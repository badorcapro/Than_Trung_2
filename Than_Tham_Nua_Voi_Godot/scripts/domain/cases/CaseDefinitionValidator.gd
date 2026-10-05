class_name CaseDefinitionValidator
extends RefCounted

const CaseRoleModifierServiceScript := preload("res://scripts/domain/cases/CaseRoleModifierService.gd")
const CaseRolePoolServiceScript := preload("res://scripts/domain/cases/CaseRolePoolService.gd")
const PoisonerTaintServiceScript := preload("res://scripts/domain/cases/PoisonerTaintService.gd")
const BarkeepTransformationServiceScript := preload("res://scripts/domain/cases/BarkeepTransformationService.gd")
const PretendCapabilityScript := preload("res://scripts/domain/cases/CaseProceduralPretendCapability.gd")
const ClockTowerServiceScript := preload("res://scripts/domain/cases/ClockTowerService.gd")
const SerialKillerTimedEventServiceScript := preload("res://scripts/domain/cases/SerialKillerTimedEventService.gd")
const CONMAN_ROLE_ID: StringName = &"conman"
const COPYCAT_ROLE_ID: StringName = &"copycat"
const MILKMAN_ROLE_ID: StringName = &"milkman"
const CLOCK_MAKER_FALSE_INTERVAL_ROLE_IDS: Array[StringName] = [
	&"tutorial_mobster",
	&"mobster",
	&"spectre",
	&"poisoner",
	&"barkeep",
	&"drunkard",
]

