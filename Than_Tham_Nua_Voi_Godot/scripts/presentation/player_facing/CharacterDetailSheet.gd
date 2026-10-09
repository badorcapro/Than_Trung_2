class_name CharacterDetailSheet
extends Control

## CharacterDetailSheet
## Giao diện hồ sơ / trạng thái người chơi toàn màn hình phong cách Honkai: Star Rail.
## Bao gồm: Nền vũ trụ huyền ảo toàn màn hình, Switcher nhân vật ở trên đỉnh,
## Thanh điều hướng bên trái (Chi Tiết, Kỷ Vật, Vết Thánh, Túi Đồ, Thông Tin, Thời Trang),
## Khu vực đài tế hoàng cung ở trung tâm, và Bảng chi tiết thuộc tính/kỹ năng ở bên phải.

signal closed
signal finish_equipment_phase_requested

const PRODUCTION_CHARACTER_REPOSITORY := preload(
	"res://scripts/application/characters/ProductionCharacterRepository.gd"
)
const COURT_RANK_SERVICE := preload(
	"res://scripts/domain/progression/CourtRankService.gd"
)
const EQUIPMENT_ENUMS := preload("res://scripts/domain/equipment/EquipmentEnums.gd")
const EQUIPMENT_INSTANCE := preload("res://scripts/domain/equipment/EquipmentInstance.gd")
const EQUIPMENT_DEFINITION := preload("res://scripts/domain/equipment/EquipmentDefinition.gd")
const EQUIPMENT_SERVICE := preload(
	"res://scripts/application/equipment/EquipmentManagementService.gd"
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

# Fullscreen Root Components
var _backdrop_rect: ColorRect
var _celestial_backdrop: Control
var _main_margin: MarginContainer
var _player_switcher_container: HBoxContainer
var _sidebar_container: VBoxContainer
var _center_avatar_rect: TextureRect
var _center_pedestal_badge: PanelContainer
var _center_pedestal_label: Label
var _right_panel_container: MarginContainer

# Popups
var _stat_modal_overlay: Control
var _stat_detail_modal: PanelContainer
var _rank_popup_overlay: Control
var _rank_detail_popup: PanelContainer
var _finish_phase_modal_overlay: Control
var _finish_phase_modal: PanelContainer

var is_post_loot_equipment_phase: bool = false


func _init() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	_build_ui()


func _ready() -> void:
	_apply_fullscreen_layout()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED or what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_inside_tree() and visible:
			_apply_fullscreen_layout()


func _apply_fullscreen_layout() -> void:
	layout_mode = 1
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	var vp_size: Vector2 = get_viewport_rect().size if is_inside_tree() else Vector2(1920, 1080)
	size = vp_size
	custom_minimum_size = vp_size

	if _backdrop_rect != null:
		_backdrop_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_backdrop_rect.size = vp_size
	if _celestial_backdrop != null:
		_celestial_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_celestial_backdrop.size = vp_size
	if _main_margin != null:
		_main_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_main_margin.size = vp_size
	if _stat_modal_overlay != null:
		_stat_modal_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_stat_modal_overlay.size = vp_size
	if _rank_popup_overlay != null:
		_rank_popup_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_rank_popup_overlay.size = vp_size
	if _finish_phase_modal_overlay != null:
		_finish_phase_modal_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_finish_phase_modal_overlay.size = vp_size


func _build_ui() -> void:
	# 1. Solid opaque cosmic backdrop (100% OPAQUE - completely covers everything)
	_backdrop_rect = ColorRect.new()
	_backdrop_rect.color = Color(0.035, 0.045, 0.075, 1.0)
	_backdrop_rect.mouse_filter = MOUSE_FILTER_STOP
	add_child(_backdrop_rect)

	# 2. Celestial canvas (drawing stars and luminous magic circle pedestal)
	_celestial_backdrop = Control.new()
	_celestial_backdrop.mouse_filter = MOUSE_FILTER_IGNORE
	_celestial_backdrop.draw.connect(_on_celestial_draw)
	add_child(_celestial_backdrop)

	# 3. Main Fullscreen Layout Margin
	_main_margin = MarginContainer.new()
	_main_margin.mouse_filter = MOUSE_FILTER_PASS
	_main_margin.add_theme_constant_override("margin_left", 48)
	_main_margin.add_theme_constant_override("margin_top", 24)
	_main_margin.add_theme_constant_override("margin_right", 48)
	_main_margin.add_theme_constant_override("margin_bottom", 28)
	add_child(_main_margin)

	var main_vbox := VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_theme_constant_override("separation", 18)
	_main_margin.add_child(main_vbox)

	# --- TOP HEADER BAR ---
	var header_row := HBoxContainer.new()
	header_row.custom_minimum_size = Vector2(0, 56)
	header_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_theme_constant_override("separation", 24)
	main_vbox.add_child(header_row)

	# Top-Left: Screen title & subtitle
	var title_vbox := VBoxContainer.new()
	title_vbox.custom_minimum_size = Vector2(240, 0)
	title_vbox.add_theme_constant_override("separation", 2)
	var title_lbl := Label.new()
	title_lbl.text = "⭐ CHI TIẾT NHÂN VẬT"
	title_lbl.add_theme_font_size_override("font_size", 20)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45))
	title_vbox.add_child(title_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = "Hồ sơ Thần Thám Hoàng Cung"
	sub_lbl.add_theme_font_size_override("font_size", 12)
	sub_lbl.add_theme_color_override("font_color", Color(0.65, 0.72, 0.82))
	title_vbox.add_child(sub_lbl)
	header_row.add_child(title_vbox)

	# Spacer
	var spacer_left := Control.new()
	spacer_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(spacer_left)

	# Top-Center: Player Switcher Container (Horizontal avatar chips)
	_player_switcher_container = HBoxContainer.new()
	_player_switcher_container.add_theme_constant_override("separation", 16)
	header_row.add_child(_player_switcher_container)

	# Spacer right
	var spacer_right := Control.new()
	spacer_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(spacer_right)

	# Top-Right: Close button (✕)
	var close_btn := Button.new()
	close_btn.text = " ✕ "
	close_btn.custom_minimum_size = Vector2(44, 44)
	close_btn.add_theme_font_size_override("font_size", 18)
	close_btn.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	var close_style := StyleBoxFlat.new()
	close_style.bg_color = Color(0.12, 0.14, 0.2, 0.85)
	close_style.corner_radius_top_left = 22
	close_style.corner_radius_top_right = 22
	close_style.corner_radius_bottom_right = 22
	close_style.corner_radius_bottom_left = 22
	close_style.border_width_left = 1
	close_style.border_width_top = 1
	close_style.border_width_right = 1
	close_style.border_width_bottom = 1
	close_style.border_color = Color(0.4, 0.45, 0.55, 0.6)
	close_btn.add_theme_stylebox_override("normal", close_style)
	close_btn.add_theme_stylebox_override("hover", close_style)
	close_btn.add_theme_stylebox_override("pressed", close_style)
	close_btn.pressed.connect(_on_close_pressed)
	header_row.add_child(close_btn)

	# --- CONTENT BODY ROW (Sidebar, Center Stage, Right Panel) ---
	var body_row := HBoxContainer.new()
	body_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_row.add_theme_constant_override("separation", 28)
	main_vbox.add_child(body_row)

	# --- LEFT SIDEBAR (Tabs) ---
	_sidebar_container = VBoxContainer.new()
	_sidebar_container.custom_minimum_size = Vector2(190, 0)
	_sidebar_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_sidebar_container.add_theme_constant_override("separation", 10)
	body_row.add_child(_sidebar_container)
	_build_sidebar_tabs()

	# --- CENTER STAGE (Character Medallion & Pedestal) ---
	var center_box := Control.new()
	center_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_row.add_child(center_box)

	var center_vbox := VBoxContainer.new()
	center_vbox.anchors_preset = Control.PRESET_FULL_RECT
	center_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center_vbox.add_theme_constant_override("separation", 24)
	center_box.add_child(center_vbox)

	_center_avatar_rect = TextureRect.new()
	_center_avatar_rect.custom_minimum_size = Vector2(340, 340)
	_center_avatar_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_center_avatar_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_center_avatar_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	center_vbox.add_child(_center_avatar_rect)

	# Frosted glass badge below character
	_center_pedestal_badge = PanelContainer.new()
	_center_pedestal_badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = Color(0.08, 0.1, 0.16, 0.8)
	badge_style.corner_radius_top_left = 18
	badge_style.corner_radius_top_right = 18
	badge_style.corner_radius_bottom_right = 18
	badge_style.corner_radius_bottom_left = 18
	badge_style.border_width_left = 1
	badge_style.border_width_top = 1
	badge_style.border_width_right = 1
	badge_style.border_width_bottom = 1
	badge_style.border_color = Color(1.0, 0.82, 0.35, 0.7)
	badge_style.content_margin_left = 22.0
	badge_style.content_margin_top = 8.0
	badge_style.content_margin_right = 22.0
	badge_style.content_margin_bottom = 8.0
	_center_pedestal_badge.add_theme_stylebox_override("panel", badge_style)
	center_vbox.add_child(_center_pedestal_badge)

	_center_pedestal_label = Label.new()
	_center_pedestal_label.text = "◆ THẦN THÁM HOÀNG CUNG ◆"
	_center_pedestal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_center_pedestal_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.7))
	_center_pedestal_label.add_theme_font_size_override("font_size", 14)
	_center_pedestal_badge.add_child(_center_pedestal_label)

	# --- RIGHT PANEL ---
	_right_panel_container = MarginContainer.new()
	_right_panel_container.custom_minimum_size = Vector2(460, 0)
	_right_panel_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_row.add_child(_right_panel_container)

	# 4. Modals
	_build_stat_detail_modal()
	_build_rank_detail_popup()
	_build_finish_phase_modal()


