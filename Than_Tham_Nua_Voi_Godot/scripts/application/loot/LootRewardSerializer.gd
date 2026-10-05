class_name LootRewardSerializer
extends RefCounted

func serialize_session(session: LootRewardSession) -> String:
	return "" if session == null else JSON.stringify(session.to_dict())
func deserialize_session(payload: String) -> LootRewardSession:
	var parsed: Variant = JSON.parse_string(payload)
	return LootRewardSession.from_dict(parsed) if parsed is Dictionary else null
func round_trip_matches(session: LootRewardSession) -> bool:
	var diagnostic: Dictionary = round_trip_diagnostic(session)
	return bool(diagnostic.get("matches", false))

func round_trip_diagnostic(session: LootRewardSession) -> Dictionary:
	if session == null:
		return {"matches":false, "mismatches":["session:null"]}
	var restored: LootRewardSession = deserialize_session(serialize_session(session))
	if restored == null:
		return {"matches":false, "mismatches":["session:deserialize_null"]}
	var mismatches: Array[String] = []
	_collect_mismatches(session.to_dict(), restored.to_dict(), "session", mismatches)
	return {"matches":mismatches.is_empty(), "mismatches":mismatches}

func _collect_mismatches(expected: Variant, actual: Variant, path: String, mismatches: Array[String]) -> void:
	if expected is Dictionary:
		if not actual is Dictionary:
			mismatches.append("%s:type" % path)
			return
		for key_value: Variant in expected.keys():
			if not actual.has(key_value):
				mismatches.append("%s.%s:missing" % [path, String(key_value)])
				continue
			_collect_mismatches(expected.get(key_value), actual.get(key_value), "%s.%s" % [path, String(key_value)], mismatches)
		for key_value: Variant in actual.keys():
			if not expected.has(key_value):
				mismatches.append("%s.%s:unexpected" % [path, String(key_value)])
	elif expected is Array:
		if not actual is Array:
			mismatches.append("%s:type" % path)
			return
		if expected.size() != actual.size():
			mismatches.append("%s:size(%d!=%d)" % [path, expected.size(), actual.size()])
			return
		for index: int in range(expected.size()):
			_collect_mismatches(expected[index], actual[index], "%s[%d]" % [path, index], mismatches)
	elif expected != actual:
		mismatches.append("%s:value(%s!=%s)" % [path, str(expected), str(actual)])
