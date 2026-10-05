class_name PrototypeBSummaryService
extends RefCounted

const PROTOTYPE_B_PLAYER_SUMMARY := preload(
	"res://scripts/domain/prototype_b/PrototypeBPlayerSummary.gd"
)
const PROTOTYPE_B_SUMMARY := preload("res://scripts/domain/prototype_b/PrototypeBSummary.gd")
const PROTOTYPE_B_SESSION := preload("res://scripts/domain/prototype_b/PrototypeBSession.gd")
const OPEN_POLICIES := {
	"rate_up_pity_scope_policy": "TEST_ONLY_PER_PLAYER_BANNER",
	"rate_up_exchange_policy": "TEST_ONLY_CONFIG",
	"perfect_pool_persistence_policy": "TEST_ONLY_SESSION",
	"perfect_weight_fixture_id": "m5_gacha_config_test_only",
	"perfect_regular_pool_fixture_id": "m5_perfect_pool_test_only",
	"s_choice_scope_fixture_id": "m5_s_choice_test_only",
	"ss_shop_currency_fixture_id": "m5_ss_shop_currency_test_only",
}


func build_player_summary(
	session: PROTOTYPE_B_SESSION, player: PlayerPhaseState
) -> PROTOTYPE_B_PLAYER_SUMMARY:
	var result: PROTOTYPE_B_PLAYER_SUMMARY = PROTOTYPE_B_PLAYER_SUMMARY.new()
	var movement_actions := 0
	var nodes_traversed := 0
	if session.movement_session != null:
		for action: MovementActionResult in session.movement_session.movement_history:
			if action.player_id == player.player_id:
				movement_actions += 1
				nodes_traversed += action.traversed_node_ids.size()
	var character_value: Variant = session.characters_by_id.get(String(player.character_id))
	var character_name := String(player.character_id)
	var origin_id := ""
	if character_value is CharacterDefinition:
		var character := character_value as CharacterDefinition
		character_name = character.display_name
		origin_id = String(character.origin_house_id)
	var equipment_rows: Array[Dictionary] = []
	var progression: Array[Dictionary] = []
	var movement_player: LootMovementPlayerState = _movement_player(
		session.movement_session, player.player_id
	)
	var round_loot: RoundLootInventoryState
	if session.reward_session != null:
		round_loot = session.reward_session.find_round_loot_state(player.player_id)
	for instance: EquipmentInstance in player.equipment_collection:
		equipment_rows.append(instance.to_dict())
		progression.append(
			{
				"instance_id": String(instance.instance_id),
				"gold": instance.gold_star_level,
				"purple": instance.purple_star_level
			}
		)
	result.data = {
		"player_id": String(player.player_id),
		"seat": player.seat_index,
		"character_id": String(player.character_id),
		"character": character_name,
		"origin_house_id": origin_id,
		"final_loot_node": String(movement_player.current_node_id) if movement_player != null else "",
		"movement_actions_used": movement_actions,
		"movement_history_count": movement_actions,
		"nodes_traversed": nodes_traversed,
		"resources":
		{
			"silver": player.silver_coin_count,
			"orb": player.orb_count,
			"gacha_ticket": player.gacha_ticket_count,
			"equipment_exp": player.equipment_exp_material_count,
			"equipment_exchange": player.equipment_exchange_material_count
		},
		"bag": round_loot.carried_items.duplicate(true) if round_loot != null else [],
		"temporary_effects": _effects(movement_player),
		"equipment_collection_count": player.equipment_collection.size(),
		"equipment_collection": equipment_rows,
		"loadout":
		{
			"relic": String(player.relic_instance_id),
			"stigmata_a": String(player.stigmata_a_instance_id),
			"stigmata_b": String(player.stigmata_b_instance_id),
			"stigmata_c": String(player.stigmata_c_instance_id)
		},
		"full_set_active": _full_set(player),
		"gold_purple_progression": progression,
		"basic_pity": player.gacha_state.consecutive_without_a_plus,
		"rate_up_state": player.gacha_state.rate_up_state_by_banner.duplicate(true),
		"rate_up_pity": player.gacha_state.rate_up_consecutive_without_a_plus,
		"perfect_remaining_pool": player.gacha_state.perfect_pool_remaining_hits.duplicate(true),
		"pending_choice": _pending_choice(session, player.player_id),
		"ss_shop_unlocks": _string_names(player.gacha_state.ss_unlocked_equipment_ids),
		"management_done":
		(
			session.management_session != null
			and session.management_session.done_player_ids.has(player.player_id)
		),
	}
	return result


