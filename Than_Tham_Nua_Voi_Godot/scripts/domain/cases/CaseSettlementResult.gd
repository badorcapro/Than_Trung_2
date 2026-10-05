class_name CaseSettlementResult
extends RefCounted

var success := false
var error_code: StringName
var error_message := ""
var case_outcome: CaseEnums.CaseOutcome
var player_resolutions: Array[PlayerCaseResolution] = []
var correct_solver_ids: Array[StringName] = []

static func failed(code: StringName, message: String) -> CaseSettlementResult:
	var result := CaseSettlementResult.new()
	result.error_code = code
	result.error_message = message
	return result
