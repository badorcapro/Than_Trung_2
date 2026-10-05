class_name CaseRuntimeState
extends RefCounted

var case_id: StringName
var players: Array[PlayerCaseState] = []
var suspects: Array[SuspectRuntimeState] = []
var turn_order_player_ids: Array[StringName] = []
var current_turn_index := 0
var turn_number := 1
var accepts_investigation_actions := false
var action_log: Array[Dictionary] = []
var submissions: Array[CaseSubmission] = []
var public_function_records: Array[PublicFunctionRecord] = []
var private_role_knowledge: Array[PrivateRoleKnowledgeRecord] = []
var final_required_player_ids: Array[StringName] = []
var final_submissions: Array[CaseSubmission] = []
var final_results: Array[CaseSubmissionResult] = []
var final_correct_player_ids: Array[StringName] = []
var final_wrong_player_ids: Array[StringName] = []
var final_input_index := 0
var final_evaluation_count := 0
var case_outcome: CaseEnums.CaseOutcome = CaseEnums.CaseOutcome.IN_PROGRESS
var elapsed_hours: int = 0
var case_event_seed: int = 0
var applied_time_action_ids: Array[StringName] = []
var timed_events: Array[CaseTimedEventRuntimeState] = []
var poisoner_taint_records: Array[PoisonerTaintRecord] = []
var barkeep_transformation_records: Array[BarkeepTransformationRecord] = []
var next_log_sequence := 1
var is_initialized := false
var is_settled := false
var settlement_result: CaseSettlementResult
var truth_reveal: CaseTruthReveal


func initialize(case_definition: CaseDefinition, player_fixtures: Array[PlayerCaseState]) -> void:
	case_id = case_definition.case_id
	players.clear()
	for player_fixture in player_fixtures:
		var player_copy := player_fixture.duplicate(true) as PlayerCaseState
		player_copy.submission_status = CaseEnums.SubmissionStatus.NOT_SUBMITTED
		player_copy.is_active_in_investigation = true
		players.append(player_copy)
	suspects.clear()
	for suspect_definition in case_definition.suspects:
		suspects.append(SuspectRuntimeState.new(suspect_definition.suspect_id, suspect_definition.true_role_id))
	turn_order_player_ids.clear()
	current_turn_index = 0
	turn_number = 1
	accepts_investigation_actions = true
	action_log.clear()
	submissions.clear()
	public_function_records.clear()
	private_role_knowledge.clear()
	final_required_player_ids.clear()
	final_submissions.clear()
	final_results.clear()
	final_correct_player_ids.clear()
	final_wrong_player_ids.clear()
	final_input_index = 0
	final_evaluation_count = 0
	case_outcome = CaseEnums.CaseOutcome.IN_PROGRESS
	elapsed_hours = 0
	case_event_seed = _new_runtime_event_seed(case_id)
	if case_definition.test_only_not_balance_locked and case_definition.dev_runtime_event_seed >= 0:
		case_event_seed = case_definition.dev_runtime_event_seed
	applied_time_action_ids.clear()
	timed_events.clear()
	poisoner_taint_records.clear()
	barkeep_transformation_records.clear()
	next_log_sequence = 1
	is_initialized = true
	is_settled = false
	settlement_result = null
	truth_reveal = null


func apply_turn_snapshot(turn_manager: TurnManager) -> void:
	turn_order_player_ids = turn_manager.get_turn_order_ids()
	current_turn_index = turn_manager.current_turn_index
	turn_number = turn_manager.turn_number


func current_player_id() -> StringName:
	if turn_order_player_ids.is_empty() or current_turn_index < 0 or current_turn_index >= turn_order_player_ids.size():
		return &""
	return turn_order_player_ids[current_turn_index]


func current_final_player_id() -> StringName:
	if final_required_player_ids.is_empty():
		return &""
	if final_input_index < 0:
		final_input_index = 0
	for offset: int in range(final_required_player_ids.size()):
		var index: int = (final_input_index + offset) % final_required_player_ids.size()
		var player_id: StringName = final_required_player_ids[index]
		if _is_final_player_unresolved(player_id):
			final_input_index = index
			return player_id
	return &""


