class_name PlayerFacingLootMapView
extends Control

const NODE_RADIUS := 18.0
const MAP_PADDING := Vector2(42.0, 38.0)
const CAMERA_EDGE_THRESHOLD := 42.0
const CAMERA_PAN_SPEED := 680.0
const CAMERA_WORLD_MARGIN := 160.0
const CAMERA_DEFAULT_ZOOM := 1.0
const CAMERA_MAX_ZOOM := 1.4
const CAMERA_ZOOM_STEP := 0.1
const CAMERA_FIT_SCREEN_MARGIN := 32.0
const CAMERA_DRAG_THRESHOLD := 16.0
const BOARD_ROUTE_WIDTH := 11.0
const BOARD_ROUTE_SHADOW_WIDTH := 19.0

signal node_clicked(node_id: StringName)

var map_definition: LootMapDefinition
var movement_session: LootMovementSession
var represented_node_ids: Array[StringName] = []
var represented_connections: Array[Dictionary] = []
var player_facing_labels: Dictionary = {}
var token_node_by_player: Dictionary = {}
var active_player_id: StringName
var highlighted_path: Array[StringName] = []
var selectable_branch_nodes: Array[StringName] = []
var _node_positions: Dictionary = {}
var _camera_center := Vector2.ZERO
var _camera_initialized := false
var _debug_labels_visible := false
var _zoom := CAMERA_DEFAULT_ZOOM
var _drag_press_held := false
var _drag_active := false
var _drag_start_screen_position := Vector2.ZERO
var _drag_last_screen_position := Vector2.ZERO


func configure(source_map: LootMapDefinition, source_movement: LootMovementSession) -> void:
	var previous_active: StringName = active_player_id
	map_definition = source_map
	movement_session = source_movement
	_rebuild_binding()
	if _uses_authored_world_coordinates():
		_clamp_zoom()
		if not _camera_initialized or previous_active != active_player_id:
			focus_active_player()
		else:
			_clamp_camera()
			_build_positions()
	queue_redraw()


func presentation_snapshot() -> Dictionary:
	return {
		"node_count": represented_node_ids.size(),
		"connection_count": represented_connections.size(),
		"labels": player_facing_labels.duplicate(true),
		"token_nodes": token_node_by_player.duplicate(true),
		"active_player_id": String(active_player_id),
		"highlighted_path": highlighted_path.duplicate(),
		"selectable_branches": selectable_branch_nodes.duplicate(),
		"camera_center": _camera_center,
		"zoom": _zoom,
		"minimum_zoom": minimum_zoom(),
		"visible_world_size": visible_world_size(),
		"world_bounds": world_bounds(),
		"debug_labels_visible": _debug_labels_visible,
		"house_region_count": house_region_count(),
	}


func set_selectable_branches(node_ids: Array[StringName]) -> void:
	selectable_branch_nodes = node_ids.duplicate()
	queue_redraw()


func find_node_at_screen_position(screen_pos: Vector2) -> StringName:
	var branch_hit_radius: float = maxf((NODE_RADIUS + 28.0) * _visual_scale(), 50.0)
	var best_branch_id: StringName = &""
	var best_branch_dist: float = branch_hit_radius
	for branch_id: StringName in selectable_branch_nodes:
		if _node_positions.has(branch_id):
			var pos: Vector2 = _node_positions[branch_id]
			var d: float = pos.distance_to(screen_pos)
			if d <= best_branch_dist:
				best_branch_dist = d
				best_branch_id = branch_id
	if not best_branch_id.is_empty():
		return best_branch_id

	var max_dist: float = maxf((NODE_RADIUS + 18.0) * _visual_scale(), 38.0)
	var best_id: StringName = &""
	var best_dist: float = max_dist
	for node_id: StringName in _node_positions:
		var pos: Vector2 = _node_positions[node_id]
		var d: float = pos.distance_to(screen_pos)
		if d <= best_dist:
			best_dist = d
			best_id = node_id
	return best_id


func label_for_node(node_id: StringName) -> String:
	return String(player_facing_labels.get(node_id, "Đường trong Hoàng Cung"))


func set_debug_labels_visible(visible: bool) -> void:
	_debug_labels_visible = visible
	queue_redraw()


