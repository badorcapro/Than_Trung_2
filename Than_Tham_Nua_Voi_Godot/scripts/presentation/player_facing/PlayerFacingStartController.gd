class_name PlayerFacingStartController
extends Control

const SETUP_SESSION := preload(
	"res://scripts/application/player_facing/PlayerFacingSetupSession.gd"
)
const CHARACTER_DEFINITION := preload(
	"res://scripts/domain/characters/CharacterDefinition.gd"
)
const CASE_FLOW_SESSION := preload(
	"res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd"
)
const CASE_CONTROLLER := preload(
	"res://scripts/presentation/case_gameplay/VSCaseMainController.gd"
)
const CASE_BOUNDARY := preload(
	"res://scripts/domain/mvp/MvpCaseCompletionBoundary.gd"
)
const PLAYER_PHASE_STATE := preload(
	"res://scripts/domain/characters/PlayerPhaseState.gd"
)
const LOOT_MOVEMENT_PLAYER_STATE := preload(
	"res://scripts/domain/loot/LootMovementPlayerState.gd"
)
const REWARD_RESOLUTION_RESULT := preload(
	"res://scripts/domain/loot/RewardResolutionResult.gd"
)
const LOOT_MAP_VIEW := preload(
	"res://scripts/presentation/player_facing/PlayerFacingLootMapView.gd"
)
const LOOT_REWARD_SESSION := preload(
	"res://scripts/domain/loot/LootRewardSession.gd"
)
const CASE_SCENE := preload("res://scenes/case_gameplay/VSCaseMain.tscn")
const MATCH_RULES := preload("res://scripts/domain/mvp/MatchRules.gd")
const EQUIPMENT_INSTANCE := preload("res://scripts/domain/equipment/EquipmentInstance.gd")
const EQUIPMENT_DEFINITION := preload("res://scripts/domain/equipment/EquipmentDefinition.gd")
const EQUIPMENT_ENUMS := preload("res://scripts/domain/equipment/EquipmentEnums.gd")
const EQUIPMENT_SESSION := preload(
	"res://scripts/domain/equipment/EquipmentManagementSession.gd"
)
const EQUIPMENT_SERVICE := preload(
	"res://scripts/application/equipment/EquipmentManagementService.gd"
)
const PLAYER_FACING_AUTOSAVE_SERVICE := preload(
	"res://scripts/application/player_facing/PlayerFacingAutosaveService.gd"
)
const MVP_MATCH_STATE := preload("res://scripts/domain/mvp/MvpMatchState.gd")
const CHARACTER_DETAIL_SHEET := preload(
	"res://scripts/presentation/player_facing/CharacterDetailSheet.gd"
)

var setup: SETUP_SESSION = SETUP_SESSION.new()
var case_flow: CASE_FLOW_SESSION
var case_controller: CASE_CONTROLLER
var _loot_activity_lines: Array[String] = []
var _logged_reward_count := 0
var _selected_branch_id: StringName = &""
var _is_rolling_dice: bool = false
var _pummel_style_normal: StyleBoxFlat
var _pummel_style_active: StyleBoxFlat
var _pummel_slot_style: StyleBoxFlat
var _hotbar_items: Array[Dictionary] = []
var _item_tray_open: bool = false
var _pending_replace_index: int = -1
var _character_sheet: CharacterDetailSheet = null
var _card_held_player_id: StringName = &""
var _card_hold_token: int = 0
var _autosave_service: PLAYER_FACING_AUTOSAVE_SERVICE = (
	PLAYER_FACING_AUTOSAVE_SERVICE.new()
)
var _cheat_layer: CanvasLayer = null
var _cheat_overlay: Control = null
var _cheat_feedback_lbl: Label = null
var _cheat_player_lbl: Label = null
var _cheat_target_player_index: int = 0

@onready var main_menu: Control = %MainMenu
@onready var continue_button: Button = (
	$SafeMargin/Page/Content/MainMenu/Buttons/Continue
)
@onready var match_mode: Control = %MatchMode
@onready var match_rules_panel: Control = %MatchRulesPanel
@onready var player_count: Control = %PlayerCount
@onready var match_rules_summary: Label = %MatchRulesSummary
@onready var custom_rules: Control = %CustomRules
@onready var victory_type_selector: OptionButton = %VictoryTypeSelector
@onready var rank_row: Control = %RankRow
@onready var target_rank_selector: OptionButton = %TargetRankSelector
@onready var round_row: Control = %RoundRow
@onready var round_limit_selector: OptionButton = %RoundLimitSelector
@onready var character_selection: Control = %CharacterSelection
@onready var pass_device: Control = %PassDevice
@onready var lineup_confirmation: Control = %LineupConfirmation
@onready var case_selection: Control = %CaseSelection
@onready var settings_panel: Control = %SettingsPanel
@onready var message_label: Label = %MessageLabel
@onready var round_indicator: Label = %RoundIndicator
@onready var character_grid: GridContainer = %CharacterGrid
@onready var current_player_label: Label = %CurrentPlayerLabel
@onready var character_details: RichTextLabel = %CharacterDetails
@onready var choose_character_button: Button = %ChooseCharacterButton
@onready var pass_device_label: Label = %PassDeviceLabel
@onready var lineup_text: RichTextLabel = %LineupText
@onready var case_title: Label = %CaseTitle
@onready var case_description: Label = %CaseDescription
@onready var case_reward: Label = %CaseReward
@onready var case_host: Control = %CaseHost
@onready var results_panel: Control = %ResultsPanel
@onready var results_text: RichTextLabel = %ResultsText
@onready var safe_margin: Control = %SafeMargin
@onready var loot_ready_panel: Control = %LootReadyPanel
@onready var loot_panel: Control = %LootPanel
@onready var loot_text: RichTextLabel = %LootText
@onready var loot_map_view: LOOT_MAP_VIEW = %LootMapView
@onready var active_turn_label: Label = %ActiveTurnLabel
@onready var action_guide: Label = %ActionGuide
@onready var resource_summary: Label = %ResourceSummary
@onready var bag_summary: Label = %BagSummary
@onready var activity_log: RichTextLabel = %ActivityLog
@onready var item_window_panel: Control = %ItemWindowPanel
@onready var item_source_selector: OptionButton = %ItemSourceSelector
@onready var use_item_button: Button = %UseItem
@onready var continue_without_item_button: Button = %ContinueWithoutItem
@onready var branch_panel: Control = %BranchPanel
@onready var branch_title: Label = %BranchTitle
@onready var branch_buttons_container: HBoxContainer = %BranchButtonsContainer
@onready var move_button: Button = get_node_or_null("%Move") as Button
@onready var toggle_detail_button: Button = get_node_or_null("%ToggleDetailButton") as Button
@onready var loot_detail_panel: Control = %LootDetailPanel
@onready var overflow_panel: Control = %OverflowPanel
@onready var overflow_text: Label = %OverflowText
@onready var overflow_target_selector: OptionButton = %OverflowTargetSelector
@onready var overflow_replace_button: Button = %OverflowReplace
@onready var overflow_skip_button: Button = %OverflowSkip
@onready var dice_roll_overlay: CenterContainer = %DiceRollOverlay
@onready var dice_card: Control = %DiceCard
@onready var dice_icon_label: Label = %DiceIconLabel
@onready var dice_result_label: RichTextLabel = %DiceResultLabel
@onready var player_cards_container: HBoxContainer = get_node_or_null("%PlayerCardsContainer") as HBoxContainer
@onready var item_hotbar_container: HBoxContainer = get_node_or_null("%ItemHotbarContainer") as HBoxContainer
@onready var roll_dice_button: Button = get_node_or_null("%RollDiceButton") as Button
@onready var incoming_item_label: Label = get_node_or_null("%IncomingItemLabel") as Label
@onready var current_items_container: HBoxContainer = get_node_or_null("%CurrentItemsContainer") as HBoxContainer
@onready var replace_confirm_modal: Control = get_node_or_null("%ReplaceConfirmModal") as Control
@onready var replace_confirm_prompt: Label = get_node_or_null("%ReplaceConfirmPrompt") as Label
@onready var replace_confirm_sub: Label = get_node_or_null("%ReplaceConfirmSub") as Label
@onready var confirm_replace_button: Button = get_node_or_null("%ConfirmReplaceButton") as Button
@onready var cancel_replace_button: Button = get_node_or_null("%CancelReplaceButton") as Button
@onready var confirmation_panel: Control = %LootConfirmationPanel
@onready var confirmation_text: RichTextLabel = %ConfirmationText
@onready var equipment_panel: Control = %EquipmentPanel
@onready var equipment_text: RichTextLabel = %EquipmentText
@onready var equipment_slot_selector: OptionButton = %EquipmentSlotSelector
@onready var owned_equipment_selector: OptionButton = %OwnedEquipmentSelector
@onready var equipment_selection_label: Label = %EquipmentSelectionLabel
@onready var equip_selected_equipment_button: Button = %EquipSelectedEquipment
@onready var unequip_selected_slot_button: Button = %UnequipSelectedSlot
@onready var equipment_progression_label: Label = %EquipmentProgressionLabel
@onready var purple_duplicate_selector: OptionButton = %PurpleDuplicateSelector
@onready var upgrade_equipment_gold_button: Button = %UpgradeEquipmentGold
@onready var upgrade_equipment_purple_button: Button = %UpgradeEquipmentPurple
@onready var basic_gacha_button: Button = %BasicGacha
@onready var rate_up_gacha_button: Button = %RateUpGacha
@onready var perfect_gacha_button: Button = %PerfectGacha
@onready var perfect_choice_panel: Control = %PerfectChoicePanel
@onready var perfect_choice_title: Label = %PerfectChoiceTitle
@onready var perfect_choice_selector: OptionButton = %PerfectChoiceSelector
@onready var resolve_choice_button: Button = %ResolveChoice
@onready var management_done_button: Button = %ManagementDone
@onready var round_summary_ready_panel: Control = %RoundSummaryReadyPanel
@onready var round_summary_panel: Control = %RoundSummaryPanel
@onready var round_summary_text: RichTextLabel = %RoundSummaryText
@onready var next_case_panel: Control = %NextCasePanel
@onready var next_case_title: Label = %NextCaseTitle
@onready var next_case_description: Label = %NextCaseDescription
@onready var next_case_status: Label = %NextCaseStatus
@onready var next_case_options: GridContainer = %NextCaseOptions
@onready var next_case_option_1: Button = %NextCaseOption1
@onready var next_case_option_2: Button = %NextCaseOption2
@onready var next_case_option_3: Button = %NextCaseOption3
@onready var start_next_case_button: Button = %StartNextCase
@onready var match_results_panel: Control = %MatchResultsPanel
@onready var match_results_text: RichTextLabel = %MatchResultsText


func _ready() -> void:
	if loot_map_view != null:
		loot_map_view.node_clicked.connect(_on_map_node_clicked)
	_init_pummel_styles()
	if roll_dice_button != null and not roll_dice_button.pressed.is_connected(_on_move_pressed):
		roll_dice_button.pressed.connect(_on_move_pressed)
	if confirm_replace_button != null and not confirm_replace_button.pressed.is_connected(_on_confirm_replace_accepted):
		confirm_replace_button.pressed.connect(_on_confirm_replace_accepted)
	if cancel_replace_button != null and not cancel_replace_button.pressed.is_connected(_on_cancel_replace_dismissed):
		cancel_replace_button.pressed.connect(_on_cancel_replace_dismissed)
	_build_match_rule_options()
	_build_character_buttons()
	_build_equipment_slot_options()
	_refresh_continue_button()
	var sheet_layer := CanvasLayer.new()
	sheet_layer.name = "CharacterDetailSheetLayer"
	sheet_layer.layer = 120
	add_child(sheet_layer)
	_character_sheet = CHARACTER_DETAIL_SHEET.new()
	_character_sheet.visible = false
	_character_sheet.finish_equipment_phase_requested.connect(_on_finish_equipment_phase_confirmed)
	sheet_layer.add_child(_character_sheet)
	_init_cheat_layer()
	_show_phase(SETUP_SESSION.Phase.MAIN_MENU)


func _init_pummel_styles() -> void:
	_pummel_style_normal = StyleBoxFlat.new()
	_pummel_style_normal.bg_color = Color(0.07, 0.08, 0.11, 0.88)
	_pummel_style_normal.border_width_left = 1
	_pummel_style_normal.border_width_top = 1
	_pummel_style_normal.border_width_right = 1
	_pummel_style_normal.border_width_bottom = 1
	_pummel_style_normal.border_color = Color(0.35, 0.4, 0.45, 0.4)
	_pummel_style_normal.corner_radius_top_left = 8
	_pummel_style_normal.corner_radius_top_right = 8
	_pummel_style_normal.corner_radius_bottom_right = 8
	_pummel_style_normal.corner_radius_bottom_left = 8
	_pummel_style_normal.content_margin_left = 12.0
	_pummel_style_normal.content_margin_top = 6.0
	_pummel_style_normal.content_margin_right = 12.0
	_pummel_style_normal.content_margin_bottom = 6.0

	_pummel_style_active = StyleBoxFlat.new()
	_pummel_style_active.bg_color = Color(0.12, 0.13, 0.18, 0.96)
	_pummel_style_active.border_width_left = 2
	_pummel_style_active.border_width_top = 2
	_pummel_style_active.border_width_right = 2
	_pummel_style_active.border_width_bottom = 2
	_pummel_style_active.border_color = Color(1.0, 0.84, 0.2, 0.95)
	_pummel_style_active.corner_radius_top_left = 8
	_pummel_style_active.corner_radius_top_right = 8
	_pummel_style_active.corner_radius_bottom_right = 8
	_pummel_style_active.corner_radius_bottom_left = 8
	_pummel_style_active.shadow_color = Color(1.0, 0.8, 0.1, 0.35)
	_pummel_style_active.shadow_size = 8
	_pummel_style_active.content_margin_left = 12.0
	_pummel_style_active.content_margin_top = 6.0
	_pummel_style_active.content_margin_right = 12.0
	_pummel_style_active.content_margin_bottom = 6.0

	_pummel_slot_style = StyleBoxFlat.new()
	_pummel_slot_style.bg_color = Color(0.09, 0.1, 0.14, 0.9)
	_pummel_slot_style.border_width_left = 1
	_pummel_slot_style.border_width_top = 1
	_pummel_slot_style.border_width_right = 1
	_pummel_slot_style.border_width_bottom = 1
	_pummel_slot_style.border_color = Color(0.78, 0.65, 0.35, 0.55)
	_pummel_slot_style.corner_radius_top_left = 8
	_pummel_slot_style.corner_radius_top_right = 8
	_pummel_slot_style.corner_radius_bottom_right = 8
	_pummel_slot_style.corner_radius_bottom_left = 8


func _input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return
	if key_event.keycode == KEY_F12:
		AppFlow.go_to_debug_home()
		get_viewport().set_input_as_handled()
		return
	if key_event.keycode == KEY_F10:
		_toggle_cheat_menu()
		get_viewport().set_input_as_handled()
		return
	if _cheat_overlay != null and _cheat_overlay.visible:
		if key_event.keycode == KEY_ESCAPE:
			_cheat_overlay.visible = false
			get_viewport().set_input_as_handled()
			return
	if _character_sheet != null and _character_sheet.visible:
		if key_event.keycode == KEY_ESCAPE or key_event.keycode == KEY_C:
			_character_sheet.visible = false
		get_viewport().set_input_as_handled()
		return
	if setup.phase == SETUP_SESSION.Phase.LOOT_ACTIVE and case_flow != null and case_flow.loot_session != null:
		var focus: Control = get_viewport().gui_get_focus_owner()
		if focus is LineEdit or focus is TextEdit:
			return
		if key_event.keycode == KEY_C:
			_toggle_character_detail_sheet()
			get_viewport().set_input_as_handled()
			return
		if key_event.keycode == KEY_TAB or key_event.keycode == KEY_I:
			_toggle_loot_detail_panel()
			get_viewport().set_input_as_handled()
			return
		if key_event.keycode == KEY_Z:
			_handle_loot_z_press()
			get_viewport().set_input_as_handled()
			return
		if key_event.keycode == KEY_1:
			_try_use_hotbar_item(0)
			get_viewport().set_input_as_handled()
			return
		if key_event.keycode == KEY_2:
			_try_use_hotbar_item(1)
			get_viewport().set_input_as_handled()
			return
		if key_event.keycode == KEY_3:
			_try_use_hotbar_item(2)
			get_viewport().set_input_as_handled()
			return
		if key_event.keycode == KEY_SPACE:
			if loot_map_view != null:
				loot_map_view.focus_active_player()
				get_viewport().set_input_as_handled()
				return


