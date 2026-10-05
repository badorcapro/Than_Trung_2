class_name GachaService
extends RefCounted

var equipment_service:=EquipmentManagementService.new()

func basic_roll(session:EquipmentManagementSession,player:PlayerPhaseState,definitions:Array[EquipmentDefinition],rng:SequenceGachaRollSource)->GachaRollResult:
	var result:=_result(player,&"basic",&"BASIC",1)
	if player.gacha_ticket_count<1:return _fail(result,&"INSUFFICIENT_TICKETS")
	player.gacha_ticket_count-=1;result.pity_before=player.gacha_state.consecutive_without_a_plus
	var roll:int=rng.next_percent();var category:StringName=&"B"
	if result.pity_before>=4:category=&"A" if roll<72 else &"S"
	elif roll>=90:category=&"S"
	elif roll>=65:category=&"A"
	result.result_category=category;player.equipment_exchange_material_count+=1;result.exchange_material_delta=1
	if category==&"B":player.equipment_exp_material_count+=5;result.resource_amount=5;player.gacha_state.consecutive_without_a_plus+=1
	else:
		player.gacha_state.consecutive_without_a_plus=0
		var pool:=_tier_pool(definitions,EquipmentEnums.Tier.A if category==&"A" else EquipmentEnums.Tier.S)
		if pool.is_empty():return _fail(result,&"POOL_EMPTY")
		var definition:EquipmentDefinition=pool[rng.next_percent()%pool.size()];var instance:=equipment_service.grant(player,definition,&"BASIC");result.equipment_definition_id=instance.equipment_definition_id
	result.pity_after=player.gacha_state.consecutive_without_a_plus;result.success=true;result.code=&"OK";session.gacha_history.append(result.to_dict());return result

func rate_up_roll(session:EquipmentManagementSession,player:PlayerPhaseState,definitions:Array[EquipmentDefinition],featured_ids:Array[StringName],config:GachaConfig,rng:SequenceGachaRollSource)->GachaRollResult:
	var result:=_result(player,&"rate_up_test",&"RATE_UP",1)
	if player.gacha_ticket_count<1:return _fail(result,&"INSUFFICIENT_TICKETS")
	player.gacha_ticket_count-=1;result.pity_before=player.gacha_state.rate_up_consecutive_without_a_plus
	var rarity_roll:int=rng.next_percent();var category:StringName=&"B"
	if result.pity_before>=4:category=&"A" if rarity_roll<72 else &"S"
	elif rarity_roll>=90:category=&"S"
	elif rarity_roll>=65:category=&"A"
	result.result_category=category
	if config.rate_up_grants_exchange_material:player.equipment_exchange_material_count+=1;result.exchange_material_delta=1
	if category==&"B":player.equipment_exp_material_count+=5;result.resource_amount=5;player.gacha_state.rate_up_consecutive_without_a_plus+=1
	else:
		player.gacha_state.rate_up_consecutive_without_a_plus=0
		var definition:EquipmentDefinition
		if category==&"A":
			var a_pool:=_tier_pool(definitions,EquipmentEnums.Tier.A)
			if not a_pool.is_empty():definition=a_pool[rng.next_percent()%a_pool.size()]
		else:
			var s_roll:int=rng.next_percent()
			if s_roll<80:
				var featured_index:int=0 if s_roll<14 else (1 if s_roll<36 else (2 if s_roll<58 else 3));definition=_find(definitions,featured_ids[featured_index])
			else:
				for candidate:EquipmentDefinition in _tier_pool(definitions,EquipmentEnums.Tier.S):
					if not featured_ids.has(candidate.equipment_definition_id):definition=candidate;break
		if definition==null:return _fail(result,&"POOL_EMPTY")
		var instance:=equipment_service.grant(player,definition,&"RATE_UP");result.equipment_definition_id=instance.equipment_definition_id
	result.pity_after=player.gacha_state.rate_up_consecutive_without_a_plus;result.success=true;result.code=&"OK";session.gacha_history.append(result.to_dict());return result

func initialize_perfect(session:EquipmentManagementSession,entries:Array[PerfectPoolEntry])->void:
	if not session.perfect_remaining_hits.is_empty():return
	for entry:PerfectPoolEntry in entries:session.perfect_remaining_hits[String(entry.entry_id)]=entry.initial_hits

