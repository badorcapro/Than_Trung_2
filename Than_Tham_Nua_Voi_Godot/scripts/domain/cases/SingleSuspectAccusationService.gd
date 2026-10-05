class_name SingleSuspectAccusationService
extends RefCounted

const SCOUNDREL_IMMUNITY_SERVICE := preload("res://scripts/domain/cases/ScoundrelImmunityService.gd")

var _resolution_service: CaseResolutionService = CaseResolutionService.new()
const CONMAN_ROLE_ID: StringName = &"conman"


func accuse(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, player: PlayerCaseState, suspect_id: int, phase: CaseEnums.SubmissionPhase = CaseEnums.SubmissionPhase.EARLY) -> SingleSuspectAccusationResult:
	var validation: SingleSuspectAccusationResult = _validate(case_definition, runtime_state, player, suspect_id, phase)
	if validation != null:
		return validation

	var suspect: SuspectDefinition = _find_suspect_definition(case_definition, suspect_id)
	if not SCOUNDREL_IMMUNITY_SERVICE.can_be_accused_by_player(
		case_definition, runtime_state, player.player_id, suspect_id
	):
		var blocked: SingleSuspectAccusationResult = SingleSuspectAccusationResult.immunity_blocked(
			player.player_id, suspect_id, phase
		)
		if phase == CaseEnums.SubmissionPhase.FINAL:
			runtime_state.advance_final_input()
		runtime_state.append_single_accusation_log(player.player_id, suspect_id, false, runtime_state.case_outcome)
		return blocked
	var result: SingleSuspectAccusationResult = SingleSuspectAccusationResult.new()
	result.success = true
	result.player_id = player.player_id
	result.suspect_id = suspect_id
	result.submission_phase = phase
	result.correct = suspect.true_alignment == CaseEnums.Alignment.EVIL
	if result.correct:
		if suspect.true_role_id != CONMAN_ROLE_ID:
			result.private_true_role_id = suspect.true_role_id
			runtime_state.add_private_role_knowledge(player.player_id, suspect_id, suspect.true_role_id)
		result.submitted_ids = _correctly_accused_evil_ids(case_definition, runtime_state, player.player_id)
		if suspect_id not in result.submitted_ids:
			result.submitted_ids.append(suspect_id)
			result.submitted_ids.sort()
		result.completed_evil_set = _sets_equal(result.submitted_ids, _resolution_service.unresolved_evil_ids(case_definition, runtime_state))
		if result.completed_evil_set:
			_lock_completed_submission(case_definition, runtime_state, player, result.submitted_ids, phase)
		elif phase == CaseEnums.SubmissionPhase.FINAL:
			runtime_state.advance_final_input()
	else:
		result.submitted_ids = PackedInt32Array([suspect_id])
		if phase == CaseEnums.SubmissionPhase.FINAL:
			_lock_completed_submission(case_definition, runtime_state, player, result.submitted_ids, phase)
		else:
			player.submission_status = CaseEnums.SubmissionStatus.SUBMITTED_WRONG
			player.is_active_in_investigation = false
		result.player_inactivated = true
		if phase == CaseEnums.SubmissionPhase.EARLY and runtime_state.active_player_count() == 0:
			runtime_state.case_outcome = CaseEnums.CaseOutcome.ALL_FAILED_EARLY
			runtime_state.lock_case_actions()
	runtime_state.append_single_accusation_log(player.player_id, suspect_id, result.correct, runtime_state.case_outcome)
	return result


