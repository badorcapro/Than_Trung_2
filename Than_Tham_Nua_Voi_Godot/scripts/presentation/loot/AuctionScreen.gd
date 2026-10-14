class_name AuctionScreen
extends Control

signal auction_finished(settlement_data: Dictionary)

const AUCTION_SESSION_CLASS := preload("res://scripts/domain/loot/AuctionSession.gd")
const CHEST_STATE_CLASS := preload("res://scripts/domain/loot/MysteryChestState.gd")
const ITEM_CLASS := preload("res://scripts/domain/loot/MysteryChestItem.gd")
const ENCYCLOPEDIA_DIALOG_CLASS := preload("res://scripts/presentation/loot/AuctionEncyclopediaDialog.gd")

const CELL_SIZE: int = 46
const SETTLEMENT_CELL_SIZE: int = 54
const GRID_COLS: int = 10
const GRID_ROWS: int = 8

var auction_session: AuctionSession
var player_silver_balances: Dictionary = {} # player_id -> int
var encyclopedia_dialog: AuctionEncyclopediaDialog = null

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
var _turn_info_label: Label
var _bid_feedback_lbl: Label
var _bid_input: LineEdit
var _confirm_bid_btn: Button
var _pass_btn: Button
var _fold_btn: Button
var _next_round_btn: Button
var _solo_box: HBoxContainer
var _solo_buy_btn: Button
var _solo_pass_btn: Button

# Turn State for Multi-player Bidding
var _current_turn_bidder_index: int = 0
var _round_completed: bool = false
var _current_bid_value: int = 10

# Settlement UI Nodes (BidKing End-Match Style)
var _settlement_overlay: ColorRect
var _settlement_winner_role_lbl: Label
var _settlement_winner_name_lbl: Label
var _settlement_final_cost_lbl: Label
var _settlement_loot_val_lbl: Label
var _settlement_profit_lbl: Label
var _settlement_extra_info_lbl: RichTextLabel
var _settlement_continue_btn: Button
var _settlement_skip_btn: Button
var _settlement_grid_draw_control: Control

# Settlement Reveal Animation State
var _is_settlement_revealing: bool = false
var _settlement_skip_requested: bool = false
var _active_loading_item_id: String = ""
var _settlement_revealed_item_ids: Dictionary = {} # item_id -> bool
var _settlement_accumulated_value: int = 0
var _settlement_spinner_angle: float = 0.0
var _continue_pulse_time: float = 0.0


func _init() -> void:
	name = "AuctionScreen"
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_STOP
	_build_ui()


