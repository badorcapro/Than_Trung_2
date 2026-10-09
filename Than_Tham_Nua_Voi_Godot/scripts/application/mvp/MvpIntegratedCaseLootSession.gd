class_name MvpIntegratedCaseLootSession
extends RefCounted

const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const MVP_MATCH_STATE := preload("res://scripts/domain/mvp/MvpMatchState.gd")
const MVP_ROUND_STATE := preload("res://scripts/domain/mvp/MvpRoundState.gd")
const PLAYER_MATCH_STATE := preload("res://scripts/domain/mvp/PlayerMatchState.gd")
const MVP_CASE_RESULT := preload("res://scripts/domain/mvp/MvpCaseResult.gd")
const MVP_CASE_PLAYER_RESULT := preload("res://scripts/domain/mvp/MvpCasePlayerResult.gd")
const MVP_CASE_COMPLETION_BOUNDARY := preload(
	"res://scripts/domain/mvp/MvpCaseCompletionBoundary.gd"
)
const MVP_TRANSITION_RESULT := preload("res://scripts/domain/mvp/MvpTransitionResult.gd")
const M2_BRIDGE := preload("res://scripts/application/mvp/MvpCaseLootBridgeService.gd")
const CASE_ADAPTER := preload("res://scripts/application/mvp/CaseSliceAdapter.gd")
const LOOT_ADAPTER := preload("res://scripts/application/mvp/LootSliceAdapter.gd")
const ORCHESTRATOR := preload("res://scripts/application/mvp/MvpRoundOrchestrator.gd")
const MVP_SERIALIZER := preload("res://scripts/application/mvp/MvpStateSerializer.gd")
const LOOT_REWARD_SERVICE := preload("res://scripts/application/loot/LootRewardService.gd")
const GD2_FIXTURES := preload("res://scripts/application/loot/Gd2FixtureRepository.gd")
const SEQUENCE_REWARD_ROLL_SOURCE := preload(
	"res://scripts/infrastructure/SequenceRewardRollSource.gd"
)
const SEEDED_REWARD_ROLL_SOURCE := preload(
	"res://scripts/infrastructure/SeededRewardRollSource.gd"
)
const PRODUCTION_REWARD_REPOSITORY := preload(
	"res://scripts/application/loot/ProductionRewardRepository.gd"
)
const PRODUCTION_CONSUMABLE_REPOSITORY := preload(
	"res://scripts/application/loot/ProductionConsumableRepository.gd"
)
const SEEDED_MOVEMENT_ROLL_SOURCE := preload(
	"res://scripts/infrastructure/SeededMovementRollSource.gd"
)

const SETTLEMENT_COMMIT_ID := &"gd3_m3_actual_case_settlement_001"
const PLAYER_FACING_SETTLEMENT_COMMIT_ID := &"pf_m2_case_settlement_001"
const FIXTURE_MARKER := "TEST_ONLY / PROTOTYPE / NOT_CANON_LOCKED"

var match_state: MVP_MATCH_STATE
var round_state: MVP_ROUND_STATE
var case_definition: CaseDefinition
var projected_case_players: Array[PlayerCaseState] = []
var normalized_result: MVP_CASE_RESULT
var loot_session: LootRewardSession
var checkpoints: Dictionary = {}
var event_log: Array[String] = []
var phase_trace: Array[Dictionary] = []
var settlement_summary: Array[Dictionary] = []

var _case_adapter: CASE_ADAPTER = CASE_ADAPTER.new()
var _loot_adapter: LOOT_ADAPTER = LOOT_ADAPTER.new()
var _orchestrator: ORCHESTRATOR = ORCHESTRATOR.new()
var _serializer: MVP_SERIALIZER = MVP_SERIALIZER.new()
var _loot_service: LOOT_REWARD_SERVICE = LOOT_REWARD_SERVICE.new()
var _movement_rng: MovementRollSource = SEEDED_MOVEMENT_ROLL_SOURCE.new(20260828)
var _characters: Array[CharacterDefinition] = []
var _rewards: Array[RewardDefinition] = []
var _items: Array[ConsumableItemDefinition] = []
var _map_definition: LootMapDefinition
var _completion_handled := false
var _loot_started := false
var _settlement_commit_id: StringName = SETTLEMENT_COMMIT_ID


