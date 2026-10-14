class_name MysteryChestState
extends RefCounted

const ITEM_CLASS := preload("res://scripts/domain/loot/MysteryChestItem.gd")

enum HintType {
	EXACT_COUNT = 0,
	COUNT_RANGE = 1,
	COUNT_COMPARISON = 2,
	RARITY_COUNT = 3,
	RARITY_TOTAL_VALUE = 4,
	RARITY_AVERAGE_VALUE = 5,
	REVEAL_ITEMS = 6,
	REVEAL_OUTLINES = 7,
	REVEAL_QUALITY = 8,
}

var items: Array[MysteryChestItem] = []
var generated_hints: Array[Dictionary] = []
var current_hint_index: int = 0


func total_silver_value() -> int:
	var total := 0
	for item: MysteryChestItem in items:
		if item != null:
			total += item.silver_value
	return total


func item_count() -> int:
	return items.size()


func red_items() -> Array[MysteryChestItem]:
	var result: Array[MysteryChestItem] = []
	for item: MysteryChestItem in items:
		if item != null and item.is_lab_upgrade_material():
			result.append(item)
	return result


func non_red_silver_value() -> int:
	var total := 0
	for item: MysteryChestItem in items:
		if item != null and not item.is_lab_upgrade_material():
			total += item.silver_value
	return total


func items_by_rarity(target_rarity: MysteryChestItem.Rarity) -> Array[MysteryChestItem]:
	var result: Array[MysteryChestItem] = []
	for item: MysteryChestItem in items:
		if item != null and item.rarity == target_rarity:
			result.append(item)
	return result


## Khi người chơi ở ô to đích và đổ xúc xắc, từ 0-2 món ngẫu nhiên được thêm vào hòm
func roll_vault_deposit(forced_count: int = -1) -> Array[MysteryChestItem]:
	var count: int = forced_count
	if count < 0:
		var roll: int = randi() % 100
		if roll < 25:
			count = 0
		elif roll < 75:
			count = 1
		else:
			count = 2

	var added: Array[MysteryChestItem] = []
	for i in range(count):
		var item: MysteryChestItem = _generate_random_item()
		items.append(item)
		added.append(item)
	return added


func _generate_random_item() -> MysteryChestItem:
	var item := MysteryChestItem.new()
	var rarity_roll: int = randi() % 100
	var rarity: MysteryChestItem.Rarity = MysteryChestItem.Rarity.WHITE

	if rarity_roll < 38:
		rarity = MysteryChestItem.Rarity.WHITE
	elif rarity_roll < 68:
		rarity = MysteryChestItem.Rarity.GREEN
	elif rarity_roll < 86:
		rarity = MysteryChestItem.Rarity.BLUE
	elif rarity_roll < 95:
		rarity = MysteryChestItem.Rarity.PURPLE
	elif rarity_roll < 99:
		rarity = MysteryChestItem.Rarity.GOLD
	else:
		rarity = MysteryChestItem.Rarity.RED

	item.rarity = rarity
	_apply_item_profile(item)
	return item


