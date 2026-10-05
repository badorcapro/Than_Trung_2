class_name Gd2ProductionRewardTablesTestSuite
extends RefCounted

const REPOSITORY := preload(
	"res://scripts/application/loot/ProductionRewardRepository.gd"
)
const ITEM_REPOSITORY := preload(
	"res://scripts/application/loot/ProductionConsumableRepository.gd"
)
const VALIDATOR := preload(
	"res://scripts/domain/loot/ProductionRewardContentValidator.gd"
)
const CHARACTER_REPOSITORY := preload(
	"res://scripts/application/characters/ProductionCharacterRepository.gd"
)
const SEEDED_ROLL_SOURCE := preload(
	"res://scripts/infrastructure/SeededRewardRollSource.gd"
)
const SEQUENCE_ROLL_SOURCE := preload(
	"res://scripts/infrastructure/SequenceRewardRollSource.gd"
)
const INTEGRATED_SESSION := preload(
	"res://scripts/application/mvp/MvpIntegratedCaseLootSession.gd"
)
const MATCH_STATE := preload("res://scripts/domain/mvp/MvpMatchState.gd")
const ROUND_STATE := preload("res://scripts/domain/mvp/MvpRoundState.gd")

var rewards: Array[RewardDefinition] = []
var tables: Array[RewardZoneTableDefinition] = []
var items: Array[ConsumableItemDefinition] = []
var characters: Array[CharacterDefinition] = []
var map_definition: LootMapDefinition
var snapshot_service := RewardSnapshotService.new()
var reward_service := LootRewardService.new()


func run() -> Array[Dictionary]:
	rewards = REPOSITORY.load_rewards()
	tables = REPOSITORY.load_tables()
	items = ITEM_REPOSITORY.load_all()
	characters = CHARACTER_REPOSITORY.load_all()
	map_definition = Gd2FixtureRepository.load_production_map()
	var rows: Array[Dictionary] = []
	rows.append(_row("GĐ2 production reward IDs and values are canonical", _reward_contract()))
	rows.append(_row("GĐ2 production rewards are repeatable non-test resources", _reward_flags()))
	rows.append(_row("GĐ2 production reward tables cover three canonical zones", _table_zones()))
	rows.append(_row("GĐ2 HOUSE reward weights are canonical", _weights_match(&"HOUSE", [26, 22, 13, 9, 7, 6, 5, 6, 3, 3])))
	rows.append(_row("GĐ2 MIDDLE reward weights are canonical", _weights_match(&"MIDDLE", [15, 15, 15, 12, 10, 9, 9, 7, 4, 4])))
	rows.append(_row("GĐ2 POST_MAUSOLEUM reward weights are canonical", _weights_match(&"POST_MAUSOLEUM", [8, 8, 16, 13, 13, 11, 13, 8, 5, 5])))
	rows.append(_row("GĐ2 production zone weights total 100", _all_weight_totals_are_100()))
	rows.append(_row("GĐ2 production reward density is 75 percent in every zone", _all_density_is_75()))
	rows.append(_row("GĐ2 production reward content passes scoped validation", VALIDATOR.new().validate(rewards, tables, map_definition, items).is_empty()))
	rows.append(_row("GĐ2 same reward seed builds the same snapshot", _same_seed_is_deterministic()))
	rows.append(_row("GĐ2 different reward seeds can change the snapshot", _different_seed_changes_snapshot()))
	rows.append(_row("GĐ2 production spawn nodes never receive rewards", _kind_has_no_snapshots(&"ORIGIN_SPAWN")))
	rows.append(_row("GĐ2 production Central Hub never receives rewards", _node_has_no_snapshot(&"central_hub")))
	rows.append(_row("GĐ2 production Mausoleum Hub never receives rewards", _node_has_no_snapshot(&"mausoleum_hub")))
	rows.append(_row("GĐ2 production HOUSE path nodes are reward eligible", _zone_is_eligible(&"HOUSE")))
	rows.append(_row("GĐ2 production MIDDLE path nodes are reward eligible", _zone_is_eligible(&"MIDDLE")))
	rows.append(_row("GĐ2 production final and END nodes use POST_MAUSOLEUM", _post_zone_and_end_are_eligible()))
	rows.append(_row("GĐ2 empty reward nodes traverse without error", _empty_nodes_are_safe()))
	rows.append(_row("GĐ2 multiple reward nodes resolve in traversal order", _multi_node_trace_resolves()))
	rows.append(_row("GĐ2 repeatable production node rewards different players", _repeatable_across_players()))
	rows.append(_row("GĐ2 reward snapshot stays fixed and serializes with the Round", _snapshot_is_stable_and_serialized()))
	rows.append(_row("GĐ2 production rewards grant directly without consuming Bag", _direct_resource_bypasses_bag()))
	rows.append(_row("PF production Loot uses seeded production reward content", _player_flow_uses_production_content()))
	rows.append(_row("GĐ2 TEST fixtures retain sequence rewards and production map topology", _fixture_and_map_boundaries_remain()))
	return rows


