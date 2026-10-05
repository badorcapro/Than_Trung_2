class_name LoadoutState
extends RefCounted

var relic_instance_id: StringName
var stigmata_a_instance_id: StringName
var stigmata_b_instance_id: StringName
var stigmata_c_instance_id: StringName

func all_instance_ids() -> Array[StringName]:
	return [relic_instance_id, stigmata_a_instance_id, stigmata_b_instance_id, stigmata_c_instance_id]
