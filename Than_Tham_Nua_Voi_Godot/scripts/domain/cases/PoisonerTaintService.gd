class_name PoisonerTaintService
extends RefCounted

const POISONER_ROLE_ID: StringName = &"poisoner"
const CASE_ROLE_POOL_SERVICE := preload("res://scripts/domain/cases/CaseRolePoolService.gd")


func resolve_taint(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, source_suspect_id: int, target_suspect_id: int) -> PoisonerTaintRecord:
	if case_definition == null or runtime_state == null or not runtime_state.is_initialized:
		return _invalid_record(source_suspect_id)
	var existing: PoisonerTaintRecord = runtime_state.poisoner_record_for_source(source_suspect_id)
	if existing != null:
		return existing
	var source_definition: SuspectDefinition = _find_suspect(case_definition, source_suspect_id)
	var target_definition: SuspectDefinition = _find_suspect(case_definition, target_suspect_id)
	var source_runtime: SuspectRuntimeState = runtime_state.find_suspect(source_suspect_id)
	var target_runtime: SuspectRuntimeState = runtime_state.find_suspect(target_suspect_id)
	if source_definition == null or target_definition == null or source_runtime == null or target_runtime == null:
		return _invalid_record(source_suspect_id)
	if runtime_state.current_role_id_for_suspect(case_definition, source_suspect_id) != POISONER_ROLE_ID:
		return _invalid_record(source_suspect_id)
	if not is_eligible_taint_target(case_definition, source_suspect_id, target_suspect_id, runtime_state):
		return _invalid_record(source_suspect_id)
	if is_effectively_corrupted(case_definition, runtime_state, source_suspect_id):
		var blocked_record: PoisonerTaintRecord = PoisonerTaintRecord.new()
		blocked_record.configure(source_suspect_id, 0, false, PoisonerTaintRecord.STATUS_SOURCE_CORRUPTED)
		runtime_state.poisoner_taint_records.append(blocked_record)
		return blocked_record
	target_runtime.apply_runtime_corruption(source_suspect_id)
	var record: PoisonerTaintRecord = PoisonerTaintRecord.new()
	record.configure(source_suspect_id, target_suspect_id, true, PoisonerTaintRecord.STATUS_APPLIED)
	runtime_state.poisoner_taint_records.append(record)
	return record


func resolve_random_taint(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, source_suspect_id: int, seed: int = -1) -> PoisonerTaintRecord:
	if case_definition == null or runtime_state == null or not runtime_state.is_initialized:
		return _invalid_record(source_suspect_id)
	var existing: PoisonerTaintRecord = runtime_state.poisoner_record_for_source(source_suspect_id)
	if existing != null:
		return existing
	var source_definition: SuspectDefinition = _find_suspect(case_definition, source_suspect_id)
	var source_runtime: SuspectRuntimeState = runtime_state.find_suspect(source_suspect_id)
	if source_definition == null or source_runtime == null:
		return _invalid_record(source_suspect_id)
	if runtime_state.current_role_id_for_suspect(case_definition, source_suspect_id) != POISONER_ROLE_ID:
		return _invalid_record(source_suspect_id)
	if is_effectively_corrupted(case_definition, runtime_state, source_suspect_id):
		var blocked_record: PoisonerTaintRecord = PoisonerTaintRecord.new()
		blocked_record.configure(source_suspect_id, 0, false, PoisonerTaintRecord.STATUS_SOURCE_CORRUPTED)
		runtime_state.poisoner_taint_records.append(blocked_record)
		return blocked_record
	var candidates: PackedInt32Array = eligible_taint_target_ids(case_definition, source_suspect_id, runtime_state)
	if candidates.is_empty():
		var no_target_record: PoisonerTaintRecord = PoisonerTaintRecord.new()
		no_target_record.configure(source_suspect_id, 0, false, PoisonerTaintRecord.STATUS_NO_ELIGIBLE_TARGET)
		runtime_state.poisoner_taint_records.append(no_target_record)
		return no_target_record
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = _selection_seed(case_definition, runtime_state, source_suspect_id, seed)
	var target_suspect_id: int = candidates[rng.randi_range(0, candidates.size() - 1)]
	return resolve_taint(case_definition, runtime_state, source_suspect_id, target_suspect_id)


func eligible_taint_target_ids(case_definition: CaseDefinition, source_suspect_id: int, runtime_state: CaseRuntimeState = null) -> PackedInt32Array:
	var ids: PackedInt32Array = PackedInt32Array()
	if case_definition == null:
		return ids
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect != null and is_eligible_taint_target(case_definition, source_suspect_id, suspect.suspect_id, runtime_state):
			ids.append(suspect.suspect_id)
	return ids


func is_eligible_taint_target(case_definition: CaseDefinition, source_suspect_id: int, target_suspect_id: int, runtime_state: CaseRuntimeState = null) -> bool:
	var source_definition: SuspectDefinition = _find_suspect(case_definition, source_suspect_id)
	var target_definition: SuspectDefinition = _find_suspect(case_definition, target_suspect_id)
	return (
		source_definition != null
		and target_definition != null
		and source_suspect_id != target_suspect_id
		and target_definition.role_group == CaseEnums.RoleGroup.CHINH_NHAN
		and not is_effectively_corrupted(case_definition, runtime_state, target_suspect_id)
		and CaseSpatialService.new().are_surrounding_neighbours_for_case(case_definition, source_definition.board_slot, target_definition.board_slot)
	)


func pretend_candidate_role_ids(case_definition: CaseDefinition) -> Array[StringName]:
	return CASE_ROLE_POOL_SERVICE.suspected_role_candidates(case_definition)


func pretend_role_is_valid(case_definition: CaseDefinition, role_id: StringName) -> bool:
	return pretend_candidate_role_ids(case_definition).has(role_id)


static func is_effectively_corrupted(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, suspect_id: int) -> bool:
	var suspect: SuspectDefinition = _find_suspect(case_definition, suspect_id)
	if suspect != null and suspect.is_corrupted:
		return true
	return runtime_state != null and runtime_state.has_runtime_corruption(suspect_id)


func _invalid_record(source_suspect_id: int) -> PoisonerTaintRecord:
	var record: PoisonerTaintRecord = PoisonerTaintRecord.new()
	record.configure(source_suspect_id, 0, false, PoisonerTaintRecord.STATUS_INVALID)
	return record


static func _find_suspect(case_definition: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	if case_definition == null:
		return null
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null


func _selection_seed(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, source_suspect_id: int, seed: int) -> int:
	if seed >= 0:
		return seed
	var source_text: String = "%s:%d:%d" % [
		String(case_definition.case_id) if case_definition != null else "",
		source_suspect_id,
		runtime_state.case_event_seed if runtime_state != null else 0,
	]
	return absi(source_text.hash())
