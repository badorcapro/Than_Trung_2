extends RefCounted

const DEBUG_HOME_PATH: String = "res://scenes/boot/DebugHome.tscn"
const SERIAL_EVENT_ID: StringName = &"serial_killer_4_9h"
const TIMED_DISPATCHER := preload("res://scripts/domain/cases/CaseTimedEventDispatcher.gd")
const PRETEND_CAPABILITY := preload("res://scripts/domain/cases/CaseProceduralPretendCapability.gd")


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var players: Array[PlayerCaseState] = FixtureRepository.load_players()
	var case_definition: CaseDefinition = FixtureRepository.load_hv3_timed_coexistence()
	_add(rows, "HV3 authored fixture validates", _fixture_valid(case_definition, roles, players))
	_add(rows, "HV3 suspect numbering follows physical reading order", _numbering_matches(case_definition))
	_add(rows, "HV3 DebugHome entry resolves through normal Case runtime", _debug_entry_resolves())
	_add(rows, "HV3 Serial Killer keeps true, displayed, truth, and native-witness authority", _identity_contract_matches(case_definition, roles))
	_add(rows, "HV3 startup has exactly one deterministic adjacent Good target", _startup_target_is_deterministic(case_definition, roles))
	_add(rows, "HV3 borrowed LYING Tailor is consumed before 9h without advancing time", _active_first_contract(case_definition, roles))
	_add(rows, "HV3 9h timed kill fires independently after borrowed function use", _timed_event_after_active(case_definition, roles))
	_add(rows, "HV3 9h timed event persists once without same-threshold reroll", _same_threshold_does_not_reroll(case_definition, roles))
	_add(rows, "HV3 Full Reveal and exact Evil answer remain authoritative", _full_reveal_and_answer_match(case_definition, roles))
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


func _numbering_matches(case_definition: CaseDefinition) -> bool:
	if case_definition == null or case_definition.crime_scene == null:
		return false
	var expected_slots: PackedInt32Array = PackedInt32Array([0, 2, 3, 5, 6])
	for index: int in range(expected_slots.size()):
		var suspect: SuspectDefinition = case_definition.suspect_at_slot(expected_slots[index])
		if suspect == null or suspect.suspect_id != index + 1:
			return false
	return (
		case_definition.crime_scene.board_slot == 1
		and case_definition.suspect_at_slot(4) == null
		and case_definition.suspect_at_slot(7) == null
		and case_definition.suspect_at_slot(8) == null
	)


func _debug_entry_resolves() -> bool:
	var packed: PackedScene = load(DEBUG_HOME_PATH) as PackedScene
	if packed == null:
		return false
	var scene: Control = packed.instantiate() as Control
	if scene == null:
		return false
	var button: Button = scene.get_node_or_null("%Hv3TimedCoexistenceButton") as Button
	var previous_path: String = AppFlow.pending_case_path
	var previous_definition: CaseDefinition = AppFlow.pending_case_definition
	AppFlow.pending_case_definition = null
	AppFlow.pending_case_path = FixtureRepository.HV3_TIMED_COEXISTENCE_PATH
	var resolved: CaseDefinition = AppFlow.take_pending_case_definition()
	AppFlow.pending_case_path = previous_path
	AppFlow.pending_case_definition = previous_definition
	var passed: bool = (
		button != null
		and button.text == "HV3 — Timed Coexistence"
		and scene.has_method("_on_hv3_timed_coexistence_pressed")
		and AppFlow.has_method("go_to_hv3_timed_coexistence")
		and AppFlow.VS_CASE_MAIN_SCENE == "res://scenes/case_gameplay/VSCaseMain.tscn"
		and resolved != null
		and resolved.case_id == &"hv3_timed_coexistence"
	)
	scene.free()
	return passed


func _identity_contract_matches(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition]
) -> bool:
	var serial_killer: SuspectDefinition = _find_suspect(case_definition, 4)
	var native_tailor: SuspectDefinition = _find_suspect(case_definition, 1)
	var runtime: CaseRuntimeState = _fresh_runtime(case_definition)
	if serial_killer == null or native_tailor == null or runtime == null:
		return false
	var current_roles: Dictionary = {}
	var suspect_ids: PackedInt32Array = PackedInt32Array()
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect == null:
			continue
		suspect_ids.append(suspect.suspect_id)
		current_roles[suspect.suspect_id] = runtime.current_role_id_for_suspect(
			case_definition, suspect.suspect_id
		)
	return (
		serial_killer.true_role_id == &"serial_killer"
		and serial_killer.displayed_role_id == &"tailor"
		and serial_killer.impersonated_role_id == &"tailor"
		and serial_killer.is_impersonating
		and serial_killer.true_alignment == CaseEnums.Alignment.EVIL
		and serial_killer.role_group == CaseEnums.RoleGroup.TONG_PHAM
		and native_tailor.true_role_id == &"tailor"
		and RoleInformationEvaluationService.new().truth_mode_for_suspect_effective(
			case_definition, runtime, 4
		) == InvestigationInformationResult.TruthMode.LYING
		and PRETEND_CAPABILITY.procedural_current_native_witness_is_satisfied(
			4, &"tailor", suspect_ids, current_roles
		)
	)