func debug_labels_visible() -> bool:
	return _debug_labels_visible


func refresh_viewport_geometry() -> void:
	if map_definition == null:
		return
	if _uses_authored_world_coordinates():
		_clamp_zoom()
		_clamp_camera()
	_build_positions()
	queue_redraw()


func house_region_count() -> int:
	if map_definition == null or not _uses_authored_world_coordinates():
		return 0
	var represented_houses: Dictionary = {}
	for node: LootNodeDefinition in map_definition.nodes:
		if node != null and not node.origin_house_id.is_empty():
			represented_houses[node.origin_house_id] = true
	return represented_houses.size()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and map_definition != null:
		if _uses_authored_world_coordinates():
			_clamp_zoom()
			_clamp_camera()
		_build_positions()
		queue_redraw()


func _process(delta: float) -> void:
	if not _uses_authored_world_coordinates() or not is_visible_in_tree():
		return
	if not edge_pan_available():
		return
	var direction: Vector2 = edge_pan_direction_for_position(
		get_local_mouse_position(), size, CAMERA_EDGE_THRESHOLD
	)
	if direction != Vector2.ZERO:
		pan_camera(direction, delta)


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event: InputEventKey = event as InputEventKey
	if (
		key_event == null
		or not key_event.pressed
		or key_event.echo
		or key_event.keycode != KEY_SPACE
	):
		return
	var focus_owner: Control = get_viewport().gui_get_focus_owner()
	if focus_owner != null:
		return
	focus_active_player()
	get_viewport().set_input_as_handled()


func _gui_input(event: InputEvent) -> void:
	if _handle_pointer_input(event):
		accept_event()


func _unhandled_input(event: InputEvent) -> void:
	if _handle_pointer_input(event):
		get_viewport().set_input_as_handled()


func _handle_pointer_input(event: InputEvent) -> bool:
	var mouse_button: InputEventMouseButton = event as InputEventMouseButton
	if mouse_button != null:
		var local_position: Vector2 = _viewport_to_local(mouse_button.position)
		if mouse_button.button_index == MOUSE_BUTTON_LEFT:
			if mouse_button.pressed:
				if is_visible_in_tree() and Rect2(Vector2.ZERO, size).has_point(local_position):
					begin_pointer_drag(local_position)
					return true
				return false
			var was_dragging: bool = end_pointer_drag()
			if was_dragging:
				return true
			if is_visible_in_tree() and Rect2(Vector2.ZERO, size).has_point(local_position):
				var clicked_node: StringName = find_node_at_screen_position(local_position)
				if clicked_node.is_empty() and _drag_start_screen_position != Vector2.ZERO:
					clicked_node = find_node_at_screen_position(_drag_start_screen_position)
				if not clicked_node.is_empty():
					node_clicked.emit(clicked_node)
					return true
			return false
		if (
			mouse_button.pressed
			and is_visible_in_tree()
			and _uses_authored_world_coordinates()
			and Rect2(Vector2.ZERO, size).has_point(local_position)
			and apply_wheel_zoom_at(mouse_button.button_index, local_position)
		):
			return true
		return false
	var mouse_motion: InputEventMouseMotion = event as InputEventMouseMotion
	if mouse_motion != null:
		var local_pos: Vector2 = _viewport_to_local(mouse_motion.position)
		if _drag_press_held:
			return update_pointer_drag(local_pos)
		if is_visible_in_tree() and Rect2(Vector2.ZERO, size).has_point(local_pos):
			var hovered: StringName = find_node_at_screen_position(local_pos)
			if not hovered.is_empty() and selectable_branch_nodes.has(hovered):
				mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			else:
				mouse_default_cursor_shape = Control.CURSOR_ARROW
	return false


