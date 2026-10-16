class_name AuctionEncyclopediaDialog
extends Control

signal closed

const CATALOG_CLASS := preload("res://scripts/domain/loot/AuctionCatalog.gd")
const ITEM_CLASS := preload("res://scripts/domain/loot/MysteryChestItem.gd")

const RARITY_SVG_NAMES: Array[String] = [
	"rarity_1_white",
	"rarity_2_green",
	"rarity_3_blue",
	"rarity_4_purple",
	"rarity_5_gold",
	"rarity_6_red",
]

static func _get_rarity_svg_path(rarity_idx: int, selected: bool) -> String:
	if rarity_idx >= 0 and rarity_idx < RARITY_SVG_NAMES.size():
		var state: String = "selected" if selected else "unselected"
		return "res://assets/ui/rarity/%s_%s.svg" % [RARITY_SVG_NAMES[rarity_idx], state]
	return ""

# Filters state
var _rarity_filter_enabled: bool = false
var _selected_rarities: Dictionary = {}

var _category_filter_enabled: bool = false
var _selected_categories: Dictionary = {}

var _shape_filter_enabled: bool = false
var _selected_shapes: Dictionary = {}

# UI References
var _dialog_panel: Control
var _rarity_name_lbl: Label
var _category_name_lbl: Label
var _shape_name_lbl: Label
var _price_range_lbl: Label
var _item_count_lbl: Label
var _cards_grid: GridContainer

var _rarity_buttons: Array[Button] = []
var _category_buttons: Array[Button] = []
var _shape_buttons: Array[Button] = []

# Cache textures to avoid disk thrashing
static var _texture_cache: Dictionary = {}


func _init() -> void:
	name = "AuctionEncyclopediaDialog"
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_STOP
	_build_ui()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			close_dialog()
			get_viewport().set_input_as_handled()


func open_dialog() -> void:
	visible = true
	_rarity_filter_enabled = false
	_selected_rarities.clear()
	_category_filter_enabled = false
	_selected_categories.clear()
	_shape_filter_enabled = false
	_selected_shapes.clear()
	_refresh_filters_ui()
	_refresh_items_grid()


func close_dialog() -> void:
	visible = false
	closed.emit()


func _build_ui() -> void:
	# 1. Dark semi-transparent modal backdrop
	var bg_overlay := ColorRect.new()
	bg_overlay.set_anchors_preset(PRESET_FULL_RECT)
	bg_overlay.color = Color(0.02, 0.03, 0.05, 0.85)
	add_child(bg_overlay)
	bg_overlay.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			close_dialog()
	)

	# 2. Centered Main Modal Window with khung.png background
	# Resolution: 1200 x 670 matches khung.png (2752 x 1536, aspect ~ 1.7916)
	var center := CenterContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	add_child(center)

	_dialog_panel = Control.new()
	_dialog_panel.custom_minimum_size = Vector2(1200, 670)
	center.add_child(_dialog_panel)

	# Frame Art Background (khung.png)
	var frame_rect := TextureRect.new()
	frame_rect.set_anchors_preset(PRESET_FULL_RECT)
	frame_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame_rect.stretch_mode = TextureRect.STRETCH_SCALE
	frame_rect.mouse_filter = MOUSE_FILTER_IGNORE
	frame_rect.texture = _get_cached_texture("res://assets/auction_items/khung.png")
	_dialog_panel.add_child(frame_rect)

	# --- Title Bar ---
	var title_lbl := Label.new()
	title_lbl.text = "📖 BÁCH KHOA TOÀN THƯ VẬT PHẨM"
	title_lbl.position = Vector2(36, 18)
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.add_theme_color_override("font_color", Color("#e2e8f0"))
	_dialog_panel.add_child(title_lbl)

	# Close Button positioned over 'X' box in khung.png
	var close_btn := Button.new()
	close_btn.position = Vector2(1130, 13)
	close_btn.size = Vector2(44, 43)
	close_btn.focus_mode = FOCUS_NONE
	close_btn.flat = true
	close_btn.tooltip_text = "Đóng Bách Khoa (ESC)"
	var close_hover := StyleBoxFlat.new()
	close_hover.bg_color = Color(1.0, 1.0, 1.0, 0.15)
	close_hover.corner_radius_top_left = 6
	close_hover.corner_radius_top_right = 6
	close_hover.corner_radius_bottom_left = 6
	close_hover.corner_radius_bottom_right = 6
	close_btn.add_theme_stylebox_override("hover", close_hover)
	var close_normal := StyleBoxEmpty.new()
	close_btn.add_theme_stylebox_override("normal", close_normal)
	close_btn.pressed.connect(close_dialog)
	_dialog_panel.add_child(close_btn)

	# --- Left Sidebar (Filters) ---
	var sidebar := _build_sidebar()
	sidebar.position = Vector2(28, 70)
	sidebar.size = Vector2(345, 580)
	_dialog_panel.add_child(sidebar)

	# --- Right Content Area ---
	var content_area := _build_content_area()
	content_area.position = Vector2(390, 84)
	content_area.size = Vector2(782, 566)
	_dialog_panel.add_child(content_area)


