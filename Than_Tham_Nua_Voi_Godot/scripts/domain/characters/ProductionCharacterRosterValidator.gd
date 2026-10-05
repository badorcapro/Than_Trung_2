class_name ProductionCharacterRosterValidator
extends RefCounted

const HOUSE_REPOSITORY := preload(
	"res://scripts/application/houses/ProductionHouseRepository.gd"
)


func validate(characters: Array[CharacterDefinition]) -> LootValidationReport:
	var report: LootValidationReport = LootValidationReport.new()
	var houses: Array[HouseDefinition] = HOUSE_REPOSITORY.load_all()
	if characters.size() != houses.size():
		report.add_error(
			&"PRODUCTION_CHARACTER_COUNT_INVALID",
			"Production roster must contain exactly one Character per canonical House"
		)
	var canonical_house_ids: Array[StringName] = []
	for house: HouseDefinition in houses:
		canonical_house_ids.append(house.house_id)
	var character_ids: Dictionary = {}
	var represented_houses: Dictionary = {}
	for index: int in range(characters.size()):
		var character: CharacterDefinition = characters[index]
		report.merge(CharacterDefinitionValidator.new().validate(character))
		if character == null:
			continue
		if character.display_name.is_empty():
			report.add_error(
				&"PRODUCTION_CHARACTER_NAME_EMPTY",
				"Production Character display_name is required",
				String(character.character_id)
			)
		if character.test_only_not_canon_locked:
			report.add_error(
				&"PRODUCTION_CHARACTER_MARKED_TEST_ONLY",
				"Production Character must not be marked TEST_ONLY",
				String(character.character_id)
			)
		if character_ids.has(character.character_id):
			report.add_error(
				&"PRODUCTION_CHARACTER_ID_DUPLICATE",
				"Production Character IDs must be unique",
				String(character.character_id)
			)
		character_ids[character.character_id] = true
		if not canonical_house_ids.has(character.origin_house_id):
			report.add_error(
				&"PRODUCTION_CHARACTER_HOUSE_UNKNOWN",
				"Production Character must reference a canonical House",
				String(character.character_id)
			)
		elif represented_houses.has(character.origin_house_id):
			report.add_error(
				&"PRODUCTION_CHARACTER_HOUSE_DUPLICATE",
				"Only one production Character may represent each House",
				String(character.origin_house_id)
			)
		represented_houses[character.origin_house_id] = true
		if index < canonical_house_ids.size() and character.origin_house_id != canonical_house_ids[index]:
			report.add_error(
				&"PRODUCTION_CHARACTER_ORDER_INVALID",
				"Production roster must follow canonical House display order",
				String(character.character_id)
			)
	for house_id: StringName in canonical_house_ids:
		if not represented_houses.has(house_id):
			report.add_error(
				&"PRODUCTION_CHARACTER_HOUSE_MISSING",
				"Every canonical House requires one production Character",
				String(house_id)
			)
	return report
