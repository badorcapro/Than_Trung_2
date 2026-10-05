class_name Gd2M0AProductionMapTestSuite
extends RefCounted

const HOUSE_REPOSITORY := preload(
	"res://scripts/application/houses/ProductionHouseRepository.gd"
)
const MAP_VIEW := preload(
	"res://scripts/presentation/player_facing/PlayerFacingLootMapView.gd"
)
const PREVIEW_SCENE := preload("res://scenes/loot/ProductionLootMapPreview.tscn")
const PREVIEW_CONTROLLER := preload(
	"res://scripts/presentation/loot/ProductionLootMapPreviewController.gd"
)


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var houses: Array[HouseDefinition] = HOUSE_REPOSITORY.load_all()
	var map_definition: LootMapDefinition = Gd2FixtureRepository.load_production_map()
	var house_ids: Array[StringName] = _house_ids()
	var preview_session: LootMovementSession = _preview_session(houses, map_definition)
	var view: PlayerFacingLootMapView = _view(map_definition, preview_session)
	var world_rect: Rect2 = _node_world_bounds(map_definition)

	rows.append(_row("GĐ2-M0A defines exactly five production Houses", houses.size() == 5))
	rows.append(_row("GĐ2-M0A House IDs are canonical and unique", _house_ids_match(houses)))
	rows.append(_row("GĐ2-M0A House display names are canonical", _house_names_match(houses)))
	rows.append(_row("GĐ2-M0A House display order is canonical", _house_order_matches(houses)))
	rows.append(_row("GĐ2-M0A House spatial roles are canonical", _house_spatial_roles_match(houses)))
	rows.append(_row("GĐ2-M0A production board and preview load", _production_assets_load(map_definition)))
	rows.append(_row("GĐ2-M0A production board has five distinct origins", _origins_are_distinct(map_definition, house_ids)))
	rows.append(_row("GĐ2-M0A House spawns expose exactly ten approach lanes", _house_spawn_branch_contract(map_definition, house_ids)))
	rows.append(_row("GĐ2-M0A physical House placement matches the palace reference", _physical_house_placement_matches(map_definition)))
	rows.append(_row("GĐ2-M0A ten House lanes meet only at one Central Hub", _house_routes_share_hub_without_early_merge(map_definition, house_ids)))
	rows.append(_row("GĐ2-M0A all House lanes have equal Loot opportunity", _house_route_fairness_matches(map_definition, house_ids)))
	rows.append(_row("GĐ2-M0A Central Hub exposes three separate Middle lanes", _middle_route_contract_matches(map_definition)))
	rows.append(_row("GĐ2-M0A three Middle lanes meet at one Mausoleum Hub", _middle_routes_converge_at_mausoleum(map_definition)))
	rows.append(_row("GĐ2-M0A Mausoleum Hub exposes three authoritative Final lanes", _final_route_contract_matches(map_definition)))
	rows.append(_row("GĐ2-M0A reward zones use metadata without waypoint nodes", _zone_metadata_and_no_waypoint_nodes(map_definition)))
	rows.append(_row("GĐ2-M0A private and shared node ownership is explicit", _node_ownership_is_consistent(map_definition)))
	rows.append(_row("GĐ2-M0A tabletop world exceeds one viewport", world_rect.size.x > 1280.0 and world_rect.size.y > 720.0))
	rows.append(_row("GĐ2-M0A existing movement service accepts production topology", _movement_service_accepts(houses, map_definition)))
	rows.append(_row("GĐ2-M0A five player markers resolve to board nodes", _markers_resolve(view, preview_session)))
	rows.append(_row("GĐ2-M0A camera bounds derive from authored world extents", _camera_bounds_derive(view, world_rect)))
	rows.append(_row("GĐ2-M0A wheel up zooms into the authored map", _wheel_up_zooms_in(map_definition, houses)))
	rows.append(_row("GĐ2-M0A wheel down zooms out from the authored map", _wheel_down_zooms_out(map_definition, houses)))
	rows.append(_row("GĐ2-M0A mouse-wheel zoom respects dynamic limits", _zoom_limits_hold(map_definition, houses)))
	rows.append(_row("GĐ2-M0A minimum zoom frames the complete production map", _minimum_zoom_frames_map(map_definition, houses)))
	rows.append(_row("GĐ2-M0A zoom reclamps camera to legal bounds", _zoom_reclamps_camera(map_definition, houses)))
	rows.append(_row("GĐ2-M0A left drag pans in inverse world direction", _left_drag_pans_inverse(map_definition, houses)))
	rows.append(_row("GĐ2-M0A drag distance scales through current zoom", _drag_scales_through_zoom(map_definition, houses)))
	rows.append(_row("GĐ2-M0A drag camera remains inside legal bounds", _drag_clamps(map_definition, houses)))
	rows.append(_row("GĐ2-M0A active drag suppresses and release restores edge pan", _drag_edge_pan_lifecycle(map_definition, houses)))
	rows.append(_row("GĐ2-M0A sub-threshold pointer movement remains a click", _drag_threshold_preserves_click(map_definition, houses)))
	rows.append(_row("GĐ2-M0A wheel zoom preserves cursor world anchor when unclamped", _cursor_zoom_anchor_holds(map_definition, houses)))
	rows.append(_row("GĐ2-M0A cursor zoom clamps legally at map boundaries", _cursor_zoom_clamps(map_definition, houses)))
	rows.append(_row("GĐ2-M0A drag and cursor zoom do not mutate gameplay", _pointer_navigation_is_camera_only(map_definition, houses)))
	rows.append(_row("GĐ2-M0A Space focus preserves zoom and clears drag", _focus_preserves_zoom(map_definition, houses)))
	rows.append(_row("GĐ2-M0A edge pan changes camera without moving players", _edge_pan_is_camera_only(map_definition, houses)))
	rows.append(_row("GĐ2-M0A edge pan recognizes four viewport edges", _four_edge_directions()))
	rows.append(_row("GĐ2-M0A edge pan normalizes corner direction", _corner_direction_is_normalized()))
	rows.append(_row("GĐ2-M0A camera remains inside authored bounds", _camera_clamps(map_definition, houses)))
	rows.append(_row("GĐ2-M0A focus centers the active player when possible", _active_focus_works(map_definition, houses)))
	rows.append(_row("GĐ2-M0A focus does not consume movement state", _focus_consumes_no_state(map_definition, houses)))
	rows.append(_row("GĐ2-M0A turn-owner change refocuses the map", _turn_change_focuses(map_definition, houses)))
	rows.append(_row("GĐ2-M0A manual pan remains available after focus", _pan_after_focus_works(map_definition, houses)))
	rows.append(_row("GĐ2-M0A camera movement is independent of route movement", _camera_and_route_are_independent(map_definition, houses)))
	rows.append(_row("GĐ2-M0A legacy TEST_ONLY map remains valid", _legacy_map_remains_valid()))
	rows.append(_row("GĐ2-M0A movement keeps Speed and Stamina semantics", _speed_stamina_semantics(houses, map_definition)))
	rows.append(_row("GĐ2-M0A normal tabletop view hides node labels", _normal_view_hides_node_labels(view)))
	rows.append(_row("GĐ2-M0A presents five readable House regions", view.house_region_count() == 5))
	rows.append(_row("GĐ2-M0A preview background leaves drag gestures unhandled", _preview_drag_input_contract()))
	rows.append(_row("GĐ2-M0A F9 debug toggle is presentation-only", _debug_toggle_is_presentation_only(map_definition, houses)))
	rows.append(_row("GĐ2-M0A F11 true fullscreen hook and clean HUD exist", _fullscreen_and_hud_contract(map_definition, houses)))
	return rows


