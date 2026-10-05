class_name CaseKillResult
extends RefCounted

enum Outcome {
	FAILED,
	KILLED,
	ALREADY_DEAD,
}

var success := false
var state_changed := false
var outcome: Outcome = Outcome.FAILED
var suspect_id := 0
var source: StringName = &""
var error_code: StringName = &""
var error_message := ""


static func killed(target_suspect_id: int, kill_source: StringName) -> CaseKillResult:
	var result: CaseKillResult = CaseKillResult.new()
	result.success = true
	result.state_changed = true
	result.outcome = Outcome.KILLED
	result.suspect_id = target_suspect_id
	result.source = kill_source
	return result


static func already_dead(target_suspect_id: int, kill_source: StringName) -> CaseKillResult:
	var result: CaseKillResult = CaseKillResult.new()
	result.success = true
	result.state_changed = false
	result.outcome = Outcome.ALREADY_DEAD
	result.suspect_id = target_suspect_id
	result.source = kill_source
	return result


static func failed(target_suspect_id: int, kill_source: StringName, code: StringName, message: String) -> CaseKillResult:
	var result: CaseKillResult = CaseKillResult.new()
	result.suspect_id = target_suspect_id
	result.source = kill_source
	result.error_code = code
	result.error_message = message
	return result
