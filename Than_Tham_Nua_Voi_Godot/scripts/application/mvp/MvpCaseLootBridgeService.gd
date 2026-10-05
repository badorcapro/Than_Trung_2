class_name MvpCaseLootBridgeService
extends RefCounted

const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const PLAYER_MATCH_STATE := preload("res://scripts/domain/mvp/PlayerMatchState.gd")
const MVP_MATCH_STATE := preload("res://scripts/domain/mvp/MvpMatchState.gd")
const MVP_ROUND_STATE := preload("res://scripts/domain/mvp/MvpRoundState.gd")
const MVP_CASE_RESULT := preload("res://scripts/domain/mvp/MvpCaseResult.gd")
const MVP_CASE_PLAYER_RESULT := preload("res://scripts/domain/mvp/MvpCasePlayerResult.gd")
const MVP_TRANSITION_RESULT := preload("res://scripts/domain/mvp/MvpTransitionResult.gd")
const CASE_ADAPTER := preload("res://scripts/application/mvp/CaseSliceAdapter.gd")
const LOOT_ADAPTER := preload("res://scripts/application/mvp/LootSliceAdapter.gd")
const ORCHESTRATOR := preload("res://scripts/application/mvp/MvpRoundOrchestrator.gd")
const MVP_SERIALIZER := preload("res://scripts/application/mvp/MvpStateSerializer.gd")
const MATCH_VALIDATOR := preload("res://scripts/domain/mvp/MvpMatchStateValidator.gd")
const ROUND_VALIDATOR := preload("res://scripts/domain/mvp/MvpRoundStateValidator.gd")

const SETTLEMENT_COMMIT_ID := &"gd3_m2_settlement_fixture_001"

var match_state: MVP_MATCH_STATE
var round_state: MVP_ROUND_STATE
var case_definition: CaseDefinition
var case_runtime: CaseRuntimeState
var actual_settlement: CaseSettlementResult
var normalized_result: MVP_CASE_RESULT
var loot_players: Array[PlayerPhaseState] = []
var before_players: Dictionary = {}
var duplicate_apply_result: Dictionary = {}
var checkpoint_results: Dictionary = {}
var event_log: Array[String] = []

var _case_adapter: CASE_ADAPTER = CASE_ADAPTER.new()
var _loot_adapter: LOOT_ADAPTER = LOOT_ADAPTER.new()
var _orchestrator: ORCHESTRATOR = ORCHESTRATOR.new()
var _serializer: MVP_SERIALIZER = MVP_SERIALIZER.new()


func build_integration_fixture() -> Dictionary:
	_reset()
	case_definition = FixtureRepository.load_case()
	var source_players: Array[PlayerCaseState] = FixtureRepository.load_players()
	if case_definition == null or source_players.size() != 3:
		return _failure(&"FIXTURE_INVALID", "Canonical three-player Case fixture is required")
	match_state = MVP_MATCH_STATE.new()
	match_state.match_id = &"gd3_m2_match_fixture"
	match_state.character_selection_complete = true
	match_state.current_round_number = 1
	match_state.current_phase = MVP_ENUMS.Phase.ROUND_START
	match_state.open_policy_config_ids = {
		"perfect_reset_policy": "TEST_ONLY_OPEN_GD3_M0",
		"rate_up_policy": "TEST_ONLY_OPEN_GD3_M0",
	}
	for index: int in range(source_players.size()):
		var player: PLAYER_MATCH_STATE = _build_match_player(source_players[index], index)
		match_state.players.append(player)
		match_state.player_order.append(player.player_id)
		before_players[player.player_id] = player.to_dict()
	round_state = MVP_ROUND_STATE.new()
	round_state.round_id = &"gd3_m2_round_fixture_001"
	round_state.round_number = 1
	round_state.case_id = case_definition.case_id
	round_state.phase = MVP_ENUMS.Phase.ROUND_START
	round_state.loot_map_id = &"loot_map_g3_001"
	_orchestrator.initialize(match_state)
	var attach: Dictionary = _orchestrator.attach_round(round_state)
	if not bool(attach.get("success", false)):
		return attach
	checkpoint_results["before_case"] = _serializer.round_trip_diagnostic(match_state, round_state)
	var case_transition: MVP_TRANSITION_RESULT = _orchestrator.transition(MVP_ENUMS.Phase.CASE)
	if not case_transition.success:
		return case_transition.to_dict()
	case_runtime = CaseRuntimeState.new()
	case_runtime.initialize(case_definition, _case_adapter.project_players(match_state.players))
	case_runtime.turn_order_player_ids = match_state.player_order.duplicate()
	round_state.case_runtime_snapshot = {
		"initialized": true,
		"player_ids": _string_ids(match_state.player_order),
		"submission_count": 0,
	}
	event_log.append("Fixture built; phase CASE")
	return _success(&"FIXTURE_BUILT", "Three-player Match/Case fixture is ready")


