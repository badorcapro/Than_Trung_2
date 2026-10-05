extends RefCounted

const DEBUG_HOME_PATH: String = "res://scenes/boot/DebugHome.tscn"
const SURGEON_EVENT_ID: StringName = &"surgeon_1_12h"


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var players: Array[PlayerCaseState] = FixtureRepository.load_players()
	var case_definition: CaseDefinition = FixtureRepository.load_hv6_resolution_timed_safety()
	_add(rows, "HV6 authored fixture validates", _fixture_valid(case_definition, roles, players))
	_add(rows, "HV6 board numbering and true Evil set are canonical", _board_and_truth_match(case_definition))
	_add(rows, "HV6 DebugHome entry resolves through normal Case runtime", _debug_entry_resolves())
	_add(rows, "HV6 deterministic Surgeon seed kills suspect 6 once at 12h", _surgeon_contract(case_definition, roles, players))
	_add(rows, "HV6 wrong accusation removes only the acting player", _wrong_accusation_contract(case_definition, players))
	_add(rows, "HV6 Scoundrel immunity uses only the acting player's Evil history", _scoundrel_contract(case_definition, players))
	_add(rows, "HV6 correct Conman accusation preserves private true-role secrecy", _conman_privacy_contract(case_definition, players))
	_add(rows, "HV6 dead Evil remains required by exact Evil-set resolution", _dead_evil_resolution_contract(case_definition, players))
	return rows


func _fixture_valid(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition],
	players: Array[PlayerCaseState]
) -> bool:
	if case_definition == null:
		return false
	var report: Dictionary = CaseDefinitionValidator.new().validate(case_definition, roles, players)
	return bool(report.get("passed", false))


func _board_and_truth_match(case_definition: CaseDefinition) -> bool:
	if case_definition == null or case_definition.crime_scene == null:
		return false
	var expected_slots: PackedInt32Array = PackedInt32Array([0, 1, 2, 3, 5, 6])
	for index: int in range(expected_slots.size()):
		var suspect: SuspectDefinition = case_definition.suspect_at_slot(expected_slots[index])
		if suspect == null or suspect.suspect_id != index + 1:
			return false
	var conman: SuspectDefinition = case_definition.suspect_at_slot(3)
	var scoundrel: SuspectDefinition = case_definition.suspect_at_slot(5)
	return (
		case_definition.crime_scene.board_slot == 4
		and case_definition.suspect_at_slot(7) == null
		and case_definition.suspect_at_slot(8) == null
		and case_definition.evil_suspect_ids == PackedInt32Array([4, 5])
		and case_definition.accomplice_suspect_ids == PackedInt32Array([4, 5])
		and case_definition.traitor_suspect_ids.is_empty()
		and _role_is(case_definition, 1, &"surgeon", CaseEnums.Alignment.GOOD)
		and _role_is(case_definition, 2, &"vigilante", CaseEnums.Alignment.GOOD)
		and conman != null and conman.true_role_id == &"conman"
		and conman.displayed_role_id == &"tutorial_priest"
		and conman.is_impersonating
		and scoundrel != null and scoundrel.true_role_id == &"tutorial_scoundrel"
	)


func _debug_entry_resolves() -> bool:
	var packed: PackedScene = load(DEBUG_HOME_PATH) as PackedScene
	if packed == null:
		return false
	var scene: Control = packed.instantiate() as Control
	if scene == null:
		return false
	var button: Button = scene.get_node_or_null("%Hv6ResolutionTimedSafetyButton") as Button
	var previous_path: String = AppFlow.pending_case_path
	var previous_definition: CaseDefinition = AppFlow.pending_case_definition
	AppFlow.pending_case_definition = null
	AppFlow.pending_case_path = FixtureRepository.HV6_RESOLUTION_TIMED_SAFETY_PATH
	var resolved: CaseDefinition = AppFlow.take_pending_case_definition()
	AppFlow.pending_case_path = previous_path
	AppFlow.pending_case_definition = previous_definition
	var passed: bool = (
		button != null
		and button.text == "HV6 — Resolution & Timed Safety"
		and scene.has_method("_on_hv6_resolution_timed_safety_pressed")
		and AppFlow.has_method("go_to_hv6_resolution_timed_safety")
		and AppFlow.VS_CASE_MAIN_SCENE == "res://scenes/case_gameplay/VSCaseMain.tscn"
		and resolved != null
		and resolved.case_id == &"hv6_resolution_timed_safety"
	)
	scene.free()
	return passed


