class_name AuctionScreen
extends Control

signal auction_finished(settlement_data: Dictionary)

const AUCTION_SESSION_CLASS := preload("res://scripts/domain/loot/AuctionSession.gd")
const CHEST_STATE_CLASS := preload("res://scripts/domain/loot/MysteryChestState.gd")
const ITEM_CLASS := preload("res://scripts/domain/loot/MysteryChestItem.gd")

const CELL_SIZE: int = 46
const GRID_COLS: int = 10
const GRID_ROWS: int = 8

var auction_session: AuctionSession
var player_silver_balances: Dictionary = {} # player_id -> int

# Item placements in the 10x8 grid
# Dictionary: item_id -> { "pos": Vector2i, "w": int, "h": int, "item": MysteryChestItem }
var _grid_placements: Dictionary = {}
var _revealed_items: Dictionary = {} # item_id -> bool
var _revealed_outlines: Dictionary = {} # item_id -> bool
var _revealed_qualities: Dictionary = {} # item_id -> bool

# UI Nodes
var _bg_rect: ColorRect
var _left_column: VBoxContainer
var _bidders_container: VBoxContainer
var _mid_column: VBoxContainer
var _round_label: Label
var _clues_feed: VBoxContainer
var _clues_scroll: ScrollContainer
var _right_column: VBoxContainer
var _grid_draw_control: Control
var _min_value_label: Label
var _bottom_bar: PanelContainer
var _timer_label: Label
var _bid_box: HBoxContainer
var _bid_label: Label
var _current_bid_value: int = 50
var _confirm_bid_btn: Button
var _next_round_btn: Button
var _solo_box: HBoxContainer
var _solo_buy_btn: Button
var _solo_pass_btn: Button
var _settlement_overlay: ColorRect
var _settlement_panel: PanelContainer
var _settlement_content: VBoxContainer


func _init() -> void:
	name = "AuctionScreen"
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_STOP
	_build_ui()


func setup(session: AuctionSession, player_silvers: Dictionary = {}) -> void:
	auction_session = session
	player_silver_balances = player_silvers.duplicate()
	_current_bid_value = maxi(50, int(session.mystery_chest.total_silver_value() * 0.3))
	_generate_grid_placements()
	_sync_reveals_from_hints()
	refresh_ui()


