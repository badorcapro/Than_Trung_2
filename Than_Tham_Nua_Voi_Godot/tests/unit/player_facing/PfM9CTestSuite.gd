class_name PfM9CTestSuite
extends RefCounted

const EQUIPMENT_SERVICE := preload(
	"res://scripts/application/equipment/EquipmentManagementService.gd"
)
const PROGRESSION_SERVICE := preload(
	"res://scripts/application/equipment/EquipmentProgressionService.gd"
)
const GACHA_SERVICE := preload("res://scripts/application/economy/GachaService.gd")
const FIXTURES := preload("res://scripts/application/loot/Gd2FixtureRepository.gd")
const LOOT_ADAPTER := preload("res://scripts/application/mvp/LootSliceAdapter.gd")
const PLAYER_STATE := preload("res://scripts/domain/characters/PlayerPhaseState.gd")
const PLAYER_MATCH_STATE := preload("res://scripts/domain/mvp/PlayerMatchState.gd")
const MANAGEMENT_SESSION := preload(
	"res://scripts/domain/equipment/EquipmentManagementSession.gd"
)
const SEQUENCE_GACHA_ROLL_SOURCE := preload(
	"res://scripts/infrastructure/SequenceGachaRollSource.gd"
)
const PLAYER_SCENE := preload("res://scenes/player_facing/PlayerFacingStart.tscn")

var _equipment: EQUIPMENT_SERVICE = EQUIPMENT_SERVICE.new()
var _progression: PROGRESSION_SERVICE = PROGRESSION_SERVICE.new()
var _definitions: Array[EquipmentDefinition] = []


func run() -> Array[Dictionary]:
	_definitions = FIXTURES.load_m5_equipment_definitions()
	var rows: Array[Dictionary] = []
	_add(rows, "PF-M9C selected owned item exposes progression state", _state_is_visible())
	_add(rows, "PF-M9C valid Gold progression uses authority", _gold_succeeds())
	_add(rows, "PF-M9C valid Purple progression uses authority", _purple_succeeds())
	_add(rows, "PF-M9C material cost is consumed exactly once", _material_consumed_once())
	_add(rows, "PF-M9C duplicate cost is consumed exactly once", _duplicate_consumed_once())
	_add(rows, "PF-M9C failed progression consumes nothing", _failed_action_is_atomic())
	_add(rows, "PF-M9C maxed item cannot progress", _max_rejects())
	_add(rows, "PF-M9C equipped item remains equipped", _equipped_reference_survives())
	_add(rows, "PF-M9C progression survives persistent Round projection", _progression_persists())
	_add(rows, "PF-M9C progression is isolated by player", _players_are_isolated())
	_add(rows, "PF-M9C PF-M9B loadout operations remain valid", _loadout_still_works())
	_add(rows, "PF-M9C Gacha material and duplicate refresh progression state", _gacha_rewards_are_visible())
	return rows


func _state_is_visible() -> bool:
	var player: PLAYER_STATE = _player()
	var definition: EquipmentDefinition = _definition(&"m5_a_relic")
	var target: EquipmentInstance = _equipment.grant(player, definition, &"TEST")
	var duplicate: EquipmentInstance = _equipment.grant(player, definition, &"TEST")
	var equipped_duplicate: EquipmentInstance = _equipment.grant(player, definition, &"TEST")
	_equipment.equip_to_slot(
		player, equipped_duplicate.instance_id, EQUIPMENT_SERVICE.SLOT_RELIC
	)
	player.equipment_exp_material_count = 20
	var state: Dictionary = _progression.progression_state(player, target, definition)
	var root: Node = PLAYER_SCENE.instantiate()
	var passed: bool = (
		bool(state.get("success", false))
		and String(state.get("display_name", "")) == definition.display_name
		and int(state.get("gold_level", 0)) == 1
		and int(state.get("gold_cap", 0)) == 6
		and int(state.get("gold_next_cost", -1)) == 11
		and int(state.get("purple_level", -1)) == 0
		and int(state.get("purple_cap", 0)) == 6
		and int(state.get("purple_next_cost", -1)) == 5
		and (state.get("duplicate_instance_ids", []) as Array).has(duplicate.instance_id)
		and not (state.get("duplicate_instance_ids", []) as Array).has(target.instance_id)
		and not (state.get("duplicate_instance_ids", []) as Array).has(equipped_duplicate.instance_id)
		and root.find_child("EquipmentProgressionLabel", true, false) is Label
		and root.find_child("PurpleDuplicateSelector", true, false) is OptionButton
		and root.find_child("UpgradeEquipmentGold", true, false) is Button
		and root.find_child("UpgradeEquipmentPurple", true, false) is Button
	)
	root.free()
	return passed


