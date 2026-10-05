class_name SeededRewardRollSource
extends RewardRollSource

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _init(seed_value: int = 0) -> void:
	if seed_value == 0: _rng.randomize()
	else: _rng.seed = seed_value

func pick_index(option_count: int) -> int:
	return -1 if option_count <= 0 else _rng.randi_range(0, option_count - 1)
