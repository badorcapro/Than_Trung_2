extends RefCounted

const REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")
const GENERATOR := preload("res://scripts/domain/cases/CaseGenerator.gd")
const ACCEPTANCE := preload("res://scripts/domain/cases/CaseGenerationAcceptanceService.gd")
const VIEW := preload("res://scripts/domain/cases/GeneratedPublicCaseView.gd")
const SUSPECT := preload("res://scripts/domain/cases/GeneratedPublicSuspectView.gd")
const CLUE := preload("res://scripts/domain/cases/GeneratedPublicClue.gd")
const SOLVER := preload("res://scripts/domain/cases/CaseGeneratorPublicSolver.gd")
const CAPABILITY := preload("res://scripts/domain/cases/CaseProceduralPretendCapability.gd")


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	for active_id: StringName in [&"tailor", &"vigilante"]:
		_test_active(rows, roles, active_id)
	var boundaries: bool = true
	for role: RoleDefinition in roles:
		if role == null:
			continue
		if role.role_id in [&"tailor", &"vigilante"]:
			boundaries = boundaries and CAPABILITY.can_pretend(&"copycat", role) and not CAPABILITY.is_supported_behavior(role.role_id)
			for mobster_id: StringName in CAPABILITY.MOBSTER_ROLE_IDS:
				boundaries = boundaries and CAPABILITY.can_pretend(mobster_id, role)
			boundaries = boundaries and CAPABILITY.can_pretend(&"serial_killer", role)
			for other_id: StringName in [&"conman", &"poisoner", &"barkeep", &"spectre", &"critic"]:
				boundaries = boundaries and not CAPABILITY.can_pretend(other_id, role)
		elif role.role_id == &"clock_maker":
			boundaries = boundaries and CAPABILITY.can_pretend(&"copycat", role)
			boundaries = boundaries and not CAPABILITY.COPYCAT_ACTIVE_ROLE_IDS.has(role.role_id)
		elif role.role_id in [&"surgeon", &"serial_killer", &"critic"]:
			boundaries = boundaries and not CAPABILITY.can_pretend(&"copycat", role)
	boundaries = (
		boundaries
		and CAPABILITY.behavior_requires_current_native_witness(&"tailor")
		and CAPABILITY.behavior_requires_current_native_witness(&"vigilante")
		and not CAPABILITY.behavior_requires_current_native_witness(&"clock_maker")
	)
	_add(rows, &"capability", "active targets require explicit approved pretenders and shared witness policy", boundaries)
	return rows


