class_name VSCaseMainController
extends Control

const MVP_CASE_COMPLETION_BOUNDARY := preload(
	"res://scripts/domain/mvp/MvpCaseCompletionBoundary.gd"
)
const CASE_ROLE_POOL_SERVICE := preload("res://scripts/domain/cases/CaseRolePoolService.gd")
const CASE_TIMED_EVENT_DISPATCHER := preload("res://scripts/domain/cases/CaseTimedEventDispatcher.gd")
const ROLE_GLOSSARY_TOOLTIP_SCENE := preload("res://scenes/shared_ui/RoleGlossaryTooltip.tscn")
const CASE_BODY_FONT: Font = preload("res://assets/fonts/Arial.ttf")
const SOLVER_INSPECTION := preload("res://scripts/tools/CaseSolverInspectionService.gd")
const CASE_GENERATION_AUDIT_SNAPSHOT := preload("res://scripts/tools/CaseGenerationAuditSnapshot.gd")

signal integration_case_completed(boundary: RefCounted)
signal integration_truth_acknowledged

@onready var case_name_label: Label = get_node_or_null("%CaseNameLabel") as Label
@onready var case_id_label: Label = get_node_or_null("%CaseIdLabel") as Label
@onready var difficulty_label: Label = get_node_or_null("%DifficultyLabel") as Label
@onready var merit_label: Label = get_node_or_null("%MeritLabel") as Label
@onready var description_label: RichTextLabel = get_node_or_null("%DescriptionLabel") as RichTextLabel
@onready var elapsed_hours_label: Label = get_node_or_null("%ElapsedHoursLabel") as Label
@onready var turn_label: Label = get_node_or_null("%TurnLabel") as Label
@onready var player_strip_label: RichTextLabel = get_node_or_null("%PlayerStripLabel") as RichTextLabel
@onready var recent_log_label: Label = get_node_or_null("%RecentLogLabel") as Label
@onready var action_reason: Label = get_node_or_null("%ActionReason") as Label
@onready var safe_margin: MarginContainer = get_node_or_null("SafeMargin") as MarginContainer
@onready var main_column: VBoxContainer = get_node_or_null("SafeMargin/MainColumn") as VBoxContainer
@onready var dev_nav_row: HBoxContainer = get_node_or_null("SafeMargin/MainColumn/DevNavRow") as HBoxContainer
@onready var content_root: HBoxContainer = get_node_or_null("%ContentRoot") as HBoxContainer
@onready var info_panel: PanelContainer = get_node_or_null("SafeMargin/MainColumn/ContentRoot/InfoPanel") as PanelContainer
@onready var role_panel: PanelContainer = get_node_or_null("%RolePanel") as PanelContainer
@onready var role_list: VBoxContainer = get_node_or_null("%RoleList") as VBoxContainer
@onready var selection_prompt: Label = get_node_or_null("%SelectionPrompt") as Label
@onready var function_picker: OptionButton = get_node_or_null("%FunctionPicker") as OptionButton
@onready var submission_classification_panel: VBoxContainer = get_node_or_null("%SubmissionClassificationPanel") as VBoxContainer
@onready var investigate_button: Button = get_node_or_null("%InvestigateButton") as Button
@onready var private_knowledge_button: Button = get_node_or_null("%PrivateKnowledgeButton") as Button
@onready var single_accuse_button: Button = get_node_or_null("%SingleAccuseButton") as Button
@onready var function_button: Button = get_node_or_null("%FunctionButton") as Button
@onready var submit_button: Button = get_node_or_null("%SubmitButton") as Button
@onready var final_result_label: Label = get_node_or_null("%FinalResultLabel") as Label
@onready var final_handoff_overlay: Control = get_node_or_null("%FinalHandoffOverlay") as Control
@onready var final_handoff_player_label: Label = get_node_or_null("%FinalHandoffPlayerLabel") as Label
@onready var confirmation_row: HBoxContainer = get_node_or_null("%ConfirmationRow") as HBoxContainer
@onready var confirm_button: Button = get_node_or_null("%ConfirmButton") as Button
@onready var cancel_button: Button = get_node_or_null("%CancelButton") as Button
@onready var board: CaseBoardController = get_node_or_null("%CaseBoard") as CaseBoardController
@onready var board_help_label: Label = get_node_or_null("%BoardHelpLabel") as Label
@onready var center_column: VBoxContainer = get_node_or_null(
	"SafeMargin/MainColumn/ContentRoot/CenterColumn"
) as VBoxContainer
@onready var error_panel: PanelContainer = get_node_or_null("%ErrorPanel") as PanelContainer
@onready var error_summary: Label = get_node_or_null("%ErrorSummary") as Label
@onready var truth_reveal_panel: PanelContainer = get_node_or_null("%TruthRevealPanel") as PanelContainer
@onready var truth_answer_label: Label = get_node_or_null("%TruthAnswerLabel") as Label
@onready var truth_suspects_label: Label = get_node_or_null("%TruthSuspectsLabel") as Label
@onready var truth_players_label: Label = get_node_or_null("%TruthPlayersLabel") as Label
@onready var truth_rewards_label: Label = get_node_or_null("%TruthRewardsLabel") as Label
@onready var truth_functions_label: Label = get_node_or_null("%TruthFunctionsLabel") as Label
@onready var cursor_feedback: InvestigationCursorFeedback = get_node_or_null("%CursorFeedback") as InvestigationCursorFeedback
@onready var role_reference_overlay: Control = get_node_or_null("%RoleReferenceOverlay") as Control
@onready var role_reference_title: Label = get_node_or_null("%RoleReferenceTitle") as Label
@onready var role_reference_body: RichTextLabel = get_node_or_null("%RoleReferenceBody") as RichTextLabel
@onready var role_reference_close_button: Button = get_node_or_null("%RoleReferenceCloseButton") as Button
@onready var private_knowledge_overlay: Control = get_node_or_null("%PrivateKnowledgeOverlay") as Control
@onready var private_knowledge_body: Label = get_node_or_null("%PrivateKnowledgeBody") as Label
@onready var private_knowledge_close_button: Button = get_node_or_null("%PrivateKnowledgeCloseButton") as Button
@onready var tutorial_dialogue_overlay: Control = get_node_or_null("%TutorialDialogueOverlay") as Control
@onready var tutorial_dialogue_body: Label = get_node_or_null("%TutorialDialogueBody") as Label
@onready var tutorial_dialogue_speaker_label: Label = get_node_or_null("%TutorialDialogueSpeakerLabel") as Label
@onready var tutorial_dialogue_progress_label: Label = get_node_or_null("%TutorialDialogueProgressLabel") as Label
@onready var tutorial_dialogue_left_portrait: ColorRect = get_node_or_null("%TutorialDialogueLeftPortrait") as ColorRect
@onready var tutorial_dialogue_right_portrait: ColorRect = get_node_or_null("%TutorialDialogueRightPortrait") as ColorRect
@onready var debug_solver_button: Button = get_node_or_null("%DebugSolverButton") as Button
@onready var solver_inspection_overlay: Control = get_node_or_null("%SolverInspectionOverlay") as Control
@onready var solver_inspection_body: RichTextLabel = get_node_or_null("%SolverInspectionBody") as RichTextLabel
@onready var solver_inspection_close_button: Button = get_node_or_null("%SolverInspectionCloseButton") as Button

var case_definition: CaseDefinition
var role_definitions: Array[RoleDefinition] = []
var runtime_state: CaseRuntimeState
var turn_manager := TurnManager.new()
var investigation_service := InvestigationService.new()
var function_availability_service := FunctionAvailabilityService.new()
var function_execution_service := InteractiveFunctionExecutionService.new()
var post_reveal_function_service := PostRevealFunctionService.new()
var submission_service := CaseSubmissionService.new()
var single_accusation_service := SingleSuspectAccusationService.new()
var case_clock_service: CaseClockService = CaseClockService.new()
var timed_event_dispatcher = CASE_TIMED_EVENT_DISPATCHER.new()
var final_verdict_service := FinalVerdictService.new()
var selection_state := InvestigationSelectionState.new()
var final_handoff_active := false
var final_initialized := false
var settlement_service := CaseSettlementService.new()
var truth_reveal_builder := CaseTruthRevealBuilder.new()
var integration_mode := false
var player_facing_mode := false
var integration_players: Array[PlayerCaseState] = []
var integration_case_definition: CaseDefinition
var _integration_completion_emitted := false
var _integration_truth_acknowledged := false
var _final_handoff_tween: Tween
var _private_overlay_player_id: StringName
var _role_glossary_tooltip: RoleGlossaryTooltipController
var _tutorial_dialogue_active := false
var _tutorial_dialogue_completed := false
var _tutorial_dialogue_index := 0


func configure_integrated_case(
	players: Array[PlayerCaseState],
	use_player_facing_copy: bool = false,
	selected_case: CaseDefinition = null
) -> void:
	integration_mode = true
	player_facing_mode = use_player_facing_copy
	integration_case_definition = selected_case
	integration_players.clear()
	for player: PlayerCaseState in players:
		integration_players.append(player)


