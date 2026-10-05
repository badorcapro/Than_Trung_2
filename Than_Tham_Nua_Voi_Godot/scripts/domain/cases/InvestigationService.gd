class_name InvestigationService
extends RefCounted


func investigate(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, suspect_id: int, player_id: StringName) -> InvestigationResult:
	if case_definition == null:
		return _fail(runtime_state, suspect_id, player_id, &"CASE_DEFINITION_INVALID", "Kỳ Án không hợp lệ.")
	if runtime_state == null or not runtime_state.is_initialized:
		return InvestigationResult.failed(suspect_id, player_id, &"CASE_RUNTIME_INVALID", "Runtime Kỳ Án chưa được khởi tạo.")
	if not runtime_state.accepts_investigation_actions:
		return _fail(runtime_state, suspect_id, player_id, &"INVESTIGATION_NOT_ALLOWED", "Hiện không thể Điều tra.")
	if player_id == &"" or runtime_state.current_player_id() != player_id:
		return _fail(runtime_state, suspect_id, player_id, &"PLAYER_NOT_CURRENT", "Người chơi không có lượt hiện tại.")
	var acting_player := runtime_state.find_player(player_id)
	if acting_player == null or not acting_player.is_active_in_investigation:
		return _fail(runtime_state, suspect_id, player_id, &"PLAYER_INACTIVE", "Người chơi đã rời giai đoạn điều tra.")
	var suspect_definition := _find_definition(case_definition, suspect_id)
	var suspect_runtime := runtime_state.find_suspect(suspect_id)
	if suspect_definition == null or suspect_runtime == null:
		return _fail(runtime_state, suspect_id, player_id, &"SUSPECT_NOT_FOUND", "Không tìm thấy nghi phạm.")
	if suspect_runtime.is_dead and not suspect_runtime.is_investigated:
		return _fail(runtime_state, suspect_id, player_id, &"SUSPECT_DEAD", "Nghi phạm đã chết.")
	if suspect_runtime.is_investigated:
		return _fail(runtime_state, suspect_id, player_id, &"SUSPECT_ALREADY_INVESTIGATED", "Nghi phạm đã được điều tra.")
	suspect_runtime.is_investigated = true
	var result := InvestigationResult.succeeded(suspect_id, player_id, suspect_definition.displayed_role_id)
	runtime_state.append_investigation_log(player_id, suspect_id, true, result.public_role_id)
	if runtime_state.all_suspects_investigated():
		runtime_state.accepts_investigation_actions = false
		runtime_state.case_outcome = CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS
	return result


func _find_definition(case_definition: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	for suspect in case_definition.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null


func _fail(runtime_state: CaseRuntimeState, suspect_id: int, player_id: StringName, code: StringName, failure_message: String) -> InvestigationResult:
	if runtime_state != null and runtime_state.is_initialized:
		runtime_state.append_investigation_log(player_id, suspect_id, false, &"", code)
	return InvestigationResult.failed(suspect_id, player_id, code, failure_message)
