class_name Gd3M1TestSuite
extends RefCounted

const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const PLAYER_MATCH_STATE := preload("res://scripts/domain/mvp/PlayerMatchState.gd")
const MVP_MATCH_STATE := preload("res://scripts/domain/mvp/MvpMatchState.gd")
const MVP_ROUND_STATE := preload("res://scripts/domain/mvp/MvpRoundState.gd")
const MVP_MATCH_VALIDATOR := preload("res://scripts/domain/mvp/MvpMatchStateValidator.gd")
const MVP_ROUND_VALIDATOR := preload("res://scripts/domain/mvp/MvpRoundStateValidator.gd")
const MVP_SERIALIZER := preload("res://scripts/application/mvp/MvpStateSerializer.gd")
const CASE_ADAPTER := preload("res://scripts/application/mvp/CaseSliceAdapter.gd")
const LOOT_ADAPTER := preload("res://scripts/application/mvp/LootSliceAdapter.gd")
const ORCHESTRATOR := preload("res://scripts/application/mvp/MvpRoundOrchestrator.gd")
const MVP_CASE_RESULT := preload("res://scripts/domain/mvp/MvpCaseResult.gd")
const MVP_CASE_PLAYER_RESULT := preload("res://scripts/domain/mvp/MvpCasePlayerResult.gd")
const MVP_VALIDATION_REPORT := preload("res://scripts/domain/mvp/MvpValidationReport.gd")


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_test_match_contract(rows)
	_test_round_contract(rows)
	_test_serializer(rows)
	_test_case_adapter(rows)
	_test_loot_adapter(rows)
	_test_orchestrator(rows)
	_test_player_counts(rows)
	return rows


func _test_match_contract(rows: Array[Dictionary]) -> void:
	var validator: MVP_MATCH_VALIDATOR = MVP_MATCH_VALIDATOR.new()
	var valid: MVP_MATCH_STATE = _match(3)
	_add(rows, "M1 valid MatchState passes", validator.validate(valid).passed())
	var new_match_round_trip: Dictionary = MVP_SERIALIZER.new().round_trip_diagnostic(_match(1))
	_add(rows, "M1 new Match without active Round round-trips", bool(new_match_round_trip.get("matches", false)))
	_add(rows, "M1 player order is explicit", valid.player_order == [&"player_1", &"player_2", &"player_3"])
	_add(rows, "M1 selected Character is persistent", valid.players[0].character_id == &"character_a")
	var bad_reputation: MVP_MATCH_STATE = _match(1)
	bad_reputation.players[0].reputation = 7
	_add(rows, "M1 reputation range rejected", _has(validator.validate(bad_reputation), "REPUTATION_OUT_OF_RANGE"))
	var bad_resource: MVP_MATCH_STATE = _match(1)
	bad_resource.players[0].orb_count = -1
	_add(rows, "M1 negative persistent resource rejected", _has(validator.validate(bad_resource), "RESOURCE_NEGATIVE"))
	var duplicate_id: MVP_MATCH_STATE = _match(3)
	duplicate_id.players[1].player_id = duplicate_id.players[0].player_id
	_add(rows, "M1 duplicate player ID rejected", _has(validator.validate(duplicate_id), "PLAYER_ID_DUPLICATE"))
	var duplicate_seat: MVP_MATCH_STATE = _match(3)
	duplicate_seat.players[1].seat_index = duplicate_seat.players[0].seat_index
	_add(rows, "M1 duplicate seat rejected", _has(validator.validate(duplicate_seat), "SEAT_DUPLICATE"))
	var missing_character: MVP_MATCH_STATE = _match(1)
	missing_character.players[0].character_id = &""
	_add(rows, "M1 completed selection requires Character", _has(validator.validate(missing_character), "CHARACTER_MISSING"))
	var bad_policy: MVP_MATCH_STATE = _match(1)
	bad_policy.open_policy_config_ids = {"": ""}
	_add(rows, "M1 OPEN policy IDs require explicit values", _has(validator.validate(bad_policy), "OPEN_POLICY_INVALID"))
	var duplicate_commit: MVP_MATCH_STATE = _match(1)
	duplicate_commit.applied_commit_ids = [&"commit_a", &"commit_a"]
	_add(rows, "M1 duplicate commit IDs rejected", _has(validator.validate(duplicate_commit), "COMMIT_ID_DUPLICATE"))
	_add(rows, "M1 state carries TEST_ONLY marker", valid.fixture_marker.contains("TEST_ONLY"))


