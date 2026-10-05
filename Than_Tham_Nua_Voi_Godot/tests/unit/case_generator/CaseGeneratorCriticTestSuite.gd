extends RefCounted

const REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")
const GENERATOR := preload("res://scripts/domain/cases/CaseGenerator.gd")
const PUBLIC_VIEW := preload("res://scripts/domain/cases/GeneratedPublicCaseView.gd")
const PUBLIC_SUSPECT := preload("res://scripts/domain/cases/GeneratedPublicSuspectView.gd")
const SOLVER := preload("res://scripts/domain/cases/CaseGeneratorPublicSolver.gd")
const ACCEPTANCE := preload("res://scripts/domain/cases/CaseGenerationAcceptanceService.gd")
const PRETEND := preload("res://scripts/domain/cases/CaseProceduralPretendCapability.gd")
const NEXT_CASE := preload("res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd")


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var generator = GENERATOR.new()
	var request: CaseGenerationRequest = _request(112233)
	var candidate: CaseGenerationResult = generator.generate(request, roles)
	var definition: CaseDefinition = generator.case_definition_from_result(candidate)
	var owner: SuspectDefinition = _role_suspect(definition, PRETEND.CRITIC_ROLE_ID)
	var fake_role_id: StringName = owner.displayed_role_id if owner != null else &""
	var clue = _clue_for_suspect(candidate, owner.suspect_id if owner != null else 0)
	var runtime := CaseRuntimeState.new()
	var no_players: Array[PlayerCaseState] = []
	if definition != null:
		runtime.initialize(definition, no_players)

	_add(rows, "Slice 8 Critic capability has explicit lying-role allowlist", (
		PRETEND.CRITIC_LYING_BEHAVIOR_ROLE_IDS == [
			&"tutorial_priest", &"priest", &"reporter", &"therapist", &"mathematician",
			&"weatherman", &"blood_hound", &"mailman", &"clock_maker",
		]
	))
	_add(rows, "Slice 8 Critic capability accepts Mailman and Clock Maker but rejects self", (
		not PRETEND.critic_can_pretend(&"critic")
		and PRETEND.critic_can_pretend(&"mailman")
		and PRETEND.critic_can_pretend(&"clock_maker")
	))
	_add(rows, "Slice 8 generator creates native Evil Critic", (
		candidate != null and candidate.is_success() and owner != null
		and owner.true_role_id == &"critic"
		and owner.role_group == CaseEnums.RoleGroup.NGHICH_THAN
		and owner.true_alignment == CaseEnums.Alignment.EVIL
	))
	_add(rows, "Slice 8 generated Critic fake role is listed", (
		owner != null and definition.suspected_role_ids.has(fake_role_id)
	))
	_add(rows, "Slice 8 generated Critic fake role is current-absent", (
		owner != null and CaseRolePoolService.is_listed_current_role_absent(
			definition, runtime, fake_role_id
		)
	))
	_add(rows, "Slice 8 displayed fake role does not become current in-play", (
		owner != null
		and owner.displayed_role_id == owner.impersonated_role_id
		and not CaseRolePoolService.current_role_ids_in_play(definition, runtime).has(fake_role_id)
	))
	_add(rows, "Slice 8 Critic requires no natural fake-role witness", (
		owner != null and _current_role_count(definition, runtime, fake_role_id) == 0
	))
	_add(rows, "Slice 8 generated clue uses displayed fake behavior", (
		owner != null and clue != null
		and PRETEND.critic_can_pretend(fake_role_id)
		and clue.displayed_role_id == fake_role_id
		and clue.behavior_role_id == fake_role_id
	))
	_add(rows, "Slice 8 generated Critic clue is LYING", (
		clue != null and clue.truth_mode == InvestigationInformationResult.TruthMode.LYING
	))
	_add(rows, "Slice 8 generated fake role differs from Critic", (
		owner != null and fake_role_id != &"critic" and not String(fake_role_id).is_empty()
	))
	var validation: Dictionary = CaseDefinitionValidator.new().validate(
		definition, roles, FixtureRepository.load_players()
	) if definition != null else {"passed": false}
	_add(rows, "Slice 8 generated Critic Case validates structurally", bool(validation.get("passed", false)))

	var view: GeneratedPublicCaseView = PUBLIC_VIEW.from_generation_result(candidate, roles)
	var solved: CaseGeneratorSolverResult = SOLVER.new().solve(view, roles)
	_add(rows, "Slice 8 solver supports Critic public worlds", (
		solved != null and solved.status != CaseGeneratorSolverResult.STATUS_UNSUPPORTED
	))
	_add(rows, "Slice 8 solver keeps the generated Critic ground-truth world", (
		solved != null and definition != null
		and _candidate_sets_have(solved.candidate_evil_sets, definition.evil_suspect_ids)
	))
	var hypothesis_checks: Dictionary = _dedicated_hypothesis_checks(roles)
	_add(rows, "Slice 8 dedicated hypothesis accepts listed absent role without witness", bool(hypothesis_checks.get("absent", false)))
	_add(rows, "Slice 8 dedicated hypothesis rejects a current-present fake role", bool(hypothesis_checks.get("present", false)))
	_add(rows, "Slice 8 Mailman still treats displayed fake role as absent", _mailman_sees_fake_absent(definition, roles, fake_role_id))

	var accepted: CaseGenerationAcceptanceResult = ACCEPTANCE.new().accept_unique_candidate(request, roles)
	var accepted_definition: CaseDefinition = null
	var accepted_solver: CaseGeneratorSolverResult = null
	if accepted != null and accepted.success:
		accepted_definition = generator.case_definition_from_result(accepted.accepted_candidate)
		accepted_solver = accepted.accepted_solver_result as CaseGeneratorSolverResult
	var evidence: String = _accepted_evidence(accepted, accepted_definition, accepted_solver)
	_add(rows, "Slice 8 normal acceptance requires UNIQUE ground-truth match", (
		accepted != null and accepted.success and accepted_solver != null
		and accepted_solver.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION
		and accepted_solver.ground_truth_checked
		and accepted_solver.unique_solution_matches_ground_truth
		and _role_suspect(accepted_definition, &"critic") != null
	), evidence)
	if not evidence.is_empty():
		print("SLICE8_CRITIC_EVIDENCE " + evidence)
	_add(rows, "Slice 8 production pool enables supported Critic only", _production_boundary())
	_add(rows, "Slice 8 solver input carries no player ownership or reputation evidence", _solver_input_excludes_meta(view))
	_add(rows, "Slice 8 Tutorial 05 Critic contract remains unchanged", _tutorial_05_unchanged(roles))
	return rows


