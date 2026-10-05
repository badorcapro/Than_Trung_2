class_name CaseGenerationAcceptanceService
extends RefCounted

const ACCEPTANCE_RESULT := preload("res://scripts/domain/cases/CaseGenerationAcceptanceResult.gd")
const CASE_GENERATION_REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")
const CASE_GENERATION_RESULT := preload("res://scripts/domain/cases/CaseGenerationResult.gd")
const CASE_GENERATOR := preload("res://scripts/domain/cases/CaseGenerator.gd")
const GENERATED_PUBLIC_CASE_VIEW := preload("res://scripts/domain/cases/GeneratedPublicCaseView.gd")
const CASE_GENERATOR_PUBLIC_SOLVER := preload("res://scripts/domain/cases/CaseGeneratorPublicSolver.gd")
const CASE_GENERATOR_SOLVER_RESULT := preload("res://scripts/domain/cases/CaseGeneratorSolverResult.gd")

const DEFAULT_MAX_ATTEMPTS := 24
const SEED_MODULUS := 2147483647

const REJECTION_GENERATION_FAILURE: StringName = &"generation_failure"
const REJECTION_UNSUPPORTED: StringName = &"unsupported"
const REJECTION_NO_SOLUTION: StringName = &"no_solution"
const REJECTION_MULTIPLE_SOLUTIONS: StringName = &"multiple_solutions"
const REJECTION_UNIQUE_GROUND_TRUTH_MISMATCH: StringName = &"unique_ground_truth_mismatch"
const REJECTION_SOLVER_FAILURE: StringName = &"solver_failure"


func accept_unique_candidate(
	request: CaseGenerationRequest,
	role_definitions: Array[RoleDefinition] = [],
	max_attempts: int = DEFAULT_MAX_ATTEMPTS,
	attempt_evaluator: Callable = Callable()
) -> CaseGenerationAcceptanceResult:
	var result: CaseGenerationAcceptanceResult = ACCEPTANCE_RESULT.new()
	if request == null:
		result.mark_failure(ACCEPTANCE_RESULT.FAILURE_REQUEST_NULL, 0)
		return result
	result.root_seed = request.seed
	if max_attempts <= 0:
		result.mark_failure(ACCEPTANCE_RESULT.FAILURE_MAX_ATTEMPTS_INVALID, 0)
		return result

	for attempt_index: int in range(max_attempts):
		var attempt_seed: int = derived_seed_for_attempt(request, attempt_index)
		var attempt_request: CaseGenerationRequest = _request_for_attempt_seed(request, attempt_seed)
		var attempt_data: Dictionary = _attempt_data(attempt_request, role_definitions, attempt_index, attempt_evaluator)
		var candidate: Variant = attempt_data.get("candidate", null)
		var solver_result: Variant = attempt_data.get("solver_result", null)
		var candidate_fingerprint: String = String(attempt_data.get("candidate_fingerprint", ""))
		if candidate == null or _candidate_is_failed_generation(candidate):
			result.record_rejection(attempt_index, attempt_seed, REJECTION_GENERATION_FAILURE, &"", candidate_fingerprint)
			continue
		if solver_result == null:
			result.record_rejection(attempt_index, attempt_seed, REJECTION_SOLVER_FAILURE, &"", candidate_fingerprint)
			continue
		if not (solver_result is Object):
			result.record_rejection(attempt_index, attempt_seed, REJECTION_SOLVER_FAILURE, &"", candidate_fingerprint)
			continue
		var solver_object: Object = solver_result as Object
		var solver_status: StringName = solver_object.get("status")
		if solver_status == CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION:
			var truth_ids: PackedInt32Array = _ground_truth_evil_ids(attempt_data, candidate)
			if bool(solver_object.call("compare_unique_solution_to_ground_truth", truth_ids)):
				result.mark_success(candidate, solver_result, attempt_index, attempt_seed, attempt_data.get("public_view", null))
				return result
			result.record_rejection(attempt_index, attempt_seed, REJECTION_UNIQUE_GROUND_TRUTH_MISMATCH, solver_status, candidate_fingerprint)
		else:
			result.record_rejection(attempt_index, attempt_seed, _rejection_reason_for_solver_status(solver_status), solver_status, candidate_fingerprint)

	result.mark_failure(ACCEPTANCE_RESULT.FAILURE_EXHAUSTED, max_attempts)
	return result


