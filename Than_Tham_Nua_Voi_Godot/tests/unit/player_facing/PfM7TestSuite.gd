class_name PfM7TestSuite
extends RefCounted

const COURT_RANK_SERVICE := preload(
	"res://scripts/domain/progression/CourtRankService.gd"
)
const SETUP_SESSION := preload(
	"res://scripts/application/player_facing/PlayerFacingSetupSession.gd"
)
const LOOP_SESSION := preload(
	"res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd"
)
const LOOT_SESSION := preload("res://scripts/domain/loot/LootRewardSession.gd")
const MANAGEMENT_SESSION := preload(
	"res://scripts/domain/equipment/EquipmentManagementSession.gd"
)
const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")

const PLAYER_CONTROLLER := (
	"res://scripts/presentation/player_facing/PlayerFacingStartController.gd"
)
const DEBUG_SCENE := "res://scenes/boot/DebugHome.tscn"

var _service: COURT_RANK_SERVICE = COURT_RANK_SERVICE.new()


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_test_threshold_authority(rows)
	_test_promotion_semantics(rows)
	_test_round_summary_and_persistence(rows)
	_test_scope_guards(rows)
	return rows


func _test_threshold_authority(rows: Array[Dictionary]) -> void:
	_add(rows, "PF-M7 prototype profile has exactly nine ordered Court Ranks", COURT_RANK_SERVICE.PROTOTYPE_THRESHOLD_PROFILE.size() == 9 and _profile_is_strictly_ordered())
	_add(rows, "PF-M7 zero Merit resolves Cửu phẩm", _rank_name(0.0) == "Cửu phẩm")
	_add(rows, "PF-M7 below Bát threshold remains Cửu phẩm", _rank_name(14.0) == "Cửu phẩm")
	_add(rows, "PF-M7 exact Bát threshold promotes", _rank_name(15.0) == "Bát phẩm")
	_add(rows, "PF-M7 middle threshold resolves Ngũ phẩm", _rank_name(90.0) == "Ngũ phẩm")
	_add(rows, "PF-M7 exact Nhất threshold resolves maximum rank", _rank_name(260.0) == "Nhất phẩm" and bool(_service.resolve(260.0).get("maximum_reached", false)))
	_add(rows, "PF-M7 above Nhất remains Nhất phẩm", _rank_name(999.0) == "Nhất phẩm")


func _test_promotion_semantics(rows: Array[Dictionary]) -> void:
	var forty: Dictionary = _service.resolve(40.0)
	_add(rows, "PF-M7 cumulative Merit never resets on promotion", float(forty.get("cumulative_merit", -1.0)) == 40.0 and String(forty.get("rank_name", "")) == "Thất phẩm")
	var jump: Dictionary = _service.promotion(14.0, 130.0)
	_add(rows, "PF-M7 multi-threshold jump resolves final rank", bool(jump.get("promoted", false)) and String(jump.get("before_rank_name", "")) == "Cửu phẩm" and String(jump.get("after_rank_name", "")) == "Tứ phẩm" and int(jump.get("ranks_crossed", 0)) == 5)
	var progress: Dictionary = _service.resolve(104.0)
	_add(rows, "PF-M7 next rank and remaining Merit are exact", String(progress.get("rank_name", "")) == "Ngũ phẩm" and String(progress.get("next_rank_name", "")) == "Tứ phẩm" and int(progress.get("next_threshold", 0)) == 125 and float(progress.get("merit_remaining", 0.0)) == 21.0)
	var maximum: Dictionary = _service.resolve(260.0)
	_add(rows, "PF-M7 Nhất phẩm has no fake next rank", not bool(maximum.get("has_next_rank", true)) and String(maximum.get("next_rank_name", "x")) == "" and int(maximum.get("next_threshold", 0)) == -1)


