class_name AuctionScreen
extends Control

signal auction_finished(settlement_data: Dictionary)

const AUCTION_SESSION_CLASS := preload("res://scripts/domain/loot/AuctionSession.gd")
const CHEST_STATE_CLASS := preload("res://scripts/domain/loot/MysteryChestState.gd")
const ITEM_CLASS := preload("res://scripts/domain/loot/MysteryChestItem.gd")

var auction_session: AuctionSession
var player_silver_balances: Dictionary = {} # player_id -> int

# UI Nodes created programmatically to avoid scene coupling and guarantee zero broken paths
var overlay_panel: PanelContainer
var header_title: Label
var round_badge: Label
var hint_scroll: ScrollContainer
var hint_container: VBoxContainer
var chest_visual_container: PanelContainer
var grid_display: GridContainer
var current_bid_label: Label
var controls_container: HBoxContainer
var solo_panel: VBoxContainer
var multi_panel: VBoxContainer
var bid_spin_box: SpinBox
var place_bid_btn: Button
var fold_btn: Button
var advance_btn: Button
var solo_buy_btn: Button
var solo_pass_btn: Button
var settlement_dialog: PanelContainer


func _init() -> void:
	name = "AuctionScreen"
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_STOP


func _ready() -> void:
	_build_ui()
	if auction_session != null:
		refresh_ui()


func setup(session: AuctionSession, player_silvers: Dictionary = {}) -> void:
	auction_session = session
	player_silver_balances = player_silvers.duplicate()
	if is_inside_tree():
		refresh_ui()


