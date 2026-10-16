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
const DEFAULT_CHARACTERS_DATA: Array[Dictionary] = [
	{
		"name": "Hoàng Linh Lâm",
		"short_name": "Hoàng Lâm",
		"title": "Nhà họ Hoàng",
		"icon": "👑",
		"portrait": "res://assets/portraits/character_hoang_linh_lam.png",
		"theme_color": Color("#f59e0b")
	},
	{
		"name": "Chu Tuệ Nguyệt",
		"short_name": "Tuệ Nguyệt",
		"title": "Nhà họ Chu",
		"icon": "🔥",
		"portrait": "res://assets/portraits/character_chu_tue_nguyet.png",
		"theme_color": Color("#ef4444")
	},
	{
		"name": "Kim Thanh Giai",
		"short_name": "Thanh Giai",
		"title": "Nhà họ Kim",
		"icon": "💎",
		"portrait": "res://assets/portraits/character_kim_thanh_giai.png",
		"theme_color": Color("#e2e8f0")
	},
	{
		"name": "Huyền Ca Xuý",
		"short_name": "Ca Xuý",
		"title": "Nhà họ Huyền",
		"icon": "🔮",
		"portrait": "res://assets/portraits/character_huyen_ca_xuy.png",
		"theme_color": Color("#38bdf8")
	},
	{
		"name": "Lam Phương Xuân",
		"short_name": "Phương Xuân",
		"title": "Nhà họ Lam",
		"icon": "🌿",
		"portrait": "res://assets/portraits/character_lam_phuong_xuan.png",
		"theme_color": Color("#10b981")
	}
]

var auction_session: AuctionSession
var player_silver_balances: Dictionary = {} # player_id -> int
var encyclopedia_dialog: AuctionEncyclopediaDialog = null

# Item placements in the 10x8 grid
# Dictionary: item_id -> { "pos": Vector2i, "w": int, "h": int, "item": MysteryChestItem }
var _grid_placements: Dictionary = {}
var _revealed_items: Dictionary = {} # item_id -> bool
var _revealed_outlines: Dictionary = {} # item_id -> bool
var _revealed_qualities: Dictionary = {} # item_id -> bool
var _dynamic_grid_rows: int = 8

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

# Numpad Modal Nodes (BidKing Style Keypad)
var _stage_bg_texture: TextureRect
var _numpad_modal: Control
var _numpad_input_display: Label
var _numpad_warning_lbl: Label
var _numpad_multiplier_btn: Button
var _numpad_current_str: String = "0"
var _numpad_secret: bool = false
var _open_numpad_btn: Button

# Bag & Finance Inspect Modal
var _bag_inspect_btn: Button
var _bag_modal: Control
var _bag_modal_title: Label
var _bag_modal_bal: Label

# Item Texture Cache & Hover Preview Card
var _item_texture_cache: Dictionary = {}
var _item_hover_popup: Control
var _current_hovered_item_id: String = ""

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
var _border_anim_time: float = 0.0

# Audio & SFX for Crate Loading / Item Reveal
## Ngưỡng giá trị kích hoạt SFX vang vọng (mặc định = 37, tương đương giá món vàng thấp nhất hiện tại)
const HIGH_VALUE_SFX_THRESHOLD: int = 37
const SFX_ITEM_REVEAL_NORMAL_PATH: String = "res://assets/audio/sfx_item_reveal_normal.wav"
const SFX_ITEM_REVEAL_HIGH_VALUE_PATH: String = "res://assets/audio/sfx_item_reveal_high_value.wav"

var _sfx_player: AudioStreamPlayer
var _sfx_high_val_player: AudioStreamPlayer
var _sfx_normal_stream: AudioStream
var _sfx_high_val_stream: AudioStream


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
	# 1. Neo-Imperial Cyber Stage Background
	var bg_tex := load("res://assets/ui/auction/auction_stage_bg.png") as Texture2D
	if bg_tex != null:
		_stage_bg_texture = TextureRect.new()
		_stage_bg_texture.set_anchors_preset(PRESET_FULL_RECT)
		_stage_bg_texture.texture = bg_tex
		_stage_bg_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_stage_bg_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		add_child(_stage_bg_texture)

	# 2. Subtle dark contrast overlay so UI frames are crisp and readable
	_bg_rect = ColorRect.new()
	_bg_rect.set_anchors_preset(PRESET_FULL_RECT)
	_bg_rect.color = Color(0.01, 0.02, 0.04, 0.40)
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
	top_bar.custom_minimum_size = Vector2(0, 36)
	main_vbox.add_child(top_bar)

	var spacer_top := Control.new()
	spacer_top.size_flags_horizontal = SIZE_EXPAND_FILL
	top_bar.add_child(spacer_top)

	# --- 3 Columns Body ---
	var body_hbox := HBoxContainer.new()
	body_hbox.size_flags_vertical = SIZE_EXPAND_FILL
	body_hbox.add_theme_constant_override("separation", 20)
	main_vbox.add_child(body_hbox)

	# CỘT TRÁI: NGƯỜI THAM GIA ĐẤU GIÁ (BIDDERS - 390px BidKing Style)
	_left_column = VBoxContainer.new()
	_left_column.custom_minimum_size = Vector2(390, 0)
	_left_column.size_flags_vertical = SIZE_EXPAND_FILL
	_left_column.add_theme_constant_override("separation", 6)
	body_hbox.add_child(_left_column)

	var bidders_scroll := ScrollContainer.new()
	bidders_scroll.custom_minimum_size = Vector2(390, 0)
	bidders_scroll.size_flags_vertical = SIZE_EXPAND_FILL
	bidders_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_left_column.add_child(bidders_scroll)

	_bidders_container = VBoxContainer.new()
	_bidders_container.size_flags_horizontal = SIZE_EXPAND_FILL
	_bidders_container.add_theme_constant_override("separation", 6)
	bidders_scroll.add_child(_bidders_container)

	# CỘT GIỮA: BẢNG MANH MỐI FEED (440px)
	_mid_column = VBoxContainer.new()
	_mid_column.custom_minimum_size = Vector2(440, 0)
	_mid_column.add_theme_constant_override("separation", 8)
	body_hbox.add_child(_mid_column)

	var round_badge := PanelContainer.new()
	var r_style := StyleBoxFlat.new()
	r_style.bg_color = Color(0.13, 0.09, 0.07, 0.95)
	r_style.border_color = Color("#c5a059")
	r_style.border_width_left = 2
	r_style.border_width_right = 2
	r_style.border_width_top = 1
	r_style.border_width_bottom = 1
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
	_round_label.add_theme_color_override("font_color", Color("#fef3c7"))
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

	var sp_gt := Control.new()
	sp_gt.size_flags_horizontal = SIZE_EXPAND_FILL
	grid_top.add_child(sp_gt)

	var enc_btn := Button.new()
	enc_btn.text = "📖 Bách Khoa Vật Phẩm"
	enc_btn.flat = true
	enc_btn.focus_mode = FOCUS_NONE
	enc_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	enc_btn.tooltip_text = "Tra cứu Bách Khoa Toàn Thư / Xem danh mục đồ đấu giá (Phím B)"
	enc_btn.add_theme_color_override("font_color", Color("#e6c280"))
	enc_btn.pressed.connect(func() -> void:
		if encyclopedia_dialog != null:
			encyclopedia_dialog.open_dialog()
	)
	grid_top.add_child(enc_btn)

	var crate_panel := PanelContainer.new()
	crate_panel.size_flags_horizontal = SIZE_EXPAND_FILL
	crate_panel.size_flags_vertical = SIZE_EXPAND_FILL
	var c_style := StyleBoxEmpty.new()
	crate_panel.add_theme_stylebox_override("panel", c_style)
	_right_column.add_child(crate_panel)

	var crate_scroll := ScrollContainer.new()
	crate_scroll.size_flags_horizontal = SIZE_EXPAND_FILL
	crate_scroll.size_flags_vertical = SIZE_EXPAND_FILL
	crate_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	crate_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	crate_panel.add_child(crate_scroll)

	var center_grid := CenterContainer.new()
	center_grid.size_flags_horizontal = SIZE_EXPAND_FILL
	crate_scroll.add_child(center_grid)

	_grid_draw_control = Control.new()
	_grid_draw_control.custom_minimum_size = Vector2(GRID_COLS * CELL_SIZE, _dynamic_grid_rows * CELL_SIZE)
	_grid_draw_control.mouse_filter = MOUSE_FILTER_PASS
	_grid_draw_control.draw.connect(_on_grid_draw)
	_grid_draw_control.gui_input.connect(_on_grid_gui_input)
	_grid_draw_control.mouse_exited.connect(func() -> void:
		_current_hovered_item_id = ""
		if _item_hover_popup != null:
			_item_hover_popup.visible = false
	)
	center_grid.add_child(_grid_draw_control)

	var min_val_margin := MarginContainer.new()
	min_val_margin.size_flags_horizontal = SIZE_EXPAND_FILL
	min_val_margin.add_theme_constant_override("margin_right", 60)
	min_val_margin.add_theme_constant_override("margin_bottom", 6)
	_right_column.add_child(min_val_margin)

	_min_value_label = Label.new()
	_min_value_label.text = "Giá ước tính thấp nhất hiện tại: 0 Xu Bạc"
	_min_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_min_value_label.add_theme_font_size_override("font_size", 15)
	_min_value_label.add_theme_color_override("font_color", Color("#50fa7b"))
	min_val_margin.add_child(_min_value_label)

	# --- BOTTOM ACTION BAR ---
	# --- Bottom Action Bar (Transparent / Floating Controls) ---
	_bottom_bar = PanelContainer.new()
	_bottom_bar.custom_minimum_size = Vector2(0, 56)
	var btm_style := StyleBoxEmpty.new()
	_bottom_bar.add_theme_stylebox_override("panel", btm_style)
	main_vbox.add_child(_bottom_bar)

	var btm_hbox := HBoxContainer.new()
	btm_hbox.add_theme_constant_override("separation", 16)
	btm_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_bottom_bar.add_child(btm_hbox)

	# Hidden compatibility labels & inputs (kept for test suite & headless assertions)
	_turn_info_label = Label.new()
	_turn_info_label.visible = false
	btm_hbox.add_child(_turn_info_label)

	_timer_label = Label.new()
	_timer_label.visible = false
	btm_hbox.add_child(_timer_label)

	_bid_feedback_lbl = Label.new()
	_bid_feedback_lbl.visible = false
	btm_hbox.add_child(_bid_feedback_lbl)

	# Multi-player Bidding Controls
	_bid_box = HBoxContainer.new()
	_bid_box.add_theme_constant_override("separation", 12)
	_bid_box.alignment = BoxContainer.ALIGNMENT_CENTER
	btm_hbox.add_child(_bid_box)

	# Hidden inputs for tests
	_bid_input = LineEdit.new()
	_bid_input.visible = false
	_bid_input.text_changed.connect(_on_bid_input_changed)
	_bid_input.text_submitted.connect(func(_t: String) -> void: _on_confirm_bid_pressed())
	_bid_box.add_child(_bid_input)

	_confirm_bid_btn = Button.new()
	_confirm_bid_btn.visible = false
	_confirm_bid_btn.pressed.connect(_on_confirm_bid_pressed)
	_bid_box.add_child(_confirm_bid_btn)

	_pass_btn = Button.new()
	_pass_btn.visible = false
	_pass_btn.pressed.connect(_on_pass_bid_pressed)
	_bid_box.add_child(_pass_btn)

	_fold_btn = Button.new()
	_fold_btn.visible = false
	_fold_btn.pressed.connect(_on_fold_bid_pressed)
	_bid_box.add_child(_fold_btn)

	# 1. Bag / Finance inspection button [ ⬡ ]
	_bag_inspect_btn = Button.new()
	_bag_inspect_btn.text = "⬡"
	_bag_inspect_btn.tooltip_text = "Xem túi đồ & lượng Xu Bạc sở hữu của bạn"
	_bag_inspect_btn.custom_minimum_size = Vector2(50, 48)
	_bag_inspect_btn.focus_mode = FOCUS_NONE
	var bag_style := StyleBoxFlat.new()
	bag_style.bg_color = Color(0.12, 0.16, 0.22, 0.9)
	bag_style.border_color = Color(0.4, 0.55, 0.75, 0.8)
	bag_style.border_width_left = 2
	bag_style.border_width_top = 2
	bag_style.border_width_right = 2
	bag_style.border_width_bottom = 2
	bag_style.corner_radius_top_left = 8
	bag_style.corner_radius_top_right = 8
	bag_style.corner_radius_bottom_left = 8
	bag_style.corner_radius_bottom_right = 8
	_bag_inspect_btn.add_theme_stylebox_override("normal", bag_style)
	var bag_hover := bag_style.duplicate() as StyleBoxFlat
	bag_hover.bg_color = Color(0.20, 0.28, 0.38, 1.0)
	bag_hover.border_color = Color("#f6c95c")
	_bag_inspect_btn.add_theme_stylebox_override("hover", bag_hover)
	_bag_inspect_btn.add_theme_font_size_override("font_size", 22)
	_bag_inspect_btn.add_theme_color_override("font_color", Color.WHITE)
	_bag_inspect_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_bag_inspect_btn.pressed.connect(_open_bag_modal)
	_bid_box.add_child(_bag_inspect_btn)

	# 2. Main Place Bid Button [ Đặt giá ]
	_open_numpad_btn = Button.new()
	_open_numpad_btn.text = "Đặt giá"
	_open_numpad_btn.custom_minimum_size = Vector2(240, 48)
	_open_numpad_btn.focus_mode = FOCUS_NONE
	var on_style := StyleBoxFlat.new()
	on_style.bg_color = Color("#ffd600")
	on_style.border_color = Color("#fff59d")
	on_style.border_width_left = 2
	on_style.border_width_top = 2
	on_style.border_width_right = 2
	on_style.border_width_bottom = 2
	on_style.corner_radius_top_left = 8
	on_style.corner_radius_top_right = 8
	on_style.corner_radius_bottom_left = 8
	on_style.corner_radius_bottom_right = 8
	_open_numpad_btn.add_theme_stylebox_override("normal", on_style)
	var on_hover := on_style.duplicate() as StyleBoxFlat
	on_hover.bg_color = Color("#ffea00")
	on_hover.border_color = Color.WHITE
	_open_numpad_btn.add_theme_stylebox_override("hover", on_hover)
	_open_numpad_btn.add_theme_color_override("font_color", Color.BLACK)
	_open_numpad_btn.add_theme_font_size_override("font_size", 18)
	_open_numpad_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_open_numpad_btn.pressed.connect(_open_numpad_modal)
	_bid_box.add_child(_open_numpad_btn)

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
	_build_numpad_modal()
	_build_bag_modal()

	encyclopedia_dialog = ENCYCLOPEDIA_DIALOG_CLASS.new()
	encyclopedia_dialog.visible = false
	add_child(encyclopedia_dialog)

	# Audio Players for Item Reveal
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = &"Master"
	add_child(_sfx_player)

	_sfx_high_val_player = AudioStreamPlayer.new()
	_sfx_high_val_player.bus = &"Master"
	_sfx_high_val_player.volume_db = 3.5
	add_child(_sfx_high_val_player)

	if ResourceLoader.exists(SFX_ITEM_REVEAL_NORMAL_PATH):
		_sfx_normal_stream = load(SFX_ITEM_REVEAL_NORMAL_PATH) as AudioStream
	if ResourceLoader.exists(SFX_ITEM_REVEAL_HIGH_VALUE_PATH):
		_sfx_high_val_stream = load(SFX_ITEM_REVEAL_HIGH_VALUE_PATH) as AudioStream


