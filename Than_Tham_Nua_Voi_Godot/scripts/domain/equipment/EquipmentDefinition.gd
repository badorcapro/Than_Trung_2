class_name EquipmentDefinition
extends Resource

@export var equipment_definition_id: StringName
@export var display_name := ""
@export var equipment_type: EquipmentEnums.EquipmentType = EquipmentEnums.EquipmentType.RELIC
@export var stigmata_slot: EquipmentEnums.StigmataSlot = EquipmentEnums.StigmataSlot.NONE
@export var tier: EquipmentEnums.Tier = EquipmentEnums.Tier.A
@export var set_id: StringName
@export var gold_stat_rows: Array[Dictionary] = []
@export var gold_upgrade_costs: Array[int] = []
@export var skill_marker: StringName
@export var test_only_not_canon_locked := true

func stat_row(gold_level: int) -> Dictionary:
	if gold_level < 1 or gold_level > gold_stat_rows.size(): return {}
	return gold_stat_rows[gold_level - 1].duplicate(true)

func gold_cost(from_level: int) -> int:
	if from_level < 1 or from_level > gold_upgrade_costs.size(): return -1
	return gold_upgrade_costs[from_level - 1]
