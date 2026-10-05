class_name CaseSeedWarehouseOptionComposer
extends RefCounted

const OPTION_SET_RESULT := preload("res://scripts/domain/cases/CaseSeedWarehouseOptionSetResult.gd")
const WAREHOUSE_SELECTOR := preload("res://scripts/domain/cases/CaseSeedWarehouseSelector.gd")
const CASE_GENERATION_REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")

const SEED_MODULUS := 2147483647


func compose_options(
	warehouse,
	option_set_seed: int,
	used_candidate_signatures: Array[String] = [],
	profile_request: CaseGenerationRequest = null,
	role_definitions: Array[RoleDefinition] = [],
	requested_option_count: int = 3,
	max_attempts: int = 24,
	attempt_evaluator: Callable = Callable()
) -> CaseSeedWarehouseOptionSetResult:
	var result: CaseSeedWarehouseOptionSetResult = OPTION_SET_RESULT.new()
	result.option_set_seed = option_set_seed
	result.requested_option_count = requested_option_count
	if requested_option_count <= 0:
		result.mark_failure(OPTION_SET_RESULT.FAILURE_REQUESTED_COUNT_INVALID)
		return result

	var local_used: Array[String] = []
	for signature: String in used_candidate_signatures:
		local_used.append(signature)
	var selector: CaseSeedWarehouseSelector = WAREHOUSE_SELECTOR.new()
	for option_index: int in range(requested_option_count):
		var option_seed: int = option_seed_for_index(option_set_seed, option_index, profile_request)
		var selection: CaseSeedWarehouseSelectionResult = selector.select_entry(
			warehouse,
			option_seed,
			local_used,
			profile_request,
			role_definitions,
			max_attempts,
			attempt_evaluator
		)
		result.add_option(selection)
		if not selection.success or selection.selected_entry == null:
			result.mark_failure(OPTION_SET_RESULT.FAILURE_INSUFFICIENT_ELIGIBLE_ENTRIES)
			return result
		local_used.append(selection.selected_entry.candidate_signature)

	result.mark_success()
	return result


static func option_seed_for_index(option_set_seed: int, option_index: int, profile_request: CaseGenerationRequest) -> int:
	var profile_component: int = 17
	var columns: int = 0
	var rows: int = 0
	var suspect_count: int = 0
	var location_count: int = 0
	var role_count: int = 0
	var generator_version: int = CASE_GENERATION_REQUEST.DEFAULT_GENERATOR_VERSION
	if profile_request != null:
		columns = profile_request.board_columns
		rows = profile_request.board_rows
		suspect_count = profile_request.required_suspect_count
		location_count = profile_request.required_location_ids.size()
		role_count = profile_request.allowed_role_ids.size()
		generator_version = profile_request.generator_version
		if profile_request.generation_profile_id == CASE_GENERATION_REQUEST.PROFILE_TUTORIAL_EASY:
			profile_component = 19
		elif profile_request.generation_profile_id == CASE_GENERATION_REQUEST.PROFILE_NORMAL_FULL:
			profile_component = 31
	var raw_seed: int = (
		option_set_seed
		+ option_index * 1000003
		+ option_index * option_index * 37
		+ generator_version * 9181
		+ columns * 113
		+ rows * 223
		+ suspect_count * 331
		+ location_count * 419
		+ role_count * 521
		+ profile_component * 631
	)
	return _positive_seed(raw_seed)


static func _positive_seed(raw_seed: int) -> int:
	var normalized: int = raw_seed % SEED_MODULUS
	if normalized < 0:
		normalized += SEED_MODULUS
	return normalized
