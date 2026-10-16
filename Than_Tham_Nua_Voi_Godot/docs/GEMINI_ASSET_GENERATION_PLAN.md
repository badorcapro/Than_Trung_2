# Kế Hoạch & Bộ Prompt Sinh Asset Cho Gemini Web (Google Imagen 3)
## Dự án: Thần Thám Nửa Vời – Truyền Kì Kỳ Án Hoàng Cung

> **Cam kết cốt lõi:** 100% các asset trong tài liệu này là **Đạo Cụ / Cổ Vật / Biểu Tượng / Phù Ấn Độc Lập (Freestanding Props & Emblems)**, hoàn toàn **KHÔNG CÓ HÌNH NGƯỜI, KHÔNG MODEL ANIME, KHÔNG NGƯỜI THẬT** để loại bỏ triệt để cảm giác "nét vẽ AI" gây khó chịu cho người chơi.

---

## 🎨 Quy Chuẩn Mỹ Thuật Chung (Global Art Direction)
* **Phong cách:** Semi-realistic ancient Asian imperial prop illustration (Minh họa đạo cụ cổ phong Á Đông bán thực, sắc nét, chất liệu cao cấp: ngọc thạch, vàng ròng, đồng thau, lụa là, gốm sứ cổ, gỗ mun).
* **Quy chuẩn khung hình:** Vật thể tự do ở trung tâm (Freestanding isolated object on solid dark charcoal background), góc 3D nghiêng 45 độ hoặc chính diện, không đóng khung cứng để Godot UI tự do lồng khung thẻ bài.
* **Ánh sáng:** Cinematic studio lighting, chiaroscuro rim light, viền sắc nét, độ phân giải 8k, tuyệt đối không có watermark hay chữ rác.

---

## 📜 ĐỢT 1: 20 ĐẠO CỤ BIỂU TRƯNG VAI TRÒ HOÀNG CUNG (ROLE PROPS)
*(Thay thế hoàn toàn chân dung người bằng vật phẩm/đạo cụ biểu trưng đặc trưng của từng vai trò)*

### 1. Người Vô Tội (`role_good_fellow`)
* **Đạo cụ:** Đèn hoa sen giấy mộc mạc và chén trà hoa cúc tinh khiết.
* **Prompt Gemini Web:**
  > `A high-end 3D isolated prop illustration of a traditional ancient Asian floating lotus flower lantern, crafted from delicate translucent white and pale pink rice paper with a small glowing golden candle inside, resting gently on a carved wooden saucer next to a pure white porcelain teacup with blooming chrysanthemum tea. Soft warm golden and soothing teal aura, isolated on solid dark charcoal background, cinematic studio lighting, no human figures, clean silhouette, 8k Unreal Engine prop render.`

### 2. Nghịch Thần (`role_traitor`)
* **Đạo cụ:** Mũ quan gấm đen thêu rồng vàng ẩn giấu và đoản kiếm chủy thủ găm vào cuộn tấu chương.
* **Prompt Gemini Web:**
  > `A high-end 3D isolated prop illustration representing an imperial traitor, featuring an opulent black and crimson silk court magistrate official hat adorned with a jade pin, resting beside an ancient folded memorial petition scroll half-pierced by a stealthy golden dragon-hilted dagger. Subtly glowing sinister crimson aura, luxurious antique textures, isolated on solid dark charcoal background, dramatic chiaroscuro rim lighting, no human figures, 8k resolution.`

### 3. Thuộc Hạ (`role_accomplice`)
* **Đạo cụ:** Cặp phi tiêu ám khí hình lá liễu và lọ thuốc độc nhỏ quấn dây thừng đen.
* **Prompt Gemini Web:**
  > `A high-end 3D isolated prop illustration of an imperial shadow assassin's gear, featuring a pair of razor-sharp blackened steel throwing daggers shaped like willow leaves with midnight-blue silk tassels, resting beside a tiny clay flask bound with rough black cords. Faint cold moonlit steel gleam, isolated on solid dark charcoal background, cinematic rim lighting, no humans, crisp clean edges, 8k.`

