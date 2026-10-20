"""
Deterministic Verification Gatekeeper (scripts/agent/run_verify.py).
Closes the LLM Self-Grading loophole: validates registry & task contract, runs Git Scope Guard,
executes verification_commands, writes tamper-evident EvidenceReceipt, and unlocks status='verified'.
"""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
import subprocess
import sys
import time
from pathlib import Path
from typing import List, Optional

ROOT_DIR = Path(__file__).resolve().parents[2]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from scripts.agent.check_diff_guard import check_diff_guard
from scripts.agent.check_line_budget import (
    DEFAULT_CONFIG_PATH,
    approved_exception_paths,
    check_cohesion_notes,
    check_line_budget,
    is_budgeted_file,
    load_project_config,
)
from scripts.agent.check_scope import check_scope
from scripts.agent.models import (
    ActiveTaskPointer,
    CommandReceipt,
    EvidenceReceipt,
    FixableBy,
    Issue,
    ResultEnvelope,
    Severity,
    TaskContract,
    TaskStatus,
    compute_file_sha256,
)
from scripts.agent.validate_registry import DEFAULT_REGISTRY_PATH, validate_registry
from scripts.agent.validate_task import (
    parse_task_markdown,
    render_task_markdown,
    resolve_task_path,
    validate_task,
)

EVIDENCE_DIR = Path("docs/agent-system/evidence")
MAX_EXCERPT_CHARS = 1500


def _truncate(text: str, limit: int = MAX_EXCERPT_CHARS) -> str:
    clean = text.strip()
    if len(clean) <= limit:
        return clean
    return clean[:limit] + f"\n...[truncated {len(clean) - limit} chars]"


def _run_budget_gates(
    workspace_root: Path,
    contract: TaskContract,
    body: str,
    modified_files: List[str],
) -> List[Issue]:
    """Line budget, cohesion note and diff guard checks (ADR-ARCH-010). Skipped if project is unconfigured."""
    if not (workspace_root / DEFAULT_CONFIG_PATH).exists():
        return [Issue(
            code="INFO_LBUD_GATE_SKIPPED", severity=Severity.INFO,
            message="Line budget gate skipped: docs/agent-system/project-config.json not found.",
            location=DEFAULT_CONFIG_PATH.as_posix(), fixable_by=FixableBy.HUMAN,
        )]
    budget_res = check_line_budget(workspace_root, contract.id, explicit_files=modified_files)
    issues: List[Issue] = list(budget_res.issues)
    if not budget_res.data:
        return issues
    issues.extend(check_cohesion_notes(budget_res.data["files"], body))
    config = load_project_config(workspace_root)
    targets = [f for f in modified_files if is_budgeted_file(f, config, workspace_root)]
    issues.extend(check_diff_guard(
        workspace_root, targets, config.line_budget.diff_guard, approved_exception_paths(contract),
    ))
    return issues


