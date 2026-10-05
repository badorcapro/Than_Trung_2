class_name MvpTransitionResult
extends RefCounted

var success := false
var code: StringName
var message := ""
var source_phase := -1
var target_phase := -1


static func create(
	passed: bool, result_code: StringName, result_message: String, source: int, target: int
) -> MvpTransitionResult:
	var result := MvpTransitionResult.new()
	result.success = passed
	result.code = result_code
	result.message = result_message
	result.source_phase = source
	result.target_phase = target
	return result


func to_dict() -> Dictionary:
	return {
		"success": success,
		"code": String(code),
		"message": message,
		"source_phase": source_phase,
		"target_phase": target_phase,
	}
