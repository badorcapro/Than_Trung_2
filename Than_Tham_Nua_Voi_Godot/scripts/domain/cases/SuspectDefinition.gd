class_name SuspectDefinition
extends Resource

@export_range(1, 99, 1) var suspect_id := 1
@export var board_slot := 0
@export var true_role_id: StringName
@export var displayed_role_id: StringName
@export var true_alignment: CaseEnums.Alignment = CaseEnums.Alignment.GOOD
@export var role_group: CaseEnums.RoleGroup = CaseEnums.RoleGroup.CHINH_NHAN
@export var is_corrupted := false
@export var is_impersonating := false
@export var impersonated_role_id: StringName
@export_range(-1, 4, 1) var authored_lie_numeric_value := -1
@export var mailman_claimed_in_play_role_id: StringName
@export var mailman_claimed_not_in_play_role_id: StringName
@export_range(0, 99, 1) var obscure_target_suspect_id := 0
@export_multiline var public_investigation_statement: String
@export_multiline var truth_reveal_note: String
