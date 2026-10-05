class_name CaseGenerator
extends RefCounted

const GENERATED_BOARD_TILE := preload("res://scripts/domain/cases/GeneratedBoardTile.gd")
const GENERATED_PUBLIC_CASE_VIEW := preload("res://scripts/domain/cases/GeneratedPublicCaseView.gd")
const GENERATED_PUBLIC_CLUE := preload("res://scripts/domain/cases/GeneratedPublicClue.gd")
const GENERATED_SUSPECT := preload("res://scripts/domain/cases/GeneratedSuspect.gd")
const CASE_GENERATOR_PUBLIC_SOLVER := preload("res://scripts/domain/cases/CaseGeneratorPublicSolver.gd")
const CASE_GENERATOR_SOLVER_RESULT := preload("res://scripts/domain/cases/CaseGeneratorSolverResult.gd")
const HIDDEN_CASE_DRAFT := preload("res://scripts/domain/cases/HiddenCaseDraft.gd")
const ON_SOLVE_REWARD := preload("res://scripts/domain/cases/OnSolveReward.gd")
const PRETEND_CAPABILITY := preload("res://scripts/domain/cases/CaseProceduralPretendCapability.gd")
const SERIAL_KILLER_TIMED_EVENT_SERVICE := preload("res://scripts/domain/cases/SerialKillerTimedEventService.gd")
const TILE_EMPTY: StringName = &"empty"
const TILE_LOCATION: StringName = &"location"
const MAX_GENERATION_ATTEMPTS := 64
const MAX_3X3_EVIL_COUNT := 3
func generate(request: CaseGenerationRequest, role_definitions: Array[RoleDefinition] = []) -> CaseGenerationResult:
	var validation: CaseGenerationResult = _validate_request(request, role_definitions)
	if not validation.is_success():
		return validation

	var rng := RandomNumberGenerator.new()
	rng.seed = request.seed

	var logical_slots: PackedInt32Array = _logical_slots(request.board_slot_count)
	var roles_by_id: Dictionary = _roles_by_id(role_definitions)
	for attempt: int in range(1, MAX_GENERATION_ATTEMPTS + 1):
		var probe_slots: PackedInt32Array = _deterministic_permutation(logical_slots, rng)
		var role_order: Array[RoleDefinition] = _deterministic_role_permutation(request.allowed_role_ids, roles_by_id, rng)
		var draft = _hidden_draft(request, logical_slots, probe_slots, role_order)
		if _assign_pretend_roles(draft, roles_by_id, rng) and _hidden_draft_is_valid(draft) and _assign_barkeep_transform(draft, request.allowed_role_ids, role_definitions, rng) and _mobster_current_witnesses_are_valid(draft) and _serial_killer_spawn_is_valid(draft, role_definitions) and _assign_spectre_obscure(draft, rng) and _assign_poisoner_taint(draft, rng):
			draft.suspected_role_ids = _case_suspected_role_ids(draft, request.allowed_role_ids, rng)
			if _assign_critic_pretend(draft, roles_by_id, role_definitions, rng) and _assign_clock_tower(draft, rng) and _generate_public_clues(draft, role_definitions, draft.suspected_role_ids):
				return _success_result(request, logical_slots, probe_slots, draft, attempt)
	return CaseGenerationResult.failure(
		request,
		CaseGenerationResult.ERROR_IMPOSSIBLE_REQUEST,
		"Unable to produce a valid hidden world within %d deterministic attempts." % MAX_GENERATION_ATTEMPTS
	)


