extends RefCounted

const REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")
const GENERATOR := preload("res://scripts/domain/cases/CaseGenerator.gd")
const PUBLIC_VIEW := preload("res://scripts/domain/cases/GeneratedPublicCaseView.gd")
const SOLVER := preload("res://scripts/domain/cases/CaseGeneratorPublicSolver.gd")
const ACCEPTANCE := preload("res://scripts/domain/cases/CaseGenerationAcceptanceService.gd")
const WAREHOUSE := preload("res://scripts/domain/cases/CaseSeedWarehouseBuilder.gd")
const SELECTOR := preload("res://scripts/domain/cases/CaseSeedWarehouseSelector.gd")
const COMPOSER := preload("res://scripts/domain/cases/CaseSeedWarehouseOptionComposer.gd")
const CAPABILITY := preload("res://scripts/domain/cases/CaseProceduralPretendCapability.gd")
const NEXT_CASE_SESSION := preload("res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd")
const AUDIT_SNAPSHOT := preload("res://scripts/tools/CaseGenerationAuditSnapshot.gd")
const WAREHOUSE_ENTRY := preload("res://scripts/domain/cases/CaseSeedWarehouseEntry.gd")
const PUBLIC_CLUE := preload("res://scripts/domain/cases/GeneratedPublicClue.gd")
const PUBLIC_SUSPECT := preload("res://scripts/domain/cases/GeneratedPublicSuspectView.gd")
const ACCEPTANCE_RESULT := preload("res://scripts/domain/cases/CaseGenerationAcceptanceResult.gd")


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var role_ids: Array[StringName] = [&"tutorial_priest", &"reporter", &"copycat", &"conman"]
	var locations: Array[StringName] = [BoardLocationDefinition.LOCATION_CRIME_SCENE]
	var request: CaseGenerationRequest = REQUEST.create(112233, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY, role_ids, locations, 4)
	var generator = GENERATOR.new()
	var candidate: CaseGenerationResult = generator.generate(request, roles)
	var repeated: CaseGenerationResult = generator.generate(request, roles)
	var case_definition: CaseDefinition = generator.case_definition_from_result(candidate)
	var copycat: SuspectDefinition = _find_role(case_definition, &"copycat")
	var conman: SuspectDefinition = _find_role(case_definition, &"conman")
	var evaluator := RoleInformationEvaluationService.new()
	var copycat_info: InvestigationInformationResult = evaluator.evaluate(case_definition, copycat.suspect_id, roles) if copycat != null else null
	var conman_info: InvestigationInformationResult = evaluator.evaluate(case_definition, conman.suspect_id, roles) if conman != null else null
	var public_view: GeneratedPublicCaseView = PUBLIC_VIEW.from_generation_result(candidate, roles)
	var solved: CaseGeneratorSolverResult = SOLVER.new().solve(public_view, roles)
	var true_roles: Dictionary = {}
	var displayed_roles: Dictionary = {}
	if case_definition != null:
		for suspect: SuspectDefinition in case_definition.suspects:
			true_roles[suspect.true_role_id] = true
			displayed_roles[suspect.displayed_role_id] = int(displayed_roles.get(suspect.displayed_role_id, 0)) + 1
	_add(rows, "M6A Copycat has distinct Good true and in-play displayed roles", _pretend_valid(copycat, case_definition, roles, true))
	_add(rows, "M6A Conman has distinct Evil true and in-play displayed roles", _pretend_valid(conman, case_definition, roles, false))
	_add(rows, "M6A natural true roles stay unique", case_definition != null and true_roles.size() == case_definition.suspects.size())
	var validation: Dictionary = CaseDefinitionValidator.new().validate(case_definition, roles, FixtureRepository.load_players()) if case_definition != null else {}
	_add(rows, "M6A generated pretend Case passes authored validation", bool(validation.get("passed", false)))
	_add(rows, "M6A final Case retains canonical suspected-role pool", case_definition != null and case_definition.suspected_role_ids == role_ids)
	_add(rows, "M6A displayed role duplication is permitted", _has_duplicate(displayed_roles))
	_add(rows, "M6A Copycat behavior and truthfulness are independent", _truthful_pretend_info(copycat, copycat_info))
	_add(rows, "M6A Evil Conman can emit truthful behavior information", _truthful_pretend_info(conman, conman_info))
	_add(rows, "M6A generated Copycat clue matches truthful behavior", _clue_matches_info(candidate, copycat, copycat_info))
	_add(rows, "M6A generated Conman clue matches truthful behavior", _clue_matches_info(candidate, conman, conman_info))
	_add(rows, "M6A public view exposes displayed role without true-role clue", _public_firewall(public_view, candidate))
	_add(rows, "M6A solver retains actual Evil world despite truthful Conman", _contains_evil_set(solved, candidate))
	_add(rows, "M6A truthful Priest text does not imply Good", _priest_text_allows_truthful_evil_pretender(roles))
	var equivalent_worlds := CaseGeneratorSolverResult.new()
	equivalent_worlds.set_candidates([PackedInt32Array([2]), PackedInt32Array([2])])
	_add(rows, "M6A solver counts Evil sets rather than hidden assignments", solved != null and solved.candidate_count == solved.candidate_evil_sets.size() and equivalent_worlds.candidate_count == 1 and equivalent_worlds.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION)
	_add(rows, "M6A same seed preserves pretend target and candidate signature", candidate != null and repeated != null and candidate.is_success() and repeated.is_success() and candidate.fingerprint == repeated.fingerprint)
	_add(rows, "M6A candidate signature distinguishes pretend targets", _pretend_target_changes_signature())
	var invalid_ids: Array[StringName] = [&"copycat", &"conman"]
	var invalid_request: CaseGenerationRequest = REQUEST.create(17, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY, invalid_ids, locations, 2)
	var invalid: CaseGenerationResult = generator.generate(invalid_request, roles)
	_add(rows, "M6A missing eligible pretend target rejects candidate", invalid != null and not invalid.is_success() and invalid.error_code == CaseGenerationResult.ERROR_IMPOSSIBLE_REQUEST)
	var accepted: CaseGenerationAcceptanceResult = ACCEPTANCE.new().accept_unique_candidate(request, roles)
	_add(rows, "M6A M3 accepts a uniquely solvable pretend Case", accepted != null and accepted.success and accepted.accepted_candidate != null and accepted.accepted_solver_result != null)
	rows.append_array(_audit_rows(request, accepted, roles))
	var root_seeds: PackedInt32Array = PackedInt32Array([112233, 112234, 112235, 112236, 112237, 112238])
	var warehouse: CaseSeedWarehouseBuildResult = WAREHOUSE.new().build(request, root_seeds, 3, roles)
	_add(rows, "M6A warehouse stores verified pretend candidates", warehouse != null and warehouse.entries.size() == 3)
	var selection: CaseSeedWarehouseSelectionResult = SELECTOR.new().select_entry(warehouse, 91, [], request, roles)
	_add(rows, "M6A M4B selects a verified pretend candidate", selection != null and selection.success and selection.selected_entry != null)
	var options: CaseSeedWarehouseOptionSetResult = COMPOSER.new().compose_options(warehouse, 91, [], request, roles)
	_add(rows, "M6A M5A composes three distinct pretend-capable options", options != null and options.success and options.option_candidate_signatures.size() == 3)
	_add(rows, "M6A Mobster lying authority remains separate", evaluator.truth_mode_for_suspect(_mobster_suspect()) == InvestigationInformationResult.TruthMode.LYING)
	var production_request: CaseGenerationRequest = NEXT_CASE_SESSION.new()._default_next_case_generation_request()
	_add(rows, "M6A normal procedural pool includes both canonical pretenders", production_request.allowed_role_ids.has(&"copycat") and production_request.allowed_role_ids.has(&"conman") and not production_request.allowed_role_ids.has(&"role_meddler_a"))
	return rows


