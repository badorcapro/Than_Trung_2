class_name CaseBoardController
extends PanelContainer

signal suspect_selected(suspect_id: int)
signal suspect_action(suspect_id: int, button_index: int, is_hold: bool)
signal suspect_hold_progress_started(suspect_id: int, duration_sec: float)
signal suspect_hold_progress_canceled(suspect_id: int)

@export var card_scene: PackedScene

const BOARD_SLOT_COUNT := CaseSpatialService.BOARD_SLOT_COUNT
const BOARD_TILE_SIZE: Vector2 = Vector2(168, 190)
const COMPACT_BOARD_TILE_SIZE: Vector2 = Vector2(126, 143)
const BOARD_GRID_H_GAP := 14
const BOARD_GRID_V_GAP := 26
const COMPACT_BOARD_GRID_H_GAP := 16
const COMPACT_BOARD_GRID_V_GAP := 28

var selection_enabled := false
var selected_suspect_id := 0
var function_target_selection_enabled := false
var selected_function_target_ids := PackedInt32Array()
var submission_selection_enabled := false
var selected_submission_ids := PackedInt32Array()
var _cards_by_suspect_id: Dictionary = {}
var _relation_ids_by_suspect_id: Dictionary = {}
var _relation_slots_by_suspect_id: Dictionary = {}
var _relation_hover_enabled_by_suspect_id: Dictionary = {}
var _non_suspect_tiles_by_slot: Dictionary = {}
var _hovered_suspect_id := 0
var _board_slot_count: int = CaseSpatialService.BOARD_SLOT_COUNT
var _board_columns: int = CaseSpatialService.BOARD_COLUMNS
var _tile_size: Vector2 = BOARD_TILE_SIZE


func _ready() -> void:
	var style := StyleBoxTexture.new()
	style.texture = preload("res://assets/ui/case/case_board_mat.png")
	style.texture_margin_left = 60.0
	style.texture_margin_top = 60.0
	style.texture_margin_right = 60.0
	style.texture_margin_bottom = 60.0
	style.content_margin_left = 84.0
	style.content_margin_right = 84.0
	style.content_margin_top = 80.0
	style.content_margin_bottom = 82.0
	add_theme_stylebox_override("panel", style)
	var board_title: Label = get_node_or_null("BoardColumn/BoardTitle") as Label
	if board_title != null:
		board_title.visible = false


func populate(
	locations: Array[BoardLocationDefinition],
	public_suspects: Array[SuspectPublicViewData],
	public_function_records: Array[PublicFunctionRecord] = [],
	elapsed_hours: int = -1,
	board_columns: int = CaseSpatialService.BOARD_COLUMNS,
	board_slot_count: int = CaseSpatialService.BOARD_SLOT_COUNT
) -> void:
	var grid := get_node("%Grid") as GridContainer
	_apply_board_presentation_size(board_columns, board_slot_count)
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
	_cards_by_suspect_id.clear()
	_relation_ids_by_suspect_id.clear()
	_relation_slots_by_suspect_id.clear()
	_relation_hover_enabled_by_suspect_id.clear()
	_non_suspect_tiles_by_slot.clear()
	_hovered_suspect_id = 0
	var tiles: Array[Control] = []
	tiles.resize(_board_slot_count)
	for location: BoardLocationDefinition in locations:
		if location != null:
			_place_tile(tiles, location.board_slot, _build_location_tile(location, elapsed_hours))
	for view_data in public_suspects:
		var card := card_scene.instantiate() as SuspectCardController
		card.custom_minimum_size = _tile_size
		card.set_presentation_profile_for_tile_size(_tile_size)
		_place_tile(tiles, view_data.board_slot, card)
		card.configure(view_data, _function_result_lines_for_source(public_function_records, view_data.suspect_id))
		_cards_by_suspect_id[view_data.suspect_id] = card
		_relation_ids_by_suspect_id[view_data.suspect_id] = view_data.public_relation_suspect_ids.duplicate()
		_relation_slots_by_suspect_id[view_data.suspect_id] = view_data.public_relation_board_slots.duplicate()
		_relation_hover_enabled_by_suspect_id[view_data.suspect_id] = view_data.public_relation_hover_enabled
		if not card.suspect_action.is_connected(_on_card_action):
			card.suspect_action.connect(_on_card_action)
		if not card.suspect_hold_progress_started.is_connected(_on_card_hold_progress_started):
			card.suspect_hold_progress_started.connect(_on_card_hold_progress_started)
		if not card.suspect_hold_progress_canceled.is_connected(_on_card_hold_progress_canceled):
			card.suspect_hold_progress_canceled.connect(_on_card_hold_progress_canceled)
		if not card.suspect_hover_changed.is_connected(_on_card_hover_changed):
			card.suspect_hover_changed.connect(_on_card_hover_changed)
		if submission_selection_enabled:
			card.set_immediate_left_click_action(false)
			card.set_selection_state(true, view_data.suspect_id in selected_submission_ids, Color(0.96, 0.23, 0.26, 1.0))
		elif function_target_selection_enabled:
			card.set_immediate_left_click_action(true)
			card.set_selection_state(true, view_data.suspect_id in selected_function_target_ids)
		else:
			card.set_immediate_left_click_action(false)
			card.set_selection_state(true, view_data.suspect_id == selected_suspect_id)
	for slot in range(_board_slot_count):
		var tile: Control = tiles[slot]
		var rendered_tile: Control = tile if tile != null else _build_empty_slot(slot)
		grid.add_child(rendered_tile)
		if not (rendered_tile is SuspectCardController):
			_non_suspect_tiles_by_slot[slot] = rendered_tile


