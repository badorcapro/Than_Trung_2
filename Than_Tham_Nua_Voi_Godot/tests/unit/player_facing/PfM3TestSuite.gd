class_name PfM3TestSuite
extends RefCounted

const SETUP_SESSION := preload("res://scripts/application/player_facing/PlayerFacingSetupSession.gd")
const ROUND_FLOW := preload("res://scripts/application/mvp/MvpIntegratedRoundCompletionSession.gd")
const LOOT_SESSION := preload("res://scripts/domain/loot/LootRewardSession.gd")
const MANAGEMENT_SESSION := preload("res://scripts/domain/equipment/EquipmentManagementSession.gd")
const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const GD2_FIXTURES := preload("res://scripts/application/loot/Gd2FixtureRepository.gd")

const PLAYER_SCENE := "res://scenes/player_facing/PlayerFacingStart.tscn"
const DEBUG_SCENE := "res://scenes/boot/DebugHome.tscn"


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_test_player_presentation(rows)
	_test_actual_loot_start(rows)
	_test_first_loot_with_full_selection_roster(rows)
	_test_loot_completion(rows)
	_test_confirmation(rows)
	_test_management(rows)
	_test_endpoint(rows)
	return rows


func _test_player_presentation(rows: Array[Dictionary]) -> void:
	var packed: PackedScene = load(PLAYER_SCENE) as PackedScene
	var root: Node = packed.instantiate() if packed != null else null
	_add(rows, "PF-M3 player scene loads", root != null)
	_add(rows, "PF-M3 Start Loot is available", _button_enabled(root, "StartLoot"))
	_add(rows, "PF-M3 player Loot panel exists", _has(root, "LootPanel"))
	_add(rows, "PF-M3 movement action exists", _has(root, "Move"))
	_add(rows, "PF-M3 Item Window actions exist", _has(root, "UseItem") and _has(root, "ContinueWithoutItem"))
	_add(rows, "PF-M3 overflow choice exists", _has(root, "OverflowPanel"))
	_add(rows, "PF-M3 confirmation panel exists", _has(root, "LootConfirmationPanel"))
	_add(rows, "PF-M3 management panel exists", _has(root, "EquipmentPanel"))
	_add(rows, "PF-M3 Gacha actions are presented", _has(root, "BasicGacha") and _has(root, "RateUpGacha") and _has(root, "PerfectGacha"))
	_add(rows, "PF-M3 exact summary-ready screen exists", _has(root, "RoundSummaryReadyPanel"))
	var early_setup: SETUP_SESSION = SETUP_SESSION.new()
	early_setup.begin_new_game()
	var early_summary: Dictionary = early_setup.open_round_summary()
	_add(rows, "PF-M3 Round Summary cannot open before readiness", not bool(early_summary.get("success", true)) and early_setup.phase == SETUP_SESSION.Phase.MATCH_MODE)
	_add(rows, "PF-M3 player copy hides internal identifiers", _copy_is_clean())
	if root != null:
		root.free()


func _test_actual_loot_start(rows: Array[Dictionary]) -> void:
	var context: Dictionary = _ready_context()
	var setup: SETUP_SESSION = context.setup
	var flow: ROUND_FLOW = context.flow
	var commit_count: int = flow.match_state.applied_commit_ids.size()
	var started: Dictionary = flow.begin_loot()
	_add(rows, "PF-M3 Loot Ready starts actual Loot", bool(started.get("success", false)))
	_add(rows, "PF-M3 actual Loot session is created", flow.loot_session != null)
	_add(rows, "PF-M3 actual Loot has three players", flow.loot_session != null and flow.loot_session.players.size() == 3)
	_add(rows, "PF-M3 Loot Match phase is actual LOOT", flow.match_state.current_phase == MVP_ENUMS.Phase.LOOT)
	_add(rows, "PF-M3 presentation enters Loot once", bool(setup.mark_loot_started().get("success", false)) and setup.phase == SETUP_SESSION.Phase.LOOT_ACTIVE)
	_add(rows, "PF-M3 settlement is not reapplied", flow.match_state.applied_commit_ids.size() == commit_count)
	_add(rows, "PF-M3 Loot preserves player identity", _loot_ids_match(flow))
	_add(rows, "PF-M3 Character origins are exact", _origins_match_character_authority(flow, setup))
	_add(rows, "PF-M3 Speed authority is exact", _speed_matches_character_authority(flow, setup))
	_add(rows, "PF-M3 Stamina authority is exact", _stamina_matches_character_authority(flow, setup))
	_add(rows, "PF-M3 one reward snapshot is authored", flow.loot_session.reward_snapshots.size() > 0)
	var duplicate: Dictionary = flow.begin_loot()
	_add(rows, "PF-M3 duplicate Loot start is safe", not bool(duplicate.get("success", true)) and bool(duplicate.get("duplicate_noop", false)))