### 4. Kẻ Bao Đồng (`role_meddler`)
* **Đạo cụ:** Chiếc quạt giấy gấp vẽ hình mắt chim hạc hé mở và cuốn sổ tay thắt chỉ đỏ.
* **Prompt Gemini Web:**
  > `A high-end 3D isolated prop illustration of a nosy courtier's signature tools, featuring a half-unfolded ancient paper folding fan painted with an inquisitive crane eye among auspicious clouds, resting next to a small stitched court gossip notebook tied with a scarlet ribbon and a tiny brass ear-spoon charm. Warm lantern light, isolated on solid dark charcoal background, no human figures, 8k.`

### 5. Độc Sư (`poisoner`)
* **Đạo cụ:** Lọ gốm độc dược quấn quanh bởi một con rắn lục ngọc bích, khói tím bốc lên.
* **Prompt Gemini Web:**
  > `A high-end 3D isolated prop illustration of an ancient imperial poisoner's signature relic, featuring an antique dark purple porcelain potion flask with a miniature jade green venomous serpent coiled protectively around its neck, emitting a faint ethereal spiraling violet and emerald poisonous vapor from the cork. Eerie bioluminescent glow, isolated on solid dark charcoal background, no humans, 8k resolution.`

### 6. Kẻ Say Rượu (`drunkard`)
* **Đạo cụ:** Bầu rượu hồ lô gốm men lam đổ nghiêng, vài giọt rượu sóng sánh óng ánh.
* **Prompt Gemini Web:**
  > `A high-end 3D isolated prop illustration representing the palace drunkard, featuring a rustic ceramic wine gourd glazed in blue-and-white porcelain patterns with a red cord tassel, tipped sideways with glistening drops of amber rice wine spilling onto an antique lacquered wood coaster. Warm cozy tavern lantern highlights, isolated on solid dark charcoal background, no human figures, 8k.`

### 7. Thợ May (`tailor`)
* **Đạo cụ:** Kéo vàng chạm trổ cổ điển cắt ngang cuộn lụa ngũ sắc và thước đo gỗ đào.
* **Prompt Gemini Web:**
  > `A high-end 3D isolated prop illustration representing the royal court tailor, featuring an exquisite pair of antique golden tailoring shears engraved with delicate floral vines, cutting across shimmering rainbow silk brocade ribbons and a polished peachwood measuring ruler marked with brass inlays. Crisp reflections, isolated on solid dark charcoal background, studio lighting, no humans, 8k.`

### 8. Kẻ Bắt Chước (`copycat`)
* **Đạo cụ:** Mặt nạ kịch hoàng cung chia đôi (một nửa ngọc trắng cười, một nửa gỗ đen khóc).
* **Prompt Gemini Web:**
  > `A high-end 3D isolated prop illustration of a theatrical disguise mask, divided symmetrically into two contrasting halves: the left half carved from polished white nephrite jade with a subtle mocking smile, the right half crafted from charred black lacquer with a weeping sorrowful expression, tied with purple silk cords. Ethereal duality aura, isolated on solid dark charcoal background, no humans, 8k.`

### 9. Sát Nhân Hàng Loạt (`serial_killer`)
* **Đạo cụ:** Chủy thủ đen chạm khắc đầu lâu phong ấn và mảnh khăn vải đen rách mép dính vết sáp đỏ.
* **Prompt Gemini Web:**
  > `A high-end 3D isolated prop illustration representing a phantom serial killer, featuring a menacing curved ritual sickle dagger forged from obsidian-black damascus steel, resting upon a torn black velvet shroud stamped with an eerie crimson wax mark. Chilling crimson edge highlights, dark gothic imperial atmosphere, isolated on solid dark charcoal background, no human figures, 8k.`

