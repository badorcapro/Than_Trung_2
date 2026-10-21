# Cẩm Nang Tái Thiết Kiến Trúc V5.3: Thực Thể Vụ Án, Địa Điểm & Cấu Trúc Bổ Trợ (232 Classes)

> **Mã định danh**: `DOC-V5C-HANDBOOK`  
> **Phạm vi tái thiết**: Vòng V5.3 (232 classes cuối cùng của Vòng V5, hoàn thiện trọn bộ 496 classes)  
> **Mục tiêu chuyển đổi**: Unity 2022.3.62f3 Mono C# $\to$ Godot 4.6.2 Stable (Case Lifecycle State Machine, Location Nodes & Hazard System)  
> **Nguyên tắc cốt lõi**: Khôi phục 100% vòng đời hồ sơ vụ án (`CaseSnapshot`), hệ thống phân tầng địa điểm (`LocationData`), và cơ chế xử lý mối nguy hiểm trên bàn cờ (`Bomb`, `BloodTrace`) `[V]`.

---

## 1. Tổng Quan Kiến Trúc Vòng V5.3: Thực Thể & Dữ Liệu Vụ Án

Vòng V5.3 cấu thành nền tảng dữ liệu thực thể của thế giới phá án *Dupery*, liên kết giữa hồ sơ vụ án (`Case`), các địa điểm điều tra (`LocationData`), và các mối nguy hiểm bất ngờ nảy sinh trong quá trình điều tra:

```
┌─────────────────────────────────┐
│         CaseHandler.gd          │
│   (Điều phối vòng đời vụ án:    │
│    Init -> Snapshot -> Reward)  │
└────────────────┬────────────────┘
                 │
        ┌────────┴────────┐
        ▼                 ▼
┌───────────────┐ ┌───────────────┐
│ LocationNodes │ │ HazardSystem  │
│ (Bản đồ địa   │ │ (Xử lý bom,   │
│  bàn 4 vùng)  │ │  vết máu...)  │
└───────────────┘ └───────────────┘
```

---

## 2. Bảng Phân Bổ 232 Classes Theo Phân Hệ Chức Năng

### 2.1. Thực Thể Vụ Án & Vòng Đời Tiến Trình (`Case Entities` — 45 Classes)

| Nhóm chức năng | Classes C# tiêu biểu | Vai trò nghiệp vụ trong game gốc | Ánh xạ Godot 4 |
| :--- | :--- | :--- | :--- |
| **Vòng Đời Vụ Án (15)** | `Case`, `CaseActionPayload`, `CaseBuildData`, `CaseHandler`, `CaseHelper`, `CaseNotes`, `CaseRatioBuilderData`, `CaseReputationManager`, `CaseReward`, `CaseSnapshot`, `CaseState`, `CaseType` | Quản lý dữ liệu một vụ án đang phá, lưu trữ ảnh chụp trạng thái bàn cờ (`CaseSnapshot`) để hoàn nguyên hoặc tính điểm | `Resource` (`CaseResource.gd`), `RefCounted` (`CaseSnapshot.gd`) |
| **Biến Thể Địa Bàn (30)** | `CasinoCase`, `CasinoCaseActionPayload`, `CasinoCaseReward`, `CasinoCaseSnapshot`, `DocksCase`, `DocksCaseActionPayload`, `DocksCaseReward`, `DocksCaseSnapshot`, `ClockCase`, `ClockCaseActionPayload`, `ClockCaseReward`, `ClockCaseSnapshot`, `BackAlleyCase`, v.v. | Các hồ sơ vụ án chuyên biệt cho từng vùng với phần thưởng và tỷ lệ sinh nghi phạm đặc thù | Kế thừa `CaseResource.gd` |

---

### 2.2. Hệ Thống Dữ Liệu Địa Điểm & Bản Đồ Vùng (`Location Data` — 35 Classes)

| Nhóm chức năng | Classes C# tiêu biểu | Vai trò nghiệp vụ trong game gốc | Ánh xạ Godot 4 |
| :--- | :--- | :--- | :--- |
| **Địa Điểm Khảo Sát (20)** | `LocationData`, `LocationHelper`, `LocationInfo`, `LocationMarker`, `LocationPlacement`, `LocationVisualData`, `LocationAbilityData`, `LocationActionData` | Xác định tọa độ các điểm nghi phạm có thể xuất hiện trên bản đồ địa bàn, cung cấp manh mối bối cảnh | `Resource` (`LocationData.gd`), `Marker2D` (`LocationMarker.gd`) |
| **Trạng Thái Vùng (15)** | `RegionDataSO`, `_dep_RegionState`, `_dep_CasinoRegionState`, `_dep_ClockRegionState`, `_dep_DocksRegionState`, `_dep_BackAlleysRegionState` | Quản lý thông tin môi trường, mức độ nguy hiểm và độ danh tiếng của từng khu vực | `Resource` (`RegionDataResource.gd`) |

