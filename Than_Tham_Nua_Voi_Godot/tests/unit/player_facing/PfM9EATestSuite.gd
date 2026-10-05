class_name PfM9EATestSuite
extends RefCounted

const ROUND_COMPLETION_SESSION := preload(
	"res://scripts/application/mvp/MvpIntegratedRoundCompletionSession.gd"
)
const GACHA_SERVICE := preload("res://scripts/application/economy/GachaService.gd")
const FIXTURES := preload("res://scripts/application/loot/Gd2FixtureRepository.gd")
const MANAGEMENT_SESSION := preload(
	"res://scripts/domain/equipment/EquipmentManagementSession.gd"
)
const MVP_ROUND_STATE := preload("res://scripts/domain/mvp/MvpRoundState.gd")
const PLAYER_STATE := preload("res://scripts/domain/characters/PlayerPhaseState.gd")
const SEQUENCE_GACHA_ROLL_SOURCE := preload(
	"res://scripts/infrastructure/SequenceGachaRollSource.gd"
)
const PLAYER_SCENE := preload("res://scenes/player_facing/PlayerFacingStart.tscn")

var _definitions: Array[EquipmentDefinition] = []
var _entries: Array[PerfectPoolEntry] = []


func run() -> Array[Dictionary]:
	_definitions = FIXTURES.load_m5_equipment_definitions()
	_entries = FIXTURES.load_m5_perfect_entries()
	var rows: Array[Dictionary] = []
	_add(rows, "PF-M9E-A Perfect multi-choice enters player-facing pending state", _pending_state_exists())
	_add(rows, "PF-M9E-A Perfect payment commits before choice without granting", _payment_commits_without_grant())
	_add(rows, "PF-M9E-A player may select a non-first Perfect reward", _non_first_choice_resolves())
	_add(rows, "PF-M9E-A confirmed non-first reward is the granted definition", _non_first_definition_is_granted())
	_add(rows, "PF-M9E-A Perfect confirmation grants exactly one reward", _exactly_one_reward_is_granted())
	_add(rows, "PF-M9E-A Perfect pending state clears after confirmation", _pending_clears())
	_add(rows, "PF-M9E-A unresolved Perfect choice blocks management completion", _pending_blocks_completion())
	_add(rows, "PF-M9E-A second Perfect roll is blocked while choice is pending", _pending_blocks_second_spin())
	_add(rows, "PF-M9E-A Perfect pending choice is isolated to its player", _pending_is_player_isolated())
	_add(rows, "PF-M9E-A Basic Gacha remains unchanged", _basic_gacha_unchanged())
	_add(rows, "PF-M9E-A Rate Up Gacha remains unchanged", _rate_up_gacha_unchanged())
	_add(rows, "PF-M9E-A confirmed reward is immediately in the owned collection", _collection_refresh_source_is_current())
	_add(rows, "PF-M9E-A invalid and stale choices reject without duplicate grant", _invalid_and_stale_choices_reject())
	_add(rows, "PF-M9E-A pending choice round-trip preserves committed state", _pending_round_trip_preserves_state())
	return rows


func _pending_state_exists() -> bool:
	var fixture: Dictionary = _spun_fixture()
	var management: MANAGEMENT_SESSION = fixture.get("management") as MANAGEMENT_SESSION
	var spin: Dictionary = fixture.get("spin") as Dictionary
	var root: Node = PLAYER_SCENE.instantiate()
	var passed: bool = (
		bool(spin.get("success", false))
		and management.pending_choice.is_active()
		and management.pending_choice.eligible_definition_ids.size() > 1
		and root.find_child("PerfectChoicePanel", true, false) is Control
		and root.find_child("PerfectChoiceSelector", true, false) is OptionButton
		and root.find_child("ResolveChoice", true, false) is Button
	)
	root.free()
	return passed


func _payment_commits_without_grant() -> bool:
	var fixture: Dictionary = _spun_fixture()
	var player: PLAYER_STATE = fixture.get("first") as PLAYER_STATE
	var management: MANAGEMENT_SESSION = fixture.get("management") as MANAGEMENT_SESSION
	return (
		player.gacha_ticket_count == 8
		and player.equipment_collection.is_empty()
		and management.pending_choice.is_active()
		and int(management.perfect_remaining_hits.get("core_ss_stigmata_choice", 0)) == 2
	)