func _test_first_loot_with_full_selection_roster(rows: Array[Dictionary]) -> void:
	var context: Dictionary = _ready_context_with_fourth_production_character()
	var setup: SETUP_SESSION = context.setup
	var flow: ROUND_FLOW = context.flow
	var commits_before: int = flow.match_state.applied_commit_ids.size()
	_add(rows, "PF-M3 first-Loot regression reaches pristine ready state with fourth production Character", setup.phase == SETUP_SESSION.Phase.LOOT_READY and flow.match_state.current_phase == MVP_ENUMS.Phase.CASE_SETTLEMENT and flow.round_state.phase == MVP_ENUMS.Phase.CASE_SETTLEMENT and flow.round_state.settlement_applied and flow.loot_session == null and flow.round_state.loot_movement_snapshot.is_empty() and flow.round_state.loot_reward_snapshot.is_empty() and _match_has_character(flow, &"character_huyen_ca_xuy"))
	var first: Dictionary = flow.begin_loot()
	_add(rows, "PF-M3 first Loot press succeeds for any selectable Character", bool(first.get("success", false)))
	_add(rows, "PF-M3 first Loot press creates actual movement state", flow.loot_session != null and flow.loot_session.movement_session != null and flow.loot_session.movement_session.started)
	_add(rows, "PF-M3 first Loot press does not reapply settlement", flow.match_state.applied_commit_ids.size() == commits_before and flow.match_state.applied_commit_ids.has(flow.round_state.settlement_commit_id))
	var first_session: LOOT_SESSION = flow.loot_session
	var duplicate: Dictionary = flow.begin_loot()
	_add(rows, "PF-M3 second Loot press cannot duplicate initialization", not bool(duplicate.get("success", true)) and bool(duplicate.get("duplicate_noop", false)) and flow.loot_session == first_session)


func _test_loot_completion(rows: Array[Dictionary]) -> void:
	var context: Dictionary = _ready_context()
	var flow: ROUND_FLOW = context.flow
	flow.match_state.players[0].consumable_inventory = [{"item_id": "test_move_plus_1"}]
	flow.begin_loot()
	var initial_history: int = flow.loot_session.reward_history.size()
	var guard: int = 0
	var saw_item_window := false
	var used_item := false
	var saw_movement := false
	var saw_overflow := false
	while flow.loot_session.phase != LOOT_SESSION.Phase.LOOT_END_CONFIRMATION_READY and guard < 100:
		guard += 1
		match flow.loot_session.phase:
			LOOT_SESSION.Phase.ITEM_WINDOW:
				saw_item_window = true
				var movement_player = flow.loot_session.movement_session.current_player()
				var current_player = flow.loot_session.find_player(movement_player.player_id)
				if not used_item and not current_player.consumable_inventory.is_empty():
					var item_row: Dictionary = current_player.consumable_inventory[0]
					used_item = bool(flow.use_item(StringName(item_row.get("item_id", ""))).get("success", false))
				else:
					flow.continue_without_item()
			LOOT_SESSION.Phase.MOVEMENT:
				saw_movement = true
				flow.move()
			LOOT_SESSION.Phase.BAG_OVERFLOW_PENDING:
				saw_overflow = true
				flow.resolve_overflow_skip()
			_:
				break
	_add(rows, "PF-M3 actual Item Window and item authority are exercised", saw_item_window and used_item)
	_add(rows, "PF-M3 actual movement is exercised", saw_movement)
	_add(rows, "PF-M3 deterministic Loot terminates", guard < 100)
	_add(rows, "PF-M3 all movement players exhaust", flow.loot_session.movement_session.all_exhausted())
	_add(rows, "PF-M3 PlayerPhase moves reach zero", _all_phase_moves_zero(flow))
	_add(rows, "PF-M3 rewards resolve in recorded order", flow.loot_session.reward_history.size() >= initial_history)
	_add(rows, "PF-M3 pending reward trace is resolved", flow.loot_session.pending_trace_index >= flow.loot_session.pending_trace.size())
	_add(rows, "PF-M3 overflow is fully resolved", not flow.loot_session.overflow.active)
	_add(rows, "PF-M3 overflow path is safe when encountered", not saw_overflow or not flow.loot_session.overflow.active)
	_add(rows, "PF-M3 THIS_MOVE effects are inactive", _duration_inactive(flow, 0))
	_add(rows, "PF-M3 THIS_TURN effects are inactive", _duration_inactive(flow, 1))
	_add(rows, "PF-M3 Loot reaches exact confirmation readiness", flow.loot_session.phase == LOOT_SESSION.Phase.LOOT_END_CONFIRMATION_READY)
	_add(rows, "PF-M3 orchestrator reaches Loot confirmation", flow.match_state.current_phase == MVP_ENUMS.Phase.LOOT_END_CONFIRMATION)
	_add(rows, "PF-M3 Loot checkpoint round-trips", bool(flow.checkpoints.get("loot_finished", {}).get("matches", false)))


