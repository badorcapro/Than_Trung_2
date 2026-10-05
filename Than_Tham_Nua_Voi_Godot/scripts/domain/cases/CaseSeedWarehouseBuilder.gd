class_name CaseSeedWarehouseBuilder
extends RefCounted

const WAREHOUSE_ENTRY := preload("res://scripts/domain/cases/CaseSeedWarehouseEntry.gd")
const BUILD_RESULT := preload("res://scripts/domain/cases/CaseSeedWarehouseBuildResult.gd")
const ACCEPTANCE_SERVICE := preload("res://scripts/domain/cases/CaseGenerationAcceptanceService.gd")
const ACCEPTANCE_RESULT := preload("res://scripts/domain/cases/CaseGenerationAcceptanceResult.gd")
const CASE_GENERATION_REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")


func build(
	request_template: CaseGenerationRequest,
	root_seeds: PackedInt32Array,
	target_count: int,
	role_definitions: Array[RoleDefinition] = [],
	max_attempts: int = 24,
	attempt_evaluator: Callable = Callable()
) -> CaseSeedWarehouseBuildResult:
	var result: CaseSeedWarehouseBuildResult = BUILD_RESULT.new()
	result.requested_root_seeds = root_seeds.duplicate()
	result.target_count = target_count
	if request_template != null:
		result.generator_version = request_template.generator_version
		result.generation_profile_id = request_template.generation_profile_id
	if request_template == null:
		result.failure_reason = BUILD_RESULT.FAILURE_REQUEST_NULL
		result.finalize_signature()
		return result
	if target_count <= 0:
		result.failure_reason = BUILD_RESULT.FAILURE_TARGET_COUNT_INVALID
		result.finalize_signature()
		return result

	var seen_signatures: Dictionary = {}
	var acceptance_service: CaseGenerationAcceptanceService = ACCEPTANCE_SERVICE.new()
	for root_seed: int in root_seeds:
		if result.entries.size() >= target_count:
			break
		var request: CaseGenerationRequest = _request_for_root_seed(request_template, root_seed)
		var acceptance: CaseGenerationAcceptanceResult = acceptance_service.accept_unique_candidate(
			request,
			role_definitions,
			max_attempts,
			attempt_evaluator
		)
		if not acceptance.success:
			result.record_failure(acceptance.failure_reason)
			continue
		var entry: CaseSeedWarehouseEntry = WAREHOUSE_ENTRY.from_acceptance(request, acceptance)
		if entry == null:
			result.record_failure(&"entry_build_failed")
			continue
		if seen_signatures.has(entry.candidate_signature):
			result.record_duplicate()
			continue
		seen_signatures[entry.candidate_signature] = true
		result.entries.append(entry)
	result.finalize_signature()
	return result


