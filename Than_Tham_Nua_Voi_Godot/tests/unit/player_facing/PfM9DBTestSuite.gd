class_name PfM9DBTestSuite
extends RefCounted

const ITEM_SERVICE := preload("res://scripts/application/loot/ConsumableItemService.gd")
const END_SERVICE := preload("res://scripts/application/loot/LootEndConfirmationService.gd")
const LOOT_ADAPTER := preload("res://scripts/application/mvp/LootSliceAdapter.gd")
const PLAYER_SCENE := preload("res://scenes/player_facing/PlayerFacingStart.tscn")

var _reward_service := LootRewardService.new()
var _end_service: END_SERVICE = END_SERVICE.new()
var _characters: Array[CharacterDefinition] = []
var _rewards: Array[RewardDefinition] = []
var _items: Array[ConsumableItemDefinition] = []
var _map: LootMapDefinition


func run() -> Array[Dictionary]:
	_characters = Gd2FixtureRepository.load_selection_characters()
	_rewards = Gd2FixtureRepository.load_m4_rewards()
	_items = Gd2FixtureRepository.load_m4_items()
	_map = Gd2FixtureRepository.load_m3_map()
	var rows: Array[Dictionary] = []
	_add(rows, "PF-M9D-B persistent consumable remains usable during Loot", _persistent_item_works())
	_add(rows, "PF-M9D-B Round-bag consumable is usable during same Loot", _round_item_works())
	_add(rows, "PF-M9D-B Round-bag use consumes exactly one carried item", _round_item_consumes_once())
	_add(rows, "PF-M9D-B Item Window exposes two explicit ownership sources", _two_sources_are_exposed())
	_add(rows, "PF-M9D-B one-item-per-turn is shared across sources", _shared_turn_limit())
	_add(rows, "PF-M9D-B unused Round loot transfers on player confirmation", _unused_item_transfers())
	_add(rows, "PF-M9D-B used Round loot does not transfer", _used_item_does_not_transfer())
	_add(rows, "PF-M9D-B overflow-rejected item does not transfer", _overflow_rejected_does_not_transfer())
	_add(rows, "PF-M9D-B overflow-replaced old item does not transfer", _overflow_replaced_old_does_not_transfer())
	_add(rows, "PF-M9D-B repeated finalization cannot duplicate transfer", _finalization_is_idempotent())
	_add(rows, "PF-M9D-B transferred item survives persistent Round merge", _transfer_survives_merge())
	_add(rows, "PF-M9D-B next Round starts with an empty Round bag", _next_round_bag_is_empty())
	_add(rows, "PF-M9D-B transferred item is persistent next Round", _transfer_is_persistent_next_round())
	_add(rows, "PF-M9D-B transferred item does not consume next-Round Bag", _persistent_does_not_fill_next_bag())
	_add(rows, "PF-M9D-B Loot disposition is isolated by player", _players_are_isolated())
	_add(rows, "PF-M9D-B MATCH_COMPLETE snapshot preserves finalized loot", _match_complete_preserves_transfer())
	_add(rows, "PF-M9D-B direct resource rewards still bypass Round bag", _direct_resources_unchanged())
	return rows


func _persistent_item_works() -> bool:
	var session: LootRewardSession = _session(1)
	session.players[0].consumable_inventory.append({"item_id": "test_move_plus_1"})
	var result: ItemUseResult = _reward_service.use_item(
		session, &"test_move_plus_1", _items, ITEM_SERVICE.SOURCE_PERSISTENT
	)
	return result.success and session.players[0].consumable_inventory.is_empty()


func _round_item_works() -> bool:
	var session: LootRewardSession = _session(1)
	_round_state(session, 0).carried_items.append({"item_id": "test_move_plus_1"})
	var result: ItemUseResult = _reward_service.use_item(
		session, &"test_move_plus_1", _items, ITEM_SERVICE.SOURCE_ROUND_LOOT
	)
	return result.success and result.consumed_item_id == &"test_move_plus_1"


