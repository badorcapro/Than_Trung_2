class_name PfM1TestSuite
extends RefCounted

const SETUP_SESSION := preload(
	"res://scripts/application/player_facing/PlayerFacingSetupSession.gd"
)
const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const MVP_SERIALIZER := preload("res://scripts/application/mvp/MvpStateSerializer.gd")
const PLAYER_MATCH_STATE := preload("res://scripts/domain/mvp/PlayerMatchState.gd")
const PLAYER_PHASE_STATE := preload(
	"res://scripts/domain/characters/PlayerPhaseState.gd"
)
const CHARACTER_DEFINITION := preload(
	"res://scripts/domain/characters/CharacterDefinition.gd"
)

const PLAYER_SCENE := "res://scenes/player_facing/PlayerFacingStart.tscn"
const DEBUG_SCENE := "res://scenes/boot/DebugHome.tscn"
const M6_SCENE := "res://scenes/mvp/Gd3M6TwoRoundCompletion.tscn"


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_test_entry_and_scenes(rows)
	_test_supported_setup(rows)
	_test_pass_device_selection(rows)
	_test_lineup_commit(rows)
	_test_case_selection_endpoint(rows)
	return rows


func _test_entry_and_scenes(rows: Array[Dictionary]) -> void:
	var packed: PackedScene = load(PLAYER_SCENE) as PackedScene
	_add(rows, "PF-M1 normal Main Menu loads", packed != null)
	var root: Node = packed.instantiate() if packed != null else null
	_add(rows, "PF-M1 Main Menu offers New Game", root != null and root.find_child("NewGame", true, false) is Button)
	var continue_button: Button
	if root != null:
		continue_button = root.find_child("Continue", true, false) as Button
	_add(rows, "PF-M1 Continue is safely disabled", continue_button != null and continue_button.disabled)
	_add(rows, "PF-M1 Settings entry exists", root != null and root.find_child("Settings", true, false) is Button)
	_add(rows, "PF-M1 Exit entry exists", root != null and root.find_child("Exit", true, false) is Button)
	_add(rows, "PF-M1 DebugHome remains loadable", load(DEBUG_SCENE) is PackedScene)
	_add(rows, "PF-M1 prior M6 harness remains loadable", load(M6_SCENE) is PackedScene)
	_add(
		rows,
		"PF-M1 AppFlow keeps player and developer routes",
		AppFlow.PLAYER_FACING_START_SCENE == PLAYER_SCENE
		and AppFlow.DEBUG_HOME_SCENE == DEBUG_SCENE
		and AppFlow.has_method("go_to_player_main_menu")
		and AppFlow.has_method("go_to_debug_home")
	)
	_add(rows, "PF-M1 developer shortcut is hidden from menu", _developer_entry_is_keyboard_only())
	_add(rows, "PF-M1 responsive Character list scroll exists", root != null and root.find_child("CharacterScroll", true, false) is ScrollContainer)
	if root != null:
		root.free()


func _test_supported_setup(rows: Array[Dictionary]) -> void:
	var session: SETUP_SESSION = SETUP_SESSION.new()
	var begun: Dictionary = session.begin_new_game()
	_add(rows, "PF-M1 New Game reaches Match Mode setup", bool(begun.get("success", false)) and session.phase == SETUP_SESSION.Phase.MATCH_MODE)
	_add(rows, "PF-M1 new Match setup starts clean", session.match_state != null and session.match_state.players.is_empty() and not session.match_state.character_selection_complete)
	_add(rows, "PF-M1 one-player runtime is not exposed", _count_rejected(1))
	_add(rows, "PF-M1 two-player runtime is not exposed", _count_rejected(2))
	_add(rows, "PF-M1 four-player runtime is not exposed", _count_rejected(4))
	var configured: Dictionary = session.choose_player_count(3)
	_add(rows, "PF-M1 supported three-player flow proceeds", bool(configured.get("success", false)) and session.phase == SETUP_SESSION.Phase.CHARACTER_SELECTION)
	_add(rows, "PF-M1 selection authority owns exactly three seats", session.selection_session.player_count == 3 and session.selection_session.selected_character_ids.size() == 3)
	_add(rows, "PF-M1 production Character duplicates are forbidden", not session.selection_session.allow_duplicate_characters and not session.selection_session.duplicate_policy_test_only_not_canon_locked)


