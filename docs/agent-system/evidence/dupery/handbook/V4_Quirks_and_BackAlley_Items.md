# Cẩm Nang Tái Thiết Kiến Trúc V4: Hệ Thống Biến Tố Quirk & Vật Phẩm Chợ Đen (101 Classes)

> **Mã định danh**: `DOC-V4-HANDBOOK`  
> **Phạm vi tái thiết**: Vòng V4 (101 classes: `Quirks` 59 classes, `BackAlleyItems` 11 classes, `ItemFan` & Quản lý phụ trợ 31 classes)  
> **Mục tiêu chuyển đổi**: Unity 2022.3.62f3 Mono C# $\to$ Godot 4.6.2 Stable (Modifier Pipeline, Item Hand Fan & Inventory System)  
> **Nguyên tắc cốt lõi**: Khôi phục 100% cơ chế can thiệp luật chơi của biến tố (Quirk Modifiers), hiệu ứng trang bị chợ đen, và giải thuật bố cục quạt thẻ bài hình cánh cung `[V]`.

---

## 1. Tổng Quan Kiến Trúc Vòng V4: Biến Tố & Trang Bị Điều Tra

Trong *Dupery*, độ biến hóa và khả năng chơi lại (Replayability) của từng vụ án phụ thuộc vào sự kết hợp giữa **Quirks** (các biến tố luật chơi làm tăng độ khó hoặc thay đổi hành vi nghi phạm) và **BackAlley Items** (các công cụ hỗ trợ người chơi mua từ Chợ đen):

```
┌───────────────────────┐         ┌────────────────────────┐
│     Active Quirks     │ ──────► │ Investigation Pipeline │ ◄────── │  BackAlley Items Hand  │
│  (Biến tố can thiệp   │         │ (Áp dụng modifiers lên │         │ (Quạt thẻ bài vật phẩm │
│   luật chơi vụ án)    │         │  bảng, thẻ & manh mối) │         │  hỗ trợ trên tay)      │
└───────────────────────┘         └────────────────────────┘         └────────────────────────┘
```

---

## 2. Bảng Phân Bổ 101 Classes Theo Phân Hệ Chức Năng

### 2.1. Phân Hệ Biến Tố Vụ Án (`Quirks` — 59 Classes)

| Nhóm chức năng | Classes C# tiêu biểu | Cơ chế can thiệp luật chơi | Ánh xạ Godot 4 |
| :--- | :--- | :--- | :--- |
| **Nhịp độ & Thời gian (4)** | `BrokenClock`, `FaultyClock`, `TickingClock`, `NightShift` | Giới hạn số lượt bốc manh mối hoặc rút ngắn thời gian suy luận | `Resource` (`TimeQuirk.gd`) |
| **Tầm nhìn & Giấu giếm (4)** | `MistyStreets`, `EvilGaze`, `HiddenSmirk`, `ShotInTheDark` | Che khuất một số đặc điểm nhận dạng của nghi phạm, làm mờ ảnh thẻ bài | Shader làm mờ, `VisionQuirk.gd` |
| **Xác suất & Đỏ đen (5)** | `GamblersFallacy`, `GoodIntuition`, `RiskReward`, `RiggedDeck`, `SoulRead` | Can thiệp vào tỷ lệ xuất hiện manh mối hiếm, x2 điểm thưởng hoặc mất trắng danh tiếng | `Resource` (`ProbabilityQuirk.gd`) |
| **Tổ chức & Trung thành (5)**| `DirtyCop`, `InsiderLoyalty`, `OutsiderLoyalty`, `PublicUnrest`, `SilentAccomplice` | Buộc các nghi phạm cùng tổ chức Syndicate bao che lẫn nhau hoặc đưa ra lời khai giả | `Resource` (`SyndicateQuirk.gd`) |
| **Quy tắc Bàn & Thẻ (15)** | `DrawLeft`, `DrawRight`, `AgileFingers`, `AntiAuthoritarianism`, `BadInfluences`, `DecisionParalysis`, `EvilSuspects`, `HarshWaters`, `Haunted`, `HideAndSeek`, `HighValueTarget`, `Jealousy`, `LostAtSea`, `LoyaltyCard`, `MedicalBreakthrough` | Thay đổi hướng rút bài, giới hạn số dây nối nỉ, đảo vị trí thẻ bài | `Resource` (`BoardQuirk.gd`) |
| **Quy tắc Đặc biệt (26)** | `MortalDread`, `Paranoia`, `PerfectCrime`, `PokerFace`, `PocketPair`, `PublicFavour`, `RadioInterference`, `Refuel`, `RegalHand`, `Sailboat`, `Setup`, `Shrink`, `SilentMutiny`, `SpectresDream`, `SwiftJustice`, `ThatSmile`, `UnholyLand`, `ViolentPiracy`, `VisibleJustice`, `CruelSeas`, `DarkWhispers`, `DeadlyAim`, `DeadlyRoyals`, `FaultyGauge`, `CaseQuirkData` | Các điều kiện thắng/thua phụ, biến đổi đặc biệt theo từng địa bàn vụ án | `Resource` (`RuleModifier.gd`) |

---

### 2.2. Phân Hệ Trang Bị Chợ Đen (`BackAlleyItems` — 11 Classes)

