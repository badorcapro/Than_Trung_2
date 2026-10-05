extends RefCounted

const GENERATOR := preload("res://scripts/domain/cases/CaseGenerator.gd")
const REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")
const DRAFT := preload("res://scripts/domain/cases/HiddenCaseDraft.gd")
const GENERATED_SUSPECT := preload("res://scripts/domain/cases/GeneratedSuspect.gd")
const PUBLIC_VIEW := preload("res://scripts/domain/cases/GeneratedPublicCaseView.gd")
const PUBLIC_SUSPECT := preload("res://scripts/domain/cases/GeneratedPublicSuspectView.gd")
const SOLVER := preload("res://scripts/domain/cases/CaseGeneratorPublicSolver.gd")
const MUTATION_STATE := preload("res://scripts/domain/cases/CaseMutationStateSnapshot.gd")
const AUDIT := preload("res://scripts/tools/CaseGenerationAuditSnapshot.gd")
const ACCEPTANCE := preload("res://scripts/domain/cases/CaseGenerationAcceptanceResult.gd")
const WAREHOUSE_ENTRY := preload("res://scripts/domain/cases/CaseSeedWarehouseEntry.gd")
const NEXT_CASE_SESSION := preload("res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd")


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var role_ids: Array[StringName] = [&"spectre", &"tutorial_priest", &"reporter", &"therapist"]
	var locations: Array[StringName] = [BoardLocationDefinition.LOCATION_CRIME_SCENE]
	var request: CaseGenerationRequest = REQUEST.create(346781, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY, role_ids, locations, 4)
	var generator = GENERATOR.new()
	var candidate: CaseGenerationResult = generator.generate(request, roles)
	var repeated: CaseGenerationResult = generator.generate(request, roles)
	var definition: CaseDefinition = generator.case_definition_from_result(candidate)
	var source: SuspectDefinition = _role_suspect(definition, &"spectre")
	var target: SuspectDefinition = _suspect(definition, source.obscure_target_suspect_id) if source != null else null
	var production_ids: Array[StringName] = NEXT_CASE_SESSION.new()._default_next_case_generation_request().allowed_role_ids
	_add(rows, "M6B-P3 Spectre joins production and generated candidates", production_ids.has(&"spectre") and candidate != null and candidate.is_success() and source != null)
	_add(rows, "M6B-P3 target and disguise are deterministic", candidate != null and repeated != null and candidate.is_success() and repeated.is_success() and candidate.fingerprint == repeated.fingerprint)
	_add(rows, "M6B-P3 target is an occupied suspect", source != null and target != null and definition.suspect_at_slot(target.board_slot) == target)
	_add(rows, "M6B-P3 target excludes current Meddler and board non-suspects", target != null and target.role_group != CaseEnums.RoleGroup.HIEU_SU and target.suspect_id != definition.startup_barkeep_target_suspect_id)
	var invalid_draft = DRAFT.new()
	invalid_draft.suspects.append(GENERATED_SUSPECT.create(1, 0, _role(roles, &"spectre")))
	invalid_draft.suspects.append(GENERATED_SUSPECT.create(2, 1, _role(roles, &"copycat")))
	var invalid_rng := RandomNumberGenerator.new()
	invalid_rng.seed = 7
	var self_target_assigned: bool = generator._assign_spectre_obscure(invalid_draft, invalid_rng)
	_add(
		rows,
		"M6B-P3 self-obscure is legal across generator validator solver",
		self_target_assigned
			and invalid_draft.spectre_source_suspect_id == 1
			and invalid_draft.spectre_obscure_target_suspect_id == 1
			and _self_obscure_validator_and_solver(candidate, definition, roles, source)
	)
	var runtime := CaseRuntimeState.new()
	var no_players: Array[PlayerCaseState] = []
	if definition != null:
		runtime.initialize(definition, no_players)
	var target_state: CaseMutationStateSnapshot = MUTATION_STATE.from_runtime(definition, runtime, target.suspect_id, roles) if target != null else null
	_add(rows, "M6B-P3 obscure preserves target true and current role", target_state != null and target_state.is_obscured and target_state.original_role_id == target.true_role_id and target_state.current_role_id == target.true_role_id)
	_add(rows, "M6B-P3 obscure preserves target group and alignment", target_state != null and target_state.current_role_group == target.role_group and target_state.current_alignment == target.true_alignment)
	var evaluator := RoleInformationEvaluationService.new()
	var target_base: InvestigationInformationResult = evaluator.evaluate(definition, target.suspect_id, roles, {}, runtime) if target != null else null
	var relation := InvestigationObscureRelation.new()
	if source != null and target != null:
		relation.configure(source.suspect_id, target.suspect_id)
	var target_obscured: InvestigationInformationResult = evaluator.apply_obscure_relation(target_base, definition, relation, runtime) if target_base != null else null
	_add(rows, "M6B-P3 obscure preserves clue authority while hiding letters", target_base != null and target_obscured != null and target_obscured.behavior_role_id == target_base.behavior_role_id and target_obscured.truth_mode == target_base.truth_mode and not target_obscured.text_information_visible and target_obscured.numeric_information_visible)
	var public_view: GeneratedPublicCaseView = PUBLIC_VIEW.from_generation_result(candidate, roles) if candidate != null and candidate.is_success() else null
	var public_target: GeneratedPublicSuspectView = _public_suspect(public_view, target.suspect_id) if target != null else null
	var target_clue: GeneratedPublicClue = _public_clue(public_view, target.suspect_id) if target != null else null
	_add(rows, "M6B-P3 public projection masks target role and group", public_target != null and public_target.role_identity_obscured and public_target.public_role_id == &"" and public_target.public_role_group == -1)
	var target_runtime: SuspectRuntimeState = runtime.find_suspect(target.suspect_id) if runtime != null and target != null else null
	if target_runtime != null:
		target_runtime.is_investigated = true
	var presentation_target: SuspectPublicViewData = _presentation_view(definition, runtime, roles, target.suspect_id) if target != null else null
	var expected_masked_text: String = CasePublicPresentationBuilder.new()._mask_public_information(
		target_base.public_text() if target_base != null else ""
	)
	_add(rows, "M6B-P3 presentation masks letters but preserves structured clue", target_clue != null and target_base != null and target_clue.displayed_role_id == &"" and target_clue.behavior_role_id == target_base.behavior_role_id and target_clue.text == target_base.public_text() and presentation_target != null and presentation_target.public_role_obscured and presentation_target.public_information_obscured and presentation_target.public_investigation_statement == expected_masked_text)
	var source_info: InvestigationInformationResult = evaluator.evaluate(definition, source.suspect_id, roles, {}, runtime) if source != null else null
	_add(rows, "M6B-P3 Spectre uses displayed behavior while lying", source != null and source.is_impersonating and source_info != null and source_info.behavior_role_id == source.displayed_role_id and source_info.truth_mode == InvestigationInformationResult.TruthMode.LYING)
	var solved: CaseGeneratorSolverResult = SOLVER.new().solve(public_view, roles) if public_view != null else null
	_add(rows, "M6B-P3 solver supports public Spectre world and retains truth", solved != null and not solved.unsupported and _contains_evil_set(solved, candidate.hidden_case_draft.hidden_evil_suspect_ids))
	var original_solver_fingerprint: String = solved.fingerprint_text() if solved != null else ""
	var generated_source_id: int = candidate.hidden_case_draft.spectre_source_suspect_id if candidate != null and candidate.hidden_case_draft != null else 0
	var generated_target_id: int = candidate.hidden_case_draft.spectre_obscure_target_suspect_id if candidate != null and candidate.hidden_case_draft != null else 0
	if candidate != null and candidate.hidden_case_draft != null:
		candidate.hidden_case_draft.spectre_source_suspect_id = 99
		candidate.hidden_case_draft.spectre_obscure_target_suspect_id = 98
	var solved_without_hidden_target: CaseGeneratorSolverResult = SOLVER.new().solve(public_view, roles) if public_view != null else null
	_add(rows, "M6B-P3 solver reads public obscure state instead of hidden target", solved_without_hidden_target != null and solved_without_hidden_target.fingerprint_text() == original_solver_fingerprint)
	if candidate != null and candidate.hidden_case_draft != null:
		candidate.hidden_case_draft.spectre_source_suspect_id = generated_source_id
		candidate.hidden_case_draft.spectre_obscure_target_suspect_id = generated_target_id
	var acceptance: CaseGenerationAcceptanceResult = ACCEPTANCE.new()
	acceptance.root_seed = request.seed
	acceptance.mark_success(candidate, solved, 0, candidate.seed_used if candidate != null else -1, public_view)
	var entry: CaseSeedWarehouseEntry = WAREHOUSE_ENTRY.from_acceptance(request, acceptance)
	var audit = AUDIT.new()
	var audit_captured: bool = audit.capture(entry, acceptance, roles)
	var audit_text: String = "\n".join(audit.display_lines(definition, runtime, roles)) if audit_captured else ""
	var reveal_ok: bool = _full_reveal_retains_obscure(definition, runtime, roles, source, target)
	var obscure_target_audit: String = "-> che #%d" % target.suspect_id if target != null else ""
	var obscured_by_audit: String = "-> obscured by #%d" % source.suspect_id if source != null else ""
	_add(rows, "M6B-P3 audit capture and Full Reveal retain obscure truth", audit_captured and target != null and source != null and audit_text.contains(obscure_target_audit) and audit_text.contains(obscured_by_audit) and reveal_ok)
	return rows


