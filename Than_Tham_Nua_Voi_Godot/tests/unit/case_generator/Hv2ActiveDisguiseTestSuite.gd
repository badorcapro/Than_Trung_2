extends RefCounted

const DEBUG_HOME_PATH: String = "res://scenes/boot/DebugHome.tscn"


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var players: Array[PlayerCaseState] = FixtureRepository.load_players()
	var case_definition: CaseDefinition = FixtureRepository.load_hv2_active_disguise()
	_add(rows, "HV2 authored fixture validates", _fixture_valid(case_definition, roles, players))
	_add(rows, "HV2 suspect numbering follows physical reading order", _numbering_matches(case_definition))
	_add(rows, "HV2 DebugHome entry resolves through normal Case runtime", _debug_entry_resolves())
	_add(rows, "HV2 active disguises preserve true and displayed identities", _identity_mappings_match(case_definition))
	_add(rows, "HV2 active owners receive displayed functions with true-owner truth modes", _function_authority_matches(case_definition, roles))
	_add(rows, "HV2 borrowed function use remains owner-local and one-use", _function_state_is_independent(case_definition, roles))
	_add(rows, "HV2 Tailor truthful and LYING results use true alignment", _tailor_results_match(case_definition, roles))
	_add(rows, "HV2 Vigilante truthful and LYING results use true alignment", _vigilante_results_match(case_definition, roles))
	_add(rows, "HV2 Full Reveal and exact Evil answer remain authoritative", _full_reveal_and_answer_match(case_definition, roles))
	return rows


func _fixture_valid(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition],
	players: Array[PlayerCaseState]
) -> bool:
	if case_definition == null:
		return false
	var report: Dictionary = CaseDefinitionValidator.new().validate(case_definition, roles, players)
	return bool(report.get("passed", false))


func _numbering_matches(case_definition: CaseDefinition) -> bool:
	if case_definition == null or case_definition.crime_scene == null:
		return false
	var expected_slots: PackedInt32Array = PackedInt32Array([0, 1, 2, 3, 5, 7, 8])
	for index: int in range(expected_slots.size()):
		var suspect: SuspectDefinition = case_definition.suspect_at_slot(expected_slots[index])
		if suspect == null or suspect.suspect_id != index + 1:
			return false
	return case_definition.crime_scene.board_slot == 4 and case_definition.suspect_at_slot(6) == null


func _debug_entry_resolves() -> bool:
	var packed: PackedScene = load(DEBUG_HOME_PATH) as PackedScene
	if packed == null:
		return false
	var scene: Control = packed.instantiate() as Control
	if scene == null:
		return false
	var button: Button = scene.get_node_or_null("%Hv2ActiveDisguiseButton") as Button
	var previous_path: String = AppFlow.pending_case_path
	var previous_definition: CaseDefinition = AppFlow.pending_case_definition
	AppFlow.pending_case_definition = null
	AppFlow.pending_case_path = FixtureRepository.HV2_ACTIVE_DISGUISE_PATH
	var resolved: CaseDefinition = AppFlow.take_pending_case_definition()
	AppFlow.pending_case_path = previous_path
	AppFlow.pending_case_definition = previous_definition
	var passed: bool = (
		button != null
		and button.text == "HV2 — Active Disguise"
		and scene.has_method("_on_hv2_active_disguise_pressed")
		and AppFlow.has_method("go_to_hv2_active_disguise")
		and AppFlow.VS_CASE_MAIN_SCENE == "res://scenes/case_gameplay/VSCaseMain.tscn"
		and resolved != null
		and resolved.case_id == &"hv2_active_disguise"
	)
	scene.free()
	return passed


func _identity_mappings_match(case_definition: CaseDefinition) -> bool:
	return (
		_suspect_maps(case_definition, 1, &"tailor", &"tailor", false)
		and _suspect_maps(case_definition, 2, &"vigilante", &"vigilante", false)
		and _suspect_maps(case_definition, 3, &"copycat", &"vigilante", true)
		and _suspect_maps(case_definition, 6, &"tutorial_mobster", &"tailor", true)
		and _suspect_maps(case_definition, 7, &"serial_killer", &"vigilante", true)
	)


func _function_authority_matches(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition]
) -> bool:
	var bundle: Dictionary = _runtime_with_available_functions(
		case_definition, roles, PackedInt32Array([1, 2, 3, 6, 7])
	)
	var runtime: CaseRuntimeState = bundle.get("runtime", null) as CaseRuntimeState
	if runtime == null:
		return false
	var truth_service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	return (
		_function_matches(runtime, 1, CaseEnums.FunctionType.TAILOR_COMPARE_ALIGNMENT)
		and _function_matches(runtime, 2, CaseEnums.FunctionType.VIGILANTE_KILL)
		and _function_matches(runtime, 3, CaseEnums.FunctionType.VIGILANTE_KILL)
		and _function_matches(runtime, 6, CaseEnums.FunctionType.TAILOR_COMPARE_ALIGNMENT)
		and _function_matches(runtime, 7, CaseEnums.FunctionType.VIGILANTE_KILL)
		and truth_service.truth_mode_for_suspect_effective(case_definition, runtime, 1) == InvestigationInformationResult.TruthMode.TRUTHFUL
		and truth_service.truth_mode_for_suspect_effective(case_definition, runtime, 3) == InvestigationInformationResult.TruthMode.TRUTHFUL
		and truth_service.truth_mode_for_suspect_effective(case_definition, runtime, 6) == InvestigationInformationResult.TruthMode.LYING
		and truth_service.truth_mode_for_suspect_effective(case_definition, runtime, 7) == InvestigationInformationResult.TruthMode.LYING
	)


