class_name LevelProgressionManager
extends RefCounted

## Domain Service: Manages stage/chapter progression loop (Candy Crush / Angry Birds paradigm).
## Tracks level unlocks, star evaluation (1-3 stars), high scores, and persistent saving/loading.

const DEFAULT_TOTAL_LEVELS := 10
const DEFAULT_SAVE_PATH := "user://save/level_progression.json"

const STAR_NONE := 0
const STAR_CLEAR := 1
const STAR_NO_CASUALTY := 2
const STAR_PERFECT := 3

const LEVEL_CHAPTER_NAMES: Array[String] = [
	"Kỳ Án Thái Y Viện",
	"Huyết Án Ngự Thiện Phòng",
	"Bí Ẩn Tàng Thư Các",
	"Sương Mù Hậu Hoa Viên",
	"Biến Loạn Cấm Vệ Doanh",
	"Mật Thám Khâm Thiên Giám",
	"Hồi Chuông Tử Thần",
	"Ám Tiễn Đông Cung",
	"Trận Đồ Bát Quái",
	"Chân Tướng Hoàng Triều"
]

var _levels: Array[Dictionary] = []


func _init(total_levels: int = DEFAULT_TOTAL_LEVELS) -> void:
	initialize_levels(total_levels)


func initialize_levels(total_levels: int = DEFAULT_TOTAL_LEVELS) -> void:
	_levels.clear()
	for i in range(1, total_levels + 1):
		var name_idx: int = (i - 1) % LEVEL_CHAPTER_NAMES.size()
		var level_name: String = "Hồi %d: %s" % [i, LEVEL_CHAPTER_NAMES[name_idx]]
		var par: int = 4 + int(i * 0.8)
		var suspects: int = mini(8, 4 + int(i * 0.5))

		var level_data: Dictionary = {
			"level_id": i,
			"name": level_name,
			"is_unlocked": i == 1,
			"completed": false,
			"star_rating": 0,
			"high_score": 0,
			"par_moves": par,
			"required_suspects": suspects
		}
		_levels.append(level_data)


func evaluate_clear(
	level_id: int,
	solved: bool,
	innocent_killed: int = 0,
	moves_used: int = 0,
	score: int = 0
) -> Dictionary:
	var level_idx := _find_level_index(level_id)
	if level_idx < 0:
		return {
			"success": false,
			"error": "Level %d not found" % level_id,
			"stars_earned": 0,
			"stars_record": 0,
			"newly_unlocked_level": 0
		}

	var lvl: Dictionary = _levels[level_idx]
	if not solved:
		return {
			"success": false,
			"stars_earned": 0,
			"stars_record": int(lvl.get("star_rating", 0)),
			"newly_unlocked_level": 0
		}

	# Calculate stars:
	# 1 Star: Case solved
	# 2 Stars: Case solved + 0 innocent casualties
	# 3 Stars: Case solved + 0 innocent casualties + moves_used <= par_moves
	var par: int = int(lvl.get("par_moves", 6))
	var stars: int = STAR_CLEAR
	if innocent_killed == 0:
		stars = STAR_NO_CASUALTY
		if moves_used > 0 and moves_used <= par:
			stars = STAR_PERFECT

	lvl["completed"] = true
	var old_stars: int = int(lvl.get("star_rating", 0))
	var record_stars: int = maxi(old_stars, stars)
	lvl["star_rating"] = record_stars

	var old_score: int = int(lvl.get("high_score", 0))
	lvl["high_score"] = maxi(old_score, score)

	# Unlock next level
	var newly_unlocked: int = 0
	var next_idx := level_idx + 1
	if next_idx < _levels.size():
		var next_lvl: Dictionary = _levels[next_idx]
		if not bool(next_lvl.get("is_unlocked", false)):
			next_lvl["is_unlocked"] = true
			newly_unlocked = int(next_lvl.get("level_id", 0))

	return {
		"success": true,
		"stars_earned": stars,
		"stars_record": record_stars,
		"newly_unlocked_level": newly_unlocked
	}


func get_level(level_id: int) -> Dictionary:
	var idx := _find_level_index(level_id)
	if idx < 0:
		return {}
	return _levels[idx].duplicate()


func get_all_levels() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for lvl in _levels:
		result.append(lvl.duplicate())
	return result


func get_total_stars() -> int:
	var total := 0
	for lvl in _levels:
		total += int(lvl.get("star_rating", 0))
	return total


func get_unlocked_level_count() -> int:
	var count := 0
	for lvl in _levels:
		if bool(lvl.get("is_unlocked", false)):
			count += 1
	return count


func get_completed_level_count() -> int:
	var count := 0
	for lvl in _levels:
		if bool(lvl.get("completed", false)):
			count += 1
	return count


func serialize() -> Dictionary:
	return {
		"version": 1,
		"total_stars": get_total_stars(),
		"levels": get_all_levels()
	}


func deserialize(data: Dictionary) -> bool:
	if not data.has("levels"):
		return false
	var loaded_levels: Variant = data.get("levels")
	if not (loaded_levels is Array):
		return false

	var new_levels: Array[Dictionary] = []
	for item in loaded_levels:
		if item is Dictionary:
			new_levels.append(item.duplicate())

	if new_levels.is_empty():
		return false

	_levels = new_levels
	return true


func save_progress(file_path: String = DEFAULT_SAVE_PATH) -> bool:
	var data := serialize()
	var json_str := JSON.stringify(data, "\t")

	var dir_path := file_path.get_base_dir()
	if not dir_path.is_empty() and not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)

	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		return false

	file.store_string(json_str)
	file.close()
	return true


func load_progress(file_path: String = DEFAULT_SAVE_PATH) -> bool:
	if not FileAccess.file_exists(file_path):
		return false

	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return false

	var content := file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(content)
	if not (parsed is Dictionary):
		return false

	return deserialize(parsed as Dictionary)


func _find_level_index(level_id: int) -> int:
	for i in range(_levels.size()):
		if int(_levels[i].get("level_id", 0)) == level_id:
			return i
	return -1
