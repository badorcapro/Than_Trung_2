class_name LootEndConfirmationService
extends RefCounted

func can_begin(reward_session: LootRewardSession) -> bool:
	if reward_session == null or reward_session.movement_session == null: return false
	if reward_session.phase != LootRewardSession.Phase.LOOT_END_CONFIRMATION_READY: return false
	if reward_session.overflow.active or reward_session.pending_trace_index < reward_session.pending_trace.size(): return false
	for player: LootMovementPlayerState in reward_session.movement_session.player_states:
		if player.remaining_moves > 0: return false
	return true

func begin(reward_session: LootRewardSession) -> EquipmentManagementSession:
	if not can_begin(reward_session): return null
	var session := EquipmentManagementSession.new(); session.round_id=reward_session.round_id
	for player: PlayerPhaseState in reward_session.players:
		session.player_order.append(player.player_id); session.players.append(PlayerPhaseState.from_persistent_dict(player.to_persistent_dict()))
	return session

func confirm(
	session: EquipmentManagementSession,
	player_id: StringName,
	reward_session: LootRewardSession = null,
	definitions: Array[ConsumableItemDefinition] = []
) -> bool:
	if session == null or session.phase != EquipmentManagementSession.Phase.LOOT_END_CONFIRMATION or not session.player_order.has(player_id): return false
	if session.confirmed_player_ids.has(player_id): return false
	if reward_session != null and not _finalize_round_loot(
		reward_session, session, player_id, definitions
	):
		return false
	session.confirmed_player_ids.append(player_id)
	if session.confirmed_player_ids.size() == session.player_order.size():
		session.phase=EquipmentManagementSession.Phase.EQUIPMENT_MANAGEMENT; session.current_player_index=0
	else:
		for offset: int in range(1, session.player_order.size() + 1):
			var candidate_index: int = (session.current_player_index + offset) % session.player_order.size()
			if not session.confirmed_player_ids.has(session.player_order[candidate_index]):
				session.current_player_index = candidate_index
				break
	return true

func _finalize_round_loot(
	reward_session: LootRewardSession,
	management_session: EquipmentManagementSession,
	player_id: StringName,
	definitions: Array[ConsumableItemDefinition]
) -> bool:
	var round_loot: RoundLootInventoryState = reward_session.find_round_loot_state(player_id)
	var reward_player: PlayerPhaseState = reward_session.find_player(player_id)
	var management_player: PlayerPhaseState = management_session.find_player(player_id)
	if round_loot == null or reward_player == null or management_player == null:
		return false
	if round_loot.disposition_finalized:
		return false
	for row: Dictionary in round_loot.carried_items:
		var item_id: StringName = StringName(row.get("item_id", ""))
		if item_id.is_empty() or not _has_definition(definitions, item_id):
			return false
	var transferred: Array[Dictionary] = round_loot.carried_items.duplicate(true)
	for row: Dictionary in transferred:
		reward_player.consumable_inventory.append(row.duplicate(true))
		management_player.consumable_inventory.append(row.duplicate(true))
	round_loot.transferred_items = transferred
	round_loot.carried_items.clear()
	round_loot.disposition_finalized = true
	return true

func _has_definition(
	definitions: Array[ConsumableItemDefinition], item_id: StringName
) -> bool:
	for definition: ConsumableItemDefinition in definitions:
		if definition != null and definition.item_id == item_id:
			return true
	return false

func mark_management_done(session: EquipmentManagementSession, player_id: StringName) -> bool:
	if session == null or session.phase != EquipmentManagementSession.Phase.EQUIPMENT_MANAGEMENT or session.current_player_id()!=player_id or session.pending_choice.is_active(): return false
	if not session.done_player_ids.has(player_id): session.done_player_ids.append(player_id)
	if session.done_player_ids.size()==session.player_order.size(): session.phase=EquipmentManagementSession.Phase.READY_FOR_M6
	else: session.current_player_index=(session.current_player_index+1)%session.player_order.size()
	return true
