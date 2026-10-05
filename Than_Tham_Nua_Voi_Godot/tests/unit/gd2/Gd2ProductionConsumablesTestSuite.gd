class_name Gd2ProductionConsumablesTestSuite
extends RefCounted

const ITEM_REPOSITORY := preload(
	"res://scripts/application/loot/ProductionConsumableRepository.gd"
)
const REWARD_REPOSITORY := preload(
	"res://scripts/application/loot/ProductionRewardRepository.gd"
)
const CHARACTER_REPOSITORY := preload(
	"res://scripts/application/characters/ProductionCharacterRepository.gd"
)
const CONTENT_VALIDATOR := preload(
	"res://scripts/domain/loot/ProductionConsumableContentValidator.gd"
)
const INTEGRATED_SESSION := preload(
	"res://scripts/application/mvp/MvpIntegratedCaseLootSession.gd"
)
const ITEM_SERVICE := preload("res://scripts/application/loot/ConsumableItemService.gd")
const END_SERVICE := preload(
	"res://scripts/application/loot/LootEndConfirmationService.gd"
)
const SEQUENCE_MOVEMENT := preload(
	"res://scripts/infrastructure/SequenceMovementRollSource.gd"
)

var items: Array[ConsumableItemDefinition] = []
var rewards: Array[RewardDefinition] = []
var tables: Array[RewardZoneTableDefinition] = []
var characters: Array[CharacterDefinition] = []
var map_definition: LootMapDefinition
var reward_service := LootRewardService.new()
var end_service: END_SERVICE = END_SERVICE.new()


func run() -> Array[Dictionary]:
	items = ITEM_REPOSITORY.load_all()
	rewards = REWARD_REPOSITORY.load_rewards()
	tables = REWARD_REPOSITORY.load_tables()
	characters = CHARACTER_REPOSITORY.load_all()
	map_definition = Gd2FixtureRepository.load_production_map()
	var rows: Array[Dictionary] = []
	_add(rows, "GĐ2 production consumable repository contains exactly three items", items.size() == 3)
	_add(rows, "GĐ2 production consumables exclude TEST item IDs", _no_test_item_ids())
	_add(rows, "GĐ2 production consumable IDs and names are canonical", _canonical_ids_and_names())
	_add(rows, "GĐ2 production consumable effects are canonical", _canonical_effects())
	_add(rows, "GĐ2 production consumable magnitudes are one", _all_magnitudes_are_one())
	_add(rows, "GĐ2 production consumable scopes are SELF", _all_scopes_are_self())
	_add(rows, "GĐ2 production consumable durations are canonical", _canonical_durations())
	_add(rows, "GĐ2 production consumable flags are non-test", _all_production_flags())
	_add(rows, "GĐ2 production reward catalog contains ten definitions", rewards.size() == 10)
	_add(rows, "GĐ2 production consumable reward IDs resolve", _consumable_rewards_resolve())
	_add(rows, "GĐ2 production consumable rewards have amount one", _consumable_reward_amounts())
	_add(rows, "GĐ2 production consumable rewards are repeatable", _consumable_rewards_repeatable())
	_add(rows, "GĐ2 production consumable zone weights are exact", _exact_zone_weights())
	_add(rows, "GĐ2 production reward tables total one hundred", _table_totals())
	_add(rows, "GĐ2 seeded production snapshots can select consumables", _seeded_snapshot_selects_consumable())
	_add(rows, "GĐ2 production consumable reward enters Round Bag", _reward_enters_round_bag())
	_add(rows, "GĐ2 production consumable consumes one Bag slot", _reward_consumes_one_slot())
	_add(rows, "GĐ2 Hành Lộ Phù works from Round Bag", _hanh_lo_phu_works(ITEM_SERVICE.SOURCE_ROUND_LOOT))
	_add(rows, "GĐ2 Hành Lộ Phù works from persistent inventory", _hanh_lo_phu_works(ITEM_SERVICE.SOURCE_PERSISTENT))
	_add(rows, "GĐ2 Lệnh Bài Thông Hành adds exactly one action", _lenh_bai_adds_one_action())
	_add(rows, "GĐ2 extra-action marker does not repeat", _lenh_bai_marker_does_not_repeat())
	_add(rows, "GĐ2 Ngự Mã Lệnh raises Speed for the next movement", _ngu_ma_next_move_uses_speed_bonus())
	_add(rows, "GĐ2 SPEED_BONUS expires after the next movement", _ngu_ma_expires_after_move())
	_add(rows, "GĐ2 successful production item use removes one copy", _successful_use_removes_one_copy())
	_add(rows, "GĐ2 failed production item use preserves the item", _failed_use_preserves_item())
	_add(rows, "GĐ2 failed item use preserves the turn allowance", _failed_use_preserves_allowance())
	_add(rows, "GĐ2 one-item limit is shared across both sources", _shared_source_allowance())
	_add(rows, "GĐ2 unused production item transfers exactly once", _unused_item_transfers_once())
	_add(rows, "GĐ2 transferred production item keeps its stable ID", _transferred_item_keeps_id())
	_add(rows, "PF Item Window resolves authoritative production names", _authoritative_display_names())
	_add(rows, "PF normal production flow loads no TEST consumables", _normal_flow_has_only_production_items())
	_add(rows, "GĐ2 production consumables preserve Bag overflow behavior", _overflow_is_unchanged())
	_add(rows, "GĐ2 production consumables preserve direct-resource rewards", _direct_resource_is_unchanged())
	_add(rows, "GĐ2 production map and Character content remain unchanged", _map_and_characters_are_unchanged())
	return rows