func advance_final_input() -> StringName:
	if final_required_player_ids.is_empty():
		final_input_index = 0
		return &""
	final_input_index = (final_input_index + 1) % final_required_player_ids.size()
	return current_final_player_id()


func find_final_submission(player_id: StringName) -> CaseSubmission:
	for submission in final_submissions:
		if submission.player_id == player_id:
			return submission
	return null


func final_resolved_player_count() -> int:
	var count: int = 0
	for player_id: StringName in final_required_player_ids:
		if not _is_final_player_unresolved(player_id):
			count += 1
	return count


func all_final_players_resolved() -> bool:
	return not final_required_player_ids.is_empty() and final_resolved_player_count() == final_required_player_ids.size()


func _is_final_player_unresolved(player_id: StringName) -> bool:
	var player: PlayerCaseState = find_player(player_id)
	return (
		player != null
		and player.is_active_in_investigation
		and player.submission_status == CaseEnums.SubmissionStatus.NOT_SUBMITTED
		and find_final_submission(player_id) == null
	)


func find_suspect(suspect_id: int) -> SuspectRuntimeState:
	for suspect in suspects:
		if suspect.suspect_id == suspect_id:
			return suspect
	return null


func original_true_role_id_for_suspect(case_definition: CaseDefinition, suspect_id: int) -> StringName:
	if case_definition == null:
		return &""
	for suspect_definition: SuspectDefinition in case_definition.suspects:
		if suspect_definition != null and suspect_definition.suspect_id == suspect_id:
			return suspect_definition.true_role_id
	return &""


func current_role_id_for_suspect(case_definition: CaseDefinition, suspect_id: int) -> StringName:
	var suspect_runtime: SuspectRuntimeState = find_suspect(suspect_id)
	if suspect_runtime != null and not String(suspect_runtime.current_role_id).is_empty():
		return suspect_runtime.current_role_id
	return original_true_role_id_for_suspect(case_definition, suspect_id)


func has_runtime_corruption(suspect_id: int) -> bool:
	var suspect_runtime: SuspectRuntimeState = find_suspect(suspect_id)
	return suspect_runtime != null and suspect_runtime.is_runtime_corrupted


func poisoner_record_for_source(source_suspect_id: int) -> PoisonerTaintRecord:
	for record: PoisonerTaintRecord in poisoner_taint_records:
		if record != null and record.source_suspect_id == source_suspect_id:
			return record
	return null


func barkeep_record_for_source(source_suspect_id: int) -> BarkeepTransformationRecord:
	for record: BarkeepTransformationRecord in barkeep_transformation_records:
		if record != null and record.source_suspect_id == source_suspect_id:
			return record
	return null


func find_player(player_id: StringName) -> PlayerCaseState:
	for player in players:
		if player.player_id == player_id:
			return player
	return null


func active_player_count() -> int:
	var count := 0
	for player in players:
		if player.is_active_in_investigation:
			count += 1
	return count


func lock_case_actions() -> void:
	accepts_investigation_actions = false


func advance_elapsed_hours(hours: int, source: StringName = &"") -> bool:
	if hours < 0:
		return false
	if hours == 0:
		return true
	elapsed_hours += hours
	append_time_log(hours, source)
	return true


func has_applied_time_action(action_id: StringName) -> bool:
	return action_id in applied_time_action_ids


func mark_time_action_applied(action_id: StringName) -> bool:
	if action_id == &"" or has_applied_time_action(action_id):
		return false
	applied_time_action_ids.append(action_id)
	return true


func timed_event_by_id(event_id: StringName) -> CaseTimedEventRuntimeState:
	for event: CaseTimedEventRuntimeState in timed_events:
		if event != null and event.event_id == event_id:
			return event
	return null


