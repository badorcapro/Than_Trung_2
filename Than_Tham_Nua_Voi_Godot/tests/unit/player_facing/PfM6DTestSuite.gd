class_name PfM6DTestSuite
extends RefCounted

const SETUP_SESSION := preload(
	"res://scripts/application/player_facing/PlayerFacingSetupSession.gd"
)
const NEXT_CASE_SESSION := preload(
	"res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd"
)
const ACCEPTANCE_SERVICE := preload("res://scripts/domain/cases/CaseGenerationAcceptanceService.gd")
const PUBLIC_CASE_VIEW := preload("res://scripts/domain/cases/GeneratedPublicCaseView.gd")
const PUBLIC_SOLVER := preload("res://scripts/domain/cases/CaseGeneratorPublicSolver.gd")
const PRETEND_CAPABILITY := preload("res://scripts/domain/cases/CaseProceduralPretendCapability.gd")
const PLAYER_SCENE := preload("res://scenes/player_facing/PlayerFacingStart.tscn")

const PLAYER_CONTROLLER := (
	"res://scripts/presentation/player_facing/PlayerFacingStartController.gd"
)
const NEXT_CASE_SESSION_SOURCE := (
	"res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd"
)


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_test_first_case_option_boundary(rows)
	_test_first_case_option_selection(rows)
	_test_full_reveal_results_transition(rows)
	_test_later_round_excludes_selected_signature(rows)
	_test_controller_round1_routing(rows)
	_test_production_source_boundary(rows)
	return rows


func _test_first_case_option_boundary(rows: Array[Dictionary]) -> void:
	var setup: SETUP_SESSION = _confirmed_setup()
	var flow: NEXT_CASE_SESSION = NEXT_CASE_SESSION.new()
	var initialized: Dictionary = flow.initialize_player_facing_case_options(setup.match_state)
	var prepared: Dictionary = flow.prepare_default_next_case_options()
	var option_rows: Array[Dictionary] = flow.case_option_presentations()
	var warehouse_before: RefCounted = flow.default_next_case_warehouse
	var signature_before: String = (
		flow.next_case_option_set.option_set_signature
		if flow.next_case_option_set != null
		else ""
	)
	var prepared_again: Dictionary = flow.prepare_default_next_case_options()
	var signature_after: String = (
		flow.next_case_option_set.option_set_signature
		if flow.next_case_option_set != null
		else ""
	)
	_add(
		rows,
		"PF-M6D Round 1 enters procedural option boundary before Case launch",
		bool(initialized.get("success", false))
		and flow.match_state == setup.match_state
		and flow.match_state.current_round_number == 1
		and flow.match_state.match_completion_state == &"NEXT_CASE_REQUIRED"
		and flow.round_state == null
		and flow.case_definition == null
	)
	_add(
		rows,
		"PF-M6D Round 1 default source composes exactly three options",
		bool(prepared.get("success", false))
		and option_rows.size() == 3
		and flow.next_case_option_definitions.size() == 3
	)
	_add(
		rows,
		"PF-M6D default warehouse is session-owned and prepare is idempotent",
		warehouse_before != null
		and flow.default_next_case_warehouse == warehouse_before
		and bool(prepared_again.get("duplicate_noop", false))
		and signature_before == signature_after
	)
	_test_canonical_procedural_pool(rows, flow)


