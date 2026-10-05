class_name ClockTowerDefinition
extends BoardLocationDefinition

@export_range(1, 23, 1) var ring_hour: int = 8


func _init() -> void:
	location_id = BoardLocationDefinition.LOCATION_CLOCK_TOWER