func _surgeon_contract(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition],
	players: Array[PlayerCaseState]
) -> bool:
	var runtime: CaseRuntimeState = _fresh_runtime(case_definition, players)
	if (
		runtime == null
		or case_definition.dev_runtime_event_seed != 1
		or runtime.case_event_seed != case_definition.dev_runtime_event_seed
	):
		return false
	CaseClockService.new().advance_hours(runtime, 12, &"hv6_surgeon_threshold")
	var dispatcher: CaseTimedEventDispatcher = CaseTimedEventDispatcher.new()
	dispatcher.evaluate_all(case_definition, runtime, roles)
	var event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(SURGEON_EVENT_ID)
	var victim: SuspectRuntimeState = runtime.find_suspect(6)
	var first_log_count: int = _timed_event_log_count(runtime, SURGEON_EVENT_ID)
	dispatcher.evaluate_all(case_definition, runtime, roles)
	return (
		event != null and event.fired and event.resolved_success
		and event.fired_at_hour == 12 and event.source_suspect_id == 1
		and event.target_suspect_id == 6 and event.kill_attempted
		and event.kill_outcome == CaseKillResult.Outcome.KILLED
		and victim != null and victim.is_dead and victim.killed_by == &"surgeon"
		and first_log_count == 1
		and _timed_event_log_count(runtime, SURGEON_EVENT_ID) == 1
	)


func _wrong_accusation_contract(
	case_definition: CaseDefinition,
	players: Array[PlayerCaseState]
) -> bool:
	var runtime: CaseRuntimeState = _fresh_runtime(case_definition, players)
	if runtime == null:
		return false
	var player_one: PlayerCaseState = runtime.find_player(&"player_1")
	var wrong: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(
		case_definition, runtime, player_one, 3
	)
	var remaining_active: int = runtime.active_player_count()
	runtime.current_turn_index = 0
	var retry: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(
		case_definition, runtime, player_one, 4
	)
	return (
		wrong != null and wrong.success and not wrong.correct and wrong.player_inactivated
		and player_one != null and not player_one.is_active_in_investigation
		and remaining_active == 2
		and runtime.case_outcome == CaseEnums.CaseOutcome.IN_PROGRESS
		and retry != null and not retry.success and retry.error_code == &"PLAYER_INACTIVE"
	)


func _scoundrel_contract(
	case_definition: CaseDefinition,
	players: Array[PlayerCaseState]
) -> bool:
	var runtime: CaseRuntimeState = _fresh_runtime(case_definition, players)
	if runtime == null:
		return false
	var service := SingleSuspectAccusationService.new()
	var player_one: PlayerCaseState = runtime.find_player(&"player_1")
	var player_two: PlayerCaseState = runtime.find_player(&"player_2")
	var blocked: SingleSuspectAccusationResult = service.accuse(case_definition, runtime, player_one, 5)
	var scoundrel_runtime: SuspectRuntimeState = runtime.find_suspect(5)
	var blocked_left_unarrested: bool = scoundrel_runtime != null and not scoundrel_runtime.is_arrested
	runtime.current_turn_index = 1
	var other_player_correct: SingleSuspectAccusationResult = service.accuse(
		case_definition, runtime, player_two, 4
	)
	var conman_runtime: SuspectRuntimeState = runtime.find_suspect(4)
	runtime.current_turn_index = 0
	var still_blocked: SingleSuspectAccusationResult = service.accuse(
		case_definition, runtime, player_one, 5
	)
	var player_one_before: PackedInt32Array = runtime.correctly_accused_evil_ids_for_player(
		case_definition, player_one.player_id
	)
	var player_two_record: PackedInt32Array = runtime.correctly_accused_evil_ids_for_player(
		case_definition, player_two.player_id
	)
	var own_other_evil: SingleSuspectAccusationResult = service.accuse(
		case_definition, runtime, player_one, 4
	)
	var player_one_after: PackedInt32Array = runtime.correctly_accused_evil_ids_for_player(
		case_definition, player_one.player_id
	)
	var allowed: SingleSuspectAccusationResult = service.accuse(case_definition, runtime, player_one, 5)
	return (
		blocked != null and blocked.success and blocked.blocked_by_immunity
		and blocked.error_code == &"SCOUNDREL_IMMUNE"
		and blocked_left_unarrested
		and other_player_correct != null and other_player_correct.success and other_player_correct.correct
		and conman_runtime != null and not conman_runtime.is_arrested
		and still_blocked != null and still_blocked.success and still_blocked.blocked_by_immunity
		and player_one_before.is_empty()
		and player_two_record == PackedInt32Array([4])
		and own_other_evil != null and own_other_evil.success and own_other_evil.correct
		and player_one_after == PackedInt32Array([4])
		and scoundrel_runtime != null and not scoundrel_runtime.is_arrested
		and allowed != null and allowed.success and allowed.correct
		and not allowed.blocked_by_immunity
	)


