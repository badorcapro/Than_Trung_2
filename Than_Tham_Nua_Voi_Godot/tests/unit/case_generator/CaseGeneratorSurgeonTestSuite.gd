extends RefCounted

const REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")
const GENERATOR := preload("res://scripts/domain/cases/CaseGenerator.gd")
const PUBLIC_VIEW := preload("res://scripts/domain/cases/GeneratedPublicCaseView.gd")
const SOLVER := preload("res://scripts/domain/cases/CaseGeneratorPublicSolver.gd")
const ACCEPTANCE := preload("res://scripts/domain/cases/CaseGenerationAcceptanceService.gd")
const PRETEND := preload("res://scripts/domain/cases/CaseProceduralPretendCapability.gd")
const NEXT_CASE := preload("res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd")
const TIMED_DISPATCHER := preload("res://scripts/domain/cases/CaseTimedEventDispatcher.gd")


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var role_ids: Array[StringName] = [
		&"surgeon", &"tutorial_priest", &"reporter", &"therapist", &"tutorial_scoundrel",
	]
	var request: CaseGenerationRequest = _request(role_ids)
	var generator = GENERATOR.new()
	var candidate: CaseGenerationResult = generator.generate(request, roles)
	var definition: CaseDefinition = generator.case_definition_from_result(candidate)
	var owner_id: int = _role_suspect_id(definition, &"surgeon")
	var view: GeneratedPublicCaseView = PUBLIC_VIEW.from_generation_result(candidate, roles)
	var no_surgeon_clue: bool = _has_no_surgeon_clue(view, owner_id)
	var validation: Dictionary = CaseDefinitionValidator.new().validate(
		definition, roles, FixtureRepository.load_players()
	)
	_add(rows, "Slice 6 generates native non-Evil Meddler Surgeon", (
		candidate != null and candidate.is_success()
		and _native_surgeon(definition, owner_id)
		and bool(validation.get("passed", false))
	))
	_add(rows, "Slice 6 native Surgeon produces no automatic public clue", no_surgeon_clue)

	var solved: CaseGeneratorSolverResult = SOLVER.new().solve(view, roles)
	_add(rows, "Slice 6 solver supports silent native Surgeon", (
		solved != null and solved.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION
		and solved.unique_evil_suspect_ids == definition.evil_suspect_ids
		and no_surgeon_clue
	))
	_add(rows, "Slice 6 Surgeon participates in true in-play role universe", (
		CaseRolePoolService.current_role_ids_in_play(definition, null).has(&"surgeon")
		and definition.suspected_role_ids.has(&"surgeon")
	))
	_add(rows, "Slice 6 Mailman present-absent logic accounts for Surgeon", _mailman_sees_surgeon(definition, roles))

	var duplicate_ids: Array[StringName] = [&"surgeon", &"surgeon", &"tutorial_scoundrel"]
	var duplicate: CaseGenerationResult = generator.generate(_request(duplicate_ids), roles)
	_add(rows, "Slice 6 true-role uniqueness rejects duplicate Surgeon slots", (
		duplicate != null and not duplicate.is_success()
		and duplicate.error_code == CaseGenerationResult.ERROR_INSUFFICIENT_UNIQUE_ROLES
	))

	var ambiguous_ids: Array[StringName] = [&"surgeon", &"tutorial_priest", &"conman"]
	var ambiguous_request: CaseGenerationRequest = _request(ambiguous_ids)
	var ambiguous_candidate: CaseGenerationResult = generator.generate(ambiguous_request, roles)
	var ambiguous_view: GeneratedPublicCaseView = PUBLIC_VIEW.from_generation_result(ambiguous_candidate, roles)
	var ambiguous_solver: CaseGeneratorSolverResult = SOLVER.new().solve(ambiguous_view, roles)
	var rejected: CaseGenerationAcceptanceResult = ACCEPTANCE.new().accept_unique_candidate(
		ambiguous_request, roles, 2
	)
	_add(rows, "Slice 6 ambiguous Surgeon Case is not rescued by future timed outcome", (
		ambiguous_candidate != null and ambiguous_candidate.is_success()
		and ambiguous_solver != null
		and ambiguous_solver.status == CaseGeneratorSolverResult.STATUS_MULTIPLE_SOLUTIONS
		and rejected != null and not rejected.success and rejected.accepted_candidate == null
		and int(rejected.rejected_status_counts.get(ACCEPTANCE.REJECTION_MULTIPLE_SOLUTIONS, 0)) == 2
	))

	var accepted: CaseGenerationAcceptanceResult = ACCEPTANCE.new().accept_unique_candidate(request, roles)
	var accepted_definition: CaseDefinition = null
	var accepted_solver: CaseGeneratorSolverResult = null
	if accepted != null and accepted.success:
		accepted_definition = generator.case_definition_from_result(accepted.accepted_candidate)
		accepted_solver = accepted.accepted_solver_result as CaseGeneratorSolverResult
	var evidence: String = _accepted_evidence(accepted, accepted_definition, accepted_solver)
	_add(rows, "Slice 6 normal acceptance requires UNIQUE and ground-truth match", (
		accepted != null and accepted.success
		and accepted_solver != null
		and accepted_solver.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION
		and accepted_solver.ground_truth_checked
		and accepted_solver.unique_solution_matches_ground_truth
		and _role_suspect_id(accepted_definition, &"surgeon") > 0
	), evidence)
	if not evidence.is_empty():
		print("SLICE6_SURGEON_EVIDENCE " + evidence)

	var runtime_checks: Dictionary = _runtime_handoff(accepted_definition, roles)
	_add(rows, "Slice 6 accepted Surgeon Case starts with clean timed state", bool(runtime_checks.get("clean", false)))
	_add(rows, "Slice 6 runtime dispatcher alone creates the pending 12h event", bool(runtime_checks.get("pending", false)))
	_add(rows, "Slice 6 existing runtime authority resolves the 12h event once", bool(runtime_checks.get("resolved_once", false)))
	_add(rows, "Slice 6 generator stores no pre-game timed victim or outcome", (
		no_surgeon_clue
		and candidate != null and candidate.hidden_case_draft != null
		and not candidate.hidden_case_draft.fingerprint_text().contains("surgeon_")
		and not candidate.hidden_case_draft.fingerprint_text().contains("12h")
	))
	_add(rows, "Slice 6 production pool enables native Surgeon only", _production_capability(roles))
	_add(rows, "Slice 6 Copycat and Mobster cannot display Surgeon", _pretend_boundary(roles))
	_add(rows, "Slice 6 Tutorial 05 authored Surgeon remains unchanged", _tutorial_05_unchanged(roles))
	return rows


