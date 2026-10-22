# ADR-0008: Controlled Bootstrap Exception & Gatekeeper Recursion Protocol

- **Reference ID**: `ADR-ARCH-008`
- **Status**: `approved`
- **Date**: `2026-10-19`
- **Depends On**: `ARCH-CORE-001`, `PLAN-CORE-001`

---

## 1. Context
Two recursive paradoxes occur when building an AI governance system:
1. **Bootstrap Paradox**: Foundational meta-documents (`master-plan.md`, `ADRs`, initial registry) cannot be governed by pre-existing task contracts because the governance engine does not exist yet.
2. **Gatekeeper Recursion**: When a task modifies `scripts/agent/*.py` (the gatekeeper engine), `run_verify.py` might be evaluated by the very script being changed, risking self-grading or circular failure.

## 2. Decision
1. **Bootstrap Exception**: Foundational architecture files (`ARCHITECTURE.md`, `docs/agent-system/master-plan.md`, `ADR-0001` to `ADR-0008`, `reference-registry.json`, `baseline-p1` commit) are authorized under a formal Bootstrap Exception. They are baseline records, not backfilled fake tasks.
2. **Gatekeeper Modification Protocol**:
   - Any task touching `scripts/agent/*.py` must declare `touches_gatekeeper: true` in its frontmatter.
   - Verification must be run against committed baseline tests.
   - Transition to `verified` requires human sign-off rather than purely autonomous state elevation.

## 3. Consequences
- **Positive**: Solves the circular causality problem honestly without fabricating historical task receipts.
