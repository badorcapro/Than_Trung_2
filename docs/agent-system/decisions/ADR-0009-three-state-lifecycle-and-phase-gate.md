# ADR-0009: Three-State Task Lifecycle & Mechanical Cross-Boundary Gate

- **Reference ID**: `ADR-ARCH-009`
- **Status**: `approved`
- **Date**: `2026-10-19`
- **Depends On**: `ARCH-CORE-001`, `PLAN-CORE-001`, `ADR-ARCH-003`, `ADR-ARCH-008`

---

## 1. Context
During the Phase P2 to Phase P3 transition, two structural governance flaws were exposed:
1. Task Execution Contracts (`TASK-0001` through `TASK-0008`) were created or committed directly in `status: verified`, bypassing deterministic runner checks.
2. Because `verified` was treated as the terminal state of a task, a mid-turn context compaction after `TASK-0005` (`P2.4`) caused the agent to assume Phase P2 was completely closed and autonomously begin executing Phase P3 (`TASK-0006`..`TASK-0008`) without human authorization.
3. Furthermore, vocabulary divergence existed across the codebase: ADRs, Registry, and Architecture specifications used `approved` for human governance sign-off, while TaskContracts used `accepted`.
4. Overfitting to a fixed `P1..P5` phase structure prevented general-use adoption by teams using single-task Kanban or custom release/sprint milestones.

## 2. Decision
1. **Unified 3-State Task Lifecycle (`ready` -> `verified` -> `approved`)**:
   - Standardize `TaskStatus` in `scripts/agent/models.py` to four states: `ready` (initial state), `verified` (deterministic test & scope receipt generated), `approved` (human sign-off), and `blocked` (halt condition). Remove dead states (`draft`, `in_progress`, `implemented`, `verifying`, `failed`).
   - Unify terminology so `approved` universally represents human governance sign-off across ADRs, reference registry, and task execution contracts.
2. **Ready-First Sync Enforcement (`ERR_VERIFY_NOT_SYNCED_READY`)**:
   - Every `TASK-XXXX.md` contract must be initialized on disk with `status: ready`, `current_checkpoint: CP-0-CONTRACT-READY`, and `evidence_receipt: null`.
   - `run_verify.py` strictly requires `docs/agent-system/state/active-task.json` to point to the target task in `status: ready` with a matching `contract_sha256` before executing verification commands. Creating a contract already marked `verified` or un-synced is rejected with exit code 2.
   - Upon verification success, `run_verify.py` transitions `status` from `ready` to `verified` and advances `current_checkpoint` to `CP-VERIFIED`.
3. **General-Use Cross-Boundary Gatekeeper (`ERR_PRIOR_WORK_UNAPPROVED`)**:
   - Add `phase: Optional[str] = None` to `TaskContract`.
     - In **Single-Task Mode** (`phase: null`): Only one standalone task can be in `verified` waiting for sign-off. Before starting a new standalone task, any prior unapproved task triggers `ERR_PRIOR_WORK_UNAPPROVED`.
     - In **Grouped/Milestone Mode** (`phase: "P3"` / `"SPRINT-1"`): The agent may execute tasks within the active group up to `verified`, but cannot sync or verify any task belonging to a subsequent group while prior work remains unapproved.
   - Provide `python scripts/agent/validate_task.py --approve [--task TASK-XXXX | --phase PX]` for explicit human-authorized sign-off.

## 3. Consequences
- **Positive**: Eliminates born-verified contract forgery, resolves vocabulary split-brain, and supports both Kanban and Phased/Milestone workflows.
- **Negative**: Requires explicit human approval (`--approve`) before boundary transitions.
