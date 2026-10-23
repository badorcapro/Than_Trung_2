---
id: TASK-0022A
title: Dissect Detective Board & Suspect Cards Architecture (28 Classes) and Model
  Snap Grid Layout
domain: software
status: approved
phase: P2
touches_gatekeeper: false
goal: 'Execute the first sub-task of Cycle V1 (Detective Board) by performing deep
  architectural dissection and Godot 4 reconstruction mapping across 28 C# classes
  responsible for the core investigative board, pins, and suspect cards. 1. Author
  a comprehensive anatomy handbook (V1A_Detective_Board_and_Suspect_Cards.md) analyzing
  all 28 classes with decompiled C# logic, Inspector properties, referenced ScriptableObjects,
  and equivalent Godot 4.6.2 Control node hierarchies and GDScript state machines.
  2. Build a deterministic board layout and snap grid simulator (scripts/agent/simulate_board_layout.py)
  modeling slot coordinates, pin physics, and classification ratio math under ADR-0010
  (< 300 LOC). 3. Update reconstruction status of all 28 classes from pending to documented
  in docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json (depth
  L3). 4. Establish the 60fps empirical verification checklist (DEC-26) for board
  cards and pins.

  '
in_scope:
- docs/agent-system/plans/PLAN-CHANG-3-DUPERY-RECONSTRUCTION.md
- docs/agent-system/reference-registry.json
- docs/agent-system/tasks/TASK-0022A.md
- docs/agent-system/evidence/dupery/handbook/V1A_Detective_Board_and_Suspect_Cards.md
- docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json
- scripts/agent/simulate_board_layout.py
- tests/test_simulate_board_layout.py
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
- TASK-0015
- TASK-0016
- TASK-0021B
- TASK-0021C
assumptions:
- Decompiled C# source trees exist under docs/agent-system/evidence/dupery/generated/decompiled_cs/.
- Scene JSONs exist under docs/agent-system/evidence/dupery/scenes/.
acceptance_criteria:
- Handbook docs/agent-system/evidence/dupery/handbook/V1A_Detective_Board_and_Suspect_Cards.md
  dissects all 28 classes with 1:1 Godot 4 node and script architecture.
- Sổ cái reconstruction_obligation_ledger.json updates exactly 28 classes to depth
  L3 with reconstruction_status documented.
- scripts/agent/simulate_board_layout.py implements deterministic snap grid and card
  layout simulation adhering to ADR-0010 (< 300 LOC, tier ok).
- tests/test_simulate_board_layout.py validates board placement and ratio calculations.
- Subagent Peer-Audit passes with verdict PASS.
verification_commands:
- python scripts/agent/simulate_board_layout.py --verify
- python -m unittest tests/test_simulate_board_layout.py
- python scripts/agent/validate_registry.py
- python scripts/agent/check_peer_audit.py --task TASK-0022A
stop_conditions:
- Any file exceeds 300 LOC without modularization.
- Git working tree modifies files outside declared in_scope.
- Unaccounted classes or missing classes among the 28 targets.
line_budget_exceptions: []
current_checkpoint: CP-APPROVED
evidence_receipt: docs/agent-system/evidence/TASK-0022A-receipt.json
---

# TASK-0022A: Dissect Detective Board & Suspect Cards Architecture (28 Classes) and Model Snap Grid Layout

## Context & Rationale
Vòng V1 (Bảng thám tử) gồm tổng cộng 95 C# classes (13.997 dòng mã nguồn decompiled). Theo quyết định kiến trúc phân rã để chống quá tải ngữ cảnh và bảo đảm độ sâu L3 toàn diện, Vòng V1 được chia thành 3 task:
- `TASK-0022A`: Bảng điều tra & Thẻ nghi phạm (28 classes).
- `TASK-0022B`: Dây nối, Cọ vẽ & Kính lúp (22 classes).
- `TASK-0022C`: Easing curves, World Visuals & Minigames (45 classes).

TASK-0022A tập trung vào phân hệ trọng tâm nhất của Dupery: Bảng điều tra (BoardVisualManager), hệ thống cọc ghim (PinsController, DragPin, HealthPins), thẻ bài nghi phạm (SuspectVisual, CharacterVisual, PrimeSuspectVisual, FakeSuspectVisual), và tỷ lệ phân loại vụ án (VisualClassificationRatioGC).

## Key Deliverables
1. `docs/agent-system/evidence/dupery/handbook/V1A_Detective_Board_and_Suspect_Cards.md`: Cẩm nang giải phẫu toàn diện 28 classes và bản thiết kế Godot 4.
2. `scripts/agent/simulate_board_layout.py`: Module mô phỏng giải tích tọa độ ghim, snap grid, và tỷ lệ phân loại.
3. `tests/test_simulate_board_layout.py`: Bộ kiểm thử tự động cho mô hình giải tích.
4. `docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json`: Cập nhật trạng thái 28 classes lên L3 `documented`.