func perfect_spin(session:EquipmentManagementSession,player:PlayerPhaseState,entries:Array[PerfectPoolEntry],rng:SequenceGachaRollSource)->GachaRollResult:
	var result:=_result(player,&"perfect_test",&"PERFECT",2)
	if player.gacha_ticket_count<2:return _fail(result,&"INSUFFICIENT_TICKETS")
	if session.pending_choice.is_active():return _fail(result,&"CHOICE_PENDING")
	initialize_perfect(session,entries)
	var available:Array[PerfectPoolEntry]=[];var total_weight:=0
	for entry:PerfectPoolEntry in entries:
		if int(session.perfect_remaining_hits.get(String(entry.entry_id),0))>0:available.append(entry);total_weight+=entry.weight
	if available.is_empty() or total_weight<=0:return _fail(result,&"POOL_EXHAUSTED")
	player.gacha_ticket_count-=2;var pick:int=rng.next_percent()%total_weight;var selected:PerfectPoolEntry
	for entry:PerfectPoolEntry in available:
		if pick<entry.weight:selected=entry;break
		pick-=entry.weight
	if selected==null:
		selected=available[available.size()-1]
	var key:=String(selected.entry_id);session.perfect_remaining_hits[key]=int(session.perfect_remaining_hits.get(key,0))-1;result.perfect_entry_id=selected.entry_id;result.result_category=StringName(PerfectPoolEntry.Kind.keys()[selected.kind]);result.resource_amount=selected.reward_amount_per_hit
	match selected.kind:
		PerfectPoolEntry.Kind.RESOURCE:_grant_resource(player,selected.resource_type,selected.reward_amount_per_hit)
		PerfectPoolEntry.Kind.SS_RELIC:
			var definition:=_find(Gd2FixtureRepository.load_m5_equipment_definitions(),selected.equipment_definition_id)
			var instance:=equipment_service.grant(player,definition,&"PERFECT");result.equipment_definition_id=instance.equipment_definition_id;_unlock_ss(player,instance.equipment_definition_id)
		PerfectPoolEntry.Kind.SS_STIGMATA_CHOICE,_:
			session.pending_choice.kind=PendingEquipmentChoice.Kind.SS_STIGMATA if selected.kind==PerfectPoolEntry.Kind.SS_STIGMATA_CHOICE else PendingEquipmentChoice.Kind.S_EQUIPMENT;session.pending_choice.player_id=player.player_id;session.pending_choice.source_entry_id=selected.entry_id;session.pending_choice.eligible_definition_ids=selected.eligible_definition_ids.duplicate()
	result.success=true;result.code=&"OK";session.gacha_history.append(result.to_dict());return result

func claim_choice(session:EquipmentManagementSession,player:PlayerPhaseState,definition_id:StringName,definitions:Array[EquipmentDefinition])->EquipmentInstance:
	if not session.pending_choice.is_active() or session.pending_choice.player_id!=player.player_id or not session.pending_choice.eligible_definition_ids.has(definition_id):return null
	var definition:=_find(definitions,definition_id)
	if definition==null:return null
	var instance:=equipment_service.grant(player,definition,&"PERFECT")
	if definition.tier==EquipmentEnums.Tier.SS:_unlock_ss(player,definition_id)
	session.pending_choice=PendingEquipmentChoice.new();return instance

func exchange_price(player:PlayerPhaseState,definition_id:StringName)->int:return 20+5*int(player.gacha_state.equipment_exchange_price_by_definition.get(String(definition_id),0))
func exchange(player:PlayerPhaseState,definition:EquipmentDefinition)->EquipmentInstance:
	var price:=exchange_price(player,definition.equipment_definition_id)
	if player.equipment_exchange_material_count<price:return null
	player.equipment_exchange_material_count-=price;var key:=String(definition.equipment_definition_id);player.gacha_state.equipment_exchange_price_by_definition[key]=int(player.gacha_state.equipment_exchange_price_by_definition.get(key,0))+1;return equipment_service.grant(player,definition,&"EXCHANGE")
