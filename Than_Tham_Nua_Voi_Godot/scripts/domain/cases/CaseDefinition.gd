class_name CaseDefinition
extends Resource

@export var case_id: StringName
@export var data_version := 1
@export var display_name: String
@export_multiline var short_description: String
@export var tutorial_dialogue_lines: PackedStringArray = PackedStringArray()
@export var difficulty_label: String
@export var crime_scene: CrimeSceneDefinition
@export var board_locations: Array[BoardLocationDefinition] = []
@export var merit_pool := 0
@export var reputation_penalty_on_wrong := 0
@export var base_ticket_reward := 0
@export var on_solve: OnSolveReward
@export var suspects: Array[SuspectDefinition] = []
@export var evil_suspect_ids := PackedInt32Array()
@export var accomplice_suspect_ids := PackedInt32Array()
@export var traitor_suspect_ids := PackedInt32Array()
@export var suspected_role_ids: Array[StringName] = []
@export var suspect_list_role_ids: Array[StringName] = []
@export var nested_suspect_list_role_ids_by_parent: Dictionary = {}
@export_range(0, 99, 1) var startup_poisoner_source_suspect_id := 0
@export_range(0, 99, 1) var startup_poisoner_target_suspect_id := 0
@export_range(0, 99, 1) var startup_barkeep_source_suspect_id := 0
@export_range(0, 99, 1) var startup_barkeep_target_suspect_id := 0
@export var dev_runtime_event_seed := -1
@export var requires_tailor := false
@export var test_only_not_balance_locked := true
@export_multiline var balance_note: String


func location_definitions() -> Array[BoardLocationDefinition]:
	var locations: Array[BoardLocationDefinition] = []
	if crime_scene != null:
		locations.append(crime_scene)
	for location: BoardLocationDefinition in board_locations:
		if location == null:
			continue
		if crime_scene != null and location == crime_scene:
			continue
		locations.append(location)
	return locations


func location_at_slot(board_slot: int) -> BoardLocationDefinition:
	for location: BoardLocationDefinition in location_definitions():
		if location != null and location.board_slot == board_slot:
			return location
	return null


func suspect_at_slot(board_slot: int) -> SuspectDefinition:
	for suspect: SuspectDefinition in suspects:
		if suspect != null and suspect.board_slot == board_slot:
			return suspect
	return null


func is_board_slot_occupied(board_slot: int) -> bool:
	return suspect_at_slot(board_slot) != null or location_at_slot(board_slot) != null
