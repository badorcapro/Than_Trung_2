class_name Gd3M4RoundCompletionController
extends Control

const SESSION := preload(
	"res://scripts/application/mvp/MvpIntegratedRoundCompletionSession.gd"
)
const CASE_CONTROLLER := preload("res://scripts/presentation/case_gameplay/VSCaseMainController.gd")
const CASE_BOUNDARY := preload("res://scripts/domain/mvp/MvpCaseCompletionBoundary.gd")
const CASE_SCENE := preload("res://scenes/case_gameplay/VSCaseMain.tscn")
const LOOT_SESSION := preload("res://scripts/domain/loot/LootRewardSession.gd")
const MANAGEMENT_SESSION := preload(
	"res://scripts/domain/equipment/EquipmentManagementSession.gd"
)
const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")

var session: SESSION = SESSION.new()
var case_controller: CASE_CONTROLLER

@onready var status_label: Label = %StatusLabel
@onready var case_host: Control = %CaseHost
@onready var settlement_panel: Control = %SettlementPanel
@onready var settlement_text: RichTextLabel = %SettlementText
@onready var loot_panel: Control = %LootPanel
@onready var loot_text: RichTextLabel = %LootText
@onready var confirm_panel: Control = %ConfirmPanel
@onready var confirm_text: RichTextLabel = %ConfirmText
@onready var management_panel: Control = %ManagementPanel
@onready var management_text: RichTextLabel = %ManagementText
@onready var ss_shop_button: Button = %SSShop
@onready var round_end_panel: Control = %RoundEndPanel
@onready var round_end_summary: RichTextLabel = %RoundEndSummary


func _ready() -> void:
	var result: Dictionary = session.build_integrated_fixture()
	_show_result(result)
	if bool(result.get("success", false)):
		_launch_case()


func _launch_case() -> void:
	case_controller = CASE_SCENE.instantiate() as CASE_CONTROLLER
	if case_controller == null:
		_show_result({"success": false, "code": "CASE_SCENE_INVALID", "message": "Case root mismatch"})
		return
	case_controller.configure_integrated_case(session.projected_case_players)
	case_controller.integration_case_completed.connect(_on_case_completed)
	case_host.add_child(case_controller)
	case_controller.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _on_case_completed(boundary_value: RefCounted) -> void:
	var boundary: CASE_BOUNDARY = boundary_value as CASE_BOUNDARY
	var result: Dictionary = session.handle_case_completion(boundary)
	_show_result(result)
	if bool(result.get("success", false)):
		case_host.visible = false
		settlement_panel.visible = true
		_render_settlement()


func _on_continue_to_loot_pressed() -> void:
	var result: Dictionary = session.begin_loot()
	_show_result(result)
	if bool(result.get("success", false)):
		settlement_panel.visible = false
		loot_panel.visible = true
		_refresh_loot()


func _on_continue_item_pressed() -> void:
	_show_result(session.continue_without_item())
	_refresh_loot()


func _on_use_item_pressed() -> void:
	_show_result(session.use_item(&"test_move_plus_1"))
	_refresh_loot()


func _on_move_pressed() -> void:
	_show_result(session.move())
	_refresh_loot()


func _on_skip_overflow_pressed() -> void:
	_show_result(session.resolve_overflow_skip())
	_refresh_loot()


func _on_begin_confirmation_pressed() -> void:
	var result: Dictionary = session.begin_loot_end_confirmation()
	_show_result(result)
	if bool(result.get("success", false)):
		loot_panel.visible = false
		confirm_panel.visible = true
		_refresh_confirmation()


func _on_confirm_loot_end_pressed() -> void:
	if session.equipment_session == null:
		return
	var result: Dictionary = session.confirm_loot_end(session.equipment_session.current_player_id())
	_show_result(result)
	if session.match_state.current_phase == MVP_ENUMS.Phase.EQUIPMENT_MANAGEMENT:
		confirm_panel.visible = false
		management_panel.visible = true
		_refresh_management()
	else:
		_refresh_confirmation()


func _on_grant_equip_pressed() -> void:
	_show_result(session.grant_and_equip_test_relic())
	_refresh_management()


func _on_grant_set_pressed() -> void:
	_show_result(session.grant_and_equip_test_set())
	_refresh_management()


func _on_unequip_pressed() -> void:
	_show_result(session.unequip_relic())
	_refresh_management()


func _on_basic_gacha_pressed() -> void:
	_show_result(session.basic_gacha_roll())
	_refresh_management()


func _on_rate_up_pressed() -> void:
	_show_result(session.rate_up_gacha_roll())
	_refresh_management()


func _on_perfect_pressed() -> void:
	_show_result(session.perfect_gacha_spin())
	_refresh_management()


func _on_choice_pressed() -> void:
	_show_result(session.resolve_pending_choice())
	_refresh_management()


func _on_ss_shop_pressed() -> void:
	_show_result(session.purchase_first_unlocked_ss())
	_refresh_management()


