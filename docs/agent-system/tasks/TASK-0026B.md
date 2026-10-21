---
id: TASK-0026B
title: Dissect 228 Suspect Roles Catalog & Regional Data Matrix (185 Pending Classes)
domain: software
status: verified
phase: P2
touches_gatekeeper: false
goal: 'Execute the second sub-task of Cycle V5 (Roles & Abilities) by building the
  comprehensive 228 Suspect Roles Catalog and updating the 185 remaining pending suspect
  role classes across 4 distinct regions: Docks (48 classes), Casino (21 classes),
  Clock Tower (21 classes), BackAlleys (5 classes), and General RoleData (90 classes).
  1. Author a comprehensive anatomy handbook (V5B_Suspect_Roles_Catalog_and_Data_Matrix.md)
  mapping all 228 roles to the Godot 4 Data-Driven Custom Resource architecture (SuspectRoleData.gd
  + .tres) as agreed in Decision A2. 2. Build an executable deterministic Role Catalog
  Simulator (scripts/agent/simulate_suspect_role_matrix.py) verifying role loading,
  regional grouping, trait distributions, and default attributes under ADR-0010 (<
  300 LOC, tier ok). 3. Update reconstruction status of all 185 pending suspect role
  classes of Cycle V5 from pending to documented in docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json
  (depth L3), bringing total documented roles to 228 and total V5 documented to 264
  classes (79 + 185). 4. Establish empirical verification checklist for role visual
  inspection.

  '
in_scope:
- docs/agent-system/tasks/TASK-0026B.md
- docs/agent-system/evidence/dupery/handbook/V5B_Suspect_Roles_Catalog_and_Data_Matrix.md
- docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json
- scripts/agent/simulate_suspect_role_matrix.py
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
assumptions:
- Decompiled C# source trees exist under docs/agent-system/evidence/dupery/generated/decompiled_cs/.
- Sổ cái tái thiết chứa 185 classes role đang ở trạng thái pending trong V5.
acceptance_criteria:
- Handbook docs/agent-system/evidence/dupery/handbook/V5B_Suspect_Roles_Catalog_and_Data_Matrix.md
  maps all 228 suspect roles across the 4 regions with Godot 4 Data-Driven Custom
  Resource architecture.
- Sổ cái reconstruction_obligation_ledger.json updates exactly 185 pending role classes
  of V5 to depth L3 with reconstruction_status documented.
- scripts/agent/simulate_suspect_role_matrix.py implements role cataloging, regional
  grouping, and attribute lookup adhering to ADR-0010 (< 300 LOC, tier ok).
- tests/test_simulate_suspect_role_matrix.py validates role lookups, regional filters,
  and ledger audit.
- Subagent Peer-Audit passes with verdict PASS.
verification_commands:
- python scripts/agent/simulate_suspect_role_matrix.py --verify
- python -m unittest tests/test_simulate_suspect_role_matrix.py
- python scripts/agent/validate_registry.py
- python scripts/agent/check_peer_audit.py --task TASK-0026B
stop_conditions:
- Any file exceeds 300 LOC without modularization.
- Git working tree modifies files outside declared in_scope.
- Missing role mapping or invalid regional assignment.
line_budget_exceptions: []
current_checkpoint: CP-VERIFIED
evidence_receipt: docs/agent-system/evidence/TASK-0026B-receipt.json
---

# TASK-0026B: Dissect 228 Suspect Roles Catalog & Regional Data Matrix (185 Pending Classes)

## Context & Rationale
TASK-0026B thực thi tiểu nhiệm vụ thứ hai của Vòng V5, xây dựng toàn bộ danh mục và ma trận dữ liệu thuộc tính cho 228 vai trò nghi phạm trong tựa game *Dupery*, đồng thời cập nhật 185 classes role đang chờ xử lý lên mức độ sâu L3:
1. **Phân Phối 228 Vai Trò Theo 4 Địa Bàn**:
   - `Docks` (53 roles, gồm 48 roles mới): `Absconder`, `Boatswain`, `HarborMaster`, `Smuggler`, `Fisherman`, `Sailor`, `CargoLoader`, v.v.
   - `Casino` (44 roles, gồm 21 roles mới): `BigBlind`, `HighRoller`, `PitBoss`, `Croupier`, `BlackjackPlayer`, v.v.
   - `Clock Tower` (21 roles, gồm 21 roles mới): `Watchmaker`, `Belfry`, `Timekeeper`, `ClockEngineer`, v.v.
   - `BackAlleys` (6 roles, gồm 5 roles mới): các vai trò giới tội phạm ngầm chợ đen.
   - `General / Office` (104 roles, gồm 90 roles mới): các vai trò điều tra, pháp đình, công dân, y tế, thương nhân.
2. **Kiến Trúc Tái Thiết Data-Driven Trong Godot 4.6.2**:
   - Hiện thực hóa quyết định A2 của người dùng: Toàn bộ 228 vai trò được mô hình hóa qua tài nguyên `SuspectRoleData.gd` và lưu trữ dưới dạng các tệp `.tres` dữ liệu, tránh tình trạng tạo 228 file GDScript đơn lẻ gây phình to dự án.

## Key Deliverables
1. `docs/agent-system/evidence/dupery/handbook/V5B_Suspect_Roles_Catalog_and_Data_Matrix.md`: Cẩm nang ma trận thuộc tính 228 vai trò và kiến trúc Data-Driven Custom Resource.
2. `scripts/agent/simulate_suspect_role_matrix.py`: Module nạp và tra cứu danh mục vai trò theo địa bàn và thuộc tính.
3. `tests/test_simulate_suspect_role_matrix.py`: Bộ kiểm thử tự động cho danh mục vai trò và đối soát sổ cái.
4. `docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json`: Cập nhật trạng thái 185 classes role còn lại của V5 lên L3 `documented` (tổng cộng 264/496 classes V5 đạt L3, lũy kế 684/1532 classes toàn dự án).