func _on_new_game_pressed() -> void:
	setup.begin_new_game()
	_show_phase(setup.phase)
	_show_message("Chọn chế độ trận đấu.")


func _on_continue_pressed() -> void:
	var loaded: Dictionary = _autosave_service.load_match()
	if not bool(loaded.get("success", false)):
		_refresh_continue_button()
		_show_message("Không có trận đấu đã lưu hợp lệ.", true)
		return
	var saved_match: MVP_MATCH_STATE = loaded.get("match_state") as MVP_MATCH_STATE
	if saved_match.match_completion_state == &"MATCH_COMPLETE":
		var completed_setup: SETUP_SESSION = SETUP_SESSION.new()
		var completed: Dictionary = completed_setup.restore_completed_match(saved_match)
		if not bool(completed.get("success", false)):
			_refresh_continue_button()
			_show_message("Không thể khôi phục kết quả Trận.", true)
			return
		_clear_active_match()
		setup = completed_setup
		_render_match_results()
		_show_phase(setup.phase)
		_show_message("Trận đã hoàn tất được khôi phục.")
		return

	var restored_flow: CASE_FLOW_SESSION = CASE_FLOW_SESSION.new()
	var restored: Dictionary = restored_flow.restore_player_facing_between_rounds(
		saved_match
	)
	if not bool(restored.get("success", false)):
		_refresh_continue_button()
		_show_message("Không thể khôi phục Trận giữa các Round.", true)
		return
	var prepared: Dictionary = restored_flow.prepare_default_next_case_options()
	if not bool(prepared.get("success", false)):
		_show_message("Chưa thể chuẩn bị ba Kỳ Án tiếp theo.", true)
		return
	var restored_setup: SETUP_SESSION = SETUP_SESSION.new()
	var presented: Dictionary = restored_setup.restore_between_rounds(
		restored_flow.match_state
	)
	if not bool(presented.get("success", false)):
		_show_message("Không thể mở lựa chọn Kỳ Án tiếp theo.", true)
		return
	_clear_active_match()
	setup = restored_setup
	case_flow = restored_flow
	_refresh_next_case()
	_show_phase(setup.phase)
	_show_message("Trận đã được khôi phục. Hãy chọn Kỳ Án tiếp theo.")


func _on_classic_mode_pressed() -> void:
	_show_match_rules_result(setup.choose_match_mode(MATCH_RULES.Mode.CLASSIC))


func _on_custom_mode_pressed() -> void:
	_show_match_rules_result(setup.choose_match_mode(MATCH_RULES.Mode.CUSTOM))


func _on_match_mode_back_pressed() -> void:
	setup.return_to_main_menu()
	_show_phase(setup.phase)


func _on_match_rules_back_pressed() -> void:
	var result: Dictionary = setup.back_to_match_mode()
	if bool(result.get("success", false)):
		_show_phase(setup.phase)


func _on_match_rules_continue_pressed() -> void:
	var result: Dictionary = setup.confirm_match_rules()
	if not bool(result.get("success", false)):
		_show_message("Luật chiến thắng chưa hợp lệ.", true)
		return
	_show_phase(setup.phase)
	_show_message("Chọn số người tham gia trận đấu.")


func _on_victory_type_selected(index: int) -> void:
	var victory_type: int = int(victory_type_selector.get_item_metadata(index))
	if bool(setup.choose_victory_type(victory_type).get("success", false)):
		_refresh_match_rules()


func _on_target_rank_selected(index: int) -> void:
	var rank_id: StringName = StringName(target_rank_selector.get_item_metadata(index))
	if bool(setup.choose_target_court_rank(rank_id).get("success", false)):
		_refresh_match_rules()


func _on_round_limit_selected(index: int) -> void:
	var round_limit: int = int(round_limit_selector.get_item_metadata(index))
	if bool(setup.choose_round_limit(round_limit).get("success", false)):
		_refresh_match_rules()


func _on_player_count_back_pressed() -> void:
	var result: Dictionary = setup.back_to_match_rules()
	if bool(result.get("success", false)):
		_refresh_match_rules()
		_show_phase(setup.phase)


func _on_three_players_pressed() -> void:
	var result: Dictionary = setup.choose_player_count(3)
	if not bool(result.get("success", false)):
		_show_message("Không thể bắt đầu thiết lập người chơi.", true)
		return
	_show_phase(setup.phase)
	_refresh_character_selection()


func _on_character_pressed(character_id: StringName) -> void:
	var result: Dictionary = setup.select_character(character_id)
	if not bool(result.get("success", false)):
		_show_message("Nhân vật này hiện chưa thể được chọn.", true)
		return
	_refresh_character_selection()


func _on_choose_character_pressed() -> void:
	var result: Dictionary = setup.lock_current_character()
	if not bool(result.get("success", false)):
		_show_message("Hãy chọn một nhân vật trước khi tiếp tục.", true)
		return
	if setup.phase == SETUP_SESSION.Phase.PASS_DEVICE:
		pass_device_label.text = "Đưa thiết bị cho Người chơi %d" % (
			setup.selection_session.current_seat_index + 1
		)
	elif setup.phase == SETUP_SESSION.Phase.LINEUP_CONFIRMATION:
		_refresh_lineup()
	_show_phase(setup.phase)


func _on_pass_continue_pressed() -> void:
	var result: Dictionary = setup.continue_after_pass_device()
	if not bool(result.get("success", false)):
		_show_message("Chưa thể chuyển sang người chơi tiếp theo.", true)
		return
	_show_phase(setup.phase)
	_refresh_character_selection()


func _on_edit_lineup_pressed() -> void:
	var result: Dictionary = setup.edit_last_selection()
	if not bool(result.get("success", false)):
		_show_message("Đội hình hiện không thể chỉnh sửa.", true)
		return
	_show_phase(setup.phase)
	_refresh_character_selection()


func _on_confirm_lineup_pressed() -> void:
	var result: Dictionary = setup.confirm_lineup()
	if not bool(result.get("success", false)):
		_show_message("Không thể xác nhận đội hình. Vui lòng kiểm tra lại.", true)
		return
	var candidate_flow: CASE_FLOW_SESSION = CASE_FLOW_SESSION.new()
	var initialized: Dictionary = candidate_flow.initialize_player_facing_case_options(
		setup.match_state
	)
	if not bool(initialized.get("success", false)):
		_show_message("Chưa thể chuẩn bị Kỳ Án sinh tự động đầu tiên.", true)
		return
	var prepared_options: Dictionary = candidate_flow.prepare_default_next_case_options()
	if not bool(prepared_options.get("success", false)):
		_show_message("Chưa thể chuẩn bị ba lựa chọn Kỳ Án sinh tự động.", true)
		return
	var presented: Dictionary = setup.mark_first_case_selection_required()
	if not bool(presented.get("success", false)):
		_show_message("Chưa thể mở danh sách Kỳ Án đầu tiên.", true)
		return
	case_flow = candidate_flow
	_refresh_next_case()
	_show_phase(setup.phase)
	_show_message("Đội hình đã sẵn sàng. Hãy chọn một trong ba Kỳ Án đầu tiên.")


func _on_start_case_pressed() -> void:
	if case_flow != null or case_controller != null:
		_show_message("Kỳ Án đang được tiến hành.", true)
		return
	var candidate_controller: CASE_CONTROLLER = CASE_SCENE.instantiate() as CASE_CONTROLLER
	if candidate_controller == null:
		_show_message("Không thể mở Kỳ Án. Vui lòng thử lại.", true)
		return
	var candidate_flow: CASE_FLOW_SESSION = CASE_FLOW_SESSION.new()
	var initialized: Dictionary = candidate_flow.initialize_player_facing_case(
		setup.match_state, setup.available_case
	)
	if not bool(initialized.get("success", false)):
		candidate_controller.free()
		_show_message("Kỳ Án chưa sẵn sàng. Vui lòng kiểm tra lại đội hình.", true)
		return
	var started: Dictionary = setup.mark_case_started()
	if not bool(started.get("success", false)):
		candidate_controller.free()
		_show_message("Kỳ Án đã được mở trước đó.", true)
		return
	case_flow = candidate_flow
	case_controller = candidate_controller
	case_controller.configure_integrated_case(
		case_flow.projected_case_players, true, case_flow.case_definition
	)
	case_controller.integration_case_completed.connect(_on_actual_case_completed)
	case_controller.integration_truth_acknowledged.connect(_on_truth_acknowledged)
	case_host.add_child(case_controller)
	case_controller.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_show_round_indicator(1)
	_show_phase(setup.phase)
	_show_message("")


func _on_start_next_case_pressed() -> void:
	_start_static_next_case()


func _on_next_case_option_1_pressed() -> void:
	_start_next_case_from_option(0)


func _on_next_case_option_2_pressed() -> void:
	_start_next_case_from_option(1)


func _on_next_case_option_3_pressed() -> void:
	_start_next_case_from_option(2)


func _start_static_next_case() -> void:
	if case_flow == null or setup.phase != SETUP_SESSION.Phase.NEXT_CASE_SELECTION:
		_show_message("Kỳ Án tiếp theo chưa sẵn sàng.", true)
		return
	var started: Dictionary = case_flow.start_next_round(setup.available_case.case_id)
	if not bool(started.get("success", false)):
		_show_message(
			"Round tiếp theo đã được bắt đầu hoặc chưa thể khởi tạo.", true
		)
		return
	var presented: Dictionary = setup.mark_next_case_started()
	if not bool(presented.get("success", false)):
		_show_message("Không thể mở Kỳ Án tiếp theo.", true)
		return
	_launch_active_round_case()
	_show_round_indicator(case_flow.round_state.round_number)
	_show_phase(setup.phase)
	_show_message(
		"Round %d bắt đầu. Kỳ Án mới đã sẵn sàng để điều tra."
		% case_flow.active_round_number()
	)


func _start_next_case_from_option(option_index: int) -> void:
	if case_flow == null or setup.phase != SETUP_SESSION.Phase.NEXT_CASE_SELECTION:
		_show_message("Kỳ Án tiếp theo chưa sẵn sàng.", true)
		return
	if not _has_procedural_next_case_options():
		_show_message("Danh sách Kỳ Án sinh tự động chưa sẵn sàng.", true)
		return
	var started: Dictionary = case_flow.start_next_round_from_option(option_index)
	if not bool(started.get("success", false)):
		_show_message(
			"Round tiếp theo đã được bắt đầu hoặc chưa thể khởi tạo.", true
		)
		return
	var presented: Dictionary = setup.mark_next_case_started()
	if not bool(presented.get("success", false)):
		_show_message("Không thể mở Kỳ Án tiếp theo.", true)
		return
	_launch_active_round_case()
	_show_round_indicator(case_flow.round_state.round_number)
	_show_phase(setup.phase)
	_show_message(
		"Round %d bắt đầu. Kỳ Án mới đã sẵn sàng để điều tra."
		% case_flow.active_round_number()
	)


func _launch_active_round_case() -> void:
	if case_controller != null:
		case_controller.queue_free()
	case_controller = CASE_SCENE.instantiate() as CASE_CONTROLLER
	if case_controller == null:
		_show_message("Không thể mở Kỳ Án của Round hiện tại.", true)
		return
	case_controller.configure_integrated_case(
		case_flow.active_case_players(), true, case_flow.active_case_definition
	)
	case_controller.integration_case_completed.connect(_on_actual_case_completed)
	case_controller.integration_truth_acknowledged.connect(_on_truth_acknowledged)
	case_host.add_child(case_controller)
	case_controller.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _on_actual_case_completed(boundary_value: RefCounted) -> void:
	var boundary: CASE_BOUNDARY = boundary_value as CASE_BOUNDARY
	var result: Dictionary = case_flow.handle_case_completion(boundary)
	if not bool(result.get("success", false)):
		_show_message("Không thể ghi nhận kết quả Kỳ Án. Vui lòng thử lại.", true)


func _on_truth_acknowledged() -> void:
	if case_flow == null or not case_flow.round_state.settlement_applied:
		_show_message("Kết quả Kỳ Án chưa sẵn sàng.", true)
		return
	var result: Dictionary = setup.mark_case_results_ready()
	if not bool(result.get("success", false)):
		return
	case_host.visible = false
	_render_case_results()
	_show_phase(setup.phase)


func _on_results_continue_pressed() -> void:
	var result: Dictionary = setup.continue_to_loot_ready()
	if not bool(result.get("success", false)):
		_show_message("Chưa thể chuẩn bị Loot.", true)
		return
	_show_phase(setup.phase)
	_show_message("Kết quả đã được lưu. Loot đã sẵn sàng cho bước tiếp theo.")


func _on_start_loot_pressed() -> void:
	if case_flow == null:
		_show_message("Kết quả Kỳ Án chưa sẵn sàng.", true)
		return
	var result: Dictionary = case_flow.begin_loot()
	if not bool(result.get("success", false)):
		match String(result.get("code", "")):
			"LOOT_SESSION_ALREADY_ACTIVE", "ROUND_2_LOOT_ALREADY_ACTIVE":
				_show_message("Loot đã được bắt đầu.", true)
			"LOOT_INITIALIZATION_FAILED":
				_show_message("Không thể khởi tạo Loot từ đội hình đã chọn.", true)
			_:
				_show_message("Kết quả Kỳ Án chưa hoàn tất để bắt đầu Loot.", true)
		return
	var marked: Dictionary = setup.mark_loot_started()
	if not bool(marked.get("success", false)):
		_show_message("Không thể mở hành trình Loot.", true)
		return
	_show_phase(setup.phase)
	_loot_activity_lines = ["Hành trình bắt đầu. Mỗi người xuất phát từ Nhà của nhân vật mình."]
	_logged_reward_count = 0
	_refresh_loot()


func _on_continue_without_item_pressed() -> void:
	_handle_loot_result(case_flow.continue_without_item())


func _on_use_item_pressed() -> void:
	if item_source_selector.item_count == 0 or item_source_selector.selected < 0:
		_show_message("Túi hiện không có vật phẩm có thể dùng.", true)
		return
	var metadata_value: Variant = item_source_selector.get_item_metadata(
		item_source_selector.selected
	)
	if not metadata_value is Dictionary:
		_show_message("Nguồn vật phẩm không hợp lệ.", true)
		return
	var metadata: Dictionary = metadata_value as Dictionary
	var item_id: StringName = StringName(metadata.get("item_id", ""))
	var source: StringName = StringName(metadata.get("source", ""))
	_handle_loot_result(case_flow.use_item(item_id, source))


func _on_move_pressed() -> void:
	_handle_loot_z_press()


func _on_branch_chosen(chosen_branch_id: StringName) -> void:
	_selected_branch_id = &""
	if dice_roll_overlay != null and dice_roll_overlay.visible:
		dice_roll_overlay.visible = false
		dice_roll_overlay.modulate.a = 1.0
	_handle_loot_result(case_flow.choose_branch(chosen_branch_id))


func _on_toggle_detail_button_pressed() -> void:
	_toggle_loot_detail_panel()


func _toggle_loot_detail_panel() -> void:
	_item_tray_open = not _item_tray_open
	if item_window_panel != null:
		item_window_panel.visible = _item_tray_open
	if loot_detail_panel != null:
		loot_detail_panel.visible = false
	if _item_tray_open and case_flow != null and case_flow.loot_session != null:
		_refresh_pummel_item_hotbar(case_flow.loot_session)
	if toggle_detail_button != null:
		toggle_detail_button.text = "[TAB] Đóng túi" if _item_tray_open else "[TAB] Túi đồ"


