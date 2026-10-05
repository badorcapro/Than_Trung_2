extends RefCounted

const MUTATION_STATE := preload("res://scripts/domain/cases/CaseMutationStateSnapshot.gd")
const PUBLIC_SUSPECT := preload("res://scripts/domain/cases/GeneratedPublicSuspectView.gd")
const PUBLIC_VIEW := preload("res://scripts/domain/cases/GeneratedPublicCaseView.gd")
const SOLVER := preload("res://scripts/domain/cases/CaseGeneratorPublicSolver.gd")
const AUDIT := preload("res://scripts/tools/CaseGenerationAuditSnapshot.gd")
const NEXT_CASE_SESSION := preload("res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd")


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var tutorial_six: CaseDefinition = FixtureRepository.load_tutorial_case_006()
	var no_players: Array[PlayerCaseState] = []
	var runtime_six := CaseRuntimeState.new()
	runtime_six.initialize(tutorial_six, no_players)
	var taint: PoisonerTaintRecord = PoisonerTaintService.new().resolve_taint(tutorial_six, runtime_six, 1, 2)
	var transform: BarkeepTransformationRecord = BarkeepTransformationService.new().resolve_transformation(tutorial_six, runtime_six, 3, 6, roles)
	var priest: CaseMutationStateSnapshot = MUTATION_STATE.from_runtime(tutorial_six, runtime_six, 2, roles)
	var drunkard: CaseMutationStateSnapshot = MUTATION_STATE.from_runtime(tutorial_six, runtime_six, 6, roles)
	_add(rows, "M6B taint applies without changing current role", taint != null and taint.applied and priest != null and priest.original_role_id == &"tutorial_priest" and priest.current_role_id == &"tutorial_priest")
	_add(rows, "M6B tainted Priest remains Innocent Good", priest != null and priest.current_role_group == CaseEnums.RoleGroup.CHINH_NHAN and priest.current_alignment == CaseEnums.Alignment.GOOD)
	_add(rows, "M6B taint changes truthfulness independently", priest != null and priest.is_tainted and priest.truth_mode == InvestigationInformationResult.TruthMode.LYING)
	var priest_public: GeneratedPublicSuspectView = PUBLIC_SUSPECT.from_mutation_state(priest, 1)
	var priest_view: GeneratedPublicCaseView = PUBLIC_VIEW.create_manual(3, 3, 0, [priest_public])
	var priest_solver: CaseGeneratorSolverResult = SOLVER.new().solve(priest_view, roles)
	_add(rows, "M6B public solver does not equate Good liar with Evil", priest_public != null and priest_public.public_role_id == &"tutorial_priest" and priest_public.public_role_group == CaseEnums.RoleGroup.CHINH_NHAN and priest_solver.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION and priest_solver.unique_evil_suspect_ids.is_empty())
	var mutation_roles: Array[StringName] = [&"spectre"]
	priest_view.allowed_role_ids = mutation_roles
	var mutation_solver: CaseGeneratorSolverResult = SOLVER.new().solve(priest_view, roles)
	_add(rows, "M6B solver accepts modeled Spectre pool", mutation_solver.status != CaseGeneratorSolverResult.STATUS_UNSUPPORTED)
	var conman := SuspectDefinition.new()
	conman.true_role_id = &"conman"
	conman.displayed_role_id = &"reporter"
	conman.true_alignment = CaseEnums.Alignment.EVIL
	_add(rows, "M6B Evil does not imply lying", RoleInformationEvaluationService.new().truth_mode_for_suspect(conman) == InvestigationInformationResult.TruthMode.TRUTHFUL)
	_add(rows, "M6B transform retains original and current separately", transform != null and transform.applied and drunkard != null and drunkard.original_role_id == &"mailman" and drunkard.current_role_id == &"drunkard")
	_add(rows, "M6B transformed Drunkard uses current Meddler group", drunkard != null and drunkard.current_role_group == CaseEnums.RoleGroup.HIEU_SU and drunkard.current_alignment == CaseEnums.Alignment.GOOD)
	_add(rows, "M6B Drunkard behavior source remains separate", drunkard != null and drunkard.behavior_role_id == &"mailman" and drunkard.truth_mode == InvestigationInformationResult.TruthMode.LYING)
	_add(rows, "M6B transform is not pretend", drunkard != null and not drunkard.is_impersonating and drunkard.displayed_role_id == &"mailman" and drunkard.public_role_id() == &"mailman")
	var drunkard_public: GeneratedPublicSuspectView = PUBLIC_SUSPECT.from_mutation_state(drunkard, 7)
	_add(rows, "M6B transformed public group follows display not current truth", drunkard_public != null and drunkard_public.public_role_group == CaseEnums.RoleGroup.CHINH_NHAN and drunkard_public.public_role_id == &"mailman")
	var tutorial_three: CaseDefinition = FixtureRepository.load_tutorial_case_003()
	var runtime_three := CaseRuntimeState.new()
	runtime_three.initialize(tutorial_three, no_players)
	var obscured: CaseMutationStateSnapshot = MUTATION_STATE.from_runtime(tutorial_three, runtime_three, 3, roles)
	var pretender: CaseMutationStateSnapshot = MUTATION_STATE.from_runtime(tutorial_three, runtime_three, 4, roles)
	_add(rows, "M6B obscure preserves Priest true and current role", obscured != null and obscured.original_role_id == &"tutorial_priest" and obscured.current_role_id == &"tutorial_priest" and obscured.is_obscured)
	var obscured_public: GeneratedPublicSuspectView = PUBLIC_SUSPECT.from_mutation_state(obscured, 3)
	_add(rows, "M6B obscure hides public role and group", obscured_public != null and obscured_public.role_identity_obscured and obscured_public.public_role_id == &"" and obscured_public.public_role_group == -1)
	_add(rows, "M6B obscure and pretend remain distinct", obscured != null and not obscured.is_impersonating and pretender != null and pretender.is_impersonating and not pretender.is_obscured)
	runtime_three.find_suspect(3).is_investigated = true
	var before_reveal: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(tutorial_three, runtime_three, roles)
	var public_masked: bool = false
	for view: SuspectPublicViewData in before_reveal:
		if view.suspect_id == 3:
			public_masked = (
				view.public_role_obscured
				and view.public_role_name == "?????"
				and view.public_role_group == -1
				and view.public_information_obscured
				and view.public_investigation_statement == "■■■ ■■ ■■ ■■."
			)
	_add(rows, "M6B existing public presentation masks obscured identity and letters", public_masked)
	runtime_three.is_settled = true
	runtime_three.settlement_result = CaseSettlementResult.new()
	var reveal: CaseTruthReveal = CaseTruthRevealBuilder.new().build(tutorial_three, runtime_three, roles)
	var truth_restored: bool = false
	if reveal != null:
		for truth: SuspectTruthReveal in reveal.suspect_truths:
			if truth.suspect_id == 3:
				truth_restored = truth.current_role_id == &"tutorial_priest" and truth.original_true_role_name == truth.current_role_name
	_add(rows, "M6B Full Reveal retains obscured true role", truth_restored)
	runtime_six.is_settled = true
	runtime_six.settlement_result = CaseSettlementResult.new()
	var transformed_reveal: CaseTruthReveal = CaseTruthRevealBuilder.new().build(tutorial_six, runtime_six, roles)
	var transformed_truth_restored: bool = false
	if transformed_reveal != null:
		for truth: SuspectTruthReveal in transformed_reveal.suspect_truths:
			if truth.suspect_id == 6:
				transformed_truth_restored = truth.current_role_id == &"drunkard" and truth.original_true_role_name != truth.current_role_name and truth.role_group_label == "Kẻ Bao Đồng"
	_add(rows, "M6B Full Reveal distinguishes original and transformed role", transformed_truth_restored)
	var obscure_view: GeneratedPublicCaseView = PUBLIC_VIEW.create_manual(3, 3, 1, [obscured_public])
	var obscure_solver: CaseGeneratorSolverResult = SOLVER.new().solve(obscure_view, roles)
	_add(rows, "M6B obscured identity without public clue behavior stays unsupported", obscure_solver.status == CaseGeneratorSolverResult.STATUS_UNSUPPORTED)
	var role_names: Dictionary = {}
	for role: RoleDefinition in roles:
		if role != null:
			role_names[role.role_id] = role.display_name
	var audit = AUDIT.new()
	audit.role_names = role_names
	audit.hidden_suspects.append({"suspect_id": 2})
	audit.hidden_suspects.append({"suspect_id": 6})
	var audit_text: String = "\n".join(audit.display_lines(tutorial_six, runtime_six, roles))
	_add(rows, "M6B audit distinguishes taint and transform concisely", audit_text.contains("tainted") and audit_text.contains("original:") and audit_text.contains("current:") and audit_text.contains("hành vi:"))
	var production_roles: Array[StringName] = NEXT_CASE_SESSION.new()._default_next_case_generation_request().allowed_role_ids
	_add(rows, "M6B Spectre joins production while top-level Drunkard stays outside", production_roles.has(&"poisoner") and production_roles.has(&"barkeep") and production_roles.has(&"spectre") and not production_roles.has(&"drunkard"))
	return rows


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({"name": name, "passed": passed, "detail": "M6B mutation-state foundation invariant"})
