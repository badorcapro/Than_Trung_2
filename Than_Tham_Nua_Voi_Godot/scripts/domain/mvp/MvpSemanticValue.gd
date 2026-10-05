class_name MvpSemanticValue
extends RefCounted


static func normalize_dictionary(source: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key: Variant in source.keys():
		result[String(key)] = normalize(source.get(key))
	return result


static func normalize_dictionary_array(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not value is Array:
		return result
	for child: Variant in value:
		if child is Dictionary:
			result.append(normalize_dictionary(child))
	return result


static func normalize(value: Variant) -> Variant:
	if value is Dictionary:
		return normalize_dictionary(value)
	if value is Array:
		var result: Array[Variant] = []
		for child: Variant in value:
			result.append(normalize(child))
		return result
	if value is StringName:
		return String(value)
	if value is float and is_finite(value) and value == floor(value):
		return int(value)
	return value


static func collect_mismatches(
	path: String, expected: Variant, actual: Variant, result: Array[String]
) -> void:
	var normalized_expected: Variant = normalize(expected)
	var normalized_actual: Variant = normalize(actual)
	if normalized_expected is Dictionary and normalized_actual is Dictionary:
		var keys: Dictionary = {}
		for key: Variant in normalized_expected.keys():
			keys[String(key)] = true
		for key: Variant in normalized_actual.keys():
			keys[String(key)] = true
		for key: String in keys.keys():
			var child_path := "%s.%s" % [path, key]
			if not normalized_expected.has(key):
				result.append("%s unexpected" % child_path)
			elif not normalized_actual.has(key):
				result.append("%s missing" % child_path)
			elif normalized_expected.get(key) != normalized_actual.get(key):
				collect_mismatches(
					child_path,
					normalized_expected.get(key),
					normalized_actual.get(key),
					result
				)
		return
	if normalized_expected is Array and normalized_actual is Array:
		if normalized_expected.size() != normalized_actual.size():
			result.append("%s size mismatch" % path)
			return
		for index: int in range(normalized_expected.size()):
			if normalized_expected[index] != normalized_actual[index]:
				collect_mismatches(
					"%s[%d]" % [path, index],
					normalized_expected[index],
					normalized_actual[index],
					result
				)
		return
	result.append("%s mismatch" % path)