func _test_pass_device_selection(rows: Array[Dictionary]) -> void:
	var session: SETUP_SESSION = _configured_session()
	var selected_one: Dictionary = session.select_character(session.characters[0].character_id)
	_add(rows, "PF-M1 Player 1 selects through existing authority", bool(selected_one.get("success", false)) and session.selection_session.current_seat_index == 0)
	var locked_one: Dictionary = session.lock_current_character()
	_add(rows, "PF-M1 Player 1 lock enters pass-device", bool(locked_one.get("success", false)) and session.phase == SETUP_SESSION.Phase.PASS_DEVICE)
	session.continue_after_pass_device()
	_add(rows, "PF-M1 pass-device advances to Player 2", session.phase == SETUP_SESSION.Phase.CHARACTER_SELECTION and session.selection_session.current_seat_index == 1)
	session.select_character(session.characters[1].character_id)
	session.lock_current_character()
	_add(rows, "PF-M1 Player 2 lock enters pass-device", session.phase == SETUP_SESSION.Phase.PASS_DEVICE)
	session.continue_after_pass_device()
	_add(rows, "PF-M1 pass-device advances to Player 3", session.selection_session.current_seat_index == 2)
	session.select_character(session.characters[2].character_id)
	session.lock_current_character()
	_add(rows, "PF-M1 Player 3 completes lineup selection", session.phase == SETUP_SESSION.Phase.LINEUP_CONFIRMATION)
	_add(rows, "PF-M1 all three selections are locked", session.selection_session.is_complete())
	_add(rows, "PF-M1 lineup exposes three friendly assignments", _friendly_lineup_complete(session))


func _test_lineup_commit(rows: Array[Dictionary]) -> void:
	var session: SETUP_SESSION = _lineup_session()
	var committed: Dictionary = session.confirm_lineup()
	_add(rows, "PF-M1 lineup confirmation succeeds", bool(committed.get("success", false)))
	_add(rows, "PF-M1 Character Selection commits exactly once", session.selection_commit_count() == 1 and session.selection_published())
	_add(rows, "PF-M1 creates exactly three PlayerMatchState entries", session.match_state.players.size() == 3)
	_add(rows, "PF-M1 assignments join by player_id", _assignments_match_by_player_id(session))
	_add(rows, "PF-M1 selected Character identities persist", _character_ids_persist(session))
	_add(rows, "PF-M1 MatchState records completed Character Selection", session.match_state.character_selection_complete)
	_add(rows, "PF-M1 MatchState semantically round-trips", bool(MVP_SERIALIZER.new().round_trip_diagnostic(session.match_state, null).get("matches", false)))
	var before: Dictionary = session.match_state.to_dict()
	var duplicate: Dictionary = session.confirm_lineup()
	_add(rows, "PF-M1 duplicate lineup confirmation is structured safe", String(duplicate.get("code", "")) == "CHARACTER_SELECTION_ALREADY_COMMITTED" and bool(duplicate.get("duplicate_noop", false)))
	_add(rows, "PF-M1 duplicate confirmation does not mutate MatchState", session.match_state.to_dict() == before and session.match_state.players.size() == 3)


func _test_case_selection_endpoint(rows: Array[Dictionary]) -> void:
	var session: SETUP_SESSION = _committed_session()
	_add(rows, "PF-M1 reaches exact Case Selection endpoint", session.phase == SETUP_SESSION.Phase.CASE_SELECTION_READY)
	_add(rows, "PF-M1 exposes exactly one existing Case", session.available_case != null)
	var card: Dictionary = session.case_presentation()
	_add(rows, "PF-M1 Case card has friendly title and description", not String(card.get("name", "")).is_empty() and not String(card.get("description", "")).is_empty())
	_add(rows, "PF-M1 Case card hides fixture identifiers", _presentation_has_no_internal_ids(card))
	_add(rows, "PF-M1 Character cards hide prototype identifiers", _all_character_presentations_are_friendly(session))
	_add(rows, "PF-M1 does not start Case gameplay", not session.case_gameplay_started and session.match_state.current_phase == MVP_ENUMS.Phase.ROUND_START)
	_add(rows, "PF-M1 creates no active Round or later Round", session.match_state.current_round_number == 0)
	_add(rows, "PF-M1 does not enter MATCH_COMPLETE", session.match_state.current_phase != MVP_ENUMS.Phase.MATCH_COMPLETE and session.match_state.match_completion_state == &"IN_PROGRESS")
	var packed: PackedScene = load(PLAYER_SCENE) as PackedScene
	var root: Node = packed.instantiate() if packed != null else null
	var start_case: Button
	if root != null:
		start_case = root.find_child("StartCase", true, false) as Button
	_add(
		rows,
		"PF-M1 investigation action is visible without auto-start",
		start_case != null and not session.case_gameplay_started
	)
	_add(rows, "PF-M1 player UI contains no milestone labels", _scene_has_no_internal_labels())
	if root != null:
		root.free()


