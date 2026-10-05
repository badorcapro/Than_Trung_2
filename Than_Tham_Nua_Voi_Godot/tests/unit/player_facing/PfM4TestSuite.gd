class_name PfM4TestSuite
extends RefCounted

const SETUP_SESSION := preload("res://scripts/application/player_facing/PlayerFacingSetupSession.gd")
const ROUND_FLOW := preload("res://scripts/application/mvp/MvpIntegratedRoundCompletionSession.gd")
const LOOT_SESSION := preload("res://scripts/domain/loot/LootRewardSession.gd")
const MANAGEMENT_SESSION := preload("res://scripts/domain/equipment/EquipmentManagementSession.gd")
const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")

const PLAYER_SCENE := "res://scenes/player_facing/PlayerFacingStart.tscn"
const DEBUG_SCENE := "res://scenes/boot/DebugHome.tscn"
const COMMIT_ID := &"pf_m4_round_end_001"


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_test_summary_presentation(rows)
	_test_round_end_authority(rows)
	_test_next_case_endpoint(rows)
	return rows


func _test_summary_presentation(rows: Array[Dictionary]) -> void:
	var context: Dictionary = _management_ready_context()
	var setup: SETUP_SESSION = context.setup
	var flow: ROUND_FLOW = context.flow
	var summary_rows: Array[Dictionary] = setup.round_summary_presentation(
		flow.match_state, flow.equipment_session.players
	)
	_add(rows, "PF-M4 player scene has Round Summary", _scene_has("RoundSummaryPanel"))
	_add(rows, "PF-M4 Round Summary button is enabled", _scene_button_enabled("RoundSummary"))
	_add(rows, "PF-M4 summary has exactly three players", summary_rows.size() == 3)
	_add(rows, "PF-M4 summary preserves identities by player_id", _summary_ids_match(flow, summary_rows))
	_add(rows, "PF-M4 summary preserves Character assignments", _summary_characters_match(setup, flow, summary_rows))
	_add(rows, "PF-M4 summary reads authoritative Merit", _summary_numeric_matches(flow, summary_rows, "merit", "merit_progress"))
	_add(rows, "PF-M4 summary reads authoritative Reputation", _summary_numeric_matches(flow, summary_rows, "reputation", "reputation"))
	_add(rows, "PF-M4 summary reads management Orb", _summary_management_matches(flow, summary_rows, "orb", "orb_count"))
	_add(rows, "PF-M4 summary reads management Tickets", _summary_management_matches(flow, summary_rows, "tickets", "gacha_ticket_count"))
	_add(rows, "PF-M4 summary reads actual Equipment state", _summary_equipment_matches(flow, summary_rows))
	var opened: Dictionary = setup.open_round_summary()
	_add(rows, "PF-M4 summary-ready opens actual summary", bool(opened.get("success", false)) and setup.phase == SETUP_SESSION.Phase.ROUND_SUMMARY)
	_add(rows, "PF-M4 summary copy hides internal identifiers", _player_copy_is_clean())


func _test_round_end_authority(rows: Array[Dictionary]) -> void:
	var context: Dictionary = _management_ready_context()
	var flow: ROUND_FLOW = context.flow
	var commits_before: int = flow.match_state.applied_commit_ids.size()
	var round_before: int = flow.match_state.current_round_number
	var settlement_id: StringName = flow.round_state.settlement_commit_id
	var reward_count: int = flow.loot_session.reward_history.size()
	var characters_before: Dictionary = _character_map(flow)
	var expected_management: Dictionary = _management_player_snapshots(flow)
	var committed: Dictionary = flow.commit_round_end(COMMIT_ID)
	_add(rows, "PF-M4 Continue commits actual Round End", bool(committed.get("success", false)))
	_add(rows, "PF-M4 Match reaches next-case-required state", flow.match_state.match_completion_state == &"NEXT_CASE_REQUIRED")
	_add(rows, "PF-M4 Match returns to pre-Case Round Start", flow.match_state.current_phase == MVP_ENUMS.Phase.ROUND_START)
	_add(rows, "PF-M4 next round number advances exactly once", flow.match_state.current_round_number == round_before + 1)
	_add(rows, "PF-M4 Round End adds exactly one commit", flow.match_state.applied_commit_ids.size() == commits_before + 1 and flow.match_state.applied_commit_ids.has(COMMIT_ID))
	_add(rows, "PF-M4 active Round clears", bool(flow.round_end_summary.get("active_round_cleared", false)))
	_add(rows, "PF-M4 persistent merge uses player_id", _persistent_merge_matches(flow, expected_management))
	_add(rows, "PF-M4 Equipment mutations persist", _equipment_merge_matches(flow, expected_management))
	_add(rows, "PF-M4 Character assignments persist", _character_map(flow) == characters_before)
	_add(rows, "PF-M4 Character Selection remains complete", flow.match_state.character_selection_complete)
	_add(rows, "PF-M4 Settlement is not reapplied", flow.match_state.applied_commit_ids.has(settlement_id) and flow.round_state.settlement_commit_id == settlement_id)
	_add(rows, "PF-M4 Loot rewards are not reapplied", flow.loot_session.reward_history.size() == reward_count)
	_add(rows, "PF-M4 completed Round records its commit", flow.round_state.round_end_commit_id == COMMIT_ID)
	_add(rows, "PF-M4 completed Round records transient clear", bool(flow.round_state.round_completion_flags.get("active_round_cleared", false)))
	var snapshot_after: Dictionary = flow.match_state.to_dict()
	var duplicate: Dictionary = flow.commit_round_end(COMMIT_ID)
	_add(rows, "PF-M4 duplicate Continue is structured safe", not bool(duplicate.get("success", true)) and bool(duplicate.get("duplicate_noop", false)))
	_add(rows, "PF-M4 duplicate Continue does not mutate Match", flow.match_state.to_dict() == snapshot_after)
	_add(rows, "PF-M4 post-Round-End checkpoint round-trips", bool(flow.checkpoints.get("post_round_end", {}).get("matches", false)))


