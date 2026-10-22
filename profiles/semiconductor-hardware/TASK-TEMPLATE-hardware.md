---
id: TASK-0000
title: "[Hardware/RTL Template] Replace with RTL module or testbench task title"
domain: semiconductor-hardware
status: ready
phase: null
goal: "Describe the target RTL block behavior, bus interface timing, and verification coverage goal."
in_scope:
  - "rtl/module_name.sv"
  - "tb/test_module_name.py"
out_of_scope:
  - "rtl/top_soc.sv"
  - "scripts/agent/**"
references:
  - "ARCH-CORE-001"
dependencies: []
assumptions:
  - "Single clock domain clk_i, active-low asynchronous reset rst_ni unless specified otherwise."
acceptance_criteria:
  - "RTL lint check passes with 0 warnings/errors (zero inferred latches, clean port widths)."
  - "Self-checking testbench simulation completes with 0 assertion failures."
  - "Zero files modified outside in_scope; waveform dumps (.vcd/.fst) excluded from git."
verification_commands:
  - "verilator --lint-only -Wall rtl/module_name.sv"
  - "pytest tb/test_module_name.py"
stop_conditions:
  - "Interface protocol or register map reference is in proposal or stale state."
  - "Timing/CDC constraint requires top-level port changes outside in_scope."
  - "Simulation or lint fails after 1 fix attempt."
current_checkpoint: CP-0
evidence_receipt: null
---

# Hardware Task Execution Log & Checkpoints

## Interface & Clock/Reset Specification
- **Clocks / Resets**: `clk_i` (posedge), `rst_ni` (async active-low).
- **Checkpoint CP-0**: Hardware task contract initialized from Semiconductor Profile template.
