class_name MvpIntegratedRoundCompletionSession
extends "res://scripts/application/mvp/MvpIntegratedCaseLootSession.gd"

const COURT_RANK_SERVICE := preload("res://scripts/domain/progression/CourtRankService.gd")
const EQUIPMENT_SESSION := preload(
	"res://scripts/domain/equipment/EquipmentManagementSession.gd"
)
const LOOT_END_SERVICE := preload(
	"res://scripts/application/loot/LootEndConfirmationService.gd"
)
const EQUIPMENT_SERVICE := preload(
	"res://scripts/application/equipment/EquipmentManagementService.gd"
)
const PROGRESSION_SERVICE := preload(
	"res://scripts/application/equipment/EquipmentProgressionService.gd"
)
const GACHA_SERVICE := preload("res://scripts/application/economy/GachaService.gd")
const SEQUENCE_GACHA_ROLL_SOURCE := preload(
	"res://scripts/infrastructure/SequenceGachaRollSource.gd"
)
const MATCH_VALIDATOR := preload("res://scripts/domain/mvp/MvpMatchStateValidator.gd")
const ROUND_VALIDATOR := preload("res://scripts/domain/mvp/MvpRoundStateValidator.gd")
const MVP_VALIDATION_REPORT := preload("res://scripts/domain/mvp/MvpValidationReport.gd")
const M4_MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const M4_MVP_MATCH_STATE := preload("res://scripts/domain/mvp/MvpMatchState.gd")
const M4_MVP_ROUND_STATE := preload("res://scripts/domain/mvp/MvpRoundState.gd")
const M4_PLAYER_MATCH_STATE := preload("res://scripts/domain/mvp/PlayerMatchState.gd")
const M4_TRANSITION_RESULT := preload("res://scripts/domain/mvp/MvpTransitionResult.gd")
const M4_FIXTURES := preload("res://scripts/application/loot/Gd2FixtureRepository.gd")
const PRODUCTION_CHARACTER_REPOSITORY := preload(
	"res://scripts/application/characters/ProductionCharacterRepository.gd"
)
const EQUIPMENT_ENUMS := preload("res://scripts/domain/equipment/EquipmentEnums.gd")
const MATCH_COMPLETION_SERVICE := preload(
	"res://scripts/domain/mvp/MatchCompletionService.gd"
)

const ROUND_END_COMMIT_ID := &"gd3_m4_round_end_001"
const PERFECT_POLICY_ID := "perfect_round_end_persist_test_only"

var equipment_session: EQUIPMENT_SESSION
var round_end_summary: Dictionary = {}

var _court_rank_service: COURT_RANK_SERVICE = COURT_RANK_SERVICE.new()
var _end_service: LOOT_END_SERVICE = LOOT_END_SERVICE.new()
var _equipment_service: EQUIPMENT_SERVICE = EQUIPMENT_SERVICE.new()
var _progression_service: PROGRESSION_SERVICE = PROGRESSION_SERVICE.new()
var _gacha_service: GACHA_SERVICE = GACHA_SERVICE.new()
var _match_completion_service: MATCH_COMPLETION_SERVICE = MATCH_COMPLETION_SERVICE.new()
var _equipment_definitions: Array[EquipmentDefinition] = []
var _perfect_entries: Array[PerfectPoolEntry] = []
var _gacha_config: GachaConfig
var _round_end_committed := false
var _player_facing_test_collection_bootstrap := false


func initialize_player_facing_case(
	source_match: M4_MVP_MATCH_STATE, selected_case: CaseDefinition
) -> Dictionary:
	var result: Dictionary = super.initialize_player_facing_case(source_match, selected_case)
	if bool(result.get("success", false)):
		_initialize_player_facing_production_content()
		_player_facing_test_collection_bootstrap = true
	return result


func build_integrated_fixture() -> Dictionary:
	var result: Dictionary = super.build_integrated_fixture()
	if bool(result.get("success", false)):
		match_state.match_id = &"gd3_m4_integrated_match"
		round_state.round_id = &"gd3_m4_round_001"
		match_state.open_policy_config_ids["perfect_round_end"] = PERFECT_POLICY_ID
		_initialize_management_content()
		checkpoints["pre_case"] = _serializer.round_trip_diagnostic(match_state, round_state)
		equipment_session = null
		round_end_summary.clear()
		_round_end_committed = false
	return result