func _on_celestial_draw() -> void:
	if _celestial_backdrop == null:
		return
	var s: Vector2 = _celestial_backdrop.size
	if s.x <= 0.0 or s.y <= 0.0:
		return

	# Cosmic radial aura in the center
	var center := Vector2(s.x * 0.45, s.y * 0.5)
	_celestial_backdrop.draw_circle(center, s.y * 0.45, Color(0.12, 0.16, 0.28, 0.35))
	_celestial_backdrop.draw_circle(center, s.y * 0.28, Color(0.2, 0.26, 0.42, 0.22))

	# Glowing perspective magic pedestal ring on the floor (underneath character)
	var ped_center := Vector2(s.x * 0.45, s.y * 0.78)
	var rx: float = s.x * 0.18
	var ry: float = s.y * 0.075

	# Drop shadow under pedestal
	var shadow_pts := PackedVector2Array()
	var ring_pts := PackedVector2Array()
	var segs := 48
	for i in range(segs + 1):
		var ang: float = float(i) / float(segs) * TAU
		var pt := ped_center + Vector2(cos(ang) * rx, sin(ang) * ry)
		ring_pts.append(pt)
		shadow_pts.append(pt + Vector2(0.0, 6.0))

	_celestial_backdrop.draw_polyline(shadow_pts, Color(0.02, 0.02, 0.04, 0.5), 6.0, true)
	_celestial_backdrop.draw_polyline(ring_pts, Color(0.35, 0.65, 0.95, 0.5), 4.0, true)
	_celestial_backdrop.draw_polyline(ring_pts, Color(1.0, 0.88, 0.45, 0.85), 2.0, true)

	# Fixed pseudo-random stellar dots
	var star_seeds: Array[Vector2] = [
		Vector2(0.1, 0.15), Vector2(0.18, 0.32), Vector2(0.25, 0.18), Vector2(0.32, 0.4),
		Vector2(0.42, 0.12), Vector2(0.5, 0.22), Vector2(0.58, 0.14), Vector2(0.68, 0.35),
		Vector2(0.75, 0.18), Vector2(0.82, 0.42), Vector2(0.88, 0.2), Vector2(0.15, 0.75),
		Vector2(0.28, 0.85), Vector2(0.72, 0.8), Vector2(0.85, 0.72), Vector2(0.52, 0.85)
	]
	for seed_pt: Vector2 in star_seeds:
		var pos := Vector2(seed_pt.x * s.x, seed_pt.y * s.y)
		_celestial_backdrop.draw_circle(pos + Vector2(1, 1), 2.0, Color(0.0, 0.0, 0.0, 0.4))
		_celestial_backdrop.draw_circle(pos, 1.8, Color(0.9, 0.95, 1.0, 0.75))


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
		btn.custom_minimum_size = Vector2(0, 52)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.mouse_default_cursor_shape = CURSOR_POINTING_HAND
		btn.set_meta("tab_id", tab_id)
		btn.pressed.connect(func() -> void: _switch_sidebar_tab(tab_id))
		_sidebar_container.add_child(btn)


func _build_stat_detail_modal() -> void:
	_stat_modal_overlay = Control.new()
	_stat_modal_overlay.visible = false
	_stat_modal_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_stat_modal_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_stat_modal_overlay)

	var dim_rect := ColorRect.new()
	dim_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim_rect.color = Color(0, 0, 0, 0.6)
	dim_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	dim_rect.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			_stat_modal_overlay.visible = false
	)
	_stat_modal_overlay.add_child(dim_rect)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_PASS
	_stat_modal_overlay.add_child(center)

	_stat_detail_modal = PanelContainer.new()
	_stat_detail_modal.custom_minimum_size = Vector2(460, 360)
	var modal_style := StyleBoxFlat.new()
	modal_style.bg_color = Color(0.95, 0.96, 0.97, 0.99) # Light modal like Image 2
	modal_style.corner_radius_top_left = 14
	modal_style.corner_radius_top_right = 14
	modal_style.corner_radius_bottom_right = 14
	modal_style.corner_radius_bottom_left = 14
	modal_style.shadow_color = Color(0, 0, 0, 0.65)
	modal_style.shadow_size = 28
	modal_style.content_margin_left = 28.0
	modal_style.content_margin_top = 22.0
	modal_style.content_margin_right = 28.0
	modal_style.content_margin_bottom = 22.0
	_stat_detail_modal.add_theme_stylebox_override("panel", modal_style)
	center.add_child(_stat_detail_modal)

	var modal_vbox := VBoxContainer.new()
	modal_vbox.name = "ModalVBox"
	modal_vbox.add_theme_constant_override("separation", 14)
	_stat_detail_modal.add_child(modal_vbox)

	var header_bar := HBoxContainer.new()
	var title := Label.new()
	title.text = "Chi Tiết Thuộc Tính"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.12, 0.14, 0.18))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_bar.add_child(title)

	var close_x := Button.new()
	close_x.text = " ✕ "
	close_x.flat = true
	close_x.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	close_x.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	close_x.pressed.connect(func() -> void: _stat_modal_overlay.visible = false)
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
	stats_rows_container.add_theme_constant_override("separation", 12)
	modal_vbox.add_child(stats_rows_container)


func _build_rank_detail_popup() -> void:
	_rank_popup_overlay = Control.new()
	_rank_popup_overlay.visible = false
	_rank_popup_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_rank_popup_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_rank_popup_overlay)

	var dim_rect := ColorRect.new()
	dim_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim_rect.color = Color(0, 0, 0, 0.6)
	dim_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	dim_rect.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			_rank_popup_overlay.visible = false
	)
	_rank_popup_overlay.add_child(dim_rect)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_PASS
	_rank_popup_overlay.add_child(center)

	_rank_detail_popup = PanelContainer.new()
	_rank_detail_popup.custom_minimum_size = Vector2(380, 240)
	var pop_style := StyleBoxFlat.new()
	pop_style.bg_color = Color(0.1, 0.12, 0.18, 0.98)
	pop_style.corner_radius_top_left = 14
	pop_style.corner_radius_top_right = 14
	pop_style.corner_radius_bottom_right = 14
	pop_style.corner_radius_bottom_left = 14
	pop_style.border_width_left = 1
	pop_style.border_width_top = 1
	pop_style.border_width_right = 1
	pop_style.border_width_bottom = 1
	pop_style.border_color = Color(1.0, 0.82, 0.28, 0.9)
	pop_style.shadow_color = Color(0, 0, 0, 0.65)
	pop_style.shadow_size = 28
	pop_style.content_margin_left = 24.0
	pop_style.content_margin_top = 20.0
	pop_style.content_margin_right = 24.0
	pop_style.content_margin_bottom = 20.0
	_rank_detail_popup.add_theme_stylebox_override("panel", pop_style)
	center.add_child(_rank_detail_popup)

	var pop_vbox := VBoxContainer.new()
	pop_vbox.name = "RankPopVBox"
	pop_vbox.add_theme_constant_override("separation", 10)
	_rank_detail_popup.add_child(pop_vbox)

	var pop_head := HBoxContainer.new()
	var pop_title := Label.new()
	pop_title.text = "🔍 BẬC CÔNG DANH HOÀNG CUNG"
	pop_title.add_theme_font_size_override("font_size", 15)
	pop_title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.25))
	pop_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pop_head.add_child(pop_title)

	var close_pop := Button.new()
	close_pop.text = " ✕ "
	close_pop.flat = true
	close_pop.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	close_pop.pressed.connect(func() -> void: _rank_popup_overlay.visible = false)
	pop_head.add_child(close_pop)
	pop_vbox.add_child(pop_head)

	var pop_content := Label.new()
	pop_content.name = "RankContent"
	pop_content.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pop_content.add_theme_font_size_override("font_size", 13)
	pop_content.add_theme_color_override("font_color", Color(0.88, 0.92, 0.96))
	pop_vbox.add_child(pop_content)