func _rebuild_binding() -> void:
	represented_node_ids.clear()
	represented_connections.clear()
	player_facing_labels.clear()
	token_node_by_player.clear()
	active_player_id = &""
	highlighted_path.clear()
	if map_definition == null:
		return
	for node: LootNodeDefinition in map_definition.nodes:
		if node == null:
			continue
		represented_node_ids.append(node.node_id)
		player_facing_labels[node.node_id] = _build_node_label(node)
		for neighbor_id: StringName in node.outgoing_neighbor_ids:
			represented_connections.append({"from": node.node_id, "to": neighbor_id})
	if movement_session != null:
		var current: LootMovementPlayerState = movement_session.current_player()
		active_player_id = current.player_id if current != null else &""
		for player: LootMovementPlayerState in movement_session.player_states:
			token_node_by_player[player.player_id] = player.current_node_id
		if not movement_session.movement_history.is_empty():
			var action_value: Variant = movement_session.movement_history.back()
			var action: MovementActionResult = action_value as MovementActionResult
			if action != null:
				highlighted_path.append(action.start_node_id)
				for node_id: StringName in action.traversed_node_ids:
					highlighted_path.append(node_id)
	_build_positions()


func _build_positions() -> void:
	_node_positions.clear()
	if map_definition == null:
		return
	if _uses_authored_world_coordinates():
		for node: LootNodeDefinition in map_definition.nodes:
			if node != null:
				_node_positions[node.node_id] = _world_to_screen(node.world_position)
		return
	var roots: Array[LootNodeDefinition] = []
	for node: LootNodeDefinition in map_definition.nodes:
		if node != null and node.node_kind == &"ORIGIN_SPAWN":
			roots.append(node)
	roots.sort_custom(func(a: LootNodeDefinition, b: LootNodeDefinition) -> bool:
		return String(a.origin_house_id) < String(b.origin_house_id)
	)
	var usable_width: float = maxf(size.x - MAP_PADDING.x * 2.0, 460.0)
	var usable_height: float = maxf(size.y - MAP_PADDING.y * 2.0, 260.0)
	var row_by_house: Dictionary = {}
	for index: int in range(roots.size()):
		var y: float = MAP_PADDING.y + usable_height * float(index + 1) / float(roots.size() + 1)
		row_by_house[roots[index].origin_house_id] = y
	for node: LootNodeDefinition in map_definition.nodes:
		if node == null:
			continue
		var position_value: Vector2
		match node.node_kind:
			&"ORIGIN_SPAWN":
				position_value = Vector2(MAP_PADDING.x, float(row_by_house.get(node.origin_house_id, size.y * 0.5)))
			&"PALACE_PATH":
				position_value = Vector2(MAP_PADDING.x + usable_width * 0.25, float(row_by_house.get(node.origin_house_id, size.y * 0.5)))
			&"CENTER_ENTRY":
				position_value = Vector2(MAP_PADDING.x + usable_width * 0.48, size.y * 0.5)
			&"CENTRAL":
				position_value = Vector2(MAP_PADDING.x + usable_width * 0.66, size.y * 0.5)
			&"LOWER_PATH":
				position_value = Vector2(MAP_PADDING.x + usable_width * 0.82, size.y * 0.64)
			&"END":
				position_value = Vector2(MAP_PADDING.x + usable_width, size.y * 0.64)
			_:
				position_value = Vector2(MAP_PADDING.x + usable_width * 0.5, size.y * 0.5)
		_node_positions[node.node_id] = position_value


func _draw() -> void:
	_draw_board_background()
	var visual_scale: float = _visual_scale()
	for edge: Dictionary in represented_connections:
		var from_id: StringName = StringName(edge.get("from", ""))
		var to_id: StringName = StringName(edge.get("to", ""))
		if not _node_positions.has(from_id) or not _node_positions.has(to_id):
			continue
		var is_recent: bool = _path_contains_edge(from_id, to_id)
		var from_node: LootNodeDefinition = map_definition.find_node(from_id)
		var route_color: Color = _route_color(from_node)
		draw_line(
			_node_positions[from_id], _node_positions[to_id],
			Color(0.055, 0.065, 0.065, 0.86),
			(BOARD_ROUTE_SHADOW_WIDTH + (4.0 if is_recent else 0.0)) * visual_scale,
			true
		)
		draw_line(
			_node_positions[from_id], _node_positions[to_id],
			Color(1.0, 0.72, 0.25, 1.0) if is_recent else route_color,
			(BOARD_ROUTE_WIDTH + (3.0 if is_recent else 0.0)) * visual_scale,
			true
		)
	for node_id: StringName in represented_node_ids:
		if not _node_positions.has(node_id):
			continue
		var center: Vector2 = _node_positions[node_id]
		var node: LootNodeDefinition = map_definition.find_node(node_id)
		var radius: float = _node_radius(node) * visual_scale
		var fill: Color = _node_color(node)
		draw_circle(center + Vector2(2.0, 4.0), radius + 5.0, Color(0.03, 0.04, 0.04, 0.58))
		draw_circle(center, radius + 3.0, Color(0.8, 0.68, 0.42, 0.95))
		draw_circle(center, radius, fill)
		draw_arc(center, radius - 4.0, 0.0, TAU, 32, fill.lightened(0.27), 2.0, true)
		if node != null and node.node_kind == &"ORIGIN_SPAWN":
			_draw_origin_seal(center, node.origin_house_id)
		if selectable_branch_nodes.has(node_id):
			_draw_selectable_branch_highlight(center, radius, visual_scale)
		if _debug_labels_visible:
			_draw_debug_node_label(center, node_id)
	_draw_tokens()


