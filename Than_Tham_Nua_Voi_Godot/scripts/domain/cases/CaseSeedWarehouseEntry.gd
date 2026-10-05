class_name CaseSeedWarehouseEntry
extends RefCounted

const SCHEMA_VERSION := 1

var schema_version: int = SCHEMA_VERSION
var root_seed: int = 0
var accepted_derived_seed: int = 0
var accepted_attempt_index: int = -1
var board_columns: int = 0
var board_rows: int = 0
var board_slot_count: int = 0
var generation_profile_id: StringName = &""
var allowed_role_ids: Array[StringName] = []
var required_location_ids: Array[StringName] = []
var required_suspect_count: int = 0
var generator_version: int = 0
var candidate_signature: String = ""
var evil_suspect_ids: PackedInt32Array = PackedInt32Array()
var solver_signature: String = ""
var acceptance_signature: String = ""


static func from_acceptance(request: CaseGenerationRequest, acceptance: CaseGenerationAcceptanceResult):
	if request == null or acceptance == null or not acceptance.success:
		return null
	var entry := CaseSeedWarehouseEntry.new()
	entry.root_seed = request.seed
	entry.accepted_derived_seed = acceptance.accepted_derived_seed
	entry.accepted_attempt_index = acceptance.accepted_attempt_index
	entry.board_columns = request.board_columns
	entry.board_rows = request.board_rows
	entry.board_slot_count = request.board_slot_count
	entry.generation_profile_id = request.generation_profile_id
	entry.allowed_role_ids = request.allowed_role_ids.duplicate()
	entry.required_location_ids = request.required_location_ids.duplicate()
	entry.required_suspect_count = request.required_suspect_count
	entry.generator_version = request.generator_version
	entry.candidate_signature = _candidate_signature(acceptance.accepted_candidate)
	entry.solver_signature = _solver_signature(acceptance.accepted_solver_result)
	entry.acceptance_signature = acceptance.fingerprint_text()
	entry.evil_suspect_ids = _solver_evil_ids(acceptance.accepted_solver_result)
	return entry


func request() -> CaseGenerationRequest:
	return CaseGenerationRequest.create(
		root_seed,
		board_columns,
		board_rows,
		generation_profile_id,
		allowed_role_ids,
		required_location_ids,
		required_suspect_count,
		generator_version
	)


func signature_text() -> String:
	return "warehouse_entry|schema:%d|root:%d|seed:%d|attempt:%d|config:%s|candidate:%s|evil:%s|solver:%s" % [
		schema_version,
		root_seed,
		accepted_derived_seed,
		accepted_attempt_index,
		_config_signature(),
		candidate_signature,
		_join_ints(evil_suspect_ids),
		solver_signature,
	]


func to_dictionary() -> Dictionary:
	return {
		"schema_version": schema_version,
		"root_seed": root_seed,
		"accepted_derived_seed": accepted_derived_seed,
		"accepted_attempt_index": accepted_attempt_index,
		"board_columns": board_columns,
		"board_rows": board_rows,
		"board_slot_count": board_slot_count,
		"generation_profile_id": generation_profile_id,
		"allowed_role_ids": allowed_role_ids.duplicate(),
		"required_location_ids": required_location_ids.duplicate(),
		"required_suspect_count": required_suspect_count,
		"generator_version": generator_version,
		"candidate_signature": candidate_signature,
		"evil_suspect_ids": evil_suspect_ids.duplicate(),
		"solver_signature": solver_signature,
		"acceptance_signature": acceptance_signature,
	}


static func from_dictionary(data: Dictionary):
	var entry := CaseSeedWarehouseEntry.new()
	entry.schema_version = int(data.get("schema_version", 0))
	entry.root_seed = int(data.get("root_seed", 0))
	entry.accepted_derived_seed = int(data.get("accepted_derived_seed", 0))
	entry.accepted_attempt_index = int(data.get("accepted_attempt_index", -1))
	entry.board_columns = int(data.get("board_columns", 0))
	entry.board_rows = int(data.get("board_rows", 0))
	entry.board_slot_count = int(data.get("board_slot_count", 0))
	entry.generation_profile_id = StringName(String(data.get("generation_profile_id", "")))
	entry.allowed_role_ids = _string_name_array(data.get("allowed_role_ids", []))
	entry.required_location_ids = _string_name_array(data.get("required_location_ids", []))
	entry.required_suspect_count = int(data.get("required_suspect_count", 0))
	entry.generator_version = int(data.get("generator_version", 0))
	entry.candidate_signature = String(data.get("candidate_signature", ""))
	entry.evil_suspect_ids = _packed_ints(data.get("evil_suspect_ids", PackedInt32Array()))
	entry.solver_signature = String(data.get("solver_signature", ""))
	entry.acceptance_signature = String(data.get("acceptance_signature", ""))
	return entry


func _config_signature() -> String:
	return "v%d|profile:%s|board:%dx%d|roles:%s|locations:%s|suspects:%d" % [
		generator_version,
		String(generation_profile_id),
		board_columns,
		board_rows,
		_join_string_names(allowed_role_ids),
		_join_string_names(required_location_ids),
		required_suspect_count,
	]


static func _candidate_signature(candidate) -> String:
	if candidate == null:
		return ""
	if candidate is Dictionary:
		return String(candidate.get("fingerprint", ""))
	if candidate is Object:
		return String((candidate as Object).get("fingerprint"))
	return ""


static func _solver_signature(solver_result) -> String:
	if solver_result is Object and (solver_result as Object).has_method("fingerprint_text"):
		return String((solver_result as Object).call("fingerprint_text"))
	return ""


static func _solver_evil_ids(solver_result) -> PackedInt32Array:
	if solver_result is Object:
		return _packed_ints((solver_result as Object).get("unique_evil_suspect_ids"))
	return PackedInt32Array()


static func _packed_ints(value: Variant) -> PackedInt32Array:
	if value is PackedInt32Array:
		var packed: PackedInt32Array = value
		return packed.duplicate()
	var result: PackedInt32Array = PackedInt32Array()
	if value is Array:
		for entry: Variant in value:
			result.append(int(entry))
	result.sort()
	return result


static func _string_name_array(value: Variant) -> Array[StringName]:
	var result: Array[StringName] = []
	if value is Array:
		for entry: Variant in value:
			result.append(StringName(str(entry)))
	return result


func _join_string_names(values: Array[StringName]) -> String:
	var parts: Array[String] = []
	for value: StringName in values:
		parts.append(String(value))
	return ",".join(parts)


func _join_ints(values: PackedInt32Array) -> String:
	var parts: Array[String] = []
	for value: int in values:
		parts.append(str(value))
	return ",".join(parts)
