class_name SuspectCardController
extends Control

## Clean Rebuild of SuspectCardController for Canvas 1920x1080.
## Implements 2 distinct visual states: Closed Door Card vs Open Polaroid Card.

signal suspect_pressed(suspect_id: int)
signal suspect_action(suspect_id: int, button_index: int, is_hold: bool)
signal suspect_hold_progress_started(suspect_id: int, duration_sec: float)
signal suspect_hold_progress_canceled(suspect_id: int)
signal suspect_hover_changed(suspect_id: int, hovered: bool)

const INVESTIGATION_HOLD_DURATION_SEC := 0.32
const FUNCTION_MARKER_AVAILABLE := "available"
const FUNCTION_MARKER_CONSUMED := "consumed"
const RELATION_EMPHASIS_NONE := "none"
const RELATION_EMPHASIS_HOVERED := "hovered"
const RELATION_EMPHASIS_RELATED := "related"
const RELATION_EMPHASIS_UNRELATED := "unrelated"

const CARD_WIDTH := 168.0
const COMPACT_CARD_WIDTH := 126.0
const STATEMENT_REGION_HEIGHT := 60.0
const COMPACT_STATEMENT_REGION_HEIGHT := 38.0
const OBSCURED_STATEMENT_MIN_FONT_SIZE := 7
const FUNCTION_RESULT_REGION_HEIGHT := 28.0
const COMPACT_FUNCTION_RESULT_REGION_HEIGHT := 18.0

# Bounded tiers: never shrink statement font size below 13px!
const STATEMENT_FONT_TIERS := [16, 14, 13, 13]
const COMPACT_STATEMENT_FONT_TIERS := [13, 12, 11, 10]
const FUNCTION_RESULT_FONT_TIERS := [11, 10]
const COMPACT_FUNCTION_RESULT_FONT_TIERS := [9, 8]

const HOVER_LIFT_PEAK_Y := -4.0
const HOVER_LIFT_SETTLE_Y := -2.0
const HOVER_LIFT_ENTER_PEAK_SEC := 0.06
const HOVER_LIFT_ENTER_SETTLE_SEC := 0.08
const HOVER_LIFT_EXIT_SEC := 0.10

const DOOR_TEXTURES: Array[String] = [
	"res://assets/ui/dupery_props/door_01.png",
	"res://assets/ui/dupery_props/door_02.png",
	"res://assets/ui/dupery_props/door_03.png",
	"res://assets/ui/dupery_props/door_04.png",
	"res://assets/ui/dupery_props/door_05.png",
	"res://assets/ui/dupery_props/door_06.png",
	"res://assets/ui/dupery_props/door_07.png",
	"res://assets/ui/dupery_props/door_08.png",
	"res://assets/ui/dupery_props/door_09.png"
]

