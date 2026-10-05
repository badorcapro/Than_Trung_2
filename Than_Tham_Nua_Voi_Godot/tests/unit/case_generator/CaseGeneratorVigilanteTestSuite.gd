extends RefCounted

const REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")
const GENERATOR := preload("res://scripts/domain/cases/CaseGenerator.gd")
const PUBLIC_VIEW := preload("res://scripts/domain/cases/GeneratedPublicCaseView.gd")
const SOLVER := preload("res://scripts/domain/cases/CaseGeneratorPublicSolver.gd")
const ACCEPTANCE := preload("res://scripts/domain/cases/CaseGenerationAcceptanceService.gd")
const PRETEND := preload("res://scripts/domain/cases/CaseProceduralPretendCapability.gd")
const NEXT_CASE := preload("res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd")


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var role_ids: Array[StringName] = [
		&"vigilante", &"tutorial_priest", &"reporter", &"therapist", &"tutorial_scoundrel",
	]
	var request: CaseGenerationRequest = _request(role_ids)
	var generator = GENERATOR.new()
	var candidate: CaseGenerationResult = generator.generate(request, roles)
	var definition: CaseDefinition = generator.case_definition_from_result(candidate)
	var owner_id: int = _role_suspect_id(definition, &"vigilante")
	var validation: Dictionary = CaseDefinitionValidator.new().validate(definition, roles, FixtureRepository.load_players())
	var view: GeneratedPublicCaseView = PUBLIC_VIEW.from_generation_result(candidate, roles)
	var no_vigilante_clue: bool = owner_id > 0
	for clue in view.public_clues:
		if clue != null and (clue.suspect_id == owner_id or clue.behavior_role_id == &"vigilante"):
			no_vigilante_clue = false
	_add(rows, "Slice 3 generates native Good Vigilante with no automatic clue", (
		candidate != null and candidate.is_success() and no_vigilante_clue
		and _native_vigilante(definition, owner_id) and bool(validation.get("passed", false))
	))

	var solved: CaseGeneratorSolverResult = SOLVER.new().solve(view, roles)
	_add(rows, "Slice 3 solver supports silent native Vigilante before function use", (
		solved != null and solved.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION
		and no_vigilante_clue and definition != null
		and solved.unique_evil_suspect_ids == definition.evil_suspect_ids
	))
	var accepted: CaseGenerationAcceptanceResult = ACCEPTANCE.new().accept_unique_candidate(request, roles)
	var accepted_definition: CaseDefinition
	var accepted_solver: CaseGeneratorSolverResult
	if accepted != null and accepted.success:
		accepted_definition = generator.case_definition_from_result(accepted.accepted_candidate)
		accepted_solver = accepted.accepted_solver_result as CaseGeneratorSolverResult
	_add(rows, "Slice 3 normal acceptance finds UNIQUE Vigilante Case without future evidence", (
		accepted != null and accepted.success and _role_suspect_id(accepted_definition, &"vigilante") > 0
		and accepted_solver != null and accepted_solver.ground_truth_checked
		and accepted_solver.unique_solution_matches_ground_truth
		and accepted_solver.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION
	))
	_test_runtime(rows, accepted_definition, roles)
	_add(rows, "Slice 3 Mailman sees native Vigilante in true role universe", _mailman_sees_vigilante(definition, roles))

	var duplicate_ids: Array[StringName] = [&"vigilante", &"vigilante", &"tutorial_scoundrel"]
	var duplicate_request: CaseGenerationRequest = _request(duplicate_ids)
	var duplicate_result: CaseGenerationResult = generator.generate(duplicate_request, roles)
	_add(rows, "Slice 3 duplicate Vigilante cannot fill two true-role slots", (
		duplicate_result != null and not duplicate_result.is_success()
		and duplicate_result.error_code == CaseGenerationResult.ERROR_INSUFFICIENT_UNIQUE_ROLES
	))

	# Both Priest announcements are truthful: either Priest-displaying suspect can be Conman.
	var ambiguous_ids: Array[StringName] = [&"vigilante", &"tutorial_priest", &"conman"]
	var ambiguous_request: CaseGenerationRequest = _request(ambiguous_ids)
	var ambiguous_candidate: CaseGenerationResult = generator.generate(ambiguous_request, roles)
	var ambiguous_view: GeneratedPublicCaseView = PUBLIC_VIEW.from_generation_result(ambiguous_candidate, roles)
	var ambiguous_solved: CaseGeneratorSolverResult = SOLVER.new().solve(ambiguous_view, roles)
	var rejected: CaseGenerationAcceptanceResult = ACCEPTANCE.new().accept_unique_candidate(ambiguous_request, roles, 2)
	_add(rows, "Slice 3 ambiguous Vigilante Case is rejected without inventing future function evidence", (
		ambiguous_candidate != null and ambiguous_candidate.is_success()
		and ambiguous_solved != null and ambiguous_solved.status == CaseGeneratorSolverResult.STATUS_MULTIPLE_SOLUTIONS
		and rejected != null and not rejected.success and rejected.accepted_candidate == null
		and int(rejected.rejected_status_counts.get(ACCEPTANCE.REJECTION_MULTIPLE_SOLUTIONS, 0)) == 2
	))

	var production_ids: Array[StringName] = NEXT_CASE.new()._default_next_case_generation_request().allowed_role_ids
	var boundaries_ok: bool = production_ids.has(&"vigilante") and not PRETEND.is_supported_behavior(&"vigilante")
	var vigilante_role: RoleDefinition
	for role: RoleDefinition in roles:
		if role != null and role.role_id == &"vigilante":
			vigilante_role = role
	boundaries_ok = (
		boundaries_ok
		and PRETEND.can_pretend(&"copycat", vigilante_role)
		and PRETEND.can_pretend(&"tutorial_mobster", vigilante_role)
		and PRETEND.can_pretend(&"mobster", vigilante_role)
		and PRETEND.can_pretend(&"serial_killer", vigilante_role)
	)
	for pretender_id: StringName in [&"conman", &"poisoner", &"barkeep", &"spectre", &"critic"]:
		boundaries_ok = boundaries_ok and not PRETEND.can_pretend(pretender_id, vigilante_role)
	for deferred_id: StringName in [&"drunkard"]:
		boundaries_ok = boundaries_ok and not production_ids.has(deferred_id)
	_add(rows, "Slice 3 native Vigilante retains scoped procedural capabilities", boundaries_ok and vigilante_role != null)
	return rows


