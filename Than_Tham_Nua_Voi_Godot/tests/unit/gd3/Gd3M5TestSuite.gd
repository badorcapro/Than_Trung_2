class_name Gd3M5TestSuite
extends RefCounted

const SESSION := preload("res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd")
const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const CASE_BOUNDARY := preload("res://scripts/domain/mvp/MvpCaseCompletionBoundary.gd")
const MVP_CASE_PLAYER_RESULT := preload("res://scripts/domain/mvp/MvpCasePlayerResult.gd")
const PLAYER_MATCH_STATE := preload("res://scripts/domain/mvp/PlayerMatchState.gd")
const MVP_ROUND_STATE := preload("res://scripts/domain/mvp/MvpRoundState.gd")
const LOOT_SESSION := preload("res://scripts/domain/loot/LootRewardSession.gd")
const M5_ORCHESTRATOR := preload("res://scripts/application/mvp/MvpRoundOrchestrator.gd")
const TURN_MANAGER := preload("res://scripts/domain/cases/TurnManager.gd")
const ACTUAL_CASE_SCENE := preload("res://scenes/case_gameplay/VSCaseMain.tscn")
const ACTUAL_CASE_CONTROLLER := preload(
	"res://scripts/presentation/case_gameplay/VSCaseMainController.gd"
)
const CASE_GENERATION_REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")
const CASE_GENERATOR_SOLVER_RESULT := preload("res://scripts/domain/cases/CaseGeneratorSolverResult.gd")
const CASE_SEED_WAREHOUSE_BUILDER := preload("res://scripts/domain/cases/CaseSeedWarehouseBuilder.gd")
const CASE_SEED_WAREHOUSE_BUILD_RESULT := preload("res://scripts/domain/cases/CaseSeedWarehouseBuildResult.gd")
const CASE_SEED_WAREHOUSE_ENTRY := preload("res://scripts/domain/cases/CaseSeedWarehouseEntry.gd")

const SCENE_PATH := "res://scenes/mvp/Gd3M5NextCaseOrchestration.tscn"
const DEBUG_HOME_PATH := "res://scenes/boot/DebugHome.tscn"


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_test_round_1_prerequisite(rows)
	_test_generated_case_options_integration(rows)
	_test_transactional_guards(rows)
	_test_round_2_creation_and_idempotency(rows)
	_test_round_2_case_runtime_and_turn_order(rows)
	_test_persistence_preservation(rows)
	_test_transient_reset(rows)
	_test_round_2_settlement(rows)
	_test_round_2_loot_initialization(rows)
	_test_scene_and_routes(rows)
	return rows


func _test_round_1_prerequisite(rows: Array[Dictionary]) -> void:
	var session: SESSION = SESSION.new()
	var built: Dictionary = session.build_integrated_fixture()
	_add(rows, "M5 session builds integrated fixture", bool(built.get("success", false)))
	_add(
		rows,
		"M5 routing policy marker stays TEST_ONLY",
		String(session.match_state.open_policy_config_ids.get("next_case_routing", "")).contains("test_only")
	)
	var r1_res: Dictionary = session.complete_round_1_programmatically()
	_add(rows, "M5 completes Round 1 programmatically", bool(r1_res.get("success", false)))
	_add(
		rows,
		"M5 Round 1 reaches NEXT_CASE_REQUIRED",
		session.match_state.match_completion_state == &"NEXT_CASE_REQUIRED"
	)
	_add(rows, "M5 Round 1 post-end checkpoint round-trips", _checkpoint(session, "round1_post_end"))
	_add(rows, "M5 active Round cleared after Round 1", session._orchestrator.active_round == null)
	_add(rows, "M5 round number incremented to 2", session.match_state.current_round_number == 2)


