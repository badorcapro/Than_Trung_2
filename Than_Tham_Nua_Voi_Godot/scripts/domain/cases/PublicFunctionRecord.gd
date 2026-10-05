class_name PublicFunctionRecord
extends RefCounted

var record_id := 0
var source_suspect_id := 0
var public_function_name := ""
var target_suspect_ids := PackedInt32Array()
var acting_player_id: StringName
var executed_on_turn := 0
var public_result_text := ""
var is_locked := false


func configure(source_record_id: int, source_id: int, function_name: String, target_ids: PackedInt32Array, player_id: StringName, turn_number: int, result_text: String) -> bool:
	if is_locked or source_record_id <= 0 or source_id <= 0:
		return false
	record_id = source_record_id
	source_suspect_id = source_id
	public_function_name = function_name
	target_suspect_ids = target_ids.duplicate()
	acting_player_id = player_id
	executed_on_turn = turn_number
	public_result_text = result_text
	is_locked = true
	return true


func summary_text() -> String:
	if target_suspect_ids.size() == 2:
		return "%s: Nghi phạm %d và %d %s." % [
			public_function_name,
			target_suspect_ids[0],
			target_suspect_ids[1],
			public_result_text.to_lower(),
		]
	return _sentence_text(public_result_text)


func _sentence_text(value: String) -> String:
	var clean: String = value.strip_edges()
	if clean.is_empty():
		return "."
	var last: String = clean.substr(clean.length() - 1, 1)
	if last in [".", "!", "?"]:
		return clean
	return clean + "."
