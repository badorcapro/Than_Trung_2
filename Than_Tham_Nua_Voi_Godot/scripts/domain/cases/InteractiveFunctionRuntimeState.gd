class_name InteractiveFunctionRuntimeState
extends RefCounted

enum State {
	HIDDEN,
	LOCKED_UNTIL_NEXT_TURN,
	AVAILABLE,
	EXHAUSTED,
	DISABLED,
	EXPIRED,
}

var suspect_id := 0
var state: State = State.HIDDEN
var revealed_on_turn := 0
var available_from_turn := 0
var function_type: CaseEnums.FunctionType = CaseEnums.FunctionType.NONE
var usage_limit := 0
var uses_remaining := 0
var target_count := 0


func _init(source_suspect_id: int = 0) -> void:
	suspect_id = source_suspect_id


func configure_hidden(role: RoleDefinition) -> void:
	state = State.HIDDEN
	revealed_on_turn = 0
	available_from_turn = 0
	function_type = role.function_type
	usage_limit = role.usage_limit
	uses_remaining = role.usage_limit
	target_count = role.target_count


func lock_after_reveal(current_turn_number: int) -> void:
	revealed_on_turn = current_turn_number
	available_from_turn = current_turn_number + 1
	state = State.LOCKED_UNTIL_NEXT_TURN


func update_for_turn(current_turn_number: int) -> bool:
	if state != State.LOCKED_UNTIL_NEXT_TURN:
		return false
	if current_turn_number < available_from_turn:
		return false
	state = State.AVAILABLE
	return true
