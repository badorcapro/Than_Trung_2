class_name PfM5TestSuite
extends RefCounted

const SETUP_SESSION := preload(
	"res://scripts/application/player_facing/PlayerFacingSetupSession.gd"
)
const ROUND_FLOW := preload(
	"res://scripts/application/mvp/MvpIntegratedRoundCompletionSession.gd"
)
const LOOT_MAP_VIEW := preload(
	"res://scripts/presentation/player_facing/PlayerFacingLootMapView.gd"
)
const LOOT_SESSION := preload("res://scripts/domain/loot/LootRewardSession.gd")

const PLAYER_SCENE := "res://scenes/player_facing/PlayerFacingStart.tscn"
const MAP_VIEW_SOURCE := (
	"res://scripts/presentation/player_facing/PlayerFacingLootMapView.gd"
)
const DEBUG_SCENE := "res://scenes/boot/DebugHome.tscn"


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_test_scene_structure(rows)
	_test_actual_map_binding(rows)
	_test_tokens_and_movement_feedback(rows)
	_test_player_information_contract(rows)
	return rows


func _test_scene_structure(rows: Array[Dictionary]) -> void:
	var packed: PackedScene = load(PLAYER_SCENE) as PackedScene
	var root: Node = packed.instantiate() if packed != null else null
	_add(rows, "PF-M5 visual Loot map exists", _has(root, "LootMapView"))
	_add(rows, "PF-M5 active-turn panel exists", _has(root, "ActiveTurnLabel"))
	_add(rows, "PF-M5 action guidance exists", _has(root, "ActionGuide"))
	_add(rows, "PF-M5 resource summary exists", _has(root, "ResourceSummary"))
	_add(rows, "PF-M5 Bag summary exists", _has(root, "BagSummary"))
	_add(rows, "PF-M5 activity log exists", _has(root, "ActivityLog"))
	_add(rows, "PF-M5 overflow presentation remains available", _has(root, "OverflowPanel"))
	_add(rows, "PF-M5 primary movement action is player-facing", _button_text(root, "Move") == "Roll & Di chuyển")
	_add(rows, "PF-M5 map layout fits target structure", _map_has_functional_size(root))
	_add(rows, "PF-M5 player-facing copy hides raw Loot identifiers", _visible_copy_is_clean())
	if root != null:
		root.free()


func _test_actual_map_binding(rows: Array[Dictionary]) -> void:
	var context: Dictionary = _loot_context()
	var flow: ROUND_FLOW = context.flow
	var map_definition: LootMapDefinition = flow.loot_map_definition()
	var view: LOOT_MAP_VIEW = LOOT_MAP_VIEW.new()
	view.size = Vector2(700.0, 390.0)
	view.configure(map_definition, flow.loot_session.movement_session)
	var snapshot: Dictionary = view.presentation_snapshot()
	_add(rows, "PF-M5 map uses actual Loot authority", map_definition != null and map_definition.map_id == flow.loot_session.map_id)
	_add(rows, "PF-M5 all authored nodes are represented", int(snapshot.get("node_count", -1)) == map_definition.nodes.size())
	_add(rows, "PF-M5 actual topology connections are represented", int(snapshot.get("connection_count", -1)) == _authored_connection_count(map_definition))
	_add(rows, "PF-M5 every node receives a player-facing label", _labels_cover_map(snapshot, map_definition))
	_add(rows, "PF-M5 labels never expose raw node IDs", _labels_hide_ids(snapshot, map_definition))
	_add(rows, "PF-M5 House, hub, and royal purposes are distinguishable", _labels_include_purposes(snapshot, map_definition))
	_add(rows, "PF-M5 view contains no gameplay movement authority", _map_view_is_presentation_only())
	view.free()


