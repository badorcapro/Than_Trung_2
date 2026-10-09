class_name CharacterDetailSheet
extends Control

## CharacterDetailSheet
## Giao diện hồ sơ / trạng thái người chơi phong cách Honkai: Star Rail.
## Bao gồm: Switcher nhân vật ở trên cùng, Thanh điều hướng bên trái (Chi Tiết, Kỷ Vật, Vết Thánh, Túi Đồ, Thông Tin, Thời Trang),
## Khu vực trung tâm mô hình/ấn tín, và Bảng thuộc tính/kỹ năng chi tiết bên phải cùng modal popup Chi Tiết Thuộc Tính.

signal closed

const PRODUCTION_CHARACTER_REPOSITORY := preload(
	"res://scripts/application/characters/ProductionCharacterRepository.gd"
)
const COURT_RANK_SERVICE := preload(
	"res://scripts/domain/progression/CourtRankService.gd"
)

enum SidebarTab {
	DETAILS,
	RELICS,
	STIGMATA,
	INVENTORY,
	INFO,
	COSTUMES
}

enum DetailSubTab {
	ATTRIBUTES,
	SKILLS
}

const CHARACTER_LORE: Dictionary = {
	&"character_hoang_linh_lam": {
		"element_name": "Thổ",
		"element_icon": "🏔️",
		"element_color": Color(0.88, 0.68, 0.28),
		"house_name": "Nhà họ Hoàng",
		"house_crest": "res://assets/maps/elements/medallion_hoang.png",
		"bio": "Hậu duệ dòng dõi Hoàng gia danh giá, tính cách điềm đạm, trầm ổn như đại địa ngàn năm. Am tường luật lệ triều đình và các cơ quan bí mật trong cung cấm.",
		"skills": {
			"passive": {
				"name": "Hoàng Cung Thổ Phách",
				"desc": "Tâm trí kiên cố như bàn thạch. Giúp ổn định bước chân và duy trì tâm lý bình tĩnh trước mọi cạm bẫy trong hoàng thành."
			},
			"active": {
				"name": "Địa Mạch Thông Hành",
				"orb_cost": 3,
				"desc": "Kích hoạt khi tích lũy đủ 3 Orb: Cảm ứng mạch đất hoàng triều, mở rộng tầm quan sát và vững bước tiến công trên cung đường."
			},
			"house": {
				"name": "Gia Uy Họ Hoàng",
				"desc": "Thừa hưởng khí phách hoàng gia phương Tây Nam, bảo hộ tài lộc và gia tăng uy danh công khanh."
			},
			"ultimate": {
				"name": "Hoàng Thổ Vạn Nhất",
				"desc": "Siêu Tuyệt Kỹ tối thượng của họ Hoàng (Phiên bản nâng cấp sắp ra mắt trong bản cập nhật tới)."
			}
		}
	},
	&"character_chu_tue_nguyet": {
		"element_name": "Hỏa",
		"element_icon": "🔥",
		"element_color": Color(0.96, 0.38, 0.32),
		"house_name": "Nhà họ Chu",
		"house_crest": "res://assets/maps/elements/medallion_chu.png",
		"bio": "Nữ thần thám tài sắc vẹn toàn, trí tuệ mẫn tiệp và ý chí rực lửa của dòng họ Chu. Nổi danh với tài quan sát vi diệu và trực giác phá án sắc bén.",
		"skills": {
			"passive": {
				"name": "Hỏa Diễm Minh Mẫn",
				"desc": "Tư duy linh hoạt và sắc bén như ánh lửa soi rọi đêm đen, phát hiện manh mối nhanh chóng trong từng manh chiếu."
			},
			"active": {
				"name": "Xích Viêm Liệt Bộ",
				"orb_cost": 3,
				"desc": "Kích hoạt khi tích lũy đủ 3 Orb: Dồn nhiệt huyết bứt tốc mạnh mẽ, tăng cường khả năng di chuyển trên đại lộ."
			},
			"house": {
				"name": "Hỏa Phụng Triều Dương",
				"desc": "Hào khí gia tộc họ Chu phương Đông Nam, tinh thần bất khuất tiếp thêm nhuệ khí cho toàn đội điều tra."
			},
			"ultimate": {
				"name": "Cửu Tiêu Phượng Vũ",
				"desc": "Siêu Tuyệt Kỹ ngọn lửa phượng hoàng triều dương (Phiên bản nâng cấp sắp ra mắt trong bản cập nhật tới)."
			}
		}
	},
	&"character_kim_thanh_giai": {
		"element_name": "Kim",
		"element_icon": "⚔️",
		"element_color": Color(0.32, 0.78, 0.88),
		"house_name": "Nhà họ Kim",
		"house_crest": "res://assets/maps/elements/medallion_kim.png",
		"bio": "Xuất thân từ tướng môn lừng lẫy họ Kim, kiên quyết, sắc sảo và hành động dứt khoát. Luôn mang theo thanh kiếm hộ thân và ấn tín bảo lân gia tộc.",
		"skills": {
			"passive": {
				"name": "Bạch Kim Quyết Đoán",
				"desc": "Ý chí sắt đá không lay chuyển trước bất kỳ ngã rẽ hiểm nguy hay áp lực điều tra nào."
			},
			"active": {
				"name": "Kim Thạch Khai Tâm",
				"orb_cost": 3,
				"desc": "Kích hoạt khi tích lũy đủ 3 Orb: Phá vỡ trở ngại phía trước, kích hoạt tiềm năng thu thập tài bảo vượt bậc."
			},
			"house": {
				"name": "Kim Lân Tụ Bảo",
				"desc": "Gia thế hiển hách của hào tộc họ Kim phương Tây, bảo chứng cho sự sung túc và sắc sảo."
			},
			"ultimate": {
				"name": "Thiên Nhận Phá Trận",
				"desc": "Siêu Tuyệt Kỹ mũi kiếm khai sơn phá thạch (Phiên bản nâng cấp sắp ra mắt trong bản cập nhật tới)."
			}
		}
	},
	&"character_huyen_ca_xuy": {
		"element_name": "Thủy",
		"element_icon": "🌊",
		"element_color": Color(0.42, 0.58, 0.96),
		"house_name": "Nhà họ Huyền",
		"house_crest": "res://assets/maps/elements/medallion_huyen.png",
		"bio": "Truyền nhân của bí tộc Huyền Vũ phương Bắc, trầm tĩnh, sâu lắng và thông tuệ. Nắm giữ nhiều thư tịch cổ xưa của cung đình hoàng gia.",
		"skills": {
			"passive": {
				"name": "Huyền Thủy Lưu Chuyển",
				"desc": "Uyển chuyển như dòng nước, điều tiết thể lực linh hoạt và bảo vệ sự tĩnh tâm tuyệt đối khi suy luận."
			},
			"active": {
				"name": "Thanh Lưu Bộ Pháp",
				"orb_cost": 3,
				"desc": "Kích hoạt khi tích lũy đủ 3 Orb: Lướt nhẹ tựa sóng biển mùa thu, tối ưu hóa các cung đường di chuyển."
			},
			"house": {
				"name": "Huyền Minh Tĩnh Dạ",
				"desc": "Nội hàm uyên thâm của gia tộc họ Huyền, bảo hộ tâm thức và khám phá những sự thật ẩn giấu trong màn đêm."
			},
			"ultimate": {
				"name": "Bích Hải Triều Sinh",
				"desc": "Siêu Tuyệt Kỹ làn sóng triều dâng ngập tràn (Phiên bản nâng cấp sắp ra mắt trong bản cập nhật tới)."
			}
		}
	},
	&"character_lam_phuong_xuan": {
		"element_name": "Mộc",
		"element_icon": "🌿",
		"element_color": Color(0.42, 0.85, 0.48),
		"house_name": "Nhà họ Lam",
		"house_crest": "res://assets/maps/elements/medallion_lam.png",
		"bio": "Ái nữ của y gia thế gia họ Lam phương Đông, tính tình nhân hậu, thanh cao và tràn đầy sức sống như mầm xuân vươn dậy sau cơn mưa.",
		"skills": {
			"passive": {
				"name": "Xuân Mộc Sinh Tức",
				"desc": "Hơi thở mùa xuân giúp hồi phục nguyên khí, duy trì thể lực dẻo dai qua từng chặng đường."
			},
			"active": {
				"name": "Vạn Mộc Hồi Xuân",
				"orb_cost": 3,
				"desc": "Kích hoạt khi tích lũy đủ 3 Orb: Khơi nguồn sinh lực tươi mới, gia tăng dung tích và hiệu năng hành trang."
			},
			"house": {
				"name": "Thanh Mộc Trường Sinh",
				"desc": "Sinh mệnh bất diệt của gia tộc họ Lam, mang lại sinh cơ và may mắn cho mọi người đồng hành."
			},
			"ultimate": {
				"name": "Thương Long Xuất Hải",
				"desc": "Siêu Tuyệt Kỹ rồng xanh bay lượn đón gió xuân (Phiên bản nâng cấp sắp ra mắt trong bản cập nhật tới)."
			}
		}
	}
}

