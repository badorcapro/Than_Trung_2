class_name CaseSpatialService
extends RefCounted

const BOARD_ROWS := 3
const BOARD_COLUMNS := 3
const BOARD_SLOT_COUNT := BOARD_ROWS * BOARD_COLUMNS
const DIRECTION_NORTH: StringName = &"north"
const DIRECTION_EAST: StringName = &"east"
const DIRECTION_SOUTH: StringName = &"south"
const DIRECTION_WEST: StringName = &"west"
const BLOOD_HOUND_BARK: StringName = &"bark"
const BLOOD_HOUND_SNIFF: StringName = &"sniff"


func is_valid_slot(slot: int) -> bool:
	return slot >= 0 and slot < BOARD_SLOT_COUNT


func slot_to_row(slot: int) -> int:
	if not is_valid_slot(slot):
		return -1
	return int(slot / BOARD_COLUMNS)


func slot_to_column(slot: int) -> int:
	if not is_valid_slot(slot):
		return -1
	return slot % BOARD_COLUMNS


func slot_to_row_column(slot: int) -> Vector2i:
	return Vector2i(slot_to_row(slot), slot_to_column(slot))


func are_orthogonally_adjacent(from_slot: int, to_slot: int) -> bool:
	return orthogonal_step_distance(from_slot, to_slot) == 1


func are_surrounding_neighbours(from_slot: int, to_slot: int) -> bool:
	if not is_valid_slot(from_slot) or not is_valid_slot(to_slot) or from_slot == to_slot:
		return false
	var row_delta: int = absi(slot_to_row(from_slot) - slot_to_row(to_slot))
	var column_delta: int = absi(slot_to_column(from_slot) - slot_to_column(to_slot))
	return row_delta <= 1 and column_delta <= 1


func are_surrounding_neighbours_for_case(case_definition: CaseDefinition, from_slot: int, to_slot: int) -> bool:
	var columns: int = _board_columns_for_case(case_definition)
	var slot_count: int = _board_slot_count_for_case(case_definition)
	if columns <= 0 or from_slot < 0 or to_slot < 0 or from_slot >= slot_count or to_slot >= slot_count or from_slot == to_slot:
		return false
	var row_delta: int = absi(int(from_slot / columns) - int(to_slot / columns))
	var column_delta: int = absi(from_slot % columns - to_slot % columns)
	return row_delta <= 1 and column_delta <= 1


func orthogonal_step_distance(from_slot: int, to_slot: int) -> int:
	if not is_valid_slot(from_slot) or not is_valid_slot(to_slot):
		return -1
	var row_delta: int = absi(slot_to_row(from_slot) - slot_to_row(to_slot))
	var column_delta: int = absi(slot_to_column(from_slot) - slot_to_column(to_slot))
	return row_delta + column_delta


func orthogonal_neighbour_slots(slot: int) -> PackedInt32Array:
	var slots: PackedInt32Array = PackedInt32Array()
	if not is_valid_slot(slot):
		return slots
	var row: int = slot_to_row(slot)
	var column: int = slot_to_column(slot)
	_append_slot_if_valid(slots, row - 1, column)
	_append_slot_if_valid(slots, row, column - 1)
	_append_slot_if_valid(slots, row, column + 1)
	_append_slot_if_valid(slots, row + 1, column)
	return slots


func orthogonal_neighbour_slots_for_case(case_definition: CaseDefinition, slot: int) -> PackedInt32Array:
	var slots: PackedInt32Array = PackedInt32Array()
	var columns: int = _board_columns_for_case(case_definition)
	var slot_count: int = _board_slot_count_for_case(case_definition)
	if columns <= 0 or slot < 0 or slot >= slot_count:
		return slots
	var row: int = int(slot / columns)
	var column: int = slot % columns
	if row > 0:
		slots.append(slot - columns)
	if column > 0:
		slots.append(slot - 1)
	if column + 1 < columns and slot + 1 < slot_count:
		slots.append(slot + 1)
	if slot + columns < slot_count:
		slots.append(slot + columns)
	return slots


