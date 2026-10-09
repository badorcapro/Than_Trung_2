class_name LootRewardService
extends RefCounted

var movement_service := LootMovementService.new()
var item_service := ConsumableItemService.new()

func build_session(
	players: Array[PlayerPhaseState],
	characters: Array[CharacterDefinition],
	map_definition: LootMapDefinition,
	rewards: Array[RewardDefinition],
	reward_rng: RewardRollSource,
	round_id: StringName = &"test_round_m4",
	zone_tables: Array[RewardZoneTableDefinition] = []
) -> LootRewardSession:
	var movement: LootMovementSession = movement_service.build_session_from_selection(players, characters, map_definition, round_id)
	if movement == null: return null
	var session := LootRewardSession.new()
	session.round_id = round_id; session.map_id = map_definition.map_id; session.movement_session = movement
	for player: PlayerPhaseState in players:
		var copy := PlayerPhaseState.from_persistent_dict(player.to_persistent_dict())
		session.players.append(copy)
		var character: CharacterDefinition = _find_character(characters, player.character_id)
		session.bag_capacity_by_player[String(player.player_id)] = character.base_bag_level
		session.ensure_round_loot_state(player.player_id, character.base_bag_level)
	var snapshot_service := RewardSnapshotService.new()
	if zone_tables.is_empty():
		session.reward_snapshots = snapshot_service.build_reward_snapshot(
			round_id, map_definition, rewards, reward_rng
		)
	else:
		session.reward_snapshots = snapshot_service.build_weighted_reward_snapshot(
			round_id, map_definition, rewards, zone_tables, reward_rng
		)
	return session

func continue_without_item(session: LootRewardSession) -> bool:
	if session == null or session.phase != LootRewardSession.Phase.ITEM_WINDOW: return false
	var movement_player: LootMovementPlayerState = session.movement_session.current_player()
	if movement_player.remaining_moves > 0:
		session.phase = LootRewardSession.Phase.MOVEMENT
	else:
		movement_service.advance_without_movement(session.movement_session)
		_finish_personal_turn(session)
	return true

func use_item(
	session: LootRewardSession,
	item_id: StringName,
	definitions: Array[ConsumableItemDefinition],
	source: StringName = ConsumableItemService.SOURCE_PERSISTENT
) -> ItemUseResult:
	var movement_player: LootMovementPlayerState = session.movement_session.current_player() if session != null and session.movement_session != null else null
	if movement_player == null:
		var failed := ItemUseResult.new(); failed.code = &"CURRENT_PLAYER_MISSING"; return failed
	var result: ItemUseResult = item_service.use_item(
		session, movement_player.player_id, item_id, definitions, source
	)
	return result

func perform_movement(
	session: LootRewardSession,
	map_definition: LootMapDefinition,
	movement_rng: MovementRollSource,
	rewards: Array[RewardDefinition],
	branch_choice: StringName = &"",
	interactive: bool = false
) -> MovementActionResult:
	if session == null or session.phase != LootRewardSession.Phase.MOVEMENT:
		return null
	var before_player: LootMovementPlayerState = session.movement_session.current_player()
	if before_player == null:
		return null
	var action: MovementActionResult = movement_service.roll_move(
		session.movement_session,
		map_definition,
		movement_rng,
		before_player.temporary_effects,
		branch_choice,
		interactive
	)
	if session.movement_session.pending_branch != null and session.movement_session.pending_branch.active:
		session.phase = LootRewardSession.Phase.BRANCH_SELECTION
		return null
	if action == null:
		return null
	session.pending_trace = action.traversed_node_ids.duplicate()
	session.pending_trace_index = 0
	session.phase = LootRewardSession.Phase.REWARD_RESOLUTION
	_resolve_pending(session, rewards)
	return action