func _build_finish_phase_modal() -> void:
	_finish_phase_modal_overlay = Control.new()
	_finish_phase_modal_overlay.visible = false
	_finish_phase_modal_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_finish_phase_modal_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_finish_phase_modal_overlay)

	var dim_rect := ColorRect.new()
	dim_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim_rect.color = Color(0, 0, 0, 0.65)
	dim_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	_finish_phase_modal_overlay.add_child(dim_rect)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_PASS
	_finish_phase_modal_overlay.add_child(center)

	_finish_phase_modal = PanelContainer.new()
	_finish_phase_modal.custom_minimum_size = Vector2(480, 240)
	var modal_style := StyleBoxFlat.new()
	modal_style.bg_color = Color(0.1, 0.12, 0.18, 0.98)
	modal_style.corner_radius_top_left = 14
	modal_style.corner_radius_top_right = 14
	modal_style.corner_radius_bottom_right = 14
	modal_style.corner_radius_bottom_left = 14
	modal_style.border_width_left = 1
	modal_style.border_width_top = 1
	modal_style.border_width_right = 1
	modal_style.border_width_bottom = 1
	modal_style.border_color = Color(1.0, 0.82, 0.28, 0.9)
	modal_style.shadow_color = Color(0, 0, 0, 0.65)
	modal_style.shadow_size = 28
	modal_style.content_margin_left = 28.0
	modal_style.content_margin_top = 22.0
	modal_style.content_margin_right = 28.0
	modal_style.content_margin_bottom = 22.0
	_finish_phase_modal.add_theme_stylebox_override("panel", modal_style)
	center.add_child(_finish_phase_modal)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	_finish_phase_modal.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = "⚖️ XÁC NHẬN KẾT THÚC CHUẨN BỊ"
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.84, 0.25))
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_lbl)

	var prompt_lbl := Label.new()
	prompt_lbl.text = "Đi đến phần tổng kết round?"
	prompt_lbl.add_theme_font_size_override("font_size", 20)
	prompt_lbl.add_theme_color_override("font_color", Color(0.96, 0.96, 0.98))
	prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(prompt_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = "Hãy chắc chắn rằng tất cả người chơi đã hoàn tất trang bị Kỷ Vật và Vết Thánh trước khi tiếp tục."
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.add_theme_font_size_override("font_size", 13)
	desc_lbl.add_theme_color_override("font_color", Color(0.72, 0.78, 0.85))
	vbox.add_child(desc_lbl)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 16)
	vbox.add_child(btn_row)

	var cancel_btn := Button.new()
	cancel_btn.text = "Ở lại chuẩn bị"
	cancel_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cancel_btn.custom_minimum_size = Vector2(0, 42)
	cancel_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var cancel_style := StyleBoxFlat.new()
	cancel_style.bg_color = Color(0.18, 0.2, 0.26, 0.9)
	cancel_style.corner_radius_top_left = 8
	cancel_style.corner_radius_top_right = 8
	cancel_style.corner_radius_bottom_right = 8
	cancel_style.corner_radius_bottom_left = 8
	cancel_btn.add_theme_stylebox_override("normal", cancel_style)
	cancel_btn.add_theme_stylebox_override("hover", cancel_style)
	cancel_btn.add_theme_stylebox_override("pressed", cancel_style)
	cancel_btn.pressed.connect(func() -> void:
		_finish_phase_modal_overlay.visible = false
	)
	btn_row.add_child(cancel_btn)

	var confirm_btn := Button.new()
	confirm_btn.text = "Xác nhận & Đi tiếp"
	confirm_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	confirm_btn.custom_minimum_size = Vector2(0, 42)
	confirm_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var conf_style := StyleBoxFlat.new()
	conf_style.bg_color = Color(0.85, 0.65, 0.15, 0.95)
	conf_style.corner_radius_top_left = 8
	conf_style.corner_radius_top_right = 8
	conf_style.corner_radius_bottom_right = 8
	conf_style.corner_radius_bottom_left = 8
	confirm_btn.add_theme_stylebox_override("normal", conf_style)
	confirm_btn.add_theme_stylebox_override("hover", conf_style)
	confirm_btn.add_theme_stylebox_override("pressed", conf_style)
	confirm_btn.add_theme_color_override("font_color", Color(0.1, 0.1, 0.12))
	confirm_btn.pressed.connect(func() -> void:
		_finish_phase_modal_overlay.visible = false
		visible = false
		finish_equipment_phase_requested.emit()
	)
	btn_row.add_child(confirm_btn)


func open_sheet(
	player_id: StringName,
	case_flow_session: Variant,
	setup_session: Variant,
	is_post_loot: bool = false
) -> void:
	_apply_fullscreen_layout()
	_case_flow_session = case_flow_session
	_setup_session = setup_session
	_active_player_id = player_id
	is_post_loot_equipment_phase = is_post_loot
	if is_post_loot_equipment_phase:
		_current_sidebar_tab = SidebarTab.RELICS
	else:
		_current_sidebar_tab = SidebarTab.DETAILS
	_current_detail_subtab = DetailSubTab.ATTRIBUTES
	visible = true
	if _stat_modal_overlay != null:
		_stat_modal_overlay.visible = false
	if _rank_popup_overlay != null:
		_rank_popup_overlay.visible = false
	if _finish_phase_modal_overlay != null:
		_finish_phase_modal_overlay.visible = false
	refresh()
	if _celestial_backdrop != null:
		_celestial_backdrop.queue_redraw()


func refresh() -> void:
	if _setup_session == null or _case_flow_session == null:
		return
	var player_order: Array[StringName] = []
	if _case_flow_session.equipment_session != null:
		player_order = _case_flow_session.equipment_session.player_order
	elif _case_flow_session.loot_session != null and _case_flow_session.loot_session.movement_session != null:
		player_order = _case_flow_session.loot_session.movement_session.ordered_player_ids

	if not player_order.has(_active_player_id):
		if not player_order.is_empty():
			_active_player_id = player_order[0]
		else:
			return

	if _case_flow_session.equipment_session != null:
		var idx: int = _case_flow_session.equipment_session.player_order.find(_active_player_id)
		if idx >= 0:
			_case_flow_session.equipment_session.current_player_index = idx

	_refresh_player_switcher(player_order)
	_refresh_sidebar_buttons()
	_refresh_center_display()
	_refresh_right_panel()
	if _celestial_backdrop != null:
		_celestial_backdrop.queue_redraw()


func _get_active_player_state() -> PlayerPhaseState:
	if _case_flow_session == null:
		return null
	if _case_flow_session.equipment_session != null:
		var p: PlayerPhaseState = _case_flow_session.equipment_session.find_player(_active_player_id)
		if p != null:
			return p
	if _case_flow_session.loot_session != null:
		var p: PlayerPhaseState = _case_flow_session.loot_session.find_player(_active_player_id)
		if p != null:
			return p
	return null


func _find_equipment_def(def_id: StringName) -> EquipmentDefinition:
	if _case_flow_session != null and _case_flow_session.has_method("find_management_equipment_definition"):
		var d: EquipmentDefinition = _case_flow_session.find_management_equipment_definition(def_id)
		if d != null:
			return d
	return null


func _tier_badge_info(tier_val: int) -> Dictionary:
	match tier_val:
		EQUIPMENT_ENUMS.Tier.A:
			return {"name": "Phẩm A", "color": Color(0.4, 0.75, 1.0)}
		EQUIPMENT_ENUMS.Tier.S:
			return {"name": "Phẩm S", "color": Color(0.85, 0.45, 1.0)}
		EQUIPMENT_ENUMS.Tier.SS:
			return {"name": "Phẩm SS", "color": Color(1.0, 0.85, 0.25)}
		_:
			return {"name": "Phẩm A", "color": Color(0.5, 0.8, 1.0)}


