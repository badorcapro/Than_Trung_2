class_name LootMovementMapValidator
extends RefCounted


func validate(map_definition: LootMapDefinition, required_house_ids: Array[StringName]) -> LootValidationReport:
	var report: LootValidationReport = LootMapValidator.new().validate(map_definition, required_house_ids)
	if map_definition == null:
		return report
	var central_hub: LootNodeDefinition = _find_tagged_node(map_definition, &"CENTRAL_HUB")
	if central_hub != null:
		_validate_branched_house_routes(map_definition, required_house_ids, central_hub, report)
		return report

	# Compatibility validation for the earlier linear prototype map shape.
	var expected_steps := -1
	for house_id: StringName in required_house_ids:
		var spawn_value: Variant = map_definition.origin_spawn_by_house.get(house_id, &"")
		var spawn_id := StringName(spawn_value)
		var spawn: LootNodeDefinition = map_definition.find_node(spawn_id)
		if spawn == null:
			continue
		if spawn.origin_house_id != house_id:
			report.add_error(&"SPAWN_ORIGIN_MISMATCH", "Spawn origin metadata does not match mapping", String(house_id))
		var steps := _steps_to_center(map_definition, spawn_id, house_id, report)
		if steps < 0:
			report.add_error(&"CENTER_ENTRY_UNREACHABLE", "Origin route cannot reach CENTER_ENTRY", String(house_id))
		elif expected_steps < 0:
			expected_steps = steps
		elif steps != expected_steps:
			report.add_error(&"PALACE_PATH_LENGTH_MISMATCH", "Palace routes must have equal steps to center entry", String(house_id))
	for node: LootNodeDefinition in map_definition.nodes:
		if node == null:
			continue
		if (&"SHARED" in node.tags or &"CENTER_ENTRY" in node.tags) and node.outgoing_neighbor_ids.size() > 1:
			report.add_error(&"SHARED_ROUTE_BRANCH_INVALID", "Base shared route must be non-branching", String(node.node_id))
	return report


func _validate_branched_house_routes(
	map_definition: LootMapDefinition,
	required_house_ids: Array[StringName],
	central_hub: LootNodeDefinition,
	report: LootValidationReport
) -> void:
	var expected_steps := -1
	for house_id: StringName in required_house_ids:
		var spawn_id := StringName(map_definition.origin_spawn_by_house.get(house_id, &""))
		var spawn: LootNodeDefinition = map_definition.find_node(spawn_id)
		if spawn == null:
			continue
		if spawn.origin_house_id != house_id:
			report.add_error(
				&"SPAWN_ORIGIN_MISMATCH",
				"Spawn origin metadata does not match mapping",
				String(house_id)
			)
		if spawn.outgoing_neighbor_ids.size() != 2:
			report.add_error(
				&"HOUSE_SPAWN_BRANCH_COUNT_INVALID",
				"Each production House spawn must expose exactly two lanes",
				String(spawn_id)
			)
			continue
		var first_lane_nodes: Dictionary = {}
		for lane_index: int in range(spawn.outgoing_neighbor_ids.size()):
			var lane_result: Dictionary = _trace_house_lane(
				map_definition,
				spawn.outgoing_neighbor_ids[lane_index],
				central_hub.node_id,
				house_id,
				report
			)
			var steps: int = int(lane_result.get("steps", -1))
			if steps < 0:
				report.add_error(
					&"CENTRAL_HUB_UNREACHABLE",
					"House lane cannot reach the shared Central Hub",
					"%s lane %d" % [house_id, lane_index + 1]
				)
				continue
			if expected_steps < 0:
				expected_steps = steps
			elif steps != expected_steps:
				report.add_error(
					&"HOUSE_ROUTE_LENGTH_MISMATCH",
					"All House lanes must have equal steps to the Central Hub",
					"%s lane %d" % [house_id, lane_index + 1]
				)
			var lane_nodes_value: Variant = lane_result.get("nodes", {})
			if not lane_nodes_value is Dictionary:
				continue
			var lane_nodes: Dictionary = lane_nodes_value
			if lane_index == 0:
				first_lane_nodes = lane_nodes
			else:
				for node_id: Variant in lane_nodes:
					if first_lane_nodes.has(node_id):
						report.add_error(
							&"HOUSE_LANES_MERGE_BEFORE_HUB",
							"Sibling House lanes may only meet at the Central Hub",
							String(node_id)
						)


func _trace_house_lane(
	map_definition: LootMapDefinition,
	start_id: StringName,
	central_hub_id: StringName,
	house_id: StringName,
	report: LootValidationReport
) -> Dictionary:
	var current_id := start_id
	var visited: Dictionary = {}
	var steps := 1
	while not current_id.is_empty() and not visited.has(current_id):
		if current_id == central_hub_id:
			return {"steps": steps, "nodes": visited}
		visited[current_id] = true
		var node: LootNodeDefinition = map_definition.find_node(current_id)
		if node == null:
			return {"steps": -1, "nodes": visited}
		if node.origin_house_id != house_id:
			report.add_error(
				&"HOUSE_ROUTE_MERGES_BEFORE_HUB",
				"House lane enters shared or foreign route before the Central Hub",
				String(node.node_id)
			)
			return {"steps": -1, "nodes": visited}
		if node.outgoing_neighbor_ids.size() != 1:
			return {"steps": -1, "nodes": visited}
		current_id = node.outgoing_neighbor_ids[0]
		steps += 1
	return {"steps": -1, "nodes": visited}


func _find_tagged_node(
	map_definition: LootMapDefinition, tag: StringName
) -> LootNodeDefinition:
	for node: LootNodeDefinition in map_definition.nodes:
		if node != null and tag in node.tags:
			return node
	return null


func _steps_to_center(map_definition: LootMapDefinition, start_id: StringName, house_id: StringName, report: LootValidationReport) -> int:
	var current_id := start_id
	var visited: Dictionary = {}
	var steps := 0
	while not current_id.is_empty() and not visited.has(current_id):
		visited[current_id] = true
		var node: LootNodeDefinition = map_definition.find_node(current_id)
		if node == null:
			return -1
		if &"CENTER_ENTRY" in node.tags:
			return steps
		if not node.origin_house_id.is_empty() and node.origin_house_id != house_id:
			report.add_error(&"CROSS_PALACE_EDGE_INVALID", "Base palace route crosses another origin lane", String(node.node_id))
			return -1
		if node.outgoing_neighbor_ids.size() != 1:
			return -1
		current_id = node.outgoing_neighbor_ids[0]
		steps += 1
	return -1
