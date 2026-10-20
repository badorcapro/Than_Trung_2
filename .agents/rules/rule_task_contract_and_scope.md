---
trigger: model_decision
description: Task Execution Contract governance, in_scope file boundary enforcement, reference authority check, and anti-self-grading verification gate. Quản lý hợp đồng task TASK-XXXX.md, kiểm soát phạm vi in_scope, kiểm tra độ tin cậy reference, chống tự chấm điểm verified.
---

# Rule: Task Execution Contract & Scope Containment

> **Scope**: Applies to all task planning, implementation, and verification operations.  
> **Companion Architecture**: [ARCHITECTURE.md](../../ARCHITECTURE.md) (`ARCH-CORE-001`)

---

## 1. Mandatory Task Contract Invariants

1. **No Code Edits Without an Active Contract**:
   - Before modifying any source or test file, an active `docs/agent-system/tasks/TASK-XXXX.md` contract must exist in `ready` or `in_progress` status.
2. **Reference Authority Gate**:
   - Tasks in `ready` or higher status may only reference entries in `docs/agent-system/reference-registry.json` that have `authority: "approved"` and `status: "current"`.
   - If a required specification is `proposal`, `stale`, `superseded`, or missing, halt immediately, set task status to `blocked`, and escalate to the user.
3. **Strict Scope Containment (`in_scope` / `out_of_scope`)**:
   - Only files matching patterns in `in_scope` may be created or modified.
   - If discovering a dependency outside `in_scope`, do NOT edit it silently; run `python scripts/agent/check_impact.py --target <REF_ID>` and ask the user to approve expanding `in_scope`.
4. **Anti-Self-Grading Invariant**:
   - Never manually create/edit files inside `docs/agent-system/evidence/`.
   - Never manually set `status: verified` in `TASK-XXXX.md`.
   - Only `python scripts/agent/run_verify.py --task TASK-XXXX` is authorized to generate the tamper-evident receipt and transition the task to `verified`.
5. **Single Source of Truth State Sync**:
   - Never manually edit `docs/agent-system/state/active-task.json`. Always synchronize it via `python scripts/agent/validate_task.py --task TASK-XXXX --sync-state`.