func _request(role_ids: Array[StringName]) -> CaseGenerationRequest:
	var locations: Array[StringName] = [BoardLocationDefinition.LOCATION_CRIME_SCENE]
	return REQUEST.create(
		112233, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY,
		role_ids, locations, role_ids.size()
	)


func _native_surgeon(definition: CaseDefinition, owner_id: int) -> bool:
	var owner: SuspectDefinition = _suspect(definition, owner_id)
	return (
		owner != null
		and owner.true_role_id == &"surgeon"
		and owner.displayed_role_id == &"surgeon"
		and owner.role_group == CaseEnums.RoleGroup.HIEU_SU
		and owner.true_alignment == CaseEnums.Alignment.GOOD
		and not owner.is_impersonating
	)


func _has_no_surgeon_clue(view: GeneratedPublicCaseView, owner_id: int) -> bool:
	if view == null or owner_id <= 0:
		return false
	for clue in view.public_clues:
		if clue != null and (clue.suspect_id == owner_id or clue.behavior_role_id == &"surgeon"):
			return false
	return true


func _mailman_sees_surgeon(source: CaseDefinition, roles: Array[RoleDefinition]) -> bool:
	if source == null:
		return false
	var definition: CaseDefinition = source.duplicate(true) as CaseDefinition
	var mailman_id: int = 0
	for suspect: SuspectDefinition in definition.suspects:
		if suspect.true_role_id == &"reporter":
			suspect.true_role_id = &"mailman"
			suspect.displayed_role_id = &"mailman"
			mailman_id = suspect.suspect_id
	definition.suspected_role_ids = [
		&"surgeon", &"tutorial_priest", &"mailman", &"therapist",
		&"tutorial_scoundrel", &"mathematician",
	]
	var result: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(
		definition,
		mailman_id,
		roles,
		{"in_play_role_id": &"surgeon", "not_in_play_role_id": &"mathematician"}
	)
	return (
		mailman_id > 0
		and CaseRolePoolService.current_role_ids_in_play(definition, null).has(&"surgeon")
		and result != null
		and result.in_play_role_id == &"surgeon"
		and result.claimed_in_play_is_true
		and result.claimed_not_in_play_is_true
	)


