class_name PendingBranchState
extends RefCounted

var active := false
var player_id: StringName = &""
var fork_node_id: StringName = &""
var available_branch_ids: Array[StringName] = []
var remaining_steps := 0
var traversed_node_ids: Array[StringName] = []
var roll_distance := 0
var start_node_id: StringName = &""


func to_dict() -> Dictionary:
	var branches: Array[String] = []
	for id: StringName in available_branch_ids:
		branches.append(String(id))
	var traversed: Array[String] = []
	for id: StringName in traversed_node_ids:
		traversed.append(String(id))
	return {
		"active": active,
		"player_id": String(player_id),
		"fork_node_id": String(fork_node_id),
		"available_branch_ids": branches,
		"remaining_steps": remaining_steps,
		"traversed_node_ids": traversed,
		"roll_distance": roll_distance,
		"start_node_id": String(start_node_id),
	}


static func from_dict(data: Dictionary) -> PendingBranchState:
	var state := PendingBranchState.new()
	state.active = bool(data.get("active", false))
	state.player_id = StringName(data.get("player_id", ""))
	state.fork_node_id = StringName(data.get("fork_node_id", ""))
	state.remaining_steps = int(data.get("remaining_steps", 0))
	state.roll_distance = int(data.get("roll_distance", 0))
	state.start_node_id = StringName(data.get("start_node_id", ""))
	var branches_val: Variant = data.get("available_branch_ids", [])
	if branches_val is Array:
		for b: Variant in branches_val:
			state.available_branch_ids.append(StringName(b))
	var trav_val: Variant = data.get("traversed_node_ids", [])
	if trav_val is Array:
		for t: Variant in trav_val:
			state.traversed_node_ids.append(StringName(t))
	return state