func _ready() -> void:
	RoleReferenceFormatter.apply_uniform_body_font(role_reference_body)
	_apply_case_typography()
	_setup_role_glossary_hover()
	if board != null:
		if not board.suspect_selected.is_connected(_on_suspect_selected):
			board.suspect_selected.connect(_on_suspect_selected)
		if not board.suspect_action.is_connected(_on_suspect_action):
			board.suspect_action.connect(_on_suspect_action)
		if not board.suspect_hold_progress_started.is_connected(_on_suspect_hold_progress_started):
			board.suspect_hold_progress_started.connect(_on_suspect_hold_progress_started)
		if not board.suspect_hold_progress_canceled.is_connected(_on_suspect_hold_progress_canceled):
			board.suspect_hold_progress_canceled.connect(_on_suspect_hold_progress_canceled)
	if submit_button != null and not submit_button.pressed.is_connected(_on_submit_pressed):
		submit_button.pressed.connect(_on_submit_pressed)
	if confirm_button != null and not confirm_button.pressed.is_connected(_on_confirm_pressed):
		confirm_button.pressed.connect(_on_confirm_pressed)
	if cancel_button != null and not cancel_button.pressed.is_connected(_on_cancel_pressed):
		cancel_button.pressed.connect(_on_cancel_pressed)
	if private_knowledge_button != null and not private_knowledge_button.pressed.is_connected(_on_private_knowledge_pressed):
		private_knowledge_button.pressed.connect(_on_private_knowledge_pressed)
	if single_accuse_button != null and not single_accuse_button.pressed.is_connected(_on_single_accuse_pressed):
		single_accuse_button.pressed.connect(_on_single_accuse_pressed)
	if role_reference_close_button != null and not role_reference_close_button.pressed.is_connected(_close_role_reference):
		role_reference_close_button.pressed.connect(_close_role_reference)
	if private_knowledge_close_button != null and not private_knowledge_close_button.pressed.is_connected(_close_private_knowledge):
		private_knowledge_close_button.pressed.connect(_close_private_knowledge)
	var dev_back_button: Button = find_child("DevBackButton", true, false) as Button
	if dev_back_button != null and not dev_back_button.pressed.is_connected(_on_back_pressed):
		dev_back_button.pressed.connect(_on_back_pressed)
	if debug_solver_button != null and not debug_solver_button.pressed.is_connected(_on_debug_solver_pressed):
		debug_solver_button.pressed.connect(_on_debug_solver_pressed)
	if solver_inspection_close_button != null and not solver_inspection_close_button.pressed.is_connected(_close_solver_inspection):
		solver_inspection_close_button.pressed.connect(_close_solver_inspection)
	_load_and_start_fresh_runtime()


func _apply_case_typography() -> void:
	if board_help_label != null:
		board_help_label.add_theme_font_override("font", CASE_BODY_FONT)


func _input(event: InputEvent) -> void:
	if _tutorial_dialogue_active:
		if event is InputEventMouseButton:
			var tutorial_mouse_button: InputEventMouseButton = event as InputEventMouseButton
			if tutorial_mouse_button.pressed and tutorial_mouse_button.button_index == MOUSE_BUTTON_LEFT:
				_advance_tutorial_dialogue()
			get_viewport().set_input_as_handled()
			return
		if event is InputEventKey:
			var tutorial_key: InputEventKey = event as InputEventKey
			if tutorial_key.pressed and not tutorial_key.echo and tutorial_key.is_action_pressed("ui_accept"):
				_advance_tutorial_dialogue()
				get_viewport().set_input_as_handled()
				return
	if selection_state == null or selection_state.mode != InvestigationSelectionState.Mode.SELECTING_FUNCTION_TARGETS:
		return
	if event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_RIGHT and mouse_button.pressed:
			_on_cancel_pressed()
			get_viewport().set_input_as_handled()


func _load_and_start_fresh_runtime() -> void:
	case_definition = integration_case_definition if integration_case_definition != null else AppFlow.take_pending_case_definition()
	if case_definition == null:
		case_definition = FixtureRepository.load_case()
	if case_definition == null:
		_show_error("CASE_LOAD_FAILED", "Không tìm thấy fixture Kỳ Án.")
		AppLogger.error("Vertical Slice fixture load failed")
		return
	role_definitions = FixtureRepository.load_roles()
	var players: Array[PlayerCaseState] = (
		integration_players if integration_mode else FixtureRepository.load_players()
	)
	var report := CaseDefinitionValidator.new().validate(case_definition, role_definitions, players)
	AppLogger.info("Case fixture: %s | validation: %s | suspects: %d" % [
		case_definition.case_id,
		"PASS" if report.passed else "FAIL",
		case_definition.suspects.size(),
	])
	if not report.passed:
		var codes: Array[String] = []
		for validation_error in report.errors:
			codes.append(validation_error.code)
		_show_error("CASE_VALIDATION_FAILED", ", ".join(codes))
		return
	runtime_state = CaseRuntimeState.new()
	runtime_state.initialize(case_definition, players)
	_apply_startup_case_effects()
	function_availability_service.initialize_hidden_states(case_definition, runtime_state, role_definitions)
	_apply_visual_sample_runtime_state()
	var tie_seed := _new_tie_break_seed()
	if not turn_manager.initialize(runtime_state.players, tie_seed):
		_show_error("TURN_INIT_FAILED", "Không thể khởi tạo thứ tự lượt.")
		return
	runtime_state.apply_turn_snapshot(turn_manager)
	AppLogger.info("Turn order initialized | seed: %d | order: %s" % [tie_seed, ", ".join(_turn_order_strings())])
	_render_case_shell()
	_refresh_all_presentation()
	if content_root != null:
		content_root.visible = true
	if error_panel != null:
		error_panel.visible = false


func _apply_startup_case_effects() -> void:
	if case_definition == null or runtime_state == null:
		return
	if case_definition.startup_poisoner_source_suspect_id > 0:
		if case_definition.has_meta(&"generator_version") and case_definition.startup_poisoner_target_suspect_id > 0:
			PoisonerTaintService.new().resolve_taint(
				case_definition,
				runtime_state,
				case_definition.startup_poisoner_source_suspect_id,
				case_definition.startup_poisoner_target_suspect_id
			)
		else:
			PoisonerTaintService.new().resolve_random_taint(
				case_definition,
				runtime_state,
				case_definition.startup_poisoner_source_suspect_id
			)
	if case_definition.startup_barkeep_source_suspect_id > 0 and case_definition.startup_barkeep_target_suspect_id > 0:
		BarkeepTransformationService.new().resolve_transformation(
			case_definition,
			runtime_state,
			case_definition.startup_barkeep_source_suspect_id,
			case_definition.startup_barkeep_target_suspect_id,
			role_definitions
		)


func _render_case_shell() -> void:
	var header_panel: PanelContainer = find_child("HeaderPanel", true, false) as PanelContainer
	if header_panel != null: header_panel.visible = false
	if case_name_label != null: case_name_label.visible = false
	if case_id_label != null: case_id_label.visible = false
	if difficulty_label != null: difficulty_label.visible = false
	if merit_label != null: merit_label.visible = false
	var back_button: Button = find_child("BackButton", true, false) as Button
	if back_button != null: back_button.visible = false
	_sync_back_navigation_button()
	var scope_note: Label = find_child("ScopeNote", true, false) as Label
	if scope_note != null: scope_note.visible = false


func _sync_back_navigation_button() -> void:
	var dev_back_button: Button = find_child("DevBackButton", true, false) as Button
	if dev_back_button == null:
		return
	if player_facing_mode:
		var truth_ready: bool = _can_acknowledge_player_facing_truth()
		dev_back_button.visible = truth_ready
		if debug_solver_button != null:
			debug_solver_button.visible = OS.is_debug_build() and truth_ready
		dev_back_button.text = "Xem kết quả Kỳ Án"
		dev_back_button.tooltip_text = "Tiếp tục tới kết quả Kỳ Án"
		return
	dev_back_button.visible = true
	if debug_solver_button != null:
		debug_solver_button.visible = false
	dev_back_button.text = "← Quay lại"
	dev_back_button.tooltip_text = "Quay lại DebugHome để chọn tutorial khác"


func _can_acknowledge_player_facing_truth() -> bool:
	return player_facing_mode and _integration_completion_emitted and not _integration_truth_acknowledged


func _on_debug_solver_pressed() -> void:
	if not OS.is_debug_build() or not _can_acknowledge_player_facing_truth():
		return
	var lines: PackedStringArray = PackedStringArray()
	var audit: Object = null
	if case_definition != null and case_definition.has_meta(&"generation_audit_snapshot"):
		audit = case_definition.get_meta(&"generation_audit_snapshot") as Object
	if audit != null and audit.get_script() == CASE_GENERATION_AUDIT_SNAPSHOT:
		lines = audit.call("display_lines", case_definition, runtime_state, role_definitions)
	elif case_definition != null and case_definition.has_meta(&"candidate_signature"):
		lines.append("Không có bản kiểm tra được lưu cho Kỳ Án này.")
	else:
		var report: Dictionary = SOLVER_INSPECTION.new().inspect(case_definition, runtime_state, role_definitions)
		lines = report.get("lines", PackedStringArray())
	if solver_inspection_body != null:
		solver_inspection_body.text = "\n".join(lines)
	if solver_inspection_overlay != null:
		solver_inspection_overlay.show()


func _close_solver_inspection() -> void:
	if solver_inspection_overlay != null:
		solver_inspection_overlay.hide()


