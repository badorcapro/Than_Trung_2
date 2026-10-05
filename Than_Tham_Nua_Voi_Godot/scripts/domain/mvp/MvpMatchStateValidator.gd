class_name MvpMatchStateValidator
extends RefCounted

const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const MVP_MATCH_STATE := preload("res://scripts/domain/mvp/MvpMatchState.gd")
const PLAYER_MATCH_STATE := preload("res://scripts/domain/mvp/PlayerMatchState.gd")
const MVP_VALIDATION_REPORT := preload("res://scripts/domain/mvp/MvpValidationReport.gd")
const VALIDATION_ISSUE := preload("res://scripts/domain/validation/ValidationIssue.gd")


func validate(match_state: MVP_MATCH_STATE) -> MVP_VALIDATION_REPORT:
	var report: MVP_VALIDATION_REPORT = MVP_VALIDATION_REPORT.new()
	if match_state == null:
		report.add_error(&"MATCH_STATE_NULL", "Match state is required", &"match")
		return report
	if match_state.match_id.is_empty():
		report.add_error(&"MATCH_ID_MISSING", "match_id is required", &"match")
	if match_state.current_round_number < 0:
		report.add_error(&"ROUND_NUMBER_NEGATIVE", "Round number cannot be negative", &"match")
	if match_state.completed_round_count < 0:
		report.add_error(&"COMPLETED_ROUND_COUNT_NEGATIVE", "Completed Round count cannot be negative", &"match")
	if not MVP_ENUMS.is_valid_phase(match_state.current_phase):
		report.add_error(&"MATCH_PHASE_INVALID", "Match phase is invalid", &"match")
	if match_state.match_rules == null:
		report.add_error(&"MATCH_RULES_MISSING", "Match rules are required", &"match_rules")
	else:
		var rules_error: StringName = match_state.match_rules.validation_error()
		if not rules_error.is_empty():
			report.add_error(rules_error, "Match rules are invalid", &"match_rules")
	_validate_players(match_state, report)
	_validate_order(match_state, report)
	_validate_policies(match_state.open_policy_config_ids, report)
	_validate_commits(match_state.applied_commit_ids, report)
	if match_state.match_completion_state == &"MATCH_COMPLETE":
		if match_state.current_phase != MVP_ENUMS.Phase.MATCH_COMPLETE:
			report.add_error(&"MATCH_COMPLETE_PHASE_MISMATCH", "Completed Match requires MATCH_COMPLETE phase", &"match")
		if match_state.final_standings.size() != match_state.players.size():
			report.add_error(&"FINAL_STANDINGS_INCOMPLETE", "Final standings must cover every player", &"match")
	elif not match_state.final_standings.is_empty():
		report.add_error(&"FINAL_STANDINGS_PREMATURE", "Final standings require a completed Match", &"match")
	return report


func _validate_players(match_state: MVP_MATCH_STATE, report: MVP_VALIDATION_REPORT) -> void:
	if match_state.players.is_empty() or match_state.players.size() > 4:
		report.add_error(&"PLAYER_COUNT_INVALID", "Match requires 1..4 players", &"players")
	var ids: Dictionary = {}
	var seats: Dictionary = {}
	for player: PLAYER_MATCH_STATE in match_state.players:
		if player == null:
			report.add_error(&"PLAYER_NULL", "Player state is required", &"players")
			continue
		var source := StringName("player:%s" % String(player.player_id))
		if player.player_id.is_empty():
			report.add_error(&"PLAYER_ID_MISSING", "player_id is required", source)
		elif ids.has(player.player_id):
			report.add_error(&"PLAYER_ID_DUPLICATE", "player_id must be unique", source)
		ids[player.player_id] = true
		if player.seat_index < 0 or player.seat_index >= 4:
			report.add_error(&"SEAT_INVALID", "seat_index must be 0..3", source)
		elif seats.has(player.seat_index):
			report.add_error(&"SEAT_DUPLICATE", "seat_index must be unique", source)
		seats[player.seat_index] = true
		if match_state.character_selection_complete and player.character_id.is_empty():
			report.add_error(&"CHARACTER_MISSING", "Selected Character is required", source)
		if player.reputation < 0 or player.reputation > 6:
			report.add_error(&"REPUTATION_OUT_OF_RANGE", "reputation must be 0..6", source)
		_validate_counts(player, report, source)
		_validate_marks(player, report, source)
		_validate_equipment(player, report, source)
		_validate_gacha(player, report, source)


