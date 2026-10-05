extends Control

@onready var phase_label:Label=%PhaseLabel
@onready var overview:RichTextLabel=%Overview
@onready var result_label:Label=%ResultLabel
@onready var confirm_button:Button=%ConfirmButton
@onready var management_actions:GridContainer=%ManagementActions
@onready var choice_row:GridContainer=%ChoiceRow

var session:=EquipmentManagementSession.new()
var definitions:Array[EquipmentDefinition]=[]
var entries:Array[PerfectPoolEntry]=[]
var config:GachaConfig
var end_service:=LootEndConfirmationService.new()
var equipment:=EquipmentManagementService.new()
var progression:=EquipmentProgressionService.new()
var gacha:=GachaService.new()

func _ready()->void:
	definitions=Gd2FixtureRepository.load_m5_equipment_definitions();entries=Gd2FixtureRepository.load_m5_perfect_entries();config=Gd2FixtureRepository.load_m5_gacha_config();session.round_id=&"debug_round_m5"
	for index:int in range(3):
		var player:=PlayerPhaseState.new();player.player_id=StringName("debug_player_%d"%(index+1));player.gacha_ticket_count=30;player.equipment_exp_material_count=300;player.equipment_exchange_material_count=60;session.players.append(player);session.player_order.append(player.player_id);session.test_ss_shop_currency_by_player[String(player.player_id)]=100
	_refresh()
func _on_confirm_pressed()->void:end_service.confirm(session,session.current_player_id());result_label.text="Confirmed";_refresh()
func _on_grant_loadout_pressed()->void:
	var player:=session.find_player(session.current_player_id())
	for id:StringName in [&"m5_s_relic_featured",&"m5_s_stig_a",&"m5_s_stig_b",&"m5_s_stig_c"]:
		var instance:=equipment.grant(player,equipment.find_definition(definitions,id),&"TEST_FIXTURE");equipment.equip(player,instance.instance_id)
	result_label.text="Granted/equipped same-set debug loadout";_refresh()
func _on_gold_pressed()->void:
	var player:=session.find_player(session.current_player_id())
	if player.equipment_collection.is_empty():return
	var instance:EquipmentInstance=player.equipment_collection[0];var definition:=equipment.find_definition(definitions,instance.equipment_definition_id);var result:=progression.upgrade_gold_one(player,instance,definition,session);result_label.text="Gold: %s"%result.code;_refresh()
func _on_gold_max_pressed()->void:
	var player:=session.find_player(session.current_player_id())
	if player.equipment_collection.is_empty():return
	var instance:EquipmentInstance=player.equipment_collection[0];var definition:=equipment.find_definition(definitions,instance.equipment_definition_id);result_label.text="Gold levels: %d"%progression.upgrade_gold_max(player,instance,definition,session);_refresh()
func _on_purple_pressed()->void:
	var player:=session.find_player(session.current_player_id())
	if player.equipment_collection.is_empty():return
	var target:EquipmentInstance=player.equipment_collection[0];var definition:=equipment.find_definition(definitions,target.equipment_definition_id);target.gold_star_level=6;var duplicate:=equipment.grant(player,definition,&"TEST_FIXTURE");var result:=progression.upgrade_purple(player,target,duplicate,definition,session);result_label.text="Purple: %s"%result.code;_refresh()
func _on_basic_pressed()->void:
	var result:=gacha.basic_roll(session,session.find_player(session.current_player_id()),definitions,SequenceGachaRollSource.new([70,0]));result_label.text="Basic: %s %s"%[result.result_category,result.equipment_definition_id];_refresh()
func _on_rate_up_pressed()->void:
	var featured:Array[StringName]=[&"m5_s_relic_featured",&"m5_s_stig_a",&"m5_s_stig_b",&"m5_s_stig_c"];var result:=gacha.rate_up_roll(session,session.find_player(session.current_player_id()),definitions,featured,config,SequenceGachaRollSource.new([95,20]));result_label.text="Rate Up: %s"%result.equipment_definition_id;_refresh()
func _on_perfect_pressed()->void:
	var result:=gacha.perfect_spin(session,session.find_player(session.current_player_id()),entries,SequenceGachaRollSource.new([1]));result_label.text="Perfect: %s"%result.perfect_entry_id;_refresh()
func _on_choice_pressed(slot:StringName)->void:
	var selected:=gacha.claim_choice(session,session.find_player(session.current_player_id()),StringName("m5_ss_stig_%s"%String(slot).to_lower()),definitions);result_label.text="Choice: %s"%(selected.equipment_definition_id if selected!=null else &"INVALID");_refresh()
func _on_ss_shop_pressed()->void:
	var player:=session.find_player(session.current_player_id())
	if player.gacha_state.ss_unlocked_equipment_ids.is_empty():result_label.text="SS Shop: no unlock";return
	var definition:=equipment.find_definition(definitions,player.gacha_state.ss_unlocked_equipment_ids[0]);var purchased:=gacha.purchase_ss(session,player,definition);result_label.text="SS Shop: %s"%(purchased.instance_id if purchased!=null else &"INSUFFICIENT_TEST_CURRENCY");_refresh()
func _on_done_pressed()->void:result_label.text="Done: %s"%end_service.mark_management_done(session,session.current_player_id());_refresh()
func _on_back_pressed()->void:AppFlow.go_to_debug_home()
func _refresh()->void:
	phase_label.text="Phase: %s"%EquipmentManagementSession.Phase.keys()[session.phase];confirm_button.visible=session.phase==EquipmentManagementSession.Phase.LOOT_END_CONFIRMATION;management_actions.visible=session.phase==EquipmentManagementSession.Phase.EQUIPMENT_MANAGEMENT;choice_row.visible=session.pending_choice.is_active()
	var lines:Array[String]=["[b]TEST_ONLY / PROTOTYPE / NOT_CANON_LOCKED[/b]","Current: %s"%session.current_player_id()]
	for player:PlayerPhaseState in session.players:lines.append("%s | confirmed=%s | done=%s | tickets=%d | EXP=%d | exchange=%d | collection=%d | set=%s"%[player.player_id,session.confirmed_player_ids.has(player.player_id),session.done_player_ids.has(player.player_id),player.gacha_ticket_count,player.equipment_exp_material_count,player.equipment_exchange_material_count,player.equipment_collection.size(),equipment.set_passive_active(player,definitions)])
	lines.append("Perfect remaining: %s"%JSON.stringify(session.perfect_remaining_hits));overview.text="\n".join(lines)
