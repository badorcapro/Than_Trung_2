---
name: project-bootstrap
description: Audit workspace environment, verify git initialization, check .agents/ context budget health, validate reference-registry.json, and install domain profile rules/templates (software or semiconductor-hardware).
---

# Skill: Project Bootstrap & Context Health Audit

> **Purpose**: Initialize or audit a project using the `AI-AGENTS-Template` 5-layer architecture and optionally activate a Domain Profile.  
> **Companion Rules**: See [AGENTS.md](../../../AGENTS.md) and [rule_task_contract_and_scope.md](../../rules/rule_task_contract_and_scope.md).

---

## 1. When to Use
- Initializing a new repository from `AI-AGENTS-Template`.
- Auditing `.agents/` rule frontmatter and token budget health ($<15\%$ `always_on` target).
- Activating a domain profile (`profiles/software/` or `profiles/semiconductor-hardware/`).

---

## 2. Step-by-Step Workflow

1. **Verify Git Repository & Python Dependencies**:
   ```powershell
   git status
   python -c "import pydantic, yaml, jsonschema; print('OK')"
   ```
   - *Failure Signal*: `fatal: not a git repository` $\rightarrow$ Run `git init`. Missing package $\rightarrow$ Run `pip install -r requirements.txt`.

2. **Install Domain Profile (Optional)**:
   - To activate Software standards, copy `profiles/software/rule_software_standards.md` into `.agents/rules/`.
   - To activate Semiconductor/RTL standards, copy `profiles/semiconductor-hardware/rule_rtl_hardware_standards.md` into `.agents/rules/`.

3. **Run Registry & Context Health Gate**:
   ```powershell
   python scripts/agent/validate_registry.py --update-hashes
   ```
   - *Success Signal*: JSON output shows `"success": true`, `"issues": []`, and `context_health.context_health_pct <= 15.0`, with exit code `0`.
   - *Failure Signal*: Non-zero exit code (`2`) or `ERR_CTX_*` / `ERR_REG_*` issues in JSON output. Fix all reported `issues` before proceeding.
