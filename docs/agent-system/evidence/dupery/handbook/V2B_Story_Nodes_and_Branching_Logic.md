# Cẩm Nang Tái Thiết Kiến Trúc V2.2: Đồ Thị Truyện & Phân Nhánh Logic (87 Classes)

> **Mã định danh**: `DOC-V2B-HANDBOOK`  
> **Phạm vi tái thiết**: Vòng V2.2 (87 classes: `Nodes` 65 classes, `Nodes.Logic` 22 classes)  
> **Mục tiêu chuyển đổi**: Unity 2022.3.62f3 Mono C# $\to$ Godot 4.6.2 Stable (GDScript Resource-based Graph Engine & Story Navigator)  
> **Nguyên tắc cốt lõi**: Khôi phục 100% cơ chế định tuyến cổng (Port Routing), luồng hội thoại có người dẫn truyện/nhân vật, chuỗi tutorial tương tác, và khớp nối 18 Story Graphs đã giải mã ở TASK-0015 `[V]`.

---

## 1. Tổng Quan Kiến Trúc V2.2 & Mô Hình Thực Thi Đồ Thị

Trong *Dupery*, toàn bộ cốt truyện, hội thoại mở đầu các vùng (Cutscenes), chuỗi hướng dẫn người chơi (Tutorials), và phân bổ bộ vai trò vùng (RoleSets) được xây dựng trên nền tảng **Đồ thị Nút (Node Graph Architecture)** thông qua thư viện `XNode`:
- Có tổng cộng **18 Story Graphs** (trong `data/graphs/story_graphs/`): 4 cutscene giới thiệu (`CasinoIntro`, `DocksIntro`, `SyndicateIntro`, `TemplateTransition`) và 14 tutorial graphs (trong đó `Of_Tutorial_6` có 53 nodes).
- Có tổng cộng **68 RoleSets Graphs** (trong `data/graphs/role_sets_graphs.json` với 335 nodes).

```
                          [StoryNodeGraph]
                                 │
                         fetchStartNode()
                                 │
                         [StoryStartNode]
                                 │ (exit port)
                                 ▼
                     [StoryDialogueNode] ◄── [BasicStringNode / AdvancedStringNode]
                         │ (enter/exit)  ◄── [StoryEventActionNode / WaitEventNode]
                         │
           ┌─────────────┴─────────────┐
 (branch)  ▼                           ▼ (linear exit)
 [StoryGateNode / Predicate]     [StoryDialogueNode]
           │                           │
           └─────────────┬─────────────┘
                         ▼
                  [StoryEndNode]
                         │
              _navigator.onStoryFinish()
```

---

## 2. Bảng Phân Bổ 87 Classes Theo Phân Hệ Chức Năng

### 2.1. Động Cơ Đồ Thị Truyện (`Nodes` — 65 Classes)

