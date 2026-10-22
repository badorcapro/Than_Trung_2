# ADR-0011: Workspace Customization and Workflow Modes

- **Reference ID**: `ADR-ARCH-011`
- **Status**: `approved`
- **Date**: `2026-10-19`
- **Depends On**: `ARCH-CORE-001`, `PLAN-CORE-001`, `ADR-ARCH-009`, `ADR-ARCH-010`

---

## 1. Context
The AI-AGENTS-Template workspace was initially designed with a multi-phase milestone lifecycle (`milestone` mode), where tasks are grouped into phases (`P1`, `P2`, `P3`, etc.) and a mechanical boundary gate prevents tasks of a new phase from starting until all tasks in the prior phase are approved.

However, when external developers adopt this template for general use:
1. Not all projects follow a multi-task milestone roadmap. Some projects consist of independent, ad-hoc tasks or rapid iterative features.
2. Adopters need an interactive and automated tool to configure their project settings (`workflow_mode`, `active_profile`, and role-based line budget presets) without hand-editing JSON files.
3. Hand-editing `docs/agent-system/project-config.json` risks syntax errors, schema drift, or invalid role mappings that crash gatekeepers.

## 2. Decision
1. **Support Two Workflow Modes**:
   - `milestone` (default): Tasks declare `phase: P<N>`. Tasks within a phase must all reach `verified` before the phase is reviewed and batch-approved. Starting a task in phase $N$ strictly requires all tasks in phase $< N$ to be `approved`.
   - `single_task`: Tasks do not require a `phase` field. Tasks can be approved individually via `validate_task.py --approve --task TASK-XXXX` once verified. Prior tasks must still be approved before subsequent tasks are verified (anti-chaos sequencing), but cross-phase batching is waived.

2. **Deterministic Configuration CLI (`scripts/agent/configure_project.py`)**:
   - Non-interactive mode:
     - `--init`: Creates starter `project-config.json` from profile defaults if missing. Fails safely if file already exists unless `--force` is provided.
     - `--mode {single_task,milestone}`: Updates workflow mode.
     - `--profile {software,semiconductor-hardware}`: Switches active domain profile.
     - `--show`: Outputs current configuration as formatted JSON.
     - `--json`: Machine-readable output for agent scripts.
   - Interactive wizard mode:
     - When run without arguments in an interactive terminal, prompts the user to select workflow mode, active profile, and line budget presets.

3. **Strict Validation Before Mutation**:
   - All mutations must pass validation through `ProjectConfig` (`scripts/agent/config_models.py`) before writing to `docs/agent-system/project-config.json`.
   - Any schema violation aborts immediately without corrupting the existing file.

## 3. Consequences
- **Positive**:
  - Provides a safe, user-friendly entry point for external developers adopting the template.
  - Eliminates manual JSON syntax errors in project configuration.
  - Bridges the gap between structured enterprise milestones and lightweight single-task workflows.
- **Negative / Constraints**:
  - `configure_project.py` must maintain the Core Engine line limit ($\le 400$ lines).
  - Profile switching requires validating that the new profile exists in `line_budget.profiles`.
