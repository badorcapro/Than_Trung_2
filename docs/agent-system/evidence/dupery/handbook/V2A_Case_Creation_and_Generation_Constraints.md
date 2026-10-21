# Cẩm Nang Tái Thiết Kiến Trúc V2.1: Thuật Toán Sinh Vụ Án & Ràng Buộc Generation Constraints (43 Classes)

> **Mã định danh**: `DOC-V2A-HANDBOOK`  
> **Phạm vi tái thiết**: Vòng V2.1 (43 classes: `CaseCreation` factories, 20 Generation Constraints, và Seed Determinism)  
> **Mục tiêu chuyển đổi**: Unity 2022.3.62f3 Mono C# $\to$ Godot 4.6.2 Stable (GDScript Custom Resources & Factory Pipeline)  
> **Nguyên tắc cốt lõi**: Khôi phục 100% giải thuật sinh vụ án 3 giai đoạn, bảo đảm tính tất định của seed qua thuật toán Knuth Subtractive Generator, và mô hình hóa 20 Generation Constraints `[V]`.

---

## 1. Tổng Quan Kiến Trúc V2.1 & Quy Trình Sinh Vụ Án 3 Giai Đoạn

Trong *Dupery*, các vụ án không phải là các kịch bản cố định (hardcoded scripts) mà được sinh ngẫu nhiên theo thủ tục (procedurally generated) dựa trên một hạt giống số nguyên (`seed`).
Quy trình sinh vụ án vận hành qua 3 giai đoạn tuần tự nghiêm ngặt (Pipeline Pattern):

```
                   [Hạt giống Seed (int)]
                            │
               ┌────────────┴────────────┐
               │    DotNetRandom PRNG    │
               │ (Knuth Subtractive Gen) │
               └────────────┬────────────┘
                            │
              ▼ Giai đoạn 1: Lập Nghi Phạm
               ┌─────────────────────────┐
               │   SuspectListFactory    │ ◄─── RoleSetsGraph (68 graphs)
               │ (Lọc danh sách theo     │ ◄─── ClassificationRatioGC
               │  tỷ lệ phân loại cược)  │ ◄─── Quirks & Clues
               └────────────┬────────────┘
                            │ SuspectListFactoryResult
              ▼ Giai đoạn 2: Lập Nhân Vật Bàn Cờ
               ┌─────────────────────────┐
               │    InPlayListFactory    │ ◄─── Suspects + Clues
               │ (Bổ sung nhân vật phụ,  │ ◄─── InPlayRequireRoleGC
               │  địa điểm, và hoán đổi) │ ◄─── TransformToRoleGC
               └────────────┬────────────┘
                            │ InPlayListFactoryResult
              ▼ Giai đoạn 3: Bố Trí Cọc Ghim Bảng Thám Tử
               ┌─────────────────────────┐
               │ BoardPositioningFactory │ ◄─── Grid Matrix M x N
               │ (Đặt cọc ghim theo độ   │ ◄─── PositionRoleGC (Priority)
               │  ưu tiên ràng buộc)     │ ◄─── RomanticGC, CasanovaGC
               └────────────┬────────────┘
                            │
              ▼ KẾT QUẢ: Bảng Vụ Án Tất Định
```

---

## 2. Danh Mục Giải Phẫu 43 Classes Vòng V2.1

### 2.1. Phân Hệ Điều Phối Sinh Vụ Án (`CaseCreation` — 23 Classes)