func _request(seed: int) -> CaseGenerationRequest:
	var role_ids: Array[StringName] = [
		&"critic", &"tutorial_priest", &"reporter", &"therapist", &"mathematician", &"mailman",
	]
	var location_ids: Array[StringName] = [BoardLocationDefinition.LOCATION_CRIME_SCENE]
	return REQUEST.create(seed, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY, role_ids, location_ids, 5)


func _dedicated_hypothesis_checks(_roles: Array[RoleDefinition]) -> Dictionary:
	var suspects: Array = [
		PUBLIC_SUSPECT.create(1, 0, &"reporter", CaseEnums.RoleGroup.CHINH_NHAN),
		PUBLIC_SUSPECT.create(2, 1, &"therapist", CaseEnums.RoleGroup.CHINH_NHAN),
		PUBLIC_SUSPECT.create(3, 2, &"mathematician", CaseEnums.RoleGroup.CHINH_NHAN),
	]
	var view: GeneratedPublicCaseView = PUBLIC_VIEW.create_manual(3, 3, 1, suspects)
	view.suspected_role_ids = [&"critic", &"reporter", &"therapist", &"mathematician"]
	var solver = SOLVER.new()
	var absent_assignment: Dictionary = {1: &"critic", 2: &"therapist", 3: &"mathematician"}
	var present_assignment: Dictionary = {1: &"critic", 2: &"reporter", 3: &"mathematician"}
	return {
		"absent": solver._critic_hypothesis_is_valid(view, absent_assignment, 1, &"reporter", 0),
		"present": not solver._critic_hypothesis_is_valid(view, present_assignment, 1, &"reporter", 0),
	}


func _mailman_sees_fake_absent(
	source: CaseDefinition, roles: Array[RoleDefinition], fake_role_id: StringName
) -> bool:
	if source == null or String(fake_role_id).is_empty():
		return false
	var definition: CaseDefinition = source.duplicate(true) as CaseDefinition
	var mailman: SuspectDefinition = _role_suspect(definition, &"mailman")
	if mailman == null:
		for suspect: SuspectDefinition in definition.suspects:
			if suspect.true_role_id != &"critic":
				suspect.true_role_id = &"mailman"
				suspect.displayed_role_id = &"mailman"
				suspect.impersonated_role_id = &""
				suspect.is_impersonating = false
				mailman = suspect
				break
	if mailman == null:
		return false
	var result: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(
		definition, mailman.suspect_id, roles,
		{"in_play_role_id": &"critic", "not_in_play_role_id": fake_role_id}
	)
	return (
		result != null and result.in_play_role_id == &"critic"
		and result.not_in_play_role_id == fake_role_id
		and result.claimed_in_play_is_true and result.claimed_not_in_play_is_true
	)


