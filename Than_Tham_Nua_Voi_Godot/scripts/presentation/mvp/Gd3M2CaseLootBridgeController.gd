class_name Gd3M2CaseLootBridgeController
extends Control

const BRIDGE_SERVICE := preload(
	"res://scripts/application/mvp/MvpCaseLootBridgeService.gd"
)

@onready var status_label: Label = %StatusLabel
@onready var report_text: RichTextLabel = %ReportText

var bridge: BRIDGE_SERVICE = BRIDGE_SERVICE.new()


func _ready() -> void:
	_show({"success": true, "code": "READY", "message": "Build the integration fixture"})


func _on_build_pressed() -> void:
	_show(bridge.build_integration_fixture())


func _on_settlement_pressed() -> void:
	_show(bridge.run_actual_settlement())


func _on_apply_pressed() -> void:
	_show(bridge.apply_settlement())


func _on_duplicate_pressed() -> void:
	_show(bridge.try_duplicate_apply())


func _on_loot_pressed() -> void:
	_show(bridge.project_to_loot())


func _on_validate_pressed() -> void:
	_show(bridge.validate_bridge())


func _on_full_pressed() -> void:
	_show(bridge.run_full_bridge())


func _on_back_pressed() -> void:
	AppFlow.go_to_debug_home()


func _show(result: Dictionary) -> void:
	var passed := bool(result.get("success", false))
	status_label.text = "%s — %s: %s" % [
		"PASS" if passed else "BLOCKED",
		String(result.get("code", "UNKNOWN")),
		String(result.get("message", "")),
	]
	status_label.modulate = Color(0.55, 1.0, 0.65) if passed else Color(1.0, 0.62, 0.52)
	report_text.text = bridge.report_text()

