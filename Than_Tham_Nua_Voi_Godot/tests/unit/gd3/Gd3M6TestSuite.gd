class_name Gd3M6TestSuite
extends RefCounted

const SESSION := preload(
	"res://scripts/application/mvp/MvpIntegratedTwoRoundCompletionSession.gd"
)
const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const LOOT_SESSION := preload("res://scripts/domain/loot/LootRewardSession.gd")
const MANAGEMENT_SESSION := preload(
	"res://scripts/domain/equipment/EquipmentManagementSession.gd"
)
const PENDING_CHOICE := preload(
	"res://scripts/domain/equipment/PendingEquipmentChoice.gd"
)
const PLAYER_MATCH_STATE := preload("res://scripts/domain/mvp/PlayerMatchState.gd")
const TEMPORARY_EFFECT_STATE := preload(
	"res://scripts/domain/loot/TemporaryEffectState.gd"
)
const PLAYER_PHASE_STATE := preload(
	"res://scripts/domain/characters/PlayerPhaseState.gd"
)
const MOVEMENT_PLAYER_STATE := preload(
	"res://scripts/domain/loot/LootMovementPlayerState.gd"
)
const REWARD_NODE_SNAPSHOT := preload(
	"res://scripts/domain/loot/RewardNodeSnapshot.gd"
)
const EQUIPMENT_INSTANCE := preload(
	"res://scripts/domain/equipment/EquipmentInstance.gd"
)

const SCENE_PATH := "res://scenes/mvp/Gd3M6TwoRoundCompletion.tscn"
const DEBUG_HOME_PATH := "res://scenes/boot/DebugHome.tscn"


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_test_exact_m5_start_boundary(rows)
	_test_actual_round2_loot_completion(rows)
	_test_confirmation_and_management(rows)
	_test_round_end_preflight_atomicity(rows)
	_test_round_end_merge_and_idempotency(rows)
	_test_scene_and_routes(rows)
	return rows


func _test_round_end_preflight_atomicity(rows: Array[Dictionary]) -> void:
	var session: SESSION = _ready_for_round_end()
	var before: Dictionary = session.match_state.to_dict()
	session.round_state.phase = MVP_ENUMS.Phase.LOOT
	var rejected: Dictionary = session.commit_round2_end()
	_add(
		rows,
		"M6 desynchronized Round End is rejected before publish",
		String(rejected.get("code", "")) == "ROUND_END_AUTHORITY_DESYNCHRONIZED"
	)
	_add(
		rows,
		"M6 failed Round End leaves Match and active Round intact",
		session.match_state.to_dict() == before
		and session._orchestrator.active_round == session.round_state
		and not session.match_state.applied_commit_ids.has(SESSION.ROUND2_ROUND_END_COMMIT_ID)
	)


func _test_exact_m5_start_boundary(rows: Array[Dictionary]) -> void:
	var session: SESSION = SESSION.new()
	var built: Dictionary = session.build_at_round2_loot_initialized()
	_add(rows, "M6 builds from current M5 endpoint", bool(built.get("success", false)))
	_add(rows, "M6 starts at ROUND_2_LOOT_INITIALIZED", String(built.get("code", "")) == "ROUND_2_LOOT_INITIALIZED")
	_add(rows, "M6 start phase is LOOT", session.match_state.current_phase == MVP_ENUMS.Phase.LOOT)
	_add(rows, "M6 active Round is Round 2", session._orchestrator.active_round != null and session._orchestrator.active_round.round_number == 2)
	_add(rows, "M6 Round 2 settlement applied", session.round_state != null and session.round_state.settlement_applied)
	_add(rows, "M6 Round 2 settlement commit retained", session.match_state.applied_commit_ids.has(SESSION.ROUND2_SETTLEMENT_COMMIT_ID))
	_add(rows, "M6 actual Round 2 Loot session exists", session.loot_session != null and session.loot_session == session.round2_loot_session)
	_add(rows, "M6 Loot belongs to active Round 2", session.loot_session != null and session.round_state != null and session.loot_session.round_id == session.round_state.round_id)
	_add(rows, "M6 Round 2 has exactly three players", session.loot_session != null and session.loot_session.players.size() == 3)
	_add(rows, "M6 player identities remain player_1 player_2 player_3", _loot_ids(session) == [&"player_1", &"player_2", &"player_3"])
	_add(rows, "M6 exact Character origins retained", _origins_match(session), _origin_diagnostic(session))
	_add(rows, "M6 exact resolved Stamina retained", _stamina_matches(session), _stamina_diagnostic(session))
	_add(rows, "M6 Round 2 reward snapshot belongs to Round 2", _snapshots_belong_to_round(session))
	_add(rows, "M6 Round 2 movement history starts clean", session.loot_session != null and session.loot_session.movement_session.movement_history.is_empty())
	_add(rows, "M6 no Round 1 management transient is active", session.equipment_session == null)
	_add(rows, "M6 initial semantic checkpoint passes", _checkpoint(session, "round2_loot_initialized"))


