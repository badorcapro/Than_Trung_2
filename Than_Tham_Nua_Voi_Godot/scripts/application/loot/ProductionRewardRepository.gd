class_name ProductionRewardRepository
extends RefCounted

const REWARD_PATHS: Array[String] = [
	"res://content/rewards/production/prod_silver_small.tres",
	"res://content/rewards/production/prod_equipment_exp_small.tres",
	"res://content/rewards/production/prod_orb_1.tres",
	"res://content/rewards/production/prod_silver_large.tres",
	"res://content/rewards/production/prod_equipment_exp_large.tres",
	"res://content/rewards/production/prod_exchange_material_1.tres",
	"res://content/rewards/production/prod_gacha_ticket_1.tres",
	"res://content/rewards/production/prod_consumable_hanh_lo_phu.tres",
	"res://content/rewards/production/prod_consumable_lenh_bai_thong_hanh.tres",
	"res://content/rewards/production/prod_consumable_ngu_ma_lenh.tres",
]
const TABLE_PATHS: Array[String] = [
	"res://content/rewards/production/house_reward_table_v1.tres",
	"res://content/rewards/production/middle_reward_table_v1.tres",
	"res://content/rewards/production/post_mausoleum_reward_table_v1.tres",
]


static func load_rewards() -> Array[RewardDefinition]:
	var result: Array[RewardDefinition] = []
	for path: String in REWARD_PATHS:
		var reward: RewardDefinition = load(path) as RewardDefinition
		if reward != null:
			result.append(reward)
	return result


static func load_tables() -> Array[RewardZoneTableDefinition]:
	var result: Array[RewardZoneTableDefinition] = []
	for path: String in TABLE_PATHS:
		var table: RewardZoneTableDefinition = load(path) as RewardZoneTableDefinition
		if table != null:
			result.append(table)
	return result


static func find_reward(
	rewards: Array[RewardDefinition], reward_id: StringName
) -> RewardDefinition:
	for reward: RewardDefinition in rewards:
		if reward != null and reward.reward_id == reward_id:
			return reward
	return null


static func find_table(
	tables: Array[RewardZoneTableDefinition], zone_id: StringName
) -> RewardZoneTableDefinition:
	for table: RewardZoneTableDefinition in tables:
		if table != null and table.zone_id == zone_id:
			return table
	return null
