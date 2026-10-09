class_name PlayerPhaseState
extends RefCounted

var schema_version := 1
var player_id: StringName
var seat_index := 0
var character_id: StringName
var merit_progress := 0.0
var reputation := 5
var orb_count := 0
var gacha_ticket_count := 0
var silver_coin_count := 0
var equipment_exp_material_count := 0
var relic_exp_material_count := 0
var stigmata_exp_material_count := 0
var equipment_exchange_material_count := 0
# Persistent/shop inventory. Round map loot is owned by RoundLootInventoryState.
var consumable_inventory: Array[Dictionary] = []
var equipment_collection: Array[EquipmentInstance] = []
var relic_instance_id: StringName
var stigmata_a_instance_id: StringName
var stigmata_b_instance_id: StringName
var stigmata_c_instance_id: StringName
# Legacy prototype mirrors only. LootMovementPlayerState is authoritative for
# movement-round position, allowance, and temporary effects.
var current_node_id: StringName
var remaining_moves := 0
var temporary_effects: Array[TemporaryEffectState] = []
var round_id: StringName
var phase_id: StringName = &"LOOT_FOUNDATION_M1"
var reward_snapshots: Array[RewardNodeSnapshot] = []
var gacha_state := GachaState.new()


func to_persistent_dict() -> Dictionary:
	var equipment_rows: Array[Dictionary] = []
	for instance in equipment_collection:
		equipment_rows.append(instance.to_dict())
	return {
		"schema_version": schema_version,
		"player_id": String(player_id), "seat_index": seat_index, "character_id": String(character_id),
		"merit_progress": merit_progress, "reputation": reputation,
		"orb_count": orb_count, "gacha_ticket_count": gacha_ticket_count, "silver_coin_count": silver_coin_count,
		"equipment_exp_material_count": equipment_exp_material_count,
		"relic_exp_material_count": relic_exp_material_count,
		"stigmata_exp_material_count": stigmata_exp_material_count,
		"equipment_exchange_material_count": equipment_exchange_material_count,
		"consumable_inventory": consumable_inventory.duplicate(true), "equipment_collection": equipment_rows,
		"relic_instance_id": String(relic_instance_id), "stigmata_a_instance_id": String(stigmata_a_instance_id),
		"stigmata_b_instance_id": String(stigmata_b_instance_id), "stigmata_c_instance_id": String(stigmata_c_instance_id),
		"gacha_state": gacha_state.to_dict(),
	}


static func from_persistent_dict(data: Dictionary) -> PlayerPhaseState:
	var state := PlayerPhaseState.new()
	state.schema_version = int(data.get("schema_version", 1))
	state.player_id = StringName(data.get("player_id", "")); state.seat_index = int(data.get("seat_index", 0)); state.character_id = StringName(data.get("character_id", ""))
	state.merit_progress = float(data.get("merit_progress", 0.0)); state.reputation = int(data.get("reputation", 5))
	state.orb_count = int(data.get("orb_count", 0)); state.gacha_ticket_count = int(data.get("gacha_ticket_count", 0)); state.silver_coin_count = int(data.get("silver_coin_count", 0))
	state.equipment_exp_material_count = int(data.get("equipment_exp_material_count", 0))
	state.relic_exp_material_count = int(data.get("relic_exp_material_count", state.equipment_exp_material_count))
	state.stigmata_exp_material_count = int(data.get("stigmata_exp_material_count", state.equipment_exp_material_count))
	state.equipment_exchange_material_count = int(data.get("equipment_exchange_material_count", 0))
	var inventory_value: Variant = data.get("consumable_inventory", [])
	if inventory_value is Array:
		state.consumable_inventory.assign(inventory_value)
	var equipment_value: Variant = data.get("equipment_collection", [])
	if equipment_value is Array:
		for row: Variant in equipment_value:
			if row is Dictionary:
				state.equipment_collection.append(EquipmentInstance.from_dict(row))
	state.relic_instance_id = StringName(data.get("relic_instance_id", "")); state.stigmata_a_instance_id = StringName(data.get("stigmata_a_instance_id", "")); state.stigmata_b_instance_id = StringName(data.get("stigmata_b_instance_id", "")); state.stigmata_c_instance_id = StringName(data.get("stigmata_c_instance_id", ""))
	var gacha_value: Variant = data.get("gacha_state", {})
	if gacha_value is Dictionary:
		state.gacha_state = GachaState.from_dict(gacha_value)
	return state


func reset_round_local_compatibility_fields() -> void:
	current_node_id = &""
	remaining_moves = 0
	temporary_effects.clear()
	round_id = &""
	phase_id = &""
	reward_snapshots.clear()


