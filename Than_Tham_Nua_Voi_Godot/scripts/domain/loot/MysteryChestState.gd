class_name MysteryChestState
extends RefCounted

const ITEM_CLASS := preload("res://scripts/domain/loot/MysteryChestItem.gd")
const CATALOG_CLASS := preload("res://scripts/domain/loot/AuctionCatalog.gd")

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
	var catalog_candidates: Array[Dictionary] = CATALOG_CLASS.filter_items(item.rarity)
	if not catalog_candidates.is_empty():
		var chosen: Dictionary = _pick_weighted_candidate(catalog_candidates)
		item.display_name = String(chosen.get("display_name", "Vật Phẩm"))
		item.silver_value = int(chosen.get("silver_value", 0))
		item.grid_width = int(chosen.get("grid_width", 1))
		item.grid_height = int(chosen.get("grid_height", 1))
		item.icon = String(chosen.get("icon", "📦"))
		item.description = String(chosen.get("description", ""))
		item.is_resource = bool(chosen.get("is_resource", false))
		item.quantity = int(chosen.get("quantity", 1))
		item.can_sell = bool(chosen.get("can_sell", true))
		item.asset_path = String(chosen.get("asset_path", ""))
		item.weight_str = String(chosen.get("weight_str", "<0.10KG"))
		item.category = String(chosen.get("category", "general"))
		item.drop_weight = int(chosen.get("drop_weight", 100))
		item.item_id = StringName("%s_%d" % [String(chosen.get("id", "item")), randi() % 10000])
		return

	# Fallback if catalog has no item of this rarity
	item.display_name = "Bảo Vật %s" % MysteryChestItem.rarity_name(item.rarity)
	item.silver_value = 10
	item.grid_width = 1
	item.grid_height = 1
	item.item_id = StringName("vault_item_%s_%d" % [MysteryChestItem.rarity_name(item.rarity).to_lower(), randi() % 10000])


func _pick_weighted_candidate(candidates: Array[Dictionary]) -> Dictionary:
	if candidates.is_empty():
		return {}
	var total_weight: int = 0
	for c in candidates:
		total_weight += int(c.get("drop_weight", 100))
	if total_weight <= 0:
		return candidates.pick_random()
	var roll: int = randi() % total_weight
	var current: int = 0
	for c in candidates:
		current += int(c.get("drop_weight", 100))
		if roll < current:
			return c
	return candidates.back()


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