func _build_sidebar() -> Control:
	var side_panel := Control.new()
	side_panel.custom_minimum_size = Vector2(345, 580)
	side_panel.size = Vector2(345, 580)
	side_panel.mouse_filter = MOUSE_FILTER_PASS

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	side_panel.add_child(scroll)

	var side_vbox := VBoxContainer.new()
	side_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	side_vbox.add_theme_constant_override("separation", 14)
	scroll.add_child(side_vbox)

	# --- Section 1: Phẩm chất (Rarity) ---
	var r_header_hbox := HBoxContainer.new()
	r_header_hbox.custom_minimum_size = Vector2(0, 30)
	side_vbox.add_child(r_header_hbox)

	_rarity_name_lbl = Label.new()
	_rarity_name_lbl.text = "Phẩm chất: Tất cả"
	_rarity_name_lbl.add_theme_font_size_override("font_size", 14)
	_rarity_name_lbl.add_theme_color_override("font_color", Color("#cbd5e1"))
	_rarity_name_lbl.size_flags_horizontal = SIZE_EXPAND_FILL
	_rarity_name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	r_header_hbox.add_child(_rarity_name_lbl)

	var r_reset_btn := Button.new()
	r_reset_btn.tooltip_text = "Chọn tất cả phẩm chất"
	r_reset_btn.custom_minimum_size = Vector2(30, 30)
	r_reset_btn.focus_mode = FOCUS_NONE
	_strip_button_style(r_reset_btn)
	var r_sel_icon := TextureRect.new()
	r_sel_icon.set_anchors_preset(PRESET_FULL_RECT)
	r_sel_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r_sel_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r_sel_icon.mouse_filter = MOUSE_FILTER_IGNORE
	var sel_all_tex := _get_cached_texture("res://assets/ui/rarity/select.png")
	if sel_all_tex != null:
		r_sel_icon.texture = sel_all_tex
	r_reset_btn.add_child(r_sel_icon)
	r_reset_btn.pressed.connect(func() -> void:
		_rarity_filter_enabled = false
		_selected_rarities.clear()
		_refresh_filters_ui()
		_refresh_items_grid()
	)
	r_header_hbox.add_child(r_reset_btn)

	var r_deselect_btn := Button.new()
	r_deselect_btn.tooltip_text = "Bỏ chọn tất cả phẩm chất"
	r_deselect_btn.custom_minimum_size = Vector2(30, 30)
	r_deselect_btn.focus_mode = FOCUS_NONE
	_strip_button_style(r_deselect_btn)
	var r_desel_icon := TextureRect.new()
	r_desel_icon.set_anchors_preset(PRESET_FULL_RECT)
	r_desel_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r_desel_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r_desel_icon.mouse_filter = MOUSE_FILTER_IGNORE
	var desel_all_tex := _get_cached_texture("res://assets/ui/rarity/unselect.png")
	if desel_all_tex != null:
		r_desel_icon.texture = desel_all_tex
	r_deselect_btn.add_child(r_desel_icon)
	r_deselect_btn.pressed.connect(func() -> void:
		_rarity_filter_enabled = true
		_selected_rarities.clear()
		_refresh_filters_ui()
		_refresh_items_grid()
	)
	r_header_hbox.add_child(r_deselect_btn)

	# Diamond buttons row (6 Rarities from SVG vector icons - enlarged and crisp, no blue bg box)
	var diamonds_hbox := HBoxContainer.new()
	diamonds_hbox.add_theme_constant_override("separation", 8)
	side_vbox.add_child(diamonds_hbox)

	var rarities := [
		ITEM_CLASS.Rarity.WHITE,
		ITEM_CLASS.Rarity.GREEN,
		ITEM_CLASS.Rarity.BLUE,
		ITEM_CLASS.Rarity.PURPLE,
		ITEM_CLASS.Rarity.GOLD,
		ITEM_CLASS.Rarity.RED
	]
	for r in rarities:
		var d_btn := Button.new()
		d_btn.custom_minimum_size = Vector2(48, 48)
		d_btn.focus_mode = FOCUS_NONE
		d_btn.tooltip_text = ITEM_CLASS.rarity_name(r)
		var r_val: int = int(r)
		d_btn.set_meta("rarity", r_val)
		_strip_button_style(d_btn)

		var icon_rect := TextureRect.new()
		icon_rect.name = "RarityIcon"
		icon_rect.set_anchors_preset(PRESET_FULL_RECT)
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.mouse_filter = MOUSE_FILTER_IGNORE
		var init_tex := _get_cached_texture(_get_rarity_svg_path(r_val, true))
		if init_tex != null:
			icon_rect.texture = init_tex
		d_btn.add_child(icon_rect)

		d_btn.pressed.connect(func() -> void:
			if not _rarity_filter_enabled:
				_rarity_filter_enabled = true
				_selected_rarities.clear()
				_selected_rarities[r_val] = true
			else:
				if _selected_rarities.has(r_val):
					_selected_rarities.erase(r_val)
				else:
					_selected_rarities[r_val] = true
			_refresh_filters_ui()
			_refresh_items_grid()
		)
		diamonds_hbox.add_child(d_btn)
		_rarity_buttons.append(d_btn)

	# Divider
	var div1 := HSeparator.new()
	side_vbox.add_child(div1)

	# --- Section 2: Loại (Category) ---
	var c_header_hbox := HBoxContainer.new()
	side_vbox.add_child(c_header_hbox)

	_category_name_lbl = Label.new()
	_category_name_lbl.text = "Loại: (Tất cả)"
	_category_name_lbl.add_theme_font_size_override("font_size", 14)
	_category_name_lbl.add_theme_color_override("font_color", Color("#cbd5e1"))
	_category_name_lbl.size_flags_horizontal = SIZE_EXPAND_FILL
	c_header_hbox.add_child(_category_name_lbl)

	var c_reset_btn := Button.new()
	c_reset_btn.tooltip_text = "Chọn tất cả chủng loại"
	c_reset_btn.custom_minimum_size = Vector2(30, 30)
	c_reset_btn.focus_mode = FOCUS_NONE
	_strip_button_style(c_reset_btn)
	var c_sel_icon := TextureRect.new()
	c_sel_icon.set_anchors_preset(PRESET_FULL_RECT)
	c_sel_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	c_sel_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	c_sel_icon.mouse_filter = MOUSE_FILTER_IGNORE
	var c_sel_tex := _get_cached_texture("res://assets/ui/rarity/select.png")
	if c_sel_tex != null:
		c_sel_icon.texture = c_sel_tex
	c_reset_btn.add_child(c_sel_icon)
	c_reset_btn.pressed.connect(func() -> void:
		_category_filter_enabled = false
		_selected_categories.clear()
		_refresh_filters_ui()
		_refresh_items_grid()
	)
	c_header_hbox.add_child(c_reset_btn)

	var c_deselect_btn := Button.new()
	c_deselect_btn.tooltip_text = "Bỏ chọn tất cả chủng loại"
	c_deselect_btn.custom_minimum_size = Vector2(30, 30)
	c_deselect_btn.focus_mode = FOCUS_NONE
	_strip_button_style(c_deselect_btn)
	var c_desel_icon := TextureRect.new()
	c_desel_icon.set_anchors_preset(PRESET_FULL_RECT)
	c_desel_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	c_desel_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	c_desel_icon.mouse_filter = MOUSE_FILTER_IGNORE
	var c_desel_tex := _get_cached_texture("res://assets/ui/rarity/unselect.png")
	if c_desel_tex != null:
		c_desel_icon.texture = c_desel_tex
	c_deselect_btn.add_child(c_desel_icon)
	c_deselect_btn.pressed.connect(func() -> void:
		_category_filter_enabled = true
		_selected_categories.clear()
		_refresh_filters_ui()
		_refresh_items_grid()
	)
	c_header_hbox.add_child(c_deselect_btn)

	var cat_grid := GridContainer.new()
	cat_grid.columns = 4
	cat_grid.add_theme_constant_override("h_separation", 6)
	cat_grid.add_theme_constant_override("v_separation", 6)
	side_vbox.add_child(cat_grid)

	for cat_entry in CATALOG_CLASS.CATEGORIES:
		var c_id: String = String(cat_entry.get("id", ""))
		var c_lbl: String = String(cat_entry.get("label", ""))
		var c_icon: String = String(cat_entry.get("icon", "📦"))
		var c_icon_path: String = String(cat_entry.get("icon_path", ""))

		var c_btn := Button.new()
		c_btn.tooltip_text = c_lbl
		c_btn.custom_minimum_size = Vector2(56, 56)
		c_btn.focus_mode = FOCUS_NONE
		c_btn.set_meta("cat_id", c_id)
		_strip_button_style(c_btn)

		var tex: Texture2D = _get_cached_texture(c_icon_path) if not c_icon_path.is_empty() else null
		if tex != null:
			var icon_rect := TextureRect.new()
			icon_rect.name = "CatIcon"
			icon_rect.set_anchors_preset(PRESET_FULL_RECT)
			icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon_rect.mouse_filter = MOUSE_FILTER_IGNORE
			icon_rect.texture = tex
			c_btn.add_child(icon_rect)
		else:
			c_btn.text = "%s" % c_icon
			c_btn.add_theme_font_size_override("font_size", 16)

		c_btn.pressed.connect(func() -> void:
			if not _category_filter_enabled:
				_category_filter_enabled = true
				_selected_categories.clear()
				_selected_categories[c_id] = true
			else:
				if _selected_categories.has(c_id):
					_selected_categories.erase(c_id)
				else:
					_selected_categories[c_id] = true
			_refresh_filters_ui()
			_refresh_items_grid()
		)
		cat_grid.add_child(c_btn)
		_category_buttons.append(c_btn)

	# Divider
	var div2 := HSeparator.new()
	side_vbox.add_child(div2)

	# --- Section 3: Hình dáng (Shape Footprint) ---
	var s_header_hbox := HBoxContainer.new()
	side_vbox.add_child(s_header_hbox)

	_shape_name_lbl = Label.new()
	_shape_name_lbl.text = "Hình dáng: Tất cả"
	_shape_name_lbl.add_theme_font_size_override("font_size", 14)
	_shape_name_lbl.add_theme_color_override("font_color", Color("#cbd5e1"))
	_shape_name_lbl.size_flags_horizontal = SIZE_EXPAND_FILL
	s_header_hbox.add_child(_shape_name_lbl)

	var s_reset_btn := Button.new()
	s_reset_btn.tooltip_text = "Chọn tất cả hình dáng"
	s_reset_btn.custom_minimum_size = Vector2(30, 30)
	s_reset_btn.focus_mode = FOCUS_NONE
	_strip_button_style(s_reset_btn)
	var s_sel_icon := TextureRect.new()
	s_sel_icon.set_anchors_preset(PRESET_FULL_RECT)
	s_sel_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	s_sel_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	s_sel_icon.mouse_filter = MOUSE_FILTER_IGNORE
	var s_sel_tex := _get_cached_texture("res://assets/ui/rarity/select.png")
	if s_sel_tex != null:
		s_sel_icon.texture = s_sel_tex
	s_reset_btn.add_child(s_sel_icon)
	s_reset_btn.pressed.connect(func() -> void:
		_shape_filter_enabled = false
		_selected_shapes.clear()
		_refresh_filters_ui()
		_refresh_items_grid()
	)
	s_header_hbox.add_child(s_reset_btn)

	var s_deselect_btn := Button.new()
	s_deselect_btn.tooltip_text = "Bỏ chọn tất cả hình dáng"
	s_deselect_btn.custom_minimum_size = Vector2(30, 30)
	s_deselect_btn.focus_mode = FOCUS_NONE
	_strip_button_style(s_deselect_btn)
	var s_desel_icon := TextureRect.new()
	s_desel_icon.set_anchors_preset(PRESET_FULL_RECT)
	s_desel_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	s_desel_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	s_desel_icon.mouse_filter = MOUSE_FILTER_IGNORE
	var s_desel_tex := _get_cached_texture("res://assets/ui/rarity/unselect.png")
	if s_desel_tex != null:
		s_desel_icon.texture = s_desel_tex
	s_deselect_btn.add_child(s_desel_icon)
	s_deselect_btn.pressed.connect(func() -> void:
		_shape_filter_enabled = true
		_selected_shapes.clear()
		_refresh_filters_ui()
		_refresh_items_grid()
	)
	s_header_hbox.add_child(s_deselect_btn)

	# 16 Shape Footprint buttons in 4 columns
	var shape_grid := GridContainer.new()
	shape_grid.columns = 4
	shape_grid.add_theme_constant_override("h_separation", 6)
	shape_grid.add_theme_constant_override("v_separation", 6)
	side_vbox.add_child(shape_grid)

	var shapes: Array[Vector2i] = [
		Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3), Vector2i(1, 4),
		Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3), Vector2i(2, 4),
		Vector2i(3, 1), Vector2i(3, 2), Vector2i(3, 3), Vector2i(3, 4),
		Vector2i(4, 1), Vector2i(4, 2), Vector2i(4, 3), Vector2i(4, 4),
	]
	for sh in shapes:
		var sh_btn := Button.new()
		sh_btn.tooltip_text = "Kích thước: %dx%d ô" % [sh.x, sh.y]
		sh_btn.custom_minimum_size = Vector2(56, 56)
		sh_btn.focus_mode = FOCUS_NONE
		sh_btn.set_meta("shape", sh)
		_strip_button_style(sh_btn)

		var icon_rect := TextureRect.new()
		icon_rect.name = "ShapeIcon"
		icon_rect.set_anchors_preset(PRESET_FULL_RECT)
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.mouse_filter = MOUSE_FILTER_IGNORE
		var sh_path := "res://assets/auction_items/%dx%d.png" % [sh.x, sh.y]
		var tex := _get_cached_texture(sh_path)
		if tex != null:
			icon_rect.texture = tex
		sh_btn.add_child(icon_rect)

		sh_btn.pressed.connect(func() -> void:
			if not _shape_filter_enabled:
				_shape_filter_enabled = true
				_selected_shapes.clear()
				_selected_shapes[sh] = true
			else:
				if _selected_shapes.has(sh):
					_selected_shapes.erase(sh)
				else:
					_selected_shapes[sh] = true
			_refresh_filters_ui()
			_refresh_items_grid()
		)
		shape_grid.add_child(sh_btn)
		_shape_buttons.append(sh_btn)

	return side_panel


