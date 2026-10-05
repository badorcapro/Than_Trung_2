class_name Gd3M5NextCaseOrchestrationController
extends Control

const SESSION := preload("res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd")
const CASE_CONTROLLER := preload("res://scripts/presentation/case_gameplay/VSCaseMainController.gd")
const CASE_BOUNDARY := preload("res://scripts/domain/mvp/MvpCaseCompletionBoundary.gd")
const CASE_SCENE := preload("res://scenes/case_gameplay/VSCaseMain.tscn")
const LOOT_SESSION := preload("res://scripts/domain/loot/LootRewardSession.gd")
const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")

var session: SESSION = SESSION.new()
var case_controller: CASE_CONTROLLER

@onready var status_label: Label = %StatusLabel
@onready var case_host: Control = %CaseHost
@onready var round1_end_panel: Control = %Round1EndPanel
@onready var round1_end_text: RichTextLabel = %Round1EndText
@onready var settlement_panel: Control = %SettlementPanel
@onready var settlement_text: RichTextLabel = %SettlementText
@onready var round2_loot_panel: Control = %Round2LootPanel
@onready var round2_loot_text: RichTextLabel = %Round2LootText


func _ready() -> void:
	var result: Dictionary = session.build_integrated_fixture()
	_show_result(result)
	if bool(result.get("success", false)):
		# Run Round 1 to NEXT_CASE_REQUIRED
		var r1_res: Dictionary = session.complete_round_1_programmatically()
		_show_result(r1_res)
		if bool(r1_res.get("success", false)):
			case_host.visible = false
			round1_end_panel.visible = true
			_render_round1_end()


func _on_start_round_2_pressed() -> void:
	var result: Dictionary = session.start_next_round(&"vs_case_001")
	_show_result(result)
	if bool(result.get("success", false)):
		round1_end_panel.visible = false
		case_host.visible = true
		_launch_round2_case()


func _launch_round2_case() -> void:
	for child: Node in case_host.get_children():
		child.queue_free()
	case_controller = CASE_SCENE.instantiate() as CASE_CONTROLLER
	if case_controller == null:
		_show_result({"success": false, "code": "CASE_SCENE_INVALID", "message": "Case scene instantiate failed"})
		return
	case_controller.configure_integrated_case(session.round2_projected_case_players)
	case_controller.integration_case_completed.connect(_on_round2_case_completed)
	case_host.add_child(case_controller)
	case_controller.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _on_round2_case_completed(boundary_value: RefCounted) -> void:
	var boundary: CASE_BOUNDARY = boundary_value as CASE_BOUNDARY
	var result: Dictionary = session.handle_round2_case_completion(boundary)
	_show_result(result)
	if bool(result.get("success", false)):
		case_host.visible = false
		settlement_panel.visible = true
		_render_round2_settlement()


func _on_continue_to_round2_loot_pressed() -> void:
	var result: Dictionary = session.begin_round2_loot()
	_show_result(result)
	if bool(result.get("success", false)):
		settlement_panel.visible = false
		round2_loot_panel.visible = true
		_render_round2_loot()


func _on_back_pressed() -> void:
	AppFlow.go_to_debug_home()


func _render_round1_end() -> void:
	var lines: Array[String] = [
		"[b]Round 1 Complete — NEXT_CASE_REQUIRED[/b]",
		"Round: %d → %d" % [session.round_end_summary.get("round_before", 1), session.round_end_summary.get("round_after", 2)],
		"Commit ID: %s" % session.round_end_summary.get("commit_id", ""),
		"Active Round cleared: %s" % session.round_end_summary.get("active_round_cleared", false),
		"",
		"Ready to route and initialize Round 2 Case."
	]
	round1_end_text.text = "\n".join(lines)


func _render_round2_settlement() -> void:
	var lines: Array[String] = [
		"[b]Round 2 Actual Settlement Applied Once[/b]",
		"Commit ID: %s" % session.round_state.settlement_commit_id,
		""
	]
	for row: Dictionary in session.round2_settlement_summary:
		lines.append(
			"%s [%s] · Merit: %.2f (+%.2f) · Rep: %d (%+d) · Orb: %d (%+d) · Tickets: %d (%+d)"
			% [
				row.get("display_name", ""),
				row.get("status", ""),
				row.get("total_merit", 0.0),
				row.get("merit_delta", 0.0),
				row.get("total_reputation", 0),
				row.get("reputation_delta", 0),
				row.get("total_orb", 0),
				row.get("orb_delta", 0),
				row.get("total_ticket", 0),
				row.get("ticket_delta", 0),
			]
		)
	settlement_text.text = "\n".join(lines)


func _render_round2_loot() -> void:
	if session.round2_loot_session == null:
		return
	var loot: LOOT_SESSION = session.round2_loot_session
	var lines: Array[String] = [
		"[b]Round 2 Loot Initialized — M5 Endpoint Reached[/b]",
		"Phase: %s" % LOOT_SESSION.Phase.keys()[loot.phase],
		"Map ID: %s" % loot.map_id,
		"Snapshots: %d reward nodes rolled fresh" % loot.reward_snapshots.size(),
		"",
		"[b]Player Status (Respawned at Origin, Stamina Reset):[/b]"
	]
	for player: PlayerPhaseState in loot.players:
		var round_loot: RoundLootInventoryState = loot.find_round_loot_state(
			player.player_id
		)
		lines.append(
			"%s · Origin node=%s · Remaining moves=%d · Bag capacity=%d"
			% [
				player.player_id,
				player.current_node_id,
				player.remaining_moves,
				round_loot.capacity if round_loot != null else 0,
			]
		)
	lines.append("\n[color=#76d99a]M5 STOP: Flow halts at ROUND_2_LOOT_INITIALIZED.[/color]")
	round2_loot_text.text = "\n".join(lines)


func _show_result(result: Dictionary) -> void:
	var success: bool = bool(result.get("success", false))
	status_label.text = "%s — %s: %s" % [
		"PASS" if success else "BLOCKED",
		result.get("code", "UNKNOWN"),
		result.get("message", ""),
	]
	status_label.modulate = Color(0.55, 1.0, 0.65) if success else Color(1.0, 0.62, 0.52)