func _test_tokens_and_movement_feedback(rows: Array[Dictionary]) -> void:
	var context: Dictionary = _loot_context()
	var flow: ROUND_FLOW = context.flow
	var view: LOOT_MAP_VIEW = LOOT_MAP_VIEW.new()
	view.size = Vector2(700.0, 390.0)
	view.configure(flow.loot_map_definition(), flow.loot_session.movement_session)
	var before: Dictionary = view.presentation_snapshot()
	var before_tokens_value: Variant = before.get("token_nodes", {})
	var before_token_count: int = before_tokens_value.size() if before_tokens_value is Dictionary else 0
	_add(rows, "PF-M5 all three player tokens are represented", before_token_count == 3)
	_add(rows, "PF-M5 tokens match authoritative current nodes", _tokens_match_session(before, flow))
	_add(rows, "PF-M5 active player is identified from turn authority", String(before.get("active_player_id", "")) == String(flow.loot_session.movement_session.current_player().player_id))
	var moving_player_id: StringName = flow.loot_session.movement_session.current_player().player_id
	var node_before: StringName = flow.loot_session.movement_session.current_player().current_node_id
	flow.continue_without_item()
	var moved: Dictionary = flow.move()
	view.configure(flow.loot_map_definition(), flow.loot_session.movement_session)
	var after: Dictionary = view.presentation_snapshot()
	var token_nodes_value: Variant = after.get("token_nodes", {})
	var token_nodes: Dictionary = token_nodes_value if token_nodes_value is Dictionary else {}
	_add(rows, "PF-M5 actual movement remains authoritative", bool(moved.get("success", false)))
	_add(rows, "PF-M5 token position updates after movement", StringName(token_nodes.get(moving_player_id, &"")) != node_before)
	_add(rows, "PF-M5 moved token matches movement state", StringName(token_nodes.get(moving_player_id, &"")) == _movement_node(flow, moving_player_id))
	var path_value: Variant = after.get("highlighted_path", [])
	_add(rows, "PF-M5 latest traversed path is highlighted", path_value is Array and path_value.size() >= 2)
	_add(rows, "PF-M5 turn indication updates from current player", String(after.get("active_player_id", "")) == String(flow.loot_session.movement_session.current_player().player_id))
	view.free()


func _test_player_information_contract(rows: Array[Dictionary]) -> void:
	var context: Dictionary = _loot_context()
	var setup: SETUP_SESSION = context.setup
	var flow: ROUND_FLOW = context.flow
	var movement_player: LootMovementPlayerState = flow.loot_session.movement_session.current_player()
	var player: PlayerPhaseState = flow.loot_session.find_player(movement_player.player_id)
	var character: CharacterDefinition = setup.find_character(player.character_id)
	var round_loot: RoundLootInventoryState = flow.loot_session.find_round_loot_state(
		player.player_id
	)
	_add(rows, "PF-M5 current-player Speed uses Character authority", movement_player.speed_snapshot == character.base_speed)
	_add(rows, "PF-M5 current-player Stamina uses movement authority", movement_player.remaining_moves == character.base_stamina)
	_add(rows, "PF-M5 Bag usage uses round map-loot authority", round_loot != null and round_loot.carried_items.is_empty() and round_loot.capacity == character.base_bag_level)
	_add(rows, "PF-M5 resources remain actual PlayerPhase state", player.merit_progress == flow.match_state.find_player(player.player_id).merit_progress and player.orb_count == flow.match_state.find_player(player.player_id).orb_count)
	_add(rows, "PF-M5 overflow UI is conditional on authority", not flow.loot_session.overflow.active and _scene_node_hidden("OverflowPanel"))
	_add(rows, "PF-M5 Loot End Confirmation authority remains intact", _can_reach_confirmation(flow))
	_add(rows, "PF-M5 developer route remains accessible", AppFlow.DEBUG_HOME_SCENE == DEBUG_SCENE and AppFlow.has_method("go_to_debug_home"))


func _loot_context() -> Dictionary:
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
	flow.begin_loot()
	setup.mark_loot_started()
	return {"setup": setup, "flow": flow}


func _can_reach_confirmation(flow: ROUND_FLOW) -> bool:
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
				return false
	return guard < 100 and bool(flow.begin_loot_end_confirmation().get("success", false))


func _authored_connection_count(map_definition: LootMapDefinition) -> int:
	var count: int = 0
	for node: LootNodeDefinition in map_definition.nodes:
		if node != null:
			count += node.outgoing_neighbor_ids.size()
	return count


func _labels_cover_map(snapshot: Dictionary, map_definition: LootMapDefinition) -> bool:
	var labels: Dictionary = snapshot.get("labels", {})
	for node: LootNodeDefinition in map_definition.nodes:
		if node == null or String(labels.get(node.node_id, "")).is_empty():
			return false
	return true


