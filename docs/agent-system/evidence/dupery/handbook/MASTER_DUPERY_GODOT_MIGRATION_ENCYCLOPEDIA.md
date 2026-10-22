# Bách Khoa Toàn Thư Kiến Trúc Dupery & Cẩm Nang Di Trú Unity ➔ Godot 4.6.2 (Master Architecture Encyclopedia)

> **Mã định danh**: `DOC-DUPERY-MASTER-ENCYCLOPEDIA-P2`  
> **Phiên bản tài liệu**: `2.0.0-STABLE` (Đồng bộ hoàn tất Tầng B & TASK-0030)  
> **Dự án nguồn**: *Dupery* (Unity `2022.3.62f3`, Mono x86, Steam AppID `2860530`)  
> **Động cơ mục tiêu**: Godot Engine `4.6.2 Stable` (GL Compatibility / Forward+, Desktop 1920x1080 60 FPS CFR)  
> **Quy mô đối tượng**: **1.533 Classes C#**, 12 Level Scenes, 879 Sprites, 155 Audio Samples, 54 Materials, 6 Golden Reference Captures (DEC-26).

---

## MỤC LỤC TỔNG QUAN

1. [PHẦN 1: BẢN VẼ KIẾN TRÚC CỐT LÕI & CÁC NGUYÊN TẮC THIẾT KẾ](#phần-1-bản-vẽ-kiến-trúc-cốt-lõi--các-nguyên-tắc-thiết-kế)
2. [PHẦN 2: MA TRẬN DI TRÚ THÀNH PHẦN UNITY ➔ GODOT 4.6.2](#phần-2-ma-trận-di-trú-thành-phần-unity--godot-462)
3. [PHẦN 3: BẢNG CHỈ SỐ NHỊP ĐỘ THỰC NGHIỆM 60 FPS & ĐƯỜNG CONG TWEENING](#phần-3-bảng-chỉ-số-nhịp-độ-thực-nghiệm-60-fps--đường-cong-tweening)
4. [PHẦN 4: HƯỚNG DẪN HIỆN THỰC HÓA CHI TIẾT TỪNG PHÂN HỆ (V1 ĐẾN V8)](#phần-4-hướng-dẫn-hiện-thực-hóa-chi-tiết-từng-phân-hệ-v1-đến-v8)
5. [PHẦN 5: BỘ TIÊU CHUẨN KIỂM TOÁN CHẤT LƯỢNG & SẴN SÀNG CHO PHASE 3](#phần-5-bộ-tiêu-chuẩn-kiểm-toán-chất-lượng--sẵn-sàng-cho-phase-3)

---

## PHẦN 1: BẢN VẼ KIẾN TRÚC CỐT LÕI & CÁC NGUYÊN TẮC THIẾT KẾ

### 1.1. Chu Kỳ Vòng Đời Đối Tượng: Unity Mono vs Godot Node
Trong Unity, toàn bộ logic trò chơi phụ thuộc vào lớp `MonoBehaviour` với các hàm ảo `Awake()`, `Start()`, `Update()`, `FixedUpdate()`. Trong Godot 4.6.2, toàn bộ cây đối tượng kế thừa từ `Node` hoặc `Node2D`/`Control`:

| Khái Niệm Unity Mono | Cơ Chế Tương Đương Trong Godot 4.6.2 | Quy Chuẩn Kỹ Thuật Tái Lập |
| :--- | :--- | :--- |
| `Awake()` | `_enter_tree()` | Khởi tạo cấu trúc dữ liệu nội bộ, không truy cập node anh em |
| `Start()` | `_ready()` | Đã nạp xong cây con, kết nối tín hiệu (`signals`) và tham chiếu |
| `Update()` | `_process(delta)` | Xử lý khung hình mượt (vẽ dây chỉ đỏ, camera drag, lerp) |
| `FixedUpdate()` | `_physics_process(delta)` | Xử lý va chạm ô cắm ghim, xác định tọa độ snap lưới |
| `Destroy(gameObject)` | `queue_free()` | Giải phóng an toàn vào cuối khung hình, tránh rò rỉ bộ nhớ |
| `Coroutine` (`IEnumerator`) | `await` / `SceneTreeTimer` / `Tween` | Sử dụng cú pháp bất đồng bộ hiện đại của GDScript 2.0 |

### 1.2. Danh Mục Các Singleton Toàn Cục (Autoload Services Registry)
Hệ thống Fan-Game Godot sẽ vận hành trên 5 dịch vụ Autoload cốt lõi để loại bỏ kiến trúc biến tĩnh (`static fields`) dễ gây lỗi rò rỉ trạng thái:

```text
Project Settings -> Autoload:
├── GameManager.gd       (Quản lý phiên vụ án, luồng ngày/đêm, trạng thái Stasis)
├── AudioManager.gd       (Điều phối 5 Bus AudioServer, stem-layering, snapshot DSP)
├── SaveManager.gd        (Quản lý tuần tự hóa JSON, chuỗi nâng cấp save v0.2.51 ➔ v0.9.34)
├── SceneRouter.gd        (Chuyển cảnh bất đồng bộ, màn đen chuyển tiếp CanvasLayer z=100)
└── InputShortcuts.gd     (Ánh xạ phím bấm, D-pad snapping cho ghim và nghi phạm)
```

### 1.3. Cấu Hình Khung Nhìn (Viewport & Canvas Scaler Strategy)
- **Độ phân giải chuẩn**: `1920 x 1080` (Full HD 16:9).
- **Chế độ co giãn (Stretch Mode)**: `canvas_items` với aspect `keep_height`. Đảm bảo độ sắc nét 1-pixel của typography và khung viền không bị nhòe mờ.
- **Bàn thám tử (SubViewport)**: Bảng gỗ phá án được đặt trong một `SubViewportContainer` độc lập, cho phép phóng to, thu nhỏ và di chuyển camera mượt mà mà không làm biến dạng giao diện HUD.

---

## PHẦN 2: MA TRẬN DI TRÚ THÀNH PHẦN UNITY ➔ GODOT 4.6.2

Toàn bộ 1.533 classes C# được phân loại thành hai nhóm di trú: thành phần dùng Node dựng sẵn (Zero-Code / Config-Only) và thành phần bắt buộc phải tái lập giải thuật tùy biến (Custom Algorithmic Logic).

### 2.1. Nhóm 1 — Thay Thế Bằng Node Dựng Sẵn (Zero-Code / Config-Only)

| Thành Phần Trong Unity C# | Giải Pháp Godot 4.6.2 Đề Xuất | Thiết Lập Tham Số Cụ Thể (Inspector / Config) |
| :--- | :--- | :--- |
| `UILineRenderer` (`GRGLib`) | `Line2D` | `width = 3.0`, `texture_mode = LINE_TEXTURE_TILE`, `joint_mode = LINE_JOINT_ROUND`, `begin_cap_mode = LINE_CAP_ROUND`. |
| FMOD Studio Bus Hierarchy | `AudioServer` Buses | Thiết lập 5 Buses: `Master` $\rightarrow$ `Ambient`, `Music`, `SFX`, `UI`. Bus `SFX` cấp phát 16 kênh polyphony. |
| Unity `ScriptableObject` | Godot `Resource` (`.tres`) | Định nghĩa các custom resource: `SuspectRoleData.gd`, `CaseQuirksVisualData.gd`, `RegionsData.gd`. |
| `CanvasScaler` / `RectTransform` | `Control` Anchors & Containers | Sử dụng `MarginContainer`, `HBoxContainer`, `VBoxContainer` kết hợp preset `Full Rect` và `Center`. |
| `TextMeshProUGUI` | `RichTextLabel` | Bật `bbcode_enabled = true`, nạp font `LiberationSans.ttf` và `PerfectDOSVGA437.ttf`, cấu hình drop shadow. |
| `IPointerEnterHandler` / `Exit` | `Control.mouse_entered` / `exited` | Kết nối tín hiệu trực tiếp với callable animation scale: hover $1.0 \rightarrow 1.05$ trong 0.15s. |
| `SpriteRenderer` / UI Image | `NinePatchRect` | Áp dụng tọa độ Nine-Slice từ `nine_slice_rects.json` (`left=12`, `top=12`, `right=12`, `bottom=12`). |
| FMOD Parameter Snapshot | `AudioEffectLowPassFilter` | Gán effect vào bus `Master`, điều chỉnh tham số `cutoff_hz` từ 20500 Hz xuống 800 Hz khi pause game. |
| `XNode` Graph Execution | Godot `Resource` Graph Trees | Mô hình hóa 18 đồ thị cốt truyện dưới dạng cây `StoryNodeResource` liên kết bằng `Array[StoryNodeResource]`. |
| Unity `VideoPlayer` | `VideoStreamPlayer` | Phát trực tiếp hai tệp video cắt cảnh `Dupery Intro English.mp4` và `Dupery Intro Cutscene.mp4`. |

### 2.2. Nhóm 2 — Bắt Buộc Tái Lập Giải Thuật Tùy Biến (Custom Algorithmic Logic)

#### 1. Bộ Sinh Số Ngẫu Nhiên Hạt Giống (`DotNetRandom.gd`)
- **Vấn đề**: Hàm `randi()` của Godot sử dụng thuật toán PCG32, sẽ sinh ra chuỗi số hoàn toàn khác với `System.Random` của Unity .NET Mono x86, phá vỡ tính tất định của seed vụ án.
- **Giải pháp**: Hiện thực hóa giải thuật **Knuth Subtractive Generator** (55 bước trừ modulo $10^9$) tương thích byte-for-byte với `scripts/agent/simulate_case_generation.py`:
  $$\alpha_n = (\alpha_{n-24} - \alpha_{n-55}) \bmod 10^9$$

#### 2. Giải Thuật Võng Dây Chỉ Đỏ (`Catenary2D.gd`)
- **Vấn đề**: Dây chỉ đỏ nối giữa 2 ghim không phải là đường thẳng mà có độ chùng vật lý đàn hồi thay đổi theo khoảng cách.
- **Giải pháp**: Tính toán tọa độ $N=24$ điểm nội suy theo đường cong hàm Hyperbolic Cosine:
  $$y(x) = a \cdot \cosh\left(\frac{x - x_0}{a}\right) + y_0$$
  khi ghim di chuyển, tham số $a$ (độ căng) được nội suy mượt bằng hàm `lerp()` với hệ số $\alpha = 0.25$.

#### 3. Shader Uốn Lượn Thấu Kính Thám Tử (`ContinuousWobble.gdshader`)
- **Giải pháp**: CanvasItem Shader biến dạng ma trận UV cục bộ xung quanh kính lúp:
  ```glsl
  shader_type canvas_item;
  uniform float frequency : hint_range(1.0, 20.0) = 8.0;
  uniform float amplitude : hint_range(0.001, 0.05) = 0.015;
  uniform float speed : hint_range(0.5, 5.0) = 2.0;

  void fragment() {
      vec2 uv = UV;
      uv.x += sin(uv.y * frequency + TIME * speed) * amplitude;
      uv.y += cos(uv.x * frequency + TIME * speed) * amplitude;
      COLOR = texture(TEXTURE, uv);
  }
  ```

---

## PHẦN 3: BẢNG CHỈ SỐ NHỊP ĐỘ THỰC NGHIỆM 60 FPS & ĐƯỜNG CONG TWEENING

Dữ liệu được trích xuất và đo lường trực tiếp từ **6 tệp video tham chiếu chuẩn** (DEC-26) tại tốc độ 60.00 FPS CFR:

| Tương Tác Trực Quan | Số Khung Hình (60 FPS) | Thời Lượng Đo Đạc | Loại Đường Cong Easing | Khung Âm Thanh Kích Hoạt (Trigger Frame) |
| :--- | :---: | :---: | :--- | :--- |
| **Lật Mặt Thẻ Vụ Án** (`Card Flip`) | 24 frames | $400\text{ ms}$ | `TRANS_CUBIC` `EASE_OUT` | Frame 4: Âm thanh `CARD_FLIP.wav` |
| **Ghim Rơi / Cắm Vào Bảng** (`Pin Drop`) | 8 frames | $133\text{ ms}$ | `TRANS_BACK` `EASE_OUT` | Frame 2: Âm thanh `PIN_DROP.wav` |
| **Xòe Quạt Vật Phẩm** (`Item Fan Open`) | 20 frames | $333\text{ ms}$ | `TRANS_BACK` `EASE_OUT` | Frame 3: Âm thanh `FAN_OPEN.wav` |
| **Hàng Nghi Phạm Di Chuyển** (`Lineup Step`) | 18 frames | $300\text{ ms}$ | `TRANS_QUAD` `EASE_IN_OUT`| Frame 0: Âm thanh `LINEUP_STEP.wav` |
| **Đóng Dấu Kết Luận** (`Stamp Gavel`) | 12 frames | $200\text{ ms}$ | `TRANS_BOUNCE` `EASE_OUT` | Frame 8: Âm thanh `STAMP_IMPACT.wav` |
| **Biểu Đồ Tròn Quét Đầy** (`Pie Chart Fill`) | 45 frames | $750\text{ ms}$ | `TRANS_SINE` `EASE_OUT` | Frame 45: Tiếng búa `JUDGE_GAVEL.wav` |
| **Menu Tạm Dừng Lọc DSP** (`Pause Cutoff`) | 12 frames | $200\text{ ms}$ | `TRANS_QUAD` `EASE_OUT` | Frame 0: Hạ cutoff filter xuống 800 Hz |
| **Chuông Đồng Hồ Chuyển Giờ** (`Clock Chime`)| 120 frames | $2000\text{ ms}$ | `TRANS_LINEAR` (Suy hao) | Frame 0: Phát `ClocktowerBell.wav` |

---

## PHẦN 4: HƯỚNG DẪN HIỆN THỰC HÓA CHI TIẾT TỪNG PHÂN HỆ (V1 ĐẾN V8)

### V1 — Bảng Điều Tra, Ghim & Dây Nối Catenary (95 Classes)
- **Kiến trúc Scene**: `DetectiveBoard.tscn` (Node2D) chứa `PinsContainer` (quản lý các nút ghim), `StringsContainer` (quản lý các `Line2D` dây chỉ), và `MagnifyingGlass` (Sprite2D kèm Shader biến dạng).
- **Quy tắc Snap Lưới**: Khi buông chuột, vị trí ghim tự động hút vào tâm slot gần nhất trong bán kính $R = 32\text{ px}$ theo đường cong `TRANS_BACK` trong 6 frames.

### V2 — Khởi Tạo Vụ Án, 20 Ràng Buộc & Cốt Truyện (130 Classes)
- **Hệ thống Tạo Vụ Án**: Quy trình 3 bước tất định:
  1. `SuspectListFactory`: Chọn ngẫu nhiên danh sách nghi phạm sơ bộ dựa trên seed.
  2. `InPlayListFactory`: Lọc và gán vai trò (`InPlay`) thỏa mãn 20 ràng buộc `GenerationConstraint` (ưu tiên `PositionRoleGC`, `ClassificationRatioGC`, `RomanticGC`).
  3. `BoardPositioningFactory`: Đặt thẻ lên bảng thám tử không bị đè tọa độ.
- **Cốt truyện đồ thị**: Sử dụng 18 tệp Resource giải mã từ XNode để điều phối luồng hội thoại phân nhánh.

### V3 — Vòng Lặp Điều Tra, Manh Mối & Hàng Nghi Phạm (94 Classes)
- **Vòng lặp Ngày/Đêm**: Quản lý biến `Energy` (năng lượng điều tra). Mỗi lần xem manh mối hoặc di chuyển khu vực trừ 1-2 điểm năng lượng.
- **Hàng nghi phạm (Lineup)**: Cụm 5 chân dung di chuyển ngang theo cơ chế băng chuyền vô tận.

### V4 — Chợ Đen, 59 Quirks & 11 Vật Phẩm Quạt Xòe (101 Classes)
- **Item Fan Manager**: Mở quạt các lá bài vật phẩm dưới đáy màn hình theo góc xòe cung tròn:
  $$\theta_i = -\frac{\Theta_{\text{total}}}{2} + i \cdot \frac{\Theta_{\text{total}}}{N - 1}$$
- **Quirk Modifier**: Thẻ đặc tính gắn vào nghi phạm làm thay đổi điều kiện thắng/thua.

### V5 — 228 Vai Trò Nghi Phạm, 87 Năng Lực & Con Dấu (496 Classes)
- **Suspect Role Matrix**: Toàn bộ 228 vai trò được lưu trữ thành 228 tệp `.tres` kế thừa `SuspectRoleData.gd`, nạp dữ liệu động từ `roles_data.json`.
- **Hệ thống đóng dấu**: Con dấu Tội phạm (`Guilty`) và Vô tội (`Innocent`) với hoạt họa xoay góc ngẫu nhiên $\pm 5^\circ$ tạo cảm giác đóng dấu thủ công.

### V6 — Lưu Trữ JSON, Bản Địa Hóa & Âm Thanh FMOD (100 Classes)
- **Save Migration Chain**: Tương thích ngược toàn bộ file lưu từ bản `v0.2.51` đến `v0.9.34`.
- **Bộ trộn âm thanh 5 Bus**: Đồng bộ 155 tệp audio WAV trích xuất từ FSB5 vào `AudioServer`. Bổ sung lớp `LocalisationActivation.gd` lọc ngôn ngữ theo whitelist.

### V7 — Màn Hình Phụ, Bách Khoa Thư Codex & Chế Độ Chơi (64 Classes)
- **Codex UI**: Bách khoa toàn thư danh bạ nghi phạm và manh mối, lọc theo khu vực.
- **6 Chế độ chơi mở rộng**: Cấu hình quy tắc qua `AlternateModeRule.gd` (như chế độ Hardcore, No Clues, Speedrun).

### V8 — Trình Biên Tập Màn Chơi & Đánh Giá Tính Giải Được (22 Classes)
- **Level Editor Canvas**: Giao diện kéo thả tạo màn chơi tùy biến, kiểm tra giới hạn nhiên liệu (`LEFuel`) và chip cược (`LEChips`).
- **Xuất Dữ Liệu**: Xuất vụ án tùy biến ra tệp định dạng chuẩn `CustomCase.json`.

---

## PHẦN 5: BỘ TIÊU CHUẨN KIỂM TOÁN CHẤT LƯỢNG & SẴN SÀNG CHO PHASE 3

1. **Chu Trình 3 Bước Nạp Context Tươi (DEC-19)**:
   Mọi module lập trình trong Phase 3 phải thực hiện theo quy trình:
   `Truy vấn Recipe` $\rightarrow$ `Đọc C# gốc & Scene JSON` $\rightarrow$ `Viết GDScript & Đối Soát Golden Reference`.
2. **Quy Chuẩn Giới Hạn Dòng Code (ADR-0010 DEC-AMEND-01)**:
   Mọi tệp mã nguồn GDScript mới phải tuân thủ trần cảnh báo **800 LOC** và trần chặn commit **1000 LOC**.
3. **Kiểm Toán Đối Kháng Độc Lập (DEC-17)**:
   Mọi Task hiện thực hóa Godot đều phải có Subagent Peer-Auditor nghiệm thu độc lập với giao thức chống trade-off ngầm trước khi đóng task.
4. **Bảo Toàn Provenance**:
   Mọi logic sao chép từ game gốc phải có chú thích trỏ về tệp mã nguồn C# tương ứng trong `Dupery_Unity_Project/Assets/Scripts/`.
