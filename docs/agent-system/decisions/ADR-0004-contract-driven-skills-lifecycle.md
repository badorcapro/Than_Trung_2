# ADR-0004: Contract-Driven Progressive Disclosure Skills Lifecycle

- **Reference ID**: `ADR-ARCH-004`
- **Status**: `approved`
- **Date**: `2026-10-19`
- **Depends On**: `ARCH-CORE-001`

---

## 1. Context
We evaluated whether to create separate specialized skills for every domain (e.g. `software-plan`, `hardware-sim-verify`) or maintain a single invariant core skills lifecycle.

## 2. Decision
Adopt a **Contract-Driven Core Skills Lifecycle**:
- Core Skills (`project-bootstrap`, `plan-task`, `execute-task`, `verify-task`) manage invariant operational workflows (dependency lookup, scope validation, test execution, receipt generation).
- Domain differences are parameterized via Task Contracts (`verification_commands`, `in_scope`) and Domain Profile templates/checklists.

## 3. Consequences
- **Positive**: Skills remain concise, stable, and universal across all domains. Zero duplicated workflow logic.
- **Negative**: Task authoring requires selecting the appropriate domain template during the planning phase.