func build_session_summary(session: PROTOTYPE_B_SESSION) -> PROTOTYPE_B_SUMMARY:
	var result: PROTOTYPE_B_SUMMARY = PROTOTYPE_B_SUMMARY.new()
	result.session_id = session.session_id
	result.round_id = session.round_id
	for player: PlayerPhaseState in session.players:
		result.player_summaries.append(build_player_summary(session, player))
	result.aggregates = calculate_aggregates(session)
	result.open_policy_ids = OPEN_POLICIES.duplicate(true)
	return result


func calculate_aggregates(session: PROTOTYPE_B_SESSION) -> Dictionary:
	var result := {
		"player_count": session.players.size(),
		"movement_actions": 0,
		"nodes_traversed": 0,
		"rewards_granted": 0,
		"consumables_used": 0,
		"overflow_events": 0,
		"equipment_acquired": 0,
		"gold_upgrades": 0,
		"purple_upgrades": 0,
		"basic_rolls": 0,
		"rate_up_rolls": 0,
		"perfect_spins": 0,
		"ss_unlocked": 0,
		"final_prototype_state": "PROTOTYPE_B_SUMMARY"
	}
	if session.movement_session != null:
		result.movement_actions = session.movement_session.movement_history.size()
		for action: MovementActionResult in session.movement_session.movement_history:
			result.nodes_traversed += action.traversed_node_ids.size()
	if session.reward_session != null:
		result.rewards_granted = session.reward_session.reward_history.size()
		for row: RewardResolutionResult in session.reward_session.reward_history:
			if row.reward_type == RewardDefinition.Type.CONSUMABLE_ITEM:
				result.consumables_used += 1
	for player: PlayerPhaseState in session.players:
		result.equipment_acquired += player.equipment_collection.size()
		result.ss_unlocked += player.gacha_state.ss_unlocked_equipment_ids.size()
	if session.management_session != null:
		for row: Dictionary in session.management_session.progression_history:
			var code := String(row.get("code", ""))
			result.gold_upgrades += int(code.contains("GOLD"))
			result.purple_upgrades += int(code.contains("PURPLE"))
		for row: Dictionary in session.management_session.gacha_history:
			var banner := String(row.get("banner_type", ""))
			result.basic_rolls += int(banner == "BASIC")
			result.rate_up_rolls += int(banner == "RATE_UP")
			result.perfect_spins += int(banner == "PERFECT")
	return result


func finalize_prototype_b(session: PROTOTYPE_B_SESSION) -> Dictionary:
	if session.status != PROTOTYPE_B_SESSION.Status.PROTOTYPE_B_SUMMARY:
		return {"success": false, "code": "SUMMARY_NOT_CONFIRMED"}
	session.status = PROTOTYPE_B_SESSION.Status.PROTOTYPE_B_COMPLETE
	if session.summary != null:
		session.summary.completion_status = &"PROTOTYPE_B_COMPLETE"
		session.summary.aggregates["final_prototype_state"] = "PROTOTYPE_B_COMPLETE"
	return {"success": true, "code": "PROTOTYPE_B_COMPLETE"}


func _effects(player: LootMovementPlayerState) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	if player == null:
		return rows
	for effect: TemporaryEffectState in player.temporary_effects:
		rows.append(effect.to_dict())
	return rows


func _movement_player(
	session: LootMovementSession, player_id: StringName
) -> LootMovementPlayerState:
	if session == null:
		return null
	for player: LootMovementPlayerState in session.player_states:
		if player.player_id == player_id:
			return player
	return null


func _string_names(values: Array[StringName]) -> Array[String]:
	var rows: Array[String] = []
	for value: StringName in values:
		rows.append(String(value))
	return rows


func _pending_choice(session: PROTOTYPE_B_SESSION, player_id: StringName) -> Dictionary:
	if (
		session.management_session != null
		and session.management_session.pending_choice.player_id == player_id
	):
		return session.management_session.pending_choice.to_dict()
	return PendingEquipmentChoice.new().to_dict()


func _full_set(player: PlayerPhaseState) -> bool:
	return (
		not player.stigmata_a_instance_id.is_empty()
		and not player.stigmata_b_instance_id.is_empty()
		and not player.stigmata_c_instance_id.is_empty()
	)