func validate(
	case_definition: CaseDefinition,
	role_definitions: Array[RoleDefinition],
	player_fixtures: Array[PlayerCaseState] = []
) -> Dictionary:
	var errors: Array[Dictionary] = []
	if case_definition == null:
		_add_error(errors, "CASE_NULL", "CaseDefinition is null.")
		return _report(errors)

	var role_by_id: Dictionary = {}
	for role in role_definitions:
		if role == null or String(role.role_id).is_empty():
			_add_error(errors, "ROLE_ID_EMPTY", "A RoleDefinition has an empty role_id.")
			continue
		if role_by_id.has(role.role_id):
			_add_error(errors, "ROLE_ID_DUPLICATE", "Duplicate role_id: %s" % role.role_id)
		role_by_id[role.role_id] = role

	if String(case_definition.case_id).is_empty():
		_add_error(errors, "CASE_ID_EMPTY", "case_id must not be empty.")
	if case_definition.crime_scene == null:
		_add_error(errors, "CRIME_SCENE_MISSING", "Case fixture must define exactly one Crime Scene.")
	else:
		if String(case_definition.crime_scene.scene_id).is_empty():
			_add_error(errors, "CRIME_SCENE_ID_EMPTY", "Crime Scene scene_id must not be empty.")
		if case_definition.crime_scene.location_id != BoardLocationDefinition.LOCATION_CRIME_SCENE:
			_add_error(errors, "CRIME_SCENE_LOCATION_ID_INVALID", "Crime Scene location_id must be crime_scene.")
	if case_definition.suspects.is_empty():
		_add_error(errors, "SUSPECT_COUNT_INVALID", "Case must contain at least one suspect.")
	var location_definitions: Array[BoardLocationDefinition] = case_definition.location_definitions()
	var board_slot_count: int = _board_slot_count_for_case(case_definition)
	if case_definition.suspects.size() + location_definitions.size() > board_slot_count:
		_add_error(errors, "BOARD_TILE_COUNT_INVALID", "Case Board supports at most %d total tiles." % board_slot_count)
	_validate_rewards(case_definition, errors)

	var suspect_by_id: Dictionary = {}
	var role_groups: Dictionary = {}
	var has_impersonating_accomplice := false
	var has_corrupted := false
	var has_tailor := false
	var occupied_slots: Dictionary = {}
	var true_role_ids: Dictionary = {}
	_validate_board_locations(case_definition, location_definitions, occupied_slots, errors)

	for suspect in case_definition.suspects:
		if suspect == null:
			_add_error(errors, "SUSPECT_NULL", "Suspect entry must not be null.")
			continue
		if suspect_by_id.has(suspect.suspect_id):
			_add_error(errors, "SUSPECT_ID_DUPLICATE", "Duplicate suspect_id: %d" % suspect.suspect_id)
		suspect_by_id[suspect.suspect_id] = suspect
		if not _is_valid_board_slot(case_definition, suspect.board_slot):
			_add_error(errors, "BOARD_SLOT_INVALID", "Suspect %d board_slot must be in board bounds." % suspect.suspect_id)
		elif occupied_slots.has(suspect.board_slot):
			_add_error(errors, "BOARD_SLOT_DUPLICATE", "Suspect %d shares board_slot %d with %s." % [suspect.suspect_id, suspect.board_slot, occupied_slots[suspect.board_slot]])
		else:
			occupied_slots[suspect.board_slot] = "Suspect %d" % suspect.suspect_id
		if not role_by_id.has(suspect.true_role_id):
			_add_error(errors, "TRUE_ROLE_MISSING", "Suspect %d true_role_id does not exist: %s" % [suspect.suspect_id, suspect.true_role_id])
		elif true_role_ids.has(suspect.true_role_id):
			_add_error(errors, "TRUE_ROLE_DUPLICATE", "Suspect %d duplicates natural true_role_id: %s" % [suspect.suspect_id, suspect.true_role_id])
		else:
			true_role_ids[suspect.true_role_id] = suspect.suspect_id
		if not role_by_id.has(suspect.displayed_role_id):
			_add_error(errors, "DISPLAYED_ROLE_MISSING", "Suspect %d displayed_role_id does not exist: %s" % [suspect.suspect_id, suspect.displayed_role_id])
		if not String(suspect.impersonated_role_id).is_empty() and not role_by_id.has(suspect.impersonated_role_id):
			_add_error(errors, "IMPERSONATED_ROLE_MISSING", "Suspect %d impersonated_role_id does not exist: %s" % [suspect.suspect_id, suspect.impersonated_role_id])
		if not CaseEnums.is_valid_alignment(suspect.true_alignment):
			_add_error(errors, "ALIGNMENT_INVALID", "Suspect %d has invalid alignment." % suspect.suspect_id)
		if not CaseEnums.is_valid_role_group(suspect.role_group):
			_add_error(errors, "ROLE_GROUP_INVALID", "Suspect %d has invalid role group." % suspect.suspect_id)
		else:
			role_groups[suspect.role_group] = true
		if suspect.role_group == CaseEnums.RoleGroup.TONG_PHAM and suspect.is_impersonating and suspect.true_role_id != suspect.displayed_role_id:
			has_impersonating_accomplice = true
		if suspect.true_role_id == PoisonerTaintServiceScript.POISONER_ROLE_ID:
			_validate_poisoner_pretend_role(case_definition, suspect, errors)
		if suspect.true_role_id == BarkeepTransformationServiceScript.BARKEEP_ROLE_ID:
			_validate_barkeep_pretend_role(case_definition, suspect, errors)
		if suspect.true_role_id == BarkeepTransformationServiceScript.DRUNKARD_ROLE_ID:
			_validate_drunkard_pretend_role(case_definition, suspect, role_definitions, null, errors)
		if suspect.true_role_id == SerialKillerTimedEventServiceScript.SERIAL_KILLER_ROLE_ID:
			_validate_serial_killer_setup(case_definition, suspect, role_definitions, errors)
		if suspect.true_role_id == CONMAN_ROLE_ID:
			_validate_conman_setup(case_definition, suspect, errors)
		if suspect.true_role_id == COPYCAT_ROLE_ID:
			_validate_copycat_setup(case_definition, suspect, role_by_id, errors)
		_validate_clock_maker_false_interval(case_definition, suspect, errors)
		if suspect.is_corrupted:
			has_corrupted = true
		if suspect.true_role_id == &"tailor":
			has_tailor = true

	if case_definition.suspects.size() == 8 and not case_definition.has_meta(&"generator_version"):
		for required_group in CaseEnums.RoleGroup.values():
			if not role_groups.has(required_group):
				_add_error(errors, "ROLE_GROUP_MISSING", "Fixture is missing role group value %d." % required_group)
		if not has_impersonating_accomplice:
			_add_error(errors, "IMPERSONATING_ACCOMPLICE_MISSING", "Fixture requires one impersonating Tòng Phạm.")
		if not has_corrupted:
			_add_error(errors, "CORRUPTED_SUSPECT_MISSING", "Fixture requires one Tha Hóa suspect.")
	if case_definition.requires_tailor and not has_tailor:
		_add_error(errors, "TAILOR_MISSING", "Fixture declares requires_tailor but has no Thợ May.")
	if BarkeepTransformationServiceScript.new().case_setup_would_create_second_drunkard(case_definition):
		_add_error(errors, "BARKEEP_SECOND_DRUNKARD_SETUP", "Barkeep setup cannot contain a preexisting Kẻ Say Rượu.")

	_validate_suspect_numbering(case_definition, errors)
	_validate_answer_ids(case_definition, suspect_by_id, errors)
	_validate_suspect_list_roles(case_definition, role_by_id, errors)
	_validate_clock_tower_presence(case_definition, errors)
	_validate_startup_effect_ids(case_definition, suspect_by_id, errors)
	var startup_runtime_state: CaseRuntimeState = _runtime_after_startup_transformations(case_definition, role_definitions)
	_validate_mobster_setups(case_definition, role_by_id, startup_runtime_state, errors)
	_validate_critic_setups(case_definition, role_by_id, startup_runtime_state, errors)
	_validate_startup_drunkard_pretend_role(case_definition, role_definitions, suspect_by_id, errors)
	_validate_spectre_setups(case_definition, role_by_id, suspect_by_id, errors)
	_validate_players(player_fixtures, errors)
	return _report(errors)


