class_name PfM8ATestSuite
extends RefCounted

const SETUP_SESSION := preload(
	"res://scripts/application/player_facing/PlayerFacingSetupSession.gd"
)
const MATCH_RULES := preload("res://scripts/domain/mvp/MatchRules.gd")
const MATCH_STATE := preload("res://scripts/domain/mvp/MvpMatchState.gd")
const COURT_RANK_SERVICE := preload(
	"res://scripts/domain/progression/CourtRankService.gd"
)
const PLAYER_SCENE := preload("res://scenes/player_facing/PlayerFacingStart.tscn")


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_add(rows, "PF-M8A Classic resolves to Nhất phẩm preset", _classic_preset())
	_add(rows, "PF-M8A Custom Court Rank persists", _custom_rank_persists())
	_add(rows, "PF-M8A Custom Fixed Rounds persists", _custom_rounds_persist())
	_add(rows, "PF-M8A invalid hybrid rules are rejected", _invalid_rules_rejected())
	_add(rows, "PF-M8A setup back navigation preserves rules", _back_navigation_preserves_rules())
	_add(rows, "PF-M8A Court Rank selector reuses progression authority", _rank_options_are_authoritative())
	_add(rows, "PF-M8A player-facing Match Rules controls exist", _scene_controls_exist())
	_add(rows, "PF-M8A configured rules reach downstream setup", _downstream_setup_preserves_rules())
	return rows


func _classic_preset() -> bool:
	var setup: SETUP_SESSION = SETUP_SESSION.new()
	setup.begin_new_game()
	var selected: Dictionary = setup.choose_match_mode(MATCH_RULES.Mode.CLASSIC)
	var rules: MATCH_RULES = setup.get_match_rules()
	return (
		bool(selected.get("success", false))
		and rules != null
		and rules.is_valid()
		and rules.mode == MATCH_RULES.Mode.CLASSIC
		and rules.victory_type == MATCH_RULES.VictoryType.REACH_COURT_RANK
		and rules.target_court_rank == &"RANK_1"
		and rules.round_limit == 0
	)


func _custom_rank_persists() -> bool:
	var setup: SETUP_SESSION = SETUP_SESSION.new()
	setup.begin_new_game()
	setup.choose_match_mode(MATCH_RULES.Mode.CUSTOM)
	setup.choose_target_court_rank(&"RANK_8")
	setup.confirm_match_rules()
	var restored: MATCH_STATE = MATCH_STATE.from_dict(setup.match_state.to_dict())
	return (
		restored.match_rules.mode == MATCH_RULES.Mode.CUSTOM
		and restored.match_rules.victory_type == MATCH_RULES.VictoryType.REACH_COURT_RANK
		and restored.match_rules.target_court_rank == &"RANK_8"
		and restored.match_rules.round_limit == 0
	)


func _custom_rounds_persist() -> bool:
	var setup: SETUP_SESSION = SETUP_SESSION.new()
	setup.begin_new_game()
	setup.choose_match_mode(MATCH_RULES.Mode.CUSTOM)
	setup.choose_victory_type(MATCH_RULES.VictoryType.FIXED_ROUNDS)
	setup.choose_round_limit(5)
	setup.confirm_match_rules()
	var restored: MATCH_STATE = MATCH_STATE.from_dict(setup.match_state.to_dict())
	return (
		restored.match_rules.mode == MATCH_RULES.Mode.CUSTOM
		and restored.match_rules.victory_type == MATCH_RULES.VictoryType.FIXED_ROUNDS
		and restored.match_rules.target_court_rank.is_empty()
		and restored.match_rules.round_limit == 5
	)


