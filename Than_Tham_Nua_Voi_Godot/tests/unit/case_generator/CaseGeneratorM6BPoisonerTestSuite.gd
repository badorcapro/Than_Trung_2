extends RefCounted

const GENERATOR := preload("res://scripts/domain/cases/CaseGenerator.gd")
const REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")
const PUBLIC_VIEW := preload("res://scripts/domain/cases/GeneratedPublicCaseView.gd")
const PUBLIC_SUSPECT := preload("res://scripts/domain/cases/GeneratedPublicSuspectView.gd")
const PUBLIC_CLUE := preload("res://scripts/domain/cases/GeneratedPublicClue.gd")
const SOLVER := preload("res://scripts/domain/cases/CaseGeneratorPublicSolver.gd")
const ACCEPTANCE := preload("res://scripts/domain/cases/CaseGenerationAcceptanceService.gd")
const DRAFT := preload("res://scripts/domain/cases/HiddenCaseDraft.gd")
const GENERATED_SUSPECT := preload("res://scripts/domain/cases/GeneratedSuspect.gd")
const NEXT_CASE_SESSION := preload("res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd")
const MUTATION_STATE := preload("res://scripts/domain/cases/CaseMutationStateSnapshot.gd")
const AUDIT := preload("res://scripts/tools/CaseGenerationAuditSnapshot.gd")


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var production_ids: Array[StringName] = NEXT_CASE_SESSION.new()._default_next_case_generation_request().allowed_role_ids
	_add(rows, "M6B-P1 Poisoner remains in production pool", production_ids.has(&"poisoner") and not production_ids.has(&"drunkard"))
	var role_ids: Array[StringName] = [&"poisoner", &"tutorial_priest", &"reporter"]
	var locations: Array[StringName] = [BoardLocationDefinition.LOCATION_CRIME_SCENE]
	var request: CaseGenerationRequest = REQUEST.create(112233, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY, role_ids, locations, 3)
	var generator = GENERATOR.new()
	var candidate: CaseGenerationResult = generator.generate(request, roles)
	var repeated: CaseGenerationResult = generator.generate(request, roles)
	var generated_case: CaseDefinition = generator.case_definition_from_result(candidate)
	var source_id: int = generated_case.startup_poisoner_source_suspect_id if generated_case != null else 0
	var target_id: int = generated_case.startup_poisoner_target_suspect_id if generated_case != null else 0
	var taint_service := PoisonerTaintService.new()
	_add(rows, "M6B-P1 generator selects one eligible occupied neighbor", generated_case != null and source_id > 0 and target_id > 0 and taint_service.eligible_taint_target_ids(generated_case, source_id).has(target_id))
	_add(rows, "M6B-P1 generator retains deterministic taint target", candidate != null and repeated != null and candidate.is_success() and repeated.is_success() and candidate.fingerprint == repeated.fingerprint and candidate.hidden_case_draft.poisoner_taint_target_suspect_id == repeated.hidden_case_draft.poisoner_taint_target_suspect_id)
	var validation: Dictionary = CaseDefinitionValidator.new().validate(generated_case, roles, FixtureRepository.load_players()) if generated_case != null else {}
	_add(rows, "M6B-P1 generated Poisoner Case validates", bool(validation.get("passed", false)))
	var generated_runtime: CaseRuntimeState = _tainted_runtime(generated_case, source_id, target_id)
	var generated_target: CaseMutationStateSnapshot = MUTATION_STATE.from_runtime(generated_case, generated_runtime, target_id, roles) if generated_runtime != null else null
	var generated_clue: GeneratedPublicClue = null
	if candidate != null and candidate.is_success():
		for clue: GeneratedPublicClue in candidate.hidden_case_draft.public_clues:
			if clue.suspect_id == target_id:
				generated_clue = clue
				break
	var replayed: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(generated_case, target_id, roles, {}, generated_runtime) if generated_runtime != null else null
	_add(rows, "M6B-P1 generated tainted clue replays from runtime", generated_clue != null and replayed != null and generated_clue.truth_mode == InvestigationInformationResult.TruthMode.LYING and generated_clue.payload_kind == replayed.payload_kind and generated_clue.numeric_value == replayed.numeric_value and generated_clue.text == replayed.public_text())
	_add(rows, "M6B-P1 taint preserves current Innocent role and group", generated_target != null and generated_target.original_role_id == generated_target.current_role_id and generated_target.current_role_group == CaseEnums.RoleGroup.CHINH_NHAN)
	_add(rows, "M6B-P1 tainted Innocent lies without becoming Evil", generated_target != null and generated_target.is_tainted and generated_target.truth_mode == InvestigationInformationResult.TruthMode.LYING and generated_target.current_alignment == CaseEnums.Alignment.GOOD)
	var public_target: GeneratedPublicSuspectView = PUBLIC_SUSPECT.from_mutation_state(generated_target, _slot_for(generated_case, target_id))
	_add(rows, "M6B-P1 public identity and group do not reveal taint", public_target != null and public_target.public_role_id == generated_target.displayed_role_id and public_target.public_role_group == CaseEnums.RoleGroup.CHINH_NHAN and not public_target.role_identity_obscured)
	var empty_case: CaseDefinition = _fixture_case(0, 8)
	var crime_scene := CrimeSceneDefinition.new()
	crime_scene.board_slot = 1
	empty_case.crime_scene = crime_scene
	_add(rows, "M6B-P1 distant Innocent and location are not taint targets", taint_service.eligible_taint_target_ids(empty_case, 1).is_empty())
	_add(rows, "M6B-P1 Poisoner cannot taint itself", not taint_service.is_eligible_taint_target(empty_case, 1, 1))
	var diagonal_case: CaseDefinition = _fixture_case(0, 4)
	_add(rows, "M6B-P1 diagonal Innocent is eligible", taint_service.eligible_taint_target_ids(diagonal_case, 1) == PackedInt32Array([2]))
	diagonal_case.suspects[1].is_corrupted = true
	_add(rows, "M6B-P1 already-tainted Innocent is excluded", taint_service.eligible_taint_target_ids(diagonal_case, 1).is_empty())
	var four_by_four: CaseDefinition = _fixture_case(0, 5)
	four_by_four.set_meta(&"board_columns", 4)
	four_by_four.set_meta(&"board_slot_count", 16)
	_add(rows, "M6B-P1 4x4 diagonal uses Case board geometry", taint_service.is_eligible_taint_target(four_by_four, 1, 2))
	var invalid_draft = DRAFT.new()
	invalid_draft.board_columns = 3
	invalid_draft.board_rows = 3
	invalid_draft.board_slot_count = 9
	invalid_draft.suspects.append(GENERATED_SUSPECT.create(1, 0, _role(roles, &"poisoner")))
	invalid_draft.suspects.append(GENERATED_SUSPECT.create(2, 8, _role(roles, &"tutorial_priest")))
	var fixed_rng := RandomNumberGenerator.new()
	fixed_rng.seed = 9
	_add(rows, "M6B-P1 generator rejects inert Poisoner draft", not generator._assign_poisoner_taint(invalid_draft, fixed_rng))
	var fixture: CaseDefinition = _fixture_case(0, 1, 4)
	var runtime: CaseRuntimeState = _tainted_runtime(fixture, 1, 2)
	var public_view: GeneratedPublicCaseView = _public_view(fixture, runtime, roles)
	var solved: CaseGeneratorSolverResult = SOLVER.new().solve(public_view, roles)
	_add(rows, "M6B-P1 public solver uniquely identifies Poisoner fixture", solved.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION and solved.unique_evil_suspect_ids == PackedInt32Array([1]))
	var no_hidden_target: bool = true
	for clue: GeneratedPublicClue in public_view.public_clues:
		no_hidden_target = no_hidden_target and clue.true_role_id == &"" and clue.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL
	_add(rows, "M6B-P1 solver input excludes hidden role and taint target", no_hidden_target and not public_view.has_meta(&"poisoner_taint_target_suspect_id"))
	var target_state: CaseMutationStateSnapshot = MUTATION_STATE.from_runtime(fixture, runtime, 2, roles)
	var source_state: CaseMutationStateSnapshot = MUTATION_STATE.from_runtime(fixture, runtime, 1, roles)
	var role_names: Dictionary = {}
	for role: RoleDefinition in roles:
		if role != null:
			role_names[role.role_id] = role.display_name
	_add(rows, "M6B-P1 audit shows Evil Poisoner and Good tainted liar", source_state != null and target_state != null and source_state.audit_line(role_names).contains("Evil") and target_state.audit_line(role_names).contains("tainted") and target_state.audit_line(role_names).contains("lying"))
	var audit = AUDIT.new()
	audit.role_names = role_names
	for suspect: SuspectDefinition in fixture.suspects:
		audit.hidden_suspects.append({
			"suspect_id": suspect.suspect_id,
			"true_role_id": suspect.true_role_id,
			"displayed_role_id": suspect.displayed_role_id,
			"behavior_role_id": suspect.displayed_role_id,
			"is_impersonating": suspect.is_impersonating,
			"role_group": suspect.role_group,
			"true_alignment": suspect.true_alignment,
			"truth_mode": RoleInformationEvaluationService.new().truth_mode_for_suspect_effective(fixture, runtime, suspect.suspect_id),
		})
	var audit_text: String = "\n".join(audit.display_lines(fixture, runtime, roles))
	_add(rows, "M6B-P1 Case Audit renders Poisoner and tainted target", audit_text.contains(String(role_names.get(&"poisoner", "poisoner"))) and audit_text.contains("tainted") and audit_text.contains("lying"))
	var accepted_candidate: CaseGenerationResult = CaseGenerationResult.new()
	accepted_candidate.status = CaseGenerationResult.STATUS_SUCCESS
	accepted_candidate.fingerprint = "poisoner_public_fixture"
	var truth_draft = DRAFT.new()
	truth_draft.hidden_evil_suspect_ids = PackedInt32Array([1])
	accepted_candidate.hidden_case_draft = truth_draft
	var evaluator: Callable = func(_attempt_request: CaseGenerationRequest, _attempt_index: int, _roles: Array[RoleDefinition]) -> Dictionary:
		return {"candidate": accepted_candidate, "public_view": public_view, "solver_result": solved}
	var accepted: CaseGenerationAcceptanceResult = ACCEPTANCE.new().accept_unique_candidate(request, roles, 1, evaluator)
	_add(rows, "M6B-P1 M3 accepts only unique ground-truth match", accepted.success and accepted.accepted_solver_result == solved and solved.ground_truth_checked and solved.unique_solution_matches_ground_truth)
	var red_herring_view: GeneratedPublicCaseView = PUBLIC_VIEW.create_manual(3, 3, 1, [
		PUBLIC_SUSPECT.create(1, 0, &"tutorial_priest", CaseEnums.RoleGroup.CHINH_NHAN),
		PUBLIC_SUSPECT.create(2, 1, &"reporter", CaseEnums.RoleGroup.CHINH_NHAN),
	])
	var red_herring_ids: Array[StringName] = [&"poisoner", &"tutorial_priest", &"reporter"]
	red_herring_view.suspected_role_ids = red_herring_ids
	var red_herring_solved: CaseGeneratorSolverResult = SOLVER.new().solve(red_herring_view, roles)
	var red_herring_poisoner_possible: bool = false
	for evil_set in red_herring_solved.candidate_evil_sets:
		if evil_set == PackedInt32Array([1]):
			red_herring_poisoner_possible = true
	_add(rows, "M6B-P1 solver keeps suspected-only Poisoner disguise worlds", red_herring_poisoner_possible)
	var still_unsupported: bool = true
	for unsupported_id: StringName in [&"drunkard"]:
		var unsupported_ids: Array[StringName] = [unsupported_id]
		public_view.suspected_role_ids = unsupported_ids
		still_unsupported = still_unsupported and SOLVER.new().solve(public_view, roles).status == CaseGeneratorSolverResult.STATUS_UNSUPPORTED
	_add(rows, "M6B-P1 top-level Drunkard remains unsupported", still_unsupported)
	return rows


