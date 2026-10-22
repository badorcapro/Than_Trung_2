---
id: TASK-0023A
title: Dissect Case Creation Algorithms & 20 Generation Constraints (43 Classes) and
  Model Seed Determinism
domain: software
status: verified
phase: P2
touches_gatekeeper: false
goal: 'Execute the first sub-task of Cycle V2 (Case Creation & Story Flow) by performing
  deep architectural dissection and Godot 4 reconstruction mapping across 43 C# classes
  responsible for case procedural generation, constraint-based board layout, and seed
  determinism. 1. Author a comprehensive anatomy handbook (V2A_Case_Creation_and_Generation_Constraints.md)
  analyzing all 43 classes with decompiled C# logic, 3-stage generation pipeline (SuspectListFactory,
  InPlayListFactory, BoardPositioningFactory), 20 Generation Constraints, and Godot
  4 Custom Resources architecture (GenerationConstraint.gd). 2. Build an executable
  deterministic Case Generator Simulator (scripts/agent/simulate_case_generation.py)
  implementing the DotNetRandom Knuth Subtractive Generator algorithm, 3-stage generation
  flow, and constraint priority resolution under ADR-0010 (< 300 LOC). 3. Update reconstruction
  status of 43 classes from pending to documented in docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json
  (depth L3). 4. Establish cross-verification checklist for seed repeatability between
  Steam game and Godot 4.

  '
in_scope:
- docs/agent-system/tasks/TASK-0023A.md
- docs/agent-system/plans/PLAN-CHANG-3-DUPERY-RECONSTRUCTION.md
- docs/agent-system/reference-registry.json
- docs/agent-system/evidence/dupery/handbook/V2A_Case_Creation_and_Generation_Constraints.md
- docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json
- scripts/agent/simulate_case_generation.py
- tests/test_simulate_case_generation.py
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
- TASK-0020
- TASK-0021B
- TASK-0022A
- TASK-0022B
- TASK-0022C
assumptions:
- Decompiled C# source trees exist under docs/agent-system/evidence/dupery/generated/decompiled_cs/.
- ScriptableObjects data exist under docs/agent-system/evidence/dupery/data/scriptable_objects/.
acceptance_criteria:
- Handbook docs/agent-system/evidence/dupery/handbook/V2A_Case_Creation_and_Generation_Constraints.md
  dissects all 43 classes with 1:1 Godot 4 Custom Resource and script architecture.
- Sổ cái reconstruction_obligation_ledger.json updates exactly 43 classes to depth
  L3 with reconstruction_status documented.
- scripts/agent/simulate_case_generation.py implements DotNetRandom Knuth Subtractive
  PRNG and 3-stage generation pipeline adhering to ADR-0010 (< 300 LOC, tier ok).
- tests/test_simulate_case_generation.py validates Knuth Subtractive PRNG against
  canonical .NET Random values and constraint resolution.
- Subagent Peer-Audit passes with verdict PASS.
verification_commands:
- python scripts/agent/simulate_case_generation.py --verify
- python -m unittest tests/test_simulate_case_generation.py
- python scripts/agent/validate_registry.py
- python scripts/agent/check_peer_audit.py --task TASK-0023A
stop_conditions:
- Any file exceeds 300 LOC without modularization.
- Git working tree modifies files outside declared in_scope.
- Incompatible seed generation or non-deterministic outcomes.
line_budget_exceptions: []
current_checkpoint: CP-VERIFIED
evidence_receipt: docs/agent-system/evidence/TASK-0023A-receipt.json
---

# TASK-0023A: Dissect Case Creation Algorithms & 20 Generation Constraints (43 Classes) and Model Seed Determinism

## Context & Rationale
TASK-0023A khởi động Vòng V2 (Sinh Vụ Án & Luồng Truyện) bằng việc giải phẫu toàn bộ thuật toán sinh vụ án theo thủ tục (Procedural Generation) và 20 ràng buộc vị trí/phân loại nhân vật:
1. **Quy trình sinh 3 giai đoạn**:
   - `SuspectListFactory`: Chọn lọc danh sách nghi phạm từ đồ thị RoleSetsGraph theo tỷ lệ phân loại yêu cầu.
   - `InPlayListFactory`: Lấy danh sách toàn bộ các nhân vật và địa điểm sẽ xuất hiện trên bàn cờ.
   - `BoardPositioningFactory`: Đặt các cọc ghim/thẻ bài lên ma trận bảng $M \times N$ dựa trên các ràng buộc vị trí (`IPositioningGenerationConstraint`) và độ ưu tiên (`GenerationConstraintPriority`).
2. **20 Ràng buộc Generation Constraints**:
   - Ràng buộc vị trí: `PositionRoleGC`, `PositionLocationGC`, `PositionRolesIfExistsGC`, `PositionSelfGC`, `SuspectLocationGC`, `InPlayLocationGC`.
   - Ràng buộc quan hệ: `RomanticGC`, `CasanovaGC`, `AvoidSuspectRoleGC`, `AvoidInPlayRoleGC`, `TransformToRoleGC`.
   - Ràng buộc tỷ lệ & yêu cầu: `ClassificationRatioGC`, `InPlayClassificationRatioGC`, `InPlayRequireRoleGC`, `SuspectRequireRoleGC`.
3. **Tính tất định của hạt giống ngẫu nhiên (Seed Determinism)**:
   - Thuật toán Knuth Subtractive PRNG của `System.Random` (.NET Mono x86) được tái hiện chính xác để bảo đảm cùng một số nguyên `seed` sẽ sinh ra chính xác 100% cùng một vụ án trên cả Steam game gốc lẫn bản tái thiết Godot 4.

## Key Deliverables
1. `docs/agent-system/evidence/dupery/handbook/V2A_Case_Creation_and_Generation_Constraints.md`: Cẩm nang giải phẫu 43 classes và thiết kế Godot 4 Custom Resources (`GenerationConstraint.gd`).
2. `scripts/agent/simulate_case_generation.py`: Module mô phỏng PRNG Knuth Subtractive và quy trình sinh vụ án 3 giai đoạn.
3. `tests/test_simulate_case_generation.py`: Bộ kiểm thử tự động kiểm chứng tính tất định của seed và giải quyết ràng buộc.
4. `docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json`: Cập nhật trạng thái 43 classes lên L3 `documented`.