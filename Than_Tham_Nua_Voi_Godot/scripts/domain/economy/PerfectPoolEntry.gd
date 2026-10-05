class_name PerfectPoolEntry
extends Resource

enum Kind { RESOURCE, SS_RELIC, SS_STIGMATA_CHOICE, S_EQUIPMENT_CHOICE }
@export var entry_id: StringName
@export var kind: Kind = Kind.RESOURCE
@export var weight := 1
@export var initial_hits := 1
@export var reward_amount_per_hit := 1
@export var equipment_definition_id: StringName
@export var resource_type: StringName
@export var eligible_definition_ids: Array[StringName] = []
@export var test_only_not_canon_locked := true