func _conman_privacy_contract(
	case_definition: CaseDefinition,
	players: Array[PlayerCaseState]
) -> bool:
	var runtime: CaseRuntimeState = _fresh_runtime(case_definition, players)
	if runtime == null:
		return false
	var player_one: PlayerCaseState = runtime.find_player(&"player_1")
	var result: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(
		case_definition, runtime, player_one, 4
	)
	return (
		result != null and result.success and result.correct
		and result.private_true_role_id == &""
		and runtime.private_role_knowledge_for_player(&"player_1").is_empty()
		and not result.completed_evil_set
		and runtime.case_outcome == CaseEnums.CaseOutcome.IN_PROGRESS
	)


func _dead_evil_resolution_contract(
	case_definition: CaseDefinition,
	players: Array[PlayerCaseState]
) -> bool:
	var runtime: CaseRuntimeState = _fresh_runtime(case_definition, players)
	if runtime == null:
		return false
	var kill: CaseKillResult = CaseKillService.new().kill(case_definition, runtime, 4, &"vigilante")
	var resolution: CaseResolutionService = CaseResolutionService.new()
	return (
		kill != null and kill.success and runtime.find_suspect(4).is_dead
		and runtime.case_outcome == CaseEnums.CaseOutcome.IN_PROGRESS
		and resolution.unresolved_evil_ids(case_definition, runtime) == PackedInt32Array([4, 5])
		and not resolution.main_answer_correct(case_definition, runtime, PackedInt32Array([5]))
		and resolution.main_answer_correct(case_definition, runtime, PackedInt32Array([4, 5]))
		and ScoundrelImmunityService.can_be_killed_or_handled(case_definition, runtime, 5)
	)


func _fresh_runtime(
	case_definition: CaseDefinition,
	players: Array[PlayerCaseState]
) -> CaseRuntimeState:
	if case_definition == null:
		return null
	var runtime: CaseRuntimeState = CaseRuntimeState.new()
	runtime.initialize(case_definition, players)
	runtime.turn_order_player_ids.clear()
	runtime.turn_order_player_ids.append(&"player_1")
	runtime.turn_order_player_ids.append(&"player_2")
	runtime.turn_order_player_ids.append(&"player_3")
	return runtime


func _role_is(
	case_definition: CaseDefinition,
	suspect_id: int,
	role_id: StringName,
	alignment: CaseEnums.Alignment
) -> bool:
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect.true_role_id == role_id and suspect.true_alignment == alignment
	return false


func _timed_event_log_count(runtime: CaseRuntimeState, event_id: StringName) -> int:
	var count: int = 0
	for entry: Dictionary in runtime.action_log:
		if String(entry.get("action", "")) == "TIMED_EVENT" and StringName(entry.get("event_id", &"")) == event_id:
			count += 1
	return count


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "HV6 resolution and timed-safety human verification invariant",
	})
