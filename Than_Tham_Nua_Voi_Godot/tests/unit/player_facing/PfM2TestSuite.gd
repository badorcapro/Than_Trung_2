class_name PfM2TestSuite
extends RefCounted

const SETUP_SESSION := preload(
	"res://scripts/application/player_facing/PlayerFacingSetupSession.gd"
)
const CASE_FLOW_SESSION := preload(
	"res://scripts/application/mvp/MvpIntegratedCaseLootSession.gd"
)
const CASE_CONTROLLER := preload(
	"res://scripts/presentation/case_gameplay/VSCaseMainController.gd"
)
const CASE_BOUNDARY := preload(
	"res://scripts/domain/mvp/MvpCaseCompletionBoundary.gd"
)
const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const MVP_SERIALIZER := preload("res://scripts/application/mvp/MvpStateSerializer.gd")
const TRUTH_BUILDER := preload(
	"res://scripts/domain/cases/CaseTruthRevealBuilder.gd"
)
const CASE_TRUTH_REVEAL := preload(
	"res://scripts/domain/cases/CaseTruthReveal.gd"
)
const PLAYER_MATCH_STATE := preload(
	"res://scripts/domain/mvp/PlayerMatchState.gd"
)
const FIXTURE_REPOSITORY := preload(
	"res://scripts/domain/cases/FixtureRepository.gd"
)

const PLAYER_SCENE := "res://scenes/player_facing/PlayerFacingStart.tscn"
const ACTUAL_CASE_SCENE := "res://scenes/case_gameplay/VSCaseMain.tscn"
const DEBUG_SCENE := "res://scenes/boot/DebugHome.tscn"


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_test_player_entry(rows)
	_test_actual_case_start(rows)
	_test_actual_case_authorities(rows)
	_test_truth_and_settlement(rows)
	_test_loot_ready_endpoint(rows)
	return rows


func _test_player_entry(rows: Array[Dictionary]) -> void:
	var packed: PackedScene = load(PLAYER_SCENE) as PackedScene
	_add(rows, "PF-M2 player-facing scene still loads", packed != null)
	var root: Node = packed.instantiate() if packed != null else null
	var start_case: Button
	if root != null:
		start_case = root.find_child("StartCase", true, false) as Button
	_add(rows, "PF-M2 Case Selection exposes Start Investigation", start_case != null)
	_add(rows, "PF-M2 Start Investigation is functional", start_case != null and not start_case.disabled)
	_add(rows, "PF-M2 actual Case scene remains the GĐ1 scene", load(ACTUAL_CASE_SCENE) is PackedScene)
	_add(rows, "PF-M2 DebugHome remains loadable", load(DEBUG_SCENE) is PackedScene)
	_add(rows, "PF-M2 player UI has Results screen", root != null and root.find_child("ResultsPanel", true, false) != null)
	_add(rows, "PF-M2 player UI has Loot Ready screen", root != null and root.find_child("LootReadyPanel", true, false) != null)
	_add(rows, "PF-M2 player UI text hides internal identifiers", _player_scene_copy_is_clean())
	if root != null:
		root.free()


func _test_actual_case_start(rows: Array[Dictionary]) -> void:
	var setup: SETUP_SESSION = _committed_setup()
	var original_ids: Dictionary = _character_by_player_id(setup)
	var flow: CASE_FLOW_SESSION = CASE_FLOW_SESSION.new()
	var initialized: Dictionary = flow.initialize_player_facing_case(
		setup.match_state, setup.available_case
	)
	_add(rows, "PF-M2 Case Selection enters actual Case", bool(initialized.get("success", false)))
	_add(rows, "PF-M2 Match enters CASE phase", flow.match_state.current_phase == MVP_ENUMS.Phase.CASE)
	_add(rows, "PF-M2 Round enters CASE phase", flow.round_state.phase == MVP_ENUMS.Phase.CASE)
	_add(rows, "PF-M2 creates the first Round exactly once", flow.round_state.round_number == 1 and flow.match_state.current_round_number == 1)
	_add(rows, "PF-M2 selected Case is the existing Case authority", flow.case_definition == setup.available_case)
	_add(rows, "PF-M2 actual Case receives exactly three players", flow.projected_case_players.size() == 3)
	_add(rows, "PF-M2 Case projection preserves player_id", _case_ids_match(flow, setup))
	_add(rows, "PF-M2 Character assignments survive Case start", _character_map_matches(setup, original_ids))
	var started: Dictionary = setup.mark_case_started()
	_add(rows, "PF-M2 presentation records one active Case", bool(started.get("success", false)) and setup.phase == SETUP_SESSION.Phase.CASE_ACTIVE)
	var duplicate: Dictionary = setup.mark_case_started()
	_add(rows, "PF-M2 duplicate Case start is structured safe", not bool(duplicate.get("success", true)) and bool(duplicate.get("duplicate_noop", false)))


