class_name CaseClockService
extends RefCounted

const ACTION_INVESTIGATION: StringName = &"investigation"
const ACTION_SINGLE_ACCUSATION: StringName = &"single_accusation"
const ACTION_ACTIVE_FUNCTION: StringName = &"active_function"

const INVESTIGATION_HOURS: int = 2
const SINGLE_ACCUSATION_HOURS: int = 1
const ACTIVE_FUNCTION_HOURS: int = 0


func action_time_cost(action_type: StringName) -> int:
	if action_type == ACTION_INVESTIGATION:
		return INVESTIGATION_HOURS
	if action_type == ACTION_SINGLE_ACCUSATION:
		return SINGLE_ACCUSATION_HOURS
	if action_type == ACTION_ACTIVE_FUNCTION:
		return ACTIVE_FUNCTION_HOURS
	return 0


func apply_action_time(runtime_state: CaseRuntimeState, action_id: StringName, action_type: StringName) -> bool:
	if runtime_state == null or not runtime_state.is_initialized:
		return false
	if not runtime_state.mark_time_action_applied(action_id):
		return false
	return runtime_state.advance_elapsed_hours(action_time_cost(action_type), action_type)


func advance_hours(runtime_state: CaseRuntimeState, hours: int, source: StringName = &"manual") -> bool:
	if runtime_state == null or not runtime_state.is_initialized:
		return false
	return runtime_state.advance_elapsed_hours(hours, source)