func setup(session: AuctionSession, player_silvers: Dictionary = {}) -> void:
	auction_session = session
	player_silver_balances = player_silvers.duplicate()
	_current_turn_bidder_index = 0
	_round_completed = false
	_generate_grid_placements()
	_sync_reveals_from_hints()
	_setup_initial_bid_for_current_player()
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
	enc_btn.focus_mode = FOCUS_NONE
	enc_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	enc_btn.tooltip_text = "Tra cứu Bách Khoa Toàn Thư / Xem danh mục đồ đấu giá (Phím B)"
	enc_btn.add_theme_color_override("font_color", Color("#8be9fd"))
	enc_btn.pressed.connect(func() -> void:
		if encyclopedia_dialog != null:
			encyclopedia_dialog.open_dialog()
	)
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
	_bottom_bar.custom_minimum_size = Vector2(0, 80)
	var btm_style := StyleBoxFlat.new()
	btm_style.bg_color = Color(0.08, 0.13, 0.19, 0.96)
	btm_style.border_color = Color(0.3, 0.5, 0.7, 0.7)
	btm_style.border_width_top = 2
	btm_style.corner_radius_top_left = 8
	btm_style.corner_radius_top_right = 8
	_bottom_bar.add_theme_stylebox_override("panel", btm_style)
	main_vbox.add_child(_bottom_bar)

	var btm_vbox := VBoxContainer.new()
	btm_vbox.add_theme_constant_override("separation", 6)
	_bottom_bar.add_child(btm_vbox)

	# Row 1: Turn & Feedback info banner
	var status_margin := MarginContainer.new()
	status_margin.add_theme_constant_override("margin_left", 14)
	status_margin.add_theme_constant_override("margin_right", 14)
	status_margin.add_theme_constant_override("margin_top", 4)
	btm_vbox.add_child(status_margin)

	var status_hbox := HBoxContainer.new()
	status_hbox.add_theme_constant_override("separation", 16)
	status_margin.add_child(status_hbox)

	_turn_info_label = Label.new()
	_turn_info_label.text = "🎯 LƯỢT ĐẤU GIÁ"
	_turn_info_label.add_theme_font_size_override("font_size", 14)
	_turn_info_label.add_theme_color_override("font_color", Color("#f1fa8c"))
	status_hbox.add_child(_turn_info_label)

	var sp_status := Control.new()
	sp_status.size_flags_horizontal = SIZE_EXPAND_FILL
	status_hbox.add_child(sp_status)

	_bid_feedback_lbl = Label.new()
	_bid_feedback_lbl.text = ""
	_bid_feedback_lbl.add_theme_font_size_override("font_size", 13)
	_bid_feedback_lbl.add_theme_color_override("font_color", Color("#50fa7b"))
	status_hbox.add_child(_bid_feedback_lbl)

	# Row 2: Controls (Bidding LineEdit + delta buttons + confirm/pass/fold, or Solo)
	var ctrl_margin := MarginContainer.new()
	ctrl_margin.add_theme_constant_override("margin_left", 14)
	ctrl_margin.add_theme_constant_override("margin_right", 14)
	ctrl_margin.add_theme_constant_override("margin_bottom", 6)
	btm_vbox.add_child(ctrl_margin)

	var btm_hbox := HBoxContainer.new()
	btm_hbox.add_theme_constant_override("separation", 12)
	btm_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	ctrl_margin.add_child(btm_hbox)

	_timer_label = Label.new()
	_timer_label.text = "⏱️ 30s"
	_timer_label.add_theme_font_size_override("font_size", 18)
	_timer_label.add_theme_color_override("font_color", Color("#ff5555"))
	btm_hbox.add_child(_timer_label)

	# Multi-player Bidding Controls
	_bid_box = HBoxContainer.new()
	_bid_box.add_theme_constant_override("separation", 8)
	btm_hbox.add_child(_bid_box)

	var minus_btn := Button.new()
	minus_btn.text = "- 20"
	minus_btn.custom_minimum_size = Vector2(48, 34)
	minus_btn.focus_mode = FOCUS_NONE
	minus_btn.pressed.connect(func() -> void: _adjust_bid(-20))
	_bid_box.add_child(minus_btn)

	_bid_input = LineEdit.new()
	_bid_input.placeholder_text = "Nhập Xu..."
	_bid_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bid_input.custom_minimum_size = Vector2(110, 34)
	_bid_input.add_theme_font_size_override("font_size", 15)
	_bid_input.add_theme_color_override("font_color", Color("#f6c95c"))
	_bid_input.text_changed.connect(_on_bid_input_changed)
	_bid_input.text_submitted.connect(func(_t: String) -> void: _on_confirm_bid_pressed())
	_bid_box.add_child(_bid_input)

	var plus_btn := Button.new()
	plus_btn.text = "+ 20"
	plus_btn.custom_minimum_size = Vector2(48, 34)
	plus_btn.focus_mode = FOCUS_NONE
	plus_btn.pressed.connect(func() -> void: _adjust_bid(20))
	_bid_box.add_child(plus_btn)

	var plus_100_btn := Button.new()
	plus_100_btn.text = "+ 100"
	plus_100_btn.custom_minimum_size = Vector2(56, 34)
	plus_100_btn.focus_mode = FOCUS_NONE
	plus_100_btn.pressed.connect(func() -> void: _adjust_bid(100))
	_bid_box.add_child(plus_100_btn)

	var plus_500_btn := Button.new()
	plus_500_btn.text = "+ 500"
	plus_500_btn.custom_minimum_size = Vector2(56, 34)
	plus_500_btn.focus_mode = FOCUS_NONE
	plus_500_btn.pressed.connect(func() -> void: _adjust_bid(500))
	_bid_box.add_child(plus_500_btn)

	_confirm_bid_btn = Button.new()
	_confirm_bid_btn.text = "✅ Xác Nhận Ra Giá"
	_confirm_bid_btn.custom_minimum_size = Vector2(150, 36)
	_confirm_bid_btn.focus_mode = FOCUS_NONE
	_confirm_bid_btn.pressed.connect(_on_confirm_bid_pressed)
	_bid_box.add_child(_confirm_bid_btn)

	_pass_btn = Button.new()
	_pass_btn.text = "⏭️ Bỏ Qua Lượt"
	_pass_btn.tooltip_text = "Không nâng giá ở lượt này, giữ nguyên giá hiện tại"
	_pass_btn.custom_minimum_size = Vector2(120, 36)
	_pass_btn.focus_mode = FOCUS_NONE
	_pass_btn.pressed.connect(_on_pass_bid_pressed)
	_bid_box.add_child(_pass_btn)

	_fold_btn = Button.new()
	_fold_btn.text = "🏳️ Bỏ Cuộc"
	_fold_btn.tooltip_text = "Rút lui hoàn toàn khỏi phiên đấu giá hòm này"
	_fold_btn.custom_minimum_size = Vector2(95, 36)
	_fold_btn.focus_mode = FOCUS_NONE
	_fold_btn.pressed.connect(_on_fold_bid_pressed)
	_bid_box.add_child(_fold_btn)

	# Solo Controls
	_solo_box = HBoxContainer.new()
	_solo_box.add_theme_constant_override("separation", 16)
	btm_hbox.add_child(_solo_box)

	_solo_buy_btn = Button.new()
	_solo_buy_btn.text = "🛒 Mua Hòm (0 Xu)"
	_solo_buy_btn.custom_minimum_size = Vector2(180, 36)
	_solo_buy_btn.focus_mode = FOCUS_NONE
	_solo_buy_btn.pressed.connect(func() -> void: _on_solo_decide(true))
	_solo_box.add_child(_solo_buy_btn)

	_solo_pass_btn = Button.new()
	_solo_pass_btn.text = "❌ Bỏ Qua (Không Mua)"
	_solo_pass_btn.custom_minimum_size = Vector2(180, 36)
	_solo_pass_btn.focus_mode = FOCUS_NONE
	_solo_pass_btn.pressed.connect(func() -> void: _on_solo_decide(false))
	_solo_box.add_child(_solo_pass_btn)

	_next_round_btn = Button.new()
	_next_round_btn.text = "⏭️ Vòng Tiếp Theo"
	_next_round_btn.custom_minimum_size = Vector2(160, 36)
	_next_round_btn.focus_mode = FOCUS_NONE
	_next_round_btn.pressed.connect(_on_next_round_pressed)
	btm_hbox.add_child(_next_round_btn)

	_build_settlement_dialog()

	encyclopedia_dialog = ENCYCLOPEDIA_DIALOG_CLASS.new()
	encyclopedia_dialog.visible = false
	add_child(encyclopedia_dialog)