func _gold_succeeds() -> bool:
	var player: PLAYER_STATE = _player()
	var definition: EquipmentDefinition = _definition(&"m5_a_relic")
	var target: EquipmentInstance = _equipment.grant(player, definition, &"TEST")
	player.equipment_exp_material_count = 20
	var result: EquipmentActionResult = _progression.upgrade_gold_one(
		player, target, definition
	)
	return result.success and result.code == &"GOLD_UPGRADED" and target.gold_star_level == 2


func _purple_succeeds() -> bool:
	var fixture: Dictionary = _purple_fixture()
	var player: PLAYER_STATE = fixture.get("player") as PLAYER_STATE
	var target: EquipmentInstance = fixture.get("target") as EquipmentInstance
	var duplicate: EquipmentInstance = fixture.get("duplicate") as EquipmentInstance
	var definition: EquipmentDefinition = fixture.get("definition") as EquipmentDefinition
	var result: EquipmentActionResult = _progression.upgrade_purple(
		player, target, duplicate, definition
	)
	return result.success and target.purple_star_level == 1


func _material_consumed_once() -> bool:
	var fixture: Dictionary = _purple_fixture()
	var player: PLAYER_STATE = fixture.get("player") as PLAYER_STATE
	var target: EquipmentInstance = fixture.get("target") as EquipmentInstance
	var duplicate: EquipmentInstance = fixture.get("duplicate") as EquipmentInstance
	var definition: EquipmentDefinition = fixture.get("definition") as EquipmentDefinition
	var before: int = player.equipment_exp_material_count
	var expected_cost: int = _progression.purple_cost(1, definition)
	var result: EquipmentActionResult = _progression.upgrade_purple(
		player, target, duplicate, definition
	)
	return (
		result.success
		and result.material_delta == -expected_cost
		and player.equipment_exp_material_count == before - expected_cost
	)


func _duplicate_consumed_once() -> bool:
	var fixture: Dictionary = _purple_fixture()
	var player: PLAYER_STATE = fixture.get("player") as PLAYER_STATE
	var target: EquipmentInstance = fixture.get("target") as EquipmentInstance
	var duplicate: EquipmentInstance = fixture.get("duplicate") as EquipmentInstance
	var definition: EquipmentDefinition = fixture.get("definition") as EquipmentDefinition
	var before: int = player.equipment_collection.size()
	var duplicate_id: StringName = duplicate.instance_id
	var result: EquipmentActionResult = _progression.upgrade_purple(
		player, target, duplicate, definition
	)
	return (
		result.success
		and result.duplicate_consumed_id == duplicate_id
		and player.equipment_collection.size() == before - 1
		and _equipment.find_instance(player, duplicate_id) == null
		and _equipment.find_instance(player, target.instance_id) == target
	)


