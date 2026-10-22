# DUPERY & THAN TRUNG 2 — TÀI LIỆU BÀN GIAO DỰ ÁN & HƯỚNG DẪN ONBOARDING CHẶNG 4

> **Dành Cho**: Đồng nghiệp lập trình & AI Agent đồng hành  
> **Repository**: `Than_Trung_2` | **Branch**: `YukiiMin-Guideline-for-project`  
> **Engine**: Godot 4.6.2 (Windows, Canvas 1920x1080) | **Python**: 3.10+  
> **Thời Điểm Bàn Giao**: 22/10/2026  
> **Trạng Thái Hiện Tại**: Đã hoàn thành 100% Chặng 1, Chặng 2, Chặng 3 (210/210 Tests PASS, 0 lỗi hồi quy). Sẵn sàng bắt đầu **`TASK-0033` (Chặng 4)**.

---

## 1. TỔNG QUAN DỰ ÁN & TIẾN TRÌNH ĐÃ HOÀN THÀNH

Dự án này là bản Fan-Game kết hợp giữa **Thần Trùng** (bối cảnh, nhân vật, không khí kinh dị Việt Nam) và cơ chế giải đố trinh thám thẻ bài chiều sâu của tựa game Steam **Dupery** (bảng thám tử, ghim chỉ Catenary2D, sinh vụ án tất định, đấu giá ẩn, looting quạt bài).

### Tiến Trình 3 Chặng Đã Nghiệm Thu:
- **Chặng 1 (Phase 0 & Toolchain Prep)**: Đã thiết lập Gatekeepers (`check_scope.py`), vá lỗi Windows ESTALE của công cụ REA, trích xuất TypeTree và Asset topology mẫu (`TASK-0001` $\rightarrow$ `TASK-0004`).
- **Chặng 2 (Phase 1 Đồ Thị Godot & TOON)**: Quét 1.735 file dự án Godot hiện hữu, phát hiện 11 God-files, xây dựng đồ thị quan hệ tĩnh (`scene_graph.json`, `code_symbols.json`), kiểm chứng cây SceneTree sống qua Windowed GL 640x480 đạt 90% correlation, đóng gói CLI `query_godot_graph.py` (`TASK-0005` $\rightarrow$ `TASK-0009`).
- **Chặng 3 (Phase 2 Giải Phẫu Chi Tiết Dupery Gốc)**:
  - **Tầng A**: Decompile 5 assemblies Unity (.NET Mono) thành 1.464 file C# (4.38 MB); trích xuất 12 scenes YAML, 879 sprites PNG / 59 sheets, 155 samples PCM WAV từ 6 FMOD Banks, 6 gameplay reference videos DEC-26 (1080p 60 FPS CFR); tái lập dự án `Dupery_Unity_Project` (`TASK-0010` $\rightarrow$ `TASK-0021`).
  - **Tầng B (8 Vòng V1–V8)**: Biên soạn 13 cẩm nang bách khoa handbook L3, 10 bộ simulator và 10 test suites tất định (`TASK-0022` $\rightarrow$ `TASK-0029`).
  - **Tầng C**: Kiểm toán sổ cái 1.533 classes (`unaccounted == 0`), biên soạn Bách khoa di trú [MASTER_DUPERY_GODOT_MIGRATION_ENCYCLOPEDIA.md](docs/agent-system/evidence/dupery/handbook/MASTER_DUPERY_GODOT_MIGRATION_ENCYCLOPEDIA.md), xây dựng lược đồ ánh xạ liên dự án [cross_project_mapping.json](docs/agent-system/evidence/dupery/cross_project_mapping.json) với 12 recipes CLI tra cứu 1-chạm (`TASK-0030` $\rightarrow$ `TASK-0032`).

---

## 2. HƯỚNG DẪN GIẢI NÉN KHO ASSET VAULT (`Dupery_Heavy_Assets_Vault.zip`)

Vì các tệp nhị phân âm thanh và video gameplay rất nặng (~1.6 GB) nên chúng nằm trong `.gitignore` để tránh phình to Git history. Toàn bộ các tệp nặng này đã được đóng gói sẵn trong tệp **`Dupery_Heavy_Assets_Vault.zip`** nằm ngay tại thư mục gốc repository.

### Lệnh Giải Nén (Unzip) Chuẩn Xác:

Mở PowerShell tại thư mục gốc `Than_Trung_2` và chạy một trong các lệnh sau:

```powershell
# Cách 1 (Khuyến nghị - Nhanh nhất nếu có 7-Zip):
7z x Dupery_Heavy_Assets_Vault.zip -y

# Cách 2 (Dùng PowerShell thuần có sẵn trên Windows):
Expand-Archive -Path "Dupery_Heavy_Assets_Vault.zip" -DestinationPath "." -Force

# Cách 3 (Nếu dùng Linux hoặc macOS):
tar -xf Dupery_Heavy_Assets_Vault.zip
```