func _test_round_contract(rows: Array[Dictionary]) -> void:
	var validator: MVP_ROUND_VALIDATOR = MVP_ROUND_VALIDATOR.new()
	var match_state: MVP_MATCH_STATE = _match(1)
	match_state.current_phase = MVP_ENUMS.Phase.ROUND_START
	var round_state: MVP_ROUND_STATE = _round(MVP_ENUMS.Phase.ROUND_START)
	_add(rows, "M1 valid RoundState passes", validator.validate(round_state, match_state).passed())
	var missing_commit: MVP_ROUND_STATE = _round(MVP_ENUMS.Phase.CASE_SETTLEMENT)
	missing_commit.settlement_applied = true
	_add(rows, "M1 applied settlement requires commit ID", _has(validator.validate(missing_commit), "SETTLEMENT_COMMIT_MISSING"))
	var mismatch: MVP_ROUND_STATE = _round(MVP_ENUMS.Phase.CASE)
	_add(rows, "M1 Match/Round phase mismatch rejected", _has(validator.validate(mismatch, match_state), "PHASE_MISMATCH"))
	var round_end: MVP_ROUND_STATE = _ready_round_end()
	_add(rows, "M1 complete Round End passes", validator.validate(round_end).passed())
	round_end.round_completion_flags["pending_choice"] = true
	_add(rows, "M1 Round End pending choice rejected", _has(validator.validate(round_end), "ROUND_END_PENDING_STATE"))
	round_end = _ready_round_end()
	round_end.round_completion_flags["reward_complete"] = false
	_add(rows, "M1 incomplete reward phase rejected", _has(validator.validate(round_end), "ROUND_END_INCOMPLETE"))
	round_end = _ready_round_end()
	round_end.settlement_applied = false
	_add(rows, "M1 Round End requires settlement", _has(validator.validate(round_end), "ROUND_END_SETTLEMENT_PENDING"))
	var object_snapshot: MVP_ROUND_STATE = _round(MVP_ENUMS.Phase.CASE)
	object_snapshot.case_runtime_snapshot = {"forbidden": RefCounted.new()}
	_add(rows, "M1 snapshots reject Object references", _has(validator.validate(object_snapshot), "ROUND_SNAPSHOT_OBJECT"))


func _test_serializer(rows: Array[Dictionary]) -> void:
	var serializer: MVP_SERIALIZER = MVP_SERIALIZER.new()
	var match_state: MVP_MATCH_STATE = _match(3)
	match_state.current_phase = MVP_ENUMS.Phase.LOOT
	match_state.applied_commit_ids.append(&"settlement_1")
	match_state.players[0].equipment_collection.append(_equipment(&"eq_1", &"player_1"))
	match_state.players[0].relic_instance_id = &"eq_1"
	match_state.players[0].gacha_state.consecutive_without_a_plus = 4
	var round_state: MVP_ROUND_STATE = _round(MVP_ENUMS.Phase.LOOT)
	round_state.loot_movement_snapshot = {"current_player_id": "player_2", "remaining_moves": 1}
	var snapshot: Dictionary = serializer.build_snapshot(match_state, round_state)
	_add(rows, "M1 snapshot schema is explicit", int(snapshot.get("schema_version", 0)) == 1)
	_add(rows, "M1 snapshot stores current phase", int(snapshot.get("current_phase", -1)) == MVP_ENUMS.Phase.LOOT)
	_add(rows, "M1 snapshot stores build label", String(snapshot.get("build_label", "")) == AppVersion.BUILD_LABEL)
	var restored: Dictionary = serializer.from_json(serializer.to_json(match_state, round_state))
	_add(rows, "M1 snapshot JSON restores successfully", bool(restored.get("success", false)))
	var restored_match: MVP_MATCH_STATE = restored.get("match_state") as MVP_MATCH_STATE
	var restored_round: MVP_ROUND_STATE = restored.get("round_state") as MVP_ROUND_STATE
	_add(rows, "M1 MatchState semantic round-trip", match_state.semantically_equals(restored_match))
	_add(rows, "M1 RoundState semantic round-trip", round_state.semantically_equals(restored_round))
	_add(rows, "M1 Equipment instance ID round-trip", restored_match.players[0].equipment_collection[0].instance_id == &"eq_1")
	_add(rows, "M1 Gacha counters round-trip", restored_match.players[0].gacha_state.consecutive_without_a_plus == 4)
	_add(rows, "M1 commit ledger round-trip", restored_match.applied_commit_ids == [&"settlement_1"])
	_add(rows, "M1 invalid JSON is structured failure", String(serializer.from_json("[").get("code", "")) == "SNAPSHOT_JSON_INVALID")
	var unsupported: Dictionary = snapshot.duplicate(true)
	unsupported["schema_version"] = 99
	_add(rows, "M1 unsupported schema is rejected", String(serializer.from_dict(unsupported).get("code", "")) == "SNAPSHOT_SCHEMA_UNSUPPORTED")
	var diagnostic: Dictionary = serializer.round_trip_diagnostic(match_state, round_state)
	_add(rows, "M1 round-trip diagnostic identifies equality", bool(diagnostic.get("matches", false)) and _optional_round_shapes_round_trip(serializer))


