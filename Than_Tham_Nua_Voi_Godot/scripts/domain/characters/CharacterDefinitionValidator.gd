class_name CharacterDefinitionValidator
extends RefCounted

func validate(character: CharacterDefinition) -> LootValidationReport:
	var report := LootValidationReport.new()
	if character == null:
		report.add_error(&"CHARACTER_NULL", "Character is required")
		return report
	if character.character_id.is_empty(): report.add_error(&"CHARACTER_ID_EMPTY", "character_id is required", "CharacterDefinition")
	if character.origin_house_id.is_empty(): report.add_error(&"ORIGIN_HOUSE_EMPTY", "origin_house_id is required", String(character.character_id))
	if character.base_speed < 1: report.add_error(&"SPEED_BELOW_ONE", "base_speed must be >= 1", String(character.character_id))
	if character.base_stamina < 0: report.add_error(&"STAMINA_NEGATIVE", "base_stamina must be >= 0", String(character.character_id))
	if character.base_bag_level < 0: report.add_error(&"BAG_LEVEL_NEGATIVE", "base_bag_level must be >= 0", String(character.character_id))
	if character.active_orb_requirement < 0: report.add_error(&"ORB_REQUIREMENT_NEGATIVE", "active_orb_requirement must be >= 0", String(character.character_id))
	return report
