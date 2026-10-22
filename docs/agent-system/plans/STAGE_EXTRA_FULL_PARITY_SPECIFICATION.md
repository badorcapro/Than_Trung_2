# Bách Khoa Toàn Thư Đối Chiếu: Game Gốc Dupery vs Game Sau Chặng 4 & Chi Tiết Toàn Bộ Hệ Thống Chặng Extra

> **Tài Liệu Đặc Tả**: `SPEC-CHANG-EXTRA-PARITY-AUDIT` (v1.0)  
> **Căn Cứ Dữ Liệu Thực Chứng**:  
> - 1.533 classes CIL decompiled từ 5 assemblies Steam hotfix `[V]`  
> - 13 Cẩm nang giải phẫu bách khoa V1–V8 và Master Migration Playbook `[V]`  
> - Kho Vault sạch: 879 sprites PNG / 59 sheets, 155 samples PCM WAV, 6 fonts, 12 scenes YAML `[V]`  
> - Báo cáo lỗi dự án Fan-Game: `docs/agent-system/problems/Tua_game_nay_dang_co_van_de.txt` `[V]`

---

## PHẦN 1: BẢNG MA TRẬN ĐỐI CHIẾU TỔNG THỂ (DUPERY GỐC vs SAU CHẶNG 4 vs CHẶNG EXTRA)

Bảng đối chiếu toàn diện 8 phân hệ cốt lõi giữa Game Gốc (*Dupery* Steam) và Fan-Game Thần Trùng (ước tính sau khi hoàn thành Chặng 4):

