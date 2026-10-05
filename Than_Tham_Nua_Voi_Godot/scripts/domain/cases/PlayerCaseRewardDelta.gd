class_name PlayerCaseRewardDelta
extends RefCounted

var merit_before := 0.0
var merit_delta := 0.0
var merit_after := 0.0
var reputation_before := 0
var reputation_delta := 0
var reputation_after := 0
var orb_before := 0
var orb_delta := 0
var orb_after := 0
var tickets_before := 0
var base_ticket_delta := 0
var tickets_after := 0

func total_ticket_delta() -> int:
	return base_ticket_delta
