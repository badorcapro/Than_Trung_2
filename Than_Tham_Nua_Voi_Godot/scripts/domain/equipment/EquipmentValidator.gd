class_name EquipmentValidator
extends RefCounted

func validate(instance: EquipmentInstance) -> LootValidationReport:
	var report := LootValidationReport.new()
	if instance == null:
		report.add_error(&"EQUIPMENT_NULL", "Equipment instance is required")
		return report
	if instance.instance_id.is_empty(): report.add_error(&"INSTANCE_ID_EMPTY", "instance_id is required")
	if instance.equipment_definition_id.is_empty(): report.add_error(&"EQUIPMENT_DEFINITION_ID_EMPTY", "definition ID is required", String(instance.instance_id))
	if instance.equipment_type < EquipmentEnums.EquipmentType.RELIC or instance.equipment_type > EquipmentEnums.EquipmentType.STIGMATA: report.add_error(&"EQUIPMENT_TYPE_INVALID", "Invalid equipment type")
	if instance.stigmata_slot < EquipmentEnums.StigmataSlot.NONE or instance.stigmata_slot > EquipmentEnums.StigmataSlot.C: report.add_error(&"STIGMATA_SLOT_INVALID", "Invalid stigmata slot")
	if instance.tier < EquipmentEnums.Tier.A or instance.tier > EquipmentEnums.Tier.SS: report.add_error(&"EQUIPMENT_TIER_INVALID", "Invalid equipment tier")
	if instance.gold_star_level < 0 or instance.gold_star_level > 6: report.add_error(&"GOLD_STAR_OUT_OF_RANGE", "Gold must be 0..6")
	if instance.purple_star_level < 0 or instance.purple_star_level > 6: report.add_error(&"PURPLE_STAR_OUT_OF_RANGE", "Purple must be 0..6")
	if instance.purple_star_level > instance.gold_star_level: report.add_error(&"PURPLE_EXCEEDS_GOLD", "Purple cannot exceed Gold")
	if instance.equipment_type == EquipmentEnums.EquipmentType.RELIC and instance.stigmata_slot != EquipmentEnums.StigmataSlot.NONE: report.add_error(&"RELIC_SLOT_INVALID", "Relic must use NONE slot")
	if instance.equipment_type == EquipmentEnums.EquipmentType.STIGMATA and instance.stigmata_slot == EquipmentEnums.StigmataSlot.NONE: report.add_error(&"STIGMATA_SLOT_REQUIRED", "Stigmata must use A/B/C")
	return report
