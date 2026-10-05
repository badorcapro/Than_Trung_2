extends RefCounted

const DEBUG_HOME_PATH: String = "res://scenes/boot/DebugHome.tscn"


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var players: Array[PlayerCaseState] = FixtureRepository.load_players()
	var case_definition: CaseDefinition = FixtureRepository.load_hv1_disguise_clue_behavior()
	var runtime: CaseRuntimeState = _fresh_runtime(case_definition)

	_add(rows, "HV1 authored fixture validates", _fixture_valid(case_definition, roles, players))
	_add(rows, "Case validator rejects suspect IDs outside physical reading order", _validator_rejects_wrong_numbering(case_definition, roles, players))
	_add(rows, "HV1 DebugHome entry resolves through normal Case runtime", _debug_entry_resolves())
	_add(rows, "HV1 disguise identities remain separated", _disguise_identities_match(case_definition))
	_add(rows, "HV1 behavior roles and truth modes remain separated", _behavior_and_truth_modes_match(case_definition, runtime, roles))
	_add(rows, "HV1 public investigation clues are deterministic", _public_clues_match(case_definition, runtime, roles))
	_add(rows, "HV1 Critic target stays listed and current-absent", _critic_target_is_listed_current_absent(case_definition, runtime))
	_add(rows, "HV1 Full Reveal exposes authoritative true identities", _full_reveal_matches(case_definition, roles))
	_add(rows, "HV1 exact Evil answer remains suspects 2, 5, and 6", _evil_answer_matches(case_definition))
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


func _debug_entry_resolves() -> bool:
	var packed: PackedScene = load(DEBUG_HOME_PATH) as PackedScene
	if packed == null:
		return false
	var scene: Control = packed.instantiate() as Control
	if scene == null:
		return false
	var button: Button = scene.get_node_or_null("%Hv1DisguiseClueButton") as Button
	var previous_path: String = AppFlow.pending_case_path
	var previous_definition: CaseDefinition = AppFlow.pending_case_definition
	AppFlow.pending_case_definition = null
	AppFlow.pending_case_path = FixtureRepository.HV1_DISGUISE_CLUE_BEHAVIOR_PATH
	var resolved: CaseDefinition = AppFlow.take_pending_case_definition()
	AppFlow.pending_case_path = previous_path
	AppFlow.pending_case_definition = previous_definition
	var passed: bool = (
		button != null
		and button.text == "HV1 — Disguise & Clue Behavior"
		and scene.has_method("_on_hv1_disguise_clue_behavior_pressed")
		and AppFlow.has_method("go_to_hv1_disguise_clue_behavior")
		and AppFlow.VS_CASE_MAIN_SCENE == "res://scenes/case_gameplay/VSCaseMain.tscn"
		and resolved != null
		and resolved.case_id == &"hv1_disguise_clue_behavior"
	)
	scene.free()
	return passed


func _validator_rejects_wrong_numbering(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition],
	players: Array[PlayerCaseState]
) -> bool:
	if case_definition == null:
		return false
	var invalid_case: CaseDefinition = case_definition.duplicate(true) as CaseDefinition
	var first: SuspectDefinition = _find_suspect(invalid_case, 1)
	var second: SuspectDefinition = _find_suspect(invalid_case, 2)
	if first == null or second == null:
		return false
	var first_slot: int = first.board_slot
	first.board_slot = second.board_slot
	second.board_slot = first_slot
	var report: Dictionary = CaseDefinitionValidator.new().validate(invalid_case, roles, players)
	var raw_errors: Variant = report.get("errors", [])
	var errors: Array = raw_errors if raw_errors is Array else []
	for error_value: Variant in errors:
		if error_value is Dictionary and String(error_value.get("code", "")) == "SUSPECT_NUMBERING_ORDER_INVALID":
			return true
	return false


func _disguise_identities_match(case_definition: CaseDefinition) -> bool:
	return (
		_suspect_maps(case_definition, 2, &"tutorial_mobster", &"tutorial_priest")
		and _suspect_maps(case_definition, 4, &"copycat", &"therapist")
		and _suspect_maps(case_definition, 6, &"critic", &"mailman")
		and _suspect_maps(case_definition, 5, &"serial_killer", &"clock_maker")
	)


func _behavior_and_truth_modes_match(
	case_definition: CaseDefinition,
	runtime: CaseRuntimeState,
	roles: Array[RoleDefinition]
) -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var mobster: InvestigationInformationResult = service.evaluate(case_definition, 2, roles, {}, runtime)
	var copycat: InvestigationInformationResult = service.evaluate(case_definition, 4, roles, {}, runtime)
	var critic: InvestigationInformationResult = service.evaluate(case_definition, 6, roles, {}, runtime)
	var serial_killer: InvestigationInformationResult = service.evaluate(case_definition, 5, roles, {}, runtime)
	return (
		_result_has_behavior(mobster, &"tutorial_priest", InvestigationInformationResult.TruthMode.LYING)
		and _result_has_behavior(copycat, &"therapist", InvestigationInformationResult.TruthMode.TRUTHFUL)
		and _result_has_behavior(critic, &"mailman", InvestigationInformationResult.TruthMode.LYING)
		and _result_has_behavior(serial_killer, &"clock_maker", InvestigationInformationResult.TruthMode.LYING)
	)


