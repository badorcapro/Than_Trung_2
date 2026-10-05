class_name CaseSubmissionResult
extends RefCounted

var success := false
var error_code: StringName
var error_message: String
var player_id: StringName
var main_answer_correct := false
var underling_classification_correct := false
var traitor_classification_correct := false
var submitted_on_turn := 0
var submission_status: CaseEnums.SubmissionStatus = CaseEnums.SubmissionStatus.NOT_SUBMITTED


static func failed(source_player_id: StringName, source_turn: int, code: StringName, message: String) -> CaseSubmissionResult:
	var result := CaseSubmissionResult.new()
	result.player_id = source_player_id
	result.submitted_on_turn = source_turn
	result.error_code = code
	result.error_message = message
	return result