func _play_reveal_sfx(silver_val: int) -> void:
	if silver_val >= HIGH_VALUE_SFX_THRESHOLD:
		if _sfx_high_val_player != null and _sfx_high_val_stream != null:
			_sfx_high_val_player.stream = _sfx_high_val_stream
			_sfx_high_val_player.play()
	else:
		if _sfx_player != null and _sfx_normal_stream != null:
			_sfx_player.stream = _sfx_normal_stream
			_sfx_player.play()


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
	hint_cont_lbl.text = "(Bấm nút Tiếp tục để hoàn tất)"
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

	var s_grid_scroll := ScrollContainer.new()
	s_grid_scroll.size_flags_horizontal = SIZE_EXPAND_FILL
	s_grid_scroll.size_flags_vertical = SIZE_EXPAND_FILL
	s_grid_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	s_grid_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	s_grid_panel.add_child(s_grid_scroll)

	var s_grid_center := CenterContainer.new()
	s_grid_center.size_flags_horizontal = SIZE_EXPAND_FILL
	s_grid_center.mouse_filter = MOUSE_FILTER_PASS
	s_grid_scroll.add_child(s_grid_center)

	_settlement_grid_draw_control = Control.new()
	_settlement_grid_draw_control.custom_minimum_size = Vector2(
		GRID_COLS * SETTLEMENT_CELL_SIZE,
		_dynamic_grid_rows * SETTLEMENT_CELL_SIZE
	)
	_settlement_grid_draw_control.mouse_filter = MOUSE_FILTER_PASS
	_settlement_grid_draw_control.draw.connect(_on_settlement_grid_draw)
	_settlement_grid_draw_control.gui_input.connect(_on_settlement_grid_gui_input)
	_settlement_grid_draw_control.mouse_exited.connect(func() -> void:
		_current_hovered_item_id = ""
		if _item_hover_popup != null:
			_item_hover_popup.visible = false
	)
	s_grid_center.add_child(_settlement_grid_draw_control)


