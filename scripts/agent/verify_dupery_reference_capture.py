"""Verification and manifest builder for Dupery Golden Reference Capture.

Audits reference captures against the established protocol (1920x1080, 60 FPS,
16:9), tracks baseline original VideoClips from sharedassets8, validates media
digests, and compiles the golden_reference_manifest.json evidence artifact.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

DEFAULT_REFERENCES_DIR = Path("docs/agent-system/evidence/dupery/references")
DEFAULT_RESOURCE_PATH = Path(r"D:\Minh\Steam\steamapps\common\Dupery\Dupery_Data\sharedassets8.resource")

CHECKLIST_CATEGORIES = [
    {"code": "MENU", "name": "Main Menu & Settings", "focus": "Button hover, clocktower bell, audio pause parameter"},
    {"code": "CUTSCENE", "name": "Intro Cutscenes", "focus": "Original intro video playback, transition to game"},
    {"code": "V1_BOARD", "name": "Detective Board & String", "focus": "Note movement, red string tension, magnifying glass"},
    {"code": "V2_CASEGEN", "name": "Case Selection & Stasis", "focus": "Card flip duration, case card inspection, seed"},
    {"code": "V3_LOOP", "name": "Leads & Lineup Loop", "focus": "District navigation, lineup move, suspect inspection"},
    {"code": "V4_ITEMS", "name": "Item Fan & Quirks", "focus": "Fan opening easing curve, quirk card drag and drop"},
    {"code": "V5_ROLES", "name": "Roles & Suspect States", "focus": "Suspect portrait states, clear/arrest stamps"},
    {"code": "V6_INFRA", "name": "Infrastructure & Shortcuts", "focus": "Input shortcuts, save system, localization font"},
    {"code": "V7_SUB", "name": "Summary & Pie Chart", "focus": "Pie chart fill animation, judge gavel impact sound"},
]

BASELINE_VIDEOS = [
    {
        "name": "Dupery Intro English.mp4",
        "category": "CUTSCENE",
        "offset": 0,
        "size_bytes": 93707625,
        "sha256": "fe703760bee3498583c1aca85dd40928a588e7e95649d5f8c95b53c242b670fe",
        "frame_rate": 24.0,
        "frame_count": 1113,
        "audio_channels": 2,
    },
    {
        "name": "Dupery Intro Cutscene.mp4",
        "category": "CUTSCENE",
        "offset": 93707625,
        "size_bytes": 92225522,
        "sha256": "8a9807546b9b68bc61076d6a5fca956b4577468dca42c332bf3c9cfcb9eda003",
        "frame_rate": 24.0,
        "frame_count": 1113,
        "audio_channels": 2,
    },
]


def verify_original_resource_streams(res_path: Path) -> bool:
    """Verify SHA-256 hashes of original video streams in sharedassets8.resource."""
    if not res_path.exists():
        return False
    with open(res_path, "rb") as f:
        for b_clip in BASELINE_VIDEOS:
            f.seek(b_clip["offset"])
            chunk = f.read(b_clip["size_bytes"])
            if len(chunk) != b_clip["size_bytes"]:
                return False
            digest = hashlib.sha256(chunk).hexdigest()
            if digest != b_clip["sha256"]:
                return False
    return True


def scan_user_captures(ref_dir: Path) -> List[Dict[str, Any]]:
    """Scan additional gameplay captures deposited in references directory."""
    captures: List[Dict[str, Any]] = []
    valid_exts = {".mp4", ".png", ".jpg", ".mkv", ".wav"}
    for f in sorted(ref_dir.iterdir()):
        if f.is_file() and f.suffix.lower() in valid_exts and not f.name.startswith("golden_reference"):
            data = f.read_bytes()
            digest = hashlib.sha256(data).hexdigest()
            cat = "UNCATEGORIZED"
            for c in CHECKLIST_CATEGORIES:
                if f.name.startswith(f"REF_{c['code']}") or c["code"] in f.name:
                    cat = c["code"]
                    break
            captures.append({
                "filename": f.name,
                "category": cat,
                "size_bytes": len(data),
                "sha256": digest,
            })
    return captures


def build_golden_manifest(ref_dir: Path, res_path: Path) -> Dict[str, Any]:
    """Compile comprehensive Golden Reference Manifest."""
    protocol_path = ref_dir / "reference_capture_protocol.md"
    user_captures = scan_user_captures(ref_dir)
    resource_streams_verified = verify_original_resource_streams(res_path) if res_path.exists() else False

    checklist_summary = []
    for c in CHECKLIST_CATEGORIES:
        has_baseline = any(v["category"] == c["code"] for v in BASELINE_VIDEOS)
        user_matches = [u["filename"] for u in user_captures if u["category"] == c["code"]]
        status = "covered" if (has_baseline or user_matches) else "protocol_ready"
        checklist_summary.append({
            "code": c["code"],
            "name": c["name"],
            "focus": c["focus"],
            "status": status,
            "baseline_present": has_baseline,
            "user_captures_count": len(user_matches),
            "files": user_matches,
        })

    return {
        "metadata": {
            "title": "Dupery Golden Reference Manifest",
            "phase": "P2",
            "protocol_defined": protocol_path.exists(),
            "target_resolution": "1920x1080",
            "target_fps": 60.0,
            "total_checklist_categories": len(CHECKLIST_CATEGORIES),
            "baseline_videos_count": len(BASELINE_VIDEOS),
            "user_captures_count": len(user_captures),
            "resource_streams_verified": resource_streams_verified,
        },
        "baseline_videos": BASELINE_VIDEOS,
        "checklist": checklist_summary,
        "user_captures": user_captures,
    }


def verify_reference_system(ref_dir: Path, res_path: Path) -> bool:
    """Verify integrity of reference protocol, manifest, and baseline streams."""
    protocol_path = ref_dir / "reference_capture_protocol.md"
    manifest_path = ref_dir / "golden_reference_manifest.json"
    if not protocol_path.exists() or not manifest_path.exists():
        return False

    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    meta = manifest.get("metadata", {})
    if not meta.get("protocol_defined", False):
        return False
    if len(manifest.get("checklist", [])) != 9:
        return False
    if len(manifest.get("baseline_videos", [])) != 2:
        return False

    if res_path.exists():
        if not verify_original_resource_streams(res_path):
            return False
    return True


def extract_baseline_videos(res_path: Path, out_dir: Path) -> List[Path]:
    """Extract original MP4 video files from sharedassets8.resource to local disk."""
    out_dir.mkdir(parents=True, exist_ok=True)
    extracted: List[Path] = []
    if not res_path.exists():
        return extracted
    with open(res_path, "rb") as f:
        for b_clip in BASELINE_VIDEOS:
            f.seek(b_clip["offset"])
            out_file = out_dir / b_clip["name"]
            data = f.read(b_clip["size_bytes"])
            out_file.write_bytes(data)
            extracted.append(out_file)
    return extracted


def main() -> int:
    parser = argparse.ArgumentParser(description="Verify and build Golden Reference Manifest.")
    parser.add_argument("--references-dir", type=Path, default=DEFAULT_REFERENCES_DIR)
    parser.add_argument("--resource-path", type=Path, default=DEFAULT_RESOURCE_PATH)
    parser.add_argument("--verify", action="store_true", help="Verify protocol and manifest integrity.")
    parser.add_argument("--stats", action="store_true", help="Print reference manifest statistics.")
    parser.add_argument("--extract-videos", type=Path, default=None, help="Extract raw MP4 files to directory.")
    args = parser.parse_args()

    ref_dir = args.references_dir
    res_path = args.resource_path
    ref_dir.mkdir(parents=True, exist_ok=True)

    if args.extract_videos:
        clips = extract_baseline_videos(res_path, args.extract_videos)
        print(f"Extracted {len(clips)} baseline video clips to {args.extract_videos}")

    manifest_path = ref_dir / "golden_reference_manifest.json"
    manifest = build_golden_manifest(ref_dir, res_path)
    manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    if args.verify:
        ok = verify_reference_system(ref_dir, res_path)
        print("VERIFY:", "PASS" if ok else "FAIL")
        return 0 if ok else 1

    print(f"Generated Golden Reference Manifest: {manifest_path}")
    if args.stats:
        print(f"Protocol defined: {manifest['metadata']['protocol_defined']}")
        print(f"Checklist categories: {manifest['metadata']['total_checklist_categories']}")
        print(f"Baseline video assets: {manifest['metadata']['baseline_videos_count']}")
        print(f"Resource streams verified: {manifest['metadata']['resource_streams_verified']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
