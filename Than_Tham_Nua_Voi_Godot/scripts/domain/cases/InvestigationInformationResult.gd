class_name InvestigationInformationResult
extends RefCounted

enum PayloadKind {
	NONE,
	TEXT,
	NUMBER,
	ROLE_PLAY_CLAIM,
	WEATHER_REPORT,
	NO_EVIL_FOUND,
	NO_MEDDLER_FOUND,
	BLOOD_HOUND_CLUE,
}

enum TruthMode {
	TRUTHFUL,
	LYING,
}

var suspect_id: int = 0
var true_role_id: StringName = &""
var displayed_role_id: StringName = &""
var behavior_role_id: StringName = &""
var truth_mode: int = TruthMode.TRUTHFUL
var payload_kind: int = PayloadKind.NONE
var text: String = ""
var numeric_value: int = -1
var in_play_role_id: StringName = &""
var not_in_play_role_id: StringName = &""
var claimed_in_play_is_true: bool = false
var claimed_not_in_play_is_true: bool = false
var weather_suspect_ids: PackedInt32Array = PackedInt32Array()
var weather_group_slots: PackedInt32Array = PackedInt32Array()
var weather_claim_complete: bool = false
var direction_key: StringName = &""
var role_identity_visible: bool = true
var text_information_visible: bool = true
var numeric_information_visible: bool = true
var is_obscured: bool = false


func has_public_information() -> bool:
	if payload_kind == PayloadKind.NUMBER:
		return numeric_information_visible and numeric_value >= 0
	if payload_kind == PayloadKind.WEATHER_REPORT:
		return text_information_visible and weather_claim_complete and weather_suspect_ids.size() == 3
	if payload_kind == PayloadKind.BLOOD_HOUND_CLUE:
		return text_information_visible and not text.is_empty() and not String(direction_key).is_empty()
	if payload_kind == PayloadKind.TEXT or payload_kind == PayloadKind.ROLE_PLAY_CLAIM or payload_kind == PayloadKind.NO_EVIL_FOUND or payload_kind == PayloadKind.NO_MEDDLER_FOUND:
		return text_information_visible and not text.is_empty()
	return false


func public_text() -> String:
	if payload_kind == PayloadKind.NUMBER and numeric_information_visible:
		return text
	if text_information_visible:
		return text
	return ""


func duplicate_result() -> InvestigationInformationResult:
	var result: InvestigationInformationResult = InvestigationInformationResult.new()
	result.suspect_id = suspect_id
	result.true_role_id = true_role_id
	result.displayed_role_id = displayed_role_id
	result.behavior_role_id = behavior_role_id
	result.truth_mode = truth_mode
	result.payload_kind = payload_kind
	result.text = text
	result.numeric_value = numeric_value
	result.in_play_role_id = in_play_role_id
	result.not_in_play_role_id = not_in_play_role_id
	result.claimed_in_play_is_true = claimed_in_play_is_true
	result.claimed_not_in_play_is_true = claimed_not_in_play_is_true
	result.weather_suspect_ids = weather_suspect_ids.duplicate()
	result.weather_group_slots = weather_group_slots.duplicate()
	result.weather_claim_complete = weather_claim_complete
	result.direction_key = direction_key
	result.role_identity_visible = role_identity_visible
	result.text_information_visible = text_information_visible
	result.numeric_information_visible = numeric_information_visible
	result.is_obscured = is_obscured
	return result
