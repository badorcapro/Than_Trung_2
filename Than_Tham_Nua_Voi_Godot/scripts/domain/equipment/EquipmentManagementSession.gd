class_name EquipmentManagementSession
extends RefCounted

enum Phase { LOOT_END_CONFIRMATION, EQUIPMENT_MANAGEMENT, READY_FOR_M6 }
var schema_version := 1
var phase := Phase.LOOT_END_CONFIRMATION
var round_id: StringName
var player_order: Array[StringName] = []
var current_player_index := 0
var confirmed_player_ids: Array[StringName] = []
var done_player_ids: Array[StringName] = []
var players: Array[PlayerPhaseState] = []
var pending_choice := PendingEquipmentChoice.new()
var perfect_remaining_hits: Dictionary = {}
var progression_history: Array[Dictionary] = []
var gacha_history: Array[Dictionary] = []
var test_ss_shop_currency_by_player: Dictionary = {}

func find_player(player_id: StringName) -> PlayerPhaseState:
	for player: PlayerPhaseState in players:
		if player.player_id == player_id: return player
	return null
func current_player_id() -> StringName:
	return player_order[current_player_index] if not player_order.is_empty() else &""
func to_dict() -> Dictionary:
	var order: Array[String] = []
	for id: StringName in player_order: order.append(String(id))
	var confirmed: Array[String] = []
	for id: StringName in confirmed_player_ids: confirmed.append(String(id))
	var done: Array[String] = []
	for id: StringName in done_player_ids: done.append(String(id))
	var player_rows: Array[Dictionary] = []
	for player: PlayerPhaseState in players: player_rows.append(player.to_persistent_dict())
	return {"schema_version":schema_version,"phase":phase,"round_id":String(round_id),"player_order":order,"current_player_index":current_player_index,"confirmed_player_ids":confirmed,"done_player_ids":done,"players":player_rows,"pending_choice":pending_choice.to_dict(),"perfect_remaining_hits":_normalize_int_dictionary(perfect_remaining_hits),"progression_history":_normalize_history_rows(progression_history),"gacha_history":_normalize_history_rows(gacha_history),"test_ss_shop_currency_by_player":_normalize_int_dictionary(test_ss_shop_currency_by_player)}
static func from_dict(data: Dictionary) -> EquipmentManagementSession:
	var result := EquipmentManagementSession.new(); result.schema_version=int(data.get("schema_version",1)); result.phase=int(data.get("phase",0)); result.round_id=StringName(data.get("round_id","")); result.current_player_index=int(data.get("current_player_index",0))
	var order: Variant=data.get("player_order",[])
	if order is Array:
		for value: Variant in order: result.player_order.append(StringName(value))
	var confirmed: Variant=data.get("confirmed_player_ids",[])
	if confirmed is Array:
		for value: Variant in confirmed: result.confirmed_player_ids.append(StringName(value))
	var done: Variant=data.get("done_player_ids",[])
	if done is Array:
		for value: Variant in done: result.done_player_ids.append(StringName(value))
	var player_rows: Variant=data.get("players",[])
	if player_rows is Array:
		for value: Variant in player_rows:
			if value is Dictionary: result.players.append(PlayerPhaseState.from_persistent_dict(value))
	var choice: Variant=data.get("pending_choice",{})
	if choice is Dictionary: result.pending_choice=PendingEquipmentChoice.from_dict(choice)
	var remaining: Variant=data.get("perfect_remaining_hits",{})
	if remaining is Dictionary:
		for key: Variant in remaining.keys(): result.perfect_remaining_hits[String(key)]=int(remaining.get(key,0))
	var currency: Variant=data.get("test_ss_shop_currency_by_player",{})
	if currency is Dictionary:
		for key: Variant in currency.keys(): result.test_ss_shop_currency_by_player[String(key)]=int(currency.get(key,0))
	result.progression_history=_normalize_history_rows(data.get("progression_history",[]))
	result.gacha_history=_normalize_history_rows(data.get("gacha_history",[]))
	return result
func semantically_equals(other: EquipmentManagementSession) -> bool: return other != null and to_dict()==other.to_dict()

static func _normalize_int_dictionary(source: Dictionary)->Dictionary:
	var result:Dictionary={}
	for key:Variant in source.keys():result[String(key)]=int(source.get(key,0))
	return result

static func _normalize_history_rows(source:Variant)->Array[Dictionary]:
	var result:Array[Dictionary]=[]
	if not source is Array:return result
	var integer_fields:Array[String]=["gold_level","purple_level","material_delta","ticket_cost","resource_amount","pity_before","pity_after","exchange_material_delta"]
	var boolean_fields:Array[String]=["success"]
	for row_value:Variant in source:
		if not row_value is Dictionary:continue
		var row:Dictionary={}
		for key_value:Variant in row_value.keys():
			var key:=String(key_value);var value:Variant=row_value.get(key_value)
			if integer_fields.has(key):row[key]=int(value)
			elif boolean_fields.has(key):row[key]=bool(value)
			elif value is StringName:row[key]=String(value)
			else:row[key]=value
		result.append(row)
	return result
