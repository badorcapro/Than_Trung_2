class_name LootValidationReport
extends RefCounted

var is_valid := true
var errors: Array[ValidationIssue] = []
var warnings: Array[ValidationIssue] = []

var passed: bool:
	get:
		return is_valid

func add_error(code: StringName, message := "", source := "") -> void:
	is_valid = false
	errors.append(ValidationIssue.new(code, message, source))

func add_warning(code: StringName, message := "", source := "") -> void:
	warnings.append(ValidationIssue.new(code, message, source))

func merge(other: LootValidationReport) -> void:
	if other == null: return
	for issue in other.errors: errors.append(issue)
	for issue in other.warnings: warnings.append(issue)
	is_valid = errors.is_empty()

func formatted_lines() -> Array[String]:
	var lines: Array[String] = []
	for issue in errors: lines.append("ERROR [%s] %s (%s)" % [issue.code, issue.message, issue.source])
	for issue in warnings: lines.append("WARN [%s] %s (%s)" % [issue.code, issue.message, issue.source])
	if lines.is_empty(): lines.append("PASS — no validation issues")
	return lines
