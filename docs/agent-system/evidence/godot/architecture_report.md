# Thần Thám Nửa Vời — Báo Cáo Kiến Trúc Đồ Thị Toàn Diện (Phase 1)

> **Generated at**: `2026-10-21`  
> **Target Project**: `Than_Tham_Nua_Voi_Godot/` (Godot 4.6.2 Stable, GL Compatibility)  
> **Source Evidence Artifacts**: `project_index.json`, `scene_graph.json`, `code_symbols.json`, `runtime_static_correlation.json`

---

## 1. Tổng Quan Đo Lường 3 Tầng Kiến Trúc

| Tầng Phân Tích | Chỉ Số Đo Lường | Giá Trị Thực Tế | Ghi Chú Kỹ Thuật |
| :--- | :--- | :--- | :--- |
| **Lớp A — Tài Nguyên & Mã Nguồn** | Tổng số tập tin | **1,735 files** | Quét toàn diện đĩa cứng |
| | Tập tin GDScript | **293 scripts** | 100% định kiểu tĩnh |
| | Tổng số dòng code GDScript | **81,442 LOC** | Non-empty lines |
| | Số lượng God-files ($\ge 1.000$ LOC) | **11 files** | Đối tượng tái cấu trúc Chặng 3–5 |
| **Lớp B — Đồ Thị Tĩnh (Static Graph)** | Tổng số Scene (`.tscn`) | **21 scenes** | 100% bóc tách AST text |
| | Tổng số Node tĩnh | **1,207 nodes** | Phân cấp Viewport, UI, Logic |
| | Kết nối Signal UI Tĩnh | **204 connections** | Bắt từ `connection` block trong `.tscn` |
| | Kết nối Signal Code Động | **201 connections** | Bắt từ `.connect()` trong GDScript |
| | Tổng số Hàm (Methods) | **4,145 methods** | Đã xử lý chữ ký đa dòng |
| **Lớp B+ — Runtime Scene Tree** | Node bắt tại `/root/` khi chạy | **20 nodes** | Chế độ Windowed GL (Guardrail 1) |
| | Autoload Singletons | **3 singletons** | `AppVersion`, `AppLogger`, `AppFlow` |
| | Độ tương quan Tĩnh / Động | **90.0%** | Khớp chính xác 15 node của `Boot.tscn` |

---

## 2. Bảng Xếp Hạng God-Files Cần Tái Cấu Trúc (Baseline Chặng 3–5)

| Đường Dẫn Script | Số Dòng (LOC) | Tầng Kiến Trúc |
| :--- | :--- | :--- |
| `scripts/tools/SmokeTestRunner.gd` | **15,302** | `tools` |
| `scripts/presentation/player_facing/PlayerFacingStartController.gd` | **5,106** | `presentation` |
| `scripts/presentation/player_facing/CharacterDetailSheet.gd` | **4,525** | `presentation` |
| `scripts/domain/loot/AuctionCatalog.gd` | **3,490** | `domain` |
| `scripts/presentation/loot/AuctionScreen.gd` | **2,919** | `presentation` |
| `scripts/presentation/case_gameplay/VSCaseMainController.gd` | **2,015** | `presentation` |
| `scripts/presentation/player_facing/PlayerFacingLootMapView.gd` | **1,519** | `presentation` |
| `scripts/domain/cases/CaseGeneratorPublicSolver.gd` | **1,268** | `domain` |
| `tests/unit/gd2/Gd2M0AProductionMapTestSuite.gd` | **1,065** | `other` |
| `scripts/application/mvp/MvpIntegratedNextCaseSession.gd` | **1,059** | `application` |
| `scripts/presentation/case_gameplay/SuspectCardController.gd` | **1,015** | `presentation` |

---

## 3. Khuyến Nghị Chuyển Tiếp Sang Chặng 3

1. **Điểm nghẽn số 1**: Giải quyết `CaseGenerator.gd` (thuật toán sinh vụ án duy nhất) trong Chặng 3.
2. **Bảo tồn tính chân thực**: Sử dụng `query_godot_graph.py` kết hợp `--format toon` để giảm token khi nạp đồ thị vào prompt AI.
