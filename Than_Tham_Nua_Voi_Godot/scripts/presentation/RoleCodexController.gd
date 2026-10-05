class_name RoleCodexController
extends Control

const GROUP_ORDER := [
	CaseEnums.RoleGroup.CHINH_NHAN,
	CaseEnums.RoleGroup.HIEU_SU,
	CaseEnums.RoleGroup.TONG_PHAM,
	CaseEnums.RoleGroup.NGHICH_THAN,
]
const ROLE_GLOSSARY_TOOLTIP_SCENE := preload("res://scenes/shared_ui/RoleGlossaryTooltip.tscn")

@onready var group_tabs: HBoxContainer = %GroupTabs
@onready var role_list: GridContainer = %RoleList
@onready var selected_title: Label = %SelectedRoleTitle
@onready var selected_group: Label = %SelectedRoleGroup
@onready var selected_alignment: Label = %SelectedRoleAlignment
@onready var detail_body: RichTextLabel = %RoleDetailBody

var _roles: Array[RoleDefinition] = []
var _selected_group: CaseEnums.RoleGroup = CaseEnums.RoleGroup.CHINH_NHAN
var _selected_role_id: StringName = &""
var _role_glossary_tooltip: RoleGlossaryTooltipController


func _ready() -> void:
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
		selected_title.text,
		selected_group.text,
		selected_alignment.text,
		detail_body.text,
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


func _render_group_tabs() -> void:
	for child: Node in group_tabs.get_children():
		child.queue_free()
	for group: int in GROUP_ORDER:
		var button: Button = Button.new()
		button.text = _role_group_full_label(group)
		button.toggle_mode = true
		button.pressed.connect(_select_group.bind(group))
		group_tabs.add_child(button)


func _select_group(group: CaseEnums.RoleGroup) -> void:
	_selected_group = group
	_render_role_list()
	var roles: Array[RoleDefinition] = _roles_for_group(group)
	if roles.is_empty():
		_clear_detail()
	else:
		_select_role(roles[0].role_id)


func _render_role_list() -> void:
	for child: Node in role_list.get_children():
		child.queue_free()
	var roles: Array[RoleDefinition] = _roles_for_group(_selected_group)
	for role: RoleDefinition in roles:
		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(180, 54)
		button.text = _player_facing_text(role.display_name)
		button.tooltip_text = _player_facing_text(role.display_name)
		button.pressed.connect(_select_role.bind(role.role_id))
		role_list.add_child(button)


func _select_role(role_id: StringName) -> void:
	var role: RoleDefinition = _find_role(role_id)
	if role == null:
		return
	_hide_role_glossary_tooltip()
	_selected_role_id = role.role_id
	selected_title.text = _player_facing_text(role.display_name)
	selected_group.text = "Nhóm: %s" % _role_group_full_label(role.role_group)
	selected_alignment.text = "Phe: %s" % _role_alignment_label(role.role_group).trim_prefix("Phe ")
	detail_body.text = _role_body_text(role)


func _clear_detail() -> void:
	_hide_role_glossary_tooltip()
	_selected_role_id = &""
	selected_title.text = "Chưa có vai"
	selected_group.text = "Nhóm: -"
	selected_alignment.text = "Phe: -"
	detail_body.text = ""


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
	AppFlow.go_to_debug_home()