func _validate_board_locations(
	case_definition: CaseDefinition,
	locations: Array[BoardLocationDefinition],
	occupied_slots: Dictionary,
	errors: Array[Dictionary]
) -> void:
	var location_ids: Dictionary = {}
	for location: BoardLocationDefinition in locations:
		if location == null:
			_add_error(errors, "LOCATION_NULL", "Board location entry must not be null.")
			continue
		if String(location.location_id).is_empty():
			_add_error(errors, "LOCATION_ID_EMPTY", "Board location_id must not be empty.")
		elif location_ids.has(location.location_id):
			_add_error(errors, "LOCATION_ID_DUPLICATE", "Duplicate location_id: %s" % location.location_id)
		else:
			location_ids[location.location_id] = true
		if location.display_name.is_empty():
			_add_error(errors, "LOCATION_NAME_EMPTY", "Board location %s display_name must not be empty." % location.location_id)
		if not _is_valid_board_slot(case_definition, location.board_slot):
			_add_error(errors, "BOARD_SLOT_INVALID", "Board location %s board_slot must be in board bounds." % location.location_id)
		elif occupied_slots.has(location.board_slot):
			_add_error(errors, "BOARD_SLOT_DUPLICATE", "Board location %s shares board_slot %d with %s." % [location.location_id, location.board_slot, occupied_slots[location.board_slot]])
		else:
			occupied_slots[location.board_slot] = "Location %s" % location.location_id
		if location is ClockTowerDefinition:
			var clock_tower: ClockTowerDefinition = location as ClockTowerDefinition
			if clock_tower.ring_hour < 1 or clock_tower.ring_hour > 23:
				_add_error(errors, "CLOCK_TOWER_RING_HOUR_INVALID", "Clock Tower ring_hour must be 1..23.")


func _board_slot_count_for_case(case_definition: CaseDefinition) -> int:
	if case_definition != null and case_definition.has_meta(&"board_slot_count"):
		return int(case_definition.get_meta(&"board_slot_count"))
	return CaseSpatialService.BOARD_SLOT_COUNT


func _is_valid_board_slot(case_definition: CaseDefinition, board_slot: int) -> bool:
	return board_slot >= 0 and board_slot < _board_slot_count_for_case(case_definition)


func _validate_suspect_numbering(
	case_definition: CaseDefinition,
	errors: Array[Dictionary]
) -> void:
	var expected_suspect_id: int = 1
	for board_slot: int in range(_board_slot_count_for_case(case_definition)):
		var suspect: SuspectDefinition = case_definition.suspect_at_slot(board_slot)
		if suspect == null:
			continue
		if suspect.suspect_id != expected_suspect_id:
			_add_error(
				errors,
				"SUSPECT_NUMBERING_ORDER_INVALID",
				"Suspects must be numbered left-to-right, top-to-bottom across suspect tiles only; board slot %d must be suspect %d, found %d." % [
					board_slot, expected_suspect_id, suspect.suspect_id,
				]
			)
		expected_suspect_id += 1


func _validate_clock_tower_presence(case_definition: CaseDefinition, errors: Array[Dictionary]) -> void:
	if ClockTowerServiceScript.requires_clock_tower(case_definition) and not ClockTowerServiceScript.has_clock_tower(case_definition):
		_add_error(errors, "CLOCK_TOWER_REQUIRED", "A suspected Clock-Tower role requires a Clock Tower location.")


func _validate_clock_maker_false_interval(
	case_definition: CaseDefinition,
	suspect: SuspectDefinition,
	errors: Array[Dictionary]
) -> void:
	if suspect == null or suspect.authored_lie_numeric_value < 0:
		return
	if suspect.displayed_role_id != &"clock_maker" and suspect.impersonated_role_id != &"clock_maker":
		return
	if not _clock_maker_false_interval_required(suspect):
		return
	var tower: ClockTowerDefinition = ClockTowerServiceScript.clock_tower_for_case(case_definition)
	if tower != null and not ClockTowerServiceScript.false_interval_is_valid(tower, suspect.authored_lie_numeric_value):
		_add_error(errors, "CLOCK_MAKER_FALSE_INTERVAL_OVERLAPS_TRUTH", "Clock Maker false interval must not overlap real Clock Tower ringing hours.")


