extends RefCounted

const REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")
const GENERATOR := preload("res://scripts/domain/cases/CaseGenerator.gd")
const PUBLIC_VIEW := preload("res://scripts/domain/cases/GeneratedPublicCaseView.gd")
const PUBLIC_CLUE := preload("res://scripts/domain/cases/GeneratedPublicClue.gd")
const SOLVER := preload("res://scripts/domain/cases/CaseGeneratorPublicSolver.gd")
const ACCEPTANCE := preload("res://scripts/domain/cases/CaseGenerationAcceptanceService.gd")
const PRETEND := preload("res://scripts/domain/cases/CaseProceduralPretendCapability.gd")
const NEXT_CASE := preload("res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd")
const AUDIT := preload("res://scripts/tools/CaseGenerationAuditSnapshot.gd")


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var ids: Array[StringName] = [&"clock_maker", &"tutorial_priest", &"reporter", &"therapist", &"tutorial_scoundrel"]
	var request: CaseGenerationRequest = _request(ids)
	var generator = GENERATOR.new()
	var candidate: CaseGenerationResult = generator.generate(request, roles)
	var definition: CaseDefinition = generator.case_definition_from_result(candidate)
	var owner: SuspectDefinition = _owner(definition)
	var tower: ClockTowerDefinition = ClockTowerService.clock_tower_for_case(definition)
	var view: GeneratedPublicCaseView = PUBLIC_VIEW.from_generation_result(candidate, roles)
	var clue: GeneratedPublicClue = _clock_clue(view)
	var validation: Dictionary = CaseDefinitionValidator.new().validate(definition, roles, FixtureRepository.load_players())
	_add(rows, "Slice 5 native Clock Maker and tower form a valid bounded Case", (
		candidate.is_success() and bool(validation.get("passed", false))
		and owner != null and tower != null and definition.suspects.size() == 5
		and definition.location_definitions().size() == 2
		and definition.evil_suspect_ids.size() <= 3
		and owner.true_alignment == CaseEnums.Alignment.GOOD
		and owner.role_group == CaseEnums.RoleGroup.CHINH_NHAN
		and owner.displayed_role_id == &"clock_maker" and not owner.is_impersonating
	))
	var repeated: CaseGenerationResult = generator.generate(request, roles)
	var repeated_view: GeneratedPublicCaseView = PUBLIC_VIEW.from_generation_result(repeated, roles)
	_add(rows, "Slice 5 same seed preserves schedule placement and structured interval", (
		candidate.is_success() and repeated.is_success() and candidate.fingerprint == repeated.fingerprint
		and candidate.hidden_case_draft.clock_tower_ring_hour == repeated.hidden_case_draft.clock_tower_ring_hour
		and view.fingerprint_text() == repeated_view.fingerprint_text()
	))
	_add(rows, "Slice 5 truthful interval is exactly two ringing hours", (
		clue != null and tower != null and clue.clock_claims_ringing
		and clue.clock_start_hour == tower.ring_hour and clue.clock_end_hour == tower.ring_hour + 1
		and ClockTowerService.hour_is_ringing(tower, clue.clock_start_hour)
		and ClockTowerService.hour_is_ringing(tower, clue.clock_end_hour)
	))
	_add(rows, "Slice 5 authored corruption changes announcement not ring schedule", _authored_taint(definition, roles))
	_add(rows, "Slice 5 runtime Poisoner taint uses effective truth without stale carryover", _runtime_taint(definition, roles))
	_add(rows, "Slice 5 normal investigation exposes automatic Clock Maker clue", _automatic_clue(definition, roles))

	var solved: CaseGeneratorSolverResult = SOLVER.new().solve(view, roles)
	_add(rows, "Slice 5 solver supports native self-confirming Clock Maker", (
		owner != null and solved.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION
		and not solved.unique_evil_suspect_ids.has(owner.suspect_id)
		and solved.unique_evil_suspect_ids == definition.evil_suspect_ids
	))
	_add(rows, "Slice 5 solver rejects incompatible interval and truth-mode claims", _incompatible_clues(candidate, roles))
	_add(rows, "Slice 5 solver rejects missing or suspect-overlapping Clock Tower", _invalid_tower(candidate, roles))
	_add(rows, "Slice 5 public replay does not read hidden clock schedule or answer", _hidden_independence(candidate, roles))
	_add(rows, "Slice 5 listed absent Clock Maker still requires a tower", _listed_only(roles))
	var capacity_ids: Array[StringName] = [&"clock_maker", &"tutorial_priest", &"reporter", &"therapist", &"tutorial_scoundrel", &"mathematician", &"tailor", &"vigilante"]
	var capacity_result: CaseGenerationResult = generator.generate(_request(capacity_ids), roles)
	_add(rows, "Slice 5 eight suspects plus Crime Scene and mandatory tower reject normally", (
		not capacity_result.is_success() and capacity_result.error_code == CaseGenerationResult.ERROR_IMPOSSIBLE_REQUEST
	))

	var accepted: CaseGenerationAcceptanceResult = ACCEPTANCE.new().accept_unique_candidate(request, roles)
	var evidence: String = _accepted_evidence(accepted, generator)
	var acceptance_ok: bool = false
	if accepted != null and accepted.success:
		var accepted_solver: CaseGeneratorSolverResult = accepted.accepted_solver_result as CaseGeneratorSolverResult
		acceptance_ok = accepted_solver != null and accepted_solver.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION and accepted_solver.ground_truth_checked and accepted_solver.unique_solution_matches_ground_truth
	_add(rows, "Slice 5 normal acceptance retains UNIQUE and ground-truth match", acceptance_ok and not evidence.is_empty(), evidence)
	if not evidence.is_empty():
		print("SLICE5_CLOCK_EVIDENCE " + evidence)
	_add(rows, "Slice 5 retained warehouse audit shows hidden schedule without re-solving", _audit_snapshot(request, accepted, roles))
	var ambiguous_ids: Array[StringName] = [&"clock_maker", &"tutorial_priest", &"conman"]
	var rejected: CaseGenerationAcceptanceResult = ACCEPTANCE.new().accept_unique_candidate(_request(ambiguous_ids), roles, 2)
	_add(rows, "Slice 5 ambiguous Clock Maker Case retries without bypass", (
		not rejected.success and rejected.accepted_candidate == null
		and int(rejected.rejected_status_counts.get(ACCEPTANCE.REJECTION_MULTIPLE_SOLUTIONS, 0)) == 2
	))
	_add(rows, "Slice 5 production enables Clock Maker only for approved disguise sources", _capabilities(roles))
	_add(rows, "Slice 5 Tutorial 07 keeps authored eight-nine ringing and announcement", _tutorial_07(roles))
	_add(rows, "Slice 5 generated Poisoner Clock Maker clue survives public solver replay", _generated_taint(roles))
	_add(rows, "Disguise Slice B Mobster Clock Maker reaches UNIQUE acceptance", _clock_disguise_evidence(roles, &"tutorial_mobster"))
	_add(rows, "Disguise Slice B Copycat Clock Maker preserves native witness and truthful replay", _clock_disguise_evidence(roles, &"copycat"))
	_add(rows, "Disguise Slice B Critic Clock Maker stays listed and current-absent", _clock_disguise_evidence(roles, &"critic"))
	return rows


