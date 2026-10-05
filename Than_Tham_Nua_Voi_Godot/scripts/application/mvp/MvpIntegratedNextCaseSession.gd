class_name MvpIntegratedNextCaseSession
extends "res://scripts/application/mvp/MvpIntegratedRoundCompletionSession.gd"

const LOOT_REWARD_SESSION := preload("res://scripts/domain/loot/LootRewardSession.gd")
const CASE_GENERATION_ACCEPTANCE_SERVICE := preload("res://scripts/domain/cases/CaseGenerationAcceptanceService.gd")
const CASE_GENERATION_ACCEPTANCE_RESULT := preload("res://scripts/domain/cases/CaseGenerationAcceptanceResult.gd")
const CASE_GENERATION_REQUEST_TYPE := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")
const CASE_GENERATOR := preload("res://scripts/domain/cases/CaseGenerator.gd")
const CASE_SEED_WAREHOUSE_BUILDER := preload("res://scripts/domain/cases/CaseSeedWarehouseBuilder.gd")
const CASE_SEED_WAREHOUSE_ENTRY := preload("res://scripts/domain/cases/CaseSeedWarehouseEntry.gd")
const CASE_SEED_WAREHOUSE_OPTION_COMPOSER := preload("res://scripts/domain/cases/CaseSeedWarehouseOptionComposer.gd")
const CASE_SEED_WAREHOUSE_OPTION_SET_RESULT := preload("res://scripts/domain/cases/CaseSeedWarehouseOptionSetResult.gd")
const CASE_GENERATION_AUDIT_SNAPSHOT := preload("res://scripts/tools/CaseGenerationAuditSnapshot.gd")

const ROUND2_ROUND_ID := &"gd3_m5_round_002"
const ROUND2_SETTLEMENT_COMMIT_ID := &"gd3_m5_round2_settlement_001"
const ROUTING_POLICY_ID := "next_case_routing_fixture_test_only"
const ROUND2_CASE_ID := &"vs_case_001"
const PLAYER_FACING_ROUND1_END_COMMIT_ID := &"pf_m4_round_end_001"
const DEFAULT_NEXT_CASE_OPTION_SET_SEED := 20260829
const DEFAULT_NEXT_CASE_WAREHOUSE_TARGET_COUNT := 8
const DEFAULT_NEXT_CASE_MAX_ATTEMPTS := 24

var round2_case_definition: CaseDefinition
var round2_projected_case_players: Array[PlayerCaseState] = []
var round2_turn_manager: TurnManager
var round2_case_runtime: CaseRuntimeState
var round2_normalized_result: MVP_CASE_RESULT
var round2_loot_session: LootRewardSession
var round2_loot_initialized := false
var round2_settlement_summary: Array[Dictionary] = []
var round1_loot_session_at_end: LootRewardSession
var round1_persistent_snapshot_by_player: Dictionary = {}

# Canonical authority for whichever continuation Round is currently active.
# The round2_* members below remain as first-continuation compatibility mirrors
# for the historical GĐ3-M5/M6 harnesses; player-facing runtime does not route by them.
var active_case_definition: CaseDefinition
var active_projected_case_players: Array[PlayerCaseState] = []
var active_turn_manager: TurnManager
var active_case_runtime: CaseRuntimeState
var active_normalized_result: MVP_CASE_RESULT
var active_loot_session: LootRewardSession
var active_settlement_summary_rows: Array[Dictionary] = []
var _active_round_start_merit_by_player: Dictionary = {}
var next_case_option_set: CASE_SEED_WAREHOUSE_OPTION_SET_RESULT
var next_case_option_definitions: Array[CaseDefinition] = []
var selected_case_candidate_signature: String = ""
var selected_case_option_index: int = -1
var default_next_case_warehouse: RefCounted

var _round2_started := false
var _round2_completion_handled := false
var _round2_loot_started := false
var _active_continuation_round := false
var _active_completion_handled := false
var _active_loot_started := false
var _continuation_rounds_started := 0
var _legacy_round2_active := false


func initialize_player_facing_case(
	source_match: M4_MVP_MATCH_STATE, selected_case: CaseDefinition
) -> Dictionary:
	var result: Dictionary = super.initialize_player_facing_case(source_match, selected_case)
	if bool(result.get("success", false)):
		_capture_active_round_start_merit()
	return result


func initialize_player_facing_case_options(source_match: M4_MVP_MATCH_STATE) -> Dictionary:
	_reset()
	_reset_active_continuation_references()
	_clear_next_case_options()
	default_next_case_warehouse = null
	if source_match == null:
		return _failure(&"PLAYER_CASE_CONTEXT_MISSING", "Match is required")
	if (
		not source_match.character_selection_complete
		or source_match.players.size() != 3
		or source_match.current_phase != M4_MVP_ENUMS.Phase.ROUND_START
	):
		return _failure(
			&"PLAYER_CASE_SETUP_INVALID",
			"Completed three-player setup at ROUND_START is required"
		)
	match_state = source_match
	match_state.current_round_number = 1
	match_state.match_completion_state = &"NEXT_CASE_REQUIRED"
	_initialize_player_facing_production_content()
	_orchestrator.initialize(match_state)
	enable_player_facing_test_collection_bootstrap()
	_settlement_commit_id = PLAYER_FACING_SETTLEMENT_COMMIT_ID
	checkpoints["first_case_options_ready"] = _serializer.round_trip_diagnostic(
		match_state, null
	)
	event_log.append("Player-facing flow prepared generated first-Case options")
	return _success(&"PLAYER_CASE_OPTIONS_READY", "Generated first Case options can be composed")


