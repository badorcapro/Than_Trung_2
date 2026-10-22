"""
Godot 4 Runtime Scene Tree Capture & Static Correlation Engine (scripts/agent/capture_runtime_tree.py).
Executes scenes/tools/RuntimeTreeDump.tscn in windowed GL mode (--audio-driver Dummy) respecting
GEMINI.md Core Guardrail 1 (no headless crash), extracts live /root hierarchy, and correlates
runtime nodes against static scene_graph.json into runtime_static_correlation.json.
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
from typing import Any, Dict, List, Optional, Set, Tuple

ROOT_DIR = Path(__file__).resolve().parents[2]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.models import (
    FixableBy,
    Issue,
    ResultEnvelope,
    Severity,
    write_canonical_json,
)

DEFAULT_PROJECT_DIR = ROOT_DIR / "Than_Tham_Nua_Voi_Godot"
RUNTIME_TREE_JSON = ROOT_DIR / "docs/agent-system/evidence/godot/runtime_scene_tree.json"
CORRELATION_JSON = ROOT_DIR / "docs/agent-system/evidence/godot/runtime_static_correlation.json"
STATIC_SCENE_GRAPH_JSON = ROOT_DIR / "docs/agent-system/evidence/godot/scene_graph.json"
KNOWN_GODOT_PATHS = [
    Path("D:/Minh/Tool_App/godot.exe"),
    Path("C:/Program Files/Godot/godot.exe"),
]


def find_godot_binary() -> Optional[Path]:
    """Locate Godot 4 executable from environment, default path, or system PATH."""
    env_bin = os.environ.get("GODOT4_BIN")
    if env_bin:
        p = Path(env_bin)
        if p.exists() and p.is_file():
            return p
    for candidate in KNOWN_GODOT_PATHS:
        if candidate.exists() and candidate.is_file():
            return candidate
    which_bin = shutil.which("godot") or shutil.which("godot4")
    return Path(which_bin) if which_bin else None


def execute_godot_capture(
    godot_bin: Path,
    project_dir: Path,
    timeout_sec: int = 15,
) -> Tuple[bool, str]:
    """Execute Windowed GL Godot scene to dump runtime scene tree."""
    cmd = [
        str(godot_bin),
        "--path",
        str(project_dir),
        "--scene",
        "scenes/tools/RuntimeTreeDump.tscn",
        "--audio-driver",
        "Dummy",
        "--resolution",
        "640x480",
        "--position",
        "100,100",
    ]
    try:
        proc = subprocess.run(
            cmd,
            cwd=str(project_dir),
            capture_output=True,
            text=True,
            check=False,
            timeout=timeout_sec,
        )
        if proc.returncode != 0:
            err = proc.stderr.strip() or f"Process exited with code {proc.returncode}"
            return False, err
        return True, proc.stdout.strip()
    except subprocess.TimeoutExpired:
        return False, f"Godot execution timed out after {timeout_sec}s."
    except OSError as exc:
        return False, f"Failed to launch Godot: {exc}"


def flatten_runtime_nodes(node: Dict[str, Any], path_prefix: str = "") -> List[Dict[str, Any]]:
    """Flatten hierarchical runtime node dictionary into a flat table."""
    flat: List[Dict[str, Any]] = []
    current_path = node.get("node_path") or f"{path_prefix}/{node.get('name', 'Unknown')}"
    flat.append({
        "name": node.get("name", ""),
        "class_name": node.get("class_name", ""),
        "node_path": current_path,
        "scene_file_path": node.get("scene_file_path", ""),
        "script_path": node.get("script_path", ""),
        "groups": node.get("groups", []),
        "children_count": node.get("children_count", 0),
    })
    for child in node.get("children", []):
        flat.extend(flatten_runtime_nodes(child, current_path))
    return flat


def correlate_nodes(
    runtime_nodes: List[Dict[str, Any]],
    autoload_singletons: List[Dict[str, Any]],
    static_graph_data: Dict[str, Any],
) -> Dict[str, Any]:
    """Compare runtime node inventory against static scene_graph.json declarations."""
    autoload_names: Set[str] = {a.get("name", "") for a in autoload_singletons}
    static_nodes = static_graph_data.get("nodes", [])
    static_node_names: Set[str] = {n.get("name", "") for n in static_nodes}
    static_map: Dict[str, Dict[str, Any]] = {n.get("name", ""): n for n in static_nodes}

    correlated: List[Dict[str, Any]] = []
    matched_static = 0
    matched_autoload = 0
    dynamic_only = 0

    for r in runtime_nodes:
        name = r["name"]
        path = r["node_path"]
        category = "dynamic_runtime_only"
        matched_scene = ""
        static_type = ""

        if name in autoload_names or (path.startswith("/root/") and path.count("/") == 2 and name in autoload_names):
            category = "autoload_singleton"
            matched_autoload += 1
        elif name in static_node_names:
            category = "static_declared_node"
            matched_static += 1
            matched_scene = static_map[name].get("scene_path", "")
            static_type = static_map[name].get("type", "")
        else:
            dynamic_only += 1

        correlated.append({
            "name": name,
            "class_name": r["class_name"],
            "node_path": path,
            "category": category,
            "matched_scene": matched_scene,
            "static_type": static_type,
            "script_path": r["script_path"],
            "groups_count": len(r["groups"]),
        })

    total = len(runtime_nodes)
    ratio = round((matched_static + matched_autoload) / total * 100.0, 2) if total else 0.0

    return {
        "summary": {
            "total_runtime_nodes": total,
            "autoload_singletons_count": matched_autoload,
            "static_declared_nodes_count": matched_static,
            "dynamic_runtime_only_count": dynamic_only,
            "correlation_confidence_pct": ratio,
        },
        "correlated_nodes": correlated,
    }


def run_pipeline(
    workspace_root: Path = ROOT_DIR,
    force_capture: bool = False,
) -> ResultEnvelope:
    """Execute capture if needed, correlate against static graph, and write canonical evidence."""
    issues: List[Issue] = []
    runtime_json = workspace_root / "docs/agent-system/evidence/godot/runtime_scene_tree.json"
    correlation_json = workspace_root / "docs/agent-system/evidence/godot/runtime_static_correlation.json"
    static_json = workspace_root / "docs/agent-system/evidence/godot/scene_graph.json"
    project_dir = workspace_root / "Than_Tham_Nua_Voi_Godot"

    if force_capture or not runtime_json.exists():
        godot_bin = find_godot_binary()
        if not godot_bin:
            issues.append(Issue(
                code="ERR_GODOT_BINARY_NOT_FOUND",
                severity=Severity.ERROR,
                message="Godot 4 binary not found. Set GODOT4_BIN or place godot.exe at D:/Minh/Tool_App/godot.exe.",
                location="Than_Tham_Nua_Voi_Godot",
                fixable_by=FixableBy.HUMAN,
            ))
            return ResultEnvelope(success=False, tool="capture_runtime_tree", issues=issues)

        ok, msg = execute_godot_capture(godot_bin, project_dir)
        if not ok or not runtime_json.exists():
            issues.append(Issue(
                code="ERR_GODOT_CAPTURE_FAILED",
                severity=Severity.ERROR,
                message=f"Godot windowed capture failed: {msg}",
                location="scenes/tools/RuntimeTreeDump.tscn",
                fixable_by=FixableBy.AI,
            ))
            return ResultEnvelope(success=False, tool="capture_runtime_tree", issues=issues)

    if not static_json.exists():
        issues.append(Issue(
            code="ERR_STATIC_GRAPH_NOT_FOUND",
            severity=Severity.ERROR,
            message=f"Static scene_graph.json not found at '{static_json.as_posix()}'. Run godot_parser.py first.",
            location=static_json.as_posix(),
            fixable_by=FixableBy.AI,
        ))
        return ResultEnvelope(success=False, tool="capture_runtime_tree", issues=issues)

    raw_tree = json.loads(runtime_json.read_text(encoding="utf-8"))
    raw_static = json.loads(static_json.read_text(encoding="utf-8"))

    root_node = raw_tree.get("root_node", {})
    autoloads = raw_tree.get("autoload_singletons", [])
    flat_nodes = flatten_runtime_nodes(root_node)

    correlation_payload = correlate_nodes(flat_nodes, autoloads, raw_static)
    write_canonical_json(correlation_json, correlation_payload)

    return ResultEnvelope(
        success=True,
        tool="capture_runtime_tree",
        issues=issues,
        data={
            "runtime_scene_tree": runtime_json.relative_to(workspace_root).as_posix(),
            "runtime_static_correlation": correlation_json.relative_to(workspace_root).as_posix(),
            "summary": correlation_payload["summary"],
        },
    )


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Capture Godot 4 Runtime Tree & Correlate with Static Graph.")
    parser.add_argument("--root", type=Path, default=ROOT_DIR, help="Workspace root directory")
    parser.add_argument("--verify", action="store_true", help="Run verification pipeline and output JSON envelope")
    parser.add_argument("--force-capture", action="store_true", help="Force re-executing Godot windowed process")
    args = parser.parse_args(argv)

    res = run_pipeline(workspace_root=args.root.resolve(), force_capture=args.force_capture)
    print(json.dumps(res.model_dump(mode="json"), indent=2, ensure_ascii=False))
    return res.exit_code


if __name__ == "__main__":
    sys.exit(main())