func _request(ids: Array[StringName], seed: int = 112233) -> CaseGenerationRequest:
	var locations: Array[StringName] = [BoardLocationDefinition.LOCATION_CRIME_SCENE]
	return REQUEST.create(seed, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY, ids, locations, ids.size())


func _owner(definition: CaseDefinition) -> SuspectDefinition:
	if definition != null:
		for suspect: SuspectDefinition in definition.suspects:
			if suspect.true_role_id == &"clock_maker":
				return suspect
	return null


func _clock_clue(view: GeneratedPublicCaseView) -> GeneratedPublicClue:
	for clue in view.public_clues:
		if clue.behavior_role_id == &"clock_maker":
			return clue as GeneratedPublicClue
	return null


func _authored_taint(source: CaseDefinition, roles: Array[RoleDefinition]) -> bool:
	if source == null:
		return false
	var definition: CaseDefinition = source.duplicate(true) as CaseDefinition
	var owner: SuspectDefinition = _owner(definition)
	var tower: ClockTowerDefinition = ClockTowerService.clock_tower_for_case(definition)
	if owner == null or tower == null:
		return false
	var before: int = tower.ring_hour
	owner.is_corrupted = true
	var info: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(definition, owner.suspect_id, roles)
	var clue: GeneratedPublicClue = PUBLIC_CLUE.from_information_result(info)
	return info.truth_mode == InvestigationInformationResult.TruthMode.LYING and not clue.clock_claims_ringing and clue.clock_end_hour == clue.clock_start_hour + 1 and ClockTowerService.false_interval_is_valid(tower, clue.clock_start_hour) and tower.ring_hour == before


