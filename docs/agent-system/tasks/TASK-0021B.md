---
id: TASK-0021B
title: Build Deep Scene Node Traversal and Exact Recipe Resolver (dupery_graph_resolver.py)
domain: software
status: approved
phase: P2
touches_gatekeeper: false
goal: 'Build Deep Scene Node Traversal and Exact Recipe Resolver (scripts/agent/dupery_graph_resolver.py)
  to completely eliminate Trade-offs 1 and 2 of TASK-0021. 1. Deep Scene Node Traversal:
  Traverse all 5,279 GameObjects across 12 Scene JSONs (docs/agent-system/evidence/dupery/scenes/*.json)
  to support deep node queries (--node <name>), returning exact hierarchy paths (Root/Child/SubChild),
  RectTransform geometry, and attached MonoBehaviour components with custom properties.
  2. Exact Deterministic Recipe Linkage: Replace heuristic substring guessing in get-recipe
  with deterministic code and scene linkage: locate exact GameObjects and Scenes where
  the C# class is attached, and scan decompiled .cs source files to extract actual
  called FMOD audio enums (Sfx, Music, Atmo), ScriptableObjects, and dependent domain
  classes. 3. Adheres strictly to ADR-0010 Line Budget (< 300 LOC per file) and passes
  independent Subagent Peer-Audit. '
in_scope:
- scripts/agent/dupery_graph_resolver.py
- scripts/agent/query_dupery_graph.py
- tests/test_dupery_graph_resolver.py
- tests/test_query_dupery_graph.py
out_of_scope:
- Than_Tham_Nua_Voi_Godot/**
- docs/agent-system/evidence/dupery/vault/raw/**
references:
- ARCH-CORE-001
- RULE-ENGINE-001
- RULE-SCOPE-001
- ADR-ARCH-010
- PLAN-CHANG-003
dependencies:
- TASK-0014
- TASK-0015
- TASK-0018
- TASK-0021
assumptions:
- All 12 Scene JSONs exist under docs/agent-system/evidence/dupery/scenes/ containing
  exactly 5,279 GameObjects.
- Decompiled C# source trees exist under docs/agent-system/evidence/dupery/generated/decompiled_cs/.
acceptance_criteria:
- scripts/agent/dupery_graph_resolver.py implements deep recursive node search across
  all 5,279 GameObjects in 12 scenes.
- query_dupery_graph.py inspect-scene supports --node <pattern> to find matching GameObjects
  with exact hierarchy paths and components.
- 'get-recipe outputs deterministic linkage: exact scene GameObject paths holding
  the class, and exact FMOD audio enums extracted from .cs source code.'
- Both scripts/agent/dupery_graph_resolver.py and scripts/agent/query_dupery_graph.py
  adhere to ADR-0010 Line Budget (< 300 LOC, tier ok).
- Unit tests pass with exit code 0.
- Subagent Peer-Audit passes with verdict PASS and produces docs/agent-system/evidence/TASK-0021B-peer-audit.json.
verification_commands:
- python scripts/agent/query_dupery_graph.py inspect-scene --node "PlayButton" --format
  toon
- python scripts/agent/query_dupery_graph.py get-recipe "LineupController" --format
  json
- python -m unittest tests/test_dupery_graph_resolver.py
- python scripts/agent/check_peer_audit.py --task TASK-0021B
stop_conditions:
- Any file exceeds 300 LOC without modularization.
- Git working tree modifies files outside declared in_scope.
line_budget_exceptions: []
current_checkpoint: CP-APPROVED
evidence_receipt: docs/agent-system/evidence/TASK-0021B-receipt.json
---

# TASK-0021B: Build Deep Scene Node Traversal and Exact Recipe Resolver (dupery_graph_resolver.py)

## Bối Cảnh & Mục Tiêu Kỹ Thuật
Ở TASK-0021, công cụ `query_dupery_graph.py` đã cung cấp giao diện truy vấn tổng quan cho Tầng A. Tuy nhiên, để giữ file dưới 300 LOC (275 LOC), công cụ đã chấp nhận 2 đánh đổi (Trade-offs):
1. `inspect-scene` chỉ đọc file tóm tắt `scene_catalog_summary.json` mà chưa cho phép duyệt sâu vào 5.279 GameObjects đã trích xuất tại 12 file `scenes/*.json`.
2. `get-recipe` liên kết scene và âm thanh bằng phương pháp heuristic (so khớp chuỗi tên) thay vì tra cứu liên kết thực tế từ mã nguồn C# và cấu trúc scene.

**TASK-0021B** được thiết lập như nhiệm vụ cầu nối đầu tiên theo quyết định `DEC-27.3` để giải quyết triệt để 2 đánh đổi trên:
- Xây dựng module điều phối chuyên biệt `scripts/agent/dupery_graph_resolver.py` theo nguyên lý Single Responsibility (ADR-0010).
- Duyệt đệ quy toàn bộ 5.279 GameObjects trong 12 Scene JSONs khi thực hiện truy vấn `--node <name>`.
- Quét trực tiếp file `.cs` để bóc tách các lệnh gọi âm thanh FMOD và liên kết với component scene thực tế, cung cấp công thức ngữ cảnh tươi (Fresh Context Recipe per DEC-19) chính xác tuyệt đối 100%.