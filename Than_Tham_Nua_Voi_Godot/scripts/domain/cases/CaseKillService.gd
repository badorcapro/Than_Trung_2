class_name CaseKillService
extends RefCounted

const SCOUNDREL_IMMUNITY_SERVICE := preload("res://scripts/domain/cases/ScoundrelImmunityService.gd")


func kill(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, target_suspect_id: int, source: StringName = &"") -> CaseKillResult:
	if case_definition == null or runtime_state == null or not runtime_state.is_initialized:
		return CaseKillResult.failed(target_suspect_id, source, &"KILL_CONTEXT_INVALID", "Dữ liệu hạ sát không hợp lệ.")
	var target_definition: SuspectDefinition = _find_definition(case_definition, target_suspect_id)
	if target_definition == null:
		return CaseKillResult.failed(target_suspect_id, source, &"KILL_TARGET_NOT_FOUND", "Không tìm thấy nghi phạm cần hạ sát.")
	var suspect_runtime: SuspectRuntimeState = runtime_state.find_suspect(target_suspect_id)
	if suspect_runtime == null:
		return CaseKillResult.failed(target_suspect_id, source, &"KILL_TARGET_NOT_FOUND", "Không tìm thấy trạng thái nghi phạm.")
	if suspect_runtime.is_dead:
		return CaseKillResult.already_dead(target_suspect_id, source)
	if not SCOUNDREL_IMMUNITY_SERVICE.can_be_killed_or_handled(case_definition, runtime_state, target_suspect_id):
		return CaseKillResult.failed(target_suspect_id, source, &"SCOUNDREL_IMMUNE", "Kẻ Bất Lương vẫn đang được miễn nhiễm.")
	suspect_runtime.mark_dead(source)
	runtime_state.append_kill_log(target_suspect_id, source, true)
	return CaseKillResult.killed(target_suspect_id, source)


func _find_definition(case_definition: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	if case_definition == null:
		return null
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null