func _test_generated_case_options_integration(rows: Array[Dictionary]) -> void:
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var request: CASE_GENERATION_REQUEST = _m5b_case_generation_request()
	var warehouse: CASE_SEED_WAREHOUSE_BUILD_RESULT = CASE_SEED_WAREHOUSE_BUILDER.new().build(
		request,
		PackedInt32Array([20, 21, 22, 23]),
		4,
		roles,
		1,
		Callable(self, "_m5b_fake_attempt_evaluator")
	)
	var session: SESSION = _ready_at_next_case_required()
	var composed: Dictionary = session.compose_next_case_options(
		warehouse,
		0,
		request,
		roles,
		3,
		1,
		Callable(self, "_m5b_fake_attempt_evaluator"),
		Callable(self, "_m5b_case_definition_for_entry")
	)
	var option_signatures: Array[String] = session.next_case_option_set.option_candidate_signatures if session.next_case_option_set != null else []
	var first_signature: String = session.next_case_option_set.option_set_signature if session.next_case_option_set != null else ""
	var reread: Dictionary = session.compose_next_case_options(
		warehouse,
		0,
		request,
		roles,
		3,
		1,
		Callable(self, "_m5b_fake_attempt_evaluator"),
		Callable(self, "_m5b_case_definition_for_entry")
	)
	var option_state_ready: bool = (
		bool(composed.get("success", false))
		and session.next_case_option_set != null
		and session.next_case_option_set.produced_option_count == 3
		and session.next_case_option_definitions.size() == 3
	)
	var order_matches: bool = (
		session.next_case_option_set != null
		and option_signatures == session.next_case_option_set.option_candidate_signatures
		and _strings_are_distinct(option_signatures)
	)
	var reread_preserved: bool = (
		session.next_case_option_set != null
		and bool(reread.get("duplicate_noop", false))
		and session.next_case_option_set.option_set_signature == first_signature
	)
	_add(rows, "M5B generated Case selection receives exactly three M5A options", option_state_ready)
	_add(rows, "M5B generated option order matches M5A output", order_matches)
	_add(rows, "M5B rereading option state does not recompose", reread_preserved)
	var selected_index: int = 1
	var selected_signature: String = option_signatures[selected_index] if option_signatures.size() > selected_index else ""
	var unselected_signatures: Array[String] = []
	for index: int in range(option_signatures.size()):
		if index != selected_index:
			unselected_signatures.append(option_signatures[index])
	var started: Dictionary = session.start_next_round_from_option(selected_index)
	var selected_definition: CaseDefinition = session.next_case_option_definitions[selected_index] if session.next_case_option_definitions.size() > selected_index else null
	var expected_used_signatures: Array[String] = [selected_signature]
	var unselected_remain_unused: bool = (
		unselected_signatures.size() == 2
		and not session.match_state.used_case_candidate_signatures.has(unselected_signatures[0])
		and not session.match_state.used_case_candidate_signatures.has(unselected_signatures[1])
	)
	_add(rows, "M5B voting winner maps to authoritative generated Case", bool(started.get("success", false)) and session.selected_case_option_index == selected_index and session.selected_case_candidate_signature == selected_signature and session.active_case_definition == selected_definition)
	_add(rows, "M5B selected generated Case enters existing gameplay setup path", session.match_state.current_phase == MVP_ENUMS.Phase.CASE and session.round_state.phase == MVP_ENUMS.Phase.CASE and session.active_case_runtime != null and session.active_case_runtime.is_initialized)
	_add(rows, "M5B commits only selected signature as session-used", session.match_state.used_case_candidate_signatures == expected_used_signatures)
	_add(rows, "M5B unselected offered signatures remain unused", unselected_remain_unused)
	var later_session: SESSION = _ready_at_next_case_required()
	later_session.match_state.used_case_candidate_signatures.append(selected_signature)
	var later: Dictionary = later_session.compose_next_case_options(
		warehouse,
		0,
		request,
		roles,
		3,
		1,
		Callable(self, "_m5b_fake_attempt_evaluator"),
		Callable(self, "_m5b_case_definition_for_entry")
	)
	var later_excludes_selected: bool = (
		bool(later.get("success", false))
		and later_session.next_case_option_set != null
		and not later_session.next_case_option_set.option_candidate_signatures.has(selected_signature)
	)
	_add(rows, "M5B later Round excludes previously selected signature", later_excludes_selected)
	var insufficient_warehouse: CASE_SEED_WAREHOUSE_BUILD_RESULT = CASE_SEED_WAREHOUSE_BUILDER.new().build(
		request,
		PackedInt32Array([20, 21]),
		2,
		roles,
		1,
		Callable(self, "_m5b_fake_attempt_evaluator")
	)
	var failure_session: SESSION = _ready_at_next_case_required()
	var failed: Dictionary = failure_session.compose_next_case_options(
		insufficient_warehouse,
		0,
		request,
		roles,
		3,
		1,
		Callable(self, "_m5b_fake_attempt_evaluator"),
		Callable(self, "_m5b_case_definition_for_entry")
	)
	_add(rows, "M5B M5A failure does not enter partial voting state", not bool(failed.get("success", true)) and failure_session.next_case_option_definitions.is_empty() and failure_session._orchestrator.active_round == null and failure_session.match_state.current_phase == MVP_ENUMS.Phase.ROUND_START)


func _test_transactional_guards(rows: Array[Dictionary]) -> void:
	var session: SESSION = _ready_at_next_case_required()
	var empty_id_res: Dictionary = session.start_next_round(&"")
	_add(
		rows,
		"M5 empty next case ID rejected",
		String(empty_id_res.get("code", "")) == "NEXT_CASE_ID_EMPTY"
	)
	var unknown_id_res: Dictionary = session.start_next_round(&"non_existent_case_999")
	_add(
		rows,
		"M5 unknown next case ID rejected",
		String(unknown_id_res.get("code", "")) == "NEXT_CASE_NOT_FOUND"
	)
	session.match_state.current_phase = MVP_ENUMS.Phase.CASE
	var wrong_phase_res: Dictionary = session.start_next_round(&"vs_case_001")
	_add(
		rows,
		"M5 wrong start phase rejected",
		String(wrong_phase_res.get("code", "")) == "WRONG_START_PHASE"
	)
	session.match_state.current_phase = MVP_ENUMS.Phase.ROUND_START
	session._orchestrator.active_round = MVP_ROUND_STATE.new()
	var active_round_res: Dictionary = session.start_next_round(&"vs_case_001")
	_add(
		rows,
		"M5 un-cleared active round blocks start",
		String(active_round_res.get("code", "")) == "ACTIVE_ROUND_ALREADY_EXISTS"
	)
	session._orchestrator.active_round = null
	var match_before: Dictionary = session.match_state.to_dict()
	session.start_next_round(&"unknown_case_x")
	_add(
		rows,
		"M5 guard rejection preserves MatchState unmutated",
		session.match_state.to_dict() == match_before
	)
	_add(
		rows,
		"M5 guard rejection attaches no new RoundState",
		session._orchestrator.active_round == null
	)
	_add(
		rows,
		"M5 guard rejection publishes no partial Round 2 state",
		not session._round2_started
		and session.round2_case_definition == null
		and session.round2_case_runtime == null
		and session.match_state.match_completion_state == &"NEXT_CASE_REQUIRED"
	)
	_add(
		rows,
		"M5 validated final transition is deterministic ROUND_START to CASE",
		int(M5_ORCHESTRATOR.NEXT_PHASE.get(MVP_ENUMS.Phase.ROUND_START, -1))
		== MVP_ENUMS.Phase.CASE
	)