func _round_item_consumes_once() -> bool:
	var session: LootRewardSession = _session(1)
	var state: RoundLootInventoryState = _round_state(session, 0)
	state.carried_items.append({"item_id": "test_move_plus_1"})
	var result: ItemUseResult = _reward_service.use_item(
		session, &"test_move_plus_1", _items, ITEM_SERVICE.SOURCE_ROUND_LOOT
	)
	return result.success and state.carried_items.is_empty()


func _two_sources_are_exposed() -> bool:
	var session: LootRewardSession = _session(1)
	session.players[0].consumable_inventory.append({"item_id": "test_extra_action"})
	_round_state(session, 0).carried_items.append({"item_id": "test_move_plus_1"})
	var scene_state: SceneState = PLAYER_SCENE.get_state()
	var has_selector := false
	for index: int in range(scene_state.get_node_count()):
		if String(scene_state.get_node_name(index)) == "ItemSourceSelector":
			has_selector = true
			break
	var source: String = FileAccess.get_file_as_string(
		"res://scripts/presentation/player_facing/PlayerFacingStartController.gd"
	)
	return (
		has_selector
		and source.contains("Đồ đang sở hữu")
		and source.contains("Nhặt trong vòng này")
		and source.contains("Giữ lại từ vòng này")
		and source.contains("\"source\": \"persistent\"")
		and source.contains("\"source\": \"round_loot\"")
		and session.players[0].consumable_inventory.size() == 1
		and _round_state(session, 0).carried_items.size() == 1
	)


func _shared_turn_limit() -> bool:
	var session: LootRewardSession = _session(1)
	session.players[0].consumable_inventory.append({"item_id": "test_move_plus_1"})
	_round_state(session, 0).carried_items.append({"item_id": "test_extra_action"})
	var first: ItemUseResult = _reward_service.use_item(
		session, &"test_move_plus_1", _items, ITEM_SERVICE.SOURCE_PERSISTENT
	)
	var second: ItemUseResult = _reward_service.use_item(
		session, &"test_extra_action", _items, ITEM_SERVICE.SOURCE_ROUND_LOOT
	)
	return first.success and not second.success and second.code == &"ITEM_LIMIT_REACHED"


func _unused_item_transfers() -> bool:
	var bundle: Dictionary = _confirmed_bundle(&"test_move_plus_1")
	return _bundle_transferred_once(bundle, &"test_move_plus_1")


func _used_item_does_not_transfer() -> bool:
	var session: LootRewardSession = _session(1)
	_round_state(session, 0).carried_items.append({"item_id": "test_move_plus_1"})
	_reward_service.use_item(
		session, &"test_move_plus_1", _items, ITEM_SERVICE.SOURCE_ROUND_LOOT
	)
	var management: EquipmentManagementSession = _begin_confirmation(session)
	return (
		management != null
		and _end_service.confirm(management, session.players[0].player_id, session, _items)
		and management.players[0].consumable_inventory.is_empty()
		and _round_state(session, 0).transferred_items.is_empty()
	)


func _overflow_rejected_does_not_transfer() -> bool:
	var session: LootRewardSession = _overflow_session()
	if not _reward_service.resolve_overflow_skip(session, [_consumable_reward()]):
		return false
	var management: EquipmentManagementSession = _begin_confirmation(session)
	if management == null or not _end_service.confirm(
		management, session.players[0].player_id, session, _items
	):
		return false
	return (
		_count_item(management.players[0].consumable_inventory, &"test_move_plus_1") == 0
		and _count_item(management.players[0].consumable_inventory, &"test_extra_action") == 1
	)


func _overflow_replaced_old_does_not_transfer() -> bool:
	var session: LootRewardSession = _overflow_session()
	if not _reward_service.resolve_overflow_discard(
		session, 0, [_consumable_reward()]
	):
		return false
	var management: EquipmentManagementSession = _begin_confirmation(session)
	if management == null or not _end_service.confirm(
		management, session.players[0].player_id, session, _items
	):
		return false
	return (
		_count_item(management.players[0].consumable_inventory, &"test_extra_action") == 0
		and _count_item(management.players[0].consumable_inventory, &"test_move_plus_1") == 1
	)


