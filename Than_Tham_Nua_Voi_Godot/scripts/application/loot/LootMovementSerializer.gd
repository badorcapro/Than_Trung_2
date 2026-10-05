class_name LootMovementSerializer
extends RefCounted


func serialize_session(session: LootMovementSession) -> String:
	return "" if session == null else JSON.stringify(session.to_dict())


func deserialize_session(payload: String) -> LootMovementSession:
	var parsed: Variant = JSON.parse_string(payload)
	if not parsed is Dictionary:
		return null
	return LootMovementSession.from_dict(parsed)


func round_trip_matches(session: LootMovementSession) -> bool:
	var restored: LootMovementSession = deserialize_session(serialize_session(session))
	return session != null and session.semantically_equals(restored)
