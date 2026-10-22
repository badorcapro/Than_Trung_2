# PLAN-CHANG-4-GODOT-RECONSTRUCTION-AND-LAN: Chặng 4 — Tái Cấu Trúc Godot Fan-Game & Kiến Trúc Nền Mạng LAN Multiplayer

> **Document ID**: `PLAN-CHANG-004` (v2.0 — Master Execution Plan for Stage 4 & Stage Extra)  
> **Target Workspace**: `Than_Tham_Nua_Voi_Godot/` (Godot 4.6.2, Cửa sổ Windowed GL 1920x1080)  
> **Căn Cứ Thống Nhất Qua `/grill-me`**:  
> - Báo cáo tồn đọng thực tế: `docs/agent-system/problems/Tua_game_nay_dang_co_van_de.txt` (giải quyết 100% trong Chặng 4) `[V]`.  
> - Kho học liệu trích xuất Dupery: 1.533 classes C#, 13 handbooks, Master Encyclopedia, Cross-project mapping `[V]`.  
> - Trần định mức dòng lệnh: `warn: 800 LOC`, `hard: 1000 LOC` per ADR-0010 DEC-AMEND-01 `[V]`.  
> - Kế hoạch mượn tạm asset gốc: 879 sprites PNG, 155 samples PCM WAV, 6 fonts, shader `ContinuousWobble` `[V]`.  
> - Quy hoạch Chặng Extra (Chặng 5): 6 tasks (TASK-0042..0047) nâng cấp hệ sinh thái đạt chuẩn 100% game gốc `[V]`.

---

## 1. Mục Tiêu Chiến Lược Hai Chặng

1. **Chặng 4 (`TASK-0033` $\rightarrow$ `TASK-0041`)**:
   - Giải quyết triệt để mọi lỗi trong file `.txt`: Thuật toán sinh câu đố Knuth DotNetRandom (`TASK-0034`), Clean Rebuild bảng thám tử và thẻ bài Canvas 1920x1080 (`TASK-0035`), Chọn 1/3 vụ án và lưu tiến trình qua màn (`TASK-0036`), Tái thiết kế màn hình Looting dạng quạt bài (`TASK-0037`).
   - Xây dựng tầng nền Mạng LAN: Autoload `NetworkManager.gd` (`ENetMultiplayerPeer`), module `LANDiscovery.gd` beacon UDP 8910 trong WiFi (`TASK-0038`), Lobby room phân bổ Slot Người / Slot Bot 3 cấp độ (`TASK-0039`), RPC Action Hooks và Đấu giá ẩn (`TASK-0040`), Kiểm thử tích hợp song song 2 tiến trình (`TASK-0041`).
2. **Chặng Extra (`TASK-0042` $\rightarrow$ `TASK-0047`)**:
   - Đưa toàn bộ các hệ sinh thái lớn của Dupery gốc vào Godot Fan-Game Thần Trùng: Nhạc Noir Jazz 5 buses thích ứng (`TASK-0042`), Hoạt ảnh kết tội Lineup cảnh sát (`TASK-0043`), Khung kỹ năng nhân vật 171 classes (`TASK-0044`), Bách khoa toàn thư Codex (`TASK-0045`), 6 Chế độ chơi phụ (`TASK-0046`), và Trình tạo màn chơi Level Editor (`TASK-0047`).

---

## 2. Bảng Kế Hoạch "Mượn Tạm Asset Gốc" Cho Fan-Game Vận Hành Ổn Định

