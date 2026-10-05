class_name M5ContentValidator
extends RefCounted

func validate(definitions:Array[EquipmentDefinition],config:GachaConfig,entries:Array[PerfectPoolEntry])->LootValidationReport:
	var report:=LootValidationReport.new();var ids:Dictionary={}
	for definition:EquipmentDefinition in definitions:
		if definition.equipment_definition_id.is_empty():report.add_error(&"DEFINITION_ID_EMPTY","Equipment definition id required")
		if ids.has(definition.equipment_definition_id):report.add_error(&"DEFINITION_ID_DUPLICATE","Duplicate Equipment definition",String(definition.equipment_definition_id))
		ids[definition.equipment_definition_id]=true
		if definition.gold_stat_rows.size()!=6:report.add_error(&"GOLD_ROWS_INVALID","Exactly six authored rows required",String(definition.equipment_definition_id))
		if definition.gold_upgrade_costs.size()!=5:report.add_error(&"GOLD_COSTS_INVALID","Exactly five authored costs required",String(definition.equipment_definition_id))
		if definition.equipment_type==EquipmentEnums.EquipmentType.RELIC and definition.stigmata_slot!=EquipmentEnums.StigmataSlot.NONE:report.add_error(&"RELIC_SLOT_INVALID","Relic requires NONE",String(definition.equipment_definition_id))
		if definition.equipment_type==EquipmentEnums.EquipmentType.STIGMATA and definition.stigmata_slot==EquipmentEnums.StigmataSlot.NONE:report.add_error(&"STIGMATA_SLOT_INVALID","Stigmata requires A/B/C",String(definition.equipment_definition_id))
	if _sum(config.basic_rates)!=100:report.add_error(&"BASIC_RATE_TOTAL","Basic rates must total 100")
	if _sum(config.rate_up_rates)!=100:report.add_error(&"RATE_UP_RATE_TOTAL","Rate Up rates must total 100")
	if _sum(config.featured_s_split)!=100:report.add_error(&"FEATURED_SPLIT_TOTAL","Featured split must total 100")
	var total_hits:=0;var core_relic:=0;var core_stigmata:=0;var core_s:=0
	for entry:PerfectPoolEntry in entries:
		if entry.weight<=0:report.add_error(&"PERFECT_WEIGHT_INVALID","Weight must be positive",String(entry.entry_id))
		if entry.initial_hits<0:report.add_error(&"PERFECT_HITS_NEGATIVE","Hits cannot be negative",String(entry.entry_id))
		total_hits+=entry.initial_hits
		if entry.kind==PerfectPoolEntry.Kind.SS_RELIC:core_relic+=entry.initial_hits
		elif entry.kind==PerfectPoolEntry.Kind.SS_STIGMATA_CHOICE:core_stigmata+=entry.initial_hits
		elif entry.kind==PerfectPoolEntry.Kind.S_EQUIPMENT_CHOICE:core_s+=entry.initial_hits
	if total_hits!=25:report.add_error(&"PERFECT_TOTAL_INVALID","Perfect pool must have 25 charges")
	if core_relic!=1 or core_stigmata!=3 or core_s!=1:report.add_error(&"PERFECT_CORE_INVALID","Core must be 1 + 3 + 1")
	return report
func _sum(values:Dictionary)->int:
	var total:=0
	for value:Variant in values.values():total+=int(value)
	return total