func _equipment_display_name(inst: EquipmentInstance) -> String:
	if inst == null:
		return "Trang bị"
	var def: EquipmentDefinition = _find_equipment_def(inst.equipment_definition_id)
	if def != null and not def.display_name.is_empty():
		return def.display_name
	var raw: String = String(inst.equipment_definition_id)
	return raw.replace("_", " ").capitalize()


func _equip_item(instance_id: StringName, slot_id: StringName) -> void:
	var p_state: PlayerPhaseState = _get_active_player_state()
	if p_state == null:
		return
	if _case_flow_session != null and _case_flow_session.equipment_session != null:
		var idx: int = _case_flow_session.equipment_session.player_order.find(_active_player_id)
		if idx >= 0:
			_case_flow_session.equipment_session.current_player_index = idx
		var _res: Dictionary = _case_flow_session.equip_owned_equipment(instance_id, slot_id)
	else:
		var svc := EQUIPMENT_SERVICE.new()
		var _res: EquipmentActionResult = svc.equip_to_slot(p_state, instance_id, slot_id)
	refresh()


func _unequip_slot(slot_id: StringName) -> void:
	var p_state: PlayerPhaseState = _get_active_player_state()
	if p_state == null:
		return
	if _case_flow_session != null and _case_flow_session.equipment_session != null:
		var idx: int = _case_flow_session.equipment_session.player_order.find(_active_player_id)
		if idx >= 0:
			_case_flow_session.equipment_session.current_player_index = idx
		var _res: Dictionary = _case_flow_session.unequip_equipment_slot(slot_id)
	else:
		var svc := EQUIPMENT_SERVICE.new()
		var _res: EquipmentActionResult = svc.unequip_slot(p_state, slot_id)
	refresh()


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
		btn.custom_minimum_size = Vector2(56, 56)
		btn.mouse_default_cursor_shape = CURSOR_POINTING_HAND
		btn.tooltip_text = "%s - %s" % [
			badges[i % badges.size()],
			char_def.display_name if char_def != null else String(pid)
		]

		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.14, 0.18, 0.26, 0.95) if is_current else Color(0.08, 0.1, 0.14, 0.8)
		style.corner_radius_top_left = 28
		style.corner_radius_top_right = 28
		style.corner_radius_bottom_right = 28
		style.corner_radius_bottom_left = 28
		style.border_width_left = 3 if is_current else 1
		style.border_width_top = 3 if is_current else 1
		style.border_width_right = 3 if is_current else 1
		style.border_width_bottom = 3 if is_current else 1
		style.border_color = Color(1.0, 0.84, 0.22) if is_current else badge_colors[i % badge_colors.size()]
		if is_current:
			style.shadow_color = Color(1.0, 0.8, 0.2, 0.4)
			style.shadow_size = 8
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
		style.corner_radius_top_left = 10
		style.corner_radius_top_right = 10
		style.corner_radius_bottom_right = 10
		style.corner_radius_bottom_left = 10
		style.content_margin_left = 18.0
		style.content_margin_top = 12.0
		style.content_margin_right = 18.0
		style.content_margin_bottom = 12.0
		if is_active:
			style.bg_color = Color(0.2, 0.25, 0.38, 0.95)
			style.border_width_left = 4
			style.border_color = Color(1.0, 0.84, 0.25)
			btn.add_theme_color_override("font_color", Color(1.0, 0.92, 0.65))
		else:
			style.bg_color = Color(0.08, 0.1, 0.14, 0.7)
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
	var elem_icon: String = String(lore.get("element_icon", "★"))
	_center_pedestal_label.text = "✦ %s  %s · %s ✦" % [
		elem_icon,
		char_name.to_upper(),
		house_name.to_upper()
	]


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
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 16)
	_right_panel_container.add_child(vbox)

	# 1. Header Card (Name, Element, House, Diamonds, Merit)
	var header_panel := PanelContainer.new()
	var h_style := StyleBoxFlat.new()
	h_style.bg_color = Color(0.08, 0.1, 0.16, 0.88)
	h_style.corner_radius_top_left = 12
	h_style.corner_radius_top_right = 12
	h_style.corner_radius_bottom_right = 12
	h_style.corner_radius_bottom_left = 12
	h_style.border_width_left = 1
	h_style.border_width_top = 1
	h_style.border_width_right = 1
	h_style.border_width_bottom = 1
	h_style.border_color = Color(0.3, 0.38, 0.5, 0.45)
	h_style.content_margin_left = 20.0
	h_style.content_margin_top = 16.0
	h_style.content_margin_right = 20.0
	h_style.content_margin_bottom = 16.0
	header_panel.add_theme_stylebox_override("panel", h_style)
	vbox.add_child(header_panel)

	var h_vbox := VBoxContainer.new()
	h_vbox.add_theme_constant_override("separation", 8)
	header_panel.add_child(h_vbox)

	# Name + Element
	var name_row := HBoxContainer.new()
	var name_lbl := Label.new()
	name_lbl.text = "⭐ %s" % (char_def.display_name if char_def != null else "Nhân vật")
	name_lbl.add_theme_font_size_override("font_size", 24)
	name_lbl.add_theme_color_override("font_color", Color(1.0, 0.94, 0.8))
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_row.add_child(name_lbl)

	var elem_lbl := Label.new()
	var elem_color: Color = lore.get("element_color", Color(0.4, 0.8, 1.0))
	elem_lbl.text = "%s %s" % [lore.get("element_icon", "★"), lore.get("element_name", "Vô Cực")]
	elem_lbl.add_theme_font_size_override("font_size", 17)
	elem_lbl.add_theme_color_override("font_color", elem_color)
	name_row.add_child(elem_lbl)
	h_vbox.add_child(name_row)

	# House origin
	var house_lbl := Label.new()
	house_lbl.text = "🏛️ %s" % lore.get("house_name", "Hoàng Cung")
	house_lbl.add_theme_font_size_override("font_size", 13)
	house_lbl.add_theme_color_override("font_color", Color(0.72, 0.8, 0.9))
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
	dia_prefix.add_theme_color_override("font_color", Color(0.68, 0.74, 0.8))
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
	orb_count_tag.add_theme_color_override("font_color", Color(0.85, 0.88, 0.9))
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
	merit_lbl.add_theme_color_override("font_color", Color(0.96, 0.9, 0.7))
	merit_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	pill_row.add_theme_constant_override("separation", 12)
	vbox.add_child(pill_row)

	var attr_pill := Button.new()
	attr_pill.text = "Thuộc Tính"
	attr_pill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	attr_pill.custom_minimum_size = Vector2(0, 42)
	attr_pill.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	_style_subtab_pill(attr_pill, _current_detail_subtab == DetailSubTab.ATTRIBUTES)
	attr_pill.pressed.connect(func() -> void:
		_current_detail_subtab = DetailSubTab.ATTRIBUTES
		refresh()
	)
	pill_row.add_child(attr_pill)

	var skill_pill := Button.new()
	skill_pill.text = "Kỹ Năng"
	skill_pill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	skill_pill.custom_minimum_size = Vector2(0, 42)
	skill_pill.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	_style_subtab_pill(skill_pill, _current_detail_subtab == DetailSubTab.SKILLS)
	skill_pill.pressed.connect(func() -> void:
		_current_detail_subtab = DetailSubTab.SKILLS
		refresh()
	)
	pill_row.add_child(skill_pill)

	# 3. Subtab Content Area
	var subtab_panel := PanelContainer.new()
	subtab_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var s_style := StyleBoxFlat.new()
	s_style.bg_color = Color(0.07, 0.085, 0.13, 0.9)
	s_style.corner_radius_top_left = 12
	s_style.corner_radius_top_right = 12
	s_style.corner_radius_bottom_right = 12
	s_style.corner_radius_bottom_left = 12
	s_style.border_width_left = 1
	s_style.border_width_top = 1
	s_style.border_width_right = 1
	s_style.border_width_bottom = 1
	s_style.border_color = Color(0.25, 0.32, 0.44, 0.4)
	s_style.content_margin_left = 18.0
	s_style.content_margin_top = 16.0
	s_style.content_margin_right = 18.0
	s_style.content_margin_bottom = 16.0
	subtab_panel.add_theme_stylebox_override("panel", s_style)
	vbox.add_child(subtab_panel)

	if _current_detail_subtab == DetailSubTab.ATTRIBUTES:
		_render_attributes_subtab(subtab_panel)
	else:
		_render_skills_subtab(subtab_panel, lore)