func build_integrated_fixture() -> Dictionary:
	_reset()
	var bridge: M2_BRIDGE = M2_BRIDGE.new()
	var built: Dictionary = bridge.build_integration_fixture()
	if not bool(built.get("success", false)):
		return _failure(&"M3_FIXTURE_INVALID", String(built.get("message", "M2 fixture failed")))
	match_state = bridge.match_state
	round_state = bridge.round_state
	case_definition = bridge.case_definition
	match_state.match_id = &"gd3_m3_integrated_match"
	match_state.fixture_marker = FIXTURE_MARKER
	_characters = GD2_FIXTURES.load_characters()
	if _characters.size() != match_state.players.size():
		return _failure(
			&"M3_CHARACTER_FIXTURE_INVALID", "Three authored Loot Characters are required"
		)
	for index: int in range(match_state.players.size()):
		match_state.players[index].character_id = _characters[index].character_id
	# Deterministic authored M4 item makes the real Item Window testable in M3.
	match_state.players[0].consumable_inventory = [{"item_id": "test_move_plus_1"}]
	round_state.round_id = &"gd3_m3_round_001"
	_map_definition = GD2_FIXTURES.load_m3_map()
	if _map_definition == null:
		return _failure(&"M3_LOOT_MAP_MISSING", "Authored M3 Loot map is required")
	round_state.loot_map_id = _map_definition.map_id
	_orchestrator.initialize(match_state)
	var attached: Dictionary = _orchestrator.attach_round(round_state)
	if not bool(attached.get("success", false)):
		return attached
	projected_case_players = _case_adapter.project_players(match_state.players)
	round_state.case_runtime_snapshot = {
		"initialized": true,
		"source": "ACTUAL_VS_CASE_MAIN",
		"player_ids": _player_id_strings(),
	}
	checkpoints["pre_case"] = _serializer.round_trip_diagnostic(match_state, round_state)
	_record_phase("before_actual_case")
	event_log.append("Integrated three-player fixture entered CASE")
	return _success(&"M3_CASE_READY", "Actual VSCaseMain can be launched")


func initialize_player_facing_case(
	source_match: MVP_MATCH_STATE, selected_case: CaseDefinition
) -> Dictionary:
	_reset()
	if source_match == null or selected_case == null:
		return _failure(&"PLAYER_CASE_CONTEXT_MISSING", "Match and Case are required")
	if (
		not source_match.character_selection_complete
		or source_match.players.size() != 3
		or source_match.current_phase != MVP_ENUMS.Phase.ROUND_START
	):
		return _failure(
			&"PLAYER_CASE_SETUP_INVALID",
			"Completed three-player setup at ROUND_START is required"
		)
	match_state = source_match
	case_definition = selected_case
	match_state.current_round_number = 1
	round_state = MVP_ROUND_STATE.new()
	round_state.round_id = &"player_facing_round_001"
	round_state.round_number = 1
	round_state.case_id = case_definition.case_id
	round_state.phase = MVP_ENUMS.Phase.ROUND_START
	_map_definition = GD2_FIXTURES.load_m3_map()
	if _map_definition != null:
		round_state.loot_map_id = _map_definition.map_id
	_orchestrator.initialize(match_state)
	var attached: Dictionary = _orchestrator.attach_round(round_state)
	if not bool(attached.get("success", false)):
		return attached
	var transition: MVP_TRANSITION_RESULT = _orchestrator.transition(MVP_ENUMS.Phase.CASE)
	if not transition.success:
		return _transition_failure(transition)
	projected_case_players = _case_adapter.project_players(match_state.players)
	round_state.case_runtime_snapshot = {
		"initialized": true,
		"source": "ACTUAL_VS_CASE_MAIN",
		"player_ids": _player_id_strings(),
	}
	_settlement_commit_id = PLAYER_FACING_SETTLEMENT_COMMIT_ID
	checkpoints["pre_case"] = _serializer.round_trip_diagnostic(match_state, round_state)
	_record_phase("player_facing_actual_case")
	event_log.append("Player-facing flow entered actual Case authority")
	return _success(&"PLAYER_CASE_READY", "Actual VSCaseMain can be launched")


