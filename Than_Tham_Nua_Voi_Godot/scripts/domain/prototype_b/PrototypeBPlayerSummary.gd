class_name PrototypeBPlayerSummary
extends RefCounted

var data: Dictionary = {}


func to_dict() -> Dictionary:
	return data.duplicate(true)


static func from_dict(value: Dictionary) -> PrototypeBPlayerSummary:
	var result := PrototypeBPlayerSummary.new()
	result.data = value.duplicate(true)
	return result
