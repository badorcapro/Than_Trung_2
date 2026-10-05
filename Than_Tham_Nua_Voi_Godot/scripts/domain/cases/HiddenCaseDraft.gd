class_name HiddenCaseDraft
extends RefCounted

var board_columns: int = 0
var board_rows: int = 0
var board_slot_count: int = 0
var logical_board_slots: PackedInt32Array = PackedInt32Array()
var board_tiles: Array = []
var suspects: Array = []
var public_clues: Array = []
var hidden_evil_suspect_ids: PackedInt32Array = PackedInt32Array()
var suspected_role_ids: Array[StringName] = []
var poisoner_source_suspect_id: int = 0
var poisoner_taint_target_suspect_id: int = 0
var barkeep_source_suspect_id: int = 0
var barkeep_transform_target_suspect_id: int = 0
var spectre_source_suspect_id: int = 0
var spectre_obscure_target_suspect_id: int = 0
var clock_tower_ring_hour: int = 0


func fingerprint_text() -> String:
	var text: String = "hidden|board:%dx%d|slots:%s|tiles:%s|suspects:%s|public:%s|evil:%s|suspected:%s" % [
		board_columns,
		board_rows,
		_join_ints(logical_board_slots),
		_join_tiles(board_tiles),
		_join_suspects(suspects),
		_join_public_clues(public_clues),
		_join_ints(hidden_evil_suspect_ids),
		_join_role_ids(suspected_role_ids),
	]
	if poisoner_source_suspect_id > 0:
		text += "|taint:%d>%d" % [poisoner_source_suspect_id, poisoner_taint_target_suspect_id]
	if barkeep_source_suspect_id > 0:
		var displayed_role_id: StringName = &""
		for suspect in suspects:
			if suspect != null and suspect.suspect_id == barkeep_transform_target_suspect_id:
				displayed_role_id = suspect.displayed_role_id
				break
		text += "|transform:%d>%d:%s" % [barkeep_source_suspect_id, barkeep_transform_target_suspect_id, displayed_role_id]
	if spectre_source_suspect_id > 0:
		text += "|obscure:%d>%d" % [spectre_source_suspect_id, spectre_obscure_target_suspect_id]
	if clock_tower_ring_hour > 0:
		text += "|clock:%d" % clock_tower_ring_hour
	return text


func _join_role_ids(values: Array[StringName]) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for role_id: StringName in values:
		parts.append(String(role_id))
	return ",".join(parts)


func _join_ints(values: PackedInt32Array) -> String:
	var parts: Array[String] = []
	for value: int in values:
		parts.append(str(value))
	return ",".join(parts)


func _join_tiles(values: Array) -> String:
	var parts: Array[String] = []
	for value in values:
		if value != null:
			parts.append(value.fingerprint_text())
	return ",".join(parts)


func _join_suspects(values: Array) -> String:
	var parts: Array[String] = []
	for value in values:
		if value != null:
			parts.append(value.fingerprint_text())
	return ",".join(parts)


func _join_public_clues(values: Array) -> String:
	var parts: Array[String] = []
	for value in values:
		if value != null:
			parts.append(value.fingerprint_text())
	return ",".join(parts)
