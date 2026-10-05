class_name ProductionConsumableRepository
extends RefCounted

const ITEM_PATHS: Array[String] = [
	"res://content/consumables/production/consumable_hanh_lo_phu.tres",
	"res://content/consumables/production/consumable_lenh_bai_thong_hanh.tres",
	"res://content/consumables/production/consumable_ngu_ma_lenh.tres",
]


static func load_all() -> Array[ConsumableItemDefinition]:
	var result: Array[ConsumableItemDefinition] = []
	for path: String in ITEM_PATHS:
		var definition: ConsumableItemDefinition = load(path) as ConsumableItemDefinition
		if definition != null:
			result.append(definition)
	return result


static func find_item(
	definitions: Array[ConsumableItemDefinition], item_id: StringName
) -> ConsumableItemDefinition:
	for definition: ConsumableItemDefinition in definitions:
		if definition != null and definition.item_id == item_id:
			return definition
	return null
