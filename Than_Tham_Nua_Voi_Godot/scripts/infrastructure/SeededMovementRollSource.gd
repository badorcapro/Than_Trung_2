class_name SeededMovementRollSource
extends MovementRollSource

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(seed_value: int = 0) -> void:
	if seed_value == 0:
		_rng.randomize()
	else:
		_rng.seed = seed_value


func roll_distance(maximum: int) -> int:
	return 0 if maximum <= 0 else _rng.randi_range(1, maximum)
