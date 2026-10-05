class_name CaseTimedEventRuntimeState
extends RefCounted

var event_id: StringName = &""
var threshold_hour: int = 0
var source_suspect_id: int = 0
var fired: bool = false
var fired_at_hour: int = 0
var resolved_success: bool = false
var target_suspect_id: int = 0
var kill_attempted: bool = false
var kill_outcome: int = CaseKillResult.Outcome.FAILED


func mark_fired(current_hour: int, success: bool, target_id: int, attempted_kill: bool, outcome: int) -> bool:
	if fired:
		return false
	fired = true
	fired_at_hour = current_hour
	resolved_success = success
	target_suspect_id = target_id
	kill_attempted = attempted_kill
	kill_outcome = outcome
	return true