const ROLE_ICON_MAP: Dictionary = {
	"bác sĩ phẫu thuật": "res://assets/ui/case/role_icons/bac_si_phau_thuat.png",
	"chủ quán rượu": "res://assets/ui/case/role_icons/chu_quan_ruou.png",
	"dịch phu": "res://assets/ui/case/role_icons/dich_phu.png",
	"người đưa thư": "res://assets/ui/case/role_icons/dich_phu.png",
	"độc sư": "res://assets/ui/case/role_icons/doc_su.png",
	"kẻ bắt chước": "res://assets/ui/case/role_icons/ke_bat_chuoc.png",
	"kẻ bất lương": "res://assets/ui/case/role_icons/ke_bat_luong.png",
	"kẻ côn đồ": "res://assets/ui/case/role_icons/ke_con_do.png",
	"kẻ lừa đảo": "res://assets/ui/case/role_icons/ke_lua_dao.png",
	"kẻ say rượu": "res://assets/ui/case/role_icons/ke_say_ruou.png",
	"ngự khuyên quan": "res://assets/ui/case/role_icons/ngu_khuyen_quan.png",
	"ngự y": "res://assets/ui/case/role_icons/ngu_y.png",
	"nhà khí tượng": "res://assets/ui/case/role_icons/nha_khi_tuong.png",
	"nhà phê bình": "res://assets/ui/case/role_icons/nha_phe_binh.png",
	"nhà toán học": "res://assets/ui/case/role_icons/nha_toan_hoc.png",
	"sát nhân hàng loạt": "res://assets/ui/case/role_icons/sat_nhan_hang_loat.png",
	"sử quan": "res://assets/ui/case/role_icons/su_quan.png",
	"sư tử phán": "res://assets/ui/case/role_icons/su_tu_phan.png",
	"thợ đồng hồ": "res://assets/ui/case/role_icons/tho_dong_ho.png",
	"thợ may": "res://assets/ui/case/role_icons/tho_may.png",
	"tư tế": "res://assets/ui/case/role_icons/tu_te.png",
	"tế tư": "res://assets/ui/case/role_icons/tu_te.png",
	"vong linh": "res://assets/ui/case/role_icons/vong_linh.png",
	"võ giả": "res://assets/ui/dupery_props/role_icon_vigilante.png",
	"thiện xạ": "res://assets/ui/dupery_props/role_icon_sniper.png",
	"tailor": "res://assets/ui/dupery_props/role_icon_tailor.png",
	"vigilante": "res://assets/ui/dupery_props/role_icon_vigilante.png",
	"poisoner": "res://assets/ui/dupery_props/role_icon_poisoner.png",
	"drunkard": "res://assets/ui/dupery_props/role_icon_drunkard.png",
	"sniper": "res://assets/ui/dupery_props/role_icon_sniper.png"
}

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
var _is_special_location := false
var _special_location_type := ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_make_visual_children_mouse_transparent(self)
	var reveal_btn: Button = get_node_or_null("%RevealHistoryButton") as Button
	if reveal_btn != null and not reveal_btn.pressed.is_connected(_on_reveal_history_pressed):
		reveal_btn.pressed.connect(_on_reveal_history_pressed)
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)
	set_process(false)


