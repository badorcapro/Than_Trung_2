class_name CharacterSelectionSession
extends RefCounted

enum Phase { PLAYER_COUNT, SELECTING, PASS_DEVICE, SUMMARY, READY_FOR_LOOT_M3 }

var player_count: int = 0
var current_seat_index: int = 0
var phase: Phase = Phase.PLAYER_COUNT
var selected_character_ids: Array[StringName] = []
var locked_seats: Array[bool] = []
var committed_players: Array[PlayerPhaseState] = []
var allow_duplicate_characters: bool = true
var duplicate_policy_test_only_not_canon_locked: bool = true
var commit_count: int = 0


func is_complete() -> bool:
	if player_count < 1 or selected_character_ids.size() != player_count or locked_seats.size() != player_count:
		return false
	for seat_index: int in range(player_count):
		if selected_character_ids[seat_index].is_empty() or not locked_seats[seat_index]:
			return false
	return true


func clear_committed_snapshot() -> void:
	committed_players.clear()
	commit_count = 0
	if is_complete(): phase = Phase.SUMMARY