func _test_canonical_procedural_pool(rows: Array[Dictionary], flow: NEXT_CASE_SESSION) -> void:
	var request: CaseGenerationRequest = flow._default_next_case_generation_request()
	var expected_ids: Array[StringName] = [
		&"tutorial_priest", &"reporter", &"therapist", &"weatherman",
		&"blood_hound", &"mathematician", &"mailman", &"tutorial_mobster",
		&"copycat", &"conman", &"poisoner", &"barkeep", &"spectre",
		&"tutorial_scoundrel",
		&"tailor",
		&"vigilante",
		&"clock_maker",
		&"surgeon",
		&"serial_killer",
		&"critic",
	]
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var canonical_roles: bool = request.allowed_role_ids == expected_ids
	for role_id: StringName in request.allowed_role_ids:
		var found: bool = false
		for role: RoleDefinition in roles:
			if role != null and role.role_id == role_id:
				found = not role.is_fixture_placeholder
				break
		canonical_roles = canonical_roles and found and (
			PUBLIC_SOLVER.SUPPORTED_PUBLIC_ROLE_IDS.has(role_id)
			or PRETEND_CAPABILITY.is_pretender(role_id)
		)
	var warehouse: CaseSeedWarehouseBuildResult = flow.default_next_case_warehouse as CaseSeedWarehouseBuildResult
	var accepted: CaseGenerationAcceptanceResult
	if warehouse != null and not warehouse.entries.is_empty():
		accepted = ACCEPTANCE_SERVICE.new().accept_unique_candidate(
			warehouse.entries[0].request(), roles, NEXT_CASE_SESSION.DEFAULT_NEXT_CASE_MAX_ATTEMPTS
		)
	var candidate: CaseGenerationResult
	var solver_result: CaseGeneratorSolverResult
	if accepted != null:
		candidate = accepted.accepted_candidate as CaseGenerationResult
		solver_result = accepted.accepted_solver_result as CaseGeneratorSolverResult
	var generated_case: CaseDefinition
	var validation_passed: bool = false
	if candidate != null and candidate.is_success():
		generated_case = CaseGenerator.new().case_definition_from_result(candidate)
	if generated_case != null:
		var validation: Dictionary = CaseDefinitionValidator.new().validate(
			generated_case, roles, FixtureRepository.load_players()
		)
		validation_passed = bool(validation.get("passed", false))
	var valid_case: bool = validation_passed and _case_has_no_placeholder(generated_case)
	var public_view: GeneratedPublicCaseView
	var replayed: CaseGeneratorSolverResult
	if candidate != null:
		public_view = PUBLIC_CASE_VIEW.from_generation_result(candidate, roles)
		replayed = PUBLIC_SOLVER.new().solve(public_view, roles)
	var warehouse_valid: bool = warehouse != null and warehouse.entries.size() >= 3
	if warehouse_valid:
		for entry: CaseSeedWarehouseEntry in warehouse.entries:
			if entry == null:
				warehouse_valid = false
				break
			var entry_request: CaseGenerationRequest = entry.request()
			if entry_request.allowed_role_ids.has(&"role_meddler_a"):
				warehouse_valid = false
				break
	var options_valid: bool = (
		flow.next_case_option_set != null
		and flow.next_case_option_set.success
		and flow.next_case_option_definitions.size() == 3
		and flow.next_case_option_set.option_candidate_signatures.size() == 3
	)
	var signatures: Dictionary = {}
	if options_valid:
		for index: int in range(3):
			var option_case: CaseDefinition = flow.next_case_option_definitions[index]
			var signature: String = flow.next_case_option_set.option_candidate_signatures[index]
			if signature.is_empty() or signatures.has(signature) or not _case_has_no_placeholder(option_case):
				options_valid = false
				break
			signatures[signature] = true
	var fixture: CaseDefinition = FixtureRepository.load_case()
	var fixture_has_placeholder: bool = false
	if fixture != null:
		for suspect: SuspectDefinition in fixture.suspects:
			fixture_has_placeholder = fixture_has_placeholder or suspect.true_role_id == &"role_meddler_a"
	_add(rows, "M5E-R default procedural pool excludes placeholder Meddler", not request.allowed_role_ids.has(&"role_meddler_a"))
	_add(rows, "M5E-R default procedural pool uses only canonical solver roles", canonical_roles)
	_add(rows, "M5E-R generated canonical Case validates structurally", valid_case)
	_add(rows, "M5E-R solver uniquely resolves canonical public world", (
		replayed != null
		and replayed.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION
		and candidate != null
		and replayed.compare_unique_solution_to_ground_truth(candidate.hidden_case_draft.hidden_evil_suspect_ids)
	))
	_add(rows, "M5E-R M3 accepts canonical candidate", (
		accepted != null and accepted.success and valid_case
		and solver_result != null
		and solver_result.status == CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION
	))
	_add(rows, "M5E-R warehouse retains only canonical requests", warehouse_valid)
	_add(rows, "M5E-R M5A composes three distinct canonical options", options_valid)
	_add(rows, "M5E-R player-facing options contain no placeholder Meddler", options_valid and flow.case_option_presentations().size() == 3)
	_add(rows, "M5E-R authored fixture retains placeholder Meddler", fixture_has_placeholder)