func _place_tile(tiles: Array[Control], slot: int, tile: Control) -> void:
	var target_slot := clampi(slot, 0, _board_slot_count - 1)
	if tiles[target_slot] == null:
		tiles[target_slot] = tile
		return
	for fallback_slot in range(_board_slot_count):
		if tiles[fallback_slot] == null:
			tiles[fallback_slot] = tile
			return


func _apply_board_presentation_size(board_columns: int, board_slot_count: int) -> void:
	_board_columns = maxi(1, board_columns)
	_board_slot_count = maxi(1, board_slot_count)
	_tile_size = _tile_size_for_columns(_board_columns)
	var compact: bool = _board_columns >= 4
	var board_title: Label = get_node_or_null("BoardColumn/BoardTitle") as Label
	if board_title != null:
		board_title.visible = false
	var board_column: VBoxContainer = get_node_or_null("BoardColumn") as VBoxContainer
	if board_column != null:
		board_column.add_theme_constant_override("separation", 0 if compact else 6)
	var grid := get_node("%Grid") as GridContainer
	grid.columns = _board_columns
	var horizontal_gap: int = COMPACT_BOARD_GRID_H_GAP if compact else BOARD_GRID_H_GAP
	var vertical_gap: int = COMPACT_BOARD_GRID_V_GAP if compact else BOARD_GRID_V_GAP
	grid.add_theme_constant_override("h_separation", horizontal_gap)
	grid.add_theme_constant_override("v_separation", vertical_gap)


func _tile_size_for_columns(board_columns: int) -> Vector2:
	return COMPACT_BOARD_TILE_SIZE if board_columns >= 4 else BOARD_TILE_SIZE


func _build_empty_slot(slot: int) -> Control:
	var spacer := Control.new()
	spacer.name = "EmptyCaseSlot%d" % slot
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spacer.custom_minimum_size = _tile_size
	spacer.size_flags_horizontal = Control.SIZE_FILL
	spacer.size_flags_vertical = Control.SIZE_FILL
	var footprint := Panel.new()
	footprint.name = "RelationFootprint"
	footprint.visible = false
	footprint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footprint.set_anchors_preset(Control.PRESET_CENTER)
	footprint.offset_left = -10.0
	footprint.offset_top = -10.0
	footprint.offset_right = 10.0
	footprint.offset_bottom = 10.0
	var marker_style := StyleBoxFlat.new()
	marker_style.bg_color = Color(0.35, 0.74, 0.85, 0.22)
	marker_style.border_color = Color(0.35, 0.74, 0.85, 0.55)
	marker_style.set_border_width_all(1)
	marker_style.set_corner_radius_all(10)
	footprint.add_theme_stylebox_override("panel", marker_style)
	spacer.add_child(footprint)
	return spacer