func _finalization_is_idempotent() -> bool:
	var session: LootRewardSession = _session(2)
	_round_state(session, 0).carried_items.append({"item_id": "test_move_plus_1"})
	var management: EquipmentManagementSession = _begin_confirmation(session)
	if management == null:
		return false
	var player_id: StringName = session.players[0].player_id
	var first: bool = _end_service.confirm(management, player_id, session, _items)
	var restored_management: EquipmentManagementSession = EquipmentManagementSession.from_dict(
		management.to_dict()
	)
	var restored_session: LootRewardSession = LootRewardSession.from_dict(
		session.to_dict()
	)
	var before: int = restored_management.players[0].consumable_inventory.size()
	var second: bool = _end_service.confirm(
		restored_management, player_id, restored_session, _items
	)
	return (
		first
		and not second
		and before == 1
		and restored_management.players[0].consumable_inventory.size() == 1
		and _round_state(restored_session, 0).disposition_finalized
	)


func _transfer_survives_merge() -> bool:
	var bundle: Dictionary = _confirmed_bundle(&"test_move_plus_1")
	var management: EquipmentManagementSession = bundle.get("management") as EquipmentManagementSession
	if management == null:
		return false
	var target := PlayerMatchState.new()
	target.player_id = management.players[0].player_id
	var merged: Dictionary = LOOT_ADAPTER.new().merge_player(target, management.players[0])
	return bool(merged.get("success", false)) and _count_item(target.consumable_inventory, &"test_move_plus_1") == 1


func _next_round_bag_is_empty() -> bool:
	var next: LootRewardSession = _next_round_session()
	return next != null and _round_state(next, 0).carried_items.is_empty()


func _transfer_is_persistent_next_round() -> bool:
	var next: LootRewardSession = _next_round_session()
	return next != null and _count_item(next.players[0].consumable_inventory, &"test_move_plus_1") == 1


func _persistent_does_not_fill_next_bag() -> bool:
	var next: LootRewardSession = _next_round_session()
	if next == null:
		return false
	var state: RoundLootInventoryState = _round_state(next, 0)
	return state.carried_items.is_empty() and state.capacity == _characters[0].base_bag_level


func _players_are_isolated() -> bool:
	var session: LootRewardSession = _session(2)
	_round_state(session, 0).carried_items.append({"item_id": "test_move_plus_1"})
	_round_state(session, 1).carried_items.append({"item_id": "test_extra_action"})
	var management: EquipmentManagementSession = _begin_confirmation(session)
	if management == null or not _end_service.confirm(
		management, session.players[0].player_id, session, _items
	):
		return false
	return (
		management.players[0].consumable_inventory.size() == 1
		and management.players[1].consumable_inventory.is_empty()
		and _round_state(session, 1).carried_items.size() == 1
		and not _round_state(session, 1).disposition_finalized
	)


func _match_complete_preserves_transfer() -> bool:
	var bundle: Dictionary = _confirmed_bundle(&"test_move_plus_1")
	var management: EquipmentManagementSession = bundle.get("management") as EquipmentManagementSession
	if management == null:
		return false
	var target := PlayerMatchState.new()
	target.player_id = management.players[0].player_id
	LOOT_ADAPTER.new().merge_player(target, management.players[0])
	var match_state := MvpMatchState.new()
	match_state.players.append(target)
	match_state.player_order.append(target.player_id)
	match_state.match_completion_state = &"MATCH_COMPLETE"
	match_state.current_phase = MvpEnums.Phase.MATCH_COMPLETE
	var restored: MvpMatchState = MvpMatchState.from_dict(match_state.to_dict())
	var restored_player: PlayerMatchState = restored.find_player(target.player_id)
	return (
		restored.match_completion_state == &"MATCH_COMPLETE"
		and restored_player != null
		and _count_item(restored_player.consumable_inventory, &"test_move_plus_1") == 1
	)