func _audit_rows(request: CaseGenerationRequest, accepted: CaseGenerationAcceptanceResult, roles: Array[RoleDefinition]) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var entry: CaseSeedWarehouseEntry = WAREHOUSE_ENTRY.from_acceptance(request, accepted) if accepted != null and accepted.success else null
	var audit = AUDIT_SNAPSHOT.new()
	var original_fingerprint: String = accepted.fingerprint_text() if accepted != null else ""
	var captured: bool = audit.capture(entry, accepted, roles)
	var audited_case: CaseDefinition = GENERATOR.new().case_definition_from_result(accepted.accepted_candidate) if accepted != null and accepted.success else null
	var attached: bool = NEXT_CASE_SESSION.new()._attach_case_generation_audit(audited_case, entry, accepted, roles)
	var attached_snapshot: Object = null
	if audited_case != null and audited_case.has_meta(&"generation_audit_snapshot"):
		attached_snapshot = audited_case.get_meta(&"generation_audit_snapshot") as Object
	_add(rows, "Case Audit accepted procedural Case has snapshot", captured and attached and attached_snapshot != null and attached_snapshot.get_script() == AUDIT_SNAPSHOT)
	_add(rows, "Case Audit reuses accepted seed and attempt", captured and audit.root_seed == accepted.root_seed and audit.attempt_index == accepted.accepted_attempt_index and audit.attempt_seed == accepted.accepted_derived_seed and audit.candidate_signature == entry.candidate_signature)
	var expected_evil: PackedInt32Array = PackedInt32Array()
	var accepted_solver: CaseGeneratorSolverResult = null
	var accepted_public_view: GeneratedPublicCaseView = null
	if captured:
		expected_evil = accepted.accepted_candidate.hidden_case_draft.hidden_evil_suspect_ids.duplicate()
		expected_evil.sort()
		accepted_solver = accepted.accepted_solver_result as CaseGeneratorSolverResult
		accepted_public_view = accepted.accepted_public_view as GeneratedPublicCaseView
	_add(rows, "Case Audit hidden Evil set matches generated Case", captured and audit.true_evil_ids == expected_evil)
	_add(rows, "Case Audit solver status and final set match acceptance", captured and accepted_solver != null and audit.solver_status == accepted_solver.status and audit.solver_unique_ids == accepted_solver.unique_evil_suspect_ids and audit.solver_final_sets.size() == accepted_solver.candidate_evil_sets.size() and audit.ground_truth_matches)
	_add(rows, "Case Audit records clue-by-clue hypothesis reduction", captured and accepted_solver != null and audit.solver_initial_count == accepted_solver.initial_candidate_count and audit.solver_remaining_counts == accepted_solver.remaining_candidate_counts and audit.solver_remaining_counts.size() == audit.public_clues.size() and (audit.solver_remaining_counts.is_empty() or audit.solver_remaining_counts[audit.solver_remaining_counts.size() - 1] == accepted_solver.candidate_count))
	_add(rows, "Case Audit raw Evil-set count is exact combinatorics", accepted_public_view != null and audit.solver_raw_evil_set_count == _choose_count(accepted_public_view.suspects.size(), accepted_public_view.public_evil_count))
	_add(rows, "Case Audit copies observed Evil-set snapshots from accepted solve", captured and accepted_solver != null and _evil_set_lists_equal(audit.solver_pre_replay_sets, accepted_solver.pre_replay_evil_sets) and _snapshot_lists_equal(audit.solver_replay_sets_after_clues, accepted_solver.replay_evil_sets_after_clues))
	_add(rows, "Case Audit observed Evil-set snapshots are deduplicated and monotonic", captured and accepted_solver != null and _observed_snapshots_are_monotonic(accepted_solver))
	_add(rows, "Case Audit observed final sets match solver result", captured and accepted_solver != null and _evil_set_lists_equal(audit.solver_final_sets, accepted_solver.candidate_evil_sets) and _last_observed_matches_final(accepted_solver))
	var pretend_separate: bool = false
	if captured:
		for suspect: Dictionary in audit.hidden_suspects:
			if bool(suspect["is_impersonating"]) and suspect["true_role_id"] != suspect["displayed_role_id"] and suspect["displayed_role_id"] == suspect["impersonated_role_id"] and suspect["behavior_role_id"] == suspect["displayed_role_id"]:
				pretend_separate = true
				break
	_add(rows, "Case Audit keeps true and pretended roles separate", pretend_separate)
	var weather = PUBLIC_CLUE.new()
	weather.payload_kind = InvestigationInformationResult.PayloadKind.WEATHER_REPORT
	weather.text = "Số Hiệu 2, 4, 6."
	weather.referenced_suspect_ids = PackedInt32Array([6, 2, 4])
	var weather_view: GeneratedPublicCaseView = PUBLIC_VIEW.create_manual(3, 3, 1, [], [weather])
	var weather_acceptance: CaseGenerationAcceptanceResult = ACCEPTANCE_RESULT.new()
	if captured:
		weather_acceptance.root_seed = accepted.root_seed
		weather_acceptance.mark_success(accepted.accepted_candidate, accepted.accepted_solver_result, accepted.accepted_attempt_index, accepted.accepted_derived_seed, weather_view)
	var weather_audit = AUDIT_SNAPSHOT.new()
	var weather_captured: bool = captured and weather_audit.capture(entry, weather_acceptance, roles)
	_add(rows, "Case Audit Weatherman public references stay numeric and sorted", weather_captured and weather_audit.public_clues.size() == 1 and weather_audit.public_clues[0]["referenced_suspect_ids"] == PackedInt32Array([2, 4, 6]) and weather_audit.public_clues[0]["text"] == weather.text)
	var packed_scene: PackedScene = load("res://scenes/case_gameplay/VSCaseMain.tscn") as PackedScene
	var case_scene: Node = packed_scene.instantiate() if packed_scene != null else null
	var debug_button: Button = null
	var debug_overlay: Control = null
	if case_scene != null:
		debug_button = case_scene.get_node_or_null("%DebugSolverButton") as Button
		debug_overlay = case_scene.get_node_or_null("%SolverInspectionOverlay") as Control
	var audit_lines: PackedStringArray = audit.display_lines() if captured else PackedStringArray()
	_add(rows, "Case Audit dev surface starts hidden", debug_button != null and not debug_button.visible and debug_overlay != null and not debug_overlay.visible and audit_lines.has("[GENERATION]") and audit_lines.has("[HIDDEN TRUTH]") and audit_lines.has("[PUBLIC CLUES]") and audit_lines.has("[SOLVER]") and audit_lines.has("[ACCEPTANCE]") and captured and accepted.fingerprint_text() == original_fingerprint)
	if case_scene != null:
		case_scene.free()
	return rows


