class_name PlayerFacingSetupSession
extends RefCounted

const CHARACTER_SELECTION_SESSION := preload(
	"res://scripts/domain/characters/CharacterSelectionSession.gd"
)
const CHARACTER_SELECTION_SERVICE := preload(
	"res://scripts/application/loot/CharacterSelectionService.gd"
)
const CHARACTER_DEFINITION := preload(
	"res://scripts/domain/characters/CharacterDefinition.gd"
)
const PRODUCTION_CHARACTER_REPOSITORY := preload(
	"res://scripts/application/characters/ProductionCharacterRepository.gd"
)
const PRODUCTION_HOUSE_REPOSITORY := preload(
	"res://scripts/application/houses/ProductionHouseRepository.gd"
)
const PRODUCTION_CHARACTER_ROSTER_VALIDATOR := preload(
	"res://scripts/domain/characters/ProductionCharacterRosterValidator.gd"
)
const MVP_MATCH_STATE := preload("res://scripts/domain/mvp/MvpMatchState.gd")
const PLAYER_MATCH_STATE := preload("res://scripts/domain/mvp/PlayerMatchState.gd")
const MVP_MATCH_VALIDATOR := preload(
	"res://scripts/domain/mvp/MvpMatchStateValidator.gd"
)
const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const CASE_DEFINITION := preload("res://scripts/domain/cases/CaseDefinition.gd")
const PLAYER_PHASE_STATE := preload(
	"res://scripts/domain/characters/PlayerPhaseState.gd"
)
const LOOT_VALIDATION_REPORT := preload(
	"res://scripts/domain/loot/LootValidationReport.gd"
)
const MVP_VALIDATION_REPORT := preload(
	"res://scripts/domain/mvp/MvpValidationReport.gd"
)
const FIXTURE_REPOSITORY := preload(
	"res://scripts/domain/cases/FixtureRepository.gd"
)
const COURT_RANK_SERVICE := preload(
	"res://scripts/domain/progression/CourtRankService.gd"
)
const MATCH_RULES := preload("res://scripts/domain/mvp/MatchRules.gd")
const MATCH_FINAL_STANDING := preload("res://scripts/domain/mvp/MatchFinalStanding.gd")

enum Phase {
	MAIN_MENU,
	MATCH_MODE,
	MATCH_RULES,
	PLAYER_COUNT,
	CHARACTER_SELECTION,
	PASS_DEVICE,
	LINEUP_CONFIRMATION,
	CASE_SELECTION_READY,
	CASE_ACTIVE,
	CASE_RESULTS,
	LOOT_READY,
	LOOT_ACTIVE,
	LOOT_END_CONFIRMATION,
	EQUIPMENT_MANAGEMENT,
	ROUND_SUMMARY_READY,
	ROUND_SUMMARY,
	NEXT_CASE_SELECTION,
	SETTINGS,
	MATCH_RESULTS,
}

const SUPPORTED_PLAYER_COUNT := 3
const MATCH_ID := &"player_facing_local_match"

var phase: int = Phase.MAIN_MENU
var characters: Array[CHARACTER_DEFINITION] = []
var selection_session: CHARACTER_SELECTION_SESSION = CHARACTER_SELECTION_SESSION.new()
var match_state: MVP_MATCH_STATE
var available_case: CASE_DEFINITION
var case_gameplay_started := false
var next_case_gameplay_started := false

var _selection_service: CHARACTER_SELECTION_SERVICE = CHARACTER_SELECTION_SERVICE.new()
var _court_rank_service: COURT_RANK_SERVICE = COURT_RANK_SERVICE.new()
var _selection_published := false


func _init() -> void:
	characters = PRODUCTION_CHARACTER_REPOSITORY.load_all()


