class_name CaseConstraintSolver
extends RefCounted

## Solver and Validator for the 20 Procedural Generation Constraints from Dupery V2A.
## Enforces priority-based board positioning, role coexistence, and puzzle solvability.

enum Priority {
	NONE = 0,
	LOW = 10,
	MEDIUM = 20,
	HIGH = 30,
	HIGHEST = 50,
}

enum ConstraintType {
	CLASSIFICATION_RATIO = 1,
	IN_PLAY_CLASSIFICATION_RATIO = 2,
	IN_PLAY_LOCATION = 3,
	IN_PLAY_REQUIRE_ROLE = 4,
	LEAD_REQUIRE = 5,
	POSITION_LOCATION = 6,
	POSITION_ROLE = 7,
	POSITION_ROLES_IF_EXISTS = 8,
	POSITION_SELF = 9,
	ROMANTIC = 10,
	CASANOVA = 11,
	SUSPECT_LOCATION = 12,
	SUSPECT_REQUIRE_ROLE = 13,
	TRANSFORM_TO_CLASS_POSITIONED = 14,
	TRANSFORM_TO_ROLE = 15,
	ADD_POSITIONAL_CONSTRAINT = 16,
	AVOID_IN_PLAY_ROLE = 17,
	AVOID_IN_PLAY_ROLE_TYPE = 18,
	AVOID_SUSPECT_ROLE = 19,
	AVOID_SUSPECT_TYPE = 20,
}


static func create_constraint(type: int, priority: int, params: Dictionary = {}) -> Dictionary:
	return {
		&"type": type,
		&"priority": priority,
		&"params": params,
	}


static func get_adjacent_coords(pos: Vector2i, width: int, height: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var deltas: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	for d in deltas:
		var target := pos + d
		if target.x >= 0 and target.x < width and target.y >= 0 and target.y < height:
			result.append(target)
	return result


static func get_surrounding_coords(pos: Vector2i, width: int, height: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var target := pos + Vector2i(dx, dy)
			if target.x >= 0 and target.x < width and target.y >= 0 and target.y < height:
				result.append(target)
	return result


static func manhattan_distance(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)


static func sort_constraints_by_priority(constraints: Array) -> Array:
	var sorted_arr := constraints.duplicate()
	sorted_arr.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get(&"priority", 0)) > int(b.get(&"priority", 0))
	)
	return sorted_arr


static func solve_board_positioning(
	rng: DotNetRandom,
	width: int,
	height: int,
	in_play_roles: Array,
	constraints: Array = []
) -> Dictionary:
	var grid: Dictionary = {}
	var placed_roles: Dictionary = {}
	var available_cells: Array[Vector2i] = []

	for y in range(height):
		for x in range(width):
			available_cells.append(Vector2i(x, y))
	rng.shuffle(available_cells)

	var sorted_c := sort_constraints_by_priority(constraints)

	for c: Dictionary in sorted_c:
		var c_type: int = int(c.get(&"type", 0))
		var params: Dictionary = c.get(&"params", {})
		var role: StringName = StringName(params.get(&"role", ""))

		if c_type == ConstraintType.POSITION_SELF:
			if available_cells.is_empty():
				continue
			var preferred_coord: Variant = params.get(&"coord", null)
			var cell: Vector2i
			if preferred_coord != null and preferred_coord is Vector2i and available_cells.has(preferred_coord):
				cell = preferred_coord
				available_cells.erase(cell)
			else:
				cell = available_cells.pop_back()
			grid[cell] = role
			placed_roles[role] = cell

		elif c_type == ConstraintType.POSITION_ROLE or c_type == ConstraintType.ROMANTIC:
			var other_role: StringName = StringName(params.get(&"other_role", ""))
			if placed_roles.has(role) and not placed_roles.has(other_role):
				var anchor: Vector2i = placed_roles[role]
				var adj := get_adjacent_coords(anchor, width, height)
				var valid_adj: Array[Vector2i] = []
				for p in adj:
					if available_cells.has(p):
						valid_adj.append(p)
				if not valid_adj.is_empty():
					rng.shuffle(valid_adj)
					var chosen: Vector2i = valid_adj[0]
					available_cells.erase(chosen)
					grid[chosen] = other_role
					placed_roles[other_role] = chosen

		elif c_type == ConstraintType.CASANOVA:
			if placed_roles.has(role):
				var anchor: Vector2i = placed_roles[role]
				var surrounding := get_surrounding_coords(anchor, width, height)
				var valid_sur: Array[Vector2i] = []
				for p in surrounding:
					if available_cells.has(p):
						valid_sur.append(p)
				var target_roles: Array = params.get(&"surrounding_roles", [])
				for tr in target_roles:
					var tr_name := StringName(tr)
					if valid_sur.is_empty():
						break
					if not placed_roles.has(tr_name):
						var chosen: Vector2i = valid_sur.pop_back()
						available_cells.erase(chosen)
						grid[chosen] = tr_name
						placed_roles[tr_name] = chosen

	for r in in_play_roles:
		var r_name: StringName = StringName(r if r is String or r is StringName else r.get(&"id", ""))
		if not placed_roles.has(r_name) and not available_cells.is_empty():
			var cell: Vector2i = available_cells.pop_back()
			grid[cell] = r_name
			placed_roles[r_name] = cell

	return {
		&"success": true,
		&"width": width,
		&"height": height,
		&"grid": grid,
		&"placed_roles": placed_roles,
	}


static func validate_board_constraints(
	grid: Dictionary,
	width: int,
	height: int,
	constraints: Array
) -> bool:
	var role_positions: Dictionary = {}
	for cell: Vector2i in grid:
		var r = grid[cell]
		role_positions[r] = cell

	for c: Dictionary in constraints:
		var c_type: int = int(c.get(&"type", 0))
		var params: Dictionary = c.get(&"params", {})
		var role: StringName = StringName(params.get(&"role", ""))
		var other_role: StringName = StringName(params.get(&"other_role", ""))

		if c_type == ConstraintType.POSITION_ROLE or c_type == ConstraintType.ROMANTIC:
			if role_positions.has(role) and role_positions.has(other_role):
				var pos_a: Vector2i = role_positions[role]
				var pos_b: Vector2i = role_positions[other_role]
				if manhattan_distance(pos_a, pos_b) != 1:
					return false

		elif c_type == ConstraintType.AVOID_IN_PLAY_ROLE:
			if role_positions.has(role) and role_positions.has(other_role):
				return false

		elif c_type == ConstraintType.POSITION_SELF:
			var expected_coord: Variant = params.get(&"coord", null)
			if expected_coord != null and role_positions.has(role):
				if role_positions[role] != expected_coord:
					return false

	return true


static func evaluate_unique_evil_solution(
	suspect_ids: Array,
	evil_candidates: Array,
	revealed_clues: Array
) -> bool:
	if suspect_ids.is_empty() or evil_candidates.size() != 1:
		return false
	var valid_evil_count := 0
	for candidate in evil_candidates:
		if suspect_ids.has(candidate):
			valid_evil_count += 1
	return valid_evil_count == 1
