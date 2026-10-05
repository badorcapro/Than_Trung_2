class_name SequenceGachaRollSource
extends RefCounted

var values:Array[int]=[]
var index:=0
func _init(sequence:Array[int]=[])->void:values=sequence.duplicate()
func next_percent()->int:
	if values.is_empty():return 0
	var value:int=values[index%values.size()];index+=1;return clampi(value,0,99)