| Phân nhóm | Classes C# | Cơ chế nghiệp vụ | Ánh xạ Godot 4 |
| :--- | :--- | :--- | :--- |
| **Graph Core (11)** | `StoryNodeGraph`, `NodeGraphBase`, `NodeBase`, `StoryNodeBase`, `StoryStartNode`, `StoryEndNode`, `StoryGateNode`, `StoryRerouteNode`, `StoryVariableNode`, `StoryWaitClickNode`, `StoryWaitActionNode` | Quản lý vòng đời đồ thị, duyệt nút từ Start $\to$ End, định tuyến cổng `exit`/`enter`, chờ click chuột người chơi | `Resource` (`StoryGraph.gd`), `RefCounted` (`StoryNode.gd`) |
| **Dialogue & Events (10)** | `StoryDialogueNode`, `DialogueSpeachers`, `StoryEventNodeBase`, `StoryEventActionNode`, `WaitEventNode`, `WaitRandomEventNode`, `FlashLightningTransition`, `IStoryGraphNavigator`, `IEventsRunner`, `IMustEndEvent` | Hiển thị lời thoại theo nhân vật (`NARRATOR`, `DETECTIVE`, v.v.), kích hoạt sự kiện âm thanh/camera/flash, đợi sự kiện kết thúc | `Control` (`DialogueBox.gd`), `Node` (`StoryNavigator.gd`) |
| **String Engine (10)** | `StringNodeBase`, `BasicStringNode`, `AdvancedStringNode`, `InputStringNode`, `KeywordStringNode`, `SpriteAssetStringNode`, `SpriteAssets`, `WaitingStringNode`, `WrapPreviousStringNode`, `IStringFetcher` | Ghép nối xâu văn bản động, chèn từ khóa (`KeywordStringNode`), chèn sprite inline TextMeshPro (`SpriteAssetStringNode`), nạp bản địa hóa đa ngữ | `RefCounted` (`StringNode.gd`), BBCode formatting |
| **Predicates & Logic (6)** | `StoryPredicateNodeBase`, `InputTypePredicateNode`, `IPredicateNodeMarker`, `IUniversalPredicateNodeMarker`, `RoleConditionNode`, `Match` | Đánh giá điều kiện logic rẽ nhánh dựa trên trạng thái thiết bị đầu vào (Gamepad/Chuột) hoặc trạng thái vụ án | `RefCounted` (`PredicateNode.gd`) |
| **Tutorial Flow (15)** | `MoveTutorialBoxEventNode`, `PutSectionAboveTutorialEventNode`, `TransformType`, `BackgroundHoleTutorialEventNode`, `CreateObjectOnTutorialEventNode`, `CreateToolTipTutorialEventNode`, `DeleteObjectOnTutorialEventNode`, `FadeSpeakerTutorialEventNode`, `TutorialDrawOnBoardNode`, `TutorialPinOnBoardNode`, `TutorialWaitForCaseState`, `CaseState`, `TutorialWaitForSceneState`, `SceneState`, `TutorialWaitForSpecificCaseState` | Điều khiển hộp thoại chỉ dẫn, tạo lỗ mask làm nổi bật cọc ghim/thẻ nghi phạm, đợi người chơi cắm ghim hoặc kéo dây nối | `Node2D` (`TutorialController.gd`), shader mask |
| **Markers & Protocols (13)** | `ICombatComponentNodeMarker`, `ICombatObjectNode`, `ICombatRareComponentNodeMarker`, `ICombatTurnActionBehaviourNodeMarker`, `IGateNodeMarker`, `INodeActionMarker`, `INodeBackgroundEventMarker`, `INodeCameraEventMarker`, `INodeEventManipulationMarker`, `INodeEventMarker`, `INodeObjectEventMarker`, `INodeRegionEvent`, `INodeRoleSets`, `INodeStringMarker`, `EventTrigger` | Các giao diện đánh dấu phân loại nút (Type Tags / Duck Typing) phục vụ công cụ biên tập và bộ lọc | Duck typing / metadata tags |

---

### 2.2. Phân Hệ Đồ Thị Bộ Vai Trò & Vùng (`Nodes.Logic` — 22 Classes)

| Phân nhóm | Classes C# | Cơ chế nghiệp vụ | Ánh xạ Godot 4 |
| :--- | :--- | :--- | :--- |
| **Region Graphs (10)** | `RegionDataGraph`, `RegionDataNodeBase`, `RegionStartNode`, `RegionEndNode`, `RegionCaseNode`, `RegionSetsChoiceBaseNode`, `SimpleRegionSetsChoiceNode`, `SplitRegionSetsChoiceNode`, `StandardRegionSetsChoiceNode`, `ConditionalRegionSetsChoiceNode` | Quản lý cấu trúc dữ liệu vùng (Office, Docks, Casino, BackAlleys), lựa chọn bộ tình huống vụ án theo tiến trình người chơi | `Resource` (`RegionDataGraph.gd`), `RefCounted` (`RegionNode.gd`) |
| **Role Sets (12)** | `RoleSetsGraph`, `RoleSetsType`, `SetsType`, `SetsDataNode`, `SetsRoleNode`, `RoleConditionNode`, `Match`, `RoleRemovalRegionNode`, `RoleSetsConditionNodeBase`, `QuirkAdditionRegionNodeBase`, `StandardisedQuirkAdditionNode`, `QuirkAdditionType` | Đồ thị quy định nhóm vai trò xuất hiện cùng nhau, bổ sung Quirks tương ứng theo độ khó vụ án | `Resource` (`RoleSetsGraph.gd`), `RefCounted` (`SetsNode.gd`) |

---

## 3. Cơ Chế Định Tuyến Cổng (Port Routing) & Thực Thi Hội Thoại

