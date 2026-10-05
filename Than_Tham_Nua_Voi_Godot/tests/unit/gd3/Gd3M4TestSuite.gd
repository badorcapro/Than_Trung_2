class_name Gd3M4TestSuite
extends RefCounted

const SESSION := preload(
	"res://scripts/application/mvp/MvpIntegratedRoundCompletionSession.gd"
)
const MVP_ENUMS := preload("res://scripts/domain/mvp/MvpEnums.gd")
const EQUIPMENT_SESSION := preload(
	"res://scripts/domain/equipment/EquipmentManagementSession.gd"
)
const LOOT_REWARD_SESSION := preload("res://scripts/domain/loot/LootRewardSession.gd")
const PENDING_CHOICE := preload("res://scripts/domain/equipment/PendingEquipmentChoice.gd")
const CASE_BOUNDARY := preload("res://scripts/domain/mvp/MvpCaseCompletionBoundary.gd")

const SCENE_PATH := "res://scenes/mvp/Gd3M4RoundCompletion.tscn"


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_test_round_completion(rows)
	_test_guards(rows)
	_test_scene(rows)
	return rows


func _test_round_completion(rows: Array[Dictionary]) -> void:
	var session: SESSION = _ready_for_confirmation()
	_add(rows, "M4 reuses M3 integrated MatchState", session != null and session.match_state != null)
	_add(rows, "M4 reuses active RoundState", session != null and session.round_state != null)
	_add(rows, "M4 Loot finished checkpoint exists", _checkpoint(session, "loot_finished"))
	_add(rows, "M4 starts at Loot End Confirmation phase", session.match_state.current_phase == MVP_ENUMS.Phase.LOOT_END_CONFIRMATION)
	_add(rows, "M4 all movement actions exhausted", session.loot_session.movement_session.all_exhausted())
	_add(rows, "M4 no overflow remains", not session.loot_session.overflow.active)
	_add(rows, "M4 no reward trace remains", session.loot_session.pending_trace_index >= session.loot_session.pending_trace.size())
	var begun: Dictionary = session.begin_loot_end_confirmation()
	_add(rows, "M4 actual Loot End Confirmation begins", bool(begun.get("success", false)))
	_add(rows, "M4 actual management projection exists", session.equipment_session != null)
	_add(rows, "M4 projection contains three players", session.equipment_session.players.size() == 3)
	_add(rows, "M4 projection preserves player order", session.equipment_session.player_order == session.match_state.player_order)
	_add(rows, "M4 projection preserves Bag", session.equipment_session.players[0].consumable_inventory == session.match_state.players[0].consumable_inventory)
	_add(rows, "M4 projection preserves Equipment collection", session.equipment_session.players[0].equipment_collection.size() == session.match_state.players[0].equipment_collection.size())
	_add(rows, "M4 projection preserves Gacha state", session.equipment_session.players[0].gacha_state.to_dict() == session.match_state.players[0].gacha_state.to_dict())
	var first_id: StringName = session.equipment_session.current_player_id()
	var first_confirm: Dictionary = session.confirm_loot_end(first_id)
	_add(rows, "M4 first player confirmation succeeds", bool(first_confirm.get("success", false)))
	_add(rows, "M4 one confirmation does not finish phase", session.equipment_session.phase == EQUIPMENT_SESSION.Phase.LOOT_END_CONFIRMATION)
	_add(rows, "M4 first confirmation stored by ID", session.equipment_session.confirmed_player_ids.has(first_id))
	var duplicate_confirm: Dictionary = session.confirm_loot_end(first_id)
	_add(rows, "M4 duplicate confirmation blocked", String(duplicate_confirm.get("code", "")) == "PLAYER_ALREADY_CONFIRMED")
	_add(rows, "M4 duplicate confirmation is structured no-op", bool(duplicate_confirm.get("duplicate_noop", false)))
	for player_id: StringName in session.equipment_session.player_order:
		if not session.equipment_session.confirmed_player_ids.has(player_id):
			session.confirm_loot_end(player_id)
	_add(rows, "M4 all players confirmed", session.equipment_session.confirmed_player_ids.size() == 3)
	_add(rows, "M4 enters actual Equipment Management", session.equipment_session.phase == EQUIPMENT_SESSION.Phase.EQUIPMENT_MANAGEMENT)
	_add(rows, "M4 orchestrator enters Equipment Management", session.match_state.current_phase == MVP_ENUMS.Phase.EQUIPMENT_MANAGEMENT)
	_add(rows, "M4 loot_end_confirmed checkpoint round-trips", _checkpoint(session, "loot_end_confirmed"))
	_add(rows, "M4 management_started checkpoint round-trips", _checkpoint(session, "management_started"))
	var managed_player: PlayerPhaseState = session.equipment_session.find_player(session.equipment_session.current_player_id())
	var ss_diagnostic: Dictionary = session.ss_shop_eligibility_diagnostic()
	var player_before_ss_shop: Dictionary = managed_player.to_dict()
	var currency_key: String = String(managed_player.player_id)
	var currency_before_ss_shop: int = int(session.equipment_session.test_ss_shop_currency_by_player.get(currency_key, 0))
	var rejected_ss_shop: Dictionary = session.purchase_first_unlocked_ss()
	var rejected_code: StringName = StringName(String(rejected_ss_shop.get("code", &"")))
	var expected_reject_code: StringName = (
		&"SS_SHOP_NO_UNLOCKED_EQUIPMENT"
		if managed_player.gacha_state.ss_unlocked_equipment_ids.is_empty()
		else &"SS_SHOP_DEFINITION_NOT_FOUND"
	)
	_add(
		rows,
		"M4 SS Shop with no eligible SS returns blocked state",
		int(ss_diagnostic.get("eligible_ss_count", -1)) == 0
		and not bool(rejected_ss_shop.get("success", false))
		and rejected_code == expected_reject_code
		and managed_player.to_dict() == player_before_ss_shop
		and int(session.equipment_session.test_ss_shop_currency_by_player.get(currency_key, 0)) == currency_before_ss_shop,
		"eligible_ss_count=%d; selected_definition_id=%s; resolved_definition=%s; success=%s; code=%s; message=%s; session_phase=%s" % [
			ss_diagnostic.get("eligible_ss_count", -1),
			ss_diagnostic.get("selected_definition_id", ""),
			ss_diagnostic.get("resolved_definition", false),
			rejected_ss_shop.get("success", false),
			rejected_code,
			rejected_ss_shop.get("message", ""),
			ss_diagnostic.get("session_phase", -1),
		]
	)
	var collection_before: int = managed_player.equipment_collection.size()
	var granted: Dictionary = session.grant_and_equip_test_relic()
	_add(rows, "M4 actual Equipment grant and equip succeeds", bool(granted.get("success", false)))
	_add(
		rows,
		"M4 Equipment collection gains actual instance",
		managed_player.equipment_collection.size() == collection_before + 1
		and _instance_ids_are_unique(managed_player)
	)
	_add(rows, "M4 equipped instance ID resolves", not managed_player.relic_instance_id.is_empty() and _has_instance(managed_player, managed_player.relic_instance_id))
	var equipped_id: StringName = managed_player.relic_instance_id
	var exp_before: int = managed_player.equipment_exp_material_count
	var gold_result: Dictionary = session.upgrade_equipped_relic_gold()
	var equipped_instance: EquipmentInstance = _find_instance(managed_player, equipped_id)
	_add(rows, "M4 actual Gold upgrade succeeds", bool(gold_result.get("success", false)))
	_add(rows, "M4 Gold level advances", equipped_instance != null and equipped_instance.gold_star_level == 2)
	_add(rows, "M4 Gold upgrade consumes authored EXP", managed_player.equipment_exp_material_count < exp_before)
	var collection_before_purple: int = managed_player.equipment_collection.size()
	var purple_result: Dictionary = session.promote_equipped_relic_purple()
	_add(rows, "M4 actual Purple promotion succeeds", bool(purple_result.get("success", false)))
	_add(rows, "M4 Purple level advances", equipped_instance != null and equipped_instance.purple_star_level == 1)
	_add(rows, "M4 Purple duplicate is consumed", managed_player.equipment_collection.size() == collection_before_purple)
	var tickets_before: int = managed_player.gacha_ticket_count
	var pity_before: int = managed_player.gacha_state.consecutive_without_a_plus
	var gacha_result: Dictionary = session.basic_gacha_roll()
	_add(rows, "M4 actual Basic Gacha succeeds", bool(gacha_result.get("success", false)))
	_add(rows, "M4 Basic Gacha consumes one Ticket", managed_player.gacha_ticket_count == tickets_before - 1)
	_add(
		rows,
		"M4 Basic Gacha updates pity",
		managed_player.gacha_state.consecutive_without_a_plus == pity_before + 1,
		"pity_before=%d; pity_after=%d; deterministic rarity roll=10 (B)" % [
			pity_before, managed_player.gacha_state.consecutive_without_a_plus
		]
	)
	_add(rows, "M4 Gacha history records action", not session.equipment_session.gacha_history.is_empty())
	_add(rows, "M4 Perfect OPEN policy ID preserved", String(session.match_state.open_policy_config_ids.get("perfect_round_end", "")) == SESSION.PERFECT_POLICY_ID)
	for player_id: StringName in session.equipment_session.player_order:
		var done: Dictionary = session.mark_management_done(player_id)
		_add(rows, "M4 management done accepted for %s" % player_id, bool(done.get("success", false)))
	_add(rows, "M4 all management players done", session.equipment_session.done_player_ids.size() == 3)
	_add(rows, "M4 management reaches ready state", session.equipment_session.phase == EQUIPMENT_SESSION.Phase.READY_FOR_M6)
	_add(rows, "M4 management_complete checkpoint round-trips", _checkpoint(session, "management_complete"))
	var round_before: int = session.match_state.current_round_number
	var merit_before: float = session.match_state.players[0].merit_progress
	var reputation_before: int = session.match_state.players[0].reputation
	var committed: Dictionary = session.commit_round_end()
	_add(
		rows,
		"M4 Round End commit succeeds",
		bool(committed.get("success", false)),
		"code=%s; message=%s" % [committed.get("code", ""), committed.get("message", "")]
	)
	_add(rows, "M4 Round End works after rejected SS Shop action", bool(committed.get("success", false)))
	_add(rows, "M4 Round End returns NEXT_CASE_REQUIRED", String(committed.get("code", "")) == "NEXT_CASE_REQUIRED")
	_add(rows, "M4 round number increments exactly once", session.match_state.current_round_number == round_before + 1)
	_add(rows, "M4 final status is NEXT_CASE_REQUIRED", session.match_state.match_completion_state == &"NEXT_CASE_REQUIRED")
	_add(rows, "M4 Round End commit ledger updated", session.match_state.applied_commit_ids.has(SESSION.ROUND_END_COMMIT_ID))
	_add(rows, "M4 active Round clears", bool(session.round_end_summary.get("active_round_cleared", false)))
	_add(rows, "M4 Equipment instance ID persists", session.match_state.players[0].relic_instance_id == equipped_id and _has_match_instance(session, equipped_id))
	_add(rows, "M4 Basic pity persists", session.match_state.players[0].gacha_state.consecutive_without_a_plus == managed_player.gacha_state.consecutive_without_a_plus)
	_add(rows, "M4 Ticket result persists", session.match_state.players[0].gacha_ticket_count == managed_player.gacha_ticket_count)
	_add(rows, "M4 Bag persists", session.match_state.players[0].consumable_inventory == managed_player.consumable_inventory)
	_add(rows, "M4 Merit remains unchanged", is_equal_approx(session.match_state.players[0].merit_progress, merit_before))
	_add(rows, "M4 Reputation remains unchanged", session.match_state.players[0].reputation == reputation_before)
	_add(rows, "M4 Loot node does not merge", not session.match_state.players[0].to_dict().has("current_node_id"))
	_add(rows, "M4 remaining moves do not merge", not session.match_state.players[0].to_dict().has("remaining_moves"))
	_add(rows, "M4 temporary effects do not merge", not session.match_state.players[0].to_dict().has("temporary_effects"))
	_add(rows, "M4 pre_round_end checkpoint round-trips", _checkpoint(session, "pre_round_end"))
	_add(rows, "M4 post_round_end checkpoint round-trips", _checkpoint(session, "post_round_end"))
	var round_after: int = session.match_state.current_round_number
	var state_after: Dictionary = session.match_state.to_dict()
	var duplicate_commit: Dictionary = session.commit_round_end()
	_add(rows, "M4 duplicate Round End blocked", String(duplicate_commit.get("code", "")) == "ROUND_END_ALREADY_APPLIED")
	_add(rows, "M4 duplicate Round End structured no-op", bool(duplicate_commit.get("duplicate_noop", false)))
	_add(rows, "M4 duplicate commit does not increment", session.match_state.current_round_number == round_after)
	_add(rows, "M4 duplicate commit does not mutate persistent state", session.match_state.to_dict() == state_after)
	_add(rows, "M4 does not create next Round", session.round_end_summary.get("status", "") == "NEXT_CASE_REQUIRED")
	_add(rows, "M4 all semantic checkpoints pass", session.checkpoints.size() == 9 and session.checkpoints_pass(), "; ".join(session.checkpoint_mismatch_paths()))