func _row(name: String, passed: bool) -> Dictionary:
	return {"name": name, "passed": passed, "detail": "GĐ2-M0A production map foundation invariant"}


func _house_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	result.append(&"house_hoang")
	result.append(&"house_chu")
	result.append(&"house_kim")
	result.append(&"house_huyen")
	result.append(&"house_lam")
	return result


func _house_ids_match(houses: Array[HouseDefinition]) -> bool:
	if houses.size() != 5:
		return false
	var expected: Array[StringName] = _house_ids()
	var observed: Array[StringName] = []
	for house: HouseDefinition in houses:
		if house == null or not house.is_valid() or observed.has(house.house_id):
			return false
		observed.append(house.house_id)
	return observed == expected


func _house_names_match(houses: Array[HouseDefinition]) -> bool:
	var expected: Array[String] = [
		"Nhà họ Hoàng", "Nhà họ Chu", "Nhà họ Kim", "Nhà họ Huyền", "Nhà họ Lam",
	]
	if houses.size() != expected.size():
		return false
	for index: int in range(houses.size()):
		if houses[index].display_name != expected[index]:
			return false
	return true


func _house_order_matches(houses: Array[HouseDefinition]) -> bool:
	if houses.size() != 5:
		return false
	for index: int in range(houses.size()):
		if houses[index].display_order != index + 1:
			return false
	return true


func _house_spatial_roles_match(houses: Array[HouseDefinition]) -> bool:
	var expected: Array[int] = [
		HouseDefinition.SpatialRole.CENTER,
		HouseDefinition.SpatialRole.SOUTH,
		HouseDefinition.SpatialRole.WEST,
		HouseDefinition.SpatialRole.NORTH,
		HouseDefinition.SpatialRole.EAST,
	]
	if houses.size() != expected.size():
		return false
	for index: int in range(houses.size()):
		if houses[index].spatial_role != expected[index]:
			return false
	return true


func _production_assets_load(map_definition: LootMapDefinition) -> bool:
	if map_definition == null or map_definition.test_only_not_canon_locked:
		return false
	var report: LootValidationReport = LootMovementMapValidator.new().validate(
		map_definition, _house_ids()
	)
	return (
		map_definition.map_id == &"imperial_court_tabletop_v1"
		and map_definition.data_version == 2
		and map_definition.nodes.size() == 77
		and report.is_valid
		and PREVIEW_SCENE is PackedScene
	)


func _origins_are_distinct(map_definition: LootMapDefinition, house_ids: Array[StringName]) -> bool:
	if map_definition == null or map_definition.origin_spawn_by_house.size() != 5:
		return false
	var spawn_ids: Array[StringName] = []
	for house_id: StringName in house_ids:
		var spawn_id: StringName = StringName(map_definition.origin_spawn_by_house.get(house_id, &""))
		if spawn_id.is_empty() or spawn_ids.has(spawn_id):
			return false
		spawn_ids.append(spawn_id)
	return true