func _build_content_area() -> Control:
	var content_vbox := VBoxContainer.new()
	content_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	content_vbox.size_flags_vertical = SIZE_EXPAND_FILL
	content_vbox.add_theme_constant_override("separation", 8)
	content_vbox.offset_right = -12
	content_vbox.offset_top = 8
	content_vbox.offset_bottom = -8

	# Header Bar (Price range & items count - neatly padded inside khung.png's top bar)
	var header_margin := MarginContainer.new()
	header_margin.custom_minimum_size = Vector2(0, 36)
	header_margin.add_theme_constant_override("margin_left", 32)
	header_margin.add_theme_constant_override("margin_right", 16)
	content_vbox.add_child(header_margin)

	var header_bar := HBoxContainer.new()
	header_bar.size_flags_horizontal = SIZE_EXPAND_FILL
	header_bar.size_flags_vertical = SIZE_EXPAND_FILL
	header_margin.add_child(header_bar)

	_item_count_lbl = Label.new()
	_item_count_lbl.text = "0 Vật Phẩm"
	_item_count_lbl.add_theme_font_size_override("font_size", 14)
	_item_count_lbl.add_theme_color_override("font_color", Color("#cbd5e1"))
	_item_count_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header_bar.add_child(_item_count_lbl)

	var sp := Control.new()
	sp.size_flags_horizontal = SIZE_EXPAND_FILL
	header_bar.add_child(sp)

	_price_range_lbl = Label.new()
	_price_range_lbl.text = "0 - 0 Xu Bạc"
	_price_range_lbl.add_theme_font_size_override("font_size", 15)
	_price_range_lbl.add_theme_color_override("font_color", Color("#f6c95c"))
	_price_range_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header_bar.add_child(_price_range_lbl)

	# Scrollable grid of items
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.size_flags_vertical = SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_vbox.add_child(scroll)

	_cards_grid = GridContainer.new()
	_cards_grid.columns = 3
	_cards_grid.size_flags_horizontal = SIZE_EXPAND_FILL
	_cards_grid.add_theme_constant_override("h_separation", 14)
	_cards_grid.add_theme_constant_override("v_separation", 14)
	scroll.add_child(_cards_grid)

	return content_vbox


