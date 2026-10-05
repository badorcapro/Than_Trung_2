class_name Gd2M3TestSuite
extends RefCounted

var characters: Array[CharacterDefinition] = []
var map_definition: LootMapDefinition
var service := LootMovementService.new()
var serializer := LootMovementSerializer.new()


func run() -> Array[Dictionary]:
	characters = Gd2FixtureRepository.load_selection_characters()
	map_definition = Gd2FixtureRepository.load_m3_map()
	var rows: Array[Dictionary] = []
	rows.append(_row("GĐ2-M3 scene loads", load("res://scenes/loot/Gd2M3Movement.tscn") is PackedScene))
	rows.append(_row("M3 TEST_ONLY graph fixture loads", map_definition != null and map_definition.test_only_not_canon_locked))
	rows.append(_row("Four origin houses are mapped", map_definition.origin_spawn_by_house.size() == 4))
	rows.append(_row("M3 base graph validates", _map_valid()))
	rows.append(_row("Missing origin mapping fails clearly", _missing_origin_fails()))
	rows.append(_row("Spawn resolves from Character origin", _spawn_matches_origin()))
	rows.append(_row("Shared origin allows same-node occupancy", _same_origin_same_spawn()))
	rows.append(_row("Speed and Stamina snapshots use Character base", _stat_snapshots_match()))
	rows.append(_row("Deterministic roll sequence is injectable", _sequence_rolls_match()))
	rows.append(_row("Roll distance clamps to Speed", _roll_clamps_to_speed()))
	rows.append(_row("Spawn node is excluded from traversal trace", _spawn_excluded_from_trace()))
	rows.append(_row("Traversal trace preserves path order", _trace_order_matches()))
	rows.append(_row("Movement updates current node", _movement_updates_node()))
	rows.append(_row("Movement consumes exactly one action", _movement_consumes_one()))
	rows.append(_row("Round-robin order is P1 P2 P3 P1", _round_robin_order()))
	rows.append(_row("Exhausted players are skipped without deadlock", _exhausted_player_skipped()))
	rows.append(_row("End-of-path action consumes with empty trace", _end_path_consumes()))
	rows.append(_row("All exhausted reaches Loot End Confirmation ready", _completion_phase_reached()))
	rows.append(_row("Initial session round-trips", _round_trip_stage(0)))
	rows.append(_row("Mid-movement session round-trips", _round_trip_stage(1)))
	rows.append(_row("Completed session round-trips", _round_trip_stage(2)))
	rows.append(_row("Movement history contains domain data only", _history_is_plain_data()))
	rows.append(_row("Movement does not mutate economy resources", _economy_unchanged()))
	rows.append(_row("M3 stops before reward/equipment gameplay", _no_reward_mutation()))
	return rows


func _row(name: String, passed: bool) -> Dictionary:
	return {"name": name, "passed": passed, "detail": "GĐ2-M3 Spawn + Movement invariant"}


func _players(character_indices: Array[int]) -> Array[PlayerPhaseState]:
	var players: Array[PlayerPhaseState] = []
	for index: int in range(character_indices.size()):
		var player := PlayerPhaseState.new()
		player.player_id = StringName("m3_player_%d" % (index + 1))
		player.seat_index = index
		player.character_id = characters[character_indices[index]].character_id
		player.phase_id = &"READY_FOR_LOOT_M3"
		players.append(player)
	return players


func _session(indices: Array[int] = [0, 1, 2]) -> LootMovementSession:
	return service.build_session_from_selection(_players(indices), characters, map_definition)


func _map_valid() -> bool:
	var houses: Array[StringName] = [&"test_house_a", &"test_house_b", &"test_house_c", &"test_house_d"]
	return LootMovementMapValidator.new().validate(map_definition, houses).is_valid


func _missing_origin_fails() -> bool:
	var clone: LootMapDefinition = map_definition.duplicate(true) as LootMapDefinition
	clone.origin_spawn_by_house = clone.origin_spawn_by_house.duplicate()
	clone.origin_spawn_by_house.erase(&"test_house_a")
	var houses: Array[StringName] = [&"test_house_a"]
	return _has_error(LootMovementMapValidator.new().validate(clone, houses), &"ORIGIN_SPAWN_MISSING")


func _spawn_matches_origin() -> bool:
	var session: LootMovementSession = _session([0, 1, 2, 3])
	return session != null and session.player_states[0].current_node_id == &"house_a_0" and session.player_states[3].current_node_id == &"house_d_0"


func _same_origin_same_spawn() -> bool:
	var session: LootMovementSession = _session([0, 0])
	return session != null and session.player_states.size() == 2 and session.player_states[0].current_node_id == session.player_states[1].current_node_id


func _stat_snapshots_match() -> bool:
	var session: LootMovementSession = _session([0, 1, 2])
	return session != null and session.player_states.size() == 3 and session.player_states[0].speed_snapshot == 2 and session.player_states[0].remaining_moves == 2 and session.player_states[1].remaining_moves == 3 and session.player_states[2].speed_snapshot == 3


