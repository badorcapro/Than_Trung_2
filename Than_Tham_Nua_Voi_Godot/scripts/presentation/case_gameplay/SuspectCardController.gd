class_name SuspectCardController
extends Control

signal suspect_pressed(suspect_id: int)
signal suspect_action(suspect_id: int, button_index: int, is_hold: bool)
signal suspect_hold_progress_started(suspect_id: int, duration_sec: float)
signal suspect_hold_progress_canceled(suspect_id: int)
signal suspect_hover_changed(suspect_id: int, hovered: bool)

const INVESTIGATION_HOLD_DURATION_SEC := 0.32
const FUNCTION_MARKER_AVAILABLE := "available"
const FUNCTION_MARKER_CONSUMED := "consumed"
const FUNCTION_HAND_AVAILABLE_TEXTURE: Texture2D = preload("res://assets/ui/case/function_hand_available.png")
const FUNCTION_HAND_CONSUMED_TEXTURE: Texture2D = preload("res://assets/ui/case/function_hand_consumed.png")
const DEAD_MARKER_TEXTURE: Texture2D = preload("res://assets/ui/case/dead_marker_universal.png")
const CARD_SKIN_3X3_TEXTURE: Texture2D = preload("res://assets/ui/case/suspect_card_skin_green_3x3_runtime.png")
const CARD_SKIN_4X4_TEXTURE: Texture2D = preload("res://assets/ui/case/suspect_card_skin_green_4x4_runtime.png")
const ROLE_ICON_DICH_PHU: Texture2D = preload("res://assets/ui/case/role_icons/dich_phu.png")
const DISPLAY_FONT: Font = preload("res://assets/fonts/TimesNewRoman.ttf")
const BODY_FONT: Font = preload("res://assets/fonts/Arial.ttf")
const ROLE_NAME_FONT: Font = preload("res://assets/fonts/NotoSerif-SemiBold.ttf")
const CARD_BODY_FONT: Font = preload("res://assets/fonts/NotoSerif-Regular.ttf")
const CARD_SKIN_STRETCH_KEEP_ASPECT_COVERED := 6
const CARD_SKIN_3X3_OVERSCAN := Vector4(-3.0, -10.0, 3.0, 10.0)
const CARD_SKIN_4X4_OVERSCAN := Vector4(-2.0, -11.0, 2.0, 11.0)
const CARD_CONTENT_3X3_SEPARATION := -8
const TOP_ROW_3X3_MIN_HEIGHT := 95.0
const CARD_WIDTH := 168.0
const COMPACT_CARD_WIDTH := 126.0
const CARD_HORIZONTAL_TEXT_PADDING := 28.0
const ROLE_NAME_HORIZONTAL_PADDING := 16.0
const ROLE_NAME_FONT_SIZE := 16
const ROLE_NAME_MIN_FONT_SIZE := 10
const COMPACT_ROLE_NAME_FONT_SIZE := 12
const COMPACT_ROLE_NAME_MIN_FONT_SIZE := 8
const STATEMENT_REGION_HEIGHT := 60.0
const COMPACT_STATEMENT_REGION_HEIGHT := 38.0
const OBSCURED_STATEMENT_MIN_FONT_SIZE := 7
const FUNCTION_RESULT_REGION_HEIGHT := 28.0
const COMPACT_FUNCTION_RESULT_REGION_HEIGHT := 18.0
const STATEMENT_FONT_TIERS := [16, 13, 9, 5]
const COMPACT_STATEMENT_FONT_TIERS := [13, 12, 11, 10]
const FUNCTION_RESULT_FONT_TIERS := [11, 10]
const COMPACT_FUNCTION_RESULT_FONT_TIERS := [9, 8]
const RELATION_EMPHASIS_NONE := "none"
const RELATION_EMPHASIS_HOVERED := "hovered"
const RELATION_EMPHASIS_RELATED := "related"
const RELATION_EMPHASIS_UNRELATED := "unrelated"
const HOVER_LIFT_PEAK_Y := -4.0
const HOVER_LIFT_SETTLE_Y := -2.0
const HOVER_LIFT_ENTER_PEAK_SEC := 0.06
const HOVER_LIFT_ENTER_SETTLE_SEC := 0.08
const HOVER_LIFT_EXIT_SEC := 0.10

var public_data: SuspectPublicViewData
var is_selectable := false
var is_selected := false
var selection_accent := Color(0.96, 0.79, 0.36, 1.0)
var immediate_left_click_action_enabled := false

var _press_start_msec := 0
var _active_button := 0
var _hold_elapsed_sec := 0.0
var _hold_action_emitted := false
var _death_tween: Tween
var _relation_tween: Tween
var _hover_lift_tween: Tween
var _reveal_history_showing_previous := false
var _card_width := CARD_WIDTH
var _statement_region_height := STATEMENT_REGION_HEIGHT
var _function_result_region_height := FUNCTION_RESULT_REGION_HEIGHT
var _statement_font_tiers: Array = STATEMENT_FONT_TIERS
var _function_result_font_tiers: Array = FUNCTION_RESULT_FONT_TIERS


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_make_visual_children_mouse_transparent(self)
	var reveal_history_button: Button = get_node_or_null("%RevealHistoryButton") as Button
	if reveal_history_button != null and not reveal_history_button.pressed.is_connected(_on_reveal_history_pressed):
		reveal_history_button.pressed.connect(_on_reveal_history_pressed)
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)
	set_process(false)