func _public_clues_match(
	case_definition: CaseDefinition,
	runtime: CaseRuntimeState,
	roles: Array[RoleDefinition]
) -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var mobster: InvestigationInformationResult = service.evaluate(case_definition, 2, roles, {}, runtime)
	var copycat: InvestigationInformationResult = service.evaluate(case_definition, 4, roles, {}, runtime)
	var critic: InvestigationInformationResult = service.evaluate(case_definition, 6, roles, {}, runtime)
	var serial_killer: InvestigationInformationResult = service.evaluate(case_definition, 5, roles, {}, runtime)
	for suspect_id: int in [2, 4, 5, 6]:
		var suspect_runtime: SuspectRuntimeState = runtime.find_suspect(suspect_id)
		if suspect_runtime != null:
			suspect_runtime.is_investigated = true
	var views: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(
		case_definition, runtime, roles
	)
	return (
		mobster.text == "Ta có thật là một Tư Tế tốt không?"
		and copycat.numeric_value == 1
		and copycat.text == "Ta có 1 người bệnh thuộc Phe Ác."
		and critic.in_play_role_id == &"weatherman"
		and critic.not_in_play_role_id == &"tutorial_priest"
		and not critic.claimed_in_play_is_true
		and not critic.claimed_not_in_play_is_true
		and critic.text == "Nhà Khí Tượng đang ở trong cung, ta chưa từng nghe đến Tư Tế."
		and serial_killer.numeric_value == 1
		and serial_killer.text == "Tháp Đồng Hồ sẽ không reo từ 1h đến 2h."
		and _public_view_matches(views, 2, "Tư Tế", mobster.text)
		and _public_view_matches(views, 4, "Ngự Y", copycat.text)
		and _public_view_matches(views, 6, "Dịch Phu", critic.text)
		and _public_view_matches(views, 5, "Thợ Đồng Hồ", serial_killer.text)
	)


func _critic_target_is_listed_current_absent(
	case_definition: CaseDefinition,
	runtime: CaseRuntimeState
) -> bool:
	return (
		case_definition != null
		and case_definition.suspect_list_role_ids.has(&"mailman")
		and CaseRolePoolService.is_listed_current_role_absent(case_definition, runtime, &"mailman")
		and not CaseRolePoolService.current_role_ids_in_play(case_definition, runtime).has(&"mailman")
	)


func _full_reveal_matches(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition]
) -> bool:
	var runtime: CaseRuntimeState = _fresh_runtime(case_definition)
	if runtime == null:
		return false
	runtime.is_settled = true
	runtime.settlement_result = CaseSettlementResult.new()
	runtime.settlement_result.success = true
	runtime.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
	var reveal: CaseTruthReveal = CaseTruthRevealBuilder.new().build(case_definition, runtime, roles)
	return (
		reveal != null
		and _truth_matches(reveal, 2, "Kẻ Côn Đồ", "Tư Tế", "Phe Ác", "Thuộc Hạ")
		and _truth_matches(reveal, 4, "Kẻ Bắt Chước", "Ngự Y", "Phe Thiện", "Kẻ Bao Đồng")
		and _truth_matches(reveal, 6, "Nhà Phê Bình", "Dịch Phu", "Phe Ác", "Nghịch Thần")
		and _truth_matches(reveal, 5, "Sát Nhân Hàng Loạt", "Thợ Đồng Hồ", "Phe Ác", "Thuộc Hạ")
	)


func _evil_answer_matches(case_definition: CaseDefinition) -> bool:
	return (
		case_definition != null
		and case_definition.evil_suspect_ids == PackedInt32Array([2, 5, 6])
		and case_definition.accomplice_suspect_ids == PackedInt32Array([2, 5])
		and case_definition.traitor_suspect_ids == PackedInt32Array([6])
	)


func _fresh_runtime(case_definition: CaseDefinition) -> CaseRuntimeState:
	if case_definition == null:
		return null
	var runtime: CaseRuntimeState = CaseRuntimeState.new()
	var no_players: Array[PlayerCaseState] = []
	runtime.initialize(case_definition, no_players)
	return runtime


func _suspect_maps(
	case_definition: CaseDefinition,
	suspect_id: int,
	true_role_id: StringName,
	displayed_role_id: StringName
) -> bool:
	var suspect: SuspectDefinition = _find_suspect(case_definition, suspect_id)
	return (
		suspect != null
		and suspect.true_role_id == true_role_id
		and suspect.displayed_role_id == displayed_role_id
		and suspect.impersonated_role_id == displayed_role_id
		and suspect.is_impersonating
	)


func _result_has_behavior(
	result: InvestigationInformationResult,
	behavior_role_id: StringName,
	truth_mode: int
) -> bool:
	return result != null and result.behavior_role_id == behavior_role_id and result.truth_mode == truth_mode


func _public_view_matches(
	views: Array[SuspectPublicViewData],
	suspect_id: int,
	role_name: String,
	statement: String
) -> bool:
	for view: SuspectPublicViewData in views:
		if view != null and view.suspect_id == suspect_id:
			return (
				view.is_investigated
				and view.public_role_name == role_name
				and view.public_investigation_statement == statement
			)
	return false


func _truth_matches(
	reveal: CaseTruthReveal,
	suspect_id: int,
	true_role_name: String,
	displayed_role_name: String,
	alignment_label: String,
	group_label: String
) -> bool:
	for truth: SuspectTruthReveal in reveal.suspect_truths:
		if truth == null or truth.suspect_id != suspect_id:
			continue
		return (
			truth.true_role_name == true_role_name
			and truth.displayed_role_name == displayed_role_name
			and truth.impersonated_role_name == displayed_role_name
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
		"detail": "HV1 disguise/clue behavior verification invariant",
	})