func _clock_maker_false_interval_required(suspect: SuspectDefinition) -> bool:
	return suspect.is_corrupted or suspect.true_role_id in CLOCK_MAKER_FALSE_INTERVAL_ROLE_IDS


func _validate_rewards(case_definition: CaseDefinition, errors: Array[Dictionary]) -> void:
	if case_definition.merit_pool < 0:
		_add_error(errors, "MERIT_POOL_INVALID", "merit_pool must be non-negative.")
	if case_definition.reputation_penalty_on_wrong < 0:
		_add_error(errors, "REPUTATION_PENALTY_INVALID", "reputation_penalty_on_wrong must be non-negative.")
	if case_definition.base_ticket_reward < 0:
		_add_error(errors, "TICKET_REWARD_INVALID", "base_ticket_reward must be non-negative.")
	if case_definition.on_solve == null:
		_add_error(errors, "ON_SOLVE_MISSING", "on_solve reward is required.")
	if not case_definition.test_only_not_balance_locked:
		_add_error(errors, "TEST_BALANCE_MARKER_MISSING", "Fixture rewards must be marked TEST_ONLY / NOT_BALANCE_LOCKED.")


func _validate_answer_ids(case_definition: CaseDefinition, suspect_by_id: Dictionary, errors: Array[Dictionary]) -> void:
	for suspect_id in case_definition.evil_suspect_ids:
		if not suspect_by_id.has(suspect_id):
			_add_error(errors, "EVIL_ANSWER_UNKNOWN", "Evil answer references unknown suspect %d." % suspect_id)
		elif suspect_by_id[suspect_id].true_alignment != CaseEnums.Alignment.EVIL:
			_add_error(errors, "EVIL_ANSWER_MISMATCH", "Suspect %d is in evil answer but true alignment is not EVIL." % suspect_id)
	for suspect_id in case_definition.accomplice_suspect_ids:
		if not suspect_by_id.has(suspect_id):
			_add_error(errors, "ACCOMPLICE_UNKNOWN", "Tòng Phạm classification references unknown suspect %d." % suspect_id)
		elif suspect_by_id[suspect_id].role_group != CaseEnums.RoleGroup.TONG_PHAM:
			_add_error(errors, "ACCOMPLICE_MISMATCH", "Suspect %d is not truly Tòng Phạm." % suspect_id)
	for suspect_id in case_definition.traitor_suspect_ids:
		if not suspect_by_id.has(suspect_id):
			_add_error(errors, "TRAITOR_UNKNOWN", "Nghịch Thần classification references unknown suspect %d." % suspect_id)
		elif suspect_by_id[suspect_id].role_group != CaseEnums.RoleGroup.NGHICH_THAN:
			_add_error(errors, "TRAITOR_MISMATCH", "Suspect %d is not truly Nghịch Thần." % suspect_id)
	for suspect_id in case_definition.accomplice_suspect_ids:
		if suspect_id in case_definition.traitor_suspect_ids:
			_add_error(errors, "CLASSIFICATION_OVERLAP", "Suspect %d cannot be both Tòng Phạm and Nghịch Thần." % suspect_id)