func run_actual_settlement() -> Dictionary:
	if match_state == null or case_runtime == null or match_state.current_phase != MVP_ENUMS.Phase.CASE:
		return _failure(&"CASE_PHASE_REQUIRED", "Build fixture and enter CASE first")
	var correct_submission: CaseSubmission = _locked_submission(
		&"player_1", PackedInt32Array([4, 5]), PackedInt32Array([4]), PackedInt32Array([5])
	)
	var wrong_submission: CaseSubmission = _locked_submission(
		&"player_2", PackedInt32Array([1]), PackedInt32Array(), PackedInt32Array()
	)
	case_runtime.final_submissions.assign([correct_submission, wrong_submission])
	case_runtime.case_outcome = CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED
	actual_settlement = CaseSettlementService.new().settle(case_definition, case_runtime)
	if actual_settlement == null or not actual_settlement.success:
		return _failure(&"ACTUAL_SETTLEMENT_FAILED", "GĐ1 CaseSettlementService rejected fixture")
	normalized_result = _case_adapter.normalize_settlement(
		actual_settlement,
		case_definition.case_id,
		round_state.round_id,
		&"FINAL_VERDICT_RESOLVED",
		SETTLEMENT_COMMIT_ID
	)
	_reorder_normalized_results()
	var transition: MVP_TRANSITION_RESULT = _orchestrator.transition(
		MVP_ENUMS.Phase.CASE_SETTLEMENT
	)
	if not transition.success:
		return transition.to_dict()
	round_state.case_completion_reason = &"FINAL_VERDICT_RESOLVED"
	round_state.case_settlement_snapshot = normalized_result.to_dict()
	event_log.append("Actual GĐ1 settlement normalized; phase CASE_SETTLEMENT")
	return _success(&"SETTLEMENT_READY", "Actual GĐ1 settlement is ready to apply")


func apply_settlement() -> Dictionary:
	if normalized_result == null:
		return _failure(&"SETTLEMENT_MISSING", "Run actual settlement first")
	if match_state.current_phase != MVP_ENUMS.Phase.CASE_SETTLEMENT:
		return _failure(&"SETTLEMENT_PHASE_INVALID", "CASE_SETTLEMENT phase is required")
	var applied: Dictionary = _case_adapter.apply_once(match_state, normalized_result)
	if not bool(applied.get("success", false)):
		return applied
	round_state.settlement_commit_id = normalized_result.settlement_commit_id
	round_state.settlement_applied = true
	checkpoint_results["after_settlement"] = _serializer.round_trip_diagnostic(
		match_state, round_state
	)
	event_log.append("Commit %s applied once" % String(normalized_result.settlement_commit_id))
	return applied


func try_duplicate_apply() -> Dictionary:
	if normalized_result == null:
		return _failure(&"SETTLEMENT_MISSING", "Run actual settlement first")
	duplicate_apply_result = _case_adapter.apply_once(match_state, normalized_result)
	event_log.append("Duplicate commit result: %s" % String(duplicate_apply_result.get("code", "")))
	return duplicate_apply_result