| Nhóm Tài Nguyên | Tệp Nguồn Vault Chặng 3 | Thư Mục Đích Trong Fan-Game | Ứng Dụng Thực Tế |
| :--- | :--- | :--- | :--- |
| **Giao Diện & Thẻ Bài (UI Props)** | `docs/agent-system/evidence/dupery/vault/sprites_manifest.json` (879 sprites PNG / 59 sheets) | `Than_Tham_Nua_Voi_Godot/assets/ui/dupery_props/` | - 3 loại ghim (đỏ/vàng/xanh).<br/>- Khung thẻ bài Nine-Patch (co giãn chống tràn chữ).<br/>- Texture mặt bàn gỗ thám tử & giấy báo retro.<br/>- Kính lúp, kẹp giấy, thước đo, búa đấu giá. |
| **Âm Thanh Cốt Lõi (SFX PCM WAV)** | `docs/agent-system/evidence/dupery/vault/audio_samples_manifest.json` (155 samples WAV sạch) | `Than_Tham_Nua_Voi_Godot/assets/audio/sfx/` | - `pin_place.wav`, `pin_remove.wav` (cắm/rút ghim).<br/>- `string_drag.wav`, `string_snap.wav` (kéo/hủy dây).<br/>- `card_flip.wav`, `card_slide.wav` (lật/xòe bài quạt).<br/>- `auction_hammer.wav` (gõ búa đấu giá). |
| **Phông Chữ Chuyên Dụng (Typewriter Fonts)** | 6 fonts TTF/OTF trích xuất từ `Dupery_Data/StreamingAssets/` | `Than_Tham_Nua_Voi_Godot/assets/fonts/` | Phông máy đánh chữ cổ điển và tiêu đề báo chí Noir, hiển thị sắc nét 1080p, không bị vỡ hạt như font Godot mặc định. |
| **Shader Dây Ghim & Mực Rung** | `ContinuousWobble.gdshader` (từ handbook V8) | `Than_Tham_Nua_Voi_Godot/shaders/ContinuousWobble.gdshader` | Hiệu ứng rung nhẹ tự nhiên cho nét vẽ Line2D và thẻ bài giấy báo, xóa bỏ hoàn toàn cảm giác đơ cứng. |

---

## 3. Lộ Trình Phân Rã Chi Tiết Chặng 4 (`TASK-0033` $\rightarrow$ `TASK-0041`)

- **`TASK-0033` (Phase 0 - Gatekeeper Upgrade Nhịp 0.2b)**:
  - Cập nhật `scripts/agent/check_line_budget.py` và `docs/agent-system/project-config.json`: bổ sung `.gd` vào `include_extensions`, kích hoạt `baseline_exemptions` cho 11 God-files cũ để cấm phình to thêm qua diff guard, chuẩn hóa trần 800 warn / 1000 block LOC per ADR-0010 DEC-AMEND-01.
- **`TASK-0034` (Phase 3 - Pilot DO-02 CaseGenerator Rewrite)**:
  - Tách `DotNetRandom.gd` (Knuth subtractive generator) và `CaseConstraintSolver.gd` (20 Generation Constraints từ V2A). Viết Fuzz Test 1.000 hạt giống cam kết 100% nghiệm duy nhất, xóa `CaseGeneratorPublicSolver.gd` khỏi `baseline_exemptions`.
- **`TASK-0035` (Phase 3 - Pilot DO-05 Detective Board & Suspect Card Clean Rebuild)**:
  - Clean Rebuild `VSCaseMain.tscn` và `SuspectCard.tscn` trên Canvas 1920x1080, gắn 879 sprites gốc, ghim chỉ dây Catenary2D, sửa dứt điểm lỗi mất chữ (font 5px) và tràn icon (`anchor_right = 1.42`), xóa 2 God-files cũ khỏi `baseline_exemptions`.
- **`TASK-0036` (Phase 3 - Pilot DO-03 Case Selection System & Level Progression)**:
  - Xây dựng `CaseSelectionManager.gd` và `LevelProgressionManager.gd` từ học liệu V1/V3. Lưu dữ liệu tiến độ vượt màn (level progression) dạng Candy Crush / Angry Birds.
- **`TASK-0037` (Phase 3 - Pilot DO-01/04 Looting & Shop Screen Redesign)**:
  - Áp dụng cơ chế xòe quạt thẻ bài `ItemFanManager` từ V4, phân bổ không gian thoáng đãng trực quan, thay thế hoàn toàn giao diện rối mắt cũ, tách `AuctionCatalog.gd` sang `Custom Resource (.tres)`.
- **`TASK-0038` (Phase 3 - Network Foundation & UDP LAN Discovery)**:
  - Tạo Autoload `NetworkManager.gd` (`ENetMultiplayerPeer`), module `LANDiscovery.gd` dùng `PacketPeerUDP` phát beacon cổng 8910 trong mạng WiFi, tích hợp cơ chế kết nối Direct IP/Port dự phòng.
