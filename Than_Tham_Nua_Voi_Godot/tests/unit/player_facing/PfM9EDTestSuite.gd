class_name PfM9EDTestSuite
extends RefCounted

const END_SERVICE := preload("res://scripts/application/loot/LootEndConfirmationService.gd")
const PLAYER_CONTROLLER := preload(
	"res://scripts/presentation/player_facing/PlayerFacingStartController.gd"
)
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
	_add(rows, "PF-M9E-D full bag enters explicit overflow choice", _pending_choice_is_explicit())
	_add(rows, "PF-M9E-D overflow UI lists every carried item", _ui_lists_every_carried_item())
	_add(rows, "PF-M9E-D first carried item can be replaced", _replace_index(0))
	_add(rows, "PF-M9E-D non-first carried item can be replaced", _replace_index(1))
	_add(rows, "PF-M9E-D selected replacement item alone is removed", _selected_item_alone_is_removed())
	_add(rows, "PF-M9E-D non-selected carried items remain", _non_selected_items_remain())
	_add(rows, "PF-M9E-D incoming item is inserted exactly once", _incoming_is_inserted_once())
	_add(rows, "PF-M9E-D replacement preserves bag capacity", _replacement_preserves_capacity())
	_add(rows, "PF-M9E-D discard-new preserves current bag", _skip_preserves_bag())
	_add(rows, "PF-M9E-D replaced old item cannot transfer", _replaced_old_cannot_transfer())
	_add(rows, "PF-M9E-D accepted incoming item transfers", _incoming_transfers())
	_add(rows, "PF-M9E-D discarded incoming item cannot transfer", _discarded_incoming_cannot_transfer())
	_add(rows, "PF-M9E-D unresolved overflow blocks Loot continuation", _pending_blocks_flow())
	_add(rows, "PF-M9E-D overflow choice is isolated to its player", _player_isolation())
	_add(rows, "PF-M9E-D zero-capacity bag offers discard-new only", _zero_capacity_is_discard_only())
	_add(rows, "PF-M9E-D stale or repeated overflow action is harmless", _stale_action_is_harmless())
	return rows


func _pending_choice_is_explicit() -> bool:
	var session: LootRewardSession = _overflow_session()
	return (
		session.phase == LootRewardSession.Phase.BAG_OVERFLOW_PENDING
		and session.overflow.active
		and session.overflow.player_id == session.players[0].player_id
		and session.overflow.incoming_item_id == _consumable_reward().item_id
		and session.reward_history[-1].status == RewardResolutionResult.Status.PENDING_OVERFLOW
	)


func _ui_lists_every_carried_item() -> bool:
	var session: LootRewardSession = _overflow_session()
	var controller: PLAYER_CONTROLLER = PLAYER_CONTROLLER.new()
	var options: Array[Dictionary] = controller.overflow_replacement_options_for_smoke(
		session, session.players[0].player_id
	)
	var scene_state: SceneState = PLAYER_SCENE.get_state()
	var has_selector := false
	var has_replace := false
	var has_skip := false
	for index: int in range(scene_state.get_node_count()):
		var node_name: String = String(scene_state.get_node_name(index))
		has_selector = has_selector or node_name == "OverflowTargetSelector"
		has_replace = has_replace or node_name == "OverflowReplace"
		has_skip = has_skip or node_name == "OverflowSkip"
	var scene_source: String = FileAccess.get_file_as_string(
		"res://scenes/player_facing/PlayerFacingStart.tscn"
	)
	var controller_source: String = FileAccess.get_file_as_string(
		"res://scripts/presentation/player_facing/PlayerFacingStartController.gd"
	)
	return (
		options.size() == 3
		and int(options[0].get("inventory_index", -1)) == 0
		and int(options[1].get("inventory_index", -1)) == 1
		and int(options[2].get("inventory_index", -1)) == 2
		and has_selector
		and has_replace
		and has_skip
		and scene_source.contains("text = \"Thay thế\"")
		and scene_source.contains("text = \"Bỏ vật phẩm mới\"")
		and controller_source.contains("resolve_overflow_discard(inventory_index)")
		and not controller_source.contains("resolve_overflow_discard(0)")
	)


func _replace_index(index: int) -> bool:
	var session: LootRewardSession = _overflow_session()
	var before: Array[Dictionary] = _copy_rows(_round_state(session, 0).carried_items)
	var removed_id: StringName = StringName(before[index].get("item_id", ""))
	var incoming_id: StringName = session.overflow.incoming_item_id
	return (
		_reward_service.resolve_overflow_discard(session, index, [_consumable_reward()])
		and _count_item(_round_state(session, 0).carried_items, removed_id)
			== _count_item(before, removed_id) - 1
		and _count_item(_round_state(session, 0).carried_items, incoming_id) == 1
	)