func _function_state_is_independent(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition]
) -> bool:
	var bundle: Dictionary = _runtime_with_available_functions(
		case_definition, roles, PackedInt32Array([3, 6, 7])
	)
	var runtime: CaseRuntimeState = bundle.get("runtime", null) as CaseRuntimeState
	if runtime == null:
		return false
	var execution: InteractiveFunctionExecutionService = InteractiveFunctionExecutionService.new()
	var serial_result: InteractiveFunctionResult = execution.execute(
		case_definition, runtime, 7, PackedInt32Array([6]), runtime.current_player_id()
	)
	var repeated: InteractiveFunctionResult = execution.execute(
		case_definition, runtime, 7, PackedInt32Array([6]), runtime.current_player_id()
	)
	var serial_function: InteractiveFunctionRuntimeState = _function_state(runtime, 7)
	return (
		serial_result != null and serial_result.success
		and repeated != null and not repeated.success
		and serial_function != null
		and serial_function.state == InteractiveFunctionRuntimeState.State.EXHAUSTED
		and serial_function.uses_remaining == 0
		and _function_matches(runtime, 3, CaseEnums.FunctionType.VIGILANTE_KILL)
		and _function_matches(runtime, 6, CaseEnums.FunctionType.TAILOR_COMPARE_ALIGNMENT)
		and runtime.public_function_records.size() == 1
	)


func _tailor_results_match(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition]
) -> bool:
	var truthful_bundle: Dictionary = _runtime_with_available_functions(
		case_definition, roles, PackedInt32Array([1])
	)
	var truthful_runtime: CaseRuntimeState = truthful_bundle.get("runtime", null) as CaseRuntimeState
	if truthful_runtime == null:
		return false
	var truthful_result: InteractiveFunctionResult = InteractiveFunctionExecutionService.new().execute(
		case_definition, truthful_runtime, 1, PackedInt32Array([4, 6]), truthful_runtime.current_player_id()
	)
	var lying_bundle: Dictionary = _runtime_with_available_functions(
		case_definition, roles, PackedInt32Array([6])
	)
	var lying_runtime: CaseRuntimeState = lying_bundle.get("runtime", null) as CaseRuntimeState
	if lying_runtime == null:
		return false
	var lying_result: InteractiveFunctionResult = InteractiveFunctionExecutionService.new().execute(
		case_definition, lying_runtime, 6, PackedInt32Array([4, 6]), lying_runtime.current_player_id()
	)
	return (
		truthful_result != null and truthful_result.success
		and truthful_result.public_result_type == InteractiveFunctionResult.PublicResultType.DIFFERENT_ALIGNMENT
		and truthful_result.public_result_text == "Khác phe"
		and lying_result != null and lying_result.success
		and lying_result.public_result_type == InteractiveFunctionResult.PublicResultType.SAME_ALIGNMENT
		and lying_result.public_result_text == "Cùng phe"
	)


func _vigilante_results_match(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition]
) -> bool:
	var lying_bundle: Dictionary = _runtime_with_available_functions(
		case_definition, roles, PackedInt32Array([7])
	)
	var lying_runtime: CaseRuntimeState = lying_bundle.get("runtime", null) as CaseRuntimeState
	if lying_runtime == null:
		return false
	var lying_result: InteractiveFunctionResult = InteractiveFunctionExecutionService.new().execute(
		case_definition, lying_runtime, 7, PackedInt32Array([6]), lying_runtime.current_player_id()
	)
	var truthful_bundle: Dictionary = _runtime_with_available_functions(
		case_definition, roles, PackedInt32Array([3])
	)
	var truthful_runtime: CaseRuntimeState = truthful_bundle.get("runtime", null) as CaseRuntimeState
	if truthful_runtime == null:
		return false
	var truthful_result: InteractiveFunctionResult = InteractiveFunctionExecutionService.new().execute(
		case_definition, truthful_runtime, 3, PackedInt32Array([7]), truthful_runtime.current_player_id()
	)
	var lying_target: SuspectRuntimeState = lying_runtime.find_suspect(6) if lying_runtime != null else null
	var truthful_target: SuspectRuntimeState = truthful_runtime.find_suspect(7) if truthful_runtime != null else null
	return (
		lying_result != null and lying_result.success
		and not lying_result.vigilante_kill_attempted
		and not lying_result.vigilante_target_killed
		and lying_result.public_result_text == "Số Hiệu 6 bình an vô sự."
		and lying_target != null and not lying_target.is_dead
		and truthful_result != null and truthful_result.success
		and truthful_result.vigilante_kill_attempted
		and truthful_result.vigilante_target_killed
		and truthful_result.public_result_text == "Số Hiệu 7 đã bị xử quyết."
		and truthful_target != null and truthful_target.is_dead
	)