func _generate_grid_placements() -> void:
	_grid_placements.clear()
	# Chiều cao hòm bí ẩn mặc định 28 hàng để luôn luôn cuộn được,
	# ngăn người chơi nhìn kích thước khung mà đoán trước được hòm to hay nhỏ
	_dynamic_grid_rows = 28
	var occupancy: Array[Array] = []
	for y in range(_dynamic_grid_rows):
		var row: Array = []
		for x in range(GRID_COLS):
			row.append(false)
		occupancy.append(row)

	if auction_session == null or auction_session.mystery_chest == null:
		if _grid_draw_control != null:
			_grid_draw_control.custom_minimum_size = Vector2(GRID_COLS * CELL_SIZE, _dynamic_grid_rows * CELL_SIZE)
		return

	for item: ITEM_CLASS in auction_session.mystery_chest.items:
		var w: int = mini(GRID_COLS, maxi(1, item.grid_width))
		var h: int = maxi(1, item.grid_height)
		var placed := false

		while not placed:
			for y in range(_dynamic_grid_rows - h + 1):
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
			if not placed:
				# Tự động nới thêm 4 hàng vào lưới khi hòm chứa nhiều đồ (kể cả 100+ món)
				for _add_r in range(4):
					var new_row: Array = []
					for x in range(GRID_COLS):
						new_row.append(false)
					occupancy.append(new_row)
				_dynamic_grid_rows += 4

	if _grid_draw_control != null:
		_grid_draw_control.custom_minimum_size = Vector2(GRID_COLS * CELL_SIZE, _dynamic_grid_rows * CELL_SIZE)
		_grid_draw_control.queue_redraw()
	if _settlement_grid_draw_control != null:
		_settlement_grid_draw_control.custom_minimum_size = Vector2(GRID_COLS * SETTLEMENT_CELL_SIZE, _dynamic_grid_rows * SETTLEMENT_CELL_SIZE)
		_settlement_grid_draw_control.queue_redraw()


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
			if _open_numpad_btn != null: _open_numpad_btn.disabled = true
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
			if _open_numpad_btn != null: _open_numpad_btn.disabled = false
			if _pass_btn != null: _pass_btn.disabled = false
			if _fold_btn != null: _fold_btn.disabled = false
			if _bid_input != null: _bid_input.editable = true
			if _next_round_btn != null: _next_round_btn.visible = false

			if _turn_info_label != null:
				_turn_info_label.text = "🎯 LƯỢT ĐẤU GIÁ ẨN: %s [🪙 %s Xu] (Gõ số tiền bí mật)" % [
					String(curr_pid),
					_format_number(bal)
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
		var char_data: Dictionary = DEFAULT_CHARACTERS_DATA[i % DEFAULT_CHARACTERS_DATA.size()]

		# Thẻ Bidder phong cách BidKing Cyber-Tabletop (Ảnh 1 & 3)
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(390, 114)
		card.size_flags_horizontal = SIZE_EXPAND_FILL
		card.mouse_filter = MOUSE_FILTER_PASS

		var card_sb := StyleBoxFlat.new()
		card_sb.bg_color = Color(0.07, 0.05, 0.05, 0.94)
		if is_current_turn:
			card_sb.border_color = Color("#f6c95c")
			card_sb.border_width_left = 2
			card_sb.border_width_top = 2
			card_sb.border_width_right = 2
			card_sb.border_width_bottom = 2
		else:
			card_sb.border_color = Color(0.45, 0.36, 0.26, 0.55)
			card_sb.border_width_left = 1
			card_sb.border_width_top = 1
			card_sb.border_width_right = 1
			card_sb.border_width_bottom = 1
		card_sb.corner_radius_top_left = 8
		card_sb.corner_radius_top_right = 8
		card_sb.corner_radius_bottom_left = 8
		card_sb.corner_radius_bottom_right = 8
		card.add_theme_stylebox_override("panel", card_sb)

		if not is_active:
			card.modulate = Color(0.6, 0.6, 0.65, 0.65)

		_bidders_container.add_child(card)

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 8)
		margin.add_theme_constant_override("margin_right", 8)
		margin.add_theme_constant_override("margin_top", 6)
		margin.add_theme_constant_override("margin_bottom", 6)
		card.add_child(margin)

		var root_hbox := HBoxContainer.new()
		root_hbox.add_theme_constant_override("separation", 12)
		margin.add_child(root_hbox)

		# =========================================================
		# 1. CỘT TRÁI: AVATAR NHÂN VẬT (BỎ AVATAR NGƯỜI CHƠI)
		# =========================================================
		var left_col := VBoxContainer.new()
		left_col.custom_minimum_size = Vector2(74, 0)
		left_col.alignment = BoxContainer.ALIGNMENT_CENTER
		root_hbox.add_child(left_col)

		var p_path: String = char_data.portrait
		var portrait_tex: Texture2D = _get_cached_item_texture(p_path)
		if portrait_tex != null:
			var c_img := TextureRect.new()
			c_img.texture = portrait_tex
			c_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			c_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			c_img.custom_minimum_size = Vector2(74, 74)
			left_col.add_child(c_img)
		else:
			var c_center := CenterContainer.new()
			c_center.custom_minimum_size = Vector2(74, 74)
			var c_icon_lbl := Label.new()
			c_icon_lbl.text = char_data.icon
			c_icon_lbl.add_theme_font_size_override("font_size", 36)
			c_center.add_child(c_icon_lbl)
			left_col.add_child(c_center)

		# =========================================================
		# 2. KHU VỰC BÊN PHẢI (THÔNG TIN & 5 CỘT ROUND)
		# =========================================================
		var right_vbox := VBoxContainer.new()
		right_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
		right_vbox.add_theme_constant_override("separation", 4)
		root_hbox.add_child(right_vbox)

		# Hàng 1: Tên người chơi & Trạng thái ra giá góc phải
		var row1_hbox := HBoxContainer.new()
		row1_hbox.size_flags_horizontal = SIZE_EXPAND_FILL
		right_vbox.add_child(row1_hbox)

		var p_name_lbl := Label.new()
		p_name_lbl.text = "Player %d" % (i + 1)
		p_name_lbl.size_flags_horizontal = SIZE_EXPAND_FILL
		p_name_lbl.add_theme_font_size_override("font_size", 13)
		p_name_lbl.add_theme_color_override("font_color", Color.WHITE if is_active else Color("#7a6c5d"))
		row1_hbox.add_child(p_name_lbl)

		# Góc phải Hàng 1: Chỉ hiện hộp cọc tiền 🪙 khi tới lượt, bỏ 'Ra giá lần 1/2'
		if is_current_turn:
			var coin_box := PanelContainer.new()
			coin_box.custom_minimum_size = Vector2(92, 22)
			var coin_sb := StyleBoxFlat.new()
			coin_sb.bg_color = Color(0.98, 0.96, 0.90, 0.95)
			coin_sb.border_color = Color("#c5a059")
			coin_sb.border_width_left = 1
			coin_sb.border_width_top = 1
			coin_sb.border_width_right = 1
			coin_sb.border_width_bottom = 1
			coin_sb.corner_radius_top_left = 4
			coin_sb.corner_radius_top_right = 4
			coin_sb.corner_radius_bottom_left = 4
			coin_sb.corner_radius_bottom_right = 4
			coin_box.add_theme_stylebox_override("panel", coin_sb)

			var coin_hbox := HBoxContainer.new()
			coin_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
			coin_hbox.add_theme_constant_override("separation", 4)
			coin_box.add_child(coin_hbox)

			var coin_icon := Label.new()
			coin_icon.text = "🪙"
			coin_icon.add_theme_font_size_override("font_size", 11)
			coin_hbox.add_child(coin_icon)

			var coin_txt := Label.new()
			coin_txt.text = "Đang ra giá"
			coin_txt.add_theme_font_size_override("font_size", 10)
			coin_txt.add_theme_color_override("font_color", Color(0.22, 0.14, 0.08, 1.0))
			coin_hbox.add_child(coin_txt)

			row1_hbox.add_child(coin_box)
		elif not is_active:
			var fold_lbl := Label.new()
			fold_lbl.text = "🏳️ Đã bỏ"
			fold_lbl.add_theme_font_size_override("font_size", 10)
			fold_lbl.add_theme_color_override("font_color", Color("#7a6c5d"))
			row1_hbox.add_child(fold_lbl)

		# Hàng 2: Tên nhân vật phóng to theo màu gia tộc (Hoàng, Chu, Kim, Huyền, Lam)
		var banner_panel := PanelContainer.new()
		banner_panel.size_flags_horizontal = SIZE_EXPAND_FILL
		var banner_sb := StyleBoxFlat.new()
		banner_sb.bg_color = Color(0.11, 0.08, 0.07, 0.90)
		banner_sb.border_width_left = 3
		banner_sb.border_color = char_data.theme_color
		banner_sb.corner_radius_top_right = 3
		banner_sb.corner_radius_bottom_right = 3
		banner_sb.content_margin_left = 6
		banner_sb.content_margin_right = 6
		banner_sb.content_margin_top = 2
		banner_sb.content_margin_bottom = 2
		banner_panel.add_theme_stylebox_override("panel", banner_sb)
		right_vbox.add_child(banner_panel)

		var b_title := Label.new()
		b_title.text = char_data.name
		b_title.add_theme_font_size_override("font_size", 13)
		b_title.add_theme_color_override("font_color", char_data.theme_color)
		banner_panel.add_child(b_title)

		# Hàng 3: 5 Cột Round (1, 2, 3, 4, 5)
		var rounds_hbox := HBoxContainer.new()
		rounds_hbox.add_theme_constant_override("separation", 6)
		right_vbox.add_child(rounds_hbox)

		for r in range(1, 6):
			var r_col := VBoxContainer.new()
			r_col.custom_minimum_size = Vector2(36, 0)
			r_col.alignment = BoxContainer.ALIGNMENT_CENTER
			r_col.add_theme_constant_override("separation", 2)
			rounds_hbox.add_child(r_col)

			# 1. Con số round
			var r_lbl := Label.new()
			r_lbl.text = str(r)
			r_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			r_lbl.add_theme_font_size_override("font_size", 9)
			if r <= auction_session.current_round:
				r_lbl.add_theme_color_override("font_color", Color("#e8dfd5"))
			else:
				r_lbl.add_theme_color_override("font_color", Color("#5c4f42"))
			r_col.add_child(r_lbl)

			# 2. Ô vuông item sử dụng ở round đó (Placeholder)
			var item_slot := PanelContainer.new()
			item_slot.custom_minimum_size = Vector2(26, 26)
			var slot_sb := StyleBoxFlat.new()
			slot_sb.bg_color = Color(0.05, 0.04, 0.04, 0.85)
			slot_sb.border_color = Color(0.38, 0.30, 0.22, 0.5)
			slot_sb.border_width_left = 1
			slot_sb.border_width_top = 1
			slot_sb.border_width_right = 1
			slot_sb.border_width_bottom = 1
			slot_sb.corner_radius_top_left = 3
			slot_sb.corner_radius_top_right = 3
			slot_sb.corner_radius_bottom_left = 3
			slot_sb.corner_radius_bottom_right = 3
			item_slot.add_theme_stylebox_override("panel", slot_sb)
			item_slot.tooltip_text = "Ô vật phẩm vòng %d (Trống)" % r
			r_col.add_child(item_slot)

			# 3. Con số thứ tự đặt giá & Tooltip xem giá khi trỏ chuột
			var rank_box := PanelContainer.new()
			rank_box.custom_minimum_size = Vector2(22, 18)
			rank_box.mouse_filter = MOUSE_FILTER_PASS
			var rank_sb := StyleBoxFlat.new()
			rank_sb.corner_radius_top_left = 3
			rank_sb.corner_radius_top_right = 3
			rank_sb.corner_radius_bottom_left = 3
			rank_sb.corner_radius_bottom_right = 3

			var is_round_done: bool = (r < auction_session.current_round) or (r == auction_session.current_round and _round_completed)
			var past_rank: int = 0
			if is_round_done:
				past_rank = auction_session.get_player_rank_in_round(pid, r)

			var rank_lbl := Label.new()
			rank_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			rank_lbl.add_theme_font_size_override("font_size", 9)

			if past_rank > 0:
				match past_rank:
					1:
						rank_sb.bg_color = Color(0.92, 0.70, 0.05, 0.95)
						rank_lbl.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
					2:
						rank_sb.bg_color = Color(0.06, 0.71, 0.83, 0.95)
						rank_lbl.add_theme_color_override("font_color", Color.WHITE)
					3:
						rank_sb.bg_color = Color(0.23, 0.51, 0.96, 0.95)
						rank_lbl.add_theme_color_override("font_color", Color.WHITE)
					_:
						rank_sb.bg_color = Color(0.13, 0.77, 0.36, 0.95)
						rank_lbl.add_theme_color_override("font_color", Color.WHITE)
				rank_lbl.text = str(past_rank)

				# Cơ chế Tooltip: Chỉ hiển thị giá đã đặt khi người chơi trỏ vào thẻ của chính mình ở lượt mình
				if pid == curr_pid:
					var past_bid: int = auction_session.get_player_bid_in_round(pid, r)
					rank_box.tooltip_text = "%s Xu" % _format_number(past_bid) if past_bid > 0 else "0 Xu"
				else:
					rank_box.tooltip_text = ""
			else:
				rank_sb.bg_color = Color(0.10, 0.13, 0.18, 0.5)
				rank_lbl.text = "-"
				rank_lbl.add_theme_color_override("font_color", Color("#475569"))
				rank_box.tooltip_text = ""

			rank_box.add_theme_stylebox_override("panel", rank_sb)
			rank_box.add_child(rank_lbl)
			r_col.add_child(rank_box)