func project_to_loot() -> Dictionary:
	if match_state == null or round_state == null:
		return _failure(&"BRIDGE_CONTEXT_MISSING", "Build fixture first")
	if not round_state.settlement_applied:
		return _failure(&"LOOT_BEFORE_SETTLEMENT", "Settlement must be applied before Loot")
	var transition: MVP_TRANSITION_RESULT = _orchestrator.transition(MVP_ENUMS.Phase.LOOT)
	if not transition.success:
		return transition.to_dict()
	loot_players.clear()
	for player: PLAYER_MATCH_STATE in match_state.players:
		loot_players.append(_loot_adapter.project_player(player, round_state.round_id))
	checkpoint_results["loot"] = _serializer.round_trip_diagnostic(match_state, round_state)
	event_log.append("Persistent MatchState projected to clean Loot state")
	return _success(&"LOOT_PROJECTED", "Three Loot PlayerPhaseState projections are ready")


func validate_bridge() -> Dictionary:
	var errors: Array[String] = []
	if match_state == null or round_state == null:
		errors.append("bridge context missing")
		return _validation(errors)
	if not MATCH_VALIDATOR.new().validate(match_state).passed():
		errors.append("MatchState invalid")
	if not ROUND_VALIDATOR.new().validate(round_state, match_state).passed():
		errors.append("RoundState invalid")
	if actual_settlement == null or not actual_settlement.success:
		errors.append("actual GĐ1 settlement missing")
	if normalized_result == null or normalized_result.player_results.size() != 3:
		errors.append("normalized result incomplete")
	if not round_state.settlement_applied:
		errors.append("settlement not applied")
	if match_state.current_phase != MVP_ENUMS.Phase.LOOT:
		errors.append("phase is not LOOT")
	if loot_players.size() != 3:
		errors.append("Loot projection count mismatch")
	_validate_players(errors)
	for key: String in ["before_case", "after_settlement", "loot"]:
		var checkpoint: Variant = checkpoint_results.get(key, {})
		if not checkpoint is Dictionary or not bool(checkpoint.get("matches", false)):
			var paths: Array[String] = []
			if checkpoint is Dictionary:
				var path_value: Variant = checkpoint.get("mismatch_paths", [])
				if path_value is Array:
					for path: Variant in path_value:
						paths.append(String(path))
			errors.append(
				"snapshot checkpoint %s mismatch: %s"
				% [key, ", ".join(paths) if not paths.is_empty() else "unknown path"]
			)
	return _validation(errors)


func run_full_bridge() -> Dictionary:
	var steps: Array[Callable] = [
		build_integration_fixture, run_actual_settlement, apply_settlement, project_to_loot
	]
	for step: Callable in steps:
		var result: Dictionary = step.call()
		if not bool(result.get("success", false)):
			return result
	return validate_bridge()


func report_text() -> String:
	var lines: Array[String] = []
	lines.append("[b]Phase:[/b] %s" % _phase_name())
	lines.append("[b]Case:[/b] %s" % (String(round_state.case_id) if round_state != null else "—"))
	lines.append("[b]Commit:[/b] %s" % (String(round_state.settlement_commit_id) if round_state != null else "—"))
	lines.append("")
	for player_id: StringName in [&"player_1", &"player_2", &"player_3"]:
		lines.append(_player_report(player_id))
	if not event_log.is_empty():
		lines.append("[b]Log[/b]")
		for line: String in event_log:
			lines.append("• %s" % line)
	return "\n".join(lines)