func _canonical_contract() -> Dictionary:
	return {
		"consumable_hanh_lo_phu": ["Hành Lộ Phù", ConsumableItemDefinition.EffectType.MOVE_DISTANCE_BONUS, TemporaryEffectState.Duration.THIS_MOVE],
		"consumable_lenh_bai_thong_hanh": ["Lệnh Bài Thông Hành", ConsumableItemDefinition.EffectType.EXTRA_MOVEMENT_ACTION, TemporaryEffectState.Duration.THIS_ROUND],
		"consumable_ngu_ma_lenh": ["Ngự Mã Lệnh", ConsumableItemDefinition.EffectType.SPEED_BONUS, TemporaryEffectState.Duration.THIS_MOVE],
	}


func _no_test_item_ids() -> bool:
	for item: ConsumableItemDefinition in items:
		if String(item.item_id).begins_with("test_"):
			return false
	return true


func _canonical_ids_and_names() -> bool:
	var expected := _canonical_contract()
	for item: ConsumableItemDefinition in items:
		var values: Array = expected.get(String(item.item_id), [])
		if values.size() != 3 or item.display_name != String(values[0]):
			return false
	return items.size() == expected.size()


func _canonical_effects() -> bool:
	var expected := _canonical_contract()
	for item: ConsumableItemDefinition in items:
		var values: Array = expected.get(String(item.item_id), [])
		if values.size() != 3 or item.effect_type != int(values[1]):
			return false
	return true


func _all_magnitudes_are_one() -> bool:
	for item: ConsumableItemDefinition in items:
		if item.magnitude != 1:
			return false
	return true


func _all_scopes_are_self() -> bool:
	for item: ConsumableItemDefinition in items:
		if item.target_scope != ConsumableItemDefinition.TargetScope.SELF:
			return false
	return true


func _canonical_durations() -> bool:
	var expected := _canonical_contract()
	for item: ConsumableItemDefinition in items:
		var values: Array = expected.get(String(item.item_id), [])
		if values.size() != 3 or item.duration != int(values[2]):
			return false
	return true


func _all_production_flags() -> bool:
	if not CONTENT_VALIDATOR.new().validate(items).is_empty():
		return false
	for item: ConsumableItemDefinition in items:
		if item.test_only_not_canon_locked:
			return false
	return true