func _test_actual_round2_loot_completion(rows: Array[Dictionary]) -> void:
	var session: SESSION = _ready_at_loot()
	var before_history: int = session.loot_session.movement_session.movement_history.size()
	var movement_player: MOVEMENT_PLAYER_STATE = session.loot_session.movement_session.current_player()
	var current_player: PLAYER_PHASE_STATE = (
		session.loot_session.find_player(movement_player.player_id)
		if movement_player != null
		else null
	)
	var bag_before: int = current_player.consumable_inventory.size() if current_player != null else -1
	var item_result: Dictionary = session.use_item(&"test_move_plus_1")
	_add(rows, "M6 actual Round 2 Item Window accepts carried item", bool(item_result.get("success", false)))
	_add(rows, "M6 normal item consumes no movement action", session.loot_session.movement_session.movement_history.size() == before_history)
	_add(rows, "M6 used normal item leaves persistent Bag", current_player != null and current_player.consumable_inventory.size() == bag_before - 1)
	var completed: Dictionary = session.complete_round2_loot_programmatically()
	_add(rows, "M6 actual Round 2 Loot completes", bool(completed.get("success", false)))
	_add(rows, "M6 Loot returns confirmation-ready code", String(completed.get("code", "")) == "LOOT_END_CONFIRMATION_READY")
	_add(rows, "M6 movement history records actual actions", session.loot_session.movement_session.movement_history.size() > before_history)
	_add(rows, "M6 all movement players exhausted", session.loot_session.movement_session.all_exhausted())
	_add(rows, "M6 all movement-player remaining moves are zero", session.loot_session.movement_session.player_states.all(func(player: MOVEMENT_PLAYER_STATE) -> bool: return player.remaining_moves == 0))
	_add(rows, "M6 reward resolution has no pending trace", session.loot_session.pending_trace_index >= session.loot_session.pending_trace.size())
	_add(rows, "M6 actual Round 2 reward history records resolved nodes", not session.loot_session.reward_history.is_empty())
	_add(rows, "M6 Bag overflow is resolved", not session.loot_session.overflow.active)
	_add(rows, "M6 no pending incoming item remains", session.loot_session.overflow.incoming_item_id.is_empty())
	_add(rows, "M6 temporary THIS_MOVE effects expire", _no_effect_duration(session, "THIS_MOVE"))
	_add(rows, "M6 temporary THIS_TURN effects expire", _no_effect_duration(session, "THIS_TURN"))
	_add(rows, "M6 Loot reaches exact ready phase", session.loot_session.phase == LOOT_SESSION.Phase.LOOT_END_CONFIRMATION_READY)
	_add(rows, "M6 orchestrator enters LOOT_END_CONFIRMATION", session.match_state.current_phase == MVP_ENUMS.Phase.LOOT_END_CONFIRMATION)


