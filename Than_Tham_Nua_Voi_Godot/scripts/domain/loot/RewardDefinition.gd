class_name RewardDefinition
extends Resource

enum Type {
	SILVER_COIN,
	ORB,
	GACHA_TICKET,
	EQUIPMENT_EXP_MATERIAL,
	EQUIPMENT_EXCHANGE_MATERIAL,
	CONSUMABLE_ITEM,
	RELIC_EXP_MATERIAL,
	STIGMATA_EXP_MATERIAL,
}
enum Tier { LOW = 0, MID = 1, HIGH = 2 }
enum RepeatPolicy { REPEATABLE, ONCE_PER_ROUND_GLOBAL }

@export var reward_id: StringName
@export var reward_type: Type = Type.SILVER_COIN
@export var tier: Tier = Tier.LOW
@export var amount := 1
@export var amount_max := 0
@export var item_id: StringName
@export var repeat_policy: RepeatPolicy = RepeatPolicy.REPEATABLE
@export var test_only_not_canon_locked := true
