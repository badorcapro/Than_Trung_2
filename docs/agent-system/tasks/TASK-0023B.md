---
id: TASK-0023B
title: Dissect Story Nodes & Branching Logic (87 Classes) and Model Story Graph Execution
domain: software
status: approved
phase: P2
touches_gatekeeper: false
goal: 'Execute the second sub-task of Cycle V2 (Story Nodes & Branching Logic) by
  performing deep architectural dissection and Godot 4 reconstruction mapping across
  87 C# classes in Nodes (65 classes) and Nodes.Logic (22 classes) responsible for
  story node graphs, interactive dialogues, tutorial sequences, condition evaluation,
  and role set graphs. 1. Author a comprehensive anatomy handbook (V2B_Story_Nodes_and_Branching_Logic.md)
  analyzing all 87 classes with decompiled C# logic, port routing mechanism, dialogue
  flow, localisation replacement, and equivalent Godot 4.6.2 Resource-based Story
  Graph engine. 2. Build an executable deterministic Story Graph Simulator (scripts/agent/simulate_story_node_graph.py)
  traversing and validating story graph structures from TASK-0015 (including cutscenes
  and tutorial graphs) under ADR-0010 (< 300 LOC). 3. Update reconstruction status
  of all remaining 87 classes of Cycle V2 from pending to documented in docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json
  (depth L3), bringing Cycle V2 to 130/130 classes (100% L3 completion). 4. Establish
  logical verification checklist for dialogue progression and cutscene transitions.

  '
in_scope:
- docs/agent-system/tasks/TASK-0023B.md
- docs/agent-system/evidence/dupery/handbook/V2B_Story_Nodes_and_Branching_Logic.md
- docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json
- scripts/agent/simulate_story_node_graph.py
- tests/test_simulate_story_node_graph.py
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
assumptions:
- Decompiled C# source trees exist under docs/agent-system/evidence/dupery/generated/decompiled_cs/.
- 18 decoded XNode Story Graphs exist under docs/agent-system/evidence/dupery/data/graphs/story_graphs/.
acceptance_criteria:
- Handbook docs/agent-system/evidence/dupery/handbook/V2B_Story_Nodes_and_Branching_Logic.md
  dissects all 87 classes with 1:1 Godot 4 node and script architecture.
- Sổ cái reconstruction_obligation_ledger.json updates exactly 87 classes to depth
  L3 with reconstruction_status documented, reaching 130/130 V2 classes at L3.
- scripts/agent/simulate_story_node_graph.py implements story node graph traversal,
  dialogue sequencing, and condition branching adhering to ADR-0010 (< 300 LOC, tier
  ok).
- tests/test_simulate_story_node_graph.py validates story graph navigation and port
  routing.
- Subagent Peer-Audit passes with verdict PASS.
verification_commands:
- python scripts/agent/simulate_story_node_graph.py --verify
- python -m unittest tests/test_simulate_story_node_graph.py
- python scripts/agent/validate_registry.py
- python scripts/agent/check_peer_audit.py --task TASK-0023B
stop_conditions:
- Any file exceeds 300 LOC without modularization.
- Git working tree modifies files outside declared in_scope.
- Broken graph traversal or unhandled port connections.
line_budget_exceptions: []
current_checkpoint: CP-APPROVED
evidence_receipt: docs/agent-system/evidence/TASK-0023B-receipt.json
---

# TASK-0023B: Dissect Story Nodes & Branching Logic (87 Classes) and Model Story Graph Execution

## Context & Rationale
TASK-0023B hoàn thiện phân hệ thứ hai của Vòng V2 (Sinh Vụ Án & Luồng Truyện), tập trung vào động cơ đồ thị truyện (Story Node Graphs), hội thoại và phân nhánh logic:
1. **Động cơ đồ thị phân nhánh (`Nodes` — 65 classes)**:
   - Các node cốt lõi: `StoryNodeGraph`, `StoryNodeBase`, `StoryStartNode`, `StoryEndNode`, `StoryGateNode`, `StoryRerouteNode`, `StoryVariableNode`, `StoryWaitClickNode`.
   - Node hội thoại & sự kiện: `StoryDialogueNode` (kết nối speaker, content string, events), `StoryEventActionNode`, `WaitEventNode`.
   - Node chuỗi ký tự động: `BasicStringNode`, `AdvancedStringNode`, `KeywordStringNode`, `SpriteAssetStringNode`, `InputStringNode`.
   - Node hướng dẫn chơi (Tutorial): `MoveTutorialBoxEventNode`, `BackgroundHoleTutorialEventNode`, `TutorialDrawOnBoardNode`, `TutorialPinOnBoardNode`.
2. **Phân hệ Logic vùng & Bộ vai trò (`Nodes.Logic` — 22 classes)**:
   - Đồ thị vùng: `RegionDataGraph`, `RegionStartNode`, `RegionEndNode`, `RegionCaseNode`, `RegionSetsChoiceBaseNode`.
   - Đồ thị bộ vai trò: `RoleSetsGraph` (68 graphs), `SetsDataNode`, `SetsRoleNode`, `RoleConditionNode`, `RoleRemovalRegionNode`.
3. **Khớp nối dữ liệu XNode thực tế**:
   - Tái hiện giải thuật duyệt đồ thị từ 18 Story Graphs đã trích xuất ở TASK-0015 (`CasinoIntro`, `DocksIntro`, `SyndicateIntro`, `TemplateTransition` và 14 tutorial graphs).

## Key Deliverables
1. `docs/agent-system/evidence/dupery/handbook/V2B_Story_Nodes_and_Branching_Logic.md`: Cẩm nang giải phẫu 87 classes và thiết kế Godot 4 Graph Engine.
2. `scripts/agent/simulate_story_node_graph.py`: Module mô phỏng nạp và duyệt đồ thị truyện từ file JSON thực tế.
3. `tests/test_simulate_story_node_graph.py`: Bộ kiểm thử tự động cho động cơ duyệt đồ thị.
4. `docs/agent-system/evidence/dupery/reconstruction_obligation_ledger.json`: Cập nhật trạng thái 87 classes còn lại lên L3 `documented` (đạt 130/130 classes V2).