class_name LootMovementPlayerState
extends RefCounted

var player_id: StringName
var character_id: StringName
var origin_house_id: StringName
var current_node_id: StringName
var speed_snapshot := 1
var stamina_snapshot := 0
var remaining_moves := 0
var temporary_effects: Array[TemporaryEffectState] = []


func to_dict() -> Dictionary:
	var effect_rows: Array[Dictionary] = []
	for effect: TemporaryEffectState in temporary_effects:
		effect_rows.append(effect.to_dict())
	return {
		"player_id": String(player_id), "character_id": String(character_id),
		"origin_house_id": String(origin_house_id), "current_node_id": String(current_node_id),
		"speed_snapshot": speed_snapshot, "stamina_snapshot": stamina_snapshot,
		"remaining_moves": remaining_moves,
		"temporary_effects": effect_rows,
	}


static func from_dict(data: Dictionary) -> LootMovementPlayerState:
	var state := LootMovementPlayerState.new()
	state.player_id = StringName(data.get("player_id", ""))
	state.character_id = StringName(data.get("character_id", ""))
	state.origin_house_id = StringName(data.get("origin_house_id", ""))
	state.current_node_id = StringName(data.get("current_node_id", ""))
	state.speed_snapshot = int(data.get("speed_snapshot", 1))
	state.stamina_snapshot = int(data.get("stamina_snapshot", 0))
	state.remaining_moves = int(data.get("remaining_moves", 0))
	var effects_value: Variant = data.get("temporary_effects", [])
	if effects_value is Array:
		for row: Variant in effects_value:
			if row is Dictionary:
				state.temporary_effects.append(TemporaryEffectState.from_dict(row))
	return state