func _draw_selectable_branch_highlight(center: Vector2, radius: float, visual_scale: float) -> void:
	var ring_r: float = radius + 6.0 * visual_scale
	draw_circle(center, ring_r + 6.0 * visual_scale, Color(1.0, 0.88, 0.25, 0.22))
	draw_arc(center, ring_r, 0.0, TAU, 36, Color(1.0, 0.85, 0.2, 0.95), 3.5 * visual_scale, true)
	draw_arc(center, ring_r + 3.5 * visual_scale, 0.0, TAU, 36, Color(1.0, 0.95, 0.5, 0.7), 1.8 * visual_scale, true)


func _draw_board_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.075, 0.095, 0.09, 1.0), true)
	if not _uses_authored_world_coordinates():
		return
	_draw_world_rect(
		Rect2(Vector2(1080.0, 40.0), Vector2(1040.0, 2580.0)),
		Color(0.16, 0.17, 0.15, 0.9), Color(0.52, 0.43, 0.27, 0.8), 7.0
	)
	_draw_world_rect(
		Rect2(Vector2(1110.0, 1280.0), Vector2(980.0, 1210.0)),
		Color(0.24, 0.2, 0.15, 0.78), Color(0.76, 0.57, 0.25, 0.72), 5.0
	)
	_draw_world_rect(
		Rect2(Vector2(700.0, 2480.0), Vector2(1800.0, 1080.0)),
		Color(0.14, 0.24, 0.2, 0.78), Color(0.48, 0.64, 0.45, 0.74), 5.0
	)
	_draw_house_regions()
	_draw_region_heading(Vector2(1640.0, 1530.0), "ĐẠI SÂN TRUNG TÂM", "◆", Color(0.82, 0.72, 0.48))
	_draw_region_heading(Vector2(1130.0, 1980.0), "BA TRUNG LỘ", "◇", Color(0.7, 0.78, 0.62))
	_draw_region_heading(Vector2(1640.0, 2630.0), "LĂNG MIẾU", "◆", Color(0.72, 0.78, 0.58))
	_draw_region_heading(Vector2(980.0, 3260.0), "HOÀNG GIA", "◇", Color(0.76, 0.67, 0.43))


func _draw_house_regions() -> void:
	_draw_house_region(
		&"house_huyen", "NHÀ HỌ HUYỀN", "IV",
		PackedVector2Array([
			Vector2(1180, 50), Vector2(2020, 50), Vector2(1980, 1130),
			Vector2(1740, 1220), Vector2(1460, 1220), Vector2(1220, 1130),
		]), Vector2(1500, 100)
	)
	_draw_house_region(
		&"house_kim", "NHÀ HỌ KIM", "III",
		PackedVector2Array([
			Vector2(120, 180), Vector2(1320, 180), Vector2(1450, 780),
			Vector2(1300, 1230), Vector2(120, 760),
		]), Vector2(270, 350)
	)
	_draw_house_region(
		&"house_lam", "NHÀ HỌ LAM", "V",
		PackedVector2Array([
			Vector2(1880, 180), Vector2(3080, 180), Vector2(3080, 760),
			Vector2(1900, 1230), Vector2(1750, 780),
		]), Vector2(2670, 350)
	)
	_draw_house_region(
		&"house_hoang", "NHÀ HỌ HOÀNG", "I",
		PackedVector2Array([
			Vector2(120, 760), Vector2(1300, 950), Vector2(1450, 1490),
			Vector2(120, 1490),
		]), Vector2(280, 930)
	)
	_draw_house_region(
		&"house_chu", "NHÀ HỌ CHU", "II",
		PackedVector2Array([
			Vector2(1900, 950), Vector2(3080, 760), Vector2(3080, 1490),
			Vector2(1750, 1490),
		]), Vector2(2670, 930)
	)


