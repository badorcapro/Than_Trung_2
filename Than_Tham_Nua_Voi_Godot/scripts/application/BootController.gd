extends Control

enum Phase {
	BIOS,
	SPLASH,
	DONE
}

const BIOS_STATIC_BBCODE: String = """[color=#64748b]================================================================[/color]
[color=#38bdf8][b]VINGROUP NEURAL-BIOS v4.09 (C) 2026 VINGROUP TECH CORP.[/b][/color]
[color=#c084fc]PROJECT: "HO-DIEP" [HỒ ĐIỆP] - COGNITIVE MATRIX ENGAGED[/color]
[color=#64748b]================================================================[/color]

[color=#4ade80][b][+][/b][/color] Testing Subject Synaptic Bridge ............. [color=#4ade80]OK[/color]
[color=#4ade80][b][+][/b][/color] Subject Heartbeat: 76 BPM | EEG Wave ........ [color=#4ade80]SYNCHRONIZED[/color]
[color=#4ade80][b][+][/b][/color] Loading Virtual Matrix: [color=#fde047]"THẦN THÁM NỬA VỜI: TRUYỀN KỲ KỲ ÁN HOÀNG CUNG"[/color]

[color=#fbbf24][b][WARN][/b][/color] Neural Divergence detected. Overriding subject consciousness...
[color=#fbbf24][b][WARN][/b][/color] Moral Dampeners: [color=#fbbf24]ENGAGED.[/color]
[color=#f87171][b][!][/b][/color] [color=#fca5a5]STATUS: Logic anomalies (Kỳ Án) generated across Inner Palace sectors.[/color]

[color=#94a3b8]Connecting to Subject Peer Network (1-4 Players):[/color]
 - Tester_01 [color=#4ade80][READY][/color]
 - Tester_02 [color=#38bdf8][ACTIVE][/color]
 - Tester_03 [color=#94a3b8][STANDBY][/color]
 - Tester_04 [color=#94a3b8][STANDBY][/color]"""

const LAST_LINE_BASE: String = "SYNAPSE OVERWRITE COMPLETE. ENTERING THE BOARD"

@onready var bios_phase: Control = %BiosPhase
@onready var bios_static_text: RichTextLabel = %BiosStaticText
@onready var bios_last_line: RichTextLabel = %BiosLastLine
@onready var splash_phase: Control = %SplashPhase
@onready var splash_graphic: TextureRect = %SplashGraphic
@onready var transition_overlay: ColorRect = %TransitionOverlay
@onready var error_label: Label = %ErrorLabel

var _current_phase: Phase = Phase.BIOS
var _dots_timer: float = 0.0
var _dots_count: int = 1
var _cursor_timer: float = 0.0
var _cursor_visible: bool = true
var _bios_elapsed: float = 0.0
var _splash_elapsed: float = 0.0
var _skipped: bool = false
var _tween: Tween = null


func _ready() -> void:
	AppLogger.info("Project boot: Retro OS & BIOS Terminal flow engaged.")
	AppLogger.info("Version: %s" % AppVersion.summary())

	var required_scene: PackedScene = load(
		AppFlow.PLAYER_FACING_START_SCENE
	) as PackedScene
	if required_scene == null:
		_show_boot_error("Main Menu scene could not be loaded.")
		return

	_setup_terminal_typography()
	_start_bios_phase()


func _setup_terminal_typography() -> void:
	var mono_font := SystemFont.new()
	mono_font.font_names = PackedStringArray([
		"Consolas",
		"Courier New",
		"Lucida Console",
		"Liberation Mono",
		"DejaVu Sans Mono",
		"monospace"
	])

	if bios_static_text != null:
		bios_static_text.add_theme_font_override("normal_font", mono_font)
		bios_static_text.add_theme_font_override("bold_font", mono_font)
		bios_static_text.add_theme_font_size_override("normal_font_size", 15)
		bios_static_text.add_theme_font_size_override("bold_font_size", 15)
		bios_static_text.add_theme_constant_override("line_separation", 4)

	if bios_last_line != null:
		bios_last_line.add_theme_font_override("normal_font", mono_font)
		bios_last_line.add_theme_font_override("bold_font", mono_font)
		bios_last_line.add_theme_font_size_override("normal_font_size", 15)
		bios_last_line.add_theme_font_size_override("bold_font_size", 15)

	# Ensure splash graphic texture is loaded
	if splash_graphic != null and splash_graphic.texture == null:
		var splash_path := "res://assets/ui/boot/splash_retro_os.png"
		if ResourceLoader.exists(splash_path):
			splash_graphic.texture = load(splash_path)