func _house_spawn_branch_contract(
	map_definition: LootMapDefinition, house_ids: Array[StringName]
) -> bool:
	var branch_count := 0
	for house_id: StringName in house_ids:
		var spawn_id := StringName(map_definition.origin_spawn_by_house.get(house_id, &""))
		var spawn: LootNodeDefinition = map_definition.find_node(spawn_id)
		if (
			spawn == null
			or spawn.node_kind != &"ORIGIN_SPAWN"
			or spawn.origin_house_id != house_id
			or spawn.outgoing_neighbor_ids.size() != 2
		):
			return false
		branch_count += spawn.outgoing_neighbor_ids.size()
	return branch_count == 10


func _physical_house_placement_matches(map_definition: LootMapDefinition) -> bool:
	var huyen: LootNodeDefinition = map_definition.find_node(&"huyen_spawn")
	var kim: LootNodeDefinition = map_definition.find_node(&"kim_spawn")
	var hoang: LootNodeDefinition = map_definition.find_node(&"hoang_spawn")
	var lam: LootNodeDefinition = map_definition.find_node(&"lam_spawn")
	var chu: LootNodeDefinition = map_definition.find_node(&"chu_spawn")
	if huyen == null or kim == null or hoang == null or lam == null or chu == null:
		return false
	return (
		huyen.world_position.y < kim.world_position.y
		and huyen.world_position.y < lam.world_position.y
		and kim.world_position.x < huyen.world_position.x
		and hoang.world_position.x < huyen.world_position.x
		and lam.world_position.x > huyen.world_position.x
		and chu.world_position.x > huyen.world_position.x
		and hoang.world_position.y > kim.world_position.y
		and chu.world_position.y > lam.world_position.y
	)


func _house_routes_share_hub_without_early_merge(
	map_definition: LootMapDefinition, house_ids: Array[StringName]
) -> bool:
	for house_id: StringName in house_ids:
		var spawn_id := StringName(map_definition.origin_spawn_by_house.get(house_id, &""))
		var spawn: LootNodeDefinition = map_definition.find_node(spawn_id)
		if spawn == null or spawn.outgoing_neighbor_ids.size() != 2:
			return false
		var lane_a: Array[StringName] = _trace_linear_path(
			map_definition, spawn.outgoing_neighbor_ids[0], &"central_hub"
		)
		var lane_b: Array[StringName] = _trace_linear_path(
			map_definition, spawn.outgoing_neighbor_ids[1], &"central_hub"
		)
		if lane_a.is_empty() or lane_b.is_empty():
			return false
		for node_id: StringName in lane_a:
			if node_id != &"central_hub" and lane_b.has(node_id):
				return false
	return true


func _house_route_fairness_matches(
	map_definition: LootMapDefinition, house_ids: Array[StringName]
) -> bool:
	for house_id: StringName in house_ids:
		var spawn_id := StringName(map_definition.origin_spawn_by_house.get(house_id, &""))
		var spawn: LootNodeDefinition = map_definition.find_node(spawn_id)
		if spawn == null or spawn.outgoing_neighbor_ids.size() != 2:
			return false
		for lane_start: StringName in spawn.outgoing_neighbor_ids:
			var path: Array[StringName] = _trace_linear_path(
				map_definition, lane_start, &"central_hub"
			)
			# Four House Loot nodes plus the shared hub equals five movement edges.
			if path.size() != 5:
				return false
			for index: int in range(path.size() - 1):
				var node: LootNodeDefinition = map_definition.find_node(path[index])
				if node == null or node.origin_house_id != house_id or &"HOUSE" not in node.tags:
					return false
	return true


func _middle_route_contract_matches(map_definition: LootMapDefinition) -> bool:
	var hub: LootNodeDefinition = map_definition.find_node(&"central_hub")
	if hub == null or hub.outgoing_neighbor_ids.size() != 3:
		return false
	var first_nodes: Dictionary = {}
	for lane_start: StringName in hub.outgoing_neighbor_ids:
		if first_nodes.has(lane_start):
			return false
		first_nodes[lane_start] = true
		var path: Array[StringName] = _trace_linear_path(
			map_definition, lane_start, &"mausoleum_hub"
		)
		# Five Middle Loot nodes plus the Mausoleum Hub equals six edges.
		if path.size() != 6:
			return false
	return true


func _middle_routes_converge_at_mausoleum(map_definition: LootMapDefinition) -> bool:
	var hub: LootNodeDefinition = map_definition.find_node(&"central_hub")
	if hub == null:
		return false
	var occupied: Dictionary = {}
	for lane_start: StringName in hub.outgoing_neighbor_ids:
		var path: Array[StringName] = _trace_linear_path(
			map_definition, lane_start, &"mausoleum_hub"
		)
		if path.is_empty() or path[path.size() - 1] != &"mausoleum_hub":
			return false
		for node_id: StringName in path:
			if node_id == &"mausoleum_hub":
				continue
			if occupied.has(node_id):
				return false
			occupied[node_id] = true
	return true