func _runtime_taint(source: CaseDefinition, roles: Array[RoleDefinition]) -> bool:
	if source == null:
		return false
	var definition: CaseDefinition = source.duplicate(true) as CaseDefinition
	var owner: SuspectDefinition = _owner(definition)
	if owner == null:
		return false
	var poisoner: SuspectDefinition = _adjacent_poisoner_fixture(definition, owner)
	if poisoner == null:
		return false
	poisoner.true_role_id = &"poisoner"
	poisoner.displayed_role_id = &"poisoner"
	poisoner.impersonated_role_id = &""
	poisoner.is_impersonating = false
	poisoner.role_group = CaseEnums.RoleGroup.TONG_PHAM
	poisoner.true_alignment = CaseEnums.Alignment.EVIL
	owner.is_corrupted = false
	var tower: ClockTowerDefinition = ClockTowerService.clock_tower_for_case(definition)
	if tower == null:
		return false
	var original_ring_hour: int = tower.ring_hour
	var original_statement: String = owner.public_investigation_statement
	var evaluator := RoleInformationEvaluationService.new()
	var clean := CaseRuntimeState.new()
	clean.initialize(definition, FixtureRepository.load_players())
	var clean_information: InvestigationInformationResult = evaluator.evaluate(
		definition, owner.suspect_id, roles, {}, clean
	)
	var clean_clue: GeneratedPublicClue = PUBLIC_CLUE.from_information_result(clean_information)
	var clean_clue_fingerprint: String = clean_clue.fingerprint_text()
	var runtime := CaseRuntimeState.new()
	runtime.initialize(definition, FixtureRepository.load_players())
	var record: PoisonerTaintRecord = PoisonerTaintService.new().resolve_taint(
		definition, runtime, poisoner.suspect_id, owner.suspect_id
	)
	var tainted: InvestigationInformationResult = evaluator.evaluate(definition, owner.suspect_id, roles, {}, runtime)
	var fresh := CaseRuntimeState.new()
	fresh.initialize(definition, FixtureRepository.load_players())
	var truthful: InvestigationInformationResult = evaluator.evaluate(definition, owner.suspect_id, roles, {}, fresh)
	return (
		clean_information.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL
		and clean_information.numeric_value == original_ring_hour
		and record != null and record.applied
		and runtime.has_runtime_corruption(owner.suspect_id)
		and tainted.truth_mode == InvestigationInformationResult.TruthMode.LYING
		and ClockTowerService.false_interval_is_valid(tower, tainted.numeric_value)
		and not fresh.has_runtime_corruption(owner.suspect_id)
		and fresh.poisoner_taint_records.is_empty()
		and truthful.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL
		and truthful.numeric_value == original_ring_hour
		and tower.ring_hour == original_ring_hour
		and owner.public_investigation_statement == original_statement
		and clean_clue.fingerprint_text() == clean_clue_fingerprint
	)


