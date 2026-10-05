class_name PrototypeBFlowService
extends RefCounted

const PROTOTYPE_B_SESSION := preload("res://scripts/domain/prototype_b/PrototypeBSession.gd")
const PROTOTYPE_B_COMPLETION_VALIDATOR := preload(
	"res://scripts/application/prototype_b/PrototypeBCompletionValidator.gd"
)
const PROTOTYPE_B_SUMMARY_SERVICE := preload(
	"res://scripts/application/prototype_b/PrototypeBSummaryService.gd"
)


func create_test_only_session(player_count: int) -> PROTOTYPE_B_SESSION:
	var session: PROTOTYPE_B_SESSION = PROTOTYPE_B_SESSION.new()
	session.session_id = StringName("m6_session_%d" % player_count)
	session.round_id = &"m6_round_test_only"
	var characters := Gd2FixtureRepository.load_selection_characters()
	for index: int in range(clampi(player_count, 1, 4)):
		var character: CharacterDefinition = characters[index]
		var player := PlayerPhaseState.new()
		player.player_id = StringName("m6_player_%d" % (index + 1))
		player.seat_index = index
		player.character_id = character.character_id
		player.round_id = session.round_id
		player.phase_id = &"READY_FOR_LOOT_M3"
		session.players.append(player)
		session.characters_by_id[String(character.character_id)] = character
	return session


func complete_test_only_flow(session: PROTOTYPE_B_SESSION) -> Dictionary:
	var allowed := session.action_allowed(&"FAST_COMPLETE_FLOW")
	if not bool(allowed.get("success", false)):
		return allowed
	_build_completed_movement(session)
	_build_completed_reward(session)
	_build_ready_management(session)
	session.status = PROTOTYPE_B_SESSION.Status.READY_FOR_SUMMARY
	return {"success": true, "code": "READY_FOR_SUMMARY"}


func enter_summary(session: PROTOTYPE_B_SESSION) -> Dictionary:
	if session.status != PROTOTYPE_B_SESSION.Status.READY_FOR_SUMMARY:
		return {"success": false, "code": "NOT_READY_FOR_SUMMARY"}
	var report = PROTOTYPE_B_COMPLETION_VALIDATOR.new().validate_completion_ready(session)
	if not report.passed():
		return {"success": false, "code": "COMPLETION_BLOCKED", "issues": report.issues}
	session.summary = PROTOTYPE_B_SUMMARY_SERVICE.new().build_session_summary(session)
	session.status = PROTOTYPE_B_SESSION.Status.PROTOTYPE_B_SUMMARY
	return {"success": true, "code": "PROTOTYPE_B_SUMMARY"}


func reject_gameplay_action(session: PROTOTYPE_B_SESSION, action_id: StringName) -> Dictionary:
	return session.action_allowed(action_id)


func _build_completed_movement(session: PROTOTYPE_B_SESSION) -> void:
	var movement := LootMovementSession.new()
	movement.round_id = session.round_id
	movement.started = true
	movement.completed = true
	movement.phase = LootMovementSession.Phase.LOOT_END_CONFIRMATION_READY
	for player: PlayerPhaseState in session.players:
		movement.ordered_player_ids.append(player.player_id)
		var character_value: Variant = session.characters_by_id.get(String(player.character_id))
		var character: CharacterDefinition = character_value as CharacterDefinition
		if character == null:
			continue
		var state := LootMovementPlayerState.new()
		state.player_id = player.player_id
		state.character_id = player.character_id
		state.origin_house_id = character.origin_house_id
		state.current_node_id = StringName("loot_end_%d" % (player.seat_index + 1))
		state.remaining_moves = 0
		state.stamina_snapshot = character.base_stamina
		state.speed_snapshot = character.base_speed
		var action := MovementActionResult.new()
		action.player_id = player.player_id
		action.start_node_id = StringName("spawn_%d" % (player.seat_index + 1))
		action.end_node_id = state.current_node_id
		action.traversed_node_ids = [state.current_node_id]
		action.roll_distance = 1
		action.movement_consumed = true
		action.remaining_moves_after = 0
		action.turn_number = player.seat_index + 1
		movement.player_states.append(state)
		movement.movement_history.append(action)
		player.phase_id = &"LOOT_END_CONFIRMATION"
	session.movement_session = movement


func _build_completed_reward(session: PROTOTYPE_B_SESSION) -> void:
	var reward := LootRewardSession.new()
	reward.round_id = session.round_id
	reward.map_id = &"loot_map_m3_test_only"
	reward.movement_session = session.movement_session
	reward.phase = LootRewardSession.Phase.LOOT_END_CONFIRMATION_READY
	for player: PlayerPhaseState in session.players:
		reward.players.append(player)
		reward.bag_capacity_by_player[String(player.player_id)] = 3
		reward.ensure_round_loot_state(player.player_id, 3)
		player.silver_coin_count += 10
		player.orb_count += 1
		player.gacha_ticket_count += 3
		player.equipment_exp_material_count += 25
		player.equipment_exchange_material_count += 2
		var row := RewardResolutionResult.new()
		row.player_id = player.player_id
		var movement_player: LootMovementPlayerState = _movement_player(
			session.movement_session, player.player_id
		)
		row.node_id = movement_player.current_node_id if movement_player != null else &""
		row.reward_id = &"m6_test_reward"
		row.reward_amount = 10
		row.resource_delta = {"silver_coin_count": 10}
		reward.reward_history.append(row)
	session.reward_session = reward


func _build_ready_management(session: PROTOTYPE_B_SESSION) -> void:
	var management := EquipmentManagementSession.new()
	management.round_id = session.round_id
	management.phase = EquipmentManagementSession.Phase.READY_FOR_M6
	for player: PlayerPhaseState in session.players:
		management.players.append(player)
		management.player_order.append(player.player_id)
		management.confirmed_player_ids.append(player.player_id)
		management.done_player_ids.append(player.player_id)
		var instance := EquipmentInstance.new()
		instance.instance_id = StringName("m6_relic_%d" % (player.seat_index + 1))
		instance.equipment_definition_id = &"m5_a_relic"
		instance.owner_player_id = player.player_id
		instance.acquired_source = &"M6_FAST_FIXTURE"
		instance.gold_star_level = 2
		instance.purple_star_level = 1
		player.equipment_collection.append(instance)
		player.relic_instance_id = instance.instance_id
		player.phase_id = &"READY_FOR_M6"
		player.gacha_state.consecutive_without_a_plus = player.seat_index
		player.gacha_state.rate_up_consecutive_without_a_plus = player.seat_index + 1
		player.gacha_state.perfect_pool_remaining_hits = {"regular_exp": 2}
		player.gacha_state.perfect_weight_config_id = &"m5_gacha_config_test_only"
		management.progression_history.append(
			{"code": "GOLD_UPGRADED", "player_id": String(player.player_id)}
		)
		management.progression_history.append(
			{"code": "PURPLE_STAT_MILESTONE", "player_id": String(player.player_id)}
		)
		management.gacha_history.append(
			{"banner_type": "BASIC", "player_id": String(player.player_id)}
		)
		management.gacha_history.append(
			{"banner_type": "RATE_UP", "player_id": String(player.player_id)}
		)
		management.gacha_history.append(
			{"banner_type": "PERFECT", "player_id": String(player.player_id)}
		)
	session.management_session = management


func _movement_player(
	session: LootMovementSession, player_id: StringName
) -> LootMovementPlayerState:
	if session == null:
		return null
	for player: LootMovementPlayerState in session.player_states:
		if player.player_id == player_id:
			return player
	return null