func _non_first_choice_resolves() -> bool:
	var fixture: Dictionary = _spun_fixture()
	var flow: ROUND_COMPLETION_SESSION = fixture.get("flow") as ROUND_COMPLETION_SESSION
	var management: MANAGEMENT_SESSION = fixture.get("management") as MANAGEMENT_SESSION
	var selected_id: StringName = management.pending_choice.eligible_definition_ids[1]
	return bool(flow.resolve_pending_choice(selected_id).get("success", false))


func _non_first_definition_is_granted() -> bool:
	var fixture: Dictionary = _spun_fixture()
	var flow: ROUND_COMPLETION_SESSION = fixture.get("flow") as ROUND_COMPLETION_SESSION
	var player: PLAYER_STATE = fixture.get("first") as PLAYER_STATE
	var management: MANAGEMENT_SESSION = fixture.get("management") as MANAGEMENT_SESSION
	var selected_id: StringName = management.pending_choice.eligible_definition_ids[1]
	var result: Dictionary = flow.resolve_pending_choice(selected_id)
	return (
		bool(result.get("success", false))
		and player.equipment_collection.size() == 1
		and player.equipment_collection[0].equipment_definition_id == selected_id
	)


func _exactly_one_reward_is_granted() -> bool:
	var fixture: Dictionary = _spun_fixture()
	var flow: ROUND_COMPLETION_SESSION = fixture.get("flow") as ROUND_COMPLETION_SESSION
	var player: PLAYER_STATE = fixture.get("first") as PLAYER_STATE
	var management: MANAGEMENT_SESSION = fixture.get("management") as MANAGEMENT_SESSION
	var selected_id: StringName = management.pending_choice.eligible_definition_ids[2]
	var first: Dictionary = flow.resolve_pending_choice(selected_id)
	var second: Dictionary = flow.resolve_pending_choice(selected_id)
	return (
		bool(first.get("success", false))
		and not bool(second.get("success", false))
		and player.equipment_collection.size() == 1
	)


func _pending_clears() -> bool:
	var fixture: Dictionary = _spun_fixture()
	var flow: ROUND_COMPLETION_SESSION = fixture.get("flow") as ROUND_COMPLETION_SESSION
	var management: MANAGEMENT_SESSION = fixture.get("management") as MANAGEMENT_SESSION
	var selected_id: StringName = management.pending_choice.eligible_definition_ids[1]
	flow.resolve_pending_choice(selected_id)
	return not management.pending_choice.is_active()


func _pending_blocks_completion() -> bool:
	var fixture: Dictionary = _spun_fixture()
	var flow: ROUND_COMPLETION_SESSION = fixture.get("flow") as ROUND_COMPLETION_SESSION
	var first: PLAYER_STATE = fixture.get("first") as PLAYER_STATE
	var result: Dictionary = flow.mark_management_done(first.player_id)
	return not bool(result.get("success", false)) and result.get("code") == &"PENDING_CHOICE"


func _pending_blocks_second_spin() -> bool:
	var fixture: Dictionary = _spun_fixture()
	var flow: ROUND_COMPLETION_SESSION = fixture.get("flow") as ROUND_COMPLETION_SESSION
	var result: Dictionary = flow.perfect_gacha_spin()
	return not bool(result.get("success", false)) and result.get("code") == &"CHOICE_PENDING"


func _pending_is_player_isolated() -> bool:
	var fixture: Dictionary = _spun_fixture()
	var flow: ROUND_COMPLETION_SESSION = fixture.get("flow") as ROUND_COMPLETION_SESSION
	var first: PLAYER_STATE = fixture.get("first") as PLAYER_STATE
	var second: PLAYER_STATE = fixture.get("second") as PLAYER_STATE
	var management: MANAGEMENT_SESSION = fixture.get("management") as MANAGEMENT_SESSION
	var selected_id: StringName = management.pending_choice.eligible_definition_ids[1]
	management.current_player_index = 1
	var result: Dictionary = flow.resolve_pending_choice(selected_id)
	return (
		not bool(result.get("success", false))
		and result.get("code") == &"PENDING_CHOICE_PLAYER_MISMATCH"
		and first.equipment_collection.is_empty()
		and second.equipment_collection.is_empty()
		and management.pending_choice.is_active()
	)


func _basic_gacha_unchanged() -> bool:
	var management: MANAGEMENT_SESSION = _management()
	var player: PLAYER_STATE = management.players[0]
	var result: GachaRollResult = GACHA_SERVICE.new().basic_roll(
		management, player, _definitions, SEQUENCE_GACHA_ROLL_SOURCE.new([10, 0])
	)
	return result.success and not management.pending_choice.is_active()


