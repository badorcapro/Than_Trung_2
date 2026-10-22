---
name: plan-task
description: Decompose an engineering requirement, analyze reference dependencies and downstream impact, and generate a validated Task Execution Contract (docs/agent-system/tasks/TASK-XXXX.md).
---

# Skill: Plan Task & Author Execution Contract

> **Purpose**: Translate a user requirement into a deterministic, scope-bounded `TASK-XXXX.md` contract before touching any source code.  
> **Companion Rules**: See [rule_task_contract_and_scope.md](../../rules/rule_task_contract_and_scope.md) and [rule_critical_engagement.md](../../rules/rule_critical_engagement.md).

---

## 1. When to Use
- Starting any new feature, bugfix, refactoring, or RTL design/verification task.
- Updating scope or acceptance criteria when an active task becomes `blocked`.

---

## 2. Step-by-Step Workflow

1. **Inspect Registry & Analyze Downstream Impact**:
   ```powershell
   python scripts/agent/validate_registry.py
   python scripts/agent/check_impact.py --target <REF_ID_OR_PATH>
   ```
   - Identify all `approved` + `current` references needed for the task.
   - If a required reference has `authority: "proposal"` or `status: "stale"`, **STOP** and ask the user for approval before setting the task to `ready`.

2. **Author `docs/agent-system/tasks/TASK-XXXX.md`**:
   - Start from the domain template in `profiles/<domain>/TASK-TEMPLATE-*.md`.
   - Populate all mandatory YAML frontmatter fields: `id`, `title`, `domain`, `status` (`draft` or `ready`), `goal`, `in_scope`, `out_of_scope`, `references`, `acceptance_criteria`, `verification_commands`, `stop_conditions`, `current_checkpoint`.

3. **Validate Contract & Sync Active State Pointer**:
   ```powershell
   python scripts/agent/validate_task.py --task TASK-XXXX --sync-state
   ```
   - *Success Signal*: JSON output returns `"success": true` and `"state_synced": true` with exit code `0`.
   - *Failure Signal*: Exit code `2` with `ERR_TASK_*` diagnostics. Resolve schema or reference authority errors before executing code changes.