func _validate_request(request: CaseGenerationRequest, role_definitions: Array[RoleDefinition]) -> CaseGenerationResult:
	if request == null:
		return CaseGenerationResult.failure(null, CaseGenerationResult.ERROR_REQUEST_NULL, "Generation request is null.")
	if request.generator_version <= 0:
		return CaseGenerationResult.failure(request, CaseGenerationResult.ERROR_GENERATOR_VERSION_INVALID, "generator_version must be positive.")
	if request.board_columns <= 0 or request.board_rows <= 0:
		return CaseGenerationResult.failure(request, CaseGenerationResult.ERROR_BOARD_DIMENSIONS_INVALID, "Board dimensions must be positive.")
	if request.board_slot_count != request.board_columns * request.board_rows:
		return CaseGenerationResult.failure(request, CaseGenerationResult.ERROR_BOARD_DIMENSIONS_INVALID, "board_slot_count must match columns * rows.")
	if not _board_profile_is_supported(request.board_columns, request.board_rows):
		return CaseGenerationResult.failure(request, CaseGenerationResult.ERROR_BOARD_DIMENSIONS_INVALID, "Only 3x3 and 4x4 generator contracts are supported in M0.")
	if not _profile_is_supported(request.generation_profile_id):
		return CaseGenerationResult.failure(request, CaseGenerationResult.ERROR_PROFILE_UNSUPPORTED, "Unsupported generation profile: %s" % request.generation_profile_id)
	if request.allowed_role_ids.is_empty():
		return CaseGenerationResult.failure(request, CaseGenerationResult.ERROR_CONTENT_POOL_EMPTY, "allowed_role_ids must not be empty.")
	if request.required_suspect_count <= 0:
		return CaseGenerationResult.failure(request, CaseGenerationResult.ERROR_IMPOSSIBLE_REQUEST, "required_suspect_count must be positive for M1 hidden-world generation.")
	if request.required_location_ids.size() + request.required_suspect_count > request.board_slot_count:
		return CaseGenerationResult.failure(request, CaseGenerationResult.ERROR_BOARD_CAPACITY_EXCEEDED, "Required locations plus suspects exceed board capacity.")
	var unique_locations: Dictionary = {}
	for location_id: StringName in request.required_location_ids:
		if String(location_id).is_empty() or unique_locations.has(location_id):
			return CaseGenerationResult.failure(request, CaseGenerationResult.ERROR_IMPOSSIBLE_REQUEST, "Required locations must be non-empty and unique.")
		unique_locations[location_id] = true
	for role_id: StringName in request.allowed_role_ids:
		if String(role_id).is_empty():
			return CaseGenerationResult.failure(request, CaseGenerationResult.ERROR_ROLE_ID_EMPTY, "allowed_role_ids must not contain empty role ids.")
	var roles_by_id: Dictionary = _roles_by_id(role_definitions)
	var unique_role_ids: Array[StringName] = []
	var has_good := false
	var has_evil := false
	for role_id: StringName in request.allowed_role_ids:
		var role: RoleDefinition = roles_by_id.get(role_id, null) as RoleDefinition
		if role == null:
			return CaseGenerationResult.failure(request, CaseGenerationResult.ERROR_ROLE_ID_UNKNOWN, "allowed role id does not resolve: %s" % role_id)
		if not unique_role_ids.has(role_id):
			unique_role_ids.append(role_id)
			var alignment: int = CaseRolePoolService.alignment_for_role_group(role.role_group)
			if alignment == CaseEnums.Alignment.EVIL:
				has_evil = true
			else:
				has_good = true
	if unique_role_ids.size() < request.required_suspect_count:
		return CaseGenerationResult.failure(request, CaseGenerationResult.ERROR_INSUFFICIENT_UNIQUE_ROLES, "Unique allowed true roles are fewer than required suspects.")
	if not has_good or not has_evil:
		return CaseGenerationResult.failure(request, CaseGenerationResult.ERROR_ALIGNMENT_POOL_INVALID, "M1 hidden world requires at least one Good and one Evil role candidate.")
	var success := CaseGenerationResult.new()
	success.status = CaseGenerationResult.STATUS_SUCCESS
	return success


func public_solver_result(result: CaseGenerationResult, role_definitions: Array[RoleDefinition] = []):
	var public_view = GENERATED_PUBLIC_CASE_VIEW.from_generation_result(result, role_definitions)
	return CASE_GENERATOR_PUBLIC_SOLVER.new().solve(public_view, role_definitions)


func public_case_has_unique_evil_answer(result: CaseGenerationResult, role_definitions: Array[RoleDefinition] = []) -> bool:
	var solver_result = public_solver_result(result, role_definitions)
	return solver_result != null and solver_result.status == CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION


func case_definition_from_result(result: CaseGenerationResult) -> CaseDefinition:
	if result == null or not result.is_success() or result.hidden_case_draft == null:
		return null
	var case_definition: CaseDefinition = _case_definition_from_hidden_draft(result.hidden_case_draft)
	case_definition.suspected_role_ids = result.suspected_role_ids.duplicate()
	case_definition.case_id = &"generated_candidate_case"
	case_definition.display_name = "Generated Candidate Case"
	case_definition.short_description = "Deterministic generated candidate for structural validation."
	case_definition.difficulty_label = String(result.generation_profile_id)
	case_definition.set_meta(&"generator_seed", result.seed_used)
	case_definition.set_meta(&"generator_version", result.generator_version)
	case_definition.set_meta(&"generation_profile_id", result.generation_profile_id)
	return case_definition


