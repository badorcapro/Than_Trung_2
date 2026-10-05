extends RefCounted

const DEBUG_HOME_PATH: String = "res://scenes/boot/DebugHome.tscn"
const PRIEST_LYING_TEXT: String = "Ta có thật là một Tư Tế tốt không?"
const DRUNKARD_MAILMAN_TEXT: String = "Nhà Toán Học đang ở trong cung, ta chưa từng nghe đến Sử Quan."
const OBSCURED_THERAPIST_TEXT: String = "Ta có 1 người bệnh thuộc Phe Ác."
const MASKED_THERAPIST_TEXT: String = "■■ ■■ 1 ■■■■■ ■■■■ ■■■■■ ■■■ ■■."


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var players: Array[PlayerCaseState] = FixtureRepository.load_players()
	var case_definition: CaseDefinition = FixtureRepository.load_hv5_mutation_visibility()
	var runtime: CaseRuntimeState = _runtime_after_startup(case_definition, roles)
	_add(rows, "HV5 authored fixture validates", _fixture_valid(case_definition, roles, players))
	_add(rows, "HV5 suspect numbering follows physical reading order", _numbering_matches(case_definition))
	_add(rows, "HV5 DebugHome entry resolves through normal Case runtime", _debug_entry_resolves())
	_add(rows, "HV5 startup mutation records target Priest and Mailman", _startup_records_match(runtime))
	_add(rows, "HV5 Poisoner taint preserves Priest identity and Good authority", _tainted_priest_state_matches(case_definition, runtime, roles))
	_add(rows, "HV5 tainted Priest uses canonical LYING announcement", _tainted_priest_clue_matches(case_definition, runtime, roles))
	_add(rows, "HV5 Barkeep transform creates Good Meddler Drunkard", _drunkard_state_matches(case_definition, runtime, roles))
	_add(rows, "HV5 Drunkard retains Mailman display and LYING behavior", _drunkard_public_behavior_matches(case_definition, runtime, roles))
	_add(rows, "HV5 Spectre obscure target is valid and separate from transform", _spectre_relation_matches(case_definition, runtime, roles))
	_add(rows, "HV5 obscure masks identity and letters while preserving number shape", _obscured_public_view_matches(case_definition, runtime, roles))
	_add(rows, "HV5 Full Reveal restores mutation and obscured truth", _full_reveal_matches(case_definition, runtime, roles))
	_add(rows, "HV5 exact Evil answer remains Poisoner Barkeep Spectre", _evil_answer_matches(case_definition))
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
	var expected_slots: PackedInt32Array = PackedInt32Array([0, 1, 2, 3, 5, 6, 7])
	for index: int in range(expected_slots.size()):
		var suspect: SuspectDefinition = case_definition.suspect_at_slot(expected_slots[index])
		if suspect == null or suspect.suspect_id != index + 1:
			return false
	return (
		case_definition.crime_scene.board_slot == 4
		and case_definition.suspect_at_slot(8) == null
		and case_definition.location_at_slot(8) == null
	)


func _debug_entry_resolves() -> bool:
	var packed: PackedScene = load(DEBUG_HOME_PATH) as PackedScene
	if packed == null:
		return false
	var scene: Control = packed.instantiate() as Control
	if scene == null:
		return false
	var button: Button = scene.get_node_or_null("%Hv5MutationVisibilityButton") as Button
	var previous_path: String = AppFlow.pending_case_path
	var previous_definition: CaseDefinition = AppFlow.pending_case_definition
	AppFlow.pending_case_definition = null
	AppFlow.pending_case_path = FixtureRepository.HV5_MUTATION_VISIBILITY_PATH
	var resolved: CaseDefinition = AppFlow.take_pending_case_definition()
	AppFlow.pending_case_path = previous_path
	AppFlow.pending_case_definition = previous_definition
	var passed: bool = (
		button != null
		and button.text == "HV5 — Mutation & Visibility"
		and scene.has_method("_on_hv5_mutation_visibility_pressed")
		and AppFlow.has_method("go_to_hv5_mutation_visibility")
		and AppFlow.VS_CASE_MAIN_SCENE == "res://scenes/case_gameplay/VSCaseMain.tscn"
		and resolved != null
		and resolved.case_id == &"hv5_mutation_visibility"
	)
	scene.free()
	return passed