func _rate_up_gacha_unchanged() -> bool:
	var management: MANAGEMENT_SESSION = _management()
	var player: PLAYER_STATE = management.players[0]
	var featured: Array[StringName] = [
		&"m5_s_relic_featured", &"m5_s_stig_a", &"m5_s_stig_b", &"m5_s_stig_c"
	]
	var result: GachaRollResult = GACHA_SERVICE.new().rate_up_roll(
		management,
		player,
		_definitions,
		featured,
		FIXTURES.load_m5_gacha_config(),
		SEQUENCE_GACHA_ROLL_SOURCE.new([95, 20])
	)
	return result.success and not management.pending_choice.is_active()


func _collection_refresh_source_is_current() -> bool:
	var fixture: Dictionary = _spun_fixture()
	var flow: ROUND_COMPLETION_SESSION = fixture.get("flow") as ROUND_COMPLETION_SESSION
	var player: PLAYER_STATE = fixture.get("first") as PLAYER_STATE
	var management: MANAGEMENT_SESSION = fixture.get("management") as MANAGEMENT_SESSION
	var selected_id: StringName = management.pending_choice.eligible_definition_ids[1]
	flow.resolve_pending_choice(selected_id)
	return (
		player.equipment_collection.size() == 1
		and player.equipment_collection[0].owner_player_id == player.player_id
		and player.equipment_collection[0].equipment_definition_id == selected_id
	)


func _invalid_and_stale_choices_reject() -> bool:
	var fixture: Dictionary = _spun_fixture()
	var flow: ROUND_COMPLETION_SESSION = fixture.get("flow") as ROUND_COMPLETION_SESSION
	var player: PLAYER_STATE = fixture.get("first") as PLAYER_STATE
	var management: MANAGEMENT_SESSION = fixture.get("management") as MANAGEMENT_SESSION
	var selected_id: StringName = management.pending_choice.eligible_definition_ids[1]
	var invalid: Dictionary = flow.resolve_pending_choice(&"not_eligible")
	var valid: Dictionary = flow.resolve_pending_choice(selected_id)
	var stale: Dictionary = flow.resolve_pending_choice(selected_id)
	return (
		not bool(invalid.get("success", false))
		and bool(valid.get("success", false))
		and not bool(stale.get("success", false))
		and player.equipment_collection.size() == 1
	)


func _pending_round_trip_preserves_state() -> bool:
	var fixture: Dictionary = _spun_fixture()
	var flow: ROUND_COMPLETION_SESSION = fixture.get("flow") as ROUND_COMPLETION_SESSION
	var management: MANAGEMENT_SESSION = fixture.get("management") as MANAGEMENT_SESSION
	var first: PLAYER_STATE = fixture.get("first") as PLAYER_STATE
	var restored: MANAGEMENT_SESSION = MANAGEMENT_SESSION.from_dict(
		flow.round_state.equipment_management_snapshot
	)
	var restored_player: PLAYER_STATE = restored.find_player(first.player_id)
	return (
		restored.pending_choice.is_active()
		and restored.pending_choice.player_id == first.player_id
		and restored.pending_choice.eligible_definition_ids == management.pending_choice.eligible_definition_ids
		and restored_player != null
		and restored_player.gacha_ticket_count == 8
		and restored_player.equipment_collection.is_empty()
		and restored.perfect_remaining_hits == management.perfect_remaining_hits
	)


func _spun_fixture() -> Dictionary:
	var management: MANAGEMENT_SESSION = _management()
	var flow: ROUND_COMPLETION_SESSION = ROUND_COMPLETION_SESSION.new()
	flow.round_state = MVP_ROUND_STATE.new()
	flow.equipment_session = management
	flow._equipment_definitions = _definitions
	flow._perfect_entries = _entries
	var spin: Dictionary = flow.perfect_gacha_spin()
	return {
		"flow": flow,
		"management": management,
		"first": management.players[0],
		"second": management.players[1],
		"spin": spin,
	}


func _management() -> MANAGEMENT_SESSION:
	var management: MANAGEMENT_SESSION = MANAGEMENT_SESSION.new()
	management.phase = MANAGEMENT_SESSION.Phase.EQUIPMENT_MANAGEMENT
	for player_id: StringName in [&"player_1", &"player_2"]:
		var player: PLAYER_STATE = PLAYER_STATE.new()
		player.player_id = player_id
		player.gacha_ticket_count = 10
		management.players.append(player)
		management.player_order.append(player_id)
	return management


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "PF-M9E-A Perfect Gacha player-choice invariant",
	})