func _consumable_rewards() -> Array[RewardDefinition]:
	var result: Array[RewardDefinition] = []
	for reward: RewardDefinition in rewards:
		if reward.reward_type == RewardDefinition.Type.CONSUMABLE_ITEM:
			result.append(reward)
	return result


func _consumable_rewards_resolve() -> bool:
	var expected := {
		"prod_consumable_hanh_lo_phu": "consumable_hanh_lo_phu",
		"prod_consumable_lenh_bai_thong_hanh": "consumable_lenh_bai_thong_hanh",
		"prod_consumable_ngu_ma_lenh": "consumable_ngu_ma_lenh",
	}
	var found: Array[RewardDefinition] = _consumable_rewards()
	for reward: RewardDefinition in found:
		if String(reward.item_id) != String(expected.get(String(reward.reward_id), "")):
			return false
		if ITEM_REPOSITORY.find_item(items, reward.item_id) == null:
			return false
	return found.size() == expected.size()


func _consumable_reward_amounts() -> bool:
	for reward: RewardDefinition in _consumable_rewards():
		if reward.amount != 1:
			return false
	return _consumable_rewards().size() == 3


func _consumable_rewards_repeatable() -> bool:
	for reward: RewardDefinition in _consumable_rewards():
		if reward.repeat_policy != RewardDefinition.RepeatPolicy.REPEATABLE:
			return false
	return _consumable_rewards().size() == 3


func _exact_zone_weights() -> bool:
	return (
		_weights(&"HOUSE") == [26, 22, 13, 9, 7, 6, 5, 6, 3, 3]
		and _weights(&"MIDDLE") == [15, 15, 15, 12, 10, 9, 9, 7, 4, 4]
		and _weights(&"POST_MAUSOLEUM") == [8, 8, 16, 13, 13, 11, 13, 8, 5, 5]
	)


func _weights(zone_id: StringName) -> Array[int]:
	var result: Array[int] = []
	var table: RewardZoneTableDefinition = REWARD_REPOSITORY.find_table(tables, zone_id)
	if table != null:
		for entry: WeightedRewardEntry in table.entries:
			result.append(entry.weight)
	return result


func _table_totals() -> bool:
	for table: RewardZoneTableDefinition in tables:
		if table.entries.size() != 10 or table.total_weight() != 100:
			return false
	return tables.size() == 3


func _seeded_snapshot_selects_consumable() -> bool:
	var service := RewardSnapshotService.new()
	for seed_value: int in range(24001, 24033):
		var snapshots: Array[RewardNodeSnapshot] = service.build_weighted_reward_snapshot(
			&"production_consumable_seeded", map_definition, rewards, tables,
			SeededRewardRollSource.new(seed_value)
		)
		for snapshot: RewardNodeSnapshot in snapshots:
			if String(snapshot.reward_definition_id).begins_with("prod_consumable_"):
				return true
	return false


func _reward_enters_round_bag() -> bool:
	var session: LootRewardSession = _resolved_item_reward(&"prod_consumable_hanh_lo_phu")
	var state: RoundLootInventoryState = _round_state(session)
	return (
		state != null
		and state.carried_items == [{"item_id": "consumable_hanh_lo_phu"}]
		and session.players[0].consumable_inventory.is_empty()
	)


func _reward_consumes_one_slot() -> bool:
	var session: LootRewardSession = _resolved_item_reward(&"prod_consumable_hanh_lo_phu")
	var state: RoundLootInventoryState = _round_state(session)
	return state != null and state.capacity == 2 and state.carried_items.size() == 1


func _hanh_lo_phu_works(source: StringName) -> bool:
	var session: LootRewardSession = _movement_session()
	var item_row := {"item_id": "consumable_hanh_lo_phu"}
	if source == ITEM_SERVICE.SOURCE_ROUND_LOOT:
		_round_state(session).carried_items.append(item_row)
	else:
		session.players[0].consumable_inventory.append(item_row)
	var used: ItemUseResult = reward_service.use_item(
		session, &"consumable_hanh_lo_phu", items, source
	)
	reward_service.continue_without_item(session)
	var action: MovementActionResult = reward_service.perform_movement(
		session, map_definition, SEQUENCE_MOVEMENT.new([1]), []
	)
	return used.success and action != null and action.roll_distance == 2