func _build_settlement_dialog() -> void:
	_settlement_overlay = ColorRect.new()
	_settlement_overlay.set_anchors_preset(PRESET_FULL_RECT)
	_settlement_overlay.color = Color(0.04, 0.06, 0.09, 0.96)
	_settlement_overlay.visible = false
	_settlement_overlay.mouse_filter = MOUSE_FILTER_STOP
	_settlement_overlay.gui_input.connect(_on_settlement_overlay_gui_input)
	add_child(_settlement_overlay)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_bottom", 24)
	margin.mouse_filter = MOUSE_FILTER_PASS
	_settlement_overlay.add_child(margin)

	var body_hbox := HBoxContainer.new()
	body_hbox.set_anchors_preset(PRESET_FULL_RECT)
	body_hbox.add_theme_constant_override("separation", 32)
	body_hbox.mouse_filter = MOUSE_FILTER_PASS
	margin.add_child(body_hbox)

	# --- LEFT COLUMN: MATCH END INFO & STATS (~400px) ---
	var left_vbox := VBoxContainer.new()
	left_vbox.custom_minimum_size = Vector2(400, 0)
	left_vbox.add_theme_constant_override("separation", 10)
	left_vbox.mouse_filter = MOUSE_FILTER_PASS
	body_hbox.add_child(left_vbox)

	var subtitle_lbl := Label.new()
	subtitle_lbl.text = "🏛️ HÒM BÍ ẨN HOÀNG CUNG"
	subtitle_lbl.add_theme_font_size_override("font_size", 14)
	subtitle_lbl.add_theme_color_override("font_color", Color("#8be9fd"))
	left_vbox.add_child(subtitle_lbl)

	var end_title_lbl := Label.new()
	end_title_lbl.text = "Kết thúc trận"
	end_title_lbl.add_theme_font_size_override("font_size", 38)
	end_title_lbl.add_theme_color_override("font_color", Color.WHITE)
	left_vbox.add_child(end_title_lbl)

	# Winner / Participant Card
	var user_card := PanelContainer.new()
	var uc_style := StyleBoxFlat.new()
	uc_style.bg_color = Color(0.1, 0.14, 0.2, 0.85)
	uc_style.border_color = Color(0.3, 0.45, 0.6, 0.6)
	uc_style.border_width_left = 1
	uc_style.border_width_top = 1
	uc_style.border_width_right = 1
	uc_style.border_width_bottom = 1
	uc_style.corner_radius_top_left = 8
	uc_style.corner_radius_top_right = 8
	uc_style.corner_radius_bottom_left = 8
	uc_style.corner_radius_bottom_right = 8
	user_card.add_theme_stylebox_override("panel", uc_style)
	user_card.mouse_filter = MOUSE_FILTER_PASS
	left_vbox.add_child(user_card)

	var uc_margin := MarginContainer.new()
	uc_margin.add_theme_constant_override("margin_left", 12)
	uc_margin.add_theme_constant_override("margin_top", 10)
	uc_margin.add_theme_constant_override("margin_right", 12)
	uc_margin.add_theme_constant_override("margin_bottom", 10)
	uc_margin.mouse_filter = MOUSE_FILTER_PASS
	user_card.add_child(uc_margin)

	var uc_hbox := HBoxContainer.new()
	uc_hbox.add_theme_constant_override("separation", 14)
	uc_hbox.mouse_filter = MOUSE_FILTER_PASS
	uc_margin.add_child(uc_hbox)

	var avatar_box := PanelContainer.new()
	avatar_box.custom_minimum_size = Vector2(50, 50)
	var av_style := StyleBoxFlat.new()
	av_style.bg_color = Color(0.15, 0.22, 0.32, 0.9)
	av_style.border_color = Color("#f6c95c")
	av_style.border_width_left = 2
	av_style.border_width_top = 2
	av_style.border_width_right = 2
	av_style.border_width_bottom = 2
	av_style.corner_radius_top_left = 25
	av_style.corner_radius_top_right = 25
	av_style.corner_radius_bottom_left = 25
	av_style.corner_radius_bottom_right = 25
	avatar_box.add_theme_stylebox_override("panel", av_style)
	var av_center := CenterContainer.new()
	avatar_box.add_child(av_center)
	var av_icon := Label.new()
	av_icon.text = "👑"
	av_icon.add_theme_font_size_override("font_size", 22)
	av_center.add_child(av_icon)
	uc_hbox.add_child(avatar_box)

	var uc_info_vbox := VBoxContainer.new()
	uc_info_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	uc_info_vbox.mouse_filter = MOUSE_FILTER_PASS
	uc_hbox.add_child(uc_info_vbox)

	_settlement_winner_role_lbl = Label.new()
	_settlement_winner_role_lbl.text = "Người chiến thắng"
	_settlement_winner_role_lbl.add_theme_font_size_override("font_size", 12)
	_settlement_winner_role_lbl.add_theme_color_override("font_color", Color("#94a3b8"))
	uc_info_vbox.add_child(_settlement_winner_role_lbl)

	_settlement_winner_name_lbl = Label.new()
	_settlement_winner_name_lbl.text = "Player"
	_settlement_winner_name_lbl.add_theme_font_size_override("font_size", 18)
	_settlement_winner_name_lbl.add_theme_color_override("font_color", Color.WHITE)
	uc_info_vbox.add_child(_settlement_winner_name_lbl)

	# Stats block
	var stats_vbox := VBoxContainer.new()
	stats_vbox.add_theme_constant_override("separation", 14)
	stats_vbox.mouse_filter = MOUSE_FILTER_PASS
	left_vbox.add_child(stats_vbox)

	# Stat 1: Giá đấu giá cuối cùng
	var s1_box := VBoxContainer.new()
	s1_box.add_theme_constant_override("separation", 2)
	stats_vbox.add_child(s1_box)
	var s1_title := Label.new()
	s1_title.text = "Giá đấu giá cuối cùng"
	s1_title.add_theme_font_size_override("font_size", 14)
	s1_title.add_theme_color_override("font_color", Color("#94a3b8"))
	s1_box.add_child(s1_title)
	_settlement_final_cost_lbl = Label.new()
	_settlement_final_cost_lbl.text = "0 Xu Bạc"
	_settlement_final_cost_lbl.add_theme_font_size_override("font_size", 28)
	_settlement_final_cost_lbl.add_theme_color_override("font_color", Color.WHITE)
	s1_box.add_child(_settlement_final_cost_lbl)

	# Stat 2: Giá chiến lợi phẩm
	var s2_box := VBoxContainer.new()
	s2_box.add_theme_constant_override("separation", 2)
	stats_vbox.add_child(s2_box)
	var s2_title := Label.new()
	s2_title.text = "Giá chiến lợi phẩm"
	s2_title.add_theme_font_size_override("font_size", 14)
	s2_title.add_theme_color_override("font_color", Color("#94a3b8"))
	s2_box.add_child(s2_title)
	_settlement_loot_val_lbl = Label.new()
	_settlement_loot_val_lbl.text = "0 Xu"
	_settlement_loot_val_lbl.add_theme_font_size_override("font_size", 30)
	_settlement_loot_val_lbl.add_theme_color_override("font_color", Color.WHITE)
	s2_box.add_child(_settlement_loot_val_lbl)

	# Stat 3: Lợi nhuận
	var s3_box := VBoxContainer.new()
	s3_box.add_theme_constant_override("separation", 2)
	stats_vbox.add_child(s3_box)
	var s3_title := Label.new()
	s3_title.text = "Lợi nhuận"
	s3_title.add_theme_font_size_override("font_size", 14)
	s3_title.add_theme_color_override("font_color", Color("#94a3b8"))
	s3_box.add_child(s3_title)
	_settlement_profit_lbl = Label.new()
	_settlement_profit_lbl.text = "0 Xu"
	_settlement_profit_lbl.add_theme_font_size_override("font_size", 30)
	_settlement_profit_lbl.add_theme_color_override("font_color", Color("#50fa7b"))
	s3_box.add_child(_settlement_profit_lbl)

	# Extra lines
	_settlement_extra_info_lbl = RichTextLabel.new()
	_settlement_extra_info_lbl.bbcode_enabled = true
	_settlement_extra_info_lbl.fit_content = true
	_settlement_extra_info_lbl.mouse_filter = MOUSE_FILTER_PASS
	_settlement_extra_info_lbl.add_theme_font_size_override("normal_font_size", 13)
	left_vbox.add_child(_settlement_extra_info_lbl)

	var sp_left := Control.new()
	sp_left.size_flags_vertical = SIZE_EXPAND_FILL
	sp_left.mouse_filter = MOUSE_FILTER_PASS
	left_vbox.add_child(sp_left)

	# Bottom Continue Box
	var btm_cont_vbox := VBoxContainer.new()
	btm_cont_vbox.add_theme_constant_override("separation", 4)
	btm_cont_vbox.mouse_filter = MOUSE_FILTER_PASS
	left_vbox.add_child(btm_cont_vbox)

	_settlement_continue_btn = Button.new()
	_settlement_continue_btn.text = "Nhấn vào đây để tiếp tục ➔"
	_settlement_continue_btn.custom_minimum_size = Vector2(0, 48)
	_settlement_continue_btn.add_theme_font_size_override("font_size", 17)
	_settlement_continue_btn.add_theme_color_override("font_color", Color("#f6c95c"))
	_settlement_continue_btn.pressed.connect(_on_finish_settlement_pressed)
	_settlement_continue_btn.visible = false
	btm_cont_vbox.add_child(_settlement_continue_btn)

	var hint_cont_lbl := Label.new()
	hint_cont_lbl.text = "(Nhấp chuột bất kỳ để hoàn tất)"
	hint_cont_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_cont_lbl.add_theme_font_size_override("font_size", 12)
	hint_cont_lbl.add_theme_color_override("font_color", Color("#64748b"))
	btm_cont_vbox.add_child(hint_cont_lbl)


	# --- RIGHT COLUMN: CHEST REVEAL GRID (~720px) ---
	var right_vbox := VBoxContainer.new()
	right_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	right_vbox.size_flags_vertical = SIZE_EXPAND_FILL
	right_vbox.add_theme_constant_override("separation", 10)
	right_vbox.mouse_filter = MOUSE_FILTER_PASS
	body_hbox.add_child(right_vbox)

	# Top Tab Bar
	var r_top_bar := HBoxContainer.new()
	r_top_bar.custom_minimum_size = Vector2(0, 36)
	r_top_bar.mouse_filter = MOUSE_FILTER_PASS
	right_vbox.add_child(r_top_bar)

	var tab_panel := PanelContainer.new()
	var tp_style := StyleBoxFlat.new()
	tp_style.bg_color = Color(0.13, 0.18, 0.25, 0.95)
	tp_style.border_color = Color("#4deeea")
	tp_style.border_width_bottom = 3
	tp_style.corner_radius_top_left = 6
	tp_style.corner_radius_top_right = 6
	tab_panel.add_theme_stylebox_override("panel", tp_style)
	r_top_bar.add_child(tab_panel)

	var tab_margin := MarginContainer.new()
	tab_margin.add_theme_constant_override("margin_left", 16)
	tab_margin.add_theme_constant_override("margin_right", 16)
	tab_margin.add_theme_constant_override("margin_top", 6)
	tab_margin.add_theme_constant_override("margin_bottom", 6)
	tab_panel.add_child(tab_margin)

	var tab_lbl := Label.new()
	tab_lbl.text = "🎁 Chiến Lợi Phẩm"
	tab_lbl.add_theme_font_size_override("font_size", 15)
	tab_lbl.add_theme_color_override("font_color", Color.WHITE)
	tab_margin.add_child(tab_lbl)

	var sp_rtab := Control.new()
	sp_rtab.size_flags_horizontal = SIZE_EXPAND_FILL
	sp_rtab.mouse_filter = MOUSE_FILTER_PASS
	r_top_bar.add_child(sp_rtab)

	_settlement_skip_btn = Button.new()
	_settlement_skip_btn.text = "⏩ Bỏ qua (Skip)"
	_settlement_skip_btn.custom_minimum_size = Vector2(120, 34)
	_settlement_skip_btn.add_theme_font_size_override("font_size", 13)
	_settlement_skip_btn.pressed.connect(_on_skip_pressed)
	r_top_bar.add_child(_settlement_skip_btn)

	# Grid Container Panel
	var s_grid_panel := PanelContainer.new()
	s_grid_panel.size_flags_horizontal = SIZE_EXPAND_FILL
	s_grid_panel.size_flags_vertical = SIZE_EXPAND_FILL
	var gp_style := StyleBoxFlat.new()
	gp_style.bg_color = Color(0.06, 0.09, 0.13, 0.98)
	gp_style.border_color = Color(0.25, 0.38, 0.52, 0.7)
	gp_style.border_width_left = 2
	gp_style.border_width_top = 2
	gp_style.border_width_right = 2
	gp_style.border_width_bottom = 2
	gp_style.corner_radius_top_left = 8
	gp_style.corner_radius_top_right = 8
	gp_style.corner_radius_bottom_left = 8
	gp_style.corner_radius_bottom_right = 8
	s_grid_panel.add_theme_stylebox_override("panel", gp_style)
	s_grid_panel.mouse_filter = MOUSE_FILTER_PASS
	right_vbox.add_child(s_grid_panel)

	var s_grid_center := CenterContainer.new()
	s_grid_center.set_anchors_preset(PRESET_FULL_RECT)
	s_grid_center.mouse_filter = MOUSE_FILTER_PASS
	s_grid_panel.add_child(s_grid_center)

	_settlement_grid_draw_control = Control.new()
	_settlement_grid_draw_control.custom_minimum_size = Vector2(
		GRID_COLS * SETTLEMENT_CELL_SIZE,
		GRID_ROWS * SETTLEMENT_CELL_SIZE
	)
	_settlement_grid_draw_control.mouse_filter = MOUSE_FILTER_PASS
	_settlement_grid_draw_control.draw.connect(_on_settlement_grid_draw)
	s_grid_center.add_child(_settlement_grid_draw_control)


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
		if _turn_info_label != null:
			_turn_info_label.text = "🛒 Ưu Đãi Mua Một Mình"
			_turn_info_label.add_theme_color_override("font_color", Color("#8be9fd"))
	else:
		_bid_box.visible = true
		_solo_box.visible = false

		var curr_pid := _get_current_turn_player_id()
		var bal: int = int(player_silver_balances.get(curr_pid, 0))

		if _round_completed:
			var lead_text := ""
			if not auction_session.highest_bidder_id.is_empty():
				lead_text = " | 👑 Đang dẫn đầu: %s (%s Xu)" % [
					String(auction_session.highest_bidder_id),
					_format_number(auction_session.highest_bid)
				]
			else:
				lead_text = " | Chưa ai ra giá"

			if _turn_info_label != null:
				_turn_info_label.text = "✅ Hoàn tất ra giá Vòng %d%s" % [auction_session.current_round, lead_text]
				_turn_info_label.add_theme_color_override("font_color", Color("#50fa7b"))
			if _confirm_bid_btn != null: _confirm_bid_btn.disabled = true
			if _pass_btn != null: _pass_btn.disabled = true
			if _fold_btn != null: _fold_btn.disabled = true
			if _bid_input != null: _bid_input.editable = false
			if _next_round_btn != null:
				_next_round_btn.visible = true
				_next_round_btn.disabled = false
				if auction_session.current_round >= AUCTION_SESSION_CLASS.MAX_ROUNDS:
					_next_round_btn.text = "🏆 Chốt Đấu Giá & Tổng Kết"
				else:
					_next_round_btn.text = "⏭️ Sang Vòng %d / %d" % [
						auction_session.current_round + 1,
						AUCTION_SESSION_CLASS.MAX_ROUNDS
					]
		else:
			if _confirm_bid_btn != null: _confirm_bid_btn.disabled = false
			if _pass_btn != null: _pass_btn.disabled = false
			if _fold_btn != null: _fold_btn.disabled = false
			if _bid_input != null: _bid_input.editable = true
			if _next_round_btn != null: _next_round_btn.visible = false

			var lead_status := ""
			if auction_session.highest_bid > 0:
				if auction_session.highest_bidder_id == curr_pid:
					lead_status = " (👑 Bạn đang dẫn đầu)"
				else:
					lead_status = " (👑 Dẫn đầu: %s - %s Xu)" % [
						String(auction_session.highest_bidder_id),
						_format_number(auction_session.highest_bid)
					]
			else:
				lead_status = " (Chưa có ai đặt giá)"

			if _turn_info_label != null:
				_turn_info_label.text = "🎯 LƯỢT: %s [🪙 %s Xu]%s" % [
					String(curr_pid),
					_format_number(bal),
					lead_status
				]
				_turn_info_label.add_theme_color_override("font_color", Color("#f1fa8c"))


