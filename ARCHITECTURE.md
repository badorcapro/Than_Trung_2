# ARCHITECTURE.md — AI-AGENTS-Template System Topology

> **Reference ID**: `ARCH-CORE-001`  
> **Authority**: `approved` | **Status**: `current`  
> **Scope**: Universal 2-Tier AI-Assisted Engineering System (Software, Semiconductor/Hardware, Systems Engineering).

---

## 1. Architectural Overview (5-Layer Context + 2-Tier Domain Model)

The repository separates **universal context governance** (Core Engine) from **domain-specific engineering toolchains** (Domain Profiles) across 5 progressive disclosure layers:

| Layer | Component | Path | Activation & Token Budget |
| :--- | :--- | :--- | :--- |
| **L1** | **Root Navigation & Invariants** | `AGENTS.md`, `ARCHITECTURE.md` | Always-on (`AGENTS.md` $\le 80$ lines). |
| **L2** | **Protective Guardrails (Rules)** | `.agents/rules/*.md` | `always_on` ($< 15\%$ of $20\text{k}$ token budget), `model_decision`, `glob` ($\le 12\text{k}$ chars/file). |
| **L3** | **Procedural Workflows (Skills)** | `.agents/skills/<name>/SKILL.md` | Progressive disclosure (metadata scanned first; instructions loaded on demand). |
| **L4** | **Authoritative Specs & State** | `docs/agent-system/` | On-demand loading by Reference ID (`reference-registry.json`, `TASK-*.md`, `ADR-*.md`). |
| **L5** | **Deterministic Gatekeepers** | `scripts/agent/*.py` | Black-box CLI execution returning Pydantic `ResultEnvelope` JSON. |

---

## 2. Module Boundaries & Single Responsibility

```text
AI-AGENTS-Template/
├── AGENTS.md                        # L1: Supreme operational invariants & skill routing (<= 80 lines)
├── ARCHITECTURE.md                  # L1: Module topology & state synchronization contract
├── .agent_scratchpad.md             # Ephemeral turn-by-turn working memory
├── requirements.txt                 # Python validation dependencies (pydantic, pyyaml, jsonschema)
├── .agents/
│   ├── rules/                       # L2: Guardrails (anti-evasion, critical-engagement, skill-authoring, task-scope)
│   └── skills/                      # L3: Modular workflows (project-bootstrap, plan-task, execute-task, verify-task)
├── profiles/                        # Pluggable Domain Packs (software, semiconductor-hardware)
├── docs/agent-system/               # L4: Persistent Knowledge & State
│   ├── reference-registry.json      # Authoritative index (id, kind, path, authority, status, sha256, depends_on)
│   ├── decisions/                   # Architectural Decision Records (ADR-*.md)
│   ├── tasks/                       # Hybrid YAML-frontmatter Task Contracts (TASK-*.md)
│   ├── state/active-task.json       # Read-only pointer auto-synced by validate_task.py
│   ├── project-config.json          # Workflow mode, active profile, role-based line budget (ADR-0010)
│   └── evidence/                    # Tamper-evident verification receipts (TASK-*-receipt.json)
├── scripts/agent/                   # L5: Deterministic Verification Engine (core engine hard cap <= 400 lines/file; product code uses role-based budgets, ADR-0010)
│   ├── models.py                    # Pydantic v2 schemas (ResultEnvelope, Issue, RegistryEntry, TaskContract)
│   ├── config_models.py             # Pydantic v2 schemas for project-config.json (ProjectConfig, LineBudgetConfig)
│   ├── validate_registry.py         # Audits reference-registry.json, SHA-256 staleness, and .agents/ budget
│   ├── validate_task.py             # Validates TASK-*.md frontmatter, authority gates, syncs active-task.json
│   ├── check_scope.py               # Git Scope Guard (verifies modified files match TaskContract.in_scope)
│   ├── check_impact.py              # Reverse dependency graph traversal over reference-registry.json
│   ├── check_docs.py                # Workspace and documentation integrity auditor
│   ├── stage_learning.py            # Controlled /learn staging gate and rule authoring CLI
│   ├── check_line_budget.py         # Deterministic role-based line budget checker
│   ├── check_diff_guard.py          # Post-hoc git diff guard (placeholders, net deletion, hunk size)
│   ├── check_peer_audit.py          # Subagent Semantic Peer-Audit receipt & diff_sha256 gatekeeper (DEC-17)
│   ├── configure_project.py         # Workspace customization and project-config initialization CLI
│   ├── export_template.py           # Clean starter template packager and distribution exporter
│   └── run_verify.py                # Executes verification_commands, hashes git diff, writes receipt, gates 'verified'
├── pilot/                           # Isolated Pilot Target (extracted slice for end-to-end verification)
└── tests/                           # Automated unit and smoke tests (T1–T6)
```

---

## 3. Core Synchronization & Security Invariants

1. **Single Source of Truth (SSOT) State Hierarchy**:
   - `docs/agent-system/tasks/TASK-XXXX.md` is the **sole authoritative Task Contract**.
   - `docs/agent-system/state/active-task.json` is a **derived read-only pointer** generated exclusively by `scripts/agent/validate_task.py` and `scripts/agent/run_verify.py`.
   - `.agent_scratchpad.md` tracks **turn-level working steps** and references the active `TASK-XXXX` ID without duplicating contract schemas.
2. **Anti-Self-Grading & Subagent Semantic Peer-Audit Gate**:
   - The AI Agent is strictly prohibited from manually editing `TASK-XXXX-receipt.json` or manually setting `status: verified` in `TASK-XXXX.md`.
   - Before running `run_verify.py`, an independent Subagent must audit the Primary Agent's thought/decision log, `transcript.jsonl`, `GEMINI.md`, rules, skills, and code semantics, writing `docs/agent-system/evidence/TASK-XXXX-peer-audit.json` (`verdict: "PASS"`).
   - Only `scripts/agent/run_verify.py` may transition a task to `verified` after confirming: (a) all `references` are `approved` + `current`, (b) `check_scope.py` passes with $0$ out-of-scope files, (c) `check_peer_audit.py` confirms a valid `PASS` peer-audit receipt matching the live `diff_sha256`, (d) all `verification_commands` exit with code `0`, and (e) line budget, cohesion notes, and post-hoc diff guard pass without errors.
3. **Reference Authority Gate**:
   - Only documents with `authority: "approved"` and `status: "current"` in `reference-registry.json` may be used by `ready`/`in_progress` tasks.

