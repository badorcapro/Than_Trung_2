class_name Gd2M4TestSuite
extends RefCounted

var characters: Array[CharacterDefinition] = []
var map_definition: LootMapDefinition
var rewards: Array[RewardDefinition] = []
var items: Array[ConsumableItemDefinition] = []
var service := LootRewardService.new()
var serializer := LootRewardSerializer.new()
var round_trip_detail := "GĐ2-M4 Reward/Item/Temporary Effect invariant"

func run() -> Array[Dictionary]:
	characters=Gd2FixtureRepository.load_selection_characters(); map_definition=Gd2FixtureRepository.load_m3_map(); rewards=Gd2FixtureRepository.load_m4_rewards(); items=Gd2FixtureRepository.load_m4_items()
	var rows: Array[Dictionary] = []
	rows.append(_row("GĐ2-M4 scene loads", load("res://scenes/loot/Gd2M4RewardItem.tscn") is PackedScene))
	rows.append(_row("M4 fixture content validates", M4ContentValidator.new().validate_rewards(rewards,items).is_valid))
	rows.append(_row("Reward snapshot excludes spawn nodes", _snapshot().size()==8))
	rows.append(_row("Reward snapshot is deterministic", _snapshot_dicts()==_snapshot_dicts()))
	rows.append(_row("Snapshot is fixed inside session", _snapshot_fixed()))
	rows.append(_row("Different RNG sequence changes snapshot", _different_rng_changes()))
	rows.append(_row("Trace resolves in exact path order", _trace_order()))
	rows.append(_row("Silver resource grants exactly", _resource_grant(RewardDefinition.Type.SILVER_COIN,2)))
	rows.append(_row("Orb resource grants exactly", _resource_grant(RewardDefinition.Type.ORB,1)))
	rows.append(_row("Gacha ticket grants exactly", _resource_grant(RewardDefinition.Type.GACHA_TICKET,1)))
	rows.append(_row("EXP material grants exactly", _resource_grant(RewardDefinition.Type.EQUIPMENT_EXP_MATERIAL,3)))
	rows.append(_row("Exchange material grants exactly", _resource_grant(RewardDefinition.Type.EQUIPMENT_EXCHANGE_MATERIAL,1)))
	rows.append(_row("Resources do not occupy Bag", _resources_do_not_fill_bag()))
	rows.append(_row("Repeatable node grants on revisit", _repeatable_revisit()))
	rows.append(_row("Special node grants only once globally", _special_once()))
	rows.append(_row("Below-capacity consumable is accepted", _item_below_capacity()))
	rows.append(_row("Full Bag enters overflow pending", _overflow_pending()))
	rows.append(_row("Overflow discard accepts incoming item", _overflow_discard()))
	rows.append(_row("Overflow skip keeps old Bag", _overflow_skip()))
	rows.append(_row("Reward chain resumes after overflow", _overflow_resumes()))
	rows.append(_row("Item consumes immediately without move cost", _item_consumes_no_move()))
	rows.append(_row("Maximum one ordinary item per turn", _item_limit()))
	rows.append(_row("Continue without item enters movement", _continue_enters_movement()))
	rows.append(_row("Zero-move player item window does not deadlock", _zero_move_rotates()))
	rows.append(_row("THIS_MOVE applies then expires", _this_move_expires()))
	rows.append(_row("THIS_TURN expires at turn end", _duration_expires(TemporaryEffectState.Duration.THIS_TURN)))
	rows.append(_row("THIS_ROUND persists until Loot completion", _round_effect_contract()))
	rows.append(_row("Extra action changes runtime not Character base", _extra_action_runtime_only()))
	rows.append(_row("All-other debuff excludes self and consumes once", _all_other_debuff()))
	var round_trip_passed: bool = _round_trip()
	rows.append({"name":"M4 session round-trip preserves state", "passed":round_trip_passed, "detail":round_trip_detail})
	return rows

func _row(name:String,passed:bool)->Dictionary: return {"name":name,"passed":passed,"detail":"GĐ2-M4 Reward/Item/Temporary Effect invariant"}
func _players(indices:Array[int]=[0,1,2])->Array[PlayerPhaseState]:
	var result:Array[PlayerPhaseState]=[]
	for index:int in range(indices.size()):
		var player:=PlayerPhaseState.new(); player.player_id=StringName("m4_player_%d"%(index+1)); player.seat_index=index; player.character_id=characters[indices[index]].character_id; player.phase_id=&"READY_FOR_LOOT_M3"; result.append(player)
	return result
func _session(indices:Array[int]=[0,1,2], reward_set:Array[RewardDefinition]=[])->LootRewardSession:
	var effective_rewards:Array[RewardDefinition]=rewards if reward_set.is_empty() else reward_set
	return service.build_session(_players(indices),characters,map_definition,effective_rewards,SequenceRewardRollSource.new([0,1,2,3,4,5,6]),&"test_round_m4")