func _render_clues() -> void:
	for child in _clues_feed.get_children():
		child.queue_free()

	for hint in auction_session.hints_history:
		var is_bonus: bool = bool(hint.get("is_bonus", false))
		var card := PanelContainer.new()
		var cl_style := StyleBoxFlat.new()
		cl_style.bg_color = Color(0.12, 0.08, 0.06, 0.95) if is_bonus else Color(0.08, 0.06, 0.05, 0.92)
		cl_style.border_color = Color("#f6c95c") if is_bonus else Color(0.55, 0.44, 0.30, 0.70)
		cl_style.border_width_left = 2 if is_bonus else 1
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
		icon_lbl.text = "✨" if is_bonus else "🔍"
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
		t_lbl.add_theme_color_override("font_color", Color("#fde047") if is_bonus else Color("#e6c280"))
		vbox.add_child(t_lbl)

		var d_lbl := Label.new()
		d_lbl.text = String(hint.get("description", ""))
		d_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		d_lbl.add_theme_font_size_override("font_size", 13)
		d_lbl.add_theme_color_override("font_color", Color("#f3ede2"))
		vbox.add_child(d_lbl)


func _get_rect_perimeter_point(rect: Rect2, dist: float) -> Vector2:
	var w: float = rect.size.x
	var h: float = rect.size.y
	var p: float = 2.0 * (w + h)
	if p <= 0.0:
		return rect.position
	var d: float = fposmod(dist, p)
	if d < w:
		return Vector2(rect.position.x + d, rect.position.y)
	d -= w
	if d < h:
		return Vector2(rect.position.x + w, rect.position.y + d)
	d -= h
	if d < w:
		return Vector2(rect.position.x + w - d, rect.position.y + h)
	d -= w
	return Vector2(rect.position.x, rect.position.y + h - d)


func _draw_rect_perimeter_segment(canvas: Control, rect: Rect2, sa: float, sb: float, color: Color, width: float, corners: Array[float], p: float) -> void:
	if sa > sb:
		var p0 := _get_rect_perimeter_point(rect, sa)
		var pc := _get_rect_perimeter_point(rect, p)
		var p_zero := _get_rect_perimeter_point(rect, 0.0)
		var p1 := _get_rect_perimeter_point(rect, sb)
		canvas.draw_line(p0, pc, color, width)
		canvas.draw_line(p_zero, p1, color, width)
	else:
		var found_c: float = -1.0
		for c in corners:
			if sa < c and c < sb:
				found_c = c
				break
		if found_c >= 0.0:
			var p0 := _get_rect_perimeter_point(rect, sa)
			var pc := _get_rect_perimeter_point(rect, found_c)
			var p1 := _get_rect_perimeter_point(rect, sb)
			canvas.draw_line(p0, pc, color, width)
			canvas.draw_line(pc, p1, color, width)
		else:
			var p0 := _get_rect_perimeter_point(rect, sa)
			var p1 := _get_rect_perimeter_point(rect, sb)
			canvas.draw_line(p0, p1, color, width)


func _draw_running_light_border(canvas: Control, rect: Rect2, light_color: Color, base_width: float = 2.0, phase_seed: float = 0.0) -> void:
	var w: float = rect.size.x
	var h: float = rect.size.y
	var p: float = 2.0 * (w + h)
	if p <= 0.0:
		return

	# BidKing Style: 2 vệt sáng đối diện nhau (cách nhau 180 độ qua chu vi) cùng chạy quanh viền hình chữ nhật
	# Không vẽ hạt/cục tròn rời mà làm dày viền cục bộ và phát sáng neon khi vệt sáng đi qua
	var beam_len: float = clampf(p * 0.28, 24.0, 70.0)
	var half_len: float = beam_len * 0.5
	var corners: Array[float] = [w, w + h, 2.0 * w + h]
	var num_steps: int = 12
	var step: float = beam_len / float(num_steps)

	var center0: float = fposmod(_border_anim_time * 115.0 + phase_seed, p)
	var centers: Array[float] = [center0, fposmod(center0 + p * 0.5, p)]

	for center in centers:
		for k in range(num_steps):
			var ta: float = -half_len + float(k) * step
			var tb: float = -half_len + float(k + 1) * step
			var tmid: float = (ta + tb) * 0.5
			var u: float = clampf(absf(tmid) / half_len, 0.0, 1.0)
			# Cosine bell curve: 1.0 ở tâm vệt sáng, 0.0 ở 2 mép
			var f: float = cos(u * PI * 0.5)

			var sa: float = fposmod(center + ta, p)
			var sb: float = fposmod(center + tb, p)

			# 1. Hào quang neon phát sáng nở rộng ra ngoài viền (Outer neon bloom)
			var bloom_w: float = base_width + 3.0 * f
			var bloom_col := Color(light_color.r, light_color.g, light_color.b, light_color.a * 0.32 * f)
			_draw_rect_perimeter_segment(canvas, rect, sa, sb, bloom_col, bloom_w, corners, p)

			# 2. Lõi viền nở to nhẹ và sáng rực trắng theo viền (Core thickened bright line)
			var core_w: float = base_width + 1.2 * f
			var core_r: float = lerpf(light_color.r, 1.0, 0.65 * f)
			var core_g: float = lerpf(light_color.g, 1.0, 0.65 * f)
			var core_b: float = lerpf(light_color.b, 1.0, 0.65 * f)
			var core_col := Color(core_r, core_g, core_b, light_color.a * (0.35 + 0.65 * f))
			_draw_rect_perimeter_segment(canvas, rect, sa, sb, core_col, core_w, corners, p)


func _on_grid_draw() -> void:
	# 1. Subtle 1x1 grid lines (bỏ 2 đường viền ngoài cùng bên trái và phải)
	var line_color := Color(0.2, 0.3, 0.4, 0.35)
	for x in range(1, GRID_COLS):
		_grid_draw_control.draw_line(Vector2(x * CELL_SIZE, 0), Vector2(x * CELL_SIZE, _dynamic_grid_rows * CELL_SIZE), line_color, 1.0)
	for y in range(_dynamic_grid_rows + 1):
		_grid_draw_control.draw_line(Vector2(0, y * CELL_SIZE), Vector2(GRID_COLS * CELL_SIZE, y * CELL_SIZE), line_color, 1.0)

	# 2. Draw placed items
	for i_id in _grid_placements:
		var entry: Dictionary = _grid_placements[i_id]
		var item: ITEM_CLASS = entry.get("item") as ITEM_CLASS
		var pos: Vector2i = entry.get("pos") as Vector2i
		var w: int = int(entry.get("w", 1))
		var h: int = int(entry.get("h", 1))

		var rect := Rect2(pos.x * CELL_SIZE, pos.y * CELL_SIZE, w * CELL_SIZE, h * CELL_SIZE)
		var r_color: Color = ITEM_CLASS.rarity_color(item.rarity)

		var is_full_reveal: bool = _revealed_items.has(i_id)
		var is_quality_reveal: bool = _revealed_qualities.has(i_id)
		var is_outline_reveal: bool = _revealed_outlines.has(i_id)
		var phase_seed: float = float((pos.x * 37 + pos.y * 61) % 150) * 3.0

		if is_full_reveal:
			_grid_draw_control.draw_rect(rect, Color(r_color.r, r_color.g, r_color.b, 0.25), true)
			_grid_draw_control.draw_rect(rect, r_color, false, 2.2)
			_draw_running_light_border(_grid_draw_control, rect, r_color.lightened(0.4), 2.2, phase_seed)

			# 1. Vẽ hình ảnh vật phẩm thực tế từ asset_path nếu có (bảo toàn tỉ lệ gốc, không bị kéo giãn)
			var tex: Texture2D = _get_cached_item_texture(item.asset_path)
			if tex != null:
				var pad: float = 3.0
				var avail_w: float = rect.size.x - pad * 2.0
				var avail_h: float = rect.size.y - pad * 2.0
				var tex_sz: Vector2 = tex.get_size()
				if tex_sz.x > 0.0 and tex_sz.y > 0.0:
					var scale_f: float = minf(avail_w / tex_sz.x, avail_h / tex_sz.y)
					var drawn_w: float = tex_sz.x * scale_f
					var drawn_h: float = tex_sz.y * scale_f
					var draw_x: float = rect.position.x + pad + (avail_w - drawn_w) * 0.5
					var draw_y: float = rect.position.y + pad + (avail_h - drawn_h) * 0.5
					var draw_r := Rect2(draw_x, draw_y, drawn_w, drawn_h)
					_grid_draw_control.draw_texture_rect(tex, draw_r, false)
			else:
				var font := ThemeDB.fallback_font
				var t_pos := Vector2(pos.x * CELL_SIZE + 4, pos.y * CELL_SIZE + 13)
				_grid_draw_control.draw_string(font, t_pos, item.display_name, HORIZONTAL_ALIGNMENT_LEFT, w * CELL_SIZE - 8, 10, Color.WHITE)

			# 2. Tag hiển thị giá trị ở cạnh dưới
			var font := ThemeDB.fallback_font
			var v_text := "%s Xu" % _format_number(item.silver_value)
			if item.reward_type == "black_ticket":
				v_text = "Vé đen 🎟️"
			elif item.is_resource and item.silver_value == 0:
				v_text = "Tài nguyên"
			var tag_h: float = 14.0
			var tag_rect := Rect2(pos.x * CELL_SIZE + 2, (pos.y + h) * CELL_SIZE - tag_h - 2, w * CELL_SIZE - 4, tag_h)
			_grid_draw_control.draw_rect(tag_rect, Color(0, 0, 0, 0.75), true)
			var v_pos := Vector2(pos.x * CELL_SIZE + 4, (pos.y + h) * CELL_SIZE - 4)
			_grid_draw_control.draw_string(font, v_pos, v_text, HORIZONTAL_ALIGNMENT_LEFT, w * CELL_SIZE - 8, 9, r_color)
		else:
			if is_outline_reveal:
				# Gợi ý kích cỡ đổi sang màu xám nhạt với hiệu ứng chạy ánh sáng ở viền
				_grid_draw_control.draw_rect(rect, Color(0.85, 0.88, 0.92, 0.08), true)
				_grid_draw_control.draw_rect(rect, Color(0.72, 0.76, 0.82, 0.85), false, 2.0)
				_draw_running_light_border(_grid_draw_control, rect, Color(0.95, 0.98, 1.0, 1.0), 2.0, phase_seed)
			if is_quality_reveal:
				# Gợi ý phẩm cấp hiển thị ở ô góc 1x1 kèm hiệu ứng chạy ánh sáng ở viền
				var q_rect := Rect2(pos.x * CELL_SIZE + 2, pos.y * CELL_SIZE + 2, CELL_SIZE - 4, CELL_SIZE - 4)
				_grid_draw_control.draw_rect(q_rect, Color(r_color.r, r_color.g, r_color.b, 0.7), true)
				_grid_draw_control.draw_rect(q_rect, r_color, false, 2.0)
				_draw_running_light_border(_grid_draw_control, q_rect, r_color.lightened(0.4), 2.0, phase_seed + 20.0)



