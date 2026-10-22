# ADR-0012: Reusable Template Export and Packaging

- **Reference ID**: `ADR-ARCH-012`
- **Status**: `proposal`
- **Date**: `2026-10-19`
- **Depends On**: `ARCH-CORE-001`, `PLAN-CORE-001`, `ADR-ARCH-007`, `ADR-ARCH-010`, `ADR-ARCH-011`

---

## 1. Context
During the creation and refinement of `AI-AGENTS-Template`, the workspace naturally accumulated:
1. Internal dogfooding pilot code (`pilot/contract/envelope.py`, `pilot/rtl/`).
2. Internal Task Contracts (`TASK-0001` through `TASK-0018`) and evidence receipts.
3. Internal ephemeral scratchpads (`.agent_scratchpad.md`) and dev caches.

If an external developer clones or downloads the raw development repository, they inherit all 18 historical task contracts and pilot slices, creating confusion over what belongs to the template versus what belongs to their own project.

## 2. Decision
1. **Automated Export CLI (`scripts/agent/export_template.py`)**:
   - Provide a deterministic packaging script that exports a pristine starter workspace to a target directory or `.zip` archive.
   - Preserves core assets:
     - `AGENTS.md`, `ARCHITECTURE.md`, `requirements.txt`
     - `.agents/rules/` (all operational guardrails)
     - `.agents/skills/` (all operational workflows including `customize-workspace`)
     - `profiles/` (pluggable domain packs)
     - `scripts/agent/` (governance engine)
     - `docs/agent-system/decisions/` (core architectural records)
     - Starter `docs/agent-system/project-config.json`
     - Initialized empty folders: `docs/agent-system/tasks/`, `docs/agent-system/state/`, `docs/agent-system/evidence/`
2. **Explicit Exclusions (Clean Slate Invariant)**:
   - Exclude `.git/` (clean git initialization for the adopter).
   - Exclude `pilot/` (internal test pilot slice).
   - Exclude dogfooding contracts: `docs/agent-system/tasks/TASK-*.md`.
   - Exclude dogfooding evidence: `docs/agent-system/evidence/*.json`.
   - Exclude ephemeral state: `docs/agent-system/state/active-task.json`, `.agent_scratchpad.md`.
   - Exclude caches: `__pycache__`, `*.pyc`, `.pytest_cache`.
3. **Pristine Reference Registry Synthesis**:
   - The export engine generates a clean `reference-registry.json` for the destination containing only core architecture, ADRs, rules, skills, and tools.
   - Strips all `MOD-PILOT-*` and internal test references.
   - Recomputes SHA-256 hashes for all exported files to guarantee zero drift.

## 3. Consequences
- **Positive**:
  - Adopters receive a turn-key starter repository with zero historical residue.
  - Running `python scripts/agent/validate_registry.py` and `python scripts/agent/check_docs.py` on the exported workspace passes immediately with 0 errors.
- **Negative / Constraints**:
  - `export_template.py` must stay within the Core Engine hard cap ($\le 400$ lines).