func _find_role(case_definition: CaseDefinition, role_id: StringName) -> SuspectDefinition:
	if case_definition == null:
		return null
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect != null and suspect.true_role_id == role_id:
			return suspect
	return null


func _pretend_valid(suspect: SuspectDefinition, case_definition: CaseDefinition, roles: Array[RoleDefinition], good: bool) -> bool:
	if suspect == null or case_definition == null or not suspect.is_impersonating:
		return false
	if suspect.displayed_role_id != suspect.impersonated_role_id or suspect.true_role_id == suspect.displayed_role_id:
		return false
	if suspect.true_alignment != (CaseEnums.Alignment.GOOD if good else CaseEnums.Alignment.EVIL):
		return false
	var target_present: bool = false
	var target_role: RoleDefinition = null
	for other: SuspectDefinition in case_definition.suspects:
		target_present = target_present or (other.suspect_id != suspect.suspect_id and other.true_role_id == suspect.impersonated_role_id)
	for role: RoleDefinition in roles:
		if role != null and role.role_id == suspect.impersonated_role_id:
			target_role = role
			break
	return target_present and CAPABILITY.can_pretend(suspect.true_role_id, target_role)


func _truthful_pretend_info(suspect: SuspectDefinition, info: InvestigationInformationResult) -> bool:
	return suspect != null and info != null and info.behavior_role_id == suspect.impersonated_role_id and info.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL and info.payload_kind != InvestigationInformationResult.PayloadKind.NONE


