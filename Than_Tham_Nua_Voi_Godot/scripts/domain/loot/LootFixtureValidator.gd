class_name LootFixtureValidator
extends RefCounted

func validate(characters: Array[CharacterDefinition], map_definition: LootMapDefinition, players: Array[PlayerPhaseState]) -> LootValidationReport:
	var report := LootValidationReport.new()
	if players.size() < 1 or players.size() > 4: report.add_error(&"PLAYER_COUNT_INVALID", "M1 fixture requires 1..4 players")
	var character_ids: Dictionary = {}
	for character in characters:
		report.merge(CharacterDefinitionValidator.new().validate(character))
		if character != null:
			if character_ids.has(character.character_id): report.add_error(&"DUPLICATE_CHARACTER_ID", "Duplicate character ID", String(character.character_id))
			character_ids[character.character_id] = true
	var required_houses: Array[StringName] = []
	for character in characters:
		if character != null and not required_houses.has(character.origin_house_id): required_houses.append(character.origin_house_id)
	report.merge(LootMapValidator.new().validate(map_definition, required_houses))
	for player in players:
		report.merge(PlayerPhaseStateValidator.new().validate(player))
		if player != null and not character_ids.has(player.character_id): report.add_error(&"PLAYER_CHARACTER_NOT_FOUND", "Player references unknown character", String(player.character_id))
	return report
