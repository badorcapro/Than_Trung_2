class_name Gd2M7TestSuite
extends RefCounted

const PROTOTYPE_B_FLOW_SERVICE := preload(
	"res://scripts/application/prototype_b/PrototypeBFlowService.gd"
)
const PROTOTYPE_B_SUMMARY_SERVICE := preload(
	"res://scripts/application/prototype_b/PrototypeBSummaryService.gd"
)
const PROTOTYPE_B_SESSION := preload("res://scripts/domain/prototype_b/PrototypeBSession.gd")

const GD2_SCENES: Array[String] = [
	"res://scenes/loot/VSLootMain.tscn",
	"res://scenes/loot/Gd2M2CharacterSelection.tscn",
	"res://scenes/loot/Gd2M3Movement.tscn",
	"res://scenes/loot/Gd2M4RewardItem.tscn",
	"res://scenes/loot/Gd2M5EquipmentManagement.tscn",
	"res://scenes/loot/Gd2M6PrototypeBFullFlow.tscn",
]
const DEBUG_HOME_SCENE := "res://scenes/boot/DebugHome.tscn"


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for scene_path: String in GD2_SCENES:
		_add(rows, "M7 scene loads: %s" % scene_path.get_file(), load(scene_path) is PackedScene)
	_add(rows, "M7 DebugHome primary entry and vertical scroll", _debug_home_primary_entry())
	_add(
		rows,
		"M7 M6 body remains vertically scrollable",
		_scene_has_node_type(GD2_SCENES[5], "Body", "ScrollContainer")
	)
	_add(
		rows,
		"M7 M6 actions remain responsive grid",
		_scene_has_node_type(GD2_SCENES[5], "Actions", "GridContainer")
	)
	for player_count: int in [1, 3, 4]:
		_test_complete_flow(rows, player_count)
	_test_complete_state(rows)
	return rows


func _test_complete_flow(rows: Array[Dictionary], player_count: int) -> void:
	var flow: PROTOTYPE_B_FLOW_SERVICE = PROTOTYPE_B_FLOW_SERVICE.new()
	var summaries: PROTOTYPE_B_SUMMARY_SERVICE = PROTOTYPE_B_SUMMARY_SERVICE.new()
	var session: PROTOTYPE_B_SESSION = flow.create_test_only_session(player_count)
	var complete_result: Dictionary = flow.complete_test_only_flow(session)
	_add(
		rows,
		"M7 %dP flow reaches summary-ready without deadlock" % player_count,
		(
			bool(complete_result.get("success", false))
			and String(session.status_name()) == "READY_FOR_SUMMARY"
		)
	)
	_add(
		rows,
		"M7 %dP has no unresolved pending state" % player_count,
		_no_pending_state(session)
	)
	var summary_result: Dictionary = flow.enter_summary(session)
	_add(
		rows,
		"M7 %dP summary preserves player count" % player_count,
		(
			bool(summary_result.get("success", false))
			and session.summary != null
			and session.summary.player_summaries.size() == player_count
		)
	)
	var finalize_result: Dictionary = summaries.finalize_prototype_b(session)
	_add(
		rows,
		"M7 %dP reaches immutable Prototype Complete" % player_count,
		bool(finalize_result.get("success", false)) and session.is_complete()
	)


func _test_complete_state(rows: Array[Dictionary]) -> void:
	var flow: PROTOTYPE_B_FLOW_SERVICE = PROTOTYPE_B_FLOW_SERVICE.new()
	var summaries: PROTOTYPE_B_SUMMARY_SERVICE = PROTOTYPE_B_SUMMARY_SERVICE.new()
	var session: PROTOTYPE_B_SESSION = flow.create_test_only_session(1)
	flow.complete_test_only_flow(session)
	flow.enter_summary(session)
	summaries.finalize_prototype_b(session)
	var all_rejected := true
	for action_id: StringName in [
		&"SELECTION_EDIT", &"MOVEMENT", &"REWARD", &"ITEM_USE", &"EQUIPMENT_UPGRADE", &"GACHA_ROLL"
	]:
		var rejection: Dictionary = flow.reject_gameplay_action(session, action_id)
		all_rejected = (
			all_rejected
			and not bool(rejection.get("success", true))
			and String(rejection.get("code", "")) == "PROTOTYPE_B_COMPLETE_IMMUTABLE"
		)
	_add(rows, "M7 complete state rejects every gameplay mutation family", all_rejected)
	_add(rows, "M7 complete state keeps summary viewable", session.summary != null)
	_add(
		rows,
		"M7 OPEN Gacha policies remain explicit and unresolved",
		session.summary != null and session.summary.open_policy_ids.size() == 7
	)


func _no_pending_state(session: PROTOTYPE_B_SESSION) -> bool:
	return (
		session.movement_session != null
		and session.movement_session.completed
		and session.movement_session.all_exhausted()
		and session.reward_session != null
		and session.reward_session.pending_trace_index >= session.reward_session.pending_trace.size()
		and not session.reward_session.overflow.active
		and session.management_session != null
		and not session.management_session.pending_choice.is_active()
		and session.management_session.done_player_ids.size() == session.players.size()
	)


func _debug_home_primary_entry() -> bool:
	var packed: PackedScene = load(DEBUG_HOME_SCENE) as PackedScene
	if packed == null:
		return false
	var root: Node = packed.instantiate()
	var button: Button = root.find_child("M6Button", true, false) as Button
	var menu_scroll: ScrollContainer = root.find_child("MenuScroll", true, false) as ScrollContainer
	var exit_button: Button = root.find_child("ExitButton", true, false) as Button
	var passed := (
		button != null
		and button.text.begins_with("Prototype B Full Flow — MAIN")
		and menu_scroll != null
		and menu_scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED
		and exit_button != null
		and exit_button.is_ancestor_of(menu_scroll) == false
		and menu_scroll.is_ancestor_of(exit_button)
	)
	root.free()
	return passed


func _scene_has_node_type(scene_path: String, node_name: String, type_name: String) -> bool:
	var packed: PackedScene = load(scene_path) as PackedScene
	if packed == null:
		return false
	var root: Node = packed.instantiate()
	var node: Node = root.find_child(node_name, true, false)
	var passed := node != null and node.get_class() == type_name
	root.free()
	return passed


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({"name": name, "passed": passed, "detail": "GĐ2-M7 stabilization invariant"})
