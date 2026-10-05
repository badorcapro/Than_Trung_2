class_name SingleSuspectAccusationResult
extends RefCounted

var success := false
var error_code: StringName
var error_message := ""
var player_id: StringName
var suspect_id := 0
var correct := false
var blocked_by_immunity := false
var private_true_role_id: StringName
var player_inactivated := false
var completed_evil_set := false
var submitted_ids := PackedInt32Array()
var submission_phase: CaseEnums.SubmissionPhase = CaseEnums.SubmissionPhase.EARLY


static func failed(source_player_id: StringName, source_suspect_id: int, code: StringName, message: String) -> SingleSuspectAccusationResult:
	var result := SingleSuspectAccusationResult.new()
	result.player_id = source_player_id
	result.suspect_id = source_suspect_id
	result.error_code = code
	result.error_message = message
	return result


static func immunity_blocked(
	source_player_id: StringName,
	source_suspect_id: int,
	phase: CaseEnums.SubmissionPhase
) -> SingleSuspectAccusationResult:
	var result := SingleSuspectAccusationResult.new()
	result.success = true
	result.player_id = source_player_id
	result.suspect_id = source_suspect_id
	result.submission_phase = phase
	result.blocked_by_immunity = true
	result.error_code = &"SCOUNDREL_IMMUNE"
	result.error_message = "Kẻ Bất Lương vẫn đang được miễn nhiễm."
	return result