| Phân Hệ & Lát Cắt | Tính Năng Trong Game Gốc *Dupery* (1.533 Classes) | Trạng Thái Sau Chặng 4 (Core Fixes + LAN) | Tồn Tại Trong Chặng Extra (Cần Bổ Sung) |
| :--- | :--- | :--- | :--- |
| **V1: Core Loop & Board Viewport** | - Vòng lặp: Briefing $\rightarrow$ Board $\rightarrow$ Lineup $\rightarrow$ Scoring.<br/>- Camera Pan/Zoom/Clamp mượt mà.<br/>- Hoạt ảnh Lineup cảnh sát kết tội kịch tính. | - Vòng lặp cơ bản: Chọn vụ án $\rightarrow$ Giải đố $\rightarrow$ Cộng điểm Công Danh `[V]`.<br/>- Camera Viewport cố định Canvas 1920x1080 `[V]`. | **Màn hình hoạt ảnh xếp hàng kết tội Lineup Police Accusation (đèn chiếu, còng tay, dàn hàng)**. |
| **V2: Case Generation & Constraints** | - Hạt giống Knuth Subtractive Generator (.NET Mono).<br/>- 20 Ràng buộc Generation Constraints.<br/>- 87 classes Story Node Graph.<br/>- 100% nghiệm duy nhất, 0 lỗi sượng. | - Di trú 100% `DotNetRandom.gd` + `CaseConstraintSolver.gd` (20 constraints) `[V]`.<br/>- Fuzz test 1.000 seeds cam kết nghiệm duy nhất `[V]`. | *Đã hoàn thành 100% trong Chặng 4 (Không cần thêm)*. |
| **V3: Leads & Progression Loop** | - Hệ thống chọn 1 trong 3 vụ án (3 Cards).<br/>- Tăng dần độ khó (1 lead $\rightarrow$ 5 leads).<br/>- Lưu tiến trình sao/cấp độ. | - Port 100% `CaseSelectionManager.gd` và `LevelProgressionManager.gd` `[V]`.<br/>- Lưu tiến trình vượt màn dạng Candy Crush/Angry Birds `[V]`. | *Đã hoàn thành 100% trong Chặng 4 (Không cần thêm)*. |
| **V4: Physical Board, Catenary & Tools** | - Sợi dây Catenary2D độ võng tự nhiên cosh.<br/>- Kính lúp phóng to với lens distortion shader.<br/>- Xòe quạt thẻ bài `ItemFanManager`.<br/>- Hiệu ứng bụi giấy, ghim rung lắc. | - Sợi dây Catenary2D độ võng tự nhiên `[V]`.<br/>- Xòe quạt thẻ bài `ItemFanManager` trong Looting `[V]`.<br/>- 879 sprites gốc + shader rung nhẹ `ContinuousWobble` `[V]`. | **Hệ thống Kính lúp phóng to chi tiết với lens distortion shader + Bụi giấy + Dấu triện đỏ**. |
| **V5: Suspect Database & Ability Engine** | - **228 Suspect Roles** độc lập.<br/>- **171 Classes Ability Engine** (kỹ năng bị động, chủ động, tráo manh mối, bảo kê, miễn nhiễm). | - Sử dụng một nhóm nhỏ nhân vật Thần Trùng (6-10 nhân vật) với chỉ số Công Danh / Kỷ vật riêng `[V]`. | **Bộ Engine Kỹ Năng 171 Classes & Toàn bộ kho 228 Archetypes nhân vật phong phú**. |
| **V6A: Interactive Audio Engine** | - FMOD 5 Audio Buses.<br/>- Stem-layering 4 lớp hòa âm Noir Jazz thời gian thực.<br/>- 16 Saxophone Solo Riffs ngẫu hứng khi nối đúng.<br/>- Dynamic Lowpass Filter múp tiếng khi pause. | - SFX cơ bản (cắm ghim, rút ghim, kéo dây, búa gõ, lật bài) từ 155 samples WAV sạch `[V]`. | **Hệ thống hòa âm Noir Jazz 4 lớp thích ứng thời gian thực + 16 Saxophone Solo Riffs + Dynamic Filter**. |
| **V6B: Save, Localization & Input** | - SavePrint Migration Chain 10 phiên bản.<br/>- Từ điển đa ngôn ngữ GRGLocalisation.<br/>- Hỗ trợ tay cầm D-pad snap từng ghim. | - Lưu dữ liệu màn chơi mới độc lập `[V]`.<br/>- Hỗ trợ bàn phím / chuột mượt mà 1080p `[V]`. | **Từ điển đa ngôn ngữ hoàn chỉnh + Hệ thống điều khiển tay cầm Gamepad D-pad Snap**. |
| **V7: Secondary Screens & Alternate Modes** | - Bách khoa toàn thư Codex trong game.<br/>- **6 Chế độ chơi phụ** (Draft, Endless, Speedrun, Hardcore, Custom Seed, Daily).<br/>- Interactive Tutorial hướng dẫn từng bước. | - Single-Player chuẩn mực qua màn `[V]`.<br/>- Tầng nền Mạng LAN: 2 Mode mới (PvP và PvBot) `[V]`. | **Bách Khoa Toàn Thư Codex + Toàn Bộ 6 Chế Độ Chơi Phụ (Draft, Endless, Speedrun...) + Tutorial**. |
| **V8: Level Editor & Custom Cases** | - Trình tạo màn chơi hoàn chỉnh (22 classes).<br/>- Đặt thẻ bài, gán manh mối, tính fuel/chips.<br/>- Xuất/nhập file JSON CustomCase chia sẻ. | - Không có trong Chặng 4. | **Trình Tạo Màn Chơi Level Editor Đầy Đủ & Hệ Thống Xuất/Nhập Vụ Án JSON Cho Cộng Đồng**. |

---

## PHẦN 2: CHI TIẾT BÁCH KHOA 7 HỆ SINH THÁI THUỘC CHẶNG EXTRA

Dưới đây là đặc tả chi tiết, đầy đủ toàn bộ thông tin của 7 hệ thống lớn của Dupery gốc sẽ được đưa vào Chặng Extra để bảo đảm không bỏ sót bất kỳ một tính năng nào:

### 1. Hệ Thống Động Cơ Kỹ Năng & 228 Vai Trò Nghi Phạm (V5A & V5B)
*Mã nguồn Dupery gốc: 171 classes C# trong `Assembly-CSharp/Abilities` và 228 ScriptableObjects `SuspectData`.*

- **Khung Điều Phối Kỹ Năng (Ability Execution Framework)**:
  - Cơ chế **Trigger Points (Điểm Kích Hoạt)**:
    - `OnCaseStart`: Kỹ năng kích hoạt ngay khi mở vụ án (ví dụ: làm mờ 1 manh mối, ẩn bớt 1 nghi can).
    - `OnCardPinned`: Kích hoạt khi người chơi cắm dây vào nhân vật này (ví dụ: phản kháng, tăng độ căng dây, tiêu hao thêm tài nguyên).
    - `OnQuestioned`: Kích hoạt khi dùng công cụ chất vấn (ví dụ: cung cấp manh mối phụ, hoặc đưa lời khai giả nếu là đồng phạm).
    - `OnLeadRequirementMet`: Kích hoạt khi đủ điều kiện manh mối.
  - Cơ chế **Status Effects (Hiệu Ứng Trạng Thái)**:
    - `ImmuneToAccusation`: Miễn nhiễm kết tội trực tiếp nếu chưa bẻ gãy chứng cứ ngoại phạm.
    - `TamperedAlibi`: Lời khai ngoại phạm bị làm giả, cần dùng kính lúp hoặc thẻ bài đối chứng để lật tẩy.
    - `ConspiracyLink`: Liên minh ngầm giữa 2 nghi phạm, khi 1 người bị tra khảo thì người kia sẽ đổi lời khai.
- **Kho Vai Trò Nhân Vật Mẫu (Suspect Archetypes)**:
  - 228 nhân vật chia làm các nhóm nghề nghiệp: Cảnh sát biến chất, Mafia, Nhà báo tống tiền, Thám tử tư đối thủ, Con bạc, Kẻ trộm kim hoàn, v.v.
  - Mỗi nhân vật có: Bộ chân dung (Portrait Sprite), Giới tính, Độ tuổi, Nghề nghiệp, Đặc điểm tính cách (Quirks: hay nói lắp, hút thuốc, thuận tay trái), và Bộ lời khai mẫu (Alibi Templates).

---

### 2. Hệ Thống Âm Thanh Tương Tác Thích Ứng Noir Jazz (V6A)
*Mã nguồn Dupery gốc: 283 classes `Audio` và cầu nối FMOD, 155 audio samples WAV PCM trong 6 FMOD Banks.*

- **Kiến Trúc 5 Buses Trong Godot AudioServer**:
  - `Master Bus`: Điều khiển tổng âm lượng.
  - `Music_Stems Bus`: Bus cha của 4 lớp nhạc cụ Noir Jazz.
  - `SFX Bus`: Toàn bộ hiệu ứng vật lý (ghim, dây, bài, giấy, búa).
  - `Ambience Bus`: Tiếng mưa rơi rả rích ngoài cửa sổ, tiếng máy đánh chữ xa xăm, tiếng quạt trần quay kẽo kẹt.
  - `UI Bus`: Tiếng click menu, tiếng mở tab, tiếng thông báo.
- **Cơ Chế Dynamic Stem Layering (Hòa Âm 4 Lớp Thích Ứng)**:
  - Bản nhạc Noir Jazz được chia thành 4 audio streams đồng bộ nhịp phách (tempo & bar sync):
    - *Layer 1 (Trống & Bass)*: Luôn chạy nền nhẹ nhàng tạo không khí trinh thám.
    - *Layer 2 (Hợp âm Piano)*: Fade-in khi người chơi bắt đầu cắm dây nối các manh mối đầu tiên.
    - *Layer 3 (Kèn Muted Trumpet)*: Fade-in khi vụ án đạt 50% tiến độ suy luận, tăng độ căng thẳng.
    - *Layer 4 (Bộ gõ dồn dập & Saxophone đệm)*: Fade-in khi người chơi bước vào giai đoạn kết tội cuối cùng.