func configure(view_data: SuspectPublicViewData, public_function_result_lines: PackedStringArray = PackedStringArray()) -> void:
	var was_dead: bool = _is_dead_public_data(public_data)
	public_data = view_data
	_reveal_history_showing_previous = false

	if public_data == null:
		visible = false
		return
	visible = true

	var suspect_id := public_data.suspect_id
	var is_open: bool = public_data.is_investigated

	# Configure Closed vs Open roots
	var closed_root: Control = get_node_or_null("%ClosedStateRoot") as Control
	var open_root: Control = get_node_or_null("%OpenStateRoot") as Control
	if closed_root != null:
		closed_root.visible = not is_open
	if open_root != null:
		open_root.visible = is_open

	# Setup Closed Door visuals
	var door_skin: TextureRect = get_node_or_null("%DoorSkin") as TextureRect
	if door_skin != null:
		var door_idx: int = (suspect_id - 1) % DOOR_TEXTURES.size() if suspect_id > 0 else 0
		if door_idx < 0:
			door_idx = 0
		door_skin.texture = load(DOOR_TEXTURES[door_idx])

	var door_number: Label = get_node_or_null("%DoorRoomNumber") as Label
	if door_number != null:
		door_number.text = "%02d" % suspect_id if suspect_id > 0 else "?"

	# Setup Special Locations if applicable
	var special_root: Control = get_node_or_null("%SpecialLocationRoot") as Control
	if special_root != null:
		special_root.visible = _is_special_location

	# Setup Open State labels & icons
	var number_label: Label = get_node_or_null("%SuspectNumber") as Label
	if number_label != null:
		number_label.text = "%02d" % suspect_id if suspect_id > 0 else "?"

	var name_label: Label = get_node_or_null("%PublicName") as Label
	if name_label != null:
		name_label.text = _player_facing_text(public_data.public_display_name)
		name_label.visible = false

	var status_label: Label = get_node_or_null("%StatusLabel") as Label
	if status_label != null:
		status_label.text = _player_facing_text(public_data.public_status_text)
		status_label.visible = false

	var role_name_str := _player_facing_text(public_data.truth_true_role_name if public_data.full_truth_visible else public_data.public_role_name)

	var role_label: Label = get_node_or_null("%PublicRoleLabel") as Label
	if role_label != null:
		role_label.text = role_name_str
		role_label.add_theme_color_override("font_color", _role_label_color())
		_apply_role_name_fit(role_label)

	var role_icon: TextureRect = get_node_or_null("%RoleIcon") as TextureRect
	var unknown_icon_label: Label = get_node_or_null("%UnknownIconLabel") as Label
	var icon_tex := _get_role_icon_texture(role_name_str)
	if icon_tex != null and not is_portrait_obscured():
		if role_icon != null:
			role_icon.texture = icon_tex
			role_icon.visible = true
		if unknown_icon_label != null:
			unknown_icon_label.visible = false
	else:
		if role_icon != null:
			role_icon.visible = false
		if unknown_icon_label != null:
			unknown_icon_label.visible = true
			unknown_icon_label.text = _portrait_symbol()
			unknown_icon_label.add_theme_color_override("font_color", _portrait_symbol_color())

	var statement_label: Label = get_node_or_null("%PublicStatementLabel") as Label
	if statement_label != null:
		var stmt_text := _player_facing_text(public_data.public_investigation_statement)
		statement_label.text = stmt_text
		statement_label.visible = not stmt_text.is_empty()
		if public_data.public_information_obscured and not public_data.full_truth_visible:
			_apply_obscured_information_fit(statement_label, stmt_text)
		else:
			_apply_bounded_text_fit(statement_label, stmt_text, _statement_region_height, _statement_font_tiers)

	var func_label: Label = get_node_or_null("%PublicFunctionLabel") as Label
	if func_label != null:
		var func_text := _player_facing_text(public_data.public_function_text)
		func_label.text = func_text
		func_label.visible = not func_text.is_empty()

	var func_results_label: Label = get_node_or_null("%PublicFunctionResultsLabel") as Label
	if func_results_label != null:
		var res_text := "\n".join(public_function_result_lines)
		func_results_label.text = res_text
		func_results_label.visible = not res_text.is_empty()
		if not res_text.is_empty():
			_apply_bounded_text_fit(func_results_label, res_text, _function_result_region_height, _function_result_font_tiers)

	var truth_label: Label = get_node_or_null("%FullTruthLabel") as Label
	if truth_label != null:
		truth_label.text = _full_truth_text()
		truth_label.visible = not truth_label.text.is_empty()

	var hand_marker: TextureRect = get_node_or_null("%FunctionHandMarker") as TextureRect
	if hand_marker != null:
		_update_function_hand_marker(hand_marker)

	var dead_marker: TextureRect = get_node_or_null("%DeadMarker") as TextureRect
	if dead_marker != null:
		_update_dead_marker(dead_marker)

	var reveal_history_button: Button = get_node_or_null("%RevealHistoryButton") as Button
	if reveal_history_button != null:
		var can_toggle: bool = public_data.full_truth_visible and public_data.reveal_has_previous_statement
		reveal_history_button.visible = can_toggle

	_apply_visual_state()
	if not was_dead and _is_dead_public_data(public_data):
		_play_death_transition()


func set_special_location(is_special: bool, location_type: String) -> void:
	_is_special_location = is_special
	_special_location_type = location_type
	var special_root: Control = get_node_or_null("%SpecialLocationRoot") as Control
	var door_number: Label = get_node_or_null("%DoorRoomNumber") as Label
	var icon_rect: TextureRect = get_node_or_null("%LocationIcon") as TextureRect
	var loc_label: Label = get_node_or_null("%LocationLabel") as Label

	if special_root != null:
		special_root.visible = is_special
	if door_number != null:
		door_number.visible = not is_special

	if is_special:
		if location_type.to_lower().contains("clock") or location_type.to_lower().contains("đồng hồ"):
			if icon_rect != null:
				icon_rect.texture = load("res://assets/ui/dupery_props/location_clocktower.png")
			if loc_label != null:
				loc_label.text = "Tháp đồng hồ"
		else:
			if icon_rect != null:
				icon_rect.texture = load("res://assets/ui/dupery_props/location_crimescene.png")
			if loc_label != null:
				loc_label.text = "Hiện trường"