func _handle_loot_z_press() -> void:
	if case_flow == null or case_flow.loot_session == null:
		return
	if _is_rolling_dice:
		return
	var session: LOOT_REWARD_SESSION = case_flow.loot_session
	if session.overflow.active:
		_show_message("Túi đang đầy! Hãy chọn thay thế hoặc bỏ vật phẩm mới trước.", true)
		return
	if session.phase == LOOT_REWARD_SESSION.Phase.BRANCH_SELECTION:
		_show_message("Đang ở ngã rẽ! Hãy bấm trực tiếp lên ô cờ vàng trên bản đồ để chọn hướng.", true)
		return

	if session.phase == LOOT_REWARD_SESSION.Phase.ITEM_WINDOW:
		var result: Dictionary = case_flow.continue_without_item()
		if not bool(result.get("success", false)):
			_show_message(String(result.get("error", "Không thể tiếp tục.")), true)
			_refresh_loot()
			return
		_refresh_loot()

	if session.phase != LOOT_REWARD_SESSION.Phase.MOVEMENT:
		return

	_is_rolling_dice = true

	# Thực hiện roll với branch_choice = &"" (không bao giờ tự chọn nhánh trước cho người chơi)
	var move_res: Dictionary = case_flow.move(&"")
	if not bool(move_res.get("success", false)):
		_is_rolling_dice = false
		_handle_loot_result(move_res)
		return

	var is_fork: bool = (session.phase == LOOT_REWARD_SESSION.Phase.BRANCH_SELECTION)
	var roll_val: int = 1
	var fork_steps_walked: int = 0
	var fork_remaining: int = 0

	if is_fork:
		var pending: PendingBranchState = session.movement_session.pending_branch
		if pending != null:
			roll_val = pending.roll_distance
			fork_steps_walked = pending.traversed_node_ids.size()
			fork_remaining = pending.remaining_steps
	else:
		var action: MovementActionResult = move_res.get("action") as MovementActionResult
		if action != null:
			roll_val = action.roll_distance

	await _play_dice_roll_animation(roll_val, is_fork, fork_steps_walked, fork_remaining)

	if is_fork:
		_is_rolling_dice = false
		_refresh_loot()
	else:
		_is_rolling_dice = false
		_handle_loot_result(move_res)