func _board_profile_is_supported(columns: int, rows: int) -> bool:
	return (columns == 3 and rows == 3) or (columns == 4 and rows == 4)


func _profile_is_supported(profile_id: StringName) -> bool:
	return profile_id == CaseGenerationRequest.PROFILE_TUTORIAL_EASY or profile_id == CaseGenerationRequest.PROFILE_NORMAL_FULL


func _roles_by_id(role_definitions: Array[RoleDefinition]) -> Dictionary:
	var roles: Dictionary = {}
	for role: RoleDefinition in role_definitions:
		if role != null and not String(role.role_id).is_empty():
			roles[role.role_id] = role
	return roles


func _logical_slots(slot_count: int) -> PackedInt32Array:
	var slots: PackedInt32Array = PackedInt32Array()
	for slot: int in range(slot_count):
		slots.append(slot)
	return slots


func _deterministic_permutation(source_slots: PackedInt32Array, rng: RandomNumberGenerator) -> PackedInt32Array:
	var slots: PackedInt32Array = source_slots.duplicate()
	for index: int in range(slots.size() - 1, 0, -1):
		var swap_index: int = rng.randi_range(0, index)
		var current: int = slots[index]
		slots[index] = slots[swap_index]
		slots[swap_index] = current
	return slots


func _deterministic_role_permutation(
	allowed_role_ids: Array[StringName],
	roles_by_id: Dictionary,
	rng: RandomNumberGenerator
) -> Array[RoleDefinition]:
	var roles: Array[RoleDefinition] = []
	for role_id: StringName in allowed_role_ids:
		var role: RoleDefinition = roles_by_id.get(role_id, null) as RoleDefinition
		if role != null and not _role_array_has_id(roles, role.role_id):
			roles.append(role)
	for index: int in range(roles.size() - 1, 0, -1):
		var swap_index: int = rng.randi_range(0, index)
		var current: RoleDefinition = roles[index]
		roles[index] = roles[swap_index]
		roles[swap_index] = current
	return roles


func _role_array_has_id(roles: Array[RoleDefinition], role_id: StringName) -> bool:
	for role: RoleDefinition in roles:
		if role != null and role.role_id == role_id:
			return true
	return false


func _case_suspected_role_ids(draft, allowed_role_ids: Array[StringName], rng: RandomNumberGenerator) -> Array[StringName]:
	var in_play: Dictionary = {}
	for suspect in draft.suspects:
		if suspect != null:
			in_play[suspect.true_role_id] = true
			in_play[suspect.displayed_role_id] = true
	var absent: Array[StringName] = []
	for role_id: StringName in allowed_role_ids:
		if not in_play.has(role_id) and not absent.has(role_id):
			absent.append(role_id)
	for index: int in range(absent.size() - 1, 0, -1):
		var swap_index: int = rng.randi_range(0, index)
		var current: StringName = absent[index]
		absent[index] = absent[swap_index]
		absent[swap_index] = current
	var red_herring_count: int = mini(absent.size(), 2 if draft.suspects.size() <= 6 else 1)
	var chosen: Dictionary = in_play.duplicate()
	for index: int in range(red_herring_count):
		chosen[absent[index]] = true
	var suspected: Array[StringName] = []
	for role_id: StringName in allowed_role_ids:
		if chosen.has(role_id) and not suspected.has(role_id):
			suspected.append(role_id)
	return suspected


func _hidden_draft(
	request: CaseGenerationRequest,
	logical_slots: PackedInt32Array,
	probe_slots: PackedInt32Array,
	role_order: Array[RoleDefinition]
):
	var draft = HIDDEN_CASE_DRAFT.new()
	draft.board_columns = request.board_columns
	draft.board_rows = request.board_rows
	draft.board_slot_count = request.board_slot_count
	draft.logical_board_slots = logical_slots.duplicate()

	var suspect_slots: PackedInt32Array = PackedInt32Array()
	var occupied_slots: Dictionary = {}
	for index: int in range(request.required_location_ids.size()):
		var slot: int = probe_slots[index]
		occupied_slots[slot] = true
		draft.board_tiles.append(GENERATED_BOARD_TILE.location(slot, request.required_location_ids[index]))
	for index: int in range(request.required_location_ids.size(), request.required_location_ids.size() + request.required_suspect_count):
		var slot: int = probe_slots[index]
		suspect_slots.append(slot)
	suspect_slots.sort()

	for index: int in range(suspect_slots.size()):
		var suspect_id: int = index + 1
		var slot: int = suspect_slots[index]
		occupied_slots[slot] = true
		var role: RoleDefinition = role_order[index]
		var suspect = GENERATED_SUSPECT.create(suspect_id, slot, role)
		draft.suspects.append(suspect)
		draft.board_tiles.append(GENERATED_BOARD_TILE.suspect(slot, suspect_id))
		if suspect.true_alignment == CaseEnums.Alignment.EVIL:
			draft.hidden_evil_suspect_ids.append(suspect_id)

	for slot: int in logical_slots:
		if not occupied_slots.has(slot):
			draft.board_tiles.append(GENERATED_BOARD_TILE.empty(slot))
	draft.board_tiles.sort_custom(_sort_generated_tiles_by_slot)
	draft.hidden_evil_suspect_ids.sort()
	return draft


