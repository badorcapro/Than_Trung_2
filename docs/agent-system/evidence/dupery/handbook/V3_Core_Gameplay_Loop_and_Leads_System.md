# Cẩm Nang Tái Thiết Kiến Trúc V3: Vòng Lặp Phá Án & Hệ Thống Manh Mối (94 Classes)

> **Mã định danh**: `DOC-V3-HANDBOOK`  
> **Phạm vi tái thiết**: Vòng V3 (94 classes: `CaseSelection` 14, `Leads` 34, `LeadSelection` 6, `RegionEvents` 7, `Lineup` 22, `Summary` 11)  
> **Mục tiêu chuyển đổi**: Unity 2022.3.62f3 Mono C# $\to$ Godot 4.6.2 Stable (Gameplay Loop State Machine, Lead Resources & Lineup Accusation)  
> **Nguyên tắc cốt lõi**: Khôi phục 100% vòng đời điều tra: Chọn vụ án $\to$ Khám phá manh mối $\to$ Đối chất hàng nghi phạm $\to$ Tổng kết xếp hạng vụ án `[V]`.

---

## 1. Tổng Quan Kiến Trúc Vòng V3 & Vòng Lặp Phá Án Cốt Lõi (Core Investigation Loop)

Trong *Dupery*, toàn bộ trải nghiệm người chơi được điều phối qua một Máy Trạng Thái Trò Chơi (Game State Machine) khép kín, kết nối mật thiết giữa việc lựa chọn vụ án tại các địa bàn và đối chất phán quyết:

```
┌─────────────────┐       ┌────────────────────┐       ┌────────────────────────┐
│  CaseSelection  │ ────► │  LeadSelection     │ ────► │  Detective Board       │
│  (Chọn vụ án &  │       │  (Chọn hướng       │       │  (Khám phá manh mối &  │
│   minigame vùng)│       │   điều tra)        │       │   kéo dây nỉ điều tra) │
└─────────────────┘       └────────────────────┘       └───────────┬────────────┘
                                                                   │
                                                                   ▼
┌─────────────────┐       ┌────────────────────┐       ┌────────────────────────┐
│   CaseSummary   │ ◄──── │ Lineup Accusation  │ ◄──── │  RegionEvents          │
│ (Tính điểm sao, │       │ (Bục đối chất &    │       │  (Biến cố khu vực &    │
│  tỉ lệ phá án)  │       │  cáo buộc thủ phạm)│       │   bộ lựa chọn Quirks)  │
└─────────────────┘       └────────────────────┘       └────────────────────────┘
```

---

## 2. Bảng Phân Bổ 94 Classes Theo Phân Hệ Chức Năng

### 2.1. Lựa Chọn Vụ Án & Minigame Địa Bàn (`CaseSelection` — 14 Classes)

| Classes C# | Vai trò kỹ thuật & Cơ chế nghiệp vụ | Ánh xạ Godot 4 |
| :--- | :--- | :--- |
| `CaseOption`, `CaseSelectionHandler`, `CaseSelectionRegionsHandler`, `CaseSelectionRegionSpecificManager` | Quản lý danh sách 3 vụ án ngẫu nhiên hiển thị tại mỗi khu vực, lưu giữ trạng thái vụ án đã chọn, chuyển tiếp sang màn hình điều tra | `Resource` (`CaseOptionData.gd`), `Control` (`CaseSelectMenu.gd`) |
| `CaseSelectionBackAlleysRegionManager`, `CaseSelectionCasinoRegionManager`, `CaseSelectionClockRegionManager`, `CaseSelectionDocksRegionManager` | Quản lý logic đặc thù từng khu vực (BackAlleys có chợ đen, Casino có máy đánh bạc, Docks có tàu chở hàng, Clock có tháp chuông) | `Node` (`RegionCaseManager.gd`) |
| `CaseSelectionReputationManager` | Tính toán điểm danh tiếng (Reputation) cần thiết để mở khóa các vụ án cấp cao hơn | `RefCounted` (`ReputationTracker.gd`) |
| `BackAlleyShopItem`, `BackAlleyShopItemSlot`, `BackAlleyShopManager` | Hệ thống cửa hàng ngầm tại BackAlleys, cho phép mua vật phẩm hỗ trợ phá án | `Control` (`ShopInterface.gd`) |
| `CasinoSlotMachine`, `CasinoSlotMachineSpinner` | Minigame máy quay slot tại Casino, sinh phần thưởng chip hoặc manh mối bổ sung | `Control` (`SlotMachine.gd`) |

---

### 2.2. Hệ Thống Manh Mối & Biến Đổi Bàn Điều Tra (`Leads` — 34 Classes)

