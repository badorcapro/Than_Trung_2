class_name RoleCodexController
extends Control

const GROUP_ORDER := [
	CaseEnums.RoleGroup.CHINH_NHAN,
	CaseEnums.RoleGroup.HIEU_SU,
	CaseEnums.RoleGroup.TONG_PHAM,
	CaseEnums.RoleGroup.NGHICH_THAN,
]

const ROLE_GLOSSARY_TOOLTIP_SCENE := preload("res://scenes/shared_ui/RoleGlossaryTooltip.tscn")
const STENCIL_SHADER := preload("res://shaders/black_to_transparent.gdshader")

const ROLE_ICON_PATHS := {
	&"tailor": "res://assets/ui/case/role_icons/tho_may.png",
	&"mailman": "res://assets/ui/case/role_icons/dich_phu.png",
	&"mathematician": "res://assets/ui/case/role_icons/nha_toan_hoc.png",
	&"weatherman": "res://assets/ui/case/role_icons/nha_khi_tuong.png",
	&"clock_maker": "res://assets/ui/case/role_icons/tho_dong_ho.png",
	&"reporter": "res://assets/ui/case/role_icons/su_quan.png",
	&"blood_hound": "res://assets/ui/case/role_icons/ngu_khuyen_quan.png",
	&"therapist": "res://assets/ui/case/role_icons/ngu_y.png",
	&"vigilante": "res://assets/ui/case/role_icons/su_tu_phan.png",
	&"tutorial_priest": "res://assets/ui/case/role_icons/tu_te.png",
	&"copycat": "res://assets/ui/case/role_icons/ke_bat_chuoc.png",
	&"drunkard": "res://assets/ui/case/role_icons/ke_say_ruou.png",
	&"surgeon": "res://assets/ui/case/role_icons/bac_si_phau_thuat.png",
	&"conman": "res://assets/ui/case/role_icons/ke_lua_dao.png",
	&"poisoner": "res://assets/ui/case/role_icons/doc_su.png",
	&"barkeep": "res://assets/ui/case/role_icons/chu_quan_ruou.png",
	&"serial_killer": "res://assets/ui/case/role_icons/sat_nhan_hang_loat.png",
	&"spectre": "res://assets/ui/case/role_icons/vong_linh.png",
	&"tutorial_scoundrel": "res://assets/ui/case/role_icons/ke_bat_luong.png",
	&"tutorial_mobster": "res://assets/ui/case/role_icons/ke_con_do.png",
	&"critic": "res://assets/ui/case/role_icons/nha_phe_binh.png",
}

const GROUP_BANNER_PATHS := {
	CaseEnums.RoleGroup.CHINH_NHAN: "res://assets/ui/case/role_groups/Innocent.png",
	CaseEnums.RoleGroup.HIEU_SU: "res://assets/ui/case/role_groups/Meddler.png",
	CaseEnums.RoleGroup.TONG_PHAM: "res://assets/ui/case/role_groups/Underling.png",
	CaseEnums.RoleGroup.NGHICH_THAN: "res://assets/ui/case/role_groups/Traitor.png",
}

const HERO_FRAME_PATH := "res://assets/ui/case/role_codex/hero_icon_frame.png"
const SEAL_STAMP_PATH := "res://assets/ui/case/role_codex/seal_stamp_approved.png"

@onready var group_tabs: HBoxContainer = %GroupTabs
@onready var role_list: GridContainer = %RoleList
@onready var selected_title: Label = %SelectedRoleTitle
@onready var selected_group: Label = %SelectedRoleGroup
@onready var selected_alignment: Label = %SelectedRoleAlignment
@onready var detail_body: RichTextLabel = %RoleDetailBody

@onready var hero_icon: TextureRect = get_node_or_null("%HeroIcon") as TextureRect
@onready var hero_frame: TextureRect = get_node_or_null("%HeroFrame") as TextureRect
@onready var group_banner: TextureRect = get_node_or_null("%GroupBanner") as TextureRect
@onready var seal_stamp: TextureRect = get_node_or_null("%SealStamp") as TextureRect

var _roles: Array[RoleDefinition] = []
var _selected_group: CaseEnums.RoleGroup = CaseEnums.RoleGroup.CHINH_NHAN
var _selected_role_id: StringName = &""
var _role_glossary_tooltip: RoleGlossaryTooltipController
var _icon_cache: Dictionary = {}
var _banner_cache: Dictionary = {}
var _stencil_material: ShaderMaterial
var _frame_material: ShaderMaterial
var _seal_material: ShaderMaterial


