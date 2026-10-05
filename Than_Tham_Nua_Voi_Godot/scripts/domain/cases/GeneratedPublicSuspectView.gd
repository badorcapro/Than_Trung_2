class_name GeneratedPublicSuspectView
extends RefCounted

var suspect_id: int = 0
var board_slot: int = -1
var public_role_id: StringName = &""
var public_role_group: int = CaseEnums.RoleGroup.CHINH_NHAN
var role_identity_obscured: bool = false


static func create(
	source_suspect_id: int,
	source_board_slot: int,
	source_public_role_id: StringName,
	source_public_role_group: int
) -> GeneratedPublicSuspectView:
	var suspect := GeneratedPublicSuspectView.new()
	suspect.suspect_id = source_suspect_id
	suspect.board_slot = source_board_slot
	suspect.public_role_id = source_public_role_id
	suspect.public_role_group = source_public_role_group
	return suspect


static func from_mutation_state(state: CaseMutationStateSnapshot, source_board_slot: int) -> GeneratedPublicSuspectView:
	if state == null:
		return null
	var suspect := GeneratedPublicSuspectView.create(
		state.suspect_id, source_board_slot, state.public_role_id(), state.public_role_group()
	)
	suspect.role_identity_obscured = not state.role_identity_visible
	return suspect


func fingerprint_text() -> String:
	var base: String = "%d:%d:%s:%d" % [
		suspect_id,
		board_slot,
		String(public_role_id),
		public_role_group,
	]
	return base + ":obscured" if role_identity_obscured else base
