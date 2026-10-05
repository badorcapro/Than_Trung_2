class_name PfM9ECTestSuite
extends RefCounted

const AUTOSAVE_SERVICE := preload(
	"res://scripts/application/player_facing/PlayerFacingAutosaveService.gd"
)
const CASE_FLOW_SESSION := preload(
	"res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd"
)
const SETUP_SESSION := preload(
	"res://scripts/application/player_facing/PlayerFacingSetupSession.gd"
)
const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const MVP_MATCH_STATE := preload("res://scripts/domain/mvp/MvpMatchState.gd")
const MVP_ROUND_STATE := preload("res://scripts/domain/mvp/MvpRoundState.gd")
const MVP_SERIALIZER := preload("res://scripts/application/mvp/MvpStateSerializer.gd")
const PLAYER_MATCH_STATE := preload("res://scripts/domain/mvp/PlayerMatchState.gd")
const MATCH_RULES := preload("res://scripts/domain/mvp/MatchRules.gd")
const MATCH_FINAL_STANDING := preload(
	"res://scripts/domain/mvp/MatchFinalStanding.gd"
)

const SMOKE_PATH := "user://pf_m9e_c_smoke_autosave.json"


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_cleanup()

	var precommit_service: AUTOSAVE_SERVICE = _service()
	var precommit: MVP_MATCH_STATE = _next_case_match()
	precommit.match_completion_state = &"IN_PROGRESS"
	var precommit_save: Dictionary = precommit_service.save_match(precommit)
	_add(rows, "PF-M9E-C autosave requires successful Round End boundary", not bool(precommit_save.get("success", false)) and not FileAccess.file_exists(SMOKE_PATH))

	var service: AUTOSAVE_SERVICE = _service()
	var source: MVP_MATCH_STATE = _next_case_match()
	var saved: Dictionary = service.save_match(source)
	var loaded: Dictionary = service.load_match()
	var restored_match: MVP_MATCH_STATE = loaded.get("match_state") as MVP_MATCH_STATE
	_add(rows, "PF-M9E-C NEXT_CASE_REQUIRED Match writes one autosave", bool(saved.get("success", false)) and FileAccess.file_exists(SMOKE_PATH))
	_add(rows, "PF-M9E-C Round autosave precedes option composition", _controller_autosave_order_is_safe())
	_add(rows, "PF-M9E-C Continue restores identical players", restored_match != null and restored_match.player_order == source.player_order and restored_match.players.size() == source.players.size())
	_add(rows, "PF-M9E-C Continue restores MatchRules", restored_match != null and restored_match.match_rules.to_dict() == source.match_rules.to_dict())
	_add(rows, "PF-M9E-C Continue restores resources and progression", restored_match != null and restored_match.players[0].to_dict() == source.players[0].to_dict())
	_add(rows, "PF-M9E-C Continue restores Round counters", restored_match != null and restored_match.completed_round_count == 1 and restored_match.current_round_number == 2)
	_add(rows, "PF-M9E-C Continue does not rerun Round End commit", _continue_path_does_not_commit_round_end())
	_add(rows, "PF-M9E-C Continue does not replay prior rewards", restored_match != null and restored_match.applied_commit_ids == source.applied_commit_ids and _restore_path_has_no_reward_replay())

	var restored_flow: CASE_FLOW_SESSION = CASE_FLOW_SESSION.new()
	var restored_flow_result: Dictionary = restored_flow.restore_player_facing_between_rounds(restored_match)
	var composed: Dictionary = (
		restored_flow.prepare_default_next_case_options()
		if bool(restored_flow_result.get("success", false))
		else {}
	)
	_add(rows, "PF-M9E-C Continue composes exactly three next Cases", bool(composed.get("success", false)) and restored_flow.case_option_presentations().size() == 3)

	var completed: MVP_MATCH_STATE = _completed_match()
	var completed_saved: Dictionary = service.save_match(completed)
	var completed_loaded: Dictionary = service.load_match()
	var restored_completed: MVP_MATCH_STATE = completed_loaded.get("match_state") as MVP_MATCH_STATE
	_add(rows, "PF-M9E-C MATCH_COMPLETE autosaves final standings", bool(completed_saved.get("success", false)) and restored_completed != null and restored_completed.final_standings.size() == 3)
	var completed_setup: SETUP_SESSION = SETUP_SESSION.new()
	var completed_restore: Dictionary = completed_setup.restore_completed_match(restored_completed)
	_add(rows, "PF-M9E-C completed Continue opens Match Results", bool(completed_restore.get("success", false)) and completed_setup.phase == SETUP_SESSION.Phase.MATCH_RESULTS)
	_add(rows, "PF-M9E-C completed Continue starts no next Round", completed_setup.match_state.current_phase == MVP_ENUMS.Phase.MATCH_COMPLETE and completed_setup.match_state.match_completion_state == &"MATCH_COMPLETE")

	_cleanup()
	_add(rows, "PF-M9E-C missing autosave disables Continue safely", not _service().has_valid_autosave() and _continue_button_uses_autosave_validity())
	_write_raw("{broken")
	_add(rows, "PF-M9E-C corrupt autosave disables Continue safely", not _service().has_valid_autosave() and _continue_button_uses_autosave_validity())
	_write_raw(JSON.stringify({"schema_version": 999}))
	_add(rows, "PF-M9E-C unsupported schema disables Continue safely", not _service().has_valid_autosave() and _continue_button_uses_autosave_validity())
	var unsupported: MVP_MATCH_STATE = _next_case_match()
	unsupported.current_phase = MVP_ENUMS.Phase.CASE
	unsupported.match_completion_state = &"IN_PROGRESS"
	_write_raw(MVP_SERIALIZER.new().to_json(unsupported, null))
	_add(rows, "PF-M9E-C unsupported phase disables Continue safely", not _service().has_valid_autosave())
	var active_round: MVP_ROUND_STATE = MVP_ROUND_STATE.new()
	active_round.round_id = &"pf_m9e_c_active_round"
	active_round.round_number = source.current_round_number
	active_round.phase = MVP_ENUMS.Phase.ROUND_START
	_write_raw(JSON.stringify(MVP_SERIALIZER.new().build_snapshot(source, active_round)))
	_add(rows, "PF-M9E-C active Round snapshot is rejected", not _service().has_valid_autosave())

	_cleanup()
	var preserved_service: AUTOSAVE_SERVICE = _service()
	preserved_service.save_match(source)
	var setup: SETUP_SESSION = SETUP_SESSION.new()
	setup.begin_new_game()
	var preserved: Dictionary = preserved_service.load_match()
	var preserved_match: MVP_MATCH_STATE = preserved.get("match_state") as MVP_MATCH_STATE
	_add(rows, "PF-M9E-C starting new Match preserves existing autosave", preserved_match != null and preserved_match.match_id == source.match_id and preserved_match.completed_round_count == 1)
	_cleanup()
	return rows