func choose_branch(
	session: LootRewardSession,
	map_definition: LootMapDefinition,
	chosen_branch_id: StringName,
	rewards: Array[RewardDefinition]
) -> MovementActionResult:
	if session == null or session.phase != LootRewardSession.Phase.BRANCH_SELECTION:
		return null
	if (
		session.movement_session == null
		or session.movement_session.pending_branch == null
		or not session.movement_session.pending_branch.active
	):
		return null
	var player: LootMovementPlayerState = session.movement_session.current_player()
	if player == null:
		return null
	var action: MovementActionResult = movement_service.continue_branch_move(
		session.movement_session,
		map_definition,
		chosen_branch_id,
		player.temporary_effects
	)
	if action == null:
		return null
	session.pending_trace = action.traversed_node_ids.duplicate()
	session.pending_trace_index = 0
	session.phase = LootRewardSession.Phase.REWARD_RESOLUTION
	_resolve_pending(session, rewards)
	return action

func resolve_trace(session: LootRewardSession, player_id: StringName, trace: Array[StringName], rewards: Array[RewardDefinition]) -> bool:
	if session == null or session.phase == LootRewardSession.Phase.BAG_OVERFLOW_PENDING: return false
	var marker := MovementActionResult.new(); marker.player_id = player_id
	session.movement_session.movement_history.append(marker)
	session.pending_trace = trace.duplicate(); session.pending_trace_index = 0; session.phase = LootRewardSession.Phase.REWARD_RESOLUTION
	_resolve_pending(session, rewards)
	return true

func resolve_overflow_discard(session: LootRewardSession, inventory_index: int, rewards: Array[RewardDefinition]) -> bool:
	if not _overflow_resolution_context_is_valid(session, rewards): return false
	var round_loot: RoundLootInventoryState = session.find_round_loot_state(
		session.overflow.player_id
	)
	if (
		round_loot == null
		or round_loot.disposition_finalized
		or round_loot.capacity <= 0
		or inventory_index < 0
		or inventory_index >= round_loot.carried_items.size()
	):
		return false
	round_loot.carried_items.remove_at(inventory_index); round_loot.carried_items.append({"item_id":String(session.overflow.incoming_item_id)})
	_finalize_pending_overflow_result(session, true); _resolve_pending(session, rewards); return true

func resolve_overflow_skip(session: LootRewardSession, rewards: Array[RewardDefinition]) -> bool:
	if not _overflow_resolution_context_is_valid(session, rewards): return false
	_finalize_pending_overflow_result(session, false); _resolve_pending(session, rewards); return true

func _overflow_resolution_context_is_valid(
	session: LootRewardSession, rewards: Array[RewardDefinition]
) -> bool:
	if (
		session == null
		or session.phase != LootRewardSession.Phase.BAG_OVERFLOW_PENDING
		or not session.overflow.active
		or session.movement_session == null
		or session.reward_history.is_empty()
	):
		return false
	var current_player: LootMovementPlayerState = session.movement_session.current_player()
	if current_player == null or current_player.player_id != session.overflow.player_id:
		return false
	var round_loot: RoundLootInventoryState = session.find_round_loot_state(
		session.overflow.player_id
	)
	if round_loot == null or round_loot.disposition_finalized:
		return false
	var pending: RewardResolutionResult = session.reward_history[-1]
	if (
		pending.status != RewardResolutionResult.Status.PENDING_OVERFLOW
		or not pending.overflow_required
		or pending.player_id != session.overflow.player_id
		or pending.node_id != session.overflow.node_id
		or pending.item_id != session.overflow.incoming_item_id
	):
		return false
	var reward: RewardDefinition = _find_reward(rewards, pending.reward_id)
	return (
		reward != null
		and reward.reward_type == RewardDefinition.Type.CONSUMABLE_ITEM
		and reward.item_id == session.overflow.incoming_item_id
	)