def run_verify(
    workspace_root: Path,
    task_arg: str,
    registry_rel_path: Path = DEFAULT_REGISTRY_PATH,
    explicit_files: Optional[List[str]] = None,
) -> ResultEnvelope:
    """Execute deterministic verification pipeline and gate transition to 'verified'."""
    issues: List[Issue] = []

    # 1. Validate Reference Registry & Context Budget
    reg_res = validate_registry(workspace_root, registry_rel_path, check_context=True)
    issues.extend(reg_res.issues)
    if not reg_res.success:
        return ResultEnvelope(success=False, tool="run_verify", issues=issues)

    # 2. Resolve and parse Task Contract
    task_path = resolve_task_path(workspace_root, task_arg)
    if not task_path.exists():
        issues.append(Issue(
            code="ERR_TASK_FILE_NOT_FOUND",
            severity=Severity.ERROR,
            message=f"Task contract '{task_arg}' not found.",
            location=task_arg,
            fixable_by=FixableBy.AI,
        ))
        return ResultEnvelope(success=False, tool="run_verify", issues=issues)

    rel_task_path = task_path.relative_to(workspace_root).as_posix()
    raw_fm, body = parse_task_markdown(task_path)

    # Anti-Self-Grading Gate: ensure task is in ready status
    if raw_fm.get("status") != TaskStatus.READY.value:
        issues.append(Issue(
            code="ERR_VERIFY_NOT_SYNCED_READY",
            severity=Severity.ERROR,
            message=(
                f"Task '{task_arg}' is in status '{raw_fm.get('status')}', expected '{TaskStatus.READY.value}'. "
                "Tasks must start in status 'ready' and be synced in active-task.json before verification."
            ),
            location=rel_task_path,
            fixable_by=FixableBy.AI,
            suggested_action="Keep status as 'ready' and sync with 'validate_task.py --task <ID> --sync-state'.",
        ))
        return ResultEnvelope(success=False, tool="run_verify", issues=issues)

    # Ready-First Enforcement: check docs/agent-system/state/active-task.json
    state_path = workspace_root / "docs/agent-system/state/active-task.json"
    if not state_path.exists():
        issues.append(Issue(
            code="ERR_VERIFY_NOT_SYNCED_READY",
            severity=Severity.ERROR,
            message=f"active-task.json is missing. Task '{task_arg}' must be synced in status 'ready' before verification.",
            location="docs/agent-system/state/active-task.json",
            fixable_by=FixableBy.SCRIPT,
            suggested_action=f"Run 'python scripts/agent/validate_task.py --task {task_arg} --sync-state'.",
        ))
        return ResultEnvelope(success=False, tool="run_verify", issues=issues)

    try:
        pointer = ActiveTaskPointer.model_validate(json.loads(state_path.read_text(encoding="utf-8")))
        current_hash = compute_file_sha256(task_path)
        if pointer.active_task_id != raw_fm.get("id") or pointer.status != TaskStatus.READY or pointer.contract_sha256 != current_hash:
            issues.append(Issue(
                code="ERR_VERIFY_NOT_SYNCED_READY",
                severity=Severity.ERROR,
                message=(
                    f"active-task.json pointer ({pointer.active_task_id}, status={pointer.status.value}) "
                    f"does not match task '{raw_fm.get('id')}' in status 'ready' with matching sha256."
                ),
                location="docs/agent-system/state/active-task.json",
                fixable_by=FixableBy.SCRIPT,
                suggested_action=f"Run 'python scripts/agent/validate_task.py --task {raw_fm.get('id')} --sync-state'.",
            ))
            return ResultEnvelope(success=False, tool="run_verify", issues=issues)
    except Exception as exc:
        issues.append(Issue(
            code="ERR_VERIFY_NOT_SYNCED_READY",
            severity=Severity.ERROR,
            message=f"Failed to validate active-task.json: {exc}",
            location="docs/agent-system/state/active-task.json",
            fixable_by=FixableBy.SCRIPT,
        ))
        return ResultEnvelope(success=False, tool="run_verify", issues=issues)

    task_res = validate_task(workspace_root, task_arg, registry_rel_path, sync_state=False, check_boundary=True)
    issues.extend(task_res.issues)
    if not task_res.success:
        return ResultEnvelope(success=False, tool="run_verify", issues=issues)

    contract = TaskContract.model_validate(raw_fm)

    # 3. Run Git Scope Guard
    scope_res = check_scope(workspace_root, task_arg, explicit_files=explicit_files)
    issues.extend(scope_res.issues)
    scope_passed = scope_res.success
    diff_sha256 = str(scope_res.data.get("diff_sha256", ""))
    modified_files = list(scope_res.data.get("evaluated_files", []))

    # 3b. Line budget, cohesion note and post-hoc diff guard (ADR-ARCH-010)
    issues.extend(_run_budget_gates(workspace_root, contract, body, modified_files))

    # 4. Execute verification_commands deterministically
    cmd_receipts: List[CommandReceipt] = []
    all_cmds_passed = True

    for cmd in contract.verification_commands:
        t0 = time.perf_counter()
        try:
            proc = subprocess.run(
                cmd,
                cwd=str(workspace_root),
                shell=True,
                capture_output=True,
                text=True,
                check=False,
                timeout=120,
            )
            exit_code = proc.returncode
            stdout_ex = _truncate(proc.stdout)
            stderr_ex = _truncate(proc.stderr)
        except subprocess.TimeoutExpired:
            exit_code = 124
            stdout_ex = ""
            stderr_ex = "Command timed out after 120 seconds."
        duration_ms = round((time.perf_counter() - t0) * 1000.0, 2)

        cmd_receipts.append(CommandReceipt(
            command=cmd,
            exit_code=exit_code,
            duration_ms=duration_ms,
            stdout_excerpt=stdout_ex,
            stderr_excerpt=stderr_ex,
        ))
        if exit_code != 0:
            all_cmds_passed = False
            issues.append(Issue(
                code="ERR_VERIFY_CMD_FAILED",
                severity=Severity.ERROR,
                message=f"Verification command failed with exit code {exit_code}: {cmd}",
                location=rel_task_path,
                fixable_by=FixableBy.AI,
                suggested_action="Inspect stderr_excerpt, apply at most 1 fix attempt, and re-run run_verify.py.",
                evidence={"command": cmd, "exit_code": exit_code, "stderr": stderr_ex, "stdout": stdout_ex},
            ))

    all_passed = scope_passed and all_cmds_passed and not any(i.severity == Severity.ERROR for i in issues)
    receipt_rel_path = (EVIDENCE_DIR / f"{contract.id}-receipt.json").as_posix()
    receipt_full_path = workspace_root / receipt_rel_path
    receipt_full_path.parent.mkdir(parents=True, exist_ok=True)

    if all_passed:
        raw_fm["status"] = TaskStatus.VERIFIED.value
        raw_fm["current_checkpoint"] = "CP-VERIFIED"
        raw_fm["evidence_receipt"] = receipt_rel_path
        task_path.write_text(render_task_markdown(raw_fm, body), encoding="utf-8")

    contract_sha256 = compute_file_sha256(task_path)
    receipt = EvidenceReceipt(
        task_id=contract.id,
        verified_at=datetime.now(timezone.utc).isoformat(),
        contract_sha256=contract_sha256,
        diff_sha256=diff_sha256,
        modified_files=modified_files,
        scope_passed=scope_passed,
        commands=cmd_receipts,
        all_passed=all_passed,
    )
    receipt_full_path.write_text(
        json.dumps(receipt.model_dump(mode="json"), indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )

    if all_passed:
        validate_task(workspace_root, task_arg, registry_rel_path, sync_state=True)

    return ResultEnvelope(
        success=all_passed,
        tool="run_verify",
        issues=issues,
        data={
            "task_id": contract.id,
            "new_status": TaskStatus.VERIFIED.value if all_passed else contract.status.value,
            "evidence_receipt": receipt_rel_path,
            "diff_sha256": diff_sha256,
            "commands_run": len(cmd_receipts),
            "all_passed": all_passed,
        },
    )


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Run deterministic verification gate for a Task Contract.")
    parser.add_argument("--root", type=Path, default=ROOT_DIR, help="Workspace root directory")
    parser.add_argument("--task", required=True, help="Task ID (e.g. TASK-0001) or path to task markdown")
    parser.add_argument("--registry", type=Path, default=DEFAULT_REGISTRY_PATH, help="Relative path to registry JSON")
    args = parser.parse_args(argv)

    res = run_verify(
        workspace_root=args.root.resolve(),
        task_arg=args.task,
        registry_rel_path=args.registry,
    )
    print(json.dumps(res.model_dump(mode="json"), indent=2, ensure_ascii=False))
    return res.exit_code


if __name__ == "__main__":
    sys.exit(main())