func ensure_timed_event(event_id: StringName, threshold_hour: int, source_suspect_id: int = 0) -> CaseTimedEventRuntimeState:
	var existing: CaseTimedEventRuntimeState = timed_event_by_id(event_id)
	if existing != null:
		return existing
	var event: CaseTimedEventRuntimeState = CaseTimedEventRuntimeState.new()
	event.event_id = event_id
	event.threshold_hour = threshold_hour
	event.source_suspect_id = source_suspect_id
	timed_events.append(event)
	return event


func investigated_count() -> int:
	var count := 0
	for suspect in suspects:
		if suspect.is_investigated:
			count += 1
	return count


func all_suspects_investigated() -> bool:
	return not suspects.is_empty() and investigated_count() == suspects.size()


func append_investigation_log(player_id: StringName, suspect_id: int, success: bool, public_role_id: StringName = &"", error_code: StringName = &"") -> void:
	action_log.append({
		"sequence": next_log_sequence,
		"turn_number": turn_number,
		"player_id": player_id,
		"action": "INVESTIGATE",
		"suspect_id": suspect_id,
		"success": success,
		"public_role_revealed": String(public_role_id) if success else "",
		"error_code": String(error_code) if not success else "",
	})
	next_log_sequence += 1


func append_function_revealed_log(suspect_id: int, available_from_turn: int) -> void:
	action_log.append({
		"sequence": next_log_sequence,
		"turn_number": turn_number,
		"action": "FUNCTION_REVEALED",
		"suspect_id": suspect_id,
		"available_from_turn": available_from_turn,
	})
	next_log_sequence += 1


func append_function_available_log(suspect_id: int, available_on_turn: int) -> void:
	action_log.append({
		"sequence": next_log_sequence,
		"turn_number": available_on_turn,
		"action": "FUNCTION_AVAILABLE",
		"suspect_id": suspect_id,
	})
	next_log_sequence += 1


func append_function_execution_log(player_id: StringName, owner_suspect_id: int, function_name: String, target_ids: PackedInt32Array, success: bool, public_result: String = "", error_code: StringName = &"") -> void:
	action_log.append({
		"sequence": next_log_sequence,
		"turn_number": turn_number,
		"player_id": player_id,
		"action": "FUNCTION_EXECUTE",
		"owner_suspect_id": owner_suspect_id,
		"function_name": function_name,
		"target_ids": target_ids.duplicate(),
		"success": success,
		"public_result": public_result if success else "",
		"error_code": String(error_code) if not success else "",
	})
	next_log_sequence += 1


func append_public_function_record(owner_suspect_id: int, function_name: String, target_ids: PackedInt32Array, player_id: StringName, public_result: String) -> PublicFunctionRecord:
	var record := PublicFunctionRecord.new()
	if not record.configure(public_function_records.size() + 1, owner_suspect_id, function_name, target_ids, player_id, turn_number, public_result):
		return null
	public_function_records.append(record)
	return record


func append_submission_log(player_id: StringName, correct: bool, outcome: CaseEnums.CaseOutcome) -> void:
	action_log.append({
		"sequence": next_log_sequence,
		"turn_number": turn_number,
		"player_id": player_id,
		"action": "EARLY_SUBMISSION",
		"success": true,
		"main_answer_correct": correct,
		"case_outcome": outcome,
	})
	next_log_sequence += 1


func append_single_accusation_log(player_id: StringName, suspect_id: int, correct: bool, outcome: CaseEnums.CaseOutcome) -> void:
	action_log.append({
		"sequence": next_log_sequence,
		"turn_number": turn_number,
		"player_id": player_id,
		"action": "SINGLE_SUSPECT_ACCUSATION",
		"suspect_id": suspect_id,
		"success": true,
		"correct": correct,
		"case_outcome": outcome,
	})
	next_log_sequence += 1