func _refresh_all_presentation() -> void:
	if runtime_state != null and runtime_state.case_outcome in [CaseEnums.CaseOutcome.EARLY_SOLVED, CaseEnums.CaseOutcome.ALL_FAILED_EARLY, CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED]:
		_ensure_settlement_and_truth()
	_apply_compact_board_shell_layout()
	var public_views := CasePublicPresentationBuilder.new().build_suspect_views(case_definition, runtime_state, role_definitions)
	if board != null:
		board.populate(
			case_definition.location_definitions(),
			public_views,
			runtime_state.public_function_records,
			runtime_state.elapsed_hours,
			_case_board_columns(),
			_case_board_slot_count()
		)
	_close_private_panel_if_not_current()
	_update_case_clock_display()
	_update_turn_display()
	_update_public_log()
	_update_action_ui()
	_sync_tutorial_dialogue_overlay()


func _update_case_clock_display() -> void:
	if elapsed_hours_label == null:
		return
	var hours: int = runtime_state.elapsed_hours if runtime_state != null else 0
	elapsed_hours_label.text = "Thời gian: %dh" % hours


func _apply_visual_sample_runtime_state() -> void:
	if not _is_visual_sample_case() or runtime_state == null:
		return
	for suspect_runtime: SuspectRuntimeState in runtime_state.suspects:
		if suspect_runtime != null:
			suspect_runtime.is_investigated = true
	runtime_state.accepts_investigation_actions = false


func _is_visual_sample_case() -> bool:
	return case_definition != null and case_definition.has_meta(&"visual_sample_case") and bool(case_definition.get_meta(&"visual_sample_case"))


func _case_board_columns() -> int:
	if case_definition != null and case_definition.has_meta(&"board_columns"):
		return int(case_definition.get_meta(&"board_columns"))
	return CaseSpatialService.BOARD_COLUMNS


func _case_board_slot_count() -> int:
	if case_definition != null and case_definition.has_meta(&"board_slot_count"):
		return int(case_definition.get_meta(&"board_slot_count"))
	return CaseSpatialService.BOARD_SLOT_COUNT


func _case_uses_compact_board() -> bool:
	return _case_board_columns() >= 4


func _apply_compact_board_shell_layout() -> void:
	var compact: bool = _case_uses_compact_board()

	if safe_margin != null:
		safe_margin.add_theme_constant_override("margin_left", 4 if compact else 16)
		safe_margin.add_theme_constant_override("margin_top", 2)
		safe_margin.add_theme_constant_override("margin_right", 4 if compact else 16)
		safe_margin.add_theme_constant_override("margin_bottom", 2)

	if main_column != null:
		main_column.add_theme_constant_override("separation", 0 if compact else 4)

	if dev_nav_row != null:
		dev_nav_row.visible = not compact

	if content_root != null:
		content_root.add_theme_constant_override("separation", 2 if compact else 12)

	if center_column != null:
		center_column.add_theme_constant_override("separation", 4)
		center_column.alignment = (
			BoxContainer.ALIGNMENT_CENTER
			if compact
			else BoxContainer.ALIGNMENT_BEGIN
		)

	if info_panel != null:
		info_panel.custom_minimum_size = Vector2(176, 0) if compact else Vector2(216, 0)

	if role_panel != null:
		role_panel.custom_minimum_size = Vector2(188, 0) if compact else Vector2(232, 0)


func _update_turn_display() -> void:
	var current_player: PlayerCaseState = _active_private_player()
	if current_player == null:
		if turn_label != null: turn_label.text = "Lượt: Chưa bắt đầu"
		if player_strip_label != null: player_strip_label.text = ""
		return

	if turn_label != null:
		turn_label.text = "LƯỢT HIỆN TẠI\n%s" % current_player.display_name

	if player_strip_label != null:
		var rows: Array[String] = ["DANH TIẾNG NGƯỜI CHƠI"]
		for player: PlayerCaseState in turn_manager.turn_order:
			var active_mark: String = "> " if player.player_id == current_player.player_id else "- "
			rows.append("%s%s: %s" % [active_mark, player.display_name, _reputation_slash_bbcode(player.reputation)])
		player_strip_label.text = "\n".join(rows)


func _update_public_log() -> void:
	if description_label != null:
		description_label.text = _case_ratio_text()

	if recent_log_label != null:
		recent_log_label.visible = false
		recent_log_label.text = ""

	_render_role_reference_list()


func _update_action_ui() -> void:
	var all_done := runtime_state != null and runtime_state.all_suspects_investigated()
	if final_result_label != null: final_result_label.visible = false

	if investigate_button != null:
		investigate_button.disabled = runtime_state == null or not runtime_state.accepts_investigation_actions
		investigate_button.visible = false

	if function_button != null:
		function_button.disabled = (
			turn_manager.get_current_player() == null
			or not _has_selectable_functions()
		)
		function_button.visible = false
	if single_accuse_button != null:
		single_accuse_button.visible = false
	_update_private_knowledge_button()

	if runtime_state != null and runtime_state.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT:
		_update_final_verdict_ui()
		return
	if runtime_state != null and runtime_state.case_outcome in [CaseEnums.CaseOutcome.EARLY_SOLVED, CaseEnums.CaseOutcome.ALL_FAILED_EARLY, CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED]:
		_show_truth_reveal()
		return

	if runtime_state != null and runtime_state.case_outcome not in [CaseEnums.CaseOutcome.IN_PROGRESS, CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS]:
		selection_state.finish()
		if submit_button != null: submit_button.disabled = true
		if selection_prompt != null: selection_prompt.visible = false
		if function_picker != null: function_picker.visible = false
		if submission_classification_panel != null: submission_classification_panel.visible = false
		if confirmation_row != null: confirmation_row.visible = false
		if board != null:
			board.set_investigation_selection(false)
			board.set_function_target_selection(false)
			board.set_submission_selection(false)
		return

	if selection_state.mode == InvestigationSelectionState.Mode.SELECTING_FUNCTION_TARGETS:
		_set_phase_hint("ĐANG DÙNG CHỨC NĂNG\nChọn đủ mục tiêu trên Bàn Kỳ Án. Chuột phải để hủy.")
		if submit_button != null: submit_button.disabled = true
		if selection_prompt != null:
			selection_prompt.visible = true
			var target_count: int = selection_state.required_function_target_count
			selection_prompt.text = "%s — chọn đúng %d nghi phạm (%d/%d)" % [
				_selected_function_label(),
				target_count,
				selection_state.selected_function_target_ids.size(),
				target_count,
			]
		if function_picker != null: function_picker.visible = false
		if submission_classification_panel != null: submission_classification_panel.visible = false
		if confirmation_row != null: confirmation_row.visible = false
		if board != null: board.set_function_target_selection(true, selection_state.selected_function_target_ids)
		return

	if selection_state.mode == InvestigationSelectionState.Mode.SELECTING_SUBMISSION:
		_set_phase_hint("ĐANG TRÌNH ÁN\nNghi phạm bị đánh dấu đỏ sẽ được gửi vào đáp án.")
		var has_evil: bool = selection_state.selected_submission_evil_ids.size() > 0
		var can_single_accuse: bool = _can_single_accuse()
		if submit_button != null:
			submit_button.visible = true
			submit_button.disabled = not has_evil
			submit_button.text = "Phán Quyết!"
		if single_accuse_button != null:
			single_accuse_button.visible = _should_show_single_accuse_button()
			single_accuse_button.disabled = not can_single_accuse
		if selection_prompt != null:
			selection_prompt.visible = true
			selection_prompt.text = "Đã chọn %d nghi phạm Phe Ác." % selection_state.selected_submission_evil_ids.size()
		if function_picker != null: function_picker.visible = false
		if submission_classification_panel != null: submission_classification_panel.visible = false
		if confirmation_row != null: confirmation_row.visible = false
		if board != null: board.set_submission_selection(true, selection_state.selected_submission_evil_ids)
		return

	if selection_prompt != null: selection_prompt.visible = false
	if function_picker != null: function_picker.visible = false
	if submission_classification_panel != null: submission_classification_panel.visible = false
	if confirmation_row != null: confirmation_row.visible = false

	var current_player: PlayerCaseState = turn_manager.get_current_player()
	var has_evil_selections: bool = selection_state.selected_submission_evil_ids.size() > 0
	var can_single_accuse: bool = _can_single_accuse()
	if single_accuse_button != null:
		single_accuse_button.visible = _should_show_single_accuse_button()
		single_accuse_button.disabled = not can_single_accuse
	if submit_button != null:
		submit_button.disabled = current_player == null or not current_player.is_active_in_investigation or current_player.submission_status != CaseEnums.SubmissionStatus.NOT_SUBMITTED or not has_evil_selections
		submit_button.visible = has_evil_selections
		submit_button.text = "Phán Quyết!" if has_evil_selections else "Trình Án"
	if runtime_state != null and runtime_state.case_outcome == CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS:
		_set_phase_hint("SAU KHI LỘ HẾT\nCó thể dùng chức năng còn hợp lệ hoặc đánh dấu nghi phạm để Trình Án.")
	else:
		_set_phase_hint("ĐANG ĐIỀU TRA\nGiữ chuột trái trên nghi phạm chưa lộ. Chuột phải để đánh dấu nghi phạm.")


