class_name HouseDefinition
extends Resource

enum SpatialRole { CENTER, SOUTH, WEST, NORTH, EAST }

@export var house_id: StringName
@export var display_name: String
@export var display_order := 0
@export var spatial_role: SpatialRole = SpatialRole.CENTER


func is_valid() -> bool:
	return not house_id.is_empty() and not display_name.is_empty() and display_order > 0