func _build_ui() -> void:
	# 1. Dark semi-transparent background
	var bg := ColorRect.new()
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.05, 0.07, 0.92)
	add_child(bg)

	# 2. Main Center Frame
	var center := CenterContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	add_child(center)

	overlay_panel = PanelContainer.new()
	overlay_panel.custom_minimum_size = Vector2(960, 620)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.09, 0.1, 0.13, 0.98)
	panel_style.border_color = Color(0.85, 0.72, 0.32, 0.95)
	panel_style.border_width_bottom = 3
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.corner_radius_bottom_left = 12
	panel_style.corner_radius_bottom_right = 12
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.shadow_color = Color(0, 0, 0, 0.6)
	panel_style.shadow_size = 18
	overlay_panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(overlay_panel)

	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_preset(PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 14)
	overlay_panel.add_child(main_vbox)

	# --- Header Bar ---
	var header_bar := HBoxContainer.new()
	main_vbox.add_child(header_bar)

	header_title = Label.new()
	header_title.text = "👑 ĐẤU GIÁ KHO BÁU HOÀNG GIA"
	header_title.add_theme_font_size_override("font_size", 22)
	header_title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35))
	header_bar.add_child(header_title)

	var spacer := Control.new()
	spacer.size_flags_horizontal = SIZE_EXPAND_FILL
	header_bar.add_child(spacer)

	round_badge = Label.new()
	round_badge.text = "VÒNG 1 / 5"
	round_badge.add_theme_font_size_override("font_size", 16)
	round_badge.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	header_bar.add_child(round_badge)

	# --- Main Body Split (Left: Hints, Right: Chest Visuals) ---
	var body_split := HBoxContainer.new()
	body_split.size_flags_vertical = SIZE_EXPAND_FILL
	body_split.add_theme_constant_override("separation", 20)
	main_vbox.add_child(body_split)

	# Left: Hints & Clues Panel
	var left_vbox := VBoxContainer.new()
	left_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	left_vbox.size_flags_stretch_ratio = 1.1
	body_split.add_child(left_vbox)

	var hint_heading := Label.new()
	hint_heading.text = "📜 MANH MỐI ĐÃ CÔNG BỐ"
	hint_heading.add_theme_font_size_override("font_size", 15)
	hint_heading.add_theme_color_override("font_color", Color(0.9, 0.82, 0.6))
	left_vbox.add_child(hint_heading)

	hint_scroll = ScrollContainer.new()
	hint_scroll.size_flags_vertical = SIZE_EXPAND_FILL
	left_vbox.add_child(hint_scroll)

	hint_container = VBoxContainer.new()
	hint_container.size_flags_horizontal = SIZE_EXPAND_FILL
	hint_container.add_theme_constant_override("separation", 10)
	hint_scroll.add_child(hint_container)

	# Right: Chest Visualizer
	var right_vbox := VBoxContainer.new()
	right_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	right_vbox.size_flags_stretch_ratio = 1.0
	body_split.add_child(right_vbox)

	var chest_heading := Label.new()
	chest_heading.text = "🧰 HÌNH ẢNH HÒM BÍ ẨN"
	chest_heading.add_theme_font_size_override("font_size", 15)
	chest_heading.add_theme_color_override("font_color", Color(0.9, 0.82, 0.6))
	right_vbox.add_child(chest_heading)

	chest_visual_container = PanelContainer.new()
	chest_visual_container.size_flags_vertical = SIZE_EXPAND_FILL
	var chest_style := StyleBoxFlat.new()
	chest_style.bg_color = Color(0.06, 0.07, 0.09, 0.95)
	chest_style.border_color = Color(0.4, 0.35, 0.25)
	chest_style.border_width_bottom = 2
	chest_style.border_width_left = 2
	chest_style.border_width_right = 2
	chest_style.border_width_top = 2
	chest_style.corner_radius_bottom_left = 8
	chest_style.corner_radius_bottom_right = 8
	chest_style.corner_radius_top_left = 8
	chest_style.corner_radius_top_right = 8
	chest_visual_container.add_theme_stylebox_override("panel", chest_style)
	right_vbox.add_child(chest_visual_container)

	var scroll_grid := ScrollContainer.new()
	scroll_grid.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll_grid.size_flags_vertical = SIZE_EXPAND_FILL
	chest_visual_container.add_child(scroll_grid)

	grid_display = GridContainer.new()
	grid_display.columns = 4
	grid_display.add_theme_constant_override("h_separation", 8)
	grid_display.add_theme_constant_override("v_separation", 8)
	scroll_grid.add_child(grid_display)

	# --- Bottom Control & Bidding Bar ---
	var bottom_panel := PanelContainer.new()
	var b_style := StyleBoxFlat.new()
	b_style.bg_color = Color(0.05, 0.06, 0.08, 0.9)
	b_style.corner_radius_bottom_left = 8
	b_style.corner_radius_bottom_right = 8
	b_style.corner_radius_top_left = 8
	b_style.corner_radius_top_right = 8
	bottom_panel.add_theme_stylebox_override("panel", b_style)
	main_vbox.add_child(bottom_panel)

	controls_container = HBoxContainer.new()
	controls_container.add_theme_constant_override("separation", 16)
	bottom_panel.add_child(controls_container)

	current_bid_label = Label.new()
	current_bid_label.text = "Giá cao nhất: 0 Xu Bạc"
	current_bid_label.add_theme_font_size_override("font_size", 16)
	current_bid_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	controls_container.add_child(current_bid_label)

	var b_spacer := Control.new()
	b_spacer.size_flags_horizontal = SIZE_EXPAND_FILL
	controls_container.add_child(b_spacer)

	# Solo Controls
	solo_panel = VBoxContainer.new()
	solo_panel.visible = false
	var solo_btn_row := HBoxContainer.new()
	solo_btn_row.add_theme_constant_override("separation", 12)
	solo_panel.add_child(solo_btn_row)

	solo_buy_btn = Button.new()
	solo_buy_btn.text = "💰 Mua Hòm (0 Xu)"
	solo_buy_btn.custom_minimum_size = Vector2(160, 40)
	solo_buy_btn.pressed.connect(_on_solo_buy_pressed)
	solo_btn_row.add_child(solo_buy_btn)

	solo_pass_btn = Button.new()
	solo_pass_btn.text = "❌ Bỏ Qua"
	solo_pass_btn.custom_minimum_size = Vector2(120, 40)
	solo_pass_btn.pressed.connect(_on_solo_pass_pressed)
	solo_btn_row.add_child(solo_pass_btn)
	controls_container.add_child(solo_panel)

	# Multiplayer Controls
	multi_panel = VBoxContainer.new()
	multi_panel.visible = false
	var multi_btn_row := HBoxContainer.new()
	multi_btn_row.add_theme_constant_override("separation", 10)
	multi_panel.add_child(multi_btn_row)

	bid_spin_box = SpinBox.new()
	bid_spin_box.min_value = 1
	bid_spin_box.max_value = 9999
	bid_spin_box.value = 10
	bid_spin_box.custom_minimum_size = Vector2(110, 36)
	multi_btn_row.add_child(bid_spin_box)

	place_bid_btn = Button.new()
	place_bid_btn.text = "⚡ Đặt Giá"
	place_bid_btn.custom_minimum_size = Vector2(110, 36)
	place_bid_btn.pressed.connect(_on_place_bid_pressed)
	multi_btn_row.add_child(place_bid_btn)

	fold_btn = Button.new()
	fold_btn.text = "🏳️ Bỏ Cuộc"
	fold_btn.custom_minimum_size = Vector2(100, 36)
	fold_btn.pressed.connect(_on_fold_pressed)
	multi_btn_row.add_child(fold_btn)

	advance_btn = Button.new()
	advance_btn.text = "▶ Vòng Kế"
	advance_btn.custom_minimum_size = Vector2(100, 36)
	advance_btn.pressed.connect(_on_advance_pressed)
	multi_btn_row.add_child(advance_btn)
	controls_container.add_child(multi_panel)