func _assign_clock_tower(draft, rng: RandomNumberGenerator) -> bool:
	var tower_tile = null
	var empty_tiles: Array = []
	for tile in draft.board_tiles:
		if tile.tile_kind == TILE_LOCATION and tile.location_id == BoardLocationDefinition.LOCATION_CLOCK_TOWER:
			tower_tile = tile
		elif tile.tile_kind == TILE_EMPTY:
			empty_tiles.append(tile)
	if not draft.suspected_role_ids.has(&"clock_maker") and tower_tile == null:
		return true
	if tower_tile == null:
		if empty_tiles.is_empty():
			return false
		tower_tile = empty_tiles[rng.randi_range(0, empty_tiles.size() - 1)]
		tower_tile.tile_kind = TILE_LOCATION
		tower_tile.location_id = BoardLocationDefinition.LOCATION_CLOCK_TOWER
	draft.clock_tower_ring_hour = rng.randi_range(1, 23)
	return true


func _assign_pretend_roles(draft, roles_by_id: Dictionary, rng: RandomNumberGenerator) -> bool:
	for suspect in draft.suspects:
		if suspect == null or suspect.true_role_id == PRETEND_CAPABILITY.CRITIC_ROLE_ID or not PRETEND_CAPABILITY.is_pretender(suspect.true_role_id):
			continue
		var targets: Array[StringName] = []
		for other in draft.suspects:
			if other == null or other.suspect_id == suspect.suspect_id:
				continue
			var role: RoleDefinition = roles_by_id.get(other.true_role_id, null) as RoleDefinition
			if PRETEND_CAPABILITY.can_pretend_procedural(suspect.true_role_id, role):
				targets.append(other.true_role_id)
		if targets.is_empty():
			return false
		var target_role_id: StringName = targets[rng.randi_range(0, targets.size() - 1)]
		suspect.displayed_role_id = target_role_id
		suspect.impersonated_role_id = target_role_id
		suspect.is_impersonating = true
	return true


func _mobster_current_witnesses_are_valid(draft) -> bool:
	for source in draft.suspects:
		if source == null or not PRETEND_CAPABILITY.MOBSTER_ROLE_IDS.has(source.true_role_id):
			continue
		var witness_found: bool = false
		for candidate in draft.suspects:
			if (
				candidate != null
				and candidate.suspect_id != source.suspect_id
				and candidate.suspect_id != draft.barkeep_transform_target_suspect_id
				and candidate.true_role_id == source.displayed_role_id
			):
				witness_found = true
				break
		if not witness_found:
			return false
	return true


func _assign_critic_pretend(
	draft,
	roles_by_id: Dictionary,
	role_definitions: Array[RoleDefinition],
	rng: RandomNumberGenerator
) -> bool:
	var critic = null
	for suspect in draft.suspects:
		if suspect != null and suspect.true_role_id == PRETEND_CAPABILITY.CRITIC_ROLE_ID:
			critic = suspect
			break
	if critic == null:
		return true
	var case_definition: CaseDefinition = _case_definition_from_hidden_draft(draft)
	var runtime_state := CaseRuntimeState.new()
	var no_players: Array[PlayerCaseState] = []
	runtime_state.initialize(case_definition, no_players)
	if draft.barkeep_source_suspect_id > 0:
		var transform: BarkeepTransformationRecord = BarkeepTransformationService.new().resolve_transformation(
			case_definition, runtime_state, draft.barkeep_source_suspect_id,
			draft.barkeep_transform_target_suspect_id, role_definitions
		)
		if transform == null or not transform.applied:
			return false
	var fake_role_ids: Array[StringName] = []
	for role_id: StringName in draft.suspected_role_ids:
		var role: RoleDefinition = roles_by_id.get(role_id, null) as RoleDefinition
		if (
			role != null
			and PRETEND_CAPABILITY.can_pretend_procedural(PRETEND_CAPABILITY.CRITIC_ROLE_ID, role)
			and CaseRolePoolService.is_listed_current_role_absent(case_definition, runtime_state, role_id)
		):
			fake_role_ids.append(role_id)
	if fake_role_ids.is_empty():
		return false
	var fake_role_id: StringName = fake_role_ids[rng.randi_range(0, fake_role_ids.size() - 1)]
	critic.displayed_role_id = fake_role_id
	critic.impersonated_role_id = fake_role_id
	critic.is_impersonating = true
	return true