func _test_confirmation_and_management(rows: Array[Dictionary]) -> void:
	var session: SESSION = _ready_at_loot_finished()
	var begun: Dictionary = session.begin_round2_loot_end_confirmation()
	_add(rows, "M6 Loot End Confirmation begins", bool(begun.get("success", false)))
	_add(rows, "M6 confirmation session preserves three-player order", session.equipment_session != null and session.equipment_session.player_order.size() == 3)
	var first_id: StringName = session.equipment_session.current_player_id()
	var first: Dictionary = session.confirm_round2_loot_end(first_id)
	_add(rows, "M6 first player confirmation succeeds", bool(first.get("success", false)))
	var duplicate: Dictionary = session.confirm_round2_loot_end(first_id)
	_add(rows, "M6 duplicate confirmation is blocked", String(duplicate.get("code", "")) == "PLAYER_ALREADY_CONFIRMED")
	_add(rows, "M6 duplicate confirmation is structured no-op", bool(duplicate.get("duplicate_noop", false)))
	for player_id: StringName in session.equipment_session.player_order:
		if not session.equipment_session.confirmed_player_ids.has(player_id):
			session.confirm_round2_loot_end(player_id)
	_add(rows, "M6 all players confirm by player_id", session.equipment_session.confirmed_player_ids.size() == 3)
	_add(rows, "M6 Equipment Management starts after all confirmations", session.match_state.current_phase == MVP_ENUMS.Phase.EQUIPMENT_MANAGEMENT and session.equipment_session.phase == MANAGEMENT_SESSION.Phase.EQUIPMENT_MANAGEMENT)
	_add(rows, "M6 confirmation checkpoint round-trips", _checkpoint(session, "round2_confirmation_complete"))
	session.equipment_session.pending_choice.kind = PENDING_CHOICE.Kind.S_EQUIPMENT
	session.equipment_session.pending_choice.player_id = session.equipment_session.current_player_id()
	var blocked: Dictionary = session.mark_round2_management_done(session.equipment_session.current_player_id())
	_add(rows, "M6 pending choice blocks Management Done", String(blocked.get("code", "")) == "PENDING_CHOICE")
	session.equipment_session.pending_choice = PENDING_CHOICE.new()
	var management_order: Array[StringName] = session.equipment_session.player_order.duplicate()
	for player_id: StringName in management_order:
		session.mark_round2_management_done(player_id)
	_add(rows, "M6 every player marks Management Done", session.equipment_session.done_player_ids.size() == 3)
	_add(rows, "M6 management reaches existing ready state", session.equipment_session.phase == MANAGEMENT_SESSION.Phase.READY_FOR_M6)
	var done_duplicate: Dictionary = session.mark_round2_management_done(management_order[0])
	_add(rows, "M6 duplicate Management Done is blocked", String(done_duplicate.get("code", "")) == "PLAYER_ALREADY_DONE")
	_add(rows, "M6 duplicate Management Done is structured no-op", bool(done_duplicate.get("duplicate_noop", false)))
	_add(rows, "M6 management checkpoint round-trips", _checkpoint(session, "round2_management_complete"))


