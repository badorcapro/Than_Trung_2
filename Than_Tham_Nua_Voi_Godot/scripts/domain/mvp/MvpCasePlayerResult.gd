class_name MvpCasePlayerResult
extends RefCounted

var player_id: StringName
var submitted := false
var submission_context: StringName = &"NONE"
var status: StringName = &"CHUA_TRINH_AN"
var main_answer_correct := false
var underling_classification_correct := false
var traitor_classification_correct := false
var merit_delta := 0.0
var reputation_delta := 0
var orb_delta := 0
var base_ticket_delta := 0
var on_solve_payload: Dictionary = {}


func total_ticket_delta() -> int:
	return base_ticket_delta


func to_dict() -> Dictionary:
	return {
		"player_id": String(player_id),
		"submitted": submitted,
		"submission_context": String(submission_context),
		"status": String(status),
		"main_answer_correct": main_answer_correct,
		"underling_classification_correct": underling_classification_correct,
		"traitor_classification_correct": traitor_classification_correct,
		"merit_delta": merit_delta,
		"reputation_delta": reputation_delta,
		"orb_delta": orb_delta,
		"base_ticket_delta": base_ticket_delta,
		"total_ticket_delta": total_ticket_delta(),
		"on_solve_payload": on_solve_payload.duplicate(true),
	}


static func from_dict(data: Dictionary) -> MvpCasePlayerResult:
	var result := MvpCasePlayerResult.new()
	result.player_id = StringName(data.get("player_id", ""))
	result.submitted = bool(data.get("submitted", false))
	result.submission_context = StringName(data.get("submission_context", "NONE"))
	result.status = StringName(data.get("status", "CHUA_TRINH_AN"))
	result.main_answer_correct = bool(data.get("main_answer_correct", false))
	result.underling_classification_correct = bool(
		data.get("underling_classification_correct", false)
	)
	result.traitor_classification_correct = bool(
		data.get("traitor_classification_correct", false)
	)
	result.merit_delta = float(data.get("merit_delta", 0.0))
	result.reputation_delta = int(data.get("reputation_delta", 0))
	result.orb_delta = int(data.get("orb_delta", 0))
	result.base_ticket_delta = int(data.get("base_ticket_delta", 0))
	var payload_value: Variant = data.get("on_solve_payload", {})
	if payload_value is Dictionary:
		result.on_solve_payload = payload_value.duplicate(true)
	return result
