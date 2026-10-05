class_name SequenceMovementRollSource
extends MovementRollSource

var _values: Array[int] = []
var _index := 0


func _init(values: Array[int] = []) -> void:
	_values = values.duplicate()


func roll_distance(maximum: int) -> int:
	if maximum <= 0:
		return 0
	var value := 1
	if not _values.is_empty():
		value = _values[_index % _values.size()]
		_index += 1
	return clampi(value, 1, maximum)