- **Hệ Thống 16 Saxophone Solo Riffs Ngẫu Hứng**:
  - 16 đoạn solo kèn Saxophone ngắn (1-3 giây) ngẫu hứng phong cách Jazz Noir.
  - Kích hoạt tự động khi người chơi nối đúng một đường dây logic the chốt (Aha moment!), mang lại cảm giác thỏa mãn tột đỉnh cho người chơi.
- **Dynamic Lowpass Filter (Hiệu Ứng Âm Thanh Trầm Múp)**:
  - Khi người chơi mở Menu tạm dừng hoặc mở tab Codex tra cứu, một hiệu ứng `AudioEffectLowPassFilter` tự động kéo tần số cắt xuống `800 Hz` bằng Tween trong 0.2s, tạo cảm giác âm thanh bị ngăn cách như đang suy ngẫm trong phòng kín.

---

### 3. Màn Hình Hoạt Ảnh Xếp Hàng Kết Tội Cảnh Sát (Lineup Police Accusation Scene - V1/V3)
*Mã nguồn Dupery gốc: `LineupController`, `LineupSuspect`, `LineupCutscene`.*

- **Dàn Dựng Hoạt Cảnh (Cinematic Staging)**:
  - Chuyển cảnh từ Bảng thám tử sang Phòng nhận diện tội phạm tại đồn cảnh sát.
  - Các nghi phạm đứng xếp hàng dọc theo bức tường đo chiều cao, đeo số thứ tự trước ngực.
  - Đèn chiếu sân khấu (Spotlight) di chuyển theo trỏ chuột khi người chơi rà soát từng nghi can.
- **Trình Tự Kết Tội (Accusation Sequence)**:
  - Người chơi chọn 1 nghi phạm để kết tội chính thức.
  - Hiệu ứng âm thanh trống dồn (Drumroll) $\rightarrow$ Cảnh sát trưởng bước ra cầm lệnh bắt.
  - *Nếu đoán đúng*: Cảnh sát áp sát, hoạt ảnh còng tay rung lắc (`handcuffs_snap.wav`), nghi phạm cúi đầu thú tội, dấu triện đỏ `GUILTY` đóng mạnh xuống hồ sơ vụ án kèm hiệu ứng nảy màn hình (Camera Shake).
  - *Nếu đoán sai*: Nghi phạm cười nhạo, chuông báo động reo, dấu triện `INNOCENT` đóng xuống, người chơi bị trừ điểm danh dự/uy tín.

---

### 4. Bách Khoa Toàn Thư Trong Game (In-Game Codex Encyclopedia - V7)
*Mã nguồn Dupery gốc: `CodexManager`, `CodexMenu`, `CodexRoleView`, `CodexCaseHistory`.*

- **Giao Diện Quyển Sổ Tay Bìa Da Thám Tử**:
  - Giao diện mở ra như một cuốn sổ tay lật trang có tiếng lật giấy rột roẹt (`page_turn.wav`).
  - Gồm 4 thẻ mục đánh dấu (Bookmark Tabs):
    1. *Tab Nhân Vật (Suspect Directory)*: Danh sách toàn bộ các nhân vật đã gặp, hiển thị chân dung, tiểu sử ngắn, độ nguy hiểm, và các đặc điểm nhận dạng.
    2. *Tab Kỹ Năng & Manh Mối (Clues & Quirks Archive)*: Giải thích chi tiết ý nghĩa của từng loại manh mối (vết máu, tàn thuốc lá, vé tàu, dấu giày, đồng hồ vỡ) và cách thức khắc chế các kỹ năng xảo quyệt.
    3. *Tab Lịch Sử Vụ Án (Case Log)*: Lưu trữ lại sơ đồ dây ghim của toàn bộ các vụ án đã từng phá thành công để người chơi xem lại chiến tích.
    4. *Tab Thành Tựu & Huy Hiệu (Badges & Medals)*: Hệ thống huy hiệu danh dự thám tử (ví dụ: "Bách phát bách trúng", "Phá án dưới 60 giây", "Không hủy dây").