func _test_runtime(rows: Array[Dictionary], definition: CaseDefinition, roles: Array[RoleDefinition]) -> void:
	var unused: bool = false
	var unlocked: bool = false
	var executed_once: bool = false
	var owner_id: int = _role_suspect_id(definition, &"vigilante")
	if definition != null and owner_id > 0 and not definition.evil_suspect_ids.is_empty():
		var runtime := CaseRuntimeState.new()
		runtime.initialize(definition, FixtureRepository.load_players())
		for player: PlayerCaseState in runtime.players:
			runtime.turn_order_player_ids.append(player.player_id)
		var availability := FunctionAvailabilityService.new()
		availability.initialize_hidden_states(definition, runtime, roles)
		var owner: SuspectRuntimeState = runtime.find_suspect(owner_id)
		var function_state: InteractiveFunctionRuntimeState = owner.interactive_function
		unused = (
			function_state != null and function_state.uses_remaining == 1
			and function_state.function_type == CaseEnums.FunctionType.VIGILANTE_KILL
			and function_state.target_count == 1
			and function_state.state == InteractiveFunctionRuntimeState.State.HIDDEN
			and runtime.public_function_records.is_empty()
			and not runtime.find_suspect(definition.evil_suspect_ids[0]).is_dead
		)
		if function_state != null:
			owner.is_investigated = true
			var revealed: bool = availability.reveal_for_suspect(definition, runtime, roles, owner_id, 1)
			availability.update_for_turn(runtime, 2)
			var info: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(definition, owner_id, roles, {}, runtime)
			unlocked = revealed and function_state.state == InteractiveFunctionRuntimeState.State.AVAILABLE and runtime.public_function_records.is_empty() and info != null and info.payload_kind == InvestigationInformationResult.PayloadKind.NONE
			var targets := PackedInt32Array([definition.evil_suspect_ids[0]])
			var execution := InteractiveFunctionExecutionService.new()
			var result: InteractiveFunctionResult = execution.execute(definition, runtime, owner_id, targets, runtime.current_player_id())
			var repeated: InteractiveFunctionResult = execution.execute(definition, runtime, owner_id, targets, runtime.current_player_id())
			executed_once = result.success and result.vigilante_kill_attempted and result.vigilante_target_killed and runtime.find_suspect(targets[0]).is_dead and not repeated.success and function_state.uses_remaining == 0 and function_state.state == InteractiveFunctionRuntimeState.State.EXHAUSTED and runtime.public_function_records.size() == 1
	_add(rows, "Slice 3 accepted Vigilante starts unused with no public function records", unused)
	_add(rows, "Slice 3 investigation unlocks Vigilante normally without automatic announcement", unlocked)
	_add(rows, "Slice 3 runtime player-selected Vigilante target produces exactly one record", executed_once)


func _mailman_sees_vigilante(source: CaseDefinition, roles: Array[RoleDefinition]) -> bool:
	if source == null:
		return false
	var definition: CaseDefinition = source.duplicate(true) as CaseDefinition
	var mailman_id: int = 0
	for suspect: SuspectDefinition in definition.suspects:
		if suspect.true_role_id == &"reporter":
			suspect.true_role_id = &"mailman"
			suspect.displayed_role_id = &"mailman"
			mailman_id = suspect.suspect_id
	definition.suspected_role_ids = [&"vigilante", &"tutorial_priest", &"mailman", &"therapist", &"tutorial_scoundrel", &"mathematician"]
	var result: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(
		definition, mailman_id, roles,
		{"in_play_role_id": &"vigilante", "not_in_play_role_id": &"mathematician"}
	)
	return CaseRolePoolService.current_role_ids_in_play(definition, null).has(&"vigilante") and result != null and result.in_play_role_id == &"vigilante" and result.claimed_in_play_is_true and result.claimed_not_in_play_is_true


func _request(role_ids: Array[StringName]) -> CaseGenerationRequest:
	var locations: Array[StringName] = [BoardLocationDefinition.LOCATION_CRIME_SCENE]
	return REQUEST.create(112233, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY, role_ids, locations, role_ids.size())


func _native_vigilante(definition: CaseDefinition, owner_id: int) -> bool:
	if definition == null or owner_id <= 0:
		return false
	for suspect: SuspectDefinition in definition.suspects:
		if suspect.suspect_id == owner_id:
			return suspect.true_role_id == &"vigilante" and suspect.displayed_role_id == &"vigilante" and suspect.true_alignment == CaseEnums.Alignment.GOOD and suspect.role_group == CaseEnums.RoleGroup.CHINH_NHAN and not suspect.is_impersonating
	return false


func _role_suspect_id(definition: CaseDefinition, role_id: StringName) -> int:
	if definition != null:
		for suspect: SuspectDefinition in definition.suspects:
			if suspect.true_role_id == role_id:
				return suspect.suspect_id
	return 0


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({"name": name, "passed": passed, "detail": "Native Vigilante accepts only pre-function public evidence"})
