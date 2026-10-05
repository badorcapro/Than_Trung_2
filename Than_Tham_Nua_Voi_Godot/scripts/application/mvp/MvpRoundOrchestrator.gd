class_name MvpRoundOrchestrator
extends RefCounted

const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const MVP_MATCH_STATE := preload("res://scripts/domain/mvp/MvpMatchState.gd")
const MVP_ROUND_STATE := preload("res://scripts/domain/mvp/MvpRoundState.gd")
const MVP_TRANSITION_RESULT := preload("res://scripts/domain/mvp/MvpTransitionResult.gd")
const MVP_ROUND_VALIDATOR := preload("res://scripts/domain/mvp/MvpRoundStateValidator.gd")
const MVP_VALIDATION_REPORT := preload("res://scripts/domain/mvp/MvpValidationReport.gd")

var match_state: MVP_MATCH_STATE
var active_round: MVP_ROUND_STATE
var transition_log: Array[Dictionary] = []

const NEXT_PHASE: Dictionary = {
	MVP_ENUMS.Phase.MATCH_SETUP: MVP_ENUMS.Phase.CHARACTER_SELECTION,
	MVP_ENUMS.Phase.CHARACTER_SELECTION: MVP_ENUMS.Phase.ROUND_START,
	MVP_ENUMS.Phase.ROUND_START: MVP_ENUMS.Phase.CASE,
	MVP_ENUMS.Phase.CASE: MVP_ENUMS.Phase.CASE_SETTLEMENT,
	MVP_ENUMS.Phase.CASE_SETTLEMENT: MVP_ENUMS.Phase.LOOT,
	MVP_ENUMS.Phase.LOOT: MVP_ENUMS.Phase.LOOT_END_CONFIRMATION,
	MVP_ENUMS.Phase.LOOT_END_CONFIRMATION: MVP_ENUMS.Phase.EQUIPMENT_MANAGEMENT,
	MVP_ENUMS.Phase.EQUIPMENT_MANAGEMENT: MVP_ENUMS.Phase.ROUND_END,
}


func initialize(state: MVP_MATCH_STATE) -> void:
	match_state = state
	active_round = null
	transition_log.clear()


func attach_round(round_state: MVP_ROUND_STATE) -> Dictionary:
	if match_state == null or round_state == null:
		return {"success": false, "code": "ORCHESTRATOR_CONTEXT_INVALID"}
	if active_round != null:
		return {"success": false, "code": "ACTIVE_ROUND_ALREADY_ATTACHED"}
	if match_state.current_phase != round_state.phase:
		return {"success": false, "code": "PHASE_MISMATCH"}
	active_round = round_state
	return {"success": true, "code": "ROUND_ATTACHED"}


func transition(target_phase: int) -> MVP_TRANSITION_RESULT:
	if match_state == null:
		return MVP_TRANSITION_RESULT.create(
			false, &"ORCHESTRATOR_NOT_INITIALIZED", "Match state is required", -1, target_phase
		)
	var source := match_state.current_phase
	if target_phase == MVP_ENUMS.Phase.MATCH_COMPLETE:
		return _result(false, &"WIN_SERVICE_REQUIRED", "M1 cannot reach MATCH_COMPLETE", source, target_phase)
	var expected := int(NEXT_PHASE.get(source, -1))
	if expected != target_phase:
		return _result(false, &"ILLEGAL_TRANSITION", "Transition is not allowed", source, target_phase)
	if source == MVP_ENUMS.Phase.CASE_SETTLEMENT and target_phase == MVP_ENUMS.Phase.LOOT:
		if (
			active_round == null
			or not active_round.settlement_applied
			or active_round.settlement_commit_id.is_empty()
			or not match_state.applied_commit_ids.has(active_round.settlement_commit_id)
		):
			return _result(
				false,
				&"SETTLEMENT_NOT_APPLIED",
				"Settlement commit must be applied before Loot",
				source,
				target_phase
			)
	match_state.current_phase = target_phase
	if active_round != null:
		active_round.phase = target_phase
	return _result(true, &"TRANSITION_APPLIED", "Phase transition applied", source, target_phase)


func commit_round_end(commit_id: StringName) -> MVP_TRANSITION_RESULT:
	if match_state == null:
		return MVP_TRANSITION_RESULT.create(
			false, &"ORCHESTRATOR_NOT_INITIALIZED", "Match state is required", -1, -1
		)
	if commit_id.is_empty():
		return _result(
			false, &"ROUND_END_COMMIT_MISSING", "Round End commit ID is required",
			match_state.current_phase, match_state.current_phase
		)
	if match_state.applied_commit_ids.has(commit_id):
		return _result(
			false, &"ROUND_END_ALREADY_APPLIED", "Round End commit already applied",
			match_state.current_phase, match_state.current_phase
		)
	if active_round == null or match_state.current_phase != MVP_ENUMS.Phase.ROUND_END:
		return _result(
			false, &"ROUND_END_NOT_READY", "Active Round End state is required",
			match_state.current_phase, MVP_ENUMS.Phase.ROUND_START
		)
	var report: MVP_VALIDATION_REPORT = MVP_ROUND_VALIDATOR.new().validate(
		active_round, match_state
	)
	if not report.passed():
		return _result(
			false, &"ROUND_END_VALIDATION_FAILED", ", ".join(report.codes()),
			match_state.current_phase, MVP_ENUMS.Phase.ROUND_START
		)
	active_round.round_end_commit_id = commit_id
	match_state.applied_commit_ids.append(commit_id)
	match_state.completed_round_count += 1
	match_state.current_round_number += 1
	match_state.current_phase = MVP_ENUMS.Phase.ROUND_START
	active_round = null
	return _result(
		true, &"NEXT_CASE_REQUIRED", "Round committed; next case input is required",
		MVP_ENUMS.Phase.ROUND_END, MVP_ENUMS.Phase.ROUND_START
	)


func _result(
	passed: bool, code: StringName, message: String, source: int, target: int
) -> MVP_TRANSITION_RESULT:
	var result: MVP_TRANSITION_RESULT = MVP_TRANSITION_RESULT.create(
		passed, code, message, source, target
	)
	transition_log.append(result.to_dict())
	return result