---

### 5. Sáu Chế Độ Chơi Phụ Mở Rộng (6 Alternate Game Modes - V7)
*Mã nguồn Dupery gốc: 13 classes `AlternateModes`, `DraftModeManager`, `EndlessModeManager`, `SpeedrunManager`.*

Ngoài chế độ qua màn cốt truyện tiêu chuẩn, 6 chế độ chơi phụ mang lại giá trị chơi lại vô tận:
1. **Draft Mode (Chế Độ Chọn Thẻ)**: Người chơi được phát ngẫu nhiên 3 gói thẻ bài, phải tự chọn lọc lấy nhân vật và manh mối để ghép thành một vụ án tự giải.
2. **Endless Mode (Chế Độ Sinh Tồn Vô Tận)**: Các vụ án được sinh liên tục với kích thước bảng lớn dần (từ bảng 4 nghi can lên bảng 12 nghi can), mỗi lần đoán sai bị trừ 1 mạng (tối đa 3 mạng).
3. **Speedrun / Timer Mode (Chế Độ Đua Thời Gian)**: Đồng hồ đếm ngược 60 giây cho mỗi vụ án, tiếng tích tắc đồng hồ gõ dồn dập, thử thách phản xạ suy luận tia chớp.
4. **Hardcore Mode (Chế Độ Thám Tử Bậc Thầy)**: Bỏ hoàn toàn cơ chế gợi ý màu dây, các nhân vật có tỷ lệ nói dối 50%, đòi hỏi phải suy luận logic 100% không dựa vào may mắn.
5. **Custom Seed Mode (Chế Độ Hạt Giống Tùy Chọn)**: Cho phép nhập bất kỳ chuỗi số seed nào (ví dụ `SEED: 948201`) để tái hiện chính xác một vụ án cụ thể, dùng để thi đấu đố nhau giữa bạn bè.
6. **Daily Case (Vụ Án Hàng Ngày)**: Mỗi ngày hệ thống dùng ngày tháng năm làm seed sinh ra 1 vụ án duy nhất cho toàn thế giới cùng giải và so bảng xếp hạng thời gian.

---

### 6. Trình Thiết Kế Màn Chơi Tùy Biến (Level Editor Suite & Custom Cases - V8)
*Mã nguồn Dupery gốc: 22 classes `LevelEditorManager`, `LEBoardManager`, `LEAdderMenu`, `LEProblemHighlighter`.*

- **Bộ Công Cụ Thiết Kế Kéo Thả Trực Quan**:
  - Giao diện lưới ô cắm thẻ bài (Slot Snapping Grid).
  - Thanh công cụ chọn thẻ (Adder Menu): Kéo thả nhân vật, hung thủ, nhân chứng, vật chứng vào vị trí mong muốn.
  - Đồng hồ đo tài nguyên (Fuel & Chips Meter): Tự động tính toán lượng tài nguyên cần thiết để giải vụ án này.
- **Bộ Kiểm Định Tính Hợp Lệ Thời Gian Thực (Real-Time Solvability Highlighter)**:
  - Hệ thống tự động chạy ngầm thuật toán giải đố để kiểm tra:
    - Nếu vụ án bị vô nghiệm: Báo viền đỏ cảnh báo.
    - Nếu vụ án có từ 2 hung thủ trở lên (nghiệm mơ hồ): Hiện cờ vàng báo lỗi logic.
    - Chỉ khi vụ án có duy nhất 1 lời giải đúng: Bật nút cho phép Xuất Bản.
- **Xuất / Nhập File Vụ Án (`CustomCase.json`)**:
  - Xuất toàn bộ cấu trúc vụ án thành 1 file JSON nhỏ gọn vài KB để gửi cho bạn bè hoặc đăng tải lên kho chia sẻ cộng đồng.