func _build_location_tile(location: BoardLocationDefinition, elapsed_hours: int) -> Control:
	if location != null and location.is_crime_scene():
		return _build_crime_scene_tile(location)
	if location != null and location.is_clock_tower():
		return _build_clock_tower_tile(location, elapsed_hours)
	return _build_generic_location_tile(location)


func _build_crime_scene_tile(_location: BoardLocationDefinition) -> Control:
	var panel := PanelContainer.new()
	panel.name = "CrimeSceneTile"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.custom_minimum_size = _tile_size
	panel.size_flags_horizontal = Control.SIZE_FILL
	panel.size_flags_vertical = Control.SIZE_FILL
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.16, 0.14, 0.12, 0.94)
	style.border_color = Color(0.72, 0.60, 0.35, 1.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 9.0
	style.content_margin_bottom = 9.0
	panel.add_theme_stylebox_override("panel", style)

	var column: VBoxContainer = VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 8)
	panel.add_child(column)

	var title: Label = Label.new()
	title.name = "CrimeSceneTitle"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.52, 1.0))
	title.add_theme_font_size_override("font_size", 16)
	title.text = "HIỆN TRƯỜNG"
	column.add_child(title)

	var icon_frame: ColorRect = ColorRect.new()
	icon_frame.name = "CrimeSceneIconFrame"
	icon_frame.custom_minimum_size = Vector2(78, 78)
	icon_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_frame.color = Color(0.26, 0.10, 0.10, 1.0)
	column.add_child(icon_frame)

	var icon_label: Label = Label.new()
	icon_label.name = "CrimeSceneIcon"
	icon_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon_label.anchor_right = 1.0
	icon_label.anchor_bottom = 1.0
	icon_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	icon_label.grow_vertical = Control.GROW_DIRECTION_BOTH
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.add_theme_color_override("font_color", Color(0.96, 0.78, 0.42, 1.0))
	icon_label.add_theme_font_size_override("font_size", 24)
	icon_label.text = "!"
	icon_frame.add_child(icon_label)
	return panel


func _build_clock_tower_tile(location: BoardLocationDefinition, elapsed_hours: int) -> Control:
	var tower: ClockTowerDefinition = location as ClockTowerDefinition
	var is_ringing: bool = tower != null and elapsed_hours >= 0 and ClockTowerService.hour_is_ringing(tower, elapsed_hours)
	var panel: PanelContainer = _build_location_panel(
		"ClockTowerTile",
		Color(0.18, 0.22, 0.12, 1.0) if is_ringing else Color(0.10, 0.09, 0.09, 1.0),
		Color(0.96, 0.86, 0.40, 1.0) if is_ringing else Color(0.72, 0.60, 0.35, 1.0)
	)
	var column: VBoxContainer = panel.get_child(0) as VBoxContainer
	_add_location_title(column, location.display_name if location != null and not location.display_name.is_empty() else "Tháp Đồng Hồ", Color(1.0, 0.88, 0.52, 1.0) if is_ringing else Color(0.92, 0.85, 0.70, 1.0))
	_add_location_icon(column, "REO" if is_ringing else "12", Color(1.0, 0.92, 0.46, 1.0) if is_ringing else Color(0.85, 0.78, 0.65, 1.0))
	return panel


func _build_generic_location_tile(location: BoardLocationDefinition) -> Control:
	var location_id: StringName = location.location_id if location != null else &"unknown"
	var panel: PanelContainer = _build_location_panel("LocationTile_%s" % String(location_id), Color(0.10, 0.11, 0.13, 1.0), Color(0.45, 0.48, 0.54, 1.0))
	var column: VBoxContainer = panel.get_child(0) as VBoxContainer
	_add_location_title(column, location.display_name if location != null and not location.display_name.is_empty() else "Địa điểm", Color(0.86, 0.88, 0.92, 1.0))
	_add_location_icon(column, "*", Color(0.82, 0.84, 0.88, 1.0))
	return panel


func _build_location_panel(tile_name: String, bg_color: Color, border_color: Color) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = tile_name
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.custom_minimum_size = _tile_size
	panel.size_flags_horizontal = Control.SIZE_FILL
	panel.size_flags_vertical = Control.SIZE_FILL
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 9.0
	style.content_margin_bottom = 9.0
	panel.add_theme_stylebox_override("panel", style)
	var column: VBoxContainer = VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 7)
	panel.add_child(column)
	return panel