func surrounding_neighbour_slots(slot: int) -> PackedInt32Array:
	var slots: PackedInt32Array = PackedInt32Array()
	if not is_valid_slot(slot):
		return slots
	var source_row: int = slot_to_row(slot)
	var source_column: int = slot_to_column(slot)
	for row in range(source_row - 1, source_row + 2):
		for column in range(source_column - 1, source_column + 2):
			if row == source_row and column == source_column:
				continue
			_append_slot_if_valid(slots, row, column)
	return slots


func cardinal_direction_slots(from_slot: int, direction: StringName) -> PackedInt32Array:
	var slots: PackedInt32Array = PackedInt32Array()
	if not is_valid_slot(from_slot):
		return slots
	var row: int = slot_to_row(from_slot)
	var column: int = slot_to_column(from_slot)
	match direction:
		DIRECTION_NORTH:
			for target_row: int in range(row - 1, -1, -1):
				_append_slot_if_valid(slots, target_row, column)
		DIRECTION_EAST:
			for target_column: int in range(column + 1, BOARD_COLUMNS):
				_append_slot_if_valid(slots, row, target_column)
		DIRECTION_SOUTH:
			for target_row: int in range(row + 1, BOARD_ROWS):
				_append_slot_if_valid(slots, target_row, column)
		DIRECTION_WEST:
			for target_column: int in range(column - 1, -1, -1):
				_append_slot_if_valid(slots, row, target_column)
	return slots


func suspects_in_cardinal_direction(case_definition: CaseDefinition, source_suspect_id: int, direction: StringName) -> Array[SuspectDefinition]:
	var suspects: Array[SuspectDefinition] = []
	var source: SuspectDefinition = _find_suspect(case_definition, source_suspect_id)
	if source == null:
		return suspects
	var slots: PackedInt32Array = cardinal_direction_slots(source.board_slot, direction)
	for slot: int in slots:
		var suspect: SuspectDefinition = _find_suspect_by_slot(case_definition, slot)
		if suspect != null:
			suspects.append(suspect)
	return suspects


func blood_hound_truthful_outcome(case_definition: CaseDefinition, source_suspect_id: int) -> Dictionary:
	var source: SuspectDefinition = _find_suspect(case_definition, source_suspect_id)
	if source == null:
		return _blood_hound_result(false, BLOOD_HOUND_SNIFF, -1, 0)
	var directions: Array[StringName] = [
		DIRECTION_NORTH,
		DIRECTION_EAST,
		DIRECTION_SOUTH,
		DIRECTION_WEST,
	]
	var best_distance: int = -1
	var best_outcome: StringName = &""
	var best_count: int = 0
	for direction: StringName in directions:
		var suspects: Array[SuspectDefinition] = suspects_in_cardinal_direction(case_definition, source_suspect_id, direction)
		for suspect: SuspectDefinition in suspects:
			if suspect == null or suspect.true_alignment != CaseEnums.Alignment.EVIL:
				continue
			var distance: int = orthogonal_step_distance(source.board_slot, suspect.board_slot)
			if distance < 0:
				continue
			if best_distance < 0 or distance < best_distance:
				best_distance = distance
				best_outcome = direction
				best_count = 1
			elif distance == best_distance:
				best_count += 1
	if best_distance < 0:
		return _blood_hound_result(false, BLOOD_HOUND_SNIFF, -1, 0)
	if best_count > 1:
		return _blood_hound_result(true, BLOOD_HOUND_BARK, best_distance, best_count)
	return _blood_hound_result(true, best_outcome, best_distance, best_count)


func suspects_orthogonally_adjacent_to(case_definition: CaseDefinition, source_suspect_id: int) -> Array[SuspectDefinition]:
	return _suspects_near_source(case_definition, source_suspect_id, true)


func suspects_surrounding_source(case_definition: CaseDefinition, source_suspect_id: int) -> Array[SuspectDefinition]:
	return _suspects_near_source(case_definition, source_suspect_id, false)


func count_adjacent_true_evil(case_definition: CaseDefinition, source_suspect_id: int) -> int:
	var count: int = 0
	for suspect in suspects_orthogonally_adjacent_to(case_definition, source_suspect_id):
		if suspect.true_alignment == CaseEnums.Alignment.EVIL:
			count += 1
	return count


