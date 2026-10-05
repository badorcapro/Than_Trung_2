class_name Gd3M2TestSuite
extends RefCounted

const BRIDGE_SERVICE := preload("res://scripts/application/mvp/MvpCaseLootBridgeService.gd")
const CASE_ADAPTER := preload("res://scripts/application/mvp/CaseSliceAdapter.gd")
const MVP_CASE_RESULT := preload("res://scripts/domain/mvp/MvpCaseResult.gd")
const MVP_CASE_PLAYER_RESULT := preload("res://scripts/domain/mvp/MvpCasePlayerResult.gd")
const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const MVP_MATCH_STATE := preload("res://scripts/domain/mvp/MvpMatchState.gd")
const MVP_ROUND_STATE := preload("res://scripts/domain/mvp/MvpRoundState.gd")
const PLAYER_MATCH_STATE := preload("res://scripts/domain/mvp/PlayerMatchState.gd")
const MVP_TRANSITION_RESULT := preload("res://scripts/domain/mvp/MvpTransitionResult.gd")
const MVP_ROUND_VALIDATOR := preload("res://scripts/domain/mvp/MvpRoundStateValidator.gd")
const ORCHESTRATOR := preload("res://scripts/application/mvp/MvpRoundOrchestrator.gd")
const MVP_SERIALIZER := preload("res://scripts/application/mvp/MvpStateSerializer.gd")

const SCENE_PATH := "res://scenes/mvp/Gd3M2CaseLootBridge.tscn"


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_test_runtime_bridge(rows)
	_test_readiness_guards(rows)
	_test_failure_paths(rows)
	_test_scene(rows)
	return rows