func restore_player_facing_between_rounds(source_match: M4_MVP_MATCH_STATE) -> Dictionary:
	_reset()
	_reset_active_continuation_references()
	_clear_next_case_options()
	default_next_case_warehouse = null
	if source_match == null:
		return _failure(&"PLAYER_CASE_CONTEXT_MISSING", "Saved Match is required")
	var restored_match: M4_MVP_MATCH_STATE = M4_MVP_MATCH_STATE.from_dict(
		source_match.to_dict()
	)
	var report: MVP_VALIDATION_REPORT = MATCH_VALIDATOR.new().validate(restored_match)
	if not report.passed():
		return _failure(&"PLAYER_CASE_RESTORE_INVALID", ", ".join(report.codes()))
	if (
		not restored_match.character_selection_complete
		or restored_match.players.size() != 3
		or restored_match.current_phase != M4_MVP_ENUMS.Phase.ROUND_START
		or restored_match.match_completion_state != &"NEXT_CASE_REQUIRED"
		or restored_match.completed_round_count < 1
	):
		return _failure(
			&"PLAYER_CASE_RESTORE_BOUNDARY_INVALID",
			"A committed between-Rounds Match is required"
		)
	match_state = restored_match
	_initialize_player_facing_production_content()
	_orchestrator.initialize(match_state)
	enable_player_facing_test_collection_bootstrap()
	_settlement_commit_id = PLAYER_FACING_SETTLEMENT_COMMIT_ID
	event_log.append("Player-facing Match restored at NEXT_CASE_REQUIRED")
	return _success(
		&"PLAYER_CASE_BETWEEN_ROUNDS_RESTORED",
		"Saved Match is ready for one fresh next-Case option composition"
	)


func build_integrated_fixture() -> Dictionary:
	var result: Dictionary = super.build_integrated_fixture()
	if bool(result.get("success", false)):
		match_state.match_id = &"gd3_m5_integrated_match"
		match_state.open_policy_config_ids["next_case_routing"] = ROUTING_POLICY_ID
		round2_case_definition = null
		round2_projected_case_players.clear()
		round2_turn_manager = null
		round2_case_runtime = null
		round2_normalized_result = null
		round2_loot_session = null
		round2_loot_initialized = false
		round2_settlement_summary.clear()
		round1_loot_session_at_end = null
		round1_persistent_snapshot_by_player.clear()
		_round2_started = false
		_round2_completion_handled = false
		_round2_loot_started = false
		_reset_active_continuation_references()
		_clear_next_case_options()
		default_next_case_warehouse = null
		selected_case_candidate_signature = ""
		selected_case_option_index = -1
		_continuation_rounds_started = 0
		_legacy_round2_active = false
	return result


func begin_loot() -> Dictionary:
	if match_state != null and match_state.match_completion_state == &"MATCH_COMPLETE":
		return _failure(&"MATCH_ALREADY_COMPLETE", "A completed Match cannot enter Loot")
	# Player-facing callers use one active-Round API. Once next-round ownership is
	# published, dispatch to that Round's existing Loot authority instead of the
	# completed Round 1 guard retained by the inherited implementation.
	if _active_continuation_round:
		return begin_active_round_loot()
	return super.begin_loot()


func handle_case_completion(boundary: MVP_CASE_COMPLETION_BOUNDARY) -> Dictionary:
	if match_state != null and match_state.match_completion_state == &"MATCH_COMPLETE":
		return _failure(&"MATCH_ALREADY_COMPLETE", "A completed Match cannot accept gameplay actions")
	if _active_continuation_round:
		return handle_active_round_case_completion(boundary)
	return super.handle_case_completion(boundary)


func active_settlement_summary() -> Array[Dictionary]:
	return active_settlement_summary_rows if _active_continuation_round else settlement_summary


func active_case_players() -> Array[PlayerCaseState]:
	return active_projected_case_players if _active_continuation_round else projected_case_players


func active_round_start_merit_by_player() -> Dictionary:
	return _active_round_start_merit_by_player.duplicate(true)


func active_round_number() -> int:
	return round_state.round_number if round_state != null else match_state.current_round_number


func active_player_facing_round_end_commit_id() -> StringName:
	# Preserve the already-shipped Round 1 identity. Once that commit is present,
	# every subsequently attached Round derives an identity from its own round_id.
	# This keeps idempotency per Round without controller-side milestone branching.
	if (
		match_state != null
		and not match_state.applied_commit_ids.has(PLAYER_FACING_ROUND1_END_COMMIT_ID)
	):
		return PLAYER_FACING_ROUND1_END_COMMIT_ID
	if round_state == null or round_state.round_id.is_empty():
		return &""
	return StringName("pf_round_end_%s" % String(round_state.round_id))


func commit_round_end(commit_id: StringName = ROUND_END_COMMIT_ID) -> Dictionary:
	var result: Dictionary = super.commit_round_end(commit_id)
	if bool(result.get("success", false)) and _active_continuation_round:
		# The orchestrator has cleared active_round. Release only the active lifecycle
		# ownership flag so the same public start_next_round() API can attach the next
		# Round. Historical round2_* mirrors remain intact for technical harnesses.
		_active_continuation_round = false
		_clear_next_case_options()
	return result