func _test_actual_case_authorities(rows: Array[Dictionary]) -> void:
	var packed: PackedScene = load(ACTUAL_CASE_SCENE) as PackedScene
	var controller: CASE_CONTROLLER
	if packed != null:
		controller = packed.instantiate() as CASE_CONTROLLER
	_add(rows, "PF-M2 actual Case uses VSCaseMainController", controller != null)
	_add(rows, "PF-M2 Investigation authority remains available", controller != null and controller.has_method("_on_investigate_pressed") and controller.investigation_service != null)
	_add(rows, "PF-M2 function authority remains available", controller != null and controller.has_method("_on_function_pressed") and controller.function_execution_service != null)
	_add(rows, "PF-M2 Early Submission authority remains available", controller != null and controller.has_method("_on_submit_pressed") and controller.submission_service != null)
	var final_verdict_report := _final_verdict_authority_report(controller)
	_add_detail(rows, "PF-M2 Final Verdict authority remains available", bool(final_verdict_report.get("passed", false)), String(final_verdict_report.get("detail", "")))
	_add(rows, "PF-M2 POST_REVEAL function authority remains available", controller != null and controller.post_reveal_function_service != null)
	_add(rows, "PF-M2 Case has no Skip action", controller != null and not controller.has_method("_on_skip_pressed"))
	if controller != null:
		controller.configure_integrated_case([], true)
	_add(rows, "PF-M2 player-facing Case mode is opt-in", controller != null and controller.integration_mode and controller.player_facing_mode)
	if controller != null:
		controller.free()


func _test_truth_and_settlement(rows: Array[Dictionary]) -> void:
	var setup: SETUP_SESSION = _committed_setup()
	var flow: CASE_FLOW_SESSION = CASE_FLOW_SESSION.new()
	flow.initialize_player_facing_case(setup.match_state, setup.available_case)
	var before_by_id: Dictionary = _orb_by_player_id(setup)
	var boundary: CASE_BOUNDARY = flow.build_test_only_completed_boundary()
	_add(rows, "PF-M2 deterministic boundary uses actual settlement authority", boundary != null and boundary.settlement_result != null and boundary.settlement_result.success)
	var reveal: CASE_TRUTH_REVEAL
	if boundary != null:
		reveal = TRUTH_BUILDER.new().build(
			flow.case_definition,
			boundary.runtime_state,
			FIXTURE_REPOSITORY.load_roles()
		)
	_add(rows, "PF-M2 Truth Reveal can be built from actual Case state", reveal != null and reveal.suspect_truths.size() == 8)
	var applied: Dictionary = flow.handle_case_completion(boundary)
	_add(rows, "PF-M2 actual Case completion is accepted", bool(applied.get("success", false)))
	_add(rows, "PF-M2 settlement reaches CASE_SETTLEMENT", flow.match_state.current_phase == MVP_ENUMS.Phase.CASE_SETTLEMENT and flow.round_state.phase == MVP_ENUMS.Phase.CASE_SETTLEMENT)
	_add(rows, "PF-M2 settlement is applied exactly once", flow.round_state.settlement_applied and flow.match_state.applied_commit_ids.has(flow.round_state.settlement_commit_id))
	_add(rows, "PF-M2 results contain all players by player_id", _summary_covers_match(flow))
	var wrong: Dictionary = _summary_row_with_status(flow, "WRONG")
	_add(rows, "PF-M2 deterministic result contains a Wrong player", not wrong.is_empty())
	_add(rows, "PF-M2 Wrong remains exactly plus one Orb", int(wrong.get("orb_delta", 0)) == 1 and _wrong_orb_matches(flow, wrong, before_by_id))
	var neutral: Dictionary = _summary_row_with_status(flow, "CHUA_TRINH_AN")
	_add(rows, "PF-M2 Chưa Trình Án remains present", not neutral.is_empty())
	_add(rows, "PF-M2 Chưa Trình Án remains neutral", float(neutral.get("merit_delta", 1.0)) == 0.0 and int(neutral.get("reputation_delta", 1)) == 0 and int(neutral.get("orb_delta", 1)) == 0 and int(neutral.get("ticket_delta", 1)) == 0)
	_add(rows, "PF-M2 Results use authored settlement ticket split", _ticket_split_matches(flow))
	var before_duplicate: Dictionary = flow.match_state.to_dict()
	var duplicate: Dictionary = flow.handle_case_completion(boundary)
	_add(rows, "PF-M2 duplicate completion is structured no-op", not bool(duplicate.get("success", true)) and bool(duplicate.get("duplicate_noop", false)))
	_add(rows, "PF-M2 duplicate completion does not duplicate rewards", flow.match_state.to_dict() == before_duplicate)
	_add(rows, "PF-M2 settlement checkpoint round-trips", bool(flow.checkpoints.get("post_settlement", {}).get("matches", false)))


