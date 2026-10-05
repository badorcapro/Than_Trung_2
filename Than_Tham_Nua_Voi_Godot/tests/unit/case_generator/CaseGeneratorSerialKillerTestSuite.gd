extends RefCounted

const REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")
const GENERATOR := preload("res://scripts/domain/cases/CaseGenerator.gd")
const PUBLIC_VIEW := preload("res://scripts/domain/cases/GeneratedPublicCaseView.gd")
const PUBLIC_SUSPECT := preload("res://scripts/domain/cases/GeneratedPublicSuspectView.gd")
const SOLVER := preload("res://scripts/domain/cases/CaseGeneratorPublicSolver.gd")
const ACCEPTANCE := preload("res://scripts/domain/cases/CaseGenerationAcceptanceService.gd")
const PRETEND := preload("res://scripts/domain/cases/CaseProceduralPretendCapability.gd")
const SERIAL_SERVICE := preload("res://scripts/domain/cases/SerialKillerTimedEventService.gd")
const TIMED_DISPATCHER := preload("res://scripts/domain/cases/CaseTimedEventDispatcher.gd")
const NEXT_CASE := preload("res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd")


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var role_ids: Array[StringName] = [
		&"serial_killer", &"tutorial_priest", &"reporter", &"therapist",
		&"mathematician", &"tutorial_scoundrel",
	]
	var request: CaseGenerationRequest = _request(role_ids, 112233)
	var generator = GENERATOR.new()
	var candidate: CaseGenerationResult = generator.generate(request, roles)
	var definition: CaseDefinition = generator.case_definition_from_result(candidate)
	var owner_id: int = _role_suspect_id(definition, &"serial_killer")
	var owner: SuspectDefinition = _suspect(definition, owner_id)
	var validation: Dictionary = CaseDefinitionValidator.new().validate(
		definition, roles, FixtureRepository.load_players()
	)
	_add(rows, "Slice 7 generates native Evil Underling Serial Killer", (
		candidate != null and candidate.is_success()
		and owner != null and owner.true_role_id == &"serial_killer"
		and owner.true_alignment == CaseEnums.Alignment.EVIL
		and owner.role_group == CaseEnums.RoleGroup.TONG_PHAM
		and owner.is_impersonating and owner.displayed_role_id != owner.true_role_id
		and bool(validation.get("passed", false))
	))
	_add(rows, "Slice 7 generated pretend target is listed and capability-valid", (
		owner != null and definition.suspected_role_ids.has(owner.displayed_role_id)
		and PRETEND.serial_killer_can_pretend(owner.displayed_role_id)
	))
	_add(rows, "Slice 7 generator enforces post-startup adjacent current Innocent", (
		owner_id > 0 and SERIAL_SERVICE.new().serial_killer_spawn_requirement_met(
			definition, owner_id, roles
		)
	))
	_add(rows, "Slice 7 preserves 3x3 capacity, uniqueness, and max-three-Evil", (
		definition != null and definition.suspects.size() == 6
		and definition.evil_suspect_ids.size() <= 3
		and _true_roles_are_unique(definition)
		and int(definition.get_meta(&"board_slot_count", 0)) == 9
	))

	var public_view: GeneratedPublicCaseView = PUBLIC_VIEW.from_generation_result(candidate, roles)
	var serial_clue = _serial_clue(candidate, owner_id)
	_add(rows, "Slice 7 Serial Killer public clue uses displayed behavior in LYING mode", (
		owner != null and serial_clue != null and serial_clue.behavior_role_id == owner.displayed_role_id
		and serial_clue.truth_mode == InvestigationInformationResult.TruthMode.LYING
	))
	_add(rows, "Slice 7 generated public evidence contains no future timed outcome", (
		_has_no_serial_timed_evidence(public_view, owner_id)
		and candidate != null and candidate.hidden_case_draft != null
		and not candidate.hidden_case_draft.fingerprint_text().contains("serial_killer_")
		and not candidate.hidden_case_draft.fingerprint_text().contains("9h")
	))
	_add(rows, "Slice 7 Priest disguise uses canonical lying announcement", _priest_disguise_uses_lying_text(roles))
	_add(rows, "Slice 7 solver spawn gate accepts and rejects current-group adjacency", _solver_spawn_gate(roles))
	_add(rows, "Slice 7 ambiguous Case is not rescued by future timed outcome", _ambiguous_case_is_rejected(roles))

	var accepted: CaseGenerationAcceptanceResult = ACCEPTANCE.new().accept_unique_candidate(request, roles)
	var accepted_definition: CaseDefinition = null
	var accepted_solver: CaseGeneratorSolverResult = null
	if accepted != null and accepted.success:
		accepted_definition = generator.case_definition_from_result(accepted.accepted_candidate)
		accepted_solver = accepted.accepted_solver_result as CaseGeneratorSolverResult
	var evidence: String = _accepted_evidence(accepted, accepted_definition, accepted_solver)
	_add(rows, "Slice 7 solver keeps the legal Serial Killer world", (
		accepted_solver != null
		and accepted_solver.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION
		and accepted_solver.unique_evil_suspect_ids == accepted_definition.evil_suspect_ids
	), evidence)
	_add(rows, "Slice 7 normal acceptance requires UNIQUE ground-truth match", (
		accepted != null and accepted.success and accepted_solver != null
		and accepted_solver.ground_truth_checked
		and accepted_solver.unique_solution_matches_ground_truth
		and _role_suspect_id(accepted_definition, &"serial_killer") > 0
		and _has_no_serial_timed_evidence(
			accepted.accepted_public_view as GeneratedPublicCaseView,
			_role_suspect_id(accepted_definition, &"serial_killer")
		)
	), evidence)
	if not evidence.is_empty():
		print("SLICE7_SERIAL_KILLER_EVIDENCE " + evidence)

	var runtime_checks: Dictionary = _runtime_handoff(accepted_definition, roles)
	_add(rows, "Slice 7 accepted Case starts with no pre-game Serial Killer event", bool(runtime_checks.get("clean", false)))
	_add(rows, "Slice 7 existing dispatcher resolves the 9h event", bool(runtime_checks.get("resolved", false)))
	_add(rows, "Slice 7 9h event is stable and does not reroll", bool(runtime_checks.get("repeat_safe", false)))
	_add(rows, "Slice 7 production pool enables solver-supported Serial Killer", _production_capability())
	_add(rows, "Slice 7 pretend capability remains explicitly scoped", _pretend_boundaries(roles))
	_add(rows, "Slice 7 Tutorial 07 authored Serial Killer remains unchanged", _tutorial_07_unchanged(roles))
	return rows


