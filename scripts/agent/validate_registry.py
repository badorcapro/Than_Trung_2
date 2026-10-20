"""
Registry & Context Health Validator (scripts/agent/validate_registry.py).
Audits docs/agent-system/reference-registry.json for duplicate IDs, missing files,
SHA-256 staleness, dependency cycles, and verifies .agents/ context budget compliance.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Dict, List, Optional, Set

ROOT_DIR = Path(__file__).resolve().parents[2]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from pydantic import ValidationError
from scripts.agent.models import (
    FixableBy,
    Issue,
    ReferenceRegistry,
    RegistryEntry,
    ResultEnvelope,
    Severity,
    compute_file_sha256,
)

DEFAULT_REGISTRY_PATH = Path("docs/agent-system/reference-registry.json")
MAX_RULE_CHARS = 12_000
MAX_ROOT_AGENTS_LINES = 100
WARN_ROOT_AGENTS_LINES = 80
ACTIVE_TOKEN_BUDGET = 20_000


def _detect_cycles(entries: Dict[str, RegistryEntry]) -> List[List[str]]:
    """Detect directed cycles in depends_on graph using 3-color DFS."""
    state: Dict[str, int] = {k: 0 for k in entries}  # 0=unvisited, 1=visiting, 2=visited
    path: List[str] = []
    cycles: List[List[str]] = []

    def dfs(node: str) -> None:
        state[node] = 1
        path.append(node)
        for dep in entries[node].depends_on:
            if dep not in entries:
                continue
            if state[dep] == 1:
                idx = path.index(dep)
                cycles.append(path[idx:] + [dep])
            elif state[dep] == 0:
                dfs(dep)
        path.pop()
        state[node] = 2

    for node_id in entries:
        if state[node_id] == 0:
            dfs(node_id)
    return cycles


def audit_context_health(workspace_root: Path) -> tuple[List[Issue], Dict[str, object]]:
    """Audit AGENTS.md and .agents/rules/*.md for frontmatter and token budget compliance."""
    issues: List[Issue] = []
    always_on_chars = 0
    rule_files_checked = 0

    agents_md = workspace_root / "AGENTS.md"
    if agents_md.exists():
        text = agents_md.read_text(encoding="utf-8")
        lines = text.splitlines()
        always_on_chars += len(text)
        if len(lines) > MAX_ROOT_AGENTS_LINES:
            issues.append(Issue(
                code="ERR_CTX_ROOT_LINES",
                severity=Severity.ERROR,
                message=f"AGENTS.md has {len(lines)} lines (hard cap: {MAX_ROOT_AGENTS_LINES}).",
                location="AGENTS.md",
                fixable_by=FixableBy.AI,
                suggested_action="Move detailed procedures to .agents/skills/ or docs/.",
                evidence={"lines": len(lines), "limit": MAX_ROOT_AGENTS_LINES},
            ))
        elif len(lines) > WARN_ROOT_AGENTS_LINES:
            issues.append(Issue(
                code="WARN_CTX_ROOT_LINES",
                severity=Severity.WARNING,
                message=f"AGENTS.md has {len(lines)} lines (recommended <= {WARN_ROOT_AGENTS_LINES}).",
                location="AGENTS.md",
                fixable_by=FixableBy.AI,
                suggested_action="Trim prose in AGENTS.md to keep baseline context lean.",
                evidence={"lines": len(lines), "recommended": WARN_ROOT_AGENTS_LINES},
            ))

    rules_dir = workspace_root / ".agents" / "rules"
    if rules_dir.exists():
        for rule_path in sorted(rules_dir.glob("*.md")):
            rule_files_checked += 1
            rel_loc = rule_path.relative_to(workspace_root).as_posix()
            raw = rule_path.read_text(encoding="utf-8")
            if len(raw) > MAX_RULE_CHARS:
                issues.append(Issue(
                    code="ERR_CTX_RULE_SIZE",
                    severity=Severity.ERROR,
                    message=f"Rule file exceeds {MAX_RULE_CHARS} chars ({len(raw)} chars).",
                    location=rel_loc,
                    fixable_by=FixableBy.AI,
                    suggested_action="Split deep reference tables into a skill package under .agents/skills/.",
                    evidence={"chars": len(raw), "limit": MAX_RULE_CHARS},
                ))

            lines = raw.splitlines()
            has_frontmatter = len(lines) >= 3 and lines[0].strip() == "---"
            trigger = "always_on"
            glob_param = ""
            desc_param = ""
            if has_frontmatter:
                for line in lines[1:]:
                    if line.strip() == "---":
                        break
                    if line.startswith("trigger:"):
                        trigger = line.replace("trigger:", "", 1).strip()
                    elif line.startswith("globs:"):
                        glob_param = line.replace("globs:", "", 1).strip()
                    elif line.startswith("description:"):
                        desc_param = line.replace("description:", "", 1).strip()

            if trigger == "glob" and not glob_param:
                issues.append(Issue(
                    code="ERR_CTX_EMPTY_GLOB",
                    severity=Severity.ERROR,
                    message="Rule uses 'trigger: glob' without a non-empty 'globs:' pattern (causes IDE 0/250 dead rule).",
                    location=rel_loc,
                    fixable_by=FixableBy.AI,
                    suggested_action="Add 'globs: <comma-separated-patterns>' to the YAML frontmatter.",
                ))
            elif trigger == "model_decision" and not desc_param:
                issues.append(Issue(
                    code="ERR_CTX_EMPTY_DESC",
                    severity=Severity.ERROR,
                    message="Rule uses 'trigger: model_decision' without a non-empty 'description:' field.",
                    location=rel_loc,
                    fixable_by=FixableBy.AI,
                    suggested_action="Add a bilingual 'description:' field to the YAML frontmatter.",
                ))
            elif trigger == "always_on":
                always_on_chars += len(raw)

    estimated_tokens = always_on_chars // 4
    health_pct = round((estimated_tokens / ACTIVE_TOKEN_BUDGET) * 100.0, 2)
    if health_pct > 30.0:
        issues.append(Issue(
            code="ERR_CTX_BUDGET_EXCEEDED",
            severity=Severity.ERROR,
            message=f"Always-on context consumes {health_pct}% ({estimated_tokens} tokens) of 20k budget (>30% critical).",
            location=".agents/rules",
            fixable_by=FixableBy.AI,
            suggested_action="Convert always_on rules to glob or model_decision triggers.",
            evidence={"estimated_tokens": estimated_tokens, "health_pct": health_pct},
        ))
    elif health_pct > 15.0:
        issues.append(Issue(
            code="WARN_CTX_BUDGET_HIGH",
            severity=Severity.WARNING,
            message=f"Always-on context consumes {health_pct}% ({estimated_tokens} tokens) of 20k budget (>15% warning).",
            location=".agents/rules",
            fixable_by=FixableBy.AI,
            suggested_action="Keep always_on baseline below 15% (3,000 tokens).",
            evidence={"estimated_tokens": estimated_tokens, "health_pct": health_pct},
        ))

    metrics = {
        "rule_files_checked": rule_files_checked,
        "always_on_chars": always_on_chars,
        "estimated_always_on_tokens": estimated_tokens,
        "context_health_pct": health_pct,
    }
    return issues, metrics


def validate_registry(
    workspace_root: Path,
    registry_rel_path: Path = DEFAULT_REGISTRY_PATH,
    check_context: bool = True,
    update_hashes: bool = False,
) -> ResultEnvelope:
    """Validate reference-registry.json and optionally audit .agents/ context budget."""
    issues: List[Issue] = []
    reg_path = workspace_root / registry_rel_path

    if not reg_path.exists():
        issues.append(Issue(
            code="ERR_REG_FILE_NOT_FOUND",
            severity=Severity.ERROR,
            message=f"Reference registry not found at '{registry_rel_path.as_posix()}'.",
            location=registry_rel_path.as_posix(),
            fixable_by=FixableBy.AI,
            suggested_action="Initialize docs/agent-system/reference-registry.json.",
        ))
        return ResultEnvelope(success=False, tool="validate_registry", issues=issues)

    try:
        raw_data = json.loads(reg_path.read_text(encoding="utf-8"))
        registry = ReferenceRegistry.model_validate(raw_data)
    except (json.JSONDecodeError, ValidationError) as exc:
        issues.append(Issue(
            code="ERR_REG_SCHEMA_INVALID",
            severity=Severity.ERROR,
            message=f"Registry schema validation failed: {exc}",
            location=registry_rel_path.as_posix(),
            fixable_by=FixableBy.AI,
            suggested_action="Fix JSON syntax or field types in reference-registry.json.",
        ))
        return ResultEnvelope(success=False, tool="validate_registry", issues=issues)

    entry_map: Dict[str, RegistryEntry] = {}
    seen_paths: Set[str] = set()
    hashes_updated = 0

    for entry in registry.entries:
        if entry.id in entry_map:
            issues.append(Issue(
                code="ERR_REG_DUPLICATE_ID",
                severity=Severity.ERROR,
                message=f"Duplicate Reference ID '{entry.id}'.",
                location=entry.id,
                fixable_by=FixableBy.AI,
                suggested_action="Assign a unique Reference ID to each entry.",
            ))
        entry_map[entry.id] = entry

        if entry.path in seen_paths:
            issues.append(Issue(
                code="WARN_REG_DUPLICATE_PATH",
                severity=Severity.WARNING,
                message=f"Multiple registry entries point to path '{entry.path}'.",
                location=entry.id,
                fixable_by=FixableBy.AI,
            ))
        seen_paths.add(entry.path)

        target_file = workspace_root / entry.path
        if not target_file.exists():
            issues.append(Issue(
                code="ERR_REG_MISSING_PATH",
                severity=Severity.ERROR,
                message=f"Referenced path '{entry.path}' does not exist on disk.",
                location=entry.id,
                fixable_by=FixableBy.AI,
                suggested_action=f"Create '{entry.path}' or correct the path in reference-registry.json.",
                evidence={"id": entry.id, "path": entry.path},
            ))
            continue

        if target_file.is_file():
            actual_hash = compute_file_sha256(target_file)
            if update_hashes and entry.sha256 != actual_hash:
                entry.sha256 = actual_hash
                hashes_updated += 1
            elif entry.sha256 and entry.sha256 != actual_hash:
                issues.append(Issue(
                    code="ERR_REG_STALE_HASH",
                    severity=Severity.ERROR,
                    message=f"File '{entry.path}' changed on disk since SHA-256 was recorded.",
                    location=entry.id,
                    fixable_by=FixableBy.HUMAN,
                    suggested_action="Review changes, verify dependents with check_impact.py, then run validate_registry.py --update-hashes.",
                    evidence={"expected": entry.sha256, "actual": actual_hash},
                ))

    if update_hashes and hashes_updated > 0:
        reg_path.write_text(
            json.dumps(registry.model_dump(mode="json"), indent=2, ensure_ascii=False) + "\n",
            encoding="utf-8",
        )

    for entry in registry.entries:
        for dep_id in entry.depends_on:
            if dep_id not in entry_map:
                issues.append(Issue(
                    code="ERR_REG_UNKNOWN_DEP",
                    severity=Severity.ERROR,
                    message=f"Entry '{entry.id}' depends on non-existent Reference ID '{dep_id}'.",
                    location=entry.id,
                    fixable_by=FixableBy.AI,
                    suggested_action=f"Register '{dep_id}' or remove it from depends_on.",
                ))

    for cycle in _detect_cycles(entry_map):
        issues.append(Issue(
            code="ERR_REG_CYCLE",
            severity=Severity.ERROR,
            message=f"Circular dependency detected: {' -> '.join(cycle)}",
            location=cycle[0],
            fixable_by=FixableBy.AI,
            suggested_action="Break the dependency cycle in reference-registry.json.",
            evidence={"cycle": cycle},
        ))

    ctx_metrics: Dict[str, object] = {}
    if check_context:
        ctx_issues, ctx_metrics = audit_context_health(workspace_root)
        issues.extend(ctx_issues)

    has_err = any(i.severity == Severity.ERROR for i in issues)
    return ResultEnvelope(
        success=not has_err,
        tool="validate_registry",
        issues=issues,
        data={
            "project": registry.project,
            "total_entries": len(registry.entries),
            "hashes_updated": hashes_updated,
            "context_health": ctx_metrics,
        },
    )


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Validate reference-registry.json and .agents/ context budget.")
    parser.add_argument("--root", type=Path, default=ROOT_DIR, help="Workspace root directory")
    parser.add_argument("--registry", type=Path, default=DEFAULT_REGISTRY_PATH, help="Relative path to registry JSON")
    parser.add_argument("--no-context-check", action="store_true", help="Skip .agents/ context budget check")
    parser.add_argument("--update-hashes", action="store_true", help="Refresh SHA-256 hashes for existing files")
    args = parser.parse_args(argv)

    res = validate_registry(
        workspace_root=args.root.resolve(),
        registry_rel_path=args.registry,
        check_context=not args.no_context_check,
        update_hashes=args.update_hashes,
    )
    print(json.dumps(res.model_dump(mode="json"), indent=2, ensure_ascii=False))
    return res.exit_code


if __name__ == "__main__":
    sys.exit(main())
