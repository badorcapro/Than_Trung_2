"""
Task Execution Contract Validator & State Pointer Synchronizer (scripts/agent/validate_task.py).
Parses YAML frontmatter in docs/agent-system/tasks/TASK-XXXX.md, enforces Reference Authority
gates, verifies tamper-evident EvidenceReceipt for 'verified' tasks, and syncs active-task.json.
"""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import yaml
from pydantic import ValidationError

ROOT_DIR = Path(__file__).resolve().parents[2]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.models import (
    ActiveTaskPointer,
    Authority,
    EvidenceReceipt,
    FixableBy,
    Issue,
    ReferenceRegistry,
    RefStatus,
    ResultEnvelope,
    Severity,
    TaskContract,
    TaskStatus,
    compute_file_sha256,
)

DEFAULT_REGISTRY_PATH = Path("docs/agent-system/reference-registry.json")
DEFAULT_STATE_PATH = Path("docs/agent-system/state/active-task.json")
TASKS_DIR = Path("docs/agent-system/tasks")

GATED_STATUSES = {
    TaskStatus.READY,
    TaskStatus.VERIFIED,
    TaskStatus.APPROVED,
}


def parse_task_markdown(task_path: Path) -> Tuple[Dict[str, Any], str]:
    """Extract YAML frontmatter dict and Markdown body from a TASK-XXXX.md file."""
    text = task_path.read_text(encoding="utf-8")
    lines = text.splitlines()
    if len(lines) < 3 or lines[0].strip() != "---":
        raise ValueError(f"Task file '{task_path.name}' must start with YAML frontmatter '---'.")
    end_idx: Optional[int] = None
    for idx in range(1, len(lines)):
        if lines[idx].strip() == "---":
            end_idx = idx
            break
    if end_idx is None:
        raise ValueError(f"Task file '{task_path.name}' is missing closing YAML frontmatter '---'.")
    yaml_text = "\n".join(lines[1:end_idx])
    body_text = "\n".join(lines[end_idx + 1 :])
    parsed = yaml.safe_load(yaml_text)
    if not isinstance(parsed, dict):
        raise ValueError(f"YAML frontmatter in '{task_path.name}' must evaluate to a key-value mapping.")
    return parsed, body_text


def render_task_markdown(frontmatter: Dict[str, Any], body: str) -> str:
    """Serialize YAML frontmatter and Markdown body back into a single string."""
    yaml_str = yaml.safe_dump(frontmatter, sort_keys=False, allow_unicode=True).strip()
    clean_body = body.lstrip("\r\n")
    return f"---\n{yaml_str}\n---\n\n{clean_body}"


def resolve_task_path(workspace_root: Path, task_arg: str) -> Path:
    """Resolve either a TASK-XXXX ID or a relative/absolute path to the task file."""
    candidate = Path(task_arg)
    if candidate.is_absolute() and candidate.exists():
        return candidate
    rel_candidate = workspace_root / candidate
    if rel_candidate.exists():
        return rel_candidate
    tasks_folder = workspace_root / TASKS_DIR
    if tasks_folder.exists():
        matches = sorted(tasks_folder.glob(f"{task_arg}*.md"))
        if matches:
            return matches[0]
    return workspace_root / TASKS_DIR / f"{task_arg}.md"


