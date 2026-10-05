class_name MvpIntegratedTwoRoundCompletionSession
extends "res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd"

const M6_LOOT_SESSION := preload("res://scripts/domain/loot/LootRewardSession.gd")
const M6_EQUIPMENT_SESSION := preload(
	"res://scripts/domain/equipment/EquipmentManagementSession.gd"
)

const ROUND2_ROUND_END_COMMIT_ID := &"gd3_m6_round2_round_end_001"
const ACCEPTANCE_ENDPOINT := &"NEXT_CASE_REQUIRED"

var round2_start_match_snapshot: Dictionary = {}
var round2_pre_round_end_match_snapshot: Dictionary = {}
var round2_post_round_end_match_snapshot: Dictionary = {}
var round2_terminal_round_snapshot: Dictionary = {}
var round2_end_summary: Dictionary = {}


func build_at_round2_loot_initialized() -> Dictionary:
	var built: Dictionary = build_integrated_fixture()
	if not bool(built.get("success", false)):
		return built
	var round1: Dictionary = complete_round_1_programmatically()
	if not bool(round1.get("success", false)):
		return round1
	var started: Dictionary = start_next_round(ROUND2_CASE_ID)
	if not bool(started.get("success", false)):
		return started
	var boundary: MVP_CASE_COMPLETION_BOUNDARY = build_round2_test_only_completed_boundary()
	if boundary == null:
		return _failure(&"ROUND_2_BOUNDARY_MISSING", "Round 2 completion boundary is required")
	var settled: Dictionary = handle_round2_case_completion(boundary)
	if not bool(settled.get("success", false)):
		return settled
	var loot_begun: Dictionary = begin_round2_loot()
	if not bool(loot_begun.get("success", false)):
		return loot_begun
	round2_start_match_snapshot = match_state.to_dict()
	return _success(
		&"ROUND_2_LOOT_INITIALIZED",
		"M6 starts from the actual M5 Round 2 Loot session"
	)


func begin_round2_loot_end_confirmation() -> Dictionary:
	var result: Dictionary = begin_loot_end_confirmation()
	if bool(result.get("success", false)):
		checkpoints["round2_loot_finished"] = _serializer.round_trip_diagnostic(
			match_state, round_state
		)
	return result


func confirm_round2_loot_end(player_id: StringName) -> Dictionary:
	var result: Dictionary = confirm_loot_end(player_id)
	if (
		bool(result.get("success", false))
		and match_state.current_phase == M4_MVP_ENUMS.Phase.EQUIPMENT_MANAGEMENT
	):
		checkpoints["round2_confirmation_complete"] = _serializer.round_trip_diagnostic(
			match_state, round_state
		)
	return result


func mark_round2_management_done(player_id: StringName) -> Dictionary:
	var result: Dictionary = mark_management_done(player_id)
	if (
		bool(result.get("success", false))
		and equipment_session != null
		and equipment_session.phase == M6_EQUIPMENT_SESSION.Phase.READY_FOR_M6
	):
		checkpoints["round2_management_complete"] = _serializer.round_trip_diagnostic(
			match_state, round_state
		)
	return result


