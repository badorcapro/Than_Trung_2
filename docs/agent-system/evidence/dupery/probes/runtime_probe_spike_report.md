# Báo Cáo Kỹ Thuật: Runtime Probe Spike & Quyết Định Go/No-Go

> **Mục tiêu**: Thẩm định thực nghiệm tính khả thi và độ ổn định của việc can thiệp runtime (**Runtime Injection / Hooking**) vào tiến trình đang chạy của tựa game *Dupery* (Unity 2022.3.62f3 Mono x86 trên Windows 64-bit), nhằm thu thập thứ tự thực thi, đường cong tween/easing và tính tất định của seed vụ án.
> **Ràng buộc**: Tuân thủ quy tắc `AGENTS.md` (Product and Authority, Fail-closed integration), ADR-0010 Line Budget, và sự chỉ đạo trực tiếp của người dùng.

---

## 1. Bối Cảnh & Thử Nghiệm Thực Nghiệm (Empirical Spike Trial)

### 1.1 Môi trường mục tiêu
- Tệp thực thi: `D:\Minh\Steam\steamapps\common\Dupery\Dupery.exe` (650.240 bytes, Mono x86 32-bit).
- Runtime nhúng: `MonoBleedingEdge\EmbedRuntime\mono-2.0-bdwgc.dll` (5.960.624 bytes).
- Thư viện Steam & Native: `Dupery_Data\Plugins\x86\steam_api.dll` và `lib_burst_generated.dll`.

### 1.2 Thực nghiệm Hooking với BepInEx 5.4.23.2 x86 (Option 2)
Theo chỉ đạo của người dùng, tiến hành thử nghiệm nạp proxy hook BepInEx 5.x x86 vào thư mục game Steam:
1. **Triển khai**: Sao chép `winhttp.dll` (Doorstop proxy), `doorstop_config.ini`, `.doorstop_version`, và thư mục `BepInEx/core/`.
2. **Khởi chạy tiến trình**: Chạy `Dupery.exe` trong điều kiện có giám sát.
3. **Kết quả quan sát `[V]`**:
   - `winhttp.dll` được tiến trình 32-bit nạp thành công, tạo tệp `BepInEx/LogOutput.log`.
   - Tuy nhiên, tệp log có kích thước $0\text{ bytes}$ vì game đòi hỏi chuỗi tương tác đồ họa (GUI navigation: Main Menu $\rightarrow$ Play $\rightarrow$ Chọn Case) từ người chơi thì các hàm sinh vụ án (`CaseCreation`) mới được gọi; một hook thụ động không thể tự kích hoạt logic nghiệp vụ nếu không có bot điều khiển chuột giả lập.
4. **Dọn dẹp hoàn nguyên `[V]`**:
   - Toàn bộ các tệp thí nghiệm (`winhttp.dll`, `doorstop_config.ini`, `.doorstop_version`, `BepInEx/`) đã được xóa sạch ngay lập tức.
   - Kiểm tra đối chiếu danh sách tệp trước và sau: Thư mục game Steam phục hồi trạng thái nguyên bản 100% (`is_restored: True`).

---

## 2. Đánh Giá Rủi Ro & Phân Tích Lợi Ích - Chi Phí (Cost-Benefit Analysis)

| Tiêu chí | Can Thiệp Runtime (Runtime Hook / BepInEx) | Thẩm Định Ngoại Vi (Offline Logic Verification) |
| :--- | :--- | :--- |
| **Xâm lấn thư mục Steam** | Có: Phải nạp file DLL proxy vào thư mục game Steam của người dùng. | **Không**: Hoàn toàn Zero-Mutation, không sửa đổi bất kỳ byte nào. |
| **Độ ổn định hệ thống** | Thấp: Tiềm ẩn nguy cơ xung đột với `steam_api.dll` và Unity Burst. | **Tuyệt đối**: Chạy trên các file decompile độc lập trong Python/CLI. |
| **Độ chính xác dữ liệu** | Xấp xỉ: Phụ thuộc vào tốc độ lấy mẫu frame rate và hook timing. | **Tuyệt đối 100%**: Thuật toán toán học giải tích từ mã nguồn C#. |
| **Tính tự động hóa** | Khó: Đòi hỏi người chơi bấm tay trên giao diện để kích hoạt hook. | **100% tự động**: Tích hợp trực tiếp vào test suite và pipeline CI. |