func _refresh_filters_ui() -> void:
	# 1. Rarity label & button highlights
	if not _rarity_filter_enabled:
		_rarity_name_lbl.text = "Phẩm chất: Tất cả"
	elif _selected_rarities.is_empty():
		_rarity_name_lbl.text = "Phẩm chất: (0 đã chọn)"
	elif _selected_rarities.size() == 1:
		var r_only: int = int(_selected_rarities.keys()[0])
		_rarity_name_lbl.text = "Phẩm chất: %s" % ITEM_CLASS.rarity_name(r_only as ITEM_CLASS.Rarity)
	else:
		_rarity_name_lbl.text = "Phẩm chất: %d loại" % _selected_rarities.size()

	for btn in _rarity_buttons:
		var r: int = int(btn.get_meta("rarity", -1))
		var is_active: bool = (not _rarity_filter_enabled or _selected_rarities.has(r))
		var tex_path: String = _get_rarity_svg_path(r, is_active)
		var tex: Texture2D = _get_cached_texture(tex_path)
		var icon_rect: TextureRect = btn.get_node_or_null("RarityIcon")
		if icon_rect != null and tex != null:
			icon_rect.texture = tex
		elif tex != null:
			btn.icon = tex
		if is_active:
			btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			btn.modulate = Color(1.0, 1.0, 1.0, 0.70)

	# 2. Category label & button highlights
	if not _category_filter_enabled:
		_category_name_lbl.text = "Loại: (Tất cả)"
	elif _selected_categories.is_empty():
		_category_name_lbl.text = "Loại: (0 đã chọn)"
	elif _selected_categories.size() == 1:
		var cat_only: String = String(_selected_categories.keys()[0])
		var found_name := cat_only
		for c in CATALOG_CLASS.CATEGORIES:
			if c.get("id") == cat_only:
				found_name = String(c.get("label", ""))
				break
		_category_name_lbl.text = "Loại: (%s)" % found_name
	else:
		_category_name_lbl.text = "Loại: %d loại" % _selected_categories.size()

	for btn in _category_buttons:
		var cat_id: String = String(btn.get_meta("cat_id", ""))
		if not _category_filter_enabled:
			btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
		elif _selected_categories.has(cat_id):
			btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			btn.modulate = Color(0.65, 0.65, 0.65, 0.28)

	# 3. Shape label & button highlights
	if _shape_name_lbl != null:
		if not _shape_filter_enabled:
			_shape_name_lbl.text = "Hình dáng: Tất cả"
		elif _selected_shapes.is_empty():
			_shape_name_lbl.text = "Hình dáng: (0 đã chọn)"
		elif _selected_shapes.size() == 1:
			var sh_only: Vector2i = _selected_shapes.keys()[0]
			_shape_name_lbl.text = "Hình dáng: %dx%d" % [sh_only.x, sh_only.y]
		else:
			_shape_name_lbl.text = "Hình dáng: %d loại" % _selected_shapes.size()

	for btn in _shape_buttons:
		var sh: Vector2i = btn.get_meta("shape", Vector2i.ZERO)
		if not _shape_filter_enabled or _selected_shapes.has(sh):
			btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			btn.modulate = Color(0.65, 0.65, 0.65, 0.28)


