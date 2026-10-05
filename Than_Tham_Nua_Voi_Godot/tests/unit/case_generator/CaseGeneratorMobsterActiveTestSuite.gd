extends RefCounted

const REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")
const GENERATOR := preload("res://scripts/domain/cases/CaseGenerator.gd")
const ACCEPTANCE := preload("res://scripts/domain/cases/CaseGenerationAcceptanceService.gd")
const CAPABILITY := preload("res://scripts/domain/cases/CaseProceduralPretendCapability.gd")
const VIEW := preload("res://scripts/domain/cases/GeneratedPublicCaseView.gd")
const SUSPECT := preload("res://scripts/domain/cases/GeneratedPublicSuspectView.gd")
const CLUE := preload("res://scripts/domain/cases/GeneratedPublicClue.gd")
const SOLVER := preload("res://scripts/domain/cases/CaseGeneratorPublicSolver.gd")

const FIXED_ROOT := 112236
const ACTIVE_ROLE_IDS: Array[StringName] = [&"tailor", &"vigilante"]


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var roles_by_id: Dictionary = _roles_by_id(roles)
	var capability_ok: bool = true
	for active_id: StringName in ACTIVE_ROLE_IDS:
		var role: RoleDefinition = roles_by_id.get(active_id, null) as RoleDefinition
		capability_ok = (
			capability_ok
			and CAPABILITY.can_pretend_procedural(&"tutorial_mobster", role)
			and CAPABILITY.can_pretend_procedural(&"mobster", role)
			and CAPABILITY.can_pretend_authored_compatible(&"tutorial_mobster", role)
			and not CAPABILITY.can_pretend_procedural(&"critic", role)
		)
	_add(rows, "Disguise Slice D1 keeps Mobster active targets after later slices", capability_ok)
	_add(rows, "Disguise Slice D1 uses shared current-native witness authority", (
		_shared_witness_contract(&"tailor") and _shared_witness_contract(&"vigilante")
	))
	_add(rows, "Disguise Slice D1 solver rejects displayed-only active witnesses", (
		_solver_rejects_missing_witness(roles, &"tailor")
		and _solver_rejects_missing_witness(roles, &"vigilante")
	))

	for active_id: StringName in ACTIVE_ROLE_IDS:
		var evidence: Dictionary = _fixed_acceptance_evidence(roles, active_id)
		var accepted_definition: CaseDefinition = evidence.get("definition", null) as CaseDefinition
		_add(rows, "Disguise Slice D1 Mobster -> %s reaches UNIQUE acceptance" % active_id, (
			bool(evidence.get("accepted", false))
			and int(evidence.get("root_seed", 0)) == FIXED_ROOT
			and int(evidence.get("accepted_seed", 0)) == FIXED_ROOT
			and int(evidence.get("owner_suspect_id", 0)) == 1
			and StringName(evidence.get("displayed_role_id", &"")) == active_id
			and bool(evidence.get("native_witness", false))
			and bool(evidence.get("lying", false))
			and bool(evidence.get("no_active_clue", false))
			and bool(evidence.get("ground_truth_match", false))
		), String(evidence.get("detail", "")))
		_add(rows, "Disguise Slice D1 Mobster -> %s borrows one LYING runtime function" % active_id, (
			_runtime_behavior(accepted_definition, roles, active_id)
		))
	return rows


func _fixed_request(active_id: StringName) -> CaseGenerationRequest:
	var role_ids: Array[StringName] = [
		&"tutorial_mobster", active_id, &"critic", &"tutorial_scoundrel", &"surgeon",
		&"reporter", &"therapist",
	]
	var locations: Array[StringName] = [BoardLocationDefinition.LOCATION_CRIME_SCENE]
	return REQUEST.create(
		FIXED_ROOT, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY,
		role_ids, locations, 6
	)


func _fixed_acceptance_evidence(
	roles: Array[RoleDefinition],
	active_id: StringName
) -> Dictionary:
	var accepted: CaseGenerationAcceptanceResult = ACCEPTANCE.new().accept_unique_candidate(
		_fixed_request(active_id), roles, 1
	)
	return _acceptance_evidence(accepted, active_id)


