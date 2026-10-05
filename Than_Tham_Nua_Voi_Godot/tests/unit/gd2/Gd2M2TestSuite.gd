class_name Gd2M2TestSuite
extends RefCounted

var characters: Array[CharacterDefinition] = []
var service: CharacterSelectionService = CharacterSelectionService.new()
var validator: CharacterSelectionValidator = CharacterSelectionValidator.new()
var serializer: Gd2StateSerializer = Gd2StateSerializer.new()


func run() -> Array[Dictionary]:
	characters = Gd2FixtureRepository.load_selection_characters()
	var rows: Array[Dictionary] = []
	rows.append(_row("GĐ2-M2 scene loads", load("res://scenes/loot/Gd2M2CharacterSelection.tscn") is PackedScene))
	rows.append(_row("M2 TEST_ONLY roster has four Characters", characters.size() == 4 and characters[3].test_only_not_canon_locked))
	rows.append(_row("Player count zero fails", _configure_fails(0, &"PLAYER_COUNT_OUT_OF_RANGE")))
	rows.append(_row("Player count five fails", _configure_fails(5, &"PLAYER_COUNT_OUT_OF_RANGE")))
	rows.append(_row("Player count one passes", _configure_passes(1)))
	rows.append(_row("Player count four passes", _configure_passes(4)))
	rows.append(_row("Selection arrays match count", _selection_arrays_match_count()))
	rows.append(_row("Sequential seats validate", _final_report_valid(4)))
	rows.append(_row("Duplicate seat fails", _mutated_players_fail(&"DUPLICATE_SEAT_INDEX", true)))
	rows.append(_row("Out-of-range seat fails", _mutated_players_fail(&"SEAT_OUT_OF_RANGE", false)))
	rows.append(_row("Missing player ID fails", _missing_player_id_fails()))
	rows.append(_row("Missing Character selection fails", _incomplete_report_has(&"CHARACTER_SELECTION_MISSING")))
	rows.append(_row("Unknown Character reference fails", _unknown_character_fails()))
	rows.append(_row("Valid Character selection passes", _valid_select_passes()))
	rows.append(_row("Cannot finalize incomplete session", _incomplete_report_has(&"SELECTION_INCOMPLETE")))
	rows.append(_row("All selected finalize passes", _final_report_valid(3)))
	rows.append(_row("Edit selection then finalize passes", _edit_then_finalize_passes()))
	rows.append(_row("Final identity fields correct", _identity_fields_correct()))
	rows.append(_row("Starting resources are clean", _starting_resources_clean()))
	rows.append(_row("Bag and loadout start empty", _bag_and_loadout_empty()))
	rows.append(_row("Gacha state starts clean", _gacha_state_clean()))
	rows.append(_row("Loot pre-start fields are inactive", _loot_prestart_clean()))
	rows.append(_row("Final phase READY_FOR_LOOT_M3", _final_phase_ready()))
	rows.append(_row("One-player snapshot round-trips", _round_trip_passes(1)))
	rows.append(_row("Three-player snapshot round-trips", _round_trip_passes(3)))
	rows.append(_row("Four-player snapshot round-trips", _round_trip_passes(4)))
	rows.append(_row("Pass-device progresses every seat", _pass_device_progresses()))
	rows.append(_row("Final summary count matches", _finalized_player_count(4) == 4))
	rows.append(_row("Duplicate session commit rejected", _duplicate_commit_rejected()))
	rows.append(_row("Prototype duplicate policy can allow", _duplicate_policy_allows()))
	rows.append(_row("Configured duplicate restriction validates", _duplicate_policy_rejects()))
	rows.append(_row("Validation errors are structured", _structured_error_fields()))
	rows.append(_row("M2 snapshot contains no Node refs", _snapshot_has_no_node_refs()))
	rows.append(_row("M2 stops before movement gameplay", _loot_prestart_clean()))
	return rows


func _row(name: String, passed: bool) -> Dictionary:
	return {"name": name, "passed": passed, "detail": "GĐ2-M2 Character Selection invariant"}


func _configure_fails(count: int, code: StringName) -> bool:
	return _has_error(service.configure_player_count(CharacterSelectionSession.new(), count), code)


func _configure_passes(count: int) -> bool:
	var session: CharacterSelectionSession = CharacterSelectionSession.new()
	return service.configure_player_count(session, count).is_valid and session.player_count == count and session.phase == CharacterSelectionSession.Phase.SELECTING