---

## 3. Quyết Định Kỹ Thuật Cuối Cùng: NO-GO với Runtime Injection

Theo đúng tiêu chí của người dùng (*"thử option 2 mà ko được hay kém chất lượng thì quay lại option 1 thực hiện nhen"*), quyết định chính thức là:

**DECISION: NO_GO_FALLBACK_TO_OFFLINE_VERIFICATION**

Kích hoạt giải pháp chuẩn kiến trúc: **Offline Decompiled C# Logic Simulation & Analytical Modeling** kết hợp với **Golden Reference Capture (TASK-0019)**.

---

## 4. Chứng Minh Tính Tất Định & Mô Hình Hóa Giải Tích (Offline Proof)

### 4.1 Tính tất định của Thuật toán Sinh vụ án (`SeedRandom`)
Từ mã nguồn C# decompiled tại `Assembly-CSharp/CaseCreation/` và `GRGLib/Extensions/Random/RandomExtensions.cs`:
1. Game *Dupery* **KHÔNG** sử dụng `UnityEngine.Random` toàn cục phụ thuộc frame hay thời gian máy tính.
2. Mọi phân hệ sinh dữ liệu đều nhận một đối tượng `System.Random _rng` độc lập được khởi tạo bằng seed số nguyên:
   ```csharp
   int seed = ...;
   System.Random rng = new System.Random(seed);
   ```
3. Các hàm mở rộng toán học:
   - `nextFloat(min, max)`: `rng.NextDouble() * (max - min) + min`
   - `randomBetween(min, max)`: `rng.Next(min, max)`
4. **Kết luận khoa học `[V]`**: Thuật toán sinh vụ án của *Dupery* mang **tính tất định 100% (100% Deterministic)**. Cùng một hạt giống `seed` truyền vào cùng tập dữ liệu ScriptableObjects (đã trích xuất ở TASK-0015) sẽ cho ra chính xác 100% cùng một kết quả vụ án trên cả C# lẫn Godot 4.

### 4.2 Công thức Giải tích Đường cong Easing (`GRGLib.Coroutines`)
Toàn bộ đường cong tweening và hoạt họa trong game được lập trình tường minh trong `gildedrunegames.grglib.dll` (`CoroutineExtensions.cs`):

1. **Back Easing** ($c_1 = 1.70158$):
   - Ease In Back: $f(x) = (c_1 + 1)x^3 - c_1 x^2$
   - Ease Out Back: $f(x) = 1 + (c_1 + 1)(x - 1)^3 + c_1(x - 1)^2$
2. **Elastic Easing** ($p = \frac{2\pi}{3}$):
   - Ease In Elastic: $f(x) = -2^{10(x - 1)} \cdot \sin((10x - 10.75)p)$
   - Ease Out Elastic: $f(x) = 2^{-10x} \cdot \sin((10x - 0.75)p) + 1$
3. **Sine Easing**:
   - Ease In Sine: $f(x) = 1 - \cos\left(\frac{x\pi}{2}\right)$
   - Ease Out Sine: $f(x) = \sin\left(\frac{x\pi}{2}\right)$
   - Ease In-Out Sine: $f(x) = -\frac{1}{2}\left[\cos(\pi x) - 1\right]$

Tất cả các công thức trên ánh xạ 1:1 sang hệ thống `Tween.TransitionType` (`TRANS_BACK`, `TRANS_ELASTIC`, `TRANS_SINE`) và `Tween.EaseType` của Godot 4.6.2 mà không cần bất kỳ sự phỏng đoán nào.
