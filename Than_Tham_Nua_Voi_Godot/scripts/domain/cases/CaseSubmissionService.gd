class_name CaseSubmissionService
extends RefCounted

var _resolution_service: CaseResolutionService = CaseResolutionService.new()


func submit(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, player: PlayerCaseState, submission: CaseSubmission) -> CaseSubmissionResult:
	var validation := _validate(case_definition, runtime_state, player, submission)
	if validation != null:
		return validation
	var result := CaseSubmissionResult.new()
	result.success = true
	result.player_id = player.player_id
	result.submitted_on_turn = submission.submitted_on_turn
	result.main_answer_correct = _resolution_service.main_answer_correct(case_definition, runtime_state, submission.selected_evil_ids)
	result.underling_classification_correct = _resolution_service.underling_classification_correct(case_definition, runtime_state, submission.underling_ids)
	result.traitor_classification_correct = _resolution_service.traitor_classification_correct(case_definition, runtime_state, submission.traitor_ids)
	submission.lock()
	runtime_state.submissions.append(submission)
	if result.main_answer_correct:
		player.submission_status = CaseEnums.SubmissionStatus.SUBMITTED_CORRECT
		result.submission_status = CaseEnums.SubmissionStatus.SUBMITTED_CORRECT
		runtime_state.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
		for other_player in runtime_state.players:
			if other_player.submission_status == CaseEnums.SubmissionStatus.NOT_SUBMITTED:
				other_player.submission_status = CaseEnums.SubmissionStatus.NOT_SUBMITTED_CASE_ENDED
		runtime_state.lock_case_actions()
	else:
		player.submission_status = CaseEnums.SubmissionStatus.SUBMITTED_WRONG
		player.is_active_in_investigation = false
		result.submission_status = CaseEnums.SubmissionStatus.SUBMITTED_WRONG
		if runtime_state.active_player_count() == 0:
			runtime_state.case_outcome = CaseEnums.CaseOutcome.ALL_FAILED_EARLY
			runtime_state.lock_case_actions()
	runtime_state.append_submission_log(player.player_id, result.main_answer_correct, runtime_state.case_outcome)
	return result


func evaluate_locked(case_definition: CaseDefinition, submission: CaseSubmission, runtime_state: CaseRuntimeState = null) -> CaseSubmissionResult:
	if case_definition == null or submission == null or not submission.is_locked:
		return CaseSubmissionResult.failed(&"", 0, &"FINAL_SUBMISSION_INVALID", "Phán quyết đã khóa không hợp lệ.")
	var result := CaseSubmissionResult.new()
	result.success = true
	result.player_id = submission.player_id
	result.submitted_on_turn = submission.submitted_on_turn
	result.main_answer_correct = _resolution_service.main_answer_correct(case_definition, runtime_state, submission.selected_evil_ids)
	result.underling_classification_correct = _resolution_service.underling_classification_correct(case_definition, runtime_state, submission.underling_ids)
	result.traitor_classification_correct = _resolution_service.traitor_classification_correct(case_definition, runtime_state, submission.traitor_ids)
	result.submission_status = CaseEnums.SubmissionStatus.SUBMITTED_CORRECT if result.main_answer_correct else CaseEnums.SubmissionStatus.SUBMITTED_WRONG
	return result


func _validate(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, player: PlayerCaseState, submission: CaseSubmission) -> CaseSubmissionResult:
	if case_definition == null or runtime_state == null or not runtime_state.is_initialized or submission == null:
		return CaseSubmissionResult.failed(&"", 0, &"SUBMISSION_CONTEXT_INVALID", "Dữ liệu Trình Án không hợp lệ.")
	if runtime_state.case_outcome not in [CaseEnums.CaseOutcome.IN_PROGRESS, CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS]:
		return CaseSubmissionResult.failed(submission.player_id, submission.submitted_on_turn, &"CASE_NOT_IN_PROGRESS", "Kỳ Án không còn nhận Trình Án sớm.")
	if submission.submission_phase != CaseEnums.SubmissionPhase.EARLY:
		return CaseSubmissionResult.failed(submission.player_id, submission.submitted_on_turn, &"SUBMISSION_PHASE_INVALID", "Đáp án không thuộc Trình Án sớm.")
	if player == null or runtime_state.find_player(player.player_id) == null:
		return CaseSubmissionResult.failed(submission.player_id, submission.submitted_on_turn, &"PLAYER_NOT_FOUND", "Không tìm thấy người chơi.")
	if player.player_id != runtime_state.current_player_id() or submission.player_id != player.player_id:
		return CaseSubmissionResult.failed(submission.player_id, submission.submitted_on_turn, &"PLAYER_NOT_CURRENT", "Chỉ người đang lượt được Trình Án.")
	if not player.is_active_in_investigation:
		return CaseSubmissionResult.failed(player.player_id, submission.submitted_on_turn, &"PLAYER_INACTIVE", "Người chơi đã rời giai đoạn điều tra.")
	if player.submission_status != CaseEnums.SubmissionStatus.NOT_SUBMITTED:
		return CaseSubmissionResult.failed(player.player_id, submission.submitted_on_turn, &"PLAYER_ALREADY_SUBMITTED", "Người chơi đã Trình Án.")
	if submission.is_locked:
		return CaseSubmissionResult.failed(player.player_id, submission.submitted_on_turn, &"SUBMISSION_ALREADY_LOCKED", "Đáp án đã bị khóa.")
	for ids in [submission.selected_evil_ids, submission.underling_ids, submission.traitor_ids]:
		if _has_duplicates(ids):
			return CaseSubmissionResult.failed(player.player_id, submission.submitted_on_turn, &"DUPLICATE_SUSPECT_ID", "Danh sách có nghi phạm trùng.")
		for suspect_id in ids:
			if not _suspect_exists(case_definition, suspect_id):
				return CaseSubmissionResult.failed(player.player_id, submission.submitted_on_turn, &"SUSPECT_NOT_FOUND", "Đáp án chứa nghi phạm không tồn tại.")
	for suspect_id in submission.underling_ids:
		if suspect_id not in submission.selected_evil_ids:
			return CaseSubmissionResult.failed(player.player_id, submission.submitted_on_turn, &"CLASSIFICATION_OUTSIDE_EVIL_SELECTION", "Phân loại phải nằm trong tập Phe Ác đã chọn.")
	for suspect_id in submission.traitor_ids:
		if suspect_id not in submission.selected_evil_ids:
			return CaseSubmissionResult.failed(player.player_id, submission.submitted_on_turn, &"CLASSIFICATION_OUTSIDE_EVIL_SELECTION", "Phân loại phải nằm trong tập Phe Ác đã chọn.")
		if suspect_id in submission.underling_ids:
			return CaseSubmissionResult.failed(player.player_id, submission.submitted_on_turn, &"CLASSIFICATION_CONFLICT", "Một nghi phạm không thể thuộc hai phân loại.")
	return null


func _sets_equal(first: PackedInt32Array, second: PackedInt32Array) -> bool:
	if first.size() != second.size():
		return false
	for value in first:
		if value not in second:
			return false
	return true


func _has_duplicates(values: PackedInt32Array) -> bool:
	var seen: Dictionary = {}
	for value in values:
		if seen.has(value):
			return true
		seen[value] = true
	return false


func _suspect_exists(case_definition: CaseDefinition, suspect_id: int) -> bool:
	for suspect in case_definition.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return true
	return false