func _invalid_rules_rejected() -> bool:
	var bad_classic: MATCH_RULES = MATCH_RULES.classic()
	bad_classic.round_limit = 1
	var bad_rank: MATCH_RULES = MATCH_RULES.custom_reach_court_rank(&"NOT_A_RANK")
	var bad_rounds: MATCH_RULES = MATCH_RULES.custom_fixed_rounds(2)
	var hybrid: MATCH_RULES = MATCH_RULES.custom_fixed_rounds(3)
	hybrid.target_court_rank = &"RANK_9"
	return (
		not bad_classic.is_valid()
		and not bad_rank.is_valid()
		and not bad_rounds.is_valid()
		and not hybrid.is_valid()
	)


func _back_navigation_preserves_rules() -> bool:
	var setup: SETUP_SESSION = SETUP_SESSION.new()
	setup.begin_new_game()
	setup.choose_match_mode(MATCH_RULES.Mode.CUSTOM)
	setup.choose_victory_type(MATCH_RULES.VictoryType.FIXED_ROUNDS)
	setup.choose_round_limit(10)
	setup.confirm_match_rules()
	var backed: Dictionary = setup.back_to_match_rules()
	var rules: MATCH_RULES = setup.get_match_rules()
	return (
		bool(backed.get("success", false))
		and setup.phase == SETUP_SESSION.Phase.MATCH_RULES
		and rules.mode == MATCH_RULES.Mode.CUSTOM
		and rules.victory_type == MATCH_RULES.VictoryType.FIXED_ROUNDS
		and rules.round_limit == 10
	)


func _rank_options_are_authoritative() -> bool:
	var setup: SETUP_SESSION = SETUP_SESSION.new()
	var setup_options: Array[Dictionary] = setup.court_rank_options()
	var authority_options: Array[Dictionary] = COURT_RANK_SERVICE.rank_options()
	return (
		setup_options == authority_options
		and setup_options.size() == 9
		and StringName(setup_options[0].get("id", &"")) == &"RANK_9"
		and StringName(setup_options[-1].get("id", &"")) == &"RANK_1"
		and String(setup_options[0].get("name", "")) == "Cửu phẩm"
		and String(setup_options[-1].get("name", "")) == "Nhất phẩm"
	)


func _scene_controls_exist() -> bool:
	var root: Node = PLAYER_SCENE.instantiate()
	var passed: bool = (
		root.find_child("MatchMode", true, false) != null
		and root.find_child("MatchRulesPanel", true, false) != null
		and root.find_child("VictoryTypeSelector", true, false) is OptionButton
		and root.find_child("TargetRankSelector", true, false) is OptionButton
		and root.find_child("RoundLimitSelector", true, false) is OptionButton
		and root.find_child("RulesContinue", true, false) is Button
		and root.find_child("RulesBack", true, false) is Button
	)
	root.free()
	return passed


func _downstream_setup_preserves_rules() -> bool:
	var setup: SETUP_SESSION = SETUP_SESSION.new()
	setup.begin_new_game()
	setup.choose_match_mode(MATCH_RULES.Mode.CUSTOM)
	setup.choose_victory_type(MATCH_RULES.VictoryType.FIXED_ROUNDS)
	setup.choose_round_limit(1)
	setup.confirm_match_rules()
	if not bool(setup.choose_player_count(3).get("success", false)):
		return false
	for seat_index: int in range(3):
		setup.select_character(setup.characters[seat_index].character_id)
		setup.lock_current_character()
		if setup.phase == SETUP_SESSION.Phase.PASS_DEVICE:
			setup.continue_after_pass_device()
	var confirmed: Dictionary = setup.confirm_lineup()
	var rules: MATCH_RULES = setup.get_match_rules()
	return (
		bool(confirmed.get("success", false))
		and setup.phase == SETUP_SESSION.Phase.CASE_SELECTION_READY
		and rules.mode == MATCH_RULES.Mode.CUSTOM
		and rules.victory_type == MATCH_RULES.VictoryType.FIXED_ROUNDS
		and rules.round_limit == 1
		and setup.match_state.match_completion_state == &"IN_PROGRESS"
	)


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "PF-M8A Match Setup and victory-rule invariant",
	})
