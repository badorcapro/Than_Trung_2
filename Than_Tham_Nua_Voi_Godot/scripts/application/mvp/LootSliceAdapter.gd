class_name LootSliceAdapter
extends RefCounted

const PLAYER_MATCH_STATE := preload("res://scripts/domain/mvp/PlayerMatchState.gd")


func project_player(player: PLAYER_MATCH_STATE, round_id: StringName) -> PlayerPhaseState:
	var result := PlayerPhaseState.new()
	result.player_id = player.player_id
	result.seat_index = player.seat_index
	result.character_id = player.character_id
	result.merit_progress = player.merit_progress
	result.reputation = player.reputation
	result.orb_count = player.orb_count
	result.gacha_ticket_count = player.gacha_ticket_count
	result.silver_coin_count = player.silver_coin_count
	result.equipment_exp_material_count = player.equipment_exp_material_count
	result.equipment_exchange_material_count = player.equipment_exchange_material_count
	result.consumable_inventory = player.consumable_inventory.duplicate(true)
	result.equipment_collection = _clone_equipment(player.equipment_collection)
	result.relic_instance_id = player.relic_instance_id
	result.stigmata_a_instance_id = player.stigmata_a_instance_id
	result.stigmata_b_instance_id = player.stigmata_b_instance_id
	result.stigmata_c_instance_id = player.stigmata_c_instance_id
	result.gacha_state = GachaState.from_dict(player.gacha_state.to_dict())
	# Compatibility context only; movement authority is created separately by LootMovementService.
	result.round_id = round_id
	result.phase_id = &"MVP_LOOT_PROJECTION_M1"
	return result


func merge_player(target: PLAYER_MATCH_STATE, source: PlayerPhaseState) -> Dictionary:
	if target == null or source == null or target.player_id != source.player_id:
		return {"success": false, "code": "LOOT_MERGE_IDENTITY_MISMATCH"}
	for instance: EquipmentInstance in source.equipment_collection:
		if instance == null or instance.owner_player_id != target.player_id:
			return {"success": false, "code": "LOOT_MERGE_EQUIPMENT_OWNER"}
	target.orb_count = source.orb_count
	target.gacha_ticket_count = source.gacha_ticket_count
	target.silver_coin_count = source.silver_coin_count
	target.equipment_exp_material_count = source.equipment_exp_material_count
	target.equipment_exchange_material_count = source.equipment_exchange_material_count
	target.consumable_inventory = source.consumable_inventory.duplicate(true)
	target.equipment_collection = _clone_equipment(source.equipment_collection)
	target.relic_instance_id = source.relic_instance_id
	target.stigmata_a_instance_id = source.stigmata_a_instance_id
	target.stigmata_b_instance_id = source.stigmata_b_instance_id
	target.stigmata_c_instance_id = source.stigmata_c_instance_id
	target.gacha_state = GachaState.from_dict(source.gacha_state.to_dict())
	return {
		"success": true,
		"code": "LOOT_PERSISTENT_STATE_MERGED",
		"ignored_transient": true,
	}


func _clone_equipment(source: Array[EquipmentInstance]) -> Array[EquipmentInstance]:
	var result: Array[EquipmentInstance] = []
	for instance: EquipmentInstance in source:
		result.append(EquipmentInstance.from_dict(instance.to_dict()))
	return result
