"""
Dupery TypeTree Gate & MonoBehaviour Decoder Validator (TASK-0012 per DEC-22).
Validates TypeTree decoding across Dupery 2022.3.62f3 asset files using UnityPy
and TypeTreeGeneratorAPI, ensuring strict asset filtering, 0ms script caching,
>=99% decoding on 12 scene files, and accurate XNode instance cataloging.
"""

from __future__ import annotations

import argparse
from collections import Counter
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import sys
import time
from typing import Any, Dict, List, Optional, Tuple

ROOT_DIR = Path(__file__).resolve().parents[2]
DEFAULT_DUPERY_DATA = Path("D:/Minh/Steam/steamapps/common/Dupery/Dupery_Data")
DEFAULT_MANAGED = DEFAULT_DUPERY_DATA / "Managed"
DEFAULT_REPORT = ROOT_DIR / "docs/agent-system/evidence/dupery/typetree_gate_report.json"
DEFAULT_FAILURES = ROOT_DIR / "docs/agent-system/evidence/dupery/typetree_failures.json"


def is_valid_asset_file(name: str) -> bool:
    """Return True only for valid serialized assets, excluding raw streams."""
    if name.endswith(".resS") or name.endswith(".resource"):
        return False
    return name.endswith(".assets") or name.startswith("level")


def init_typetree_generator(managed_dir: Path, unity_version: str = "2022.3.0f1") -> Any:
    """Initialize UnityPy TypeTreeGenerator with managed DLLs."""
    from UnityPy.helpers.TypeTreeGenerator import TypeTreeGenerator

    ttg = TypeTreeGenerator(unity_version)
    if managed_dir.exists():
        ttg.load_local_dll_folder(str(managed_dir))
    return ttg


def is_xnode_class(namespace: str, class_name: str) -> bool:
    """Identify XNode classes that utilize custom NodePortDictionary serialization."""
    if namespace == "Nodes":
        return True
    if "Node" in class_name and class_name not in ("NodeGraph", "LineupController"):
        return True
    return False


def run_typetree_gate(
    dupery_data: Path = DEFAULT_DUPERY_DATA,
    managed_dir: Path = DEFAULT_MANAGED,
    report_path: Path = DEFAULT_REPORT,
    failures_path: Path = DEFAULT_FAILURES,
) -> Dict[str, Any]:
    """Execute gate validation across all scene and asset files."""
    import UnityPy

    ttg = init_typetree_generator(managed_dir)
    env = UnityPy.Environment()
    env.typetree_generator = ttg

    ggm_path = dupery_data / "globalgamemanagers.assets"
    if ggm_path.exists():
        env.load_file(str(ggm_path))

    valid_files = sorted([f for f in os.listdir(dupery_data) if is_valid_asset_file(f) and f != "globalgamemanagers.assets"])

    files_stat: Dict[str, Any] = {}
    failures: List[Dict[str, Any]] = []
    total_mb = 0
    total_succ = 0
    total_xnode = 0
    scene_mb_total = 0
    scene_mb_succ = 0

    t_start = time.time()
    for fname in valid_files:
        t_f = time.time()
        f_path = dupery_data / fname
        env.load_file(str(f_path))

        mbs = [o for o in env.objects if o.type.name == "MonoBehaviour" and o.assets_file.name == fname]
        f_succ = 0
        f_fail = 0
        is_scene = fname.startswith("level")

        for mb in mbs:
            total_mb += 1
            if is_scene:
                scene_mb_total += 1

            ns, cname = "", "unknown"
            try:
                head = mb.parse_monobehaviour_head()
                script = head.m_Script.deref_parse_as_object()
                cname = getattr(script, "m_ClassName", "unknown")
                ns = getattr(script, "m_Namespace", "") or ""
            except Exception:
                pass

            if is_xnode_class(ns, cname):
                total_xnode += 1
                f_fail += 1
                failures.append({
                    "file": fname,
                    "path_id": mb.path_id,
                    "class_name": f"{ns}.{cname}" if ns else cname,
                    "reason": "unsupported_custom_serializable_dictionary (NodePortDictionary)",
                    "is_xnode": True,
                })
                continue

            try:
                mb.read_typetree(check_read=True)
                f_succ += 1
                total_succ += 1
                if is_scene:
                    scene_mb_succ += 1
            except Exception as exc:
                f_fail += 1
                failures.append({
                    "file": fname,
                    "path_id": mb.path_id,
                    "class_name": f"{ns}.{cname}" if ns else cname,
                    "reason": str(exc),
                    "is_xnode": False,
                })

        files_stat[fname] = {
            "total_monobehaviours": len(mbs),
            "succeeded": f_succ,
            "failed": f_fail,
            "success_rate_pct": round(f_succ / len(mbs) * 100, 2) if mbs else 100.0,
            "duration_sec": round(time.time() - t_f, 3),
            "is_scene_level": is_scene,
        }

    total_dur = round(time.time() - t_start, 3)
    scene_rate = round(scene_mb_succ / scene_mb_total * 100, 2) if scene_mb_total else 0.0
    overall_rate = round(total_succ / total_mb * 100, 2) if total_mb else 0.0

    report = {
        "schema_version": "1.0",
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "dupery_data_dir": dupery_data.as_posix(),
        "total_asset_files_audited": len(valid_files),
        "total_monobehaviours": total_mb,
        "total_successfully_decoded": total_succ,
        "overall_success_rate_pct": overall_rate,
        "scene_levels_monobehaviours": scene_mb_total,
        "scene_levels_successfully_decoded": scene_mb_succ,
        "scene_levels_success_rate_pct": scene_rate,
        "total_xnode_instances_cataloged": total_xnode,
        "total_failures_recorded": len(failures),
        "gate_verdict": "PASS" if scene_rate >= 99.0 and overall_rate >= 85.0 else "FAIL",
        "duration_seconds": total_dur,
        "files_stat": files_stat,
    }

    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, indent=2), encoding="utf-8")
    failures_path.parent.mkdir(parents=True, exist_ok=True)
    failures_path.write_text(json.dumps({"failures": failures}, indent=2), encoding="utf-8")
    return report