func _render_bidders() -> void:
	for child in _bidders_container.get_children():
		child.queue_free()

	var curr_pid := _get_current_turn_player_id()

	for i in range(auction_session.eligible_player_ids.size()):
		var pid: StringName = auction_session.eligible_player_ids[i]
		var is_active: bool = auction_session.active_bidder_ids.has(pid)
		var is_current_turn: bool = (not _round_completed and pid == curr_pid)
		var is_leader: bool = (auction_session.highest_bidder_id == pid and auction_session.highest_bid > 0)

		var card := PanelContainer.new()
		var card_style := StyleBoxFlat.new()

		if is_current_turn:
			card_style.bg_color = Color(0.18, 0.28, 0.42, 0.98)
			card_style.border_color = Color("#50fa7b")
			card_style.border_width_left = 3
			card_style.border_width_top = 3
			card_style.border_width_right = 3
			card_style.border_width_bottom = 3
		elif is_leader:
			card_style.bg_color = Color(0.15, 0.20, 0.30, 0.9)
			card_style.border_color = Color("#f1fa8c")
			card_style.border_width_left = 2
			card_style.border_width_top = 2
			card_style.border_width_right = 2
			card_style.border_width_bottom = 2
		elif not is_active:
			card_style.bg_color = Color(0.08, 0.10, 0.12, 0.6)
			card_style.border_color = Color(0.25, 0.25, 0.3, 0.4)
			card_style.border_width_left = 1
			card_style.border_width_top = 1
			card_style.border_width_right = 1
			card_style.border_width_bottom = 1
		else:
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

		var s_bal: int = int(player_silver_balances.get(pid, 0))
		card.tooltip_text = "👤 Người chơi: %s\n🪙 Xu Bạc hiện có: %s Xu" % [String(pid), _format_number(s_bal)]
		card.mouse_filter = MOUSE_FILTER_STOP
		_bidders_container.add_child(card)

		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		card.add_child(hbox)

		# Left column of card: Title, Name, Balance
		var vbox := VBoxContainer.new()
		vbox.size_flags_horizontal = SIZE_EXPAND_FILL

		var title_hbox := HBoxContainer.new()
		var title_lbl := Label.new()
		title_lbl.text = "%d Nhà Sưu Tầm" % (i + 1)
		title_lbl.add_theme_font_size_override("font_size", 12)
		title_lbl.add_theme_color_override("font_color", Color("#8be9fd"))
		title_hbox.add_child(title_lbl)

		if is_current_turn:
			var turn_badge := Label.new()
			turn_badge.text = " ▶ LƯỢT ĐẤU"
			turn_badge.add_theme_font_size_override("font_size", 12)
			turn_badge.add_theme_color_override("font_color", Color("#50fa7b"))
			title_hbox.add_child(turn_badge)
		elif is_leader:
			var lead_badge := Label.new()
			lead_badge.text = " 👑 DẪN ĐẦU"
			lead_badge.add_theme_font_size_override("font_size", 12)
			lead_badge.add_theme_color_override("font_color", Color("#f1fa8c"))
			title_hbox.add_child(lead_badge)

		vbox.add_child(title_hbox)

		var name_lbl := Label.new()
		name_lbl.text = String(pid)
		name_lbl.add_theme_font_size_override("font_size", 14)
		name_lbl.add_theme_color_override("font_color", Color.WHITE if is_active else Color("#6272a4"))
		vbox.add_child(name_lbl)

		var bal_lbl := Label.new()
		bal_lbl.text = "🪙 %s Xu" % _format_number(s_bal)
		bal_lbl.add_theme_font_size_override("font_size", 11)
		bal_lbl.add_theme_color_override("font_color", Color("#f6c95c"))
		vbox.add_child(bal_lbl)

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

		# Right column of card: Current bid status
		var b_val: int = int(auction_session.round_bids.get(pid, 0))
		var bid_lbl := Label.new()
		if not is_active:
			bid_lbl.text = "Bỏ cuộc"
			bid_lbl.add_theme_color_override("font_color", Color("#6272a4"))
		elif b_val > 0:
			bid_lbl.text = "💰 %s" % _format_number(b_val)
			bid_lbl.add_theme_color_override("font_color", Color("#50fa7b"))
		elif is_leader:
			bid_lbl.text = "👑 %s" % _format_number(auction_session.highest_bid)
			bid_lbl.add_theme_color_override("font_color", Color("#f1fa8c"))
		else:
			bid_lbl.text = "Chưa ra giá"
			bid_lbl.add_theme_color_override("font_color", Color("#888888"))

		bid_lbl.add_theme_font_size_override("font_size", 13)
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
		var phase_tag: String = String(hint.get("phase", ""))
		if not phase_tag.is_empty():
			t_lbl.text = "[%s] %s" % [phase_tag, String(hint.get("title", "Manh Mối"))]
		else:
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


