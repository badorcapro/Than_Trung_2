class_name RewardNodeSnapshot
extends RefCounted

var node_id: StringName
var reward_definition_id: StringName
var remaining_hits := -1
var policy_id: StringName
var round_id: StringName

func to_dict() -> Dictionary:
	return {"node_id":String(node_id), "reward_definition_id":String(reward_definition_id), "remaining_hits":remaining_hits, "policy_id":String(policy_id), "round_id":String(round_id)}

static func from_dict(data: Dictionary) -> RewardNodeSnapshot:
	var result := RewardNodeSnapshot.new()
	result.node_id = StringName(data.get("node_id", "")); result.reward_definition_id = StringName(data.get("reward_definition_id", "")); result.remaining_hits = int(data.get("remaining_hits", -1)); result.policy_id = StringName(data.get("policy_id", "")); result.round_id = StringName(data.get("round_id", ""))
	return result