func _lenh_bai_adds_one_action() -> bool:
	var session: LootRewardSession = _movement_session()
	var movement_player: LootMovementPlayerState = session.movement_session.current_player()
	var before := movement_player.remaining_moves
	session.players[0].consumable_inventory.append({"item_id": "consumable_lenh_bai_thong_hanh"})
	var used: ItemUseResult = reward_service.use_item(
		session, &"consumable_lenh_bai_thong_hanh", items, ITEM_SERVICE.SOURCE_PERSISTENT
	)
	return used.success and movement_player.remaining_moves == before + 1


func _lenh_bai_marker_does_not_repeat() -> bool:
	var session: LootRewardSession = _movement_session()
	var movement_player: LootMovementPlayerState = session.movement_session.current_player()
	session.players[0].consumable_inventory.append({"item_id": "consumable_lenh_bai_thong_hanh"})
	reward_service.use_item(
		session, &"consumable_lenh_bai_thong_hanh", items, ITEM_SERVICE.SOURCE_PERSISTENT
	)
	var after_use := movement_player.remaining_moves
	reward_service.continue_without_item(session)
	reward_service.perform_movement(session, map_definition, SEQUENCE_MOVEMENT.new([1]), [])
	return after_use == 3 and movement_player.remaining_moves == 2


func _ngu_ma_movement_bundle() -> Dictionary:
	var session: LootRewardSession = _movement_session()
	var movement_player: LootMovementPlayerState = session.movement_session.current_player()
	session.players[0].consumable_inventory.append({"item_id": "consumable_ngu_ma_lenh"})
	var used: ItemUseResult = reward_service.use_item(
		session, &"consumable_ngu_ma_lenh", items, ITEM_SERVICE.SOURCE_PERSISTENT
	)
	reward_service.continue_without_item(session)
	var first: MovementActionResult = reward_service.perform_movement(
		session, map_definition, SEQUENCE_MOVEMENT.new([3]), []
	)
	var active_after_first := false
	for effect: TemporaryEffectState in movement_player.temporary_effects:
		if effect.effect_kind == &"SPEED_BONUS" and effect.active:
			active_after_first = true
	reward_service.continue_without_item(session)
	var second: MovementActionResult = reward_service.perform_movement(
		session, map_definition, SEQUENCE_MOVEMENT.new([3]), []
	)
	return {"used": used, "first": first, "second": second, "active": active_after_first}


func _ngu_ma_next_move_uses_speed_bonus() -> bool:
	var bundle := _ngu_ma_movement_bundle()
	var used: ItemUseResult = bundle.get("used") as ItemUseResult
	var first: MovementActionResult = bundle.get("first") as MovementActionResult
	return used != null and used.success and first != null and first.roll_distance == 3


func _ngu_ma_expires_after_move() -> bool:
	var bundle := _ngu_ma_movement_bundle()
	var second: MovementActionResult = bundle.get("second") as MovementActionResult
	return not bool(bundle.get("active", true)) and second != null and second.roll_distance == 2


func _successful_use_removes_one_copy() -> bool:
	var session: LootRewardSession = _movement_session()
	session.players[0].consumable_inventory = [
		{"item_id": "consumable_hanh_lo_phu"},
		{"item_id": "consumable_hanh_lo_phu"},
	]
	var result: ItemUseResult = reward_service.use_item(
		session, &"consumable_hanh_lo_phu", items, ITEM_SERVICE.SOURCE_PERSISTENT
	)
	return result.success and session.players[0].consumable_inventory.size() == 1


func _failed_use_bundle() -> Dictionary:
	var session: LootRewardSession = _movement_session()
	session.players[0].consumable_inventory.append({"item_id": "consumable_hanh_lo_phu"})
	session.phase = LootRewardSession.Phase.MOVEMENT
	var result: ItemUseResult = reward_service.use_item(
		session, &"consumable_hanh_lo_phu", items, ITEM_SERVICE.SOURCE_PERSISTENT
	)
	return {"session": session, "result": result}