func _failed_action_is_atomic() -> bool:
	var fixture: Dictionary = _purple_fixture()
	var player: PLAYER_STATE = fixture.get("player") as PLAYER_STATE
	var target: EquipmentInstance = fixture.get("target") as EquipmentInstance
	var duplicate: EquipmentInstance = fixture.get("duplicate") as EquipmentInstance
	var definition: EquipmentDefinition = fixture.get("definition") as EquipmentDefinition
	player.equipment_exp_material_count = 0
	var before_count: int = player.equipment_collection.size()
	var result: EquipmentActionResult = _progression.upgrade_purple(
		player, target, duplicate, definition
	)
	return (
		not result.success
		and result.code == &"INSUFFICIENT_EXP"
		and player.equipment_exp_material_count == 0
		and player.equipment_collection.size() == before_count
		and target.purple_star_level == 0
	)


func _max_rejects() -> bool:
	var fixture: Dictionary = _purple_fixture()
	var player: PLAYER_STATE = fixture.get("player") as PLAYER_STATE
	var target: EquipmentInstance = fixture.get("target") as EquipmentInstance
	var duplicate: EquipmentInstance = fixture.get("duplicate") as EquipmentInstance
	var definition: EquipmentDefinition = fixture.get("definition") as EquipmentDefinition
	target.gold_star_level = 6
	target.purple_star_level = 6
	var gold_result: EquipmentActionResult = _progression.upgrade_gold_one(
		player, target, definition
	)
	var purple_result: EquipmentActionResult = _progression.upgrade_purple(
		player, target, duplicate, definition
	)
	return gold_result.code == &"GOLD_MAX" and purple_result.code == &"PURPLE_MAX"


func _equipped_reference_survives() -> bool:
	var fixture: Dictionary = _purple_fixture()
	var player: PLAYER_STATE = fixture.get("player") as PLAYER_STATE
	var target: EquipmentInstance = fixture.get("target") as EquipmentInstance
	var duplicate: EquipmentInstance = fixture.get("duplicate") as EquipmentInstance
	var definition: EquipmentDefinition = fixture.get("definition") as EquipmentDefinition
	_equipment.equip_to_slot(player, target.instance_id, EQUIPMENT_SERVICE.SLOT_RELIC)
	var gold_result: EquipmentActionResult = _progression.upgrade_gold_one(
		player, target, definition
	)
	var purple_result: EquipmentActionResult = _progression.upgrade_purple(
		player, target, duplicate, definition
	)
	return (
		gold_result.success
		and purple_result.success
		and player.relic_instance_id == target.instance_id
	)


func _progression_persists() -> bool:
	var managed: PLAYER_STATE = _player()
	var definition: EquipmentDefinition = _definition(&"m5_a_relic")
	var target: EquipmentInstance = _equipment.grant(managed, definition, &"TEST")
	var duplicate: EquipmentInstance = _equipment.grant(managed, definition, &"TEST")
	managed.equipment_exp_material_count = 30
	_equipment.equip_to_slot(managed, target.instance_id, EQUIPMENT_SERVICE.SLOT_RELIC)
	_progression.upgrade_gold_one(managed, target, definition)
	_progression.upgrade_purple(managed, target, duplicate, definition)
	var persistent: PLAYER_MATCH_STATE = PLAYER_MATCH_STATE.new()
	persistent.player_id = managed.player_id
	var adapter: LOOT_ADAPTER = LOOT_ADAPTER.new()
	var merged: Dictionary = adapter.merge_player(persistent, managed)
	var next_round: PLAYER_STATE = adapter.project_player(persistent, &"round_2")
	var restored: EquipmentInstance = _equipment.find_instance(next_round, target.instance_id)
	return (
		bool(merged.get("success", false))
		and restored != null
		and restored.gold_star_level == 2
		and restored.purple_star_level == 1
		and next_round.relic_instance_id == target.instance_id
	)


