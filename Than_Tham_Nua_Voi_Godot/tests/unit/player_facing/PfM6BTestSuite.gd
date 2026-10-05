class_name PfM6BTestSuite
extends RefCounted

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
const INVESTIGATION_SERVICE := preload(
	"res://scripts/domain/cases/InvestigationService.gd"
)
const CASE_CONTROLLER := preload(
	"res://scripts/presentation/case_gameplay/VSCaseMainController.gd"
)
const CASE_SCENE := preload("res://scenes/case_gameplay/VSCaseMain.tscn")

const PLAYER_CONTROLLER_PATH := (
	"res://scripts/presentation/player_facing/PlayerFacingStartController.gd"
)


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_test_general_round_three_start(rows)
	_test_general_round_three_case_and_loot(rows)
	_test_structural_active_round_authority(rows)
	return rows


func _test_general_round_three_start(rows: Array[Dictionary]) -> void:
	var context: Dictionary = _round_three_ready_context()
	var setup: SETUP_SESSION = context.setup
	var flow: LOOP_SESSION = context.flow
	var before: Dictionary = _persistent_by_player(flow)
	var round2_loot: LOOT_SESSION = context.round2_loot
	var started: Dictionary = flow.start_next_round(setup.available_case.case_id)
	var presented: Dictionary = setup.mark_next_case_started()
	_add(rows, "PF-M6B Round 3 starts through general next-Round API", bool(started.get("success", false)) and String(started.get("code", "")) == "NEXT_ROUND_CASE_READY")
	_add(rows, "PF-M6B player-facing presentation enters Round 3 Case", bool(presented.get("success", false)) and setup.phase == SETUP_SESSION.Phase.CASE_ACTIVE)
	_add(rows, "PF-M6B active Round number is exactly 3", flow.match_state.current_round_number == 3 and flow.round_state.round_number == 3 and flow.active_round_number() == 3)
	_add(rows, "PF-M6B Round 3 owns one active RoundState", flow._orchestrator.active_round == flow.round_state and flow.round_state.round_id == &"gd3_m5_round_003")
	_add(rows, "PF-M6B Character assignments persist into Round 3", _field_map_equal(before, _persistent_by_player(flow), "character_id"))
	_add(rows, "PF-M6B persistent resources survive into Round 3", _persistent_resources_equal(before, _persistent_by_player(flow)))
	_add(rows, "PF-M6B Equipment loadout and Gacha survive into Round 3", _progression_equal(before, _persistent_by_player(flow)))
	_add(rows, "PF-M6B Round 2 Loot and Management transients are detached", round2_loot != null and flow.loot_session == null and flow.equipment_session == null and flow.active_loot_session == null)
	_add(rows, "PF-M6B Round 3 RoundState starts with fresh transient snapshots", flow.round_state.case_settlement_snapshot.is_empty() and flow.round_state.loot_movement_snapshot.is_empty() and flow.round_state.loot_reward_snapshot.is_empty() and flow.round_state.equipment_management_snapshot.is_empty() and flow.round_state.round_completion_flags.is_empty())
	_add(rows, "PF-M6B Round 3 actual Case runtime is fresh", flow.active_case_runtime != null and flow.active_case_runtime.is_initialized and flow.active_case_runtime.investigated_count() == 0 and flow.active_case_runtime.submissions.is_empty() and flow.active_case_runtime.final_submissions.is_empty() and flow.active_case_runtime.action_log.is_empty() and flow.active_case_runtime.truth_reveal == null)
	var active_round = flow._orchestrator.active_round
	var duplicate: Dictionary = flow.start_next_round(setup.available_case.case_id)
	_add(rows, "PF-M6B duplicate Round 3 Start is safe", not bool(duplicate.get("success", true)) and bool(duplicate.get("duplicate_noop", false)) and flow._orchestrator.active_round == active_round and flow.match_state.current_round_number == 3)


func _test_general_round_three_case_and_loot(rows: Array[Dictionary]) -> void:
	var context: Dictionary = _round_three_ready_context()
	var setup: SETUP_SESSION = context.setup
	var flow: LOOP_SESSION = context.flow
	flow.start_next_round(setup.available_case.case_id)
	setup.mark_next_case_started()
	var controller: CASE_CONTROLLER = CASE_SCENE.instantiate() as CASE_CONTROLLER
	if controller != null:
		controller.configure_integrated_case(flow.active_case_players(), true)
	_add(rows, "PF-M6B actual VSCaseMain accepts Round 3 players", controller != null and controller.integration_mode and controller.integration_players.size() == 3)
	if controller != null:
		controller.free()
	var player_id: StringName = flow.active_case_runtime.current_player_id()
	var investigation = INVESTIGATION_SERVICE.new().investigate(
		flow.active_case_definition, flow.active_case_runtime, 1, player_id
	)
	_add(rows, "PF-M6B Round 3 Investigation is usable", investigation != null and investigation.success and flow.active_case_runtime.investigated_count() == 1)
	var boundary = flow.build_active_round_test_only_completed_boundary()
	var settled: Dictionary = flow.handle_case_completion(boundary)
	setup.mark_case_results_ready()
	setup.continue_to_loot_ready()
	_add(rows, "PF-M6B Round 3 Case settles through active-Round authority", bool(settled.get("success", false)) and flow.round_state.settlement_applied and flow.match_state.applied_commit_ids.has(flow.round_state.settlement_commit_id))
	var round2_settlement_id: StringName = StringName(context.round2_settlement_id)
	_add(rows, "PF-M6B Round 3 settlement identity is unique", flow.round_state.settlement_commit_id != round2_settlement_id)
	var begun: Dictionary = flow.begin_loot()
	var shown: Dictionary = setup.mark_loot_started()
	_add(rows, "PF-M6B Round 3 Loot starts through same active-Round API", bool(begun.get("success", false)) and bool(shown.get("success", false)) and setup.phase == SETUP_SESSION.Phase.LOOT_ACTIVE and flow.loot_session == flow.active_loot_session)
	_add(rows, "PF-M6B Round 3 Loot owns fresh movement state", flow.loot_session != context.round2_loot and flow.loot_session.round_id == flow.round_state.round_id and flow.loot_session.movement_session.round_id == flow.round_state.round_id)
	_add(rows, "PF-M6B loop does not enter MATCH_COMPLETE", flow.match_state.current_phase != MVP_ENUMS.Phase.MATCH_COMPLETE and flow.match_state.match_completion_state != &"MATCH_COMPLETE")