func _style_subtab_pill(btn: Button, is_active: bool) -> void:
	var style := StyleBoxFlat.new()
	style.corner_radius_top_left = 21
	style.corner_radius_top_right = 21
	style.corner_radius_bottom_right = 21
	style.corner_radius_bottom_left = 21
	if is_active:
		style.bg_color = Color(0.94, 0.96, 0.98, 0.96)
		btn.add_theme_color_override("font_color", Color(0.08, 0.1, 0.15))
	else:
		style.bg_color = Color(0.12, 0.15, 0.22, 0.8)
		btn.add_theme_color_override("font_color", Color(0.75, 0.82, 0.9))
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)


func _render_attributes_subtab(container: Control) -> void:
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 18)
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
		icon_lbl.add_theme_font_size_override("font_size", 20)
		row.add_child(icon_lbl)

		var name_lbl := Label.new()
		name_lbl.text = s["name"]
		name_lbl.add_theme_font_size_override("font_size", 15)
		name_lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_lbl)

		var val_lbl := Label.new()
		val_lbl.text = s["val"]
		val_lbl.add_theme_font_size_override("font_size", 18)
		val_lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.8))
		row.add_child(val_lbl)
		vbox.add_child(row)

	var note_lbl := Label.new()
	note_lbl.text = "💡 Sức Mạnh tương đương dung tích túi đồ. Mỗi điểm cầm thêm 1 món khi loot."
	note_lbl.add_theme_font_size_override("font_size", 12)
	note_lbl.add_theme_color_override("font_color", Color(0.68, 0.75, 0.8))
	note_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(note_lbl)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	# Button "Chi Tiết Thuộc Tính" (Opens Image 3 popup)
	var detail_btn := Button.new()
	detail_btn.text = "Chi Tiết Thuộc Tính"
	detail_btn.custom_minimum_size = Vector2(180, 42)
	detail_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	detail_btn.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.18, 0.22, 0.32, 0.9)
	btn_style.corner_radius_top_left = 10
	btn_style.corner_radius_top_right = 10
	btn_style.corner_radius_bottom_right = 10
	btn_style.corner_radius_bottom_left = 10
	btn_style.border_width_left = 1
	btn_style.border_width_top = 1
	btn_style.border_width_right = 1
	btn_style.border_width_bottom = 1
	btn_style.border_color = Color(0.4, 0.5, 0.65, 0.6)
	detail_btn.add_theme_stylebox_override("normal", btn_style)
	detail_btn.add_theme_stylebox_override("hover", btn_style)
	detail_btn.add_theme_stylebox_override("pressed", btn_style)
	detail_btn.pressed.connect(_on_open_stat_detail_modal_pressed)
	vbox.add_child(detail_btn)


func _render_skills_subtab(container: Control, lore: Dictionary) -> void:
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 12)
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
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	vbox.add_child(grid)

	for i in range(skill_list.size()):
		var sk: Dictionary = skill_list[i]
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(204, 68)
		btn.mouse_default_cursor_shape = CURSOR_POINTING_HAND

		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.14, 0.18, 0.26, 0.9) if _selected_skill_index == i else Color(0.08, 0.1, 0.15, 0.7)
		style.corner_radius_top_left = 10
		style.corner_radius_top_right = 10
		style.corner_radius_bottom_right = 10
		style.corner_radius_bottom_left = 10
		style.border_width_left = 2 if _selected_skill_index == i else 1
		style.border_width_top = 2 if _selected_skill_index == i else 1
		style.border_width_right = 2 if _selected_skill_index == i else 1
		style.border_width_bottom = 2 if _selected_skill_index == i else 1
		style.border_color = Color(1.0, 0.84, 0.25) if _selected_skill_index == i else Color(0.3, 0.38, 0.5, 0.4)
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)

		btn.text = "%s %s\n[%s]" % [sk["icon"], sk["name"], sk["tag"]]
		btn.add_theme_font_size_override("font_size", 12)
		btn.add_theme_color_override("font_color", Color(1.0, 0.9, 0.7) if _selected_skill_index == i else Color(0.78, 0.84, 0.9))

		var cur_i := i
		btn.pressed.connect(func() -> void:
			_selected_skill_index = cur_i
			refresh()
		)
		grid.add_child(btn)

	# Selected skill detail description box
	var selected_sk: Dictionary = skill_list[clampi(_selected_skill_index, 0, skill_list.size() - 1)]
	var desc_box := PanelContainer.new()
	desc_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var db_style := StyleBoxFlat.new()
	db_style.bg_color = Color(0.05, 0.065, 0.1, 0.95)
	db_style.corner_radius_top_left = 10
	db_style.corner_radius_top_right = 10
	db_style.corner_radius_bottom_right = 10
	db_style.corner_radius_bottom_left = 10
	db_style.content_margin_left = 16.0
	db_style.content_margin_top = 14.0
	db_style.content_margin_right = 16.0
	db_style.content_margin_bottom = 14.0
	desc_box.add_theme_stylebox_override("panel", db_style)
	vbox.add_child(desc_box)

	var desc_vbox := VBoxContainer.new()
	desc_vbox.add_theme_constant_override("separation", 8)
	desc_box.add_child(desc_vbox)

	var sk_title := Label.new()
	sk_title.text = "%s %s (%s)" % [selected_sk["icon"], selected_sk["name"], selected_sk["type"]]
	sk_title.add_theme_font_size_override("font_size", 15)
	sk_title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.3))
	desc_vbox.add_child(sk_title)

	var sk_desc := Label.new()
	sk_desc.text = selected_sk["desc"]
	sk_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sk_desc.add_theme_font_size_override("font_size", 13)
	sk_desc.add_theme_color_override("font_color", Color(0.9, 0.92, 0.96))
	desc_vbox.add_child(sk_desc)