func _validate_suspect_list_roles(case_definition: CaseDefinition, role_by_id: Dictionary, errors: Array[Dictionary]) -> void:
	var top_level_ids: Dictionary = {}
	var raw_suspected_ids: Array[StringName] = (
		case_definition.suspected_role_ids
		if not case_definition.suspected_role_ids.is_empty()
		else case_definition.suspect_list_role_ids
	)
	for role_id: StringName in raw_suspected_ids:
		if String(role_id).is_empty():
			_add_error(errors, "SUSPECTED_ROLE_EMPTY", "Suspected role_id must not be empty.")
		elif not role_by_id.has(role_id):
			_add_error(errors, "SUSPECTED_ROLE_MISSING", "Suspected role_id does not exist: %s" % role_id)
		elif top_level_ids.has(role_id):
			_add_error(errors, "SUSPECTED_ROLE_DUPLICATE", "Duplicate suspected role_id: %s" % role_id)
		else:
			var role: RoleDefinition = role_by_id[role_id] as RoleDefinition
			if role != null and role.is_fixture_placeholder:
				_add_error(errors, "SUSPECTED_ROLE_PLACEHOLDER", "Suspected role_id cannot be fixture-only: %s" % role_id)
		top_level_ids[role_id] = true
	var resolved_suspected_ids: Array[StringName] = CaseRolePoolServiceScript.suspected_role_ids_for_case(case_definition)
	for role_id: StringName in resolved_suspected_ids:
		top_level_ids[role_id] = true
	for parent_role_id: Variant in case_definition.nested_suspect_list_role_ids_by_parent.keys():
		var parent_id: StringName = StringName(parent_role_id)
		if not top_level_ids.has(parent_id):
			_add_error(errors, "NESTED_SUSPECT_LIST_PARENT_MISSING", "Nested suspect list parent is not top-level: %s" % parent_id)
		var raw_children: Variant = case_definition.nested_suspect_list_role_ids_by_parent.get(parent_role_id, [])
		var child_ids: Array = raw_children if raw_children is Array else []
		var child_seen: Dictionary = {}
		for child_role_id: Variant in child_ids:
			var child_id: StringName = StringName(child_role_id)
			if String(child_id).is_empty():
				_add_error(errors, "NESTED_SUSPECT_LIST_ROLE_EMPTY", "Nested suspect list role_id must not be empty.")
			elif not role_by_id.has(child_id):
				_add_error(errors, "NESTED_SUSPECT_LIST_ROLE_MISSING", "Nested suspect list role_id does not exist: %s" % child_id)
			elif top_level_ids.has(child_id):
				_add_error(errors, "NESTED_SUSPECT_LIST_ROLE_TOP_LEVEL", "Nested suspect list role_id must not also be top-level: %s" % child_id)
			elif child_seen.has(child_id):
				_add_error(errors, "NESTED_SUSPECT_LIST_ROLE_DUPLICATE", "Duplicate nested suspect list role_id: %s" % child_id)
			child_seen[child_id] = true


func _validate_poisoner_pretend_role(case_definition: CaseDefinition, suspect: SuspectDefinition, errors: Array[Dictionary]) -> void:
	var pretend_role_id: StringName = suspect.impersonated_role_id
	if String(pretend_role_id).is_empty():
		pretend_role_id = suspect.displayed_role_id
	if String(pretend_role_id).is_empty() or pretend_role_id == suspect.true_role_id:
		_add_error(errors, "POISONER_PRETEND_ROLE_REQUIRED", "Poisoner suspect %d must pretend a suspected role." % suspect.suspect_id)
	elif not PoisonerTaintServiceScript.new().pretend_role_is_valid(case_definition, pretend_role_id):
		_add_error(errors, "POISONER_PRETEND_ROLE_NOT_SUSPECTED", "Poisoner suspect %d pretends a role that is not suspected: %s" % [suspect.suspect_id, pretend_role_id])


func _validate_barkeep_pretend_role(case_definition: CaseDefinition, suspect: SuspectDefinition, errors: Array[Dictionary]) -> void:
	var pretend_role_id: StringName = _authored_pretend_role_id(suspect)
	if String(pretend_role_id).is_empty() or pretend_role_id == suspect.true_role_id:
		_add_error(errors, "BARKEEP_PRETEND_ROLE_REQUIRED", "Barkeep suspect %d must pretend a suspected role." % suspect.suspect_id)
	elif not BarkeepTransformationServiceScript.new().barkeep_pretend_role_is_valid(case_definition, pretend_role_id):
		_add_error(errors, "BARKEEP_PRETEND_ROLE_NOT_SUSPECTED", "Barkeep suspect %d pretends a role that is not suspected: %s" % [suspect.suspect_id, pretend_role_id])


func _validate_critic_setups(
	case_definition: CaseDefinition,
	role_by_id: Dictionary,
	startup_runtime_state: CaseRuntimeState,
	errors: Array[Dictionary]
) -> void:
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect == null or suspect.true_role_id != CaseRoleModifierServiceScript.CRITIC_ROLE_ID:
			continue
		var pretend_role_id: StringName = _authored_pretend_role_id(suspect)
		if (
			String(pretend_role_id).is_empty()
			or pretend_role_id == CaseRoleModifierServiceScript.CRITIC_ROLE_ID
			or not suspect.is_impersonating
			or suspect.displayed_role_id != pretend_role_id
		):
			_add_error(errors, "CRITIC_PRETEND_ROLE_REQUIRED", "Critic suspect %d must display another role." % suspect.suspect_id)
			continue
		var pretend_role: RoleDefinition = role_by_id.get(pretend_role_id, null) as RoleDefinition
		if pretend_role != null and not PretendCapabilityScript.can_pretend_authored_compatible(
			PretendCapabilityScript.CRITIC_ROLE_ID, pretend_role
		):
			_add_error(errors, "CRITIC_PRETEND_ROLE_UNSUPPORTED", "Critic suspect %d must display a supported lying-behavior role: %s" % [suspect.suspect_id, pretend_role_id])
		if not CaseRolePoolServiceScript.is_role_listed(case_definition, pretend_role_id):
			_add_error(errors, "CRITIC_PRETEND_ROLE_NOT_LISTED", "Critic suspect %d must display a role listed for this Case: %s" % [suspect.suspect_id, pretend_role_id])
		elif not CaseRolePoolServiceScript.is_listed_current_role_absent(case_definition, startup_runtime_state, pretend_role_id):
			_add_error(errors, "CRITIC_PRETEND_ROLE_IN_PLAY", "Critic suspect %d must display a listed role absent after startup mutations: %s" % [suspect.suspect_id, pretend_role_id])