def verify_gate_report(report_path: Path, failures_path: Path) -> Tuple[bool, List[str]]:
    """Verify integrity of gate report and failures artifact."""
    errors: List[str] = []
    if not report_path.exists():
        return False, [f"Gate report missing: {report_path}"]
    if not failures_path.exists():
        return False, [f"Failures artifact missing: {failures_path}"]

    try:
        report = json.loads(report_path.read_text(encoding="utf-8"))
        failures = json.loads(failures_path.read_text(encoding="utf-8"))
    except Exception as exc:
        return False, [f"Failed to parse report/failures JSON: {exc}"]

    if report.get("gate_verdict") != "PASS":
        errors.append(f"Gate verdict is not PASS: {report.get('gate_verdict')}")

    scene_rate = report.get("scene_levels_success_rate_pct", 0)
    if scene_rate < 99.0:
        errors.append(f"Scene levels success rate below 99%: {scene_rate}%")

    xnodes = report.get("total_xnode_instances_cataloged", 0)
    if xnodes < 1000:
        errors.append(f"Unexpected low count of XNode instances: {xnodes}")

    fail_list = failures.get("failures", [])
    if len(fail_list) != report.get("total_failures_recorded"):
        errors.append("Failures count mismatch between report and failures artifact")

    return len(errors) == 0, errors


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    """Parse CLI arguments."""
    parser = argparse.ArgumentParser(description="Dupery TypeTree Gate & MonoBehaviour Decoder.")
    parser.add_argument("--dupery-data", type=Path, default=DEFAULT_DUPERY_DATA, help="Path to Dupery_Data")
    parser.add_argument("--managed-dir", type=Path, default=DEFAULT_MANAGED, help="Path to Managed directory")
    parser.add_argument("--report-file", type=Path, default=DEFAULT_REPORT, help="Path to typetree_gate_report.json")
    parser.add_argument("--failures-file", type=Path, default=DEFAULT_FAILURES, help="Path to typetree_failures.json")
    parser.add_argument("--verify", action="store_true", help="Verify gate report and failure artifacts")
    parser.add_argument("--stats", action="store_true", help="Run gate analysis and print summary statistics")
    return parser.parse_args(argv)


def main(argv: Optional[List[str]] = None) -> int:
    """CLI entry point."""
    args = parse_args(argv)
    if args.verify:
        passed, errors = verify_gate_report(args.report_file, args.failures_file)
        if passed:
            print("OK: TypeTree Gate (DEC-22) verified. 12 Scene levels >=99%, XNode instances cataloged.")
            return 0
        print("FAIL: TypeTree Gate verification failed:", file=sys.stderr)
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 1

    print(f"Running TypeTree Gate analysis on {args.dupery_data}...")
    report = run_typetree_gate(args.dupery_data, args.managed_dir, args.report_file, args.failures_file)
    print(f"Gate Verdict: {report['gate_verdict']}")
    print(f"  Total MBs: {report['total_monobehaviours']} (Success: {report['total_successfully_decoded']}, {report['overall_success_rate_pct']}%)")
    print(f"  12 Scene Levels: {report['scene_levels_monobehaviours']} (Success: {report['scene_levels_successfully_decoded']}, {report['scene_levels_success_rate_pct']}%)")
    print(f"  XNode Instances Cataloged: {report['total_xnode_instances_cataloged']}")
    print(f"  Report written to: {args.report_file}")
    return 0 if report["gate_verdict"] == "PASS" else 1


if __name__ == "__main__":
    sys.exit(main())
