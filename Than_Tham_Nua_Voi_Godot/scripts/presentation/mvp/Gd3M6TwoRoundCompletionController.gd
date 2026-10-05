class_name Gd3M6TwoRoundCompletionController
extends Control

const SESSION := preload(
	"res://scripts/application/mvp/MvpIntegratedTwoRoundCompletionSession.gd"
)
const LOOT_SESSION := preload("res://scripts/domain/loot/LootRewardSession.gd")
const MANAGEMENT_SESSION := preload(
	"res://scripts/domain/equipment/EquipmentManagementSession.gd"
)
const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const PLAYER_PHASE_STATE := preload(
	"res://scripts/domain/characters/PlayerPhaseState.gd"
)

var session: SESSION = SESSION.new()

@onready var status_label: Label = %StatusLabel
@onready var state_text: RichTextLabel = %StateText
@onready var continue_item_button: Button = %ContinueItem
@onready var use_item_button: Button = %UseItem
@onready var move_button: Button = %Move
@onready var skip_overflow_button: Button = %SkipOverflow
@onready var begin_confirmation_button: Button = %BeginConfirmation
@onready var confirm_button: Button = %ConfirmLootEnd
@onready var grant_equip_button: Button = %GrantEquip
@onready var basic_gacha_button: Button = %BasicGacha
@onready var management_done_button: Button = %ManagementDone
@onready var commit_round_end_button: Button = %CommitRoundEnd


func _ready() -> void:
	var result: Dictionary = session.build_at_round2_loot_initialized()
	_show_result(result)
	_refresh()


func _on_continue_item_pressed() -> void:
	_show_result(session.continue_without_item())
	_refresh()


func _on_use_item_pressed() -> void:
	_show_result(session.use_item(&"test_move_plus_1"))
	_refresh()


func _on_move_pressed() -> void:
	_show_result(session.move())
	_refresh()


func _on_skip_overflow_pressed() -> void:
	_show_result(session.resolve_overflow_skip())
	_refresh()


func _on_begin_confirmation_pressed() -> void:
	_show_result(session.begin_round2_loot_end_confirmation())
	_refresh()


func _on_confirm_loot_end_pressed() -> void:
	if session.equipment_session == null:
		_show_result({"success": false, "code": "CONFIRMATION_SESSION_MISSING", "message": "Begin confirmation first"})
		return
	_show_result(
		session.confirm_round2_loot_end(session.equipment_session.current_player_id())
	)
	_refresh()


func _on_grant_equip_pressed() -> void:
	_show_result(session.grant_and_equip_test_relic())
	_refresh()


func _on_basic_gacha_pressed() -> void:
	_show_result(session.basic_gacha_roll())
	_refresh()


func _on_management_done_pressed() -> void:
	if session.equipment_session == null:
		_show_result({"success": false, "code": "MANAGEMENT_SESSION_MISSING", "message": "Management is not active"})
		return
	_show_result(
		session.mark_round2_management_done(session.equipment_session.current_player_id())
	)
	_refresh()


func _on_commit_round_end_pressed() -> void:
	_show_result(session.commit_round2_end())
	_refresh()


func _on_duplicate_round_end_pressed() -> void:
	_show_result(session.commit_round2_end())
	_refresh()


func _on_back_pressed() -> void:
	AppFlow.go_to_debug_home()


