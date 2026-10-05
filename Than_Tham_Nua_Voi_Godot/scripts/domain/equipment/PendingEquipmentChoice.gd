class_name PendingEquipmentChoice
extends RefCounted

enum Kind { NONE, SS_STIGMATA, S_EQUIPMENT }
var kind := Kind.NONE
var player_id: StringName
var source_entry_id: StringName
var eligible_definition_ids: Array[StringName] = []

func is_active() -> bool: return kind != Kind.NONE
func to_dict() -> Dictionary:
	var ids: Array[String] = []
	for id: StringName in eligible_definition_ids: ids.append(String(id))
	return {"kind":kind,"player_id":String(player_id),"source_entry_id":String(source_entry_id),"eligible_definition_ids":ids}
static func from_dict(data: Dictionary) -> PendingEquipmentChoice:
	var result := PendingEquipmentChoice.new(); result.kind = int(data.get("kind", 0)); result.player_id = StringName(data.get("player_id", "")); result.source_entry_id = StringName(data.get("source_entry_id", ""))
	var values: Variant = data.get("eligible_definition_ids", [])
	if values is Array:
		for value: Variant in values: result.eligible_definition_ids.append(StringName(value))
	return result