func _test_case_adapter(rows: Array[Dictionary]) -> void:
	var adapter: CASE_ADAPTER = CASE_ADAPTER.new()
	var match_state: MVP_MATCH_STATE = _match(1)
	var player: PLAYER_MATCH_STATE = match_state.players[0]
	player.merit_progress = 1.5
	player.orb_count = 2
	player.gacha_ticket_count = 3
	player.silver_coin_count = 7
	player.equipment_collection.append(_equipment(&"eq_case_guard", player.player_id))
	var projected: PlayerCaseState = adapter.project_player(player)
	_add(rows, "M1 Case projection preserves identity", projected.player_id == player.player_id)
	_add(rows, "M1 Case projection carries Case economy", projected.merit == 1.5 and projected.orb_count == 2 and projected.gacha_ticket_count == 3)
	_add(rows, "M1 Case projection resets submission", projected.submission_status == CaseEnums.SubmissionStatus.NOT_SUBMITTED)
	_add(rows, "M1 Case projection resets active status", projected.is_active_in_investigation)
	var result: MVP_CASE_RESULT = MVP_CASE_RESULT.new()
	result.settlement_commit_id = &"case_commit_1"
	var row: MVP_CASE_PLAYER_RESULT = MVP_CASE_PLAYER_RESULT.new()
	row.player_id = player.player_id
	row.merit_delta = 2.0
	row.reputation_delta = -1
	row.orb_delta = 4
	row.base_ticket_delta = 1
	result.player_results.append(row)
	var applied: Dictionary = adapter.apply_once(match_state, result)
	_add(rows, "M1 settlement applies successfully", bool(applied.get("success", false)))
	_add(rows, "M1 settlement applies merit/reputation", player.merit_progress == 3.5 and player.reputation == 4)
	_add(rows, "M1 settlement applies Orb/Ticket", player.orb_count == 6 and player.gacha_ticket_count == 4)
	_add(rows, "M1 settlement does not mutate Loot-only currency", player.silver_coin_count == 7)
	_add(rows, "M1 settlement does not mutate Equipment", player.equipment_collection.size() == 1)
	var duplicate: Dictionary = adapter.apply_once(match_state, result)
	_add(rows, "M1 settlement duplicate is structured no-op", not bool(duplicate.get("success", true)) and bool(duplicate.get("duplicate_noop", false)))
	_add(rows, "M1 settlement duplicate does not double reward", player.orb_count == 6 and player.merit_progress == 3.5 and player.gacha_ticket_count == 4)
	var unknown: MVP_CASE_RESULT = MVP_CASE_RESULT.new()
	unknown.settlement_commit_id = &"case_commit_unknown"
	var unknown_row: MVP_CASE_PLAYER_RESULT = MVP_CASE_PLAYER_RESULT.new()
	unknown_row.player_id = &"unknown"
	unknown.player_results.append(unknown_row)
	_add(rows, "M1 settlement rejects unknown player", String(adapter.apply_once(match_state, unknown).get("code", "")) == "SETTLEMENT_PLAYER_UNKNOWN")


