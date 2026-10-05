class_name FinalVerdictResult
extends RefCounted

var success := false
var error_code: StringName
var error_message := ""
var player_id: StringName
var all_required_locked := false
var evaluation_performed := false

static func failed(code: StringName, message: String) -> FinalVerdictResult:
	var result := FinalVerdictResult.new()
	result.error_code = code
	result.error_message = message
	return result
