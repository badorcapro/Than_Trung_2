class_name MatchCompletionService
extends RefCounted

const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const MATCH_RULES := preload("res://scripts/domain/mvp/MatchRules.gd")
const MATCH_STATE := preload("res://scripts/domain/mvp/MvpMatchState.gd")
const FINAL_STANDING := preload("res://scripts/domain/mvp/MatchFinalStanding.gd")
const PLAYER_MATCH_STATE := preload("res://scripts/domain/mvp/PlayerMatchState.gd")
const COURT_RANK_SERVICE := preload(
	"res://scripts/domain/progression/CourtRankService.gd"
)

var _rank_service: COURT_RANK_SERVICE = COURT_RANK_SERVICE.new()


func apply_after_round_settlement(match_state: MATCH_STATE) -> Dictionary:
	if match_state == null or match_state.match_rules == null:
		return {"success": false, "code": &"MATCH_CONTEXT_INVALID"}
	if match_state.current_phase != MVP_ENUMS.Phase.ROUND_START:
		return {"success": false, "code": &"ROUND_SETTLEMENT_NOT_COMMITTED"}
	var standings: Array[FINAL_STANDING] = build_final_standings(match_state)
	var complete: bool = _victory_reached(match_state)
	if complete:
		match_state.final_standings = standings
		match_state.match_completion_state = &"MATCH_COMPLETE"
		match_state.current_phase = MVP_ENUMS.Phase.MATCH_COMPLETE
	else:
		match_state.final_standings.clear()
		match_state.match_completion_state = &"NEXT_CASE_REQUIRED"
	return {
		"success": true,
		"code": &"MATCH_COMPLETE" if complete else &"NEXT_CASE_REQUIRED",
		"status": &"MATCH_COMPLETE" if complete else &"NEXT_CASE_REQUIRED",
		"winner_player_id": standings[0].player_id if complete and not standings.is_empty() else &"",
		"match_complete": complete,
		"standings": standings,
	}


func build_final_standings(match_state: MATCH_STATE) -> Array[FINAL_STANDING]:
	var rows: Array[Dictionary] = []
	var order_by_player: Dictionary = {}
	for order_index: int in range(match_state.player_order.size()):
		order_by_player[match_state.player_order[order_index]] = order_index
	for player: PLAYER_MATCH_STATE in match_state.players:
		var rank: Dictionary = _rank_service.resolve(player.merit_progress)
		rows.append({
			"player": player,
			"rank_index": int(rank.get("rank_index", 0)),
			"rank_id": StringName(rank.get("rank_id", &"RANK_9")),
			"rank_name": String(rank.get("rank_name", "Cửu phẩm")),
			"order_index": int(order_by_player.get(player.player_id, player.seat_index)),
		})
	rows.sort_custom(_standing_precedes)
	var result: Array[FINAL_STANDING] = []
	var previous_rank_index: int = -1
	var previous_merit: float = -1.0
	var previous_place: int = 0
	for index: int in range(rows.size()):
		var row: Dictionary = rows[index]
		var player: PLAYER_MATCH_STATE = row.get("player") as PLAYER_MATCH_STATE
		var rank_index: int = int(row.get("rank_index", 0))
		var place: int = index + 1
		if index > 0 and rank_index == previous_rank_index and player.merit_progress == previous_merit:
			place = previous_place
		var standing: FINAL_STANDING = FINAL_STANDING.new()
		standing.player_id = player.player_id
		standing.display_name = player.display_name
		standing.court_rank_id = StringName(row.get("rank_id", &"RANK_9"))
		standing.court_rank_name = String(row.get("rank_name", "Cửu phẩm"))
		standing.merit = player.merit_progress
		standing.place = place
		result.append(standing)
		previous_rank_index = rank_index
		previous_merit = player.merit_progress
		previous_place = place
	return result


func _victory_reached(match_state: MATCH_STATE) -> bool:
	var rules: MATCH_RULES = match_state.match_rules
	if rules.victory_type == MATCH_RULES.VictoryType.FIXED_ROUNDS:
		return match_state.completed_round_count >= rules.round_limit
	var target_index: int = COURT_RANK_SERVICE.rank_index(rules.target_court_rank)
	if target_index < 0:
		return false
	for player: PLAYER_MATCH_STATE in match_state.players:
		var rank: Dictionary = _rank_service.resolve(player.merit_progress)
		if int(rank.get("rank_index", 0)) >= target_index:
			return true
	return false


func _standing_precedes(left: Dictionary, right: Dictionary) -> bool:
	var left_rank: int = int(left.get("rank_index", 0))
	var right_rank: int = int(right.get("rank_index", 0))
	if left_rank != right_rank:
		return left_rank > right_rank
	var left_player: PLAYER_MATCH_STATE = left.get("player") as PLAYER_MATCH_STATE
	var right_player: PLAYER_MATCH_STATE = right.get("player") as PLAYER_MATCH_STATE
	if left_player.merit_progress != right_player.merit_progress:
		return left_player.merit_progress > right_player.merit_progress
	return int(left.get("order_index", 0)) < int(right.get("order_index", 0))