var _active_player_id: StringName = &""
var _current_sidebar_tab: SidebarTab = SidebarTab.DETAILS
var _current_detail_subtab: DetailSubTab = DetailSubTab.ATTRIBUTES
var _selected_skill_index: int = 0

# Cached session references
var _case_flow_session: Variant = null
var _setup_session: Variant = null

# UI Root Nodes
var _backdrop_panel: Panel
var _player_switcher_container: HBoxContainer
var _sidebar_container: VBoxContainer
var _center_avatar_rect: TextureRect
var _center_pedestal_label: Label
var _right_panel_container: Control

# Sub-components
var _stat_detail_modal: PanelContainer
var _rank_detail_popup: PanelContainer


func _init() -> void:
	anchors_preset = PRESET_FULL_RECT
	mouse_filter = MOUSE_FILTER_STOP
	_build_ui()


func _build_ui() -> void:
	# 1. Dark celestial cosmic backdrop
	_backdrop_panel = Panel.new()
	_backdrop_panel.anchors_preset = PRESET_FULL_RECT
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.04, 0.055, 0.085, 0.96)
	_backdrop_panel.add_theme_stylebox_override("panel", bg_style)
	add_child(_backdrop_panel)

	# Main layout margin
	var margin := MarginContainer.new()
	margin.anchors_preset = PRESET_FULL_RECT
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 16)
	margin.add_child(main_vbox)

	# 2. Top Header: Title, Player Switcher Row, Close Button
	var header_row := HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 24)
	main_vbox.add_child(header_row)

	var title_vbox := VBoxContainer.new()
	title_vbox.add_theme_constant_override("separation", 2)
	var title_lbl := Label.new()
	title_lbl.text = "⭐ HỒ SƠ THẦN THÁM"
	title_lbl.add_theme_font_size_override("font_size", 20)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45))
	title_vbox.add_child(title_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = "Trạng thái người chơi & Thuộc tính hoàng gia"
	sub_lbl.add_theme_font_size_override("font_size", 12)
	sub_lbl.add_theme_color_override("font_color", Color(0.65, 0.72, 0.8))
	title_vbox.add_child(sub_lbl)
	header_row.add_child(title_vbox)

	# Spacer
	var spacer_left := Control.new()
	spacer_left.size_flags_horizontal = SIZE_EXPAND_FILL
	header_row.add_child(spacer_left)

	# Player Switcher Container (Horizontal avatars like HSR)
	_player_switcher_container = HBoxContainer.new()
	_player_switcher_container.add_theme_constant_override("separation", 14)
	header_row.add_child(_player_switcher_container)

	# Spacer right
	var spacer_right := Control.new()
	spacer_right.size_flags_horizontal = SIZE_EXPAND_FILL
	header_row.add_child(spacer_right)

	# Close button (X)
	var close_btn := Button.new()
	close_btn.text = " ✕ "
	close_btn.custom_minimum_size = Vector2(40, 40)
	close_btn.add_theme_font_size_override("font_size", 18)
	close_btn.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	close_btn.pressed.connect(_on_close_pressed)
	header_row.add_child(close_btn)

	# 3. Content Body (Left Sidebar, Center Stage, Right Panel)
	var body_row := HBoxContainer.new()
	body_row.size_flags_vertical = SIZE_EXPAND_FILL
	body_row.add_theme_constant_override("separation", 24)
	main_vbox.add_child(body_row)

	# --- LEFT SIDEBAR ---
	_sidebar_container = VBoxContainer.new()
	_sidebar_container.custom_minimum_size = Vector2(170, 0)
	_sidebar_container.add_theme_constant_override("separation", 10)
	body_row.add_child(_sidebar_container)
	_build_sidebar_tabs()

	# --- CENTER STAGE (Avatar / Pedestal / Crest) ---
	var center_container := PanelContainer.new()
	center_container.size_flags_horizontal = SIZE_EXPAND_FILL
	center_container.size_flags_vertical = SIZE_EXPAND_FILL
	var center_style := StyleBoxFlat.new()
	center_style.bg_color = Color(0.06, 0.08, 0.12, 0.45)
	center_style.corner_radius_top_left = 12
	center_style.corner_radius_top_right = 12
	center_style.corner_radius_bottom_right = 12
	center_style.corner_radius_bottom_left = 12
	center_style.border_width_left = 1
	center_style.border_width_top = 1
	center_style.border_width_right = 1
	center_style.border_width_bottom = 1
	center_style.border_color = Color(0.25, 0.32, 0.42, 0.35)
	center_container.add_theme_stylebox_override("panel", center_style)
	body_row.add_child(center_container)

	var center_vbox := VBoxContainer.new()
	center_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center_vbox.add_theme_constant_override("separation", 18)
	center_container.add_child(center_vbox)

	_center_avatar_rect = TextureRect.new()
	_center_avatar_rect.custom_minimum_size = Vector2(260, 260)
	_center_avatar_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_center_avatar_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_center_avatar_rect.size_flags_horizontal = SIZE_SHRINK_CENTER
	center_vbox.add_child(_center_avatar_rect)

	_center_pedestal_label = Label.new()
	_center_pedestal_label.text = "◆ ĐÀN TẾ THẦN THÁM ◆"
	_center_pedestal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_center_pedestal_label.add_theme_color_override("font_color", Color(0.85, 0.75, 0.45, 0.8))
	_center_pedestal_label.add_theme_font_size_override("font_size", 14)
	center_vbox.add_child(_center_pedestal_label)

	# --- RIGHT PANEL ---
	_right_panel_container = Control.new()
	_right_panel_container.custom_minimum_size = Vector2(440, 0)
	_right_panel_container.size_flags_vertical = SIZE_EXPAND_FILL
	body_row.add_child(_right_panel_container)

	# 4. Stat Detail Modal (Popup matching Image 3)
	_build_stat_detail_modal()

	# 5. Rank Detail Popup (Magnifying glass popup)
	_build_rank_detail_popup()


func _build_sidebar_tabs() -> void:
	var tabs: Array[Dictionary] = [
		{"id": SidebarTab.DETAILS, "title": "🌟 Chi Tiết"},
		{"id": SidebarTab.RELICS, "title": "🏺 Kỷ Vật"},
		{"id": SidebarTab.STIGMATA, "title": "📜 Vết Thánh"},
		{"id": SidebarTab.INVENTORY, "title": "🎒 Túi Đồ"},
		{"id": SidebarTab.INFO, "title": "ℹ️ Thông Tin"},
		{"id": SidebarTab.COSTUMES, "title": "👘 Thời Trang"},
	]
	for t: Dictionary in tabs:
		var btn := Button.new()
		var tab_id: SidebarTab = t["id"] as SidebarTab
		btn.text = String(t["title"])
		btn.custom_minimum_size = Vector2(0, 48)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.mouse_default_cursor_shape = CURSOR_POINTING_HAND
		btn.set_meta("tab_id", tab_id)
		btn.pressed.connect(func() -> void: _switch_sidebar_tab(tab_id))
		_sidebar_container.add_child(btn)


func _build_stat_detail_modal() -> void:
	_stat_detail_modal = PanelContainer.new()
	_stat_detail_modal.visible = false
	_stat_detail_modal.custom_minimum_size = Vector2(400, 320)
	_stat_detail_modal.anchors_preset = PRESET_CENTER

	var modal_style := StyleBoxFlat.new()
	modal_style.bg_color = Color(0.94, 0.95, 0.96, 0.98) # Light modal like Image 3
	modal_style.corner_radius_top_left = 12
	modal_style.corner_radius_top_right = 12
	modal_style.corner_radius_bottom_right = 12
	modal_style.corner_radius_bottom_left = 12
	modal_style.shadow_color = Color(0, 0, 0, 0.55)
	modal_style.shadow_size = 18
	modal_style.content_margin_left = 24.0
	modal_style.content_margin_top = 20.0
	modal_style.content_margin_right = 24.0
	modal_style.content_margin_bottom = 20.0
	_stat_detail_modal.add_theme_stylebox_override("panel", modal_style)

	var modal_vbox := VBoxContainer.new()
	modal_vbox.name = "ModalVBox"
	modal_vbox.add_theme_constant_override("separation", 14)
	_stat_detail_modal.add_child(modal_vbox)

	var header_bar := HBoxContainer.new()
	var title := Label.new()
	title.text = "Chi Tiết Thuộc Tính"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.12, 0.14, 0.18))
	title.size_flags_horizontal = SIZE_EXPAND_FILL
	header_bar.add_child(title)

	var close_x := Button.new()
	close_x.text = " ✕ "
	close_x.flat = true
	close_x.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	close_x.pressed.connect(func() -> void: _stat_detail_modal.visible = false)
	header_bar.add_child(close_x)
	modal_vbox.add_child(header_bar)

	var sep := HSeparator.new()
	modal_vbox.add_child(sep)

	var section_lbl := Label.new()
	section_lbl.text = "Thuộc Tính Cơ Bản"
	section_lbl.add_theme_font_size_override("font_size", 13)
	section_lbl.add_theme_color_override("font_color", Color(0.45, 0.5, 0.55))
	modal_vbox.add_child(section_lbl)

	var stats_rows_container := VBoxContainer.new()
	stats_rows_container.name = "StatsRows"
	stats_rows_container.add_theme_constant_override("separation", 10)
	modal_vbox.add_child(stats_rows_container)

	add_child(_stat_detail_modal)