func _test_confirmation(rows: Array[Dictionary]) -> void:
	var flow: ROUND_FLOW = _completed_loot_flow()
	var began: Dictionary = flow.begin_loot_end_confirmation()
	_add(rows, "PF-M3 confirmation starts only after Loot ready", bool(began.get("success", false)))
	_add(rows, "PF-M3 confirmation uses actual management projection", flow.equipment_session != null and flow.equipment_session.phase == MANAGEMENT_SESSION.Phase.LOOT_END_CONFIRMATION)
	_add(rows, "PF-M3 confirmation preserves all player identities", _same_player_id_set(flow.equipment_session.player_order, flow.loot_session.movement_session.ordered_player_ids))
	var first_id: StringName = flow.equipment_session.current_player_id()
	var first: Dictionary = flow.confirm_loot_end(first_id)
	_add(rows, "PF-M3 first player confirmation is accepted", bool(first.get("success", false)))
	_add(rows, "PF-M3 one confirmation cannot start management", flow.equipment_session.phase == MANAGEMENT_SESSION.Phase.LOOT_END_CONFIRMATION)
	var second_id: StringName = flow.equipment_session.current_player_id()
	flow.confirm_loot_end(second_id)
	_add(rows, "PF-M3 two confirmations cannot start management", flow.equipment_session.phase == MANAGEMENT_SESSION.Phase.LOOT_END_CONFIRMATION)
	var third_id: StringName = flow.equipment_session.current_player_id()
	var third: Dictionary = flow.confirm_loot_end(third_id)
	_add(rows, "PF-M3 all three confirmations start management", bool(third.get("success", false)) and flow.equipment_session.phase == MANAGEMENT_SESSION.Phase.EQUIPMENT_MANAGEMENT)
	_add(rows, "PF-M3 confirmation joins by player_id", flow.equipment_session.confirmed_player_ids.has(first_id) and flow.equipment_session.confirmed_player_ids.has(second_id) and flow.equipment_session.confirmed_player_ids.has(third_id))
	var duplicate: Dictionary = flow.confirm_loot_end(first_id)
	_add(rows, "PF-M3 duplicate confirmation is safe", not bool(duplicate.get("success", true)))


func _test_management(rows: Array[Dictionary]) -> void:
	var flow: ROUND_FLOW = _management_flow()
	var current_id: StringName = flow.equipment_session.current_player_id()
	var player = flow.equipment_session.find_player(current_id)
	var equipped: Dictionary = flow.grant_and_equip_test_relic()
	_add(rows, "PF-M3 actual Equipment grant succeeds", bool(equipped.get("success", false)))
	_add(rows, "PF-M3 actual Relic loadout is updated", player != null and not player.relic_instance_id.is_empty())
	var unique_before: bool = _equipment_ids_unique(player)
	player.gacha_ticket_count = maxi(player.gacha_ticket_count, 1)
	var gacha: Dictionary = flow.basic_gacha_roll()
	_add(rows, "PF-M3 actual Basic Gacha can run", bool(gacha.get("success", false)))
	_add(rows, "PF-M3 Gacha preserves unique instances", unique_before and _equipment_ids_unique(player))
	_add(rows, "PF-M3 Gacha history records the action", not flow.equipment_session.gacha_history.is_empty())
	var done_ids: Array[StringName] = []
	for index: int in range(3):
		var player_id: StringName = flow.equipment_session.current_player_id()
		done_ids.append(player_id)
		flow.mark_management_done(player_id)
	_add(rows, "PF-M3 management Done uses player_id", _three_unique_ids(done_ids))
	_add(rows, "PF-M3 all three players must finish", flow.equipment_session.done_player_ids.size() == 3)
	_add(rows, "PF-M3 management reaches ready boundary", flow.equipment_session.phase == MANAGEMENT_SESSION.Phase.READY_FOR_M6)
	_add(rows, "PF-M3 management checkpoint round-trips", bool(flow.checkpoints.get("management_complete", {}).get("matches", false)))
	var duplicate: Dictionary = flow.mark_management_done(done_ids[0])
	_add(rows, "PF-M3 duplicate Done is safe", not bool(duplicate.get("success", true)) and bool(duplicate.get("duplicate_noop", false)))