func _failed_use_preserves_item() -> bool:
	var bundle := _failed_use_bundle()
	var session: LootRewardSession = bundle.get("session") as LootRewardSession
	var result: ItemUseResult = bundle.get("result") as ItemUseResult
	return result != null and not result.success and session.players[0].consumable_inventory.size() == 1


func _failed_use_preserves_allowance() -> bool:
	var bundle := _failed_use_bundle()
	var session: LootRewardSession = bundle.get("session") as LootRewardSession
	return session != null and not session.item_used_this_turn


func _shared_source_allowance() -> bool:
	var session: LootRewardSession = _movement_session()
	session.players[0].consumable_inventory.append({"item_id": "consumable_hanh_lo_phu"})
	_round_state(session).carried_items.append({"item_id": "consumable_ngu_ma_lenh"})
	var first: ItemUseResult = reward_service.use_item(
		session, &"consumable_hanh_lo_phu", items, ITEM_SERVICE.SOURCE_PERSISTENT
	)
	var second: ItemUseResult = reward_service.use_item(
		session, &"consumable_ngu_ma_lenh", items, ITEM_SERVICE.SOURCE_ROUND_LOOT
	)
	return first.success and not second.success and second.code == &"ITEM_LIMIT_REACHED"


func _transfer_bundle() -> Dictionary:
	var session: LootRewardSession = _movement_session()
	_round_state(session).carried_items.append({"item_id": "consumable_ngu_ma_lenh"})
	for player: LootMovementPlayerState in session.movement_session.player_states:
		player.remaining_moves = 0
	session.phase = LootRewardSession.Phase.LOOT_END_CONFIRMATION_READY
	var management: EquipmentManagementSession = end_service.begin(session)
	var first := false
	var second := false
	if management != null:
		first = end_service.confirm(management, session.players[0].player_id, session, items)
		second = end_service.confirm(management, session.players[0].player_id, session, items)
	return {"session": session, "management": management, "first": first, "second": second}


func _unused_item_transfers_once() -> bool:
	var bundle := _transfer_bundle()
	var session: LootRewardSession = bundle.get("session") as LootRewardSession
	var management: EquipmentManagementSession = bundle.get("management") as EquipmentManagementSession
	return (
		bool(bundle.get("first", false))
		and not bool(bundle.get("second", true))
		and session != null
		and management != null
		and _round_state(session).disposition_finalized
		and _round_state(session).transferred_items.size() == 1
		and management.players[0].consumable_inventory.size() == 1
	)


func _transferred_item_keeps_id() -> bool:
	var bundle := _transfer_bundle()
	var management: EquipmentManagementSession = bundle.get("management") as EquipmentManagementSession
	if management == null or management.players[0].consumable_inventory.size() != 1:
		return false
	var restored := EquipmentManagementSession.from_dict(management.to_dict())
	return StringName(restored.players[0].consumable_inventory[0].get("item_id", "")) == &"consumable_ngu_ma_lenh"


func _production_flow() -> MvpIntegratedCaseLootSession:
	var flow: MvpIntegratedCaseLootSession = INTEGRATED_SESSION.new()
	flow.match_state = MvpMatchState.new()
	flow.match_state.case_generation_seed = 24001
	flow.round_state = MvpRoundState.new()
	flow.round_state.round_id = &"production_consumable_flow"
	flow.round_state.round_number = 1
	flow._characters = characters
	flow._map_definition = map_definition
	flow._build_loot_reward_session(_players(), [0])
	return flow


