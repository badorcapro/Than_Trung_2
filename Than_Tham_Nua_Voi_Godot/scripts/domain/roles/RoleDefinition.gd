class_name RoleDefinition
extends Resource

@export var role_id: StringName
@export var display_name: String
@export var role_group: CaseEnums.RoleGroup = CaseEnums.RoleGroup.CHINH_NHAN
# Player-facing rulebook prose uses "ta"; literal in-world announcements keep their canonical wording.
@export_multiline var help_text: String
@export var has_interactive_function := false
@export var function_type: CaseEnums.FunctionType = CaseEnums.FunctionType.NONE
@export_range(0, 99, 1) var usage_limit := 0
@export var unlock_timing: CaseEnums.UnlockTiming = CaseEnums.UnlockTiming.NONE
@export_range(0, 9, 1) var target_count := 0
@export var information_result_type: CaseEnums.InformationResultType = CaseEnums.InformationResultType.NONE
@export var always_lies: bool = false
@export_range(1, 9, 1) var reputation_loss_multiplier: int = 1
@export_range(-1, 6, 1) var effective_turn_reputation_override: int = -1
@export var pretend_role_must_be_not_true_in_play: bool = false
@export var is_fixture_placeholder := true
