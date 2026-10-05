class_name Gd2StateSerializer
extends RefCounted

func serialize_player(state: PlayerPhaseState) -> String:
	if state == null: return ""
	return JSON.stringify(state.to_persistent_dict())

func deserialize_player(payload: String) -> PlayerPhaseState:
	var data: Variant = JSON.parse_string(payload)
	if not data is Dictionary: return null
	return PlayerPhaseState.from_persistent_dict(data)

func round_trip_matches(state: PlayerPhaseState) -> bool:
	var restored: PlayerPhaseState = deserialize_player(serialize_player(state))
	return state != null and restored != null and state.to_persistent_dict() == restored.to_persistent_dict()

func serialize_players(states: Array[PlayerPhaseState]) -> String:
	var rows: Array[Dictionary] = []
	for state: PlayerPhaseState in states:
		if state == null: return ""
		rows.append(state.to_persistent_dict())
	return JSON.stringify(rows)

func deserialize_players(payload: String) -> Array[PlayerPhaseState]:
	var result: Array[PlayerPhaseState] = []
	var data: Variant = JSON.parse_string(payload)
	if not data is Array: return result
	for row: Variant in data:
		if not row is Dictionary:
			result.clear()
			return result
		result.append(PlayerPhaseState.from_persistent_dict(row))
	return result

func players_round_trip_match(states: Array[PlayerPhaseState]) -> bool:
	var restored: Array[PlayerPhaseState] = deserialize_players(serialize_players(states))
	if restored.size() != states.size(): return false
	for index: int in range(states.size()):
		if states[index].to_persistent_dict() != restored[index].to_persistent_dict(): return false
	return true

func contains_forbidden_runtime_value(value: Variant) -> bool:
	if value is Node or value is Callable or value is Resource: return true
	if value is Dictionary:
		for child in value.values():
			if contains_forbidden_runtime_value(child): return true
	elif value is Array:
		for child in value:
			if contains_forbidden_runtime_value(child): return true
	return false
