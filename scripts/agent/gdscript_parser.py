"""
Godot GDScript AST & Symbol Parser (scripts/agent/gdscript_parser.py).
Parses class definitions, inner classes, multiline function signatures, signals,
dynamic .connect() signal wiring, signal emissions, and preload dependencies.
"""

from __future__ import annotations

from pathlib import Path
import re
from typing import Any, Dict, List, Optional, Tuple

_CLASS_RE = re.compile(r"^\s*class_name\s+([A-Za-z0-9_]+)")
_EXTENDS_RE = re.compile(r"^\s*extends\s+([A-Za-z0-9_.]+)")
_INNER_CLASS_RE = re.compile(r"^\s*class\s+([A-Za-z0-9_]+)(?:\s+extends\s+([A-Za-z0-9_.]+))?:")
_SIGNAL_DECL_RE = re.compile(r"^\s*signal\s+([A-Za-z0-9_]+)(?:\(([^)]*)\))?")
_FUNC_HEAD_RE = re.compile(r"^\s*(static\s+)?func\s+([A-Za-z0-9_]+)\s*\(")
_PRELOAD_RE = re.compile(r'(?:preload|load)\s*\(\s*["\']([^"\']+)["\']\s*\)')

# Dynamic signal connection patterns (Godot 4: emitter.signal.connect(handler) or signal.connect(handler))
_DOT_CONNECT_RE = re.compile(r'(\b[A-Za-z0-9_$.]+(?:\([^)]*\))?\.|\b)([A-Za-z0-9_]+)\.connect\s*\((.*)')
_CALL_CONNECT_RE = re.compile(r'(?:^|[^A-Za-z0-9_])connect\s*\(\s*["\']([A-Za-z0-9_]+)["\']\s*,\s*([^)]+)\)')
_FUNC_SIG_END_RE = re.compile(r"\)\s*(?:->\s*([^:]+))?\s*:")


def split_parameters(raw: str) -> List[str]:
    """Split parameter list by comma, respecting nested brackets and string literals."""
    tokens: List[str] = []
    current: List[str] = []
    depth = 0
    in_quote: Optional[str] = None

    for ch in raw:
        if in_quote:
            current.append(ch)
            if ch == in_quote:
                in_quote = None
        elif ch in ('"', "'"):
            in_quote = ch
            current.append(ch)
        elif ch in "([{":
            depth += 1
            current.append(ch)
        elif ch in ")]}":
            depth = max(0, depth - 1)
            current.append(ch)
        elif ch == "," and depth == 0:
            tokens.append("".join(current).strip())
            current = []
        else:
            current.append(ch)

    if current:
        trailing = "".join(current).strip()
        if trailing:
            tokens.append(trailing)
    return tokens


def parse_function_parameters(params_raw: str) -> List[Dict[str, str]]:
    """Parse comma-separated parameter declarations, handling types and defaults."""
    params: List[Dict[str, str]] = []
    if not params_raw.strip():
        return params

    for raw in split_parameters(params_raw):
        p = raw.strip()
        if not p:
            continue
        p_name, _, p_default = p.partition("=")
        p_name, _, p_type = p_name.partition(":")
        params.append({
            "name": p_name.strip(),
            "type": p_type.strip() if p_type else "Variant",
            "default": p_default.strip() if p_default else "none",
        })
    return params


def extract_multiline_functions(lines: List[str], rel_path: str) -> List[Dict[str, Any]]:
    """State-machine parsing function declarations across multiple lines."""
    methods: List[Dict[str, Any]] = []
    idx = 0
    total = len(lines)

    while idx < total:
        line = lines[idx]
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            idx += 1
            continue

        if m_head := _FUNC_HEAD_RE.match(line):
            is_static = bool(m_head.group(1))
            func_name = m_head.group(2)
            start_line = idx + 1

            buf = line
            while idx < total and not _FUNC_SIG_END_RE.search(buf):
                idx += 1
                if idx < total:
                    buf += " " + lines[idx].strip()

            if m_end := _FUNC_SIG_END_RE.search(buf):
                ret_raw = m_end.group(1)
                return_type = ret_raw.strip() if ret_raw else "void"
                paren_start = buf.find("(")
                params_raw = buf[paren_start + 1 : m_end.start()]
                parsed_params = parse_function_parameters(params_raw)

                methods.append({
                    "script_path": rel_path,
                    "name": func_name,
                    "is_static": is_static,
                    "return_type": return_type,
                    "param_count": len(parsed_params),
                    "params": [p["name"] for p in parsed_params],
                    "start_line": start_line,
                })
        idx += 1

    return methods