func _adjacent_poisoner_fixture(
	definition: CaseDefinition,
	owner: SuspectDefinition
) -> SuspectDefinition:
	var spatial := CaseSpatialService.new()
	for suspect: SuspectDefinition in definition.suspects:
		if (
			suspect.suspect_id != owner.suspect_id
			and spatial.are_surrounding_neighbours_for_case(
				definition, suspect.board_slot, owner.board_slot
			)
		):
			return suspect
	var source: SuspectDefinition = null
	for suspect: SuspectDefinition in definition.suspects:
		if suspect.suspect_id != owner.suspect_id:
			source = suspect
			break
	if source == null:
		return null
	var source_slot: int = source.board_slot
	for target_slot: int in spatial.surrounding_neighbour_slots(owner.board_slot):
		var occupied_by_suspect: bool = false
		for suspect: SuspectDefinition in definition.suspects:
			if suspect.suspect_id != source.suspect_id and suspect.board_slot == target_slot:
				occupied_by_suspect = true
				break
		if occupied_by_suspect:
			continue
		if definition.crime_scene != null and definition.crime_scene.board_slot == target_slot:
			definition.crime_scene.board_slot = source_slot
		else:
			for location: BoardLocationDefinition in definition.board_locations:
				if location != null and location.board_slot == target_slot:
					location.board_slot = source_slot
					break
		source.board_slot = target_slot
		return source
	return null


func _automatic_clue(definition: CaseDefinition, roles: Array[RoleDefinition]) -> bool:
	var owner: SuspectDefinition = _owner(definition)
	if owner == null:
		return false
	var runtime := CaseRuntimeState.new()
	runtime.initialize(definition, FixtureRepository.load_players())
	for player: PlayerCaseState in runtime.players:
		runtime.turn_order_player_ids.append(player.player_id)
	var investigated: InvestigationResult = InvestigationService.new().investigate(definition, runtime, owner.suspect_id, runtime.current_player_id())
	if not investigated.success:
		return false
	for card: SuspectPublicViewData in CasePublicPresentationBuilder.new().build_suspect_views(definition, runtime, roles):
		if card.suspect_id == owner.suspect_id:
			return card.is_investigated and not card.public_investigation_statement.is_empty() and runtime.public_function_records.is_empty() and runtime.elapsed_hours == 0
	return false


func _incompatible_clues(candidate: CaseGenerationResult, roles: Array[RoleDefinition]) -> bool:
	var view: GeneratedPublicCaseView = PUBLIC_VIEW.from_generation_result(candidate, roles)
	var clue: GeneratedPublicClue = _clock_clue(view)
	if clue == null:
		return false
	clue.clock_end_hour += 1
	var malformed: CaseGeneratorSolverResult = SOLVER.new().solve(view, roles)
	clue.clock_end_hour -= 1
	clue.clock_claims_ringing = false
	var incompatible: CaseGeneratorSolverResult = SOLVER.new().solve(view, roles)
	return malformed.status == CaseGeneratorSolverResult.STATUS_NO_SOLUTION and incompatible.status == CaseGeneratorSolverResult.STATUS_NO_SOLUTION


func _invalid_tower(candidate: CaseGenerationResult, roles: Array[RoleDefinition]) -> bool:
	var view: GeneratedPublicCaseView = PUBLIC_VIEW.from_generation_result(candidate, roles)
	if view.suspects.is_empty():
		return false
	view.clock_tower_slot = -1
	var missing: CaseGeneratorSolverResult = SOLVER.new().solve(view, roles)
	view.clock_tower_slot = view.suspects[0].board_slot
	var overlapping: CaseGeneratorSolverResult = SOLVER.new().solve(view, roles)
	return missing.status == CaseGeneratorSolverResult.STATUS_NO_SOLUTION and overlapping.status == CaseGeneratorSolverResult.STATUS_NO_SOLUTION