func begin_new_game() -> Dictionary:
	selection_session = CHARACTER_SELECTION_SESSION.new()
	match_state = MVP_MATCH_STATE.new()
	match_state.match_id = MATCH_ID
	var match_rng := RandomNumberGenerator.new()
	match_rng.randomize()
	match_state.case_generation_seed = match_rng.randi_range(1, 2147483646)
	match_state.current_phase = MVP_ENUMS.Phase.MATCH_SETUP
	match_state.current_round_number = 0
	match_state.character_selection_complete = false
	match_state.match_completion_state = &"IN_PROGRESS"
	match_state.match_rules = MATCH_RULES.classic()
	_selection_published = false
	available_case = null
	case_gameplay_started = false
	next_case_gameplay_started = false
	phase = Phase.MATCH_MODE
	return _success(&"MATCH_MODE_READY")


func choose_match_mode(mode: int) -> Dictionary:
	if phase != Phase.MATCH_MODE:
		return _failure(&"MATCH_MODE_PHASE_REQUIRED")
	if mode == MATCH_RULES.Mode.CLASSIC:
		match_state.match_rules = MATCH_RULES.classic()
	elif mode == MATCH_RULES.Mode.CUSTOM:
		if match_state.match_rules == null or match_state.match_rules.mode != MATCH_RULES.Mode.CUSTOM:
			var rank_options: Array[Dictionary] = COURT_RANK_SERVICE.rank_options()
			var default_rank: StringName = &"RANK_9"
			if not rank_options.is_empty():
				default_rank = StringName(rank_options[0].get("id", &"RANK_9"))
			match_state.match_rules = MATCH_RULES.custom_reach_court_rank(default_rank)
	else:
		return _failure(&"MATCH_MODE_INVALID")
	phase = Phase.MATCH_RULES
	return _success(&"MATCH_RULES_READY")


func choose_victory_type(victory_type: int) -> Dictionary:
	if phase != Phase.MATCH_RULES or match_state.match_rules == null:
		return _failure(&"MATCH_RULES_PHASE_REQUIRED")
	if match_state.match_rules.mode != MATCH_RULES.Mode.CUSTOM:
		return _failure(&"CLASSIC_RULES_LOCKED")
	if victory_type == MATCH_RULES.VictoryType.REACH_COURT_RANK:
		var rank_id: StringName = match_state.match_rules.target_court_rank
		if not COURT_RANK_SERVICE.is_valid_rank_id(rank_id):
			rank_id = &"RANK_9"
		match_state.match_rules = MATCH_RULES.custom_reach_court_rank(rank_id)
	elif victory_type == MATCH_RULES.VictoryType.FIXED_ROUNDS:
		var rounds: int = match_state.match_rules.round_limit
		if rounds not in MATCH_RULES.ROUND_LIMIT_OPTIONS:
			rounds = MATCH_RULES.ROUND_LIMIT_OPTIONS[0]
		match_state.match_rules = MATCH_RULES.custom_fixed_rounds(rounds)
	else:
		return _failure(&"VICTORY_TYPE_INVALID")
	return _success(&"VICTORY_TYPE_SELECTED")


func choose_target_court_rank(rank_id: StringName) -> Dictionary:
	if not _can_edit_custom_rules(MATCH_RULES.VictoryType.REACH_COURT_RANK):
		return _failure(&"CUSTOM_RANK_RULES_REQUIRED")
	if not COURT_RANK_SERVICE.is_valid_rank_id(rank_id):
		return _failure(&"COURT_RANK_INVALID")
	match_state.match_rules = MATCH_RULES.custom_reach_court_rank(rank_id)
	return _success(&"COURT_RANK_SELECTED")


func choose_round_limit(round_limit: int) -> Dictionary:
	if not _can_edit_custom_rules(MATCH_RULES.VictoryType.FIXED_ROUNDS):
		return _failure(&"CUSTOM_ROUND_RULES_REQUIRED")
	if round_limit not in MATCH_RULES.ROUND_LIMIT_OPTIONS:
		return _failure(&"ROUND_LIMIT_INVALID")
	match_state.match_rules = MATCH_RULES.custom_fixed_rounds(round_limit)
	return _success(&"ROUND_LIMIT_SELECTED")


