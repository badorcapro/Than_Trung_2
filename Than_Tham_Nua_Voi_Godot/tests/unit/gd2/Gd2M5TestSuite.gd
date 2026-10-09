class_name Gd2M5TestSuite
extends RefCounted

var definitions:Array[EquipmentDefinition]=[]
var perfect_entries:Array[PerfectPoolEntry]=[]
var config:GachaConfig
var equipment:=EquipmentManagementService.new()
var progression:=EquipmentProgressionService.new()
var gacha:=GachaService.new()

func run()->Array[Dictionary]:
	definitions=Gd2FixtureRepository.load_m5_equipment_definitions();perfect_entries=Gd2FixtureRepository.load_m5_perfect_entries();config=Gd2FixtureRepository.load_m5_gacha_config()
	var rows:Array[Dictionary]=[]
	_add(rows,"GĐ2-M5 scene loads",load("res://scenes/loot/Gd2M5EquipmentManagement.tscn") is PackedScene)
	_add(rows,"M5 Equipment fixture count",definitions.size()==13)
	_add(rows,"M5 Perfect fixture entry count",perfect_entries.size()==7)
	_add(rows,"M5 content validates",M5ContentValidator.new().validate(definitions,config,perfect_entries).is_valid)
	_add(rows,"Basic rates locked 65/25/10",config.basic_rates=={"B":65,"A":25,"S":10})
	_add(rows,"Rate Up rates locked 65/25/10",config.rate_up_rates=={"B":65,"A":25,"S":10})
	_add(rows,"Featured conditional split locked 14/22/22/22/20",config.featured_s_split=={"RELIC":14,"A":22,"B":22,"C":22,"OTHER_S":20})
	_add(rows,"Rate Up pity scope explicitly TEST_ONLY",config.test_only_not_canon_locked)
	_add(rows,"SS shop currency remains configurable",config.ss_shop_currency_type==&"TEST_ONLY_SS_SHOP_CURRENCY")
	_test_confirmation(rows);_test_collection_loadout(rows);_test_gold(rows);_test_purple(rows);_test_equipment_upgrade_specification(rows);_test_basic(rows);_test_rate_up(rows);_test_perfect(rows);_test_ss_shop_guards(rows);_test_serialization(rows)
	return rows

func _add(rows:Array[Dictionary],name:String,passed:bool)->void:rows.append({"name":name,"passed":passed,"detail":"GĐ2-M5 Equipment/Gacha invariant"})
func _add_detail(rows:Array[Dictionary],name:String,passed:bool,detail:String)->void:rows.append({"name":name,"passed":passed,"detail":detail})
func _player(id:StringName=&"m5_p1")->PlayerPhaseState:
	var player:=PlayerPhaseState.new();player.player_id=id;player.phase_id=&"EQUIPMENT_MANAGEMENT";player.gacha_ticket_count=100;player.equipment_exp_material_count=1000;player.equipment_exchange_material_count=100;return player
func _management(count:int=2)->EquipmentManagementSession:
	var session:=EquipmentManagementSession.new();session.round_id=&"m5_round"
	for index:int in range(count):
		var player:=_player(StringName("m5_p%d"%(index+1)))
		session.players.append(player);session.player_order.append(player.player_id)
	return session
func _definition(id:StringName)->EquipmentDefinition:return equipment.find_definition(definitions,id)
func _sum_hits(session:EquipmentManagementSession)->int:
	var total:=0
	for value:Variant in session.perfect_remaining_hits.values():total+=int(value)
	return total

