extends Control

const PROTOTYPE_B_PLAYER_SUMMARY := preload(
	"res://scripts/domain/prototype_b/PrototypeBPlayerSummary.gd"
)
const PROTOTYPE_B_SESSION := preload("res://scripts/domain/prototype_b/PrototypeBSession.gd")
const PROTOTYPE_B_COMPLETION_VALIDATOR := preload(
	"res://scripts/application/prototype_b/PrototypeBCompletionValidator.gd"
)
const PROTOTYPE_B_SUMMARY_SERVICE := preload(
	"res://scripts/application/prototype_b/PrototypeBSummaryService.gd"
)
const PROTOTYPE_B_EXPORT_SERVICE := preload(
	"res://scripts/application/prototype_b/PrototypeBExportService.gd"
)
const PROTOTYPE_B_FLOW_SERVICE := preload(
	"res://scripts/application/prototype_b/PrototypeBFlowService.gd"
)

var session: PROTOTYPE_B_SESSION
var flow: PROTOTYPE_B_FLOW_SERVICE = PROTOTYPE_B_FLOW_SERVICE.new()
var summary_service: PROTOTYPE_B_SUMMARY_SERVICE = PROTOTYPE_B_SUMMARY_SERVICE.new()
var export_service: PROTOTYPE_B_EXPORT_SERVICE = PROTOTYPE_B_EXPORT_SERVICE.new()
@onready var status_label: Label = %StatusLabel
@onready var summary_text: RichTextLabel = %SummaryText
@onready var export_label: Label = %ExportStatus


func _ready() -> void:
	_start(3)


func _start(count: int) -> void:
	session = flow.create_test_only_session(count)
	export_label.text = "Chưa export · TEST_ONLY / PROTOTYPE / NOT_CANON_LOCKED"
	_render()


func _on_one_pressed() -> void:
	_start(1)


func _on_three_pressed() -> void:
	_start(3)


func _on_four_pressed() -> void:
	_start(4)


func _on_advance_pressed() -> void:
	var result: Dictionary = flow.complete_test_only_flow(session)
	export_label.text = "%s" % result.get("code", "UNKNOWN")
	_render()


func _on_summary_pressed() -> void:
	var result: Dictionary = flow.enter_summary(session)
	export_label.text = "%s" % result.get("code", "UNKNOWN")
	_render()


func _on_validate_pressed() -> void:
	var report = PROTOTYPE_B_COMPLETION_VALIDATOR.new().validate_summary(session, session.summary)
	export_label.text = (
		"Validation PASS" if report.passed() else "Validation FAIL: %s" % ", ".join(report.codes())
	)


func _on_export_pressed() -> void:
	var result: Dictionary = export_service.export_snapshot(session)
	export_label.text = "%s · %s" % [result.get("code", "UNKNOWN"), result.get("path", "")]


func _on_validate_export_pressed() -> void:
	var report = export_service.parse_and_validate(session.export_path, session)
	export_label.text = (
		"Export round-trip PASS"
		if report.passed()
		else "Export FAIL: %s" % ", ".join(report.codes())
	)


func _on_finish_pressed() -> void:
	var result: Dictionary = summary_service.finalize_prototype_b(session)
	export_label.text = "%s" % result.get("code", "UNKNOWN")
	_render()


func _on_back_pressed() -> void:
	AppFlow.go_to_debug_home()


func _render() -> void:
	status_label.text = "Status: %s · %d player" % [session.status_name(), session.players.size()]
	var lines: Array[String] = []
	if session.summary == null:
		lines.append("Full-flow session giữ cùng PlayerPhaseState qua M2 → M6.")
		for player: PlayerPhaseState in session.players:
			lines.append(
				"P%d · %s · %s" % [player.seat_index + 1, player.character_id, player.phase_id]
			)
	else:
		for player_summary: PROTOTYPE_B_PLAYER_SUMMARY in session.summary.player_summaries:
			var row := player_summary.data
			var resources_value: Variant = row.get("resources", {})
			var resources := resources_value as Dictionary if resources_value is Dictionary else {}
			(
				lines
				. append(
					(
						"[b]%s · %s[/b]\nOrigin: %s · Node: %s\nSilver %d · Orb %d · Vé %d · EXP %d · Exchange %d\nEquipment %d · Done %s"
						% [
							row.get("player_id", ""),
							row.get("character", ""),
							row.get("origin_house_id", ""),
							row.get("final_loot_node", ""),
							int(resources.get("silver", 0)),
							int(resources.get("orb", 0)),
							int(resources.get("gacha_ticket", 0)),
							int(resources.get("equipment_exp", 0)),
							int(resources.get("equipment_exchange", 0)),
							int(row.get("equipment_collection_count", 0)),
							row.get("management_done", false)
						]
					)
				)
			)
		lines.append("\n[b]Aggregate[/b]\n%s" % JSON.stringify(session.summary.aggregates, "  "))
	summary_text.text = "\n\n".join(lines)