### 3.1. Vòng Lặp Duyệt Nút (`StoryNodeBase.cs`)
Mỗi nút thực thi kế thừa `StoryNodeBase` và triển khai phương thức `progress(IStoryGraphNavigator _navigator)`:
1. Khi đến `StoryDialogueNode`:
   - Lấy văn bản từ cổng vào `content` (`StringNodeBase`), áp dụng bộ dịch đa ngữ:
     `key = $"{story_graph.localisation_graph_id} Dialogue [{UID}]"`
   - Kích hoạt toàn bộ sự kiện gắn trên cổng `events` (`StoryEventNodeBase`).
   - Gọi `_navigator.writeDialogue(speaker, text, events, callback)`.
2. Máy đánh chữ (`DialogueTextWriter`):
   - Xuất từng ký tự với tốc độ $0.03\text{s}/\text{char}$.
   - Nếu `can_skip == true`, người chơi bấm chuột sẽ hiện trọn vẹn câu ngay lập tức.
3. Chờ tương tác:
   - Nếu `wait_for_click == true`, dừng chờ người chơi bấm chuột trước khi gọi `progressNextAction(_navigator)`.
   - `getNextNodeFromOutput(_navigator, "exit")` tìm nút tiếp theo và chuyển quyền điều khiển.

---

## 4. Kiến Trúc Tái Thiết Trong Godot 4.6.2

### 4.1. Cấu Trúc Dữ Liệu Đồ Thị (`StoryGraphResource.gd`)
```gdscript
# res://scripts/story/story_graph_resource.gd
class_name StoryGraphResource
extends Resource

@export var graph_id: String = ""
@export var nodes: Dictionary = {} # node_id -> Dictionary (type, fields, inputs, outputs)
@export var start_node_id: int = -1

func fetch_start_node() -> Dictionary:
    if start_node_id != -1 and nodes.has(start_node_id):
        return nodes[start_node_id]
    for nid in nodes:
        if nodes[nid].get("type") == "StoryStartNode":
            start_node_id = nid
            return nodes[nid]
    push_error("No StoryStartNode found in graph: " + graph_id)
    return {}
```

### 4.2. Bộ Điều Phối Truyện (`StoryNavigator.gd`)
```gdscript
# res://scripts/story/story_navigator.gd
class_name StoryNavigator
extends Node

signal story_finished
signal dialogue_prompted(speaker: String, text: String)

var current_graph: StoryGraphResource
var current_node: Dictionary

func play_graph(graph: StoryGraphResource) -> void:
    current_graph = graph
    current_node = graph.fetch_start_node()
    _progress_current()

func _progress_current() -> void:
    var node_type: String = current_node.get("type", "")
    match node_type:
        "StoryStartNode", "StoryRerouteNode":
            _step_next("exit")
        "StoryDialogueNode":
            var speaker: String = current_node.get("speaker", "NARRATOR")
            var text: String = current_node.get("raw_text", "")
            dialogue_prompted.emit(speaker, text)
        "StoryEndNode":
            story_finished.emit()

func advance_dialogue() -> void:
    _step_next("exit")

func _step_next(port_name: String) -> void:
    var outputs: Array = current_node.get("outputs", {}).get(port_name, [])
    if outputs.is_empty():
        story_finished.emit()
        return
    var next_id: int = outputs[0]
    if current_graph.nodes.has(next_id):
        current_node = current_graph.nodes[next_id]
        _progress_current()
    else:
        story_finished.emit()
```

---

## 5. Danh Mục Thẩm Định Thực Nghiệm Đồ Thị (DEC-26)

| Đồ thị kiểm thử thực tế | Số lượng Nodes | Node bắt đầu | Node kết thúc | Nhãn xác minh |
| :--- | :---: | :---: | :---: | :---: |
| `CasinoIntro` (Cutscene) | 12 | `StoryStartNode` (ID 0) | `StoryEndNode` (ID 11) | `[V]` Khớp 100% |
| `DocksIntro` (Cutscene) | 15 | `StoryStartNode` (ID 0) | `StoryEndNode` (ID 14) | `[V]` Khớp 100% |
| `SyndicateIntro` (Cutscene) | 18 | `StoryStartNode` (ID 0) | `StoryEndNode` (ID 17) | `[V]` Khớp 100% |
| `Of_Tutorial_6` (Tutorial) | 53 | `StoryStartNode` (ID 0) | `StoryEndNode` (ID 52) | `[V]` Khớp 100% |

---
*Tài liệu cẩm nang giải phẫu hoàn thiện cho toàn bộ 87 classes của Vòng V2.2 theo chuẩn DEC-21 và ADR-0010.*