func _ready() -> void:
	_init_shaders()
	RoleReferenceFormatter.apply_uniform_body_font(detail_body)
	_setup_role_glossary_hover()
	_roles = _available_roles()
	_render_group_tabs()
	_select_group(CaseEnums.RoleGroup.CHINH_NHAN)


func get_group_labels() -> Array[String]:
	var labels: Array[String] = []
	for group: int in GROUP_ORDER:
		labels.append(_role_group_full_label(group))
	return labels


func get_visible_role_ids_for_group(group: CaseEnums.RoleGroup) -> Array[StringName]:
	var ids: Array[StringName] = []
	for role: RoleDefinition in _roles_for_group(group):
		ids.append(role.role_id)
	return ids


func select_role_for_smoke(role_id: StringName) -> void:
	_select_role(role_id)


func get_selected_role_id() -> StringName:
	return _selected_role_id


func get_detail_text() -> String:
	var lines: Array[String] = [
		selected_title.text if selected_title != null else "",
		selected_group.text if selected_group != null else "",
		selected_alignment.text if selected_alignment != null else "",
		detail_body.text if detail_body != null else "",
	]
	return "\n".join(lines)


func get_loaded_role_count() -> int:
	return _roles.size()


func _available_roles() -> Array[RoleDefinition]:
	var result: Array[RoleDefinition] = []
	for role: RoleDefinition in FixtureRepository.load_roles():
		if role == null or role.is_fixture_placeholder:
			continue
		result.append(role)
	return result


func _init_shaders() -> void:
	if STENCIL_SHADER != null:
		_stencil_material = ShaderMaterial.new()
		_stencil_material.shader = STENCIL_SHADER
		_stencil_material.set_shader_parameter("threshold", 0.04)
		_stencil_material.set_shader_parameter("softness", 0.06)

		_frame_material = ShaderMaterial.new()
		_frame_material.shader = STENCIL_SHADER
		_frame_material.set_shader_parameter("threshold", 0.04)
		_frame_material.set_shader_parameter("softness", 0.06)

		_seal_material = ShaderMaterial.new()
		_seal_material.shader = STENCIL_SHADER
		_seal_material.set_shader_parameter("threshold", 0.04)
		_seal_material.set_shader_parameter("softness", 0.06)

	if hero_frame != null and ResourceLoader.exists(HERO_FRAME_PATH):
		hero_frame.texture = load(HERO_FRAME_PATH) as Texture2D
		if _frame_material != null:
			hero_frame.material = _frame_material

	if seal_stamp != null and ResourceLoader.exists(SEAL_STAMP_PATH):
		seal_stamp.texture = load(SEAL_STAMP_PATH) as Texture2D
		if _seal_material != null:
			seal_stamp.material = _seal_material

	if hero_icon != null and _stencil_material != null:
		hero_icon.material = _stencil_material


func _render_group_tabs() -> void:
	if group_tabs == null:
		return
	for child: Node in group_tabs.get_children():
		child.queue_free()
	for group: int in GROUP_ORDER:
		var button: Button = Button.new()
		var count: int = _roles_for_group(group).size()
		var group_name: String = _role_group_full_label(group)
		button.text = "%s (%d)" % [group_name, count]
		button.custom_minimum_size = Vector2(165, 42)
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_style_group_tab_button(button, group, group == _selected_group)
		button.pressed.connect(_on_group_tab_pressed.bind(group))
		group_tabs.add_child(button)


func _on_group_tab_pressed(group: CaseEnums.RoleGroup) -> void:
	_select_group(group)


func _select_group(group: CaseEnums.RoleGroup) -> void:
	_selected_group = group
	_update_group_banner(group)
	_update_group_tabs_visual()
	_render_role_list()
	var roles: Array[RoleDefinition] = _roles_for_group(group)
	if roles.is_empty():
		_clear_detail()
	else:
		_select_role(roles[0].role_id)


func _update_group_banner(group: CaseEnums.RoleGroup) -> void:
	if group_banner == null:
		return
	var banner_path: String = GROUP_BANNER_PATHS.get(group, "")
	if not banner_path.is_empty() and ResourceLoader.exists(banner_path):
		if not _banner_cache.has(banner_path):
			_banner_cache[banner_path] = load(banner_path) as Texture2D
		group_banner.texture = _banner_cache[banner_path]
		group_banner.visible = true
	else:
		group_banner.visible = false