func _runtime_handoff(definition: CaseDefinition, roles: Array[RoleDefinition]) -> Dictionary:
	var checks: Dictionary = {"clean": false, "pending": false, "resolved_once": false}
	var owner_id: int = _role_suspect_id(definition, &"surgeon")
	if definition == null or owner_id <= 0:
		return checks
	var runtime := CaseRuntimeState.new()
	runtime.initialize(definition, FixtureRepository.load_players())
	var all_alive: bool = true
	for suspect_runtime: SuspectRuntimeState in runtime.suspects:
		all_alive = all_alive and not suspect_runtime.is_dead
	checks.clean = runtime.elapsed_hours == 0 and runtime.timed_events.is_empty() and all_alive
	var dispatcher = TIMED_DISPATCHER.new()
	dispatcher.evaluate_all(definition, runtime, roles)
	var event_id: StringName = StringName("surgeon_%d_12h" % owner_id)
	var pending: CaseTimedEventRuntimeState = runtime.timed_event_by_id(event_id)
	checks.pending = (
		pending != null and not pending.fired and pending.target_suspect_id == 0
		and not pending.kill_attempted and runtime.elapsed_hours == 0
	)
	CaseClockService.new().advance_hours(runtime, 12, &"slice6_runtime_handoff")
	dispatcher.evaluate_all(definition, runtime, roles)
	var resolved: CaseTimedEventRuntimeState = runtime.timed_event_by_id(event_id)
	var first_fired_hour: int = resolved.fired_at_hour if resolved != null else -1
	var first_target_id: int = resolved.target_suspect_id if resolved != null else 0
	var first_log_count: int = _timed_event_log_count(runtime, event_id)
	dispatcher.evaluate_all(definition, runtime, roles)
	checks.resolved_once = (
		resolved != null and resolved.fired and first_fired_hour == 12
		and resolved.fired_at_hour == first_fired_hour
		and resolved.target_suspect_id == first_target_id
		and first_log_count == 1 and _timed_event_log_count(runtime, event_id) == 1
	)
	return checks


func _production_capability(roles: Array[RoleDefinition]) -> bool:
	var production_ids: Array[StringName] = NEXT_CASE.new()._default_next_case_generation_request().allowed_role_ids
	var surgeon_role: RoleDefinition = _role(roles, &"surgeon")
	return (
		surgeon_role != null
		and production_ids.has(&"surgeon")
		and SOLVER.SUPPORTED_PUBLIC_ROLE_IDS.has(&"surgeon")
		and production_ids.has(&"serial_killer")
		and production_ids.has(&"critic")
		and not production_ids.has(&"drunkard")
	)


func _pretend_boundary(roles: Array[RoleDefinition]) -> bool:
	var surgeon_role: RoleDefinition = _role(roles, &"surgeon")
	if surgeon_role == null or PRETEND.is_supported_behavior(&"surgeon"):
		return false
	for source_id: StringName in [&"copycat", &"tutorial_mobster", &"mobster"]:
		if PRETEND.can_pretend(source_id, surgeon_role):
			return false
	return true


func _tutorial_05_unchanged(roles: Array[RoleDefinition]) -> bool:
	var definition: CaseDefinition = FixtureRepository.load_tutorial_case_005()
	var owner: SuspectDefinition = _suspect(definition, 6)
	if owner == null:
		return false
	var runtime := CaseRuntimeState.new()
	runtime.initialize(definition, FixtureRepository.load_players())
	TIMED_DISPATCHER.new().evaluate_all(definition, runtime, roles)
	var event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"surgeon_6_12h")
	return (
		owner.true_role_id == &"surgeon"
		and owner.role_group == CaseEnums.RoleGroup.HIEU_SU
		and event != null and event.threshold_hour == 12 and not event.fired
	)


func _accepted_evidence(
	accepted: CaseGenerationAcceptanceResult,
	definition: CaseDefinition,
	solver: CaseGeneratorSolverResult
) -> String:
	if accepted == null or not accepted.success or definition == null or solver == null:
		return ""
	var owner_id: int = _role_suspect_id(definition, &"surgeon")
	if owner_id <= 0:
		return ""
	return "root=%d accepted_seed=%d suspects=%d surgeon_id=%d solver=%s timed_evidence=false" % [
		accepted.root_seed,
		accepted.accepted_derived_seed,
		definition.suspects.size(),
		owner_id,
		String(solver.status),
	]


func _timed_event_log_count(runtime: CaseRuntimeState, event_id: StringName) -> int:
	var count: int = 0
	for entry: Dictionary in runtime.action_log:
		if StringName(entry.get("event_id", &"")) == event_id:
			count += 1
	return count


func _role_suspect_id(definition: CaseDefinition, role_id: StringName) -> int:
	if definition != null:
		for suspect: SuspectDefinition in definition.suspects:
			if suspect.true_role_id == role_id:
				return suspect.suspect_id
	return 0


func _suspect(definition: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	if definition != null:
		for suspect: SuspectDefinition in definition.suspects:
			if suspect.suspect_id == suspect_id:
				return suspect
	return null


func _role(roles: Array[RoleDefinition], role_id: StringName) -> RoleDefinition:
	for role: RoleDefinition in roles:
		if role != null and role.role_id == role_id:
			return role
	return null


func _add(rows: Array[Dictionary], name: String, passed: bool, detail: String = "Native Surgeon excludes future timed evidence") -> void:
	rows.append({"name": name, "passed": passed, "detail": detail})