func _full_reveal_retains_obscure(
	definition: CaseDefinition, runtime: CaseRuntimeState, roles: Array[RoleDefinition],
	source: SuspectDefinition, target: SuspectDefinition
) -> bool:
	if definition == null or runtime == null or source == null or target == null:
		return false
	runtime.is_settled = true
	runtime.settlement_result = CaseSettlementResult.new()
	var reveal: CaseTruthReveal = CaseTruthRevealBuilder.new().build(definition, runtime, roles)
	if reveal == null:
		return false
	var source_ok: bool = false
	var target_ok: bool = false
	for truth: SuspectTruthReveal in reveal.suspect_truths:
		if truth.suspect_id == source.suspect_id:
			source_ok = truth.current_role_id == &"spectre" and truth.obscure_target_suspect_id == target.suspect_id
		elif truth.suspect_id == target.suspect_id:
			target_ok = truth.current_role_id == target.true_role_id
	return source_ok and target_ok


func _self_obscure_validator_and_solver(
	candidate: CaseGenerationResult,
	definition: CaseDefinition,
	roles: Array[RoleDefinition],
	source: SuspectDefinition
) -> bool:
	if candidate == null or candidate.hidden_case_draft == null or definition == null or source == null:
		return false
	var self_definition: CaseDefinition = definition.duplicate(true) as CaseDefinition
	var self_source: SuspectDefinition = _role_suspect(self_definition, &"spectre")
	if self_source == null:
		return false
	self_source.obscure_target_suspect_id = self_source.suspect_id
	var no_players: Array[PlayerCaseState] = []
	var validation: Dictionary = CaseDefinitionValidator.new().validate(self_definition, roles, no_players)
	var self_runtime: CaseRuntimeState = CaseRuntimeState.new()
	self_runtime.initialize(self_definition, no_players)
	var self_state: CaseMutationStateSnapshot = MUTATION_STATE.from_runtime(
		self_definition, self_runtime, self_source.suspect_id, roles
	)
	var original_target_id: int = candidate.hidden_case_draft.spectre_obscure_target_suspect_id
	candidate.hidden_case_draft.spectre_obscure_target_suspect_id = source.suspect_id
	var self_public_view: GeneratedPublicCaseView = PUBLIC_VIEW.from_generation_result(candidate, roles)
	var role_by_id: Dictionary = {}
	for role: RoleDefinition in roles:
		if role != null:
			role_by_id[role.role_id] = role
	var assigned: Dictionary = {}
	for generated_suspect: GeneratedSuspect in candidate.hidden_case_draft.suspects:
		if generated_suspect != null:
			assigned[generated_suspect.suspect_id] = generated_suspect.true_role_id
	var solver_accepts_self: bool = SOLVER.new()._spectre_hypothesis_is_valid(
		self_public_view,
		role_by_id,
		assigned,
		candidate.hidden_case_draft.barkeep_transform_target_suspect_id
	)
	candidate.hidden_case_draft.spectre_obscure_target_suspect_id = original_target_id
	return (
		bool(validation.get("passed", false))
		and self_state != null
		and self_state.is_obscured
		and not self_state.role_identity_visible
		and solver_accepts_self
	)


