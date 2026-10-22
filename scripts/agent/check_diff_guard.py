"""
Post-hoc Git Diff Guard (scripts/agent/check_diff_guard.py).
Detects destructive or truncated edits after the fact (ADR-ARCH-010): truncation placeholders on
added lines, excessive net line deletion per file, and single hunks that remove too many lines.
Tool calls are not interceptable; only the resulting git diff is checked.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import List, Optional, Set, Tuple

ROOT_DIR = Path(__file__).resolve().parents[2]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.check_line_budget import (
    DEFAULT_CONFIG_PATH,
    approved_exception_paths,
    is_budgeted_file,
    load_project_config,
)
from scripts.agent.config_models import DiffGuardConfig
from scripts.agent.models import FixableBy, Issue, ResultEnvelope, Severity, TaskContract
from scripts.agent.validate_task import parse_task_markdown, resolve_task_path

_HUNK_RE = re.compile(r"^@@ -\d+(?:,(\d+))? \+\d+(?:,(\d+))? @@")


def _git(workspace_root: Path, args: List[str]) -> Optional[str]:
    """Run a git command and return stdout, or None when git fails."""
    try:
        proc = subprocess.run(
            ["git", *args], cwd=str(workspace_root), capture_output=True,
            text=True, encoding="utf-8", errors="replace", check=False, timeout=30,
        )
    except OSError:
        return None
    return proc.stdout if proc.returncode == 0 else None


def parse_unified_diff(diff_text: str) -> Tuple[List[str], int, int, List[int]]:
    """Return (added_lines, total_added, total_deleted, removed_per_hunk) from a -U0 diff."""
    added: List[str] = []
    deleted = 0
    removed_per_hunk: List[int] = []
    for line in diff_text.splitlines():
        hunk = _HUNK_RE.match(line)
        if hunk:
            old_n = int(hunk.group(1)) if hunk.group(1) is not None else 1
            removed_per_hunk.append(old_n)
            continue
        if line.startswith("+++") or line.startswith("---"):
            continue
        if line.startswith("+"):
            added.append(line[1:])
        elif line.startswith("-"):
            deleted += 1
    return added, len(added), deleted, removed_per_hunk


def _is_untracked(workspace_root: Path, rel_path: str) -> bool:
    out = _git(workspace_root, ["ls-files", "--others", "--exclude-standard", "--", rel_path])
    return bool(out and out.strip())


def check_diff_guard(
    workspace_root: Path,
    files: List[str],
    guard: DiffGuardConfig,
    waived_paths: Set[str],
) -> List[Issue]:
    """Evaluate each file's diff against the guard thresholds; return error Issues."""
    issues: List[Issue] = []
    patterns = [re.compile(p) for p in guard.placeholder_patterns]
    for rel_path in files:
        full = workspace_root / rel_path
        if _is_untracked(workspace_root, rel_path) and full.is_file():
            added = full.read_text(encoding="utf-8", errors="replace").splitlines()
            deleted, removed_per_hunk, total_added = 0, [], len(added)
        else:
            diff_text = _git(workspace_root, ["diff", "HEAD", "-U0", "--no-color", "--", rel_path])
            if diff_text is None:
                issues.append(Issue(
                    code="ERR_DIFF_GIT_UNAVAILABLE", severity=Severity.ERROR,
                    message=f"git diff failed for '{rel_path}'.", location=rel_path, fixable_by=FixableBy.AI,
                ))
                continue
            added, total_added, deleted, removed_per_hunk = parse_unified_diff(diff_text)

        for line in added:
            if any(p.search(line) for p in patterns):
                issues.append(Issue(
                    code="ERR_DIFF_PLACEHOLDER", severity=Severity.ERROR,
                    message=f"'{rel_path}' contains a truncation placeholder on an added line.",
                    location=rel_path, fixable_by=FixableBy.AI,
                    evidence={"line": line.strip()[:200]},
                    suggested_action="Restore the omitted code; never replace code with a placeholder.",
                ))
                break

        if rel_path in waived_paths:
            continue
        net_deleted = deleted - total_added
        if net_deleted > guard.max_net_deleted_lines:
            issues.append(Issue(
                code="ERR_DIFF_NET_DELETION", severity=Severity.ERROR,
                message=f"'{rel_path}' loses {net_deleted} net lines (> {guard.max_net_deleted_lines}).",
                location=rel_path, fixable_by=FixableBy.HUMAN,
                evidence={"deleted": deleted, "added": total_added, "limit": guard.max_net_deleted_lines},
                suggested_action="Confirm the deletion is intended and add an approved line_budget_exceptions entry.",
            ))
        if removed_per_hunk and max(removed_per_hunk) > guard.max_hunk_lines:
            issues.append(Issue(
                code="ERR_DIFF_HUNK_TOO_LARGE", severity=Severity.ERROR,
                message=f"'{rel_path}' has a hunk removing {max(removed_per_hunk)} lines (> {guard.max_hunk_lines}).",
                location=rel_path, fixable_by=FixableBy.HUMAN,
                evidence={"max_removed_in_hunk": max(removed_per_hunk), "limit": guard.max_hunk_lines},
                suggested_action="Edit in smaller slices, or add an approved line_budget_exceptions entry.",
            ))
    return issues


def run_diff_guard(workspace_root: Path, task_arg: str, files: List[str]) -> ResultEnvelope:
    """Load config and contract, then guard the given files."""
    config = load_project_config(workspace_root, DEFAULT_CONFIG_PATH)
    raw_fm, _ = parse_task_markdown(resolve_task_path(workspace_root, task_arg))
    contract = TaskContract.model_validate(raw_fm)
    targets = [f for f in files if is_budgeted_file(f, config, workspace_root)]
    issues = check_diff_guard(workspace_root, targets, config.line_budget.diff_guard, approved_exception_paths(contract))
    return ResultEnvelope(
        success=not any(i.severity == Severity.ERROR for i in issues),
        tool="check_diff_guard", issues=issues, data={"files_checked": targets},
    )


def main(argv: Optional[List[str]] = None) -> int:
    from scripts.agent.check_scope import get_git_changed_files

    parser = argparse.ArgumentParser(description="Post-hoc git diff guard against truncated or destructive edits.")
    parser.add_argument("--root", type=Path, default=ROOT_DIR)
    parser.add_argument("--task", required=True)
    parser.add_argument("--files", nargs="*", default=None)
    args = parser.parse_args(argv)
    root = args.root.resolve()
    files = args.files if args.files is not None else (get_git_changed_files(root)[0] or [])
    res = run_diff_guard(root, args.task, files)
    print(json.dumps(res.model_dump(mode="json"), indent=2, ensure_ascii=False))
    return res.exit_code


if __name__ == "__main__":
    sys.exit(main())
