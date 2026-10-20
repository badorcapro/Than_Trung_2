# ADR-0006: Reference Registry Authority & Automated Staleness Gate

- **Reference ID**: `ADR-ARCH-006`
- **Status**: `approved`
- **Date**: `2026-10-19`
- **Depends On**: `ARCH-CORE-001`

---

## 1. Context
AI agents must not treat draft proposals or outdated documentation as proven architectural facts.

## 2. Decision
1. All core specs, ADRs, rules, and contracts are indexed in `docs/agent-system/reference-registry.json` with explicit `authority` (`approved`, `observed`, `proposal`, `deprecated`) and `status` (`current`, `stale`, `superseded`).
2. Tasks in `ready` or higher status may ONLY depend on `authority: "approved"` and `status: "current"` references. Encountering a `proposal` or `stale` reference blocks the task.
3. `validate_registry.py` enforces SHA-256 consistency: when a tracked file changes on disk, `validate_registry.py` flags `ERR_REG_STALE_HASH` until human review and hash refresh.

## 3. Consequences
- **Positive**: Eliminates AI hallucination on draft proposals; catches stale documentation immediately.
- **Negative**: Modifying approved documents requires re-verifying downstream dependents via `check_impact.py`.