func _test_next_case_endpoint(rows: Array[Dictionary]) -> void:
	var context: Dictionary = _management_ready_context()
	var setup: SETUP_SESSION = context.setup
	var flow: ROUND_FLOW = context.flow
	setup.open_round_summary()
	flow.commit_round_end(COMMIT_ID)
	var presented: Dictionary = setup.mark_next_case_required()
	_add(rows, "PF-M4 presents next Case Selection", bool(presented.get("success", false)) and setup.phase == SETUP_SESSION.Phase.NEXT_CASE_SELECTION)
	_add(rows, "PF-M4 next Case card remains authored presentation", not setup.case_presentation().is_empty())
	_add(rows, "PF-M4 does not repeat Player Count", setup.phase != SETUP_SESSION.Phase.PLAYER_COUNT)
	_add(rows, "PF-M4 does not repeat Character Selection", setup.phase != SETUP_SESSION.Phase.CHARACTER_SELECTION and setup.selection_published())
	_add(rows, "PF-M4 does not auto-start next Case", flow.match_state.current_phase == MVP_ENUMS.Phase.ROUND_START and flow.match_state.current_round_number == 2)
	_add(rows, "PF-M4 does not initialize next Loot", flow.loot_session.round_id == &"player_facing_round_001" and flow.round_state.round_number == 1)
	_add(rows, "PF-M4 does not enter Match Complete", flow.match_state.current_phase != MVP_ENUMS.Phase.MATCH_COMPLETE and flow.match_state.match_completion_state == &"NEXT_CASE_REQUIRED")
	_add(rows, "PF-M4 has no winner or Ending screen", not _scene_has("MatchEnding") and not _scene_has("WinnerPanel"))
	_add(rows, "PF-M4 next Case screen is player-facing", _scene_has("NextCasePanel"))
	_add(rows, "PF-M4 DebugHome remains reachable", AppFlow.DEBUG_HOME_SCENE == DEBUG_SCENE and AppFlow.has_method("go_to_debug_home"))
	var duplicate: Dictionary = setup.mark_next_case_required()
	_add(rows, "PF-M4 duplicate next-Case presentation is safe", not bool(duplicate.get("success", true)) and bool(duplicate.get("duplicate_noop", false)))


func _management_ready_context() -> Dictionary:
	var setup: SETUP_SESSION = _committed_setup()
	var flow: ROUND_FLOW = ROUND_FLOW.new()
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
	return {"setup": setup, "flow": flow}


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


func _complete_loot(flow: ROUND_FLOW) -> void:
	var guard := 0
	while flow.loot_session.phase != LOOT_SESSION.Phase.LOOT_END_CONFIRMATION_READY and guard < 100:
		guard += 1
		if flow.loot_session.phase == LOOT_SESSION.Phase.ITEM_WINDOW:
			flow.continue_without_item()
		elif flow.loot_session.phase == LOOT_SESSION.Phase.MOVEMENT:
			flow.move()
		elif flow.loot_session.phase == LOOT_SESSION.Phase.BAG_OVERFLOW_PENDING:
			flow.resolve_overflow_skip()
		else:
			break


