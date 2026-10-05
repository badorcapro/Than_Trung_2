class_name GeneratedSuspect
extends RefCounted

var suspect_id: int = 0
var board_slot: int = -1
var true_role_id: StringName = &""
var displayed_role_id: StringName = &""
var impersonated_role_id: StringName = &""
var is_impersonating: bool = false
var role_group: int = CaseEnums.RoleGroup.CHINH_NHAN
var true_alignment: int = CaseEnums.Alignment.GOOD


static func create(
	source_suspect_id: int,
	source_board_slot: int,
	source_role: RoleDefinition
) -> GeneratedSuspect:
	var suspect := GeneratedSuspect.new()
	suspect.suspect_id = source_suspect_id
	suspect.board_slot = source_board_slot
	if source_role != null:
		suspect.true_role_id = source_role.role_id
		suspect.displayed_role_id = source_role.role_id
		suspect.role_group = source_role.role_group
		suspect.true_alignment = CaseRolePoolService.alignment_for_role_group(source_role.role_group)
	return suspect


func fingerprint_text() -> String:
	var identity: String = "%d:%d:%s:%d:%d" % [
		suspect_id,
		board_slot,
		String(true_role_id),
		role_group,
		true_alignment,
	]
	if is_impersonating:
		return "%s:pretend:%s" % [identity, String(impersonated_role_id)]
	return identity
