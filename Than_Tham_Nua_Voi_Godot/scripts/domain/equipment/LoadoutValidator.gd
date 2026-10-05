class_name LoadoutValidator
extends RefCounted

func validate(collection: Array[EquipmentInstance], loadout: LoadoutState) -> LootValidationReport:
	var report := LootValidationReport.new()
	var by_id: Dictionary = {}
	for instance in collection:
		report.merge(EquipmentValidator.new().validate(instance))
		if instance != null and not instance.instance_id.is_empty(): by_id[instance.instance_id] = instance
	if loadout == null:
		report.add_error(&"LOADOUT_NULL", "Loadout is required")
		return report
	var seen: Dictionary = {}
	var expected_slots: Array[int] = [EquipmentEnums.StigmataSlot.NONE, EquipmentEnums.StigmataSlot.A, EquipmentEnums.StigmataSlot.B, EquipmentEnums.StigmataSlot.C]
	var ids: Array[StringName] = loadout.all_instance_ids()
	var referenced_relic_count := 0
	for index in range(ids.size()):
		var id: StringName = ids[index]
		if id.is_empty(): continue
		if seen.has(id): report.add_error(&"INSTANCE_EQUIPPED_MULTIPLE_SLOTS", "Same instance used by multiple slots", String(id)); continue
		seen[id] = true
		if not by_id.has(id): report.add_error(&"LOADOUT_INSTANCE_MISSING", "Loadout reference not found", String(id)); continue
		var instance_value: Variant = by_id.get(id)
		var instance: EquipmentInstance = instance_value as EquipmentInstance
		if instance.equipment_type == EquipmentEnums.EquipmentType.RELIC: referenced_relic_count += 1
		if index == 0 and instance.equipment_type != EquipmentEnums.EquipmentType.RELIC: report.add_error(&"RELIC_LOADOUT_TYPE_INVALID", "Relic slot requires RELIC", String(id))
		if index > 0 and (instance.equipment_type != EquipmentEnums.EquipmentType.STIGMATA or instance.stigmata_slot != expected_slots[index]): report.add_error(&"STIGMATA_LOADOUT_SLOT_MISMATCH", "Stigmata slot mismatch", String(id))
	if referenced_relic_count > 1: report.add_error(&"MULTIPLE_RELICS_EQUIPPED", "Only one Relic may be equipped")
	return report