func _test_confirmation(rows:Array[Dictionary])->void:
	var service:=LootEndConfirmationService.new();var reward:=LootRewardSession.new();reward.round_id=&"m5_round";reward.movement_session=LootMovementSession.new();reward.phase=LootRewardSession.Phase.MOVEMENT
	var movement:=LootMovementPlayerState.new();movement.player_id=&"m5_p1";movement.remaining_moves=1;reward.movement_session.player_states.append(movement);reward.players.append(_player())
	_add(rows,"Cannot confirm while movement remains",not service.can_begin(reward))
	movement.remaining_moves=0;reward.phase=LootRewardSession.Phase.LOOT_END_CONFIRMATION_READY;reward.pending_trace=[&"pending"]
	_add(rows,"Cannot confirm while reward pending",not service.can_begin(reward))
	reward.pending_trace_index=1;reward.overflow.active=true
	_add(rows,"Cannot confirm while overflow pending",not service.can_begin(reward))
	reward.overflow.active=false
	_add(rows,"All exhausted enters Loot End Confirmation",service.can_begin(reward))
	var session:=service.begin(reward)
	_add(rows,"Confirmation session preserves players",session!=null and session.player_order==[&"m5_p1"])
	_add(rows,"Single required player confirms",service.confirm(session,&"m5_p1") and session.phase==EquipmentManagementSession.Phase.EQUIPMENT_MANAGEMENT)
	_add(rows,"Confirmation is idempotent",not service.confirm(session,&"m5_p1"))
	_add(rows,"No return to movement state",session.phase!=EquipmentManagementSession.Phase.LOOT_END_CONFIRMATION)
	var multi:=_management(2)
	_add(rows,"One player cannot end Loot for table",service.confirm(multi,&"m5_p1") and multi.phase==EquipmentManagementSession.Phase.LOOT_END_CONFIRMATION)
	_add(rows,"All confirmations enter Equipment Management",service.confirm(multi,&"m5_p2") and multi.phase==EquipmentManagementSession.Phase.EQUIPMENT_MANAGEMENT)
	_add(rows,"One management done advances pass-device player",service.mark_management_done(multi,&"m5_p1") and multi.current_player_id()==&"m5_p2")
	multi.pending_choice.kind=PendingEquipmentChoice.Kind.S_EQUIPMENT
	_add(rows,"Pending choice blocks management done",not service.mark_management_done(multi,&"m5_p2"))
	multi.pending_choice=PendingEquipmentChoice.new()
	_add(rows,"All management done stops at READY_FOR_M6",service.mark_management_done(multi,&"m5_p2") and multi.phase==EquipmentManagementSession.Phase.READY_FOR_M6)

func _test_collection_loadout(rows:Array[Dictionary])->void:
	var player:=_player();var relic:=equipment.grant(player,_definition(&"m5_a_relic"),&"BASIC");var a:=equipment.grant(player,_definition(&"m5_s_stig_a"),&"RATE_UP");var b:=equipment.grant(player,_definition(&"m5_s_stig_b"),&"RATE_UP");var c:=equipment.grant(player,_definition(&"m5_s_stig_c"),&"RATE_UP");var duplicate:=equipment.grant(player,_definition(&"m5_s_stig_a"),&"RATE_UP")
	_add(rows,"Duplicate creates independent instance",a.instance_id!=duplicate.instance_id and player.equipment_collection.size()==5)
	_add(rows,"Relic is ACTIVE metadata",_definition(relic.equipment_definition_id).skill_marker==&"ACTIVE_DEBUG")
	_add(rows,"Stigmata is PASSIVE metadata",_definition(a.equipment_definition_id).skill_marker==&"PASSIVE_DEBUG")
	_add(rows,"Equip Relic",equipment.equip(player,relic.instance_id).success and player.relic_instance_id==relic.instance_id)
	_add(rows,"Equip Stigmata A",equipment.equip(player,a.instance_id).success and player.stigmata_a_instance_id==a.instance_id)
	_add(rows,"Equip Stigmata B",equipment.equip(player,b.instance_id).success and player.stigmata_b_instance_id==b.instance_id)
	_add(rows,"Equip Stigmata C",equipment.equip(player,c.instance_id).success and player.stigmata_c_instance_id==c.instance_id)
	_add(rows,"Full same set activates set passive",equipment.set_passive_active(player,definitions))
	var mixed:=equipment.grant(player,_definition(&"m5_a_stig_c"),&"BASIC");equipment.equip(player,mixed.instance_id)
	_add(rows,"Mixed set has no set passive",not equipment.set_passive_active(player,definitions))
	_add(rows,"Unequip clears slot",equipment.unequip(player,mixed.instance_id) and player.stigmata_c_instance_id.is_empty())
	var stranger:=_player(&"stranger");stranger.equipment_collection.append(relic)
	_add(rows,"Instance ownership enforced",not equipment.equip(stranger,relic.instance_id).success)

