---
id: TASK-0000
title: "[Software Template] Replace with concise feature or bugfix title"
domain: software
status: ready
phase: null
goal: "Describe the exact measurable software capability or defect resolution."
in_scope:
  - "src/module_name/**"
  - "tests/test_module_name.py"
out_of_scope:
  - "scripts/agent/**"
references:
  - "ARCH-CORE-001"
dependencies: []
assumptions: []
acceptance_criteria:
  - "All unit tests pass with exit code 0."
  - "Modified files stay strictly under 400 lines/file with full type annotations."
  - "Zero files modified outside in_scope."
verification_commands:
  - "python -m unittest discover -s tests -p \"test_*.py\""
stop_conditions:
  - "Required reference is missing, stale, or in proposal authority."
  - "Fix requires modifying files outside declared in_scope."
  - "Verification command fails after 1 fix attempt."
current_checkpoint: CP-0
evidence_receipt: null
---

# Task Execution Log & Checkpoints

## Checkpoint History
- **CP-0**: Task contract initialized from Software Profile template.
