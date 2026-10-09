class_name EquipmentInstance
extends Resource

@export var instance_id: StringName
@export var equipment_definition_id: StringName
@export var owner_player_id: StringName
@export var acquired_source: StringName
@export var equipment_type: EquipmentEnums.EquipmentType = EquipmentEnums.EquipmentType.RELIC
@export var stigmata_slot: EquipmentEnums.StigmataSlot = EquipmentEnums.StigmataSlot.NONE
@export var tier: EquipmentEnums.Tier = EquipmentEnums.Tier.A
@export_range(0, 6, 1) var gold_star_level := 0
@export_range(0, 6, 1) var purple_star_level := 0
@export var test_only_not_canon_locked := true

func to_dict() -> Dictionary:
	return {"instance_id":String(instance_id), "equipment_definition_id":String(equipment_definition_id), "owner_player_id":String(owner_player_id), "acquired_source":String(acquired_source), "equipment_type":equipment_type, "stigmata_slot":stigmata_slot, "tier":tier, "gold_star_level":gold_star_level, "purple_star_level":purple_star_level}

static func from_dict(data: Dictionary) -> EquipmentInstance:
	var result := EquipmentInstance.new()
	result.instance_id = StringName(data.get("instance_id", "")); result.equipment_definition_id = StringName(data.get("equipment_definition_id", ""))
	result.owner_player_id = StringName(data.get("owner_player_id", "")); result.acquired_source = StringName(data.get("acquired_source", ""))
	result.equipment_type = int(data.get("equipment_type", 0)); result.stigmata_slot = int(data.get("stigmata_slot", 0)); result.tier = int(data.get("tier", 0))
	result.gold_star_level = int(data.get("gold_star_level", 0)); result.purple_star_level = int(data.get("purple_star_level", 0))
	return result
