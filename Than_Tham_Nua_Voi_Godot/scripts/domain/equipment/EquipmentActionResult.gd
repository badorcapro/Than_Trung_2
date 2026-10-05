class_name EquipmentActionResult
extends RefCounted

var success := false
var code: StringName
var instance_id: StringName
var material_delta := 0
var duplicate_consumed_id: StringName

static func make(ok: bool, result_code: StringName, target_id: StringName = &"") -> EquipmentActionResult:
	var result := EquipmentActionResult.new()
	result.success = ok; result.code = result_code; result.instance_id = target_id
	return result
