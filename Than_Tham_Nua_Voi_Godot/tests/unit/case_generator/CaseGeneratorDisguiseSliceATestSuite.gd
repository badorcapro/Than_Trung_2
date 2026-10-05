extends RefCounted

const REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")
const GENERATOR := preload("res://scripts/domain/cases/CaseGenerator.gd")
const ACCEPTANCE := preload("res://scripts/domain/cases/CaseGenerationAcceptanceService.gd")
const CAPABILITY := preload("res://scripts/domain/cases/CaseProceduralPretendCapability.gd")

const NEW_CLUE_ROLE_IDS: Array[StringName] = [
	&"weatherman", &"blood_hound", &"mailman",
]


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var role_by_id: Dictionary = _roles_by_id(roles)
	var mobster_procedural_ok: bool = true
	var critic_procedural_ok: bool = true
	for role_id: StringName in NEW_CLUE_ROLE_IDS:
		var role: RoleDefinition = role_by_id.get(role_id, null) as RoleDefinition
		mobster_procedural_ok = mobster_procedural_ok and CAPABILITY.can_pretend_procedural(
			&"tutorial_mobster", role
		)
		critic_procedural_ok = critic_procedural_ok and CAPABILITY.critic_can_pretend(role_id)
	_add(rows, "Disguise Slice A Mobster procedural scope adds three clue-only roles", mobster_procedural_ok)
	_add(rows, "Disguise Slice A Critic procedural scope adds three clue-only roles", critic_procedural_ok)

	var tailor: RoleDefinition = role_by_id.get(&"tailor", null) as RoleDefinition
	var clock_maker: RoleDefinition = role_by_id.get(&"clock_maker", null) as RoleDefinition
	_add(rows, "Disguise Slice D1 promotes Mobster Tailor while preserving authored scope", (
		CAPABILITY.can_pretend_authored_compatible(&"tutorial_mobster", tailor)
		and CAPABILITY.can_pretend_procedural(&"tutorial_mobster", tailor)
	))
	_add(rows, "Disguise Slice A Mobster Clock Maker remains authored-compatible after procedural promotion", (
		CAPABILITY.can_pretend_authored_compatible(&"tutorial_mobster", clock_maker)
		and CAPABILITY.can_pretend_procedural(&"tutorial_mobster", clock_maker)
	))
	_add(rows, "Disguise Slice A procedural Mobster scope is an authored-compatible subset", (
		_procedural_mobster_is_authored_subset()
	))
	var surgeon: RoleDefinition = role_by_id.get(&"surgeon", null) as RoleDefinition
	_add(rows, "Disguise Slice A unsupported Mobster target is rejected by both scopes", (
		not CAPABILITY.can_pretend_procedural(&"tutorial_mobster", surgeon)
		and not CAPABILITY.can_pretend_authored_compatible(&"tutorial_mobster", surgeon)
	))

	var validator := CaseDefinitionValidator.new()
	var players: Array[PlayerCaseState] = FixtureRepository.load_players()
	var tutorial_04_report: Dictionary = validator.validate(
		FixtureRepository.load_tutorial_case_004(), roles, players
	)
	var tutorial_07_report: Dictionary = validator.validate(
		FixtureRepository.load_tutorial_case_007(), roles, players
	)
	_add(rows, "Disguise Slice A Tutorial 04 Mobster to Tailor remains valid", bool(tutorial_04_report.get("passed", false)))
	_add(rows, "Disguise Slice A Tutorial 07 Mobster to Clock Maker remains valid", bool(tutorial_07_report.get("passed", false)))
	_add(rows, "Disguise Slice A authored validator rejects unsupported Mobster target", (
		_authored_validator_rejects_unsupported_mobster(roles, players)
	))
	_add(rows, "Disguise Slice A other pretender scopes remain aligned", (
		_other_pretender_scopes_are_unchanged(roles)
	))

	var mobster_acceptance: CaseGenerationAcceptanceResult = ACCEPTANCE.new().accept_unique_candidate(
		_mobster_request(), roles
	)
	var mobster_evidence: Dictionary = _accepted_evidence(mobster_acceptance, roles, &"tutorial_mobster")
	_add(rows, "Disguise Slice A Mobster accepted Case uses a new current in-play witness", (
		bool(mobster_evidence.get("accepted", false))
		and NEW_CLUE_ROLE_IDS.has(StringName(mobster_evidence.get("displayed_role_id", &"")))
		and bool(mobster_evidence.get("current_witness", false))
		and bool(mobster_evidence.get("lying_clue", false))
	), String(mobster_evidence.get("text", "")))
	_add(rows, "Disguise Slice A transformed-away Mobster witness is rejected", (
		_mobster_transformed_witness_is_rejected(mobster_acceptance)
	))

	var critic_evidence: Dictionary = _fixed_critic_blood_hound_evidence(roles)
	_add(rows, "Disguise Slice A Critic accepted Case uses a new listed current-absent target", (
		bool(critic_evidence.get("accepted", false))
		and int(critic_evidence.get("root_seed", 0)) == 112233
		and int(critic_evidence.get("accepted_seed", 0)) == 112233
		and int(critic_evidence.get("owner_suspect_id", 0)) == 4
		and StringName(critic_evidence.get("displayed_role_id", &"")) == &"blood_hound"
		and CAPABILITY.critic_can_pretend(&"blood_hound")
		and bool(critic_evidence.get("listed", false))
		and bool(critic_evidence.get("current_absent", false))
		and not bool(critic_evidence.get("current_witness", true))
		and bool(critic_evidence.get("lying_clue", false))
		and StringName(critic_evidence.get("solver_status", &"")) == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION
		and bool(critic_evidence.get("ground_truth_match", false))
	), String(critic_evidence.get("text", "")))
	return rows