func _hidden_independence(candidate: CaseGenerationResult, roles: Array[RoleDefinition]) -> bool:
	if candidate.hidden_case_draft == null:
		return false
	var before: GeneratedPublicCaseView = PUBLIC_VIEW.from_generation_result(candidate, roles)
	var old_hour: int = candidate.hidden_case_draft.clock_tower_ring_hour
	var old_ids: PackedInt32Array = candidate.hidden_case_draft.hidden_evil_suspect_ids.duplicate()
	candidate.hidden_case_draft.clock_tower_ring_hour = 1 if old_hour != 1 else 23
	candidate.hidden_case_draft.hidden_evil_suspect_ids.clear()
	var after: GeneratedPublicCaseView = PUBLIC_VIEW.from_generation_result(candidate, roles)
	candidate.hidden_case_draft.clock_tower_ring_hour = old_hour
	candidate.hidden_case_draft.hidden_evil_suspect_ids = old_ids
	var solved: CaseGeneratorSolverResult = SOLVER.new().solve(after, roles)
	return before.fingerprint_text() == after.fingerprint_text() and solved.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION and solved.unique_evil_suspect_ids == old_ids


func _listed_only(roles: Array[RoleDefinition]) -> bool:
	var ids: Array[StringName] = [&"tutorial_priest", &"reporter", &"therapist", &"mathematician", &"tutorial_scoundrel", &"clock_maker"]
	var request: CaseGenerationRequest = _request(ids)
	request.required_suspect_count = 5
	var generator = GENERATOR.new()
	for seed: int in range(112233, 112297):
		request.seed = seed
		var candidate: CaseGenerationResult = generator.generate(request, roles)
		var definition: CaseDefinition = generator.case_definition_from_result(candidate)
		if definition != null and _owner(definition) == null:
			return definition.suspected_role_ids.has(&"clock_maker") and ClockTowerService.has_clock_tower(definition)
	return false


func _capabilities(roles: Array[RoleDefinition]) -> bool:
	var ids: Array[StringName] = NEXT_CASE.new()._default_next_case_generation_request().allowed_role_ids
	var clock_role: RoleDefinition = null
	for role: RoleDefinition in roles:
		if role.role_id == &"clock_maker":
			clock_role = role
	if clock_role == null or not ids.has(&"clock_maker") or not SOLVER.SUPPORTED_PUBLIC_ROLE_IDS.has(&"clock_maker"):
		return false
	for source_id: StringName in [&"copycat", &"tutorial_mobster", &"mobster", &"critic", &"serial_killer"]:
		if not PRETEND.can_pretend(source_id, clock_role):
			return false
	for source_id: StringName in [&"conman", &"poisoner", &"barkeep", &"spectre"]:
		if PRETEND.can_pretend(source_id, clock_role):
			return false
	for deferred_id: StringName in [&"drunkard"]:
		if ids.has(deferred_id):
			return false
	return true


func _tutorial_07(roles: Array[RoleDefinition]) -> bool:
	var definition: CaseDefinition = load("res://content/cases/fixtures/tutorial_case_007.tres") as CaseDefinition
	var owner: SuspectDefinition = _owner(definition)
	var tower: ClockTowerDefinition = ClockTowerService.clock_tower_for_case(definition)
	if owner == null or tower == null:
		return false
	var info: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(definition, owner.suspect_id, roles)
	return tower.ring_hour == 8 and info.numeric_value == 8 and info.public_text() == "Tháp Đồng Hồ sẽ reo từ 8h đến 9h."


func _generated_taint(roles: Array[RoleDefinition]) -> bool:
	var ids: Array[StringName] = [&"clock_maker", &"tutorial_priest", &"reporter", &"therapist", &"poisoner"]
	var generator = GENERATOR.new()
	for seed: int in range(112233, 112297):
		var candidate: CaseGenerationResult = generator.generate(_request(ids, seed), roles)
		var definition: CaseDefinition = generator.case_definition_from_result(candidate)
		var owner: SuspectDefinition = _owner(definition)
		if owner == null or candidate.hidden_case_draft.poisoner_taint_target_suspect_id != owner.suspect_id:
			continue
		var view: GeneratedPublicCaseView = PUBLIC_VIEW.from_generation_result(candidate, roles)
		var clue: GeneratedPublicClue = _clock_clue(view)
		var solved: CaseGeneratorSolverResult = SOLVER.new().solve(view, roles)
		var contains_truth: bool = false
		for evil_ids: PackedInt32Array in solved.candidate_evil_sets:
			contains_truth = contains_truth or evil_ids == definition.evil_suspect_ids
		return clue != null and not clue.clock_claims_ringing and ClockTowerService.false_interval_is_valid(ClockTowerService.clock_tower_for_case(definition), clue.clock_start_hour) and contains_truth
	return false