func _update_group_tabs_visual() -> void:
	if group_tabs == null:
		return
	var children: Array[Node] = group_tabs.get_children()
	for i: int in range(mini(children.size(), GROUP_ORDER.size())):
		var button := children[i] as Button
		if button != null:
			var group: int = GROUP_ORDER[i]
			_style_group_tab_button(button, group, group == _selected_group)


func _style_group_tab_button(button: Button, group: int, is_active: bool) -> void:
	var group_col: Color = RoleReferenceFormatter.role_group_color(group)
	var style := StyleBoxFlat.new()
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6

	if is_active:
		style.bg_color = Color(group_col.r * 0.25, group_col.g * 0.25, group_col.b * 0.25, 0.95)
		style.border_color = group_col
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		button.add_theme_color_override("font_color", Color.WHITE)
		button.add_theme_font_size_override("font_size", 14)
	else:
		style.bg_color = Color(0.08, 0.10, 0.14, 0.75)
		style.border_color = Color(0.25, 0.28, 0.35, 0.5)
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		button.add_theme_color_override("font_color", Color(0.8, 0.82, 0.88))
		button.add_theme_font_size_override("font_size", 13)

	button.add_theme_stylebox_override("normal", style)
	var hover_style := style.duplicate() as StyleBoxFlat
	hover_style.bg_color = Color(group_col.r * 0.35, group_col.g * 0.35, group_col.b * 0.35, 0.95)
	hover_style.border_color = group_col
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", hover_style)


func _render_role_list() -> void:
	if role_list == null:
		return
	for child: Node in role_list.get_children():
		child.queue_free()
	var roles: Array[RoleDefinition] = _roles_for_group(_selected_group)
	for role: RoleDefinition in roles:
		var button := _create_role_card_button(role)
		role_list.add_child(button)


func _create_role_card_button(role: RoleDefinition) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(205, 62)
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.tooltip_text = _player_facing_text(role.display_name)
	button.set_meta(&"role_id", role.role_id)

	var is_active: bool = (role.role_id == _selected_role_id)
	_apply_role_card_style(button, role.role_group, is_active)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	button.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_theme_constant_override("separation", 10)
	margin.add_child(hbox)

	var icon_rect := TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(44, 44)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_rect.texture = _get_role_icon_texture(role.role_id)
	if _stencil_material != null:
		icon_rect.material = _stencil_material
	hbox.add_child(icon_rect)

	var vbox := VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(vbox)

	var name_label := Label.new()
	name_label.text = _player_facing_text(role.display_name)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color(0.96, 0.96, 0.98))
	vbox.add_child(name_label)

	var group_col: Color = RoleReferenceFormatter.role_group_color(role.role_group)
	var sub_label := Label.new()
	sub_label.text = RoleReferenceFormatter.role_alignment_label(role.role_group)
	sub_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sub_label.add_theme_font_size_override("font_size", 11)
	sub_label.add_theme_color_override("font_color", group_col.lerp(Color(0.8, 0.8, 0.8), 0.25))
	vbox.add_child(sub_label)

	button.pressed.connect(_select_role.bind(role.role_id))
	return button


func _apply_role_card_style(button: Button, group: int, is_active: bool) -> void:
	var group_col: Color = RoleReferenceFormatter.role_group_color(group)
	var style := StyleBoxFlat.new()
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6

	if is_active:
		style.bg_color = Color(0.12, 0.15, 0.20, 0.95)
		style.border_color = group_col
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
	else:
		style.bg_color = Color(0.06, 0.08, 0.12, 0.85)
		style.border_color = Color(0.22, 0.26, 0.32, 0.5)
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1

	button.add_theme_stylebox_override("normal", style)
	var hover_style := style.duplicate() as StyleBoxFlat
	hover_style.bg_color = Color(0.14, 0.18, 0.25, 0.95)
	hover_style.border_color = group_col
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", hover_style)