func _refresh() -> void:
	var lines: Array[String] = [
		"[b]GĐ3-M6 — Bounded Two-Round Completion[/b]",
		"TEST_ONLY / PROTOTYPE / NOT_CANON_LOCKED",
		"",
	]
	if session.match_state == null:
		lines.append("MatchState missing")
		state_text.text = "\n".join(lines)
		_set_actions_disabled()
		return
	lines.append("Round number: %d" % session.match_state.current_round_number)
	lines.append("Match phase: %s" % MVP_ENUMS.phase_name(session.match_state.current_phase))
	lines.append("Match status: %s" % String(session.match_state.match_completion_state))
	lines.append("Active Round: %s" % ("YES" if session._orchestrator.active_round != null else "NO"))
	if session.loot_session != null:
		lines.append("")
		lines.append("[b]Actual Round 2 Loot[/b] · %s" % LOOT_SESSION.Phase.keys()[session.loot_session.phase])
		for player: PLAYER_PHASE_STATE in session.loot_session.players:
			var round_loot: RoundLootInventoryState = (
				session.loot_session.find_round_loot_state(player.player_id)
			)
			lines.append(
				"%s · node=%s · moves=%d · Bag=%d"
				% [
					String(player.player_id),
					String(player.current_node_id),
					player.remaining_moves,
					round_loot.carried_items.size() if round_loot != null else 0,
				]
			)
	if session.equipment_session != null:
		lines.append("")
		lines.append("[b]Confirmation / Equipment Management[/b]")
		lines.append("Session phase: %s" % MANAGEMENT_SESSION.Phase.keys()[session.equipment_session.phase])
		lines.append("Current player: %s" % String(session.equipment_session.current_player_id()))
		lines.append("Confirmed: %s" % ", ".join(_string_ids(session.equipment_session.confirmed_player_ids)))
		lines.append("Management Done: %s" % ", ".join(_string_ids(session.equipment_session.done_player_ids)))
	if not session.round2_end_summary.is_empty():
		lines.append("")
		lines.append("[b][color=#76d99a]NEXT_CASE_REQUIRED[/color][/b]")
		lines.append("Commit: %s" % String(session.round2_end_summary.get("commit_id", "")))
		lines.append(
			"Round: %d → %d"
			% [
				int(session.round2_end_summary.get("round_before", 0)),
				int(session.round2_end_summary.get("round_after", 0)),
			]
		)
		lines.append("Active Round cleared: %s" % str(session.round2_end_summary.get("active_round_cleared", false)))
		lines.append("Round 3 created: %s" % str(session.round2_end_summary.get("round3_created", true)))
		lines.append("MATCH_COMPLETE: %s" % str(session.round2_end_summary.get("match_complete", true)))
	lines.append("")
	lines.append("[b]Semantic checkpoints[/b]")
	for key: String in [
		"round2_loot_initialized",
		"round2_loot_finished",
		"round2_confirmation_complete",
		"round2_management_complete",
		"round2_pre_round_end",
		"round2_post_round_end",
	]:
		var value: Variant = session.checkpoints.get(key, {})
		var passed: bool = value is Dictionary and bool((value as Dictionary).get("matches", false))
		lines.append("%s: %s" % [key, "PASS" if passed else "PENDING"])
	state_text.text = "\n".join(lines)
	_refresh_actions()


func _refresh_actions() -> void:
	var loot_phase: int = session.loot_session.phase if session.loot_session != null else -1
	continue_item_button.disabled = loot_phase != LOOT_SESSION.Phase.ITEM_WINDOW
	use_item_button.disabled = loot_phase != LOOT_SESSION.Phase.ITEM_WINDOW
	move_button.disabled = loot_phase != LOOT_SESSION.Phase.MOVEMENT
	skip_overflow_button.disabled = loot_phase != LOOT_SESSION.Phase.BAG_OVERFLOW_PENDING
	begin_confirmation_button.disabled = (
		loot_phase != LOOT_SESSION.Phase.LOOT_END_CONFIRMATION_READY
		or session.equipment_session != null
	)
	confirm_button.disabled = (
		session.equipment_session == null
		or session.equipment_session.phase != MANAGEMENT_SESSION.Phase.LOOT_END_CONFIRMATION
	)
	var management_active: bool = (
		session.equipment_session != null
		and session.equipment_session.phase == MANAGEMENT_SESSION.Phase.EQUIPMENT_MANAGEMENT
	)
	grant_equip_button.disabled = not management_active
	basic_gacha_button.disabled = not management_active
	management_done_button.disabled = not management_active
	commit_round_end_button.disabled = (
		session.equipment_session == null
		or session.equipment_session.phase != MANAGEMENT_SESSION.Phase.READY_FOR_M6
	)


func _set_actions_disabled() -> void:
	for button: Button in [
		continue_item_button,
		use_item_button,
		move_button,
		skip_overflow_button,
		begin_confirmation_button,
		confirm_button,
		grant_equip_button,
		basic_gacha_button,
		management_done_button,
		commit_round_end_button,
	]:
		button.disabled = true


func _show_result(result: Dictionary) -> void:
	var success: bool = bool(result.get("success", false))
	status_label.text = "%s — %s: %s" % [
		"PASS" if success else "BLOCKED",
		String(result.get("code", "UNKNOWN")),
		String(result.get("message", "")),
	]
	status_label.modulate = Color(0.55, 1.0, 0.65) if success else Color(1.0, 0.62, 0.52)


func _string_ids(ids: Array[StringName]) -> Array[String]:
	var result: Array[String] = []
	for id: StringName in ids:
		result.append(String(id))
	return result
