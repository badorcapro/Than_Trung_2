# ADR-0010: Role-Based Configurable Line Budgets

- **Reference ID**: `ADR-ARCH-010`
- **Status**: `approved`
- **Date**: `2026-10-19`
- **Depends On**: `ARCH-CORE-001`, `PLAN-CORE-001`, `ADR-ARCH-005`, `ADR-ARCH-009`

---

## 1. Context
The repository enforced a single hard cap of 400 lines per file. Cohesive units (RTL modules, state machines, parsers) legitimately exceed that, and splitting them creates shotgun surgery. The cap exists for a different reason: LLM agents truncate or mis-edit large files. The cap conflated a product-quality judgment with an agent-safety control.

## 2. Decision
1. **Role-first classification.** A file's budget is determined by its role (`core_engine`, `domain_logic`, `ui_component`, `test`, `rtl`, `testbench`, `generated`), not by product type. Product type is a *profile* that overrides thresholds for some roles.
2. **Deterministic role assignment.** Roles come only from the ordered `role_map` (first match wins) plus `default_role` in `docs/agent-system/project-config.json`. Agents must not assign roles ad hoc. Editing `project-config.json` is a human-reviewed change.
3. **Three tiers per role** (counted in non-empty lines, one shared counting function):
   - `warn`: the agent records a cohesion note in the task body.
   - `review`: a cohesion note plus a human-approved exception is required to pass verification.
   - `hard`: fails verification unless an exception with `approved_by` exists.
4. **Generated code is exempt** (`generated` role, `exempt: true`).
5. **Exceptions** are declared in the task contract as `line_budget_exceptions: [{path, reason, approved_by}]`.
6. **Core Engine stays strict**: `scripts/agent/**` keeps `hard: 400`, because agents maintain their own gatekeepers.
7. **Large-file protocol (slice-first).** Agents read and edit large files in narrow line ranges, not whole-file read/write.
8. **Post-hoc diff guard** in `run_verify.py` (TASK-0015): flags truncation placeholders in added lines, net deletions above `max_net_deleted_lines`, and hunks above `max_hunk_lines`.

## 3. Consequences
- **Positive**: Cohesive large files are allowed with human sign-off; agent-safety controls are decoupled from product quality judgments.
- **Negative / limits**:
  - Scripts cannot measure cohesion. The cohesion note is only checked for presence of fields, not content; judgment stays with the human reviewer.
  - Scripts cannot intercept the agent's read/edit tool calls; slice-first is guidance, and only the resulting git diff is checked. A truncation that avoids placeholders and stays under the thresholds is not detected.
  - `approved_by` cannot be proven to be human-written by a script; the control is phase-level human review of contract diffs.
  - Threshold values are initial settings, not industry standards, and are expected to be tuned per project.
- **Implementation split**: TASK-0013 (data layer), TASK-0014 (`check_line_budget.py`), TASK-0015 (`run_verify.py` integration).

## 4. Amendments
### DEC-AMEND-01 (2026-10-22): Unified Higher Thresholds (Warn: 800, Hard: 1000) & Anti-Silent-Tradeoff Protocol
- **Rationale**: Strict 300/400 line limits inadvertently incentivized agents to simplify, truncate, or defer essential game logic and architectural constraints into artificial "trade-offs".
- **Resolution**:
  1. Updated `project-config.json` software profiles to `warn: 800`, `review: 900`, `hard: 1000` across all roles.
  2. Updated `rule_critical_engagement.md` and `check_docs.py` to align with the 1000-line hard cap (warn: 800).
  3. Mandated that Subagents during peer-audit must explicitly cross-examine the Primary Agent for ANY architectural/implementation trade-offs or simplifications, and require them to be surfaced to the user before final verification.
