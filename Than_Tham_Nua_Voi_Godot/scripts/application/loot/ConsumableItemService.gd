class_name ConsumableItemService
extends RefCounted

const SOURCE_PERSISTENT := &"persistent"
const SOURCE_ROUND_LOOT := &"round_loot"

func use_item(
	session: LootRewardSession,
	user_id: StringName,
	item_id: StringName,
	definitions: Array[ConsumableItemDefinition],
	source: StringName = SOURCE_PERSISTENT
) -> ItemUseResult:
	var result := ItemUseResult.new()
	if session == null or session.movement_session == null or session.phase != LootRewardSession.Phase.ITEM_WINDOW: result.code = &"ITEM_WINDOW_INACTIVE"; return result
	if session.item_used_this_turn: result.code = &"ITEM_LIMIT_REACHED"; return result
	var current_player: LootMovementPlayerState = session.movement_session.current_player()
	if current_player == null or current_player.player_id != user_id:
		result.code = &"ITEM_PLAYER_NOT_ACTIVE"
		return result
	var user: PlayerPhaseState = session.find_player(user_id)
	var definition: ConsumableItemDefinition = _find_definition(definitions, item_id)
	if user == null or definition == null: result.code = &"ITEM_OR_PLAYER_UNKNOWN"; return result
	var round_loot: RoundLootInventoryState = session.find_round_loot_state(user_id)
	if source == SOURCE_ROUND_LOOT and (round_loot == null or round_loot.disposition_finalized):
		result.code = &"ROUND_LOOT_UNAVAILABLE"
		return result
	if source != SOURCE_PERSISTENT and source != SOURCE_ROUND_LOOT:
		result.code = &"ITEM_SOURCE_UNKNOWN"
		return result
	var inventory_index: int = (
		_find_round_loot_index(round_loot, item_id)
		if source == SOURCE_ROUND_LOOT
		else _find_inventory_index(user, item_id)
	)
	if inventory_index < 0: result.code = &"ITEM_NOT_OWNED"; return result
	var targets: Array[LootMovementPlayerState] = []
	var movement_user: LootMovementPlayerState = _find_movement_player(session, user_id)
	if movement_user == null: result.code = &"MOVEMENT_PLAYER_UNKNOWN"; return result
	if source == SOURCE_ROUND_LOOT:
		round_loot.carried_items.remove_at(inventory_index)
	else:
		user.consumable_inventory.remove_at(inventory_index)
	if definition.target_scope == ConsumableItemDefinition.TargetScope.SELF: targets.append(movement_user)
	else:
		for player: LootMovementPlayerState in session.movement_session.player_states:
			if player.player_id != user_id: targets.append(player)
	for target: LootMovementPlayerState in targets:
		_apply_effect(target, user_id, definition)
		result.affected_player_ids.append(target.player_id)
	session.item_used_this_turn = true; result.success = true; result.code = &"OK"; result.consumed_item_id = item_id
	return result

func expire_duration(players: Array[LootMovementPlayerState], duration: TemporaryEffectState.Duration) -> void:
	for player: LootMovementPlayerState in players:
		for effect: TemporaryEffectState in player.temporary_effects:
			if effect.active and effect.duration == duration: effect.active = false; effect.remaining = 0

func _apply_effect(target: LootMovementPlayerState, _source_player_id: StringName, definition: ConsumableItemDefinition) -> void:
	if definition.effect_type == ConsumableItemDefinition.EffectType.EXTRA_MOVEMENT_ACTION: target.remaining_moves += definition.magnitude
	elif definition.effect_type == ConsumableItemDefinition.EffectType.MOVEMENT_ACTION_PENALTY: target.remaining_moves = maxi(0, target.remaining_moves - definition.magnitude)
	var effect := TemporaryEffectState.new()
	effect.effect_id = StringName("%s_effect" % definition.item_id); effect.source_id = definition.item_id; effect.target_player_ids = [target.player_id]; effect.effect_kind = StringName(ConsumableItemDefinition.EffectType.keys()[definition.effect_type]); effect.magnitude = definition.magnitude; effect.duration = definition.duration
	target.temporary_effects.append(effect)

func _find_inventory_index(player: PlayerPhaseState, item_id: StringName) -> int:
	for index: int in range(player.consumable_inventory.size()):
		if StringName(player.consumable_inventory[index].get("item_id", "")) == item_id: return index
	return -1

func _find_round_loot_index(state: RoundLootInventoryState, item_id: StringName) -> int:
	if state == null:
		return -1
	for index: int in range(state.carried_items.size()):
		if StringName(state.carried_items[index].get("item_id", "")) == item_id:
			return index
	return -1

func _find_definition(definitions: Array[ConsumableItemDefinition], item_id: StringName) -> ConsumableItemDefinition:
	for definition: ConsumableItemDefinition in definitions:
		if definition.item_id == item_id: return definition
	return null

func _find_movement_player(session: LootRewardSession, player_id: StringName) -> LootMovementPlayerState:
	if session == null or session.movement_session == null:
		return null
	for player: LootMovementPlayerState in session.movement_session.player_states:
		if player.player_id == player_id:
			return player
	return null
