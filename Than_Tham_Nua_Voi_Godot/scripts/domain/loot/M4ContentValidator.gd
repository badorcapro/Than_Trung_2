class_name M4ContentValidator
extends RefCounted

func validate_rewards(rewards: Array[RewardDefinition], items: Array[ConsumableItemDefinition]) -> LootValidationReport:
	var report := LootValidationReport.new()
	var item_ids: Dictionary = {}
	for item: ConsumableItemDefinition in items:
		if item == null or item.item_id.is_empty(): report.add_error(&"ITEM_ID_MISSING", "Consumable item_id is required"); continue
		item_ids[item.item_id] = true
		if item.magnitude <= 0: report.add_error(&"ITEM_MAGNITUDE_INVALID", "Item magnitude must be positive", String(item.item_id))
		if item.effect_type < ConsumableItemDefinition.EffectType.MOVE_DISTANCE_BONUS or item.effect_type > ConsumableItemDefinition.EffectType.MOVEMENT_ACTION_PENALTY: report.add_error(&"ITEM_EFFECT_TYPE_INVALID", "Unsupported effect type", String(item.item_id))
		if item.duration < TemporaryEffectState.Duration.THIS_MOVE or item.duration > TemporaryEffectState.Duration.THIS_ROUND: report.add_error(&"ITEM_DURATION_INVALID", "Unsupported item duration", String(item.item_id))
		if item.target_scope < ConsumableItemDefinition.TargetScope.SELF or item.target_scope > ConsumableItemDefinition.TargetScope.ALL_OTHER_PLAYERS: report.add_error(&"ITEM_TARGET_SCOPE_INVALID", "Unsupported target scope", String(item.item_id))
	for reward: RewardDefinition in rewards:
		if reward == null or reward.reward_id.is_empty(): report.add_error(&"REWARD_ID_MISSING", "Reward ID is required"); continue
		if reward.amount < 0: report.add_error(&"REWARD_AMOUNT_NEGATIVE", "Reward amount cannot be negative", String(reward.reward_id))
		if reward.reward_type < RewardDefinition.Type.SILVER_COIN or reward.reward_type > RewardDefinition.Type.CONSUMABLE_ITEM: report.add_error(&"REWARD_TYPE_INVALID", "Unknown reward type", String(reward.reward_id))
		if reward.repeat_policy < RewardDefinition.RepeatPolicy.REPEATABLE or reward.repeat_policy > RewardDefinition.RepeatPolicy.ONCE_PER_ROUND_GLOBAL: report.add_error(&"REWARD_REPEAT_POLICY_INVALID", "Unknown repeat policy", String(reward.reward_id))
		if reward.reward_type == RewardDefinition.Type.CONSUMABLE_ITEM and not item_ids.has(reward.item_id): report.add_error(&"REWARD_ITEM_REFERENCE_MISSING", "Consumable reward references unknown item", String(reward.reward_id))
	return report

func validate_bag(state: RoundLootInventoryState, overflow_active: bool) -> LootValidationReport:
	var report := LootValidationReport.new()
	if state == null:
		report.add_error(&"BAG_STATE_MISSING", "Round map-loot state is required")
		return report
	if state.capacity < 0: report.add_error(&"BAG_CAPACITY_INVALID", "Bag capacity cannot be negative")
	if state.carried_items.size() > state.capacity and not overflow_active: report.add_error(&"BAG_OVER_CAPACITY", "Round map loot exceeds Bag capacity", String(state.player_id))
	return report

func validate_effect(effect: TemporaryEffectState) -> LootValidationReport:
	var report := LootValidationReport.new()
	if effect == null: report.add_error(&"TEMP_EFFECT_NULL", "Temporary effect is required"); return report
	if effect.effect_id.is_empty() or effect.source_id.is_empty(): report.add_error(&"TEMP_EFFECT_SOURCE_INVALID", "Effect ID and source are required")
	if effect.duration < TemporaryEffectState.Duration.THIS_MOVE or effect.duration > TemporaryEffectState.Duration.THIS_ROUND: report.add_error(&"TEMP_EFFECT_DURATION_INVALID", "Unsupported duration")
	if effect.active and effect.remaining <= 0: report.add_error(&"TEMP_EFFECT_EXPIRED_INCONSISTENT", "Active effect must have remaining duration")
	return report