func _role_suspect(definition: CaseDefinition, role_id: StringName) -> SuspectDefinition:
	if definition == null:
		return null
	for suspect: SuspectDefinition in definition.suspects:
		if suspect != null and suspect.true_role_id == role_id:
			return suspect
	return null


func _suspect(definition: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	if definition == null:
		return null
	for suspect: SuspectDefinition in definition.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null


func _public_suspect(view: GeneratedPublicCaseView, suspect_id: int) -> GeneratedPublicSuspectView:
	if view == null:
		return null
	for suspect: GeneratedPublicSuspectView in view.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null


func _public_clue(view: GeneratedPublicCaseView, suspect_id: int) -> GeneratedPublicClue:
	if view == null:
		return null
	for clue: GeneratedPublicClue in view.public_clues:
		if clue != null and clue.suspect_id == suspect_id:
			return clue
	return null


func _presentation_view(
	definition: CaseDefinition, runtime: CaseRuntimeState, roles: Array[RoleDefinition], suspect_id: int
) -> SuspectPublicViewData:
	if definition == null or runtime == null:
		return null
	for view: SuspectPublicViewData in CasePublicPresentationBuilder.new().build_suspect_views(definition, runtime, roles):
		if view != null and view.suspect_id == suspect_id:
			return view
	return null


func _contains_evil_set(result: CaseGeneratorSolverResult, expected: PackedInt32Array) -> bool:
	if result == null:
		return false
	var sorted_expected: PackedInt32Array = expected.duplicate()
	sorted_expected.sort()
	for evil_set: PackedInt32Array in result.candidate_evil_sets:
		if evil_set == sorted_expected:
			return true
	return false


func _role(roles: Array[RoleDefinition], role_id: StringName) -> RoleDefinition:
	for role: RoleDefinition in roles:
		if role != null and role.role_id == role_id:
			return role
	return null


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({"name": name, "passed": passed, "detail": "M6B-P3 Spectre/obscure procedural invariant"})