func confirm_match_rules() -> Dictionary:
	if phase != Phase.MATCH_RULES or match_state.match_rules == null:
		return _failure(&"MATCH_RULES_PHASE_REQUIRED")
	var rules_error: StringName = match_state.match_rules.validation_error()
	if not rules_error.is_empty():
		return _failure(rules_error)
	phase = Phase.PLAYER_COUNT
	return _success(&"PLAYER_COUNT_READY")


func back_to_match_mode() -> Dictionary:
	if phase != Phase.MATCH_RULES:
		return _failure(&"MATCH_RULES_PHASE_REQUIRED")
	phase = Phase.MATCH_MODE
	return _success(&"MATCH_MODE_READY")


func back_to_match_rules() -> Dictionary:
	if phase != Phase.PLAYER_COUNT:
		return _failure(&"PLAYER_COUNT_PHASE_REQUIRED")
	phase = Phase.MATCH_RULES
	return _success(&"MATCH_RULES_READY")


func choose_player_count(player_count: int) -> Dictionary:
	if phase == Phase.MATCH_MODE:
		var mode_result: Dictionary = choose_match_mode(MATCH_RULES.Mode.CLASSIC)
		if not bool(mode_result.get("success", false)):
			return mode_result
		var rules_result: Dictionary = confirm_match_rules()
		if not bool(rules_result.get("success", false)):
			return rules_result
	if phase != Phase.PLAYER_COUNT:
		return _failure(&"PLAYER_COUNT_PHASE_REQUIRED")
	if player_count != SUPPORTED_PLAYER_COUNT:
		return _failure(&"PLAYER_COUNT_NOT_SUPPORTED")
	var roster_report: LOOT_VALIDATION_REPORT = (
		PRODUCTION_CHARACTER_ROSTER_VALIDATOR.new().validate(characters)
	)
	if not roster_report.is_valid:
		return _report_failure(roster_report)
	var report: LOOT_VALIDATION_REPORT = _selection_service.configure_player_count(
		selection_session,
		SUPPORTED_PLAYER_COUNT,
		false
	)
	if not report.is_valid:
		return _report_failure(report)
	match_state.current_phase = MVP_ENUMS.Phase.CHARACTER_SELECTION
	phase = Phase.CHARACTER_SELECTION
	return _success(&"CHARACTER_SELECTION_READY")


func select_character(character_id: StringName) -> Dictionary:
	if phase != Phase.CHARACTER_SELECTION:
		return _failure(&"CHARACTER_SELECTION_PHASE_REQUIRED")
	var report: LOOT_VALIDATION_REPORT = _selection_service.select_character(
		selection_session, character_id, characters
	)
	if not report.is_valid:
		return _report_failure(report)
	return _success(&"CHARACTER_SELECTED")


func lock_current_character() -> Dictionary:
	if phase != Phase.CHARACTER_SELECTION:
		return _failure(&"CHARACTER_SELECTION_PHASE_REQUIRED")
	var report: LOOT_VALIDATION_REPORT = _selection_service.lock_current_selection(
		selection_session, characters
	)
	if not report.is_valid:
		return _report_failure(report)
	if selection_session.phase == CHARACTER_SELECTION_SESSION.Phase.PASS_DEVICE:
		phase = Phase.PASS_DEVICE
	elif selection_session.phase == CHARACTER_SELECTION_SESSION.Phase.SUMMARY:
		phase = Phase.LINEUP_CONFIRMATION
	return _success(&"CHARACTER_LOCKED")


func continue_after_pass_device() -> Dictionary:
	if phase != Phase.PASS_DEVICE:
		return _failure(&"PASS_DEVICE_PHASE_REQUIRED")
	var report: LOOT_VALIDATION_REPORT = _selection_service.continue_after_pass_device(
		selection_session
	)
	if not report.is_valid:
		return _report_failure(report)
	phase = Phase.CHARACTER_SELECTION
	return _success(&"NEXT_PLAYER_READY")