func _apply_item_profile(item: MysteryChestItem) -> void:
	match item.rarity:
		MysteryChestItem.Rarity.WHITE:
			var pool: Array[Dictionary] = [
				{"name": "Card - Ace", "val": 1, "w": 1, "h": 1, "icon": "🂡", "desc": "Thẻ bài Át thông thường."},
				{"name": "Card - 1", "val": 1, "w": 1, "h": 1, "icon": "🎴", "desc": "Thẻ bài 1 thông thường."},
				{"name": "Card - 2", "val": 1, "w": 1, "h": 1, "icon": "🎴", "desc": "Thẻ bài 2 thông thường."},
				{"name": "Card - 3", "val": 1, "w": 1, "h": 1, "icon": "🎴", "desc": "Thẻ bài 3 thông thường."},
				{"name": "Card - 4", "val": 1, "w": 1, "h": 1, "icon": "🎴", "desc": "Thẻ bài 4 thông thường."},
				{"name": "Card - 5", "val": 1, "w": 1, "h": 1, "icon": "🎴", "desc": "Thẻ bài 5 thông thường."},
				{"name": "Card - 6", "val": 1, "w": 1, "h": 1, "icon": "🎴", "desc": "Thẻ bài 6 thông thường."},
				{"name": "Card - 7", "val": 1, "w": 1, "h": 1, "icon": "🎴", "desc": "Thẻ bài 7 thông thường."},
				{"name": "Card - 8", "val": 1, "w": 1, "h": 1, "icon": "🎴", "desc": "Thẻ bài 8 thông thường."},
				{"name": "Card - 9", "val": 1, "w": 1, "h": 1, "icon": "🎴", "desc": "Thẻ bài 9 thông thường."},
				{"name": "Card - 10", "val": 1, "w": 1, "h": 1, "icon": "🎴", "desc": "Thẻ bài 10 thông thường."},
				{"name": "Card - J", "val": 1, "w": 1, "h": 1, "icon": "🂫", "desc": "Thẻ bài J thông thường."},
				{"name": "Card - Q", "val": 1, "w": 1, "h": 1, "icon": "🂭", "desc": "Thẻ bài Q thông thường."},
				{"name": "Card - K", "val": 1, "w": 1, "h": 1, "icon": "🂮", "desc": "Thẻ bài K thông thường."},
				{"name": "Card - Joker", "val": 5, "w": 1, "h": 1, "icon": "🃏", "desc": "Thẻ bài Joker đặc biệt."},
				{"name": "Refinement Chips (2)", "val": 0, "w": 1, "h": 1, "icon": "💾", "desc": "Mảnh tinh chế (x2). Vật phẩm tài nguyên không bán.", "res": true, "qty": 2, "can_sell": false},
			]
			var chosen: Dictionary = pool[randi() % pool.size()]
			item.display_name = chosen.get("name", "")
			item.silver_value = int(chosen.get("val", 1))
			item.grid_width = int(chosen.get("w", 1))
			item.grid_height = int(chosen.get("h", 1))
			item.icon = String(chosen.get("icon", "📦"))
			item.description = String(chosen.get("desc", ""))
			item.is_resource = bool(chosen.get("res", false))
			item.quantity = int(chosen.get("qty", 1))
			item.can_sell = bool(chosen.get("can_sell", true))

		MysteryChestItem.Rarity.GREEN:
			var pool: Array[Dictionary] = [
				{"name": "Keyboard", "val": 2, "w": 2, "h": 1, "icon": "⌨️", "desc": "Bàn phím cơ tinh xảo."},
				{"name": "Mouse", "val": 2, "w": 1, "h": 1, "icon": "🖱️", "desc": "Chuột quang học nhanh nhạy."},
				{"name": "Socket", "val": 2, "w": 1, "h": 1, "icon": "🔌", "desc": "Ổ cắm điện an toàn."},
				{"name": "9V Battery", "val": 2, "w": 1, "h": 1, "icon": "🔋", "desc": "Pin 9V chuẩn công nghiệp."},
				{"name": "Rechargeable Battery", "val": 2, "w": 1, "h": 1, "icon": "🔋", "desc": "Pin sạc dung lượng cao."},
				{"name": "Refinement Chips (4)", "val": 0, "w": 1, "h": 1, "icon": "💾", "desc": "Mảnh tinh chế (x4). Vật phẩm tài nguyên không bán.", "res": true, "qty": 4, "can_sell": false},
			]
			var chosen: Dictionary = pool[randi() % pool.size()]
			item.display_name = chosen.get("name", "")
			item.silver_value = int(chosen.get("val", 2))
			item.grid_width = int(chosen.get("w", 1))
			item.grid_height = int(chosen.get("h", 1))
			item.icon = String(chosen.get("icon", "📦"))
			item.description = String(chosen.get("desc", ""))
			item.is_resource = bool(chosen.get("res", false))
			item.quantity = int(chosen.get("qty", 1))
			item.can_sell = bool(chosen.get("can_sell", true))

		MysteryChestItem.Rarity.BLUE:
			var pool: Array[Dictionary] = [
				{"name": "Encrypted Router", "val": 3, "w": 2, "h": 1, "icon": "📡", "desc": "Bộ định tuyến mã hóa an toàn."},
				{"name": "SSD", "val": 3, "w": 1, "h": 1, "icon": "💾", "desc": "Ổ cứng thể rắn tốc độ cao."},
				{"name": "Radio", "val": 3, "w": 2, "h": 1, "icon": "📻", "desc": "Máy thu thanh cổ điển."},
				{"name": "Robin: If I Can Stop One Heart From Breaking - Chevy", "val": 4, "w": 2, "h": 2, "icon": "🎵", "desc": "Đĩa nhạc Robin: If I Can Stop One Heart From Breaking."},
				{"name": "Robin: Had I Not Seen the Sun - Chevy", "val": 4, "w": 2, "h": 2, "icon": "🎵", "desc": "Đĩa nhạc Robin: Had I Not Seen the Sun."},
				{"name": "Robin:  Hope Is the Thing With Feathers - Chevy", "val": 4, "w": 2, "h": 2, "icon": "🎵", "desc": "Đĩa nhạc Robin: Hope Is the Thing With Feathers."},
				{"name": "Refinement Chips (8)", "val": 0, "w": 1, "h": 1, "icon": "💾", "desc": "Mảnh tinh chế (x8). Vật phẩm tài nguyên không bán.", "res": true, "qty": 8, "can_sell": false},
			]
			var chosen: Dictionary = pool[randi() % pool.size()]
			item.display_name = chosen.get("name", "")
			item.silver_value = int(chosen.get("val", 3))
			item.grid_width = int(chosen.get("w", 1))
			item.grid_height = int(chosen.get("h", 1))
			item.icon = String(chosen.get("icon", "📦"))
			item.description = String(chosen.get("desc", ""))
			item.is_resource = bool(chosen.get("res", false))
			item.quantity = int(chosen.get("qty", 1))
			item.can_sell = bool(chosen.get("can_sell", true))

		MysteryChestItem.Rarity.PURPLE:
			var pool: Array[Dictionary] = [
				{"name": "Oximeter", "val": 8, "w": 1, "h": 1, "icon": "📟", "desc": "Máy đo nồng độ oxy chính xác."},
				{"name": "Merit Medal", "val": 8, "w": 1, "h": 1, "icon": "🏅", "desc": "Huy chương công trạng hoàng gia."},
				{"name": "GS5 Controller", "val": 8, "w": 2, "h": 1, "icon": "🎮", "desc": "Tay cầm điều khiển GS5 hiện đại."},
				{"name": "Spy Pen", "val": 8, "w": 1, "h": 1, "icon": "🖊️", "desc": "Bút điệp viên gắn vi mạch ngầm."},
				{"name": "Robin: Sway to My Beat in Cosmos - Chevy", "val": 0, "w": 2, "h": 2, "icon": "💿", "desc": "Đĩa nhạc Robin: Sway to My Beat in Cosmos (1 gói random vé đen).", "rtype": "black_ticket"},
				{"name": "Himeko Coffee Machine Set", "val": 0, "w": 2, "h": 2, "icon": "☕", "desc": "Bộ máy pha cà phê Himeko đặc biệt (1 gói random vé đen).", "rtype": "black_ticket"},
				{"name": "Himeko Broken Sword", "val": 0, "w": 2, "h": 1, "icon": "🗡️", "desc": "Thanh kiếm gãy Himeko huyền thoại (1 gói random vé đen).", "rtype": "black_ticket"},
				{"name": "Refinement Chips (16)", "val": 0, "w": 1, "h": 1, "icon": "💾", "desc": "Mảnh tinh chế (x16). Vật phẩm tài nguyên không bán.", "res": true, "qty": 16, "can_sell": false},
			]
			var chosen: Dictionary = pool[randi() % pool.size()]
			item.display_name = chosen.get("name", "")
			item.silver_value = int(chosen.get("val", 8))
			item.grid_width = int(chosen.get("w", 1))
			item.grid_height = int(chosen.get("h", 1))
			item.icon = String(chosen.get("icon", "📦"))
			item.description = String(chosen.get("desc", ""))
			item.reward_type = String(chosen.get("rtype", ""))
			item.is_resource = bool(chosen.get("res", false))
			item.quantity = int(chosen.get("qty", 1))
			item.can_sell = bool(chosen.get("can_sell", true))

		MysteryChestItem.Rarity.GOLD: # Cam / Vàng (Legendary)
			var pool: Array[Dictionary] = [
				{"name": "Array Server", "val": 16, "w": 2, "h": 2, "icon": "🖥️", "desc": "Máy chủ mảng dung lượng cực lớn."},
				{"name": "Military Satellite Communications Device", "val": 16, "w": 2, "h": 2, "icon": "🛰️", "desc": "Thiết bị truyền thông vệ tinh quân sự."},
				{"name": "Digital Camera", "val": 16, "w": 2, "h": 1, "icon": "📷", "desc": "Máy ảnh kỹ thuật số chuyên nghiệp."},
				{"name": "ASOS Motherboard", "val": 16, "w": 2, "h": 2, "icon": "🖲️", "desc": "Bo mạch chủ ASOS hiệu năng đỉnh cao."},
				{"name": "Refinement Chips (32)", "val": 0, "w": 1, "h": 1, "icon": "💾", "desc": "Mảnh tinh chế (x32). Vật phẩm tài nguyên không bán.", "res": true, "qty": 32, "can_sell": false},
			]
			var chosen: Dictionary = pool[randi() % pool.size()]
			item.display_name = chosen.get("name", "")
			item.silver_value = int(chosen.get("val", 16))
			item.grid_width = int(chosen.get("w", 1))
			item.grid_height = int(chosen.get("h", 1))
			item.icon = String(chosen.get("icon", "📦"))
			item.description = String(chosen.get("desc", ""))
			item.is_resource = bool(chosen.get("res", false))
			item.quantity = int(chosen.get("qty", 1))
			item.can_sell = bool(chosen.get("can_sell", true))

		MysteryChestItem.Rarity.RED: # Đỏ (Mythical)
			var pool: Array[Dictionary] = [
				{"name": "Rocket Fuel", "val": 45, "w": 1, "h": 2, "icon": "🚀", "desc": "Nhiên liệu tên lửa. Vật phẩm tài nguyên, có thể chọn bán lấy 45 Xu Bạc.", "res": true, "can_sell": true},
				{"name": "Quantum Storage", "val": 45, "w": 2, "h": 2, "icon": "🔮", "desc": "Kho lưu trữ lượng tử. Vật phẩm tài nguyên, có thể chọn bán lấy 45 Xu Bạc.", "res": true, "can_sell": true},
				{"name": "Locking Component (5)", "val": 0, "w": 1, "h": 1, "icon": "🔒", "desc": "Linh kiện khóa (x5). Vật phẩm tài nguyên, không bán được.", "res": true, "qty": 5, "can_sell": false},
			]
			var chosen: Dictionary = pool[randi() % pool.size()]
			item.display_name = chosen.get("name", "")
			item.silver_value = int(chosen.get("val", 45))
			item.grid_width = int(chosen.get("w", 1))
			item.grid_height = int(chosen.get("h", 1))
			item.icon = String(chosen.get("icon", "📦"))
			item.description = String(chosen.get("desc", ""))
			item.is_resource = bool(chosen.get("res", true))
			item.quantity = int(chosen.get("qty", 1))
			item.can_sell = bool(chosen.get("can_sell", false))

	item.item_id = StringName("vault_item_%s_%d" % [MysteryChestItem.rarity_name(item.rarity).to_lower(), randi() % 10000])