func commit_round2_end() -> Dictionary:
	if (
		_round_end_committed
		or match_state.applied_commit_ids.has(ROUND2_ROUND_END_COMMIT_ID)
	):
		return commit_round_end(ROUND2_ROUND_END_COMMIT_ID)
	# M4 validates the persistent candidate before publishing it. M6 also verifies
	# that all three phase authorities still point at this same Round 2 before the
	# inherited merge begins, making the final allowed transition deterministic.
	if (
		round_state == null
		or _orchestrator.active_round != round_state
		or round_state.phase != M4_MVP_ENUMS.Phase.EQUIPMENT_MANAGEMENT
		or match_state.current_phase != M4_MVP_ENUMS.Phase.EQUIPMENT_MANAGEMENT
	):
		return _failure(
			&"ROUND_END_AUTHORITY_DESYNCHRONIZED",
			"Round, Match, and Orchestrator must agree on Equipment Management"
		)
	round2_pre_round_end_match_snapshot = match_state.to_dict()
	checkpoints["round2_pre_round_end"] = _serializer.round_trip_diagnostic(
		match_state, round_state
	)
	var result: Dictionary = commit_round_end(ROUND2_ROUND_END_COMMIT_ID)
	if not bool(result.get("success", false)):
		return result
	round2_post_round_end_match_snapshot = match_state.to_dict()
	round2_terminal_round_snapshot = round_state.to_dict()
	checkpoints["round2_post_round_end"] = _serializer.round_trip_diagnostic(
		match_state, null
	)
	round2_end_summary = {
		"commit_id": String(ROUND2_ROUND_END_COMMIT_ID),
		"round_before": 2,
		"round_after": match_state.current_round_number,
		"status": String(match_state.match_completion_state),
		"active_round_cleared": _orchestrator.active_round == null,
		"round3_created": false,
		"match_complete": match_state.current_phase == M4_MVP_ENUMS.Phase.MATCH_COMPLETE,
	}
	_clear_round2_transient_references()
	event_log.append("Round 2 committed once; no Round 3 created; NEXT_CASE_REQUIRED")
	return _success(
		ACCEPTANCE_ENDPOINT,
		"Bounded two-Round proof complete; production next-Case input is required"
	)


func complete_round2_loot_programmatically() -> Dictionary:
	if loot_session == null:
		return _failure(&"ROUND_2_LOOT_SESSION_MISSING", "M5 Loot session is required")
	var guard: int = 0
	while (
		loot_session != null
		and loot_session.phase != M6_LOOT_SESSION.Phase.LOOT_END_CONFIRMATION_READY
		and guard < 160
	):
		guard += 1
		var action: Dictionary = {}
		match loot_session.phase:
			M6_LOOT_SESSION.Phase.ITEM_WINDOW:
				action = continue_without_item()
			M6_LOOT_SESSION.Phase.MOVEMENT:
				action = move()
			M6_LOOT_SESSION.Phase.BAG_OVERFLOW_PENDING:
				action = resolve_overflow_skip()
			_:
				return _failure(
					&"ROUND_2_LOOT_PHASE_UNHANDLED",
					"Programmatic completion stopped at phase %s" % str(loot_session.phase)
				)
		if not bool(action.get("success", false)):
			return action
	if loot_session == null or loot_session.phase != M6_LOOT_SESSION.Phase.LOOT_END_CONFIRMATION_READY:
		return _failure(&"ROUND_2_LOOT_GUARD_EXHAUSTED", "Loot did not finish deterministically")
	return _success(&"LOOT_END_CONFIRMATION_READY", "Actual Round 2 Loot is complete")


func complete_round2_after_loot_programmatically() -> Dictionary:
	var confirmation_started: Dictionary = begin_round2_loot_end_confirmation()
	if not bool(confirmation_started.get("success", false)):
		return confirmation_started
	var confirmation_order: Array[StringName] = equipment_session.player_order.duplicate()
	for player_id: StringName in confirmation_order:
		var confirmed: Dictionary = confirm_round2_loot_end(player_id)
		if not bool(confirmed.get("success", false)):
			return confirmed
	var management_order: Array[StringName] = equipment_session.player_order.duplicate()
	for player_id: StringName in management_order:
		var done: Dictionary = mark_round2_management_done(player_id)
		if not bool(done.get("success", false)):
			return done
	return commit_round2_end()


func required_m6_checkpoints_pass() -> bool:
	for key: String in [
		"round2_loot_initialized",
		"round2_loot_finished",
		"round2_confirmation_complete",
		"round2_management_complete",
		"round2_pre_round_end",
		"round2_post_round_end",
	]:
		var value: Variant = checkpoints.get(key, {})
		if not (value is Dictionary) or not bool((value as Dictionary).get("matches", false)):
			return false
	return true


func _clear_round2_transient_references() -> void:
	loot_session = null
	round2_loot_session = null
	equipment_session = null
	round2_case_definition = null
	round2_projected_case_players.clear()
	round2_case_runtime = null
	round2_turn_manager = null
	round2_normalized_result = null
	round2_settlement_summary.clear()
	round_state = null
	round2_loot_initialized = false
	_round2_started = false
	_round2_completion_handled = false
	_round2_loot_started = false
	_reset_active_continuation_references()