func _get_role_icon_texture(role_id: StringName) -> Texture2D:
	var path: String = ROLE_ICON_PATHS.get(role_id, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	if not _icon_cache.has(path):
		_icon_cache[path] = load(path) as Texture2D
	return _icon_cache[path] as Texture2D


func _select_role(role_id: StringName) -> void:
	var role: RoleDefinition = _find_role(role_id)
	if role == null:
		return
	_hide_role_glossary_tooltip()
	_selected_role_id = role.role_id

	if selected_title != null:
		selected_title.text = _player_facing_text(role.display_name)
		var role_col: Color = RoleReferenceFormatter.role_group_color(role.role_group)
		selected_title.add_theme_color_override("font_color", role_col.lerp(Color.WHITE, 0.4))

	if selected_group != null:
		selected_group.text = "Nhóm: %s" % _role_group_full_label(role.role_group)
		selected_group.add_theme_color_override("font_color", RoleReferenceFormatter.role_group_color(role.role_group))

	if selected_alignment != null:
		selected_alignment.text = "Phe: %s" % _role_alignment_label(role.role_group).trim_prefix("Phe ")
		var align_col: Color = Color(1.0, 0.4, 0.4) if role.role_group in [CaseEnums.RoleGroup.TONG_PHAM, CaseEnums.RoleGroup.NGHICH_THAN] else Color(0.4, 0.8, 1.0)
		selected_alignment.add_theme_color_override("font_color", align_col)

	if detail_body != null:
		detail_body.text = _role_body_text(role)

	if hero_icon != null:
		var tex := _get_role_icon_texture(role.role_id)
		hero_icon.texture = tex
		hero_icon.visible = tex != null

	_refresh_card_active_states()


func _refresh_card_active_states() -> void:
	if role_list == null:
		return
	for child: Node in role_list.get_children():
		var btn := child as Button
		if btn != null and btn.has_meta(&"role_id"):
			var rid: StringName = btn.get_meta(&"role_id") as StringName
			_apply_role_card_style(btn, _selected_group, rid == _selected_role_id)


func _clear_detail() -> void:
	_hide_role_glossary_tooltip()
	_selected_role_id = &""
	if selected_title != null:
		selected_title.text = "Chưa có vai"
		selected_title.remove_theme_color_override("font_color")
	if selected_group != null:
		selected_group.text = "Nhóm: -"
	if selected_alignment != null:
		selected_alignment.text = "Phe: -"
	if detail_body != null:
		detail_body.text = ""
	if hero_icon != null:
		hero_icon.texture = null
		hero_icon.visible = false
	_refresh_card_active_states()


func _roles_for_group(group: CaseEnums.RoleGroup) -> Array[RoleDefinition]:
	var result: Array[RoleDefinition] = []
	for role: RoleDefinition in _roles:
		if role != null and role.role_group == group:
			result.append(role)
	return result


func _find_role(role_id: StringName) -> RoleDefinition:
	for role: RoleDefinition in _roles:
		if role != null and role.role_id == role_id:
			return role
	return null


func _role_body_text(role: RoleDefinition) -> String:
	return RoleReferenceFormatter.role_body_bbcode(role)


func _role_visual(role: RoleDefinition) -> String:
	return ""


func _role_group_full_label(group: CaseEnums.RoleGroup) -> String:
	return RoleReferenceFormatter.role_group_full_label(group)


func _role_alignment_label(group: CaseEnums.RoleGroup) -> String:
	return RoleReferenceFormatter.role_alignment_label(group)


func _player_facing_text(value: String) -> String:
	return RoleReferenceFormatter.player_facing_text(value)


func has_glossary_hover_for_smoke() -> bool:
	return (
		detail_body != null
		and _role_glossary_tooltip != null
		and detail_body.meta_hover_started.is_connected(_on_role_glossary_meta_hover_started)
		and detail_body.meta_hover_ended.is_connected(_on_role_glossary_meta_hover_ended)
	)


func _setup_role_glossary_hover() -> void:
	if detail_body == null:
		return
	if _role_glossary_tooltip == null:
		_role_glossary_tooltip = ROLE_GLOSSARY_TOOLTIP_SCENE.instantiate() as RoleGlossaryTooltipController
		if _role_glossary_tooltip != null:
			add_child(_role_glossary_tooltip)
	if not detail_body.meta_hover_started.is_connected(_on_role_glossary_meta_hover_started):
		detail_body.meta_hover_started.connect(_on_role_glossary_meta_hover_started)
	if not detail_body.meta_hover_ended.is_connected(_on_role_glossary_meta_hover_ended):
		detail_body.meta_hover_ended.connect(_on_role_glossary_meta_hover_ended)


func _on_role_glossary_meta_hover_started(meta: Variant) -> void:
	var key: StringName = RoleGlossaryBank.key_from_meta(meta)
	if String(key).is_empty() or _role_glossary_tooltip == null:
		return
	_role_glossary_tooltip.show_key(key, get_viewport().get_mouse_position())


func _on_role_glossary_meta_hover_ended(_meta: Variant) -> void:
	_hide_role_glossary_tooltip()


func _hide_role_glossary_tooltip() -> void:
	if _role_glossary_tooltip != null:
		_role_glossary_tooltip.hide_tooltip()


func _on_back_pressed() -> void:
	_hide_role_glossary_tooltip()
	AppFlow.go_to_player_main_menu()