func _validate(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, player: PlayerCaseState, suspect_id: int, phase: CaseEnums.SubmissionPhase) -> SingleSuspectAccusationResult:
	if case_definition == null or runtime_state == null or not runtime_state.is_initialized:
		return SingleSuspectAccusationResult.failed(&"", suspect_id, &"ACCUSATION_CONTEXT_INVALID", "Dữ liệu Chỉ Điểm không hợp lệ.")
	var valid_outcome: bool = runtime_state.case_outcome in [CaseEnums.CaseOutcome.IN_PROGRESS, CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS]
	if phase == CaseEnums.SubmissionPhase.FINAL:
		valid_outcome = runtime_state.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
	if not valid_outcome:
		return SingleSuspectAccusationResult.failed(player.player_id if player != null else &"", suspect_id, &"CASE_NOT_IN_PROGRESS", "Kỳ Án không còn nhận Chỉ Điểm.")
	if player == null or runtime_state.find_player(player.player_id) == null:
		return SingleSuspectAccusationResult.failed(&"", suspect_id, &"PLAYER_NOT_FOUND", "Không tìm thấy người chơi.")
	var expected_player_id: StringName = runtime_state.current_final_player_id() if phase == CaseEnums.SubmissionPhase.FINAL else runtime_state.current_player_id()
	if player.player_id != expected_player_id:
		return SingleSuspectAccusationResult.failed(player.player_id, suspect_id, &"PLAYER_NOT_CURRENT", "Chỉ người đang lượt được Chỉ Điểm.")
	if not player.is_active_in_investigation:
		return SingleSuspectAccusationResult.failed(player.player_id, suspect_id, &"PLAYER_INACTIVE", "Người chơi đã rời giai đoạn điều tra.")
	if player.submission_status != CaseEnums.SubmissionStatus.NOT_SUBMITTED:
		return SingleSuspectAccusationResult.failed(player.player_id, suspect_id, &"PLAYER_ALREADY_SUBMITTED", "Người chơi đã Trình Án.")
	var suspect_runtime: SuspectRuntimeState = runtime_state.find_suspect(suspect_id)
	if _find_suspect_definition(case_definition, suspect_id) == null or suspect_runtime == null:
		return SingleSuspectAccusationResult.failed(player.player_id, suspect_id, &"SUSPECT_NOT_FOUND", "Chỉ Điểm phải chọn một nghi phạm hợp lệ.")
	return null


func _find_suspect_definition(case_definition: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	if case_definition == null:
		return null
	for suspect in case_definition.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null


func _correctly_accused_evil_ids(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, player_id: StringName) -> PackedInt32Array:
	var ids: PackedInt32Array = _resolution_service.unresolved_known_evil_ids(case_definition, runtime_state, player_id)
	if case_definition == null or runtime_state == null:
		return ids
	var unresolved: PackedInt32Array = _resolution_service.unresolved_evil_ids(case_definition, runtime_state)
	for entry: Dictionary in runtime_state.action_log:
		if (
			StringName(String(entry.get("player_id", ""))) == player_id
			and String(entry.get("action", "")) == "SINGLE_SUSPECT_ACCUSATION"
			and bool(entry.get("correct", false))
		):
			var suspect_id: int = int(entry.get("suspect_id", 0))
			if suspect_id in unresolved and suspect_id not in ids:
				ids.append(suspect_id)
	ids.sort()
	return ids


func _lock_completed_submission(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, player: PlayerCaseState, selected_ids: PackedInt32Array, phase: CaseEnums.SubmissionPhase) -> void:
	var submission: CaseSubmission = CaseSubmission.new()
	submission.configure(player.player_id, runtime_state.turn_number, selected_ids, PackedInt32Array(), PackedInt32Array(), phase)
	if not submission.lock():
		return
	if phase == CaseEnums.SubmissionPhase.EARLY:
		runtime_state.submissions.append(submission)
		player.submission_status = CaseEnums.SubmissionStatus.SUBMITTED_CORRECT
		runtime_state.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
		for other_player: PlayerCaseState in runtime_state.players:
			if other_player.submission_status == CaseEnums.SubmissionStatus.NOT_SUBMITTED:
				other_player.submission_status = CaseEnums.SubmissionStatus.NOT_SUBMITTED_CASE_ENDED
		runtime_state.lock_case_actions()
		runtime_state.append_submission_log(player.player_id, true, runtime_state.case_outcome)
		return
	if runtime_state.find_final_submission(player.player_id) == null:
		runtime_state.final_submissions.append(submission)
	player.submission_status = CaseEnums.SubmissionStatus.FINAL_LOCKED_PENDING
	runtime_state.append_final_lock_log(player.player_id)
	runtime_state.advance_final_input()
	if runtime_state.all_final_players_resolved():
		FinalVerdictService.new()._evaluate_all(case_definition, runtime_state)


func _sets_equal(first: PackedInt32Array, second: PackedInt32Array) -> bool:
	if first.size() != second.size():
		return false
	for value: int in first:
		if value not in second:
			return false
	return true