func _validate_serial_killer_setup(
	case_definition: CaseDefinition,
	suspect: SuspectDefinition,
	role_definitions: Array[RoleDefinition],
	errors: Array[Dictionary]
) -> void:
	var service = SerialKillerTimedEventServiceScript.new()
	var pretend_role_id: StringName = _authored_pretend_role_id(suspect)
	if String(pretend_role_id).is_empty() or pretend_role_id == suspect.true_role_id:
		_add_error(errors, "SERIAL_KILLER_PRETEND_ROLE_REQUIRED", "Serial Killer suspect %d must pretend a suspected role." % suspect.suspect_id)
	elif not service.pretend_role_is_valid(case_definition, pretend_role_id):
		_add_error(errors, "SERIAL_KILLER_PRETEND_ROLE_NOT_SUSPECTED", "Serial Killer suspect %d pretends a role that is not suspected: %s" % [suspect.suspect_id, pretend_role_id])
	if not service.serial_killer_spawn_requirement_met(case_definition, suspect.suspect_id, role_definitions):
		_add_error(errors, "SERIAL_KILLER_ADJACENT_INNOCENT_REQUIRED", "Serial Killer suspect %d must be adjacent to a Người Vô Tội role." % suspect.suspect_id)


func _validate_conman_setup(case_definition: CaseDefinition, suspect: SuspectDefinition, errors: Array[Dictionary]) -> void:
	var pretend_role_id: StringName = _authored_pretend_role_id(suspect)
	if String(pretend_role_id).is_empty() or pretend_role_id == suspect.true_role_id:
		_add_error(errors, "CONMAN_PRETEND_ROLE_REQUIRED", "Conman suspect %d must pretend an in-play role." % suspect.suspect_id)
	elif pretend_role_id not in _true_role_ids_in_play(case_definition):
		_add_error(errors, "CONMAN_PRETEND_ROLE_NOT_IN_PLAY", "Conman suspect %d pretends a role that is not in play: %s" % [suspect.suspect_id, pretend_role_id])


func _validate_copycat_setup(case_definition: CaseDefinition, suspect: SuspectDefinition, role_by_id: Dictionary, errors: Array[Dictionary]) -> void:
	var pretend_role_id: StringName = _authored_pretend_role_id(suspect)
	var pretend_role: RoleDefinition = role_by_id.get(pretend_role_id, null) as RoleDefinition
	if String(pretend_role_id).is_empty() or pretend_role_id == suspect.true_role_id:
		_add_error(errors, "COPYCAT_PRETEND_ROLE_REQUIRED", "Copycat suspect %d must pretend a Good in-play role." % suspect.suspect_id)
	elif pretend_role_id == MILKMAN_ROLE_ID:
		_add_error(errors, "COPYCAT_PRETEND_MILKMAN", "Copycat suspect %d cannot pretend Milkman." % suspect.suspect_id)
	elif not PretendCapabilityScript.can_pretend_authored_compatible(suspect.true_role_id, pretend_role):
		_add_error(errors, "COPYCAT_PRETEND_ROLE_UNSUPPORTED", "Copycat suspect %d must pretend an authored-compatible role: %s" % [suspect.suspect_id, pretend_role_id])
	elif pretend_role_id not in _true_role_ids_in_play(case_definition):
		_add_error(errors, "COPYCAT_PRETEND_ROLE_NOT_IN_PLAY", "Copycat suspect %d pretends a role that is not in play: %s" % [suspect.suspect_id, pretend_role_id])
	elif pretend_role != null:
		if pretend_role.role_group in [CaseEnums.RoleGroup.TONG_PHAM, CaseEnums.RoleGroup.NGHICH_THAN]:
			_add_error(errors, "COPYCAT_PRETEND_ROLE_NOT_GOOD", "Copycat suspect %d must pretend a Good in-play role." % suspect.suspect_id)


