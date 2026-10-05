class_name EquipmentProgressionService
extends RefCounted

const GOLD_CAP := 6
const PURPLE_CAP := 6


func progression_state(
	player: PlayerPhaseState,
	instance: EquipmentInstance,
	definition: EquipmentDefinition
) -> Dictionary:
	if player == null or instance == null or definition == null:
		return {"success": false, "code": &"INVALID_TARGET"}
	if instance.owner_player_id != player.player_id or player.equipment_collection.find(instance) < 0:
		return {"success": false, "code": &"TARGET_NOT_OWNED"}

	var duplicate_ids: Array[StringName] = []
	for candidate: EquipmentInstance in player.equipment_collection:
		if (
			candidate != null
			and candidate != instance
			and candidate.instance_id != instance.instance_id
			and candidate.owner_player_id == player.player_id
			and candidate.equipment_definition_id == instance.equipment_definition_id
			and not _is_equipped(player, candidate.instance_id)
		):
			duplicate_ids.append(candidate.instance_id)

	var gold_cost: int = (
		definition.gold_cost(instance.gold_star_level)
		if instance.gold_star_level < GOLD_CAP
		else -1
	)
	var purple_next_level: int = instance.purple_star_level + 1
	var next_purple_cost: int = (
		purple_cost(purple_next_level, definition)
		if purple_next_level <= PURPLE_CAP
		else -1
	)
	var gold_code: StringName = &"AVAILABLE"
	if instance.gold_star_level >= GOLD_CAP:
		gold_code = &"GOLD_MAX"
	elif gold_cost < 0:
		gold_code = &"COST_MISSING"
	elif player.equipment_exp_material_count < gold_cost:
		gold_code = &"INSUFFICIENT_EXP"
	var purple_code: StringName = &"AVAILABLE"
	if purple_next_level > PURPLE_CAP:
		purple_code = &"PURPLE_MAX"
	elif instance.gold_star_level < purple_next_level:
		purple_code = &"GOLD_PREREQUISITE"
	elif duplicate_ids.is_empty():
		purple_code = &"DUPLICATE_REQUIRED"
	elif next_purple_cost < 0:
		purple_code = &"PURPLE_COST_INVALID"
	elif player.equipment_exp_material_count < next_purple_cost:
		purple_code = &"INSUFFICIENT_EXP"
	return {
		"success": true,
		"code": &"OK",
		"instance_id": instance.instance_id,
		"definition_id": definition.equipment_definition_id,
		"display_name": definition.display_name,
		"tier": instance.tier,
		"gold_level": instance.gold_star_level,
		"gold_cap": GOLD_CAP,
		"gold_next_cost": gold_cost,
		"gold_code": gold_code,
		"can_upgrade_gold": gold_code == &"AVAILABLE",
		"purple_level": instance.purple_star_level,
		"purple_cap": PURPLE_CAP,
		"purple_next_cost": next_purple_cost,
		"purple_code": purple_code,
		"can_upgrade_purple": purple_code == &"AVAILABLE",
		"duplicate_instance_ids": duplicate_ids,
		"exp_material_count": player.equipment_exp_material_count,
		"is_equipped": _is_equipped(player, instance.instance_id),
	}

func upgrade_gold_one(player:PlayerPhaseState,instance:EquipmentInstance,definition:EquipmentDefinition,session:EquipmentManagementSession=null)->EquipmentActionResult:
	if player==null or instance==null or definition==null:return EquipmentActionResult.make(false,&"INVALID_TARGET")
	if instance.owner_player_id!=player.player_id or player.equipment_collection.find(instance)<0:return EquipmentActionResult.make(false,&"TARGET_NOT_OWNED",instance.instance_id)
	if instance.gold_star_level>=GOLD_CAP:return EquipmentActionResult.make(false,&"GOLD_MAX",instance.instance_id)
	var cost:int=definition.gold_cost(instance.gold_star_level)
	if cost<0:return EquipmentActionResult.make(false,&"COST_MISSING",instance.instance_id)
	if player.equipment_exp_material_count<cost:return EquipmentActionResult.make(false,&"INSUFFICIENT_EXP",instance.instance_id)
	player.equipment_exp_material_count-=cost;instance.gold_star_level+=1
	var result:=EquipmentActionResult.make(true,&"GOLD_UPGRADED",instance.instance_id);result.material_delta=-cost
	if session!=null:session.progression_history.append({"code":String(result.code),"player_id":String(player.player_id),"instance_id":String(instance.instance_id),"gold_level":instance.gold_star_level,"material_delta":result.material_delta})
	return result