func _final_route_contract_matches(map_definition: LootMapDefinition) -> bool:
	var hub: LootNodeDefinition = map_definition.find_node(&"mausoleum_hub")
	if hub == null or hub.outgoing_neighbor_ids.size() != 3:
		return false
	var occupied: Dictionary = {}
	var lane_positions: Array = []
	for lane_start: StringName in hub.outgoing_neighbor_ids:
		var path: Array[StringName] = _trace_to_terminal(map_definition, lane_start)
		if path.size() != 5:
			return false
		var positions: Array[Vector2] = []
		var terminal: LootNodeDefinition = map_definition.find_node(path[path.size() - 1])
		if terminal == null or terminal.node_kind != &"END" or not terminal.outgoing_neighbor_ids.is_empty():
			return false
		for node_id: StringName in path:
			if occupied.has(node_id):
				return false
			occupied[node_id] = true
			var node: LootNodeDefinition = map_definition.find_node(node_id)
			if node == null:
				return false
			positions.append(node.world_position)
		lane_positions.append(positions)
	return _final_lanes_run_south(lane_positions, hub.world_position.x)


func _final_lanes_run_south(lanes: Array, center_x: float) -> bool:
	if lanes.size() != 3:
		return false
	for depth: int in range(5):
		var left: Vector2 = lanes[0][depth]
		var center: Vector2 = lanes[1][depth]
		var right: Vector2 = lanes[2][depth]
		if not (left.x < center.x and center.x < right.x):
			return false
		if not (left.y == center.y and center.y == right.y):
			return false
		if depth == 0:
			continue
		for lane: Array in lanes:
			var previous: Vector2 = lane[depth - 1]
			var current: Vector2 = lane[depth]
			var delta: Vector2 = current - previous
			if delta.y <= 0.0 or absf(delta.x) > delta.y:
				return false
		var previous_left: Vector2 = lanes[0][depth - 1]
		var previous_right: Vector2 = lanes[2][depth - 1]
		if absf(left.x - center_x) > absf(previous_left.x - center_x):
			return false
		if absf(right.x - center_x) > absf(previous_right.x - center_x):
			return false
	return true


func _zone_metadata_and_no_waypoint_nodes(map_definition: LootMapDefinition) -> bool:
	var zones: Dictionary = {&"HOUSE": false, &"MIDDLE": false, &"POST_MAUSOLEUM": false}
	for node: LootNodeDefinition in map_definition.nodes:
		if node == null or node.node_kind == &"WAYPOINT" or &"PRESENTATION_WAYPOINT" in node.tags:
			return false
		for zone_id: StringName in zones:
			if zone_id in node.tags:
				zones[zone_id] = true
	return bool(zones[&"HOUSE"]) and bool(zones[&"MIDDLE"]) and bool(zones[&"POST_MAUSOLEUM"])


func _trace_linear_path(
	map_definition: LootMapDefinition, start_id: StringName, target_id: StringName
) -> Array[StringName]:
	var path: Array[StringName] = []
	var current_id := start_id
	var visited: Dictionary = {}
	while not current_id.is_empty() and not visited.has(current_id):
		visited[current_id] = true
		path.append(current_id)
		if current_id == target_id:
			return path
		var node: LootNodeDefinition = map_definition.find_node(current_id)
		if node == null or node.outgoing_neighbor_ids.size() != 1:
			return []
		current_id = node.outgoing_neighbor_ids[0]
	return []


func _trace_to_terminal(
	map_definition: LootMapDefinition, start_id: StringName
) -> Array[StringName]:
	var path: Array[StringName] = []
	var current_id := start_id
	var visited: Dictionary = {}
	while not current_id.is_empty() and not visited.has(current_id):
		visited[current_id] = true
		path.append(current_id)
		var node: LootNodeDefinition = map_definition.find_node(current_id)
		if node == null:
			return []
		if node.outgoing_neighbor_ids.is_empty():
			return path
		if node.outgoing_neighbor_ids.size() != 1:
			return []
		current_id = node.outgoing_neighbor_ids[0]
	return []


func _node_ownership_is_consistent(map_definition: LootMapDefinition) -> bool:
	for node: LootNodeDefinition in map_definition.nodes:
		if node == null or node.test_only_not_canon_locked:
			return false
		var shared: bool = &"SHARED" in node.tags
		if shared and not node.origin_house_id.is_empty():
			return false
		if not shared and node.origin_house_id.is_empty():
			return false
	return true


func _movement_service_accepts(
	houses: Array[HouseDefinition], map_definition: LootMapDefinition
) -> bool:
	return _service_session(houses, map_definition) != null


func _markers_resolve(view: PlayerFacingLootMapView, session: LootMovementSession) -> bool:
	var snapshot: Dictionary = view.presentation_snapshot()
	var token_nodes_value: Variant = snapshot.get("token_nodes", {})
	if not token_nodes_value is Dictionary:
		return false
	var token_nodes: Dictionary = token_nodes_value
	if token_nodes.size() != 5:
		return false
	for player: LootMovementPlayerState in session.player_states:
		if view.node_screen_position(player.current_node_id) == Vector2.ZERO:
			return false
	return true


func _camera_bounds_derive(view: PlayerFacingLootMapView, world_rect: Rect2) -> bool:
	var actual: Rect2 = view.world_bounds()
	var camera_bounds: Rect2 = view.camera_center_bounds()
	return actual == world_rect and camera_bounds.size.x > 0.0 and camera_bounds.size.y > 0.0


func _wheel_up_zooms_in(
	map_definition: LootMapDefinition, houses: Array[HouseDefinition]
) -> bool:
	var view: PlayerFacingLootMapView = _view(
		map_definition, _preview_session(houses, map_definition)
	)
	var before_zoom: float = view.zoom_level()
	var before_area: float = view.visible_world_size().x * view.visible_world_size().y
	var changed: bool = view.apply_wheel_zoom(MOUSE_BUTTON_WHEEL_UP)
	var after_area: float = view.visible_world_size().x * view.visible_world_size().y
	return changed and view.zoom_level() > before_zoom and after_area < before_area


