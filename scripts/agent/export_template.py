"""
Reusable starter template packager and distribution export CLI (scripts/agent/export_template.py).
Exports a clean-slate, turn-key distribution bundle of AI-AGENTS-Template without dogfooding artifacts.
Governed by ADR-ARCH-012.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import shutil
import sys
from typing import Any, Dict, List, Optional, Set
import zipfile

from scripts.agent.models import FixableBy, Issue, ResultEnvelope, Severity

CORE_FILES = [
    "AGENTS.md",
    "ARCHITECTURE.md",
    "README.md",
    "requirements.txt",
]

CORE_DIRECTORIES = [
    ".agents/rules",
    ".agents/skills",
    "profiles",
    "scripts/agent",
    "docs/agent-system/decisions",
]

EMPTY_STARTER_DIRECTORIES = [
    "docs/agent-system/tasks",
    "docs/agent-system/state",
    "docs/agent-system/evidence",
]

EXCLUDED_GLOBS = [
    "__pycache__",
    "*.pyc",
    "*.pyo",
    ".pytest_cache",
    ".coverage",
    ".DS_Store",
    "Thumbs.db",
]


def _compute_sha256(path: Path) -> str:
    """Compute SHA-256 hash of a file."""
    h = hashlib.sha256()
    with path.open("rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()


def _is_excluded(path: Path) -> bool:
    """Check if file or directory name matches any excluded glob."""
    for part in path.parts:
        for pattern in EXCLUDED_GLOBS:
            if pattern.startswith("*") and part.endswith(pattern[1:]):
                return True
            if part == pattern:
                return True
    return False


def synthesize_clean_registry(
    source_root: Path,
    target_root: Path,
) -> Dict[str, Any]:
    """Generate a pristine reference-registry.json for the exported workspace."""
    source_reg_path = source_root / "docs/agent-system/reference-registry.json"
    if not source_reg_path.exists():
        raise FileNotFoundError(f"Source registry not found: {source_reg_path}")

    raw_data = json.loads(source_reg_path.read_text(encoding="utf-8"))
    entries: List[Dict[str, Any]] = raw_data.get("entries", [])

    valid_entries: List[Dict[str, Any]] = []
    retained_ids: Set[str] = set()

    # Pass 1: Filter out dogfooding artifacts and check file presence in target_root
    for entry in entries:
        path_str = entry.get("path", "")
        kind = entry.get("kind", "")
        entry_id = entry.get("id", "")

        # Exclude pilot slices
        if path_str.startswith("pilot/") or kind == "pilot" or "PILOT" in entry_id:
            continue
        # Exclude internal dev test suite
        if path_str.startswith("tests/") or kind == "test":
            continue
        # Exclude internal dogfooding tasks
        if path_str.startswith("docs/agent-system/tasks/") or kind == "task":
            continue

        target_file = target_root / path_str
        if target_file.exists():
            valid_entries.append(dict(entry))
            retained_ids.add(entry_id)

    # Pass 2: Clean up depends_on to only include retained IDs, and recompute sha256
    final_entries: List[Dict[str, Any]] = []
    for entry in valid_entries:
        entry_path = target_root / entry["path"]
        entry["sha256"] = _compute_sha256(entry_path)
        # Retain only dependencies that exist in the exported bundle
        entry["depends_on"] = [
            dep for dep in entry.get("depends_on", [])
            if dep in retained_ids
        ]
        final_entries.append(entry)

    return {
        "schema_version": raw_data.get("schema_version", "1.0"),
        "project": "AI-AGENTS-Starter",
        "entries": final_entries,
    }


def export_template(
    source_root: Path,
    target_dir: Path,
    zip_path: Optional[Path] = None,
    force: bool = False,
) -> ResultEnvelope:
    """Export a clean distribution bundle of the template to target_dir or zip_path."""
    issues: List[Issue] = []

    if target_dir.exists() and any(target_dir.iterdir()):
        if not force:
            issues.append(Issue(
                code="ERR_EXP_TARGET_NOT_EMPTY",
                severity=Severity.ERROR,
                message=f"Target directory '{target_dir}' exists and is not empty. Use --force to overwrite.",
                location=str(target_dir),
                fixable_by=FixableBy.HUMAN,
                suggested_action="Specify an empty or non-existent target directory, or pass --force.",
            ))
            return ResultEnvelope(success=False, tool="export_template", issues=issues)
        shutil.rmtree(target_dir)

    target_dir.mkdir(parents=True, exist_ok=True)
    files_copied = 0

    # 1. Copy core root files
    for filename in CORE_FILES:
        src = source_root / filename
        if src.exists():
            dst = target_dir / filename
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
            files_copied += 1

    # 2. Copy core directories
    for dir_rel in CORE_DIRECTORIES:
        src_dir = source_root / dir_rel
        if src_dir.exists():
            dst_dir = target_dir / dir_rel
            dst_dir.mkdir(parents=True, exist_ok=True)
            for item in src_dir.rglob("*"):
                if item.is_file() and not _is_excluded(item):
                    rel = item.relative_to(src_dir)
                    target_item = dst_dir / rel
                    target_item.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(item, target_item)
                    files_copied += 1

    # 3. Copy starter project config if present
    src_cfg = source_root / "docs/agent-system/project-config.json"
    if src_cfg.exists():
        dst_cfg = target_dir / "docs/agent-system/project-config.json"
        dst_cfg.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src_cfg, dst_cfg)
        files_copied += 1

    # 4. Create empty starter directories with .gitkeep
    for empty_rel in EMPTY_STARTER_DIRECTORIES:
        empty_path = target_dir / empty_rel
        empty_path.mkdir(parents=True, exist_ok=True)
        (empty_path / ".gitkeep").write_text("", encoding="utf-8")
        files_copied += 1

    # 5. Synthesize clean reference-registry.json
    try:
        clean_reg = synthesize_clean_registry(source_root, target_dir)
        reg_out = target_dir / "docs/agent-system/reference-registry.json"
        reg_out.write_text(
            json.dumps(clean_reg, indent=2, ensure_ascii=False) + "\n",
            encoding="utf-8",
        )
        files_copied += 1
    except Exception as exc:
        issues.append(Issue(
            code="ERR_EXP_REGISTRY_SYNTHESIS_FAILED",
            severity=Severity.ERROR,
            message=f"Failed to synthesize clean reference-registry.json: {exc}",
            location="docs/agent-system/reference-registry.json",
            fixable_by=FixableBy.AI,
        ))
        return ResultEnvelope(success=False, tool="export_template", issues=issues)

    # 6. If zip_path requested, create zip archive
    if zip_path is not None:
        if zip_path.exists() and not force:
            issues.append(Issue(
                code="ERR_EXP_ZIP_EXISTS",
                severity=Severity.ERROR,
                message=f"Zip archive '{zip_path}' already exists. Use --force to overwrite.",
                location=str(zip_path),
                fixable_by=FixableBy.HUMAN,
            ))
            return ResultEnvelope(success=False, tool="export_template", issues=issues)
        zip_path.parent.mkdir(parents=True, exist_ok=True)
        with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
            for file_path in target_dir.rglob("*"):
                if file_path.is_file():
                    arcname = file_path.relative_to(target_dir)
                    zf.write(file_path, arcname)

    return ResultEnvelope(
        success=True,
        tool="export_template",
        issues=issues,
        data={
            "target_dir": str(target_dir),
            "zip_path": str(zip_path) if zip_path else None,
            "files_copied": files_copied,
            "registry_entries": len(clean_reg["entries"]),
        },
    )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Export a pristine starter distribution of AI-AGENTS-Template."
    )
    parser.add_argument("--root", type=str, default=".", help="Source template workspace root")
    parser.add_argument("--output", type=str, required=True, help="Target destination directory")
    parser.add_argument("--zip", type=str, help="Optional destination .zip archive path")
    parser.add_argument("--force", action="store_true", help="Force overwrite existing output")
    parser.add_argument("--json", action="store_true", help="Output machine-readable ResultEnvelope JSON")

    args = parser.parse_args()
    source_root = Path(args.root).resolve()
    target_dir = Path(args.output).resolve()
    zip_path = Path(args.zip).resolve() if args.zip else None

    res = export_template(
        source_root=source_root,
        target_dir=target_dir,
        zip_path=zip_path,
        force=args.force,
    )

    if args.json:
        print(json.dumps(res.model_dump(mode="json"), indent=2, ensure_ascii=False))
    elif res.success:
        print(f"[SUCCESS] Exported template to {target_dir} ({res.data.get('files_copied')} files, {res.data.get('registry_entries')} clean registry entries).")
        if zip_path:
            print(f"[SUCCESS] Created zip archive: {zip_path}")
    else:
        for issue in res.issues:
            print(f"[{issue.severity.value.upper()}] {issue.code}: {issue.message}", file=sys.stderr)

    sys.exit(0 if res.success else 2)


if __name__ == "__main__":
    main()