func _test_guards(rows: Array[Dictionary]) -> void:
	var early: SESSION = SESSION.new()
	early.build_integrated_fixture()
	_add(rows, "M4 premature confirmation blocked", String(early.begin_loot_end_confirmation().get("code", "")) == "LOOT_NOT_FINISHED")
	_add(rows, "M4 premature Round End blocked", String(early.commit_round_end().get("code", "")) == "ROUND_END_PHASE_INVALID")
	var session: SESSION = _ready_for_confirmation()
	session.begin_loot_end_confirmation()
	for player_id: StringName in session.equipment_session.player_order:
		if not session.equipment_session.confirmed_player_ids.has(player_id):
			session.confirm_loot_end(player_id)
	_add(rows, "M4 incomplete management blocks Round End", String(session.commit_round_end().get("code", "")) == "MANAGEMENT_INCOMPLETE")
	var current_id: StringName = session.equipment_session.current_player_id()
	session.equipment_session.pending_choice.kind = PENDING_CHOICE.Kind.S_EQUIPMENT
	session.equipment_session.pending_choice.player_id = current_id
	_add(rows, "M4 pending choice blocks management done", String(session.mark_management_done(current_id).get("code", "")) == "PENDING_CHOICE")
	session.equipment_session.pending_choice = PENDING_CHOICE.new()
	_add(rows, "M4 empty Round End commit blocked", String(session.commit_round_end(&"").get("code", "")) == "ROUND_END_COMMIT_MISSING")


