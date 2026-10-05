class_name SequenceRewardRollSource
extends RewardRollSource

var _values: Array[int] = []
var _index := 0

func _init(values: Array[int] = []) -> void:
	_values = values.duplicate()

func pick_index(option_count: int) -> int:
	if option_count <= 0: return -1
	var value := 0
	if not _values.is_empty():
		value = _values[_index % _values.size()]
		_index += 1
	return posmod(value, option_count)
