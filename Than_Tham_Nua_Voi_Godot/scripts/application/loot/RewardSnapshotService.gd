class_name RewardSnapshotService
extends RefCounted

func build_reward_snapshot(round_id: StringName, map_definition: LootMapDefinition, rewards: Array[RewardDefinition], roll_source: RewardRollSource) -> Array[RewardNodeSnapshot]:
	var snapshots: Array[RewardNodeSnapshot] = []
	if map_definition == null or rewards.is_empty() or roll_source == null: return snapshots
	for node: LootNodeDefinition in map_definition.nodes:
		if node == null or node.node_kind == &"ORIGIN_SPAWN": continue
		var index: int = roll_source.pick_index(rewards.size())
		if index < 0: continue
		var reward: RewardDefinition = rewards[index]
		var snapshot := RewardNodeSnapshot.new()
		snapshot.node_id = node.node_id; snapshot.reward_definition_id = reward.reward_id; snapshot.round_id = round_id
		snapshot.policy_id = &"REPEATABLE" if reward.repeat_policy == RewardDefinition.RepeatPolicy.REPEATABLE else &"ONCE_PER_ROUND_GLOBAL"
		snapshot.remaining_hits = -1 if reward.repeat_policy == RewardDefinition.RepeatPolicy.REPEATABLE else 1
		snapshots.append(snapshot)
	return snapshots


func build_weighted_reward_snapshot(
	round_id: StringName,
	map_definition: LootMapDefinition,
	rewards: Array[RewardDefinition],
	tables: Array[RewardZoneTableDefinition],
	roll_source: RewardRollSource
) -> Array[RewardNodeSnapshot]:
	var snapshots: Array[RewardNodeSnapshot] = []
	if map_definition == null or rewards.is_empty() or tables.is_empty() or roll_source == null:
		return snapshots
	for node: LootNodeDefinition in map_definition.nodes:
		if node == null:
			continue
		if node.node_id == &"royal_vault_hub" or node.tags.has(&"ROYAL_VAULT"):
			var high_rewards: Array[RewardDefinition] = []
			for r: RewardDefinition in rewards:
				if r != null and r.tier == RewardDefinition.Tier.HIGH:
					high_rewards.append(r)
			if not high_rewards.is_empty():
				var high_pick: int = roll_source.pick_index(high_rewards.size())
				var selected_high: RewardDefinition = high_rewards[maxi(0, high_pick % high_rewards.size())]
				var vault_snapshot := RewardNodeSnapshot.new()
				vault_snapshot.node_id = node.node_id
				vault_snapshot.reward_definition_id = selected_high.reward_id
				vault_snapshot.round_id = round_id
				vault_snapshot.policy_id = &"ONCE_PER_ROUND_GLOBAL"
				vault_snapshot.remaining_hits = 1
				snapshots.append(vault_snapshot)
			continue
		var zone_id: StringName = production_zone_for_node(node)
		if zone_id == &"":
			continue
		var table: RewardZoneTableDefinition = _find_table(tables, zone_id)
		if table == null:
			continue
		var density_roll: int = roll_source.pick_index(100)
		if density_roll < 0 or density_roll >= table.density_percent:
			continue
		var reward_id: StringName = table.pick_reward_id(roll_source)
		var reward: RewardDefinition = _find_reward(rewards, reward_id)
		if reward == null:
			continue
		var snapshot := RewardNodeSnapshot.new()
		snapshot.node_id = node.node_id
		snapshot.reward_definition_id = reward.reward_id
		snapshot.round_id = round_id
		snapshot.policy_id = (
			&"REPEATABLE"
			if reward.repeat_policy == RewardDefinition.RepeatPolicy.REPEATABLE
			else &"ONCE_PER_ROUND_GLOBAL"
		)
		snapshot.remaining_hits = (
			-1 if reward.repeat_policy == RewardDefinition.RepeatPolicy.REPEATABLE else 1
		)
		snapshots.append(snapshot)
	return snapshots


func production_zone_for_node(node: LootNodeDefinition) -> StringName:
	if node == null:
		return &""
	if node.node_kind in [&"ORIGIN_SPAWN", &"CENTRAL_HUB", &"MAUSOLEUM_HUB"]:
		return &""
	if node.node_kind == &"END" or node.tags.has(&"POST_MAUSOLEUM"):
		return &"POST_MAUSOLEUM"
	if node.tags.has(&"MIDDLE"):
		return &"MIDDLE"
	if node.tags.has(&"HOUSE"):
		return &"HOUSE"
	return &""


func _find_table(
	tables: Array[RewardZoneTableDefinition], zone_id: StringName
) -> RewardZoneTableDefinition:
	for table: RewardZoneTableDefinition in tables:
		if table != null and table.zone_id == zone_id:
			return table
	return null


func _find_reward(
	rewards: Array[RewardDefinition], reward_id: StringName
) -> RewardDefinition:
	for reward: RewardDefinition in rewards:
		if reward != null and reward.reward_id == reward_id:
			return reward
	return null
