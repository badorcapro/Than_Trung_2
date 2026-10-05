class_name Gd3M3TestSuite
extends RefCounted

const SESSION := preload("res://scripts/application/mvp/MvpIntegratedCaseLootSession.gd")
const CASE_BOUNDARY := preload("res://scripts/domain/mvp/MvpCaseCompletionBoundary.gd")
const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const MVP_CASE_PLAYER_RESULT := preload("res://scripts/domain/mvp/MvpCasePlayerResult.gd")
const PLAYER_MATCH_STATE := preload("res://scripts/domain/mvp/PlayerMatchState.gd")
const LOOT_REWARD_SESSION := preload("res://scripts/domain/loot/LootRewardSession.gd")

const SCENE_PATH := "res://scenes/mvp/Gd3M3IntegratedCaseLoot.tscn"


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_test_integrated_flow(rows)
	_test_guards(rows)
	_test_scene_and_wiring(rows)
	return rows


func _test_integrated_flow(rows: Array[Dictionary]) -> void:
	var session: SESSION = SESSION.new()
	var built: Dictionary = session.build_integrated_fixture()
	_add(rows, "M3 integrated fixture builds", bool(built.get("success", false)))
	_add(rows, "M3 fixture is exactly three players", session.match_state.players.size() == 3)
	_add(
		rows,
		"M3 fixture marker stays TEST_ONLY",
		session.match_state.fixture_marker.contains("NOT_CANON_LOCKED")
	)
	_add(
		rows,
		"M3 starts in actual CASE phase",
		session.match_state.current_phase == MVP_ENUMS.Phase.CASE
	)
	_add(
		rows, "M3 RoundState mirrors CASE phase", session.round_state.phase == MVP_ENUMS.Phase.CASE
	)
	_add(
		rows,
		"M3 canonical Case fixture loaded",
		session.case_definition != null and session.case_definition.case_id == &"vs_case_001"
	)
	_add(
		rows,
		"M3 Match projects three actual Case players",
		session.projected_case_players.size() == 3
	)
	_add(
		rows,
		"M3 Case projection preserves IDs",
		session.projected_case_players[0].player_id == session.match_state.players[0].player_id
	)
	_add(
		rows,
		"M3 Case projection resets submission",
		(
			session.projected_case_players[0].submission_status
			== CaseEnums.SubmissionStatus.NOT_SUBMITTED
		)
	)
	_add(rows, "M3 pre_case checkpoint round-trips", _checkpoint_passes(session, "pre_case"))
	var unrelated_before: Dictionary = _unrelated_fingerprint(session)
	var orb_before_by_player: Dictionary = _orb_snapshot(session)
	var boundary: CASE_BOUNDARY = session.build_test_only_completed_boundary()
	_add(rows, "M3 typed completion boundary builds", boundary != null and boundary.is_valid())
	_add(
		rows,
		"M3 boundary contains actual settlement",
		(
			boundary != null
			and boundary.settlement_result is CaseSettlementResult
			and boundary.settlement_result.success
		)
	)
	_add(
		rows,
		"M3 boundary retains Case runtime",
		boundary != null and boundary.runtime_state != null
	)
	var handled: Dictionary = session.handle_case_completion(boundary)
	_add(rows, "M3 actual Case completion applies", bool(handled.get("success", false)))
	_add(
		rows,
		"M3 phase reaches CASE_SETTLEMENT",
		session.match_state.current_phase == MVP_ENUMS.Phase.CASE_SETTLEMENT
	)
	_add(
		rows,
		"M3 settlement commit recorded",
		session.match_state.applied_commit_ids.has(SESSION.SETTLEMENT_COMMIT_ID)
	)
	_add(rows, "M3 RoundState settlement applied", session.round_state.settlement_applied)
	_add(
		rows,
		"M3 normalized result has all players",
		session.normalized_result != null and session.normalized_result.player_results.size() == 3
	)
	var wrong_result: MVP_CASE_PLAYER_RESULT = _find_result_by_status(session, &"WRONG")
	var wrong_player_id: StringName = wrong_result.player_id if wrong_result != null else &""
	var wrong_match_player: PLAYER_MATCH_STATE = session.match_state.find_player(wrong_player_id)
	var orb_before: int = int(orb_before_by_player.get(String(wrong_player_id), -999))
	var orb_delta: int = wrong_result.orb_delta if wrong_result != null else -999
	var orb_after: int = wrong_match_player.orb_count if wrong_match_player != null else -999
	var actual_orb_delta: int = _actual_settlement_orb_delta(boundary, wrong_player_id)
	_add(
		rows,
		"M3 unrelated persistent state survives Case",
		unrelated_before == _unrelated_fingerprint(session)
	)
	_add(
		rows,
		"M3 post_settlement checkpoint round-trips",
		_checkpoint_passes(session, "post_settlement")
	)
	var after_first: Dictionary = session.match_state.to_dict()
	var duplicate: Dictionary = session.handle_case_completion(boundary)
	_add(
		rows,
		"M3 duplicate completion callback blocked",
		String(duplicate.get("code", "")) == "CASE_COMPLETION_DUPLICATE"
	)
	_add(
		rows,
		"M3 duplicate completion is structured no-op",
		bool(duplicate.get("duplicate_noop", false))
	)
	_add(
		rows,
		"M3 duplicate callback does not mutate Match",
		after_first == session.match_state.to_dict()
	)
	var loot_started: Dictionary = session.begin_loot()
	_add(rows, "M3 begins actual Loot after settlement", bool(loot_started.get("success", false)))
	_add(
		rows,
		"M3 phase reaches LOOT through orchestrator",
		session.match_state.current_phase == MVP_ENUMS.Phase.LOOT
	)
	var loot_ready := session.loot_session != null
	_add(rows, "M3 actual Loot session exists", loot_ready)
	var loot_projection_orb: int = _loot_projection_orb(session, wrong_player_id)
	_add(
		rows,
		"M3 Wrong remains exactly plus one Orb",
		(
			wrong_result != null
			and actual_orb_delta == 1
			and orb_delta == 1
			and orb_after == orb_before + 1
			and loot_projection_orb == orb_after
		),
		(
			(
				"wrong_player_id=%s; orb_before=%d; actual_delta=%d; "
				+ "orb_delta=%d; orb_after=%d; loot_projection_orb=%d"
			)
			% [
				wrong_player_id,
				orb_before,
				actual_orb_delta,
				orb_delta,
				orb_after,
				loot_projection_orb
			]
		)
	)
	_add(
		rows,
		"M3 Loot has exactly three players",
		loot_ready and session.loot_session.players.size() == 3
	)
	_add(
		rows,
		"M3 Loot preserves player identity",
		(
			loot_ready
			and session.loot_session.players.size() > 1
			and session.loot_session.players[1].player_id == &"player_2"
		)
	)
	_add(
		rows,
		"M3 Loot order follows projection seats",
		(
			loot_ready
			and session.loot_session.movement_session != null
			and (
				session.loot_session.movement_session.ordered_player_ids
				== session.match_state.player_order
			)
		)
	)
	_add(
		rows,
		"M3 spawn uses Character origins",
		(
			loot_ready
			and session.loot_session.movement_session.player_states.all(
				func(player: LootMovementPlayerState) -> bool: return not player.current_node_id.is_empty()
			)
		)
	)
	_add(
		rows,
		"M3 Stamina initializes movement actions",
		(
			loot_ready
			and session.loot_session.movement_session.player_states.all(
				func(player: LootMovementPlayerState) -> bool: return player.remaining_moves > 0
			)
		)
	)
	_add(
		rows,
		"M3 reward snapshot created once",
		loot_ready and not session.loot_session.reward_snapshots.is_empty()
	)
	var snapshot_size: int = session.loot_session.reward_snapshots.size() if loot_ready else -1
	_add(
		rows,
		"M3 loot_initialized checkpoint round-trips",
		_checkpoint_passes(session, "loot_initialized")
	)
	var duplicate_loot: Dictionary = session.begin_loot()
	_add(
		rows,
		"M3 duplicate begin Loot blocked",
		String(duplicate_loot.get("code", "")) == "LOOT_SESSION_ALREADY_ACTIVE"
	)
	_add(
		rows,
		"M3 duplicate begin keeps reward snapshot",
		loot_ready and session.loot_session.reward_snapshots.size() == snapshot_size
	)
	var first_player_id := &""
	if loot_ready and session.loot_session.movement_session != null:
		var first_movement_player: LootMovementPlayerState = (
			session.loot_session.movement_session.current_player()
		)
		if first_movement_player != null:
			first_player_id = first_movement_player.player_id
	var item_result: Dictionary = (
		session.use_item(&"test_move_plus_1")
		if loot_ready
		else {"success": false, "code": "LOOT_SESSION_MISSING"}
	)
	_add(
		rows, "M3 actual item service accepts fixture item", bool(item_result.get("success", false))
	)
	_add(
		rows,
		"M3 item window keeps same player identity",
		(
			loot_ready
			and session.loot_session.movement_session.current_player() != null
			and session.loot_session.movement_session.current_player().player_id == first_player_id
		)
	)
	_finish_loot(session)
	_add(
		rows,
		"M3 actual movement history exists",
		loot_ready and not session.loot_session.movement_session.movement_history.is_empty()
	)
	_add(
		rows,
		"M3 actual reward history exists",
		loot_ready and not session.loot_session.reward_history.is_empty()
	)
	_add(
		rows,
		"M3 all movement exhausted",
		loot_ready and session.loot_session.movement_session.all_exhausted()
	)
	_add(
		rows,
		"M3 Loot reaches confirmation-ready",
		(
			loot_ready
			and session.loot_session.phase == LOOT_REWARD_SESSION.Phase.LOOT_END_CONFIRMATION_READY
		)
	)
	_add(
		rows,
		"M3 orchestrator stops at Loot confirmation",
		session.match_state.current_phase == MVP_ENUMS.Phase.LOOT_END_CONFIRMATION
	)
	_add(
		rows,
		"M3 does not enter Equipment Management",
		session.match_state.current_phase != MVP_ENUMS.Phase.EQUIPMENT_MANAGEMENT
	)
	_add(
		rows,
		"M3 loot_finished checkpoint round-trips",
		_checkpoint_passes(session, "loot_finished")
	)
	_add(
		rows,
		"M3 all four checkpoints pass",
		session.checkpoints.size() == 4 and session.checkpoints_pass()
	)