func _players_are_isolated() -> bool:
	var first: PLAYER_STATE = _player(&"p1")
	var second: PLAYER_STATE = _player(&"p2")
	var definition: EquipmentDefinition = _definition(&"m5_a_relic")
	var target: EquipmentInstance = _equipment.grant(first, definition, &"TEST")
	var foreign_duplicate: EquipmentInstance = _equipment.grant(second, definition, &"TEST")
	first.equipment_exp_material_count = 20
	second.equipment_exp_material_count = 20
	var foreign_gold: EquipmentActionResult = _progression.upgrade_gold_one(
		second, target, definition
	)
	var foreign_purple: EquipmentActionResult = _progression.upgrade_purple(
		first, target, foreign_duplicate, definition
	)
	return (
		not foreign_gold.success
		and foreign_gold.code == &"TARGET_NOT_OWNED"
		and not foreign_purple.success
		and foreign_purple.code == &"DUPLICATE_NOT_OWNED"
		and target.gold_star_level == 1
		and first.equipment_exp_material_count == 20
		and second.equipment_exp_material_count == 20
		and second.equipment_collection.has(foreign_duplicate)
	)


func _loadout_still_works() -> bool:
	var player: PLAYER_STATE = _player()
	var definition: EquipmentDefinition = _definition(&"m5_a_relic")
	var first: EquipmentInstance = _equipment.grant(player, definition, &"TEST")
	var second: EquipmentInstance = _equipment.grant(player, definition, &"TEST")
	var equipped: EquipmentActionResult = _equipment.equip_to_slot(
		player, first.instance_id, EQUIPMENT_SERVICE.SLOT_RELIC
	)
	var replaced: EquipmentActionResult = _equipment.equip_to_slot(
		player, second.instance_id, EQUIPMENT_SERVICE.SLOT_RELIC
	)
	var unequipped: EquipmentActionResult = _equipment.unequip_slot(
		player, EQUIPMENT_SERVICE.SLOT_RELIC
	)
	return (
		equipped.success
		and replaced.success
		and unequipped.success
		and player.relic_instance_id.is_empty()
		and player.equipment_collection.size() == 2
	)


func _gacha_rewards_are_visible() -> bool:
	var player: PLAYER_STATE = _player()
	var definition: EquipmentDefinition = _definition(&"m5_a_relic")
	var target: EquipmentInstance = _equipment.grant(player, definition, &"TEST")
	player.gacha_ticket_count = 2
	var session: MANAGEMENT_SESSION = MANAGEMENT_SESSION.new()
	session.players.append(player)
	session.player_order.append(player.player_id)
	session.phase = MANAGEMENT_SESSION.Phase.EQUIPMENT_MANAGEMENT
	var resource_result: GachaRollResult = GACHA_SERVICE.new().basic_roll(
		session, player, _definitions, SEQUENCE_GACHA_ROLL_SOURCE.new([0])
	)
	var duplicate_result: GachaRollResult = GACHA_SERVICE.new().basic_roll(
		session, player, _definitions, SEQUENCE_GACHA_ROLL_SOURCE.new([70, 0])
	)
	var state: Dictionary = _progression.progression_state(player, target, definition)
	return (
		resource_result.success
		and resource_result.result_category == &"B"
		and duplicate_result.success
		and duplicate_result.equipment_definition_id == definition.equipment_definition_id
		and int(state.get("exp_material_count", 0)) == 5
		and not (state.get("duplicate_instance_ids", []) as Array).is_empty()
		and bool(state.get("can_upgrade_purple", false))
	)


func _purple_fixture() -> Dictionary:
	var player: PLAYER_STATE = _player()
	var definition: EquipmentDefinition = _definition(&"m5_a_relic")
	var target: EquipmentInstance = _equipment.grant(player, definition, &"TEST")
	var duplicate: EquipmentInstance = _equipment.grant(player, definition, &"TEST")
	player.equipment_exp_material_count = 20
	return {
		"player": player,
		"definition": definition,
		"target": target,
		"duplicate": duplicate,
	}


func _player(player_id: StringName = &"p1") -> PLAYER_STATE:
	var player: PLAYER_STATE = PLAYER_STATE.new()
	player.player_id = player_id
	return player


func _definition(definition_id: StringName) -> EquipmentDefinition:
	return _equipment.find_definition(_definitions, definition_id)


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "PF-M9C Equipment progression invariant",
	})