func _draw_house_region(
	house_id: StringName, title: String, seal: String,
	world_points: PackedVector2Array, title_position: Vector2
) -> void:
	var screen_points := PackedVector2Array()
	for point: Vector2 in world_points:
		screen_points.append(_world_to_screen(point))
	var color: Color = _house_color(house_id)
	draw_colored_polygon(screen_points, Color(color.r, color.g, color.b, 0.28))
	var outline: PackedVector2Array = screen_points.duplicate()
	if not outline.is_empty():
		outline.append(outline[0])
	draw_polyline(outline, Color(color.r, color.g, color.b, 0.82), 5.0, true)
	_draw_region_heading(title_position, title, seal, color.lightened(0.3))


func _draw_region_heading(
	world_position: Vector2, title: String, seal: String, color: Color
) -> void:
	var position: Vector2 = _world_to_screen(world_position)
	draw_circle(position, 30.0, Color(0.04, 0.05, 0.045, 0.86))
	draw_arc(position, 30.0, 0.0, TAU, 32, color, 4.0, true)
	draw_string(
		ThemeDB.fallback_font, position + Vector2(-18.0, 6.0), seal,
		HORIZONTAL_ALIGNMENT_CENTER, 36.0, 14, color
	)
	draw_string(
		ThemeDB.fallback_font, position + Vector2(42.0, 7.0), title,
		HORIZONTAL_ALIGNMENT_LEFT, -1.0, 19, Color(0.94, 0.9, 0.78)
	)


func _draw_world_rect(rect: Rect2, fill: Color, outline: Color, width: float) -> void:
	var screen_rect := Rect2(_world_to_screen(rect.position), rect.size * _zoom)
	draw_rect(screen_rect, fill, true)
	draw_rect(screen_rect, outline, false, width * _visual_scale())


func _draw_origin_seal(center: Vector2, house_id: StringName) -> void:
	var seal: String = _house_seal(house_id)
	draw_string(
		ThemeDB.fallback_font, center + Vector2(-13.0, 5.0), seal,
		HORIZONTAL_ALIGNMENT_CENTER, 26.0, 12, Color(0.95, 0.9, 0.76)
	)


func _draw_debug_node_label(center: Vector2, node_id: StringName) -> void:
	var label: String = "%s · %s" % [label_for_node(node_id), node_id]
	var label_rect := Rect2(center + Vector2(-72.0, 30.0), Vector2(144.0, 22.0))
	draw_rect(label_rect, Color(0.02, 0.025, 0.025, 0.82), true)
	draw_string(
		ThemeDB.fallback_font, label_rect.position + Vector2(4.0, 16.0), label,
		HORIZONTAL_ALIGNMENT_CENTER, 136.0, 11, Color(0.9, 0.94, 0.9)
	)