func refresh_ui() -> void:
	if auction_session == null:
		return

	# Cập nhật round badge
	if auction_session.is_solo():
		round_badge.text = "CHẾ ĐỘ MUA BÁN CÁ NHÂN"
		solo_panel.visible = true
		multi_panel.visible = false
		current_bid_label.text = "Giá đề nghị bí ẩn: %d Xu Bạc" % auction_session.solo_offer_price
		solo_buy_btn.text = "💰 Mua Hòm (%d Xu)" % auction_session.solo_offer_price
	else:
		round_badge.text = "VÒNG %d / %d" % [auction_session.current_round, AUCTION_SESSION_CLASS.MAX_ROUNDS]
		solo_panel.visible = false
		multi_panel.visible = true
		var leader: String = String(auction_session.highest_bidder_id) if not auction_session.highest_bidder_id.is_empty() else "Chưa có"
		current_bid_label.text = "Giá cao nhất: %d Xu Bạc (Người dẫn: %s)" % [auction_session.highest_bid, leader]
		bid_spin_box.min_value = auction_session.highest_bid + 5
		bid_spin_box.value = auction_session.highest_bid + 10

	# Cập nhật manh mối
	_render_hints()

	# Cập nhật hiển thị vật phẩm trong hòm
	_render_chest_visuals()

	# Nếu đã kết thúc
	if auction_session.state == AUCTION_SESSION_CLASS.State.COMPLETED or auction_session.state == AUCTION_SESSION_CLASS.State.CANCELLED:
		_show_settlement_dialog()


func _render_hints() -> void:
	for child in hint_container.get_children():
		child.queue_free()

	for i in range(auction_session.hints_history.size()):
		var h: Dictionary = auction_session.hints_history[i]
		var card := PanelContainer.new()
		var card_style := StyleBoxFlat.new()
		var is_latest: bool = (i == auction_session.hints_history.size() - 1)

		card_style.bg_color = Color(0.12, 0.14, 0.18, 0.95) if is_latest else Color(0.08, 0.09, 0.11, 0.8)
		card_style.border_color = Color(1.0, 0.84, 0.3) if is_latest else Color(0.3, 0.35, 0.4)
		card_style.border_width_bottom = 1
		card_style.border_width_left = 3 if is_latest else 1
		card_style.border_width_right = 1
		card_style.border_width_top = 1
		card_style.corner_radius_bottom_left = 6
		card_style.corner_radius_bottom_right = 6
		card_style.corner_radius_top_left = 6
		card_style.corner_radius_top_right = 6
		card.add_theme_stylebox_override("panel", card_style)

		var card_vbox := VBoxContainer.new()
		card.add_child(card_vbox)

		var title_lbl := Label.new()
		title_lbl.text = "• [%s] %s" % [h.get("phase", "Manh Mối"), h.get("title", "")]
		title_lbl.add_theme_font_size_override("font_size", 13)
		title_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.4) if is_latest else Color(0.8, 0.85, 0.9))
		card_vbox.add_child(title_lbl)

		var desc_lbl := Label.new()
		desc_lbl.text = h.get("description", "")
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.add_theme_font_size_override("font_size", 12)
		desc_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		card_vbox.add_child(desc_lbl)

		hint_container.add_child(card)


