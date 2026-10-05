class_name GachaState
extends RefCounted

var consecutive_without_a_plus := 0
var rate_up_state_by_banner: Dictionary = {}
var equipment_exchange_price_by_definition: Dictionary = {}
var ss_unlocked_equipment_ids: Array[StringName] = []
var ss_purchase_count_by_definition: Dictionary = {}
var perfect_pool_remaining_hits: Dictionary = {}
var perfect_weight_config_id: StringName
var rate_up_consecutive_without_a_plus := 0

func to_dict() -> Dictionary:
	var unlocked: Array[String] = []
	for id in ss_unlocked_equipment_ids: unlocked.append(String(id))
	return {"consecutive_without_a_plus":consecutive_without_a_plus, "rate_up_consecutive_without_a_plus":rate_up_consecutive_without_a_plus, "rate_up_state_by_banner":_normalized_int_dictionary(rate_up_state_by_banner), "equipment_exchange_price_by_definition":_normalized_int_dictionary(equipment_exchange_price_by_definition), "ss_unlocked_equipment_ids":unlocked, "ss_purchase_count_by_definition":_normalized_int_dictionary(ss_purchase_count_by_definition), "perfect_pool_remaining_hits":_normalized_int_dictionary(perfect_pool_remaining_hits), "perfect_weight_config_id":String(perfect_weight_config_id)}

static func from_dict(data: Dictionary) -> GachaState:
	var result := GachaState.new()
	result.consecutive_without_a_plus = int(data.get("consecutive_without_a_plus", 0))
	result.rate_up_consecutive_without_a_plus = int(data.get("rate_up_consecutive_without_a_plus", 0))
	var rate_up_value: Variant = data.get("rate_up_state_by_banner", {})
	if rate_up_value is Dictionary: result.rate_up_state_by_banner = _normalized_int_dictionary(rate_up_value)
	var exchange_value: Variant = data.get("equipment_exchange_price_by_definition", {})
	if exchange_value is Dictionary: result.equipment_exchange_price_by_definition = _normalized_int_dictionary(exchange_value)
	var unlocked_value: Variant = data.get("ss_unlocked_equipment_ids", [])
	if unlocked_value is Array:
		for id: Variant in unlocked_value: result.ss_unlocked_equipment_ids.append(StringName(id))
	var ss_purchase_value: Variant = data.get("ss_purchase_count_by_definition", {})
	if ss_purchase_value is Dictionary: result.ss_purchase_count_by_definition = _normalized_int_dictionary(ss_purchase_value)
	var perfect_pool_value: Variant = data.get("perfect_pool_remaining_hits", {})
	if perfect_pool_value is Dictionary: result.perfect_pool_remaining_hits = _normalized_int_dictionary(perfect_pool_value)
	result.perfect_weight_config_id = StringName(data.get("perfect_weight_config_id", ""))
	return result

static func _normalized_int_dictionary(source: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key: Variant in source.keys():
		result[String(key)] = int(source.get(key, 0))
	return result