func _acceptance_evidence(
	accepted: CaseGenerationAcceptanceResult,
	active_id: StringName
) -> Dictionary:
	var evidence: Dictionary = _empty_evidence("candidate did not meet D1 evidence contract")
	if accepted == null or not accepted.success or accepted.accepted_candidate == null:
		return evidence
	var candidate: CaseGenerationResult = accepted.accepted_candidate as CaseGenerationResult
	var definition: CaseDefinition = GENERATOR.new().case_definition_from_result(candidate)
	var owner: SuspectDefinition = _find_role(definition, &"tutorial_mobster")
	var native: SuspectDefinition = _find_role(definition, active_id)
	var solver: CaseGeneratorSolverResult = accepted.accepted_solver_result as CaseGeneratorSolverResult
	if owner == null or native == null or solver == null or owner.displayed_role_id != active_id:
		return evidence
	var no_active_clue: bool = true
	for clue in candidate.hidden_case_draft.public_clues:
		if clue.suspect_id == owner.suspect_id or clue.suspect_id == native.suspect_id:
			no_active_clue = false
			break
	evidence.accepted = solver.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION
	evidence.root_seed = accepted.root_seed
	evidence.accepted_seed = accepted.accepted_derived_seed
	evidence.owner_suspect_id = owner.suspect_id
	evidence.solver_status = solver.status
	evidence.displayed_role_id = owner.displayed_role_id
	evidence.native_witness = owner.suspect_id != native.suspect_id and native.true_role_id == active_id
	evidence.lying = (
		owner.true_alignment == CaseEnums.Alignment.EVIL
		and owner.role_group == CaseEnums.RoleGroup.TONG_PHAM
		and RoleInformationEvaluationService.new().truth_mode_for_suspect(owner) == InvestigationInformationResult.TruthMode.LYING
	)
	evidence.no_active_clue = no_active_clue
	evidence.ground_truth_match = solver.ground_truth_checked and solver.unique_solution_matches_ground_truth
	evidence.definition = definition
	evidence.detail = "root=%d accepted_seed=%d owner=%d displayed=%s solver=%s" % [
		accepted.root_seed, accepted.accepted_derived_seed, owner.suspect_id,
		String(owner.displayed_role_id), String(solver.status),
	]
	return evidence


func _empty_evidence(detail: String) -> Dictionary:
	var evidence: Dictionary = {
		"accepted": false,
		"root_seed": 0,
		"accepted_seed": 0,
		"owner_suspect_id": 0,
		"solver_status": &"",
		"displayed_role_id": &"",
		"native_witness": false,
		"lying": false,
		"no_active_clue": false,
		"ground_truth_match": false,
		"definition": null,
		"detail": detail,
	}
	return evidence


func _shared_witness_contract(active_id: StringName) -> bool:
	var suspect_ids: PackedInt32Array = PackedInt32Array([1, 2, 3])
	var native_roles: Dictionary = {1: &"tutorial_mobster", 2: active_id, 3: &"tutorial_scoundrel"}
	var transformed_roles: Dictionary = {1: &"tutorial_mobster", 2: &"drunkard", 3: &"tutorial_scoundrel"}
	var displayed_only_roles: Dictionary = {1: &"tutorial_mobster", 2: &"critic", 3: &"tutorial_scoundrel"}
	var self_only_ids: PackedInt32Array = PackedInt32Array([1, 3])
	var self_only_roles: Dictionary = {1: active_id, 3: &"tutorial_scoundrel"}
	return (
		CAPABILITY.procedural_current_native_witness_is_satisfied(1, active_id, suspect_ids, native_roles)
		and not CAPABILITY.procedural_current_native_witness_is_satisfied(1, active_id, suspect_ids, transformed_roles)
		and not CAPABILITY.procedural_current_native_witness_is_satisfied(1, active_id, suspect_ids, displayed_only_roles)
		and not CAPABILITY.procedural_current_native_witness_is_satisfied(1, active_id, self_only_ids, self_only_roles)
	)