func _render_chest_visuals() -> void:
	for child in grid_display.get_children():
		child.queue_free()

	# Gom tất cả các thông tin đã được lộ diện qua các manh mối
	var revealed_items_map: Dictionary = {} # index -> item dict
	var revealed_outlines_map: Dictionary = {}
	var revealed_qualities_map: Dictionary = {}

	for h: Dictionary in auction_session.hints_history:
		var items_rev: Array = h.get("revealed_items", [])
		for idx in range(items_rev.size()):
			revealed_items_map[idx] = items_rev[idx]

		var outlines: Array = h.get("revealed_outlines", [])
		for idx in range(outlines.size()):
			revealed_outlines_map[idx] = outlines[idx]

		var quals: Array = h.get("revealed_qualities", [])
		for idx in range(quals.size()):
			revealed_qualities_map[idx] = quals[idx]

	var total_items: int = auction_session.mystery_chest.items.size()
	if total_items == 0:
		var empty_lbl := Label.new()
		empty_lbl.text = "Hòm Bí Ẩn đang trống..."
		empty_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		grid_display.add_child(empty_lbl)
		return

	for idx in range(total_items):
		var tile := PanelContainer.new()
		tile.custom_minimum_size = Vector2(90, 90)
		var t_style := StyleBoxFlat.new()
		t_style.corner_radius_bottom_left = 6
		t_style.corner_radius_bottom_right = 6
		t_style.corner_radius_top_left = 6
		t_style.corner_radius_top_right = 6

		var vbox := VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		tile.add_child(vbox)

		if revealed_items_map.has(idx):
			# Lộ hoàn toàn item
			var it_data: Dictionary = revealed_items_map[idx]
			var rarity_enum: MysteryChestItem.Rarity = it_data.get("rarity", 0) as MysteryChestItem.Rarity
			var col: Color = MysteryChestItem.rarity_color(rarity_enum)
			t_style.bg_color = Color(col.r * 0.25, col.g * 0.25, col.b * 0.25, 0.9)
			t_style.border_color = col
			t_style.border_width_bottom = 2
			t_style.border_width_left = 2
			t_style.border_width_right = 2
			t_style.border_width_top = 2

			var icon_lbl := Label.new()
			icon_lbl.text = it_data.get("icon", "📦")
			icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			icon_lbl.add_theme_font_size_override("font_size", 22)
			vbox.add_child(icon_lbl)

			var name_lbl := Label.new()
			name_lbl.text = it_data.get("display_name", "")
			name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			name_lbl.add_theme_font_size_override("font_size", 10)
			name_lbl.add_theme_color_override("font_color", col)
			vbox.add_child(name_lbl)
		elif revealed_qualities_map.has(idx):
			# Lộ phẩm cấp 1x1
			var rarity_enum: MysteryChestItem.Rarity = revealed_qualities_map[idx] as MysteryChestItem.Rarity
			var col: Color = MysteryChestItem.rarity_color(rarity_enum)
			t_style.bg_color = Color(col.r * 0.3, col.g * 0.3, col.b * 0.3, 0.95)
			t_style.border_color = col
			t_style.border_width_bottom = 2
			t_style.border_width_left = 2
			t_style.border_width_right = 2
			t_style.border_width_top = 2

			var qual_lbl := Label.new()
			qual_lbl.text = MysteryChestItem.rarity_name(rarity_enum)
			qual_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			qual_lbl.add_theme_font_size_override("font_size", 11)
			qual_lbl.add_theme_color_override("font_color", col)
			vbox.add_child(qual_lbl)
		elif revealed_outlines_map.has(idx):
			# Lộ viền kích cỡ
			var outline_data: Dictionary = revealed_outlines_map[idx]
			t_style.bg_color = Color(0.1, 0.12, 0.15, 0.85)
			t_style.border_color = Color(1.0, 1.0, 1.0, 0.8)
			t_style.border_width_bottom = 2
			t_style.border_width_left = 2
			t_style.border_width_right = 2
			t_style.border_width_top = 2

			var outline_lbl := Label.new()
			outline_lbl.text = "Viền: %dx%d" % [outline_data.get("width", 1), outline_data.get("height", 1)]
			outline_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			outline_lbl.add_theme_font_size_override("font_size", 11)
			outline_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
			vbox.add_child(outline_lbl)
		else:
			# Chưa lộ
			t_style.bg_color = Color(0.08, 0.09, 0.11, 0.8)
			t_style.border_color = Color(0.2, 0.22, 0.26)
			t_style.border_width_bottom = 1
			t_style.border_width_left = 1
			t_style.border_width_right = 1
			t_style.border_width_top = 1

			var secret_lbl := Label.new()
			secret_lbl.text = "❓"
			secret_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			secret_lbl.add_theme_font_size_override("font_size", 20)
			vbox.add_child(secret_lbl)

		tile.add_theme_stylebox_override("panel", t_style)
		grid_display.add_child(tile)