### 10. Bác Sĩ Phẫu Thuật (`surgeon`)
* **Đạo cụ:** Bộ dao mổ bạc và kẹp phẫu thuật dã chiến đặt trên khay gốm sứ trắng.
* **Prompt Gemini Web:**
  > `A high-end 3D isolated prop illustration representing the imperial court surgeon, featuring a set of gleaming antique silver surgical scalpels, delicate forceps, and silver suture needles neatly arranged inside a clean white celadon porcelain medical dish. Pristine clinical metallic gleam mixed with soft candle rim light, isolated on solid dark charcoal background, no humans, 8k.`

### 11. Thợ Đồng Hồ (`clock_maker`)
* **Đạo cụ:** Kính lúp một mắt bằng đồng thau kèm bánh răng cơ khí và quả lắc đồng hồ cổ.
* **Prompt Gemini Web:**
  > `A high-end 3D isolated prop illustration representing the royal horologist, featuring an intricate Victorian-oriental antique brass watchmaker's monocle with adjustable magnifying lenses, resting amidst interlocking miniature golden clockwork gears, brass cogs, and a tiny swinging pendulum. Warm amber mechanical glow, isolated on solid dark charcoal background, no humans, 8k.`

### 12. Kẻ Lừa Đảo (`conman`)
* **Đạo cụ:** Cặp xúc xắc ngọc bích gian lận mạ vàng và một thỏi vàng giả bị mẻ góc lộ đất sét bên trong.
* **Prompt Gemini Web:**
  > `A high-end 3D isolated prop illustration representing the cunning con artist, featuring a pair of weighted golden dice inlaid with fake jade dots, resting beside an ancient Chinese gold sycee ingot with a chipped corner revealing hidden grey clay underneath. Playful glint of deceit, isolated on solid dark charcoal background, warm gambling hall lighting, no human figures, 8k.`

### 13. Kẻ Bới Vết (`critic`)
* **Đạo cụ:** Cây bút lông chu sa mực đỏ gác trên giá bút đá hoa cương và tờ sớ tấu gạch chéo đỏ.
* **Prompt Gemini Web:**
  > `A high-end 3D isolated prop illustration representing the strict imperial censor, featuring a calligraphy brush with deep red cinnabar ink dripping from the tip, resting on a carved marble mountain brush rest beside an unrolled imperial report scroll stamped with sharp red audit marks. Crisp analytical lighting, isolated on solid dark charcoal background, no humans, 8k.`

### 14. Người Đưa Thư (`mailman`)
* **Đạo cụ:** Ống tre đưa thư hỏa tốc bịt đồng có cắm lông gà truyền tin (hỏa kê linh).
* **Prompt Gemini Web:**
  > `A high-end 3D isolated prop illustration representing the royal express courier, featuring an ancient bamboo dispatch tube bound with polished bronze hoops and sealed with red wax, adorned with three bright pheasant feather plumage indicating top military urgency, resting on weathered leather travel straps. Dawn sunlight rim, isolated on solid dark charcoal background, no humans, 8k.`

### 15. Nhà Toán Học (`mathematician`)
* **Đạo cụ:** Bàn tính gỗ mun hạt ngọc cẩn xà cừ và thước đo góc thiên văn.
* **Prompt Gemini Web:**
  > `A high-end 3D isolated prop illustration representing the imperial astronomer mathematician, featuring a compact antique ebony wood abacus with luminous jade beads, set next to an intricately engraved brass celestial protractor and compass divider. Faint celestial stardust sparkles, isolated on solid dark charcoal background, no human figures, 8k.`

### 16. Người Kể Chuyện (`reporter`)
* **Đạo cụ:** Khối phách gỗ gõ nhịp (kinh đường mộc) đặt cạnh tách trà bốc khói.
* **Prompt Gemini Web:**
  > `A high-end 3D isolated prop illustration representing the teahouse storyteller, featuring a polished dark rosewood gavel / storytelling clapper (xingmu) engraved with cloud waves, resting next to a traditional covered porcelain gaiwan teacup emitting gentle swirling steam. Warm cozy candle glow, isolated on solid dark charcoal background, no human figures, 8k.`