# -----------------------------------------------------------------------------
# TAB 2: KỶ VẬT (Relics)
# -----------------------------------------------------------------------------
func _render_tab_relics() -> void:
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 14)
	_right_panel_container.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = "🏺 KỶ VẬT HOÀNG GIA (RELICS)"
	title_lbl.add_theme_font_size_override("font_size", 20)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(title_lbl)

	if is_post_loot_equipment_phase:
		var phase_hint := Label.new()
		phase_hint.text = "⚖️ Giai đoạn chuẩn bị: Thiết lập Kỷ Vật & Vết Thánh cho các người chơi. Bấm ✕ khi hoàn tất để đi đến Tổng Kết Round."
		phase_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		phase_hint.add_theme_font_size_override("font_size", 12)
		phase_hint.add_theme_color_override("font_color", Color(0.95, 0.8, 0.4))
		vbox.add_child(phase_hint)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)

	var content_vbox := VBoxContainer.new()
	content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_vbox.add_theme_constant_override("separation", 16)
	scroll.add_child(content_vbox)

	var p_state: PlayerPhaseState = _get_active_player_state()
	var relic_inst: EquipmentInstance = null
	if p_state != null and not p_state.relic_instance_id.is_empty():
		for inst: EquipmentInstance in p_state.equipment_collection:
			if inst.instance_id == p_state.relic_instance_id:
				relic_inst = inst
				break

	# 1. Equipped Relic Section
	var eq_title := Label.new()
	eq_title.text = "👑 KỶ VẬT ĐANG TRANG BỊ"
	eq_title.add_theme_font_size_override("font_size", 14)
	eq_title.add_theme_color_override("font_color", Color(0.9, 0.92, 0.98))
	content_vbox.add_child(eq_title)

	var eq_card := PanelContainer.new()
	var eq_style := StyleBoxFlat.new()
	eq_style.bg_color = Color(0.1, 0.13, 0.2, 0.92)
	eq_style.corner_radius_top_left = 12
	eq_style.corner_radius_top_right = 12
	eq_style.corner_radius_bottom_right = 12
	eq_style.corner_radius_bottom_left = 12
	eq_style.border_width_left = 2
	eq_style.border_width_top = 2
	eq_style.border_width_right = 2
	eq_style.border_width_bottom = 2
	eq_style.border_color = Color(1.0, 0.82, 0.25, 0.85) if relic_inst != null else Color(0.3, 0.35, 0.45, 0.5)
	eq_style.content_margin_left = 18.0
	eq_style.content_margin_top = 14.0
	eq_style.content_margin_right = 18.0
	eq_style.content_margin_bottom = 14.0
	eq_card.add_theme_stylebox_override("panel", eq_style)
	content_vbox.add_child(eq_card)

	var eq_hbox := HBoxContainer.new()
	eq_hbox.add_theme_constant_override("separation", 12)
	eq_card.add_child(eq_hbox)

	var eq_vbox := VBoxContainer.new()
	eq_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	eq_vbox.add_theme_constant_override("separation", 4)
	eq_hbox.add_child(eq_vbox)

	if relic_inst != null:
		var name_lbl := Label.new()
		name_lbl.text = "👑 %s" % _equipment_display_name(relic_inst)
		name_lbl.add_theme_font_size_override("font_size", 16)
		name_lbl.add_theme_color_override("font_color", Color(1.0, 0.92, 0.7))
		eq_vbox.add_child(name_lbl)

		var tier_badge := _tier_badge_info(relic_inst.tier)
		var stats_lbl := Label.new()
		stats_lbl.text = "[%s]  ⭐ Cấp Vàng: %d  |  🔮 Cấp Tím: %d" % [
			tier_badge.get("name", "Phẩm A"),
			relic_inst.gold_star_level,
			relic_inst.purple_star_level
		]
		stats_lbl.add_theme_font_size_override("font_size", 12)
		stats_lbl.add_theme_color_override("font_color", tier_badge.get("color", Color(0.7, 0.8, 0.9)))
		eq_vbox.add_child(stats_lbl)

		var unequip_btn := Button.new()
		unequip_btn.text = "✕ Tháo Kỷ Vật"
		unequip_btn.custom_minimum_size = Vector2(120, 36)
		unequip_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var unequip_style := StyleBoxFlat.new()
		unequip_style.bg_color = Color(0.35, 0.15, 0.18, 0.85)
		unequip_style.corner_radius_top_left = 8
		unequip_style.corner_radius_top_right = 8
		unequip_style.corner_radius_bottom_right = 8
		unequip_style.corner_radius_bottom_left = 8
		unequip_btn.add_theme_stylebox_override("normal", unequip_style)
		unequip_btn.add_theme_stylebox_override("hover", unequip_style)
		unequip_btn.add_theme_stylebox_override("pressed", unequip_style)
		unequip_btn.pressed.connect(func() -> void:
			_unequip_slot(EQUIPMENT_SERVICE.SLOT_RELIC)
		)
		eq_hbox.add_child(unequip_btn)
	else:
		var empty_lbl := Label.new()
		empty_lbl.text = "(Chưa trang bị Kỷ Vật)"
		empty_lbl.add_theme_font_size_override("font_size", 13)
		empty_lbl.add_theme_color_override("font_color", Color(0.55, 0.6, 0.68))
		eq_vbox.add_child(empty_lbl)

	# 2. Owned Relics Section
	var inv_title := Label.new()
	inv_title.text = "📦 KHO KỶ VẬT SỞ HỮU"
	inv_title.add_theme_font_size_override("font_size", 14)
	inv_title.add_theme_color_override("font_color", Color(0.85, 0.88, 0.95))
	content_vbox.add_child(inv_title)

	var owned_relics: Array[EquipmentInstance] = []
	if p_state != null:
		for inst: EquipmentInstance in p_state.equipment_collection:
			if inst.equipment_type == EQUIPMENT_ENUMS.EquipmentType.RELIC:
				owned_relics.append(inst)

	if owned_relics.is_empty():
		var no_item := Label.new()
		no_item.text = "(Hiện chưa có Kỷ Vật nào trong kho. Hãy quay Gacha hoặc thu thập thêm)"
		no_item.add_theme_font_size_override("font_size", 12)
		no_item.add_theme_color_override("font_color", Color(0.5, 0.55, 0.65))
		content_vbox.add_child(no_item)
	else:
		for inst: EquipmentInstance in owned_relics:
			var item_card := PanelContainer.new()
			var ic_style := StyleBoxFlat.new()
			ic_style.bg_color = Color(0.08, 0.1, 0.15, 0.85)
			ic_style.corner_radius_top_left = 8
			ic_style.corner_radius_top_right = 8
			ic_style.corner_radius_bottom_right = 8
			ic_style.corner_radius_bottom_left = 8
			ic_style.content_margin_left = 14.0
			ic_style.content_margin_top = 10.0
			ic_style.content_margin_right = 14.0
			ic_style.content_margin_bottom = 10.0
			item_card.add_theme_stylebox_override("panel", ic_style)
			content_vbox.add_child(item_card)

			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 10)
			item_card.add_child(row)

			var info_vbox := VBoxContainer.new()
			info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(info_vbox)

			var r_name := Label.new()
			r_name.text = _equipment_display_name(inst)
			r_name.add_theme_font_size_override("font_size", 14)
			r_name.add_theme_color_override("font_color", Color(0.9, 0.94, 0.98))
			info_vbox.add_child(r_name)

			var tb := _tier_badge_info(inst.tier)
			var r_sub := Label.new()
			r_sub.text = "[%s]  ⭐ Cấp %d  |  🔮 Cấp %d" % [
				tb.get("name", "Phẩm A"), inst.gold_star_level, inst.purple_star_level
			]
			r_sub.add_theme_font_size_override("font_size", 11)
			r_sub.add_theme_color_override("font_color", tb.get("color", Color(0.65, 0.72, 0.82)))
			info_vbox.add_child(r_sub)

			var is_equipped: bool = (p_state != null and inst.instance_id == p_state.relic_instance_id)
			if is_equipped:
				var eq_tag := Label.new()
				eq_tag.text = "✔ Đang trang bị"
				eq_tag.add_theme_font_size_override("font_size", 12)
				eq_tag.add_theme_color_override("font_color", Color(0.4, 0.88, 0.5))
				row.add_child(eq_tag)
			else:
				var equip_btn := Button.new()
				equip_btn.text = "⚔️ Trang Bị"
				equip_btn.custom_minimum_size = Vector2(96, 32)
				equip_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
				var eb_style := StyleBoxFlat.new()
				eb_style.bg_color = Color(0.2, 0.35, 0.55, 0.9)
				eb_style.corner_radius_top_left = 6
				eb_style.corner_radius_top_right = 6
				eb_style.corner_radius_bottom_right = 6
				eb_style.corner_radius_bottom_left = 6
				equip_btn.add_theme_stylebox_override("normal", eb_style)
				equip_btn.add_theme_stylebox_override("hover", eb_style)
				equip_btn.add_theme_stylebox_override("pressed", eb_style)
				var target_inst_id: StringName = inst.instance_id
				equip_btn.pressed.connect(func() -> void:
					_equip_item(target_inst_id, EQUIPMENT_SERVICE.SLOT_RELIC)
				)
				row.add_child(equip_btn)