func _add_location_title(column: VBoxContainer, text: String, color: Color) -> void:
	var title: Label = Label.new()
	title.name = "LocationTitle"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", color)
	title.add_theme_font_size_override("font_size", 15)
	title.text = text
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(title)


func _add_location_icon(column: VBoxContainer, text: String, color: Color) -> void:
	var icon_frame: ColorRect = ColorRect.new()
	icon_frame.name = "LocationIconFrame"
	icon_frame.custom_minimum_size = Vector2(78, 78)
	icon_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_frame.color = Color(0.06, 0.07, 0.09, 1.0)
	column.add_child(icon_frame)

	var icon_label: Label = Label.new()
	icon_label.name = "LocationIcon"
	icon_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon_label.anchor_right = 1.0
	icon_label.anchor_bottom = 1.0
	icon_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	icon_label.grow_vertical = Control.GROW_DIRECTION_BOTH
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.add_theme_color_override("font_color", color)
	icon_label.add_theme_font_size_override("font_size", 24)
	icon_label.text = text
	icon_frame.add_child(icon_label)


func _function_result_lines_for_source(records: Array[PublicFunctionRecord], source_suspect_id: int) -> PackedStringArray:
	var lines := PackedStringArray()
	for record in records:
		if record == null or not record.is_locked or record.source_suspect_id != source_suspect_id:
			continue
		if record.target_suspect_ids.size() == 2:
			lines.append("%d và %d %s." % [
				record.target_suspect_ids[0],
				record.target_suspect_ids[1],
				record.public_result_text.to_lower(),
			])
		elif record.target_suspect_ids.size() == 1:
			lines.append(record.summary_text())
		elif not record.public_result_text.is_empty():
			lines.append(record.public_result_text)
	return lines


func get_case_tile_count() -> int:
	return (get_node("%Grid") as GridContainer).get_child_count()


func get_board_columns_for_smoke() -> int:
	return (get_node("%Grid") as GridContainer).columns


func get_board_slot_count_for_smoke() -> int:
	return _board_slot_count


func get_board_tile_size_for_smoke() -> Vector2:
	return _tile_size


func get_occupied_tile_count() -> int:
	var count: int = 0
	for child in (get_node("%Grid") as GridContainer).get_children():
		if child is Control and not String(child.name).begins_with("EmptyCaseSlot"):
			count += 1
	return count


func get_empty_slot_count() -> int:
	var count := 0
	for child in (get_node("%Grid") as GridContainer).get_children():
		if child is Control and String(child.name).begins_with("EmptyCaseSlot"):
			count += 1
	return count


func get_suspect_slot(suspect_id: int) -> int:
	var grid := get_node("%Grid") as GridContainer
	var index := 0
	for child in grid.get_children():
		if child is SuspectCardController and (child as SuspectCardController).get_suspect_id() == suspect_id:
			return index
		index += 1
	return -1


func get_crime_scene_slot() -> int:
	var grid := get_node("%Grid") as GridContainer
	var index := 0
	for child in grid.get_children():
		if child.name == "CrimeSceneTile":
			return index
		index += 1
	return -1


func has_crime_scene_tile() -> bool:
	return (get_node("%Grid") as GridContainer).get_node_or_null("CrimeSceneTile") != null


func get_crime_scene_tile_text() -> String:
	var tile: Node = (get_node("%Grid") as GridContainer).get_node_or_null("CrimeSceneTile")
	if tile == null:
		return ""
	var values: PackedStringArray = PackedStringArray()
	_collect_label_text(tile, values)
	return "\n".join(values)


func is_crime_scene_noninteractive() -> bool:
	var tile: Control = (get_node("%Grid") as GridContainer).get_node_or_null("CrimeSceneTile") as Control
	return tile != null and tile.mouse_filter == Control.MOUSE_FILTER_IGNORE


func get_crime_scene_scale_for_smoke() -> Vector2:
	var tile: Control = (get_node("%Grid") as GridContainer).get_node_or_null("CrimeSceneTile") as Control
	return tile.scale if tile != null else Vector2.ZERO


func get_crime_scene_modulate_for_smoke() -> Color:
	var tile: Control = (get_node("%Grid") as GridContainer).get_node_or_null("CrimeSceneTile") as Control
	return tile.modulate if tile != null else Color.TRANSPARENT