### 17. U Hồn (`spectre`)
* **Đạo cụ:** Ngọn đèn lồng giấy rách nát cháy ngọn lửa ma trơi xanh lam u linh (quỷ hỏa).
* **Prompt Gemini Web:**
  > `A high-end 3D isolated prop illustration representing a haunting palace ghost, featuring a weathered and tattered antique hexagonal paper lantern floating weightlessly, glowing from within with an eerie ethereal blue will-o'-the-wisp ghost flame, with faint translucent spirit ribbons swirling around it. Haunting cyan luminescence, isolated on solid dark charcoal background, no humans, 8k.`

### 18. Lang Y Trấn Thần (`therapist`)
* **Đạo cụ:** Chuông đồng thiền định và lư trầm hương nhỏ tỏa khói an thần.
* **Prompt Gemini Web:**
  > `A high-end 3D isolated prop illustration representing the spiritual mind healer, featuring a small antique bronze Tibetan singing bell with a wooden striker, resting next to an intricately carved lotus-shaped bronze incense burner emitting soft, peaceful spiral ribbons of white agarwood smoke. Divine peaceful golden halo, isolated on solid dark charcoal background, no humans, 8k.`

### 19. Hiệp Khách Cấm Cung (`vigilante`)
* **Đạo cụ:** Thanh trường kiếm gác trên chiếc nón lá phong trần có dải lụa xanh.
* **Prompt Gemini Web:**
  > `A high-end 3D isolated prop illustration representing the righteous imperial vigilante, featuring a classical straight steel longsword in a black sharkskin scabbard with brass fittings, resting across a weathered woven bamboo conical hat with a fluttering azure silk ribbon. Noble heroic moonlight gleam, isolated on solid dark charcoal background, no human figures, 8k.`

### 20. Chiêm Tinh Gia (`weatherman`)
* **Đạo cụ:** La bàn thiên văn bằng đồng khắc 28 chòm sao và mảnh thiên thạch phát sáng.
* **Prompt Gemini Web:**
  > `A high-end 3D isolated prop illustration representing the royal astrologer, featuring an intricate antique brass astrolabe inscribed with 28 lunar constellations and celestial rings, resting beside a glowing fragment of star meteorite pulsing with deep purple cosmic energy. Starlight flares and golden planetary aura, isolated on solid dark charcoal background, no humans, 8k.`

---

## 🔮 ĐỢT 2: 12 DI VẬT HOÀNG CUNG (RELICS & IMPERIAL EQUIPMENT)
*(Vật thể 1:1 Isolated trên nền tối sạch, góc 3D isometric 45 độ, chất liệu hoàng kim/ngọc thạch)*

1. **Trấn Quốc Ngọc Tỷ (Imperial Jade Seal):**
   > `A high-end 3D isolated item illustration of the legendary Chinese Imperial Jade Seal, carved from flawless glowing white nephrite jade, surmounted by an intricately sculpted crouching dragon handle, bottom engraved with ancient imperial seal script in gold leaf. Soft golden-green divine aura, isolated on pure dark charcoal background, cinematic studio lighting, no humans, 8k resolution, Unreal Engine 5 prop render quality.`

2. **Gương Bát Quái Càn Khôn (Eight Trigrams Gold Mirror):**
   > `A high-end isolated item illustration of an ancient Eight Trigrams bronze mirror, ornate gold-plated rim engraved with Daoist Bagua symbols and celestial dragons, polished mirror surface glowing with ethereal swirling azure light. Intricate antique craftsmanship, isolated on dark charcoal background, magical rim lighting, no humans, fantasy game prop asset.`

3. **Thượng Phương Bảo Kiếm (Imperial Decree Sword):**
   > `A high-end isolated item illustration of an ancient imperial decree ceremonial straight sword (Jian), polished folded steel blade gleaming with cold silver light, scabbard made of black lacquered wood bound with gold filigree and inlaid with blood-red rubies, golden dragon crossguard. Isolated on dark background, dramatic rim lighting, no humans, 8k game art.`