func _test_gold(rows:Array[Dictionary])->void:
	var player:=_player();var definition:=_definition(&"m5_a_relic");var instance:=equipment.grant(player,definition,&"BASIC")
	_add(rows,"New Equipment starts Gold 0",instance.gold_star_level==0)
	instance.gold_star_level=1
	var before:=player.equipment_exp_material_count;var one:=progression.upgrade_gold_one(player,instance,definition)
	_add(rows,"Gold one-level succeeds",one.success and instance.gold_star_level==2)
	_add(rows,"Gold consumes integer authored cost",player.equipment_exp_material_count==before-11)
	_add(rows,"Authored stat row selected",int(definition.stat_row(2).get("power",0))==12)
	player.equipment_exp_material_count=0
	_add(rows,"Insufficient Gold material fails",not progression.upgrade_gold_one(player,instance,definition).success)
	player.equipment_exp_material_count=73;var levels:=progression.upgrade_gold_max(player,instance,definition)
	_add(rows,"Upgrade Max uses complete affordable levels",levels==2 and instance.gold_star_level==4)
	_add(rows,"Upgrade Max preserves remainder without partial XP",player.equipment_exp_material_count==21)
	instance.gold_star_level=6
	_add(rows,"Gold max is 6",progression.upgrade_gold_one(player,instance,definition).code==&"GOLD_MAX")

func _test_purple(rows:Array[Dictionary])->void:
	var player:=_player();var definition:=_definition(&"m5_a_relic");var target:=equipment.grant(player,definition,&"BASIC");var duplicate:=equipment.grant(player,definition,&"BASIC")
	target.gold_star_level=0
	var prerequisite_exp_before:=player.equipment_exp_material_count;var prerequisite_count_before:=player.equipment_collection.size()
	var prerequisite_result:=progression.upgrade_purple(player,target,duplicate,definition)
	_add_detail(rows,"Purple P1 requires Gold target",prerequisite_result.code==&"GOLD_PREREQUISITE" and target.purple_star_level==0 and equipment.find_instance(player,duplicate.instance_id)!=null and player.equipment_exp_material_count==prerequisite_exp_before and player.equipment_collection.size()==prerequisite_count_before,_purple_diagnostic(player,target,duplicate,definition,prerequisite_result))
	target.gold_star_level=1
	_add(rows,"Purple target cannot consume itself",progression.upgrade_purple(player,target,target,definition).code==&"TARGET_IS_DUPLICATE")
	var wrong:=equipment.grant(player,_definition(&"m5_a_stig_a"),&"BASIC")
	_add(rows,"Purple rejects wrong duplicate",progression.upgrade_purple(player,target,wrong,definition).code==&"WRONG_DUPLICATE")
	var count_before:=player.equipment_collection.size();var exp_before:=player.equipment_exp_material_count;var p1:=progression.upgrade_purple(player,target,duplicate,definition)
	var p1_detail:=_purple_diagnostic(player,target,duplicate,definition,p1)
	_add_detail(rows,"Purple valid duplicate succeeds",p1.success and target.purple_star_level==1,p1_detail)
	_add_detail(rows,"Purple consumes duplicate instance",player.equipment_collection.size()==count_before-1 and equipment.find_instance(player,duplicate.instance_id)==null,p1_detail)
	_add_detail(rows,"Purple consumes EXP",player.equipment_exp_material_count==exp_before-progression.purple_cost(1,definition),p1_detail)
	_add_detail(rows,"P1 stat milestone",p1.code==&"PURPLE_STAT_MILESTONE",p1_detail)
	target.gold_star_level=6
	_add(rows,"P2 skill milestone",_purple_step_code(player,target,definition)==&"PURPLE_SKILL_MILESTONE")
	_add(rows,"P3 stat milestone",_purple_step_code(player,target,definition)==&"PURPLE_STAT_MILESTONE")
	_add(rows,"P4 skill milestone",_purple_step_code(player,target,definition)==&"PURPLE_SKILL_MILESTONE")
	_add(rows,"P5 stat milestone",_purple_step_code(player,target,definition)==&"PURPLE_STAT_MILESTONE")
	_add(rows,"P6 skill milestone",_purple_step_code(player,target,definition)==&"PURPLE_SKILL_MILESTONE")
	_add(rows,"Purple costs floor half Gold",progression.purple_cost(1,definition)==5 and progression.purple_cost(2,definition)==10)
	_add(rows,"P5 to P6 cost floors 1.5 times",progression.purple_cost(6,definition)==37)
	_add(rows,"Purple max 6",target.purple_star_level==6 and progression.upgrade_purple(player,target,target,definition).code==&"PURPLE_MAX")
	_add(rows,"Purple leaves Gold unchanged",target.gold_star_level==6)