func _startup_records_match(runtime: CaseRuntimeState) -> bool:
	if runtime == null:
		return false
	var poisoner_record: PoisonerTaintRecord = runtime.poisoner_record_for_source(1)
	var barkeep_record: BarkeepTransformationRecord = runtime.barkeep_record_for_source(3)
	return (
		poisoner_record != null
		and poisoner_record.applied
		and poisoner_record.target_suspect_id == 2
		and barkeep_record != null
		and barkeep_record.applied
		and barkeep_record.target_suspect_id == 5
		and barkeep_record.original_target_role_id == &"mailman"
		and barkeep_record.resulting_role_id == &"drunkard"
	)


func _tainted_priest_state_matches(
	case_definition: CaseDefinition,
	runtime: CaseRuntimeState,
	roles: Array[RoleDefinition]
) -> bool:
	var state: CaseMutationStateSnapshot = CaseMutationStateSnapshot.from_runtime(
		case_definition, runtime, 2, roles
	)
	return (
		state != null
		and state.original_role_id == &"tutorial_priest"
		and state.current_role_id == &"tutorial_priest"
		and state.displayed_role_id == &"tutorial_priest"
		and state.behavior_role_id == &"tutorial_priest"
		and state.current_role_group == CaseEnums.RoleGroup.CHINH_NHAN
		and state.current_alignment == CaseEnums.Alignment.GOOD
		and state.is_tainted
		and state.truth_mode == InvestigationInformationResult.TruthMode.LYING
	)


func _tainted_priest_clue_matches(
	case_definition: CaseDefinition,
	runtime: CaseRuntimeState,
	roles: Array[RoleDefinition]
) -> bool:
	var result: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(
		case_definition, 2, roles, {}, runtime
	)
	return (
		result != null
		and result.behavior_role_id == &"tutorial_priest"
		and result.truth_mode == InvestigationInformationResult.TruthMode.LYING
		and result.text == PRIEST_LYING_TEXT
	)


func _drunkard_state_matches(
	case_definition: CaseDefinition,
	runtime: CaseRuntimeState,
	roles: Array[RoleDefinition]
) -> bool:
	var state: CaseMutationStateSnapshot = CaseMutationStateSnapshot.from_runtime(
		case_definition, runtime, 5, roles
	)
	return (
		state != null
		and state.original_role_id == &"mailman"
		and state.current_role_id == &"drunkard"
		and state.displayed_role_id == &"mailman"
		and state.behavior_role_id == &"mailman"
		and state.current_role_group == CaseEnums.RoleGroup.HIEU_SU
		and state.current_alignment == CaseEnums.Alignment.GOOD
		and state.truth_mode == InvestigationInformationResult.TruthMode.LYING
		and not state.is_impersonating
	)


func _drunkard_public_behavior_matches(
	case_definition: CaseDefinition,
	runtime: CaseRuntimeState,
	roles: Array[RoleDefinition]
) -> bool:
	var result: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(
		case_definition, 5, roles, {}, runtime
	)
	return (
		result != null
		and result.true_role_id == &"mailman"
		and result.displayed_role_id == &"mailman"
		and result.behavior_role_id == &"mailman"
		and result.truth_mode == InvestigationInformationResult.TruthMode.LYING
		and not result.claimed_in_play_is_true
		and not result.claimed_not_in_play_is_true
		and result.text == DRUNKARD_MAILMAN_TEXT
	)


