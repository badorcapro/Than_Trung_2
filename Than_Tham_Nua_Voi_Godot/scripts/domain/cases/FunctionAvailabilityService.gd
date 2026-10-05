class_name FunctionAvailabilityService
extends RefCounted


func initialize_hidden_states(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, roles: Array[RoleDefinition]) -> void:
	if case_definition == null or runtime_state == null:
		return
	for suspect_runtime in runtime_state.suspects:
		suspect_runtime.interactive_function = null
	for suspect_definition in case_definition.suspects:
		var role: RoleDefinition = _interactive_function_role(roles, suspect_definition)
		if not _has_valid_interactive_function(role):
			continue
		var suspect_runtime := runtime_state.find_suspect(suspect_definition.suspect_id)
		if suspect_runtime == null:
			continue
		var function_state := InteractiveFunctionRuntimeState.new(suspect_definition.suspect_id)
		function_state.configure_hidden(role)
		suspect_runtime.interactive_function = function_state


func reveal_for_suspect(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, roles: Array[RoleDefinition], suspect_id: int, current_turn_number: int) -> bool:
	if case_definition == null or runtime_state == null or current_turn_number < 1:
		return false
	var suspect_definition := _find_suspect(case_definition, suspect_id)
	var suspect_runtime := runtime_state.find_suspect(suspect_id)
	if suspect_definition == null or suspect_runtime == null or not suspect_runtime.is_investigated:
		return false
	var function_role: RoleDefinition = _interactive_function_role(roles, suspect_definition)
	if not _has_valid_interactive_function(function_role):
		return false
	if suspect_runtime.interactive_function == null:
		var function_state := InteractiveFunctionRuntimeState.new(suspect_id)
		function_state.configure_hidden(function_role)
		suspect_runtime.interactive_function = function_state
	var runtime_function := suspect_runtime.interactive_function
	if runtime_function.state != InteractiveFunctionRuntimeState.State.HIDDEN:
		return false
	runtime_function.lock_after_reveal(current_turn_number)
	runtime_state.append_function_revealed_log(suspect_id, runtime_function.available_from_turn)
	return true


func update_for_turn(runtime_state: CaseRuntimeState, current_turn_number: int) -> PackedInt32Array:
	var newly_available := PackedInt32Array()
	if runtime_state == null:
		return newly_available
	for suspect_runtime in runtime_state.suspects:
		var runtime_function := suspect_runtime.interactive_function
		if runtime_function != null and runtime_function.update_for_turn(current_turn_number):
			newly_available.append(suspect_runtime.suspect_id)
			runtime_state.append_function_available_log(suspect_runtime.suspect_id, current_turn_number)
	return newly_available


func available_functions(runtime_state: CaseRuntimeState) -> Array[InteractiveFunctionRuntimeState]:
	var available: Array[InteractiveFunctionRuntimeState] = []
	if runtime_state == null:
		return available
	for suspect_runtime in runtime_state.suspects:
		var runtime_function := suspect_runtime.interactive_function
		if runtime_function != null and runtime_function.state == InteractiveFunctionRuntimeState.State.AVAILABLE:
			available.append(runtime_function)
	return available


func has_available_functions(runtime_state: CaseRuntimeState) -> bool:
	return not available_functions(runtime_state).is_empty()


func expire_for_final_verdict(runtime_state: CaseRuntimeState) -> int:
	var expired_count := 0
	if runtime_state == null:
		return expired_count
	for suspect_runtime in runtime_state.suspects:
		var runtime_function := suspect_runtime.interactive_function
		if runtime_function != null and runtime_function.state in [InteractiveFunctionRuntimeState.State.LOCKED_UNTIL_NEXT_TURN, InteractiveFunctionRuntimeState.State.AVAILABLE]:
			runtime_function.state = InteractiveFunctionRuntimeState.State.EXPIRED
			expired_count += 1
	return expired_count


func _find_role(roles: Array[RoleDefinition], role_id: StringName) -> RoleDefinition:
	for role in roles:
		if role != null and role.role_id == role_id:
			return role
	return null


func _find_suspect(case_definition: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	for suspect in case_definition.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null


func _interactive_function_role(roles: Array[RoleDefinition], suspect_definition: SuspectDefinition) -> RoleDefinition:
	if suspect_definition == null:
		return null
	var true_role: RoleDefinition = _find_role(roles, suspect_definition.true_role_id)
	if _has_valid_interactive_function(true_role):
		return true_role
	if (
		suspect_definition.is_impersonating
		and suspect_definition.displayed_role_id != suspect_definition.true_role_id
	):
		var displayed_role: RoleDefinition = _find_role(roles, suspect_definition.displayed_role_id)
		if _has_valid_interactive_function(displayed_role):
			return displayed_role
	return null


func _has_valid_interactive_function(role: RoleDefinition) -> bool:
	return (
		role != null
		and role.has_interactive_function
		and role.function_type != CaseEnums.FunctionType.NONE
		and role.usage_limit > 0
		and role.unlock_timing == CaseEnums.UnlockTiming.NEXT_TURN_AFTER_INVESTIGATION
	)