func _test_round_2_creation_and_idempotency(rows: Array[Dictionary]) -> void:
	var session: SESSION = _ready_at_next_case_required()
	var start_res: Dictionary = session.start_next_round(&"vs_case_001")
	_add(rows, "M5 start next round succeeds", bool(start_res.get("success", false)))
	_add(
		rows,
		"M5 returns ROUND_2_CASE_READY",
		String(start_res.get("code", "")) == "ROUND_2_CASE_READY"
	)
	_add(rows, "M5 round number is exactly 2", session.match_state.current_round_number == 2)
	_add(rows, "M5 new round ID is gd3_m5_round_002", session.round_state.round_id == SESSION.ROUND2_ROUND_ID)
	_add(
		rows,
		"M5 Round 2 runtime and settlement identities do not collide with Round 1",
		session.round_state.round_id != &"gd3_m4_round_001"
		and not session.match_state.applied_commit_ids.has(SESSION.ROUND2_SETTLEMENT_COMMIT_ID)
		and SESSION.ROUND2_SETTLEMENT_COMMIT_ID != SESSION.ROUND_END_COMMIT_ID
	)
	_add(rows, "M5 orchestrator phase is CASE", session.match_state.current_phase == MVP_ENUMS.Phase.CASE)
	_add(rows, "M5 round state phase is CASE", session.round_state.phase == MVP_ENUMS.Phase.CASE)
	_add(
		rows,
		"M5 match completion state cleared from NEXT_CASE_REQUIRED",
		session.match_state.match_completion_state == &"IN_PROGRESS"
	)
	var dup_res: Dictionary = session.start_next_round(&"vs_case_001")
	_add(
		rows,
		"M5 duplicate start next round blocked",
		String(dup_res.get("code", "")) == "ROUND_2_ALREADY_STARTED"
	)
	_add(
		rows,
		"M5 duplicate start next round is structured no-op",
		bool(dup_res.get("duplicate_noop", false))
	)
	_add(
		rows,
		"M5 duplicate start does not advance round number",
		session.match_state.current_round_number == 2
	)
	_add(rows, "M5 round2_initialized checkpoint round-trips", _checkpoint(session, "round2_initialized"))
	_add(rows, "M5 round2_pre_case checkpoint round-trips", _checkpoint(session, "round2_pre_case"))


func _test_round_2_case_runtime_and_turn_order(rows: Array[Dictionary]) -> void:
	var session: SESSION = _ready_at_next_case_required()
	session.match_state.find_player(&"player_1").reputation = 3
	session.match_state.find_player(&"player_2").reputation = 6
	session.match_state.find_player(&"player_3").reputation = 4
	var seed: int = 20260828
	var started: Dictionary = session.start_next_round(&"vs_case_001", seed)
	_add(rows, "M5 deterministic Reputation fixture starts Round 2", bool(started.get("success", false)))
	_add(rows, "M5 Round 2 Case runtime initialized", session.round2_case_runtime != null)
	_add(
		rows,
		"M5 Round 2 Case runtime is fresh instance",
		session.round2_case_runtime.is_initialized and not session.round2_case_runtime.is_settled
	)
	_add(
		rows,
		"M5 Round 2 Case submissions empty",
		session.round2_case_runtime.submissions.is_empty() and session.round2_case_runtime.final_submissions.is_empty()
	)
	_add(rows, "M5 Round 2 Case action log empty", session.round2_case_runtime.action_log.is_empty())
	_add(
		rows,
		"M5 Round 2 Case public functions empty",
		session.round2_case_runtime.public_function_records.is_empty()
	)
	_add(rows, "M5 Round 2 Case truth reveal is null", session.round2_case_runtime.truth_reveal == null)
	_add(rows, "M5 Round 2 TurnManager initialized", session.round2_turn_manager != null and session.round2_turn_manager.is_initialized)
	var turn_order_ids: Array[StringName] = session.round2_turn_manager.get_turn_order_ids()
	_add(
		rows,
		"M5 Round 2 order uses current post-Round-1 Reputation descending",
		turn_order_ids == [&"player_2", &"player_3", &"player_1"]
	)
	var expected_manager: TURN_MANAGER = TURN_MANAGER.new()
	var expected_players: Array[PlayerCaseState] = []
	for projected_player: PlayerCaseState in session.round2_projected_case_players:
		expected_players.append(_clone_case_player(projected_player))
	expected_manager.initialize(expected_players, seed)
	_add(
		rows,
		"M5 Round 2 uses a fresh deterministic TurnManager",
		session.round2_turn_manager != expected_manager
		and turn_order_ids == expected_manager.get_turn_order_ids()
	)
	_add(
		rows,
		"M5 Round 1 order is not blindly reused",
		turn_order_ids != [&"player_1", &"player_2", &"player_3"]
	)
	var tie_players_a: Array[PlayerCaseState] = _tie_fixture_players()
	var tie_players_b: Array[PlayerCaseState] = _tie_fixture_players()
	var tie_a: TURN_MANAGER = TURN_MANAGER.new()
	var tie_b: TURN_MANAGER = TURN_MANAGER.new()
	tie_a.initialize(tie_players_a, 424242)
	tie_b.initialize(tie_players_b, 424242)
	_add(
		rows,
		"M5 Round 2 seeded tie behavior matches TurnManager contract",
		tie_a.get_turn_order_ids() == tie_b.get_turn_order_ids()
		and tie_a.get_turn_order_ids().back() == &"player_3"
	)
	var actual_case: ACTUAL_CASE_CONTROLLER = ACTUAL_CASE_SCENE.instantiate() as ACTUAL_CASE_CONTROLLER
	if actual_case != null:
		actual_case.configure_integrated_case(session.round2_projected_case_players)
	_add(
		rows,
		"M5 Round 2 actual VSCaseMain accepts projected players by identity",
		actual_case != null
		and actual_case.integration_mode
		and _case_player_ids(actual_case.integration_players) == _case_player_ids(session.round2_projected_case_players)
	)
	if actual_case != null:
		actual_case.free()


