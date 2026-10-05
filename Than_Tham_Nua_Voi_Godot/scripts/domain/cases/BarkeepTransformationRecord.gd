class_name BarkeepTransformationRecord
extends RefCounted

const STATUS_APPLIED: StringName = &"APPLIED"
const STATUS_DRUNKARD_ALREADY_EXISTS: StringName = &"DRUNKARD_ALREADY_EXISTS"
const STATUS_INVALID: StringName = &"INVALID"

var source_suspect_id := 0
var target_suspect_id := 0
var original_target_role_id: StringName = &""
var resulting_role_id: StringName = &""
var resolved := false
var applied := false
var status: StringName = &""


func configure(
	source_id: int,
	target_id: int,
	original_role_id: StringName,
	result_role_id: StringName,
	did_apply: bool,
	result_status: StringName
) -> void:
	source_suspect_id = source_id
	target_suspect_id = target_id
	original_target_role_id = original_role_id
	resulting_role_id = result_role_id
	applied = did_apply
	resolved = true
	status = result_status
