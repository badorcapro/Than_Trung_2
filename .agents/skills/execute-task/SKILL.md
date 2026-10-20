---
name: execute-task
description: Execute an approved Task Execution Contract by selectively loading declared references, making surgical edits strictly within in_scope, and checking scope boundaries continuously.
---

# Skill: Execute Task Within Scope Boundaries

> **Purpose**: Implement code and test changes for an active `TASK-XXXX.md` contract while keeping context minimal and enforcing strict scope containment.  
> **Companion Rules**: See [rule_task_contract_and_scope.md](../../rules/rule_task_contract_and_scope.md) and [rule_anti_evasion.md](../../rules/rule_anti_evasion.md).

---

## 1. When to Use
- Implementing a task whose contract is validated in `ready` or `in_progress` status.
- Resuming an `in_progress` task from `docs/agent-system/state/active-task.json` after session compaction (`/compact`).

---

## 2. Step-by-Step Workflow

1. **Recover State & Verify Contract Readiness**:
   ```powershell
   python scripts/agent/validate_task.py --task TASK-XXXX --check-state
   ```
   - Read **only** the files listed in `references` and `in_scope` of `TASK-XXXX.md`. Do not read unrelated project modules.

2. **Transition Status to `in_progress`**:
   - Update `status: in_progress` and `current_checkpoint` in `TASK-XXXX.md`, then sync state:
   ```powershell
   python scripts/agent/validate_task.py --task TASK-XXXX --sync-state
   ```

3. **Perform Surgical Edits & Enforce Scope Guard**:
   - Modify or create files strictly matching `in_scope`.
   - Core Engine scripts (`scripts/agent/*.py`) strictly observe the hard cap of $\le 400$ lines/file.
   - Application and domain files follow the role-based line budget configured in `docs/agent-system/project-config.json` (`ADR-ARCH-010`).
   - If you discover a contradiction in requirements or need to touch a file outside `in_scope`, **HALT**, update `status: blocked` in `TASK-XXXX.md`, sync state, and ask the user.
   - Verify scope compliance after edits:
   ```powershell
   python scripts/agent/check_scope.py --task TASK-XXXX
   ```
   - *Success Signal*: `"success": true` and `"out_of_scope_files": []` (exit code `0`).
   - *Failure Signal*: Exit code `2` (`ERR_SCOPE_VIOLATION` or `ERR_SCOPE_FORBIDDEN`). Revert unauthorized file changes immediately.

4. **Large-File Protocol (Slice-First) & Diff Guard Discipline**:
   - **Slice-First Reading**: For large files, do not read the full file into context. Use targeted line slices (`view_file` with `StartLine`/`EndLine`, `grep`).
   - **Targeted Editing**: Edit contiguous blocks using line-bounded replacements (`replace_file_content`).
   - **Zero Truncation Placeholders**: Never insert placeholders like `// rest of code remains unchanged`. The post-hoc diff guard detects and blocks them with `ERR_DIFF_PLACEHOLDER`.
   - **Cohesion Note Requirement**: Any file reaching `warn` tier or above requires a Cohesion Note in the task contract body before verification can pass:
     ```markdown
     ## Cohesion Note: path/to/file.ext
     - responsibilities: <primary responsibilities>
     - public_symbols: <count or list of key symbols>
     - reason_not_split: <why single cohesive module is architecturally superior>
     ```
   - **Approved Exceptions**: Substantial refactors causing net deletions above threshold require an approved exception (`line_budget_exceptions` with non-empty `approved_by`).