func _test_persistence_preservation(rows: Array[Dictionary]) -> void:
	var session: SESSION = _ready_in_round_2_case()
	_add(rows, "M5 Round 1 persistent snapshot covers every player ID", _snapshot_covers_players(session))
	_add(rows, "M5 identity seat and Character persist exactly", _persistent_fields_equal(session, ["player_id", "seat_index", "character_id"]))
	_add(rows, "M5 Merit Reputation Orb and Tickets persist exactly", _persistent_fields_equal(session, ["merit_progress", "reputation", "orb_count", "gacha_ticket_count"]))
	_add(rows, "M5 currency materials and Bag persist exactly", _persistent_fields_equal(session, ["silver_coin_count", "equipment_exp_material_count", "equipment_exchange_material_count", "consumable_inventory"]))
	_add(rows, "M5 Equipment collection and stable instance IDs persist exactly", _persistent_fields_equal(session, ["equipment_collection"]))
	_add(rows, "M5 loadout IDs persist exactly", _persistent_fields_equal(session, ["relic_instance_id", "stigmata_a_instance_id", "stigmata_b_instance_id", "stigmata_c_instance_id"]))
	_add(rows, "M5 Gold Purple and authored Equipment state persist exactly", _persistent_fields_equal(session, ["equipment_collection"]))
	_add(rows, "M5 Gacha pity banner Perfect and SS state persist exactly", _persistent_fields_equal(session, ["gacha_state"]))
	_add(rows, "M5 complete PlayerMatchState semantic snapshot is unchanged at Round 2 CASE", _all_persistent_players_equal(session))
	_add(
		rows,
		"M5 commit history contains Round 1 commits",
		session.match_state.applied_commit_ids.has(SESSION.ROUND_END_COMMIT_ID)
	)


func _test_transient_reset(rows: Array[Dictionary]) -> void:
	var session: SESSION = _ready_in_round_2_case()
	_add(rows, "M5 Round 1 active Loot reference is cleared", session.loot_session == null)
	_add(rows, "M5 Round 1 Equipment Management reference is cleared", session.equipment_session == null)
	_add(rows, "M5 Round 2 Case submissions and final submissions reset", session.round2_case_runtime.submissions.is_empty() and session.round2_case_runtime.final_submissions.is_empty())
	_add(rows, "M5 Round 2 Case action truth and function runtime reset", session.round2_case_runtime.action_log.is_empty() and session.round2_case_runtime.truth_reveal == null and session.round2_case_runtime.public_function_records.is_empty())
	_add(rows, "M5 Round 2 owns fresh turn runtime", session.round2_case_runtime.turn_number == 1 and session.round2_turn_manager.turn_number == 1)
	_add(rows, "M5 Round 1 overflow not carried over", session.round_state.round_completion_flags.get("pending_overflow", false) == false)
	_add(rows, "M5 Round 1 Loot confirmation and Management snapshot reset", session.round_state.equipment_management_snapshot.is_empty())
	_add(rows, "M5 Round 1 management flags and pending choice reset", session.round_state.round_completion_flags.get("management_complete", false) == false and session.round_state.round_completion_flags.get("pending_choice", false) == false)