func _request(role_ids: Array[StringName], seed: int) -> CaseGenerationRequest:
	var locations: Array[StringName] = [BoardLocationDefinition.LOCATION_CRIME_SCENE]
	return REQUEST.create(
		seed, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY,
		role_ids, locations, role_ids.size()
	)


func _priest_disguise_uses_lying_text(roles: Array[RoleDefinition]) -> bool:
	var ids: Array[StringName] = [
		&"serial_killer", &"tutorial_priest", &"tailor", &"vigilante", &"surgeon",
	]
	var candidate: CaseGenerationResult = GENERATOR.new().generate(_request(ids, 771907), roles)
	if candidate == null or not candidate.is_success():
		return false
	var owner_id: int = _generated_role_suspect_id(candidate, &"serial_killer")
	var owner = _generated_suspect(candidate, owner_id)
	var clue = _serial_clue(candidate, owner_id)
	return (
		owner != null and owner.displayed_role_id == &"tutorial_priest"
		and clue != null and clue.behavior_role_id == &"tutorial_priest"
		and RoleInformationEvaluationService.PRIEST_LIE_TEXTS.has(clue.text)
		and clue.text != RoleInformationEvaluationService.PRIEST_TRUTHFUL_TEXT
	)


func _solver_spawn_gate(roles: Array[RoleDefinition]) -> bool:
	var role_by_id: Dictionary = {}
	for role: RoleDefinition in roles:
		if role != null:
			role_by_id[role.role_id] = role
	var suspects: Array = [
		PUBLIC_SUSPECT.create(1, 0, &"tutorial_priest", CaseEnums.RoleGroup.CHINH_NHAN),
		PUBLIC_SUSPECT.create(2, 1, &"therapist", CaseEnums.RoleGroup.CHINH_NHAN),
		PUBLIC_SUSPECT.create(3, 4, &"reporter", CaseEnums.RoleGroup.CHINH_NHAN),
	]
	var view: GeneratedPublicCaseView = PUBLIC_VIEW.create_manual(3, 3, 1, suspects)
	var solver = SOLVER.new()
	var compatible: Dictionary = {1: &"serial_killer", 2: &"therapist", 3: &"reporter"}
	var incompatible: Dictionary = {1: &"serial_killer", 2: &"tutorial_scoundrel", 3: &"reporter"}
	return (
		solver._serial_killer_hypothesis_is_valid(view, role_by_id, compatible, 0)
		and not solver._serial_killer_hypothesis_is_valid(view, role_by_id, incompatible, 0)
		and not solver._serial_killer_hypothesis_is_valid(view, role_by_id, compatible, 2)
	)


