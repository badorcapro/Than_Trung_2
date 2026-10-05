class_name CaseRolePoolService
extends RefCounted


static func suspected_role_ids_for_case(case_definition: CaseDefinition) -> Array[StringName]:
	var ids: Array[StringName] = []
	if case_definition == null:
		return ids
	var authored_ids: Array[StringName] = case_definition.suspected_role_ids
	if authored_ids.is_empty():
		authored_ids = case_definition.suspect_list_role_ids
	for role_id: StringName in authored_ids:
		if not String(role_id).is_empty() and not ids.has(role_id):
			ids.append(role_id)
	return ids


static func nested_role_reference_ids_for_case(case_definition: CaseDefinition, parent_role_id: StringName) -> Array[StringName]:
	var ids: Array[StringName] = []
	if case_definition == null:
		return ids
	var raw_ids: Variant = case_definition.nested_suspect_list_role_ids_by_parent.get(parent_role_id, [])
	var raw_array: Array = raw_ids if raw_ids is Array else []
	if raw_array.is_empty():
		raw_ids = case_definition.nested_suspect_list_role_ids_by_parent.get(String(parent_role_id), [])
		raw_array = raw_ids if raw_ids is Array else []
	for raw_id: Variant in raw_array:
		var role_id: StringName = StringName(raw_id)
		if not String(role_id).is_empty() and not ids.has(role_id):
			ids.append(role_id)
	return ids


static func current_role_ids_in_play(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, exclude_suspect_id: int = 0) -> Array[StringName]:
	var role_ids: Array[StringName] = []
	if case_definition == null:
		return role_ids
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect == null or suspect.suspect_id == exclude_suspect_id:
			continue
		var role_id: StringName = &""
		if runtime_state != null:
			role_id = runtime_state.current_role_id_for_suspect(case_definition, suspect.suspect_id)
		else:
			role_id = suspect.true_role_id
		if not String(role_id).is_empty() and not role_ids.has(role_id):
			role_ids.append(role_id)
	role_ids.sort()
	return role_ids


static func current_role_ids_not_in_play(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	candidate_role_ids: Array[StringName],
	exclude_role_id: StringName = &""
) -> Array[StringName]:
	var in_play: Array[StringName] = current_role_ids_in_play(case_definition, runtime_state)
	var not_in_play: Array[StringName] = []
	for role_id: StringName in candidate_role_ids:
		if String(role_id).is_empty() or role_id == exclude_role_id:
			continue
		if not in_play.has(role_id) and not not_in_play.has(role_id):
			not_in_play.append(role_id)
	not_in_play.sort()
	return not_in_play


static func suspected_role_candidates(case_definition: CaseDefinition, exclude_role_id: StringName = &"") -> Array[StringName]:
	var ids: Array[StringName] = []
	for role_id: StringName in suspected_role_ids_for_case(case_definition):
		if role_id != exclude_role_id:
			ids.append(role_id)
	return ids


static func is_role_listed(case_definition: CaseDefinition, role_id: StringName) -> bool:
	return not String(role_id).is_empty() and suspected_role_ids_for_case(case_definition).has(role_id)


static func is_listed_current_role_absent(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	role_id: StringName
) -> bool:
	return (
		is_role_listed(case_definition, role_id)
		and not current_role_ids_in_play(case_definition, runtime_state).has(role_id)
	)


static func good_current_not_in_play_candidates(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	roles: Array[RoleDefinition],
	candidate_role_ids: Array[StringName],
	exclude_role_id: StringName = &""
) -> Array[StringName]:
	var role_by_id: Dictionary = _role_by_id(roles)
	var not_in_play: Array[StringName] = current_role_ids_not_in_play(case_definition, runtime_state, candidate_role_ids, exclude_role_id)
	var good_ids: Array[StringName] = []
	for role_id: StringName in not_in_play:
		var role: RoleDefinition = role_by_id.get(role_id, null) as RoleDefinition
		if role != null and not role.is_fixture_placeholder and role_alignment(role) == CaseEnums.Alignment.GOOD:
			good_ids.append(role_id)
	good_ids.sort()
	return good_ids


static func role_alignment(role: RoleDefinition) -> int:
	if role == null:
		return CaseEnums.Alignment.GOOD
	return alignment_for_role_group(role.role_group)


static func alignment_for_role_group(group: int) -> int:
	if group == CaseEnums.RoleGroup.TONG_PHAM or group == CaseEnums.RoleGroup.NGHICH_THAN:
		return CaseEnums.Alignment.EVIL
	return CaseEnums.Alignment.GOOD


static func _role_by_id(roles: Array[RoleDefinition]) -> Dictionary:
	var by_id: Dictionary = {}
	for role: RoleDefinition in roles:
		if role != null and not String(role.role_id).is_empty():
			by_id[role.role_id] = role
	return by_id


static func _is_good_alignment_group(group: int) -> bool:
	return alignment_for_role_group(group) == CaseEnums.Alignment.GOOD
