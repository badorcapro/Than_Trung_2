extends Control

@onready var phase_label:Label=%PhaseLabel
@onready var player_overview:RichTextLabel=%PlayerOverview
@onready var reward_log:RichTextLabel=%RewardLog
@onready var bag_label:RichTextLabel=%BagLabel
@onready var effects_label:RichTextLabel=%EffectsLabel
@onready var result_label:Label=%ResultLabel
@onready var item_option:OptionButton=%ItemOption
@onready var use_button:Button=%UseButton
@onready var continue_button:Button=%ContinueButton
@onready var move_button:Button=%MoveButton
@onready var overflow_panel:PanelContainer=%OverflowPanel

var characters:Array[CharacterDefinition]=[]
var rewards:Array[RewardDefinition]=[]
var items:Array[ConsumableItemDefinition]=[]
var map_definition:LootMapDefinition
var session:LootRewardSession
var service:=LootRewardService.new()
var movement_rng:MovementRollSource=SeededMovementRollSource.new()

func _ready()->void:
	characters=Gd2FixtureRepository.load_selection_characters(); rewards=Gd2FixtureRepository.load_m4_rewards(); items=Gd2FixtureRepository.load_m4_items(); map_definition=Gd2FixtureRepository.load_m3_map()
	var players:Array[PlayerPhaseState]=[]
	for index:int in range(3):
		var player:=PlayerPhaseState.new(); player.player_id=StringName("debug_player_%d"%(index+1)); player.seat_index=index; player.character_id=characters[index].character_id; players.append(player)
	session=service.build_session(players,characters,map_definition,rewards,SequenceRewardRollSource.new([0,1,2,3,4,5,6]),&"debug_round_m4")
	# Seed one ordinary item so Item Window is testable before the first reward.
	session.players[0].consumable_inventory.append({"item_id":"test_move_plus_1"})
	_refresh()

func _on_use_pressed()->void:
	var selected:int=item_option.get_selected_id()
	if selected<0:return
	var item_id:=StringName(item_option.get_item_metadata(item_option.selected))
	var result:ItemUseResult=service.use_item(session,item_id,items); result_label.text="Use Item: %s"%String(result.code); _refresh()
func _on_continue_pressed()->void:
	result_label.text="Continue Without Item: %s"%("PASS" if service.continue_without_item(session) else "FAIL"); _refresh()
func _on_move_pressed()->void:
	var action:MovementActionResult=service.perform_movement(session,map_definition,movement_rng,rewards); result_label.text="Move: unavailable" if action==null else "Roll %d → %s"%[action.roll_distance,action.end_node_id]; _refresh()
func _on_discard_pressed()->void:
	service.resolve_overflow_discard(session,0,rewards); result_label.text="Overflow: discarded old item"; _refresh()
func _on_skip_incoming_pressed()->void:
	service.resolve_overflow_skip(session,rewards); result_label.text="Overflow: skipped incoming"; _refresh()
func _on_back_pressed()->void: AppFlow.go_to_debug_home()

func _refresh()->void:
	var phase_name:Variant=LootRewardSession.Phase.keys()[session.phase]; phase_label.text="Phase: %s"%String(phase_name)
	use_button.disabled=session.phase!=LootRewardSession.Phase.ITEM_WINDOW; continue_button.disabled=use_button.disabled; move_button.disabled=session.phase!=LootRewardSession.Phase.MOVEMENT; overflow_panel.visible=session.phase==LootRewardSession.Phase.BAG_OVERFLOW_PENDING
	var lines:Array[String]=["[b]Player | Node | Moves | Silver | Orb | Ticket | EXP | Exchange[/b]"]
	for player:PlayerPhaseState in session.players:
		var movement_player:LootMovementPlayerState=_find_movement_player(player.player_id)
		lines.append("%s | %s | %d | %d | %d | %d | %d | %d"%[player.player_id,movement_player.current_node_id,movement_player.remaining_moves,player.silver_coin_count,player.orb_count,player.gacha_ticket_count,player.equipment_exp_material_count,player.equipment_exchange_material_count])
	player_overview.text="\n".join(lines)
	item_option.clear(); var current_movement:LootMovementPlayerState=session.movement_session.current_player(); var current:PlayerPhaseState=session.find_player(current_movement.player_id)
	for entry:Dictionary in current.consumable_inventory:
		var item_id:=StringName(entry.get("item_id","")); item_option.add_item(String(item_id)); item_option.set_item_metadata(item_option.item_count-1,String(item_id))
	var round_loot:RoundLootInventoryState=session.find_round_loot_state(current.player_id)
	bag_label.text="[b]Bag %d/%d[/b]\n%s"%[round_loot.carried_items.size(),round_loot.capacity,JSON.stringify(round_loot.carried_items)]
	var effect_lines:Array[String]=["[b]Temporary Effects[/b]"]
	for player:LootMovementPlayerState in session.movement_session.player_states:
		for effect:TemporaryEffectState in player.temporary_effects:
			effect_lines.append("%s: %s / %s / active=%s"%[player.player_id,effect.effect_kind,TemporaryEffectState.Duration.keys()[effect.duration],effect.active])
	effects_label.text="\n".join(effect_lines)
	var history_lines:Array[String]=["[b]Reward Log[/b]"]
	for result:RewardResolutionResult in session.reward_history:
		history_lines.append("%s → %s x%d / %s"%[result.node_id,result.reward_id,result.reward_amount,RewardResolutionResult.Status.keys()[result.status]])
	reward_log.text="\n".join(history_lines)

func _find_movement_player(player_id:StringName)->LootMovementPlayerState:
	for player:LootMovementPlayerState in session.movement_session.player_states:
		if player.player_id==player_id:return player
	return null
