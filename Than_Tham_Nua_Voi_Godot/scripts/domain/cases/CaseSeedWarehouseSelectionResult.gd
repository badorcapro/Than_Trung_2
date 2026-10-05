class_name CaseSeedWarehouseSelectionResult
extends RefCounted

const FAILURE_NONE: StringName = &""
const FAILURE_WAREHOUSE_EMPTY: StringName = &"warehouse_empty"
const FAILURE_NO_ELIGIBLE_ENTRIES: StringName = &"no_eligible_entries"
const FAILURE_NO_VALID_ENTRY: StringName = &"no_valid_entry"

var success: bool = false
var selected_entry: CaseSeedWarehouseEntry = null
var selected_warehouse_index: int = -1
var selection_seed: int = 0
var eligible_entry_count: int = 0
var skipped_used_count: int = 0
var skipped_invalid_count: int = 0
var deterministic_start_index: int = -1
var selection_signature: String = ""
var failure_reason: StringName = FAILURE_NONE


func mark_success(entry: CaseSeedWarehouseEntry, warehouse_index: int) -> void:
	success = true
	selected_entry = entry
	selected_warehouse_index = warehouse_index
	failure_reason = FAILURE_NONE
	finalize_signature()


func mark_failure(reason: StringName) -> void:
	success = false
	failure_reason = reason
	finalize_signature()


func finalize_signature() -> void:
	var selected_signature := ""
	if selected_entry != null:
		selected_signature = selected_entry.candidate_signature
	selection_signature = "warehouse_select|success:%s|seed:%d|start:%d|selected_index:%d|eligible:%d|used:%d|invalid:%d|selected:%s|failure:%s" % [
		str(success),
		selection_seed,
		deterministic_start_index,
		selected_warehouse_index,
		eligible_entry_count,
		skipped_used_count,
		skipped_invalid_count,
		selected_signature,
		String(failure_reason),
	]