func _clue_matches_info(candidate: CaseGenerationResult, suspect: SuspectDefinition, info: InvestigationInformationResult) -> bool:
	if candidate == null or not candidate.is_success() or suspect == null or info == null:
		return false
	for clue in candidate.hidden_case_draft.public_clues:
		if clue.suspect_id == suspect.suspect_id:
			return clue.behavior_role_id == info.behavior_role_id and clue.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL and clue.payload_kind == info.payload_kind and clue.numeric_value == info.numeric_value and clue.text == info.public_text()
	return false


func _pretend_target_changes_signature() -> bool:
	var suspect := GeneratedSuspect.new()
	suspect.suspect_id = 1
	suspect.board_slot = 0
	suspect.true_role_id = &"copycat"
	suspect.displayed_role_id = &"reporter"
	suspect.impersonated_role_id = &"reporter"
	suspect.is_impersonating = true
	var first: String = suspect.fingerprint_text()
	suspect.displayed_role_id = &"therapist"
	suspect.impersonated_role_id = &"therapist"
	return first != suspect.fingerprint_text()


func _has_duplicate(counts: Dictionary) -> bool:
	for count: Variant in counts.values():
		if int(count) > 1:
			return true
	return false


func _public_firewall(view: GeneratedPublicCaseView, candidate: CaseGenerationResult) -> bool:
	if view == null or candidate == null or not candidate.is_success():
		return false
	for clue in view.public_clues:
		if not String(clue.true_role_id).is_empty():
			return false
	for suspect in candidate.hidden_case_draft.suspects:
		var matching: bool = false
		for public_suspect in view.suspects:
			matching = matching or (public_suspect.suspect_id == suspect.suspect_id and public_suspect.public_role_id == suspect.displayed_role_id)
		if not matching:
			return false
	return true


