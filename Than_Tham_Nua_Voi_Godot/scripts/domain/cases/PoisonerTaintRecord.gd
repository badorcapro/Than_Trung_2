class_name PoisonerTaintRecord
extends RefCounted

const STATUS_APPLIED: StringName = &"APPLIED"
const STATUS_SOURCE_CORRUPTED: StringName = &"SOURCE_CORRUPTED"
const STATUS_NO_ELIGIBLE_TARGET: StringName = &"NO_ELIGIBLE_TARGET"
const STATUS_INVALID: StringName = &"INVALID"

var source_suspect_id := 0
var target_suspect_id := 0
var resolved := false
var applied := false
var status: StringName = &""


func configure(source_id: int, target_id: int, did_apply: bool, result_status: StringName) -> bool:
	source_suspect_id = source_id
	target_suspect_id = target_id
	applied = did_apply
	resolved = true
	status = result_status
	return true
