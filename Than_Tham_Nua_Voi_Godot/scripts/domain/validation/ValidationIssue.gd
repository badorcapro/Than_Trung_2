class_name ValidationIssue
extends RefCounted

var code: StringName
var message := ""
var source := ""

func _init(issue_code: StringName = &"", issue_message := "", issue_source := "") -> void:
	code = issue_code
	message = issue_message
	source = issue_source