## Tạo danh sách 6 manh mối (1 lúc bắt đầu + 5 cho 5 vòng đấu giá)
func generate_hint_pack(count: int = 6) -> Array[Dictionary]:
	generated_hints.clear()
	current_hint_index = 0
	var used_types: Dictionary = {}

	# Đảm bảo có ít nhất vài món nếu hòm trống để có manh mối ý nghĩa
	if items.is_empty():
		roll_vault_deposit(2)

	var all_types: Array[HintType] = [
		HintType.EXACT_COUNT,
		HintType.COUNT_RANGE,
		HintType.COUNT_COMPARISON,
		HintType.RARITY_COUNT,
		HintType.RARITY_TOTAL_VALUE,
		HintType.RARITY_AVERAGE_VALUE,
		HintType.REVEAL_ITEMS,
		HintType.REVEAL_OUTLINES,
		HintType.REVEAL_QUALITY,
	]
	all_types.shuffle()

	for type_cand: HintType in all_types:
		if generated_hints.size() >= count:
			break
		var hint: Dictionary = _create_hint(type_cand)
		if not hint.is_empty():
			generated_hints.append(hint)
			used_types[type_cand] = true

	# Bổ sung nếu chưa đủ count
	while generated_hints.size() < count:
		var fallback_type: HintType = [HintType.REVEAL_ITEMS, HintType.REVEAL_OUTLINES, HintType.RARITY_COUNT].pick_random()
		generated_hints.append(_create_hint(fallback_type))

	return generated_hints