func _test_scene(rows: Array[Dictionary]) -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	_add(rows, "M4 integrated entry scene loads", packed != null)
	if packed == null:
		return
	var root: Node = packed.instantiate()
	_add(rows, "M4 scene retains actual Case host", root.find_child("CaseHost", true, false) != null)
	_add(rows, "M4 scene has responsive main scroll", root.find_child("ManagementScroll", true, false) is ScrollContainer)
	_add(rows, "M4 scene exposes confirmation action", root.find_child("ConfirmLootEnd", true, false) is Button)
	_add(rows, "M4 scene exposes actual management actions", root.find_child("ManagementActions", true, false) is GridContainer)
	_add(rows, "M4 scene exposes Round End commit", root.find_child("CommitRoundEnd", true, false) is Button)
	_add(rows, "M4 scene exposes NEXT_CASE_REQUIRED summary", root.find_child("RoundEndSummary", true, false) is RichTextLabel)
	root.free()


func _ready_for_confirmation() -> SESSION:
	var session: SESSION = SESSION.new()
	var built: Dictionary = session.build_integrated_fixture()
	if not bool(built.get("success", false)):
		return session
	var boundary: CASE_BOUNDARY = session.build_test_only_completed_boundary()
	if boundary == null or not bool(session.handle_case_completion(boundary).get("success", false)):
		return session
	if not bool(session.begin_loot().get("success", false)):
		return session
	var guard := 0
	while (
		session.loot_session != null
		and session.loot_session.phase != LOOT_REWARD_SESSION.Phase.LOOT_END_CONFIRMATION_READY
		and guard < 120
	):
		guard += 1
		match session.loot_session.phase:
			LOOT_REWARD_SESSION.Phase.ITEM_WINDOW:
				session.continue_without_item()
			LOOT_REWARD_SESSION.Phase.MOVEMENT:
				session.move()
			LOOT_REWARD_SESSION.Phase.BAG_OVERFLOW_PENDING:
				session.resolve_overflow_skip()
	return session