func _test_round_2_settlement(rows: Array[Dictionary]) -> void:
	var session: SESSION = _ready_in_round_2_case()
	var before_match: Dictionary = session.match_state.to_dict()
	var before_by_id: Dictionary = _players_by_id_from_match_dict(before_match)
	var boundary: CASE_BOUNDARY = session.build_round2_test_only_completed_boundary()
	_add(rows, "M5 Round 2 completion boundary builds", boundary != null and boundary.is_valid())
	_add(
		rows,
		"M5 TEST_ONLY completion fixture still uses canonical Case settlement authority",
		boundary != null
		and boundary.runtime_state != null
		and boundary.settlement_result is CaseSettlementResult
	)
	var handled: Dictionary = session.handle_round2_case_completion(boundary)
	_add(rows, "M5 Round 2 typed boundary settlement applies", bool(handled.get("success", false)))
	_add(
		rows,
		"M5 phase reaches CASE_SETTLEMENT",
		session.match_state.current_phase == MVP_ENUMS.Phase.CASE_SETTLEMENT
	)
	_add(
		rows,
		"M5 Round 2 settlement commit recorded",
		session.match_state.applied_commit_ids.has(SESSION.ROUND2_SETTLEMENT_COMMIT_ID)
	)
	_add(
		rows,
		"M5 Round 2 settlement commit ID is gd3_m5_round2_settlement_001",
		session.round_state.settlement_commit_id == SESSION.ROUND2_SETTLEMENT_COMMIT_ID
	)
	_add(
		rows,
		"M5 Round 1 commits did not block Round 2 settlement",
		session.match_state.applied_commit_ids.has(SESSION.ROUND_END_COMMIT_ID)
		and session.match_state.applied_commit_ids.has(SESSION.ROUND2_SETTLEMENT_COMMIT_ID)
	)
	_add(rows, "M5 Round 2 settlement is applied once", session.round_state.settlement_applied)
	_add(
		rows,
		"M5 completed Case runtime authority comes from typed boundary",
		session.round2_case_runtime == boundary.runtime_state
	)
	_add(
		rows,
		"M5 Round 2 settlement deltas apply by player_id",
		_settlement_deltas_match(session, before_by_id)
	)
	var wrong_result: MVP_CASE_PLAYER_RESULT = _result_with_status(session, &"WRONG")
	var wrong_before: Dictionary = (
		before_by_id.get(String(wrong_result.player_id), {}) as Dictionary
		if wrong_result != null
		else {}
	)
	var wrong_after: PLAYER_MATCH_STATE = (
		session.match_state.find_player(wrong_result.player_id) if wrong_result != null else null
	)
	_add(
		rows,
		"M5 WRONG remains exactly plus one Orb by player_id",
		wrong_result != null
		and wrong_result.orb_delta == 1
		and wrong_after != null
		and wrong_after.orb_count == int(wrong_before.get("orb_count", 0)) + 1,
		"wrong_player_id=%s; before=%d; delta=%d; after=%d" % [
			String(wrong_result.player_id) if wrong_result != null else "MISSING",
			int(wrong_before.get("orb_count", 0)),
			wrong_result.orb_delta if wrong_result != null else -999,
			wrong_after.orb_count if wrong_after != null else -999,
		]
	)
	var after_first_apply: Dictionary = session.match_state.to_dict()
	var dup_res: Dictionary = session.handle_round2_case_completion(boundary)
	_add(
		rows,
		"M5 duplicate Round 2 settlement blocked",
		String(dup_res.get("code", "")) == "ROUND_2_CASE_COMPLETION_DUPLICATE"
	)
	_add(
		rows,
		"M5 duplicate Round 2 settlement is structured no-op",
		bool(dup_res.get("duplicate_noop", false))
	)
	_add(
		rows,
		"M5 duplicate Round 2 settlement does not mutate MatchState",
		session.match_state.to_dict() == after_first_apply
	)
	session.match_state.players.reverse()
	session._build_round2_settlement_summary(before_match)
	_add(
		rows,
		"M5 settlement summary survives reordered player arrays by player_id",
		_summary_matches_by_player_id(session, before_by_id)
	)
	_add(
		rows,
		"M5 round2_post_settlement checkpoint round-trips",
		_checkpoint(session, "round2_post_settlement")
	)


func _test_round_2_loot_initialization(rows: Array[Dictionary]) -> void:
	var session: SESSION = _ready_at_round_2_settled()
	var round1_loot: LOOT_SESSION = session.round1_loot_session_at_end
	var loot_res: Dictionary = session.begin_round2_loot()
	_add(rows, "M5 Round 2 Loot begins successfully", bool(loot_res.get("success", false)))
	_add(
		rows,
		"M5 returns ROUND_2_LOOT_INITIALIZED",
		String(loot_res.get("code", "")) == "ROUND_2_LOOT_INITIALIZED"
	)
	_add(rows, "M5 phase enters LOOT", session.match_state.current_phase == MVP_ENUMS.Phase.LOOT)
	_add(
		rows,
		"M5 every player respawns at exact Character origin authority",
		_all_players_at_expected_origin(session),
		_origin_diagnostic(session)
	)
	_add(
		rows,
		"M5 remaining moves equal current resolved Stamina authority",
		_all_players_have_resolved_stamina(session),
		_stamina_diagnostic(session)
	)
	_add(
		rows,
		"M5 Round 2 reward snapshots created",
		session.round2_loot_session.reward_snapshots.size() > 0
	)
	_add(
		rows,
		"M5 Round 2 reward snapshot has fresh Round ownership",
		round1_loot != null
		and round1_loot.round_id != session.round2_loot_session.round_id
		and _snapshots_owned_by_round(round1_loot)
		and _snapshots_owned_by_round(session.round2_loot_session)
	)
	_add(
		rows,
		"M5 Round 2 reward snapshot is a fresh object graph",
		round1_loot != null
		and round1_loot != session.round2_loot_session
		and _reward_snapshot_objects_are_distinct(round1_loot, session.round2_loot_session)
	)
	_add(
		rows,
		"M5 Round 1 movement history not carried over",
		session.round2_loot_session.movement_session.movement_history.is_empty()
	)
	_add(
		rows,
		"M5 Round 2 reward cursor overflow and history start clean",
		session.round2_loot_session.reward_history.is_empty()
		and session.round2_loot_session.pending_trace.is_empty()
		and session.round2_loot_session.pending_trace_index == 0
		and not session.round2_loot_session.overflow.active
	)
	_add(
		rows,
		"M5 Round 2 temporary effects and item-turn flag start clean",
		session.round2_loot_session.movement_session.player_states.all(
			func(player: LootMovementPlayerState) -> bool: return player.temporary_effects.is_empty()
		)
		and not session.round2_loot_session.item_used_this_turn
	)
	_add(
		rows,
		"M5 full persistent allowlist projects to Round 2 Loot by player_id",
		_loot_persistent_projection_matches(session)
	)
	var dup_loot: Dictionary = session.begin_round2_loot()
	_add(
		rows,
		"M5 duplicate begin Round 2 Loot blocked",
		String(dup_loot.get("code", "")) == "ROUND_2_LOOT_ALREADY_ACTIVE"
	)
	_add(
		rows,
		"M5 duplicate begin Round 2 Loot is structured no-op",
		bool(dup_loot.get("duplicate_noop", false))
	)
	_add(
		rows,
		"M5 round2_loot_initialized checkpoint round-trips",
		_checkpoint(session, "round2_loot_initialized")
	)
	_add(
		rows,
		"M5 flow halts at ROUND_2_LOOT_INITIALIZED endpoint",
		session.round2_loot_initialized and session.loot_session.movement_session.movement_history.is_empty()
	)