func _start_bios_phase() -> void:
	_current_phase = Phase.BIOS
	_bios_elapsed = 0.0
	_dots_timer = 0.0
	_dots_count = 1
	_cursor_timer = 0.0
	_cursor_visible = true

	if bios_phase != null:
		bios_phase.visible = true
		bios_phase.modulate.a = 1.0

	if splash_phase != null:
		splash_phase.visible = true
		splash_phase.modulate.a = 0.0

	if transition_overlay != null:
		transition_overlay.modulate.a = 0.0

	# Static text appears completely and immediately, no typewriter delay
	if bios_static_text != null:
		bios_static_text.text = BIOS_STATIC_BBCODE

	_render_last_line()


func _process(delta: float) -> void:
	if _skipped or _current_phase == Phase.DONE:
		return

	if _current_phase == Phase.BIOS:
		_bios_elapsed += delta

		# Animate cycling dots (. -> .. -> ...)
		_dots_timer += delta
		if _dots_timer >= 0.35:
			_dots_timer -= 0.35
			_dots_count = (_dots_count % 3) + 1
			_render_last_line()

		# Animate blinking cursor (█)
		_cursor_timer += delta
		if _cursor_timer >= 0.25:
			_cursor_timer -= 0.25
			_cursor_visible = not _cursor_visible
			_render_last_line()

		# Auto-advance to Splash Phase after ~3.0 seconds if no skip
		if _bios_elapsed >= 3.0:
			_transition_to_splash()

	elif _current_phase == Phase.SPLASH:
		_splash_elapsed += delta

		# Auto-advance to Main Menu after ~2.8 seconds
		if _splash_elapsed >= 2.8:
			_finish_boot()


func _render_last_line() -> void:
	if bios_last_line == null:
		return

	var dots_str := ""
	for i in range(_dots_count):
		dots_str += ". "

	var cursor_str: String = "█" if _cursor_visible else " "

	bios_last_line.text = "[color=#38bdf8][b]%s[/b][/color] [color=#e2e8f0]%s[/color][color=#4ade80]%s[/color]" % [
		LAST_LINE_BASE,
		dots_str,
		cursor_str
	]


func _unhandled_input(event: InputEvent) -> void:
	if _skipped or _current_phase == Phase.DONE:
		return

	var is_trigger := false
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		is_trigger = true
	elif event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		is_trigger = true

	if is_trigger:
		get_viewport().set_input_as_handled()
		_handle_user_skip()


func _gui_input(event: InputEvent) -> void:
	if _skipped or _current_phase == Phase.DONE:
		return

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		_handle_user_skip()


func _handle_user_skip() -> void:
	if _current_phase == Phase.BIOS:
		_transition_to_splash()
	elif _current_phase == Phase.SPLASH:
		_finish_boot()


func _transition_to_splash() -> void:
	if _current_phase == Phase.SPLASH or _current_phase == Phase.DONE:
		return

	_current_phase = Phase.SPLASH
	_splash_elapsed = 0.0

	if _tween != null and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	# Smooth cross-fade: fade out BIOS text, fade in retro OS splash screen
	_tween.tween_property(bios_phase, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_SINE)
	_tween.parallel().tween_property(splash_phase, "modulate:a", 1.0, 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _finish_boot() -> void:
	if _skipped:
		return
	_skipped = true
	_current_phase = Phase.DONE

	if _tween != null and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(transition_overlay, "modulate:a", 1.0, 0.35).set_trans(Tween.TRANS_SINE)
	_tween.finished.connect(func() -> void:
		AppFlow.call_deferred("go_to_player_main_menu")
	)


func _show_boot_error(message: String) -> void:
	AppLogger.error("Initialization error: %s" % message)
	if error_label != null:
		error_label.text = "Initialization error\n%s" % message
		error_label.visible = true
	if bios_phase != null:
		bios_phase.visible = false
	if splash_phase != null:
		splash_phase.visible = false
