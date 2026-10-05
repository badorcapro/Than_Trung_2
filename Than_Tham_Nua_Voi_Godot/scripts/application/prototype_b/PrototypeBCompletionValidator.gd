class_name PrototypeBCompletionValidator
extends RefCounted

const PROTOTYPE_B_PLAYER_SUMMARY := preload(
	"res://scripts/domain/prototype_b/PrototypeBPlayerSummary.gd"
)
const PROTOTYPE_B_SUMMARY := preload("res://scripts/domain/prototype_b/PrototypeBSummary.gd")
const PROTOTYPE_B_SESSION := preload("res://scripts/domain/prototype_b/PrototypeBSession.gd")
const PROTOTYPE_B_VALIDATION_REPORT := preload(
	"res://scripts/domain/prototype_b/PrototypeBValidationReport.gd"
)


func validate_completion_ready(session: PROTOTYPE_B_SESSION) -> PROTOTYPE_B_VALIDATION_REPORT:
	var report: PROTOTYPE_B_VALIDATION_REPORT = PROTOTYPE_B_VALIDATION_REPORT.new()
	if session == null:
		report.add(&"SESSION_MISSING", "Prototype B session is missing", &"session")
		return report
	if session.players.is_empty():
		report.add(&"PLAYERS_MISSING", "At least one player is required", &"players")
	var ids: Dictionary = {}
	for player: PlayerPhaseState in session.players:
		if player.player_id.is_empty():
			report.add(&"PLAYER_ID_MISSING", "Player id is required", &"players")
		elif ids.has(String(player.player_id)):
			report.add(&"DUPLICATE_PLAYER_ID", "Duplicate player id", &"players")
		ids[String(player.player_id)] = true
		var player_report := PlayerPhaseStateValidator.new().validate(player)
		if not player_report.is_valid:
			report.add(
				&"PLAYER_STATE_INVALID",
				"Player Equipment/loadout/resource state is invalid",
				&"players"
			)
		if player.gacha_state.rate_up_consecutive_without_a_plus < 0:
			report.add(&"GACHA_STATE_INVALID", "Rate Up pity cannot be negative", &"gacha")
		for remaining_value: Variant in player.gacha_state.perfect_pool_remaining_hits.values():
			if int(remaining_value) < 0:
				report.add(
					&"GACHA_STATE_INVALID", "Perfect remaining hits cannot be negative", &"gacha"
				)
	if (
		session.movement_session == null
		or not session.movement_session.completed
		or not session.movement_session.all_exhausted()
	):
		report.add(&"MOVEMENT_UNRESOLVED", "Movement actions remain", &"movement")
	if session.reward_session == null:
		report.add(&"REWARD_SESSION_MISSING", "Reward session is missing", &"reward")
	else:
		if session.reward_session.phase != LootRewardSession.Phase.LOOT_END_CONFIRMATION_READY:
			report.add(&"REWARD_UNRESOLVED", "Reward chain is not ready", &"reward")
		if session.reward_session.pending_trace_index < session.reward_session.pending_trace.size():
			report.add(&"REWARD_TRACE_PENDING", "Reward trace remains", &"reward")
		if session.reward_session.overflow.active:
			report.add(&"OVERFLOW_PENDING", "Bag overflow remains", &"reward")
	if session.management_session == null:
		report.add(&"MANAGEMENT_MISSING", "Management session is missing", &"management")
	else:
		if session.management_session.phase != EquipmentManagementSession.Phase.READY_FOR_M6:
			report.add(&"MANAGEMENT_NOT_DONE", "All players must finish management", &"management")
		if (
			session.management_session.done_player_ids.size()
			!= session.management_session.player_order.size()
		):
			report.add(
				&"MANAGEMENT_DONE_MISMATCH", "Done flags do not match player order", &"management"
			)
		if session.management_session.pending_choice.is_active():
			report.add(&"PENDING_CHOICE", "Gacha choice must be resolved", &"management")
		if not EquipmentManagementSerializer.new().round_trip(session.management_session):
			report.add(
				&"SERIALIZATION_INVALID", "Management state cannot round-trip", &"serialization"
			)
	return report


func validate_summary(
	session: PROTOTYPE_B_SESSION, summary: PROTOTYPE_B_SUMMARY
) -> PROTOTYPE_B_VALIDATION_REPORT:
	var report: PROTOTYPE_B_VALIDATION_REPORT = validate_completion_ready(session)
	if summary == null:
		report.add(&"SUMMARY_MISSING", "Summary is missing", &"summary")
		return report
	if summary.player_summaries.size() != session.players.size():
		report.add(&"SUMMARY_PLAYER_COUNT", "Summary player count mismatch", &"summary")
	var ids: Dictionary = {}
	for row: PROTOTYPE_B_PLAYER_SUMMARY in summary.player_summaries:
		var id := String(row.data.get("player_id", ""))
		if id.is_empty() or ids.has(id):
			report.add(&"SUMMARY_PLAYER_ID", "Missing or duplicate summary player id", &"summary")
		ids[id] = true
	for key: String in [
		"player_count",
		"movement_actions",
		"nodes_traversed",
		"rewards_granted",
		"consumables_used",
		"overflow_events",
		"equipment_acquired",
		"gold_upgrades",
		"purple_upgrades",
		"basic_rolls",
		"rate_up_rolls",
		"perfect_spins",
		"ss_unlocked",
		"final_prototype_state"
	]:
		if not summary.aggregates.has(key):
			report.add(&"AGGREGATE_FIELD_MISSING", "Missing aggregate: %s" % key, &"summary")
	return report
