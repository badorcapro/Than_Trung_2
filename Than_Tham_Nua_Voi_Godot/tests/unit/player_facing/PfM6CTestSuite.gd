class_name PfM6CTestSuite
extends RefCounted

const NEXT_CASE_SESSION := preload(
	"res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd"
)
const CASE_GENERATION_REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")
const CASE_GENERATOR_SOLVER_RESULT := preload("res://scripts/domain/cases/CaseGeneratorSolverResult.gd")
const CASE_SEED_WAREHOUSE_BUILDER := preload("res://scripts/domain/cases/CaseSeedWarehouseBuilder.gd")
const CASE_SEED_WAREHOUSE_BUILD_RESULT := preload("res://scripts/domain/cases/CaseSeedWarehouseBuildResult.gd")
const CASE_SEED_WAREHOUSE_ENTRY := preload("res://scripts/domain/cases/CaseSeedWarehouseEntry.gd")

const PLAYER_SCENE := "res://scenes/player_facing/PlayerFacingStart.tscn"
const PLAYER_CONTROLLER := (
	"res://scripts/presentation/player_facing/PlayerFacingStartController.gd"
)
const NEXT_CASE_SESSION_SOURCE := (
	"res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd"
)


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_test_scene_contract(rows)
	_test_controller_binding_contract(rows)
	_test_option_state_presentation(rows)
	_test_option_selection_binding(rows)
	_test_empty_and_static_paths(rows)
	_test_failed_options_hidden(rows)
	return rows


func _test_scene_contract(rows: Array[Dictionary]) -> void:
	var packed: PackedScene = load(PLAYER_SCENE) as PackedScene
	var root: Node = packed.instantiate() if packed != null else null
	_add(
		rows,
		"PF-M6C next-Case panel exposes three procedural option buttons",
		root != null
		and root.find_child("NextCaseOptions", true, false) is GridContainer
		and root.find_child("NextCaseOption1", true, false) is Button
		and root.find_child("NextCaseOption2", true, false) is Button
		and root.find_child("NextCaseOption3", true, false) is Button
	)
	_add(
		rows,
		"PF-M6C static StartNextCase fallback remains available",
		root != null and root.find_child("StartNextCase", true, false) is Button
	)
	if root != null:
		root.free()


func _test_controller_binding_contract(rows: Array[Dictionary]) -> void:
	var source: String = FileAccess.get_file_as_string(PLAYER_CONTROLLER)
	var next_case_transition: String = _source_between(
		source,
		"func _on_round_summary_continue_pressed()",
		"func _show_management_result"
	)
	_add(
		rows,
		"PF-M6C controller reads stored M5B option state without composing",
		source.contains("case_option_presentations()")
		and not source.contains("compose_next_case_options(")
	)
	_add(
		rows,
		"PF-M6C next-Case transition prepares M5B options before render",
		next_case_transition.contains("prepare_default_next_case_options()")
		and next_case_transition.contains("setup.mark_next_case_required()")
		and next_case_transition.contains("_refresh_next_case()")
		and next_case_transition.find("prepare_default_next_case_options()") < next_case_transition.find("setup.mark_next_case_required()")
		and next_case_transition.find("setup.mark_next_case_required()") < next_case_transition.find("_refresh_next_case()")
	)
	_add(
		rows,
		"PF-M6C option buttons bind through M5B selected-option API",
		source.contains("_start_next_case_from_option(0)")
		and source.contains("_start_next_case_from_option(1)")
		and source.contains("_start_next_case_from_option(2)")
		and source.contains("start_next_round_from_option(option_index)")
	)


func _source_between(source: String, start_marker: String, end_marker: String) -> String:
	var start_index: int = source.find(start_marker)
	if start_index < 0:
		return ""
	var end_index: int = source.find(end_marker, start_index + start_marker.length())
	if end_index <= start_index:
		return ""
	return source.substr(start_index, end_index - start_index)