func _build_rank_detail_popup() -> void:
	_rank_detail_popup = PanelContainer.new()
	_rank_detail_popup.visible = false
	_rank_detail_popup.custom_minimum_size = Vector2(320, 200)
	_rank_detail_popup.anchors_preset = PRESET_CENTER

	var pop_style := StyleBoxFlat.new()
	pop_style.bg_color = Color(0.1, 0.12, 0.17, 0.98)
	pop_style.corner_radius_top_left = 10
	pop_style.corner_radius_top_right = 10
	pop_style.corner_radius_bottom_right = 10
	pop_style.corner_radius_bottom_left = 10
	pop_style.border_width_left = 1
	pop_style.border_width_top = 1
	pop_style.border_width_right = 1
	pop_style.border_width_bottom = 1
	pop_style.border_color = Color(1.0, 0.82, 0.28, 0.85)
	pop_style.shadow_color = Color(0, 0, 0, 0.6)
	pop_style.shadow_size = 14
	pop_style.content_margin_left = 18.0
	pop_style.content_margin_top = 16.0
	pop_style.content_margin_right = 18.0
	pop_style.content_margin_bottom = 16.0
	_rank_detail_popup.add_theme_stylebox_override("panel", pop_style)

	var pop_vbox := VBoxContainer.new()
	pop_vbox.name = "RankPopVBox"
	pop_vbox.add_theme_constant_override("separation", 8)
	_rank_detail_popup.add_child(pop_vbox)

	var pop_head := HBoxContainer.new()
	var pop_title := Label.new()
	pop_title.text = "🔍 BẬC CÔNG DANH HOÀNG CUNG"
	pop_title.add_theme_font_size_override("font_size", 14)
	pop_title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.25))
	pop_title.size_flags_horizontal = SIZE_EXPAND_FILL
	pop_head.add_child(pop_title)

	var close_pop := Button.new()
	close_pop.text = " ✕ "
	close_pop.flat = true
	close_pop.pressed.connect(func() -> void: _rank_detail_popup.visible = false)
	pop_head.add_child(close_pop)
	pop_vbox.add_child(pop_head)

	var pop_content := Label.new()
	pop_content.name = "RankContent"
	pop_content.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pop_content.add_theme_font_size_override("font_size", 12)
	pop_content.add_theme_color_override("font_color", Color(0.88, 0.9, 0.94))
	pop_vbox.add_child(pop_content)

	add_child(_rank_detail_popup)


func open_sheet(
	player_id: StringName,
	case_flow_session: Variant,
	setup_session: Variant
) -> void:
	_case_flow_session = case_flow_session
	_setup_session = setup_session
	_active_player_id = player_id
	_current_sidebar_tab = SidebarTab.DETAILS
	_current_detail_subtab = DetailSubTab.ATTRIBUTES
	visible = true
	_stat_detail_modal.visible = false
	_rank_detail_popup.visible = false
	refresh()


func refresh() -> void:
	if _setup_session == null or _case_flow_session == null or _case_flow_session.loot_session == null:
		return
	var session: LootRewardSession = _case_flow_session.loot_session
	var player_order: Array[StringName] = session.movement_session.ordered_player_ids
	if not player_order.has(_active_player_id):
		if not player_order.is_empty():
			_active_player_id = player_order[0]
		else:
			return

	_refresh_player_switcher(player_order)
	_refresh_sidebar_buttons()
	_refresh_center_display()
	_refresh_right_panel()


func _refresh_player_switcher(player_order: Array[StringName]) -> void:
	for child in _player_switcher_container.get_children():
		child.queue_free()

	var badges: Array[String] = ["P1", "P2", "P3", "P4"]
	var badge_colors: Array[Color] = [
		Color(0.2, 0.75, 1.0), Color(1.0, 0.35, 0.45),
		Color(0.35, 0.9, 0.45), Color(0.8, 0.45, 1.0)
	]

	for i: int in range(player_order.size()):
		var pid: StringName = player_order[i]
		var is_current: bool = (pid == _active_player_id)
		var p_state: PlayerPhaseState = _case_flow_session.loot_session.find_player(pid)
		var char_def: CharacterDefinition = (
			_setup_session.find_character(p_state.character_id) if p_state != null else null
		)
		var lore: Dictionary = CHARACTER_LORE.get(char_def.character_id, {}) if char_def != null else {}

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(52, 52)
		btn.mouse_default_cursor_shape = CURSOR_POINTING_HAND
		btn.tooltip_text = "%s - %s" % [
			badges[i % badges.size()],
			char_def.display_name if char_def != null else String(pid)
		]

		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.12, 0.15, 0.22, 0.95) if is_current else Color(0.08, 0.09, 0.12, 0.8)
		style.corner_radius_top_left = 26
		style.corner_radius_top_right = 26
		style.corner_radius_bottom_right = 26
		style.corner_radius_bottom_left = 26
		style.border_width_left = 2 if is_current else 1
		style.border_width_top = 2 if is_current else 1
		style.border_width_right = 2 if is_current else 1
		style.border_width_bottom = 2 if is_current else 1
		style.border_color = Color(1.0, 0.84, 0.22) if is_current else badge_colors[i % badge_colors.size()]
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)

		btn.text = "%s\n%s" % [
			lore.get("element_icon", "★"),
			badges[i % badges.size()]
		]
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_color_override("font_color", badge_colors[i % badge_colors.size()])

		btn.pressed.connect(func() -> void:
			_active_player_id = pid
			refresh()
		)
		_player_switcher_container.add_child(btn)


