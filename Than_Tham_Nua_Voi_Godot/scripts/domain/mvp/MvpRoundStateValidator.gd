class_name MvpRoundStateValidator
extends RefCounted

const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const MVP_MATCH_STATE := preload("res://scripts/domain/mvp/MvpMatchState.gd")
const MVP_ROUND_STATE := preload("res://scripts/domain/mvp/MvpRoundState.gd")
const MVP_VALIDATION_REPORT := preload("res://scripts/domain/mvp/MvpValidationReport.gd")


func validate(
	round_state: MVP_ROUND_STATE, match_state: MVP_MATCH_STATE = null
) -> MVP_VALIDATION_REPORT:
	var report: MVP_VALIDATION_REPORT = MVP_VALIDATION_REPORT.new()
	if round_state == null:
		report.add_error(&"ROUND_STATE_NULL", "Round state is required", &"round")
		return report
	if round_state.round_id.is_empty():
		report.add_error(&"ROUND_ID_MISSING", "round_id is required", &"round")
	if round_state.round_number < 1:
		report.add_error(&"ROUND_NUMBER_INVALID", "round_number must be >= 1", &"round")
	if not MVP_ENUMS.is_valid_phase(round_state.phase):
		report.add_error(&"ROUND_PHASE_INVALID", "Round phase is invalid", &"round")
	if round_state.settlement_applied and round_state.settlement_commit_id.is_empty():
		report.add_error(
			&"SETTLEMENT_COMMIT_MISSING", "Applied settlement requires commit ID", &"settlement"
		)
	if match_state != null and match_state.current_phase != round_state.phase:
		report.add_error(&"PHASE_MISMATCH", "Match and Round phase must match", &"phase")
	_validate_snapshot_shapes(round_state, report)
	if round_state.phase == MVP_ENUMS.Phase.ROUND_END:
		_validate_round_end(round_state, report)
	return report


func _validate_snapshot_shapes(
	round_state: MVP_ROUND_STATE, report: MVP_VALIDATION_REPORT
) -> void:
	var snapshots: Array[Dictionary] = [
		round_state.case_runtime_snapshot,
		round_state.case_settlement_snapshot,
		round_state.loot_movement_snapshot,
		round_state.loot_reward_snapshot,
		round_state.equipment_management_snapshot,
	]
	for snapshot: Dictionary in snapshots:
		if _contains_object(snapshot):
			report.add_error(&"ROUND_SNAPSHOT_OBJECT", "Snapshots cannot contain Objects", &"snapshot")
			return


func _validate_round_end(
	round_state: MVP_ROUND_STATE, report: MVP_VALIDATION_REPORT
) -> void:
	if not round_state.settlement_applied:
		report.add_error(&"ROUND_END_SETTLEMENT_PENDING", "Settlement must be applied", &"round_end")
	var flags: Dictionary = round_state.round_completion_flags
	for required: String in ["movement_complete", "reward_complete", "management_complete"]:
		if not bool(flags.get(required, false)):
			report.add_error(&"ROUND_END_INCOMPLETE", "%s is required" % required, &"round_end")
	for pending: String in ["pending_overflow", "pending_choice", "pending_reward"]:
		if bool(flags.get(pending, false)):
			report.add_error(&"ROUND_END_PENDING_STATE", "%s must resolve" % pending, &"round_end")


func _contains_object(value: Variant) -> bool:
	if value is Object:
		return true
	if value is Array:
		for child: Variant in value:
			if _contains_object(child):
				return true
	if value is Dictionary:
		for child: Variant in value.values():
			if _contains_object(child):
				return true
	return false