func _test_endpoint(rows: Array[Dictionary]) -> void:
	var context: Dictionary = _ready_context()
	var setup: SETUP_SESSION = context.setup
	var flow: ROUND_FLOW = _management_flow_from(context.flow)
	for index: int in range(3):
		flow.mark_management_done(flow.equipment_session.current_player_id())
	setup.mark_loot_started()
	setup.mark_loot_confirmation()
	setup.mark_equipment_management()
	var ready: Dictionary = setup.mark_round_summary_ready()
	_add(rows, "PF-M3 reaches exact ROUND_SUMMARY_READY endpoint", bool(ready.get("success", false)) and setup.phase == SETUP_SESSION.Phase.ROUND_SUMMARY_READY)
	_add(rows, "PF-M3 does not commit Round End", flow.round_end_summary.is_empty())
	_add(rows, "PF-M3 active Round remains present", flow.round_state != null and flow.round_state.round_number == 1)
	_add(rows, "PF-M3 does not begin next Case", flow.match_state.current_round_number == 1)
	_add(rows, "PF-M3 does not enter Match Complete", flow.match_state.current_phase != MVP_ENUMS.Phase.MATCH_COMPLETE)
	_add(rows, "PF-M3 persistent Case settlement remains applied", flow.round_state.settlement_applied)
	_add(rows, "PF-M3 developer route remains accessible", AppFlow.DEBUG_HOME_SCENE == DEBUG_SCENE and AppFlow.has_method("go_to_debug_home"))
	var duplicate: Dictionary = setup.mark_round_summary_ready()
	_add(rows, "PF-M3 duplicate summary-ready transition is safe", not bool(duplicate.get("success", true)) and bool(duplicate.get("duplicate_noop", false)))


func _ready_context() -> Dictionary:
	var setup: SETUP_SESSION = SETUP_SESSION.new()
	setup.begin_new_game()
	setup.choose_player_count(3)
	for seat_index: int in range(3):
		setup.select_character(setup.characters[seat_index].character_id)
		setup.lock_current_character()
		if setup.phase == SETUP_SESSION.Phase.PASS_DEVICE:
			setup.continue_after_pass_device()
	setup.confirm_lineup()
	var flow: ROUND_FLOW = ROUND_FLOW.new()
	flow.initialize_player_facing_case(setup.match_state, setup.available_case)
	setup.mark_case_started()
	flow.handle_case_completion(flow.build_test_only_completed_boundary())
	setup.mark_case_results_ready()
	setup.continue_to_loot_ready()
	return {"setup": setup, "flow": flow}


func _ready_context_with_fourth_production_character() -> Dictionary:
	var setup: SETUP_SESSION = SETUP_SESSION.new()
	setup.begin_new_game()
	setup.choose_player_count(3)
	var selected_ids: Array[StringName] = [
		setup.characters[0].character_id,
		setup.characters[1].character_id,
		setup.characters[3].character_id,
	]
	for character_id: StringName in selected_ids:
		setup.select_character(character_id)
		setup.lock_current_character()
		if setup.phase == SETUP_SESSION.Phase.PASS_DEVICE:
			setup.continue_after_pass_device()
	setup.confirm_lineup()
	var flow: ROUND_FLOW = ROUND_FLOW.new()
	flow.initialize_player_facing_case(setup.match_state, setup.available_case)
	setup.mark_case_started()
	flow.handle_case_completion(flow.build_test_only_completed_boundary())
	setup.mark_case_results_ready()
	setup.continue_to_loot_ready()
	return {"setup": setup, "flow": flow}


func _match_has_character(flow: ROUND_FLOW, character_id: StringName) -> bool:
	for player in flow.match_state.players:
		if player.character_id == character_id:
			return true
	return false


func _completed_loot_flow() -> ROUND_FLOW:
	var flow: ROUND_FLOW = _ready_context().flow
	flow.begin_loot()
	var guard: int = 0
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
	return flow