func _direct_resources_unchanged() -> bool:
	var silver: RewardDefinition
	for reward: RewardDefinition in _rewards:
		if reward.reward_type == RewardDefinition.Type.SILVER_COIN:
			silver = reward
			break
	if silver == null:
		return false
	var players: Array[PlayerPhaseState] = _players(1)
	var rewards: Array[RewardDefinition] = [silver]
	var session: LootRewardSession = _reward_service.build_session(
		players, _characters, _map, rewards, SequenceRewardRollSource.new([0]), &"m9d_resource"
	)
	_reward_service.resolve_trace(session, session.players[0].player_id, [&"house_a_1"], rewards)
	return session.players[0].silver_coin_count == silver.amount and _round_state(session, 0).carried_items.is_empty()


func _confirmed_bundle(item_id: StringName) -> Dictionary:
	var session: LootRewardSession = _session(1)
	_round_state(session, 0).carried_items.append({"item_id": String(item_id)})
	var management: EquipmentManagementSession = _begin_confirmation(session)
	if management == null:
		return {}
	var confirmed: bool = _end_service.confirm(
		management, session.players[0].player_id, session, _items
	)
	return {"session": session, "management": management, "confirmed": confirmed}


func _bundle_transferred_once(bundle: Dictionary, item_id: StringName) -> bool:
	var session: LootRewardSession = bundle.get("session") as LootRewardSession
	var management: EquipmentManagementSession = bundle.get("management") as EquipmentManagementSession
	if session == null or management == null or not bool(bundle.get("confirmed", false)):
		return false
	var state: RoundLootInventoryState = _round_state(session, 0)
	return (
		state.disposition_finalized
		and state.carried_items.is_empty()
		and _count_item(state.transferred_items, item_id) == 1
		and _count_item(management.players[0].consumable_inventory, item_id) == 1
	)


func _next_round_session() -> LootRewardSession:
	var bundle: Dictionary = _confirmed_bundle(&"test_move_plus_1")
	var management: EquipmentManagementSession = bundle.get("management") as EquipmentManagementSession
	if management == null:
		return null
	return _reward_service.build_session(
		management.players,
		_characters,
		_map,
		_rewards,
		SequenceRewardRollSource.new([0]),
		&"m9d_next_round"
	)


func _overflow_session() -> LootRewardSession:
	var reward: RewardDefinition = _consumable_reward()
	var reward_set: Array[RewardDefinition] = [reward]
	var session: LootRewardSession = _reward_service.build_session(
		_players(1), _characters, _map, reward_set,
		SequenceRewardRollSource.new([0]), &"m9d_overflow"
	)
	var state: RoundLootInventoryState = _round_state(session, 0)
	state.carried_items.append({"item_id": "test_extra_action"})
	_reward_service.resolve_trace(
		session, session.players[0].player_id, [&"house_a_1"], reward_set
	)
	return session


func _consumable_reward() -> RewardDefinition:
	for reward: RewardDefinition in _rewards:
		if reward.reward_type == RewardDefinition.Type.CONSUMABLE_ITEM:
			return reward
	return null


func _begin_confirmation(session: LootRewardSession) -> EquipmentManagementSession:
	for player: LootMovementPlayerState in session.movement_session.player_states:
		player.remaining_moves = 0
	session.phase = LootRewardSession.Phase.LOOT_END_CONFIRMATION_READY
	return _end_service.begin(session)


func _session(player_count: int) -> LootRewardSession:
	return _reward_service.build_session(
		_players(player_count), _characters, _map, _rewards,
		SequenceRewardRollSource.new([0, 1, 2]), &"m9d_round"
	)


func _players(count: int) -> Array[PlayerPhaseState]:
	var result: Array[PlayerPhaseState] = []
	for index: int in range(count):
		var player := PlayerPhaseState.new()
		player.player_id = StringName("m9d_player_%d" % (index + 1))
		player.seat_index = index
		player.character_id = _characters[index].character_id
		result.append(player)
	return result


func _round_state(session: LootRewardSession, index: int) -> RoundLootInventoryState:
	return session.find_round_loot_state(session.players[index].player_id)


func _count_item(rows: Array[Dictionary], item_id: StringName) -> int:
	var count := 0
	for row: Dictionary in rows:
		if StringName(row.get("item_id", "")) == item_id:
			count += 1
	return count


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "PF-M9D-B Round map-loot disposition invariant",
	})
