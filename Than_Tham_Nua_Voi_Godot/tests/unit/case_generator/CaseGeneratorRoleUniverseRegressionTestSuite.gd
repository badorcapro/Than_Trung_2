extends RefCounted

const REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")
const GENERATOR := preload("res://scripts/domain/cases/CaseGenerator.gd")
const NEXT_CASE_SESSION := preload("res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd")
const PRETEND_CAPABILITY := preload("res://scripts/domain/cases/CaseProceduralPretendCapability.gd")
const PUBLIC_VIEW := preload("res://scripts/domain/cases/GeneratedPublicCaseView.gd")
const PUBLIC_SOLVER := preload("res://scripts/domain/cases/CaseGeneratorPublicSolver.gd")

const FIXTURE_ROLE_IDS: Array[StringName] = [
	&"role_good_a", &"role_good_b", &"role_good_c", &"role_meddler_a",
	&"role_meddler_b", &"role_accomplice_a", &"role_traitor_a",
]


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var production_request: CaseGenerationRequest = NEXT_CASE_SESSION.new()._default_next_case_generation_request()
	var production_roles_clean: bool = true
	for role_id: StringName in production_request.allowed_role_ids:
		production_roles_clean = production_roles_clean and not FIXTURE_ROLE_IDS.has(role_id)
	_add(rows, "M6A-R production true-role pool excludes sample roles", production_roles_clean)
	var fixture_roles_retained: bool = true
	for role_id: StringName in FIXTURE_ROLE_IDS:
		fixture_roles_retained = fixture_roles_retained and _role(roles, role_id) != null
	_add(rows, "M6A-R explicit fixture roles remain available", fixture_roles_retained)
	var pretend_roles_clean: bool = true
	for role_id: StringName in FIXTURE_ROLE_IDS:
		pretend_roles_clean = pretend_roles_clean and not PRETEND_CAPABILITY.can_pretend(&"copycat", _role(roles, role_id))
	_add(rows, "M6A-R production pretend targets exclude sample roles", pretend_roles_clean)

	var mailman_ids: Array[StringName] = [&"mailman", &"tutorial_priest", &"tutorial_mobster"]
	var mailman_case: CaseDefinition = _case_with_roles(roles, mailman_ids)
	mailman_case.suspected_role_ids = production_request.allowed_role_ids.duplicate()
	mailman_case.suspects[2].displayed_role_id = &"reporter"
	mailman_case.suspects[2].impersonated_role_id = &"reporter"
	mailman_case.suspects[2].is_impersonating = true
	var evaluator := RoleInformationEvaluationService.new()
	var mailman: InvestigationInformationResult = evaluator.evaluate(mailman_case, 1, roles)
	var absent_ids: Array[StringName] = evaluator.true_role_ids_not_in_play(mailman_case, roles, &"mailman")
	var mailman_valid: Dictionary = evaluator.validate_mailman_pair(mailman_case, 1, mailman.in_play_role_id, mailman.not_in_play_role_id, mailman.truth_mode, roles)
	_add(rows, "M6A-R Mailman absent universe follows Case production pool", not absent_ids.is_empty() and _all_in_pool(absent_ids, production_request.allowed_role_ids) and not _has_fixture_id(absent_ids))
	_add(rows, "M6A-R Mailman announces canonical present and absent roles", bool(mailman_valid.get("valid", false)) and not FIXTURE_ROLE_IDS.has(mailman.not_in_play_role_id) and mailman.in_play_role_id != &"mailman" and mailman.not_in_play_role_id != &"mailman")
	var displayed_only_claim: Dictionary = evaluator.validate_mailman_pair(mailman_case, 1, &"reporter", mailman.not_in_play_role_id, InvestigationInformationResult.TruthMode.TRUTHFUL, roles)
	_add(rows, "M6A-R Mailman does not count displayed disguise as present", not bool(displayed_only_claim.get("valid", true)) and not bool(displayed_only_claim.get("in_play_truth", true)))
	var current_roles_for_mailman := CaseRuntimeState.new()
	current_roles_for_mailman.suspects.append(SuspectRuntimeState.new(2, &"therapist"))
	var current_mailman: InvestigationInformationResult = evaluator.evaluate(mailman_case, 1, roles, {}, current_roles_for_mailman)
	var transformed_pair: Dictionary = evaluator.validate_mailman_pair_current(mailman_case, current_roles_for_mailman, 1, &"therapist", &"tutorial_priest", InvestigationInformationResult.TruthMode.TRUTHFUL, roles)
	_add(rows, "M6A-R runtime Mailman uses current roles, not old or displayed roles", bool(transformed_pair.get("valid", false)) and current_mailman.claimed_in_play_is_true and current_mailman.claimed_not_in_play_is_true and not FIXTURE_ROLE_IDS.has(current_mailman.not_in_play_role_id))
	var fully_used_ids: Array[StringName] = mailman_ids.duplicate()
	mailman_case.suspected_role_ids = fully_used_ids
	var fallback_mailman: InvestigationInformationResult = evaluator.evaluate(mailman_case, 1, roles)
	_add(rows, "M6A-R exhausted Case pool falls back to real roles only", not String(fallback_mailman.not_in_play_role_id).is_empty() and not FIXTURE_ROLE_IDS.has(fallback_mailman.not_in_play_role_id) and not fully_used_ids.has(fallback_mailman.not_in_play_role_id))
	var full_ids: Array[StringName] = [&"mailman", &"tutorial_priest", &"reporter", &"therapist", &"weatherman", &"blood_hound", &"mathematician", &"role_meddler_a", &"tutorial_mobster"]
	var full_case: CaseDefinition = _case_with_roles(roles, full_ids)
	full_case.set_meta(&"board_columns", 4)
	full_case.set_meta(&"board_rows", 4)
	full_case.set_meta(&"board_slot_count", 16)
	full_case.suspected_role_ids = full_ids.duplicate()
	full_case.suspected_role_ids.append(&"copycat")
	var full_mailman: InvestigationInformationResult = evaluator.evaluate(full_case, 1, roles)
	_add(rows, "M6A-R nine-suspect 4x4 Mailman uses spare absent role", full_mailman.not_in_play_role_id == &"copycat" and not FIXTURE_ROLE_IDS.has(full_mailman.not_in_play_role_id))

	var generator = GENERATOR.new()
	var locations: Array[StringName] = [BoardLocationDefinition.LOCATION_CRIME_SCENE]
	var without_meddler_ids: Array[StringName] = [&"weatherman", &"tutorial_priest", &"reporter", &"therapist", &"tutorial_mobster"]
	var without_meddler: CaseGenerationRequest = REQUEST.create(112233, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY, without_meddler_ids, locations, 5)
	var rejected: CaseGenerationResult = generator.generate(without_meddler, roles)
	_add(rows, "M6A-R true Weatherman without Meddler is rejected", rejected != null and not rejected.is_success() and rejected.error_code == CaseGenerationResult.ERROR_IMPOSSIBLE_REQUEST)
	var with_meddler_ids: Array[StringName] = [&"weatherman", &"copycat", &"tutorial_priest", &"reporter", &"tutorial_mobster"]
	var with_meddler: CaseGenerationRequest = REQUEST.create(112233, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY, with_meddler_ids, locations, 5)
	var generated: CaseGenerationResult = generator.generate(with_meddler, roles)
	var generated_case: CaseDefinition = generator.case_definition_from_result(generated)
	var generated_weatherman: SuspectDefinition = _find_true_role(generated_case, &"weatherman")
	var generated_info: InvestigationInformationResult = evaluator.evaluate(generated_case, generated_weatherman.suspect_id, roles) if generated_weatherman != null else null
	_add(rows, "M6A-R true Weatherman with actual Copycat Meddler can generate", generated != null and generated.is_success() and generated_weatherman != null and _find_true_role(generated_case, &"copycat") != null)
	_add(rows, "M6A-R generated true Weatherman never uses no-Meddler form", generated_info != null and generated_info.payload_kind == InvestigationInformationResult.PayloadKind.WEATHER_REPORT and generated_info.weather_claim_complete and generated_info.weather_suspect_ids.size() == 3)
	_add(rows, "M6A-R generated truthful Weatherman has three true categories", generated_info != null and evaluator.weatherman_claim_matches_truthful_pattern(generated_case, generated_info) and not generated_info.weather_suspect_ids.has(generated_weatherman.suspect_id))
	var generated_roles_clean: bool = generated_case != null
	if generated_case != null:
		for candidate: SuspectDefinition in generated_case.suspects:
			generated_roles_clean = generated_roles_clean and not FIXTURE_ROLE_IDS.has(candidate.true_role_id) and not FIXTURE_ROLE_IDS.has(candidate.displayed_role_id)
	_add(rows, "M6A-R generated true and displayed roles stay canonical", generated_roles_clean)
	var baseline_view: GeneratedPublicCaseView = PUBLIC_VIEW.from_generation_result(generated, roles)
	var reordered_view: GeneratedPublicCaseView = PUBLIC_VIEW.from_generation_result(generated, roles)
	var public_groups_hidden: bool = false
	for clue: GeneratedPublicClue in baseline_view.public_clues:
		if clue.behavior_role_id == &"weatherman" and clue.payload_kind == InvestigationInformationResult.PayloadKind.WEATHER_REPORT:
			var sorted_public_ids: PackedInt32Array = clue.referenced_suspect_ids.duplicate()
			sorted_public_ids.sort()
			public_groups_hidden = clue.weather_group_slots.is_empty() and clue.referenced_suspect_ids == sorted_public_ids
			break
	var reordered_clue: GeneratedPublicClue = null
	for clue: GeneratedPublicClue in reordered_view.public_clues:
		if clue.behavior_role_id == &"weatherman" and clue.payload_kind == InvestigationInformationResult.PayloadKind.WEATHER_REPORT:
			reordered_clue = clue
			break
	var reordered_ids: bool = reordered_clue != null and reordered_clue.referenced_suspect_ids.size() == 3
	if reordered_ids:
		var original_ids: PackedInt32Array = reordered_clue.referenced_suspect_ids.duplicate()
		reordered_clue.referenced_suspect_ids = PackedInt32Array([original_ids[2], original_ids[0], original_ids[1]])
		reordered_clue.weather_group_slots = PackedInt32Array([99, 99, 99])
	var baseline_solution: CaseGeneratorSolverResult = PUBLIC_SOLVER.new().solve(baseline_view, roles) as CaseGeneratorSolverResult
	var reordered_solution: CaseGeneratorSolverResult = PUBLIC_SOLVER.new().solve(reordered_view, roles) as CaseGeneratorSolverResult
	_add(rows, "M6A-R Weatherman solver treats announced IDs as an unordered set", reordered_ids and public_groups_hidden and baseline_solution != null and reordered_solution != null and baseline_solution.candidate_count > 0 and baseline_solution.fingerprint_text() == reordered_solution.fingerprint_text())
	var repeated: CaseGenerationResult = generator.generate(with_meddler, roles)
	var repeated_case: CaseDefinition = generator.case_definition_from_result(repeated)
	var repeated_weatherman: SuspectDefinition = _find_true_role(repeated_case, &"weatherman")
	var repeated_info: InvestigationInformationResult = evaluator.evaluate(repeated_case, repeated_weatherman.suspect_id, roles) if repeated_weatherman != null else null
	_add(rows, "M6A-R same seed keeps Weatherman clue deterministic", generated != null and repeated != null and generated.is_success() and repeated.is_success() and generated.fingerprint == repeated.fingerprint and generated_info != null and repeated_info != null and generated_info.public_text() == repeated_info.public_text())

	var weather_ids: Array[StringName] = [&"copycat", &"weatherman", &"tutorial_priest", &"reporter", &"conman"]
	var weather_case: CaseDefinition = _case_with_roles(roles, weather_ids)
	weather_case.suspects[0].displayed_role_id = &"weatherman"
	weather_case.suspects[0].impersonated_role_id = &"weatherman"
	weather_case.suspects[0].is_impersonating = true
	weather_case.suspects[4].displayed_role_id = &"weatherman"
	weather_case.suspects[4].impersonated_role_id = &"weatherman"
	weather_case.suspects[4].is_impersonating = true
	var true_weather: InvestigationInformationResult = evaluator.evaluate(weather_case, 2, roles)
	var copycat_weather: InvestigationInformationResult = evaluator.evaluate(weather_case, 1, roles)
	var conman_weather: InvestigationInformationResult = evaluator.evaluate(weather_case, 5, roles)
	_add(rows, "M6A-R Weatherman text sorts unsorted semantic picks", true_weather.weather_suspect_ids == PackedInt32Array([3, 5, 1]) and true_weather.public_text() == "Ta thấy Số Hiệu 1, 3 và 5.")
	var reordered_truth: InvestigationInformationResult = true_weather.duplicate_result()
	reordered_truth.weather_suspect_ids = PackedInt32Array([1, 3, 5])
	var duplicate_truth: InvestigationInformationResult = true_weather.duplicate_result()
	duplicate_truth.weather_suspect_ids = PackedInt32Array([3, 3, 5])
	var wrong_groups: InvestigationInformationResult = true_weather.duplicate_result()
	wrong_groups.weather_suspect_ids = PackedInt32Array([3, 4, 5])
	_add(rows, "M6A-R Weatherman true groups are one each regardless of order or disguise", evaluator.weatherman_claim_matches_truthful_pattern(weather_case, true_weather) and evaluator.weatherman_claim_matches_truthful_pattern(weather_case, reordered_truth) and not evaluator.weatherman_claim_matches_truthful_pattern(weather_case, duplicate_truth) and not evaluator.weatherman_claim_matches_truthful_pattern(weather_case, wrong_groups))
	_add(rows, "M6A-R true Weatherman excludes itself", true_weather.weather_suspect_ids == PackedInt32Array([3, 5, 1]))
	_add(rows, "M6A-R Copycat Weatherman is truthful and may name itself", copycat_weather.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL and copycat_weather.weather_suspect_ids == PackedInt32Array([2, 5, 1]))
	_add(rows, "M6A-R Evil Conman Weatherman is truthful and may name itself", conman_weather.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL and conman_weather.weather_suspect_ids == PackedInt32Array([2, 5, 1]))
	var current_roles := CaseRuntimeState.new()
	var transformed_priest := SuspectRuntimeState.new(3, &"tutorial_priest")
	transformed_priest.current_role_id = &"copycat"
	current_roles.suspects.append(transformed_priest)
	var current_weather: InvestigationInformationResult = evaluator.evaluate(weather_case, 2, roles, {}, current_roles)
	_add(rows, "M6A-R Weatherman groups follow current role not displayed role", current_weather.weather_suspect_ids == PackedInt32Array([4, 5, 1]) and current_weather.weather_group_slots == PackedInt32Array([CaseEnums.RoleGroup.CHINH_NHAN, CaseEnums.RoleGroup.TONG_PHAM, CaseEnums.RoleGroup.HIEU_SU]))
	weather_case.suspects[1].is_corrupted = true
	var tainted_weather: InvestigationInformationResult = evaluator.evaluate(weather_case, 2, roles)
	_add(rows, "M6A-R tainted Weatherman names only Innocent or Meddler", tainted_weather.truth_mode == InvestigationInformationResult.TruthMode.LYING and _benign_weather_ids(weather_case, tainted_weather))
	weather_case.suspects[4].true_role_id = &"tutorial_mobster"
	weather_case.suspects[4].role_group = CaseEnums.RoleGroup.TONG_PHAM
	var lying_weather: InvestigationInformationResult = evaluator.evaluate(weather_case, 5, roles)
	_add(rows, "M6A-R lying Weatherman names only Innocent or Meddler", lying_weather.truth_mode == InvestigationInformationResult.TruthMode.LYING and _benign_weather_ids(weather_case, lying_weather))
	return rows