func _test_loot_ready_endpoint(rows: Array[Dictionary]) -> void:
	var setup: SETUP_SESSION = _committed_setup()
	var flow: CASE_FLOW_SESSION = CASE_FLOW_SESSION.new()
	flow.initialize_player_facing_case(setup.match_state, setup.available_case)
	setup.mark_case_started()
	flow.handle_case_completion(flow.build_test_only_completed_boundary())
	var results_ready: Dictionary = setup.mark_case_results_ready()
	_add(rows, "PF-M2 player-facing Results becomes ready", bool(results_ready.get("success", false)) and setup.phase == SETUP_SESSION.Phase.CASE_RESULTS)
	var continued: Dictionary = setup.continue_to_loot_ready()
	_add(rows, "PF-M2 reaches exact LOOT_READY endpoint", bool(continued.get("success", false)) and setup.phase == SETUP_SESSION.Phase.LOOT_READY)
	_add(rows, "PF-M2 does not initialize actual Loot session", flow.loot_session == null)
	_add(rows, "PF-M2 does not begin Loot movement", flow.round_state.loot_movement_snapshot.is_empty() and flow.round_state.loot_reward_snapshot.is_empty())
	_add(rows, "PF-M2 Match remains ready at CASE_SETTLEMENT", flow.match_state.current_phase == MVP_ENUMS.Phase.CASE_SETTLEMENT and flow.round_state.settlement_applied)
	_add(rows, "PF-M2 does not create a later Round", flow.match_state.current_round_number == 1 and flow.round_state.round_number == 1)
	_add(rows, "PF-M2 does not enter MATCH_COMPLETE", flow.match_state.current_phase != MVP_ENUMS.Phase.MATCH_COMPLETE and flow.match_state.match_completion_state == &"IN_PROGRESS")
	_add(rows, "PF-M2 final Match/Round state round-trips", bool(MVP_SERIALIZER.new().round_trip_diagnostic(flow.match_state, flow.round_state).get("matches", false)))
	var duplicate: Dictionary = setup.continue_to_loot_ready()
	_add(rows, "PF-M2 duplicate Loot Ready transition is safe", not bool(duplicate.get("success", true)) and bool(duplicate.get("duplicate_noop", false)))
	_add(rows, "PF-M2 developer route remains available", AppFlow.has_method("go_to_debug_home") and AppFlow.DEBUG_HOME_SCENE == DEBUG_SCENE)


func _final_verdict_authority_report(controller: CASE_CONTROLLER) -> Dictionary:
	var checks: Dictionary = {}
	checks.service_exists = controller != null and controller.final_verdict_service != null
	checks.old_continue_removed = controller != null and not controller.has_method("_on_final_continue_pressed")
	checks.automatic_handoff_hook_exists = controller != null and controller.has_method("_show_final_handoff") and controller.has_method("_finish_final_handoff")
	var case_definition: CaseDefinition = FIXTURE_REPOSITORY.load_case()
	var players: Array[PlayerCaseState] = FIXTURE_REPOSITORY.load_players()
	checks.fixture_loaded = case_definition != null and not players.is_empty()
	var runtime := CaseRuntimeState.new()
	if checks.fixture_loaded:
		runtime.initialize(case_definition, players)
		var turn_manager := TurnManager.new()
		checks.turn_order_initialized = turn_manager.initialize(runtime.players, 3030)
		if checks.turn_order_initialized:
			runtime.apply_turn_snapshot(turn_manager)
		for suspect in runtime.suspects:
			suspect.is_investigated = true
		runtime.case_outcome = CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
		runtime.lock_case_actions()
	else:
		checks.turn_order_initialized = false
	checks.runtime_initialized = runtime.is_initialized and not runtime.turn_order_player_ids.is_empty()
	var service := controller.final_verdict_service if checks.service_exists else FinalVerdictService.new()
	var initialized := service.initialize(runtime) if checks.runtime_initialized else FinalVerdictResult.failed(&"TEST_RUNTIME_INVALID", "PF-M2 test runtime did not initialize final authority.")
	checks.final_initialize_succeeds = initialized.success
	var first_player := runtime.current_final_player_id()
	checks.player_a_available = first_player != &""
	var first_submission := CaseSubmission.new()
	first_submission.configure(first_player, runtime.turn_number, PackedInt32Array([4, 5]), PackedInt32Array(), PackedInt32Array(), CaseEnums.SubmissionPhase.FINAL)
	var first_lock := service.lock_submission(case_definition, runtime, first_submission) if checks.player_a_available else FinalVerdictResult.failed(&"TEST_NO_PLAYER_A", "No first final player.")
	checks.player_a_lock_succeeds = first_lock.success
	checks.truth_not_revealed_too_early = first_lock.success and runtime.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT and runtime.final_results.is_empty()
	var second_player := runtime.current_final_player_id()
	checks.current_player_advances_to_b = second_player != &"" and second_player != first_player
	checks.authority_still_accepts_b = checks.current_player_advances_to_b and runtime.find_player(second_player) != null
	var second_submission := CaseSubmission.new()
	second_submission.configure(second_player, runtime.turn_number, PackedInt32Array([4]), PackedInt32Array(), PackedInt32Array(), CaseEnums.SubmissionPhase.FINAL)
	var second_lock := service.lock_submission(case_definition, runtime, second_submission) if checks.authority_still_accepts_b else FinalVerdictResult.failed(&"TEST_NO_PLAYER_B", "No next final player.")
	checks.player_b_lock_succeeds = second_lock.success
	var order := [
		"service_exists",
		"old_continue_removed",
		"automatic_handoff_hook_exists",
		"fixture_loaded",
		"turn_order_initialized",
		"runtime_initialized",
		"final_initialize_succeeds",
		"player_a_available",
		"player_a_lock_succeeds",
		"truth_not_revealed_too_early",
		"current_player_advances_to_b",
		"authority_still_accepts_b",
		"player_b_lock_succeeds",
	]
	var passed := true
	var detail_parts: Array[String] = []
	for key in order:
		var value := bool(checks.get(key, false))
		passed = passed and value
		detail_parts.append("%s=%s" % [key, "true" if value else "false"])
	checks.passed = passed
	checks.detail = "; ".join(detail_parts)
	return checks


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


