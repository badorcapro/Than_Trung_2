class_name PrototypeBExportService
extends RefCounted

const PROTOTYPE_B_SESSION := preload("res://scripts/domain/prototype_b/PrototypeBSession.gd")
const PROTOTYPE_B_VALIDATION_REPORT := preload(
	"res://scripts/domain/prototype_b/PrototypeBValidationReport.gd"
)
const PROTOTYPE_B_SUMMARY_SERVICE := preload(
	"res://scripts/application/prototype_b/PrototypeBSummaryService.gd"
)
const SCHEMA_VERSION := 1


func build_export(session: PROTOTYPE_B_SESSION) -> Dictionary:
	return {
		"prototype_b_summary_schema": SCHEMA_VERSION,
		"project_version": AppVersion.GAME_VERSION,
		"build_label": AppVersion.BUILD_LABEL,
		"prototype_milestone": AppVersion.CURRENT_MILESTONE,
		"session_id": String(session.session_id),
		"round_id": String(session.round_id),
		"completion_status": String(session.status_name()),
		"fixture_marker": "TEST_ONLY / PROTOTYPE / NOT_CANON_LOCKED",
		"summary": session.summary.to_dict() if session.summary != null else {},
		"resumable_state_snapshot": session.safe_snapshot(),
		"open_policy_ids": PROTOTYPE_B_SUMMARY_SERVICE.OPEN_POLICIES.duplicate(true)
	}


func export_snapshot(session: PROTOTYPE_B_SESSION) -> Dictionary:
	if session.summary == null:
		return {"success": false, "code": "SUMMARY_MISSING", "path": ""}
	var path := "user://prototype_b_summary_%s.json" % String(session.session_id)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"success": false, "code": "FILE_OPEN_FAILED", "path": path}
	file.store_string(JSON.stringify(build_export(session), "  ", true))
	file.close()
	session.export_path = path
	return {"success": true, "code": "EXPORTED", "path": path}


func parse_and_validate(
	path: String, expected_session: PROTOTYPE_B_SESSION = null
) -> PROTOTYPE_B_VALIDATION_REPORT:
	var report: PROTOTYPE_B_VALIDATION_REPORT = PROTOTYPE_B_VALIDATION_REPORT.new()
	if not FileAccess.file_exists(path):
		report.add(&"EXPORT_MISSING", "Export file does not exist", &"export")
		return report
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		report.add(&"EXPORT_READ_FAILED", "Export file cannot be opened", &"export")
		return report
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		report.add(&"EXPORT_JSON_INVALID", "Export is not a JSON object", &"export")
		return report
	var data := parsed as Dictionary
	return validate_export_data(data, expected_session)


func validate_export_data(
	data: Dictionary, expected_session: PROTOTYPE_B_SESSION = null
) -> PROTOTYPE_B_VALIDATION_REPORT:
	var report: PROTOTYPE_B_VALIDATION_REPORT = PROTOTYPE_B_VALIDATION_REPORT.new()
	if int(data.get("prototype_b_summary_schema", 0)) != SCHEMA_VERSION:
		report.add(&"EXPORT_SCHEMA", "Unsupported summary schema", &"export")
	var summary_value: Variant = data.get("summary", {})
	if not summary_value is Dictionary:
		report.add(&"EXPORT_SUMMARY", "Summary object missing", &"export")
	else:
		var summary_data := summary_value as Dictionary
		var players_value: Variant = summary_data.get("player_summaries", [])
		if not players_value is Array:
			report.add(&"EXPORT_PLAYERS", "Player summaries missing", &"export")
		elif expected_session != null and players_value.size() != expected_session.players.size():
			report.add(&"EXPORT_PLAYER_COUNT", "Player count mismatch", &"export")
	if (
		expected_session != null
		and String(data.get("session_id", "")) != String(expected_session.session_id)
	):
		report.add(&"EXPORT_SESSION_ID", "Session id mismatch", &"export")
	if not data.has("open_policy_ids"):
		report.add(&"EXPORT_OPEN_POLICIES", "Open policy ids missing", &"export")
	if not data.has("resumable_state_snapshot"):
		report.add(&"EXPORT_SNAPSHOT", "Safe resumable snapshot missing", &"export")
	return report