func _case_with_roles(roles: Array[RoleDefinition], role_ids: Array[StringName]) -> CaseDefinition:
	var case_definition := CaseDefinition.new()
	for index: int in range(role_ids.size()):
		var role: RoleDefinition = _role(roles, role_ids[index])
		var suspect := SuspectDefinition.new()
		suspect.suspect_id = index + 1
		suspect.board_slot = index
		suspect.true_role_id = role_ids[index]
		suspect.displayed_role_id = role_ids[index]
		suspect.role_group = role.role_group
		suspect.true_alignment = CaseRolePoolService.role_alignment(role)
		case_definition.suspects.append(suspect)
	return case_definition


func _role(roles: Array[RoleDefinition], role_id: StringName) -> RoleDefinition:
	for role: RoleDefinition in roles:
		if role != null and role.role_id == role_id:
			return role
	return null


func _find_true_role(case_definition: CaseDefinition, role_id: StringName) -> SuspectDefinition:
	if case_definition != null:
		for suspect: SuspectDefinition in case_definition.suspects:
			if suspect != null and suspect.true_role_id == role_id:
				return suspect
	return null


func _all_in_pool(ids: Array[StringName], pool: Array[StringName]) -> bool:
	for role_id: StringName in ids:
		if not pool.has(role_id):
			return false
	return true


func _has_fixture_id(ids: Array[StringName]) -> bool:
	for role_id: StringName in ids:
		if FIXTURE_ROLE_IDS.has(role_id):
			return true
	return false


func _benign_weather_ids(case_definition: CaseDefinition, result: InvestigationInformationResult) -> bool:
	if result == null or not result.weather_claim_complete or result.weather_suspect_ids.size() != 3:
		return false
	for suspect_id: int in result.weather_suspect_ids:
		var suspect: SuspectDefinition = null
		for candidate: SuspectDefinition in case_definition.suspects:
			if candidate != null and candidate.suspect_id == suspect_id:
				suspect = candidate
				break
		if suspect == null or (suspect.role_group != CaseEnums.RoleGroup.CHINH_NHAN and suspect.role_group != CaseEnums.RoleGroup.HIEU_SU):
			return false
	return true


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({"name": name, "passed": passed, "detail": "M6A role-universe and Weatherman regression"})