func _refresh_sidebar_buttons() -> void:
	for child in _sidebar_container.get_children():
		var btn := child as Button
		if btn == null:
			continue
		var tab_id: SidebarTab = btn.get_meta("tab_id", SidebarTab.DETAILS) as SidebarTab
		var is_active: bool = (tab_id == _current_sidebar_tab)
		var style := StyleBoxFlat.new()
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_right = 8
		style.corner_radius_bottom_left = 8
		style.content_margin_left = 16.0
		style.content_margin_top = 10.0
		style.content_margin_right = 16.0
		style.content_margin_bottom = 10.0
		if is_active:
			style.bg_color = Color(0.2, 0.24, 0.35, 0.95)
			style.border_width_left = 3
			style.border_color = Color(1.0, 0.84, 0.25)
			btn.add_theme_color_override("font_color", Color(1.0, 0.92, 0.65))
		else:
			style.bg_color = Color(0.08, 0.1, 0.14, 0.65)
			btn.add_theme_color_override("font_color", Color(0.72, 0.78, 0.85))
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)


func _refresh_center_display() -> void:
	var p_state: PlayerPhaseState = _case_flow_session.loot_session.find_player(_active_player_id)
	var char_def: CharacterDefinition = (
		_setup_session.find_character(p_state.character_id) if p_state != null else null
	)
	var lore: Dictionary = CHARACTER_LORE.get(char_def.character_id, {}) if char_def != null else {}

	var crest_path: String = String(lore.get("house_crest", ""))
	if not crest_path.is_empty() and ResourceLoader.exists(crest_path):
		_center_avatar_rect.texture = load(crest_path) as Texture2D
	else:
		_center_avatar_rect.texture = null

	var char_name: String = char_def.display_name if char_def != null else "Thần Thám"
	var house_name: String = String(lore.get("house_name", "Hoàng Cung"))
	_center_pedestal_label.text = "◆ %s · %s ◆" % [char_name.to_upper(), house_name.to_upper()]


func _refresh_right_panel() -> void:
	for child in _right_panel_container.get_children():
		child.queue_free()

	match _current_sidebar_tab:
		SidebarTab.DETAILS:
			_render_tab_details()
		SidebarTab.RELICS:
			_render_tab_relics()
		SidebarTab.STIGMATA:
			_render_tab_stigmata()
		SidebarTab.INVENTORY:
			_render_tab_inventory()
		SidebarTab.INFO:
			_render_tab_info()
		SidebarTab.COSTUMES:
			_render_tab_costumes()


# -----------------------------------------------------------------------------
# TAB 1: CHI TIẾT (Details)
# -----------------------------------------------------------------------------
func _render_tab_details() -> void:
	var p_state: PlayerPhaseState = _case_flow_session.loot_session.find_player(_active_player_id)
	var char_def: CharacterDefinition = (
		_setup_session.find_character(p_state.character_id) if p_state != null else null
	)
	var lore: Dictionary = CHARACTER_LORE.get(char_def.character_id, {}) if char_def != null else {}

	var vbox := VBoxContainer.new()
	vbox.anchors_preset = PRESET_FULL_RECT
	vbox.add_theme_constant_override("separation", 14)
	_right_panel_container.add_child(vbox)

	# 1. Header Card (Name, Element, House, Diamonds, Merit)
	var header_panel := PanelContainer.new()
	var h_style := StyleBoxFlat.new()
	h_style.bg_color = Color(0.08, 0.1, 0.15, 0.85)
	h_style.corner_radius_top_left = 10
	h_style.corner_radius_top_right = 10
	h_style.corner_radius_bottom_right = 10
	h_style.corner_radius_bottom_left = 10
	h_style.content_margin_left = 18.0
	h_style.content_margin_top = 14.0
	h_style.content_margin_right = 18.0
	h_style.content_margin_bottom = 14.0
	header_panel.add_theme_stylebox_override("panel", h_style)
	vbox.add_child(header_panel)

	var h_vbox := VBoxContainer.new()
	h_vbox.add_theme_constant_override("separation", 6)
	header_panel.add_child(h_vbox)

	# Name + Element
	var name_row := HBoxContainer.new()
	var name_lbl := Label.new()
	name_lbl.text = "⭐ %s" % (char_def.display_name if char_def != null else "Nhân vật")
	name_lbl.add_theme_font_size_override("font_size", 22)
	name_lbl.add_theme_color_override("font_color", Color(1.0, 0.94, 0.8))
	name_lbl.size_flags_horizontal = SIZE_EXPAND_FILL
	name_row.add_child(name_lbl)

	var elem_lbl := Label.new()
	var elem_color: Color = lore.get("element_color", Color(0.4, 0.8, 1.0))
	elem_lbl.text = "%s %s" % [lore.get("element_icon", "★"), lore.get("element_name", "Vô Cực")]
	elem_lbl.add_theme_font_size_override("font_size", 16)
	elem_lbl.add_theme_color_override("font_color", elem_color)
	name_row.add_child(elem_lbl)
	h_vbox.add_child(name_row)

	# House origin
	var house_lbl := Label.new()
	house_lbl.text = "🏛️ %s" % lore.get("house_name", "Hoàng Cung")
	house_lbl.add_theme_font_size_override("font_size", 13)
	house_lbl.add_theme_color_override("font_color", Color(0.7, 0.78, 0.88))
	h_vbox.add_child(house_lbl)

	# Diamonds row (Orb requirement & current orbs)
	var active_skill_info: Dictionary = lore.get("skills", {}).get("active", {})
	var req_orbs: int = int(active_skill_info.get("orb_cost", 3))
	var cur_orbs: int = p_state.orb_count if p_state != null else 0
	var diamonds_row := HBoxContainer.new()
	diamonds_row.add_theme_constant_override("separation", 8)
	var dia_prefix := Label.new()
	dia_prefix.text = "Năng lượng kĩ năng (Orb):"
	dia_prefix.add_theme_font_size_override("font_size", 12)
	dia_prefix.add_theme_color_override("font_color", Color(0.65, 0.7, 0.75))
	diamonds_row.add_child(dia_prefix)

	var dia_str: String = ""
	for d_idx in range(req_orbs):
		if d_idx < cur_orbs:
			dia_str += "◆ " # Lit gold
		else:
			dia_str += "◇ " # Unlit
	var dia_label := Label.new()
	dia_label.text = dia_str
	dia_label.add_theme_font_size_override("font_size", 16)
	dia_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.22))
	diamonds_row.add_child(dia_label)

	var orb_count_tag := Label.new()
	orb_count_tag.text = "(%d/%d)" % [cur_orbs, req_orbs]
	orb_count_tag.add_theme_font_size_override("font_size", 12)
	orb_count_tag.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	diamonds_row.add_child(orb_count_tag)
	h_vbox.add_child(diamonds_row)

	# Level / Merit row with magnifying glass
	var merit_row := HBoxContainer.new()
	merit_row.add_theme_constant_override("separation", 8)

	var merit_val: float = p_state.merit_progress if p_state != null else 0.0
	var rank_service := COURT_RANK_SERVICE.new()
	var rank_info: Dictionary = rank_service.resolve(merit_val)
	var rank_title: String = String(rank_info.get("name", "Cửu phẩm"))

	var merit_lbl := Label.new()
	merit_lbl.text = "⭐ Công Danh: %.2f  [%s]" % [merit_val, rank_title]
	merit_lbl.add_theme_font_size_override("font_size", 14)
	merit_lbl.add_theme_color_override("font_color", Color(0.95, 0.88, 0.65))
	merit_lbl.size_flags_horizontal = SIZE_EXPAND_FILL
	merit_row.add_child(merit_lbl)

	# Magnifying glass button
	var mag_btn := Button.new()
	mag_btn.text = " 🔍 "
	mag_btn.flat = true
	mag_btn.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	mag_btn.tooltip_text = "Bấm để xem Bậc phẩm Công danh Hoàng Cung"
	mag_btn.pressed.connect(func() -> void:
		_show_rank_popup(merit_val, rank_info)
	)
	merit_row.add_child(mag_btn)
	h_vbox.add_child(merit_row)

	# 2. Pill Switcher: [ Thuộc Tính ] [ Kỹ Năng ]
	var pill_row := HBoxContainer.new()
	pill_row.add_theme_constant_override("separation", 10)
	vbox.add_child(pill_row)

	var attr_pill := Button.new()
	attr_pill.text = "Thuộc Tính"
	attr_pill.size_flags_horizontal = SIZE_EXPAND_FILL
	attr_pill.custom_minimum_size = Vector2(0, 38)
	attr_pill.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	_style_subtab_pill(attr_pill, _current_detail_subtab == DetailSubTab.ATTRIBUTES)
	attr_pill.pressed.connect(func() -> void:
		_current_detail_subtab = DetailSubTab.ATTRIBUTES
		refresh()
	)
	pill_row.add_child(attr_pill)

	var skill_pill := Button.new()
	skill_pill.text = "Kỹ Năng"
	skill_pill.size_flags_horizontal = SIZE_EXPAND_FILL
	skill_pill.custom_minimum_size = Vector2(0, 38)
	skill_pill.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	_style_subtab_pill(skill_pill, _current_detail_subtab == DetailSubTab.SKILLS)
	skill_pill.pressed.connect(func() -> void:
		_current_detail_subtab = DetailSubTab.SKILLS
		refresh()
	)
	pill_row.add_child(skill_pill)

	# 3. Subtab Content Area
	var subtab_panel := PanelContainer.new()
	subtab_panel.size_flags_vertical = SIZE_EXPAND_FILL
	var s_style := StyleBoxFlat.new()
	s_style.bg_color = Color(0.07, 0.08, 0.12, 0.85)
	s_style.corner_radius_top_left = 10
	s_style.corner_radius_top_right = 10
	s_style.corner_radius_bottom_right = 10
	s_style.corner_radius_bottom_left = 10
	s_style.content_margin_left = 16.0
	s_style.content_margin_top = 14.0
	s_style.content_margin_right = 16.0
	s_style.content_margin_bottom = 14.0
	subtab_panel.add_theme_stylebox_override("panel", s_style)
	vbox.add_child(subtab_panel)

	if _current_detail_subtab == DetailSubTab.ATTRIBUTES:
		_render_attributes_subtab(subtab_panel)
	else:
		_render_skills_subtab(subtab_panel, lore)


