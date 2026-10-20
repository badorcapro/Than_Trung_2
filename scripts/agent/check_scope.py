"""
Git Scope Guard (scripts/agent/check_scope.py).
Compares working tree changes (git status --porcelain -uall) against TaskContract.in_scope
and TaskContract.out_of_scope. Computes a deterministic diff_sha256 fingerprint.
Supports Godot 4 engine bookkeeping exemptions (.godot/**, *.import) and .uid sidecars.
"""

from __future__ import annotations

import argparse
from fnmatch import fnmatchcase
import hashlib
import json
import subprocess
import sys
from pathlib import Path
from typing import List, Optional, Set, Tuple

from pydantic import ValidationError
import yaml

ROOT_DIR = Path(__file__).resolve().parents[2]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.models import (
    FixableBy,
    Issue,
    ResultEnvelope,
    Severity,
    TaskContract,
    compute_file_sha256,
)
from scripts.agent.validate_task import parse_task_markdown, resolve_task_path

BOOKKEEPING_EXEMPT_PATTERNS = [
    ".agent_scratchpad.md",
    "docs/agent-system/state/active-task.json",
    "docs/agent-system/evidence/TASK-*.json",
    ".godot/**",
    "**/.godot/**",
    "*.import",
    "**/*.import",
]


def matches_pattern(rel_path: str, pattern: str) -> bool:
    """Match a POSIX relative path against an exact path, glob, or directory prefix."""
    norm_path = rel_path.strip().replace("\\", "/")
    norm_pat = pattern.strip().replace("\\", "/")
    if norm_path == norm_pat:
        return True
    if norm_pat.startswith("**/"):
        suffix_pat = norm_pat[3:]
        if matches_pattern(norm_path, suffix_pat):
            return True
    if norm_pat.endswith("/**"):
        prefix = norm_pat[:-3].rstrip("/") + "/"
        if norm_path.startswith(prefix):
            return True
    if norm_pat.endswith("/"):
        if norm_path.startswith(norm_pat):
            return True
    return fnmatchcase(norm_path, norm_pat)


def matches_any(rel_path: str, patterns: List[str]) -> bool:
    """Return True if rel_path matches at least one pattern in patterns."""
    return any(matches_pattern(rel_path, pat) for pat in patterns)


def is_authorized_uid_sidecar(
    rel_path: str,
    in_scope: List[str],
    out_of_scope: List[str],
) -> bool:
    """Return True if rel_path is a Godot 4.4+ .uid sidecar whose base file is in_scope and not out_of_scope."""
    norm_path = rel_path.strip().replace("\\", "/")
    if not norm_path.endswith(".uid") or len(norm_path) <= 4:
        return False
    base_path = norm_path[:-4]
    if matches_any(base_path, out_of_scope):
        return False
    return matches_any(base_path, in_scope)


def is_forbidden_by_out_of_scope(rel_path: str, out_of_scope: List[str]) -> bool:
    """Return True if rel_path or its .uid base path is explicitly forbidden by out_of_scope."""
    norm_path = rel_path.strip().replace("\\", "/")
    if matches_any(norm_path, out_of_scope):
        return True
    if norm_path.endswith(".uid") and len(norm_path) > 4:
        return matches_any(norm_path[:-4], out_of_scope)
    return False


def get_git_changed_files(workspace_root: Path) -> Tuple[Optional[List[str]], Optional[str]]:
    """Run git status --porcelain -uall and return sorted relative POSIX paths."""
    try:
        proc = subprocess.run(
            ["git", "status", "--porcelain", "-uall"],
            cwd=str(workspace_root),
            capture_output=True,
            text=True,
            check=False,
            timeout=15,
        )
    except OSError as exc:
        return None, f"Failed to execute git: {exc}"

    if proc.returncode != 0:
        return None, proc.stderr.strip() or f"git status exited with code {proc.returncode}"

    changed: Set[str] = set()
    for line in proc.stdout.splitlines():
        if len(line) < 4:
            continue
        raw_entry = line[3:].strip()
        if " -> " in raw_entry:
            parts = raw_entry.split(" -> ", 1)
            for p in parts:
                changed.add(p.strip('"').replace("\\", "/"))
        else:
            changed.add(raw_entry.strip('"').replace("\\", "/"))
    return sorted(changed), None


def compute_working_diff_sha256(workspace_root: Path, files: List[str]) -> str:
    """Compute a deterministic SHA-256 fingerprint across all changed working tree files."""
    hasher = hashlib.sha256()
    for rel_path in sorted(files):
        full_path = workspace_root / rel_path
        if full_path.exists() and full_path.is_file():
            file_hash = compute_file_sha256(full_path)
            hasher.update(f"{rel_path}:{file_hash}\n".encode("utf-8"))
        else:
            hasher.update(f"{rel_path}:DELETED\n".encode("utf-8"))
    return hasher.hexdigest()