func _snapshot()->Array[RewardNodeSnapshot]: return RewardSnapshotService.new().build_reward_snapshot(&"r",map_definition,rewards,SequenceRewardRollSource.new([0,1,2,3,4,5,6]))
func _snapshot_dicts()->Array[Dictionary]:
	var rows:Array[Dictionary]=[]
	for snapshot:RewardNodeSnapshot in _snapshot(): rows.append(snapshot.to_dict())
	return rows
func _snapshot_fixed()->bool:
	var session:=_session(); var before:=session.reward_snapshots[0].to_dict(); service.continue_without_item(session); service.perform_movement(session,map_definition,SequenceMovementRollSource.new([1]),rewards); return session.reward_snapshots[0].to_dict()==before
func _different_rng_changes()->bool:
	var a:=RewardSnapshotService.new().build_reward_snapshot(&"r",map_definition,rewards,SequenceRewardRollSource.new([0])); var b:=RewardSnapshotService.new().build_reward_snapshot(&"r2",map_definition,rewards,SequenceRewardRollSource.new([1])); return a[0].reward_definition_id!=b[0].reward_definition_id
func _trace_order()->bool:
	var session:=_session(); service.resolve_trace(session,&"m4_player_1",[&"house_a_1",&"center_0",&"center_1"],rewards); return session.reward_history.size()==3 and session.reward_history[0].node_id==&"house_a_1" and session.reward_history[1].node_id==&"center_0" and session.reward_history[2].node_id==&"center_1"
func _reward_of_type(type:int)->RewardDefinition:
	for reward:RewardDefinition in rewards:
		if reward.reward_type==type and reward.repeat_policy==RewardDefinition.RepeatPolicy.REPEATABLE:return reward
	return null
func _resource_grant(type:int,amount:int)->bool:
	var reward:=_reward_of_type(type); var reward_set:Array[RewardDefinition]=[reward]; var session:=_session([0],reward_set); var p:=session.players[0]; service.resolve_trace(session,p.player_id,[&"house_a_1"],reward_set)
	match type:
		RewardDefinition.Type.SILVER_COIN:return p.silver_coin_count==amount
		RewardDefinition.Type.ORB:return p.orb_count==amount
		RewardDefinition.Type.GACHA_TICKET:return p.gacha_ticket_count==amount
		RewardDefinition.Type.EQUIPMENT_EXP_MATERIAL:return p.equipment_exp_material_count==amount
		RewardDefinition.Type.EQUIPMENT_EXCHANGE_MATERIAL:return p.equipment_exchange_material_count==amount
	return false
func _resources_do_not_fill_bag()->bool:
	var reward:=_reward_of_type(RewardDefinition.Type.SILVER_COIN); var reward_set:Array[RewardDefinition]=[reward]; var s:=_session([0],reward_set); service.resolve_trace(s,s.players[0].player_id,[&"house_a_1"],reward_set); return s.find_round_loot_state(s.players[0].player_id).carried_items.is_empty()
func _repeatable_revisit()->bool:
	var reward:=_reward_of_type(RewardDefinition.Type.ORB); var reward_set:Array[RewardDefinition]=[reward]; var s:=_session([0],reward_set); service.resolve_trace(s,s.players[0].player_id,[&"house_a_1"],reward_set); service.resolve_trace(s,s.players[0].player_id,[&"house_a_1"],reward_set); return s.players[0].orb_count==2
func _special_once()->bool:
	var reward:=rewards[6]; var reward_set:Array[RewardDefinition]=[reward]; var s:=_session([0,1],reward_set); service.resolve_trace(s,s.players[0].player_id,[&"house_a_1"],reward_set); service.resolve_trace(s,s.players[1].player_id,[&"house_a_1"],reward_set); return s.players[0].orb_count==2 and s.players[1].orb_count==0 and s.consumed_special_node_ids.has(&"house_a_1")
func _item_session(prefill:bool)->Dictionary:
	var reward:=_reward_of_type(RewardDefinition.Type.CONSUMABLE_ITEM)
	var reward_set:Array[RewardDefinition]=[reward]
	var s:=_session([0],reward_set)
	if prefill:
		s.find_round_loot_state(s.players[0].player_id).carried_items.append({"item_id":"test_extra_action"})
	service.resolve_trace(s,s.players[0].player_id,[&"house_a_1"],reward_set)
	return {"session":s}
func _item_below_capacity()->bool:
	var s:LootRewardSession=_item_session(false).get("session") as LootRewardSession; return s.find_round_loot_state(s.players[0].player_id).carried_items.size()==1 and s.players[0].consumable_inventory.is_empty() and s.phase!=LootRewardSession.Phase.BAG_OVERFLOW_PENDING
func _overflow_pending()->bool:
	var s:LootRewardSession=_item_session(true).get("session") as LootRewardSession; return s.phase==LootRewardSession.Phase.BAG_OVERFLOW_PENDING and s.overflow.active
func _overflow_discard()->bool:
	var s:LootRewardSession=_item_session(true).get("session") as LootRewardSession; var reward_set:Array[RewardDefinition]=[_reward_of_type(RewardDefinition.Type.CONSUMABLE_ITEM)]; return service.resolve_overflow_discard(s,0,reward_set) and StringName(s.find_round_loot_state(s.players[0].player_id).carried_items[0].get("item_id",""))==&"test_move_plus_1"