func handle_case_completion(boundary: MVP_CASE_COMPLETION_BOUNDARY) -> Dictionary:
	if _completion_handled:
		return _failure(&"CASE_COMPLETION_DUPLICATE", "Case completion was already committed", true)
	if (
		match_state == null
		or round_state == null
		or match_state.current_phase != MVP_ENUMS.Phase.CASE
	):
		return _failure(&"CASE_CONTEXT_INVALID", "Active CASE context is required")
	if boundary == null or not boundary.is_valid() or boundary.case_id != round_state.case_id:
		return _failure(&"CASE_BOUNDARY_INVALID", "Typed Case completion boundary is invalid")
	_record_phase("case_completion_boundary")
	normalized_result = _case_adapter.normalize_settlement(
		boundary.settlement_result,
		boundary.case_id,
		round_state.round_id,
		boundary.completion_reason,
		_settlement_commit_id
	)
	var transition: MVP_TRANSITION_RESULT = _orchestrator.transition(
		MVP_ENUMS.Phase.CASE_SETTLEMENT
	)
	if not transition.success:
		return _transition_failure(transition)
	round_state.case_completion_reason = boundary.completion_reason
	round_state.case_runtime_snapshot = {
		"completed": true,
		"case_outcome": boundary.runtime_state.case_outcome,
		"turn_number": boundary.runtime_state.turn_number,
		"player_ids": _player_id_strings(),
	}
	round_state.case_settlement_snapshot = normalized_result.to_dict()
	var before_apply: Dictionary = match_state.to_dict()
	_record_phase("before_settlement_apply")
	var applied: Dictionary = _case_adapter.apply_once(match_state, normalized_result)
	if not bool(applied.get("success", false)):
		return applied
	round_state.settlement_commit_id = normalized_result.settlement_commit_id
	round_state.settlement_applied = true
	_record_phase("after_settlement_apply")
	_completion_handled = true
	_build_settlement_summary(before_apply)
	checkpoints["post_settlement"] = _serializer.round_trip_diagnostic(match_state, round_state)
	event_log.append("Actual GĐ1 settlement applied exactly once")
	return _success(&"CASE_SETTLEMENT_APPLIED", "Continue to actual Loot runtime")


func begin_loot() -> Dictionary:
	if _loot_started or loot_session != null:
		return _failure(
			&"LOOT_SESSION_ALREADY_ACTIVE", "Active Round already owns a Loot session", true
		)
	if not _completion_handled or not round_state.settlement_applied:
		return _failure(&"LOOT_BEFORE_SETTLEMENT", "Settlement must be applied first")
	_record_phase("continue_to_loot_requested")
	if not _is_case_settlement_synchronized():
		return _failure(
			&"LOOT_PHASE_NOT_READY",
			"Match, Round and Orchestrator must all be synchronized at CASE_SETTLEMENT"
		)
	var loot_players: Array[PlayerPhaseState] = []
	for player in match_state.players:
		loot_players.append(_loot_adapter.project_player(player, round_state.round_id))
	var candidate_session: LootRewardSession = _build_loot_reward_session(
		loot_players, [0, 1, 2, 3, 4, 5, 6]
	)
	if candidate_session == null:
		return _failure(
			&"LOOT_INITIALIZATION_FAILED",
			"GĐ2 Loot services rejected Character/map projection before transition"
		)
	var transition: MVP_TRANSITION_RESULT = _orchestrator.transition(MVP_ENUMS.Phase.LOOT)
	if not transition.success:
		return _transition_failure(transition)
	loot_session = candidate_session
	_loot_started = true
	_record_phase("loot_session_initialized")
	_capture_loot_snapshots()
	checkpoints["loot_initialized"] = _serializer.round_trip_diagnostic(match_state, round_state)
	event_log.append("Actual Loot initialized with one reward snapshot")
	return _success(&"LOOT_INITIALIZED", "Spawn, movement and reward runtime are active")


func _build_loot_reward_session(
	loot_players: Array[PlayerPhaseState], fixture_sequence: Array[int]
) -> LootRewardSession:
	if _map_definition != null and not _map_definition.test_only_not_canon_locked:
		_rewards = PRODUCTION_REWARD_REPOSITORY.load_rewards()
		_items = PRODUCTION_CONSUMABLE_REPOSITORY.load_all()
		return _loot_service.build_session(
			loot_players,
			_characters,
			_map_definition,
			_rewards,
			SEEDED_REWARD_ROLL_SOURCE.new(_production_reward_seed()),
			round_state.round_id,
			PRODUCTION_REWARD_REPOSITORY.load_tables()
		)
	_rewards = GD2_FIXTURES.load_m4_rewards()
	_items = GD2_FIXTURES.load_m4_items()
	return _loot_service.build_session(
		loot_players,
		_characters,
		_map_definition,
		_rewards,
		SEQUENCE_REWARD_ROLL_SOURCE.new(fixture_sequence),
		round_state.round_id
	)


