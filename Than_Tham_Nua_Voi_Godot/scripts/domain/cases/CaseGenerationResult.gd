class_name CaseGenerationResult
extends RefCounted

const STATUS_SUCCESS: StringName = &"success"
const STATUS_FAILURE: StringName = &"failure"
const ERROR_REQUEST_NULL: StringName = &"REQUEST_NULL"
const ERROR_BOARD_DIMENSIONS_INVALID: StringName = &"BOARD_DIMENSIONS_INVALID"
const ERROR_PROFILE_UNSUPPORTED: StringName = &"PROFILE_UNSUPPORTED"
const ERROR_CONTENT_POOL_EMPTY: StringName = &"CONTENT_POOL_EMPTY"
const ERROR_ROLE_ID_EMPTY: StringName = &"ROLE_ID_EMPTY"
const ERROR_ROLE_ID_UNKNOWN: StringName = &"ROLE_ID_UNKNOWN"
const ERROR_BOARD_CAPACITY_EXCEEDED: StringName = &"BOARD_CAPACITY_EXCEEDED"
const ERROR_INSUFFICIENT_UNIQUE_ROLES: StringName = &"INSUFFICIENT_UNIQUE_ROLES"
const ERROR_ALIGNMENT_POOL_INVALID: StringName = &"ALIGNMENT_POOL_INVALID"
const ERROR_GENERATOR_VERSION_INVALID: StringName = &"GENERATOR_VERSION_INVALID"
const ERROR_IMPOSSIBLE_REQUEST: StringName = &"IMPOSSIBLE_REQUEST"

var status: StringName = STATUS_FAILURE
var error_code: StringName = &""
var error_message: String = ""
var seed_used: int = 0
var generator_version: int = 0
var board_columns: int = 0
var board_rows: int = 0
var board_slot_count: int = 0
var generation_profile_id: StringName = &""
var allowed_role_ids: Array[StringName] = []
var suspected_role_ids: Array[StringName] = []
var logical_board_slots: PackedInt32Array = PackedInt32Array()
var probe_slot_sequence: PackedInt32Array = PackedInt32Array()
var draft_tiles: Array[Dictionary] = []
var assigned_hidden_role_ids: Array[StringName] = []
var hidden_case_draft = null
var generation_attempts: int = 0
var fingerprint: String = ""


static func failure(request: CaseGenerationRequest, code: StringName, message: String) -> CaseGenerationResult:
	var result := CaseGenerationResult.new()
	result.status = STATUS_FAILURE
	result.error_code = code
	result.error_message = message
	if request != null:
		result.seed_used = request.seed
		result.generator_version = request.generator_version
		result.board_columns = request.board_columns
		result.board_rows = request.board_rows
		result.board_slot_count = request.board_slot_count
		result.generation_profile_id = request.generation_profile_id
	return result


func is_success() -> bool:
	return status == STATUS_SUCCESS
