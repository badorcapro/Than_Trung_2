class_name SurgeonTimedEventService
extends RefCounted

const SURGEON_ROLE_IDS: Array[StringName] = [&"surgeon"]
const SURGEON_THRESHOLD_HOUR: int = 12


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
		if suspect == null or not _is_true_surgeon(suspect):
			continue
		var source_runtime: SuspectRuntimeState = runtime_state.find_suspect(suspect.suspect_id)
		if source_runtime == null or source_runtime.is_dead:
			continue
		var event_id: StringName = _event_id_for_surgeon(suspect.suspect_id)
		var event: CaseTimedEventRuntimeState = runtime_state.ensure_timed_event(event_id, SURGEON_THRESHOLD_HOUR, suspect.suspect_id)
		if not event.fired and runtime_state.elapsed_hours >= event.threshold_hour:
			_resolve_surgeon_event(case_definition, runtime_state, event, roles)
		events.append(event)
	return events


func _resolve_surgeon_event(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	event: CaseTimedEventRuntimeState,
	roles: Array[RoleDefinition]
) -> void:
	if not _deterministic_success(runtime_state.case_event_seed, event.event_id, event.source_suspect_id):
		if event.mark_fired(runtime_state.elapsed_hours, false, 0, false, CaseKillResult.Outcome.FAILED):
			runtime_state.append_timed_event_log(event)
		return
	var target: SuspectDefinition = _random_alive_current_innocent(case_definition, runtime_state, event, roles)
	if target == null:
		if event.mark_fired(runtime_state.elapsed_hours, false, 0, false, CaseKillResult.Outcome.FAILED):
			runtime_state.append_timed_event_log(event)
		return
	var kill_outcome: int = CaseKillResult.Outcome.FAILED
	var kill_result: CaseKillResult = CaseKillService.new().kill(case_definition, runtime_state, target.suspect_id, &"surgeon")
	kill_outcome = kill_result.outcome
	if event.mark_fired(runtime_state.elapsed_hours, true, target.suspect_id, true, kill_outcome):
		runtime_state.append_timed_event_log(event)


func _random_alive_current_innocent(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	event: CaseTimedEventRuntimeState,
	roles: Array[RoleDefinition]
) -> SuspectDefinition:
	var candidates: Array[SuspectDefinition] = []
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect == null:
			continue
		if suspect.suspect_id == event.source_suspect_id:
			continue
		var mutation_state: CaseMutationStateSnapshot = CaseMutationStateSnapshot.from_runtime(
			case_definition,
			runtime_state,
			suspect.suspect_id,
			roles
		)
		if mutation_state == null or mutation_state.current_role_group != CaseEnums.RoleGroup.CHINH_NHAN:
			continue
		var suspect_runtime: SuspectRuntimeState = runtime_state.find_suspect(suspect.suspect_id)
		if suspect_runtime != null and not suspect_runtime.is_dead:
			candidates.append(suspect)
	if candidates.is_empty():
		return null
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = _victim_selection_seed(runtime_state.case_event_seed, event.event_id, event.source_suspect_id)
	return candidates[rng.randi_range(0, candidates.size() - 1)]


func _deterministic_success(case_seed: int, event_id: StringName, source_suspect_id: int) -> bool:
	var value: int = case_seed + _stable_string_score(event_id) + source_suspect_id * 31
	if value < 0:
		value = -value
	return value % 2 == 0


func _victim_selection_seed(case_seed: int, event_id: StringName, source_suspect_id: int) -> int:
	var value: int = case_seed * 97 + _stable_string_score(event_id) + source_suspect_id * 53
	if value < 0:
		value = -value
	return value


func _stable_string_score(value: StringName) -> int:
	var text: String = String(value)
	var score: int = 23
	for index: int in range(text.length()):
		score = score * 37 + text.unicode_at(index)
	if score < 0:
		score = -score
	return score


func _is_true_surgeon(suspect: SuspectDefinition) -> bool:
	return (
		suspect.true_role_id in SURGEON_ROLE_IDS
		and suspect.role_group == CaseEnums.RoleGroup.HIEU_SU
	)


func _event_id_for_surgeon(suspect_id: int) -> StringName:
	return StringName("surgeon_%d_12h" % suspect_id)
