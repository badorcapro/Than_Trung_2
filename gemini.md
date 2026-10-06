# Gemini & Antigravity Knowledge Base — Thần Thám Nửa Vời

Tài liệu này lưu trữ toàn bộ kiến thức tổng quan, kiến trúc, quy ước bất khả xâm phạm và chỉ mục tham chiếu nhanh tới [`CODEX_PROJECT_MAP.md`](file:///d:/Game%20Maker/%C4%90%E1%BB%95i%20acc/Than_Tham_Nua_Voi_Godot_Runtime_Clean/Than_Tham_Nua_Voi_Godot/CODEX_PROJECT_MAP.md) dành cho Google Antigravity (Gemini Agent) và các nhà phát triển.

---

## 1. Thông Tin Dự Án (Project Identity)

* **Tên dự án:** Thần Thám Nửa Vời – Truyền Kì Kỳ Án Hoàng Cung
* **Thể loại:** Game trinh thám suy luận logic thẻ bài (Social deduction / Puzzle RPG)
* **Engine:** Godot Engine **4.6.2 stable**
* **Renderer:** GL Compatibility
* **Ngôn ngữ:** GDScript
* **Cấu trúc thư mục:**
  * Thư mục gốc Workspace: `d:\Game Maker\Đổi acc\Than_Tham_Nua_Voi_Godot_Runtime_Clean\`
  * Dự án Godot chính: [`Than_Tham_Nua_Voi_Godot/`](file:///d:/Game%20Maker/%C4%90%E1%BB%95i%20acc/Than_Tham_Nua_Voi_Godot_Runtime_Clean/Than_Tham_Nua_Voi_Godot)
  * Tài liệu ảnh / Art references: [`art references/`](file:///d:/Game%20Maker/%C4%90%E1%BB%95i%20acc/Than_Tham_Nua_Voi_Godot_Runtime_Clean/art%20references)

---

## 2. Các Quy Ước Bất Khả Xâm Phạm (Core Guardrails)

1. 🚫 **KHÔNG chạy Godot Headless CLI:**
   * Không tự ý thực thi các lệnh `godot --headless` hoặc điều tra lỗi headless crash qua terminal. Môi trường Windows GL Compatibility không hỗ trợ headless ổn định.
   * Việc xác thực runtime do người dùng thực hiện trực tiếp trên Godot GUI hoặc thông qua màn hình `DebugHome`.
2. 🔒 **Presentation Separation Contract:**
   * Tuyệt đối không để tầng UI/Presentation (`SuspectCard`, `CaseBoard`, `VSCaseMainController`) mutate trực tiếp state gameplay (`CaseRuntimeState`, `SuspectRuntimeState`, `PlayerCaseState`).
   * Không bao giờ suy diễn tính đúng sai hoặc vai trò ẩn từ nội dung văn bản hiển thị trên nhãn thẻ. Mọi thông tin hiển thị phải đi qua `SuspectPublicViewData` và `CasePublicPresentationBuilder`.
3. 🎯 **Quy tắc STOP & Báo cáo Checkpoint:**
   * Sau khi hoàn thành đúng phạm vi tác vụ được giao, dừng lại ngay lập tức và báo cáo:
     - Danh sách file đã sửa.
     - Authority chính xác đã tác động.
     - Các Smoke/static assertions đã thêm hoặc cập nhật.
     - Checklist kiểm tra thủ công cần người dùng bấm trên GUI.
   * Không tự ý nhảy sang milestone tiếp theo khi chưa có yêu cầu từ người dùng.
4. 🚀 **Chính sách Tự Động Commit & Push Remote (Auto-Commit & Push Policy):**
   * Sau khi hoàn thành bất kỳ tác vụ nào do người dùng giao, Antigravity **bắt buộc tự động chạy commit Git và đẩy thẳng lên remote (`git push origin main`)** để đồng bộ mã nguồn.
   * Định dạng commit tuân thủ chuẩn **Conventional Commits**: `<type>(<scope>): <mô tả ngắn>`.
   * Chủ động hoàn thiện code và tự động hóa kiểm tra nội bộ; không bắt người dùng phải kiểm tra thủ công trên GUI nếu không có yêu cầu đặc biệt.

---

## 3. Kiến Trúc Phân Tầng (Architecture Layers)

Dự án áp dụng mô hình Clean Architecture & Domain-Driven Design (DDD) trong [`Than_Tham_Nua_Voi_Godot/scripts/`](file:///d:/Game%20Maker/%C4%90%E1%BB%95i%20acc/Than_Tham_Nua_Voi_Godot_Runtime_Clean/Than_Tham_Nua_Voi_Godot/scripts):

* `domain/`: Trung tâm logic trò chơi (chứa các Entity, State, Value Object, Service logic suy luận, bộ sinh vụ án `CaseGenerator`, và bộ giải `CaseGeneratorPublicSolver`).
* `application/`: Điều phối luồng nghiệp vụ của ca án (Investigation, Accusation, Verdict, Progression, Round/Match management, Loot & Equipment).
* `infrastructure/`: Kho dữ liệu và tài nguyên (Repository tải vai trò, bản đồ, kịch bản ca án qua `FixtureRepository`).
* `presentation/`: Giao diện và Adapter (Controller điều khiển thẻ bài, bàn đấu, hiển thị sổ vai trò, popup giải nghĩa).
* `tools/`: Các công cụ kiểm thử tĩnh và kiểm thử Smoke đồ sộ ([`SmokeTestRunner.gd`](file:///d:/Game%20Maker/%C4%90%E1%BB%95i%20acc/Than_Tham_Nua_Voi_Godot_Runtime_Clean/Than_Tham_Nua_Voi_Godot/scripts/tools/SmokeTestRunner.gd)).

---

## 4. Cơ Chế Gameplay Cốt Lõi

* **Phân định Phe Phái:**
  * **Phe Thiện:** `Người Vô Tội` (Innocent), `Kẻ Bao Đồng` (Meddler).
  * **Phe Ác:** `Thuộc Hạ` (Underling), `Nghịch Thần` (Traitor).
* **Phân biệt danh tính:**
  * `vai trò thật` (True Role): Bản chất thực tế của nghi phạm khi bắt đầu hoặc được gán.
  * `vai trò hiển thị` (Displayed/Pretended Role): Vai trò lộ diện ra công chúng trên bàn đấu.
  * `vai trò hiện tại sau biến đổi` (Current Transformed Role): Vai trò bị đột biến (ví dụ bị Chủ Quán Rượu biến thành Kẻ Say Rượu).
* **Các hiệu ứng đặc biệt:**
  * **Tha hóa (Taint):** `Độc Sư` làm tha hóa một người vô tội lân cận, khiến người đó nói dối.
  * **Biến đổi (Transform):** `Chủ Quán Rượu` biến 1 người vô tội thành `Kẻ Say Rượu`. Kẻ Say Rượu phát ngôn sai nhưng vẫn là người của Phe Thiện.
  * **Vay mượn chức năng (Borrowed function):** `Kẻ Bắt Chước` hoặc kẻ cải trang vay mượn chức năng hành động (như Thợ May, Sư Tử Phán).
  * **Sự kiện theo mốc giờ (Timed Events):** `Sát Nhân Hàng Loạt` (giết người ở mốc 9h), `Bác Sĩ Phẫu Thuật` (giết người ở mốc 12h), `Tháp Đồng Hồ` (reo chuông theo chu kỳ).
  * **Chỉ Điểm (Accusation):** Thám tử tự chỉ điểm riêng rẽ; kết quả đúng/sai là thông tin cá nhân của người chỉ điểm, không công khai phá vỡ bí mật của bàn đấu.
  * **Toàn Án Phơi Bày (Full Reveal):** Kết thúc vụ án, lật mở toàn bộ sự thật, trạng thái tha hóa, lịch sử biến đổi và danh tính thật của từng nghi phạm.

---

## 5. Bảng Chỉ Mục Tham Chiếu Nhanh Tới `CODEX_PROJECT_MAP.md`

Tất cả chi tiết kỹ thuật sâu được duy trì tại [`Than_Tham_Nua_Voi_Godot/CODEX_PROJECT_MAP.md`](file:///d:/Game%20Maker/%C4%90%E1%BB%95i%20acc/Than_Tham_Nua_Voi_Godot_Runtime_Clean/Than_Tham_Nua_Voi_Godot/CODEX_PROJECT_MAP.md). Dưới đây là mục lục tham chiếu nhanh:

| Chủ Đề / Khía Cạnh | Vị Trí Trong CODEX_PROJECT_MAP.md | Mô Tả Tóm Tắt |
|---|---|---|
| **Project Guardrails & Stop Rules** | [Dòng 7 - 35](file:///d:/Game%20Maker/%C4%90%E1%BB%95i%20acc/Than_Tham_Nua_Voi_Godot_Runtime_Clean/Than_Tham_Nua_Voi_Godot/CODEX_PROJECT_MAP.md#L7-L35) | Quy định cấm headless test, quy tắc dừng báo cáo, ranh giới sửa code. |
| **Scene / Entry Points** | [Dòng 36 - 52](file:///d:/Game%20Maker/%C4%90%E1%BB%95i%20acc/Than_Tham_Nua_Voi_Godot_Runtime_Clean/Than_Tham_Nua_Voi_Godot/CODEX_PROJECT_MAP.md#L36-L52) | Điểm vào chính: `Boot.tscn`, `DebugHome.tscn`, `RoleCodexController.gd`, `VSCaseMainController.gd`. |
| **Autoload Authorities** | [Dòng 53 - 65](file:///d:/Game%20Maker/%C4%90%E1%BB%95i%20acc/Than_Tham_Nua_Voi_Godot_Runtime_Clean/Than_Tham_Nua_Voi_Godot/CODEX_PROJECT_MAP.md#L53-L65) | Danh sách Autoload: `AppFlow`, `AppLogger`, `AppVersion`, `FixtureRepository`. |
| **Content & Fixture Rules** | [Dòng 66 - 82](file:///d:/Game%20Maker/%C4%90%E1%BB%95i%20acc/Than_Tham_Nua_Voi_Godot_Runtime_Clean/Than_Tham_Nua_Voi_Godot/CODEX_PROJECT_MAP.md#L66-L82) | Quy định tải `.tres`, plain Vietnamese text cho `help_text`, không nhúng BBCode vào data role. |
| **Tutorial Status Snapshot (T01 - T08)** | [Dòng 83 - 110](file:///d:/Game%20Maker/%C4%90%E1%BB%95i%20acc/Than_Tham_Nua_Voi_Godot_Runtime_Clean/Than_Tham_Nua_Voi_Godot/CODEX_PROJECT_MAP.md#L83-L110) | Trạng thái từng bài học hướng dẫn: T01–T05 đã đóng, T06/T08 chờ GUI Smoke, T07 đã xong. |
| **Human Verification Fixtures (HV1 - HV6)** | [Dòng 111 - 300](file:///d:/Game%20Maker/%C4%90%E1%BB%95i%20acc/Than_Tham_Nua_Voi_Godot_Runtime_Clean/Than_Tham_Nua_Voi_Godot/CODEX_PROJECT_MAP.md#L111-L300) | Checklist thao tác thủ công trên GUI để kiểm tra Disguise, Timed Coexistence, Mutation, Resolution Safety. |
| **Presentation Contract & UI Boundaries** | [Dòng 806 - 845](file:///d:/Game%20Maker/%C4%90%E1%BB%95i%20acc/Than_Tham_Nua_Voi_Godot_Runtime_Clean/Than_Tham_Nua_Voi_Godot/CODEX_PROJECT_MAP.md#L806-L845) | Hợp đồng phân tách UI/Domain, Dead Marker Seal, Reveal History Toggle, typography và footprint cố định. |
| **Want To Change X? Start Here** | [Dòng 846 - 867](file:///d:/Game%20Maker/%C4%90%E1%BB%95i%20acc/Than_Tham_Nua_Voi_Godot_Runtime_Clean/Than_Tham_Nua_Voi_Godot/CODEX_PROJECT_MAP.md#L846-L867) | Bảng hướng dẫn tra cứu nhanh: Sửa copy text, tooltip, suspect numbering, loot, match state ở đâu. |
| **Tutorial 06 Canonical Spec** | [Dòng 868 - 911](file:///d:/Game%20Maker/%C4%90%E1%BB%95i%20acc/Than_Tham_Nua_Voi_Godot_Runtime_Clean/Than_Tham_Nua_Voi_Godot/CODEX_PROJECT_MAP.md#L868-L911) | Thiết kế layout, slot nghi phạm, tỷ lệ ban đầu và chân tướng của Tutorial 06. |

---

## 6. Quy Trình Auto-Commit Khi Hoàn Thành Tác Vụ

Mỗi khi người dùng giao một tác vụ:
1. Đọc và cập nhật `.agent_scratchpad.md` nếu tác vụ có từ 3 bước trở lên.
2. Kiểm tra mã nguồn, đối chiếu `CODEX_PROJECT_MAP.md` và `gemini.md`.
3. Thực hiện sửa đổi bằng các công cụ targeted edit (`replace_file_content`, `write_to_file`).
4. Kiểm tra tĩnh (static checks) và đảm bảo không phá vỡ hợp đồng presentation.
5. **Tự động chạy lệnh commit và đẩy lên remote**:
   ```powershell
   git add .
   git commit -m "<type>(<scope>): <mô tả tác vụ>"
   git push origin main
   ```
6. Báo cáo kết quả và mã commit hash cho người dùng; sẵn sàng nhận nhiệm vụ tiếp theo.