func _test_option_state_presentation(rows: Array[Dictionary]) -> void:
	var flow: NEXT_CASE_SESSION = _composed_flow()
	var rows_view: Array[Dictionary] = flow.case_option_presentations()
	var signatures: Array[String] = []
	if flow.next_case_option_set != null:
		for signature: String in flow.next_case_option_set.option_candidate_signatures:
			signatures.append(signature)
	var presented_signatures: Array[String] = []
	for row: Dictionary in rows_view:
		presented_signatures.append(String(row.get("candidate_signature", "")))
	var signature_before: String = flow.next_case_option_set.option_set_signature if flow.next_case_option_set != null else ""
	var refreshed: Array[Dictionary] = flow.case_option_presentations()
	var signature_after: String = flow.next_case_option_set.option_set_signature if flow.next_case_option_set != null else ""
	_add(
		rows,
		"PF-M6C presentation receives exactly three stored M5B options",
		rows_view.size() == 3 and signatures.size() == 3
	)
	_add(
		rows,
		"PF-M6C presentation preserves M5A option order",
		presented_signatures == signatures
	)
	_add(
		rows,
		"PF-M6C refresh reads option state without recomposition",
		refreshed.size() == rows_view.size() and signature_before == signature_after
	)
	var session_source: String = FileAccess.get_file_as_string(NEXT_CASE_SESSION_SOURCE)
	_add(
		rows,
		"PF-M6C default option preparation is session-owned and idempotent",
		session_source.contains("func prepare_default_next_case_options()")
		and session_source.contains("next_case_option_set != null")
		and session_source.contains("compose_next_case_options(")
	)


func _test_option_selection_binding(rows: Array[Dictionary]) -> void:
	var all_bound: bool = true
	for option_index: int in range(3):
		var flow: NEXT_CASE_SESSION = _composed_flow()
		if (
			flow.next_case_option_set == null
			or flow.next_case_option_definitions.size() <= option_index
			or flow.next_case_option_set.option_candidate_signatures.size() <= option_index
		):
			all_bound = false
			continue
		var expected_definition: CaseDefinition = flow.next_case_option_definitions[option_index]
		var expected_signature: String = flow.next_case_option_set.option_candidate_signatures[option_index]
		var started: Dictionary = flow.start_next_round_from_option(option_index)
		all_bound = (
			all_bound
			and bool(started.get("success", false))
			and flow.selected_case_option_index == option_index
			and flow.selected_case_candidate_signature == expected_signature
			and flow.active_case_definition == expected_definition
		)
	_add(
		rows,
		"PF-M6C option 1/2/3 selection maps to stored CaseDefinition",
		all_bound
	)


func _test_empty_and_static_paths(rows: Array[Dictionary]) -> void:
	var flow: NEXT_CASE_SESSION = _ready_flow()
	var procedural_start: Dictionary = flow.start_next_round_from_option(0)
	var static_start: Dictionary = flow.start_next_round(&"vs_case_001")
	_add(
		rows,
		"PF-M6C missing option state exposes no procedural selection",
		flow.case_option_presentations().is_empty()
		and not bool(procedural_start.get("success", true))
	)
	_add(
		rows,
		"PF-M6C static authored next-Case path remains intact",
		bool(static_start.get("success", false))
	)


func _test_failed_options_hidden(rows: Array[Dictionary]) -> void:
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var request: CASE_GENERATION_REQUEST = _case_generation_request()
	var warehouse: CASE_SEED_WAREHOUSE_BUILD_RESULT = CASE_SEED_WAREHOUSE_BUILDER.new().build(
		request,
		PackedInt32Array([20, 21]),
		2,
		roles,
		1,
		Callable(self, "_fake_attempt_evaluator")
	)
	var flow: NEXT_CASE_SESSION = _ready_flow()
	var failed: Dictionary = flow.compose_next_case_options(
		warehouse,
		0,
		request,
		roles,
		3,
		1,
		Callable(self, "_fake_attempt_evaluator"),
		Callable(self, "_case_definition_for_entry")
	)
	_add(
		rows,
		"PF-M6C failed option state does not expose partial selection",
		not bool(failed.get("success", true))
		and flow.case_option_presentations().is_empty()
		and flow.next_case_option_definitions.is_empty()
	)