func _assign_poisoner_taint(draft, rng: RandomNumberGenerator) -> bool:
	var source_id: int = 0
	for suspect in draft.suspects:
		if suspect != null and suspect.true_role_id == &"poisoner":
			source_id = suspect.suspect_id
			break
	if source_id == 0:
		return true
	var case_definition: CaseDefinition = _case_definition_from_hidden_draft(draft)
	var eligible_ids: PackedInt32Array = PoisonerTaintService.new().eligible_taint_target_ids(case_definition, source_id)
	if eligible_ids.is_empty():
		return false
	draft.poisoner_source_suspect_id = source_id
	draft.poisoner_taint_target_suspect_id = eligible_ids[rng.randi_range(0, eligible_ids.size() - 1)]
	return true


func _assign_barkeep_transform(draft, allowed_role_ids: Array[StringName], roles: Array[RoleDefinition], rng: RandomNumberGenerator) -> bool:
	var source_id: int = 0
	var eligible_ids: PackedInt32Array = PackedInt32Array()
	for suspect in draft.suspects:
		if suspect == null:
			continue
		if suspect.true_role_id == &"barkeep":
			source_id = suspect.suspect_id
		elif suspect.role_group == CaseEnums.RoleGroup.CHINH_NHAN:
			eligible_ids.append(suspect.suspect_id)
	if source_id == 0:
		return true
	if eligible_ids.is_empty():
		return false
	var target_id: int = eligible_ids[rng.randi_range(0, eligible_ids.size() - 1)]
	var case_definition: CaseDefinition = _case_definition_from_hidden_draft(draft)
	var runtime_state := CaseRuntimeState.new()
	var no_players: Array[PlayerCaseState] = []
	runtime_state.initialize(case_definition, no_players)
	var transform: BarkeepTransformationRecord = BarkeepTransformationService.new().resolve_transformation(
		case_definition, runtime_state, source_id, target_id, roles
	)
	if transform == null or not transform.applied:
		return false
	var fake_ids: Array[StringName] = []
	for role_id: StringName in BarkeepTransformationService.new().drunkard_pretend_candidate_role_ids(
		case_definition, runtime_state, roles, allowed_role_ids
	):
		if PRETEND_CAPABILITY.is_supported_behavior(role_id):
			fake_ids.append(role_id)
	if fake_ids.is_empty():
		return false
	var fake_role_id: StringName = fake_ids[rng.randi_range(0, fake_ids.size() - 1)]
	for suspect in draft.suspects:
		if suspect != null and suspect.suspect_id == target_id:
			suspect.displayed_role_id = fake_role_id
			break
	draft.barkeep_source_suspect_id = source_id
	draft.barkeep_transform_target_suspect_id = target_id
	return true


func _assign_spectre_obscure(draft, rng: RandomNumberGenerator) -> bool:
	var source_id: int = 0
	for suspect in draft.suspects:
		if suspect != null and suspect.true_role_id == PRETEND_CAPABILITY.SPECTRE_ROLE_ID:
			source_id = suspect.suspect_id
			break
	if source_id == 0:
		return true
	var eligible_ids: PackedInt32Array = PackedInt32Array()
	for suspect in draft.suspects:
		if suspect == null:
			continue
		if suspect.role_group == CaseEnums.RoleGroup.HIEU_SU:
			continue
		if suspect.suspect_id == draft.barkeep_transform_target_suspect_id:
			continue
		eligible_ids.append(suspect.suspect_id)
	if eligible_ids.is_empty():
		return false
	draft.spectre_source_suspect_id = source_id
	draft.spectre_obscure_target_suspect_id = eligible_ids[rng.randi_range(0, eligible_ids.size() - 1)]
	return true


