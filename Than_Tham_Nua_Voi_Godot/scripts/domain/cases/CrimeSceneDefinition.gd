class_name CrimeSceneDefinition
extends BoardLocationDefinition

@export var scene_id: StringName
@export_multiline var description: String


func _init() -> void:
	location_id = BoardLocationDefinition.LOCATION_CRIME_SCENE