- **`TASK-0039` (Phase 3 - Lobby Room UI & Slot Allocation)**:
  - Giao diện Tạo phòng, danh sách phòng WiFi tự động cập nhật 1-chạm, quản lý Slot người chơi (Human) và Slot Bot (hỗ trợ chọn 3 mức độ thông minh: Dễ, Vừa, Khó).
- **`TASK-0040` (Phase 3 - RPC Action Bridges & Secret Bidding Network Hooks)**:
  - Thiết lập các RPC action hooks chuẩn hóa (`submit_solution`, `player_ready`, `start_match`) và kiến trúc Đấu Giá Ẩn (Secret Bidding: mỗi Client gửi giá thầu kín qua RPC lên Server phân xử, không lộ màn hình).
- **`TASK-0041` (Phase 3 - End-to-End LAN Integration & Runtime Verification)**:
  - Khởi chạy song song 2 tiến trình Godot trong mạng nội bộ kiểm tra kết nối, đối chiếu SceneTree sống không dùng `--headless`, nghiệm thu toàn diện Chặng 4.

---

## 4. Lộ Trình Phân Rã Chi Tiết Chặng Extra (`TASK-0042` $\rightarrow$ `TASK-0047`)

- **`TASK-0042` (Chặng Extra - Interactive Noir Jazz Audio Engine)**:
  - Tái tạo hệ thống 5 buses trong Godot `AudioServer` (`Master`, `Music`, `SFX`, `Stems`, `Ambience`). Nạp 155 samples WAV, xây dựng Autoload `AudioManager.gd` hỗ trợ hòa trộn thích ứng (stem fading 4 lớp nhạc cụ) và kích hoạt ngẫu nhiên 16 saxophone solo riffs.
- **`TASK-0043` (Chặng Extra - Lineup Police Accusation Cinematic Scene)**:
  - Dàn dựng màn hình kết tội nghi phạm với hoạt ảnh hàng cảnh sát xếp hàng (`LineupController`), đèn chiếu sân khấu (spotlight), hiệu ứng còng tay và âm thanh phán quyết tội phạm kịch tính.
- **`TASK-0044` (Chặng Extra - Suspect Abilities Engine & Role Extensibility)**:
  - Di trú toàn bộ bộ engine 171 classes của V5A sang Godot: Cung cấp khung gắn kỹ năng bị động/chủ động cho nhân vật (áp dụng cho các nhân vật Thần Trùng như kỹ năng xem trộm manh mối, làm nhiễu lời khai, bảo kê nghi phạm).
- **`TASK-0045` (Chặng Extra - In-Game Codex Encyclopedia)**:
  - Xây dựng giao diện Bách khoa toàn thư Codex trong game, cho phép tra cứu hồ sơ nhân vật, tiểu sử, phân tích tâm lý và bộ sưu tập các vụ án đã giải.
- **`TASK-0046` (Chặng Extra - 6 Alternate Game Modes)**:
  - Tích hợp 6 chế độ chơi phụ từ V7: Draft Mode (chọn bài ngẫu nhiên), Endless Mode (vô tận tăng dần độ khó), Speedrun/Timer Mode (đếm ngược thời gian áp lực cao), Hardcore Mode, Custom Seed Mode, và Daily Case.
- **`TASK-0047` (Chặng Extra - Level Editor & Custom Case Sharing)**:
  - Xây dựng bộ công cụ Level Editor hoàn chỉnh từ V8: Cho phép người chơi tự thiết kế câu đố trên Godot, cắm thẻ bài, gán manh mối, kiểm tra fuel/chips và xuất/nhập file JSON để chia sẻ cộng đồng.

---

## 5. Quy Chuẩn Kỹ Thuật Bất Biến

1. **Clean Core First**: Toàn bộ Giai đoạn 4A vận hành hoàn toàn độc lập với Netcode. Không trộn lẫn RPC vào các lớp Domain và Board UI cơ bản.
2. **Kỷ Luật Ngân Sách Dòng Lệnh**: Tuân thủ nghiêm ngặt trần warn 800 LOC / block 1000 LOC per ADR-0010 DEC-AMEND-01. Mọi module mới thiết kế đơn trách nhiệm < 300 LOC.
3. **Kiểm Toán Đối Kháng Subagent Peer-Audit**: Mọi Task từ `TASK-0033` đến `TASK-0047` đều bắt buộc qua Subagent Peer-Auditor độc lập kiểm toán trước khi chạy `run_verify.py`.