func _serial_killer_spawn_is_valid(draft, roles: Array[RoleDefinition]) -> bool:
	var source_id: int = 0
	for suspect in draft.suspects:
		if suspect != null and suspect.true_role_id == PRETEND_CAPABILITY.SERIAL_KILLER_ROLE_ID:
			source_id = suspect.suspect_id
			break
	if source_id == 0:
		return true
	var case_definition: CaseDefinition = _case_definition_from_hidden_draft(draft)
	return SERIAL_KILLER_TIMED_EVENT_SERVICE.new().serial_killer_spawn_requirement_met(
		case_definition, source_id, roles
	)


func _sort_generated_tiles_by_slot(a, b) -> bool:
	return a.board_slot < b.board_slot


func _hidden_draft_is_valid(draft) -> bool:
	if draft == null or draft.suspects.is_empty() or draft.hidden_evil_suspect_ids.is_empty():
		return false
	var has_good := false
	var has_evil := false
	var slots: Dictionary = {}
	var role_ids: Dictionary = {}
	var suspect_ids: Dictionary = {}
	var true_weatherman_id: int = 0
	var innocent_ids: Array[int] = []
	var meddler_count: int = 0
	var evil_group_count: int = 0
	for tile in draft.board_tiles:
		if tile == null or tile.board_slot < 0 or slots.has(tile.board_slot):
			return false
		slots[tile.board_slot] = true
	for suspect in draft.suspects:
		if suspect == null or suspect.suspect_id <= 0 or suspect_ids.has(suspect.suspect_id):
			return false
		suspect_ids[suspect.suspect_id] = suspect
		if role_ids.has(suspect.true_role_id):
			return false
		role_ids[suspect.true_role_id] = true
		if suspect.true_role_id == &"weatherman":
			true_weatherman_id = suspect.suspect_id
		if suspect.role_group == CaseEnums.RoleGroup.CHINH_NHAN:
			innocent_ids.append(suspect.suspect_id)
		elif suspect.role_group == CaseEnums.RoleGroup.HIEU_SU:
			meddler_count += 1
		elif suspect.role_group == CaseEnums.RoleGroup.TONG_PHAM or suspect.role_group == CaseEnums.RoleGroup.NGHICH_THAN:
			evil_group_count += 1
		if suspect.true_alignment == CaseEnums.Alignment.EVIL:
			has_evil = true
		else:
			has_good = true
	for evil_id: int in draft.hidden_evil_suspect_ids:
		var suspect = suspect_ids.get(evil_id, null)
		if suspect == null or suspect.true_alignment != CaseEnums.Alignment.EVIL:
			return false
	if draft.board_columns == 3 and draft.board_rows == 3 and evil_group_count > MAX_3X3_EVIL_COUNT:
		return false
	if true_weatherman_id != 0 and (meddler_count == 0 or evil_group_count == 0 or innocent_ids.size() < 2):
		return false
	return has_good and has_evil


func _generate_public_clues(draft, role_definitions: Array[RoleDefinition], suspected_role_ids: Array[StringName]) -> bool:
	if draft == null:
		return false
	if not _procedural_active_witnesses_are_valid(draft):
		return false
	var case_definition: CaseDefinition = _case_definition_from_hidden_draft(draft)
	case_definition.suspected_role_ids = suspected_role_ids.duplicate()
	var evaluator := RoleInformationEvaluationService.new()
	var runtime_state: CaseRuntimeState = null
	if draft.poisoner_source_suspect_id > 0 or draft.barkeep_source_suspect_id > 0:
		runtime_state = CaseRuntimeState.new()
		var no_players: Array[PlayerCaseState] = []
		runtime_state.initialize(case_definition, no_players)
	if draft.poisoner_source_suspect_id > 0:
		var taint: PoisonerTaintRecord = PoisonerTaintService.new().resolve_taint(
			case_definition, runtime_state, draft.poisoner_source_suspect_id, draft.poisoner_taint_target_suspect_id
		)
		if taint == null or not taint.applied:
			return false
	if draft.barkeep_source_suspect_id > 0:
		var transform: BarkeepTransformationRecord = BarkeepTransformationService.new().resolve_transformation(
			case_definition, runtime_state, draft.barkeep_source_suspect_id,
			draft.barkeep_transform_target_suspect_id, role_definitions
		)
		if transform == null or not transform.applied:
			return false
	draft.public_clues.clear()
	for suspect in draft.suspects:
		if suspect == null or (not PRETEND_CAPABILITY.is_supported_behavior(suspect.displayed_role_id) and suspect.displayed_role_id != &"clock_maker"):
			continue
		var result: InvestigationInformationResult = evaluator.evaluate(case_definition, suspect.suspect_id, role_definitions, {}, runtime_state)
		if result == null or result.payload_kind == InvestigationInformationResult.PayloadKind.NONE:
			return false
		if result.behavior_role_id == &"weatherman" and (result.payload_kind != InvestigationInformationResult.PayloadKind.WEATHER_REPORT or not result.weather_claim_complete):
			return false
		if result.behavior_role_id == &"mailman" and (String(result.in_play_role_id).is_empty() or String(result.not_in_play_role_id).is_empty()):
			return false
		var clue = GENERATED_PUBLIC_CLUE.from_information_result(result)
		if not _public_clue_references_are_valid(clue, draft):
			return false
		draft.public_clues.append(clue)
	return true