func _test_equipment_upgrade_specification(rows: Array[Dictionary]) -> void:
	var def := _definition(&"m5_a_relic")
	_add(rows, "Skill level progression 1..4", def.get_skill_level(0) == 1 and def.get_skill_level(1) == 1 and def.get_skill_level(2) == 2 and def.get_skill_level(3) == 2 and def.get_skill_level(4) == 3 and def.get_skill_level(5) == 3 and def.get_skill_level(6) == 4)
	var player := _player()
	player.relic_exp_material_count = 50
	player.stigmata_exp_material_count = 30
	_add(rows, "Player separate relic EXP material count", player.get_exp_material_count(EquipmentEnums.EquipmentType.RELIC) == 50)
	_add(rows, "Player separate stigmata EXP material count", player.get_exp_material_count(EquipmentEnums.EquipmentType.STIGMATA) == 30)
	_add(rows, "Spend relic EXP leaves stigmata unchanged", player.spend_exp_material(EquipmentEnums.EquipmentType.RELIC, 20) and player.relic_exp_material_count == 30 and player.stigmata_exp_material_count == 30)
	var inst := equipment.grant(player, def, &"BASIC")
	var state := progression.progression_state(player, inst, def)
	_add(rows, "Progression state includes current and next stats", state.has("current_stats") and state.has("next_gold_stats") and state.has("skill_level"))
func _purple_step_code(player:PlayerPhaseState,target:EquipmentInstance,definition:EquipmentDefinition)->StringName:
	var duplicate:=equipment.grant(player,definition,&"BASIC");return progression.upgrade_purple(player,target,duplicate,definition).code
func _purple_diagnostic(player:PlayerPhaseState,target:EquipmentInstance,duplicate:EquipmentInstance,definition:EquipmentDefinition,result:EquipmentActionResult)->String:
	var target_level:int=target.purple_star_level+1 if not result.success else target.purple_star_level
	var required:int=progression.purple_cost(target_level,definition)
	return "Gold=%d | Purple=%d | target=%d | duplicate=%s | EXP=%d | required=%d | code=%s"%[target.gold_star_level,target.purple_star_level,target_level,duplicate.instance_id,player.equipment_exp_material_count,required,result.code]