func edit_last_selection() -> Dictionary:
	if phase != Phase.LINEUP_CONFIRMATION or _selection_published:
		return _failure(&"LINEUP_EDIT_UNAVAILABLE")
	var seat_index: int = maxi(0, selection_session.player_count - 1)
	var report: LOOT_VALIDATION_REPORT = _selection_service.edit_seat(
		selection_session, seat_index
	)
	if not report.is_valid:
		return _report_failure(report)
	phase = Phase.CHARACTER_SELECTION
	return _success(&"LINEUP_EDIT_READY")


func confirm_lineup() -> Dictionary:
	if _selection_published or selection_session.commit_count > 0:
		return _failure(&"CHARACTER_SELECTION_ALREADY_COMMITTED", true)
	if phase != Phase.LINEUP_CONFIRMATION:
		return _failure(&"LINEUP_CONFIRMATION_REQUIRED")
	var report: LOOT_VALIDATION_REPORT = _selection_service.finalize_selection(
		selection_session, characters
	)
	if not report.is_valid:
		return _report_failure(report)
	var candidate: MVP_MATCH_STATE = MVP_MATCH_STATE.from_dict(match_state.to_dict())
	candidate.players.clear()
	candidate.player_order.clear()
	for source: PLAYER_PHASE_STATE in selection_session.committed_players:
		var player: PLAYER_MATCH_STATE = PLAYER_MATCH_STATE.from_dict(source.to_dict())
		player.display_name = "Người chơi %d" % (source.seat_index + 1)
		candidate.players.append(player)
		candidate.player_order.append(player.player_id)
	candidate.character_selection_complete = true
	candidate.current_phase = MVP_ENUMS.Phase.ROUND_START
	candidate.current_round_number = 0
	var match_report: MVP_VALIDATION_REPORT = MVP_MATCH_VALIDATOR.new().validate(candidate)
	if not match_report.passed():
		return _failure(&"MATCH_SETUP_INVALID")
	available_case = FIXTURE_REPOSITORY.load_case()
	if available_case == null:
		return _failure(&"CASE_PRESENTATION_UNAVAILABLE")
	match_state = candidate
	_selection_published = true
	phase = Phase.CASE_SELECTION_READY
	return _success(&"CASE_SELECTION_READY")


func show_settings() -> void:
	if phase == Phase.MAIN_MENU:
		phase = Phase.SETTINGS


func return_to_main_menu() -> void:
	phase = Phase.MAIN_MENU
	match_state = null
	available_case = null
	case_gameplay_started = false
	next_case_gameplay_started = false
	_selection_published = false


func get_match_rules() -> MATCH_RULES:
	return match_state.match_rules if match_state != null else null


func court_rank_options() -> Array[Dictionary]:
	return COURT_RANK_SERVICE.rank_options()


func round_limit_options() -> Array[int]:
	var result: Array[int] = []
	for value: int in MATCH_RULES.ROUND_LIMIT_OPTIONS:
		result.append(value)
	return result


func match_rules_presentation() -> Dictionary:
	var rules: MATCH_RULES = get_match_rules()
	if rules == null:
		return {}
	return {
		"mode": rules.mode,
		"mode_name": "Cổ điển" if rules.mode == MATCH_RULES.Mode.CLASSIC else "Tùy chỉnh",
		"victory_type": rules.victory_type,
		"victory_name": (
			"Đạt Công Danh"
			if rules.victory_type == MATCH_RULES.VictoryType.REACH_COURT_RANK
			else "Số Round cố định"
		),
		"target_name": (
			COURT_RANK_SERVICE.rank_name(rules.target_court_rank)
			if rules.victory_type == MATCH_RULES.VictoryType.REACH_COURT_RANK
			else "%d Round" % rules.round_limit
		),
	}


func selected_character_for_seat(seat_index: int) -> CHARACTER_DEFINITION:
	if seat_index < 0 or seat_index >= selection_session.selected_character_ids.size():
		return null
	return find_character(selection_session.selected_character_ids[seat_index])