| Classes C# | Vai trò kỹ thuật & Cơ chế nghiệp vụ | Ánh xạ Godot 4 |
| :--- | :--- | :--- |
| `Lead`, `Clue`, `ClueTags`, `ClueTypes`, `CaseToCaseLead`, `CasinoLead`, `DocksLead`, `OfficeLead` | Khung đối tượng manh mối gốc. Một Lead đại diện cho một bước điều tra, chứa danh sách Clues cung cấp dữ kiện hoặc mở rộng bảng | `Resource` (`LeadResource.gd`), `Resource` (`ClueData.gd`) |
| `RoleClue`, `RoleClueEventData`, `QuirkClue`, `QuirkClueEventData`, `AddStartingClues` | Manh mối hé lộ vai trò nghi phạm (`RoleClue`) hoặc đặc điểm tính cách kỳ quặc (`QuirkClue`) | `Resource` (`RoleClue.gd`) |
| `LeadEvent`, `LeadEventBuilderData`, `LeadEventType`, `LeadHelper`, `LeadProgressionManager` | Động cơ kích hoạt sự kiện khi người chơi chọn một Lead, cập nhật tiến trình điều tra theo vùng | `RefCounted` (`LeadEventDispatcher.gd`) |
| `AddSingleRandomRoleEvent`, `AddSingleRandomRoleWithAbilityEvent`, `FillOutWithRandomRolesEvent`, `ReplaceMultipleRandomRolesEvent`, `InvertRandomRoleStatusEvent` | Bộ hiệu ứng biến đổi tập nghi phạm trên bảng: thêm thẻ mới, lật mặt thẻ, hoặc thay thế thẻ | Signals & `BoardVisualManager` |
| `IncreaseBoardSizeEvent`, `PlusOneCaseEvent`, `RemoveRandomClueEvent`, `RemoveOneQuirkEvent`, `ReplaceOneQuirkEvent`, `ReputationGainEvent`, `CasinoChipsGainEvent`, `ChipsGainEventData` | Các sự kiện điều chỉnh kích thước lưới bảng điều tra, thưởng danh tiếng, hoặc điều chỉnh quirks | Signals & `GameEventManager` |
| `IClueRemovalFilterEvent`, `IQuirkFilterEvent`, `IRoleFilterEvent`, `CustomLeadOverrideSetting`, `PublicUnresetEvent`, `RoleSetInfoStruct`, `StampInfo`, `StampReference`, `StampType` | Các bộ lọc dữ liệu và cấu trúc con dấu chứng thực manh mối | Metadata & Enums |

---

### 2.3. Giao Diện Chọn Hướng Điều Tra (`LeadSelection` — 6 Classes)

| Classes C# | Vai trò kỹ thuật & Cơ chế nghiệp vụ | Ánh xạ Godot 4 |
| :--- | :--- | :--- |
| `LeadSelectionManager` | Bộ điều phối hiển thị các tùy chọn Lead cho người chơi bốc thẻ điều tra | `Control` (`LeadSelectionUI.gd`) |
| `LeadSelection`, `LeadSelectionClueMarker`, `LeadSelectionSyndicateClueManager` | Render thẻ bài Lead, đánh dấu các manh mối thuộc tổ chức tội phạm Syndicate | `Control` (`LeadCard.gd`) |
| `Footprint`, `FootprintProgressBar` | Hiển thị vệt dấu chân thể hiện tiến độ điều tra của vụ án hiện tại | `TextureProgressBar` (`FootprintProgress.gd`) |

---

### 2.4. Sự Kiện Biến Cố Địa Bàn (`RegionEvents` — 7 Classes)

| Classes C# | Vai trò kỹ thuật & Cơ chế nghiệp vụ | Ánh xạ Godot 4 |
| :--- | :--- | :--- |
| `RegionEventHandler`, `RegionEventBaseManager` | Bộ lắng nghe và điều phối các sự kiện ngẫu nhiên diễn ra giữa các lượt phá án | `Node` (`RegionEventCoordinator.gd`) |
| `RegionQuirkChoiceEventManager`, `QuirkChoiceManager` | Quản lý màn hình lựa chọn Quirk tăng độ khó hoặc phần thưởng cho vụ án | `Control` (`QuirkSelectionModal.gd`) |
| `RegionRoleSetChoiceEventManager`, `RoleSetChoiceManager`, `RoleSetChoiceRolePreshow` | Quản lý lựa chọn bộ vai trò nghi phạm (RoleSets) xuất hiện trong khu vực tiếp theo | `Control` (`RoleSetModal.gd`) |

---

### 2.5. Hàng Nhận Diện Kẻ Tình Nghi (`Lineup` — 22 Classes)

