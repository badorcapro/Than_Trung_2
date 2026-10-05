class_name MvpMatchState
extends RefCounted

const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const PLAYER_MATCH_STATE := preload("res://scripts/domain/mvp/PlayerMatchState.gd")
const MVP_SEMANTIC_VALUE := preload("res://scripts/domain/mvp/MvpSemanticValue.gd")
const MATCH_RULES := preload("res://scripts/domain/mvp/MatchRules.gd")
const MATCH_FINAL_STANDING := preload("res://scripts/domain/mvp/MatchFinalStanding.gd")

var schema_version := 1
var match_id: StringName
var case_generation_seed: int = 0
var players: Array[PLAYER_MATCH_STATE] = []
var player_order: Array[StringName] = []
var character_selection_complete := false
var current_round_number := 0
var current_phase: int = MVP_ENUMS.Phase.MATCH_SETUP
var open_policy_config_ids: Dictionary = {}
var fixture_marker := "TEST_ONLY / PROTOTYPE / NOT_CANON_LOCKED"
var applied_commit_ids: Array[StringName] = []
var match_completion_state: StringName = &"IN_PROGRESS"
var used_case_candidate_signatures: Array[String] = []
var match_rules: MATCH_RULES = MATCH_RULES.classic()
var completed_round_count: int = 0
var final_standings: Array[MATCH_FINAL_STANDING] = []


func find_player(player_id: StringName) -> PLAYER_MATCH_STATE:
	for player: PLAYER_MATCH_STATE in players:
		if player.player_id == player_id:
			return player
	return null


func to_dict() -> Dictionary:
	var player_rows: Array[Dictionary] = []
	for player: PLAYER_MATCH_STATE in players:
		player_rows.append(player.to_dict())
	var order_rows: Array[String] = []
	for player_id: StringName in player_order:
		order_rows.append(String(player_id))
	var commit_rows: Array[String] = []
	for commit_id: StringName in applied_commit_ids:
		commit_rows.append(String(commit_id))
	var used_case_rows: Array[String] = []
	for signature: String in used_case_candidate_signatures:
		used_case_rows.append(signature)
	var standing_rows: Array[Dictionary] = []
	for standing: MATCH_FINAL_STANDING in final_standings:
		standing_rows.append(standing.to_dict())
	return {
		"schema_version": schema_version,
		"match_id": String(match_id),
		"case_generation_seed": case_generation_seed,
		"players": player_rows,
		"player_order": order_rows,
		"character_selection_complete": character_selection_complete,
		"current_round_number": current_round_number,
		"current_phase": current_phase,
		"open_policy_config_ids": _normalize_string_dictionary(open_policy_config_ids),
		"fixture_marker": fixture_marker,
		"applied_commit_ids": commit_rows,
		"match_completion_state": String(match_completion_state),
		"used_case_candidate_signatures": used_case_rows,
		"match_rules": match_rules.to_dict() if match_rules != null else {},
		"completed_round_count": completed_round_count,
		"final_standings": standing_rows,
	}


static func from_dict(data: Dictionary) -> MvpMatchState:
	var result := MvpMatchState.new()
	result.schema_version = int(data.get("schema_version", 1))
	result.match_id = StringName(data.get("match_id", ""))
	result.case_generation_seed = int(data.get("case_generation_seed", 0))
	result.character_selection_complete = bool(data.get("character_selection_complete", false))
	result.current_round_number = int(data.get("current_round_number", 0))
	result.current_phase = int(data.get("current_phase", MVP_ENUMS.Phase.MATCH_SETUP))
	result.fixture_marker = String(data.get("fixture_marker", ""))
	result.match_completion_state = StringName(data.get("match_completion_state", "IN_PROGRESS"))
	result.completed_round_count = int(data.get("completed_round_count", 0))
	var rules_value: Variant = data.get("match_rules", {})
	if rules_value is Dictionary:
		var rules_data: Dictionary = rules_value
		result.match_rules = (
			MATCH_RULES.from_dict(rules_data)
			if not rules_data.is_empty()
			else MATCH_RULES.classic()
		)
	else:
		result.match_rules = MATCH_RULES.classic()
	var players_value: Variant = data.get("players", [])
	if players_value is Array:
		for row: Variant in players_value:
			if row is Dictionary:
				result.players.append(PLAYER_MATCH_STATE.from_dict(row))
	var order_value: Variant = data.get("player_order", [])
	if order_value is Array:
		for value: Variant in order_value:
			result.player_order.append(StringName(value))
	var policies_value: Variant = data.get("open_policy_config_ids", {})
	if policies_value is Dictionary:
		result.open_policy_config_ids = _normalize_string_dictionary(policies_value)
	var commits_value: Variant = data.get("applied_commit_ids", [])
	if commits_value is Array:
		for value: Variant in commits_value:
			result.applied_commit_ids.append(StringName(value))
	var used_cases_value: Variant = data.get("used_case_candidate_signatures", [])
	if used_cases_value is Array:
		for value: Variant in used_cases_value:
			result.used_case_candidate_signatures.append(String(value))
	var standings_value: Variant = data.get("final_standings", [])
	if standings_value is Array:
		for row: Variant in standings_value:
			if row is Dictionary:
				result.final_standings.append(MATCH_FINAL_STANDING.from_dict(row))
	return result


func semantically_equals(other: MvpMatchState) -> bool:
	return semantic_mismatches(other).is_empty()


func semantic_mismatches(other: MvpMatchState) -> Array[String]:
	var mismatches: Array[String] = []
	if other == null:
		mismatches.append("match_state missing")
		return mismatches
	MVP_SEMANTIC_VALUE.collect_mismatches("", to_dict(), other.to_dict(), mismatches)
	var result: Array[String] = []
	for path: String in mismatches:
		result.append(path.trim_prefix("."))
	return result


static func _normalize_string_dictionary(source: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key: Variant in source.keys():
		result[String(key)] = String(source.get(key, ""))
	return result
