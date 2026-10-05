class_name PfM6ATestSuite
extends RefCounted

const SETUP_SESSION := preload(
	"res://scripts/application/player_facing/PlayerFacingSetupSession.gd"
)
const NEXT_CASE_SESSION := preload(
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
const CASE_BOUNDARY := preload(
	"res://scripts/domain/mvp/MvpCaseCompletionBoundary.gd"
)
const PLAYER_PHASE_STATE := preload(
	"res://scripts/domain/characters/PlayerPhaseState.gd"
)
const PLAYER_MATCH_STATE := preload(
	"res://scripts/domain/mvp/PlayerMatchState.gd"
)
const ROUND_STATE := preload("res://scripts/domain/mvp/MvpRoundState.gd")
const CASE_CONTROLLER := preload(
	"res://scripts/presentation/case_gameplay/VSCaseMainController.gd"
)
const CASE_SCENE := preload("res://scenes/case_gameplay/VSCaseMain.tscn")

const PLAYER_SCENE := "res://scenes/player_facing/PlayerFacingStart.tscn"
const PLAYER_CONTROLLER := (
	"res://scripts/presentation/player_facing/PlayerFacingStartController.gd"
)
const DEBUG_SCENE := "res://scenes/boot/DebugHome.tscn"
const ROUND_END_COMMIT_ID := &"pf_m4_round_end_001"


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_test_player_facing_entry(rows)
	_test_next_round_transaction(rows)
	_test_persistent_boundary(rows)
	_test_transient_reset_and_actual_case(rows)
	_test_round2_player_facing_loot_continuation(rows)
	_test_round2_player_facing_round_end_continuation(rows)
	return rows


func _test_player_facing_entry(rows: Array[Dictionary]) -> void:
	var packed: PackedScene = load(PLAYER_SCENE) as PackedScene
	var root: Node = packed.instantiate() if packed != null else null
	_add(rows, "PF-M6A Next Case Start button exists", _button_enabled(root, "StartNextCase"))
	_add(rows, "PF-M6A friendly Round indicator exists", _has(root, "RoundIndicator"))
	_add(rows, "PF-M6A Round 2 entry reuses actual Case host", _has(root, "CaseHost"))
	_add(rows, "PF-M6A player controller uses existing next-round authority", _controller_reuses_authority())
	_add(rows, "PF-M6A next-Case copy hides internal identifiers", _visible_copy_is_clean())
	if root != null:
		root.free()


func _test_next_round_transaction(rows: Array[Dictionary]) -> void:
	var context: Dictionary = _next_case_context()
	var setup: SETUP_SESSION = context.setup
	var flow: NEXT_CASE_SESSION = context.flow
	var started: Dictionary = flow.start_next_round(setup.available_case.case_id)
	var presented: Dictionary = setup.mark_next_case_started()
	_add(rows, "PF-M6A Next Case starts actual next Round once", bool(started.get("success", false)))
	_add(rows, "PF-M6A player presentation enters actual Case", bool(presented.get("success", false)) and setup.phase == SETUP_SESSION.Phase.CASE_ACTIVE)
	_add(rows, "PF-M6A active Round is created exactly once", flow._orchestrator.active_round == flow.round_state and flow.round_state != null)
	_add(rows, "PF-M6A Round number is exactly 2", flow.match_state.current_round_number == 2 and flow.round_state.round_number == 2)
	_add(rows, "PF-M6A Round 2 has a distinct identity", flow.round_state.round_id != &"player_facing_round_001")
	_add(rows, "PF-M6A Match and Round phases enter CASE", flow.match_state.current_phase == MVP_ENUMS.Phase.CASE and flow.round_state.phase == MVP_ENUMS.Phase.CASE)
	_add(rows, "PF-M6A Match leaves next-case-required state", flow.match_state.match_completion_state == &"IN_PROGRESS")
	var active_round = flow._orchestrator.active_round
	var duplicate: Dictionary = flow.start_next_round(setup.available_case.case_id)
	var duplicate_presented: Dictionary = setup.mark_next_case_started()
	_add(rows, "PF-M6A duplicate Start is structured safe", not bool(duplicate.get("success", true)) and bool(duplicate.get("duplicate_noop", false)))
	_add(rows, "PF-M6A duplicate Start creates no second Round", flow._orchestrator.active_round == active_round and flow.match_state.current_round_number == 2)
	_add(rows, "PF-M6A duplicate presentation is safe", not bool(duplicate_presented.get("success", true)) and bool(duplicate_presented.get("duplicate_noop", false)))
	_add(rows, "PF-M6A Character Selection does not repeat", setup.selection_published() and setup.selection_commit_count() == 1 and setup.phase != SETUP_SESSION.Phase.CHARACTER_SELECTION)


func _test_persistent_boundary(rows: Array[Dictionary]) -> void:
	var context: Dictionary = _next_case_context()
	var setup: SETUP_SESSION = context.setup
	var flow: NEXT_CASE_SESSION = context.flow
	var before_by_id: Dictionary = _persistent_by_player(flow)
	# Reordering proves comparisons and preservation use player_id rather than array index.
	flow.match_state.players.reverse()
	var started: Dictionary = flow.start_next_round(setup.available_case.case_id)
	var after_by_id: Dictionary = _persistent_by_player(flow)
	_add(rows, "PF-M6A reordered Match still starts Round 2", bool(started.get("success", false)))
	_add(rows, "PF-M6A player_id identity is preserved", _same_keys(before_by_id, after_by_id))
	_add(rows, "PF-M6A Character assignments persist by player_id", _field_map_equal(before_by_id, after_by_id, "character_id"))
	_add(rows, "PF-M6A cumulative Merit persists", _field_map_equal(before_by_id, after_by_id, "merit_progress"))
	_add(rows, "PF-M6A Reputation persists", _field_map_equal(before_by_id, after_by_id, "reputation"))
	_add(rows, "PF-M6A Orb persists", _field_map_equal(before_by_id, after_by_id, "orb_count"))
	_add(rows, "PF-M6A Tickets persist", _field_map_equal(before_by_id, after_by_id, "gacha_ticket_count"))
	_add(rows, "PF-M6A Equipment collections persist", _field_map_equal(before_by_id, after_by_id, "equipment_collection"))
	_add(rows, "PF-M6A loadouts persist", _loadouts_equal(before_by_id, after_by_id))
	_add(rows, "PF-M6A Gacha progression persists", _field_map_equal(before_by_id, after_by_id, "gacha_state"))
	_add(rows, "PF-M6A projected Case players preserve identities", _case_projection_matches_match(flow))


func _test_transient_reset_and_actual_case(rows: Array[Dictionary]) -> void:
	var context: Dictionary = _next_case_context()
	var setup: SETUP_SESSION = context.setup
	var flow: NEXT_CASE_SESSION = context.flow
	var historical_loot: LOOT_SESSION = flow.loot_session
	var historical_loot_snapshot: Dictionary = historical_loot.to_dict()
	var historical_management: MANAGEMENT_SESSION = flow.equipment_session
	flow.start_next_round(setup.available_case.case_id)
	_add(rows, "PF-M6A Round 1 Loot session is detached", flow.loot_session == null and historical_loot != null)
	_add(rows, "PF-M6A Round 1 management session is detached", flow.equipment_session == null and historical_management != null)
	_add(rows, "PF-M6A pending reward and overflow do not leak", flow.round_state.loot_reward_snapshot.is_empty() and flow.round_state.loot_movement_snapshot.is_empty())
	_add(rows, "PF-M6A management completion flags do not leak", flow.round_state.equipment_management_snapshot.is_empty() and flow.round_state.round_completion_flags.is_empty())
	_add(rows, "PF-M6A Round 2 Case runtime is fresh", _fresh_case_runtime(flow))
	_add(rows, "PF-M6A Round 1 Case progress does not leak", flow.round2_case_runtime.investigated_count() == 0 and flow.round2_case_runtime.action_log.is_empty())
	_add(rows, "PF-M6A submissions and verdict locks reset", flow.round2_case_runtime.submissions.is_empty() and flow.round2_case_runtime.final_submissions.is_empty() and flow.round2_case_runtime.final_required_player_ids.is_empty())
	_add(rows, "PF-M6A truth and public functions reset", flow.round2_case_runtime.truth_reveal == null and flow.round2_case_runtime.public_function_records.is_empty())
	_add(rows, "PF-M6A Round 1 temporary effects cannot leak into active Case", flow.loot_session == null and flow.round2_case_runtime.is_initialized)
	_add(rows, "PF-M6A actual Case scene accepts Round 2 projection", _actual_case_scene_accepts(flow))
	var current_player_id: StringName = flow.round2_case_runtime.current_player_id()
	var investigation = INVESTIGATION_SERVICE.new().investigate(
		flow.round2_case_definition, flow.round2_case_runtime, 1, current_player_id
	)
	_add(rows, "PF-M6A Round 2 enters active Investigation", investigation != null and investigation.success)
	_add(rows, "PF-M6A first Round 2 investigation mutates only fresh Case", flow.round2_case_runtime.investigated_count() == 1 and historical_loot.to_dict() == historical_loot_snapshot)
	_add(rows, "PF-M6A does not enter MATCH_COMPLETE", flow.match_state.current_phase != MVP_ENUMS.Phase.MATCH_COMPLETE and flow.match_state.match_completion_state != &"MATCH_COMPLETE")
	_add(rows, "PF-M6A F12 developer route remains available", AppFlow.DEBUG_HOME_SCENE == DEBUG_SCENE and AppFlow.has_method("go_to_debug_home"))


func _test_round2_player_facing_loot_continuation(rows: Array[Dictionary]) -> void:
	var context: Dictionary = _next_case_context()
	var setup: SETUP_SESSION = context.setup
	var flow: NEXT_CASE_SESSION = context.flow
	var round1_loot: LOOT_SESSION = context.historical_loot
	flow.start_next_round(setup.available_case.case_id)
	setup.mark_next_case_started()
	var boundary: CASE_BOUNDARY = flow.build_round2_test_only_completed_boundary()
	flow.handle_round2_case_completion(boundary)
	setup.mark_case_results_ready()
	setup.continue_to_loot_ready()
	var commits_before: int = flow.match_state.applied_commit_ids.size()
	_add(rows, "PF-M6A Round 2 reaches pristine player-facing LOOT_READY", setup.phase == SETUP_SESSION.Phase.LOOT_READY and flow.match_state.current_phase == MVP_ENUMS.Phase.CASE_SETTLEMENT and flow.round_state.phase == MVP_ENUMS.Phase.CASE_SETTLEMENT and flow.round_state.round_number == 2 and flow.loot_session == null and flow.round2_loot_session == null and not flow._loot_started and not flow._round2_loot_started)
	var first: Dictionary = flow.begin_loot()
	_add(rows, "PF-M6A first Round 2 player-facing Loot start succeeds", bool(first.get("success", false)) and String(first.get("code", "")) == "ROUND_2_LOOT_INITIALIZED")
	_add(rows, "PF-M6A actual Round 2 Loot session becomes active", flow.loot_session != null and flow.loot_session == flow.round2_loot_session and flow.round2_loot_initialized)
	var presented: Dictionary = setup.mark_loot_started()
	_add(rows, "PF-M6A player-facing presentation enters Round 2 Loot", bool(presented.get("success", false)) and setup.phase == SETUP_SESSION.Phase.LOOT_ACTIVE)
	_add(rows, "PF-M6A Round 1 Loot session is not reused", flow.loot_session != round1_loot and flow.loot_session.round_id != round1_loot.round_id)
	_add(rows, "PF-M6A movement state belongs to active Round 2", flow.loot_session.movement_session != null and flow.loot_session.movement_session.started and flow.loot_session.movement_session.round_id == flow.round_state.round_id)
	_add(rows, "PF-M6A Round 2 Loot start does not reapply settlement", flow.match_state.applied_commit_ids.size() == commits_before and flow.match_state.applied_commit_ids.has(flow.round_state.settlement_commit_id))
	var active_loot: LOOT_SESSION = flow.loot_session
	var duplicate: Dictionary = flow.begin_loot()
	_add(rows, "PF-M6A duplicate Round 2 Loot start is safe", not bool(duplicate.get("success", true)) and bool(duplicate.get("duplicate_noop", false)) and flow.loot_session == active_loot)


func _test_round2_player_facing_round_end_continuation(rows: Array[Dictionary]) -> void:
	var context: Dictionary = _round2_loot_context()
	var setup: SETUP_SESSION = context.setup
	var flow: NEXT_CASE_SESSION = context.flow
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
	var round1_commit_id: StringName = ROUND_END_COMMIT_ID
	var round2_commit_id: StringName = flow.active_player_facing_round_end_commit_id()
	var settlement_commit_id: StringName = flow.round_state.settlement_commit_id
	var case_progress_before: Dictionary = _case_progress_by_player(flow)
	var commit_count_before: int = flow.match_state.applied_commit_ids.size()
	var active_round_before: ROUND_STATE = flow._orchestrator.active_round
	_add(rows, "PF-M6A Round 2 Summary reports active Round 2", setup.phase == SETUP_SESSION.Phase.ROUND_SUMMARY and flow.active_round_number() == 2 and flow.round_state.round_number == 2)
	_add(rows, "PF-M6A Round 2 Round-End commit identity is distinct", not round2_commit_id.is_empty() and round2_commit_id != round1_commit_id and round2_commit_id != settlement_commit_id and flow.match_state.applied_commit_ids.has(round1_commit_id))
	var first: Dictionary = flow.commit_round_end(round2_commit_id)
	_add(rows, "PF-M6A first Round 2 Continue succeeds", bool(first.get("success", false)) and String(first.get("code", "")) == "NEXT_CASE_REQUIRED")
	_add(rows, "PF-M6A Round 2 Round End commits exactly once", flow.match_state.applied_commit_ids.size() == commit_count_before + 1 and flow.match_state.applied_commit_ids.has(round2_commit_id))
	_add(rows, "PF-M6A Round 2 persistent merge occurs once", _management_matches_match(flow) and flow.match_state.applied_commit_ids.has(settlement_commit_id))
	_add(rows, "PF-M6A Round 2 transient state clears with active Round", active_round_before != null and flow._orchestrator.active_round == null)
	_add(rows, "PF-M6A next Round number advances exactly once", flow.match_state.current_round_number == 3)
	_add(rows, "PF-M6A Round 2 reaches NEXT_CASE_REQUIRED", flow.match_state.current_phase == MVP_ENUMS.Phase.ROUND_START and flow.match_state.match_completion_state == &"NEXT_CASE_REQUIRED")
	var duplicate: Dictionary = flow.commit_round_end(round2_commit_id)
	_add(rows, "PF-M6A duplicate Round 2 Continue is safe", not bool(duplicate.get("success", true)) and bool(duplicate.get("duplicate_noop", false)) and flow.match_state.current_round_number == 3 and flow.match_state.applied_commit_ids.size() == commit_count_before + 1)
	_add(rows, "PF-M6A Round 1 rewards are not reapplied", _case_progress_by_player(flow) == case_progress_before and flow.match_state.applied_commit_ids.has(round1_commit_id) and flow.match_state.applied_commit_ids.has(settlement_commit_id))


func _round2_loot_context() -> Dictionary:
	var context: Dictionary = _next_case_context()
	var setup: SETUP_SESSION = context.setup
	var flow: NEXT_CASE_SESSION = context.flow
	flow.start_next_round(setup.available_case.case_id)
	setup.mark_next_case_started()
	var boundary: CASE_BOUNDARY = flow.build_round2_test_only_completed_boundary()
	flow.handle_case_completion(boundary)
	setup.mark_case_results_ready()
	setup.continue_to_loot_ready()
	flow.begin_loot()
	setup.mark_loot_started()
	return context


func _next_case_context() -> Dictionary:
	var setup: SETUP_SESSION = _committed_setup()
	var flow: NEXT_CASE_SESSION = NEXT_CASE_SESSION.new()
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
	flow.grant_and_equip_test_relic()
	for index: int in range(3):
		flow.mark_management_done(flow.equipment_session.current_player_id())
	setup.mark_round_summary_ready()
	setup.open_round_summary()
	var historical_loot: LOOT_SESSION = flow.loot_session
	flow.commit_round_end(ROUND_END_COMMIT_ID)
	setup.mark_next_case_required()
	return {"setup": setup, "flow": flow, "historical_loot": historical_loot}


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


func _complete_loot(flow: NEXT_CASE_SESSION) -> void:
	var guard: int = 0
	while flow.loot_session.phase != LOOT_SESSION.Phase.LOOT_END_CONFIRMATION_READY and guard < 100:
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


func _persistent_by_player(flow: NEXT_CASE_SESSION) -> Dictionary:
	var result: Dictionary = {}
	for player in flow.match_state.players:
		result[String(player.player_id)] = player.to_dict()
	return result


func _case_progress_by_player(flow: NEXT_CASE_SESSION) -> Dictionary:
	var result: Dictionary = {}
	for player in flow.match_state.players:
		result[String(player.player_id)] = {
			"merit": player.merit_progress,
			"reputation": player.reputation,
		}
	return result


func _management_matches_match(flow: NEXT_CASE_SESSION) -> bool:
	for source: PLAYER_PHASE_STATE in flow.equipment_session.players:
		var target: PLAYER_MATCH_STATE = flow.match_state.find_player(source.player_id)
		if target == null:
			return false
		if (
			target.orb_count != source.orb_count
			or target.gacha_ticket_count != source.gacha_ticket_count
			or target.silver_coin_count != source.silver_coin_count
			or target.equipment_exp_material_count != source.equipment_exp_material_count
			or target.equipment_exchange_material_count != source.equipment_exchange_material_count
			or target.relic_instance_id != source.relic_instance_id
			or target.stigmata_a_instance_id != source.stigmata_a_instance_id
			or target.stigmata_b_instance_id != source.stigmata_b_instance_id
			or target.stigmata_c_instance_id != source.stigmata_c_instance_id
			or target.equipment_collection.size() != source.equipment_collection.size()
		):
			return false
	return true


func _same_keys(left: Dictionary, right: Dictionary) -> bool:
	if left.size() != right.size():
		return false
	for key: Variant in left.keys():
		if not right.has(key):
			return false
	return true


func _field_map_equal(left: Dictionary, right: Dictionary, field: String) -> bool:
	for player_id_value: Variant in left.keys():
		var left_row: Dictionary = left.get(player_id_value, {})
		var right_row: Dictionary = right.get(player_id_value, {})
		if left_row.get(field) != right_row.get(field):
			return false
	return true


func _loadouts_equal(left: Dictionary, right: Dictionary) -> bool:
	for field: String in [
		"relic_instance_id", "stigmata_a_instance_id", "stigmata_b_instance_id",
		"stigmata_c_instance_id",
	]:
		if not _field_map_equal(left, right, field):
			return false
	return true


func _case_projection_matches_match(flow: NEXT_CASE_SESSION) -> bool:
	if flow.round2_projected_case_players.size() != flow.match_state.players.size():
		return false
	for projected in flow.round2_projected_case_players:
		var persistent = flow.match_state.find_player(projected.player_id)
		if persistent == null or persistent.display_name != projected.display_name:
			return false
	return true


func _fresh_case_runtime(flow: NEXT_CASE_SESSION) -> bool:
	return (
		flow.round2_case_runtime != null
		and flow.round2_case_runtime.is_initialized
		and flow.round2_case_runtime.accepts_investigation_actions
		and flow.round2_case_runtime.turn_number == 1
		and flow.round2_case_runtime.case_outcome == CaseEnums.CaseOutcome.IN_PROGRESS
	)


func _actual_case_scene_accepts(flow: NEXT_CASE_SESSION) -> bool:
	var controller: CASE_CONTROLLER = CASE_SCENE.instantiate() as CASE_CONTROLLER
	if controller == null:
		return false
	controller.configure_integrated_case(flow.round2_projected_case_players, true)
	var valid: bool = (
		controller.integration_mode
		and controller.player_facing_mode
		and controller.integration_players.size() == 3
	)
	controller.free()
	return valid


func _controller_reuses_authority() -> bool:
	var source: String = FileAccess.get_file_as_string(PLAYER_CONTROLLER)
	return (
		source.contains("MvpIntegratedNextCaseSession.gd")
		and source.contains("start_next_round(")
		and source.contains("active_case_players()")
		and not source.contains("MvpMatchState.new()")
	)


func _visible_copy_is_clean() -> bool:
	var source: String = FileAccess.get_file_as_string(PLAYER_SCENE)
	for line: String in source.split("\n"):
		if not line.begins_with("text = ") and not line.begins_with("tooltip_text = "):
			continue
		var lowered: String = line.to_lower()
		for forbidden: String in ["next_case_required", "gd3", "pf-m6", "commit", "fixture", "match_complete"]:
			if lowered.contains(forbidden):
				return false
	return true


func _button_enabled(root: Node, name: String) -> bool:
	var button: Button = root.find_child(name, true, false) as Button if root != null else null
	return button != null and not button.disabled


func _has(root: Node, name: String) -> bool:
	return root != null and root.find_child(name, true, false) != null


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({"name": name, "passed": passed, "detail": "PF-M6A player-facing next-Round Case invariant"})