func _play_dice_roll_animation(
	roll_val: int, is_fork: bool, fork_steps_walked: int, fork_remaining: int
) -> void:
	if dice_roll_overlay == null or dice_icon_label == null or dice_result_label == null:
		return
	dice_roll_overlay.visible = true
	dice_roll_overlay.modulate.a = 1.0
	if dice_card != null:
		dice_card.scale = Vector2.ONE
		dice_card.pivot_offset = dice_card.size * 0.5

	var dice_faces: Array[String] = ["⚀ 1", "⚁ 2", "⚂ 3", "⚃ 4", "⚄ 5", "⚅ 6"]
	for i in range(8):
		dice_icon_label.text = dice_faces[randi() % dice_faces.size()]
		dice_result_label.text = "[center][b][color=#8be9fd]Đang gieo xúc xắc...[/color][/b][/center]"
		await get_tree().create_timer(0.05).timeout
		if not is_instance_valid(self):
			return

	var final_face: String = ""
	match roll_val:
		1: final_face = "⚀ 1"
		2: final_face = "⚁ 2"
		3: final_face = "⚂ 3"
		4: final_face = "⚃ 4"
		5: final_face = "⚄ 5"
		6: final_face = "⚅ 6"
		_: final_face = "🎲 %d" % roll_val
	dice_icon_label.text = final_face

	if dice_card != null:
		dice_card.pivot_offset = dice_card.size * 0.5
		var punch_tween: Tween = create_tween()
		punch_tween.tween_property(dice_card, "scale", Vector2(1.18, 1.18), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		punch_tween.tween_property(dice_card, "scale", Vector2.ONE, 0.1)

	if is_fork:
		if fork_steps_walked > 0:
			dice_result_label.text = (
				"[center][b][color=#f1fa8c]ĐÃ ĐỔ RA %d BƯỚC[/color][/b]\n"
				+ "[font_size=13][color=#ffb86c]⚡ Đi %d bước gặp ngã rẽ! (Còn %d bước)\n"
				+ "Bấm chọn ô cờ vàng trên bản đồ để đi tiếp[/color][/font_size][/center]"
			) % [roll_val, fork_steps_walked, fork_remaining]
		else:
			dice_result_label.text = (
				"[center][b][color=#f1fa8c]ĐÃ ĐỔ RA %d BƯỚC[/color][/b]\n"
				+ "[font_size=13][color=#ffb86c]⚡ Đang ở ngã rẽ!\n"
				+ "Bấm chọn ô cờ vàng trên bản đồ để chọn hướng[/color][/font_size][/center]"
			) % roll_val
		var fade_tween: Tween = create_tween()
		fade_tween.tween_interval(2.0)
		fade_tween.tween_property(dice_roll_overlay, "modulate:a", 0.0, 0.4)
		fade_tween.finished.connect(func():
			if is_instance_valid(dice_roll_overlay) and dice_roll_overlay.modulate.a <= 0.05:
				dice_roll_overlay.visible = false
				dice_roll_overlay.modulate.a = 1.0
		)
	else:
		dice_result_label.text = (
			"[center][b][color=#50fa7b]ĐÃ ĐỔ RA %d BƯỚC[/color][/b]\n"
			+ "[font_size=13][color=#cccccc]Đang tiến bước...[/color][/font_size][/center]"
		) % roll_val
		await get_tree().create_timer(0.45).timeout
		if not is_instance_valid(self):
			return
		var fade_tween: Tween = create_tween()
		fade_tween.tween_property(dice_roll_overlay, "modulate:a", 0.0, 0.2)
		await fade_tween.finished
		if is_instance_valid(dice_roll_overlay):
			dice_roll_overlay.visible = false
			dice_roll_overlay.modulate.a = 1.0


func _on_map_node_clicked(node_id: StringName) -> void:
	if setup.phase != SETUP_SESSION.Phase.LOOT_ACTIVE:
		return
	if case_flow == null or case_flow.loot_session == null:
		return
	var session: LOOT_REWARD_SESSION = case_flow.loot_session
	if session.overflow.active:
		return
	if _is_rolling_dice:
		return
	if session.phase == LOOT_REWARD_SESSION.Phase.BRANCH_SELECTION:
		var pending: PendingBranchState = session.movement_session.pending_branch
		if pending != null and pending.available_branch_ids.has(node_id):
			if dice_roll_overlay != null:
				dice_roll_overlay.visible = false
				dice_roll_overlay.modulate.a = 1.0
			_on_branch_chosen(node_id)
			return
		else:
			_show_message("Hãy bấm vào 1 trong các ô cờ vàng trên bản đồ để chọn hướng!", false)
			return
	elif (
		session.phase == LOOT_REWARD_SESSION.Phase.ITEM_WINDOW
		or session.phase == LOOT_REWARD_SESSION.Phase.MOVEMENT
	):
		_show_message("Hãy bấm phím [Z] để đổ xúc xắc trước!", false)
		return


func _on_overflow_discard_pressed() -> void:
	var selected: int = overflow_target_selector.selected
	if selected < 0 or selected >= overflow_target_selector.item_count:
		_show_message("Hãy chọn vật phẩm đang mang cần thay thế.", true)
		_refresh_loot()
		return
	var metadata_value: Variant = overflow_target_selector.get_item_metadata(selected)
	if not metadata_value is Dictionary:
		_show_message("Lựa chọn thay thế không còn hợp lệ.", true)
		_refresh_loot()
		return
	var metadata: Dictionary = metadata_value as Dictionary
	var inventory_index: int = int(metadata.get("inventory_index", -1))
	_handle_loot_result(case_flow.resolve_overflow_discard(inventory_index))


func _on_overflow_skip_pressed() -> void:
	if replace_confirm_modal != null:
		replace_confirm_modal.visible = false
	_pending_replace_index = -1
	_handle_loot_result(case_flow.resolve_overflow_skip())


func _on_overflow_target_selected(_index: int) -> void:
	overflow_replace_button.disabled = overflow_target_selector.selected < 0


func _handle_loot_result(result: Dictionary) -> void:
	if not bool(result.get("success", false)):
		_show_message(_loot_failure_message(String(result.get("code", ""))), true)
		_refresh_loot()
		return
	var action_value: Variant = result.get("action")
	if action_value is MovementActionResult:
		var action: MovementActionResult = action_value
		_loot_activity_lines.append(
			"🎲 [b]%s[/b] đổ xí ngầu được [color=#8be9fd]%d bước[/color]." % [_player_name(action.player_id), action.roll_distance]
		)
		for node_id: StringName in action.traversed_node_ids:
			_loot_activity_lines.append("  ➜ Di chuyển qua: [b]%s[/b]" % _node_display_name(node_id))
		_show_message("Token đã di chuyển theo đường vừa roll.")
	elif String(result.get("code", "")) == "ITEM_WINDOW_CONTINUED":
		_loot_activity_lines.append("Bỏ qua vật phẩm; tiến vào bước di chuyển.")
	elif String(result.get("code", "")) == "ITEM_USED":
		_loot_activity_lines.append("Đã kích hoạt vật phẩm từ Túi hành trang.")
	elif String(result.get("code", "")) == "BRANCH_SELECTION_REQUIRED":
		_loot_activity_lines.append("⚡ Gặp ngã rẽ! Hãy bấm chọn ô cờ vàng trên bản đồ.")
	elif String(result.get("code", "")) == "OVERFLOW_RESOLVED":
		_loot_activity_lines.append("Đã xử lý xong Túi đầy; tiếp tục hành trình.")
	_append_latest_reward_feedback()
	_trim_loot_log()
	if case_flow.loot_session.phase == 4:
		var started: Dictionary = case_flow.begin_loot_end_confirmation()
		if bool(started.get("success", false)):
			if case_flow.equipment_session != null:
				for pid: StringName in case_flow.equipment_session.player_order.duplicate():
					if not case_flow.equipment_session.confirmed_player_ids.has(pid):
						case_flow.confirm_loot_end(pid)
			setup.mark_equipment_management()
			_show_phase(setup.phase)
			_open_character_detail_sheet(&"", true)
			return
	_refresh_loot()


func _on_confirm_loot_end_pressed() -> void:
	var player_id: StringName = case_flow.equipment_session.current_player_id()
	var result: Dictionary = case_flow.confirm_loot_end(player_id)
	if not bool(result.get("success", false)):
		_show_message("Xác nhận chưa được chấp nhận.", true)
		return
	if String(result.get("code", "")) == "EQUIPMENT_MANAGEMENT_STARTED":
		setup.mark_equipment_management()
		_show_phase(setup.phase)
		_refresh_equipment()
	else:
		_refresh_confirmation()


func _on_equipment_slot_selected(_index: int) -> void:
	_refresh_owned_equipment_selector()


func _on_owned_equipment_selected(_index: int) -> void:
	_refresh_equipment_selection_state()


func _on_equip_selected_equipment_pressed() -> void:
	var instance_id: StringName = _selected_owned_equipment_id()
	var slot_id: StringName = _selected_equipment_slot_id()
	_show_management_result(case_flow.equip_owned_equipment(instance_id, slot_id))


func _on_unequip_selected_slot_pressed() -> void:
	_show_management_result(
		case_flow.unequip_equipment_slot(_selected_equipment_slot_id())
	)


func _on_upgrade_equipment_gold_pressed() -> void:
	_show_management_result(
		case_flow.upgrade_owned_equipment_gold(_selected_owned_equipment_id())
	)


func _on_upgrade_equipment_purple_pressed() -> void:
	_show_management_result(
		case_flow.upgrade_owned_equipment_purple(
			_selected_owned_equipment_id(), _selected_purple_duplicate_id()
		)
	)


func _on_basic_gacha_pressed() -> void:
	_show_management_result(case_flow.basic_gacha_roll())


func _on_rate_up_gacha_pressed() -> void:
	_show_management_result(case_flow.rate_up_gacha_roll())


func _on_perfect_gacha_pressed() -> void:
	_show_management_result(case_flow.perfect_gacha_spin())


func _on_perfect_choice_selected(_index: int) -> void:
	resolve_choice_button.disabled = _selected_pending_choice_id().is_empty()


func _on_resolve_choice_pressed() -> void:
	_show_management_result(
		case_flow.resolve_pending_choice(_selected_pending_choice_id())
	)


func _on_management_done_pressed() -> void:
	var player_id: StringName = case_flow.equipment_session.current_player_id()
	var result: Dictionary = case_flow.mark_management_done(player_id)
	if not bool(result.get("success", false)):
		_show_message("Hãy hoàn tất lựa chọn trang bị trước.", true)
		return
	if String(result.get("code", "")) == "MANAGEMENT_COMPLETE":
		setup.mark_round_summary_ready()
		_show_phase(setup.phase)
		_show_message("Mọi người đã hoàn tất chuẩn bị.")
	else:
		_refresh_equipment()


func _on_finish_equipment_phase_confirmed() -> void:
	if case_flow != null and case_flow.equipment_session != null:
		while case_flow.equipment_session.phase == EQUIPMENT_SESSION.Phase.EQUIPMENT_MANAGEMENT:
			var curr_id: StringName = case_flow.equipment_session.current_player_id()
			if curr_id.is_empty():
				break
			var res: Dictionary = case_flow.mark_management_done(curr_id)
			if not bool(res.get("success", false)):
				break
	if _character_sheet != null:
		_character_sheet.visible = false
	setup.mark_round_summary_ready()
	_on_round_summary_pressed()


func _on_round_summary_pressed() -> void:
	var result: Dictionary = setup.open_round_summary()
	if not bool(result.get("success", false)):
		_show_message("Tổng kết Round chưa sẵn sàng.", true)
		return
	_render_round_summary()
	_show_phase(setup.phase)
	_show_message("")


func _on_round_summary_continue_pressed() -> void:
	var committed: Dictionary = case_flow.commit_round_end(
		case_flow.active_player_facing_round_end_commit_id()
	)
	if not bool(committed.get("success", false)):
		_show_message("Round đã được hoàn tất hoặc chưa thể kết thúc.", true)
		return
	var autosaved: Dictionary = _autosave_service.save_match(case_flow.match_state)
	if not bool(autosaved.get("success", false)):
		AppLogger.error(
			"Player-facing autosave failed: %s" % String(autosaved.get("code", "UNKNOWN"))
		)
	_refresh_continue_button()
	if case_flow.match_state.match_completion_state == &"MATCH_COMPLETE":
		var completed: Dictionary = setup.mark_match_complete(case_flow.match_state)
		if not bool(completed.get("success", false)):
			_show_message("Chưa thể mở kết quả Trận.", true)
			return
		_render_match_results()
		_show_phase(setup.phase)
		_show_message("Trận đấu đã hoàn tất.")
		return
	var prepared_options: Dictionary = case_flow.prepare_default_next_case_options()
	if not bool(prepared_options.get("success", false)):
		_show_message("Chưa thể chuẩn bị ba lựa chọn Kỳ Án sinh tự động.", true)
		return
	var presented: Dictionary = setup.mark_next_case_required()
	if not bool(presented.get("success", false)):
		_show_message("Chưa thể mở danh sách Kỳ Án tiếp theo.", true)
		return
	_refresh_next_case()
	_show_phase(setup.phase)
	_show_message("Hãy chọn Kỳ Án tiếp theo khi mọi người đã sẵn sàng.")


func _show_management_result(result: Dictionary) -> void:
	var success: bool = bool(result.get("success", false))
	_show_message(
		"Thao tác đã được ghi nhận." if success else _management_failure_message(
			String(result.get("code", ""))
		),
		not success
	)
	_refresh_equipment()


func _management_failure_message(code: String) -> String:
	match code:
		"NOT_OWNED":
			return "Trang bị này không thuộc kho của người chơi hiện tại."
		"WRONG_SLOT":
			return "Trang bị không phù hợp với vị trí đã chọn."
		"SLOT_EMPTY":
			return "Vị trí này đang trống."
		"PLAYER_MISSING", "MANAGEMENT_PLAYER_MISSING":
			return "Không tìm thấy người chơi đang chuẩn bị trang bị."
		"INSUFFICIENT_TICKETS":
			return "Không đủ Vé cho lượt cầu nguyện này."
		"PENDING_CHOICE_MISSING", "PENDING_CHOICE_EMPTY":
			return "Hiện không có phần thưởng cần chọn."
		"PENDING_CHOICE_SELECTION_REQUIRED":
			return "Hãy chọn đúng một phần thưởng trước khi xác nhận."
		"PENDING_CHOICE_PLAYER_MISMATCH":
			return "Phần thưởng này thuộc lượt chuẩn bị của người chơi khác."
		"PENDING_CHOICE_REJECTED":
			return "Phần thưởng đã chọn không còn hợp lệ."
		"CHOICE_PENDING", "PENDING_CHOICE":
			return "Hãy chọn phần thưởng đang chờ trước khi tiếp tục."
		"POOL_EMPTY", "POOL_EXHAUSTED":
			return "Banner này hiện không còn phần thưởng khả dụng."
		"GOLD_MAX", "PURPLE_MAX":
			return "Trang bị đã đạt cấp tối đa."
		"INSUFFICIENT_EXP":
			return "Không đủ nguyên liệu EXP trang bị."
		"GOLD_PREREQUISITE":
			return "Cấp Vàng chưa đủ cho lần thăng cấp Tím tiếp theo."
		"DUPLICATE_REQUIRED", "DUPLICATE_NOT_OWNED", "WRONG_DUPLICATE":
			return "Cần một bản sao hợp lệ đang sở hữu."
		"DUPLICATE_EQUIPPED":
			return "Không thể dùng bản sao đang được trang bị."
		_:
			return "Thao tác này chưa thể thực hiện trong trạng thái hiện tại."


func _on_settings_pressed() -> void:
	setup.show_settings()
	_show_phase(setup.phase)


func _on_return_main_menu_pressed() -> void:
	_clear_active_match()
	setup.return_to_main_menu()
	_refresh_continue_button()
	_show_phase(setup.phase)
	_show_message("")


func _on_match_replay_pressed() -> void:
	_clear_active_match()
	setup = SETUP_SESSION.new()
	setup.begin_new_game()
	_show_phase(setup.phase)
	_show_message("Hãy chọn luật cho Trận mới.")


func _on_match_results_main_menu_pressed() -> void:
	_clear_active_match()
	setup = SETUP_SESSION.new()
	setup.return_to_main_menu()
	_refresh_continue_button()
	_show_phase(setup.phase)
	_show_message("")


func _clear_active_match() -> void:
	if case_controller != null:
		case_controller.queue_free()
		case_controller = null
	case_flow = null
	_loot_activity_lines.clear()
	_logged_reward_count = 0
	_is_rolling_dice = false
	if dice_roll_overlay != null:
		dice_roll_overlay.visible = false
		dice_roll_overlay.modulate.a = 1.0


func _refresh_continue_button() -> void:
	if continue_button == null:
		return
	var available: bool = _autosave_service.has_valid_autosave()
	continue_button.disabled = not available
	continue_button.tooltip_text = (
		"Tiếp tục trận đấu đã lưu"
		if available
		else "Chưa có trận đấu đã lưu"
	)


func _on_exit_pressed() -> void:
	get_tree().quit()


func _build_character_buttons() -> void:
	for child: Node in character_grid.get_children():
		child.queue_free()
	for character: CHARACTER_DEFINITION in setup.characters:
		var view: Dictionary = setup.character_presentation(character)
		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(320, 125)
		var char_name: String = String(view.get("name", "Nhân vật"))
		var house: String = String(view.get("house", ""))
		var speed: int = int(view.get("speed", 0))
		var stamina: int = int(view.get("stamina", 0))
		var bag: int = int(view.get("bag", 0))
		button.text = "🏛️ %s — %s\n⚡ Tốc độ %d  ·  ❤️ Thể lực %d  ·  🎒 Túi %d" % [
			char_name, house, speed, stamina, bag
		]
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.pressed.connect(_on_character_pressed.bind(character.character_id))
		character_grid.add_child(button)


func _build_match_rule_options() -> void:
	victory_type_selector.clear()
	victory_type_selector.add_item("Đạt Công Danh")
	victory_type_selector.set_item_metadata(
		0, MATCH_RULES.VictoryType.REACH_COURT_RANK
	)
	victory_type_selector.add_item("Số Round cố định")
	victory_type_selector.set_item_metadata(1, MATCH_RULES.VictoryType.FIXED_ROUNDS)
	target_rank_selector.clear()
	for rank: Dictionary in setup.court_rank_options():
		target_rank_selector.add_item(String(rank.get("name", "")))
		target_rank_selector.set_item_metadata(
			target_rank_selector.item_count - 1,
			StringName(rank.get("id", &""))
		)
	round_limit_selector.clear()
	for round_limit: int in setup.round_limit_options():
		round_limit_selector.add_item("%d Round" % round_limit)
		round_limit_selector.set_item_metadata(
			round_limit_selector.item_count - 1, round_limit
		)


func _show_match_rules_result(result: Dictionary) -> void:
	if not bool(result.get("success", false)):
		_show_message("Chưa thể chọn chế độ trận đấu.", true)
		return
	_refresh_match_rules()
	_show_phase(setup.phase)


func _refresh_match_rules() -> void:
	var rules: MATCH_RULES = setup.get_match_rules()
	var view: Dictionary = setup.match_rules_presentation()
	if rules == null or view.is_empty():
		return
	match_rules_summary.text = "%s\n%s: %s" % [
		String(view.get("mode_name", "")),
		String(view.get("victory_name", "")),
		String(view.get("target_name", "")),
	]
	var is_custom: bool = rules.mode == MATCH_RULES.Mode.CUSTOM
	custom_rules.visible = is_custom
	if not is_custom:
		return
	_select_option_by_metadata(victory_type_selector, rules.victory_type)
	var uses_rank: bool = rules.victory_type == MATCH_RULES.VictoryType.REACH_COURT_RANK
	rank_row.visible = uses_rank
	round_row.visible = not uses_rank
	if uses_rank:
		_select_option_by_metadata(target_rank_selector, rules.target_court_rank)
	else:
		_select_option_by_metadata(round_limit_selector, rules.round_limit)


func _select_option_by_metadata(selector: OptionButton, expected: Variant) -> void:
	for index: int in range(selector.item_count):
		if selector.get_item_metadata(index) == expected:
			selector.select(index)
			return


func _refresh_character_selection() -> void:
	var player_number: int = setup.selection_session.current_seat_index + 1
	current_player_label.text = "👤 NGƯỜI CHƠI %d — CẢN PHONG CHỌN TƯỚNG" % player_number
	var character: CHARACTER_DEFINITION = setup.selected_character_for_seat(
		setup.selection_session.current_seat_index
	)
	choose_character_button.disabled = character == null
	if character == null:
		character_details.text = "[center][color=#8be9fd]Hãy chọn một nhân vật bên trên để xem thuộc tính chi tiết.[/color][/center]"
		return
	var view: Dictionary = setup.character_presentation(character)
	var char_name: String = String(view.get("name", "Nhân vật"))
	var house: String = String(view.get("house", ""))
	var speed: int = int(view.get("speed", 0))
	var stamina: int = int(view.get("stamina", 0))
	var bag: int = int(view.get("bag", 0))
	var skill: String = String(view.get("skill", "Chưa có mô tả kỹ năng"))
	
	character_details.text = "[center][font_size=22][b][color=#f6c95c]%s[/color][/b][/font_size]\n[color=#bd93f9]%s[/color]\n\n⚡ [b]Tốc độ:[/b] %d  |  ❤️ [b]Thể lực:[/b] %d  |  🎒 [b]Túi:[/b] %d\n\n[i]%s[/i][/center]" % [
		char_name, house, speed, stamina, bag, skill
	]


func _refresh_lineup() -> void:
	var lines: Array[String] = ["[center][font_size=22][b][color=#f6c95c]📜 ĐỘI HÌNH ĐÃ CHỌN[/color][/b][/font_size][/center]\n"]
	for seat_index: int in range(setup.selection_session.player_count):
		var character: CHARACTER_DEFINITION = setup.selected_character_for_seat(seat_index)
		var view: Dictionary = setup.character_presentation(character)
		lines.append(
			"👤 [b]Người chơi %d:[/b]  [color=#50fa7b]%s[/color]  ·  %s  (⚡ %d  ❤️ %d  🎒 %d)"
			% [
				seat_index + 1,
				String(view.get("name", "Nhân vật")),
				String(view.get("house", "")),
				int(view.get("speed", 0)),
				int(view.get("stamina", 0)),
				int(view.get("bag", 0)),
			]
		)
	lineup_text.text = "\n".join(lines)


func _refresh_case_card() -> void:
	var view: Dictionary = setup.case_presentation()
	case_title.text = "🔍 " + String(view.get("name", "Kỳ Án Hoàng Cung"))
	case_description.text = String(view.get("description", ""))
	case_reward.text = "⭐ Công Danh dự kiến: +%d" % int(view.get("merit", 0))


func _render_case_results() -> void:
	var lines: Array[String] = []
	for row: Dictionary in case_flow.active_settlement_summary():
		var status: String = _result_status_label(String(row.get("status", "")))
		lines.append(
			(
				"👤 [b][color=#f6c95c]%s[/color][/b]  —  %s\n"
				+ "   ⭐ [b]Công Danh:[/b] [color=#50fa7b]%+.2f[/color]\n"
				+ "   🛡️ [b]Danh Tiếng:[/b] %d ➔ [b]%d[/b]\n"
				+ "   🔮 [b]Orb:[/b] %+d  |  🎟️ [b]Vé:[/b] %+d"
			)
			% [
				String(row.get("display_name", "Người chơi")),
				status,
				float(row.get("merit_delta", 0.0)),
				int(row.get("reputation_before", 0)),
				int(row.get("reputation_total", 0)),
				int(row.get("orb_delta", 0)),
				int(row.get("ticket_delta", 0)),
			]
		)
	results_text.text = "\n\n".join(lines)


func _result_status_label(status: String) -> String:
	match status:
		"CORRECT":
			return "[color=#50fa7b][b]✓ CHÍNH XÁC[/b][/color]"
		"WRONG":
			return "[color=#ff5555][b]✗ SAI LẦM[/b][/color]"
		_:
			return "[color=#6272a4]CHƯA TRÌNH ÁN[/color]"


func _current_loot_player() -> PLAYER_PHASE_STATE:
	if case_flow == null or case_flow.loot_session == null:
		return null
	var movement_player: LOOT_MOVEMENT_PLAYER_STATE = (
		case_flow.loot_session.movement_session.current_player()
	)
	if movement_player == null:
		return null
	return case_flow.loot_session.find_player(movement_player.player_id)


func _refresh_loot() -> void:
	var session: LOOT_REWARD_SESSION = case_flow.loot_session
	var movement_player: LOOT_MOVEMENT_PLAYER_STATE = session.movement_session.current_player()
	if movement_player == null:
		return
	var player: PLAYER_PHASE_STATE = session.find_player(movement_player.player_id)
	var display_name: String = _player_name(movement_player.player_id)
	var round_loot: RoundLootInventoryState = session.find_round_loot_state(
		movement_player.player_id
	)
	var bag_count: int = round_loot.carried_items.size() if round_loot != null else 0
	var bag_capacity: int = round_loot.capacity if round_loot != null else 0
	var persistent_item_count: int = player.consumable_inventory.size() if player != null else 0
	var round_item_count: int = round_loot.carried_items.size() if round_loot != null else 0
	var character: CHARACTER_DEFINITION = (
		setup.find_character(player.character_id) if player != null else null
	)
	var character_name: String = character.display_name if character != null else "Nhân vật"
	active_turn_label.text = "🎯 %s" % display_name
	loot_text.text = (
		"[b][color=#f6c95c]%s[/color][/b] · 📍 [b]%s[/b]\n⚡ Tốc độ: %d  |  ❤️ Còn: %d  |  🎒 %d/%d"
	) % [
		character_name,
		_node_display_name(movement_player.current_node_id),
		movement_player.speed_snapshot,
		movement_player.remaining_moves,
		bag_count,
		bag_capacity,
	]
	resource_summary.text = (
		"📊 TÀI NGUYÊN — %s\n⭐ Công Danh: %.2f  ·  🛡️ Danh Tiếng: %d  ·  🔮 Orb: %d  ·  🎟️ Vé: %d  ·  🪙 Xu Bạc: %d"
		% [
			display_name, player.merit_progress, player.reputation,
			player.orb_count, player.gacha_ticket_count, player.silver_coin_count,
		]
	) if player != null else "Tài nguyên chưa sẵn sàng."
	bag_summary.text = "🎒 TÚI CHỨA (%d/%d)\n%s" % [bag_count, bag_capacity, _round_loot_item_names(round_loot)]
	activity_log.text = "[b]📜 LỊCH SỬ HÀNH ĐỘNG[/b]\n%s" % (
		"\n".join(_loot_activity_lines)
		if not _loot_activity_lines.is_empty()
		else "Chưa có hành động."
	)
	loot_map_view.configure(case_flow.loot_map_definition(), session.movement_session)
	var item_window: bool = session.phase == LOOT_REWARD_SESSION.Phase.ITEM_WINDOW
	var movement_ready: bool = session.phase == LOOT_REWARD_SESSION.Phase.MOVEMENT
	if item_window_panel != null:
		item_window_panel.visible = _item_tray_open
	_refresh_item_source_selector(player, round_loot)
	item_source_selector.disabled = (
		not item_window or session.item_used_this_turn or item_source_selector.item_count == 0
	)
	use_item_button.disabled = (
		not item_window
		or session.item_used_this_turn
		or persistent_item_count + round_item_count == 0
	)
	if session.item_used_this_turn:
		use_item_button.tooltip_text = "Lượt này đã dùng một vật phẩm."
	elif persistent_item_count + round_item_count == 0:
		use_item_button.tooltip_text = "Túi hiện không có vật phẩm có thể dùng."
	elif not item_window:
		use_item_button.tooltip_text = "Chỉ dùng vật phẩm trong Cửa sổ Vật phẩm."
	else:
		use_item_button.tooltip_text = (
			"Dùng vật phẩm đã chọn; mỗi lượt chỉ dùng một vật phẩm."
		)
	continue_without_item_button.disabled = not item_window
	if move_button != null:
		move_button.disabled = not movement_ready
		move_button.tooltip_text = (
			"Bấm [Z] để đổ xúc xắc."
			if movement_ready
			else (
				"Hãy hoàn tất Cửa sổ Vật phẩm trước (hoặc bấm [Z] để bỏ qua)."
				if item_window
				else (
					"Hãy xử lý vật phẩm đang chờ trước."
					if session.overflow.active
					else "Chưa thể di chuyển."
				)
			)
		)
	action_guide.text = _loot_action_guidance(session, movement_player)
	_refresh_branch_ui(session, movement_player, movement_ready)
	overflow_panel.visible = session.overflow.active
	if not session.overflow.active and replace_confirm_modal != null:
		replace_confirm_modal.visible = false
	if session.overflow.active:
		overflow_text.text = (
			"⚠️ TÚI ĐÃ ĐẦY!\nVật phẩm mới: %s\n"
			+ "Chọn một vật phẩm đang mang để thay thế, hoặc bỏ vật phẩm mới."
		) % _item_display_name(session.overflow.incoming_item_id)
	_refresh_overflow_choice(session, movement_player.player_id)
	_refresh_pummel_player_cards(session)
	if _item_tray_open:
		_refresh_pummel_item_hotbar(session)


func _refresh_pummel_player_cards(session: LOOT_REWARD_SESSION) -> void:
	if player_cards_container == null or session == null or session.movement_session == null:
		return
	var player_order: Array[StringName] = session.movement_session.ordered_player_ids
	var active_id: StringName = (
		session.movement_session.current_player().player_id
		if session.movement_session.current_player() != null
		else &""
	)
	var badges: Array[String] = ["🔵 P1", "🔴 P2", "🟢 P3", "🟣 P4"]
	var badge_colors: Array[Color] = [
		Color(0.2, 0.75, 1.0), Color(1.0, 0.35, 0.45),
		Color(0.35, 0.9, 0.45), Color(0.8, 0.45, 1.0)
	]

	for i: int in range(player_cards_container.get_child_count()):
		var card: Control = player_cards_container.get_child(i) as Control
		if card == null:
			continue
		if i >= player_order.size():
			card.visible = false
			continue

		card.visible = true
		var player_id: StringName = player_order[i]
		var is_active: bool = (player_id == active_id)
		var player_state: PLAYER_PHASE_STATE = session.find_player(player_id)
		var movement_player: LOOT_MOVEMENT_PLAYER_STATE = null
		for mp: LOOT_MOVEMENT_PLAYER_STATE in session.movement_session.player_states:
			if mp.player_id == player_id:
				movement_player = mp
				break
		var round_loot: RoundLootInventoryState = session.find_round_loot_state(player_id)
		var character: CHARACTER_DEFINITION = (
			setup.find_character(player_state.character_id) if player_state != null else null
		)
		var char_name: String = character.display_name if character != null else _player_name(player_id)

		card.add_theme_stylebox_override("panel", _pummel_style_active if is_active else _pummel_style_normal)
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.tooltip_text = "Đè giữ chuột để xem Hồ sơ Trạng thái (Honkai: Star Rail)\nBấm chuột trái để xem vị trí trên bản đồ"
		card.set_meta("player_id", player_id)
		if not card.has_meta("click_connected"):
			card.set_meta("click_connected", true)
			card.gui_input.connect(func(event: InputEvent) -> void:
				_on_pummel_player_card_gui_input(event, card)
			)
		_make_children_mouse_pass(card)

		var badge_label: Label = card.find_child("Badge", true, false) as Label
		if badge_label != null:
			badge_label.text = badges[i % badges.size()]
			badge_label.add_theme_color_override("font_color", badge_colors[i % badge_colors.size()])

		var name_label: Label = card.find_child("Name", true, false) as Label
		if name_label != null:
			name_label.text = char_name

		var crown_label: Label = card.find_child("Crown", true, false) as Label
		if crown_label != null:
			crown_label.visible = is_active

		var hp_label: Label = card.find_child("Stamina", true, false) as Label
		if hp_label == null:
			hp_label = card.find_child("Hp", true, false) as Label
		if hp_label != null:
			var remaining: int = movement_player.remaining_moves if movement_player != null else 0
			hp_label.text = "⚡ %d" % remaining
			hp_label.tooltip_text = "Thể lực: Còn %d lượt đi" % remaining

		var speed_label: Label = card.find_child("Speed", true, false) as Label
		if speed_label == null:
			speed_label = card.find_child("Merit", true, false) as Label
		if speed_label != null:
			var max_speed: int = (
				movement_player.speed_snapshot if movement_player != null
				else (character.base_speed if character != null else 2)
			)
			speed_label.text = "👟 %d" % max_speed
			speed_label.tooltip_text = "Tốc độ: 1-%d bước mỗi lần đổ xúc xắc" % max_speed

		var coins_label: Label = card.find_child("Coins", true, false) as Label
		if coins_label != null:
			var coins: int = player_state.silver_coin_count if player_state != null else 0
			coins_label.text = "🪙 %d" % coins
			coins_label.tooltip_text = "Xu Bạc: %d" % coins

		var bag_label: Label = card.find_child("Bag", true, false) as Label
		if bag_label != null:
			var carried: int = round_loot.carried_items.size() if round_loot != null else 0
			var cap: int = round_loot.capacity if round_loot != null else 2
			bag_label.text = "🎒 %d/%d" % [carried, cap]
			bag_label.tooltip_text = "Túi đồ: %d/%d món" % [carried, cap]


func _on_pummel_player_card_gui_input(event: InputEvent, card: Control) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event == null:
		return
	var target_player_id: StringName = StringName(card.get_meta("player_id", &""))
	if target_player_id.is_empty():
		return

	if mouse_event.pressed:
		if mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			_open_character_detail_sheet(target_player_id)
			get_viewport().set_input_as_handled()
			return
		elif mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_card_held_player_id = target_player_id
			_card_hold_token += 1
			var current_token: int = _card_hold_token
			get_tree().create_timer(0.32).timeout.connect(func() -> void:
				if _card_held_player_id == target_player_id and _card_hold_token == current_token:
					_card_held_player_id = &""
					_open_character_detail_sheet(target_player_id)
			)
			get_viewport().set_input_as_handled()
			return
	else:
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if _card_held_player_id == target_player_id:
				_card_held_player_id = &""
				_card_hold_token += 1
				if loot_map_view != null:
					loot_map_view.focus_player(target_player_id)
			get_viewport().set_input_as_handled()
			return


func _open_character_detail_sheet(player_id: StringName = &"", is_post_loot: bool = false) -> void:
	if _character_sheet == null:
		return
	var target_id: StringName = player_id
	if target_id.is_empty():
		if case_flow != null:
			if case_flow.equipment_session != null:
				target_id = case_flow.equipment_session.current_player_id()
			elif case_flow.loot_session != null and case_flow.loot_session.movement_session != null:
				var curr: LootMovementPlayerState = case_flow.loot_session.movement_session.current_player()
				if curr != null:
					target_id = curr.player_id
	_character_sheet.open_sheet(target_id, case_flow, setup, is_post_loot)


func _toggle_character_detail_sheet() -> void:
	if _character_sheet != null and _character_sheet.visible:
		if _character_sheet.is_post_loot_equipment_phase:
			_character_sheet._on_close_pressed()
		else:
			_character_sheet.visible = false
	else:
		_open_character_detail_sheet(&"")



func _make_children_mouse_pass(parent: Node) -> void:
	for child: Node in parent.get_children():
		if child is Control:
			(child as Control).mouse_filter = Control.MOUSE_FILTER_PASS
		_make_children_mouse_pass(child)


func _refresh_pummel_item_hotbar(session: LOOT_REWARD_SESSION) -> void:
	if item_hotbar_container == null or session == null:
		return
	for child: Node in item_hotbar_container.get_children():
		child.queue_free()

	_hotbar_items.clear()
	var movement_player: LOOT_MOVEMENT_PLAYER_STATE = session.movement_session.current_player()
	if movement_player == null:
		return
	var player_state: PLAYER_PHASE_STATE = session.find_player(movement_player.player_id)
	var round_loot: RoundLootInventoryState = session.find_round_loot_state(movement_player.player_id)
	var is_item_window: bool = (session.phase == LOOT_REWARD_SESSION.Phase.ITEM_WINDOW)
	var can_use: bool = is_item_window and not session.item_used_this_turn

	if player_state != null:
		for row: Dictionary in player_state.consumable_inventory:
			_hotbar_items.append({
				"item_id": StringName(row.get("item_id", "")),
				"source": "persistent"
			})
	if round_loot != null and not round_loot.disposition_finalized:
		for row: Dictionary in round_loot.carried_items:
			_hotbar_items.append({
				"item_id": StringName(row.get("item_id", "")),
				"source": "round_loot"
			})

	if _hotbar_items.is_empty():
		var empty_label: Label = Label.new()
		empty_label.text = "🎒 Túi đồ đang trống"
		empty_label.add_theme_font_size_override("font_size", 13)
		empty_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 0.85))
		item_hotbar_container.add_child(empty_label)
		return

	for slot_idx: int in range(_hotbar_items.size()):
		var entry: Dictionary = _hotbar_items[slot_idx]
		var item_id: StringName = entry.get("item_id", &"")
		var source: String = String(entry.get("source", ""))
		var icon_str: String = _item_icon(item_id)
		var display_name: String = _item_display_name(item_id)

		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(110, 52)
		btn.focus_mode = Control.FOCUS_NONE
		btn.add_theme_stylebox_override("normal", _pummel_slot_style)
		btn.text = "[%d] %s\n%s" % [slot_idx + 1, icon_str, display_name]
		btn.tooltip_text = "[Phím %d] Sử dụng %s (%s)" % [
			slot_idx + 1, display_name, "Đồ sở hữu" if source == "persistent" else "Đồ trong lượt"
		]
		btn.disabled = not can_use
		btn.pressed.connect(_on_hotbar_slot_pressed.bind(slot_idx))
		item_hotbar_container.add_child(btn)

	if roll_dice_button != null:
		var movement_ready: bool = (session.phase == LOOT_REWARD_SESSION.Phase.MOVEMENT)
		roll_dice_button.disabled = (not movement_ready and not is_item_window) or session.overflow.active
		if session.phase == LOOT_REWARD_SESSION.Phase.BRANCH_SELECTION:
			roll_dice_button.text = "⚠️ CHỌN Ô VÀNG"
			roll_dice_button.tooltip_text = "Bấm trực tiếp lên ô cờ vàng trên bản đồ để chọn hướng."
		elif is_item_window:
			roll_dice_button.text = "🎲 [Z] BỎ ITEM & ĐỔ"
			roll_dice_button.tooltip_text = "Bỏ qua dùng item và đổ xúc xắc ngay lập tức."
		else:
			roll_dice_button.text = "🎲 [Z] ĐỔ XÚC XẮC"
			roll_dice_button.tooltip_text = "Gieo xí ngầu để di chuyển."