func get_crime_scene_position_for_smoke() -> Vector2:
	var tile: Control = (get_node("%Grid") as GridContainer).get_node_or_null("CrimeSceneTile") as Control
	return tile.position if tile != null else Vector2.INF


func get_location_slot(location_id: StringName) -> int:
	var expected_name: String = _location_tile_name(location_id)
	var grid: GridContainer = get_node("%Grid") as GridContainer
	var index: int = 0
	for child in grid.get_children():
		if child.name == expected_name:
			return index
		index += 1
	return -1


func has_location_tile(location_id: StringName) -> bool:
	return get_location_slot(location_id) >= 0


func get_location_tile_text(location_id: StringName) -> String:
	var tile: Node = (get_node("%Grid") as GridContainer).get_node_or_null(_location_tile_name(location_id))
	if tile == null:
		return ""
	var values: PackedStringArray = PackedStringArray()
	_collect_label_text(tile, values)
	return "\n".join(values)


func is_location_noninteractive(location_id: StringName) -> bool:
	var tile: Control = (get_node("%Grid") as GridContainer).get_node_or_null(_location_tile_name(location_id)) as Control
	return tile != null and tile.mouse_filter == Control.MOUSE_FILTER_IGNORE


func get_card_count() -> int:
	var count: int = 0
	for child in (get_node("%Grid") as GridContainer).get_children():
		if child is SuspectCardController:
			count += 1
	return count


func get_rendered_ids() -> PackedInt32Array:
	var ids := PackedInt32Array()
	for child in (get_node("%Grid") as GridContainer).get_children():
		if child is SuspectCardController:
			ids.append(child.get_suspect_id())
	return ids


func get_public_relation_ids_for_smoke(suspect_id: int) -> PackedInt32Array:
	var value: Variant = _relation_ids_by_suspect_id.get(suspect_id, PackedInt32Array())
	if value is PackedInt32Array:
		return PackedInt32Array(value)
	return PackedInt32Array()


func get_public_relation_slots_for_smoke(suspect_id: int) -> PackedInt32Array:
	var value: Variant = _relation_slots_by_suspect_id.get(suspect_id, PackedInt32Array())
	if value is PackedInt32Array:
		return PackedInt32Array(value)
	return PackedInt32Array()


func is_relation_footprint_visible_for_smoke(slot: int) -> bool:
	var tile: Control = _non_suspect_tiles_by_slot.get(slot, null) as Control
	if tile == null:
		return false
	var footprint: Panel = tile.get_node_or_null("RelationFootprint") as Panel
	return footprint != null and footprint.visible


func apply_relation_hover_for_smoke(suspect_id: int) -> void:
	_apply_relation_hover(suspect_id)


func clear_relation_hover_for_smoke() -> void:
	_clear_relation_hover()


func _location_tile_name(location_id: StringName) -> String:
	if location_id == BoardLocationDefinition.LOCATION_CRIME_SCENE:
		return "CrimeSceneTile"
	if location_id == BoardLocationDefinition.LOCATION_CLOCK_TOWER:
		return "ClockTowerTile"
	return "LocationTile_%s" % String(location_id)


func _is_location_tile(tile: Control) -> bool:
	if tile == null:
		return false
	var tile_name: String = String(tile.name)
	return tile_name == "CrimeSceneTile" or tile_name == "ClockTowerTile" or tile_name.begins_with("LocationTile_")


func _collect_label_text(node: Node, values: PackedStringArray) -> void:
	if node is Label:
		var label: Label = node as Label
		if label.visible and not label.text.is_empty():
			values.append(label.text)
	for child in node.get_children():
		_collect_label_text(child, values)


func set_investigation_selection(enabled: bool, selected_id: int = 0) -> void:
	selection_enabled = enabled
	selected_suspect_id = selected_id
	function_target_selection_enabled = false
	selected_function_target_ids.clear()
	submission_selection_enabled = false
	selected_submission_ids.clear()
	for child in (get_node("%Grid") as GridContainer).get_children():
		if child is SuspectCardController:
			var card := child as SuspectCardController
			card.set_immediate_left_click_action(false)
			card.set_selection_state(true, card.get_suspect_id() == selected_id)


