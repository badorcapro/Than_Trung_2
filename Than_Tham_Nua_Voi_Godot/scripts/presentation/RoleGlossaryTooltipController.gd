class_name RoleGlossaryTooltipController
extends PanelContainer

const VIEWPORT_PADDING: float = 12.0
const POINTER_OFFSET: Vector2 = Vector2(16.0, 20.0)
const TOOLTIP_WIDTH: float = 280.0
const MAX_TOOLTIP_HEIGHT: float = 220.0

@onready var title_label: Label = %GlossaryTitle
@onready var definition_label: Label = %GlossaryDefinition

var _pending_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func show_entry(entry: Dictionary, viewport_position: Vector2) -> void:
	var title: String = String(entry.get("title", ""))
	var definition: String = String(entry.get("definition", ""))
	if title.is_empty():
		hide_tooltip()
		return
	title_label.text = title
	definition_label.text = definition
	definition_label.visible = not definition.is_empty()
	_pending_position = viewport_position
	visible = true
	_resize_to_content()
	_position_near(_pending_position)
	call_deferred("_refresh_layout_near", _pending_position)


func show_key(key: StringName, viewport_position: Vector2) -> void:
	show_entry(RoleGlossaryBank.entry_for_key(key), viewport_position)


func hide_tooltip() -> void:
	visible = false


func _position_near(viewport_position: Vector2) -> void:
	var desired: Vector2 = viewport_position + POINTER_OFFSET
	var viewport_size: Vector2 = get_viewport_rect().size
	var tooltip_size: Vector2 = size
	if tooltip_size.x <= 0.0 or tooltip_size.y <= 0.0:
		tooltip_size = custom_minimum_size
	var max_x: float = maxf(VIEWPORT_PADDING, viewport_size.x - tooltip_size.x - VIEWPORT_PADDING)
	var max_y: float = maxf(VIEWPORT_PADDING, viewport_size.y - tooltip_size.y - VIEWPORT_PADDING)
	position = Vector2(
		clampf(desired.x, VIEWPORT_PADDING, max_x),
		clampf(desired.y, VIEWPORT_PADDING, max_y)
	)


func _refresh_layout_near(viewport_position: Vector2) -> void:
	_resize_to_content()
	_position_near(viewport_position)


func _resize_to_content() -> void:
	custom_minimum_size = Vector2(TOOLTIP_WIDTH, 0.0)
	size = Vector2(TOOLTIP_WIDTH, 0.0)
	reset_size()
	var desired_size: Vector2 = get_combined_minimum_size()
	size = Vector2(TOOLTIP_WIDTH, minf(desired_size.y, MAX_TOOLTIP_HEIGHT))