func _wheel_down_zooms_out(
	map_definition: LootMapDefinition, houses: Array[HouseDefinition]
) -> bool:
	var view: PlayerFacingLootMapView = _view(
		map_definition, _preview_session(houses, map_definition)
	)
	var before_zoom: float = view.zoom_level()
	var before_area: float = view.visible_world_size().x * view.visible_world_size().y
	var changed: bool = view.apply_wheel_zoom(MOUSE_BUTTON_WHEEL_DOWN)
	var after_area: float = view.visible_world_size().x * view.visible_world_size().y
	return changed and view.zoom_level() < before_zoom and after_area > before_area


func _zoom_limits_hold(
	map_definition: LootMapDefinition, houses: Array[HouseDefinition]
) -> bool:
	var view: PlayerFacingLootMapView = _view(
		map_definition, _preview_session(houses, map_definition)
	)
	for _zoom_in_step: int in range(32):
		view.apply_wheel_zoom(MOUSE_BUTTON_WHEEL_UP)
	var maximum_holds: bool = is_equal_approx(view.zoom_level(), view.maximum_zoom())
	for _zoom_out_step: int in range(32):
		view.apply_wheel_zoom(MOUSE_BUTTON_WHEEL_DOWN)
	return maximum_holds and is_equal_approx(view.zoom_level(), view.minimum_zoom())


func _minimum_zoom_frames_map(
	map_definition: LootMapDefinition, houses: Array[HouseDefinition]
) -> bool:
	var view: PlayerFacingLootMapView = _view(
		map_definition, _preview_session(houses, map_definition)
	)
	for _step: int in range(32):
		view.apply_wheel_zoom(MOUSE_BUTTON_WHEEL_DOWN)
	var visible: Vector2 = view.visible_world_size()
	var framed: Rect2 = view.framing_world_bounds()
	var framed_screen_size: Vector2 = framed.size * view.zoom_level()
	return (
		visible.x >= framed.size.x
		and visible.y >= framed.size.y
		and view.size.x - framed_screen_size.x >= 63.9
		and view.size.y - framed_screen_size.y >= 63.9
	)


func _zoom_reclamps_camera(
	map_definition: LootMapDefinition, houses: Array[HouseDefinition]
) -> bool:
	var view: PlayerFacingLootMapView = _view(
		map_definition, _preview_session(houses, map_definition)
	)
	view.pan_camera(Vector2(1.0, 1.0), 1000.0)
	var before_zoom_out: Vector2 = view.camera_center()
	for _step: int in range(32):
		view.apply_wheel_zoom(MOUSE_BUTTON_WHEEL_DOWN)
	var bounds: Rect2 = view.camera_center_bounds()
	var expected := Vector2(
		clampf(before_zoom_out.x, bounds.position.x, bounds.end.x),
		clampf(before_zoom_out.y, bounds.position.y, bounds.end.y)
	)
	return view.camera_center().is_equal_approx(expected)


func _left_drag_pans_inverse(
	map_definition: LootMapDefinition, houses: Array[HouseDefinition]
) -> bool:
	var view: PlayerFacingLootMapView = _view(
		map_definition, _preview_session(houses, map_definition)
	)
	view.pan_camera(Vector2.RIGHT, 1.0)
	view.pan_camera(Vector2.DOWN, 1.0)
	var start := Vector2(500.0, 300.0)
	var screen_delta := Vector2(40.0, 30.0)
	var before: Vector2 = view.camera_center()
	view.begin_pointer_drag(start)
	var dragged: bool = view.update_pointer_drag(start + screen_delta)
	return dragged and view.camera_center().is_equal_approx(before - screen_delta)


func _drag_scales_through_zoom(
	map_definition: LootMapDefinition, houses: Array[HouseDefinition]
) -> bool:
	var view: PlayerFacingLootMapView = _view(
		map_definition, _preview_session(houses, map_definition)
	)
	view.pan_camera(Vector2.DOWN, 1.0)
	view.apply_wheel_zoom(MOUSE_BUTTON_WHEEL_UP)
	var start := Vector2(500.0, 300.0)
	var screen_delta := Vector2(-44.0, 22.0)
	var before: Vector2 = view.camera_center()
	var zoom: float = view.zoom_level()
	view.begin_pointer_drag(start)
	view.update_pointer_drag(start + screen_delta)
	return view.camera_center().is_equal_approx(before - screen_delta / zoom)


func _drag_clamps(
	map_definition: LootMapDefinition, houses: Array[HouseDefinition]
) -> bool:
	var view: PlayerFacingLootMapView = _view(
		map_definition, _preview_session(houses, map_definition)
	)
	view.pan_camera(Vector2(-1.0, -1.0), 1000.0)
	var bounds: Rect2 = view.camera_center_bounds()
	var start := Vector2(500.0, 300.0)
	view.begin_pointer_drag(start)
	view.update_pointer_drag(start + Vector2(500.0, 500.0))
	return view.camera_center().is_equal_approx(bounds.position)