func compose_next_case_options(
	warehouse,
	option_set_seed: int,
	profile_request: CaseGenerationRequest,
	role_definitions: Array[RoleDefinition] = [],
	requested_option_count: int = 3,
	max_attempts: int = 24,
	attempt_evaluator: Callable = Callable(),
	case_definition_resolver: Callable = Callable()
) -> Dictionary:
	if next_case_option_set != null and next_case_option_set.success:
		return {
			"success": true,
			"code": String(&"NEXT_CASE_OPTIONS_READY"),
			"message": "Next Case options already composed",
			"duplicate_noop": true,
		}
	if match_state == null:
		return _failure(&"MATCH_STATE_MISSING", "Match state is required")
	if match_state.current_phase != M4_MVP_ENUMS.Phase.ROUND_START:
		return _failure(
			&"WRONG_START_PHASE",
			"Round Start phase is required to compose next cases; current is %s"
			% M4_MVP_ENUMS.phase_name(match_state.current_phase)
		)
	if match_state.match_completion_state != &"NEXT_CASE_REQUIRED":
		return _failure(
			&"NEXT_CASE_NOT_REQUIRED",
			"Previous round must reach NEXT_CASE_REQUIRED; current is %s"
			% str(match_state.match_completion_state)
		)
	var used_signatures: Array[String] = []
	for signature: String in match_state.used_case_candidate_signatures:
		used_signatures.append(signature)
	var composed: CASE_SEED_WAREHOUSE_OPTION_SET_RESULT = CASE_SEED_WAREHOUSE_OPTION_COMPOSER.new().compose_options(
		warehouse,
		option_set_seed,
		used_signatures,
		profile_request,
		role_definitions,
		requested_option_count,
		max_attempts,
		attempt_evaluator
	)
	if not composed.success:
		next_case_option_set = composed
		next_case_option_definitions.clear()
		return _failure(
			&"NEXT_CASE_OPTIONS_UNAVAILABLE",
			"Failed to compose three generated case options: %s" % String(composed.failure_reason)
		)
	var definitions: Array[CaseDefinition] = []
	for option_entry: CASE_SEED_WAREHOUSE_ENTRY in composed.option_entries:
		var definition: CaseDefinition = _case_definition_from_warehouse_entry(
			option_entry, role_definitions, max_attempts, attempt_evaluator, case_definition_resolver
		)
		if definition == null:
			next_case_option_set = composed
			next_case_option_definitions.clear()
			return _failure(
				&"NEXT_CASE_OPTION_DEFINITION_FAILED",
				"Failed to resolve selected warehouse option into a CaseDefinition"
			)
		definitions.append(definition)
	next_case_option_set = composed
	next_case_option_definitions = definitions
	return _success(&"NEXT_CASE_OPTIONS_READY", "Three generated Case options are ready")


func prepare_default_next_case_options() -> Dictionary:
	if match_state != null and match_state.match_completion_state == &"MATCH_COMPLETE":
		return _failure(&"MATCH_ALREADY_COMPLETE", "A completed Match cannot compose another Case")
	if next_case_option_set != null:
		if next_case_option_set.success:
			return {
				"success": true,
				"code": String(&"NEXT_CASE_OPTIONS_READY"),
				"message": "Next Case options already composed",
				"duplicate_noop": true,
			}
		return _failure(
			&"NEXT_CASE_OPTIONS_UNAVAILABLE",
			"Generated Case options were already attempted and are unavailable: %s"
			% String(next_case_option_set.failure_reason)
		)
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var request: CaseGenerationRequest = _default_next_case_generation_request()
	var warehouse: RefCounted = _default_next_case_warehouse(
		request, roles
	)
	var selection_request: CaseGenerationRequest = request
	if match_state != null and match_state.case_generation_seed > 0:
		selection_request = CASE_GENERATION_REQUEST_TYPE.create(
			request.seed,
			request.board_columns,
			request.board_rows,
			request.generation_profile_id,
			request.allowed_role_ids,
			request.required_location_ids,
			0,
			request.generator_version
		)
	return compose_next_case_options(
		warehouse,
		_default_next_case_option_seed(),
		selection_request,
		roles,
		3,
		DEFAULT_NEXT_CASE_MAX_ATTEMPTS
	)


func case_option_presentations() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	if next_case_option_set == null or not next_case_option_set.success:
		return rows
	for index: int in range(next_case_option_set.option_entries.size()):
		var entry: CASE_SEED_WAREHOUSE_ENTRY = next_case_option_set.option_entries[index]
		var definition: CaseDefinition = next_case_option_definitions[index] if index < next_case_option_definitions.size() else null
		rows.append({
			"option_index": index,
			"candidate_signature": entry.candidate_signature if entry != null else "",
			"warehouse_index": next_case_option_set.option_warehouse_indices[index] if index < next_case_option_set.option_warehouse_indices.size() else -1,
			"case_id": definition.case_id if definition != null else &"",
			"name": definition.display_name if definition != null else "",
			"description": definition.short_description if definition != null else "",
		})
	return rows


func start_next_round_from_option(option_index: int, tie_break_seed: int = 20260828) -> Dictionary:
	if next_case_option_set == null or not next_case_option_set.success:
		return _failure(&"NEXT_CASE_OPTIONS_MISSING", "Generated Case options must be composed before voting")
	if option_index < 0 or option_index >= next_case_option_definitions.size():
		return _failure(&"NEXT_CASE_OPTION_INVALID", "Selected Case option index is invalid")
	var selected_case: CaseDefinition = next_case_option_definitions[option_index]
	var signature: String = next_case_option_set.option_candidate_signatures[option_index]
	var started: Dictionary = _start_next_round_with_case(
		selected_case,
		signature,
		option_index,
		tie_break_seed
	)
	if bool(started.get("success", false)):
		_commit_used_case_signature(signature)
	return started