func _production_reward_seed() -> int:
	var match_seed: int = match_state.case_generation_seed if match_state != null else 0
	var round_number: int = round_state.round_number if round_state != null else 1
	var mixed: int = posmod(match_seed + maxi(1, round_number) * 1000003, 2147483646)
	return maxi(1, mixed)


func loot_map_definition() -> LootMapDefinition:
	# Read-only presentation access to the exact authored map used by begin_loot().
	return _map_definition


func consumable_item_definitions() -> Array[ConsumableItemDefinition]:
	return _items.duplicate()


func consumable_item_display_name(item_id: StringName) -> String:
	for definition: ConsumableItemDefinition in _items:
		if definition != null and definition.item_id == item_id:
			return definition.display_name
	return ""


func continue_without_item() -> Dictionary:
	if loot_session == null:
		return _failure(&"LOOT_SESSION_MISSING", "Begin Loot first")
	if not _loot_service.continue_without_item(loot_session):
		return _failure(&"ITEM_WINDOW_REQUIRED", "Current Loot phase is not ITEM_WINDOW")
	return _after_loot_action(&"ITEM_WINDOW_CONTINUED", "Movement is ready")


func use_item(
	item_id: StringName,
	source: StringName = ConsumableItemService.SOURCE_PERSISTENT
) -> Dictionary:
	if loot_session == null:
		return _failure(&"LOOT_SESSION_MISSING", "Begin Loot first")
	var result: ItemUseResult = _loot_service.use_item(
		loot_session, item_id, _items, source
	)
	if result == null or not result.success:
		return _failure(
			result.code if result != null else &"ITEM_RESULT_MISSING", "Item use rejected"
		)
	return _after_loot_action(&"ITEM_USED", String(result.code))


func move(branch_choice: StringName = &"") -> Dictionary:
	if loot_session == null:
		return _failure(&"LOOT_SESSION_MISSING", "Begin Loot first")
	var action: MovementActionResult = _loot_service.perform_movement(
		loot_session, _map_definition, _movement_rng, _rewards, branch_choice, true
	)
	if loot_session.phase == LootRewardSession.Phase.BRANCH_SELECTION:
		var fork_id: StringName = (
			loot_session.movement_session.pending_branch.fork_node_id
			if loot_session.movement_session != null and loot_session.movement_session.pending_branch != null
			else &""
		)
		var pending_res: Dictionary = _after_loot_action(
			&"BRANCH_SELECTION_REQUIRED",
			"Đã đến ngã rẽ. Hãy chọn nhánh để tiếp tục di chuyển."
		)
		pending_res["fork_node_id"] = fork_id
		return pending_res
	if action == null:
		return _failure(&"MOVEMENT_ACTION_UNAVAILABLE", "Movement action is not legal now")
	var result: Dictionary = _after_loot_action(
		&"MOVEMENT_APPLIED",
		(
			"%s rolled %d and reached %s"
			% [String(action.player_id), action.roll_distance, String(action.end_node_id)]
		)
	)
	result["action"] = action
	return result


func choose_branch(chosen_branch_id: StringName) -> Dictionary:
	if loot_session == null:
		return _failure(&"LOOT_SESSION_MISSING", "Begin Loot first")
	var action: MovementActionResult = _loot_service.choose_branch(
		loot_session, _map_definition, chosen_branch_id, _rewards
	)
	if action == null:
		return _failure(&"BRANCH_CHOICE_REJECTED", "Không thể chọn nhánh này")
	var result: Dictionary = _after_loot_action(
		&"BRANCH_RESOLVED",
		(
			"%s took branch %s and reached %s"
			% [String(action.player_id), String(chosen_branch_id), String(action.end_node_id)]
		)
	)
	result["action"] = action
	return result


func resolve_overflow_discard(index: int) -> Dictionary:
	if (
		loot_session == null
		or not _loot_service.resolve_overflow_discard(loot_session, index, _rewards)
	):
		return _failure(&"OVERFLOW_DISCARD_REJECTED", "Cannot discard this Bag entry")
	return _after_loot_action(&"OVERFLOW_RESOLVED", "Incoming item accepted")


func resolve_overflow_skip() -> Dictionary:
	if loot_session == null or not _loot_service.resolve_overflow_skip(loot_session, _rewards):
		return _failure(&"OVERFLOW_SKIP_REJECTED", "No pending overflow exists")
	return _after_loot_action(&"OVERFLOW_RESOLVED", "Incoming item skipped")


