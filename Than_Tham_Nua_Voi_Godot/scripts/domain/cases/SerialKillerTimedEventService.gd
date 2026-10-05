class_name SerialKillerTimedEventService
extends RefCounted

const SERIAL_KILLER_ROLE_ID: StringName = &"serial_killer"
const INTERVAL_HOURS: int = 9
const CASE_ROLE_POOL_SERVICE := preload("res://scripts/domain/cases/CaseRolePoolService.gd")
const POISONER_TAINT_SERVICE := preload("res://scripts/domain/cases/PoisonerTaintService.gd")
const PRETEND_CAPABILITY := preload("res://scripts/domain/cases/CaseProceduralPretendCapability.gd")
const BARKEEP_TRANSFORMATION_SERVICE := preload("res://scripts/domain/cases/BarkeepTransformationService.gd")


func evaluate(case_definition: CaseDefinition, runtime_state: CaseRuntimeState) -> Array[CaseTimedEventRuntimeState]:
	var roles: Array[RoleDefinition] = []
	return _evaluate(case_definition, runtime_state, roles)


func evaluate_with_roles(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	roles: Array[RoleDefinition]
) -> Array[CaseTimedEventRuntimeState]:
	return _evaluate(case_definition, runtime_state, roles)


func _evaluate(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	roles: Array[RoleDefinition]
) -> Array[CaseTimedEventRuntimeState]:
	var events: Array[CaseTimedEventRuntimeState] = []
	if case_definition == null or runtime_state == null or not runtime_state.is_initialized:
		return events
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect == null or not _is_current_serial_killer(case_definition, runtime_state, suspect.suspect_id):
			continue
		for threshold_hour: int in _due_thresholds(runtime_state.elapsed_hours):
			var event_id: StringName = _event_id_for_serial_killer(suspect.suspect_id, threshold_hour)
			var event: CaseTimedEventRuntimeState = runtime_state.ensure_timed_event(event_id, threshold_hour, suspect.suspect_id)
			if not event.fired:
				_resolve_serial_killer_event(case_definition, runtime_state, event, roles)
			events.append(event)
	return events


func _resolve_serial_killer_event(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	event: CaseTimedEventRuntimeState,
	roles: Array[RoleDefinition]
) -> void:
	if _source_suppressed(case_definition, runtime_state, event.source_suspect_id):
		if event.mark_fired(runtime_state.elapsed_hours, false, 0, false, CaseKillResult.Outcome.FAILED):
			runtime_state.append_timed_event_log(event)
		return
	var target: SuspectDefinition = _random_adjacent_good_target(case_definition, runtime_state, event, roles)
	if target == null:
		if event.mark_fired(runtime_state.elapsed_hours, false, 0, false, CaseKillResult.Outcome.FAILED):
			runtime_state.append_timed_event_log(event)
		return
	var kill_result: CaseKillResult = CaseKillService.new().kill(case_definition, runtime_state, target.suspect_id, &"serial_killer")
	var resolved: bool = kill_result.outcome == CaseKillResult.Outcome.KILLED
	if event.mark_fired(runtime_state.elapsed_hours, resolved, target.suspect_id, true, kill_result.outcome):
		runtime_state.append_timed_event_log(event)


func _random_adjacent_good_target(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	event: CaseTimedEventRuntimeState,
	roles: Array[RoleDefinition]
) -> SuspectDefinition:
	var candidates: Array[SuspectDefinition] = _eligible_adjacent_good_targets(case_definition, runtime_state, event.source_suspect_id, roles)
	if candidates.is_empty():
		return null
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = _victim_selection_seed(runtime_state.case_event_seed, event.event_id, event.source_suspect_id, event.threshold_hour)
	return candidates[rng.randi_range(0, candidates.size() - 1)]


func eligible_adjacent_good_target_ids(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	source_suspect_id: int,
	roles: Array[RoleDefinition] = []
) -> PackedInt32Array:
	var ids: PackedInt32Array = PackedInt32Array()
	for suspect: SuspectDefinition in _eligible_adjacent_good_targets(case_definition, runtime_state, source_suspect_id, roles):
		ids.append(suspect.suspect_id)
	ids.sort()
	return ids


