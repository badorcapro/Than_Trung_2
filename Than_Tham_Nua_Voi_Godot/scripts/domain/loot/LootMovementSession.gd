class_name LootMovementSession
extends RefCounted

enum Phase { MOVEMENT_ACTIVE, LOOT_END_CONFIRMATION_READY }

var schema_version := 1
var phase := Phase.MOVEMENT_ACTIVE
var round_id: StringName
var ordered_player_ids: Array[StringName] = []
var current_turn_index := 0
var turn_number := 0
var player_states: Array[LootMovementPlayerState] = []
var movement_history: Array[MovementActionResult] = []
var pending_branch: PendingBranchState = PendingBranchState.new()
var started := false
var completed := false


func current_player() -> LootMovementPlayerState:
	if player_states.is_empty() or current_turn_index < 0 or current_turn_index >= player_states.size():
		return null
	return player_states[current_turn_index]


func all_exhausted() -> bool:
	for player: LootMovementPlayerState in player_states:
		if player.remaining_moves > 0:
			return false
	return not player_states.is_empty()


func to_dict() -> Dictionary:
	var order: Array[String] = []
	for player_id: StringName in ordered_player_ids:
		order.append(String(player_id))
	var players: Array[Dictionary] = []
	for player: LootMovementPlayerState in player_states:
		players.append(player.to_dict())
	var history: Array[Dictionary] = []
	for action: MovementActionResult in movement_history:
		history.append(action.to_dict())
	return {
		"schema_version": schema_version, "phase": phase, "round_id": String(round_id),
		"ordered_player_ids": order, "current_turn_index": current_turn_index,
		"turn_number": turn_number, "player_states": players,
		"movement_history": history, "pending_branch": pending_branch.to_dict(),
		"started": started, "completed": completed,
	}


static func from_dict(data: Dictionary) -> LootMovementSession:
	var session := LootMovementSession.new()
	session.schema_version = int(data.get("schema_version", 1))
	session.phase = int(data.get("phase", Phase.MOVEMENT_ACTIVE))
	session.round_id = StringName(data.get("round_id", ""))
	var order_value: Variant = data.get("ordered_player_ids", [])
	if order_value is Array:
		for player_id_value: Variant in order_value:
			session.ordered_player_ids.append(StringName(player_id_value))
	session.current_turn_index = int(data.get("current_turn_index", 0))
	session.turn_number = int(data.get("turn_number", 0))
	var players_value: Variant = data.get("player_states", [])
	if players_value is Array:
		for player_value: Variant in players_value:
			if player_value is Dictionary:
				session.player_states.append(LootMovementPlayerState.from_dict(player_value))
	var history_value: Variant = data.get("movement_history", [])
	if history_value is Array:
		for action_value: Variant in history_value:
			if action_value is Dictionary:
				session.movement_history.append(MovementActionResult.from_dict(action_value))
	var branch_value: Variant = data.get("pending_branch", {})
	if branch_value is Dictionary:
		session.pending_branch = PendingBranchState.from_dict(branch_value)
	session.started = bool(data.get("started", false))
	session.completed = bool(data.get("completed", false))
	return session


func semantically_equals(other: LootMovementSession) -> bool:
	return other != null and to_dict() == other.to_dict()