func _refresh_items_grid() -> void:
	for child in _cards_grid.get_children():
		child.queue_free()

	var items: Array[Dictionary] = CATALOG_CLASS.filter_items_multi(
		_selected_rarities,
		_rarity_filter_enabled,
		_selected_categories,
		_category_filter_enabled,
		_selected_shapes,
		_shape_filter_enabled
	)

	# Thứ tự mặc định: sắp xếp từ giá cao nhất xuống giá thấp nhất
	items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var va: int = int(a.get("silver_value", 0))
		var vb: int = int(b.get("silver_value", 0))
		if va != vb:
			return va > vb
		var ra: int = int(a.get("rarity", 0))
		var rb: int = int(b.get("rarity", 0))
		if ra != rb:
			return ra > rb
		return String(a.get("id", "")) < String(b.get("id", ""))
	)

	_item_count_lbl.text = "%d Vật Phẩm" % items.size()

	if items.is_empty():
		_price_range_lbl.text = "Không có vật phẩm"
		return

	# Calculate price range
	var min_val: int = 99999999
	var max_val: int = 0
	for it in items:
		var v := int(it.get("silver_value", 0))
		if v < min_val: min_val = v
		if v > max_val: max_val = v
	if min_val == 99999999: min_val = 0
	_price_range_lbl.text = "🪙 %s - %s Xu Bạc" % [_format_number(min_val), _format_number(max_val)]

	# Create Cards
	for it in items:
		var card := _create_item_card(it)
		_cards_grid.add_child(card)