func _draw_tokens() -> void:
	if movement_session == null:
		return
	var occupants_by_node: Dictionary = {}
	for player: LootMovementPlayerState in movement_session.player_states:
		if not occupants_by_node.has(player.current_node_id):
			occupants_by_node[player.current_node_id] = []
		var occupants: Array = occupants_by_node[player.current_node_id]
		occupants.append(player.player_id)
	var token_colors: Array[Color] = [
		Color(0.3, 0.8, 1.0), Color(1.0, 0.42, 0.48),
		Color(0.5, 0.92, 0.5), Color(0.85, 0.62, 1.0), Color(1.0, 0.78, 0.28),
	]
	for player_index: int in range(movement_session.ordered_player_ids.size()):
		var player_id: StringName = movement_session.ordered_player_ids[player_index]
		var node_id: StringName = StringName(token_node_by_player.get(player_id, &""))
		if not _node_positions.has(node_id):
			continue
		var occupants: Array = occupants_by_node.get(node_id, [])
		var occupant_index: int = occupants.find(player_id)
		var offset: Vector2 = Vector2(-14.0 + float(occupant_index) * 14.0, -28.0)
		var center: Vector2 = _node_positions[node_id] + offset
		var active: bool = player_id == active_player_id
		var color: Color = token_colors[player_index % token_colors.size()]
		draw_circle(center + Vector2(1.0, 3.0), 16.0 if active else 13.0, Color(0.02, 0.025, 0.025, 0.72))
		draw_circle(center, 14.0 if active else 12.0, color)
		if active:
			draw_arc(center, 20.0, 0.0, TAU, 28, Color(1.0, 0.82, 0.28), 4.0, true)
		draw_string(ThemeDB.fallback_font, center + Vector2(-8.0, 5.0), "P%d" % (player_index + 1), HORIZONTAL_ALIGNMENT_CENTER, 16.0, 11, Color(0.04, 0.05, 0.08))


func _path_contains_edge(from_id: StringName, to_id: StringName) -> bool:
	for index: int in range(highlighted_path.size() - 1):
		if highlighted_path[index] == from_id and highlighted_path[index + 1] == to_id:
			return true
	return false


func _build_node_label(node: LootNodeDefinition) -> String:
	if not node.display_name.is_empty():
		return node.display_name
	match node.node_kind:
		&"ORIGIN_SPAWN":
			return "Nhà %s" % _house_letter(node.origin_house_id)
		&"HOUSE_PATH":
			return "Lối Nhà %s" % _house_letter(node.origin_house_id)
		&"CENTRAL_HUB":
			return "Đại sân Trung tâm"
		&"MIDDLE_PATH":
			return "Trung lộ"
		&"MAUSOLEUM_HUB":
			return "Lăng Miếu"
		&"FINAL_PATH":
			return "Hoàng lộ"
		&"END":
			return "Điểm kết thúc"
		_:
			return "Đường trong Hoàng Cung"


func _house_letter(house_id: StringName) -> String:
	match house_id:
		&"house_huyen":
			return "Huyền"
		&"house_kim":
			return "Kim"
		&"house_hoang":
			return "Hoàng"
		&"house_lam":
			return "Lam"
		&"house_chu":
			return "Chu"
	var value: String = String(house_id).to_upper()
	for letter: String in ["A", "B", "C", "D"]:
		if value.ends_with("_" + letter):
			return letter
	return "Hoàng"


func _node_color(node: LootNodeDefinition) -> Color:
	if node == null:
		return Color(0.3, 0.42, 0.38)
	if not node.origin_house_id.is_empty():
		return _house_color(node.origin_house_id)
	match node.node_kind:
		&"ORIGIN_SPAWN":
			return Color(0.22, 0.56, 0.82)
		&"END":
			return Color(0.75, 0.5, 0.18)
		&"CENTRAL_HUB":
			return Color(0.62, 0.35, 0.72)
		&"MAUSOLEUM_HUB":
			return Color(0.74, 0.56, 0.24)
		&"MIDDLE_PATH":
			return Color(0.3, 0.62, 0.42)
		&"FINAL_PATH":
			return Color(0.64, 0.36, 0.25)
		_:
			return Color(0.38, 0.46, 0.4)


func _route_color(node: LootNodeDefinition) -> Color:
	if node != null and not node.origin_house_id.is_empty():
		return _house_color(node.origin_house_id).lightened(0.08)
	if node != null and &"POST_MAUSOLEUM" in node.tags:
		return Color(0.73, 0.43, 0.26, 0.98)
	if node != null and &"MIDDLE" in node.tags:
		return Color(0.45, 0.67, 0.44, 0.98)
	return Color(0.69, 0.58, 0.36, 0.96)


func _node_radius(node: LootNodeDefinition) -> float:
	if node == null:
		return NODE_RADIUS
	match node.node_kind:
		&"CENTRAL_HUB", &"MAUSOLEUM_HUB":
			return 36.0
		&"ORIGIN_SPAWN":
			return 25.0
		_:
			return NODE_RADIUS