func _initialize_management_content() -> void:
	_characters = M4_FIXTURES.load_selection_characters()
	_equipment_definitions = M4_FIXTURES.load_m5_equipment_definitions()
	_perfect_entries = M4_FIXTURES.load_m5_perfect_entries()
	_gacha_config = M4_FIXTURES.load_m5_gacha_config()
	equipment_session = null
	round_end_summary.clear()
	_round_end_committed = false
	_player_facing_test_collection_bootstrap = false


func _initialize_player_facing_production_content() -> void:
	_initialize_management_content()
	_characters = PRODUCTION_CHARACTER_REPOSITORY.load_all()
	_map_definition = M4_FIXTURES.load_production_map()
	if round_state != null and _map_definition != null:
		round_state.loot_map_id = _map_definition.map_id


func enable_player_facing_test_collection_bootstrap() -> void:
	_player_facing_test_collection_bootstrap = true


func _seed_test_only_player_facing_collections(session: EQUIPMENT_SESSION) -> void:
	if session == null:
		return
	for player: PlayerPhaseState in session.players:
		if player == null or not player.equipment_collection.is_empty():
			continue
		for definition_id: StringName in [
			&"m5_a_relic",
			&"m5_a_relic",
			&"m5_s_relic_other",
			&"m5_a_stig_a",
			&"m5_s_stig_a",
			&"m5_a_stig_b",
			&"m5_a_stig_c",
		]:
			var definition: EquipmentDefinition = _equipment_service.find_definition(
				_equipment_definitions, definition_id
			)
			if definition != null and definition.test_only_not_canon_locked:
				_equipment_service.grant(player, definition, &"PF_M9B_TEST_BOOTSTRAP")
		player.equipment_exp_material_count = maxi(
			player.equipment_exp_material_count, 200
		)
		player.gacha_ticket_count = maxi(player.gacha_ticket_count, 4)


func begin_loot_end_confirmation() -> Dictionary:
	if equipment_session != null:
		return _failure(
			&"MANAGEMENT_SESSION_ALREADY_ACTIVE", "Round already owns a management session", true
		)
	if match_state.current_phase != M4_MVP_ENUMS.Phase.LOOT_END_CONFIRMATION:
		return _failure(&"LOOT_NOT_FINISHED", "Loot must reach confirmation readiness first")
	if not _end_service.can_begin(loot_session):
		return _failure(
			&"LOOT_CONFIRMATION_NOT_READY",
			"Movement, reward, overflow and mandatory item state must all be resolved"
		)
	var candidate: EQUIPMENT_SESSION = _end_service.begin(loot_session)
	if candidate == null:
		return _failure(&"MANAGEMENT_INITIALIZATION_FAILED", "GĐ2 rejected Loot projection")
	if _player_facing_test_collection_bootstrap:
		_seed_test_only_player_facing_collections(candidate)
	for player_id: StringName in candidate.player_order:
		candidate.test_ss_shop_currency_by_player[String(player_id)] = 100
	equipment_session = candidate
	round_state.equipment_management_snapshot = equipment_session.to_dict()
	return _success(&"LOOT_END_CONFIRMATION_STARTED", "Pass-device confirmation is active")


