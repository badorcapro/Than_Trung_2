extends RefCounted

const REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")
const GENERATOR := preload("res://scripts/domain/cases/CaseGenerator.gd")
const PUBLIC_VIEW := preload("res://scripts/domain/cases/GeneratedPublicCaseView.gd")
const PUBLIC_SUSPECT := preload("res://scripts/domain/cases/GeneratedPublicSuspectView.gd")
const SOLVER := preload("res://scripts/domain/cases/CaseGeneratorPublicSolver.gd")
const ACCEPTANCE := preload("res://scripts/domain/cases/CaseGenerationAcceptanceService.gd")
const NEXT_CASE_SESSION := preload("res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd")


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()

	var protected_case: CaseDefinition = _runtime_case(true)
	var protected_runtime: CaseRuntimeState = _runtime(protected_case)
	var blocked_kill: CaseKillResult = CaseKillService.new().kill(
		protected_case, protected_runtime, 1, &"scoundrel_test"
	)
	_add(rows, "Slice 1 Scoundrel blocks kill while another true Evil remains", (
		not blocked_kill.success
		and blocked_kill.error_code == &"SCOUNDREL_IMMUNE"
		and not protected_runtime.find_suspect(1).is_dead
	))

	var last_evil_case: CaseDefinition = _runtime_case(true)
	var last_evil_runtime: CaseRuntimeState = _runtime(last_evil_case)
	last_evil_runtime.find_suspect(2).mark_arrested()
	var allowed_kill: CaseKillResult = CaseKillService.new().kill(
		last_evil_case, last_evil_runtime, 1, &"scoundrel_test"
	)
	_add(rows, "Slice 1 Scoundrel can be killed as last living unhandled true Evil", (
		allowed_kill.success and allowed_kill.state_changed
		and last_evil_runtime.find_suspect(1).is_dead
	))

	var tainted_case: CaseDefinition = _runtime_case(true)
	var tainted_runtime: CaseRuntimeState = _runtime(tainted_case)
	tainted_runtime.find_suspect(1).apply_runtime_corruption(99)
	var tainted_kill: CaseKillResult = CaseKillService.new().kill(
		tainted_case, tainted_runtime, 1, &"scoundrel_test"
	)
	_add(rows, "Slice 1 tainted Scoundrel loses immunity early", (
		tainted_kill.success and tainted_runtime.find_suspect(1).is_dead
	))

	var displayed_case: CaseDefinition = _runtime_case(false, true)
	var displayed_runtime: CaseRuntimeState = _runtime(displayed_case)
	var displayed_kill: CaseKillResult = CaseKillService.new().kill(
		displayed_case, displayed_runtime, 1, &"scoundrel_test"
	)
	_add(rows, "Slice 1 Good suspect displaying Evil does not preserve immunity", (
		displayed_kill.success and displayed_runtime.find_suspect(1).is_dead
	))

	var accusation_case: CaseDefinition = _runtime_case(true)
	var accusation_runtime: CaseRuntimeState = _runtime(accusation_case)
	var accusation_player: PlayerCaseState = accusation_runtime.players[0]
	var blocked_accusation: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(
		accusation_case, accusation_runtime, accusation_player, 1
	)
	var time_applied: bool = false
	if blocked_accusation.success:
		time_applied = CaseClockService.new().apply_action_time(
			accusation_runtime, &"scoundrel_blocked_accusation", CaseClockService.ACTION_SINGLE_ACCUSATION
		)
	_add(rows, "Slice 1 immune accusation consumes action without arrest or reveal", (
		blocked_accusation.success and blocked_accusation.blocked_by_immunity
		and blocked_accusation.error_code == &"SCOUNDREL_IMMUNE"
		and not accusation_runtime.find_suspect(1).is_arrested
		and accusation_player.is_active_in_investigation
		and accusation_runtime.private_role_knowledge.is_empty()
		and time_applied and accusation_runtime.elapsed_hours == 1
	))

	var personal_case: CaseDefinition = _runtime_case(true)
	var personal_runtime: CaseRuntimeState = _runtime(personal_case)
	var personal_player: PlayerCaseState = personal_runtime.players[0]
	var other_evil: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(
		personal_case, personal_runtime, personal_player, 2
	)
	var personal_history_before_scoundrel: PackedInt32Array = (
		personal_runtime.correctly_accused_evil_ids_for_player(
			personal_case, personal_player.player_id
		)
	)
	var successful_accusation: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(
		personal_case, personal_runtime, personal_player, 1
	)
	_add(rows, "Slice 1 Scoundrel accusation unlocks from the same player's Evil history", (
		other_evil.success and other_evil.correct
		and personal_history_before_scoundrel == PackedInt32Array([2])
		and successful_accusation.success and successful_accusation.correct
		and not successful_accusation.blocked_by_immunity
		and not personal_runtime.find_suspect(1).is_arrested
	))

	var silent_view: GeneratedPublicCaseView = _silent_public_view()
	var silent_solved: CaseGeneratorSolverResult = SOLVER.new().solve(silent_view, roles)
	_add(rows, "Slice 1 solver accepts Scoundrel as silent Evil hypothesis", (
		silent_solved != null
		and silent_solved.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION
		and silent_solved.unique_evil_suspect_ids == PackedInt32Array([1])
	))

	var request: CaseGenerationRequest = _generation_request()
	var generator = GENERATOR.new()
	var candidate: CaseGenerationResult = generator.generate(request, roles)
	var generated_scoundrel_id: int = _generated_role_suspect_id(candidate, &"tutorial_scoundrel")
	var scoundrel_has_no_clue: bool = generated_scoundrel_id > 0
	if candidate != null and candidate.hidden_case_draft != null:
		for clue in candidate.hidden_case_draft.public_clues:
			if clue != null and clue.suspect_id == generated_scoundrel_id:
				scoundrel_has_no_clue = false
	_add(rows, "Slice 1 generator constructs silent Scoundrel candidate", (
		candidate != null and candidate.is_success()
		and generated_scoundrel_id > 0 and scoundrel_has_no_clue
	))

	var production_ids: Array[StringName] = NEXT_CASE_SESSION.new()._default_next_case_generation_request().allowed_role_ids
	var unsupported_roles_absent: bool = true
	for unsupported_id: StringName in [
		&"drunkard",
	]:
		unsupported_roles_absent = unsupported_roles_absent and not production_ids.has(unsupported_id)
	_add(rows, "Slice 1 production pool retains Scoundrel and excludes deferred roles", (
		production_ids.has(&"tutorial_scoundrel") and unsupported_roles_absent
	))

	var accepted: CaseGenerationAcceptanceResult = ACCEPTANCE.new().accept_unique_candidate(
		request, roles, 8
	)
	var accepted_candidate: CaseGenerationResult
	var accepted_solver: CaseGeneratorSolverResult
	if accepted != null:
		accepted_candidate = accepted.accepted_candidate as CaseGenerationResult
		accepted_solver = accepted.accepted_solver_result as CaseGeneratorSolverResult
	var accepted_has_scoundrel: bool = _generated_role_suspect_id(
		accepted_candidate, &"tutorial_scoundrel"
	) > 0
	_add(rows, "Slice 1 normal acceptance requires UNIQUE ground-truth Scoundrel Case", (
		accepted != null and accepted.success and accepted_has_scoundrel
		and accepted_solver != null
		and accepted_solver.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION
		and accepted_solver.ground_truth_checked
		and accepted_solver.unique_solution_matches_ground_truth
	))
	return rows


