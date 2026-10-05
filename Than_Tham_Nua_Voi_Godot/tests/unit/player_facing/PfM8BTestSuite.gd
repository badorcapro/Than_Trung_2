class_name PfM8BTestSuite
extends RefCounted

const MATCH_COMPLETION_SERVICE := preload(
	"res://scripts/domain/mvp/MatchCompletionService.gd"
)
const MATCH_STATE := preload("res://scripts/domain/mvp/MvpMatchState.gd")
const PLAYER_MATCH_STATE := preload("res://scripts/domain/mvp/PlayerMatchState.gd")
const MATCH_RULES := preload("res://scripts/domain/mvp/MatchRules.gd")
const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const SETUP_SESSION := preload(
	"res://scripts/application/player_facing/PlayerFacingSetupSession.gd"
)
const NEXT_CASE_SESSION := preload(
	"res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd"
)
const PLAYER_SCENE := preload("res://scenes/player_facing/PlayerFacingStart.tscn")

var _service: MATCH_COMPLETION_SERVICE = MATCH_COMPLETION_SERVICE.new()


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_add(rows, "PF-M8B victory cannot evaluate before full Round Settlement", _requires_committed_round())
	_add(rows, "PF-M8B Court Rank below target continues Match", _rank_below_target_continues())
	_add(rows, "PF-M8B Court Rank target completes Match", _rank_target_completes())
	_add(rows, "PF-M8B all settled players enter final standings", _all_players_are_ranked())
	_add(rows, "PF-M8B Fixed Rounds below limit continues", _fixed_rounds_below_limit())
	_add(rows, "PF-M8B Fixed Rounds at limit completes", _fixed_rounds_at_limit())
	_add(rows, "PF-M8B standings use rank then Merit with competition ties", _standings_and_ties())
	_add(rows, "PF-M8B completed Match snapshot round-trips", _snapshot_round_trip())
	_add(rows, "PF-M8B MATCH_COMPLETE blocks next Case and Round", _completed_match_blocks_continuation())
	_add(rows, "PF-M8B Match Results UI exposes standings actions", _match_results_ui_exists())
	_add(rows, "PF-M8B restored completed Match opens Results", _restore_opens_results())
	_add(rows, "PF-M8B Replay creates clean setup and Main Menu clears session", _replay_and_menu_reset())
	return rows


func _requires_committed_round() -> bool:
	var state: MATCH_STATE = _match_state()
	state.current_phase = MVP_ENUMS.Phase.EQUIPMENT_MANAGEMENT
	state.completed_round_count = 0
	state.players[0].merit_progress = 300.0
	var result: Dictionary = _service.apply_after_round_settlement(state)
	return (
		not bool(result.get("success", true))
		and StringName(result.get("code", &"")) == &"ROUND_SETTLEMENT_NOT_COMMITTED"
		and state.match_completion_state == &"IN_PROGRESS"
		and state.final_standings.is_empty()
	)


func _rank_below_target_continues() -> bool:
	var state: MATCH_STATE = _match_state()
	state.match_rules = MATCH_RULES.custom_reach_court_rank(&"RANK_3")
	state.completed_round_count = 1
	state.players[0].merit_progress = 125.0
	var result: Dictionary = _service.apply_after_round_settlement(state)
	return (
		bool(result.get("success", false))
		and not bool(result.get("match_complete", true))
		and state.current_phase == MVP_ENUMS.Phase.ROUND_START
		and state.match_completion_state == &"NEXT_CASE_REQUIRED"
	)


func _rank_target_completes() -> bool:
	var state: MATCH_STATE = _match_state()
	state.match_rules = MATCH_RULES.custom_reach_court_rank(&"RANK_8")
	state.completed_round_count = 1
	state.players[1].merit_progress = 15.0
	var result: Dictionary = _service.apply_after_round_settlement(state)
	return (
		bool(result.get("match_complete", false))
		and state.current_phase == MVP_ENUMS.Phase.MATCH_COMPLETE
		and state.match_completion_state == &"MATCH_COMPLETE"
	)


func _all_players_are_ranked() -> bool:
	var state: MATCH_STATE = _match_state()
	state.match_rules = MATCH_RULES.custom_reach_court_rank(&"RANK_8")
	state.completed_round_count = 1
	state.players[0].merit_progress = 16.0
	state.players[1].merit_progress = 35.0
	state.players[2].merit_progress = 15.0
	_service.apply_after_round_settlement(state)
	return (
		state.final_standings.size() == 3
		and state.final_standings[0].player_id == &"p2"
		and state.final_standings[1].player_id == &"p1"
		and state.final_standings[2].player_id == &"p3"
	)


func _fixed_rounds_below_limit() -> bool:
	var state: MATCH_STATE = _match_state()
	state.match_rules = MATCH_RULES.custom_fixed_rounds(3)
	state.completed_round_count = 2
	var result: Dictionary = _service.apply_after_round_settlement(state)
	return not bool(result.get("match_complete", true)) and state.final_standings.is_empty()


func _fixed_rounds_at_limit() -> bool:
	var state: MATCH_STATE = _match_state()
	state.match_rules = MATCH_RULES.custom_fixed_rounds(3)
	state.completed_round_count = 3
	var result: Dictionary = _service.apply_after_round_settlement(state)
	return bool(result.get("match_complete", false)) and state.final_standings.size() == 3