func _contains_evil_set(solved: CaseGeneratorSolverResult, candidate: CaseGenerationResult) -> bool:
	if solved == null or candidate == null or not candidate.is_success() or solved.unsupported:
		return false
	for evil_set: PackedInt32Array in solved.candidate_evil_sets:
		if evil_set == candidate.hidden_case_draft.hidden_evil_suspect_ids:
			return true
	return false


func _priest_text_allows_truthful_evil_pretender(roles: Array[RoleDefinition]) -> bool:
	var priest_role: RoleDefinition = null
	var conman_role: RoleDefinition = null
	for role: RoleDefinition in roles:
		if role != null and role.role_id == &"tutorial_priest":
			priest_role = role
		elif role != null and role.role_id == &"conman":
			conman_role = role
	if priest_role == null or conman_role == null or not CAPABILITY.can_pretend(&"conman", priest_role):
		return false
	var case_definition := CaseDefinition.new()
	case_definition.set_meta(&"board_columns", 3)
	case_definition.set_meta(&"board_slot_count", 9)
	var role_pool: Array[StringName] = [&"tutorial_priest", &"conman"]
	case_definition.suspected_role_ids = role_pool
	var priest := SuspectDefinition.new()
	priest.suspect_id = 1
	priest.board_slot = 0
	priest.true_role_id = &"tutorial_priest"
	priest.displayed_role_id = &"tutorial_priest"
	priest.role_group = priest_role.role_group
	priest.true_alignment = CaseEnums.Alignment.GOOD
	var conman := SuspectDefinition.new()
	conman.suspect_id = 2
	conman.board_slot = 1
	conman.true_role_id = &"conman"
	conman.displayed_role_id = &"tutorial_priest"
	conman.role_group = conman_role.role_group
	conman.true_alignment = CaseEnums.Alignment.EVIL
	conman.is_impersonating = true
	conman.impersonated_role_id = &"tutorial_priest"
	case_definition.suspects.append(priest)
	case_definition.suspects.append(conman)
	var evaluator := RoleInformationEvaluationService.new()
	var priest_info: InvestigationInformationResult = evaluator.evaluate(case_definition, 1, roles)
	var conman_info: InvestigationInformationResult = evaluator.evaluate(case_definition, 2, roles)
	if priest_info.public_text() != "Tôi là Tư Tế." or conman_info.public_text() != priest_info.public_text():
		return false
	if priest_info.truth_mode != InvestigationInformationResult.TruthMode.TRUTHFUL or conman_info.truth_mode != InvestigationInformationResult.TruthMode.TRUTHFUL:
		return false
	var public_suspects: Array = [
		PUBLIC_SUSPECT.create(1, 0, &"tutorial_priest", priest_role.role_group),
		PUBLIC_SUSPECT.create(2, 1, &"tutorial_priest", priest_role.role_group),
	]
	var public_clues: Array = [PUBLIC_CLUE.from_information_result(priest_info), PUBLIC_CLUE.from_information_result(conman_info)]
	var view: GeneratedPublicCaseView = PUBLIC_VIEW.create_manual(3, 3, 1, public_suspects, public_clues)
	view.suspected_role_ids = role_pool.duplicate()
	view.allowed_role_ids = role_pool.duplicate()
	var result: CaseGeneratorSolverResult = SOLVER.new().solve(view, roles)
	var evil_one: bool = false
	var evil_two: bool = false
	for evil_set: PackedInt32Array in result.candidate_evil_sets:
		evil_one = evil_one or evil_set == PackedInt32Array([1])
		evil_two = evil_two or evil_set == PackedInt32Array([2])
	return evil_one and evil_two