---

### 2.3. Mối Nguy Hiểm & Thực Thể Minigame (`Investigation Hazards` — 25 Classes)

| Classes C# | Vai trò kỹ thuật & Cơ chế nghiệp vụ | Ánh xạ Godot 4 |
| :--- | :--- | :--- |
| `Bomb`, `BombThreat` | Quả bom hẹn giờ nảy sinh trên bàn cờ, đếm ngược số lượt cắm ghim; nếu không gỡ sẽ phát nổ gây trừ nặng danh tiếng | `Node2D` (`BombHazard.gd`) |
| `BloodTrace`, `BreachOfTrust` | Vết máu và dấu hiệu phản bội làm nhiễu loạn dây nối nỉ giữa các nghi phạm | Shader vết máu, modifier |
| `CasinoCard`, `CasinoCardInfo`, `Suit` | Bộ bài Tây và hệ thống chất bài (Cơ, Rô, Chuồn, Bích) phục vụ minigame tại sòng bạc | `Resource` (`PlayingCard.gd`) |
| `BugReporter`, `BugReporterHelper` | Công cụ ghi nhận lỗi nội bộ của game gốc | Hệ thống Logger nội bộ |

---

### 2.4. Cấu Trúc Bổ Trợ, Menu & Enums Dữ Liệu (`Supporting Structs` — 127 Classes)

Bao gồm các enum, struct dữ liệu và component hỗ trợ giao diện:
- `Alignments`, `Direction`, `B_InfoType`, `Achiements`, `AchiementStats`, `AdjustableText`, `AdvancedGenerationConstraint`, `BackgroundState`, `TransformAnimationTarget`, `StatsRegionSection`, `ShortcutKeybinds`, v.v.
- Ánh xạ sang Godot 4: Các `enum` toàn cục (`res://scripts/core/enums.gd`), các `Dictionary` cấu hình và component giao diện phụ trợ.

---

## 3. Kiến Trúc Tái Thiết Trong Godot 4.6.2

### 3.1. Quản Lý Vòng Đời Vụ Án (`CaseHandler.gd`)
```gdscript
# res://scripts/case/case_handler.gd
class_name CaseHandler
extends Node

signal case_snapshot_created(snapshot: Dictionary)
signal case_completed(reward: Dictionary)

var current_case: Resource
var active_hazards: Array = []

func create_snapshot(board_state: Array) -> Dictionary:
    var snapshot: Dictionary = {
        "timestamp": Time.get_unix_time_from_system(),
        "case_id": current_case.get("case_id", ""),
        "suspect_count": board_state.size(),
        "hazards": active_hazards.duplicate()
    }
    case_snapshot_created.emit(snapshot)
    return snapshot

func defuse_hazard(hazard_node: Node) -> bool:
    if active_hazards.has(hazard_node):
        active_hazards.erase(hazard_node)
        hazard_node.queue_free()
        return true
    return false
```

---

## 4. Danh Mục Thẩm Định Thực Nghiệm 60fps (DEC-26)

| Tình huống tương tác | Hành vi bản gốc | Tiêu chí thẩm định Godot 4 | Trạng thái |
| :--- | :--- | :--- | :---: |
| **Kích hoạt Bom hẹn giờ** | Tiếng tích tắc đếm ngược theo từng thao tác ghim, tia lửa nhấp nháy | Timer pulse Tween + SFX `bomb_tick` | `[V]` Đã mô hình |
| **Vết máu BloodTrace** | Vệt máu đỏ loang nhẹ trên mặt bàn làm đổi màu dây nối đi qua | Shader alpha overlay đỏ + raycast check | `[V]` Đã mô hình |
| **Lưu Snapshot vụ án** | Hiệu ứng chớp màn hình nhẹ như chụp ảnh, ghi nhận trạng thái | CanvasModulate flash $0.1\text{s}$ | `[V]` Đã mô hình |

---
*Tài liệu cẩm nang giải phẫu hoàn thiện cho toàn bộ 232 classes còn lại của Vòng V5 (hoàn tất 496/496 classes V5) theo chuẩn DEC-21 và ADR-0010.*