func _get_current_turn_player_id() -> StringName:
	if auction_session == null or auction_session.active_bidder_ids.is_empty():
		return &""
	if _current_turn_bidder_index < auction_session.active_bidder_ids.size():
		return auction_session.active_bidder_ids[_current_turn_bidder_index]
	return &""


func _setup_initial_bid_for_current_player() -> void:
	if auction_session == null:
		return
	var curr_pid := _get_current_turn_player_id()
	if curr_pid.is_empty():
		return

	if auction_session.highest_bid > 0:
		if auction_session.highest_bidder_id == curr_pid:
			_current_bid_value = auction_session.highest_bid
		else:
			_current_bid_value = auction_session.highest_bid + 5
	else:
		_current_bid_value = 10

	if _bid_input != null:
		_bid_input.text = str(_current_bid_value)


func _show_bid_feedback(msg: String) -> void:
	if _bid_feedback_lbl != null:
		_bid_feedback_lbl.text = msg
		if msg.begins_with("⚠️"):
			_bid_feedback_lbl.add_theme_color_override("font_color", Color("#ff5555"))
		elif msg.begins_with("✅"):
			_bid_feedback_lbl.add_theme_color_override("font_color", Color("#50fa7b"))
		elif msg.begins_with("⏭️") or msg.begins_with("🏳️"):
			_bid_feedback_lbl.add_theme_color_override("font_color", Color("#f1fa8c"))
		else:
			_bid_feedback_lbl.add_theme_color_override("font_color", Color("#8be9fd"))