func _resolve_pending(session: LootRewardSession, rewards: Array[RewardDefinition]) -> void:
	while session.pending_trace_index < session.pending_trace.size():
		var node_id: StringName = session.pending_trace[session.pending_trace_index]
		session.pending_trace_index += 1
		var snapshot: RewardNodeSnapshot = session.find_snapshot(node_id)
		if snapshot == null: continue
		var reward: RewardDefinition = _find_reward(rewards, snapshot.reward_definition_id)
		if reward == null: continue
		var player_id: StringName = session.movement_session.movement_history[-1].player_id
		var result := RewardResolutionResult.new()
		result.player_id=player_id; result.node_id=node_id; result.reward_type=reward.reward_type; result.reward_amount=reward.amount; result.reward_id=reward.reward_id; result.item_id=reward.item_id
		if reward.repeat_policy == RewardDefinition.RepeatPolicy.ONCE_PER_ROUND_GLOBAL and session.consumed_special_node_ids.has(node_id):
			result.status = RewardResolutionResult.Status.SKIPPED; session.reward_history.append(result); continue
		var player: PlayerPhaseState = session.find_player(player_id)
		if reward.reward_type == RewardDefinition.Type.CONSUMABLE_ITEM:
			var round_loot: RoundLootInventoryState = session.find_round_loot_state(player_id)
			if round_loot == null:
				var compatibility_capacity := int(
					session.bag_capacity_by_player.get(String(player_id), 0)
				)
				round_loot = session.ensure_round_loot_state(
					player_id, compatibility_capacity
				)
			if round_loot.carried_items.size() >= round_loot.capacity:
				result.status=RewardResolutionResult.Status.PENDING_OVERFLOW; result.overflow_required=true; session.reward_history.append(result)
				session.overflow.active=true; session.overflow.player_id=player_id; session.overflow.incoming_item_id=reward.item_id; session.overflow.node_id=node_id; session.phase=LootRewardSession.Phase.BAG_OVERFLOW_PENDING; return
			round_loot.carried_items.append({"item_id":String(reward.item_id)})
		else: _grant_resource(player, reward, result)
		if reward.repeat_policy == RewardDefinition.RepeatPolicy.ONCE_PER_ROUND_GLOBAL:
			session.consumed_special_node_ids.append(node_id); result.consumed_special=true
		session.reward_history.append(result)
	_finish_personal_turn(session)

func _finish_personal_turn(session: LootRewardSession) -> void:
	item_service.expire_duration(session.movement_session.player_states, TemporaryEffectState.Duration.THIS_TURN)
	session.item_used_this_turn = false
	if session.movement_session.completed:
		item_service.expire_duration(session.movement_session.player_states, TemporaryEffectState.Duration.THIS_ROUND); session.phase=LootRewardSession.Phase.LOOT_END_CONFIRMATION_READY
	else: session.phase=LootRewardSession.Phase.ITEM_WINDOW

func _finalize_pending_overflow_result(session: LootRewardSession, accepted: bool) -> void:
	var result: RewardResolutionResult = session.reward_history[-1]
	result.status = RewardResolutionResult.Status.GRANTED if accepted else RewardResolutionResult.Status.SKIPPED; result.overflow_required=false
	session.overflow = BagOverflowState.new(); session.phase = LootRewardSession.Phase.REWARD_RESOLUTION

func _grant_resource(player: PlayerPhaseState, reward: RewardDefinition, result: RewardResolutionResult) -> void:
	match reward.reward_type:
		RewardDefinition.Type.SILVER_COIN: player.silver_coin_count += reward.amount; result.resource_delta={"silver_coin":reward.amount}
		RewardDefinition.Type.ORB: player.orb_count += reward.amount; result.resource_delta={"orb":reward.amount}
		RewardDefinition.Type.GACHA_TICKET: player.gacha_ticket_count += reward.amount; result.resource_delta={"gacha_ticket":reward.amount}
		RewardDefinition.Type.EQUIPMENT_EXP_MATERIAL: player.equipment_exp_material_count += reward.amount; result.resource_delta={"equipment_exp_material":reward.amount}
		RewardDefinition.Type.EQUIPMENT_EXCHANGE_MATERIAL: player.equipment_exchange_material_count += reward.amount; result.resource_delta={"equipment_exchange_material":reward.amount}

func _find_character(characters: Array[CharacterDefinition], character_id: StringName) -> CharacterDefinition:
	for character: CharacterDefinition in characters:
		if character.character_id == character_id: return character
	return null
func _find_reward(rewards: Array[RewardDefinition], reward_id: StringName) -> RewardDefinition:
	for reward: RewardDefinition in rewards:
		if reward.reward_id == reward_id: return reward
	return null