func _validate_mobster_setups(
	case_definition: CaseDefinition,
	role_by_id: Dictionary,
	startup_runtime_state: CaseRuntimeState,
	errors: Array[Dictionary]
) -> void:
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect == null or not PretendCapabilityScript.MOBSTER_ROLE_IDS.has(suspect.true_role_id):
			continue
		var pretend_role_id: StringName = _authored_pretend_role_id(suspect)
		var pretend_role: RoleDefinition = role_by_id.get(pretend_role_id, null) as RoleDefinition
		if (
			String(pretend_role_id).is_empty()
			or pretend_role_id == suspect.true_role_id
			or not suspect.is_impersonating
			or suspect.displayed_role_id != pretend_role_id
		):
			_add_error(errors, "MOBSTER_PRETEND_ROLE_REQUIRED", "Mobster suspect %d must display another role." % suspect.suspect_id)
			continue
		if not PretendCapabilityScript.can_pretend_authored_compatible(suspect.true_role_id, pretend_role):
			_add_error(errors, "MOBSTER_PRETEND_ROLE_UNSUPPORTED", "Mobster suspect %d must display an authored-compatible role: %s" % [suspect.suspect_id, pretend_role_id])
			continue
		if not CaseRolePoolServiceScript.current_role_ids_in_play(
			case_definition, startup_runtime_state, suspect.suspect_id
		).has(pretend_role_id):
			_add_error(errors, "MOBSTER_PRETEND_ROLE_NOT_IN_PLAY", "Mobster suspect %d must display a current in-play role: %s" % [suspect.suspect_id, pretend_role_id])


func _validate_drunkard_pretend_role(
	case_definition: CaseDefinition,
	suspect: SuspectDefinition,
	role_definitions: Array[RoleDefinition],
	runtime_state: CaseRuntimeState,
	errors: Array[Dictionary]
) -> void:
	var pretend_role_id: StringName = _authored_pretend_role_id(suspect)
	var candidate_ids: Array[StringName] = CaseRolePoolServiceScript.suspected_role_candidates(case_definition)
	if String(pretend_role_id).is_empty() or pretend_role_id == BarkeepTransformationServiceScript.DRUNKARD_ROLE_ID:
		_add_error(errors, "DRUNKARD_PRETEND_ROLE_REQUIRED", "Drunkard suspect %d must pretend a Good role not currently in play." % suspect.suspect_id)
	elif not BarkeepTransformationServiceScript.new().drunkard_pretend_role_is_valid(case_definition, runtime_state, role_definitions, candidate_ids, pretend_role_id):
		_add_error(errors, "DRUNKARD_PRETEND_ROLE_NOT_GOOD_NOT_IN_PLAY", "Drunkard suspect %d pretends an invalid Good not-in-play role: %s" % [suspect.suspect_id, pretend_role_id])


func _validate_startup_drunkard_pretend_role(
	case_definition: CaseDefinition,
	role_definitions: Array[RoleDefinition],
	suspect_by_id: Dictionary,
	errors: Array[Dictionary]
) -> void:
	if case_definition.startup_barkeep_source_suspect_id <= 0 or case_definition.startup_barkeep_target_suspect_id <= 0:
		return
	if not suspect_by_id.has(case_definition.startup_barkeep_source_suspect_id) or not suspect_by_id.has(case_definition.startup_barkeep_target_suspect_id):
		return
	var source: SuspectDefinition = suspect_by_id[case_definition.startup_barkeep_source_suspect_id] as SuspectDefinition
	var target: SuspectDefinition = suspect_by_id[case_definition.startup_barkeep_target_suspect_id] as SuspectDefinition
	if source == null or target == null or source.true_role_id != BarkeepTransformationServiceScript.BARKEEP_ROLE_ID:
		return
	var runtime_state: CaseRuntimeState = CaseRuntimeState.new()
	var empty_players: Array[PlayerCaseState] = []
	runtime_state.initialize(case_definition, empty_players)
	if not CaseRoleTransformationService.new().transform_role(case_definition, runtime_state, target.suspect_id, BarkeepTransformationServiceScript.DRUNKARD_ROLE_ID, role_definitions):
		return
	_validate_drunkard_pretend_role(case_definition, target, role_definitions, runtime_state, errors)


func _authored_pretend_role_id(suspect: SuspectDefinition) -> StringName:
	if suspect == null:
		return &""
	if not String(suspect.impersonated_role_id).is_empty():
		return suspect.impersonated_role_id
	return suspect.displayed_role_id


func _true_role_ids_in_play(case_definition: CaseDefinition) -> Array[StringName]:
	var ids: Array[StringName] = []
	if case_definition == null:
		return ids
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect != null and suspect.true_role_id not in ids:
			ids.append(suspect.true_role_id)
	return ids


