class_name CourtRankService
extends RefCounted

# TEST_ONLY / PROTOTYPE_BALANCE / NOT_CANON_THRESHOLD_LOCKED.
# This is the single threshold profile authority until balance is approved.
const PROTOTYPE_THRESHOLD_PROFILE: Array[Dictionary] = [
	{"id": &"RANK_9", "name": "Cửu phẩm", "threshold": 0},
	{"id": &"RANK_8", "name": "Bát phẩm", "threshold": 15},
	{"id": &"RANK_7", "name": "Thất phẩm", "threshold": 35},
	{"id": &"RANK_6", "name": "Lục phẩm", "threshold": 60},
	{"id": &"RANK_5", "name": "Ngũ phẩm", "threshold": 90},
	{"id": &"RANK_4", "name": "Tứ phẩm", "threshold": 125},
	{"id": &"RANK_3", "name": "Tam phẩm", "threshold": 165},
	{"id": &"RANK_2", "name": "Nhị phẩm", "threshold": 210},
	{"id": &"RANK_1", "name": "Nhất phẩm", "threshold": 260},
]


static func rank_options() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for source: Dictionary in PROTOTYPE_THRESHOLD_PROFILE:
		result.append(source.duplicate(true))
	return result


static func is_valid_rank_id(rank_id: StringName) -> bool:
	for rank: Dictionary in PROTOTYPE_THRESHOLD_PROFILE:
		if StringName(rank.get("id", &"")) == rank_id:
			return true
	return false


static func rank_name(rank_id: StringName) -> String:
	for rank: Dictionary in PROTOTYPE_THRESHOLD_PROFILE:
		if StringName(rank.get("id", &"")) == rank_id:
			return String(rank.get("name", ""))
	return ""


static func rank_index(rank_id: StringName) -> int:
	for index: int in range(PROTOTYPE_THRESHOLD_PROFILE.size()):
		if StringName(PROTOTYPE_THRESHOLD_PROFILE[index].get("id", &"")) == rank_id:
			return index
	return -1


func resolve(cumulative_merit: float) -> Dictionary:
	var merit: float = maxf(0.0, cumulative_merit)
	var rank_index := 0
	for index: int in range(PROTOTYPE_THRESHOLD_PROFILE.size()):
		var threshold: int = int(PROTOTYPE_THRESHOLD_PROFILE[index].get("threshold", 0))
		if merit < float(threshold):
			break
		rank_index = index
	var current: Dictionary = PROTOTYPE_THRESHOLD_PROFILE[rank_index]
	var maximum_reached: bool = rank_index == PROTOTYPE_THRESHOLD_PROFILE.size() - 1
	var next_rank: Dictionary = (
		{} if maximum_reached else PROTOTYPE_THRESHOLD_PROFILE[rank_index + 1]
	)
	var next_threshold: int = -1 if maximum_reached else int(next_rank.get("threshold", -1))
	return {
		"rank_id": current.get("id", &"RANK_9"),
		"rank_name": String(current.get("name", "Cửu phẩm")),
		"rank_index": rank_index,
		"rank_threshold": int(current.get("threshold", 0)),
		"cumulative_merit": merit,
		"has_next_rank": not maximum_reached,
		"next_rank_id": next_rank.get("id", &""),
		"next_rank_name": String(next_rank.get("name", "")),
		"next_threshold": next_threshold,
		"merit_remaining": maxf(0.0, float(next_threshold) - merit) if not maximum_reached else 0.0,
		"maximum_reached": maximum_reached,
	}


func promotion(before_merit: float, after_merit: float) -> Dictionary:
	var before: Dictionary = resolve(before_merit)
	var after: Dictionary = resolve(after_merit)
	return {
		"promoted": int(after.get("rank_index", 0)) > int(before.get("rank_index", 0)),
		"before_rank_id": before.get("rank_id", &"RANK_9"),
		"before_rank_name": String(before.get("rank_name", "Cửu phẩm")),
		"before_rank_index": int(before.get("rank_index", 0)),
		"after_rank_id": after.get("rank_id", &"RANK_9"),
		"after_rank_name": String(after.get("rank_name", "Cửu phẩm")),
		"after_rank_index": int(after.get("rank_index", 0)),
		"ranks_crossed": maxi(
			0,
			int(after.get("rank_index", 0)) - int(before.get("rank_index", 0))
		),
	}