func _validate_counts(
	player: PLAYER_MATCH_STATE, report: MVP_VALIDATION_REPORT, source: StringName
) -> void:
	var values: Array[int] = [
		player.orb_count,
		player.gacha_ticket_count,
		player.silver_coin_count,
		player.equipment_exp_material_count,
		player.equipment_exchange_material_count,
	]
	for value: int in values:
		if value < 0:
			report.add_error(&"RESOURCE_NEGATIVE", "Persistent resources cannot be negative", source)
			break


func _validate_marks(
	player: PLAYER_MATCH_STATE, report: MVP_VALIDATION_REPORT, source: StringName
) -> void:
	var ids: Dictionary = {}
	for mark in player.persistent_marks:
		if mark.mark_id.is_empty() or mark.count < 0:
			report.add_error(&"PERSISTENT_MARK_INVALID", "Mark ID/count is invalid", source)
		elif ids.has(mark.mark_id):
			report.add_error(&"PERSISTENT_MARK_DUPLICATE", "Mark IDs must be unique", source)
		ids[mark.mark_id] = true


func _validate_equipment(
	player: PLAYER_MATCH_STATE, report: MVP_VALIDATION_REPORT, source: StringName
) -> void:
	var ids: Dictionary = {}
	for instance: EquipmentInstance in player.equipment_collection:
		if instance == null:
			report.add_error(&"EQUIPMENT_NULL", "Equipment instance is required", source)
			continue
		if ids.has(instance.instance_id):
			report.add_error(&"EQUIPMENT_INSTANCE_DUPLICATE", "Instance IDs must be unique", source)
		ids[instance.instance_id] = true
		if instance.owner_player_id != player.player_id:
			report.add_error(&"EQUIPMENT_OWNER_MISMATCH", "Equipment owner mismatch", source)
	var loadout := LoadoutState.new()
	loadout.relic_instance_id = player.relic_instance_id
	loadout.stigmata_a_instance_id = player.stigmata_a_instance_id
	loadout.stigmata_b_instance_id = player.stigmata_b_instance_id
	loadout.stigmata_c_instance_id = player.stigmata_c_instance_id
	var loadout_report := LoadoutValidator.new().validate(player.equipment_collection, loadout)
	for issue: VALIDATION_ISSUE in loadout_report.errors:
		report.add_error(issue.code, issue.message, source)


func _validate_gacha(
	player: PLAYER_MATCH_STATE, report: MVP_VALIDATION_REPORT, source: StringName
) -> void:
	if player.gacha_state == null:
		report.add_error(&"GACHA_STATE_NULL", "Gacha state is required", source)
		return
	if (
		player.gacha_state.consecutive_without_a_plus < 0
		or player.gacha_state.rate_up_consecutive_without_a_plus < 0
	):
		report.add_error(&"GACHA_PITY_NEGATIVE", "Gacha pity cannot be negative", source)
	for dictionary: Dictionary in [
		player.gacha_state.rate_up_state_by_banner,
		player.gacha_state.equipment_exchange_price_by_definition,
		player.gacha_state.ss_purchase_count_by_definition,
		player.gacha_state.perfect_pool_remaining_hits,
	]:
		for value: Variant in dictionary.values():
			if int(value) < 0:
				report.add_error(&"GACHA_STATE_NEGATIVE", "Gacha counters cannot be negative", source)
				return


func _validate_order(match_state: MVP_MATCH_STATE, report: MVP_VALIDATION_REPORT) -> void:
	if match_state.player_order.size() != match_state.players.size():
		report.add_error(&"PLAYER_ORDER_SIZE", "Player order must cover every player", &"order")
		return
	var seen: Dictionary = {}
	for player_id: StringName in match_state.player_order:
		if seen.has(player_id):
			report.add_error(&"PLAYER_ORDER_DUPLICATE", "Player order contains duplicate", &"order")
		elif match_state.find_player(player_id) == null:
			report.add_error(&"PLAYER_ORDER_UNKNOWN", "Player order references unknown player", &"order")
		seen[player_id] = true


func _validate_policies(policies: Dictionary, report: MVP_VALIDATION_REPORT) -> void:
	for key: Variant in policies.keys():
		if String(key).is_empty() or String(policies.get(key, "")).is_empty():
			report.add_error(&"OPEN_POLICY_INVALID", "Policy IDs require non-empty key/value", &"policy")


func _validate_commits(commits: Array[StringName], report: MVP_VALIDATION_REPORT) -> void:
	var seen: Dictionary = {}
	for commit_id: StringName in commits:
		if commit_id.is_empty():
			report.add_error(&"COMMIT_ID_EMPTY", "Commit ID cannot be empty", &"commit")
		elif seen.has(commit_id):
			report.add_error(&"COMMIT_ID_DUPLICATE", "Commit IDs must be unique", &"commit")
		seen[commit_id] = true
