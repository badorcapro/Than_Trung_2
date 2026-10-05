class_name CaseSliceAdapter
extends RefCounted

const MVP_MATCH_STATE := preload("res://scripts/domain/mvp/MvpMatchState.gd")
const PLAYER_MATCH_STATE := preload("res://scripts/domain/mvp/PlayerMatchState.gd")
const MVP_CASE_RESULT := preload("res://scripts/domain/mvp/MvpCaseResult.gd")
const MVP_CASE_PLAYER_RESULT := preload("res://scripts/domain/mvp/MvpCasePlayerResult.gd")
const MVP_MATCH_VALIDATOR := preload("res://scripts/domain/mvp/MvpMatchStateValidator.gd")


func project_player(player: PLAYER_MATCH_STATE) -> PlayerCaseState:
	var result := PlayerCaseState.new()
	result.player_id = player.player_id
	result.display_name = player.display_name
	result.merit = player.merit_progress
	result.reputation = player.reputation
	result.orb_count = player.orb_count
	result.gacha_ticket_count = player.gacha_ticket_count
	result.submission_status = CaseEnums.SubmissionStatus.NOT_SUBMITTED
	result.is_active_in_investigation = true
	result.test_only_fixture = true
	return result


func project_players(players: Array[PLAYER_MATCH_STATE]) -> Array[PlayerCaseState]:
	var result: Array[PlayerCaseState] = []
	for player: PLAYER_MATCH_STATE in players:
		result.append(project_player(player))
	return result


func normalize_settlement(
	settlement: CaseSettlementResult,
	case_id: StringName,
	round_id: StringName,
	completion_reason: StringName,
	commit_id: StringName
) -> MVP_CASE_RESULT:
	var result: MVP_CASE_RESULT = MVP_CASE_RESULT.new()
	result.case_id = case_id
	result.round_id = round_id
	result.completion_reason = completion_reason
	result.settlement_commit_id = commit_id
	if settlement == null or not settlement.success:
		return result
	result.case_outcome = settlement.case_outcome
	for resolution: PlayerCaseResolution in settlement.player_resolutions:
		var row: MVP_CASE_PLAYER_RESULT = MVP_CASE_PLAYER_RESULT.new()
		row.player_id = resolution.player_id
		row.submitted = (
			resolution.outcome != CaseEnums.PlayerResolutionOutcome.NOT_SUBMITTED_CASE_ENDED
		)
		row.submission_context = _submission_context(resolution)
		row.status = _status(resolution)
		row.main_answer_correct = resolution.main_answer_correct
		row.underling_classification_correct = resolution.underling_classification_correct
		row.traitor_classification_correct = resolution.traitor_classification_correct
		row.merit_delta = resolution.reward.merit_delta
		row.reputation_delta = resolution.reward.reputation_delta
		row.orb_delta = resolution.reward.orb_delta
		row.base_ticket_delta = resolution.reward.base_ticket_delta
		result.player_results.append(row)
	return result


func apply_once(match_state: MVP_MATCH_STATE, result: MVP_CASE_RESULT) -> Dictionary:
	if match_state == null or result == null:
		return _failure(&"SETTLEMENT_CONTEXT_INVALID", "Match/result is required")
	if not MVP_MATCH_VALIDATOR.new().validate(match_state).passed():
		return _failure(&"MATCH_STATE_INVALID", "Match state validation failed")
	if result.settlement_commit_id.is_empty():
		return _failure(&"SETTLEMENT_COMMIT_MISSING", "Settlement commit ID is required")
	if match_state.applied_commit_ids.has(result.settlement_commit_id):
		return _failure(&"SETTLEMENT_ALREADY_APPLIED", "Settlement is already applied", true)
	var seen_player_ids: Dictionary = {}
	for row: MVP_CASE_PLAYER_RESULT in result.player_results:
		if seen_player_ids.has(row.player_id):
			return _failure(&"SETTLEMENT_PLAYER_DUPLICATE", "Player result appears more than once")
		seen_player_ids[row.player_id] = true
		if match_state.find_player(row.player_id) == null:
			return _failure(&"SETTLEMENT_PLAYER_UNKNOWN", "Settlement player is not in match")
	for player: PLAYER_MATCH_STATE in match_state.players:
		if not seen_player_ids.has(player.player_id):
			return _failure(&"SETTLEMENT_PLAYER_MISSING", "Settlement is missing a match player")
	for row: MVP_CASE_PLAYER_RESULT in result.player_results:
		var player: PLAYER_MATCH_STATE = match_state.find_player(row.player_id)
		player.merit_progress += row.merit_delta
		player.reputation = clampi(player.reputation + row.reputation_delta, 0, 6)
		player.orb_count += row.orb_delta
		player.gacha_ticket_count += row.total_ticket_delta()
	match_state.applied_commit_ids.append(result.settlement_commit_id)
	return {
		"success": true,
		"code": "SETTLEMENT_APPLIED",
		"message": "Settlement applied once",
		"duplicate_noop": false,
	}


func _submission_context(resolution: PlayerCaseResolution) -> StringName:
	if resolution.outcome == CaseEnums.PlayerResolutionOutcome.NOT_SUBMITTED_CASE_ENDED:
		return &"NONE"
	return &"EARLY" if resolution.submission_phase == CaseEnums.SubmissionPhase.EARLY else &"FINAL"


func _status(resolution: PlayerCaseResolution) -> StringName:
	if resolution.outcome == CaseEnums.PlayerResolutionOutcome.NOT_SUBMITTED_CASE_ENDED:
		return &"CHUA_TRINH_AN"
	return &"CORRECT" if resolution.main_answer_correct else &"WRONG"


func _failure(code: StringName, message: String, duplicate := false) -> Dictionary:
	return {
		"success": false,
		"code": String(code),
		"message": message,
		"duplicate_noop": duplicate,
	}
