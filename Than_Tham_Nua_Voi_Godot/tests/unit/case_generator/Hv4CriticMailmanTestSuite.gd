extends RefCounted

const DEBUG_HOME_PATH: String = "res://scenes/boot/DebugHome.tscn"
const FAKE_ROLE_ID: StringName = &"blood_hound"
const PRESENT_ROLE_ID: StringName = &"tutorial_priest"
const EXPECTED_MAILMAN_TEXT: String = "Tư Tế đang ở trong cung, ta chưa từng nghe đến Ngự Khuyển Quan."


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var players: Array[PlayerCaseState] = FixtureRepository.load_players()
	var case_definition: CaseDefinition = FixtureRepository.load_hv4_critic_mailman()
	var runtime: CaseRuntimeState = _fresh_runtime(case_definition)
	_add(rows, "HV4 authored fixture validates", _fixture_valid(case_definition, roles, players))
	_add(rows, "HV4 suspect numbering follows physical reading order", _numbering_matches(case_definition))
	_add(rows, "HV4 DebugHome entry resolves through normal Case runtime", _debug_entry_resolves())
	_add(rows, "HV4 explicit Suspect List and current true-role set stay distinct", _role_sets_match(case_definition, runtime))
	_add(rows, "HV4 Critic fake role stays listed and current-absent", _critic_contract_matches(case_definition, runtime, roles))
	_add(rows, "HV4 truthful Mailman sees Priest present and displayed Blood Hound absent", _mailman_result_matches(case_definition, runtime, roles))
	_add(rows, "HV4 public cards show Critic disguise and exact Mailman statement", _public_views_match(case_definition, runtime, roles))
	_add(rows, "HV4 Full Reveal exposes Critic true and displayed identities", _full_reveal_matches(case_definition, roles))
	_add(rows, "HV4 exact Evil answer remains Critic and Scoundrel", _evil_answer_matches(case_definition))
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
	var expected_slots: PackedInt32Array = PackedInt32Array([0, 1, 2, 3, 5])
	for index: int in range(expected_slots.size()):
		var suspect: SuspectDefinition = case_definition.suspect_at_slot(expected_slots[index])
		if suspect == null or suspect.suspect_id != index + 1:
			return false
	return (
		case_definition.crime_scene.board_slot == 4
		and case_definition.suspect_at_slot(6) == null
		and case_definition.suspect_at_slot(7) == null
		and case_definition.suspect_at_slot(8) == null
	)


func _debug_entry_resolves() -> bool:
	var packed: PackedScene = load(DEBUG_HOME_PATH) as PackedScene
	if packed == null:
		return false
	var scene: Control = packed.instantiate() as Control
	if scene == null:
		return false
	var button: Button = scene.get_node_or_null("%Hv4CriticMailmanButton") as Button
	var previous_path: String = AppFlow.pending_case_path
	var previous_definition: CaseDefinition = AppFlow.pending_case_definition
	AppFlow.pending_case_definition = null
	AppFlow.pending_case_path = FixtureRepository.HV4_CRITIC_MAILMAN_PATH
	var resolved: CaseDefinition = AppFlow.take_pending_case_definition()
	AppFlow.pending_case_path = previous_path
	AppFlow.pending_case_definition = previous_definition
	var passed: bool = (
		button != null
		and button.text == "HV4 — Critic & Mailman"
		and scene.has_method("_on_hv4_critic_mailman_pressed")
		and AppFlow.has_method("go_to_hv4_critic_mailman")
		and AppFlow.VS_CASE_MAIN_SCENE == "res://scenes/case_gameplay/VSCaseMain.tscn"
		and resolved != null
		and resolved.case_id == &"hv4_critic_mailman"
	)
	scene.free()
	return passed


func _role_sets_match(case_definition: CaseDefinition, runtime: CaseRuntimeState) -> bool:
	if case_definition == null or runtime == null:
		return false
	var expected_list: Array[StringName] = [
		&"tutorial_priest", &"mailman", &"critic", &"reporter", &"tutorial_scoundrel", &"blood_hound",
	]
	var current_roles: Array[StringName] = CaseRolePoolService.current_role_ids_in_play(case_definition, runtime)
	return (
		case_definition.suspect_list_role_ids == expected_list
		and case_definition.suspected_role_ids == expected_list
		and current_roles.size() == 5
		and current_roles.has(&"tutorial_priest")
		and current_roles.has(&"mailman")
		and current_roles.has(&"critic")
		and current_roles.has(&"reporter")
		and current_roles.has(&"tutorial_scoundrel")
		and not current_roles.has(FAKE_ROLE_ID)
	)


