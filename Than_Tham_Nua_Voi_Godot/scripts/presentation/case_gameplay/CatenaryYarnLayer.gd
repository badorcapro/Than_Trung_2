class_name CatenaryYarnLayer
extends Node2D

## Interactive Catenary2D yarn string connection layer for detective board.
## Simulates physical Verlet yarn sag between suspect card pushpins.

signal yarn_connected(from_id: int, to_id: int)
signal yarn_disconnected(from_id: int, to_id: int)

const DEFAULT_SEGMENT_COUNT := 24
const DEFAULT_CONSTRAINT_RUNS := 15
const DEFAULT_SNAP_DISTANCE := 50.0
const DEFAULT_GRAVITY := Vector2(0.0, 50.0)
const DEFAULT_DAMPING := 0.98
const YARN_COLOR := Color(0.82, 0.18, 0.15, 0.95)
const YARN_SHADOW_COLOR := Color(0.0, 0.0, 0.0, 0.30)
const YARN_WIDTH := 2.5
const YARN_SHADOW_OFFSET := Vector2(2.0, 3.5)

class YarnConnection:
	var from_id: int
	var to_id: int
	var start_pos: Vector2
	var end_pos: Vector2
	var segments: Array[Vector2] = []
	var old_segments: Array[Vector2] = []
	var segment_length: float = 0.0

var _connections: Array[YarnConnection] = []
var _pin_positions_by_id: Dictionary = {}
var _is_dragging := false
var _drag_from_id := -1
var _drag_current_pos := Vector2.ZERO


func register_pin_position(suspect_id: int, global_pos: Vector2) -> void:
	_pin_positions_by_id[suspect_id] = to_local(global_pos)
	_update_connection_endpoints()


func unregister_pin_position(suspect_id: int) -> void:
	_pin_positions_by_id.erase(suspect_id)
	remove_connections_for(suspect_id)


func get_pin_position(suspect_id: int) -> Vector2:
	return _pin_positions_by_id.get(suspect_id, Vector2.ZERO)


func has_pin(suspect_id: int) -> bool:
	return _pin_positions_by_id.has(suspect_id)


func start_dragging_from(suspect_id: int) -> void:
	if not _pin_positions_by_id.has(suspect_id):
		return
	_is_dragging = true
	_drag_from_id = suspect_id
	_drag_current_pos = _pin_positions_by_id[suspect_id]
	queue_redraw()


func update_drag_position(global_pos: Vector2) -> void:
	if not _is_dragging:
		return
	_drag_current_pos = to_local(global_pos)
	queue_redraw()


func finish_dragging(global_pos: Vector2) -> int:
	if not _is_dragging:
		return -1
	var local_pos := to_local(global_pos)
	var target_id := find_nearest_pin(local_pos, DEFAULT_SNAP_DISTANCE)
	var from_id := _drag_from_id
	_is_dragging = false
	_drag_from_id = -1
	queue_redraw()

	if target_id >= 0 and target_id != from_id:
		add_connection(from_id, target_id)
		return target_id
	return -1


func cancel_dragging() -> void:
	_is_dragging = false
	_drag_from_id = -1
	queue_redraw()


func is_dragging() -> bool:
	return _is_dragging


func get_drag_from_id() -> int:
	return _drag_from_id


func find_nearest_pin(local_pos: Vector2, max_dist: float = DEFAULT_SNAP_DISTANCE) -> int:
	var best_id := -1
	var best_dist := max_dist
	for id in _pin_positions_by_id.keys():
		var pin_pos: Vector2 = _pin_positions_by_id[id]
		var dist := local_pos.distance_to(pin_pos)
		if dist <= best_dist:
			best_dist = dist
			best_id = int(id)
	return best_id


func add_connection(from_id: int, to_id: int) -> bool:
	if from_id == to_id:
		return false
	if not _pin_positions_by_id.has(from_id) or not _pin_positions_by_id.has(to_id):
		return false
	if has_connection(from_id, to_id):
		return false

	var start_p: Vector2 = _pin_positions_by_id[from_id]
	var end_p: Vector2 = _pin_positions_by_id[to_id]
	var total_dist := start_p.distance_to(end_p)
	if total_dist < 1.0:
		return false

	var conn := YarnConnection.new()
	conn.from_id = from_id
	conn.to_id = to_id
	conn.start_pos = start_p
	conn.end_pos = end_p
	conn.segment_length = (total_dist * 1.08) / float(DEFAULT_SEGMENT_COUNT - 1)

	for i in range(DEFAULT_SEGMENT_COUNT):
		var t := float(i) / float(DEFAULT_SEGMENT_COUNT - 1)
		var p := start_p.lerp(end_p, t)
		conn.segments.append(p)
		conn.old_segments.append(p)

	_connections.append(conn)
	yarn_connected.emit(from_id, to_id)
	queue_redraw()
	return true