func find_character(character_id: StringName) -> CHARACTER_DEFINITION:
	for character: CHARACTER_DEFINITION in characters:
		if character.character_id == character_id:
			return character
	return null


func character_presentation(character: CHARACTER_DEFINITION) -> Dictionary:
	if character == null:
		return {}
	var house: HouseDefinition = PRODUCTION_HOUSE_REPOSITORY.find(
		character.origin_house_id
	)
	var has_authored_skill: bool = (
		not character.passive_skill_id.is_empty()
		and not String(character.passive_skill_id).begins_with("test_")
	)
	return {
		"name": character.display_name,
		"house": house.display_name if house != null else "",
		"speed": character.base_speed,
		"stamina": character.base_stamina,
		"bag": character.base_bag_level,
		"skill": (
			String(character.passive_skill_id)
			if has_authored_skill
			else "Kỹ năng đang được hoàn thiện"
		),
	}


func case_presentation() -> Dictionary:
	if available_case == null:
		return {}
	return {
		"name": "Kỳ Án Hoàng Cung",
		"description": "Một bí ẩn trong hoàng cung đang chờ các thần thám điều tra.",
		"merit": available_case.merit_pool,
	}


func selection_commit_count() -> int:
	return selection_session.commit_count


func selection_published() -> bool:
	return _selection_published


func mark_case_started() -> Dictionary:
	if phase == Phase.CASE_ACTIVE:
		return _failure(&"CASE_SESSION_ALREADY_ACTIVE", true)
	if phase != Phase.CASE_SELECTION_READY or case_gameplay_started:
		return _failure(&"CASE_SELECTION_NOT_READY")
	case_gameplay_started = true
	phase = Phase.CASE_ACTIVE
	return _success(&"CASE_ACTIVE")


func mark_first_case_selection_required() -> Dictionary:
	if phase == Phase.NEXT_CASE_SELECTION:
		return _failure(&"NEXT_CASE_ALREADY_PRESENTED", true)
	if phase != Phase.CASE_SELECTION_READY:
		return _failure(&"CASE_SELECTION_NOT_READY")
	next_case_gameplay_started = false
	phase = Phase.NEXT_CASE_SELECTION
	return _success(&"NEXT_CASE_SELECTION")


func mark_case_results_ready() -> Dictionary:
	if phase != Phase.CASE_ACTIVE:
		return _failure(&"CASE_RESULTS_NOT_READY")
	phase = Phase.CASE_RESULTS
	return _success(&"CASE_RESULTS_READY")


func continue_to_loot_ready() -> Dictionary:
	if phase == Phase.LOOT_READY:
		return _failure(&"LOOT_READY_ALREADY_REACHED", true)
	if phase != Phase.CASE_RESULTS:
		return _failure(&"CASE_RESULTS_REQUIRED")
	phase = Phase.LOOT_READY
	return _success(&"LOOT_READY")


func mark_loot_started() -> Dictionary:
	if phase == Phase.LOOT_ACTIVE:
		return _failure(&"LOOT_ALREADY_ACTIVE", true)
	if phase != Phase.LOOT_READY:
		return _failure(&"LOOT_READY_REQUIRED")
	phase = Phase.LOOT_ACTIVE
	return _success(&"LOOT_ACTIVE")


func mark_loot_confirmation() -> Dictionary:
	if phase != Phase.LOOT_ACTIVE:
		return _failure(&"LOOT_ACTIVE_REQUIRED")
	phase = Phase.LOOT_END_CONFIRMATION
	return _success(&"LOOT_END_CONFIRMATION")


func mark_equipment_management() -> Dictionary:
	if phase != Phase.LOOT_END_CONFIRMATION:
		return _failure(&"LOOT_CONFIRMATION_REQUIRED")
	phase = Phase.EQUIPMENT_MANAGEMENT
	return _success(&"EQUIPMENT_MANAGEMENT")