func nearest_true_evil_distance(case_definition: CaseDefinition, source_suspect_id: int) -> Dictionary:
	var source: SuspectDefinition = _find_suspect(case_definition, source_suspect_id)
	if source == null:
		return _nearest_result(false, -1, PackedInt32Array())

	var nearest_distance: int = -1
	var suspect_ids: PackedInt32Array = PackedInt32Array()
	for suspect in case_definition.suspects:
		if suspect == null or suspect.suspect_id == source_suspect_id:
			continue
		if suspect.true_alignment != CaseEnums.Alignment.EVIL:
			continue
		var distance: int = _orthogonal_step_distance_for_case(case_definition, source.board_slot, suspect.board_slot)
		if distance < 0:
			continue
		if nearest_distance < 0 or distance < nearest_distance:
			nearest_distance = distance
			suspect_ids = PackedInt32Array([suspect.suspect_id])
		elif distance == nearest_distance:
			suspect_ids.append(suspect.suspect_id)
	suspect_ids.sort()
	return _nearest_result(nearest_distance >= 0, nearest_distance, suspect_ids)


func _orthogonal_step_distance_for_case(case_definition: CaseDefinition, from_slot: int, to_slot: int) -> int:
	var columns: int = _board_columns_for_case(case_definition)
	var slot_count: int = _board_slot_count_for_case(case_definition)
	if columns <= 0 or from_slot < 0 or to_slot < 0 or from_slot >= slot_count or to_slot >= slot_count:
		return -1
	var from_row: int = int(from_slot / columns)
	var from_column: int = from_slot % columns
	var to_row: int = int(to_slot / columns)
	var to_column: int = to_slot % columns
	return absi(from_row - to_row) + absi(from_column - to_column)


func _board_columns_for_case(case_definition: CaseDefinition) -> int:
	if case_definition != null and case_definition.has_meta(&"board_columns"):
		return int(case_definition.get_meta(&"board_columns"))
	return BOARD_COLUMNS


func _board_slot_count_for_case(case_definition: CaseDefinition) -> int:
	if case_definition != null and case_definition.has_meta(&"board_slot_count"):
		return int(case_definition.get_meta(&"board_slot_count"))
	return BOARD_SLOT_COUNT


func _suspects_near_source(case_definition: CaseDefinition, source_suspect_id: int, orthogonal_only: bool) -> Array[SuspectDefinition]:
	var suspects: Array[SuspectDefinition] = []
	var source: SuspectDefinition = _find_suspect(case_definition, source_suspect_id)
	if source == null:
		return suspects
	for suspect in case_definition.suspects:
		if suspect == null or suspect.suspect_id == source_suspect_id:
			continue
		var is_neighbour: bool = are_surrounding_neighbours(source.board_slot, suspect.board_slot)
		if orthogonal_only:
			is_neighbour = _orthogonal_step_distance_for_case(case_definition, source.board_slot, suspect.board_slot) == 1
		if is_neighbour:
			suspects.append(suspect)
	return suspects


func _find_suspect(case_definition: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	if case_definition == null:
		return null
	for suspect in case_definition.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null


func _find_suspect_by_slot(case_definition: CaseDefinition, board_slot: int) -> SuspectDefinition:
	if case_definition == null:
		return null
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect != null and suspect.board_slot == board_slot:
			return suspect
	return null


func _append_slot_if_valid(slots: PackedInt32Array, row: int, column: int) -> void:
	if row < 0 or row >= BOARD_ROWS or column < 0 or column >= BOARD_COLUMNS:
		return
	slots.append(row * BOARD_COLUMNS + column)


func _nearest_result(found: bool, distance: int, suspect_ids: PackedInt32Array) -> Dictionary:
	return {
		"found": found,
		"distance": distance,
		"suspect_ids": suspect_ids,
	}


func _blood_hound_result(found: bool, outcome: StringName, distance: int, match_count: int) -> Dictionary:
	return {
		"found": found,
		"outcome": outcome,
		"distance": distance,
		"match_count": match_count,
	}
