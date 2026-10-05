class_name CaseMutationStateSnapshot
extends RefCounted

var suspect_id: int = 0
var original_role_id: StringName = &""
var current_role_id: StringName = &""
var displayed_role_id: StringName = &""
var behavior_role_id: StringName = &""
var current_role_group: int = -1
var current_alignment: int = -1
var displayed_role_group: int = -1
var truth_mode: int = InvestigationInformationResult.TruthMode.TRUTHFUL
var is_tainted: bool = false
var is_obscured: bool = false
var is_impersonating: bool = false
var role_identity_visible: bool = true


static func from_runtime(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	source_suspect_id: int,
	roles: Array[RoleDefinition]
) -> CaseMutationStateSnapshot:
	if case_definition == null:
		return null
	var definition: SuspectDefinition = null
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect != null and suspect.suspect_id == source_suspect_id:
			definition = suspect
			break
	if definition == null:
		return null
	var state := CaseMutationStateSnapshot.new()
	state.suspect_id = source_suspect_id
	state.original_role_id = definition.true_role_id
	state.current_role_id = (
		runtime_state.current_role_id_for_suspect(case_definition, source_suspect_id)
		if runtime_state != null else definition.true_role_id
	)
	state.displayed_role_id = definition.displayed_role_id
	state.is_impersonating = definition.is_impersonating
	state.current_role_group = definition.role_group
	state.displayed_role_group = -1
	for role: RoleDefinition in roles:
		if role != null and role.role_id == state.current_role_id:
			state.current_role_group = role.role_group
		if role != null and role.role_id == state.displayed_role_id:
			state.displayed_role_group = role.role_group
	state.current_alignment = CaseRolePoolService.alignment_for_role_group(state.current_role_group)
	var evaluator := RoleInformationEvaluationService.new()
	state.behavior_role_id = evaluator.investigation_behavior_role_id(definition)
	state.truth_mode = evaluator.truth_mode_for_suspect_effective(case_definition, runtime_state, source_suspect_id)
	state.is_tainted = PoisonerTaintService.is_effectively_corrupted(case_definition, runtime_state, source_suspect_id)
	var information: InvestigationInformationResult = evaluator.evaluate(case_definition, source_suspect_id, roles, {}, runtime_state)
	for source: SuspectDefinition in case_definition.suspects:
		if source == null or source.obscure_target_suspect_id != source_suspect_id:
			continue
		var relation := InvestigationObscureRelation.new()
		if relation.configure(source.suspect_id, source_suspect_id):
			information = evaluator.apply_obscure_relation(information, case_definition, relation, runtime_state)
	state.is_obscured = information != null and information.is_obscured
	state.role_identity_visible = information == null or information.role_identity_visible
	return state


func public_role_id() -> StringName:
	return &"" if not role_identity_visible else displayed_role_id


func public_role_group() -> int:
	return -1 if not role_identity_visible else displayed_role_group


func audit_line(role_names: Dictionary) -> String:
	var current_name: String = String(role_names.get(current_role_id, String(current_role_id)))
	var line: String = "#%d %s" % [suspect_id, current_name]
	if original_role_id != current_role_id:
		line = "#%d original: %s -> current: %s" % [
			suspect_id, String(role_names.get(original_role_id, String(original_role_id))), current_name,
		]
	if is_impersonating:
		line += " -> giả %s" % String(role_names.get(displayed_role_id, String(displayed_role_id)))
	elif displayed_role_id != current_role_id:
		line += " | hiển thị: %s" % String(role_names.get(displayed_role_id, String(displayed_role_id)))
	if behavior_role_id != current_role_id:
		line += " | hành vi: %s" % String(role_names.get(behavior_role_id, String(behavior_role_id)))
	if is_tainted:
		line += " | tainted"
	if is_obscured:
		line += " | obscured"
	line += " | %s / %s" % [_group_text(), "Evil" if current_alignment == CaseEnums.Alignment.EVIL else "Good"]
	line += " | %s" % ("lying" if truth_mode == InvestigationInformationResult.TruthMode.LYING else "truthful")
	return line


func _group_text() -> String:
	match current_role_group:
		CaseEnums.RoleGroup.CHINH_NHAN:
			return "Người Vô Tội"
		CaseEnums.RoleGroup.HIEU_SU:
			return "Kẻ Bao Đồng"
		CaseEnums.RoleGroup.TONG_PHAM:
			return "Thuộc Hạ"
		CaseEnums.RoleGroup.NGHICH_THAN:
			return "Nghịch Thần"
		_:
			return "unknown"