func _drag_edge_pan_lifecycle(
	map_definition: LootMapDefinition, houses: Array[HouseDefinition]
) -> bool:
	var view: PlayerFacingLootMapView = _view(
		map_definition, _preview_session(houses, map_definition)
	)
	var start := Vector2(500.0, 300.0)
	view.begin_pointer_drag(start)
	view.update_pointer_drag(start + Vector2(view.drag_threshold() + 1.0, 0.0))
	var suppressed: bool = view.pointer_drag_active() and not view.edge_pan_available()
	var ended_drag: bool = view.end_pointer_drag()
	return suppressed and ended_drag and view.edge_pan_available()


func _drag_threshold_preserves_click(
	map_definition: LootMapDefinition, houses: Array[HouseDefinition]
) -> bool:
	var view: PlayerFacingLootMapView = _view(
		map_definition, _preview_session(houses, map_definition)
	)
	var start := Vector2(500.0, 300.0)
	var before: Vector2 = view.camera_center()
	view.begin_pointer_drag(start)
	var dragged: bool = view.update_pointer_drag(
		start + Vector2(view.drag_threshold() - 1.0, 0.0)
	)
	var ended_drag: bool = view.end_pointer_drag()
	return not dragged and not ended_drag and view.camera_center() == before


func _cursor_zoom_anchor_holds(
	map_definition: LootMapDefinition, houses: Array[HouseDefinition]
) -> bool:
	var view: PlayerFacingLootMapView = _view(
		map_definition, _preview_session(houses, map_definition)
	)
	view.pan_camera(Vector2.DOWN, 1.0)
	var cursor := Vector2(850.0, 410.0)
	var world_before: Vector2 = view.screen_to_world(cursor)
	var changed: bool = view.apply_wheel_zoom_at(MOUSE_BUTTON_WHEEL_UP, cursor)
	var world_after: Vector2 = view.screen_to_world(cursor)
	return changed and world_after.is_equal_approx(world_before)


func _cursor_zoom_clamps(
	map_definition: LootMapDefinition, houses: Array[HouseDefinition]
) -> bool:
	var view: PlayerFacingLootMapView = _view(
		map_definition, _preview_session(houses, map_definition)
	)
	view.pan_camera(Vector2(-1.0, -1.0), 1000.0)
	var changed: bool = view.apply_wheel_zoom_at(
		MOUSE_BUTTON_WHEEL_DOWN, view.size - Vector2(1.0, 1.0)
	)
	var bounds: Rect2 = view.camera_center_bounds()
	return changed and bounds.has_point(view.camera_center())


func _pointer_navigation_is_camera_only(
	map_definition: LootMapDefinition, houses: Array[HouseDefinition]
) -> bool:
	var session: LootMovementSession = _preview_session(houses, map_definition)
	var view: PlayerFacingLootMapView = _view(map_definition, session)
	var before_state: Dictionary = session.to_dict()
	var start := Vector2(500.0, 300.0)
	view.begin_pointer_drag(start)
	view.update_pointer_drag(start + Vector2(-40.0, -30.0))
	view.end_pointer_drag()
	view.apply_wheel_zoom_at(MOUSE_BUTTON_WHEEL_UP, Vector2(800.0, 400.0))
	return session.to_dict() == before_state


func _focus_preserves_zoom(
	map_definition: LootMapDefinition, houses: Array[HouseDefinition]
) -> bool:
	var session: LootMovementSession = _preview_session(houses, map_definition)
	var view: PlayerFacingLootMapView = _view(map_definition, session)
	view.apply_wheel_zoom(MOUSE_BUTTON_WHEEL_DOWN)
	var before_zoom: float = view.zoom_level()
	view.pan_camera(Vector2.DOWN, 0.2)
	var start := Vector2(500.0, 300.0)
	view.begin_pointer_drag(start)
	view.update_pointer_drag(start + Vector2(view.drag_threshold() + 1.0, 0.0))
	view.focus_active_player()
	return is_equal_approx(view.zoom_level(), before_zoom) and not view.pointer_drag_active()


func _edge_pan_is_camera_only(
	map_definition: LootMapDefinition, houses: Array[HouseDefinition]
) -> bool:
	var session: LootMovementSession = _preview_session(houses, map_definition)
	var view: PlayerFacingLootMapView = _view(map_definition, session)
	var before_camera: Vector2 = view.camera_center()
	var before_node: StringName = session.current_player().current_node_id
	view.pan_camera(Vector2.RIGHT, 0.25)
	return view.camera_center() != before_camera and session.current_player().current_node_id == before_node


func _four_edge_directions() -> bool:
	var size := Vector2(1280.0, 720.0)
	return (
		MAP_VIEW.edge_pan_direction_for_position(Vector2(1.0, 360.0), size, 42.0) == Vector2.LEFT
		and MAP_VIEW.edge_pan_direction_for_position(Vector2(1279.0, 360.0), size, 42.0) == Vector2.RIGHT
		and MAP_VIEW.edge_pan_direction_for_position(Vector2(640.0, 1.0), size, 42.0) == Vector2.UP
		and MAP_VIEW.edge_pan_direction_for_position(Vector2(640.0, 719.0), size, 42.0) == Vector2.DOWN
	)


func _corner_direction_is_normalized() -> bool:
	var direction: Vector2 = MAP_VIEW.edge_pan_direction_for_position(
		Vector2(1.0, 1.0), Vector2(1280.0, 720.0), 42.0
	)
	return is_equal_approx(direction.length(), 1.0) and direction.x < 0.0 and direction.y < 0.0