func _get_cached_item_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if _item_texture_cache.has(path):
		return _item_texture_cache[path] as Texture2D
	if ResourceLoader.exists(path):
		var t := load(path) as Texture2D
		_item_texture_cache[path] = t
		return t
	return null


func _build_item_hover_popup() -> void:
	if _item_hover_popup != null:
		return
	_item_hover_popup = Control.new()
	_item_hover_popup.custom_minimum_size = Vector2(246, 193)
	_item_hover_popup.size = Vector2(246, 193)
	_item_hover_popup.mouse_filter = MOUSE_FILTER_IGNORE
	_item_hover_popup.visible = false
	_item_hover_popup.top_level = true
	add_child(_item_hover_popup)


static func _set_mouse_filter_recursive(node: Node, filter: int) -> void:
	if node is Control:
		(node as Control).mouse_filter = filter
	for child in node.get_children():
		_set_mouse_filter_recursive(child, filter)


func _show_item_hover_popup(item: ITEM_CLASS, mouse_pos: Vector2) -> void:
	if _item_hover_popup == null:
		_build_item_hover_popup()
	if item == null:
		_current_hovered_item_id = ""
		_item_hover_popup.visible = false
		return

	var str_id: String = String(item.item_id)
	if _current_hovered_item_id != str_id or _item_hover_popup.get_child_count() == 0:
		_current_hovered_item_id = str_id
		for ch in _item_hover_popup.get_children():
			ch.queue_free()

		# Khởi tạo card chuẩn xác 100% từ Bách Khoa Toàn Thư (AuctionEncyclopediaDialog)
		var card: Control = ENCYCLOPEDIA_DIALOG_CLASS.create_item_card(item.to_dict())
		_set_mouse_filter_recursive(card, Control.MOUSE_FILTER_IGNORE)
		_item_hover_popup.add_child(card)

	var vp_size := get_viewport_rect().size
	var pop_w: float = 246.0
	var pop_h: float = 193.0
	var target_x: float = mouse_pos.x + 16.0
	var target_y: float = mouse_pos.y + 16.0
	if target_x + pop_w > vp_size.x:
		target_x = mouse_pos.x - pop_w - 12.0
	if target_y + pop_h > vp_size.y:
		target_y = mouse_pos.y - pop_h - 12.0
	_item_hover_popup.global_position = Vector2(target_x, target_y)
	_item_hover_popup.visible = true


func _on_grid_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var pos: Vector2 = (event as InputEventMouseMotion).position
		var cell_x := int(pos.x / float(CELL_SIZE))
		var cell_y := int(pos.y / float(CELL_SIZE))
		var hovered_item: ITEM_CLASS = null

		for i_id in _grid_placements:
			var entry: Dictionary = _grid_placements[i_id]
			var p: Vector2i = entry.get("pos") as Vector2i
			var w: int = int(entry.get("w", 1))
			var h: int = int(entry.get("h", 1))
			if cell_x >= p.x and cell_x < p.x + w and cell_y >= p.y and cell_y < p.y + h:
				if _revealed_items.has(String(i_id)):
					hovered_item = entry.get("item") as ITEM_CLASS
				break

		if hovered_item != null:
			_show_item_hover_popup(hovered_item, _grid_draw_control.get_global_mouse_position())
		else:
			_current_hovered_item_id = ""
			if _item_hover_popup != null:
				_item_hover_popup.visible = false


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
				ITEM_CLASS.Rarity.GREEN: total += 3
				ITEM_CLASS.Rarity.BLUE: total += 8
				ITEM_CLASS.Rarity.PURPLE: total += 11
				ITEM_CLASS.Rarity.GOLD: total += 37
				ITEM_CLASS.Rarity.RED: total += 85
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

	_current_bid_value = 0
	if _bid_input != null:
		_bid_input.text = ""
		_bid_input.secret = true
		_bid_input.placeholder_text = "Nhập giá ẩn..."
		_bid_input.grab_focus()


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
	curr_val = maxi(0, curr_val + delta)
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
	if bid_val < 0:
		_show_bid_feedback("⚠️ Số tiền ra giá không được nhỏ hơn 0 Xu!")
		return

	var bal: int = int(player_silver_balances.get(curr_pid, 999999))
	if bid_val > bal:
		_show_bid_feedback("⚠️ Không đủ Xu Bạc! %s chỉ có %s Xu." % [String(curr_pid), _format_number(bal)])
		return

	var ok: bool = auction_session.place_bid(curr_pid, bid_val)
	if not ok:
		_show_bid_feedback("⚠️ Không thể ra giá này!")
		return

	_show_bid_feedback("🔒 %s đã ra giá ẩn thành công!" % String(curr_pid))
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
		# Tất cả người chơi trong vòng đã ra giá xong! Lật mở giá và xác định người dẫn đầu
		var round_res: Dictionary = auction_session.resolve_round_bids()
		var ko_data: Dictionary = round_res.get("knockout", {})
		if not ko_data.is_empty():
			_handle_knockout_victory(ko_data)
			return
		else:
			var h_pid: StringName = auction_session.highest_bidder_id
			var h_bid: int = auction_session.highest_bid
			if h_bid > 0:
				_show_bid_feedback("📢 TẤT CẢ ĐÃ RA GIÁ XONG! %s đang dẫn đầu Vòng %d với %s Xu." % [
					String(h_pid), auction_session.current_round, _format_number(h_bid)
				])
			else:
				_show_bid_feedback("📢 TẤT CẢ ĐÃ RA GIÁ XONG! Chưa ai ra giá ở Vòng %d." % auction_session.current_round)
	else:
		_setup_initial_bid_for_current_player()
	refresh_ui()


func _handle_knockout_victory(ko_data: Dictionary) -> void:
	var w_pid: StringName = ko_data.get("winner_id", &"")
	var w_bid: int = int(ko_data.get("top1_bid", 0))
	var t2_pid: StringName = ko_data.get("top2_id", &"")
	var t2_bid: int = int(ko_data.get("top2_bid", 0))
	var r: int = int(ko_data.get("round", 1))
	var req_r: float = float(ko_data.get("req_ratio", 2.0))
	var act_r: float = float(ko_data.get("actual_ratio", 2.0))

	var msg := ""
	if t2_bid > 0:
		msg = "💥 ĐOẠT HÒM ÁP ĐẢO (VÒNG %d)! %s ra giá %s Xu (gấp %.2fx so với %s: %s Xu, mốc yêu cầu %.1fx) — Ngay lập tức sở hữu hòm!" % [
			r, String(w_pid), _format_number(w_bid), act_r, String(t2_pid), _format_number(t2_bid), req_r
		]
	else:
		msg = "💥 ĐOẠT HÒM ÁP ĐẢO (VÒNG %d)! %s ra giá %s Xu trong khi đối thủ không theo giá — Ngay lập tức sở hữu hòm!" % [
			r, String(w_pid), _format_number(w_bid)
		]

	_round_completed = true
	_show_bid_feedback(msg)
	refresh_ui()

	if _turn_info_label != null:
		_turn_info_label.text = msg
		_turn_info_label.add_theme_color_override("font_color", Color("#50fa7b"))

	if _confirm_bid_btn != null: _confirm_bid_btn.disabled = true
	if _open_numpad_btn != null: _open_numpad_btn.disabled = true
	if _pass_btn != null: _pass_btn.disabled = true
	if _fold_btn != null: _fold_btn.disabled = true
	if _bid_input != null: _bid_input.editable = false
	if _next_round_btn != null: _next_round_btn.visible = false

	var timer := get_tree().create_timer(1.6)
	timer.timeout.connect(func() -> void:
		_show_settlement_dialog()
	)


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

		# Determine wait duration according to user specification (reduced speed by 50% = 2x wait time):
		# 5 món top (Flight Recorder, Armored Vehicle Battery, Micro Reactor, Medical Ventilator, Heart of Africa) load đúng 6.0s (trước là 3.0s).
		# Đồ Đỏ khác: ngẫu nhiên từ 1.0s đến 6.0s (trước là 0.5s - 3.0s).
		# Đồ Vàng: ngẫu nhiên từ 0.6s đến 1.6s (trước là 0.3s - 0.8s).
		# Đồ khác: ngẫu nhiên từ 0.4s đến 0.9s (trước là 0.2s - 0.45s).
		var wait_time: float = 0.70
		var item_id_str := String(item.item_id).to_lower()
		var d_name_lower := item.display_name.to_lower()
		var is_top_5: bool = (
			"flight_recorder" in item_id_str or "flight recorder" in d_name_lower
			or "armored_vehicle_battery" in item_id_str or "armored vehicle battery" in d_name_lower
			or "micro_reactor" in item_id_str or "micro reactor" in d_name_lower
			or "medical_ventilator" in item_id_str or "medical ventilator" in d_name_lower
			or "heart_of_africa" in item_id_str or "heart of africa" in d_name_lower
		)
		if is_top_5:
			wait_time = 6.0
		elif item.rarity == ITEM_CLASS.Rarity.RED:
			wait_time = randf_range(1.0, 6.0)
		elif item.rarity == ITEM_CLASS.Rarity.GOLD:
			wait_time = randf_range(0.6, 1.6)
		else:
			wait_time = randf_range(0.4, 0.9)

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
		_play_reveal_sfx(item.silver_value)
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
		_settlement_skip_btn.visible = true
		_settlement_skip_btn.text = "Tiếp tục ➔"
		_settlement_skip_btn.custom_minimum_size = Vector2(150, 36)
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
			Vector2(x * SETTLEMENT_CELL_SIZE, _dynamic_grid_rows * SETTLEMENT_CELL_SIZE),
			line_color,
			1.0
		)
	for y in range(_dynamic_grid_rows + 1):
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
		var phase_seed: float = float((pos.x * 37 + pos.y * 61) % 150) * 3.0

		if is_revealed:
			var r_color: Color = ITEM_CLASS.rarity_color(item.rarity)
			var fill_color := Color(r_color.r, r_color.g, r_color.b, 0.35)
			_settlement_grid_draw_control.draw_rect(rect, fill_color, true)
			var b_width: float = 2.5 if (item.rarity == ITEM_CLASS.Rarity.RED or item.rarity == ITEM_CLASS.Rarity.GOLD) else 2.0
			_settlement_grid_draw_control.draw_rect(rect, r_color, false, b_width)
			_draw_running_light_border(_settlement_grid_draw_control, rect, r_color.lightened(0.4), b_width, phase_seed)

			if item.rarity == ITEM_CLASS.Rarity.RED:
				var inner_rect := rect.grow(-2)
				_settlement_grid_draw_control.draw_rect(inner_rect, Color(1.0, 0.2, 0.2, 0.4), false, 1.0)
			elif item.rarity == ITEM_CLASS.Rarity.GOLD:
				var inner_rect := rect.grow(-2)
				_settlement_grid_draw_control.draw_rect(inner_rect, Color(1.0, 0.85, 0.2, 0.4), false, 1.0)

			# 1. Item Sprite Texture (Center, bảo toàn tỉ lệ gốc, không bị kéo giãn)
			var tex: Texture2D = _get_cached_item_texture(item.asset_path)
			if tex != null:
				var pad: float = 3.0
				var avail_w: float = rect.size.x - pad * 2.0
				var avail_h: float = rect.size.y - pad * 2.0
				var tex_sz: Vector2 = tex.get_size()
				if tex_sz.x > 0.0 and tex_sz.y > 0.0:
					var scale_f: float = minf(avail_w / tex_sz.x, avail_h / tex_sz.y)
					var drawn_w: float = tex_sz.x * scale_f
					var drawn_h: float = tex_sz.y * scale_f
					var draw_x: float = rect.position.x + pad + (avail_w - drawn_w) * 0.5
					var draw_y: float = rect.position.y + pad + (avail_h - drawn_h) * 0.5
					var draw_r := Rect2(draw_x, draw_y, drawn_w, drawn_h)
					_settlement_grid_draw_control.draw_texture_rect(tex, draw_r, false)
			else:
				# Fallback Item Name (Top-left)
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

			# 2. Tag hiển thị giá trị ở cạnh dưới
			var val_str := "%s Xu" % _format_number(item.silver_value)
			if item.reward_type == "black_ticket":
				val_str = "Vé đen 🎟️"
			elif item.is_resource and item.silver_value == 0:
				val_str = "Tài nguyên"

			var tag_h: float = 14.0
			var tag_rect := Rect2(rect.position.x + 2, rect.position.y + rect.size.y - tag_h - 2, rect.size.x - 4, tag_h)
			_settlement_grid_draw_control.draw_rect(tag_rect, Color(0, 0, 0, 0.75), true)
			var val_pos := Vector2(rect.position.x + 4, rect.position.y + rect.size.y - 4)
			_settlement_grid_draw_control.draw_string(
				font,
				val_pos,
				val_str,
				HORIZONTAL_ALIGNMENT_LEFT,
				rect.size.x - 8,
				9,
				r_color
			)

		elif is_loading:
			# Loading active slot
			var slot_bg := Color(0.18, 0.23, 0.30, 0.95)
			_settlement_grid_draw_control.draw_rect(rect, slot_bg, true)
			_settlement_grid_draw_control.draw_rect(rect, Color(0.85, 0.92, 1.0, 0.8), false, 2.0)
			_draw_running_light_border(_settlement_grid_draw_control, rect, Color(0.95, 0.98, 1.0, 1.0), 2.0, phase_seed)

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


