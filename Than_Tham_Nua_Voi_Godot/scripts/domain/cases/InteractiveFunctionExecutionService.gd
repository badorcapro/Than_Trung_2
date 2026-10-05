class_name InteractiveFunctionExecutionService
extends RefCounted


func execute(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, owner_suspect_id: int, target_ids: PackedInt32Array, acting_player_id: StringName) -> InteractiveFunctionResult:
	if case_definition == null or runtime_state == null or not runtime_state.is_initialized:
		return _fail(runtime_state, owner_suspect_id, CaseEnums.FunctionType.NONE, target_ids, acting_player_id, &"CASE_RUNTIME_INVALID", "Runtime Kỳ Án không hợp lệ.")
	if runtime_state.case_outcome not in [CaseEnums.CaseOutcome.IN_PROGRESS, CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS]:
		return _fail(runtime_state, owner_suspect_id, CaseEnums.FunctionType.NONE, target_ids, acting_player_id, &"CASE_NOT_IN_PROGRESS", "Kỳ Án không còn nhận hành động.")
	if acting_player_id == &"" or runtime_state.current_player_id() != acting_player_id:
		return _fail(runtime_state, owner_suspect_id, CaseEnums.FunctionType.NONE, target_ids, acting_player_id, &"PLAYER_NOT_CURRENT", "Người chơi không có lượt hiện tại.")
	var acting_player: PlayerCaseState = runtime_state.find_player(acting_player_id)
	if acting_player == null or not acting_player.is_active_in_investigation:
		return _fail(runtime_state, owner_suspect_id, CaseEnums.FunctionType.NONE, target_ids, acting_player_id, &"PLAYER_INACTIVE", "Người chơi đã rời giai đoạn điều tra.")
	var owner_definition: SuspectDefinition = _find_definition(case_definition, owner_suspect_id)
	var owner_runtime: SuspectRuntimeState = runtime_state.find_suspect(owner_suspect_id)
	if owner_definition == null or owner_runtime == null:
		return _fail(runtime_state, owner_suspect_id, CaseEnums.FunctionType.NONE, target_ids, acting_player_id, &"FUNCTION_OWNER_NOT_FOUND", "Không tìm thấy nghi phạm sở hữu chức năng.")
	if not owner_runtime.is_investigated:
		return _fail(runtime_state, owner_suspect_id, CaseEnums.FunctionType.NONE, target_ids, acting_player_id, &"FUNCTION_OWNER_NOT_REVEALED", "Chức năng chưa được công khai.")
	var runtime_function: InteractiveFunctionRuntimeState = owner_runtime.interactive_function
	if runtime_function == null:
		return _fail(runtime_state, owner_suspect_id, CaseEnums.FunctionType.NONE, target_ids, acting_player_id, &"FUNCTION_NOT_OWNED", "Nghi phạm không sở hữu chức năng tương tác.")
	if runtime_function.state != InteractiveFunctionRuntimeState.State.AVAILABLE:
		var code: StringName = &"FUNCTION_EXHAUSTED" if runtime_function.state == InteractiveFunctionRuntimeState.State.EXHAUSTED else &"FUNCTION_NOT_AVAILABLE"
		return _fail(runtime_state, owner_suspect_id, runtime_function.function_type, target_ids, acting_player_id, code, "Chức năng hiện không khả dụng.")
	if runtime_function.uses_remaining <= 0:
		return _fail(runtime_state, owner_suspect_id, runtime_function.function_type, target_ids, acting_player_id, &"FUNCTION_NO_USES", "Chức năng đã hết lượt dùng.")
	if runtime_function.function_type == CaseEnums.FunctionType.TAILOR_COMPARE_ALIGNMENT:
		return _execute_tailor(case_definition, runtime_state, owner_definition, runtime_function, owner_suspect_id, target_ids, acting_player_id)
	if runtime_function.function_type == CaseEnums.FunctionType.VIGILANTE_KILL:
		return _execute_vigilante(case_definition, runtime_state, owner_definition, runtime_function, owner_suspect_id, target_ids, acting_player_id)
	return _fail(runtime_state, owner_suspect_id, runtime_function.function_type, target_ids, acting_player_id, &"FUNCTION_TYPE_UNSUPPORTED", "Loại chức năng chưa được hỗ trợ.")