func _on_hotbar_slot_pressed(slot_idx: int) -> void:
	_try_use_hotbar_item(slot_idx)


func _try_use_hotbar_item(slot_idx: int) -> void:
	if case_flow == null or case_flow.loot_session == null:
		return
	var session: LOOT_REWARD_SESSION = case_flow.loot_session
	if session.phase != LOOT_REWARD_SESSION.Phase.ITEM_WINDOW:
		_show_message("Chỉ có thể dùng vật phẩm trong Cửa sổ Vật phẩm (đầu lượt)!", true)
		return
	if session.item_used_this_turn:
		_show_message("Lượt này bạn đã kích hoạt một vật phẩm rồi!", true)
		return
	if slot_idx < 0 or slot_idx >= _hotbar_items.size():
		_show_message("Ô vật phẩm này đang trống!", false)
		return
	var entry: Dictionary = _hotbar_items[slot_idx]
	var item_id: StringName = entry.get("item_id", &"")
	var source: StringName = StringName(entry.get("source", ""))
	_handle_loot_result(case_flow.use_item(item_id, source))


func _item_icon(item_id: StringName) -> String:
	match item_id:
		&"consumable_speed_charm_v1":
			return "📜"
		&"consumable_pass_token_v1":
			return "🪪"
		&"consumable_royal_steed_decree_v1":
			return "🐎"
		_:
			return "🎒"


func _refresh_branch_ui(
	session: LOOT_REWARD_SESSION,
	movement_player: LOOT_MOVEMENT_PLAYER_STATE,
	movement_ready: bool
) -> void:
	if branch_panel != null:
		branch_panel.visible = false
	if branch_buttons_container != null:
		for child: Node in branch_buttons_container.get_children():
			child.queue_free()

	if session.phase == LOOT_REWARD_SESSION.Phase.BRANCH_SELECTION:
		var pending: PendingBranchState = session.movement_session.pending_branch
		if pending != null:
			loot_map_view.set_selectable_branches(pending.available_branch_ids)
		if move_button != null:
			move_button.visible = false
		return

	if move_button != null:
		move_button.visible = true

	_selected_branch_id = &""
	loot_map_view.set_selectable_branches([])


func _refresh_confirmation() -> void:
	var lines: Array[String] = ["[center][font_size=20][b][color=#f6c95c]🤝 XÁC NHẬN HOÀN TẤT LOOT[/color][/b][/font_size][/center]\n"]
	for player_id: StringName in case_flow.equipment_session.player_order:
		var confirmed: bool = case_flow.equipment_session.confirmed_player_ids.has(player_id)
		var retained: Array[Dictionary] = case_flow.transferred_round_loot_items(player_id)
		var retained_text: String = (
			" · Giữ lại %d vật phẩm" % retained.size() if confirmed and not retained.is_empty() else ""
		)
		lines.append("👤 %s — %s%s" % [_player_name(player_id), "[color=#50fa7b]✓ Đã xác nhận[/color]" if confirmed else "[color=#ff5555]⌛ Chưa xác nhận[/color]", retained_text])
	lines.append("\n👉 Đưa thiết bị cho [b]%s[/b]." % _player_name(case_flow.equipment_session.current_player_id()))
	confirmation_text.text = "\n".join(lines)


func _build_equipment_slot_options() -> void:
	equipment_slot_selector.clear()
	for row: Dictionary in [
		{"id": EQUIPMENT_SERVICE.SLOT_RELIC, "label": "Kỷ Vật"},
		{"id": EQUIPMENT_SERVICE.SLOT_STIGMATA_A, "label": "Vết Thánh A"},
		{"id": EQUIPMENT_SERVICE.SLOT_STIGMATA_B, "label": "Vết Thánh B"},
		{"id": EQUIPMENT_SERVICE.SLOT_STIGMATA_C, "label": "Vết Thánh C"},
	]:
		equipment_slot_selector.add_item(String(row.get("label", "")))
		equipment_slot_selector.set_item_metadata(
			equipment_slot_selector.item_count - 1,
			StringName(row.get("id", &""))
		)
	if equipment_slot_selector.item_count > 0:
		equipment_slot_selector.select(0)


func _refresh_equipment() -> void:
	var management: EquipmentManagementSession = case_flow.equipment_session
	var player_id: StringName = management.current_player_id()
	var player: PLAYER_PHASE_STATE = management.find_player(player_id)
	if player == null:
		return
	var loadout: Array[String] = []
	loadout.append(_loadout_line(player, EQUIPMENT_SERVICE.SLOT_RELIC, "👑 Kỷ Vật"))
	loadout.append(_loadout_line(player, EQUIPMENT_SERVICE.SLOT_STIGMATA_A, "✨ Vết Thánh A"))
	loadout.append(_loadout_line(player, EQUIPMENT_SERVICE.SLOT_STIGMATA_B, "✨ Vết Thánh B"))
	loadout.append(_loadout_line(player, EQUIPMENT_SERVICE.SLOT_STIGMATA_C, "✨ Vết Thánh C"))
	var retained_count: int = case_flow.transferred_round_loot_items(player_id).size()
	equipment_text.text = (
		"[center][font_size=20][b][color=#f6c95c]⚙️ CHUẨN BỊ TRANG BỊ — %s[/color][/b][/font_size][/center]\n\n"
		+ "🎟️ Vé cầu nguyện: [b]%d[/b]  |  📦 Trang bị sở hữu: [b]%d[/b]\n"
		+ "🎒 Vật phẩm sở hữu: [b]%d[/b]  |  Giữ lại từ vòng này: [b]%d[/b]\n\n"
		+ "[b]TRANG BỊ HIỆN TẠI[/b]\n%s"
	) % [
		_player_name(player_id),
		player.gacha_ticket_count,
		player.equipment_collection.size(),
		player.consumable_inventory.size(),
		retained_count,
		"\n".join(loadout),
	]
	_refresh_owned_equipment_selector()
	var has_pending_choice: bool = management.pending_choice.is_active()
	basic_gacha_button.disabled = player.gacha_ticket_count < 1 or has_pending_choice
	basic_gacha_button.tooltip_text = (
		"Cần ít nhất 1 Vé."
		if player.gacha_ticket_count < 1
		else ("Hãy chọn phần thưởng đang chờ." if has_pending_choice else "Dùng 1 Vé.")
	)
	rate_up_gacha_button.disabled = player.gacha_ticket_count < 1 or has_pending_choice
	rate_up_gacha_button.tooltip_text = (
		"Cần ít nhất 1 Vé."
		if player.gacha_ticket_count < 1
		else ("Hãy chọn phần thưởng đang chờ." if has_pending_choice else "Dùng 1 Vé.")
	)
	perfect_gacha_button.disabled = player.gacha_ticket_count < 2 or has_pending_choice
	perfect_gacha_button.tooltip_text = (
		"Cần ít nhất 2 Vé."
		if player.gacha_ticket_count < 2
		else ("Hãy chọn phần thưởng đang chờ." if has_pending_choice else "Dùng 2 Vé.")
	)
	_refresh_perfect_choice(management, player_id)
	management_done_button.disabled = has_pending_choice
	management_done_button.tooltip_text = (
		"Hãy xác nhận phần thưởng Tuyệt Phẩm trước."
		if has_pending_choice
		else "Hoàn tất lượt chuẩn bị trang bị."
	)


