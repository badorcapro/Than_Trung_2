extends RefCounted

const BOARD_SCENE := preload("res://scenes/case_gameplay/CaseBoard.tscn")
const CASE_SCENE := preload("res://scenes/case_gameplay/VSCaseMain.tscn")
const INSPECTION := preload("res://scripts/tools/CaseSolverInspectionService.gd")


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var case_definition := CaseDefinition.new()
	case_definition.case_id = &"therapist_sparse_4x4_smoke"
	case_definition.set_meta(&"board_columns", 4)
	case_definition.set_meta(&"board_slot_count", 16)
	case_definition.suspected_role_ids = [&"therapist", &"tutorial_mobster"]
	case_definition.suspects.append(_suspect(1, 5, &"therapist", CaseEnums.RoleGroup.CHINH_NHAN, CaseEnums.Alignment.GOOD))
	case_definition.suspects.append(_suspect(2, 10, &"tutorial_mobster", CaseEnums.RoleGroup.TONG_PHAM, CaseEnums.Alignment.EVIL))
	var spatial := CaseSpatialService.new()
	var neighbourhood: PackedInt32Array = spatial.orthogonal_neighbour_slots_for_case(case_definition, 5)
	var count: int = spatial.count_adjacent_true_evil(case_definition, 1)
	var information: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(case_definition, 1, roles)
	case_definition.suspects[1].board_slot = 9
	var adjacent_count: int = spatial.count_adjacent_true_evil(case_definition, 1)
	case_definition.suspects[1].board_slot = 10
	rows.append(_row("Ngự Y 4x4 counts lattice neighbours, not diagonal suspects", neighbourhood == PackedInt32Array([1, 4, 6, 9]) and count == 0 and adjacent_count == 1 and information != null and information.numeric_value == 0))
	case_definition.suspects.append(_suspect(3, 1, &"tutorial_priest", CaseEnums.RoleGroup.CHINH_NHAN, CaseEnums.Alignment.GOOD))
	var runtime := CaseRuntimeState.new()
	var therapist_state := SuspectRuntimeState.new(1, &"therapist")
	therapist_state.is_investigated = true
	runtime.suspects.append(therapist_state)
	var mobster_state := SuspectRuntimeState.new(2, &"tutorial_mobster")
	mobster_state.is_investigated = true
	runtime.suspects.append(mobster_state)
	var views: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(case_definition, runtime, roles)
	var therapist_view: SuspectPublicViewData = views[0] if not views.is_empty() else null
	var board: CaseBoardController = BOARD_SCENE.instantiate() as CaseBoardController
	var locations: Array[BoardLocationDefinition] = []
	var function_records: Array[PublicFunctionRecord] = []
	board.populate(locations, views, function_records, -1, 4, 16)
	board.apply_relation_hover_for_smoke(1)
	var zero_grid: GridContainer = board.get_node("%Grid") as GridContainer
	var zero_source: SuspectCardController = zero_grid.get_child(5) as SuspectCardController
	var zero_north: SuspectCardController = zero_grid.get_child(1) as SuspectCardController
	var zero_diagonal: SuspectCardController = zero_grid.get_child(10) as SuspectCardController
	var zero_display: bool = (
		therapist_view != null
		and therapist_view.public_relation_hover_enabled
		and therapist_view.public_relation_suspect_ids.is_empty()
		and therapist_view.public_relation_board_slots.is_empty()
		and board.get_public_relation_ids_for_smoke(1).is_empty()
		and board.get_public_relation_slots_for_smoke(1).is_empty()
		and not board.is_relation_footprint_visible_for_smoke(1)
		and not board.is_relation_footprint_visible_for_smoke(4)
		and not board.is_relation_footprint_visible_for_smoke(6)
		and not board.is_relation_footprint_visible_for_smoke(9)
		and zero_source.get_relation_emphasis_scale_for_smoke() == Vector2(1.02, 1.02)
		and zero_north.get_relation_emphasis_scale_for_smoke() == Vector2(0.94, 0.94)
		and zero_diagonal.get_relation_emphasis_scale_for_smoke() == Vector2(0.94, 0.94)
		and zero_north.get_relation_emphasis_modulate_for_smoke().a < 1.0
	)
	board.clear_relation_hover_for_smoke()
	board.free()
	rows.append(_row("Ngự Y count zero highlights no board targets", zero_display))
	case_definition.suspects.remove_at(2)
	var positive_case := CaseDefinition.new()
	positive_case.set_meta(&"board_columns", 4)
	positive_case.set_meta(&"board_slot_count", 16)
	positive_case.suspects.append(_suspect(1, 5, &"therapist", CaseEnums.RoleGroup.CHINH_NHAN, CaseEnums.Alignment.GOOD))
	positive_case.suspects.append(_suspect(2, 9, &"tutorial_mobster", CaseEnums.RoleGroup.TONG_PHAM, CaseEnums.Alignment.EVIL))
	positive_case.suspects.append(_suspect(3, 1, &"tutorial_priest", CaseEnums.RoleGroup.CHINH_NHAN, CaseEnums.Alignment.GOOD))
	positive_case.suspects.append(_suspect(4, 10, &"reporter", CaseEnums.RoleGroup.CHINH_NHAN, CaseEnums.Alignment.GOOD))
	var crime_scene := BoardLocationDefinition.new()
	crime_scene.location_id = BoardLocationDefinition.LOCATION_CRIME_SCENE
	crime_scene.board_slot = 4
	positive_case.board_locations.append(crime_scene)
	var positive_information: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(positive_case, 1, roles)
	var positive_views: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(positive_case, runtime, roles)
	var positive_view: SuspectPublicViewData = positive_views[0] if not positive_views.is_empty() else null
	var positive_board: CaseBoardController = BOARD_SCENE.instantiate() as CaseBoardController
	positive_board.populate(positive_case.location_definitions(), positive_views, function_records, -1, 4, 16)
	positive_board.apply_relation_hover_for_smoke(1)
	var positive_grid: GridContainer = positive_board.get_node("%Grid") as GridContainer
	var positive_source: SuspectCardController = positive_grid.get_child(5) as SuspectCardController
	var north_card: SuspectCardController = positive_grid.get_child(1) as SuspectCardController
	var south_card: SuspectCardController = positive_grid.get_child(9) as SuspectCardController
	var diagonal_card: SuspectCardController = positive_grid.get_child(10) as SuspectCardController
	var west_location: Control = positive_grid.get_child(4) as Control
	var east_empty: Control = positive_grid.get_child(6) as Control
	var positive_display: bool = (
		positive_information != null
		and positive_information.numeric_value == 1
		and positive_view != null
		and positive_view.public_relation_hover_enabled
		and positive_view.public_relation_suspect_ids == PackedInt32Array([2, 3])
		and positive_view.public_relation_board_slots.is_empty()
		and positive_board.get_public_relation_ids_for_smoke(1) == PackedInt32Array([2, 3])
		and positive_source.get_relation_emphasis_scale_for_smoke() == Vector2(1.02, 1.02)
		and north_card.get_relation_emphasis_scale_for_smoke() == Vector2(1.06, 1.06)
		and south_card.get_relation_emphasis_scale_for_smoke() == Vector2(1.06, 1.06)
		and diagonal_card.get_relation_emphasis_scale_for_smoke() == Vector2(0.94, 0.94)
		and diagonal_card.get_relation_emphasis_modulate_for_smoke().a < 1.0
		and not positive_board.is_relation_footprint_visible_for_smoke(6)
		and not positive_board.is_relation_footprint_visible_for_smoke(4)
		and west_location.modulate == Color.WHITE
		and west_location.scale == Vector2.ONE
		and east_empty.scale == Vector2.ONE
	)
	positive_board.free()
	rows.append(_row("Ngự Y positive count highlights all occupied cardinal suspects only", positive_display))
	var report: Dictionary = INSPECTION.new().inspect(case_definition, runtime, roles)
	var lines: PackedStringArray = report.get("lines", PackedStringArray())
	var steps: Array = report.get("steps", [])
	var inspection_source: String = FileAccess.get_file_as_string("res://scripts/tools/CaseSolverInspectionService.gd")
	rows.append(_row("DEV inspection replays public clues through solver", report.has("status") and steps.size() > 0 and "\n".join(lines).contains("KẾT LUẬN") and not inspection_source.contains("hidden_evil_suspect_ids")))
	var explanation: String = "\n".join(lines)
	var first_step: Dictionary = steps[0] if not steps.is_empty() else {}
	rows.append(_row("DEV explanation has readable sections and per-clue sets", explanation.contains("KẾT LUẬN") and explanation.contains("CÁC GIẢ THUYẾT PHE ÁC BAN ĐẦU") and explanation.contains("KIỂM TRA TỪNG LỜI KHAI") and explanation.contains("KẾT LUẬN CUỐI") and first_step.has("clue") and first_step.has("removed") and first_step.has("remaining_sets")))
	var public_view = GeneratedPublicCaseView.create_manual(4, 4, 1, [GeneratedPublicSuspectView.create(1, 5, &"therapist", CaseEnums.RoleGroup.CHINH_NHAN), GeneratedPublicSuspectView.create(2, 10, &"tutorial_mobster", CaseEnums.RoleGroup.CHINH_NHAN)])
	var therapist_clue := GeneratedPublicClue.new()
	therapist_clue.suspect_id = 1
	therapist_clue.behavior_role_id = &"therapist"
	therapist_clue.numeric_value = 1
	var numeric_reason: String = INSPECTION.new()._contradiction_reason(therapist_clue, PackedInt32Array([2]), public_view)
	rows.append(_row("DEV explanation states a grounded lattice contradiction", numeric_reason.contains("Bốn ô kề") and numeric_reason.contains("0") and numeric_reason.contains("1")))
	var scene: VSCaseMainController = CASE_SCENE.instantiate() as VSCaseMainController
	var button: Button = scene.find_child("DebugSolverButton", true, false) as Button
	var result_button: Button = scene.find_child("DevBackButton", true, false) as Button
	var overlay: Control = scene.find_child("SolverInspectionOverlay", true, false) as Control
	var controller_source: String = FileAccess.get_file_as_string("res://scripts/presentation/case_gameplay/VSCaseMainController.gd")
	rows.append(_row("DEV solver inspection is gated and separate from Results", button != null and not button.visible and result_button != null and overlay != null and not overlay.visible and scene.has_method("_on_debug_solver_pressed") and controller_source.contains("OS.is_debug_build() and truth_ready") and controller_source.contains("integration_truth_acknowledged.emit()") and controller_source.contains("debug_solver_button.pressed.connect(_on_debug_solver_pressed)")))
	scene.free()
	return rows


func _suspect(id: int, slot: int, role_id: StringName, group: int, alignment: int) -> SuspectDefinition:
	var suspect := SuspectDefinition.new()
	suspect.suspect_id = id
	suspect.board_slot = slot
	suspect.true_role_id = role_id
	suspect.displayed_role_id = role_id
	suspect.role_group = group
	suspect.true_alignment = alignment
	return suspect


func _row(name: String, passed: bool) -> Dictionary:
	return {"name": name, "passed": passed, "detail": "4x4 Therapist lattice and DEV public-only solver inspection"}