func _test_loot_adapter(rows: Array[Dictionary]) -> void:
	var adapter: LOOT_ADAPTER = LOOT_ADAPTER.new()
	var target: PLAYER_MATCH_STATE = _player(0)
	target.orb_count = 5
	target.silver_coin_count = 2
	target.equipment_collection.append(_equipment(&"eq_loot", target.player_id))
	target.relic_instance_id = &"eq_loot"
	var projected: PlayerPhaseState = adapter.project_player(target, &"round_1")
	_add(rows, "M1 Loot projection preserves identity", projected.player_id == target.player_id and projected.round_id == &"round_1")
	_add(rows, "M1 Loot projection carries persistent economy", projected.orb_count == 5 and projected.silver_coin_count == 2)
	_add(rows, "M1 Loot projection preserves Equipment IDs", projected.equipment_collection[0].instance_id == &"eq_loot")
	_add(rows, "M1 Loot projection resets movement transient", projected.current_node_id.is_empty() and projected.remaining_moves == 0)
	_add(rows, "M1 Loot projection resets reward transient", projected.reward_snapshots.is_empty() and projected.temporary_effects.is_empty())
	projected.orb_count = 8
	projected.silver_coin_count = 9
	projected.current_node_id = &"node_transient"
	projected.remaining_moves = 3
	var merged: Dictionary = adapter.merge_player(target, projected)
	_add(rows, "M1 Loot merge succeeds", bool(merged.get("success", false)))
	_add(rows, "M1 Loot merge updates persistent resources", target.orb_count == 8 and target.silver_coin_count == 9)
	_add(rows, "M1 Loot merge preserves stable Equipment identity", target.equipment_collection[0].instance_id == &"eq_loot")
	_add(rows, "M1 Loot merge explicitly ignores transient state", bool(merged.get("ignored_transient", false)) and not target.to_dict().has("current_node_id"))
	var wrong: PlayerPhaseState = adapter.project_player(target, &"round_1")
	wrong.player_id = &"other"
	_add(rows, "M1 Loot merge rejects identity mismatch", String(adapter.merge_player(target, wrong).get("code", "")) == "LOOT_MERGE_IDENTITY_MISMATCH")


func _test_orchestrator(rows: Array[Dictionary]) -> void:
	var match_state: MVP_MATCH_STATE = _match(1)
	match_state.current_phase = MVP_ENUMS.Phase.ROUND_START
	var round_state: MVP_ROUND_STATE = _round(MVP_ENUMS.Phase.ROUND_START)
	var service: ORCHESTRATOR = ORCHESTRATOR.new()
	service.initialize(match_state)
	_add(rows, "M1 orchestrator attaches phase-aligned Round", bool(service.attach_round(round_state).get("success", false)))
	var legal = service.transition(MVP_ENUMS.Phase.CASE)
	_add(rows, "M1 legal transition succeeds", legal.success and legal.code == &"TRANSITION_APPLIED")
	_add(rows, "M1 transition keeps Match/Round phase synced", match_state.current_phase == MVP_ENUMS.Phase.CASE and round_state.phase == MVP_ENUMS.Phase.CASE)
	var illegal = service.transition(MVP_ENUMS.Phase.LOOT)
	_add(rows, "M1 illegal transition is structured failure", not illegal.success and illegal.code == &"ILLEGAL_TRANSITION")
	var win = service.transition(MVP_ENUMS.Phase.MATCH_COMPLETE)
	_add(rows, "M1 completion requires future Win service", not win.success and win.code == &"WIN_SERVICE_REQUIRED")
	match_state.current_phase = MVP_ENUMS.Phase.ROUND_END
	round_state = _ready_round_end()
	service.active_round = round_state
	var committed = service.commit_round_end(&"round_end_1")
	_add(rows, "M1 Round End commit succeeds", committed.success and committed.code == &"NEXT_CASE_REQUIRED")
	_add(rows, "M1 Round End increments exactly once", match_state.current_round_number == 2)
	_add(rows, "M1 Round End returns to Round Start", match_state.current_phase == MVP_ENUMS.Phase.ROUND_START and service.active_round == null)
	var duplicate = service.commit_round_end(&"round_end_1")
	_add(rows, "M1 Round End duplicate rejected", not duplicate.success and duplicate.code == &"ROUND_END_ALREADY_APPLIED")
	_add(rows, "M1 duplicate Round End cannot increment", match_state.current_round_number == 2)


func _test_player_counts(rows: Array[Dictionary]) -> void:
	var validator: MVP_MATCH_VALIDATOR = MVP_MATCH_VALIDATOR.new()
	_add(rows, "M1 supports one player", validator.validate(_match(1)).passed())
	_add(rows, "M1 supports three players", validator.validate(_match(3)).passed())
	_add(rows, "M1 supports four players", validator.validate(_match(4)).passed())
	_add(rows, "M1 rejects zero players", _has(validator.validate(_match(0)), "PLAYER_COUNT_INVALID"))


