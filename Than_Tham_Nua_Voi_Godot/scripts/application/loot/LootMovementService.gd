class_name LootMovementService
extends RefCounted


func build_session_from_selection(players: Array[PlayerPhaseState], characters: Array[CharacterDefinition], map_definition: LootMapDefinition, round_id: StringName = &"test_round_m3") -> LootMovementSession:
	var required_houses: Array[StringName] = []
	for player: PlayerPhaseState in players:
		var character: CharacterDefinition = _find_character(characters, player.character_id)
		if character != null and not required_houses.has(character.origin_house_id):
			required_houses.append(character.origin_house_id)
	var report: LootValidationReport = LootMovementMapValidator.new().validate(map_definition, required_houses)
	if not report.is_valid:
		return null
	var session := LootMovementSession.new()
	session.round_id = round_id
	for player: PlayerPhaseState in players:
		var character: CharacterDefinition = _find_character(characters, player.character_id)
		if character == null:
			return null
		var movement_player := LootMovementPlayerState.new()
		movement_player.player_id = player.player_id
		movement_player.character_id = player.character_id
		movement_player.origin_house_id = character.origin_house_id
		movement_player.current_node_id = StringName(map_definition.origin_spawn_by_house.get(character.origin_house_id, &""))
		movement_player.speed_snapshot = character.base_speed
		movement_player.stamina_snapshot = character.base_stamina
		movement_player.remaining_moves = character.base_stamina
		session.ordered_player_ids.append(player.player_id)
		session.player_states.append(movement_player)
	session.started = true
	if session.all_exhausted():
		_complete(session)
	return session


func get_available_branches(
	map_definition: LootMapDefinition, node_id: StringName
) -> Array[LootNodeDefinition]:
	var result: Array[LootNodeDefinition] = []
	if map_definition == null or node_id.is_empty():
		return result
	var node: LootNodeDefinition = map_definition.find_node(node_id)
	if node == null or node.outgoing_neighbor_ids.size() <= 1:
		return result
	for neighbor_id: StringName in node.outgoing_neighbor_ids:
		var neighbor: LootNodeDefinition = map_definition.find_node(neighbor_id)
		if neighbor != null:
			result.append(neighbor)
	return result


func roll_move(
	session: LootMovementSession,
	map_definition: LootMapDefinition,
	roll_source: MovementRollSource,
	temporary_effects: Array[TemporaryEffectState] = [],
	branch_choice: StringName = &"",
	interactive: bool = false
) -> MovementActionResult:
	if session == null or map_definition == null or roll_source == null or session.completed:
		return null
	if session.pending_branch != null and session.pending_branch.active:
		return null
	var player: LootMovementPlayerState = session.current_player()
	if player == null or player.remaining_moves <= 0:
		_advance_turn(session)
		return null
	var result := MovementActionResult.new()
	result.player_id = player.player_id
	var speed_bonus := 0
	var distance_bonus := 0
	for effect: TemporaryEffectState in temporary_effects:
		if not effect.active:
			continue
		if effect.effect_kind == &"SPEED_BONUS":
			speed_bonus += int(effect.magnitude)
		elif effect.effect_kind == &"MOVE_DISTANCE_BONUS":
			distance_bonus += int(effect.magnitude)
	result.roll_distance = (
		roll_source.roll_distance(maxi(1, player.speed_snapshot + speed_bonus))
		+ distance_bonus
	)
	result.start_node_id = player.current_node_id
	result.turn_number = session.turn_number
	var current_id := player.current_node_id
	var active_branch_choice := branch_choice
	for step: int in range(result.roll_distance):
		var node: LootNodeDefinition = map_definition.find_node(current_id)
		if node == null or node.outgoing_neighbor_ids.is_empty():
			result.truncated_by_end_of_path = true
			break
		if node.outgoing_neighbor_ids.size() == 1:
			current_id = node.outgoing_neighbor_ids[0]
			result.traversed_node_ids.append(current_id)
		else:
			# Fork encountered!
			if not active_branch_choice.is_empty() and node.outgoing_neighbor_ids.has(active_branch_choice):
				current_id = active_branch_choice
				active_branch_choice = &""
				result.traversed_node_ids.append(current_id)
			elif interactive:
				var remaining: int = result.roll_distance - step
				session.pending_branch.active = true
				session.pending_branch.player_id = player.player_id
				session.pending_branch.fork_node_id = current_id
				session.pending_branch.available_branch_ids = node.outgoing_neighbor_ids.duplicate()
				session.pending_branch.remaining_steps = remaining
				session.pending_branch.traversed_node_ids = result.traversed_node_ids.duplicate()
				session.pending_branch.roll_distance = result.roll_distance
				session.pending_branch.start_node_id = result.start_node_id
				return null
			else:
				current_id = node.outgoing_neighbor_ids[0]
				result.traversed_node_ids.append(current_id)
	_finalize_movement_success(session, player, current_id, result, temporary_effects)
	return result


