---
name: verify-task
description: Run Subagent Semantic Peer-Audit (check_peer_audit.py) and deterministic verification commands + Git Scope Guard via scripts/agent/run_verify.py to generate tamper-evident evidence receipts and transition task status to verified.
---

# Skill: Verify Task via Subagent Semantic Peer-Audit & Deterministic Gatekeepers

> **Purpose**: Bridge the gap between deterministic algorithmic gates (`scripts/agent/*.py`) and probabilistic LLM drift by requiring an independent Subagent Peer-Audit (`TASK-XXXX-peer-audit.json`) before `run_verify.py` can unlock `status: verified`.  
> **Companion Rules**: See [rule_task_contract_and_scope.md](../../rules/rule_task_contract_and_scope.md), [rule_anti_evasion.md](../../rules/rule_anti_evasion.md), and [rule_critical_engagement.md](../../rules/rule_critical_engagement.md).

---

## 1. When to Use
- After completing implementation and unit tests for a `ready` task, **before** attempting to transition the task to `verified`.
- Auditing whether a task meets both syntactic/algorithmic gates AND semantic completeness (no truncated logic, no code-golfing to dodge ADR-0010 line limits, no hidden shortcuts).

---

## 2. Step-by-Step Verification Workflow

### Step 1: Record Thought/Decision Handover & Sync Task State
1. In `docs/agent-system/tasks/TASK-XXXX.md` (and `.agent_scratchpad.md`), document your **`## Implementation & Decision Log`**:
   - `decisions_made`: Architectural choices and trade-offs made during this turn.
   - `omissions_and_simplifications`: Any edge cases, syntax patterns, or requirements simplified or omitted (or explicit confirmation of 100% coverage).
   - `adr_0010_modularization_check`: How line budgets were respected (Single Responsibility Modularization vs any compression).
2. Synchronize `active-task.json` and compute the live `diff_sha256`:
   ```powershell
   python scripts/agent/validate_task.py --task TASK-XXXX --sync-state
   python scripts/agent/check_scope.py --task TASK-XXXX
   ```

### Step 2: Spawn an Independent Peer-Auditor Subagent (MANDATORY)
- **NEVER** write `docs/agent-system/evidence/TASK-XXXX-peer-audit.json` yourself.
- Invoke an independent Subagent (`invoke_subagent` with `TypeName: "self"`, `Role: "Peer Auditor for TASK-XXXX"`) and pass:
  1. **Workspace Root & Branch**: Exact path and active branch.
  2. **Live `diff_sha256`**: From `check_scope.py --task TASK-XXXX`.
  3. **Primary Agent Thought/Decision Log & `transcript.jsonl` Path**: So the Subagent can cross-examine your reasoning, tool calls, and decisions against the actual code diff.
  4. **Mandatory Context Files to Read & Verify**:
     - `GEMINI.md`
     - `AGENTS.md`
     - `ARCHITECTURE.md` (specifically ADR-0010 Single Responsibility Modularization)
     - `.agents/rules/rule_anti_evasion.md`
     - `.agents/rules/rule_critical_engagement.md`
     - `.agents/rules/rule_task_contract_and_scope.md`
     - `.agents/skills/verify-task/SKILL.md`
     - `.agents/skills/critical-engagement/SKILL.md`
     - `.agents/skills/honest-execution/SKILL.md`
     - `docs/agent-system/tasks/TASK-XXXX.md` and its declared `references`.
  5. **Subagent Deliverable**:
     - Perform both deterministic script execution AND semantic / edge-case inspection on real data.
     - Verify zero code-golfing (`;`), zero placeholder truncation, and genuine ADR-0010 modularization (warn: 800, hard: 1000 LOC).
     - **Mandatory Trade-off Interrogation**: The Subagent MUST actively cross-examine the Primary Agent's transcript, tool calls, and decisions for ANY hidden trade-offs, scope shortcuts, logic simplifications, or deferred branches. In its completion message returned to the Primary Agent, the Subagent must explicitly list all detected trade-offs and demand that if any trade-offs exist, the Primary Agent MUST surface and report them directly to the human user before final delivery.
     - Write `docs/agent-system/evidence/TASK-XXXX-peer-audit.json` conforming to `PeerAuditReceipt` in `scripts/agent/models.py`:
       - `verdict`: `"PASS"` or `"FAIL"` (`CONDITIONAL PASS` is forbidden; any defect requires `"FAIL"`).
       - `findings`: Must be `[]` when `verdict` is `"PASS"`.
     - Run `python scripts/agent/check_peer_audit.py --task TASK-XXXX` to confirm exit code `0`.

### Step 3: Run the Deterministic Verification Gatekeeper (`run_verify.py`)
- Once the Subagent reports `verdict: "PASS"` and `check_peer_audit.py` passes:
  ```powershell
  python scripts/agent/run_verify.py --task TASK-XXXX
  ```
- **Note**: Any edit to an `in_scope` file after the Subagent audit changes `diff_sha256` and invalidates `TASK-XXXX-peer-audit.json` (`ERR_PEER_AUDIT_DIFF_STALE`), requiring a fresh Subagent re-audit.

### Step 4: Handle Failures (Fail-Closed 1-Fix Protocol)
- If either the Peer-Auditor Subagent or `run_verify.py` reports a failure:
  - Apply at most **1 fix attempt** within `in_scope`.
  - Re-sync state, have the Subagent re-verify the new `diff_sha256` and update `TASK-XXXX-peer-audit.json`, then re-run `run_verify.py`.
  - If the failure persists after 1 fix attempt, **STOP immediately** and escalate to the user.

### Step 5: Refresh Registry Hashes (If Tracked Artifacts Changed)
```powershell
python scripts/agent/validate_registry.py --update-hashes
```