func _test_basic(rows:Array[Dictionary])->void:
	var session:=_management(2);session.phase=EquipmentManagementSession.Phase.EQUIPMENT_MANAGEMENT;var p:=session.players[0]
	var tickets:=p.gacha_ticket_count;var b:=gacha.basic_roll(session,p,definitions,SequenceGachaRollSource.new([0]))
	_add(rows,"Basic costs one ticket",b.success and p.gacha_ticket_count==tickets-1)
	_add(rows,"Basic B grants EXP not Equipment",b.result_category==&"B" and b.resource_amount==5 and p.equipment_collection.is_empty())
	_add(rows,"Basic roll grants exchange material",b.exchange_material_delta==1)
	var a:=gacha.basic_roll(session,p,definitions,SequenceGachaRollSource.new([70,0]))
	_add(rows,"Basic A grants A Equipment",a.result_category==&"A" and _definition(a.equipment_definition_id).tier==EquipmentEnums.Tier.A)
	var s:=gacha.basic_roll(session,p,definitions,SequenceGachaRollSource.new([95,0]))
	_add(rows,"Basic S grants S Equipment",s.result_category==&"S" and _definition(s.equipment_definition_id).tier==EquipmentEnums.Tier.S)
	var pity_player:=session.players[1]
	for index:int in range(4):gacha.basic_roll(session,pity_player,definitions,SequenceGachaRollSource.new([0]))
	_add(rows,"Basic tracks four consecutive B",pity_player.gacha_state.consecutive_without_a_plus==4)
	var guaranteed:=gacha.basic_roll(session,pity_player,definitions,SequenceGachaRollSource.new([0,0]))
	_add(rows,"Basic fifth roll guaranteed A plus",guaranteed.result_category==&"A" or guaranteed.result_category==&"S")
	_add(rows,"Basic A plus resets pity",pity_player.gacha_state.consecutive_without_a_plus==0)
	_add(rows,"Basic pity is per player",p.gacha_state.consecutive_without_a_plus==0)
	var definition:=_definition(&"m5_a_relic");_add(rows,"Exchange starts at 20",gacha.exchange_price(p,definition.equipment_definition_id)==20)
	var first:=gacha.exchange(p,definition);_add(rows,"Exchange grants selected Equipment",first!=null and first.acquired_source==&"EXCHANGE")
	_add(rows,"Same Equipment exchange escalates 25",gacha.exchange_price(p,definition.equipment_definition_id)==25)
	_add(rows,"Other Equipment price remains 20",gacha.exchange_price(p,&"m5_a_stig_a")==20)
	_add(rows,"Exchange state is per player",gacha.exchange_price(pity_player,definition.equipment_definition_id)==20)

func _test_rate_up(rows:Array[Dictionary])->void:
	var session:=_management(1);session.phase=EquipmentManagementSession.Phase.EQUIPMENT_MANAGEMENT;var player:=session.players[0];var featured:Array[StringName]=[&"m5_s_relic_featured",&"m5_s_stig_a",&"m5_s_stig_b",&"m5_s_stig_c"]
	var b:=gacha.rate_up_roll(session,player,definitions,featured,config,SequenceGachaRollSource.new([0]))
	_add(rows,"Rate Up B routing",b.result_category==&"B")
	var a:=gacha.rate_up_roll(session,player,definitions,featured,config,SequenceGachaRollSource.new([70,0]))
	_add(rows,"Rate Up A routing",a.result_category==&"A")
	var relic:=gacha.rate_up_roll(session,player,definitions,featured,config,SequenceGachaRollSource.new([95,0]))
	_add(rows,"Rate Up featured Relic 14 split",relic.equipment_definition_id==featured[0])
	var stig_a:=gacha.rate_up_roll(session,player,definitions,featured,config,SequenceGachaRollSource.new([95,20]))
	_add(rows,"Rate Up featured A 22 split",stig_a.equipment_definition_id==featured[1])
	var stig_b:=gacha.rate_up_roll(session,player,definitions,featured,config,SequenceGachaRollSource.new([95,40]))
	_add(rows,"Rate Up featured B 22 split",stig_b.equipment_definition_id==featured[2])
	var stig_c:=gacha.rate_up_roll(session,player,definitions,featured,config,SequenceGachaRollSource.new([95,70]))
	_add(rows,"Rate Up featured C 22 split",stig_c.equipment_definition_id==featured[3])
	var other:=gacha.rate_up_roll(session,player,definitions,featured,config,SequenceGachaRollSource.new([95,90]))
	_add(rows,"Rate Up off-featured S 20 split",other.equipment_definition_id==&"m5_s_relic_other")
	player.gacha_state.consecutive_without_a_plus=3
	_add(rows,"Rate Up pity independent from Basic",player.gacha_state.rate_up_consecutive_without_a_plus==0 and player.gacha_state.consecutive_without_a_plus==3)
	_add(rows,"Rate Up exchange grant remains config",not config.rate_up_grants_exchange_material and b.exchange_material_delta==0)

