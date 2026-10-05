class_name ScoundrelImmunityService
extends RefCounted

const SCOUNDREL_ROLE_ID: StringName = &"tutorial_scoundrel"


static func can_be_killed_or_handled(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	target_suspect_id: int
) -> bool:
	if case_definition == null or runtime_state == null or not runtime_state.is_initialized:
		return true
	if runtime_state.current_role_id_for_suspect(case_definition, target_suspect_id) != SCOUNDREL_ROLE_ID:
		return true
	if PoisonerTaintService.is_effectively_corrupted(case_definition, runtime_state, target_suspect_id):
		return true
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect == null or suspect.suspect_id == target_suspect_id:
			continue
		if suspect.true_alignment != CaseEnums.Alignment.EVIL:
			continue
		var suspect_runtime: SuspectRuntimeState = runtime_state.find_suspect(suspect.suspect_id)
		if suspect_runtime != null and not suspect_runtime.is_dead and not suspect_runtime.is_arrested:
			return false
	return true


static func can_be_accused_by_player(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	player_id: StringName,
	target_suspect_id: int
) -> bool:
	if case_definition == null or runtime_state == null or not runtime_state.is_initialized:
		return true
	if runtime_state.current_role_id_for_suspect(case_definition, target_suspect_id) != SCOUNDREL_ROLE_ID:
		return true
	if PoisonerTaintService.is_effectively_corrupted(case_definition, runtime_state, target_suspect_id):
		return true
	var has_other_true_evil: bool = false
	for suspect: SuspectDefinition in case_definition.suspects:
		if (
			suspect != null
			and suspect.suspect_id != target_suspect_id
			and suspect.true_alignment == CaseEnums.Alignment.EVIL
		):
			has_other_true_evil = true
			break
	if not has_other_true_evil:
		return true
	for suspect_id: int in runtime_state.correctly_accused_evil_ids_for_player(case_definition, player_id):
		if suspect_id != target_suspect_id:
			return true
	return false