func _mobster_request() -> CaseGenerationRequest:
	var role_ids: Array[StringName] = [
		&"tutorial_mobster", &"weatherman", &"blood_hound", &"mailman", &"role_meddler_a", &"surgeon",
	]
	var location_ids: Array[StringName] = [BoardLocationDefinition.LOCATION_CRIME_SCENE]
	return REQUEST.create(112233, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY, role_ids, location_ids, 6)


func _critic_request(seed: int, target_role_id: StringName) -> CaseGenerationRequest:
	var role_ids: Array[StringName] = [
		&"critic", &"tutorial_priest", &"reporter", target_role_id, &"mathematician", &"therapist",
	]
	var location_ids: Array[StringName] = [BoardLocationDefinition.LOCATION_CRIME_SCENE]
	return REQUEST.create(seed, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY, role_ids, location_ids, 5)


func _fixed_critic_blood_hound_evidence(roles: Array[RoleDefinition]) -> Dictionary:
	var accepted: CaseGenerationAcceptanceResult = ACCEPTANCE.new().accept_unique_candidate(
		_critic_request(112233, &"blood_hound"), roles, 1
	)
	return _accepted_evidence(accepted, roles, &"critic")


func _accepted_evidence(
	accepted: CaseGenerationAcceptanceResult,
	roles: Array[RoleDefinition],
	owner_role_id: StringName
) -> Dictionary:
	var evidence: Dictionary = {
		"accepted": false,
		"root_seed": 0,
		"accepted_seed": 0,
		"owner_suspect_id": 0,
		"displayed_role_id": &"",
		"current_witness": false,
		"current_absent": false,
		"listed": false,
		"lying_clue": false,
		"solver_status": &"",
		"ground_truth_match": false,
		"text": "",
	}
	if accepted == null or not accepted.success or accepted.accepted_candidate == null:
		return evidence
	var definition: CaseDefinition = GENERATOR.new().case_definition_from_result(accepted.accepted_candidate)
	var owner: SuspectDefinition = _role_suspect(definition, owner_role_id)
	if definition == null or owner == null:
		return evidence
	var runtime := CaseRuntimeState.new()
	var no_players: Array[PlayerCaseState] = []
	runtime.initialize(definition, no_players)
	if definition.startup_barkeep_source_suspect_id > 0:
		BarkeepTransformationService.new().resolve_transformation(
			definition, runtime, definition.startup_barkeep_source_suspect_id,
			definition.startup_barkeep_target_suspect_id, roles
		)
	var current_ids: Array[StringName] = CaseRolePoolService.current_role_ids_in_play(
		definition, runtime, owner.suspect_id
	)
	var clue: GeneratedPublicClue = _clue_for_suspect(accepted.accepted_candidate, owner.suspect_id) as GeneratedPublicClue
	var solver: CaseGeneratorSolverResult = accepted.accepted_solver_result as CaseGeneratorSolverResult
	evidence.accepted = (
		solver != null
		and solver.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION
		and solver.unique_solution_matches_ground_truth
	)
	evidence.root_seed = accepted.root_seed
	evidence.accepted_seed = accepted.accepted_derived_seed
	evidence.owner_suspect_id = owner.suspect_id
	evidence.displayed_role_id = owner.displayed_role_id
	evidence.current_witness = current_ids.has(owner.displayed_role_id)
	evidence.listed = definition.suspected_role_ids.has(owner.displayed_role_id)
	evidence.current_absent = CaseRolePoolService.is_listed_current_role_absent(
		definition, runtime, owner.displayed_role_id
	)
	evidence.lying_clue = clue != null and clue.truth_mode == InvestigationInformationResult.TruthMode.LYING
	evidence.solver_status = solver.status if solver != null else &""
	evidence.ground_truth_match = solver != null and solver.unique_solution_matches_ground_truth
	evidence.text = "root=%d accepted_seed=%d owner=%s displayed=%s witness=%s listed=%s solver=%s" % [
		accepted.root_seed, accepted.accepted_derived_seed, String(owner_role_id),
		String(owner.displayed_role_id), str(evidence.current_witness), str(evidence.listed),
		String(solver.status) if solver != null else "missing",
	]
	print("DISGUISE_SLICE_A_EVIDENCE " + String(evidence.text))
	return evidence