### Kiểm Tra Tính Toàn Vẹn Sau Khi Giải Nén:
Chạy lệnh kiểm định tất định sau, nếu hiển thị **`PASS (12/12 subsystems)`** nghĩa là toàn bộ asset đã khớp vị trí 100%:
```bash
python scripts/agent/query_cross_project_mapping.py --verify
```

Cấu trúc các thư mục được phục hồi sau khi giải nén:
- `docs/agent-system/evidence/dupery/vault/audio/samples/`: 155 tệp âm thanh PCM WAV sạch (tiếng ghim, rút ghim, kéo dây, búa gõ, 16 saxophone solo riffs).
- `docs/agent-system/evidence/dupery/references/gameplay/`: 6 tệp video MP4 thực tế 1080p 60 FPS chuẩn hóa theo DEC-26.
- `Dupery_Unity_Project/`: Toàn bộ solution Unity C# gốc hoàn chỉnh với `Assets/Art`, `Assets/Audio`, `Assets/Materials`, `Assets/Plugins`, `Assets/Scripts`.

---

## 3. BẢN ĐỒ TÀI LIỆU QUY HOẠCH QUAN TRỌNG TRONG DỰ ÁN

Tất cả tài liệu quy hoạch kiến trúc đã được chuyển từ thư mục tạm vào trực tiếp trong kho mã nguồn tại `docs/agent-system/plans/`:

| Đường Dẫn Tệp | Vai Trò & Nội Dung |
| :--- | :--- |
| [`docs/agent-system/plans/MASTER_EXECUTION_PLAN_ALL_STAGES.md`](docs/agent-system/plans/MASTER_EXECUTION_PLAN_ALL_STAGES.md) | **Kế hoạch tổng thể 4 chặng**: Lộ trình tiến hóa xuyên suốt từ Chặng 1 đến Chặng 4 và Chặng Extra. |
| [`docs/agent-system/plans/STAGE_4_AND_EXTRA_MASTER_BLUEPRINT.md`](docs/agent-system/plans/STAGE_4_AND_EXTRA_MASTER_BLUEPRINT.md) | **Bản vẽ quy hoạch tổng thể Chặng 4 & Chặng Extra**: Kiến trúc phân tầng hai chặng, bảng mượn tạm asset gốc, phân rã 9 tasks Chặng 4 và 6 tasks Chặng Extra. |
| [`docs/agent-system/plans/STAGE_4_DETAILED_EXECUTION_PLAN.md`](docs/agent-system/plans/STAGE_4_DETAILED_EXECUTION_PLAN.md) | **Kế hoạch chi tiết Chặng 4**: Chi tiết từng task từ `TASK-0033` đến `TASK-0041` (Single-player core và Mạng LAN Multiplayer). |
| [`docs/agent-system/plans/STAGE_EXTRA_FULL_PARITY_SPECIFICATION.md`](docs/agent-system/plans/STAGE_EXTRA_FULL_PARITY_SPECIFICATION.md) | **Bách khoa toàn thư Chặng Extra**: Mô tả toàn diện 7 hệ sinh thái lớn của game gốc (228 Roles/Abilities, Noir Jazz 5 buses, Lineup accusation, Codex, 6 Alternate modes, Level Editor) mà không chia task để tiết kiệm context. |
| [`docs/agent-system/problems/Tua_game_nay_dang_co_van_de.txt`](docs/agent-system/problems/Tua_game_nay_dang_co_van_de.txt) | **Báo cáo thực địa**: Danh sách 6 điểm nghẽn gốc của dự án fan-game cần giải quyết triệt để trong Chặng 4. |

---

## 4. KỶ LUẬT QUẢN TRỊ BẮT BUỘC CHO AI AGENT (`AI-AGENTS-Template`)

Bất kỳ AI Agent nào tiếp quản làm việc trên dự án này đều **BẮT BUỘC PHẢI TUÂN THỦ** các nguyên tắc bất biến sau:

1. **Nhánh Git & Quản Trị Scope**:
   - Chỉ được commit trên nhánh: **`YukiiMin-Guideline-for-project`**. Nhánh `main` bị khóa bảo toàn tuyệt đối.
   - Mọi sửa đổi phải nằm trong phạm vi `in_scope` được khai báo trong hợp đồng `docs/agent-system/tasks/TASK-XXXX.md`. Công cụ `scripts/agent/check_scope.py` sẽ chặn cứng nếu vi phạm.
