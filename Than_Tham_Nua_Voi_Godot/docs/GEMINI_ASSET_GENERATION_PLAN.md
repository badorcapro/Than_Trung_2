# Kế Hoạch & Bộ Prompt Sinh Asset Biểu Tượng Vai Trò (Chuẩn Dupery)
## Dự án: Thần Thám Nửa Vời – Truyền Kì Kỳ Án Hoàng Cung

> **Định hướng phong cách tri ân Dupery:**
> - **100% Tối Giản (Minimalist 2D Flat Silhouette / Stencil Glyphs):** Biểu tượng hình bóng phẳng, đơn sắc, tương phản cao trên nền đen hoặc trong suốt.
> - **Tuyệt đối KHÔNG vẽ người / anime / mặt người:** Chỉ sử dụng hình bóng biểu trưng của đồ vật, huy hiệu, động vật hoặc ấn ký đặc trưng của vai trò.
> - **Khả năng đọc lướt (Instant Readability):** Đảm bảo người chơi nhìn lướt qua ở kích thước nhỏ (32×32, 48×48, 64×64) trên bàn cờ hoặc trong sổ tay là nhận ra ngay vai trò.
> - **Màu sắc nhận diện theo 4 Nhóm Vai Trò:**
>   - 🔵 **Người Vô Tội (Innocent):** Xanh Cyan / Lam sáng (`#5DADE2` hoặc `#A9DCFF`)
>   - 🟡 **Kẻ Bao Đồng (Meddler):** Vàng / Hổ phách (`#F5B041` hoặc `#F9E79F`)
>   - 🔴 **Thuộc Hạ (Underling):** Đỏ san hô / Đỏ thắm (`#E74C3C` hoặc `#F1948A`)
>   - 🟣 **Nghịch Thần (Traitor):** Tím quý tộc / Violet (`#A569BD` hoặc `#BB8FCE`)

---

## 🏛️ 1. Danh Sách 4 Asset Nhóm Đã Thêm (Group Banners)
Người dùng đã thêm 4 asset nền/banner nhóm tại `Than_Tham_Nua_Voi_Godot/assets/`:
1. `Innocent.png` — Banner đại diện nhóm Người Vô Tội (Màu xanh lam)
2. `Meddler.png` — Banner đại diện nhóm Kẻ Bao Đồng (Màu vàng hổ phách)
3. `Underling.png` — Banner đại diện nhóm Thuộc Hạ (Màu đỏ thắm)
4. `Traitor.png` — Banner đại diện nhóm Nghịch Thần (Màu tím)

---

## 📋 2. Bảng Rà Soát Toàn Bộ 21 Vai Trò Thực Tế Trong Game
*(Được trích xuất và xác thực 100% từ mã nguồn `FixtureRepository.gd` và màn hình `RoleCodexController.gd`)*