def validate_task(
    workspace_root: Path,
    task_arg: str,
    registry_rel_path: Path = DEFAULT_REGISTRY_PATH,
    sync_state: bool = False,
    check_state: bool = False,
    check_boundary: bool = False,
) -> ResultEnvelope:
    """Validate a TASK-XXXX.md contract against schema, registry authority, and evidence gates."""
    issues: List[Issue] = []
    task_path = resolve_task_path(workspace_root, task_arg)

    if not task_path.exists():
        issues.append(Issue(
            code="ERR_TASK_FILE_NOT_FOUND", severity=Severity.ERROR,
            message=f"Task file for '{task_arg}' not found at '{task_path}'.",
            location=task_arg, fixable_by=FixableBy.AI,
            suggested_action="Create the task contract in docs/agent-system/tasks/ using plan-task skill.",
        ))
        return ResultEnvelope(success=False, tool="validate_task", issues=issues)

    rel_task_path = task_path.relative_to(workspace_root).as_posix()
    try:
        raw_fm, _ = parse_task_markdown(task_path)
        contract = TaskContract.model_validate(raw_fm)
    except (ValueError, yaml.YAMLError, ValidationError) as exc:
        issues.append(Issue(
            code="ERR_TASK_SCHEMA_INVALID", severity=Severity.ERROR,
            message=f"Task contract validation failed: {exc}",
            location=rel_task_path, fixable_by=FixableBy.AI,
            suggested_action="Ensure all required TaskContract YAML frontmatter fields are valid.",
        ))
        return ResultEnvelope(success=False, tool="validate_task", issues=issues)

    reg_path = workspace_root / registry_rel_path
    if not reg_path.exists():
        issues.append(Issue(
            code="ERR_REG_FILE_NOT_FOUND", severity=Severity.ERROR,
            message=f"Reference registry missing at '{registry_rel_path.as_posix()}'.",
            location=rel_task_path, fixable_by=FixableBy.AI,
        ))
        return ResultEnvelope(success=False, tool="validate_task", issues=issues)

    try:
        registry = ReferenceRegistry.model_validate(json.loads(reg_path.read_text(encoding="utf-8")))
    except (json.JSONDecodeError, ValidationError) as exc:
        issues.append(Issue(
            code="ERR_REG_SCHEMA_INVALID", severity=Severity.ERROR,
            message=f"Cannot validate task references; registry is invalid: {exc}",
            location=registry_rel_path.as_posix(), fixable_by=FixableBy.AI,
        ))
        return ResultEnvelope(success=False, tool="validate_task", issues=issues)

    reg_map = {e.id: e for e in registry.entries}
    for ref_id in contract.references:
        if ref_id not in reg_map:
            issues.append(Issue(
                code="ERR_TASK_UNKNOWN_REF", severity=Severity.ERROR,
                message=f"Task references unregistered ID '{ref_id}'.",
                location=rel_task_path, fixable_by=FixableBy.AI,
                suggested_action=f"Register '{ref_id}' in reference-registry.json or remove it from references.",
                evidence={"task_id": contract.id, "ref_id": ref_id},
            ))
            continue

        entry = reg_map[ref_id]
        ref_file = workspace_root / entry.path
        if not ref_file.exists():
            issues.append(Issue(
                code="ERR_TASK_BROKEN_REF_PATH", severity=Severity.ERROR,
                message=f"Reference '{ref_id}' points to missing file '{entry.path}'.",
                location=rel_task_path, fixable_by=FixableBy.AI,
                evidence={"ref_id": ref_id, "path": entry.path},
            ))
        if contract.status in GATED_STATUSES:
            if entry.authority != Authority.APPROVED:
                issues.append(Issue(
                    code="ERR_TASK_UNAPPROVED_REF", severity=Severity.ERROR,
                    message=f"Task '{contract.id}' in status '{contract.status.value}' cannot depend on reference '{ref_id}' with authority='{entry.authority.value}' (must be 'approved').",
                    location=rel_task_path, fixable_by=FixableBy.HUMAN,
                    suggested_action="Transition task to 'blocked' and request human approval for the reference.",
                    evidence={"ref_id": ref_id, "authority": entry.authority.value},
                ))
            if entry.status != RefStatus.CURRENT:
                issues.append(Issue(
                    code="ERR_TASK_STALE_REF", severity=Severity.ERROR,
                    message=f"Task '{contract.id}' in status '{contract.status.value}' cannot depend on reference '{ref_id}' with status='{entry.status.value}' (must be 'current').",
                    location=rel_task_path, fixable_by=FixableBy.HUMAN,
                    suggested_action="Update stale/superseded documentation before executing task.",
                    evidence={"ref_id": ref_id, "status": entry.status.value},
                ))

    # Anti-Self-Grading Gate: verified/approved requires valid EvidenceReceipt
    if contract.status in {TaskStatus.VERIFIED, TaskStatus.APPROVED}:
        if not contract.evidence_receipt:
            issues.append(Issue(
                code="ERR_TASK_MISSING_RECEIPT", severity=Severity.ERROR,
                message=f"Task '{contract.id}' is marked '{contract.status.value}' without an evidence_receipt.",
                location=rel_task_path, fixable_by=FixableBy.SCRIPT,
                suggested_action=f"Run 'python scripts/agent/run_verify.py --task {contract.id}'.",
            ))
        else:
            receipt_path = workspace_root / contract.evidence_receipt
            if not receipt_path.exists():
                issues.append(Issue(
                    code="ERR_TASK_RECEIPT_NOT_FOUND", severity=Severity.ERROR,
                    message=f"Evidence receipt '{contract.evidence_receipt}' does not exist.",
                    location=rel_task_path, fixable_by=FixableBy.SCRIPT,
                    suggested_action=f"Run 'python scripts/agent/run_verify.py --task {contract.id}'.",
                ))
            else:
                try:
                    receipt = EvidenceReceipt.model_validate(json.loads(receipt_path.read_text(encoding="utf-8")))
                    if receipt.task_id != contract.id or not receipt.all_passed or not receipt.scope_passed:
                        issues.append(Issue(
                            code="ERR_TASK_INVALID_RECEIPT", severity=Severity.ERROR,
                            message="Evidence receipt indicates failed checks or mismatched task_id.",
                            location=contract.evidence_receipt, fixable_by=FixableBy.SCRIPT,
                            suggested_action=f"Fix failing checks and re-run 'run_verify.py --task {contract.id}'.",
                        ))
                except (json.JSONDecodeError, ValidationError) as exc:
                    issues.append(Issue(
                        code="ERR_TASK_CORRUPT_RECEIPT", severity=Severity.ERROR,
                        message=f"Evidence receipt schema invalid: {exc}",
                        location=contract.evidence_receipt, fixable_by=FixableBy.SCRIPT,
                    ))

    contract_hash = compute_file_sha256(task_path)
    state_file = workspace_root / DEFAULT_STATE_PATH

    if check_state and state_file.exists():
        try:
            pointer = ActiveTaskPointer.model_validate(json.loads(state_file.read_text(encoding="utf-8")))
            if pointer.active_task_id == contract.id and pointer.contract_sha256 != contract_hash:
                issues.append(Issue(
                    code="ERR_STATE_DRIFT", severity=Severity.ERROR,
                    message="active-task.json is out of sync with TASK-*.md (SHA-256 mismatch).",
                    location=DEFAULT_STATE_PATH.as_posix(), fixable_by=FixableBy.SCRIPT,
                    suggested_action=f"Run 'python scripts/agent/validate_task.py --task {contract.id} --sync-state'.",
                ))
        except (json.JSONDecodeError, ValidationError) as exc:
            issues.append(Issue(
                code="ERR_STATE_SCHEMA", severity=Severity.ERROR,
                message=f"active-task.json is corrupt: {exc}",
                location=DEFAULT_STATE_PATH.as_posix(), fixable_by=FixableBy.SCRIPT,
            ))

    if (sync_state or check_boundary) and not any(i.severity == Severity.ERROR for i in issues):
        prior_issues = check_prior_work(workspace_root, contract)
        issues.extend(prior_issues)

    has_err = any(i.severity == Severity.ERROR for i in issues)
    if sync_state and not has_err:
        state_file.parent.mkdir(parents=True, exist_ok=True)
        pointer = ActiveTaskPointer(
            active_task_id=contract.id,
            status=contract.status,
            current_checkpoint=contract.current_checkpoint,
            contract_path=rel_task_path,
            contract_sha256=contract_hash,
            updated_at=datetime.now(timezone.utc).isoformat(),
        )
        state_file.write_text(
            json.dumps(pointer.model_dump(mode="json"), indent=2, ensure_ascii=False) + "\n",
            encoding="utf-8",
        )

    return ResultEnvelope(
        success=not has_err,
        tool="validate_task",
        issues=issues,
        data={
            "task_id": contract.id,
            "status": contract.status.value,
            "contract_path": rel_task_path,
            "contract_sha256": contract_hash,
            "state_synced": bool(sync_state and not has_err),
        },
    )