func configure(view_data: SuspectPublicViewData, public_function_result_lines: PackedStringArray = PackedStringArray()) -> void:
	var was_dead: bool = _is_dead_public_data(public_data)
	public_data = view_data
	_reveal_history_showing_previous = false
	var number_label: Label = get_node_or_null("%SuspectNumber") as Label
	var name_label: Label = get_node_or_null("%PublicName") as Label
	var status_label: Label = get_node_or_null("%StatusLabel") as Label
	var role_icon: TextureRect = get_node_or_null("%RoleIcon") as TextureRect
	var unknown_icon_label: Label = get_node_or_null("%UnknownIconLabel") as Label
	var role_label: Label = get_node_or_null("%PublicRoleLabel") as Label
	var function_hand_marker: TextureRect = get_node_or_null("%FunctionHandMarker") as TextureRect
	var dead_marker: TextureRect = get_node_or_null("%DeadMarker") as TextureRect
	var reveal_history_button: Button = get_node_or_null("%RevealHistoryButton") as Button
	var function_label: Label = get_node_or_null("%PublicFunctionLabel") as Label
	var function_results_label: Label = get_node_or_null("%PublicFunctionResultsLabel") as Label
	var full_truth_label: Label = get_node_or_null("%FullTruthLabel") as Label

	if public_data == null:
		return

	if number_label != null:
		number_label.text = "%02d" % public_data.suspect_id

	if name_label != null:
		name_label.visible = false
		name_label.text = ""

	if status_label != null:
		status_label.visible = false
		status_label.text = ""

	var show_dich_phu_icon := (
		public_data.is_investigated
		and _player_facing_text(public_data.public_role_name) == "Dịch Phu"
	)

	if role_icon != null:
		role_icon.visible = show_dich_phu_icon
		role_icon.texture = ROLE_ICON_DICH_PHU if show_dich_phu_icon else null

	if unknown_icon_label != null:
		unknown_icon_label.visible = not show_dich_phu_icon
		unknown_icon_label.text = _portrait_symbol()
		unknown_icon_label.add_theme_color_override("font_color", _portrait_symbol_color())

	if role_label != null:
		role_label.visible = true
		if public_data.full_truth_visible:
			role_label.text = _player_facing_text(public_data.truth_true_role_name)
		elif not public_data.is_investigated:
			role_label.text = ""
		elif public_data.public_role_name.is_empty():
			role_label.text = ""
		else:
			role_label.text = _player_facing_text(public_data.public_role_name)
		role_label.add_theme_color_override("font_color", _role_label_color())
		_apply_role_name_fit(role_label)

	_refresh_reveal_statement()

	if reveal_history_button != null:
		reveal_history_button.visible = public_data.full_truth_visible and public_data.reveal_has_previous_statement
		reveal_history_button.text = "↶"

	_update_function_hand_marker(function_hand_marker)
	_update_dead_marker(dead_marker)

	if function_label != null:
		function_label.visible = false
		function_label.text = ""

	if function_results_label != null:
		function_results_label.visible = (
			public_data.is_investigated
			and not public_data.full_truth_visible
			and (public_data.has_public_function or not public_function_result_lines.is_empty())
		)
		var result_text := "\n".join(public_function_result_lines)
		function_results_label.text = result_text
		_apply_bounded_text_fit(function_results_label, result_text, _function_result_region_height, _function_result_font_tiers)

	if full_truth_label != null:
		full_truth_label.visible = false
		full_truth_label.text = _full_truth_text()

	_apply_visual_state()
	if _is_dead_public_data(public_data) and not was_dead:
		_play_death_transition()


func set_presentation_profile_for_tile_size(tile_size: Vector2) -> void:
	var compact: bool = tile_size.x < CARD_WIDTH
	_card_width = COMPACT_CARD_WIDTH if compact else CARD_WIDTH
	_statement_region_height = COMPACT_STATEMENT_REGION_HEIGHT if compact else STATEMENT_REGION_HEIGHT
	_function_result_region_height = COMPACT_FUNCTION_RESULT_REGION_HEIGHT if compact else FUNCTION_RESULT_REGION_HEIGHT
	_statement_font_tiers = COMPACT_STATEMENT_FONT_TIERS if compact else STATEMENT_FONT_TIERS
	_function_result_font_tiers = COMPACT_FUNCTION_RESULT_FONT_TIERS if compact else FUNCTION_RESULT_FONT_TIERS
	_apply_presentation_profile(compact)


