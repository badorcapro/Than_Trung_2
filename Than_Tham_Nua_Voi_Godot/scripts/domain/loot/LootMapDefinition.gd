class_name LootMapDefinition
extends Resource

@export var map_id: StringName
@export var data_version := 1
@export var nodes: Array[LootNodeDefinition] = []
@export var origin_spawn_by_house: Dictionary = {}
@export var test_only_not_canon_locked := true

func find_node(node_id: StringName) -> LootNodeDefinition:
	for node in nodes:
		if node != null and node.node_id == node_id:
			return node
	return null