func _test_runtime_bridge(rows: Array[Dictionary]) -> void:
	var bridge: BRIDGE_SERVICE = BRIDGE_SERVICE.new()
	var built: Dictionary = bridge.build_integration_fixture()
	_add(rows, "M2 integration fixture builds", bool(built.get("success", false)))
	_add(rows, "M2 runtime scope is exactly three Case players", bridge.match_state.players.size() == 3 and bridge.case_runtime.players.size() == 3)
	_add(rows, "M2 fixture enters CASE through orchestrator", bridge.match_state.current_phase == MVP_ENUMS.Phase.CASE and bridge.round_state.phase == MVP_ENUMS.Phase.CASE)
	_add(rows, "M2 Case projection preserves player identity", bridge.case_runtime.players[0].player_id == bridge.match_state.players[0].player_id)
	_add(rows, "M2 Case projection preserves display name", bridge.case_runtime.players[0].display_name == bridge.match_state.players[0].display_name)
	_add(rows, "M2 Case projection preserves Merit", is_equal_approx(bridge.case_runtime.players[0].merit, bridge.match_state.players[0].merit_progress))
	_add(rows, "M2 Case projection preserves Reputation", bridge.case_runtime.players[0].reputation == bridge.match_state.players[0].reputation)
	_add(rows, "M2 Case projection preserves Orb and Ticket", bridge.case_runtime.players[0].orb_count == bridge.match_state.players[0].orb_count and bridge.case_runtime.players[0].gacha_ticket_count == bridge.match_state.players[0].gacha_ticket_count)
	_add(rows, "M2 Case-local submission resets", bridge.case_runtime.players[0].submission_status == CaseEnums.SubmissionStatus.NOT_SUBMITTED)
	_add(rows, "M2 Case-local active state resets", bridge.case_runtime.players[0].is_active_in_investigation)
	_add(rows, "M2 before-Case snapshot round-trips", bool(bridge.checkpoint_results["before_case"].get("matches", false)))
	var settlement_ready: Dictionary = bridge.run_actual_settlement()
	_add(rows, "M2 actual GĐ1 settlement succeeds", bool(settlement_ready.get("success", false)) and bridge.actual_settlement.success)
	_add(rows, "M2 settlement uses canonical Case result", bridge.actual_settlement is CaseSettlementResult and bridge.actual_settlement.player_resolutions.size() == 3)
	_add(rows, "M2 normalized result retains Case/Round IDs", bridge.normalized_result.case_id == bridge.case_definition.case_id and bridge.normalized_result.round_id == bridge.round_state.round_id)
	_add(rows, "M2 normalized result retains completion reason", bridge.normalized_result.completion_reason == &"FINAL_VERDICT_RESOLVED")
	_add(rows, "M2 normalized result retains commit ID", bridge.normalized_result.settlement_commit_id == BRIDGE_SERVICE.SETTLEMENT_COMMIT_ID)
	_add(rows, "M2 result order deliberately differs from Match order", bridge.normalized_result.player_results[0].player_id == &"player_3" and bridge.match_state.players[0].player_id == &"player_1")
	var correct: MVP_CASE_PLAYER_RESULT = _row(bridge, &"player_1")
	var wrong: MVP_CASE_PLAYER_RESULT = _row(bridge, &"player_2")
	var absent: MVP_CASE_PLAYER_RESULT = _row(bridge, &"player_3")
	_add(rows, "M2 correct status normalized", correct.status == &"CORRECT" and correct.submission_context == &"FINAL")
	_add(rows, "M2 correct main answer retained", correct.main_answer_correct)
	_add(rows, "M2 correct classification retained", correct.underling_classification_correct and correct.traitor_classification_correct)
	_add(rows, "M2 correct Merit comes from settlement", correct.merit_delta > 0.0)
	_add(rows, "M2 correct Reputation comes from settlement", correct.reputation_delta >= 0)
	_add(rows, "M2 correct base Ticket retained without classification bonus", correct.base_ticket_delta > 0 and correct.total_ticket_delta() == correct.base_ticket_delta)
	_add(rows, "M2 correct player receives no wrong-rule Orb", correct.orb_delta == 0)
	_add(rows, "M2 wrong status normalized", wrong.status == &"WRONG" and wrong.submission_context == &"FINAL")
	_add(rows, "M2 wrong Merit is zero", is_zero_approx(wrong.merit_delta))
	_add(rows, "M2 wrong Reputation penalty retained", wrong.reputation_delta < 0)
	_add(rows, "M2 wrong receives exactly one Orb", wrong.orb_delta == 1)
	_add(rows, "M2 wrong receives no correctness Ticket", wrong.total_ticket_delta() == 0)
	_add(rows, "M2 Chưa Trình Án status normalized", absent.status == &"CHUA_TRINH_AN" and absent.submission_context == &"NONE")
	_add(rows, "M2 Chưa Trình Án is not submitted", not absent.submitted)
	_add(rows, "M2 Chưa Trình Án has zero Case delta", is_zero_approx(absent.merit_delta) and absent.reputation_delta == 0 and absent.orb_delta == 0 and absent.total_ticket_delta() == 0)
	var before_non_case: Dictionary = _non_case_fingerprint(bridge.match_state)
	var apply: Dictionary = bridge.apply_settlement()
	_add(rows, "M2 settlement apply succeeds", bool(apply.get("success", false)))
	_add(rows, "M2 settlement joins reordered rows by player_id", bridge.match_state.find_player(&"player_1").orb_count == int(bridge.before_players[&"player_1"].get("orb_count", 0)) and bridge.match_state.find_player(&"player_2").orb_count == int(bridge.before_players[&"player_2"].get("orb_count", 0)) + 1)
	_add(rows, "M2 apply records settlement commit", bridge.match_state.applied_commit_ids.has(BRIDGE_SERVICE.SETTLEMENT_COMMIT_ID) and bridge.round_state.settlement_applied)
	_add(rows, "M2 non-Case economy remains unchanged", before_non_case == _non_case_fingerprint(bridge.match_state))
	_add(rows, "M2 after-settlement snapshot round-trips", bool(bridge.checkpoint_results["after_settlement"].get("matches", false)))
	var after_first: Dictionary = bridge.match_state.to_dict()
	var duplicate: Dictionary = bridge.try_duplicate_apply()
	_add(rows, "M2 duplicate commit is structured no-op", not bool(duplicate.get("success", true)) and bool(duplicate.get("duplicate_noop", false)))
	_add(rows, "M2 duplicate commit does not mutate MatchState", after_first == bridge.match_state.to_dict())
	var loot_result: Dictionary = bridge.project_to_loot()
	_add(rows, "M2 Match projects to Loot after settlement", bool(loot_result.get("success", false)) and bridge.loot_players.size() == 3)
	_add(rows, "M2 Loot projection carries updated Merit and Reputation", is_equal_approx(bridge.loot_players[0].merit_progress, bridge.match_state.players[0].merit_progress) and bridge.loot_players[1].reputation == bridge.match_state.players[1].reputation)
	_add(rows, "M2 Loot projection carries updated Orb and Ticket", bridge.loot_players[1].orb_count == bridge.match_state.players[1].orb_count and bridge.loot_players[0].gacha_ticket_count == bridge.match_state.players[0].gacha_ticket_count)
	_add(rows, "M2 Loot projection preserves Bag", bridge.loot_players[0].consumable_inventory == bridge.match_state.players[0].consumable_inventory)
	_add(rows, "M2 Loot projection preserves economy materials", bridge.loot_players[0].silver_coin_count == bridge.match_state.players[0].silver_coin_count and bridge.loot_players[0].equipment_exp_material_count == bridge.match_state.players[0].equipment_exp_material_count and bridge.loot_players[0].equipment_exchange_material_count == bridge.match_state.players[0].equipment_exchange_material_count)
	_add(rows, "M2 Equipment collection count preserved", bridge.loot_players[0].equipment_collection.size() == bridge.match_state.players[0].equipment_collection.size())
	_add(rows, "M2 Equipment instance ID preserved", bridge.loot_players[0].equipment_collection[0].instance_id == bridge.match_state.players[0].equipment_collection[0].instance_id)
	_add(rows, "M2 loadout ID still resolves", bridge.loot_players[0].relic_instance_id == bridge.match_state.players[0].relic_instance_id and bridge.loot_players[0].relic_instance_id == bridge.loot_players[0].equipment_collection[0].instance_id)
	_add(rows, "M2 Gacha Basic and Rate Up state preserved", bridge.loot_players[0].gacha_state.consecutive_without_a_plus == bridge.match_state.players[0].gacha_state.consecutive_without_a_plus and bridge.loot_players[0].gacha_state.rate_up_state_by_banner == bridge.match_state.players[0].gacha_state.rate_up_state_by_banner)
	_add(rows, "M2 Gacha exchange and SS state preserved", bridge.loot_players[0].gacha_state.equipment_exchange_price_by_definition == bridge.match_state.players[0].gacha_state.equipment_exchange_price_by_definition and bridge.loot_players[0].gacha_state.ss_purchase_count_by_definition == bridge.match_state.players[0].gacha_state.ss_purchase_count_by_definition)
	_add(rows, "M2 Perfect state and OPEN policy preserved", bridge.loot_players[0].gacha_state.perfect_pool_remaining_hits == bridge.match_state.players[0].gacha_state.perfect_pool_remaining_hits and bridge.loot_players[0].gacha_state.perfect_weight_config_id == &"TEST_ONLY_PERFECT_OPEN_POLICY")
	_add(rows, "M2 Loot current node and moves reset", bridge.loot_players.all(func(player: PlayerPhaseState) -> bool: return player.current_node_id.is_empty() and player.remaining_moves == 0))
	_add(rows, "M2 Loot reward and temporary effects reset", bridge.loot_players.all(func(player: PlayerPhaseState) -> bool: return player.reward_snapshots.is_empty() and player.temporary_effects.is_empty()))
	_add(rows, "M2 phase reaches LOOT", bridge.match_state.current_phase == MVP_ENUMS.Phase.LOOT and bridge.round_state.phase == MVP_ENUMS.Phase.LOOT)
	_add(rows, "M2 LOOT checkpoint round-trips", bool(bridge.checkpoint_results["loot"].get("matches", false)))
	var validation: Dictionary = bridge.validate_bridge()
	_add(rows, "M2 full bridge validation PASS", bool(validation.get("success", false)))
	var serialized: String = MVP_SERIALIZER.new().to_json(bridge.match_state, bridge.round_state)
	var restored: Dictionary = MVP_SERIALIZER.new().from_json(serialized)
	var restored_match: MVP_MATCH_STATE = restored.get("match_state") as MVP_MATCH_STATE
	_add(rows, "M2 commit ledger survives JSON", restored_match.applied_commit_ids.has(BRIDGE_SERVICE.SETTLEMENT_COMMIT_ID))
	_add(rows, "M2 duplicate remains blocked after restore", not bool(CASE_ADAPTER.new().apply_once(restored_match, bridge.normalized_result).get("success", true)))