func serial_killer_spawn_requirement_met(
	case_definition: CaseDefinition,
	source_suspect_id: int,
	roles: Array[RoleDefinition] = []
) -> bool:
	var source: SuspectDefinition = _find_suspect(case_definition, source_suspect_id)
	if source == null:
		return false
	var runtime_state: CaseRuntimeState = _startup_runtime(case_definition, roles)
	var spatial: CaseSpatialService = CaseSpatialService.new()
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect == null or suspect.suspect_id == source_suspect_id:
			continue
		var mutation_state: CaseMutationStateSnapshot = CaseMutationStateSnapshot.from_runtime(
			case_definition,
			runtime_state,
			suspect.suspect_id,
			roles
		)
		if mutation_state != null and mutation_state.current_role_group == CaseEnums.RoleGroup.CHINH_NHAN and spatial.are_orthogonally_adjacent(source.board_slot, suspect.board_slot):
			return true
	return false


func pretend_role_is_valid(case_definition: CaseDefinition, pretend_role_id: StringName) -> bool:
	return (
		pretend_role_id in CASE_ROLE_POOL_SERVICE.suspected_role_candidates(case_definition, SERIAL_KILLER_ROLE_ID)
		and PRETEND_CAPABILITY.serial_killer_can_pretend(pretend_role_id)
	)


func _eligible_adjacent_good_targets(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	source_suspect_id: int,
	roles: Array[RoleDefinition]
) -> Array[SuspectDefinition]:
	var candidates: Array[SuspectDefinition] = []
	if case_definition == null or runtime_state == null:
		return candidates
	for suspect: SuspectDefinition in CaseSpatialService.new().suspects_orthogonally_adjacent_to(case_definition, source_suspect_id):
		if suspect == null or suspect.suspect_id == source_suspect_id:
			continue
		var mutation_state: CaseMutationStateSnapshot = CaseMutationStateSnapshot.from_runtime(
			case_definition,
			runtime_state,
			suspect.suspect_id,
			roles
		)
		if mutation_state == null or mutation_state.current_alignment != CaseEnums.Alignment.GOOD:
			continue
		var suspect_runtime: SuspectRuntimeState = runtime_state.find_suspect(suspect.suspect_id)
		if suspect_runtime != null and not suspect_runtime.is_dead:
			candidates.append(suspect)
	return candidates


func _startup_runtime(case_definition: CaseDefinition, roles: Array[RoleDefinition]) -> CaseRuntimeState:
	var runtime_state: CaseRuntimeState = CaseRuntimeState.new()
	var players: Array[PlayerCaseState] = []
	runtime_state.initialize(case_definition, players)
	if case_definition.startup_barkeep_source_suspect_id > 0 and case_definition.startup_barkeep_target_suspect_id > 0:
		BARKEEP_TRANSFORMATION_SERVICE.new().resolve_transformation(
			case_definition,
			runtime_state,
			case_definition.startup_barkeep_source_suspect_id,
			case_definition.startup_barkeep_target_suspect_id,
			roles
		)
	return runtime_state


func _source_suppressed(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, source_suspect_id: int) -> bool:
	var source_runtime: SuspectRuntimeState = runtime_state.find_suspect(source_suspect_id)
	return (
		source_runtime == null
		or source_runtime.is_dead
		or source_runtime.is_arrested
		or POISONER_TAINT_SERVICE.is_effectively_corrupted(case_definition, runtime_state, source_suspect_id)
	)


func _is_current_serial_killer(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, suspect_id: int) -> bool:
	return runtime_state.current_role_id_for_suspect(case_definition, suspect_id) == SERIAL_KILLER_ROLE_ID


func _due_thresholds(elapsed_hours: int) -> PackedInt32Array:
	var thresholds: PackedInt32Array = PackedInt32Array()
	if elapsed_hours < INTERVAL_HOURS:
		return thresholds
	var threshold_hour: int = INTERVAL_HOURS
	while threshold_hour <= elapsed_hours:
		thresholds.append(threshold_hour)
		threshold_hour += INTERVAL_HOURS
	return thresholds


func _event_id_for_serial_killer(suspect_id: int, threshold_hour: int) -> StringName:
	return StringName("serial_killer_%d_%dh" % [suspect_id, threshold_hour])


func _victim_selection_seed(case_seed: int, event_id: StringName, source_suspect_id: int, threshold_hour: int) -> int:
	var value: int = case_seed * 131 + _stable_string_score(event_id) + source_suspect_id * 41 + threshold_hour * 17
	if value < 0:
		value = -value
	return value


func _stable_string_score(value: StringName) -> int:
	var text: String = String(value)
	var score: int = 29
	for index: int in range(text.length()):
		score = score * 39 + text.unicode_at(index)
	if score < 0:
		score = -score
	return score


func _find_suspect(case_definition: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	if case_definition == null:
		return null
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null
