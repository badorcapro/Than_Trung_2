class_name CaseSelectionManager
extends RefCounted

## Domain Service: Manages 1-of-3 procedural case option selection.
## Provides deterministic option synthesis matching Dupery V1/V3 CaseSelection specifications.

const DEFAULT_OPTION_COUNT := 3

const REGIONS: Array[String] = [
	"Thái Y Viện",
	"Ngự Thiện Phòng",
	"Tàng Thư Các",
	"Hậu Hoa Viên",
	"Cấm Vệ Doanh",
	"Khâm Thiên Giám"
]

const CASE_TITLES: Array[String] = [
	"Án Mạng Độc Khí",
	"Mật Thư Thất Lạc",
	"Bóng Ma Hậu Cung",
	"Vụ Trộm Ngọc Tỷ",
	"Lời Thề Huyết Lệnh",
	"Tiếng Chuông Lúc Nửa Đêm"
]

const DIFFICULTY_EASY := "Dễ"
const DIFFICULTY_MEDIUM := "Vừa"
const DIFFICULTY_HARD := "Khó"

var _current_options: Array[Dictionary] = []
var _selected_option_index: int = -1


func generate_options(seed_val: int, round_number: int = 1) -> Array[Dictionary]:
	_current_options.clear()
	_selected_option_index = -1

	var rng := DotNetRandom.new(seed_val)
	var difficulty_tiers: Array[String] = [DIFFICULTY_EASY, DIFFICULTY_MEDIUM, DIFFICULTY_HARD]
	var suspect_tiers: Array[int] = [5, 6, 8]
	var evil_tiers: Array[int] = [1, 2, 3]
	var reward_tiers: Array[int] = [100, 250, 500]

	for i in range(DEFAULT_OPTION_COUNT):
		var tier_idx: int = i % difficulty_tiers.size()
		var reg_idx: int = rng.randi_range(0, REGIONS.size() - 1)
		var title_idx: int = (seed_val + i + round_number) % CASE_TITLES.size()
		if title_idx < 0:
			title_idx = -title_idx

		var case_seed: int = abs(seed_val + (i + 1) * 1000003 + round_number * 9176)
		var region_name: String = REGIONS[reg_idx]
		var title: String = "%s: %s" % [region_name, CASE_TITLES[title_idx]]

		var desc: String = (
			"Vụ án tại %s (Cấp độ: %s). Số lượng nghi phạm cần thẩm vấn: %d. "
			+ "Phá án thành công nhận %d điểm công danh."
		) % [region_name, difficulty_tiers[tier_idx], suspect_tiers[tier_idx], reward_tiers[tier_idx]]

		var option_data: Dictionary = {
			"option_index": i,
			"title": title,
			"region_name": region_name,
			"difficulty": difficulty_tiers[tier_idx],
			"suspect_count": suspect_tiers[tier_idx],
			"evil_count": evil_tiers[tier_idx],
			"reputation_reward": reward_tiers[tier_idx],
			"case_seed": case_seed,
			"round_number": round_number,
			"description": desc
		}
		_current_options.append(option_data)

	return _current_options.duplicate()


func select_option(option_index: int) -> Dictionary:
	if option_index < 0 or option_index >= _current_options.size():
		return {}
	_selected_option_index = option_index
	return _current_options[option_index].duplicate()


func get_selected_option() -> Dictionary:
	if _selected_option_index < 0 or _selected_option_index >= _current_options.size():
		return {}
	return _current_options[_selected_option_index].duplicate()


func get_current_options() -> Array[Dictionary]:
	return _current_options.duplicate()


func get_selected_option_index() -> int:
	return _selected_option_index


func has_options() -> bool:
	return _current_options.size() == DEFAULT_OPTION_COUNT


func clear() -> void:
	_current_options.clear()
	_selected_option_index = -1
