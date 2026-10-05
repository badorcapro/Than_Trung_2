class_name MvpRoundState
extends RefCounted

const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const MVP_SEMANTIC_VALUE := preload("res://scripts/domain/mvp/MvpSemanticValue.gd")

var schema_version := 1
var round_id: StringName
var round_number := 1
var case_id: StringName
var phase: int = MVP_ENUMS.Phase.ROUND_START
var case_runtime_snapshot: Dictionary = {}
var case_completion_reason: StringName
var case_settlement_snapshot: Dictionary = {}
var settlement_commit_id: StringName
var settlement_applied := false
var loot_map_id: StringName
var loot_movement_snapshot: Dictionary = {}
var loot_reward_snapshot: Dictionary = {}
var equipment_management_snapshot: Dictionary = {}
var round_completion_flags: Dictionary = {}
var round_end_commit_id: StringName


func to_dict() -> Dictionary:
	return {
		"schema_version": schema_version,
		"round_id": String(round_id),
		"round_number": round_number,
		"case_id": String(case_id),
		"phase": phase,
		"case_runtime_snapshot": MVP_SEMANTIC_VALUE.normalize_dictionary(case_runtime_snapshot),
		"case_completion_reason": String(case_completion_reason),
		"case_settlement_snapshot": MVP_SEMANTIC_VALUE.normalize_dictionary(case_settlement_snapshot),
		"settlement_commit_id": String(settlement_commit_id),
		"settlement_applied": settlement_applied,
		"loot_map_id": String(loot_map_id),
		"loot_movement_snapshot": MVP_SEMANTIC_VALUE.normalize_dictionary(loot_movement_snapshot),
		"loot_reward_snapshot": MVP_SEMANTIC_VALUE.normalize_dictionary(loot_reward_snapshot),
		"equipment_management_snapshot": MVP_SEMANTIC_VALUE.normalize_dictionary(
			equipment_management_snapshot
		),
		"round_completion_flags": MVP_SEMANTIC_VALUE.normalize_dictionary(round_completion_flags),
		"round_end_commit_id": String(round_end_commit_id),
	}


static func from_dict(data: Dictionary) -> MvpRoundState:
	var result := MvpRoundState.new()
	result.schema_version = int(data.get("schema_version", 1))
	result.round_id = StringName(data.get("round_id", ""))
	result.round_number = int(data.get("round_number", 1))
	result.case_id = StringName(data.get("case_id", ""))
	result.phase = int(data.get("phase", MVP_ENUMS.Phase.ROUND_START))
	result.case_completion_reason = StringName(data.get("case_completion_reason", ""))
	result.settlement_commit_id = StringName(data.get("settlement_commit_id", ""))
	result.settlement_applied = bool(data.get("settlement_applied", false))
	result.loot_map_id = StringName(data.get("loot_map_id", ""))
	result.round_end_commit_id = StringName(data.get("round_end_commit_id", ""))
	result.case_runtime_snapshot = _snapshot_dictionary(data.get("case_runtime_snapshot", {}))
	result.case_settlement_snapshot = _snapshot_dictionary(
		data.get("case_settlement_snapshot", {})
	)
	result.loot_movement_snapshot = _snapshot_dictionary(data.get("loot_movement_snapshot", {}))
	result.loot_reward_snapshot = _snapshot_dictionary(data.get("loot_reward_snapshot", {}))
	result.equipment_management_snapshot = _snapshot_dictionary(
		data.get("equipment_management_snapshot", {})
	)
	result.round_completion_flags = _snapshot_dictionary(data.get("round_completion_flags", {}))
	return result


func semantically_equals(other: MvpRoundState) -> bool:
	return semantic_mismatches(other).is_empty()


func semantic_mismatches(other: MvpRoundState) -> Array[String]:
	var mismatches: Array[String] = []
	if other == null:
		mismatches.append("round_state missing")
		return mismatches
	var expected: Dictionary = to_dict()
	var actual: Dictionary = other.to_dict()
	for field: String in expected.keys():
		if expected.get(field) != actual.get(field):
			MVP_SEMANTIC_VALUE.collect_mismatches(
				field, expected.get(field), actual.get(field), mismatches
			)
	return mismatches


static func _snapshot_dictionary(value: Variant) -> Dictionary:
	if not value is Dictionary:
		return {}
	return MVP_SEMANTIC_VALUE.normalize_dictionary(value)