func next_hint() -> Dictionary:
	if current_hint_index < generated_hints.size():
		var hint: Dictionary = generated_hints[current_hint_index]
		current_hint_index += 1
		return hint
	if not generated_hints.is_empty():
		return generated_hints[generated_hints.size() - 1]
	return _create_hint(HintType.COUNT_RANGE)


func _create_hint(type: HintType) -> Dictionary:
	var total_count: int = items.size()
	var result: Dictionary = {
		"type": int(type),
		"title": "",
		"description": "",
		"revealed_items": [],
		"revealed_outlines": [],
		"revealed_qualities": [],
	}

	match type:
		HintType.EXACT_COUNT:
			result["title"] = "Số Lượng Chính Xác"
			result["description"] = "Trong Hòm Bí Ẩn hiện có chính xác %d vật phẩm." % total_count

		HintType.COUNT_RANGE:
			var delta: int = maxi(1, randi_range(1, 3))
			var min_c: int = maxi(0, total_count - delta)
			var max_c: int = total_count + delta
			result["title"] = "Khoảng Số Lượng"
			result["description"] = "Tổng số vật phẩm trong hòm nằm trong khoảng từ %d đến %d món." % [min_c, max_c]

		HintType.COUNT_COMPARISON:
			result["title"] = "So Sánh Số Lượng"
			if randi() % 2 == 0 and total_count > 1:
				var bound: int = randi_range(1, total_count - 1)
				result["description"] = "Hòm Bí Ẩn có TRÊN %d vật phẩm." % bound
			else:
				var bound: int = total_count + randi_range(1, 3)
				result["description"] = "Hòm Bí Ẩn có DƯỚI %d vật phẩm." % bound

		HintType.RARITY_COUNT:
			var r_cand: MysteryChestItem.Rarity = (randi() % 6) as MysteryChestItem.Rarity
			var matches: Array[MysteryChestItem] = items_by_rarity(r_cand)
			result["title"] = "Số Lượng Phẩm Cấp %s" % MysteryChestItem.rarity_name(r_cand)
			result["description"] = "Số lượng vật phẩm cấp [%s] trong hòm là: %d món." % [MysteryChestItem.rarity_name(r_cand), matches.size()]

		HintType.RARITY_TOTAL_VALUE:
			var r_cand: MysteryChestItem.Rarity = (randi() % 6) as MysteryChestItem.Rarity
			var matches: Array[MysteryChestItem] = items_by_rarity(r_cand)
			var sum_val := 0
			for m in matches: sum_val += m.silver_value
			result["title"] = "Tổng Giá Trị Phẩm Cấp %s" % MysteryChestItem.rarity_name(r_cand)
			result["description"] = "Tổng giá trị của các vật phẩm cấp [%s] là: %d Xu Bạc." % [MysteryChestItem.rarity_name(r_cand), sum_val]

		HintType.RARITY_AVERAGE_VALUE:
			var r_cand: MysteryChestItem.Rarity = (randi() % 6) as MysteryChestItem.Rarity
			var matches: Array[MysteryChestItem] = items_by_rarity(r_cand)
			var avg_val: int = 0
			if not matches.is_empty():
				var sum_val := 0
				for m in matches: sum_val += m.silver_value
				avg_val = int(round(float(sum_val) / float(matches.size())))
			result["title"] = "Trung Bình Cộng Phẩm Cấp %s" % MysteryChestItem.rarity_name(r_cand)
			result["description"] = "Giá trị trung bình cộng của các vật phẩm cấp [%s] là: %d Xu Bạc." % [MysteryChestItem.rarity_name(r_cand), avg_val]

		HintType.REVEAL_ITEMS:
			var reveal_count: int = mini(items.size(), randi_range(1, 5))
			var shuffled := items.duplicate()
			shuffled.shuffle()
			var revealed_list: Array[Dictionary] = []
			var revealed_ids: Array[String] = []
			for idx in range(reveal_count):
				var it: MysteryChestItem = shuffled[idx]
				revealed_list.append(it.to_dict())
				revealed_ids.append(String(it.item_id))
			result["title"] = "Phơi Bày %d Vật Phẩm" % reveal_count
			result["description"] = "Đã lộ diện %d món đồ ngẫu nhiên từ trong Hòm Bí Ẩn!" % reveal_count
			result["revealed_items"] = revealed_list
			result["revealed_item_ids"] = revealed_ids

		HintType.REVEAL_OUTLINES:
			var reveal_count: int = mini(items.size(), randi_range(1, 10))
			var shuffled := items.duplicate()
			shuffled.shuffle()
			var outlines: Array[Dictionary] = []
			for idx in range(reveal_count):
				var it: MysteryChestItem = shuffled[idx]
				outlines.append({
					"item_id": String(it.item_id),
					"width": it.grid_width,
					"height": it.grid_height
				})
			result["title"] = "Lộ Viền Kích Thước %d Món" % reveal_count
			result["description"] = "Biết được hình dạng kích cỡ (%d món) đang chiếm vị trí trong hòm." % reveal_count
			result["revealed_outlines"] = outlines

		HintType.REVEAL_QUALITY:
			var reveal_count: int = mini(items.size(), randi_range(1, 8))
			var shuffled := items.duplicate()
			shuffled.shuffle()
			var qualities: Array[Dictionary] = []
			for idx in range(reveal_count):
				var it: MysteryChestItem = shuffled[idx]
				qualities.append({
					"item_id": String(it.item_id),
					"rarity": int(it.rarity)
				})
			result["title"] = "Lộ Phẩm Cấp %d Ô (1x1)" % reveal_count
			result["description"] = "Nhìn thấy màu sắc phẩm cấp của %d món đồ (thu gọn ô 1x1)." % reveal_count
			result["revealed_qualities"] = qualities

	return result


func to_dict() -> Dictionary:
	var item_dicts: Array[Dictionary] = []
	for it: MysteryChestItem in items:
		if it != null: item_dicts.append(it.to_dict())
	return {
		"items": item_dicts,
		"generated_hints": generated_hints,
		"current_hint_index": current_hint_index,
	}


static func from_dict(data: Dictionary) -> MysteryChestState:
	var state := MysteryChestState.new()
	var raw_items: Array = data.get("items", [])
	for raw_it: Dictionary in raw_items:
		state.items.append(MysteryChestItem.from_dict(raw_it))
	var hints_raw: Array = data.get("generated_hints", [])
	for h in hints_raw:
		if h is Dictionary: state.generated_hints.append(h)
	state.current_hint_index = int(data.get("current_hint_index", 0))
	return state