func _test_scene_and_routes(rows: Array[Dictionary]) -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	_add(rows, "M5 orchestration scene loads", packed != null)
	if packed != null:
		var root: Node = packed.instantiate()
		_add(rows, "M5 scene retains CaseHost", root.find_child("CaseHost", true, false) != null)
		_add(rows, "M5 scene exposes Round 1 End panel", root.find_child("Round1EndPanel", true, false) != null)
		_add(rows, "M5 scene exposes Start Round 2 action", root.find_child("StartRound2", true, false) is Button)
		_add(rows, "M5 scene exposes Settlement panel", root.find_child("SettlementPanel", true, false) != null)
		_add(rows, "M5 scene exposes Round 2 Loot panel", root.find_child("Round2LootPanel", true, false) != null)
		root.free()
	else:
		_add(rows, "M5 scene retains CaseHost", false)
		_add(rows, "M5 scene exposes Round 1 End panel", false)
		_add(rows, "M5 scene exposes Start Round 2 action", false)
		_add(rows, "M5 scene exposes Settlement panel", false)
		_add(rows, "M5 scene exposes Round 2 Loot panel", false)
	var home_packed: PackedScene = load(DEBUG_HOME_PATH) as PackedScene
	if home_packed != null:
		var home: Node = home_packed.instantiate()
		_add(rows, "M5 DebugHome button exists", home.find_child("Gd3M5Button", true, false) is Button)
		home.free()
	else:
		_add(rows, "M5 DebugHome button exists", false)
	_add(
		rows,
		"M5 AppFlow constant and method exist",
		AppFlow.get("GD3_M5_NEXT_CASE_ORCHESTRATION_SCENE") != null
		and AppFlow.has_method("go_to_gd3_m5_next_case_orchestration")
	)


func _ready_at_next_case_required() -> SESSION:
	var session: SESSION = SESSION.new()
	session.build_integrated_fixture()
	session.complete_round_1_programmatically()
	return session


func _ready_in_round_2_case() -> SESSION:
	var session: SESSION = _ready_at_next_case_required()
	session.start_next_round(&"vs_case_001")
	return session


func _ready_at_round_2_settled() -> SESSION:
	var session: SESSION = _ready_in_round_2_case()
	var boundary: CASE_BOUNDARY = session.build_round2_test_only_completed_boundary()
	session.handle_round2_case_completion(boundary)
	return session


func _checkpoint(session: SESSION, key: String) -> bool:
	if session == null:
		return false
	var value: Variant = session.checkpoints.get(key, {})
	if not (value is Dictionary):
		return false
	var dict_value: Dictionary = value as Dictionary
	return bool(dict_value.get("matches", false))


func _snapshot_covers_players(session: SESSION) -> bool:
	if session.round1_persistent_snapshot_by_player.size() != session.match_state.players.size():
		return false
	for player: PLAYER_MATCH_STATE in session.match_state.players:
		if not session.round1_persistent_snapshot_by_player.has(String(player.player_id)):
			return false
	return true


func _persistent_fields_equal(session: SESSION, fields: Array) -> bool:
	for player: PLAYER_MATCH_STATE in session.match_state.players:
		var before_value: Variant = session.round1_persistent_snapshot_by_player.get(
			String(player.player_id), {}
		)
		if not (before_value is Dictionary):
			return false
		var before: Dictionary = before_value as Dictionary
		var after: Dictionary = player.to_dict()
		for field_value: Variant in fields:
			var field: String = String(field_value)
			if before.get(field) != after.get(field):
				return false
	return true


func _all_persistent_players_equal(session: SESSION) -> bool:
	for player: PLAYER_MATCH_STATE in session.match_state.players:
		var before_value: Variant = session.round1_persistent_snapshot_by_player.get(
			String(player.player_id), {}
		)
		if not (before_value is Dictionary) or player.to_dict() != before_value:
			return false
	return true


