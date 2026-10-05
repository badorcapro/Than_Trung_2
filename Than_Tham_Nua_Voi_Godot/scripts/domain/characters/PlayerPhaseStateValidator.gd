class_name PlayerPhaseStateValidator
extends RefCounted

func validate(state: PlayerPhaseState) -> LootValidationReport:
	var report := LootValidationReport.new()
	if state == null:
		report.add_error(&"PLAYER_STATE_NULL", "Player state is required")
		return report
	if state.player_id.is_empty(): report.add_error(&"PLAYER_ID_EMPTY", "player_id is required")
	if state.character_id.is_empty(): report.add_error(&"PLAYER_CHARACTER_ID_EMPTY", "character_id is required")
	if state.seat_index < 0: report.add_error(&"SEAT_INDEX_NEGATIVE", "seat_index must be >= 0")
	if state.reputation < 0 or state.reputation > 6: report.add_error(&"REPUTATION_OUT_OF_RANGE", "reputation must be 0..6")
	var counts: Array[int] = [state.orb_count, state.gacha_ticket_count, state.silver_coin_count, state.equipment_exp_material_count, state.equipment_exchange_material_count, state.gacha_state.consecutive_without_a_plus]
	for value in counts:
		if int(value) < 0: report.add_error(&"RESOURCE_OR_STATE_NEGATIVE", "Count-like state cannot be negative"); break
	var loadout := LoadoutState.new()
	loadout.relic_instance_id = state.relic_instance_id; loadout.stigmata_a_instance_id = state.stigmata_a_instance_id; loadout.stigmata_b_instance_id = state.stigmata_b_instance_id; loadout.stigmata_c_instance_id = state.stigmata_c_instance_id
	report.merge(LoadoutValidator.new().validate(state.equipment_collection, loadout))
	return report
