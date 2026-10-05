extends RefCounted

const REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")
const GENERATOR := preload("res://scripts/domain/cases/CaseGenerator.gd")
const CAPABILITY := preload("res://scripts/domain/cases/CaseProceduralPretendCapability.gd")
const HIDDEN_DRAFT := preload("res://scripts/domain/cases/HiddenCaseDraft.gd")
const GENERATED_SUSPECT := preload("res://scripts/domain/cases/GeneratedSuspect.gd")
const CASE_SCENE := preload("res://scenes/case_gameplay/VSCaseMain.tscn")
const CARD_SCENE := preload("res://scenes/case_gameplay/SuspectCard.tscn")
const RED := Color(0.78, 0.17, 0.17, 1.0)


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	_test_modal_layers(rows)
	_test_procedural_mobster(rows, roles)
	_test_scoundrel(rows, roles)
	return rows


func _test_modal_layers(rows: Array[Dictionary]) -> void:
	var scene: Control = CASE_SCENE.instantiate() as Control
	var card: Control = CARD_SCENE.instantiate() as Control
	var role_overlay: Control = scene.get_node_or_null("%RoleReferenceOverlay") as Control
	var private_overlay: Control = scene.get_node_or_null("%PrivateKnowledgeOverlay") as Control
	var card_visual: Control = card.get_node_or_null("%CardVisual") as Control
	var hand: Control = card.get_node_or_null("%FunctionHandMarker") as Control
	var dead: Control = card.get_node_or_null("%DeadMarker") as Control
	var top_card_layer: int = maxi(card_visual.z_index, maxi(hand.z_index, dead.z_index)) if card_visual != null and hand != null and dead != null else 999
	_add(rows, "M6A-R suspect-info modal stacks over every card child", role_overlay != null and role_overlay.get_parent() == scene and role_overlay.z_index > top_card_layer)
	_add(rows, "M6A-R private-info modal shares safe overlay boundary", private_overlay != null and private_overlay.get_parent() == scene and private_overlay.z_index > top_card_layer)
	card.free()
	scene.free()


func _test_procedural_mobster(rows: Array[Dictionary], roles: Array[RoleDefinition]) -> void:
	var ids: Array[StringName] = [&"tutorial_priest", &"reporter", &"tutorial_mobster"]
	var locations: Array[StringName] = [BoardLocationDefinition.LOCATION_CRIME_SCENE]
	var request: CaseGenerationRequest = REQUEST.create(112233, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY, ids, locations, 3)
	var generator = GENERATOR.new()
	var generated: CaseGenerationResult = generator.generate(request, roles)
	var definition: CaseDefinition = generator.case_definition_from_result(generated)
	var mobster: SuspectDefinition = _find_suspect(definition, &"tutorial_mobster")
	var target: SuspectDefinition = null
	if mobster != null:
		for suspect: SuspectDefinition in definition.suspects:
			if suspect.suspect_id != mobster.suspect_id and suspect.true_role_id == mobster.impersonated_role_id:
				target = suspect
	var target_role: RoleDefinition = _find_role(roles, mobster.impersonated_role_id) if mobster != null else null
	_add(rows, "M6A-R procedural Mobster has valid in-play pretend target", mobster != null and mobster.true_role_id == &"tutorial_mobster" and mobster.role_group == CaseEnums.RoleGroup.TONG_PHAM and mobster.true_alignment == CaseEnums.Alignment.EVIL and mobster.is_impersonating and mobster.displayed_role_id == mobster.impersonated_role_id and mobster.displayed_role_id != mobster.true_role_id and target != null and CAPABILITY.can_pretend(mobster.true_role_id, target_role))
	var runtime := CaseRuntimeState.new()
	var before_view: SuspectPublicViewData = null
	var after_view: SuspectPublicViewData = null
	if definition != null and mobster != null:
		runtime.initialize(definition, FixtureRepository.load_players())
		runtime.find_suspect(mobster.suspect_id).is_investigated = true
		before_view = _find_view(CasePublicPresentationBuilder.new().build_suspect_views(definition, runtime, roles), mobster.suspect_id)
	var before_card: SuspectCardController = _card(before_view)
	var displayed_name: String = target_role.display_name if target_role != null else ""
	_add(rows, "M6A-R Mobster before reveal shows only pretended role", before_view != null and before_card != null and before_view.public_role_name == displayed_name and before_card.get_public_role_text() == displayed_name and before_card.get_public_role_text() != "Kẻ Côn Đồ")
	_add(rows, "M6A-R Mobster before reveal uses displayed group color", before_view != null and before_card != null and target_role != null and before_view.public_role_group == target_role.role_group and before_card.get_public_role_color_for_smoke() == _color_for_group(target_role.role_group))
	var info: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(definition, mobster.suspect_id, roles) if definition != null and mobster != null else null
	_add(rows, "M6A-R Mobster uses pretended behavior while lying", info != null and info.behavior_role_id == mobster.displayed_role_id and info.truth_mode == InvestigationInformationResult.TruthMode.LYING and before_view != null and before_view.public_investigation_statement == info.public_text())
	if before_card != null:
		before_card.free()
	if definition != null and mobster != null:
		runtime.is_settled = true
		runtime.settlement_result = CaseSettlementResult.new()
		CaseTruthRevealBuilder.new().build(definition, runtime, roles)
		after_view = _find_view(CasePublicPresentationBuilder.new().build_suspect_views(definition, runtime, roles), mobster.suspect_id)
	var after_card: SuspectCardController = _card(after_view)
	_add(rows, "M6A-R Full Reveal names true Mobster", after_view != null and after_card != null and after_view.truth_true_role_name == "Kẻ Côn Đồ" and after_card.get_public_role_text() == "Kẻ Côn Đồ")
	_add(rows, "M6A-R Full Reveal Mobster is Underling red", after_view != null and after_card != null and after_view.truth_role_group == CaseEnums.RoleGroup.TONG_PHAM and after_card.get_public_role_color_for_smoke() == RED)
	_add(rows, "M6A-R Full Reveal preserves Mobster pretend relation", after_view != null and after_view.truth_impersonated_role_name == displayed_name and after_view.reveal_default_statement == "Ta giả danh %s." % displayed_name)
	if after_card != null:
		after_card.free()
	_add(rows, "M6A-R Mobster without eligible target rejects instead of self-displaying", _mobster_without_target_rejected(roles))


