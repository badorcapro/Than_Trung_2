class_name Gd3M3IntegratedCaseLootController
extends Control

const INTEGRATED_SESSION := preload("res://scripts/application/mvp/MvpIntegratedCaseLootSession.gd")
const CASE_CONTROLLER := preload("res://scripts/presentation/case_gameplay/VSCaseMainController.gd")
const CASE_BOUNDARY := preload("res://scripts/domain/mvp/MvpCaseCompletionBoundary.gd")
const CASE_SCENE := preload("res://scenes/case_gameplay/VSCaseMain.tscn")
const LOOT_REWARD_SESSION := preload("res://scripts/domain/loot/LootRewardSession.gd")

var session: INTEGRATED_SESSION = INTEGRATED_SESSION.new()
var case_controller: CASE_CONTROLLER

@onready var status_label: Label = %StatusLabel
@onready var case_host: Control = %CaseHost
@onready var settlement_panel: PanelContainer = %SettlementPanel
@onready var settlement_text: RichTextLabel = %SettlementText
@onready var loot_panel: PanelContainer = %LootPanel
@onready var loot_phase_label: Label = %LootPhaseLabel
@onready var loot_state_text: RichTextLabel = %LootStateText
@onready var item_picker: OptionButton = %ItemPicker
@onready var use_item_button: Button = %UseItemButton
@onready var continue_button: Button = %ContinueButton
@onready var move_button: Button = %MoveButton
@onready var discard_button: Button = %DiscardButton
@onready var skip_button: Button = %SkipButton


func _ready() -> void:
	var result: Dictionary = session.build_integrated_fixture()
	_show_result(result)
	if bool(result.get("success", false)):
		_launch_actual_case()


func _launch_actual_case() -> void:
	case_controller = CASE_SCENE.instantiate() as CASE_CONTROLLER
	if case_controller == null:
		_show_result(_failure("CASE_SCENE_INVALID", "VSCaseMain root/controller mismatch"))
		return
	case_controller.configure_integrated_case(session.projected_case_players)
	case_controller.integration_case_completed.connect(_on_case_completed)
	case_host.add_child(case_controller)
	case_controller.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _on_case_completed(boundary_value: RefCounted) -> void:
	var boundary: CASE_BOUNDARY = boundary_value as CASE_BOUNDARY
	var result: Dictionary = session.handle_case_completion(boundary)
	_show_result(result)
	if not bool(result.get("success", false)):
		return
	case_host.visible = false
	settlement_panel.visible = true
	_render_settlement()


func _on_continue_to_loot_pressed() -> void:
	var result: Dictionary = session.begin_loot()
	_show_result(result)
	if not bool(result.get("success", false)):
		return
	settlement_panel.visible = false
	loot_panel.visible = true
	_refresh_loot()


func _on_continue_without_item_pressed() -> void:
	_show_result(session.continue_without_item())
	_refresh_loot()


func _on_use_item_pressed() -> void:
	if item_picker.item_count == 0 or item_picker.selected < 0:
		_show_result(_failure("ITEM_SELECTION_MISSING", "Choose an available Bag item"))
		return
	var item_id := StringName(item_picker.get_item_metadata(item_picker.selected))
	_show_result(session.use_item(item_id))
	_refresh_loot()


func _on_move_pressed() -> void:
	_show_result(session.move())
	_refresh_loot()


func _on_discard_pressed() -> void:
	_show_result(session.resolve_overflow_discard(0))
	_refresh_loot()


func _on_skip_pressed() -> void:
	_show_result(session.resolve_overflow_skip())
	_refresh_loot()


func _on_back_pressed() -> void:
	AppFlow.go_to_debug_home()