func remove_connection(from_id: int, to_id: int) -> bool:
	for i in range(_connections.size() - 1, -1, -1):
		var conn: YarnConnection = _connections[i]
		if (conn.from_id == from_id and conn.to_id == to_id) or (conn.from_id == to_id and conn.to_id == from_id):
			_connections.remove_at(i)
			yarn_disconnected.emit(from_id, to_id)
			queue_redraw()
			return true
	return false


func remove_connections_for(suspect_id: int) -> void:
	for i in range(_connections.size() - 1, -1, -1):
		var conn: YarnConnection = _connections[i]
		if conn.from_id == suspect_id or conn.to_id == suspect_id:
			var other_id: int = conn.to_id if conn.from_id == suspect_id else conn.from_id
			_connections.remove_at(i)
			yarn_disconnected.emit(suspect_id, other_id)
	queue_redraw()


func clear_all() -> void:
	_connections.clear()
	_is_dragging = false
	_drag_from_id = -1
	queue_redraw()


func has_connection(a_id: int, b_id: int) -> bool:
	for conn in _connections:
		if (conn.from_id == a_id and conn.to_id == b_id) or (conn.from_id == b_id and conn.to_id == a_id):
			return true
	return false


func get_connection_count() -> int:
	return _connections.size()


func get_connections() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for conn in _connections:
		result.append({"from_id": conn.from_id, "to_id": conn.to_id})
	return result


func _process(delta: float) -> void:
	if _connections.is_empty() and not _is_dragging:
		return
	var dt := clampf(delta, 0.005, 0.05)
	for conn in _connections:
		_step_verlet(conn, dt)
	queue_redraw()


func _step_verlet(conn: YarnConnection, dt: float) -> void:
	var count := conn.segments.size()
	if count < 2:
		return

	for i in range(count):
		var velocity := (conn.segments[i] - conn.old_segments[i]) * DEFAULT_DAMPING
		conn.old_segments[i] = conn.segments[i]
		conn.segments[i] += velocity + (DEFAULT_GRAVITY * dt)

	for _step in range(DEFAULT_CONSTRAINT_RUNS):
		conn.segments[0] = conn.start_pos
		conn.segments[count - 1] = conn.end_pos

		for i in range(count - 1):
			var diff := conn.segments[i] - conn.segments[i + 1]
			var dist := diff.length()
			if dist < 1e-4:
				continue
			var error := dist - conn.segment_length
			var offset := diff.normalized() * (error * 0.5)

			if i != 0 and i != count - 2:
				conn.segments[i] -= offset
				conn.segments[i + 1] += offset
			elif i == 0:
				conn.segments[i + 1] += offset * 2.0
			else:
				conn.segments[i] -= offset * 2.0

		conn.segments[0] = conn.start_pos
		conn.segments[count - 1] = conn.end_pos


func _update_connection_endpoints() -> void:
	for conn in _connections:
		if _pin_positions_by_id.has(conn.from_id):
			conn.start_pos = _pin_positions_by_id[conn.from_id]
		if _pin_positions_by_id.has(conn.to_id):
			conn.end_pos = _pin_positions_by_id[conn.to_id]


func _draw() -> void:
	for conn in _connections:
		if conn.segments.size() >= 2:
			_draw_curve(conn.segments, YARN_SHADOW_COLOR, YARN_WIDTH + 1.0, YARN_SHADOW_OFFSET)
			_draw_curve(conn.segments, YARN_COLOR, YARN_WIDTH, Vector2.ZERO)

	if _is_dragging and _pin_positions_by_id.has(_drag_from_id):
		var start_p: Vector2 = _pin_positions_by_id[_drag_from_id]
		var drag_points: Array[Vector2] = [start_p, _drag_current_pos]
		_draw_curve(drag_points, YARN_SHADOW_COLOR, YARN_WIDTH + 1.0, YARN_SHADOW_OFFSET)
		_draw_curve(drag_points, YARN_COLOR, YARN_WIDTH, Vector2.ZERO)


func _draw_curve(points: Array[Vector2], color: Color, width: float, offset: Vector2) -> void:
	if points.size() < 2:
		return
	var offset_points := PackedVector2Array()
	offset_points.resize(points.size())
	for i in range(points.size()):
		offset_points[i] = points[i] + offset
	draw_polyline(offset_points, color, width, true)