func _next_case_match() -> MVP_MATCH_STATE:
	var state: MVP_MATCH_STATE = MVP_MATCH_STATE.new()
	state.match_id = &"pf_m9e_c_match"
	state.case_generation_seed = 24681357
	state.character_selection_complete = true
	state.current_round_number = 2
	state.completed_round_count = 1
	state.current_phase = MVP_ENUMS.Phase.ROUND_START
	state.match_completion_state = &"NEXT_CASE_REQUIRED"
	state.match_rules = MATCH_RULES.custom_fixed_rounds(3)
	state.applied_commit_ids.append(&"pf_m9e_c_round_1_commit")
	state.used_case_candidate_signatures.append("pf-m9e-c-used-case")
	for index: int in range(3):
		var player: PLAYER_MATCH_STATE = PLAYER_MATCH_STATE.new()
		player.player_id = StringName("player_%d" % (index + 1))
		player.display_name = "Người chơi %d" % (index + 1)
		player.character_id = StringName("character_%d" % (index + 1))
		player.seat_index = index
		player.merit_progress = 20.0 + index * 5.0
		player.reputation = 5 - index
		player.orb_count = 10 + index
		player.gacha_ticket_count = 7 + index
		player.silver_coin_count = 30 + index
		player.equipment_exp_material_count = 40 + index
		player.equipment_exchange_material_count = 2 + index
		player.gacha_state.consecutive_without_a_plus = index + 1
		state.players.append(player)
		state.player_order.append(player.player_id)
	return state