func _test_readiness_guards(rows: Array[Dictionary]) -> void:
	var bridge: BRIDGE_SERVICE = BRIDGE_SERVICE.new()
	bridge.build_integration_fixture()
	_add(rows, "M2 Loot projection before settlement blocked", String(bridge.project_to_loot().get("code", "")) == "LOOT_BEFORE_SETTLEMENT")
	var direct: ORCHESTRATOR = ORCHESTRATOR.new()
	var match_state: MVP_MATCH_STATE = bridge.match_state
	var round_state: MVP_ROUND_STATE = bridge.round_state
	direct.initialize(match_state)
	direct.attach_round(round_state)
	var illegal: MVP_TRANSITION_RESULT = direct.transition(MVP_ENUMS.Phase.LOOT)
	_add(rows, "M2 CASE to LOOT direct transition rejected", not illegal.success and illegal.code == &"ILLEGAL_TRANSITION")
	bridge.run_actual_settlement()
	var not_applied: MVP_TRANSITION_RESULT = bridge._orchestrator.transition(MVP_ENUMS.Phase.LOOT)
	_add(rows, "M2 CASE_SETTLEMENT to LOOT requires applied commit", not not_applied.success and not_applied.code == &"SETTLEMENT_NOT_APPLIED")


func _test_failure_paths(rows: Array[Dictionary]) -> void:
	var bridge: BRIDGE_SERVICE = BRIDGE_SERVICE.new()
	bridge.build_integration_fixture()
	var adapter: CASE_ADAPTER = CASE_ADAPTER.new()
	_add(rows, "M2 missing settlement rejected", String(bridge.apply_settlement().get("code", "")) == "SETTLEMENT_MISSING")
	var empty_commit: MVP_CASE_RESULT = _complete_zero_result(bridge.match_state)
	_add(rows, "M2 empty settlement commit rejected", String(adapter.apply_once(bridge.match_state, empty_commit).get("code", "")) == "SETTLEMENT_COMMIT_MISSING")
	var unknown: MVP_CASE_RESULT = _complete_zero_result(bridge.match_state)
	unknown.settlement_commit_id = &"unknown_player_commit"
	unknown.player_results[0].player_id = &"unknown"
	_add(rows, "M2 invalid settlement player rejected", String(adapter.apply_once(bridge.match_state, unknown).get("code", "")) == "SETTLEMENT_PLAYER_UNKNOWN")
	var duplicate: MVP_CASE_RESULT = _complete_zero_result(bridge.match_state)
	duplicate.settlement_commit_id = &"duplicate_player_commit"
	duplicate.player_results[1].player_id = duplicate.player_results[0].player_id
	_add(rows, "M2 duplicate player result rejected", String(adapter.apply_once(bridge.match_state, duplicate).get("code", "")) == "SETTLEMENT_PLAYER_DUPLICATE")
	var missing: MVP_CASE_RESULT = _complete_zero_result(bridge.match_state)
	missing.settlement_commit_id = &"missing_player_commit"
	missing.player_results.pop_back()
	_add(rows, "M2 missing player result rejected", String(adapter.apply_once(bridge.match_state, missing).get("code", "")) == "SETTLEMENT_PLAYER_MISSING")
	var invalid_match: MVP_MATCH_STATE = MVP_MATCH_STATE.new()
	var invalid_result: MVP_CASE_RESULT = MVP_CASE_RESULT.new()
	invalid_result.settlement_commit_id = &"invalid_match_commit"
	_add(rows, "M2 invalid MatchState rejected", String(adapter.apply_once(invalid_match, invalid_result).get("code", "")) == "MATCH_STATE_INVALID")
	var invalid_round: MVP_ROUND_STATE = MVP_ROUND_STATE.new()
	_add(rows, "M2 invalid RoundState is diagnosed", not MVP_ROUND_VALIDATOR.new().validate(invalid_round).passed())


