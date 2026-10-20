"""
Godot Static Graph Orchestrator & CLI Facade (scripts/agent/godot_parser.py).
Coordinates tscn_parser and gdscript_parser to extract unified scene topologies,
signal wiring (static UI + dynamic code), and code symbol catalogs into Layer 1 JSON.
Supports DEC-15 Layer 3 TOON/JSONL context projections.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys
from typing import Any, Dict, Tuple

ROOT_DIR = Path(__file__).resolve().parents[2]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.gdscript_parser import parse_all_gd_files
from scripts.agent.models import FixableBy, Issue, ResultEnvelope, Severity, compute_raw_sha256, write_canonical_json
from scripts.agent.toon_projector import format_projection
from scripts.agent.tscn_parser import parse_all_tscn_files

DEFAULT_GODOT_ROOT = ROOT_DIR / "Than_Tham_Nua_Voi_Godot"
SCENE_GRAPH_JSON = ROOT_DIR / "docs/agent-system/evidence/godot/scene_graph.json"
CODE_SYMBOLS_JSON = ROOT_DIR / "docs/agent-system/evidence/godot/code_symbols.json"


def parse_and_export_all(
    godot_root: Path = DEFAULT_GODOT_ROOT,
    scene_out: Path = SCENE_GRAPH_JSON,
    code_out: Path = CODE_SYMBOLS_JSON,
) -> Tuple[Dict[str, Any], Dict[str, Any]]:
    """Parse all .tscn and .gd files, merge connections, and export Layer 1 canonical JSON."""
    scenes, nodes, static_conns, scene_deps = parse_all_tscn_files(godot_root)
    scripts, methods, signals, dynamic_conns, code_deps = parse_all_gd_files(godot_root)

    # Unified signal connections: combine static UI bindings and dynamic GDScript .connect() wiring
    all_connections = static_conns + dynamic_conns

    scene_payload = {
        "schema_version": "1.1",
        "total_scenes": len(scenes),
        "total_nodes": len(nodes),
        "total_static_ui_connections": len(static_conns),
        "total_dynamic_code_connections": len(dynamic_conns),
        "total_connections": len(all_connections),
        "total_dependencies": len(scene_deps),
        "scenes": scenes,
        "nodes": nodes,
        "connections": all_connections,
        "dependencies": scene_deps,
    }
    write_canonical_json(scene_out, scene_payload)

    code_payload = {
        "schema_version": "1.1",
        "total_scripts": len(scripts),
        "total_methods": len(methods),
        "total_signals": len(signals),
        "total_dynamic_connections": len(dynamic_conns),
        "total_dependencies": len(code_deps),
        "scripts": scripts,
        "methods": methods,
        "signals": signals,
        "dynamic_connections": dynamic_conns,
        "dependencies": code_deps,
    }
    write_canonical_json(code_out, code_payload)
    return scene_payload, code_payload


def verify_godot_parser(
    workspace_root: Path = ROOT_DIR,
    scene_out: Path = SCENE_GRAPH_JSON,
    code_out: Path = CODE_SYMBOLS_JSON,
) -> ResultEnvelope:
    """Verify scene_graph.json and code_symbols.json coverage and integrity."""
    issues: list[Issue] = []
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
    total_nodes = sc_data.get("total_nodes", 0)
    total_conns = sc_data.get("total_connections", 0)
    total_dynamic_conns = sc_data.get("total_dynamic_code_connections", 0)
    total_scripts = cd_data.get("total_scripts", 0)
    total_methods = cd_data.get("total_methods", 0)

    if total_scenes < 20:
        issues.append(Issue(
            code="ERR_TOO_FEW_SCENES", severity=Severity.ERROR,
            message=f"Expected >= 20 scenes, observed {total_scenes}.", location=scene_out.name, fixable_by=FixableBy.AI,
        ))
    if total_nodes < 1000:
        issues.append(Issue(
            code="ERR_TOO_FEW_NODES", severity=Severity.ERROR,
            message=f"Expected >= 1,000 nodes, observed {total_nodes}.", location=scene_out.name, fixable_by=FixableBy.AI,
        ))
    if total_dynamic_conns < 150:
        issues.append(Issue(
            code="ERR_TOO_FEW_DYNAMIC_CONNS", severity=Severity.ERROR,
            message=f"Expected >= 150 dynamic .connect() calls, observed {total_dynamic_conns}.", location=scene_out.name, fixable_by=FixableBy.AI,
        ))
    if total_scripts < 250:
        issues.append(Issue(
            code="ERR_TOO_FEW_SCRIPTS", severity=Severity.ERROR,
            message=f"Expected >= 250 scripts, observed {total_scripts}.", location=code_out.name, fixable_by=FixableBy.AI,
        ))
    if total_methods < 3600:
        issues.append(Issue(
            code="ERR_TOO_FEW_METHODS", severity=Severity.ERROR,
            message=f"Expected >= 3,600 methods (including multiline), observed {total_methods}.", location=code_out.name, fixable_by=FixableBy.AI,
        ))

    return ResultEnvelope(
        success=not any(i.severity == Severity.ERROR for i in issues),
        tool="godot_parser",
        issues=issues,
        data={
            "total_scenes": total_scenes,
            "total_nodes": total_nodes,
            "total_static_ui_connections": sc_data.get("total_static_ui_connections", 0),
            "total_dynamic_code_connections": total_dynamic_conns,
            "total_connections": total_conns,
            "total_scripts": total_scripts,
            "total_methods": total_methods,
            "total_signals": cd_data.get("total_signals", 0),
            "scene_graph_sha256": compute_raw_sha256(scene_out),
            "code_symbols_sha256": compute_raw_sha256(code_out),
        },
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Godot Static Graph Orchestrator & Symbol Extractor")
    parser.add_argument("--parse", action="store_true", help="Parse .tscn and .gd files to JSON")
    parser.add_argument("--verify", action="store_true", help="Verify scene_graph.json and code_symbols.json")
    parser.add_argument("--target", choices=["scenes", "symbols"], default="scenes", help="Target artifact for projection")
    parser.add_argument("--format", choices=["toon", "json", "json_compact", "jsonl"], default=None)
    parser.add_argument("--select", default=None, help="Dotted path or column filter")
    args = parser.parse_args()

    if args.parse or (not args.parse and not args.verify and not args.format):
        s_data, c_data = parse_and_export_all()
        if not args.format:
            print(
                f"Parsed {s_data['total_scenes']} scenes ({s_data['total_nodes']} nodes, "
                f"{s_data['total_static_ui_connections']} static UI + "
                f"{s_data['total_dynamic_code_connections']} dynamic code connections) "
                f"and {c_data['total_scripts']} scripts ({c_data['total_methods']} methods)."
            )

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
