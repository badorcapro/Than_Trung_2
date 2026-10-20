---
name: verify-task
description: Run deterministic verification commands and Git Scope Guard via scripts/agent/run_verify.py to generate a tamper-evident evidence receipt and transition task status to verified.
---

# Skill: Verify Task & Generate Tamper-Evident Evidence

> **Purpose**: Execute deterministic quality gates and produce verifiable completion receipts without LLM self-grading.  
> **Companion Rules**: See [rule_task_contract_and_scope.md](../../rules/rule_task_contract_and_scope.md) and [rule_anti_evasion.md](../../rules/rule_anti_evasion.md).

---

## 1. When to Use
- After completing implementation and unit tests for an `in_progress` or `implemented` task.
- Auditing whether a task meets all acceptance criteria and scope constraints before human sign-off.

---

## 2. Step-by-Step Workflow

1. **Run the Deterministic Verification Gatekeeper**:
   - **NEVER** manually write files in `docs/agent-system/evidence/` or manually set `status: verified`.
   - Execute:
   ```powershell
   python scripts/agent/run_verify.py --task TASK-XXXX
   ```
   - *Success Signal*: JSON output shows `"success": true`, `"all_passed": true`, `"new_status": "verified"`, and writes `docs/agent-system/evidence/TASK-XXXX-receipt.json` (exit code `0`).
   - *Failure Signal*: Exit code `2` with `ERR_VERIFY_CMD_FAILED` or `ERR_SCOPE_VIOLATION`.

2. **Handle Verification Failures (Fail-Closed Protocol)**:
   - If `run_verify.py` fails, inspect the `issues` array in the JSON output.
   - Attempt a **maximum of 1 fix** within `in_scope` and re-run `python scripts/agent/run_verify.py --task TASK-XXXX`.
   - If the failure persists after 1 fix attempt, **STOP immediately**, report the verbatim command and error excerpt to the user, and await instructions.

3. ** Refresh Registry Hashes (If Tracked Artifacts Changed)**:
   - If the task legitimately updated a registered module or specification in `reference-registry.json`, refresh hashes and verify registry cleanliness:
   ```powershell
   python scripts/agent/validate_registry.py --update-hashes
   ```
