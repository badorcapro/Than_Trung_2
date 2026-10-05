class_name PrototypeBValidationReport
extends RefCounted

var issues: Array[Dictionary] = []


func add(code: StringName, message: String, source: StringName) -> void:
	issues.append({"code": String(code), "message": message, "source": String(source)})


func passed() -> bool:
	return issues.is_empty()


func codes() -> Array[String]:
	var result: Array[String] = []
	for issue: Dictionary in issues:
		result.append(String(issue.get("code", "UNKNOWN")))
	return result
