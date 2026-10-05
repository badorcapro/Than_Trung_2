class_name CharacterSelectionValidator
extends RefCounted


func validate(session: CharacterSelectionSession, characters: Array[CharacterDefinition], require_complete: bool = true) -> LootValidationReport:
	var report: LootValidationReport = LootValidationReport.new()
	if session == null:
		report.add_error(&"SELECTION_SESSION_NULL", "Selection session is required")
		return report
	if session.player_count < 1 or session.player_count > 4:
		report.add_error(&"PLAYER_COUNT_OUT_OF_RANGE", "player_count must be 1..4")
	var character_by_id: Dictionary = {}
	for character: CharacterDefinition in characters:
		if character != null and not character.character_id.is_empty(): character_by_id[character.character_id] = character
	if session.selected_character_ids.size() != session.player_count or session.locked_seats.size() != session.player_count:
		report.add_error(&"SELECTION_COUNT_MISMATCH", "Selection arrays must match player_count")
		return report
	var seen_character_ids: Dictionary = {}
	for seat_index: int in range(session.player_count):
		var character_id: StringName = session.selected_character_ids[seat_index]
		if character_id.is_empty():
			if require_complete: report.add_error(&"CHARACTER_SELECTION_MISSING", "Every seat must select a Character", "seat_%d" % seat_index)
			continue
		if not character_by_id.has(character_id):
			report.add_error(&"CHARACTER_REFERENCE_UNKNOWN", "Selected Character does not exist", String(character_id))
		if not session.allow_duplicate_characters and seen_character_ids.has(character_id):
			report.add_error(&"DUPLICATE_CHARACTER_DISALLOWED", "Duplicate Character violates configured prototype policy", String(character_id))
		seen_character_ids[character_id] = true
		if require_complete and not session.locked_seats[seat_index]:
			report.add_error(&"SELECTION_NOT_LOCKED", "Every selection must be locked", "seat_%d" % seat_index)
	if require_complete and not session.is_complete():
		report.add_error(&"SELECTION_INCOMPLETE", "Cannot finalize an incomplete selection")
	return report


func validate_players(session: CharacterSelectionSession, players: Array[PlayerPhaseState], characters: Array[CharacterDefinition]) -> LootValidationReport:
	var report: LootValidationReport = validate(session, characters, true)
	if players.size() != session.player_count:
		report.add_error(&"PLAYER_STATE_COUNT_MISMATCH", "PlayerPhaseState count must match player_count")
		return report
	var seen_player_ids: Dictionary = {}
	var seen_seats: Dictionary = {}
	for player: PlayerPhaseState in players:
		if player == null:
			report.add_error(&"PLAYER_STATE_NULL", "PlayerPhaseState is required")
			continue
		if player.player_id.is_empty(): report.add_error(&"PLAYER_ID_EMPTY", "player_id is required")
		elif seen_player_ids.has(player.player_id): report.add_error(&"DUPLICATE_PLAYER_ID", "player_id must be unique", String(player.player_id))
		seen_player_ids[player.player_id] = true
		if player.seat_index < 0 or player.seat_index >= session.player_count:
			report.add_error(&"SEAT_OUT_OF_RANGE", "seat_index must be inside session range", str(player.seat_index))
		elif seen_seats.has(player.seat_index):
			report.add_error(&"DUPLICATE_SEAT_INDEX", "seat_index must be unique", str(player.seat_index))
		seen_seats[player.seat_index] = true
		if player.character_id.is_empty(): report.add_error(&"PLAYER_CHARACTER_ID_EMPTY", "character_id is required")
		elif not session.selected_character_ids.has(player.character_id): report.add_error(&"PLAYER_CHARACTER_NOT_SELECTED", "Player Character is not in session selection", String(player.character_id))
		report.merge(PlayerPhaseStateValidator.new().validate(player))
	return report