func _test_perfect(rows:Array[Dictionary])->void:
	var session:=_management(1);session.phase=EquipmentManagementSession.Phase.EQUIPMENT_MANAGEMENT;var player:=session.players[0];gacha.initialize_perfect(session,perfect_entries)
	_add(rows,"Perfect initial total is 25",_sum_hits(session)==25)
	_add(rows,"Perfect core structure is 1 plus 3 plus 1",int(session.perfect_remaining_hits.get("core_ss_relic",0))==1 and int(session.perfect_remaining_hits.get("core_ss_stigmata_choice",0))==3 and int(session.perfect_remaining_hits.get("core_s_choice",0))==1)
	var tickets:=player.gacha_ticket_count;var regular:=gacha.perfect_spin(session,player,perfect_entries,SequenceGachaRollSource.new([10]))
	_add(rows,"Perfect costs two tickets",regular.success and player.gacha_ticket_count==tickets-2)
	_add(rows,"Perfect hit decrements remaining",_sum_hits(session)==24)
	_add(rows,"Perfect weighted draw selects configured weight",regular.perfect_entry_id==&"regular_exp")
	_add(rows,"Perfect amount means amount per hit",regular.resource_amount==5)
	var choice_session:=_management(1);choice_session.phase=EquipmentManagementSession.Phase.EQUIPMENT_MANAGEMENT;var choice_player:=choice_session.players[0];gacha.initialize_perfect(choice_session,perfect_entries)
	var choice:=gacha.perfect_spin(choice_session,choice_player,perfect_entries,SequenceGachaRollSource.new([1]))
	_add(rows,"SS Stigmata chest creates pending choice",choice.success and choice_session.pending_choice.kind==PendingEquipmentChoice.Kind.SS_STIGMATA)
	_add(rows,"Each SS chest allows A B or C",choice_session.pending_choice.eligible_definition_ids==[&"m5_ss_stig_a",&"m5_ss_stig_b",&"m5_ss_stig_c"])
	var selected:=gacha.claim_choice(choice_session,choice_player,&"m5_ss_stig_b",definitions)
	_add(rows,"SS chest grants player-selected B",selected!=null and selected.equipment_definition_id==&"m5_ss_stig_b")
	_add(rows,"SS acquisition unlocks personal shop",choice_player.gacha_state.ss_unlocked_equipment_ids.has(&"m5_ss_stig_b"))
	choice_session.test_ss_shop_currency_by_player[String(choice_player.player_id)]=100;var ss_def:=_definition(&"m5_ss_stig_b")
	_add(rows,"SS shop starts at configurable-currency price 30",gacha.ss_shop_price(choice_player,ss_def.equipment_definition_id)==30)
	var purchase:=gacha.purchase_ss(choice_session,choice_player,ss_def)
	_add(rows,"SS shop purchase grants duplicate instance",purchase!=null and purchase.instance_id!=selected.instance_id)
	_add(rows,"SS shop same item escalates by 6",gacha.ss_shop_price(choice_player,ss_def.equipment_definition_id)==36)
	_add(rows,"Perfect has no pity interaction",choice_player.gacha_state.consecutive_without_a_plus==0 and choice_player.gacha_state.rate_up_consecutive_without_a_plus==0)
	_add(rows,"SS is not Character-element gated",purchase!=null)