func _selection_arrays_match_count() -> bool:
	var session: CharacterSelectionSession = CharacterSelectionSession.new()
	service.configure_player_count(session, 4)
	return session.selected_character_ids.size() == 4 and session.locked_seats.size() == 4


func _finalized_session(count: int, allow_duplicates: bool = true) -> Dictionary:
	var session: CharacterSelectionSession = CharacterSelectionSession.new()
	var configure_report: LootValidationReport = service.configure_player_count(session, count, allow_duplicates)
	if not configure_report.is_valid: return {"session": session, "report": configure_report}
	for seat_index: int in range(count):
		var character: CharacterDefinition = characters[seat_index % characters.size()]
		var select_report: LootValidationReport = service.select_character(session, character.character_id, characters)
		if not select_report.is_valid: return {"session": session, "report": select_report}
		var lock_report: LootValidationReport = service.lock_current_selection(session, characters)
		if not lock_report.is_valid: return {"session": session, "report": lock_report}
		if session.phase == CharacterSelectionSession.Phase.PASS_DEVICE:
			var continue_report: LootValidationReport = service.continue_after_pass_device(session)
			if not continue_report.is_valid: return {"session": session, "report": continue_report}
	var final_report: LootValidationReport = service.finalize_selection(session, characters)
	return {"session": session, "report": final_report}


func _final_report_valid(count: int) -> bool:
	var bundle: Dictionary = _finalized_session(count)
	var report: LootValidationReport = bundle.get("report") as LootValidationReport
	return report != null and report.is_valid


func _final_phase_ready() -> bool:
	var bundle: Dictionary = _finalized_session(1)
	var session: CharacterSelectionSession = bundle.get("session") as CharacterSelectionSession
	return session != null and session.phase == CharacterSelectionSession.Phase.READY_FOR_LOOT_M3


func _finalized_player_count(count: int) -> int:
	var bundle: Dictionary = _finalized_session(count)
	var session: CharacterSelectionSession = bundle.get("session") as CharacterSelectionSession
	return 0 if session == null else session.committed_players.size()


func _mutated_players_fail(code: StringName, duplicate: bool) -> bool:
	var bundle: Dictionary = _finalized_session(2)
	var session: CharacterSelectionSession = bundle.get("session") as CharacterSelectionSession
	var players: Array[PlayerPhaseState] = session.committed_players.duplicate()
	players[1].seat_index = 0 if duplicate else 2
	return _has_error(validator.validate_players(session, players, characters), code)


func _missing_player_id_fails() -> bool:
	var bundle: Dictionary = _finalized_session(1)
	var session: CharacterSelectionSession = bundle.get("session") as CharacterSelectionSession
	var players: Array[PlayerPhaseState] = session.committed_players.duplicate()
	players[0].player_id = &""
	return _has_error(validator.validate_players(session, players, characters), &"PLAYER_ID_EMPTY")


func _incomplete_report_has(code: StringName) -> bool:
	var session: CharacterSelectionSession = CharacterSelectionSession.new()
	service.configure_player_count(session, 2)
	return _has_error(service.finalize_selection(session, characters), code)


func _unknown_character_fails() -> bool:
	var session: CharacterSelectionSession = CharacterSelectionSession.new()
	service.configure_player_count(session, 1)
	return _has_error(service.select_character(session, &"missing_character", characters), &"CHARACTER_REFERENCE_UNKNOWN")


func _valid_select_passes() -> bool:
	var session: CharacterSelectionSession = CharacterSelectionSession.new()
	service.configure_player_count(session, 1)
	return service.select_character(session, characters[0].character_id, characters).is_valid


func _edit_then_finalize_passes() -> bool:
	var bundle: Dictionary = _finalized_session(3)
	var session: CharacterSelectionSession = bundle.get("session") as CharacterSelectionSession
	if not service.edit_seat(session, 2).is_valid: return false
	if not service.select_character(session, characters[3].character_id, characters).is_valid: return false
	if not service.lock_current_selection(session, characters).is_valid: return false
	return service.finalize_selection(session, characters).is_valid and session.committed_players[2].character_id == characters[3].character_id


func _identity_fields_correct() -> bool:
	var session: CharacterSelectionSession = (_finalized_session(3).get("session") as CharacterSelectionSession)
	for index: int in range(session.committed_players.size()):
		var player: PlayerPhaseState = session.committed_players[index]
		if player.player_id != StringName("local_player_%d" % (index + 1)) or player.seat_index != index or player.character_id != characters[index].character_id: return false
	return true