func _selected_item_alone_is_removed() -> bool:
	var session: LootRewardSession = _overflow_session()
	var state: RoundLootInventoryState = _round_state(session, 0)
	var first: Dictionary = state.carried_items[0].duplicate(true)
	var third: Dictionary = state.carried_items[2].duplicate(true)
	if not _reward_service.resolve_overflow_discard(session, 1, [_consumable_reward()]):
		return false
	return state.carried_items[0] == first and state.carried_items[1] == third


func _non_selected_items_remain() -> bool:
	var session: LootRewardSession = _overflow_session()
	var state: RoundLootInventoryState = _round_state(session, 0)
	var first_id: StringName = StringName(state.carried_items[0].get("item_id", ""))
	var second_id: StringName = StringName(state.carried_items[1].get("item_id", ""))
	if not _reward_service.resolve_overflow_discard(session, 2, [_consumable_reward()]):
		return false
	return (
		_count_item(state.carried_items, first_id) == 1
		and _count_item(state.carried_items, second_id) == 1
	)


func _incoming_is_inserted_once() -> bool:
	var session: LootRewardSession = _overflow_session()
	var incoming_id: StringName = session.overflow.incoming_item_id
	return (
		_reward_service.resolve_overflow_discard(session, 1, [_consumable_reward()])
		and _count_item(_round_state(session, 0).carried_items, incoming_id) == 1
	)


func _replacement_preserves_capacity() -> bool:
	var session: LootRewardSession = _overflow_session()
	var state: RoundLootInventoryState = _round_state(session, 0)
	var capacity: int = state.capacity
	return (
		_reward_service.resolve_overflow_discard(session, 1, [_consumable_reward()])
		and state.capacity == capacity
		and state.carried_items.size() == capacity
	)


func _skip_preserves_bag() -> bool:
	var session: LootRewardSession = _overflow_session()
	var state: RoundLootInventoryState = _round_state(session, 0)
	var before: Array[Dictionary] = _copy_rows(state.carried_items)
	return (
		_reward_service.resolve_overflow_skip(session, [_consumable_reward()])
		and state.carried_items == before
	)


func _replaced_old_cannot_transfer() -> bool:
	var session: LootRewardSession = _overflow_session()
	var replaced_id: StringName = StringName(
		_round_state(session, 0).carried_items[1].get("item_id", "")
	)
	if not _reward_service.resolve_overflow_discard(session, 1, [_consumable_reward()]):
		return false
	var management: EquipmentManagementSession = _confirm(session)
	return (
		management != null
		and _count_item(management.players[0].consumable_inventory, replaced_id) == 0
	)


func _incoming_transfers() -> bool:
	var session: LootRewardSession = _overflow_session()
	var incoming_id: StringName = session.overflow.incoming_item_id
	if not _reward_service.resolve_overflow_discard(session, 1, [_consumable_reward()]):
		return false
	var management: EquipmentManagementSession = _confirm(session)
	return (
		management != null
		and _count_item(management.players[0].consumable_inventory, incoming_id) == 1
	)


func _discarded_incoming_cannot_transfer() -> bool:
	var session: LootRewardSession = _overflow_session()
	var incoming_id: StringName = session.overflow.incoming_item_id
	if not _reward_service.resolve_overflow_skip(session, [_consumable_reward()]):
		return false
	var management: EquipmentManagementSession = _confirm(session)
	return (
		management != null
		and _count_item(management.players[0].consumable_inventory, incoming_id) == 0
	)


func _pending_blocks_flow() -> bool:
	var session: LootRewardSession = _overflow_session()
	return (
		not _reward_service.continue_without_item(session)
		and not _reward_service.resolve_trace(
			session,
			session.players[0].player_id,
			[&"house_b_1"],
			[_consumable_reward()]
		)
		and _end_service.begin(session) == null
		and session.phase == LootRewardSession.Phase.BAG_OVERFLOW_PENDING
	)


func _player_isolation() -> bool:
	var session: LootRewardSession = _overflow_session(2)
	var other: RoundLootInventoryState = _round_state(session, 1)
	other.carried_items.append({"item_id": "test_move_plus_1"})
	var other_before: Array[Dictionary] = _copy_rows(other.carried_items)
	session.movement_session.current_turn_index = 1
	var rejected: bool = _reward_service.resolve_overflow_discard(
		session, 0, [_consumable_reward()]
	)
	var controller: PLAYER_CONTROLLER = PLAYER_CONTROLLER.new()
	var foreign_options: Array[Dictionary] = controller.overflow_replacement_options_for_smoke(
		session, session.players[1].player_id
	)
	return rejected == false and other.carried_items == other_before and foreign_options.is_empty()