func _test_round_end_merge_and_idempotency(rows: Array[Dictionary]) -> void:
	var session: SESSION = _ready_for_round_end()
	var management_by_id: Dictionary = _management_players_by_id(session)
	var equipment_ids_before: Dictionary = _equipment_ids_by_player(session)
	var match_before: Dictionary = session.match_state.to_dict()
	session.match_state.players.reverse()
	var committed: Dictionary = session.commit_round2_end()
	_add(rows, "M6 Round 2 Round End succeeds", bool(committed.get("success", false)))
	_add(rows, "M6 Round End returns NEXT_CASE_REQUIRED", String(committed.get("code", "")) == "NEXT_CASE_REQUIRED")
	_add(rows, "M6 unique Round 2 Round-End commit recorded", session.match_state.applied_commit_ids.has(SESSION.ROUND2_ROUND_END_COMMIT_ID))
	_add(rows, "M6 Round-End commit ID does not collide", _commit_ids_unique(session))
	_add(rows, "M6 persistent merge joins reordered players by player_id", _merged_players_match(session, management_by_id))
	_add(rows, "M6 stable Equipment instance IDs persist", _equipment_ids_after_match(session, equipment_ids_before))
	_add(rows, "M6 current round number increments 2 to 3", session.match_state.current_round_number == 3)
	_add(rows, "M6 current phase returns ROUND_START boundary", session.match_state.current_phase == MVP_ENUMS.Phase.ROUND_START)
	_add(rows, "M6 Match status is NEXT_CASE_REQUIRED", session.match_state.match_completion_state == &"NEXT_CASE_REQUIRED")
	_add(rows, "M6 active Round is cleared", session._orchestrator.active_round == null)
	_add(
		rows,
		"M6 local Round 2 authority and live flags clear",
		session.round_state == null
		and not session._round2_started
		and not session._round2_completion_handled
		and not session._round2_loot_started
		and not session.round2_loot_initialized
	)
	_add(rows, "M6 Round 2 Loot references cleared", session.loot_session == null and session.round2_loot_session == null)
	_add(rows, "M6 Round 2 management reference cleared", session.equipment_session == null)
	_add(rows, "M6 Round 2 Case runtime reference cleared", session.round2_case_runtime == null)
	_add(rows, "M6 no Round 3 RoundState is created", session._orchestrator.active_round == null and not bool(session.round2_end_summary.get("round3_created", true)))
	_add(rows, "M6 no MATCH_COMPLETE transition occurs", session.match_state.current_phase != MVP_ENUMS.Phase.MATCH_COMPLETE and not bool(session.round2_end_summary.get("match_complete", true)))
	_add(rows, "M6 Round 1 and Round 2 commit history retained", _historical_commits_retained(session))
	_add(rows, "M6 semantic pre-Round-End checkpoint passes", _checkpoint(session, "round2_pre_round_end"))
	_add(rows, "M6 semantic post-Round-End checkpoint passes", _checkpoint(session, "round2_post_round_end"))
	_add(rows, "M6 all six required checkpoints pass", session.required_m6_checkpoints_pass(), "; ".join(session.checkpoint_mismatch_paths()))
	var after_first: Dictionary = session.match_state.to_dict()
	var duplicate: Dictionary = session.commit_round2_end()
	_add(rows, "M6 duplicate Round End blocked", String(duplicate.get("code", "")) == "ROUND_END_ALREADY_APPLIED")
	_add(rows, "M6 duplicate Round End is structured no-op", bool(duplicate.get("duplicate_noop", false)))
	_add(rows, "M6 duplicate Round End does not mutate MatchState", session.match_state.to_dict() == after_first)
	_add(rows, "M6 duplicate Round End does not increment again", session.match_state.current_round_number == 3)
	_add(rows, "M6 failed or duplicate commit creates no active Round", session._orchestrator.active_round == null)
	_add(rows, "M6 Round End changed state only after readiness", match_before != session.round2_post_round_end_match_snapshot)


func _test_scene_and_routes(rows: Array[Dictionary]) -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	_add(rows, "M6 harness scene loads", packed != null)
	if packed != null:
		var root: Node = packed.instantiate()
		_add(rows, "M6 scene has vertical state scroll", root.find_child("StateScroll", true, false) is ScrollContainer)
		_add(rows, "M6 scene has vertical action scroll", root.find_child("ActionScroll", true, false) is ScrollContainer)
		_add(rows, "M6 scene exposes actual movement action", root.find_child("Move", true, false) is Button)
		_add(rows, "M6 scene exposes Loot confirmation", root.find_child("BeginConfirmation", true, false) is Button)
		_add(rows, "M6 scene exposes Management Done", root.find_child("ManagementDone", true, false) is Button)
		_add(rows, "M6 scene exposes Round End commit", root.find_child("CommitRoundEnd", true, false) is Button)
		root.free()
	else:
		_add(rows, "M6 scene has vertical state scroll", false)
		_add(rows, "M6 scene has vertical action scroll", false)
		_add(rows, "M6 scene exposes actual movement action", false)
		_add(rows, "M6 scene exposes Loot confirmation", false)
		_add(rows, "M6 scene exposes Management Done", false)
		_add(rows, "M6 scene exposes Round End commit", false)
	var home_packed: PackedScene = load(DEBUG_HOME_PATH) as PackedScene
	if home_packed != null:
		var home: Node = home_packed.instantiate()
		_add(rows, "M6 DebugHome route button exists", home.find_child("Gd3M6Button", true, false) is Button)
		home.free()
	else:
		_add(rows, "M6 DebugHome route button exists", false)
	_add(
		rows,
		"M6 AppFlow constant and method exist",
		AppFlow.GD3_M6_TWO_ROUND_COMPLETION_SCENE == SCENE_PATH
		and AppFlow.has_method("go_to_gd3_m6_two_round_completion")
	)


