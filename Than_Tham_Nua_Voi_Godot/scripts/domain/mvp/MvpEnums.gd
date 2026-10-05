class_name MvpEnums
extends RefCounted

enum Phase {
	MATCH_SETUP,
	CHARACTER_SELECTION,
	ROUND_START,
	CASE,
	CASE_SETTLEMENT,
	LOOT,
	LOOT_END_CONFIRMATION,
	EQUIPMENT_MANAGEMENT,
	ROUND_END,
	MATCH_COMPLETE,
}


static func phase_name(value: int) -> StringName:
	if value < 0 or value >= Phase.size():
		return &"INVALID"
	return StringName(Phase.keys()[value])


static func is_valid_phase(value: int) -> bool:
	return value >= 0 and value < Phase.size()