func _camera_clamps(map_definition: LootMapDefinition, houses: Array[HouseDefinition]) -> bool:
	var view: PlayerFacingLootMapView = _view(map_definition, _preview_session(houses, map_definition))
	view.pan_camera(Vector2(-1.0, -1.0), 1000.0)
	var bounds: Rect2 = view.camera_center_bounds()
	if view.camera_center() != bounds.position:
		return false
	view.pan_camera(Vector2(1.0, 1.0), 1000.0)
	return view.camera_center() == bounds.end


func _active_focus_works(map_definition: LootMapDefinition, houses: Array[HouseDefinition]) -> bool:
	var session: LootMovementSession = _preview_session(houses, map_definition)
	var view: PlayerFacingLootMapView = _view(map_definition, session)
	var active_node: LootNodeDefinition = map_definition.find_node(session.current_player().current_node_id)
	if active_node == null:
		return false
	var bounds: Rect2 = view.camera_center_bounds()
	var expected_center := Vector2(
		clampf(active_node.world_position.x, bounds.position.x, bounds.end.x),
		clampf(active_node.world_position.y, bounds.position.y, bounds.end.y)
	)
	return view.camera_center().is_equal_approx(expected_center)


func _focus_consumes_no_state(
	map_definition: LootMapDefinition, houses: Array[HouseDefinition]
) -> bool:
	var session: LootMovementSession = _preview_session(houses, map_definition)
	var view: PlayerFacingLootMapView = _view(map_definition, session)
	var before: Dictionary = session.to_dict()
	view.focus_active_player()
	return session.to_dict() == before


func _turn_change_focuses(map_definition: LootMapDefinition, houses: Array[HouseDefinition]) -> bool:
	var session: LootMovementSession = _preview_session(houses, map_definition)
	var view: PlayerFacingLootMapView = _view(map_definition, session)
	var drag_start := Vector2(500.0, 300.0)
	view.begin_pointer_drag(drag_start)
	view.update_pointer_drag(drag_start + Vector2(view.drag_threshold() + 1.0, 0.0))
	session.current_turn_index = 2
	view.configure(map_definition, session)
	var active_node: LootNodeDefinition = map_definition.find_node(session.current_player().current_node_id)
	if active_node == null:
		return false
	var screen_position: Vector2 = view.node_screen_position(active_node.node_id)
	return (
		not view.pointer_drag_active()
		and screen_position.x >= 0.0 and screen_position.x <= view.size.x
		and screen_position.y >= 0.0 and screen_position.y <= view.size.y
	)


func _pan_after_focus_works(map_definition: LootMapDefinition, houses: Array[HouseDefinition]) -> bool:
	var view: PlayerFacingLootMapView = _view(map_definition, _preview_session(houses, map_definition))
	var focused: Vector2 = view.camera_center()
	view.pan_camera(Vector2.DOWN, 0.2)
	return view.camera_center() != focused


func _camera_and_route_are_independent(
	map_definition: LootMapDefinition, houses: Array[HouseDefinition]
) -> bool:
	var session: LootMovementSession = _preview_session(houses, map_definition)
	var view: PlayerFacingLootMapView = _view(map_definition, session)
	var before: Dictionary = session.to_dict()
	view.pan_camera(Vector2.RIGHT, 0.1)
	return session.to_dict() == before


func _legacy_map_remains_valid() -> bool:
	var legacy_map: LootMapDefinition = Gd2FixtureRepository.load_map()
	var legacy_houses: Array[StringName] = []
	legacy_houses.append(&"test_house_a")
	legacy_houses.append(&"test_house_b")
	legacy_houses.append(&"test_house_c")
	return LootMapValidator.new().validate(legacy_map, legacy_houses).is_valid


func _speed_stamina_semantics(
	houses: Array[HouseDefinition], map_definition: LootMapDefinition
) -> bool:
	var session: LootMovementSession = _service_session(houses, map_definition)
	if session == null:
		return false
	var first: LootMovementPlayerState = session.current_player()
	var start_id: StringName = first.current_node_id
	var roll_values: Array[int] = [2]
	var result: MovementActionResult = LootMovementService.new().roll_move(
		session, map_definition, SequenceMovementRollSource.new(roll_values)
	)
	return (
		result != null
		and result.roll_distance == 2
		and result.traversed_node_ids.size() == 2
		and result.start_node_id == start_id
		and first.speed_snapshot == 2
		and first.stamina_snapshot == 3
		and first.remaining_moves == 2
	)


func _normal_view_hides_node_labels(view: PlayerFacingLootMapView) -> bool:
	var snapshot: Dictionary = view.presentation_snapshot()
	return (
		not view.debug_labels_visible()
		and not bool(snapshot.get("debug_labels_visible", true))
		and int(snapshot.get("house_region_count", 0)) == 5
	)


func _debug_toggle_is_presentation_only(
	map_definition: LootMapDefinition, houses: Array[HouseDefinition]
) -> bool:
	var session: LootMovementSession = _preview_session(houses, map_definition)
	var view: PlayerFacingLootMapView = _view(map_definition, session)
	var before: Dictionary = session.to_dict()
	view.set_debug_labels_visible(true)
	var became_visible: bool = view.debug_labels_visible()
	view.set_debug_labels_visible(false)
	return (
		PREVIEW_CONTROLLER.preview_hotkey_action(KEY_F9) == &"TOGGLE_DEBUG"
		and became_visible
		and not view.debug_labels_visible()
		and session.to_dict() == before
	)


