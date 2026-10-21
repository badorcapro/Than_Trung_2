# Cẩm Nang Tái Thiết Kiến Trúc V1.3: Easing Curves, World Visuals & Region Minigames (45 Classes)

> **Mã định danh**: `DOC-V1C-HANDBOOK`  
> **Phạm vi tái thiết**: Vòng V1.3 (Hoàn thiện 45 classes còn lại của Vòng V1, tổng kết 95/95 classes đạt L3 `documented`)  
> **Mục tiêu chuyển đổi**: Unity 2022.3.62f3 Mono C# $\to$ Godot 4.6.2 Stable (GDScript & Godot Scene Trees)  
> **Nguyên tắc cốt lõi**: Phục hồi giải tích 100% công thức toán học, không làm mất độ phân giải tương tác, bảo toàn âm thanh FMOD và hành vi gốc `[V]`.

---

## 1. Tổng Quan Kiến Trúc V1.3 & Bản Đồ Phân Bổ 45 Classes

Vòng V1.3 phụ trách tầng hiển thị thế giới (Visual World Layer) và động lực học hoạt họa (Animation Dynamics). Trái với định kiến game Unity dùng `AnimationClip` và `AnimatorController`, kiểm kê ở `TASK-0017` (`negative_findings.json`) đã chứng minh Dupery có **0 AnimationClip và 0 AnimatorController**; 100% chuyển động và hiệu ứng của Dupery được sinh ra từ các coroutines điều khiển biến số theo thời gian thông qua các công thức toán giải tích (`GRGLib.Coroutines`).

```
                              [GameScene / level1]
                                       │
                              [GameVisualManager]
                                       │ (spawns from RegionsVisualsDataSO)
                             ┌─────────┴─────────┐
                   [WorldVisualManager] (Abstract Base)
        ┌──────────────┬──────────────┬──────────────┬──────────────┐
[BackAlleysWorld] [CasinoWorld] [ClockWorld] [DocksWorld] [WorldDecorManager]
  - PouchManager    - ChipsManager  - ClockTower   - BoatVisual   - Shadow Oscillate
  - HealthManager   - CardManager   - Chime Loop   - BobberVisual - Noir Flickering
  - SlotVisual      - LightsManager - Jiggle Ring  - NavalMine
  - ItemVisualSO    - Bulb (5 pat)  - TextWriter   - FuelCounter
```

### Danh Mục Phân Bổ 45 Classes