func _execute_tailor(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, owner_definition: SuspectDefinition, runtime_function: InteractiveFunctionRuntimeState, owner_suspect_id: int, target_ids: PackedInt32Array, acting_player_id: StringName) -> InteractiveFunctionResult:
	if target_ids.size() != 2:
		return _fail(runtime_state, owner_suspect_id, runtime_function.function_type, target_ids, acting_player_id, &"TARGET_COUNT_INVALID", "Thợ May cần đúng hai nghi phạm.")
	if target_ids[0] == target_ids[1]:
		return _fail(runtime_state, owner_suspect_id, runtime_function.function_type, target_ids, acting_player_id, &"TARGETS_MUST_DIFFER", "Hai mục tiêu phải khác nhau.")
	var first_target: SuspectDefinition = _find_definition(case_definition, target_ids[0])
	var second_target: SuspectDefinition = _find_definition(case_definition, target_ids[1])
	if first_target == null or second_target == null:
		return _fail(runtime_state, owner_suspect_id, runtime_function.function_type, target_ids, acting_player_id, &"TARGET_NOT_FOUND", "Không tìm thấy mục tiêu hợp lệ.")
	var same_alignment: bool = first_target.true_alignment == second_target.true_alignment
	var owner_truth_mode: int = RoleInformationEvaluationService.new().truth_mode_for_suspect_effective(
		case_definition, runtime_state, owner_suspect_id
	)
	var public_same_alignment: bool = same_alignment
	if owner_truth_mode == InvestigationInformationResult.TruthMode.LYING:
		public_same_alignment = not public_same_alignment
	var result_type: InteractiveFunctionResult.PublicResultType = (
		InteractiveFunctionResult.PublicResultType.SAME_ALIGNMENT
		if public_same_alignment
		else InteractiveFunctionResult.PublicResultType.DIFFERENT_ALIGNMENT
	)
	var result_text: String = "Cùng phe" if public_same_alignment else "Khác phe"
	var result: InteractiveFunctionResult = InteractiveFunctionResult.succeeded(owner_suspect_id, runtime_function.function_type, target_ids, result_type, result_text)
	_commit_success(runtime_state, runtime_function, owner_suspect_id, target_ids, acting_player_id, result.public_result_text)
	return result


func _execute_vigilante(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, _owner_definition: SuspectDefinition, runtime_function: InteractiveFunctionRuntimeState, owner_suspect_id: int, target_ids: PackedInt32Array, acting_player_id: StringName) -> InteractiveFunctionResult:
	if target_ids.size() != 1:
		return _fail(runtime_state, owner_suspect_id, runtime_function.function_type, target_ids, acting_player_id, &"TARGET_COUNT_INVALID", "Vigilante cần đúng một nghi phạm.")
	var target_definition: SuspectDefinition = _find_definition(case_definition, target_ids[0])
	if target_definition == null:
		return _fail(runtime_state, owner_suspect_id, runtime_function.function_type, target_ids, acting_player_id, &"TARGET_NOT_FOUND", "Không tìm thấy mục tiêu hợp lệ.")
	var owner_truth_mode: int = RoleInformationEvaluationService.new().truth_mode_for_suspect_effective(
		case_definition, runtime_state, owner_suspect_id
	)
	var kill_attempted: bool = (
		owner_truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL
		and target_definition.true_alignment == CaseEnums.Alignment.EVIL
	)
	var result_type: InteractiveFunctionResult.PublicResultType = InteractiveFunctionResult.PublicResultType.VIGILANTE_MISSED
	var result_text: String = "Số Hiệu %d bình an vô sự." % target_definition.suspect_id
	var kill_result: CaseKillResult = null
	if kill_attempted:
		kill_result = CaseKillService.new().kill(case_definition, runtime_state, target_definition.suspect_id, &"vigilante")
		result_type = InteractiveFunctionResult.PublicResultType.VIGILANTE_KILL_ATTEMPTED
		result_text = "Số Hiệu %d đã bị xử quyết." % target_definition.suspect_id
	var result: InteractiveFunctionResult = InteractiveFunctionResult.succeeded(owner_suspect_id, runtime_function.function_type, target_ids, result_type, result_text)
	result.vigilante_kill_attempted = kill_attempted
	if kill_result != null:
		result.vigilante_target_killed = kill_result.outcome == CaseKillResult.Outcome.KILLED
		result.kill_outcome = kill_result.outcome
	_commit_success(runtime_state, runtime_function, owner_suspect_id, target_ids, acting_player_id, result.public_result_text)
	return result


func _commit_success(runtime_state: CaseRuntimeState, runtime_function: InteractiveFunctionRuntimeState, owner_suspect_id: int, target_ids: PackedInt32Array, acting_player_id: StringName, public_result_text: String) -> void:
	runtime_function.uses_remaining -= 1
	if runtime_function.uses_remaining <= 0:
		runtime_function.uses_remaining = 0
		runtime_function.state = InteractiveFunctionRuntimeState.State.EXHAUSTED
	runtime_state.append_function_execution_log(acting_player_id, owner_suspect_id, _function_display_name(runtime_function.function_type), target_ids, true, public_result_text)
	runtime_state.append_public_function_record(owner_suspect_id, _function_display_name(runtime_function.function_type), target_ids, acting_player_id, public_result_text)


func _fail(runtime_state: CaseRuntimeState, owner_suspect_id: int, function_type: CaseEnums.FunctionType, target_ids: PackedInt32Array, acting_player_id: StringName, code: StringName, message: String) -> InteractiveFunctionResult:
	if runtime_state != null and runtime_state.is_initialized:
		runtime_state.append_function_execution_log(acting_player_id, owner_suspect_id, _function_display_name(function_type), target_ids, false, "", code)
	return InteractiveFunctionResult.failed(owner_suspect_id, function_type, target_ids, code, message)


func _find_definition(case_definition: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	for suspect in case_definition.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null


func _function_display_name(function_type: CaseEnums.FunctionType) -> String:
	if function_type == CaseEnums.FunctionType.TAILOR_COMPARE_ALIGNMENT:
		return "Thợ May"
	if function_type == CaseEnums.FunctionType.VIGILANTE_KILL:
		return "Vigilante"
	return "Chức năng tương tác"