func complete_round_1_programmatically() -> Dictionary:
	if match_state == null:
		return _failure(&"MATCH_STATE_MISSING", "Match state is required")
	var boundary: MVP_CASE_COMPLETION_BOUNDARY = build_test_only_completed_boundary()
	if boundary == null:
		return _failure(&"ROUND_1_BOUNDARY_FAILED", "Failed to build Round 1 boundary")
	var case_handled: Dictionary = handle_case_completion(boundary)
	if not bool(case_handled.get("success", false)):
		return case_handled
	var loot_begun: Dictionary = begin_loot()
	if not bool(loot_begun.get("success", false)):
		return loot_begun
	var guard := 0
	while (
		loot_session != null
		and loot_session.phase != LOOT_REWARD_SESSION.Phase.LOOT_END_CONFIRMATION_READY
		and guard < 120
	):
		guard += 1
		match loot_session.phase:
			LOOT_REWARD_SESSION.Phase.ITEM_WINDOW:
				continue_without_item()
			LOOT_REWARD_SESSION.Phase.MOVEMENT:
				move()
			LOOT_REWARD_SESSION.Phase.BAG_OVERFLOW_PENDING:
				resolve_overflow_skip()
	var conf_started: Dictionary = begin_loot_end_confirmation()
	if not bool(conf_started.get("success", false)):
		return conf_started
	for player_id: StringName in equipment_session.player_order:
		confirm_loot_end(player_id)
	grant_and_equip_test_relic()
	upgrade_equipped_relic_gold()
	promote_equipped_relic_purple()
	basic_gacha_roll()
	for player_id: StringName in equipment_session.player_order:
		mark_management_done(player_id)
	round1_loot_session_at_end = LootRewardSession.from_dict(loot_session.to_dict())
	var round_end_committed: Dictionary = commit_round_end()
	if not bool(round_end_committed.get("success", false)):
		return round_end_committed
	checkpoints["round1_post_end"] = _serializer.round_trip_diagnostic(match_state, null)
	_capture_round1_persistent_snapshot()
	return _success(&"ROUND_1_COMPLETED", "Round 1 completed; status is NEXT_CASE_REQUIRED")


func start_next_round(
	next_case_id: StringName = ROUND2_CASE_ID, tie_break_seed: int = 20260828
) -> Dictionary:
	if next_case_id.is_empty():
		return _failure(&"NEXT_CASE_ID_EMPTY", "Next case ID cannot be empty")
	var loaded_case: CaseDefinition = FixtureRepository.load_case()
	if loaded_case == null or loaded_case.case_id != next_case_id:
		return _failure(
			&"NEXT_CASE_NOT_FOUND",
			"Case definition was not found or ID mismatch: %s" % String(next_case_id)
		)
	return _start_next_round_with_case(loaded_case, "", -1, tie_break_seed)


