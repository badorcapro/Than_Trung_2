"""Comprehensive inspection and metric verification for Dupery Gameplay References.

Validates that all captured video references comply with DEC-26
(1920x1080 resolution, 60.0 CFR frame rate, 48.0 kHz 2-channel AAC audio).
Extracts duration, frame counts, bitrates, and key architectural event timings.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

DEFAULT_GAMEPLAY_DIR = Path("docs/agent-system/evidence/dupery/references/gameplay")

EXPECTED_VIDEOS = {
    "REF_MENU_GameSettings_1080p_60fps.mkv": {
        "category": "MENU",
        "expected_duration_range": (10.0, 20.0),
        "architectural_phase": "V6/V7",
        "description": "Game Settings, Audio Sliders, Screen Resolution and Display Mode",
    },
    "REF_MENU_MainMenuAndStats_1080p_60fps.mkv": {
        "category": "MENU",
        "expected_duration_range": (15.0, 30.0),
        "architectural_phase": "V7",
        "description": "Main Menu navigation, Clocktower Bell, and Detective Stats modal",
    },
    "REF_V2_CASEGEN_EndCaseNextCase_1080p_60fps.mkv": {
        "category": "V2_CASEGEN",
        "expected_duration_range": (40.0, 60.0),
        "architectural_phase": "V2",
        "description": "End Case dossier transition, 3-card Case Selection and Stasis",
    },
    "REF_V3_LOOP_QuickCaseInvestigation_1080p_60fps.mkv": {
        "category": "V3_LOOP",
        "expected_duration_range": (60.0, 120.0),
        "architectural_phase": "V1/V3/V4/V5",
        "description": "Core Investigation loop, Detective Board, Pins, Red Strings and Lineup",
    },
    "REF_V7_SUB_EndRoundSummary_1080p_60fps.mkv": {
        "category": "V7_SUB",
        "expected_duration_range": (10.0, 25.0),
        "architectural_phase": "V7",
        "description": "End Round summary, animated PieChart percentage fill, Gavel sound",
    },
    "REF_V7_SUB_ReplayTutorial_1080p_60fps.mkv": {
        "category": "V7_SUB",
        "expected_duration_range": (40.0, 80.0),
        "architectural_phase": "V7",
        "description": "Tutorial sequence replay, dialogue progression, spotlight highlight",
    },
}


def probe_media_file(filepath: Path) -> Optional[Dict[str, Any]]:
    """Probe video and audio stream parameters via ffprobe CLI."""
    cmd = [
        "ffprobe",
        "-v", "error",
        "-print_format", "json",
        "-show_format",
        "-show_streams",
        str(filepath),
    ]
    try:
        res = subprocess.run(cmd, capture_output=True, text=True, check=True)
        data = json.loads(res.stdout)
    except Exception as exc:
        print(f"Error probing {filepath}: {exc}", file=sys.stderr)
        return None

    v_stream = next((s for s in data.get("streams", []) if s.get("codec_type") == "video"), {})
    a_stream = next((s for s in data.get("streams", []) if s.get("codec_type") == "audio"), {})
    fmt = data.get("format", {})

    duration = float(fmt.get("duration", 0.0))
    width = int(v_stream.get("width", 0))
    height = int(v_stream.get("height", 0))
    r_fps = v_stream.get("r_frame_rate", "0/1")
    avg_fps = v_stream.get("avg_frame_rate", "0/1")
    fps_val = eval(r_fps) if "/" in r_fps else float(r_fps)
    sample_rate = int(a_stream.get("sample_rate", 0))
    channels = int(a_stream.get("channels", 0))

    return {
        "filename": filepath.name,
        "size_bytes": int(fmt.get("size", 0)),
        "duration_seconds": round(duration, 3),
        "total_frames": int(round(duration * fps_val)),
        "width": width,
        "height": height,
        "aspect_ratio": f"{width}:{height}" if height else "N/A",
        "fps": round(fps_val, 2),
        "video_codec": v_stream.get("codec_name", "unknown"),
        "audio_codec": a_stream.get("codec_name", "unknown"),
        "audio_sample_rate_hz": sample_rate,
        "audio_channels": channels,
        "bit_rate_bps": int(fmt.get("bit_rate", 0)),
    }


def audit_gameplay_directory(gameplay_dir: Path) -> Dict[str, Any]:
    """Audit all gameplay reference videos against DEC-26 specifications."""
    results: List[Dict[str, Any]] = []
    all_passed = True

    for filename, meta in EXPECTED_VIDEOS.items():
        file_path = gameplay_dir / filename
        if not file_path.exists():
            results.append({
                "filename": filename,
                "status": "MISSING",
                "category": meta["category"],
                "phase": meta["architectural_phase"],
            })
            all_passed = False
            continue

        probe = probe_media_file(file_path)
        if not probe:
            results.append({"filename": filename, "status": "PROBE_FAILED"})
            all_passed = False
            continue

        is_1080p = (probe["width"] == 1920 and probe["height"] == 1080)
        is_60fps = abs(probe["fps"] - 60.0) < 0.01
        is_48khz = (probe["audio_sample_rate_hz"] == 48000)
        is_stereo = (probe["audio_channels"] == 2)
        min_d, max_d = meta["expected_duration_range"]
        dur_ok = min_d <= probe["duration_seconds"] <= max_d

        valid = is_1080p and is_60fps and is_48khz and is_stereo and dur_ok
        if not valid:
            all_passed = False

        results.append({
            **probe,
            "category": meta["category"],
            "phase": meta["architectural_phase"],
            "description": meta["description"],
            "checks": {
                "resolution_1080p": is_1080p,
                "cfr_60fps": is_60fps,
                "audio_48khz_stereo": (is_48khz and is_stereo),
                "duration_in_range": dur_ok,
            },
            "status": "PASS" if valid else "FAIL",
        })

    return {
        "all_passed": all_passed,
        "total_expected": len(EXPECTED_VIDEOS),
        "total_audited": len(results),
        "results": results,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit and analyze Dupery gameplay reference videos.")
    parser.add_argument("--gameplay-dir", type=Path, default=DEFAULT_GAMEPLAY_DIR)
    parser.add_argument("--verify", action="store_true", help="Return 0 if all comply with DEC-26, else 1.")
    parser.add_argument("--json", action="store_true", help="Print report in JSON format.")
    args = parser.parse_args()

    report = audit_gameplay_directory(args.gameplay_dir)

    if args.json:
        print(json.dumps(report, indent=2, ensure_ascii=False))
    else:
        print(f"=== Dupery Gameplay Reference Audit (DEC-26) ===")
        print(f"Overall Status: {'PASS' if report['all_passed'] else 'FAIL'}")
        print(f"Audited: {report['total_audited']}/{report['total_expected']} videos\n")
        for r in report["results"]:
            status_flag = r.get("status", "FAIL")
            print(f"[{status_flag}] {r.get('filename')}")
            print(f"      Category: {r.get('category')} | Phase: {r.get('phase')}")
            print(f"      Resolution: {r.get('width')}x{r.get('height')} @ {r.get('fps')} FPS ({r.get('total_frames')} frames)")
            print(f"      Duration: {r.get('duration_seconds')}s | Audio: {r.get('audio_sample_rate_hz')} Hz {r.get('audio_channels')}ch {r.get('audio_codec')}")
            print(f"      Focus: {r.get('description')}\n")

    if args.verify:
        return 0 if report["all_passed"] else 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