func _checkpoint(session: SESSION, key: String) -> bool:
	if session == null:
		return false
	var value: Variant = session.checkpoints.get(key, {})
	return value is Dictionary and bool(value.get("matches", false))


func _has_instance(player: PlayerPhaseState, instance_id: StringName) -> bool:
	for instance: EquipmentInstance in player.equipment_collection:
		if instance.instance_id == instance_id:
			return true
	return false


func _find_instance(player: PlayerPhaseState, instance_id: StringName) -> EquipmentInstance:
	for instance: EquipmentInstance in player.equipment_collection:
		if instance.instance_id == instance_id:
			return instance
	return null


func _instance_ids_are_unique(player: PlayerPhaseState) -> bool:
	var seen: Dictionary = {}
	for instance: EquipmentInstance in player.equipment_collection:
		if seen.has(instance.instance_id):
			return false
		seen[instance.instance_id] = true
	return true


func _has_match_instance(session: SESSION, instance_id: StringName) -> bool:
	for instance: EquipmentInstance in session.match_state.players[0].equipment_collection:
		if instance.instance_id == instance_id:
			return true
	return false


func _add(rows: Array[Dictionary], name: String, passed: bool, detail: String = "") -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": detail if not detail.is_empty() else "GĐ3-M4 integrated round-completion invariant",
	})