func _completed_match() -> MVP_MATCH_STATE:
	var state: MVP_MATCH_STATE = _next_case_match()
	state.current_phase = MVP_ENUMS.Phase.MATCH_COMPLETE
	state.match_completion_state = &"MATCH_COMPLETE"
	state.match_rules = MATCH_RULES.custom_fixed_rounds(1)
	for index: int in range(state.players.size()):
		var player: PLAYER_MATCH_STATE = state.players[index]
		var standing: MATCH_FINAL_STANDING = MATCH_FINAL_STANDING.new()
		standing.player_id = player.player_id
		standing.display_name = player.display_name
		standing.court_rank_id = &"RANK_9"
		standing.court_rank_name = "Cửu phẩm"
		standing.merit = player.merit_progress
		standing.place = index + 1
		state.final_standings.append(standing)
	return state


func _controller_autosave_order_is_safe() -> bool:
	var source: String = FileAccess.get_file_as_string(
		"res://scripts/presentation/player_facing/PlayerFacingStartController.gd"
	)
	var body: String = _function_body(source, "func _on_round_summary_continue_pressed()")
	return (
		body.find("commit_round_end(") >= 0
		and body.find("save_match(case_flow.match_state)") > body.find("commit_round_end(")
		and body.find("save_match(case_flow.match_state)") < body.find("prepare_default_next_case_options()")
	)


func _continue_path_does_not_commit_round_end() -> bool:
	var source: String = FileAccess.get_file_as_string(
		"res://scripts/presentation/player_facing/PlayerFacingStartController.gd"
	)
	return not _function_body(source, "func _on_continue_pressed()").contains(
		"commit_round_end("
	)


func _restore_path_has_no_reward_replay() -> bool:
	var source: String = FileAccess.get_file_as_string(
		"res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd"
	)
	var body: String = _function_body(
		source, "func restore_player_facing_between_rounds("
	)
	return (
		not body.contains("commit_round_end(")
		and not body.contains("begin_loot(")
		and not body.contains("move(")
		and not body.contains("reward")
	)


func _continue_button_uses_autosave_validity() -> bool:
	var controller_source: String = FileAccess.get_file_as_string(
		"res://scripts/presentation/player_facing/PlayerFacingStartController.gd"
	)
	var scene_source: String = FileAccess.get_file_as_string(
		"res://scenes/player_facing/PlayerFacingStart.tscn"
	)
	var refresh_body: String = _function_body(
		controller_source, "func _refresh_continue_button()"
	)
	return (
		controller_source.contains("_refresh_continue_button()")
		and refresh_body.contains("has_valid_autosave()")
		and refresh_body.contains("continue_button.disabled = not available")
		and scene_source.contains("method=\"_on_continue_pressed\"")
	)


func _function_body(source: String, signature: String) -> String:
	var start: int = source.find(signature)
	if start < 0:
		return ""
	var next_function: int = source.find("\nfunc ", start + signature.length())
	return source.substr(start) if next_function < 0 else source.substr(start, next_function - start)


func _service() -> AUTOSAVE_SERVICE:
	var service: AUTOSAVE_SERVICE = AUTOSAVE_SERVICE.new()
	service.autosave_path = SMOKE_PATH
	return service


func _write_raw(text: String) -> void:
	var file: FileAccess = FileAccess.open(SMOKE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(text)
	file.close()


func _cleanup() -> void:
	for path: String in [SMOKE_PATH, SMOKE_PATH + ".tmp", SMOKE_PATH + ".bak"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "PF-M9E-C single-slot autosave and Continue invariant",
	})