func _row(name: String, passed: bool) -> Dictionary:
	return {
		"name": name,
		"passed": passed,
		"detail": "GĐ2 production reward-table invariant",
	}


func _reward_contract() -> bool:
	var expected: Dictionary = {
		"prod_silver_small": [RewardDefinition.Type.SILVER_COIN, 2],
		"prod_silver_large": [RewardDefinition.Type.SILVER_COIN, 5],
		"prod_orb_1": [RewardDefinition.Type.ORB, 1],
		"prod_gacha_ticket_1": [RewardDefinition.Type.GACHA_TICKET, 1],
		"prod_equipment_exp_small": [RewardDefinition.Type.EQUIPMENT_EXP_MATERIAL, 3],
		"prod_equipment_exp_large": [RewardDefinition.Type.EQUIPMENT_EXP_MATERIAL, 6],
		"prod_exchange_material_1": [RewardDefinition.Type.EQUIPMENT_EXCHANGE_MATERIAL, 1],
		"prod_consumable_hanh_lo_phu": [RewardDefinition.Type.CONSUMABLE_ITEM, 1],
		"prod_consumable_lenh_bai_thong_hanh": [RewardDefinition.Type.CONSUMABLE_ITEM, 1],
		"prod_consumable_ngu_ma_lenh": [RewardDefinition.Type.CONSUMABLE_ITEM, 1],
	}
	if rewards.size() != expected.size():
		return false
	for reward: RewardDefinition in rewards:
		var values: Array = expected.get(String(reward.reward_id), [])
		if values.size() != 2 or reward.reward_type != int(values[0]) or reward.amount != int(values[1]):
			return false
	return true


func _reward_flags() -> bool:
	for reward: RewardDefinition in rewards:
		if (
			reward == null
			or reward.test_only_not_canon_locked
			or reward.repeat_policy != RewardDefinition.RepeatPolicy.REPEATABLE
		):
			return false
		if reward.reward_type == RewardDefinition.Type.CONSUMABLE_ITEM:
			if reward.item_id == &"" or reward.amount != 1:
				return false
		elif reward.item_id != &"":
			return false
	return true


func _table_zones() -> bool:
	var zones: Array[StringName] = []
	for table: RewardZoneTableDefinition in tables:
		zones.append(table.zone_id)
	return zones == [&"HOUSE", &"MIDDLE", &"POST_MAUSOLEUM"]


func _weights_match(zone_id: StringName, expected_weights: Array) -> bool:
	var expected_ids: Array[StringName] = [
		&"prod_silver_small",
		&"prod_equipment_exp_small",
		&"prod_orb_1",
		&"prod_silver_large",
		&"prod_equipment_exp_large",
		&"prod_exchange_material_1",
		&"prod_gacha_ticket_1",
		&"prod_consumable_hanh_lo_phu",
		&"prod_consumable_lenh_bai_thong_hanh",
		&"prod_consumable_ngu_ma_lenh",
	]
	var table: RewardZoneTableDefinition = REPOSITORY.find_table(tables, zone_id)
	if table == null or table.entries.size() != expected_ids.size():
		return false
	for index: int in range(expected_ids.size()):
		var entry: WeightedRewardEntry = table.entries[index]
		if entry.reward_id != expected_ids[index] or entry.weight != int(expected_weights[index]):
			return false
	return true


