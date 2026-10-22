# GEMINI.md — Gemini & Antigravity Knowledge Base & Engine Rules

> **Reference ID**: `RULE-ENGINE-001`  
> **Authority**: `approved`  
> **Status**: `current`  
> **Target Branch**: `YukiiMin-Guideline-for-project` (Nhánh `main` được bảo toàn nguyên trạng làm mốc đối chiếu `[V]`)

Tài liệu này lưu trữ toàn bộ kiến thức tổng quan, kiến trúc, quy ước bất khả xâm phạm và chỉ mục tham chiếu nhanh tới [`Than_Tham_Nua_Voi_Godot/CODEX_PROJECT_MAP.md`](Than_Tham_Nua_Voi_Godot/CODEX_PROJECT_MAP.md) dành cho Google Antigravity (Gemini Agent) và các nhà phát triển.

---

## 1. Thông Tin Dự Án (Project Identity)

* **Tên dự án:** Thần Thám Nửa Vời – Truyền Kì Kỳ Án Hoàng Cung
* **Thể loại:** Game trinh thám suy luận logic thẻ bài (Social deduction / Puzzle RPG)
* **Engine:** Godot Engine **4.6.2 stable**
* **Renderer:** GL Compatibility
* **Ngôn ngữ:** GDScript (Static Typing)
* **Cấu trúc thư mục (Workspace-relative POSIX):**
  * Thư mục gốc Workspace: `.`
  * Dự án Godot chính: `Than_Tham_Nua_Voi_Godot/`
  * Bản đồ điều hướng kỹ thuật: `Than_Tham_Nua_Voi_Godot/CODEX_PROJECT_MAP.md`
  * Nhật ký trạng thái liên tục: `PROJECT_MEMORY_CURRENT.md`
  * Hệ thống quản trị và kiểm chứng: `docs/agent-system/` và `scripts/agent/`

---

## 2. Các Quy Ước Bất Khả Xâm Phạm (Core Guardrails)

1. 🚫 **KHÔNG chạy Godot Headless CLI:**
   * Không tự ý thực thi các lệnh `godot --headless` hoặc điều tra lỗi headless crash qua terminal. Môi trường Windows GL Compatibility không hỗ trợ headless ổn định.
   * Việc xác thực runtime do người dùng thực hiện trực tiếp trên Godot GUI hoặc thông qua màn hình `DebugHome` / kịch bản Windowed GL tự động.
2. 🔒 **Presentation Separation Contract:**
   * Tuyệt đối không để tầng UI/Presentation (`SuspectCard`, `CaseBoard`, `VSCaseMainController`) mutate trực tiếp state gameplay (`CaseRuntimeState`, `SuspectRuntimeState`, `PlayerCaseState`).
   * Không bao giờ suy diễn tính đúng sai hoặc vai trò ẩn từ nội dung văn bản hiển thị trên nhãn thẻ. Mọi thông tin hiển thị phải đi qua `SuspectPublicViewData` và `CasePublicPresentationBuilder`.
3. 🎯 **Quy tắc STOP & Báo cáo Checkpoint:**
   * Sau khi hoàn thành đúng phạm vi tác vụ được giao trong `TASK-XXXX.md`, dừng lại ngay lập tức và báo cáo:
     - Danh sách file đã sửa.
     - Authority chính xác đã tác động.
     - Các Smoke/unit assertions đã thêm hoặc cập nhật.
     - Checklist kiểm tra thủ công cần người dùng bấm trên GUI (nếu có).
   * Không tự ý nhảy sang milestone tiếp theo khi chưa có yêu cầu từ người dùng.
4. 🚀 **Chính sách Nhánh Phát Triển & Commit Git (Branch & Push Policy):**
   * Mọi phát triển và thay đổi mã nguồn bắt buộc thực hiện trên nhánh **`YukiiMin-Guideline-for-project`**.
   * Nhánh `main` được bảo toàn tuyệt đối, không đẩy trực tiếp vào `main`.
   * Định dạng commit tuân thủ chuẩn **Conventional Commits**: `<type>(<scope>): <mô tả ngắn>`.
   * Khi đẩy mã nguồn lên remote:
     ```powershell
     git push origin YukiiMin-Guideline-for-project
     ```
5. ⚖️ **Quy Tắc Định Giá Vật Phẩm Đấu Giá (Decoupled Size-Price Valuation):**
   * Tuyệt đối **không** định giá vật phẩm theo kích thước ô lưới (không mặc định đồ to 2x2, 2x3, 4x2 là đắt tiền, đồ nhỏ 1x1, 1x2 là rẻ tiền).
   * Giá trị xu bạc (`silver_value`) phải được phân bổ ngẫu nhiên và phản ánh bản chất thực tế của vật phẩm trong cùng bậc phẩm chất (Rarity):
     - Đồ công nghệ cao, thiết bị điện tử, dữ liệu tình báo, y tế, dụng cụ cơ khí chính xác (dù chỉ chiếm 1x1, 1x2) hoàn toàn có thể sở hữu mức giá cao nhất trong bậc.
     - Đồ thô sơ, vật liệu xây dựng cồng kềnh, thức ăn tiêu hao (dù chiếm 2x2, 2x3) có thể có mức giá thấp hoặc trung bình trong bậc.
