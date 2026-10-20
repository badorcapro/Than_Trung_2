"""
Godot TSCN Scene Parser (scripts/agent/tscn_parser.py).
Extracts Scene Metadata, Node Hierarchy, Instance Tree, External Resources,
and static UI signal connections from Godot 4 text-based .tscn files.
"""

from __future__ import annotations

from pathlib import Path
import re
from typing import Any, Dict, List, Optional, Tuple

_ATTR_RE = re.compile(r'(\w+)="([^"]+)"')
_EXT_RES_REF_RE = re.compile(r'ExtResource\("([^"]+)"\)')


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

    for line_idx, line in enumerate(lines, 1):
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
                "source_line": line_idx,
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
                "source_line": line_idx,
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
                "kind": "static_ui",
                "signal": attrs.get("signal", "unknown"),
                "from_node": attrs.get("from", "."),
                "to_node": attrs.get("to", "."),
                "method": attrs.get("method", "unknown"),
                "source_line": line_idx,
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


def parse_all_tscn_files(
    godot_root: Path,
) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]], List[Dict[str, Any]], List[Dict[str, Any]]]:
    """Scan and parse all .tscn files in the Godot project."""
    scenes: List[Dict[str, Any]] = []
    nodes: List[Dict[str, Any]] = []
    connections: List[Dict[str, Any]] = []
    deps: List[Dict[str, Any]] = []

    for path in sorted(godot_root.rglob("*.tscn")):
        if path.is_file() and ".godot" not in path.parts:
            s_entry, s_nodes, s_conns, s_deps = parse_tscn_file(path, godot_root)
            scenes.append(s_entry)
            nodes.extend(s_nodes)
            connections.extend(s_conns)
            deps.extend(s_deps)

    return scenes, nodes, connections, deps