func _build_ui() -> void:
	# 1. Dark frosted sci-fi/imperial backdrop
	_bg_rect = ColorRect.new()
	_bg_rect.set_anchors_preset(PRESET_FULL_RECT)
	_bg_rect.color = Color(0.05, 0.08, 0.12, 0.96)
	add_child(_bg_rect)

	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_preset(PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 10)
	main_vbox.offset_left = 18
	main_vbox.offset_top = 14
	main_vbox.offset_right = -18
	main_vbox.offset_bottom = -14
	add_child(main_vbox)

	# --- Top Bar ---
	var top_bar := HBoxContainer.new()
	top_bar.custom_minimum_size = Vector2(0, 42)
	main_vbox.add_child(top_bar)

	var title_lbl := Label.new()
	title_lbl.text = "🏛️ ĐẤU GIÁ HÒM BÍ ẨN HOÀNG GIA"
	title_lbl.add_theme_font_size_override("font_size", 22)
	title_lbl.add_theme_color_override("font_color", Color("#f6c95c"))
	top_bar.add_child(title_lbl)

	var spacer_top := Control.new()
	spacer_top.size_flags_horizontal = SIZE_EXPAND_FILL
	top_bar.add_child(spacer_top)

	var currency_lbl := Label.new()
	currency_lbl.text = "🪙 Xu Bạc: Sẵn sàng  |  💎 Vé Đấu Giá: 5"
	currency_lbl.add_theme_font_size_override("font_size", 15)
	currency_lbl.add_theme_color_override("font_color", Color("#8be9fd"))
	top_bar.add_child(currency_lbl)

	# --- 3 Columns Body ---
	var body_hbox := HBoxContainer.new()
	body_hbox.size_flags_vertical = SIZE_EXPAND_FILL
	body_hbox.add_theme_constant_override("separation", 16)
	main_vbox.add_child(body_hbox)

	# CỘT TRÁI: NGƯỜI ĐẤU GIÁ (BIDDERS - 290px)
	_left_column = VBoxContainer.new()
	_left_column.custom_minimum_size = Vector2(290, 0)
	_left_column.add_theme_constant_override("separation", 8)
	body_hbox.add_child(_left_column)

	var b_header := Label.new()
	b_header.text = "👥 NGƯỜI ĐẤU GIÁ"
	b_header.add_theme_font_size_override("font_size", 16)
	b_header.add_theme_color_override("font_color", Color("#50fa7b"))
	_left_column.add_child(b_header)

	var b_panel := PanelContainer.new()
	b_panel.size_flags_vertical = SIZE_EXPAND_FILL
	var bp_style := StyleBoxFlat.new()
	bp_style.bg_color = Color(0.08, 0.12, 0.16, 0.85)
	bp_style.border_color = Color(0.25, 0.38, 0.5, 0.6)
	bp_style.border_width_left = 1
	bp_style.border_width_top = 1
	bp_style.border_width_right = 1
	bp_style.border_width_bottom = 1
	bp_style.corner_radius_top_left = 6
	bp_style.corner_radius_top_right = 6
	bp_style.corner_radius_bottom_left = 6
	bp_style.corner_radius_bottom_right = 6
	b_panel.add_theme_stylebox_override("panel", bp_style)
	_left_column.add_child(b_panel)

	var b_scroll := ScrollContainer.new()
	b_panel.add_child(b_scroll)
	_bidders_container = VBoxContainer.new()
	_bidders_container.size_flags_horizontal = SIZE_EXPAND_FILL
	_bidders_container.add_theme_constant_override("separation", 10)
	b_scroll.add_child(_bidders_container)

	# CỘT GIỮA: BẢNG MANH MỐI FEED (440px)
	_mid_column = VBoxContainer.new()
	_mid_column.custom_minimum_size = Vector2(440, 0)
	_mid_column.add_theme_constant_override("separation", 8)
	body_hbox.add_child(_mid_column)

	var round_badge := PanelContainer.new()
	var r_style := StyleBoxFlat.new()
	r_style.bg_color = Color(0.12, 0.22, 0.32, 0.9)
	r_style.border_color = Color("#4deeea")
	r_style.border_width_left = 2
	r_style.border_width_right = 2
	r_style.corner_radius_top_left = 8
	r_style.corner_radius_top_right = 8
	r_style.corner_radius_bottom_left = 8
	r_style.corner_radius_bottom_right = 8
	round_badge.add_theme_stylebox_override("panel", r_style)
	_mid_column.add_child(round_badge)

	_round_label = Label.new()
	_round_label.text = "VÒNG 1 / 5"
	_round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_round_label.add_theme_font_size_override("font_size", 18)
	_round_label.add_theme_color_override("font_color", Color.WHITE)
	round_badge.add_child(_round_label)

	_clues_scroll = ScrollContainer.new()
	_clues_scroll.size_flags_vertical = SIZE_EXPAND_FILL
	_clues_scroll.size_flags_horizontal = SIZE_EXPAND_FILL
	_mid_column.add_child(_clues_scroll)

	_clues_feed = VBoxContainer.new()
	_clues_feed.size_flags_horizontal = SIZE_EXPAND_FILL
	_clues_feed.add_theme_constant_override("separation", 10)
	_clues_scroll.add_child(_clues_feed)

	# CỘT PHẢI: CHIẾN LỢI PHẨM / HÒM BÍ ẨN (10x8 GRID)
	_right_column = VBoxContainer.new()
	_right_column.size_flags_horizontal = SIZE_EXPAND_FILL
	_right_column.add_theme_constant_override("separation", 8)
	body_hbox.add_child(_right_column)

	var grid_top := HBoxContainer.new()
	_right_column.add_child(grid_top)

	var grid_title := Label.new()
	grid_title.text = "📦 CHIẾN LỢI PHẨM TRONG HÒM"
	grid_title.add_theme_font_size_override("font_size", 16)
	grid_title.add_theme_color_override("font_color", Color("#f1fa8c"))
	grid_top.add_child(grid_title)

	var sp_gt := Control.new()
	sp_gt.size_flags_horizontal = SIZE_EXPAND_FILL
	grid_top.add_child(sp_gt)

	var enc_btn := Button.new()
	enc_btn.text = "📖 Bách Khoa Vật Phẩm"
	enc_btn.flat = true
	enc_btn.add_theme_color_override("font_color", Color("#8be9fd"))
	grid_top.add_child(enc_btn)

	var crate_panel := PanelContainer.new()
	crate_panel.custom_minimum_size = Vector2(GRID_COLS * CELL_SIZE + 20, GRID_ROWS * CELL_SIZE + 20)
	crate_panel.size_flags_horizontal = SIZE_EXPAND_FILL
	crate_panel.size_flags_vertical = SIZE_EXPAND_FILL
	var c_style := StyleBoxFlat.new()
	c_style.bg_color = Color(0.04, 0.07, 0.1, 0.95)
	c_style.border_color = Color(0.25, 0.45, 0.65, 0.8)
	c_style.border_width_left = 2
	c_style.border_width_top = 2
	c_style.border_width_right = 2
	c_style.border_width_bottom = 2
	c_style.corner_radius_top_left = 8
	c_style.corner_radius_top_right = 8
	c_style.corner_radius_bottom_left = 8
	c_style.corner_radius_bottom_right = 8
	crate_panel.add_theme_stylebox_override("panel", c_style)
	_right_column.add_child(crate_panel)

	var center_grid := CenterContainer.new()
	center_grid.set_anchors_preset(PRESET_FULL_RECT)
	crate_panel.add_child(center_grid)

	_grid_draw_control = Control.new()
	_grid_draw_control.custom_minimum_size = Vector2(GRID_COLS * CELL_SIZE, GRID_ROWS * CELL_SIZE)
	_grid_draw_control.draw.connect(_on_grid_draw)
	center_grid.add_child(_grid_draw_control)

	_min_value_label = Label.new()
	_min_value_label.text = "Giá ước tính thấp nhất hiện tại: 0 Xu Bạc"
	_min_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_min_value_label.add_theme_font_size_override("font_size", 15)
	_min_value_label.add_theme_color_override("font_color", Color("#50fa7b"))
	_right_column.add_child(_min_value_label)

	# --- BOTTOM ACTION BAR ---
	_bottom_bar = PanelContainer.new()
	_bottom_bar.custom_minimum_size = Vector2(0, 65)
	var btm_style := StyleBoxFlat.new()
	btm_style.bg_color = Color(0.08, 0.13, 0.19, 0.96)
	btm_style.border_color = Color(0.3, 0.5, 0.7, 0.7)
	btm_style.border_width_top = 2
	btm_style.corner_radius_top_left = 8
	btm_style.corner_radius_top_right = 8
	_bottom_bar.add_theme_stylebox_override("panel", btm_style)
	main_vbox.add_child(_bottom_bar)

	var btm_hbox := HBoxContainer.new()
	btm_hbox.add_theme_constant_override("separation", 20)
	btm_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_bottom_bar.add_child(btm_hbox)

	_timer_label = Label.new()
	_timer_label.text = "⏱️ 30s"
	_timer_label.add_theme_font_size_override("font_size", 22)
	_timer_label.add_theme_color_override("font_color", Color("#ff5555"))
	btm_hbox.add_child(_timer_label)

	# Multi-player Bidding Controls
	_bid_box = HBoxContainer.new()
	_bid_box.add_theme_constant_override("separation", 10)
	btm_hbox.add_child(_bid_box)

	var minus_btn := Button.new()
	minus_btn.text = "- 20"
	minus_btn.pressed.connect(func() -> void: _adjust_bid(-20))
	_bid_box.add_child(minus_btn)

	_bid_label = Label.new()
	_bid_label.text = "Đã ra giá: 50 Xu"
	_bid_label.add_theme_font_size_override("font_size", 18)
	_bid_label.add_theme_color_override("font_color", Color("#f6c95c"))
	_bid_box.add_child(_bid_label)

	var plus_btn := Button.new()
	plus_btn.text = "+ 20"
	plus_btn.pressed.connect(func() -> void: _adjust_bid(20))
	_bid_box.add_child(plus_btn)

	var plus_100_btn := Button.new()
	plus_100_btn.text = "+ 100"
	plus_100_btn.pressed.connect(func() -> void: _adjust_bid(100))
	_bid_box.add_child(plus_100_btn)

	var plus_500_btn := Button.new()
	plus_500_btn.text = "+ 500"
	plus_500_btn.pressed.connect(func() -> void: _adjust_bid(500))
	_bid_box.add_child(plus_500_btn)

	_confirm_bid_btn = Button.new()
	_confirm_bid_btn.text = "✅ Xác Nhận Ra Giá"
	_confirm_bid_btn.custom_minimum_size = Vector2(160, 40)
	_confirm_bid_btn.pressed.connect(_on_confirm_bid_pressed)
	_bid_box.add_child(_confirm_bid_btn)

	# Solo Controls
	_solo_box = HBoxContainer.new()
	_solo_box.add_theme_constant_override("separation", 16)
	btm_hbox.add_child(_solo_box)

	_solo_buy_btn = Button.new()
	_solo_buy_btn.text = "🛒 Mua Hòm (0 Xu)"
	_solo_buy_btn.custom_minimum_size = Vector2(180, 40)
	_solo_buy_btn.pressed.connect(func() -> void: _on_solo_decide(true))
	_solo_box.add_child(_solo_buy_btn)

	_solo_pass_btn = Button.new()
	_solo_pass_btn.text = "❌ Bỏ Qua (Không Mua)"
	_solo_pass_btn.custom_minimum_size = Vector2(180, 40)
	_solo_pass_btn.pressed.connect(func() -> void: _on_solo_decide(false))
	_solo_box.add_child(_solo_pass_btn)

	_next_round_btn = Button.new()
	_next_round_btn.text = "⏭️ Vòng Tiếp Theo"
	_next_round_btn.custom_minimum_size = Vector2(160, 40)
	_next_round_btn.pressed.connect(_on_next_round_pressed)
	btm_hbox.add_child(_next_round_btn)

	_build_settlement_dialog()