func _test_scene(rows: Array[Dictionary]) -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	_add(rows, "M2 integration harness scene loads", packed != null)
	if packed == null:
		_add(rows, "M2 harness has responsive body", false)
		_add(rows, "M2 harness exposes required actions", false)
		return
	var root: Node = packed.instantiate()
	var body: ScrollContainer = root.find_child("Body", true, false) as ScrollContainer
	var actions: GridContainer = root.find_child("Actions", true, false) as GridContainer
	_add(rows, "M2 harness has responsive body", body != null and body.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED)
	_add(rows, "M2 harness exposes required actions", actions != null and actions.get_child_count() == 8 and root.find_child("Back", true, false) != null)
	root.free()


func _complete_zero_result(match_state: MVP_MATCH_STATE) -> MVP_CASE_RESULT:
	var result: MVP_CASE_RESULT = MVP_CASE_RESULT.new()
	for player: PLAYER_MATCH_STATE in match_state.players:
		var row: MVP_CASE_PLAYER_RESULT = MVP_CASE_PLAYER_RESULT.new()
		row.player_id = player.player_id
		result.player_results.append(row)
	return result


func _row(bridge: BRIDGE_SERVICE, player_id: StringName) -> MVP_CASE_PLAYER_RESULT:
	for row: MVP_CASE_PLAYER_RESULT in bridge.normalized_result.player_results:
		if row.player_id == player_id:
			return row
	return null


func _non_case_fingerprint(match_state: MVP_MATCH_STATE) -> Dictionary:
	var result: Dictionary = {}
	for player: PLAYER_MATCH_STATE in match_state.players:
		var data: Dictionary = player.to_dict()
		result[String(player.player_id)] = {
			"silver_coin_count": data.get("silver_coin_count"),
			"equipment_exp_material_count": data.get("equipment_exp_material_count"),
			"equipment_exchange_material_count": data.get("equipment_exchange_material_count"),
			"consumable_inventory": data.get("consumable_inventory"),
			"equipment_collection": data.get("equipment_collection"),
			"relic_instance_id": data.get("relic_instance_id"),
			"gacha_state": data.get("gacha_state"),
		}
	return result


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({"name": name, "passed": passed, "detail": "GĐ3-M2 Case Settlement → MatchState → Loot invariant"})