| STT | Tên Vai Trò (In-game) | Role ID | Nhóm (RoleGroup) | Phe (Alignment) | Ý Tưởng Biểu Tượng (Dupery Stencil Glyph) |
|:---:|:---|:---|:---|:---|:---|
| **I** | **NGƯỜI VÔ TỘI** | *(10 vai trò)* | **CHINH_NHAN** | **Phe Thiện** | **Màu Xanh Cyan (#5DADE2)** |
| 1 | **Thợ May** | `tailor` | Người Vô Tội | Phe Thiện | Cặp kéo may cắt chéo tối giản |
| 2 | **Dịch Phu** | `mailman` | Người Vô Tội | Phe Thiện | Bức thư niêm phong sáp / Ống thẻ truyền tin |
| 3 | **Nhà Toán Học** | `mathematician` | Người Vô Tội | Phe Thiện | Bàn tính cổ (Abacus) / Ký hiệu hình học |
| 4 | **Nhà Khí Tượng** | `weatherman` | Người Vô Tội | Phe Thiện | Chong chóng gió / Mũi tên la bàn chỉ 4 hướng |
| 5 | **Thợ Đồng Hồ** | `clock_maker` | Người Vô Tội | Phe Thiện | Mặt đồng hồ kim la mã / Quả lắc cơ khí |
| 6 | **Sử Quan** | `reporter` | Người Vô Tội | Phe Thiện | Cuộn thẻ tre mở ra / Cây bút lông vắt ngang |
| 7 | **Ngự Khuyển Quan** | `blood_hound` | Người Vô Tội | Phe Thiện | Hình bóng đầu chó săn silhouette nhìn nghiêng |
| 8 | **Ngự Y** | `therapist` | Người Vô Tội | Phe Thiện | Cối chày giã thuốc bắc / Nhánh thảo dược |
| 9 | **Sư Tử Phán** | `vigilante` | Người Vô Tội | Phe Thiện | Đầu sư tử đá gầm hoặc thanh kiếm công lý thẳng đứng |
| 10 | **Tư Tế** | `tutorial_priest` | Người Vô Tội | Phe Thiện | Lư hương tế đỉnh đồng bốc khói / Chuỗi ngọc châu |
| **II** | **KẺ BAO ĐỒNG** | *(3 vai trò)* | **HIEU_SU** | **Phe Thiện** | **Màu Vàng Gold (#F5B041)** |
| 11 | **Kẻ Bắt Chước** | `copycat` | Kẻ Bao Đồng | Phe Thiện | Hai chiếc mặt nạ hát tuồng lồng vào nhau / Chiếc gương phản chiếu |
| 12 | **Kẻ Say Rượu** | `drunkard` | Kẻ Bao Đồng | Phe Thiện | Bình rượu hồ lô nghiêng đổ giọt rượu |
| 13 | **Bác Sĩ Phẫu Thuật** | `surgeon` | Kẻ Bao Đồng | Phe Thiện | Dao mổ bạc phẫu thuật (Scalpel) sắc nhọn |
| **III** | **THUỘC HẠ** | *(7 vai trò)* | **TONG_PHAM** | **Phe Ác** | **Màu Đỏ Coral (#E74C3C)** |
| 14 | **Kẻ Lừa Đảo** | `conman` | Thuộc Hạ | Phe Ác | Bàn tay xòe 3 quân bài úp / Con xúc xắc nghiêng |
| 15 | **Độc Sư** | `poisoner` | Thuộc Hạ | Phe Ác | Bình độc dược có khói đầu lâu / Giọt nọc độc |
| 16 | **Chủ Quán Rượu** | `barkeep` | Thuộc Hạ | Phe Ác | Chiếc vại bia gỗ lớn sủi bọt tràn mép |
| 17 | **Sát Nhân Hàng Loạt** | `serial_killer` | Thuộc Hạ | Phe Ác | Dao găm cong vấy máu / Vết chém xước chéo |
| 18 | **Vong Linh** | `spectre` | Thuộc Hạ | Phe Ác | Bóng ma trôi bồng bềnh / Đôi mắt ma mị trong sương |
| 19 | **Kẻ Bất Lương** | `tutorial_scoundrel` | Thuộc Hạ | Phe Ác | Ổ khóa sắt có gai nhọn / Tấm khiên thép gai bảo vệ |
| 20 | **Kẻ Côn Đồ** | `tutorial_mobster` | Thuộc Hạ | Phe Ác | Nắm đấm sắt siết chặt (Brass knuckles/Fist silhouette) |
| **IV** | **NGHỊCH THÂN** | *(1 vai trò)* | **NGHICH_THAN** | **Phe Ác** | **Màu Tím Violet (#A569BD)** |
| 21 | **Nhà Phê Bình** | `critic` | Nghịch Thần | Phe Ác | Chiếc bút lông gạch chéo chữ X lớn / Cuộn tấu bị gạch bỏ |

---

## 🎨 3. Cấu Trúc Prompt Chuẩn Dupery Cho Gemini Web

Công thức prompt tối ưu:
> `A minimalist flat 2D vector stencil icon of [SUBJECT], solid [COLOR] color silhouette glyph on a pure black background. Dupery and board game token style, clean sharp edges, bold geometric shapes, high contrast, zero shading, zero gradients, no realistic textures, no human face or human body, centered composition, icon design, vector illustration.`

---

## 📝 4. Bộ Prompt Chi Tiết Cho Từng Vai Trò (Sẵn Sàng Copy/Paste)

### 🔵 Nhóm 1: Người Vô Tội (Innocent) — Màu Xanh Cyan

#### 1. Thợ May (`tailor`)
```text
A minimalist flat 2D vector stencil icon of a classic pair of tailor scissors opened at an angle, solid cyan blue (#5DADE2) silhouette glyph on a pure black background. Dupery and board game token style, clean sharp edges, bold shapes, high contrast, zero gradients, no human figures, centered, 2D vector icon.
```

#### 2. Dịch Phu (`mailman`)
```text
A minimalist flat 2D vector stencil icon of a vintage postal letter envelope with a wax seal emblem, solid cyan blue (#5DADE2) silhouette glyph on a pure black background. Dupery and board game token style, clean sharp edges, bold geometric lines, zero gradients, no human figures, centered, 2D vector icon.
```

#### 3. Nhà Toán Học (`mathematician`)
```text
A minimalist flat 2D vector stencil icon of an ancient abacus frame with counting beads, solid cyan blue (#5DADE2) silhouette glyph on a pure black background. Dupery and board game token style, clean sharp edges, bold geometric shapes, zero gradients, no human figures, centered, 2D vector icon.
```

#### 4. Nhà Khí Tượng (`weatherman`)
```text
A minimalist flat 2D vector stencil icon of a weather vane rooster pointing directions on a cross axis (N-E-S-W), solid cyan blue (#5DADE2) silhouette glyph on a pure black background. Dupery and board game token style, clean sharp edges, bold shapes, zero gradients, no human figures, centered, 2D vector icon.
```

#### 5. Thợ Đồng Hồ (`clock_maker`)
```text
A minimalist flat 2D vector stencil icon of an antique pocket watch face with Roman numerals and clockwork gear cog, solid cyan blue (#5DADE2) silhouette glyph on a pure black background. Dupery and board game token style, clean sharp edges, bold geometric shapes, zero gradients, no human figures, centered, 2D vector icon.
```

#### 6. Sử Quan (`reporter`)
```text
A minimalist flat 2D vector stencil icon of an unrolled ancient scroll parchment with a traditional calligraphy quill feather, solid cyan blue (#5DADE2) silhouette glyph on a pure black background. Dupery and board game token style, clean sharp edges, bold shapes, zero gradients, no human figures, centered, 2D vector icon.
```

#### 7. Ngự Khuyển Quan (`blood_hound`)
```text
A minimalist flat 2D vector stencil icon of an imperial hunting hound dog head silhouette in profile view, solid cyan blue (#5DADE2) silhouette glyph on a pure black background. Dupery and board game token style, bold graphic lines, clean sharp edges, zero gradients, no human figures, centered, 2D vector icon.
```

#### 8. Ngự Y (`therapist`)
```text
A minimalist flat 2D vector stencil icon of an apothecary mortar and pestle with herbal medicinal leaves, solid cyan blue (#5DADE2) silhouette glyph on a pure black background. Dupery and board game token style, clean sharp edges, bold geometric shapes, zero gradients, no human figures, centered, 2D vector icon.
```

#### 9. Sư Tử Phán (`vigilante`)
```text
A minimalist flat 2D vector stencil icon of a fierce stone guardian lion (shishi/foo dog) head silhouette, solid cyan blue (#5DADE2) silhouette glyph on a pure black background. Dupery and board game token style, bold heraldic emblem, clean sharp edges, zero gradients, no human figures, centered, 2D vector icon.
```

#### 10. Tư Tế (`tutorial_priest`)
```text
A minimalist flat 2D vector stencil icon of a sacred ceremonial temple incense burner cauldron with three legs and rising smoke curls, solid cyan blue (#5DADE2) silhouette glyph on a pure black background. Dupery and board game token style, clean sharp edges, bold shapes, zero gradients, no human figures, centered, 2D vector icon.
```

---

### 🟡 Nhóm 2: Kẻ Bao Đồng (Meddler) — Màu Vàng Hổ Phách

#### 11. Kẻ Bắt Chước (`copycat`)
```text
A minimalist flat 2D vector stencil icon of two overlapping theatrical comedy and tragedy drama masks silhouette, solid golden yellow (#F5B041) silhouette glyph on a pure black background. Dupery and board game token style, clean sharp edges, bold shapes, zero gradients, no human figures, centered, 2D vector icon.
```

#### 12. Kẻ Say Rượu (`drunkard`)
```text
A minimalist flat 2D vector stencil icon of a tilted oriental gourd wine flask (calabash bottle) spilling liquid droplets, solid golden yellow (#F5B041) silhouette glyph on a pure black background. Dupery and board game token style, clean sharp edges, bold shapes, zero gradients, no human figures, centered, 2D vector icon.
```

#### 13. Bác Sĩ Phẫu Thuật (`surgeon`)
```text
A minimalist flat 2D vector stencil icon of a sharp medical surgical scalpel blade pointing downwards, solid golden yellow (#F5B041) silhouette glyph on a pure black background. Dupery and board game token style, clean sharp edges, bold geometric lines, zero gradients, no human figures, centered, 2D vector icon.
```

---

### 🔴 Nhóm 3: Thuộc Hạ (Underling) — Màu Đỏ San Hô

#### 14. Kẻ Lừa Đảo (`conman`)
```text
A minimalist flat 2D vector stencil icon of a fanned set of three playing cards with an eye emblem on the center card, solid coral red (#E74C3C) silhouette glyph on a pure black background. Dupery and board game token style, clean sharp edges, bold graphic shapes, zero gradients, no human figures, centered, 2D vector icon.
```

#### 15. Độc Sư (`poisoner`)
```text
A minimalist flat 2D vector stencil icon of a poison potion flask bottle with a skull silhouette insignia and falling drop, solid coral red (#E74C3C) silhouette glyph on a pure black background. Dupery and board game token style, clean sharp edges, bold shapes, zero gradients, no human figures, centered, 2D vector icon.
```

#### 16. Chủ Quán Rượu (`barkeep`)
```text
A minimalist flat 2D vector stencil icon of a wooden tavern beer mug stein with thick overflowing foam head, solid coral red (#E74C3C) silhouette glyph on a pure black background. Dupery and board game token style, clean sharp edges, bold shapes, zero gradients, no human figures, centered, 2D vector icon.
```

#### 17. Sát Nhân Hàng Loạt (`serial_killer`)
```text
A minimalist flat 2D vector stencil icon of a menacing curved assassin dagger silhouette crossing three sharp slash marks, solid coral red (#E74C3C) silhouette glyph on a pure black background. Dupery and board game token style, clean sharp edges, bold graphic lines, zero gradients, no human figures, centered, 2D vector icon.
```

#### 18. Vong Linh (`spectre`)
```text
A minimalist flat 2D vector stencil icon of a floating spooky ghostly phantom silhouette with glowing hollow eye holes, solid coral red (#E74C3C) silhouette glyph on a pure black background. Dupery and board game token style, clean sharp edges, bold shapes, zero gradients, no human figures, centered, 2D vector icon.
```

#### 19. Kẻ Bất Lương (`tutorial_scoundrel`)
```text
A minimalist flat 2D vector stencil icon of a fortified padlock surrounded by sharp barbed iron spikes, solid coral red (#E74C3C) silhouette glyph on a pure black background. Dupery and board game token style, clean sharp edges, bold geometric shapes, zero gradients, no human figures, centered, 2D vector icon.
```

#### 20. Kẻ Côn Đồ (`tutorial_mobster`)
```text
A minimalist flat 2D vector stencil icon of a clenched spiked brass knuckle silhouette, solid coral red (#E74C3C) silhouette glyph on a pure black background. Dupery and board game token style, clean sharp edges, bold heavy geometric shapes, zero gradients, no human figures, centered, 2D vector icon.
```

---

### 🟣 Nhóm 4: Nghịch Thần (Traitor) — Màu Tím Violet

#### 21. Nhà Phê Bình (`critic`)
```text
A minimalist flat 2D vector stencil icon of a large bold X cross mark intersecting an imperial calligraphy brush, solid violet purple (#A569BD) silhouette glyph on a pure black background. Dupery and board game token style, clean sharp edges, bold graphical cross, zero gradients, no human figures, centered, 2D vector icon.
```

---

## 💡 Hướng Dẫn Sử Dụng
1. Copy từng prompt ở trên vào ô nhập lệnh của **Gemini Web / Imagen 3**.
2. Kết quả trả về sẽ là hình bóng vector đơn sắc 2D trên nền đen, cực kỳ sạch sẽ và dễ nhìn.
3. Khi đưa vào Godot, hệ thống có thể dùng shader cắt nền đen hoặc để làm texture icon trên thẻ bài / sổ vai trò.
