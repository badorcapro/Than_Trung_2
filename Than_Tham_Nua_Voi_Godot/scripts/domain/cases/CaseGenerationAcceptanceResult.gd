class_name CaseGenerationAcceptanceResult
extends RefCounted

const FAILURE_NONE: StringName = &""
const FAILURE_REQUEST_NULL: StringName = &"request_null"
const FAILURE_MAX_ATTEMPTS_INVALID: StringName = &"max_attempts_invalid"
const FAILURE_EXHAUSTED: StringName = &"max_attempts_exhausted"

var success: bool = false
var accepted_candidate = null
var root_seed: int = 0
var accepted_derived_seed: int = -1
var accepted_attempt_index: int = -1
var attempts_performed: int = 0
var accepted_solver_result = null
var accepted_public_view = null
var rejected_status_counts: Dictionary = {}
var rejected_attempts: Array[Dictionary] = []
var failure_reason: StringName = FAILURE_NONE


func record_rejection(
	attempt_index: int,
	attempt_seed: int,
	reason: StringName,
	solver_status: StringName = &"",
	candidate_fingerprint: String = ""
) -> void:
	attempts_performed = maxi(attempts_performed, attempt_index + 1)
	var current_count: int = int(rejected_status_counts.get(reason, 0))
	rejected_status_counts[reason] = current_count + 1
	rejected_attempts.append({
		"attempt_index": attempt_index,
		"attempt_seed": attempt_seed,
		"reason": reason,
		"solver_status": solver_status,
		"candidate_fingerprint": candidate_fingerprint,
	})


func mark_success(
	candidate,
	solver_result,
	attempt_index: int,
	attempt_seed: int,
	public_view = null
) -> void:
	success = true
	accepted_candidate = candidate
	accepted_solver_result = solver_result
	accepted_public_view = public_view
	accepted_attempt_index = attempt_index
	accepted_derived_seed = attempt_seed
	attempts_performed = attempt_index + 1
	failure_reason = FAILURE_NONE


func mark_failure(reason: StringName, performed: int) -> void:
	success = false
	failure_reason = reason
	attempts_performed = performed


func fingerprint_text() -> String:
	var reject_parts: Array[String] = []
	for reason: Variant in rejected_status_counts.keys():
		reject_parts.append("%s:%d" % [String(reason), int(rejected_status_counts.get(reason, 0))])
	reject_parts.sort()
	var solver_fingerprint := ""
	if accepted_solver_result is Object and (accepted_solver_result as Object).has_method("fingerprint_text"):
		solver_fingerprint = String((accepted_solver_result as Object).call("fingerprint_text"))
	var candidate_fingerprint := ""
	if accepted_candidate != null:
		if accepted_candidate is Dictionary:
			candidate_fingerprint = String(accepted_candidate.get("fingerprint", ""))
		elif accepted_candidate is Object:
			candidate_fingerprint = String((accepted_candidate as Object).get("fingerprint"))
	return "accept|success:%s|root:%d|attempt:%d|seed:%d|performed:%d|rejects:%s|candidate:%s|solver:%s|failure:%s" % [
		str(success),
		root_seed,
		accepted_attempt_index,
		accepted_derived_seed,
		attempts_performed,
		";".join(reject_parts),
		candidate_fingerprint,
		solver_fingerprint,
		String(failure_reason),
	]
