class_name PlayerCaseResolution
extends RefCounted

var player_id: StringName
var display_name := ""
var outcome: CaseEnums.PlayerResolutionOutcome
var main_answer_correct := false
var underling_classification_correct := false
var traitor_classification_correct := false
var submission_phase: CaseEnums.SubmissionPhase = CaseEnums.SubmissionPhase.EARLY
var reward := PlayerCaseRewardDelta.new()