func _start_next_round_with_case(
	selected_case: CaseDefinition,
	candidate_signature: String = "",
	option_index: int = -1,
	tie_break_seed: int = 20260828
) -> Dictionary:
	if _active_continuation_round:
		return _failure(
			&"ROUND_2_ALREADY_STARTED" if _legacy_round2_active else &"NEXT_ROUND_ALREADY_STARTED",
			"The active continuation Round has already been initialized",
			true
		)
	if match_state == null:
		return _failure(&"MATCH_STATE_MISSING", "Match state is required")
	if match_state.current_phase != M4_MVP_ENUMS.Phase.ROUND_START:
		return _failure(
			&"WRONG_START_PHASE",
			"Round Start phase is required to begin next round; current is %s"
			% M4_MVP_ENUMS.phase_name(match_state.current_phase)
		)
	if match_state.match_completion_state != &"NEXT_CASE_REQUIRED":
		return _failure(
			&"NEXT_CASE_NOT_REQUIRED",
			"Previous round must reach NEXT_CASE_REQUIRED; current is %s"
			% str(match_state.match_completion_state)
		)
	if _orchestrator.active_round != null:
		return _failure(
			&"ACTIVE_ROUND_ALREADY_EXISTS",
			"Previous active round must be cleared before attaching next round"
		)
	if selected_case == null or String(selected_case.case_id).is_empty():
		return _failure(&"NEXT_CASE_NOT_FOUND", "Selected Case definition is missing")
	var match_report: MVP_VALIDATION_REPORT = MATCH_VALIDATOR.new().validate(match_state)
	if not match_report.passed():
		return _failure(&"MATCH_STATE_INVALID", ", ".join(match_report.codes()))
	var candidate_round: M4_MVP_ROUND_STATE = M4_MVP_ROUND_STATE.new()
	candidate_round.round_id = _round_id_for_number(match_state.current_round_number)
	candidate_round.round_number = match_state.current_round_number
	candidate_round.case_id = selected_case.case_id
	candidate_round.phase = M4_MVP_ENUMS.Phase.ROUND_START
	candidate_round.loot_map_id = (
		_map_definition.map_id if _map_definition != null else &"loot_map_g3_001"
	)
	var round_report: MVP_VALIDATION_REPORT = ROUND_VALIDATOR.new().validate(
		candidate_round, match_state
	)
	if not round_report.passed():
		return _failure(&"ROUND_STATE_INVALID", ", ".join(round_report.codes()))
	var candidate_players: Array[PlayerCaseState] = _case_adapter.project_players(match_state.players)
	var candidate_turn_manager: TurnManager = TurnManager.new()
	if not candidate_turn_manager.initialize(candidate_players, tie_break_seed):
		return _failure(&"TURN_MANAGER_INIT_FAILED", "TurnManager failed to initialize from players")
	var turn_order_ids: Array[StringName] = candidate_turn_manager.get_turn_order_ids()
	var candidate_case_runtime: CaseRuntimeState = CaseRuntimeState.new()
	candidate_case_runtime.initialize(
		selected_case, _clone_case_players(candidate_players)
	)
	candidate_case_runtime.turn_order_player_ids = turn_order_ids.duplicate()
	candidate_round.case_runtime_snapshot = {
		"initialized": true,
		"source": "ACTUAL_VS_CASE_MAIN_CONTINUATION_ROUND",
		"candidate_signature": candidate_signature,
		"option_index": option_index,
		"player_ids": _player_id_strings(),
		"turn_order": _string_ids(turn_order_ids),
	}
	var round_key: String = "round%d" % candidate_round.round_number
	var attach_res: Dictionary = _orchestrator.attach_round(candidate_round)
	if not bool(attach_res.get("success", false)):
		return attach_res
	checkpoints["%s_initialized" % round_key] = _serializer.round_trip_diagnostic(
		match_state, candidate_round
	)
	var transition: M4_TRANSITION_RESULT = _orchestrator.transition(M4_MVP_ENUMS.Phase.CASE)
	if not transition.success:
		# All fallible candidate construction happens before attach. Transition is expected
		# to be infallible after validation; rollback still prevents a partial active Round.
		_orchestrator.active_round = null
		checkpoints.erase("%s_initialized" % round_key)
		return _transition_failure(transition)
	round_state = candidate_round
	active_case_definition = selected_case
	active_projected_case_players = candidate_players
	active_turn_manager = candidate_turn_manager
	active_case_runtime = candidate_case_runtime
	active_normalized_result = null
	active_loot_session = null
	active_settlement_summary_rows.clear()
	match_state.match_completion_state = &"IN_PROGRESS"
	case_definition = selected_case
	projected_case_players = candidate_players
	_active_continuation_round = true
	_active_completion_handled = false
	_active_loot_started = false
	_completion_handled = false
	_loot_started = false
	selected_case_candidate_signature = candidate_signature
	selected_case_option_index = option_index
	_legacy_round2_active = candidate_round.round_number == 2 and _continuation_rounds_started == 0
	_continuation_rounds_started += 1
	if _legacy_round2_active:
		_sync_legacy_round2_start()
	_capture_active_round_start_merit()
	# Round End idempotency belongs to the active Round. Generated Round 1 uses
	# the original player-facing commit id; later Rounds derive distinct ids.
	_round_end_committed = false
	# Round 1 objects remain available only through the explicit historical snapshot.
	# Active session references must not leak Loot/Management transients into Round 2.
	loot_session = null
	equipment_session = null
	checkpoints["%s_pre_case" % round_key] = _serializer.round_trip_diagnostic(
		match_state, round_state
	)
	event_log.append(
		"Round %d entered CASE with fresh turn order computed from Reputation"
		% round_state.round_number
	)
	return _success(
		&"ROUND_2_CASE_READY" if _legacy_round2_active else &"NEXT_ROUND_CASE_READY",
		"Round %d initialized; Case is ready" % round_state.round_number
	)


func build_round2_test_only_completed_boundary() -> MVP_CASE_COMPLETION_BOUNDARY:
	# Deterministic smoke fixture only. The M5 runtime controller launches VSCaseMain
	# and sends its real typed completion boundary to handle_round2_case_completion().
	return build_active_round_test_only_completed_boundary()


func build_active_round_test_only_completed_boundary() -> MVP_CASE_COMPLETION_BOUNDARY:
	if active_case_definition == null or active_projected_case_players.size() != 3:
		return null
	var runtime := CaseRuntimeState.new()
	runtime.initialize(
		active_case_definition, _clone_case_players(active_projected_case_players)
	)
	if active_turn_manager != null:
		runtime.turn_order_player_ids = active_turn_manager.get_turn_order_ids().duplicate()
	var sub1 := CaseSubmission.new()
	sub1.configure(
		&"player_1",
		1,
		PackedInt32Array([4, 5]),
		PackedInt32Array([4]),
		PackedInt32Array([5]),
		CaseEnums.SubmissionPhase.FINAL
	)
	var sub2 := CaseSubmission.new()
	sub2.configure(
		&"player_2",
		1,
		PackedInt32Array([4, 5]),
		PackedInt32Array(),
		PackedInt32Array(),
		CaseEnums.SubmissionPhase.FINAL
	)
	var sub3 := CaseSubmission.new()
	sub3.configure(
		&"player_3",
		1,
		PackedInt32Array([1]),
		PackedInt32Array(),
		PackedInt32Array(),
		CaseEnums.SubmissionPhase.FINAL
	)
	sub1.lock()
	sub2.lock()
	sub3.lock()
	runtime.final_submissions.assign([sub1, sub2, sub3])
	runtime.case_outcome = CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED
	var settlement: CaseSettlementResult = CaseSettlementService.new().settle(
		active_case_definition, runtime
	)
	var boundary: MVP_CASE_COMPLETION_BOUNDARY = MVP_CASE_COMPLETION_BOUNDARY.new()
	boundary.case_id = active_case_definition.case_id
	boundary.completion_reason = &"FINAL_VERDICT_RESOLVED"
	boundary.runtime_state = runtime
	boundary.settlement_result = settlement
	return boundary


func handle_round2_case_completion(boundary: MVP_CASE_COMPLETION_BOUNDARY) -> Dictionary:
	return handle_active_round_case_completion(boundary)