func _on_settlement_grid_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var pos: Vector2 = (event as InputEventMouseMotion).position
		var cell_x := int(pos.x / float(SETTLEMENT_CELL_SIZE))
		var cell_y := int(pos.y / float(SETTLEMENT_CELL_SIZE))
		var hovered_item: ITEM_CLASS = null

		for i_id in _grid_placements:
			var entry: Dictionary = _grid_placements[i_id]
			var p: Vector2i = entry.get("pos") as Vector2i
			var w: int = int(entry.get("w", 1))
			var h: int = int(entry.get("h", 1))
			if cell_x >= p.x and cell_x < p.x + w and cell_y >= p.y and cell_y < p.y + h:
				if _settlement_revealed_item_ids.has(String(i_id)):
					hovered_item = entry.get("item") as ITEM_CLASS
				break

		if hovered_item != null:
			_show_item_hover_popup(hovered_item, _settlement_grid_draw_control.get_global_mouse_position())
		else:
			_current_hovered_item_id = ""
			if _item_hover_popup != null:
				_item_hover_popup.visible = false


func _rarity_badge(rarity: int) -> String:
	match rarity:
		ITEM_CLASS.Rarity.RED: return "🔥 Thần Thoại"
		ITEM_CLASS.Rarity.GOLD: return "⭐ Hoàng Kim"
		ITEM_CLASS.Rarity.PURPLE: return "🔮 Sử Thi"
		ITEM_CLASS.Rarity.BLUE: return "💎 Quý Hiếm"
		ITEM_CLASS.Rarity.GREEN: return "🌿 Đặc Biệt"
		_: return "⚪ Thường"


func _process(delta: float) -> void:
	_border_anim_time += delta
	if _settlement_overlay != null and _settlement_overlay.visible:
		_settlement_spinner_angle = fmod(_settlement_spinner_angle + delta * 8.0, TAU)
		_continue_pulse_time += delta * 4.0
		if _settlement_continue_btn != null and _settlement_continue_btn.visible:
			_settlement_continue_btn.modulate.a = 0.7 + 0.3 * sin(_continue_pulse_time)
		if _settlement_grid_draw_control != null and _settlement_grid_draw_control.is_visible_in_tree():
			_settlement_grid_draw_control.queue_redraw()
	else:
		if visible and _grid_draw_control != null and (_revealed_outlines.size() > 0 or _revealed_qualities.size() > 0 or _revealed_items.size() > 0):
			_grid_draw_control.queue_redraw()


func _on_settlement_overlay_gui_input(_event: InputEvent) -> void:
	# Bấm vô màn hình sẽ không qua phase hay skip gì hết theo yêu cầu người dùng
	pass


func _on_skip_pressed() -> void:
	if _is_settlement_revealing:
		_settlement_skip_requested = true
	else:
		_on_finish_settlement_pressed()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if _numpad_modal != null and _numpad_modal.visible:
				_close_numpad_modal()
				get_viewport().set_input_as_handled()
				return
		if event.keycode == KEY_B:
			if encyclopedia_dialog != null:
				if encyclopedia_dialog.visible:
					encyclopedia_dialog.close_dialog()
				else:
					encyclopedia_dialog.open_dialog()
			get_viewport().set_input_as_handled()
			return


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


# ==============================================================================
# BIDKING-STYLE NUMPAD MODAL (Ảnh 2)
# ==============================================================================

