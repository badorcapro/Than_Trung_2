class_name MovementRollSource
extends RefCounted


func roll_distance(maximum: int) -> int:
	return 1 if maximum > 0 else 0