func _authoritative_display_names() -> bool:
	var flow: MvpIntegratedCaseLootSession = _production_flow()
	return (
		flow.consumable_item_display_name(&"consumable_hanh_lo_phu") == "Hành Lộ Phù"
		and flow.consumable_item_display_name(&"consumable_lenh_bai_thong_hanh") == "Lệnh Bài Thông Hành"
		and flow.consumable_item_display_name(&"consumable_ngu_ma_lenh") == "Ngự Mã Lệnh"
		and FileAccess.get_file_as_string(
			"res://scripts/presentation/player_facing/PlayerFacingStartController.gd"
		).contains("case_flow.consumable_item_display_name(item_id)")
	)


func _normal_flow_has_only_production_items() -> bool:
	var flow: MvpIntegratedCaseLootSession = _production_flow()
	var definitions: Array[ConsumableItemDefinition] = flow.consumable_item_definitions()
	if definitions.size() != 3:
		return false
	for definition: ConsumableItemDefinition in definitions:
		if definition.test_only_not_canon_locked or String(definition.item_id).begins_with("test_"):
			return false
	return Gd2FixtureRepository.load_m4_items().size() == 3


func _overflow_is_unchanged() -> bool:
	var reward: RewardDefinition = REWARD_REPOSITORY.find_reward(
		rewards, &"prod_consumable_hanh_lo_phu"
	)
	var reward_set: Array[RewardDefinition] = [reward]
	var session: LootRewardSession = _session(reward_set)
	var state: RoundLootInventoryState = _round_state(session)
	state.carried_items = [
		{"item_id": "consumable_lenh_bai_thong_hanh"},
		{"item_id": "consumable_ngu_ma_lenh"},
	]
	reward_service.resolve_trace(session, session.players[0].player_id, [&"hoang_lane_a_1"], reward_set)
	var pending := session.phase == LootRewardSession.Phase.BAG_OVERFLOW_PENDING
	var skipped := reward_service.resolve_overflow_skip(session, reward_set)
	return pending and skipped and state.carried_items.size() == 2


func _direct_resource_is_unchanged() -> bool:
	var reward: RewardDefinition = REWARD_REPOSITORY.find_reward(rewards, &"prod_silver_small")
	var reward_set: Array[RewardDefinition] = [reward]
	var session: LootRewardSession = _session(reward_set)
	reward_service.resolve_trace(session, session.players[0].player_id, [&"hoang_lane_a_1"], reward_set)
	return session.players[0].silver_coin_count == 2 and _round_state(session).carried_items.is_empty()


func _map_and_characters_are_unchanged() -> bool:
	return (
		map_definition != null
		and map_definition.nodes.size() == 77
		and map_definition.find_node(&"central_hub").world_position == Vector2(1600, 1500)
		and map_definition.find_node(&"mausoleum_hub").world_position == Vector2(1600, 2600)
		and characters.size() == 5
		and characters[0].base_speed == 2
		and characters[0].base_stamina == 2
		and characters[0].base_bag_level == 2
	)


func _resolved_item_reward(reward_id: StringName) -> LootRewardSession:
	var reward: RewardDefinition = REWARD_REPOSITORY.find_reward(rewards, reward_id)
	var reward_set: Array[RewardDefinition] = [reward]
	var session: LootRewardSession = _session(reward_set)
	reward_service.resolve_trace(session, session.players[0].player_id, [&"hoang_lane_a_1"], reward_set)
	return session


func _movement_session() -> LootRewardSession:
	var no_rewards: Array[RewardDefinition] = []
	return _session(no_rewards)


func _session(reward_set: Array[RewardDefinition]) -> LootRewardSession:
	return reward_service.build_session(
		_players(), characters, map_definition, reward_set,
		SequenceRewardRollSource.new([0]), &"production_consumable_round"
	)


func _players() -> Array[PlayerPhaseState]:
	var player := PlayerPhaseState.new()
	player.player_id = &"production_consumable_player"
	player.seat_index = 0
	player.character_id = characters[0].character_id
	var result: Array[PlayerPhaseState] = [player]
	return result


func _round_state(session: LootRewardSession) -> RoundLootInventoryState:
	return session.find_round_loot_state(session.players[0].player_id) if session != null else null


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "GĐ2 production Consumables V1 invariant",
	})