func _ambiguous_case_is_rejected(roles: Array[RoleDefinition]) -> bool:
	var ids: Array[StringName] = [&"serial_killer", &"tutorial_priest", &"conman"]
	var request: CaseGenerationRequest = _request(ids, 441177)
	var candidate: CaseGenerationResult = GENERATOR.new().generate(request, roles)
	if candidate == null or not candidate.is_success():
		return false
	var view: GeneratedPublicCaseView = PUBLIC_VIEW.from_generation_result(candidate, roles)
	var owner_id: int = _generated_role_suspect_id(candidate, &"serial_killer")
	var other_slots: PackedInt32Array = PackedInt32Array([1, 3])
	var other_index: int = 0
	for suspect in view.suspects:
		if suspect.suspect_id == owner_id:
			suspect.board_slot = 4
		else:
			suspect.board_slot = other_slots[other_index]
			other_index += 1
	var solved: CaseGeneratorSolverResult = SOLVER.new().solve(view, roles)
	return (
		solved != null and solved.status == CaseGeneratorSolverResult.STATUS_MULTIPLE_SOLUTIONS
		and _has_no_serial_timed_evidence(view, owner_id)
	)


func _runtime_handoff(definition: CaseDefinition, roles: Array[RoleDefinition]) -> Dictionary:
	var checks: Dictionary = {"clean": false, "resolved": false, "repeat_safe": false}
	var owner_id: int = _role_suspect_id(definition, &"serial_killer")
	if definition == null or owner_id <= 0:
		return checks
	var runtime := CaseRuntimeState.new()
	runtime.initialize(definition, FixtureRepository.load_players())
	checks.clean = runtime.elapsed_hours == 0 and runtime.timed_events.is_empty()
	var dispatcher = TIMED_DISPATCHER.new()
	CaseClockService.new().advance_hours(runtime, 9, &"slice7_runtime_handoff")
	dispatcher.evaluate_all(definition, runtime, roles)
	var event_id: StringName = StringName("serial_killer_%d_9h" % owner_id)
	var event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(event_id)
	var first_target: int = event.target_suspect_id if event != null else 0
	var first_logs: int = _timed_event_log_count(runtime, event_id)
	checks.resolved = (
		event != null and event.fired and event.kill_attempted
		and event.target_suspect_id > 0 and event.fired_at_hour == 9
	)
	dispatcher.evaluate_all(definition, runtime, roles)
	event = runtime.timed_event_by_id(event_id)
	checks.repeat_safe = (
		event != null and event.target_suspect_id == first_target
		and first_logs == 1 and _timed_event_log_count(runtime, event_id) == 1
	)
	return checks


func _production_capability() -> bool:
	var production_ids: Array[StringName] = NEXT_CASE.new()._default_next_case_generation_request().allowed_role_ids
	return (
		production_ids.has(&"serial_killer")
		and SOLVER.SUPPORTED_PUBLIC_ROLE_IDS.has(&"serial_killer")
		and production_ids.has(&"critic")
		and not production_ids.has(&"drunkard")
	)


func _pretend_boundaries(roles: Array[RoleDefinition]) -> bool:
	var serial_role: RoleDefinition = _role(roles, &"serial_killer")
	var clock_role: RoleDefinition = _role(roles, &"clock_maker")
	var critic_role: RoleDefinition = _role(roles, &"critic")
	return (
		serial_role != null and clock_role != null and critic_role != null
		and PRETEND.can_pretend(&"serial_killer", clock_role)
		and not PRETEND.can_pretend(&"serial_killer", critic_role)
		and not PRETEND.can_pretend(&"copycat", serial_role)
		and not PRETEND.can_pretend(&"tutorial_mobster", serial_role)
		and not PRETEND.can_pretend(&"mobster", serial_role)
	)


func _tutorial_07_unchanged(roles: Array[RoleDefinition]) -> bool:
	var definition: CaseDefinition = FixtureRepository.load_tutorial_case_007()
	var owner: SuspectDefinition = _suspect(definition, 7)
	if owner == null:
		return false
	var runtime := CaseRuntimeState.new()
	runtime.initialize(definition, FixtureRepository.load_players())
	CaseClockService.new().advance_hours(runtime, 9, &"slice7_tutorial_guard")
	TIMED_DISPATCHER.new().evaluate_all(definition, runtime, roles)
	var event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"serial_killer_7_9h")
	return (
		owner.true_role_id == &"serial_killer"
		and owner.displayed_role_id == &"clock_maker"
		and event != null and event.fired and event.threshold_hour == 9
	)


