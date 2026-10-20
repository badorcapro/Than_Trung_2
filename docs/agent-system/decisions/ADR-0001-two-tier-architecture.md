# ADR-0001: Two-Tier Architecture (Core Engine + Pluggable Domain Profiles)

- **Reference ID**: `ADR-ARCH-001`
- **Status**: `approved`
- **Date**: `2026-10-19`
- **Depends On**: `ARCH-CORE-001`, `PLAN-CORE-001`

---

## 1. Context
The system must generalize across Software, Semiconductor/Hardware (RTL/IC), and systems engineering without bloated monolithic rules or duplicate orchestration frameworks.

## 2. Decision
Adopt a 2-Tier Architecture:
1. **Tier 1 (Core Engine)**: Domain-agnostic invariants (`AGENTS.md`), task contract schemas, progressive disclosure core skills (`project-bootstrap`, `plan-task`, `execute-task`, `verify-task`), and deterministic verification scripts.
2. **Tier 2 (Pluggable Domain Profiles)**: Domain-specific task contract templates, verification checklists, and `trigger: glob` rules (`profiles/software/`, `profiles/semiconductor-hardware/`).

## 3. Consequences
- **Positive**: Core governance engine is reusable across any engineering discipline with zero domain-specific clutter.
- **Negative**: Starting a project in a new domain requires authoring a domain profile pack (`rule_*_standards.md` + `TASK-TEMPLATE-*.md`).
