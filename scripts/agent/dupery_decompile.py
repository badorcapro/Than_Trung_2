"""
Decompiler and Manifest Generator for Dupery Managed Assemblies.
Decompiles CIL assemblies using ilspycmd into structured C# source trees
and records SHA-256 hashes, file counts, and durations in decompile_manifest.json.
Supports --verify mode for deterministic verification without re-decompilation.
"""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time
from typing import Any, Dict, List, Optional, Tuple

ROOT_DIR = Path(__file__).resolve().parents[2]
DEFAULT_MANAGED_DIR = Path("D:/Minh/Steam/steamapps/common/Dupery/Dupery_Data/Managed")
DEFAULT_OUT_DIR = ROOT_DIR / "docs/agent-system/evidence/dupery/generated/decompiled_cs"
DEFAULT_MANIFEST = ROOT_DIR / "docs/agent-system/evidence/dupery/decompile_manifest.json"

TARGET_ASSEMBLIES = [
    "Assembly-CSharp.dll",
    "gildedrunegames.grglib.dll",
    "gildedrunegames.grglocalisation.dll",
    "XNode.dll",
    "FMODUnity.dll",
]

KEY_NAMESPACES = {
    "Assembly-CSharp": ["Visual", "Quirks", "Save", "Nodes", "Leads", "CaseCreation"],
    "gildedrunegames.grglib": ["GRGLib"],
    "XNode": ["XNode"],
    "gildedrunegames.grglocalisation": ["GRGLocalisation"],
    "FMODUnity": ["FMODUnity"],
}


def compute_file_sha256(path: Path) -> str:
    """Compute standard SHA-256 hex digest for a file."""
    hasher = hashlib.sha256()
    with path.open("rb") as f:
        while chunk := f.read(65536):
            hasher.update(chunk)
    return hasher.hexdigest()


def get_ilspycmd_version() -> str:
    """Return version string of ilspycmd CLI tool."""
    try:
        proc = subprocess.run(
            ["ilspycmd", "--version"],
            capture_output=True,
            text=True,
            check=False,
            timeout=10,
        )
        if proc.returncode == 0 and proc.stdout.strip():
            return proc.stdout.strip().splitlines()[0]
    except OSError:
        pass
    return "unknown"


def decompile_single_assembly(
    dll_path: Path,
    managed_dir: Path,
    out_dir: Path,
) -> Tuple[bool, int, int, str]:
    """Decompile one assembly using ilspycmd into out_dir."""
    out_dir.mkdir(parents=True, exist_ok=True)
    cmd = [
        "ilspycmd",
        "-p",
        "--nested-directories",
        "--disable-updatecheck",
        "-r",
        str(managed_dir),
        "-o",
        str(out_dir),
        str(dll_path),
    ]
    start = time.perf_counter()
    proc = subprocess.run(cmd, capture_output=True, text=True, check=False)
    elapsed_ms = int((time.perf_counter() - start) * 1000)

    if proc.returncode != 0:
        err = proc.stderr.strip() or f"exited with code {proc.returncode}"
        return False, 0, elapsed_ms, err

    cs_files = list(out_dir.rglob("*.cs"))
    total_bytes = sum(f.stat().st_size for f in cs_files)
    return True, total_bytes, elapsed_ms, ""


def run_decompile_pipeline(
    managed_dir: Path,
    out_root: Path,
    manifest_path: Path,
    assemblies: Optional[List[str]] = None,
) -> Dict[str, Any]:
    """Execute decompilation for all target assemblies and generate manifest."""
    targets = assemblies or TARGET_ASSEMBLIES
    out_root.mkdir(parents=True, exist_ok=True)
    manifest_path.parent.mkdir(parents=True, exist_ok=True)

    ilspy_ver = get_ilspycmd_version()
    results: Dict[str, Any] = {}
    total_files = 0
    total_bytes = 0
    total_duration = 0

    for dll_name in targets:
        dll_path = managed_dir / dll_name
        stem = dll_path.stem
        sub_out = out_root / stem

        if not dll_path.exists():
            results[stem] = {
                "dll_name": dll_name,
                "status": "missing_dll",
                "error": f"File not found: {dll_path}",
            }
            continue

        dll_sha = compute_file_sha256(dll_path)
        dll_size = dll_path.stat().st_size

        success, cs_bytes, dur_ms, err_msg = decompile_single_assembly(
            dll_path, managed_dir, sub_out
        )

        cs_files = list(sub_out.rglob("*.cs")) if success else []
        file_count = len(cs_files)

        results[stem] = {
            "dll_name": dll_name,
            "dll_size_bytes": dll_size,
            "dll_sha256": dll_sha,
            "output_dir": sub_out.relative_to(ROOT_DIR).as_posix(),
            "cs_file_count": file_count,
            "total_cs_bytes": cs_bytes,
            "duration_ms": dur_ms,
            "status": "success" if success else "failed",
            "error": err_msg if not success else None,
        }

        total_files += file_count
        total_bytes += cs_bytes
        total_duration += dur_ms

    manifest_data = {
        "schema_version": "1.0",
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "ilspycmd_version": ilspy_ver,
        "managed_dir": managed_dir.as_posix(),
        "assemblies": results,
        "summary": {
            "total_assemblies": len(targets),
            "successful_assemblies": sum(1 for r in results.values() if r.get("status") == "success"),
            "total_cs_files": total_files,
            "total_cs_bytes": total_bytes,
            "total_duration_ms": total_duration,
        },
    }

    manifest_path.write_text(json.dumps(manifest_data, indent=2), encoding="utf-8")
    return manifest_data


