# Thần Trùng 2 (Fan-Game) — Thần Thám Nửa Vời

> **Dự án Game Trinh Thám Suy Luận & Điều Tra Tâm Linh trên Godot Engine 4.6.2 (.NET / C#)**  
> Sự giao thoa độc đáo giữa không khí kinh dị tâm linh của vũ trụ *Thần Trùng* và chiều sâu cơ chế suy luận vụ án từ tựa game trinh thám *Dupery* (Steam), được xây dựng dưới khung quản trị AI-Native Engineering Operating System 2 tầng.

---

## 1. Tổng Quan Dự Án

**Thần Trùng 2 (Thần Thám Nửa Vời)** là dự án fan-game trinh thám góc nhìn 2D (Canvas 1920x1080) kết hợp giữa cốt truyện điều tra hiện tượng kỳ bí và hệ thống cơ chế suy luận logic chặt chẽ:
- **Nguyên bản cảm hứng**: Không khí bí ẩn, các vụ án đô thị mang đậm bản sắc Việt Nam từ *Thần Trùng* kết hợp cùng toàn bộ hệ thống cơ chế lõi của tựa game suy luận *Dupery* (Steam).
- **Nền tảng công nghệ**: **Godot Engine 4.6.2 (.NET Edition)**, C# (.NET 8.0) cho Core Engine & Domain Logic.
- **Tiến độ hiện tại**: Đã hoàn thành 100% Chặng 1, 2, 3 (Decompile 1.464 file C# Dupery, kiểm toán 1.533 lớp, 13 handbooks L3, Master Encyclopedia, đối chiếu 12/12 hệ thống con, 210/210 automated unit tests PASS). Đang bước vào **Chặng 4: Tái Cấu Trúc Godot & Hạ Tầng Mạng LAN Multiplayer**.

---

## 2. Điểm Nhấn Cơ Chế Gameplay (Core Pillars)

### 📌 Bảng Thám Tử Tương Tác (Detective Board)
- Ghim hồ sơ, tài liệu, hiện vật và ảnh chụp hiện trường lên không gian 2D với pan/zoom không giới hạn.
- **Dây nối Catenary2D**: Hệ thống nối chỉ đỏ liên kết các đầu mối với hiệu ứng võng vật lý tự nhiên theo khoảng cách hai điểm ghim.
- Phân loại trực quan: Nghi phạm (Suspects), Chứng cứ (Evidence), Hiện trường (Locations), Mốc thời gian (Timestamps), Động cơ (Motives).

### 🎲 Máy Sinh Vụ Án Tất Định (Deterministic Case Generator)
- Thuật toán sinh ngẫu nhiên tất định dựa trên **Knuth DotNetRandom** với Seed có thể tái lập 100%.
- Kiểm soát nghiêm ngặt bởi **20 Generation Constraints**: Đảm bảo mọi vụ án được tạo ra luôn có lời giải duy nhất, không mâu thuẫn thời gian - không gian, và không xảy ra ngõ cụt logic.

### 🔍 Hệ Thống Phán Đoán & Câu Đố (1-of-3 Deduction)
- Bộ câu hỏi suy luận 3 ngôi: *Ai là thủ phạm?*, *Hung khí / Phương thức gây án là gì?*, *Động cơ / Mốc thời gian thực sự?*.
- Cơ chế đối chất bằng chứng với lời khai nghi phạm; hệ thống phán quyết phản hồi trực tiếp dựa trên bằng chứng đã liên kết.

### 🃏 Khám Xét & Xòe Quạt Thẻ Bài (Looting & Fan-out Deck)
- Cơ chế xòe quạt thẻ bài mượt mà khi người chơi thu thập vật phẩm, khám xét ngăn tủ hoặc tra cứu hồ sơ.
- Lật thẻ xem thông tin chi tiết, đặc tính vật lý và thuộc tính ẩn của bằng chứng.

### 🌐 Hạ Tầng Mạng LAN Multiplayer (Chặng 4 Platform)
- **Tự động dò tìm phòng**: UDP Broadcast Room Discovery (Port 7777) trong mạng nội bộ (cùng WiFi).
- **Lobby đa năng**: Phòng chờ hỗ trợ ghép linh hoạt giữa Người chơi (Human) và AI Bot.
- **Cơ chế RPC Secret Bidding**: Đấu giá manh mối và gửi đáp án suy luận bí mật giữa các thám tử, bảo mật tuyệt đối không lộ dữ liệu qua mạng cho đến vòng công bố phán quyết.

---

## 3. Kiến Trúc Kỹ Thuật (Architecture & Invariants)

Dự án áp dụng mô hình kiến trúc phân tách nghiêm ngặt:

```text
Than_Trung_2/
├── Than_Tham_Nua_Voi_Godot/         # Workspace Godot Engine 4.6.2 (.NET)
│   ├── scenes/                      # Màn chơi & UI (Board, CardFan, Lobby, Room)
│   ├── scripts/                     # C# / GDScript Scripts
│   │   ├── domain/                  # Pure Domain Logic (Case Gen, Solver, LAN Protocol)
│   │   └── presentation/            # Godot Nodes, CanvasLayer, Catenary2D, Shaders
│   ├── assets/                      # Textures, Fonts, SFX, Shaders
│   └── project.godot                # Cấu hình dự án Godot (1920x1080)
├── Dupery_Heavy_Assets_Vault.zip    # Kho asset gốc nén (2.43 GB, 2.731 files)
├── docs/agent-system/               # Trung tâm tri thức & quản trị AI
│   ├── plans/                       # Kế hoạch chi tiết Chặng 1-3, Chặng 4, Chặng Extra
│   ├── evidence/dupery/             # 13 Handbooks L3, Master Encyclopedia, Mapping
│   ├── decisions/                   # 12 Architectural Decision Records (ADR-0001..0012)
│   ├── tasks/                       # Task Execution Contracts (TASK-0001..TASK-0032)
│   └── HANDOFF.md                   # Tài liệu bàn giao toàn diện Chặng 4
├── scripts/agent/                   # Engine kiểm soát chất lượng & Gatekeepers (<= 400 lines)
└── tests/                           # 210 Automated Unit Tests (100% PASS)
```

### Quy Tắc Kiến Trúc Cốt Lõi:
1. **Presentation Separation Contract**: Toàn bộ Logic nghiệp vụ (Sinh vụ án, Giải đố, Giao thức LAN) là mã nguồn thuần túy, độc lập 100% với Godot Node và có thể kiểm thử tự động không cần khởi động engine.
2. **Godot Engine Guard (Windows)**: Tuyệt đối không chạy lệnh `godot --headless` tự động trên Windows (gây treo/crash engine ngầm). Mọi kiểm thử tự động chạy qua Python test harness hoặc `dotnet test`.
3. **Role-Based Line Budgets ([ADR-0010](docs/agent-system/decisions/ADR-0010-role-based-configurable-line-budgets.md))**: Giới hạn kích thước tệp theo vai trò (`warn: 800 / hard: 1000 LOC`), ngăn chặn các file nguyên khối (God classes) và chống cắt vụn mã nguồn.
4. **Fail-Closed Verification & Semantic Peer-Audit**: Mọi tính năng code đều phải có Task Contract (`TASK-XXXX.md`), kiểm toán độc lập qua Subagent Peer-Audit và sinh biên lai tamper-evident `TASK-XXXX-receipt.json`.

---

## 4. Hướng Dẫn Cài Đặt & Bắt Đầu (Quickstart)

### Yêu Cầu Môi Trường
- **Hệ điều hành**: Windows 10/11 (hoặc Linux/macOS)
- **Godot Engine**: [Godot Engine 4.6.2 - .NET Edition](https://godotengine.org/download)
- **.NET SDK**: .NET 8.0 SDK trở lên
- **Python**: Python 3.10+ (phục vụ bộ công cụ kiểm toán và test harness)

### Bước 1: Cài Đặt Dependencies Quản Trị
```powershell
pip install -r requirements.txt
```

### Bước 2: Giải Nén Kho Asset Nặng
Giải nén tệp `Dupery_Heavy_Assets_Vault.zip` (2.43 GB) vào ngay thư mục gốc của dự án. Sau khi giải nén, các thư mục sau sẽ xuất hiện:
- `docs/agent-system/evidence/dupery/vault/raw/` (Sprite textures, fonts)
- `docs/agent-system/evidence/dupery/vault/audio/samples/` (155 WAV audio samples)
- `docs/agent-system/evidence/dupery/references/gameplay/` (6 gameplay video references)
- `Dupery_Unity_Project/` (Dự án tham chiếu Unity gốc)

### Bước 3: Chạy Kiểm Thử Toàn Diện
```powershell
# Chạy bộ kiểm thử tự động (210/210 tests PASS):
python -m unittest discover -s tests -p "test_*.py"

# Xác thực tính toàn vẹn của Registry tài liệu:
python scripts/agent/validate_registry.py

# Kiểm tra ánh xạ 12/12 hệ thống con với asset gốc:
python scripts/agent/query_cross_project_mapping.py --verify
```

### Bước 4: Mở Dự Án Bằng Godot 4.6.2
1. Khởi động **Godot Engine 4.6.2 (.NET)**.
2. Chọn **Import** và trỏ đến tệp `Than_Tham_Nua_Voi_Godot/project.godot`.
3. Nhấn **Build** để biên dịch giải pháp .NET C#.

---

## 5. Tài Liệu Bàn Giao & Lộ Trình Phát Triển

Dành cho thành viên dự án và AI Agent tiếp quản:
- 📖 [Tài liệu Bàn giao Toàn diện Chặng 4 (HANDOFF.md)](HANDOFF.md): Đầy đủ ngữ cảnh, hướng dẫn cấu hình REA ngang hàng, khắc phục lỗi và quy trình thực hiện `TASK-0033`.
- 🗺️ [Kế hoạch Tổng thể Toàn bộ Các Chặng](docs/agent-system/plans/MASTER_EXECUTION_PLAN_ALL_STAGES.md): Bức tranh toàn cảnh từ Chặng 1 đến Chặng Extra.
- 📐 [Quy hoạch Kiến trúc Chặng 4 & Chặng Extra](docs/agent-system/plans/STAGE_4_AND_EXTRA_MASTER_BLUEPRINT.md): 5 Pillar giải quyết toàn bộ vấn đề của bản Godot cũ và thiết kế Mạng LAN.
- 📋 [Kế hoạch Triển khai Chi tiết Chặng 4](docs/agent-system/plans/STAGE_4_DETAILED_EXECUTION_PLAN.md): Lộ trình 14 Tasks thực thi Chặng 4.
- 🔍 [Đặc tả Đối chiếu Tính năng với Game Gốc (Chặng Extra)](docs/agent-system/plans/STAGE_EXTRA_FULL_PARITY_SPECIFICATION.md): Ma trận so sánh chi tiết tính năng tương đương với bản game gốc Steam.
