class_name PersistentMarkState
extends RefCounted

var mark_id: StringName
var source_id: StringName
var count := 1
var state_id: StringName = &"ACTIVE"
var test_only := true


func to_dict() -> Dictionary:
	return {
		"mark_id": String(mark_id),
		"source_id": String(source_id),
		"count": count,
		"state_id": String(state_id),
		"test_only": test_only,
	}


static func from_dict(data: Dictionary) -> PersistentMarkState:
	var result := PersistentMarkState.new()
	result.mark_id = StringName(data.get("mark_id", ""))
	result.source_id = StringName(data.get("source_id", ""))
	result.count = int(data.get("count", 1))
	result.state_id = StringName(data.get("state_id", "ACTIVE"))
	result.test_only = bool(data.get("test_only", true))
	return result