func _validate_startup_effect_ids(case_definition: CaseDefinition, suspect_by_id: Dictionary, errors: Array[Dictionary]) -> void:
	if case_definition.startup_poisoner_source_suspect_id > 0 and not suspect_by_id.has(case_definition.startup_poisoner_source_suspect_id):
		_add_error(errors, "STARTUP_POISONER_SOURCE_UNKNOWN", "Startup Poisoner source references an unknown suspect.")
	if case_definition.startup_poisoner_target_suspect_id > 0 and not suspect_by_id.has(case_definition.startup_poisoner_target_suspect_id):
		_add_error(errors, "STARTUP_POISONER_TARGET_UNKNOWN", "Startup Poisoner target references an unknown suspect.")
	if case_definition.startup_barkeep_source_suspect_id > 0 and not suspect_by_id.has(case_definition.startup_barkeep_source_suspect_id):
		_add_error(errors, "STARTUP_BARKEEP_SOURCE_UNKNOWN", "Startup Barkeep source references an unknown suspect.")
	if case_definition.startup_barkeep_target_suspect_id > 0 and not suspect_by_id.has(case_definition.startup_barkeep_target_suspect_id):
		_add_error(errors, "STARTUP_BARKEEP_TARGET_UNKNOWN", "Startup Barkeep target references an unknown suspect.")


func _runtime_after_startup_transformations(
	case_definition: CaseDefinition,
	role_definitions: Array[RoleDefinition]
) -> CaseRuntimeState:
	if case_definition == null:
		return null
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect == null:
			return null
	var runtime_state: CaseRuntimeState = CaseRuntimeState.new()
	var empty_players: Array[PlayerCaseState] = []
	runtime_state.initialize(case_definition, empty_players)
	if case_definition.startup_barkeep_source_suspect_id > 0 and case_definition.startup_barkeep_target_suspect_id > 0:
		BarkeepTransformationServiceScript.new().resolve_transformation(
			case_definition,
			runtime_state,
			case_definition.startup_barkeep_source_suspect_id,
			case_definition.startup_barkeep_target_suspect_id,
			role_definitions
		)
	return runtime_state


func _validate_spectre_setups(
	case_definition: CaseDefinition,
	role_by_id: Dictionary,
	suspect_by_id: Dictionary,
	errors: Array[Dictionary]
) -> void:
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect == null or suspect.true_role_id != PretendCapabilityScript.SPECTRE_ROLE_ID:
			continue
		var displayed_role: RoleDefinition = role_by_id.get(suspect.displayed_role_id, null) as RoleDefinition
		if (
			not suspect.is_impersonating
			or suspect.impersonated_role_id != suspect.displayed_role_id
			or not PretendCapabilityScript.can_pretend_authored_compatible(PretendCapabilityScript.SPECTRE_ROLE_ID, displayed_role)
		):
			_add_error(errors, "SPECTRE_PRETEND_ROLE_INVALID", "Spectre suspect %d must pretend a supported role." % suspect.suspect_id)
		var target_id: int = suspect.obscure_target_suspect_id
		if target_id <= 0 or not suspect_by_id.has(target_id):
			_add_error(errors, "SPECTRE_OBSCURE_TARGET_INVALID", "Spectre suspect %d must obscure one occupied suspect." % suspect.suspect_id)
			continue
		var target: SuspectDefinition = suspect_by_id[target_id] as SuspectDefinition
		if (
			target == null
			or target.role_group == CaseEnums.RoleGroup.HIEU_SU
			or target_id == case_definition.startup_barkeep_target_suspect_id
		):
			_add_error(errors, "SPECTRE_OBSCURE_TARGET_MEDDLER", "Spectre suspect %d cannot obscure a current Meddler." % suspect.suspect_id)


func _validate_players(players: Array[PlayerCaseState], errors: Array[Dictionary]) -> void:
	for player in players:
		if player == null:
			_add_error(errors, "PLAYER_NULL", "Player fixture must not be null.")
			continue
		if player.reputation < 0 or player.reputation > 6:
			_add_error(errors, "PLAYER_REPUTATION_INVALID", "Player %s reputation must be in 0–6." % player.player_id)
		if player.merit < 0.0 or player.orb_count < 0 or player.gacha_ticket_count < 0:
			_add_error(errors, "PLAYER_RESOURCE_INVALID", "Player %s has a negative resource." % player.player_id)
		if not CaseEnums.is_valid_submission_status(player.submission_status):
			_add_error(errors, "SUBMISSION_STATUS_INVALID", "Player %s has invalid submission status." % player.player_id)


func _add_error(errors: Array[Dictionary], code: String, reason: String) -> void:
	errors.append({"code": code, "reason": reason})


func _report(errors: Array[Dictionary]) -> Dictionary:
	return {
		"passed": errors.is_empty(),
		"errors": errors,
		"error_count": errors.size(),
	}