func _spectre_relation_matches(
	case_definition: CaseDefinition,
	runtime: CaseRuntimeState,
	roles: Array[RoleDefinition]
) -> bool:
	var spectre: SuspectDefinition = _find_suspect(case_definition, 4)
	var target: SuspectDefinition = _find_suspect(case_definition, 6)
	var target_state: CaseMutationStateSnapshot = CaseMutationStateSnapshot.from_runtime(
		case_definition, runtime, 6, roles
	)
	return (
		spectre != null
		and spectre.true_role_id == &"spectre"
		and spectre.obscure_target_suspect_id == 6
		and target != null
		and target.role_group == CaseEnums.RoleGroup.CHINH_NHAN
		and target.suspect_id != case_definition.startup_barkeep_target_suspect_id
		and target_state != null
		and target_state.current_role_id == &"therapist"
		and target_state.is_obscured
		and not target_state.role_identity_visible
	)


func _obscured_public_view_matches(
	case_definition: CaseDefinition,
	runtime: CaseRuntimeState,
	roles: Array[RoleDefinition]
) -> bool:
	for suspect_id: int in [2, 5, 6]:
		var suspect_runtime: SuspectRuntimeState = runtime.find_suspect(suspect_id)
		if suspect_runtime != null:
			suspect_runtime.is_investigated = true
	var views: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(
		case_definition, runtime, roles
	)
	var priest_view: SuspectPublicViewData = _find_view(views, 2)
	var drunkard_view: SuspectPublicViewData = _find_view(views, 5)
	var obscured_view: SuspectPublicViewData = _find_view(views, 6)
	return (
		priest_view != null
		and priest_view.public_role_name == "Tư Tế"
		and priest_view.public_investigation_statement == PRIEST_LYING_TEXT
		and drunkard_view != null
		and drunkard_view.public_role_name == "Dịch Phu"
		and drunkard_view.public_role_group == CaseEnums.RoleGroup.CHINH_NHAN
		and drunkard_view.public_investigation_statement == DRUNKARD_MAILMAN_TEXT
		and obscured_view != null
		and obscured_view.public_role_name == "?????"
		and obscured_view.public_role_group == -1
		and obscured_view.public_role_obscured
		and obscured_view.public_information_obscured
		and obscured_view.public_investigation_statement == MASKED_THERAPIST_TEXT
		and obscured_view.public_investigation_statement.contains("1")
		and not obscured_view.public_investigation_statement.contains("T")
		and not obscured_view.public_investigation_statement.contains("Á")
	)