func _test_scoundrel(rows: Array[Dictionary], roles: Array[RoleDefinition]) -> void:
	var definition: CaseDefinition = FixtureRepository.load_tutorial_case_001()
	var scoundrel: SuspectDefinition = _find_suspect(definition, &"tutorial_scoundrel")
	var runtime := CaseRuntimeState.new()
	var view: SuspectPublicViewData = null
	if definition != null and scoundrel != null:
		runtime.initialize(definition, FixtureRepository.load_players())
		runtime.find_suspect(scoundrel.suspect_id).is_investigated = true
		view = _find_view(CasePublicPresentationBuilder.new().build_suspect_views(definition, runtime, roles), scoundrel.suspect_id)
	var card: SuspectCardController = _card(view)
	_add(rows, "M6A-R Scoundrel remains self-displayed without pretend", scoundrel != null and scoundrel.true_role_id == &"tutorial_scoundrel" and scoundrel.displayed_role_id == scoundrel.true_role_id and not scoundrel.is_impersonating and String(scoundrel.impersonated_role_id).is_empty())
	_add(rows, "M6A-R Scoundrel reveals name without announcement", view != null and card != null and card.get_public_role_text() == "Kẻ Bất Lương" and view.public_investigation_statement.is_empty())
	_add(rows, "M6A-R Scoundrel is Underling red", scoundrel != null and view != null and card != null and scoundrel.role_group == CaseEnums.RoleGroup.TONG_PHAM and view.public_role_group == CaseEnums.RoleGroup.TONG_PHAM and card.get_public_role_color_for_smoke() == RED)
	if card != null:
		card.free()


func _mobster_without_target_rejected(roles: Array[RoleDefinition]) -> bool:
	var mobster_role: RoleDefinition = _find_role(roles, &"tutorial_mobster")
	var copycat_role: RoleDefinition = _find_role(roles, &"copycat")
	var unsupported_good: RoleDefinition = _find_role(roles, &"role_meddler_a")
	if mobster_role == null or copycat_role == null or unsupported_good == null:
		return false
	var draft = HIDDEN_DRAFT.new()
	draft.suspects.append(GENERATED_SUSPECT.create(1, 0, mobster_role))
	draft.suspects.append(GENERATED_SUSPECT.create(2, 1, copycat_role))
	var by_id: Dictionary = {}
	by_id[mobster_role.role_id] = mobster_role
	by_id[copycat_role.role_id] = copycat_role
	var rng := RandomNumberGenerator.new()
	rng.seed = 17
	var draft_rejected: bool = not GENERATOR.new()._assign_pretend_roles(draft, by_id, rng)
	var ids: Array[StringName] = [&"tutorial_mobster", &"role_meddler_a"]
	var request: CaseGenerationRequest = REQUEST.create(17, 3, 3, REQUEST.PROFILE_TUTORIAL_EASY, ids, [], 2)
	var generated: CaseGenerationResult = GENERATOR.new().generate(request, roles)
	return draft_rejected and generated != null and not generated.is_success() and generated.error_code == CaseGenerationResult.ERROR_IMPOSSIBLE_REQUEST


func _find_role(roles: Array[RoleDefinition], role_id: StringName) -> RoleDefinition:
	for role: RoleDefinition in roles:
		if role != null and role.role_id == role_id:
			return role
	return null


func _find_suspect(definition: CaseDefinition, role_id: StringName) -> SuspectDefinition:
	if definition != null:
		for suspect: SuspectDefinition in definition.suspects:
			if suspect != null and suspect.true_role_id == role_id:
				return suspect
	return null


func _find_view(views: Array[SuspectPublicViewData], suspect_id: int) -> SuspectPublicViewData:
	for view: SuspectPublicViewData in views:
		if view != null and view.suspect_id == suspect_id:
			return view
	return null


func _card(view: SuspectPublicViewData) -> SuspectCardController:
	if view == null:
		return null
	var card: SuspectCardController = CARD_SCENE.instantiate() as SuspectCardController
	if card != null:
		card.configure(view)
	return card


func _color_for_group(group: int) -> Color:
	match group:
		CaseEnums.RoleGroup.CHINH_NHAN:
			return Color(0.12, 0.47, 0.68, 1.0)
		CaseEnums.RoleGroup.HIEU_SU:
			return Color(0.74, 0.48, 0.10, 1.0)
		CaseEnums.RoleGroup.TONG_PHAM:
			return RED
		CaseEnums.RoleGroup.NGHICH_THAN:
			return Color(0.48, 0.20, 0.72, 1.0)
		_:
			return Color.TRANSPARENT


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({"name": name, "passed": passed, "detail": "M6A/runtime modal and role-presentation regression"})
