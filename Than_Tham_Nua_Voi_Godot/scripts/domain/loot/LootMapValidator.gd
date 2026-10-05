class_name LootMapValidator
extends RefCounted

func validate(map_definition: LootMapDefinition, required_house_ids: Array[StringName] = []) -> LootValidationReport:
	var report := LootValidationReport.new()
	if map_definition == null:
		report.add_error(&"LOOT_MAP_NULL", "Map definition is required")
		return report
	if map_definition.map_id.is_empty(): report.add_error(&"LOOT_MAP_ID_EMPTY", "map_id is required")
	var by_id: Dictionary = {}
	for node in map_definition.nodes:
		if node == null or node.node_id.is_empty(): report.add_error(&"NODE_ID_EMPTY", "Every node needs node_id"); continue
		if by_id.has(node.node_id): report.add_error(&"DUPLICATE_NODE_ID", "Duplicate node ID", String(node.node_id)); continue
		by_id[node.node_id] = node
	for node in map_definition.nodes:
		if node == null: continue
		for neighbor_id in node.outgoing_neighbor_ids:
			if neighbor_id == node.node_id: report.add_error(&"SELF_REFERENCE_INVALID", "Self edge is not allowed", String(node.node_id))
			elif not by_id.has(neighbor_id): report.add_error(&"DANGLING_EDGE", "Outgoing neighbor does not exist", "%s → %s" % [node.node_id, neighbor_id])
	for house_id in required_house_ids:
		if not map_definition.origin_spawn_by_house.has(house_id): report.add_error(&"ORIGIN_SPAWN_MISSING", "House has no spawn mapping", String(house_id)); continue
		var spawn_value: Variant = map_definition.origin_spawn_by_house.get(house_id, &"")
		var spawn_id: StringName = StringName(spawn_value)
		if not by_id.has(spawn_id): report.add_error(&"SPAWN_NODE_MISSING", "Spawn mapping points to missing node", String(spawn_id))
	if not map_definition.nodes.is_empty() and not by_id.is_empty():
		var first_key: Variant = by_id.keys()[0]
		var reachable: Dictionary = _reachable_from(StringName(first_key), by_id)
		for node_id in by_id:
			if not reachable.has(node_id): report.add_warning(&"NODE_NOT_STRUCTURALLY_REACHABLE", "Node not reachable from structural probe", String(node_id))
	return report

func _reachable_from(start_id: StringName, by_id: Dictionary) -> Dictionary:
	var visited: Dictionary = {}; var queue: Array[StringName] = [start_id]
	while not queue.is_empty():
		var current: StringName = queue.pop_front()
		if visited.has(current): continue
		visited[current] = true
		var node_value: Variant = by_id.get(current)
		var node: LootNodeDefinition = node_value as LootNodeDefinition
		for neighbor in node.outgoing_neighbor_ids:
			if by_id.has(neighbor) and not visited.has(neighbor): queue.append(neighbor)
	return visited