4. **Quạt Lông Vũ Cung Đình (Royal Peacock Feather Fan):**
   > `A high-end isolated item illustration of a luxurious ancient Asian royal hand fan made of iridescent peacock feathers and gold foil trim, handle carved from white jade with an emerald pendant hanging from golden silk tassels. Soft sparkling magical aura, isolated on clean dark background, no humans, 8k resolution.`

5. **Ngọc Bội Long Phượng (Dragon & Phoenix Jade Pendant):**
   > `A high-end isolated item illustration of a circular ancient Chinese bi jade disc carved with interlocking dragon and phoenix in high relief, translucent emerald jade with glowing veins of green light, tied with red royal silk cord and golden beads. Isolated on dark charcoal background, macro jewelry render, no humans, 8k.`

6. **Hồ Lô Cửu Chuyển Kim Đan (Nine-turn Alchemy Gourd):**
   > `A high-end isolated item illustration of a mystical golden alchemy gourd, painted with swirling cinnabar clouds and gold leaf talismans, top sealed with a carved purple jade stopper emitting a fragrant golden spiral smoke. Soft glowing magical essence, isolated on dark background, no humans, fantasy loot asset.`

7. **Bàn Tính Vàng Khảm Ngọc (Imperial Gold Abacus):**
   > `A high-end isolated item illustration of an antique imperial court abacus made of solid polished gold frame with jadeite beads strung on silver rods, engraved with miniature auspicious bat and coin motifs. Gleaming metallic reflections, isolated on dark background, luxury ancient artifact render, no humans.`

8. **Trâm Cài Phượng Hoàng (Phoenix Ruby Hairpin):**
   > `A high-end isolated item illustration of an exquisite imperial golden phoenix hairpin, delicate gold filigree wings inlaid with glowing pigeon-blood rubies and freshwater pearls, dangling golden tassels with crystal drops. Masterpiece ancient royal jewelry, isolated on dark charcoal background, no humans, 8k studio lighting.`

9. **Chuông Đồng Cổ Trừ Tà (Ancient Exorcism Bronze Bell):**
   > `A high-end isolated item illustration of an antique miniature bronze temple bell, covered in weathered green patina and carved with protective Buddhist and Daoist incantations, wooden handle tipped with a vajra pestle, emitting faint golden soundwaves. Isolated on dark background, no humans, mystical relic prop.`

10. **Kính Thiên Lý Cẩn Xà Cừ (Mother-of-Pearl Spyglass):**
    > `A high-end isolated item illustration of an ornate collapsible brass spyglass telescope, barrel wrapped in polished tortoiseshell and inlaid with iridescent mother-of-pearl floral patterns, glass lens gleaming with sapphire reflections. Isolated on dark charcoal background, no humans, antique collector item.`

11. **Hộp Gỗ Trầm Hương Niêm Phong (Sealed Agarwood Relic Box):**
    > `A high-end isolated item illustration of an antique rectangular relic box made of dark carved agarwood, bound with brass corner protectors and sealed with a heavy brass dragon padlock wrapped in talisman paper with red cinnabar stamps. Faint mystic mist escaping from cracks, isolated on dark background, no humans.`

12. **Kim Long Ngự Ấn (Golden Dragon Imperial Seal):**
    > `A high-end isolated item illustration of a monumental solid gold royal stamp, surmounted by a fierce five-clawed golden dragon holding a glowing pearl in its mouth, mirror-polished gold with sharp ornamental engravings. Warm majestic golden brilliance, isolated on dark charcoal background, no humans, 8k resolution.`

---

## ⚡ ĐỢT 3: 12 VẾT THÁNH THẦN ẤN (STIGMATA / HOLY MARKS)
*(Biểu tượng/Dấu ấn phù chú phát sáng 1:1 Isolated trên nền đen thuần, hiệu ứng thần lực)*