func correctly_accused_evil_ids_for_player(case_definition: CaseDefinition, player_id: StringName) -> PackedInt32Array:
	var ids := PackedInt32Array()
	if case_definition == null or player_id == &"":
		return ids
	for entry: Dictionary in action_log:
		if (
			StringName(String(entry.get("player_id", ""))) != player_id
			or String(entry.get("action", "")) != "SINGLE_SUSPECT_ACCUSATION"
			or not bool(entry.get("success", false))
			or not bool(entry.get("correct", false))
		):
			continue
		var suspect_id: int = int(entry.get("suspect_id", 0))
		for suspect: SuspectDefinition in case_definition.suspects:
			if (
				suspect != null
				and suspect.suspect_id == suspect_id
				and suspect.true_alignment == CaseEnums.Alignment.EVIL
				and suspect_id not in ids
			):
				ids.append(suspect_id)
				break
	ids.sort()
	return ids


func append_time_log(hours_added: int, source: StringName) -> void:
	action_log.append({
		"sequence": next_log_sequence,
		"turn_number": turn_number,
		"action": "CASE_TIME_ADVANCED",
		"hours_added": hours_added,
		"elapsed_hours": elapsed_hours,
		"source": String(source),
		"success": true,
	})
	next_log_sequence += 1


func append_kill_log(suspect_id: int, source: StringName, success: bool) -> void:
	action_log.append({
		"sequence": next_log_sequence,
		"turn_number": turn_number,
		"action": "KILL",
		"suspect_id": suspect_id,
		"source": String(source),
		"success": success,
	})
	next_log_sequence += 1


func append_timed_event_log(event: CaseTimedEventRuntimeState) -> void:
	if event == null:
		return
	action_log.append({
		"sequence": next_log_sequence,
		"turn_number": turn_number,
		"action": "TIMED_EVENT",
		"event_id": String(event.event_id),
		"threshold_hour": event.threshold_hour,
		"fired_at_hour": event.fired_at_hour,
		"source_suspect_id": event.source_suspect_id,
		"target_suspect_id": event.target_suspect_id,
		"success": event.resolved_success,
		"kill_attempted": event.kill_attempted,
		"kill_outcome": event.kill_outcome,
	})
	next_log_sequence += 1


func add_private_role_knowledge(player_id: StringName, suspect_id: int, true_role_id: StringName) -> PrivateRoleKnowledgeRecord:
	if String(player_id).is_empty() or find_suspect(suspect_id) == null or String(true_role_id).is_empty():
		return null
	for record in private_role_knowledge:
		if record != null and record.player_id == player_id and record.suspect_id == suspect_id:
			return record
	var record := PrivateRoleKnowledgeRecord.new()
	if not record.configure(player_id, suspect_id, true_role_id):
		return null
	private_role_knowledge.append(record)
	return record


func private_role_knowledge_for_player(player_id: StringName) -> Array[PrivateRoleKnowledgeRecord]:
	var records: Array[PrivateRoleKnowledgeRecord] = []
	for record in private_role_knowledge:
		if record != null and record.player_id == player_id:
			records.append(record)
	return records


func append_final_lock_log(player_id: StringName) -> void:
	action_log.append({"sequence": next_log_sequence, "turn_number": turn_number, "player_id": player_id, "action": "FINAL_VERDICT_LOCKED", "success": true})
	next_log_sequence += 1


func append_final_result_log(player_id: StringName, correct: bool) -> void:
	action_log.append({"sequence": next_log_sequence, "turn_number": turn_number, "player_id": player_id, "action": "FINAL_VERDICT_RESULT", "success": true, "main_answer_correct": correct})
	next_log_sequence += 1


func _stable_case_seed(value: StringName) -> int:
	var text: String = String(value)
	var seed: int = 17
	for index: int in range(text.length()):
		seed = seed * 31 + text.unicode_at(index)
	if seed < 0:
		seed = -seed
	return seed


func _new_runtime_event_seed(value: StringName) -> int:
	var seed: int = _stable_case_seed(value)
	var random_bytes: PackedByteArray = Crypto.new().generate_random_bytes(8)
	for byte: int in random_bytes:
		seed = int((seed * 257 + byte) & 0x7fffffff)
	if seed < 0:
		seed = -seed
	return seed