func _standings_and_ties() -> bool:
	var tied_state: MATCH_STATE = _match_state()
	tied_state.match_rules = MATCH_RULES.custom_fixed_rounds(1)
	tied_state.completed_round_count = 1
	tied_state.players[0].merit_progress = 35.0
	tied_state.players[1].merit_progress = 35.0
	tied_state.players[2].merit_progress = 20.0
	_service.apply_after_round_settlement(tied_state)
	var ordered_state: MATCH_STATE = _match_state()
	ordered_state.match_rules = MATCH_RULES.custom_fixed_rounds(1)
	ordered_state.completed_round_count = 1
	ordered_state.players[0].merit_progress = 40.0
	ordered_state.players[1].merit_progress = 35.0
	ordered_state.players[2].merit_progress = 60.0
	_service.apply_after_round_settlement(ordered_state)
	return (
		tied_state.final_standings[0].place == 1
		and tied_state.final_standings[1].place == 1
		and tied_state.final_standings[2].place == 3
		and tied_state.final_standings[0].court_rank_id == &"RANK_7"
		and tied_state.final_standings[2].court_rank_id == &"RANK_8"
		and ordered_state.final_standings[0].player_id == &"p3"
		and ordered_state.final_standings[1].player_id == &"p1"
		and ordered_state.final_standings[2].player_id == &"p2"
	)


func _snapshot_round_trip() -> bool:
	var state: MATCH_STATE = _completed_state()
	var restored: MATCH_STATE = MATCH_STATE.from_dict(state.to_dict())
	return (
		restored.semantically_equals(state)
		and restored.completed_round_count == 1
		and restored.match_completion_state == &"MATCH_COMPLETE"
		and restored.final_standings.size() == 3
		and restored.final_standings[0].player_id == state.final_standings[0].player_id
	)


func _completed_match_blocks_continuation() -> bool:
	var flow: NEXT_CASE_SESSION = NEXT_CASE_SESSION.new()
	flow.match_state = _completed_state()
	var composed: Dictionary = flow.prepare_default_next_case_options()
	var started: Dictionary = flow.start_next_round(&"vs_case_001")
	return (
		StringName(composed.get("code", &"")) == &"MATCH_ALREADY_COMPLETE"
		and not bool(started.get("success", true))
		and flow.match_state.current_phase == MVP_ENUMS.Phase.MATCH_COMPLETE
	)


func _match_results_ui_exists() -> bool:
	var root: Node = PLAYER_SCENE.instantiate()
	var passed: bool = (
		root.find_child("MatchResultsPanel", true, false) is Control
		and root.find_child("MatchResultsText", true, false) is RichTextLabel
		and root.find_child("Replay", true, false) is Button
		and root.find_child("MatchResultsMainMenu", true, false) is Button
	)
	root.free()
	return passed


func _restore_opens_results() -> bool:
	var setup: SETUP_SESSION = SETUP_SESSION.new()
	var restored: Dictionary = setup.restore_completed_match(_completed_state())
	var view: Dictionary = setup.match_results_presentation()
	return (
		bool(restored.get("success", false))
		and setup.phase == SETUP_SESSION.Phase.MATCH_RESULTS
		and int(view.get("completed_round_count", 0)) == 1
		and (view.get("standings", []) as Array).size() == 3
	)


func _replay_and_menu_reset() -> bool:
	var setup: SETUP_SESSION = SETUP_SESSION.new()
	setup.restore_completed_match(_completed_state())
	var old_state: MATCH_STATE = setup.match_state
	setup.begin_new_game()
	var replay_clean: bool = (
		setup.match_state != old_state
		and setup.phase == SETUP_SESSION.Phase.MATCH_MODE
		and setup.match_state.completed_round_count == 0
		and setup.match_state.final_standings.is_empty()
		and setup.match_state.match_completion_state == &"IN_PROGRESS"
	)
	setup.return_to_main_menu()
	return replay_clean and setup.phase == SETUP_SESSION.Phase.MAIN_MENU and setup.match_state == null


func _completed_state() -> MATCH_STATE:
	var state: MATCH_STATE = _match_state()
	state.match_rules = MATCH_RULES.custom_fixed_rounds(1)
	state.completed_round_count = 1
	state.players[0].merit_progress = 35.0
	state.players[1].merit_progress = 35.0
	state.players[2].merit_progress = 15.0
	_service.apply_after_round_settlement(state)
	return state


func _match_state() -> MATCH_STATE:
	var state: MATCH_STATE = MATCH_STATE.new()
	state.match_id = &"pf_m8b_match"
	state.character_selection_complete = true
	state.current_round_number = 2
	state.current_phase = MVP_ENUMS.Phase.ROUND_START
	state.match_completion_state = &"IN_PROGRESS"
	for index: int in range(3):
		var player: PLAYER_MATCH_STATE = PLAYER_MATCH_STATE.new()
		player.player_id = StringName("p%d" % (index + 1))
		player.display_name = "Người chơi %d" % (index + 1)
		player.character_id = StringName("character_%d" % (index + 1))
		player.seat_index = index
		state.players.append(player)
		state.player_order.append(player.player_id)
	return state


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "PF-M8B Match completion and final-results invariant",
	})
