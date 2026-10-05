class_name InteractiveFunctionResult
extends RefCounted

enum PublicResultType {
	NONE,
	SAME_ALIGNMENT,
	DIFFERENT_ALIGNMENT,
	VIGILANTE_KILL_ATTEMPTED,
	VIGILANTE_MISSED,
}

var success := false
var error_code: StringName
var error_message: String
var owner_suspect_id := 0
var function_type: CaseEnums.FunctionType = CaseEnums.FunctionType.NONE
var target_ids := PackedInt32Array()
var public_result_type: PublicResultType = PublicResultType.NONE
var public_result_text: String
var vigilante_kill_attempted := false
var vigilante_target_killed := false
var kill_outcome: int = CaseKillResult.Outcome.FAILED


static func failed(owner_id: int, source_function_type: CaseEnums.FunctionType, targets: PackedInt32Array, code: StringName, message: String) -> InteractiveFunctionResult:
	var result: InteractiveFunctionResult = InteractiveFunctionResult.new()
	result.owner_suspect_id = owner_id
	result.function_type = source_function_type
	result.target_ids = targets.duplicate()
	result.error_code = code
	result.error_message = message
	return result


static func succeeded(owner_id: int, source_function_type: CaseEnums.FunctionType, targets: PackedInt32Array, result_type: PublicResultType, result_text: String) -> InteractiveFunctionResult:
	var result: InteractiveFunctionResult = InteractiveFunctionResult.new()
	result.success = true
	result.owner_suspect_id = owner_id
	result.function_type = source_function_type
	result.target_ids = targets.duplicate()
	result.public_result_type = result_type
	result.public_result_text = result_text
	return result