| Classes C# | Cơ chế nghiệp vụ trong game gốc | Ánh xạ Godot 4 |
| :--- | :--- | :--- |
| `BundleOfString` | Cung cấp thêm dây nối nỉ dự phòng khi người chơi hết tài nguyên cắm ghim | Tăng `remaining_yarn_count` |
| `CertificateOfCredit` | Cho phép vay tiền hoặc hoãn trừ danh tiếng trong một vụ án | Modifier danh tiếng |
| `EvilMonocle` | Soi thấu và lật mở ngay một đặc điểm ẩn của nghi phạm được chỉ định | Kích hoạt lật thẻ tức thì |
| `FalsePoliceBadge` | Miễn nhiễm với các Quirk gây nhiễu loạn điều tra | Hủy bỏ 1 Quirk tiêu cực |
| `FamilialLocket` | Bảo hiểm danh tiếng: nếu cáo buộc sai, không bị trừ danh tiếng | Flag `reputation_shield` |
| `FlipKnife` | Cắt đứt toàn bộ dây nối kết nối với một nghi phạm bị nghi ngờ oan | Gọi hàm `StringManager.clear_node` |
| `Lighter` | Thiêu hủy một manh mối gây nhiễu loạn để bốc lại manh mối khác | Hủy Clue hiện tại |
| `SkepticLoop` | Kính lúp phóng đại làm lộ ra các chi tiết nhỏ trên thẻ bài nghi phạm | Tương tác kính lúp |
| `StabVest` | Áo giáp chống đâm: bảo vệ người chơi trước các biến cố nguy hiểm | Tăng sinh mạng điều tra |
| `ThreeShotRevolver` | Trấn áp nghi phạm: ép buộc một nghi phạm trên bục Lineup phải khai thật | Buộc tiết lộ thông tin |
| `WadOfCash` | Hối lộ nhân chứng để lấy trực tiếp một manh mối cấp cao | Thêm Clue cao cấp |

---

### 2.3. Phân Hệ Quạt Bài Vật Phẩm Trên Tay (`ItemFan` & Quản Lý Phụ Trợ — 31 Classes)

Bao gồm `ItemFanManager`, `ItemFanVisual`, `ItemSlotVisual`, `QuirkVisualManager`, `QuirkSlot`, và các ScriptableObjects định nghĩa dữ liệu hiển thị:
- **Giải thuật bố cục cánh cung (Radial Arc Fan)**:
  $$x_i = R \cdot \sin(\theta_i), \quad y_i = R \cdot (1 - \cos(\theta_i))$$
  $$\text{với } \theta_i = \left(i - \frac{N-1}{2}\right) \cdot \Delta\theta$$
- Khi di chuột hover lên thẻ bài thứ $i$: Thẻ bài nâng cao lên trục Y một khoảng $\Delta y = -40\text{px}$, góc xoay dựng đứng về $0^\circ$ và tỷ lệ phóng đại $1.15\times$ giúp người chơi đọc rõ chi tiết.

---

## 3. Kiến Trúc Tái Thiết Trong Godot 4.6.2

### 3.1. Tài Nguyên Quirk & Modifier Pipeline (`QuirkResource.gd`)
```gdscript
# res://scripts/quirks/quirk_resource.gd
class_name QuirkResource
extends Resource

@export var id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var is_positive: bool = false
@export var modifier_type: String = "" # TIME, VISION, PROBABILITY, BOARD
@export var value_modifier: float = 1.0

func apply_modifier(context: Dictionary) -> void:
    match modifier_type:
        "REPUTATION_MULTIPLIER":
            context["reputation_mult"] = context.get("reputation_mult", 1.0) * value_modifier
        "MAX_CLUES":
            context["max_clues"] = int(context.get("max_clues", 5) + value_modifier)
```

### 3.2. Bố Cục Quạt Bài Hình Cánh Cung (`ItemFanContainer.gd`)
```gdscript
# res://scripts/ui/item_fan_container.gd
class_name ItemFanContainer
extends Control

@export var radius: float = 500.0
@export var angle_step_deg: float = 6.0

func layout_fan() -> void:
    var cards: Array = get_children()
    var count: int = cards.size()
    if count == 0:
        return
    for i in range(count):
        var card: Control = cards[i]
        var offset_idx: float = float(i) - float(count - 1) / 2.0
        var angle_rad: float = deg_to_rad(offset_idx * angle_step_deg)
        var px: float = radius * sin(angle_rad)
        var py: float = radius * (1.0 - cos(angle_rad))
        card.position = Vector2(px, py)
        card.rotation = angle_rad
```

---

## 4. Danh Mục Thẩm Định Thực Nghiệm 60fps (DEC-26)

| Tình huống tương tác | Hành vi bản gốc | Tiêu chí thẩm định Godot 4 | Trạng thái |
| :--- | :--- | :--- | :---: |
| **Xòe quạt vật phẩm** | Thẻ bài trượt ra từ góc dưới màn hình và xòe thành hình cung trong $0.3\text{s}$ | Tween position & rotation đồng thời | `[V]` Đã mô hình |
| **Hover thẻ bài** | Thẻ bài nâng lên, xoay thẳng $0^\circ$, phóng to $1.15\times$, âm thanh lướt giấy | Tween TRANS_SINE trong $0.15\text{s}$ | `[V]` Đã mô hình |
| **Sử dụng vật phẩm** | Thẻ biến mất, tạo hiệu ứng hạt/chớp sáng và cập nhật bàn điều tra | Tween fade out và signal kích hoạt | `[V]` Đã mô hình |

---
*Tài liệu cẩm nang giải phẫu hoàn thiện cho toàn bộ 101 classes của Vòng V4 theo chuẩn DEC-21 và ADR-0010.*