func _full_reveal_matches(
	case_definition: CaseDefinition,
	runtime: CaseRuntimeState,
	roles: Array[RoleDefinition]
) -> bool:
	if runtime == null:
		return false
	runtime.is_settled = true
	runtime.settlement_result = CaseSettlementResult.new()
	runtime.settlement_result.success = true
	runtime.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
	var reveal: CaseTruthReveal = CaseTruthRevealBuilder.new().build(case_definition, runtime, roles)
	if reveal == null:
		return false
	var views: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(
		case_definition, runtime, roles
	)
	var poisoner_truth: SuspectTruthReveal = _find_truth(reveal, 1)
	var priest_truth: SuspectTruthReveal = _find_truth(reveal, 2)
	var barkeep_truth: SuspectTruthReveal = _find_truth(reveal, 3)
	var spectre_truth: SuspectTruthReveal = _find_truth(reveal, 4)
	var drunkard_truth: SuspectTruthReveal = _find_truth(reveal, 5)
	var therapist_truth: SuspectTruthReveal = _find_truth(reveal, 6)
	var priest_view: SuspectPublicViewData = _find_view(views, 2)
	var drunkard_view: SuspectPublicViewData = _find_view(views, 5)
	var therapist_view: SuspectPublicViewData = _find_view(views, 6)
	return (
		poisoner_truth != null
		and poisoner_truth.true_role_name == "Độc Sư"
		and poisoner_truth.relation_notes.has("Độc Sư đã Tha Hóa Số Hiệu 2.")
		and priest_truth != null
		and priest_truth.true_role_name == "Tư Tế"
		and priest_truth.role_group_label == "Người Vô Tội"
		and priest_truth.alignment_label == "Phe Thiện"
		and priest_truth.is_corrupted
		and priest_view != null
		and priest_view.full_truth_visible
		and priest_view.truth_is_corrupted
		and barkeep_truth != null
		and barkeep_truth.true_role_name == "Chủ Quán Rượu"
		and barkeep_truth.relation_notes.has("Chủ Quán Rượu đã biến Số Hiệu 5 thành Kẻ Say Rượu.")
		and spectre_truth != null
		and spectre_truth.true_role_name == "Vong Linh"
		and spectre_truth.obscure_target_suspect_id == 6
		and drunkard_truth != null
		and drunkard_truth.original_true_role_name == "Dịch Phu"
		and drunkard_truth.current_role_id == &"drunkard"
		and drunkard_truth.current_role_name == "Kẻ Say Rượu"
		and drunkard_truth.role_group_label == "Kẻ Bao Đồng"
		and drunkard_truth.alignment_label == "Phe Thiện"
		and drunkard_view != null
		and drunkard_view.full_truth_visible
		and drunkard_view.public_role_name == "Kẻ Say Rượu"
		and drunkard_view.truth_role_group == CaseEnums.RoleGroup.HIEU_SU
		and drunkard_view.reveal_has_previous_statement
		and drunkard_view.reveal_previous_statement == DRUNKARD_MAILMAN_TEXT
		and therapist_truth != null
		and therapist_truth.true_role_name == "Ngự Y"
		and therapist_truth.role_group_label == "Người Vô Tội"
		and therapist_view != null
		and therapist_view.full_truth_visible
		and not therapist_view.public_role_obscured
		and therapist_view.public_role_name == "Ngự Y"
		and therapist_view.truth_role_group == CaseEnums.RoleGroup.CHINH_NHAN
		and therapist_view.reveal_has_previous_statement
		and therapist_view.reveal_previous_statement == OBSCURED_THERAPIST_TEXT
	)


func _evil_answer_matches(case_definition: CaseDefinition) -> bool:
	return (
		case_definition != null
		and case_definition.evil_suspect_ids == PackedInt32Array([1, 3, 4])
		and case_definition.accomplice_suspect_ids == PackedInt32Array([1, 3, 4])
		and case_definition.traitor_suspect_ids.is_empty()
	)


func _runtime_after_startup(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition]
) -> CaseRuntimeState:
	if case_definition == null:
		return null
	var runtime: CaseRuntimeState = CaseRuntimeState.new()
	var no_players: Array[PlayerCaseState] = []
	runtime.initialize(case_definition, no_players)
	PoisonerTaintService.new().resolve_random_taint(
		case_definition, runtime, case_definition.startup_poisoner_source_suspect_id
	)
	BarkeepTransformationService.new().resolve_transformation(
		case_definition,
		runtime,
		case_definition.startup_barkeep_source_suspect_id,
		case_definition.startup_barkeep_target_suspect_id,
		roles
	)
	return runtime


func _find_suspect(case_definition: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	if case_definition == null:
		return null
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null


func _find_view(
	views: Array[SuspectPublicViewData],
	suspect_id: int
) -> SuspectPublicViewData:
	for view: SuspectPublicViewData in views:
		if view != null and view.suspect_id == suspect_id:
			return view
	return null


func _find_truth(reveal: CaseTruthReveal, suspect_id: int) -> SuspectTruthReveal:
	if reveal == null:
		return null
	for truth: SuspectTruthReveal in reveal.suspect_truths:
		if truth != null and truth.suspect_id == suspect_id:
			return truth
	return null


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "HV5 mutation and visibility human verification invariant",
	})
