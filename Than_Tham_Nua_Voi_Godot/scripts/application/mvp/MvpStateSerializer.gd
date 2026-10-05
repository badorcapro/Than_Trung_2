class_name MvpStateSerializer
extends RefCounted

const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const MVP_MATCH_STATE := preload("res://scripts/domain/mvp/MvpMatchState.gd")
const MVP_ROUND_STATE := preload("res://scripts/domain/mvp/MvpRoundState.gd")

const SCHEMA_VERSION := 1


func build_snapshot(
	match_state: MVP_MATCH_STATE, round_state: MVP_ROUND_STATE = null
) -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"project_version": AppVersion.GAME_VERSION,
		"build_label": AppVersion.BUILD_LABEL,
		"fixture_marker": match_state.fixture_marker,
		"match_state": match_state.to_dict(),
		"current_round_state": round_state.to_dict() if round_state != null else {},
		"current_phase": match_state.current_phase,
		"open_policy_config_ids": match_state.to_dict().get("open_policy_config_ids", {}),
		"applied_commit_ids": match_state.to_dict().get("applied_commit_ids", []),
	}


func to_json(match_state: MVP_MATCH_STATE, round_state: MVP_ROUND_STATE = null) -> String:
	return JSON.stringify(build_snapshot(match_state, round_state), "  ", true)


func from_json(json_text: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(json_text)
	if not parsed is Dictionary:
		return {"success": false, "code": "SNAPSHOT_JSON_INVALID"}
	return from_dict(parsed)


func from_dict(data: Dictionary) -> Dictionary:
	if int(data.get("schema_version", 0)) != SCHEMA_VERSION:
		return {"success": false, "code": "SNAPSHOT_SCHEMA_UNSUPPORTED"}
	var match_value: Variant = data.get("match_state", {})
	if not match_value is Dictionary:
		return {"success": false, "code": "MATCH_STATE_MISSING"}
	var match_state: MVP_MATCH_STATE = MVP_MATCH_STATE.from_dict(match_value)
	var phase := int(data.get("current_phase", MVP_ENUMS.Phase.MATCH_SETUP))
	if phase != match_state.current_phase:
		return {"success": false, "code": "SNAPSHOT_PHASE_MISMATCH"}
	var round_state: MVP_ROUND_STATE
	var round_value: Variant = data.get("current_round_state", {})
	if round_value is Dictionary and not round_value.is_empty():
		round_state = MVP_ROUND_STATE.from_dict(round_value)
	return {
		"success": true,
		"code": "OK",
		"match_state": match_state,
		"round_state": round_state,
	}


func round_trip_diagnostic(
	match_state: MVP_MATCH_STATE, round_state: MVP_ROUND_STATE = null
) -> Dictionary:
	var restored: Dictionary = from_json(to_json(match_state, round_state))
	if not bool(restored.get("success", false)):
		return {"matches": false, "code": restored.get("code", "UNKNOWN")}
	var restored_match: MVP_MATCH_STATE = restored.get("match_state") as MVP_MATCH_STATE
	var restored_round: MVP_ROUND_STATE = restored.get("round_state") as MVP_ROUND_STATE
	var match_mismatches: Array[String] = match_state.semantic_mismatches(restored_match)
	var match_equal := match_mismatches.is_empty()
	var round_mismatches: Array[String] = []
	if round_state == null and restored_round != null:
		round_mismatches.append("current_round_state unexpected")
	elif round_state != null:
		round_mismatches = round_state.semantic_mismatches(restored_round)
	var round_equal := (
		(round_state == null and restored_round == null)
		or (round_state != null and round_mismatches.is_empty())
	)
	var mismatch_paths: Array[String] = []
	for path: String in match_mismatches:
		mismatch_paths.append("match_state.%s" % path)
	for path: String in round_mismatches:
		mismatch_paths.append("current_round_state.%s" % path)
	return {
		"matches": match_equal and round_equal,
		"code": "OK" if match_equal and round_equal else "SEMANTIC_MISMATCH",
		"match_equal": match_equal,
		"round_equal": round_equal,
		"mismatch_paths": mismatch_paths,
	}