6. 🖼️ **Quy Chuẩn Thiết Kế Asset Khung UI & NinePatch (Clean Scalable UI Frame Rule):**
   * **Tối giản hóa họa tiết:** Tránh nhồi nhét quá nhiều chi tiết phức tạp, hoa văn dày đặc vào các asset NinePatch/StyleBoxTexture.
   * **Đảm bảo khả năng co giãn (Scalability):** Khung giao diện phải sử dụng các đường viền thanh mảnh, góc bo gọn gàng, chia tỉ lệ 9-slice rõ ràng để khi co giãn đều giữ nguyên tỷ lệ, không bị kéo dãn bẹp dí hay vỡ nét.
   * **Tách rời thành phần tương tác (Decoupled Interactive Controls):** Không vẽ cứng các nút bấm tương tác (Đóng X, Minimize, Tab) trực tiếp vào texture nền của cửa sổ. Mọi nút bấm tương tác phải là Node/Texture riêng biệt với hitbox và hiệu ứng hover/focus chuẩn xác 100%.

---

## 3. Kiến Trúc Phân Tầng (Architecture Layers)

Dự án áp dụng mô hình Clean Architecture & Domain-Driven Design (DDD) trong `Than_Tham_Nua_Voi_Godot/scripts/`:

* `domain/`: Trung tâm logic trò chơi (chứa các Entity, State, Value Object, Service logic suy luận, bộ sinh vụ án `CaseGenerator`, và bộ giải `CaseGeneratorPublicSolver`).
* `application/`: Điều phối luồng nghiệp vụ của ca án (Investigation, Accusation, Verdict, Progression, Round/Match management, Loot & Equipment).
* `infrastructure/`: Kho dữ liệu và tài nguyên (Repository tải vai trò, bản đồ, kịch bản ca án qua `FixtureRepository`).
* `presentation/`: Giao diện và Adapter (Controller điều khiển thẻ bài, bàn đấu, hiển thị sổ vai trò, popup giải nghĩa).
* `tools/`: Các công cụ kiểm thử tĩnh và kiểm thử Smoke đồ sộ (`SmokeTestRunner.gd`).

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

## 5. Bảng Chỉ Mục Tham Chiếu Nhanh

| Chủ Đề / Khía Cạnh | Vị Trí Tham Chiếu | Mô Tả Tóm Tắt |
|---|---|---|
| **Project Guardrails & Stop Rules** | `Than_Tham_Nua_Voi_Godot/CODEX_PROJECT_MAP.md` (L7 - 35) | Quy định cấm headless test, quy tắc dừng báo cáo, ranh giới sửa code. |
| **Current Continuity & Roadmap** | `PROJECT_MEMORY_CURRENT.md` | Nguồn sự thật duy nhất về checkpoint hiện tại, tiến độ GĐ2, PF-M8, PF-M9, và bug đã xử lý. |
| **Scene / Entry Points** | `Than_Tham_Nua_Voi_Godot/CODEX_PROJECT_MAP.md` (L36 - 52) | Điểm vào chính: `Boot.tscn`, `DebugHome.tscn`, `PlayerFacingStart.tscn`. |
| **Autoload Authorities** | `Than_Tham_Nua_Voi_Godot/CODEX_PROJECT_MAP.md` (L53 - 65) | Danh sách Autoload: `AppFlow`, `AppLogger`, `AppVersion`, `FixtureRepository`. |
| **Giai Đoạn 2: Production Tabletop Loot Map** | `PROJECT_MEMORY_CURRENT.md` (Mục 7) | Bản đồ 77 ô Imperial Court (`imperial_court_tabletop_v1`), 5 gia tộc, spawn, hubs, camera UX. |
| **Giai Đoạn 2: Production Character Roster** | `PROJECT_MEMORY_CURRENT.md` (Mục 6) | 5 nhân vật chính (Hoàng Linh Lâm, Chu Tuệ Nguyệt, Kim Thanh Giai, Huyền Ca Xuý, Lam Phương Xuân), chỉ số 2/2/2. |
| **Giai Đoạn 2: Production Consumables V1** | `PROJECT_MEMORY_CURRENT.md` (Mục 10) | 3 vật phẩm (Hành Lộ Phù, Lệnh Bài Thông Hành, Ngự Mã Lệnh), đã PASS 3188/3188. |
| **Player-Facing Meta (PF-M8, PF-M9)** | `PROJECT_MEMORY_CURRENT.md` (Mục 3, 4) | Match Rules, Results, Equipment Collection, Progression, Gacha, Autosave, Bag Overflow. |
| **Presentation Contract & UI Boundaries** | `Than_Tham_Nua_Voi_Godot/CODEX_PROJECT_MAP.md` (L806 - 845) | Hợp đồng phân tách UI/Domain, Dead Marker Seal, Reveal History Toggle, typography và footprint cố định. |
| **Want To Change X? Start Here** | `Than_Tham_Nua_Voi_Godot/CODEX_PROJECT_MAP.md` (L846 - 867) | Bảng hướng dẫn tra cứu nhanh: Sửa copy text, tooltip, suspect numbering, loot, match state ở đâu. |

---

## 6. Quy Trình Làm Việc Theo Hợp Đồng Task (Task Execution Protocol)

Mỗi khi thực hiện một tác vụ:
1. Đọc và cập nhật `.agent_scratchpad.md` nếu tác vụ có từ 3 bước trở lên.
2. Kiểm tra `reference-registry.json` và mã nguồn theo hợp đồng `docs/agent-system/tasks/TASK-XXXX.md`.
3. Thực hiện sửa đổi bằng các công cụ targeted edit strictly within `in_scope`.
4. Chạy kiểm chứng tất định qua `python scripts/agent/run_verify.py --task TASK-XXXX`.
5. Sau khi Task chuyển sang `verified` và được người dùng duyệt (`--approve`), commit và đẩy lên nhánh phát triển:
   ```powershell
   git add .
   git commit -m "<type>(<scope>): <mô tả tác vụ>"
   git push origin YukiiMin-Guideline-for-project
   ```
6. Báo cáo kết quả và mã commit hash cho người dùng; sẵn sàng nhận nhiệm vụ tiếp theo.
