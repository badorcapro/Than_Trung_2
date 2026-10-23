---
id: TASK-0027B
title: Dissect Persistence, Localization & UX Infrastructure (103 Classes)
domain: software
status: approved
phase: P2
touches_gatekeeper: false
goal: 'Execute the second and final sub-task of Cycle V6 (Technical Infrastructure
  & Interactive Audio) by performing deep architectural dissection and Godot 4 reconstruction
  mapping across 103 C# classes: 54 classes in Save and SavePrint (SaveHandler, SaveData_v0_9_34,
  version migration chains v0_2_51 to v0_9_34, checkpoint data, board serialization),
  21 classes in Localisation and GRGLocalisation (GRGLocalisationHandler, LanguageKey,
  LocalisedText, CSV importers), 11 classes in Hover (BaseHover, BobTextAnimationManager,
  HoveringText, TextLinkHover), 10 classes in ControllerSupport (AdvancedInputHandler,
  BoardControllerSupportManager, Virtual Cursor), and 7 classes in GameStats (RunStats,
  CaseStats, LeadStats). 1. Author a comprehensive anatomy handbook (V6B_Persistence_Localization_and_UX_Infrastructure.md)
  analyzing all 103 classes and mapping them to Godot 4.6.2 (SaveManager.gd JSON migration,
  TranslationServer, InputMap controller actions, and Control node hover tooltips).
  2. Build an executable deterministic Persistence & UX Simulator (scripts/agent/simulate_persistence_and_ux.py)
  modeling save schema serialization, version migration, localization key translation,
  and controller cursor snapping under ADR-0010 (< 300 LOC, tier ok). 3. Update reconstruction
  status of all 103 classes to L3 documented in docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json,
  bringing Cycle V6 to 100% completion (386/386 classes documented) and grand total
  documented to 1,302 classes (unaccounted == 0). 4. Establish empirical verification
  checklist for save file integrity, translation switching, and gamepad navigation.

  '
in_scope:
- docs/agent-system/tasks/TASK-0027B.md
- docs/agent-system/evidence/dupery/handbook/V6B_Persistence_Localization_and_UX_Infrastructure.md
- docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json
- scripts/agent/simulate_persistence_and_ux.py
- tests/test_simulate_persistence_and_ux.py
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
- TASK-0013
- TASK-0015
- TASK-0021B
- TASK-0027A
assumptions:
- Decompiled C# source trees exist under docs/agent-system/evidence/dupery/generated/decompiled_cs/.
- Sổ cái tái thiết chứa đúng 103 classes pending thuộc V6B.
acceptance_criteria:
- Handbook docs/agent-system/evidence/dupery/handbook/V6B_Persistence_Localization_and_UX_Infrastructure.md
  analyzes all 103 classes across Save, Localisation, Hover, ControllerSupport, and
  GameStats.
- Sổ cái reconstruction_obligation_ledger.json updates all 103 classes of V6B to depth
  L3 with reconstruction_status documented, bringing Cycle V6 to 386/386 classes (100%
  completion) and grand total documented to 1,302 classes.
- scripts/agent/simulate_persistence_and_ux.py implements JSON save serialization,
  version migration chain, translation key resolution, and controller cursor snapping
  adhering to ADR-0010 (< 300 LOC, tier ok).
- tests/test_simulate_persistence_and_ux.py validates save migrations, language switching,
  gamepad actions, and ledger audit.
- Subagent Peer-Audit passes with verdict PASS.
verification_commands:
- python scripts/agent/simulate_persistence_and_ux.py --verify
- python -m unittest tests/test_simulate_persistence_and_ux.py
- python scripts/agent/validate_registry.py
- python scripts/agent/check_peer_audit.py --task TASK-0027B
stop_conditions:
- Any file exceeds 300 LOC without modularization.
- Git working tree modifies files outside declared in_scope.
- Failure of save migration chain or localization key resolution.
line_budget_exceptions: []
current_checkpoint: CP-APPROVED
evidence_receipt: docs/agent-system/evidence/TASK-0027B-receipt.json
---

# TASK-0027B: Dissect Persistence, Localization & UX Infrastructure (103 Classes)

## Context & Rationale
TASK-0027B là tiểu nhiệm vụ thứ hai và cuối cùng của Vòng V6, hoàn tất phân hệ hạ tầng kỹ thuật của tựa game *Dupery*:
1. **Phân hệ Lưu trữ Dữ liệu (`Save` & `SavePrint` — 54 classes)**:
   - Các lớp quản lý lưu trữ: `SaveHandler`, `BaseSaveData`, `GameSave`, `SaveDataVersions`, `GameMetaData`.
   - Chuỗi nâng cấp phiên bản dữ liệu (Version Migration Chain): từ `SaveDatav0_2_51`, qua `v0_3_12`, `v0_4_23`, `v0_5_19` đến `SaveData_v0_9_34`.
   - Các cấu trúc lưu trữ chuyên biệt: `CaseSave`, `CaseBuildDataSave`, `CaseRewardSave`, `CaseStatsSaveData`, `ClueSaveData`, `LineSaveData`, `PinsSave`, `StringSave`, `BackAlleyPouchSaveData`, `RoleDataSave`.
   - `SavePrint` (3 classes): `BugReportImporter`, `SimulatedBoardManager`, `SimulatedBoardTile`.
2. **Phân hệ Đa ngôn ngữ (`Localisation` & `GRGLocalisation` — 21 classes)**:
   - `LocalisationHandler`, `LocalisationHelper`, `LanguageSettings`.
   - Thư viện `gildedrunegames.grglocalisation` (18 classes): `GRGLocalisationHandler`, `LanguageKey`, `LocalisedText`, `LocalisationDataSO`, `CSVLocalisationImporter`, v.v.
3. **Phân hệ Tương tác & Phản hồi Trực quan (`Hover` — 11 classes)**:
   - `BaseHover`, `BobTextAnimationManager`, `HoveringText`, `HoveringImage`, `TextLinkHover`, v.v.
4. **Phân hệ Hỗ trợ Bộ điều khiển (`ControllerSupport` — 10 classes)**:
   - `AdvancedInputHandler`, `BaseInputHandler`, `BoardControllerSupportManager`, `CaseControllerSupportHandler`, `VirtualCursor`.
5. **Phân hệ Thống kê Chỉ số Game (`GameStats` — 7 classes)**:
   - `RunStats`, `CaseStats`, `LeadStats`, `CasinoCaseStats`, `DocksCaseStats`, `OfficeCaseStats`, `CombinedCaseStats`.

## Key Deliverables
1. `docs/agent-system/evidence/dupery/handbook/V6B_Persistence_Localization_and_UX_Infrastructure.md`: Cẩm nang giải phẫu 103 classes.
2. `scripts/agent/simulate_persistence_and_ux.py`: Module mô phỏng lưu trữ, nâng cấp version, dịch thuật và điều khiển gamepad.
3. `tests/test_simulate_persistence_and_ux.py`: Bộ unit tests kiểm định toàn diện phân hệ hạ tầng.
4. `docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json`: Cập nhật 103 classes sang L3 `documented`, khép lại Vòng V6 100% (386/386 classes).