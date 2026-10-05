class_name PfM9BTestSuite
extends RefCounted

const EQUIPMENT_SERVICE := preload(
	"res://scripts/application/equipment/EquipmentManagementService.gd"
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

var _service: EQUIPMENT_SERVICE = EQUIPMENT_SERVICE.new()
var _definitions: Array[EquipmentDefinition] = []


func run() -> Array[Dictionary]:
	_definitions = FIXTURES.load_m5_equipment_definitions()
	var rows: Array[Dictionary] = []
	_add(rows, "PF-M9B collection is isolated to current player", _collection_is_player_owned())
	_add(rows, "PF-M9B owned Relic equips to Relic slot", _owned_relic_equips())
	_add(rows, "PF-M9B owned Stigmata equips to authored slot", _owned_stigmata_equips())
	_add(rows, "PF-M9B replacement preserves both owned instances", _replacement_preserves_collection())
	_add(rows, "PF-M9B unequip preserves collection ownership", _unequip_preserves_collection())
	_add(rows, "PF-M9B loadout survives Round End merge projection", _loadout_persists())
	_add(rows, "PF-M9B Player 1 loadout cannot affect Player 2", _cross_player_action_rejected())
	_add(rows, "PF-M9B Gacha grant enters same player collection", _gacha_grant_is_visible())
	_add(rows, "PF-M9B invalid item and slot operations reject", _invalid_operations_reject())
	_add(rows, "PF-M9B normal UI uses collection workflow without test grant", _collection_ui_exists())
	return rows


func _collection_is_player_owned() -> bool:
	var session: MANAGEMENT_SESSION = MANAGEMENT_SESSION.new()
	var first: PLAYER_STATE = _player(&"p1")
	var second: PLAYER_STATE = _player(&"p2")
	_service.grant(first, _definition(&"m5_a_relic"), &"TEST")
	_service.grant(second, _definition(&"m5_s_relic_other"), &"TEST")
	session.players.append(first)
	session.players.append(second)
	session.player_order.append(&"p1")
	session.player_order.append(&"p2")
	var current: PLAYER_STATE = session.find_player(session.current_player_id())
	return (
		current == first
		and current.equipment_collection.size() == 1
		and current.equipment_collection[0].owner_player_id == &"p1"
		and current.equipment_collection[0].equipment_definition_id == &"m5_a_relic"
	)


func _owned_relic_equips() -> bool:
	var player: PLAYER_STATE = _player()
	var relic: EquipmentInstance = _service.grant(
		player, _definition(&"m5_a_relic"), &"TEST"
	)
	var result: EquipmentActionResult = _service.equip_to_slot(
		player, relic.instance_id, EQUIPMENT_SERVICE.SLOT_RELIC
	)
	return result.success and player.relic_instance_id == relic.instance_id


func _owned_stigmata_equips() -> bool:
	var player: PLAYER_STATE = _player()
	var stigmata: EquipmentInstance = _service.grant(
		player, _definition(&"m5_a_stig_b"), &"TEST"
	)
	var result: EquipmentActionResult = _service.equip_to_slot(
		player, stigmata.instance_id, EQUIPMENT_SERVICE.SLOT_STIGMATA_B
	)
	return result.success and player.stigmata_b_instance_id == stigmata.instance_id


func _replacement_preserves_collection() -> bool:
	var player: PLAYER_STATE = _player()
	var first: EquipmentInstance = _service.grant(
		player, _definition(&"m5_a_relic"), &"TEST"
	)
	var replacement: EquipmentInstance = _service.grant(
		player, _definition(&"m5_s_relic_other"), &"TEST"
	)
	_service.equip_to_slot(player, first.instance_id, EQUIPMENT_SERVICE.SLOT_RELIC)
	var result: EquipmentActionResult = _service.equip_to_slot(
		player, replacement.instance_id, EQUIPMENT_SERVICE.SLOT_RELIC
	)
	return (
		result.success
		and player.relic_instance_id == replacement.instance_id
		and _service.find_instance(player, first.instance_id) == first
		and _service.find_instance(player, replacement.instance_id) == replacement
		and player.equipment_collection.size() == 2
	)


func _unequip_preserves_collection() -> bool:
	var player: PLAYER_STATE = _player()
	var stigmata: EquipmentInstance = _service.grant(
		player, _definition(&"m5_a_stig_a"), &"TEST"
	)
	_service.equip_to_slot(player, stigmata.instance_id, EQUIPMENT_SERVICE.SLOT_STIGMATA_A)
	var result: EquipmentActionResult = _service.unequip_slot(
		player, EQUIPMENT_SERVICE.SLOT_STIGMATA_A
	)
	return (
		result.success
		and player.stigmata_a_instance_id.is_empty()
		and _service.find_instance(player, stigmata.instance_id) == stigmata
	)


func _loadout_persists() -> bool:
	var managed: PLAYER_STATE = _player()
	var relic: EquipmentInstance = _service.grant(
		managed, _definition(&"m5_a_relic"), &"TEST"
	)
	_service.equip_to_slot(managed, relic.instance_id, EQUIPMENT_SERVICE.SLOT_RELIC)
	var persistent: PLAYER_MATCH_STATE = PLAYER_MATCH_STATE.new()
	persistent.player_id = managed.player_id
	var adapter: LOOT_ADAPTER = LOOT_ADAPTER.new()
	var merged: Dictionary = adapter.merge_player(persistent, managed)
	var next_round: PLAYER_STATE = adapter.project_player(persistent, &"round_2")
	return (
		bool(merged.get("success", false))
		and next_round.relic_instance_id == relic.instance_id
		and next_round.equipment_collection.size() == 1
		and next_round.equipment_collection[0].owner_player_id == managed.player_id
	)


func _cross_player_action_rejected() -> bool:
	var first: PLAYER_STATE = _player(&"p1")
	var second: PLAYER_STATE = _player(&"p2")
	var relic: EquipmentInstance = _service.grant(
		first, _definition(&"m5_a_relic"), &"TEST"
	)
	var result: EquipmentActionResult = _service.equip_to_slot(
		second, relic.instance_id, EQUIPMENT_SERVICE.SLOT_RELIC
	)
	return (
		not result.success
		and result.code == &"NOT_OWNED"
		and first.relic_instance_id.is_empty()
		and second.relic_instance_id.is_empty()
	)


func _gacha_grant_is_visible() -> bool:
	var session: MANAGEMENT_SESSION = MANAGEMENT_SESSION.new()
	var player: PLAYER_STATE = _player()
	player.gacha_ticket_count = 1
	session.players.append(player)
	session.player_order.append(player.player_id)
	session.phase = MANAGEMENT_SESSION.Phase.EQUIPMENT_MANAGEMENT
	var result: GachaRollResult = GACHA_SERVICE.new().basic_roll(
		session,
		player,
		_definitions,
		SEQUENCE_GACHA_ROLL_SOURCE.new([70, 0])
	)
	return (
		result.success
		and not result.equipment_definition_id.is_empty()
		and player.equipment_collection.size() == 1
		and player.equipment_collection[0].owner_player_id == player.player_id
	)


func _invalid_operations_reject() -> bool:
	var player: PLAYER_STATE = _player()
	var relic: EquipmentInstance = _service.grant(
		player, _definition(&"m5_a_relic"), &"TEST"
	)
	var wrong_slot: EquipmentActionResult = _service.equip_to_slot(
		player, relic.instance_id, EQUIPMENT_SERVICE.SLOT_STIGMATA_A
	)
	var missing: EquipmentActionResult = _service.equip_to_slot(
		player, &"missing", EQUIPMENT_SERVICE.SLOT_RELIC
	)
	var invalid_player: EquipmentActionResult = _service.equip_to_slot(
		null, relic.instance_id, EQUIPMENT_SERVICE.SLOT_RELIC
	)
	return (
		wrong_slot.code == &"WRONG_SLOT"
		and missing.code == &"NOT_OWNED"
		and invalid_player.code == &"NOT_OWNED"
		and player.relic_instance_id.is_empty()
		and player.stigmata_a_instance_id.is_empty()
	)


func _collection_ui_exists() -> bool:
	var root: Node = PLAYER_SCENE.instantiate()
	var passed: bool = (
		root.find_child("EquipmentSlotSelector", true, false) is OptionButton
		and root.find_child("OwnedEquipmentSelector", true, false) is OptionButton
		and root.find_child("EquipSelectedEquipment", true, false) is Button
		and root.find_child("UnequipSelectedSlot", true, false) is Button
		and root.find_child("GrantRelic", true, false) == null
	)
	root.free()
	return passed


func _player(player_id: StringName = &"p1") -> PLAYER_STATE:
	var player: PLAYER_STATE = PLAYER_STATE.new()
	player.player_id = player_id
	return player


func _definition(definition_id: StringName) -> EquipmentDefinition:
	return _service.find_definition(_definitions, definition_id)


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "PF-M9B Equipment collection and loadout invariant",
	})
