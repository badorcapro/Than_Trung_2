class_name Gd2Prep3InventoryBoundaryTestSuite
extends RefCounted


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	rows.append(_row(
		"PREP-3 persistent inventory does not consume round Bag capacity",
		_persistent_inventory_does_not_fill_round_bag()
	))
	rows.append(_row(
		"PREP-3 round map loot serializes outside persistent inventory",
		_round_loot_round_trip_is_separate()
	))
	rows.append(_row(
		"PREP-3 reward history is not inventory authority",
		_reward_history_is_not_inventory()
	))
	return rows


func _persistent_inventory_does_not_fill_round_bag() -> bool:
	var session: LootRewardSession = _resolved_item_session()
	if session == null:
		return false
	var player: PlayerPhaseState = session.players[0]
	var round_loot: RoundLootInventoryState = session.find_round_loot_state(
		player.player_id
	)
	return (
		round_loot != null
		and round_loot.player_id == player.player_id
		and round_loot.carried_items.size() == 1
		and player.consumable_inventory.size() == 2
		and session.phase != LootRewardSession.Phase.BAG_OVERFLOW_PENDING
	)


func _round_loot_round_trip_is_separate() -> bool:
	var session: LootRewardSession = _resolved_item_session()
	if session == null:
		return false
	var restored: LootRewardSession = LootRewardSerializer.new().deserialize_session(
		LootRewardSerializer.new().serialize_session(session)
	)
	if restored == null:
		return false
	var player: PlayerPhaseState = restored.players[0]
	var round_loot: RoundLootInventoryState = restored.find_round_loot_state(
		player.player_id
	)
	return (
		round_loot != null
		and round_loot.player_id == player.player_id
		and round_loot.carried_items.size() == 1
		and player.consumable_inventory.size() == 2
	)


func _reward_history_is_not_inventory() -> bool:
	var session: LootRewardSession = _resolved_item_session()
	if session == null:
		return false
	var player: PlayerPhaseState = session.players[0]
	var round_loot: RoundLootInventoryState = session.find_round_loot_state(
		player.player_id
	)
	if round_loot == null or session.reward_history.is_empty():
		return false
	var persistent_before: Array[Dictionary] = player.consumable_inventory.duplicate(true)
	var round_before: Array[Dictionary] = round_loot.carried_items.duplicate(true)
	session.reward_history.clear()
	return (
		player.consumable_inventory == persistent_before
		and round_loot.carried_items == round_before
	)


func _resolved_item_session() -> LootRewardSession:
	var characters: Array[CharacterDefinition] = (
		Gd2FixtureRepository.load_selection_characters()
	)
	var player := PlayerPhaseState.new()
	player.player_id = &"prep3_player_1"
	player.character_id = characters[0].character_id
	player.consumable_inventory = [
		{"item_id": "persistent_shop_item_a"},
		{"item_id": "persistent_shop_item_b"},
	]
	var players: Array[PlayerPhaseState] = [player]
	var reward: RewardDefinition
	for candidate: RewardDefinition in Gd2FixtureRepository.load_m4_rewards():
		if candidate.reward_type == RewardDefinition.Type.CONSUMABLE_ITEM:
			reward = candidate
			break
	if reward == null:
		return null
	var rewards: Array[RewardDefinition] = [reward]
	var service := LootRewardService.new()
	var session: LootRewardSession = service.build_session(
		players,
		characters,
		Gd2FixtureRepository.load_m3_map(),
		rewards,
		SequenceRewardRollSource.new([0]),
		&"prep3_round"
	)
	if session == null:
		return null
	service.resolve_trace(
		session, player.player_id, [&"house_a_1"], rewards
	)
	return session


func _row(name: String, passed: bool) -> Dictionary:
	return {
		"name": name,
		"passed": passed,
		"detail": "GĐ2-PREP-3 inventory ownership invariant",
	}