| STT | Class C# gốc | Phân nhóm chức năng | File nguồn C# | Node Godot 4 tương đương |
| :-: | :--- | :--- | :--- | :--- |
| 1 | `BackAlleysItemVisualDataSO` | Data SO | `Assembly-CSharp/BackAlleysItemVisualDataSO.cs` | `Resource` (`ItemVisualData.gd`) |
| 2 | `BobberVisuals` | Minigame Visual | `Assembly-CSharp/BobberVisuals.cs` | `TextureRect` + `Control.mouse_entered` |
| 3 | `CaseQuirksVisualDataSO` | Data SO | `Assembly-CSharp/CaseQuirksVisualDataSO.cs` | `Resource` (`QuirksVisualData.gd`) |
| 4 | `CasinoCardsVisualDataSO` | Data SO | `Assembly-CSharp/CasinoCardsVisualDataSO.cs` | `Resource` (`CasinoCardsData.gd`) |
| 5 | `CodexVisualDataSO` | Data SO | `Assembly-CSharp/CodexVisualDataSO.cs` | `Resource` (`CodexVisualData.gd`) |
| 6 | `StampOddVisualiser` | UI Component | `Assembly-CSharp/MainMenu/StampOddVisualiser.cs` | `Control` (`StampOddVisualiser.gd`) |
| 7 | `RegionsVisualsDataSO` | Data SO | `Assembly-CSharp/RegionsVisualsDataSO.cs` | `Resource` (`RegionsVisualsData.gd`) |
| 8 | `StampVisualDataSO` | Data SO | `Assembly-CSharp/StampVisualDataSO.cs` | `Resource` (`StampVisualData.gd`) |
| 9 | `AbilityVisualManager` | Ability Coordinator | `Visual/AbilityVisualManager.cs` | `Node` (`AbilityVisualManager.gd`) |
| 10 | `BackAlleysHealthVisualManager` | Region World | `Visual/BackAlleysHealthVisualManager.cs` | `HBoxContainer` (`HealthPinsBar.gd`) |
| 11 | `BackAlleysItemInfoCard` | Region World | `Visual/BackAlleysItemInfoCard.cs` | `PanelContainer` (`ItemInfoCard.gd`) |
| 12 | `BackAlleysItemInfoVisualManager`| Region World | `Visual/BackAlleysItemInfoVisualManager.cs` | `Control` (`ItemInfoVisualManager.gd`)|
| 13 | `BackAlleysItemVisual` | Region World | `Visual/BackAlleysItemVisual.cs` | `TextureRect` (`ItemVisual.gd`) |
| 14 | `BackAlleysNewItemVisualManager` | Region World | `Visual/BackAlleysNewItemVisualManager.cs` | `Window` / `Control` (`NewItemPopup.gd`)|
| 15 | `BackAlleysPouchVisualManager` | Region World | `Visual/BackAlleysPouchVisualManager.cs` | `GridContainer` (`PouchManager.gd`) |
| 16 | `BackAlleysRegionWorldManager` | Region World | `Visual/BackAlleysRegionWorldManager.cs` | `Node2D` (`BackAlleysWorld.gd`) |
| 17 | `BackAlleysSlotVisual` | Region World | `Visual/BackAlleysSlotVisual.cs` | `Button` + `TextureRect` (`SlotVisual.gd`) |
| 18 | `BoatVisual` | Region World | `Visual/BoatVisual.cs` | `Node2D` + `Sprite2D` (`BoatVisual.gd`) |
| 19 | `CaseQuirkExplanation` | UI Tooltip | `Visual/CaseQuirkExplanation.cs` | `PanelContainer` (`QuirkTooltip.gd`) |
| 20 | `CaseQuirkListVisualManager` | UI Coordinator | `Visual/CaseQuirkListVisualManager.cs` | `HBoxContainer` (`QuirkListManager.gd`) |
| 21 | `CaseQuirkVisual` | UI Component | `Visual/CaseQuirkVisual.cs` | `Button` (`QuirkBadge.gd`) |
| 22 | `CasinoBulb` | Lighting | `Visual/CasinoBulb.cs` | `TextureRect` (`CasinoBulb.gd`) |
| 23 | `Settings` (CasinoBulb) | Lighting Enum | `Visual/CasinoBulb.cs` | `enum BulbSettings` |
| 24 | `CasinoCardManager` | Minigame Visual | `Visual/CasinoCardManager.cs` | `Control` (`CasinoCardManager.gd`) |
| 25 | `CasinoChipsManager` | Minigame Visual | `Visual/CasinoChipsManager.cs` | `Control` (`CasinoChipsManager.gd`) |
| 26 | `CasinoLightsManager` | Lighting | `Visual/CasinoLightsManager.cs` | `Node2D` (`CasinoLightsManager.gd`) |
| 27 | `CasinoLightsPatterns` | Lighting Enum | `Visual/CasinoLightsManager.cs` | `enum LightPatterns` |
| 28 | `CasinoRegionWorldManager` | Region World | `Visual/CasinoRegionWorldManager.cs` | `Node2D` (`CasinoWorld.gd`) |
| 29 | `ClockRegionWorldManager` | Region World | `Visual/ClockRegionWorldManager.cs` | `Node2D` (`ClockWorld.gd`) |
| 30 | `ClockTowerVisual` | Location Visual | `Visual/ClockTowerVisual.cs` | `Node2D` (`ClockTowerVisual.gd`) |
| 31 | `DocksRegionWorldManager` | Region World | `Visual/DocksRegionWorldManager.cs` | `Node2D` (`DocksWorld.gd`) |
| 32 | `FuelVisualManager` | Minigame Visual | `Visual/FuelVisualManager.cs` | `ProgressBar` (`FuelVisualManager.gd`) |
| 33 | `GameInstructionsManager` | UI Prompt | `Visual/GameInstructionsManager.cs` | `Label` (`InstructionPrompt.gd`) |
| 34 | `GameVisualManager` | Top Coordinator | `Visual/GameVisualManager.cs` | `Node2D` (`GameVisualManager.gd`) |
| 35 | `IAmItemVisualised` | Interface | `Visual/IAmItemVisualised.cs` | `RefCounted` / Duck typing |
| 36 | `ItemVisualHelper` | Helper | `Visual/ItemVisualHelper.cs` | `RefCounted` (`ItemVisualHelper.gd`) |
| 37 | `JudgeGavelAnimationEffect` | Effect Visual | `Visual/JudgeGavelAnimationEffect.cs` | `Node2D` (`JudgeGavelEffect.gd`) |
| 38 | `KnockVisual` | Effect Visual | `Visual/KnockVisual.cs` | `Node2D` (`KnockRippleEffect.gd`) |
| 39 | `NavalMineVisual` | Location Visual | `Visual/NavalMineVisual.cs` | `Node2D` (`NavalMineVisual.gd`) |
| 40 | `SlotMachineVisual` | Location Visual | `Visual/SlotMachineVisual.cs` | `Node2D` (`SlotMachineVisual.gd`) |
| 41 | `VisualCasinoCard` | Minigame Visual | `Visual/VisualCasinoCard.cs` | `Button` (`VisualCasinoCard.gd`) |
| 42 | `WorldAnimationEffect` | Abstract Effect | `Visual/WorldAnimationEffect.cs` | `Node2D` (`WorldAnimationEffect.gd`) |
| 43 | `WorldAnimationEffectsVisualManager` | Effect Manager | `Visual/WorldAnimationEffectsVisualManager.cs` | `Node2D` (`WorldAnimManager.gd`) |
| 44 | `WorldDecorManager` | Atmosphere | `Visual/WorldDecorManager.cs` | `CanvasModulate` + `Node2D` |
| 45 | `WorldVisualManager` | Master Base | `Visual/WorldVisualManager.cs` | `Node2D` (`WorldVisualManager.gd`) |