func _test_structural_active_round_authority(rows: Array[Dictionary]) -> void:
	var session_source: String = FileAccess.get_file_as_string(
		"res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd"
	)
	var controller_source: String = FileAccess.get_file_as_string(PLAYER_CONTROLLER_PATH)
	_add(rows, "PF-M6B controller launches active Round without Round-specific API", controller_source.contains("_launch_active_round_case") and controller_source.contains("active_case_players()") and not controller_source.contains("_launch_round3_case") and not controller_source.contains("begin_round3"))
	_add(rows, "PF-M6B active lifecycle has no Round 3 implementation branch", not session_source.contains("begin_round3") and not session_source.contains("handle_round3") and not session_source.contains("round_number == 3"))
	_add(rows, "PF-M6B Round End identity derives from active round_id", session_source.contains("pf_round_end_%s") and session_source.contains("round_state.round_id"))


func _round_three_ready_context() -> Dictionary:
	var setup: SETUP_SESSION = _committed_setup()
	var flow: LOOP_SESSION = LOOP_SESSION.new()
	flow.initialize_player_facing_case(setup.match_state, setup.available_case)
	setup.mark_case_started()
	_finish_current_round(setup, flow, flow.build_test_only_completed_boundary())
	flow.start_next_round(setup.available_case.case_id)
	setup.mark_next_case_started()
	var round2_boundary = flow.build_active_round_test_only_completed_boundary()
	flow.handle_case_completion(round2_boundary)
	setup.mark_case_results_ready()
	setup.continue_to_loot_ready()
	flow.begin_loot()
	setup.mark_loot_started()
	var round2_loot: LOOT_SESSION = flow.loot_session
	var round2_settlement_id: StringName = flow.round_state.settlement_commit_id
	_finish_loot_management_and_round_end(setup, flow)
	return {
		"setup": setup,
		"flow": flow,
		"round2_loot": round2_loot,
		"round2_settlement_id": round2_settlement_id,
	}


func _finish_current_round(setup: SETUP_SESSION, flow: LOOP_SESSION, boundary) -> void:
	flow.handle_case_completion(boundary)
	setup.mark_case_results_ready()
	setup.continue_to_loot_ready()
	flow.begin_loot()
	setup.mark_loot_started()
	_finish_loot_management_and_round_end(setup, flow)


func _finish_loot_management_and_round_end(
	setup: SETUP_SESSION, flow: LOOP_SESSION
) -> void:
	_complete_loot(flow)
	flow.begin_loot_end_confirmation()
	setup.mark_loot_confirmation()
	while flow.equipment_session.phase == MANAGEMENT_SESSION.Phase.LOOT_END_CONFIRMATION:
		flow.confirm_loot_end(flow.equipment_session.current_player_id())
	setup.mark_equipment_management()
	while flow.equipment_session.phase == MANAGEMENT_SESSION.Phase.EQUIPMENT_MANAGEMENT:
		flow.mark_management_done(flow.equipment_session.current_player_id())
	setup.mark_round_summary_ready()
	setup.open_round_summary()
	flow.commit_round_end(flow.active_player_facing_round_end_commit_id())
	setup.mark_next_case_required()


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


func _persistent_by_player(flow: LOOP_SESSION) -> Dictionary:
	var result: Dictionary = {}
	for player in flow.match_state.players:
		result[String(player.player_id)] = player.to_dict()
	return result


func _field_map_equal(left: Dictionary, right: Dictionary, field: String) -> bool:
	for player_id: Variant in left.keys():
		var left_row: Dictionary = left.get(player_id, {})
		var right_row: Dictionary = right.get(player_id, {})
		if left_row.get(field) != right_row.get(field):
			return false
	return true


func _persistent_resources_equal(left: Dictionary, right: Dictionary) -> bool:
	for field: String in [
		"merit_progress", "reputation", "orb_count", "gacha_ticket_count",
		"silver_coin_count", "equipment_exp_material_count",
		"equipment_exchange_material_count", "consumable_inventory",
	]:
		if not _field_map_equal(left, right, field):
			return false
	return true


func _progression_equal(left: Dictionary, right: Dictionary) -> bool:
	for field: String in [
		"equipment_collection", "relic_instance_id", "stigmata_a_instance_id",
		"stigmata_b_instance_id", "stigmata_c_instance_id", "gacha_state",
	]:
		if not _field_map_equal(left, right, field):
			return false
	return true


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "PF-M6B generalized player-facing multi-Round invariant",
	})
