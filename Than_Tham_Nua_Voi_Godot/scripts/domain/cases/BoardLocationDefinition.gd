class_name BoardLocationDefinition
extends Resource

const LOCATION_CRIME_SCENE: StringName = &"crime_scene"
const LOCATION_CLOCK_TOWER: StringName = &"clock_tower"

@export var location_id: StringName
@export var display_name: String
@export var board_slot: int = -1


func is_crime_scene() -> bool:
	return location_id == LOCATION_CRIME_SCENE


func is_clock_tower() -> bool:
	return location_id == LOCATION_CLOCK_TOWER