func _configured_session() -> SETUP_SESSION:
	var session: SETUP_SESSION = SETUP_SESSION.new()
	session.begin_new_game()
	session.choose_player_count(3)
	return session


func _lineup_session() -> SETUP_SESSION:
	var session: SETUP_SESSION = _configured_session()
	for seat_index: int in range(3):
		session.select_character(session.characters[seat_index].character_id)
		session.lock_current_character()
		if session.phase == SETUP_SESSION.Phase.PASS_DEVICE:
			session.continue_after_pass_device()
	return session


func _committed_session() -> SETUP_SESSION:
	var session: SETUP_SESSION = _lineup_session()
	session.confirm_lineup()
	return session


func _count_rejected(count: int) -> bool:
	var session: SETUP_SESSION = SETUP_SESSION.new()
	session.begin_new_game()
	var result: Dictionary = session.choose_player_count(count)
	return not bool(result.get("success", false)) and String(result.get("code", "")) == "PLAYER_COUNT_NOT_SUPPORTED"


func _friendly_lineup_complete(session: SETUP_SESSION) -> bool:
	for seat_index: int in range(3):
		var view: Dictionary = session.character_presentation(
			session.selected_character_for_seat(seat_index)
		)
		if String(view.get("name", "")).is_empty() or not _presentation_has_no_internal_ids(view):
			return false
	return true


func _assignments_match_by_player_id(session: SETUP_SESSION) -> bool:
	for seat_index: int in range(3):
		var player_id: StringName = StringName("local_player_%d" % (seat_index + 1))
		var player: PLAYER_MATCH_STATE = session.match_state.find_player(player_id)
		if player == null or player.seat_index != seat_index:
			return false
	return true


func _character_ids_persist(session: SETUP_SESSION) -> bool:
	for source: PLAYER_PHASE_STATE in session.selection_session.committed_players:
		var target: PLAYER_MATCH_STATE = session.match_state.find_player(source.player_id)
		if target == null or target.character_id != source.character_id:
			return false
	return true


func _all_character_presentations_are_friendly(session: SETUP_SESSION) -> bool:
	for character: CHARACTER_DEFINITION in session.characters:
		if not _presentation_has_no_internal_ids(session.character_presentation(character)):
			return false
	return true


func _presentation_has_no_internal_ids(view: Dictionary) -> bool:
	var payload: String = JSON.stringify(view).to_lower()
	return (
		not payload.contains("test_")
		and not payload.contains("fixture")
		and not payload.contains("vs_case_001")
		and not payload.contains("gd3")
	)


func _developer_entry_is_keyboard_only() -> bool:
	var scene_text: String = FileAccess.get_file_as_string(PLAYER_SCENE)
	var controller_text: String = FileAccess.get_file_as_string(
		"res://scripts/presentation/player_facing/PlayerFacingStartController.gd"
	)
	return not scene_text.contains("DebugHome") and controller_text.contains("KEY_F12")


func _scene_has_no_internal_labels() -> bool:
	var source: String = FileAccess.get_file_as_string(PLAYER_SCENE)
	for forbidden: String in ["DebugHome", "GĐ1", "GĐ2", "GĐ3", "PF-M1", "PASS", "BLOCKED", "TEST_ONLY", "fixture"]:
		if source.contains(forbidden):
			return false
	return true


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "PF-M1 player-facing startup invariant",
	})