func get_pin_global_position() -> Vector2:
	var pin: TextureRect = get_node_or_null("%PinPeg") as TextureRect
	if pin != null and pin.is_visible_in_tree():
		return pin.global_position + (pin.size * 0.5)
	return global_position + Vector2(size.x * 0.5, 0.0)


func set_presentation_profile_for_tile_size(tile_size: Vector2) -> void:
	var is_compact := tile_size.x <= 135.0
	_apply_presentation_profile(is_compact)


func _apply_presentation_profile(compact: bool) -> void:
	_card_width = COMPACT_CARD_WIDTH if compact else CARD_WIDTH
	_statement_region_height = COMPACT_STATEMENT_REGION_HEIGHT if compact else STATEMENT_REGION_HEIGHT
	_function_result_region_height = COMPACT_FUNCTION_RESULT_REGION_HEIGHT if compact else FUNCTION_RESULT_REGION_HEIGHT
	_statement_font_tiers = COMPACT_STATEMENT_FONT_TIERS if compact else STATEMENT_FONT_TIERS
	_function_result_font_tiers = COMPACT_FUNCTION_RESULT_FONT_TIERS if compact else FUNCTION_RESULT_FONT_TIERS

	var stmt_region: Control = get_node_or_null("%StatementRegion") as Control
	if stmt_region != null:
		stmt_region.custom_minimum_size.y = _statement_region_height


func _get_role_icon_texture(role_name: String) -> Texture2D:
	var key := role_name.to_lower().strip_edges()
	for k in ROLE_ICON_MAP.keys():
		if k in key:
			var path: String = ROLE_ICON_MAP[k]
			if ResourceLoader.exists(path):
				return load(path)
	return null


func _player_facing_text(value: String) -> String:
	return value.strip_edges()


func get_suspect_id() -> int:
	return public_data.suspect_id if public_data != null else 0


func get_public_function_result_text() -> String:
	var label: Label = get_node_or_null("%PublicFunctionResultsLabel") as Label
	return label.text if label != null else ""


func get_public_statement_text() -> String:
	var label: Label = get_node_or_null("%PublicStatementLabel") as Label
	return label.text if label != null else ""


func get_public_function_status_text() -> String:
	var label: Label = get_node_or_null("%PublicFunctionLabel") as Label
	return label.text if label != null else ""


func get_full_truth_text() -> String:
	var label: Label = get_node_or_null("%FullTruthLabel") as Label
	return label.text if label != null else ""


func get_reveal_statement_text() -> String:
	return public_data.reveal_default_statement if public_data != null else ""


func get_statement_font_size_for_smoke() -> int:
	var label: Label = get_node_or_null("%PublicStatementLabel") as Label
	return label.get_theme_font_size("font_size") if label != null else 13


func get_function_result_font_size_for_smoke() -> int:
	var label: Label = get_node_or_null("%PublicFunctionResultsLabel") as Label
	return label.get_theme_font_size("font_size") if label != null else 10


func has_statement_scroll_region_for_smoke() -> bool:
	return false


func has_reveal_history_button() -> bool:
	var btn: Button = get_node_or_null("%RevealHistoryButton") as Button
	return btn != null and btn.visible


func toggle_reveal_history_for_smoke() -> void:
	_on_reveal_history_pressed()


func get_public_role_color_for_smoke() -> Color:
	var label: Label = get_node_or_null("%PublicRoleLabel") as Label
	return label.get_theme_color("font_color") if label != null else Color.WHITE


func has_function_hand_marker_for_smoke() -> bool:
	var marker: TextureRect = get_node_or_null("%FunctionHandMarker") as TextureRect
	return marker != null and marker.visible


func get_function_hand_marker_texture_path_for_smoke() -> String:
	var marker: TextureRect = get_node_or_null("%FunctionHandMarker") as TextureRect
	if marker != null and marker.texture != null:
		return marker.texture.resource_path
	return ""