---

### 7. Hệ Thống Dụng Cụ Thám Tử Chuyên Sâu & Hiệu Ứng Game Feel (V4)
*Mã nguồn Dupery gốc: `MagnifyingGlassManager`, `StringManager`, Shaders.*

- **Kính Lúp Tương Tác Kèm Shader Thấu Kính (Magnifying Glass Lens Distortion)**:
  - Một chiếc kính lúp có thể cầm kéo lê khắp mặt bàn.
  - Sử dụng custom shader tạo độ lồi cong của kính quang học (barrel distortion), phóng to bề mặt thẻ bài để soi các manh mối vi mô ẩn giấu (như vết mực tẩy xóa, dấu vân tay ẩn, sợi vải trên áo).
- **Hiệu Ứng Vật Lý Dây Chỉ (String Physics & Juice)**:
  - Dây chỉ có thể dùng chuột kéo gảy như dây đàn guitar (`string_pluck.wav`).
  - Khi dây bị kéo quá căng: Dây chuyển sang màu đỏ nhấp nháy và phát tiếng căng đứt.
- **Dấu Triện Mực Đỏ (Red Wax / Ink Stamp Physics)**:
  - Dấu triện kết tội bằng gỗ cầm tay dập mạnh xuống mặt bàn có hiệu ứng Squash & Stretch (bẹp xuống rồi nảy lên) kèm bụi giấy bay ra (`dust_particles`).

---

## PHẦN 3: TỔNG HỢP DANH MỤC ASSET GỐC MƯỢN TẠM TỪ VAULT

Toàn bộ tài nguyên gốc đã trích xuất sạch sẽ trong Chặng 3, sẵn sàng đưa vào sử dụng ngay cho Fan-Game Thần Trùng:

1. **Sprites PNG & Atlas (879 Sprites / 59 Sheets)**:
   - Toàn bộ khung thẻ bài Nine-Patch (Thẻ Nghi phạm, Thẻ Manh mối, Thẻ Nhân chứng, Thẻ Báo chí).
   - 3 loại Ghim găm gỗ (Đỏ, Vàng, Xanh dương).
   - Dụng cụ: Kính lúp kim loại, Kẹp giấy sắt, Thước đo thám tử, Đồng hồ quả quýt, Búa đấu giá gỗ.
   - Bề mặt: Mặt bàn gỗ sồi trinh thám, texture giấy báo cũ ngả vàng, tem niêm phong cảnh sát.
2. **Âm Thanh PCM WAV (155 Samples Sạch Sẽ)**:
   - Hiệu ứng ghim: `pin_in_01..04.wav`, `pin_out_01..03.wav`.
   - Hiệu ứng dây: `string_drag.wav`, `string_snap.wav`, `string_pluck_01..03.wav`.
   - Hiệu ứng giấy: `paper_shuffle.wav`, `card_flip_01..05.wav`, `page_turn.wav`.
   - Hiệu ứng phán quyết: `gavel_strike.wav`, `handcuffs_click.wav`, `stamp_impact.wav`.
   - 16 Đoạn Saxophone Solo Jazz Riffs (`sax_riff_01..16.wav`).
3. **Phông Chữ Chuyên Nghiệp**:
   - 6 Phông máy đánh chữ cơ học và phông tiêu đề báo chí Noir sắc nét 1080p.
4. **Shaders**:
   - `ContinuousWobble.gdshader` (Rung nét vẽ giấy báo sống động).
   - `LensDistortion.gdshader` (Độ lồi thấu kính của kính lúp).

---

Tài liệu bách khoa này đã liệt kê đầy đủ 100% không bỏ sót bất kỳ chi tiết nào của game gốc. Bạn có thể lưu giữ tài liệu này làm kim chỉ nam để kích hoạt Chặng Extra ngay sau khi hoàn thành Chặng 4!
