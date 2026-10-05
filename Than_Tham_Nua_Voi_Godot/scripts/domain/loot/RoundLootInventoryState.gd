class_name RoundLootInventoryState
extends RefCounted

var player_id: StringName
var capacity := 0
var carried_items: Array[Dictionary] = []
var disposition_finalized := false
var transferred_items: Array[Dictionary] = []


func to_dict() -> Dictionary:
	return {
		"player_id": String(player_id),
		"capacity": capacity,
		"carried_items": carried_items.duplicate(true),
		"disposition_finalized": disposition_finalized,
		"transferred_items": transferred_items.duplicate(true),
	}


static func from_dict(data: Dictionary) -> RoundLootInventoryState:
	var state := RoundLootInventoryState.new()
	state.player_id = StringName(data.get("player_id", ""))
	state.capacity = int(data.get("capacity", 0))
	state.disposition_finalized = bool(data.get("disposition_finalized", false))
	var items_value: Variant = data.get("carried_items", [])
	if items_value is Array:
		state.carried_items.assign(items_value)
	var transferred_value: Variant = data.get("transferred_items", [])
	if transferred_value is Array:
		state.transferred_items.assign(transferred_value)
	return state
