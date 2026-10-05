class_name CaseSeedWarehouseSelector
extends RefCounted

const SELECTION_RESULT := preload("res://scripts/domain/cases/CaseSeedWarehouseSelectionResult.gd")
const WAREHOUSE_ENTRY := preload("res://scripts/domain/cases/CaseSeedWarehouseEntry.gd")
const WAREHOUSE_BUILDER := preload("res://scripts/domain/cases/CaseSeedWarehouseBuilder.gd")
const CASE_GENERATION_REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")

const SEED_MODULUS := 2147483647


func select_entry(
	warehouse,
	selection_seed: int,
	used_candidate_signatures: Array[String] = [],
	profile_request: CaseGenerationRequest = null,
	role_definitions: Array[RoleDefinition] = [],
	max_attempts: int = 24,
	attempt_evaluator: Callable = Callable()
) -> CaseSeedWarehouseSelectionResult:
	var result: CaseSeedWarehouseSelectionResult = SELECTION_RESULT.new()
	result.selection_seed = selection_seed
	var entries: Array[CaseSeedWarehouseEntry] = _entries_from_warehouse(warehouse)
	if entries.is_empty():
		result.mark_failure(SELECTION_RESULT.FAILURE_WAREHOUSE_EMPTY)
		return result

	var eligible: Array[Dictionary] = []
	for index: int in range(entries.size()):
		var entry: CaseSeedWarehouseEntry = entries[index]
		if entry == null or not _entry_metadata_compatible(entry, profile_request):
			result.skipped_invalid_count += 1
			continue
		if used_candidate_signatures.has(entry.candidate_signature):
			result.skipped_used_count += 1
			continue
		eligible.append({
			"entry": entry,
			"warehouse_index": index,
		})
	result.eligible_entry_count = eligible.size()
	if eligible.is_empty():
		result.mark_failure(SELECTION_RESULT.FAILURE_NO_ELIGIBLE_ENTRIES)
		return result

	result.deterministic_start_index = _start_index(selection_seed, profile_request, eligible.size())
	var builder: CaseSeedWarehouseBuilder = WAREHOUSE_BUILDER.new()
	for offset: int in range(eligible.size()):
		var eligible_index: int = (result.deterministic_start_index + offset) % eligible.size()
		var candidate: Dictionary = eligible[eligible_index]
		var entry: CaseSeedWarehouseEntry = candidate.get("entry", null) as CaseSeedWarehouseEntry
		var warehouse_index: int = int(candidate.get("warehouse_index", -1))
		var verification: Dictionary = builder.verify_entry(entry, role_definitions, max_attempts, attempt_evaluator)
		if bool(verification.get("passed", false)):
			result.mark_success(entry, warehouse_index)
			return result
		result.skipped_invalid_count += 1

	result.mark_failure(SELECTION_RESULT.FAILURE_NO_VALID_ENTRY)
	return result


func _entries_from_warehouse(warehouse) -> Array[CaseSeedWarehouseEntry]:
	var entries: Array[CaseSeedWarehouseEntry] = []
	if warehouse == null:
		return entries
	if warehouse is CaseSeedWarehouseBuildResult:
		for entry: CaseSeedWarehouseEntry in warehouse.entries:
			entries.append(entry)
	elif warehouse is Array:
		for value: Variant in warehouse:
			if value is CaseSeedWarehouseEntry:
				entries.append(value)
	return entries


func _entry_metadata_compatible(entry: CaseSeedWarehouseEntry, profile_request: CaseGenerationRequest) -> bool:
	if entry.schema_version != WAREHOUSE_ENTRY.SCHEMA_VERSION:
		return false
	if entry.generator_version != CASE_GENERATION_REQUEST.DEFAULT_GENERATOR_VERSION:
		return false
	if profile_request == null:
		return true
	return (
		entry.board_columns == profile_request.board_columns
		and entry.board_rows == profile_request.board_rows
		and entry.board_slot_count == profile_request.board_slot_count
		and entry.generation_profile_id == profile_request.generation_profile_id
		and (profile_request.required_suspect_count == 0 or entry.required_suspect_count == profile_request.required_suspect_count)
		and entry.required_location_ids == profile_request.required_location_ids
		and entry.allowed_role_ids == profile_request.allowed_role_ids
		and entry.generator_version == profile_request.generator_version
	)


func _start_index(selection_seed: int, profile_request: CaseGenerationRequest, eligible_count: int) -> int:
	if eligible_count <= 0:
		return -1
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
	var mixed_seed: int = (
		selection_seed
		+ generator_version * 7919
		+ columns * 157
		+ rows * 263
		+ suspect_count * 383
		+ location_count * 467
		+ role_count * 587
		+ profile_component * 683
	)
	return _positive_mod(mixed_seed, eligible_count)


func _positive_mod(value: int, modulus: int) -> int:
	if modulus <= 0:
		return 0
	var normalized: int = value % modulus
	if normalized < 0:
		normalized += modulus
	return normalized
