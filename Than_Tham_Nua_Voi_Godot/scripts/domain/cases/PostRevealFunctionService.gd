class_name PostRevealFunctionService
extends RefCounted


func resolve_phase(case_definition: CaseDefinition, runtime_state: CaseRuntimeState) -> bool:
	if case_definition == null or runtime_state == null or runtime_state.case_outcome != CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS:
		return false
	if not executable_functions(case_definition, runtime_state).is_empty():
		return false
	_expire_remaining_unusable(runtime_state)
	runtime_state.case_outcome = CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
	runtime_state.lock_case_actions()
	return true


func executable_functions(case_definition: CaseDefinition, runtime_state: CaseRuntimeState) -> Array[InteractiveFunctionRuntimeState]:
	var result: Array[InteractiveFunctionRuntimeState] = []
	if case_definition == null or runtime_state == null:
		return result
	for suspect_runtime in runtime_state.suspects:
		var runtime_function: InteractiveFunctionRuntimeState = suspect_runtime.interactive_function
		if runtime_function == null:
			continue
		if suspect_runtime.is_dead:
			continue
		if runtime_function.state != InteractiveFunctionRuntimeState.State.AVAILABLE or runtime_function.uses_remaining <= 0:
			continue
		if _has_valid_targets(case_definition, runtime_function):
			result.append(runtime_function)
	return result


func has_executable_functions(case_definition: CaseDefinition, runtime_state: CaseRuntimeState) -> bool:
	return not executable_functions(case_definition, runtime_state).is_empty()


func _has_valid_targets(case_definition: CaseDefinition, runtime_function: InteractiveFunctionRuntimeState) -> bool:
	if runtime_function.function_type == CaseEnums.FunctionType.TAILOR_COMPARE_ALIGNMENT:
		return case_definition.suspects.size() >= 2
	if runtime_function.function_type == CaseEnums.FunctionType.VIGILANTE_KILL:
		return case_definition.suspects.size() >= 1
	return false


func _expire_remaining_unusable(runtime_state: CaseRuntimeState) -> void:
	for suspect_runtime in runtime_state.suspects:
		var runtime_function: InteractiveFunctionRuntimeState = suspect_runtime.interactive_function
		if runtime_function != null and runtime_function.state in [InteractiveFunctionRuntimeState.State.LOCKED_UNTIL_NEXT_TURN, InteractiveFunctionRuntimeState.State.AVAILABLE]:
			runtime_function.state = InteractiveFunctionRuntimeState.State.EXPIRED
