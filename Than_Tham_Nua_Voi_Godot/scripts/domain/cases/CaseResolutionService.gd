class_name CaseResolutionService
extends RefCounted


func is_evil_handled(_case_definition: CaseDefinition, _runtime_state: CaseRuntimeState, _suspect_id: int) -> bool:
	return false


func unresolved_evil_ids(case_definition: CaseDefinition, runtime_state: CaseRuntimeState) -> PackedInt32Array:
	if case_definition == null:
		return PackedInt32Array()
	return _unresolved_ids(case_definition.evil_suspect_ids, case_definition, runtime_state)


func unresolved_underling_ids(case_definition: CaseDefinition, runtime_state: CaseRuntimeState) -> PackedInt32Array:
	if case_definition == null:
		return PackedInt32Array()
	return _unresolved_ids(case_definition.accomplice_suspect_ids, case_definition, runtime_state)


func unresolved_traitor_ids(case_definition: CaseDefinition, runtime_state: CaseRuntimeState) -> PackedInt32Array:
	if case_definition == null:
		return PackedInt32Array()
	return _unresolved_ids(case_definition.traitor_suspect_ids, case_definition, runtime_state)


func main_answer_correct(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, selected_evil_ids: PackedInt32Array) -> bool:
	return _sets_equal(selected_evil_ids, unresolved_evil_ids(case_definition, runtime_state))


func underling_classification_correct(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, underling_ids: PackedInt32Array) -> bool:
	return _sets_equal(underling_ids, unresolved_underling_ids(case_definition, runtime_state))


func traitor_classification_correct(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, traitor_ids: PackedInt32Array) -> bool:
	return _sets_equal(traitor_ids, unresolved_traitor_ids(case_definition, runtime_state))


func unresolved_known_evil_ids(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, player_id: StringName) -> PackedInt32Array:
	var ids: PackedInt32Array = PackedInt32Array()
	if case_definition == null or runtime_state == null:
		return ids
	var unresolved: PackedInt32Array = unresolved_evil_ids(case_definition, runtime_state)
	for record: PrivateRoleKnowledgeRecord in runtime_state.private_role_knowledge_for_player(player_id):
		if record != null and record.suspect_id in unresolved and record.suspect_id not in ids:
			ids.append(record.suspect_id)
	ids.sort()
	return ids


func _unresolved_ids(source_ids: PackedInt32Array, _case_definition: CaseDefinition, _runtime_state: CaseRuntimeState) -> PackedInt32Array:
	var ids: PackedInt32Array = PackedInt32Array()
	for suspect_id: int in source_ids:
		ids.append(suspect_id)
	ids.sort()
	return ids


func _id_in(suspect_id: int, ids: PackedInt32Array) -> bool:
	for value: int in ids:
		if value == suspect_id:
			return true
	return false


func _sets_equal(first: PackedInt32Array, second: PackedInt32Array) -> bool:
	if first.size() != second.size():
		return false
	for value: int in first:
		if value not in second:
			return false
	return true