func _runtime_case(include_other_evil: bool, include_good_displaying_evil: bool = false) -> CaseDefinition:
	var definition := CaseDefinition.new()
	definition.case_id = &"scoundrel_runtime_fixture"
	definition.set_meta(&"board_columns", 3)
	definition.set_meta(&"board_slot_count", 9)
	definition.suspected_role_ids = [&"tutorial_scoundrel", &"tutorial_mobster", &"tutorial_priest"]
	definition.suspects.append(_suspect(
		1, 0, &"tutorial_scoundrel", &"tutorial_scoundrel",
		CaseEnums.RoleGroup.TONG_PHAM, CaseEnums.Alignment.EVIL
	))
	definition.evil_suspect_ids.append(1)
	if include_other_evil:
		definition.suspects.append(_suspect(
			2, 1, &"tutorial_mobster", &"tutorial_priest",
			CaseEnums.RoleGroup.TONG_PHAM, CaseEnums.Alignment.EVIL
		))
		definition.evil_suspect_ids.append(2)
	if include_good_displaying_evil:
		definition.suspects.append(_suspect(
			3, 2, &"tutorial_priest", &"tutorial_scoundrel",
			CaseEnums.RoleGroup.CHINH_NHAN, CaseEnums.Alignment.GOOD
		))
	return definition


func _runtime(definition: CaseDefinition) -> CaseRuntimeState:
	var runtime := CaseRuntimeState.new()
	runtime.initialize(definition, FixtureRepository.load_players())
	for player: PlayerCaseState in runtime.players:
		runtime.turn_order_player_ids.append(player.player_id)
	return runtime


func _suspect(
	suspect_id: int,
	board_slot: int,
	true_role_id: StringName,
	displayed_role_id: StringName,
	role_group: CaseEnums.RoleGroup,
	alignment: CaseEnums.Alignment
) -> SuspectDefinition:
	var suspect := SuspectDefinition.new()
	suspect.suspect_id = suspect_id
	suspect.board_slot = board_slot
	suspect.true_role_id = true_role_id
	suspect.displayed_role_id = displayed_role_id
	suspect.role_group = role_group
	suspect.true_alignment = alignment
	if true_role_id != displayed_role_id:
		suspect.is_impersonating = true
		suspect.impersonated_role_id = displayed_role_id
	return suspect


func _silent_public_view() -> GeneratedPublicCaseView:
	var suspects: Array = [
		PUBLIC_SUSPECT.create(1, 0, &"tutorial_scoundrel", CaseEnums.RoleGroup.TONG_PHAM),
		PUBLIC_SUSPECT.create(2, 1, &"tutorial_priest", CaseEnums.RoleGroup.CHINH_NHAN),
	]
	var view: GeneratedPublicCaseView = PUBLIC_VIEW.create_manual(3, 3, 1, suspects)
	view.allowed_role_ids = [&"tutorial_scoundrel", &"tutorial_priest"]
	view.suspected_role_ids = view.allowed_role_ids.duplicate()
	return view


func _generation_request() -> CaseGenerationRequest:
	var role_ids: Array[StringName] = [
		&"tutorial_priest", &"reporter", &"therapist", &"mathematician",
		&"tutorial_scoundrel",
	]
	var location_ids: Array[StringName] = [BoardLocationDefinition.LOCATION_CRIME_SCENE]
	return REQUEST.create(
		112233, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY,
		role_ids, location_ids, 5
	)


func _generated_role_suspect_id(candidate: CaseGenerationResult, role_id: StringName) -> int:
	if candidate == null or not candidate.is_success() or candidate.hidden_case_draft == null:
		return 0
	for suspect in candidate.hidden_case_draft.suspects:
		if suspect != null and suspect.true_role_id == role_id:
			return suspect.suspect_id
	return 0


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "Case Generator Slice 1 Scoundrel end-to-end invariant",
	})