static func create_item_card(data: Dictionary) -> Control:
	var rarity: int = int(data.get("rarity", ITEM_CLASS.Rarity.WHITE))
	var r_color: Color = ITEM_CLASS.rarity_color(rarity as ITEM_CLASS.Rarity)
	var d_name: String = String(data.get("display_name", "Vật Phẩm"))
	var s_val: int = int(data.get("silver_value", 0))
	var w: int = int(data.get("grid_width", 1))
	var h: int = int(data.get("grid_height", 1))
	var weight_str: String = String(data.get("weight_str", "<0.10KG"))
	var asset_path: String = String(data.get("asset_path", ""))
	var is_res: bool = bool(data.get("is_resource", false))

	var card := Control.new()
	card.custom_minimum_size = Vector2(246, 193)
	card.size_flags_horizontal = SIZE_EXPAND_FILL
	card.tooltip_text = "%s\nPhẩm chất: %s\nKích thước: %dx%d ô\nGiá trị: %s Xu Bạc\nKhối lượng: %s" % [
		d_name,
		ITEM_CLASS.rarity_name(rarity as ITEM_CLASS.Rarity),
		w, h,
		format_number(s_val),
		weight_str
	]

	# 1. Background Antique Card Frame (khung_item.png)
	var frame_rect := TextureRect.new()
	frame_rect.name = "FrameBG"
	frame_rect.set_anchors_preset(PRESET_FULL_RECT)
	frame_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame_rect.stretch_mode = TextureRect.STRETCH_SCALE
	frame_rect.mouse_filter = MOUSE_FILTER_IGNORE
	var frame_tex := get_cached_texture("res://assets/ui/rarity/khung_item.png")
	if frame_tex != null:
		frame_rect.texture = frame_tex
	card.add_child(frame_rect)

	# Subtle hover highlight on card
	card.mouse_entered.connect(func() -> void:
		frame_rect.modulate = Color(1.18, 1.18, 1.18, 1.0)
	)
	card.mouse_exited.connect(func() -> void:
		frame_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)
	)

	# Card Content layout
	var card_vbox := VBoxContainer.new()
	card_vbox.set_anchors_preset(PRESET_FULL_RECT)
	card_vbox.mouse_filter = MOUSE_FILTER_PASS
	card_vbox.add_theme_constant_override("separation", 0)
	card.add_child(card_vbox)

	# --- 1. Card Header Band (Inside frame's top header compartment) ---
	var header_panel := MarginContainer.new()
	header_panel.custom_minimum_size = Vector2(0, 32)
	header_panel.add_theme_constant_override("margin_left", 12)
	header_panel.add_theme_constant_override("margin_right", 12)
	header_panel.add_theme_constant_override("margin_top", 4)
	header_panel.add_theme_constant_override("margin_bottom", 2)
	card_vbox.add_child(header_panel)

	var h_hbox := HBoxContainer.new()
	h_hbox.add_theme_constant_override("separation", 6)
	h_hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	header_panel.add_child(h_hbox)

	var rarity_icon := TextureRect.new()
	rarity_icon.custom_minimum_size = Vector2(18, 18)
	rarity_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rarity_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rarity_icon.tooltip_text = ITEM_CLASS.rarity_name(rarity as ITEM_CLASS.Rarity)
	var r_svg_path := _get_rarity_svg_path(rarity, true)
	var r_tex := get_cached_texture(r_svg_path)
	if r_tex != null:
		rarity_icon.texture = r_tex
		h_hbox.add_child(rarity_icon)
	else:
		var diamond_lbl := Label.new()
		diamond_lbl.text = "◆"
		diamond_lbl.add_theme_font_size_override("font_size", 14)
		diamond_lbl.add_theme_color_override("font_color", r_color)
		h_hbox.add_child(diamond_lbl)

	var name_lbl := Label.new()
	name_lbl.text = d_name
	name_lbl.add_theme_font_size_override("font_size", 13)
	name_lbl.add_theme_color_override("font_color", r_color)
	name_lbl.size_flags_horizontal = SIZE_EXPAND_FILL
	name_lbl.clip_text = true
	name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	h_hbox.add_child(name_lbl)

	# --- 2. Center Image & Footprint Area ---
	var body_control := Control.new()
	body_control.size_flags_vertical = SIZE_EXPAND_FILL
	body_control.clip_contents = true
	body_control.mouse_filter = MOUSE_FILTER_PASS
	card_vbox.add_child(body_control)

	# Item Texture
	var texture_rect := TextureRect.new()
	texture_rect.set_anchors_preset(PRESET_FULL_RECT)
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.offset_left = 14
	texture_rect.offset_top = 4
	texture_rect.offset_right = -14
	texture_rect.offset_bottom = -4
	texture_rect.mouse_filter = MOUSE_FILTER_IGNORE
	body_control.add_child(texture_rect)

	if not asset_path.is_empty():
		var tex: Texture2D = get_cached_texture(asset_path)
		if tex != null:
			texture_rect.texture = tex

	# 16-Cell (4x4) Footprint Matrix in Bottom-Right Corner
	var footprint_control := create_footprint_matrix(w, h)
	footprint_control.set_anchors_preset(PRESET_BOTTOM_RIGHT)
	footprint_control.offset_left = -44
	footprint_control.offset_top = -42
	footprint_control.offset_right = -12
	footprint_control.offset_bottom = -8
	footprint_control.mouse_filter = MOUSE_FILTER_IGNORE
	body_control.add_child(footprint_control)

	# --- 3. Card Footer (Weight & Price) ---
	var footer_panel := MarginContainer.new()
	footer_panel.custom_minimum_size = Vector2(0, 26)
	footer_panel.add_theme_constant_override("margin_left", 14)
	footer_panel.add_theme_constant_override("margin_right", 14)
	footer_panel.add_theme_constant_override("margin_bottom", 8)
	card_vbox.add_child(footer_panel)

	var f_hbox := HBoxContainer.new()
	footer_panel.add_child(f_hbox)

	var w_lbl := Label.new()
	w_lbl.text = weight_str
	w_lbl.add_theme_font_size_override("font_size", 11)
	w_lbl.add_theme_color_override("font_color", Color("#cbd5e1"))
	f_hbox.add_child(w_lbl)

	var f_sp := Control.new()
	f_sp.size_flags_horizontal = SIZE_EXPAND_FILL
	f_hbox.add_child(f_sp)

	if is_res and s_val == 0:
		var res_tag := HBoxContainer.new()
		res_tag.add_theme_constant_override("separation", 5)
		res_tag.alignment = BoxContainer.ALIGNMENT_CENTER

		var res_lbl := Label.new()
		res_lbl.text = "Tài nguyên"
		res_lbl.add_theme_color_override("font_color", Color("#8be9fd"))
		res_lbl.add_theme_font_size_override("font_size", 11)
		res_tag.add_child(res_lbl)

		var res_icon := TextureRect.new()
		res_icon.custom_minimum_size = Vector2(16, 16)
		res_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		res_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var r_icon_tex := get_cached_texture("res://assets/auction_items/tai_nguyen.png")
		if r_icon_tex != null:
			res_icon.texture = r_icon_tex
		res_tag.add_child(res_icon)

		f_hbox.add_child(res_tag)
	else:
		var price_lbl := Label.new()
		price_lbl.text = "🪙 %s Xu" % format_number(s_val)
		price_lbl.add_theme_color_override("font_color", Color("#f6c95c"))
		price_lbl.add_theme_font_size_override("font_size", 12)
		f_hbox.add_child(price_lbl)

	return card