func _solver_rejects_missing_witness(
	roles: Array[RoleDefinition],
	active_id: StringName
) -> bool:
	var view: GeneratedPublicCaseView = VIEW.create_manual(3, 3, 2, [
		SUSPECT.create(1, 0, active_id, CaseEnums.RoleGroup.CHINH_NHAN),
		SUSPECT.create(2, 1, &"mailman", CaseEnums.RoleGroup.CHINH_NHAN),
		SUSPECT.create(3, 2, &"tutorial_scoundrel", CaseEnums.RoleGroup.TONG_PHAM),
	])
	view.allowed_role_ids = [&"tutorial_mobster", active_id, &"mailman", &"tutorial_scoundrel"]
	view.suspected_role_ids = view.allowed_role_ids.duplicate()
	var clue: GeneratedPublicClue = CLUE.new()
	clue.suspect_id = 2
	clue.behavior_role_id = &"mailman"
	clue.payload_kind = InvestigationInformationResult.PayloadKind.ROLE_PLAY_CLAIM
	clue.in_play_role_id = &"tutorial_mobster"
	clue.not_in_play_role_id = active_id
	view.public_clues.append(clue)
	var solved: CaseGeneratorSolverResult = SOLVER.new().solve(view, roles)
	return solved != null and solved.status == CaseGeneratorSolverResult.STATUS_NO_SOLUTION


func _runtime_behavior(
	definition: CaseDefinition,
	roles: Array[RoleDefinition],
	active_id: StringName
) -> bool:
	if definition == null:
		return false
	var owner: SuspectDefinition = _find_role(definition, &"tutorial_mobster")
	var evil: SuspectDefinition = _find_role(definition, &"tutorial_scoundrel")
	if owner == null or evil == null or owner.displayed_role_id != active_id:
		return false
	var runtime := CaseRuntimeState.new()
	runtime.initialize(definition, FixtureRepository.load_players())
	for player: PlayerCaseState in runtime.players:
		runtime.turn_order_player_ids.append(player.player_id)
	var availability := FunctionAvailabilityService.new()
	availability.initialize_hidden_states(definition, runtime, roles)
	var owner_runtime: SuspectRuntimeState = runtime.find_suspect(owner.suspect_id)
	var function_state: InteractiveFunctionRuntimeState = owner_runtime.interactive_function if owner_runtime != null else null
	if function_state == null:
		return false
	var expected_type: int = (
		CaseEnums.FunctionType.TAILOR_COMPARE_ALIGNMENT
		if active_id == &"tailor"
		else CaseEnums.FunctionType.VIGILANTE_KILL
	)
	var starts_hidden: bool = (
		function_state.function_type == expected_type
		and function_state.state == InteractiveFunctionRuntimeState.State.HIDDEN
		and function_state.uses_remaining == 1
		and runtime.public_function_records.is_empty()
	)
	owner_runtime.is_investigated = true
	var revealed: bool = availability.reveal_for_suspect(definition, runtime, roles, owner.suspect_id, 1)
	availability.update_for_turn(runtime, 2)
	var targets: PackedInt32Array = (
		PackedInt32Array([owner.suspect_id, evil.suspect_id])
		if active_id == &"tailor"
		else PackedInt32Array([evil.suspect_id])
	)
	var execution := InteractiveFunctionExecutionService.new()
	var result: InteractiveFunctionResult = execution.execute(
		definition, runtime, owner.suspect_id, targets, runtime.current_player_id()
	)
	var repeated: InteractiveFunctionResult = execution.execute(
		definition, runtime, owner.suspect_id, targets, runtime.current_player_id()
	)
	var lying_effect: bool = false
	if active_id == &"tailor":
		# Mobster and Scoundrel are truly both Evil, so LYING Tailor reports different.
		lying_effect = result.public_result_type == InteractiveFunctionResult.PublicResultType.DIFFERENT_ALIGNMENT
	else:
		lying_effect = (
			not result.vigilante_kill_attempted
			and not result.vigilante_target_killed
			and not runtime.find_suspect(evil.suspect_id).is_dead
		)
	return (
		starts_hidden and revealed
		and function_state.state == InteractiveFunctionRuntimeState.State.EXHAUSTED
		and result.success and lying_effect and not repeated.success
		and function_state.uses_remaining == 0
		and runtime.public_function_records.size() == 1
	)


func _roles_by_id(roles: Array[RoleDefinition]) -> Dictionary:
	var result: Dictionary = {}
	for role: RoleDefinition in roles:
		if role != null:
			result[role.role_id] = role
	return result


func _find_role(definition: CaseDefinition, role_id: StringName) -> SuspectDefinition:
	if definition != null:
		for suspect: SuspectDefinition in definition.suspects:
			if suspect != null and suspect.true_role_id == role_id:
				return suspect
	return null


func _add(
	rows: Array[Dictionary],
	name: String,
	passed: bool,
	detail: String = "Mobster active-role disguise invariant"
) -> void:
	rows.append({"name": name, "passed": passed, "detail": detail})
