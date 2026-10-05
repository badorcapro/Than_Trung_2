class_name InvestigationCursorFeedback
extends Control

var _progress := 0.0
var _tween: Tween


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func start_progress(screen_position: Vector2, duration_sec: float) -> void:
	position = screen_position - Vector2(14, 14)
	size = Vector2(28, 28)
	_progress = 0.0
	visible = true
	queue_redraw()
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_set_progress, 0.0, 1.0, max(duration_sec, 0.01))


func cancel() -> void:
	if _tween != null:
		_tween.kill()
		_tween = null
	_progress = 0.0
	visible = false
	queue_redraw()


func complete() -> void:
	cancel()


func _draw() -> void:
	var center := size * 0.5
	draw_arc(center, 11.0, -PI * 0.5, -PI * 0.5 + TAU * _progress, 32, Color(0.96, 0.79, 0.36, 1.0), 3.0)


func _set_progress(value: float) -> void:
	_progress = value
	queue_redraw()


func _finish() -> void:
	cancel()
