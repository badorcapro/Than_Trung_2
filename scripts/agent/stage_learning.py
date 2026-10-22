"""
Controlled /learn Staging Gate & Rule Authoring Engine (Layer 5 Governance Engine).
Enforces the 3-step learning gate: proposal generation, anti-overfitting & budget auditing,
and human-authorized promotion to active rules/skills.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import yaml
from pydantic import BaseModel, ConfigDict, Field, ValidationError

ROOT_DIR = Path(__file__).resolve().parents[2]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.models import (
    FixableBy,
    Issue,
    ResultEnvelope,
    Severity,
)

_MAX_RULE_CHARS = 12000
_LEARN_ID_RE = re.compile(r"^LEARN-[0-9]{4}$")
_FOREIGN_PATH_RE = re.compile(r"(file:///|[a-zA-Z]:[/\\]|/home/|/Users/)", re.IGNORECASE)
_HARDCODED_COORD_RE = re.compile(r'\b(ws|sheet)\[["\'][A-Z]+[0-9]+["\']\]', re.IGNORECASE)


class LearningProposalFrontmatter(BaseModel):
    """YAML Frontmatter schema for docs/agent-system/proposals/LEARN-XXXX-*.md."""
    model_config = ConfigDict(extra="forbid")

    id: str = Field(..., description="Proposal ID matching LEARN-XXXX")
    title: str = Field(..., min_length=3, description="Concise rule/skill title")
    target_type: str = Field(..., description="rule | skill")
    trigger: str = Field(default="model_decision", description="always_on | model_decision | glob")
    globs: Optional[List[str]] = Field(default=None, description="Globs if trigger is glob")
    description: Optional[str] = Field(default=None, description="Description for model_decision or rule summary")
    status: str = Field(default="proposal", description="proposal | approved | rejected")
    generality_score: int = Field(default=3, ge=1, le=5, description="Generality rating 1-5")
    created_at: str = Field(..., description="ISO UTC timestamp")


def parse_proposal_markdown(proposal_path: Path) -> Tuple[Dict[str, Any], str]:
    """Extract YAML frontmatter and body from a learning proposal file."""
    text = proposal_path.read_text(encoding="utf-8")
    lines = text.splitlines()
    if len(lines) < 3 or lines[0].strip() != "---":
        raise ValueError(f"Proposal '{proposal_path.name}' must start with '---'.")
    end_idx: Optional[int] = None
    for idx in range(1, len(lines)):
        if lines[idx].strip() == "---":
            end_idx = idx
            break
    if end_idx is None:
        raise ValueError(f"Proposal '{proposal_path.name}' is missing closing '---'.")
    fm = yaml.safe_load("\n".join(lines[1:end_idx]))
    if not isinstance(fm, dict):
        raise ValueError("Proposal frontmatter must be a key-value mapping.")
    body = "\n".join(lines[end_idx + 1 :])
    return fm, body


def audit_proposal(proposal_path: Path, workspace_root: Path) -> ResultEnvelope:
    """Audit learning proposal against anti-overfitting, budget, and schema invariants."""
    issues: List[Issue] = []
    rel_path = str(proposal_path.relative_to(workspace_root)).replace("\\", "/")

    if not proposal_path.exists():
        issues.append(
            Issue(
                code="ERR_LEARN_FILE_NOT_FOUND",
                severity=Severity.ERROR,
                message=f"Proposal file not found at '{rel_path}'.",
                location=rel_path,
                fixable_by=FixableBy.AI,
            )
        )
        return ResultEnvelope(success=False, tool="stage_learning", issues=issues)

    content = proposal_path.read_text(encoding="utf-8")
    if len(content) > _MAX_RULE_CHARS:
        issues.append(
            Issue(
                code="ERR_LEARN_BUDGET",
                severity=Severity.ERROR,
                message=f"Proposal exceeds {_MAX_RULE_CHARS} chars ({len(content)} chars).",
                location=rel_path,
                fixable_by=FixableBy.AI,
                suggested_action="Condense proposal to prevent prompt bloat.",
                evidence={"char_count": len(content), "limit": _MAX_RULE_CHARS},
            )
        )

    try:
        raw_fm, body = parse_proposal_markdown(proposal_path)
        fm = LearningProposalFrontmatter.model_validate(raw_fm)
    except (ValueError, yaml.YAMLError, ValidationError) as exc:
        issues.append(
            Issue(
                code="ERR_LEARN_SCHEMA",
                severity=Severity.ERROR,
                message=f"Proposal schema invalid: {exc}",
                location=rel_path,
                fixable_by=FixableBy.AI,
            )
        )
        return ResultEnvelope(success=False, tool="stage_learning", issues=issues)

    if not _LEARN_ID_RE.match(fm.id):
        issues.append(
            Issue(
                code="ERR_LEARN_SCHEMA",
                severity=Severity.ERROR,
                message=f"Proposal id '{fm.id}' must match LEARN-XXXX pattern.",
                location=rel_path,
                fixable_by=FixableBy.AI,
            )
        )

    if fm.target_type not in {"rule", "skill"}:
        issues.append(
            Issue(
                code="ERR_LEARN_SCHEMA",
                severity=Severity.ERROR,
                message=f"target_type must be 'rule' or 'skill', got '{fm.target_type}'.",
                location=rel_path,
                fixable_by=FixableBy.AI,
            )
        )

    if fm.trigger == "model_decision" and not fm.description:
        issues.append(
            Issue(
                code="ERR_LEARN_SCHEMA",
                severity=Severity.ERROR,
                message="trigger 'model_decision' requires a non-empty description.",
                location=rel_path,
                fixable_by=FixableBy.AI,
            )
        )
    elif fm.trigger == "glob" and not fm.globs:
        issues.append(
            Issue(
                code="ERR_LEARN_SCHEMA",
                severity=Severity.ERROR,
                message="trigger 'glob' requires non-empty globs list.",
                location=rel_path,
                fixable_by=FixableBy.AI,
            )
        )

    # Generality Check
    has_specific_general_split = (
        "[SPECIFIC CASE" in body and "[GENERAL PRINCIPLE" in body
    )
    if fm.generality_score < 3 and not has_specific_general_split:
        issues.append(
            Issue(
                code="ERR_LEARN_LOW_GENERALITY",
                severity=Severity.ERROR,
                message=f"Proposal has generality_score={fm.generality_score} (< 3) without [SPECIFIC CASE] / [GENERAL PRINCIPLE] dual structure.",
                location=rel_path,
                fixable_by=FixableBy.AI,
                suggested_action="Generalize rule across >= 3 scenarios or structure as a one-time critical prevention exception.",
            )
        )

    # Anti-Overfitting Heuristic Check
    clean_body = re.sub(r"```[\s\S]*?```", "", body)
    if _FOREIGN_PATH_RE.search(clean_body):
        issues.append(
            Issue(
                code="ERR_LEARN_OVERFIT",
                severity=Severity.ERROR,
                message="Proposal contains hardcoded absolute or foreign filesystem paths (rote memorization).",
                location=rel_path,
                fixable_by=FixableBy.AI,
                suggested_action="Replace concrete absolute paths with workspace-relative or abstract concepts.",
            )
        )

    if _HARDCODED_COORD_RE.search(clean_body):
        issues.append(
            Issue(
                code="ERR_LEARN_OVERFIT",
                severity=Severity.ERROR,
                message="Proposal hardcodes spreadsheet cell coordinates (e.g. ws['A1']) instead of derivation methods.",
                location=rel_path,
                fixable_by=FixableBy.AI,
                suggested_action="Use dynamic derivation from template cells rather than hardcoded coordinates.",
            )
        )

    has_errors = any(i.severity == Severity.ERROR for i in issues)
    return ResultEnvelope(
        success=not has_errors,
        tool="stage_learning",
        issues=issues,
        data={
            "proposal_id": fm.id,
            "target_type": fm.target_type,
            "generality_score": fm.generality_score,
            "audited_chars": len(content),
        },
    )


def promote_proposal(
    proposal_path: Path,
    workspace_root: Path,
    approved: bool = False,
    destination_name: Optional[str] = None,
) -> ResultEnvelope:
    """Promote an audited proposal into active rules or skills after human approval."""
    audit_env = audit_proposal(proposal_path, workspace_root)
    if not audit_env.success:
        return audit_env

    rel_path = str(proposal_path.relative_to(workspace_root)).replace("\\", "/")
    if not approved:
        issues = [
            Issue(
                code="ERR_LEARN_UNAPPROVED_PROMOTION",
                severity=Severity.ERROR,
                message="Rule promotion requires explicit human authorization flag '--approve-proposal'.",
                location=rel_path,
                fixable_by=FixableBy.HUMAN,
                suggested_action="Confirm human approval by passing '--approve-proposal'.",
            )
        ]
        return ResultEnvelope(success=False, tool="stage_learning", issues=issues)

    raw_fm, body = parse_proposal_markdown(proposal_path)
    fm = LearningProposalFrontmatter.model_validate(raw_fm)
    name = destination_name or fm.title.lower().replace(" ", "_")

    if fm.target_type == "rule":
        target_file = workspace_root / ".agents" / "rules" / f"{name}.md"
        target_file.parent.mkdir(parents=True, exist_ok=True)
        rule_fm: Dict[str, Any] = {"trigger": fm.trigger}
        if fm.description:
            rule_fm["description"] = fm.description
        if fm.globs:
            rule_fm["globs"] = fm.globs
        rule_content = f"---\n{yaml.safe_dump(rule_fm, sort_keys=False).strip()}\n---\n\n# Rule: {fm.title}\n\n{body.strip()}\n"
        target_file.write_text(rule_content, encoding="utf-8")
        promoted_target = str(target_file.relative_to(workspace_root)).replace("\\", "/")
    else:
        skill_dir = workspace_root / ".agents" / "skills" / name
        skill_dir.mkdir(parents=True, exist_ok=True)
        target_file = skill_dir / "SKILL.md"
        skill_fm = {"name": name, "description": fm.description or fm.title}
        skill_content = f"---\n{yaml.safe_dump(skill_fm, sort_keys=False).strip()}\n---\n\n# Skill: {fm.title}\n\n{body.strip()}\n"
        target_file.write_text(skill_content, encoding="utf-8")
        promoted_target = str(target_file.relative_to(workspace_root)).replace("\\", "/")

    # Update proposal status to approved
    raw_fm["status"] = "approved"
    updated_proposal = f"---\n{yaml.safe_dump(raw_fm, sort_keys=False).strip()}\n---\n\n{body.strip()}\n"
    proposal_path.write_text(updated_proposal, encoding="utf-8")

    return ResultEnvelope(
        success=True,
        tool="stage_learning",
        issues=[],
        data={
            "proposal_id": fm.id,
            "status": "approved",
            "promoted_target": promoted_target,
        },
    )


def draft_proposal(
    workspace_root: Path,
    proposal_id: str,
    title: str,
    target_type: str = "rule",
    trigger: str = "model_decision",
    description: str = "",
    generality_score: int = 3,
) -> Path:
    """Helper to generate a clean structured learning proposal template."""
    proposals_dir = workspace_root / "docs" / "agent-system" / "proposals"
    proposals_dir.mkdir(parents=True, exist_ok=True)
    slug = title.lower().replace(" ", "-")
    target_path = proposals_dir / f"{proposal_id}-{slug}.md"

    fm = {
        "id": proposal_id,
        "title": title,
        "target_type": target_type,
        "trigger": trigger,
        "description": description or f"Learning proposal: {title}",
        "status": "proposal",
        "generality_score": generality_score,
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    body = (
        f"# Proposal: {title}\n\n"
        "## 1. Context & Mistake Class\n\n"
        "Describe the underlying failure class and why it would repeat without this rule.\n\n"
        "## 2. Invariant & General Principle\n\n"
        "Describe the universal principle applicable across >= 3 scenarios.\n\n"
        "## 3. Verification Method\n\n"
        "Describe how an automated test or check verifies this invariant.\n"
    )
    content = f"---\n{yaml.safe_dump(fm, sort_keys=False).strip()}\n---\n\n{body}"
    target_path.write_text(content, encoding="utf-8")
    return target_path


def main() -> None:
    parser = argparse.ArgumentParser(description="Controlled /learn Staging Gate & Rule Authoring Engine.")
    parser.add_argument("--root", type=Path, default=None, help="Workspace root directory")
    parser.add_argument("--audit", type=Path, help="Path to learning proposal to audit")
    parser.add_argument("--promote", type=Path, help="Path to learning proposal to promote")
    parser.add_argument("--approve-proposal", action="store_true", help="Authorize promotion to active rules/skills")
    parser.add_argument("--dest-name", type=str, default=None, help="Custom filename/skill name")
    args = parser.parse_args()

    workspace_root = (args.root or Path.cwd()).resolve()

    if args.audit:
        env = audit_proposal(args.audit, workspace_root)
    elif args.promote:
        env = promote_proposal(
            args.promote,
            workspace_root,
            approved=args.approve_proposal,
            destination_name=args.dest_name,
        )
    else:
        parser.error("Specify either --audit <path> or --promote <path>.")

    print(env.model_dump_json(indent=2))
    sys.exit(env.exit_code)


if __name__ == "__main__":
    main()