func _players_by_id_from_match_dict(match_dict: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	var players_value: Variant = match_dict.get("players", [])
	if players_value is Array:
		for player_value: Variant in players_value:
			if player_value is Dictionary:
				var player_row: Dictionary = player_value as Dictionary
				result[String(player_row.get("player_id", ""))] = player_row
	return result


func _result_with_status(session: SESSION, status: StringName) -> MVP_CASE_PLAYER_RESULT:
	if session.round2_normalized_result == null:
		return null
	for result: MVP_CASE_PLAYER_RESULT in session.round2_normalized_result.player_results:
		if result.status == status:
			return result
	return null


func _settlement_deltas_match(session: SESSION, before_by_id: Dictionary) -> bool:
	if session.round2_normalized_result == null:
		return false
	for result: MVP_CASE_PLAYER_RESULT in session.round2_normalized_result.player_results:
		var before_value: Variant = before_by_id.get(String(result.player_id), {})
		var after: PLAYER_MATCH_STATE = session.match_state.find_player(result.player_id)
		if not (before_value is Dictionary) or after == null:
			return false
		var before: Dictionary = before_value as Dictionary
		if not is_equal_approx(
			after.merit_progress,
			float(before.get("merit_progress", 0.0)) + result.merit_delta
		):
			return false
		if after.reputation != int(before.get("reputation", 0)) + result.reputation_delta:
			return false
		if after.orb_count != int(before.get("orb_count", 0)) + result.orb_delta:
			return false
		if (
			after.gacha_ticket_count
			!= int(before.get("gacha_ticket_count", 0)) + result.total_ticket_delta()
		):
			return false
	return true


func _summary_matches_by_player_id(session: SESSION, before_by_id: Dictionary) -> bool:
	if session.round2_settlement_summary.size() != session.match_state.players.size():
		return false
	for row: Dictionary in session.round2_settlement_summary:
		var player_id: StringName = StringName(String(row.get("player_id", "")))
		var before_value: Variant = before_by_id.get(String(player_id), {})
		var after: PLAYER_MATCH_STATE = session.match_state.find_player(player_id)
		if not (before_value is Dictionary) or after == null:
			return false
		var before: Dictionary = before_value as Dictionary
		if int(row.get("orb_delta", -999)) != after.orb_count - int(before.get("orb_count", 0)):
			return false
		if (
			int(row.get("ticket_delta", -999))
			!= after.gacha_ticket_count - int(before.get("gacha_ticket_count", 0))
		):
			return false
	return true


func _all_players_at_expected_origin(session: SESSION) -> bool:
	if session.round2_loot_session == null:
		return false
	for player: LootMovementPlayerState in session.round2_loot_session.movement_session.player_states:
		if player.current_node_id != session.expected_origin_node_for_player(player.player_id):
			return false
	return true


func _origin_diagnostic(session: SESSION) -> String:
	var parts: Array[String] = []
	if session.round2_loot_session == null:
		return "loot_session=MISSING"
	for player: LootMovementPlayerState in session.round2_loot_session.movement_session.player_states:
		parts.append("%s expected=%s actual=%s" % [
			String(player.player_id),
			String(session.expected_origin_node_for_player(player.player_id)),
			String(player.current_node_id),
		])
	return "; ".join(parts)


func _all_players_have_resolved_stamina(session: SESSION) -> bool:
	if session.round2_loot_session == null:
		return false
	for movement_player: LootMovementPlayerState in session.round2_loot_session.movement_session.player_states:
		var expected: int = session.resolved_stamina_for_player(movement_player.player_id)
		if movement_player.stamina_snapshot != expected or movement_player.remaining_moves != expected:
			return false
	return true


func _stamina_diagnostic(session: SESSION) -> String:
	var parts: Array[String] = []
	if session.round2_loot_session == null:
		return "loot_session=MISSING"
	for player: LootMovementPlayerState in session.round2_loot_session.movement_session.player_states:
		parts.append("%s expected=%d actual=%d" % [
			String(player.player_id),
			session.resolved_stamina_for_player(player.player_id),
			player.remaining_moves,
		])
	return "; ".join(parts)


func _snapshots_owned_by_round(session: LOOT_SESSION) -> bool:
	if session == null or session.reward_snapshots.is_empty():
		return false
	for snapshot: RewardNodeSnapshot in session.reward_snapshots:
		if snapshot.round_id != session.round_id:
			return false
	return true


func _reward_snapshot_objects_are_distinct(a: LOOT_SESSION, b: LOOT_SESSION) -> bool:
	if a == null or b == null or a.reward_snapshots.is_empty() or b.reward_snapshots.is_empty():
		return false
	for first: RewardNodeSnapshot in a.reward_snapshots:
		for second: RewardNodeSnapshot in b.reward_snapshots:
			if first == second:
				return false
	return true


func _loot_persistent_projection_matches(session: SESSION) -> bool:
	if session.round2_loot_session == null:
		return false
	for loot_player: PlayerPhaseState in session.round2_loot_session.players:
		var match_player: PLAYER_MATCH_STATE = session.match_state.find_player(loot_player.player_id)
		if match_player == null:
			return false
		var expected: Dictionary = match_player.to_dict()
		var actual: Dictionary = loot_player.to_dict()
		for field_value: Variant in [
			"player_id", "seat_index", "character_id", "merit_progress", "reputation",
			"orb_count", "gacha_ticket_count", "silver_coin_count",
			"equipment_exp_material_count", "equipment_exchange_material_count",
			"consumable_inventory", "equipment_collection", "relic_instance_id",
			"stigmata_a_instance_id", "stigmata_b_instance_id", "stigmata_c_instance_id",
			"gacha_state",
		]:
			var field: String = String(field_value)
			if expected.get(field) != actual.get(field):
				return false
	return true


func _clone_case_player(source: PlayerCaseState) -> PlayerCaseState:
	var result: PlayerCaseState = PlayerCaseState.new()
	result.player_id = source.player_id
	result.display_name = source.display_name
	result.merit = source.merit
	result.reputation = source.reputation
	result.orb_count = source.orb_count
	result.gacha_ticket_count = source.gacha_ticket_count
	result.is_active_in_investigation = source.is_active_in_investigation
	return result


func _tie_fixture_players() -> Array[PlayerCaseState]:
	var result: Array[PlayerCaseState] = []
	for row: Dictionary in [
		{"id": &"player_1", "rep": 5},
		{"id": &"player_2", "rep": 5},
		{"id": &"player_3", "rep": 3},
	]:
		var player: PlayerCaseState = PlayerCaseState.new()
		player.player_id = StringName(String(row.get("id", &"")))
		player.reputation = int(row.get("rep", 0))
		player.is_active_in_investigation = true
		result.append(player)
	return result


func _case_player_ids(players: Array[PlayerCaseState]) -> Array[StringName]:
	var result: Array[StringName] = []
	for player: PlayerCaseState in players:
		result.append(player.player_id)
	return result


func _movement_player(
	session: LOOT_SESSION, player_id: StringName
) -> LootMovementPlayerState:
	if session == null or session.movement_session == null:
		return null
	for player: LootMovementPlayerState in session.movement_session.player_states:
		if player.player_id == player_id:
			return player
	return null


func _m5b_case_generation_request() -> CASE_GENERATION_REQUEST:
	var role_ids: Array[StringName] = [
		&"reporter",
		&"therapist",
		&"tutorial_mobster",
	]
	var location_ids: Array[StringName] = [
		BoardLocationDefinition.LOCATION_CRIME_SCENE,
	]
	return CASE_GENERATION_REQUEST.create(
		0,
		3,
		3,
		CASE_GENERATION_REQUEST.PROFILE_TUTORIAL_EASY,
		role_ids,
		location_ids,
		3
	)


func _m5b_fake_attempt_evaluator(request: CASE_GENERATION_REQUEST, _attempt_index: int, _roles: Array[RoleDefinition]) -> Dictionary:
	if request.seed == 20:
		return _m5b_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION, PackedInt32Array([2]), PackedInt32Array([2]), "warehouse-a")
	if request.seed == 21:
		return _m5b_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION, PackedInt32Array([3]), PackedInt32Array([3]), "warehouse-b")
	if request.seed == 22:
		return _m5b_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION, PackedInt32Array([4]), PackedInt32Array([4]), "warehouse-c")
	if request.seed == 23:
		return _m5b_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION, PackedInt32Array([5]), PackedInt32Array([5]), "warehouse-d")
	return _m5b_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_MULTIPLE_SOLUTIONS, PackedInt32Array(), PackedInt32Array([2]), "warehouse-reject")