func _overflow_skip()->bool:
	var s:LootRewardSession=_item_session(true).get("session") as LootRewardSession; var reward_set:Array[RewardDefinition]=[_reward_of_type(RewardDefinition.Type.CONSUMABLE_ITEM)]; return service.resolve_overflow_skip(s,reward_set) and StringName(s.find_round_loot_state(s.players[0].player_id).carried_items[0].get("item_id",""))==&"test_extra_action"
func _overflow_resumes()->bool:
	var reward:=_reward_of_type(RewardDefinition.Type.CONSUMABLE_ITEM); var silver:=_reward_of_type(RewardDefinition.Type.SILVER_COIN); var reward_set:Array[RewardDefinition]=[reward,silver]; var s:=service.build_session(_players([0]),characters,map_definition,reward_set,SequenceRewardRollSource.new([0,1]),&"r"); s.find_round_loot_state(s.players[0].player_id).carried_items.append({"item_id":"test_extra_action"}); service.resolve_trace(s,s.players[0].player_id,[&"house_a_1",&"house_b_1"],reward_set); service.resolve_overflow_skip(s,reward_set); return s.players[0].silver_coin_count==2 and s.reward_history.size()==2
func _item_ready(item_id:StringName)->LootRewardSession:
	var s:=_session([0,1]); s.players[0].consumable_inventory.append({"item_id":String(item_id)}); return s
func _item_consumes_no_move()->bool:
	var s:=_item_ready(&"test_extra_action"); var before:=s.movement_session.current_player().remaining_moves; var result:=service.use_item(s,&"test_extra_action",items); return result.success and s.players[0].consumable_inventory.is_empty() and s.movement_session.current_player().remaining_moves==before+1
func _item_limit()->bool:
	var s:=_item_ready(&"test_move_plus_1"); s.players[0].consumable_inventory.append({"item_id":"test_extra_action"}); var first:=service.use_item(s,&"test_move_plus_1",items); var second:=service.use_item(s,&"test_extra_action",items); return first.success and not second.success and second.code==&"ITEM_LIMIT_REACHED"
func _continue_enters_movement()->bool:
	var s:=_session([0]); return service.continue_without_item(s) and s.phase==LootRewardSession.Phase.MOVEMENT
func _zero_move_rotates()->bool:
	var s:=_session([0,1]); s.movement_session.player_states[0].remaining_moves=0; return service.continue_without_item(s) and s.phase==LootRewardSession.Phase.ITEM_WINDOW and s.movement_session.current_player().player_id==&"m4_player_2"
func _this_move_expires()->bool:
	var s:=_item_ready(&"test_move_plus_1"); service.use_item(s,&"test_move_plus_1",items); service.continue_without_item(s); var action:=service.perform_movement(s,map_definition,SequenceMovementRollSource.new([1]),rewards); return action!=null and action.roll_distance==2 and not s.movement_session.player_states[0].temporary_effects[0].active
func _duration_expires(duration:int)->bool:
	var s:=_item_ready(&"test_extra_action"); service.use_item(s,&"test_extra_action",items); s.movement_session.player_states[0].temporary_effects[0].duration=duration; ConsumableItemService.new().expire_duration(s.movement_session.player_states,duration); return not s.movement_session.player_states[0].temporary_effects[0].active
func _round_effect_contract()->bool:
	var s:=_item_ready(&"test_extra_action"); service.use_item(s,&"test_extra_action",items); var effect:=s.movement_session.player_states[0].temporary_effects[0]; return effect.active and effect.duration==TemporaryEffectState.Duration.THIS_ROUND
func _extra_action_runtime_only()->bool:
	var base:=characters[0].base_stamina; var s:=_item_ready(&"test_extra_action"); var before:=s.movement_session.player_states[0].remaining_moves; service.use_item(s,&"test_extra_action",items); return s.movement_session.player_states[0].remaining_moves==before+1 and characters[0].base_stamina==base
func _all_other_debuff()->bool:
	var s:=_item_ready(&"test_all_others_minus_1_move"); var self_before:=s.movement_session.player_states[0].remaining_moves; var result:=service.use_item(s,&"test_all_others_minus_1_move",items); return result.success and result.affected_player_ids==[&"m4_player_2"] and s.movement_session.player_states[0].remaining_moves==self_before and s.movement_session.player_states[1].remaining_moves==2
func _round_trip()->bool:
	var s:=_item_ready(&"test_extra_action")
	service.use_item(s,&"test_extra_action",items)
	var diagnostic: Dictionary = serializer.round_trip_diagnostic(s)
	var mismatch_value: Variant = diagnostic.get("mismatches", [])
	var mismatch_lines: Array[String] = []
	if mismatch_value is Array:
		mismatch_lines.assign(mismatch_value)
	round_trip_detail = "Round-trip semantic state PASS" if bool(diagnostic.get("matches", false)) else "Mismatch: %s" % ", ".join(mismatch_lines)
	return bool(diagnostic.get("matches", false))
