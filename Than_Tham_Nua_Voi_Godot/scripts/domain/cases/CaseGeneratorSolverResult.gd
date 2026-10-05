class_name CaseGeneratorSolverResult
extends RefCounted

const STATUS_NO_SOLUTION: StringName = &"no_solution"
const STATUS_CONTRADICTION: StringName = &"no_solution"
const STATUS_MULTIPLE_SOLUTIONS: StringName = &"multiple_solutions"
const STATUS_UNIQUE_SOLUTION: StringName = &"unique_solution"
const STATUS_UNSUPPORTED: StringName = &"unsupported"

var status: StringName = STATUS_NO_SOLUTION
var candidate_evil_sets: Array = []
var candidate_count: int = 0
var solution_count: int = 0
var unique_evil_suspect_ids: PackedInt32Array = PackedInt32Array()
var unsupported: bool = false
var error_message: String = ""
var ground_truth_checked: bool = false
var unique_solution_matches_ground_truth: bool = false
var initial_candidate_count: int = 0
var remaining_candidate_counts: PackedInt32Array = PackedInt32Array()
var raw_evil_set_count: int = 0
var pre_replay_evil_sets: Array = []
var replay_evil_sets_after_clues: Array = []
# Observability only; excluded from solver status, fingerprints, and acceptance.
var performance_diagnostics: Dictionary = {}


func set_candidates(candidates: Array) -> void:
	candidate_evil_sets = []
	var seen: Dictionary = {}
	for candidate in candidates:
		if candidate != null:
			var ids: PackedInt32Array = candidate.duplicate()
			ids.sort()
			var signature: String = _join_ints(ids)
			if not seen.has(signature):
				seen[signature] = true
				candidate_evil_sets.append(ids)
	candidate_count = candidate_evil_sets.size()
	solution_count = candidate_count
	if candidate_count == 0:
		status = STATUS_NO_SOLUTION
		unique_evil_suspect_ids = PackedInt32Array()
	elif candidate_count == 1:
		status = STATUS_UNIQUE_SOLUTION
		unique_evil_suspect_ids = candidate_evil_sets[0].duplicate()
	else:
		status = STATUS_MULTIPLE_SOLUTIONS
		unique_evil_suspect_ids = PackedInt32Array()


func mark_unsupported(message: String) -> void:
	unsupported = true
	error_message = message
	status = STATUS_UNSUPPORTED
	candidate_evil_sets.clear()
	candidate_count = 0
	solution_count = 0
	unique_evil_suspect_ids = PackedInt32Array()


func compare_unique_solution_to_ground_truth(ground_truth_evil_ids: PackedInt32Array) -> bool:
	ground_truth_checked = true
	var expected: PackedInt32Array = ground_truth_evil_ids.duplicate()
	expected.sort()
	unique_solution_matches_ground_truth = (
		status == STATUS_UNIQUE_SOLUTION
		and unique_evil_suspect_ids == expected
	)
	return unique_solution_matches_ground_truth


func fingerprint_text() -> String:
	var parts: Array[String] = []
	for candidate in candidate_evil_sets:
		if candidate != null:
			parts.append(_join_ints(candidate))
	return "solver|status:%s|count:%d|candidates:%s|unsupported:%s|truth_checked:%s|truth_match:%s" % [
		String(status),
		candidate_count,
		";".join(parts),
		str(unsupported),
		str(ground_truth_checked),
		str(unique_solution_matches_ground_truth),
	]


func _join_ints(values: PackedInt32Array) -> String:
	var parts: Array[String] = []
	for value: int in values:
		parts.append(str(value))
	return ",".join(parts)