func confirm_loot_end(player_id: StringName) -> Dictionary:
	if equipment_session == null:
		return _failure(&"CONFIRMATION_SESSION_MISSING", "Begin Loot End Confirmation first")
	if equipment_session.confirmed_player_ids.has(player_id):
		return _failure(&"PLAYER_ALREADY_CONFIRMED", "Player confirmation is idempotent", true)
	var candidate: EQUIPMENT_SESSION = EQUIPMENT_SESSION.from_dict(equipment_session.to_dict())
	var candidate_loot: LootRewardSession = LootRewardSession.from_dict(
		loot_session.to_dict()
	)
	if not _end_service.confirm(candidate, player_id, candidate_loot, _items):
		return _failure(&"PLAYER_CONFIRM_REJECTED", "Player cannot confirm this state")
	if candidate.phase == EQUIPMENT_SESSION.Phase.EQUIPMENT_MANAGEMENT:
		var transition: M4_TRANSITION_RESULT = _orchestrator.transition(
			M4_MVP_ENUMS.Phase.EQUIPMENT_MANAGEMENT
		)
		if not transition.success:
			return _transition_failure(transition)
		loot_session = candidate_loot
		equipment_session = candidate
		_sync_loot_to_match()
		_capture_loot_snapshots()
		round_state.equipment_management_snapshot = equipment_session.to_dict()
		checkpoints["loot_end_confirmed"] = _serializer.round_trip_diagnostic(
			match_state, round_state
		)
		checkpoints["management_started"] = _serializer.round_trip_diagnostic(
			match_state, round_state
		)
		event_log.append("All Loot End confirmations received; actual management started")
		return _success(&"EQUIPMENT_MANAGEMENT_STARTED", "Actual GĐ2 management is active")
	loot_session = candidate_loot
	equipment_session = candidate
	_sync_loot_to_match()
	_capture_loot_snapshots()
	round_state.equipment_management_snapshot = equipment_session.to_dict()
	return _success(&"PLAYER_CONFIRMED", "Waiting for remaining players")