func _house_color(house_id: StringName) -> Color:
	match house_id:
		&"house_hoang":
			return Color(0.76, 0.51, 0.16)
		&"house_chu":
			return Color(0.68, 0.25, 0.28)
		&"house_kim":
			return Color(0.18, 0.5, 0.55)
		&"house_huyen":
			return Color(0.36, 0.37, 0.68)
		&"house_lam":
			return Color(0.29, 0.57, 0.34)
		_:
			return Color(0.5, 0.5, 0.46)


func _house_seal(house_id: StringName) -> String:
	match house_id:
		&"house_hoang":
			return "I"
		&"house_chu":
			return "II"
		&"house_kim":
			return "III"
		&"house_huyen":
			return "IV"
		&"house_lam":
			return "V"
		_:
			return "·"


func world_bounds() -> Rect2:
	if map_definition == null or not _uses_authored_world_coordinates():
		return Rect2(Vector2.ZERO, size)
	var minimum := Vector2(INF, INF)
	var maximum := Vector2(-INF, -INF)
	for node: LootNodeDefinition in map_definition.nodes:
		if node == null:
			continue
		minimum.x = minf(minimum.x, node.world_position.x)
		minimum.y = minf(minimum.y, node.world_position.y)
		maximum.x = maxf(maximum.x, node.world_position.x)
		maximum.y = maxf(maximum.y, node.world_position.y)
	return Rect2(minimum, maximum - minimum)


func camera_center_bounds() -> Rect2:
	var bounds: Rect2 = framing_world_bounds()
	var half_view: Vector2 = visible_world_size() * 0.5
	var minimum := bounds.position + half_view
	var maximum := bounds.end - half_view
	if minimum.x > maximum.x:
		minimum.x = bounds.get_center().x
		maximum.x = minimum.x
	if minimum.y > maximum.y:
		minimum.y = bounds.get_center().y
		maximum.y = minimum.y
	return Rect2(minimum, maximum - minimum)


func framing_world_bounds() -> Rect2:
	return world_bounds().grow(CAMERA_WORLD_MARGIN)


func pan_camera(direction: Vector2, delta: float) -> void:
	if not _uses_authored_world_coordinates() or direction == Vector2.ZERO:
		return
	_camera_center += direction.normalized() * CAMERA_PAN_SPEED * maxf(delta, 0.0)
	_clamp_camera()
	_build_positions()
	queue_redraw()


func apply_wheel_zoom(button_index: int) -> bool:
	return apply_wheel_zoom_at(button_index, size * 0.5)


func apply_wheel_zoom_at(button_index: int, screen_position: Vector2) -> bool:
	if not _uses_authored_world_coordinates():
		return false
	if button_index == MOUSE_BUTTON_WHEEL_UP:
		return _set_zoom_at(_zoom + CAMERA_ZOOM_STEP, screen_position)
	if button_index == MOUSE_BUTTON_WHEEL_DOWN:
		return _set_zoom_at(_zoom - CAMERA_ZOOM_STEP, screen_position)
	return false


func begin_pointer_drag(screen_position: Vector2) -> void:
	_drag_press_held = true
	_drag_active = false
	_drag_start_screen_position = screen_position
	_drag_last_screen_position = screen_position


func update_pointer_drag(screen_position: Vector2) -> bool:
	if not _drag_press_held or not _uses_authored_world_coordinates():
		return false
	if not _drag_active:
		if screen_position.distance_to(_drag_start_screen_position) < CAMERA_DRAG_THRESHOLD:
			return false
		_drag_active = true
	var screen_delta: Vector2 = screen_position - _drag_last_screen_position
	_drag_last_screen_position = screen_position
	if screen_delta == Vector2.ZERO:
		return true
	_camera_center -= screen_delta / maxf(_zoom, 0.01)
	_clamp_camera()
	_build_positions()
	queue_redraw()
	return true


func end_pointer_drag() -> bool:
	var was_dragging: bool = _drag_active
	_clear_drag_state()
	return was_dragging


func pointer_drag_active() -> bool:
	return _drag_active


func edge_pan_available() -> bool:
	return not _drag_active


func drag_threshold() -> float:
	return CAMERA_DRAG_THRESHOLD


func zoom_level() -> float:
	return _zoom


