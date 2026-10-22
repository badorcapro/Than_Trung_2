# Dupery Golden Reference Capture Protocol (Quy Chuẩn Thu Thập Tham Chiếu Chuẩn)

> **Mục tiêu**: Thiết lập quy chuẩn kỹ thuật đồng nhất cho việc ghi hình gameplay, chụp ảnh màn hình, và thu âm thanh tham chiếu trực tiếp từ bản game gốc *Dupery* (Unity 2022.3.62f3 Mono x86). Bộ tài liệu và media thu được đóng vai trò **Golden Reference** (Hệ quy chiếu vàng) để kiểm chứng đối kháng 1:1 trong toàn bộ các Vòng giải phẫu V1–V8 và quá trình tái thiết trên Godot 4.6.2.
> **Ràng buộc**: Tuân thủ quyết định kiến trúc `DEC-19` (Chu trình 3 bước nạp context tươi) và `DEC-23` (Behaviour Capture).

---

## 1. Thông Số Kỹ Thuật Bắt Buộc (Capture Specifications)

Mọi video clip và ảnh chụp màn hình nạp vào hệ thống tham chiếu phải tuân thủ nghiêm ngặt các thông số sau để loại trừ hiện tượng méo tỷ lệ, sai lệch nhịp độ hoặc biến dạng màu sắc:

| Tham số | Quy chuẩn bắt buộc | Căn cứ kỹ thuật |
| :--- | :--- | :--- |
| **Độ phân giải hiển thị** | `1920 x 1080` (Full HD, tỷ lệ 16:9) | Chuẩn cố định từ `PlayerSettings.json` của game gốc |
| **Chế độ hiển thị** | Fullscreen hoặc Borderless Windowed | Tránh viền cửa sổ OS và thanh taskbar làm lệch tọa độ pixel |
| **Tốc độ khung hình (FPS)** | `60.0 FPS` (Constant Frame Rate - CFR) | Bắt buộc CFR để đo lường chính xác số frame của tween/easing curves |
| **Mã hóa Video** | H.264 (AVC) / MP4, Bitrate $\ge 15\text{ Mbps}$ | Giữ nguyên độ sắc nét của typography và UI 1-pixel borders |
| **Định dạng Ảnh chụp** | PNG 24-bit RGB (Lossless) | Không dùng JPEG nén mờ rìa icon và nét vẽ |
| **Tần số lấy mẫu Âm thanh** | 48.0 kHz, Stereo 2 channels, 320 kbps AAC | Đồng bộ với engine FMOD Studio trong `fmod_banks_manifest.json` |
| **Môi trường ghi hình** | Tắt toàn bộ Overlay bên ngoài | Tắt Steam Overlay, Discord, GeForce Experience notification, FPS counter |

---

## 2. Quy Chuẩn Đặt Tên Tệp (Naming Convention)

Các tệp media nạp vào kho lưu trữ `docs/agent-system/evidence/dupery/references/` phải được đặt tên theo cú pháp tất định để công cụ `verify_dupery_reference_capture.py` tự động phân loại và đối chiếu checklist:

```text
REF_<CATEGORY>_<ACTION>_<RESOLUTION>_<FPS>.<EXT>
```

### Các tiền tố phân hệ (Category Codes):
- `MENU`: Giao diện Main Menu, Options, Settings, Credits.
- `CUTSCENE`: Cắt cảnh Video intro hoặc chuyển tiếp màn chơi.
- `V1_BOARD`: Vòng 1 — Bảng thám tử, ghim ghi chú, kéo dây chỉ đỏ, kính lúp.
- `V2_CASEGEN`: Vòng 2 — Sinh vụ án, chọn thẻ vụ án, logic ngẫu nhiên/seed.
- `V3_LOOP`: Vòng 3 — Vòng lặp điều tra chính, Leads, Events, Lineup nghi phạm.
- `V4_ITEMS`: Vòng 4 — Xòe quạt vật phẩm (`ItemFanManager`), thẻ Quirks, cửa hàng.
- `V5_ROLES`: Vòng 5 — Nghi phạm, nhân vật, biểu cảm chân dung, hover cards.
- `V6_INFRA`: Vòng 6 — Lưu game, bảng ngôn ngữ, điều khiển phím tắt (`InputShortcutsSO`).
- `V7_SUB`: Vòng 7 — Hướng dẫn Tutorial, bảng tổng kết Summary, biểu đồ PieChart.

---

## 3. Danh Mục Kiểm Tra Đối Kháng 9 Phân Cảnh (Checklist Matrix)

