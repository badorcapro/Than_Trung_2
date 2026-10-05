class_name ProductionRewardContentValidator
extends RefCounted

const PRODUCTION_CONSUMABLE_VALIDATOR := preload(
	"res://scripts/domain/loot/ProductionConsumableContentValidator.gd"
)

const EXPECTED_REWARD_COUNT := 10
const EXPECTED_TABLE_COUNT := 3
const EXPECTED_DENSITY_PERCENT := 75
const EXPECTED_WEIGHT_TOTAL := 100
const EXPECTED_ZONES: Array[StringName] = [&"HOUSE", &"MIDDLE", &"POST_MAUSOLEUM"]
const APPROVED_TYPES: Array[int] = [
	RewardDefinition.Type.SILVER_COIN,
	RewardDefinition.Type.ORB,
	RewardDefinition.Type.GACHA_TICKET,
	RewardDefinition.Type.EQUIPMENT_EXP_MATERIAL,
	RewardDefinition.Type.EQUIPMENT_EXCHANGE_MATERIAL,
	RewardDefinition.Type.CONSUMABLE_ITEM,
]
const EXPECTED_CONSUMABLE_REWARDS := {
	"prod_consumable_hanh_lo_phu": "consumable_hanh_lo_phu",
	"prod_consumable_lenh_bai_thong_hanh": "consumable_lenh_bai_thong_hanh",
	"prod_consumable_ngu_ma_lenh": "consumable_ngu_ma_lenh",
}


func validate(
	rewards: Array[RewardDefinition],
	tables: Array[RewardZoneTableDefinition],
	map_definition: LootMapDefinition = null,
	items: Array[ConsumableItemDefinition] = []
) -> Array[String]:
	var errors: Array[String] = PRODUCTION_CONSUMABLE_VALIDATOR.new().validate(items)
	var reward_ids: Dictionary = {}
	var item_ids: Dictionary = {}
	for item: ConsumableItemDefinition in items:
		if item != null:
			item_ids[String(item.item_id)] = true
	if rewards.size() != EXPECTED_REWARD_COUNT:
		errors.append("Production reward count must be 10")
	for reward: RewardDefinition in rewards:
		if reward == null:
			errors.append("Production reward is null")
			continue
		if reward.reward_id == &"" or reward_ids.has(String(reward.reward_id)):
			errors.append("Production reward IDs must be non-empty and unique")
		reward_ids[String(reward.reward_id)] = true
		if reward.test_only_not_canon_locked:
			errors.append("Production reward cannot be TEST_ONLY: %s" % reward.reward_id)
		if reward.amount <= 0:
			errors.append("Production reward amount must be positive: %s" % reward.reward_id)
		if reward.repeat_policy != RewardDefinition.RepeatPolicy.REPEATABLE:
			errors.append("Production reward must be REPEATABLE: %s" % reward.reward_id)
		if not APPROVED_TYPES.has(reward.reward_type):
			errors.append("Production reward type is not approved")
		if reward.reward_type == RewardDefinition.Type.CONSUMABLE_ITEM:
			var expected_item_id := String(EXPECTED_CONSUMABLE_REWARDS.get(
				String(reward.reward_id), ""
			))
			if expected_item_id.is_empty() or String(reward.item_id) != expected_item_id:
				errors.append("Production consumable reward mapping is not canonical: %s" % reward.reward_id)
			if reward.amount != 1:
				errors.append("Production consumable reward amount must be 1: %s" % reward.reward_id)
			if not item_ids.has(String(reward.item_id)):
				errors.append("Production consumable reward item must resolve: %s" % reward.item_id)
		elif reward.item_id != &"":
			errors.append("Production direct-resource reward cannot reference an item: %s" % reward.reward_id)
	for reward_id: String in EXPECTED_CONSUMABLE_REWARDS:
		if not reward_ids.has(reward_id):
			errors.append("Missing production consumable reward: %s" % reward_id)
	var table_zones: Dictionary = {}
	if tables.size() != EXPECTED_TABLE_COUNT:
		errors.append("Production reward table count must be 3")
	for table: RewardZoneTableDefinition in tables:
		if table == null:
			errors.append("Production reward table is null")
			continue
		var zone_key := String(table.zone_id)
		if not EXPECTED_ZONES.has(table.zone_id) or table_zones.has(zone_key):
			errors.append("Production reward zones must be unique and canonical")
		table_zones[zone_key] = true
		if table.density_percent != EXPECTED_DENSITY_PERCENT:
			errors.append("Production reward density must be 75 percent: %s" % table.zone_id)
		if table.total_weight() != EXPECTED_WEIGHT_TOTAL:
			errors.append("Production reward weights must total 100: %s" % table.zone_id)
		var table_reward_ids: Dictionary = {}
		for entry: WeightedRewardEntry in table.entries:
			if entry == null or entry.weight <= 0:
				errors.append("Production reward weights must be positive: %s" % table.zone_id)
				continue
			var reward_key := String(entry.reward_id)
			if not reward_ids.has(reward_key) or table_reward_ids.has(reward_key):
				errors.append("Production table reward must exist exactly once: %s" % reward_key)
			table_reward_ids[reward_key] = true
		if table_reward_ids.size() != EXPECTED_REWARD_COUNT:
			errors.append("Every production table must contain all 10 rewards: %s" % table.zone_id)
	for expected_zone: StringName in EXPECTED_ZONES:
		if not table_zones.has(String(expected_zone)):
			errors.append("Missing production reward zone: %s" % expected_zone)
	if map_definition != null:
		var end_count := 0
		for node: LootNodeDefinition in map_definition.nodes:
			if node == null:
				continue
			if node.node_kind == &"END":
				end_count += 1
				if not node.tags.has(&"POST_MAUSOLEUM"):
					errors.append("Production END node must use POST_MAUSOLEUM")
			if (
				node.node_kind in [&"ORIGIN_SPAWN", &"CENTRAL_HUB", &"MAUSOLEUM_HUB"]
				and node.tags.has(&"POST_MAUSOLEUM")
			):
				errors.append("Production spawn/hub cannot use a reward zone")
		if end_count == 0:
			errors.append("Production map requires reward-eligible END nodes")
	return errors