func _test_active(rows: Array[Dictionary], roles: Array[RoleDefinition], active_id: StringName) -> void:
	var generator = GENERATOR.new()
	var accepted: CaseGenerationAcceptanceResult = _find_accepted(roles, active_id)
	var definition: CaseDefinition
	var candidate: CaseGenerationResult
	var solved: CaseGeneratorSolverResult
	if accepted != null and accepted.success:
		candidate = accepted.accepted_candidate as CaseGenerationResult
		solved = accepted.accepted_solver_result as CaseGeneratorSolverResult
		definition = generator.case_definition_from_result(candidate)
	var owner: SuspectDefinition = _find_role(definition, &"copycat")
	var native: SuspectDefinition = _find_role(definition, active_id)
	var accepted_ok: bool = owner != null and native != null and owner.displayed_role_id == active_id
	if accepted_ok:
		var validation: Dictionary = CaseDefinitionValidator.new().validate(definition, roles, FixtureRepository.load_players())
		accepted_ok = bool(validation.get("passed", false)) and owner.true_alignment == CaseEnums.Alignment.GOOD and owner.role_group == CaseEnums.RoleGroup.HIEU_SU and owner.is_impersonating and owner.impersonated_role_id == active_id
		for clue in candidate.hidden_case_draft.public_clues:
			accepted_ok = accepted_ok and clue.suspect_id != owner.suspect_id and clue.suspect_id != native.suspect_id
	_add(rows, active_id, "accepted UNIQUE with true Copycat and native witness, no active clue", (
		accepted_ok and solved != null and solved.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION
		and solved.ground_truth_checked and solved.unique_solution_matches_ground_truth
	), "root=%d accepted_seed=%d" % [accepted.root_seed, accepted.accepted_derived_seed] if accepted != null else "no matching accepted candidate")
	var deterministic: bool = false
	if candidate != null:
		var repeated: CaseGenerationResult = generator.generate(_request(candidate.seed_used), roles)
		deterministic = repeated.is_success() and repeated.fingerprint == candidate.fingerprint
	_add(rows, active_id, "same seed preserves disguise and fingerprint", deterministic)
	_add(rows, active_id, "missing or transformed native witness cannot be supplied by display", _missing_witness_rejected(roles, active_id, candidate))
	_add(rows, active_id, "Mailman sees true Copycat and exactly one native role", _role_presence(definition, roles, active_id))
	var runtime_checks: Dictionary = _runtime_checks(definition, roles, active_id)
	_add(rows, active_id, "borrowed function starts unused and unlocks without public result", bool(runtime_checks.get("lifecycle", false)))
	_add(rows, active_id, "player action uses shared function and consumes one use", bool(runtime_checks.get("execution", false)))
	_add(rows, active_id, "effective owner taint controls borrowed execution", bool(runtime_checks.get("taint", false)))
	var ambiguous_ids: Array[StringName] = [&"copycat", active_id, &"tutorial_priest", &"conman", &"tutorial_scoundrel"]
	var locations: Array[StringName] = [BoardLocationDefinition.LOCATION_CRIME_SCENE]
	var ambiguous_request: CaseGenerationRequest = REQUEST.create(112233, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY, ambiguous_ids, locations, 5)
	var rejected: CaseGenerationAcceptanceResult = ACCEPTANCE.new().accept_unique_candidate(ambiguous_request, roles, 2)
	_add(rows, active_id, "ambiguous pre-function evidence is rejected normally", (
		not rejected.success and rejected.accepted_candidate == null
		and int(rejected.rejected_status_counts.get(ACCEPTANCE.REJECTION_MULTIPLE_SOLUTIONS, 0)) == 2
	))


func _request(seed_value: int) -> CaseGenerationRequest:
	var ids: Array[StringName] = [&"copycat", &"tailor", &"vigilante", &"tutorial_priest", &"tutorial_scoundrel"]
	var locations: Array[StringName] = [BoardLocationDefinition.LOCATION_CRIME_SCENE]
	return REQUEST.create(seed_value, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY, ids, locations, 5)


func _find_accepted(roles: Array[RoleDefinition], active_id: StringName) -> CaseGenerationAcceptanceResult:
	# Bounded fixture search only; every call uses unchanged production acceptance/retry.
	for root: int in range(112233, 112257):
		var accepted: CaseGenerationAcceptanceResult = ACCEPTANCE.new().accept_unique_candidate(_request(root), roles)
		if not accepted.success:
			continue
		for suspect in accepted.accepted_candidate.hidden_case_draft.suspects:
			if suspect.true_role_id == &"copycat" and suspect.displayed_role_id == active_id:
				return accepted
	return null