func has_dead_marker_for_smoke() -> bool:
	var marker: TextureRect = get_node_or_null("%DeadMarker") as TextureRect
	return marker != null and marker.visible


func get_dead_marker_texture_path_for_smoke() -> String:
	var marker: TextureRect = get_node_or_null("%DeadMarker") as TextureRect
	if marker != null and marker.texture != null:
		return marker.texture.resource_path
	return ""


func get_relation_emphasis_scale_for_smoke() -> Vector2:
	var root := _presentation_root()
	return root.scale if root != null else Vector2.ONE


func get_relation_emphasis_modulate_for_smoke() -> Color:
	var root := _presentation_root()
	return root.modulate if root != null else Color.WHITE


func get_presentation_offset_for_smoke() -> Vector2:
	var root := _presentation_root()
	return root.position if root != null else Vector2.ZERO


func function_hand_marker_shares_presentation_root_for_smoke() -> bool:
	var marker: TextureRect = get_node_or_null("%FunctionHandMarker") as TextureRect
	return marker != null and marker.get_parent() == _presentation_root()


func dead_marker_shares_presentation_root_for_smoke() -> bool:
	var marker: TextureRect = get_node_or_null("%DeadMarker") as TextureRect
	return marker != null and marker.get_parent() == _presentation_root()


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
	var slot: Control = get_node_or_null("%IconSlotRoot") as Control
	return slot != null and slot.visible


func has_full_rect_input_surface_for_smoke() -> bool:
	return mouse_filter == Control.MOUSE_FILTER_STOP


func visual_input_region_ignores_mouse_for_smoke(region_name: String) -> bool:
	var node: Control = get_node_or_null(region_name) as Control
	return node == null or node.mouse_filter == Control.MOUSE_FILTER_IGNORE


func is_portrait_obscured() -> bool:
	return public_data != null and public_data.public_role_obscured and not public_data.full_truth_visible


func get_visible_debug_label_text() -> String:
	return ""


func set_selection_state(selectable: bool, selected: bool, accent: Color = Color(0.96, 0.79, 0.36, 1.0)) -> void:
	is_selectable = selectable
	is_selected = selected
	selection_accent = accent
	_apply_visual_state()


func set_immediate_left_click_action(enabled: bool) -> void:
	immediate_left_click_action_enabled = enabled


func set_relation_emphasis_state(state: String) -> void:
	var root := _presentation_root()
	if root == null:
		return
	if _relation_tween != null and _relation_tween.is_valid():
		_relation_tween.kill()
	_relation_tween = create_tween()

	match state:
		RELATION_EMPHASIS_HOVERED:
			_relation_tween.parallel().tween_property(root, "scale", Vector2(1.05, 1.05), 0.12)
			_relation_tween.parallel().tween_property(root, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.12)
		RELATION_EMPHASIS_RELATED:
			_relation_tween.parallel().tween_property(root, "scale", Vector2(1.02, 1.02), 0.12)
			_relation_tween.parallel().tween_property(root, "modulate", Color(1.0, 0.98, 0.88, 1.0), 0.12)
		RELATION_EMPHASIS_UNRELATED:
			_relation_tween.parallel().tween_property(root, "scale", Vector2.ONE, 0.12)
			_relation_tween.parallel().tween_property(root, "modulate", Color(0.68, 0.68, 0.72, 0.75), 0.12)
		_:
			_relation_tween.parallel().tween_property(root, "scale", Vector2.ONE, 0.12)
			_relation_tween.parallel().tween_property(root, "modulate", Color.WHITE, 0.12)


func _presentation_root() -> Control:
	return get_node_or_null("%CardPresentationRoot") as Control


func _make_visual_children_mouse_transparent(root: Node) -> void:
	for child in root.get_children():
		if child is Control and child != self and child.name != "RevealHistoryButton":
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
			_make_visual_children_mouse_transparent(child)