func _case_has_no_placeholder(case_definition: CaseDefinition) -> bool:
	if case_definition == null:
		return false
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect == null or suspect.true_role_id == &"role_meddler_a":
			return false
	return true


func _test_first_case_option_selection(rows: Array[Dictionary]) -> void:
	var setup: SETUP_SESSION = _confirmed_setup()
	var flow: NEXT_CASE_SESSION = NEXT_CASE_SESSION.new()
	flow.initialize_player_facing_case_options(setup.match_state)
	flow.prepare_default_next_case_options()
	var selected_index: int = 1
	var selected_signature: String = (
		flow.next_case_option_set.option_candidate_signatures[selected_index]
		if flow.next_case_option_set != null
		else ""
	)
	var unselected_signatures: Array[String] = []
	if flow.next_case_option_set != null:
		for option_index: int in range(flow.next_case_option_set.option_candidate_signatures.size()):
			if option_index != selected_index:
				unselected_signatures.append(flow.next_case_option_set.option_candidate_signatures[option_index])
	var started: Dictionary = flow.start_next_round_from_option(selected_index)
	var unselected_committed: bool = false
	for signature: String in unselected_signatures:
		if flow.match_state.used_case_candidate_signatures.has(signature):
			unselected_committed = true
	_add(
		rows,
		"PF-M6D selected Round 1 option launches through M5B start path",
		bool(started.get("success", false))
		and flow.round_state != null
		and flow.round_state.round_number == 1
		and flow.active_case_definition == flow.next_case_option_definitions[selected_index]
		and flow.selected_case_option_index == selected_index
	)
	_add(
		rows,
		"PF-M6D only selected Round 1 signature becomes session-used",
		not selected_signature.is_empty()
		and flow.match_state.used_case_candidate_signatures.has(selected_signature)
		and not unselected_committed
	)


func _test_full_reveal_results_transition(rows: Array[Dictionary]) -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		_add(rows, "PF-M6D selected Case Full Reveal advances to Results", false)
		return
	var setup: SETUP_SESSION = _confirmed_setup()
	var flow: NEXT_CASE_SESSION = NEXT_CASE_SESSION.new()
	var initialized: Dictionary = flow.initialize_player_facing_case_options(setup.match_state)
	var prepared: Dictionary = (
		flow.prepare_default_next_case_options()
		if bool(initialized.get("success", false)) else {}
	)
	var presented: Dictionary = (
		setup.mark_first_case_selection_required()
		if bool(prepared.get("success", false)) else {}
	)
	var controller: PlayerFacingStartController = PLAYER_SCENE.instantiate() as PlayerFacingStartController
	if controller == null:
		_add(rows, "PF-M6D selected Case Full Reveal advances to Results", false)
		return
	tree.root.add_child(controller)
	controller.setup = setup
	controller.case_flow = flow
	if bool(presented.get("success", false)):
		controller.call("_start_next_case_from_option", 0)
	var case_scene: VSCaseMainController = controller.case_controller
	var selected_case_loaded: bool = (
		case_scene != null
		and case_scene.case_definition == flow.active_case_definition
		and flow.round_state != null
		and case_scene.case_definition.case_id == flow.round_state.case_id
	)
	if selected_case_loaded:
		case_scene.runtime_state.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
		case_scene.call("_refresh_all_presentation")
	var completion_applied: bool = (
		selected_case_loaded
		and flow.round_state.settlement_applied
		and bool(case_scene.get("_integration_completion_emitted"))
	)
	var results_button: Button
	if case_scene != null:
		results_button = case_scene.get_node_or_null("%DevBackButton") as Button
	if results_button != null and completion_applied:
		results_button.pressed.emit()
	var reached_results: bool = (
		completion_applied
		and setup.phase == SETUP_SESSION.Phase.CASE_RESULTS
		and not controller.case_host.visible
		and controller.results_panel.visible
	)
	_add(rows, "PF-M6D selected Case Full Reveal advances to Results", reached_results)
	tree.root.remove_child(controller)
	controller.free()


