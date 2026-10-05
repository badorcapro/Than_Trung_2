class_name InvestigationObscureRelation
extends RefCounted

var source_suspect_id: int = 0
var target_suspect_id: int = 0


func configure(source_id: int, target_id: int) -> bool:
	if source_id <= 0 or target_id <= 0:
		return false
	source_suspect_id = source_id
	target_suspect_id = target_id
	return true