# -----------------------------------------------------------------------------
# TAB 3: VẾT THÁNH (Stigmata)
# -----------------------------------------------------------------------------
func _render_tab_stigmata() -> void:
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 14)
	_right_panel_container.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = "📜 VẾT THÁNH BẢO VỆ (STIGMATA)"
	title_lbl.add_theme_font_size_override("font_size", 20)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(title_lbl)

	if is_post_loot_equipment_phase:
		var phase_hint := Label.new()
		phase_hint.text = "⚖️ Giai đoạn chuẩn bị: Thiết lập Kỷ Vật & Vết Thánh cho các người chơi. Bấm ✕ khi hoàn tất để đi đến Tổng Kết Round."
		phase_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		phase_hint.add_theme_font_size_override("font_size", 12)
		phase_hint.add_theme_color_override("font_color", Color(0.95, 0.8, 0.4))
		vbox.add_child(phase_hint)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)

	var content_vbox := VBoxContainer.new()
	content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_vbox.add_theme_constant_override("separation", 16)
	scroll.add_child(content_vbox)

	var p_state: PlayerPhaseState = _get_active_player_state()

	var slot_configs: Array[Dictionary] = [
		{
			"title": "✨ VỊ TRÍ A (THƯỢNG)",
			"slot_const": EQUIPMENT_SERVICE.SLOT_STIGMATA_A,
			"slot_enum": EQUIPMENT_ENUMS.StigmataSlot.A,
			"equipped_id": p_state.stigmata_a_instance_id if p_state != null else &""
		},
		{
			"title": "✨ VỊ TRÍ B (TRUNG)",
			"slot_const": EQUIPMENT_SERVICE.SLOT_STIGMATA_B,
			"slot_enum": EQUIPMENT_ENUMS.StigmataSlot.B,
			"equipped_id": p_state.stigmata_b_instance_id if p_state != null else &""
		},
		{
			"title": "✨ VỊ TRÍ C (HẠ)",
			"slot_const": EQUIPMENT_SERVICE.SLOT_STIGMATA_C,
			"slot_enum": EQUIPMENT_ENUMS.StigmataSlot.C,
			"equipped_id": p_state.stigmata_c_instance_id if p_state != null else &""
		},
	]

	for cfg: Dictionary in slot_configs:
		var slot_card := PanelContainer.new()
		var sc_style := StyleBoxFlat.new()
		sc_style.bg_color = Color(0.08, 0.1, 0.16, 0.9)
		sc_style.corner_radius_top_left = 10
		sc_style.corner_radius_top_right = 10
		sc_style.corner_radius_bottom_right = 10
		sc_style.corner_radius_bottom_left = 10
		sc_style.border_width_left = 1
		sc_style.border_width_top = 1
		sc_style.border_width_right = 1
		sc_style.border_width_bottom = 1
		sc_style.border_color = Color(0.3, 0.38, 0.52, 0.5)
		sc_style.content_margin_left = 16.0
		sc_style.content_margin_top = 12.0
		sc_style.content_margin_right = 16.0
		sc_style.content_margin_bottom = 12.0
		slot_card.add_theme_stylebox_override("panel", sc_style)
		content_vbox.add_child(slot_card)

		var sc_vbox := VBoxContainer.new()
		sc_vbox.add_theme_constant_override("separation", 8)
		slot_card.add_child(sc_vbox)

		# Slot header
		var s_head := Label.new()
		s_head.text = String(cfg["title"])
		s_head.add_theme_font_size_override("font_size", 14)
		s_head.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45))
		sc_vbox.add_child(s_head)

		var eq_id: StringName = cfg["equipped_id"] as StringName
		var eq_inst: EquipmentInstance = null
		if p_state != null and not eq_id.is_empty():
			for inst: EquipmentInstance in p_state.equipment_collection:
				if inst.instance_id == eq_id:
					eq_inst = inst
					break

		# Current equipped row
		var eq_row := HBoxContainer.new()
		eq_row.add_theme_constant_override("separation", 10)
		sc_vbox.add_child(eq_row)

		var eq_info := VBoxContainer.new()
		eq_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		eq_row.add_child(eq_info)

		if eq_inst != null:
			var name_l := Label.new()
			name_l.text = "Đang trang bị: %s" % _equipment_display_name(eq_inst)
			name_l.add_theme_font_size_override("font_size", 13)
			name_l.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
			eq_info.add_child(name_l)

			var tb := _tier_badge_info(eq_inst.tier)
			var sub_l := Label.new()
			sub_l.text = "[%s]  ⭐ Cấp %d  |  🔮 Cấp %d" % [
				tb.get("name", "Phẩm A"), eq_inst.gold_star_level, eq_inst.purple_star_level
			]
			sub_l.add_theme_font_size_override("font_size", 11)
			sub_l.add_theme_color_override("font_color", tb.get("color", Color(0.65, 0.75, 0.85)))
			eq_info.add_child(sub_l)

			var un_btn := Button.new()
			un_btn.text = "✕ Tháo Ra"
			un_btn.custom_minimum_size = Vector2(88, 30)
			un_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			var un_style := StyleBoxFlat.new()
			un_style.bg_color = Color(0.35, 0.15, 0.18, 0.85)
			un_style.corner_radius_top_left = 6
			un_style.corner_radius_top_right = 6
			un_style.corner_radius_bottom_right = 6
			un_style.corner_radius_bottom_left = 6
			un_btn.add_theme_stylebox_override("normal", un_style)
			un_btn.add_theme_stylebox_override("hover", un_style)
			un_btn.add_theme_stylebox_override("pressed", un_style)
			var target_slot_const: StringName = cfg["slot_const"] as StringName
			un_btn.pressed.connect(func() -> void:
				_unequip_slot(target_slot_const)
			)
			eq_row.add_child(un_btn)
		else:
			var empty_l := Label.new()
			empty_l.text = "Trạng thái: (Vị trí trống)"
			empty_l.add_theme_font_size_override("font_size", 12)
			empty_l.add_theme_color_override("font_color", Color(0.5, 0.55, 0.65))
			eq_info.add_child(empty_l)

		# Available owned stigmata for this slot
		var slot_owned: Array[EquipmentInstance] = []
		var slot_target_enum: int = int(cfg["slot_enum"])
		if p_state != null:
			for inst: EquipmentInstance in p_state.equipment_collection:
				if (
					inst.equipment_type == EQUIPMENT_ENUMS.EquipmentType.STIGMATA
					and inst.stigmata_slot == slot_target_enum
				):
					slot_owned.append(inst)

		if not slot_owned.is_empty():
			var owned_sep := HSeparator.new()
			sc_vbox.add_child(owned_sep)

			for inst: EquipmentInstance in slot_owned:
				var item_row := HBoxContainer.new()
				item_row.add_theme_constant_override("separation", 8)
				sc_vbox.add_child(item_row)

				var item_info := VBoxContainer.new()
				item_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				item_row.add_child(item_info)

				var i_name := Label.new()
				i_name.text = "• %s" % _equipment_display_name(inst)
				i_name.add_theme_font_size_override("font_size", 12)
				i_name.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
				item_info.add_child(i_name)

				var is_this_equipped: bool = (eq_inst != null and inst.instance_id == eq_inst.instance_id)
				if is_this_equipped:
					var eq_tag := Label.new()
					eq_tag.text = "✔ Đang trang bị"
					eq_tag.add_theme_font_size_override("font_size", 11)
					eq_tag.add_theme_color_override("font_color", Color(0.4, 0.88, 0.5))
					item_row.add_child(eq_tag)
				else:
					var eq_btn := Button.new()
					eq_btn.text = "Trang Bị"
					eq_btn.custom_minimum_size = Vector2(80, 26)
					eq_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
					var eb_style := StyleBoxFlat.new()
					eb_style.bg_color = Color(0.2, 0.35, 0.55, 0.9)
					eb_style.corner_radius_top_left = 6
					eb_style.corner_radius_top_right = 6
					eb_style.corner_radius_bottom_right = 6
					eb_style.corner_radius_bottom_left = 6
					eq_btn.add_theme_stylebox_override("normal", eb_style)
					eq_btn.add_theme_stylebox_override("hover", eb_style)
					eq_btn.add_theme_stylebox_override("pressed", eb_style)
					var target_inst_id: StringName = inst.instance_id
					var target_slot_const: StringName = cfg["slot_const"] as StringName
					eq_btn.pressed.connect(func() -> void:
						_equip_item(target_inst_id, target_slot_const)
					)
					item_row.add_child(eq_btn)