func _build_settlement_dialog() -> void:
	_settlement_overlay = ColorRect.new()
	_settlement_overlay.set_anchors_preset(PRESET_FULL_RECT)
	_settlement_overlay.color = Color(0, 0, 0, 0.85)
	_settlement_overlay.visible = false
	add_child(_settlement_overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	_settlement_overlay.add_child(center)

	_settlement_panel = PanelContainer.new()
	_settlement_panel.custom_minimum_size = Vector2(660, 460)
	var s_style := StyleBoxFlat.new()
	s_style.bg_color = Color(0.08, 0.12, 0.18, 0.98)
	s_style.border_color = Color("#f6c95c")
	s_style.border_width_left = 3
	s_style.border_width_top = 3
	s_style.border_width_right = 3
	s_style.border_width_bottom = 3
	s_style.corner_radius_top_left = 12
	s_style.corner_radius_top_right = 12
	s_style.corner_radius_bottom_left = 12
	s_style.corner_radius_bottom_right = 12
	_settlement_panel.add_theme_stylebox_override("panel", s_style)
	center.add_child(_settlement_panel)

	_settlement_content = VBoxContainer.new()
	_settlement_content.add_theme_constant_override("separation", 16)
	_settlement_panel.add_child(_settlement_content)


func _generate_grid_placements() -> void:
	_grid_placements.clear()
	var occupancy: Array[Array] = []
	for y in range(GRID_ROWS):
		var row: Array = []
		for x in range(GRID_COLS):
			row.append(false)
		occupancy.append(row)

	if auction_session == null or auction_session.mystery_chest == null:
		return

	for item: ITEM_CLASS in auction_session.mystery_chest.items:
		var w: int = mini(GRID_COLS, maxi(1, item.grid_width))
		var h: int = mini(GRID_ROWS, maxi(1, item.grid_height))
		var placed := false

		# Find first available spot
		for y in range(GRID_ROWS - h + 1):
			if placed: break
			for x in range(GRID_COLS - w + 1):
				var can_fit := true
				for dy in range(h):
					for dx in range(w):
						if occupancy[y + dy][x + dx]:
							can_fit = false
							break
					if not can_fit: break
				if can_fit:
					for dy in range(h):
						for dx in range(w):
							occupancy[y + dy][x + dx] = true
					_grid_placements[String(item.item_id)] = {
						"pos": Vector2i(x, y),
						"w": w,
						"h": h,
						"item": item
					}
					placed = true
					break


func _sync_reveals_from_hints() -> void:
	_revealed_items.clear()
	_revealed_outlines.clear()
	_revealed_qualities.clear()

	if auction_session == null:
		return

	for hint: Variant in auction_session.hints_history:
		if not (hint is Dictionary):
			continue

		# 1. Vật phẩm lộ diện hoàn toàn (tên, sprite, giá trị)
		var items_rev: Variant = hint.get("revealed_item_ids", [])
		if not (items_rev is Array) or items_rev.is_empty():
			items_rev = hint.get("revealed_items", [])
		if items_rev is Array:
			for entry: Variant in items_rev:
				if entry is Dictionary:
					var i_id: String = String(entry.get("item_id", ""))
					if not i_id.is_empty():
						_revealed_items[i_id] = true
				elif entry != null:
					var i_id: String = String(entry)
					if not i_id.is_empty():
						_revealed_items[i_id] = true

		# 2. Lộ viền kích thước
		var outlines_rev: Variant = hint.get("revealed_outlines", [])
		if outlines_rev is Array:
			for out: Variant in outlines_rev:
				if out is Dictionary:
					var i_id: String = String(out.get("item_id", ""))
					if not i_id.is_empty():
						_revealed_outlines[i_id] = true
				elif out != null:
					var i_id: String = String(out)
					if not i_id.is_empty():
						_revealed_outlines[i_id] = true

		# 3. Lộ phẩm cấp màu sắc 1x1
		var quals_rev: Variant = hint.get("revealed_qualities", [])
		if quals_rev is Array:
			for q: Variant in quals_rev:
				if q is Dictionary:
					var i_id: String = String(q.get("item_id", ""))
					if not i_id.is_empty():
						_revealed_qualities[i_id] = true
				elif q is int:
					# Nếu là mảng int rarity, tìm món chưa lộ có phẩm cấp tương ứng
					if auction_session.mystery_chest != null:
						for it in auction_session.mystery_chest.items:
							var it_id := String(it.item_id)
							if int(it.rarity) == q and not _revealed_qualities.has(it_id) and not _revealed_items.has(it_id):
								_revealed_qualities[it_id] = true
								break
				elif q != null:
					var i_id: String = String(q)
					if not i_id.is_empty():
						_revealed_qualities[i_id] = true


func refresh_ui() -> void:
	if auction_session == null:
		return

	_round_label.text = "VÒNG %d / %d" % [auction_session.current_round, AUCTION_SESSION_CLASS.MAX_ROUNDS]

	_render_bidders()
	_render_clues()
	_grid_draw_control.queue_redraw()

	var est_val: int = _calculate_minimum_estimated_value()
	_min_value_label.text = "Giá ước tính thấp nhất hiện tại: %s Xu Bạc" % _format_number(est_val)

	if auction_session.is_solo():
		_bid_box.visible = false
		_solo_box.visible = true
		_solo_buy_btn.text = "🛒 Mua Hòm (%s Xu)" % _format_number(auction_session.solo_offer_price)
		_next_round_btn.visible = false
	else:
		_bid_box.visible = true
		_solo_box.visible = false
		_bid_label.text = "Đã ra giá: %s Xu" % _format_number(_current_bid_value)
		_next_round_btn.visible = (auction_session.current_round < AUCTION_SESSION_CLASS.MAX_ROUNDS)


func _render_bidders() -> void:
	for child in _bidders_container.get_children():
		child.queue_free()

	for i in range(auction_session.eligible_player_ids.size()):
		var pid: StringName = auction_session.eligible_player_ids[i]
		var card := PanelContainer.new()
		var card_style := StyleBoxFlat.new()
		card_style.bg_color = Color(0.12, 0.16, 0.22, 0.8)
		card_style.border_color = Color(0.3, 0.45, 0.6, 0.5)
		card_style.border_width_left = 1
		card_style.border_width_top = 1
		card_style.border_width_right = 1
		card_style.border_width_bottom = 1
		card_style.corner_radius_top_left = 6
		card_style.corner_radius_top_right = 6
		card_style.corner_radius_bottom_left = 6
		card_style.corner_radius_bottom_right = 6
		card.add_theme_stylebox_override("panel", card_style)
		_bidders_container.add_child(card)

		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		card.add_child(hbox)

		var vbox := VBoxContainer.new()
		var title_lbl := Label.new()
		title_lbl.text = "%d Nhà Sưu Tầm Đỉnh" % (i + 1)
		title_lbl.add_theme_font_size_override("font_size", 12)
		title_lbl.add_theme_color_override("font_color", Color("#50fa7b"))
		vbox.add_child(title_lbl)

		var name_lbl := Label.new()
		name_lbl.text = String(pid)
		name_lbl.add_theme_font_size_override("font_size", 14)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		vbox.add_child(name_lbl)
		hbox.add_child(vbox)

		# 5 rounds dots
		var dots_hbox := HBoxContainer.new()
		dots_hbox.add_theme_constant_override("separation", 4)
		for r in range(1, 6):
			var dot := ColorRect.new()
			dot.custom_minimum_size = Vector2(8, 8)
			if r < auction_session.current_round:
				dot.color = Color("#50fa7b")
			elif r == auction_session.current_round:
				dot.color = Color("#f1fa8c")
			else:
				dot.color = Color(0.3, 0.35, 0.4)
			dots_hbox.add_child(dot)
		hbox.add_child(dots_hbox)

		var b_val: int = int(auction_session.round_bids.get(pid, 0))
		var bid_lbl := Label.new()
		bid_lbl.text = "💰 %s" % _format_number(b_val) if b_val > 0 else "Chưa ra giá"
		bid_lbl.add_theme_font_size_override("font_size", 13)
		bid_lbl.add_theme_color_override("font_color", Color("#f6c95c") if b_val > 0 else Color("#888888"))
		hbox.add_child(bid_lbl)


func _render_clues() -> void:
	for child in _clues_feed.get_children():
		child.queue_free()

	for hint in auction_session.hints_history:
		var card := PanelContainer.new()
		var cl_style := StyleBoxFlat.new()
		cl_style.bg_color = Color(0.08, 0.12, 0.18, 0.9)
		cl_style.border_color = Color(0.3, 0.5, 0.65, 0.7)
		cl_style.border_width_left = 1
		cl_style.border_width_top = 1
		cl_style.border_width_right = 1
		cl_style.border_width_bottom = 1
		cl_style.corner_radius_top_left = 6
		cl_style.corner_radius_top_right = 6
		cl_style.corner_radius_bottom_left = 6
		cl_style.corner_radius_bottom_right = 6
		card.add_theme_stylebox_override("panel", cl_style)
		_clues_feed.add_child(card)

		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 12)
		card.add_child(hbox)

		var icon_lbl := Label.new()
		icon_lbl.text = "🔍"
		icon_lbl.add_theme_font_size_override("font_size", 22)
		hbox.add_child(icon_lbl)

		var vbox := VBoxContainer.new()
		vbox.size_flags_horizontal = SIZE_EXPAND_FILL
		hbox.add_child(vbox)

		var t_lbl := Label.new()
		t_lbl.text = String(hint.get("title", "Manh Mối"))
		t_lbl.add_theme_font_size_override("font_size", 14)
		t_lbl.add_theme_color_override("font_color", Color("#8be9fd"))
		vbox.add_child(t_lbl)

		var d_lbl := Label.new()
		d_lbl.text = String(hint.get("description", ""))
		d_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		d_lbl.add_theme_font_size_override("font_size", 13)
		d_lbl.add_theme_color_override("font_color", Color("#e0e0e0"))
		vbox.add_child(d_lbl)


