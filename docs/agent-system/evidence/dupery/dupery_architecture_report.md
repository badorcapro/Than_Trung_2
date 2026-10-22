# Dupery — Báo Cáo Kiến Trúc Toàn Diện Tầng A (Reverse Engineering Foundation)

> **Generated at**: `2026-10-21`  
> **Target Project**: *Dupery* (Unity 2022.3.62f3 Mono x86, Steam AppID 2860530)  
> **Reconstruction Target Engine**: Godot 4.6.2 Stable (GL Compatibility, Desktop 1920x1080)  
> **Scope**: Hoàn thành 100% Tầng A (TASK-0010 đến TASK-0021) — Sẵn sàng cho Tầng B

---

## 1. Bảng Chỉ Số Giải Phẫu Toàn Diện (Coverage Matrix)

| Phân hệ / Hạng mục | Chỉ số Trích xuất Hoàn tất | Độ toàn vẹn & Provenance |
| :--- | :--- | :--- |
| **Codebase C#** | **1,533 types** (Tier 1: 1,102, Tier 2: 431) | 100% CIL Tokens (1,532), **Unaccounted = 0** |
| **Scene Hierarchy Trees** | **12 scenes**, **5,279 GameObjects**, **7,365 MonoBehaviours** | 100% Decode, 11 Project Settings Managers |
| **Kho Vault Tài Nguyên** | **879 Sprites**, **10 Fonts**, **752 Textures** | Nine-Slice rect/pivot/ppu, 100% SHA-256 |
| **Vật Liệu & Hiệu Ứng** | **54 Materials**, **46 Shaders**, **2 VideoClips** | 13 Custom Shader Graphs, 0 Animations verified |
| **Âm Thanh FMOD** | **6 Banks**, **155 FSB5 Samples**, **50 Enums** mapped | 62 Master GUIDs, 2 Parameters, 2 Busses |
| **Tham Chiếu & Bán Động**| **9 Checklist Categories**, **2 Baseline Videos** | Quyết định **NO-GO**, **100% Deterministic Seed** |

---

## 2. Phân Bổ Sổ Cái Nghĩa Vụ Tái Thiết (Vòng Giải Phẫu V1–V8)

- **V1: Bàn Phá Án & Lưới Thẻ (Board & Grid)**: 95 types — Cấu trúc thẻ bài, snap grid, tọa độ bảng ghim.
- **V2: Khởi Tạo Vụ Án (Case Generation & Seed)**: 130 types — `System.Random` seed tất định 100%, vai trò nghi phạm.
- **V3: Vòng Lặp Trò Chơi (Core Game Loop)**: 94 types — Quản lý năng lượng, chuyển lượt, giải quyết vụ án.
- **V4: Bản Đồ Khu Vực & Kinh Tế (Region & Map)**: 101 types — Casino, Docks, Office, Syndicate, cược tiền.
- **V5: Manh Mối & Lời Khai (Leads & Evidence)**: 496 types — Hệ thống hỏi cung, xâu chuỗi bằng chứng.
- **V6: Nhận Diện Nghi Phạm (Lineup & Verdict)**: 99 types — `LineupController`, đối chất đặc điểm hình dạng.
- **V7: Cốt Truyện & Hội Thoại (Story & Narrative)**: 64 types — 18 Story Graphs, 1.908 Localisation keys.
- **V8: Tinh Chỉnh & Lưu Trữ (Metagame & Polish)**: 22 types — Save system, credits, 7 Easing curves.
- **Hạ Tầng Khung (Framework & Bridges)**: 431 types — FMODUnity bridge, GRGLib utilities, XNode engine.

---

## 3. Các Quyết Định Kiến Trúc Trọng Tâm (ADR & DEC)

1. **DEC-19 (Fresh Context Recipe)**: Truy vấn 1 lệnh qua `query_dupery_graph.py get-recipe` cung cấp đầy đủ đường dẫn source C#, scene hierarchy, ScriptableObjects, và âm thanh cho Agent ở Tầng B.
2. **DEC-20 (Anti-Omission Commitment)**: Toàn bộ 1.532 kiểu dữ liệu được lập chỉ mục và phân bổ với cam kết `unaccounted == 0` tuyệt đối.
3. **DEC-21 (2-Tier & 3-Depth Taxonomy)**: Phân tầng Tier 1 (1.101 cốt lõi) / Tier 2 (431 thư viện ngoài) cùng độ sâu L1–L3 định hướng tái lập chuẩn xác.
4. **DEC-22 (TypeTree Gate Success)**: Đạt 100% thành công trên 12 Scenes level (`level0`..`level11`) và 90.12% toàn dự án.
5. **DEC-23 (Behavioral Capture Protocol & Negative Findings)**: Xác nhận tựa game không chứa Animator/Particle, hoàn toàn sử dụng mã nguồn Tweening và Shader Graphs.
6. **DEC-24 (NO-GO for Process Injection)**: Tránh xâm phạm tiến trình bên ngoài, sử dụng mô hình hóa giải tích tất định 100% kết hợp Giao thức Golden Reference 60fps 1080p CFR.

---

## 4. Sẵn Sàng Chuyển Giao Sang Tầng B (Reconstruction Ready)

Tầng A đã hoàn thành trọn vẹn sứ mệnh giải phẫu và cung cấp nền tảng vững chắc. Toàn bộ tài nguyên, logic giải thuật và cấu trúc scene đã được chuẩn hóa SSOT, sẵn sàng cho công tác tái thiết Godot 4.6.2 trong Tầng B.