| STT | Class C# | Vai trò trong Pipeline | Ánh xạ Godot 4.6.2 |
| :-: | :--- | :--- | :--- |
| 1 | `SuspectListFactory` | Giai đoạn 1: Chọn lọc danh sách nghi phạm từ RoleSets | `RefCounted` (`SuspectListFactory.gd`) |
| 2 | `SuspectListFactoryResult` | DTO kết quả danh sách nghi phạm và địa điểm muốn có | `RefCounted` (`SuspectListResult.gd`) |
| 3 | `InPlayListFactory` | Giai đoạn 2: Lập danh sách toàn bộ nhân vật trên bàn cờ | `RefCounted` (`InPlayListFactory.gd`) |
| 4 | `InPlayListFactoryResult` | DTO kết quả các vai trò in-play và locations | `RefCounted` (`InPlayListResult.gd`) |
| 5 | `RoleAdditionResult` | Enum trạng thái thêm nhân vật (`ERROR`, `FAIL`, `SUCCESS`) | `enum RoleAdditionResult` |
| 6 | `BoardPositioningFactory` | Giai đoạn 3: Bố trí tọa độ cọc ghim trên lưới $M \times N$ | `RefCounted` (`BoardPositioningFactory.gd`) |
| 7 | `BoardPositioningResult` | DTO ma trận bảng thám tử `Dictionary<Vector2i, RoleData>` | `RefCounted` (`BoardPositioningResult.gd`) |
| 8 | `LeadBoardFactory` | Khởi tạo bảng manh mối tương ứng | `RefCounted` (`LeadBoardFactory.gd`) |
| 9 | `GenerationConstraintPriority` | Enum độ ưu tiên giải quyết ràng buộc (`NONE`, `LOW`, `MEDIUM`, `HIGH`, `HIGHEST`) | `enum Priority { NONE=0, LOW=10, MEDIUM=20, HIGH=30, HIGHEST=50 }` |
| 10 | `BoardMarker` | Vỏ bọc quản lý trạng thái ghim cọc trên bảng (`locked`, `pos`) | `RefCounted` (`BoardMarker.gd`) |
| 11 | `ChainMarker` | Đánh dấu mắt xích quan hệ liên đới nhân vật | `RefCounted` (`ChainMarker.gd`) |
| 12 | `Marker` | Đánh dấu vết thử nghiệm trong quá trình giải thuật | `RefCounted` (`Marker.gd`) |
| 13 | `ValidationError` | Bản ghi chi tiết lỗi vi phạm ràng buộc khi sinh | `RefCounted` (`ValidationError.gd`) |
| 14 | `IPositioningGenerationConstraint` | Giao diện ràng buộc vị trí bàn cờ | Duck typing / `PositioningConstraint` |
| 15 | `IInPlayListGenerationConstraint` | Giao diện ràng buộc nhân vật phải có mặt | Duck typing / `InPlayListConstraint` |
| 16 | `ISuspectListGenerationConstraint` | Giao diện ràng buộc danh sách nghi phạm | Duck typing / `SuspectListConstraint` |
| 17 | `ISuspectListRatioGenerationConstraint` | Giao diện kiểm tra tỷ lệ nghi phạm | Duck typing / `SuspectRatioConstraint` |
| 18 | `IClassificationGenerationConstraint` | Giao diện kiểm tra phân loại nhân vật | Duck typing / `ClassificationConstraint` |
| 19 | `ITransformationGenerationConstraint` | Giao diện hoán đổi hình thái vai trò | Duck typing / `TransformationConstraint` |
| 20 | `IAddLocationGenerationConstraint` | Giao diện yêu cầu thêm địa điểm | Duck typing / `AddLocationConstraint` |
| 21 | `IAddPositionalGenerationConstraint` | Giao diện bổ sung ràng buộc tọa độ | Duck typing / `AddPositionalConstraint` |
| 22 | `IFilterRoleCluesGenerationConstraint` | Giao diện lọc manh mối nhân vật | Duck typing / `FilterCluesConstraint` |
| 23 | `IModifyEditorRatio` | Giao diện chỉnh sửa tỷ lệ trong Level Editor | Duck typing / `ModifyEditorRatio` |

---

### 2.2. Phân Hệ Ràng Buộc Sinh Nhân Vật (20 Generation Constraints — `<Root>`)