func _on_bid_input_changed(new_text: String) -> void:
	var clean := ""
	for c in new_text:
		if c >= "0" and c <= "9":
			clean += c
	if clean != new_text:
		_bid_input.text = clean
		_bid_input.caret_column = clean.length()
	if not clean.is_empty():
		_current_bid_value = clean.to_int()


func _adjust_bid(delta: int) -> void:
	var curr_val: int = _current_bid_value
	if _bid_input != null and not _bid_input.text.is_empty():
		curr_val = _bid_input.text.to_int()
	curr_val = maxi(1, curr_val + delta)
	_current_bid_value = curr_val
	if _bid_input != null:
		_bid_input.text = str(_current_bid_value)


func _on_confirm_bid_pressed() -> void:
	if auction_session == null or auction_session.state != AUCTION_SESSION_CLASS.State.AUCTION_ACTIVE:
		return
	if _round_completed:
		_show_bid_feedback("⚠️ Vòng đấu này đã kết thúc lượt. Vui lòng bấm 'Vòng Tiếp Theo'!")
		return

	var curr_pid := _get_current_turn_player_id()
	if curr_pid.is_empty():
		return

	var bid_val: int = _bid_input.text.to_int() if _bid_input != null and not _bid_input.text.is_empty() else _current_bid_value
	if bid_val <= 0:
		_show_bid_feedback("⚠️ Số tiền ra giá phải lớn hơn 0 Xu!")
		return

	if auction_session.highest_bid > 0 and bid_val <= auction_session.highest_bid:
		_show_bid_feedback("⚠️ Phải đặt giá cao hơn giá dẫn đầu (%d Xu)!" % auction_session.highest_bid)
		return

	var bal: int = int(player_silver_balances.get(curr_pid, 999999))
	if bid_val > bal:
		_show_bid_feedback("⚠️ Không đủ Xu Bạc! %s chỉ có %s Xu." % [String(curr_pid), _format_number(bal)])
		return

	var ok: bool = auction_session.place_bid(curr_pid, bid_val)
	if not ok:
		_show_bid_feedback("⚠️ Không thể ra giá này!")
		return

	_show_bid_feedback("✅ %s đã ra giá %s Xu!" % [String(curr_pid), _format_number(bid_val)])
	_advance_to_next_bidder_turn()


func _on_pass_bid_pressed() -> void:
	if auction_session == null or auction_session.state != AUCTION_SESSION_CLASS.State.AUCTION_ACTIVE:
		return
	if _round_completed:
		return

	var curr_pid := _get_current_turn_player_id()
	if curr_pid.is_empty():
		return

	_show_bid_feedback("⏭️ %s đã bỏ qua lượt ra giá." % String(curr_pid))
	_advance_to_next_bidder_turn()


func _on_fold_bid_pressed() -> void:
	if auction_session == null or auction_session.state != AUCTION_SESSION_CLASS.State.AUCTION_ACTIVE:
		return
	if _round_completed:
		return

	var curr_pid := _get_current_turn_player_id()
	if curr_pid.is_empty():
		return

	_show_bid_feedback("🏳️ %s đã bỏ cuộc!" % String(curr_pid))
	auction_session.fold(curr_pid)

	if auction_session.state == AUCTION_SESSION_CLASS.State.COMPLETED:
		_show_settlement_dialog()
		return

	if _current_turn_bidder_index >= auction_session.active_bidder_ids.size():
		_round_completed = true
	else:
		_setup_initial_bid_for_current_player()
	refresh_ui()


func _advance_to_next_bidder_turn() -> void:
	_current_turn_bidder_index += 1
	if _current_turn_bidder_index >= auction_session.active_bidder_ids.size():
		_round_completed = true
	else:
		_setup_initial_bid_for_current_player()
	refresh_ui()


func _on_next_round_pressed() -> void:
	if auction_session == null:
		return
	auction_session.advance_round()
	_sync_reveals_from_hints()
	if auction_session.state == AUCTION_SESSION_CLASS.State.COMPLETED:
		_show_settlement_dialog()
	else:
		_current_turn_bidder_index = 0
		_round_completed = false
		_setup_initial_bid_for_current_player()
		_show_bid_feedback("📢 Bắt đầu Vòng %d! Manh mối mới đã mở." % auction_session.current_round)
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
	if auction_session == null:
		return

	_settlement_overlay.visible = true
	_is_settlement_revealing = true
	_settlement_skip_requested = false
	_settlement_revealed_item_ids.clear()
	_settlement_accumulated_value = 0
	_active_loading_item_id = ""

	_settlement_skip_btn.visible = true
	_settlement_continue_btn.visible = false

	_update_settlement_stats()
	if _settlement_grid_draw_control != null:
		_settlement_grid_draw_control.queue_redraw()

	_run_settlement_reveal()