func _match(player_count: int) -> MVP_MATCH_STATE:
	var result: MVP_MATCH_STATE = MVP_MATCH_STATE.new()
	result.match_id = &"match_m1_test"
	result.character_selection_complete = true
	result.current_round_number = 1
	result.open_policy_config_ids = {"perfect_weights": "OPEN_GD3_M0"}
	for index: int in range(player_count):
		var player: PLAYER_MATCH_STATE = _player(index)
		result.players.append(player)
		result.player_order.append(player.player_id)
	return result


func _player(index: int) -> PLAYER_MATCH_STATE:
	var result: PLAYER_MATCH_STATE = PLAYER_MATCH_STATE.new()
	result.player_id = StringName("player_%d" % (index + 1))
	result.seat_index = index
	result.display_name = "Player %d" % (index + 1)
	result.character_id = StringName("character_%s" % char(97 + index))
	return result


func _round(phase: int) -> MVP_ROUND_STATE:
	var result: MVP_ROUND_STATE = MVP_ROUND_STATE.new()
	result.round_id = &"round_1"
	result.round_number = 1
	result.case_id = &"case_fixture_001"
	result.loot_map_id = &"loot_fixture_001"
	result.phase = phase
	return result


func _ready_round_end() -> MVP_ROUND_STATE:
	var result: MVP_ROUND_STATE = _round(MVP_ENUMS.Phase.ROUND_END)
	result.settlement_applied = true
	result.settlement_commit_id = &"settlement_1"
	result.round_completion_flags = {
		"movement_complete": true,
		"reward_complete": true,
		"management_complete": true,
		"pending_overflow": false,
		"pending_choice": false,
		"pending_reward": false,
	}
	return result


func _optional_round_shapes_round_trip(serializer: MVP_SERIALIZER) -> bool:
	var shapes: Array[MVP_ROUND_STATE] = []
	var fresh: MVP_ROUND_STATE = _round(MVP_ENUMS.Phase.ROUND_START)
	shapes.append(fresh)
	var case_state: MVP_ROUND_STATE = _round(MVP_ENUMS.Phase.CASE)
	case_state.case_runtime_snapshot = {
		"current_player_id": &"player_1", "turn": 2, "merit_preview": 1.5
	}
	shapes.append(case_state)
	var settlement: MVP_ROUND_STATE = _round(MVP_ENUMS.Phase.CASE_SETTLEMENT)
	settlement.case_completion_reason = &"FINAL_VERDICT"
	settlement.case_settlement_snapshot = {"player_results": [{"player_id": &"player_1"}]}
	settlement.settlement_commit_id = &"settlement_optional"
	settlement.settlement_applied = true
	shapes.append(settlement)
	var loot: MVP_ROUND_STATE = _round(MVP_ENUMS.Phase.LOOT)
	loot.loot_movement_snapshot = {"remaining_moves": 1, "path": [&"a", &"b"]}
	loot.loot_reward_snapshot = {"pending_reward": false, "cursor": 0}
	shapes.append(loot)
	var management: MVP_ROUND_STATE = _round(MVP_ENUMS.Phase.EQUIPMENT_MANAGEMENT)
	management.equipment_management_snapshot = {"done_player_ids": [&"player_1"]}
	shapes.append(management)
	shapes.append(_ready_round_end())
	for round_state: MVP_ROUND_STATE in shapes:
		var match_state: MVP_MATCH_STATE = _match(1)
		match_state.current_phase = round_state.phase
		var diagnostic: Dictionary = serializer.round_trip_diagnostic(match_state, round_state)
		if not bool(diagnostic.get("matches", false)):
			return false
	return true


func _equipment(instance_id: StringName, owner_id: StringName) -> EquipmentInstance:
	var result := EquipmentInstance.new()
	result.instance_id = instance_id
	result.equipment_definition_id = &"relic_fixture_a"
	result.owner_player_id = owner_id
	result.acquired_source = &"GD3_M1_TEST"
	result.gold_star_level = 1
	result.purple_star_level = 0
	return result


func _has(report: MVP_VALIDATION_REPORT, code: String) -> bool:
	return report != null and report.codes().has(code)


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({"name": name, "passed": passed, "detail": "GĐ3-M1 Match/Round State Bridge invariant"})
