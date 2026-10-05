extends RefCounted

const GENERATOR := preload("res://scripts/domain/cases/CaseGenerator.gd")
const REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")
const DRAFT := preload("res://scripts/domain/cases/HiddenCaseDraft.gd")
const GENERATED_SUSPECT := preload("res://scripts/domain/cases/GeneratedSuspect.gd")
const PUBLIC_VIEW := preload("res://scripts/domain/cases/GeneratedPublicCaseView.gd")
const PUBLIC_SUSPECT := preload("res://scripts/domain/cases/GeneratedPublicSuspectView.gd")
const PUBLIC_CLUE := preload("res://scripts/domain/cases/GeneratedPublicClue.gd")
const SOLVER := preload("res://scripts/domain/cases/CaseGeneratorPublicSolver.gd")
const ACCEPTANCE := preload("res://scripts/domain/cases/CaseGenerationAcceptanceService.gd")
const MUTATION_STATE := preload("res://scripts/domain/cases/CaseMutationStateSnapshot.gd")
const AUDIT := preload("res://scripts/tools/CaseGenerationAuditSnapshot.gd")
const NEXT_CASE_SESSION := preload("res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd")


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var production_ids: Array[StringName] = NEXT_CASE_SESSION.new()._default_next_case_generation_request().allowed_role_ids
	_add(rows, "M6B-P2 Barkeep remains in production without top-level Drunkard",
		production_ids.has(&"barkeep") and production_ids.has(&"poisoner")
		and not production_ids.has(&"drunkard"))
	var role_ids: Array[StringName] = [&"barkeep", &"tutorial_priest", &"reporter", &"therapist"]
	var locations: Array[StringName] = [BoardLocationDefinition.LOCATION_CRIME_SCENE]
	var request: CaseGenerationRequest = REQUEST.create(112233, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY, role_ids, locations, 4)
	var generator = GENERATOR.new()
	var candidate: CaseGenerationResult = generator.generate(request, roles)
	var repeated: CaseGenerationResult = generator.generate(request, roles)
	var definition: CaseDefinition = generator.case_definition_from_result(candidate)
	var source_id: int = definition.startup_barkeep_source_suspect_id if definition != null else 0
	var target_id: int = definition.startup_barkeep_target_suspect_id if definition != null else 0
	var target: SuspectDefinition = _suspect_for(definition, target_id)
	_add(rows, "M6B-P2 generator assigns exactly one occupied Innocent target",
		source_id > 0 and target != null and target_id != source_id
		and target.role_group == CaseEnums.RoleGroup.CHINH_NHAN)
	_add(rows, "M6B-P2 target and displayed role are deterministic",
		candidate != null and repeated != null and target != null
		and candidate.is_success() and repeated.is_success()
		and candidate.fingerprint == repeated.fingerprint
		and candidate.hidden_case_draft.barkeep_transform_target_suspect_id == repeated.hidden_case_draft.barkeep_transform_target_suspect_id
		and _suspect_for(generator.case_definition_from_result(repeated), target_id).displayed_role_id == target.displayed_role_id)
	var runtime: CaseRuntimeState = _transformed_runtime(definition, source_id, target_id, roles)
	var target_state: CaseMutationStateSnapshot = MUTATION_STATE.from_runtime(definition, runtime, target_id, roles) if runtime != null else null
	_add(rows, "M6B-P2 transform retains original and makes current Drunkard Meddler",
		target_state != null and target != null and runtime.barkeep_transformation_records.size() == 1
		and target_state.original_role_id == target.true_role_id
		and target_state.current_role_id == &"drunkard"
		and target_state.current_role_group == CaseEnums.RoleGroup.HIEU_SU)
	_add(rows, "M6B-P2 transformed target is not an impersonator",
		target_state != null and not target_state.is_impersonating
		and target != null and not target.is_impersonating and target.impersonated_role_id == &"")
	_add(rows, "M6B-P2 displayed Good role is distinct and not currently in play",
		target_state != null and target_state.displayed_role_id != target_state.current_role_id
		and BarkeepTransformationService.new().drunkard_pretend_role_is_valid(
			definition, runtime, roles, CaseRolePoolService.suspected_role_candidates(definition), target_state.displayed_role_id))
	_add(rows, "M6B-P2 displayed role drives a lying clue",
		target_state != null and target_state.behavior_role_id == target_state.displayed_role_id
		and target_state.truth_mode == InvestigationInformationResult.TruthMode.LYING)
	var audit = AUDIT.new()
	var audit_text: String = ""
	if definition != null and runtime != null:
		for suspect: SuspectDefinition in definition.suspects:
			audit.hidden_suspects.append({
				"suspect_id": suspect.suspect_id,
				"true_role_id": suspect.true_role_id,
				"displayed_role_id": suspect.displayed_role_id,
				"behavior_role_id": suspect.displayed_role_id,
				"is_impersonating": suspect.is_impersonating,
				"role_group": suspect.role_group,
				"true_alignment": suspect.true_alignment,
				"truth_mode": RoleInformationEvaluationService.new().truth_mode_for_suspect_effective(definition, runtime, suspect.suspect_id),
			})
		audit_text = "\n".join(audit.display_lines(definition, runtime, roles))
	_add(rows, "M6B-P2 dev audit names target and separates mutation identities",
		audit_text.contains("Transform target: #%d" % target_id)
		and audit_text.contains("original:") and audit_text.contains("current:")
		and audit_text.contains("hành vi:") and audit_text.contains("lying"))
	var public_target: GeneratedPublicSuspectView = PUBLIC_SUSPECT.from_mutation_state(target_state, target.board_slot) if target_state != null else null
	var generated_view: GeneratedPublicCaseView = PUBLIC_VIEW.from_generation_result(candidate, roles) if candidate != null and candidate.is_success() else null
	var generated_public_target: GeneratedPublicSuspectView = null
	if generated_view != null:
		for public_suspect: GeneratedPublicSuspectView in generated_view.suspects:
			if public_suspect.suspect_id == target_id:
				generated_public_target = public_suspect
				break
	_add(rows, "M6B-P2 public role and group do not reveal Drunkard",
		public_target != null and public_target.public_role_id == target_state.displayed_role_id
		and public_target.public_role_group == CaseEnums.RoleGroup.CHINH_NHAN
		and generated_public_target != null and generated_public_target.public_role_id == public_target.public_role_id
		and generated_public_target.public_role_group == public_target.public_role_group)
	var generated_clue: GeneratedPublicClue = _clue_for(generated_view, target_id)
	var generated_hidden_clue: GeneratedPublicClue = null
	if candidate != null and candidate.hidden_case_draft != null:
		for clue: GeneratedPublicClue in candidate.hidden_case_draft.public_clues:
			if clue != null and clue.suspect_id == target_id:
				generated_hidden_clue = clue
				break
	var replayed: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(definition, target_id, roles, {}, runtime) if runtime != null else null
	print("DRUNKARD_REGRESSION_DIAG seed=112233 target=%d original=%s current=%s displayed=%s behavior=%s hidden_truth_mode=%s public_truth_mode=%s generated_text=%s replayed_text=%s" % [
		target_id,
		String(target.true_role_id) if target != null else "null",
		String(target_state.current_role_id) if target_state != null else "null",
		String(target.displayed_role_id) if target != null else "null",
		String(generated_hidden_clue.behavior_role_id) if generated_hidden_clue != null else "null",
		str(generated_hidden_clue.truth_mode) if generated_hidden_clue != null else "null",
		str(generated_clue.truth_mode) if generated_clue != null else "null",
		generated_clue.text if generated_clue != null else "null",
		replayed.public_text() if replayed != null else "null",
	])
	_add(rows, "M6B-P2 generated Drunkard clue replays from behavior source",
		generated_clue != null and generated_hidden_clue != null and replayed != null and target != null
		and generated_clue.behavior_role_id == target.displayed_role_id
		and generated_hidden_clue.truth_mode == InvestigationInformationResult.TruthMode.LYING
		and generated_hidden_clue.behavior_role_id == generated_clue.behavior_role_id
		and generated_clue.payload_kind == replayed.payload_kind
		and generated_clue.text == replayed.public_text())
	var validation: Dictionary = CaseDefinitionValidator.new().validate(definition, roles, FixtureRepository.load_players()) if definition != null else {}
	_add(rows, "M6B-P2 generated Case validates and nests Drunkard under Barkeep",
		bool(validation.get("passed", false)) and definition != null
		and not definition.suspected_role_ids.has(&"drunkard")
		and CaseRolePoolService.nested_role_reference_ids_for_case(definition, &"barkeep").has(&"drunkard"))
	var invalid_draft = DRAFT.new()
	invalid_draft.suspects.append(GENERATED_SUSPECT.create(1, 0, _role(roles, &"barkeep")))
	invalid_draft.suspects.append(GENERATED_SUSPECT.create(2, 1, _role(roles, &"copycat")))
	var fixed_rng := RandomNumberGenerator.new()
	fixed_rng.seed = 9
	_add(rows, "M6B-P2 draft without Innocent cannot transform",
		not generator._assign_barkeep_transform(invalid_draft, role_ids, roles, fixed_rng))
	var fixture: CaseDefinition = _public_fixture()
	var fixture_runtime: CaseRuntimeState = _transformed_runtime(fixture, 1, 2, roles)
	var fixture_view: GeneratedPublicCaseView = _public_view(fixture, fixture_runtime, roles)
	var solved: CaseGeneratorSolverResult = SOLVER.new().solve(fixture_view, roles)
	_add(rows, "M6B-P2 solver uniquely resolves a public Barkeep world",
		solved.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION
		and solved.unique_evil_suspect_ids == PackedInt32Array([1]))
	fixture.startup_barkeep_source_suspect_id = 0
	fixture.startup_barkeep_target_suspect_id = 0
	fixture.suspects[1].displayed_role_id = &"reporter"
	var solved_again: CaseGeneratorSolverResult = SOLVER.new().solve(fixture_view, roles)
	_add(rows, "M6B-P2 solver does not read hidden transform target or fake choice",
		solved_again.status == solved.status
		and solved_again.unique_evil_suspect_ids == solved.unique_evil_suspect_ids
		and not fixture_view.has_meta(&"barkeep_transform_target_suspect_id"))
	var accepted_candidate := CaseGenerationResult.new()
	accepted_candidate.status = CaseGenerationResult.STATUS_SUCCESS
	accepted_candidate.fingerprint = "barkeep_public_fixture"
	var truth_draft = DRAFT.new()
	truth_draft.hidden_evil_suspect_ids = PackedInt32Array([1])
	accepted_candidate.hidden_case_draft = truth_draft
	var evaluator: Callable = func(_attempt_request: CaseGenerationRequest, _attempt_index: int, _roles: Array[RoleDefinition]) -> Dictionary:
		return {"candidate": accepted_candidate, "public_view": fixture_view, "solver_result": solved}
	var accepted: CaseGenerationAcceptanceResult = ACCEPTANCE.new().accept_unique_candidate(request, roles, 1, evaluator)
	_add(rows, "M6B-P2 M3 accepts only the matched unique Evil set",
		accepted.success and solved.ground_truth_checked and solved.unique_solution_matches_ground_truth)
	var reveal_case: CaseDefinition = _public_fixture()
	var revealed_runtime: CaseRuntimeState = _transformed_runtime(reveal_case, 1, 2, roles)
	var revealed: bool = false
	if revealed_runtime != null:
		revealed_runtime.is_settled = true
		revealed_runtime.settlement_result = CaseSettlementResult.new()
		var truth: CaseTruthReveal = CaseTruthRevealBuilder.new().build(reveal_case, revealed_runtime, roles)
		if truth != null:
			for item: SuspectTruthReveal in truth.suspect_truths:
				if item.suspect_id == 2:
					revealed = item.current_role_id == &"drunkard" and item.role_group_label == "Kẻ Bao Đồng"
	_add(rows, "M6B-P2 Full Reveal shows current Drunkard and Meddler group", revealed)
	var unsupported_role_ids: Array[StringName] = [&"drunkard"]
	fixture_view.allowed_role_ids = unsupported_role_ids
	fixture_view.suspected_role_ids = unsupported_role_ids
	var unsupported_drunkard: CaseGeneratorSolverResult = SOLVER.new().solve(fixture_view, roles)
	_add(rows, "M6B-P2 standalone Drunkard role pools remain unsupported", unsupported_drunkard != null and unsupported_drunkard.unsupported)
	return rows


