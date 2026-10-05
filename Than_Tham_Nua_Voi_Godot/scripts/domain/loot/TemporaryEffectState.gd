class_name TemporaryEffectState
extends RefCounted

enum Duration { THIS_MOVE, THIS_TURN, THIS_ROUND, OTHER }

var effect_id: StringName
var source_id: StringName
var target_player_ids: Array[StringName] = []
var effect_kind: StringName
var magnitude := 0.0
var duration: Duration = Duration.THIS_MOVE
var remaining := 1
var active := true

func to_dict() -> Dictionary:
	var targets: Array[String] = []
	for id in target_player_ids: targets.append(String(id))
	return {"effect_id":String(effect_id), "source_id":String(source_id), "target_player_ids":targets, "effect_kind":String(effect_kind), "magnitude":magnitude, "duration":duration, "remaining":remaining, "active":active}

static func from_dict(data: Dictionary) -> TemporaryEffectState:
	var result := TemporaryEffectState.new()
	result.effect_id = StringName(data.get("effect_id", "")); result.source_id = StringName(data.get("source_id", "")); result.effect_kind = StringName(data.get("effect_kind", ""))
	var targets_value: Variant = data.get("target_player_ids", [])
	if targets_value is Array:
		for id: Variant in targets_value: result.target_player_ids.append(StringName(id))
	result.magnitude = float(data.get("magnitude", 0.0)); result.duration = int(data.get("duration", 0)); result.remaining = int(data.get("remaining", 1)); result.active = bool(data.get("active", true))
	return result
