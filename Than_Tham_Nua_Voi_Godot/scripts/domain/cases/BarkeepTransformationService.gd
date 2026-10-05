class_name BarkeepTransformationService
extends RefCounted

const BARKEEP_ROLE_ID: StringName = &"barkeep"
const DRUNKARD_ROLE_ID: StringName = &"drunkard"
const CASE_ROLE_POOL_SERVICE := preload("res://scripts/domain/cases/CaseRolePoolService.gd")


func resolve_transformation(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	source_suspect_id: int,
	target_suspect_id: int,
	roles: Array[RoleDefinition] = []
) -> BarkeepTransformationRecord:
	if case_definition == null or runtime_state == null or not runtime_state.is_initialized:
		return _invalid_record(source_suspect_id)
	var existing: BarkeepTransformationRecord = runtime_state.barkeep_record_for_source(source_suspect_id)
	if existing != null:
		return existing
	var source_definition: SuspectDefinition = _find_suspect(case_definition, source_suspect_id)
	var target_definition: SuspectDefinition = _find_suspect(case_definition, target_suspect_id)
	if source_definition == null or target_definition == null:
		return _invalid_record(source_suspect_id)
	if runtime_state.find_suspect(source_suspect_id) == null or runtime_state.find_suspect(target_suspect_id) == null:
		return _invalid_record(source_suspect_id)
	if runtime_state.current_role_id_for_suspect(case_definition, source_suspect_id) != BARKEEP_ROLE_ID:
		return _invalid_record(source_suspect_id)
	if _current_drunkard_exists(case_definition, runtime_state):
		return _store_no_second_drunkard(runtime_state, source_suspect_id)
	if source_suspect_id == target_suspect_id:
		return _invalid_record(source_suspect_id)
	if target_definition.role_group != CaseEnums.RoleGroup.CHINH_NHAN:
		return _invalid_record(source_suspect_id)
	var original_role_id: StringName = runtime_state.current_role_id_for_suspect(case_definition, target_suspect_id)
	if original_role_id == DRUNKARD_ROLE_ID:
		return _store_no_second_drunkard(runtime_state, source_suspect_id)
	if not CaseRoleTransformationService.new().transform_role(case_definition, runtime_state, target_suspect_id, DRUNKARD_ROLE_ID, roles):
		return _invalid_record(source_suspect_id)
	var record: BarkeepTransformationRecord = BarkeepTransformationRecord.new()
	record.configure(source_suspect_id, target_suspect_id, original_role_id, DRUNKARD_ROLE_ID, true, BarkeepTransformationRecord.STATUS_APPLIED)
	runtime_state.barkeep_transformation_records.append(record)
	return record


func barkeep_pretend_candidate_role_ids(case_definition: CaseDefinition) -> Array[StringName]:
	return CASE_ROLE_POOL_SERVICE.suspected_role_candidates(case_definition)


func barkeep_pretend_role_is_valid(case_definition: CaseDefinition, role_id: StringName) -> bool:
	return barkeep_pretend_candidate_role_ids(case_definition).has(role_id)


func drunkard_pretend_candidate_role_ids(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	roles: Array[RoleDefinition],
	candidate_role_ids: Array[StringName],
	exclude_role_id: StringName = &"drunkard"
) -> Array[StringName]:
	return CASE_ROLE_POOL_SERVICE.good_current_not_in_play_candidates(case_definition, runtime_state, roles, candidate_role_ids, exclude_role_id)


func drunkard_pretend_role_is_valid(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	roles: Array[RoleDefinition],
	candidate_role_ids: Array[StringName],
	role_id: StringName
) -> bool:
	return drunkard_pretend_candidate_role_ids(case_definition, runtime_state, roles, candidate_role_ids).has(role_id)


func case_setup_would_create_second_drunkard(case_definition: CaseDefinition) -> bool:
	var has_barkeep: bool = false
	var has_drunkard: bool = false
	if case_definition == null:
		return false
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect == null:
			continue
		if suspect.true_role_id == BARKEEP_ROLE_ID:
			has_barkeep = true
		elif suspect.true_role_id == DRUNKARD_ROLE_ID:
			has_drunkard = true
	return has_barkeep and has_drunkard


func _current_drunkard_exists(case_definition: CaseDefinition, runtime_state: CaseRuntimeState) -> bool:
	return RoleInformationEvaluationService.new().current_role_ids_in_play(case_definition, runtime_state).has(DRUNKARD_ROLE_ID)


func _store_no_second_drunkard(runtime_state: CaseRuntimeState, source_suspect_id: int) -> BarkeepTransformationRecord:
	var record: BarkeepTransformationRecord = BarkeepTransformationRecord.new()
	record.configure(source_suspect_id, 0, &"", DRUNKARD_ROLE_ID, false, BarkeepTransformationRecord.STATUS_DRUNKARD_ALREADY_EXISTS)
	runtime_state.barkeep_transformation_records.append(record)
	return record


func _invalid_record(source_suspect_id: int) -> BarkeepTransformationRecord:
	var record: BarkeepTransformationRecord = BarkeepTransformationRecord.new()
	record.configure(source_suspect_id, 0, &"", DRUNKARD_ROLE_ID, false, BarkeepTransformationRecord.STATUS_INVALID)
	return record


func _find_suspect(case_definition: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	if case_definition == null:
		return null
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null