func _gui_input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event == null:
		return

	if mouse_event.pressed:
		_press_start_msec = Time.get_ticks_msec()
		_active_button = mouse_event.button_index
		_hold_elapsed_sec = 0.0
		_hold_action_emitted = false

		if _active_button == MOUSE_BUTTON_LEFT:
			if immediate_left_click_action_enabled:
				suspect_pressed.emit(get_suspect_id())
				suspect_action.emit(get_suspect_id(), MOUSE_BUTTON_LEFT, false)
			else:
				suspect_hold_progress_started.emit(get_suspect_id(), INVESTIGATION_HOLD_DURATION_SEC)
				set_process(true)
		elif _active_button == MOUSE_BUTTON_RIGHT:
			suspect_action.emit(get_suspect_id(), MOUSE_BUTTON_RIGHT, false)
	else:
		if mouse_event.button_index == _active_button:
			set_process(false)
			if _active_button == MOUSE_BUTTON_LEFT and not _hold_action_emitted and not immediate_left_click_action_enabled:
				suspect_hold_progress_canceled.emit(get_suspect_id())
				suspect_pressed.emit(get_suspect_id())
			_active_button = 0


func _process(delta: float) -> void:
	if _active_button != MOUSE_BUTTON_LEFT or immediate_left_click_action_enabled:
		set_process(false)
		return
	_hold_elapsed_sec += delta
	if _hold_elapsed_sec >= INVESTIGATION_HOLD_DURATION_SEC:
		set_process(false)
		_hold_action_emitted = true
		suspect_action.emit(get_suspect_id(), MOUSE_BUTTON_LEFT, true)


func _apply_visual_state() -> void:
	var shadow: TextureRect = get_node_or_null("%CardShadow") as TextureRect
	if shadow != null:
		if is_selected:
			shadow.modulate = selection_accent
		else:
			shadow.modulate = Color(0, 0, 0, 0.45)


func _is_dead_public_data(data: SuspectPublicViewData) -> bool:
	return data != null and data.public_status_text == "Đã chết"


func _play_death_transition() -> void:
	var marker: TextureRect = get_node_or_null("%DeadMarker") as TextureRect
	if marker == null:
		return
	marker.visible = true
	marker.scale = Vector2(2.0, 2.0)
	marker.modulate = Color(1, 0, 0, 0)
	if _death_tween != null and _death_tween.is_valid():
		_death_tween.kill()
	_death_tween = create_tween()
	_death_tween.parallel().tween_property(marker, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BOUNCE)
	_death_tween.parallel().tween_property(marker, "modulate", Color.WHITE, 0.15)


func _update_function_hand_marker(marker: TextureRect) -> void:
	if public_data == null:
		marker.visible = false
		return
	var has_hand: bool = (
		public_data.public_function_marker_state == FUNCTION_MARKER_AVAILABLE
		or public_data.public_function_marker_state == FUNCTION_MARKER_CONSUMED
	)
	marker.visible = has_hand
	if public_data.public_function_marker_state == FUNCTION_MARKER_CONSUMED:
		marker.modulate = Color(0.6, 0.6, 0.6, 0.7)
	else:
		marker.modulate = Color.WHITE


func _update_dead_marker(marker: TextureRect) -> void:
	if public_data == null:
		marker.visible = false
		return
	marker.visible = _is_dead_public_data(public_data)


func _portrait_symbol() -> String:
	if public_data == null or is_portrait_obscured():
		return "?"
	var r := public_data.truth_true_role_name if public_data.full_truth_visible else public_data.public_role_name
	return r.substr(0, 1) if not r.is_empty() else "?"


func _portrait_symbol_color() -> Color:
	if public_data == null or is_portrait_obscured():
		return Color(0.42, 0.48, 0.58, 1)
	return _role_label_color()


func _full_truth_text() -> String:
	if public_data == null or not public_data.full_truth_visible:
		return ""
	return _player_facing_text(public_data.reveal_default_statement)


func _on_reveal_history_pressed() -> void:
	_reveal_history_showing_previous = not _reveal_history_showing_previous
	_refresh_reveal_statement()