func _on_suspect_action(suspect_id: int, button_index: int, is_hold: bool) -> void:
	if runtime_state == null:
		return
	if _is_tutorial_dialogue_blocking():
		return
	if _is_final_handoff_blocking():
		return

	var is_valid_phase := (
		runtime_state.accepts_investigation_actions
		or runtime_state.case_outcome in [
			CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS,
			CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT,
		]
	)
	if not is_valid_phase:
		return

	var suspect_runtime: SuspectRuntimeState = runtime_state.find_suspect(suspect_id)
	if suspect_runtime == null:
		return

	if button_index == MOUSE_BUTTON_RIGHT and selection_state.mode == InvestigationSelectionState.Mode.SELECTING_FUNCTION_TARGETS:
		_on_cancel_pressed()
		return

	if button_index == MOUSE_BUTTON_RIGHT:
		_toggle_evil_marking(suspect_id)
		return

	if button_index == MOUSE_BUTTON_LEFT:
		if selection_state.mode == InvestigationSelectionState.Mode.IDLE:
			if not suspect_runtime.is_investigated:
				if is_hold:
					_perform_direct_investigation(suspect_id)
				return
			if is_hold:
				return
			_on_function_pressed_for_suspect(suspect_id)
			return
		if selection_state.mode == InvestigationSelectionState.Mode.SELECTING_FUNCTION_TARGETS:
			_on_suspect_selected(suspect_id)
			if selection_state.selected_function_target_ids.size() == selection_state.required_function_target_count:
				_confirm_function_execution()
			return

		if selection_state.mode == InvestigationSelectionState.Mode.SELECTING_SUBMISSION:
			_on_suspect_selected(suspect_id)
			return


func _perform_direct_investigation(suspect_id: int) -> void:
	if cursor_feedback != null:
		cursor_feedback.complete()
	if not selection_state.begin_selection():
		return
	if not selection_state.select_suspect(suspect_id):
		selection_state.cancel()
		return
	if not selection_state.begin_resolving():
		selection_state.cancel()
		return

	var acting_player := turn_manager.get_current_player()
	var result := investigation_service.investigate(
		case_definition,
		runtime_state,
		suspect_id,
		acting_player.player_id if acting_player != null else &"",
	)
	if not result.success:
		AppLogger.warning("Investigation failed | code: %s | suspect: %d" % [result.error_code, result.suspect_id])
		selection_state.finish()
		if board != null: board.set_investigation_selection(false)
		_refresh_all_presentation()
		return

	AppLogger.info("Turn %d | %s | INVESTIGATE suspect %02d | public role: %s | PASS" % [
		turn_manager.turn_number,
		String(result.player_id),
		result.suspect_id,
		_role_display_name(result.public_role_id),
	])
	_commit_action_time_and_timed_events(
		_time_action_id(CaseClockService.ACTION_INVESTIGATION, result.player_id, result.suspect_id),
		CaseClockService.ACTION_INVESTIGATION
	)
	function_availability_service.reveal_for_suspect(
		case_definition,
		runtime_state,
		role_definitions,
		result.suspect_id,
		turn_manager.turn_number,
	)
	if runtime_state.case_outcome in [CaseEnums.CaseOutcome.IN_PROGRESS, CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS, CaseEnums.CaseOutcome.EARLY_SOLVED, CaseEnums.CaseOutcome.ALL_FAILED_EARLY]:
		var advanced_player: PlayerCaseState = turn_manager.advance_turn()
		if advanced_player != null:
			runtime_state.apply_turn_snapshot(turn_manager)
	if runtime_state.case_outcome in [CaseEnums.CaseOutcome.IN_PROGRESS, CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS]:
		function_availability_service.update_for_turn(runtime_state, turn_manager.turn_number)
		if runtime_state.case_outcome == CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS:
			post_reveal_function_service.resolve_phase(case_definition, runtime_state)

	selection_state.finish()
	if board != null: board.set_investigation_selection(false)
	_refresh_all_presentation()


func _on_suspect_hold_progress_started(suspect_id: int, duration_sec: float) -> void:
	if _is_tutorial_dialogue_blocking():
		return
	if runtime_state == null or not runtime_state.accepts_investigation_actions:
		return
	var suspect_runtime := runtime_state.find_suspect(suspect_id)
	if suspect_runtime == null or suspect_runtime.is_investigated or suspect_runtime.is_dead:
		return
	if cursor_feedback != null:
		cursor_feedback.start_progress(get_viewport().get_mouse_position(), duration_sec)


func _on_suspect_hold_progress_canceled(suspect_id: int) -> void:
	if cursor_feedback != null:
		cursor_feedback.cancel()


func _on_suspect_selected(suspect_id: int) -> void:
	if selection_state.mode == InvestigationSelectionState.Mode.SELECTING_SUBMISSION:
		if _is_valid_single_accuse_target(suspect_id) and selection_state.toggle_submission_suspect(suspect_id):
			if board != null: board.set_submission_selection(true, selection_state.selected_submission_evil_ids)
			_update_action_ui()
		return
	if selection_state.mode == InvestigationSelectionState.Mode.SELECTING_FUNCTION_TARGETS:
		if runtime_state.find_suspect(suspect_id) != null and selection_state.toggle_function_target(suspect_id):
			if board != null: board.set_function_target_selection(true, selection_state.selected_function_target_ids)
			_update_action_ui()
		return


func _on_investigate_pressed() -> void:
	if _is_tutorial_dialogue_blocking():
		return
	if runtime_state == null or runtime_state.all_suspects_investigated():
		return
	if selection_state.begin_selection():
		if board != null: board.set_investigation_selection(true)
		_update_action_ui()


func _toggle_evil_marking(suspect_id: int) -> void:
	if selection_state.mode == InvestigationSelectionState.Mode.IDLE:
		if not _is_valid_single_accuse_target(suspect_id) or not selection_state.begin_submission():
			return

	if selection_state.mode == InvestigationSelectionState.Mode.SELECTING_SUBMISSION:
		if not _is_valid_single_accuse_target(suspect_id):
			return
		selection_state.toggle_submission_suspect(suspect_id)
		if selection_state.selected_submission_evil_ids.is_empty():
			selection_state.finish()
			if board != null:
				board.set_submission_selection(false)
		else:
			if board != null:
				board.set_submission_selection(true, selection_state.selected_submission_evil_ids)
		_update_action_ui()


func _on_confirm_pressed() -> void:
	if _is_tutorial_dialogue_blocking():
		return
	if _is_final_handoff_blocking():
		return
	if selection_state.mode == InvestigationSelectionState.Mode.SELECTING_SUBMISSION or selection_state.mode == InvestigationSelectionState.Mode.SELECTING_SUBMISSION_CLASSIFICATION:
		_confirm_submission()
		return
	if selection_state.mode == InvestigationSelectionState.Mode.SELECTING_FUNCTION_TARGETS:
		_confirm_function_execution()
		return


func _on_cancel_pressed() -> void:
	if _is_tutorial_dialogue_blocking():
		return
	if _is_final_handoff_blocking():
		return
	if selection_state.cancel():
		if board != null:
			board.set_investigation_selection(false)
			board.set_function_target_selection(false)
			board.set_submission_selection(false)
		_update_action_ui()


func _on_function_pressed() -> void:
	if runtime_state == null:
		return
	if _is_tutorial_dialogue_blocking():
		return
	if _is_final_handoff_blocking():
		return
	var selectable := _selectable_functions()
	if selectable.is_empty():
		return
	# Lấy chức năng khả dụng đầu tiên trong danh sách để tiến hành chọn mục tiêu
	var target_suspect_id = selectable[0].suspect_id
	_on_function_pressed_for_suspect(target_suspect_id)


func _on_function_pressed_for_suspect(suspect_id: int) -> void:
	if _is_tutorial_dialogue_blocking():
		return
	if runtime_state == null or runtime_state.case_outcome not in [CaseEnums.CaseOutcome.IN_PROGRESS, CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS]:
		return
	if selection_state.mode != InvestigationSelectionState.Mode.IDLE:
		return
	var selectable := _selectable_functions()
	var matching_fn: InteractiveFunctionRuntimeState = null
	for fn in selectable:
		if fn.suspect_id == suspect_id:
			matching_fn = fn
			break
	if matching_fn == null:
		return

	var owner_ids: PackedInt32Array = PackedInt32Array([suspect_id])
	if selection_state.begin_function_selection(owner_ids, matching_fn.target_count):
		selection_state.select_function_owner(suspect_id, matching_fn.target_count)
		_update_action_ui()


func _confirm_function_execution() -> void:
	if not selection_state.begin_resolving_function():
		return
	_update_action_ui()
	var acting_player := turn_manager.get_current_player()
	var result := function_execution_service.execute(
		case_definition,
		runtime_state,
		selection_state.selected_function_owner_id,
		selection_state.selected_function_target_ids,
		acting_player.player_id if acting_player != null else &"",
	)
	if not result.success:
		AppLogger.warning("Function execution failed | code: %s" % result.error_code)
		selection_state.finish()
		if board != null: board.set_function_target_selection(false)
		_refresh_all_presentation()
		return
	var target_parts: PackedStringArray = PackedStringArray()
	for target_id: int in result.target_ids:
		target_parts.append(str(target_id))
	var target_text: String = ", ".join(target_parts)
	AppLogger.info("Turn %d | %s | FUNCTION %s -> [%s] | %s | PASS" % [
		turn_manager.turn_number,
		String(acting_player.player_id) if acting_player != null else "",
		_function_type_log_name(result.function_type),
		target_text,
		result.public_result_text,
	])
	_commit_action_time_and_timed_events(
		_time_action_id(CaseClockService.ACTION_ACTIVE_FUNCTION, acting_player.player_id if acting_player != null else &"", result.owner_suspect_id, result.target_ids),
		CaseClockService.ACTION_ACTIVE_FUNCTION
	)
	_refresh_all_presentation()
	turn_manager.advance_turn()
	runtime_state.apply_turn_snapshot(turn_manager)
	function_availability_service.update_for_turn(runtime_state, turn_manager.turn_number)
	if runtime_state.case_outcome == CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS:
		post_reveal_function_service.resolve_phase(case_definition, runtime_state)
	selection_state.finish()
	if board != null: board.set_function_target_selection(false)
	_refresh_all_presentation()