func _test_serialization(rows:Array[Dictionary])->void:
	var serializer:=EquipmentManagementSerializer.new();var session:=_management(2);session.confirmed_player_ids.append(&"m5_p1");session.perfect_remaining_hits={"core":3};session.test_ss_shop_currency_by_player={"m5_p1":44};session.progression_history.append({"code":"GOLD_UPGRADED"});session.gacha_history.append({"banner_type":"BASIC"})
	_add(rows,"Partial Loot confirmation round-trip",serializer.round_trip(session))
	session.phase=EquipmentManagementSession.Phase.EQUIPMENT_MANAGEMENT;var player:=session.players[0];var instance:=equipment.grant(player,_definition(&"m5_s_relic_featured"),&"RATE_UP");equipment.equip(player,instance.instance_id)
	_add(rows,"Management collection/loadout round-trip",serializer.round_trip(session))
	instance.gold_star_level=1;instance.purple_star_level=0;var duplicate:=equipment.grant(player,_definition(&"m5_s_relic_featured"),&"RATE_UP");var purple_result:=progression.upgrade_purple(player,instance,duplicate,_definition(&"m5_s_relic_featured"),session);var progression_diagnostic:=serializer.round_trip_diagnostic(session)
	_add_detail(rows,"Gold Purple progression round-trip",purple_result.success and instance.purple_star_level==1 and equipment.find_instance(player,duplicate.instance_id)==null and not session.progression_history.is_empty() and bool(progression_diagnostic.get("matches",false)),_round_trip_detail(progression_diagnostic))
	session.pending_choice.kind=PendingEquipmentChoice.Kind.S_EQUIPMENT;session.pending_choice.player_id=player.player_id;session.pending_choice.source_entry_id=&"core_s_choice";session.pending_choice.eligible_definition_ids=[&"m5_s_relic_featured"];session.gacha_history.append({"success":true,"banner_type":"PERFECT","player_id":String(player.player_id),"ticket_cost":2,"perfect_entry_id":"core_s_choice"});var choice_diagnostic:=serializer.round_trip_diagnostic(session)
	_add_detail(rows,"Perfect pending choice round-trip",bool(choice_diagnostic.get("matches",false)),_round_trip_detail(choice_diagnostic))
	session.pending_choice=PendingEquipmentChoice.new();session.done_player_ids.clear()
	for player_id:StringName in session.player_order:session.done_player_ids.append(player_id)
	session.current_player_index=1;session.phase=EquipmentManagementSession.Phase.READY_FOR_M6;var ready_diagnostic:=serializer.round_trip_diagnostic(session)
	_add_detail(rows,"Management ready state data round-trip",bool(ready_diagnostic.get("matches",false)),_round_trip_detail(ready_diagnostic))

func _test_ss_shop_guards(rows:Array[Dictionary])->void:
	var session:=_management(1);session.phase=EquipmentManagementSession.Phase.EQUIPMENT_MANAGEMENT
	var player:=session.players[0]
	_add(rows,"SS shop null definition does not crash",gacha.purchase_ss(session,player,null)==null)
	var no_unlock:Dictionary=gacha.purchase_ss_checked(session,player,null)
	_add(rows,"SS shop no unlocked Equipment structured reject",StringName(String(no_unlock.get("code",&"")))==&"SS_SHOP_NO_UNLOCKED_EQUIPMENT")
	var ss_definition:=_definition(&"m5_ss_stig_b")
	var locked:Dictionary=gacha.purchase_ss_checked(session,player,ss_definition)
	_add(rows,"SS shop locked Equipment structured reject",StringName(String(locked.get("code",&"")))==&"SS_SHOP_NOT_UNLOCKED")
	player.gacha_state.ss_unlocked_equipment_ids.append(ss_definition.equipment_definition_id)
	session.test_ss_shop_currency_by_player[String(player.player_id)]=29
	var insufficient:Dictionary=gacha.purchase_ss_checked(session,player,ss_definition)
	_add(rows,"SS shop insufficient currency structured reject",StringName(String(insufficient.get("code",&"")))==&"SS_SHOP_INSUFFICIENT_CURRENCY")
	session.test_ss_shop_currency_by_player[String(player.player_id)]=100
	var first:Dictionary=gacha.purchase_ss_checked(session,player,ss_definition)
	_add(rows,"SS shop valid unlocked Equipment purchase succeeds",bool(first.get("success",false)))
	var second:Dictionary=gacha.purchase_ss_checked(session,player,ss_definition)
	var first_instance:EquipmentInstance=first.get("instance") as EquipmentInstance
	var second_instance:EquipmentInstance=second.get("instance") as EquipmentInstance
	_add(rows,"SS shop duplicate purchases preserve unique instance IDs",first_instance!=null and second_instance!=null and first_instance.instance_id!=second_instance.instance_id)

func _round_trip_detail(diagnostic:Dictionary)->String:
	var mismatch_value:Variant=diagnostic.get("mismatches",[]);var mismatches:Array[String]=[]
	if mismatch_value is Array:mismatches.assign(mismatch_value)
	return "Round-trip PASS" if bool(diagnostic.get("matches",false)) else "Mismatch: %s"%", ".join(mismatches)