func _apply_presentation_profile(compact: bool) -> void:
	var card_skin: TextureRect = get_node_or_null("%CardSkin") as TextureRect
	if card_skin != null:
		card_skin.texture = CARD_SKIN_4X4_TEXTURE if compact else CARD_SKIN_3X3_TEXTURE
		var skin_overscan: Vector4 = CARD_SKIN_4X4_OVERSCAN if compact else CARD_SKIN_3X3_OVERSCAN
		card_skin.set_anchors_preset(Control.PRESET_FULL_RECT)
		card_skin.offset_left = skin_overscan.x
		card_skin.offset_top = skin_overscan.y
		card_skin.offset_right = skin_overscan.z
		card_skin.offset_bottom = skin_overscan.w
		card_skin.stretch_mode = CARD_SKIN_STRETCH_KEEP_ASPECT_COVERED

	var card_content: VBoxContainer = get_node_or_null("CardPresentationRoot/CardVisual/CardContent") as VBoxContainer
	if card_content != null:
		card_content.add_theme_constant_override("separation", 2 if compact else CARD_CONTENT_3X3_SEPARATION)

	var top_row: HBoxContainer = get_node_or_null("CardPresentationRoot/CardVisual/CardContent/TopRow") as HBoxContainer
	if top_row != null:
		top_row.custom_minimum_size = Vector2(0, 64) if compact else Vector2(0, TOP_ROW_3X3_MIN_HEIGHT)
		top_row.add_theme_constant_override("separation", 4 if compact else 6)

	var icon_slot_root: Control = get_node_or_null("%IconSlotRoot") as Control
	if icon_slot_root != null:
		icon_slot_root.custom_minimum_size = Vector2(48, 42) if compact else Vector2(64, 56)

	var role_icon: TextureRect = get_node_or_null("%RoleIcon") as TextureRect
	if role_icon != null:
		if compact:
			role_icon.anchor_left = 0.0
			role_icon.anchor_top = 0.0
			role_icon.anchor_right = 1.375
			role_icon.anchor_bottom = 0.85
		else:
			# 3x3: human-tuned bằng Remote
			role_icon.anchor_left = 0.125
			role_icon.anchor_top = 0.038
			role_icon.anchor_right = 1.42
			role_icon.anchor_bottom = 0.725

		role_icon.offset_left = 0.0
		role_icon.offset_top = 0.0
		role_icon.offset_right = 0.0
		role_icon.offset_bottom = 0.0
		role_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		role_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	var unknown_icon_label: Label = get_node_or_null("%UnknownIconLabel") as Label
	if unknown_icon_label != null:
		unknown_icon_label.add_theme_font_size_override("font_size", 18 if compact else 26)

	var number_label: Label = get_node_or_null("%SuspectNumber") as Label
	if number_label != null:
		number_label.custom_minimum_size = Vector2(40, 0) if compact else Vector2(60, 50)
		number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		number_label.add_theme_font_size_override("font_size", 18 if compact else 23)

	var role_label: Label = get_node_or_null("%PublicRoleLabel") as Label
	if role_label != null:
		role_label.custom_minimum_size = Vector2(0, 0) if compact else Vector2(0, 28)
		role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		role_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER if compact else VERTICAL_ALIGNMENT_TOP
		role_label.add_theme_font_size_override("font_size", 11 if compact else 15)

	var statement_region: Control = get_node_or_null("%StatementRegion") as Control
	if statement_region != null:
		statement_region.custom_minimum_size = Vector2(0, _statement_region_height)

	var statement_label: Label = get_node_or_null("%PublicStatementLabel") as Label
	if statement_label != null:
		statement_label.custom_minimum_size = Vector2.ZERO
		statement_label.offset_left = 5.0 if compact else 7.0
		statement_label.offset_right = -5.0 if compact else -7.0
		statement_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		statement_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP if compact else VERTICAL_ALIGNMENT_CENTER

	var reveal_history_button: Button = get_node_or_null("%RevealHistoryButton") as Button
	if reveal_history_button != null:
		reveal_history_button.custom_minimum_size = Vector2.ZERO
		reveal_history_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		reveal_history_button.offset_left = 104.0 if compact else 140.0
		reveal_history_button.offset_top = 34.0 if compact else 58.0
		reveal_history_button.offset_right = 122.0 if compact else 162.0
		reveal_history_button.offset_bottom = 52.0 if compact else 80.0
		reveal_history_button.add_theme_font_size_override("font_size", 13 if compact else 16)

	var function_results_label: Label = get_node_or_null("%PublicFunctionResultsLabel") as Label
	if function_results_label != null:
		function_results_label.custom_minimum_size = Vector2(0, _function_result_region_height)

	var function_hand_marker: TextureRect = get_node_or_null("%FunctionHandMarker") as TextureRect
	if function_hand_marker != null:
		function_hand_marker.set_offsets_preset(Control.PRESET_TOP_LEFT)
		function_hand_marker.offset_left = -16.0 if compact else -22.0
		function_hand_marker.offset_top = -20.0 if compact else -20.0
		function_hand_marker.offset_right = 27.0 if compact else 34.0
		function_hand_marker.offset_bottom = 28.0 if compact else 36.0

	var dead_marker: TextureRect = get_node_or_null("%DeadMarker") as TextureRect
	if dead_marker != null:
		dead_marker.set_offsets_preset(Control.PRESET_TOP_LEFT)
		if compact:
			dead_marker.offset_left = 60.0
			dead_marker.offset_top = 1.0
			dead_marker.offset_right = 120.0
			dead_marker.offset_bottom = 61.0
		else:
			dead_marker.offset_left = 86.5
			dead_marker.offset_top = 22.5
			dead_marker.offset_right = 146.5
			dead_marker.offset_bottom = 82.5

	_apply_card_typography(compact)