def extract_dynamic_connections(lines: List[str], rel_path: str) -> List[Dict[str, Any]]:
    """Extract dynamic signal connection calls (.connect and legacy connect(...))."""
    conns: List[Dict[str, Any]] = []
    for line_idx, line in enumerate(lines, 1):
        s = line.strip()
        if not s or s.startswith("#"):
            continue

        for m in _DOT_CONNECT_RE.finditer(line):
            raw_emitter = m.group(1).rstrip(".").strip()
            source_obj = raw_emitter if raw_emitter else "self"
            signal_name = m.group(2).strip()
            raw_target = m.group(3).strip()
            if raw_target.startswith("func"):
                target_callable = "<lambda>"
            else:
                target_callable = raw_target.rstrip(");").strip()

            conns.append({
                "script_path": rel_path,
                "kind": "dynamic_code",
                "signal": signal_name,
                "from_node": source_obj,
                "to_node": "callable",
                "method": target_callable,
                "source_line": line_idx,
            })

        for m in _CALL_CONNECT_RE.finditer(line):
            raw_target = m.group(2).strip()
            target_callable = "<lambda>" if raw_target.startswith("func") else raw_target.rstrip(");").strip()
            conns.append({
                "script_path": rel_path,
                "kind": "dynamic_code",
                "signal": m.group(1).strip(),
                "from_node": "self",
                "to_node": "target",
                "method": target_callable,
                "source_line": line_idx,
            })
    return conns


def parse_gd_file(
    path: Path, godot_root: Path
) -> Tuple[Dict[str, Any], List[Dict[str, Any]], List[Dict[str, Any]], List[Dict[str, Any]], List[Dict[str, Any]]]:
    """Parse a single .gd file for class declarations, methods, signals, dynamic wiring, and deps."""
    rel_path = path.relative_to(godot_root).as_posix()
    text = path.read_text(encoding="utf-8", errors="ignore")
    lines = text.splitlines()

    class_name = "none"
    extends_name = "Object"
    signals: List[Dict[str, Any]] = []
    deps: List[Dict[str, Any]] = []
    inner_classes: List[str] = []

    for line_idx, line in enumerate(lines, 1):
        s = line.strip()
        if not s or s.startswith("#"):
            continue

        if class_name == "none" and (m_cn := _CLASS_RE.match(line)):
            class_name = m_cn.group(1)
        if extends_name == "Object" and (m_ex := _EXTENDS_RE.match(line)):
            extends_name = m_ex.group(1)
        if m_in := _INNER_CLASS_RE.match(line):
            inner_classes.append(m_in.group(1))

        if m_sig := _SIGNAL_DECL_RE.match(line):
            params = [p.strip() for p in (m_sig.group(2) or "").split(",") if p.strip()]
            signals.append({
                "script_path": rel_path,
                "name": m_sig.group(1),
                "param_count": len(params),
                "source_line": line_idx,
            })

        for m_pre in _PRELOAD_RE.finditer(line):
            deps.append({
                "script_path": rel_path,
                "target_path": m_pre.group(1).replace("res://", ""),
                "kind": "preload",
                "source_line": line_idx,
            })

    methods = extract_multiline_functions(lines, rel_path)
    dynamic_conns = extract_dynamic_connections(lines, rel_path)

    layer = "other"
    for prefix in ("domain", "application", "infrastructure", "presentation", "tools"):
        if rel_path.lower().startswith(f"scripts/{prefix}/"):
            layer = prefix
            break

    script_entry = {
        "path": rel_path,
        "layer": layer,
        "class_name": class_name,
        "extends": extends_name,
        "method_count": len(methods),
        "signal_count": len(signals),
        "dynamic_connection_count": len(dynamic_conns),
        "preload_count": len(deps),
        "inner_class_count": len(inner_classes),
        "loc": len(lines),
    }
    return script_entry, methods, signals, dynamic_conns, deps


def parse_all_gd_files(
    godot_root: Path,
) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]], List[Dict[str, Any]], List[Dict[str, Any]], List[Dict[str, Any]]]:
    """Scan and parse all .gd files in the Godot project."""
    scripts: List[Dict[str, Any]] = []
    methods: List[Dict[str, Any]] = []
    signals: List[Dict[str, Any]] = []
    connections: List[Dict[str, Any]] = []
    deps: List[Dict[str, Any]] = []

    for path in sorted(godot_root.rglob("*.gd")):
        if path.is_file() and ".godot" not in path.parts:
            sc_entry, sc_methods, sc_signals, sc_conns, sc_deps = parse_gd_file(path, godot_root)
            scripts.append(sc_entry)
            methods.extend(sc_methods)
            signals.extend(sc_signals)
            connections.extend(sc_conns)
            deps.extend(sc_deps)

    return scripts, methods, signals, connections, deps