func _zero_capacity_is_discard_only() -> bool:
	var session: LootRewardSession = _overflow_session(1, 0)
	var controller: PLAYER_CONTROLLER = PLAYER_CONTROLLER.new()
	var options: Array[Dictionary] = controller.overflow_replacement_options_for_smoke(
		session, session.players[0].player_id
	)
	var replace_result: bool = _reward_service.resolve_overflow_discard(
		session, 0, [_consumable_reward()]
	)
	return (
		options.is_empty()
		and not replace_result
		and _reward_service.resolve_overflow_skip(session, [_consumable_reward()])
	)


func _stale_action_is_harmless() -> bool:
	var invalid_session: LootRewardSession = _overflow_session()
	var invalid_before: Array[Dictionary] = _copy_rows(
		_round_state(invalid_session, 0).carried_items
	)
	invalid_session.overflow.incoming_item_id = &"missing_item"
	var invalid_result: bool = _reward_service.resolve_overflow_discard(
		invalid_session, 1, [_consumable_reward()]
	)
	var session: LootRewardSession = _overflow_session()
	if not _reward_service.resolve_overflow_discard(session, 1, [_consumable_reward()]):
		return false
	var before: Array[Dictionary] = _copy_rows(_round_state(session, 0).carried_items)
	var repeated: bool = _reward_service.resolve_overflow_discard(
		session, 1, [_consumable_reward()]
	)
	return (
		not invalid_result
		and _round_state(invalid_session, 0).carried_items == invalid_before
		and not repeated
		and _round_state(session, 0).carried_items == before
	)


func _overflow_session(player_count: int = 1, capacity: int = 3) -> LootRewardSession:
	var reward: RewardDefinition = _consumable_reward()
	var reward_set: Array[RewardDefinition] = [reward]
	var session: LootRewardSession = _reward_service.build_session(
		_players(player_count), _characters, _map, reward_set,
		SequenceRewardRollSource.new([0]), &"m9e_d_overflow"
	)
	var state: RoundLootInventoryState = _round_state(session, 0)
	state.capacity = capacity
	var carried_item_ids: Array[String] = [
		"test_extra_action", "test_all_others_minus_1_move", "test_extra_action"
	]
	for item_id: String in carried_item_ids:
		if state.carried_items.size() >= capacity:
			break
		state.carried_items.append({"item_id": item_id})
	_reward_service.resolve_trace(
		session, session.players[0].player_id, [&"house_a_1"], reward_set
	)
	return session


func _confirm(session: LootRewardSession) -> EquipmentManagementSession:
	for player: LootMovementPlayerState in session.movement_session.player_states:
		player.remaining_moves = 0
	session.phase = LootRewardSession.Phase.LOOT_END_CONFIRMATION_READY
	var management: EquipmentManagementSession = _end_service.begin(session)
	if management == null:
		return null
	if not _end_service.confirm(
		management, session.players[0].player_id, session, _items
	):
		return null
	return management


func _players(count: int) -> Array[PlayerPhaseState]:
	var result: Array[PlayerPhaseState] = []
	for index: int in range(count):
		var player := PlayerPhaseState.new()
		player.player_id = StringName("m9e_d_player_%d" % (index + 1))
		player.seat_index = index
		player.character_id = _characters[index].character_id
		result.append(player)
	return result


func _round_state(session: LootRewardSession, index: int) -> RoundLootInventoryState:
	return session.find_round_loot_state(session.players[index].player_id)


func _consumable_reward() -> RewardDefinition:
	for reward: RewardDefinition in _rewards:
		if reward.reward_type == RewardDefinition.Type.CONSUMABLE_ITEM:
			return reward
	return null


func _count_item(rows: Array[Dictionary], item_id: StringName) -> int:
	var count := 0
	for row: Dictionary in rows:
		if StringName(row.get("item_id", "")) == item_id:
			count += 1
	return count


func _copy_rows(rows: Array[Dictionary]) -> Array[Dictionary]:
	var copy: Array[Dictionary] = []
	for row: Dictionary in rows:
		copy.append(row.duplicate(true))
	return copy


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "PF-M9E-D explicit Bag overflow choice invariant",
	})