func _public_fixture() -> CaseDefinition:
	var definition := CaseDefinition.new()
	definition.case_id = &"barkeep_public_fixture"
	definition.set_meta(&"board_columns", 3)
	definition.set_meta(&"board_slot_count", 9)
	definition.suspected_role_ids = [&"barkeep", &"tutorial_priest", &"reporter", &"therapist"]
	definition.nested_suspect_list_role_ids_by_parent = {&"barkeep": [&"drunkard"]}
	definition.startup_barkeep_source_suspect_id = 1
	definition.startup_barkeep_target_suspect_id = 2
	definition.suspects.append(_suspect(1, 0, &"barkeep", &"reporter", CaseEnums.RoleGroup.TONG_PHAM, true))
	definition.suspects.append(_suspect(2, 1, &"tutorial_priest", &"tutorial_priest", CaseEnums.RoleGroup.CHINH_NHAN, false))
	definition.suspects.append(_suspect(3, 8, &"reporter", &"reporter", CaseEnums.RoleGroup.CHINH_NHAN, false))
	definition.suspects.append(_suspect(4, 3, &"therapist", &"therapist", CaseEnums.RoleGroup.CHINH_NHAN, false))
	definition.evil_suspect_ids = PackedInt32Array([1])
	return definition


func _suspect(id: int, slot: int, true_id: StringName, display_id: StringName, group: int, impersonating: bool) -> SuspectDefinition:
	var suspect := SuspectDefinition.new()
	suspect.suspect_id = id
	suspect.board_slot = slot
	suspect.true_role_id = true_id
	suspect.displayed_role_id = display_id
	suspect.role_group = group
	suspect.true_alignment = CaseRolePoolService.alignment_for_role_group(group)
	suspect.is_impersonating = impersonating
	if impersonating:
		suspect.impersonated_role_id = display_id
	return suspect