func upgrade_gold_max(player:PlayerPhaseState,instance:EquipmentInstance,definition:EquipmentDefinition,session:EquipmentManagementSession=null)->int:
	var levels:=0
	while instance.gold_star_level<GOLD_CAP:
		var result:=upgrade_gold_one(player,instance,definition,session)
		if not result.success:break
		levels+=1
	return levels

func purple_cost(target_level:int,definition:EquipmentDefinition)->int:
	if target_level<1 or target_level>PURPLE_CAP:return -1
	if target_level<=5:return int(floor(float(definition.gold_cost(target_level))*0.5))
	var p5_cost:int=int(floor(float(definition.gold_cost(5))*0.5));return int(floor(float(p5_cost)*1.5))

func upgrade_purple(player:PlayerPhaseState,target:EquipmentInstance,duplicate:EquipmentInstance,definition:EquipmentDefinition,session:EquipmentManagementSession=null)->EquipmentActionResult:
	if player==null or target==null or duplicate==null or definition==null:return EquipmentActionResult.make(false,&"INVALID_TARGET")
	var next_level:int=target.purple_star_level+1
	if next_level>PURPLE_CAP:return EquipmentActionResult.make(false,&"PURPLE_MAX",target.instance_id)
	if target.gold_star_level<next_level:return EquipmentActionResult.make(false,&"GOLD_PREREQUISITE",target.instance_id)
	if target.owner_player_id!=player.player_id or player.equipment_collection.find(target)<0:return EquipmentActionResult.make(false,&"TARGET_NOT_OWNED",target.instance_id)
	if duplicate==target or duplicate.instance_id==target.instance_id:return EquipmentActionResult.make(false,&"TARGET_IS_DUPLICATE",target.instance_id)
	if duplicate.equipment_definition_id!=target.equipment_definition_id:return EquipmentActionResult.make(false,&"WRONG_DUPLICATE",target.instance_id)
	if duplicate.owner_player_id!=player.player_id:return EquipmentActionResult.make(false,&"DUPLICATE_NOT_OWNED",target.instance_id)
	if _is_equipped(player,duplicate.instance_id):return EquipmentActionResult.make(false,&"DUPLICATE_EQUIPPED",target.instance_id)
	var duplicate_index:int=player.equipment_collection.find(duplicate)
	if duplicate_index<0:return EquipmentActionResult.make(false,&"DUPLICATE_NOT_OWNED",target.instance_id)
	var cost:int=purple_cost(next_level,definition)
	if cost<0:return EquipmentActionResult.make(false,&"PURPLE_COST_INVALID",target.instance_id)
	if player.equipment_exp_material_count<cost:return EquipmentActionResult.make(false,&"INSUFFICIENT_EXP",target.instance_id)
	player.equipment_exp_material_count-=cost;player.equipment_collection.remove_at(duplicate_index);target.purple_star_level=next_level
	var result:=EquipmentActionResult.make(true,&"PURPLE_SKILL_MILESTONE" if next_level%2==0 else &"PURPLE_STAT_MILESTONE",target.instance_id);result.material_delta=-cost;result.duplicate_consumed_id=duplicate.instance_id
	if session!=null:session.progression_history.append({"code":String(result.code),"player_id":String(player.player_id),"instance_id":String(target.instance_id),"purple_level":target.purple_star_level,"duplicate_consumed_id":String(duplicate.instance_id),"material_delta":result.material_delta})
	return result


func _is_equipped(player: PlayerPhaseState, instance_id: StringName) -> bool:
	return (
		player != null
		and not instance_id.is_empty()
		and instance_id in [
			player.relic_instance_id,
			player.stigmata_a_instance_id,
			player.stigmata_b_instance_id,
			player.stigmata_c_instance_id,
		]
	)