func _style_subtab_pill(btn: Button, is_active: bool) -> void:
	var style := StyleBoxFlat.new()
	style.corner_radius_top_left = 19
	style.corner_radius_top_right = 19
	style.corner_radius_bottom_right = 19
	style.corner_radius_bottom_left = 19
	if is_active:
		style.bg_color = Color(0.94, 0.96, 0.98, 0.95)
		btn.add_theme_color_override("font_color", Color(0.08, 0.1, 0.15))
	else:
		style.bg_color = Color(0.12, 0.14, 0.19, 0.75)
		btn.add_theme_color_override("font_color", Color(0.75, 0.8, 0.85))
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)


func _render_attributes_subtab(container: Control) -> void:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	container.add_child(vbox)

	var p_state: PlayerPhaseState = _case_flow_session.loot_session.find_player(_active_player_id)
	var char_def: CharacterDefinition = (
		_setup_session.find_character(p_state.character_id) if p_state != null else null
	)

	var movement_player: LootMovementPlayerState = null
	for mp: LootMovementPlayerState in _case_flow_session.loot_session.movement_session.player_states:
		if mp.player_id == _active_player_id:
			movement_player = mp
			break
	var round_loot: RoundLootInventoryState = _case_flow_session.loot_session.find_round_loot_state(_active_player_id)

	var cur_stamina: int = movement_player.remaining_moves if movement_player != null else 2
	var cur_speed: int = (
		movement_player.speed_snapshot if movement_player != null
		else (char_def.base_speed if char_def != null else 2)
	)
	var cur_strength: int = round_loot.capacity if round_loot != null else (char_def.base_bag_level if char_def != null else 2)

	var stats: Array[Dictionary] = [
		{"icon": "⚡", "name": "Thể Lực", "val": "%d" % cur_stamina, "desc": "Số lượt di chuyển còn lại trong phiên Loot."},
		{"icon": "👟", "name": "Tốc Độ", "val": "%d" % cur_speed, "desc": "Khoảng bước ngẫu nhiên tối đa khi đổ xúc xắc (1-%d)." % cur_speed},
		{"icon": "🎒", "name": "Sức Mạnh", "val": "%d" % cur_strength, "desc": "Dung tích hành trang: Mỗi 1 điểm mang thêm được 1 vật phẩm khi loot."},
	]

	for s: Dictionary in stats:
		var row := HBoxContainer.new()
		var icon_lbl := Label.new()
		icon_lbl.text = s["icon"]
		icon_lbl.add_theme_font_size_override("font_size", 18)
		row.add_child(icon_lbl)

		var name_lbl := Label.new()
		name_lbl.text = s["name"]
		name_lbl.add_theme_font_size_override("font_size", 14)
		name_lbl.add_theme_color_override("font_color", Color(0.82, 0.88, 0.92))
		name_lbl.size_flags_horizontal = SIZE_EXPAND_FILL
		row.add_child(name_lbl)

		var val_lbl := Label.new()
		val_lbl.text = s["val"]
		val_lbl.add_theme_font_size_override("font_size", 16)
		val_lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.8))
		row.add_child(val_lbl)
		vbox.add_child(row)

	var note_lbl := Label.new()
	note_lbl.text = "💡 Sức Mạnh tương đương dung tích túi đồ. Mỗi điểm cầm thêm 1 món khi loot."
	note_lbl.add_theme_font_size_override("font_size", 11)
	note_lbl.add_theme_color_override("font_color", Color(0.65, 0.72, 0.75))
	note_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(note_lbl)

	var spacer := Control.new()
	spacer.size_flags_vertical = SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	# Button "Chi Tiết Thuộc Tính" (Opens Image 3 popup)
	var detail_btn := Button.new()
	detail_btn.text = "Chi Tiết Thuộc Tính"
	detail_btn.custom_minimum_size = Vector2(170, 38)
	detail_btn.size_flags_horizontal = SIZE_SHRINK_END
	detail_btn.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	detail_btn.pressed.connect(_on_open_stat_detail_modal_pressed)
	vbox.add_child(detail_btn)