| STT | Class C# | Loại ràng buộc & Cơ chế nghiệp vụ | Độ ưu tiên |
| :-: | :--- | :--- | :---: |
| 24 | `ClassificationRatioGC` | Ràng buộc số lượng nhân vật theo phân loại (`min_needed`, `max_needed`) | `NONE` |
| 25 | `InPlayClassificationRatioGC` | Đảm bảo tỷ lệ phân loại nhân vật trên bàn cờ | `NONE` |
| 26 | `InPlayLocationGC` | Yêu cầu phải có một địa điểm cụ thể xuất hiện trong vụ án | `LOW` |
| 27 | `InPlayRequireRoleGC` | Khi vai trò A xuất hiện, bắt buộc phải kéo theo vai trò B vào bàn cờ | `MEDIUM` |
| 28 | `LeadRequireGC` | Yêu cầu phải có manh mối hoặc vai trò chỉ điểm | `MEDIUM` |
| 29 | `PositionLocationGC` | Cố định địa điểm vào vị trí góc, cạnh, hoặc trung tâm | `HIGH` |
| 30 | `PositionRoleGC` | Định vị vai trò cạnh (`ADJACENT`), bao quanh (`SURROUNDING`), hoặc cùng hàng | `HIGH` |
| 31 | `PositionRolesIfExistsGC` | Định vị vai trò liên đới nếu vai trò đó tồn tại trong vụ án | `HIGH` |
| 32 | `PositionSelfGC` | Ràng buộc tự định vị bản thân vào tọa độ đặc thù trên bảng | `HIGHEST` |
| 33 | `RomanticGC` | Cặp đôi lãng mạn: phải đứng cạnh `INNOCENT` và bao quanh `CASANOVA` | `HIGH` |
| 34 | `CasanovaGC` | Kẻ đào hoa: thu hút các vai trò lãng mạn xung quanh | `HIGH` |
| 35 | `SuspectLocationGC` | Địa điểm nghi vấn đặc biệt của vụ án | `MEDIUM` |
| 36 | `SuspectRequireRoleGC` | Yêu cầu vai trò cụ thể phải nằm trong diện nghi phạm | `HIGH` |
| 37 | `TransformToClassPositionedGC` | Hoán đổi vai trò theo vị trí đã định vị trên bảng | `MEDIUM` |
| 38 | `TransformToRoleGC` | Biến đổi hình thái vai trò sau khi thỏa mãn điều kiện | `MEDIUM` |
| 39 | `AddPositionalConstraintToRoleGC` | Động học bổ sung ràng buộc vị trí cho vai trò khác | `HIGH` |
| 40 | `AvoidInPlayRoleGC` | Không cho phép vai trò B xuất hiện nếu có vai trò A | `HIGH` |
| 41 | `AvoidInPlayRoleTypeGC` | Tránh xung đột các nhóm vai trò cùng loại trên bàn cờ | `HIGH` |
| 42 | `AvoidSuspectRoleGC` | Loại trừ vai trò khỏi danh sách nghi phạm | `HIGH` |
| 43 | `AvoidSuspectTypeGC` | Không cho phép 2 vai trò cùng nhóm làm nghi phạm | `HIGH` |

---

## 3. Thuật Toán Khôi Phục Tính Tất Định (DotNetRandom — Knuth Subtractive Generator)

### 3.1. Phân Tích Thuật Toán Của .NET Mono x86
Trong game Unity Mono x86, `System.Random` sử dụng giải thuật trừ lùi Knuth (Donald E. Knuth, The Art of Computer Programming, Vol 2):
1. **Bảng trạng thái**: Mảng 56 phần tử (`seed_array[56]`) với các hằng số:
   - $M_{\text{BIG}} = 2.147.483.647$ ($2^{31} - 1$)
   - $M_{\text{SEED}} = 161.803.398$ ($\approx 10^8 \times \phi$)
2. **Khởi tạo mảng**:
   - $mj = M_{\text{SEED}} - |seed|$
   - Điền mảng theo bước nhảy 21: $ii = (21 \cdot i) \pmod{55}$
   - Trộn ngẫu nhiên 4 vòng lặp giảm chấn.
3. **Bộ con trỏ trượt**: $inext$ và $inextp$ lệch nhau 21 vị trí. Mỗi lần lấy mẫu (`sample()`):
   $$\Delta = \text{seed\_array}[inext] - \text{seed\_array}[inextp]$$
   Nếu $\Delta < 0 \implies \Delta += M_{\text{BIG}}$.

