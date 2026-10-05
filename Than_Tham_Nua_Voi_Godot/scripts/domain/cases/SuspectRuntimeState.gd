class_name SuspectRuntimeState
extends RefCounted

var suspect_id: int
var current_role_id: StringName = &""
var is_runtime_corrupted := false
var runtime_corrupted_by_suspect_id := 0
var is_investigated := false
var is_arrested := false
var is_dead := false
var killed_by: StringName = &""
var interactive_function: InteractiveFunctionRuntimeState


func _init(source_suspect_id: int = 0, source_role_id: StringName = &"") -> void:
	suspect_id = source_suspect_id
	current_role_id = source_role_id


func set_current_role(role_id: StringName) -> bool:
	if String(role_id).is_empty():
		return false
	current_role_id = role_id
	return true


func apply_runtime_corruption(source_suspect_id: int) -> bool:
	if source_suspect_id <= 0:
		return false
	if is_runtime_corrupted and runtime_corrupted_by_suspect_id == source_suspect_id:
		return true
	is_runtime_corrupted = true
	runtime_corrupted_by_suspect_id = source_suspect_id
	return true


func mark_arrested() -> bool:
	if is_arrested:
		return false
	is_arrested = true
	return true


func mark_dead(source: StringName = &"") -> bool:
	if is_dead:
		return false
	is_dead = true
	killed_by = source
	return true