func _sequence_rolls_match() -> bool:
	var source: SequenceMovementRollSource = SequenceMovementRollSource.new([2, 1, 3])
	var values: Array[int] = []
	for _index: int in range(3):
		# Character C has Speed 3 but only one Stamina. A fresh valid session per
		# roll tests the injected source sequence without asking one player for
		# more actions than the Character contract permits.
		var session: LootMovementSession = _session([2])
		var action: MovementActionResult = service.roll_move(session, map_definition, source)
		if action == null:
			return false
		values.append(action.roll_distance)
	return values == [2, 1, 3]


func _roll_clamps_to_speed() -> bool:
	var session: LootMovementSession = _session([1])
	var action: MovementActionResult = service.roll_move(session, map_definition, SequenceMovementRollSource.new([99]))
	return action != null and action.roll_distance == 1


func _spawn_excluded_from_trace() -> bool:
	var session: LootMovementSession = _session([0])
	var action: MovementActionResult = service.roll_move(session, map_definition, SequenceMovementRollSource.new([1]))
	return action != null and action.traversed_node_ids == [&"house_a_1"]


func _trace_order_matches() -> bool:
	var session: LootMovementSession = _session([2])
	var action: MovementActionResult = service.roll_move(session, map_definition, SequenceMovementRollSource.new([3]))
	return action != null and action.traversed_node_ids == [&"house_c_1", &"center_0", &"center_1"]


func _movement_updates_node() -> bool:
	var session: LootMovementSession = _session([0])
	var action: MovementActionResult = service.roll_move(session, map_definition, SequenceMovementRollSource.new([2]))
	return action != null and session.player_states[0].current_node_id == &"center_0"


func _movement_consumes_one() -> bool:
	var session: LootMovementSession = _session([0])
	var before := session.player_states[0].remaining_moves
	var action: MovementActionResult = service.roll_move(session, map_definition, SequenceMovementRollSource.new([2]))
	return action != null and session.player_states[0].remaining_moves == before - 1


func _round_robin_order() -> bool:
	var session: LootMovementSession = _session([0, 1, 0])
	var source: SequenceMovementRollSource = SequenceMovementRollSource.new([1])
	var order: Array[StringName] = []
	for _turn: int in range(4):
		var action: MovementActionResult = service.roll_move(session, map_definition, source)
		if action == null:
			return false
		order.append(action.player_id)
	return order == [&"m3_player_1", &"m3_player_2", &"m3_player_3", &"m3_player_1"]


func _exhausted_player_skipped() -> bool:
	var session: LootMovementSession = _session([2, 0])
	var action: MovementActionResult = service.roll_move(session, map_definition, SequenceMovementRollSource.new([1]))
	var current: LootMovementPlayerState = session.current_player()
	return action != null and current != null and current.player_id == &"m3_player_2"


func _end_path_consumes() -> bool:
	var session: LootMovementSession = _session([0])
	var player: LootMovementPlayerState = session.player_states[0]
	player.current_node_id = &"end_0"
	var action: MovementActionResult = service.roll_move(session, map_definition, SequenceMovementRollSource.new([2]))
	return action != null and action.movement_consumed and action.traversed_node_ids.is_empty() and action.end_node_id == &"end_0" and action.truncated_by_end_of_path


func _completion_phase_reached() -> bool:
	var session: LootMovementSession = _session([2])
	var source: SequenceMovementRollSource = SequenceMovementRollSource.new([1])
	var action: MovementActionResult = service.roll_move(session, map_definition, source)
	return action != null and session.completed and session.phase == LootMovementSession.Phase.LOOT_END_CONFIRMATION_READY


func _round_trip_stage(stage: int) -> bool:
	var session: LootMovementSession = _session([0])
	var source: SequenceMovementRollSource = SequenceMovementRollSource.new([1])
	if stage >= 1:
		var first_action: MovementActionResult = service.roll_move(session, map_definition, source)
		if first_action == null:
			return false
	if stage >= 2:
		var second_action: MovementActionResult = service.roll_move(session, map_definition, source)
		if second_action == null:
			return false
	return serializer.round_trip_matches(session)


func _history_is_plain_data() -> bool:
	var session: LootMovementSession = _session([0])
	var action: MovementActionResult = service.roll_move(session, map_definition, SequenceMovementRollSource.new([1]))
	if action == null:
		return false
	var parsed: Variant = JSON.parse_string(serializer.serialize_session(session))
	return not Gd2StateSerializer.new().contains_forbidden_runtime_value(parsed)


func _economy_unchanged() -> bool:
	var players: Array[PlayerPhaseState] = _players([0])
	players[0].orb_count = 7
	players[0].silver_coin_count = 11
	var session: LootMovementSession = service.build_session_from_selection(players, characters, map_definition)
	var action: MovementActionResult = service.roll_move(session, map_definition, SequenceMovementRollSource.new([2]))
	return action != null and players[0].orb_count == 7 and players[0].silver_coin_count == 11


func _no_reward_mutation() -> bool:
	var players: Array[PlayerPhaseState] = _players([0])
	var session: LootMovementSession = service.build_session_from_selection(players, characters, map_definition)
	var action: MovementActionResult = service.roll_move(session, map_definition, SequenceMovementRollSource.new([2]))
	return action != null and players[0].reward_snapshots.is_empty() and players[0].equipment_collection.is_empty()


func _has_error(report: LootValidationReport, code: StringName) -> bool:
	for issue: ValidationIssue in report.errors:
		if issue.code == code:
			return true
	return false
