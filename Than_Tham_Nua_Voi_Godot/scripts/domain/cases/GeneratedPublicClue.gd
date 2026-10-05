class_name GeneratedPublicClue
extends RefCounted

var suspect_id: int = 0
var true_role_id: StringName = &""
var displayed_role_id: StringName = &""
var behavior_role_id: StringName = &""
var payload_kind: int = InvestigationInformationResult.PayloadKind.NONE
var text: String = ""
var numeric_value: int = -1
var referenced_suspect_ids: PackedInt32Array = PackedInt32Array()
var weather_group_slots: PackedInt32Array = PackedInt32Array()
var in_play_role_id: StringName = &""
var not_in_play_role_id: StringName = &""
var claimed_in_play_is_true: bool = false
var claimed_not_in_play_is_true: bool = false
var direction_key: StringName = &""
var truth_mode: int = InvestigationInformationResult.TruthMode.TRUTHFUL
var clock_start_hour: int = -1
var clock_end_hour: int = -1
var clock_claims_ringing: bool = false


static func from_information_result(result: InvestigationInformationResult) -> GeneratedPublicClue:
	var clue := GeneratedPublicClue.new()
	if result == null:
		return clue
	clue.suspect_id = result.suspect_id
	clue.true_role_id = result.true_role_id
	clue.displayed_role_id = result.displayed_role_id
	clue.behavior_role_id = result.behavior_role_id
	clue.payload_kind = result.payload_kind
	clue.text = result.public_text()
	clue.numeric_value = result.numeric_value
	clue.in_play_role_id = result.in_play_role_id
	clue.not_in_play_role_id = result.not_in_play_role_id
	clue.claimed_in_play_is_true = result.claimed_in_play_is_true
	clue.claimed_not_in_play_is_true = result.claimed_not_in_play_is_true
	clue.direction_key = result.direction_key
	clue.truth_mode = result.truth_mode
	clue.referenced_suspect_ids = _referenced_ids_from_result(result)
	clue.weather_group_slots = result.weather_group_slots.duplicate()
	if result.behavior_role_id == &"clock_maker" and result.numeric_value > 0:
		clue.clock_start_hour = result.numeric_value
		clue.clock_end_hour = result.numeric_value + 1
		# The public announcement explicitly says either "will ring" or "will not ring".
		clue.clock_claims_ringing = result.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL
	return clue


func fingerprint_text() -> String:
	var value: String = "%d:%s:%s:%d:%d:%s:%s:%s:%s:%s:%s:%s" % [
		suspect_id,
		String(true_role_id),
		String(behavior_role_id),
		payload_kind,
		numeric_value,
		_join_ints(referenced_suspect_ids),
		_join_ints(weather_group_slots),
		String(in_play_role_id),
		String(not_in_play_role_id),
		str(claimed_in_play_is_true),
		str(claimed_not_in_play_is_true),
		String(direction_key),
	]
	if behavior_role_id == &"clock_maker":
		value += "|interval:%d:%d:%s" % [clock_start_hour, clock_end_hour, str(clock_claims_ringing)]
	return value


static func _referenced_ids_from_result(result: InvestigationInformationResult) -> PackedInt32Array:
	if result == null:
		return PackedInt32Array()
	var ids: PackedInt32Array = PackedInt32Array()
	if result.payload_kind == InvestigationInformationResult.PayloadKind.WEATHER_REPORT or result.payload_kind == InvestigationInformationResult.PayloadKind.NO_MEDDLER_FOUND:
		ids = result.weather_suspect_ids.duplicate()
	return ids


func _join_ints(values: PackedInt32Array) -> String:
	var parts: Array[String] = []
	for value: int in values:
		parts.append(str(value))
	return ",".join(parts)