func _apply_card_typography(compact: bool) -> void:
	var number_label: Label = get_node_or_null("%SuspectNumber") as Label
	if number_label != null:
		number_label.add_theme_font_override("font", DISPLAY_FONT)
		number_label.add_theme_font_size_override("font_size", 19 if compact else 24)

	var role_label: Label = get_node_or_null("%PublicRoleLabel") as Label
	if role_label != null:
		role_label.add_theme_font_override("font", ROLE_NAME_FONT)
		role_label.add_theme_font_size_override(
			"font_size", COMPACT_ROLE_NAME_FONT_SIZE if compact else ROLE_NAME_FONT_SIZE
		)
		_apply_role_name_fit(role_label)

	var statement_label: Label = get_node_or_null("%PublicStatementLabel") as Label
	if statement_label != null:
		statement_label.add_theme_font_override("font", CARD_BODY_FONT)

	var function_results_label: Label = get_node_or_null("%PublicFunctionResultsLabel") as Label
	if function_results_label != null:
		function_results_label.add_theme_font_override("font", CARD_BODY_FONT)

	var full_truth_label: Label = get_node_or_null("%FullTruthLabel") as Label
	if full_truth_label != null:
		full_truth_label.add_theme_font_override("font", BODY_FONT)

	var reveal_history_button: Button = get_node_or_null("%RevealHistoryButton") as Button
	if reveal_history_button != null:
		reveal_history_button.add_theme_font_override("font", BODY_FONT)

	var unknown_icon_label: Label = get_node_or_null("%UnknownIconLabel") as Label
	if unknown_icon_label != null:
		unknown_icon_label.add_theme_font_override("font", DISPLAY_FONT)


func _player_facing_text(value: String) -> String:
	return value.replace(" (Fixture)", "").replace("(Fixture)", "").replace(" fixture", "").strip_edges()


func get_suspect_id() -> int:
	return public_data.suspect_id if public_data != null else -1


func get_public_function_result_text() -> String:
	var label: Label = get_node_or_null("%PublicFunctionResultsLabel") as Label
	return label.text if label != null else ""


func get_public_statement_text() -> String:
	var label: Label = get_node_or_null("%PublicStatementLabel") as Label
	return label.text if label != null and label.visible else ""


func get_public_function_status_text() -> String:
	var label: Label = get_node_or_null("%PublicFunctionLabel") as Label
	return label.text if label != null and label.visible else ""


func get_full_truth_text() -> String:
	var label: Label = get_node_or_null("%FullTruthLabel") as Label
	return label.text if label != null else ""


func get_reveal_statement_text() -> String:
	var label: Label = get_node_or_null("%PublicStatementLabel") as Label
	return label.text if label != null and label.visible else ""


func get_statement_font_size_for_smoke() -> int:
	var label: Label = get_node_or_null("%PublicStatementLabel") as Label
	return label.get_theme_font_size("font_size") if label != null else 0


func get_function_result_font_size_for_smoke() -> int:
	var label: Label = get_node_or_null("%PublicFunctionResultsLabel") as Label
	return label.get_theme_font_size("font_size") if label != null else 0


func has_statement_scroll_region_for_smoke() -> bool:
	return get_node_or_null("%StatementScrollRegion") != null


func has_reveal_history_button() -> bool:
	var button: Button = get_node_or_null("%RevealHistoryButton") as Button
	return button != null and button.visible


func toggle_reveal_history_for_smoke() -> void:
	_on_reveal_history_pressed()


func get_public_role_color_for_smoke() -> Color:
	var label: Label = get_node_or_null("%PublicRoleLabel") as Label
	return label.get_theme_color("font_color") if label != null else Color.TRANSPARENT


func has_function_hand_marker_for_smoke() -> bool:
	var marker: TextureRect = get_node_or_null("%FunctionHandMarker") as TextureRect
	return marker != null and marker.visible


func get_function_hand_marker_texture_path_for_smoke() -> String:
	var marker: TextureRect = get_node_or_null("%FunctionHandMarker") as TextureRect
	if marker == null or not marker.visible or marker.texture == null:
		return ""
	return marker.texture.resource_path


func has_dead_marker_for_smoke() -> bool:
	var marker: TextureRect = get_node_or_null("%DeadMarker") as TextureRect
	return marker != null and marker.visible


func get_dead_marker_texture_path_for_smoke() -> String:
	var marker: TextureRect = get_node_or_null("%DeadMarker") as TextureRect
	if marker == null or not marker.visible or marker.texture == null:
		return ""
	return marker.texture.resource_path


func get_relation_emphasis_scale_for_smoke() -> Vector2:
	var presentation_root: Control = _presentation_root()
	return presentation_root.scale if presentation_root != null else Vector2.ZERO


func get_relation_emphasis_modulate_for_smoke() -> Color:
	var presentation_root: Control = _presentation_root()
	return presentation_root.modulate if presentation_root != null else Color.TRANSPARENT


func get_presentation_offset_for_smoke() -> Vector2:
	var presentation_root: Control = _presentation_root()
	return presentation_root.position if presentation_root != null else Vector2.INF


func function_hand_marker_shares_presentation_root_for_smoke() -> bool:
	var presentation_root: Control = _presentation_root()
	var marker: TextureRect = get_node_or_null("%FunctionHandMarker") as TextureRect
	return presentation_root != null and marker != null and marker.get_parent() == presentation_root


func dead_marker_shares_presentation_root_for_smoke() -> bool:
	var presentation_root: Control = _presentation_root()
	var marker: TextureRect = get_node_or_null("%DeadMarker") as TextureRect
	return presentation_root != null and marker != null and marker.get_parent() == presentation_root


func apply_pointer_hover_for_smoke(hovered: bool) -> void:
	_apply_pointer_hover_lift(hovered, false)


func get_public_role_text() -> String:
	var label: Label = get_node_or_null("%PublicRoleLabel") as Label
	return label.text if label != null else ""