1. **Thanh Long (Mộc):** `A mystical glowing elemental stigmata crest of the Azure Dragon, circular oriental tattoo insignia forming an energetic coiled dragon emitting radiant cyan and emerald-green lightning, surrounded by sacred wind runes. Isolated on pure black background, glowing ethereal vector magic seal, no humans, 8k VFX game icon.`
2. **Bạch Hổ (Kim):** `A mystical glowing elemental stigmata insignia of the White Tiger, stylized fierce tiger claw and fangs mark composed of brilliant platinum-white and golden metallic energy blades, sacred warrior aura. Isolated on black background, glowing celestial martial arts crest, no humans, 8k resolution.`
3. **Chu Tước (Hỏa):** `A mystical glowing stigmata insignia of the Vermilion Bird Phoenix, blazing wings and fiery tail feathers spiraling in a circular sacred pattern, burning with brilliant scarlet red, crimson and orange magical flames. Isolated on black background, intense fire magic seal, no humans, fantasy UI icon.`
4. **Huyền Vũ (Thủy):** `A mystical glowing stigmata insignia of the Black Tortoise and Serpent, ancient runic shell pattern intertwined with a water serpent, glowing with deep sapphire blue, aquamarine and abyssal black water magic ripples. Isolated on black background, divine defense crest, no humans, 8k.`
5. **Kỳ Lân (Thổ):** `A sacred glowing stigmata mark of the divine Qilin, stylized horn and auspicious clouds seal glowing with radiant amber-gold and earthy crystalline light, surrounded by golden petal sparks. Isolated on black background, holy blessing emblem, no humans, high-end fantasy UI asset.`
6. **Thái Cực Âm Dương:** `A mystical floating Yin-Yang Taiji stigmata symbol, swirling teardrops of pure celestial white light and deep cosmic void black, encircled by eight glowing golden Daoist Bagua trigrams, magical energy vortex. Isolated on dark black background, spiritual sacred emblem, no humans.`
7. **Huyết Nguyệt:** `An ominous occult stigmata mark of the Blood Moon, a jagged crescent moon dripping with crimson magical light, surrounded by delicate thorny briars and occult eye symbols glowing in deep blood-red. Isolated on black background, dark fantasy curse icon, no humans, 8k.`
8. **Thiên Phạt:** `A divine heavenly judgment stigmata mark, sharp geometric golden lightning bolts striking downward in a sacred diamond formation, surrounded by glowing plasma sparks and thunder runes. Isolated on pure black background, divine retribution magic crest, no humans.`
9. **Bạch Liên:** `A divine stigmata mark of a sacred blooming White Lotus flower, delicate petals glowing with pure translucent pearlescent white and soft golden halo light, floating on sacred water ripples. Isolated on black background, purity and healing aura icon, no humans, 8k.`
10. **Ma Nhãn:** `A forbidden demonic third-eye stigmata mark, stylized vertical dragon/demon eye glowing with menacing violet and magenta psychic flame, encircled by ancient binding chains and runes. Isolated on black background, eldritch perception crest, dark fantasy art, no humans.`
11. **Thiên Mệnh:** `A supreme imperial stigmata mark featuring the stylized ancient seal-script character for 'Heaven' (天), forged from solid radiant celestial gold with soaring dragon wings on both sides, raining golden dust. Isolated on black background, divine right of kings seal, no humans.`
12. **Hư Vô:** `A cosmic void stigmata mark resembling a total solar eclipse, a pitch-black central orb surrounded by a violent swirling corona of violet, deep indigo and starlight silver flares, distorting space around it. Isolated on black background, ultimate void magic seal, no humans, 8k.`

---

## 🎒 ĐỢT 4: 12 VẬT PHẨM LOOT BẢN ĐỒ (TABLETOP CONSUMABLES & PROPS)
*(Đạo cụ tiêu hao 1:1 Isolated trên nền tối, phong cách vật phẩm sa bàn cấm cung)*

