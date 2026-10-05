class_name CaseTimedEventDispatcher
extends RefCounted

const HANDLER_SURGEON: StringName = &"surgeon"
const HANDLER_SERIAL_KILLER: StringName = &"serial_killer"
const SURGEON_TIMED_EVENT_SERVICE := preload("res://scripts/domain/cases/SurgeonTimedEventService.gd")
const SERIAL_KILLER_TIMED_EVENT_SERVICE := preload("res://scripts/domain/cases/SerialKillerTimedEventService.gd")

var _handlers: Array[Dictionary] = []


func _init() -> void:
	register_handler(HANDLER_SURGEON, SURGEON_TIMED_EVENT_SERVICE.new())
	register_handler(HANDLER_SERIAL_KILLER, SERIAL_KILLER_TIMED_EVENT_SERVICE.new())


func register_handler(handler_id: StringName, handler: RefCounted) -> void:
	if String(handler_id).is_empty() or handler == null:
		return
	_handlers.append({
		"handler_id": handler_id,
		"handler": handler,
	})


func clear_handlers() -> void:
	_handlers.clear()


func registered_handler_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for entry: Dictionary in _handlers:
		var handler_id: StringName = StringName(entry.get("handler_id", &""))
		ids.append(handler_id)
	return ids


func evaluate_all(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	roles: Array[RoleDefinition] = []
) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	for entry: Dictionary in _handlers:
		var handler: RefCounted = entry.get("handler", null) as RefCounted
		if handler == null or not handler.has_method("evaluate"):
			continue
		var events: Array[CaseTimedEventRuntimeState] = []
		var raw_result: Variant = (
			handler.call("evaluate_with_roles", case_definition, runtime_state, roles)
			if handler.has_method("evaluate_with_roles")
			else handler.call("evaluate", case_definition, runtime_state)
		)
		if raw_result is Array:
			for event: Variant in raw_result:
				if event is CaseTimedEventRuntimeState:
					events.append(event as CaseTimedEventRuntimeState)
		var handler_id: StringName = StringName(entry.get("handler_id", &""))
		results.append({
			"handler_id": handler_id,
			"events": events,
		})
	return results