func ss_shop_price(player:PlayerPhaseState,definition_id:StringName)->int:return 30+6*int(player.gacha_state.ss_purchase_count_by_definition.get(String(definition_id),0))
func purchase_ss(session:EquipmentManagementSession,player:PlayerPhaseState,definition:EquipmentDefinition)->EquipmentInstance:
	var checked:Dictionary=purchase_ss_checked(session,player,definition)
	var instance_value:Variant=checked.get("instance")
	return instance_value as EquipmentInstance

func purchase_ss_checked(session:EquipmentManagementSession,player:PlayerPhaseState,definition:EquipmentDefinition)->Dictionary:
	if session==null or player==null:
		return _shop_failure(&"SS_SHOP_CONTEXT_MISSING","Session and player are required")
	if definition==null:
		if player.gacha_state.ss_unlocked_equipment_ids.is_empty():
			return _shop_failure(&"SS_SHOP_NO_UNLOCKED_EQUIPMENT","No SS Equipment is unlocked")
		return _shop_failure(&"SS_SHOP_DEFINITION_NOT_FOUND","Unlocked SS definition was not found")
	var definition_id:StringName=definition.equipment_definition_id
	if definition_id.is_empty():
		return _shop_failure(&"SS_SHOP_DEFINITION_NOT_FOUND","SS Equipment definition ID is empty")
	if definition.tier!=EquipmentEnums.Tier.SS:
		return _shop_failure(&"SS_SHOP_DEFINITION_NOT_SS","Selected Equipment is not SS tier")
	if not player.gacha_state.ss_unlocked_equipment_ids.has(definition_id):
		return _shop_failure(&"SS_SHOP_NOT_UNLOCKED","Selected SS Equipment is not unlocked")
	var price:int=ss_shop_price(player,definition_id)
	var key:String=String(player.player_id)
	var balance:int=int(session.test_ss_shop_currency_by_player.get(key,0))
	if balance<price:
		return _shop_failure(&"SS_SHOP_INSUFFICIENT_CURRENCY","TEST_ONLY SS shop currency is insufficient")
	var instance:EquipmentInstance=equipment_service.grant(player,definition,&"SS_SHOP")
	if instance==null:
		return _shop_failure(&"SS_SHOP_GRANT_FAILED","Equipment grant failed")
	session.test_ss_shop_currency_by_player[key]=balance-price
	var equipment_key:String=String(definition_id)
	player.gacha_state.ss_purchase_count_by_definition[equipment_key]=int(player.gacha_state.ss_purchase_count_by_definition.get(equipment_key,0))+1
	return {"success":true,"code":&"SS_SHOP_PURCHASED","message":"SS Equipment duplicate purchased","instance":instance,"price":price}

func _shop_failure(code:StringName,message:String)->Dictionary:
	return {"success":false,"code":code,"message":message,"instance":null,"price":0}

func _result(player:PlayerPhaseState,banner_id:StringName,banner_type:StringName,cost:int)->GachaRollResult:
	var result:=GachaRollResult.new();result.player_id=player.player_id;result.banner_id=banner_id;result.banner_type=banner_type;result.ticket_cost=cost;result.acquisition_source=banner_type;return result
func _fail(result:GachaRollResult,code:StringName)->GachaRollResult:result.code=code;return result
func _tier_pool(definitions:Array[EquipmentDefinition],tier:int)->Array[EquipmentDefinition]:
	var result:Array[EquipmentDefinition]=[]
	for definition:EquipmentDefinition in definitions:
		if definition.tier==tier:result.append(definition)
	return result
func _find(definitions:Array[EquipmentDefinition],id:StringName)->EquipmentDefinition:
	for definition:EquipmentDefinition in definitions:
		if definition.equipment_definition_id==id:return definition
	return null
func _grant_resource(player:PlayerPhaseState,type:StringName,amount:int)->void:
	match type:
		&"EXP": player.equipment_exp_material_count+=amount
		&"EXCHANGE": player.equipment_exchange_material_count+=amount
		&"SILVER": player.silver_coin_count+=amount
		&"TICKET": player.gacha_ticket_count+=amount
func _unlock_ss(player:PlayerPhaseState,id:StringName)->void:
	if not player.gacha_state.ss_unlocked_equipment_ids.has(id):player.gacha_state.ss_unlocked_equipment_ids.append(id)