func get_suspect_number_text() -> String:
	var label: Label = get_node_or_null("%SuspectNumber") as Label
	return label.text if label != null else ""


func get_portrait_symbol_text() -> String:
	var label: Label = get_node_or_null("%UnknownIconLabel") as Label
	return label.text if label != null else ""


func has_role_art_placeholder() -> bool:
	return (
		get_node_or_null("%IconSlotRoot") is Control
		and get_node_or_null("%RoleIcon") is TextureRect
		and get_node_or_null("%UnknownIconLabel") is Label
		and not (get_node_or_null("%IconSlotRoot") is ColorRect)
	)


func has_full_rect_input_surface_for_smoke() -> bool:
	return mouse_filter == Control.MOUSE_FILTER_STOP and _visual_children_ignore_mouse(self)


func visual_input_region_ignores_mouse_for_smoke(region_name: String) -> bool:
	var region: Control = get_node_or_null(region_name) as Control
	return region != null and region.mouse_filter == Control.MOUSE_FILTER_IGNORE


func is_portrait_obscured() -> bool:
	return public_data != null and public_data.public_role_obscured and not public_data.full_truth_visible


func get_visible_debug_label_text() -> String:
	var values: PackedStringArray = PackedStringArray()
	var node_paths: PackedStringArray = PackedStringArray(["%PublicName", "%StatusLabel"])
	for node_path: String in node_paths:
		var label: Label = get_node_or_null(node_path) as Label
		if label != null and label.visible and not label.text.is_empty():
			values.append(label.text)
	var title: Label = get_node_or_null("CardPresentationRoot/CardVisual/CardContent/TopRow/SuspectTitle") as Label
	if title != null and title.visible and not title.text.is_empty():
		values.append(title.text)
	return "\n".join(values)


func set_selection_state(selectable: bool, selected: bool, accent: Color = Color(0.96, 0.79, 0.36, 1.0)) -> void:
	is_selectable = selectable
	is_selected = selected
	selection_accent = accent
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_apply_visual_state()


func set_immediate_left_click_action(enabled: bool) -> void:
	immediate_left_click_action_enabled = enabled


func set_relation_emphasis_state(state: String) -> void:
	var presentation_root: Control = _presentation_root()
	if presentation_root == null:
		return
	var target_scale: Vector2 = Vector2.ONE
	var target_modulate: Color = Color.WHITE
	match state:
		RELATION_EMPHASIS_HOVERED:
			target_scale = Vector2(1.02, 1.02)
		RELATION_EMPHASIS_RELATED:
			target_scale = Vector2(1.06, 1.06)
		RELATION_EMPHASIS_UNRELATED:
			target_scale = Vector2(0.94, 0.94)
			target_modulate = Color(0.68, 0.70, 0.72, 0.82)
		_:
			target_scale = Vector2.ONE
			target_modulate = Color.WHITE
	presentation_root.pivot_offset = presentation_root.size * 0.5
	if _relation_tween != null:
		_relation_tween.kill()
	if is_inside_tree():
		_relation_tween = create_tween()
		_relation_tween.tween_property(presentation_root, "scale", target_scale, 0.08)
		_relation_tween.parallel().tween_property(presentation_root, "modulate", target_modulate, 0.08)
	else:
		presentation_root.scale = target_scale
		presentation_root.modulate = target_modulate


func _presentation_root() -> Control:
	return get_node_or_null("%CardPresentationRoot") as Control


