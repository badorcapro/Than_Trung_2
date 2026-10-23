---
id: TASK-0026C
title: Dissect Case Entities, Locations & Supporting Structs (232 Classes)
domain: software
status: approved
phase: P2
touches_gatekeeper: false
goal: 'Execute the third and final sub-task of Cycle V5 (Roles & Abilities) by performing
  deep architectural dissection and Godot 4 reconstruction mapping across 232 remaining
  C# classes in Assembly-CSharp responsible for Case Entities (Case, CaseActionPayload,
  CaseReward, CaseSnapshot), regional location data (LocationData, RegionDataSO),
  investigation hazards (Bomb, BombThreat, BloodTrace), and supporting data structures
  (Alignments, Direction, StatsRegionSection). 1. Author a comprehensive anatomy handbook
  (V5C_Case_Entities_Locations_and_Supporting_Structs.md) analyzing all 232 classes,
  mapping case lifecycle state machines, regional location hierarchy, and hazard resolution
  to Godot 4.6.2 (CaseResource.gd, LocationNode.gd). 2. Build an executable deterministic
  Case Entities Simulator (scripts/agent/simulate_case_entities.py) modeling case
  snapshot creation, reward calculation, and hazard mitigation under ADR-0010 (< 300
  LOC, tier ok). 3. Update reconstruction status of all remaining 232 classes of Cycle
  V5 from pending to documented in docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json
  (depth L3), bringing Cycle V5 to 496/496 classes (100% L3 completion) and grand
  total documented to 916 classes. 4. Establish empirical verification checklist for
  case lifecycle and hazard visual feedback.

  '
in_scope:
- docs/agent-system/tasks/TASK-0026C.md
- docs/agent-system/evidence/dupery/handbook/V5C_Case_Entities_Locations_and_Supporting_Structs.md
- docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json
- scripts/agent/simulate_case_entities.py
- tests/test_simulate_case_entities.py
- tests/test_simulate_suspect_role_matrix.py
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
- TASK-0018
- TASK-0020
- TASK-0021B
- TASK-0021C
- TASK-0022A
- TASK-0022B
- TASK-0022C
- TASK-0023A
- TASK-0023B
- TASK-0024
- TASK-0025
- TASK-0026A
- TASK-0026B
assumptions:
- Decompiled C# source trees exist under docs/agent-system/evidence/dupery/generated/decompiled_cs/.
- Sổ cái tái thiết chứa 232 classes pending cuối cùng của V5.
acceptance_criteria:
- Handbook docs/agent-system/evidence/dupery/handbook/V5C_Case_Entities_Locations_and_Supporting_Structs.md
  analyzes all 232 classes across Case Entities, Location Data, and Hazards.
- Sổ cái reconstruction_obligation_ledger.json updates all remaining 232 classes of
  V5 to depth L3 with reconstruction_status documented, reaching 496/496 V5 classes
  (100% completion).
- scripts/agent/simulate_case_entities.py implements case lifecycle, snapshot generation,
  and hazard resolution adhering to ADR-0010 (< 300 LOC, tier ok).
- tests/test_simulate_case_entities.py validates case transitions, rewards, and ledger
  audit.
- Subagent Peer-Audit passes with verdict PASS.
verification_commands:
- python scripts/agent/simulate_case_entities.py --verify
- python -m unittest tests/test_simulate_case_entities.py
- python scripts/agent/validate_registry.py
- python scripts/agent/check_peer_audit.py --task TASK-0026C
stop_conditions:
- Any file exceeds 300 LOC without modularization.
- Git working tree modifies files outside declared in_scope.
- Inconsistent case state snapshotting or missing hazard handlers.
line_budget_exceptions: []
current_checkpoint: CP-APPROVED
evidence_receipt: docs/agent-system/evidence/TASK-0026C-receipt.json
---

# TASK-0026C: Dissect Case Entities, Locations & Supporting Structs (232 Classes)

## Context & Rationale
TASK-0026C là tiểu nhiệm vụ thứ ba và cuối cùng của Vòng V5, hoàn tất việc bóc tách toàn bộ 232 classes còn lại để khép lại 100% Vòng V5 (496/496 classes):
1. **Thực Thể Vụ Án & Vòng Đời Tiến Trình (`Case Entities` — 45 classes)**:
   - Các lớp cốt lõi: `Case`, `CaseActionPayload`, `CaseBuildData`, `CaseHandler`, `CaseHelper`, `CaseNotes`, `CaseRatioBuilderData`, `CaseReputationManager`, `CaseReward`, `CaseSnapshot`, `CaseState`, `CaseType`.
   - Các biến thể vụ án theo 4 địa bàn: `CasinoCase`, `DocksCase`, `ClockCase`, `BackAlleyCase` cùng các snapshot tương ứng.
2. **Hệ Thống Dữ Liệu Địa Điểm & Bản Đồ Vùng (`Location Data` — 35 classes)**:
   - Các lớp địa điểm: `LocationData`, `LocationHelper`, `LocationInfo`, `LocationMarker`, `LocationPlacement`, `LocationVisualData`, `RegionDataSO`, `_dep_RegionState`, các trạng thái vùng (`_dep_CasinoRegionState`, `_dep_ClockRegionState`, `_dep_DocksRegionState`, `_dep_BackAlleysRegionState`).
3. **Mối Nguy Hiểm & Thực Thể Minigame (`Investigation Hazards` — 25 classes)**:
   - Các mối nguy trên bàn cờ: `Bomb`, `BombThreat`, `BloodTrace`, `BreachOfTrust`, `CasinoCard`, `CasinoCardInfo`, `Suit`, `BugReporter`.
4. **Cấu Trúc Bổ Trợ, Menu & Enums Dữ Liệu (`Supporting Structs` — 127 classes)**:
   - Các enums & structs: `Alignments`, `Direction`, `B_InfoType`, `Achiements`, `AchiementStats`, `AdjustableText`, `AdvancedGenerationConstraint`, `BackgroundState`, `TransformAnimationTarget`, `StatsRegionSection`, `ShortcutKeybinds`, v.v.

## Key Deliverables
1. `docs/agent-system/evidence/dupery/handbook/V5C_Case_Entities_Locations_and_Supporting_Structs.md`: Cẩm nang giải phẫu 232 classes và kiến trúc Godot 4 Case/Location Engine.
2. `scripts/agent/simulate_case_entities.py`: Module mô phỏng tạo snapshot vụ án, tính toán phần thưởng và xử lý mối nguy hiểm trên bàn.
3. `tests/test_simulate_case_entities.py`: Bộ kiểm thử tự động cho thực thể vụ án và kiểm toán sổ cái.
4. `docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json`: Cập nhật trạng thái 232 classes còn lại của V5 lên L3 `documented` (đạt 496/496 classes V5, tổng cộng 916/1532 classes toàn dự án).