func handle_active_round_case_completion(
	boundary: MVP_CASE_COMPLETION_BOUNDARY
) -> Dictionary:
	if _active_completion_handled:
		return _failure(
			&"ROUND_2_CASE_COMPLETION_DUPLICATE" if _legacy_round2_active else &"CASE_COMPLETION_DUPLICATE",
			"The active Round Case completion was already committed",
			true
		)
	if (
		match_state == null
		or round_state == null
		or match_state.current_phase != M4_MVP_ENUMS.Phase.CASE
	):
		return _failure(&"CASE_CONTEXT_INVALID", "Active continuation Round CASE context is required")
	if boundary == null or not boundary.is_valid() or boundary.case_id != round_state.case_id:
		return _failure(&"CASE_BOUNDARY_INVALID", "Typed Case completion boundary is invalid")
	active_normalized_result = _case_adapter.normalize_settlement(
		boundary.settlement_result,
		boundary.case_id,
		round_state.round_id,
		boundary.completion_reason,
		_settlement_commit_id_for_round(round_state.round_number)
	)
	var transition: M4_TRANSITION_RESULT = _orchestrator.transition(
		M4_MVP_ENUMS.Phase.CASE_SETTLEMENT
	)
	if not transition.success:
		return _transition_failure(transition)
	# The completed runtime carried by the typed boundary is the actual Case authority.
	active_case_runtime = boundary.runtime_state
	round_state.case_completion_reason = boundary.completion_reason
	round_state.case_runtime_snapshot = {
		"completed": true,
		"case_outcome": boundary.runtime_state.case_outcome,
		"turn_number": boundary.runtime_state.turn_number,
		"player_ids": _player_id_strings(),
	}
	round_state.case_settlement_snapshot = active_normalized_result.to_dict()
	var before_apply: Dictionary = match_state.to_dict()
	var applied: Dictionary = _case_adapter.apply_once(match_state, active_normalized_result)
	if not bool(applied.get("success", false)):
		return applied
	round_state.settlement_commit_id = active_normalized_result.settlement_commit_id
	round_state.settlement_applied = true
	_active_completion_handled = true
	_completion_handled = true
	_build_active_settlement_summary(before_apply)
	if _legacy_round2_active:
		_sync_legacy_round2_completion()
	var round_key: String = "round%d" % round_state.round_number
	checkpoints["%s_post_settlement" % round_key] = _serializer.round_trip_diagnostic(
		match_state, round_state
	)
	event_log.append(
		"Round %d settlement applied exactly once with new commit ID"
		% round_state.round_number
	)
	return _success(
		&"ROUND_2_SETTLEMENT_APPLIED" if _legacy_round2_active else &"ROUND_SETTLEMENT_APPLIED",
		"Continue to Round %d Loot runtime" % round_state.round_number
	)


func begin_round2_loot() -> Dictionary:
	return begin_active_round_loot()


func begin_active_round_loot() -> Dictionary:
	if _active_loot_started or active_loot_session != null:
		return _failure(
			&"ROUND_2_LOOT_ALREADY_ACTIVE" if _legacy_round2_active else &"LOOT_SESSION_ALREADY_ACTIVE",
			"The active Round already owns a Loot session",
			true
		)
	if not _active_completion_handled or not round_state.settlement_applied:
		return _failure(&"LOOT_BEFORE_SETTLEMENT", "Settlement must be applied first")
	if match_state.current_phase != M4_MVP_ENUMS.Phase.CASE_SETTLEMENT:
		return _failure(
			&"LOOT_PHASE_NOT_READY", "Orchestrator and Match must be at CASE_SETTLEMENT phase"
		)
	var loot_players: Array[PlayerPhaseState] = []
	for player: M4_PLAYER_MATCH_STATE in match_state.players:
		loot_players.append(_loot_adapter.project_player(player, round_state.round_id))
	var candidate_session: LootRewardSession = _build_loot_reward_session(
		loot_players, [6, 5, 4, 3, 2, 1, 0]
	)
	if candidate_session == null:
		return _failure(
			&"LOOT_INITIALIZATION_FAILED", "GĐ2 Loot services rejected the active Round projection"
		)
	var transition: M4_TRANSITION_RESULT = _orchestrator.transition(M4_MVP_ENUMS.Phase.LOOT)
	if not transition.success:
		return _transition_failure(transition)
	loot_session = candidate_session
	active_loot_session = candidate_session
	_active_loot_started = true
	_loot_started = true
	if _legacy_round2_active:
		_sync_legacy_round2_loot()
	_capture_loot_snapshots()
	var round_key: String = "round%d" % round_state.round_number
	checkpoints["%s_loot_initialized" % round_key] = _serializer.round_trip_diagnostic(
		match_state, round_state
	)
	event_log.append(
		"Round %d Loot initialized at origin with fresh reward snapshot"
		% round_state.round_number
	)
	return _success(
		&"ROUND_2_LOOT_INITIALIZED" if _legacy_round2_active else &"ROUND_LOOT_INITIALIZED",
		"Round %d tokens initialized at origin with moves reset to Stamina"
		% round_state.round_number
	)


func _build_round2_settlement_summary(before_match_dict: Dictionary) -> void:
	_build_active_settlement_summary(before_match_dict)
	_sync_legacy_round2_completion()


