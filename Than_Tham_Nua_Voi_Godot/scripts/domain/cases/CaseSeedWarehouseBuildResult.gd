class_name CaseSeedWarehouseBuildResult
extends RefCounted

const SCHEMA_VERSION := 1
const FAILURE_NONE: StringName = &""
const FAILURE_REQUEST_NULL: StringName = &"request_null"
const FAILURE_TARGET_COUNT_INVALID: StringName = &"target_count_invalid"

var schema_version: int = SCHEMA_VERSION
var entries: Array[CaseSeedWarehouseEntry] = []
var requested_root_seeds: PackedInt32Array = PackedInt32Array()
var target_count: int = 0
var produced_count: int = 0
var rejected_root_count: int = 0
var duplicate_skipped_count: int = 0
var failure_summary: Dictionary = {}
var build_signature: String = ""
var failure_reason: StringName = FAILURE_NONE
var generator_version: int = 0
var generation_profile_id: StringName = &""


func record_failure(reason: StringName) -> void:
	rejected_root_count += 1
	var current_count: int = int(failure_summary.get(reason, 0))
	failure_summary[reason] = current_count + 1


func record_duplicate() -> void:
	duplicate_skipped_count += 1
	var current_count: int = int(failure_summary.get(&"duplicate_signature", 0))
	failure_summary[&"duplicate_signature"] = current_count + 1


func finalize_signature() -> void:
	produced_count = entries.size()
	var entry_signatures: Array[String] = []
	for entry: CaseSeedWarehouseEntry in entries:
		if entry != null:
			entry_signatures.append(entry.signature_text())
	var failure_parts: Array[String] = []
	for key: Variant in failure_summary.keys():
		failure_parts.append("%s:%d" % [String(key), int(failure_summary.get(key, 0))])
	failure_parts.sort()
	build_signature = "warehouse_build|schema:%d|profile:%s|version:%d|target:%d|roots:%s|produced:%d|rejected:%d|duplicates:%d|entries:%s|failures:%s|failure:%s" % [
		schema_version,
		String(generation_profile_id),
		generator_version,
		target_count,
		_join_ints(requested_root_seeds),
		produced_count,
		rejected_root_count,
		duplicate_skipped_count,
		"||".join(entry_signatures),
		";".join(failure_parts),
		String(failure_reason),
	]


func ordered_entry_signatures() -> Array[String]:
	var signatures: Array[String] = []
	for entry: CaseSeedWarehouseEntry in entries:
		if entry != null:
			signatures.append(entry.signature_text())
	return signatures


func to_dictionary() -> Dictionary:
	var entry_data: Array[Dictionary] = []
	for entry: CaseSeedWarehouseEntry in entries:
		if entry != null:
			entry_data.append(entry.to_dictionary())
	return {
		"schema_version": schema_version,
		"entries": entry_data,
		"requested_root_seeds": requested_root_seeds.duplicate(),
		"target_count": target_count,
		"produced_count": produced_count,
		"rejected_root_count": rejected_root_count,
		"duplicate_skipped_count": duplicate_skipped_count,
		"failure_summary": failure_summary.duplicate(),
		"build_signature": build_signature,
		"failure_reason": failure_reason,
		"generator_version": generator_version,
		"generation_profile_id": generation_profile_id,
	}


static func from_dictionary(data: Dictionary) -> CaseSeedWarehouseBuildResult:
	var result := CaseSeedWarehouseBuildResult.new()
	result.schema_version = int(data.get("schema_version", 0))
	var raw_entries: Variant = data.get("entries", [])
	if raw_entries is Array:
		for raw_entry: Variant in raw_entries:
			if raw_entry is Dictionary:
				var entry: CaseSeedWarehouseEntry = CaseSeedWarehouseEntry.from_dictionary(raw_entry)
				result.entries.append(entry)
	result.requested_root_seeds = _packed_ints(data.get("requested_root_seeds", PackedInt32Array()))
	result.target_count = int(data.get("target_count", 0))
	result.produced_count = int(data.get("produced_count", result.entries.size()))
	result.rejected_root_count = int(data.get("rejected_root_count", 0))
	result.duplicate_skipped_count = int(data.get("duplicate_skipped_count", 0))
	var raw_failure_summary: Variant = data.get("failure_summary", {})
	if raw_failure_summary is Dictionary:
		result.failure_summary = raw_failure_summary.duplicate()
	else:
		result.failure_summary = {}
	result.build_signature = String(data.get("build_signature", ""))
	result.failure_reason = StringName(String(data.get("failure_reason", "")))
	result.generator_version = int(data.get("generator_version", 0))
	result.generation_profile_id = StringName(String(data.get("generation_profile_id", "")))
	return result


func _join_ints(values: PackedInt32Array) -> String:
	var parts: Array[String] = []
	for value: int in values:
		parts.append(str(value))
	return ",".join(parts)


static func _packed_ints(value: Variant) -> PackedInt32Array:
	if value is PackedInt32Array:
		var packed: PackedInt32Array = value
		return packed.duplicate()
	var result: PackedInt32Array = PackedInt32Array()
	if value is Array:
		for entry: Variant in value:
			result.append(int(entry))
	return result