# -----------------------------------------------------------------------------
# TAB 4: TÚI ĐỒ (Inventory - Consumables & Resources only, no relics/stigmata)
# -----------------------------------------------------------------------------
func _render_tab_inventory() -> void:
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 16)
	_right_panel_container.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = "🎒 TÚI HÀNH TRANG & TÀI BẢO"
	title_lbl.add_theme_font_size_override("font_size", 20)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(title_lbl)

	var p_state: PlayerPhaseState = _case_flow_session.loot_session.find_player(_active_player_id)
	var round_loot: RoundLootInventoryState = _case_flow_session.loot_session.find_round_loot_state(_active_player_id)

	# Resources row
	var res_card := PanelContainer.new()
	var rc_style := StyleBoxFlat.new()
	rc_style.bg_color = Color(0.08, 0.1, 0.15, 0.9)
	rc_style.corner_radius_top_left = 10
	rc_style.corner_radius_top_right = 10
	rc_style.corner_radius_bottom_right = 10
	rc_style.corner_radius_bottom_left = 10
	rc_style.content_margin_left = 16.0
	rc_style.content_margin_top = 12.0
	rc_style.content_margin_right = 16.0
	rc_style.content_margin_bottom = 12.0
	res_card.add_theme_stylebox_override("panel", rc_style)
	vbox.add_child(res_card)

	var res_vbox := VBoxContainer.new()
	res_vbox.add_theme_constant_override("separation", 8)
	res_card.add_child(res_vbox)

	var coins: int = p_state.silver_coin_count if p_state != null else 0
	var tickets: int = p_state.gacha_ticket_count if p_state != null else 0
	var orbs: int = p_state.orb_count if p_state != null else 0
	var rep: int = p_state.reputation if p_state != null else 5

	var res_lbl := Label.new()
	res_lbl.text = "🪙 Xu Bạc: %d   🎟️ Vé Gacha: %d   🔮 Orb: %d   🛡️ Danh Tiếng: %d" % [
		coins, tickets, orbs, rep
	]
	res_lbl.add_theme_font_size_override("font_size", 14)
	res_lbl.add_theme_color_override("font_color", Color(0.95, 0.9, 0.75))
	res_vbox.add_child(res_lbl)

	# Round Carried Consumables
	var carried_title := Label.new()
	var carried_count: int = round_loot.carried_items.size() if round_loot != null else 0
	var carried_cap: int = round_loot.capacity if round_loot != null else 2
	carried_title.text = "📦 Vật Phẩm Đang Mang Khi Loot (%d/%d)" % [carried_count, carried_cap]
	carried_title.add_theme_font_size_override("font_size", 15)
	carried_title.add_theme_color_override("font_color", Color(0.85, 0.9, 0.96))
	vbox.add_child(carried_title)

	var carried_card := PanelContainer.new()
	carried_card.add_theme_stylebox_override("panel", rc_style)
	vbox.add_child(carried_card)

	var carried_vbox := VBoxContainer.new()
	carried_vbox.add_theme_constant_override("separation", 6)
	carried_card.add_child(carried_vbox)

	if round_loot != null and not round_loot.carried_items.is_empty():
		for row: Dictionary in round_loot.carried_items:
			var item_id: StringName = StringName(row.get("item_id", ""))
			var it_name: String = _item_name(item_id)
			var it_lbl := Label.new()
			it_lbl.text = "• %s" % it_name
			it_lbl.add_theme_font_size_override("font_size", 13)
			it_lbl.add_theme_color_override("font_color", Color(0.85, 0.95, 0.88))
			carried_vbox.add_child(it_lbl)
	else:
		var empty_c := Label.new()
		empty_c.text = "(Túi rỗng - nhặt vật phẩm trên các ô bản đồ để sử dụng)"
		empty_c.add_theme_font_size_override("font_size", 13)
		empty_c.add_theme_color_override("font_color", Color(0.55, 0.6, 0.65))
		carried_vbox.add_child(empty_c)

	# Persistent Consumables in Vault
	var persistent_title := Label.new()
	var persistent_count: int = p_state.consumable_inventory.size() if p_state != null else 0
	persistent_title.text = "🏛️ Vật Phẩm Vĩnh Viễn Trong Kho (%d món)" % persistent_count
	persistent_title.add_theme_font_size_override("font_size", 15)
	persistent_title.add_theme_color_override("font_color", Color(0.85, 0.9, 0.96))
	vbox.add_child(persistent_title)

	var persistent_card := PanelContainer.new()
	persistent_card.add_theme_stylebox_override("panel", rc_style)
	vbox.add_child(persistent_card)

	var persistent_vbox := VBoxContainer.new()
	persistent_vbox.add_theme_constant_override("separation", 6)
	persistent_card.add_child(persistent_vbox)

	if p_state != null and not p_state.consumable_inventory.is_empty():
		for row: Dictionary in p_state.consumable_inventory:
			var item_id: StringName = StringName(row.get("item_id", ""))
			var qty: int = int(row.get("quantity", 1))
			var it_name: String = _item_name(item_id)
			var it_lbl := Label.new()
			it_lbl.text = "• %s (x%d)" % [it_name, qty]
			it_lbl.add_theme_font_size_override("font_size", 13)
			it_lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
			persistent_vbox.add_child(it_lbl)
	else:
		var empty_p := Label.new()
		empty_p.text = "(Kho trống - vật phẩm mang trong túi sẽ chuyển về kho khi kết thúc Loot)"
		empty_p.add_theme_font_size_override("font_size", 13)
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
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 16)
	_right_panel_container.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = "ℹ️ TIỂU SỬ & THÂN THẾ"
	title_lbl.add_theme_font_size_override("font_size", 20)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(title_lbl)

	var p_state: PlayerPhaseState = _case_flow_session.loot_session.find_player(_active_player_id)
	var char_def: CharacterDefinition = (
		_setup_session.find_character(p_state.character_id) if p_state != null else null
	)
	var lore: Dictionary = CHARACTER_LORE.get(char_def.character_id, {}) if char_def != null else {}

	var card := PanelContainer.new()
	var c_style := StyleBoxFlat.new()
	c_style.bg_color = Color(0.08, 0.1, 0.15, 0.9)
	c_style.corner_radius_top_left = 12
	c_style.corner_radius_top_right = 12
	c_style.corner_radius_bottom_right = 12
	c_style.corner_radius_bottom_left = 12
	c_style.content_margin_left = 20.0
	c_style.content_margin_top = 18.0
	c_style.content_margin_right = 20.0
	c_style.content_margin_bottom = 18.0
	card.add_theme_stylebox_override("panel", c_style)
	vbox.add_child(card)

	var cvbox := VBoxContainer.new()
	cvbox.add_theme_constant_override("separation", 12)
	card.add_child(cvbox)

	var bio_lbl := Label.new()
	bio_lbl.text = lore.get("bio", "Chưa có dữ liệu tiểu sử.")
	bio_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bio_lbl.add_theme_font_size_override("font_size", 14)
	bio_lbl.add_theme_color_override("font_color", Color(0.88, 0.92, 0.96))
	cvbox.add_child(bio_lbl)


# -----------------------------------------------------------------------------
# TAB 6: THỜI TRANG (Costumes - Placeholder)
# -----------------------------------------------------------------------------
func _render_tab_costumes() -> void:
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 16)
	_right_panel_container.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = "👘 TỦ ĐỒ & THỜI TRANG"
	title_lbl.add_theme_font_size_override("font_size", 20)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(title_lbl)

	var card := PanelContainer.new()
	var c_style := StyleBoxFlat.new()
	c_style.bg_color = Color(0.08, 0.1, 0.15, 0.9)
	c_style.corner_radius_top_left = 12
	c_style.corner_radius_top_right = 12
	c_style.corner_radius_bottom_right = 12
	c_style.corner_radius_bottom_left = 12
	c_style.content_margin_left = 20.0
	c_style.content_margin_top = 18.0
	c_style.content_margin_right = 20.0
	c_style.content_margin_bottom = 18.0
	card.add_theme_stylebox_override("panel", c_style)
	vbox.add_child(card)

	var lbl := Label.new()
	lbl.text = "• Trang phục hiện tại: Thường phục Thần Thám Hoàng Cung.\n\n(Tính năng Tủ Đồ Ngoại Trang đang được phát triển trong các bản mở rộng tương lai)."
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", Color(0.72, 0.78, 0.85))
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
		icon_lbl.add_theme_font_size_override("font_size", 15)
		row.add_child(icon_lbl)

		var name_lbl := Label.new()
		name_lbl.text = item["name"]
		name_lbl.add_theme_font_size_override("font_size", 14)
		name_lbl.add_theme_color_override("font_color", Color(0.2, 0.22, 0.25)) # Dark text like Image 3
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_lbl)

		var val_row := HBoxContainer.new()
		val_row.add_theme_constant_override("separation", 6)

		# Base stat in black/dark
		var base_lbl := Label.new()
		base_lbl.text = "%d" % int(item["base"])
		base_lbl.add_theme_font_size_override("font_size", 15)
		base_lbl.add_theme_color_override("font_color", Color(0.12, 0.12, 0.15))
		val_row.add_child(base_lbl)

		# Bonus stat in bright cyan/blue like Image 3
		var bonus_lbl := Label.new()
		bonus_lbl.text = "+%d" % int(item["bonus"])
		bonus_lbl.add_theme_font_size_override("font_size", 15)
		bonus_lbl.add_theme_color_override("font_color", Color(0.12, 0.58, 0.95))
		val_row.add_child(bonus_lbl)

		row.add_child(val_row)
		rows_container.add_child(row)

	if _stat_modal_overlay != null:
		_stat_modal_overlay.visible = true


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
	if _rank_popup_overlay != null:
		_rank_popup_overlay.visible = true


func _switch_sidebar_tab(tab_id: SidebarTab) -> void:
	_current_sidebar_tab = tab_id
	if _stat_modal_overlay != null:
		_stat_modal_overlay.visible = false
	if _rank_popup_overlay != null:
		_rank_popup_overlay.visible = false
	refresh()


func _on_close_pressed() -> void:
	if is_post_loot_equipment_phase:
		if _finish_phase_modal_overlay != null:
			_finish_phase_modal_overlay.visible = true
	else:
		visible = false
		closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_ESCAPE or key.keycode == KEY_C:
			if _finish_phase_modal_overlay != null and _finish_phase_modal_overlay.visible:
				_finish_phase_modal_overlay.visible = false
				get_viewport().set_input_as_handled()
				return
			if _stat_modal_overlay != null and _stat_modal_overlay.visible:
				_stat_modal_overlay.visible = false
				get_viewport().set_input_as_handled()
				return
			if _rank_popup_overlay != null and _rank_popup_overlay.visible:
				_rank_popup_overlay.visible = false
				get_viewport().set_input_as_handled()
				return
			_on_close_pressed()
			get_viewport().set_input_as_handled()