func _create_item_card(data: Dictionary) -> Control:
	return create_item_card(data)



## Vẽ ma trận ô thể hiện diện tích chiếm chỗ của vật phẩm (Đi từ góc trên bên trái đi xuống)
static func create_footprint_matrix(item_w: int, item_h: int) -> Control:
	var ctrl := Control.new()
	var cols := maxi(4, item_w)
	var rows := maxi(4, item_h)
	var cell_sz := 5.5
	var gap := 1.5
	if cols > 4:
		cell_sz = 4.2
		gap = 1.0
	var total_w := cols * cell_sz + (cols - 1) * gap
	var total_h := rows * cell_sz + (rows - 1) * gap
	ctrl.custom_minimum_size = Vector2(total_w, total_h)
	ctrl.draw.connect(func() -> void:
		var empty_col := Color(1.0, 1.0, 1.0, 0.15)
		var filled_col := Color(1.0, 1.0, 1.0, 0.95)

		# columns x rows, đi từ góc trên bên trái đi xuống
		for row in range(rows):
			for col in range(cols):
				var r := Rect2(
					col * (cell_sz + gap),
					row * (cell_sz + gap),
					cell_sz,
					cell_sz
				)
				if col < item_w and row < item_h:
					ctrl.draw_rect(r, filled_col, true)
				else:
					ctrl.draw_rect(r, empty_col, true)
	)
	return ctrl