func _build_numpad_modal() -> void:
	_numpad_modal = Control.new()
	_numpad_modal.set_anchors_preset(PRESET_FULL_RECT)
	_numpad_modal.visible = false
	_numpad_modal.mouse_filter = MOUSE_FILTER_STOP
	add_child(_numpad_modal)

	# Semi-transparent dark overlay background
	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(PRESET_FULL_RECT)
	backdrop.color = Color(0.01, 0.02, 0.04, 0.70)
	backdrop.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			_close_numpad_modal()
	)
	_numpad_modal.add_child(backdrop)

	# Modal Dialog Center Container
	var center_wrap := CenterContainer.new()
	center_wrap.set_anchors_preset(PRESET_FULL_RECT)
	center_wrap.mouse_filter = MOUSE_FILTER_PASS
	_numpad_modal.add_child(center_wrap)

	var dialog_box := Control.new()
	dialog_box.custom_minimum_size = Vector2(840, 420)
	center_wrap.add_child(dialog_box)

	var modal_tex := load("res://assets/ui/auction/numpad_modal_frame.png") as Texture2D
	if modal_tex != null:
		var frame_rect := TextureRect.new()
		frame_rect.set_anchors_preset(PRESET_FULL_RECT)
		frame_rect.texture = modal_tex
		frame_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		frame_rect.stretch_mode = TextureRect.STRETCH_SCALE
		frame_rect.mouse_filter = MOUSE_FILTER_PASS
		dialog_box.add_child(frame_rect)
	else:
		var m_flat := PanelContainer.new()
		m_flat.set_anchors_preset(PRESET_FULL_RECT)
		var fb := StyleBoxFlat.new()
		fb.bg_color = Color(0.06, 0.08, 0.12, 0.98)
		fb.border_color = Color("#f6c95c")
		fb.border_width_left = 2
		fb.border_width_top = 2
		fb.border_width_right = 2
		fb.border_width_bottom = 2
		fb.corner_radius_top_left = 12
		fb.corner_radius_top_right = 12
		fb.corner_radius_bottom_left = 12
		fb.corner_radius_bottom_right = 12
		m_flat.add_theme_stylebox_override("panel", fb)
		dialog_box.add_child(m_flat)

	# --- LEFT SIDE: CUSTOM DUAL-COLUMN KEYPAD (Aligned with numpad_modal_frame.png sockets) ---
	var left_box := Control.new()
	left_box.position = Vector2(48, 52)
	left_box.size = Vector2(310, 332)
	dialog_box.add_child(left_box)

	var keypad_hbox := HBoxContainer.new()
	keypad_hbox.set_anchors_preset(PRESET_FULL_RECT)
	keypad_hbox.add_theme_constant_override("separation", 6)
	left_box.add_child(keypad_hbox)

	# Left section: Columns 1 to 3 (stretch ratio 3.0)
	var cols_1_3 := VBoxContainer.new()
	cols_1_3.size_flags_horizontal = SIZE_EXPAND_FILL
	cols_1_3.size_flags_vertical = SIZE_EXPAND_FILL
	cols_1_3.size_flags_stretch_ratio = 3.0
	cols_1_3.add_theme_constant_override("separation", 6)
	keypad_hbox.add_child(cols_1_3)

	# Row 1: 1, 2, 3
	var r1 := HBoxContainer.new()
	r1.size_flags_horizontal = SIZE_EXPAND_FILL
	r1.size_flags_vertical = SIZE_EXPAND_FILL
	r1.add_theme_constant_override("separation", 6)
	cols_1_3.add_child(r1)
	_add_numpad_key(r1, "1", "1")
	_add_numpad_key(r1, "2", "2")
	_add_numpad_key(r1, "3", "3")

	# Row 2: 4, 5, 6
	var r2 := HBoxContainer.new()
	r2.size_flags_horizontal = SIZE_EXPAND_FILL
	r2.size_flags_vertical = SIZE_EXPAND_FILL
	r2.add_theme_constant_override("separation", 6)
	cols_1_3.add_child(r2)
	_add_numpad_key(r2, "4", "4")
	_add_numpad_key(r2, "5", "5")
	_add_numpad_key(r2, "6", "6")

	# Row 3: 7, 8, 9
	var r3 := HBoxContainer.new()
	r3.size_flags_horizontal = SIZE_EXPAND_FILL
	r3.size_flags_vertical = SIZE_EXPAND_FILL
	r3.add_theme_constant_override("separation", 6)
	cols_1_3.add_child(r3)
	_add_numpad_key(r3, "7", "7")
	_add_numpad_key(r3, "8", "8")
	_add_numpad_key(r3, "9", "9")

	# Row 4: "0" (wide, 2 cols), "00" (1 col)
	var r4 := HBoxContainer.new()
	r4.size_flags_horizontal = SIZE_EXPAND_FILL
	r4.size_flags_vertical = SIZE_EXPAND_FILL
	r4.add_theme_constant_override("separation", 6)
	cols_1_3.add_child(r4)
	var k0 := _add_numpad_key(r4, "0", "0")
	k0.size_flags_stretch_ratio = 2.05
	var k00 := _add_numpad_key(r4, "00", "00")
	k00.size_flags_stretch_ratio = 1.0

	# Right section: Column 4 (stretch ratio 1.0)
	var col_4 := VBoxContainer.new()
	col_4.size_flags_horizontal = SIZE_EXPAND_FILL
	col_4.size_flags_vertical = SIZE_EXPAND_FILL
	col_4.size_flags_stretch_ratio = 1.0
	col_4.add_theme_constant_override("separation", 6)
	keypad_hbox.add_child(col_4)

	# Row 1, Col 4: Backspace
	var k_del := _add_numpad_key(col_4, "⌫", "backspace", Color("#ff79c6"), 20)
	k_del.size_flags_stretch_ratio = 1.0

	# Row 2, Col 4: Multiplier
	_numpad_multiplier_btn = _add_numpad_key(col_4, "x2.0", "multiplier", Color("#f1fa8c"), 17)
	_numpad_multiplier_btn.size_flags_stretch_ratio = 1.0

	# Rows 3-4, Col 4: Tall "Giá Trước" button (spans rows 3 and 4)
	var k_prev := _add_numpad_key(col_4, "Giá\nTrước", "prev_bid", Color("#8be9fd"), 13)
	k_prev.size_flags_stretch_ratio = 2.08
	k_prev.tooltip_text = "Lấy lại mức giá vòng trước của bạn"

	# --- RIGHT SIDE: CONSOLE & ACTIONS (Aligned within right compartment) ---
	var right_console := VBoxContainer.new()
	right_console.position = Vector2(412, 52)
	right_console.size = Vector2(386, 332)
	right_console.add_theme_constant_override("separation", 12)
	dialog_box.add_child(right_console)

	# Warning notice box
	var warn_panel := PanelContainer.new()
	var wp_style := StyleBoxFlat.new()
	wp_style.bg_color = Color(0.08, 0.11, 0.16, 0.85)
	wp_style.border_color = Color(0.85, 0.70, 0.20, 0.6)
	wp_style.border_width_left = 1
	wp_style.border_width_top = 1
	wp_style.border_width_right = 1
	wp_style.border_width_bottom = 1
	wp_style.corner_radius_top_left = 6
	wp_style.corner_radius_top_right = 6
	wp_style.corner_radius_bottom_left = 6
	wp_style.corner_radius_bottom_right = 6
	warn_panel.add_theme_stylebox_override("panel", wp_style)
	right_console.add_child(warn_panel)

	var warn_margin := MarginContainer.new()
	warn_margin.add_theme_constant_override("margin_left", 12)
	warn_margin.add_theme_constant_override("margin_top", 8)
	warn_margin.add_theme_constant_override("margin_right", 12)
	warn_margin.add_theme_constant_override("margin_bottom", 8)
	warn_panel.add_child(warn_margin)

	_numpad_warning_lbl = Label.new()
	_numpad_warning_lbl.text = "⚠️ Chú ý: Nếu giá cao hơn 2.0 lần so với người thứ hai thì sẽ đoạt hòm ngay!"
	_numpad_warning_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_numpad_warning_lbl.add_theme_font_size_override("font_size", 12)
	_numpad_warning_lbl.add_theme_color_override("font_color", Color("#f1fa8c"))
	warn_margin.add_child(_numpad_warning_lbl)

	# LCD Display panel
	var lcd_panel := PanelContainer.new()
	var lcd_style := StyleBoxFlat.new()
	lcd_style.bg_color = Color(0.03, 0.05, 0.08, 0.95)
	lcd_style.border_color = Color(0.25, 0.55, 0.75, 0.7)
	lcd_style.border_width_left = 1
	lcd_style.border_width_top = 1
	lcd_style.border_width_right = 1
	lcd_style.border_width_bottom = 1
	lcd_style.corner_radius_top_left = 8
	lcd_style.corner_radius_top_right = 8
	lcd_style.corner_radius_bottom_left = 8
	lcd_style.corner_radius_bottom_right = 8
	lcd_panel.add_theme_stylebox_override("panel", lcd_style)
	right_console.add_child(lcd_panel)

	var lcd_margin := MarginContainer.new()
	lcd_margin.add_theme_constant_override("margin_left", 14)
	lcd_margin.add_theme_constant_override("margin_top", 10)
	lcd_margin.add_theme_constant_override("margin_right", 14)
	lcd_margin.add_theme_constant_override("margin_bottom", 10)
	lcd_panel.add_child(lcd_margin)

	var lcd_vbox := VBoxContainer.new()
	lcd_vbox.add_theme_constant_override("separation", 4)
	lcd_margin.add_child(lcd_vbox)

	var prompt_lbl := Label.new()
	prompt_lbl.text = "Số tiền đấu giá (Xu Bạc):"
	prompt_lbl.add_theme_font_size_override("font_size", 12)
	prompt_lbl.add_theme_color_override("font_color", Color("#8be9fd"))
	lcd_vbox.add_child(prompt_lbl)

	_numpad_input_display = Label.new()
	_numpad_input_display.text = "0 Xu"
	_numpad_input_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_numpad_input_display.add_theme_font_size_override("font_size", 26)
	_numpad_input_display.add_theme_color_override("font_color", Color("#f6c95c"))
	lcd_vbox.add_child(_numpad_input_display)

	var spacer_rc := Control.new()
	spacer_rc.size_flags_vertical = SIZE_EXPAND_FILL
	right_console.add_child(spacer_rc)

	# Bottom Action Buttons in Numpad (Real Assets: btn_place_bid.png and btn_cancel.png)
	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 14)
	right_console.add_child(action_row)

	var confirm_btn := Button.new()
	confirm_btn.text = "XÁC NHẬN RA GIÁ"
	confirm_btn.size_flags_horizontal = SIZE_EXPAND_FILL
	confirm_btn.custom_minimum_size = Vector2(200, 48)
	confirm_btn.focus_mode = FOCUS_NONE
	confirm_btn.add_theme_font_size_override("font_size", 16)
	confirm_btn.add_theme_color_override("font_color", Color("#261403"))
	confirm_btn.add_theme_color_override("font_hover_color", Color("#000000"))
	confirm_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var cf_tex := load("res://assets/ui/auction/btn_place_bid.png") as Texture2D
	if cf_tex != null:
		var cf_sb := StyleBoxTexture.new()
		cf_sb.texture = cf_tex
		cf_sb.texture_margin_left = 40
		cf_sb.texture_margin_right = 40
		cf_sb.texture_margin_top = 10
		cf_sb.texture_margin_bottom = 10
		cf_sb.content_margin_top = 8
		cf_sb.content_margin_bottom = 8
		confirm_btn.add_theme_stylebox_override("normal", cf_sb)
		var cf_hover := cf_sb.duplicate() as StyleBoxTexture
		cf_hover.modulate_color = Color(1.15, 1.15, 1.15, 1.0)
		confirm_btn.add_theme_stylebox_override("hover", cf_hover)
		var cf_press := cf_sb.duplicate() as StyleBoxTexture
		cf_press.modulate_color = Color(0.85, 0.85, 0.85, 1.0)
		confirm_btn.add_theme_stylebox_override("pressed", cf_press)
	else:
		var cf_style := StyleBoxFlat.new()
		cf_style.bg_color = Color("#f6c95c")
		cf_style.corner_radius_top_left = 6
		cf_style.corner_radius_top_right = 6
		cf_style.corner_radius_bottom_left = 6
		cf_style.corner_radius_bottom_right = 6
		confirm_btn.add_theme_stylebox_override("normal", cf_style)

	confirm_btn.pressed.connect(func() -> void:
		_bid_input.text = _numpad_current_str
		_close_numpad_modal()
		_on_confirm_bid_pressed()
	)
	action_row.add_child(confirm_btn)

	var close_btn := Button.new()
	close_btn.text = ""
	close_btn.tooltip_text = "Hủy & Đóng bàn phím"
	close_btn.custom_minimum_size = Vector2(48, 48)
	close_btn.focus_mode = FOCUS_NONE
	close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var cl_tex := load("res://assets/ui/auction/btn_cancel.png") as Texture2D
	if cl_tex != null:
		var cl_sb := StyleBoxTexture.new()
		cl_sb.texture = cl_tex
		close_btn.add_theme_stylebox_override("normal", cl_sb)
		var cl_hover := cl_sb.duplicate() as StyleBoxTexture
		cl_hover.modulate_color = Color(1.15, 1.15, 1.15, 1.0)
		close_btn.add_theme_stylebox_override("hover", cl_hover)
		var cl_press := cl_sb.duplicate() as StyleBoxTexture
		cl_press.modulate_color = Color(0.85, 0.85, 0.85, 1.0)
		close_btn.add_theme_stylebox_override("pressed", cl_press)
	else:
		close_btn.text = "❌"
		var cl_style := StyleBoxFlat.new()
		cl_style.bg_color = Color(0.85, 0.25, 0.25, 0.9)
		cl_style.corner_radius_top_left = 6
		cl_style.corner_radius_top_right = 6
		cl_style.corner_radius_bottom_left = 6
		cl_style.corner_radius_bottom_right = 6
		close_btn.add_theme_stylebox_override("normal", cl_style)

	close_btn.pressed.connect(_close_numpad_modal)
	action_row.add_child(close_btn)