func minimum_zoom() -> float:
	if not _uses_authored_world_coordinates() or size.x <= 0.0 or size.y <= 0.0:
		return CAMERA_DEFAULT_ZOOM
	var framed_bounds: Rect2 = framing_world_bounds()
	if framed_bounds.size.x <= 0.0 or framed_bounds.size.y <= 0.0:
		return CAMERA_DEFAULT_ZOOM
	var available := Vector2(
		maxf(size.x - CAMERA_FIT_SCREEN_MARGIN * 2.0, 1.0),
		maxf(size.y - CAMERA_FIT_SCREEN_MARGIN * 2.0, 1.0)
	)
	return clampf(
		minf(
			available.x / framed_bounds.size.x,
			available.y / framed_bounds.size.y
		),
		0.01,
		CAMERA_DEFAULT_ZOOM
	)


func maximum_zoom() -> float:
	return CAMERA_MAX_ZOOM


func visible_world_size() -> Vector2:
	return size / maxf(_zoom, 0.01)


func _set_zoom(requested_zoom: float) -> bool:
	return _set_zoom_at(requested_zoom, size * 0.5)


func _set_zoom_at(requested_zoom: float, screen_position: Vector2) -> bool:
	var next_zoom: float = clampf(requested_zoom, minimum_zoom(), CAMERA_MAX_ZOOM)
	if is_equal_approx(next_zoom, _zoom):
		return false
	var anchored_world_position: Vector2 = screen_to_world(screen_position)
	_zoom = next_zoom
	_camera_center = anchored_world_position - (screen_position - size * 0.5) / _zoom
	_clamp_camera()
	_build_positions()
	queue_redraw()
	return true


func _clamp_zoom() -> void:
	_zoom = clampf(_zoom, minimum_zoom(), CAMERA_MAX_ZOOM)


func focus_active_player() -> void:
	_clear_drag_state()
	if movement_session == null or not _uses_authored_world_coordinates():
		return
	var player: LootMovementPlayerState = movement_session.current_player()
	if player == null:
		return
	var node: LootNodeDefinition = map_definition.find_node(player.current_node_id)
	if node == null:
		return
	_camera_center = node.world_position
	_camera_initialized = true
	_clamp_camera()
	_build_positions()
	queue_redraw()


func camera_center() -> Vector2:
	return _camera_center


func node_screen_position(node_id: StringName) -> Vector2:
	return Vector2(_node_positions.get(node_id, Vector2.ZERO))


func screen_to_world(screen_position: Vector2) -> Vector2:
	return _camera_center + (screen_position - size * 0.5) / maxf(_zoom, 0.01)


static func edge_pan_direction_for_position(
	mouse_position: Vector2, viewport_size: Vector2, threshold: float
) -> Vector2:
	var direction := Vector2.ZERO
	if mouse_position.x >= 0.0 and mouse_position.x <= threshold:
		direction.x = -1.0
	elif mouse_position.x <= viewport_size.x and mouse_position.x >= viewport_size.x - threshold:
		direction.x = 1.0
	if mouse_position.y >= 0.0 and mouse_position.y <= threshold:
		direction.y = -1.0
	elif mouse_position.y <= viewport_size.y and mouse_position.y >= viewport_size.y - threshold:
		direction.y = 1.0
	return direction.normalized()


func _uses_authored_world_coordinates() -> bool:
	if map_definition == null or map_definition.nodes.is_empty():
		return false
	for node: LootNodeDefinition in map_definition.nodes:
		if node == null or node.world_position == Vector2.ZERO:
			return false
	return true


func _world_to_screen(world_position: Vector2) -> Vector2:
	return (world_position - _camera_center) * _zoom + size * 0.5


func _viewport_to_local(viewport_position: Vector2) -> Vector2:
	return get_global_transform_with_canvas().affine_inverse() * viewport_position


func _clear_drag_state() -> void:
	_drag_press_held = false
	_drag_active = false


func _visual_scale() -> float:
	return clampf(_zoom, 0.45, CAMERA_MAX_ZOOM)


func _clamp_camera() -> void:
	var bounds: Rect2 = camera_center_bounds()
	_camera_center.x = clampf(_camera_center.x, bounds.position.x, bounds.end.x)
	_camera_center.y = clampf(_camera_center.y, bounds.position.y, bounds.end.y)
