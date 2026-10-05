class_name FinalVerdictService
extends RefCounted

var submission_service := CaseSubmissionService.new()

func initialize(runtime_state: CaseRuntimeState) -> FinalVerdictResult:
	if runtime_state == null or runtime_state.case_outcome != CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT:
		return FinalVerdictResult.failed(&"FINAL_CONTEXT_INVALID", "Kỳ Án chưa ở giai đoạn Phán quyết cuối.")
	if not runtime_state.final_required_player_ids.is_empty():
		return _success(runtime_state.current_final_player_id())
	for player_id in runtime_state.turn_order_player_ids:
		var player: PlayerCaseState = runtime_state.find_player(player_id)
		if player != null and player.is_active_in_investigation and player.submission_status == CaseEnums.SubmissionStatus.NOT_SUBMITTED:
			runtime_state.final_required_player_ids.append(player_id)
	if runtime_state.final_required_player_ids.is_empty():
		return FinalVerdictResult.failed(&"FINAL_REQUIRED_PLAYERS_EMPTY", "Không có người chơi hợp lệ cho Phán quyết cuối.")
	runtime_state.final_input_index = 0
	return _success(runtime_state.current_final_player_id())

func lock_submission(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, submission: CaseSubmission) -> FinalVerdictResult:
	if runtime_state == null or runtime_state.case_outcome != CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT:
		return FinalVerdictResult.failed(&"FINAL_NOT_AWAITING", "Phán quyết cuối không nhận thêm đáp án.")
	if submission == null or submission.submission_phase != CaseEnums.SubmissionPhase.FINAL:
		return FinalVerdictResult.failed(&"FINAL_SUBMISSION_PHASE_INVALID", "Đáp án không thuộc Phán quyết cuối.")
	var expected_player_id: StringName = runtime_state.current_final_player_id()
	if expected_player_id == &"" or submission.player_id != expected_player_id:
		return FinalVerdictResult.failed(&"FINAL_PLAYER_NOT_CURRENT", "Không đúng người chơi đang nhập Phán quyết cuối.")
	if runtime_state.find_final_submission(submission.player_id) != null:
		return FinalVerdictResult.failed(&"FINAL_ALREADY_LOCKED", "Người chơi đã khóa Phán quyết cuối.")
	var structural_error: FinalVerdictResult = _validate_content(case_definition, submission)
	if structural_error != null:
		return structural_error
	if not submission.lock():
		return FinalVerdictResult.failed(&"FINAL_ALREADY_LOCKED", "Phán quyết đã bị khóa.")
	runtime_state.final_submissions.append(submission)
	var player: PlayerCaseState = runtime_state.find_player(submission.player_id)
	player.submission_status = CaseEnums.SubmissionStatus.FINAL_LOCKED_PENDING
	runtime_state.append_final_lock_log(submission.player_id)
	runtime_state.advance_final_input()
	var result: FinalVerdictResult = _success(submission.player_id)
	result.all_required_locked = runtime_state.all_final_players_resolved()
	if result.all_required_locked:
		_evaluate_all(case_definition, runtime_state)
		result.evaluation_performed = true
	return result

func _evaluate_all(case_definition: CaseDefinition, runtime_state: CaseRuntimeState) -> void:
	if runtime_state.final_evaluation_count > 0:
		return
	runtime_state.final_evaluation_count += 1
	for submission in runtime_state.final_submissions:
		var evaluation: CaseSubmissionResult = submission_service.evaluate_locked(case_definition, submission, runtime_state)
		runtime_state.final_results.append(evaluation)
		var player: PlayerCaseState = runtime_state.find_player(submission.player_id)
		player.submission_status = evaluation.submission_status
		if evaluation.main_answer_correct:
			runtime_state.final_correct_player_ids.append(submission.player_id)
		else:
			runtime_state.final_wrong_player_ids.append(submission.player_id)
		runtime_state.append_final_result_log(submission.player_id, evaluation.main_answer_correct)
	for player_id: StringName in runtime_state.final_required_player_ids:
		if runtime_state.find_final_submission(player_id) != null:
			continue
		var player: PlayerCaseState = runtime_state.find_player(player_id)
		if player != null and player.submission_status == CaseEnums.SubmissionStatus.SUBMITTED_WRONG:
			runtime_state.final_wrong_player_ids.append(player_id)
			runtime_state.append_final_result_log(player_id, false)
	runtime_state.case_outcome = CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED
	runtime_state.lock_case_actions()

func _validate_content(case_definition: CaseDefinition, submission: CaseSubmission) -> FinalVerdictResult:
	if case_definition == null:
		return FinalVerdictResult.failed(&"CASE_DEFINITION_INVALID", "Kỳ Án không hợp lệ.")
	for ids in [submission.selected_evil_ids, submission.underling_ids, submission.traitor_ids]:
		var seen: Dictionary = {}
		for suspect_id in ids:
			if seen.has(suspect_id): return FinalVerdictResult.failed(&"DUPLICATE_SUSPECT_ID", "Danh sách có nghi phạm trùng.")
			seen[suspect_id] = true
			if not _suspect_exists(case_definition, suspect_id): return FinalVerdictResult.failed(&"SUSPECT_NOT_FOUND", "Đáp án chứa nghi phạm không tồn tại.")
	for suspect_id in submission.underling_ids:
		if suspect_id not in submission.selected_evil_ids: return FinalVerdictResult.failed(&"CLASSIFICATION_OUTSIDE_EVIL_SELECTION", "Phân loại phải thuộc tập Phe Ác.")
	for suspect_id in submission.traitor_ids:
		if suspect_id not in submission.selected_evil_ids: return FinalVerdictResult.failed(&"CLASSIFICATION_OUTSIDE_EVIL_SELECTION", "Phân loại phải thuộc tập Phe Ác.")
		if suspect_id in submission.underling_ids: return FinalVerdictResult.failed(&"CLASSIFICATION_CONFLICT", "Một nghi phạm không thể thuộc hai phân loại.")
	return null

func _suspect_exists(case_definition: CaseDefinition, suspect_id: int) -> bool:
	for suspect in case_definition.suspects:
		if suspect != null and suspect.suspect_id == suspect_id: return true
	return false

func _success(player_id: StringName) -> FinalVerdictResult:
	var result: FinalVerdictResult = FinalVerdictResult.new()
	result.success = true
	result.player_id = player_id
	return result
