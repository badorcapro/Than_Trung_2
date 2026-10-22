---
name: customize-workspace
description: "Guide onboarding and customization of AI-AGENTS-Template for new or existing projects: selecting workflow modes (single_task vs milestone), choosing domain profiles, configuring line budgets, and initializing registry."
---

# Skill: Workspace Customization & Onboarding Playbook

> **Purpose**: Guide developers and AI agents in tailoring AI-AGENTS-Template to any project domain, setting workflow agility modes, and calibrating verification policies.  
> **Companion References**: See [ADR-0010](../../../docs/agent-system/decisions/ADR-0010-role-based-configurable-line-budgets.md) and [ADR-0011](../../../docs/agent-system/decisions/ADR-0011-workspace-customization-and-workflow-modes.md).

---

## 1. When to Use
- Initializing a new project using the AI-AGENTS-Template.
- Switching between `single_task` mode (rapid ad-hoc development) and `milestone` mode (structured phased governance).
- Changing or extending domain profiles (`software`, `semiconductor-hardware`, or custom).
- Adjusting role-based line budget limits or git diff guard thresholds.

---

## 2. Step-by-Step Onboarding Workflow

### Step 1: Inspect Current Workspace Configuration
Check if `docs/agent-system/project-config.json` already exists and inspect its current settings:
```powershell
python scripts/agent/configure_project.py --show
```
If the file does not exist, proceed to Step 2 to initialize it.

### Step 2: Select Workflow Mode
Choose the appropriate governance mode based on project requirements:
- **`single_task`**: Best for rapid, iterative projects. Tasks do not require a `phase` field and can be verified and approved individually without waiting for cross-phase milestones.
- **`milestone`**: Best for high-assurance or large team deliverables. Tasks declare `phase: P<N>`. All tasks in a phase must reach `verified` before batch approval, and prior phases must be `approved` before subsequent phases start.

### Step 3: Select Active Domain Profile
Choose the active profile matching your technology stack:
- **`software`**: General software development (Python, TypeScript, Go, Rust, C++, etc.). Default domain logic limits: 400 warn / 500 review / 800 hard LOC.
- **`semiconductor-hardware`**: Hardware and silicon engineering (SystemVerilog, Verilog, VHDL). RTL limits: 400 warn / 600 review / 1000 hard LOC; Testbench: 600 warn / 900 review / 1500 hard LOC.

### Step 4: Apply Configuration
Run `configure_project.py` to write or update `docs/agent-system/project-config.json`:
```powershell
# For fresh initialization:
python scripts/agent/configure_project.py --init --profile <software|semiconductor-hardware> --mode <single_task|milestone>

# To reconfigure an existing workspace:
python scripts/agent/configure_project.py --mode single_task
```

### Step 5: Register Core Files & Update Hashes
Ensure all project documentation and architecture contracts are indexed and verified:
```powershell
python scripts/agent/validate_registry.py --update-hashes
```

### Step 6: Create First Task Contract
- In `single_task` mode: Copy template to `docs/agent-system/tasks/TASK-0001.md`, omit `phase` (or set `phase: null`), sync state:
  ```powershell
  python scripts/agent/validate_task.py --task TASK-0001 --sync-state
  ```
- In `milestone` mode: Set `phase: P1`, sync state:
  ```powershell
  python scripts/agent/validate_task.py --task TASK-0001 --sync-state
  ```

---

## 3. Customization Invariants & Safety Guardrails
1. **Never Hand-Edit Raw Configuration**: Always use `scripts/agent/configure_project.py` to prevent invalid JSON or broken role definitions.
2. **Core Engine Hard Cap**: The `core_engine` role (`scripts/agent/**`) is strictly capped at $\le 400$ LOC regardless of active profile.
3. **Fail-Closed Verification**: `run_verify.py` strictly checks whether the workspace configuration is valid before approving any task.