func _on_grid_draw() -> void:
	# 1. Subtle 1x1 grid lines
	var line_color := Color(0.2, 0.3, 0.4, 0.35)
	for x in range(GRID_COLS + 1):
		_grid_draw_control.draw_line(Vector2(x * CELL_SIZE, 0), Vector2(x * CELL_SIZE, GRID_ROWS * CELL_SIZE), line_color, 1.0)
	for y in range(GRID_ROWS + 1):
		_grid_draw_control.draw_line(Vector2(0, y * CELL_SIZE), Vector2(GRID_COLS * CELL_SIZE, y * CELL_SIZE), line_color, 1.0)

	# 2. Draw placed items
	var is_finished: bool = (auction_session != null and auction_session.state == AUCTION_SESSION_CLASS.State.COMPLETED)
	for i_id in _grid_placements:
		var entry: Dictionary = _grid_placements[i_id]
		var item: ITEM_CLASS = entry.get("item") as ITEM_CLASS
		var pos: Vector2i = entry.get("pos") as Vector2i
		var w: int = int(entry.get("w", 1))
		var h: int = int(entry.get("h", 1))

		var rect := Rect2(pos.x * CELL_SIZE, pos.y * CELL_SIZE, w * CELL_SIZE, h * CELL_SIZE)
		var r_color: Color = ITEM_CLASS.rarity_color(item.rarity)

		var is_full_reveal: bool = is_finished or _revealed_items.has(i_id)
		var is_quality_reveal: bool = _revealed_qualities.has(i_id)
		var is_outline_reveal: bool = _revealed_outlines.has(i_id)

		if is_full_reveal:
			_grid_draw_control.draw_rect(rect, Color(r_color.r, r_color.g, r_color.b, 0.25), true)
			_grid_draw_control.draw_rect(rect, r_color, false, 2.5)

			var font := ThemeDB.fallback_font
			var t_pos := Vector2(pos.x * CELL_SIZE + 4, pos.y * CELL_SIZE + 13)
			_grid_draw_control.draw_string(font, t_pos, item.display_name, HORIZONTAL_ALIGNMENT_LEFT, w * CELL_SIZE - 8, 10, Color.WHITE)

			var v_text := "%s Xu" % _format_number(item.silver_value)
			if item.reward_type == "black_ticket":
				v_text = "Vé đen 🎟️"
			elif item.is_resource and item.silver_value == 0:
				v_text = "Tài nguyên 💾"
			var v_pos := Vector2(pos.x * CELL_SIZE + 4, (pos.y + h) * CELL_SIZE - 5)
			_grid_draw_control.draw_string(font, v_pos, v_text, HORIZONTAL_ALIGNMENT_LEFT, w * CELL_SIZE - 8, 9, r_color)
		elif is_quality_reveal:
			var q_rect := Rect2(pos.x * CELL_SIZE + 2, pos.y * CELL_SIZE + 2, CELL_SIZE - 4, CELL_SIZE - 4)
			_grid_draw_control.draw_rect(q_rect, Color(r_color.r, r_color.g, r_color.b, 0.7), true)
			_grid_draw_control.draw_rect(q_rect, r_color, false, 2.0)
		elif is_outline_reveal:
			_grid_draw_control.draw_rect(rect, Color(1, 1, 1, 0.08), true)
			_grid_draw_control.draw_rect(rect, Color("#4deeea"), false, 2.0)