func _fullscreen_and_hud_contract(
	map_definition: LootMapDefinition, houses: Array[HouseDefinition]
) -> bool:
	var preview: Node = PREVIEW_SCENE.instantiate()
	var player_hud: Node = preview.get_node_or_null("PlayerHud")
	var debug_overlay: CanvasItem = preview.get_node_or_null("DebugOverlay") as CanvasItem
	var session: LootMovementSession = _preview_session(houses, map_definition)
	var view: PlayerFacingLootMapView = _view(map_definition, session)
	var before: Dictionary = session.to_dict()
	view.refresh_viewport_geometry()
	var valid: bool = (
		PREVIEW_CONTROLLER.preview_hotkey_action(KEY_F11) == &"TOGGLE_FULLSCREEN"
		and PREVIEW_CONTROLLER.fullscreen_window_id() == DisplayServer.MAIN_WINDOW_ID
		and PREVIEW_CONTROLLER.fullscreen_mode_after_toggle(
			DisplayServer.WINDOW_MODE_WINDOWED
		) == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
		and PREVIEW_CONTROLLER.fullscreen_mode_after_toggle(
			DisplayServer.WINDOW_MODE_FULLSCREEN
		) == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
		and PREVIEW_CONTROLLER.fullscreen_mode_after_toggle(
			DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
		) == DisplayServer.WINDOW_MODE_WINDOWED
		and player_hud != null
		and debug_overlay != null
		and not debug_overlay.visible
		and not _has_window_descendant(preview)
		and session.to_dict() == before
		and view.camera_center_bounds().has_point(view.camera_center())
	)
	preview.free()
	return valid


func _preview_drag_input_contract() -> bool:
	var preview: Control = PREVIEW_SCENE.instantiate() as Control
	if preview == null:
		return false
	var map_view: Control = preview.get_node_or_null("ProductionMapView") as Control
	var move_button: Button = preview.get_node_or_null(
		"PlayerHud/Panel/Row/MoveButton"
	) as Button
	var back_button: Button = preview.get_node_or_null(
		"PlayerHud/Panel/Row/BackButton"
	) as Button
	var valid: bool = (
		preview.mouse_filter == Control.MOUSE_FILTER_IGNORE
		and map_view != null
		and map_view.mouse_filter == Control.MOUSE_FILTER_IGNORE
		and move_button != null
		and move_button.mouse_filter == Control.MOUSE_FILTER_STOP
		and back_button != null
		and back_button.mouse_filter == Control.MOUSE_FILTER_STOP
	)
	preview.free()
	return valid


func _has_window_descendant(node: Node) -> bool:
	for child: Node in node.get_children():
		if child is Window or _has_window_descendant(child):
			return true
	return false


func _preview_session(
	houses: Array[HouseDefinition], map_definition: LootMapDefinition
) -> LootMovementSession:
	var session := LootMovementSession.new()
	session.round_id = &"test_m0a_preview"
	for index: int in range(houses.size()):
		var house: HouseDefinition = houses[index]
		var player := LootMovementPlayerState.new()
		player.player_id = StringName("test_m0a_preview_%d" % (index + 1))
		player.origin_house_id = house.house_id
		player.current_node_id = StringName(map_definition.origin_spawn_by_house.get(house.house_id, &""))
		player.speed_snapshot = 2
		player.stamina_snapshot = 3
		player.remaining_moves = 3
		session.ordered_player_ids.append(player.player_id)
		session.player_states.append(player)
	session.started = true
	return session


func _service_session(
	houses: Array[HouseDefinition], map_definition: LootMapDefinition
) -> LootMovementSession:
	var players: Array[PlayerPhaseState] = []
	var characters: Array[CharacterDefinition] = []
	for index: int in range(houses.size()):
		var character: CharacterDefinition = CharacterDefinition.new()
		character.character_id = StringName("test_m0a_character_%d" % (index + 1))
		character.display_name = "M0A test character %d" % (index + 1)
		character.origin_house_id = houses[index].house_id
		character.base_speed = 2
		character.base_stamina = 3
		character.base_bag_level = 1
		character.test_only_not_canon_locked = true
		characters.append(character)
		var player := PlayerPhaseState.new()
		player.player_id = StringName("test_m0a_player_%d" % (index + 1))
		player.character_id = character.character_id
		players.append(player)
	return LootMovementService.new().build_session_from_selection(
		players, characters, map_definition, &"test_m0a_round"
	)


func _view(
	map_definition: LootMapDefinition, session: LootMovementSession
) -> PlayerFacingLootMapView:
	var view: PlayerFacingLootMapView = MAP_VIEW.new()
	view.size = Vector2(1280.0, 720.0)
	view.configure(map_definition, session)
	return view


func _node_world_bounds(map_definition: LootMapDefinition) -> Rect2:
	var minimum := Vector2(INF, INF)
	var maximum := Vector2(-INF, -INF)
	for node: LootNodeDefinition in map_definition.nodes:
		minimum.x = minf(minimum.x, node.world_position.x)
		minimum.y = minf(minimum.y, node.world_position.y)
		maximum.x = maxf(maximum.x, node.world_position.x)
		maximum.y = maxf(maximum.y, node.world_position.y)
	return Rect2(minimum, maximum - minimum)