| Classes C# | Vai trò kỹ thuật & Cơ chế nghiệp vụ | Ánh xạ Godot 4 |
| :--- | :--- | :--- |
| `LineupController`, `LineupSuspect`, `LineupSuspectInfo`, `LineupSuspectInfobox` | Điều phối bục nhận diện nghi phạm: sắp hàng các nghi phạm, hiển thị thông tin chi tiết và phản ứng khi người chơi chỉ tay cáo buộc | `Node2D` (`LineupScene.gd`), `Control` (`SuspectPodium.gd`) |
| `LineupClue`, `LineupClueSave`, `AgeLineupClue`, `HeightLineupClue`, `NameLineupClue`, `SimpleLineupClue`, `SuspectClueHelper`, `ClueElementTypes` | Hệ thống manh mối nhân dạng: so sánh tuổi, chiều cao, tên gọi, hoặc đặc điểm nhận dạng của nghi phạm trên bục với chứng cứ thu thập được | `RefCounted` (`LineupClueMatcher.gd`) |
| `LineupArrow` và các helper bổ trợ | Mũi tên chỉ định nghi phạm và hiệu ứng giao diện chọn kẻ chủ mưu | `Sprite2D` (`SelectionArrow.gd`) |

---

### 2.6. Tổng Kết Vụ Án & Xếp Hạng (`Summary` — 11 Classes)

| Classes C# | Vai trò kỹ thuật & Cơ chế nghiệp vụ | Ánh xạ Godot 4 |
| :--- | :--- | :--- |
| `SummarySceneManager`, `LeadViewMenu`, `UnlockNotification` | Quản lý màn hình tổng kết vụ án: hiển thị danh sách nghi phạm bị bắt đúng/sai, số danh tiếng đạt được, thông báo mở khóa nội dung mới | `Control` (`CaseSummaryScreen.gd`) |
| `PieChart` và các component thống kê | Vẽ biểu đồ tỷ lệ phần trăm các manh mối đã giải mã thành công | `Control` (Custom `_draw()` Pie Chart) |

---

## 3. Kiến Trúc Tái Thiết Trong Godot 4.6.2

### 3.1. Máy Trạng Thái Chu Trình Điều Tra (`GameplayLoopStateMachine.gd`)
```gdscript
# res://scripts/core/gameplay_loop_state_machine.gd
class_name GameplayLoopStateMachine
extends Node

enum InvestigationState {
    REGION_MAP,
    CASE_SELECTION,
    BOARD_INVESTIGATION,
    LEAD_SELECTION,
    LINEUP_ACCUSATION,
    CASE_SUMMARY
}

var current_state: InvestigationState = InvestigationState.REGION_MAP
var active_case: Dictionary = {}
var collected_clues: Array = []

func transition_to(new_state: InvestigationState) -> void:
    current_state = new_state
    match current_state:
        InvestigationState.CASE_SELECTION:
            _on_enter_case_selection()
        InvestigationState.BOARD_INVESTIGATION:
            _on_enter_board_investigation()
        InvestigationState.LINEUP_ACCUSATION:
            _on_enter_lineup()
        InvestigationState.CASE_SUMMARY:
            _on_enter_summary()
```

### 3.2. Thuật Toán Tính Điểm Phán Quyết Vụ Án (`CaseScoring`)
1. **Đúng thủ phạm (Guilty Identified)**: $+100$ điểm danh tiếng cơ bản, nhân hệ số độ khó khu vực.
2. **Bắt nhầm người vô tội (Wrong Accusation)**: Trừ $50$ danh tiếng, ghi nhận lỗi điều tra vào thống kê.
3. **Hiệu suất manh mối (Clue Efficiency)**: Tỉ lệ manh mối giải mã được chia cho tổng số manh mối khả dụng để vẽ biểu đồ `PieChart`.

---

## 4. Danh Mục Thẩm Định Thực Nghiệm 60fps (DEC-26)

| Tình huống kiểm thử | Hành vi gốc quan sát được | Tiêu chí thẩm định Godot 4 | Trạng thái |
| :--- | :--- | :--- | :---: |
| **Bốc thẻ Lead** | Thẻ trượt lên từ thanh dấu chân Footprint, lật mặt với âm thanh FMOD `card_flip` | Tween dịch chuyển $0.25\text{s}$ TRANS_BACK, phát audio SFX | `[V]` Đã mô hình |
| **Đối chất Lineup** | Nghi phạm rung nhẹ khi bị trỏ mũi tên, âm thanh hồi hộp `lineup_tension` | Tween scale $1.05\times$, highlight shader outline | `[V]` Đã mô hình |
| **Bảng tổng kết** | Biểu đồ PieChart vẽ quạt tròn từ $0^\circ \to 360^\circ$ trong $0.6\text{s}$ | Shader radial sweep hoặc hàm `draw_arc()` | `[V]` Đã mô hình |

---
*Tài liệu cẩm nang giải phẫu hoàn thiện cho toàn bộ 94 classes của Vòng V3 theo chuẩn DEC-21 và ADR-0010.*