func _build_match_player(source: PlayerCaseState, index: int) -> PLAYER_MATCH_STATE:
	var player: PLAYER_MATCH_STATE = PLAYER_MATCH_STATE.new()
	player.player_id = source.player_id
	player.seat_index = index
	player.display_name = source.display_name
	player.character_id = StringName("character_%s" % char(97 + index))
	player.merit_progress = source.merit
	player.reputation = source.reputation
	player.orb_count = source.orb_count
	player.gacha_ticket_count = source.gacha_ticket_count
	player.silver_coin_count = 20 + index
	player.equipment_exp_material_count = 30 + index
	player.equipment_exchange_material_count = 40 + index
	player.consumable_inventory = [{"item_id": "item_fixture_%d" % (index + 1), "count": 2}]
	var equipment := EquipmentInstance.new()
	equipment.instance_id = StringName("gd3_m2_equipment_%d" % (index + 1))
	equipment.equipment_definition_id = &"relic_fixture_a"
	equipment.owner_player_id = player.player_id
	equipment.acquired_source = &"GD3_M2_TEST_ONLY"
	equipment.gold_star_level = 2 + index
	equipment.purple_star_level = index
	player.equipment_collection.append(equipment)
	player.relic_instance_id = equipment.instance_id
	player.gacha_state.consecutive_without_a_plus = 3 + index
	player.gacha_state.rate_up_consecutive_without_a_plus = 4 + index
	player.gacha_state.rate_up_state_by_banner = {"banner_fixture": 5 + index}
	player.gacha_state.equipment_exchange_price_by_definition = {"relic_fixture_a": 6 + index}
	player.gacha_state.ss_unlocked_equipment_ids = [&"relic_fixture_a"]
	player.gacha_state.ss_purchase_count_by_definition = {"relic_fixture_a": index}
	player.gacha_state.perfect_pool_remaining_hits = {"ss_choice_chest": 3 - index}
	player.gacha_state.perfect_weight_config_id = &"TEST_ONLY_PERFECT_OPEN_POLICY"
	return player


func _locked_submission(
	player_id: StringName,
	evil_ids: PackedInt32Array,
	underling_ids: PackedInt32Array,
	traitor_ids: PackedInt32Array
) -> CaseSubmission:
	var submission := CaseSubmission.new()
	submission.configure(
		player_id,
		1,
		evil_ids,
		underling_ids,
		traitor_ids,
		CaseEnums.SubmissionPhase.FINAL
	)
	submission.lock()
	return submission


func _reorder_normalized_results() -> void:
	var reordered: Array[MVP_CASE_PLAYER_RESULT] = []
	for player_id: StringName in [&"player_3", &"player_1", &"player_2"]:
		for row: MVP_CASE_PLAYER_RESULT in normalized_result.player_results:
			if row.player_id == player_id:
				reordered.append(row)
	normalized_result.player_results = reordered


func _validate_players(errors: Array[String]) -> void:
	if normalized_result == null:
		return
	for player: PLAYER_MATCH_STATE in match_state.players:
		var before_value: Variant = before_players.get(player.player_id, {})
		if not before_value is Dictionary:
			errors.append("before state missing for %s" % String(player.player_id))
			continue
		var before: Dictionary = before_value
		var row: MVP_CASE_PLAYER_RESULT = _result_for(player.player_id)
		if row == null:
			errors.append("result missing for %s" % String(player.player_id))
			continue
		if not is_equal_approx(player.merit_progress, float(before.get("merit_progress", 0.0)) + row.merit_delta):
			errors.append("merit mismatch for %s" % String(player.player_id))
		if player.reputation != clampi(int(before.get("reputation", 0)) + row.reputation_delta, 0, 6):
			errors.append("reputation mismatch for %s" % String(player.player_id))
		if player.orb_count != int(before.get("orb_count", 0)) + row.orb_delta:
			errors.append("Orb mismatch for %s" % String(player.player_id))
		if player.gacha_ticket_count != int(before.get("gacha_ticket_count", 0)) + row.total_ticket_delta():
			errors.append("Ticket mismatch for %s" % String(player.player_id))
		for field: String in [
			"silver_coin_count", "equipment_exp_material_count",
			"equipment_exchange_material_count", "consumable_inventory",
			"equipment_collection", "relic_instance_id", "gacha_state"
		]:
			if player.to_dict().get(field) != before.get(field):
				errors.append("%s changed for %s" % [field, String(player.player_id)])
		var loot: PlayerPhaseState = _loot_for(player.player_id)
		if loot == null:
			errors.append("Loot projection missing for %s" % String(player.player_id))
		elif (
			# Migration guard: compatibility mirrors must enter Loot empty.
			loot.orb_count != player.orb_count
			or loot.gacha_ticket_count != player.gacha_ticket_count
			or loot.reputation != player.reputation
			or not is_equal_approx(loot.merit_progress, player.merit_progress)
			or not loot.current_node_id.is_empty()
			or loot.remaining_moves != 0
			or not loot.reward_snapshots.is_empty()
			or not loot.temporary_effects.is_empty()
		):
			errors.append("Loot projection mismatch for %s" % String(player.player_id))