func _on_solo_buy_pressed() -> void:
	if auction_session == null or not auction_session.is_solo():
		return
	var player_id: StringName = auction_session.eligible_player_ids[0]
	var current_silver: int = int(player_silver_balances.get(player_id, 9999))
	auction_session.accept_solo_offer(player_id, current_silver)
	refresh_ui()


func _on_solo_pass_pressed() -> void:
	if auction_session == null or not auction_session.is_solo():
		return
	var player_id: StringName = auction_session.eligible_player_ids[0]
	auction_session.decline_solo_offer(player_id)
	refresh_ui()


func _on_place_bid_pressed() -> void:
	if auction_session == null:
		return
	var bidder: StringName = auction_session.active_bidder_ids[0] if not auction_session.active_bidder_ids.is_empty() else &""
	if bidder.is_empty():
		return
	var amount: int = int(bid_spin_box.value)
	if auction_session.place_bid(bidder, amount):
		refresh_ui()


func _on_fold_pressed() -> void:
	if auction_session == null:
		return
	var bidder: StringName = auction_session.active_bidder_ids[0] if not auction_session.active_bidder_ids.is_empty() else &""
	if not bidder.is_empty():
		auction_session.fold(bidder)
		refresh_ui()


func _on_advance_pressed() -> void:
	if auction_session == null:
		return
	auction_session.advance_round()
	refresh_ui()


func _show_settlement_dialog() -> void:
	if settlement_dialog != null:
		return

	var summary: Dictionary = auction_session.settlement_summary()
	settlement_dialog = PanelContainer.new()
	settlement_dialog.set_anchors_preset(PRESET_CENTER)
	settlement_dialog.custom_minimum_size = Vector2(550, 420)

	var s_style := StyleBoxFlat.new()
	s_style.bg_color = Color(0.08, 0.09, 0.12, 0.98)
	s_style.border_color = Color(1.0, 0.84, 0.25)
	s_style.border_width_bottom = 3
	s_style.border_width_left = 3
	s_style.border_width_right = 3
	s_style.border_width_top = 3
	s_style.corner_radius_bottom_left = 10
	s_style.corner_radius_bottom_right = 10
	s_style.corner_radius_top_left = 10
	s_style.corner_radius_top_right = 10
	settlement_dialog.add_theme_stylebox_override("panel", s_style)
	add_child(settlement_dialog)

	var s_vbox := VBoxContainer.new()
	s_vbox.add_theme_constant_override("separation", 14)
	settlement_dialog.add_child(s_vbox)

	var title := Label.new()
	title.text = "🎉 TỔNG KẾT PHIÊN ĐẤU GIÁ"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35))
	s_vbox.add_child(title)

	var desc := Label.new()
	if not auction_session.winner_player_id.is_empty():
		var red_info := ""
		if summary["red_items_count"] > 0:
			red_info = "\n🔮 Đồ Đỏ lưu giữ lại (Vật phẩm Phòng Thí Nghiệm): %d món [%s]" % [
				summary["red_items_count"], ", ".join(summary["red_item_names"])
			]
		desc.text = "Người thắng cuộc: %s\n• Giá đấu đã trả: -%d Xu Bạc\n• Vật phẩm quy đổi ra: +%d Xu Bạc\n• Chênh lệch ròng: %+d Xu Bạc%s" % [
			summary["winner_id"],
			summary["final_price_paid"],
			summary["converted_silver"],
			summary["net_profit"],
			red_info
		]
	else:
		desc.text = "Phiên đấu giá đã kết thúc hoặc bị hủy mà không có người mua."
	desc.add_theme_font_size_override("font_size", 14)
	s_vbox.add_child(desc)

	var ok_btn := Button.new()
	ok_btn.text = "XÁC NHẬN & HOÀN TẤT"
	ok_btn.custom_minimum_size = Vector2(160, 42)
	ok_btn.pressed.connect(func():
		auction_finished.emit(summary)
		queue_free()
	)
	s_vbox.add_child(ok_btn)