func _startup_target_is_deterministic(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition]
) -> bool:
	var runtime: CaseRuntimeState = _fresh_runtime(case_definition)
	if runtime == null:
		return false
	var target_ids: PackedInt32Array = SerialKillerTimedEventService.new().eligible_adjacent_good_target_ids(
		case_definition, runtime, 4, roles
	)
	var adjacent: Array[SuspectDefinition] = CaseSpatialService.new().suspects_orthogonally_adjacent_to(
		case_definition, 4
	)
	return (
		target_ids == PackedInt32Array([2])
		and adjacent.size() == 1
		and adjacent[0] != null
		and adjacent[0].suspect_id == 2
		and adjacent[0].true_alignment == CaseEnums.Alignment.GOOD
	)


func _active_first_contract(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition]
) -> bool:
	var flow: Dictionary = _active_first_flow(case_definition, roles)
	var runtime: CaseRuntimeState = flow.get("runtime", null) as CaseRuntimeState
	var result: InteractiveFunctionResult = flow.get("function_result", null) as InteractiveFunctionResult
	var function_state: InteractiveFunctionRuntimeState = _function_state(runtime, 4)
	return (
		runtime != null and runtime.elapsed_hours == 2
		and result != null and result.success
		and result.public_result_type == InteractiveFunctionResult.PublicResultType.DIFFERENT_ALIGNMENT
		and result.public_result_text == "Khác phe"
		and function_state != null
		and function_state.state == InteractiveFunctionRuntimeState.State.EXHAUSTED
		and function_state.uses_remaining == 0
		and runtime.timed_event_by_id(SERIAL_EVENT_ID) == null
	)


func _timed_event_after_active(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition]
) -> bool:
	var flow: Dictionary = _flow_through_nine_hours(case_definition, roles)
	var runtime: CaseRuntimeState = flow.get("runtime", null) as CaseRuntimeState
	var accusation: SingleSuspectAccusationResult = flow.get("accusation", null) as SingleSuspectAccusationResult
	var event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(SERIAL_EVENT_ID) if runtime != null else null
	var target: SuspectRuntimeState = runtime.find_suspect(2) if runtime != null else null
	var function_state: InteractiveFunctionRuntimeState = _function_state(runtime, 4)
	return (
		runtime != null and runtime.elapsed_hours == 9
		and accusation != null and accusation.success and not accusation.correct
		and target != null and not target.is_arrested and target.is_dead
		and event != null and event.fired
		and event.threshold_hour == 9 and event.fired_at_hour == 9
		and event.source_suspect_id == 4 and event.target_suspect_id == 2
		and event.kill_attempted and event.resolved_success
		and event.kill_outcome == CaseKillResult.Outcome.KILLED
		and function_state != null
		and function_state.state == InteractiveFunctionRuntimeState.State.EXHAUSTED
		and function_state.uses_remaining == 0
	)


func _same_threshold_does_not_reroll(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition]
) -> bool:
	var flow: Dictionary = _flow_through_nine_hours(case_definition, roles)
	var runtime: CaseRuntimeState = flow.get("runtime", null) as CaseRuntimeState
	if runtime == null:
		return false
	var event_before: CaseTimedEventRuntimeState = runtime.timed_event_by_id(SERIAL_EVENT_ID)
	var log_count_before: int = _timed_event_log_count(runtime, SERIAL_EVENT_ID)
	TIMED_DISPATCHER.new().evaluate_all(case_definition, runtime, roles)
	var event_after: CaseTimedEventRuntimeState = runtime.timed_event_by_id(SERIAL_EVENT_ID)
	return (
		event_before != null and event_after == event_before
		and runtime.timed_events.size() == 1
		and event_after.target_suspect_id == 2
		and event_after.fired_at_hour == 9
		and _timed_event_log_count(runtime, SERIAL_EVENT_ID) == log_count_before
	)


