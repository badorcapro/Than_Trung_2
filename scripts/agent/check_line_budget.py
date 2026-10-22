"""
Role-Based Line Budget Checker (scripts/agent/check_line_budget.py).
Resolves each changed code file's role from project-config.json, counts non-empty lines with a
single shared function, and evaluates warn/review/hard tiers (ADR-ARCH-010). Cohesion is not
measured here; a human decides at the review tier by approving an exception.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path, PurePosixPath
from typing import Any, Dict, List, Optional

import yaml
from pydantic import ValidationError

ROOT_DIR = Path(__file__).resolve().parents[2]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.check_scope import get_git_changed_files, matches_pattern
from scripts.agent.config_models import LineBudgetConfig, ProjectConfig, RoleBudget
from scripts.agent.models import (
    FixableBy,
    Issue,
    ResultEnvelope,
    Severity,
    TaskContract,
)
from scripts.agent.validate_task import parse_task_markdown, resolve_task_path

DEFAULT_CONFIG_PATH = Path("docs/agent-system/project-config.json")


def count_loc(text: str) -> int:
    """Count lines with non-whitespace content. The only LOC counting function."""
    return sum(1 for line in text.splitlines() if line.strip())


def resolve_role(rel_path: str, budget: LineBudgetConfig) -> str:
    """Return the role of the first matching role_map entry, else default_role."""
    for entry in budget.role_map:
        if matches_pattern(rel_path, entry.glob):
            return entry.role
    return budget.default_role


def load_project_config(workspace_root: Path, config_rel_path: Path = DEFAULT_CONFIG_PATH) -> ProjectConfig:
    """Load and validate project-config.json."""
    raw = json.loads((workspace_root / config_rel_path).read_text(encoding="utf-8"))
    return ProjectConfig.model_validate(raw)


def approved_exception_paths(contract: Optional[TaskContract]) -> set[str]:
    """Paths whose exception carries a non-empty approved_by."""
    if contract is None:
        return set()
    return {
        exc.path.replace("\\", "/")
        for exc in contract.line_budget_exceptions
        if exc.approved_by and exc.approved_by.strip()
    }


def classify_tier(loc: int, role_budget: RoleBudget) -> str:
    """Return 'exempt', 'ok', 'warn', 'review' or 'hard' for a LOC value."""
    if role_budget.exempt:
        return "exempt"
    assert role_budget.warn is not None and role_budget.review is not None and role_budget.hard is not None
    if loc > role_budget.hard:
        return "hard"
    if loc > role_budget.review:
        return "review"
    if loc > role_budget.warn:
        return "warn"
    return "ok"


def is_budgeted_file(rel_path: str, config: ProjectConfig, workspace_root: Path) -> bool:
    """True if the file is an existing code file whose role is not exempt."""
    budget = config.line_budget
    if PurePosixPath(rel_path).suffix.lower() not in {e.lower() for e in budget.include_extensions}:
        return False
    if not (workspace_root / rel_path).is_file():
        return False
    return not budget.profiles[config.active_profile][resolve_role(rel_path, budget)].exempt


_NOTE_FIELDS = ("responsibilities", "public_symbols", "reason_not_split")


def _note_section(body: str, rel_path: str) -> Optional[str]:
    """Return the text of the '## Cohesion Note: <path>' section, ignoring fenced code blocks."""
    clean = re.sub(r"```[\s\S]*?```", "", body)
    for match in re.finditer(r"^##\s+Cohesion Note:\s*(.+?)\s*$", clean, flags=re.MULTILINE):
        if match.group(1).replace("\\", "/") == rel_path:
            rest = clean[match.end():]
            nxt = re.search(r"^##\s", rest, flags=re.MULTILINE)
            return rest[: nxt.start()] if nxt else rest
    return None


def check_cohesion_notes(files_report: List[Dict[str, Any]], task_body: str) -> List[Issue]:
    """Require a complete cohesion note for every file at warn tier or above (presence only)."""
    issues: List[Issue] = []
    for entry in files_report:
        if entry["tier"] not in ("warn", "review", "hard"):
            continue
        section = _note_section(task_body, entry["path"])
        missing = list(_NOTE_FIELDS) if section is None else [
            f for f in _NOTE_FIELDS
            if not re.search(rf"^-\s*{f}:\s*\S", section, flags=re.MULTILINE)
        ]
        if missing:
            issues.append(Issue(
                code="ERR_LBUD_COHESION_NOTE_MISSING", severity=Severity.ERROR,
                message=f"'{entry['path']}' ({entry['loc']} lines, tier {entry['tier']}) lacks a complete cohesion note.",
                location=entry["path"], fixable_by=FixableBy.AI, evidence={"missing_fields": missing},
                suggested_action="Add '## Cohesion Note: <path>' with responsibilities, public_symbols, reason_not_split to the task body.",
            ))
    return issues


def _tier_issue(rel_path: str, role: str, loc: int, tier: str, limit: int, excepted: bool) -> Optional[Issue]:
    """Build the Issue for a tier result, or None when nothing to report."""
    evidence: Dict[str, Any] = {"role": role, "loc": loc, "limit": limit, "tier": tier}
    if tier == "warn":
        return Issue(
            code="WARN_LBUD_COHESION_NOTE", severity=Severity.WARNING,
            message=f"'{rel_path}' ({role}) has {loc} lines > warn {limit}; a cohesion note is required.",
            location=rel_path, fixable_by=FixableBy.AI, evidence=evidence,
            suggested_action="Record a cohesion note (responsibilities, public symbols, reason not split) in the task body.",
        )
    if tier in ("review", "hard") and excepted:
        return Issue(
            code="INFO_LBUD_EXCEPTION_APPLIED", severity=Severity.INFO,
            message=f"'{rel_path}' ({role}) has {loc} lines > {tier} {limit}; approved exception applied.",
            location=rel_path, fixable_by=FixableBy.HUMAN, evidence=evidence,
        )
    if tier == "review":
        return Issue(
            code="ERR_LBUD_REVIEW_REQUIRED", severity=Severity.ERROR,
            message=f"'{rel_path}' ({role}) has {loc} lines > review {limit}; human-approved exception required.",
            location=rel_path, fixable_by=FixableBy.HUMAN, evidence=evidence,
            suggested_action="Propose a line_budget_exceptions entry; a human must fill approved_by, or split the file.",
        )
    if tier == "hard":
        return Issue(
            code="ERR_LBUD_HARD_EXCEEDED", severity=Severity.ERROR,
            message=f"'{rel_path}' ({role}) has {loc} lines > hard {limit}; approved exception required.",
            location=rel_path, fixable_by=FixableBy.HUMAN, evidence=evidence,
            suggested_action="Split the file, or obtain a human-approved line_budget_exceptions entry.",
        )
    return None


def check_line_budget(
    workspace_root: Path,
    task_arg: Optional[str] = None,
    explicit_files: Optional[List[str]] = None,
    config_rel_path: Path = DEFAULT_CONFIG_PATH,
) -> ResultEnvelope:
    """Evaluate changed code files against role-based line budgets."""
    issues: List[Issue] = []
    try:
        config = load_project_config(workspace_root, config_rel_path)
    except (OSError, json.JSONDecodeError, ValidationError) as exc:
        issues.append(Issue(
            code="ERR_LBUD_CONFIG_INVALID", severity=Severity.ERROR,
            message=f"project-config.json unreadable or invalid: {exc}",
            location=config_rel_path.as_posix(), fixable_by=FixableBy.HUMAN,
        ))
        return ResultEnvelope(success=False, tool="check_line_budget", issues=issues)

    contract: Optional[TaskContract] = None
    if task_arg:
        task_path = resolve_task_path(workspace_root, task_arg)
        try:
            raw_fm, _ = parse_task_markdown(task_path)
            contract = TaskContract.model_validate(raw_fm)
        except (OSError, ValueError, yaml.YAMLError, ValidationError) as exc:
            issues.append(Issue(
                code="ERR_TASK_SCHEMA_INVALID", severity=Severity.ERROR,
                message=f"Invalid task contract '{task_arg}': {exc}", location=task_arg, fixable_by=FixableBy.AI,
            ))
            return ResultEnvelope(success=False, tool="check_line_budget", issues=issues)

    if explicit_files is not None:
        changed: Optional[List[str]] = sorted(f.replace("\\", "/") for f in explicit_files)
    else:
        changed, git_err = get_git_changed_files(workspace_root)
        if changed is None:
            issues.append(Issue(
                code="ERR_GIT_UNAVAILABLE", severity=Severity.ERROR,
                message=f"Git status check failed: {git_err}", location=workspace_root.as_posix(),
                fixable_by=FixableBy.AI,
            ))
            return ResultEnvelope(success=False, tool="check_line_budget", issues=issues)

    budget = config.line_budget
    profile = budget.profiles[config.active_profile]
    extensions = {ext.lower() for ext in budget.include_extensions}
    approved = approved_exception_paths(contract)
    report: List[Dict[str, Any]] = []

    for rel_path in changed:
        full = workspace_root / rel_path
        if PurePosixPath(rel_path).suffix.lower() not in extensions or not full.is_file():
            continue
        role = resolve_role(rel_path, budget)
        role_budget = profile[role]
        loc = count_loc(full.read_text(encoding="utf-8", errors="replace"))
        tier = classify_tier(loc, role_budget)
        report.append({"path": rel_path, "role": role, "loc": loc, "tier": tier})
        if tier in ("exempt", "ok"):
            continue
        limit = {"warn": role_budget.warn, "review": role_budget.review, "hard": role_budget.hard}[tier]
        issue = _tier_issue(rel_path, role, loc, tier, int(limit or 0), rel_path in approved)
        if issue is not None:
            issues.append(issue)

    has_err = any(i.severity == Severity.ERROR for i in issues)
    return ResultEnvelope(
        success=not has_err, tool="check_line_budget", issues=issues,
        data={"active_profile": config.active_profile, "files": report},
    )


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Check changed files against role-based line budgets.")
    parser.add_argument("--root", type=Path, default=ROOT_DIR, help="Workspace root directory")
    parser.add_argument("--task", default=None, help="Task ID whose line_budget_exceptions apply")
    parser.add_argument("--files", nargs="*", default=None, help="Explicit file list (default: git changed files)")
    parser.add_argument("--config", type=Path, default=DEFAULT_CONFIG_PATH, help="Relative path to project-config.json")
    args = parser.parse_args(argv)

    res = check_line_budget(args.root.resolve(), args.task, args.files, args.config)
    print(json.dumps(res.model_dump(mode="json"), indent=2, ensure_ascii=False))
    return res.exit_code


if __name__ == "__main__":
    sys.exit(main())