def check_scope(
    workspace_root: Path,
    task_arg: str,
    explicit_files: Optional[List[str]] = None,
) -> ResultEnvelope:
    """Check that all modified/untracked files conform to TaskContract.in_scope."""
    issues: List[Issue] = []
    task_path = resolve_task_path(workspace_root, task_arg)

    if not task_path.exists():
        issues.append(Issue(
            code="ERR_TASK_FILE_NOT_FOUND",
            severity=Severity.ERROR,
            message=f"Task contract '{task_arg}' not found.",
            location=task_arg,
            fixable_by=FixableBy.AI,
        ))
        return ResultEnvelope(success=False, tool="check_scope", issues=issues)

    rel_task_path = task_path.relative_to(workspace_root).as_posix()
    try:
        raw_fm, _ = parse_task_markdown(task_path)
        contract = TaskContract.model_validate(raw_fm)
    except (ValueError, yaml.YAMLError, ValidationError) as exc:
        issues.append(Issue(
            code="ERR_TASK_SCHEMA_INVALID",
            severity=Severity.ERROR,
            message=f"Invalid task contract: {exc}",
            location=rel_task_path,
            fixable_by=FixableBy.AI,
        ))
        return ResultEnvelope(success=False, tool="check_scope", issues=issues)

    if explicit_files is not None:
        changed_files = sorted(f.replace("\\", "/") for f in explicit_files)
    else:
        changed_files, git_err = get_git_changed_files(workspace_root)
        if changed_files is None:
            issues.append(Issue(
                code="ERR_GIT_UNAVAILABLE",
                severity=Severity.ERROR,
                message=f"Git status check failed: {git_err}",
                location=workspace_root.as_posix(),
                fixable_by=FixableBy.AI,
                suggested_action="Ensure git is initialized ('git init') in the workspace root.",
            ))
            return ResultEnvelope(success=False, tool="check_scope", issues=issues)

    exempt_patterns = BOOKKEEPING_EXEMPT_PATTERNS + [rel_task_path]
    evaluated_files: List[str] = []
    out_of_scope_files: List[str] = []

    for rel_file in changed_files:
        if matches_any(rel_file, exempt_patterns):
            continue

        if is_forbidden_by_out_of_scope(rel_file, contract.out_of_scope):
            out_of_scope_files.append(rel_file)
            issues.append(Issue(
                code="ERR_SCOPE_FORBIDDEN",
                severity=Severity.ERROR,
                message=f"Modified file '{rel_file}' is explicitly forbidden by out_of_scope.",
                location=rel_file,
                fixable_by=FixableBy.AI,
                suggested_action=f"Revert changes to '{rel_file}' ('git checkout -- {rel_file}').",
                evidence={"file": rel_file, "out_of_scope": contract.out_of_scope},
            ))
            continue

        evaluated_files.append(rel_file)
        in_declared_scope = matches_any(rel_file, contract.in_scope) or is_authorized_uid_sidecar(
            rel_file, contract.in_scope, contract.out_of_scope
        )
        if not in_declared_scope:
            out_of_scope_files.append(rel_file)
            issues.append(Issue(
                code="ERR_SCOPE_VIOLATION",
                severity=Severity.ERROR,
                message=f"Modified/untracked file '{rel_file}' is outside declared in_scope.",
                location=rel_file,
                fixable_by=FixableBy.AI,
                suggested_action=(
                    f"Revert '{rel_file}' or halt and ask user to approve expanding in_scope in {rel_task_path}."
                ),
                evidence={"file": rel_file, "in_scope": contract.in_scope},
            ))

    diff_sha256 = compute_working_diff_sha256(workspace_root, evaluated_files)
    has_err = any(i.severity == Severity.ERROR for i in issues)

    return ResultEnvelope(
        success=not has_err,
        tool="check_scope",
        issues=issues,
        data={
            "task_id": contract.id,
            "evaluated_files": evaluated_files,
            "out_of_scope_files": out_of_scope_files,
            "diff_sha256": diff_sha256,
        },
    )


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Verify git changes match TaskContract.in_scope.")
    parser.add_argument("--root", type=Path, default=ROOT_DIR, help="Workspace root directory")
    parser.add_argument("--task", required=True, help="Task ID (e.g. TASK-0001) or path to task markdown")
    parser.add_argument("--files", nargs="*", help="Optional explicit file list (for testing)")
    args = parser.parse_args(argv)

    res = check_scope(
        workspace_root=args.root.resolve(),
        task_arg=args.task,
        explicit_files=args.files,
    )
    print(json.dumps(res.model_dump(mode="json"), indent=2, ensure_ascii=False))
    return res.exit_code


if __name__ == "__main__":
    sys.exit(main())