---

## 2. Giải Phẫu Động Lực Học Hoạt Họa & Toán Học Easing

### 2.1. Động Cơ Easing Giải Tích (`CoroutineExtensions.cs`)

Game sử dụng trực tiếp các hàm toán học để nội suy các giá trị biến thiên (vị trí `moveTransform`, góc xoay `rotateTransformSmart`, kích thước `scaleTransform`, độ trong suốt `fade`, giá trị đổ đầy `fill`):

1. **Sine Curves**:
   $$\text{easeInSine}(x) = 1.0 - \cos\left(\frac{x \pi}{2}\right)$$
   $$\text{easeOutSine}(x) = \sin\left(\frac{x \pi}{2}\right)$$
   $$\text{easeInOutSine}(x) = \frac{1.0 - \cos(x \pi)}{2.0}$$
   *Ánh xạ Godot 4*: `Tween.TRANS_SINE` kết hợp `Tween.EASE_IN`, `Tween.EASE_OUT`, `Tween.EASE_IN_OUT`.

2. **Elastic Curves**:
   $$\text{easeInElastic}(x) = -\left(2^{10(x - 1)}\right) \cdot \sin\left((10x - 10.75) \cdot \frac{2\pi}{3}\right)$$
   $$\text{easeOutElastic}(x) = 2^{-10x} \cdot \sin\left((10x - 0.75) \cdot \frac{2\pi}{3}\right) + 1.0$$
   *Ánh xạ Godot 4*: `Tween.TRANS_ELASTIC`.

3. **Back Curves** (văng vượt ngưỡng, $c_1 = 1.70158$, $c_2 = 2.5949094$):
   $$\text{easeInBack}(x) = (c_1 + 1)x^3 - c_1 x^2$$
   $$\text{easeOutBack}(x) = 1.0 + (c_1 + 1)(x - 1)^3 + c_1(x - 1)^2$$
   *Ánh xạ Godot 4*: `Tween.TRANS_BACK`.

4. **Bounce Curves**: Phân đoạn 4 chấn động theo hệ số nhảy parabol ($7.5625, 2.75$).
   *Ánh xạ Godot 4*: `Tween.TRANS_BOUNCE`.

### 2.2. Cơ Chế Jiggle Toàn Cục (`Jiggler.cs`)
Mọi tương tác bấm thẻ, lật bài, hover phao câu (`BobberVisuals`), hay tiếng chuông đồng hồ (`ClockTowerVisual`) đều gọi `transform.jiggle()`:
- Kích thước phóng tức thì: $S_0 = 1.08 \times$
- Góc xoay lệch ngẫu nhiên: $\theta_0 \in [\pm 5^\circ, \pm 8^\circ]$
- Thời gian phục hồi: $T = 0.75\text{ s}$
- Hàm hồi vị: `easeOutElasticFunc` (dao động tắt dần quanh trục cân bằng $S=1.0, \theta=0^\circ$).

---

## 3. Kiến Trúc 4 Vùng Thế Giới (Region World Managers)

### 3.1. Hẻm Tối (`BackAlleysRegionWorldManager`)
- **Túi đồ nghề (`BackAlleysPouchVisualManager`)**: Quản lý ma trận ô đồ nghề `slots: Dictionary<Vector2Int, BackAlleysSlotVisual>`, hỗ trợ thao tác kéo thả (`onSlotDrag`, `onSlotDragEnd`) và hoán đổi vị trí items.
- **Thanh máu (`BackAlleysHealthVisualManager`)**: Quản lý các ghim máu `HealthPins`. Pin còn sống hiển thị màu trắng (`Color.white`), pin mất máu đổi màu xám mờ (`Color(0.5, 0.5, 0.5)`) bằng phép biến đổi màu `fadeToColour(..., 0.35s)`.
- **Hộp thoại vật phẩm mới (`BackAlleysNewItemVisualManager`)**: Tự động mở khi nhận được vật phẩm mới (`addNewItem`).