func _build_active_settlement_summary(before_match_dict: Dictionary) -> void:
	active_settlement_summary_rows.clear()
	var before_players_value: Variant = before_match_dict.get("players", [])
	var before_by_id: Dictionary = {}
	if before_players_value is Array:
		for before_value: Variant in before_players_value:
			if before_value is Dictionary:
				var before_row: Dictionary = before_value as Dictionary
				before_by_id[String(before_row.get("player_id", ""))] = before_row
	for after_player: M4_PLAYER_MATCH_STATE in match_state.players:
		var before_value: Variant = before_by_id.get(String(after_player.player_id), {})
		var before_player_dict: Dictionary = (
			before_value as Dictionary if before_value is Dictionary else {}
		)
		var player_result: MVP_CASE_PLAYER_RESULT = null
		if active_normalized_result != null and active_normalized_result.player_results != null:
			for pr in active_normalized_result.player_results:
				if String(pr.player_id) == String(after_player.player_id):
					player_result = pr
					break
		active_settlement_summary_rows.append({
			"player_id": after_player.player_id,
			"display_name": after_player.display_name,
			"status": str(player_result.status) if player_result != null else "UNKNOWN",
			"merit_delta": after_player.merit_progress - float(before_player_dict.get("merit_progress", 0.0)),
			"reputation_delta": after_player.reputation - int(before_player_dict.get("reputation", 0)),
			"orb_delta": after_player.orb_count - int(before_player_dict.get("orb_count", 0)),
			"ticket_delta": after_player.gacha_ticket_count - int(before_player_dict.get("gacha_ticket_count", 0)),
			"total_merit": after_player.merit_progress,
			"total_reputation": after_player.reputation,
			"total_orb": after_player.orb_count,
			"total_ticket": after_player.gacha_ticket_count,
		})


func _sync_legacy_round2_start() -> void:
	round2_case_definition = active_case_definition
	round2_projected_case_players = active_projected_case_players
	round2_turn_manager = active_turn_manager
	round2_case_runtime = active_case_runtime
	round2_normalized_result = null
	round2_loot_session = null
	round2_loot_initialized = false
	round2_settlement_summary.clear()
	_round2_started = true
	_round2_completion_handled = false
	_round2_loot_started = false


func _sync_legacy_round2_completion() -> void:
	if not _legacy_round2_active:
		return
	round2_case_runtime = active_case_runtime
	round2_normalized_result = active_normalized_result
	round2_settlement_summary.assign(active_settlement_summary_rows)
	_round2_completion_handled = _active_completion_handled


func _sync_legacy_round2_loot() -> void:
	if not _legacy_round2_active:
		return
	round2_loot_session = active_loot_session
	round2_loot_initialized = true
	_round2_loot_started = true


func _reset_active_continuation_references() -> void:
	active_case_definition = null
	active_projected_case_players.clear()
	active_turn_manager = null
	active_case_runtime = null
	active_normalized_result = null
	active_loot_session = null
	active_settlement_summary_rows.clear()
	_active_continuation_round = false
	_active_completion_handled = false
	_active_loot_started = false
	_active_round_start_merit_by_player.clear()


func _clear_next_case_options() -> void:
	next_case_option_set = null
	next_case_option_definitions.clear()
	selected_case_candidate_signature = ""
	selected_case_option_index = -1


func _default_next_case_warehouse(
	request: CaseGenerationRequest, roles: Array[RoleDefinition]
) -> RefCounted:
	if default_next_case_warehouse != null:
		return default_next_case_warehouse
	if match_state != null and match_state.case_generation_seed > 0:
		default_next_case_warehouse = CASE_SEED_WAREHOUSE_BUILDER.new().build_varied_suspect_counts(
			request,
			_default_next_case_warehouse_root_seeds(),
			DEFAULT_NEXT_CASE_WAREHOUSE_TARGET_COUNT,
			roles,
			5,
			8,
			DEFAULT_NEXT_CASE_MAX_ATTEMPTS
		)
	else:
		default_next_case_warehouse = CASE_SEED_WAREHOUSE_BUILDER.new().build(
			request,
			_default_next_case_warehouse_root_seeds(),
			DEFAULT_NEXT_CASE_WAREHOUSE_TARGET_COUNT,
			roles,
			DEFAULT_NEXT_CASE_MAX_ATTEMPTS
		)
	return default_next_case_warehouse


func _case_definition_from_warehouse_entry(
	entry: CASE_SEED_WAREHOUSE_ENTRY,
	role_definitions: Array[RoleDefinition],
	max_attempts: int,
	attempt_evaluator: Callable,
	case_definition_resolver: Callable = Callable()
) -> CaseDefinition:
	if entry == null:
		return null
	if case_definition_resolver.is_valid():
		var resolved: Variant = case_definition_resolver.call(entry)
		if resolved is CaseDefinition:
			return resolved as CaseDefinition
	var acceptance: CASE_GENERATION_ACCEPTANCE_RESULT = CASE_GENERATION_ACCEPTANCE_SERVICE.new().accept_unique_candidate(
		entry.request(),
		role_definitions,
		max_attempts,
		attempt_evaluator
	)
	if not acceptance.success:
		return null
	if (
		acceptance.accepted_attempt_index != entry.accepted_attempt_index
		or acceptance.accepted_derived_seed != entry.accepted_derived_seed
	):
		return null
	var definition: CaseDefinition = CASE_GENERATOR.new().case_definition_from_result(
		acceptance.accepted_candidate
	)
	if definition == null:
		return null
	definition.case_id = StringName("generated_case_%s" % _safe_signature_id(entry.candidate_signature))
	definition.display_name = "Kỳ Án Sinh Tự Động"
	definition.short_description = "Một Kỳ Án được chọn từ Seed Warehouse đã xác minh."
	definition.set_meta(&"candidate_signature", entry.candidate_signature)
	definition.set_meta(&"warehouse_root_seed", entry.root_seed)
	definition.set_meta(&"option_index", next_case_option_set.option_candidate_signatures.find(entry.candidate_signature) if next_case_option_set != null else -1)
	_attach_case_generation_audit(definition, entry, acceptance, role_definitions)
	return definition