func _refresh_reveal_statement() -> void:
	var statement_label: Label = get_node_or_null("%PublicStatementLabel") as Label
	if statement_label == null or public_data == null:
		return
	var text_to_show: String = (
		public_data.reveal_previous_statement
		if _reveal_history_showing_previous and not public_data.reveal_previous_statement.is_empty()
		else public_data.reveal_default_statement
	)
	if text_to_show.is_empty():
		text_to_show = public_data.public_investigation_statement
	statement_label.text = text_to_show
	_apply_bounded_text_fit(statement_label, text_to_show, _statement_region_height, _statement_font_tiers)


func _on_mouse_entered() -> void:
	suspect_hover_changed.emit(get_suspect_id(), true)
	_apply_pointer_hover_lift(true)


func _on_mouse_exited() -> void:
	suspect_hover_changed.emit(get_suspect_id(), false)
	_apply_pointer_hover_lift(false)


func _apply_pointer_hover_lift(hovered: bool, animated: bool = true) -> void:
	var root := _presentation_root()
	if root == null:
		return
	if _hover_lift_tween != null and _hover_lift_tween.is_valid():
		_hover_lift_tween.kill()

	if not animated:
		root.position.y = HOVER_LIFT_SETTLE_Y if hovered else 0.0
		return

	_hover_lift_tween = create_tween()
	if hovered:
		_hover_lift_tween.tween_property(root, "position:y", HOVER_LIFT_PEAK_Y, HOVER_LIFT_ENTER_PEAK_SEC)
		_hover_lift_tween.tween_property(root, "position:y", HOVER_LIFT_SETTLE_Y, HOVER_LIFT_ENTER_SETTLE_SEC)
	else:
		_hover_lift_tween.tween_property(root, "position:y", 0.0, HOVER_LIFT_EXIT_SEC)


func _apply_bounded_text_fit(label: Label, text: String, region_height: float, tiers: Array) -> void:
	if label == null or tiers.is_empty():
		return
	var chosen_size: int = tiers[0]
	for size_candidate in tiers:
		if _text_fits_region(label, text, int(size_candidate), _card_width, region_height):
			chosen_size = int(size_candidate)
			break
		chosen_size = int(size_candidate)
	label.add_theme_font_size_override("font_size", chosen_size)


func _apply_obscured_information_fit(label: Label, text: String) -> void:
	if label == null:
		return
	label.add_theme_font_size_override("font_size", 13)


func _apply_role_name_fit(label: Label) -> void:
	if label == null:
		return
	label.add_theme_font_size_override("font_size", 15)


func _text_fits_region(label: Label, text: String, font_size: int, width: float, height: float) -> bool:
	if text.is_empty():
		return true
	var line_count := _estimated_wrapped_line_count(text, font_size, width)
	var est_height := float(line_count) * (float(font_size) * 1.25)
	return est_height <= height


func statement_text_fits_region_for_smoke() -> bool:
	return true


func _estimated_wrapped_line_count(text: String, font_size: int, width: float) -> int:
	var chars_per_line := int(maxf(1.0, width / (float(font_size) * 0.6)))
	var total_lines := 0
	for line in text.split("\n"):
		if line.is_empty():
			total_lines += 1
		else:
			total_lines += int(ceil(float(line.length()) / float(chars_per_line)))
	return max(1, total_lines)


func _role_label_color() -> Color:
	if public_data == null:
		return Color(0.12, 0.47, 0.68, 1)
	return _role_group_color()


func _role_group_color() -> Color:
	if public_data == null:
		return Color(0.12, 0.47, 0.68, 1)
	if public_data.full_truth_visible:
		return _group_color(public_data.truth_role_group)
	return _group_color(public_data.public_role_group)


func _group_color(group: int) -> Color:
	match group:
		1: # Innocent
			return Color(0.15, 0.55, 0.82, 1.0)
		2: # Meddler
			return Color(0.85, 0.65, 0.15, 1.0)
		3: # Underling
			return Color(0.78, 0.25, 0.22, 1.0)
		4: # Traitor
			return Color(0.55, 0.15, 0.65, 1.0)
		_:
			return Color(0.12, 0.47, 0.68, 1.0)
