class_name MvpValidationReport
extends RefCounted

var issues: Array[Dictionary] = []


func add_error(code: StringName, message: String, source: StringName) -> void:
	issues.append(
		{"code": String(code), "message": message, "source": String(source), "severity": "ERROR"}
	)


func add_warning(code: StringName, message: String, source: StringName) -> void:
	issues.append(
		{"code": String(code), "message": message, "source": String(source), "severity": "WARNING"}
	)


func merge(other: MvpValidationReport) -> void:
	if other != null:
		issues.append_array(other.issues)


func passed() -> bool:
	for issue: Dictionary in issues:
		if String(issue.get("severity", "ERROR")) == "ERROR":
			return false
	return true


func codes() -> Array[String]:
	var result: Array[String] = []
	for issue: Dictionary in issues:
		result.append(String(issue.get("code", "UNKNOWN")))
	return result