func _choose_count(item_count: int, selected_count: int) -> int:
	if selected_count < 0 or selected_count > item_count:
		return 0
	var shorter_count: int = mini(selected_count, item_count - selected_count)
	var result: int = 1
	for step: int in range(1, shorter_count + 1):
		result = int(result * (item_count - shorter_count + step) / step)
	return result


func _observed_snapshots_are_monotonic(result: CaseGeneratorSolverResult) -> bool:
	if not _evil_sets_are_unique(result.pre_replay_evil_sets):
		return false
	var previous: Array = result.pre_replay_evil_sets
	for clue_sets: Array in result.replay_evil_sets_after_clues:
		if not _evil_sets_are_unique(clue_sets) or not _evil_sets_are_subset(clue_sets, previous):
			return false
		previous = clue_sets
	return true


func _last_observed_matches_final(result: CaseGeneratorSolverResult) -> bool:
	if result.replay_evil_sets_after_clues.is_empty():
		return _evil_set_lists_equal(result.pre_replay_evil_sets, result.candidate_evil_sets)
	var final_observed: Array = result.replay_evil_sets_after_clues[result.replay_evil_sets_after_clues.size() - 1]
	return _evil_set_lists_equal(final_observed, result.candidate_evil_sets)


func _snapshot_lists_equal(first: Array, second: Array) -> bool:
	if first.size() != second.size():
		return false
	for index: int in range(first.size()):
		var first_sets: Array = first[index]
		var second_sets: Array = second[index]
		if not _evil_set_lists_equal(first_sets, second_sets):
			return false
	return true


func _evil_set_lists_equal(first: Array, second: Array) -> bool:
	if first.size() != second.size():
		return false
	return _evil_set_keys(first) == _evil_set_keys(second)


func _evil_sets_are_unique(sets: Array) -> bool:
	return _evil_set_keys(sets).size() == sets.size()


func _evil_sets_are_subset(subset: Array, superset: Array) -> bool:
	var allowed: Dictionary = _evil_set_keys(superset)
	for key: String in _evil_set_keys(subset).keys():
		if not allowed.has(key):
			return false
	return true


func _evil_set_keys(sets: Array) -> Dictionary:
	var keys: Dictionary = {}
	for ids: PackedInt32Array in sets:
		var parts: PackedStringArray = PackedStringArray()
		for suspect_id: int in ids:
			parts.append(str(suspect_id))
		keys[",".join(parts)] = true
	return keys


func _mobster_suspect() -> SuspectDefinition:
	var suspect := SuspectDefinition.new()
	suspect.true_role_id = &"tutorial_mobster"
	suspect.displayed_role_id = &"reporter"
	suspect.is_impersonating = true
	return suspect


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({"name": name, "passed": passed, "detail": "M6A procedural pretend/truthfulness invariant"})
