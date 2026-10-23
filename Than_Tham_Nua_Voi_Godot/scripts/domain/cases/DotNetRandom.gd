class_name DotNetRandom
extends RefCounted

## Donald E. Knuth's Subtractive PRNG matching .NET Mono System.Random.
## Provides cross-platform, deterministic seed parity for procedural case generation.

const MBIG: int = 2147483647
const MSEED: int = 161803398

var seed: int = 0:
	set(val):
		seed = val
		_reseed(val)

var _seed_array: Array[int] = []
var _inext: int = 0
var _inextp: int = 21


func _init(seed_val: int = 0) -> void:
	seed = seed_val
	_reseed(seed_val)


static func _to_int32(x: int) -> int:
	var v: int = x & 0xFFFFFFFF
	if v >= 0x80000000:
		return v - 0x100000000
	return v


func _reseed(seed_val: int) -> void:
	_seed_array.resize(56)
	var subtraction: int = MBIG if seed_val == -2147483648 else abs(seed_val)
	var mj: int = _to_int32(MSEED - subtraction)
	_seed_array[55] = mj
	var mk: int = 1
	for i in range(1, 55):
		var ii: int = (21 * i) % 55
		_seed_array[ii] = mk
		mk = _to_int32(mj - mk)
		if mk < 0:
			mk += MBIG
		mj = _seed_array[ii]

	for _k in range(4):
		for i in range(1, 56):
			var idx: int = 1 + (i + 30) % 55
			_seed_array[i] = _to_int32(_seed_array[i] - _seed_array[idx])
			if _seed_array[i] < 0:
				_seed_array[i] += MBIG

	_inext = 0
	_inextp = 21


func sample() -> float:
	var loc_inext: int = _inext + 1
	var loc_inextp: int = _inextp + 1
	if loc_inext >= 56:
		loc_inext = 1
	if loc_inextp >= 56:
		loc_inextp = 1
	var num: int = _to_int32(_seed_array[loc_inext] - _seed_array[loc_inextp])
	if num == MBIG:
		num -= 1
	if num < 0:
		num += MBIG
	_seed_array[loc_inext] = num
	_inext = loc_inext
	_inextp = loc_inextp
	var s: float = float(num) / float(MBIG)
	return clampf(s, 0.0, 0.999999999999999)


func next(min_val: int = 0, max_val: Variant = null) -> int:
	if max_val == null:
		return clampi(int(sample() * float(MBIG)), 0, MBIG - 1)
	var max_i: int = int(max_val)
	if min_val >= max_i:
		return min_val
	var diff: int = max_i - min_val
	var val: int = int(sample() * float(diff)) + min_val
	return clampi(val, min_val, max_i - 1)


func randi_range(min_val: int, max_val: int) -> int:
	if min_val >= max_val:
		return min_val
	var diff: int = (max_val - min_val) + 1
	var val: int = int(sample() * float(diff)) + min_val
	return clampi(val, min_val, max_val)


func randf() -> float:
	return sample()


func randf_range(min_val: float, max_val: float) -> float:
	var diff: float = max_val - min_val
	return (sample() * diff) + min_val


func shuffle(items: Array) -> void:
	var n: int = items.size()
	for i in range(n - 1, 0, -1):
		var j: int = next(0, i + 1)
		var tmp = items[i]
		items[i] = items[j]
		items[j] = tmp