func _add_numpad_key(parent: Control, label_text: String, action_id: String, font_col: Color = Color("#f0e6d2"), font_sz: int = 20) -> Button:
	var btn := Button.new()
	btn.text = label_text
	btn.size_flags_horizontal = SIZE_EXPAND_FILL
	btn.size_flags_vertical = SIZE_EXPAND_FILL
	btn.focus_mode = FOCUS_NONE
	btn.add_theme_font_size_override("font_size", font_sz)
	btn.add_theme_color_override("font_color", font_col)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color("#f6c95c"))
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	# Transparent stylebox so the 3D metal sockets in numpad_modal_frame.png show directly
	var empty_sb := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty_sb)
	btn.add_theme_stylebox_override("focus", empty_sb)

	var sb_hover := StyleBoxFlat.new()
	sb_hover.bg_color = Color(1.0, 1.0, 1.0, 0.08)
	sb_hover.corner_radius_top_left = 6
	sb_hover.corner_radius_top_right = 6
	sb_hover.corner_radius_bottom_left = 6
	sb_hover.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("hover", sb_hover)

	var sb_pressed := StyleBoxFlat.new()
	sb_pressed.bg_color = Color(0.0, 0.0, 0.0, 0.25)
	sb_pressed.corner_radius_top_left = 6
	sb_pressed.corner_radius_top_right = 6
	sb_pressed.corner_radius_bottom_left = 6
	sb_pressed.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("pressed", sb_pressed)

	btn.pressed.connect(func() -> void: _handle_numpad_action(action_id))
	parent.add_child(btn)
	return btn


func _build_bag_modal() -> void:
	_bag_modal = Control.new()
	_bag_modal.set_anchors_preset(PRESET_FULL_RECT)
	_bag_modal.visible = false
	_bag_modal.mouse_filter = MOUSE_FILTER_STOP
	add_child(_bag_modal)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(PRESET_FULL_RECT)
	backdrop.color = Color(0.01, 0.02, 0.04, 0.75)
	backdrop.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			_close_bag_modal()
	)
	_bag_modal.add_child(backdrop)

	var center_wrap := CenterContainer.new()
	center_wrap.set_anchors_preset(PRESET_FULL_RECT)
	center_wrap.mouse_filter = MOUSE_FILTER_PASS
	_bag_modal.add_child(center_wrap)

	var dialog_box := PanelContainer.new()
	dialog_box.custom_minimum_size = Vector2(500, 320)
	var d_style := StyleBoxFlat.new()
	d_style.bg_color = Color(0.06, 0.09, 0.14, 0.98)
	d_style.border_color = Color("#f6c95c")
	d_style.border_width_left = 2
	d_style.border_width_top = 2
	d_style.border_width_right = 2
	d_style.border_width_bottom = 2
	d_style.corner_radius_top_left = 10
	d_style.corner_radius_top_right = 10
	d_style.corner_radius_bottom_left = 10
	d_style.corner_radius_bottom_right = 10
	dialog_box.add_theme_stylebox_override("panel", d_style)
	center_wrap.add_child(dialog_box)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 20)
	dialog_box.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = "🎒 HÀNH TRANG & TÀI CHÍNH CÁ NHÂN"
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color("#f6c95c"))
	vbox.add_child(title_lbl)

	_bag_modal_title = Label.new()
	_bag_modal_title.text = "Người chơi: ..."
	_bag_modal_title.add_theme_font_size_override("font_size", 14)
	_bag_modal_title.add_theme_color_override("font_color", Color("#8be9fd"))
	vbox.add_child(_bag_modal_title)

	var bal_panel := PanelContainer.new()
	var bp_style := StyleBoxFlat.new()
	bp_style.bg_color = Color(0.12, 0.18, 0.25, 0.9)
	bp_style.border_color = Color("#50fa7b")
	bp_style.border_width_left = 1
	bp_style.border_width_top = 1
	bp_style.border_width_right = 1
	bp_style.border_width_bottom = 1
	bp_style.corner_radius_top_left = 6
	bp_style.corner_radius_top_right = 6
	bp_style.corner_radius_bottom_left = 6
	bp_style.corner_radius_bottom_right = 6
	bal_panel.add_theme_stylebox_override("panel", bp_style)
	vbox.add_child(bal_panel)

	var bal_margin := MarginContainer.new()
	bal_margin.add_theme_constant_override("margin_left", 14)
	bal_margin.add_theme_constant_override("margin_top", 10)
	bal_margin.add_theme_constant_override("margin_right", 14)
	bal_margin.add_theme_constant_override("margin_bottom", 10)
	bal_panel.add_child(bal_margin)

	_bag_modal_bal = Label.new()
	_bag_modal_bal.text = "🪙 Số dư Xu Bạc: 0 Xu"
	_bag_modal_bal.add_theme_font_size_override("font_size", 20)
	_bag_modal_bal.add_theme_color_override("font_color", Color("#50fa7b"))
	bal_margin.add_child(_bag_modal_bal)

	var hint_lbl := Label.new()
	hint_lbl.text = "ℹ️ Số dư của bạn được giữ bí mật với các người chơi khác trên bàn đấu giá."
	hint_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_lbl.add_theme_font_size_override("font_size", 12)
	hint_lbl.add_theme_color_override("font_color", Color("#94a3b8"))
	vbox.add_child(hint_lbl)

	var sp := Control.new()
	sp.size_flags_vertical = SIZE_EXPAND_FILL
	vbox.add_child(sp)

	var close_btn := Button.new()
	close_btn.text = "Đóng"
	close_btn.custom_minimum_size = Vector2(120, 38)
	close_btn.size_flags_horizontal = SIZE_SHRINK_CENTER
	close_btn.focus_mode = FOCUS_NONE
	var c_style := StyleBoxFlat.new()
	c_style.bg_color = Color(0.2, 0.28, 0.38, 0.9)
	c_style.border_color = Color(0.4, 0.5, 0.6, 0.7)
	c_style.corner_radius_top_left = 6
	c_style.corner_radius_top_right = 6
	c_style.corner_radius_bottom_left = 6
	c_style.corner_radius_bottom_right = 6
	close_btn.add_theme_stylebox_override("normal", c_style)
	close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	close_btn.pressed.connect(_close_bag_modal)
	vbox.add_child(close_btn)


func _open_bag_modal() -> void:
	if _bag_modal == null:
		return
	var curr_pid := _get_current_turn_player_id()
	var bal: int = int(player_silver_balances.get(curr_pid, 0))
	if _bag_modal_title != null:
		_bag_modal_title.text = "👤 Lượt hiện tại: %s" % String(curr_pid)
	if _bag_modal_bal != null:
		_bag_modal_bal.text = "🪙 Số dư Xu Bạc: %s Xu" % _format_number(bal)
	_bag_modal.visible = true


func _close_bag_modal() -> void:
	if _bag_modal != null:
		_bag_modal.visible = false


func _handle_numpad_action(action_id: String) -> void:
	match action_id:
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
			if _numpad_current_str == "0":
				_numpad_current_str = action_id
			elif _numpad_current_str.length() < 9:
				_numpad_current_str += action_id
		"00":
			if _numpad_current_str != "0" and _numpad_current_str.length() < 8:
				_numpad_current_str += "00"
		"backspace":
			if _numpad_current_str.length() > 1:
				_numpad_current_str = _numpad_current_str.substr(0, _numpad_current_str.length() - 1)
			else:
				_numpad_current_str = "0"
		"prev_bid":
			var curr_pid := _get_current_turn_player_id()
			var prev: int = 0
			if auction_session != null and auction_session.current_round > 1:
				prev = auction_session.get_player_bid_in_round(curr_pid, auction_session.current_round - 1)
			if prev <= 0 and auction_session != null and not auction_session.rounds_bids_history.is_empty():
				var last_dict: Dictionary = auction_session.rounds_bids_history.back()
				prev = int(last_dict.get(curr_pid, 0))
			_numpad_current_str = str(maxi(0, prev))
		"multiplier":
			var ratio: float = 2.0
			if auction_session != null and AUCTION_SESSION_CLASS.KNOCKOUT_RATIOS.has(auction_session.current_round):
				ratio = float(AUCTION_SESSION_CLASS.KNOCKOUT_RATIOS[auction_session.current_round])
			var curr_val: int = _numpad_current_str.to_int()
			if curr_val <= 0:
				curr_val = 10
			var target_bid := int(ceil(float(curr_val) * ratio))
			var curr_pid := _get_current_turn_player_id()
			var max_bal: int = int(player_silver_balances.get(curr_pid, target_bid))
			target_bid = mini(target_bid, max_bal)
			_numpad_current_str = str(maxi(1, target_bid))

	if _bid_input != null:
		_bid_input.text = _numpad_current_str
	_refresh_numpad_display()


func _refresh_numpad_display() -> void:
	if _numpad_input_display == null:
		return
	_numpad_input_display.text = "%s Xu" % _format_number(_numpad_current_str.to_int())


func _open_numpad_modal() -> void:
	if _numpad_modal == null:
		return
	_numpad_modal.visible = true
	_numpad_current_str = _bid_input.text if _bid_input != null and not _bid_input.text.is_empty() else "0"
	var ratio: float = 2.0
	if auction_session != null and AUCTION_SESSION_CLASS.KNOCKOUT_RATIOS.has(auction_session.current_round):
		ratio = float(AUCTION_SESSION_CLASS.KNOCKOUT_RATIOS[auction_session.current_round])
	if _numpad_multiplier_btn != null:
		_numpad_multiplier_btn.text = "x%.1f" % ratio
	if _numpad_warning_lbl != null:
		_numpad_warning_lbl.text = "⚠️ Chú ý: Nếu giá cao hơn %.1f lần so với người thứ hai thì sẽ đoạt hòm ngay!" % ratio
	_refresh_numpad_display()


func _close_numpad_modal() -> void:
	if _numpad_modal != null:
		_numpad_modal.visible = false