func _test_guards(rows: Array[Dictionary]) -> void:
	var session: SESSION = SESSION.new()
	session.build_integrated_fixture()
	_add(
		rows,
		"M3 Loot before Case completion blocked",
		String(session.begin_loot().get("code", "")) == "LOOT_BEFORE_SETTLEMENT"
	)
	_add(
		rows,
		"M3 null completion boundary blocked",
		String(session.handle_case_completion(null).get("code", "")) == "CASE_BOUNDARY_INVALID"
	)


func _test_scene_and_wiring(rows: Array[Dictionary]) -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	_add(rows, "M3 integrated entry scene loads", packed != null)
	if packed == null:
		return
	var root: Node = packed.instantiate()
	_add(rows, "M3 scene has actual Case host", root.find_child("CaseHost", true, false) != null)
	_add(
		rows,
		"M3 scene has responsive settlement scroll",
		root.find_child("SettlementScroll", true, false) is ScrollContainer
	)
	_add(
		rows,
		"M3 scene has responsive Loot scroll",
		root.find_child("LootScroll", true, false) is ScrollContainer
	)
	_add(
		rows,
		"M3 scene exposes Continue to Loot",
		root.find_child("ContinueToLoot", true, false) is Button
	)
	root.free()


func _finish_loot(session: SESSION) -> void:
	var guard := 0
	while (
		session.loot_session != null
		and session.loot_session.phase != LOOT_REWARD_SESSION.Phase.LOOT_END_CONFIRMATION_READY
		and guard < 100
	):
		guard += 1
		match session.loot_session.phase:
			LOOT_REWARD_SESSION.Phase.ITEM_WINDOW:
				session.continue_without_item()
			LOOT_REWARD_SESSION.Phase.MOVEMENT:
				session.move()
			LOOT_REWARD_SESSION.Phase.BAG_OVERFLOW_PENDING:
				session.resolve_overflow_skip()