func _clock_disguise_evidence(
	roles: Array[RoleDefinition],
	source_role_id: StringName
) -> bool:
	var request: CaseGenerationRequest = _clock_disguise_request(source_role_id)
	var accepted: CaseGenerationAcceptanceResult = ACCEPTANCE.new().accept_unique_candidate(
		request, roles, 1
	)
	if accepted == null or not accepted.success or accepted.accepted_candidate == null:
		return false
	var candidate: CaseGenerationResult = accepted.accepted_candidate as CaseGenerationResult
	var definition: CaseDefinition = GENERATOR.new().case_definition_from_result(candidate)
	var owner: SuspectDefinition = _role_suspect(definition, source_role_id)
	var tower: ClockTowerDefinition = ClockTowerService.clock_tower_for_case(definition)
	var clue: GeneratedPublicClue = _clue_for_suspect(candidate, owner.suspect_id if owner != null else 0)
	var solver: CaseGeneratorSolverResult = accepted.accepted_solver_result as CaseGeneratorSolverResult
	var public_view: GeneratedPublicCaseView = accepted.accepted_public_view as GeneratedPublicCaseView
	if owner == null or tower == null or clue == null or solver == null or public_view == null:
		return false
	var runtime := CaseRuntimeState.new()
	var no_players: Array[PlayerCaseState] = []
	runtime.initialize(definition, no_players)
	var current_clock_count: int = 0
	for role_id: StringName in CaseRolePoolService.current_role_ids_in_play(definition, runtime):
		if role_id == &"clock_maker":
			current_clock_count += 1
	var expected_truth_mode: int = InvestigationInformationResult.TruthMode.TRUTHFUL
	if source_role_id != &"copycat":
		expected_truth_mode = InvestigationInformationResult.TruthMode.LYING
	var source_contract: bool = owner.true_role_id == source_role_id
	if source_role_id == &"copycat":
		source_contract = source_contract and owner.true_alignment == CaseEnums.Alignment.GOOD
	elif source_role_id == &"critic":
		source_contract = (
			source_contract
			and owner.true_alignment == CaseEnums.Alignment.EVIL
			and definition.suspected_role_ids.has(&"clock_maker")
			and current_clock_count == 0
			and CaseRolePoolService.is_listed_current_role_absent(
				definition, runtime, &"clock_maker"
			)
		)
	else:
		source_contract = source_contract and owner.true_alignment == CaseEnums.Alignment.EVIL
	var interval_contract: bool = (
		clue.clock_end_hour == clue.clock_start_hour + 1
		and clue.truth_mode == expected_truth_mode
	)
	if expected_truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL:
		interval_contract = (
			interval_contract
			and clue.clock_claims_ringing
			and clue.clock_start_hour == tower.ring_hour
		)
	else:
		interval_contract = (
			interval_contract
			and not clue.clock_claims_ringing
			and ClockTowerService.false_interval_is_valid(tower, clue.clock_start_hour)
		)
	var witness_contract: bool = current_clock_count == 1
	if source_role_id == &"critic":
		witness_contract = current_clock_count == 0
	var passed: bool = (
		accepted.root_seed == 112233
		and accepted.accepted_derived_seed == 112233
		and owner.displayed_role_id == &"clock_maker"
		and owner.impersonated_role_id == &"clock_maker"
		and owner.is_impersonating
		and source_contract
		and witness_contract
		and tower.ring_hour >= 1 and tower.ring_hour <= 23
		and public_view.clock_tower_slot == tower.board_slot
		and not _object_has_property(public_view, &"clock_tower_ring_hour")
		and interval_contract
		and solver.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION
		and solver.ground_truth_checked
		and solver.unique_solution_matches_ground_truth
	)
	print("SLICE_B_CLOCK_EVIDENCE source=%s root=%d accepted_seed=%d owner=%d truth=%d interval=%d-%d ring=%d solver=%s" % [
		String(source_role_id), accepted.root_seed, accepted.accepted_derived_seed,
		owner.suspect_id, clue.truth_mode, clue.clock_start_hour, clue.clock_end_hour,
		tower.ring_hour, String(solver.status),
	])
	return passed