func build_test_only_completed_boundary() -> MVP_CASE_COMPLETION_BOUNDARY:
	if case_definition == null or projected_case_players.size() != 3:
		return null
	var runtime := CaseRuntimeState.new()
	runtime.initialize(case_definition, _clone_case_players(projected_case_players))
	var correct := CaseSubmission.new()
	correct.configure(
		projected_case_players[0].player_id,
		1,
		PackedInt32Array([4, 5]),
		PackedInt32Array([4]),
		PackedInt32Array([5]),
		CaseEnums.SubmissionPhase.FINAL
	)
	var wrong := CaseSubmission.new()
	wrong.configure(
		projected_case_players[1].player_id,
		1,
		PackedInt32Array([1]),
		PackedInt32Array(),
		PackedInt32Array(),
		CaseEnums.SubmissionPhase.FINAL
	)
	correct.lock()
	wrong.lock()
	runtime.final_submissions.assign([correct, wrong])
	runtime.case_outcome = CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED
	var settlement: CaseSettlementResult = CaseSettlementService.new().settle(
		case_definition, runtime
	)
	var boundary: MVP_CASE_COMPLETION_BOUNDARY = MVP_CASE_COMPLETION_BOUNDARY.new()
	boundary.case_id = case_definition.case_id
	boundary.completion_reason = &"FINAL_VERDICT_RESOLVED"
	boundary.runtime_state = runtime
	boundary.settlement_result = settlement
	return boundary


func checkpoints_pass() -> bool:
	for key_value: Variant in checkpoints.keys():
		var key := String(key_value)
		var value: Variant = checkpoints.get(key, {})
		if not value is Dictionary or not bool(value.get("matches", false)):
			return false
	return not checkpoints.is_empty()


func checkpoint_mismatch_paths() -> Array[String]:
	var result: Array[String] = []
	for key_value: Variant in checkpoints.keys():
		var key := String(key_value)
		var value: Variant = checkpoints.get(key, {})
		if value is Dictionary and not bool(value.get("matches", false)):
			var paths_value: Variant = value.get("mismatch_paths", [])
			if paths_value is Array:
				for path: Variant in paths_value:
					result.append("%s: %s" % [key, String(path)])
	return result


func _after_loot_action(code: StringName, message: String) -> Dictionary:
	_sync_loot_to_match()
	_capture_loot_snapshots()
	if loot_session.phase == LootRewardSession.Phase.LOOT_END_CONFIRMATION_READY:
		var transition: MVP_TRANSITION_RESULT = _orchestrator.transition(
			MVP_ENUMS.Phase.LOOT_END_CONFIRMATION
		)
		if not transition.success:
			return _transition_failure(transition)
		round_state.round_completion_flags["loot_end_confirmation_ready"] = true
		_capture_loot_snapshots()
		checkpoints["loot_finished"] = _serializer.round_trip_diagnostic(match_state, round_state)
		event_log.append("Loot finished at LOOT_END_CONFIRMATION_READY; M3 stopped")
		return _success(&"LOOT_END_CONFIRMATION_READY", "M3 stop point reached")
	return _success(code, message)


func _sync_loot_to_match() -> void:
	if loot_session == null:
		return
	for loot_player: PlayerPhaseState in loot_session.players:
		var target: PLAYER_MATCH_STATE = match_state.find_player(loot_player.player_id)
		if target != null:
			_loot_adapter.merge_player(target, loot_player)


func _capture_loot_snapshots() -> void:
	if loot_session == null:
		return
	round_state.loot_movement_snapshot = (
		loot_session.movement_session.to_dict() if loot_session.movement_session != null else {}
	)
	round_state.loot_reward_snapshot = loot_session.to_dict()