func _player_report(player_id: StringName) -> String:
	var before_value: Variant = before_players.get(player_id, {})
	var before: Dictionary = before_value if before_value is Dictionary else {}
	var row: MVP_CASE_PLAYER_RESULT = _result_for(player_id)
	var after: PLAYER_MATCH_STATE = match_state.find_player(player_id) if match_state != null else null
	var loot: PlayerPhaseState = _loot_for(player_id)
	if row == null:
		return "[b]%s[/b] — settlement pending\n" % String(player_id)
	return (
		"[b]%s — %s[/b]\nBefore M %.2f / R %d / O %d / T %d\n"
		+ "Delta %.2f / %d / %d / %d\nAfter M %.2f / R %d / O %d / T %d\n"
		+ "Loot O %s / T %s | Equipment %s | Gacha %s\n"
	) % [
		String(player_id), String(row.status), float(before.get("merit_progress", 0.0)),
		int(before.get("reputation", 0)), int(before.get("orb_count", 0)),
		int(before.get("gacha_ticket_count", 0)), row.merit_delta, row.reputation_delta,
		row.orb_delta, row.total_ticket_delta(), after.merit_progress if after != null else 0.0,
		after.reputation if after != null else 0, after.orb_count if after != null else 0,
		after.gacha_ticket_count if after != null else 0, loot.orb_count if loot != null else "—",
		loot.gacha_ticket_count if loot != null else "—",
		"OK" if loot != null and after != null and loot.relic_instance_id == after.relic_instance_id else "pending",
		"OK" if loot != null and after != null and loot.gacha_state.to_dict() == after.gacha_state.to_dict() else "pending",
	]


func _result_for(player_id: StringName) -> MVP_CASE_PLAYER_RESULT:
	if normalized_result == null:
		return null
	for row: MVP_CASE_PLAYER_RESULT in normalized_result.player_results:
		if row.player_id == player_id:
			return row
	return null


func _loot_for(player_id: StringName) -> PlayerPhaseState:
	for player: PlayerPhaseState in loot_players:
		if player.player_id == player_id:
			return player
	return null


func _phase_name() -> String:
	return MVP_ENUMS.phase_name(match_state.current_phase) if match_state != null else "NOT_BUILT"


func _string_ids(ids: Array[StringName]) -> Array[String]:
	var result: Array[String] = []
	for value: StringName in ids:
		result.append(String(value))
	return result


func _validation(errors: Array[String]) -> Dictionary:
	return {
		"success": errors.is_empty(),
		"code": "BRIDGE_VALID" if errors.is_empty() else "BRIDGE_INVALID",
		"message": "Bridge validation PASS" if errors.is_empty() else "; ".join(errors),
		"errors": errors,
	}


func _success(code: StringName, message: String) -> Dictionary:
	return {"success": true, "code": String(code), "message": message}


func _failure(code: StringName, message: String) -> Dictionary:
	return {"success": false, "code": String(code), "message": message}


func _reset() -> void:
	match_state = null
	round_state = null
	case_definition = null
	case_runtime = null
	actual_settlement = null
	normalized_result = null
	loot_players.clear()
	before_players.clear()
	duplicate_apply_result.clear()
	checkpoint_results.clear()
	event_log.clear()
