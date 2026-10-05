class_name Gd2Prep1StateBoundaryTestSuite
extends RefCounted

const ROUND_LOCAL_KEYS: Array[String] = [
	"current_node_id",
	"remaining_moves",
	"temporary_effects",
	"round_id",
	"phase_id",
	"reward_snapshots",
]


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var player := _player()
	var serializer := Gd2StateSerializer.new()
	var serialized_value: Variant = JSON.parse_string(serializer.serialize_player(player))
	var serialized: Dictionary = serialized_value if serialized_value is Dictionary else {}
	rows.append(_row("PREP-1 persistent serialization excludes round-local fields", _excludes_round_keys(serialized)))
	rows.append(_row("PREP-1 persistent resources round-trip", _persistent_round_trip(player, serializer)))
	rows.append(_row("PREP-1 movement session creation preserves persistent resources", _movement_creation_preserves(player)))
	rows.append(_row("PREP-1 new round resets movement without erasing persistent state", _new_round_resets_movement(player)))
	rows.append(_row("PREP-1 player identity is stable across state projections", _identity_is_stable(player, serializer)))
	rows.append(_row("PREP-1 temporary effects belong to movement state", _temporary_effect_authority(player)))
	rows.append(_row("PREP-1 persistent inventory is not movement state", _inventory_does_not_leak_to_movement(player)))
	rows.append(_row("PREP-1 prototype movement and reward flows remain compatible", _prototype_flows_compatible(player)))
	return rows


func _player() -> PlayerPhaseState:
	var player := PlayerPhaseState.new()
	player.player_id = &"prep_player_1"
	player.seat_index = 0
	player.character_id = &"test_character_a"
	player.reputation = 4
	player.orb_count = 7
	player.gacha_ticket_count = 3
	player.silver_coin_count = 11
	player.current_node_id = &"legacy_node"
	player.remaining_moves = 99
	player.round_id = &"legacy_round"
	player.phase_id = &"legacy_phase"
	var effect := TemporaryEffectState.new()
	effect.effect_id = &"legacy_effect"
	player.temporary_effects.append(effect)
	return player


func _movement_session(player: PlayerPhaseState, round_id: StringName) -> LootMovementSession:
	var players: Array[PlayerPhaseState] = [player]
	return LootMovementService.new().build_session_from_selection(
		players,
		Gd2FixtureRepository.load_selection_characters(),
		Gd2FixtureRepository.load_m3_map(),
		round_id
	)


func _excludes_round_keys(data: Dictionary) -> bool:
	for key: String in ROUND_LOCAL_KEYS:
		if data.has(key):
			return false
	return true


func _persistent_round_trip(player: PlayerPhaseState, serializer: Gd2StateSerializer) -> bool:
	var restored: PlayerPhaseState = serializer.deserialize_player(serializer.serialize_player(player))
	return (
		restored != null
		and restored.orb_count == 7
		and restored.gacha_ticket_count == 3
		and restored.silver_coin_count == 11
		and restored.current_node_id.is_empty()
		and restored.remaining_moves == 0
	)


func _movement_creation_preserves(player: PlayerPhaseState) -> bool:
	var before: Dictionary = player.to_persistent_dict()
	var session: LootMovementSession = _movement_session(player, &"prep_round_a")
	return session != null and player.to_persistent_dict() == before


func _new_round_resets_movement(player: PlayerPhaseState) -> bool:
	var first: LootMovementSession = _movement_session(player, &"prep_round_a")
	if first == null:
		return false
	first.player_states[0].current_node_id = &"center_1"
	first.player_states[0].remaining_moves = 0
	var second: LootMovementSession = _movement_session(player, &"prep_round_b")
	return (
		second != null
		and second.player_states[0].current_node_id != &"center_1"
		and second.player_states[0].remaining_moves > 0
		and player.orb_count == 7
		and player.silver_coin_count == 11
	)


func _identity_is_stable(player: PlayerPhaseState, serializer: Gd2StateSerializer) -> bool:
	var restored: PlayerPhaseState = serializer.deserialize_player(serializer.serialize_player(player))
	var movement: LootMovementSession = _movement_session(player, &"prep_round_identity")
	return (
		restored != null
		and movement != null
		and restored.player_id == player.player_id
		and movement.player_states[0].player_id == player.player_id
	)


func _temporary_effect_authority(player: PlayerPhaseState) -> bool:
	var movement: LootMovementSession = _movement_session(player, &"prep_round_effect")
	if movement == null:
		return false
	var effect := TemporaryEffectState.new()
	effect.effect_id = &"round_effect"
	movement.player_states[0].temporary_effects.append(effect)
	return (
		movement.player_states[0].temporary_effects.size() == 1
		and not player.to_persistent_dict().has("temporary_effects")
	)


func _inventory_does_not_leak_to_movement(player: PlayerPhaseState) -> bool:
	player.consumable_inventory = [{"item_id": "persistent_fixture_item"}]
	var movement: LootMovementSession = _movement_session(player, &"prep_round_inventory")
	return (
		movement != null
		and not movement.player_states[0].to_dict().has("consumable_inventory")
		and player.consumable_inventory.size() == 1
	)


func _prototype_flows_compatible(player: PlayerPhaseState) -> bool:
	var players: Array[PlayerPhaseState] = [player]
	var characters: Array[CharacterDefinition] = Gd2FixtureRepository.load_selection_characters()
	var map_definition: LootMapDefinition = Gd2FixtureRepository.load_m3_map()
	var character: CharacterDefinition
	for candidate: CharacterDefinition in characters:
		if candidate.character_id == player.character_id:
			character = candidate
			break
	if character == null:
		return false
	var expected_node: StringName = StringName(
		map_definition.origin_spawn_by_house.get(character.origin_house_id, &"")
	)
	var reward_session: LootRewardSession = LootRewardService.new().build_session(
		players,
		characters,
		map_definition,
		Gd2FixtureRepository.load_m4_rewards(),
		SequenceRewardRollSource.new([0, 1, 2, 3, 4, 5, 6]),
		&"prep_round_reward"
	)
	return (
		reward_session != null
		and reward_session.players.size() == 1
		and reward_session.movement_session.player_states.size() == 1
		and reward_session.players[0].player_id == reward_session.movement_session.player_states[0].player_id
		and reward_session.players[0].current_node_id.is_empty()
		and reward_session.players[0].remaining_moves == 0
		and reward_session.movement_session.player_states[0].current_node_id == expected_node
		and reward_session.movement_session.player_states[0].remaining_moves == character.base_stamina
	)


func _row(name: String, passed: bool) -> Dictionary:
	return {"name": name, "passed": passed, "detail": "GĐ2-PREP-1 state ownership invariant"}
