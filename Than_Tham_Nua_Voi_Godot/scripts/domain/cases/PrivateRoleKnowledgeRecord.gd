class_name PrivateRoleKnowledgeRecord
extends RefCounted

var player_id: StringName
var suspect_id := 0
var true_role_id: StringName


func configure(owner_player_id: StringName, source_suspect_id: int, source_true_role_id: StringName) -> bool:
	if String(owner_player_id).is_empty() or source_suspect_id <= 0 or String(source_true_role_id).is_empty():
		return false
	player_id = owner_player_id
	suspect_id = source_suspect_id
	true_role_id = source_true_role_id
	return true
