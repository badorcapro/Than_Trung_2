extends Control

@onready var error_label: Label = %ErrorLabel


func _ready() -> void:
	AppLogger.info("Project boot")
	AppLogger.info("Version: %s" % AppVersion.summary())
	var required_scene: PackedScene = load(
		AppFlow.PLAYER_FACING_START_SCENE
	) as PackedScene
	if required_scene == null:
		_show_boot_error("Main Menu scene could not be loaded.")
		return
	AppLogger.info("Boot initialization successful")
	AppFlow.call_deferred("go_to_player_main_menu")


func _show_boot_error(message: String) -> void:
	AppLogger.error("Initialization error: %s" % message)
	error_label.text = "Initialization error\n%s" % message
	error_label.visible = true