func build_varied_suspect_counts(
	request_template: CaseGenerationRequest,
	root_seeds: PackedInt32Array,
	target_count: int,
	role_definitions: Array[RoleDefinition],
	min_suspect_count: int,
	max_suspect_count: int,
	max_attempts: int = 24
) -> CaseSeedWarehouseBuildResult:
	var result: CaseSeedWarehouseBuildResult = BUILD_RESULT.new()
	result.requested_root_seeds = root_seeds.duplicate()
	result.target_count = target_count
	if request_template == null:
		result.failure_reason = BUILD_RESULT.FAILURE_REQUEST_NULL
		result.finalize_signature()
		return result
	result.generator_version = request_template.generator_version
	result.generation_profile_id = request_template.generation_profile_id
	if target_count <= 0 or min_suspect_count <= 0 or max_suspect_count < min_suspect_count:
		result.failure_reason = BUILD_RESULT.FAILURE_TARGET_COUNT_INVALID
		result.finalize_signature()
		return result
	var seen_signatures: Dictionary = {}
	var count_range: int = max_suspect_count - min_suspect_count + 1
	for root_seed: int in root_seeds:
		if result.entries.size() >= target_count:
			break
		var suspect_count: int = min_suspect_count + posmod(root_seed, count_range)
		var request: CaseGenerationRequest = CASE_GENERATION_REQUEST.create(
			root_seed,
			request_template.board_columns,
			request_template.board_rows,
			request_template.generation_profile_id,
			request_template.allowed_role_ids,
			request_template.required_location_ids,
			suspect_count,
			request_template.generator_version
		)
		var single_root: PackedInt32Array = PackedInt32Array([root_seed])
		var single: CaseSeedWarehouseBuildResult = build(request, single_root, 1, role_definitions, max_attempts)
		if single.entries.is_empty():
			var failure_reason: String = "no_accepted_candidate"
			for reason_value: Variant in single.failure_summary.keys():
				failure_reason = String(reason_value)
				break
			result.record_failure(StringName("count_%d_%s" % [suspect_count, failure_reason]))
			continue
		var entry: CaseSeedWarehouseEntry = single.entries[0]
		if seen_signatures.has(entry.candidate_signature):
			result.record_duplicate()
			continue
		seen_signatures[entry.candidate_signature] = true
		result.entries.append(entry)
	result.finalize_signature()
	return result


func verify_entry(
	entry: CaseSeedWarehouseEntry,
	role_definitions: Array[RoleDefinition] = [],
	max_attempts: int = 24,
	attempt_evaluator: Callable = Callable()
) -> Dictionary:
	var checks: Dictionary = {
		"passed": false,
		"schema_version": false,
		"generator_version": false,
		"accepted": false,
		"attempt_index": false,
		"derived_seed": false,
		"candidate_signature": false,
		"evil_solution": false,
	}
	if entry == null:
		return checks
	checks.schema_version = entry.schema_version == WAREHOUSE_ENTRY.SCHEMA_VERSION
	checks.generator_version = entry.generator_version == CASE_GENERATION_REQUEST.DEFAULT_GENERATOR_VERSION
	if not bool(checks.schema_version) or not bool(checks.generator_version):
		return checks
	var acceptance: CaseGenerationAcceptanceResult = ACCEPTANCE_SERVICE.new().accept_unique_candidate(
		entry.request(),
		role_definitions,
		max_attempts,
		attempt_evaluator
	)
	checks.accepted = acceptance.success
	if not acceptance.success:
		return checks
	checks.attempt_index = acceptance.accepted_attempt_index == entry.accepted_attempt_index
	checks.derived_seed = acceptance.accepted_derived_seed == entry.accepted_derived_seed
	checks.candidate_signature = WAREHOUSE_ENTRY.from_acceptance(entry.request(), acceptance).candidate_signature == entry.candidate_signature
	checks.evil_solution = _accepted_evil_ids(acceptance) == entry.evil_suspect_ids
	checks.passed = (
		bool(checks.schema_version)
		and bool(checks.generator_version)
		and bool(checks.accepted)
		and bool(checks.attempt_index)
		and bool(checks.derived_seed)
		and bool(checks.candidate_signature)
		and bool(checks.evil_solution)
	)
	return checks


func _request_for_root_seed(request_template: CaseGenerationRequest, root_seed: int) -> CaseGenerationRequest:
	return CASE_GENERATION_REQUEST.create(
		root_seed,
		request_template.board_columns,
		request_template.board_rows,
		request_template.generation_profile_id,
		request_template.allowed_role_ids,
		request_template.required_location_ids,
		request_template.required_suspect_count,
		request_template.generator_version
	)


func _accepted_evil_ids(acceptance: CaseGenerationAcceptanceResult) -> PackedInt32Array:
	if acceptance.accepted_solver_result is Object:
		var ids: Variant = (acceptance.accepted_solver_result as Object).get("unique_evil_suspect_ids")
		if ids is PackedInt32Array:
			var packed: PackedInt32Array = ids
			return packed.duplicate()
	return PackedInt32Array()