func _missing_witness_rejected(roles: Array[RoleDefinition], active_id: StringName, candidate: CaseGenerationResult) -> bool:
	if not _shared_witness_contract(active_id):
		return false
	# Public Mailman claims Copycat present and the active role absent. Display alone cannot witness it.
	var view: GeneratedPublicCaseView = VIEW.create_manual(3, 3, 1, [
		SUSPECT.create(1, 0, active_id, CaseEnums.RoleGroup.CHINH_NHAN),
		SUSPECT.create(2, 1, &"mailman", CaseEnums.RoleGroup.CHINH_NHAN),
		SUSPECT.create(3, 2, &"tutorial_scoundrel", CaseEnums.RoleGroup.TONG_PHAM),
	])
	view.allowed_role_ids = [&"copycat", active_id, &"mailman", &"tutorial_scoundrel"]
	view.suspected_role_ids = view.allowed_role_ids.duplicate()
	var clue = CLUE.new()
	clue.suspect_id = 2
	clue.behavior_role_id = &"mailman"
	clue.payload_kind = InvestigationInformationResult.PayloadKind.ROLE_PLAY_CLAIM
	clue.in_play_role_id = &"copycat"
	clue.not_in_play_role_id = active_id
	view.public_clues.append(clue)
	var solved: CaseGeneratorSolverResult = SOLVER.new().solve(view, roles)
	if candidate == null or solved.status != CaseGeneratorSolverResult.STATUS_NO_SOLUTION:
		return false
	var generator = GENERATOR.new()
	var repeated: CaseGenerationResult = generator.generate(_request(candidate.seed_used), roles)
	if not repeated.is_success():
		return false
	for suspect in repeated.hidden_case_draft.suspects:
		if suspect.true_role_id == active_id:
			repeated.hidden_case_draft.barkeep_transform_target_suspect_id = suspect.suspect_id
	if generator._generate_public_clues(repeated.hidden_case_draft, roles, repeated.suspected_role_ids):
		return false
	# Keep the old displayed identity, remove its only true witness, and reselect normally.
	for index: int in range(repeated.hidden_case_draft.suspects.size() - 1, -1, -1):
		if repeated.hidden_case_draft.suspects[index].true_role_id == active_id:
			repeated.hidden_case_draft.suspects.remove_at(index)
	var roles_by_id: Dictionary = {}
	for role: RoleDefinition in roles:
		if role != null:
			roles_by_id[role.role_id] = role
	var rng := RandomNumberGenerator.new()
	rng.seed = 112233
	if not generator._assign_pretend_roles(repeated.hidden_case_draft, roles_by_id, rng):
		return true
	for suspect in repeated.hidden_case_draft.suspects:
		if suspect.true_role_id == &"copycat" and suspect.displayed_role_id == active_id:
			return false
	return true


func _shared_witness_contract(active_id: StringName) -> bool:
	var suspect_ids: PackedInt32Array = PackedInt32Array([1, 2, 3])
	var native_roles: Dictionary = {1: &"copycat", 2: active_id, 3: &"tutorial_scoundrel"}
	var transformed_roles: Dictionary = {1: &"copycat", 2: &"drunkard", 3: &"tutorial_scoundrel"}
	var displayed_copy_roles: Dictionary = {1: &"copycat", 2: &"copycat", 3: &"tutorial_scoundrel"}
	var self_only_ids: PackedInt32Array = PackedInt32Array([1, 3])
	var self_only_roles: Dictionary = {1: active_id, 3: &"tutorial_scoundrel"}
	return (
		CAPABILITY.procedural_current_native_witness_is_satisfied(
			1, active_id, suspect_ids, native_roles
		)
		and not CAPABILITY.procedural_current_native_witness_is_satisfied(
			1, active_id, suspect_ids, transformed_roles
		)
		and not CAPABILITY.procedural_current_native_witness_is_satisfied(
			1, active_id, suspect_ids, displayed_copy_roles
		)
		and not CAPABILITY.procedural_current_native_witness_is_satisfied(
			1, active_id, self_only_ids, self_only_roles
		)
	)


func _role_presence(source: CaseDefinition, roles: Array[RoleDefinition], active_id: StringName) -> bool:
	if source == null:
		return false
	var definition: CaseDefinition = source.duplicate(true) as CaseDefinition
	var native: SuspectDefinition = _find_role(definition, active_id)
	var mailman: SuspectDefinition = _find_role(definition, &"tutorial_priest")
	if native == null or mailman == null:
		return false
	mailman.true_role_id = &"mailman"
	mailman.displayed_role_id = &"mailman"
	definition.suspected_role_ids.append(&"mailman")
	definition.suspected_role_ids.append(&"mathematician")
	var result: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(
		definition, mailman.suspect_id, roles, {"in_play_role_id": active_id, "not_in_play_role_id": &"mathematician"}
	)
	var present: Array[StringName] = CaseRolePoolService.current_role_ids_in_play(definition, null)
	definition.suspects.erase(native)
	var after: Array[StringName] = CaseRolePoolService.current_role_ids_in_play(definition, null)
	return result.claimed_in_play_is_true and result.claimed_not_in_play_is_true and present.count(active_id) == 1 and present.has(&"copycat") and not after.has(active_id) and after.has(&"copycat")