func _character_by_player_id(setup: SETUP_SESSION) -> Dictionary:
	var result: Dictionary = {}
	for player in setup.match_state.players:
		result[String(player.player_id)] = String(player.character_id)
	return result


func _character_map_matches(setup: SETUP_SESSION, expected: Dictionary) -> bool:
	return _character_by_player_id(setup) == expected


func _case_ids_match(flow: CASE_FLOW_SESSION, setup: SETUP_SESSION) -> bool:
	for projected in flow.projected_case_players:
		if setup.match_state.find_player(projected.player_id) == null:
			return false
	return true


func _orb_by_player_id(setup: SETUP_SESSION) -> Dictionary:
	var result: Dictionary = {}
	for player in setup.match_state.players:
		result[String(player.player_id)] = player.orb_count
	return result


func _summary_covers_match(flow: CASE_FLOW_SESSION) -> bool:
	if flow.settlement_summary.size() != flow.match_state.players.size():
		return false
	for player in flow.match_state.players:
		var found := false
		for row: Dictionary in flow.settlement_summary:
			if String(row.get("player_id", "")) == String(player.player_id):
				found = true
				break
		if not found:
			return false
	return true


func _summary_row_with_status(flow: CASE_FLOW_SESSION, status: String) -> Dictionary:
	for row: Dictionary in flow.settlement_summary:
		if String(row.get("status", "")) == status:
			return row
	return {}


func _wrong_orb_matches(
	flow: CASE_FLOW_SESSION, wrong: Dictionary, before_by_id: Dictionary
) -> bool:
	var player_id: String = String(wrong.get("player_id", ""))
	var player: PLAYER_MATCH_STATE = flow.match_state.find_player(StringName(player_id))
	return (
		player != null
		and player.orb_count == int(before_by_id.get(player_id, 0)) + 1
		and int(wrong.get("normalized_orb_delta", 0)) == 1
	)


func _ticket_split_matches(flow: CASE_FLOW_SESSION) -> bool:
	for row: Dictionary in flow.settlement_summary:
		if int(row.get("ticket_delta", 0)) != int(row.get("base_ticket_delta", 0)):
			return false
	return true


func _player_scene_copy_is_clean() -> bool:
	var source: String = FileAccess.get_file_as_string(PLAYER_SCENE)
	for line: String in source.split("\n"):
		if not line.begins_with("text = ") and not line.begins_with("tooltip_text = "):
			continue
		var lowered: String = line.to_lower()
		for forbidden: String in ["vs_case_001", "test_only", "fixture", "gd3", "pf-m2", "blocked", "commit"]:
			if lowered.contains(forbidden):
				return false
	return true


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "PF-M2 player-facing actual Case invariant",
	})


func _add_detail(rows: Array[Dictionary], name: String, passed: bool, detail: String) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": detail if not detail.is_empty() else "PF-M2 player-facing actual Case invariant",
	})
