class_name InvestigationSelectionState
extends RefCounted

enum Mode {
	IDLE,
	SELECTING_INVESTIGATION_TARGET,
	SELECTING_FUNCTION,
	SELECTING_FUNCTION_TARGETS,
	SELECTING_SUBMISSION,
	SELECTING_SUBMISSION_CLASSIFICATION,
	RESOLVING_ACTION,
}

var mode: Mode = Mode.IDLE
var selected_suspect_id := 0
var available_function_owner_ids := PackedInt32Array()
var selected_function_owner_id := 0
var selected_function_target_ids := PackedInt32Array()
var required_function_target_count := 2
var selected_submission_evil_ids := PackedInt32Array()


func begin_selection() -> bool:
	if mode != Mode.IDLE:
		return false
	mode = Mode.SELECTING_INVESTIGATION_TARGET
	selected_suspect_id = 0
	return true


func begin_function_selection(owner_ids: PackedInt32Array, target_count: int = 2) -> bool:
	if mode != Mode.IDLE or owner_ids.is_empty():
		return false
	available_function_owner_ids = owner_ids.duplicate()
	required_function_target_count = target_count
	if required_function_target_count < 1:
		required_function_target_count = 1
	if owner_ids.size() == 1:
		selected_function_owner_id = owner_ids[0]
		mode = Mode.SELECTING_FUNCTION_TARGETS
	else:
		mode = Mode.SELECTING_FUNCTION
	return true


func select_function_owner(owner_suspect_id: int, target_count: int = 2) -> bool:
	if mode != Mode.SELECTING_FUNCTION or owner_suspect_id not in available_function_owner_ids:
		return false
	selected_function_owner_id = owner_suspect_id
	required_function_target_count = target_count
	if required_function_target_count < 1:
		required_function_target_count = 1
	selected_function_target_ids.clear()
	mode = Mode.SELECTING_FUNCTION_TARGETS
	return true


func toggle_function_target(suspect_id: int) -> bool:
	if mode != Mode.SELECTING_FUNCTION_TARGETS or suspect_id <= 0:
		return false
	var index := selected_function_target_ids.find(suspect_id)
	if index >= 0:
		selected_function_target_ids.remove_at(index)
		return true
	if selected_function_target_ids.size() >= required_function_target_count:
		return false
	selected_function_target_ids.append(suspect_id)
	return true


func begin_submission() -> bool:
	if mode != Mode.IDLE:
		return false
	selected_submission_evil_ids.clear()
	mode = Mode.SELECTING_SUBMISSION
	return true


func toggle_submission_suspect(suspect_id: int) -> bool:
	if mode != Mode.SELECTING_SUBMISSION or suspect_id <= 0:
		return false
	var index := selected_submission_evil_ids.find(suspect_id)
	if index >= 0:
		selected_submission_evil_ids.remove_at(index)
	else:
		selected_submission_evil_ids.append(suspect_id)
	return true


func begin_submission_classification() -> bool:
	if mode != Mode.SELECTING_SUBMISSION:
		return false
	mode = Mode.SELECTING_SUBMISSION_CLASSIFICATION
	return true


func begin_resolving_submission() -> bool:
	if mode != Mode.SELECTING_SUBMISSION and mode != Mode.SELECTING_SUBMISSION_CLASSIFICATION:
		return false
	mode = Mode.RESOLVING_ACTION
	return true


func select_suspect(suspect_id: int) -> bool:
	if mode != Mode.SELECTING_INVESTIGATION_TARGET or suspect_id <= 0:
		return false
	selected_suspect_id = suspect_id
	return true


func cancel() -> bool:
	if mode == Mode.IDLE or mode == Mode.RESOLVING_ACTION:
		return false
	finish()
	return true


func begin_resolving() -> bool:
	if mode != Mode.SELECTING_INVESTIGATION_TARGET or selected_suspect_id <= 0:
		return false
	mode = Mode.RESOLVING_ACTION
	return true


func begin_resolving_function() -> bool:
	if mode != Mode.SELECTING_FUNCTION_TARGETS or selected_function_owner_id <= 0 or selected_function_target_ids.size() != required_function_target_count:
		return false
	mode = Mode.RESOLVING_ACTION
	return true


func finish() -> void:
	selected_suspect_id = 0
	available_function_owner_ids.clear()
	selected_function_owner_id = 0
	selected_function_target_ids.clear()
	required_function_target_count = 2
	selected_submission_evil_ids.clear()
	mode = Mode.IDLE
