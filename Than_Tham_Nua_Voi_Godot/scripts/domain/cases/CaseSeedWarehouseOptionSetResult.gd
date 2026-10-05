class_name CaseSeedWarehouseOptionSetResult
extends RefCounted

const FAILURE_NONE: StringName = &""
const FAILURE_REQUESTED_COUNT_INVALID: StringName = &"requested_count_invalid"
const FAILURE_INSUFFICIENT_ELIGIBLE_ENTRIES: StringName = &"insufficient_eligible_entries"

var success: bool = false
var option_entries: Array[CaseSeedWarehouseEntry] = []
var option_warehouse_indices: Array[int] = []
var option_candidate_signatures: Array[String] = []
var option_selection_seeds: Array[int] = []
var selection_results: Array[CaseSeedWarehouseSelectionResult] = []
var requested_option_count: int = 0
var produced_option_count: int = 0
var option_set_seed: int = 0
var skipped_used_count: int = 0
var skipped_invalid_count: int = 0
var option_set_signature: String = ""
var failure_reason: StringName = FAILURE_NONE


func add_option(selection: CaseSeedWarehouseSelectionResult) -> void:
	selection_results.append(selection)
	if selection == null:
		return
	option_selection_seeds.append(selection.selection_seed)
	skipped_used_count += selection.skipped_used_count
	skipped_invalid_count += selection.skipped_invalid_count
	if selection.success and selection.selected_entry != null:
		option_entries.append(selection.selected_entry)
		option_warehouse_indices.append(selection.selected_warehouse_index)
		option_candidate_signatures.append(selection.selected_entry.candidate_signature)
		produced_option_count = option_entries.size()


func mark_success() -> void:
	success = true
	failure_reason = FAILURE_NONE
	finalize_signature()


func mark_failure(reason: StringName) -> void:
	success = false
	failure_reason = reason
	option_entries.clear()
	option_warehouse_indices.clear()
	option_candidate_signatures.clear()
	produced_option_count = 0
	finalize_signature()


func finalize_signature() -> void:
	produced_option_count = option_entries.size()
	option_set_signature = "warehouse_options|success:%s|seed:%d|requested:%d|produced:%d|selection_seeds:%s|indices:%s|signatures:%s|used:%d|invalid:%d|failure:%s" % [
		str(success),
		option_set_seed,
		requested_option_count,
		produced_option_count,
		_join_ints(option_selection_seeds),
		_join_ints(option_warehouse_indices),
		"||".join(option_candidate_signatures),
		skipped_used_count,
		skipped_invalid_count,
		String(failure_reason),
	]


func _join_ints(values: Array[int]) -> String:
	var parts: Array[String] = []
	for value: int in values:
		parts.append(str(value))
	return ",".join(parts)