func _checkpoint_passes(session: SESSION, key: String) -> bool:
	var value: Variant = session.checkpoints.get(key, {})
	return value is Dictionary and bool(value.get("matches", false))


func _unrelated_fingerprint(session: SESSION) -> Dictionary:
	var result: Dictionary = {}
	for player in session.match_state.players:
		result[String(player.player_id)] = {
			"silver": player.silver_coin_count,
			"exp": player.equipment_exp_material_count,
			"exchange": player.equipment_exchange_material_count,
			"bag": player.consumable_inventory.duplicate(true),
			"equipment": player.to_dict().get("equipment_collection", []),
			"loadout": player.relic_instance_id,
			"gacha": player.gacha_state.to_dict(),
		}
	return result


func _orb_snapshot(session: SESSION) -> Dictionary:
	var result: Dictionary = {}
	for player: PLAYER_MATCH_STATE in session.match_state.players:
		result[String(player.player_id)] = player.orb_count
	return result


func _find_result_by_status(session: SESSION, status: StringName) -> MVP_CASE_PLAYER_RESULT:
	if session.normalized_result == null:
		return null
	for row: MVP_CASE_PLAYER_RESULT in session.normalized_result.player_results:
		if row.status == status:
			return row
	return null


func _actual_settlement_orb_delta(boundary: CASE_BOUNDARY, player_id: StringName) -> int:
	if boundary == null or boundary.settlement_result == null:
		return -999
	for resolution: PlayerCaseResolution in boundary.settlement_result.player_resolutions:
		if resolution.player_id == player_id:
			return resolution.reward.orb_delta
	return -999


func _loot_projection_orb(session: SESSION, player_id: StringName) -> int:
	if session.loot_session == null:
		return -999
	var player: PlayerPhaseState = session.loot_session.find_player(player_id)
	return player.orb_count if player != null else -999


func _add(rows: Array[Dictionary], name: String, passed: bool, diagnostic: String = "") -> void:
	(
		rows
		. append(
			{
				"name": name,
				"passed": passed,
				"detail":
				(
					diagnostic
					if not diagnostic.is_empty()
					else "GĐ3-M3 actual Case → settlement → actual Loot invariant"
				),
			}
		)
	)