func _procedural_active_witnesses_are_valid(draft) -> bool:
	var suspect_ids: PackedInt32Array = PackedInt32Array()
	var current_role_ids_by_suspect: Dictionary = {}
	for suspect in draft.suspects:
		if suspect == null:
			continue
		suspect_ids.append(suspect.suspect_id)
		var current_role_id: StringName = suspect.true_role_id
		if suspect.suspect_id == draft.barkeep_transform_target_suspect_id:
			current_role_id = BarkeepTransformationService.DRUNKARD_ROLE_ID
		current_role_ids_by_suspect[suspect.suspect_id] = current_role_id
	for suspect in draft.suspects:
		if suspect == null or not PRETEND_CAPABILITY.is_pretender(suspect.true_role_id):
			continue
		if not PRETEND_CAPABILITY.procedural_current_native_witness_is_satisfied(
			suspect.suspect_id,
			suspect.displayed_role_id,
			suspect_ids,
			current_role_ids_by_suspect
		):
			return false
	return true


func _case_definition_from_hidden_draft(draft) -> CaseDefinition:
	var case_definition := CaseDefinition.new()
	case_definition.case_id = &"generated_hidden_draft"
	case_definition.data_version = 1
	case_definition.merit_pool = 0
	case_definition.reputation_penalty_on_wrong = 0
	case_definition.base_ticket_reward = 0
	case_definition.test_only_not_balance_locked = true
	case_definition.balance_note = "Generated candidate structural validation only; not balance locked."
	var reward: OnSolveReward = ON_SOLVE_REWARD.new()
	reward.reward_id = &"generated_candidate_reward"
	reward.reputation_delta = 0
	reward.test_only_not_balance_locked = true
	case_definition.on_solve = reward
	case_definition.set_meta(&"board_columns", draft.board_columns)
	case_definition.set_meta(&"board_rows", draft.board_rows)
	case_definition.set_meta(&"board_slot_count", draft.board_slot_count)
	case_definition.suspected_role_ids = draft.suspected_role_ids.duplicate()
	case_definition.startup_poisoner_source_suspect_id = draft.poisoner_source_suspect_id
	case_definition.startup_poisoner_target_suspect_id = draft.poisoner_taint_target_suspect_id
	case_definition.startup_barkeep_source_suspect_id = draft.barkeep_source_suspect_id
	case_definition.startup_barkeep_target_suspect_id = draft.barkeep_transform_target_suspect_id
	if draft.barkeep_source_suspect_id > 0:
		case_definition.nested_suspect_list_role_ids_by_parent = {&"barkeep": [&"drunkard"]}
	if draft.poisoner_source_suspect_id > 0:
		case_definition.set_meta(&"procedural_poisoner_clues", true)
	if draft.barkeep_source_suspect_id > 0:
		case_definition.set_meta(&"procedural_barkeep_clues", true)
	for suspect in draft.suspects:
		if suspect != null and suspect.true_role_id == PRETEND_CAPABILITY.CRITIC_ROLE_ID:
			case_definition.set_meta(&"procedural_critic_clues", true)
			break
	for tile in draft.board_tiles:
		if tile == null or tile.tile_kind != TILE_LOCATION:
			continue
		if tile.location_id == BoardLocationDefinition.LOCATION_CRIME_SCENE:
			var crime_scene := CrimeSceneDefinition.new()
			crime_scene.scene_id = &"generated_crime_scene"
			crime_scene.display_name = "HIỆN TRƯỜNG"
			crime_scene.board_slot = tile.board_slot
			case_definition.crime_scene = crime_scene
		elif tile.location_id == BoardLocationDefinition.LOCATION_CLOCK_TOWER:
			var tower := ClockTowerDefinition.new()
			tower.display_name = "Tháp Đồng Hồ"
			tower.board_slot = tile.board_slot
			tower.ring_hour = draft.clock_tower_ring_hour
			case_definition.board_locations.append(tower)
		else:
			var location := BoardLocationDefinition.new()
			location.location_id = tile.location_id
			location.display_name = String(tile.location_id)
			location.board_slot = tile.board_slot
			case_definition.board_locations.append(location)
	for generated_suspect in draft.suspects:
		if generated_suspect == null:
			continue
		var suspect := SuspectDefinition.new()
		suspect.suspect_id = generated_suspect.suspect_id
		suspect.board_slot = generated_suspect.board_slot
		suspect.true_role_id = generated_suspect.true_role_id
		suspect.displayed_role_id = generated_suspect.displayed_role_id
		suspect.impersonated_role_id = generated_suspect.impersonated_role_id
		suspect.is_impersonating = generated_suspect.is_impersonating
		suspect.true_alignment = generated_suspect.true_alignment
		suspect.role_group = generated_suspect.role_group
		if generated_suspect.suspect_id == draft.spectre_source_suspect_id:
			suspect.obscure_target_suspect_id = draft.spectre_obscure_target_suspect_id
		case_definition.suspects.append(suspect)
	case_definition.evil_suspect_ids = draft.hidden_evil_suspect_ids.duplicate()
	return case_definition


