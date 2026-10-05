class_name GeneratedPublicCaseView
extends RefCounted

const GENERATED_PUBLIC_CLUE := preload("res://scripts/domain/cases/GeneratedPublicClue.gd")
const GENERATED_PUBLIC_SUSPECT_VIEW := preload("res://scripts/domain/cases/GeneratedPublicSuspectView.gd")

var board_columns: int = 0
var board_rows: int = 0
var board_slot_count: int = 0
var logical_board_slots: PackedInt32Array = PackedInt32Array()
var public_evil_count: int = -1
var allowed_role_ids: Array[StringName] = []
var suspected_role_ids: Array[StringName] = []
var suspects: Array = []
var public_clues: Array = []
var clock_tower_slot: int = -1


static func from_generation_result(result, roles: Array[RoleDefinition]) -> GeneratedPublicCaseView:
	var view := GeneratedPublicCaseView.new()
	if result == null:
		return view
	view.board_columns = result.board_columns
	view.board_rows = result.board_rows
	view.board_slot_count = result.board_slot_count
	view.logical_board_slots = result.logical_board_slots.duplicate()
	view.allowed_role_ids = result.allowed_role_ids.duplicate()
	view.suspected_role_ids = result.suspected_role_ids.duplicate()
	if result.hidden_case_draft == null:
		return view
	for tile in result.hidden_case_draft.board_tiles:
		if tile.tile_kind == &"location" and tile.location_id == BoardLocationDefinition.LOCATION_CLOCK_TOWER:
			view.clock_tower_slot = tile.board_slot
	var role_by_id: Dictionary = _roles_by_id(roles)
	var evil_count: int = 0
	var obscured_target_id: int = result.hidden_case_draft.spectre_obscure_target_suspect_id
	for generated_suspect in result.hidden_case_draft.suspects:
		if generated_suspect == null:
			continue
		var public_role_id: StringName = generated_suspect.displayed_role_id
		var public_group: int = _public_group_for_role(role_by_id, public_role_id, generated_suspect.role_group)
		if generated_suspect.true_alignment == CaseEnums.Alignment.EVIL:
			evil_count += 1
		var public_suspect = GENERATED_PUBLIC_SUSPECT_VIEW.create(
			generated_suspect.suspect_id,
			generated_suspect.board_slot,
			public_role_id,
			public_group
		)
		if generated_suspect.suspect_id == obscured_target_id:
			public_suspect.public_role_id = &""
			public_suspect.public_role_group = -1
			public_suspect.role_identity_obscured = true
		view.suspects.append(public_suspect)
	view.suspects.sort_custom(func(first, second) -> bool:
		return first.suspect_id < second.suspect_id
	)
	for clue in result.hidden_case_draft.public_clues:
		if clue != null:
			var public_clue = _duplicate_public_clue(clue)
			if clue.suspect_id == obscured_target_id:
				public_clue.displayed_role_id = &""
			view.public_clues.append(public_clue)
	view.public_evil_count = evil_count
	return view


static func create_manual(
	source_board_columns: int,
	source_board_rows: int,
	source_public_evil_count: int,
	source_suspects: Array,
	source_public_clues: Array = []
) -> GeneratedPublicCaseView:
	var view := GeneratedPublicCaseView.new()
	view.board_columns = source_board_columns
	view.board_rows = source_board_rows
	view.board_slot_count = source_board_columns * source_board_rows
	for slot: int in range(view.board_slot_count):
		view.logical_board_slots.append(slot)
	view.public_evil_count = source_public_evil_count
	view.suspects = source_suspects.duplicate()
	view.suspects.sort_custom(func(first, second) -> bool:
		return first.suspect_id < second.suspect_id
	)
	for clue in source_public_clues:
		if clue != null:
			view.public_clues.append(_duplicate_public_clue(clue))
	return view


func suspect_ids() -> PackedInt32Array:
	var ids: PackedInt32Array = PackedInt32Array()
	for suspect in suspects:
		if suspect != null:
			ids.append(suspect.suspect_id)
	ids.sort()
	return ids


func fingerprint_text() -> String:
	var value: String = "public|board:%dx%d|slots:%s|evil_count:%d|roles:%s|suspected:%s|suspects:%s|clues:%s" % [
		board_columns,
		board_rows,
		_join_ints(logical_board_slots),
		public_evil_count,
		_join_role_ids(allowed_role_ids),
		_join_role_ids(suspected_role_ids),
		_join_values(suspects),
		_join_values(public_clues),
	]
	if clock_tower_slot >= 0:
		value += "|clock_slot:%d" % clock_tower_slot
	return value


static func _roles_by_id(roles: Array[RoleDefinition]) -> Dictionary:
	var by_id: Dictionary = {}
	for role: RoleDefinition in roles:
		if role != null and not String(role.role_id).is_empty():
			by_id[role.role_id] = role
	return by_id


static func _public_group_for_role(role_by_id: Dictionary, role_id: StringName, fallback_group: int) -> int:
	var role: RoleDefinition = role_by_id.get(role_id, null) as RoleDefinition
	return role.role_group if role != null else fallback_group


static func _duplicate_public_clue(clue):
	var copy = GENERATED_PUBLIC_CLUE.new()
	copy.suspect_id = clue.suspect_id
	copy.displayed_role_id = clue.displayed_role_id
	copy.behavior_role_id = clue.behavior_role_id
	copy.payload_kind = clue.payload_kind
	copy.text = clue.text
	copy.numeric_value = clue.numeric_value
	copy.referenced_suspect_ids = clue.referenced_suspect_ids.duplicate()
	if clue.payload_kind == InvestigationInformationResult.PayloadKind.WEATHER_REPORT:
		copy.referenced_suspect_ids.sort()
	else:
		copy.weather_group_slots = clue.weather_group_slots.duplicate()
	copy.in_play_role_id = clue.in_play_role_id
	copy.not_in_play_role_id = clue.not_in_play_role_id
	copy.direction_key = clue.direction_key
	copy.clock_start_hour = clue.clock_start_hour
	copy.clock_end_hour = clue.clock_end_hour
	copy.clock_claims_ringing = clue.clock_claims_ringing
	return copy


func _join_ints(values: PackedInt32Array) -> String:
	var parts: Array[String] = []
	for value: int in values:
		parts.append(str(value))
	return ",".join(parts)


func _join_role_ids(values: Array[StringName]) -> String:
	var parts: Array[String] = []
	for value: StringName in values:
		parts.append(String(value))
	return ",".join(parts)


func _join_values(values: Array) -> String:
	var parts: Array[String] = []
	for value in values:
		if value != null:
			parts.append(value.fingerprint_text())
	return ",".join(parts)