| STT | Phân Cảnh / Tương Tác | Thao Tác Cần Ghi Hình / Chụp Ảnh | Mục Tiêu Thẩm Định Kiến Trúc |
| :-: | :--- | :--- | :--- |
| **01** | **Main Menu & Settings** | - Hover và click từng nút (Play, Settings, Quit).<br>- Âm thanh chuông đồng hồ `ClocktowerBell`.<br>- Mở menu tạm dừng (Pause) kiểm tra tham số `GamePause`. | Khớp nối âm thanh FMOD, độ trễ phản hồi UI, vị trí Canvas Scaler. |
| **02** | **Intro Cutscene** | - Phát video mở đầu tiếng Anh.<br>- Chuyển cảnh từ Video sang giao diện game. | Khớp nối VideoClip `sharedassets8.resource` và FMOD `Intro.bank`. |
| **03** | **Case Selection & Stasis** | - Hiển thị 3 thẻ vụ án trên bàn.<br>- Hover xem chi tiết, lật mặt sau thẻ.<br>- Click chọn 1 vụ án và chuyển cảnh. | Thời lượng lật thẻ (Card Flip duration), âm thanh `CARD`, `PAPER_SHORT`. |
| **04** | **Detective Board & String** | - Kéo ghim ghi chú di chuyển trên bảng gỗ.<br>- Nhấp giữ kéo dây chỉ đỏ (`UILineRenderer`) giữa 2 manh mối.<br>- Di chuột kính lúp (`MagnifyingGlassManager`) kiểm tra shader cong thấu kính. | Đường cong chùng của dây chỉ (elastic tension), shader distortion, âm thanh `PIN_DROP`. |
| **05** | **Leads & Region Events** | - Mở cửa sổ Leads các khu vực (Casino, Docks, Office, Syndicate).<br>- Đọc chuỗi đa ngôn ngữ (GRGLocalisation).<br>- Click kích hoạt sự kiện tàu/khu vực. | Khớp nối ScriptableObject `regions_data.json` và âm thanh `BOAT_ACTIVATE`. |
| **06** | **Lineup & Suspects** | - Di chuyển hàng nghi phạm (LineupMove).<br>- Hover từng nghi phạm xem thông tin thẻ bài.<br>- Đóng dấu xác nhận hoặc loại trừ. | Thời lượng hoạt họa `LineupMove`, âm thanh `SUSPECT_HOVER`, `JUDGE_GAVEL`. |
| **07** | **Item Fan & Quirks** | - Mở khay xòe quạt vật phẩm (`ItemFanManager`).<br>- Rê chuột trên từng lá bài trong quạt.<br>- Kéo thẻ Quirk thả vào bảng thám tử. | Đường cong bung góc quạt (fan angle distribution), easing coroutine của `GRGLib`. |
| **08** | **Summary & Pie Chart** | - Màn hình tổng kết cuối màn điều tra.<br>- Hoạt họa lấp đầy biểu đồ tròn PieChart theo tỷ lệ % phá án.<br>- Tiếng búa thẩm phán phán quyết. | Thuật toán vẽ biểu đồ tròn động, âm thanh `JUDGE_GAVEL`, chuyển scene. |
| **09** | **Pause Menu & Pitch Shift** | - Bấm Escape mở Pause Menu.<br>- Kiểm tra âm thanh FMOD parameter `parameter:/GamePause` và `PopPitch`. | Xác minh trực nghiệm hành vi DSP parameter FMOD runtime. |

---

## 4. Phương Pháp Đo Lường Nhịp Độ & Thời Lượng (Frame-by-Frame Timing Analysis)

Khi sử dụng video tham chiếu để tái lập logic trên Godot 4:
1. **Đếm số Frame hoạt họa**: Tại tốc độ chuẩn 60 FPS, mỗi frame tương ứng $\approx 16.67\text{ ms}$.
   $$\text{Duration (seconds)} = \frac{\text{Frames Count}}{60.0}$$
2. **Xác định đường cong Easing (Tween Curves)**:
   - Đo vị trí pixel của đối tượng tại frame $0\%, 25\%, 50\%, 75\%, 100\%$ của chuyển động.
   - So khớp với các đường cong chuẩn trong Godot: `TRANS_SINE`, `TRANS_CUBIC`, `TRANS_BACK`, `TRANS_ELASTIC` và `EASE_OUT` / `EASE_IN_OUT`.
3. **Độ trễ âm thanh (Audio-Visual Latency)**:
   - Đánh dấu frame click chuột (Down event) và frame âm thanh FMOD bắt đầu xuất hiện trong waveform audio để thiết lập chính xác điểm trigger trong Godot.
