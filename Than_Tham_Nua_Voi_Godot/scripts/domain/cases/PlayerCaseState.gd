class_name PlayerCaseState
extends Resource

@export var player_id: StringName
@export var display_name: String
@export var case_role_id: StringName
@export var merit: float = 0.0
@export_range(0, 6, 1) var reputation := 5
@export_range(0, 999, 1) var orb_count := 0
@export_range(0, 999, 1) var gacha_ticket_count := 0
@export var submission_status: CaseEnums.SubmissionStatus = CaseEnums.SubmissionStatus.NOT_SUBMITTED
@export var is_active_in_investigation := true
@export var test_only_fixture := true