func _all_weight_totals_are_100() -> bool:
	for table: RewardZoneTableDefinition in tables:
		if table.total_weight() != 100:
			return false
	return tables.size() == 3


func _all_density_is_75() -> bool:
	for table: RewardZoneTableDefinition in tables:
		if table.density_percent != 75:
			return false
	return tables.size() == 3


func _snapshot(seed_value: int) -> Array[RewardNodeSnapshot]:
	return snapshot_service.build_weighted_reward_snapshot(
		&"production_reward_test_round",
		map_definition,
		rewards,
		tables,
		SEEDED_ROLL_SOURCE.new(seed_value)
	)


func _snapshot_dicts(seed_value: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for snapshot: RewardNodeSnapshot in _snapshot(seed_value):
		result.append(snapshot.to_dict())
	return result


func _same_seed_is_deterministic() -> bool:
	return _snapshot_dicts(24001) == _snapshot_dicts(24001)


func _different_seed_changes_snapshot() -> bool:
	return _snapshot_dicts(24001) != _snapshot_dicts(24002)


func _all_eligible_snapshot() -> Array[RewardNodeSnapshot]:
	return snapshot_service.build_weighted_reward_snapshot(
		&"all_eligible", map_definition, rewards, tables, SEQUENCE_ROLL_SOURCE.new([0])
	)


func _kind_has_no_snapshots(node_kind: StringName) -> bool:
	var snapshots: Array[RewardNodeSnapshot] = _all_eligible_snapshot()
	for node: LootNodeDefinition in map_definition.nodes:
		if node.node_kind == node_kind and _find_snapshot(snapshots, node.node_id) != null:
			return false
	return true


func _node_has_no_snapshot(node_id: StringName) -> bool:
	return _find_snapshot(_all_eligible_snapshot(), node_id) == null


func _zone_is_eligible(zone_id: StringName) -> bool:
	var snapshots: Array[RewardNodeSnapshot] = _all_eligible_snapshot()
	for node: LootNodeDefinition in map_definition.nodes:
		if snapshot_service.production_zone_for_node(node) == zone_id:
			return _find_snapshot(snapshots, node.node_id) != null
	return false


func _post_zone_and_end_are_eligible() -> bool:
	var snapshots: Array[RewardNodeSnapshot] = _all_eligible_snapshot()
	var saw_path := false
	var saw_end := false
	for node: LootNodeDefinition in map_definition.nodes:
		if snapshot_service.production_zone_for_node(node) != &"POST_MAUSOLEUM":
			continue
		if _find_snapshot(snapshots, node.node_id) == null:
			return false
		saw_end = saw_end or node.node_kind == &"END"
		saw_path = saw_path or node.node_kind == &"FINAL_PATH"
	return saw_path and saw_end


func _empty_nodes_are_safe() -> bool:
	var session: LootRewardSession = _session(SEQUENCE_ROLL_SOURCE.new([99]))
	if session == null or not session.reward_snapshots.is_empty():
		return false
	var trace: Array[StringName] = [&"hoang_lane_a_1", &"middle_lane_1_1", &"final_lane_1_1"]
	return reward_service.resolve_trace(session, session.players[0].player_id, trace, rewards) and session.reward_history.is_empty()


func _multi_node_trace_resolves() -> bool:
	var session: LootRewardSession = _session(SEQUENCE_ROLL_SOURCE.new([0]))
	var trace: Array[StringName] = [&"hoang_lane_a_1", &"hoang_lane_a_2"]
	reward_service.resolve_trace(session, session.players[0].player_id, trace, rewards)
	return (
		session.reward_history.size() == 2
		and session.reward_history[0].node_id == trace[0]
		and session.reward_history[1].node_id == trace[1]
	)


func _repeatable_across_players() -> bool:
	var session: LootRewardSession = _session(SEQUENCE_ROLL_SOURCE.new([0]))
	var node_id := &"hoang_lane_a_1"
	reward_service.resolve_trace(session, session.players[0].player_id, [node_id], rewards)
	reward_service.resolve_trace(session, session.players[1].player_id, [node_id], rewards)
	return session.players[0].silver_coin_count == 2 and session.players[1].silver_coin_count == 2


func _snapshot_is_stable_and_serialized() -> bool:
	var session: LootRewardSession = _session(SEEDED_ROLL_SOURCE.new(24001))
	if session == null or session.reward_snapshots.is_empty():
		return false
	var before: Array[Dictionary] = []
	for snapshot: RewardNodeSnapshot in session.reward_snapshots:
		before.append(snapshot.to_dict())
	var reward_node_id: StringName = session.reward_snapshots[0].node_id
	reward_service.resolve_trace(session, session.players[0].player_id, [reward_node_id], rewards)
	var restored := LootRewardSession.from_dict(session.to_dict())
	var after: Array[Dictionary] = []
	for snapshot: RewardNodeSnapshot in restored.reward_snapshots:
		after.append(snapshot.to_dict())
	return before == after


func _direct_resource_bypasses_bag() -> bool:
	var session: LootRewardSession = _session(SEQUENCE_ROLL_SOURCE.new([0]))
	var player: PlayerPhaseState = session.players[0]
	var round_loot: RoundLootInventoryState = session.find_round_loot_state(player.player_id)
	reward_service.resolve_trace(session, player.player_id, [&"hoang_lane_a_1"], rewards)
	return player.silver_coin_count == 2 and round_loot.carried_items.is_empty()


func _player_flow_uses_production_content() -> bool:
	var flow := INTEGRATED_SESSION.new()
	flow.match_state = MATCH_STATE.new()
	flow.match_state.case_generation_seed = 24001
	flow.round_state = ROUND_STATE.new()
	flow.round_state.round_id = &"player_facing_reward_round"
	flow.round_state.round_number = 2
	flow._characters = characters
	flow._map_definition = map_definition
	var first: LootRewardSession = flow._build_loot_reward_session(_players(), [0])
	var second: LootRewardSession = flow._build_loot_reward_session(_players(), [99])
	if (
		first == null
		or second == null
		or flow._rewards.size() != 10
		or flow.consumable_item_definitions().size() != 3
		or first.reward_snapshots.is_empty()
	):
		return false
	if _session_snapshot_rows(first) != _session_snapshot_rows(second):
		return false
	for snapshot: RewardNodeSnapshot in first.reward_snapshots:
		if not String(snapshot.reward_definition_id).begins_with("prod_"):
			return false
	return true


func _session_snapshot_rows(session: LootRewardSession) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for snapshot: RewardNodeSnapshot in session.reward_snapshots:
		result.append(snapshot.to_dict())
	return result


func _fixture_and_map_boundaries_remain() -> bool:
	var fixture_map: LootMapDefinition = Gd2FixtureRepository.load_m3_map()
	var fixture_rewards: Array[RewardDefinition] = Gd2FixtureRepository.load_m4_rewards()
	var fixture_snapshots: Array[RewardNodeSnapshot] = snapshot_service.build_reward_snapshot(
		&"fixture_round", fixture_map, fixture_rewards, SEQUENCE_ROLL_SOURCE.new([0])
	)
	return (
		fixture_map.test_only_not_canon_locked
		and not fixture_snapshots.is_empty()
		and fixture_snapshots[0].reward_definition_id == fixture_rewards[0].reward_id
		and map_definition.nodes.size() == 77
		and map_definition.find_node(&"central_hub").world_position == Vector2(1600, 1500)
		and map_definition.find_node(&"mausoleum_hub").world_position == Vector2(1600, 2600)
	)


func _session(roll_source: RewardRollSource) -> LootRewardSession:
	return reward_service.build_session(
		_players(),
		characters,
		map_definition,
		rewards,
		roll_source,
		&"production_reward_test_round",
		tables
	)


func _players() -> Array[PlayerPhaseState]:
	var result: Array[PlayerPhaseState] = []
	for index: int in range(2):
		var player := PlayerPhaseState.new()
		player.player_id = StringName("production_reward_player_%d" % (index + 1))
		player.seat_index = index
		player.character_id = characters[index].character_id
		result.append(player)
	return result


func _find_snapshot(
	snapshots: Array[RewardNodeSnapshot], node_id: StringName
) -> RewardNodeSnapshot:
	for snapshot: RewardNodeSnapshot in snapshots:
		if snapshot.node_id == node_id:
			return snapshot
	return null
