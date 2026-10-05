class_name RewardResolutionResult
extends RefCounted

enum Status { GRANTED, PENDING_OVERFLOW, SKIPPED }

var player_id: StringName
var node_id: StringName
var reward_type := RewardDefinition.Type.SILVER_COIN
var reward_amount := 0
var reward_id: StringName
var item_id: StringName
var status := Status.GRANTED
var overflow_required := false
var consumed_special := false
var resource_delta: Dictionary = {}


func to_dict() -> Dictionary:
	return {"player_id":String(player_id), "node_id":String(node_id), "reward_type":reward_type, "reward_amount":reward_amount, "reward_id":String(reward_id), "item_id":String(item_id), "status":status, "overflow_required":overflow_required, "consumed_special":consumed_special, "resource_delta":resource_delta.duplicate(true)}


static func from_dict(data: Dictionary) -> RewardResolutionResult:
	var result := RewardResolutionResult.new()
	result.player_id = StringName(data.get("player_id", "")); result.node_id = StringName(data.get("node_id", "")); result.reward_type = int(data.get("reward_type", 0)); result.reward_amount = int(data.get("reward_amount", 0)); result.reward_id = StringName(data.get("reward_id", "")); result.item_id = StringName(data.get("item_id", "")); result.status = int(data.get("status", 0)); result.overflow_required = bool(data.get("overflow_required", false)); result.consumed_special = bool(data.get("consumed_special", false))
	var delta_value: Variant = data.get("resource_delta", {})
	if delta_value is Dictionary: result.resource_delta = delta_value.duplicate(true)
	return result
