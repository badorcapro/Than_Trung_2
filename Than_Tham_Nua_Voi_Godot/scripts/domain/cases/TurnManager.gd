class_name TurnManager
extends RefCounted

const CaseRoleModifierServiceScript := preload("res://scripts/domain/cases/CaseRoleModifierService.gd")

var turn_order: Array[PlayerCaseState] = []
var current_turn_index := 0
var turn_number := 1
var tie_break_seed := 0
var is_initialized := false


func initialize(players: Array[PlayerCaseState], explicit_tie_break_seed: int) -> bool:
	turn_order.clear()
	current_turn_index = 0
	turn_number = 1
	tie_break_seed = explicit_tie_break_seed
	is_initialized = false
	if players.is_empty():
		return false
	for player in players:
		if player == null or player.player_id == &"":
			return false
		turn_order.append(player)
	turn_order.sort_custom(_has_higher_reputation)
	_shuffle_tied_groups()
	is_initialized = true
	return true


func get_current_player() -> PlayerCaseState:
	if not is_initialized or turn_order.is_empty():
		return null
	return turn_order[current_turn_index]


func get_next_player() -> PlayerCaseState:
	if not is_initialized or turn_order.is_empty():
		return null
	return turn_order[(current_turn_index + 1) % turn_order.size()]


func advance_turn() -> PlayerCaseState:
	if not is_initialized or turn_order.is_empty():
		return null
	var next_index := current_turn_index
	var found_active := false
	for _step in range(turn_order.size()):
		next_index = (next_index + 1) % turn_order.size()
		if turn_order[next_index].is_active_in_investigation:
			found_active = true
			break
	if not found_active:
		return null
	current_turn_index = next_index
	turn_number += 1
	return get_current_player()


func active_player_count() -> int:
	var count := 0
	for player in turn_order:
		if player.is_active_in_investigation:
			count += 1
	return count


func get_turn_order_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for player in turn_order:
		ids.append(player.player_id)
	return ids


func _has_higher_reputation(a: PlayerCaseState, b: PlayerCaseState) -> bool:
	return CaseRoleModifierServiceScript.effective_turn_reputation(a) > CaseRoleModifierServiceScript.effective_turn_reputation(b)


func _shuffle_tied_groups() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = tie_break_seed
	var group_start := 0
	while group_start < turn_order.size():
		var group_end := group_start + 1
		while group_end < turn_order.size() and CaseRoleModifierServiceScript.effective_turn_reputation(turn_order[group_end]) == CaseRoleModifierServiceScript.effective_turn_reputation(turn_order[group_start]):
			group_end += 1
		for index in range(group_end - 1, group_start, -1):
			var swap_index := rng.randi_range(group_start, index)
			var held := turn_order[index]
			turn_order[index] = turn_order[swap_index]
			turn_order[swap_index] = held
		group_start = group_end