func _function_type_log_name(function_type: CaseEnums.FunctionType) -> String:
	if function_type == CaseEnums.FunctionType.TAILOR_COMPARE_ALIGNMENT:
		return "TAILOR_COMPARE_ALIGNMENT"
	if function_type == CaseEnums.FunctionType.VIGILANTE_KILL:
		return "VIGILANTE_KILL"
	return "UNKNOWN"


func _commit_action_time_and_timed_events(action_id: StringName, action_type: StringName) -> bool:
	var applied: bool = case_clock_service.apply_action_time(runtime_state, action_id, action_type)
	if applied and case_clock_service.action_time_cost(action_type) > 0:
		timed_event_dispatcher.evaluate_all(case_definition, runtime_state, role_definitions)
	return applied


func _time_action_id(action_type: StringName, player_id: StringName, source_id: int, target_ids: PackedInt32Array = PackedInt32Array()) -> StringName:
	return StringName("%s:%d:%s:%d:%s" % [
		String(action_type),
		turn_manager.turn_number,
		String(player_id),
		source_id,
		_target_ids_key(target_ids),
	])


func _target_ids_key(target_ids: PackedInt32Array) -> String:
	if target_ids.is_empty():
		return "-"
	var parts: PackedStringArray = PackedStringArray()
	for target_id: int in target_ids:
		parts.append(str(target_id))
	return ",".join(parts)


func _selected_function_label() -> String:
	if runtime_state == null:
		return "Chức năng"
	var owner_runtime: SuspectRuntimeState = runtime_state.find_suspect(selection_state.selected_function_owner_id)
	if owner_runtime == null or owner_runtime.interactive_function == null:
		return "Chức năng"
	if owner_runtime.interactive_function.function_type == CaseEnums.FunctionType.TAILOR_COMPARE_ALIGNMENT:
		return "Thợ May"
	if owner_runtime.interactive_function.function_type == CaseEnums.FunctionType.VIGILANTE_KILL:
		return "Vigilante"
	return "Chức năng"


func _on_submit_pressed() -> void:
	if runtime_state == null:
		return
	if _is_tutorial_dialogue_blocking():
		return
	if _is_final_handoff_blocking():
		return

	if selection_state.mode == InvestigationSelectionState.Mode.SELECTING_SUBMISSION or selection_state.selected_submission_evil_ids.size() > 0:
		if selection_state.mode == InvestigationSelectionState.Mode.IDLE:
			selection_state.mode = InvestigationSelectionState.Mode.SELECTING_SUBMISSION
		_confirm_submission()
		return

	if runtime_state.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT:
		if selection_state.begin_submission():
			_update_action_ui()


func _on_single_accuse_pressed() -> void:
	if runtime_state == null or _is_tutorial_dialogue_blocking() or _is_final_handoff_blocking() or not _can_single_accuse():
		return
	var is_final: bool = runtime_state.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
	var current_player: PlayerCaseState = runtime_state.find_player(runtime_state.current_final_player_id()) if is_final else turn_manager.get_current_player()
	var suspect_id: int = selection_state.selected_submission_evil_ids[0]
	var phase: CaseEnums.SubmissionPhase = CaseEnums.SubmissionPhase.FINAL if is_final else CaseEnums.SubmissionPhase.EARLY
	var result: SingleSuspectAccusationResult = single_accusation_service.accuse(case_definition, runtime_state, current_player, suspect_id, phase)
	if not result.success:
		AppLogger.warning("Chỉ Điểm failed | code: %s | suspect: %d" % [result.error_code, suspect_id])
		_refresh_all_presentation()
		return
	AppLogger.info("Turn %d | %s | CHI_DIEM suspect %02d | correct: %s | PASS" % [
		turn_manager.turn_number,
		String(result.player_id),
		result.suspect_id,
		str(result.correct),
	])
	if not is_final:
		_commit_action_time_and_timed_events(
			_time_action_id(CaseClockService.ACTION_SINGLE_ACCUSATION, result.player_id, result.suspect_id),
			CaseClockService.ACTION_SINGLE_ACCUSATION
		)
	selection_state.finish()
	if board != null:
		board.set_submission_selection(false)
	if is_final:
		_close_private_knowledge()
		if runtime_state.case_outcome == CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED:
			_refresh_all_presentation()
			return
		_refresh_all_presentation()
		_show_final_handoff(runtime_state.current_final_player_id())
		return
	if runtime_state.case_outcome in [CaseEnums.CaseOutcome.IN_PROGRESS, CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS, CaseEnums.CaseOutcome.EARLY_SOLVED, CaseEnums.CaseOutcome.ALL_FAILED_EARLY]:
		var advanced_player: PlayerCaseState = turn_manager.advance_turn()
		if advanced_player != null:
			runtime_state.apply_turn_snapshot(turn_manager)
	if runtime_state.case_outcome in [CaseEnums.CaseOutcome.IN_PROGRESS, CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS]:
		function_availability_service.update_for_turn(runtime_state, turn_manager.turn_number)
		if runtime_state.case_outcome == CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS:
			post_reveal_function_service.resolve_phase(case_definition, runtime_state)
	_close_private_knowledge()
	_refresh_all_presentation()


func _confirm_submission() -> void:
	if not selection_state.begin_resolving_submission():
		return
	var underling_ids := PackedInt32Array()
	var traitor_ids := PackedInt32Array()
	var is_final := runtime_state.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
	var current_player: PlayerCaseState = runtime_state.find_player(runtime_state.current_final_player_id()) if is_final else turn_manager.get_current_player()
	var submission: CaseSubmission = CaseSubmission.new()
	submission.configure(current_player.player_id if current_player != null else &"", turn_manager.turn_number, selection_state.selected_submission_evil_ids, underling_ids, traitor_ids, CaseEnums.SubmissionPhase.FINAL if is_final else CaseEnums.SubmissionPhase.EARLY)

	if is_final:
		var final_result := final_verdict_service.lock_submission(case_definition, runtime_state, submission)
		selection_state.finish()
		if board != null: board.set_submission_selection(false)
		if not final_result.success:
			_refresh_all_presentation()
			return
		if runtime_state.case_outcome == CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED:
			_refresh_all_presentation()
			return
		_refresh_all_presentation()
		_show_final_handoff(runtime_state.current_final_player_id())
		return

	var result := submission_service.submit(case_definition, runtime_state, current_player, submission)
	if not result.success:
		selection_state.finish()
		if board != null: board.set_submission_selection(false)
		_refresh_all_presentation()
		return

	selection_state.finish()
	if board != null: board.set_submission_selection(false)
	if result.main_answer_correct or runtime_state.case_outcome in [CaseEnums.CaseOutcome.EARLY_SOLVED, CaseEnums.CaseOutcome.ALL_FAILED_EARLY]:
		_refresh_all_presentation()
		return

	turn_manager.advance_turn()
	runtime_state.apply_turn_snapshot(turn_manager)
	function_availability_service.update_for_turn(runtime_state, turn_manager.turn_number)
	_refresh_all_presentation()


func _player_public_state(player: PlayerCaseState, current_player_id: StringName) -> String:
	if player.submission_status == CaseEnums.SubmissionStatus.SUBMITTED_CORRECT:
		return "Đã phá án"
	if player.submission_status == CaseEnums.SubmissionStatus.SUBMITTED_WRONG:
		return "Đã Trình Án sai — chỉ theo dõi"
	if player.submission_status == CaseEnums.SubmissionStatus.NOT_SUBMITTED_CASE_ENDED:
		return "Chưa Trình Án"
	if player.submission_status == CaseEnums.SubmissionStatus.FINAL_LOCKED_PENDING:
		return "Đã khóa Phán quyết — chờ"
	if player.player_id == current_player_id:
		return "▶ Đang lượt"
	return "Đang điều tra"


func _case_outcome_message() -> String:
	if runtime_state.case_outcome == CaseEnums.CaseOutcome.EARLY_SOLVED:
		return "Kỳ Án đã được phá thành công."
	if runtime_state.case_outcome == CaseEnums.CaseOutcome.ALL_FAILED_EARLY:
		return "Tất cả người chơi đã Trình Án sai. Kỳ Án kết thúc."
	if runtime_state.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT:
		return "Tất cả nghi phạm đã được điều tra — đang nhập Phán quyết cuối."
	if runtime_state.case_outcome == CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS:
		return "Đã điều tra toàn bộ nghi phạm — có thể dùng chức năng còn hợp lệ hoặc Trình Án."
	if runtime_state.case_outcome == CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED:
		return "Phán quyết cuối đã hoàn tất."
	return "Kỳ Án đang diễn ra."


