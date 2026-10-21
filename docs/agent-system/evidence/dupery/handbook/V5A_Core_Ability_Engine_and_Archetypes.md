# Cẩm Nang Tái Thiết Kiến Trúc V5.1: Động Cơ Kỹ Năng & Vai Trò Đặc Biệt (79 Classes)

> **Mã định danh**: `DOC-V5A-HANDBOOK`  
> **Phạm vi tái thiết**: Vòng V5.1 (79 classes: Core Ability Engine 32 classes L3, 47 Special Roles có kỹ năng)  
> **Mục tiêu chuyển đổi**: Unity 2022.3.62f3 Mono C# $\to$ Godot 4.6.2 Stable (Custom Resource Ability System & Event-Driven Ability Pipeline)  
> **Nguyên tắc cốt lõi**: Khôi phục 100% cơ chế kích hoạt năng lực (Ability Triggers), chuyển hướng mục tiêu (`IChangeAbilityTargets`), và 8 mẫu hình kỹ năng đại diện `[V]`.

---

## 1. Tổng Quan Kiến Trúc Vòng V5.1: Động Cơ Kỹ Năng Nghiệp Vụ

Trong *Dupery*, các nghi phạm không chỉ là những thẻ bài tĩnh mà sở hữu các **Kỹ năng Nghiệp vụ (Abilities)** can thiệp trực tiếp vào bàn điều tra, hoán đổi thẻ bài, gây nhiễu loạn dây nối, hoặc cung cấp manh mối đặc thù:

```
┌─────────────────────────────────┐
│     Trigger Event Pipeline      │
│  (ON_BOARD_ENTER / ON_PINNED /  │
│          ON_ACCUSED)            │
└────────────────┬────────────────┘
                 │
                 ▼
┌─────────────────────────────────┐       ┌───────────────────────────────┐
│         RoleAbility.gd          │ ────► │     TargetMutationManager     │
│   (Thực thi logic kỹ năng)      │       │ (Xử lý IChangeAbilityTargets: │
│                                 │       │  hoán đổi/chuyển hướng nghi   │
│                                 │       │  phạm bị ảnh hưởng)           │
└────────────────┬────────────────┘       └───────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────┐
│     Board & Clue Mutation       │
│  (Cập nhật thẻ bài, lật mặt     │
│   hoặc sinh manh mối mới)       │
└─────────────────────────────────┘
```

---

## 2. Bảng Phân Bổ 79 Classes Theo Phân Hệ Chức Năng

### 2.1. Khung Kỹ Năng Cốt Lõi (Core Ability Engine — 32 Classes L3)

| Nhóm phân loại | Classes C# | Vai trò kỹ thuật & Cơ chế nghiệp vụ | Ánh xạ Godot 4 |
| :--- | :--- | :--- | :--- |
| **Dữ Liệu Năng Lực (7)** | `AbilityData`, `SuspectAbilityData`, `LocationAbilityData`, `CasinoCardAbilityData`, `EmptySlotAbilityData`, `AddressAbilityData`, `SpecialAbilityType` | Khung dữ liệu thuần túy định nghĩa loại kỹ năng, tham số tác động và đối tượng mục tiêu | `Resource` (`AbilityData.gd`) |
| **Interfaces Năng Lực (6)** | `IHaveAbility`, `IHaveMultiAbility`, `IHaveRoleAbility`, `IHaveSpecialAbility`, `IHaveSpecialSpecificAbility`, `IChangeAbilityTargets` | Giao thức định nghĩa vai trò có kỹ năng, hỗ trợ nhiều kỹ năng đồng thời và can thiệp hoán đổi mục tiêu | Duck-typing & Protocols |
| **Hành Vi Đại Diện (8)** | `HunterRoleAbility`, `HunterSuspectAbility`, `MagicianCardAbility`, `MagicianRoleAbility`, `PsychicCardAbility`, `PsychicRoleAbility`, `RadarLocationAbility`, `RadarSuspectAbility` | Hiện thực hóa 4 trường phái kỹ năng cốt lõi: Săn lùng (Hunter), Đánh tráo (Magician), Ngoại cảm (Psychic), Dò quét (Radar) | `RefCounted` (`AbilityBehavior.gd`) |
| **Mặt Tiền Điều Phối (8)**| `LeadClueFacade`, `LeadEndManager`, `LeadEventFacade`, `LeadEventManager`, `LeadFacade`, `LeadStampManager`, `LeadStasisManager`, `LeadStasisRegionManager` | Quản lý vòng đời sự kiện, lưu giữ trạng thái tạm dừng (Stasis) và đóng dấu con dấu chứng thực | `Node` (`LeadCoordinator.gd`) |
| **Giao Diện Địa Bàn (3)** | `IAmCasinoRole`, `IAmClockRole`, `IAmDocksRole` | Phân loại vai trò theo địa bàn hoạt động chính | Tag metadata / enums |

---