func _attach_case_generation_audit(
	definition: CaseDefinition,
	entry: CASE_SEED_WAREHOUSE_ENTRY,
	acceptance: CASE_GENERATION_ACCEPTANCE_RESULT,
	role_definitions: Array[RoleDefinition]
) -> bool:
	if definition == null:
		return false
	var audit = CASE_GENERATION_AUDIT_SNAPSHOT.new()
	if not audit.capture(entry, acceptance, role_definitions):
		return false
	definition.set_meta(&"generation_audit_snapshot", audit)
	return true


func _default_next_case_generation_request() -> CaseGenerationRequest:
	var role_ids: Array[StringName] = [
		&"tutorial_priest",
		&"reporter",
		&"therapist",
		&"weatherman",
		&"blood_hound",
		&"mathematician",
		&"mailman",
		&"tutorial_mobster",
		&"copycat",
		&"conman",
		&"poisoner",
		&"barkeep",
		&"spectre",
		&"tutorial_scoundrel",
		&"tailor",
		&"vigilante",
		&"clock_maker",
		&"surgeon",
		&"serial_killer",
		&"critic",
	]
	var location_ids: Array[StringName] = [
		BoardLocationDefinition.LOCATION_CRIME_SCENE,
	]
	return CASE_GENERATION_REQUEST_TYPE.create(
		112233,
		3,
		3,
		CASE_GENERATION_REQUEST_TYPE.PROFILE_TUTORIAL_EASY,
		role_ids,
		location_ids,
		5
	)


func _default_next_case_warehouse_root_seeds() -> PackedInt32Array:
	if match_state != null and match_state.case_generation_seed > 0:
		var roots: PackedInt32Array = PackedInt32Array()
		var base_seed: int = _positive_case_seed(match_state.case_generation_seed + 112233)
		for index: int in range(64):
			roots.append(_positive_case_seed(base_seed + index * 1000003))
		return roots
	return PackedInt32Array([
		112233,
		112234,
		112235,
		112236,
		112237,
		112238,
		112239,
		112240,
		112241,
		112242,
		112243,
		112244,
	])


func _default_next_case_option_seed() -> int:
	if match_state == null or match_state.case_generation_seed <= 0:
		return DEFAULT_NEXT_CASE_OPTION_SET_SEED
	return _positive_case_seed(
		match_state.case_generation_seed
		+ match_state.current_round_number * 1000003
		+ DEFAULT_NEXT_CASE_OPTION_SET_SEED
	)


func _positive_case_seed(value: int) -> int:
	return posmod(value - 1, 2147483646) + 1


func _commit_used_case_signature(signature: String) -> void:
	if signature.is_empty() or match_state == null:
		return
	if not match_state.used_case_candidate_signatures.has(signature):
		match_state.used_case_candidate_signatures.append(signature)


func _safe_signature_id(signature: String) -> String:
	var result: String = ""
	for index: int in range(signature.length()):
		var code: int = signature.unicode_at(index)
		var character: String = char(code)
		if (
			(code >= 48 and code <= 57)
			or (code >= 65 and code <= 90)
			or (code >= 97 and code <= 122)
		):
			result += character
		else:
			result += "_"
	return result if not result.is_empty() else "unknown"


func _capture_active_round_start_merit() -> void:
	_active_round_start_merit_by_player.clear()
	if match_state == null:
		return
	for player: M4_PLAYER_MATCH_STATE in match_state.players:
		_active_round_start_merit_by_player[String(player.player_id)] = player.merit_progress


func expected_origin_node_for_player(player_id: StringName) -> StringName:
	var player: M4_PLAYER_MATCH_STATE = match_state.find_player(player_id) if match_state != null else null
	if player == null or _map_definition == null:
		return &""
	var character: CharacterDefinition = _find_character_definition(player.character_id)
	if character == null:
		return &""
	return StringName(_map_definition.origin_spawn_by_house.get(character.origin_house_id, &""))


func resolved_stamina_for_player(player_id: StringName) -> int:
	# Current GĐ2 authority has no persistent stat-modifier pipeline. Equipment and
	# progression do not author resolved Stamina yet, so base_stamina is exact authority.
	var player: M4_PLAYER_MATCH_STATE = match_state.find_player(player_id) if match_state != null else null
	if player == null:
		return 0
	var character: CharacterDefinition = _find_character_definition(player.character_id)
	return character.base_stamina if character != null else 0


func _find_character_definition(character_id: StringName) -> CharacterDefinition:
	for character: CharacterDefinition in _characters:
		if character.character_id == character_id:
			return character
	return null


func _capture_round1_persistent_snapshot() -> void:
	round1_persistent_snapshot_by_player.clear()
	for player: M4_PLAYER_MATCH_STATE in match_state.players:
		round1_persistent_snapshot_by_player[String(player.player_id)] = player.to_dict()


func _round_id_for_number(round_number: int) -> StringName:
	return StringName("gd3_m5_round_%03d" % round_number)


func _settlement_commit_id_for_round(round_number: int) -> StringName:
	return StringName("gd3_m5_round%d_settlement_001" % round_number)


func _string_ids(ids: Array) -> Array[String]:
	var result: Array[String] = []
	for id in ids:
		result.append(String(id))
	return result
