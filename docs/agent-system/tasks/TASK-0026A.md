---
id: TASK-0026A
title: Dissect Core Ability Engine & Special Roles (79 Classes)
domain: software
status: verified
phase: P2
touches_gatekeeper: false
goal: 'Execute the first sub-task of Cycle V5 (Roles & Abilities) by performing deep
  architectural dissection and Godot 4 reconstruction mapping across 79 C# classes
  in Assembly-CSharp responsible for the Core Ability Engine, ability interfaces (IHaveAbility,
  IHaveMultiAbility, IHaveSpecialAbility), ability data structures (AbilityData, SuspectAbilityData,
  LocationAbilityData), lead management facades, and 47 special suspect roles possessing
  active/passive abilities (Hunter, Magician, Psychic, Cultist, Doppelganger, etc.).
  1. Author a comprehensive anatomy handbook (V5A_Core_Ability_Engine_and_Archetypes.md)
  analyzing all 79 classes, ability trigger pipelines (ON_BOARD_ENTER, ON_PINNED,
  ON_ACCUSED), target redirection (IChangeAbilityTargets), and Godot 4 Custom Resource
  architecture (RoleAbility.gd, AbilityPipeline.gd). 2. Build an executable deterministic
  Ability Engine Simulator (scripts/agent/simulate_role_ability_engine.py) modeling
  ability registration, trigger execution, and target mutation under ADR-0010 (< 300
  LOC, tier ok). 3. Update reconstruction status of these 79 classes of Cycle V5 from
  pending to documented in docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json
  (depth L3). 4. Establish empirical verification checklist for ability visual feedback
  and audio triggers.

  '
in_scope:
- docs/agent-system/tasks/TASK-0026A.md
- docs/agent-system/evidence/dupery/handbook/V5A_Core_Ability_Engine_and_Archetypes.md
- docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json
- scripts/agent/simulate_role_ability_engine.py
- tests/test_simulate_role_ability_engine.py
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
assumptions:
- Decompiled C# source trees exist under docs/agent-system/evidence/dupery/generated/decompiled_cs/.
- Sổ cái tái thiết chứa 79 classes gán nhãn V5A thuộc nhóm Core Ability Engine và
  vai trò đặc biệt.
acceptance_criteria:
- Handbook docs/agent-system/evidence/dupery/handbook/V5A_Core_Ability_Engine_and_Archetypes.md
  dissects all 79 classes across Ability Engine, Interfaces, and Special Roles.
- Sổ cái reconstruction_obligation_ledger.json updates exactly 79 classes of V5 to
  depth L3 with reconstruction_status documented.
- scripts/agent/simulate_role_ability_engine.py implements ability registration, trigger
  events, and target mutation adhering to ADR-0010 (< 300 LOC, tier ok).
- tests/test_simulate_role_ability_engine.py validates ability triggers and ledger
  audit.
- Subagent Peer-Audit passes with verdict PASS.
verification_commands:
- python scripts/agent/simulate_role_ability_engine.py --verify
- python -m unittest tests/test_simulate_role_ability_engine.py
- python scripts/agent/validate_registry.py
- python scripts/agent/check_peer_audit.py --task TASK-0026A
stop_conditions:
- Any file exceeds 300 LOC without modularization.
- Git working tree modifies files outside declared in_scope.
- Unhandled ability triggers or target redirection errors.
line_budget_exceptions: []
current_checkpoint: CP-VERIFIED
evidence_receipt: docs/agent-system/evidence/TASK-0026A-receipt.json
---

# TASK-0026A: Dissect Core Ability Engine & Special Roles (79 Classes)

## Context & Rationale
TASK-0026A thực thi tiểu nhiệm vụ đầu tiên của Vòng V5 (Vai Trò Nghi Phạm & Kỹ Năng), tập trung vào trái tim logic của toàn bộ hệ thống vai trò:
1. **Khung Kỹ Năng Cốt Lõi (`Core Ability Engine` — 32 classes L3)**:
   - Dữ liệu năng lực: `AbilityData`, `SuspectAbilityData`, `LocationAbilityData`, `CasinoCardAbilityData`, `EmptySlotAbilityData`, `AddressAbilityData`, `SpecialAbilityType`.
   - Interfaces năng lực: `IHaveAbility`, `IHaveMultiAbility`, `IHaveRoleAbility`, `IHaveSpecialAbility`, `IHaveSpecialSpecificAbility`, `IChangeAbilityTargets`.
   - Hành vi kỹ năng cụ thể: `HunterRoleAbility`, `HunterSuspectAbility`, `MagicianCardAbility`, `MagicianRoleAbility`, `PsychicCardAbility`, `PsychicRoleAbility`, `RadarLocationAbility`, `RadarSuspectAbility`.
   - Mặt tiền điều phối Manh mối & Sự kiện: `LeadClueFacade`, `LeadEndManager`, `LeadEventFacade`, `LeadEventManager`, `LeadFacade`, `LeadStampManager`, `LeadStasisManager`, `LeadStasisRegionManager`.
   - Giao diện vai trò địa bàn: `IAmCasinoRole`, `IAmClockRole`, `IAmDocksRole`, `IAmClockLocation`, `IAmDocksLocation`.
2. **47 Vai Trò Nghi Phạm Sở Hữu Kỹ Năng Đặc Biệt (47 Special Ability Roles)**:
   - Các vai trò can thiệp trực tiếp vào luật bàn cờ hoặc đánh lừa người chơi: `Hunter`, `Magician`, `Psychic`, `Cultist`, `Devil`, `Doppelganger`, `Empath`, `GoodCop`, `HiredGun`, `HotShot`, `Mythomaniac`, `Politician`, `Siren`, `Snitch`, `Trickster`, `Vigilante`, `Visionary`, v.v.
   - Cơ chế can thiệp mục tiêu: `Accountant`, `Dealer`, `Barista`, `Bouncer` (triển khai `IChangeAbilityTargets`).

## Key Deliverables
1. `docs/agent-system/evidence/dupery/handbook/V5A_Core_Ability_Engine_and_Archetypes.md`: Cẩm nang giải phẫu 79 classes và kiến trúc Godot 4 Ability Pipeline.
2. `scripts/agent/simulate_role_ability_engine.py`: Module mô phỏng máy kích hoạt kỹ năng theo các sự kiện (`ON_BOARD_ENTER`, `ON_PINNED`, `ON_ACCUSED`) và đổi mục tiêu.
3. `tests/test_simulate_role_ability_engine.py`: Bộ kiểm thử tự động cho hệ thống kích hoạt kỹ năng.
4. `docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json`: Cập nhật trạng thái 79 classes V5A lên L3 `documented` (đạt 79 classes V5, tổng cộng 499/499 classes V1+V2+V3+V4+V5A).