func _create_footprint_matrix(item_w: int, item_h: int) -> Control:
	return create_footprint_matrix(item_w, item_h)


static func get_cached_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if _texture_cache.has(path):
		return _texture_cache[path] as Texture2D
	if ResourceLoader.exists(path):
		var res := load(path)
		if res is Texture2D:
			_texture_cache[path] = res
			return res
	# Fallback nạp trực tiếp từ file trên ổ đĩa nếu file chưa kịp được Godot tạo .import
	var global_path := ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(global_path):
		var img := Image.load_from_file(global_path)
		if img != null and not img.is_empty():
			var tex := ImageTexture.create_from_image(img)
			if tex != null:
				_texture_cache[path] = tex
				return tex
	return null


func _get_cached_texture(path: String) -> Texture2D:
	return get_cached_texture(path)


static func format_number(val: int) -> String:
	var s := str(absi(val))
	var res := ""
	var cnt := 0
	for i in range(s.length() - 1, -1, -1):
		res = s[i] + res
		cnt += 1
		if cnt % 3 == 0 and i > 0:
			res = "," + res
	return ("-" if val < 0 else "") + res


func _format_number(val: int) -> String:
	return format_number(val)


## Xóa bỏ hoàn toàn StyleBox viền xanh mặc định của Button để icon hiển thị trọn vẹn
func _strip_button_style(btn: Button) -> void:
	var empty := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty)
	btn.add_theme_stylebox_override("hover", empty)
	btn.add_theme_stylebox_override("pressed", empty)
	btn.add_theme_stylebox_override("focus", empty)
	btn.add_theme_stylebox_override("disabled", empty)

