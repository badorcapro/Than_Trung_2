"""Cross-Project Subgraph Mapping Query and Verification Tool (TASK-0032).

Provides CLI query and verification for cross_project_mapping.json, connecting
the Godot Fan-Game (Than_Tham_Nua_Voi_Godot) to Dupery Unity source trees,
13 handbooks, and DEC-26 60 FPS gameplay reference captures.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

ROOT_DIR = Path(__file__).resolve().parents[2]
DEFAULT_MAPPING = ROOT_DIR / "docs/agent-system/evidence/dupery/cross_project_mapping.json"


def load_mapping_artifact(path: Path = DEFAULT_MAPPING) -> Dict[str, Any]:
    """Load cross-project mapping JSON artifact."""
    if not path.exists():
        raise FileNotFoundError(f"Mapping artifact not found: {path}")
    return json.loads(path.read_text(encoding="utf-8"))


def verify_mapping_integrity(
    data: Dict[str, Any],
    root_dir: Path = ROOT_DIR,
) -> Tuple[bool, List[str], Dict[str, int]]:
    """Verify that all referenced C# sources, handbooks, and reference captures exist on disk."""
    errors: List[str] = []
    mappings: List[Dict[str, Any]] = data.get("mappings", [])

    if len(mappings) != 12:
        errors.append(f"Expected 12 mappings, got {len(mappings)}")

    verified_sources = 0
    verified_handbooks = 0
    verified_videos = 0

    for m in mappings:
        m_id = m.get("id", "UNKNOWN")

        # 1. Verify C# source files
        for src in m.get("dupery_source_files", []):
            src_path = root_dir / src
            if not src_path.exists():
                errors.append(f"[{m_id}] Source C# file missing: {src}")
            else:
                verified_sources += 1

        # 2. Verify Handbook document
        hb = m.get("handbook_reference", "")
        if hb:
            hb_path = root_dir / hb
            if not hb_path.exists():
                errors.append(f"[{m_id}] Handbook missing: {hb}")
            else:
                verified_handbooks += 1

        # 3. Verify Golden Reference Capture
        ref_cap = m.get("golden_reference_capture", {})
        vid_file = ref_cap.get("file", "")
        if vid_file:
            vid_path = root_dir / vid_file
            if not vid_path.exists():
                errors.append(f"[{m_id}] Golden Reference video missing: {vid_file}")
            else:
                verified_videos += 1

    stats = {
        "total_mappings": len(mappings),
        "verified_sources": verified_sources,
        "verified_handbooks": verified_handbooks,
        "verified_videos": verified_videos,
    }
    return len(errors) == 0, errors, stats


def search_mappings(
    data: Dict[str, Any],
    vong: Optional[str] = None,
    keyword: Optional[str] = None,
    map_id: Optional[str] = None,
) -> List[Dict[str, Any]]:
    """Search mapping entries based on filter criteria."""
    results = []
    for m in data.get("mappings", []):
        if map_id and m.get("id", "").lower() != map_id.lower():
            continue
        if vong and m.get("vong", "").lower() != vong.lower():
            continue
        if keyword:
            kw = keyword.lower()
            text_corpus = (
                m.get("subsystem", "")
                + " " + m.get("target_godot_feature", "")
                + " " + " ".join(m.get("godot_target_nodes", []))
                + " " + " ".join(m.get("dupery_unity_classes", []))
            ).lower()
            if kw not in text_corpus:
                continue
        results.append(m)
    return results


def format_recipe_card(m: Dict[str, Any]) -> str:
    """Format an interactive live lookup recipe card."""
    lines = [
        f"============================================================",
        f"  RECIPE [{m.get('id')}] - {m.get('subsystem')}",
        f"============================================================",
        f"  * Vòng / Depth: {m.get('vong')} ({m.get('depth')})",
        f"  * Godot Target: {m.get('target_godot_feature')}",
        f"  * Godot Nodes:  {', '.join(m.get('godot_target_nodes', []))}",
        f"  * Unity C#:     {', '.join(m.get('dupery_unity_classes', []))}",
        f"  * Handbook:     {m.get('handbook_reference')}",
        f"  * Master Sec:   {m.get('master_encyclopedia_section')}",
        f"  * Golden Video: {m.get('golden_reference_capture', {}).get('file')}",
        f"    Action:       {m.get('golden_reference_capture', {}).get('action')}",
        f"    Timestamp:    {m.get('golden_reference_capture', {}).get('timestamp')}",
        f"    Invariants:   {m.get('golden_reference_capture', {}).get('timing_invariants')}",
        f"  * Live Lookup:  {m.get('rea_live_lookup_recipe')}",
        f"------------------------------------------------------------",
    ]
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description="Query and verify cross-project mappings.")
    parser.add_argument("--mapping", type=Path, default=DEFAULT_MAPPING)
    parser.add_argument("--vong", type=str, help="Filter by cycle (e.g. V1, V2, V6, audio_bridge)")
    parser.add_argument("--keyword", type=str, help="Search across subsystem names and classes")
    parser.add_argument("--id", type=str, help="Find mapping by exact ID")
    parser.add_argument("--verify", action="store_true", help="Validate that 100% of referenced files exist")
    args = parser.parse_args()

    data = load_mapping_artifact(args.mapping)

    if args.verify:
        passed, errors, stats = verify_mapping_integrity(data, ROOT_DIR)
        print("=== Cross-Project Mapping Verification ===")
        print(f"Status: {'PASS' if passed else 'FAIL'}")
        print(f"Total Mappings: {stats.get('total_mappings')}/12")
        print(f"Verified C# Sources: {stats.get('verified_sources')}")
        print(f"Verified Handbooks: {stats.get('verified_handbooks')}")
        print(f"Verified Golden Videos: {stats.get('verified_videos')}")
        if not passed:
            for err in errors:
                print(f"  - {err}", file=sys.stderr)
            return 1
        return 0

    results = search_mappings(data, args.vong, args.keyword, args.id)
    print(f"Found {len(results)} matching cross-project recipes:\n")
    for r in results:
        print(format_recipe_card(r))
        print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