def check_prior_work(workspace_root: Path, current: TaskContract) -> List[Issue]:
    """Block execution if prior work is unapproved (single-task or milestone mode)."""
    issues: List[Issue] = []
    tasks_dir = workspace_root / TASKS_DIR
    if not tasks_dir.exists():
        return issues
    for path in sorted(tasks_dir.glob("TASK-*.md")):
        if path.name.startswith(current.id):
            continue
        try:
            raw_fm, _ = parse_task_markdown(path)
            other = TaskContract.model_validate(raw_fm)
        except Exception:
            continue

        if current.phase is not None:
            if other.phase is not None and other.phase != current.phase:
                if other.id < current.id and other.status != TaskStatus.APPROVED:
                    issues.append(Issue(
                        code="ERR_PRIOR_WORK_UNAPPROVED",
                        severity=Severity.ERROR,
                        message=f"Prior phase task '{other.id}' (phase={other.phase}) is '{other.status.value}', expected 'approved'.",
                        location=path.relative_to(workspace_root).as_posix(),
                        fixable_by=FixableBy.HUMAN,
                        suggested_action=f"Approve prior phase using 'validate_task.py --approve --phase {other.phase}'.",
                    ))
                    break
        else:
            if other.id < current.id and other.status != TaskStatus.APPROVED:
                issues.append(Issue(
                    code="ERR_PRIOR_WORK_UNAPPROVED",
                    severity=Severity.ERROR,
                    message=f"Prior task '{other.id}' is '{other.status.value}', expected 'approved'.",
                    location=path.relative_to(workspace_root).as_posix(),
                    fixable_by=FixableBy.HUMAN,
                    suggested_action=f"Approve prior task using 'validate_task.py --approve --task {other.id}'.",
                ))
                break
    return issues


