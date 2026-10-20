# ADR-0005: Strict Git Scope Guard & Normalized Evidence Receipts

- **Reference ID**: `ADR-ARCH-005`
- **Status**: `approved`
- **Date**: `2026-10-19`
- **Depends On**: `ARCH-CORE-001`

---

## 1. Context
LLMs frequently modify files outside the intended task boundary or dump megabytes of raw logs/simulation waveforms into git, causing repo bloat and silent regressions.

## 2. Decision
1. Implement `scripts/agent/check_scope.py` to compare `git status --porcelain -uall` against `TaskContract.in_scope` and `TaskContract.out_of_scope`.
2. Any out-of-scope modified/untracked file immediately aborts state transition to `verified`.
3. Only normalized JSON receipts (`TASK-XXXX-receipt.json` containing exit code, duration, diff SHA-256, and truncated excerpts) are stored in `docs/agent-system/evidence/`. Raw logs, `.vcd`, `.fsdb`, and `.bin` are gitignored.

## 3. Consequences
- **Positive**: Guarantees zero out-of-scope edits reach production; repository remains lean.