func _transformed_runtime(definition: CaseDefinition, source_id: int, target_id: int, roles: Array[RoleDefinition]) -> CaseRuntimeState:
	if definition == null or source_id <= 0 or target_id <= 0:
		return null
	var runtime := CaseRuntimeState.new()
	var no_players: Array[PlayerCaseState] = []
	runtime.initialize(definition, no_players)
	var transform: BarkeepTransformationRecord = BarkeepTransformationService.new().resolve_transformation(definition, runtime, source_id, target_id, roles)
	return runtime if transform != null and transform.applied else null


func _public_view(definition: CaseDefinition, runtime: CaseRuntimeState, roles: Array[RoleDefinition]) -> GeneratedPublicCaseView:
	var public_suspects: Array = []
	var clues: Array = []
	var evaluator := RoleInformationEvaluationService.new()
	for suspect: SuspectDefinition in definition.suspects:
		var role: RoleDefinition = _role(roles, suspect.displayed_role_id)
		public_suspects.append(PUBLIC_SUSPECT.create(suspect.suspect_id, suspect.board_slot, suspect.displayed_role_id, role.role_group))
		clues.append(PUBLIC_CLUE.from_information_result(evaluator.evaluate(definition, suspect.suspect_id, roles, {}, runtime)))
	var view: GeneratedPublicCaseView = PUBLIC_VIEW.create_manual(3, 3, 1, public_suspects, clues)
	view.suspected_role_ids = definition.suspected_role_ids.duplicate()
	view.allowed_role_ids = view.suspected_role_ids.duplicate()
	return view


func _suspect_for(definition: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	if definition != null:
		for suspect: SuspectDefinition in definition.suspects:
			if suspect.suspect_id == suspect_id:
				return suspect
	return null


func _clue_for(view: GeneratedPublicCaseView, suspect_id: int) -> GeneratedPublicClue:
	if view != null:
		for clue: GeneratedPublicClue in view.public_clues:
			if clue.suspect_id == suspect_id:
				return clue
	return null


func _role(roles: Array[RoleDefinition], role_id: StringName) -> RoleDefinition:
	for role: RoleDefinition in roles:
		if role != null and role.role_id == role_id:
			return role
	return null


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({"name": name, "passed": passed, "detail": "M6B-P2 Barkeep/Drunkard procedural invariant"})