func _ready_at_loot() -> SESSION:
	var session: SESSION = SESSION.new()
	session.build_at_round2_loot_initialized()
	return session


func _ready_at_loot_finished() -> SESSION:
	var session: SESSION = _ready_at_loot()
	session.complete_round2_loot_programmatically()
	return session


func _ready_at_management() -> SESSION:
	var session: SESSION = _ready_at_loot_finished()
	session.begin_round2_loot_end_confirmation()
	var order: Array[StringName] = session.equipment_session.player_order.duplicate()
	for player_id: StringName in order:
		session.confirm_round2_loot_end(player_id)
	return session


func _ready_for_round_end() -> SESSION:
	var session: SESSION = _ready_at_management()
	var order: Array[StringName] = session.equipment_session.player_order.duplicate()
	for player_id: StringName in order:
		session.mark_round2_management_done(player_id)
	return session


func _checkpoint(session: SESSION, key: String) -> bool:
	var value: Variant = session.checkpoints.get(key, {})
	return value is Dictionary and bool((value as Dictionary).get("matches", false))


func _loot_ids(session: SESSION) -> Array[StringName]:
	var ids: Array[StringName] = []
	if session.loot_session != null:
		for player: PlayerPhaseState in session.loot_session.players:
			ids.append(player.player_id)
	return ids


func _origins_match(session: SESSION) -> bool:
	if session.loot_session == null:
		return false
	for player: MOVEMENT_PLAYER_STATE in session.loot_session.movement_session.player_states:
		if player.current_node_id != session.expected_origin_node_for_player(player.player_id):
			return false
	return true


func _origin_diagnostic(session: SESSION) -> String:
	var values: Array[String] = []
	if session.loot_session == null:
		return "loot=MISSING"
	for player: MOVEMENT_PLAYER_STATE in session.loot_session.movement_session.player_states:
		values.append("%s expected=%s actual=%s" % [String(player.player_id), String(session.expected_origin_node_for_player(player.player_id)), String(player.current_node_id)])
	return "; ".join(values)


func _stamina_matches(session: SESSION) -> bool:
	if session.loot_session == null:
		return false
	for player: MOVEMENT_PLAYER_STATE in session.loot_session.movement_session.player_states:
		var expected: int = session.resolved_stamina_for_player(player.player_id)
		if player.stamina_snapshot != expected or player.remaining_moves != expected:
			return false
	return true


func _stamina_diagnostic(session: SESSION) -> String:
	var values: Array[String] = []
	if session.loot_session == null:
		return "loot=MISSING"
	for player: MOVEMENT_PLAYER_STATE in session.loot_session.movement_session.player_states:
		values.append("%s expected=%d actual=%d" % [String(player.player_id), session.resolved_stamina_for_player(player.player_id), player.remaining_moves])
	return "; ".join(values)


func _snapshots_belong_to_round(session: SESSION) -> bool:
	if session.loot_session == null or session.loot_session.reward_snapshots.is_empty():
		return false
	for snapshot: REWARD_NODE_SNAPSHOT in session.loot_session.reward_snapshots:
		if snapshot.round_id != session.loot_session.round_id:
			return false
	return true


