class_name MovementActionResult
extends RefCounted

var player_id: StringName
var roll_distance := 0
var start_node_id: StringName
var traversed_node_ids: Array[StringName] = []
var end_node_id: StringName
var movement_consumed := false
var turn_number := 0
var remaining_moves_after := 0
var truncated_by_end_of_path := false


func to_dict() -> Dictionary:
	var path: Array[String] = []
	for node_id: StringName in traversed_node_ids:
		path.append(String(node_id))
	return {
		"player_id": String(player_id), "roll_distance": roll_distance,
		"start_node_id": String(start_node_id), "traversed_node_ids": path,
		"end_node_id": String(end_node_id), "movement_consumed": movement_consumed,
		"turn_number": turn_number, "remaining_moves_after": remaining_moves_after,
		"truncated_by_end_of_path": truncated_by_end_of_path,
	}


static func from_dict(data: Dictionary) -> MovementActionResult:
	var result := MovementActionResult.new()
	result.player_id = StringName(data.get("player_id", ""))
	result.roll_distance = int(data.get("roll_distance", 0))
	result.start_node_id = StringName(data.get("start_node_id", ""))
	var path_value: Variant = data.get("traversed_node_ids", [])
	if path_value is Array:
		for node_value: Variant in path_value:
			result.traversed_node_ids.append(StringName(node_value))
	result.end_node_id = StringName(data.get("end_node_id", ""))
	result.movement_consumed = bool(data.get("movement_consumed", false))
	result.turn_number = int(data.get("turn_number", 0))
	result.remaining_moves_after = int(data.get("remaining_moves_after", 0))
	result.truncated_by_end_of_path = bool(data.get("truncated_by_end_of_path", false))
	return result