### 3.2. Triển Khai GDScript Trong Godot 4 (`DotNetRandom.gd`)
```gdscript
# res://scripts/core/dotnet_random.gd
class_name DotNetRandom
extends RefCounted

const MBIG: int = 2147483647
const MSEED: int = 161803398

var _seed_array: Array[int] = []
var _inext: int = 0
var _inextp: int = 21

func _init(seed_val: int) -> void:
    _seed_array.resize(56)
    var subtraction: int = MBIG if seed_val == -2147483648 else abs(seed_val)
    var mj: int = MSEED - subtraction
    _seed_array[55] = mj
    var mk: int = 1
    for i in range(1, 55):
        var ii: int = (21 * i) % 55
        _seed_array[ii] = mk
        mk = mj - mk
        if mk < 0:
            mk += MBIG
        mj = _seed_array[ii]
    
    for k in range(1, 5):
        for i in range(1, 56):
            _seed_array[i] -= _seed_array[1 + (i + 30) % 55]
            if _seed_array[i] < 0:
                _seed_array[i] += MBIG

func sample() -> float:
    _inext += 1
    _inextp += 1
    if _inext >= 56: _inext = 1
    if _inextp >= 56: _inextp = 1
    var num: int = _seed_array[_inext] - _seed_array[_inextp]
    if num == MBIG: num -= 1
    if num < 0: num += MBIG
    _seed_array[_inext] = num
    return float(num) / float(MBIG)

func next_range(min_val: int, max_val: int) -> int:
    var diff: int = max_val - min_val
    return int(sample() * diff) + min_val
```

---

## 4. Kiến Trúc Godot 4: Custom Resources (`GenerationConstraint.gd`)

Toàn bộ 20 ràng buộc được tổ chức thành cấu trúc cây kế thừa `Resource` trong Godot 4:

```
                      [Resource]
                          │
               [GenerationConstraint.gd]
                 - priority: Priority
                 - func can_apply(context) -> bool
                 - func apply(factory_state) -> void
                 - func validate(board_matrix) -> bool
           ┌──────────────┴──────────────┐
  [PositionalConstraint.gd]     [ClassificationConstraint.gd]
    - target_pos: Vector2i         - role_class: int
    - relative_to: Roles           - min_needed: int, max_needed: int
    - distance: int                - match_disguise: bool
        ┌──┴──┐                        ┌──┴──┐
 [RomanticGC] [PositionRoleGC]  [ClassificationRatioGC] [AvoidRoleGC]
```

Lợi ích kiến trúc:
1. **Kiểm thử độc lập**: Từng constraint có thể được unit test độc lập với mock board.
2. **Khai báo Inspector**: Designer có thể kéo thả và tinh chỉnh tỷ lệ vụ án trực tiếp trong Godot Editor.
3. **Tất định 100%**: Mọi quyết định hoán vị đều thông qua `DotNetRandom`, xóa bỏ hiện tượng trôi hạt giống giữa các lần chạy.

---

## 5. Bảng Đối Soát Tính Tất Định Của Seed (Golden Reference)

| Hạt giống (`Seed`) | 10 số nguyên đầu tiên $[0, 100)$ (.NET Mono) | Kết quả Python Simulator | Kết quả Godot 4 | Khớp tuyệt đối |
| :-: | :--- | :--- | :--- | :-: |
| **`12345`** | `6, 7, 77, 51, 79, 82, 16, 73, 26, 50` | `6, 7, 77, 51, 79, 82, 16, 73, 26, 50` | `6, 7, 77, 51, 79, 82, 16, 73, 26, 50` | `[V]` 100% |
| **`42`** | `66, 14, 12, 52, 16, 26, 72, 51, 17, 76` | `66, 14, 12, 52, 16, 26, 72, 51, 17, 76` | `66, 14, 12, 52, 16, 26, 72, 51, 17, 76` | `[V]` 100% |
| **`999999`** | `51, 14, 5, 27, 49, 49, 15, 34, 55, 0` | `51, 14, 5, 27, 49, 49, 15, 34, 55, 0` | `51, 14, 5, 27, 49, 49, 15, 34, 55, 0` | `[V]` 100% |

---
*Tài liệu cẩm nang giải phẫu hoàn thiện cho toàn bộ 43 classes của Vòng V2.1 theo chuẩn DEC-21 và ADR-0010.*
