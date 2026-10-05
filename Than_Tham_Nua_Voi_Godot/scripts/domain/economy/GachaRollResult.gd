class_name GachaRollResult
extends RefCounted

var success := false
var code: StringName
var banner_id: StringName
var banner_type: StringName
var player_id: StringName
var ticket_cost := 0
var result_category: StringName
var equipment_definition_id: StringName
var resource_amount := 0
var pity_before := 0
var pity_after := 0
var exchange_material_delta := 0
var acquisition_source: StringName
var perfect_entry_id: StringName

func to_dict() -> Dictionary:
	return {"success":success,"code":String(code),"banner_id":String(banner_id),"banner_type":String(banner_type),"player_id":String(player_id),"ticket_cost":ticket_cost,"result_category":String(result_category),"equipment_definition_id":String(equipment_definition_id),"resource_amount":resource_amount,"pity_before":pity_before,"pity_after":pity_after,"exchange_material_delta":exchange_material_delta,"acquisition_source":String(acquisition_source),"perfect_entry_id":String(perfect_entry_id)}