func mark_round_summary_ready() -> Dictionary:
	if phase == Phase.ROUND_SUMMARY_READY:
		return _failure(&"ROUND_SUMMARY_ALREADY_READY", true)
	if phase != Phase.EQUIPMENT_MANAGEMENT:
		return _failure(&"MANAGEMENT_REQUIRED")
	phase = Phase.ROUND_SUMMARY_READY
	return _success(&"ROUND_SUMMARY_READY")


func open_round_summary() -> Dictionary:
	if phase == Phase.ROUND_SUMMARY:
		return _failure(&"ROUND_SUMMARY_ALREADY_OPEN", true)
	if phase != Phase.ROUND_SUMMARY_READY:
		return _failure(&"ROUND_SUMMARY_NOT_READY")
	phase = Phase.ROUND_SUMMARY
	return _success(&"ROUND_SUMMARY")


func mark_next_case_required() -> Dictionary:
	if phase == Phase.NEXT_CASE_SELECTION:
		return _failure(&"NEXT_CASE_ALREADY_PRESENTED", true)
	if phase != Phase.ROUND_SUMMARY:
		return _failure(&"ROUND_SUMMARY_REQUIRED")
	next_case_gameplay_started = false
	phase = Phase.NEXT_CASE_SELECTION
	return _success(&"NEXT_CASE_SELECTION")


func mark_match_complete(source_match: MVP_MATCH_STATE) -> Dictionary:
	if phase != Phase.ROUND_SUMMARY:
		return _failure(&"ROUND_SUMMARY_REQUIRED")
	if (
		source_match == null
		or source_match.match_completion_state != &"MATCH_COMPLETE"
		or source_match.current_phase != MVP_ENUMS.Phase.MATCH_COMPLETE
		or source_match.final_standings.is_empty()
	):
		return _failure(&"MATCH_RESULTS_NOT_READY")
	match_state = source_match
	phase = Phase.MATCH_RESULTS
	return _success(&"MATCH_RESULTS")


func restore_completed_match(source_match: MVP_MATCH_STATE) -> Dictionary:
	if (
		source_match == null
		or source_match.match_completion_state != &"MATCH_COMPLETE"
		or source_match.current_phase != MVP_ENUMS.Phase.MATCH_COMPLETE
		or source_match.final_standings.is_empty()
	):
		return _failure(&"COMPLETED_MATCH_REQUIRED")
	match_state = MVP_MATCH_STATE.from_dict(source_match.to_dict())
	phase = Phase.MATCH_RESULTS
	return _success(&"MATCH_RESULTS_RESTORED")


func restore_between_rounds(source_match: MVP_MATCH_STATE) -> Dictionary:
	if source_match == null:
		return _failure(&"BETWEEN_ROUNDS_MATCH_REQUIRED")
	var report: MVP_VALIDATION_REPORT = MVP_MATCH_VALIDATOR.new().validate(source_match)
	if not report.passed():
		return _failure(&"BETWEEN_ROUNDS_MATCH_INVALID")
	if (
		not source_match.character_selection_complete
		or source_match.players.size() != SUPPORTED_PLAYER_COUNT
		or source_match.current_phase != MVP_ENUMS.Phase.ROUND_START
		or source_match.match_completion_state != &"NEXT_CASE_REQUIRED"
		or source_match.completed_round_count < 1
	):
		return _failure(&"BETWEEN_ROUNDS_BOUNDARY_REQUIRED")
	match_state = source_match
	available_case = FIXTURE_REPOSITORY.load_case()
	case_gameplay_started = false
	next_case_gameplay_started = false
	_selection_published = true
	phase = Phase.NEXT_CASE_SELECTION
	return _success(&"BETWEEN_ROUNDS_RESTORED")


func match_results_presentation() -> Dictionary:
	if match_state == null or match_state.match_completion_state != &"MATCH_COMPLETE":
		return {}
	var standings: Array[Dictionary] = []
	for standing: MATCH_FINAL_STANDING in match_state.final_standings:
		standings.append(standing.to_dict())
	var rules: MATCH_RULES = match_state.match_rules
	return {
		"completed_round_count": match_state.completed_round_count,
		"victory_type": rules.victory_type,
		"target": (
			COURT_RANK_SERVICE.rank_name(rules.target_court_rank)
			if rules.victory_type == MATCH_RULES.VictoryType.REACH_COURT_RANK
			else "%d Round" % rules.round_limit
		),
		"standings": standings,
	}