### 2.2. Nhóm 47 Vai Trò Nghi Phạm Sở Hữu Kỹ Năng Đặc Biệt (47 Special Ability Roles)

| Nhóm trường phái | Classes C# tiêu biểu | Cơ chế can thiệp bàn chơi | Ánh xạ Godot 4 |
| :--- | :--- | :--- | :--- |
| **Đánh lừa & Hoán đổi (10)** | `Doppelganger`, `Trickster`, `Scrambler`, `CardShuffler`, `Magician`, `Dealer`, `Barista`, `Accountant`, `Bouncer`, `Offeror` | Hoán đổi vị trí thẻ bài trên bảng, tráo đổi dữ kiện lời khai hoặc chuyển hướng tác động của ghim điều tra | `SwapAbility.gd` |
| **Tâm linh & Cảm ứng (8)** | `Psychic`, `CardPsychic`, `Clairvoyant`, `Empath`, `Visionary`, `Siren`, `Cultist`, `Devil` | Dự báo trước các thẻ bài ẩn, cảm ứng độ trung thực của nhân chứng, tạo hào quang dẫn dắt | `SenseAbility.gd` |
| **Săn lùng & Đe dọa (10)** | `Hunter`, `GoodCop`, `HiredGun`, `HotShot`, `Marine`, `Snitch`, `Spotter`, `Stalker`, `Vigilante`, `Craber` | Ép buộc lộ diện nghi phạm ẩn náu, theo dấu vết dây nối nỉ, khóa chân thẻ bài | `HuntAbility.gd` |
| **Xã hội & Thao túng (10)** | `Politician`, `Producer`, `Mythomaniac`, `Opportunist`, `Receptionist`, `Researcher`, `Supplier`, `Tailor`, `Valet`, `Waiter` | Can thiệp vào danh tiếng vụ án, chi phối luồng tiền cược hoặc hối lộ thông tin | `SocialAbility.gd` |
| **Địa bàn & Vận may (7)** | `LottoScratcher`, `SlotMachine`, `CrackPot`, `Alerter`, `Cardiologist`, `IAmClockLocation`, `IAmDocksLocation` | Minigame cào thẻ, máy đánh bạc tại chỗ, báo động khi có ghim sai | `ChanceAbility.gd` |

---

## 3. Kiến Trúc Tái Thiết Trong Godot 4.6.2

### 3.1. Hệ Thống Tài Nguyên Kỹ Năng (`RoleAbility.gd`)
```gdscript
# res://scripts/abilities/role_ability.gd
class_name RoleAbility
extends Resource

enum TriggerPhase {
    ON_BOARD_ENTER, # Kích hoạt khi chia thẻ lên bảng
    ON_PINNED,       # Kích hoạt khi cắm ghim hoặc nối dây
    ON_ACCUSED       # Kích hoạt khi chỉ mặt trên bục Lineup
}

@export var ability_id: String = ""
@export var trigger: TriggerPhase = TriggerPhase.ON_BOARD_ENTER
@export var target_scope: String = "ADJACENT" # SELF, ADJACENT, ALL, RANDOM

func execute_ability(source_node: Node, board_context: Dictionary) -> Dictionary:
    # Triển khai hành vi cụ thể (override ở subclass)
    return {"mutated": false}
```

### 3.2. Đường Ống Điều Phối Kỹ Năng (`AbilityPipeline.gd`)
```gdscript
# res://scripts/abilities/ability_pipeline.gd
class_name AbilityPipeline
extends Node

signal ability_triggered(role_name: String, effect_data: Dictionary)

func trigger_phase(phase: RoleAbility.TriggerPhase, board: Array) -> void:
    for suspect in board:
        var ability: RoleAbility = suspect.get("ability")
        if ability and ability.trigger == phase:
            var result: Dictionary = ability.execute_ability(suspect, {})
            ability_triggered.emit(suspect.get("name", ""), result)
```

---

## 4. Danh Mục Thẩm Định Thực Nghiệm 60fps (DEC-26)

| Tình huống kích hoạt | Hành vi bản gốc | Tiêu chí thẩm định Godot 4 | Trạng thái |
| :--- | :--- | :--- | :---: |
| **Kỹ năng Hunter** | Mũi tên đỏ nhấp nháy từ thợ săn chỉ thẳng vào thẻ bài kế cận | Tween line draw + red pulsing shader | `[V]` Đã mô hình |
| **Kỹ năng Magician** | Khói mù xuất hiện, 2 thẻ bài hoán đổi vị trí trong $0.4\text{s}$ | Tween position arc swap + sound `smoke_poof` | `[V]` Đã mô hình |
| **Kỹ năng Psychic** | Hào quang tím tỏa ra từ thẻ bài, lộ diện 1 đặc tính ẩn | Shader purple glow outline + reveal flip | `[V]` Đã mô hình |

---
*Tài liệu cẩm nang giải phẫu hoàn thiện cho toàn bộ 79 classes của Vòng V5.1 theo chuẩn DEC-21 và ADR-0010.*
