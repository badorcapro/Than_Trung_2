class_name CharacterDefinition
extends Resource

@export var character_id: StringName
@export var data_version := 1
@export var display_name: String
@export var origin_house_id: StringName
@export_range(1, 99, 1) var base_speed := 1
@export_range(0, 99, 1) var base_stamina := 0
@export_range(0, 99, 1) var base_bag_level := 0
@export var passive_skill_id: StringName
@export var active_skill_id: StringName
@export_range(0, 999, 1) var active_orb_requirement := 0
@export var test_only_not_canon_locked := true