func _run_settlement_reveal() -> void:
	if auction_session == null or auction_session.mystery_chest == null:
		_finish_settlement_reveal()
		return

	# Sort items by grid position (pos.y, pos.x)
	var item_keys: Array[String] = []
	for k in _grid_placements.keys():
		item_keys.append(String(k))
	item_keys.sort_custom(func(a: String, b: String) -> bool:
		var pa: Vector2i = _grid_placements[a].pos
		var pb: Vector2i = _grid_placements[b].pos
		if pa.y != pb.y:
			return pa.y < pb.y
		return pa.x < pb.x
	)

	for i_id in item_keys:
		if _settlement_skip_requested or not is_inside_tree() or not _settlement_overlay.visible:
			break

		var entry: Dictionary = _grid_placements[i_id]
		var item: ITEM_CLASS = entry.get("item") as ITEM_CLASS
		if item == null:
			continue

		_active_loading_item_id = i_id
		if _settlement_grid_draw_control != null:
			_settlement_grid_draw_control.queue_redraw()

		# Determine wait duration according to user specification (doubled for suspenseful reveal):
		var wait_time: float = 0.4
		if item.rarity == ITEM_CLASS.Rarity.GOLD or item.rarity == ITEM_CLASS.Rarity.RED:
			var val_ratio: float = clampf(float(item.silver_value) / 450.0, 0.0, 1.0)
			var prob_long: float = lerpf(0.35, 0.85, val_ratio)
			if randf() < prob_long:
				wait_time = randf_range(1.6, 4.0)
			else:
				wait_time = randf_range(0.3, 1.2)
		else:
			# "khoảng load nhẹ ở giữa ô đồ trước khi xuất hiện"
			wait_time = randf_range(0.25, 0.55)

		var start_ticks: int = Time.get_ticks_msec()
		var last_ticks: int = start_ticks
		var wait_msec: int = int(wait_time * 1000.0)
		while (Time.get_ticks_msec() - start_ticks) < wait_msec and not _settlement_skip_requested:
			if not is_inside_tree() or not _settlement_overlay.visible:
				break
			await get_tree().process_frame
			var now_ticks: int = Time.get_ticks_msec()
			var frame_delta: float = float(now_ticks - last_ticks) / 1000.0
			last_ticks = now_ticks
			_settlement_spinner_angle += frame_delta * 8.0
			if _settlement_grid_draw_control != null:
				_settlement_grid_draw_control.queue_redraw()

		if _settlement_skip_requested:
			break

		_settlement_revealed_item_ids[i_id] = true
		_settlement_accumulated_value += item.silver_value
		_active_loading_item_id = ""
		_update_settlement_stats()
		if _settlement_grid_draw_control != null:
			_settlement_grid_draw_control.queue_redraw()

	_finish_settlement_reveal()


func _finish_settlement_reveal() -> void:
	_is_settlement_revealing = false
	_active_loading_item_id = ""

	for i_id in _grid_placements.keys():
		var str_id := String(i_id)
		if not _settlement_revealed_item_ids.has(str_id):
			_settlement_revealed_item_ids[str_id] = true
			var it: ITEM_CLASS = _grid_placements[str_id].get("item") as ITEM_CLASS
			if it != null:
				_settlement_accumulated_value += it.silver_value

	_update_settlement_stats()
	if _settlement_grid_draw_control != null:
		_settlement_grid_draw_control.queue_redraw()

	if _settlement_skip_btn != null:
		_settlement_skip_btn.visible = false
	if _settlement_continue_btn != null:
		_settlement_continue_btn.visible = true


func _update_settlement_stats() -> void:
	if auction_session == null:
		return

	var is_bought: bool = not auction_session.winner_player_id.is_empty()
	var final_cost: int = auction_session.final_price_paid if is_bought else 0

	# 1. Winner / Participant
	if is_bought:
		_settlement_winner_role_lbl.text = "Người chiến thắng"
		_settlement_winner_name_lbl.text = String(auction_session.winner_player_id)
		_settlement_final_cost_lbl.text = "%s Xu Bạc" % _format_number(final_cost)
	else:
		_settlement_winner_role_lbl.text = "Kết quả hòm"
		_settlement_winner_name_lbl.text = "Không có người mua"
		_settlement_final_cost_lbl.text = "0 Xu (Bỏ qua)"

	# 2. Loot value accumulated
	_settlement_loot_val_lbl.text = "%s Xu" % _format_number(_settlement_accumulated_value)

	# 3. Profit
	if is_bought:
		var profit: int = _settlement_accumulated_value - final_cost
		if profit >= 0:
			_settlement_profit_lbl.text = "+%s Xu" % _format_number(profit)
			_settlement_profit_lbl.add_theme_color_override("font_color", Color("#50fa7b"))
		else:
			_settlement_profit_lbl.text = "-%s Xu" % _format_number(absi(profit))
			_settlement_profit_lbl.add_theme_color_override("font_color", Color("#ff5555"))
	else:
		_settlement_profit_lbl.text = "0 Xu (Đã bỏ qua)"
		_settlement_profit_lbl.add_theme_color_override("font_color", Color("#94a3b8"))

	# 4. Extra info
	var extra_lines: Array[String] = []
	if is_bought:
		if auction_session.converted_silver_received > 0:
			extra_lines.append("[color=#50fa7b]💰 Quy đổi Thường ➔ Vàng:[/color] +%s Xu" % _format_number(auction_session.converted_silver_received))
		if not auction_session.retained_red_items.is_empty():
			var names: Array[String] = []
			for r_it in auction_session.retained_red_items:
				names.append(r_it.display_name)
			extra_lines.append("[color=#ff5555]🔥 Bảo vật đỏ giữ lại:[/color] %s" % ", ".join(names))

	_settlement_extra_info_lbl.text = "\n".join(extra_lines)