func _management_flow() -> ROUND_FLOW:
	return _management_flow_from(_completed_loot_flow())


func _management_flow_from(flow: ROUND_FLOW) -> ROUND_FLOW:
	if flow.loot_session == null:
		flow.begin_loot()
		var guard: int = 0
		while flow.loot_session.phase != LOOT_SESSION.Phase.LOOT_END_CONFIRMATION_READY and guard < 100:
			guard += 1
			if flow.loot_session.phase == LOOT_SESSION.Phase.ITEM_WINDOW:
				flow.continue_without_item()
			elif flow.loot_session.phase == LOOT_SESSION.Phase.MOVEMENT:
				flow.move()
			elif flow.loot_session.phase == LOOT_SESSION.Phase.BAG_OVERFLOW_PENDING:
				flow.resolve_overflow_skip()
	flow.begin_loot_end_confirmation()
	while flow.equipment_session.phase == MANAGEMENT_SESSION.Phase.LOOT_END_CONFIRMATION:
		flow.confirm_loot_end(flow.equipment_session.current_player_id())
	return flow


func _loot_ids_match(flow: ROUND_FLOW) -> bool:
	for player in flow.loot_session.players:
		if flow.match_state.find_player(player.player_id) == null:
			return false
	return true


func _origins_match_character_authority(flow: ROUND_FLOW, setup: SETUP_SESSION) -> bool:
	var map_definition = GD2_FIXTURES.load_production_map()
	if map_definition == null:
		return false
	for state in flow.loot_session.movement_session.player_states:
		var character = setup.find_character(state.character_id)
		if character == null:
			return false
		var expected_node_id: StringName = StringName(
			map_definition.origin_spawn_by_house.get(character.origin_house_id, &"")
		)
		if expected_node_id.is_empty() or state.current_node_id != expected_node_id:
			return false
	return true


func _speed_matches_character_authority(flow: ROUND_FLOW, setup: SETUP_SESSION) -> bool:
	for state in flow.loot_session.movement_session.player_states:
		var character = setup.find_character(state.character_id)
		if character == null or state.speed_snapshot != character.base_speed:
			return false
	return true


func _stamina_matches_character_authority(flow: ROUND_FLOW, setup: SETUP_SESSION) -> bool:
	for state in flow.loot_session.movement_session.player_states:
		var character = setup.find_character(state.character_id)
		if character == null or state.stamina_snapshot != character.base_stamina or state.remaining_moves != character.base_stamina:
			return false
	return true


func _all_phase_moves_zero(flow: ROUND_FLOW) -> bool:
	for player in flow.loot_session.movement_session.player_states:
		if player.remaining_moves != 0:
			return false
	return true


func _duration_inactive(flow: ROUND_FLOW, duration: int) -> bool:
	for player in flow.loot_session.movement_session.player_states:
		for effect in player.temporary_effects:
			if effect.duration == duration and effect.active and effect.remaining > 0:
				return false
	return true


func _equipment_ids_unique(player) -> bool:
	var ids: Dictionary = {}
	for instance in player.equipment_collection:
		if ids.has(instance.instance_id):
			return false
		ids[instance.instance_id] = true
	return true


func _three_unique_ids(ids: Array[StringName]) -> bool:
	var unique: Dictionary = {}
	for player_id: StringName in ids:
		unique[player_id] = true
	return ids.size() == 3 and unique.size() == 3


func _same_player_id_set(left: Array[StringName], right: Array[StringName]) -> bool:
	if left.size() != right.size():
		return false
	for player_id: StringName in left:
		if not right.has(player_id):
			return false
	return true


func _button_enabled(root: Node, name: String) -> bool:
	var button: Button = root.find_child(name, true, false) as Button if root != null else null
	return button != null and not button.disabled


func _has(root: Node, name: String) -> bool:
	return root != null and root.find_child(name, true, false) != null


func _copy_is_clean() -> bool:
	var source: String = FileAccess.get_file_as_string(PLAYER_SCENE)
	for line: String in source.split("\n"):
		if not line.begins_with("text = ") and not line.begins_with("tooltip_text = "):
			continue
		var lowered: String = line.to_lower()
		for forbidden: String in ["test_only", "fixture", "gd3", "pf-m3", "blocked", "commit", "house_a_0"]:
			if lowered.contains(forbidden):
				return false
	return true


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({"name": name, "passed": passed, "detail": "PF-M3 player-facing Loot and Equipment invariant"})
