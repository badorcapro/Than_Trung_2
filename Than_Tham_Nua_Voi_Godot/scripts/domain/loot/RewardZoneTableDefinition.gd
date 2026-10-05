class_name RewardZoneTableDefinition
extends Resource

@export var zone_id: StringName
@export_range(0, 100, 1) var density_percent: int = 75
@export var entries: Array[WeightedRewardEntry] = []


func total_weight() -> int:
	var total := 0
	for entry: WeightedRewardEntry in entries:
		if entry != null and entry.weight > 0:
			total += entry.weight
	return total


func pick_reward_id(roll_source: RewardRollSource) -> StringName:
	var total: int = total_weight()
	if roll_source == null or total <= 0:
		return &""
	var pick: int = roll_source.pick_index(total)
	if pick < 0:
		return &""
	for entry: WeightedRewardEntry in entries:
		if entry == null or entry.weight <= 0:
			continue
		if pick < entry.weight:
			return entry.reward_id
		pick -= entry.weight
	return &""
