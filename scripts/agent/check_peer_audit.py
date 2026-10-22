"""
Subagent Semantic Peer-Audit Gatekeeper (scripts/agent/check_peer_audit.py).
Validates that an independent Auditor Subagent has reviewed the Primary Agent's
thinking/decisions, loaded GEMINI.md + core rules + verification skills, verified
ADR-0010 anti-cheat compliance, and issued a PASS verdict matching the live diff_sha256.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import List, Optional

from pydantic import ValidationError

ROOT_DIR = Path(__file__).resolve().parents[2]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.check_scope import check_scope
from scripts.agent.models import (
    FixableBy,
    Issue,
    PeerAuditReceipt,
    PeerAuditVerdict,
    ResultEnvelope,
    Severity,
)
from scripts.agent.validate_task import parse_task_markdown, resolve_task_path

EVIDENCE_DIR = Path("docs/agent-system/evidence")

MANDATORY_AUDIT_CONTEXT_FILES: List[str] = [
    "GEMINI.md",
    "AGENTS.md",
    "ARCHITECTURE.md",
    ".agents/rules/rule_anti_evasion.md",
    ".agents/rules/rule_critical_engagement.md",
    ".agents/rules/rule_task_contract_and_scope.md",
    ".agents/skills/verify-task/SKILL.md",
    ".agents/skills/critical-engagement/SKILL.md",
    ".agents/skills/honest-execution/SKILL.md",
]


def _resolve_task_id(workspace_root: Path, task_arg: str) -> str:
    task_path = resolve_task_path(workspace_root, task_arg)
    if task_path.exists():
        try:
            raw_fm, _ = parse_task_markdown(task_path)
            if isinstance(raw_fm.get("id"), str):
                return str(raw_fm["id"])
        except Exception:
            pass
    return task_arg.strip()


def check_peer_audit(
    workspace_root: Path,
    task_arg: str,
    expected_diff_sha256: Optional[str] = None,
    explicit_files: Optional[List[str]] = None,
) -> ResultEnvelope:
    """Validate docs/agent-system/evidence/TASK-XXXX-peer-audit.json against live diff and rules."""
    issues: List[Issue] = []
    task_id = _resolve_task_id(workspace_root, task_arg)
    audit_rel_path = (EVIDENCE_DIR / f"{task_id}-peer-audit.json").as_posix()
    audit_full_path = workspace_root / audit_rel_path

    if not audit_full_path.exists():
        issues.append(Issue(
            code="ERR_PEER_AUDIT_MISSING",
            severity=Severity.ERROR,
            message=(
                f"Subagent peer-audit receipt '{audit_rel_path}' is missing. "
                "You must spawn an independent Auditor Subagent to review your thinking/decisions, "
                "GEMINI.md, rules, skills, and code semantics before running run_verify.py."
            ),
            location=audit_rel_path,
            fixable_by=FixableBy.AI,
            suggested_action="Follow .agents/skills/verify-task/SKILL.md to invoke the Peer Auditor Subagent.",
        ))
        return ResultEnvelope(success=False, tool="check_peer_audit", issues=issues)

    try:
        raw_data = json.loads(audit_full_path.read_text(encoding="utf-8"))
        receipt = PeerAuditReceipt.model_validate(raw_data)
    except (OSError, json.JSONDecodeError, ValidationError) as exc:
        issues.append(Issue(
            code="ERR_PEER_AUDIT_SCHEMA_INVALID",
            severity=Severity.ERROR,
            message=f"Peer-audit receipt '{audit_rel_path}' failed schema validation: {exc}",
            location=audit_rel_path,
            fixable_by=FixableBy.AI,
        ))
        return ResultEnvelope(success=False, tool="check_peer_audit", issues=issues)

    if receipt.task_id != task_id:
        issues.append(Issue(
            code="ERR_PEER_AUDIT_TASK_MISMATCH",
            severity=Severity.ERROR,
            message=f"Peer-audit receipt task_id '{receipt.task_id}' does not match '{task_id}'.",
            location=audit_rel_path,
            fixable_by=FixableBy.AI,
        ))

    loaded_norm = {p.strip().replace("\\", "/") for p in receipt.rules_and_docs_loaded}
    missing_context = [req for req in MANDATORY_AUDIT_CONTEXT_FILES if req not in loaded_norm]
    if missing_context:
        issues.append(Issue(
            code="ERR_PEER_AUDIT_INCOMPLETE_CONTEXT",
            severity=Severity.ERROR,
            message=f"Subagent did not load all mandatory rules/skills/GEMINI.md: missing {missing_context}",
            location=audit_rel_path,
            fixable_by=FixableBy.AI,
            evidence={"missing_context_files": missing_context},
        ))

    if receipt.verdict != PeerAuditVerdict.PASS or receipt.findings:
        issues.append(Issue(
            code="ERR_PEER_AUDIT_REJECTED",
            severity=Severity.ERROR,
            message=(
                f"Subagent peer audit did not pass cleanly (verdict={receipt.verdict.value}, "
                f"findings={len(receipt.findings)}). Fix all findings and re-audit before verifying."
            ),
            location=audit_rel_path,
            fixable_by=FixableBy.AI,
            evidence={"verdict": receipt.verdict.value, "findings": receipt.findings},
        ))

    live_diff_sha256 = expected_diff_sha256
    if live_diff_sha256 is None:
        scope_res = check_scope(workspace_root, task_id, explicit_files=explicit_files)
        if not scope_res.success:
            issues.extend(scope_res.issues)
        live_diff_sha256 = str(scope_res.data.get("diff_sha256", ""))

    if not live_diff_sha256 or receipt.diff_sha256 != live_diff_sha256:
        issues.append(Issue(
            code="ERR_PEER_AUDIT_DIFF_STALE",
            severity=Severity.ERROR,
            message=(
                f"Peer-audit diff_sha256 ({receipt.diff_sha256[:12]}...) does not match current working tree "
                f"diff_sha256 ({live_diff_sha256[:12]}...). Code changed after peer audit."
            ),
            location=audit_rel_path,
            fixable_by=FixableBy.AI,
            suggested_action="Re-run the Subagent peer audit on the current working tree diff.",
            evidence={"audit_diff_sha256": receipt.diff_sha256, "live_diff_sha256": live_diff_sha256},
        ))

    has_err = any(i.severity == Severity.ERROR for i in issues)
    return ResultEnvelope(
        success=not has_err,
        tool="check_peer_audit",
        issues=issues,
        data={
            "task_id": task_id,
            "subagent_conversation_id": receipt.subagent_conversation_id,
            "verdict": receipt.verdict.value,
            "diff_sha256": receipt.diff_sha256,
            "audit_receipt": audit_rel_path,
        },
    )


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Validate Subagent Semantic Peer-Audit Receipt.")
    parser.add_argument("--root", type=Path, default=ROOT_DIR, help="Workspace root directory")
    parser.add_argument("--task", required=True, help="Task ID (e.g. TASK-0007B) or path to task markdown")
    args = parser.parse_args(argv)

    res = check_peer_audit(workspace_root=args.root.resolve(), task_arg=args.task)
    print(json.dumps(res.model_dump(mode="json"), indent=2, ensure_ascii=False))
    return res.exit_code


if __name__ == "__main__":
    sys.exit(main())