func _summary_ids_match(flow: ROUND_FLOW, rows: Array[Dictionary]) -> bool:
	for row: Dictionary in rows:
		if flow.match_state.find_player(StringName(row.get("player_id", ""))) == null:
			return false
	return rows.size() == flow.match_state.players.size()


func _summary_characters_match(
	setup: SETUP_SESSION, flow: ROUND_FLOW, rows: Array[Dictionary]
) -> bool:
	for row: Dictionary in rows:
		var player = flow.match_state.find_player(StringName(row.get("player_id", "")))
		var character = setup.find_character(player.character_id) if player != null else null
		var view: Dictionary = setup.character_presentation(character)
		if String(row.get("character_name", "")) != String(view.get("name", "")):
			return false
	return true


func _summary_numeric_matches(
	flow: ROUND_FLOW, rows: Array[Dictionary], row_field: String, player_field: String
) -> bool:
	for row: Dictionary in rows:
		var player = flow.match_state.find_player(StringName(row.get("player_id", "")))
		if player == null or row.get(row_field) != player.get(player_field):
			return false
	return true


func _summary_management_matches(
	flow: ROUND_FLOW, rows: Array[Dictionary], row_field: String, player_field: String
) -> bool:
	for row: Dictionary in rows:
		var player = flow.equipment_session.find_player(StringName(row.get("player_id", "")))
		if player == null or row.get(row_field) != player.get(player_field):
			return false
	return true


func _summary_equipment_matches(flow: ROUND_FLOW, rows: Array[Dictionary]) -> bool:
	for row: Dictionary in rows:
		var player = flow.equipment_session.find_player(StringName(row.get("player_id", "")))
		if player == null or int(row.get("equipment_count", -1)) != player.equipment_collection.size():
			return false
	return true


func _management_player_snapshots(flow: ROUND_FLOW) -> Dictionary:
	var result: Dictionary = {}
	for player in flow.equipment_session.players:
		result[String(player.player_id)] = player.to_dict()
	return result


func _persistent_merge_matches(flow: ROUND_FLOW, expected: Dictionary) -> bool:
	for player in flow.match_state.players:
		var source_value: Variant = expected.get(String(player.player_id), {})
		if not source_value is Dictionary:
			return false
		var source: Dictionary = source_value
		for field: String in ["orb_count", "gacha_ticket_count", "silver_coin_count", "equipment_exp_material_count", "equipment_exchange_material_count", "consumable_inventory", "gacha_state"]:
			if player.to_dict().get(field) != source.get(field):
				return false
	return true


func _equipment_merge_matches(flow: ROUND_FLOW, expected: Dictionary) -> bool:
	for player in flow.match_state.players:
		var source_value: Variant = expected.get(String(player.player_id), {})
		if not source_value is Dictionary:
			return false
		var source: Dictionary = source_value
		for field: String in ["equipment_collection", "relic_instance_id", "stigmata_a_instance_id", "stigmata_b_instance_id", "stigmata_c_instance_id"]:
			if player.to_dict().get(field) != source.get(field):
				return false
	return true


func _character_map(flow: ROUND_FLOW) -> Dictionary:
	var result: Dictionary = {}
	for player in flow.match_state.players:
		result[String(player.player_id)] = String(player.character_id)
	return result


func _scene_has(name: String) -> bool:
	var packed: PackedScene = load(PLAYER_SCENE) as PackedScene
	var root: Node = packed.instantiate() if packed != null else null
	var found: bool = root != null and root.find_child(name, true, false) != null
	if root != null:
		root.free()
	return found


func _scene_button_enabled(name: String) -> bool:
	var packed: PackedScene = load(PLAYER_SCENE) as PackedScene
	var root: Node = packed.instantiate() if packed != null else null
	var button: Button = root.find_child(name, true, false) as Button if root != null else null
	var enabled: bool = button != null and not button.disabled
	if root != null:
		root.free()
	return enabled


func _player_copy_is_clean() -> bool:
	var source: String = FileAccess.get_file_as_string(PLAYER_SCENE)
	for line: String in source.split("\n"):
		if not line.begins_with("text = ") and not line.begins_with("tooltip_text = "):
			continue
		var lowered: String = line.to_lower()
		for forbidden: String in ["test_only", "fixture", "gd3", "pf-m4", "commit", "next_case_required", "match_complete"]:
			if lowered.contains(forbidden):
				return false
	return true


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({"name": name, "passed": passed, "detail": "PF-M4 player-facing Round completion invariant"})