func _has_no_serial_timed_evidence(view: GeneratedPublicCaseView, owner_id: int) -> bool:
	if view == null or owner_id <= 0:
		return false
	for clue in view.public_clues:
		if clue != null and clue.behavior_role_id == &"serial_killer":
			return false
	return true


func _serial_clue(candidate: CaseGenerationResult, owner_id: int):
	if candidate == null or candidate.hidden_case_draft == null:
		return null
	for clue in candidate.hidden_case_draft.public_clues:
		if clue != null and clue.suspect_id == owner_id:
			return clue
	return null


func _accepted_evidence(
	accepted: CaseGenerationAcceptanceResult,
	definition: CaseDefinition,
	solver: CaseGeneratorSolverResult
) -> String:
	if accepted == null or not accepted.success or definition == null or solver == null:
		return ""
	var owner_id: int = _role_suspect_id(definition, &"serial_killer")
	var owner: SuspectDefinition = _suspect(definition, owner_id)
	if owner == null:
		return ""
	var adjacent_ids: PackedInt32Array = _adjacent_current_innocent_ids(definition, owner_id, FixtureRepository.load_roles())
	var accepted_view: GeneratedPublicCaseView = accepted.accepted_public_view as GeneratedPublicCaseView
	var timed_evidence: bool = not _has_no_serial_timed_evidence(accepted_view, owner_id)
	return "root=%d accepted_seed=%d suspects=%d serial_killer_id=%d pretend=%s adjacent_current_innocents=%s solver=%s timed_evidence=%s" % [
		accepted.root_seed,
		accepted.accepted_derived_seed,
		definition.suspects.size(),
		owner_id,
		String(owner.displayed_role_id),
		_join_ints(adjacent_ids),
		String(solver.status),
		str(timed_evidence),
	]


func _adjacent_current_innocent_ids(
	definition: CaseDefinition, owner_id: int, roles: Array[RoleDefinition]
) -> PackedInt32Array:
	var ids: PackedInt32Array = PackedInt32Array()
	var owner: SuspectDefinition = _suspect(definition, owner_id)
	if owner == null:
		return ids
	var runtime := CaseRuntimeState.new()
	var no_players: Array[PlayerCaseState] = []
	runtime.initialize(definition, no_players)
	if definition.startup_barkeep_source_suspect_id > 0 and definition.startup_barkeep_target_suspect_id > 0:
		BarkeepTransformationService.new().resolve_transformation(
			definition, runtime, definition.startup_barkeep_source_suspect_id,
			definition.startup_barkeep_target_suspect_id, roles
		)
	var spatial := CaseSpatialService.new()
	for suspect: SuspectDefinition in definition.suspects:
		if suspect == null or suspect.suspect_id == owner_id:
			continue
		var state: CaseMutationStateSnapshot = CaseMutationStateSnapshot.from_runtime(
			definition, runtime, suspect.suspect_id, roles
		)
		if state != null and state.current_role_group == CaseEnums.RoleGroup.CHINH_NHAN and spatial.are_orthogonally_adjacent(owner.board_slot, suspect.board_slot):
			ids.append(suspect.suspect_id)
	ids.sort()
	return ids


func _join_ints(values: PackedInt32Array) -> String:
	var parts: Array[String] = []
	for value: int in values:
		parts.append(str(value))
	return ",".join(parts)


func _true_roles_are_unique(definition: CaseDefinition) -> bool:
	var seen: Dictionary = {}
	if definition == null:
		return false
	for suspect: SuspectDefinition in definition.suspects:
		if seen.has(suspect.true_role_id):
			return false
		seen[suspect.true_role_id] = true
	return true


func _timed_event_log_count(runtime: CaseRuntimeState, event_id: StringName) -> int:
	var count: int = 0
	for entry: Dictionary in runtime.action_log:
		if StringName(entry.get("event_id", &"")) == event_id:
			count += 1
	return count


func _generated_role_suspect_id(candidate: CaseGenerationResult, role_id: StringName) -> int:
	if candidate != null and candidate.hidden_case_draft != null:
		for suspect in candidate.hidden_case_draft.suspects:
			if suspect != null and suspect.true_role_id == role_id:
				return suspect.suspect_id
	return 0


func _generated_suspect(candidate: CaseGenerationResult, suspect_id: int):
	if candidate != null and candidate.hidden_case_draft != null:
		for suspect in candidate.hidden_case_draft.suspects:
			if suspect != null and suspect.suspect_id == suspect_id:
				return suspect
	return null


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


func _add(rows: Array[Dictionary], name: String, passed: bool, detail: String = "Native Serial Killer pre-timed-event invariant") -> void:
	rows.append({"name": name, "passed": passed, "detail": detail})
