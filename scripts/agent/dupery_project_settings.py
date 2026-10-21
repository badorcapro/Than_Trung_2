"""
Dupery Project Settings Extractor & Cataloger (TASK-0013 per P1).
Extracts 11 core Project Settings managers from globalgamemanagers into individual
canonical JSON files and generates a unified project_settings_summary.json mapping.
"""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import sys
from typing import Any, Dict, List, Optional, Tuple

ROOT_DIR = Path(__file__).resolve().parents[2]
DEFAULT_GGM = Path("D:/Minh/Steam/steamapps/common/Dupery/Dupery_Data/globalgamemanagers")
DEFAULT_OUT_DIR = ROOT_DIR / "docs/agent-system/evidence/dupery/project_settings"

TARGET_MANAGERS = [
    "BuildSettings",
    "TagManager",
    "Physics2DSettings",
    "QualitySettings",
    "GraphicsSettings",
    "TimeManager",
    "InputManager",
    "PlayerSettings",
    "AudioManager",
    "PhysicsManager",
    "NavMeshProjectSettings",
]


def extract_project_settings(
    ggm_path: Path = DEFAULT_GGM,
    out_dir: Path = DEFAULT_OUT_DIR,
) -> Dict[str, Any]:
    """Extract 11 managers from globalgamemanagers to out_dir and return summary."""
    import UnityPy

    if not ggm_path.exists():
        raise FileNotFoundError(f"globalgamemanagers not found: {ggm_path}")

    out_dir.mkdir(parents=True, exist_ok=True)
    env = UnityPy.load(str(ggm_path))

    extracted: Dict[str, Any] = {}
    for obj in env.objects:
        tname = obj.type.name
        if tname in TARGET_MANAGERS:
            try:
                tree = obj.read_typetree()
                extracted[tname] = tree
                out_file = out_dir / f"{tname}.json"
                out_file.write_text(json.dumps(tree, indent=2), encoding="utf-8")
            except Exception as exc:
                extracted[tname] = {"error": str(exc)}

    # Build unified summary
    build = extracted.get("BuildSettings", {})
    raw_scenes = build.get("scenes", [])
    scenes_map = [
        {
            "build_index": idx,
            "level_file": f"level{idx}",
            "scene_path": sc,
            "scene_name": Path(sc).stem,
        }
        for idx, sc in enumerate(raw_scenes)
    ]

    player = extracted.get("PlayerSettings", {})
    tags_mgr = extracted.get("TagManager", {})
    input_mgr = extracted.get("InputManager", {})
    phys2d = extracted.get("Physics2DSettings", {})
    time_mgr = extracted.get("TimeManager", {})
    audio_mgr = extracted.get("AudioManager", {})

    axes = input_mgr.get("m_Axes", [])
    axis_names = sorted(list({a.get("m_Name") for a in axes if isinstance(a, dict) and a.get("m_Name")}))

    summary = {
        "schema_version": "1.0",
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "ggm_source": ggm_path.as_posix(),
        "total_managers_extracted": len([m for m in TARGET_MANAGERS if m in extracted and "error" not in extracted[m]]),
        "target_managers_count": len(TARGET_MANAGERS),
        "scenes_count": len(scenes_map),
        "scenes": scenes_map,
        "display": {
            "product_name": player.get("productName", ""),
            "company_name": player.get("companyName", ""),
            "default_screen_width": player.get("defaultScreenWidth", 0),
            "default_screen_height": player.get("defaultScreenHeight", 0),
            "fullscreen_mode": player.get("d3d11FullscreenMode", 0),
        },
        "tags_and_layers": {
            "tags": tags_mgr.get("tags", []),
            "layers": [l for l in tags_mgr.get("layers", []) if l],
            "sorting_layers": [sl.get("name") for sl in tags_mgr.get("m_SortingLayers", []) if isinstance(sl, dict)],
        },
        "input": {
            "total_axes_defined": len(axes),
            "unique_axis_names": axis_names,
        },
        "physics_2d": {
            "gravity": phys2d.get("m_Gravity", {}),
            "velocity_iterations": phys2d.get("m_VelocityIterations", 0),
            "position_iterations": phys2d.get("m_PositionIterations", 0),
        },
        "time": {
            "fixed_timestep": time_mgr.get("Fixed Timestep", 0.0),
            "maximum_allowed_timestep": time_mgr.get("Maximum Allowed Timestep", 0.0),
            "time_scale": time_mgr.get("m_TimeScale", 1.0),
        },
        "audio": {
            "volume": audio_mgr.get("m_Volume", 1.0),
            "speaker_mode": audio_mgr.get("Default Speaker Mode", 0),
            "sample_rate": audio_mgr.get("m_SampleRate", 0),
        },
    }

    summary_file = out_dir / "project_settings_summary.json"
    summary_file.write_text(json.dumps(summary, indent=2), encoding="utf-8")
    return summary


