"""Verification tool for Dupery Master Architecture Encyclopedia (TASK-0031).

Audits MASTER_DUPERY_GODOT_MIGRATION_ENCYCLOPEDIA.md to ensure complete coverage
of the 5 architectural sections, Unity-to-Godot migration matrix rows,
empirical 60 FPS timing metrics, and V1-V8 subsystem implementation guides.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from typing import Any, Dict, List, Tuple

ROOT_DIR = Path(__file__).resolve().parents[2]
DEFAULT_ENCYCLOPEDIA = ROOT_DIR / "docs/agent-system/evidence/dupery/handbook/MASTER_DUPERY_GODOT_MIGRATION_ENCYCLOPEDIA.md"

REQUIRED_SECTIONS = [
    "PHẦN 1: BẢN VẼ KIẾN TRÚC CỐT LÕI & CÁC NGUYÊN TẮC THIẾT KẾ",
    "PHẦN 2: MA TRẬN DI TRÚ THÀNH PHẦN UNITY ➔ GODOT 4.6.2",
    "PHẦN 3: BẢNG CHỈ SỐ NHỊP ĐỘ THỰC NGHIỆM 60 FPS & ĐƯỜNG CONG TWEENING",
    "PHẦN 4: HƯỚNG DẪN HIỆN THỰC HÓA CHI TIẾT TỪNG PHÂN HỆ (V1 ĐẾN V8)",
    "PHẦN 5: BỘ TIÊU CHUẨN KIỂM TOÁN CHẤT LƯỢNG & SẴN SÀNG CHO PHASE 3",
]

REQUIRED_MIGRATION_COMPONENTS = [
    "UILineRenderer",
    "AudioServer",
    "ScriptableObject",
    "CanvasScaler",
    "TextMeshProUGUI",
    "DotNetRandom",
    "Catenary2D",
    "ContinuousWobble",
]

REQUIRED_VONG_SUBSECTIONS = [
    "V1 — Bảng Điều Tra, Ghim & Dây Nối Catenary",
    "V2 — Khởi Tạo Vụ Án, 20 Ràng Buộc & Cốt Truyện",
    "V3 — Vòng Lặp Điều Tra, Manh Mối & Hàng Nghi Phạm",
    "V4 — Chợ Đen, 59 Quirks & 11 Vật Phẩm Quạt Xòe",
    "V5 — 228 Vai Trò Nghi Phạm, 87 Năng Lực & Con Dấu",
    "V6 — Lưu Trữ JSON, Bản Địa Hóa & Âm Thanh FMOD",
    "V7 — Màn Hình Phụ, Bách Khoa Thư Codex & Chế Độ Chơi",
    "V8 — Trình Biên Tập Màn Chơi & Đánh Giá Tính Giải Được",
]

REQUIRED_TIMING_METRICS = [
    "Card Flip",
    "Pin Drop",
    "Item Fan Open",
    "Lineup Step",
    "Stamp Gavel",
    "Pie Chart Fill",
]


def audit_encyclopedia_document(doc_path: Path) -> Tuple[bool, List[str], Dict[str, Any]]:
    """Audit the Master Migration Encyclopedia against required architectural invariants."""
    errors: List[str] = []
    if not doc_path.exists():
        return False, [f"Encyclopedia document missing: {doc_path}"], {}

    text = doc_path.read_text(encoding="utf-8")
    lines_count = len(text.splitlines())

    if lines_count < 100:
        errors.append(f"Encyclopedia document too short: {lines_count} lines (expected > 100)")

    # 1. Verify 5 main sections
    for sec in REQUIRED_SECTIONS:
        if sec not in text:
            errors.append(f"Missing required section header: '{sec}'")

    # 2. Verify migration components
    for comp in REQUIRED_MIGRATION_COMPONENTS:
        if comp not in text:
            errors.append(f"Missing migration component mapping for: '{comp}'")

    # 3. Verify V1-V8 subsections
    for v_sub in REQUIRED_VONG_SUBSECTIONS:
        if v_sub not in text:
            errors.append(f"Missing subsystem implementation section for: '{v_sub}'")

    # 4. Verify empirical 60 FPS timing rows
    for metric in REQUIRED_TIMING_METRICS:
        if metric not in text:
            errors.append(f"Missing empirical timing entry for: '{metric}'")

    # 5. Metadata verification
    if "1.533 Classes" not in text and "1,533 Classes" not in text:
        errors.append("Missing 1,533 total classes scope declaration")

    passed = len(errors) == 0
    stats = {
        "lines_count": lines_count,
        "char_count": len(text),
        "sections_verified": len(REQUIRED_SECTIONS) - sum(1 for e in errors if "section header" in e),
        "components_verified": len(REQUIRED_MIGRATION_COMPONENTS) - sum(1 for e in errors if "migration component" in e),
        "vongs_verified": len(REQUIRED_VONG_SUBSECTIONS) - sum(1 for e in errors if "subsystem implementation" in e),
        "timing_metrics_verified": len(REQUIRED_TIMING_METRICS) - sum(1 for e in errors if "empirical timing" in e),
    }
    return passed, errors, stats


def main() -> int:
    parser = argparse.ArgumentParser(description="Verify Dupery Master Architecture Encyclopedia.")
    parser.add_argument("--doc", type=Path, default=DEFAULT_ENCYCLOPEDIA)
    parser.add_argument("--verify", action="store_true", help="Return 0 if valid, else 1.")
    args = parser.parse_args()

    passed, errors, stats = audit_encyclopedia_document(args.doc)

    print(f"=== Dupery Master Architecture Encyclopedia Audit ===")
    print(f"Document: {args.doc}")
    print(f"Status: {'PASS' if passed else 'FAIL'}")
    print(f"Lines: {stats.get('lines_count')} | Size: {stats.get('char_count')} chars")
    print(f"Sections Verified: {stats.get('sections_verified')}/{len(REQUIRED_SECTIONS)}")
    print(f"Migration Components: {stats.get('components_verified')}/{len(REQUIRED_MIGRATION_COMPONENTS)}")
    print(f"Subsystems Covered: {stats.get('vongs_verified')}/{len(REQUIRED_VONG_SUBSECTIONS)}")
    print(f"Timing Metrics: {stats.get('timing_metrics_verified')}/{len(REQUIRED_TIMING_METRICS)}")

    if not passed:
        print("\nErrors detected:", file=sys.stderr)
        for err in errors:
            print(f"  - {err}", file=sys.stderr)

    if args.verify:
        return 0 if passed else 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