func _render_skills_subtab(container: Control, lore: Dictionary) -> void:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	container.add_child(vbox)

	var skills_dict: Dictionary = lore.get("skills", {})
	var skill_list: Array[Dictionary] = [
		{
			"type": "Nội Tại",
			"icon": "🌟",
			"name": skills_dict.get("passive", {}).get("name", "Nội Tại"),
			"desc": skills_dict.get("passive", {}).get("desc", ""),
			"tag": "Thiên Phú"
		},
		{
			"type": "Kỹ Năng",
			"icon": "⚡",
			"name": skills_dict.get("active", {}).get("name", "Kỹ Năng Kích Hoạt"),
			"desc": skills_dict.get("active", {}).get("desc", ""),
			"tag": "Cần 3 Orb"
		},
		{
			"type": "Nội Tại Nhà",
			"icon": "🏛️",
			"name": skills_dict.get("house", {}).get("name", "Nội Tại Gia Tộc"),
			"desc": skills_dict.get("house", {}).get("desc", ""),
			"tag": "Dòng Tộc"
		},
		{
			"type": "Siêu Tuyệt Kỹ",
			"icon": "👑",
			"name": skills_dict.get("ultimate", {}).get("name", "Siêu Tuyệt Kỹ"),
			"desc": skills_dict.get("ultimate", {}).get("desc", ""),
			"tag": "Sắp Ra Mắt"
		},
	]

	# Grid of 4 skill buttons (circular style representation)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	vbox.add_child(grid)

	for i in range(skill_list.size()):
		var sk: Dictionary = skill_list[i]
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(195, 62)
		btn.mouse_default_cursor_shape = CURSOR_POINTING_HAND

		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.12, 0.15, 0.22, 0.85) if _selected_skill_index == i else Color(0.08, 0.1, 0.14, 0.65)
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_right = 8
		style.corner_radius_bottom_left = 8
		style.border_width_left = 2 if _selected_skill_index == i else 1
		style.border_width_top = 2 if _selected_skill_index == i else 1
		style.border_width_right = 2 if _selected_skill_index == i else 1
		style.border_width_bottom = 2 if _selected_skill_index == i else 1
		style.border_color = Color(1.0, 0.84, 0.25) if _selected_skill_index == i else Color(0.3, 0.35, 0.45, 0.4)
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)

		btn.text = "%s %s\n[%s]" % [sk["icon"], sk["name"], sk["tag"]]
		btn.add_theme_font_size_override("font_size", 12)
		btn.add_theme_color_override("font_color", Color(1.0, 0.9, 0.7) if _selected_skill_index == i else Color(0.75, 0.8, 0.85))

		var cur_i := i
		btn.pressed.connect(func() -> void:
			_selected_skill_index = cur_i
			refresh()
		)
		grid.add_child(btn)

	# Selected skill detail description box
	var selected_sk: Dictionary = skill_list[clampi(_selected_skill_index, 0, skill_list.size() - 1)]
	var desc_box := PanelContainer.new()
	desc_box.size_flags_vertical = SIZE_EXPAND_FILL
	var db_style := StyleBoxFlat.new()
	db_style.bg_color = Color(0.05, 0.065, 0.09, 0.9)
	db_style.corner_radius_top_left = 8
	db_style.corner_radius_top_right = 8
	db_style.corner_radius_bottom_right = 8
	db_style.corner_radius_bottom_left = 8
	db_style.content_margin_left = 12.0
	db_style.content_margin_top = 10.0
	db_style.content_margin_right = 12.0
	db_style.content_margin_bottom = 10.0
	desc_box.add_theme_stylebox_override("panel", db_style)
	vbox.add_child(desc_box)

	var desc_vbox := VBoxContainer.new()
	desc_vbox.add_theme_constant_override("separation", 6)
	desc_box.add_child(desc_vbox)

	var sk_title := Label.new()
	sk_title.text = "%s %s (%s)" % [selected_sk["icon"], selected_sk["name"], selected_sk["type"]]
	sk_title.add_theme_font_size_override("font_size", 14)
	sk_title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.3))
	desc_vbox.add_child(sk_title)

	var sk_desc := Label.new()
	sk_desc.text = selected_sk["desc"]
	sk_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sk_desc.add_theme_font_size_override("font_size", 12)
	sk_desc.add_theme_color_override("font_color", Color(0.88, 0.9, 0.94))
	desc_vbox.add_child(sk_desc)


# -----------------------------------------------------------------------------
# TAB 2: KỶ VẬT (Relics)
# -----------------------------------------------------------------------------
func _render_tab_relics() -> void:
	var vbox := VBoxContainer.new()
	vbox.anchors_preset = PRESET_FULL_RECT
	vbox.add_theme_constant_override("separation", 14)
	_right_panel_container.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = "🏺 KỶ VẬT HOÀNG GIA (RELICS)"
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(title_lbl)

	var p_state: PlayerPhaseState = _case_flow_session.loot_session.find_player(_active_player_id)
	var relic_inst: EquipmentInstance = null
	if p_state != null and not p_state.relic_instance_id.is_empty():
		for inst in p_state.equipment_collection:
			if inst.instance_id == p_state.relic_instance_id:
				relic_inst = inst
				break

	var card := PanelContainer.new()
	var c_style := StyleBoxFlat.new()
	c_style.bg_color = Color(0.08, 0.1, 0.15, 0.85)
	c_style.corner_radius_top_left = 10
	c_style.corner_radius_top_right = 10
	c_style.corner_radius_bottom_right = 10
	c_style.corner_radius_bottom_left = 10
	c_style.content_margin_left = 18.0
	c_style.content_margin_top = 16.0
	c_style.content_margin_right = 18.0
	c_style.content_margin_bottom = 16.0
	card.add_theme_stylebox_override("panel", c_style)
	vbox.add_child(card)

	var cvbox := VBoxContainer.new()
	cvbox.add_theme_constant_override("separation", 8)
	card.add_child(cvbox)

	if relic_inst != null:
		var name_lbl := Label.new()
		name_lbl.text = "Đang trang bị: %s" % relic_inst.display_name
		name_lbl.add_theme_font_size_override("font_size", 16)
		name_lbl.add_theme_color_override("font_color", Color(0.95, 0.9, 0.7))
		cvbox.add_child(name_lbl)

		var tier_lbl := Label.new()
		tier_lbl.text = "Phẩm cấp: %s | Cấp Vàng: %d | Cấp Tím: %d" % [
			EquipmentEnums.Tier.keys()[relic_inst.tier],
			relic_inst.gold_level,
			relic_inst.purple_level
		]
		tier_lbl.add_theme_font_size_override("font_size", 13)
		tier_lbl.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
		cvbox.add_child(tier_lbl)
	else:
		var empty_lbl := Label.new()
		empty_lbl.text = "Chưa trang bị Kỷ Vật.\nHãy tham gia Gacha hoặc quản lý trang bị giữa các Kỳ Án để nhận Kỷ Vật."
		empty_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_lbl.add_theme_font_size_override("font_size", 13)
		empty_lbl.add_theme_color_override("font_color", Color(0.65, 0.7, 0.75))
		cvbox.add_child(empty_lbl)


