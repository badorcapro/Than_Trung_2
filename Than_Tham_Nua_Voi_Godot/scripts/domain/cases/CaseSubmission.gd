class_name CaseSubmission
extends RefCounted

var player_id: StringName
var submitted_on_turn := 0
var selected_evil_ids := PackedInt32Array()
var underling_ids := PackedInt32Array()
var traitor_ids := PackedInt32Array()
var is_locked := false
var submission_phase: CaseEnums.SubmissionPhase = CaseEnums.SubmissionPhase.EARLY


func configure(source_player_id: StringName, source_turn: int, evil_ids: PackedInt32Array, source_underling_ids: PackedInt32Array, source_traitor_ids: PackedInt32Array, phase: CaseEnums.SubmissionPhase = CaseEnums.SubmissionPhase.EARLY) -> bool:
	if is_locked:
		return false
	player_id = source_player_id
	submitted_on_turn = source_turn
	selected_evil_ids = evil_ids.duplicate()
	underling_ids = source_underling_ids.duplicate()
	traitor_ids = source_traitor_ids.duplicate()
	submission_phase = phase
	return true


func lock() -> bool:
	if is_locked:
		return false
	selected_evil_ids = selected_evil_ids.duplicate()
	underling_ids = underling_ids.duplicate()
	traitor_ids = traitor_ids.duplicate()
	is_locked = true
	return true