func _render_settlement() -> void:
	var lines: Array[String] = ["[b]Actual GĐ1 settlement → MatchState[/b]"]
	for row: Dictionary in session.settlement_summary:
		(
			lines
			. append(
				(
					"%s [%s] · Merit %+.2f → %.2f · Rep %+.0f → %d · Orb %+.0f → %d · Ticket %+.0f → %d"
					% [
						String(row.get("display_name", "")),
						String(row.get("status", "UNKNOWN")),
						float(row.get("merit_delta", 0.0)),
						float(row.get("merit_total", 0.0)),
						float(row.get("reputation_delta", 0)),
						int(row.get("reputation_total", 0)),
						float(row.get("orb_delta", 0)),
						int(row.get("orb_total", 0)),
						float(row.get("ticket_delta", 0)),
						int(row.get("ticket_total", 0)),
					]
				)
			)
		)
	lines.append("\nCommit: %s" % String(session.round_state.settlement_commit_id))
	lines.append("Checkpoint post_settlement: %s" % _checkpoint_label("post_settlement"))
	settlement_text.text = "\n".join(lines)


func _refresh_loot() -> void:
	if session.loot_session == null:
		return
	var loot: LOOT_REWARD_SESSION = session.loot_session
	loot_phase_label.text = "Phase: %s" % String(LOOT_REWARD_SESSION.Phase.keys()[loot.phase])
	var lines: Array[String] = ["[b]Player · Node · Moves · Orb · Ticket · Silver · Bag[/b]"]
	for player: PlayerPhaseState in loot.players:
		var round_loot: RoundLootInventoryState = loot.find_round_loot_state(
			player.player_id
		)
		lines.append(
			(
				"%s · %s · %d · %d · %d · %d · %d"
				% [
					player.player_id,
					player.current_node_id,
					player.remaining_moves,
					player.orb_count,
					player.gacha_ticket_count,
					player.silver_coin_count,
					round_loot.carried_items.size() if round_loot != null else 0
				]
			)
		)
	lines.append("\nReward snapshot: %d nodes" % loot.reward_snapshots.size())
	lines.append("Reward history: %d" % loot.reward_history.size())
	var checkpoint_names: Array[String] = []
	for key_value: Variant in session.checkpoints.keys():
		checkpoint_names.append(String(key_value))
	lines.append("Checkpoints: %s" % ", ".join(checkpoint_names))
	if loot.phase == LOOT_REWARD_SESSION.Phase.LOOT_END_CONFIRMATION_READY:
		lines.append("\n[b]M3 STOP: LOOT_END_CONFIRMATION_READY[/b]")
	loot_state_text.text = "\n".join(lines)
	var item_window := loot.phase == LOOT_REWARD_SESSION.Phase.ITEM_WINDOW
	var movement := loot.phase == LOOT_REWARD_SESSION.Phase.MOVEMENT
	var overflow := loot.phase == LOOT_REWARD_SESSION.Phase.BAG_OVERFLOW_PENDING
	continue_button.disabled = not item_window
	use_item_button.disabled = not item_window
	move_button.disabled = not movement
	discard_button.disabled = not overflow
	skip_button.disabled = not overflow
	_populate_items()


func _populate_items() -> void:
	item_picker.clear()
	if session.loot_session == null or session.loot_session.movement_session == null:
		return
	var movement_player: LootMovementPlayerState = (
		session.loot_session.movement_session.current_player()
	)
	if movement_player == null:
		return
	var player: PlayerPhaseState = session.loot_session.find_player(movement_player.player_id)
	if player == null:
		return
	for entry: Dictionary in player.consumable_inventory:
		var item_id := StringName(entry.get("item_id", ""))
		item_picker.add_item(String(item_id))
		item_picker.set_item_metadata(item_picker.item_count - 1, String(item_id))


func _checkpoint_label(key: String) -> String:
	var value: Variant = session.checkpoints.get(key, {})
	return "PASS" if value is Dictionary and bool(value.get("matches", false)) else "FAIL"


func _show_result(result: Dictionary) -> void:
	var success := bool(result.get("success", false))
	status_label.text = (
		"%s — %s [%s]: %s"
		% [
			"PASS" if success else "BLOCKED",
			String(result.get("code", "UNKNOWN")),
			String(result.get("phase", "UNKNOWN_PHASE")),
			String(result.get("message", "")),
		]
	)
	status_label.modulate = Color(0.55, 1.0, 0.65) if success else Color(1.0, 0.62, 0.52)


func _failure(code: String, message: String) -> Dictionary:
	return {"success": false, "code": code, "message": message}