func _refresh_perfect_choice(
	management: EquipmentManagementSession, player_id: StringName
) -> void:
	var pending_owned: bool = (
		management.pending_choice.is_active()
		and management.pending_choice.player_id == player_id
	)
	perfect_choice_panel.visible = pending_owned
	perfect_choice_selector.clear()
	if not pending_owned:
		resolve_choice_button.disabled = true
		resolve_choice_button.tooltip_text = "Hiện không có phần thưởng cần chọn."
		return

	perfect_choice_title.text = "Chọn phần thưởng — %s" % _player_name(player_id)
	perfect_choice_selector.add_item("Chọn một phần thưởng...")
	perfect_choice_selector.set_item_metadata(0, &"")
	for definition_id: StringName in management.pending_choice.eligible_definition_ids:
		var definition: EQUIPMENT_DEFINITION = (
			case_flow.find_management_equipment_definition(definition_id)
		)
		if definition == null:
			continue
		perfect_choice_selector.add_item(
			"%s · %s · %s" % [
				_equipment_name(definition),
				_equipment_tier_name(definition.tier),
				_equipment_definition_type_name(definition),
			]
		)
		perfect_choice_selector.set_item_metadata(
			perfect_choice_selector.item_count - 1, definition_id
		)
	perfect_choice_selector.select(0)
	perfect_choice_selector.disabled = perfect_choice_selector.item_count <= 1
	resolve_choice_button.disabled = true
	resolve_choice_button.tooltip_text = (
		"Chọn đúng một phần thưởng rồi xác nhận."
		if perfect_choice_selector.item_count > 1
		else "Không có phần thưởng hợp lệ để chọn."
	)


func _refresh_owned_equipment_selector() -> void:
	var preserved_id: StringName = _selected_owned_equipment_id()
	owned_equipment_selector.clear()
	var management: EquipmentManagementSession = case_flow.equipment_session
	var player: PLAYER_PHASE_STATE = management.find_player(management.current_player_id())
	var slot_id: StringName = _selected_equipment_slot_id()
	var selected_index := -1
	if player != null:
		for instance: EQUIPMENT_INSTANCE in player.equipment_collection:
			if (
				instance == null
				or instance.owner_player_id != player.player_id
				or _equipment_slot_id(instance) != slot_id
			):
				continue
			var definition: EQUIPMENT_DEFINITION = (
				case_flow.find_management_equipment_definition(
					instance.equipment_definition_id
				)
			)
			var equipped: bool = _equipped_instance_id(player, slot_id) == instance.instance_id
			owned_equipment_selector.add_item(
				"%s%s" % [_equipment_name(definition), " · Đang dùng" if equipped else ""]
			)
			var item_index: int = owned_equipment_selector.item_count - 1
			owned_equipment_selector.set_item_metadata(item_index, instance.instance_id)
			if instance.instance_id == preserved_id:
				selected_index = item_index
	if owned_equipment_selector.item_count == 0:
		owned_equipment_selector.add_item("Không có trang bị phù hợp")
		owned_equipment_selector.set_item_metadata(0, &"")
		owned_equipment_selector.disabled = true
	else:
		owned_equipment_selector.disabled = false
		owned_equipment_selector.select(maxi(0, selected_index))
	_refresh_equipment_selection_state()


func _refresh_equipment_selection_state() -> void:
	var management: EquipmentManagementSession = case_flow.equipment_session
	var player: PLAYER_PHASE_STATE = management.find_player(management.current_player_id())
	var slot_id: StringName = _selected_equipment_slot_id()
	var instance_id: StringName = _selected_owned_equipment_id()
	var instance: EQUIPMENT_INSTANCE = _equipment_instance(player, instance_id)
	var equipped_id: StringName = _equipped_instance_id(player, slot_id)
	unequip_selected_slot_button.disabled = equipped_id.is_empty()
	equip_selected_equipment_button.disabled = instance == null or equipped_id == instance_id
	if instance == null:
		equipment_selection_label.text = (
			"%s hiện chưa có trang bị phù hợp trong kho."
			% _equipment_slot_name(slot_id)
		)
		_refresh_equipment_progression_state({})
		return
	var definition: EQUIPMENT_DEFINITION = case_flow.find_management_equipment_definition(
		instance.equipment_definition_id
	)
	equipment_selection_label.text = "%s · Bậc %s · Vàng %d · Tím %d" % [
		_equipment_name(definition),
		_equipment_tier_name(instance.tier),
		instance.gold_star_level,
		instance.purple_star_level,
	]
	_refresh_equipment_progression_state(
		case_flow.management_equipment_progression_state(instance.instance_id)
	)


func _refresh_equipment_progression_state(state: Dictionary) -> void:
	purple_duplicate_selector.clear()
	if not bool(state.get("success", false)):
		equipment_progression_label.text = "Chọn trang bị để xem tiến triển."
		purple_duplicate_selector.add_item("Không có bản sao hợp lệ")
		purple_duplicate_selector.set_item_metadata(0, &"")
		purple_duplicate_selector.disabled = true
		upgrade_equipment_gold_button.disabled = true
		upgrade_equipment_purple_button.disabled = true
		return
	var gold_level: int = int(state.get("gold_level", 0))
	var gold_cap: int = int(state.get("gold_cap", 0))
	var purple_level: int = int(state.get("purple_level", 0))
	var purple_cap: int = int(state.get("purple_cap", 0))
	var gold_cost: int = int(state.get("gold_next_cost", -1))
	var purple_cost: int = int(state.get("purple_next_cost", -1))
	var material_count: int = int(state.get("exp_material_count", 0))
	var gold_cost_text: String = "TỐI ĐA" if gold_level >= gold_cap else "%d EXP" % gold_cost
	var purple_cost_text: String = (
		"TỐI ĐA" if purple_level >= purple_cap else "%d EXP + 1 bản sao" % purple_cost
	)
	equipment_progression_label.text = (
		"%s · Bậc %s%s\nVàng %d/%d · Lần tới: %s · %s\nTím %d/%d · Lần tới: %s · %s\nNguyên liệu EXP: %d"
		% [
			String(state.get("display_name", "Trang bị")),
			_equipment_tier_name(int(state.get("tier", 0))),
			" · Đang trang bị" if bool(state.get("is_equipped", false)) else "",
			gold_level,
			gold_cap,
			gold_cost_text,
			_progression_state_hint(StringName(state.get("gold_code", &""))),
			purple_level,
			purple_cap,
			purple_cost_text,
			_progression_state_hint(StringName(state.get("purple_code", &""))),
			material_count,
		]
	)
	var duplicate_value: Variant = state.get("duplicate_instance_ids", [])
	if duplicate_value is Array:
		for duplicate_id_value: Variant in duplicate_value:
			var duplicate_id: StringName = StringName(duplicate_id_value)
			purple_duplicate_selector.add_item("Bản sao · %s" % String(duplicate_id))
			purple_duplicate_selector.set_item_metadata(
				purple_duplicate_selector.item_count - 1, duplicate_id
			)
	if purple_duplicate_selector.item_count == 0:
		purple_duplicate_selector.add_item("Không có bản sao hợp lệ")
		purple_duplicate_selector.set_item_metadata(0, &"")
		purple_duplicate_selector.disabled = true
	else:
		purple_duplicate_selector.disabled = false
		purple_duplicate_selector.select(0)
	upgrade_equipment_gold_button.disabled = not bool(
		state.get("can_upgrade_gold", false)
	)
	upgrade_equipment_purple_button.disabled = not bool(
		state.get("can_upgrade_purple", false)
	)
	upgrade_equipment_gold_button.tooltip_text = _progression_state_hint(
		StringName(state.get("gold_code", &""))
	)
	upgrade_equipment_purple_button.tooltip_text = _progression_state_hint(
		StringName(state.get("purple_code", &""))
	)


func _selected_purple_duplicate_id() -> StringName:
	if purple_duplicate_selector.item_count == 0 or purple_duplicate_selector.selected < 0:
		return &""
	return StringName(
		purple_duplicate_selector.get_item_metadata(purple_duplicate_selector.selected)
	)


func _progression_state_hint(code: StringName) -> String:
	match code:
		&"AVAILABLE":
			return "Có thể tiến triển ngay."
		&"GOLD_MAX", &"PURPLE_MAX":
			return "Đã đạt cấp tối đa."
		&"INSUFFICIENT_EXP":
			return "Chưa đủ nguyên liệu EXP."
		&"GOLD_PREREQUISITE":
			return "Cần tăng cấp Vàng trước."
		&"DUPLICATE_REQUIRED":
			return "Chưa có bản sao hợp lệ chưa trang bị."
	return "Chưa thể tiến triển."


func _loadout_line(player: PLAYER_PHASE_STATE, slot_id: StringName, label: String) -> String:
	var instance_id: StringName = _equipped_instance_id(player, slot_id)
	if instance_id.is_empty():
		return "%s: [color=#6272a4]Trống[/color]" % label
	var instance: EQUIPMENT_INSTANCE = _equipment_instance(player, instance_id)
	if instance == null:
		return "%s: [color=#ff5555]Không hợp lệ[/color]" % label
	var definition: EQUIPMENT_DEFINITION = case_flow.find_management_equipment_definition(
		instance.equipment_definition_id
	)
	return "%s: [color=#50fa7b]%s[/color] · %s · Vàng %d / Tím %d" % [
		label,
		_equipment_name(definition),
		_equipment_tier_name(instance.tier),
		instance.gold_star_level,
		instance.purple_star_level,
	]


func _selected_equipment_slot_id() -> StringName:
	if equipment_slot_selector.item_count == 0 or equipment_slot_selector.selected < 0:
		return &""
	return StringName(
		equipment_slot_selector.get_item_metadata(equipment_slot_selector.selected)
	)


func _selected_owned_equipment_id() -> StringName:
	if owned_equipment_selector.item_count == 0 or owned_equipment_selector.selected < 0:
		return &""
	return StringName(
		owned_equipment_selector.get_item_metadata(owned_equipment_selector.selected)
	)


func _equipment_instance(
	player: PLAYER_PHASE_STATE, instance_id: StringName
) -> EQUIPMENT_INSTANCE:
	if player == null or instance_id.is_empty():
		return null
	for instance: EQUIPMENT_INSTANCE in player.equipment_collection:
		if instance != null and instance.instance_id == instance_id:
			return instance
	return null


func _equipped_instance_id(player: PLAYER_PHASE_STATE, slot_id: StringName) -> StringName:
	if player == null:
		return &""
	match slot_id:
		EQUIPMENT_SERVICE.SLOT_RELIC:
			return player.relic_instance_id
		EQUIPMENT_SERVICE.SLOT_STIGMATA_A:
			return player.stigmata_a_instance_id
		EQUIPMENT_SERVICE.SLOT_STIGMATA_B:
			return player.stigmata_b_instance_id
		EQUIPMENT_SERVICE.SLOT_STIGMATA_C:
			return player.stigmata_c_instance_id
	return &""


func _equipment_slot_id(instance: EQUIPMENT_INSTANCE) -> StringName:
	if instance.equipment_type == EQUIPMENT_ENUMS.EquipmentType.RELIC:
		return EQUIPMENT_SERVICE.SLOT_RELIC
	match instance.stigmata_slot:
		EQUIPMENT_ENUMS.StigmataSlot.A:
			return EQUIPMENT_SERVICE.SLOT_STIGMATA_A
		EQUIPMENT_ENUMS.StigmataSlot.B:
			return EQUIPMENT_SERVICE.SLOT_STIGMATA_B
		EQUIPMENT_ENUMS.StigmataSlot.C:
			return EQUIPMENT_SERVICE.SLOT_STIGMATA_C
	return &""


func _equipment_slot_name(slot_id: StringName) -> String:
	match slot_id:
		EQUIPMENT_SERVICE.SLOT_RELIC:
			return "Kỷ Vật"
		EQUIPMENT_SERVICE.SLOT_STIGMATA_A:
			return "Vết Thánh A"
		EQUIPMENT_SERVICE.SLOT_STIGMATA_B:
			return "Vết Thánh B"
		EQUIPMENT_SERVICE.SLOT_STIGMATA_C:
			return "Vết Thánh C"
	return "Vị trí"


func _equipment_name(definition: EQUIPMENT_DEFINITION) -> String:
	return definition.display_name if definition != null else "Trang bị không xác định"


func _equipment_definition_type_name(definition: EQUIPMENT_DEFINITION) -> String:
	if definition.equipment_type == EQUIPMENT_ENUMS.EquipmentType.RELIC:
		return "Kỷ Vật"
	match definition.stigmata_slot:
		EQUIPMENT_ENUMS.StigmataSlot.A:
			return "Vết Thánh A"
		EQUIPMENT_ENUMS.StigmataSlot.B:
			return "Vết Thánh B"
		EQUIPMENT_ENUMS.StigmataSlot.C:
			return "Vết Thánh C"
	return "Vết Thánh"


func _selected_pending_choice_id() -> StringName:
	if perfect_choice_selector.item_count == 0 or perfect_choice_selector.selected < 0:
		return &""
	return StringName(
		perfect_choice_selector.get_item_metadata(perfect_choice_selector.selected)
	)


func _equipment_tier_name(tier: int) -> String:
	match tier:
		EQUIPMENT_ENUMS.Tier.S:
			return "S"
		EQUIPMENT_ENUMS.Tier.SS:
			return "SS"
	return "A"


func _render_round_summary() -> void:
	var rows: Array[Dictionary] = setup.round_summary_presentation(
		case_flow.match_state,
		case_flow.equipment_session.players,
		case_flow.active_round_start_merit_by_player()
	)
	var lines: Array[String] = [
		"[center][font_size=22][b][color=#f6c95c]🏆 TỔNG KẾT ROUND %d[/color][/b][/font_size][/center]\n" % case_flow.active_round_number(),
	]
	for row: Dictionary in rows:
		var rank_value: Variant = row.get("court_rank", {})
		var rank: Dictionary = rank_value as Dictionary if rank_value is Dictionary else {}
		var promotion_value: Variant = row.get("court_rank_promotion", {})
		var promotion: Dictionary = (
			promotion_value as Dictionary if promotion_value is Dictionary else {}
		)
		var rank_lines: Array[String] = []
		if bool(promotion.get("promoted", false)):
			rank_lines.append(
				"[color=#ff79c6][b]✨ THĂNG PHẨM! %s → %s[/b][/color]"
				% [
					String(promotion.get("before_rank_name", "Cửu phẩm")),
					String(promotion.get("after_rank_name", "Cửu phẩm")),
				]
			)
		rank_lines.append("🎖️ Phẩm cấp: [b][color=#f6c95c]%s[/color][/b]" % String(rank.get("rank_name", "Cửu phẩm")))
		if bool(rank.get("maximum_reached", false)):
			rank_lines.append(
				"⭐ %.0f Công Danh · [color=#ffb86c][b]Đã đạt phẩm cấp tối cao[/b][/color]"
				% float(rank.get("cumulative_merit", 0.0))
			)
		else:
			rank_lines.append(
				"⭐ %.0f / %d Công Danh (Còn thiếu %.0f để lên %s)"
				% [
					float(rank.get("cumulative_merit", 0.0)),
					int(rank.get("next_threshold", 0)),
					float(rank.get("merit_remaining", 0.0)),
					String(rank.get("next_rank_name", "phẩm tiếp theo")),
				]
			)
		var player_id: StringName = StringName(row.get("player_id", ""))
		var retained_items: Array[Dictionary] = case_flow.transferred_round_loot_items(
			player_id
		)
		var retained_line: String = ""
		if not retained_items.is_empty():
			var retained_names: Array[String] = []
			for item: Dictionary in retained_items:
				retained_names.append(
					_item_display_name(StringName(item.get("item_id", "")))
				)
			retained_line = "\n   🎒 Giữ lại từ vòng này: %s" % ", ".join(
				retained_names
			)
		lines.append(
			(
				"👤 [b]%s[/b] ([color=#8be9fd]%s[/color])\n"
				+ "   %s\n"
				+ "   🛡️ Danh Tiếng: %d  |  🔮 Orb: %d  |  🎟️ Vé: %d\n"
				+ "   📦 Trang bị: %d món  |  👑 Kỷ Vật: %s  |  ✨ Vết Thánh: %d/3%s"
			)
			% [
				String(row.get("display_name", "Người chơi")),
				String(row.get("character_name", "Nhân vật")),
				"\n".join(rank_lines),
				int(row.get("reputation", 0)),
				int(row.get("orb", 0)),
				int(row.get("tickets", 0)),
				int(row.get("equipment_count", 0)),
				"Đã trang bị" if bool(row.get("has_relic", false)) else "Trống",
				int(row.get("stigmata_count", 0)),
				retained_line,
			]
		)
	round_summary_text.text = "\n\n".join(lines)