func _runtime_checks(source: CaseDefinition, roles: Array[RoleDefinition], active_id: StringName) -> Dictionary:
	var checks: Dictionary = {"lifecycle": false, "execution": false, "taint": false}
	if source == null:
		return checks
	for tainted: bool in [false, true]:
		var definition: CaseDefinition = source.duplicate(true) as CaseDefinition
		var owner: SuspectDefinition = _find_role(definition, &"copycat")
		var evil: SuspectDefinition = _find_role(definition, &"tutorial_scoundrel")
		if owner == null or evil == null:
			return checks
		# Deliberately misleading displayed identity must not replace target true alignment.
		evil.displayed_role_id = &"tutorial_priest"
		var runtime := CaseRuntimeState.new()
		runtime.initialize(definition, FixtureRepository.load_players())
		for player: PlayerCaseState in runtime.players:
			runtime.turn_order_player_ids.append(player.player_id)
		var availability := FunctionAvailabilityService.new()
		availability.initialize_hidden_states(definition, runtime, roles)
		var state: InteractiveFunctionRuntimeState = runtime.find_suspect(owner.suspect_id).interactive_function
		if state == null:
			return checks
		var expected_type: int = CaseEnums.FunctionType.TAILOR_COMPARE_ALIGNMENT if active_id == &"tailor" else CaseEnums.FunctionType.VIGILANTE_KILL
		var lifecycle: bool = state.state == InteractiveFunctionRuntimeState.State.HIDDEN and state.uses_remaining == 1 and state.function_type == expected_type and runtime.public_function_records.is_empty() and not runtime.find_suspect(evil.suspect_id).is_dead
		runtime.find_suspect(owner.suspect_id).is_investigated = true
		var revealed: bool = availability.reveal_for_suspect(definition, runtime, roles, owner.suspect_id, 1)
		availability.update_for_turn(runtime, 2)
		lifecycle = lifecycle and revealed and state.state == InteractiveFunctionRuntimeState.State.AVAILABLE and runtime.public_function_records.is_empty()
		if tainted:
			runtime.find_suspect(owner.suspect_id).apply_runtime_corruption(evil.suspect_id)
		var targets: PackedInt32Array = PackedInt32Array([owner.suspect_id, evil.suspect_id]) if active_id == &"tailor" else PackedInt32Array([evil.suspect_id])
		var execution := InteractiveFunctionExecutionService.new()
		var result: InteractiveFunctionResult = execution.execute(definition, runtime, owner.suspect_id, targets, runtime.current_player_id())
		var repeated: InteractiveFunctionResult = execution.execute(definition, runtime, owner.suspect_id, targets, runtime.current_player_id())
		var effect: bool = false
		if active_id == &"tailor":
			var expected_result: int = InteractiveFunctionResult.PublicResultType.SAME_ALIGNMENT if tainted else InteractiveFunctionResult.PublicResultType.DIFFERENT_ALIGNMENT
			effect = result.public_result_type == expected_result
		else:
			if tainted:
				effect = not result.vigilante_kill_attempted and not runtime.find_suspect(evil.suspect_id).is_dead
			else:
				effect = result.vigilante_target_killed and runtime.find_suspect(evil.suspect_id).is_dead
		var completed: bool = lifecycle and result.success and effect and not repeated.success and state.uses_remaining == 0 and state.state == InteractiveFunctionRuntimeState.State.EXHAUSTED and runtime.public_function_records.size() == 1
		if completed:
			completed = runtime.public_function_records[0].source_suspect_id == owner.suspect_id and runtime.public_function_records[0].target_suspect_ids == targets
		if tainted:
			checks.taint = completed
		else:
			checks.lifecycle = lifecycle
			checks.execution = completed
	return checks


func _find_role(definition: CaseDefinition, role_id: StringName) -> SuspectDefinition:
	if definition != null:
		for suspect: SuspectDefinition in definition.suspects:
			if suspect.true_role_id == role_id:
				return suspect
	return null


func _add(rows: Array[Dictionary], active_id: StringName, label: String, passed: bool, detail: String = "No future borrowed-function evidence") -> void:
	rows.append({"name": "Slice 4 Copycat -> %s: %s" % [active_id, label], "passed": passed, "detail": detail})
