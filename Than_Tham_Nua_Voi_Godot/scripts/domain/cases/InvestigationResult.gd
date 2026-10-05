class_name InvestigationResult
extends RefCounted

var success := false
var suspect_id := 0
var player_id: StringName
var public_role_id: StringName
var error_code: StringName
var message: String


static func succeeded(source_suspect_id: int, source_player_id: StringName, revealed_role_id: StringName) -> InvestigationResult:
	var result := InvestigationResult.new()
	result.success = true
	result.suspect_id = source_suspect_id
	result.player_id = source_player_id
	result.public_role_id = revealed_role_id
	return result


static func failed(source_suspect_id: int, source_player_id: StringName, code: StringName, failure_message: String) -> InvestigationResult:
	var result := InvestigationResult.new()
	result.suspect_id = source_suspect_id
	result.player_id = source_player_id
	result.error_code = code
	result.message = failure_message
	return result
