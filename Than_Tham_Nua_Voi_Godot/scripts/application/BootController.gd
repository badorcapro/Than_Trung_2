extends Control

@onready var studio_logo: TextureRect = %StudioLogo
@onready var engine_logo: TextureRect = %EngineLogo
@onready var error_label: Label = %ErrorLabel
@onready var skip_prompt: Label = %SkipPrompt

var _boot_tween: Tween = null
var _skipped: bool = false


func _ready() -> void:
	AppLogger.info("Project boot")
	AppLogger.info("Version: %s" % AppVersion.summary())
	var required_scene: PackedScene = load(
		AppFlow.PLAYER_FACING_START_SCENE
	) as PackedScene
	if required_scene == null:
		_show_boot_error("Main Menu scene could not be loaded.")
		return
	AppLogger.info("Boot initialization successful, starting logo splash sequence.")
	_play_splash_sequence()


func _unhandled_input(event: InputEvent) -> void:
	if _skipped:
		return
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE]:
			_skip_to_main_menu()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		_skip_to_main_menu()
		get_viewport().set_input_as_handled()


func _play_splash_sequence() -> void:
	if studio_logo == null or engine_logo == null:
		_finish_boot()
		return
	studio_logo.modulate.a = 0.0
	engine_logo.modulate.a = 0.0

	_boot_tween = create_tween()
	# Phase 1: Studio Logo fade in -> hold -> fade out
	_boot_tween.tween_property(studio_logo, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_SINE)
	_boot_tween.tween_interval(1.2)
	_boot_tween.tween_property(studio_logo, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	_boot_tween.tween_interval(0.2)

	# Phase 2: Engine Logo fade in -> hold -> fade out
	_boot_tween.tween_property(engine_logo, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_SINE)
	_boot_tween.tween_interval(1.2)
	_boot_tween.tween_property(engine_logo, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	_boot_tween.tween_interval(0.2)

	_boot_tween.finished.connect(_finish_boot)


func _skip_to_main_menu() -> void:
	if _skipped:
		return
	_skipped = true
	if _boot_tween != null and _boot_tween.is_valid():
		_boot_tween.kill()
	_finish_boot()


func _finish_boot() -> void:
	_skipped = true
	AppFlow.call_deferred("go_to_player_main_menu")


func _show_boot_error(message: String) -> void:
	AppLogger.error("Initialization error: %s" % message)
	if error_label != null:
		error_label.text = "Initialization error\n%s" % message
		error_label.visible = true
	if skip_prompt != null:
		skip_prompt.visible = false
