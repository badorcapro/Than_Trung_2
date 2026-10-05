class_name CaseGenerationRequest
extends RefCounted

const DEFAULT_GENERATOR_VERSION := 1
const PROFILE_TUTORIAL_EASY: StringName = &"tutorial_easy"
const PROFILE_NORMAL_FULL: StringName = &"normal_full"

var seed: int = 0
var board_columns: int = 3
var board_rows: int = 3
var board_slot_count: int = 9
var generation_profile_id: StringName = PROFILE_TUTORIAL_EASY
var allowed_role_ids: Array[StringName] = []
var required_location_ids: Array[StringName] = []
var required_suspect_count: int = 0
var generator_version: int = DEFAULT_GENERATOR_VERSION


static func create(
	source_seed: int,
	columns: int,
	rows: int,
	profile_id: StringName,
	role_ids: Array[StringName],
	location_ids: Array[StringName] = [],
	suspect_count: int = 0,
	version: int = DEFAULT_GENERATOR_VERSION
) -> CaseGenerationRequest:
	var request := CaseGenerationRequest.new()
	request.seed = source_seed
	request.board_columns = columns
	request.board_rows = rows
	request.board_slot_count = columns * rows
	request.generation_profile_id = profile_id
	request.allowed_role_ids = role_ids.duplicate()
	request.required_location_ids = location_ids.duplicate()
	request.required_suspect_count = suspect_count
	request.generator_version = version
	return request


func canonical_config_text() -> String:
	return "v%d|profile:%s|board:%dx%d|roles:%s|locations:%s|suspects:%d" % [
		generator_version,
		String(generation_profile_id),
		board_columns,
		board_rows,
		_join_string_names(allowed_role_ids),
		_join_string_names(required_location_ids),
		required_suspect_count,
	]


func _join_string_names(values: Array[StringName]) -> String:
	var parts: Array[String] = []
	for value: StringName in values:
		parts.append(String(value))
	return ",".join(parts)