func _clock_disguise_request(source_role_id: StringName) -> CaseGenerationRequest:
	var role_ids: Array[StringName] = []
	if source_role_id == &"tutorial_mobster":
		role_ids = [&"tutorial_mobster", &"clock_maker", &"surgeon", &"tutorial_scoundrel", &"role_meddler_a"]
	elif source_role_id == &"copycat":
		role_ids = [&"copycat", &"clock_maker", &"surgeon", &"tutorial_scoundrel", &"tutorial_mobster"]
	else:
		role_ids = [&"critic", &"tutorial_priest", &"reporter", &"clock_maker", &"mathematician", &"therapist"]
	var locations: Array[StringName] = [BoardLocationDefinition.LOCATION_CRIME_SCENE]
	var required_count: int = 5
	return REQUEST.create(
		112233, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY,
		role_ids, locations, required_count
	)


func _role_suspect(definition: CaseDefinition, role_id: StringName) -> SuspectDefinition:
	if definition != null:
		for suspect: SuspectDefinition in definition.suspects:
			if suspect != null and suspect.true_role_id == role_id:
				return suspect
	return null


func _clue_for_suspect(
	candidate: CaseGenerationResult,
	suspect_id: int
) -> GeneratedPublicClue:
	if candidate != null and candidate.hidden_case_draft != null:
		for clue in candidate.hidden_case_draft.public_clues:
			if clue != null and clue.suspect_id == suspect_id:
				return clue as GeneratedPublicClue
	return null


func _object_has_property(source: Object, property_name: StringName) -> bool:
	if source == null:
		return false
	for property_info: Dictionary in source.get_property_list():
		if StringName(property_info.get("name", &"")) == property_name:
			return true
	return false


func _accepted_evidence(accepted: CaseGenerationAcceptanceResult, generator: GENERATOR) -> String:
	if accepted == null or not accepted.success:
		return ""
	var definition: CaseDefinition = generator.case_definition_from_result(accepted.accepted_candidate)
	var tower: ClockTowerDefinition = ClockTowerService.clock_tower_for_case(definition)
	var clue: GeneratedPublicClue = _clock_clue(accepted.accepted_public_view)
	if tower == null or clue == null:
		return ""
	return "root=%d accepted_seed=%d suspects=%d tower_slot=%d ring=%d,%d interval=%d,%d solver=%s" % [accepted.root_seed, accepted.accepted_derived_seed, definition.suspects.size(), tower.board_slot, tower.ring_hour, tower.ring_hour + 1, clue.clock_start_hour, clue.clock_end_hour, accepted.accepted_solver_result.status]


func _audit_snapshot(request: CaseGenerationRequest, accepted: CaseGenerationAcceptanceResult, roles: Array[RoleDefinition]) -> bool:
	if accepted == null or not accepted.success:
		return false
	var entry: CaseSeedWarehouseEntry = CaseSeedWarehouseEntry.from_acceptance(request, accepted)
	var snapshot = AUDIT.new()
	if not snapshot.capture(entry, accepted, roles):
		return false
	var hour: int = accepted.accepted_candidate.hidden_case_draft.clock_tower_ring_hour
	var lines: PackedStringArray = snapshot.display_lines()
	return snapshot.clock_tower_ring_hour == hour and lines.has("Clock Tower: %dh / %dh" % [hour, hour + 1]) and snapshot.accepted and snapshot.ground_truth_matches


func _add(rows: Array[Dictionary], name: String, passed: bool, detail: String = "Native Clock Maker automatic investigation evidence") -> void:
	rows.append({"name": name, "passed": passed, "detail": detail})
