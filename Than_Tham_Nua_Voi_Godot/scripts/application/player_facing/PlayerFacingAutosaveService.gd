class_name PlayerFacingAutosaveService
extends RefCounted

const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const MVP_MATCH_STATE := preload("res://scripts/domain/mvp/MvpMatchState.gd")
const MVP_MATCH_VALIDATOR := preload(
	"res://scripts/domain/mvp/MvpMatchStateValidator.gd"
)
const MVP_VALIDATION_REPORT := preload(
	"res://scripts/domain/mvp/MvpValidationReport.gd"
)
const MATCH_FINAL_STANDING := preload(
	"res://scripts/domain/mvp/MatchFinalStanding.gd"
)
const MVP_SERIALIZER := preload("res://scripts/application/mvp/MvpStateSerializer.gd")

const AUTOSAVE_PATH := "user://player_facing_autosave.json"

var autosave_path: String = AUTOSAVE_PATH
var _serializer: MVP_SERIALIZER = MVP_SERIALIZER.new()


func save_match(match_state: MVP_MATCH_STATE) -> Dictionary:
	var validation: Dictionary = _validate_supported_match(match_state)
	if not bool(validation.get("success", false)):
		return validation

	var temporary_path: String = autosave_path + ".tmp"
	var backup_path: String = autosave_path + ".bak"
	_remove_if_present(temporary_path)
	_remove_if_present(backup_path)

	var file: FileAccess = FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return _failure(&"AUTOSAVE_TEMP_OPEN_FAILED")
	file.store_string(_serializer.to_json(match_state, null))
	file.flush()
	var write_error: int = file.get_error()
	file.close()
	if write_error != OK:
		_remove_if_present(temporary_path)
		return _failure(&"AUTOSAVE_TEMP_WRITE_FAILED")

	var verified: Dictionary = _load_path(temporary_path)
	if not bool(verified.get("success", false)):
		_remove_if_present(temporary_path)
		return _failure(&"AUTOSAVE_TEMP_INVALID")

	var committed_absolute: String = ProjectSettings.globalize_path(autosave_path)
	var temporary_absolute: String = ProjectSettings.globalize_path(temporary_path)
	var backup_absolute: String = ProjectSettings.globalize_path(backup_path)
	var had_committed_save: bool = FileAccess.file_exists(autosave_path)
	if had_committed_save:
		var backup_error: int = DirAccess.rename_absolute(
			committed_absolute, backup_absolute
		)
		if backup_error != OK:
			_remove_if_present(temporary_path)
			return _failure(&"AUTOSAVE_BACKUP_FAILED")

	var commit_error: int = DirAccess.rename_absolute(
		temporary_absolute, committed_absolute
	)
	if commit_error != OK:
		if had_committed_save and FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(backup_absolute, committed_absolute)
		_remove_if_present(temporary_path)
		return _failure(&"AUTOSAVE_COMMIT_FAILED")

	_remove_if_present(backup_path)
	return {
		"success": true,
		"code": String(&"AUTOSAVE_COMMITTED"),
		"path": autosave_path,
	}


func load_match() -> Dictionary:
	return _load_path(autosave_path)


func has_valid_autosave() -> bool:
	return bool(load_match().get("success", false))


func _load_path(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _failure(&"AUTOSAVE_MISSING")
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _failure(&"AUTOSAVE_READ_FAILED")
	var json_text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(json_text)
	if not parsed is Dictionary:
		return _failure(&"AUTOSAVE_JSON_INVALID")
	var snapshot: Dictionary = parsed as Dictionary
	var round_value: Variant = snapshot.get("current_round_state", {})
	if not round_value is Dictionary or not (round_value as Dictionary).is_empty():
		return _failure(&"AUTOSAVE_ACTIVE_ROUND_UNSUPPORTED")
	var restored: Dictionary = _serializer.from_dict(snapshot)
	if not bool(restored.get("success", false)):
		return _failure(StringName(restored.get("code", "AUTOSAVE_INVALID")))
	var match_state: MVP_MATCH_STATE = restored.get("match_state") as MVP_MATCH_STATE
	var validation: Dictionary = _validate_supported_match(match_state)
	if not bool(validation.get("success", false)):
		return validation
	return {
		"success": true,
		"code": String(&"AUTOSAVE_READY"),
		"path": path,
		"match_state": match_state,
	}


func _validate_supported_match(match_state: MVP_MATCH_STATE) -> Dictionary:
	var report: MVP_VALIDATION_REPORT = MVP_MATCH_VALIDATOR.new().validate(match_state)
	if not report.passed():
		return _failure(&"AUTOSAVE_MATCH_INVALID")
	if not match_state.character_selection_complete or match_state.players.size() != 3:
		return _failure(&"AUTOSAVE_PLAYER_FACING_MATCH_INVALID")
	if (
		match_state.current_phase == MVP_ENUMS.Phase.ROUND_START
		and match_state.match_completion_state == &"NEXT_CASE_REQUIRED"
	):
		if (
			match_state.completed_round_count < 1
			or match_state.current_round_number != match_state.completed_round_count + 1
			or match_state.applied_commit_ids.is_empty()
			or not match_state.final_standings.is_empty()
		):
			return _failure(&"AUTOSAVE_NEXT_CASE_INVALID")
		return {"success": true, "code": String(&"NEXT_CASE_REQUIRED")}
	if (
		match_state.current_phase == MVP_ENUMS.Phase.MATCH_COMPLETE
		and match_state.match_completion_state == &"MATCH_COMPLETE"
		and match_state.completed_round_count >= 1
		and not match_state.applied_commit_ids.is_empty()
		and _final_standings_are_valid(match_state)
	):
		return {"success": true, "code": String(&"MATCH_COMPLETE")}
	return _failure(&"AUTOSAVE_PHASE_UNSUPPORTED")


func _final_standings_are_valid(match_state: MVP_MATCH_STATE) -> bool:
	if match_state.final_standings.size() != match_state.players.size():
		return false
	var seen_player_ids: Dictionary = {}
	for standing: MATCH_FINAL_STANDING in match_state.final_standings:
		if (
			standing == null
			or standing.player_id.is_empty()
			or seen_player_ids.has(standing.player_id)
			or match_state.find_player(standing.player_id) == null
			or standing.place <= 0
			or standing.court_rank_id.is_empty()
		):
			return false
		seen_player_ids[standing.player_id] = true
	return true


func _remove_if_present(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _failure(code: StringName) -> Dictionary:
	return {
		"success": false,
		"code": String(code),
		"path": autosave_path,
	}