func _update_final_verdict_ui() -> void:
	if not final_initialized:
		var init_result := final_verdict_service.initialize(runtime_state)
		if not init_result.success:
			_show_error(String(init_result.error_code), init_result.error_message)
			return
		function_availability_service.expire_for_final_verdict(runtime_state)
		final_initialized = true
		_update_turn_display()

	if selection_prompt != null: selection_prompt.visible = false
	if function_picker != null: function_picker.visible = false
	if submission_classification_panel != null: submission_classification_panel.visible = false
	if confirmation_row != null: confirmation_row.visible = false

	var next_player := runtime_state.find_player(runtime_state.current_final_player_id())
	var has_evil_selections := selection_state.selected_submission_evil_ids.size() > 0
	var can_single_accuse: bool = _can_single_accuse()

	if submit_button != null:
		submit_button.visible = true
		submit_button.disabled = final_handoff_active or not has_evil_selections
		submit_button.text = "Phán Quyết!"
	if single_accuse_button != null:
		single_accuse_button.visible = _should_show_single_accuse_button()
		single_accuse_button.disabled = final_handoff_active or not can_single_accuse
	if action_reason != null:
		if has_evil_selections:
			action_reason.text = "PHÁN QUYẾT CUỐI (%s)\nĐã chọn %d nghi phạm Phe Ác. Bấm Phán Quyết! để chốt đáp án." % [next_player.display_name if next_player != null else "", selection_state.selected_submission_evil_ids.size()]
		else:
			action_reason.text = "PHÁN QUYẾT CUỐI\nĐang chờ: %s\nĐè chuột phải để đánh dấu nghi phạm Phe Ác." % (next_player.display_name if next_player != null else "Không xác định")
	_set_phase_hint("PHÁN QUYẾT CUỐI\nTừng người chơi khóa đáp án, sự thật chỉ mở khi tất cả đã xong.")


func _show_final_handoff(player_id: StringName) -> void:
	var player: PlayerCaseState = runtime_state.find_player(player_id) if runtime_state != null else null
	final_handoff_active = true
	if final_handoff_player_label != null:
		final_handoff_player_label.text = _handoff_player_text(player)
	if final_handoff_overlay != null:
		final_handoff_overlay.visible = true
		final_handoff_overlay.modulate.a = 0.0
		final_handoff_overlay.scale = Vector2(0.98, 0.98)
	if _final_handoff_tween != null:
		_final_handoff_tween.kill()
	if is_inside_tree() and final_handoff_overlay != null:
		_final_handoff_tween = create_tween()
		_final_handoff_tween.tween_property(final_handoff_overlay, "modulate:a", 1.0, 0.12)
		_final_handoff_tween.parallel().tween_property(final_handoff_overlay, "scale", Vector2.ONE, 0.12)
		_final_handoff_tween.tween_interval(0.82)
		_final_handoff_tween.tween_property(final_handoff_overlay, "modulate:a", 0.0, 0.16)
		_final_handoff_tween.tween_callback(_finish_final_handoff)


func _finish_final_handoff() -> void:
	final_handoff_active = false
	_final_handoff_tween = null
	if final_handoff_overlay != null:
		final_handoff_overlay.visible = false
		final_handoff_overlay.modulate.a = 1.0
	if runtime_state != null and runtime_state.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT:
		_update_action_ui()


func _is_final_handoff_blocking() -> bool:
	return final_handoff_active or (final_handoff_overlay != null and final_handoff_overlay.visible)


func _selectable_functions() -> Array[InteractiveFunctionRuntimeState]:
	if runtime_state != null and runtime_state.case_outcome == CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS:
		return post_reveal_function_service.executable_functions(case_definition, runtime_state)
	return function_availability_service.available_functions(runtime_state)


func _has_selectable_functions() -> bool:
	return not _selectable_functions().is_empty()


func _show_truth_reveal() -> void:
	selection_state.finish()
	runtime_state.lock_case_actions()
	if content_root != null: content_root.visible = true
	if truth_reveal_panel != null: truth_reveal_panel.visible = false
	if action_reason != null:
		action_reason.text = "CÔNG BỐ SỰ THẬT\nCác lá bài trên Bàn Kỳ Án đã chuyển sang hiển thị vai thật và quan hệ liên quan."
	if selection_prompt != null: selection_prompt.visible = false
	if private_knowledge_button != null: private_knowledge_button.visible = false
	if single_accuse_button != null: single_accuse_button.visible = false
	if submit_button != null: submit_button.visible = false
	if player_facing_mode:
		var truth_back_button: Button = find_child("TruthBackButton", true, false) as Button
		if truth_back_button != null: truth_back_button.text = "Xem kết quả Kỳ Án"
	_sync_back_navigation_button()


func _ensure_settlement_and_truth() -> void:
	var settlement: CaseSettlementResult = settlement_service.settle(case_definition, runtime_state)
	if not settlement.success:
		_show_error(String(settlement.error_code), settlement.error_message)
		return
	var reveal := truth_reveal_builder.build(case_definition, runtime_state, role_definitions)
	if reveal == null:
		_show_error("TRUTH_REVEAL_BLOCKED", "Không thể dựng công bố sự thật trước quyết toán.")
		return
	if truth_answer_label != null:
		truth_answer_label.text = "ĐÁP ÁN\nPhe Ác: Nghi phạm %s\nThuộc Hạ: Nghi phạm %s\nNghịch Thần: Nghi phạm %s" % [_ids_text(case_definition.evil_suspect_ids), _ids_text(case_definition.accomplice_suspect_ids), _ids_text(case_definition.traitor_suspect_ids)]
	var suspect_lines: Array[String] = ["SỰ THẬT CÁC NGHI PHẠM"]
	for truth in reveal.suspect_truths:
		var flags: Array[String] = []
		if truth.is_impersonating:
			flags.append("Giả danh%s" % (" " + truth.impersonated_role_name if not truth.impersonated_role_name.is_empty() else ""))
		if truth.is_corrupted: flags.append("Tha Hóa")
		suspect_lines.append("#%d — Vai thật: %s · Đang hiện: %s · %s · %s%s" % [truth.suspect_id, truth.true_role_name, truth.displayed_role_name, truth.alignment_label, truth.role_group_label, " · " + ", ".join(flags) if not flags.is_empty() else ""])
	if truth_suspects_label != null: truth_suspects_label.text = "\n".join(suspect_lines)
	var player_lines: Array[String] = ["KẾT QUẢ NGƯỜI CHƠI"]
	var reward_lines: Array[String] = ["THAY ĐỔI TÀI NGUYÊN"]
	for resolution in reveal.player_resolutions:
		player_lines.append("%s — %s" % [resolution.display_name, _resolution_label(resolution.outcome)])
		var d := resolution.reward
		reward_lines.append("%s — Công Danh %+.2f · Danh Tiếng %+d · Orb %+d · Vé %+d" % [resolution.display_name, d.merit_delta, d.reputation_delta, d.orb_delta, d.total_ticket_delta()])
	if truth_players_label != null: truth_players_label.text = "\n".join(player_lines)
	if truth_rewards_label != null: truth_rewards_label.text = "\n".join(reward_lines)
	var function_lines: Array[String] = ["THÔNG TIN CHỨC NĂNG CÔNG KHAI"]
	for record in reveal.public_function_records:
		function_lines.append(record.summary_text())
	if reveal.public_function_records.is_empty(): function_lines.append("Không có.")
	if truth_functions_label != null: truth_functions_label.text = "\n".join(function_lines)
	if integration_mode and not _integration_completion_emitted:
		var boundary: MVP_CASE_COMPLETION_BOUNDARY = MVP_CASE_COMPLETION_BOUNDARY.new()
		boundary.case_id = case_definition.case_id
		boundary.completion_reason = _completion_reason()
		boundary.runtime_state = runtime_state
		boundary.settlement_result = settlement
		_integration_completion_emitted = true
		integration_case_completed.emit(boundary)


func _ids_text(ids: PackedInt32Array) -> String:
	var parts: Array[String] = []
	for id in ids: parts.append(str(id))
	return ", ".join(parts)


func _resolution_label(outcome: CaseEnums.PlayerResolutionOutcome) -> String:
	match outcome:
		CaseEnums.PlayerResolutionOutcome.CORRECT_EARLY: return "Đúng — Trình Án sớm"
		CaseEnums.PlayerResolutionOutcome.WRONG_EARLY: return "Sai — Trình Án sớm"
		CaseEnums.PlayerResolutionOutcome.CORRECT_FINAL: return "Đúng — Phán quyết cuối"
		CaseEnums.PlayerResolutionOutcome.WRONG_FINAL: return "Sai — Phán quyết cuối"
		_: return "Không Trình Án — Kỳ Án đã kết thúc"


func _show_error(code: String, summary: String) -> void:
	if content_root != null: content_root.visible = false
	if error_panel != null: error_panel.visible = true
	if error_summary != null:
		if player_facing_mode:
			error_summary.text = "Không thể tiếp tục Kỳ Án. Vui lòng quay lại và thử lại."
		else:
			error_summary.text = "Không thể tải Kỳ Án thử nghiệm\n%s\n%s" % [code, summary]


func _on_back_pressed() -> void:
	if player_facing_mode:
		if _can_acknowledge_player_facing_truth():
			_integration_truth_acknowledged = true
			integration_truth_acknowledged.emit()
		return
	AppLogger.info("Returning from Vertical Slice Kỳ Án to DebugHome")
	AppFlow.go_to_debug_home()


func _completion_reason() -> StringName:
	match runtime_state.case_outcome:
		CaseEnums.CaseOutcome.EARLY_SOLVED:
			return &"EARLY_SOLVED"
		CaseEnums.CaseOutcome.ALL_FAILED_EARLY:
			return &"ALL_FAILED_EARLY"
		CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED:
			return &"FINAL_VERDICT_RESOLVED"
	return &"UNKNOWN"


func _new_tie_break_seed() -> int:
	var random_bytes := Crypto.new().generate_random_bytes(8)
	var seed_value := 17
	for byte in random_bytes:
		seed_value = int((seed_value * 257 + byte) & 0x7fffffff)
	return seed_value