### 3.2. Sòng Bạc (`CasinoRegionWorldManager`)
- **Dàn đèn tròn Casino (`CasinoLightsManager` & `CasinoBulb`)**:
  - Dãy bóng đèn xếp quanh viền bàn thám tử và danh sách nghi phạm.
  - 5 mẫu nhấp nháy (`CasinoLightsPatterns`):
    - `SWAP_HALF`: Nhấp nháy so le chẵn/lẻ (chu kỳ đổi $0.05\text{s}$, nghỉ $0.5\text{s}$).
    - `SWAP_FULL`: Đồng loạt bật/tắt toàn bộ đèn.
    - `CIRCLE`: Đèn chạy vòng tròn 1 hướng (bật tắt từng bóng $0.07\text{s}$, bước dịch $0.03\text{s}$).
    - `CIRCLE_2`: Đèn chạy vòng tròn 2 cụm đối xứng.
    - `CIRCLE_4`: Đèn chạy vòng tròn 4 cụm tứ giác.
  - Phản ứng bắt giữ:
    - Bắt đúng kẻ ác (`Alignments.EVIL`): Kích hoạt mẫu `CIRCLE_2`.
    - Bắt nhầm người tốt (`Alignments.GOOD`): Kích hoạt mẫu `SWAP_FULL` tốc độ nhanh ($1.2\times$).
    - Sau $2.5\text{s}$ tự động hoàn nguyên về `SWAP_HALF`.
- **Thẻ bài cược (`CasinoCardManager`)**: Hiển thị 2 lá bài đối nghịch (`left_card`, `right_card`), góc nghiêng đối xứng $\pm 2.5^\circ$, âm thanh `Sfx.CARD_DECK`.
- **Ngân lượng chíp (`CasinoChipsManager`)**: Đếm số chíp và tiền mặt, hoạt họa đổi màu xanh khi thắng (`gain_colour`) và đỏ khi thua (`lose_colour`).

### 3.3. Tháp Chuông (`ClockRegionWorldManager`)
- Quản lý cảnh báo thời gian trôi qua (`hour_passed`).
- Khi chuông gõ:
  - Phát âm thanh `Sfx.CLOCK_TOWER_CHIME` (`fmod_samples_vault/Sfx/Clock Chime.wav`).
  - Chữ hiện từng ký tự qua máy đánh chữ tốc độ $0.03\text{s}/\text{char}$.
  - Tháp rung giật liên hồi qua coroutine `jiggle()` mỗi chu kỳ $0.5\text{s}$.

### 3.4. Bến Cảng (`DocksRegionWorldManager`)
- **Thuyền hải trình (`BoatVisual`)**:
  - Tàu di chuyển giữa các tọa độ lưới cọc ghim: thời lượng $0.65\text{s}$ với `easeInOutSine`.
  - Bộ đếm nhiên liệu (`fuel_counter`) đếm lùi trong $0.5\text{s}$.
  - Tàu tiêu hao nhiên liệu theo khoảng cách Manhattan/Cardinal: $\Delta F = |\Delta x| + |\Delta y|$.
- **Thủy lôi phục kích (`NavalMineVisual`)**:
  - Khi kích hoạt: nổ phát sáng trong $0.125\text{s}$ (`easeOutSine`), phóng đại hình ảnh trong $0.5\text{s}$ (`easeOutBack`), và rung lắc chấn động $5\text{px}$ trong $0.25\text{s}$.
  - Âm thanh nổ: `Sfx.NAVAL_MINE_EXPLOSION`.

---

## 4. Bầu Không Khí & Ánh Sáng Phòng Thám Tử (`WorldDecorManager`)

Trái tim tạo nên bầu không khí "Film Noir" của Dupery là lớp bóng râm chuyển động nhẹ:
1. **Dao động bóng râm nhẹ (`moveLightsSlightly`)**:
   - Hai lớp bóng `top_layer_shadow` và `bottom_layer_shadow` xoay nhẹ quanh trục $Z$.
   - Biên độ: $\pm 0.5^\circ \dots 1.25^\circ$.
   - Thời gian một lượt lắc: $6.0\text{s} \dots 8.0\text{s}$ (ngẫu nhiên).
   - Nội suy: `easeInOutSine`.