1. **Hành Lộ Phù:** `A high-end isolated item illustration of an ancient yellow paper Daoist talisman inscribed with glowing red cinnabar calligraphy for speed and wind, edges burnt and floating with gentle golden wind embers. Isolated on dark charcoal background, fantasy consumable game prop, no humans.`
2. **Lệnh Bài Thông Hành:** `A high-end isolated item illustration of an ancient bronze imperial palace transit pass token, rectangular with rounded top, engraved with deep archaic Chinese characters for 'Command / Pass', tied with a weathered red cord and tassel. Authentic aged bronze patina, isolated on dark background, no humans.`
3. **Ngự Mã Lệnh:** `A high-end isolated item illustration of a silver military horse command medallion, carved with a galloping stallion surrounded by thunderclouds, polished silver with oxidized engravings, hanging from a blue silk lanyard. Isolated on dark background, strategic token asset, no humans.`
4. **Rương Gỗ Niêm Phong:** `A high-end isolated item illustration of a small heavy royal treasure chest made of dark red mahogany wood, reinforced with ornate brass straps and corner plates, locked with an antique brass latch. Isolated on dark background, classic RPG loot chest, no humans.`
5. **Chìa Khóa Vàng:** `A high-end isolated item illustration of a heavy ornamental antique skeleton key forged from pure gold, bow shaped into a majestic coiled dragon, shaft engraved with cloud patterns. Gleaming metallic highlights, isolated on dark charcoal background, no humans, 8k resolution.`
6. **Mật Chỉ Hoàng Đế:** `A high-end isolated item illustration of a secret imperial decree scroll, crafted from rich yellow dragon-brocade silk, partially unrolled showing classical calligraphy, bound with a gold-threaded red ribbon and stamped with an imperial scarlet wax seal. Isolated on dark background, no humans.`
7. **Trà Thảo Dược:** `A high-end isolated item illustration of an exquisite celadon ceramic tea jar painted with blue lotus motifs, wooden cork stopper tied with hemp string, steaming gently with aromatic herbal vapor. Warm healing aura, isolated on dark background, consumable potion asset, no humans.`
8. **Túi Gấm Cẩm Nang:** `A high-end isolated item illustration of a small traditional embroidered silk brocade pouch (lucky pouch), vibrant purple and gold floral embroidery, cinched tightly with golden braided cords and two jade beads. Isolated on dark background, mystery item bag, no humans.`
9. **Đèn Lồng Lụa:** `A high-end isolated item illustration of a miniature portable ancient Asian hexagonal palace lantern, delicate wooden frame with carved latticework and translucent yellow silk panels, glowing brightly from inside with warm candle flame. Isolated on dark background, cozy exploratory prop, no humans.`
10. **La Bàn Đồng:** `A high-end isolated item illustration of an antique bronze Feng Shui geomancy compass (Luo Pan), circular plate inscribed with intricate concentric rings of Chinese trigrams and heavenly stems, center magnetic needle floating in oil. Isolated on dark background, mystical navigation tool, no humans.`
11. **Bình Rượu Ngọc Tuyền:** `A high-end isolated item illustration of an ancient Asian wine jug made of polished light green jade with gold-inlaid plum blossom branches, wrapped around the neck with red silk ribbon and wax seal. Isolated on dark charcoal background, consumable stamina item, no humans.`
12. **Hộp Thuốc Ngự Y:** `A high-end isolated item illustration of a traditional portable imperial apothecary doctor's box, red lacquered wood with brass drawer handles, one small drawer slightly open revealing silver acupuncture needles and herbal pills. Isolated on dark background, medical kit asset, no humans.`

---

## 🚀 Hướng Dẫn Nhanh Khi Tạo Ảnh
1. Mở **Gemini Web**.
2. Copy nguyên khối prompt tiếng Anh bên trên vào chat.
3. Khi ảnh sinh xong, tải về và lưu theo tên gợi ý (ví dụ: `prop_poisoner.png`, `prop_traitor.png`, `relic_jade_seal.png`).
4. Gửi ảnh vào thư mục dự án hoặc gửi qua chat để Antigravity lắp ráp thẳng vào giao diện!