func _turn_order_strings() -> Array[String]:
	var values: Array[String] = []
	for player_id in turn_manager.get_turn_order_ids():
		values.append(String(player_id))
	return values


func _player_display_name(player_id: StringName) -> String:
	for player in runtime_state.players:
		if player.player_id == player_id:
			return player.display_name
	return String(player_id)


func _role_display_name(role_id: StringName) -> String:
	for role in role_definitions:
		if role.role_id == role_id:
			return role.display_name
	return "Vai chưa xác định"


func _case_ratio_text() -> String:
	var counts: Dictionary = {
		CaseEnums.RoleGroup.CHINH_NHAN: 0,
		CaseEnums.RoleGroup.HIEU_SU: 0,
		CaseEnums.RoleGroup.TONG_PHAM: 0,
		CaseEnums.RoleGroup.NGHICH_THAN: 0,
	}
	if case_definition != null:
		for suspect in case_definition.suspects:
			if suspect != null and counts.has(suspect.role_group):
				counts[suspect.role_group] = int(counts.get(suspect.role_group, 0)) + 1
	var ratio_lines: Array[String] = [
		_group_count_bbcode(CaseEnums.RoleGroup.CHINH_NHAN, int(counts.get(CaseEnums.RoleGroup.CHINH_NHAN, 0))),
		_group_count_bbcode(CaseEnums.RoleGroup.HIEU_SU, int(counts.get(CaseEnums.RoleGroup.HIEU_SU, 0))),
		_group_count_bbcode(CaseEnums.RoleGroup.TONG_PHAM, int(counts.get(CaseEnums.RoleGroup.TONG_PHAM, 0))),
		_group_count_bbcode(CaseEnums.RoleGroup.NGHICH_THAN, int(counts.get(CaseEnums.RoleGroup.NGHICH_THAN, 0))),
	]
	return "\n".join(ratio_lines)


func _has_tutorial_dialogue() -> bool:
	return case_definition != null and not case_definition.tutorial_dialogue_lines.is_empty()


func _sync_tutorial_dialogue_overlay() -> void:
	if not _has_tutorial_dialogue():
		_tutorial_dialogue_active = false
		_tutorial_dialogue_completed = false
		_tutorial_dialogue_index = 0
		if tutorial_dialogue_overlay != null:
			tutorial_dialogue_overlay.visible = false
		return
	if not _tutorial_dialogue_completed and not _tutorial_dialogue_active:
		_tutorial_dialogue_active = true
		_tutorial_dialogue_index = clampi(_tutorial_dialogue_index, 0, case_definition.tutorial_dialogue_lines.size() - 1)
	_update_tutorial_dialogue_overlay()


func _advance_tutorial_dialogue() -> void:
	if not _tutorial_dialogue_active or not _has_tutorial_dialogue():
		return
	_tutorial_dialogue_index += 1
	if _tutorial_dialogue_index >= case_definition.tutorial_dialogue_lines.size():
		_tutorial_dialogue_active = false
		_tutorial_dialogue_completed = true
		if tutorial_dialogue_overlay != null:
			tutorial_dialogue_overlay.visible = false
		return
	_update_tutorial_dialogue_overlay()


func _update_tutorial_dialogue_overlay() -> void:
	if tutorial_dialogue_overlay == null:
		return
	tutorial_dialogue_overlay.visible = _tutorial_dialogue_active and _has_tutorial_dialogue()
	if not tutorial_dialogue_overlay.visible:
		return
	var speaker_side: StringName = _tutorial_dialogue_speaker_side()
	if tutorial_dialogue_body != null:
		tutorial_dialogue_body.text = case_definition.tutorial_dialogue_lines[_tutorial_dialogue_index]
	if tutorial_dialogue_speaker_label != null:
		tutorial_dialogue_speaker_label.text = "Người Dẫn Chuyện" if speaker_side == &"left" else "Thám Tử"
	if tutorial_dialogue_progress_label != null:
		tutorial_dialogue_progress_label.text = "%d / %d" % [_tutorial_dialogue_index + 1, case_definition.tutorial_dialogue_lines.size()]
	_update_tutorial_dialogue_portrait(tutorial_dialogue_left_portrait, speaker_side == &"left", Color(0.34, 0.68, 0.95, 1.0))
	_update_tutorial_dialogue_portrait(tutorial_dialogue_right_portrait, speaker_side == &"right", Color(0.96, 0.62, 0.34, 1.0))


func _update_tutorial_dialogue_portrait(portrait: ColorRect, active: bool, active_color: Color) -> void:
	if portrait == null:
		return
	portrait.color = active_color if active else Color(0.24, 0.28, 0.34, 0.78)
	portrait.scale = Vector2(1.06, 1.06) if active else Vector2.ONE


func _tutorial_dialogue_speaker_side() -> StringName:
	if case_definition == null or case_definition.tutorial_dialogue_lines.is_empty():
		return &""
	if case_definition.case_id == &"tutorial_case_008":
		return &"right" if _tutorial_dialogue_index < 2 else &"left"
	return &"right" if _tutorial_dialogue_index == 1 else &"left"


func _is_tutorial_dialogue_blocking() -> bool:
	return _tutorial_dialogue_active


func is_tutorial_dialogue_overlay_visible_for_smoke() -> bool:
	return tutorial_dialogue_overlay != null and tutorial_dialogue_overlay.visible


func get_tutorial_dialogue_line_index_for_smoke() -> int:
	return _tutorial_dialogue_index


func get_tutorial_dialogue_text_for_smoke() -> String:
	return tutorial_dialogue_body.text if tutorial_dialogue_body != null else ""


func get_tutorial_dialogue_active_speaker_for_smoke() -> StringName:
	return _tutorial_dialogue_speaker_side()


func get_tutorial_dialogue_portrait_scale_for_smoke(side: StringName) -> Vector2:
	if side == &"left" and tutorial_dialogue_left_portrait != null:
		return tutorial_dialogue_left_portrait.scale
	if side == &"right" and tutorial_dialogue_right_portrait != null:
		return tutorial_dialogue_right_portrait.scale
	return Vector2.ZERO


func _render_role_reference_list() -> void:
	if role_list == null:
		return
	for child in role_list.get_children():
		role_list.remove_child(child)
		child.queue_free()
	for role in _roles_relevant_to_case():
		_add_role_reference_button(role, false)
		for nested_role_id: StringName in _nested_suspect_list_role_ids(role.role_id):
			var nested_role: RoleDefinition = _role_definition(nested_role_id)
			if nested_role != null:
				_add_role_reference_button(nested_role, true)
	if action_reason != null:
		action_reason.visible = false
		action_reason.text = ""


func _roles_relevant_to_case() -> Array[RoleDefinition]:
	var authored_ids: Array[StringName] = _top_level_suspect_list_role_ids()
	if not authored_ids.is_empty():
		var authored_roles: Array[RoleDefinition] = []
		for group: int in _canonical_role_group_order():
			for role_id: StringName in authored_ids:
				var authored_role: RoleDefinition = _role_definition(role_id)
				if authored_role != null and authored_role.role_group == group:
					authored_roles.append(authored_role)
		return authored_roles

	var ids: Dictionary = {}
	if case_definition != null:
		for suspect in case_definition.suspects:
			if suspect != null:
				ids[suspect.true_role_id] = true
				ids[suspect.displayed_role_id] = true
				if not String(suspect.impersonated_role_id).is_empty():
					ids[suspect.impersonated_role_id] = true
	var values: Array[RoleDefinition] = []
	var group_order: Array[int] = _canonical_role_group_order()
	for group: int in group_order:
		for role in role_definitions:
			if role != null and role.role_group == group and ids.has(role.role_id):
				values.append(role)
	return values


func _add_role_reference_button(role: RoleDefinition, nested: bool) -> void:
	if role_list == null or role == null:
		return
	var button := Button.new()
	button.flat = true
	button.custom_minimum_size = Vector2(0, 26)
	var indent: String = "    " if nested else ""
	button.text = "%s%s" % [
		indent,
		_player_facing_text(role.display_name),
	]
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.focus_mode = Control.FOCUS_NONE
	button.tooltip_text = "Xem luật vai"
	button.add_theme_color_override("font_color", _role_group_color(role.role_group))
	button.add_theme_font_size_override("font_size", 16 if not nested else 14)
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0, 0, 0, 0)
	normal_style.border_width_bottom = 1
	normal_style.border_color = Color(0.72, 0.60, 0.35, 0.20)
	button.add_theme_stylebox_override("normal", normal_style)
	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = Color(0.72, 0.60, 0.35, 0.15)
	hover_style.border_width_bottom = 1
	hover_style.border_color = Color(0.85, 0.72, 0.40, 0.50)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", hover_style)
	button.pressed.connect(_on_role_reference_pressed.bind(role.role_id))
	role_list.add_child(button)


func _role_icon_placeholder(_role: RoleDefinition) -> String:
	return ""


func _top_level_suspect_list_role_ids() -> Array[StringName]:
	return CASE_ROLE_POOL_SERVICE.suspected_role_ids_for_case(case_definition)


func _nested_suspect_list_role_ids(parent_role_id: StringName) -> Array[StringName]:
	return CASE_ROLE_POOL_SERVICE.nested_role_reference_ids_for_case(case_definition, parent_role_id)