# -----------------------------------------------------------------------------
# TAB 3: VẾT THÁNH (Stigmata)
# -----------------------------------------------------------------------------
func _render_tab_stigmata() -> void:
	var vbox := VBoxContainer.new()
	vbox.anchors_preset = PRESET_FULL_RECT
	vbox.add_theme_constant_override("separation", 14)
	_right_panel_container.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = "📜 VẾT THÁNH BẢO VỆ (STIGMATA)"
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(title_lbl)

	var p_state: PlayerPhaseState = _case_flow_session.loot_session.find_player(_active_player_id)
	var slots: Array[Dictionary] = [
		{"name": "Vết Thánh (Thượng) - Vị trí A", "id": p_state.stigmata_a_instance_id if p_state != null else &""},
		{"name": "Vết Thánh (Trung) - Vị trí B", "id": p_state.stigmata_b_instance_id if p_state != null else &""},
		{"name": "Vết Thánh (Hạ) - Vị trí C", "id": p_state.stigmata_c_instance_id if p_state != null else &""},
	]

	for s: Dictionary in slots:
		var slot_card := PanelContainer.new()
		var sc_style := StyleBoxFlat.new()
		sc_style.bg_color = Color(0.08, 0.1, 0.14, 0.8)
		sc_style.corner_radius_top_left = 8
		sc_style.corner_radius_top_right = 8
		sc_style.corner_radius_bottom_right = 8
		sc_style.corner_radius_bottom_left = 8
		sc_style.content_margin_left = 14.0
		sc_style.content_margin_top = 10.0
		sc_style.content_margin_right = 14.0
		sc_style.content_margin_bottom = 10.0
		slot_card.add_theme_stylebox_override("panel", sc_style)
		vbox.add_child(slot_card)

		var sc_vbox := VBoxContainer.new()
		slot_card.add_child(sc_vbox)

		var s_name := Label.new()
		s_name.text = s["name"]
		s_name.add_theme_font_size_override("font_size", 13)
		s_name.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45))
		sc_vbox.add_child(s_name)

		var inst_id: StringName = s["id"] as StringName
		var s_detail := Label.new()
		if inst_id.is_empty():
			s_detail.text = "Trống"
			s_detail.add_theme_color_override("font_color", Color(0.5, 0.55, 0.6))
		else:
			s_detail.text = "Đã trang bị: %s" % inst_id
			s_detail.add_theme_color_override("font_color", Color(0.85, 0.92, 0.98))
		s_detail.add_theme_font_size_override("font_size", 12)
		sc_vbox.add_child(s_detail)


# -----------------------------------------------------------------------------
# TAB 4: TÚI ĐỒ (Inventory - Consumables & Resources only, no relics/stigmata)
# -----------------------------------------------------------------------------
func _render_tab_inventory() -> void:
	var vbox := VBoxContainer.new()
	vbox.anchors_preset = PRESET_FULL_RECT
	vbox.add_theme_constant_override("separation", 14)
	_right_panel_container.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = "🎒 TÚI HÀNH TRANG & TÀI BẢO"
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(title_lbl)

	var p_state: PlayerPhaseState = _case_flow_session.loot_session.find_player(_active_player_id)
	var round_loot: RoundLootInventoryState = _case_flow_session.loot_session.find_round_loot_state(_active_player_id)

	# Resources row
	var res_card := PanelContainer.new()
	var rc_style := StyleBoxFlat.new()
	rc_style.bg_color = Color(0.08, 0.1, 0.14, 0.85)
	rc_style.corner_radius_top_left = 8
	rc_style.corner_radius_top_right = 8
	rc_style.corner_radius_bottom_right = 8
	rc_style.corner_radius_bottom_left = 8
	rc_style.content_margin_left = 14.0
	rc_style.content_margin_top = 10.0
	rc_style.content_margin_right = 14.0
	rc_style.content_margin_bottom = 10.0
	res_card.add_theme_stylebox_override("panel", rc_style)
	vbox.add_child(res_card)

	var res_vbox := VBoxContainer.new()
	res_vbox.add_theme_constant_override("separation", 6)
	res_card.add_child(res_vbox)

	var coins: int = p_state.silver_coin_count if p_state != null else 0
	var tickets: int = p_state.gacha_ticket_count if p_state != null else 0
	var orbs: int = p_state.orb_count if p_state != null else 0
	var rep: int = p_state.reputation if p_state != null else 5

	var res_lbl := Label.new()
	res_lbl.text = "🪙 Xu Bạc: %d   🎟️ Vé Gacha: %d   🔮 Orb: %d   🛡️ Danh Tiếng: %d" % [
		coins, tickets, orbs, rep
	]
	res_lbl.add_theme_font_size_override("font_size", 13)
	res_lbl.add_theme_color_override("font_color", Color(0.95, 0.9, 0.75))
	res_vbox.add_child(res_lbl)

	# Round Carried Consumables
	var carried_title := Label.new()
	var carried_count: int = round_loot.carried_items.size() if round_loot != null else 0
	var carried_cap: int = round_loot.capacity if round_loot != null else 2
	carried_title.text = "📦 Vật Phẩm Đang Mang Khi Loot (%d/%d)" % [carried_count, carried_cap]
	carried_title.add_theme_font_size_override("font_size", 14)
	carried_title.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
	vbox.add_child(carried_title)

	var carried_card := PanelContainer.new()
	carried_card.add_theme_stylebox_override("panel", rc_style)
	vbox.add_child(carried_card)

	var carried_vbox := VBoxContainer.new()
	carried_card.add_child(carried_vbox)

	if round_loot != null and not round_loot.carried_items.is_empty():
		for row: Dictionary in round_loot.carried_items:
			var item_id: StringName = StringName(row.get("item_id", ""))
			var it_name: String = _item_name(item_id)
			var it_lbl := Label.new()
			it_lbl.text = "• %s" % it_name
			it_lbl.add_theme_font_size_override("font_size", 12)
			it_lbl.add_theme_color_override("font_color", Color(0.85, 0.95, 0.88))
			carried_vbox.add_child(it_lbl)
	else:
		var empty_c := Label.new()
		empty_c.text = "(Túi rỗng - nhặt vật phẩm trên các ô bản đồ để sử dụng)"
		empty_c.add_theme_font_size_override("font_size", 12)
		empty_c.add_theme_color_override("font_color", Color(0.55, 0.6, 0.65))
		carried_vbox.add_child(empty_c)

	# Persistent Consumables
	var persistent_title := Label.new()
	var persistent_count: int = p_state.consumable_inventory.size() if p_state != null else 0
	persistent_title.text = "🏛️ Vật Phẩm Vĩnh Viễn Trong Kho (%d món)" % persistent_count
	persistent_title.add_theme_font_size_override("font_size", 14)
	persistent_title.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
	vbox.add_child(persistent_title)

	var persistent_card := PanelContainer.new()
	persistent_card.add_theme_stylebox_override("panel", rc_style)
	vbox.add_child(persistent_card)

	var persistent_vbox := VBoxContainer.new()
	persistent_card.add_child(persistent_vbox)

	if p_state != null and not p_state.consumable_inventory.is_empty():
		for row: Dictionary in p_state.consumable_inventory:
			var item_id: StringName = StringName(row.get("item_id", ""))
			var qty: int = int(row.get("quantity", 1))
			var it_name: String = _item_name(item_id)
			var it_lbl := Label.new()
			it_lbl.text = "• %s (x%d)" % [it_name, qty]
			it_lbl.add_theme_font_size_override("font_size", 12)
			it_lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
			persistent_vbox.add_child(it_lbl)
	else:
		var empty_p := Label.new()
		empty_p.text = "(Kho trống - vật phẩm mang trong túi sẽ chuyển về kho khi kết thúc Loot)"
		empty_p.add_theme_font_size_override("font_size", 12)
		empty_p.add_theme_color_override("font_color", Color(0.55, 0.6, 0.65))
		persistent_vbox.add_child(empty_p)


func _item_name(item_id: StringName) -> String:
	if _case_flow_session != null and _case_flow_session.has_method("consumable_item_display_name"):
		var n: String = _case_flow_session.consumable_item_display_name(item_id)
		if not n.is_empty():
			return n
	match item_id:
		&"item_hanh_lo_phu":
			return "Hành Lộ Phù"
		&"item_lenh_bai_thong_hanh":
			return "Lệnh Bài Thông Hành"
		&"item_ngu_ma_lenh":
			return "Ngự Mã Lệnh"
	return String(item_id) if item_id != &"" else "Vật phẩm"