func set_function_target_selection(enabled: bool, selected_ids: PackedInt32Array = PackedInt32Array()) -> void:
	function_target_selection_enabled = enabled
	selected_function_target_ids = selected_ids.duplicate()
	selection_enabled = false
	selected_suspect_id = 0
	submission_selection_enabled = false
	selected_submission_ids.clear()
	for child in (get_node("%Grid") as GridContainer).get_children():
		if child is SuspectCardController:
			var card := child as SuspectCardController
			card.set_immediate_left_click_action(enabled)
			card.set_selection_state(enabled, enabled and card.get_suspect_id() in selected_function_target_ids)


func set_submission_selection(enabled: bool, selected_ids: PackedInt32Array = PackedInt32Array()) -> void:
	submission_selection_enabled = enabled
	selected_submission_ids = selected_ids.duplicate()
	selection_enabled = false
	function_target_selection_enabled = false
	for child in (get_node("%Grid") as GridContainer).get_children():
		if child is SuspectCardController:
			var card := child as SuspectCardController
			card.set_immediate_left_click_action(false)
			card.set_selection_state(enabled, enabled and card.get_suspect_id() in selected_submission_ids, Color(0.96, 0.23, 0.26, 1.0))


func _on_card_action(suspect_id: int, button_index: int, is_hold: bool) -> void:
	suspect_action.emit(suspect_id, button_index, is_hold)


func _on_card_hold_progress_started(suspect_id: int, duration_sec: float) -> void:
	suspect_hold_progress_started.emit(suspect_id, duration_sec)


func _on_card_hold_progress_canceled(suspect_id: int) -> void:
	suspect_hold_progress_canceled.emit(suspect_id)


func _on_card_hover_changed(suspect_id: int, hovered: bool) -> void:
	if hovered:
		_apply_relation_hover(suspect_id)
	elif _hovered_suspect_id == suspect_id:
		_clear_relation_hover()


func _apply_relation_hover(suspect_id: int) -> void:
	_hovered_suspect_id = suspect_id
	var related_ids: PackedInt32Array = get_public_relation_ids_for_smoke(suspect_id)
	var related_slots: PackedInt32Array = get_public_relation_slots_for_smoke(suspect_id)
	if related_ids.is_empty() and related_slots.is_empty() and not bool(_relation_hover_enabled_by_suspect_id.get(suspect_id, false)):
		_clear_relation_hover()
		return
	for card_id_value: Variant in _cards_by_suspect_id.keys():
		var card_id: int = int(card_id_value)
		var card: SuspectCardController = _cards_by_suspect_id[card_id] as SuspectCardController
		if card == null:
			continue
		if card_id == suspect_id:
			card.set_relation_emphasis_state(SuspectCardController.RELATION_EMPHASIS_HOVERED)
		elif card_id in related_ids:
			card.set_relation_emphasis_state(SuspectCardController.RELATION_EMPHASIS_RELATED)
		else:
			card.set_relation_emphasis_state(SuspectCardController.RELATION_EMPHASIS_UNRELATED)
	_set_non_suspect_relation_focus(not related_slots.is_empty(), related_slots)


func _clear_relation_hover() -> void:
	_hovered_suspect_id = 0
	for card_id_value: Variant in _cards_by_suspect_id.keys():
		var card_id: int = int(card_id_value)
		var card: SuspectCardController = _cards_by_suspect_id[card_id] as SuspectCardController
		if card != null:
			card.set_relation_emphasis_state(SuspectCardController.RELATION_EMPHASIS_NONE)
	_set_non_suspect_relation_focus(false, PackedInt32Array())


func _set_non_suspect_relation_focus(active: bool, related_slots: PackedInt32Array) -> void:
	for slot_value: Variant in _non_suspect_tiles_by_slot.keys():
		var slot: int = int(slot_value)
		var tile: Control = _non_suspect_tiles_by_slot[slot] as Control
		if tile == null:
			continue
		tile.scale = Vector2.ONE
		if _is_location_tile(tile):
			tile.modulate = Color.WHITE if not active or slot in related_slots else Color(0.58, 0.60, 0.62, 0.72)
		else:
			var footprint: Panel = tile.get_node_or_null("RelationFootprint") as Panel
			if footprint != null:
				footprint.visible = active and slot in related_slots