func _make_visual_children_mouse_transparent(root: Node) -> void:
	for child: Node in root.get_children():
		if child is Control:
			if String(child.name) == "RevealHistoryButton":
				(child as Control).mouse_filter = Control.MOUSE_FILTER_STOP
			else:
				(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		_make_visual_children_mouse_transparent(child)


func _visual_children_ignore_mouse(root: Node) -> bool:
	for child: Node in root.get_children():
		if child is Control and String(child.name) == "RevealHistoryButton":
			continue
		if child is Control and (child as Control).mouse_filter != Control.MOUSE_FILTER_IGNORE:
			return false
		if not _visual_children_ignore_mouse(child):
			return false
	return true


func _gui_input(event: InputEvent) -> void:
	if public_data == null:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
			if mb.pressed:
				if mb.button_index == MOUSE_BUTTON_LEFT and not public_data.is_investigated and _is_dead_public_data(public_data):
					accept_event()
					_active_button = 0
					set_process(false)
					return
				if mb.button_index == MOUSE_BUTTON_RIGHT and immediate_left_click_action_enabled:
					accept_event()
					suspect_action.emit(public_data.suspect_id, MOUSE_BUTTON_RIGHT, false)
					_active_button = 0
					return
				_active_button = mb.button_index
				_press_start_msec = Time.get_ticks_msec()
				_hold_elapsed_sec = 0.0
				_hold_action_emitted = false
				if mb.button_index == MOUSE_BUTTON_LEFT and immediate_left_click_action_enabled:
					accept_event()
				elif mb.button_index == MOUSE_BUTTON_LEFT and not public_data.is_investigated and not _is_dead_public_data(public_data):
					accept_event()
					suspect_hold_progress_started.emit(public_data.suspect_id, INVESTIGATION_HOLD_DURATION_SEC)
					set_process(true)
			else:
				if mb.button_index == _active_button:
					var hold_duration := Time.get_ticks_msec() - _press_start_msec
					var is_hold := hold_duration >= 150
					accept_event()
					if _active_button == MOUSE_BUTTON_LEFT and not public_data.is_investigated and not immediate_left_click_action_enabled:
						set_process(false)
						if not _hold_action_emitted:
							suspect_hold_progress_canceled.emit(public_data.suspect_id)
					else:
						suspect_action.emit(public_data.suspect_id, _active_button, is_hold)
					_active_button = 0


func _process(delta: float) -> void:
	if public_data == null or public_data.is_investigated or _is_dead_public_data(public_data):
		set_process(false)
		return
	if _active_button != MOUSE_BUTTON_LEFT or _hold_action_emitted:
		set_process(false)
		return
	_hold_elapsed_sec += delta
	if _hold_elapsed_sec >= INVESTIGATION_HOLD_DURATION_SEC:
		_hold_action_emitted = true
		set_process(false)
		suspect_action.emit(public_data.suspect_id, MOUSE_BUTTON_LEFT, true)


func _apply_visual_state() -> void:
	if public_data == null:
		return

	var style := StyleBoxFlat.new()
	style.content_margin_left = 7.0
	style.content_margin_right = 7.0
	style.content_margin_top = 7.0
	style.content_margin_bottom = 7.0
	style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	style.draw_center = false

	if is_selected:
		style.border_width_left = 4
		style.border_width_top = 4
		style.border_width_right = 4
		style.border_width_bottom = 4
		style.border_color = selection_accent
	elif is_selectable:
		style.border_width_left = 0
		style.border_width_top = 0
		style.border_width_right = 0
		style.border_width_bottom = 0
		style.border_color = Color(0.10, 0.10, 0.10, 1.0)
	else:
		style.border_width_left = 0
		style.border_width_top = 0
		style.border_width_right = 0
		style.border_width_bottom = 0
		style.border_color = Color(0.08, 0.08, 0.075, 1.0)

	var card_visual: PanelContainer = get_node_or_null("%CardVisual") as PanelContainer
	if card_visual != null:
		card_visual.add_theme_stylebox_override("panel", style)


func _is_dead_public_data(data: SuspectPublicViewData) -> bool:
	return data != null and data.public_status_text.to_lower().contains("chết")


func _play_death_transition() -> void:
	if _death_tween != null:
		_death_tween.kill()
	modulate = Color(1.0, 0.78, 0.78, 1.0)
	if not is_inside_tree():
		return
	_death_tween = create_tween()
	_death_tween.tween_property(self, "modulate", Color.WHITE, 0.18)


func _update_function_hand_marker(marker: TextureRect) -> void:
	if marker == null:
		return
	if public_data == null or public_data.full_truth_visible or not public_data.has_public_function:
		marker.visible = false
		marker.texture = null
		return
	if public_data.public_function_marker_state == FUNCTION_MARKER_AVAILABLE:
		marker.visible = true
		marker.texture = FUNCTION_HAND_AVAILABLE_TEXTURE
	elif public_data.public_function_marker_state == FUNCTION_MARKER_CONSUMED:
		marker.visible = true
		marker.texture = FUNCTION_HAND_CONSUMED_TEXTURE
	else:
		marker.visible = false
		marker.texture = null


func _update_dead_marker(marker: TextureRect) -> void:
	if marker == null:
		return
	if _is_dead_public_data(public_data):
		marker.visible = true
		marker.texture = DEAD_MARKER_TEXTURE
	else:
		marker.visible = false
		marker.texture = null


func _portrait_symbol() -> String:
	if public_data == null or not public_data.is_investigated:
		return "?"
	if public_data.full_truth_visible:
		return "!"
	if public_data.public_role_obscured:
		return "?"
	return "?"


func _portrait_symbol_color() -> Color:
	if public_data == null or not public_data.is_investigated:
		return Color(0.42, 0.48, 0.58, 1.0)
	if public_data.full_truth_visible:
		return _role_group_color()
	if public_data.public_role_obscured:
		return Color(0.42, 0.48, 0.58, 1.0)
	return Color(0.74, 0.84, 0.98, 1.0)


func _full_truth_text() -> String:
	if public_data == null or not public_data.full_truth_visible:
		return ""
	return _player_facing_text(public_data.reveal_default_statement)


func _on_reveal_history_pressed() -> void:
	if public_data == null or not public_data.full_truth_visible or not public_data.reveal_has_previous_statement:
		return
	_reveal_history_showing_previous = not _reveal_history_showing_previous
	_refresh_reveal_statement()


func _refresh_reveal_statement() -> void:
	if public_data == null:
		return
	var statement_label: Label = get_node_or_null("%PublicStatementLabel") as Label
	if statement_label == null:
		return
	var statement: String = public_data.public_investigation_statement
	if public_data.full_truth_visible:
		statement = (
			public_data.reveal_previous_statement
			if _reveal_history_showing_previous
			else public_data.reveal_default_statement
		)
	var region_visible := public_data.full_truth_visible or public_data.is_investigated
	var statement_region: Control = get_node_or_null("%StatementRegion") as Control
	if statement_region != null:
		statement_region.visible = region_visible
	statement_label.visible = region_visible
	var player_statement := _player_facing_text(statement)
	statement_label.text = player_statement
	_apply_bounded_text_fit(statement_label, player_statement, _statement_region_height, _statement_font_tiers)
	if public_data.public_information_obscured and not public_data.full_truth_visible:
		_apply_obscured_information_fit(statement_label, player_statement)
	var reveal_history_button: Button = get_node_or_null("%RevealHistoryButton") as Button
	if reveal_history_button != null and public_data.full_truth_visible and public_data.reveal_has_previous_statement:
		reveal_history_button.text = "↷" if _reveal_history_showing_previous else "↶"


func _on_mouse_entered() -> void:
	_apply_pointer_hover_lift(true)
	if public_data != null:
		suspect_hover_changed.emit(public_data.suspect_id, true)


func _on_mouse_exited() -> void:
	_apply_pointer_hover_lift(false)
	if public_data != null:
		suspect_hover_changed.emit(public_data.suspect_id, false)


func _apply_pointer_hover_lift(hovered: bool, animated: bool = true) -> void:
	var presentation_root: Control = _presentation_root()
	if presentation_root == null:
		return
	if _hover_lift_tween != null:
		_hover_lift_tween.kill()
	if not animated or not is_inside_tree():
		presentation_root.position = Vector2(0.0, HOVER_LIFT_SETTLE_Y if hovered else 0.0)
		return
	if hovered:
		_hover_lift_tween = create_tween()
		_hover_lift_tween.set_trans(Tween.TRANS_SINE)
		_hover_lift_tween.set_ease(Tween.EASE_OUT)
		_hover_lift_tween.tween_property(presentation_root, "position", Vector2(0.0, HOVER_LIFT_PEAK_Y), HOVER_LIFT_ENTER_PEAK_SEC)
		_hover_lift_tween.tween_property(presentation_root, "position", Vector2(0.0, HOVER_LIFT_SETTLE_Y), HOVER_LIFT_ENTER_SETTLE_SEC)
	else:
		_hover_lift_tween = create_tween()
		_hover_lift_tween.set_trans(Tween.TRANS_SINE)
		_hover_lift_tween.set_ease(Tween.EASE_OUT)
		_hover_lift_tween.tween_property(presentation_root, "position", Vector2.ZERO, HOVER_LIFT_EXIT_SEC)


func _apply_bounded_text_fit(label: Label, text: String, region_height: float, tiers: Array) -> void:
	if label == null or tiers.is_empty():
		return

	var width := _card_width - CARD_HORIZONTAL_TEXT_PADDING

	# Luôn thử cỡ lớn nhất trước.
	# Chỉ giảm font khi cỡ lớn hơn thực sự không vừa.
	var reference_size := 16
	var estimated_lines := _estimated_wrapped_line_count(text, reference_size, width)

	var preferred_index := 0

	if estimated_lines <= 2:
		preferred_index = 0
	elif estimated_lines <= 4:
		preferred_index = mini(1, tiers.size() - 1)
	else:
		preferred_index = mini(2, tiers.size() - 1)

	var chosen_size: int = int(tiers[tiers.size() - 1])

	for i in range(preferred_index, tiers.size()):
		var tier: int = int(tiers[i])
		if _text_fits_region(label, text, tier, width, region_height):
			chosen_size = tier
			break

	label.add_theme_font_size_override("font_size", chosen_size)

	label.tooltip_text = (
		text
		if not _text_fits_region(label, text, chosen_size, width, region_height)
		else ""
	)


func _apply_obscured_information_fit(label: Label, text: String) -> void:
	if label == null or _statement_font_tiers.is_empty():
		return
	var available_size: Vector2 = _statement_label_available_size(label)
	var normal_size: int = int(_statement_font_tiers[0])
	var chosen_size: int = OBSCURED_STATEMENT_MIN_FONT_SIZE
	for font_size: int in range(normal_size, OBSCURED_STATEMENT_MIN_FONT_SIZE - 1, -1):
		label.add_theme_font_size_override("font_size", font_size)
		if _obscured_text_fits_current_rect(label, text, font_size, available_size):
			chosen_size = font_size
			break
	label.add_theme_font_size_override("font_size", chosen_size)
	label.tooltip_text = (
		text
		if not _obscured_text_fits_current_rect(label, text, chosen_size, available_size)
		else ""
	)


func _statement_label_available_size(label: Label) -> Vector2:
	if not label.is_inside_tree():
		return Vector2(
			maxf(1.0, _card_width + label.offset_right - label.offset_left),
			maxf(1.0, _statement_region_height + label.offset_bottom - label.offset_top)
		)
	var available_width: float = label.size.x
	var available_height: float = label.size.y
	var statement_region: Control = get_node_or_null("%StatementRegion") as Control
	if available_width <= 0.5 and statement_region != null and statement_region.size.x > 0.5:
		available_width = statement_region.size.x + label.offset_right - label.offset_left
	if available_height <= 0.5 and statement_region != null and statement_region.size.y > 0.5:
		available_height = statement_region.size.y + label.offset_bottom - label.offset_top
	if available_width <= 0.5:
		available_width = _card_width - CARD_HORIZONTAL_TEXT_PADDING
	if available_height <= 0.5:
		available_height = _statement_region_height
	return Vector2(maxf(1.0, available_width), maxf(1.0, available_height))


func _label_text_fits_current_rect(
	label: Label, text: String, font_size: int, available_size: Vector2
) -> bool:
	if not _text_fits_region(label, text, font_size, available_size.x, available_size.y):
		return false
	return label.get_line_count() <= label.get_visible_line_count()


func _obscured_text_fits_current_rect(
	label: Label, text: String, font_size: int, available_size: Vector2
) -> bool:
	var font: Font = label.get_theme_font("font")
	if font == null:
		return _text_fits_region(label, text, font_size, available_size.x, available_size.y)
	var measured_size: Vector2 = font.get_multiline_string_size(
		text, HORIZONTAL_ALIGNMENT_CENTER, available_size.x, font_size
	)
	var wrapped_line_count: int = label.get_line_count()
	if not label.is_inside_tree():
		var font_line_height: float = maxf(1.0, font.get_height(font_size))
		wrapped_line_count = maxi(1, int(round(measured_size.y / font_line_height)))
	var line_spacing: float = float(label.get_theme_constant("line_spacing"))
	var effective_height: float = (
		measured_size.y + float(maxi(0, wrapped_line_count - 1)) * line_spacing
	)
	if measured_size.x > available_size.x + 0.5 or effective_height > available_size.y + 0.5:
		return false
	return not label.is_inside_tree() or wrapped_line_count <= label.get_visible_line_count()


func _apply_role_name_fit(label: Label) -> void:
	if label == null:
		return
	var compact: bool = _card_width <= COMPACT_CARD_WIDTH
	var normal_size: int = COMPACT_ROLE_NAME_FONT_SIZE if compact else ROLE_NAME_FONT_SIZE
	var minimum_size: int = COMPACT_ROLE_NAME_MIN_FONT_SIZE if compact else ROLE_NAME_MIN_FONT_SIZE
	var available_width: float = maxf(1.0, _card_width - ROLE_NAME_HORIZONTAL_PADDING)
	var chosen_size: int = minimum_size
	for font_size: int in range(normal_size, minimum_size - 1, -1):
		var measured_width: float = ROLE_NAME_FONT.get_string_size(
			label.text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size
		).x
		if measured_width <= available_width + 0.5:
			chosen_size = font_size
			break
	label.add_theme_font_size_override("font_size", chosen_size)


func _text_fits_region(label: Label, text: String, font_size: int, width: float, height: float) -> bool:
	if text.strip_edges().is_empty():
		return true
	var font: Font = label.get_theme_font("font")
	if font != null:
		var measured_size: Vector2 = font.get_multiline_string_size(
			text, HORIZONTAL_ALIGNMENT_CENTER, width, font_size
		)
		return measured_size.x <= width + 0.5 and measured_size.y <= height + 0.5
	var line_count := _estimated_wrapped_line_count(text, font_size, width)
	var max_lines := maxi(1, int(floor(height / float(font_size + 2))))
	return line_count <= max_lines


func statement_text_fits_region_for_smoke() -> bool:
	var label: Label = get_node_or_null("%PublicStatementLabel") as Label
	if label == null:
		return false
	var available_size: Vector2 = _statement_label_available_size(label)
	if not label.is_inside_tree():
		if public_data != null and public_data.public_information_obscured:
			return _obscured_text_fits_current_rect(
				label, label.text, label.get_theme_font_size("font_size"), available_size
			)
		return _text_fits_region(label, label.text, label.get_theme_font_size("font_size"), available_size.x, available_size.y)
	if public_data != null and public_data.public_information_obscured:
		return _obscured_text_fits_current_rect(
			label, label.text, label.get_theme_font_size("font_size"), available_size
		)
	return _label_text_fits_current_rect(
		label, label.text, label.get_theme_font_size("font_size"), available_size
	)


func _estimated_wrapped_line_count(text: String, font_size: int, width: float) -> int:
	var char_capacity := maxi(1, int(floor(width / (float(font_size) * 0.52))))
	var total_lines := 0
	for paragraph: String in text.split("\n"):
		var words := paragraph.strip_edges().split(" ", false)
		if words.is_empty():
			total_lines += 1
			continue
		var current_line := 0
		for word: String in words:
			var word_length := word.length()
			if current_line == 0:
				total_lines += maxi(1, int(ceil(float(word_length) / float(char_capacity))))
				current_line = word_length % char_capacity
				if current_line == 0 and word_length > 0:
					current_line = char_capacity
			elif current_line + 1 + word_length <= char_capacity:
				current_line += 1 + word_length
			else:
				total_lines += maxi(1, int(ceil(float(word_length) / float(char_capacity))))
				current_line = word_length % char_capacity
				if current_line == 0 and word_length > 0:
					current_line = char_capacity
	return maxi(1, total_lines)


func _role_label_color() -> Color:
	if public_data != null and public_data.full_truth_visible:
		return _role_group_color()
	return _group_color(public_data.public_role_group) if public_data != null else Color(0.12, 0.47, 0.68, 1.0)


func _role_group_color() -> Color:
	if public_data == null:
		return Color(0.12, 0.47, 0.68, 1.0)
	return _group_color(public_data.truth_role_group)


func _group_color(group: int) -> Color:
	match group:
		CaseEnums.RoleGroup.CHINH_NHAN:
			return Color(0.12, 0.47, 0.68, 1.0)
		CaseEnums.RoleGroup.HIEU_SU:
			return Color(0.74, 0.48, 0.10, 1.0)
		CaseEnums.RoleGroup.TONG_PHAM:
			return Color(0.78, 0.17, 0.17, 1.0)
		CaseEnums.RoleGroup.NGHICH_THAN:
			return Color(0.48, 0.20, 0.72, 1.0)
		_:
			return Color(0.12, 0.47, 0.68, 1.0)