func _build_settlement_summary(before_apply: Dictionary) -> void:
	settlement_summary.clear()
	var before_players_value: Variant = before_apply.get("players", [])
	var before_by_id: Dictionary = {}
	if before_players_value is Array:
		for value: Variant in before_players_value:
			if value is Dictionary:
				before_by_id[String(value.get("player_id", ""))] = value
	for player in match_state.players:
		var before: Dictionary = before_by_id.get(String(player.player_id), {})
		var normalized_row: MVP_CASE_PLAYER_RESULT = _normalized_player_result(player.player_id)
		(
			settlement_summary
			. append(
				{
					"player_id": String(player.player_id),
					"display_name": player.display_name,
					"status":
					String(normalized_row.status) if normalized_row != null else "MISSING",
					"main_answer_correct":
					normalized_row.main_answer_correct if normalized_row != null else false,
					"underling_classification_correct":
					normalized_row.underling_classification_correct if normalized_row != null else false,
					"traitor_classification_correct":
					normalized_row.traitor_classification_correct if normalized_row != null else false,
					"merit_delta": player.merit_progress - float(before.get("merit_progress", 0.0)),
					"reputation_before": int(before.get("reputation", 0)),
					"reputation_delta": player.reputation - int(before.get("reputation", 0)),
					"orb_delta": player.orb_count - int(before.get("orb_count", 0)),
					"normalized_orb_delta":
					normalized_row.orb_delta if normalized_row != null else 0,
					"ticket_delta":
					player.gacha_ticket_count - int(before.get("gacha_ticket_count", 0)),
					"base_ticket_delta":
					normalized_row.base_ticket_delta if normalized_row != null else 0,
					"merit_total": player.merit_progress,
					"reputation_total": player.reputation,
					"orb_total": player.orb_count,
					"ticket_total": player.gacha_ticket_count,
				}
			)
		)


func _player_id_strings() -> Array[String]:
	var result: Array[String] = []
	for player in match_state.players:
		result.append(String(player.player_id))
	return result


func _clone_case_players(source: Array[PlayerCaseState]) -> Array[PlayerCaseState]:
	var result: Array[PlayerCaseState] = []
	for player: PlayerCaseState in source:
		var copy := PlayerCaseState.new()
		copy.player_id = player.player_id
		copy.display_name = player.display_name
		copy.merit = player.merit
		copy.reputation = player.reputation
		copy.orb_count = player.orb_count
		copy.gacha_ticket_count = player.gacha_ticket_count
		copy.test_only_fixture = true
		result.append(copy)
	return result


func _reset() -> void:
	match_state = null
	round_state = null
	case_definition = null
	projected_case_players.clear()
	normalized_result = null
	loot_session = null
	checkpoints.clear()
	event_log.clear()
	phase_trace.clear()
	settlement_summary.clear()
	_completion_handled = false
	_loot_started = false
	_settlement_commit_id = SETTLEMENT_COMMIT_ID


func _success(code: StringName, message: String) -> Dictionary:
	return {
		"success": true,
		"code": String(code),
		"message": message,
		"source": "MvpIntegratedCaseLootSession",
		"phase": _phase_name(),
		"phase_trace": phase_trace.duplicate(true),
	}


func _failure(code: StringName, message: String, duplicate_noop: bool = false) -> Dictionary:
	return {
		"success": false,
		"code": String(code),
		"message": message,
		"source": "MvpIntegratedCaseLootSession",
		"phase": _phase_name(),
		"phase_trace": phase_trace.duplicate(true),
		"duplicate_noop": duplicate_noop,
	}


func _phase_name() -> String:
	if match_state == null:
		return "UNINITIALIZED"
	return String(MVP_ENUMS.phase_name(match_state.current_phase))


func _is_case_settlement_synchronized() -> bool:
	return (
		match_state != null
		and round_state != null
		and _orchestrator.match_state == match_state
		and _orchestrator.active_round == round_state
		and match_state.current_phase == MVP_ENUMS.Phase.CASE_SETTLEMENT
		and round_state.phase == MVP_ENUMS.Phase.CASE_SETTLEMENT
	)


func _normalized_player_result(player_id: StringName) -> MVP_CASE_PLAYER_RESULT:
	if normalized_result == null:
		return null
	for row: MVP_CASE_PLAYER_RESULT in normalized_result.player_results:
		if row.player_id == player_id:
			return row
	return null


func _record_phase(label: String) -> void:
	(
		phase_trace
		. append(
			{
				"label": label,
				"match_phase": match_state.current_phase if match_state != null else -1,
				"round_phase": round_state.phase if round_state != null else -1,
				"orchestrator_match_phase":
				(
					_orchestrator.match_state.current_phase
					if _orchestrator.match_state != null
					else -1
				),
			}
		)
	)


func _transition_failure(transition: MVP_TRANSITION_RESULT) -> Dictionary:
	return _failure(
		transition.code,
		(
			"%s (%s → %s)"
			% [
				transition.message,
				String(MVP_ENUMS.phase_name(transition.source_phase)),
				String(MVP_ENUMS.phase_name(transition.target_phase)),
			]
		)
	)