func _public_clue_references_are_valid(clue, draft) -> bool:
	if clue == null or draft == null:
		return false
	for suspect_id: int in clue.referenced_suspect_ids:
		if not _draft_has_suspect_id(draft, suspect_id):
			return false
	return true


func _draft_has_suspect_id(draft, suspect_id: int) -> bool:
	if draft == null:
		return false
	for suspect in draft.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return true
	return false


func _success_result(
	request: CaseGenerationRequest,
	logical_slots: PackedInt32Array,
	probe_slots: PackedInt32Array,
	draft,
	attempt_count: int
) -> CaseGenerationResult:
	var result := CaseGenerationResult.new()
	result.status = CaseGenerationResult.STATUS_SUCCESS
	result.seed_used = request.seed
	result.generator_version = request.generator_version
	result.board_columns = request.board_columns
	result.board_rows = request.board_rows
	result.board_slot_count = request.board_slot_count
	result.generation_profile_id = request.generation_profile_id
	result.allowed_role_ids = request.allowed_role_ids.duplicate()
	result.suspected_role_ids = draft.suspected_role_ids.duplicate()
	result.logical_board_slots = logical_slots
	result.probe_slot_sequence = probe_slots
	result.hidden_case_draft = draft
	result.generation_attempts = attempt_count
	result.draft_tiles = _legacy_draft_tiles(draft)
	result.assigned_hidden_role_ids = _assigned_hidden_role_ids(draft)
	result.fingerprint = _fingerprint(request, logical_slots, probe_slots, result.draft_tiles, draft)
	return result


func _legacy_draft_tiles(draft) -> Array[Dictionary]:
	var tiles: Array[Dictionary] = []
	if draft == null:
		return tiles
	for tile in draft.board_tiles:
		if tile == null:
			continue
		tiles.append({
			"slot": tile.board_slot,
			"tile_kind": tile.tile_kind,
			"location_id": tile.location_id,
			"suspect_index": tile.suspect_id,
		})
	return tiles


func _assigned_hidden_role_ids(draft) -> Array[StringName]:
	var ids: Array[StringName] = []
	if draft == null:
		return ids
	for suspect in draft.suspects:
		if suspect != null:
			ids.append(suspect.true_role_id)
	return ids


func _fingerprint(
	request: CaseGenerationRequest,
	logical_slots: PackedInt32Array,
	probe_slots: PackedInt32Array,
	draft_tiles: Array[Dictionary],
	draft
) -> String:
	return "casegen|%s|seed:%d|logical:%s|probe:%s|tiles:%s|%s" % [
		request.canonical_config_text(),
		request.seed,
		_join_ints(logical_slots),
		_join_ints(probe_slots),
		_join_tiles(draft_tiles),
		draft.fingerprint_text() if draft != null else "hidden:null",
	]


func _join_ints(values: PackedInt32Array) -> String:
	var parts: Array[String] = []
	for value: int in values:
		parts.append(str(value))
	return ",".join(parts)


func _join_tiles(tiles: Array[Dictionary]) -> String:
	var parts: Array[String] = []
	for tile: Dictionary in tiles:
		parts.append("%d:%s:%d" % [
			int(tile.get("slot", -1)),
			String(tile.get("tile_kind", &"")),
			int(tile.get("suspect_index", 0)),
		])
	return ",".join(parts)