func _procedural_mobster_is_authored_subset() -> bool:
	for role_id: StringName in CAPABILITY.MOBSTER_PROCEDURAL_ROLE_IDS:
		if not CAPABILITY.MOBSTER_AUTHORED_COMPAT_ROLE_IDS.has(role_id):
			return false
	return true


func _mobster_transformed_witness_is_rejected(
	accepted: CaseGenerationAcceptanceResult
) -> bool:
	if accepted == null or not accepted.success or accepted.accepted_candidate == null:
		return false
	var draft: HiddenCaseDraft = accepted.accepted_candidate.hidden_case_draft as HiddenCaseDraft
	if draft == null:
		return false
	var owner: GeneratedSuspect = null
	var witness: GeneratedSuspect = null
	for suspect in draft.suspects:
		if suspect != null and CAPABILITY.MOBSTER_ROLE_IDS.has(suspect.true_role_id):
			owner = suspect
			break
	if owner == null:
		return false
	for suspect in draft.suspects:
		if (
			suspect != null
			and suspect.suspect_id != owner.suspect_id
			and suspect.true_role_id == owner.displayed_role_id
		):
			witness = suspect
			break
	if witness == null:
		return false
	var original_target_id: int = draft.barkeep_transform_target_suspect_id
	draft.barkeep_transform_target_suspect_id = witness.suspect_id
	var rejected: bool = not GENERATOR.new()._mobster_current_witnesses_are_valid(draft)
	draft.barkeep_transform_target_suspect_id = original_target_id
	return rejected and GENERATOR.new()._mobster_current_witnesses_are_valid(draft)


func _other_pretender_scopes_are_unchanged(roles: Array[RoleDefinition]) -> bool:
	var pretender_ids: Array[StringName] = [&"copycat", &"serial_killer", &"critic"]
	for role: RoleDefinition in roles:
		if role == null:
			continue
		for pretender_id: StringName in pretender_ids:
			if CAPABILITY.can_pretend_procedural(pretender_id, role) != CAPABILITY.can_pretend_authored_compatible(pretender_id, role):
				return false
	return true


func _authored_validator_rejects_unsupported_mobster(
	roles: Array[RoleDefinition], players: Array[PlayerCaseState]
) -> bool:
	var definition: CaseDefinition = FixtureRepository.load_tutorial_case_004().duplicate(true) as CaseDefinition
	var owner: SuspectDefinition = _role_suspect(definition, &"tutorial_mobster")
	if owner == null:
		return false
	owner.displayed_role_id = &"surgeon"
	owner.impersonated_role_id = &"surgeon"
	var report: Dictionary = CaseDefinitionValidator.new().validate(definition, roles, players)
	var errors: Array = report.get("errors", [])
	for error: Dictionary in errors:
		if String(error.get("code", "")) == "MOBSTER_PRETEND_ROLE_UNSUPPORTED":
			return true
	return false


func _clue_for_suspect(candidate: CaseGenerationResult, suspect_id: int):
	if candidate != null and candidate.hidden_case_draft != null:
		for clue in candidate.hidden_case_draft.public_clues:
			if clue != null and clue.suspect_id == suspect_id:
				return clue
	return null


func _role_suspect(definition: CaseDefinition, role_id: StringName) -> SuspectDefinition:
	if definition != null:
		for suspect: SuspectDefinition in definition.suspects:
			if suspect != null and suspect.true_role_id == role_id:
				return suspect
	return null


func _roles_by_id(roles: Array[RoleDefinition]) -> Dictionary:
	var by_id: Dictionary = {}
	for role: RoleDefinition in roles:
		if role != null:
			by_id[role.role_id] = role
	return by_id


func _add(rows: Array[Dictionary], name: String, passed: bool, detail: String = "Two-scope disguise capability invariant") -> void:
	rows.append({"name": name, "passed": passed, "detail": detail})
