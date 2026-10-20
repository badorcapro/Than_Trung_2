---
trigger: glob
globs: **/*.v, **/*.sv, **/*.svh, **/*.vhd, **/*.vhdl, **/*.tcl, **/*.sdc
description: Semiconductor RTL, FPGA, and ASIC design & verification invariants (clock domain crossing, reset polarity, synthesizable constructs, lint and simulation gates). Tiêu chuẩn thiết kế vi mạch bán dẫn RTL, đồng bộ xung nhịp, chống latch ngầm, kiểm thử testbench/simulation.
---

# Rule: Semiconductor & Hardware RTL Engineering Standards

> **Scope**: Activated via `glob` when viewing or editing HDL/RTL, testbench, or synthesis constraint files.

---

## 1. Synthesizable RTL & Verification Invariants

1. **Zero Inferred Latches**:
   - Every combinational block (`always_comb` / `always @(*)`) and `case` statement must assign default values to all outputs on every path.
2. **Sequential & Reset Discipline**:
   - Use non-blocking assignments (`<=`) strictly in sequential blocks (`always_ff`) and blocking assignments (`=`) strictly in combinational blocks (`always_comb`).
   - Adhere strictly to the clock edge and reset polarity declared in the architecture specification; never mix asynchronous and synchronous resets within the same module without an approved ADR.
3. **Clock Domain Crossing (CDC)**:
   - Never pass signals across asynchronous clock domains without explicit synchronizer cells or FIFO structures registered in the architecture spec.
4. **Deterministic Verification & Artifact Hygiene**:
   - Every RTL change must pass static lint (e.g. Verilator `--lint-only` / SpyGlass) and self-checking testbench simulation (e.g. Cocotb / SystemVerilog assertions) with $0$ errors.
   - Raw waveforms (`*.vcd`, `*.fsdb`, `*.fst`) must be excluded from Git (`docs/agent-system/evidence/.gitignore`); only structured simulation receipts belong in `evidence/`.
