# Cẩm Nang Tái Thiết Kiến Trúc V5.2: Danh Mục 228 Vai Trò Nghi Phạm & Ma Trận Dữ Liệu (185 Classes)

> **Mã định danh**: `DOC-V5B-HANDBOOK`  
> **Phạm vi tái thiết**: Vòng V5.2 (185 classes role đang chờ xử lý, hoàn thiện trọn bộ 228 vai trò nghi phạm trong *Dupery*)  
> **Mục tiêu chuyển đổi**: Unity 2022.3.62f3 Mono C# $\to$ Godot 4.6.2 Stable (Data-Driven Custom Resource Architecture: `SuspectRoleData.gd` + `.tres`)  
> **Nguyên tắc cốt lõi**: Khôi phục 100% ma trận thuộc tính nhận dạng nghi phạm (Tuổi, Chiều cao, Giới tính, Phe phái, Khu vực hoạt động) mà không sinh ra 228 file GDScript đơn lẻ `[V]`.

---

## 1. Tổng Quan Kiến Trúc Danh Mục 228 Vai Trò Nghi Phạm

Trong *Dupery*, toàn bộ 228 vai trò nghi phạm đại diện cho các cá nhân sinh sống và làm việc tại 4 khu vực đô thị. Chúng kế thừa từ lớp cơ sở `RoleData` và các lớp biến thể địa bàn trong Unity C#:

```
                                  [RoleData]
                                       │
        ┌──────────────┬───────────────┴───────────────┬──────────────┐
        ▼              ▼                               ▼              ▼
[DocksRoleData] [CasinoRoleData]               [ClockRoleData] [BackAlleyRoleData]
  (53 roles)      (44 roles)                      (21 roles)      (6 roles)
        │              │                               │              │
        └──────────────┴───────────────┬───────────────┴──────────────┘
                                       ▼
                       [Godot 4: SuspectRoleData.gd]
                        (Resource Data-Driven .tres)
```

---

## 2. Bảng Phân Bổ 228 Vai Trò Theo 4 Địa Bàn Hoạt Động

### 2.1. Khu Vực Bến Cảng (`Docks` — 53 Roles)
- **Đặc thù địa bàn**: Gắn liền với sông nước, tàu thuyền, buôn lậu và hải sản.
- **Vai trò tiêu biểu (53)**: `Absconder`, `Boatswain`, `HarborMaster`, `Smuggler`, `Fisherman`, `Sailor`, `CargoLoader`, `Anglerfish`, `Craber`, `Diver`, `Ferryman`, `Dockworker`, `Captain`, `Marine`, `FirstMate`, `Helmsman`, `NetMaker`, `Oysterman`, `Pirate`, `Stevedore`, `TugCaptain`, `Whaler`, v.v.
- **Đặc điểm nhận dạng**: Chiều cao trung bình $170 - 190\text{cm}$, trang phục chống nước, hình xăm thủy thủ, mùi muối biển.

### 2.2. Khu Vực Sòng Bạc Hoàng Gia (`Casino` — 44 Roles)
- **Đặc thù địa bàn**: Đỏ đen, bài bạc, thế giới thượng lưu và lừa đảo chuyên nghiệp.
- **Vai trò tiêu biểu (44)**: `BigBlind`, `HighRoller`, `PitBoss`, `Croupier`, `BlackjackPlayer`, `CardShark`, `Bouncer`, `Dealer`, `CardPsychic`, `CardShuffler`, `Chauffeur`, `SlotMachine`, `LottoScratcher`, `Magician`, `Showgirl`, `CocktailWaitress`, `Bookmaker`, `ChipRunner`, `FloorManager`, v.v.
- **Đặc điểm nhận dạng**: Lịch thiệp, âu phục/váy dạ hội, mang theo bài Tây hoặc phỉnh sòng bạc, tuổi dao động từ $25 - 55$.

### 2.3. Khu Vực Tháp Đồng Hồ Cổ (`Clock Tower` — 21 Roles)
- **Đặc thù địa bàn**: Cơ khí chính xác, thời gian, sự tỉ mỉ và nhịp điệu đô thị.
- **Vai trò tiêu biểu (21)**: `Watchmaker`, `Belfry`, `Timekeeper`, `ClockEngineer`, `BellRinger`, `GearCutter`, `Horologist`, `PendulumSmith`, `Chimer`, `DialMaker`, `SpringWinder`, `TowerGuard`, `Astronomer`, `Chronographer`, v.v.
- **Đặc điểm nhận dạng**: Mang kính lúp phóng đại một mắt, dính dầu máy, đồng hồ quả quýt, tuổi trung niên $40 - 65$.