func mark_next_case_started() -> Dictionary:
	if phase == Phase.CASE_ACTIVE and next_case_gameplay_started:
		return _failure(&"NEXT_CASE_SESSION_ALREADY_ACTIVE", true)
	if phase != Phase.NEXT_CASE_SELECTION or next_case_gameplay_started:
		return _failure(&"NEXT_CASE_SELECTION_NOT_READY")
	next_case_gameplay_started = true
	phase = Phase.CASE_ACTIVE
	return _success(&"NEXT_CASE_ACTIVE")


func round_summary_presentation(
	source_match: MVP_MATCH_STATE,
	management_players: Array[PLAYER_PHASE_STATE],
	round_start_merit_by_player: Dictionary = {}
) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	if source_match == null:
		return rows
	for player_id: StringName in source_match.player_order:
		var persistent: PLAYER_MATCH_STATE = source_match.find_player(player_id)
		var managed: PLAYER_PHASE_STATE = _find_management_player(
			management_players, player_id
		)
		if persistent == null or managed == null:
			continue
		var character: CHARACTER_DEFINITION = find_character(persistent.character_id)
		var character_view: Dictionary = character_presentation(character)
		var before_merit: float = float(
			round_start_merit_by_player.get(
				String(player_id), persistent.merit_progress
			)
		)
		var court_rank: Dictionary = _court_rank_service.resolve(
			persistent.merit_progress
		)
		var promotion: Dictionary = _court_rank_service.promotion(
			before_merit, persistent.merit_progress
		)
		rows.append({
			"player_id": player_id,
			"display_name": persistent.display_name,
			"character_name": String(character_view.get("name", "Nhân vật")),
			"merit": persistent.merit_progress,
			"round_start_merit": before_merit,
			"court_rank": court_rank,
			"court_rank_promotion": promotion,
			"reputation": persistent.reputation,
			"orb": managed.orb_count,
			"tickets": managed.gacha_ticket_count,
			"equipment_count": managed.equipment_collection.size(),
			"has_relic": not managed.relic_instance_id.is_empty(),
			"stigmata_count": _equipped_stigmata_count(managed),
		})
	return rows


func _find_management_player(
	players: Array[PLAYER_PHASE_STATE], player_id: StringName
) -> PLAYER_PHASE_STATE:
	for player: PLAYER_PHASE_STATE in players:
		if player.player_id == player_id:
			return player
	return null


func _equipped_stigmata_count(player: PLAYER_PHASE_STATE) -> int:
	var count := 0
	var instance_ids: Array[StringName] = [
		player.stigmata_a_instance_id,
		player.stigmata_b_instance_id,
		player.stigmata_c_instance_id,
	]
	for instance_id: StringName in instance_ids:
		if not instance_id.is_empty():
			count += 1
	return count


func _can_edit_custom_rules(victory_type: int) -> bool:
	return (
		phase == Phase.MATCH_RULES
		and match_state != null
		and match_state.match_rules != null
		and match_state.match_rules.mode == MATCH_RULES.Mode.CUSTOM
		and match_state.match_rules.victory_type == victory_type
	)


func _report_failure(report: LOOT_VALIDATION_REPORT) -> Dictionary:
	var code: StringName = &"VALIDATION_FAILED"
	if not report.errors.is_empty():
		code = report.errors[0].code
	return _failure(code)


func _success(code: StringName) -> Dictionary:
	return {"success": true, "code": String(code), "duplicate_noop": false}


func _failure(code: StringName, duplicate_noop: bool = false) -> Dictionary:
	return {
		"success": false,
		"code": String(code),
		"duplicate_noop": duplicate_noop,
	}
