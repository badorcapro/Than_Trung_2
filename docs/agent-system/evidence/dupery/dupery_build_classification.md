# Dupery Target Build Classification & Architectural Anatomy

> **Reference ID**: `EVID-DUPERY-BUILD-001`  
> **Status**: `current`  
> **Date**: `2026-10-20`  
> **Target Path**: `D:/Minh/Steam/steamapps/common/Dupery`  
> **Authority**: `DEC-09` (Non-commercial fan-game learning and architectural cross-graph reference)

---

## 1. Thông Tin Nhận Diện Mục Tiêu (Target Identity)

* **Tên trò chơi đối chiếu:** *Dupery* (Commercial Steam release)
* **Vị trí cài đặt cục bộ:** `D:/Minh/Steam/steamapps/common/Dupery`
* **Quy chế pháp lý & đạo đức (`DEC-09`):** Toàn quyền trích xuất, đọc mã bytecode CIL/Mono, phân tích `ScriptableObject`, cấu trúc đồ thị `XNode`, bảng ngôn ngữ `GRGLocalisation`, âm thanh FMOD và layout UI Nine-Slice phục vụ mục đích nghiên cứu kiến trúc nội bộ, không tái phát hành nguyên mẫu thương mại.

---

## 2. Thông Số Kỹ Thuật Engine & Nền Tảng (Engine & Platform)

* **Game Engine:** Unity **2021.3.11f1**
* **Kiến trúc nhị phân (Binary Architecture):** Windows PE32 (`x86` / machine `0x014c`), 32-bit executable.
* **Scripting Backend:** **Mono** (ECMA CLI Runtime v2.5, `il-only` flag, không sử dụng IL2CPP obfuscation).
* **Metadata Status:** PE Optional Header `pe32`, Metadata RVA `733884`, Size `1189652` bytes.

---

## 3. Bản Đồ Phân Bổ Nhị Phân & Mã Nguồn (Binary & Assembly Layout)

1. **Điểm nhập thực thi (Executable Entry):**
   * `Dupery.exe` (650,240 bytes, SHA256: `c3431334a4a8a344da65b2a81527d9cdfaec68cfc75c9b4dc99070a6f1a30505`)
   * `UnityPlayer.dll` (23,147,952 bytes)
2. **Hội tụ Logic Trò chơi Chính (Primary Gameplay Assembly):**
   * `Dupery_Data/Managed/Assembly-CSharp.dll` (1,999,360 bytes, SHA256: `14f9b85b27de66535b5baa13e845fd4df0983cee014f24af2f607cac0e3c037b`).
   * Chứa toàn bộ các module gameplay: `Lineup.*`, `CaseCreation.*`, `Loot.*`, `Cards.*`, `Suspects.*`.
3. **Thư viện Phụ trợ Đặc trưng (Domain Frameworks):**
   * `XNode.dll`: Khung tạo và duyệt đồ thị dữ liệu logic / nhiệm vụ theo dạng Node.
   * `FMODUnity.dll`: Adapter điều khiển âm thanh tương tác đa kênh FMOD.
   * Tổng số Assembly quản lý: **126 DLLs**.

---

## 4. Cấu Trúc Tài Nguyên & Âm Thanh (Assets & Audio Topology)

* **Kho lưu trữ Asset:** Tổng cộng **28 tập tin** trong `Dupery_Data/`.
  * `resources.assets`: 118.5 MB (Chứa hầu hết các ScriptableObjects, Prefabs, Sprites, Texture UI).
  * `sharedassets0.assets` đến `sharedassets11.assets`: Tài nguyên phân mảnh theo Scene.
  * `globalgamemanagers`, `data.unity3d`: Cấu hình toàn cục Unity.
* **Hệ thống Âm thanh Tương tác (FMOD Soundbanks):**
  * Thư mục `Dupery_Data/StreamingAssets/` gồm **6 tập tin `.bank`**:
    * `Master.bank` & `Master.strings.bank`
    * `Music.bank`
    * `Sfx.bank`
    * `Atmosphere.bank`
    * `Intro.bank`

---

## 5. Kết Quả Kiểm Chứng Thực Địa: Probe 1 (`Lineup.LineupController`)

* **Công cụ thực thi:** REA Managed Static Provider (`inspect_managed_members`) sau khi áp dụng bản vá `PATCH-REA-WIN-ESTALE-001`.
* **Đối tượng kiểm tra:** `Lineup.LineupController` trong `Assembly-CSharp.dll`.
* **Kết quả:** Trích xuất thành công **24 trường dữ liệu (fields)** và **20 hàm nghiệp vụ (methods)** bao gồm:
  * Khởi tạo & Cấu hình: `Awake`, `Start`, `createAndConfigureSuspect`.
  * Điều phối nghi phạm: `nextSuspect`, `moveToSuspect`, `moveToSuspectIntro`, `fadeCharacter`.
  * Hoạt cảnh & Hiệu ứng UI: `jiggleClipboard`, `moveShadow`, `gunMove`.
  * Phán xử & Kết tội: `onBlame`, `getConvictString`.
  * Địa phương hóa (Localisation): `englishTitle`, `englishCliboard`, `englishConvict`, `get_loc_clipboard_key`, `get_localisation_asset`.
* **Biên nhận chi tiết:** Lưu trữ tại [`docs/agent-system/evidence/dupery/probes/probe1_lineup_controller.json`](probes/probe1_lineup_controller.json).