func _on_settlement_grid_draw() -> void:
	if _settlement_grid_draw_control == null:
		return

	# 1. Subtle grid lines
	var line_color := Color(0.2, 0.28, 0.38, 0.35)
	for x in range(GRID_COLS + 1):
		_settlement_grid_draw_control.draw_line(
			Vector2(x * SETTLEMENT_CELL_SIZE, 0),
			Vector2(x * SETTLEMENT_CELL_SIZE, GRID_ROWS * SETTLEMENT_CELL_SIZE),
			line_color,
			1.0
		)
	for y in range(GRID_ROWS + 1):
		_settlement_grid_draw_control.draw_line(
			Vector2(0, y * SETTLEMENT_CELL_SIZE),
			Vector2(GRID_COLS * SETTLEMENT_CELL_SIZE, y * SETTLEMENT_CELL_SIZE),
			line_color,
			1.0
		)

	# 2. Draw placed items
	var font := ThemeDB.fallback_font
	for i_id in _grid_placements:
		var entry: Dictionary = _grid_placements[i_id]
		var item: ITEM_CLASS = entry.get("item") as ITEM_CLASS
		var pos: Vector2i = entry.get("pos") as Vector2i
		var w: int = int(entry.get("w", 1))
		var h: int = int(entry.get("h", 1))

		var rect := Rect2(
			pos.x * SETTLEMENT_CELL_SIZE + 1,
			pos.y * SETTLEMENT_CELL_SIZE + 1,
			w * SETTLEMENT_CELL_SIZE - 2,
			h * SETTLEMENT_CELL_SIZE - 2
		)

		var is_revealed: bool = _settlement_revealed_item_ids.has(String(i_id))
		var is_loading: bool = (_active_loading_item_id == String(i_id))

		if is_revealed:
			var r_color: Color = ITEM_CLASS.rarity_color(item.rarity)
			var fill_color := Color(r_color.r, r_color.g, r_color.b, 0.35)
			_settlement_grid_draw_control.draw_rect(rect, fill_color, true)
			var b_width: float = 3.0 if (item.rarity == ITEM_CLASS.Rarity.RED or item.rarity == ITEM_CLASS.Rarity.GOLD) else 2.0
			_settlement_grid_draw_control.draw_rect(rect, r_color, false, b_width)

			if item.rarity == ITEM_CLASS.Rarity.RED:
				var inner_rect := rect.grow(-2)
				_settlement_grid_draw_control.draw_rect(inner_rect, Color(1.0, 0.2, 0.2, 0.4), false, 1.0)
			elif item.rarity == ITEM_CLASS.Rarity.GOLD:
				var inner_rect := rect.grow(-2)
				_settlement_grid_draw_control.draw_rect(inner_rect, Color(1.0, 0.85, 0.2, 0.4), false, 1.0)

			# Item Name (Top-left)
			var name_pos := Vector2(rect.position.x + 5, rect.position.y + 14)
			_settlement_grid_draw_control.draw_string(
				font,
				name_pos,
				item.display_name,
				HORIZONTAL_ALIGNMENT_LEFT,
				rect.size.x - 10,
				11,
				Color.WHITE
			)

			# Badge (Center / Middle)
			if rect.size.y >= 50:
				var badge: String = _rarity_badge(item.rarity)
				var icon_pos := Vector2(rect.position.x + 6, rect.position.y + rect.size.y * 0.5 + 4)
				_settlement_grid_draw_control.draw_string(
					font,
					icon_pos,
					badge,
					HORIZONTAL_ALIGNMENT_LEFT,
					rect.size.x - 12,
					11,
					Color(0.9, 0.9, 0.9, 0.8)
				)

			# Value (Bottom)
			var val_str := "%s Xu" % _format_number(item.silver_value)
			if item.reward_type == "black_ticket":
				val_str = "Vé đen 🎟️"
			elif item.is_resource and item.silver_value == 0:
				val_str = "Tài nguyên 💾"

			var val_pos := Vector2(rect.position.x + 5, rect.position.y + rect.size.y - 6)
			_settlement_grid_draw_control.draw_string(
				font,
				val_pos,
				val_str,
				HORIZONTAL_ALIGNMENT_LEFT,
				rect.size.x - 10,
				10,
				r_color
			)

		elif is_loading:
			# Loading active slot
			var slot_bg := Color(0.18, 0.23, 0.30, 0.95)
			_settlement_grid_draw_control.draw_rect(rect, slot_bg, true)
			_settlement_grid_draw_control.draw_rect(rect, Color(0.85, 0.92, 1.0, 0.8), false, 2.0)

			# Spinner arc at center
			var center_pos := rect.position + rect.size * 0.5
			var spinner_rad: float = clampf(mini(rect.size.x, rect.size.y) * 0.22, 9.0, 22.0)
			_settlement_grid_draw_control.draw_arc(
				center_pos,
				spinner_rad,
				_settlement_spinner_angle,
				_settlement_spinner_angle + PI * 1.35,
				24,
				Color.WHITE,
				2.5,
				true
			)

		else:
			# Unrevealed slot
			var dark_slot_bg := Color(0.13, 0.16, 0.21, 0.85)
			_settlement_grid_draw_control.draw_rect(rect, dark_slot_bg, true)
			_settlement_grid_draw_control.draw_rect(rect, Color(0.35, 0.45, 0.55, 0.45), false, 1.2)


func _rarity_badge(rarity: int) -> String:
	match rarity:
		ITEM_CLASS.Rarity.RED: return "🔥 Thần Thoại"
		ITEM_CLASS.Rarity.GOLD: return "⭐ Hoàng Kim"
		ITEM_CLASS.Rarity.PURPLE: return "🔮 Sử Thi"
		ITEM_CLASS.Rarity.BLUE: return "💎 Quý Hiếm"
		ITEM_CLASS.Rarity.GREEN: return "🌿 Đặc Biệt"
		_: return "⚪ Thường"


func _process(delta: float) -> void:
	if _settlement_overlay != null and _settlement_overlay.visible:
		_settlement_spinner_angle = fmod(_settlement_spinner_angle + delta * 8.0, TAU)
		_continue_pulse_time += delta * 4.0
		if _settlement_continue_btn != null and _settlement_continue_btn.visible:
			_settlement_continue_btn.modulate.a = 0.7 + 0.3 * sin(_continue_pulse_time)
		if _is_settlement_revealing and _settlement_grid_draw_control != null:
			_settlement_grid_draw_control.queue_redraw()


func _on_settlement_overlay_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _is_settlement_revealing:
			_settlement_skip_requested = true
		else:
			_on_finish_settlement_pressed()


func _on_skip_pressed() -> void:
	if _is_settlement_revealing:
		_settlement_skip_requested = true


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_B:
			if encyclopedia_dialog != null:
				if encyclopedia_dialog.visible:
					encyclopedia_dialog.close_dialog()
				else:
					encyclopedia_dialog.open_dialog()
			get_viewport().set_input_as_handled()
			return

	if _settlement_overlay != null and _settlement_overlay.visible:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
				if _is_settlement_revealing:
					_settlement_skip_requested = true
				else:
					_on_finish_settlement_pressed()
				get_viewport().set_input_as_handled()


func _on_finish_settlement_pressed() -> void:
	_settlement_overlay.visible = false
	visible = false
	if auction_session != null:
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
