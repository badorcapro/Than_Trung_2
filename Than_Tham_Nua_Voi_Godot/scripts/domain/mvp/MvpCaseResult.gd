class_name MvpCaseResult
extends RefCounted

const MVP_CASE_PLAYER_RESULT := preload("res://scripts/domain/mvp/MvpCasePlayerResult.gd")

var case_id: StringName
var round_id: StringName
var completion_reason: StringName
var settlement_commit_id: StringName
var case_outcome := -1
var player_results: Array[MVP_CASE_PLAYER_RESULT] = []


func to_dict() -> Dictionary:
	var rows: Array[Dictionary] = []
	for result: MVP_CASE_PLAYER_RESULT in player_results:
		rows.append(result.to_dict())
	return {
		"case_id": String(case_id),
		"round_id": String(round_id),
		"completion_reason": String(completion_reason),
		"settlement_commit_id": String(settlement_commit_id),
		"case_outcome": case_outcome,
		"player_results": rows,
	}


static func from_dict(data: Dictionary) -> MvpCaseResult:
	var result := MvpCaseResult.new()
	result.case_id = StringName(data.get("case_id", ""))
	result.round_id = StringName(data.get("round_id", ""))
	result.completion_reason = StringName(data.get("completion_reason", ""))
	result.settlement_commit_id = StringName(data.get("settlement_commit_id", ""))
	result.case_outcome = int(data.get("case_outcome", -1))
	var rows_value: Variant = data.get("player_results", [])
	if rows_value is Array:
		for row: Variant in rows_value:
			if row is Dictionary:
				result.player_results.append(MVP_CASE_PLAYER_RESULT.from_dict(row))
	return result