# -----------------------------------------------------------------------------
# TAB 5: THÔNG TIN (Info / Lore)
# -----------------------------------------------------------------------------
func _render_tab_info() -> void:
	var vbox := VBoxContainer.new()
	vbox.anchors_preset = PRESET_FULL_RECT
	vbox.add_theme_constant_override("separation", 14)
	_right_panel_container.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = "ℹ️ TIỂU SỬ & THÂN THẾ"
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(title_lbl)

	var p_state: PlayerPhaseState = _case_flow_session.loot_session.find_player(_active_player_id)
	var char_def: CharacterDefinition = (
		_setup_session.find_character(p_state.character_id) if p_state != null else null
	)
	var lore: Dictionary = CHARACTER_LORE.get(char_def.character_id, {}) if char_def != null else {}

	var card := PanelContainer.new()
	var c_style := StyleBoxFlat.new()
	c_style.bg_color = Color(0.08, 0.1, 0.14, 0.85)
	c_style.corner_radius_top_left = 8
	c_style.corner_radius_top_right = 8
	c_style.corner_radius_bottom_right = 8
	c_style.corner_radius_bottom_left = 8
	c_style.content_margin_left = 16.0
	c_style.content_margin_top = 14.0
	c_style.content_margin_right = 16.0
	c_style.content_margin_bottom = 14.0
	card.add_theme_stylebox_override("panel", c_style)
	vbox.add_child(card)

	var cvbox := VBoxContainer.new()
	cvbox.add_theme_constant_override("separation", 10)
	card.add_child(cvbox)

	var bio_lbl := Label.new()
	bio_lbl.text = lore.get("bio", "Chưa có dữ liệu tiểu sử.")
	bio_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bio_lbl.add_theme_font_size_override("font_size", 13)
	bio_lbl.add_theme_color_override("font_color", Color(0.88, 0.92, 0.96))
	cvbox.add_child(bio_lbl)


# -----------------------------------------------------------------------------
# TAB 6: THỜI TRANG (Costumes - Placeholder)
# -----------------------------------------------------------------------------
func _render_tab_costumes() -> void:
	var vbox := VBoxContainer.new()
	vbox.anchors_preset = PRESET_FULL_RECT
	vbox.add_theme_constant_override("separation", 14)
	_right_panel_container.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = "👘 TỦ ĐỒ & THỜI TRANG"
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(title_lbl)

	var card := PanelContainer.new()
	var c_style := StyleBoxFlat.new()
	c_style.bg_color = Color(0.08, 0.1, 0.14, 0.85)
	c_style.corner_radius_top_left = 8
	c_style.corner_radius_top_right = 8
	c_style.corner_radius_bottom_right = 8
	c_style.corner_radius_bottom_left = 8
	c_style.content_margin_left = 16.0
	c_style.content_margin_top = 14.0
	c_style.content_margin_right = 16.0
	c_style.content_margin_bottom = 14.0
	card.add_theme_stylebox_override("panel", c_style)
	vbox.add_child(card)

	var lbl := Label.new()
	lbl.text = "• Trang phục hiện tại: Thường phục Thần Thám Hoàng Cung.\n\n(Tính năng Tủ Đồ Ngoại Trang đang được phát triển trong các bản mở rộng tương lai)."
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8))
	card.add_child(lbl)


# -----------------------------------------------------------------------------
# POPUPS & MODALS
# -----------------------------------------------------------------------------
func _on_open_stat_detail_modal_pressed() -> void:
	var rows_container: VBoxContainer = _stat_detail_modal.find_child("StatsRows", true, false) as VBoxContainer
	if rows_container == null:
		return
	for child in rows_container.get_children():
		child.queue_free()

	var p_state: PlayerPhaseState = _case_flow_session.loot_session.find_player(_active_player_id)
	var char_def: CharacterDefinition = (
		_setup_session.find_character(p_state.character_id) if p_state != null else null
	)

	var base_hp: int = char_def.base_stamina if char_def != null else 2
	var base_spd: int = char_def.base_speed if char_def != null else 2
	var base_str: int = char_def.base_bag_level if char_def != null else 2

	# In current balance, bonus comes from equipment / temporary effects (or 0)
	var bonus_hp: int = 0
	var bonus_spd: int = 0
	var bonus_str: int = 0

	var modal_stats: Array[Dictionary] = [
		{"icon": "❤️", "name": "Thể Lực (HP)", "base": base_hp, "bonus": bonus_hp},
		{"icon": "👟", "name": "Tốc Độ", "base": base_spd, "bonus": bonus_spd},
		{"icon": "🎒", "name": "Sức Mạnh (Túi đồ)", "base": base_str, "bonus": bonus_str},
	]

	for item: Dictionary in modal_stats:
		var row := HBoxContainer.new()

		var icon_lbl := Label.new()
		icon_lbl.text = item["icon"]
		icon_lbl.add_theme_font_size_override("font_size", 14)
		row.add_child(icon_lbl)

		var name_lbl := Label.new()
		name_lbl.text = item["name"]
		name_lbl.add_theme_font_size_override("font_size", 13)
		name_lbl.add_theme_color_override("font_color", Color(0.2, 0.22, 0.25)) # Dark text like Image 3
		name_lbl.size_flags_horizontal = SIZE_EXPAND_FILL
		row.add_child(name_lbl)

		var val_row := HBoxContainer.new()
		val_row.add_theme_constant_override("separation", 6)

		# Base stat in black/dark
		var base_lbl := Label.new()
		base_lbl.text = "%d" % int(item["base"])
		base_lbl.add_theme_font_size_override("font_size", 14)
		base_lbl.add_theme_color_override("font_color", Color(0.12, 0.12, 0.15))
		val_row.add_child(base_lbl)

		# Bonus stat in bright cyan/blue like Image 3
		var bonus_lbl := Label.new()
		bonus_lbl.text = "+%d" % int(item["bonus"])
		bonus_lbl.add_theme_font_size_override("font_size", 14)
		bonus_lbl.add_theme_color_override("font_color", Color(0.15, 0.6, 0.95))
		val_row.add_child(bonus_lbl)

		row.add_child(val_row)
		rows_container.add_child(row)

	_stat_detail_modal.visible = true


func _show_rank_popup(merit_val: float, rank_info: Dictionary) -> void:
	var content: Label = _rank_detail_popup.find_child("RankContent", true, false) as Label
	if content == null:
		return

	var current_name: String = String(rank_info.get("name", "Cửu phẩm"))
	var max_reached: bool = bool(rank_info.get("maximum_reached", false))
	var next_threshold: int = int(rank_info.get("next_threshold", -1))
	var next_name: String = String(rank_info.get("next_rank", {}).get("name", "Nhất phẩm"))

	var text: String = "Điểm Công Danh tích lũy: %.2f\n" % merit_val
	text += "Bậc phẩm hiện tại: %s\n\n" % current_name
	if max_reached:
		text += "⭐ Đã đạt phẩm vị tối cao của Hoàng Cung (Nhất phẩm)."
	else:
		var needed: float = maxf(0.0, float(next_threshold) - merit_val)
		text += "Cần thêm %.2f điểm Công Danh để thăng lên %s (Mốc: %d điểm)." % [
			needed, next_name, next_threshold
		]
	content.text = text
	_rank_detail_popup.visible = true


func _switch_sidebar_tab(tab_id: SidebarTab) -> void:
	_current_sidebar_tab = tab_id
	_stat_detail_modal.visible = false
	_rank_detail_popup.visible = false
	refresh()


func _on_close_pressed() -> void:
	visible = false
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_ESCAPE or key.keycode == KEY_C:
			_on_close_pressed()
			get_viewport().set_input_as_handled()
