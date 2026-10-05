class_name PlayerMatchState
extends RefCounted

const PERSISTENT_MARK_STATE := preload("res://scripts/domain/mvp/PersistentMarkState.gd")
const MVP_SEMANTIC_VALUE := preload("res://scripts/domain/mvp/MvpSemanticValue.gd")

var schema_version := 1
var player_id: StringName
var seat_index := 0
var display_name := ""
var character_id: StringName
var merit_progress := 0.0
var reputation := 5
var persistent_marks: Array[PERSISTENT_MARK_STATE] = []
var orb_count := 0
var gacha_ticket_count := 0
var silver_coin_count := 0
var equipment_exp_material_count := 0
var equipment_exchange_material_count := 0
var consumable_inventory: Array[Dictionary] = []
var equipment_collection: Array[EquipmentInstance] = []
var relic_instance_id: StringName
var stigmata_a_instance_id: StringName
var stigmata_b_instance_id: StringName
var stigmata_c_instance_id: StringName
var gacha_state := GachaState.new()


func to_dict() -> Dictionary:
	var mark_rows: Array[Dictionary] = []
	for mark: PERSISTENT_MARK_STATE in persistent_marks:
		mark_rows.append(mark.to_dict())
	var equipment_rows: Array[Dictionary] = []
	for instance: EquipmentInstance in equipment_collection:
		equipment_rows.append(instance.to_dict())
	return {
		"schema_version": schema_version,
		"player_id": String(player_id),
		"seat_index": seat_index,
		"display_name": display_name,
		"character_id": String(character_id),
		"merit_progress": merit_progress,
		"reputation": reputation,
		"persistent_marks": mark_rows,
		"orb_count": orb_count,
		"gacha_ticket_count": gacha_ticket_count,
		"silver_coin_count": silver_coin_count,
		"equipment_exp_material_count": equipment_exp_material_count,
		"equipment_exchange_material_count": equipment_exchange_material_count,
		"consumable_inventory": MVP_SEMANTIC_VALUE.normalize_dictionary_array(
			consumable_inventory
		),
		"equipment_collection": equipment_rows,
		"relic_instance_id": String(relic_instance_id),
		"stigmata_a_instance_id": String(stigmata_a_instance_id),
		"stigmata_b_instance_id": String(stigmata_b_instance_id),
		"stigmata_c_instance_id": String(stigmata_c_instance_id),
		"gacha_state": gacha_state.to_dict(),
	}


static func from_dict(data: Dictionary) -> PlayerMatchState:
	var result := PlayerMatchState.new()
	result.schema_version = int(data.get("schema_version", 1))
	result.player_id = StringName(data.get("player_id", ""))
	result.seat_index = int(data.get("seat_index", 0))
	result.display_name = String(data.get("display_name", ""))
	result.character_id = StringName(data.get("character_id", ""))
	result.merit_progress = float(data.get("merit_progress", 0.0))
	result.reputation = int(data.get("reputation", 5))
	result.orb_count = int(data.get("orb_count", 0))
	result.gacha_ticket_count = int(data.get("gacha_ticket_count", 0))
	result.silver_coin_count = int(data.get("silver_coin_count", 0))
	result.equipment_exp_material_count = int(data.get("equipment_exp_material_count", 0))
	result.equipment_exchange_material_count = int(
		data.get("equipment_exchange_material_count", 0)
	)
	var marks_value: Variant = data.get("persistent_marks", [])
	if marks_value is Array:
		for row: Variant in marks_value:
			if row is Dictionary:
				result.persistent_marks.append(PERSISTENT_MARK_STATE.from_dict(row))
	var inventory_value: Variant = data.get("consumable_inventory", [])
	result.consumable_inventory = MVP_SEMANTIC_VALUE.normalize_dictionary_array(
		inventory_value
	)
	var equipment_value: Variant = data.get("equipment_collection", [])
	if equipment_value is Array:
		for row: Variant in equipment_value:
			if row is Dictionary:
				result.equipment_collection.append(EquipmentInstance.from_dict(row))
	result.relic_instance_id = StringName(data.get("relic_instance_id", ""))
	result.stigmata_a_instance_id = StringName(data.get("stigmata_a_instance_id", ""))
	result.stigmata_b_instance_id = StringName(data.get("stigmata_b_instance_id", ""))
	result.stigmata_c_instance_id = StringName(data.get("stigmata_c_instance_id", ""))
	var gacha_value: Variant = data.get("gacha_state", {})
	if gacha_value is Dictionary:
		result.gacha_state = GachaState.from_dict(gacha_value)
	return result


func semantically_equals(other: PlayerMatchState) -> bool:
	return semantic_mismatches(other).is_empty()


func semantic_mismatches(other: PlayerMatchState) -> Array[String]:
	var mismatches: Array[String] = []
	if other == null:
		mismatches.append("player missing")
		return mismatches
	MVP_SEMANTIC_VALUE.collect_mismatches("", to_dict(), other.to_dict(), mismatches)
	var result: Array[String] = []
	for path: String in mismatches:
		result.append(path.trim_prefix("."))
	return result