static func derived_seed_for_attempt(request: CaseGenerationRequest, attempt_index: int) -> int:
	if request == null:
		return 0
	if attempt_index <= 0:
		return _positive_seed(request.seed)
	var profile_component: int = 17
	if request.generation_profile_id == CASE_GENERATION_REQUEST.PROFILE_TUTORIAL_EASY:
		profile_component = 19
	elif request.generation_profile_id == CASE_GENERATION_REQUEST.PROFILE_NORMAL_FULL:
		profile_component = 31
	var raw_seed: int = (
		request.seed
		+ attempt_index * 1000003
		+ request.generator_version * 9176
		+ request.board_columns * 101
		+ request.board_rows * 211
		+ request.required_suspect_count * 307
		+ request.required_location_ids.size() * 401
		+ request.allowed_role_ids.size() * 503
		+ profile_component * 601
	)
	return _positive_seed(raw_seed)


static func _positive_seed(raw_seed: int) -> int:
	var normalized: int = raw_seed % SEED_MODULUS
	if normalized < 0:
		normalized += SEED_MODULUS
	return normalized


func _request_for_attempt_seed(request: CaseGenerationRequest, attempt_seed: int) -> CaseGenerationRequest:
	return CASE_GENERATION_REQUEST.create(
		attempt_seed,
		request.board_columns,
		request.board_rows,
		request.generation_profile_id,
		request.allowed_role_ids,
		request.required_location_ids,
		request.required_suspect_count,
		request.generator_version
	)


func _attempt_data(
	attempt_request: CaseGenerationRequest,
	role_definitions: Array[RoleDefinition],
	attempt_index: int,
	attempt_evaluator: Callable
) -> Dictionary:
	if attempt_evaluator.is_valid():
		var injected: Variant = attempt_evaluator.call(attempt_request, attempt_index, role_definitions)
		if injected is Dictionary:
			return injected
		return {}
	var generator = CASE_GENERATOR.new()
	var candidate: CaseGenerationResult = generator.generate(attempt_request, role_definitions)
	if candidate == null or not candidate.is_success():
		return {
			"candidate": candidate,
			"candidate_fingerprint": _candidate_fingerprint(candidate),
		}
	var public_view = GENERATED_PUBLIC_CASE_VIEW.from_generation_result(candidate, role_definitions)
	var solver_result = CASE_GENERATOR_PUBLIC_SOLVER.new().solve(public_view, role_definitions)
	return {
		"candidate": candidate,
		"public_view": public_view,
		"solver_result": solver_result,
		"candidate_fingerprint": _candidate_fingerprint(candidate),
	}


func _ground_truth_evil_ids(attempt_data: Dictionary, candidate) -> PackedInt32Array:
	if attempt_data.has("ground_truth_evil_suspect_ids"):
		return _packed_ints(attempt_data.get("ground_truth_evil_suspect_ids"))
	if candidate is Object:
		var hidden_draft: Variant = (candidate as Object).get("hidden_case_draft")
		if hidden_draft is Object:
			var hidden_ids: Variant = (hidden_draft as Object).get("hidden_evil_suspect_ids")
			return _packed_ints(hidden_ids)
	return PackedInt32Array()


func _packed_ints(value: Variant) -> PackedInt32Array:
	if value is PackedInt32Array:
		var packed: PackedInt32Array = value
		return packed.duplicate()
	var result: PackedInt32Array = PackedInt32Array()
	if value is Array:
		for entry: Variant in value:
			result.append(int(entry))
	result.sort()
	return result


func _rejection_reason_for_solver_status(solver_status: StringName) -> StringName:
	if solver_status == CASE_GENERATOR_SOLVER_RESULT.STATUS_UNSUPPORTED:
		return REJECTION_UNSUPPORTED
	if solver_status == CASE_GENERATOR_SOLVER_RESULT.STATUS_MULTIPLE_SOLUTIONS:
		return REJECTION_MULTIPLE_SOLUTIONS
	if solver_status == CASE_GENERATOR_SOLVER_RESULT.STATUS_NO_SOLUTION:
		return REJECTION_NO_SOLUTION
	return REJECTION_SOLVER_FAILURE


func _candidate_fingerprint(candidate) -> String:
	if candidate == null:
		return ""
	if candidate is Dictionary:
		return String(candidate.get("fingerprint", ""))
	if candidate is Object:
		return String((candidate as Object).get("fingerprint"))
	return ""


func _candidate_is_failed_generation(candidate: Variant) -> bool:
	if not (candidate is Object):
		return false
	var candidate_object: Object = candidate as Object
	if candidate_object.has_method("is_success"):
		return not bool(candidate_object.call("is_success"))
	return false