func _on_gold_pressed() -> void:
	_show_result(session.upgrade_equipped_relic_gold())
	_refresh_management()


func _on_purple_pressed() -> void:
	_show_result(session.promote_equipped_relic_purple())
	_refresh_management()


func _on_management_done_pressed() -> void:
	if session.equipment_session == null:
		return
	_show_result(session.mark_management_done(session.equipment_session.current_player_id()))
	_refresh_management()


func _on_commit_round_end_pressed() -> void:
	var result: Dictionary = session.commit_round_end()
	_show_result(result)
	if bool(result.get("success", false)):
		management_panel.visible = false
		round_end_panel.visible = true
		_render_round_end()


func _on_back_pressed() -> void:
	AppFlow.go_to_debug_home()


func _render_settlement() -> void:
	var lines: Array[String] = ["[b]Actual Kỳ Án settlement committed[/b]"]
	for row: Dictionary in session.settlement_summary:
		lines.append("%s [%s] · Orb %+.0f · Ticket %+.0f" % [row.get("display_name", ""), row.get("status", ""), row.get("orb_delta", 0), row.get("ticket_delta", 0)])
	lines.append("Commit: %s" % session.round_state.settlement_commit_id)
	settlement_text.text = "\n".join(lines)


func _refresh_loot() -> void:
	if session.loot_session == null:
		return
	var loot: LOOT_SESSION = session.loot_session
	var lines: Array[String] = ["[b]Actual Loot[/b] · %s" % LOOT_SESSION.Phase.keys()[loot.phase]]
	for player: PlayerPhaseState in loot.players:
		var round_loot: RoundLootInventoryState = loot.find_round_loot_state(
			player.player_id
		)
		lines.append("%s · node=%s · moves=%d · Bag=%d" % [player.player_id, player.current_node_id, player.remaining_moves, round_loot.carried_items.size() if round_loot != null else 0])
	loot_text.text = "\n".join(lines)
	%ContinueItem.disabled = loot.phase != LOOT_SESSION.Phase.ITEM_WINDOW
	%UseItem.disabled = loot.phase != LOOT_SESSION.Phase.ITEM_WINDOW
	%Move.disabled = loot.phase != LOOT_SESSION.Phase.MOVEMENT
	%SkipOverflow.disabled = loot.phase != LOOT_SESSION.Phase.BAG_OVERFLOW_PENDING
	%BeginConfirmation.disabled = loot.phase != LOOT_SESSION.Phase.LOOT_END_CONFIRMATION_READY


func _refresh_confirmation() -> void:
	var management: MANAGEMENT_SESSION = session.equipment_session
	confirm_text.text = "Current: %s\nConfirmed: %s" % [management.current_player_id(), ", ".join(_string_ids(management.confirmed_player_ids))]


func _refresh_management() -> void:
	var management: MANAGEMENT_SESSION = session.equipment_session
	if management == null:
		return
	var lines: Array[String] = ["[b]Actual Equipment/Gacha Management[/b]", "Current: %s" % management.current_player_id()]
	for player: PlayerPhaseState in management.players:
		lines.append("%s · Ticket=%d · EXP=%d · Equipment=%d · done=%s" % [player.player_id, player.gacha_ticket_count, player.equipment_exp_material_count, player.equipment_collection.size(), management.done_player_ids.has(player.player_id)])
	lines.append("Policy: %s" % session.match_state.open_policy_config_ids.get("perfect_round_end", ""))
	management_text.text = "\n".join(lines)
	ss_shop_button.disabled = not session.can_purchase_first_unlocked_ss()
	ss_shop_button.tooltip_text = "Unlock and select a valid SS Equipment first" if ss_shop_button.disabled else "Purchase the first unlocked SS Equipment (TEST_ONLY currency)"
	%CommitRoundEnd.disabled = management.phase != MANAGEMENT_SESSION.Phase.READY_FOR_M6


func _render_round_end() -> void:
	round_end_summary.text = "[b]NEXT_CASE_REQUIRED[/b]\nCommit: %s\nRound: %d → %d\nActive Round cleared: %s\nM4 STOP — no next Case selected" % [session.round_end_summary.get("commit_id", ""), session.round_end_summary.get("round_before", 0), session.round_end_summary.get("round_after", 0), session.round_end_summary.get("active_round_cleared", false)]


func _show_result(result: Dictionary) -> void:
	var success: bool = bool(result.get("success", false))
	status_label.text = "%s — %s: %s" % ["PASS" if success else "BLOCKED", result.get("code", "UNKNOWN"), result.get("message", "")]
	status_label.modulate = Color(0.55, 1.0, 0.65) if success else Color(1.0, 0.62, 0.52)


func _string_ids(ids: Array[StringName]) -> Array[String]:
	var result: Array[String] = []
	for id: StringName in ids:
		result.append(String(id))
	return result