func _no_effect_duration(session: SESSION, duration_name: String) -> bool:
	if session.loot_session == null:
		return false
	for player: MOVEMENT_PLAYER_STATE in session.loot_session.movement_session.player_states:
		for effect: TEMPORARY_EFFECT_STATE in player.temporary_effects:
			# GĐ2 keeps expired effect records for serialization/history. Expiration
			# means inactive with zero remaining duration, not removal from the Array.
			if (
				str(TEMPORARY_EFFECT_STATE.Duration.keys()[effect.duration]) == duration_name
				and (effect.active or effect.remaining > 0)
			):
				return false
	return true


func _management_players_by_id(session: SESSION) -> Dictionary:
	var result: Dictionary = {}
	for player: PLAYER_PHASE_STATE in session.equipment_session.players:
		result[String(player.player_id)] = player.to_dict()
	return result


func _equipment_ids_by_player(session: SESSION) -> Dictionary:
	var result: Dictionary = {}
	for player: PLAYER_PHASE_STATE in session.equipment_session.players:
		var ids: Array[String] = []
		for instance: EQUIPMENT_INSTANCE in player.equipment_collection:
			ids.append(String(instance.instance_id))
		result[String(player.player_id)] = ids
	return result


func _merged_players_match(session: SESSION, expected_by_id: Dictionary) -> bool:
	for player: PLAYER_MATCH_STATE in session.match_state.players:
		var expected_value: Variant = expected_by_id.get(String(player.player_id), {})
		if not (expected_value is Dictionary):
			return false
		var expected: Dictionary = expected_value as Dictionary
		var actual: Dictionary = player.to_dict()
		for field: String in [
			"orb_count", "gacha_ticket_count", "silver_coin_count",
			"equipment_exp_material_count", "equipment_exchange_material_count",
			"consumable_inventory", "equipment_collection", "relic_instance_id",
			"stigmata_a_instance_id", "stigmata_b_instance_id",
			"stigmata_c_instance_id", "gacha_state",
		]:
			if expected.get(field) != actual.get(field):
				return false
	return true


func _equipment_ids_after_match(session: SESSION, expected: Dictionary) -> bool:
	for player: PLAYER_MATCH_STATE in session.match_state.players:
		var actual: Array[String] = []
		for instance: EQUIPMENT_INSTANCE in player.equipment_collection:
			actual.append(String(instance.instance_id))
		var expected_value: Variant = expected.get(String(player.player_id), [])
		if not (expected_value is Array) or actual != expected_value:
			return false
	return true


func _commit_ids_unique(session: SESSION) -> bool:
	var ids: Array[StringName] = session.match_state.applied_commit_ids
	var seen: Dictionary = {}
	for id: StringName in ids:
		if seen.has(String(id)):
			return false
		seen[String(id)] = true
	return SESSION.ROUND2_ROUND_END_COMMIT_ID != SESSION.ROUND_END_COMMIT_ID and SESSION.ROUND2_ROUND_END_COMMIT_ID != SESSION.ROUND2_SETTLEMENT_COMMIT_ID


func _historical_commits_retained(session: SESSION) -> bool:
	return (
		session.match_state.applied_commit_ids.has(SESSION.SETTLEMENT_COMMIT_ID)
		and session.match_state.applied_commit_ids.has(SESSION.ROUND_END_COMMIT_ID)
		and session.match_state.applied_commit_ids.has(SESSION.ROUND2_SETTLEMENT_COMMIT_ID)
		and session.match_state.applied_commit_ids.has(SESSION.ROUND2_ROUND_END_COMMIT_ID)
	)


func _add(rows: Array[Dictionary], name: String, passed: bool, detail: String = "") -> void:
	rows.append({"name": name, "passed": passed, "detail": detail if not detail.is_empty() else "GĐ3-M6 bounded two-Round completion invariant"})