2. **Hiệu ứng đèn chập chờn bóng tối (`rollDark`)**:
   - Xác suất $2\%$ mỗi khi kết thúc một chu kỳ xoay đèn.
   - Nhấp nháy chập chờn: chớp đen $0.05\text{s} \to$ sáng $0.1\text{s} \to$ chớp đen $0.05\text{s} \to$ sáng $0.25\text{s} \to$ chập bóng tối ngẫu nhiên $0.5\text{s}..1.25\text{s} \to$ trở lại bình thường.

---

## 5. Quy Chuẩn Tái Thiết Bằng GDScript (Godot 4.6.2)

### 5.1. Triển Khai Jiggler Trong Godot 4
```gdscript
# res://scripts/ui/jiggler.gd
class_name Jiggler
extends RefCounted

static func jiggle(node: Control, scale_factor: float = 1.08, duration: float = 0.75) -> Tween:
    var rot_offset: float = deg_to_rad(randf_range(5.0, 8.0))
    if randi() % 2 == 0:
        rot_offset = -rot_offset
    
    node.scale = Vector2(scale_factor, scale_factor)
    node.rotation = rot_offset
    
    var tween: Tween = node.create_tween().set_parallel(true)
    tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
    tween.tween_property(node, "scale", Vector2.ONE, duration)
    tween.tween_property(node, "rotation", 0.0, duration)
    return tween
```

### 5.2. Triển Khai Casino Lights Manager Trong Godot 4
```gdscript
# res://scripts/visual/casino_lights_manager.gd
class_name CasinoLightsManager
extends Node2D

enum Patterns { SWAP_HALF = 0, SWAP_FULL = 1, CIRCLE = 10, CIRCLE_2 = 11, CIRCLE_4 = 12 }

@export var bulbs: Array[TextureRect] = []
var active_tween: Tween

func play_pattern(pattern: Patterns, speed_multi: float = 1.0) -> void:
    if active_tween and active_tween.is_valid():
        active_tween.kill()
    active_tween = create_tween().set_loops()
    
    match pattern:
        Patterns.SWAP_HALF:
            var step_time: float = 0.5 / speed_multi
            active_tween.tween_callback(func(): _toggle_half(true))
            active_tween.tween_interval(step_time)
            active_tween.tween_callback(func(): _toggle_half(false))
            active_tween.tween_interval(step_time)
            
        Patterns.SWAP_FULL:
            var step_time: float = 0.3 / speed_multi
            active_tween.tween_callback(func(): _set_all(true))
            active_tween.tween_interval(step_time)
            active_tween.tween_callback(func(): _set_all(false))
            active_tween.tween_interval(step_time)

func _toggle_half(even_state: bool) -> void:
    for i in range(bulbs.size()):
        var is_even: bool = (i % 2 == 0)
        bulbs[i].modulate.a = 1.0 if (is_even == even_state) else 0.2

func _set_all(on: bool) -> void:
    for b in bulbs:
        b.modulate.a = 1.0 if on else 0.2
```

---

## 6. Danh Mục Thẩm Định Thực Nghiệm 60 FPS (DEC-26)

| Hạng mục kiểm tra | Tiêu chuẩn đo lường Unity gốc | Ngưỡng chấp thuận Godot 4 | Nhãn chứng thực |
| :--- | :--- | :--- | :---: |
| Tốc độ hồi vị Jiggle | $0.75\text{s}$ ($\pm 0.02\text{s}$ ở 60fps) | Đúng 45 frames 60fps | `[V]` Giải tích |
| Nhịp chớp đèn SWAP_HALF | $0.50\text{s}$ sáng, $0.50\text{s}$ tắt | Chu kỳ $1.0\text{s}$ (60 frames) | `[V]` Giải tích |
| Tàu di chuyển Docks | $0.65\text{s}$ với `easeInOutSine` | 39 frames nội suy mượt | `[V]` Giải tích |
| Thời lượng nổ Thủy lôi | $0.125\text{s}$ flash, $0.50\text{s}$ expand | Đúng 30 frames giãn nở | `[V]` Giải tích |
| Dao động bóng Decor | Chu kỳ $6\text{s} \dots 8\text{s}$, góc $\le 1.25^\circ$ | Không giật hình, FPS $\ge 60$ | `[V]` Giải tích |
| Chập chờn bóng tối rollDark | Xác suất $2\%$, 4 nhịp chớp tối | Tương thích CanvasModulate | `[V]` Giải tích |

---
*Tài liệu hoàn thành nghĩa vụ bóc tách kiến trúc cho toàn bộ 45 classes còn lại của Vòng V1 theo chuẩn DEC-21 và DEC-26.*
