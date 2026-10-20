"""
Godot Static Graph Parser & Symbol Extractor (scripts/agent/godot_parser.py).
Extracts Scene Node Hierarchy, ExtResources, and Signal Connections from all .tscn files,
and class definitions, signals, methods, and preload dependencies from all .gd scripts.
Supports DEC-15 Layer 3 TOON/JSONL context projections.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import re
import sys
from typing import Any, Dict, List, Optional, Tuple

ROOT_DIR = Path(__file__).resolve().parents[2]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.models import FixableBy, Issue, ResultEnvelope, Severity, compute_raw_sha256, write_canonical_json
from scripts.agent.toon_projector import format_projection

DEFAULT_GODOT_ROOT = ROOT_DIR / "Than_Tham_Nua_Voi_Godot"
SCENE_GRAPH_JSON = ROOT_DIR / "docs/agent-system/evidence/godot/scene_graph.json"
CODE_SYMBOLS_JSON = ROOT_DIR / "docs/agent-system/evidence/godot/code_symbols.json"

_ATTR_RE = re.compile(r'(\w+)="([^"]+)"')
_EXT_RES_REF_RE = re.compile(r'ExtResource\("([^"]+)"\)')
_CLASS_RE = re.compile(r"^\s*class_name\s+([A-Za-z0-9_]+)")
_EXTENDS_RE = re.compile(r"^\s*extends\s+([A-Za-z0-9_.]+)")
_SIGNAL_RE = re.compile(r"^\s*signal\s+([A-Za-z0-9_]+)(?:\(([^)]*)\))?")
_FUNC_RE = re.compile(r"^\s*(static\s+)?func\s+([A-Za-z0-9_]+)\s*\(([^)]*)\)(?:\s*->\s*([A-Za-z0-9_.]+))?:")
_PRELOAD_RE = re.compile(r'preload\s*\(\s*["\']([^"\']+)["\']\s*\)')


def parse_tag_attributes(line: str) -> Dict[str, str]:
    """Extract key-value pairs from a Godot tag line (e.g. [node name=... type=...])."""
    return {m.group(1): m.group(2) for m in _ATTR_RE.finditer(line)}


def parse_tscn_file(
    path: Path, godot_root: Path
) -> Tuple[Dict[str, Any], List[Dict[str, Any]], List[Dict[str, Any]], List[Dict[str, Any]]]:
    """Parse a single .tscn file for metadata, nodes, connections, and external resources."""
    rel_path = path.relative_to(godot_root).as_posix()
    text = path.read_text(encoding="utf-8", errors="ignore")
    lines = text.splitlines()

    ext_resources: Dict[str, Dict[str, str]] = {}
    nodes: List[Dict[str, Any]] = []
    connections: List[Dict[str, Any]] = []
    deps: List[Dict[str, Any]] = []
    current_node: Optional[Dict[str, Any]] = None

    for line in lines:
        s = line.strip()
        if not s or s.startswith(";"):
            continue
        if s.startswith("[ext_resource"):
            attrs = parse_tag_attributes(s)
            res_id = attrs.get("id", "")
            ext_resources[res_id] = attrs
            deps.append({
                "scene_path": rel_path,
                "res_id": res_id,
                "res_type": attrs.get("type", "Resource"),
                "res_path": attrs.get("path", "").replace("res://", ""),
                "uid": attrs.get("uid", "none"),
            })
            continue

        if s.startswith("[node"):
            if current_node:
                nodes.append(current_node)
            attrs = parse_tag_attributes(s)
            name = attrs.get("name", "Unnamed")
            parent = attrs.get("parent", "")
            is_inst = "instance=" in s
            inst_id = ""
            if is_inst and (m_inst := _EXT_RES_REF_RE.search(s)):
                inst_id = m_inst.group(1)

            node_path = name if not parent or parent == "." else f"{parent}/{name}"
            current_node = {
                "scene_path": rel_path,
                "node_path": node_path,
                "name": name,
                "type": attrs.get("type", "Node" if is_inst else "Unknown"),
                "parent": parent if parent else "root",
                "script_path": "none",
                "is_instance": is_inst,
                "instance_source": ext_resources.get(inst_id, {}).get("path", "none").replace("res://", ""),
            }
            continue

        if current_node and s.startswith("script = ExtResource("):
            if m_scr := _EXT_RES_REF_RE.search(s):
                scr_id = m_scr.group(1)
                current_node["script_path"] = ext_resources.get(scr_id, {}).get("path", "none").replace("res://", "")
            continue

        if s.startswith("[connection"):
            if current_node:
                nodes.append(current_node)
                current_node = None
            attrs = parse_tag_attributes(s)
            connections.append({
                "scene_path": rel_path,
                "signal": attrs.get("signal", "unknown"),
                "from_node": attrs.get("from", "."),
                "to_node": attrs.get("to", "."),
                "method": attrs.get("method", "unknown"),
            })

    if current_node:
        nodes.append(current_node)

    root_name = nodes[0]["name"] if nodes else "Empty"
    root_type = nodes[0]["type"] if nodes else "Empty"
    root_script = nodes[0]["script_path"] if nodes else "none"

    scene_entry = {
        "path": rel_path,
        "root_name": root_name,
        "root_type": root_type,
        "script_path": root_script,
        "node_count": len(nodes),
        "connection_count": len(connections),
        "ext_resource_count": len(deps),
    }
    return scene_entry, nodes, connections, deps


def parse_gd_file(
    path: Path, godot_root: Path
) -> Tuple[Dict[str, Any], List[Dict[str, Any]], List[Dict[str, Any]], List[Dict[str, Any]]]:
    """Parse a single .gd file for class declaration, methods, signals, and preloads."""
    rel_path = path.relative_to(godot_root).as_posix()
    text = path.read_text(encoding="utf-8", errors="ignore")
    lines = text.splitlines()

    class_name = "none"
    extends_name = "Object"
    methods: List[Dict[str, Any]] = []
    signals: List[Dict[str, Any]] = []
    deps: List[Dict[str, Any]] = []

    for idx, line in enumerate(lines, 1):
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        if class_name == "none" and (m_cn := _CLASS_RE.match(line)):
            class_name = m_cn.group(1)
        if extends_name == "Object" and (m_ex := _EXTENDS_RE.match(line)):
            extends_name = m_ex.group(1)
        if m_sig := _SIGNAL_RE.match(line):
            params = [p.strip() for p in (m_sig.group(2) or "").split(",") if p.strip()]
            signals.append({
                "script_path": rel_path,
                "name": m_sig.group(1),
                "param_count": len(params),
                "start_line": idx,
            })
        elif m_fn := _FUNC_RE.match(line):
            params = [p.strip() for p in (m_fn.group(3) or "").split(",") if p.strip()]
            methods.append({
                "script_path": rel_path,
                "name": m_fn.group(2),
                "is_static": bool(m_fn.group(1)),
                "return_type": m_fn.group(4) or "void",
                "param_count": len(params),
                "start_line": idx,
            })
        for m_pre in _PRELOAD_RE.finditer(line):
            deps.append({
                "script_path": rel_path,
                "target_path": m_pre.group(1).replace("res://", ""),
                "kind": "preload",
                "line": idx,
            })

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
        "preload_count": len(deps),
        "loc": len(lines),
    }
    return script_entry, methods, signals, deps


def parse_and_export_all(
    godot_root: Path = DEFAULT_GODOT_ROOT,
    scene_out: Path = SCENE_GRAPH_JSON,
    code_out: Path = CODE_SYMBOLS_JSON,
) -> Tuple[Dict[str, Any], Dict[str, Any]]:
    """Parse all .tscn and .gd files and write Layer 1 canonical JSON artifacts."""
    all_scenes, all_nodes, all_conns, all_scene_deps = [], [], [], []
    for p in sorted(godot_root.rglob("*.tscn")):
        if p.is_file() and ".godot" not in p.parts:
            s_entry, s_nodes, s_conns, s_deps = parse_tscn_file(p, godot_root)
            all_scenes.append(s_entry)
            all_nodes.extend(s_nodes)
            all_conns.extend(s_conns)
            all_scene_deps.extend(s_deps)

    scene_payload = {
        "schema_version": "1.0",
        "total_scenes": len(all_scenes),
        "total_nodes": len(all_nodes),
        "total_connections": len(all_conns),
        "total_dependencies": len(all_scene_deps),
        "scenes": all_scenes,
        "nodes": all_nodes,
        "connections": all_conns,
        "dependencies": all_scene_deps,
    }
    write_canonical_json(scene_out, scene_payload)

    all_scripts, all_methods, all_signals, all_code_deps = [], [], [], []
    for p in sorted(godot_root.rglob("*.gd")):
        if p.is_file() and ".godot" not in p.parts:
            sc_entry, sc_methods, sc_signals, sc_deps = parse_gd_file(p, godot_root)
            all_scripts.append(sc_entry)
            all_methods.extend(sc_methods)
            all_signals.extend(sc_signals)
            all_code_deps.extend(sc_deps)

    code_payload = {
        "schema_version": "1.0",
        "total_scripts": len(all_scripts),
        "total_methods": len(all_methods),
        "total_signals": len(all_signals),
        "total_dependencies": len(all_code_deps),
        "scripts": all_scripts,
        "methods": all_methods,
        "signals": all_signals,
        "dependencies": all_code_deps,
    }
    write_canonical_json(code_out, code_payload)
    return scene_payload, code_payload


def verify_godot_parser(
    workspace_root: Path = ROOT_DIR,
    scene_out: Path = SCENE_GRAPH_JSON,
    code_out: Path = CODE_SYMBOLS_JSON,
) -> ResultEnvelope:
    """Verify scene_graph.json and code_symbols.json compliance."""
    issues: List[Issue] = []
    if not scene_out.exists():
        issues.append(Issue(
            code="ERR_SCENE_GRAPH_MISSING", severity=Severity.ERROR,
            message="scene_graph.json not found.", location=scene_out.name, fixable_by=FixableBy.AI,
        ))
    if not code_out.exists():
        issues.append(Issue(
            code="ERR_CODE_SYMBOLS_MISSING", severity=Severity.ERROR,
            message="code_symbols.json not found.", location=code_out.name, fixable_by=FixableBy.AI,
        ))
    if issues:
        return ResultEnvelope(success=False, tool="godot_parser", issues=issues)

    sc_data = json.loads(scene_out.read_text(encoding="utf-8"))
    cd_data = json.loads(code_out.read_text(encoding="utf-8"))
    total_scenes = sc_data.get("total_scenes", 0)
    total_scripts = cd_data.get("total_scripts", 0)

    if total_scenes < 20:
        issues.append(Issue(
            code="ERR_TOO_FEW_SCENES", severity=Severity.ERROR,
            message=f"Expected >= 20 scenes, observed {total_scenes}.",
            location=scene_out.name, fixable_by=FixableBy.AI,
        ))
    if total_scripts < 250:
        issues.append(Issue(
            code="ERR_TOO_FEW_SCRIPTS", severity=Severity.ERROR,
            message=f"Expected >= 250 scripts, observed {total_scripts}.",
            location=code_out.name, fixable_by=FixableBy.AI,
        ))

    return ResultEnvelope(
        success=not any(i.severity == Severity.ERROR for i in issues),
        tool="godot_parser",
        issues=issues,
        data={
            "total_scenes": total_scenes,
            "total_nodes": sc_data.get("total_nodes", 0),
            "total_connections": sc_data.get("total_connections", 0),
            "total_scripts": total_scripts,
            "total_methods": cd_data.get("total_methods", 0),
            "total_signals": cd_data.get("total_signals", 0),
            "scene_graph_sha256": compute_raw_sha256(scene_out),
            "code_symbols_sha256": compute_raw_sha256(code_out),
        },
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Godot Static Graph Parser & Symbol Extractor")
    parser.add_argument("--parse", action="store_true", help="Parse .tscn and .gd files to JSON")
    parser.add_argument("--verify", action="store_true", help="Verify scene_graph.json and code_symbols.json")
    parser.add_argument("--target", choices=["scenes", "symbols"], default="scenes", help="Target artifact for projection")
    parser.add_argument("--format", choices=["toon", "json", "json_compact", "jsonl"], default=None)
    parser.add_argument("--select", default=None, help="Dotted path or column filter")
    args = parser.parse_args()

    if args.parse or (not args.parse and not args.verify and not args.format):
        s_data, c_data = parse_and_export_all()
        if not args.format:
            print(f"Parsed {s_data['total_scenes']} scenes ({s_data['total_nodes']} nodes, {s_data['total_connections']} connections) and {c_data['total_scripts']} scripts ({c_data['total_methods']} methods).")

    if args.format:
        target_path = SCENE_GRAPH_JSON if args.target == "scenes" else CODE_SYMBOLS_JSON
        if not target_path.exists():
            parse_and_export_all()
        raw = json.loads(target_path.read_text(encoding="utf-8"))
        print(format_projection(raw, args.format, target_path, ROOT_DIR, args.select))

    if args.verify:
        env = verify_godot_parser()
        print(json.dumps(env.model_dump(mode="json"), indent=2))
        sys.exit(env.exit_code)


if __name__ == "__main__":
    main()