func _render_match_results() -> void:
	var view: Dictionary = setup.match_results_presentation()
	var lines: Array[String] = [
		"[center]Hoàn tất sau %d Round · Điều kiện: %s[/center]"
		% [int(view.get("completed_round_count", 0)), String(view.get("target", ""))],
	]
	var standings_value: Variant = view.get("standings", [])
	if standings_value is Array:
		var standings: Array = standings_value as Array
		var place_counts: Dictionary = {}
		for counted_value: Variant in standings:
			if counted_value is Dictionary:
				var counted_row: Dictionary = counted_value
				var counted_place: int = int(counted_row.get("place", 0))
				place_counts[counted_place] = int(place_counts.get(counted_place, 0)) + 1
		for row_value: Variant in standings:
			if not row_value is Dictionary:
				continue
			var row: Dictionary = row_value
			lines.append(
				"[font_size=22][b]Hạng %d%s · %s[/b][/font_size]\n%s · %.0f Công Danh"
				% [
					int(row.get("place", 0)),
					" (đồng hạng)" if int(place_counts.get(int(row.get("place", 0)), 0)) > 1 else "",
					String(row.get("display_name", "Người chơi")),
					String(row.get("court_rank_name", "Cửu phẩm")),
					float(row.get("merit", 0.0)),
				]
			)
	match_results_text.text = "\n\n".join(lines)


func _refresh_next_case() -> void:
	var view: Dictionary = setup.case_presentation()
	next_case_title.text = "📜 " + String(view.get("name", "Kỳ Án Hoàng Cung"))
	next_case_description.text = String(view.get("description", ""))
	_refresh_procedural_next_case_options()
	_show_round_indicator(case_flow.match_state.current_round_number)


func _refresh_procedural_next_case_options() -> void:
	var options: Array[Dictionary] = _procedural_next_case_options()
	var has_options: bool = options.size() == 3
	next_case_options.visible = has_options
	start_next_case_button.visible = false
	start_next_case_button.disabled = true
	if not has_options:
		next_case_status.text = "Chưa có đủ ba Kỳ Án sinh tự động để lựa chọn."
		_set_next_case_option_button(next_case_option_1, {}, 0)
		_set_next_case_option_button(next_case_option_2, {}, 1)
		_set_next_case_option_button(next_case_option_3, {}, 2)
		return
	next_case_status.text = "Chọn một trong ba Kỳ Án sinh tự động."
	_set_next_case_option_button(next_case_option_1, options[0], 0)
	_set_next_case_option_button(next_case_option_2, options[1], 1)
	_set_next_case_option_button(next_case_option_3, options[2], 2)


func _procedural_next_case_options() -> Array[Dictionary]:
	if case_flow == null:
		return []
	return case_flow.case_option_presentations()


func _has_procedural_next_case_options() -> bool:
	return _procedural_next_case_options().size() == 3


func _set_next_case_option_button(button: Button, option: Dictionary, option_index: int) -> void:
	button.disabled = option.is_empty()
	if option.is_empty():
		button.text = "Kỳ Án %d" % (option_index + 1)
		button.tooltip_text = ""
		return
	var name: String = String(option.get("name", "Kỳ Án Sinh Tự Động"))
	var description: String = String(option.get("description", ""))
	button.text = "Kỳ Án %d\n%s\n%s" % [option_index + 1, name, description]
	button.tooltip_text = "Chọn Kỳ Án %d" % (option_index + 1)


func _show_round_indicator(round_number: int) -> void:
	round_indicator.text = "ROUND %d" % round_number
	round_indicator.visible = round_number > 0


func _player_name(player_id: StringName) -> String:
	if case_flow != null and case_flow.match_state != null:
		var player: PlayerMatchState = case_flow.match_state.find_player(player_id)
		if player != null and not player.display_name.is_empty():
			return player.display_name
	return "Người chơi"


func _node_display_name(node_id: StringName) -> String:
	if loot_map_view != null:
		return loot_map_view.label_for_node(node_id)
	return "Đường đi trong Hoàng Cung"


func _loot_action_guidance(
	session: LOOT_REWARD_SESSION, movement_player: LOOT_MOVEMENT_PLAYER_STATE
) -> String:
	match session.phase:
		LOOT_REWARD_SESSION.Phase.ITEM_WINDOW:
			return "Bấm [Z] để đổ xúc xắc · Hoặc dùng vật phẩm trong túi."
		LOOT_REWARD_SESSION.Phase.MOVEMENT:
			if movement_player.remaining_moves <= 0:
				return "Đã dùng hết thể lực di chuyển. Chuẩn bị chuyển lượt."
			return "Bấm [Z] để đổ xúc xắc di chuyển."
		LOOT_REWARD_SESSION.Phase.BAG_OVERFLOW_PENDING:
			return "⚠️ TÚI ĐỒ ĐẦY: Xử lý thay thế hoặc bỏ vật phẩm trước khi đi tiếp."
		LOOT_REWARD_SESSION.Phase.REWARD_RESOLUTION:
			return "Đang trích xuất phần thưởng tại các điểm vừa đi qua..."
		LOOT_REWARD_SESSION.Phase.BRANCH_SELECTION:
			return "⚠️ GẶP NGÃ RẼ: Bấm trực tiếp lên ô cờ vàng trên bản đồ để chọn hướng!"
		LOOT_REWARD_SESSION.Phase.LOOT_END_CONFIRMATION_READY:
			return "Mọi người đã hoàn tất Loot. Xác nhận để vào giai đoạn Trang Bị."
		_:
			return "Đang chờ trạng thái Loot..."


func _loot_failure_message(code: String) -> String:
	match code:
		"ITEM_WINDOW_REQUIRED":
			return "Hiện chưa đến Cửa sổ Vật phẩm."
		"MOVEMENT_ACTION_UNAVAILABLE":
			return "Chưa thể di chuyển: hãy xử lý bước đang chờ trước."
		"OVERFLOW_DISCARD_REJECTED", "OVERFLOW_SKIP_REJECTED":
			return "Không có tình huống Túi đầy cần xử lý."
		_:
			return "Hành động này chưa thể thực hiện lúc này."


func _round_loot_item_names(state: RoundLootInventoryState) -> String:
	if state == null or state.carried_items.is_empty():
		return "Túi hiện đang trống."
	var names: Array[String] = []
	for row: Dictionary in state.carried_items:
		names.append(_item_display_name(StringName(row.get("item_id", ""))))
	return " • " + "\n • ".join(names)


func _refresh_overflow_choice(
	session: LOOT_REWARD_SESSION, current_player_id: StringName
) -> void:
	overflow_target_selector.clear()
	var options: Array[Dictionary] = _overflow_replacement_options(
		session, current_player_id
	)
	for option: Dictionary in options:
		var item_id: StringName = StringName(option.get("item_id", ""))
		var inventory_index: int = int(option.get("inventory_index", -1))
		overflow_target_selector.add_item(
			"%d. %s" % [inventory_index + 1, _item_display_name(item_id)]
		)
		overflow_target_selector.set_item_metadata(
			overflow_target_selector.item_count - 1,
			{"inventory_index": inventory_index}
		)
	var has_targets: bool = not options.is_empty()
	if has_targets:
		overflow_target_selector.select(-1)
	overflow_target_selector.visible = false
	overflow_target_selector.disabled = not has_targets
	overflow_replace_button.visible = false
	overflow_replace_button.disabled = true
	var owns_choice: bool = (
		session != null
		and session.overflow.active
		and session.overflow.player_id == current_player_id
	)
	overflow_skip_button.disabled = not owns_choice
	if owns_choice and not has_targets:
		overflow_text.text = (
			"⚠️ TÚI ĐÃ ĐẦY!\nVật phẩm mới: %s\n"
			+ "Túi không có vật phẩm có thể thay thế. Hãy bỏ vật phẩm mới."
		) % _item_display_name(session.overflow.incoming_item_id)

	if incoming_item_label != null and session != null and session.overflow.active:
		var incoming_id: StringName = session.overflow.incoming_item_id
		incoming_item_label.text = "%s %s" % [_item_icon(incoming_id), _item_display_name(incoming_id)]

	if current_items_container != null:
		for child: Node in current_items_container.get_children():
			child.queue_free()

		if session != null and session.overflow.active:
			for option: Dictionary in options:
				var item_id: StringName = StringName(option.get("item_id", ""))
				var inventory_index: int = int(option.get("inventory_index", -1))
				var btn: Button = Button.new()
				btn.custom_minimum_size = Vector2(130, 56)
				btn.focus_mode = Control.FOCUS_NONE
				btn.add_theme_stylebox_override("normal", _pummel_slot_style)
				btn.text = "%s\n%s" % [_item_icon(item_id), _item_display_name(item_id)]
				btn.tooltip_text = "Thay thế %s bằng vật phẩm mới" % _item_display_name(item_id)
				btn.disabled = not owns_choice
				btn.pressed.connect(_on_overflow_current_item_clicked.bind(inventory_index, item_id))
				current_items_container.add_child(btn)


func _on_overflow_current_item_clicked(inventory_index: int, item_id: StringName) -> void:
	if case_flow == null or case_flow.loot_session == null:
		return
	var session: LOOT_REWARD_SESSION = case_flow.loot_session
	_pending_replace_index = inventory_index
	if replace_confirm_modal != null:
		if replace_confirm_prompt != null:
			replace_confirm_prompt.text = "Bạn có muốn thay thế item \"%s\"?" % _item_display_name(item_id)
		if replace_confirm_sub != null:
			replace_confirm_sub.text = "(Vật phẩm mới \"%s\" sẽ được thêm vào túi)" % _item_display_name(session.overflow.incoming_item_id)
		replace_confirm_modal.visible = true


func _on_confirm_replace_accepted() -> void:
	if replace_confirm_modal != null:
		replace_confirm_modal.visible = false
	if _pending_replace_index >= 0:
		var idx: int = _pending_replace_index
		_pending_replace_index = -1
		_handle_loot_result(case_flow.resolve_overflow_discard(idx))


func _on_cancel_replace_dismissed() -> void:
	if replace_confirm_modal != null:
		replace_confirm_modal.visible = false
	_pending_replace_index = -1


func _overflow_replacement_options(
	session: LOOT_REWARD_SESSION, current_player_id: StringName
) -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	if (
		session == null
		or not session.overflow.active
		or session.overflow.player_id != current_player_id
	):
		return options
	var state: RoundLootInventoryState = session.find_round_loot_state(current_player_id)
	if state == null or state.disposition_finalized or state.capacity <= 0:
		return options
	for index: int in range(state.carried_items.size()):
		var row: Dictionary = state.carried_items[index]
		options.append({
			"inventory_index": index,
			"item_id": String(row.get("item_id", "")),
		})
	return options


func overflow_replacement_options_for_smoke(
	session: LOOT_REWARD_SESSION, current_player_id: StringName
) -> Array[Dictionary]:
	return _overflow_replacement_options(session, current_player_id)


func _refresh_item_source_selector(
	player: PLAYER_PHASE_STATE, round_loot: RoundLootInventoryState
) -> void:
	item_source_selector.clear()
	if player != null:
		for row: Dictionary in player.consumable_inventory:
			var item_id: StringName = StringName(row.get("item_id", ""))
			item_source_selector.add_item(
				"%s — Đồ đang sở hữu" % _item_display_name(item_id)
			)
			item_source_selector.set_item_metadata(
				item_source_selector.item_count - 1,
				{"item_id": String(item_id), "source": "persistent"}
			)
	if round_loot != null and not round_loot.disposition_finalized:
		for row: Dictionary in round_loot.carried_items:
			var item_id: StringName = StringName(row.get("item_id", ""))
			item_source_selector.add_item(
				"%s — Nhặt trong vòng này" % _item_display_name(item_id)
			)
			item_source_selector.set_item_metadata(
				item_source_selector.item_count - 1,
				{"item_id": String(item_id), "source": "round_loot"}
			)


func _item_display_name(item_id: StringName) -> String:
	if case_flow != null:
		var display_name: String = case_flow.consumable_item_display_name(item_id)
		if not display_name.is_empty():
			return display_name
	return String(item_id) if item_id != &"" else "Vật phẩm hành trình"


func _append_latest_reward_feedback() -> void:
	if case_flow == null or case_flow.loot_session == null:
		return
	var session: LOOT_REWARD_SESSION = case_flow.loot_session
	while _logged_reward_count < session.reward_history.size():
		var reward: REWARD_RESOLUTION_RESULT = session.reward_history[_logged_reward_count]
		var line: String = "🎁 Nhận: [b]%s[/b]" % _reward_type_name(reward.reward_type)
		if reward.reward_amount > 0:
			line += " +%d" % reward.reward_amount
		if reward.overflow_required:
			line += " [color=#ff5555](Túi đầy!)[/color]"
		else:
			line += "."
		_loot_activity_lines.append(line)
		_logged_reward_count += 1


func _trim_loot_log() -> void:
	while _loot_activity_lines.size() > 6:
		_loot_activity_lines.pop_front()


func _recent_reward_text() -> String:
	if case_flow.loot_session.reward_history.is_empty():
		return "Chưa nhận phần thưởng trong lượt này."
	var reward: REWARD_RESOLUTION_RESULT = case_flow.loot_session.reward_history.back()
	return "Phần thưởng gần nhất: %s" % _reward_type_name(reward.reward_type)


func _reward_type_name(reward_type: int) -> String:
	match reward_type:
		0:
			return "Xu Bạc"
		1:
			return "Orb"
		2:
			return "Vé"
		3:
			return "Vật phẩm"
		_:
			return "Phần thưởng hành trình"