func _calculate_minimum_estimated_value() -> int:
	if auction_session == null or auction_session.mystery_chest == null:
		return 0
	var total := 0
	for item in auction_session.mystery_chest.items:
		var i_id := String(item.item_id)
		if _revealed_items.has(i_id):
			total += item.silver_value
		elif _revealed_qualities.has(i_id):
			match item.rarity:
				ITEM_CLASS.Rarity.WHITE: total += 1
				ITEM_CLASS.Rarity.GREEN: total += 15
				ITEM_CLASS.Rarity.BLUE: total += 20
				ITEM_CLASS.Rarity.PURPLE: total += 30
				ITEM_CLASS.Rarity.GOLD: total += 65
				ITEM_CLASS.Rarity.RED: total += 188
	return total


func _adjust_bid(delta: int) -> void:
	_current_bid_value = maxi(1, _current_bid_value + delta)
	_bid_label.text = "Đã ra giá: %s Xu" % _format_number(_current_bid_value)


func _on_confirm_bid_pressed() -> void:
	if auction_session == null or auction_session.state != AUCTION_SESSION_CLASS.State.AUCTION_ACTIVE:
		return
	if not auction_session.active_bidder_ids.is_empty():
		var curr_pid: StringName = auction_session.active_bidder_ids[0]
		auction_session.place_bid(curr_pid, _current_bid_value)
		for i in range(1, auction_session.active_bidder_ids.size()):
			var ai_pid: StringName = auction_session.active_bidder_ids[i]
			var ai_bid: int = _current_bid_value + randi_range(-10, 50)
			auction_session.place_bid(ai_pid, maxi(1, ai_bid))
	refresh_ui()