func _starting_resources_clean() -> bool:
	var player: PlayerPhaseState = (_finalized_session(1).get("session") as CharacterSelectionSession).committed_players[0]
	return player.merit_progress == 0.0 and player.orb_count == 0 and player.gacha_ticket_count == 0 and player.silver_coin_count == 0 and player.equipment_exp_material_count == 0 and player.equipment_exchange_material_count == 0


func _bag_and_loadout_empty() -> bool:
	var player: PlayerPhaseState = (_finalized_session(1).get("session") as CharacterSelectionSession).committed_players[0]
	return player.consumable_inventory.is_empty() and player.equipment_collection.is_empty() and player.relic_instance_id.is_empty() and player.stigmata_a_instance_id.is_empty() and player.stigmata_b_instance_id.is_empty() and player.stigmata_c_instance_id.is_empty()


func _gacha_state_clean() -> bool:
	var player: PlayerPhaseState = (_finalized_session(1).get("session") as CharacterSelectionSession).committed_players[0]
	return player.gacha_state != null and player.gacha_state.consecutive_without_a_plus == 0 and player.gacha_state.rate_up_state_by_banner.is_empty()


func _loot_prestart_clean() -> bool:
	var player: PlayerPhaseState = (_finalized_session(1).get("session") as CharacterSelectionSession).committed_players[0]
	return player.current_node_id.is_empty() and player.remaining_moves == 0 and player.temporary_effects.is_empty() and player.reward_snapshots.is_empty() and player.round_id.is_empty() and player.phase_id == &"READY_FOR_LOOT_M3"


func _round_trip_passes(count: int) -> bool:
	var session: CharacterSelectionSession = (_finalized_session(count).get("session") as CharacterSelectionSession)
	return serializer.players_round_trip_match(session.committed_players)


func _pass_device_progresses() -> bool:
	var session: CharacterSelectionSession = CharacterSelectionSession.new()
	service.configure_player_count(session, 3)
	for expected_seat: int in range(3):
		if session.current_seat_index != expected_seat: return false
		service.select_character(session, characters[expected_seat].character_id, characters)
		service.lock_current_selection(session, characters)
		if expected_seat < 2:
			if session.phase != CharacterSelectionSession.Phase.PASS_DEVICE: return false
			service.continue_after_pass_device(session)
	return session.phase == CharacterSelectionSession.Phase.SUMMARY


func _duplicate_commit_rejected() -> bool:
	var bundle: Dictionary = _finalized_session(1)
	var session: CharacterSelectionSession = bundle.get("session") as CharacterSelectionSession
	return _has_error(service.finalize_selection(session, characters), &"SELECTION_ALREADY_COMMITTED") and session.commit_count == 1


func _duplicate_policy_allows() -> bool:
	var session: CharacterSelectionSession = CharacterSelectionSession.new()
	service.configure_player_count(session, 2, true)
	for seat_index: int in range(2):
		service.select_character(session, characters[0].character_id, characters)
		service.lock_current_selection(session, characters)
		if seat_index == 0: service.continue_after_pass_device(session)
	return service.finalize_selection(session, characters).is_valid and session.duplicate_policy_test_only_not_canon_locked


func _duplicate_policy_rejects() -> bool:
	var session: CharacterSelectionSession = CharacterSelectionSession.new()
	service.configure_player_count(session, 2, false)
	service.select_character(session, characters[0].character_id, characters)
	service.lock_current_selection(session, characters)
	service.continue_after_pass_device(session)
	return _has_error(service.select_character(session, characters[0].character_id, characters), &"DUPLICATE_CHARACTER_DISALLOWED")


func _structured_error_fields() -> bool:
	var report: LootValidationReport = service.configure_player_count(CharacterSelectionSession.new(), 0)
	return not report.errors.is_empty() and not report.errors[0].code.is_empty() and not report.errors[0].message.is_empty()


func _snapshot_has_no_node_refs() -> bool:
	var session: CharacterSelectionSession = (_finalized_session(4).get("session") as CharacterSelectionSession)
	var payload: String = serializer.serialize_players(session.committed_players)
	var parsed: Variant = JSON.parse_string(payload)
	return not serializer.contains_forbidden_runtime_value(parsed)


func _has_error(report: LootValidationReport, code: StringName) -> bool:
	for issue: ValidationIssue in report.errors:
		if issue.code == code: return true
	return false
