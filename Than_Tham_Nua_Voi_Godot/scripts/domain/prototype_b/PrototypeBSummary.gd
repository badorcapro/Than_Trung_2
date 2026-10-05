class_name PrototypeBSummary
extends RefCounted

const PROTOTYPE_B_PLAYER_SUMMARY := preload(
	"res://scripts/domain/prototype_b/PrototypeBPlayerSummary.gd"
)
const SCHEMA_VERSION := 1
var session_id: StringName
var round_id: StringName
var completion_status: StringName = &"PROTOTYPE_B_SUMMARY"
var player_summaries: Array[PROTOTYPE_B_PLAYER_SUMMARY] = []
var aggregates: Dictionary = {}
var open_policy_ids: Dictionary = {}
var fixture_marker := "TEST_ONLY / PROTOTYPE / NOT_CANON_LOCKED"


func to_dict() -> Dictionary:
	var rows: Array[Dictionary] = []
	for summary: PROTOTYPE_B_PLAYER_SUMMARY in player_summaries:
		rows.append(summary.to_dict())
	return {
		"schema_version": SCHEMA_VERSION,
		"session_id": String(session_id),
		"round_id": String(round_id),
		"completion_status": String(completion_status),
		"player_summaries": rows,
		"aggregates": aggregates.duplicate(true),
		"open_policy_ids": open_policy_ids.duplicate(true),
		"fixture_marker": fixture_marker
	}