def verify_project_settings(out_dir: Path = DEFAULT_OUT_DIR) -> Tuple[bool, List[str]]:
    """Verify that all 11 managers and summary JSON exist, are valid, and complete."""
    errors: List[str] = []
    if not out_dir.exists():
        return False, [f"Project settings directory missing: {out_dir}"]

    summary_file = out_dir / "project_settings_summary.json"
    if not summary_file.exists():
        errors.append("project_settings_summary.json missing")
    else:
        try:
            summary = json.loads(summary_file.read_text(encoding="utf-8"))
            if summary.get("total_managers_extracted") != len(TARGET_MANAGERS):
                errors.append(f"Managers count mismatch: {summary.get('total_managers_extracted')} != {len(TARGET_MANAGERS)}")
            if len(summary.get("scenes", [])) != 12:
                errors.append(f"Scenes count mismatch: expected 12, got {len(summary.get('scenes', []))}")
        except Exception as exc:
            errors.append(f"Invalid summary JSON: {exc}")

    for mgr in TARGET_MANAGERS:
        f = out_dir / f"{mgr}.json"
        if not f.exists():
            errors.append(f"Manager JSON missing: {mgr}.json")
            continue
        try:
            data = json.loads(f.read_text(encoding="utf-8"))
            if not isinstance(data, dict) or "error" in data:
                errors.append(f"Manager JSON invalid or contains error: {mgr}.json")
        except Exception as exc:
            errors.append(f"Manager JSON parse error in {mgr}.json: {exc}")

    return len(errors) == 0, errors


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    """Parse CLI arguments."""
    parser = argparse.ArgumentParser(description="Dupery Project Settings Extractor.")
    parser.add_argument("--ggm-path", type=Path, default=DEFAULT_GGM, help="Path to globalgamemanagers")
    parser.add_argument("--out-dir", type=Path, default=DEFAULT_OUT_DIR, help="Path to output directory")
    parser.add_argument("--verify", action="store_true", help="Verify extracted project settings files")
    parser.add_argument("--stats", action="store_true", help="Extract and print summary statistics")
    return parser.parse_args(argv)


def main(argv: Optional[List[str]] = None) -> int:
    """CLI entry point."""
    args = parse_args(argv)
    if args.verify:
        passed, errors = verify_project_settings(args.out_dir)
        if passed:
            print("OK: Project settings verified. All 11 managers and summary present and valid.")
            return 0
        print("FAIL: Project settings verification failed:", file=sys.stderr)
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 1

    print(f"Extracting Project Settings from {args.ggm_path}...")
    summary = extract_project_settings(args.ggm_path, args.out_dir)
    print(f"Extracted {summary['total_managers_extracted']}/{summary['target_managers_count']} managers successfully.")
    print(f"Product: {summary['display']['product_name']} by {summary['display']['company_name']} ({summary['display']['default_screen_width']}x{summary['display']['default_screen_height']})")
    print(f"Build Scenes: {summary['scenes_count']} scenes mapped to level0..level11.")
    print(f"Input Axes: {summary['input']['total_axes_defined']} axes defined ({len(summary['input']['unique_axis_names'])} unique).")
    print(f"Output directory: {args.out_dir}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
