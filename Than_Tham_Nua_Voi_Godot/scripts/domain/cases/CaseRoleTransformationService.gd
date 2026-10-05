class_name CaseRoleTransformationService
extends RefCounted


func transform_role(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	suspect_id: int,
	target_role_id: StringName,
	roles: Array[RoleDefinition] = []
) -> bool:
	if case_definition == null or runtime_state == null or not runtime_state.is_initialized:
		return false
	if String(target_role_id).is_empty():
		return false
	if _find_suspect_definition(case_definition, suspect_id) == null:
		return false
	var suspect_runtime: SuspectRuntimeState = runtime_state.find_suspect(suspect_id)
	if suspect_runtime == null:
		return false
	if not roles.is_empty() and not _role_exists(roles, target_role_id):
		return false
	return suspect_runtime.set_current_role(target_role_id)


func original_true_role_id(case_definition: CaseDefinition, suspect_id: int) -> StringName:
	if case_definition == null:
		return &""
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect.true_role_id
	return &""


func current_role_id(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, suspect_id: int) -> StringName:
	if runtime_state != null:
		return runtime_state.current_role_id_for_suspect(case_definition, suspect_id)
	return original_true_role_id(case_definition, suspect_id)


func _find_suspect_definition(case_definition: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	if case_definition == null:
		return null
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null


func _role_exists(roles: Array[RoleDefinition], role_id: StringName) -> bool:
	for role: RoleDefinition in roles:
		if role != null and role.role_id == role_id:
			return true
	return false