func _show_phase(next_phase: int) -> void:
	round_indicator.visible = next_phase in [
		SETUP_SESSION.Phase.CASE_SELECTION_READY,
		SETUP_SESSION.Phase.CASE_ACTIVE,
		SETUP_SESSION.Phase.CASE_RESULTS,
		SETUP_SESSION.Phase.LOOT_READY,
		SETUP_SESSION.Phase.LOOT_ACTIVE,
		SETUP_SESSION.Phase.LOOT_END_CONFIRMATION,
		SETUP_SESSION.Phase.EQUIPMENT_MANAGEMENT,
		SETUP_SESSION.Phase.ROUND_SUMMARY_READY,
		SETUP_SESSION.Phase.ROUND_SUMMARY,
		SETUP_SESSION.Phase.NEXT_CASE_SELECTION,
	]
	if safe_margin != null:
		safe_margin.visible = (
			next_phase != SETUP_SESSION.Phase.CASE_ACTIVE
			and next_phase != SETUP_SESSION.Phase.LOOT_ACTIVE
			and next_phase != SETUP_SESSION.Phase.EQUIPMENT_MANAGEMENT
		)
	main_menu.visible = next_phase == SETUP_SESSION.Phase.MAIN_MENU
	match_mode.visible = next_phase == SETUP_SESSION.Phase.MATCH_MODE
	match_rules_panel.visible = next_phase == SETUP_SESSION.Phase.MATCH_RULES
	player_count.visible = next_phase == SETUP_SESSION.Phase.PLAYER_COUNT
	character_selection.visible = next_phase == SETUP_SESSION.Phase.CHARACTER_SELECTION
	pass_device.visible = next_phase == SETUP_SESSION.Phase.PASS_DEVICE
	lineup_confirmation.visible = next_phase == SETUP_SESSION.Phase.LINEUP_CONFIRMATION
	case_selection.visible = next_phase == SETUP_SESSION.Phase.CASE_SELECTION_READY
	case_host.visible = next_phase == SETUP_SESSION.Phase.CASE_ACTIVE
	results_panel.visible = next_phase == SETUP_SESSION.Phase.CASE_RESULTS
	loot_ready_panel.visible = next_phase == SETUP_SESSION.Phase.LOOT_READY
	loot_panel.visible = next_phase == SETUP_SESSION.Phase.LOOT_ACTIVE
	if next_phase == SETUP_SESSION.Phase.LOOT_ACTIVE:
		var current_focus := get_viewport().gui_get_focus_owner()
		if current_focus != null:
			current_focus.release_focus()
	confirmation_panel.visible = next_phase == SETUP_SESSION.Phase.LOOT_END_CONFIRMATION
	equipment_panel.visible = false
	round_summary_ready_panel.visible = next_phase == SETUP_SESSION.Phase.ROUND_SUMMARY_READY
	round_summary_panel.visible = next_phase == SETUP_SESSION.Phase.ROUND_SUMMARY
	next_case_panel.visible = next_phase == SETUP_SESSION.Phase.NEXT_CASE_SELECTION
	settings_panel.visible = next_phase == SETUP_SESSION.Phase.SETTINGS
	match_results_panel.visible = next_phase == SETUP_SESSION.Phase.MATCH_RESULTS
	if _character_sheet != null and next_phase != SETUP_SESSION.Phase.LOOT_ACTIVE and next_phase != SETUP_SESSION.Phase.EQUIPMENT_MANAGEMENT:
		_character_sheet.visible = false


func _show_message(message: String, is_error: bool = false) -> void:
	message_label.text = message
	message_label.modulate = Color(1.0, 0.45, 0.45) if is_error else Color(0.5, 0.9, 1.0)


func _init_cheat_layer() -> void:
	_cheat_layer = CanvasLayer.new()
	_cheat_layer.name = "CheatLayer"
	_cheat_layer.layer = 140
	add_child(_cheat_layer)

	_cheat_overlay = Control.new()
	_cheat_overlay.name = "CheatOverlay"
	_cheat_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cheat_overlay.visible = false
	_cheat_layer.add_child(_cheat_overlay)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.0, 0.0, 0.0, 0.75)
	_cheat_overlay.add_child(backdrop)

	var center_box := CenterContainer.new()
	center_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cheat_overlay.add_child(center_box)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(760, 560)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.11, 0.15, 0.98)
	style.border_color = Color(0.3, 0.75, 1.0, 0.9)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	style.content_margin_left = 24.0
	style.content_margin_top = 20.0
	style.content_margin_right = 24.0
	style.content_margin_bottom = 20.0
	panel.add_theme_stylebox_override("panel", style)
	center_box.add_child(panel)

	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 12)
	panel.add_child(main_vbox)

	var header_hbox := HBoxContainer.new()
	var title_lbl := Label.new()
	title_lbl.text = "🛠️ MENU CHEAT KIỂM THỬ [F10]"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0))
	header_hbox.add_child(title_lbl)

	var close_btn := Button.new()
	close_btn.text = "✖ ĐÓNG [F10 / ESC]"
	close_btn.custom_minimum_size = Vector2(160, 36)
	close_btn.pressed.connect(func() -> void: _cheat_overlay.visible = false)
	header_hbox.add_child(close_btn)
	main_vbox.add_child(header_hbox)

	var desc_lbl := Label.new()
	desc_lbl.text = "Bảng cheat tạm phục vụ thử nghiệm nâng cấp Kỷ Vật, Vết Thánh, EXP và vật phẩm."
	desc_lbl.add_theme_font_size_override("font_size", 12)
	desc_lbl.add_theme_color_override("font_color", Color(0.68, 0.72, 0.78))
	main_vbox.add_child(desc_lbl)

	var player_box := HBoxContainer.new()
	player_box.add_theme_constant_override("separation", 12)
	var prev_player_btn := Button.new()
	prev_player_btn.text = "◀ P Trước"
	prev_player_btn.custom_minimum_size = Vector2(110, 34)
	prev_player_btn.pressed.connect(func() -> void: _cycle_cheat_target_player(-1))
	player_box.add_child(prev_player_btn)

	_cheat_player_lbl = Label.new()
	_cheat_player_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cheat_player_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cheat_player_lbl.add_theme_font_size_override("font_size", 14)
	_cheat_player_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	player_box.add_child(_cheat_player_lbl)

	var next_player_btn := Button.new()
	next_player_btn.text = "P Sau ▶"
	next_player_btn.custom_minimum_size = Vector2(110, 34)
	next_player_btn.pressed.connect(func() -> void: _cycle_cheat_target_player(1))
	player_box.add_child(next_player_btn)
	main_vbox.add_child(player_box)

	_cheat_feedback_lbl = Label.new()
	_cheat_feedback_lbl.text = "Sẵn sàng."
	_cheat_feedback_lbl.add_theme_font_size_override("font_size", 13)
	_cheat_feedback_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
	_cheat_feedback_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(_cheat_feedback_lbl)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	main_vbox.add_child(grid)

	_add_cheat_btn(grid, "💎 +100 EXP Kỷ Vật", func() -> void:
		var p := _get_cheat_target_player()
		if p != null:
			p.relic_exp_material_count += 100
			_notify_cheat("Đã thêm 100 EXP Kỷ Vật!")
			_refresh_after_cheat()
	)
	_add_cheat_btn(grid, "💎 +1000 EXP Kỷ Vật", func() -> void:
		var p := _get_cheat_target_player()
		if p != null:
			p.relic_exp_material_count += 1000
			_notify_cheat("Đã thêm 1000 EXP Kỷ Vật!")
			_refresh_after_cheat()
	)
	_add_cheat_btn(grid, "🔮 +100 EXP Vết Thánh", func() -> void:
		var p := _get_cheat_target_player()
		if p != null:
			p.stigmata_exp_material_count += 100
			_notify_cheat("Đã thêm 100 EXP Vết Thánh!")
			_refresh_after_cheat()
	)
	_add_cheat_btn(grid, "🔮 +1000 EXP Vết Thánh", func() -> void:
		var p := _get_cheat_target_player()
		if p != null:
			p.stigmata_exp_material_count += 1000
			_notify_cheat("Đã thêm 1000 EXP Vết Thánh!")
			_refresh_after_cheat()
	)
	_add_cheat_btn(grid, "🎟️ +10 Vé Gacha", func() -> void:
		var p := _get_cheat_target_player()
		if p != null:
			p.gacha_ticket_count += 10
			_notify_cheat("Đã thêm 10 Vé Gacha!")
			_refresh_after_cheat()
	)
	_add_cheat_btn(grid, "🪙 +5000 Xu Bạc", func() -> void:
		var p := _get_cheat_target_player()
		if p != null:
			p.silver_coin_count += 5000
			_notify_cheat("Đã thêm 5000 Xu Bạc!")
			_refresh_after_cheat()
	)
	_add_cheat_btn(grid, "🎁 Bản Trùng Kỷ Vật (Đang Mang)", func() -> void:
		_cheat_grant_duplicate_equipped(&"relic")
	)
	_add_cheat_btn(grid, "🎁 Bản Trùng Vết Thánh A", func() -> void:
		_cheat_grant_duplicate_equipped(&"stigmata_a")
	)
	_add_cheat_btn(grid, "🎁 Bản Trùng Vết Thánh B", func() -> void:
		_cheat_grant_duplicate_equipped(&"stigmata_b")
	)
	_add_cheat_btn(grid, "⭐ Set 6★ Vàng (Kỷ Vật)", func() -> void:
		_cheat_set_relic_stars(6, 0)
	)
	_add_cheat_btn(grid, "🟣 Set 6★ Tím (Kỷ Vật)", func() -> void:
		_cheat_set_relic_stars(6, 6)
	)
	_add_cheat_btn(grid, "🔄 Reset 0★ (Kỷ Vật)", func() -> void:
		_cheat_set_relic_stars(0, 0)
	)
	_add_cheat_btn(grid, "⭐ Set 6★ Vàng (Vết Thánh A)", func() -> void:
		_cheat_set_stigmata_stars(&"stigmata_a", 6, 0)
	)
	_add_cheat_btn(grid, "🟣 Set 6★ Tím (Vết Thánh A)", func() -> void:
		_cheat_set_stigmata_stars(&"stigmata_a", 6, 6)
	)
	_add_cheat_btn(grid, "🔄 Reset 0★ (Vết Thánh A)", func() -> void:
		_cheat_set_stigmata_stars(&"stigmata_a", 0, 0)
	)


func _toggle_cheat_menu() -> void:
	if _cheat_overlay == null:
		return
	_cheat_overlay.visible = not _cheat_overlay.visible
	if _cheat_overlay.visible:
		_refresh_cheat_player_display()


func _refresh_cheat_player_display() -> void:
	var player := _get_cheat_target_player()
	if player == null:
		if _cheat_player_lbl != null:
			_cheat_player_lbl.text = "⚠️ Chưa có người chơi trong phiên"
		return
	var char_def: CHARACTER_DEFINITION = setup.find_character(player.character_id) if setup != null else null
	var name_str: String = char_def.display_name if char_def != null else String(player.player_id)
	if _cheat_player_lbl != null:
		_cheat_player_lbl.text = "🎯 Đang chọn: P%d - %s  (Relic EXP: %d | Stig EXP: %d | Vé: %d | Xu: %d)" % [
			player.seat_index + 1,
			name_str,
			player.relic_exp_material_count,
			player.stigmata_exp_material_count,
			player.gacha_ticket_count,
			player.silver_coin_count,
		]


func _get_all_active_players() -> Array:
	if case_flow != null and case_flow.equipment_session != null and not case_flow.equipment_session.players.is_empty():
		return case_flow.equipment_session.players
	if case_flow != null and case_flow.loot_session != null and not case_flow.loot_session.players.is_empty():
		return case_flow.loot_session.players
	if setup != null and not setup.players.is_empty():
		return setup.players
	return []


func _get_cheat_target_player() -> PLAYER_PHASE_STATE:
	var list := _get_all_active_players()
	if list.is_empty():
		return null
	if _cheat_target_player_index < 0 or _cheat_target_player_index >= list.size():
		_cheat_target_player_index = 0
	return list[_cheat_target_player_index] as PLAYER_PHASE_STATE


func _cycle_cheat_target_player(delta: int) -> void:
	var list := _get_all_active_players()
	if list.is_empty():
		return
	_cheat_target_player_index = (_cheat_target_player_index + delta + list.size()) % list.size()
	_refresh_cheat_player_display()


func _notify_cheat(msg: String, is_err: bool = false) -> void:
	if _cheat_feedback_lbl != null:
		_cheat_feedback_lbl.text = msg
		_cheat_feedback_lbl.add_theme_color_override(
			"font_color",
			Color(1.0, 0.45, 0.45) if is_err else Color(0.3, 1.0, 0.5)
		)


func _refresh_after_cheat() -> void:
	_refresh_cheat_player_display()
	if _character_sheet != null and _character_sheet.visible:
		_character_sheet.refresh()
	if case_flow != null and case_flow.loot_session != null and loot_panel != null and loot_panel.visible:
		_refresh_pummel_player_cards(case_flow.loot_session)


func _cheat_grant_duplicate_equipped(slot_id: StringName) -> void:
	var player := _get_cheat_target_player()
	if player == null:
		_notify_cheat("Không tìm thấy người chơi mục tiêu!", true)
		return
	var inst_id: StringName = &""
	match slot_id:
		&"relic":
			inst_id = player.relic_instance_id
		&"stigmata_a":
			inst_id = player.stigmata_a_instance_id
		&"stigmata_b":
			inst_id = player.stigmata_b_instance_id
	if inst_id.is_empty():
		_notify_cheat("Người chơi chưa trang bị vị trí này!", true)
		return
	var target_item: EQUIPMENT_INSTANCE = null
	for item: EQUIPMENT_INSTANCE in player.equipment_collection:
		if item.instance_id == inst_id:
			target_item = item
			break
	if target_item == null:
		_notify_cheat("Không tìm thấy dữ liệu trang bị đã mang!", true)
		return
	var dup := EQUIPMENT_INSTANCE.new()
	dup.instance_id = StringName("%s_dup_%d" % [String(target_item.equipment_definition_id), Time.get_ticks_msec()])
	dup.equipment_definition_id = target_item.equipment_definition_id
	dup.owner_player_id = player.player_id
	dup.equipment_type = target_item.equipment_type
	dup.stigmata_slot = target_item.stigmata_slot
	dup.tier = target_item.tier
	dup.gold_star_level = 0
	dup.purple_star_level = 0
	dup.acquired_source = &"CHEAT_F10"
	player.equipment_collection.append(dup)
	_notify_cheat("Đã thêm 1 bản trùng [0★] của %s vào túi!" % String(target_item.equipment_definition_id))
	_refresh_after_cheat()


func _cheat_set_relic_stars(gold: int, purple: int) -> void:
	var player := _get_cheat_target_player()
	if player == null or player.relic_instance_id.is_empty():
		_notify_cheat("Người chơi chưa trang bị Kỷ Vật!", true)
		return
	for item: EQUIPMENT_INSTANCE in player.equipment_collection:
		if item.instance_id == player.relic_instance_id:
			item.gold_star_level = clampi(gold, 0, 6)
			item.purple_star_level = clampi(purple, 0, item.gold_star_level)
			_notify_cheat("Đã đặt Kỷ Vật: %d★ Vàng, %d★ Tím!" % [item.gold_star_level, item.purple_star_level])
			_refresh_after_cheat()
			return
	_notify_cheat("Không tìm thấy Kỷ Vật!", true)


func _cheat_set_stigmata_stars(slot_id: StringName, gold: int, purple: int) -> void:
	var player := _get_cheat_target_player()
	if player == null:
		_notify_cheat("Không tìm thấy người chơi mục tiêu!", true)
		return
	var inst_id: StringName = player.stigmata_a_instance_id if slot_id == &"stigmata_a" else player.stigmata_b_instance_id
	if inst_id.is_empty():
		_notify_cheat("Người chơi chưa trang bị Vết Thánh này!", true)
		return
	for item: EQUIPMENT_INSTANCE in player.equipment_collection:
		if item.instance_id == inst_id:
			item.gold_star_level = clampi(gold, 0, 6)
			item.purple_star_level = clampi(purple, 0, item.gold_star_level)
			_notify_cheat("Đã đặt Vết Thánh: %d★ Vàng, %d★ Tím!" % [item.gold_star_level, item.purple_star_level])
			_refresh_after_cheat()
			return
	_notify_cheat("Không tìm thấy Vết Thánh!", true)


func _add_cheat_btn(parent: Node, label_text: String, callback: Callable) -> Button:
	var btn := Button.new()
	btn.text = label_text
	btn.custom_minimum_size = Vector2(220, 42)
	btn.focus_mode = Control.FOCUS_NONE
	btn.pressed.connect(callback)
	parent.add_child(btn)
	return btn