func _test_round_summary_and_persistence(rows: Array[Dictionary]) -> void:
	# Round 2 remains the persistence proof. Promotion feedback is verified from a
	# separate real Round 1 settlement: its sole correct solver moves from 0 to 20
	# Công Danh and therefore crosses the authored prototype Bát threshold at 15.
	var context: Dictionary = _round_two_summary_context()
	var setup: SETUP_SESSION = context.setup
	var flow: LOOP_SESSION = context.flow
	var summary_rows: Array[Dictionary] = setup.round_summary_presentation(
		flow.match_state,
		flow.equipment_session.players,
		flow.active_round_start_merit_by_player()
	)
	_add(rows, "PF-M7 Round Summary uses authoritative Court Rank data", _summary_ranks_match_authority(flow, summary_rows))
	var promotion_context: Dictionary = _round_one_summary_context()
	var promotion_setup: SETUP_SESSION = promotion_context.setup
	var promotion_flow: LOOP_SESSION = promotion_context.flow
	var promotion_rows: Array[Dictionary] = promotion_setup.round_summary_presentation(
		promotion_flow.match_state,
		promotion_flow.equipment_session.players,
		promotion_flow.active_round_start_merit_by_player()
	)
	_add(rows, "PF-M7 rank-up feedback uses authoritative before and after Merit", _summary_has_real_promotion(promotion_rows))
	var ranks_before: Dictionary = _rank_map(flow)
	setup.open_round_summary()
	flow.commit_round_end(flow.active_player_facing_round_end_commit_id())
	setup.mark_next_case_required()
	flow.start_next_round(setup.available_case.case_id)
	setup.mark_next_case_started()
	_add(rows, "PF-M7 Court Rank persists by derivation across Rounds", _rank_map(flow) == ranks_before and flow.round_state.round_number == 3)
	_add(rows, "PF-M7 Rank start snapshot follows player_id", _start_merit_snapshot_matches_match(flow))


func _test_scope_guards(rows: Array[Dictionary]) -> void:
	var source: String = FileAccess.get_file_as_string(
		"res://scripts/domain/progression/CourtRankService.gd"
	).to_lower()
	_add(rows, "PF-M7 rank authority introduces no gameplay modifiers", not source.contains("speed") and not source.contains("stamina") and not source.contains("gacha_rate") and not source.contains("loot_reward") and not source.contains("turn_order"))
	var context: Dictionary = _round_one_summary_context()
	var flow: LOOP_SESSION = context.flow
	flow.match_state.players[0].merit_progress = 260.0
	flow.equipment_session.players[0].merit_progress = 260.0
	var setup: SETUP_SESSION = context.setup
	setup.open_round_summary()
	flow.commit_round_end(flow.active_player_facing_round_end_commit_id())
	_add(rows, "PF-M7 Nhất phẩm remains Court Rank authority for Match completion", flow.match_state.current_phase == MVP_ENUMS.Phase.MATCH_COMPLETE and flow.match_state.match_completion_state == &"MATCH_COMPLETE")
	var controller_source: String = FileAccess.get_file_as_string(PLAYER_CONTROLLER)
	_add(rows, "PF-M7 player-facing Summary exposes promotion and maximum copy", controller_source.contains("THĂNG PHẨM!") and controller_source.contains("Đã đạt phẩm cấp tối cao"))
	_add(rows, "PF-M7 F12 DebugHome remains available", AppFlow.DEBUG_HOME_SCENE == DEBUG_SCENE and AppFlow.has_method("go_to_debug_home"))


func _round_one_summary_context() -> Dictionary:
	var setup: SETUP_SESSION = _committed_setup()
	var flow: LOOP_SESSION = LOOP_SESSION.new()
	flow.initialize_player_facing_case(setup.match_state, setup.available_case)
	setup.mark_case_started()
	flow.handle_case_completion(flow.build_test_only_completed_boundary())
	setup.mark_case_results_ready()
	setup.continue_to_loot_ready()
	flow.begin_loot()
	setup.mark_loot_started()
	_complete_loot(flow)
	flow.begin_loot_end_confirmation()
	setup.mark_loot_confirmation()
	while flow.equipment_session.phase == MANAGEMENT_SESSION.Phase.LOOT_END_CONFIRMATION:
		flow.confirm_loot_end(flow.equipment_session.current_player_id())
	setup.mark_equipment_management()
	while flow.equipment_session.phase == MANAGEMENT_SESSION.Phase.EQUIPMENT_MANAGEMENT:
		flow.mark_management_done(flow.equipment_session.current_player_id())
	setup.mark_round_summary_ready()
	return {"setup": setup, "flow": flow}