func _full_reveal_and_answer_match(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition]
) -> bool:
	if case_definition == null:
		return false
	var runtime: CaseRuntimeState = _fresh_runtime(case_definition)
	runtime.is_settled = true
	runtime.settlement_result = CaseSettlementResult.new()
	runtime.settlement_result.success = true
	runtime.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
	var reveal: CaseTruthReveal = CaseTruthRevealBuilder.new().build(case_definition, runtime, roles)
	return (
		case_definition.evil_suspect_ids == PackedInt32Array([6, 7])
		and case_definition.accomplice_suspect_ids == PackedInt32Array([6, 7])
		and case_definition.traitor_suspect_ids.is_empty()
		and _truth_matches(reveal, 3, "Kẻ Bắt Chước", "Sư Tử Phán", "Phe Thiện", "Kẻ Bao Đồng")
		and _truth_matches(reveal, 6, "Kẻ Côn Đồ", "Thợ May", "Phe Ác", "Thuộc Hạ")
		and _truth_matches(reveal, 7, "Sát Nhân Hàng Loạt", "Sư Tử Phán", "Phe Ác", "Thuộc Hạ")
	)


func _runtime_with_available_functions(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition],
	owner_ids: PackedInt32Array
) -> Dictionary:
	var runtime: CaseRuntimeState = _fresh_runtime(case_definition)
	if runtime == null:
		return {"runtime": null}
	for player: PlayerCaseState in runtime.players:
		runtime.turn_order_player_ids.append(player.player_id)
	var availability: FunctionAvailabilityService = FunctionAvailabilityService.new()
	availability.initialize_hidden_states(case_definition, runtime, roles)
	for owner_id: int in owner_ids:
		var owner_runtime: SuspectRuntimeState = runtime.find_suspect(owner_id)
		if owner_runtime == null:
			continue
		owner_runtime.is_investigated = true
		availability.reveal_for_suspect(case_definition, runtime, roles, owner_id, 1)
	availability.update_for_turn(runtime, 2)
	return {"runtime": runtime}


func _fresh_runtime(case_definition: CaseDefinition) -> CaseRuntimeState:
	if case_definition == null:
		return null
	var runtime: CaseRuntimeState = CaseRuntimeState.new()
	runtime.initialize(case_definition, FixtureRepository.load_players())
	return runtime


func _function_matches(runtime: CaseRuntimeState, suspect_id: int, function_type: int) -> bool:
	var state: InteractiveFunctionRuntimeState = _function_state(runtime, suspect_id)
	return (
		state != null
		and state.function_type == function_type
		and state.state == InteractiveFunctionRuntimeState.State.AVAILABLE
		and state.uses_remaining == 1
	)


func _function_state(runtime: CaseRuntimeState, suspect_id: int) -> InteractiveFunctionRuntimeState:
	var suspect_runtime: SuspectRuntimeState = runtime.find_suspect(suspect_id) if runtime != null else null
	return suspect_runtime.interactive_function if suspect_runtime != null else null


func _suspect_maps(
	case_definition: CaseDefinition,
	suspect_id: int,
	true_role_id: StringName,
	displayed_role_id: StringName,
	expect_impersonating: bool
) -> bool:
	var suspect: SuspectDefinition = _find_suspect(case_definition, suspect_id)
	if suspect == null:
		return false
	return (
		suspect.true_role_id == true_role_id
		and suspect.displayed_role_id == displayed_role_id
		and suspect.is_impersonating == expect_impersonating
		and (
			suspect.impersonated_role_id == displayed_role_id
			if expect_impersonating
			else String(suspect.impersonated_role_id).is_empty()
		)
	)


func _truth_matches(
	reveal: CaseTruthReveal,
	suspect_id: int,
	true_role_name: String,
	displayed_role_name: String,
	alignment_label: String,
	group_label: String
) -> bool:
	if reveal == null:
		return false
	for truth: SuspectTruthReveal in reveal.suspect_truths:
		if truth == null or truth.suspect_id != suspect_id:
			continue
		return (
			truth.true_role_name == true_role_name
			and truth.displayed_role_name == displayed_role_name
			and truth.alignment_label == alignment_label
			and truth.role_group_label == group_label
			and truth.is_impersonating
		)
	return false


func _find_suspect(case_definition: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	if case_definition == null:
		return null
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "HV2 active-disguise human verification invariant",
	})