### 2.4. Khu Vực Ngõ Hẻm Chợ Đen & Trụ Sở Dân Sự (`BackAlleys & General Office` — 110 Roles)
- **Hẻm Chợ Đen (6 roles)**: `BlackMarketDealer`, `Fence`, `Locksmith`, `Forger`, `ShadowBroker`, `Pickpocket`.
- **Dân sự & Pháp đình Trụ sở (104 roles)**: `Accountant`, `Admirer`, `Artist`, `Assassin`, `BadCop`, `Barista`, `Barkeep`, `Doctor`, `Judge`, `Lawyer`, `Mayor`, `Merchant`, `Officer`, `Photographer`, `Priest`, `Reporter`, `Tailor`, `Valet`, `Waiter`, `Vigilante`, v.v.
- **Đặc điểm nhận dạng**: Đa dạng từ thường dân, công chức đến quan chức cấp cao và thành phần ngoài vòng pháp luật.

---

## 3. Kiến Trúc Data-Driven Trong Godot 4.6.2 (Quyết Định A2)

### 3.1. Tài Nguyên Vai Trò Nghi Phạm (`SuspectRoleData.gd`)
```gdscript
# res://scripts/roles/suspect_role_data.gd
class_name SuspectRoleData
extends Resource

@export var role_id: String = ""
@export var role_name: String = ""
@export var region: String = "OFFICE" # DOCKS, CASINO, CLOCK, BACKALLEYS, OFFICE
@export var is_syndicate: bool = false

# Thuộc tính nhân dạng phục vụ đối chất Lineup
@export var min_age: int = 20
@export var max_age: int = 60
@export var min_height_cm: int = 155
@export var max_height_cm: int = 195
@export var gender_presentation: String = "ANY" # MALE, FEMALE, AMBIGUOUS

# Tham chiếu hình ảnh & âm thanh
@export var portrait_sprite_name: String = ""
@export var voice_pitch_modifier: float = 1.0

# Kỹ năng tùy biến (nếu có, kế thừa từ RoleAbility.gd)
@export var ability: Resource = null
```

### 3.2. Cơ Chế Nạp Dữ Liệu Tự Động (`RoleRegistry.gd`)
Thay vì tải từng tệp thủ công, `RoleRegistry.gd` quét thư mục `res://data/roles/` và lập chỉ mục trong bộ nhớ Cache khi khởi động game:
```gdscript
# res://scripts/roles/role_registry.gd
class_name RoleRegistry
extends Node

var _roles_by_id: Dictionary = {}
var _roles_by_region: Dictionary = {}

func register_role(role: SuspectRoleData) -> void:
    _roles_by_id[role.role_id] = role
    if not _roles_by_region.has(role.region):
        _roles_by_region[role.region] = []
    _roles_by_region[role.region].append(role)

func get_roles_for_region(region_name: String) -> Array:
    return _roles_by_region.get(region_name, [])
```

---

## 4. Danh Mục Thẩm Định Thực Nghiệm 60fps (DEC-26)

| Tình huống kiểm thử | Hành vi bản gốc | Tiêu chí thẩm định Godot 4 | Trạng thái |
| :--- | :--- | :--- | :---: |
| **Hiển thị thẻ vai trò** | Thẻ bài lật mở với ảnh chân dung, tên vai trò và ký hiệu địa bàn | Tween lật mặt 3D/Scale $0.2\text{s}$ | `[V]` Đã mô hình |
| **So sánh Lineup** | Đối chiếu tuổi và chiều cao với dữ liệu thực tế của vai trò | Label format: `Tuổi: {age} | Cao: {height}cm` | `[V]` Đã mô hình |
| **Phân bổ theo Seed** | Cùng 1 seed vụ án và khu vực luôn bốc ra cùng tập vai trò | Tất định 100% qua `DotNetRandom` | `[V]` Đã mô hình |

---
*Tài liệu cẩm nang giải phẫu hoàn thiện cho toàn bộ 228 vai trò nghi phạm (cập nhật 185 classes V5B) theo chuẩn DEC-21 và ADR-0010.*
