class_name LootNodeDefinition
extends Resource

@export var node_id: StringName
@export var node_kind: StringName = &"PATH"
@export var tags: Array[StringName] = []
@export var origin_house_id: StringName
@export var outgoing_neighbor_ids: Array[StringName] = []
@export var reward_profile_id: StringName
@export var display_name: String
@export var world_position := Vector2.ZERO
@export var test_only_not_canon_locked := true