func transferred_round_loot_items(player_id: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if loot_session == null:
		return result
	var state: RoundLootInventoryState = loot_session.find_round_loot_state(player_id)
	if state != null:
		result.assign(state.transferred_items.duplicate(true))
	return result


func grant_and_equip_test_relic() -> Dictionary:
	var player: PlayerPhaseState = _current_management_player()
	if player == null or _equipment_definitions.is_empty():
		return _failure(&"MANAGEMENT_PLAYER_MISSING", "Current management player is required")
	var definition: EquipmentDefinition = _equipment_definitions[0]
	var instance: EquipmentInstance = _equipment_service.grant(player, definition, &"M4_RUNTIME")
	if instance == null:
		return _failure(&"EQUIPMENT_GRANT_FAILED", "Actual Equipment service rejected grant")
	var equipped: EquipmentActionResult = _equipment_service.equip(player, instance.instance_id)
	if equipped == null or not equipped.success:
		return _failure(&"EQUIPMENT_EQUIP_FAILED", "Actual Equipment service rejected equip")
	_capture_management_snapshot()
	return _success(&"EQUIPMENT_EQUIPPED", String(instance.instance_id))


func find_management_equipment_definition(
	definition_id: StringName
) -> EquipmentDefinition:
	return _equipment_service.find_definition(_equipment_definitions, definition_id)


func management_equipment_progression_state(instance_id: StringName) -> Dictionary:
	var player: PlayerPhaseState = _current_management_player()
	if player == null:
		return _failure(&"MANAGEMENT_PLAYER_MISSING", "Current management player is required")
	var instance: EquipmentInstance = _equipment_service.find_instance(player, instance_id)
	var definition: EquipmentDefinition = (
		_equipment_service.find_definition(_equipment_definitions, instance.equipment_definition_id)
		if instance != null
		else null
	)
	return _progression_service.progression_state(player, instance, definition)


func upgrade_owned_equipment_gold(instance_id: StringName) -> Dictionary:
	var player: PlayerPhaseState = _current_management_player()
	if player == null:
		return _failure(&"MANAGEMENT_PLAYER_MISSING", "Current management player is required")
	var instance: EquipmentInstance = _equipment_service.find_instance(player, instance_id)
	var definition: EquipmentDefinition = (
		_equipment_service.find_definition(_equipment_definitions, instance.equipment_definition_id)
		if instance != null
		else null
	)
	var result: EquipmentActionResult = _progression_service.upgrade_gold_one(
		player, instance, definition, equipment_session
	)
	if result == null or not result.success:
		return _failure(
			result.code if result != null else &"GOLD_RESULT_MISSING",
			"Gold upgrade failed"
		)
	_capture_management_snapshot()
	return _success(&"GOLD_UPGRADED", str(instance.gold_star_level))


func upgrade_owned_equipment_purple(
	instance_id: StringName, duplicate_instance_id: StringName
) -> Dictionary:
	var player: PlayerPhaseState = _current_management_player()
	if player == null:
		return _failure(&"MANAGEMENT_PLAYER_MISSING", "Current management player is required")
	var target: EquipmentInstance = _equipment_service.find_instance(player, instance_id)
	var duplicate: EquipmentInstance = _equipment_service.find_instance(
		player, duplicate_instance_id
	)
	var definition: EquipmentDefinition = (
		_equipment_service.find_definition(_equipment_definitions, target.equipment_definition_id)
		if target != null
		else null
	)
	var result: EquipmentActionResult = _progression_service.upgrade_purple(
		player, target, duplicate, definition, equipment_session
	)
	if result == null or not result.success:
		return _failure(
			result.code if result != null else &"PURPLE_RESULT_MISSING",
			"Purple promotion failed"
		)
	_capture_management_snapshot()
	return _success(&"PURPLE_PROMOTED", str(target.purple_star_level))


func equip_owned_equipment(instance_id: StringName, slot_id: StringName) -> Dictionary:
	var player: PlayerPhaseState = _current_management_player()
	if player == null:
		return _failure(&"MANAGEMENT_PLAYER_MISSING", "Current management player is required")
	var result: EquipmentActionResult = _equipment_service.equip_to_slot(
		player, instance_id, slot_id
	)
	if result == null or not result.success:
		return _failure(
			result.code if result != null else &"EQUIPMENT_ACTION_MISSING",
			"Owned Equipment cannot be equipped in this slot"
		)
	_capture_management_snapshot()
	return _success(&"EQUIPMENT_EQUIPPED", String(result.instance_id))


func unequip_equipment_slot(slot_id: StringName) -> Dictionary:
	var player: PlayerPhaseState = _current_management_player()
	if player == null:
		return _failure(&"MANAGEMENT_PLAYER_MISSING", "Current management player is required")
	var result: EquipmentActionResult = _equipment_service.unequip_slot(player, slot_id)
	if result == null or not result.success:
		return _failure(
			result.code if result != null else &"EQUIPMENT_ACTION_MISSING",
			"Equipment slot cannot be cleared"
		)
	_capture_management_snapshot()
	return _success(&"EQUIPMENT_UNEQUIPPED", String(result.instance_id))


func grant_and_equip_test_set() -> Dictionary:
	var player: PlayerPhaseState = _current_management_player()
	if player == null:
		return _failure(&"MANAGEMENT_PLAYER_MISSING", "Current management player is required")
	for definition_id: StringName in [
		&"m5_s_relic_featured", &"m5_s_stig_a", &"m5_s_stig_b", &"m5_s_stig_c"
	]:
		var definition: EquipmentDefinition = _equipment_service.find_definition(
			_equipment_definitions, definition_id
		)
		var instance: EquipmentInstance = _equipment_service.grant(
			player, definition, &"M4_RUNTIME_SET"
		)
		var equipped: EquipmentActionResult = _equipment_service.equip(
			player, instance.instance_id
		)
		if equipped == null or not equipped.success:
			return _failure(&"TEST_SET_EQUIP_FAILED", String(definition_id))
	_capture_management_snapshot()
	return _success(&"TEST_SET_EQUIPPED", "Relic and Stigmata A/B/C equipped")


func unequip_relic() -> Dictionary:
	var player: PlayerPhaseState = _current_management_player()
	if player == null or player.relic_instance_id.is_empty():
		return _failure(&"EQUIPPED_RELIC_REQUIRED", "Equip a Relic first")
	var instance_id: StringName = player.relic_instance_id
	if not _equipment_service.unequip(player, instance_id):
		return _failure(&"UNEQUIP_REJECTED", String(instance_id))
	_capture_management_snapshot()
	return _success(&"RELIC_UNEQUIPPED", String(instance_id))


func basic_gacha_roll() -> Dictionary:
	var player: PlayerPhaseState = _current_management_player()
	if player == null:
		return _failure(&"MANAGEMENT_PLAYER_MISSING", "Current management player is required")
	if player.gacha_ticket_count < 1:
		return _failure(&"INSUFFICIENT_TICKETS", "Current player needs one Ticket")
	var result: GachaRollResult = _gacha_service.basic_roll(
		equipment_session,
		player,
		_equipment_definitions,
		SEQUENCE_GACHA_ROLL_SOURCE.new([10, 0])
	)
	if result == null or not result.success:
		return _failure(result.code if result != null else &"GACHA_RESULT_MISSING", "Basic roll failed")
	_capture_management_snapshot()
	return _success(&"BASIC_GACHA_APPLIED", String(result.result_category))


func rate_up_gacha_roll() -> Dictionary:
	var player: PlayerPhaseState = _current_management_player()
	if player == null or _gacha_config == null:
		return _failure(&"RATE_UP_CONTEXT_MISSING", "Current player and config are required")
	var featured: Array[StringName] = [
		&"m5_s_relic_featured", &"m5_s_stig_a", &"m5_s_stig_b", &"m5_s_stig_c"
	]
	var result: GachaRollResult = _gacha_service.rate_up_roll(
		equipment_session,
		player,
		_equipment_definitions,
		featured,
		_gacha_config,
		SEQUENCE_GACHA_ROLL_SOURCE.new([95, 20])
	)
	if result == null or not result.success:
		return _failure(result.code if result != null else &"RATE_UP_RESULT_MISSING", "Rate Up failed")
	_capture_management_snapshot()
	return _success(&"RATE_UP_APPLIED", String(result.equipment_definition_id))


func perfect_gacha_spin() -> Dictionary:
	var player: PlayerPhaseState = _current_management_player()
	if player == null:
		return _failure(&"MANAGEMENT_PLAYER_MISSING", "Current management player is required")
	var result: GachaRollResult = _gacha_service.perfect_spin(
		equipment_session,
		player,
		_perfect_entries,
		SEQUENCE_GACHA_ROLL_SOURCE.new([1])
	)
	if result == null or not result.success:
		return _failure(result.code if result != null else &"PERFECT_RESULT_MISSING", "Perfect spin failed")
	_capture_management_snapshot()
	return _success(&"PERFECT_APPLIED", String(result.perfect_entry_id))


func resolve_pending_choice(definition_id: StringName = &"") -> Dictionary:
	var player: PlayerPhaseState = _current_management_player()
	if player == null or not equipment_session.pending_choice.is_active():
		return _failure(&"PENDING_CHOICE_MISSING", "No current-player choice is pending")
	if equipment_session.pending_choice.player_id != player.player_id:
		return _failure(&"PENDING_CHOICE_PLAYER_MISMATCH", "Pending choice belongs to another player")
	var eligible: Array[StringName] = equipment_session.pending_choice.eligible_definition_ids
	if eligible.is_empty():
		return _failure(&"PENDING_CHOICE_EMPTY", "Pending choice has no eligible definition")
	if definition_id.is_empty():
		return _failure(&"PENDING_CHOICE_SELECTION_REQUIRED", "Choose one eligible reward")
	if not eligible.has(definition_id):
		return _failure(&"PENDING_CHOICE_REJECTED", String(definition_id))
	var instance: EquipmentInstance = _gacha_service.claim_choice(
		equipment_session, player, definition_id, _equipment_definitions
	)
	if instance == null:
		return _failure(&"PENDING_CHOICE_REJECTED", String(definition_id))
	_capture_management_snapshot()
	return _success(&"PENDING_CHOICE_RESOLVED", String(instance.instance_id))


func purchase_first_unlocked_ss() -> Dictionary:
	var player: PlayerPhaseState = _current_management_player()
	if player == null:
		return _failure(&"SS_SHOP_CONTEXT_MISSING", "Current management player is required")
	if player.gacha_state.ss_unlocked_equipment_ids.is_empty():
		return _failure(&"SS_SHOP_NO_UNLOCKED_EQUIPMENT", "No SS Equipment is unlocked")
	var definition: EquipmentDefinition = _first_unlocked_ss_definition(player)
	if definition == null:
		return _failure(&"SS_SHOP_DEFINITION_NOT_FOUND", "Unlocked SS definition was not found")
	var purchase: Dictionary = _gacha_service.purchase_ss_checked(equipment_session, player, definition)
	if not bool(purchase.get("success", false)):
		return _failure(
			StringName(String(purchase.get("code", &"SS_SHOP_PURCHASE_REJECTED"))),
			String(purchase.get("message", "SS Shop purchase rejected"))
		)
	var instance_value: Variant = purchase.get("instance")
	var instance: EquipmentInstance = instance_value as EquipmentInstance
	if instance == null:
		return _failure(&"SS_SHOP_GRANT_FAILED", "SS Shop did not return an Equipment instance")
	_capture_management_snapshot()
	return _success(&"SS_PURCHASED", String(instance.instance_id))


func can_purchase_first_unlocked_ss() -> bool:
	var player: PlayerPhaseState = _current_management_player()
	if player == null or player.gacha_state.ss_unlocked_equipment_ids.is_empty():
		return false
	return _first_unlocked_ss_definition(player) != null


func ss_shop_eligibility_diagnostic() -> Dictionary:
	var player: PlayerPhaseState = _current_management_player()
	if player == null:
		return {
			"eligible_ss_count": 0,
			"selected_definition_id": "",
			"resolved_definition": false,
			"session_phase": -1,
		}
	var eligible_count: int = 0
	for unlocked_id: StringName in player.gacha_state.ss_unlocked_equipment_ids:
		var candidate: EquipmentDefinition = _equipment_service.find_definition(
			_equipment_definitions, unlocked_id
		)
		if candidate != null and candidate.tier == EQUIPMENT_ENUMS.Tier.SS:
			eligible_count += 1
	var selected_id: StringName = (
		player.gacha_state.ss_unlocked_equipment_ids[0]
		if not player.gacha_state.ss_unlocked_equipment_ids.is_empty()
		else &""
	)
	return {
		"eligible_ss_count": eligible_count,
		"selected_definition_id": String(selected_id),
		"resolved_definition": _first_unlocked_ss_definition(player) != null,
		"session_phase": equipment_session.phase if equipment_session != null else -1,
	}


func _first_unlocked_ss_definition(player: PlayerPhaseState) -> EquipmentDefinition:
	for unlocked_id: StringName in player.gacha_state.ss_unlocked_equipment_ids:
		var definition: EquipmentDefinition = _equipment_service.find_definition(
			_equipment_definitions, unlocked_id
		)
		if definition != null and definition.tier == EQUIPMENT_ENUMS.Tier.SS:
			return definition
	return null


func upgrade_equipped_relic_gold() -> Dictionary:
	var player: PlayerPhaseState = _current_management_player()
	if player == null or player.relic_instance_id.is_empty():
		return _failure(&"EQUIPPED_RELIC_REQUIRED", "Equip a Relic first")
	var instance: EquipmentInstance = _equipment_service.find_instance(
		player, player.relic_instance_id
	)
	var definition: EquipmentDefinition = (
		_equipment_service.find_definition(_equipment_definitions, instance.equipment_definition_id)
		if instance != null
		else null
	)
	var result: EquipmentActionResult = _progression_service.upgrade_gold_one(
		player, instance, definition, equipment_session
	)
	if result == null or not result.success:
		return _failure(result.code if result != null else &"GOLD_RESULT_MISSING", "Gold upgrade failed")
	_capture_management_snapshot()
	return _success(&"GOLD_UPGRADED", str(instance.gold_star_level))


func promote_equipped_relic_purple() -> Dictionary:
	var player: PlayerPhaseState = _current_management_player()
	if player == null or player.relic_instance_id.is_empty():
		return _failure(&"EQUIPPED_RELIC_REQUIRED", "Equip a Relic first")
	var target: EquipmentInstance = _equipment_service.find_instance(
		player, player.relic_instance_id
	)
	var definition: EquipmentDefinition = (
		_equipment_service.find_definition(_equipment_definitions, target.equipment_definition_id)
		if target != null
		else null
	)
	if target == null or definition == null:
		return _failure(&"PURPLE_TARGET_INVALID", "Authored Equipment definition is required")
	var duplicate: EquipmentInstance = _equipment_service.grant(
		player, definition, &"M4_RUNTIME_DUPLICATE"
	)
	var result: EquipmentActionResult = _progression_service.upgrade_purple(
		player, target, duplicate, definition, equipment_session
	)
	if result == null or not result.success:
		if duplicate != null and player.equipment_collection.has(duplicate):
			player.equipment_collection.erase(duplicate)
		return _failure(
			result.code if result != null else &"PURPLE_RESULT_MISSING",
			"Purple promotion failed"
		)
	_capture_management_snapshot()
	return _success(&"PURPLE_PROMOTED", str(target.purple_star_level))


func mark_management_done(player_id: StringName) -> Dictionary:
	if equipment_session == null:
		return _failure(&"MANAGEMENT_SESSION_MISSING", "Management session is required")
	if equipment_session.done_player_ids.has(player_id):
		return _failure(&"PLAYER_ALREADY_DONE", "Management completion is idempotent", true)
	if equipment_session.pending_choice.is_active():
		return _failure(&"PENDING_CHOICE", "Resolve pending Equipment choice first")
	if not _end_service.mark_management_done(equipment_session, player_id):
		return _failure(&"MANAGEMENT_DONE_REJECTED", "Only the current player may mark done")
	_capture_management_snapshot()
	if equipment_session.phase == EQUIPMENT_SESSION.Phase.READY_FOR_M6:
		round_state.round_completion_flags["management_complete"] = true
		checkpoints["management_complete"] = _serializer.round_trip_diagnostic(
			match_state, round_state
		)
		return _success(&"MANAGEMENT_COMPLETE", "Round End validation is ready")
	return _success(&"PLAYER_MANAGEMENT_DONE", "Pass device to the next player")


func commit_round_end(commit_id: StringName = ROUND_END_COMMIT_ID) -> Dictionary:
	if _round_end_committed or match_state.applied_commit_ids.has(commit_id):
		return _failure(&"ROUND_END_ALREADY_APPLIED", "Round End commit is a no-op", true)

	var readiness: Dictionary = _validate_round_end_readiness(commit_id)
	if not bool(readiness.get("success", false)):
		return readiness

	var candidate_management: EQUIPMENT_SESSION = EQUIPMENT_SESSION.from_dict(
		equipment_session.to_dict()
	)
	_apply_perfect_round_end_policy(candidate_management)

	var candidate_match: M4_MVP_MATCH_STATE = M4_MVP_MATCH_STATE.from_dict(
		match_state.to_dict()
	)

	for source: PlayerPhaseState in candidate_management.players:
		var target: M4_PLAYER_MATCH_STATE = candidate_match.find_player(source.player_id)
		var merged: Dictionary = _loot_adapter.merge_player(target, source)
		if not bool(merged.get("success", false)):
			return _failure(
				&"ROUND_END_MERGE_INVALID",
				String(merged.get("code", "merge failed"))
			)

	var report: MVP_VALIDATION_REPORT = MATCH_VALIDATOR.new().validate(candidate_match)
	if not report.passed():
		return _failure(&"ROUND_END_MATCH_INVALID", ", ".join(report.codes()))

	var candidate_round: M4_MVP_ROUND_STATE = M4_MVP_ROUND_STATE.from_dict(
		round_state.to_dict()
	)
	candidate_round.phase = M4_MVP_ENUMS.Phase.ROUND_END
	_set_completion_flags(candidate_round)

	var round_report: MVP_VALIDATION_REPORT = ROUND_VALIDATOR.new().validate(candidate_round)
	if not round_report.passed():
		return _failure(&"ROUND_END_ROUND_INVALID", ", ".join(round_report.codes()))

	_apply_perfect_round_end_policy(equipment_session)

	for source: PlayerPhaseState in equipment_session.players:
		var target: M4_PLAYER_MATCH_STATE = match_state.find_player(source.player_id)
		_loot_adapter.merge_player(target, source)

	_sync_round_end_flags()
	checkpoints["pre_round_end"] = _serializer.round_trip_diagnostic(match_state, round_state)

	var transition: M4_TRANSITION_RESULT = _orchestrator.transition(
		M4_MVP_ENUMS.Phase.ROUND_END
	)
	if not transition.success:
		return _transition_failure(transition)

	var round_before: int = match_state.current_round_number

	var committed: M4_TRANSITION_RESULT = _orchestrator.commit_round_end(commit_id)
	if not committed.success:
		return _transition_failure(committed)

	_round_end_committed = true
	round_state.round_end_commit_id = commit_id
	round_state.round_completion_flags["active_round_cleared"] = true

	var match_end: Dictionary = _evaluate_match_end()
	match_state.match_completion_state = StringName(match_end.get(
		"status",
		&"NEXT_CASE_REQUIRED"
	))

	checkpoints["post_round_end"] = _serializer.round_trip_diagnostic(
		match_state, round_state
	)

	round_end_summary = {
		"commit_id": String(commit_id),
		"round_before": round_before,
		"round_after": match_state.current_round_number,
		"status": String(match_state.match_completion_state),
		"winner_player_id": String(match_end.get("winner_player_id", &"")),
		"active_round_cleared": _orchestrator.active_round == null,
	}

	event_log.append(
		"Round End committed exactly once; Match End evaluated as %s"
		% String(match_state.match_completion_state)
	)

	if match_state.match_completion_state == &"MATCH_COMPLETE":
		return _success(
			&"MATCH_COMPLETE",
			"Match complete; winner is %s"
			% String(match_end.get("winner_player_id", &""))
		)

	if match_state.match_completion_state == &"OVERTIME":
		return _success(
			&"OVERTIME",
			"Round complete; Match requires overtime"
		)

	return _success(
		&"NEXT_CASE_REQUIRED",
		"Round complete; next Case is required"
	)


func _validate_round_end_readiness(commit_id: StringName) -> Dictionary:
	if commit_id.is_empty():
		return _failure(&"ROUND_END_COMMIT_MISSING", "Round End commit ID is required")
	if match_state.current_phase != M4_MVP_ENUMS.Phase.EQUIPMENT_MANAGEMENT:
		return _failure(&"ROUND_END_PHASE_INVALID", "Equipment Management phase is required")
	if equipment_session == null or equipment_session.phase != EQUIPMENT_SESSION.Phase.READY_FOR_M6:
		return _failure(&"MANAGEMENT_INCOMPLETE", "Every player must mark management done")
	if equipment_session.pending_choice.is_active():
		return _failure(&"PENDING_CHOICE", "Resolve pending Equipment choice first")
	return _success(&"ROUND_END_READY", "Persistent merge candidate may be built")


func _sync_round_end_flags() -> void:
	_set_completion_flags(round_state)


func _set_completion_flags(target_round: M4_MVP_ROUND_STATE) -> void:
	target_round.round_completion_flags["movement_complete"] = (
		loot_session != null
		and loot_session.movement_session != null
		and loot_session.movement_session.all_exhausted()
	)
	target_round.round_completion_flags["reward_complete"] = (
		loot_session != null
		and not loot_session.overflow.active
		and loot_session.pending_trace_index >= loot_session.pending_trace.size()
	)
	target_round.round_completion_flags["management_complete"] = true
	target_round.round_completion_flags["pending_overflow"] = false
	target_round.round_completion_flags["pending_choice"] = false
	target_round.round_completion_flags["pending_reward"] = false


func _capture_management_snapshot() -> void:
	if equipment_session != null:
		round_state.equipment_management_snapshot = equipment_session.to_dict()


func _apply_perfect_round_end_policy(management: EQUIPMENT_SESSION) -> void:
	var policy_id: String = String(
		match_state.open_policy_config_ids.get("perfect_round_end", "")
	)
	for player: PlayerPhaseState in management.players:
		if policy_id == PERFECT_POLICY_ID:
			player.gacha_state.perfect_pool_remaining_hits = (
				management.perfect_remaining_hits.duplicate(true)
			)
		else:
			player.gacha_state.perfect_pool_remaining_hits.clear()


func _current_management_player() -> PlayerPhaseState:
	if (
		equipment_session == null
		or equipment_session.phase != EQUIPMENT_SESSION.Phase.EQUIPMENT_MANAGEMENT
	):
		return null
	return equipment_session.find_player(equipment_session.current_player_id())


func _evaluate_match_end() -> Dictionary:
	return _match_completion_service.apply_after_round_settlement(match_state)
