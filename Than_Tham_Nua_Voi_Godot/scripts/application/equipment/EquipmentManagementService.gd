class_name EquipmentManagementService
extends RefCounted

const SLOT_RELIC := &"RELIC"
const SLOT_STIGMATA_A := &"STIGMATA_A"
const SLOT_STIGMATA_B := &"STIGMATA_B"
const SLOT_STIGMATA_C := &"STIGMATA_C"

var next_instance_number := 1

func grant(player: PlayerPhaseState, definition: EquipmentDefinition, source: StringName) -> EquipmentInstance:
	if player==null or definition==null: return null
	var instance:=EquipmentInstance.new()
	var candidate_id: StringName = StringName(
		"%s_%d" % [definition.equipment_definition_id, next_instance_number]
	)
	while find_instance(player,candidate_id)!=null:
		next_instance_number+=1
		candidate_id = StringName(
			"%s_%d" % [definition.equipment_definition_id, next_instance_number]
		)
	instance.instance_id=candidate_id; next_instance_number+=1
	instance.equipment_definition_id=definition.equipment_definition_id; instance.owner_player_id=player.player_id; instance.acquired_source=source; instance.equipment_type=definition.equipment_type; instance.stigmata_slot=definition.stigmata_slot; instance.tier=definition.tier
	player.equipment_collection.append(instance); return instance

func find_instance(player: PlayerPhaseState, instance_id: StringName) -> EquipmentInstance:
	if player==null:return null
	for instance: EquipmentInstance in player.equipment_collection:
		if instance.instance_id==instance_id:return instance
	return null

func equip(player: PlayerPhaseState, instance_id: StringName) -> EquipmentActionResult:
	var instance:=find_instance(player,instance_id)
	if instance==null or instance.owner_player_id!=player.player_id:return EquipmentActionResult.make(false,&"NOT_OWNED",instance_id)
	match instance.equipment_type:
		EquipmentEnums.EquipmentType.RELIC: player.relic_instance_id=instance_id
		EquipmentEnums.EquipmentType.STIGMATA:
			match instance.stigmata_slot:
				EquipmentEnums.StigmataSlot.A: player.stigmata_a_instance_id=instance_id
				EquipmentEnums.StigmataSlot.B: player.stigmata_b_instance_id=instance_id
				EquipmentEnums.StigmataSlot.C: player.stigmata_c_instance_id=instance_id
				_: return EquipmentActionResult.make(false,&"WRONG_SLOT",instance_id)
	return EquipmentActionResult.make(true,&"EQUIPPED",instance_id)

func equip_to_slot(
	player: PlayerPhaseState, instance_id: StringName, slot_id: StringName
) -> EquipmentActionResult:
	var instance := find_instance(player, instance_id)
	if instance == null or instance.owner_player_id != player.player_id:
		return EquipmentActionResult.make(false, &"NOT_OWNED", instance_id)
	if slot_id_for_instance(instance) != slot_id:
		return EquipmentActionResult.make(false, &"WRONG_SLOT", instance_id)
	return equip(player, instance_id)

func unequip_slot(player: PlayerPhaseState, slot_id: StringName) -> EquipmentActionResult:
	if player == null:
		return EquipmentActionResult.make(false, &"PLAYER_MISSING")
	var instance_id: StringName = equipped_instance_id(player, slot_id)
	if instance_id.is_empty():
		return EquipmentActionResult.make(false, &"SLOT_EMPTY")
	if not unequip(player, instance_id):
		return EquipmentActionResult.make(false, &"UNEQUIP_REJECTED", instance_id)
	return EquipmentActionResult.make(true, &"UNEQUIPPED", instance_id)

func equipped_instance_id(player: PlayerPhaseState, slot_id: StringName) -> StringName:
	if player == null:
		return &""
	match slot_id:
		SLOT_RELIC:
			return player.relic_instance_id
		SLOT_STIGMATA_A:
			return player.stigmata_a_instance_id
		SLOT_STIGMATA_B:
			return player.stigmata_b_instance_id
		SLOT_STIGMATA_C:
			return player.stigmata_c_instance_id
	return &""

func slot_id_for_instance(instance: EquipmentInstance) -> StringName:
	if instance == null:
		return &""
	if instance.equipment_type == EquipmentEnums.EquipmentType.RELIC:
		return SLOT_RELIC
	if instance.equipment_type != EquipmentEnums.EquipmentType.STIGMATA:
		return &""
	match instance.stigmata_slot:
		EquipmentEnums.StigmataSlot.A:
			return SLOT_STIGMATA_A
		EquipmentEnums.StigmataSlot.B:
			return SLOT_STIGMATA_B
		EquipmentEnums.StigmataSlot.C:
			return SLOT_STIGMATA_C
	return &""

func unequip(player: PlayerPhaseState, instance_id: StringName) -> bool:
	if player.relic_instance_id==instance_id:player.relic_instance_id=&"";return true
	if player.stigmata_a_instance_id==instance_id:player.stigmata_a_instance_id=&"";return true
	if player.stigmata_b_instance_id==instance_id:player.stigmata_b_instance_id=&"";return true
	if player.stigmata_c_instance_id==instance_id:player.stigmata_c_instance_id=&"";return true
	return false

func set_passive_active(player: PlayerPhaseState, definitions: Array[EquipmentDefinition]) -> bool:
	var ids:Array[StringName]=[player.stigmata_a_instance_id,player.stigmata_b_instance_id,player.stigmata_c_instance_id]
	var set_id:StringName
	for id:StringName in ids:
		var instance:=find_instance(player,id)
		if instance==null:return false
		var definition:=find_definition(definitions,instance.equipment_definition_id)
		if definition==null or definition.set_id.is_empty():return false
		if set_id.is_empty():set_id=definition.set_id
		elif set_id!=definition.set_id:return false
	return true

func find_definition(definitions:Array[EquipmentDefinition],definition_id:StringName)->EquipmentDefinition:
	for definition:EquipmentDefinition in definitions:
		if definition.equipment_definition_id==definition_id:return definition
	return null