func _production_boundary() -> bool:
	var production_ids: Array[StringName] = NEXT_CASE.new()._default_next_case_generation_request().allowed_role_ids
	return (
		production_ids.has(&"critic")
		and SOLVER.SUPPORTED_PUBLIC_ROLE_IDS.has(&"critic")
		and not production_ids.has(&"drunkard")
	)


func _solver_input_excludes_meta(view: GeneratedPublicCaseView) -> bool:
	if view == null:
		return false
	var property_names: Array[StringName] = []
	for property_info: Dictionary in view.get_property_list():
		property_names.append(StringName(property_info.get("name", "")))
	return not property_names.has(&"player_id") and not property_names.has(&"case_role_id") and not property_names.has(&"reputation")


func _candidate_sets_have(candidate_sets: Array, expected_ids: PackedInt32Array) -> bool:
	var expected: PackedInt32Array = expected_ids.duplicate()
	expected.sort()
	for candidate_ids: PackedInt32Array in candidate_sets:
		var normalized: PackedInt32Array = candidate_ids.duplicate()
		normalized.sort()
		if normalized == expected:
			return true
	return false


func _tutorial_05_unchanged(roles: Array[RoleDefinition]) -> bool:
	var definition: CaseDefinition = FixtureRepository.load_tutorial_case_005()
	var owner: SuspectDefinition = _suspect(definition, 1)
	var report: Dictionary = CaseDefinitionValidator.new().validate(
		definition, roles, FixtureRepository.load_players()
	)
	return (
		owner != null and owner.true_role_id == &"critic"
		and owner.displayed_role_id == &"mathematician"
		and owner.is_impersonating and owner.impersonated_role_id == &"mathematician"
		and definition.suspected_role_ids.has(&"mathematician")
		and CaseRolePoolService.is_listed_current_role_absent(definition, null, &"mathematician")
		and bool(report.get("passed", false))
	)


func _accepted_evidence(
	accepted: CaseGenerationAcceptanceResult,
	definition: CaseDefinition,
	solver: CaseGeneratorSolverResult
) -> String:
	if accepted == null or not accepted.success or definition == null or solver == null:
		return ""
	var owner: SuspectDefinition = _role_suspect(definition, &"critic")
	if owner == null:
		return ""
	return "root=%d accepted_seed=%d suspects=%d critic_id=%d fake=%s listed=%s current_absent=%s solver=%s meta_evidence=false" % [
		accepted.root_seed,
		accepted.accepted_derived_seed,
		definition.suspects.size(),
		owner.suspect_id,
		String(owner.displayed_role_id),
		str(definition.suspected_role_ids.has(owner.displayed_role_id)),
		str(CaseRolePoolService.is_listed_current_role_absent(definition, null, owner.displayed_role_id)),
		String(solver.status),
	]


func _clue_for_suspect(candidate: CaseGenerationResult, suspect_id: int):
	if candidate != null and candidate.hidden_case_draft != null:
		for clue in candidate.hidden_case_draft.public_clues:
			if clue != null and clue.suspect_id == suspect_id:
				return clue
	return null


func _current_role_count(
	definition: CaseDefinition, runtime: CaseRuntimeState, role_id: StringName
) -> int:
	var count: int = 0
	for current_role_id: StringName in CaseRolePoolService.current_role_ids_in_play(definition, runtime):
		if current_role_id == role_id:
			count += 1
	return count


func _role_suspect(definition: CaseDefinition, role_id: StringName) -> SuspectDefinition:
	if definition != null:
		for suspect: SuspectDefinition in definition.suspects:
			if suspect.true_role_id == role_id:
				return suspect
	return null


func _suspect(definition: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	if definition != null:
		for suspect: SuspectDefinition in definition.suspects:
			if suspect.suspect_id == suspect_id:
				return suspect
	return null


func _add(rows: Array[Dictionary], name: String, passed: bool, detail: String = "Critic listed-but-current-absent deduction invariant") -> void:
	rows.append({"name": name, "passed": passed, "detail": detail})
