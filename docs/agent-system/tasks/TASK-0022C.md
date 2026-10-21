---
id: TASK-0022C
title: Dissect Easing Curves, World Visuals & Region Minigames (45 Classes) and Model
  Visual Effects
domain: software
status: verified
phase: P2
touches_gatekeeper: false
goal: 'Execute the third and final sub-task of Cycle V1 (Detective Board & Visual
  World) by performing deep architectural dissection and Godot 4 reconstruction mapping
  across the remaining 45 C# classes responsible for mathematical easing curves, world
  atmosphere, ambient decor, animated visual effects, region world managers (BackAlleys,
  Casino, Clock, Docks), minigame visuals (SlotMachine, Boat, CasinoCards, CasinoChips,
  ClockTower), and visual ScriptableObjects. 1. Author a comprehensive anatomy handbook
  (V1C_Easing_Curves_and_World_Visuals.md) analyzing all 45 classes with decompiled
  C# logic, Inspector properties, referenced assets, and equivalent Godot 4.6.2 Tween,
  GPUParticles2D / custom shader / CanvasItem rendering, and Node2D scene tree architecture.
  2. Build a deterministic easing curves & visual effects simulator (scripts/agent/simulate_easing_and_world_visuals.py)
  modeling 7 analytical easing formulas from CoroutineExtensions, Casino bulb blink
  patterns, world decor bobbing & rotation animations under ADR-0010 (< 300 LOC).
  3. Update reconstruction status of all remaining 45 classes from pending to documented
  in docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json (depth
  L3), bringing all 95 classes of Cycle V1 to 100% L3 completion. 4. Establish the
  60fps empirical verification checklist (DEC-26) for visual world & minigame effects.

  '
in_scope:
- docs/agent-system/tasks/TASK-0022C.md
- docs/agent-system/evidence/dupery/handbook/V1C_Easing_Curves_and_World_Visuals.md
- docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json
- scripts/agent/simulate_easing_and_world_visuals.py
- tests/test_simulate_easing_and_world_visuals.py
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
- TASK-0017
- TASK-0018
- TASK-0020
- TASK-0021B
- TASK-0021C
- TASK-0022A
- TASK-0022B
assumptions:
- Decompiled C# source trees exist under docs/agent-system/evidence/dupery/generated/decompiled_cs/.
- Scene JSONs exist under docs/agent-system/evidence/dupery/scenes/.
acceptance_criteria:
- Handbook docs/agent-system/evidence/dupery/handbook/V1C_Easing_Curves_and_World_Visuals.md
  dissects all 45 classes with 1:1 Godot 4 node and script architecture.
- Sổ cái reconstruction_obligation_ledger.json updates exactly 45 classes to depth
  L3 with reconstruction_status documented, reaching 95/95 V1 classes at L3.
- scripts/agent/simulate_easing_and_world_visuals.py implements deterministic easing
  curves, bulb pattern sequencer, and world visual animation models adhering to ADR-0010
  (< 300 LOC, tier ok).
- tests/test_simulate_easing_and_world_visuals.py validates easing mathematical curves,
  casino bulb sequence timing, and bobbing calculations.
- Subagent Peer-Audit passes with verdict PASS.
verification_commands:
- python scripts/agent/simulate_easing_and_world_visuals.py --verify
- python -m unittest tests/test_simulate_easing_and_world_visuals.py
- python scripts/agent/validate_registry.py
- python scripts/agent/check_peer_audit.py --task TASK-0022C
stop_conditions:
- Any file exceeds 300 LOC without modularization.
- Git working tree modifies files outside declared in_scope.
- Unaccounted classes or missing classes among the 45 targets.
line_budget_exceptions: []
current_checkpoint: CP-VERIFIED
evidence_receipt: docs/agent-system/evidence/TASK-0022C-receipt.json
---

# TASK-0022C: Dissect Easing Curves, World Visuals & Region Minigames (45 Classes) and Model Visual Effects

## Context & Rationale
TASK-0022C là phân nhiệm cuối cùng của Vòng V1 (Bảng thám tử & Môi trường trực quan), hoàn thiện 100% (95/95 classes) của Vòng V1 lên độ sâu L3 (`documented`):
1. **Toán học chuyển động & Easing Curves**: Giải phẫu 7 đường cong easing giải tích từ `CoroutineExtensions` (`easeInSine`, `easeOutSine`, `easeInOutSine`, `easeInElastic`, `easeOutElastic`, `easeInBack`, `easeOutBack`, `easeInOutBack`, `easeInBounce`, `easeOutBounce`) làm nền tảng toán học cho toàn bộ chuyển động của Dupery.
2. **Quản lý Môi trường Thế giới 4 Vùng (Region World Managers)**:
   - `WorldVisualManager`: Lớp cơ sở trừu tượng điều phối toàn bộ các phân hệ visual.
   - `BackAlleysRegionWorldManager`: Pouch manager, health pins, túi đồ nghề và giao dịch items.
   - `CasinoRegionWorldManager`: Chips manager, card manager, hệ thống đèn bóng tròn Casino 5 mẫu nhấp nháy.
   - `ClockRegionWorldManager`: Tháp đồng hồ, cơ chế đổ chuông và rung lắc jiggle.
   - `DocksRegionWorldManager`: Tàu thuyền di chuyển trên lưới tọa độ, tiêu hao nhiên liệu, phao câu jiggle và thủy lôi phát nổ.
3. **Hiệu ứng Trực quan & Hoạt ảnh Thế giới (World Animation & Decor)**:
   - `WorldDecorManager`: Đèn chiếu bóng lắc lư theo chu kỳ 6-8s và cơ chế chập chờn bóng tối 2% (`rollDark`).
   - `WorldAnimationEffectsVisualManager` & `WorldAnimationEffect`: Búa thẩm phán (`JudgeGavelAnimationEffect`) rung lắc liên tục tại hiện trường vụ án.
   - `KnockVisual`: Hiệu ứng gõ cửa vòng tròn mở rộng và các hạt bắn ra.
4. **Visual ScriptableObjects & Dữ liệu Hiển thị**:
   - `RegionsVisualsDataSO`, `CaseQuirksVisualDataSO`, `CasinoCardsVisualDataSO`, `CodexVisualDataSO`, `StampVisualDataSO`, `BackAlleysItemVisualDataSO`.

## Key Deliverables
1. `docs/agent-system/evidence/dupery/handbook/V1C_Easing_Curves_and_World_Visuals.md`: Cẩm nang giải phẫu 45 classes và thiết kế Godot 4 tương đương.
2. `scripts/agent/simulate_easing_and_world_visuals.py`: Module giải tích 7 đường cong easing, bộ lập trình nhịp đèn Casino, và dao động ánh sáng decor.
3. `tests/test_simulate_easing_and_world_visuals.py`: Bộ kiểm thử tự động cho mô hình giải tích.
4. `docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json`: Cập nhật trạng thái 45 classes còn lại lên L3 `documented` (đạt 95/95 classes V1).