func _round_two_summary_context() -> Dictionary:
	var context: Dictionary = _round_one_summary_context()
	var setup: SETUP_SESSION = context.setup
	var flow: LOOP_SESSION = context.flow
	setup.open_round_summary()
	flow.commit_round_end(flow.active_player_facing_round_end_commit_id())
	setup.mark_next_case_required()
	flow.start_next_round(setup.available_case.case_id)
	setup.mark_next_case_started()
	flow.handle_case_completion(flow.build_active_round_test_only_completed_boundary())
	setup.mark_case_results_ready()
	setup.continue_to_loot_ready()
	flow.begin_loot()
	setup.mark_loot_started()
	_complete_loot(flow)
	flow.begin_loot_end_confirmation()
	setup.mark_loot_confirmation()
	while flow.equipment_session.phase == MANAGEMENT_SESSION.Phase.LOOT_END_CONFIRMATION:
		flow.confirm_loot_end(flow.equipment_session.current_player_id())
	setup.mark_equipment_management()
	while flow.equipment_session.phase == MANAGEMENT_SESSION.Phase.EQUIPMENT_MANAGEMENT:
		flow.mark_management_done(flow.equipment_session.current_player_id())
	setup.mark_round_summary_ready()
	return context


func _complete_loot(flow: LOOP_SESSION) -> void:
	var guard: int = 0
	while flow.loot_session.phase != LOOT_SESSION.Phase.LOOT_END_CONFIRMATION_READY and guard < 120:
		guard += 1
		match flow.loot_session.phase:
			LOOT_SESSION.Phase.ITEM_WINDOW:
				flow.continue_without_item()
			LOOT_SESSION.Phase.MOVEMENT:
				flow.move()
			LOOT_SESSION.Phase.BAG_OVERFLOW_PENDING:
				flow.resolve_overflow_skip()
			_:
				return


func _committed_setup() -> SETUP_SESSION:
	var setup: SETUP_SESSION = SETUP_SESSION.new()
	setup.begin_new_game()
	setup.choose_player_count(3)
	for seat_index: int in range(3):
		setup.select_character(setup.characters[seat_index].character_id)
		setup.lock_current_character()
		if setup.phase == SETUP_SESSION.Phase.PASS_DEVICE:
			setup.continue_after_pass_device()
	setup.confirm_lineup()
	return setup


func _rank_name(merit: float) -> String:
	return String(_service.resolve(merit).get("rank_name", ""))


func _profile_is_strictly_ordered() -> bool:
	var previous := -1
	for row: Dictionary in COURT_RANK_SERVICE.PROTOTYPE_THRESHOLD_PROFILE:
		var threshold: int = int(row.get("threshold", -1))
		if threshold <= previous:
			return false
		previous = threshold
	return true


func _summary_ranks_match_authority(
	flow: LOOP_SESSION, rows: Array[Dictionary]
) -> bool:
	for row: Dictionary in rows:
		var player = flow.match_state.find_player(StringName(row.get("player_id", "")))
		var rank_value: Variant = row.get("court_rank", {})
		if player == null or not (rank_value is Dictionary):
			return false
		var expected: Dictionary = _service.resolve(player.merit_progress)
		var actual: Dictionary = rank_value as Dictionary
		if actual.get("rank_id") != expected.get("rank_id") or float(actual.get("cumulative_merit", -1.0)) != player.merit_progress:
			return false
	return rows.size() == flow.match_state.players.size()


func _summary_has_real_promotion(rows: Array[Dictionary]) -> bool:
	for row: Dictionary in rows:
		var promotion_value: Variant = row.get("court_rank_promotion", {})
		if not (promotion_value is Dictionary):
			continue
		var promotion: Dictionary = promotion_value as Dictionary
		if bool(promotion.get("promoted", false)):
			var expected: Dictionary = _service.promotion(
				float(row.get("round_start_merit", 0.0)),
				float(row.get("merit", 0.0))
			)
			return promotion == expected
	return false


func _rank_map(flow: LOOP_SESSION) -> Dictionary:
	var result: Dictionary = {}
	for player in flow.match_state.players:
		result[String(player.player_id)] = _service.resolve(player.merit_progress).get(
			"rank_id", &""
		)
	return result


func _start_merit_snapshot_matches_match(flow: LOOP_SESSION) -> bool:
	var snapshot: Dictionary = flow.active_round_start_merit_by_player()
	for player in flow.match_state.players:
		if float(snapshot.get(String(player.player_id), -1.0)) != player.merit_progress:
			return false
	return snapshot.size() == flow.match_state.players.size()


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "PF-M7 Court Rank progression invariant",
	})