func _test_later_round_excludes_selected_signature(rows: Array[Dictionary]) -> void:
	var setup: SETUP_SESSION = _confirmed_setup()
	var flow: NEXT_CASE_SESSION = NEXT_CASE_SESSION.new()
	flow.initialize_player_facing_case_options(setup.match_state)
	flow.prepare_default_next_case_options()
	var selected_signature: String = (
		flow.next_case_option_set.option_candidate_signatures[0]
		if flow.next_case_option_set != null
		else ""
	)
	flow.start_next_round_from_option(0)
	var completed: Dictionary = flow.complete_round_1_programmatically()
	var prepared_next: Dictionary = flow.prepare_default_next_case_options()
	var next_signatures: Array[String] = []
	if flow.next_case_option_set != null:
		for signature: String in flow.next_case_option_set.option_candidate_signatures:
			next_signatures.append(signature)
	_add(
		rows,
		"PF-M6D later option composition excludes selected Round 1 signature",
		bool(completed.get("success", false))
		and bool(prepared_next.get("success", false))
		and not selected_signature.is_empty()
		and flow.match_state.used_case_candidate_signatures.has(selected_signature)
		and not next_signatures.has(selected_signature)
	)


func _test_controller_round1_routing(rows: Array[Dictionary]) -> void:
	var source: String = FileAccess.get_file_as_string(PLAYER_CONTROLLER)
	var confirm_start: int = source.find("func _on_confirm_lineup_pressed()")
	var confirm_end: int = source.find("func _on_start_case_pressed()")
	var confirm_body: String = (
		source.substr(confirm_start, confirm_end - confirm_start)
		if confirm_start >= 0 and confirm_end > confirm_start
		else ""
	)
	_add(
		rows,
		"PF-M6D lineup confirmation prepares first procedural option set",
		confirm_body.contains("initialize_player_facing_case_options(")
		and confirm_body.contains("prepare_default_next_case_options()")
		and confirm_body.contains("setup.mark_first_case_selection_required()")
		and confirm_body.find("prepare_default_next_case_options()") < confirm_body.find("setup.mark_first_case_selection_required()")
		and confirm_body.find("setup.mark_first_case_selection_required()") < confirm_body.find("_refresh_next_case()")
	)
	_add(
		rows,
		"PF-M6D lineup confirmation no longer launches authored case card",
		not confirm_body.contains("_refresh_case_card()")
		and not confirm_body.contains("CASE_SCENE.instantiate()")
		and not confirm_body.contains("initialize_player_facing_case(")
	)
	_add(
		rows,
		"PF-M6D missing procedural options do not show static fallback button",
		source.contains("start_next_case_button.visible = false")
		and source.contains("Chưa có đủ ba Kỳ Án sinh tự động để lựa chọn.")
	)


func _test_production_source_boundary(rows: Array[Dictionary]) -> void:
	var source: String = FileAccess.get_file_as_string(NEXT_CASE_SESSION_SOURCE)
	_add(
		rows,
		"PF-M6D production source uses real generator warehouse pipeline",
		source.contains("CASE_SEED_WAREHOUSE_BUILDER.new().build(")
		and source.contains("FixtureRepository.load_roles()")
		and source.contains("compose_next_case_options(")
		and not source.contains("_fake_attempt_evaluator")
	)
	_add(
		rows,
		"PF-M6D static authored next-Case API remains explicit",
		source.contains("func start_next_round(")
		and source.contains("FixtureRepository.load_case()")
	)


func _confirmed_setup() -> SETUP_SESSION:
	var setup: SETUP_SESSION = SETUP_SESSION.new()
	setup.begin_new_game()
	setup.choose_player_count(3)
	for index: int in range(3):
		setup.select_character(setup.characters[index].character_id)
		setup.lock_current_character()
		if setup.phase == SETUP_SESSION.Phase.PASS_DEVICE:
			setup.continue_after_pass_device()
	setup.confirm_lineup()
	return setup


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "PF-M6D / M5D procedural first-case source bootstrap invariant",
	})