func _full_reveal_and_answer_match(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition]
) -> bool:
	if case_definition == null:
		return false
	var runtime: CaseRuntimeState = _fresh_runtime(case_definition)
	runtime.is_settled = true
	runtime.settlement_result = CaseSettlementResult.new()
	runtime.settlement_result.success = true
	runtime.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
	var reveal: CaseTruthReveal = CaseTruthRevealBuilder.new().build(case_definition, runtime, roles)
	return (
		case_definition.evil_suspect_ids == PackedInt32Array([4, 5])
		and case_definition.accomplice_suspect_ids == PackedInt32Array([4, 5])
		and case_definition.traitor_suspect_ids.is_empty()
		and _truth_matches(reveal, 4, "Sát Nhân Hàng Loạt", "Thợ May", "Phe Ác", "Thuộc Hạ")
	)


func _active_first_flow(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition]
) -> Dictionary:
	var runtime: CaseRuntimeState = _fresh_runtime(case_definition)
	if runtime == null:
		return {"runtime": null, "function_result": null}
	for player: PlayerCaseState in runtime.players:
		runtime.turn_order_player_ids.append(player.player_id)
	var availability: FunctionAvailabilityService = FunctionAvailabilityService.new()
	availability.initialize_hidden_states(case_definition, runtime, roles)
	var owner: SuspectRuntimeState = runtime.find_suspect(4)
	if owner == null:
		return {"runtime": runtime, "function_result": null}
	owner.is_investigated = true
	CaseClockService.new().apply_action_time(
		runtime, &"hv3_investigate_4", CaseClockService.ACTION_INVESTIGATION
	)
	availability.reveal_for_suspect(case_definition, runtime, roles, 4, 1)
	availability.update_for_turn(runtime, 2)
	var result: InteractiveFunctionResult = InteractiveFunctionExecutionService.new().execute(
		case_definition, runtime, 4, PackedInt32Array([4, 5]), runtime.current_player_id()
	)
	CaseClockService.new().apply_action_time(
		runtime, &"hv3_active_4", CaseClockService.ACTION_ACTIVE_FUNCTION
	)
	return {"runtime": runtime, "function_result": result}


func _flow_through_nine_hours(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition]
) -> Dictionary:
	var flow: Dictionary = _active_first_flow(case_definition, roles)
	var runtime: CaseRuntimeState = flow.get("runtime", null) as CaseRuntimeState
	if runtime == null:
		return flow
	CaseClockService.new().advance_hours(runtime, 6, &"hv3_three_investigations")
	TIMED_DISPATCHER.new().evaluate_all(case_definition, runtime, roles)
	var current_player: PlayerCaseState = runtime.find_player(runtime.current_player_id())
	var accusation: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(
		case_definition, runtime, current_player, 2, CaseEnums.SubmissionPhase.EARLY
	)
	CaseClockService.new().apply_action_time(
		runtime, &"hv3_accuse_2", CaseClockService.ACTION_SINGLE_ACCUSATION
	)
	TIMED_DISPATCHER.new().evaluate_all(case_definition, runtime, roles)
	flow["accusation"] = accusation
	return flow


func _fresh_runtime(case_definition: CaseDefinition) -> CaseRuntimeState:
	if case_definition == null:
		return null
	var runtime: CaseRuntimeState = CaseRuntimeState.new()
	runtime.initialize(case_definition, FixtureRepository.load_players())
	return runtime


func _function_state(runtime: CaseRuntimeState, suspect_id: int) -> InteractiveFunctionRuntimeState:
	var suspect_runtime: SuspectRuntimeState = runtime.find_suspect(suspect_id) if runtime != null else null
	return suspect_runtime.interactive_function if suspect_runtime != null else null


func _timed_event_log_count(runtime: CaseRuntimeState, event_id: StringName) -> int:
	if runtime == null:
		return 0
	var count: int = 0
	for entry: Dictionary in runtime.action_log:
		if String(entry.get("action", "")) == "TIMED_EVENT" and StringName(entry.get("event_id", &"")) == event_id:
			count += 1
	return count


func _truth_matches(
	reveal: CaseTruthReveal,
	suspect_id: int,
	true_role_name: String,
	displayed_role_name: String,
	alignment_label: String,
	group_label: String
) -> bool:
	if reveal == null:
		return false
	for truth: SuspectTruthReveal in reveal.suspect_truths:
		if truth == null or truth.suspect_id != suspect_id:
			continue
		return (
			truth.true_role_name == true_role_name
			and truth.displayed_role_name == displayed_role_name
			and truth.alignment_label == alignment_label
			and truth.role_group_label == group_label
			and truth.is_impersonating
		)
	return false


func _find_suspect(case_definition: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	if case_definition == null:
		return null
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "HV3 Serial Killer timed-coexistence human verification invariant",
	})
