extends Node

signal log_emitted(level: String, message: String, formatted_line: String)

const LEVEL_INFO := "INFO"
const LEVEL_WARNING := "WARNING"
const LEVEL_ERROR := "ERROR"

var _recent_lines: Array[String] = []
const MAX_RECENT_LINES := 12


func info(message: String) -> void:
	_write(LEVEL_INFO, message)


func warning(message: String) -> void:
	_write(LEVEL_WARNING, message)


func error(message: String) -> void:
	_write(LEVEL_ERROR, message)


func recent_lines() -> Array[String]:
	return _recent_lines.duplicate()


func _write(level: String, message: String) -> void:
	var line := "%s: %s" % [level, message]
	_recent_lines.append(line)
	if _recent_lines.size() > MAX_RECENT_LINES:
		_recent_lines.pop_front()
	match level:
		LEVEL_WARNING:
			push_warning(message)
		LEVEL_ERROR:
			push_error(message)
		_:
			print(line)
	log_emitted.emit(level, message, line)