func _fixture_case(source_slot: int, priest_slot: int, reporter_slot: int = -1) -> CaseDefinition:
	var definition := CaseDefinition.new()
	definition.case_id = &"poisoner_public_fixture"
	definition.set_meta(&"board_columns", 3)
	definition.set_meta(&"board_slot_count", 9)
	definition.suspected_role_ids = [&"poisoner", &"tutorial_priest", &"reporter"]
	definition.suspects.append(_suspect(1, source_slot, &"poisoner", &"reporter", CaseEnums.RoleGroup.TONG_PHAM))
	definition.suspects.append(_suspect(2, priest_slot, &"tutorial_priest", &"tutorial_priest", CaseEnums.RoleGroup.CHINH_NHAN))
	if reporter_slot >= 0:
		definition.suspects.append(_suspect(3, reporter_slot, &"reporter", &"reporter", CaseEnums.RoleGroup.CHINH_NHAN))
	definition.evil_suspect_ids = PackedInt32Array([1])
	return definition


func _suspect(id: int, slot: int, true_id: StringName, display_id: StringName, group: CaseEnums.RoleGroup) -> SuspectDefinition:
	var suspect := SuspectDefinition.new()
	suspect.suspect_id = id
	suspect.board_slot = slot
	suspect.true_role_id = true_id
	suspect.displayed_role_id = display_id
	suspect.role_group = group
	suspect.true_alignment = CaseRolePoolService.alignment_for_role_group(group)
	if true_id != display_id:
		suspect.impersonated_role_id = display_id
		suspect.is_impersonating = true
	return suspect