func _canonical_role_group_order() -> Array[int]:
	return [
		CaseEnums.RoleGroup.CHINH_NHAN,
		CaseEnums.RoleGroup.HIEU_SU,
		CaseEnums.RoleGroup.TONG_PHAM,
		CaseEnums.RoleGroup.NGHICH_THAN,
	]


func get_top_level_suspect_list_role_ids_for_smoke() -> Array[StringName]:
	return _top_level_suspect_list_role_ids()


func get_nested_suspect_list_role_ids_for_smoke(parent_role_id: StringName) -> Array[StringName]:
	return _nested_suspect_list_role_ids(parent_role_id)


func get_presented_role_ids_for_smoke() -> Array[StringName]:
	var ids: Array[StringName] = []
	for role: RoleDefinition in _roles_relevant_to_case():
		if role != null:
			ids.append(role.role_id)
	return ids


func _on_role_reference_pressed(role_id: StringName) -> void:
	var role := _role_definition(role_id)
	if role == null:
		return
	_hide_role_glossary_tooltip()
	if role_reference_title != null:
		role_reference_title.text = _player_facing_text(role.display_name)
	if role_reference_body != null:
		role_reference_body.text = _role_reference_bbcode(role)
	if role_reference_overlay != null:
		role_reference_overlay.visible = true


func _close_role_reference() -> void:
	_hide_role_glossary_tooltip()
	if role_reference_overlay != null:
		role_reference_overlay.visible = false


func _role_reference_text(role: RoleDefinition) -> String:
	return RoleReferenceFormatter.role_reference_text(role)


func _role_reference_bbcode(role: RoleDefinition) -> String:
	return RoleReferenceFormatter.role_reference_bbcode(role)


func _on_private_knowledge_pressed() -> void:
	if runtime_state == null:
		return
	var current_player := _active_private_player()
	if current_player == null:
		return
	_private_overlay_player_id = current_player.player_id
	if private_knowledge_body != null:
		private_knowledge_body.text = _private_knowledge_text(current_player.player_id)
	if private_knowledge_overlay != null:
		private_knowledge_overlay.visible = true


func _close_private_knowledge() -> void:
	_private_overlay_player_id = &""
	if private_knowledge_overlay != null:
		private_knowledge_overlay.visible = false


func _close_private_panel_if_not_current() -> void:
	if private_knowledge_overlay == null or not private_knowledge_overlay.visible:
		return
	var current_player := _active_private_player()
	if current_player == null or current_player.player_id != _private_overlay_player_id:
		_close_private_knowledge()


func _update_private_knowledge_button() -> void:
	if private_knowledge_button == null:
		return
	var current_player := _active_private_player()
	var count := 0
	if runtime_state != null and current_player != null:
		count = runtime_state.private_role_knowledge_for_player(current_player.player_id).size()
	private_knowledge_button.visible = count > 0
	private_knowledge_button.text = "Hồ sơ riêng (%d)" % count if count > 0 else "Hồ sơ riêng"


func _private_knowledge_text(player_id: StringName) -> String:
	var records: Array[PrivateRoleKnowledgeRecord] = []
	if runtime_state != null:
		records = runtime_state.private_role_knowledge_for_player(player_id)
	if records.is_empty():
		return "Chưa có hồ sơ riêng."
	var lines: Array[String] = []
	for record in records:
		lines.append("Nghi phạm %d\nVai trò thật: %s" % [
			record.suspect_id,
			_player_facing_text(_role_display_name(record.true_role_id)),
		])
	return "\n\n".join(lines)


func _can_single_accuse() -> bool:
	if runtime_state == null or turn_manager == null or case_definition == null:
		return false
	var is_final: bool = runtime_state.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
	var current_player: PlayerCaseState = runtime_state.find_player(runtime_state.current_final_player_id()) if is_final else turn_manager.get_current_player()
	return (
		current_player != null
		and runtime_state.case_outcome in [CaseEnums.CaseOutcome.IN_PROGRESS, CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS, CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT]
		and current_player.is_active_in_investigation
		and current_player.submission_status == CaseEnums.SubmissionStatus.NOT_SUBMITTED
		and selection_state.selected_submission_evil_ids.size() == 1
		and _is_valid_single_accuse_target(selection_state.selected_submission_evil_ids[0])
	)


func _should_show_single_accuse_button() -> bool:
	return selection_state.selected_submission_evil_ids.size() == 1 and _can_single_accuse()


func _is_valid_single_accuse_target(suspect_id: int) -> bool:
	if runtime_state == null:
		return false
	var suspect_runtime: SuspectRuntimeState = runtime_state.find_suspect(suspect_id)
	return suspect_runtime != null


func _role_definition(role_id: StringName) -> RoleDefinition:
	for role in role_definitions:
		if role != null and role.role_id == role_id:
			return role
	return null


func _role_group_full_label(group: int) -> String:
	return RoleReferenceFormatter.role_group_full_label(group)


func _role_alignment_label(group: int) -> String:
	return RoleReferenceFormatter.role_alignment_label(group)


func _role_group_color(group: int) -> Color:
	return RoleReferenceFormatter.role_group_color(group)


func _role_alignment_color(group: int) -> Color:
	return RoleReferenceFormatter.role_alignment_color(group)


func _group_count_bbcode(group: int, count: int) -> String:
	return _color_bbcode("%s  %d" % [_role_group_full_label(group), count], _role_group_color(group))


func _reputation_slash_bbcode(reputation: int) -> String:
	if reputation <= 0:
		return ""
	var slashes: String = ""
	for _index: int in range(reputation):
		slashes += "/"
	return _color_bbcode(slashes, _reputation_color(reputation))


func _reputation_color(reputation: int) -> Color:
	if reputation <= 2:
		return Color(1.0, 0.36, 0.34, 1.0)
	if reputation <= 4:
		return Color(0.96, 0.82, 0.28, 1.0)
	return Color(0.42, 0.86, 0.58, 1.0)


func _style_role_reference_terms(value: String) -> String:
	return RoleReferenceFormatter.style_role_reference_terms(value)


func _color_bbcode(value: String, color: Color) -> String:
	return RoleReferenceFormatter.color_bbcode(value, color)


func _function_type_label(function_type: int) -> String:
	match function_type:
		CaseEnums.FunctionType.TAILOR_COMPARE_ALIGNMENT:
			return "So sánh hai nghi phạm cùng phe hay khác phe"
		CaseEnums.FunctionType.VIGILANTE_KILL:
			return "Hạ sát một nghi phạm Phe Ác"
		_:
			return "Không có"


func _set_phase_hint(value: String) -> void:
	if recent_log_label != null:
		recent_log_label.visible = false
		recent_log_label.text = ""
	if board_help_label != null:
		board_help_label.visible = not _case_uses_compact_board() and not value.strip_edges().is_empty()
		board_help_label.text = value.replace("\n", " · ")


func _player_facing_text(value: String) -> String:
	return RoleReferenceFormatter.player_facing_text(value)


func has_glossary_hover_for_smoke() -> bool:
	return (
		role_reference_body != null
		and _role_glossary_tooltip != null
		and role_reference_body.meta_hover_started.is_connected(_on_role_glossary_meta_hover_started)
		and role_reference_body.meta_hover_ended.is_connected(_on_role_glossary_meta_hover_ended)
	)


func _setup_role_glossary_hover() -> void:
	if role_reference_body == null:
		return
	if _role_glossary_tooltip == null:
		_role_glossary_tooltip = ROLE_GLOSSARY_TOOLTIP_SCENE.instantiate() as RoleGlossaryTooltipController
		if _role_glossary_tooltip != null:
			add_child(_role_glossary_tooltip)
	if not role_reference_body.meta_hover_started.is_connected(_on_role_glossary_meta_hover_started):
		role_reference_body.meta_hover_started.connect(_on_role_glossary_meta_hover_started)
	if not role_reference_body.meta_hover_ended.is_connected(_on_role_glossary_meta_hover_ended):
		role_reference_body.meta_hover_ended.connect(_on_role_glossary_meta_hover_ended)


func _on_role_glossary_meta_hover_started(meta: Variant) -> void:
	var key: StringName = RoleGlossaryBank.key_from_meta(meta)
	if String(key).is_empty() or _role_glossary_tooltip == null:
		return
	_role_glossary_tooltip.show_key(key, get_viewport().get_mouse_position())


func _on_role_glossary_meta_hover_ended(_meta: Variant) -> void:
	_hide_role_glossary_tooltip()


func _hide_role_glossary_tooltip() -> void:
	if _role_glossary_tooltip != null:
		_role_glossary_tooltip.hide_tooltip()


func _role_group_label(group: int) -> String:
	match group:
		CaseEnums.RoleGroup.CHINH_NHAN:
			return "Người Vô Tội"
		CaseEnums.RoleGroup.HIEU_SU:
			return "Kẻ Bao Đồng"
		CaseEnums.RoleGroup.TONG_PHAM:
			return "Thuộc Hạ"
		CaseEnums.RoleGroup.NGHICH_THAN:
			return "Nghịch Thần"
		_:
			return "Vai"


func _handoff_player_text(player: PlayerCaseState) -> String:
	if player == null:
		return "Người chơi kế tiếp"
	var label := player.display_name.replace("Người chơi", "").replace("Player", "").strip_edges()
	if label.is_empty():
		return player.display_name
	return "Người chơi %s" % label


func _active_private_player() -> PlayerCaseState:
	if runtime_state == null:
		return null
	if runtime_state.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT:
		return runtime_state.find_player(runtime_state.current_final_player_id())
	return turn_manager.get_current_player()