def approve_tasks(
    workspace_root: Path,
    task_arg: Optional[str] = None,
    phase_arg: Optional[str] = None,
) -> ResultEnvelope:
    """Transition verified tasks with valid evidence receipts to approved."""
    issues: List[Issue] = []
    tasks_dir = workspace_root / TASKS_DIR
    approved: List[str] = []
    if not tasks_dir.exists():
        return ResultEnvelope(success=False, tool="approve_tasks", issues=[Issue(code="ERR_NO_TASKS", severity=Severity.ERROR, message="Tasks directory missing.")])

    for path in sorted(tasks_dir.glob("TASK-*.md")):
        raw_fm, body = parse_task_markdown(path)
        tid = raw_fm.get("id")
        t_phase = raw_fm.get("phase")
        if (task_arg and tid != task_arg) or (phase_arg and t_phase != phase_arg):
            continue
        if raw_fm.get("status") != TaskStatus.VERIFIED.value:
            if task_arg:
                issues.append(Issue(code="ERR_APPROVE_NOT_VERIFIED", severity=Severity.ERROR, message=f"Task '{tid}' is '{raw_fm.get('status')}', not 'verified'."))
            continue
        receipt = workspace_root / (raw_fm.get("evidence_receipt") or "")
        if not receipt.exists():
            issues.append(Issue(code="ERR_APPROVE_RECEIPT_MISSING", severity=Severity.ERROR, message=f"Evidence receipt missing for '{tid}'."))
            continue
        raw_fm["status"] = TaskStatus.APPROVED.value
        raw_fm["current_checkpoint"] = "CP-APPROVED"
        path.write_text(render_task_markdown(raw_fm, body), encoding="utf-8")
        approved.append(tid)

    has_err = any(i.severity == Severity.ERROR for i in issues)
    return ResultEnvelope(
        success=not has_err and bool(approved),
        tool="approve_tasks",
        issues=issues,
        data={"approved": approved, "count": len(approved)},
    )


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Validate TASK-XXXX.md contract, sync state, or approve verified tasks.")
    parser.add_argument("--root", type=Path, default=ROOT_DIR, help="Workspace root directory")
    parser.add_argument("--task", default=None, help="Task ID (e.g. TASK-0001) or path to task markdown")
    parser.add_argument("--phase", default=None, help="Phase identifier (e.g. P1, P2) for batch operations")
    parser.add_argument("--approve", action="store_true", help="Approve verified task(s) to approved status")
    parser.add_argument("--registry", type=Path, default=DEFAULT_REGISTRY_PATH, help="Relative path to registry JSON")
    parser.add_argument("--sync-state", action="store_true", help="Write/update docs/agent-system/state/active-task.json")
    parser.add_argument("--check-state", action="store_true", help="Verify active-task.json matches task contract")
    parser.add_argument("--check-boundary", action="store_true", help="Check that prior work is approved")
    args = parser.parse_args(argv)

    root = args.root.resolve()
    if args.approve:
        res = approve_tasks(root, task_arg=args.task, phase_arg=args.phase)
    elif args.task:
        res = validate_task(
            workspace_root=root,
            task_arg=args.task,
            registry_rel_path=args.registry,
            sync_state=args.sync_state,
            check_state=args.check_state,
            check_boundary=args.check_boundary,
        )
    else:
        parser.error("Either --task or --approve with --phase is required.")
    print(json.dumps(res.model_dump(mode="json"), indent=2, ensure_ascii=False))
    return res.exit_code


if __name__ == "__main__":
    sys.exit(main())