func _on_next_round_pressed() -> void:
	if auction_session == null:
		return
	auction_session.advance_round()
	_sync_reveals_from_hints()
	if auction_session.state == AUCTION_SESSION_CLASS.State.COMPLETED:
		_show_settlement_dialog()
	else:
		refresh_ui()


func _on_solo_decide(buy: bool) -> void:
	if auction_session == null:
		return
	var pid: StringName = auction_session.eligible_player_ids[0] if not auction_session.eligible_player_ids.is_empty() else &""
	if buy:
		var bal: int = int(player_silver_balances.get(pid, 999999))
		auction_session.accept_solo_offer(pid, bal)
	else:
		auction_session.decline_solo_offer(pid)
	_show_settlement_dialog()


func _show_settlement_dialog() -> void:
	for child in _settlement_content.get_children():
		child.queue_free()

	var title := Label.new()
	title.text = "🏆 TỔNG KẾT ĐẤU GIÁ HÒM BÍ ẨN"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("#f6c95c"))
	_settlement_content.add_child(title)

	var winner_text := ""
	if not auction_session.winner_player_id.is_empty():
		winner_text = "🎉 Người chiến thắng: [b]%s[/b] (Giá mua: %s Xu Bạc)" % [
			auction_session.winner_player_id,
			_format_number(auction_session.final_price_paid)
		]
	else:
		winner_text = "Không có ai mua hoặc trúng đấu giá hòm bí ẩn lần này."

	var win_lbl := RichTextLabel.new()
	win_lbl.bbcode_enabled = true
	win_lbl.text = winner_text
	win_lbl.fit_content = true
	win_lbl.add_theme_font_size_override("normal_font_size", 16)
	_settlement_content.add_child(win_lbl)

	if not auction_session.winner_player_id.is_empty():
		var conv_lbl := RichTextLabel.new()
		conv_lbl.bbcode_enabled = true
		conv_lbl.text = "💰 [color=#50fa7b]Quy đổi vật phẩm Thường ➔ Hoàng Kim:[/color] +%s Xu Bạc" % _format_number(auction_session.converted_silver_received)
		conv_lbl.fit_content = true
		conv_lbl.add_theme_font_size_override("normal_font_size", 16)
		_settlement_content.add_child(conv_lbl)

		if not auction_session.retained_red_items.is_empty():
			var red_box := PanelContainer.new()
			var r_st := StyleBoxFlat.new()
			r_st.bg_color = Color(0.25, 0.05, 0.05, 0.9)
			r_st.border_color = Color("#ff5555")
			r_st.border_width_left = 2
			r_st.border_width_top = 2
			r_st.border_width_right = 2
			r_st.border_width_bottom = 2
			r_st.corner_radius_top_left = 6
			r_st.corner_radius_top_right = 6
			r_st.corner_radius_bottom_left = 6
			r_st.corner_radius_bottom_right = 6
			red_box.add_theme_stylebox_override("panel", r_st)
			_settlement_content.add_child(red_box)

			var red_vbox := VBoxContainer.new()
			red_box.add_child(red_vbox)

			var red_title := Label.new()
			red_title.text = "🔥 BẢO VẬT PHÒNG THÍ NGHIỆM ĐƯỢC GIỮ LẠI:"
			red_title.add_theme_color_override("font_color", Color("#ff5555"))
			red_title.add_theme_font_size_override("font_size", 15)
			red_vbox.add_child(red_title)

			for red_item: ITEM_CLASS in auction_session.retained_red_items:
				var r_item_lbl := Label.new()
				r_item_lbl.text = "• %s (%dx%d) - %s" % [red_item.display_name, red_item.grid_width, red_item.grid_height, red_item.description]
				r_item_lbl.add_theme_color_override("font_color", Color.WHITE)
				r_item_lbl.add_theme_font_size_override("font_size", 13)
				red_vbox.add_child(r_item_lbl)

	var finish_btn := Button.new()
	finish_btn.text = "Tiến Vào Giai Đoạn Trang Bị ➔"
	finish_btn.custom_minimum_size = Vector2(220, 45)
	finish_btn.size_flags_horizontal = SIZE_SHRINK_CENTER
	finish_btn.pressed.connect(_on_finish_settlement_pressed)
	_settlement_content.add_child(finish_btn)

	_settlement_overlay.visible = true


func _on_finish_settlement_pressed() -> void:
	_settlement_overlay.visible = false
	visible = false
	auction_finished.emit(auction_session.settlement_summary())


func _format_number(val: int) -> String:
	var s := str(val)
	var res := ""
	var cnt := 0
	for i in range(s.length() - 1, -1, -1):
		res = s[i] + res
		cnt += 1
		if cnt % 3 == 0 and i > 0:
			res = "," + res
	return res