func _critic_contract_matches(
	case_definition: CaseDefinition,
	runtime: CaseRuntimeState,
	roles: Array[RoleDefinition]
) -> bool:
	var critic: SuspectDefinition = _find_suspect(case_definition, 3)
	var fake_role: RoleDefinition = _find_role(roles, FAKE_ROLE_ID)
	return (
		critic != null
		and fake_role != null
		and critic.true_role_id == &"critic"
		and critic.displayed_role_id == FAKE_ROLE_ID
		and critic.impersonated_role_id == FAKE_ROLE_ID
		and critic.is_impersonating
		and critic.true_alignment == CaseEnums.Alignment.EVIL
		and critic.role_group == CaseEnums.RoleGroup.NGHICH_THAN
		and CaseProceduralPretendCapability.can_pretend_authored_compatible(&"critic", fake_role)
		and CaseRolePoolService.is_role_listed(case_definition, FAKE_ROLE_ID)
		and CaseRolePoolService.is_listed_current_role_absent(case_definition, runtime, FAKE_ROLE_ID)
		and not CaseRolePoolService.current_role_ids_in_play(case_definition, runtime).has(FAKE_ROLE_ID)
	)


func _mailman_result_matches(
	case_definition: CaseDefinition,
	runtime: CaseRuntimeState,
	roles: Array[RoleDefinition]
) -> bool:
	var result: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(
		case_definition, 2, roles, {}, runtime
	)
	return (
		result != null
		and result.behavior_role_id == &"mailman"
		and result.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL
		and result.in_play_role_id == PRESENT_ROLE_ID
		and result.not_in_play_role_id == FAKE_ROLE_ID
		and result.claimed_in_play_is_true
		and result.claimed_not_in_play_is_true
		and result.text == EXPECTED_MAILMAN_TEXT
	)


func _public_views_match(
	case_definition: CaseDefinition,
	runtime: CaseRuntimeState,
	roles: Array[RoleDefinition]
) -> bool:
	if runtime == null:
		return false
	for suspect_id: int in [2, 3]:
		var suspect_runtime: SuspectRuntimeState = runtime.find_suspect(suspect_id)
		if suspect_runtime != null:
			suspect_runtime.is_investigated = true
	var views: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(
		case_definition, runtime, roles
	)
	return (
		_public_view_matches(views, 2, "Dịch Phu", EXPECTED_MAILMAN_TEXT)
		and _public_role_matches(views, 3, "Ngự Khuyển Quan")
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
	if reveal == null:
		return false
	for truth: SuspectTruthReveal in reveal.suspect_truths:
		if truth == null or truth.suspect_id != 3:
			continue
		return (
			truth.true_role_name == "Nhà Phê Bình"
			and truth.displayed_role_name == "Ngự Khuyển Quan"
			and truth.impersonated_role_name == "Ngự Khuyển Quan"
			and truth.alignment_label == "Phe Ác"
			and truth.role_group_label == "Nghịch Thần"
			and truth.is_impersonating
		)
	return false


func _evil_answer_matches(case_definition: CaseDefinition) -> bool:
	return (
		case_definition != null
		and case_definition.evil_suspect_ids == PackedInt32Array([3, 5])
		and case_definition.accomplice_suspect_ids == PackedInt32Array([5])
		and case_definition.traitor_suspect_ids == PackedInt32Array([3])
	)


func _fresh_runtime(case_definition: CaseDefinition) -> CaseRuntimeState:
	if case_definition == null:
		return null
	var runtime: CaseRuntimeState = CaseRuntimeState.new()
	var no_players: Array[PlayerCaseState] = []
	runtime.initialize(case_definition, no_players)
	return runtime


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


func _public_role_matches(
	views: Array[SuspectPublicViewData],
	suspect_id: int,
	role_name: String
) -> bool:
	for view: SuspectPublicViewData in views:
		if view != null and view.suspect_id == suspect_id:
			return view.is_investigated and view.public_role_name == role_name
	return false


func _find_suspect(case_definition: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	if case_definition == null:
		return null
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null


func _find_role(roles: Array[RoleDefinition], role_id: StringName) -> RoleDefinition:
	for role: RoleDefinition in roles:
		if role != null and role.role_id == role_id:
			return role
	return null


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "HV4 Critic and Mailman human verification invariant",
	})