func _composed_flow() -> NEXT_CASE_SESSION:
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var request: CASE_GENERATION_REQUEST = _case_generation_request()
	var warehouse: CASE_SEED_WAREHOUSE_BUILD_RESULT = CASE_SEED_WAREHOUSE_BUILDER.new().build(
		request,
		PackedInt32Array([20, 21, 22, 23]),
		4,
		roles,
		1,
		Callable(self, "_fake_attempt_evaluator")
	)
	var flow: NEXT_CASE_SESSION = _ready_flow()
	flow.compose_next_case_options(
		warehouse,
		0,
		request,
		roles,
		3,
		1,
		Callable(self, "_fake_attempt_evaluator"),
		Callable(self, "_case_definition_for_entry")
	)
	return flow


func _ready_flow() -> NEXT_CASE_SESSION:
	var flow: NEXT_CASE_SESSION = NEXT_CASE_SESSION.new()
	flow.build_integrated_fixture()
	flow.complete_round_1_programmatically()
	return flow


func _case_generation_request() -> CASE_GENERATION_REQUEST:
	var role_ids: Array[StringName] = [
		&"reporter",
		&"therapist",
		&"tutorial_mobster",
	]
	var location_ids: Array[StringName] = [
		BoardLocationDefinition.LOCATION_CRIME_SCENE,
	]
	return CASE_GENERATION_REQUEST.create(
		0,
		3,
		3,
		CASE_GENERATION_REQUEST.PROFILE_TUTORIAL_EASY,
		role_ids,
		location_ids,
		3
	)


func _fake_attempt_evaluator(request: CASE_GENERATION_REQUEST, _attempt_index: int, _roles: Array[RoleDefinition]) -> Dictionary:
	if request.seed == 20:
		return _attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION, PackedInt32Array([2]), PackedInt32Array([2]), "presentation-a")
	if request.seed == 21:
		return _attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION, PackedInt32Array([3]), PackedInt32Array([3]), "presentation-b")
	if request.seed == 22:
		return _attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION, PackedInt32Array([4]), PackedInt32Array([4]), "presentation-c")
	if request.seed == 23:
		return _attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION, PackedInt32Array([5]), PackedInt32Array([5]), "presentation-d")
	return _attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_MULTIPLE_SOLUTIONS, PackedInt32Array(), PackedInt32Array([2]), "presentation-reject")


func _attempt(
	solver_status: StringName,
	solver_evil_ids: PackedInt32Array,
	ground_truth_evil_ids: PackedInt32Array,
	fingerprint_suffix: String
) -> Dictionary:
	var solver_result: CASE_GENERATOR_SOLVER_RESULT = CASE_GENERATOR_SOLVER_RESULT.new()
	if solver_status == CASE_GENERATOR_SOLVER_RESULT.STATUS_MULTIPLE_SOLUTIONS:
		solver_result.set_candidates([
			PackedInt32Array([1]),
			PackedInt32Array([2]),
		])
	else:
		solver_result.set_candidates([
			solver_evil_ids,
		])
	return {
		"candidate": {
			"fingerprint": "m5c-smoke-%s" % fingerprint_suffix,
		},
		"candidate_fingerprint": "m5c-smoke-%s" % fingerprint_suffix,
		"solver_result": solver_result,
		"ground_truth_evil_suspect_ids": ground_truth_evil_ids,
	}


func _case_definition_for_entry(entry: CASE_SEED_WAREHOUSE_ENTRY) -> CaseDefinition:
	var source: CaseDefinition = FixtureRepository.load_case()
	if source == null or entry == null:
		return null
	var definition: CaseDefinition = source.duplicate(true) as CaseDefinition
	if definition == null:
		return null
	definition.case_id = StringName("m5c_generated_%s" % _safe_case_id_suffix(entry.candidate_signature))
	definition.display_name = "Kỳ Án Sinh Tự Động"
	definition.short_description = "Một lựa chọn Kỳ Án đã được chuẩn bị."
	definition.set_meta(&"candidate_signature", entry.candidate_signature)
	return definition


func _safe_case_id_suffix(signature: String) -> String:
	var result: String = ""
	for index: int in range(signature.length()):
		var code: int = signature.unicode_at(index)
		if (
			(code >= 48 and code <= 57)
			or (code >= 65 and code <= 90)
			or (code >= 97 and code <= 122)
		):
			result += char(code)
		else:
			result += "_"
	return result if not result.is_empty() else "unknown"


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append({
		"name": name,
		"passed": passed,
		"detail": "PF-M6C / M5C player-facing three-case option presentation invariant",
	})