func to_dict() -> Dictionary:
	var equipment_rows: Array[Dictionary] = []
	for instance in equipment_collection:
		equipment_rows.append(instance.to_dict())
	var effect_rows: Array[Dictionary] = []
	for effect in temporary_effects:
		effect_rows.append(effect.to_dict())
	var reward_rows: Array[Dictionary] = []
	for snapshot in reward_snapshots:
		reward_rows.append(snapshot.to_dict())
	return {
		"schema_version": schema_version,
		"player_id": String(player_id), "seat_index": seat_index, "character_id": String(character_id),
		"merit_progress": merit_progress, "reputation": reputation,
		"orb_count": orb_count, "gacha_ticket_count": gacha_ticket_count, "silver_coin_count": silver_coin_count,
		"equipment_exp_material_count": equipment_exp_material_count,
		"relic_exp_material_count": relic_exp_material_count,
		"stigmata_exp_material_count": stigmata_exp_material_count,
		"equipment_exchange_material_count": equipment_exchange_material_count,
		"consumable_inventory": consumable_inventory.duplicate(true), "equipment_collection": equipment_rows,
		"relic_instance_id": String(relic_instance_id), "stigmata_a_instance_id": String(stigmata_a_instance_id),
		"stigmata_b_instance_id": String(stigmata_b_instance_id), "stigmata_c_instance_id": String(stigmata_c_instance_id),
		"current_node_id": String(current_node_id), "remaining_moves": remaining_moves,
		"temporary_effects": effect_rows, "round_id": String(round_id), "phase_id": String(phase_id),
		"reward_snapshots": reward_rows, "gacha_state": gacha_state.to_dict(),
	}


static func from_dict(data: Dictionary) -> PlayerPhaseState:
	var state := PlayerPhaseState.new()
	state.schema_version = int(data.get("schema_version", 1))
	state.player_id = StringName(data.get("player_id", "")); state.seat_index = int(data.get("seat_index", 0)); state.character_id = StringName(data.get("character_id", ""))
	state.merit_progress = float(data.get("merit_progress", 0.0)); state.reputation = int(data.get("reputation", 5))
	state.orb_count = int(data.get("orb_count", 0)); state.gacha_ticket_count = int(data.get("gacha_ticket_count", 0)); state.silver_coin_count = int(data.get("silver_coin_count", 0))
	state.equipment_exp_material_count = int(data.get("equipment_exp_material_count", 0))
	state.relic_exp_material_count = int(data.get("relic_exp_material_count", state.equipment_exp_material_count))
	state.stigmata_exp_material_count = int(data.get("stigmata_exp_material_count", state.equipment_exp_material_count))
	state.equipment_exchange_material_count = int(data.get("equipment_exchange_material_count", 0))
	var inventory_value: Variant = data.get("consumable_inventory", [])
	if inventory_value is Array:
		state.consumable_inventory.assign(inventory_value)
	var equipment_value: Variant = data.get("equipment_collection", [])
	if equipment_value is Array:
		for row: Variant in equipment_value:
			if row is Dictionary:
				state.equipment_collection.append(EquipmentInstance.from_dict(row))
	state.relic_instance_id = StringName(data.get("relic_instance_id", "")); state.stigmata_a_instance_id = StringName(data.get("stigmata_a_instance_id", "")); state.stigmata_b_instance_id = StringName(data.get("stigmata_b_instance_id", "")); state.stigmata_c_instance_id = StringName(data.get("stigmata_c_instance_id", ""))
	state.current_node_id = StringName(data.get("current_node_id", "")); state.remaining_moves = int(data.get("remaining_moves", 0)); state.round_id = StringName(data.get("round_id", "")); state.phase_id = StringName(data.get("phase_id", ""))
	var effects_value: Variant = data.get("temporary_effects", [])
	if effects_value is Array:
		for row: Variant in effects_value:
			if row is Dictionary:
				state.temporary_effects.append(TemporaryEffectState.from_dict(row))
	var rewards_value: Variant = data.get("reward_snapshots", [])
	if rewards_value is Array:
		for row: Variant in rewards_value:
			if row is Dictionary:
				state.reward_snapshots.append(RewardNodeSnapshot.from_dict(row))
	var gacha_value: Variant = data.get("gacha_state", {})
	if gacha_value is Dictionary:
		state.gacha_state = GachaState.from_dict(gacha_value)
	return state


func get_exp_material_count(eq_type: EquipmentEnums.EquipmentType) -> int:
	if eq_type == EquipmentEnums.EquipmentType.RELIC:
		if relic_exp_material_count > 0 or stigmata_exp_material_count > 0:
			return relic_exp_material_count
		return equipment_exp_material_count
	else:
		if relic_exp_material_count > 0 or stigmata_exp_material_count > 0:
			return stigmata_exp_material_count
		return equipment_exp_material_count


func spend_exp_material(eq_type: EquipmentEnums.EquipmentType, amount: int) -> bool:
	if amount <= 0:
		return true
	if eq_type == EquipmentEnums.EquipmentType.RELIC:
		if relic_exp_material_count >= amount:
			relic_exp_material_count -= amount
			return true
		elif equipment_exp_material_count >= amount:
			equipment_exp_material_count -= amount
			return true
	else:
		if stigmata_exp_material_count >= amount:
			stigmata_exp_material_count -= amount
			return true
		elif equipment_exp_material_count >= amount:
			equipment_exp_material_count -= amount
			return true
	return false


func semantically_equals(other: PlayerPhaseState) -> bool:
	return other != null and to_dict() == other.to_dict()