func _tainted_runtime(definition: CaseDefinition, source_id: int, target_id: int) -> CaseRuntimeState:
	if definition == null or source_id <= 0 or target_id <= 0:
		return null
	var runtime := CaseRuntimeState.new()
	var no_players: Array[PlayerCaseState] = []
	runtime.initialize(definition, no_players)
	var taint: PoisonerTaintRecord = PoisonerTaintService.new().resolve_taint(definition, runtime, source_id, target_id)
	return runtime if taint != null and taint.applied else null


func _public_view(definition: CaseDefinition, runtime: CaseRuntimeState, roles: Array[RoleDefinition]) -> GeneratedPublicCaseView:
	var public_suspects: Array = []
	var public_clues: Array = []
	var evaluator := RoleInformationEvaluationService.new()
	for suspect: SuspectDefinition in definition.suspects:
		public_suspects.append(PUBLIC_SUSPECT.create(suspect.suspect_id, suspect.board_slot, suspect.displayed_role_id, CaseEnums.RoleGroup.CHINH_NHAN))
		public_clues.append(PUBLIC_CLUE.from_information_result(evaluator.evaluate(definition, suspect.suspect_id, roles, {}, runtime)))
	var view: GeneratedPublicCaseView = PUBLIC_VIEW.create_manual(3, 3, 1, public_suspects, public_clues)
	view.allowed_role_ids = [&"poisoner", &"tutorial_priest", &"reporter"]
	view.suspected_role_ids = view.allowed_role_ids.duplicate()
	return view


func _role(roles: Array[RoleDefinition], id: StringName) -> RoleDefinition:
	for role: RoleDefinition in roles:
		if role != null and role.role_id == id:
			return role
	return null


func _slot_for(definition: CaseDefinition, id: int) -> int:
	if definition != null:
		for suspect: SuspectDefinition in definition.suspects:
			if suspect.suspect_id == id:
				return suspect.board_slot
	return -1


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({"name": name, "passed": passed, "detail": "M6B-P1 Poisoner procedural invariant"})
