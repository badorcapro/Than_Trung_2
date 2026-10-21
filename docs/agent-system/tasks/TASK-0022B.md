---
id: TASK-0022B
title: Dissect Yarn Strings, Drawing Canvas & Investigative Tools (22 Classes) and
  Model String Catenary
domain: software
status: verified
phase: P2
touches_gatekeeper: false
goal: 'Execute the second sub-task of Cycle V1 (Detective Board) by performing deep
  architectural dissection and Godot 4 reconstruction mapping across 22 C# classes
  responsible for interactive yarn strings, freehand drawing canvas, magnifying glass,
  and board tools. 1. Author a comprehensive anatomy handbook (V1B_Yarn_Strings_and_Tools.md)
  analyzing all 22 classes with decompiled C# logic, Inspector properties, referenced
  assets, and equivalent Godot 4.6.2 Line2D, SubViewport render textures, and GDScript
  physics. 2. Build a deterministic string catenary and Verlet physics simulator (scripts/agent/simulate_string_catenary.py)
  modeling 50-segment Verlet relaxation, gravity sag, pin snap distance, and magnifying
  glass timings under ADR-0010 (< 300 LOC). 3. Update reconstruction status of all
  22 classes from pending to documented in docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json
  (depth L3). 4. Establish the 60fps empirical verification checklist (DEC-26) for
  yarn strings and tools.

  '
in_scope:
- docs/agent-system/tasks/TASK-0022B.md
- docs/agent-system/evidence/dupery/handbook/V1B_Yarn_Strings_and_Tools.md
- docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json
- scripts/agent/simulate_string_catenary.py
- tests/test_simulate_string_catenary.py
out_of_scope:
- Than_Tham_Nua_Voi_Godot/**
- docs/agent-system/evidence/dupery/vault/audio/samples/**
- docs/agent-system/evidence/dupery/vault/raw/**
references:
- ARCH-CORE-001
- RULE-ENGINE-001
- RULE-SCOPE-001
- ADR-ARCH-010
- PLAN-CHANG-003
dependencies:
- TASK-0010
- TASK-0011
- TASK-0014
- TASK-0018
- TASK-0021B
- TASK-0021C
- TASK-0022A
assumptions:
- Decompiled C# source trees exist under docs/agent-system/evidence/dupery/generated/decompiled_cs/.
- Scene JSONs exist under docs/agent-system/evidence/dupery/scenes/.
acceptance_criteria:
- Handbook docs/agent-system/evidence/dupery/handbook/V1B_Yarn_Strings_and_Tools.md
  dissects all 22 classes with 1:1 Godot 4 node and script architecture.
- Sổ cái reconstruction_obligation_ledger.json updates exactly 22 classes to depth
  L3 with reconstruction_status documented.
- scripts/agent/simulate_string_catenary.py implements deterministic Verlet string
  relaxation and tool simulation adhering to ADR-0010 (< 300 LOC, tier ok).
- tests/test_simulate_string_catenary.py validates string physics and tool timings.
- Subagent Peer-Audit passes with verdict PASS.
verification_commands:
- python scripts/agent/simulate_string_catenary.py --verify
- python -m unittest tests/test_simulate_string_catenary.py
- python scripts/agent/validate_registry.py
- python scripts/agent/check_peer_audit.py --task TASK-0022B
stop_conditions:
- Any file exceeds 300 LOC without modularization.
- Git working tree modifies files outside declared in_scope.
- Unaccounted classes or missing classes among the 22 targets.
line_budget_exceptions: []
current_checkpoint: CP-VERIFIED
evidence_receipt: docs/agent-system/evidence/TASK-0022B-receipt.json
---

# TASK-0022B: Dissect Yarn Strings, Drawing Canvas & Investigative Tools (22 Classes) and Model String Catenary

## Context & Rationale
TASK-0022B tiếp nối TASK-0022A trong Vòng V1 (Bảng thám tử), tập trung vào các công cụ tương tác trực tiếp của người chơi trên bảng điều tra:
1. Hệ thống dây dù đỏ/xanh nối giữa các cọc ghim (StringManager, ConnectionString, ConnectionStringVerlet).
2. Hệ thống cọ vẽ tự do bằng sáp chì và tẩy (LRBrush, RTDrawer, RTBrush, PenManager, PenState).
3. Kính lúp soi chi tiết và phóng to chân dung nghi phạm (MagnifyingGlassManager, MagnifyingGlassMenuingAnimation).
4. Các công cụ ghi chú và điều hướng phụ trợ (NotesToolManager, NavigationVisualManager, RatioVisualManager, TimeVisualManager, ReputationVisualManager).

## Key Deliverables
1. `docs/agent-system/evidence/dupery/handbook/V1B_Yarn_Strings_and_Tools.md`: Cẩm nang giải phẫu 22 classes và thiết kế Godot 4 (Line2D, SubViewport).
2. `scripts/agent/simulate_string_catenary.py`: Module giải tích vật lý Verlet 50 phân đoạn, lực trọng trường, và bán kính bắt dính ghim.
3. `tests/test_simulate_string_catenary.py`: Bộ kiểm thử tự động cho mô hình giải tích.
4. `docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json`: Cập nhật trạng thái 22 classes lên L3 `documented`.