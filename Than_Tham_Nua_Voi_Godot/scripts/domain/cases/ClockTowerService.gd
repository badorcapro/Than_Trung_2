class_name ClockTowerService
extends RefCounted

const CLOCK_TOWER_REQUIRED_ROLE_IDS: Array[StringName] = [
	&"clock_maker",
	&"gentleman",
	&"gargoyle",
	&"belfry",
	&"sniper",
	&"maid",
	&"fearmonger",
]


static func clock_tower_for_case(case_definition: CaseDefinition) -> ClockTowerDefinition:
	if case_definition == null:
		return null
	for location: BoardLocationDefinition in case_definition.location_definitions():
		if location is ClockTowerDefinition:
			return location as ClockTowerDefinition
	return null


static func has_clock_tower(case_definition: CaseDefinition) -> bool:
	return clock_tower_for_case(case_definition) != null


static func is_clock_tower_ringing(case_definition: CaseDefinition, runtime_state: CaseRuntimeState) -> bool:
	var tower: ClockTowerDefinition = clock_tower_for_case(case_definition)
	if tower == null or runtime_state == null:
		return false
	return hour_is_ringing(tower, runtime_state.elapsed_hours)


static func hour_is_ringing(tower: ClockTowerDefinition, elapsed_hour: int) -> bool:
	if tower == null:
		return false
	return elapsed_hour == tower.ring_hour or elapsed_hour == tower.ring_hour + 1


static func ring_interval_text(tower: ClockTowerDefinition) -> String:
	if tower == null:
		return ""
	return "%dh đến %dh" % [tower.ring_hour, tower.ring_hour + 1]


static func false_interval_is_valid(tower: ClockTowerDefinition, false_start_hour: int) -> bool:
	if tower == null:
		return false
	if false_start_hour < 1 or false_start_hour > 23:
		return false
	return not hour_is_ringing(tower, false_start_hour) and not hour_is_ringing(tower, false_start_hour + 1)


static func requires_clock_tower(case_definition: CaseDefinition) -> bool:
	if case_definition == null:
		return false
	for role_id: StringName in CaseRolePoolService.suspected_role_ids_for_case(case_definition):
		if role_id in CLOCK_TOWER_REQUIRED_ROLE_IDS:
			return true
	return false