func continue_branch_move(
	session: LootMovementSession,
	map_definition: LootMapDefinition,
	chosen_branch_id: StringName,
	temporary_effects: Array[TemporaryEffectState] = []
) -> MovementActionResult:
	if (
		session == null
		or session.pending_branch == null
		or not session.pending_branch.active
		or map_definition == null
	):
		return null
	if not session.pending_branch.available_branch_ids.has(chosen_branch_id):
		return null
	var player: LootMovementPlayerState = session.current_player()
	if player == null or player.player_id != session.pending_branch.player_id:
		return null
	var result := MovementActionResult.new()
	result.player_id = session.pending_branch.player_id
	result.roll_distance = session.pending_branch.roll_distance
	result.start_node_id = session.pending_branch.start_node_id
	result.turn_number = session.turn_number
	result.traversed_node_ids = session.pending_branch.traversed_node_ids.duplicate()
	var current_id := chosen_branch_id
	result.traversed_node_ids.append(current_id)
	var remaining: int = session.pending_branch.remaining_steps - 1
	for _step: int in range(remaining):
		var node: LootNodeDefinition = map_definition.find_node(current_id)
		if node == null or node.outgoing_neighbor_ids.is_empty():
			result.truncated_by_end_of_path = true
			break
		if node.outgoing_neighbor_ids.size() == 1:
			current_id = node.outgoing_neighbor_ids[0]
			result.traversed_node_ids.append(current_id)
		else:
			current_id = node.outgoing_neighbor_ids[0]
			result.traversed_node_ids.append(current_id)
	session.pending_branch = PendingBranchState.new()
	_finalize_movement_success(session, player, current_id, result, temporary_effects)
	return result


func _finalize_movement_success(
	session: LootMovementSession,
	player: LootMovementPlayerState,
	end_node_id: StringName,
	result: MovementActionResult,
	temporary_effects: Array[TemporaryEffectState]
) -> void:
	player.current_node_id = end_node_id
	player.remaining_moves = maxi(0, player.remaining_moves - 1)
	result.end_node_id = end_node_id
	result.remaining_moves_after = player.remaining_moves
	result.movement_consumed = true
	session.movement_history.append(result)
	session.turn_number += 1
	for effect: TemporaryEffectState in temporary_effects:
		if effect.active and effect.duration == TemporaryEffectState.Duration.THIS_MOVE:
			effect.active = false
			effect.remaining = 0
	_advance_turn(session)


func _advance_turn(session: LootMovementSession) -> void:
	if session.all_exhausted():
		_complete(session)
		return
	var count := session.player_states.size()
	for offset: int in range(1, count + 1):
		var candidate := (session.current_turn_index + offset) % count
		if session.player_states[candidate].remaining_moves > 0:
			session.current_turn_index = candidate
			return


func advance_without_movement(session: LootMovementSession) -> void:
	if session != null and not session.completed:
		_advance_turn(session)


func _complete(session: LootMovementSession) -> void:
	session.phase = LootMovementSession.Phase.LOOT_END_CONFIRMATION_READY
	session.completed = true


func _find_character(characters: Array[CharacterDefinition], character_id: StringName) -> CharacterDefinition:
	for character: CharacterDefinition in characters:
		if character.character_id == character_id:
			return character
	return null