2. **Kỷ Luật Ngân Sách Dòng Lệnh (ADR-0010 DEC-AMEND-01)**:
   - **Ngưỡng cảnh báo (`warn`)**: **800 dòng (LOC)**.
   - **Ngưỡng chặn đứng (`hard cap`)**: **1.000 dòng (LOC)**.
   - Mục tiêu thiết kế kiến trúc chuẩn: Mỗi file/module đơn trách nhiệm `< 300 LOC`.
   - **Nghiêm cấm mọi hành vi gian lận (Anti-Cheat)**: Tuyệt đối không dùng dấu chấm phẩy `;` để gộp dòng, không dùng comment placeholder dạng `// ... existing code remains unchanged`.
3. **Quy Trình Kiểm Toán Đối Kháng Đồng Cấp (Subagent Peer-Audit Gate per DEC-17)**:
   - Nghiêm cấm AI Agent tự chấm điểm bản thân (Anti-Self-Grading).
   - Trước khi một Task chuyển sang trạng thái `verified`: Bắt buộc phải spawn một **Subagent Peer-Auditor độc lập** kiểm toán toàn bộ mã nguồn, chạy bộ công cụ kiểm định, đối soát transcript chống trade-off ngầm, và ghi biên nhận `docs/agent-system/evidence/TASK-XXXX-peer-audit.json` (`verdict: "PASS"`).
   - Lệnh ký số nghiệm thu duy nhất được phép: `python scripts/agent/run_verify.py --task TASK-XXXX`.
4. **Quy Tắc Engine Godot 4.6.2 (Windows)**:
   - **TUYỆT ĐỐI KHÔNG CHẠY `godot --headless` TRÊN WINDOWS** (gây treo tiến trình và lỗi viewport).
   - Muốn kiểm tra đồ họa, cây SceneTree: Dùng lệnh chạy cửa sổ thật Windowed GL tự đóng hoặc kiểm tra tĩnh qua parser.
   - Giao diện phải chuẩn hóa trên Canvas cố định **1920x1080**, bật Pixel Snap để font chữ và thẻ bài sắc nét.

---

## 5. BẮT TAY VÀO VIỆC NGAY: HƯỚNG DẪN TRIỂN KHAI `TASK-0033`

Task đầu tiên bạn và AI Agent cần thực hiện là **`TASK-0033` (Phase 0 Gatekeeper Upgrade Nhịp 0.2b)** để mở đường cho việc refactor code Godot:

### Mục Tiêu Của `TASK-0033`:
1. Mở `docs/agent-system/project-config.json`:
   - Bổ sung extension `".gd"` vào danh sách `include_extensions`.
   - Khai báo danh sách `baseline_exemptions` cho 11 God-files hiện có trong `Than_Tham_Nua_Voi_Godot` (như `SmokeTestRunner.gd`, `PlayerFacingStartController.gd`, `AuctionCatalog.gd`, `VSCaseMainController.gd`, `CaseGeneratorPublicSolver.gd`, `SuspectCardController.gd`, v.v.) để hệ thống không báo lỗi ngay trên các file cũ này, nhưng chặn cứng không cho chúng phình to thêm qua `check_diff_guard.py`.
2. Cập nhật `scripts/agent/check_line_budget.py`:
   - Hỗ trợ role phân loại cho file `.gd`.
   - Áp dụng cơ chế bỏ qua file trong `baseline_exemptions` khi đo ngân sách tổng thể.
3. Mở rộng unit tests trong `tests/test_check_line_budget.py` kiểm chứng tính năng exemptions và extension `.gd`.
4. Chạy kiểm toán đối kháng qua Subagent Peer-Audit và chạy `python scripts/agent/run_verify.py --task TASK-0033` để chuyển trạng thái sang `verified`.

Sau khi `TASK-0033` hoàn thành, tiến hành tuần tự các Task tiếp theo:
- **`TASK-0034`**: Rewrite `CaseGenerator` (nạp Knuth DotNetRandom và 20 ràng buộc từ V2A, Fuzz test 1.000 seeds).
- **`TASK-0035`**: Clean Rebuild màn hình Giải đố Canvas 1920x1080 (gắn 879 sprites gốc, ghim Catenary2D, sửa lỗi font 5px).
- **`TASK-0036`**: Case Selection (chọn 1/3 vụ án) & Lưu tiến trình vượt màn Candy Crush / Angry Birds.
- **`TASK-0037`**: Redesign màn hình Looting và Shop dạng quạt bài `ItemFanManager`.
- **`TASK-0038` $\rightarrow$ `TASK-0041`**: Xây dựng tầng nền Mạng LAN Multiplayer (UDP Discovery + Lobby slots Người/Bot + RPC Đấu giá ẩn).

---

Chúc bạn và đồng nghiệp phối hợp ăn ý và tiếp tục phát triển dự án thành công rực rỡ!