def verify_decompilation(
    manifest_path: Path,
    managed_dir: Path,
) -> Tuple[bool, List[str]]:
    """Verify integrity of decompiled source trees against manifest and filesystem."""
    errors: List[str] = []
    if not manifest_path.exists():
        return False, [f"Manifest not found: {manifest_path}"]

    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError) as exc:
        return False, [f"Manifest invalid JSON: {exc}"]

    assemblies = manifest.get("assemblies", {})
    if not assemblies:
        return False, ["Manifest contains no assemblies data"]

    for stem, info in assemblies.items():
        if info.get("status") != "success":
            errors.append(f"Assembly '{stem}' marked as {info.get('status')}: {info.get('error')}")
            continue

        rel_out = info.get("output_dir", "")
        out_dir = ROOT_DIR / rel_out
        if not out_dir.exists():
            errors.append(f"Output directory does not exist: {out_dir}")
            continue

        actual_cs = list(out_dir.rglob("*.cs"))
        expected_count = info.get("cs_file_count", 0)
        if len(actual_cs) != expected_count:
            errors.append(
                f"Assembly '{stem}' file count mismatch: actual {len(actual_cs)} != expected {expected_count}"
            )

        # Check key namespaces presence
        expected_ns = KEY_NAMESPACES.get(stem, [])
        for ns in expected_ns:
            ns_dir = out_dir / ns
            if not ns_dir.exists():
                errors.append(f"Key namespace directory missing for '{stem}': {ns_dir}")

        # Check source DLL sha256
        dll_name = info.get("dll_name", "")
        dll_path = managed_dir / dll_name
        if dll_path.exists():
            actual_sha = compute_file_sha256(dll_path)
            expected_sha = info.get("dll_sha256", "")
            if actual_sha != expected_sha:
                errors.append(f"DLL '{dll_name}' SHA-256 changed: {actual_sha} != {expected_sha}")

    return len(errors) == 0, errors


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    """Parse CLI arguments."""
    parser = argparse.ArgumentParser(description="Dupery assembly decompiler and manifest manager.")
    parser.add_argument("--managed-dir", type=Path, default=DEFAULT_MANAGED_DIR, help="Path to Managed/ dir")
    parser.add_argument("--out-dir", type=Path, default=DEFAULT_OUT_DIR, help="Path to output root")
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST, help="Path to decompile_manifest.json")
    parser.add_argument("--verify", action="store_true", help="Verify decompiled source integrity against manifest")
    parser.add_argument("--assemblies", nargs="+", help="Specific assemblies to decompile")
    return parser.parse_args(argv)


def main(argv: Optional[List[str]] = None) -> int:
    """CLI Entry point."""
    args = parse_args(argv)
    if args.verify:
        passed, errors = verify_decompilation(args.manifest, args.managed_dir)
        if passed:
            print("OK: Decompilation verification passed 100%. All assemblies and source trees valid.")
            return 0
        print("FAIL: Decompilation verification failed:", file=sys.stderr)
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 1

    print(f"Starting decompilation of {len(args.assemblies or TARGET_ASSEMBLIES)} assemblies...")
    data = run_decompile_pipeline(args.managed_dir, args.out_dir, args.manifest, args.assemblies)
    summary = data.get("summary", {})
    print(f"Decompilation finished in {summary.get('total_duration_ms', 0)} ms:")
    print(f"  Assemblies: {summary.get('successful_assemblies', 0)}/{summary.get('total_assemblies', 0)}")
    print(f"  Total .cs files: {summary.get('total_cs_files', 0)}")
    print(f"  Total code bytes: {summary.get('total_cs_bytes', 0)} ({summary.get('total_cs_bytes', 0) // 1024} KB)")
    print(f"  Manifest written to: {args.manifest}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