func _m5b_attempt(
	solver_status: StringName,
	solver_evil_ids: PackedInt32Array,
	ground_truth_evil_ids: PackedInt32Array,
	fingerprint_suffix: String
) -> Dictionary:
	var solver_result: CASE_GENERATOR_SOLVER_RESULT = CASE_GENERATOR_SOLVER_RESULT.new()
	if solver_status == CASE_GENERATOR_SOLVER_RESULT.STATUS_MULTIPLE_SOLUTIONS:
		solver_result.set_candidates([
			PackedInt32Array([1]),
			PackedInt32Array([2]),
		])
	else:
		solver_result.set_candidates([
			solver_evil_ids,
		])
	return {
		"candidate": {
			"fingerprint": "m5b-smoke-%s" % fingerprint_suffix,
		},
		"candidate_fingerprint": "m5b-smoke-%s" % fingerprint_suffix,
		"solver_result": solver_result,
		"ground_truth_evil_suspect_ids": ground_truth_evil_ids,
	}


func _m5b_case_definition_for_entry(entry: CASE_SEED_WAREHOUSE_ENTRY) -> CaseDefinition:
	var source: CaseDefinition = FixtureRepository.load_case()
	if source == null or entry == null:
		return null
	var definition: CaseDefinition = source.duplicate(true) as CaseDefinition
	if definition == null:
		return null
	definition.case_id = StringName("m5b_generated_%s" % _safe_case_id_suffix(entry.candidate_signature))
	definition.display_name = "Kỳ Án Sinh Tự Động"
	definition.short_description = "Smoke fixture generated option %s." % entry.candidate_signature
	definition.set_meta(&"candidate_signature", entry.candidate_signature)
	return definition


func _safe_case_id_suffix(signature: String) -> String:
	var result: String = ""
	for index: int in range(signature.length()):
		var code: int = signature.unicode_at(index)
		if (
			(code >= 48 and code <= 57)
			or (code >= 65 and code <= 90)
			or (code >= 97 and code <= 122)
		):
			result += char(code)
		else:
			result += "_"
	return result


func _strings_are_distinct(values: Array[String]) -> bool:
	var seen: Dictionary = {}
	for value: String in values:
		if seen.has(value):
			return false
		seen[value] = true
	return true


func _add(rows: Array[Dictionary], name: String, passed: bool, detail: String = "") -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": detail if not detail.is_empty() else "GĐ3-M5 multi-round next case invariant",
	})
