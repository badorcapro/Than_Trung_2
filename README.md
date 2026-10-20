# AI-AGENTS-Template

> **Universal 2-Tier AI-Assisted Engineering Operating System**  
> A deterministic, anti-evasion governance framework designed for pair-programming with autonomous AI agents across Software and Semiconductor/Hardware engineering projects.

---

## 1. Core Architectural Invariants

1. **Contract-First Execution**: No production or test code may be modified without an active, validated Task Contract (`docs/agent-system/tasks/TASK-XXXX.md`).
2. **Zero Self-Grading (Fail-Closed Verification)**: AI Agents cannot mark their own tasks as `verified` or `approved`. Transition to `verified` is performed strictly by running `python scripts/agent/run_verify.py --task TASK-XXXX` which hashes code diffs and runs test suites deterministically.
3. **Role-Based Configurable Line Budgets ([ADR-0010](docs/agent-system/decisions/ADR-0010-role-based-configurable-line-budgets.md))**: Replaces naive universal file-length caps with domain-aware role budgets (`core_engine`, `domain_logic`, `rtl`, `test`), backed by a post-hoc git diff guard that halts code truncation placeholders.
4. **Flexible Workflow Modes ([ADR-0011](docs/agent-system/decisions/ADR-0011-workspace-customization-and-workflow-modes.md))**:
   - `single_task`: Agile per-task validation, verification, and individual approval for rapid development.
   - `milestone`: Structured phased governance with mechanical cross-phase boundary gates for enterprise delivery.
5. **Progressive Disclosure (5-Layer Model)**: Keeps agent context consumption below $15\%$ of budget through on-demand loading of rules and skills.

---

## 2. Quickstart for Adopters

### Step 1: Install Dependencies
```powershell
pip install -r requirements.txt
```

### Step 2: Initialize Workspace Configuration
```powershell
# For general software development in single-task mode:
python scripts/agent/configure_project.py --init --profile software --mode single_task

# Or for semiconductor/hardware development in milestone mode:
python scripts/agent/configure_project.py --init --profile semiconductor-hardware --mode milestone
```

### Step 3: Validate Reference Registry
```powershell
python scripts/agent/validate_registry.py --update-hashes
python scripts/agent/check_docs.py
```

### Step 4: Plan and Execute Your First Task
1. Create a task contract in `docs/agent-system/tasks/TASK-0001.md` (see domain templates in `profiles/`).
2. Sync state:
   ```powershell
   python scripts/agent/validate_task.py --task TASK-0001 --sync-state
   ```
3. Implement in-scope changes and verify deterministically:
   ```powershell
   python scripts/agent/run_verify.py --task TASK-0001
   ```
4. Approve task:
   ```powershell
   python scripts/agent/validate_task.py --approve --task TASK-0001
   ```

---

## 3. Directory Layout

```text
AI-AGENTS-Template/
├── AGENTS.md                        # L1: Supreme operational manual & invariants
├── ARCHITECTURE.md                  # L1: System topology & contract specifications
├── requirements.txt                 # Dependencies (pydantic, pyyaml, jsonschema)
├── .agents/
│   ├── rules/                       # L2: Operational guardrails (anti-evasion, critical engagement)
│   └── skills/                      # L3: Progressive procedural workflows
│       ├── customize-workspace/     # Project personalization & onboarding playbook
│       ├── plan-task/               # Task decomposition & contract authoring
│       ├── execute-task/            # Scope containment & surgical editing
│       ├── verify-task/             # Deterministic verification & receipt generation
│       ├── controlled-learning/     # Staging gate for durable knowledge
│       └── investigate-bug/         # Systematic bug diagnosis & ADR capture
├── profiles/                        # Domain packs (software, semiconductor-hardware)
├── docs/agent-system/
│   ├── reference-registry.json      # Authoritative dependency and SHA-256 index
│   ├── project-config.json          # Workflow mode, profile, and role budgets
│   ├── decisions/                   # Architectural Decision Records (ADR-0001..0012)
│   ├── tasks/                       # Active and historical Task Contracts
│   ├── evidence/                    # Tamper-evident verification receipts
│   └── state/                       # Active task pointer (active-task.json)
└── scripts/agent/                   # L5: Deterministic Gatekeeper Engines (<= 400 lines)
```

---

## 4. Exporting as a Starter Bundle ([ADR-0012](docs/agent-system/decisions/ADR-0012-reusable-template-export-and-packaging.md))

To package a clean, turn-key distribution without dogfooding task history:
```powershell
python scripts/agent/export_template.py --output ../my-new-project
# Or export directly to a zip archive:
python scripts/agent/export_template.py --output ../temp-export --zip ../starter.zip
```