func _labels_hide_ids(snapshot: Dictionary, map_definition: LootMapDefinition) -> bool:
	var labels: Dictionary = snapshot.get("labels", {})
	for node: LootNodeDefinition in map_definition.nodes:
		var label: String = String(labels.get(node.node_id, ""))
		if label.to_lower().contains(String(node.node_id).to_lower()):
			return false
	return true


func _labels_include_purposes(
	snapshot: Dictionary, map_definition: LootMapDefinition
) -> bool:
	var labels_value: Variant = snapshot.get("labels", {})
	if not labels_value is Dictionary or map_definition == null:
		return false
	var labels: Dictionary = labels_value
	var house_node_id: StringName
	var central_node_id: StringName
	var royal_node_id: StringName
	for node: LootNodeDefinition in map_definition.nodes:
		if node == null:
			continue
		if house_node_id.is_empty() and node.node_kind == &"ORIGIN_SPAWN":
			house_node_id = node.node_id
		if central_node_id.is_empty() and (
			&"CENTRAL_HUB" in node.tags or &"CENTER_ENTRY" in node.tags
		):
			central_node_id = node.node_id
		if royal_node_id.is_empty() and (
			&"POST_MAUSOLEUM" in node.tags or node.node_kind == &"END"
		):
			royal_node_id = node.node_id
	var house_label := String(labels.get(house_node_id, ""))
	var central_label := String(labels.get(central_node_id, ""))
	var royal_label := String(labels.get(royal_node_id, ""))
	return (
		not house_node_id.is_empty()
		and not central_node_id.is_empty()
		and not royal_node_id.is_empty()
		and not house_label.is_empty()
		and not central_label.is_empty()
		and not royal_label.is_empty()
		and house_label != central_label
		and central_label != royal_label
		and house_label != royal_label
	)


func _tokens_match_session(snapshot: Dictionary, flow: ROUND_FLOW) -> bool:
	var token_nodes: Dictionary = snapshot.get("token_nodes", {})
	for player: LootMovementPlayerState in flow.loot_session.movement_session.player_states:
		if StringName(token_nodes.get(player.player_id, &"")) != player.current_node_id:
			return false
	return true


func _movement_node(flow: ROUND_FLOW, player_id: StringName) -> StringName:
	for player: LootMovementPlayerState in flow.loot_session.movement_session.player_states:
		if player.player_id == player_id:
			return player.current_node_id
	return &""


func _map_view_is_presentation_only() -> bool:
	var source: String = FileAccess.get_file_as_string(MAP_VIEW_SOURCE)
	return not source.contains("LootMovementService") and not source.contains("perform_movement(") and not source.contains("remaining_moves -=")


func _visible_copy_is_clean() -> bool:
	var source: String = FileAccess.get_file_as_string(PLAYER_SCENE)
	for line: String in source.split("\n"):
		if not line.begins_with("text = ") and not line.begins_with("tooltip_text = "):
			continue
		var lowered: String = line.to_lower()
		for forbidden: String in ["house_a_0", "center_0", "test_only", "fixture", "commit", "loot_active", "blocked"]:
			if lowered.contains(forbidden):
				return false
	return true


func _map_has_functional_size(root: Node) -> bool:
	var view: Control = root.find_child("LootMapView", true, false) as Control if root != null else null
	return view != null and view.custom_minimum_size.x >= 600.0 and view.custom_minimum_size.y >= 300.0


func _scene_node_hidden(name: String) -> bool:
	var packed: PackedScene = load(PLAYER_SCENE) as PackedScene
	var root: Node = packed.instantiate() if packed != null else null
	var node: CanvasItem = root.find_child(name, true, false) as CanvasItem if root != null else null
	var result: bool = node != null and not node.visible
	if root != null:
		root.free()
	return result


func _button_text(root: Node, name: String) -> String:
	var button: Button = root.find_child(name, true, false) as Button if root != null else null
	return button.text if button != null else ""


func _has(root: Node, name: String) -> bool:
	return root != null and root.find_child(name, true, false) != null


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({"name": name, "passed": passed, "detail": "PF-M5 player-facing Loot presentation invariant"})
