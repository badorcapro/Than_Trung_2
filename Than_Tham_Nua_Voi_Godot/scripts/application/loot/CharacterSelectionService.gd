class_name CharacterSelectionService
extends RefCounted

const TEST_ONLY_STARTING_REPUTATION: int = 5


func configure_player_count(session: CharacterSelectionSession, player_count: int, allow_duplicates: bool = true) -> LootValidationReport:
	var report: LootValidationReport = LootValidationReport.new()
	if session == null:
		report.add_error(&"SELECTION_SESSION_NULL", "Selection session is required")
		return report
	if player_count < 1 or player_count > 4:
		report.add_error(&"PLAYER_COUNT_OUT_OF_RANGE", "player_count must be 1..4")
		return report
	session.player_count = player_count
	session.current_seat_index = 0
	session.phase = CharacterSelectionSession.Phase.SELECTING
	session.allow_duplicate_characters = allow_duplicates
	session.duplicate_policy_test_only_not_canon_locked = allow_duplicates
	session.selected_character_ids.clear()
	session.locked_seats.clear()
	for _seat_index: int in range(player_count):
		session.selected_character_ids.append(&"")
		session.locked_seats.append(false)
	session.committed_players.clear()
	session.commit_count = 0
	return report


func select_character(session: CharacterSelectionSession, character_id: StringName, characters: Array[CharacterDefinition]) -> LootValidationReport:
	var report: LootValidationReport = LootValidationReport.new()
	if session == null or session.phase != CharacterSelectionSession.Phase.SELECTING:
		report.add_error(&"SELECTION_PHASE_INVALID", "Character can only be selected during SELECTING")
		return report
	if character_id.is_empty() or _find_character(character_id, characters) == null:
		report.add_error(&"CHARACTER_REFERENCE_UNKNOWN", "Selected Character does not exist", String(character_id))
		return report
	if not session.allow_duplicate_characters:
		for seat_index: int in range(session.player_count):
			if seat_index != session.current_seat_index and session.locked_seats[seat_index] and session.selected_character_ids[seat_index] == character_id:
				report.add_error(&"DUPLICATE_CHARACTER_DISALLOWED", "Duplicate Character violates configured prototype policy", String(character_id))
				return report
	session.selected_character_ids[session.current_seat_index] = character_id
	return report


func lock_current_selection(session: CharacterSelectionSession, characters: Array[CharacterDefinition]) -> LootValidationReport:
	var report: LootValidationReport = LootValidationReport.new()
	if session == null or session.phase != CharacterSelectionSession.Phase.SELECTING:
		report.add_error(&"SELECTION_PHASE_INVALID", "Selection can only lock during SELECTING")
		return report
	var selected_id: StringName = session.selected_character_ids[session.current_seat_index]
	if selected_id.is_empty() or _find_character(selected_id, characters) == null:
		report.add_error(&"CHARACTER_SELECTION_MISSING", "Choose a valid Character before locking")
		return report
	session.locked_seats[session.current_seat_index] = true
	if session.current_seat_index + 1 >= session.player_count:
		session.phase = CharacterSelectionSession.Phase.SUMMARY
	else:
		session.current_seat_index += 1
		session.phase = CharacterSelectionSession.Phase.PASS_DEVICE
	return report


func continue_after_pass_device(session: CharacterSelectionSession) -> LootValidationReport:
	var report: LootValidationReport = LootValidationReport.new()
	if session == null or session.phase != CharacterSelectionSession.Phase.PASS_DEVICE:
		report.add_error(&"PASS_DEVICE_PHASE_INVALID", "Continue requires PASS_DEVICE phase")
		return report
	session.phase = CharacterSelectionSession.Phase.SELECTING
	return report


func edit_seat(session: CharacterSelectionSession, seat_index: int) -> LootValidationReport:
	var report: LootValidationReport = LootValidationReport.new()
	if session == null or seat_index < 0 or seat_index >= session.player_count:
		report.add_error(&"SEAT_OUT_OF_RANGE", "Seat is outside session range", str(seat_index))
		return report
	session.clear_committed_snapshot()
	session.current_seat_index = seat_index
	session.locked_seats[seat_index] = false
	session.phase = CharacterSelectionSession.Phase.SELECTING
	return report


func finalize_selection(session: CharacterSelectionSession, characters: Array[CharacterDefinition]) -> LootValidationReport:
	var validator: CharacterSelectionValidator = CharacterSelectionValidator.new()
	var report: LootValidationReport = validator.validate(session, characters, true)
	if not report.is_valid: return report
	if session.commit_count > 0:
		report.add_error(&"SELECTION_ALREADY_COMMITTED", "Selection snapshot may only commit once")
		return report
	var players: Array[PlayerPhaseState] = []
	for seat_index: int in range(session.player_count):
		var state: PlayerPhaseState = PlayerPhaseState.new()
		state.player_id = StringName("local_player_%d" % (seat_index + 1))
		state.seat_index = seat_index
		state.character_id = session.selected_character_ids[seat_index]
		state.merit_progress = 0.0
		state.reputation = TEST_ONLY_STARTING_REPUTATION
		# Compatibility projection only. LootMovementService authors the round state.
		state.current_node_id = &""
		state.remaining_moves = 0
		state.round_id = &""
		state.phase_id = &"READY_FOR_LOOT_M3"
		players.append(state)
	report.merge(validator.validate_players(session, players, characters))
	if not report.is_valid: return report
	session.committed_players = players
	session.commit_count = 1
	session.phase = CharacterSelectionSession.Phase.READY_FOR_LOOT_M3
	return report


func _find_character(character_id: StringName, characters: Array[CharacterDefinition]) -> CharacterDefinition:
	for character: CharacterDefinition in characters:
		if character != null and character.character_id == character_id: return character
	return null
