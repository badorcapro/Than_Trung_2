class_name BagOverflowState
extends RefCounted

var active := false
var player_id: StringName
var incoming_item_id: StringName
var node_id: StringName

func to_dict() -> Dictionary:
	return {"active":active, "player_id":String(player_id), "incoming_item_id":String(incoming_item_id), "node_id":String(node_id)}

static func from_dict(data: Dictionary) -> BagOverflowState:
	var state := BagOverflowState.new()
	state.active = bool(data.get("active", false)); state.player_id = StringName(data.get("player_id", "")); state.incoming_item_id = StringName(data.get("incoming_item_id", "")); state.node_id = StringName(data.get("node_id", ""))
	return state
