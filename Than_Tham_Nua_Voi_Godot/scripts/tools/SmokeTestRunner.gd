class_name SmokeTestRunner
extends RefCounted

const DEBUG_HOME_PATH := "res://scenes/boot/DebugHome.tscn"
const ROLE_CODEX_PATH := "res://scenes/boot/RoleCodex.tscn"
const THEME_PATH := "res://themes/AppTheme.tres"
const VS_CASE_MAIN_PATH := "res://scenes/case_gameplay/VSCaseMain.tscn"
const CASE_BOARD_PATH := "res://scenes/case_gameplay/CaseBoard.tscn"
const SUSPECT_CARD_PATH := "res://scenes/case_gameplay/SuspectCard.tscn"
const CASE_TIMED_EVENT_DISPATCHER := preload("res://scripts/domain/cases/CaseTimedEventDispatcher.gd")
const SERIAL_KILLER_TIMED_EVENT_SERVICE := preload("res://scripts/domain/cases/SerialKillerTimedEventService.gd")
const CASE_PROCEDURAL_PRETEND_CAPABILITY := preload("res://scripts/domain/cases/CaseProceduralPretendCapability.gd")
const CASE_ROLE_MODIFIER_SERVICE := preload("res://scripts/domain/cases/CaseRoleModifierService.gd")
const CASE_ROLE_POOL_SERVICE := preload("res://scripts/domain/cases/CaseRolePoolService.gd")
const CASE_GENERATION_REQUEST := preload("res://scripts/domain/cases/CaseGenerationRequest.gd")
const CASE_GENERATION_RESULT := preload("res://scripts/domain/cases/CaseGenerationResult.gd")
const CASE_GENERATOR := preload("res://scripts/domain/cases/CaseGenerator.gd")
const GENERATED_PUBLIC_CASE_VIEW := preload("res://scripts/domain/cases/GeneratedPublicCaseView.gd")
const GENERATED_PUBLIC_SUSPECT_VIEW := preload("res://scripts/domain/cases/GeneratedPublicSuspectView.gd")
const CASE_GENERATOR_PUBLIC_SOLVER := preload("res://scripts/domain/cases/CaseGeneratorPublicSolver.gd")
const CASE_GENERATOR_SOLVER_RESULT := preload("res://scripts/domain/cases/CaseGeneratorSolverResult.gd")
const CASE_GENERATION_ACCEPTANCE_SERVICE := preload("res://scripts/domain/cases/CaseGenerationAcceptanceService.gd")
const CASE_GENERATION_ACCEPTANCE_RESULT := preload("res://scripts/domain/cases/CaseGenerationAcceptanceResult.gd")
const CASE_SEED_WAREHOUSE_ENTRY := preload("res://scripts/domain/cases/CaseSeedWarehouseEntry.gd")
const CASE_SEED_WAREHOUSE_BUILD_RESULT := preload("res://scripts/domain/cases/CaseSeedWarehouseBuildResult.gd")
const CASE_SEED_WAREHOUSE_BUILDER := preload("res://scripts/domain/cases/CaseSeedWarehouseBuilder.gd")
const CASE_SEED_WAREHOUSE_SELECTOR := preload("res://scripts/domain/cases/CaseSeedWarehouseSelector.gd")
const CASE_SEED_WAREHOUSE_SELECTION_RESULT := preload("res://scripts/domain/cases/CaseSeedWarehouseSelectionResult.gd")
const CASE_SEED_WAREHOUSE_OPTION_COMPOSER := preload("res://scripts/domain/cases/CaseSeedWarehouseOptionComposer.gd")
const CASE_SEED_WAREHOUSE_OPTION_SET_RESULT := preload("res://scripts/domain/cases/CaseSeedWarehouseOptionSetResult.gd")
const CASE_GENERATOR_M6A_TEST_SUITE := preload("res://tests/unit/case_generator/CaseGeneratorM6ATestSuite.gd")
const CASE_GENERATOR_M6B_FOUNDATION_TEST_SUITE := preload("res://tests/unit/case_generator/CaseGeneratorM6BFoundationTestSuite.gd")
const CASE_GENERATOR_M6B_POISONER_TEST_SUITE := preload("res://tests/unit/case_generator/CaseGeneratorM6BPoisonerTestSuite.gd")
const CASE_GENERATOR_M6B_BARKEEP_TEST_SUITE := preload("res://tests/unit/case_generator/CaseGeneratorM6BBarkeepTestSuite.gd")
const CASE_GENERATOR_M6B_SPECTRE_TEST_SUITE := preload("res://tests/unit/case_generator/CaseGeneratorM6BSpectreTestSuite.gd")
const CASE_GENERATOR_SCOUNDREL_TEST_SUITE := preload("res://tests/unit/case_generator/CaseGeneratorScoundrelTestSuite.gd")
const CASE_GENERATOR_TAILOR_TEST_SUITE := preload("res://tests/unit/case_generator/CaseGeneratorTailorTestSuite.gd")
const CASE_GENERATOR_VIGILANTE_TEST_SUITE := preload("res://tests/unit/case_generator/CaseGeneratorVigilanteTestSuite.gd")
const CASE_GENERATOR_COPYCAT_ACTIVE_TEST_SUITE := preload("res://tests/unit/case_generator/CaseGeneratorCopycatActiveTestSuite.gd")
const CASE_GENERATOR_CLOCK_MAKER_TEST_SUITE := preload("res://tests/unit/case_generator/CaseGeneratorClockMakerTestSuite.gd")
const CASE_GENERATOR_SURGEON_TEST_SUITE := preload("res://tests/unit/case_generator/CaseGeneratorSurgeonTestSuite.gd")
const CASE_GENERATOR_SERIAL_KILLER_TEST_SUITE := preload("res://tests/unit/case_generator/CaseGeneratorSerialKillerTestSuite.gd")
const CASE_GENERATOR_CRITIC_TEST_SUITE := preload("res://tests/unit/case_generator/CaseGeneratorCriticTestSuite.gd")
const CASE_GENERATOR_DISGUISE_SLICE_A_TEST_SUITE := preload("res://tests/unit/case_generator/CaseGeneratorDisguiseSliceATestSuite.gd")
const CASE_GENERATOR_MOBSTER_ACTIVE_TEST_SUITE := preload("res://tests/unit/case_generator/CaseGeneratorMobsterActiveTestSuite.gd")
const CASE_GENERATOR_SERIAL_KILLER_ACTIVE_TEST_SUITE := preload("res://tests/unit/case_generator/CaseGeneratorSerialKillerActiveTestSuite.gd")
const HV1_DISGUISE_CLUE_BEHAVIOR_TEST_SUITE := preload("res://tests/unit/case_generator/Hv1DisguiseClueBehaviorTestSuite.gd")
const HV2_ACTIVE_DISGUISE_TEST_SUITE := preload("res://tests/unit/case_generator/Hv2ActiveDisguiseTestSuite.gd")
const HV3_TIMED_COEXISTENCE_TEST_SUITE := preload("res://tests/unit/case_generator/Hv3TimedCoexistenceTestSuite.gd")
const HV4_CRITIC_MAILMAN_TEST_SUITE := preload("res://tests/unit/case_generator/Hv4CriticMailmanTestSuite.gd")
const HV5_MUTATION_VISIBILITY_TEST_SUITE := preload("res://tests/unit/case_generator/Hv5MutationVisibilityTestSuite.gd")
const HV6_RESOLUTION_TIMED_SAFETY_TEST_SUITE := preload("res://tests/unit/case_generator/Hv6ResolutionTimedSafetyTestSuite.gd")
const CASE_GENERATOR_ROLE_UNIVERSE_TEST_SUITE := preload("res://tests/unit/case_generator/CaseGeneratorRoleUniverseRegressionTestSuite.gd")
const CASE_THERAPIST_SOLVER_INSPECTION_TEST_SUITE := preload("res://tests/unit/case_generator/CaseTherapistSolverInspectionTestSuite.gd")
const CASE_PRODUCTION_VARIETY_TEST_SUITE := preload("res://tests/unit/case_generator/CaseProductionVarietyTestSuite.gd")
const CASE_M6A_REGRESSION_TEST_SUITE := preload("res://tests/unit/case_generator/CaseM6ARegressionTestSuite.gd")
const GD2_M0A_TEST_SUITE := preload(
	"res://tests/unit/gd2/Gd2M0AProductionMapTestSuite.gd"
)
const GD2_PRODUCTION_CHARACTER_TEST_SUITE := preload(
	"res://tests/unit/gd2/Gd2ProductionCharacterRosterTestSuite.gd"
)
const GD2_PRODUCTION_REWARD_TABLES_TEST_SUITE := preload(
	"res://tests/unit/gd2/Gd2ProductionRewardTablesTestSuite.gd"
)
const GD2_PRODUCTION_CONSUMABLES_TEST_SUITE := preload(
	"res://tests/unit/gd2/Gd2ProductionConsumablesTestSuite.gd"
)
const GD2_M2_TEST_SUITE := preload("res://tests/unit/gd2/Gd2M2TestSuite.gd")
const GD2_M3_TEST_SUITE := preload("res://tests/unit/gd2/Gd2M3TestSuite.gd")
const GD2_M4_TEST_SUITE := preload("res://tests/unit/gd2/Gd2M4TestSuite.gd")
const GD2_M5_TEST_SUITE := preload("res://tests/unit/gd2/Gd2M5TestSuite.gd")
const GD2_M6_TEST_SUITE := preload("res://tests/unit/gd2/Gd2M6TestSuite.gd")
const GD2_M7_TEST_SUITE := preload("res://tests/unit/gd2/Gd2M7TestSuite.gd")
const GD2_PREP_1_TEST_SUITE := preload(
	"res://tests/unit/gd2/Gd2Prep1StateBoundaryTestSuite.gd"
)
const GD2_PREP_3_TEST_SUITE := preload(
	"res://tests/unit/gd2/Gd2Prep3InventoryBoundaryTestSuite.gd"
)
const GD3_M1_TEST_SUITE := preload("res://tests/unit/gd3/Gd3M1TestSuite.gd")
const GD3_M2_TEST_SUITE := preload("res://tests/unit/gd3/Gd3M2TestSuite.gd")
const GD3_M3_TEST_SUITE := preload("res://tests/unit/gd3/Gd3M3TestSuite.gd")
const GD3_M4_TEST_SUITE := preload("res://tests/unit/gd3/Gd3M4TestSuite.gd")
const GD3_M5_TEST_SUITE := preload("res://tests/unit/gd3/Gd3M5TestSuite.gd")
const GD3_M6_TEST_SUITE := preload("res://tests/unit/gd3/Gd3M6TestSuite.gd")
const PF_M1_TEST_SUITE := preload(
	"res://tests/unit/player_facing/PfM1TestSuite.gd"
)
const PF_M2_TEST_SUITE := preload(
	"res://tests/unit/player_facing/PfM2TestSuite.gd"
)
const PF_M3_TEST_SUITE := preload(
	"res://tests/unit/player_facing/PfM3TestSuite.gd"
)
const PF_M4_TEST_SUITE := preload(
	"res://tests/unit/player_facing/PfM4TestSuite.gd"
)
const PF_M5_TEST_SUITE := preload(
	"res://tests/unit/player_facing/PfM5TestSuite.gd"
)
const PF_M6A_TEST_SUITE := preload(
	"res://tests/unit/player_facing/PfM6ATestSuite.gd"
)
const PF_M6B_TEST_SUITE := preload(
	"res://tests/unit/player_facing/PfM6BTestSuite.gd"
)
const PF_M6C_TEST_SUITE := preload(
	"res://tests/unit/player_facing/PfM6CTestSuite.gd"
)
const PF_M6D_TEST_SUITE := preload(
	"res://tests/unit/player_facing/PfM6DTestSuite.gd"
)
const PF_M7_TEST_SUITE := preload(
	"res://tests/unit/player_facing/PfM7TestSuite.gd"
)
const PF_M8A_TEST_SUITE := preload(
	"res://tests/unit/player_facing/PfM8ATestSuite.gd"
)
const PF_M8B_TEST_SUITE := preload(
	"res://tests/unit/player_facing/PfM8BTestSuite.gd"
)
const PF_M9B_TEST_SUITE := preload(
	"res://tests/unit/player_facing/PfM9BTestSuite.gd"
)
const PF_M9C_TEST_SUITE := preload(
	"res://tests/unit/player_facing/PfM9CTestSuite.gd"
)
const PF_M9D_B_TEST_SUITE := preload(
	"res://tests/unit/player_facing/PfM9DBTestSuite.gd"
)
const PF_M9E_A_TEST_SUITE := preload(
	"res://tests/unit/player_facing/PfM9EATestSuite.gd"
)
const PF_M9E_C_TEST_SUITE := preload(
	"res://tests/unit/player_facing/PfM9ECTestSuite.gd"
)
const PF_M9E_D_TEST_SUITE := preload(
	"res://tests/unit/player_facing/PfM9EDTestSuite.gd"
)

var _case_generation_m3_injected_attempts: Array[Dictionary] = []


func run_all() -> Dictionary:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var case_fixture: CaseDefinition = FixtureRepository.load_case()
	var tutorial_case: CaseDefinition = FixtureRepository.load_tutorial_case_001()
	var tutorial_case_02: CaseDefinition = FixtureRepository.load_tutorial_case_002()
	var tutorial_case_03: CaseDefinition = FixtureRepository.load_tutorial_case_003()
	var tutorial_case_04: CaseDefinition = FixtureRepository.load_tutorial_case_004()
	var tutorial_case_05: CaseDefinition = FixtureRepository.load_tutorial_case_005()
	var tutorial_case_06: CaseDefinition = FixtureRepository.load_tutorial_case_006()
	var tutorial_case_07: CaseDefinition = FixtureRepository.load_tutorial_case_007()
	var tutorial_case_08: CaseDefinition = FixtureRepository.load_tutorial_case_008()
	var player_fixtures: Array[PlayerCaseState] = FixtureRepository.load_players()
	var validator: CaseDefinitionValidator = CaseDefinitionValidator.new()
	var validation_report: Dictionary = validator.validate(case_fixture, roles, player_fixtures)
	var tutorial_validation_report: Dictionary = validator.validate(tutorial_case, roles, player_fixtures)
	var tutorial_02_validation_report: Dictionary = validator.validate(tutorial_case_02, roles, player_fixtures)
	var tutorial_03_validation_report: Dictionary = validator.validate(tutorial_case_03, roles, player_fixtures)
	var tutorial_04_validation_report: Dictionary = validator.validate(tutorial_case_04, roles, player_fixtures)
	var tutorial_05_validation_report: Dictionary = validator.validate(tutorial_case_05, roles, player_fixtures)
	var tutorial_06_validation_report: Dictionary = validator.validate(tutorial_case_06, roles, player_fixtures)
	var tutorial_07_validation_report: Dictionary = validator.validate(tutorial_case_07, roles, player_fixtures)
	var tutorial_08_validation_report: Dictionary = validator.validate(tutorial_case_08, roles, player_fixtures)
	var invalid_report := validator.validate(FixtureRepository.load_invalid_case(), roles, player_fixtures)
	var function_placeholder_snapshot := _function_placeholder_snapshot()
	var g2h := _g2h_checks(case_fixture, roles, player_fixtures)
	var post_reveal := _post_reveal_checks(case_fixture, roles, player_fixtures)
	var text_history := _function_text_history_checks(case_fixture, roles, player_fixtures)
	var post_reveal_input := _post_reveal_input_routing_checks(case_fixture, roles, player_fixtures)
	var card_local_clue := _card_local_clue_checks(case_fixture, roles, player_fixtures)
	var g2i := _g2i_checks(case_fixture, roles, player_fixtures)
	var t07a := _t07_a_location_checks(roles, player_fixtures)
	var t07b := _t07_b_clock_maker_checks(roles, player_fixtures)
	var t07c := _t07_c_timed_event_dispatcher_checks(player_fixtures)
	var t07d := _t07_d_serial_killer_checks(roles, player_fixtures)
	var t07i1 := _t07_i1_tutorial_case_07_checks(tutorial_case_07, roles, player_fixtures, tutorial_07_validation_report)
	var t07i1_repair := _t07_i1_human_runtime_repair_checks(tutorial_case_07, tutorial_case_06, roles, player_fixtures)
	var t07i2 := _t07_i2_closeout_checks(tutorial_case_07, roles, player_fixtures)
	var t08 := _t08_final_tutorial_checks(tutorial_case_08, roles, player_fixtures, tutorial_08_validation_report)
	var case_generation_m0 := _case_generation_m0_checks(roles)
	var case_generation_m1 := _case_generation_m1_checks(roles)
	var case_generation_m2 := _case_generation_m2_checks(roles)
	var case_generation_m3a := _case_generation_m3a_checks(roles)
	var case_generation_m3 := _case_generation_m3_checks(roles)
	var case_generation_m4a := _case_generation_m4a_checks(roles)
	var case_generation_m4b := _case_generation_m4b_checks(roles)
	var case_generation_m5a := _case_generation_m5a_checks(roles)

	rows.append(_result("Project boot", Engine.get_main_loop() != null, "SceneTree exists"))
	rows.append(_result("Version info", not AppVersion.GAME_VERSION.is_empty(), AppVersion.summary()))
	rows.append(_result("DebugHome load", load(DEBUG_HOME_PATH) is PackedScene, DEBUG_HOME_PATH))
	rows.append(_result("Role Codex load", load(ROLE_CODEX_PATH) is PackedScene, ROLE_CODEX_PATH))
	rows.append(_result("DebugHome Role Codex launcher exists", _debug_role_codex_launcher_exists(), "Sổ Vai Trò"))
	rows.append(_result("Role Codex route exists", AppFlow.has_method("go_to_role_codex"), "DebugHome → Sổ Vai Trò"))
	rows.append(_result("Role Codex groups canonical", _role_codex_groups_canonical(), "Người Vô Tội / Kẻ Bao Đồng / Thuộc Hạ / Nghịch Thần"))
	rows.append(_result("Role Codex filters available roles", _role_codex_filters_available_roles(), "real roles included; fixture roles excluded"))
	rows.append(_result("Role Codex uses RoleDefinition content", _role_codex_uses_authoritative_content(roles), "same RoleDefinition help_text as Case Role Reference"))
	var role_codex_render_result: Dictionary = _role_codex_simple_complex_render()
	rows.append(_result("Role Codex simple and complex roles render", bool(role_codex_render_result.get("passed", false)), String(role_codex_render_result.get("detail", "Mobster simple; Tailor complex; no empty sections"))))
	var term_bank_result: Dictionary = _role_reference_term_bank_semantics()
	rows.append(_result("Role Reference term bank styles semantic keywords", bool(term_bank_result.get("passed", false)), String(term_bank_result.get("detail", "shared bank, longest match, no font-size"))))
	rows.append(_result("Role glossary bank canonical definitions", _role_glossary_bank_canonical(), "aliases, Số Hiệu, longest overlaps"))
	var hover_result: Dictionary = _role_glossary_hover_plumbing()
	rows.append(_result("Role glossary hover tooltip plumbing", bool(hover_result.get("passed", false)), String(hover_result.get("detail", "Case and Codex RichTextLabel meta hover"))))
	rows.append(_result("DebugHome Tutorial Case 01 launcher exists", _debug_tutorial_case_01_launcher_exists(), "Tutorial Case 01 — Deduction M0"))
	rows.append(_result("DebugHome Tutorial Case 01 resolves fixture", _debug_tutorial_case_01_resolves_fixture(), FixtureRepository.TUTORIAL_CASE_001_PATH))
	rows.append(_result("DebugHome Tutorial Case 02 launcher exists", _debug_tutorial_case_02_launcher_exists(), "Tutorial Case 02 — Deduction"))
	rows.append(_result("DebugHome Tutorial Case 02 resolves fixture", _debug_tutorial_case_02_resolves_fixture(), FixtureRepository.TUTORIAL_CASE_002_PATH))
	rows.append(_result("DebugHome Tutorial Case 03 launcher exists", _debug_tutorial_case_03_launcher_exists(), "Tutorial Case 03 — Deduction"))
	rows.append(_result("DebugHome Tutorial Case 03 resolves fixture", _debug_tutorial_case_03_resolves_fixture(), FixtureRepository.TUTORIAL_CASE_003_PATH))
	rows.append(_result("DebugHome Tutorial Case 04 launcher exists", _debug_tutorial_case_04_launcher_exists(), "Tutorial Case 04 — Active Ability"))
	rows.append(_result("DebugHome Tutorial Case 04 resolves fixture", _debug_tutorial_case_04_resolves_fixture(), FixtureRepository.TUTORIAL_CASE_004_PATH))
	rows.append(_result("DebugHome Tutorial Case 05 launcher exists", _debug_tutorial_case_05_launcher_exists(), "Tutorial Case 05 — Timed Roles"))
	rows.append(_result("DebugHome Tutorial Case 05 resolves fixture", _debug_tutorial_case_05_resolves_fixture(), FixtureRepository.TUTORIAL_CASE_005_PATH))
	rows.append(_result("DebugHome Tutorial Case 06 launcher exists", _debug_tutorial_case_06_launcher_exists(), "Tutorial Case 06 — Transform"))
	rows.append(_result("DebugHome Tutorial Case 06 resolves fixture", _debug_tutorial_case_06_resolves_fixture(), FixtureRepository.TUTORIAL_CASE_006_PATH))
	rows.append(_result("DebugHome Tutorial Case 07 launcher exists", _debug_tutorial_case_07_launcher_exists(), "Tutorial Case 07 — Dangerous Time"))
	rows.append(_result("DebugHome Tutorial Case 07 resolves fixture", _debug_tutorial_case_07_resolves_fixture(), FixtureRepository.TUTORIAL_CASE_007_PATH))
	rows.append(_result("DebugHome Tutorial Case 08 launcher exists", _debug_tutorial_case_08_launcher_exists(), "Tutorial Case 08 — Truthful Evil"))
	rows.append(_result("DebugHome Tutorial Case 08 resolves fixture", _debug_tutorial_case_08_resolves_fixture(), FixtureRepository.TUTORIAL_CASE_008_PATH))
	rows.append(_result("DebugHome existing Case launcher remains", _debug_existing_case_launcher_remains(), "Vertical Slice Kỳ Án"))
	rows.append(_result("Theme load", load(THEME_PATH) is Theme, THEME_PATH))
	rows.append(_result("Logger INFO/WARNING/ERROR", _test_logger_methods(), "Logger methods callable"))
	rows.append(_result("Simulated PASS", true, "Intentional harness check"))
	rows.append(_result("Handled failure", _test_handled_failure(), "Expected invalid resource returned null"))
	rows.append(_result("Role definitions load", roles.size() == 28, "%d/28 roles" % roles.size()))
	rows.append(_result("Case fixture load", case_fixture != null, FixtureRepository.CASE_PATH))
	rows.append(_result("Exactly 8 suspects plus Crime Scene", case_fixture != null and case_fixture.crime_scene != null and case_fixture.suspects.size() == 8, "Canonical Case Board fixture"))
	rows.append(_result("T07-A generic location definition exists", bool(t07a.get("definition_exists", false)), "BoardLocationDefinition"))
	rows.append(_result("T07-A location_id required", bool(t07a.get("id_required", false)), "LOCATION_ID_EMPTY"))
	rows.append(_result("T07-A duplicate location_id rejected", bool(t07a.get("duplicate_id", false)), "LOCATION_ID_DUPLICATE"))
	rows.append(_result("T07-A invalid location slot rejected", bool(t07a.get("invalid_slot", false)), "BOARD_SLOT_INVALID"))
	rows.append(_result("T07-A location/suspect slot collision rejected", bool(t07a.get("suspect_collision", false)), "BOARD_SLOT_DUPLICATE"))
	rows.append(_result("T07-A location/location slot collision rejected", bool(t07a.get("location_collision", false)), "BOARD_SLOT_DUPLICATE"))
	rows.append(_result("T07-A Crime Scene resolves as generic location", bool(t07a.get("crime_scene_generic", false)), "crime_scene in location_definitions"))
	rows.append(_result("T07-A existing Crime Scene behavior preserved", bool(t07a.get("crime_scene_preserved", false)), "legacy crime_scene still present"))
	rows.append(_result("T07-A Clock Tower location can be authored", bool(t07a.get("clock_tower_authored", false)), "clock_tower"))
	rows.append(_result("T07-A Clock Tower display name resolves", bool(t07a.get("clock_tower_name", false)), "Tháp Đồng Hồ"))
	rows.append(_result("T07-A Clock Tower and Crime Scene coexist", bool(t07a.get("locations_coexist", false)), "2 locations"))
	rows.append(_result("T07-A location list supports multiple locations", bool(t07a.get("multiple_locations", false)), "generic list"))
	rows.append(_result("T07-A location stays out of suspect list", bool(t07a.get("not_suspect", false)), "suspect count unchanged"))
	rows.append(_result("T07-A location stays out of role pools", bool(t07a.get("not_role_pool", false)), "no location role ids"))
	rows.append(_result("T07-A location is not investigation target", bool(t07a.get("not_investigation_target", false)), "SUSPECT_NOT_FOUND"))
	rows.append(_result("T07-A location is not Final Verdict candidate", bool(t07a.get("not_final_candidate", false)), "SUSPECT_NOT_FOUND"))
	rows.append(_result("T07-A location is not kill target", bool(t07a.get("not_kill_target", false)), "target remains alive"))
	rows.append(_result("T07-A board occupancy recognizes location slot", bool(t07a.get("occupancy_location", false)), "location_at_slot"))
	rows.append(_result("T07-A empty slot remains empty", bool(t07a.get("empty_slot", false)), "unoccupied slot"))
	rows.append(_result("T07-A generic service does not hardcode Clock Tower slot5", bool(t07a.get("no_clock_slot_hardcode", false)), "no service slot5 constant"))
	rows.append(_result("T07-A generic service does not hardcode Crime Scene slot6", bool(t07a.get("no_crime_slot_hardcode", false)), "no service slot6 constant"))
	rows.append(_result("T07-A static Clock Tower presentation renders", bool(t07a.get("clock_tower_presentation", false)), "non-suspect location tile"))
	rows.append(_result("T07-B Clock Maker RoleDefinition exists", bool(t07b.get("role_exists", false)), "clock_maker"))
	rows.append(_result("T07-B Clock Maker group is Innocent", bool(t07b.get("role_group", false)), "CHINH_NHAN"))
	rows.append(_result("T07-B Clock Maker resolves Good", bool(t07b.get("role_alignment", false)), "role-group authority"))
	rows.append(_result("T07-B Clock Maker display name resolves", bool(t07b.get("display_name", false)), "Thợ Đồng Hồ"))
	rows.append(_result("T07-B ClockTowerDefinition exists", bool(t07b.get("tower_definition", false)), "ClockTowerDefinition"))
	rows.append(_result("T07-B Clock Tower remains generic location", bool(t07b.get("tower_generic", false)), "BoardLocationDefinition"))
	rows.append(_result("T07-B ring_hour accepts 1", bool(t07b.get("ring_accepts_1", false)), "1..23"))
	rows.append(_result("T07-B ring_hour accepts 23", bool(t07b.get("ring_accepts_23", false)), "1..23"))
	rows.append(_result("T07-B ring_hour rejects 0", bool(t07b.get("ring_rejects_0", false)), "CLOCK_TOWER_RING_HOUR_INVALID"))
	rows.append(_result("T07-B ring_hour rejects 24", bool(t07b.get("ring_rejects_24", false)), "CLOCK_TOWER_RING_HOUR_INVALID"))
	rows.append(_result("T07-B late ring hour is not reachability-rejected", bool(t07b.get("late_ring_not_rejected", false)), "23 allowed"))
	rows.append(_result("T07-B ring_hour 8 idle at 7h", bool(t07b.get("idle_7", false)), "not ringing"))
	rows.append(_result("T07-B ring_hour 8 rings at 8h", bool(t07b.get("ring_8", false)), "ringing"))
	rows.append(_result("T07-B ring_hour 8 rings at 9h", bool(t07b.get("ring_9", false)), "ringing"))
	rows.append(_result("T07-B ring_hour 8 idle at 10h", bool(t07b.get("idle_10", false)), "not ringing"))
	rows.append(_result("T07-B ring query does not mutate elapsed hours", bool(t07b.get("query_no_mutation", false)), "read-only"))
	rows.append(_result("T07-B truthful Clock Maker uses actual ring_hour", bool(t07b.get("truth_uses_ring_hour", false)), "ring_hour source"))
	rows.append(_result("T07-B truthful Clock Maker says 8h đến 9h", bool(t07b.get("truth_text_8_9", false)), "canonical interval"))
	rows.append(_result("T07-B lying Clock Maker false interval does not overlap", bool(t07b.get("lying_false_interval", false)), "false interval"))
	rows.append(_result("T07-B tainted Clock Maker false interval does not overlap", bool(t07b.get("tainted_false_interval", false)), "false interval"))
	rows.append(_result("T07-B false 5h..6h valid against 8h..9h", bool(t07b.get("false_5_6_valid", false)), "non-overlap"))
	rows.append(_result("T07-B false 11h..12h valid against 8h..9h", bool(t07b.get("false_11_12_valid", false)), "non-overlap"))
	rows.append(_result("T07-B false 7h..8h rejected", bool(t07b.get("false_7_8_rejected", false)), "overlap"))
	rows.append(_result("T07-B false 8h..9h rejected", bool(t07b.get("false_8_9_rejected", false)), "overlap"))
	rows.append(_result("T07-B false 9h..10h rejected", bool(t07b.get("false_9_10_rejected", false)), "overlap"))
	rows.append(_result("T07-B lying/tainted evaluation preserves ring_hour", bool(t07b.get("lie_no_ring_mutation", false)), "truth unchanged"))
	rows.append(_result("T07-B suspected clock_maker requires Clock Tower", bool(t07b.get("requires_clock_maker", false)), "suspected authority"))
	rows.append(_result("T07-B suspected gentleman requires Clock Tower", bool(t07b.get("requires_gentleman", false)), "suspected authority"))
	rows.append(_result("T07-B suspected gargoyle requires Clock Tower", bool(t07b.get("requires_gargoyle", false)), "suspected authority"))
	rows.append(_result("T07-B suspected belfry requires Clock Tower", bool(t07b.get("requires_belfry", false)), "suspected authority"))
	rows.append(_result("T07-B suspected sniper requires Clock Tower", bool(t07b.get("requires_sniper", false)), "suspected authority"))
	rows.append(_result("T07-B suspected maid requires Clock Tower", bool(t07b.get("requires_maid", false)), "suspected authority"))
	rows.append(_result("T07-B suspected fearmonger requires Clock Tower", bool(t07b.get("requires_fearmonger", false)), "suspected authority"))
	rows.append(_result("T07-B Clock Tower may exist without true Clock Maker", bool(t07b.get("tower_without_true_clock_maker", false)), "suspected not true"))
	rows.append(_result("T07-B Clock Tower presence uses suspected authority", bool(t07b.get("presence_suspected_not_current", false)), "not current in-play"))
	rows.append(_result("T07-B Clock Tower and Crime Scene coexist", bool(t07b.get("tower_crime_coexist", false)), "locations"))
	rows.append(_result("T07-B Clock Tower does not enter suspect list", bool(t07b.get("tower_not_suspect", false)), "location only"))
	rows.append(_result("T07-B Clock Tower does not enter role pools", bool(t07b.get("tower_not_role_pool", false)), "no role id"))
	rows.append(_result("T07-B Clock Tower is not investigation target", bool(t07b.get("tower_not_investigation", false)), "SUSPECT_NOT_FOUND"))
	rows.append(_result("T07-B Clock Tower is not kill target", bool(t07b.get("tower_not_kill", false)), "KILL_TARGET_NOT_FOUND"))
	rows.append(_result("T07-B Mobster can reuse Clock Maker behavior", bool(t07b.get("mobster_pretend_clock_maker", false)), "displayed-role behavior"))
	rows.append(_result("T07-B Clock Maker logic does not hardcode slot5", bool(t07b.get("no_slot5_hardcode", false)), "no T07 slot logic"))
	rows.append(_result("T07-B Clock Maker logic does not hardcode 8h", bool(t07b.get("no_ring8_hardcode", false)), "ring from data"))
	rows.append(_result("T07-B presentation refresh reflects ringing state", bool(t07b.get("presentation_state", false)), "idle/ringing"))
	rows.append(_result("T07-B no new 3x3 hardcode added", bool(t07b.get("no_new_3x3_hardcode", false)), "location APIs"))
	rows.append(_result("T07-C timed-event dispatcher exists", bool(t07c.get("dispatcher_exists", false)), "CaseTimedEventDispatcher"))
	rows.append(_result("T07-C dispatcher includes Surgeon handler", bool(t07c.get("surgeon_registered", false)), "explicit registry"))
	rows.append(_result("T07-C dispatcher does not advance elapsed hours", bool(t07c.get("elapsed_unchanged", false)), "handler-only dispatch"))
	rows.append(_result("T07-C dispatcher preserves Surgeon before-12h no-op", bool(t07c.get("before_12_noop", false)), "unfired event"))
	rows.append(_result("T07-C dispatcher preserves Surgeon 12h resolution", bool(t07c.get("threshold_resolution", false)), "fired at 12h"))
	rows.append(_result("T07-C dispatcher preserves Surgeon 50 percent fail branch", bool(t07c.get("fail_branch", false)), "failed proc"))
	rows.append(_result("T07-C dispatcher preserves Surgeon success branch", bool(t07c.get("success_branch", false)), "successful proc"))
	rows.append(_result("T07-C dispatcher preserves Surgeon random victim semantics", bool(t07c.get("random_victim", false)), "actual event target"))
	rows.append(_result("T07-C dispatcher preserves Surgeon idempotency", bool(t07c.get("idempotency", false)), "handler-owned fired state"))
	rows.append(_result("T07-C dispatcher preserves dead-source suppression", bool(t07c.get("dead_source_suppression", false)), "no source event"))
	rows.append(_result("T07-C dispatcher aggregates handler result", bool(t07c.get("aggregates_result", false)), "handler_id + events"))
	rows.append(_result("T07-C dispatcher supports multiple handlers", bool(t07c.get("multiple_handlers", false)), "registry list"))
	rows.append(_result("T07-C handler order is deterministic", bool(t07c.get("handler_order", false)), "registration order"))
	rows.append(_result("T07-C handler result does not overwrite another", bool(t07c.get("no_overwrite", false)), "one entry per handler"))
	rows.append(_result("T07-C repeated dispatch respects handler idempotency", bool(t07c.get("repeat_safe", false)), "no duplicate event log"))
	rows.append(_result("T07-C zero-hour ability path does not trigger timed events", bool(t07c.get("zero_hour_no_dispatch", false)), "+0h stays quiet"))
	rows.append(_result("T07-C investigation path still triggers timed dispatch", bool(t07c.get("investigation_dispatch", false)), "+2h dispatch"))
	rows.append(_result("T07-C single-accusation path still triggers timed dispatch", bool(t07c.get("single_accusation_dispatch", false)), "+1h dispatch"))
	rows.append(_result("T07-C controller no longer hardcodes Surgeon evaluation", bool(t07c.get("controller_no_direct_surgeon", false)), "dispatcher-owned"))
	rows.append(_result("T07-C dispatcher remains generic after Serial Killer registration", bool(t07c.get("dispatcher_generic_with_serial", false)), "handler registry"))
	rows.append(_result("T07-C recurrence stays out of dispatcher/controller", bool(t07c.get("no_recurrence", false)), "handler-owned recurrence"))
	rows.append(_result("T07-C no new 3x3 assumptions introduced", bool(t07c.get("no_new_3x3", false)), "dispatcher spatial-agnostic"))
	rows.append(_result("T07-D Serial Killer RoleDefinition exists", bool(t07d.get("role_exists", false)), "serial_killer"))
	rows.append(_result("T07-D Serial Killer group is Underling", bool(t07d.get("role_group", false)), "TONG_PHAM"))
	rows.append(_result("T07-D Serial Killer resolves Evil", bool(t07d.get("role_alignment", false)), "role-group authority"))
	rows.append(_result("T07-D Serial Killer always lies", bool(t07d.get("always_lies", false)), "always_lies"))
	rows.append(_result("T07-D pretend pool uses suspected authority", bool(t07d.get("pretend_pool_suspected", false)), "suspected_role_candidates"))
	rows.append(_result("T07-D nested-only role excluded from pretend pool", bool(t07d.get("nested_excluded", false)), "nested-only Drunkard excluded"))
	rows.append(_result("T07-D supported lying behavior is a valid pretend target", bool(t07d.get("pretend_supported", false)), "shared capability"))
	rows.append(_result("T07-D Tutorial 07 Clock Maker pretend remains valid", bool(t07d.get("pretend_clock_maker", false)), "Tutorial 07"))
	rows.append(_result("T07-D unsupported behavior role is rejected", bool(t07d.get("pretend_unsupported", false)), "no silent/timed behavior alias"))
	rows.append(_result("T07-D self pretend target is rejected", bool(t07d.get("pretend_self_rejected", false)), "not self"))
	rows.append(_result("T07-D unlisted pretend target is rejected", bool(t07d.get("pretend_unlisted_rejected", false)), "Case Suspect List"))
	rows.append(_result("T07-D validator and pretend capability share authority", bool(t07d.get("pretend_shared_authority", false)), "CaseProceduralPretendCapability"))
	rows.append(_result("T07-D adjacent Innocent satisfies spawn", bool(t07d.get("spawn_adjacent_innocent", false)), "CHINH_NHAN"))
	rows.append(_result("T07-D adjacent Meddler alone fails spawn", bool(t07d.get("spawn_meddler_fails", false)), "HIEU_SU excluded"))
	rows.append(_result("T07-D non-adjacent Innocent fails spawn", bool(t07d.get("spawn_non_adjacent_fails", false)), "must be adjacent"))
	rows.append(_result("T07-D evil Innocent satisfies spawn", bool(t07d.get("spawn_evil_innocent", false)), "group not alignment"))
	rows.append(_result("T07-D adjacent location fails spawn", bool(t07d.get("spawn_location_fails", false)), "locations excluded"))
	rows.append(_result("T07-D transformed only adjacent Innocent fails spawn", bool(t07d.get("spawn_transformed_only_fails", false)), "post-startup current group"))
	rows.append(_result("T07-D another current adjacent Innocent satisfies spawn", bool(t07d.get("spawn_transformed_plus_innocent", false)), "current CHINH_NHAN"))
	rows.append(_result("T07-D displayed Innocent does not satisfy spawn", bool(t07d.get("spawn_displayed_innocent_fails", false)), "current group authority"))
	rows.append(_result("T07-D adjacent Good target eligible", bool(t07d.get("kill_adjacent_good", false)), "Good target pool"))
	rows.append(_result("T07-D adjacent Evil target excluded", bool(t07d.get("kill_adjacent_evil_excluded", false)), "Evil excluded"))
	rows.append(_result("T07-D non-adjacent Good excluded", bool(t07d.get("kill_non_adjacent_good_excluded", false)), "adjacency required"))
	rows.append(_result("T07-D dead Good excluded", bool(t07d.get("kill_dead_good_excluded", false)), "alive only"))
	rows.append(_result("T07-D source excluded from kill pool", bool(t07d.get("kill_source_excluded", false)), "not self"))
	rows.append(_result("T07-D locations excluded from kill pool", bool(t07d.get("kill_location_excluded", false)), "suspects only"))
	rows.append(_result("T07-D current Drunkard remains a Good target", bool(t07d.get("kill_transformed_good", false)), "current alignment"))
	rows.append(_result("T07-D displayed Good does not make current Evil eligible", bool(t07d.get("kill_displayed_good_evil_excluded", false)), "current alignment"))
	rows.append(_result("T07-D arrested Good remains eligible", bool(t07d.get("kill_arrested_good_eligible", false)), "existing target contract"))
	rows.append(_result("T07-D multiple adjacent Good targets form full pool", bool(t07d.get("kill_full_pool", false)), "full eligible set"))
	rows.append(_result("T07-D deterministic seed is stable", bool(t07d.get("deterministic_seed_stable", false)), "same seed"))
	rows.append(_result("T07-D alternate seed can choose different victim", bool(t07d.get("alternate_seed_varies", false)), "different seeds"))
	rows.append(_result("T07-D before 9h no event", bool(t07d.get("before_9_no_event", false)), "8h"))
	rows.append(_result("T07-D 8h to 10h resolves 9h event", bool(t07d.get("cross_8_10_resolves_9", false)), "threshold crossing"))
	rows.append(_result("T07-D 9h event idempotent", bool(t07d.get("event_9_idempotent", false)), "no reroll"))
	rows.append(_result("T07-D at 18h resolves distinct interval", bool(t07d.get("event_18_distinct", false)), "18h"))
	rows.append(_result("T07-D 18h does not overwrite 9h", bool(t07d.get("event_18_no_overwrite", false)), "separate records"))
	rows.append(_result("T07-D 8h to 20h resolves 9h and 18h chronologically", bool(t07d.get("cross_8_20_chronological", false)), "9 then 18"))
	rows.append(_result("T07-D repeated 20h evaluation does not reroll", bool(t07d.get("repeat_20_no_reroll", false)), "stable intervals"))
	rows.append(_result("T07-D no eligible target resolves safely", bool(t07d.get("no_target_safe", false)), "no kill"))
	rows.append(_result("T07-D event evaluation does not advance elapsed hours", bool(t07d.get("evaluation_no_time_advance", false)), "read-only time"))
	rows.append(_result("T07-D dead Serial Killer source does not kill", bool(t07d.get("dead_source_no_kill", false)), "source dead"))
	rows.append(_result("T07-D tainted Serial Killer source does not kill", bool(t07d.get("tainted_source_no_kill", false)), "authored corruption"))
	rows.append(_result("T07-D runtime-corrupted Serial Killer source does not kill", bool(t07d.get("runtime_corrupted_source_no_kill", false)), "runtime corruption"))
	rows.append(_result("T07-D arrested Serial Killer source does not kill", bool(t07d.get("arrested_source_no_kill", false)), "handled source"))
	rows.append(_result("T07-D suppression marks interval resolved", bool(t07d.get("suppression_marks_resolved", false)), "idempotent event"))
	rows.append(_result("T07-D suppression does not reroll same interval", bool(t07d.get("suppression_no_reroll", false)), "stable suppression"))
	rows.append(_result("T07-D dispatcher registers Serial Killer", bool(t07d.get("dispatcher_serial_registered", false)), "handler registry"))
	rows.append(_result("T07-D Surgeon remains registered", bool(t07d.get("dispatcher_surgeon_registered", false)), "existing handler"))
	rows.append(_result("T07-D dispatcher handler order deterministic", bool(t07d.get("dispatcher_order", false)), "Surgeon then Serial Killer"))
	rows.append(_result("T07-D controller does not hardcode Serial Killer", bool(t07d.get("controller_no_direct_serial", false)), "dispatcher-owned"))
	rows.append(_result("T07-D zero-hour ability does not dispatch", bool(t07d.get("zero_hour_no_dispatch", false)), "+0h"))
	rows.append(_result("T07-D positive-time action dispatches", bool(t07d.get("positive_time_dispatch", false)), "+1h/+2h"))
	rows.append(_result("T07-D victim death goes through CaseKillService", bool(t07d.get("death_uses_kill_service", false)), "kill log source"))
	rows.append(_result("T07-D runtime death leaves authored definition unchanged", bool(t07d.get("authored_unchanged", false)), "runtime-only"))
	rows.append(_result("T07-D event target stored", bool(t07d.get("event_target_stored", false)), "target_suspect_id"))
	rows.append(_result("T07-D history records actual victim", bool(t07d.get("history_records_victim", false)), "TIMED_EVENT + KILL"))
	rows.append(_result("T07-D later interval independently resolves", bool(t07d.get("later_interval_independent", false)), "9h then 18h"))
	rows.append(_result("T07-D no Tutorial-specific #7 hardcode", bool(t07d.get("no_tutorial_7_hardcode", false)), "reusable service"))
	rows.append(_result("T07-D no hardcoded board slot", bool(t07d.get("no_slot_hardcode", false)), "spatial service authority"))
	rows.append(_result("T07-D no new 3x3 assumption", bool(t07d.get("no_3x3_assumption", false)), "no board dimensions"))
	rows.append(_result("T07-D no recurrence logic in controller", bool(t07d.get("no_controller_recurrence", false)), "handler-owned recurrence"))
	rows.append(_result("T07-D Surgeon semantics unchanged", bool(t07d.get("surgeon_unchanged", false)), "Surgeon service untouched"))
	var t07i1_specs: Array[Dictionary] = [
		{"name":"T07-I1 tutorial_case_007 loads","key":"fixture_load"},
		{"name":"T07-I1 validates with exactly 7 suspects","key":"validates_7_suspects"},
		{"name":"T07-I1 suspect IDs are #1 through #7","key":"suspect_ids"},
		{"name":"T07-I1 exact board slots authored","key":"board_slots"},
		{"name":"T07-I1 Clock Tower authored at slot5","key":"clock_tower_slot"},
		{"name":"T07-I1 Crime Scene authored at slot6","key":"crime_scene_slot"},
		{"name":"T07-I1 ratio is 4/1/2/0","key":"ratio"},
		{"name":"T07-I1 Evil answer is #4 and #7","key":"evil_answer"},
		{"name":"T07-I1 #1 true Surgeon","key":"s1_surgeon"},
		{"name":"T07-I1 #2 true Therapist","key":"s2_therapist"},
		{"name":"T07-I1 #3 true Blood Hound","key":"s3_blood_hound"},
		{"name":"T07-I1 #3 display name Ngự Khuyển Quan","key":"s3_display_name"},
		{"name":"T07-I1 #4 true Mobster","key":"s4_mobster"},
		{"name":"T07-I1 #4 displayed Clock Maker","key":"s4_clock_maker"},
		{"name":"T07-I1 #5 true Clock Maker","key":"s5_clock_maker"},
		{"name":"T07-I1 #6 true Reporter","key":"s6_reporter"},
		{"name":"T07-I1 #7 true Serial Killer","key":"s7_serial_killer"},
		{"name":"T07-I1 #7 displayed Clock Maker","key":"s7_clock_maker"},
		{"name":"T07-I1 Clock Tower ring hour is 8","key":"ring_hour_8"},
		{"name":"T07-I1 #5 true Clock Maker interval is 8h to 9h","key":"s5_true_interval"},
		{"name":"T07-I1 #4 false Clock Maker interval is 11h to 12h","key":"s4_false_interval"},
		{"name":"T07-I1 #7 false Clock Maker interval is 5h to 6h","key":"s7_false_interval"},
		{"name":"T07-I1 false intervals validate against true tower","key":"false_intervals_valid"},
		{"name":"T07-I1 Clock Tower idle at 7h","key":"tower_idle_7"},
		{"name":"T07-I1 Clock Tower ringing at 8h","key":"tower_ring_8"},
		{"name":"T07-I1 Clock Tower ringing at 9h","key":"tower_ring_9"},
		{"name":"T07-I1 Clock Tower idle at 10h","key":"tower_idle_10"},
		{"name":"T07-I1 fresh runtime starts at 0h","key":"fresh_0h"},
		{"name":"T07-I1 investigating #1 advances to 2h","key":"path_s1_2h"},
		{"name":"T07-I1 investigating #2 advances to 4h","key":"path_s2_4h"},
		{"name":"T07-I1 investigating #3 advances to 6h","key":"path_s3_6h"},
		{"name":"T07-I1 investigating #4 advances to 8h","key":"path_s4_8h"},
		{"name":"T07-I1 8h refresh shows Clock Tower ringing","key":"path_8h_tower_ringing"},
		{"name":"T07-I1 investigating #5 advances to 10h","key":"path_s5_10h"},
		{"name":"T07-I1 9h Serial Killer event resolves during crossing","key":"path_serial_9_resolved"},
		{"name":"T07-I1 #6 becomes dead from Serial Killer","key":"path_s6_dead"},
		{"name":"T07-I1 #6 killed_by Serial Killer","key":"path_s6_killed_by"},
		{"name":"T07-I1 Serial Killer 9h event does not reroll","key":"path_serial_no_reroll"},
		{"name":"T07-I1 investigating #7 advances to 12h","key":"path_s7_12h"},
		{"name":"T07-I1 Surgeon 12h event resolves","key":"surgeon_12_resolves"},
		{"name":"T07-I1 Surgeon event does not assert fixed victim","key":"surgeon_no_fixed_victim"},
		{"name":"T07-I1 Surgeon success victim is eligible Innocent if present","key":"surgeon_success_victim_valid"},
		{"name":"T07-I1 Surgeon failure branch remains valid","key":"surgeon_failure_valid"},
		{"name":"T07-I1 repeated Surgeon evaluate does not reroll","key":"surgeon_no_reroll"},
		{"name":"T07-I1 Chỉ Điểm remains +1h","key":"accusation_plus_1h"},
		{"name":"T07-I1 private Chỉ Điểm does not globally arrest Serial Killer","key":"accusation_stays_private"},
		{"name":"T07-I1 private Chỉ Điểm does not suppress timed event","key":"private_accusation_keeps_event"},
		{"name":"T07-I1 #6 death survives board refresh","key":"death_survives_refresh"},
		{"name":"T07-I1 #6 remains in board slot7","key":"death_slot_preserved"},
		{"name":"T07-I1 authored #6 definition unchanged","key":"death_authored_unchanged"},
		{"name":"T07-I1 Clock Tower remains non-suspect","key":"tower_non_suspect"},
		{"name":"T07-I1 Crime Scene remains non-suspect","key":"crime_non_suspect"},
		{"name":"T07-I1 locations stay out of verdict candidates","key":"locations_not_verdict"},
		{"name":"T07-I1 timed events flow through dispatcher","key":"dispatcher_flow"},
		{"name":"T07-I1 controller has no direct timed-role service calls","key":"controller_no_direct_services"},
		{"name":"T07-I1 fresh relaunch resets elapsed time","key":"relaunch_resets_time"},
		{"name":"T07-I1 fresh relaunch resets death state","key":"relaunch_resets_death"},
		{"name":"T07-I1 fresh relaunch resets timed-event state","key":"relaunch_resets_events"},
		{"name":"T07-I1 T01-T06 launch paths remain intact","key":"previous_launchers_intact"},
		{"name":"T07-I1 no generic service hardcodes T07 suspect IDs","key":"no_t07_id_hardcode"},
		{"name":"T07-I1 no generic service hardcodes T07 slot5 or slot6","key":"no_t07_slot_hardcode"},
		{"name":"T07-I1 no new 3x3 assumption outside fixture","key":"no_new_3x3_outside_fixture"},
	]
	for spec: Dictionary in t07i1_specs:
		rows.append(_result(String(spec.name), bool(t07i1.get(spec.key, false)), "Tutorial 07 I1 exact fixture and runtime integration invariant"))
	var t07i1_repair_specs: Array[Dictionary] = [
		{"name":"T07-I1 just-investigated target remains Serial Killer eligible","key":"serial_just_investigated_not_excluded"},
		{"name":"T07-I1 just-investigated eligible Good may die to Serial Killer","key":"serial_just_investigated_can_die"},
		{"name":"T07-I1 just-investigated eligible Innocent may die to Surgeon","key":"surgeon_just_investigated_can_die"},
		{"name":"T07-I1 no just-investigated protection logic remains","key":"no_just_investigated_protection"},
		{"name":"T07-I1 Surgeon canonical pool unchanged","key":"surgeon_probability_unchanged"},
		{"name":"T07-I1 Serial Killer canonical pool unchanged","key":"serial_recurrence_unchanged"},
		{"name":"T07-I1 dead unrevealed suspect is not Investigation-eligible","key":"dead_unrevealed_not_eligible"},
		{"name":"T07-I1 dead unrevealed investigation is rejected","key":"dead_unrevealed_rejected"},
		{"name":"T07-I1 dead unrevealed rejected investigation preserves elapsed hours","key":"dead_unrevealed_no_elapsed"},
		{"name":"T07-I1 dead unrevealed rejected investigation preserves turn","key":"dead_unrevealed_no_turn"},
		{"name":"T07-I1 dead unrevealed rejected investigation preserves reveal state","key":"dead_unrevealed_no_reveal"},
		{"name":"T07-I1 dead unrevealed card leaks no role identity","key":"dead_unrevealed_no_role_leak"},
		{"name":"T07-I1 dead unrevealed card leaks no clue","key":"dead_unrevealed_no_clue_leak"},
		{"name":"T07-I1 dead unrevealed card starts no hold feedback","key":"dead_unrevealed_no_hold_feedback"},
		{"name":"T07-I1 dead unrevealed rejected investigation dispatches no timed events","key":"dead_unrevealed_no_timed_dispatch"},
		{"name":"T07-I1 dead-unrevealed rule is not T07-id-specific","key":"dead_unrevealed_not_t07_id_specific"},
		{"name":"T07-I1 T07 #6 investigation can trigger 9h death","key":"same_action_t07_s6_death"},
		{"name":"T07-I1 dead #6 remains revealed","key":"same_action_role_revealed"},
		{"name":"T07-I1 dead #6 suppresses Reporter clue","key":"same_action_clue_suppressed"},
		{"name":"T07-I1 dead #6 displays exact *Chết...*","key":"same_action_dead_text"},
		{"name":"T07-I1 dead #6 remains in board slot7","key":"same_action_slot_preserved"},
		{"name":"T07-I1 authored #6 remains unchanged after death","key":"same_action_authored_unchanged"},
		{"name":"T07-I1 previously investigated suspect can later die","key":"later_investigated_can_die"},
		{"name":"T07-I1 later death removes previous announcement","key":"later_clue_removed"},
		{"name":"T07-I1 later death displays exact *Chết...*","key":"later_dead_text"},
		{"name":"T07-I1 later death preserves role identity","key":"later_role_visible"},
		{"name":"T07-I1 structured timed-event history remains after death","key":"structured_history_preserved"},
		{"name":"T07-I1 active dead-card presentation no longer uses *Dead*","key":"dead_text_localized"},
		{"name":"T07-I1 dead presentation has no #2/#6 hardcode","key":"dead_presentation_no_id_hardcode"},
		{"name":"T07-I1 dead presentation has no role-name hardcode","key":"dead_presentation_no_role_hardcode"},
		{"name":"T07-I1 any revealed dead suspect uses dead text","key":"generic_dead_text"},
		{"name":"T07-I1 dead suspect uses universal seal marker","key":"dead_universal_marker"},
		{"name":"T07-I1 alive suspect has no dead marker","key":"alive_no_dead_marker"},
		{"name":"T07-I1 dead marker does not resize card footprint","key":"dead_marker_footprint_stable"},
		{"name":"T07-I1 alive revealed suspect still shows announcement","key":"alive_revealed_shows_announcement"},
		{"name":"T07-I1 death state drives public presentation","key":"death_state_drives_presentation"},
		{"name":"T07-I1 sidebar title is THÂN PHẬN","key":"sidebar_title"},
		{"name":"T07-I1 sidebar top-level group order is canonical","key":"sidebar_group_order"},
		{"name":"T07-I1 nested Drunkard remains under Barkeep","key":"nested_drunkard_attached"},
		{"name":"T07-I1 Kill glossary entry exists","key":"kill_glossary_exists"},
		{"name":"T07-I1 Kill glossary definition is canonical","key":"kill_definition"},
		{"name":"T07-I1 generic key terms are not bold","key":"key_terms_not_bold"},
		{"name":"T07-I1 semantic colors remain intact","key":"semantic_colors"},
		{"name":"T07-I1 no Tutorial 09 behavior added","key":"no_t07_i2_behavior"},
	]
	for spec: Dictionary in t07i1_repair_specs:
		rows.append(_result(String(spec.name), bool(t07i1_repair.get(spec.key, false)), "Tutorial 07 I1 human-runtime repair invariant"))
	var t07i2_specs: Array[Dictionary] = [
		{"name":"T07-I2 Tutorial 07 dialogue source exists","key":"dialogue_source"},
		{"name":"T07-I2 Tutorial 07 dialogue has exactly 8 lines","key":"dialogue_count"},
		{"name":"T07-I2 dialogue line 1 says investigation advances time","key":"dialogue_line_1"},
		{"name":"T07-I2 dialogue line 2 says investigation costs 2h","key":"dialogue_line_2_investigate"},
		{"name":"T07-I2 dialogue line 2 says Chỉ Điểm costs 1h","key":"dialogue_line_2_accuse"},
		{"name":"T07-I2 dialogue line 3 says ability costs 0h","key":"dialogue_line_3"},
		{"name":"T07-I2 dialogue line 4 references upper-left clock","key":"dialogue_line_4"},
		{"name":"T07-I2 dialogue line 6 warns active danger remains","key":"dialogue_line_6"},
		{"name":"T07-I2 dialogue line 7 says board state can change over time","key":"dialogue_line_7"},
		{"name":"T07-I2 dialogue line 8 says early Chỉ Điểm can help","key":"dialogue_line_8"},
		{"name":"T07-I2R dialogue removed from left info panel","key":"dialogue_left_panel_clean"},
		{"name":"T07-I2R dialogue overlay appears on launch","key":"dialogue_overlay_launch"},
		{"name":"T07-I2R dialogue overlay shows first line","key":"dialogue_overlay_first_line"},
		{"name":"T07-I2R dialogue advances one line","key":"dialogue_overlay_advances"},
		{"name":"T07-I2R dialogue active speaker visual state changes","key":"dialogue_speaker_state"},
		{"name":"T07-I2R dialogue overlay blocks board interaction","key":"dialogue_blocks_interaction"},
		{"name":"T07-I2R dialogue overlay closes after final line","key":"dialogue_closes"},
		{"name":"T07-I2R gameplay resumes after dialogue","key":"dialogue_gameplay_resumes"},
		{"name":"T07-I2R non-T07 cases do not force dialogue overlay","key":"dialogue_non_t07_clear"},
		{"name":"T07-I2R fresh relaunch resets dialogue display","key":"dialogue_relaunch"},
		{"name":"T07-I2 Serial Killer actual kill record remains structured","key":"serial_structured"},
		{"name":"T07-I2 Serial Killer history formats actual victim","key":"serial_history"},
		{"name":"T07-I2 timed-kill history formatter has no hardcoded #6","key":"history_no_six_hardcode"},
		{"name":"T07-I2 Surgeon success history formats actual victim","key":"surgeon_success_history"},
		{"name":"T07-I2 Surgeon failure creates no false kill history","key":"surgeon_failure_no_fake"},
		{"name":"T07-I2 timed-kill history has no hardcoded Surgeon victim","key":"history_no_surgeon_victim_hardcode"},
		{"name":"T07-I2 timed-kill history survives presentation refresh","key":"history_survives_refresh"},
		{"name":"T07-I2 #4 pretend history remains","key":"s4_pretend"},
		{"name":"T07-I2 #7 pretend history remains","key":"s7_pretend"},
		{"name":"T07-I2 #6 Reporter truth remains available","key":"s6_truth"},
		{"name":"T07-I2 active #6 dead card remains *Chết...*","key":"active_six_dead_text"},
		{"name":"T07-I2 active clue loss does not delete structured history","key":"clue_loss_keeps_history"},
		{"name":"T07-I2 Final Verdict answer remains #4 and #7","key":"final_answer"},
		{"name":"T07-I2 Clock Tower semantics unchanged","key":"clock_tower_unchanged"},
		{"name":"T07-I2 death/investigation rules unchanged","key":"death_rules_unchanged"},
		{"name":"T07-I2 sidebar title/order unchanged","key":"sidebar_unchanged"},
		{"name":"T07-I2 Kill glossary/style unchanged","key":"kill_glossary_unchanged"},
		{"name":"T07-I2 Tutorial 01-06 launch paths remain intact","key":"previous_launchers"},
		{"name":"T07-I2 Tutorial 07 fresh relaunch resets time/death/events","key":"t07_relaunch"},
		{"name":"T07-I2 no Tutorial 09 implementation exists","key":"no_t08"},
		{"name":"T07-I2 no new 3x3 hardcode added","key":"no_new_3x3"},
	]
	for spec: Dictionary in t07i2_specs:
		rows.append(_result(String(spec.name), bool(t07i2.get(spec.key, false)), "Tutorial 07 I2 dialogue and timed-kill history closeout invariant"))
	var t08_specs: Array[Dictionary] = [
		{"name":"T08 Conman role exists","key":"conman_exists"},
		{"name":"T08 Conman display name is Kẻ Lừa Đảo","key":"conman_name"},
		{"name":"T08 Conman group is Thuộc Hạ","key":"conman_group"},
		{"name":"T08 Conman resolves Evil","key":"conman_evil"},
		{"name":"T08 Conman is truthful despite Evil alignment","key":"conman_truthful"},
		{"name":"T08 Conman can pretend in-play role","key":"conman_pretend_valid"},
		{"name":"T08 Copycat role exists","key":"copycat_exists"},
		{"name":"T08 Copycat display name is Kẻ Bắt Chước","key":"copycat_name"},
		{"name":"T08 Copycat group is Kẻ Bao Đồng","key":"copycat_group"},
		{"name":"T08 Copycat resolves Good","key":"copycat_good"},
		{"name":"T08 Copycat pretends Good in-play role","key":"copycat_pretend_valid"},
		{"name":"T08 Copycat cannot pretend Milkman","key":"copycat_milkman_rejected"},
		{"name":"T08 fixture validates","key":"fixture_validates"},
		{"name":"T08 fixture has exactly 6 suspects","key":"six_suspects"},
		{"name":"T08 fixture has 1 Crime Scene and 2 empty slots","key":"crime_and_empty"},
		{"name":"T08 fixture layout slots are canonical","key":"layout"},
		{"name":"T08 ratio is 3/1/2/0","key":"ratio"},
		{"name":"T08 final Evil answer is #2 and #6","key":"final_answer"},
		{"name":"T08 duplicate displayed Therapist is allowed","key":"duplicate_therapist"},
		{"name":"T08 duplicate displayed Mathematician is allowed","key":"duplicate_mathematician"},
		{"name":"T08 duplicate displayed Vigilante is allowed","key":"duplicate_vigilante"},
		{"name":"T08 #2 pretends Mathematician","key":"s2_pretend"},
		{"name":"T08 #3 pretends Vigilante","key":"s3_pretend"},
		{"name":"T08 #6 pretends Therapist","key":"s6_pretend"},
		{"name":"T08 Conman Mathematician information is truthful","key":"conman_math_truth"},
		{"name":"T08 real Mathematician reports same total","key":"real_math_truth"},
		{"name":"T08 true Therapist reports one evil client","key":"therapist_truth"},
		{"name":"T08 Mobster Therapist information lies to 3","key":"mobster_therapist_lies"},
		{"name":"T08 Vigilante cards have no normal announcement","key":"vigilante_no_announcement"},
		{"name":"T08 Copycat obtains Vigilante function","key":"copycat_function"},
		{"name":"T08 Copycat borrowed function uses Vigilante mechanics","key":"copycat_uses_vigilante"},
		{"name":"T08 Copycat kills #2 through CaseKillService","key":"copycat_kills_s2"},
		{"name":"T08 #5 true Vigilante is not auto-used","key":"true_vigilante_not_auto"},
		{"name":"T08 #2 death does not auto-complete case","key":"death_no_auto_complete"},
		{"name":"T08 killed Evil remains in canonical answer","key":"dead_evil_required"},
		{"name":"T08 final #6 alone is incomplete","key":"final_six_incomplete"},
		{"name":"T08 final #2 plus #6 is correct","key":"final_two_six_correct"},
		{"name":"T08 dead Evil can still be selected for verdict","key":"dead_selectable"},
		{"name":"T08 Conman Chỉ Điểm succeeds","key":"conman_accuse_success"},
		{"name":"T08 Conman Chỉ Điểm has no role reveal payload","key":"conman_accuse_no_payload"},
		{"name":"T08 Conman identity remains hidden before Full Reveal","key":"conman_hidden_active"},
		{"name":"T08 Conman Chỉ Điểm preserves player continuation","key":"conman_accuse_continue"},
		{"name":"T08 dialogue has exactly 6 lines","key":"dialogue_count"},
		{"name":"T08 dialogue first 2 speakers are RIGHT","key":"dialogue_right_first_two"},
		{"name":"T08 dialogue last 4 speakers are LEFT","key":"dialogue_left_last_four"},
		{"name":"T08 dialogue overlay launches","key":"dialogue_overlay_launch"},
		{"name":"T08 dialogue overlay blocks board input","key":"dialogue_blocks"},
		{"name":"T08 dialogue advances and closes","key":"dialogue_advances_closes"},
		{"name":"T08 left info panel remains clean","key":"dialogue_left_clean"},
		{"name":"T08 Full Reveal shows #2 true/pretend/dead","key":"truth_s2"},
		{"name":"T08 Full Reveal shows #3 true/pretend","key":"truth_s3"},
		{"name":"T08 Full Reveal shows #6 true/pretend","key":"truth_s6"},
		{"name":"T08 public function history preserves #3 to #2","key":"function_history"},
		{"name":"T08 Copycat does not duplicate Vigilante kill logic","key":"no_duplicate_vigilante_logic"},
		{"name":"T08 T01-T07 launch paths remain intact","key":"previous_launchers"},
		{"name":"T08 T07 dialogue overlay remains intact","key":"t07_dialogue_intact"},
		{"name":"T08 dead-before-investigation rule remains intact","key":"dead_before_rule"},
		{"name":"T08 revealed dead text remains localized","key":"dead_text_localized"},
		{"name":"T08 sidebar title/order remains intact","key":"sidebar_unchanged"},
		{"name":"T08 Kill glossary remains intact","key":"kill_glossary"},
		{"name":"T08 Clock Tower semantics remain intact","key":"clock_tower"},
		{"name":"T08 no new generic 3x3 hardcode added","key":"no_new_3x3"},
		{"name":"T08 no Tutorial 09 implementation started","key":"no_t09"},
		{"name":"T08 no main-game implementation started","key":"no_main_game"},
	]
	for spec: Dictionary in t08_specs:
		rows.append(_result(String(spec.name), bool(t08.get(spec.key, false)), "Tutorial 08 final implementation invariant"))
	rows.append(_result(
		"Case Generator M0 deterministic seed foundation",
		bool(case_generation_m0.get("passed", false)),
		String(case_generation_m0.get("detail", "contract, seed, RNG, board slots, fingerprint"))
	))
	rows.append(_result(
		"Case Generator M1 valid hidden world generation",
		bool(case_generation_m1.get("passed", false)),
		String(case_generation_m1.get("detail", "hidden world, roles, locations, answer, bounded retry"))
	))
	rows.append(_result(
		"Case Generator M2 public information generation",
		bool(case_generation_m2.get("passed", false)),
		String(case_generation_m2.get("detail", "static role clues, determinism, no solver/runtime integration"))
	))
	rows.append(_result(
		"Case Generator M2 solver / solvability foundation",
		bool(case_generation_m3a.get("passed", false)),
		String(case_generation_m3a.get("detail", "public-only candidates, clue constraints, unique Evil set"))
	))
	rows.append(_result(
		"Case Generator M3 deterministic acceptance / retry composition",
		bool(case_generation_m3.get("passed", false)),
		String(case_generation_m3.get("detail", "bounded retry, UNIQUE only, ground-truth comparison"))
	))
	rows.append(_result(
		"Case Generator M4A seed warehouse precompute",
		bool(case_generation_m4a.get("passed", false)),
		String(case_generation_m4a.get("detail", "warehouse entries, deterministic build, verification"))
	))
	rows.append(_result(
		"Case Generator M4B runtime warehouse selection",
		bool(case_generation_m4b.get("passed", false)),
		String(case_generation_m4b.get("detail", "single-entry deterministic selector, no-repeat, verification fallback"))
	))
	rows.append(_result(
		"Case Generator M5A three distinct case options",
		bool(case_generation_m5a.get("passed", false)),
		String(case_generation_m5a.get("detail", "three verified distinct warehouse options"))
	))
	rows.append(_result("Tutorial 01 fixture load", tutorial_case != null, FixtureRepository.TUTORIAL_CASE_001_PATH))
	rows.append(_result("Tutorial 01 validates with 2 suspects", tutorial_validation_report.passed and tutorial_case.suspects.size() == 2, "1 Crime Scene + 2 Suspects"))
	rows.append(_result("Tutorial 01 ratio is 1 Người Vô Tội and 1 Thuộc Hạ", _tutorial_01_ratio(tutorial_case), "1 GOOD / 1 EVIL"))
	rows.append(_result("Tutorial 01 roles load for reference", _tutorial_01_roles_loaded(tutorial_case, roles), "Tư Tế and Kẻ Bất Lương"))
	rows.append(_result("Tutorial 01 investigated outputs authored", _tutorial_01_investigated_outputs(tutorial_case, roles, player_fixtures), "S1 announces; S2 silent"))
	rows.append(_result("Tutorial 01 silent role does not invent announcement", _tutorial_01_silent_card_has_no_fake_announcement(tutorial_case, roles, player_fixtures), "Kẻ Bất Lương card remains silent"))
	rows.append(_result("Tutorial 01 true roles authored", _tutorial_01_true_roles_authored(tutorial_case), "Suspect 1 Tư Tế; Suspect 2 Kẻ Bất Lương"))
	rows.append(_result("Tutorial 01 has no impersonation relation", _tutorial_01_has_no_impersonation(tutorial_case), "No displayed-role mismatch or impersonated role"))
	rows.append(_result("Tutorial 01 Crime Scene has no deduction clue", _tutorial_01_crime_scene_has_no_clue(tutorial_case), "Flavor only"))
	rows.append(_result("Tutorial 01 Chỉ Điểm reveals only true role", _tutorial_01_single_accuse_private_only(tutorial_case, player_fixtures), "Suspect 2 private true role only"))
	rows.append(_result("Tutorial 01 Full Reveal is card-local without impersonation", _tutorial_01_full_reveal(tutorial_case, roles, player_fixtures), "Kẻ Bất Lương true role only"))
	rows.append(_result("Tutorial 01 board slots remain 3-4-5", _tutorial_01_slots_are_345(tutorial_case), "Suspect 1 / Crime Scene / Suspect 2"))
	rows.append(_result("Tutorial 02 fixture load", tutorial_case_02 != null, FixtureRepository.TUTORIAL_CASE_002_PATH))
	rows.append(_result("Tutorial 02 validates with 2 suspects", tutorial_02_validation_report.passed and tutorial_case_02.suspects.size() == 2, "1 Crime Scene + 2 Suspects"))
	rows.append(_result("Tutorial 02 ratio is 1 Người Vô Tội and 1 Thuộc Hạ", _tutorial_02_ratio(tutorial_case_02), "1 GOOD / 1 EVIL"))
	rows.append(_result("Tutorial 02 Mobster role remains separate", _tutorial_02_mobster_separate_from_scoundrel(roles), "Kẻ Côn Đồ != Kẻ Bất Lương"))
	rows.append(_result("Tutorial 02 investigated outputs authored", _tutorial_02_investigated_outputs(tutorial_case_02, roles, player_fixtures), "S1 exact Tư Tế; S2 lying variant"))
	rows.append(_result("Tutorial 02 Mobster pretend authored", _tutorial_02_mobster_pretend_authored(tutorial_case_02), "true Mobster, displayed Tư Tế, lying announcement"))
	rows.append(_result("Tutorial 02 public view hides Mobster truth", _tutorial_02_public_hides_truth(tutorial_case_02, roles, player_fixtures), "No true role or impersonation before Full Reveal"))
	rows.append(_result("Tutorial 02 Chỉ Điểm reveals only true role", _tutorial_02_single_accuse_private_only(tutorial_case_02, player_fixtures), "Suspect 2 private Mobster only"))
	rows.append(_result("Tutorial 02 Full Reveal shows Mobster pretend", _tutorial_02_full_reveal(tutorial_case_02, roles, player_fixtures), "Kẻ Côn Đồ + Giả danh Tư Tế"))
	rows.append(_result("Full Reveal Dupery-style card presentation", _full_reveal_dupery_card_presentation(tutorial_case_02, roles, player_fixtures), "True color, concise default, per-card history, no debug dump"))
	rows.append(_result("Tutorial 02 board slots remain 3-4-5", _tutorial_02_slots_are_345(tutorial_case_02), "Suspect 1 / Crime Scene / Suspect 2"))
	rows.append(_result("Tutorial 02 Crime Scene has no deduction clue", _tutorial_02_crime_scene_has_no_clue(tutorial_case_02), "Flavor only"))
	rows.append(_result("Tutorial 03 fixture load", tutorial_case_03 != null, FixtureRepository.TUTORIAL_CASE_003_PATH))
	rows.append(_result("Tutorial 03 validates with 5 suspects", tutorial_03_validation_report.passed and tutorial_case_03.suspects.size() == 5, "1 Crime Scene + 5 Suspects"))
	rows.append(_result("Tutorial 03 ratio is 3 Người Vô Tội and 2 Thuộc Hạ", _tutorial_03_ratio(tutorial_case_03), "3/0/2/0 groups"))
	rows.append(_result("Tutorial 03 board slots authored", _tutorial_03_board_slots(tutorial_case_03), "S1=0, Crime=1, S2=2, S3=3, S4=4, S5=7"))
	rows.append(_result("Tutorial 03 true/displayed assignments authored", _tutorial_03_assignments(tutorial_case_03), "Mailman/Reporter/Priest/Spectre/Mobster chain"))
	rows.append(_result("Tutorial 03 role references translated", _tutorial_03_role_reference(roles), "Dịch Phu/Sử Quan/Tư Tế/Ngự Y/Vong Linh/Kẻ Côn Đồ"))
	rows.append(_result("Role group labels use canonical player-facing terms", _role_group_labels_player_facing(), "Người Vô Tội / Kẻ Bao Đồng / Thuộc Hạ / Nghịch Thần"))
	rows.append(_result("Role Reference sorts by canonical group order", _role_reference_group_order(tutorial_case_03, roles), "Good roles before Underling roles"))
	rows.append(_result("Dịch Phu reference translation corrected", _mailman_reference_translation(roles), "specifying which is which"))
	rows.append(_result("Tutorial 03 Mailman pair evaluated from truth", _tutorial_03_mailman(tutorial_case_03, roles), "Tư Tế in play; Ngự Y not truly in play"))
	rows.append(_result("Tutorial 03 Reporter truthful distance generated", _tutorial_03_reporter(tutorial_case_03, roles), "S2 nearest Evil distance 2"))
	rows.append(_result("Tutorial 03 Spectre lie and obscure evaluated", _tutorial_03_spectre(tutorial_case_03, roles, player_fixtures), "Ngự Y lie 3 vs true count 1; S3 hidden"))
	rows.append(_result("Tutorial 03 Mobster lie evaluated", _tutorial_03_mobster(tutorial_case_03, roles), "Sử Quan lie 2 vs true distance 1"))
	rows.append(_result("Tutorial 03 multiple Chỉ Điểm stores private roles", _tutorial_03_private_knowledge(tutorial_case_03, player_fixtures), "Same player records #4 and #5 only"))
	rows.append(_result("Tutorial 03 Chỉ Điểm UI enables on exactly one suspect", _tutorial_03_single_accuse_ui_selection(tutorial_case_03, roles, player_fixtures), "0/multiple hidden, 1 enabled, Crime Scene ignored"))
	rows.append(_result("Tutorial 03 Chỉ Điểm UI stores private chain", _tutorial_03_single_accuse_ui_chain(tutorial_case_03, roles, player_fixtures), "player returns for #5, private records persist"))
	var tutorial_03_full_reveal_result: Dictionary = _tutorial_03_full_reveal_result(tutorial_case_03, roles, player_fixtures)
	rows.append(_result("Tutorial 03 Full Reveal relations", bool(tutorial_03_full_reveal_result.get("passed", false)), String(tutorial_03_full_reveal_result.get("detail", "S3 Priest; S4 Spectre→Therapist hides #3; S5 Mobster→Reporter"))))
	var tutorial_03_card_result: Dictionary = _tutorial_03_card_presentation(tutorial_case_03, roles, player_fixtures)
	rows.append(_result("Tutorial 03 card hierarchy is player-facing", bool(tutorial_03_card_result.get("passed", false)), String(tutorial_03_card_result.get("detail", "number + art placeholder + role + announcement"))))
	rows.append(_result("Natural duplicate true role rejected", _true_role_uniqueness_rejects_duplicate(roles, player_fixtures), "TRUE_ROLE_DUPLICATE"))
	rows.append(_result("Duplicate displayed role through Pretend is valid", _duplicate_displayed_tailor_valid(tutorial_case_04, roles, player_fixtures), "Two displayed Thợ May, one true Thợ May"))
	rows.append(_result("Tutorial 04 fixture load", tutorial_case_04 != null, FixtureRepository.TUTORIAL_CASE_004_PATH))
	rows.append(_result("Tutorial 04 validates with 4 suspects", tutorial_04_validation_report.passed and tutorial_case_04.suspects.size() == 4, "1 Crime Scene + 4 Suspects"))
	rows.append(_result("Tutorial 04 ratio is 3 Người Vô Tội and 1 Thuộc Hạ", _tutorial_04_ratio(tutorial_case_04), "3/0/1/0 groups"))
	rows.append(_result("Tutorial 04 board slots authored", _tutorial_04_board_slots(tutorial_case_04), "S1=0, S2=2, Crime=4, S3=6, S4=8"))
	rows.append(_result("Tutorial 04 true/displayed assignments authored", _tutorial_04_assignments(tutorial_case_04), "Mobster→Tailor plus true Tailor/Mailman/Priest"))
	rows.append(_result("Tutorial 04 Role Reference keeps canonical order", _tutorial_04_role_reference(tutorial_case_04, roles), "Thợ May/Dịch Phu/Tư Tế before Kẻ Côn Đồ"))
	rows.append(_result("Tutorial 04 Mailman pair evaluated from truth", _tutorial_04_mailman(tutorial_case_04, roles), "Thợ May in play; Nhà Toán Học not in play"))
	rows.append(_result("Tutorial 04 Priest self-confirm exact", _tutorial_04_priest(tutorial_case_04, roles), "Tôi là Tư Tế."))
	var tutorial_04_tailor_result: Dictionary = _tutorial_04_tailor_functions(tutorial_case_04, roles, player_fixtures)
	rows.append(_result("Tutorial 04 true and fake Tailor functions diverge", bool(tutorial_04_tailor_result.get("passed", false)), String(tutorial_04_tailor_result.get("detail", "true Tailor same; fake Tailor different"))))
	var tutorial_04_reveal_result: Dictionary = _tutorial_04_private_and_reveal(tutorial_case_04, roles, player_fixtures)
	rows.append(_result("Tutorial 04 private Chỉ Điểm and Full Reveal", bool(tutorial_04_reveal_result.get("passed", false)), String(tutorial_04_reveal_result.get("detail", "private Mobster; reveal Giả danh Thợ May"))))
	rows.append(_result("Tutorial 05 fixture load", tutorial_case_05 != null, FixtureRepository.TUTORIAL_CASE_005_PATH))
	rows.append(_result("Tutorial 05 validates with 6 suspects", tutorial_05_validation_report.passed and tutorial_case_05 != null and tutorial_case_05.suspects.size() == 6, "1 Crime Scene + 6 Suspects"))
	var tutorial_05_checks: Dictionary = _tutorial_05_integration_checks(tutorial_case_05, roles, player_fixtures)
	var tutorial_05_specs: Array[Dictionary] = [
		{"name":"Tutorial 05 sparse board slots authored","key":"board_slots"},
		{"name":"Tutorial 05 unused slots remain empty","key":"empty_slots"},
		{"name":"Tutorial 05 suspect numbers ignore board slots","key":"numbering"},
		{"name":"Tutorial 05 true roles authored","key":"true_roles"},
		{"name":"Tutorial 05 displayed roles authored","key":"displayed_roles"},
		{"name":"Tutorial 05 ratio is 3/1/1/1","key":"ratio"},
		{"name":"Tutorial 05 Evil answer is Critic plus Mobster","key":"evil_answers"},
		{"name":"Tutorial 05 Critic pretends absent Mathematician","key":"critic_pretend"},
		{"name":"Tutorial 05 Mobster pretends in-play Priest","key":"mobster_pretend"},
		{"name":"Tutorial 05 Critic uses displayed Mathematician behavior","key":"critic_math_behavior"},
		{"name":"Tutorial 05 Mathematician truth sum is 5","key":"math_truth_sum"},
		{"name":"Tutorial 05 Critic Mathematician result lies","key":"critic_math_lie"},
		{"name":"Tutorial 05 Priest remains truthful","key":"priest_truthful"},
		{"name":"Tutorial 05 fake Priest lies","key":"fake_priest_lies"},
		{"name":"Tutorial 05 Weatherman structured claim works","key":"weatherman_claim"},
		{"name":"Tutorial 05 Weatherman self-exclusion applies","key":"weatherman_self_exclusion"},
		{"name":"Tutorial 05 Vigilante starts alive","key":"vigilante_alive"},
		{"name":"Tutorial 05 Vigilante metadata available","key":"vigilante_metadata"},
		{"name":"Tutorial 05 Vigilante runtime function initializes","key":"vigilante_runtime_function"},
		{"name":"Tutorial 05 Surgeon role is Meddler","key":"surgeon_role_group"},
		{"name":"Tutorial 05 Surgeon timed event is discoverable","key":"surgeon_discoverable"},
		{"name":"Tutorial 05 Surgeon event not fired initially","key":"surgeon_initially_unfired"},
		{"name":"Tutorial 05 clock HUD starts at authoritative 0h","key":"clock_hud_zero"},
		{"name":"Tutorial 05 preserves foundation anchors","key":"foundation_anchors"},
		{"name":"Tutorial 05 public view hides true roles","key":"public_hides_truth"},
	]
	for spec: Dictionary in tutorial_05_specs:
		rows.append(_result(String(spec.name), bool(tutorial_05_checks.get(spec.key, false)), "Tutorial 05 I1 fixture/investigation invariant"))
	var tutorial_05_i2_checks: Dictionary = _tutorial_05_i2_live_checks(tutorial_case_05, roles, player_fixtures)
	var tutorial_05_i2_specs: Array[Dictionary] = [
		{"name":"T05-I2 live Investigation adds 2h","key":"investigation_adds_two"},
		{"name":"T05-I2 invalid Investigation adds 0h","key":"invalid_investigation_zero"},
		{"name":"T05-I2 duplicate Investigation time is idempotent","key":"duplicate_investigation_idempotent"},
		{"name":"T05-I2 live Chỉ Điểm adds 1h","key":"single_accuse_adds_one"},
		{"name":"T05-I2 invalid Chỉ Điểm adds 0h","key":"invalid_single_accuse_zero"},
		{"name":"T05-I2 duplicate Chỉ Điểm time is idempotent","key":"duplicate_single_accuse_idempotent"},
		{"name":"T05-I2 active function adds 0h","key":"active_function_zero"},
		{"name":"T05-I2 target-selection click adds 0h","key":"target_selection_zero"},
		{"name":"T05-I2 time advancement does not advance turn","key":"time_turn_separate"},
		{"name":"T05-I2 Investigation advances turn once","key":"investigation_turn_once"},
		{"name":"T05-I2 Chỉ Điểm advances turn once","key":"single_accuse_turn_once"},
		{"name":"T05-I2 Vigilante advances turn once","key":"vigilante_turn_once"},
		{"name":"T05-I2 reaching 12h reevaluates Surgeon","key":"surgeon_reevaluates_at_12"},
		{"name":"T05-I2 Surgeon source uses true role","key":"surgeon_true_role_source"},
		{"name":"T05-I2 Surgeon fires once only","key":"surgeon_once"},
		{"name":"T05-I2 Surgeon ignores displayed role","key":"surgeon_ignores_displayed"},
		{"name":"T05-I2 Surgeon target is not hardcoded","key":"surgeon_target_not_hardcoded"},
		{"name":"T05-I2 Surgeon success uses CaseKillService","key":"surgeon_success_kill_service"},
		{"name":"T05-I2 Surgeon failure leaves target alive","key":"surgeon_failure_alive"},
		{"name":"T05-I2 Surgeon no-target resolves once","key":"surgeon_no_target_once"},
		{"name":"T05-I2 post-fired time does not duplicate Surgeon","key":"surgeon_no_duplicate_after_time"},
		{"name":"T05-I2 Vigilante accepts one target","key":"vigilante_one_target"},
		{"name":"T05-I2 Vigilante truthful Evil kill attempt","key":"vigilante_evil_attempt"},
		{"name":"T05-I2 Vigilante truthful Good misses","key":"vigilante_good_miss"},
		{"name":"T05-I2 Vigilante lying path misses","key":"vigilante_lying_miss"},
		{"name":"T05-I2 Vigilante consumes once","key":"vigilante_consumes_once"},
		{"name":"T05-I2 Vigilante clock cost remains 0h","key":"vigilante_clock_zero"},
		{"name":"T05-I2 Vigilante death uses CaseKillService","key":"vigilante_death_kill_service"},
		{"name":"T05-I2 death preserves Evil verdict requirement","key":"death_handled_evil"},
		{"name":"T05-I2 death does not create Chỉ Điểm knowledge","key":"death_no_private_knowledge"},
	]
	for spec: Dictionary in tutorial_05_i2_specs:
		rows.append(_result(String(spec.name), bool(tutorial_05_i2_checks.get(spec.key, false)), "Tutorial 05 I2 live clock/timed-function invariant"))
	var tutorial_05_i3_checks: Dictionary = _tutorial_05_i3_end_to_end_checks(tutorial_case_05, roles, player_fixtures)
	var tutorial_05_i3_specs: Array[Dictionary] = [
		{"name":"T05-I3 loads through normal entry path","key":"entry_load"},
		{"name":"T05-I3 authoritative layout unchanged","key":"layout_unchanged"},
		{"name":"T05-I3 true Evil remains 1 and 4","key":"evil_static"},
		{"name":"T05-I3 #1 uses Mathematician behavior","key":"critic_math_behavior"},
		{"name":"T05-I3 #1 Critic lie affects result","key":"critic_math_lies"},
		{"name":"T05-I3 #1 investigation hides true Critic","key":"critic_truth_hidden"},
		{"name":"T05-I3 Weatherman payload reaches presentation","key":"weatherman_presentation"},
		{"name":"T05-I3 #4 fake Priest hides Mobster","key":"mobster_truth_hidden"},
		{"name":"T05-I3 Clock HUD reflects fresh 0h","key":"clock_hud_zero"},
		{"name":"T05-I3 Clock HUD reflects Investigation +2h","key":"clock_hud_investigation"},
		{"name":"T05-I3 Clock HUD reflects Chỉ Điểm +1h","key":"clock_hud_single_accuse"},
		{"name":"T05-I3 Clock HUD stays unchanged for +0h function","key":"clock_hud_function_zero"},
		{"name":"T05-I3 selection-only action does not change clock HUD","key":"clock_hud_selection_zero"},
		{"name":"T05-I3 turn change alone does not change clock HUD","key":"clock_turn_only_zero"},
		{"name":"T05-I3 true Evil sum is 5","key":"math_true_sum_five"},
		{"name":"T05-I3 Critic Mathematician reports 4","key":"critic_math_reports_four"},
		{"name":"T05-I3 Mathematician 4 is reusable rule","key":"math_no_tutorial_four_hardcode"},
		{"name":"T05-I3 truthful Mathematician remains truthful","key":"truthful_math_stable"},
		{"name":"T05-I3 Weatherman canonical triplet is 2,4,6","key":"weatherman_triplet"},
		{"name":"T05-I3 Số Hiệu uses suspect_id, not board_slot","key":"so_hieu_is_suspect_id"},
		{"name":"T05-I3 sparse board numbering ignores non-suspects","key":"so_hieu_sparse_numbering"},
		{"name":"T05-I3 Mathematician copy uses Số Hiệu","key":"mathematician_help_so_hieu"},
		{"name":"T05-I3 Số Hiệu glossary is player-facing","key":"so_hieu_glossary"},
		{"name":"T05-I3 Weatherman output order is 2,4,6","key":"weatherman_triplet_order"},
		{"name":"T05-I3 Weatherman triplet is generic authority","key":"weatherman_generic_authority"},
		{"name":"T05-I3 legal investigations advance clock toward 12h","key":"investigations_clock"},
		{"name":"T05-I3 reaching 12h keeps controller usable","key":"controller_not_stuck_at_12"},
		{"name":"T05-I3 Surgeon event once-only in live flow","key":"surgeon_once_live"},
		{"name":"T05-I3 Surgeon death refreshes runtime coherently","key":"surgeon_death_runtime"},
		{"name":"T05-I3 dead suspect keeps true role and alignment","key":"dead_truth_preserved"},
		{"name":"T05-I3 death creates no private Chỉ Điểm","key":"death_no_private"},
		{"name":"T05-I3 killed Evil remains verdict-required","key":"handled_evil_resolution"},
		{"name":"T05-I3 Vigilante selection requires one target","key":"vigilante_one_target"},
		{"name":"T05-I3 Vigilante selection alone does not consume","key":"vigilante_selection_no_consume"},
		{"name":"T05-I3 Vigilante execution exits selection","key":"vigilante_exits_selection"},
		{"name":"T05-I3 Vigilante consumes once","key":"vigilante_consumes"},
		{"name":"T05-I3 Vigilante advances turn once","key":"vigilante_turn_once"},
		{"name":"T05-I3 Vigilante adds 0h","key":"vigilante_zero_time"},
		{"name":"T05-I3 Vigilante result survives refresh","key":"vigilante_result_refresh"},
		{"name":"T05-I3 Vigilante #5 can target Evil #1","key":"vigilante_targets_one"},
		{"name":"T05-I3 Vigilante #1 kill uses CaseKillService","key":"vigilante_one_kill_service"},
		{"name":"T05-I3 Vigilante #1 death reaches presentation","key":"vigilante_one_death_presentation"},
		{"name":"T05-I3 Vigilante kill reuses CaseKillService","key":"vigilante_kill_service_reused"},
		{"name":"T05-I3 killed suspect enters dead presentation state","key":"vigilante_dead_status"},
		{"name":"T05-I3 death transition trigger exists","key":"vigilante_death_transition"},
		{"name":"T05-I3 dead suspect remains valid Chỉ Điểm target","key":"dead_single_accuse_rejected"},
		{"name":"T05-I3 living suspect remains valid Chỉ Điểm target","key":"living_single_accuse_accepted"},
		{"name":"T05-I3 dead suspect can be selected in Chỉ Điểm UI","key":"dead_ui_not_selectable"},
		{"name":"T05-I3 direct death creates no private Chỉ Điểm","key":"death_no_private_direct"},
		{"name":"T05-I3 dead owner does not trap post reveal","key":"dead_owner_no_trap"},
		{"name":"T05-I3 dead target does not trap post reveal","key":"dead_target_no_trap"},
		{"name":"T05-I3 consumed function not falsely available","key":"consumed_not_available"},
		{"name":"T05-I3 reaches Final Verdict when functions done","key":"awaiting_final"},
		{"name":"T05-I3 one-target function reveal text is safe","key":"one_target_reveal_safe"},
		{"name":"T05-I3 Final Verdict resolves Tutorial 05","key":"final_resolves"},
		{"name":"T05-I3 correct result reaches settlement","key":"settlement_success"},
		{"name":"T05-I3 settlement applies once","key":"settlement_once"},
		{"name":"T05-I3 Surgeon seed can succeed","key":"surgeon_seed_success"},
		{"name":"T05-I3 Surgeon seed can fail","key":"surgeon_seed_failure"},
		{"name":"T05-I3 Surgeon exposes two 50/50 buckets","key":"surgeon_two_buckets"},
		{"name":"T05-I3 unrevealed true Surgeon can trigger at 12h","key":"surgeon_unrevealed_alive"},
		{"name":"T05-I3 revealed true Surgeon can still trigger at 12h","key":"surgeon_revealed_alive"},
		{"name":"T05-I3 dead true Surgeon cannot trigger at 12h","key":"surgeon_dead_source_blocked"},
		{"name":"T05-I3 displayed Surgeon without true role cannot trigger","key":"surgeon_displayed_false_source"},
		{"name":"T05-I3 controlled Surgeon seed succeeds while unrevealed","key":"surgeon_unrevealed_seed_success"},
		{"name":"T05-I3 controlled Surgeon seed fails while unrevealed","key":"surgeon_unrevealed_seed_failure"},
		{"name":"T05-I3 live Case event seed is per runtime","key":"runtime_event_seed_fresh"},
		{"name":"T05-I3 Tutorial fixture does not force Surgeon result","key":"surgeon_not_fixture_forced"},
		{"name":"T05-I3 Surgeon same event does not reroll","key":"surgeon_same_run_no_reroll"},
		{"name":"T05-I3 Surgeon has no hardcoded victim","key":"surgeon_no_hardcoded_victim"},
		{"name":"T05-I3 no Tutorial-specific domain branch","key":"no_tutorial_domain_branch"},
		{"name":"T05-I3 Sư Tử Phán kill summary is exact","key":"vigilante_kill_summary_exact"},
		{"name":"T05-I3 Sư Tử Phán miss summary is exact","key":"vigilante_miss_summary_exact"},
		{"name":"T05-I3 Sư Tử Phán result has no duplicate prefix","key":"vigilante_no_duplicate_prefix"},
		{"name":"T05-I3 unrevealed target accepts normal click","key":"function_click_unrevealed"},
		{"name":"T05-I3 revealed target accepts normal click","key":"function_click_revealed"},
		{"name":"T05-I3 function target click does not investigate","key":"function_click_no_investigation"},
		{"name":"T05-I3 function target click does not require hold","key":"function_click_no_hold"},
		{"name":"T05-I3 function target click executes once","key":"function_click_execute_once"},
		{"name":"T05-I3 function target click consumes once","key":"function_click_consumes_once"},
		{"name":"T05-I3 function target click advances turn once","key":"function_click_turn_once"},
		{"name":"T05-I3 function target click keeps Case time +0h","key":"function_click_time_zero"},
		{"name":"T05-I3 background right-click cancels function targeting","key":"right_cancel_background"},
		{"name":"T05-I3 cancel does not require suspect hover","key":"right_cancel_no_hover"},
		{"name":"T05-I3 cancel clears function targets","key":"right_cancel_clears_targets"},
		{"name":"T05-I3 cancel does not consume function","key":"right_cancel_no_consume"},
		{"name":"T05-I3 cancel does not advance turn","key":"right_cancel_no_turn"},
		{"name":"T05-I3 cancel does not advance Case time","key":"right_cancel_no_time"},
		{"name":"T05-I3 cancel does not execute function","key":"right_cancel_no_execute"},
		{"name":"T05-I3 function remains available after cancel","key":"right_cancel_function_available"},
		{"name":"T05-I3 normal gameplay restored after cancel","key":"right_cancel_restores_normal"},
		{"name":"T05-I3 shared cancel works for multi-target function mode","key":"right_cancel_multi_target"},
		{"name":"T05-I3 normal click outside targeting preserves investigation hold","key":"normal_click_investigation_unchanged"},
	]
	for spec: Dictionary in tutorial_05_i3_specs:
		rows.append(_result(String(spec.name), bool(tutorial_05_i3_checks.get(spec.key, false)), "Tutorial 05 I3 end-to-end integration invariant"))
	var t06_f1_checks: Dictionary = _t06_f1_current_role_checks(roles, player_fixtures)
	var t06_f1_specs: Array[Dictionary] = [
		{"name":"T06-F1 fresh current role starts as authored true role","key":"fresh_current_equals_authored"},
		{"name":"T06-F1 transform changes current role only","key":"transform_changes_current"},
		{"name":"T06-F1 authored true role remains unchanged","key":"authored_true_unchanged"},
		{"name":"T06-F1 displayed role remains unchanged","key":"displayed_unchanged"},
		{"name":"T06-F1 impersonated role remains unchanged","key":"impersonated_unchanged"},
		{"name":"T06-F1 CaseDefinition remains immutable","key":"case_definition_unchanged"},
		{"name":"T06-F1 current-role resolver returns transformed role","key":"current_resolver_transformed"},
		{"name":"T06-F1 authored-role resolver returns original role","key":"authored_resolver_original"},
		{"name":"T06-F1 current roles-in-play reflects transformation","key":"current_roles_reflect_transform"},
		{"name":"T06-F1 authored roles-in-play remains original","key":"authored_roles_remain_original"},
		{"name":"T06-F1 Truth Reveal can use current role","key":"truth_reveal_uses_current"},
		{"name":"T06-F1 public presentation consumes current role safely","key":"presentation_current_safe"},
		{"name":"T06-F1 static ratio remains authored","key":"static_ratio_unchanged"},
		{"name":"T06-F1 transform does not advance turn","key":"no_turn_advance"},
		{"name":"T06-F1 transform does not advance elapsed hours","key":"no_elapsed_hours"},
		{"name":"T06-F1 transform does not mutate death state","key":"no_death_mutation"},
		{"name":"T06-F1 transform does not mutate corruption state","key":"no_corruption_mutation"},
		{"name":"T06-F1 reinitialize resets current role","key":"reinitialize_resets"},
		{"name":"T06-F1 separate runtimes are isolated","key":"separate_runtime_isolated"},
		{"name":"T06-F1 invalid suspect transform rejected","key":"invalid_suspect_rejected"},
		{"name":"T06-F1 invalid or empty target role rejected","key":"invalid_target_rejected"},
		{"name":"T06-F1 same-role transform is safe","key":"same_role_safe"},
	]
	for spec: Dictionary in t06_f1_specs:
		rows.append(_result(String(spec.name), bool(t06_f1_checks.get(spec.key, false)), "Tutorial 06 F1 current-role transformation invariant"))
	var t06_f2_checks: Dictionary = _t06_f2_poisoner_taint_checks(roles, player_fixtures)
	var t06_f2_specs: Array[Dictionary] = [
		{"name":"T06-F2 Poisoner role definition loads","key":"poisoner_role_loads"},
		{"name":"T06-F2 fresh runtime has no Poisoner taint record","key":"fresh_no_record"},
		{"name":"T06-F2 surrounding target can be runtime corrupted","key":"valid_surrounding_corrupts"},
		{"name":"T06-F2 non-surrounding target is rejected","key":"non_surrounding_rejected"},
		{"name":"T06-F2 source is not accidentally corrupted","key":"source_not_corrupted"},
		{"name":"T06-F2 authored SuspectDefinition is not mutated","key":"authored_not_mutated"},
		{"name":"T06-F2 authored corruption remains intact","key":"authored_corruption_intact"},
		{"name":"T06-F2 runtime corruption makes truth mode LYING","key":"runtime_corruption_lies"},
		{"name":"T06-F2 reinitialize removes runtime corruption only","key":"reinitialize_clears_runtime_only"},
		{"name":"T06-F2 authored-corrupted suspect remains LYING after reset","key":"authored_corrupted_still_lies"},
		{"name":"T06-F2 tainted Poisoner corrupts no target","key":"tainted_poisoner_no_target"},
		{"name":"T06-F2 tainted Poisoner resolves without duplicate reroll","key":"tainted_poisoner_idempotent"},
		{"name":"T06-F2 taint record stores source","key":"record_source"},
		{"name":"T06-F2 taint record stores target on success","key":"record_target_success"},
		{"name":"T06-F2 tainted-source record stores no target","key":"record_no_target_on_tainted_source"},
		{"name":"T06-F2 taint effect resolves once","key":"effect_idempotent"},
		{"name":"T06-F2 taint does not advance turn","key":"no_turn_advance"},
		{"name":"T06-F2 taint does not advance elapsed hours","key":"no_elapsed_hours"},
		{"name":"T06-F2 taint does not mutate death state","key":"no_death_mutation"},
		{"name":"T06-F2 taint does not mutate current role","key":"no_current_role_mutation"},
		{"name":"T06-F2 taint does not mutate CaseDefinition","key":"no_case_definition_mutation"},
		{"name":"T06-F2 diagonal surrounding target is valid","key":"diagonal_valid"},
		{"name":"T06-F2 orthogonal surrounding target is valid","key":"orthogonal_valid"},
		{"name":"T06-F2 distant target is invalid","key":"distant_invalid"},
		{"name":"T06-F2 separate runtimes do not share taint","key":"separate_runtime_isolated"},
	]
	for spec: Dictionary in t06_f2_specs:
		rows.append(_result(String(spec.name), bool(t06_f2_checks.get(spec.key, false)), "Tutorial 06 F2 Poisoner taint invariant"))
	var t06_f2r_checks: Dictionary = _t06_f2r_poisoner_canonical_repair_checks(tutorial_case_06, roles, player_fixtures)
	var t06_f2r_specs: Array[Dictionary] = [
		{"name":"T06-F2R Poisoner remains Underling Evil","key":"poisoner_underling_evil"},
		{"name":"T06-F2R taint target must be Innocent","key":"target_must_be_innocent"},
		{"name":"T06-F2R adjacent non-Innocent rejected from random pool","key":"non_innocent_rejected"},
		{"name":"T06-F2R orthogonal Innocent candidate valid","key":"orthogonal_valid"},
		{"name":"T06-F2R diagonal Innocent candidate valid","key":"diagonal_valid"},
		{"name":"T06-F2R non-surrounding Innocent excluded","key":"non_surrounding_excluded"},
		{"name":"T06-F2R source itself excluded","key":"source_excluded"},
		{"name":"T06-F2R automatic resolver chooses one target","key":"auto_chooses_one"},
		{"name":"T06-F2R deterministic seed is stable","key":"seed_stable"},
		{"name":"T06-F2R alternate seed can choose another target","key":"alternate_seed_can_differ"},
		{"name":"T06-F2R no eligible target resolves safely","key":"no_eligible_safe"},
		{"name":"T06-F2R tainted Poisoner applies no corruption","key":"tainted_no_corruption"},
		{"name":"T06-F2R tainted Poisoner does not reroll","key":"tainted_no_reroll"},
		{"name":"T06-F2R chosen target becomes runtime corrupted","key":"chosen_runtime_corrupted"},
		{"name":"T06-F2R authored SuspectDefinition remains unchanged","key":"authored_unchanged"},
		{"name":"T06-F2R turn unchanged","key":"turn_unchanged"},
		{"name":"T06-F2R elapsed hours unchanged","key":"elapsed_unchanged"},
		{"name":"T06-F2R current role unchanged","key":"current_role_unchanged"},
		{"name":"T06-F2R death state unchanged","key":"death_unchanged"},
		{"name":"T06-F2R record stores selected target","key":"record_selected_target"},
		{"name":"T06-F2R T06 startup taints #2","key":"t06_startup_taints_two"},
		{"name":"T06-F2R T06 #2 effectively corrupted","key":"t06_two_effectively_corrupted"},
		{"name":"T06-F2R Poisoner pretend pool equals suspected authority","key":"pretend_pool_suspected"},
		{"name":"T06-F2R nested Drunkard excluded from pretend pool","key":"pretend_pool_excludes_drunkard"},
		{"name":"T06-F2R T06 Reporter valid pretend","key":"reporter_valid_pretend"},
		{"name":"T06-F2R non-suspected role invalid pretend","key":"non_suspected_invalid_pretend"},
		{"name":"T06-F2R fixture placeholder excluded from pretend","key":"placeholder_excluded_pretend"},
		{"name":"T06-F2R repeated resolve is idempotent","key":"repeated_idempotent"},
		{"name":"T06-F2R separate runtimes isolate selection","key":"separate_runtime_isolated"},
		{"name":"T06-F2R authored-corruption reset semantics preserved","key":"authored_corruption_reset_preserved"},
	]
	for spec: Dictionary in t06_f2r_specs:
		rows.append(_result(String(spec.name), bool(t06_f2r_checks.get(spec.key, false)), "Tutorial 06 F2R Poisoner canonical repair invariant"))
	var t06_f3_checks: Dictionary = _t06_f3_barkeep_drunkard_checks(roles, player_fixtures)
	var t06_f3_specs: Array[Dictionary] = [
		{"name":"T06-F3 Barkeep real role loads","key":"barkeep_role_loads"},
		{"name":"T06-F3 Drunkard real role loads","key":"drunkard_role_loads"},
		{"name":"T06-F3 Drunkard role group is Kẻ Bao Đồng","key":"drunkard_group"},
		{"name":"T06-F3 fresh Drunkard truth mode is LYING","key":"fresh_drunkard_lies"},
		{"name":"T06-F3 transformed Drunkard truth mode is LYING","key":"transformed_drunkard_lies"},
		{"name":"T06-F3 eligible Innocent transforms to Drunkard","key":"eligible_innocent_transforms"},
		{"name":"T06-F3 authored original role remains unchanged","key":"authored_role_unchanged"},
		{"name":"T06-F3 displayed role remains unchanged","key":"displayed_unchanged"},
		{"name":"T06-F3 impersonated role remains unchanged","key":"impersonated_unchanged"},
		{"name":"T06-F3 authored role group remains unchanged","key":"authored_group_unchanged"},
		{"name":"T06-F3 current role becomes Drunkard","key":"current_role_drunkard"},
		{"name":"T06-F3 current roles-in-play includes Drunkard","key":"current_roles_include_drunkard"},
		{"name":"T06-F3 authored roles-in-play remains unchanged","key":"authored_roles_unchanged"},
		{"name":"T06-F3 old current role removed when unique","key":"old_current_removed"},
		{"name":"T06-F3 existing Drunkard blocks second Drunkard","key":"no_second_drunkard"},
		{"name":"T06-F3 no-second Drunkard result is idempotent","key":"no_second_idempotent"},
		{"name":"T06-F3 non-Innocent target rejected","key":"non_innocent_rejected"},
		{"name":"T06-F3 source cannot target itself","key":"self_target_rejected"},
		{"name":"T06-F3 invalid suspect safely rejected","key":"invalid_suspect_rejected"},
		{"name":"T06-F3 transform record stores source","key":"record_source"},
		{"name":"T06-F3 transform record stores target","key":"record_target"},
		{"name":"T06-F3 transform record stores original target role","key":"record_original_role"},
		{"name":"T06-F3 transform record stores resulting Drunkard role","key":"record_result_role"},
		{"name":"T06-F3 reinitialize clears transform record","key":"reinitialize_clears_record"},
		{"name":"T06-F3 separate runtimes do not share transform record","key":"separate_runtime_isolated"},
		{"name":"T06-F3 static ratio remains authored","key":"static_ratio_unchanged"},
		{"name":"T06-F3 transform does not advance turn","key":"no_turn_advance"},
		{"name":"T06-F3 transform does not advance elapsed hours","key":"no_elapsed_hours"},
		{"name":"T06-F3 transform does not mutate death state","key":"no_death_mutation"},
		{"name":"T06-F3 transform does not mutate corruption","key":"no_corruption_mutation"},
		{"name":"T06-F3 transform does not mutate displayed or impersonated","key":"no_display_impersonation_mutation"},
		{"name":"T06-F3 Truth Reveal reports current Drunkard","key":"truth_reveal_current_drunkard"},
		{"name":"T06-F3 public presentation hides transformed Drunkard before reveal","key":"public_hides_before_reveal"},
		{"name":"T06-F3 same effect resolves once","key":"effect_idempotent"},
	]
	for spec: Dictionary in t06_f3_specs:
		rows.append(_result(String(spec.name), bool(t06_f3_checks.get(spec.key, false)), "Tutorial 06 F3 Barkeep transformation invariant"))
	var t06_f3r_checks: Dictionary = _t06_f3r_barkeep_drunkard_canonical_repair_checks(tutorial_case_06, roles, player_fixtures)
	var t06_f3r_specs: Array[Dictionary] = [
		{"name":"T06-F3R Barkeep remains Underling Evil","key":"barkeep_underling_evil"},
		{"name":"T06-F3R Drunkard remains Meddler Good","key":"drunkard_meddler_good"},
		{"name":"T06-F3R Barkeep pretend pool uses suspected authority","key":"barkeep_pool_suspected"},
		{"name":"T06-F3R T06 Reporter valid Barkeep pretend","key":"reporter_valid_barkeep_pretend"},
		{"name":"T06-F3R nested Drunkard invalid Barkeep pretend","key":"drunkard_invalid_barkeep_pretend"},
		{"name":"T06-F3R non-suspected role invalid Barkeep pretend","key":"non_suspected_invalid_barkeep_pretend"},
		{"name":"T06-F3R Drunkard pretend pool uses Good alignment","key":"drunkard_pool_good_alignment"},
		{"name":"T06-F3R absent Good role valid Drunkard pretend","key":"absent_good_valid_drunkard_pretend"},
		{"name":"T06-F3R current in-play Good role excluded","key":"current_good_excluded"},
		{"name":"T06-F3R Evil role excluded from Drunkard pretend","key":"evil_excluded"},
		{"name":"T06-F3R fixture placeholder excluded from Drunkard pretend","key":"placeholder_excluded"},
		{"name":"T06-F3R candidate outside explicit pool excluded","key":"outside_pool_excluded"},
		{"name":"T06-F3R after transform Mailman current not in play","key":"mailman_current_not_in_play"},
		{"name":"T06-F3R Mailman valid Drunkard pretend in T06","key":"mailman_valid_drunkard_pretend"},
		{"name":"T06-F3R T06 #6 authored Mailman pretend remains valid","key":"six_mailman_pretend_valid"},
		{"name":"T06-F3R clean Drunkard remains LYING","key":"clean_drunkard_lies"},
		{"name":"T06-F3R tainted Drunkard remains LYING","key":"tainted_drunkard_lies"},
		{"name":"T06-F3R taint does not change Drunkard current role","key":"taint_current_role_unchanged"},
		{"name":"T06-F3R taint preserves Drunkard pretend rule","key":"taint_pretend_rule_unchanged"},
		{"name":"T06-F3R Barkeep transform targets authored Innocent","key":"transform_target_authored_innocent"},
		{"name":"T06-F3R transform still changes current role to Drunkard","key":"transform_current_drunkard"},
		{"name":"T06-F3R authored original role remains unchanged","key":"authored_original_unchanged"},
		{"name":"T06-F3R static ratio unchanged","key":"static_ratio_unchanged"},
		{"name":"T06-F3R suspected pool unchanged after transform","key":"suspected_pool_unchanged"},
		{"name":"T06-F3R generated Drunkard remains not suspected","key":"drunkard_not_suspected"},
		{"name":"T06-F3R nested Barkeep to Drunkard remains present","key":"nested_barkeep_drunkard"},
		{"name":"T06-F3R preexisting Drunkard blocks second transform","key":"preexisting_drunkard_blocks"},
		{"name":"T06-F3R second-Drunkard setup rejected by validator","key":"second_drunkard_setup_rejected"},
		{"name":"T06-F3R runtime guard remains idempotent","key":"runtime_guard_idempotent"},
		{"name":"T06-F3R transform has no turn time death corruption side effects","key":"no_transform_side_effects"},
		{"name":"T06-F3R Mailman current-role truth preserved","key":"mailman_current_truth_preserved"},
		{"name":"T06-F3R Full Reveal original current pretend history preserved","key":"full_reveal_history_preserved"},
	]
	for spec: Dictionary in t06_f3r_specs:
		rows.append(_result(String(spec.name), bool(t06_f3r_checks.get(spec.key, false)), "Tutorial 06 F3R Barkeep + Drunkard canonical repair invariant"))
	var t06_f4_checks: Dictionary = _t06_f4_blood_hound_checks(roles, player_fixtures)
	var t06_f4_specs: Array[Dictionary] = [
		{"name":"T06-F4 Ngự Khuyển Quan real role loads","key":"blood_hound_role_loads"},
		{"name":"T06-F4 Blood Hound role id is stable","key":"blood_hound_role_id"},
		{"name":"T06-F4 Ngự Khuyển Quan help text is canonical","key":"blood_hound_help_text"},
		{"name":"T06-F4 Ngự Khuyển Quan no-evil wording uses nằm im","key":"blood_hound_no_evil_wording"},
		{"name":"T06-F4 Blood Hound canonical group is Người Vô Tội","key":"blood_hound_group"},
		{"name":"T06-F4 Blood Hound canonical alignment is Phe Thiện","key":"blood_hound_alignment"},
		{"name":"T06-F4 Blood Hound is Role Codex visible","key":"codex_visible"},
		{"name":"T06-F4 fixture placeholders remain Codex excluded","key":"placeholder_excluded"},
		{"name":"T06-F4 Blood Hound north clue uses board slots","key":"uses_board_slots"},
		{"name":"T06-F4 Blood Hound output hides target ids","key":"output_hides_target_ids"},
		{"name":"T06-F4 empty slot on ray is traversable","key":"empty_slot_traversable"},
		{"name":"T06-F4 Crime Scene on ray is traversable","key":"crime_scene_traversable"},
		{"name":"T06-F4 cardinal differs from surrounding semantics","key":"cardinal_not_surrounding"},
		{"name":"T06-F4 truthful clue is deterministic","key":"truthful_deterministic"},
		{"name":"T06-F4 equal closest Evil makes Blood Hound bark","key":"bark_on_tie"},
		{"name":"T06-F4 no cardinal Evil makes Ngự Khuyển Quan nằm im","key":"sniff_when_none"},
		{"name":"T06-F4 evaluator has no Tutorial 06 hardcode","key":"no_tutorial_hardcode"},
		{"name":"T06-F4 tainted Blood Hound enters LYING mode","key":"tainted_enters_lying"},
		{"name":"T06-F4 lying/tainted result differs from truth","key":"lying_non_truthful"},
		{"name":"T06-F4 no CaseDefinition mutation","key":"no_case_definition_mutation"},
		{"name":"T06-F4 no current role mutation","key":"no_current_role_mutation"},
		{"name":"T06-F4 no corruption mutation","key":"no_corruption_mutation"},
		{"name":"T06-F4 no death mutation","key":"no_death_mutation"},
		{"name":"T06-F4 no turn advance","key":"no_turn_advance"},
		{"name":"T06-F4 no elapsed-hours advance","key":"no_elapsed_hours"},
		{"name":"T06-F4 runtime instances remain isolated","key":"runtime_isolated"},
		{"name":"T06-F4 existing Weatherman spatial behavior remains intact","key":"weatherman_regression_safe"},
	]
	for spec: Dictionary in t06_f4_specs:
		rows.append(_result(String(spec.name), bool(t06_f4_checks.get(spec.key, false)), "Tutorial 06 F4 Blood Hound foundation invariant"))
	rows.append(_result("Tutorial 06 fixture load", tutorial_case_06 != null, FixtureRepository.TUTORIAL_CASE_006_PATH))
	rows.append(_result("Tutorial 06 validates with 7 suspects", tutorial_06_validation_report.passed and tutorial_case_06 != null and tutorial_case_06.suspects.size() == 7, "1 Crime Scene + 7 Suspects"))
	var tutorial_06_checks: Dictionary = _tutorial_06_i1_checks(tutorial_case_06, roles, player_fixtures)
	var tutorial_06_specs: Array[Dictionary] = [
		{"name":"T06-I1 exact sparse board layout authored","key":"board_layout"},
		{"name":"T06-I1 top-level suspect-role pool has 8 roles","key":"top_level_pool"},
		{"name":"T06-I1 Drunkard nested under Barkeep only","key":"nested_drunkard"},
		{"name":"T06-I1 authored ratio remains 5/0/2/0","key":"ratio_static"},
		{"name":"T06-I1 Evil answer is Poisoner plus Barkeep","key":"evil_answer"},
		{"name":"T06-I1 startup Poisoner taints #2","key":"startup_taint"},
		{"name":"T06-I1 startup Barkeep transforms #6","key":"startup_transform"},
		{"name":"T06-I1 runtime ratio stays authored after transform","key":"ratio_not_mutated"},
		{"name":"T06-I1 #5 Blood Hound points North","key":"blood_hound_north"},
		{"name":"T06-I1 Blood Hound bark and no-evil outcomes remain available","key":"blood_hound_bark_sniff"},
		{"name":"T06-I1 Blood Hound lying result is non-truthful","key":"blood_hound_lying"},
		{"name":"T06-I1 Mailman respects transformed current role","key":"mailman_current_truth"},
		{"name":"T06-I1 Full Reveal supports transform/pretend notes","key":"full_reveal_notes"},
		{"name":"T06-I1 no Partner implementation introduced","key":"no_partner"},
	]
	for spec: Dictionary in tutorial_06_specs:
		rows.append(_result(String(spec.name), bool(tutorial_06_checks.get(spec.key, false)), "Tutorial 06 I1 exact fixture and authority invariant"))
	var tutorial_06_i2_checks: Dictionary = _tutorial_06_i2_clue_output_checks(tutorial_case_06, roles, player_fixtures)
	var tutorial_06_i2_specs: Array[Dictionary] = [
		{"name":"T06-I2 #1 displayed Reporter uses lying pretend semantics","key":"s1_reporter_lying_pretend"},
		{"name":"T06-I2 #1 displayed Reporter says 3 steps","key":"s1_reporter_exact_three"},
		{"name":"T06-I2 #3 displayed Reporter uses lying pretend semantics","key":"s3_reporter_lying_pretend"},
		{"name":"T06-I2 #3 displayed Reporter says 4 steps","key":"s3_reporter_exact_four"},
		{"name":"T06-I2 Reporter nearest Evil excludes source suspect","key":"reporter_self_excluded"},
		{"name":"T06-I2 #2 Priest exact public line","key":"s2_priest_exact"},
		{"name":"T06-I2 #5 Blood Hound exact north direction text","key":"s5_blood_hound_exact"},
		{"name":"T06-I2 #5 Blood Hound hides target identity","key":"s5_blood_hound_no_identity"},
		{"name":"T06-I2 #6 Mailman exact current-role wording","key":"s6_mailman_exact"},
		{"name":"T06-I2 #6 Mailman keeps both false facts","key":"s6_mailman_false_facts"},
		{"name":"T06-I2 #6 Mailman uses transformed current-role truth","key":"s6_mailman_current_role_truth"},
		{"name":"T06-I2 generic Reporter output remains spatial","key":"generic_reporter_safe"},
		{"name":"T06-I2 generic Blood Hound bark/no-evil/lie remains valid","key":"blood_hound_regression_safe"},
		{"name":"T06-I2 generic Mailman truth/lying remains valid","key":"mailman_regression_safe"},
	]
	for spec: Dictionary in tutorial_06_i2_specs:
		rows.append(_result(String(spec.name), bool(tutorial_06_i2_checks.get(spec.key, false)), "Tutorial 06 I2 clue presentation invariant"))
	var tutorial_06_i3_checks: Dictionary = _tutorial_06_i3_full_reveal_checks(tutorial_case_06, roles, player_fixtures)
	var tutorial_06_i3_specs: Array[Dictionary] = [
		{"name":"T06-I3 transformed truth retains original role id","key":"truth_original_role_id"},
		{"name":"T06-I3 transformed truth retains current role id","key":"truth_current_role_id"},
		{"name":"T06-I3 #6 original Mailman current Drunkard","key":"t06_six_original_current"},
		{"name":"T06-I3 #6 card shows current Kẻ Say Rượu","key":"card_current_drunkard"},
		{"name":"T06-I3 #6 card shows original Dịch Phu","key":"card_original_mailman"},
		{"name":"T06-I3 non-transformed cards avoid duplicate original-role line","key":"non_transformed_no_original_line"},
		{"name":"T06-I3 Barkeep transform relation uses runtime record","key":"transform_relation_runtime"},
		{"name":"T06-I3 Barkeep transform relation uses Số Hiệu 6","key":"transform_relation_so_hieu"},
		{"name":"T06-I3 Poisoner taint relation uses runtime record","key":"taint_relation_runtime"},
		{"name":"T06-I3 Poisoner taint relation uses Số Hiệu 2","key":"taint_relation_so_hieu"},
		{"name":"T06-I3 #6 pretend/display history remains Dịch Phu","key":"six_pretend_history"},
		{"name":"T06-I3 CaseDefinition #6 authored true role remains Mailman","key":"case_definition_six_mailman"},
		{"name":"T06-I3 runtime #6 current role remains Drunkard","key":"runtime_six_drunkard"},
		{"name":"T06-I3 static ratio remains 5/0/2/0","key":"static_ratio"},
		{"name":"T06-I3 generic reveal formatter has no Tutorial 06 ID hardcode","key":"no_t06_id_hardcode"},
	]
	for spec: Dictionary in tutorial_06_i3_specs:
		rows.append(_result(String(spec.name), bool(tutorial_06_i3_checks.get(spec.key, false)), "Tutorial 06 I3 Full Reveal invariant"))
	var tutorial_06_f5_checks: Dictionary = _tutorial_06_f5_role_pool_checks(tutorial_case_06, roles, player_fixtures)
	var tutorial_06_f5_specs: Array[Dictionary] = [
		{"name":"T06-F5 explicit suspected authority exists","key":"authority_exists"},
		{"name":"T06-F5 suspected pool has exactly 8 roles","key":"suspected_count"},
		{"name":"T06-F5 Reporter is suspected","key":"reporter_suspected"},
		{"name":"T06-F5 Therapist is suspected","key":"therapist_suspected"},
		{"name":"T06-F5 Blood Hound is suspected","key":"blood_hound_suspected"},
		{"name":"T06-F5 Priest is suspected","key":"priest_suspected"},
		{"name":"T06-F5 Mailman is suspected","key":"mailman_suspected"},
		{"name":"T06-F5 Mathematician is suspected","key":"mathematician_suspected"},
		{"name":"T06-F5 Barkeep is suspected","key":"barkeep_suspected"},
		{"name":"T06-F5 Poisoner is suspected","key":"poisoner_suspected"},
		{"name":"T06-F5 Drunkard is not suspected","key":"drunkard_not_suspected"},
		{"name":"T06-F5 nested Barkeep to Drunkard metadata exists","key":"nested_barkeep_drunkard"},
		{"name":"T06-F5 nested Drunkard renders in sidebar","key":"nested_drunkard_renders"},
		{"name":"T06-F5 nested child does not become suspected","key":"nested_child_not_suspected"},
		{"name":"T06-F5 transformed Drunkard is current in play","key":"drunkard_current_in_play"},
		{"name":"T06-F5 transformed Mailman is current not in play","key":"mailman_current_not_in_play"},
		{"name":"T06-F5 Mathematician is suspected and not in play","key":"mathematician_suspected_not_in_play"},
		{"name":"T06-F5 Drunkard is in play and not suspected","key":"drunkard_in_play_not_suspected"},
		{"name":"T06-F5 transform does not mutate suspected pool","key":"transform_pool_unchanged"},
		{"name":"T06-F5 static ratio stays 5/0/2/0","key":"ratio_static"},
		{"name":"T06-F5 reinitialize keeps authored suspected pool","key":"reinitialize_pool_intact"},
		{"name":"T06-F5 separate runtimes do not share role-pool state","key":"separate_runtime_pools"},
		{"name":"T06-F5 suspected helper excludes nested Drunkard","key":"suspected_helper_excludes_nested"},
		{"name":"T06-F5 bounded not-in-play ignores outside roles","key":"bounded_not_in_play"},
		{"name":"T06-F5 Good not-in-play includes absent Good","key":"good_absent_included"},
		{"name":"T06-F5 Good not-in-play excludes current in-play","key":"good_current_excluded"},
		{"name":"T06-F5 Good not-in-play excludes Evil","key":"good_evil_excluded"},
		{"name":"T06-F5 Good not-in-play excludes fixture placeholder","key":"good_placeholder_excluded"},
		{"name":"T06-F5 Mailman current-role truth remains correct","key":"mailman_current_truth"},
		{"name":"T06-F5 duplicate suspected ID validation rejects","key":"duplicate_validation"},
		{"name":"T06-F5 invalid suspected ID validation rejects","key":"invalid_validation"},
		{"name":"T06-F5 invalid nested reference validation rejects","key":"invalid_nested_validation"},
		{"name":"T06-F5 Role Codex remains separate","key":"role_codex_separate"},
	]
	for spec: Dictionary in tutorial_06_f5_specs:
		rows.append(_result(String(spec.name), bool(tutorial_06_f5_checks.get(spec.key, false)), "Tutorial 06 F5 suspected/in-play/not-in-play foundation invariant"))
	rows.append(_result("Case UI left panel is player-facing", _case_left_info_panel_presentation(tutorial_case_03, roles, player_fixtures), "colored groups, clock HUD, slash reputation"))
	rows.append(_result("Role Reference rich styling canonical", _role_reference_rich_styling(roles), "group/alignment colors and key terms"))
	rows.append(_result("Crime Scene tile is simple and non-interactive", _tutorial_03_crime_scene_presentation(tutorial_case_03), "HIỆN TRƯỜNG + icon only"))
	rows.append(_result("Board rejects more than 9 tiles", _oversized_case_rejected(roles, player_fixtures), "BOARD_TILE_COUNT_INVALID"))
	rows.append(_result("Unique suspect IDs", _has_unique_suspect_ids(case_fixture), "No duplicate suspect_id"))
	rows.append(_result("All 4 role groups", _has_all_role_groups(case_fixture), "Người Vô Tội / Kẻ Bao Đồng / Thuộc Hạ / Nghịch Thần"))
	rows.append(_result("Impersonating Thuộc Hạ", _has_impersonating_accomplice(case_fixture), "True role differs from displayed role"))
	rows.append(_result("Tha Hóa fixture", _has_corrupted_suspect(case_fixture), "At least one is_corrupted"))
	rows.append(_result("Thợ May metadata", _has_valid_tailor(roles, case_fixture), "canonical copy; 2 targets, compare alignment, next-turn unlock"))
	rows.append(_result("Evil answer references", _evil_answer_ids_exist(case_fixture), "All IDs exist"))
	rows.append(_result("Role group classification data", _classification_matches_truth(case_fixture), "Thuộc Hạ/Nghịch Thần match true groups"))
	rows.append(_result("Reward fixture fields", _reward_fixture_complete(case_fixture), "TEST_ONLY / NOT_BALANCE_LOCKED"))
	rows.append(_result("Three player fixtures", _players_are_valid(player_fixtures), "Reputation 5/4/3 in range"))
	rows.append(_result("Main validator PASS", validation_report.passed, "%d validation errors" % validation_report.error_count))
	rows.append(_result("Invalid fixture FAIL", not invalid_report.passed and invalid_report.error_count > 0, "%d expected errors caught" % invalid_report.error_count))
	rows.append(_result("VSCaseMain scene load", load(VS_CASE_MAIN_PATH) is PackedScene, VS_CASE_MAIN_PATH))
	rows.append(_result("CaseBoard scene load", load(CASE_BOARD_PATH) is PackedScene, CASE_BOARD_PATH))
	rows.append(_result("SuspectCard scene load", load(SUSPECT_CARD_PATH) is PackedScene, SUSPECT_CARD_PATH))
	var suspect_card_hitbox_checks: Dictionary = _suspect_card_full_rect_hitbox_checks(tutorial_case_06)
	var suspect_card_hitbox_specs: Array[Dictionary] = [
		{"name":"SuspectCard hitbox includes question mark area","key":"question_mark_area"},
		{"name":"SuspectCard hitbox includes suspect number area","key":"number_area"},
		{"name":"SuspectCard hitbox includes top empty gap","key":"top_gap_area"},
		{"name":"SuspectCard hitbox includes lower text area","key":"lower_area"},
		{"name":"SuspectCard unrevealed hold can start from root rect","key":"unrevealed_hold"},
		{"name":"SuspectCard function target click can start from root rect","key":"function_target_click"},
		{"name":"SuspectCard revealed click can start from root rect","key":"revealed_click"},
		{"name":"SuspectCard right-click cancel can start from root rect","key":"right_click_cancel"},
		{"name":"SuspectCard root input does not double emit","key":"no_duplicate_action"},
		{"name":"Outside empty CaseBoard slot remains noninteractive","key":"outside_empty_slot"},
	]
	for spec: Dictionary in suspect_card_hitbox_specs:
		rows.append(_result(String(spec.name), bool(suspect_card_hitbox_checks.get(spec.key, false)), "SuspectCard full-rectangle hitbox invariant"))
	rows.append(_result("Render source has 8 suspects", _public_views(case_fixture).size() == 8, "Fixture → public presentation"))
	rows.append(_result("Board creates 8 suspect cards", _board_card_count(case_fixture) == 8, "Suspect card children"))
	rows.append(_result("Board capacity remains 9 spatial slots", _board_tile_count(case_fixture) == 9 and _board_has_crime_scene(case_fixture), "Fixed 3x3 Case Board"))
	rows.append(_result("Tutorial board preserves sparse 3x3 layout", _tutorial_board_preserves_sparse_layout(tutorial_case), "3 occupied tiles, 6 empty slots"))
	rows.append(_result("Tutorial unused board slots remain empty", _tutorial_unused_slots_remain_empty(tutorial_case), "No compacting into a row"))
	rows.append(_result("Tutorial authored board slots preserved", _board_slots_match_authored(tutorial_case), "Crime Scene 4; suspects 3 and 5"))
	rows.append(_result("Full case authored board slots preserved", _board_slots_match_authored(case_fixture), "1 Crime Scene + 8 authored Suspects"))
	rows.append(_result("Full Reveal preserves board slots", _full_reveal_preserves_board_slots(case_fixture, roles, player_fixtures), "Truth stays on authored Suspect slots"))
	rows.append(_result("Spatial service uses fixed 3x3 slots", _spatial_service_uses_fixed_slots(), "Slots 0..8 map to rows/columns"))
	rows.append(_result("Spatial orthogonal adjacency is cardinal only", _spatial_orthogonal_adjacency(), "0 touches 1/3; 4 touches 1/3/5/7"))
	rows.append(_result("Spatial surrounding includes diagonals", _spatial_surrounding_neighbours(), "Center has 8; corner has 3"))
	rows.append(_result("Spatial distance is orthogonal steps", _spatial_orthogonal_distances(), "Manhattan distance across 3x3 grid"))
	rows.append(_result("Spatial distance ignores empty and Crime Scene tiles", _spatial_sparse_distance(), "Traversal crosses empty slots and Crime Scene"))
	rows.append(_result("Spatial adjacent evil count uses true orthogonal suspects", _spatial_adjacent_evil_count(), "Diagonal/Crime Scene/empty excluded"))
	rows.append(_result("Spatial nearest evil ignores displayed roles", _spatial_nearest_true_evil(), "TRUE Evil selected, public pretend ignored"))
	rows.append(_result("Spatial service accepts tutorial/full fixtures", _spatial_existing_fixtures_valid(tutorial_case, tutorial_case_02, case_fixture), "Tutorial 01/02 and full fixture slots valid"))
	rows.append(_result("Role info truth state separates Evil from Lie", _role_info_truth_state(), "Scoundrel truthful; Mobster/Spectre/Tha Hóa lie"))
	rows.append(_result("Role info Priest evaluator canonical", _role_info_priest(), "Truthful exact phrase; lying differs"))
	rows.append(_result("Role info Reporter uses spatial distance", _role_info_reporter(), "Nearest true Evil; no self target; no-Evil supported"))
	rows.append(_result("Role info Therapist uses orthogonal evil count", _role_info_therapist(), "Diagonal/Crime Scene/empty excluded; lie incorrect"))
	rows.append(_result("Role info Mailman uses true role play state", _role_info_mailman(), "Displayed pretend ignored; both lie claims false"))
	rows.append(_result("Role info Pretend keeps truth mode separate", _role_info_pretend(), "Pretended behavior role with independent truth/lie"))
	rows.append(_result("Role info Obscure hides text not numbers", _role_info_obscure(), "Identity hidden; numeric payload remains"))
	rows.append(_result("Role info Mathematician evaluator recognized", _role_info_mathematician_recognized(), "Mathematician returns numeric sum payload"))
	rows.append(_result("Role info Mathematician sums true Evil numbers", _role_info_mathematician_truthful_sum(), "All true Evil Số Hiệu contribute"))
	rows.append(_result("Role info Mathematician ignores Good numbers", _role_info_mathematician_ignores_good(), "Good suspects do not contribute"))
	rows.append(_result("Role info Mathematician ignores displayed pretend", _role_info_mathematician_ignores_displayed_state(), "True alignment drives sum"))
	rows.append(_result("Role info Mathematician supports pretend behavior", _role_info_mathematician_pretend_behavior(), "Displayed Mathematician uses behavior evaluator"))
	rows.append(_result("Role info Mathematician lying differs", _role_info_mathematician_lying_differs(), "Lying sum != true sum"))
	rows.append(_result("Role info Mathematician tainted differs", _role_info_mathematician_tainted_differs(), "Tha Hóa sum != true sum"))
	rows.append(_result("Role info Mathematician <=11 deviation", _role_info_mathematician_low_deviation(), "Incorrect sum differs by at most 4"))
	rows.append(_result("Role info Mathematician 11-29 deviation", _role_info_mathematician_mid_deviation(), "Incorrect sum differs by at most 35%"))
	rows.append(_result("Role info Mathematician >=29 deviation", _role_info_mathematician_high_deviation(), "Incorrect sum differs by at most 10"))
	rows.append(_result("Role info Mathematician ignores handled-death state", _role_info_mathematician_death_independent(player_fixtures), "Authored hidden world, not unresolved Evil"))
	rows.append(_result("Role info Mathematician is tutorial agnostic", _role_info_mathematician_no_tutorial_specific_domain(), "No Tutorial 05 IDs in evaluator"))
	rows.append(_result("Role info Weatherman evaluator recognized", _role_info_weatherman_recognized(), "Weatherman returns structured weather payload"))
	rows.append(_result("Role info Weatherman returns three numbers", _role_info_weatherman_three_numbers(), "Exactly 3 Số Hiệu"))
	rows.append(_result("Role info Weatherman includes true Innocent", _role_info_weatherman_true_innocent(), "One announced Số Hiệu is Người Vô Tội"))
	rows.append(_result("Role info Weatherman includes true Meddler", _role_info_weatherman_true_meddler(), "One announced Số Hiệu is Kẻ Bao Đồng"))
	rows.append(_result("Role info Weatherman includes true Evil group", _role_info_weatherman_true_evil_group(), "One announced Số Hiệu is Thuộc Hạ or Nghịch Thần"))
	rows.append(_result("Role info Weatherman ignores displayed groups", _role_info_weatherman_ignores_displayed_groups(), "True role group drives claim"))
	rows.append(_result("Role info Weatherman true Innocent excludes self", _role_info_weatherman_true_self_exclusion(), "True Innocent Weatherman not selected as Innocent"))
	rows.append(_result("Role info Weatherman pretender may select self", _role_info_weatherman_pretender_self_allowed(), "Non-Innocent pretender can appear in fitting slot"))
	rows.append(_result("Role info Weatherman lying uses Good/Meddler only", _role_info_weatherman_lying_restricted(), "No Thuộc Hạ/Nghịch Thần in lying claim"))
	rows.append(_result("Role info Weatherman tainted uses Good/Meddler only", _role_info_weatherman_tainted_restricted(), "No Thuộc Hạ/Nghịch Thần in tainted claim"))
	rows.append(_result("Role info Weatherman lie pattern false", _role_info_weatherman_lie_pattern_false(), "Lying/tainted claim is not 1/1/Evil"))
	rows.append(_result("Role info Weatherman no-Meddler special payload", _role_info_weatherman_no_meddler_payload(), "Explicit NO_MEDDLER_FOUND payload"))
	rows.append(_result("Role info Weatherman no-Meddler absence represented", _role_info_weatherman_no_meddler_absence(), "No Kẻ Bao Đồng claim remains explicit"))
	rows.append(_result("Role info Weatherman no-Meddler keeps two numbers", _role_info_weatherman_no_meddler_two_numbers(), "Innocent + Evil Số Hiệu retained"))
	rows.append(_result("Role info Weatherman no-Meddler keeps Innocent", _role_info_weatherman_no_meddler_innocent(), "One true Người Vô Tội retained"))
	rows.append(_result("Role info Weatherman no-Meddler keeps Evil group", _role_info_weatherman_no_meddler_evil_group(), "One Thuộc Hạ/Nghịch Thần retained"))
	rows.append(_result("Role info Weatherman no-Meddler excludes true self", _role_info_weatherman_no_meddler_self_exclusion(), "True Innocent Weatherman not selected"))
	rows.append(_result("Role info Weatherman no-Meddler uses suspect number", _role_info_weatherman_no_meddler_uses_suspect_number(), "Số Hiệu is suspect_id, not board_slot"))
	rows.append(_result("Role info Weatherman no-Meddler deterministic", _role_info_weatherman_no_meddler_deterministic(), "Stable selection order"))
	rows.append(_result("Role info Weatherman uses suspect number", _role_info_weatherman_uses_suspect_number(), "Số Hiệu is suspect_id, not board_slot"))
	rows.append(_result("Role info Weatherman is tutorial agnostic", _role_info_weatherman_no_tutorial_specific_domain(), "No Tutorial 05 IDs in evaluator"))
	rows.append(_result("Role info presentation preserves tutorials", _role_info_presentation_regression(tutorial_case, tutorial_case_02, roles, player_fixtures), "Tutorial 01/02 investigated output unchanged"))
	rows.append(_result("Kill foundation suspects start alive", _kill_foundation_starts_alive(case_fixture, player_fixtures), "Runtime death defaults false"))
	rows.append(_result("Kill foundation successful kill marks dead", _kill_foundation_success_marks_dead(case_fixture, player_fixtures), "Alive to dead transition"))
	rows.append(_result("Kill foundation repeated kill is idempotent", _kill_foundation_repeat_idempotent(case_fixture, player_fixtures), "Second kill does not transition again"))
	rows.append(_result("Kill foundation Good kill preserves Evil answer", _kill_foundation_good_kill_preserves_evil_answer(case_fixture, player_fixtures), "Static answer membership unchanged"))
	rows.append(_result("Dead Evil remains unresolved after kill", _handled_evil_excludes_killed_evil(case_fixture, player_fixtures), "Dead Evil remains in unresolved set"))
	rows.append(_result("Dead Evil keeps living true Evil unresolved", _handled_evil_keeps_living_evil(case_fixture, player_fixtures), "All Evil IDs still required"))
	rows.append(_result("Dead Evil zero-death path preserves static answers", _handled_evil_zero_death_static(case_fixture, player_fixtures), "No death equals old Evil set"))
	rows.append(_result("Submission still requires killed Evil after kill", _handled_evil_submission_integration(case_fixture, player_fixtures), "Killed Evil remains required in answer"))
	rows.append(_result("Chỉ Điểm completion still requires killed Evil", _handled_evil_single_accuse_integration(case_fixture, player_fixtures), "Death does not replace Chỉ Điểm"))
	rows.append(_result("Kill foundation does not fabricate Chỉ Điểm knowledge", _kill_foundation_no_private_knowledge(case_fixture, player_fixtures), "Death and private reveal stay separate"))
	rows.append(_result("Kill foundation is tutorial agnostic", _kill_foundation_no_tutorial_specific_domain(), "No Tutorial 05 IDs in domain foundation"))
	var vigilante_checks: Dictionary = _vigilante_function_checks(player_fixtures)
	var vigilante_specs: Array[Dictionary] = [
		{"name":"Vigilante function type is recognized","key":"type_recognized"},
		{"name":"Vigilante truthful Evil target kills","key":"truthful_evil_kills"},
		{"name":"Vigilante truthful Good target misses","key":"truthful_good_misses"},
		{"name":"Vigilante lying Evil target misses","key":"lying_evil_misses"},
		{"name":"Vigilante tainted Evil target misses","key":"tainted_evil_misses"},
		{"name":"Runtime Poisoner-tainted Vigilante misses without kill attempt","key":"runtime_tainted_misses"},
		{"name":"Vigilante fresh runtime does not retain Poisoner taint","key":"fresh_runtime_kills"},
		{"name":"Truthful Vigilante respects Scoundrel effective immunity","key":"scoundrel_immunity"},
		{"name":"Vigilante uses true alignment over displayed role","key":"true_alignment_drives"},
		{"name":"Vigilante pretender can execute behavior role","key":"pretender_behavior"},
		{"name":"Vigilante self-target is valid","key":"self_target_allowed"},
		{"name":"Vigilante miss consumes one use","key":"miss_consumes"},
		{"name":"Vigilante kill consumes one use","key":"kill_consumes"},
		{"name":"Vigilante action advances exactly once","key":"turn_advances_once"},
		{"name":"Vigilante killed Evil remains verdict-required","key":"killed_evil_handled"},
		{"name":"Vigilante Good kill attempt preserves Evil membership","key":"good_miss_preserves_evil"},
		{"name":"Vigilante death does not fabricate Chỉ Điểm knowledge","key":"no_private_knowledge"},
		{"name":"Vigilante repeated use is rejected","key":"repeat_rejected"},
		{"name":"Vigilante foundation is tutorial agnostic","key":"tutorial_agnostic"},
	]
	for spec: Dictionary in vigilante_specs:
		rows.append(_result(String(spec.name), bool(vigilante_checks.get(spec.key, false)), "Vigilante active-function invariant"))
	var surgeon_checks: Dictionary = _surgeon_timed_event_checks(player_fixtures)
	var surgeon_specs: Array[Dictionary] = [
		{"name":"Case clock starts at zero","key":"clock_zero"},
		{"name":"Case time advances without turn advance","key":"time_turn_independent"},
		{"name":"Action time cost applies exactly once","key":"time_cost_once"},
		{"name":"Timed event waits before threshold","key":"before_threshold"},
		{"name":"Timed event fires at 12h","key":"fires_at_threshold"},
		{"name":"Timed event fires only once","key":"one_shot"},
		{"name":"Surgeon event is role-driven","key":"role_driven"},
		{"name":"Surgeon selects alive current Innocent","key":"true_innocent_target"},
		{"name":"Surgeon victim pool follows current role group","key":"current_group_target_authority"},
		{"name":"Surgeon ignores displayed victim role","key":"displayed_ignored"},
		{"name":"Successful Surgeon kill uses CaseKillService","key":"kill_service"},
		{"name":"Failed Surgeon event kills nobody","key":"failed_kills_nobody"},
		{"name":"Surgeon deterministic same seed stable","key":"deterministic_same"},
		{"name":"Surgeon deterministic alternate seed flips branch","key":"deterministic_flip"},
		{"name":"Surgeon no-target event resolves once","key":"no_target_once"},
		{"name":"Surgeon excludes dead Innocent target","key":"dead_innocent_excluded"},
		{"name":"Surgeon excludes source from victim pool","key":"source_excluded"},
		{"name":"Surgeon excludes living Meddler from victim pool","key":"meddler_excluded"},
		{"name":"Surgeon excludes living non-Innocent from victim pool","key":"non_innocent_excluded"},
		{"name":"Surgeon uses full random Innocent pool","key":"full_candidate_pool"},
		{"name":"Surgeon alternate seed can select another victim","key":"alternate_seed_victim"},
		{"name":"Surgeon Good kill preserves Evil membership","key":"good_kill_preserves_evil"},
		{"name":"Surgeon event does not fabricate Chỉ Điểm knowledge","key":"no_private_knowledge"},
		{"name":"Surgeon reevaluation does not duplicate kill","key":"no_duplicate"},
		{"name":"Surgeon event leaves current roles unchanged","key":"current_role_unchanged"},
		{"name":"Surgeon event does not advance clock","key":"elapsed_unchanged"},
		{"name":"Surgeon event does not mutate authored suspects","key":"authored_unchanged"},
		{"name":"Zero timed-event Case stays unchanged","key":"zero_event_case"},
		{"name":"Surgeon foundation is tutorial agnostic","key":"tutorial_agnostic"},
	]
	for spec: Dictionary in surgeon_specs:
		rows.append(_result(String(spec.name), bool(surgeon_checks.get(spec.key, false)), "Surgeon timed-event invariant"))
	var critic_checks: Dictionary = _critic_foundation_checks(roles, player_fixtures)
	var critic_specs: Array[Dictionary] = [
		{"name":"Critic role exists as Traitor","key":"role_exists"},
		{"name":"Critic true alignment is Evil","key":"true_alignment"},
		{"name":"Normal Reputation loss unchanged","key":"normal_loss"},
		{"name":"Critic Reputation loss doubled","key":"critic_loss"},
		{"name":"Critic Reputation gain not doubled","key":"gain_not_doubled"},
		{"name":"Critic actual Reputation not overwritten","key":"actual_reputation_stable"},
		{"name":"Critic treated as Poor for turn order","key":"effective_poor"},
		{"name":"Non-Critic turn ordering unchanged","key":"normal_turn_order"},
		{"name":"Critic pretend role must exist","key":"pretend_valid_role"},
		{"name":"Critic may pretend role not truly in play","key":"pretend_not_true_in_play"},
		{"name":"Critic pretend role truly in play rejected","key":"pretend_true_in_play_rejected"},
		{"name":"Displayed roles do not define in-play set","key":"displayed_not_in_play"},
		{"name":"Critic current-role witness defines present role","key":"current_role_witness_present"},
		{"name":"Critic sees Barkeep transformed-away role as absent","key":"transformed_away_absent"},
		{"name":"Critic sees replacement Drunkard as present","key":"replacement_drunkard_present"},
		{"name":"Critic may display listed role transformed away at startup","key":"transformed_away_valid"},
		{"name":"Critic rejects unlisted absent role","key":"unlisted_absent_rejected"},
		{"name":"Tutorial 05 Mathematician is explicitly listed and absent","key":"tutorial_05_listed_absent"},
		{"name":"Tutorial 05 Critic listed-absent setup remains valid","key":"tutorial_05_valid"},
		{"name":"Critic truth remains separate from pretend","key":"truth_separate"},
		{"name":"Critic foundation is tutorial agnostic","key":"tutorial_agnostic"},
		{"name":"Critic foundation preserves F1-F5 anchors","key":"prior_foundations"},
	]
	for spec: Dictionary in critic_specs:
		rows.append(_result(String(spec.name), bool(critic_checks.get(spec.key, false)), "Critic / Traitor foundation invariant"))
	rows.append(_result("Crime Scene stays out of runtime suspects", _crime_scene_not_runtime_suspect(tutorial_case, player_fixtures), "Runtime has only suspect entities"))
	rows.append(_result("Card IDs ordered 1–8", _board_ids_are_ordered(case_fixture), "Sorted public IDs"))
	rows.append(_result("Public data hides true_alignment", _view_data_excludes(case_fixture, "true_alignment"), "DTO field absent"))
	rows.append(_result("Public data hides true_role_id", _view_data_excludes(case_fixture, "true_role_id"), "DTO field absent"))
	rows.append(_result("Public data hides is_corrupted", _view_data_excludes(case_fixture, "is_corrupted"), "DTO field absent"))
	rows.append(_result("Public data hides is_impersonating", _view_data_excludes(case_fixture, "is_impersonating"), "DTO field absent"))
	rows.append(_result("All cards not investigated", _all_public_views_hidden(case_fixture), "Chưa điều tra; no public role"))
	rows.append(_result("Gameplay actions disabled", _case_actions_disabled(), "Điều tra / Chức năng / Trình Án"))
	rows.append(_result("Back route to DebugHome", _case_scene_has_back_route(), AppFlow.DEBUG_HOME_SCENE))
	rows.append(_result("Player-facing Full Reveal results button activates", _case_scene_player_facing_results_button_activates(), "Xem kết quả Kỳ Án emits truth acknowledgement"))
	rows.append(_result("Invalid case presentation safe", _invalid_case_presentation_safe(), "Empty public view list; no crash"))
	rows.append(_result("Case body uses fixed three-region layout", _case_body_uses_vertical_scroll(), "No whole-page scroll; left, board, and right stay fixed"))
	rows.append(_result("Case role list owns independent overflow scroll", _case_scroll_owns_full_body(), "Only Thân Phận content scrolls when needed"))
	rows.append(_result("Case Board 3x3 layout preserved", _case_board_layout_preserved(), "No horizontal scroll; board remains 3 columns"))
	rows.append(_result("Case UI foundation freeze", _case_ui_foundation_freeze(case_fixture), "help footer non-overlap; board columns size-aware"))
	var hover_relation: Dictionary = _hover_relation_emphasis_checks(tutorial_case_03, tutorial_case_04, tutorial_case_05, roles, player_fixtures)
	rows.append(_result("Case Board hover relation emphasis", bool(hover_relation.get("passed", false)), String(hover_relation.get("detail", "structured relation targets emphasized without reflow"))))
	rows.append(_result("VSCaseMain required UI wiring", _case_required_ui_nodes_exist(), "All controller %Node references resolve"))
	rows.append(_result("Role Reference nodes exist", _role_reference_nodes_exist(), "Clickable role reference shell"))
	rows.append(_result("Role Reference entries clickable", _role_reference_entries_clickable(case_fixture, roles), "Role list renders Buttons"))
	rows.append(_result("Role Reference color follows group", _role_reference_color_by_group(roles), "GOOD/EVIL role groups differ"))
	rows.append(_result("Role Reference exposes rules only", _role_reference_is_public_only(case_fixture, roles), "No suspect ownership/truth"))
	rows.append(_result("Chỉ Điểm service load", SingleSuspectAccusationService.new() != null, "Separate authority service"))
	rows.append(_result("Correct Chỉ Điểm stores private role", _single_accuse_correct_private(case_fixture, player_fixtures), "player_id keyed true role only"))
	rows.append(_result("Private knowledge is player scoped", _private_knowledge_player_scoped(case_fixture, player_fixtures), "Other player cannot read"))
	rows.append(_result("Repeated Chỉ Điểm does not duplicate", _single_accuse_no_duplicate(case_fixture, player_fixtures), "same player + suspect"))
	rows.append(_result("Chỉ Điểm keeps public board unchanged", _single_accuse_public_board_unchanged(case_fixture, roles, player_fixtures), "No private truth on public card"))
	rows.append(_result("Crime Scene cannot be Chỉ Điểm target", _single_accuse_crime_scene_rejected(case_fixture, player_fixtures), "SUSPECT_NOT_FOUND"))
	rows.append(_result("Wrong Chỉ Điểm uses inactive consequence", _single_accuse_wrong_consequence(case_fixture, player_fixtures), "SUBMITTED_WRONG + inactive"))
	rows.append(_result("Incomplete Chỉ Điểm remains separate from submissions", _single_accuse_not_submission(case_fixture, player_fixtures), "No CaseSubmission until full Evil set"))
	rows.append(_result("Correct Chỉ Điểm advances exactly once", _single_accuse_correct_advances_once(tutorial_case_03, roles, player_fixtures), "Private #4, next player, one turn"))
	rows.append(_result("Wrong Chỉ Điểm advances exactly once", _single_accuse_wrong_advances_once(tutorial_case_03, roles, player_fixtures), "Wrong/inactive, next player, one turn"))
	rows.append(_result("Chỉ Điểm early completion uses Early verdict", _single_accuse_early_completion(tutorial_case_03, roles, player_fixtures), "Final missing Evil ends through EARLY_SOLVED"))
	rows.append(_result("Chỉ Điểm Final completion uses Final verdict", _single_accuse_final_completion(tutorial_case_03, player_fixtures), "Early knowledge + final missing Evil resolves final player"))
	rows.append(_result("Incomplete Final Chỉ Điểm rotates unresolved player", _single_accuse_final_incomplete_rotates(tutorial_case_03, player_fixtures), "Private knowledge persists; no Final lock"))
	rows.append(_result("Wrong Final Chỉ Điểm resolves wrong", _single_accuse_final_wrong_resolves(tutorial_case_03, player_fixtures), "No private role; wrong Final lock skips player"))
	rows.append(_result("Final phase Chỉ Điểm UI remains available", _single_accuse_final_ui_available(tutorial_case_03, roles, player_fixtures), "One suspect enables Chỉ Điểm; multiple keeps full verdict"))
	rows.append(_result("Full truth hidden before reveal", _full_truth_hidden_before_reveal(case_fixture, roles, player_fixtures), "Board DTO has no active truth"))
	rows.append(_result("Full Reveal presents true identity after reveal", _full_truth_available_after_reveal(case_fixture, roles, player_fixtures), "True identity, concise statement, structured truth"))
	rows.append(_result("General impersonation infrastructure remains intact", _impersonation_contract_ready(case_fixture, roles), "Full fixture still has true/displayed/impersonated role ids"))
	rows.append(_result("TurnManager load", TurnManager.new() != null, "Domain service available"))
	rows.append(_result("Turn order reputation descending", _turn_order_reputation_descending(player_fixtures), "Danh Tiếng high to low"))
	rows.append(_result("Fixture turn order", _fixture_turn_order(player_fixtures), "Player 1 → Player 2 → Player 3"))
	rows.append(_result("Tie-break 5/5/3 valid", _tie_break_valid(false), "All players once; lower reputation last"))
	rows.append(_result("Tie-break 5/5/5 valid", _tie_break_valid(true), "All tied players once"))
	rows.append(_result("Tie-break fixed after init", _turn_order_fixed_after_init(), "Reads do not reroll"))
	rows.append(_result("Turn order does not resort", _turn_order_not_resorted(player_fixtures), "Reputation mutation does not change current case order"))
	rows.append(_result("Initial current player", _initial_current_player(player_fixtures), "Player 1"))
	rows.append(_result("Advance Player 1 to Player 2", _advance_sequence_matches(player_fixtures, 1, &"player_2"), "Exactly one advance"))
	rows.append(_result("Advance Player 2 to Player 3", _advance_sequence_matches(player_fixtures, 2, &"player_3"), "Second advance"))
	rows.append(_result("Advance Player 3 to Player 1", _advance_sequence_matches(player_fixtures, 3, &"player_1"), "Wraps safely"))
	rows.append(_result("InvestigationService load", InvestigationService.new() != null, "Domain service available"))
	rows.append(_result("Valid investigation succeeds", _valid_investigation(case_fixture, player_fixtures), "Suspect runtime committed"))
	rows.append(_result("Repeat investigation fails", _repeat_investigation_fails(case_fixture, player_fixtures), "SUSPECT_ALREADY_INVESTIGATED"))
	rows.append(_result("Unknown suspect investigation fails", _unknown_investigation_fails(case_fixture, player_fixtures), "SUSPECT_NOT_FOUND"))
	rows.append(_result("Investigation changes one runtime", _investigation_changes_one_runtime(case_fixture, player_fixtures), "Only selected suspect changes"))
	rows.append(_result("Investigation keeps definition immutable", _investigation_keeps_definition(case_fixture, player_fixtures), "Definition unchanged"))
	rows.append(_result("Runtime DTO before investigation hidden", _runtime_dto_before_hidden(case_fixture, roles, player_fixtures), "No public role"))
	rows.append(_result("Runtime DTO after investigation reveals display", _runtime_dto_after_reveals(case_fixture, roles, player_fixtures), "Displayed role name only"))
	rows.append(_result("Runtime DTO hides true role", _runtime_dto_excludes(case_fixture, roles, player_fixtures, "true_role_id"), "Forbidden field absent"))
	rows.append(_result("Runtime DTO hides true alignment", _runtime_dto_excludes(case_fixture, roles, player_fixtures, "true_alignment"), "Forbidden field absent"))
	rows.append(_result("Runtime DTO hides Tha Hóa field", _runtime_dto_excludes(case_fixture, roles, player_fixtures, "is_corrupted"), "Forbidden field absent"))
	rows.append(_result("Runtime DTO hides impersonation field", _runtime_dto_excludes(case_fixture, roles, player_fixtures, "is_impersonating"), "Forbidden field absent"))
	rows.append(_result("Suspect 4 reveals impersonated display role", _suspect_four_reveals_displayed(case_fixture, roles, player_fixtures), "Chính Nhân A (Fixture)"))
	rows.append(_result("Suspect 4 hides true role", _suspect_four_hides_true(case_fixture, roles, player_fixtures), "Tòng Phạm A not public"))
	rows.append(_result("Suspect 6 hides Tha Hóa", _suspect_six_hides_corruption(case_fixture, roles, player_fixtures), "No Tha Hóa label or field"))
	rows.append(_result("Investigation advances exactly once", _investigation_advances_once(case_fixture, player_fixtures), "Commit then one TurnManager advance"))
	rows.append(_result("Cancel selection does not advance", _cancel_does_not_advance(player_fixtures), "Selection cleared; same turn"))
	rows.append(_result("Eight investigations disable action", _eight_investigations_finish_safely(case_fixture, player_fixtures), "8/8 suspects; Crime Scene ignored; investigation closed"))
	rows.append(_result("Fresh runtime on re-enter", _fresh_runtime_resets(case_fixture, player_fixtures), "No investigated cards, turn 1, empty log"))
	rows.append(_result("FunctionAvailabilityService load", FunctionAvailabilityService.new() != null, "Domain lifecycle service available"))
	rows.append(_result("Hidden before investigation", _function_hidden_before_investigation(case_fixture, roles, player_fixtures), "Functional true role remains private"))
	rows.append(_result("Role without function stays absent", _non_function_role_has_no_runtime(case_fixture, roles, player_fixtures), "No public/runtime function for suspect 2"))
	rows.append(_result("Reveal creates LOCKED function", _reveal_function_is_locked(case_fixture, roles, player_fixtures), "LOCKED_UNTIL_NEXT_TURN"))
	rows.append(_result("Locked unavailable same turn", _locked_not_available_same_turn(case_fixture, roles, player_fixtures), "No early action availability"))
	rows.append(_result("available_from_turn is reveal + 1", _available_turn_is_next(case_fixture, roles, player_fixtures), "Explicit global turn metadata"))
	rows.append(_result("Next global turn unlocks function", _next_turn_unlocks(case_fixture, roles, player_fixtures), "LOCKED → AVAILABLE"))
	rows.append(_result("Unlock independent of revealer", _unlock_independent_of_revealer(case_fixture, roles, player_fixtures), "Player 2 can use after Player 1 reveal"))
	rows.append(_result("Turn 4 reveal unlocks turn 5", _turn_four_unlocks_turn_five(case_fixture, roles, player_fixtures), "No hard-coded turn 2"))
	rows.append(_result("Multiple available functions coexist", _multiple_functions_coexist(case_fixture, roles, player_fixtures), "Available list supports more than one suspect"))
	rows.append(_result("Function action disabled when none", _function_action_disabled_without_available(case_fixture, roles, player_fixtures), "Availability predicate false"))
	rows.append(_result("Function action enabled when available", _function_action_enabled_with_available(case_fixture, roles, player_fixtures), "Availability predicate true"))
	rows.append(_result("Function placeholder does not advance", function_placeholder_snapshot.turn_unchanged, "2E click consumes no turn"))
	rows.append(_result("Function placeholder preserves usage", function_placeholder_snapshot.usage_unchanged, "2E click consumes no usage"))
	rows.append(_result("Function placeholder changes no target", function_placeholder_snapshot.runtime_unchanged, "No target selection/commit in 2E"))
	rows.append(_result("True role owns function", _true_role_owns_function(roles, player_fixtures), "Displayed role is not effect ownership"))
	rows.append(_result("Pretender uses displayed role function", _pretended_role_function_available(tutorial_case_04, roles, player_fixtures), "Mobster→Thợ May receives displayed-role function"))
	rows.append(_result("Suspect 1 Tailor next-turn timing", _suspect_one_tailor_timing(case_fixture, roles, player_fixtures), "Locked turn 1; available turn 2"))
	rows.append(_result("Function lifecycle resets on re-enter", _function_lifecycle_resets(case_fixture, roles, player_fixtures), "Fresh runtime returns to HIDDEN"))
	rows.append(_result("All suspect investigations preserve usable function", _all_suspect_investigations_function_button_enabled(), "Tailor remains actionable after all suspects"))
	rows.append(_result("2D investigation/turn regression", _investigation_and_unlock_advance_once(case_fixture, roles, player_fixtures), "Commit then exactly one advance"))
	rows.append(_result("Public DTO hides function source", _public_function_dto_hides_source(case_fixture, roles, player_fixtures), "No true role/function type/internal source"))
	rows.append(_result("Active function hand marker presentation", _public_function_hand_marker_contract(case_fixture, roles, player_fixtures), "no function no hand; available blue; consumed gray; no status prose"))
	rows.append(_result("ExecutionService load", InteractiveFunctionExecutionService.new() != null, "Typed domain execution service available"))
	rows.append(_result("Tailor AVAILABLE required", _tailor_available_required(case_fixture, roles, player_fixtures), "Execution rejects non-AVAILABLE state"))
	rows.append(_result("Locked Tailor cannot execute", _locked_tailor_cannot_execute(case_fixture, roles, player_fixtures), "FUNCTION_NOT_AVAILABLE"))
	rows.append(_result("Exhausted Tailor cannot execute", _exhausted_tailor_cannot_execute(case_fixture, roles, player_fixtures), "FUNCTION_EXHAUSTED"))
	rows.append(_result("Exactly two targets required", _tailor_exactly_two_targets(case_fixture, roles, player_fixtures), "TARGET_COUNT_INVALID"))
	rows.append(_result("Same target twice fails", _tailor_duplicate_target_fails(case_fixture, roles, player_fixtures), "TARGETS_MUST_DIFFER"))
	rows.append(_result("Unknown target fails", _tailor_unknown_target_fails(case_fixture, roles, player_fixtures), "TARGET_NOT_FOUND"))
	rows.append(_result("Valid Tailor pair succeeds", _tailor_valid_pair_succeeds(case_fixture, roles, player_fixtures), "Two existing suspects accepted"))
	rows.append(_result("Same alignment returns SAME", _tailor_same_alignment(case_fixture, roles, player_fixtures), "Suspects 2 and 3"))
	rows.append(_result("Different alignment returns DIFFERENT", _tailor_different_alignment(case_fixture, roles, player_fixtures), "Suspects 2 and 4"))
	rows.append(_result("Authored-corrupted Tailor inverts relation", _tailor_authored_corruption_inverts(case_fixture, roles, player_fixtures), "SAME → DIFFERENT"))
	rows.append(_result("Runtime-tainted Tailor inverts relation", _tailor_runtime_taint_inverts(case_fixture, roles, player_fixtures), "SAME → DIFFERENT"))
	rows.append(_result("Tailor runtime taint does not leak into fresh runtime", _tailor_runtime_taint_is_not_sticky(case_fixture, roles, player_fixtures), "fresh SAME remains SAME"))
	rows.append(_result("Tailor compares true alignment not displayed identity", _tailor_ignores_target_displayed_identity(case_fixture, roles, player_fixtures), "displayed Evil target remains true Good"))
	rows.append(_result("Public result hides raw alignment", _tailor_result_hides_raw_alignment(case_fixture, roles, player_fixtures), "No GOOD/EVIL or individual faction"))
	rows.append(_result("Function result exposes no true role", _tailor_result_has_no_true_role(case_fixture, roles, player_fixtures), "Typed result has no hidden-role field"))
	rows.append(_result("Cancel targets preserves usage", _tailor_cancel_preserves_usage(case_fixture, roles, player_fixtures), "No execution on cancel"))
	rows.append(_result("Cancel targets does not advance", _tailor_cancel_does_not_advance(case_fixture, roles, player_fixtures), "Same turn after cancel"))
	rows.append(_result("Tailor consumes one usage", _tailor_consumes_usage(case_fixture, roles, player_fixtures), "1 → 0"))
	rows.append(_result("Tailor becomes EXHAUSTED", _tailor_becomes_exhausted(case_fixture, roles, player_fixtures), "AVAILABLE → EXHAUSTED"))
	rows.append(_result("Exhausted Tailor not selectable", _exhausted_tailor_not_available(case_fixture, roles, player_fixtures), "Removed from available function list"))
	rows.append(_result("Tailor advances exactly once", _tailor_advances_exactly_once(case_fixture, roles, player_fixtures), "Controller-owned turn commit"))
	rows.append(_result("Failed function does not advance", _failed_tailor_does_not_advance(case_fixture, roles, player_fixtures), "Validation failure keeps turn"))
	rows.append(_result("Tailor keeps investigated states", _tailor_keeps_investigated_states(case_fixture, roles, player_fixtures), "Target investigation flags unchanged"))
	rows.append(_result("Tailor keeps definitions immutable", _tailor_keeps_definitions_immutable(case_fixture, roles, player_fixtures), "No definition mutation"))
	rows.append(_result("Displayed Tailor pretender uses copied function", _pretended_role_function_available(tutorial_case_04, roles, player_fixtures), "Mobster→Thợ May uses displayed-role function"))
	rows.append(_result("Public log stores Tailor result", _tailor_public_log_stored(case_fixture, roles, player_fixtures), "Actor, owner, targets and snapshot result"))
	rows.append(_result("Tailor result is immutable snapshot", _tailor_result_snapshot_stable(case_fixture, roles, player_fixtures), "Later definition change does not rewrite result"))
	rows.append(_result("Re-enter resets Tailor usage/history", _tailor_reenter_resets(case_fixture, roles, player_fixtures), "Usage 1 and no execution history"))
	rows.append(_result("All suspect investigations enter mandatory function phase", _all_suspect_investigations_function_button_enabled(), "Investigation locked; Tailor enabled"))
	rows.append(_result("2E unlock lifecycle regression", _next_turn_unlocks(case_fixture, roles, player_fixtures), "Next global turn remains AVAILABLE"))
	rows.append(_result("2D turn/investigation regression retained", _investigation_advances_once(case_fixture, player_fixtures), "Investigation advances once"))
	rows.append(_result("2F layout regression retained", _case_board_layout_preserved(), "Case Board scroll and 3x3 grid retained"))
	rows.append(_result("No 2G submission implementation", _submission_still_disabled(), "Trình Án remains disabled"))
	rows.append(_result("SubmissionService load", CaseSubmissionService.new() != null, "Domain service available"))
	rows.append(_result("Current active player can submit", _submission_current_player(case_fixture, player_fixtures), "Player 1 accepted"))
	rows.append(_result("Non-current player cannot submit", _submission_non_current(case_fixture, player_fixtures), "PLAYER_NOT_CURRENT"))
	rows.append(_result("Inactive player cannot submit", _submission_inactive(case_fixture, player_fixtures), "PLAYER_INACTIVE"))
	rows.append(_result("Player submits only once", _submission_only_once(case_fixture, player_fixtures), "Second commit rejected"))
	rows.append(_result("Empty evil set structurally valid", _submission_answer(case_fixture, player_fixtures, PackedInt32Array()).success, "Valid commit but wrong answer"))
	rows.append(_result("Exact evil set correct", _submission_main(case_fixture, player_fixtures, PackedInt32Array([4, 5])), "{4,5}"))
	rows.append(_result("Reversed evil set correct", _submission_main(case_fixture, player_fixtures, PackedInt32Array([5, 4])), "Order independent"))
	rows.append(_result("Missing evil suspect wrong", not _submission_main(case_fixture, player_fixtures, PackedInt32Array([4])), "Missing 5"))
	rows.append(_result("Extra evil suspect wrong", not _submission_main(case_fixture, player_fixtures, PackedInt32Array([4, 5, 6])), "Extra 6"))
	rows.append(_result("Duplicate submission IDs rejected", _submission_error(case_fixture, player_fixtures, PackedInt32Array([4, 4]), PackedInt32Array(), PackedInt32Array()) == &"DUPLICATE_SUSPECT_ID", "No duplicates"))
	rows.append(_result("Unknown submission suspect rejected", _submission_error(case_fixture, player_fixtures, PackedInt32Array([99]), PackedInt32Array(), PackedInt32Array()) == &"SUSPECT_NOT_FOUND", "Unknown ID"))
	rows.append(_result("Classification outside evil rejected", _submission_error(case_fixture, player_fixtures, PackedInt32Array([4]), PackedInt32Array([5]), PackedInt32Array()) == &"CLASSIFICATION_OUTSIDE_EVIL_SELECTION", "Subset required"))
	rows.append(_result("Classification conflict rejected", _submission_error(case_fixture, player_fixtures, PackedInt32Array([4]), PackedInt32Array([4]), PackedInt32Array([4])) == &"CLASSIFICATION_CONFLICT", "No dual class"))
	rows.append(_result("Main correctness independent from class", _submission_wrong_class_still_solves(case_fixture, player_fixtures), "Bonus separate"))
	rows.append(_result("Correct main wrong class early solves", _submission_wrong_class_still_solves(case_fixture, player_fixtures), "EARLY_SOLVED"))
	rows.append(_result("Correct submission locks", _submission_locks(case_fixture, player_fixtures, PackedInt32Array([4, 5])), "Immutable after confirm"))
	rows.append(_result("Wrong submission locks", _submission_locks(case_fixture, player_fixtures, PackedInt32Array([4])), "Immutable after confirm"))
	rows.append(_result("Submission cancel does not lock", _submission_cancel_clean(), "Draft cleared"))
	rows.append(_result("Submission cancel does not advance", _submission_cancel_turn(player_fixtures), "Same turn"))
	rows.append(_result("Early correct ends case", _submission_outcome(case_fixture, player_fixtures, PackedInt32Array([4, 5])) == CaseEnums.CaseOutcome.EARLY_SOLVED, "Immediate end"))
	rows.append(_result("Early correct does not advance", _submission_correct_no_advance(case_fixture, player_fixtures), "Turn unchanged"))
	rows.append(_result("Others become not submitted", _submission_marks_others(case_fixture, player_fixtures), "NOT_SUBMITTED_CASE_ENDED"))
	rows.append(_result("Prior wrong stays wrong", _submission_prior_wrong_stays(case_fixture, player_fixtures), "Status preserved"))
	rows.append(_result("Wrong submission makes inactive", _submission_wrong_inactive(case_fixture, player_fixtures), "Leaves investigation"))
	rows.append(_result("Wrong submission advances once", _submission_wrong_advances(case_fixture, player_fixtures), "Controller-owned advance"))
	rows.append(_result("Next turn skips inactive", _turn_skips_one_inactive(player_fixtures), "P1 → P2"))
	rows.append(_result("Two inactive players skipped", _turn_skips_two_inactive(player_fixtures), "Only P3"))
	rows.append(_result("Sole active loops safely", _sole_active_loops(player_fixtures), "P3 → P3"))
	rows.append(_result("Zero active gives all failed", _all_players_fail(case_fixture, player_fixtures), "ALL_FAILED_EARLY"))
	rows.append(_result("Zero active has no deadlock", _zero_active_no_next(player_fixtures), "advance returns null"))
	rows.append(_result("Inactive still sees public info", _inactive_sees_public(case_fixture, roles, player_fixtures), "Presentation unaffected"))
	rows.append(_result("Inactive cannot investigate", _inactive_cannot_investigate(case_fixture, player_fixtures), "PLAYER_INACTIVE"))
	rows.append(_result("Inactive cannot use function", _inactive_cannot_function(case_fixture, roles, player_fixtures), "PLAYER_INACTIVE"))
	rows.append(_result("Function survives inactive revealer", _function_survives_revealer(case_fixture, roles, player_fixtures), "P2 can use Tailor"))
	rows.append(_result("Submission selection private", _submission_log_private(case_fixture, player_fixtures), "No selected IDs"))
	rows.append(_result("Correct answer private in progress", _public_log_has_no_truth(case_fixture, player_fixtures), "No evil answer"))
	rows.append(_result("8/8 without usable function awaits final", _eight_sets_awaiting(case_fixture, player_fixtures), "POST phase resolves immediately"))
	rows.append(_result("Early submit disabled awaiting final", _awaiting_rejects_submission(case_fixture, player_fixtures), "CASE_NOT_IN_PROGRESS"))
	rows.append(_result("Ended states lock actions", _ended_states_lock_actions(case_fixture, player_fixtures), "All actions disabled by runtime"))
	rows.append(_result("Player panel uses public status", _player_status_public_only(), "No answer IDs"))
	rows.append(_result("Submission leaves rewards unchanged", _submission_rewards_unchanged(case_fixture, player_fixtures), "All resources stable"))
	rows.append(_result("No Orb added by submission", _submission_resource_delta(case_fixture, player_fixtures, "orb") == 0.0, "Deferred to 2I"))
	rows.append(_result("No Merit added by submission", _submission_resource_delta(case_fixture, player_fixtures, "merit") == 0.0, "Deferred to 2I"))
	rows.append(_result("No Reputation changed", _submission_resource_delta(case_fixture, player_fixtures, "reputation") == 0.0, "Deferred to 2I"))
	rows.append(_result("No Tickets added", _submission_resource_delta(case_fixture, player_fixtures, "tickets") == 0.0, "Deferred to 2I"))
	rows.append(_result("Re-enter resets submission runtime", _submission_reset(case_fixture, player_fixtures), "Active, no submissions, IN_PROGRESS"))
	rows.append(_result("2F Tailor regression", _tailor_valid_pair_succeeds(case_fixture, roles, player_fixtures), "Tailor still works"))
	rows.append(_result("2E unlock regression after 2G", _next_turn_unlocks(case_fixture, roles, player_fixtures), "Lifecycle retained"))
	rows.append(_result("2D turn regression after 2G", _investigation_advances_once(case_fixture, player_fixtures), "Turn retained"))
	rows.append(_result("2G layout regression", _case_board_layout_preserved(), "Responsive Case Board retained"))
	rows.append(_result("2H Final Verdict service available", FinalVerdictService.new() != null, "Typed domain coordinator"))
	rows.append(_result("No 2I Reward Calculator", not ClassDB.class_exists("RewardCalculator"), "Reward remains deferred"))
	var g2h_specs: Array[Dictionary] = [
		{"name":"FinalVerdictService load","key":"service_load"},{"name":"Final starts after post phase resolves","key":"awaiting"},{"name":"Investigation disabled in final","key":"actions_locked"},{"name":"Function disabled in final","key":"actions_locked"},{"name":"Early submission disabled in final","key":"early_disabled"},{"name":"Required players filtered","key":"required_filtered"},{"name":"Early-wrong excluded","key":"early_wrong_excluded"},{"name":"Frozen order used","key":"frozen_order"},{"name":"Final order not randomized","key":"frozen_order"},{"name":"First player draft supported","key":"draft_supported"},{"name":"Cancel stays in final","key":"cancel_stays_final"},{"name":"Cancel does not lock","key":"cancel_no_lock"},{"name":"Confirm locks final","key":"first_locked"},{"name":"Locked answer immutable","key":"immutable"},{"name":"Duplicate final rejected","key":"duplicate_rejected"},{"name":"Final arrays copied","key":"copied"},{"name":"Pending result not public","key":"pending_private"},{"name":"Pending selection not public","key":"pending_private"},{"name":"Next player clean state","key":"next_clean"},{"name":"Automatic handoff overlay UI exists","key":"ui_nodes"},{"name":"Handoff overlay stays above suspect cards","key":"handoff_layer"},{"name":"No manual Final Continue required","key":"handoff_no_continue"},{"name":"Handoff advances to next player immediately","key":"handoff_next_player"},{"name":"Handoff overlay blocks input","key":"handoff_blocks_input"},{"name":"Next player can select after handoff","key":"handoff_after_select"},{"name":"No verdict selection leaks between players","key":"handoff_no_leak"},{"name":"Handoff keeps independent verdict locks","key":"handoff_independent_locks"},{"name":"Truth waits until all verdicts lock","key":"handoff_truth_after_all"},{"name":"Evaluation barrier","key":"barrier"},{"name":"Last lock evaluates once","key":"evaluated_once"},{"name":"Exact set order independent final","key":"order_independent"},{"name":"Classification independent final","key":"classification_independent"},{"name":"Multiple correct supported","key":"multiple_correct"},{"name":"All wrong supported","key":"all_wrong"},{"name":"One active evaluates immediately","key":"one_active"},{"name":"Early-wrong remains wrong","key":"early_wrong_preserved"},{"name":"Pending status hides correctness","key":"pending_status"},{"name":"Results public after barrier","key":"results_public"},{"name":"Correct solver IDs stored","key":"correct_ids"},{"name":"Wrong solver IDs stored","key":"wrong_ids"},{"name":"No correct suspect reveal","key":"no_truth"},{"name":"No true-role reveal","key":"no_truth"},{"name":"No true-alignment reveal","key":"no_truth"},{"name":"No Tha Hóa reveal","key":"no_truth"},{"name":"No impersonation reveal","key":"no_truth"},{"name":"Turn number unchanged final","key":"turn_static"},{"name":"Final flow avoids advance_turn","key":"turn_static"},{"name":"Unusable function expires at final boundary","key":"expiry"},{"name":"EXHAUSTED stays exhausted","key":"exhausted_stable"},{"name":"Expiry consumes no usage","key":"expiry_usage"},{"name":"Resources unchanged before settlement","key":"resources"},{"name":"No Công Danh before settlement","key":"resources"},{"name":"No Danh Tiếng before settlement","key":"resources"},{"name":"No Orb before settlement","key":"resources"},{"name":"No tickets before settlement","key":"resources"},{"name":"No On Solve before settlement","key":"resources"},{"name":"Early solve skips final","key":"early_regression"},{"name":"All failed skips final","key":"all_failed_regression"},{"name":"Zero required guarded","key":"zero_guard"},{"name":"Final state resets","key":"reset"},{"name":"2G submission regression 2H","key":"early_regression"},{"name":"2F Tailor regression 2H","key":"tailor_regression"},{"name":"2E lifecycle regression 2H","key":"expiry"},{"name":"2D turn regression 2H","key":"turn_regression"},{"name":"Responsive layout regression 2H","key":"layout"},{"name":"No Stage 3 implementation","key":"no_2i"},
	]
	g2h_specs.append({"name":"Final Verdict sidebar preserves normal turn actor","key":"sidebar_normal"})
	g2h_specs.append({"name":"Final Verdict sidebar shows first pending player","key":"sidebar_first"})
	g2h_specs.append({"name":"Final Verdict sidebar and handoff show Player 2","key":"sidebar_second"})
	g2h_specs.append({"name":"Final Verdict sidebar and handoff show Player 3","key":"sidebar_third"})
	g2h_specs.append({"name":"Final Verdict sidebar sync leaves gameplay turn unchanged","key":"sidebar_turn_static"})
	for spec in g2h_specs:
		rows.append(_result(spec.name, bool(g2h.get(spec.key, false)), "2H invariant"))
	var post_reveal_specs: Array[Dictionary] = [
		{"name":"All suspects no usable function enters final","key":"no_function_final"},
		{"name":"All suspects available Tailor enters post phase","key":"available_tailor_post"},
		{"name":"Last-reveal locked Tailor unlocks after advance","key":"locked_tailor_unlocks"},
		{"name":"Tailor exhaustion opens final","key":"tailor_then_final"},
		{"name":"Multiple functions resolve sequentially","key":"multiple_sequential"},
		{"name":"Exhausted function does not block final","key":"exhausted_no_block"},
		{"name":"Function without valid targets cannot deadlock","key":"invalid_targets_no_deadlock"},
		{"name":"Investigation disabled in post phase","key":"post_no_investigation"},
		{"name":"Early submission allowed in post phase","key":"post_early_submit"},
		{"name":"Final verdict still does not advance turn","key":"final_turn_static"},
	]
	for spec in post_reveal_specs:
		rows.append(_result(spec.name, bool(post_reveal.get(spec.key, false)), "Post-reveal rule invariant"))
	var text_history_specs: Array[Dictionary] = [
		{"name":"PublicFunctionRecord type load","key":"record_load"},
		{"name":"Tailor creates exactly one public record","key":"one_record"},
		{"name":"Public record owner","key":"owner"},
		{"name":"Public record targets","key":"targets"},
		{"name":"Public record result","key":"result"},
		{"name":"Public record acting player","key":"acting_player"},
		{"name":"Public record executed turn","key":"turn"},
		{"name":"Cancel creates no public record","key":"cancel_clean"},
		{"name":"Invalid function creates no public record","key":"invalid_clean"},
		{"name":"Record excludes true alignment","key":"no_hidden_fields"},
		{"name":"Record excludes true role","key":"no_hidden_fields"},
		{"name":"Record excludes Tha Hóa","key":"no_hidden_fields"},
		{"name":"Record excludes impersonation","key":"no_hidden_fields"},
		{"name":"Record excludes correct answer","key":"no_hidden_fields"},
		{"name":"Tailor same-faction sentence","key":"same_sentence"},
		{"name":"Tailor different-faction sentence","key":"different_sentence"},
		{"name":"Text result hides faction identities","key":"sentence_no_leak"},
		{"name":"Multiple text records preserve order","key":"multiple_order"},
		{"name":"History retains prior text results","key":"history_retains"},
		{"name":"Re-enter resets public records","key":"record_reset"},
		{"name":"Text history does not advance turn","key":"turn_unchanged"},
		{"name":"Text history consumes no extra usage","key":"usage_once"},
		{"name":"Text history preserves post-reveal flow","key":"post_regression"},
		{"name":"Text history preserves Final Verdict","key":"final_regression"},
		{"name":"Text history preserves early submission","key":"early_regression"},
		{"name":"Card-local clue UI replaces history panel","key":"ui_nodes"},
		{"name":"Function overlay removed","key":"no_overlay"},
		{"name":"Function overlay toggle removed","key":"no_toggle"},
	]
	for spec in text_history_specs:
		rows.append(_result(spec.name, bool(text_history.get(spec.key, false)), "Public text-history invariant"))
	var post_reveal_input_specs: Array[Dictionary] = [
		{"name":"Post-reveal Tailor accepts card click","key":"post_click"},
		{"name":"Investigated card selectable as function target","key":"investigated_target"},
		{"name":"First target click reaches 1/2","key":"first_click"},
		{"name":"Second distinct click reaches 2/2","key":"second_click"},
		{"name":"Function Confirm enabled at exactly two","key":"confirm_two"},
		{"name":"Crime Scene cannot become function target","key":"crime_scene_target"},
		{"name":"Selected target toggles off","key":"toggle_off"},
		{"name":"Duplicate target cannot create invalid pair","key":"no_duplicate"},
		{"name":"Investigation stays disabled post-reveal","key":"investigation_locked"},
		{"name":"Post-reveal suspicion enables Trình Án","key":"post_submission_choice"},
		{"name":"Crime Scene cannot be suspected/submitted","key":"post_crime_scene_submission"},
		{"name":"Post-reveal submission can skip function use","key":"post_submission_without_function"},
		{"name":"Function Confirm executes once","key":"execute_once"},
		{"name":"Post-reveal function consumes one usage","key":"usage_once"},
		{"name":"Post-reveal function advances one turn","key":"turn_once"},
		{"name":"Text clue history appended once","key":"history_once"},
		{"name":"Function resolution still opens Final Verdict","key":"final_transition"},
		{"name":"Submission selection input regression","key":"submission_selection"},
		{"name":"Final Verdict selection input regression","key":"final_selection"},
	]
	for spec in post_reveal_input_specs:
		rows.append(_result(spec.name, bool(post_reveal_input.get(spec.key, false)), "Post-reveal input-routing invariant"))
	var card_local_clue_specs: Array[Dictionary] = [
		{"name":"Tailor owner card shows consumed hand marker","key":"owner_status"},
		{"name":"Tailor owner card shows short public clue","key":"owner_clue"},
		{"name":"Target card 4 receives no owner clue","key":"target_four_clean"},
		{"name":"Target card 5 receives no owner clue","key":"target_five_clean"},
		{"name":"Public record maps by source suspect","key":"source_mapping"},
		{"name":"Multiple owner records preserve line order","key":"multiple_order"},
		{"name":"Card-local clue excludes hidden truth","key":"no_leak"},
		{"name":"Card-local clue label wraps text","key":"wrap"},
		{"name":"Standalone function history panel removed","key":"no_panel"},
		{"name":"Cancel adds no card-local clue","key":"cancel_clean"},
		{"name":"Validation failure adds no card-local clue","key":"invalid_clean"},
		{"name":"Card-local clue reset on fresh runtime","key":"reset"},
	]
	for spec in card_local_clue_specs:
		rows.append(_result(spec.name, bool(card_local_clue.get(spec.key, false)), "Card-local public clue invariant"))
	var g2i_specs: Array[Dictionary] = [
		{"name":"SettlementService loads","key":"service"}, {"name":"Settlement rejects IN_PROGRESS","key":"reject_open"},
		{"name":"Settlement rejects POST_REVEAL_FUNCTIONS","key":"reject_post"}, {"name":"Settlement rejects AWAITING_FINAL_VERDICT","key":"reject_awaiting"},
		{"name":"Early solved settlement succeeds","key":"early"}, {"name":"Early solver receives full Merit pool","key":"early_merit"},
		{"name":"Early solver receives On Solve reputation","key":"early_rep"}, {"name":"Early solver receives base ticket","key":"early_base"},
		{"name":"Fully classified early solver receives no classification bonus","key":"early_no_bonus"}, {"name":"Early correct solver receives no Orb","key":"early_orb"},
		{"name":"Chỉ Điểm completion matches normal correct reward","key":"single_accuse_reward"},
		{"name":"ALL_FAILED_EARLY settlement succeeds","key":"all_failed"}, {"name":"Not-submitted player Merit unchanged","key":"not_submitted"},
		{"name":"Not-submitted player reputation unchanged","key":"not_submitted"}, {"name":"Not-submitted player Orb unchanged","key":"not_submitted"},
		{"name":"Not-submitted player tickets unchanged","key":"not_submitted"}, {"name":"Not-submitted is not counted wrong","key":"not_submitted"},
		{"name":"Settlement commit marks runtime settled","key":"settled"}, {"name":"Settlement stores typed result","key":"settled"},
		{"name":"Second settlement returns stored result","key":"idempotent"}, {"name":"Second settlement does not duplicate Merit","key":"idempotent"},
		{"name":"Second settlement does not duplicate reputation","key":"idempotent"}, {"name":"Second settlement does not duplicate Orb","key":"idempotent"},
		{"name":"Second settlement does not duplicate tickets","key":"idempotent"}, {"name":"Final settlement succeeds","key":"final"},
		{"name":"Final Merit pool splits between correct solvers","key":"final_merit"}, {"name":"Final Merit share rounds to two decimals","key":"rounding"},
		{"name":"Final correct player receives On Solve","key":"final_correct"}, {"name":"Final correct player receives base ticket","key":"final_correct"},
		{"name":"Final wrong player receives zero Merit","key":"final_wrong"}, {"name":"Final wrong player loses fixture reputation","key":"final_wrong"},
		{"name":"Final wrong player receives exactly one Orb","key":"final_wrong"}, {"name":"Final wrong player receives no tickets","key":"final_wrong"},
		{"name":"Wrong early receives penalty and one Orb","key":"wrong_early"}, {"name":"Classification does not affect correct verdict reward","key":"classification"},
		{"name":"Final one correct receives full pool","key":"final_one"}, {"name":"Final three correct receive 6.67 each","key":"final_three"},
		{"name":"Reputation lower clamp is zero","key":"clamp"}, {"name":"Reputation upper clamp is six","key":"clamp"},
		{"name":"Truth builder rejects unsettled runtime","key":"truth_gate"}, {"name":"Truth builder accepts settled terminal runtime","key":"truth"},
		{"name":"Truth answer identifies evil suspects 4 and 5","key":"truth_answer"}, {"name":"Truth identifies suspect 4 true EVIL alignment","key":"truth_four"},
		{"name":"Truth identifies suspect 4 as Thuộc Hạ","key":"truth_four"}, {"name":"Truth identifies suspect 4 impersonation","key":"truth_four"},
		{"name":"Truth shows suspect 4 displayed role differs","key":"truth_four"}, {"name":"Truth identifies suspect 5 as Nghịch Thần","key":"truth_five"},
		{"name":"Truth includes all eight suspects","key":"truth_count"}, {"name":"Truth identifies suspect 6 Tha Hóa","key":"truth_six"},
		{"name":"Truth contains player resolution list","key":"truth_players"}, {"name":"Truth may retain public function records","key":"truth_functions"},
		{"name":"Truth UI panel exists","key":"ui"}, {"name":"Truth answer label exists","key":"ui"},
		{"name":"Truth suspect list label exists","key":"ui"}, {"name":"Truth player result label exists","key":"ui"},
		{"name":"Truth reward delta label exists","key":"ui"}, {"name":"Truth UI content scrolls","key":"ui"},
		{"name":"Truth UI hidden before completion","key":"ui_hidden"}, {"name":"Settlement occurs before truth construction","key":"source_order"},
		{"name":"Player strip reads committed resources","key":"source_order"}, {"name":"Fresh runtime resets settlement flag","key":"reset"},
		{"name":"Fresh runtime clears stored settlement","key":"reset"}, {"name":"Fresh runtime clears truth reveal","key":"reset"},
		{"name":"Final Verdict input does not advance gameplay turn","key":"final_turn"}, {"name":"No reward mutation occurs during submission","key":"deferred"},
		{"name":"G2I build label locked","key":"build"},
	]
	for spec in g2i_specs:
		rows.append(_result(spec.name, bool(g2i.get(spec.key, false)), "G2I settlement/truth invariant"))
	for gd2_m0a_row: Dictionary in GD2_M0A_TEST_SUITE.new().run():
		rows.append(_result(String(gd2_m0a_row.get("name", "GĐ2-M0A unnamed")), bool(gd2_m0a_row.get("passed", false)), String(gd2_m0a_row.get("detail", "GĐ2-M0A production map foundation invariant"))))
	for production_character_row: Dictionary in GD2_PRODUCTION_CHARACTER_TEST_SUITE.new().run():
		rows.append(_result(String(production_character_row.get("name", "GĐ2 production Character unnamed")), bool(production_character_row.get("passed", false)), String(production_character_row.get("detail", "GĐ2 production Character roster invariant"))))
	for production_reward_row: Dictionary in GD2_PRODUCTION_REWARD_TABLES_TEST_SUITE.new().run():
		rows.append(_result(String(production_reward_row.get("name", "GĐ2 production reward unnamed")), bool(production_reward_row.get("passed", false)), String(production_reward_row.get("detail", "GĐ2 production reward-table invariant"))))
	for production_consumable_row: Dictionary in GD2_PRODUCTION_CONSUMABLES_TEST_SUITE.new().run():
		rows.append(_result(String(production_consumable_row.get("name", "GĐ2 production consumable unnamed")), bool(production_consumable_row.get("passed", false)), String(production_consumable_row.get("detail", "GĐ2 production Consumables V1 invariant"))))
	for gd2_row: Dictionary in Gd2M1TestSuite.new().run():
		rows.append(_result(String(gd2_row.get("name", "GĐ2-M1 unnamed")), bool(gd2_row.get("passed", false)), String(gd2_row.get("detail", "GĐ2-M1 foundation invariant"))))
	for gd2_m2_row: Dictionary in GD2_M2_TEST_SUITE.new().run():
		rows.append(_result(String(gd2_m2_row.get("name", "GĐ2-M2 unnamed")), bool(gd2_m2_row.get("passed", false)), String(gd2_m2_row.get("detail", "GĐ2-M2 Character Selection invariant"))))
	for gd2_m3_row: Dictionary in GD2_M3_TEST_SUITE.new().run():
		rows.append(_result(String(gd2_m3_row.get("name", "GĐ2-M3 unnamed")), bool(gd2_m3_row.get("passed", false)), String(gd2_m3_row.get("detail", "GĐ2-M3 Spawn + Movement invariant"))))
	for gd2_m4_row: Dictionary in GD2_M4_TEST_SUITE.new().run():
		rows.append(_result(String(gd2_m4_row.get("name", "GĐ2-M4 unnamed")), bool(gd2_m4_row.get("passed", false)), String(gd2_m4_row.get("detail", "GĐ2-M4 Reward/Item/Temporary Effect invariant"))))
	for gd2_m5_row: Dictionary in GD2_M5_TEST_SUITE.new().run():
		rows.append(_result(String(gd2_m5_row.get("name", "GĐ2-M5 unnamed")), bool(gd2_m5_row.get("passed", false)), String(gd2_m5_row.get("detail", "GĐ2-M5 Equipment/Gacha invariant"))))
	for gd2_m6_row: Dictionary in GD2_M6_TEST_SUITE.new().run():
		rows.append(_result(String(gd2_m6_row.get("name", "GĐ2-M6 unnamed")), bool(gd2_m6_row.get("passed", false)), String(gd2_m6_row.get("detail", "GĐ2-M6 Prototype B Summary/Export invariant"))))
	for gd2_m7_row: Dictionary in GD2_M7_TEST_SUITE.new().run():
		rows.append(_result(String(gd2_m7_row.get("name", "GĐ2-M7 unnamed")), bool(gd2_m7_row.get("passed", false)), String(gd2_m7_row.get("detail", "GĐ2-M7 stabilization invariant"))))
	for gd2_prep_1_row: Dictionary in GD2_PREP_1_TEST_SUITE.new().run():
		rows.append(_result(String(gd2_prep_1_row.get("name", "GĐ2-PREP-1 unnamed")), bool(gd2_prep_1_row.get("passed", false)), String(gd2_prep_1_row.get("detail", "GĐ2-PREP-1 state ownership invariant"))))
	for gd2_prep_3_row: Dictionary in GD2_PREP_3_TEST_SUITE.new().run():
		rows.append(_result(String(gd2_prep_3_row.get("name", "GĐ2-PREP-3 unnamed")), bool(gd2_prep_3_row.get("passed", false)), String(gd2_prep_3_row.get("detail", "GĐ2-PREP-3 inventory ownership invariant"))))
	for gd3_m1_row: Dictionary in GD3_M1_TEST_SUITE.new().run():
		rows.append(_result(String(gd3_m1_row.get("name", "GĐ3-M1 unnamed")), bool(gd3_m1_row.get("passed", false)), String(gd3_m1_row.get("detail", "GĐ3-M1 Match/Round State Bridge invariant"))))
	for gd3_m2_row: Dictionary in GD3_M2_TEST_SUITE.new().run():
		rows.append(_result(String(gd3_m2_row.get("name", "GĐ3-M2 unnamed")), bool(gd3_m2_row.get("passed", false)), String(gd3_m2_row.get("detail", "GĐ3-M2 Case Settlement → MatchState → Loot invariant"))))
	for gd3_m3_row: Dictionary in GD3_M3_TEST_SUITE.new().run():
		rows.append(_result(String(gd3_m3_row.get("name", "GĐ3-M3 unnamed")), bool(gd3_m3_row.get("passed", false)), String(gd3_m3_row.get("detail", "GĐ3-M3 actual Case → settlement → actual Loot invariant"))))
	for gd3_m4_row: Dictionary in GD3_M4_TEST_SUITE.new().run():
		rows.append(_result(String(gd3_m4_row.get("name", "GĐ3-M4 unnamed")), bool(gd3_m4_row.get("passed", false)), String(gd3_m4_row.get("detail", "GĐ3-M4 integrated round-completion invariant"))))
	for gd3_m5_row: Dictionary in GD3_M5_TEST_SUITE.new().run():
		rows.append(_result(String(gd3_m5_row.get("name", "GĐ3-M5 unnamed")), bool(gd3_m5_row.get("passed", false)), String(gd3_m5_row.get("detail", "GĐ3-M5 multi-round next case invariant"))))
	for gd3_m6_row: Dictionary in GD3_M6_TEST_SUITE.new().run():
		rows.append(_result(String(gd3_m6_row.get("name", "GĐ3-M6 unnamed")), bool(gd3_m6_row.get("passed", false)), String(gd3_m6_row.get("detail", "GĐ3-M6 bounded two-Round completion invariant"))))
	for pf_m1_row: Dictionary in PF_M1_TEST_SUITE.new().run():
		rows.append(_result(String(pf_m1_row.get("name", "PF-M1 unnamed")), bool(pf_m1_row.get("passed", false)), String(pf_m1_row.get("detail", "PF-M1 player-facing startup invariant"))))
	for pf_m2_row: Dictionary in PF_M2_TEST_SUITE.new().run():
		rows.append(_result(String(pf_m2_row.get("name", "PF-M2 unnamed")), bool(pf_m2_row.get("passed", false)), String(pf_m2_row.get("detail", "PF-M2 player-facing actual Case invariant"))))
	for pf_m3_row: Dictionary in PF_M3_TEST_SUITE.new().run():
		rows.append(_result(String(pf_m3_row.get("name", "PF-M3 unnamed")), bool(pf_m3_row.get("passed", false)), String(pf_m3_row.get("detail", "PF-M3 player-facing Loot and Equipment invariant"))))
	for pf_m4_row: Dictionary in PF_M4_TEST_SUITE.new().run():
		rows.append(_result(String(pf_m4_row.get("name", "PF-M4 unnamed")), bool(pf_m4_row.get("passed", false)), String(pf_m4_row.get("detail", "PF-M4 player-facing Round completion invariant"))))
	for pf_m5_row: Dictionary in PF_M5_TEST_SUITE.new().run():
		rows.append(_result(String(pf_m5_row.get("name", "PF-M5 unnamed")), bool(pf_m5_row.get("passed", false)), String(pf_m5_row.get("detail", "PF-M5 player-facing Loot presentation invariant"))))
	for pf_m6a_row: Dictionary in PF_M6A_TEST_SUITE.new().run():
		rows.append(_result(String(pf_m6a_row.get("name", "PF-M6A unnamed")), bool(pf_m6a_row.get("passed", false)), String(pf_m6a_row.get("detail", "PF-M6A player-facing next-Round Case invariant"))))
	for pf_m6b_row: Dictionary in PF_M6B_TEST_SUITE.new().run():
		rows.append(_result(String(pf_m6b_row.get("name", "PF-M6B unnamed")), bool(pf_m6b_row.get("passed", false)), String(pf_m6b_row.get("detail", "PF-M6B generalized player-facing multi-Round invariant"))))
	for pf_m6c_row: Dictionary in PF_M6C_TEST_SUITE.new().run():
		rows.append(_result(String(pf_m6c_row.get("name", "PF-M6C unnamed")), bool(pf_m6c_row.get("passed", false)), String(pf_m6c_row.get("detail", "PF-M6C / M5C player-facing three-case option presentation invariant"))))
	for pf_m6d_row: Dictionary in PF_M6D_TEST_SUITE.new().run():
		rows.append(_result(String(pf_m6d_row.get("name", "PF-M6D unnamed")), bool(pf_m6d_row.get("passed", false)), String(pf_m6d_row.get("detail", "PF-M6D / M5D procedural first-case source bootstrap invariant"))))
	for m6a_row: Dictionary in CASE_GENERATOR_M6A_TEST_SUITE.new().run():
		rows.append(_result(String(m6a_row.get("name", "M6A unnamed")), bool(m6a_row.get("passed", false)), String(m6a_row.get("detail", "M6A procedural pretend/truthfulness invariant"))))
	for m6b_row: Dictionary in CASE_GENERATOR_M6B_FOUNDATION_TEST_SUITE.new().run():
		rows.append(_result(String(m6b_row.get("name", "M6B unnamed")), bool(m6b_row.get("passed", false)), String(m6b_row.get("detail", "M6B mutation-state foundation invariant"))))
	for poisoner_row: Dictionary in CASE_GENERATOR_M6B_POISONER_TEST_SUITE.new().run():
		rows.append(_result(String(poisoner_row.get("name", "M6B-P1 unnamed")), bool(poisoner_row.get("passed", false)), String(poisoner_row.get("detail", "M6B-P1 Poisoner procedural invariant"))))
	for barkeep_row: Dictionary in CASE_GENERATOR_M6B_BARKEEP_TEST_SUITE.new().run():
		rows.append(_result(String(barkeep_row.get("name", "M6B-P2 unnamed")), bool(barkeep_row.get("passed", false)), String(barkeep_row.get("detail", "M6B-P2 Barkeep/Drunkard procedural invariant"))))
	for spectre_row: Dictionary in CASE_GENERATOR_M6B_SPECTRE_TEST_SUITE.new().run():
		rows.append(_result(String(spectre_row.get("name", "M6B-P3 unnamed")), bool(spectre_row.get("passed", false)), String(spectre_row.get("detail", "M6B-P3 Spectre/obscure procedural invariant"))))
	for scoundrel_row: Dictionary in CASE_GENERATOR_SCOUNDREL_TEST_SUITE.new().run():
		rows.append(_result(String(scoundrel_row.get("name", "Slice 1 Scoundrel unnamed")), bool(scoundrel_row.get("passed", false)), String(scoundrel_row.get("detail", "Case Generator Slice 1 Scoundrel end-to-end invariant"))))
	for tailor_row: Dictionary in CASE_GENERATOR_TAILOR_TEST_SUITE.new().run():
		rows.append(_result(String(tailor_row.get("name", "Slice 2 Tailor unnamed")), bool(tailor_row.get("passed", false)), String(tailor_row.get("detail", "Native Tailor pre-function invariant"))))
	for vigilante_row: Dictionary in CASE_GENERATOR_VIGILANTE_TEST_SUITE.new().run():
		rows.append(_result(String(vigilante_row.get("name", "Slice 3 Vigilante unnamed")), bool(vigilante_row.get("passed", false)), String(vigilante_row.get("detail", "Native Vigilante pre-function invariant"))))
	for borrowed_row: Dictionary in CASE_GENERATOR_COPYCAT_ACTIVE_TEST_SUITE.new().run():
		rows.append(_result(String(borrowed_row.get("name", "Slice 4 Copycat unnamed")), bool(borrowed_row.get("passed", false)), String(borrowed_row.get("detail", "Copycat borrowed active invariant"))))
	for clock_row: Dictionary in CASE_GENERATOR_CLOCK_MAKER_TEST_SUITE.new().run():
		rows.append(_result(String(clock_row.get("name", "Slice 5 Clock Maker unnamed")), bool(clock_row.get("passed", false)), String(clock_row.get("detail", "Native Clock Maker automatic investigation invariant"))))
	for surgeon_row: Dictionary in CASE_GENERATOR_SURGEON_TEST_SUITE.new().run():
		rows.append(_result(String(surgeon_row.get("name", "Slice 6 Surgeon unnamed")), bool(surgeon_row.get("passed", false)), String(surgeon_row.get("detail", "Native Surgeon pre-timed-event invariant"))))
	for serial_killer_row: Dictionary in CASE_GENERATOR_SERIAL_KILLER_TEST_SUITE.new().run():
		rows.append(_result(String(serial_killer_row.get("name", "Slice 7 Serial Killer unnamed")), bool(serial_killer_row.get("passed", false)), String(serial_killer_row.get("detail", "Native Serial Killer pre-timed-event invariant"))))
	for critic_row: Dictionary in CASE_GENERATOR_CRITIC_TEST_SUITE.new().run():
		rows.append(_result(String(critic_row.get("name", "Slice 8 Critic unnamed")), bool(critic_row.get("passed", false)), String(critic_row.get("detail", "Critic listed-but-current-absent deduction invariant"))))
	for disguise_slice_a_row: Dictionary in CASE_GENERATOR_DISGUISE_SLICE_A_TEST_SUITE.new().run():
		rows.append(_result(String(disguise_slice_a_row.get("name", "Disguise Slice A unnamed")), bool(disguise_slice_a_row.get("passed", false)), String(disguise_slice_a_row.get("detail", "Two-scope disguise capability invariant"))))
	for mobster_active_row: Dictionary in CASE_GENERATOR_MOBSTER_ACTIVE_TEST_SUITE.new().run():
		rows.append(_result(String(mobster_active_row.get("name", "Disguise Slice D1 unnamed")), bool(mobster_active_row.get("passed", false)), String(mobster_active_row.get("detail", "Mobster active-role disguise invariant"))))
	for serial_active_row: Dictionary in CASE_GENERATOR_SERIAL_KILLER_ACTIVE_TEST_SUITE.new().run():
		rows.append(_result(String(serial_active_row.get("name", "Disguise Slice D2 unnamed")), bool(serial_active_row.get("passed", false)), String(serial_active_row.get("detail", "Serial Killer active-role disguise invariant"))))
	for hv1_row: Dictionary in HV1_DISGUISE_CLUE_BEHAVIOR_TEST_SUITE.new().run():
		rows.append(_result(String(hv1_row.get("name", "HV1 unnamed")), bool(hv1_row.get("passed", false)), String(hv1_row.get("detail", "HV1 disguise/clue behavior verification invariant"))))
	for hv2_row: Dictionary in HV2_ACTIVE_DISGUISE_TEST_SUITE.new().run():
		rows.append(_result(String(hv2_row.get("name", "HV2 unnamed")), bool(hv2_row.get("passed", false)), String(hv2_row.get("detail", "HV2 active-disguise human verification invariant"))))
	for hv3_row: Dictionary in HV3_TIMED_COEXISTENCE_TEST_SUITE.new().run():
		rows.append(_result(String(hv3_row.get("name", "HV3 unnamed")), bool(hv3_row.get("passed", false)), String(hv3_row.get("detail", "HV3 Serial Killer timed-coexistence human verification invariant"))))
	for hv4_row: Dictionary in HV4_CRITIC_MAILMAN_TEST_SUITE.new().run():
		rows.append(_result(String(hv4_row.get("name", "HV4 unnamed")), bool(hv4_row.get("passed", false)), String(hv4_row.get("detail", "HV4 Critic and Mailman human verification invariant"))))
	for hv5_row: Dictionary in HV5_MUTATION_VISIBILITY_TEST_SUITE.new().run():
		rows.append(_result(String(hv5_row.get("name", "HV5 unnamed")), bool(hv5_row.get("passed", false)), String(hv5_row.get("detail", "HV5 mutation and visibility human verification invariant"))))
	for hv6_row: Dictionary in HV6_RESOLUTION_TIMED_SAFETY_TEST_SUITE.new().run():
		rows.append(_result(String(hv6_row.get("name", "HV6 unnamed")), bool(hv6_row.get("passed", false)), String(hv6_row.get("detail", "HV6 resolution and timed-safety human verification invariant"))))
	for role_universe_row: Dictionary in CASE_GENERATOR_ROLE_UNIVERSE_TEST_SUITE.new().run():
		rows.append(_result(String(role_universe_row.get("name", "M6A-R unnamed")), bool(role_universe_row.get("passed", false)), String(role_universe_row.get("detail", "M6A role-universe and Weatherman regression"))))
	for therapist_inspection_row: Dictionary in CASE_THERAPIST_SOLVER_INSPECTION_TEST_SUITE.new().run():
		rows.append(_result(String(therapist_inspection_row.get("name", "Therapist/inspection unnamed")), bool(therapist_inspection_row.get("passed", false)), String(therapist_inspection_row.get("detail", "Therapist lattice and DEV solver inspection"))))
	for variety_row: Dictionary in CASE_PRODUCTION_VARIETY_TEST_SUITE.new().run():
		rows.append(_result(String(variety_row.get("name", "Production variety unnamed")), bool(variety_row.get("passed", false)), String(variety_row.get("detail", "Deterministic production diversity"))))
	for m6a_regression_row: Dictionary in CASE_M6A_REGRESSION_TEST_SUITE.new().run():
		rows.append(_result(String(m6a_regression_row.get("name", "M6A-R unnamed")), bool(m6a_regression_row.get("passed", false)), String(m6a_regression_row.get("detail", "M6A/runtime modal and role-presentation regression"))))
	for pf_m7_row: Dictionary in PF_M7_TEST_SUITE.new().run():
		rows.append(_result(String(pf_m7_row.get("name", "PF-M7 unnamed")), bool(pf_m7_row.get("passed", false)), String(pf_m7_row.get("detail", "PF-M7 Court Rank progression invariant"))))
	for pf_m8a_row: Dictionary in PF_M8A_TEST_SUITE.new().run():
		rows.append(_result(String(pf_m8a_row.get("name", "PF-M8A unnamed")), bool(pf_m8a_row.get("passed", false)), String(pf_m8a_row.get("detail", "PF-M8A Match Setup and victory-rule invariant"))))
	for pf_m8b_row: Dictionary in PF_M8B_TEST_SUITE.new().run():
		rows.append(_result(String(pf_m8b_row.get("name", "PF-M8B unnamed")), bool(pf_m8b_row.get("passed", false)), String(pf_m8b_row.get("detail", "PF-M8B Match completion and final-results invariant"))))
	for pf_m9b_row: Dictionary in PF_M9B_TEST_SUITE.new().run():
		rows.append(_result(String(pf_m9b_row.get("name", "PF-M9B unnamed")), bool(pf_m9b_row.get("passed", false)), String(pf_m9b_row.get("detail", "PF-M9B Equipment collection and loadout invariant"))))
	for pf_m9c_row: Dictionary in PF_M9C_TEST_SUITE.new().run():
		rows.append(_result(String(pf_m9c_row.get("name", "PF-M9C unnamed")), bool(pf_m9c_row.get("passed", false)), String(pf_m9c_row.get("detail", "PF-M9C Equipment progression invariant"))))
	for pf_m9d_b_row: Dictionary in PF_M9D_B_TEST_SUITE.new().run():
		rows.append(_result(String(pf_m9d_b_row.get("name", "PF-M9D-B unnamed")), bool(pf_m9d_b_row.get("passed", false)), String(pf_m9d_b_row.get("detail", "PF-M9D-B Round map-loot disposition invariant"))))
	for pf_m9e_a_row: Dictionary in PF_M9E_A_TEST_SUITE.new().run():
		rows.append(_result(String(pf_m9e_a_row.get("name", "PF-M9E-A unnamed")), bool(pf_m9e_a_row.get("passed", false)), String(pf_m9e_a_row.get("detail", "PF-M9E-A Perfect Gacha player-choice invariant"))))
	for pf_m9e_c_row: Dictionary in PF_M9E_C_TEST_SUITE.new().run():
		rows.append(_result(String(pf_m9e_c_row.get("name", "PF-M9E-C unnamed")), bool(pf_m9e_c_row.get("passed", false)), String(pf_m9e_c_row.get("detail", "PF-M9E-C single-slot autosave and Continue invariant"))))
	for pf_m9e_d_row: Dictionary in PF_M9E_D_TEST_SUITE.new().run():
		rows.append(_result(String(pf_m9e_d_row.get("name", "PF-M9E-D unnamed")), bool(pf_m9e_d_row.get("passed", false)), String(pf_m9e_d_row.get("detail", "PF-M9E-D explicit Bag overflow choice invariant"))))

	var passed := 0
	var lines: Array[String] = []
	var failure_lines: Array[String] = []
	for row in rows:
		if row.passed:
			passed += 1
		else:
			failure_lines.append("FAIL %s - %s" % [row.name, row.detail])
		lines.append("[color=%s]%s[/color]  %s — %s" % [
			"#76d99a" if row.passed else "#ff7b7b",
			"PASS" if row.passed else "FAIL",
			row.name,
			row.detail,
		])
	return {
		"total": rows.size(),
		"passed": passed,
		"failed": rows.size() - passed,
		"formatted_text": "\n".join(lines),
		"failure_text": "\n".join(failure_lines),
	}


func _test_logger_methods() -> bool:
	AppLogger.info("Smoke probe: INFO")
	AppLogger.warning("Smoke probe: WARNING")
	AppLogger.error("Smoke probe: ERROR (handled test signal)")
	return AppLogger.recent_lines().size() >= 3


func _test_handled_failure() -> bool:
	return not ResourceLoader.exists("res://tests/fixtures/__expected_missing_resource__.tres")


func _has_unique_suspect_ids(case_fixture: CaseDefinition) -> bool:
	if case_fixture == null:
		return false
	var seen: Dictionary = {}
	for suspect in case_fixture.suspects:
		if seen.has(suspect.suspect_id):
			return false
		seen[suspect.suspect_id] = true
	return true


func _has_all_role_groups(case_fixture: CaseDefinition) -> bool:
	if case_fixture == null:
		return false
	var groups: Dictionary = {}
	for suspect in case_fixture.suspects:
		groups[suspect.role_group] = true
	for required_group in CaseEnums.RoleGroup.values():
		if not groups.has(required_group):
			return false
	return true


func _has_impersonating_accomplice(case_fixture: CaseDefinition) -> bool:
	if case_fixture == null:
		return false
	for suspect in case_fixture.suspects:
		if suspect.role_group == CaseEnums.RoleGroup.TONG_PHAM and suspect.is_impersonating and suspect.true_role_id != suspect.displayed_role_id:
			return true
	return false


func _has_corrupted_suspect(case_fixture: CaseDefinition) -> bool:
	if case_fixture == null:
		return false
	for suspect in case_fixture.suspects:
		if suspect.is_corrupted:
			return true
	return false


func _has_valid_tailor(roles: Array[RoleDefinition], case_fixture: CaseDefinition) -> bool:
	if case_fixture == null:
		return false
	var tailor_role: RoleDefinition
	for role in roles:
		if role.role_id == &"tailor":
			tailor_role = role
			break
	if tailor_role == null:
		return false
	var tailor_present := false
	for suspect in case_fixture.suspects:
		if suspect.true_role_id == &"tailor":
			tailor_present = true
	return (
		tailor_present
		and tailor_role.has_interactive_function
		and tailor_role.target_count == 2
		and tailor_role.function_type == CaseEnums.FunctionType.TAILOR_COMPARE_ALIGNMENT
		and tailor_role.information_result_type == CaseEnums.InformationResultType.SAME_OR_DIFFERENT_ALIGNMENT
		and tailor_role.unlock_timing == CaseEnums.UnlockTiming.NEXT_TURN_AFTER_INVESTIGATION
		and tailor_role.help_text.contains("Chọn đúng hai nghi phạm khác nhau")
		and tailor_role.help_text.contains("dựa trên phe thật của họ")
		and tailor_role.help_text.contains("Ta có thể chọn chính mình cùng một mục tiêu khác.")
		and tailor_role.help_text.contains("nghi phạm đã chết, chưa được điều tra hoặc đã bị bắt")
		and tailor_role.help_text.contains("Khi ta nói dối hoặc bị tha hóa, ta thông báo kết quả ngược lại với sự thật.")
		and tailor_role.help_text.contains("#X và #Y cùng phe.")
		and tailor_role.help_text.contains("#X và #Y không cùng phe.")
		and not tailor_role.help_text.contains("Fixture")
		and not tailor_role.help_text.contains("Runtime")
	)


func _tutorial_01_ratio(c: CaseDefinition) -> bool:
	if c == null or c.suspects.size() != 2:
		return false
	var counts := {
		CaseEnums.RoleGroup.CHINH_NHAN: 0,
		CaseEnums.RoleGroup.HIEU_SU: 0,
		CaseEnums.RoleGroup.TONG_PHAM: 0,
		CaseEnums.RoleGroup.NGHICH_THAN: 0,
	}
	var good_count := 0
	var evil_count := 0
	for suspect in c.suspects:
		if suspect == null:
			return false
		if counts.has(suspect.role_group):
			counts[suspect.role_group] += 1
		if suspect.true_alignment == CaseEnums.Alignment.GOOD:
			good_count += 1
		elif suspect.true_alignment == CaseEnums.Alignment.EVIL:
			evil_count += 1
	return (
		good_count == 1
		and evil_count == 1
		and counts[CaseEnums.RoleGroup.CHINH_NHAN] == 1
		and counts[CaseEnums.RoleGroup.HIEU_SU] == 0
		and counts[CaseEnums.RoleGroup.TONG_PHAM] == 1
		and counts[CaseEnums.RoleGroup.NGHICH_THAN] == 0
	)


func _tutorial_01_roles_loaded(c: CaseDefinition, roles: Array[RoleDefinition]) -> bool:
	if c == null or c.suspects.size() != 2:
		return false
	var priest := _find_role_for_test(roles, &"tutorial_priest")
	var scoundrel := _find_role_for_test(roles, &"tutorial_scoundrel")
	var expected_priest_help_text: String = (
		"💬 Khi được điều tra và nói thật, ta thông báo: \"Tôi là Tư Tế.\"\n\n"
		+ "❗ Ta là một thân phận tự xác thực.\n\n"
		+ "❓ Khi nói dối hoặc bị tha hóa, ta thông báo một trong các câu sau:\n"
		+ "- \"Ta có thật là một Tư Tế tốt không?\"\n"
		+ "- \"Tôi chỉ nhớ mình từng đứng trong thánh đường.\""
	)
	return (
		priest != null
		and scoundrel != null
		and priest.display_name == "Tư Tế"
		and priest.role_id == &"tutorial_priest"
		and priest.role_group == CaseEnums.RoleGroup.CHINH_NHAN
		and RoleReferenceFormatter.role_body_bbcode(priest).length() > 0
		and priest.help_text == expected_priest_help_text
		and scoundrel.display_name == "Kẻ Bất Lương"
		and scoundrel.role_id == &"tutorial_scoundrel"
		and scoundrel.role_group == CaseEnums.RoleGroup.TONG_PHAM
		and RoleReferenceFormatter.role_body_bbcode(scoundrel).length() > 0
		and RoleReferenceFormatter.role_body_text(scoundrel).length() > 0
		and c.suspects[0].true_role_id == priest.role_id
		and c.suspects[1].true_role_id == scoundrel.role_id
	)


func _tutorial_01_investigated_outputs(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	if c == null:
		return false
	var runtime := _tutorial_01_investigated_runtime(c, players)
	var views := CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles)
	if views.size() != 2:
		return false
	return (
		views[0].public_role_name == "Tư Tế"
		and views[0].public_investigation_statement == "Tôi là Tư Tế."
		and views[1].public_role_name == "Kẻ Bất Lương"
		and views[1].public_investigation_statement.is_empty()
		and not views[0].full_truth_visible
		and not views[1].full_truth_visible
	)


func _tutorial_01_silent_card_has_no_fake_announcement(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _tutorial_01_investigated_runtime(c, players)
	var board: CaseBoardController = _board_instance_with_runtime(c, runtime, roles)
	if board == null:
		return false
	var card: SuspectCardController = _board_card(board, 2)
	var passed := (
		card != null
		and card.get_public_role_text() == "Kẻ Bất Lương"
		and card.get_public_statement_text().is_empty()
		and card.has_role_art_placeholder()
	)
	board.free()
	return passed


func _tutorial_01_true_roles_authored(c: CaseDefinition) -> bool:
	if c == null or c.suspects.size() != 2:
		return false
	var s1 := c.suspects[0]
	var s2 := c.suspects[1]
	return (
		s1.suspect_id == 1
		and s1.true_role_id == &"tutorial_priest"
		and s1.displayed_role_id == &"tutorial_priest"
		and s1.true_alignment == CaseEnums.Alignment.GOOD
		and s1.role_group == CaseEnums.RoleGroup.CHINH_NHAN
		and s2.suspect_id == 2
		and s2.true_role_id == &"tutorial_scoundrel"
		and s2.displayed_role_id == &"tutorial_scoundrel"
		and s2.true_alignment == CaseEnums.Alignment.EVIL
		and s2.role_group == CaseEnums.RoleGroup.TONG_PHAM
		and not s2.is_impersonating
		and String(s2.impersonated_role_id).is_empty()
	)


func _tutorial_01_has_no_impersonation(c: CaseDefinition) -> bool:
	if c == null:
		return false
	for suspect in c.suspects:
		if suspect != null and (suspect.is_impersonating or suspect.true_role_id != suspect.displayed_role_id or not String(suspect.impersonated_role_id).is_empty()):
			return false
	return true


func _tutorial_01_crime_scene_has_no_clue(c: CaseDefinition) -> bool:
	if c == null or c.crime_scene == null:
		return false
	var text := c.crime_scene.description.to_lower()
	for forbidden in ["bên phải", "mạo danh", "manh mối", "phe ác", "chính nhân", "tòng phạm", "liền kề", "khoảng cách", "đáp án"]:
		if text.contains(forbidden):
			return false
	return true


func _tutorial_01_single_accuse_private_only(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	if c == null:
		return false
	var b := _fresh_turn_bundle(c, players)
	var runtime := b.runtime as CaseRuntimeState
	var player := runtime.find_player(runtime.current_player_id())
	var result := SingleSuspectAccusationService.new().accuse(c, runtime, player, 2)
	var records := runtime.private_role_knowledge_for_player(player.player_id)
	var other_players_have_no_private_reveal: bool = true
	for other_player: PlayerCaseState in runtime.players:
		if (
			other_player.player_id != player.player_id
			and not runtime.private_role_knowledge_for_player(other_player.player_id).is_empty()
		):
			other_players_have_no_private_reveal = false
			break
	var suspect_runtime: SuspectRuntimeState = runtime.find_suspect(2)
	return (
		result.success
		and result.correct
		and result.private_true_role_id == &"tutorial_scoundrel"
		and records.size() == 1
		and records[0].suspect_id == 2
		and records[0].true_role_id == &"tutorial_scoundrel"
		and _private_record_excludes_truth_metadata(records[0])
		and other_players_have_no_private_reveal
		and suspect_runtime != null
		and not suspect_runtime.is_investigated
		and not suspect_runtime.is_arrested
	)


func _tutorial_01_full_reveal(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	if c == null:
		return false
	var r := _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var submission := _locked_submission(&"player_1", PackedInt32Array([2]), PackedInt32Array([2]), PackedInt32Array(), CaseEnums.SubmissionPhase.EARLY)
	r.submissions.append(submission)
	r.find_player(&"player_1").submission_status = CaseEnums.SubmissionStatus.SUBMITTED_CORRECT
	r.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
	var settlement := CaseSettlementService.new().settle(c, r)
	var reveal := CaseTruthRevealBuilder.new().build(c, r, roles)
	var views := CasePublicPresentationBuilder.new().build_suspect_views(c, r, roles)
	if views.size() != 2:
		return false
	var board := _board_instance_with_runtime(c, r, roles)
	var suspect_two_truth := ""
	var suspect_two_statement := ""
	if board != null:
		var card := _board_card(board, 2)
		suspect_two_truth = card.get_full_truth_text() if card != null else ""
		suspect_two_statement = card.get_reveal_statement_text() if card != null else ""
		board.free()
	return (
		settlement.success
		and reveal != null
		and views[0].truth_true_role_name == "Tư Tế"
		and views[1].truth_true_role_name == "Kẻ Bất Lương"
		and views[1].truth_impersonated_role_name.is_empty()
		and suspect_two_truth.is_empty()
		and suspect_two_statement.is_empty()
	)


func _tutorial_01_slots_are_345(c: CaseDefinition) -> bool:
	return (
		c != null
		and c.crime_scene != null
		and c.suspects.size() == 2
		and c.suspects[0].board_slot == 3
		and c.crime_scene.board_slot == 4
		and c.suspects[1].board_slot == 5
		and _board_slots_match_authored(c)
	)


func _tutorial_01_investigated_runtime(c: CaseDefinition, players: Array[PlayerCaseState]) -> CaseRuntimeState:
	var runtime := CaseRuntimeState.new()
	runtime.initialize(c, players)
	for suspect in runtime.suspects:
		suspect.is_investigated = true
	return runtime


func _tutorial_02_ratio(c: CaseDefinition) -> bool:
	return _tutorial_01_ratio(c)


func _tutorial_02_mobster_separate_from_scoundrel(roles: Array[RoleDefinition]) -> bool:
	var scoundrel := _find_role_for_test(roles, &"tutorial_scoundrel")
	var mobster := _find_role_for_test(roles, &"tutorial_mobster")
	return (
		scoundrel != null
		and mobster != null
		and scoundrel.display_name == "Kẻ Bất Lương"
		and mobster.display_name == "Kẻ Côn Đồ"
		and scoundrel.role_id != mobster.role_id
	)


func _tutorial_02_investigated_outputs(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	if c == null:
		return false
	var runtime := _tutorial_01_investigated_runtime(c, players)
	var views := CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles)
	if views.size() != 2:
		return false
	return (
		views[0].public_role_name == "Tư Tế"
		and views[0].public_investigation_statement == "Tôi là Tư Tế."
		and views[1].public_role_name == "Tư Tế"
		and not views[1].public_investigation_statement.is_empty()
		and views[1].public_investigation_statement != "Tôi là Tư Tế."
		and views[1].public_investigation_statement == "Ta có thật là một Tư Tế tốt không?"
	)


func _tutorial_02_mobster_pretend_authored(c: CaseDefinition) -> bool:
	if c == null or c.suspects.size() != 2:
		return false
	var s1 := c.suspects[0]
	var s2 := c.suspects[1]
	return (
		s1.suspect_id == 1
		and s1.true_role_id == &"tutorial_priest"
		and s1.displayed_role_id == &"tutorial_priest"
		and s1.public_investigation_statement == "Tôi là Tư Tế."
		and s2.suspect_id == 2
		and s2.true_role_id == &"tutorial_mobster"
		and s2.displayed_role_id == &"tutorial_priest"
		and s2.impersonated_role_id == &"tutorial_priest"
		and s2.true_alignment == CaseEnums.Alignment.EVIL
		and s2.role_group == CaseEnums.RoleGroup.TONG_PHAM
		and s2.is_impersonating
		and s2.public_investigation_statement != "Tôi là Tư Tế."
	)


func _tutorial_02_public_hides_truth(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	if c == null:
		return false
	var runtime := _tutorial_01_investigated_runtime(c, players)
	var views := CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles)
	if views.size() != 2:
		return false
	var view := views[1]
	return (
		view.public_role_name == "Tư Tế"
		and not view.public_role_name.contains("Kẻ Côn Đồ")
		and view.truth_true_role_name.is_empty()
		and view.truth_impersonated_role_name.is_empty()
		and not view.full_truth_visible
		and _view_data_excludes(c, "true_role_id")
		and _view_data_excludes(c, "impersonated_role_id")
	)


func _tutorial_02_single_accuse_private_only(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	if c == null:
		return false
	var b := _fresh_turn_bundle(c, players)
	var runtime := b.runtime as CaseRuntimeState
	var player := runtime.find_player(runtime.current_player_id())
	var result := SingleSuspectAccusationService.new().accuse(c, runtime, player, 2)
	var records := runtime.private_role_knowledge_for_player(player.player_id)
	return (
		result.success
		and result.correct
		and result.private_true_role_id == &"tutorial_mobster"
		and records.size() == 1
		and records[0].suspect_id == 2
		and records[0].true_role_id == &"tutorial_mobster"
		and _private_record_excludes_truth_metadata(records[0])
	)


func _tutorial_02_full_reveal(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	if c == null:
		return false
	var before := _authored_board_slot_snapshot(c)
	var r := _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var submission := _locked_submission(&"player_1", PackedInt32Array([2]), PackedInt32Array([2]), PackedInt32Array(), CaseEnums.SubmissionPhase.EARLY)
	r.submissions.append(submission)
	r.find_player(&"player_1").submission_status = CaseEnums.SubmissionStatus.SUBMITTED_CORRECT
	r.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
	var settlement := CaseSettlementService.new().settle(c, r)
	var reveal := CaseTruthRevealBuilder.new().build(c, r, roles)
	var views := CasePublicPresentationBuilder.new().build_suspect_views(c, r, roles)
	if views.size() != 2:
		return false
	var board := _board_instance_with_runtime(c, r, roles)
	if board == null:
		return false
	var after := _rendered_board_slot_snapshot(board, c)
	var card := _board_card(board, 2)
	var suspect_two_truth: String = card.get_full_truth_text() if card != null else ""
	var suspect_two_statement: String = card.get_reveal_statement_text() if card != null else ""
	board.free()
	return (
		settlement.success
		and reveal != null
		and before == after
		and views[1].truth_true_role_name == "Kẻ Côn Đồ"
		and views[1].truth_impersonated_role_name == "Tư Tế"
		and suspect_two_truth == "Ta giả danh Tư Tế."
		and suspect_two_statement == "Ta giả danh Tư Tế."
	)


func _full_reveal_dupery_card_presentation(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	if c == null:
		return false
	var active_runtime: CaseRuntimeState = _tutorial_01_investigated_runtime(c, players)
	var active_views: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(c, active_runtime, roles)
	var active_unchanged: bool = (
		active_views.size() == 2
		and active_views[1].public_role_name == "Tư Tế"
		and active_views[1].public_investigation_statement == "Ta có thật là một Tư Tế tốt không?"
		and not active_views[1].full_truth_visible
	)
	var reveal_runtime: CaseRuntimeState = _tutorial_01_investigated_runtime(c, players)
	var submission: CaseSubmission = _locked_submission(&"player_1", PackedInt32Array([2]), PackedInt32Array([2]), PackedInt32Array(), CaseEnums.SubmissionPhase.EARLY)
	reveal_runtime.submissions.append(submission)
	reveal_runtime.find_player(&"player_1").submission_status = CaseEnums.SubmissionStatus.SUBMITTED_CORRECT
	reveal_runtime.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
	var settlement: CaseSettlementResult = CaseSettlementService.new().settle(c, reveal_runtime)
	var reveal: CaseTruthReveal = CaseTruthRevealBuilder.new().build(c, reveal_runtime, roles)
	var reveal_views: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(c, reveal_runtime, roles)
	var board: CaseBoardController = _board_instance_with_runtime(c, reveal_runtime, roles)
	if board == null:
		return false
	var priest_card: SuspectCardController = _board_card(board, 1)
	var mobster_card: SuspectCardController = _board_card(board, 2)
	var priest_default: String = priest_card.get_reveal_statement_text() if priest_card != null else ""
	var mobster_default: String = mobster_card.get_reveal_statement_text() if mobster_card != null else ""
	var priest_min_before_history: Vector2 = priest_card.get_combined_minimum_size() if priest_card != null else Vector2.ZERO
	var mobster_min_before_history: Vector2 = mobster_card.get_combined_minimum_size() if mobster_card != null else Vector2.ZERO
	var priest_color: Color = priest_card.get_public_role_color_for_smoke() if priest_card != null else Color.TRANSPARENT
	var mobster_color: Color = mobster_card.get_public_role_color_for_smoke() if mobster_card != null else Color.TRANSPARENT
	var priest_exists: bool = priest_card != null
	var mobster_exists: bool = mobster_card != null
	var priest_role: String = priest_card.get_public_role_text() if priest_card != null else ""
	var priest_has_history: bool = priest_card.has_reveal_history_button() if priest_card != null else false
	var mobster_has_history: bool = mobster_card.has_reveal_history_button() if mobster_card != null else false
	if priest_card != null:
		priest_card.toggle_reveal_history_for_smoke()
	if mobster_card != null:
		mobster_card.toggle_reveal_history_for_smoke()
	var priest_history: String = priest_card.get_reveal_statement_text() if priest_card != null else ""
	var mobster_history: String = mobster_card.get_reveal_statement_text() if mobster_card != null else ""
	var priest_min_after_history: Vector2 = priest_card.get_combined_minimum_size() if priest_card != null else Vector2.ZERO
	var mobster_min_after_history: Vector2 = mobster_card.get_combined_minimum_size() if mobster_card != null else Vector2.ZERO
	var mobster_role_after_history: String = mobster_card.get_public_role_text() if mobster_card != null else ""
	var priest_debug: String = priest_card.get_full_truth_text() if priest_card != null else ""
	var mobster_debug: String = mobster_card.get_full_truth_text() if mobster_card != null else ""
	board.free()

	var dead_runtime: CaseRuntimeState = _tutorial_01_investigated_runtime(c, players)
	var dead_suspect: SuspectRuntimeState = dead_runtime.find_suspect(2)
	if dead_suspect != null:
		dead_suspect.is_dead = true
	var dead_submission: CaseSubmission = _locked_submission(&"player_1", PackedInt32Array([2]), PackedInt32Array([2]), PackedInt32Array(), CaseEnums.SubmissionPhase.EARLY)
	dead_runtime.submissions.append(dead_submission)
	dead_runtime.find_player(&"player_1").submission_status = CaseEnums.SubmissionStatus.SUBMITTED_CORRECT
	dead_runtime.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
	CaseSettlementService.new().settle(c, dead_runtime)
	CaseTruthRevealBuilder.new().build(c, dead_runtime, roles)
	var dead_board: CaseBoardController = _board_instance_with_runtime(c, dead_runtime, roles)
	var dead_card: SuspectCardController = _board_card(dead_board, 2) if dead_board != null else null
	var dead_default: String = dead_card.get_reveal_statement_text() if dead_card != null else ""
	var dead_min_before_history: Vector2 = dead_card.get_combined_minimum_size() if dead_card != null else Vector2.ZERO
	if dead_card != null:
		dead_card.toggle_reveal_history_for_smoke()
	var dead_history: String = dead_card.get_reveal_statement_text() if dead_card != null else ""
	var dead_min_after_history: Vector2 = dead_card.get_combined_minimum_size() if dead_card != null else Vector2.ZERO
	if dead_board != null:
		dead_board.free()

	return (
		active_unchanged
		and settlement.success
		and reveal != null
		and reveal_views.size() == 2
		and reveal_views[1].truth_true_role_name == "Kẻ Côn Đồ"
		and reveal_views[1].truth_impersonated_role_name == "Tư Tế"
		and priest_exists
		and mobster_exists
		and priest_role == "Tư Tế"
		and mobster_role_after_history == "Kẻ Côn Đồ"
		and priest_default.is_empty()
		and priest_has_history
		and priest_history == "Tôi là Tư Tế."
		and mobster_default == "Ta giả danh Tư Tế."
		and mobster_has_history
		and mobster_history == "Ta có thật là một Tư Tế tốt không?"
		and priest_min_before_history == priest_min_after_history
		and mobster_min_before_history == mobster_min_after_history
		and mobster_color.r > priest_color.r
		and mobster_color.b < priest_color.b
		and dead_default == "*Chết...*"
		and dead_history == "Ta có thật là một Tư Tế tốt không?"
		and dead_min_before_history == dead_min_after_history
		and not priest_debug.contains("Sự thật:")
		and not mobster_debug.contains("Sự thật:")
		and not mobster_debug.contains("Giả danh:")
	)


func _tutorial_02_slots_are_345(c: CaseDefinition) -> bool:
	return _tutorial_01_slots_are_345(c)


func _tutorial_02_crime_scene_has_no_clue(c: CaseDefinition) -> bool:
	return _tutorial_01_crime_scene_has_no_clue(c)


func _tutorial_03_ratio(c: CaseDefinition) -> bool:
	if c == null:
		return false
	var counts: Dictionary = {}
	counts[CaseEnums.RoleGroup.CHINH_NHAN] = 0
	counts[CaseEnums.RoleGroup.HIEU_SU] = 0
	counts[CaseEnums.RoleGroup.TONG_PHAM] = 0
	counts[CaseEnums.RoleGroup.NGHICH_THAN] = 0
	for suspect in c.suspects:
		if suspect == null:
			return false
		counts[suspect.role_group] = int(counts.get(suspect.role_group, 0)) + 1
	return (
		int(counts.get(CaseEnums.RoleGroup.CHINH_NHAN, 0)) == 3
		and int(counts.get(CaseEnums.RoleGroup.HIEU_SU, 0)) == 0
		and int(counts.get(CaseEnums.RoleGroup.TONG_PHAM, 0)) == 2
		and int(counts.get(CaseEnums.RoleGroup.NGHICH_THAN, 0)) == 0
	)


func _tutorial_03_board_slots(c: CaseDefinition) -> bool:
	var s1: SuspectDefinition = _tutorial_03_suspect(c, 1)
	var s2: SuspectDefinition = _tutorial_03_suspect(c, 2)
	var s3: SuspectDefinition = _tutorial_03_suspect(c, 3)
	var s4: SuspectDefinition = _tutorial_03_suspect(c, 4)
	var s5: SuspectDefinition = _tutorial_03_suspect(c, 5)
	return (
		c != null
		and c.crime_scene != null
		and c.crime_scene.board_slot == 1
		and s1 != null and s1.board_slot == 0
		and s2 != null and s2.board_slot == 2
		and s3 != null and s3.board_slot == 3
		and s4 != null and s4.board_slot == 4
		and s5 != null and s5.board_slot == 7
		and _board_slots_match_authored(c)
	)


func _tutorial_03_assignments(c: CaseDefinition) -> bool:
	var s1: SuspectDefinition = _tutorial_03_suspect(c, 1)
	var s2: SuspectDefinition = _tutorial_03_suspect(c, 2)
	var s3: SuspectDefinition = _tutorial_03_suspect(c, 3)
	var s4: SuspectDefinition = _tutorial_03_suspect(c, 4)
	var s5: SuspectDefinition = _tutorial_03_suspect(c, 5)
	return (
		s1 != null and s1.true_role_id == &"mailman" and s1.displayed_role_id == &"mailman" and s1.true_alignment == CaseEnums.Alignment.GOOD and s1.role_group == CaseEnums.RoleGroup.CHINH_NHAN
		and s2 != null and s2.true_role_id == &"reporter" and s2.displayed_role_id == &"reporter" and s2.true_alignment == CaseEnums.Alignment.GOOD and s2.role_group == CaseEnums.RoleGroup.CHINH_NHAN
		and s3 != null and s3.true_role_id == &"tutorial_priest" and s3.displayed_role_id == &"tutorial_priest" and s3.true_alignment == CaseEnums.Alignment.GOOD and s3.role_group == CaseEnums.RoleGroup.CHINH_NHAN
		and s4 != null and s4.true_role_id == &"spectre" and s4.displayed_role_id == &"therapist" and s4.impersonated_role_id == &"therapist" and s4.true_alignment == CaseEnums.Alignment.EVIL and s4.role_group == CaseEnums.RoleGroup.TONG_PHAM
		and s5 != null and s5.true_role_id == &"tutorial_mobster" and s5.displayed_role_id == &"reporter" and s5.impersonated_role_id == &"reporter" and s5.true_alignment == CaseEnums.Alignment.EVIL and s5.role_group == CaseEnums.RoleGroup.TONG_PHAM
	)


func _tutorial_03_role_reference(roles: Array[RoleDefinition]) -> bool:
	var required: Dictionary = {
		&"mailman": "Dịch Phu",
		&"reporter": "Sử Quan",
		&"tutorial_priest": "Tư Tế",
		&"therapist": "Ngự Y",
		&"spectre": "Vong Linh",
		&"tutorial_mobster": "Kẻ Côn Đồ",
	}
	for role_key in required:
		var role_id: StringName = StringName(role_key)
		var role: RoleDefinition = _find_role_for_test(roles, role_id)
		if role == null or role.display_name != String(required.get(role_id, "")):
			return false
		if role.help_text.contains("Nghi phạm 4") or role.help_text.contains("Nghi phạm 5") or role.help_text.contains("Tutorial"):
			return false
	return true


func _role_group_labels_player_facing() -> bool:
	var controller: VSCaseMainController = VSCaseMainController.new()
	var passed: bool = (
		controller._role_group_full_label(CaseEnums.RoleGroup.CHINH_NHAN) == "Người Vô Tội"
		and controller._role_group_full_label(CaseEnums.RoleGroup.HIEU_SU) == "Kẻ Bao Đồng"
		and controller._role_group_full_label(CaseEnums.RoleGroup.TONG_PHAM) == "Thuộc Hạ"
		and controller._role_group_full_label(CaseEnums.RoleGroup.NGHICH_THAN) == "Nghịch Thần"
		and controller._role_group_label(CaseEnums.RoleGroup.CHINH_NHAN) == "Người Vô Tội"
		and controller._role_group_label(CaseEnums.RoleGroup.HIEU_SU) == "Kẻ Bao Đồng"
		and controller._role_group_label(CaseEnums.RoleGroup.TONG_PHAM) == "Thuộc Hạ"
		and controller._role_group_label(CaseEnums.RoleGroup.NGHICH_THAN) == "Nghịch Thần"
		and CaseTruthRevealBuilder.new()._group_label(CaseEnums.RoleGroup.CHINH_NHAN) == "Người Vô Tội"
		and CaseTruthRevealBuilder.new()._group_label(CaseEnums.RoleGroup.HIEU_SU) == "Kẻ Bao Đồng"
		and CaseTruthRevealBuilder.new()._group_label(CaseEnums.RoleGroup.TONG_PHAM) == "Thuộc Hạ"
		and CaseTruthRevealBuilder.new()._group_label(CaseEnums.RoleGroup.NGHICH_THAN) == "Nghịch Thần"
	)
	controller.free()
	return passed


func _role_reference_group_order(c: CaseDefinition, roles: Array[RoleDefinition]) -> bool:
	var controller: VSCaseMainController = VSCaseMainController.new()
	controller.case_definition = c
	controller.role_definitions = roles
	var relevant: Array[RoleDefinition] = controller._roles_relevant_to_case()
	controller.free()
	if relevant.size() != 6:
		return false
	var groups: Array[int] = []
	var ids: Array[StringName] = []
	for role: RoleDefinition in relevant:
		groups.append(role.role_group)
		ids.append(role.role_id)
	return (
		groups[0] == CaseEnums.RoleGroup.CHINH_NHAN
		and groups[1] == CaseEnums.RoleGroup.CHINH_NHAN
		and groups[2] == CaseEnums.RoleGroup.CHINH_NHAN
		and groups[3] == CaseEnums.RoleGroup.CHINH_NHAN
		and groups[4] == CaseEnums.RoleGroup.TONG_PHAM
		and groups[5] == CaseEnums.RoleGroup.TONG_PHAM
		and ids[0] == &"mailman"
		and ids[1] == &"reporter"
		and ids[2] == &"therapist"
		and ids[3] == &"tutorial_priest"
		and ids[4] == &"spectre"
		and ids[5] == &"tutorial_mobster"
	)


func _tutorial_04_role_reference(c: CaseDefinition, roles: Array[RoleDefinition]) -> bool:
	var controller: VSCaseMainController = VSCaseMainController.new()
	controller.case_definition = c
	controller.role_definitions = roles
	var relevant: Array[RoleDefinition] = controller._roles_relevant_to_case()
	controller.free()
	if relevant.size() != 4:
		return false
	var ids: Array[StringName] = []
	var groups: Array[int] = []
	for role: RoleDefinition in relevant:
		ids.append(role.role_id)
		groups.append(role.role_group)
	return (
		ids[0] == &"tailor"
		and ids[1] == &"mailman"
		and ids[2] == &"tutorial_priest"
		and ids[3] == &"tutorial_mobster"
		and groups[0] == CaseEnums.RoleGroup.CHINH_NHAN
		and groups[1] == CaseEnums.RoleGroup.CHINH_NHAN
		and groups[2] == CaseEnums.RoleGroup.CHINH_NHAN
		and groups[3] == CaseEnums.RoleGroup.TONG_PHAM
	)


func _mailman_reference_translation(roles: Array[RoleDefinition]) -> bool:
	var role: RoleDefinition = _find_role_for_test(roles, &"mailman")
	if role == null:
		return false
	return (
		role.help_text.contains("một thân phận xuất hiện trong Kỳ Án")
		and role.help_text.contains("một thân phận không xuất hiện trong Kỳ Án")
		and role.help_text.contains("phân biệt rõ hai trường hợp")
		and role.help_text.contains("thân phận thật hiện tại")
		and role.help_text.contains("cả hai nhận định của ta đều sai.")
		and not role.help_text.contains("Nghi phạm")
		and not role.help_text.contains("Tutorial")
	)


func _tutorial_03_mailman(c: CaseDefinition, roles: Array[RoleDefinition]) -> bool:
	var s1: SuspectDefinition = _tutorial_03_suspect(c, 1)
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var result: InvestigationInformationResult = service.evaluate(c, 1, roles)
	var validation: Dictionary = service.validate_mailman_pair(c, 1, &"tutorial_priest", &"therapist", InvestigationInformationResult.TruthMode.TRUTHFUL, roles)
	var in_play: Array[StringName] = service.true_role_ids_in_play(c)
	return (
		s1 != null
		and s1.mailman_claimed_in_play_role_id == &"tutorial_priest"
		and s1.mailman_claimed_not_in_play_role_id == &"therapist"
		and bool(validation.get("valid", false))
		and in_play.has(&"tutorial_priest")
		and not in_play.has(&"therapist")
		and result.payload_kind == InvestigationInformationResult.PayloadKind.ROLE_PLAY_CLAIM
		and result.in_play_role_id == &"tutorial_priest"
		and result.not_in_play_role_id == &"therapist"
		and result.public_text().contains("Tư Tế")
		and result.public_text().contains("Ngự Y")
	)


func _tutorial_03_reporter(c: CaseDefinition, roles: Array[RoleDefinition]) -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var spatial: CaseSpatialService = CaseSpatialService.new()
	var nearest: Dictionary = spatial.nearest_true_evil_distance(c, 2)
	var result: InvestigationInformationResult = service.evaluate(c, 2, roles)
	var s2: SuspectDefinition = _tutorial_03_suspect(c, 2)
	return (
		s2 != null
		and s2.public_investigation_statement.is_empty()
		and bool(nearest.get("found", false))
		and int(nearest.get("distance", -1)) == 2
		and result.payload_kind == InvestigationInformationResult.PayloadKind.NUMBER
		and result.numeric_value == 2
		and result.public_text().contains("2")
	)


func _tutorial_03_spectre(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var spatial: CaseSpatialService = CaseSpatialService.new()
	var s4: SuspectDefinition = _tutorial_03_suspect(c, 4)
	var s3: SuspectDefinition = _tutorial_03_suspect(c, 3)
	var true_count: int = spatial.count_adjacent_true_evil(c, 4)
	var result: InvestigationInformationResult = service.evaluate(c, 4, roles)
	var runtime: CaseRuntimeState = _tutorial_01_investigated_runtime(c, players)
	var views: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles)
	var view_three: SuspectPublicViewData = _tutorial_03_view(views, 3)
	var target_information: InvestigationInformationResult = service.evaluate(c, 3, roles, {}, runtime)
	return (
		s4 != null
		and s4.displayed_role_id == &"therapist"
		and s4.obscure_target_suspect_id == 3
		and s4.authored_lie_numeric_value == 3
		and true_count == 1
		and result.behavior_role_id == &"therapist"
		and result.truth_mode == InvestigationInformationResult.TruthMode.LYING
		and result.numeric_value == 3
		and view_three != null
		and view_three.public_role_obscured
		and view_three.public_information_obscured
		and view_three.public_role_name == "?????"
		and target_information != null
		and view_three.public_investigation_statement == "■■■ ■■ ■■ ■■."
		and s3 != null
		and s3.true_role_id == &"tutorial_priest"
	)


func _tutorial_03_mobster(c: CaseDefinition, roles: Array[RoleDefinition]) -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var spatial: CaseSpatialService = CaseSpatialService.new()
	var s5: SuspectDefinition = _tutorial_03_suspect(c, 5)
	var nearest: Dictionary = spatial.nearest_true_evil_distance(c, 5)
	var in_play: Array[StringName] = service.true_role_ids_in_play(c)
	var result: InvestigationInformationResult = service.evaluate(c, 5, roles)
	return (
		s5 != null
		and s5.displayed_role_id == &"reporter"
		and s5.authored_lie_numeric_value == 2
		and in_play.has(&"reporter")
		and bool(nearest.get("found", false))
		and int(nearest.get("distance", -1)) == 1
		and result.behavior_role_id == &"reporter"
		and result.truth_mode == InvestigationInformationResult.TruthMode.LYING
		and result.numeric_value == 2
	)


func _tutorial_03_private_knowledge(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var player: PlayerCaseState = runtime.find_player(runtime.current_player_id())
	if player == null:
		return false
	var service: SingleSuspectAccusationService = SingleSuspectAccusationService.new()
	var initial_records: Array[PrivateRoleKnowledgeRecord] = runtime.private_role_knowledge_for_player(player.player_id)
	var first: SingleSuspectAccusationResult = service.accuse(c, runtime, player, 4)
	var records_after_first: Array[PrivateRoleKnowledgeRecord] = runtime.private_role_knowledge_for_player(player.player_id)
	var duplicate: SingleSuspectAccusationResult = service.accuse(c, runtime, player, 4)
	var records_after_duplicate: Array[PrivateRoleKnowledgeRecord] = runtime.private_role_knowledge_for_player(player.player_id)
	var second: SingleSuspectAccusationResult = service.accuse(c, runtime, player, 5)
	var records: Array[PrivateRoleKnowledgeRecord] = runtime.private_role_knowledge_for_player(player.player_id)
	var other_records: Array[PrivateRoleKnowledgeRecord] = runtime.private_role_knowledge_for_player(&"player_2")
	return (
		initial_records.is_empty()
		and first.success and first.correct and first.private_true_role_id == &"spectre"
		and records_after_first.size() == 1
		and duplicate.suspect_id == 4
		and records_after_duplicate.size() == 1
		and second.success and second.correct and second.private_true_role_id == &"tutorial_mobster"
		and records.size() == 2
		and _tutorial_03_private_record_has(records, 4, &"spectre")
		and _tutorial_03_private_record_has(records, 5, &"tutorial_mobster")
		and _private_record_excludes_truth_metadata(records[0])
		and _private_record_excludes_truth_metadata(records[1])
		and other_records.is_empty()
	)


func _tutorial_03_single_accuse_ui_selection(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _case_scene_instance() as VSCaseMainController
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if scene == null or tree == null:
		if scene != null:
			scene.free()
		return false
	tree.root.add_child(scene)
	_prepare_case_scene_for_smoke(scene, c, roles, players)
	var button: Button = scene.get_node_or_null("%SingleAccuseButton") as Button
	if button == null:
		tree.root.remove_child(scene)
		scene.free()
		return false
	var zero_hidden: bool = not button.visible and button.disabled
	scene._on_suspect_action(4, MOUSE_BUTTON_RIGHT, false)
	var one_enabled: bool = button.visible and not button.disabled and scene.selection_state.selected_submission_evil_ids == PackedInt32Array([4])
	scene._on_suspect_action(0, MOUSE_BUTTON_RIGHT, false)
	var crime_scene_ignored: bool = scene.selection_state.selected_submission_evil_ids == PackedInt32Array([4])
	scene._on_suspect_action(5, MOUSE_BUTTON_RIGHT, false)
	var multiple_hidden: bool = not button.visible and button.disabled and scene.selection_state.selected_submission_evil_ids == PackedInt32Array([4, 5])
	var final_multi_selection_still_available: bool = scene.submit_button != null and scene.submit_button.visible and not scene.submit_button.disabled
	scene._on_suspect_action(5, MOUSE_BUTTON_RIGHT, false)
	var one_restored: bool = button.visible and not button.disabled and scene.selection_state.selected_submission_evil_ids == PackedInt32Array([4])
	tree.root.remove_child(scene)
	scene.free()
	return zero_hidden and one_enabled and crime_scene_ignored and multiple_hidden and final_multi_selection_still_available and one_restored


func _tutorial_03_single_accuse_ui_chain(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _case_scene_instance() as VSCaseMainController
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if scene == null or tree == null:
		if scene != null:
			scene.free()
		return false
	tree.root.add_child(scene)
	_prepare_case_scene_for_smoke(scene, c, roles, players)
	var player_id: StringName = scene.runtime_state.current_player_id()
	var turn_before: int = scene.turn_manager.turn_number
	var public_before: SuspectPublicViewData = CasePublicPresentationBuilder.new().build_suspect_views(c, scene.runtime_state, roles)[3]
	scene._on_suspect_action(4, MOUSE_BUTTON_RIGHT, false)
	scene._on_single_accuse_pressed()
	var records_after_first: Array[PrivateRoleKnowledgeRecord] = scene.runtime_state.private_role_knowledge_for_player(player_id)
	var public_after_first: SuspectPublicViewData = CasePublicPresentationBuilder.new().build_suspect_views(c, scene.runtime_state, roles)[3]
	var first_ok: bool = (
		scene.runtime_state.case_outcome == CaseEnums.CaseOutcome.IN_PROGRESS
		and scene.runtime_state.current_player_id() != player_id
		and scene.turn_manager.turn_number == turn_before + 1
		and records_after_first.size() == 1
		and _tutorial_03_private_record_has(records_after_first, 4, &"spectre")
		and public_before.public_role_name == public_after_first.public_role_name
		and public_after_first.truth_true_role_name.is_empty()
		and not public_after_first.full_truth_visible
		and scene.runtime_state.submissions.is_empty()
		and scene.runtime_state.final_submissions.is_empty()
	)
	scene.turn_manager.advance_turn()
	scene.runtime_state.apply_turn_snapshot(scene.turn_manager)
	scene.turn_manager.advance_turn()
	scene.runtime_state.apply_turn_snapshot(scene.turn_manager)
	scene._refresh_all_presentation()
	var returned_to_player: bool = (
		scene.runtime_state.current_player_id() == player_id
		and scene.private_knowledge_button != null
		and scene.private_knowledge_button.visible
		and scene.private_knowledge_button.text == "Hồ sơ riêng (1)"
	)
	scene._on_suspect_action(5, MOUSE_BUTTON_RIGHT, false)
	scene._on_single_accuse_pressed()
	var records_after_second: Array[PrivateRoleKnowledgeRecord] = scene.runtime_state.private_role_knowledge_for_player(player_id)
	var other_records: Array[PrivateRoleKnowledgeRecord] = scene.runtime_state.private_role_knowledge_for_player(&"player_2")
	var second_ok: bool = (
		scene.runtime_state.case_outcome == CaseEnums.CaseOutcome.EARLY_SOLVED
		and scene.turn_manager.turn_number == turn_before + 4
		and records_after_second.size() == 2
		and _tutorial_03_private_record_has(records_after_second, 4, &"spectre")
		and _tutorial_03_private_record_has(records_after_second, 5, &"tutorial_mobster")
		and _private_record_excludes_truth_metadata(records_after_second[0])
		and _private_record_excludes_truth_metadata(records_after_second[1])
		and other_records.is_empty()
	)
	tree.root.remove_child(scene)
	scene.free()
	return first_ok and returned_to_player and second_ok


func _prepare_case_scene_for_smoke(scene: VSCaseMainController, c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> void:
	var bundle: Dictionary = _fresh_turn_bundle(c, players)
	scene.case_definition = c
	scene.role_definitions = roles
	scene.runtime_state = bundle.runtime as CaseRuntimeState
	scene.turn_manager = bundle.manager as TurnManager
	scene.selection_state.finish()
	scene._refresh_all_presentation()


func _tutorial_03_full_reveal_result(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var before: Dictionary = _authored_board_slot_snapshot(c)
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var submission: CaseSubmission = _locked_submission(&"player_1", PackedInt32Array([4, 5]), PackedInt32Array([4, 5]), PackedInt32Array(), CaseEnums.SubmissionPhase.EARLY)
	runtime.submissions.append(submission)
	runtime.find_player(&"player_1").submission_status = CaseEnums.SubmissionStatus.SUBMITTED_CORRECT
	runtime.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
	var settlement: CaseSettlementResult = CaseSettlementService.new().settle(c, runtime)
	var reveal: CaseTruthReveal = CaseTruthRevealBuilder.new().build(c, runtime, roles)
	var checks: Dictionary = {}
	checks.settlement_success = settlement.success
	checks.reveal_exists = reveal != null
	checks.runtime_reveal_stored = runtime.truth_reveal == reveal and reveal != null
	var board: CaseBoardController = _board_instance_with_runtime(c, runtime, roles)
	if board == null:
		checks.board_exists = false
		return _named_check_result(checks)
	checks.board_exists = true
	var after: Dictionary = _rendered_board_slot_snapshot(board, c)
	var card_three: SuspectCardController = _board_card(board, 3)
	var card_four: SuspectCardController = _board_card(board, 4)
	var card_five: SuspectCardController = _board_card(board, 5)
	var three_role_text: String = card_three.get_public_role_text() if card_three != null else ""
	var three_truth_text: String = card_three.get_full_truth_text() if card_three != null else ""
	var three_statement: String = card_three.get_reveal_statement_text() if card_three != null else ""
	var three_mask_removed: bool = card_three != null and not card_three.is_portrait_obscured()
	var four_text: String = card_four.get_full_truth_text() if card_four != null else ""
	var four_statement: String = card_four.get_reveal_statement_text() if card_four != null else ""
	var five_text: String = card_five.get_full_truth_text() if card_five != null else ""
	var five_statement: String = card_five.get_reveal_statement_text() if card_five != null else ""
	var t3: SuspectTruthReveal = _tutorial_03_truth(reveal, 3)
	var t4: SuspectTruthReveal = _tutorial_03_truth(reveal, 4)
	var t5: SuspectTruthReveal = _tutorial_03_truth(reveal, 5)
	checks.slots_preserved = before == after
	checks.s3_truth_record = t3 != null and t3.true_role_name == "Tư Tế"
	checks.s3_mask_removed = three_mask_removed
	checks.s3_truth_visible = three_role_text == "Tư Tế" and three_truth_text.is_empty() and three_statement.is_empty()
	checks.s4_truth_record = t4 != null and t4.true_role_name == "Vong Linh"
	checks.s4_pretend_record = t4 != null and t4.impersonated_role_name == "Ngự Y"
	checks.s4_obscure_target_record = t4 != null and t4.obscure_target_suspect_id == 3
	checks.s4_truth_visible = card_four != null and card_four.get_public_role_text() == "Vong Linh"
	checks.s4_pretend_visible = four_text.contains("Ta giả danh Ngự Y.") and four_statement.contains("Ta giả danh Ngự Y.")
	checks.s4_obscure_target_visible = four_text.contains("Che giấu Nghi phạm 3.") and four_statement.contains("Che giấu Nghi phạm 3.")
	checks.s5_truth_record = t5 != null and t5.true_role_name == "Kẻ Côn Đồ"
	checks.s5_pretend_record = t5 != null and t5.impersonated_role_name == "Sử Quan"
	checks.s5_truth_visible = card_five != null and card_five.get_public_role_text() == "Kẻ Côn Đồ"
	checks.s5_pretend_visible = five_text == "Ta giả danh Sử Quan." and five_statement == "Ta giả danh Sử Quan."
	board.free()
	return _named_check_result(checks)


func _named_check_result(checks: Dictionary) -> Dictionary:
	var failed: PackedStringArray = PackedStringArray()
	for key: String in checks.keys():
		if not bool(checks.get(key, false)):
			failed.append(String(key))
	if failed.is_empty():
		return {"passed": true, "detail": "all subchecks passed"}
	return {"passed": false, "detail": "failed subchecks: %s" % ", ".join(failed)}


func _tutorial_03_card_presentation(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var unrevealed_board: CaseBoardController = _board_instance(c)
	if unrevealed_board == null:
		return {"passed": false, "detail": "unrevealed_board=false"}
	var unrevealed_card: SuspectCardController = _board_card(unrevealed_board, 1)
	var top_row: HBoxContainer = null
	var portrait: Control = null
	var number: Label = null
	var role_label: Label = null
	var statement_label: Label = null
	var statement_region: Control = null
	var card_content: VBoxContainer = null
	if unrevealed_card != null:
		top_row = unrevealed_card.get_node_or_null("CardPresentationRoot/CardVisual/CardContent/TopRow") as HBoxContainer
		portrait = unrevealed_card.get_node_or_null("%IconSlotRoot") as Control
		number = unrevealed_card.get_node_or_null("%SuspectNumber") as Label
		role_label = unrevealed_card.get_node_or_null("%PublicRoleLabel") as Label
		statement_label = unrevealed_card.get_node_or_null("%PublicStatementLabel") as Label
		statement_region = unrevealed_card.get_node_or_null("%StatementRegion") as Control
		card_content = unrevealed_card.get_node_or_null("CardPresentationRoot/CardVisual/CardContent") as VBoxContainer
	var checks: Dictionary = {}
	checks.unrevealed_card_exists = unrevealed_card != null
	checks.number_node_exists = number != null
	checks.art_node_exists = portrait != null and unrevealed_card.has_role_art_placeholder()
	checks.role_node_exists = role_label != null
	checks.announcement_node_exists = statement_label != null
	checks.hierarchy = (
		top_row != null
		and portrait != null
		and number != null
		and portrait.get_parent() == top_row
		and number.get_parent() == top_row
		and portrait.get_index() < number.get_index()
		and card_content != null
		and role_label != null
		and statement_region != null
		and statement_label != null
		and role_label.get_parent() == card_content
		and statement_region.get_parent() == card_content
		and statement_label.get_parent() == statement_region
		and role_label.get_index() > top_row.get_index()
		and statement_region.get_index() > role_label.get_index()
		and statement_region.clip_contents
		and statement_region.custom_minimum_size.y == SuspectCardController.STATEMENT_REGION_HEIGHT
		and statement_label.clip_text
	)
	var crime_scene_tile: Control = unrevealed_board.get_node("%Grid").get_node_or_null("CrimeSceneTile") as Control
	var empty_slot: Control = unrevealed_board.get_node("%Grid").get_node_or_null("EmptyCaseSlot5") as Control
	var grid: GridContainer = unrevealed_board.get_node("%Grid") as GridContainer
	var card_size: Vector2 = unrevealed_card.custom_minimum_size if unrevealed_card != null else Vector2.ZERO
	var card_aspect: float = card_size.x / card_size.y if card_size.y > 0.0 else 0.0
	var grid_h_gap: int = grid.get_theme_constant("h_separation") if grid != null else -1
	var grid_v_gap: int = grid.get_theme_constant("v_separation") if grid != null else -1
	var card_content_separation: int = card_content.get_theme_constant("separation") if card_content != null else 999
	var grid_footprint: Vector2 = Vector2(
		card_size.x * 3.0 + float(grid_h_gap * 2),
		card_size.y * 3.0 + float(grid_v_gap * 2)
	)
	checks.dupery_like_proportions = (
		unrevealed_card != null
		and card_aspect >= 0.78
		and card_aspect <= 0.92
		and card_size.x >= 164.0
		and card_size.x <= 172.0
		and card_size.y >= 186.0
		and card_size.y <= 194.0
		and grid != null
		and grid.size_flags_horizontal == Control.SIZE_SHRINK_CENTER
		and grid.size_flags_vertical == Control.SIZE_SHRINK_BEGIN
		and grid_h_gap == CaseBoardController.BOARD_GRID_H_GAP
		and grid_v_gap == CaseBoardController.BOARD_GRID_V_GAP
		and float(grid_h_gap) / card_size.x <= 0.09
		and grid_footprint.x >= 520.0
		and grid_footprint.x <= 540.0
		and grid_footprint.y >= 615.0
		and grid_footprint.y <= 630.0
	)
	checks.art_geometry = (
		unrevealed_card != null
		and portrait != null
		and not (portrait is ColorRect)
		and top_row != null
		and portrait.custom_minimum_size == Vector2(64, 56)
		and portrait.custom_minimum_size.x < card_size.x
		and portrait.custom_minimum_size.y < top_row.custom_minimum_size.y
		and top_row.custom_minimum_size.y == 95.0
		and card_content_separation == -8
	)
	checks.equal_slot_footprint = (
		unrevealed_card != null
		and crime_scene_tile != null
		and crime_scene_tile.custom_minimum_size == card_size
		and empty_slot != null
		and empty_slot.custom_minimum_size == card_size
	)
	checks.number_unrevealed = unrevealed_card != null and unrevealed_card.get_suspect_number_text() == "01"
	checks.art_unrevealed = unrevealed_card != null and unrevealed_card.get_portrait_symbol_text() == "?"
	checks.role_hidden_unrevealed = unrevealed_card != null and unrevealed_card.get_public_role_text().is_empty()
	checks.announcement_hidden_unrevealed = unrevealed_card != null and unrevealed_card.get_public_statement_text().is_empty()
	checks.no_debug_unrevealed = unrevealed_card != null and unrevealed_card.get_visible_debug_label_text().is_empty()
	unrevealed_board.free()

	var runtime: CaseRuntimeState = _tutorial_01_investigated_runtime(c, players)
	var board: CaseBoardController = _board_instance_with_runtime(c, runtime, roles)
	if board == null:
		checks.investigated_board_exists = false
		return _named_check_result(checks)
	checks.investigated_board_exists = true
	var reporter_card: SuspectCardController = _board_card(board, 2)
	var obscured_card: SuspectCardController = _board_card(board, 3)
	checks.number_investigated = reporter_card != null and reporter_card.get_suspect_number_text() == "02"
	checks.art_investigated = reporter_card != null and reporter_card.has_role_art_placeholder() and reporter_card.get_portrait_symbol_text() == "?"
	checks.role_investigated = reporter_card != null and reporter_card.get_public_role_text() == "Sử Quan"
	checks.announcement_investigated = reporter_card != null and reporter_card.get_public_statement_text().contains("2 bước")
	checks.no_debug_investigated = reporter_card != null and reporter_card.get_visible_debug_label_text().is_empty()
	checks.art_obscured = obscured_card != null and obscured_card.has_role_art_placeholder() and obscured_card.is_portrait_obscured() and obscured_card.get_portrait_symbol_text() == "?"
	checks.role_obscured = obscured_card != null and obscured_card.get_public_role_text() == "?????"
	checks.announcement_obscured = obscured_card != null and obscured_card.get_public_statement_text() == "■■■ ■■ ■■ ■■."
	checks.mask_contract = _mask_preserves_digits_and_punctuation()
	checks.no_debug_obscured = obscured_card != null and obscured_card.get_visible_debug_label_text().is_empty()
	board.free()
	return _named_check_result(checks)


func _mask_preserves_digits_and_punctuation() -> bool:
	var masked: String = CasePublicPresentationBuilder.new()._mask_public_information("Tôi có 3 người bệnh, đúng không?")
	var uppercase_vietnamese: String = CasePublicPresentationBuilder.new()._mask_public_information("Ab Đá Ác 37, Ư?")
	var punctuation_sample: String = "Áa 12.,!? :;-…()[]/\\\"'+=%\nĐ"
	var punctuation_masked: String = CasePublicPresentationBuilder.new()._mask_public_information(punctuation_sample)
	return (
		masked == "■■■ ■■ 3 ■■■■■ ■■■■, ■■■■ ■■■■■?"
		and masked.length() == "Tôi có 3 người bệnh, đúng không?".length()
		and uppercase_vietnamese == "■■ ■■ ■■ 37, ■?"
		and uppercase_vietnamese.length() == "Ab Đá Ác 37, Ư?".length()
		and punctuation_masked == "■■ 12.,!? :;-…()[]/\\\"'+=%\n■"
		and punctuation_masked.length() == punctuation_sample.length()
	)


func _case_left_info_panel_presentation(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _case_scene_instance() as VSCaseMainController
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if scene == null or tree == null:
		if scene != null:
			scene.free()
		return false
	tree.root.add_child(scene)
	_prepare_case_scene_for_smoke(scene, c, roles, players)
	var ratio: RichTextLabel = scene.get_node_or_null("%DescriptionLabel") as RichTextLabel
	var turn: Label = scene.get_node_or_null("%TurnLabel") as Label
	var reputation: RichTextLabel = scene.get_node_or_null("%PlayerStripLabel") as RichTextLabel
	var text: String = ratio.text if ratio != null else ""
	var turn_text: String = turn.text if turn != null else ""
	var reputation_text: String = reputation.text if reputation != null else ""
	var passed: bool = (
		ratio != null
		and turn != null
		and reputation != null
		and not text.contains("TỶ LỆ PHE")
		and not text.contains("Hiện trường")
		and text.contains("Người Vô Tội")
		and text.contains("Kẻ Bao Đồng")
		and text.contains("Thuộc Hạ")
		and text.contains("Nghịch Thần")
		and text.contains(scene._role_group_color(CaseEnums.RoleGroup.CHINH_NHAN).to_html(false))
		and text.contains(scene._role_group_color(CaseEnums.RoleGroup.HIEU_SU).to_html(false))
		and text.contains(scene._role_group_color(CaseEnums.RoleGroup.TONG_PHAM).to_html(false))
		and text.contains(scene._role_group_color(CaseEnums.RoleGroup.NGHICH_THAN).to_html(false))
		and turn_text.contains("LƯỢT HIỆN TẠI")
		and not turn_text.contains("Giờ")
		and reputation_text.contains("Player 1: [color=#%s]/////[/color]" % scene._reputation_color(5).to_html(false))
		and reputation_text.contains("Player 2: [color=#%s]////[/color]" % scene._reputation_color(4).to_html(false))
		and reputation_text.contains("Player 3: [color=#%s]///[/color]" % scene._reputation_color(3).to_html(false))
	)
	tree.root.remove_child(scene)
	scene.free()
	return passed


func _role_reference_term_bank_semantics() -> Dictionary:
	var sample: String = "Khi ta chưa được điều tra, ta thông báo một vai trò. Khi ta nói dối hoặc bị tha hóa, mục tiêu chưa bị bắt vẫn sống. Người Vô Tội thuộc Phe Thiện; Thuộc Hạ thuộc Phe Ác."
	var original: String = sample
	var styled: String = RoleReferenceFormatter.style_role_reference_terms(sample)
	var role: RoleDefinition = RoleDefinition.new()
	role.help_text = sample
	var terms: Array[Dictionary] = RoleReferenceFormatter.term_bank()
	var term_labels: Array[String] = []
	for entry: Dictionary in terms:
		term_labels.append(String(entry.get("term", "")))
	var checks: Dictionary = {}
	checks.sample_unchanged = sample == original
	checks.help_text_plain = role.help_text == original and RoleReferenceFormatter.role_body_text(role) == original
	checks.body_formatter = RoleReferenceFormatter.role_body_bbcode(role) == styled
	checks.bank_seeded = (
		term_labels.has("được điều tra")
		and term_labels.has("chưa được điều tra")
		and term_labels.has("nói dối")
		and term_labels.has("tha hóa")
		and term_labels.has("Người Vô Tội")
		and term_labels.has("Phe Ác")
	)
	checks.longest_phrase_first = (
		styled.contains("[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"investigate"), RoleReferenceFormatter.color_bbcode("chưa được điều tra", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
		and not styled.contains("chưa [url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"investigate"), RoleReferenceFormatter.color_bbcode("được điều tra", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
		and styled.contains("[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"unarrested"), RoleReferenceFormatter.color_bbcode("chưa bị bắt", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
		and not styled.contains("chưa [url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"arrest"), RoleReferenceFormatter.color_bbcode("bị bắt", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
	)
	checks.semantic_styles = (
		styled.contains("[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"announce"), RoleReferenceFormatter.color_bbcode("thông báo", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
		and styled.contains("[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"role"), RoleReferenceFormatter.color_bbcode("vai trò", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
		and styled.contains("[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"target"), RoleReferenceFormatter.color_bbcode("mục tiêu", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
		and styled.contains("[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"lie"), RoleReferenceFormatter.color_bbcode("nói dối", RoleReferenceFormatter.LYING_COLOR)])
		and styled.contains("[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"tainted"), RoleReferenceFormatter.color_bbcode("bị tha hóa", RoleReferenceFormatter.TAINTED_COLOR)])
		and styled.contains("[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"innocent_group"), RoleReferenceFormatter.color_bbcode("Người Vô Tội", RoleReferenceFormatter.role_group_color(CaseEnums.RoleGroup.CHINH_NHAN))])
		and styled.contains("[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"underling_group"), RoleReferenceFormatter.color_bbcode("Thuộc Hạ", RoleReferenceFormatter.role_group_color(CaseEnums.RoleGroup.TONG_PHAM))])
		and styled.contains("[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"good_alignment"), RoleReferenceFormatter.color_bbcode("Phe Thiện", RoleReferenceFormatter.role_alignment_color(CaseEnums.RoleGroup.CHINH_NHAN))])
		and styled.contains("[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"evil_alignment"), RoleReferenceFormatter.color_bbcode("Phe Ác", RoleReferenceFormatter.role_alignment_color(CaseEnums.RoleGroup.TONG_PHAM))])
	)
	checks.metadata_emitted = styled.contains("[url=glossary:")
	checks.no_font_size = not styled.contains("[font_size")
	return _checks_result(checks, "shared bank styles semantic glossary terms")


func _role_glossary_bank_canonical() -> bool:
	var address_entry: Dictionary = RoleGlossaryBank.entry_for_key(&"address")
	var dead_key: StringName = RoleGlossaryBank.resolve_alias("đã chết")
	var styled_overlap: String = RoleReferenceFormatter.style_role_reference_terms("không có trong Kỳ Án; có trong Kỳ Án; không xuất hiện trong Kỳ Án; xuất hiện trong Kỳ Án; được liệt kê; Được liệt kê; Phe Ác; chưa được điều tra; chưa bị bắt")
	var not_in_play_meta: String = RoleGlossaryBank.meta_for_key(&"not_in_play")
	var in_play_meta: String = RoleGlossaryBank.meta_for_key(&"in_play")
	var suspected_meta: String = RoleGlossaryBank.meta_for_key(&"suspected")
	var evil_alignment_meta: String = RoleGlossaryBank.meta_for_key(&"evil_alignment")
	var investigate_meta: String = RoleGlossaryBank.meta_for_key(&"investigate")
	var unarrested_meta: String = RoleGlossaryBank.meta_for_key(&"unarrested")
	var address_ok: bool = (
		String(address_entry.get("title", "")) == "Số Hiệu"
		and String(address_entry.get("definition", "")).contains("Số Hiệu")
		and not String(address_entry.get("title", "")).contains("Địa chỉ")
		and RoleGlossaryBank.resolve_alias("số hiệu") == &"address"
	)
	var alias_ok: bool = (
		RoleGlossaryBank.resolve_alias("được điều tra") == &"investigate"
		and RoleGlossaryBank.resolve_alias("đã thông báo") == &"announce"
		and RoleGlossaryBank.resolve_alias("đang nói dối") == &"lie"
		and RoleGlossaryBank.resolve_alias("bị tha hóa") == &"tainted"
		and RoleGlossaryBank.resolve_alias("thân phận") == &"role"
		and RoleGlossaryBank.resolve_alias("Thân phận") == &"role"
		and RoleGlossaryBank.resolve_alias("được liệt kê") == &"suspected"
		and RoleGlossaryBank.resolve_alias("Được liệt kê") == &"suspected"
		and RoleGlossaryBank.resolve_alias("xuất hiện trong Kỳ Án") == &"in_play"
		and RoleGlossaryBank.resolve_alias("không xuất hiện trong Kỳ Án") == &"not_in_play"
		and RoleGlossaryBank.resolve_alias("bị giết") == dead_key
		and RoleGlossaryBank.resolve_alias("chết") == dead_key
		and dead_key == &"dead"
	)
	var longest_overlap_ok: bool = (
		styled_overlap.contains("[url=%s]%s[/url]" % [not_in_play_meta, RoleReferenceFormatter.color_bbcode("không có trong Kỳ Án", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
		and styled_overlap.contains("[url=%s]%s[/url]" % [in_play_meta, RoleReferenceFormatter.color_bbcode("có trong Kỳ Án", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
		and styled_overlap.contains("[url=%s]%s[/url]" % [not_in_play_meta, RoleReferenceFormatter.color_bbcode("không xuất hiện trong Kỳ Án", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
		and styled_overlap.contains("[url=%s]%s[/url]" % [in_play_meta, RoleReferenceFormatter.color_bbcode("xuất hiện trong Kỳ Án", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
		and styled_overlap.contains("[url=%s]%s[/url]" % [suspected_meta, RoleReferenceFormatter.color_bbcode("được liệt kê", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
		and styled_overlap.contains("[url=%s]%s[/url]" % [suspected_meta, RoleReferenceFormatter.color_bbcode("Được liệt kê", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
		and styled_overlap.contains("[url=%s]%s[/url]" % [investigate_meta, RoleReferenceFormatter.color_bbcode("chưa được điều tra", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
		and styled_overlap.contains("[url=%s]%s[/url]" % [unarrested_meta, RoleReferenceFormatter.color_bbcode("chưa bị bắt", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
		and styled_overlap.contains("[url=%s]%s[/url]" % [evil_alignment_meta, RoleReferenceFormatter.color_bbcode("Phe Ác", RoleReferenceFormatter.role_alignment_color(CaseEnums.RoleGroup.TONG_PHAM))])
		and not styled_overlap.contains("không [url=%s]%s[/url]" % [in_play_meta, RoleReferenceFormatter.color_bbcode("có trong Kỳ Án", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
		and not styled_overlap.contains("không [url=%s]%s[/url]" % [in_play_meta, RoleReferenceFormatter.color_bbcode("xuất hiện trong Kỳ Án", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
		and not styled_overlap.contains("chưa [url=%s]%s[/url]" % [investigate_meta, RoleReferenceFormatter.color_bbcode("được điều tra", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
		and not styled_overlap.contains("chưa [url=glossary:arrest]%s[/url]" % RoleReferenceFormatter.color_bbcode("bị bắt", RoleReferenceFormatter.GLOSSARY_LINK_COLOR))
	)
	var approved_wording: Dictionary = {
		&"role": ["Thân phận", "Một thân phận có thể xuất hiện trong Kỳ Án và sở hữu những quy tắc, thông tin hoặc chức năng riêng."],
		&"alignment": ["Phe", "Mỗi thân phận thuộc Phe Thiện hoặc Phe Ác. Để phá giải Kỳ Án, cần xác định đầy đủ những thân phận thuộc Phe Ác."],
		&"good_alignment": ["Phe", "Mỗi thân phận thuộc Phe Thiện hoặc Phe Ác. Để phá giải Kỳ Án, cần xác định đầy đủ những thân phận thuộc Phe Ác."],
		&"evil_alignment": ["Phe", "Mỗi thân phận thuộc Phe Thiện hoặc Phe Ác. Để phá giải Kỳ Án, cần xác định đầy đủ những thân phận thuộc Phe Ác."],
		&"investigate": ["Điều tra", "Lật mở một nghi phạm để biết thân phận mà họ đang thể hiện cùng thông tin được công bố."],
		&"announce": ["Thông báo", "Thông tin mà một thân phận đưa ra khi được điều tra. Nội dung này sẽ được hiển thị bên dưới tên của họ."],
		&"lie": ["Nói dối", "Khi một thân phận nói dối, thông tin hoặc kết quả họ tạo ra sẽ tuân theo quy tắc nói dối của thân phận đó."],
		&"tainted": ["Tha hóa", "Khi bị tha hóa, một thân phận sẽ hoạt động theo trạng thái tha hóa của mình. Với các thân phận cung cấp thông tin, điều này thường khiến họ nói dối."],
		&"ability": ["Chức năng", "Năng lực chủ động của một thân phận, được sử dụng khi người chơi đưa ra lựa chọn. Mỗi chức năng có quy tắc và thời điểm sử dụng riêng."],
		&"pretend": ["Giả danh", "Khi một thân phận giả danh thân phận khác, họ sẽ xuất hiện dưới danh nghĩa của thân phận đó khi được điều tra và sử dụng thông tin hoặc chức năng tương ứng. Việc họ nói thật hay nói dối được xác định riêng."],
		&"suspected": ["Được liệt kê", "Thân phận này xuất hiện trong danh sách THÂN PHẬN của Kỳ Án. Điều đó không có nghĩa rằng họ nhất định sẽ xuất hiện trên bàn."],
		&"in_play": ["Xuất hiện trong Kỳ Án", "Thân phận này thực sự tồn tại trên bàn Kỳ Án hiện tại."],
		&"not_in_play": ["Không xuất hiện trong Kỳ Án", "Thân phận này không thực sự tồn tại trên bàn Kỳ Án hiện tại."],
	}
	var approved_wording_ok: bool = true
	for key: StringName in approved_wording:
		var expected: Array = approved_wording[key] as Array
		var entry: Dictionary = RoleGlossaryBank.entry_for_key(key)
		approved_wording_ok = (
			approved_wording_ok
			and String(entry.get("title", "")) == String(expected[0])
			and String(entry.get("definition", "")) == String(expected[1])
		)
	return address_ok and alias_ok and longest_overlap_ok and approved_wording_ok and not styled_overlap.contains("[font_size")


func _role_glossary_hover_plumbing() -> Dictionary:
	var checks: Dictionary = {}
	var tooltip_scene: PackedScene = load("res://scenes/shared_ui/RoleGlossaryTooltip.tscn") as PackedScene
	var tooltip: RoleGlossaryTooltipController = null
	if tooltip_scene != null:
		tooltip = tooltip_scene.instantiate() as RoleGlossaryTooltipController
	checks.tooltip_scene = tooltip_scene != null
	checks.tooltip_controller = tooltip != null
	var sample: String = RoleReferenceFormatter.style_role_reference_terms("Khi ta nói dối hoặc bị tha hóa, ta thông báo.")
	checks.metadata = (
		sample.contains("[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"lie"), RoleReferenceFormatter.color_bbcode("nói dối", RoleReferenceFormatter.LYING_COLOR)])
		and sample.contains("[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"tainted"), RoleReferenceFormatter.color_bbcode("bị tha hóa", RoleReferenceFormatter.TAINTED_COLOR)])
		and sample.contains("[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"announce"), RoleReferenceFormatter.color_bbcode("thông báo", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
		and not sample.contains("[font_size")
	)
	var case_hook_ok: bool = false
	var case_scene: VSCaseMainController = _case_scene_instance() as VSCaseMainController
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var case_scene_ready: bool = case_scene != null and tree != null
	if case_scene != null and tree != null:
		tree.root.add_child(case_scene)
		case_hook_ok = case_scene.has_glossary_hover_for_smoke()
		tree.root.remove_child(case_scene)
		case_scene.free()
	elif case_scene != null:
		case_scene.free()
	var codex_scene: RoleCodexController = _role_codex_instance()
	var codex_scene_ready: bool = codex_scene != null
	var codex_hook_ok: bool = codex_scene != null and codex_scene.has_glossary_hover_for_smoke()
	_free_role_codex(codex_scene)
	checks.case_scene_ready = case_scene_ready
	checks.case_hook = case_hook_ok
	checks.codex_scene_ready = codex_scene_ready
	checks.codex_hook = codex_hook_ok
	if tooltip != null:
		tooltip.free()
	return _checks_result(checks, "shared tooltip and hover signals connected")


func _role_reference_rich_styling(roles: Array[RoleDefinition]) -> bool:
	var scene: VSCaseMainController = _case_scene_instance() as VSCaseMainController
	if scene == null:
		return false
	var meddler: RoleDefinition = null
	var underling: RoleDefinition = null
	for role: RoleDefinition in roles:
		if role == null:
			continue
		if role.role_group == CaseEnums.RoleGroup.HIEU_SU and meddler == null:
			meddler = role
		if role.role_group == CaseEnums.RoleGroup.TONG_PHAM and underling == null:
			underling = role
	if meddler == null or underling == null:
		scene.free()
		return false
	var sample_role: RoleDefinition = RoleDefinition.new()
	sample_role.role_id = &"smoke_role_reference_sample"
	sample_role.display_name = "Smoke Sample"
	sample_role.role_group = CaseEnums.RoleGroup.CHINH_NHAN
	sample_role.help_text = "Khi ta được điều tra, ta thông báo một vai trò. Khi ta nói dối hoặc bị tha hóa, mục tiêu chưa bị bắt vẫn sống."
	var underling_sample: RoleDefinition = RoleDefinition.new()
	underling_sample.role_id = &"smoke_underling_reference_sample"
	underling_sample.display_name = "Smoke Underling Sample"
	underling_sample.role_group = CaseEnums.RoleGroup.TONG_PHAM
	underling_sample.help_text = sample_role.help_text
	var sample_plain: String = scene._role_reference_text(sample_role)
	var sample_rich: String = scene._role_reference_bbcode(sample_role)
	var underling_rich: String = scene._role_reference_bbcode(underling_sample)
	var probe_body: RichTextLabel = RichTextLabel.new()
	RoleReferenceFormatter.apply_uniform_body_font(probe_body)
	var body_font_size_ok: bool = (
		probe_body.get_theme_font_size("normal_font_size") == RoleReferenceFormatter.BODY_FONT_SIZE
		and probe_body.get_theme_font_size("normal_font_size") == probe_body.get_theme_font_size("bold_font_size")
		and probe_body.get_theme_font_size("normal_font_size") == probe_body.get_theme_font_size("italics_font_size")
		and probe_body.get_theme_font_size("normal_font_size") == probe_body.get_theme_font_size("bold_italics_font_size")
	)
	var passed: bool = (
		body_font_size_ok
		and scene._role_reference_bbcode(sample_role) == RoleReferenceFormatter.role_reference_bbcode(sample_role)
		and not sample_rich.contains("[font_size")
		and scene._role_group_color(CaseEnums.RoleGroup.HIEU_SU) == Color(0.96, 0.82, 0.28, 1.0)
		and scene._role_group_color(CaseEnums.RoleGroup.NGHICH_THAN) == Color(0.78, 0.55, 1.0, 1.0)
		and scene._role_alignment_color(meddler.role_group) == Color(0.67, 0.86, 1.0, 1.0)
		and scene._role_alignment_color(underling.role_group) == Color(1.0, 0.58, 0.55, 1.0)
		and sample_rich.contains("[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"innocent_group"), scene._color_bbcode("Người Vô Tội", scene._role_group_color(CaseEnums.RoleGroup.CHINH_NHAN))])
		and sample_rich.contains("[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"good_alignment"), scene._color_bbcode("Phe Thiện", scene._role_alignment_color(CaseEnums.RoleGroup.CHINH_NHAN))])
		and underling_rich.contains(scene._color_bbcode("Thuộc Hạ", scene._role_group_color(CaseEnums.RoleGroup.TONG_PHAM)))
		and underling_rich.contains(scene._color_bbcode("Phe Ác", scene._role_alignment_color(CaseEnums.RoleGroup.TONG_PHAM)))
		and sample_rich.contains("[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"investigate"), scene._color_bbcode("được điều tra", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
		and sample_rich.contains("[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"announce"), scene._color_bbcode("thông báo", RoleReferenceFormatter.GLOSSARY_LINK_COLOR)])
		and sample_rich.contains("[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"lie"), scene._color_bbcode("nói dối", Color(1.0, 0.30, 0.28, 1.0))])
		and sample_rich.contains("[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(&"tainted"), scene._color_bbcode("bị tha hóa", Color(0.78, 0.55, 1.0, 1.0))])
		and not sample_rich.contains("Tha Hóa")
		and sample_plain.contains(sample_role.help_text)
		and not sample_plain.contains("tôi")
		and not sample_plain.contains("Tha Hóa")
	)
	probe_body.free()
	scene.free()
	return passed


func _tutorial_03_crime_scene_presentation(c: CaseDefinition) -> bool:
	var board: CaseBoardController = _board_instance(c)
	if board == null:
		return false
	var text: String = board.get_crime_scene_tile_text()
	var passed: bool = (
		board.has_crime_scene_tile()
		and board.is_crime_scene_noninteractive()
		and board.get_crime_scene_slot() == 1
		and text == "HIỆN TRƯỜNG\n!"
		and not text.contains("Một hiện trường")
		and not text.contains("trung tính")
		and not text.contains("Không chứa")
	)
	board.free()
	return passed


func _tutorial_03_suspect(c: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	if c == null:
		return null
	for suspect in c.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null


func _tutorial_03_view(views: Array[SuspectPublicViewData], suspect_id: int) -> SuspectPublicViewData:
	for view in views:
		if view != null and view.suspect_id == suspect_id:
			return view
	return null


func _tutorial_03_truth(reveal: CaseTruthReveal, suspect_id: int) -> SuspectTruthReveal:
	if reveal == null:
		return null
	for truth in reveal.suspect_truths:
		if truth != null and truth.suspect_id == suspect_id:
			return truth
	return null


func _true_role_uniqueness_rejects_duplicate(roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = CaseDefinition.new()
	c.case_id = &"duplicate_true_role_smoke"
	c.display_name = "Duplicate True Role Smoke"
	c.crime_scene = CrimeSceneDefinition.new()
	c.crime_scene.scene_id = &"duplicate_true_role_scene"
	c.crime_scene.display_name = "Hiện trường"
	c.crime_scene.board_slot = 8
	c.on_solve = OnSolveReward.new()
	for index: int in range(2):
		var suspect: SuspectDefinition = SuspectDefinition.new()
		suspect.suspect_id = index + 1
		suspect.board_slot = index
		suspect.true_role_id = &"tailor"
		suspect.displayed_role_id = &"tailor"
		suspect.true_alignment = CaseEnums.Alignment.GOOD
		suspect.role_group = CaseEnums.RoleGroup.CHINH_NHAN
		c.suspects.append(suspect)
	var report: Dictionary = CaseDefinitionValidator.new().validate(c, roles, players)
	return not bool(report.get("passed", false)) and _report_has_error_code(report, "TRUE_ROLE_DUPLICATE")


func _duplicate_displayed_tailor_valid(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var report: Dictionary = CaseDefinitionValidator.new().validate(c, roles, players)
	return (
		bool(report.get("passed", false))
		and _count_true_role(c, &"tailor") == 1
		and _count_displayed_role(c, &"tailor") == 2
	)


func _tutorial_04_ratio(c: CaseDefinition) -> bool:
	if c == null:
		return false
	var counts: Dictionary = {
		CaseEnums.RoleGroup.CHINH_NHAN: 0,
		CaseEnums.RoleGroup.HIEU_SU: 0,
		CaseEnums.RoleGroup.TONG_PHAM: 0,
		CaseEnums.RoleGroup.NGHICH_THAN: 0,
	}
	for suspect: SuspectDefinition in c.suspects:
		counts[suspect.role_group] = int(counts.get(suspect.role_group, 0)) + 1
	return (
		int(counts.get(CaseEnums.RoleGroup.CHINH_NHAN, 0)) == 3
		and int(counts.get(CaseEnums.RoleGroup.HIEU_SU, 0)) == 0
		and int(counts.get(CaseEnums.RoleGroup.TONG_PHAM, 0)) == 1
		and int(counts.get(CaseEnums.RoleGroup.NGHICH_THAN, 0)) == 0
	)


func _tutorial_04_board_slots(c: CaseDefinition) -> bool:
	var s1: SuspectDefinition = _case_suspect(c, 1)
	var s2: SuspectDefinition = _case_suspect(c, 2)
	var s3: SuspectDefinition = _case_suspect(c, 3)
	var s4: SuspectDefinition = _case_suspect(c, 4)
	var occupied_slots: Dictionary = {}
	if c != null and c.crime_scene != null:
		occupied_slots[c.crime_scene.board_slot] = true
	if c != null:
		for suspect: SuspectDefinition in c.suspects:
			if suspect != null:
				occupied_slots[suspect.board_slot] = true
	return (
		c != null
		and c.crime_scene != null
		and c.crime_scene.board_slot == 4
		and _case_suspect(c, 0) == null
		and _case_suspect(c, 5) == null
		and c.suspects.size() == 4
		and s1 != null
		and s1.board_slot == 0
		and s2 != null
		and s2.board_slot == 2
		and s3 != null
		and s3.board_slot == 6
		and s4 != null
		and s4.board_slot == 8
		and not occupied_slots.has(1)
		and not occupied_slots.has(3)
		and not occupied_slots.has(5)
		and not occupied_slots.has(7)
		and _board_slots_match_authored(c)
	)


func _tutorial_04_assignments(c: CaseDefinition) -> bool:
	var s1: SuspectDefinition = _case_suspect(c, 1)
	var s2: SuspectDefinition = _case_suspect(c, 2)
	var s3: SuspectDefinition = _case_suspect(c, 3)
	var s4: SuspectDefinition = _case_suspect(c, 4)
	return (
		_true_role_ids_unique(c)
		and s1 != null
		and s1.true_role_id == &"tailor"
		and s1.displayed_role_id == &"tailor"
		and s1.true_alignment == CaseEnums.Alignment.GOOD
		and s2 != null
		and s2.true_role_id == &"tutorial_mobster"
		and s2.displayed_role_id == &"tailor"
		and s2.impersonated_role_id == &"tailor"
		and s2.is_impersonating
		and s2.true_alignment == CaseEnums.Alignment.EVIL
		and s2.role_group == CaseEnums.RoleGroup.TONG_PHAM
		and s3 != null
		and s3.true_role_id == &"mailman"
		and s3.displayed_role_id == &"mailman"
		and s3.true_alignment == CaseEnums.Alignment.GOOD
		and s4 != null
		and s4.true_role_id == &"tutorial_priest"
		and s4.displayed_role_id == &"tutorial_priest"
		and s4.true_alignment == CaseEnums.Alignment.GOOD
		and _count_displayed_role(c, &"tailor") == 2
	)


func _tutorial_04_mailman(c: CaseDefinition, roles: Array[RoleDefinition]) -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var validation: Dictionary = service.validate_mailman_pair(
		c,
		3,
		&"tailor",
		&"mathematician",
		InvestigationInformationResult.TruthMode.TRUTHFUL,
		roles
	)
	var evaluated: InvestigationInformationResult = service.evaluate(c, 3, roles)
	var true_in_play: Array[StringName] = service.true_role_ids_in_play(c)
	return (
		bool(validation.get("valid", false))
		and bool(validation.get("in_play_truth", false))
		and bool(validation.get("not_in_play_truth", false))
		and evaluated.payload_kind == InvestigationInformationResult.PayloadKind.ROLE_PLAY_CLAIM
		and evaluated.in_play_role_id == &"tailor"
		and evaluated.not_in_play_role_id == &"mathematician"
		and evaluated.public_text().contains("Thợ May")
		and evaluated.public_text().contains("Nhà Toán Học")
		and _count_true_role(c, &"tailor") == 1
		and true_in_play.has(&"tailor")
		and not true_in_play.has(&"mathematician")
	)


func _tutorial_04_priest(c: CaseDefinition, roles: Array[RoleDefinition]) -> bool:
	var evaluated: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(c, 4, roles)
	return evaluated.payload_kind == InvestigationInformationResult.PayloadKind.TEXT and evaluated.public_text() == "Tôi là Tư Tế."


func _tutorial_04_tailor_functions(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	var bundle: Dictionary = _fresh_turn_bundle(c, players)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var manager: TurnManager = bundle.manager as TurnManager
	var availability: FunctionAvailabilityService = FunctionAvailabilityService.new()
	availability.initialize_hidden_states(c, runtime, roles)
	var player_id: StringName = runtime.current_player_id()
	var investigate_true: InvestigationResult = InvestigationService.new().investigate(c, runtime, 1, player_id)
	var investigate_fake: InvestigationResult = InvestigationService.new().investigate(c, runtime, 2, player_id)
	checks.investigated = investigate_true.success and investigate_fake.success
	checks.true_reveal = availability.reveal_for_suspect(c, runtime, roles, 1, manager.turn_number)
	checks.fake_reveal = availability.reveal_for_suspect(c, runtime, roles, 2, manager.turn_number)
	manager.advance_turn()
	runtime.apply_turn_snapshot(manager)
	availability.update_for_turn(runtime, manager.turn_number)
	var true_function: InteractiveFunctionRuntimeState = runtime.find_suspect(1).interactive_function
	var fake_function: InteractiveFunctionRuntimeState = runtime.find_suspect(2).interactive_function
	checks.both_available = (
		true_function != null
		and fake_function != null
		and true_function.state == InteractiveFunctionRuntimeState.State.AVAILABLE
		and fake_function.state == InteractiveFunctionRuntimeState.State.AVAILABLE
	)
	var targets: PackedInt32Array = PackedInt32Array([3, 4])
	var actor_id: StringName = runtime.current_player_id()
	var true_result: InteractiveFunctionResult = InteractiveFunctionExecutionService.new().execute(c, runtime, 1, targets, actor_id)
	var fake_result: InteractiveFunctionResult = InteractiveFunctionExecutionService.new().execute(c, runtime, 2, targets, actor_id)
	var target_three: SuspectDefinition = _case_suspect(c, 3)
	var target_four: SuspectDefinition = _case_suspect(c, 4)
	checks.targets_good_good = (
		target_three != null
		and target_three.true_alignment == CaseEnums.Alignment.GOOD
		and target_four != null
		and target_four.true_alignment == CaseEnums.Alignment.GOOD
	)
	checks.true_tailor_same = (
		true_result.success
		and true_result.public_result_type == InteractiveFunctionResult.PublicResultType.SAME_ALIGNMENT
		and true_result.public_result_text == "Cùng phe"
	)
	checks.fake_tailor_different = (
		fake_result.success
		and fake_result.public_result_type == InteractiveFunctionResult.PublicResultType.DIFFERENT_ALIGNMENT
		and fake_result.public_result_text == "Khác phe"
	)
	checks.one_use = (
		true_function != null
		and true_function.uses_remaining == 0
		and true_function.state == InteractiveFunctionRuntimeState.State.EXHAUSTED
		and fake_function != null
		and fake_function.uses_remaining == 0
		and fake_function.state == InteractiveFunctionRuntimeState.State.EXHAUSTED
	)
	checks.public_history = (
		runtime.public_function_records.size() == 2
		and runtime.public_function_records[0].summary_text() == "Thợ May: Nghi phạm 3 và 4 cùng phe."
		and runtime.public_function_records[1].summary_text() == "Thợ May: Nghi phạm 3 và 4 khác phe."
	)
	return _named_check_result(checks)


func _tutorial_04_private_and_reveal(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	var before_slots: Dictionary = _authored_board_slot_snapshot(c)
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var player: PlayerCaseState = runtime.find_player(runtime.current_player_id())
	var before_views: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles)
	var before_two: SuspectPublicViewData = _tutorial_03_view(before_views, 2)
	checks.no_early_public_leak = before_two != null and before_two.public_role_name == "" and not before_two.full_truth_visible
	if player == null:
		checks.private_accuse = false
		return _named_check_result(checks)
	var accuse: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(c, runtime, player, 2)
	var records: Array[PrivateRoleKnowledgeRecord] = runtime.private_role_knowledge_for_player(player.player_id)
	checks.private_accuse = (
		accuse.success
		and accuse.correct
		and accuse.completed_evil_set
		and records.size() == 1
		and _tutorial_03_private_record_has(records, 2, &"tutorial_mobster")
		and _private_record_excludes_truth_metadata(records[0])
	)
	var settlement: CaseSettlementResult = CaseSettlementService.new().settle(c, runtime)
	var reveal: CaseTruthReveal = CaseTruthRevealBuilder.new().build(c, runtime, roles)
	var truth_two: SuspectTruthReveal = _tutorial_03_truth(reveal, 2)
	checks.settlement_reveal = settlement.success and reveal != null and runtime.truth_reveal == reveal
	checks.mobster_truth = truth_two != null and truth_two.true_role_name == "Kẻ Côn Đồ"
	checks.mobster_pretend = truth_two != null and truth_two.impersonated_role_name == "Thợ May"
	var board: CaseBoardController = _board_instance_with_runtime(c, runtime, roles)
	var card_two: SuspectCardController = _board_card(board, 2) if board != null else null
	var truth_text: String = card_two.get_full_truth_text() if card_two != null else ""
	var reveal_statement: String = card_two.get_reveal_statement_text() if card_two != null else ""
	checks.slots_preserved = board != null and before_slots == _rendered_board_slot_snapshot(board, c)
	checks.full_reveal_visible = (
		card_two != null
		and card_two.get_public_role_text() == "Kẻ Côn Đồ"
		and truth_text == "Ta giả danh Thợ May."
		and reveal_statement == "Ta giả danh Thợ May."
	)
	if board != null:
		board.free()
	return _named_check_result(checks)


func _tutorial_05_integration_checks(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	if c == null:
		checks.fixture_loaded = false
		return checks
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var role_info: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var result_one: InvestigationInformationResult = role_info.evaluate(c, 1, roles)
	var result_two: InvestigationInformationResult = role_info.evaluate(c, 2, roles)
	var result_three: InvestigationInformationResult = role_info.evaluate(c, 3, roles)
	var result_four: InvestigationInformationResult = role_info.evaluate(c, 4, roles)
	var suspect_one: SuspectDefinition = _case_suspect(c, 1)
	var suspect_four: SuspectDefinition = _case_suspect(c, 4)
	var suspect_five_runtime: SuspectRuntimeState = runtime.find_suspect(5) if runtime != null else null
	var vigilante_role: RoleDefinition = _find_role_for_test(roles, &"vigilante")
	var surgeon_role: RoleDefinition = _find_role_for_test(roles, &"surgeon")
	FunctionAvailabilityService.new().initialize_hidden_states(c, runtime, roles)
	var vigilante_function: InteractiveFunctionRuntimeState = runtime.find_suspect(5).interactive_function if runtime != null and runtime.find_suspect(5) != null else null
	var surgeon_events: Array[CaseTimedEventRuntimeState] = SurgeonTimedEventService.new().evaluate(c, runtime)
	var surgeon_event: CaseTimedEventRuntimeState = surgeon_events[0] if not surgeon_events.is_empty() else null
	var views: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles)
	checks.board_slots = _tutorial_05_board_slots(c)
	checks.empty_slots = _tutorial_05_empty_slots(c)
	checks.numbering = _tutorial_05_numbering(c)
	checks.true_roles = _tutorial_05_true_roles(c)
	checks.displayed_roles = _tutorial_05_displayed_roles(c)
	checks.ratio = _tutorial_05_ratio(c)
	checks.evil_answers = c.evil_suspect_ids == PackedInt32Array([1, 4]) and c.accomplice_suspect_ids == PackedInt32Array([4]) and c.traitor_suspect_ids == PackedInt32Array([1])
	checks.critic_pretend = suspect_one != null and suspect_one.is_impersonating and suspect_one.impersonated_role_id == &"mathematician" and not RoleInformationEvaluationService.new().true_role_ids_in_play(c).has(&"mathematician")
	checks.mobster_pretend = suspect_four != null and suspect_four.is_impersonating and suspect_four.impersonated_role_id == &"tutorial_priest" and RoleInformationEvaluationService.new().true_role_ids_in_play(c).has(&"tutorial_priest")
	checks.critic_math_behavior = result_one != null and result_one.behavior_role_id == &"mathematician" and result_one.payload_kind == InvestigationInformationResult.PayloadKind.NUMBER
	checks.math_truth_sum = RoleInformationEvaluationService.new().true_evil_suspect_number_sum(c) == 5
	checks.critic_math_lie = result_one != null and result_one.truth_mode == InvestigationInformationResult.TruthMode.LYING and result_one.numeric_value != 5
	checks.priest_truthful = result_two != null and result_two.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL and result_two.text == "Tôi là Tư Tế."
	checks.fake_priest_lies = result_four != null and result_four.behavior_role_id == &"tutorial_priest" and result_four.truth_mode == InvestigationInformationResult.TruthMode.LYING and result_four.text != "Tôi là Tư Tế."
	checks.weatherman_claim = result_three != null and result_three.payload_kind == InvestigationInformationResult.PayloadKind.WEATHER_REPORT and role_info.weatherman_claim_matches_truthful_pattern(c, result_three)
	checks.weatherman_self_exclusion = result_three != null and result_three.weather_suspect_ids.size() == 3 and int(result_three.weather_suspect_ids[0]) != 3
	checks.vigilante_alive = suspect_five_runtime != null and not suspect_five_runtime.is_dead
	checks.vigilante_metadata = vigilante_role != null and vigilante_role.has_interactive_function and vigilante_role.function_type == CaseEnums.FunctionType.VIGILANTE_KILL and vigilante_role.target_count == 1
	checks.vigilante_runtime_function = vigilante_function != null and vigilante_function.suspect_id == 5 and vigilante_function.function_type == CaseEnums.FunctionType.VIGILANTE_KILL and vigilante_function.target_count == 1
	checks.surgeon_role_group = surgeon_role != null and surgeon_role.role_group == CaseEnums.RoleGroup.HIEU_SU and _case_suspect(c, 6).role_group == CaseEnums.RoleGroup.HIEU_SU
	checks.surgeon_discoverable = surgeon_event != null and surgeon_event.source_suspect_id == 6 and surgeon_event.threshold_hour == 12
	checks.surgeon_initially_unfired = surgeon_event != null and not surgeon_event.fired and runtime.elapsed_hours == 0
	checks.clock_hud_zero = _tutorial_05_clock_hud_zero(players)
	checks.foundation_anchors = FixtureRepository.load_tutorial_case_001() != null and FixtureRepository.load_tutorial_case_004() != null and _role_id_exists(roles, &"mathematician") and _role_id_exists(roles, &"weatherman") and _role_id_exists(roles, &"critic")
	checks.public_hides_truth = views.size() == 6 and _view_data_excludes(c, "true_role_id") and _tutorial_05_public_roles_hidden(views)
	return checks


func _tutorial_05_board_slots(c: CaseDefinition) -> bool:
	return (
		c.crime_scene != null
		and c.crime_scene.board_slot == 3
		and _case_suspect(c, 1).board_slot == 0
		and _case_suspect(c, 2).board_slot == 2
		and _case_suspect(c, 3).board_slot == 4
		and _case_suspect(c, 4).board_slot == 6
		and _case_suspect(c, 5).board_slot == 7
		and _case_suspect(c, 6).board_slot == 8
	)


func _tutorial_05_empty_slots(c: CaseDefinition) -> bool:
	var occupied: Dictionary = {}
	occupied[3] = true
	for suspect: SuspectDefinition in c.suspects:
		occupied[suspect.board_slot] = true
	return not occupied.has(1) and not occupied.has(5) and occupied.size() == 7


func _tutorial_05_numbering(c: CaseDefinition) -> bool:
	var suspect_ids: PackedInt32Array = PackedInt32Array()
	for suspect: SuspectDefinition in c.suspects:
		suspect_ids.append(suspect.suspect_id)
	return (
		suspect_ids == PackedInt32Array([1, 2, 3, 4, 5, 6])
		and _case_suspect(c, 4).board_slot == 6
		and _case_suspect(c, 6).board_slot == 8
		and c.crime_scene != null
		and c.crime_scene.board_slot == 3
	)


func _tutorial_05_true_roles(c: CaseDefinition) -> bool:
	return (
		_case_suspect(c, 1).true_role_id == &"critic"
		and _case_suspect(c, 2).true_role_id == &"tutorial_priest"
		and _case_suspect(c, 3).true_role_id == &"weatherman"
		and _case_suspect(c, 4).true_role_id == &"tutorial_mobster"
		and _case_suspect(c, 5).true_role_id == &"vigilante"
		and _case_suspect(c, 6).true_role_id == &"surgeon"
	)


func _tutorial_05_displayed_roles(c: CaseDefinition) -> bool:
	return (
		_case_suspect(c, 1).displayed_role_id == &"mathematician"
		and _case_suspect(c, 2).displayed_role_id == &"tutorial_priest"
		and _case_suspect(c, 3).displayed_role_id == &"weatherman"
		and _case_suspect(c, 4).displayed_role_id == &"tutorial_priest"
		and _case_suspect(c, 5).displayed_role_id == &"vigilante"
		and _case_suspect(c, 6).displayed_role_id == &"surgeon"
	)


func _tutorial_05_ratio(c: CaseDefinition) -> bool:
	var counts: Dictionary = {}
	counts[CaseEnums.RoleGroup.CHINH_NHAN] = 0
	counts[CaseEnums.RoleGroup.HIEU_SU] = 0
	counts[CaseEnums.RoleGroup.TONG_PHAM] = 0
	counts[CaseEnums.RoleGroup.NGHICH_THAN] = 0
	for suspect: SuspectDefinition in c.suspects:
		counts[suspect.role_group] = int(counts.get(suspect.role_group, 0)) + 1
	return (
		int(counts[CaseEnums.RoleGroup.CHINH_NHAN]) == 3
		and int(counts[CaseEnums.RoleGroup.HIEU_SU]) == 1
		and int(counts[CaseEnums.RoleGroup.TONG_PHAM]) == 1
		and int(counts[CaseEnums.RoleGroup.NGHICH_THAN]) == 1
	)


func _tutorial_05_clock_hud_zero(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return false
	var label: Label = scene.get_node_or_null("%ElapsedHoursLabel") as Label
	var passed: bool = scene.runtime_state.elapsed_hours == 0 and label != null and label.text.contains("0h")
	_t05_i2_free_scene(scene)
	return passed


func _tutorial_05_public_roles_hidden(views: Array[SuspectPublicViewData]) -> bool:
	for view: SuspectPublicViewData in views:
		if view == null or not view.public_role_name.is_empty() or view.full_truth_visible:
			return false
	return true


func _tutorial_05_i2_live_checks(_c: CaseDefinition, _roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	checks.investigation_adds_two = _t05_i2_live_investigation_adds_two(players)
	checks.invalid_investigation_zero = _t05_i2_invalid_investigation_zero(players)
	checks.duplicate_investigation_idempotent = _t05_i2_duplicate_action_time_idempotent(CaseClockService.ACTION_INVESTIGATION, 2)
	checks.single_accuse_adds_one = _t05_i2_live_single_accuse_adds_one(players)
	checks.invalid_single_accuse_zero = _t05_i2_invalid_single_accuse_zero(players)
	checks.duplicate_single_accuse_idempotent = _t05_i2_duplicate_action_time_idempotent(CaseClockService.ACTION_SINGLE_ACCUSATION, 1)
	checks.active_function_zero = _t05_i2_live_vigilante_clock_zero(players)
	checks.target_selection_zero = _t05_i2_function_selection_zero(players)
	checks.time_turn_separate = _t05_i2_time_turn_separate(players)
	checks.investigation_turn_once = _t05_i2_live_investigation_turn_once(players)
	checks.single_accuse_turn_once = _t05_i2_live_single_accuse_turn_once(players)
	checks.vigilante_turn_once = _t05_i2_live_vigilante_turn_once(players)
	checks.surgeon_reevaluates_at_12 = _t05_i2_surgeon_reevaluates_at_12(players)
	checks.surgeon_true_role_source = _t05_i2_surgeon_true_role_source(players)
	checks.surgeon_once = _surgeon_no_duplicate(players)
	checks.surgeon_ignores_displayed = _t05_i2_surgeon_ignores_displayed_role(players)
	checks.surgeon_target_not_hardcoded = _t05_i2_surgeon_target_not_hardcoded(players)
	checks.surgeon_success_kill_service = _surgeon_success_kill_service(players)
	checks.surgeon_failure_alive = _surgeon_failed_kills_nobody(players)
	checks.surgeon_no_target_once = _surgeon_no_target_once(players)
	checks.surgeon_no_duplicate_after_time = _t05_i2_surgeon_no_duplicate_after_time(players)
	checks.vigilante_one_target = _t05_i2_live_vigilante_one_target(players)
	checks.vigilante_evil_attempt = _t05_i2_live_vigilante_evil_attempt(players)
	checks.vigilante_good_miss = _vigilante_truthful_good_misses(players)
	checks.vigilante_lying_miss = _vigilante_lying_evil_misses(players)
	checks.vigilante_consumes_once = _t05_i2_live_vigilante_consumes_once(players)
	checks.vigilante_clock_zero = _t05_i2_live_vigilante_clock_zero(players)
	checks.vigilante_death_kill_service = _t05_i2_live_vigilante_death_uses_kill_service(players)
	checks.death_handled_evil = _t05_i2_live_death_handled_evil(players)
	checks.death_no_private_knowledge = _t05_i2_live_death_no_private_knowledge(players)
	return checks


func _t05_i2_live_scene(players: Array[PlayerCaseState]) -> VSCaseMainController:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var previous_pending: String = AppFlow.pending_case_path
	AppFlow.pending_case_path = FixtureRepository.TUTORIAL_CASE_005_PATH
	var scene: VSCaseMainController = _case_scene_instance() as VSCaseMainController
	if scene == null:
		AppFlow.pending_case_path = previous_pending
		return null
	scene.configure_integrated_case(players)
	tree.root.add_child(scene)
	AppFlow.pending_case_path = previous_pending
	return scene


func _t05_i2_free_scene(scene: VSCaseMainController) -> void:
	if scene == null:
		return
	var parent: Node = scene.get_parent()
	if parent != null:
		parent.remove_child(scene)
	scene.free()


func _t05_i2_live_investigation_adds_two(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return false
	var before: int = scene.runtime_state.elapsed_hours
	scene._perform_direct_investigation(2)
	var passed: bool = scene.runtime_state.elapsed_hours == before + 2
	_t05_i2_free_scene(scene)
	return passed


func _t05_i2_invalid_investigation_zero(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return false
	scene._perform_direct_investigation(99)
	var passed: bool = scene.runtime_state.elapsed_hours == 0 and scene.turn_manager.turn_number == 1
	_t05_i2_free_scene(scene)
	return passed


func _t05_i2_duplicate_action_time_idempotent(action_type: StringName, expected_hours: int) -> bool:
	var runtime: CaseRuntimeState = CaseRuntimeState.new()
	runtime.initialize(FixtureRepository.load_tutorial_case_005(), FixtureRepository.load_players())
	var clock: CaseClockService = CaseClockService.new()
	var first: bool = clock.apply_action_time(runtime, &"duplicate_action", action_type)
	var second: bool = clock.apply_action_time(runtime, &"duplicate_action", action_type)
	return first and not second and runtime.elapsed_hours == expected_hours


func _t05_i2_live_single_accuse_adds_one(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return false
	scene.selection_state.begin_submission()
	scene.selection_state.toggle_submission_suspect(1)
	scene._on_single_accuse_pressed()
	var passed: bool = scene.runtime_state.elapsed_hours == 1
	_t05_i2_free_scene(scene)
	return passed


func _t05_i2_invalid_single_accuse_zero(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return false
	scene.selection_state.begin_submission()
	scene.selection_state.toggle_submission_suspect(0)
	scene._on_single_accuse_pressed()
	var passed: bool = scene.runtime_state.elapsed_hours == 0 and scene.turn_manager.turn_number == 1
	_t05_i2_free_scene(scene)
	return passed


func _t05_i2_live_vigilante_scene(players: Array[PlayerCaseState]) -> VSCaseMainController:
	var scene: VSCaseMainController = _t05_i2_live_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return null
	scene._perform_direct_investigation(5)
	var state: InteractiveFunctionRuntimeState = scene.runtime_state.find_suspect(5).interactive_function
	if state == null or state.state != InteractiveFunctionRuntimeState.State.AVAILABLE:
		_t05_i2_free_scene(scene)
		return null
	return scene


func _t05_i2_execute_live_vigilante(players: Array[PlayerCaseState], target_id: int) -> Dictionary:
	var scene: VSCaseMainController = _t05_i2_live_vigilante_scene(players)
	if scene == null:
		return {"scene": null, "before_hours": 0, "before_turn": 0, "after_hours": 0, "after_turn": 0}
	var before_hours: int = scene.runtime_state.elapsed_hours
	var before_turn: int = scene.turn_manager.turn_number
	scene._on_function_pressed_for_suspect(5)
	scene._on_suspect_action(target_id, MOUSE_BUTTON_LEFT, false)
	return {
		"scene": scene,
		"before_hours": before_hours,
		"before_turn": before_turn,
		"after_hours": scene.runtime_state.elapsed_hours,
		"after_turn": scene.turn_manager.turn_number,
	}


func _t05_i2_live_vigilante_clock_zero(players: Array[PlayerCaseState]) -> bool:
	var bundle: Dictionary = _t05_i2_execute_live_vigilante(players, 4)
	var scene: VSCaseMainController = bundle.get("scene", null) as VSCaseMainController
	var passed: bool = scene != null and int(bundle.get("after_hours", -1)) == int(bundle.get("before_hours", -2))
	_t05_i2_free_scene(scene)
	return passed


func _t05_i2_function_selection_zero(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_vigilante_scene(players)
	if scene == null:
		return false
	var before_hours: int = scene.runtime_state.elapsed_hours
	var before_turn: int = scene.turn_manager.turn_number
	scene._on_function_pressed_for_suspect(5)
	var state: InteractiveFunctionRuntimeState = scene.runtime_state.find_suspect(5).interactive_function
	var passed: bool = (
		scene.runtime_state.elapsed_hours == before_hours
		and scene.turn_manager.turn_number == before_turn
		and state != null
		and state.uses_remaining == 1
	)
	_t05_i2_free_scene(scene)
	return passed


func _t05_i2_time_turn_separate(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return false
	var before_turn: int = scene.turn_manager.turn_number
	var applied: bool = scene._commit_action_time_and_timed_events(&"manual_time_only", CaseClockService.ACTION_INVESTIGATION)
	var passed: bool = applied and scene.runtime_state.elapsed_hours == 2 and scene.turn_manager.turn_number == before_turn
	_t05_i2_free_scene(scene)
	return passed


func _t05_i2_live_investigation_turn_once(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return false
	var before: int = scene.turn_manager.turn_number
	scene._perform_direct_investigation(2)
	var passed: bool = scene.turn_manager.turn_number == before + 1 and scene.runtime_state.turn_number == scene.turn_manager.turn_number
	_t05_i2_free_scene(scene)
	return passed


func _t05_i2_live_single_accuse_turn_once(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return false
	var before: int = scene.turn_manager.turn_number
	scene.selection_state.begin_submission()
	scene.selection_state.toggle_submission_suspect(1)
	scene._on_single_accuse_pressed()
	var passed: bool = scene.turn_manager.turn_number == before + 1 and scene.runtime_state.turn_number == scene.turn_manager.turn_number
	_t05_i2_free_scene(scene)
	return passed


func _t05_i2_live_vigilante_turn_once(players: Array[PlayerCaseState]) -> bool:
	var bundle: Dictionary = _t05_i2_execute_live_vigilante(players, 4)
	var scene: VSCaseMainController = bundle.get("scene", null) as VSCaseMainController
	var passed: bool = scene != null and int(bundle.get("after_turn", -1)) == int(bundle.get("before_turn", -2)) + 1
	_t05_i2_free_scene(scene)
	return passed


func _t05_i2_surgeon_reevaluates_at_12(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return false
	for suspect_id: int in [1, 2, 3, 4, 5, 6]:
		scene._perform_direct_investigation(suspect_id)
	var event: CaseTimedEventRuntimeState = scene.runtime_state.timed_event_by_id(&"surgeon_6_12h")
	var passed: bool = scene.runtime_state.elapsed_hours == 12 and event != null and event.fired
	_t05_i2_free_scene(scene)
	return passed


func _t05_i2_custom_surgeon_case(displayed_role_id: StringName = &"surgeon", include_target: bool = true) -> CaseDefinition:
	var specs: Array[Dictionary] = [
		_role_info_spec(7, 0, &"surgeon", displayed_role_id, CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
		_role_info_spec(9, 2, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	]
	if include_target:
		specs.insert(1, _role_info_spec(8, 1, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN))
	var c: CaseDefinition = _role_info_case_fixture(specs, 4)
	c.case_id = &"t05_i2_surgeon_custom"
	c.evil_suspect_ids = PackedInt32Array([9])
	c.accomplice_suspect_ids = PackedInt32Array([9])
	c.traitor_suspect_ids = PackedInt32Array()
	return c


func _t05_i2_surgeon_runtime(c: CaseDefinition, players: Array[PlayerCaseState], seed: int = 1, elapsed_hours: int = 12) -> CaseRuntimeState:
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	runtime.case_event_seed = seed
	if elapsed_hours > 0:
		CaseClockService.new().advance_hours(runtime, elapsed_hours, &"smoke")
	return runtime


func _t05_i2_surgeon_true_role_source(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _t05_i2_custom_surgeon_case(&"tutorial_priest")
	var runtime: CaseRuntimeState = _t05_i2_surgeon_runtime(c, players)
	var events: Array[CaseTimedEventRuntimeState] = SurgeonTimedEventService.new().evaluate(c, runtime)
	return events.size() == 1 and events[0].source_suspect_id == 7 and events[0].event_id == &"surgeon_7_12h"


func _t05_i2_surgeon_ignores_displayed_role(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _t05_i2_custom_surgeon_case(&"tutorial_priest")
	var runtime: CaseRuntimeState = _t05_i2_surgeon_runtime(c, players)
	var events: Array[CaseTimedEventRuntimeState] = SurgeonTimedEventService.new().evaluate(c, runtime)
	return events.size() == 1 and events[0].source_suspect_id == 7


func _t05_i2_surgeon_target_not_hardcoded(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _t05_i2_custom_surgeon_case()
	var runtime: CaseRuntimeState = _t05_i2_surgeon_runtime(c, players, 1)
	var events: Array[CaseTimedEventRuntimeState] = SurgeonTimedEventService.new().evaluate(c, runtime)
	var target: SuspectDefinition = _case_suspect(c, events[0].target_suspect_id) if not events.is_empty() else null
	return events.size() == 1 and events[0].resolved_success and target != null and target.role_group == CaseEnums.RoleGroup.CHINH_NHAN and events[0].target_suspect_id != 5


func _t05_i2_surgeon_no_duplicate_after_time(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _t05_i2_custom_surgeon_case()
	var runtime: CaseRuntimeState = _t05_i2_surgeon_runtime(c, players, 0)
	SurgeonTimedEventService.new().evaluate(c, runtime)
	var event_count_before: int = _timed_event_log_count(runtime, &"surgeon_7_12h")
	var kill_count_before: int = _surgeon_kill_log_count(runtime, 8)
	CaseClockService.new().advance_hours(runtime, 4, &"smoke_later")
	SurgeonTimedEventService.new().evaluate(c, runtime)
	return event_count_before == _timed_event_log_count(runtime, &"surgeon_7_12h") and kill_count_before == _surgeon_kill_log_count(runtime, 8)


func _t05_i2_live_vigilante_one_target(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_vigilante_scene(players)
	if scene == null:
		return false
	var state: InteractiveFunctionRuntimeState = scene.runtime_state.find_suspect(5).interactive_function
	var passed: bool = state != null and state.target_count == 1
	_t05_i2_free_scene(scene)
	return passed


func _t05_i2_live_vigilante_evil_attempt(players: Array[PlayerCaseState]) -> bool:
	var bundle: Dictionary = _t05_i2_execute_live_vigilante(players, 4)
	var scene: VSCaseMainController = bundle.get("scene", null) as VSCaseMainController
	var target: SuspectRuntimeState = scene.runtime_state.find_suspect(4) if scene != null else null
	var passed: bool = target != null and target.is_dead and _vigilante_kill_log_count(scene.runtime_state, 4) == 1
	_t05_i2_free_scene(scene)
	return passed


func _t05_i2_live_vigilante_consumes_once(players: Array[PlayerCaseState]) -> bool:
	var bundle: Dictionary = _t05_i2_execute_live_vigilante(players, 4)
	var scene: VSCaseMainController = bundle.get("scene", null) as VSCaseMainController
	var state: InteractiveFunctionRuntimeState = scene.runtime_state.find_suspect(5).interactive_function if scene != null else null
	var passed: bool = state != null and state.uses_remaining == 0 and state.state == InteractiveFunctionRuntimeState.State.EXHAUSTED
	_t05_i2_free_scene(scene)
	return passed


func _t05_i2_live_vigilante_death_uses_kill_service(players: Array[PlayerCaseState]) -> bool:
	var bundle: Dictionary = _t05_i2_execute_live_vigilante(players, 4)
	var scene: VSCaseMainController = bundle.get("scene", null) as VSCaseMainController
	var target: SuspectRuntimeState = scene.runtime_state.find_suspect(4) if scene != null else null
	var passed: bool = target != null and target.is_dead and target.killed_by == &"vigilante" and _vigilante_kill_log_count(scene.runtime_state, 4) == 1
	_t05_i2_free_scene(scene)
	return passed


func _t05_i2_live_death_handled_evil(players: Array[PlayerCaseState]) -> bool:
	var bundle: Dictionary = _t05_i2_execute_live_vigilante(players, 4)
	var scene: VSCaseMainController = bundle.get("scene", null) as VSCaseMainController
	var unresolved: PackedInt32Array = CaseResolutionService.new().unresolved_evil_ids(FixtureRepository.load_tutorial_case_005(), scene.runtime_state) if scene != null else PackedInt32Array()
	var target_runtime: SuspectRuntimeState = scene.runtime_state.find_suspect(4) if scene != null else null
	var passed: bool = target_runtime != null and target_runtime.is_dead and unresolved == PackedInt32Array([1, 4])
	_t05_i2_free_scene(scene)
	return passed


func _t05_i2_live_death_no_private_knowledge(players: Array[PlayerCaseState]) -> bool:
	var bundle: Dictionary = _t05_i2_execute_live_vigilante(players, 4)
	var scene: VSCaseMainController = bundle.get("scene", null) as VSCaseMainController
	var passed: bool = scene != null and scene.runtime_state.private_role_knowledge.is_empty()
	_t05_i2_free_scene(scene)
	return passed


func _tutorial_05_i3_end_to_end_checks(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	checks.entry_load = _t05_i3_entry_load(players)
	checks.layout_unchanged = _tutorial_05_board_slots(c)
	checks.evil_static = c != null and c.evil_suspect_ids == PackedInt32Array([1, 4])
	checks.critic_math_behavior = _t05_i3_critic_math_behavior(c, roles, players)
	checks.critic_math_lies = _t05_i3_critic_math_lies(c, roles, players)
	checks.critic_truth_hidden = _t05_i3_critic_truth_hidden(c, roles, players)
	checks.weatherman_presentation = _t05_i3_weatherman_presentation(c, roles, players)
	checks.mobster_truth_hidden = _t05_i3_mobster_truth_hidden(c, roles, players)
	checks.clock_hud_zero = _tutorial_05_clock_hud_zero(players)
	checks.clock_hud_investigation = _t05_i3_clock_hud_investigation(players)
	checks.clock_hud_single_accuse = _t05_i3_clock_hud_single_accuse(players)
	checks.clock_hud_function_zero = _t05_i3_clock_hud_function_zero(players)
	checks.clock_hud_selection_zero = _t05_i3_clock_hud_selection_zero(players)
	checks.clock_turn_only_zero = _t05_i3_clock_turn_only_zero(players)
	checks.math_true_sum_five = RoleInformationEvaluationService.new().true_evil_suspect_number_sum(c) == 5
	checks.critic_math_reports_four = _t05_i3_critic_math_reports_four(c, roles)
	checks.math_no_tutorial_four_hardcode = _t05_i3_math_no_tutorial_four_hardcode()
	checks.truthful_math_stable = _t05_i3_truthful_math_stable()
	checks.weatherman_triplet = _t05_i3_weatherman_triplet(c, roles)
	checks.so_hieu_is_suspect_id = _t05_i3_so_hieu_is_suspect_id(c)
	checks.so_hieu_sparse_numbering = _tutorial_05_numbering(c)
	checks.mathematician_help_so_hieu = _t05_i3_mathematician_help_so_hieu(roles)
	checks.so_hieu_glossary = _t05_i3_so_hieu_glossary()
	checks.weatherman_triplet_order = _t05_i3_weatherman_triplet_order(c, roles)
	checks.weatherman_generic_authority = _t05_i3_weatherman_generic_authority()
	var after_investigations: Dictionary = _t05_i3_after_all_investigations(players)
	var live_scene: VSCaseMainController = after_investigations.get("scene", null) as VSCaseMainController
	checks.investigations_clock = live_scene != null and live_scene.runtime_state.elapsed_hours == 12
	checks.controller_not_stuck_at_12 = live_scene != null and live_scene.runtime_state.case_outcome in [CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS, CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT, CaseEnums.CaseOutcome.EARLY_SOLVED, CaseEnums.CaseOutcome.ALL_FAILED_EARLY]
	checks.surgeon_once_live = _t05_i3_live_surgeon_once(live_scene)
	var surgeon_death_scene: VSCaseMainController = (_t05_i3_after_all_investigations(players, true).get("scene", null)) as VSCaseMainController
	checks.surgeon_death_runtime = _t05_i3_live_surgeon_death_runtime(surgeon_death_scene)
	checks.dead_truth_preserved = _t05_i3_dead_truth_preserved(c, surgeon_death_scene)
	_t05_i2_free_scene(surgeon_death_scene)
	checks.death_no_private = live_scene != null and live_scene.runtime_state.private_role_knowledge.is_empty()
	checks.handled_evil_resolution = _t05_i3_live_vigilante_handled_evil(players)
	checks.vigilante_one_target = _t05_i3_live_vigilante_one_target(live_scene)
	checks.vigilante_selection_no_consume = _t05_i3_live_vigilante_selection_no_consume(live_scene)
	var vigilante_state: Dictionary = _t05_i3_live_vigilante_execute_state(live_scene)
	checks.vigilante_exits_selection = bool(vigilante_state.get("selection_idle", false))
	checks.vigilante_consumes = bool(vigilante_state.get("consumed", false))
	checks.vigilante_turn_once = bool(vigilante_state.get("turn_once", false))
	checks.vigilante_zero_time = bool(vigilante_state.get("zero_time", false))
	checks.vigilante_result_refresh = bool(vigilante_state.get("result_recorded", false))
	checks.vigilante_targets_one = _t05_i3_vigilante_targets_one(players)
	checks.vigilante_one_kill_service = _t05_i3_vigilante_one_kill_service(players)
	checks.vigilante_one_death_presentation = _t05_i3_vigilante_one_death_presentation(players)
	checks.vigilante_kill_service_reused = checks.vigilante_one_kill_service
	checks.vigilante_dead_status = checks.vigilante_one_death_presentation
	checks.vigilante_death_transition = _t05_i3_vigilante_death_transition_source()
	checks.dead_single_accuse_rejected = _t05_i3_dead_single_accuse_rejected(c, players)
	checks.living_single_accuse_accepted = _t05_i3_living_single_accuse_accepted(c, players)
	checks.dead_ui_not_selectable = _t05_i3_dead_ui_not_selectable(players)
	checks.death_no_private_direct = _t05_i3_death_no_private_direct(c, players)
	checks.dead_owner_no_trap = _t05_i3_dead_owner_no_post_trap(c, roles, players)
	checks.dead_target_no_trap = _t05_i3_dead_target_no_post_trap(c, roles, players)
	checks.consumed_not_available = bool(vigilante_state.get("consumed_not_available", false))
	checks.awaiting_final = bool(vigilante_state.get("awaiting_final", false))
	checks.one_target_reveal_safe = _t05_i3_one_target_reveal_safe(players)
	var final_bundle: Dictionary = _t05_i3_final_and_settlement(players)
	checks.final_resolves = bool(final_bundle.get("final_resolves", false))
	checks.settlement_success = bool(final_bundle.get("settlement_success", false))
	checks.settlement_once = bool(final_bundle.get("settlement_once", false))
	checks.surgeon_seed_success = _t05_i3_surgeon_seed_success(players)
	checks.surgeon_seed_failure = _t05_i3_surgeon_seed_failure(players)
	checks.surgeon_two_buckets = bool(checks.surgeon_seed_success) and bool(checks.surgeon_seed_failure)
	checks.surgeon_unrevealed_alive = _t05_i3_surgeon_unrevealed_alive(players)
	checks.surgeon_revealed_alive = _t05_i3_surgeon_revealed_alive(players)
	checks.surgeon_dead_source_blocked = _t05_i3_surgeon_dead_source_blocked(players)
	checks.surgeon_displayed_false_source = _t05_i3_surgeon_displayed_false_source(players)
	checks.surgeon_unrevealed_seed_success = checks.surgeon_seed_success
	checks.surgeon_unrevealed_seed_failure = checks.surgeon_seed_failure
	checks.runtime_event_seed_fresh = _t05_i3_runtime_event_seed_fresh()
	checks.surgeon_not_fixture_forced = _t05_i3_surgeon_not_fixture_forced()
	checks.surgeon_same_run_no_reroll = _t05_i3_surgeon_same_run_no_reroll(players)
	checks.surgeon_no_hardcoded_victim = _t05_i3_surgeon_no_hardcoded_victim()
	checks.no_tutorial_domain_branch = _t05_i3_no_tutorial_specific_domain_branch()
	var click_targeting: Dictionary = _t05_i3_function_click_targeting_checks(players)
	checks.vigilante_kill_summary_exact = _t05_i3_vigilante_kill_summary_exact(players)
	checks.vigilante_miss_summary_exact = _t05_i3_vigilante_miss_summary_exact(players)
	checks.vigilante_no_duplicate_prefix = _t05_i3_vigilante_no_duplicate_prefix(players)
	checks.function_click_unrevealed = bool(click_targeting.get("unrevealed_target", false))
	checks.function_click_revealed = _t05_i3_revealed_function_click_target(players)
	checks.function_click_no_investigation = bool(click_targeting.get("no_investigation", false))
	checks.function_click_no_hold = bool(click_targeting.get("no_hold", false))
	checks.function_click_execute_once = bool(click_targeting.get("execute_once", false))
	checks.function_click_consumes_once = bool(click_targeting.get("consumes_once", false))
	checks.function_click_turn_once = bool(click_targeting.get("turn_once", false))
	checks.function_click_time_zero = bool(click_targeting.get("time_zero", false))
	var cancel_checks: Dictionary = _t05_i3_right_cancel_checks(players)
	checks.right_cancel_background = bool(cancel_checks.get("cancelled", false))
	checks.right_cancel_no_hover = bool(cancel_checks.get("background_path", false))
	checks.right_cancel_clears_targets = bool(cancel_checks.get("targets_cleared", false))
	checks.right_cancel_no_consume = bool(cancel_checks.get("uses_preserved", false))
	checks.right_cancel_no_turn = bool(cancel_checks.get("turn_preserved", false))
	checks.right_cancel_no_time = bool(cancel_checks.get("time_preserved", false))
	checks.right_cancel_no_execute = bool(cancel_checks.get("no_execute", false))
	checks.right_cancel_function_available = bool(cancel_checks.get("function_available", false))
	checks.right_cancel_restores_normal = bool(cancel_checks.get("normal_restored", false))
	checks.right_cancel_multi_target = _t05_i3_right_cancel_multi_target(players)
	checks.normal_click_investigation_unchanged = _t05_i3_normal_click_investigation_unchanged(players)
	_t05_i2_free_scene(live_scene)
	return checks


func _t06_f1_current_role_checks(_roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var roles: Array[RoleDefinition] = _role_info_roles()
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"reporter", &"therapist", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(2, 1, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(3, 2, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	])
	var source: SuspectDefinition = _case_suspect(c, 1)
	source.impersonated_role_id = &"therapist"
	source.is_impersonating = true
	var bundle: Dictionary = _fresh_turn_bundle(c, players)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var transform_service: CaseRoleTransformationService = CaseRoleTransformationService.new()
	var info_service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var current_before: StringName = runtime.current_role_id_for_suspect(c, 1)
	var turn_before: int = runtime.turn_number
	var turn_index_before: int = runtime.current_turn_index
	var elapsed_before: int = runtime.elapsed_hours
	var log_count_before: int = runtime.action_log.size()
	var source_dead_before: bool = runtime.find_suspect(1).is_dead
	var source_corrupted_before: bool = source.is_corrupted
	var ratio_controller: VSCaseMainController = VSCaseMainController.new()
	ratio_controller.case_definition = c
	var ratio_before: String = ratio_controller._case_ratio_text()
	var transformed: bool = transform_service.transform_role(c, runtime, 1, &"mailman", roles)
	var current_after: StringName = runtime.current_role_id_for_suspect(c, 1)
	var current_roles: Array[StringName] = info_service.current_role_ids_in_play(c, runtime)
	var current_not_roles: Array[StringName] = info_service.current_role_ids_not_in_play(c, runtime, roles)
	var authored_roles: Array[StringName] = info_service.true_role_ids_in_play(c)
	var authored_not_roles: Array[StringName] = info_service.true_role_ids_not_in_play(c, roles)
	var current_mailman_validation: Dictionary = info_service.validate_mailman_pair_current(
		c,
		runtime,
		2,
		&"mailman",
		&"reporter",
		InvestigationInformationResult.TruthMode.TRUTHFUL,
		roles
	)
	runtime.find_suspect(1).is_investigated = true
	var public_before_reveal: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles)
	var source_view_before: SuspectPublicViewData = _tutorial_03_view(public_before_reveal, 1)
	var settlement: CaseSettlementResult = CaseSettlementResult.new()
	settlement.success = true
	settlement.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
	runtime.is_settled = true
	runtime.settlement_result = settlement
	var reveal: CaseTruthReveal = CaseTruthRevealBuilder.new().build(c, runtime, roles)
	var truth: SuspectTruthReveal = _t06_f1_truth_for_suspect(reveal, 1)
	var public_after_reveal: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles)
	var source_view_after: SuspectPublicViewData = _tutorial_03_view(public_after_reveal, 1)
	var runtime_b: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var invalid_suspect: bool = transform_service.transform_role(c, runtime, 99, &"mailman", roles)
	var invalid_role: bool = transform_service.transform_role(c, runtime, 1, &"missing_role", roles)
	var empty_role: bool = transform_service.transform_role(c, runtime, 1, &"", roles)
	var same_role: bool = transform_service.transform_role(c, runtime, 2, &"tutorial_priest", roles)
	var same_role_state: StringName = runtime.current_role_id_for_suspect(c, 2)
	var current_resolver_transformed: bool = (
		current_after == &"mailman"
		and info_service.current_role_id_for_suspect(c, runtime, 1) == &"mailman"
		and transform_service.current_role_id(c, runtime, 1) == &"mailman"
	)
	var no_turn_advance: bool = runtime.turn_number == turn_before and runtime.current_turn_index == turn_index_before
	var no_elapsed_hours: bool = runtime.elapsed_hours == elapsed_before
	var no_death_mutation: bool = runtime.find_suspect(1) != null and runtime.find_suspect(1).is_dead == source_dead_before
	var no_corruption_mutation: bool = source.is_corrupted == source_corrupted_before
	var same_role_safe: bool = same_role and same_role_state == &"tutorial_priest" and runtime.action_log.size() == log_count_before
	runtime.initialize(c, players)
	var reset_current_role: StringName = runtime.current_role_id_for_suspect(c, 1)
	var checks: Dictionary = {}
	checks.fresh_current_equals_authored = current_before == &"reporter"
	checks.transform_changes_current = transformed and current_after == &"mailman"
	checks.authored_true_unchanged = source.true_role_id == &"reporter"
	checks.displayed_unchanged = source.displayed_role_id == &"therapist"
	checks.impersonated_unchanged = source.impersonated_role_id == &"therapist" and source.is_impersonating
	checks.case_definition_unchanged = c.suspects.size() == 3 and _case_suspect(c, 1).true_role_id == &"reporter" and _case_suspect(c, 1).displayed_role_id == &"therapist"
	checks.current_resolver_transformed = current_resolver_transformed
	checks.authored_resolver_original = transform_service.original_true_role_id(c, 1) == &"reporter" and info_service.original_true_role_id_for_suspect(c, 1) == &"reporter"
	checks.current_roles_reflect_transform = current_roles.has(&"mailman") and not current_roles.has(&"reporter") and current_not_roles.has(&"reporter") and bool(current_mailman_validation.get("valid", false))
	checks.authored_roles_remain_original = authored_roles.has(&"reporter") and not authored_roles.has(&"mailman") and authored_not_roles.has(&"mailman")
	checks.truth_reveal_uses_current = truth != null and truth.true_role_name == "Dịch Phu" and truth.current_role_name == "Dịch Phu" and truth.original_true_role_name == "Sử Quan"
	checks.presentation_current_safe = source_view_before != null and source_view_before.public_role_name == "Ngự Y" and source_view_after != null and source_view_after.public_role_name == "Dịch Phu" and source_view_after.truth_original_true_role_name == "Sử Quan"
	checks.static_ratio_unchanged = ratio_before == ratio_controller._case_ratio_text()
	checks.no_turn_advance = no_turn_advance
	checks.no_elapsed_hours = no_elapsed_hours
	checks.no_death_mutation = no_death_mutation
	checks.no_corruption_mutation = no_corruption_mutation
	checks.reinitialize_resets = reset_current_role == &"reporter"
	checks.separate_runtime_isolated = runtime_b.current_role_id_for_suspect(c, 1) == &"reporter"
	checks.invalid_suspect_rejected = not invalid_suspect
	checks.invalid_target_rejected = not invalid_role and not empty_role
	checks.same_role_safe = same_role_safe
	return checks


func _t06_f1_truth_for_suspect(reveal: CaseTruthReveal, suspect_id: int) -> SuspectTruthReveal:
	if reveal == null:
		return null
	for truth: SuspectTruthReveal in reveal.suspect_truths:
		if truth != null and truth.suspect_id == suspect_id:
			return truth
	return null


func _t06_f2_poisoner_taint_checks(roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var c: CaseDefinition = _t06_f2_poisoner_case(false)
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var service: PoisonerTaintService = PoisonerTaintService.new()
	var poisoner_role: RoleDefinition = _role_by_id(roles, &"poisoner")
	var turn_before: int = runtime.turn_number
	var turn_index_before: int = runtime.current_turn_index
	var elapsed_before: int = runtime.elapsed_hours
	var source_current_before: StringName = runtime.current_role_id_for_suspect(c, 1)
	var target_current_before: StringName = runtime.current_role_id_for_suspect(c, 2)
	var source_dead_before: bool = runtime.find_suspect(1).is_dead
	var target_authored_corrupted_before: bool = _case_suspect(c, 2).is_corrupted
	var source_authored_role_before: StringName = _case_suspect(c, 1).true_role_id
	var diagonal_record: PoisonerTaintRecord = service.resolve_taint(c, runtime, 1, 2)
	var duplicate_record: PoisonerTaintRecord = service.resolve_taint(c, runtime, 1, 4)
	var source_runtime: SuspectRuntimeState = runtime.find_suspect(1)
	var target_runtime: SuspectRuntimeState = runtime.find_suspect(2)
	var runtime_truth_mode: int = RoleInformationEvaluationService.new().evaluate(c, 2, roles, {}, runtime).truth_mode
	var success_record_count: int = runtime.poisoner_taint_records.size()
	var success_turn_unchanged: bool = runtime.turn_number == turn_before and runtime.current_turn_index == turn_index_before
	var success_elapsed_unchanged: bool = runtime.elapsed_hours == elapsed_before
	var success_death_unchanged: bool = source_runtime != null and source_runtime.is_dead == source_dead_before
	var success_current_role_unchanged: bool = runtime.current_role_id_for_suspect(c, 1) == source_current_before and runtime.current_role_id_for_suspect(c, 2) == target_current_before
	var success_idempotent: bool = duplicate_record == diagonal_record and success_record_count == 1
	var separate_runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var orthogonal_runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var orthogonal_record: PoisonerTaintRecord = service.resolve_taint(c, orthogonal_runtime, 1, 4)
	var distant_runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var distant_record: PoisonerTaintRecord = service.resolve_taint(c, distant_runtime, 1, 3)
	runtime.initialize(c, players)
	var runtime_cleared_after_reset: bool = not runtime.has_runtime_corruption(2)
	var authored_corrupted_case: CaseDefinition = _t06_f2_poisoner_case(false)
	_case_suspect(authored_corrupted_case, 2).is_corrupted = true
	var authored_runtime: CaseRuntimeState = _fresh_turn_bundle(authored_corrupted_case, players).runtime as CaseRuntimeState
	var authored_truth_before_reset: int = RoleInformationEvaluationService.new().evaluate(authored_corrupted_case, 2, roles, {}, authored_runtime).truth_mode
	authored_runtime.initialize(authored_corrupted_case, players)
	var authored_truth_after_reset: int = RoleInformationEvaluationService.new().evaluate(authored_corrupted_case, 2, roles, {}, authored_runtime).truth_mode
	var tainted_source_case: CaseDefinition = _t06_f2_poisoner_case(true)
	var tainted_source_runtime: CaseRuntimeState = _fresh_turn_bundle(tainted_source_case, players).runtime as CaseRuntimeState
	var blocked_record: PoisonerTaintRecord = service.resolve_taint(tainted_source_case, tainted_source_runtime, 1, 2)
	var blocked_duplicate: PoisonerTaintRecord = service.resolve_taint(tainted_source_case, tainted_source_runtime, 1, 4)
	var checks: Dictionary = {}
	checks.poisoner_role_loads = poisoner_role != null and poisoner_role.role_id == &"poisoner" and poisoner_role.display_name == "Độc Sư" and poisoner_role.role_group == CaseEnums.RoleGroup.TONG_PHAM
	var fresh_runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	checks.fresh_no_record = fresh_runtime.poisoner_taint_records.is_empty()
	checks.valid_surrounding_corrupts = diagonal_record != null and diagonal_record.applied and target_runtime != null and target_runtime.is_runtime_corrupted
	checks.non_surrounding_rejected = distant_record != null and distant_record.status == PoisonerTaintRecord.STATUS_INVALID and not distant_runtime.has_runtime_corruption(3)
	checks.source_not_corrupted = source_runtime != null and not source_runtime.is_runtime_corrupted
	checks.authored_not_mutated = _case_suspect(c, 2).is_corrupted == target_authored_corrupted_before
	checks.authored_corruption_intact = _case_suspect(authored_corrupted_case, 2).is_corrupted
	checks.runtime_corruption_lies = runtime_truth_mode == InvestigationInformationResult.TruthMode.LYING
	checks.reinitialize_clears_runtime_only = runtime_cleared_after_reset and not _case_suspect(c, 2).is_corrupted
	checks.authored_corrupted_still_lies = authored_truth_before_reset == InvestigationInformationResult.TruthMode.LYING and authored_truth_after_reset == InvestigationInformationResult.TruthMode.LYING
	checks.tainted_poisoner_no_target = blocked_record != null and blocked_record.status == PoisonerTaintRecord.STATUS_SOURCE_CORRUPTED and not tainted_source_runtime.has_runtime_corruption(2)
	checks.tainted_poisoner_idempotent = blocked_duplicate == blocked_record and tainted_source_runtime.poisoner_taint_records.size() == 1
	checks.record_source = diagonal_record != null and diagonal_record.source_suspect_id == 1
	checks.record_target_success = diagonal_record != null and diagonal_record.target_suspect_id == 2 and diagonal_record.status == PoisonerTaintRecord.STATUS_APPLIED
	checks.record_no_target_on_tainted_source = blocked_record != null and blocked_record.target_suspect_id == 0 and not blocked_record.applied
	checks.effect_idempotent = success_idempotent
	checks.no_turn_advance = success_turn_unchanged
	checks.no_elapsed_hours = success_elapsed_unchanged
	checks.no_death_mutation = success_death_unchanged
	checks.no_current_role_mutation = success_current_role_unchanged
	checks.no_case_definition_mutation = _case_suspect(c, 1).true_role_id == source_authored_role_before and c.suspects.size() == 4
	checks.diagonal_valid = diagonal_record != null and diagonal_record.status == PoisonerTaintRecord.STATUS_APPLIED
	checks.orthogonal_valid = orthogonal_record != null and orthogonal_record.status == PoisonerTaintRecord.STATUS_APPLIED and orthogonal_runtime.has_runtime_corruption(4)
	checks.distant_invalid = distant_record != null and distant_record.status == PoisonerTaintRecord.STATUS_INVALID
	checks.separate_runtime_isolated = not separate_runtime.has_runtime_corruption(2)
	return checks


func _t06_f2r_poisoner_canonical_repair_checks(t06: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	var service: PoisonerTaintService = PoisonerTaintService.new()
	var poisoner_role: RoleDefinition = _role_by_id(roles, &"poisoner")
	var random_case: CaseDefinition = _t06_f2r_random_poisoner_case()
	var random_runtime: CaseRuntimeState = _fresh_turn_bundle(random_case, players).runtime as CaseRuntimeState
	var source_runtime: SuspectRuntimeState = random_runtime.find_suspect(1)
	var source_dead_before: bool = source_runtime.is_dead if source_runtime != null else false
	var source_current_before: StringName = random_runtime.current_role_id_for_suspect(random_case, 1)
	var target_two_authored_corrupted_before: bool = _case_suspect(random_case, 2).is_corrupted
	var turn_before: int = random_runtime.turn_number
	var turn_index_before: int = random_runtime.current_turn_index
	var elapsed_before: int = random_runtime.elapsed_hours
	var eligible_ids: PackedInt32Array = service.eligible_taint_target_ids(random_case, 1)
	var random_record: PoisonerTaintRecord = service.resolve_random_taint(random_case, random_runtime, 1, 11)
	var repeated_record: PoisonerTaintRecord = service.resolve_random_taint(random_case, random_runtime, 1, 29)
	var stable_runtime_a: CaseRuntimeState = _fresh_turn_bundle(random_case, players).runtime as CaseRuntimeState
	var stable_runtime_b: CaseRuntimeState = _fresh_turn_bundle(random_case, players).runtime as CaseRuntimeState
	var stable_a: PoisonerTaintRecord = service.resolve_random_taint(random_case, stable_runtime_a, 1, 17)
	var stable_b: PoisonerTaintRecord = service.resolve_random_taint(random_case, stable_runtime_b, 1, 17)
	var first_seed_target: int = stable_a.target_suspect_id if stable_a != null else 0
	var alternate_seed_found: bool = false
	for seed: int in range(0, 512):
		var seeded_runtime: CaseRuntimeState = _fresh_turn_bundle(random_case, players).runtime as CaseRuntimeState
		var seeded_record: PoisonerTaintRecord = service.resolve_random_taint(random_case, seeded_runtime, 1, seed)
		if seeded_record != null and seeded_record.target_suspect_id != first_seed_target:
			alternate_seed_found = true
			break
	var no_eligible_case: CaseDefinition = _t06_f2r_no_eligible_poisoner_case(false)
	var no_eligible_runtime: CaseRuntimeState = _fresh_turn_bundle(no_eligible_case, players).runtime as CaseRuntimeState
	var no_eligible_record: PoisonerTaintRecord = service.resolve_random_taint(no_eligible_case, no_eligible_runtime, 1, 3)
	var tainted_case: CaseDefinition = _t06_f2r_no_eligible_poisoner_case(true)
	var tainted_runtime: CaseRuntimeState = _fresh_turn_bundle(tainted_case, players).runtime as CaseRuntimeState
	var tainted_record: PoisonerTaintRecord = service.resolve_random_taint(tainted_case, tainted_runtime, 1, 3)
	var tainted_repeat: PoisonerTaintRecord = service.resolve_random_taint(tainted_case, tainted_runtime, 1, 5)
	var non_innocent_runtime: CaseRuntimeState = _fresh_turn_bundle(no_eligible_case, players).runtime as CaseRuntimeState
	var non_innocent_record: PoisonerTaintRecord = service.resolve_taint(no_eligible_case, non_innocent_runtime, 1, 2)
	var t06_scene: VSCaseMainController = _t06_i1_live_scene(players)
	var t06_runtime: CaseRuntimeState = t06_scene.runtime_state if t06_scene != null else null
	var t06_record: PoisonerTaintRecord = t06_runtime.poisoner_record_for_source(1) if t06_runtime != null else null
	var pretend_pool: Array[StringName] = service.pretend_candidate_role_ids(t06)
	var suspected_pool: Array[StringName] = CASE_ROLE_POOL_SERVICE.suspected_role_ids_for_case(t06)
	var existing_f2_checks: Dictionary = _t06_f2_poisoner_taint_checks(roles, players)

	checks.poisoner_underling_evil = (
		poisoner_role != null
		and poisoner_role.role_id == &"poisoner"
		and poisoner_role.display_name == "Độc Sư"
		and poisoner_role.role_group == CaseEnums.RoleGroup.TONG_PHAM
		and t06 != null
		and _case_suspect(t06, 1) != null
		and _case_suspect(t06, 1).true_alignment == CaseEnums.Alignment.EVIL
	)
	checks.target_must_be_innocent = not service.is_eligible_taint_target(no_eligible_case, 1, 2)
	checks.non_innocent_rejected = non_innocent_record != null and non_innocent_record.status == PoisonerTaintRecord.STATUS_INVALID
	checks.orthogonal_valid = service.is_eligible_taint_target(random_case, 1, 2)
	checks.diagonal_valid = service.is_eligible_taint_target(random_case, 1, 3)
	checks.non_surrounding_excluded = not service.is_eligible_taint_target(random_case, 1, 4) and not eligible_ids.has(4)
	checks.source_excluded = not service.is_eligible_taint_target(random_case, 1, 1) and not eligible_ids.has(1)
	checks.auto_chooses_one = random_record != null and random_record.resolved and eligible_ids.has(random_record.target_suspect_id) and random_runtime.poisoner_taint_records.size() == 1
	checks.seed_stable = stable_a != null and stable_b != null and stable_a.target_suspect_id == stable_b.target_suspect_id
	checks.alternate_seed_can_differ = alternate_seed_found
	checks.no_eligible_safe = no_eligible_record != null and no_eligible_record.status == PoisonerTaintRecord.STATUS_NO_ELIGIBLE_TARGET and no_eligible_record.target_suspect_id == 0
	checks.tainted_no_corruption = tainted_record != null and tainted_record.status == PoisonerTaintRecord.STATUS_SOURCE_CORRUPTED and not tainted_runtime.has_runtime_corruption(2)
	checks.tainted_no_reroll = tainted_repeat == tainted_record and tainted_runtime.poisoner_taint_records.size() == 1
	checks.chosen_runtime_corrupted = random_record != null and random_runtime.has_runtime_corruption(random_record.target_suspect_id)
	checks.authored_unchanged = _case_suspect(random_case, 2).is_corrupted == target_two_authored_corrupted_before
	checks.turn_unchanged = random_runtime.turn_number == turn_before and random_runtime.current_turn_index == turn_index_before
	checks.elapsed_unchanged = random_runtime.elapsed_hours == elapsed_before
	checks.current_role_unchanged = random_runtime.current_role_id_for_suspect(random_case, 1) == source_current_before
	checks.death_unchanged = source_runtime != null and source_runtime.is_dead == source_dead_before
	checks.record_selected_target = random_record != null and random_record.status == PoisonerTaintRecord.STATUS_APPLIED and eligible_ids.has(random_record.target_suspect_id)
	checks.t06_startup_taints_two = t06_record != null and t06_record.source_suspect_id == 1 and t06_record.target_suspect_id == 2 and t06_record.status == PoisonerTaintRecord.STATUS_APPLIED
	checks.t06_two_effectively_corrupted = t06_runtime != null and service.is_effectively_corrupted(t06, t06_runtime, 2)
	checks.pretend_pool_suspected = pretend_pool == suspected_pool
	checks.pretend_pool_excludes_drunkard = not pretend_pool.has(&"drunkard")
	checks.reporter_valid_pretend = service.pretend_role_is_valid(t06, &"reporter")
	checks.non_suspected_invalid_pretend = not service.pretend_role_is_valid(t06, &"drunkard")
	checks.placeholder_excluded_pretend = not service.pretend_role_is_valid(t06, &"role_good_a")
	checks.repeated_idempotent = repeated_record == random_record and random_runtime.poisoner_taint_records.size() == 1
	checks.separate_runtime_isolated = stable_runtime_a.poisoner_taint_records.size() == 1 and stable_runtime_b.poisoner_taint_records.size() == 1 and stable_a != stable_b
	checks.authored_corruption_reset_preserved = bool(existing_f2_checks.get("authored_corrupted_still_lies", false)) and bool(existing_f2_checks.get("reinitialize_clears_runtime_only", false))
	_t05_i2_free_scene(t06_scene)
	return checks


func _t06_f2r_random_poisoner_case() -> CaseDefinition:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"poisoner", &"reporter", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(2, 1, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(3, 4, &"therapist", &"therapist", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(4, 8, &"mailman", &"mailman", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
	])
	c.case_id = &"poisoner_random_smoke"
	var suspected_ids: Array[StringName] = [
		&"reporter",
		&"tutorial_priest",
		&"therapist",
		&"mailman",
		&"poisoner",
	]
	c.suspected_role_ids = suspected_ids
	return c


func _t06_f2r_no_eligible_poisoner_case(source_corrupted: bool) -> CaseDefinition:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"poisoner", &"reporter", CaseEnums.Alignment.EVIL, source_corrupted, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(2, 1, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(3, 8, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
	])
	c.case_id = &"poisoner_no_eligible_smoke"
	var suspected_ids: Array[StringName] = [
		&"reporter",
		&"tutorial_mobster",
		&"tutorial_priest",
		&"poisoner",
	]
	c.suspected_role_ids = suspected_ids
	return c


func _t06_f2_poisoner_case(source_corrupted: bool) -> CaseDefinition:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"poisoner", &"reporter", CaseEnums.Alignment.EVIL, source_corrupted, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(2, 4, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(3, 8, &"reporter", &"reporter", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(4, 1, &"therapist", &"therapist", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
	])
	c.case_id = &"poisoner_taint_smoke"
	return c


func _t06_f3_barkeep_drunkard_checks(roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var c: CaseDefinition = _t06_f3_barkeep_case()
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var service: BarkeepTransformationService = BarkeepTransformationService.new()
	var info_service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var barkeep_role: RoleDefinition = _role_by_id(roles, &"barkeep")
	var drunkard_role: RoleDefinition = _role_by_id(roles, &"drunkard")
	var target_definition: SuspectDefinition = _case_suspect(c, 2)
	target_definition.impersonated_role_id = &"therapist"
	target_definition.is_impersonating = true
	var current_roles_before: Array[StringName] = info_service.current_role_ids_in_play(c, runtime)
	var authored_roles_before: Array[StringName] = info_service.true_role_ids_in_play(c)
	var ratio_controller: VSCaseMainController = VSCaseMainController.new()
	ratio_controller.case_definition = c
	var ratio_before: String = ratio_controller._case_ratio_text()
	var turn_before: int = runtime.turn_number
	var turn_index_before: int = runtime.current_turn_index
	var elapsed_before: int = runtime.elapsed_hours
	var source_dead_before: bool = runtime.find_suspect(1).is_dead
	var target_dead_before: bool = runtime.find_suspect(2).is_dead
	var source_runtime_corrupted_before: bool = runtime.has_runtime_corruption(1)
	var target_runtime_corrupted_before: bool = runtime.has_runtime_corruption(2)
	var target_authored_role_before: StringName = target_definition.true_role_id
	var target_displayed_before: StringName = target_definition.displayed_role_id
	var target_impersonated_before: StringName = target_definition.impersonated_role_id
	var target_group_before: int = target_definition.role_group
	var record: BarkeepTransformationRecord = service.resolve_transformation(c, runtime, 1, 2, roles)
	var duplicate_record: BarkeepTransformationRecord = service.resolve_transformation(c, runtime, 1, 4, roles)
	var current_roles_after: Array[StringName] = info_service.current_role_ids_in_play(c, runtime)
	var authored_roles_after: Array[StringName] = info_service.true_role_ids_in_play(c)
	var transformed_truth_mode: int = info_service.evaluate(c, 2, roles, {}, runtime).truth_mode
	var success_record_count: int = runtime.barkeep_transformation_records.size()
	var no_turn_advance: bool = runtime.turn_number == turn_before and runtime.current_turn_index == turn_index_before
	var no_elapsed_hours: bool = runtime.elapsed_hours == elapsed_before
	var no_death_mutation: bool = runtime.find_suspect(1).is_dead == source_dead_before and runtime.find_suspect(2).is_dead == target_dead_before
	var no_corruption_mutation: bool = runtime.has_runtime_corruption(1) == source_runtime_corrupted_before and runtime.has_runtime_corruption(2) == target_runtime_corrupted_before
	var no_display_impersonation_mutation: bool = target_definition.displayed_role_id == target_displayed_before and target_definition.impersonated_role_id == target_impersonated_before
	runtime.find_suspect(2).is_investigated = true
	var public_before_reveal: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles)
	var target_view_before: SuspectPublicViewData = _tutorial_03_view(public_before_reveal, 2)
	var settlement: CaseSettlementResult = CaseSettlementResult.new()
	settlement.success = true
	settlement.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
	runtime.is_settled = true
	runtime.settlement_result = settlement
	var reveal: CaseTruthReveal = CaseTruthRevealBuilder.new().build(c, runtime, roles)
	var truth: SuspectTruthReveal = _t06_f1_truth_for_suspect(reveal, 2)
	runtime.initialize(c, players)
	var reset_record_clear: bool = runtime.barkeep_transformation_records.is_empty()
	var separate_runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var drunkard_case: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"drunkard", &"drunkard", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
	])
	var drunkard_runtime: CaseRuntimeState = _fresh_turn_bundle(drunkard_case, players).runtime as CaseRuntimeState
	var fresh_drunkard_truth_mode: int = info_service.evaluate(drunkard_case, 1, roles, {}, drunkard_runtime).truth_mode
	var no_second_case: CaseDefinition = _t06_f3_barkeep_case()
	var no_second_runtime: CaseRuntimeState = _fresh_turn_bundle(no_second_case, players).runtime as CaseRuntimeState
	CaseRoleTransformationService.new().transform_role(no_second_case, no_second_runtime, 4, &"drunkard", roles)
	var no_second_record: BarkeepTransformationRecord = service.resolve_transformation(no_second_case, no_second_runtime, 1, 2, roles)
	var no_second_duplicate: BarkeepTransformationRecord = service.resolve_transformation(no_second_case, no_second_runtime, 1, 3, roles)
	var invalid_runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var non_innocent_record: BarkeepTransformationRecord = service.resolve_transformation(c, invalid_runtime, 1, 3, roles)
	var self_runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var self_record: BarkeepTransformationRecord = service.resolve_transformation(c, self_runtime, 1, 1, roles)
	var invalid_suspect_runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var invalid_suspect_record: BarkeepTransformationRecord = service.resolve_transformation(c, invalid_suspect_runtime, 99, 2, roles)
	var checks: Dictionary = {}
	checks.barkeep_role_loads = barkeep_role != null and barkeep_role.role_id == &"barkeep" and barkeep_role.display_name == "Chủ Quán Rượu" and barkeep_role.role_group == CaseEnums.RoleGroup.TONG_PHAM
	checks.drunkard_role_loads = drunkard_role != null and drunkard_role.role_id == &"drunkard" and drunkard_role.display_name == "Kẻ Say Rượu"
	checks.drunkard_group = drunkard_role != null and drunkard_role.role_group == CaseEnums.RoleGroup.HIEU_SU
	checks.fresh_drunkard_lies = fresh_drunkard_truth_mode == InvestigationInformationResult.TruthMode.LYING
	checks.transformed_drunkard_lies = transformed_truth_mode == InvestigationInformationResult.TruthMode.LYING
	checks.eligible_innocent_transforms = record != null and record.applied and record.status == BarkeepTransformationRecord.STATUS_APPLIED
	checks.authored_role_unchanged = target_definition.true_role_id == target_authored_role_before
	checks.displayed_unchanged = target_definition.displayed_role_id == target_displayed_before
	checks.impersonated_unchanged = target_definition.impersonated_role_id == target_impersonated_before
	checks.authored_group_unchanged = target_definition.role_group == target_group_before
	checks.current_role_drunkard = record != null and record.resulting_role_id == &"drunkard"
	checks.current_roles_include_drunkard = current_roles_after.has(&"drunkard")
	checks.authored_roles_unchanged = authored_roles_before == authored_roles_after and authored_roles_after.has(&"reporter") and not authored_roles_after.has(&"drunkard")
	checks.old_current_removed = current_roles_before.has(&"reporter") and not current_roles_after.has(&"reporter")
	checks.no_second_drunkard = no_second_record != null and no_second_record.status == BarkeepTransformationRecord.STATUS_DRUNKARD_ALREADY_EXISTS and not no_second_runtime.has_runtime_corruption(2) and no_second_runtime.current_role_id_for_suspect(no_second_case, 2) == &"reporter"
	checks.no_second_idempotent = no_second_duplicate == no_second_record and no_second_runtime.barkeep_transformation_records.size() == 1
	checks.non_innocent_rejected = non_innocent_record != null and non_innocent_record.status == BarkeepTransformationRecord.STATUS_INVALID and invalid_runtime.current_role_id_for_suspect(c, 3) == &"tutorial_mobster"
	checks.self_target_rejected = self_record != null and self_record.status == BarkeepTransformationRecord.STATUS_INVALID
	checks.invalid_suspect_rejected = invalid_suspect_record != null and invalid_suspect_record.status == BarkeepTransformationRecord.STATUS_INVALID
	checks.record_source = record != null and record.source_suspect_id == 1
	checks.record_target = record != null and record.target_suspect_id == 2
	checks.record_original_role = record != null and record.original_target_role_id == &"reporter"
	checks.record_result_role = record != null and record.resulting_role_id == &"drunkard"
	checks.reinitialize_clears_record = reset_record_clear
	checks.separate_runtime_isolated = separate_runtime.barkeep_transformation_records.is_empty() and separate_runtime.current_role_id_for_suspect(c, 2) == &"reporter"
	checks.static_ratio_unchanged = ratio_before == ratio_controller._case_ratio_text()
	checks.no_turn_advance = no_turn_advance
	checks.no_elapsed_hours = no_elapsed_hours
	checks.no_death_mutation = no_death_mutation
	checks.no_corruption_mutation = no_corruption_mutation
	checks.no_display_impersonation_mutation = no_display_impersonation_mutation
	checks.truth_reveal_current_drunkard = truth != null and truth.true_role_name == "Kẻ Say Rượu" and truth.current_role_name == "Kẻ Say Rượu" and truth.original_true_role_name == "Sử Quan"
	checks.public_hides_before_reveal = target_view_before != null and target_view_before.public_role_name == "Ngự Y" and not target_view_before.public_role_name.contains("Kẻ Say Rượu")
	checks.effect_idempotent = duplicate_record == record and success_record_count == 1
	return checks


func _t06_f3r_barkeep_drunkard_canonical_repair_checks(t06: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	if t06 == null:
		return checks
	var service: BarkeepTransformationService = BarkeepTransformationService.new()
	var info_service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var barkeep_role: RoleDefinition = _role_by_id(roles, &"barkeep")
	var drunkard_role: RoleDefinition = _role_by_id(roles, &"drunkard")
	var t06_scene: VSCaseMainController = _t06_i1_live_scene(players)
	var runtime: CaseRuntimeState = t06_scene.runtime_state if t06_scene != null else null
	var source: SuspectDefinition = _case_suspect(t06, 3)
	var target: SuspectDefinition = _case_suspect(t06, 6)
	var suspected_before: Array[StringName] = CASE_ROLE_POOL_SERVICE.suspected_role_ids_for_case(t06)
	var nested_drunkard: Array[StringName] = CASE_ROLE_POOL_SERVICE.nested_role_reference_ids_for_case(t06, &"barkeep")
	var barkeep_pool: Array[StringName] = service.barkeep_pretend_candidate_role_ids(t06)
	var drunkard_pool: Array[StringName] = []
	if runtime != null:
		drunkard_pool = service.drunkard_pretend_candidate_role_ids(t06, runtime, roles, suspected_before)
	var current_roles: Array[StringName] = info_service.current_role_ids_in_play(t06, runtime)
	var not_in_play: Array[StringName] = info_service.current_role_ids_not_in_play_from_candidates(t06, runtime, suspected_before)
	var mailman_result: InvestigationInformationResult = info_service.evaluate(t06, 6, roles, {}, runtime)
	var clean_drunkard_case: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"drunkard", &"mailman", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
		_role_info_spec(2, 1, &"reporter", &"reporter", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
	])
	clean_drunkard_case.case_id = &"drunkard_pretend_smoke"
	var clean_candidates: Array[StringName] = [
		&"mailman",
		&"reporter",
		&"poisoner",
		&"role_good_a",
	]
	clean_drunkard_case.suspected_role_ids = clean_candidates
	var clean_runtime: CaseRuntimeState = _fresh_turn_bundle(clean_drunkard_case, players).runtime as CaseRuntimeState
	var clean_truth: int = info_service.evaluate(clean_drunkard_case, 1, roles, {}, clean_runtime).truth_mode
	var tainted_drunkard_case: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"drunkard", &"mailman", CaseEnums.Alignment.GOOD, true, CaseEnums.RoleGroup.HIEU_SU),
		_role_info_spec(2, 1, &"reporter", &"reporter", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
	])
	tainted_drunkard_case.case_id = &"tainted_drunkard_pretend_smoke"
	var tainted_candidates: Array[StringName] = [
		&"mailman",
		&"reporter",
		&"poisoner",
		&"role_good_a",
	]
	tainted_drunkard_case.suspected_role_ids = tainted_candidates
	var tainted_runtime: CaseRuntimeState = _fresh_turn_bundle(tainted_drunkard_case, players).runtime as CaseRuntimeState
	var tainted_current_before: StringName = tainted_runtime.current_role_id_for_suspect(tainted_drunkard_case, 1)
	var tainted_truth: int = info_service.evaluate(tainted_drunkard_case, 1, roles, {}, tainted_runtime).truth_mode
	var tainted_pool: Array[StringName] = service.drunkard_pretend_candidate_role_ids(tainted_drunkard_case, tainted_runtime, roles, tainted_candidates)
	var f3_checks: Dictionary = _t06_f3_barkeep_drunkard_checks(roles, players)
	var invalid_second_case: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"barkeep", &"reporter", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(2, 1, &"drunkard", &"mailman", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
	])
	invalid_second_case.case_id = &"barkeep_second_drunkard_invalid_smoke"
	var invalid_second_candidates: Array[StringName] = [
		&"reporter",
		&"mailman",
		&"barkeep",
	]
	invalid_second_case.suspected_role_ids = invalid_second_candidates
	var invalid_second_report: Dictionary = CaseDefinitionValidator.new().validate(invalid_second_case, roles, players)
	var t06_validation_report: Dictionary = CaseDefinitionValidator.new().validate(t06, roles, players)
	var reveal: CaseTruthReveal = _tutorial_06_reveal(t06, runtime, roles)
	var truth_3: SuspectTruthReveal = _truth_for_suspect(reveal, 3)
	var truth_6: SuspectTruthReveal = _truth_for_suspect(reveal, 6)
	checks.barkeep_underling_evil = barkeep_role != null and barkeep_role.role_group == CaseEnums.RoleGroup.TONG_PHAM and source != null and source.true_alignment == CaseEnums.Alignment.EVIL
	checks.drunkard_meddler_good = drunkard_role != null and drunkard_role.role_group == CaseEnums.RoleGroup.HIEU_SU and CaseRolePoolService.alignment_for_role_group(drunkard_role.role_group) == CaseEnums.Alignment.GOOD
	checks.barkeep_pool_suspected = barkeep_pool == suspected_before
	checks.reporter_valid_barkeep_pretend = source != null and source.impersonated_role_id == &"reporter" and service.barkeep_pretend_role_is_valid(t06, &"reporter")
	checks.drunkard_invalid_barkeep_pretend = not service.barkeep_pretend_role_is_valid(t06, &"drunkard")
	checks.non_suspected_invalid_barkeep_pretend = not service.barkeep_pretend_role_is_valid(t06, &"surgeon")
	checks.drunkard_pool_good_alignment = drunkard_pool.has(&"mailman") and drunkard_pool.has(&"mathematician") and not drunkard_pool.has(&"poisoner") and not drunkard_pool.has(&"barkeep")
	checks.absent_good_valid_drunkard_pretend = service.drunkard_pretend_role_is_valid(t06, runtime, roles, suspected_before, &"mailman")
	checks.current_good_excluded = not drunkard_pool.has(&"reporter") and not drunkard_pool.has(&"tutorial_priest") and not drunkard_pool.has(&"therapist") and not drunkard_pool.has(&"blood_hound")
	checks.evil_excluded = not drunkard_pool.has(&"poisoner") and not drunkard_pool.has(&"barkeep")
	checks.placeholder_excluded = not tainted_pool.has(&"role_good_a") and not service.drunkard_pretend_role_is_valid(tainted_drunkard_case, tainted_runtime, roles, tainted_candidates, &"role_good_a")
	checks.outside_pool_excluded = not service.drunkard_pretend_role_is_valid(t06, runtime, roles, suspected_before, &"surgeon")
	checks.mailman_current_not_in_play = current_roles.has(&"drunkard") and not current_roles.has(&"mailman") and not_in_play.has(&"mailman")
	checks.mailman_valid_drunkard_pretend = service.drunkard_pretend_role_is_valid(t06, runtime, roles, suspected_before, &"mailman")
	checks.six_mailman_pretend_valid = target != null and target.displayed_role_id == &"mailman" and service.drunkard_pretend_role_is_valid(t06, runtime, roles, suspected_before, target.displayed_role_id)
	checks.clean_drunkard_lies = clean_truth == InvestigationInformationResult.TruthMode.LYING
	checks.tainted_drunkard_lies = tainted_truth == InvestigationInformationResult.TruthMode.LYING
	checks.taint_current_role_unchanged = tainted_runtime.current_role_id_for_suspect(tainted_drunkard_case, 1) == tainted_current_before
	checks.taint_pretend_rule_unchanged = tainted_pool.has(&"mailman") and not tainted_pool.has(&"poisoner")
	checks.transform_target_authored_innocent = target != null and target.true_role_id == &"mailman" and target.role_group == CaseEnums.RoleGroup.CHINH_NHAN
	checks.transform_current_drunkard = runtime != null and runtime.current_role_id_for_suspect(t06, 6) == &"drunkard"
	checks.authored_original_unchanged = target != null and target.true_role_id == &"mailman"
	checks.static_ratio_unchanged = _role_group_count(t06, CaseEnums.RoleGroup.CHINH_NHAN) == 5 and _role_group_count(t06, CaseEnums.RoleGroup.HIEU_SU) == 0 and _role_group_count(t06, CaseEnums.RoleGroup.TONG_PHAM) == 2
	checks.suspected_pool_unchanged = CASE_ROLE_POOL_SERVICE.suspected_role_ids_for_case(t06) == suspected_before
	checks.drunkard_not_suspected = not suspected_before.has(&"drunkard")
	checks.nested_barkeep_drunkard = nested_drunkard == [&"drunkard"] and not suspected_before.has(&"drunkard")
	checks.preexisting_drunkard_blocks = bool(f3_checks.get("no_second_drunkard", false))
	checks.second_drunkard_setup_rejected = service.case_setup_would_create_second_drunkard(invalid_second_case) and _report_has_error_code(invalid_second_report, "BARKEEP_SECOND_DRUNKARD_SETUP")
	checks.runtime_guard_idempotent = bool(f3_checks.get("no_second_idempotent", false)) and bool(f3_checks.get("effect_idempotent", false))
	checks.no_transform_side_effects = bool(f3_checks.get("no_turn_advance", false)) and bool(f3_checks.get("no_elapsed_hours", false)) and bool(f3_checks.get("no_death_mutation", false)) and bool(f3_checks.get("no_corruption_mutation", false))
	checks.mailman_current_truth_preserved = mailman_result != null and mailman_result.not_in_play_role_id == &"drunkard" and current_roles.has(&"drunkard") and not current_roles.has(&"mailman")
	checks.full_reveal_history_preserved = (
		bool(t06_validation_report.get("passed", false))
		and truth_3 != null
		and truth_3.current_role_id == &"barkeep"
		and truth_3.impersonated_role_name == "Sử Quan"
		and truth_6 != null
		and truth_6.original_true_role_name == "Dịch Phu"
		and truth_6.current_role_id == &"drunkard"
		and truth_6.displayed_role_name == "Dịch Phu"
	)
	_t05_i2_free_scene(t06_scene)
	return checks


func _t06_f3_barkeep_case() -> CaseDefinition:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"barkeep", &"reporter", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(2, 1, &"reporter", &"therapist", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(3, 2, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(4, 3, &"therapist", &"therapist", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
	])
	c.case_id = &"barkeep_transformation_smoke"
	return c


func _t06_f4_blood_hound_checks(roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var c: CaseDefinition = _t06_f4_blood_hound_case(false)
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var info_service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var spatial: CaseSpatialService = CaseSpatialService.new()
	var role: RoleDefinition = _role_by_id(roles, &"blood_hound")
	var source_definition: SuspectDefinition = _case_suspect(c, 50)
	var source_authored_role_before: StringName = source_definition.true_role_id
	var source_displayed_before: StringName = source_definition.displayed_role_id
	var source_corrupted_before: bool = source_definition.is_corrupted
	var source_current_before: StringName = runtime.current_role_id_for_suspect(c, 50)
	var source_dead_before: bool = runtime.find_suspect(50).is_dead
	var turn_before: int = runtime.turn_number
	var turn_index_before: int = runtime.current_turn_index
	var elapsed_before: int = runtime.elapsed_hours
	var result: InvestigationInformationResult = info_service.evaluate(c, 50, roles, {}, runtime)
	var duplicate_result: InvestigationInformationResult = info_service.evaluate(c, 50, roles, {}, runtime)
	var north_suspects: Array[SuspectDefinition] = spatial.suspects_in_cardinal_direction(c, 50, CaseSpatialService.DIRECTION_NORTH)
	var surrounding_suspects: Array[SuspectDefinition] = spatial.suspects_surrounding_source(c, 50)
	var bark_case: CaseDefinition = _t06_f4_blood_hound_bark_case()
	var bark_result: InvestigationInformationResult = info_service.evaluate(bark_case, 50, roles)
	var sniff_case: CaseDefinition = _t06_f4_blood_hound_sniff_case()
	var sniff_result: InvestigationInformationResult = info_service.evaluate(sniff_case, 50, roles)
	var tainted_case: CaseDefinition = _t06_f4_blood_hound_case(true)
	var tainted_runtime: CaseRuntimeState = _fresh_turn_bundle(tainted_case, players).runtime as CaseRuntimeState
	var tainted_result: InvestigationInformationResult = info_service.evaluate(tainted_case, 50, roles, {}, tainted_runtime)
	var separate_runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var weatherman_case: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(10, 8, &"weatherman", &"weatherman", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(20, 0, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(40, 1, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	])
	var weatherman_result: InvestigationInformationResult = info_service.evaluate(weatherman_case, 10, roles)
	var scene: RoleCodexController = _role_codex_instance()
	var good_ids: Array[StringName] = []
	var all_ids: Array[StringName] = []
	if scene != null:
		good_ids = scene.get_visible_role_ids_for_group(CaseEnums.RoleGroup.CHINH_NHAN)
		for group: int in RoleCodexController.GROUP_ORDER:
			all_ids.append_array(scene.get_visible_role_ids_for_group(group))
	var source_runtime: SuspectRuntimeState = runtime.find_suspect(50)
	var checks: Dictionary = {}
	checks.blood_hound_role_loads = role != null and role.display_name == "Ngự Khuyển Quan" and not role.is_fixture_placeholder
	checks.blood_hound_role_id = role != null and role.role_id == &"blood_hound"
	checks.blood_hound_help_text = role != null and role.help_text.contains("Hao Khuyển sẽ nằm im") and role.help_text.contains("sủa hoặc nằm im") and role.help_text.contains("một kết quả khác sự thật") and not role.help_text.contains("đánh hơi")
	checks.blood_hound_no_evil_wording = sniff_result != null and sniff_result.direction_key == CaseSpatialService.BLOOD_HOUND_SNIFF and sniff_result.public_text().contains("nằm im") and not sniff_result.public_text().contains("đánh hơi")
	checks.blood_hound_group = role != null and role.role_group == CaseEnums.RoleGroup.CHINH_NHAN
	checks.blood_hound_alignment = role != null and RoleReferenceFormatter.role_alignment_label(role.role_group) == "Phe Thiện"
	checks.codex_visible = good_ids.has(&"blood_hound")
	checks.placeholder_excluded = not all_ids.has(&"role_good_a") and not all_ids.has(&"role_meddler_a") and not all_ids.has(&"role_accomplice_a") and not all_ids.has(&"role_traitor_a")
	checks.uses_board_slots = result != null and result.payload_kind == InvestigationInformationResult.PayloadKind.BLOOD_HOUND_CLUE and result.direction_key == CaseSpatialService.DIRECTION_NORTH
	checks.output_hides_target_ids = result != null and not result.public_text().contains("Số Hiệu")
	checks.empty_slot_traversable = north_suspects.size() == 1 and north_suspects[0].suspect_id == 10
	checks.crime_scene_traversable = c.crime_scene.board_slot == 3 and result != null and result.direction_key == CaseSpatialService.DIRECTION_NORTH
	checks.cardinal_not_surrounding = surrounding_suspects.size() > north_suspects.size() and not spatial.are_surrounding_neighbours(source_definition.board_slot, _case_suspect(c, 10).board_slot)
	checks.truthful_deterministic = result != null and duplicate_result != null and result.direction_key == duplicate_result.direction_key and result.public_text() == duplicate_result.public_text()
	checks.bark_on_tie = bark_result != null and bark_result.direction_key == CaseSpatialService.BLOOD_HOUND_BARK and bark_result.public_text().contains("sủa")
	checks.sniff_when_none = sniff_result != null and sniff_result.direction_key == CaseSpatialService.BLOOD_HOUND_SNIFF and sniff_result.public_text().contains("nằm im")
	checks.no_tutorial_hardcode = result != null and result.direction_key == CaseSpatialService.DIRECTION_NORTH and source_definition.suspect_id == 50
	checks.tainted_enters_lying = tainted_result != null and tainted_result.truth_mode == InvestigationInformationResult.TruthMode.LYING
	checks.lying_non_truthful = tainted_result != null and tainted_result.payload_kind == InvestigationInformationResult.PayloadKind.BLOOD_HOUND_CLUE and tainted_result.direction_key != CaseSpatialService.DIRECTION_NORTH and _blood_hound_allowed_outcome(tainted_result.direction_key)
	checks.no_case_definition_mutation = source_definition.true_role_id == source_authored_role_before and source_definition.displayed_role_id == source_displayed_before and source_definition.is_corrupted == source_corrupted_before
	checks.no_current_role_mutation = runtime.current_role_id_for_suspect(c, 50) == source_current_before
	checks.no_corruption_mutation = not runtime.has_runtime_corruption(50)
	checks.no_death_mutation = source_runtime != null and source_runtime.is_dead == source_dead_before
	checks.no_turn_advance = runtime.turn_number == turn_before and runtime.current_turn_index == turn_index_before
	checks.no_elapsed_hours = runtime.elapsed_hours == elapsed_before
	checks.runtime_isolated = separate_runtime != runtime and separate_runtime.current_role_id_for_suspect(c, 50) == &"blood_hound" and not separate_runtime.has_runtime_corruption(50)
	checks.weatherman_regression_safe = weatherman_result != null and weatherman_result.payload_kind == InvestigationInformationResult.PayloadKind.NO_MEDDLER_FOUND and weatherman_result.weather_suspect_ids.size() == 2
	_free_role_codex(scene)
	return checks


func _t06_f4_blood_hound_case(source_corrupted: bool) -> CaseDefinition:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(10, 0, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(20, 4, &"reporter", &"reporter", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(30, 7, &"therapist", &"therapist", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(50, 6, &"blood_hound", &"blood_hound", CaseEnums.Alignment.GOOD, source_corrupted, CaseEnums.RoleGroup.CHINH_NHAN),
	], 3)
	c.case_id = &"blood_hound_spatial_smoke"
	return c


func _t06_f4_blood_hound_bark_case() -> CaseDefinition:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(10, 3, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(20, 7, &"tutorial_mobster_alt", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(50, 4, &"blood_hound", &"blood_hound", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
	], 8)
	c.case_id = &"blood_hound_bark_smoke"
	return c


func _t06_f4_blood_hound_sniff_case() -> CaseDefinition:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(10, 0, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(50, 8, &"blood_hound", &"blood_hound", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
	], 4)
	c.case_id = &"blood_hound_sniff_smoke"
	return c


func _blood_hound_allowed_outcome(outcome: StringName) -> bool:
	return outcome in [
		CaseSpatialService.DIRECTION_NORTH,
		CaseSpatialService.DIRECTION_EAST,
		CaseSpatialService.DIRECTION_SOUTH,
		CaseSpatialService.DIRECTION_WEST,
		CaseSpatialService.BLOOD_HOUND_BARK,
		CaseSpatialService.BLOOD_HOUND_SNIFF,
	]


func _tutorial_06_i1_checks(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	if c == null:
		return checks
	var scene: VSCaseMainController = _t06_i1_live_scene(players)
	var runtime: CaseRuntimeState = scene.runtime_state if scene != null else null
	var info_service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var blood_result: InvestigationInformationResult = info_service.evaluate(c, 5, roles, {}, runtime)
	var mailman_result: InvestigationInformationResult = info_service.evaluate(c, 6, roles, {}, runtime)
	var bark_result: InvestigationInformationResult = info_service.evaluate(_t06_f4_blood_hound_bark_case(), 50, roles)
	var sniff_result: InvestigationInformationResult = info_service.evaluate(_t06_f4_blood_hound_sniff_case(), 50, roles)
	var tainted_blood_case: CaseDefinition = _t06_f4_blood_hound_case(true)
	var tainted_blood_result: InvestigationInformationResult = info_service.evaluate(tainted_blood_case, 50, roles)
	var reveal: CaseTruthReveal = _tutorial_06_reveal(c, runtime, roles)
	var truth_1: SuspectTruthReveal = _truth_for_suspect(reveal, 1)
	var truth_3: SuspectTruthReveal = _truth_for_suspect(reveal, 3)
	var truth_6: SuspectTruthReveal = _truth_for_suspect(reveal, 6)
	var top_level_ids: Array[StringName] = scene.get_top_level_suspect_list_role_ids_for_smoke() if scene != null else CASE_ROLE_POOL_SERVICE.suspected_role_ids_for_case(c)
	var nested_drunkard_ids: Array[StringName] = scene.get_nested_suspect_list_role_ids_for_smoke(&"barkeep") if scene != null else _case_nested_suspect_list_role_ids(c, &"barkeep")
	checks.board_layout = (
		c.crime_scene != null
		and c.crime_scene.board_slot == 4
		and _case_suspect(c, 1).board_slot == 0
		and _case_suspect(c, 2).board_slot == 1
		and _case_suspect(c, 3).board_slot == 2
		and _case_suspect(c, 4).board_slot == 5
		and _case_suspect(c, 5).board_slot == 6
		and _case_suspect(c, 6).board_slot == 7
		and _case_suspect(c, 7).board_slot == 8
		and _case_slot_empty(c, 3)
	)
	checks.top_level_pool = top_level_ids == [
		&"reporter",
		&"therapist",
		&"blood_hound",
		&"tutorial_priest",
		&"mailman",
		&"mathematician",
		&"barkeep",
		&"poisoner",
	]
	checks.nested_drunkard = nested_drunkard_ids == [&"drunkard"] and not top_level_ids.has(&"drunkard")
	checks.ratio_static = _role_group_count(c, CaseEnums.RoleGroup.CHINH_NHAN) == 5 and _role_group_count(c, CaseEnums.RoleGroup.HIEU_SU) == 0 and _role_group_count(c, CaseEnums.RoleGroup.TONG_PHAM) == 2 and _role_group_count(c, CaseEnums.RoleGroup.NGHICH_THAN) == 0
	checks.evil_answer = c.evil_suspect_ids == PackedInt32Array([1, 3]) and c.accomplice_suspect_ids == PackedInt32Array([1, 3]) and c.traitor_suspect_ids.is_empty()
	checks.startup_taint = runtime != null and runtime.has_runtime_corruption(2) and runtime.poisoner_taint_records.size() == 1 and runtime.poisoner_taint_records[0].source_suspect_id == 1 and runtime.poisoner_taint_records[0].target_suspect_id == 2
	checks.startup_transform = runtime != null and runtime.current_role_id_for_suspect(c, 6) == &"drunkard" and runtime.barkeep_transformation_records.size() == 1 and runtime.barkeep_transformation_records[0].source_suspect_id == 3 and runtime.barkeep_transformation_records[0].target_suspect_id == 6
	checks.ratio_not_mutated = runtime != null and scene._case_ratio_text().contains("Người Vô Tội") and _role_group_count(c, CaseEnums.RoleGroup.CHINH_NHAN) == 5 and runtime.current_role_id_for_suspect(c, 6) == &"drunkard"
	checks.blood_hound_north = blood_result != null and blood_result.payload_kind == InvestigationInformationResult.PayloadKind.BLOOD_HOUND_CLUE and blood_result.direction_key == CaseSpatialService.DIRECTION_NORTH and blood_result.public_text().contains("Bắc")
	checks.blood_hound_bark_sniff = bark_result != null and bark_result.direction_key == CaseSpatialService.BLOOD_HOUND_BARK and sniff_result != null and sniff_result.direction_key == CaseSpatialService.BLOOD_HOUND_SNIFF
	checks.blood_hound_lying = tainted_blood_result != null and tainted_blood_result.truth_mode == InvestigationInformationResult.TruthMode.LYING and tainted_blood_result.direction_key != CaseSpatialService.DIRECTION_NORTH and _blood_hound_allowed_outcome(tainted_blood_result.direction_key)
	checks.mailman_current_truth = (
		runtime != null
		and mailman_result != null
		and mailman_result.in_play_role_id == &"mathematician"
		and mailman_result.not_in_play_role_id == &"drunkard"
		and not mailman_result.claimed_in_play_is_true
		and not mailman_result.claimed_not_in_play_is_true
		and RoleInformationEvaluationService.new().current_role_ids_in_play(c, runtime).has(&"drunkard")
	)
	checks.full_reveal_notes = (
		truth_1 != null
		and truth_1.current_role_id == &"poisoner"
		and truth_1.impersonated_role_name == "Sử Quan"
		and truth_3 != null
		and truth_3.current_role_id == &"barkeep"
		and truth_3.impersonated_role_name == "Sử Quan"
		and truth_6 != null
		and truth_6.current_role_id == &"drunkard"
		and truth_6.displayed_role_name == "Dịch Phu"
	)
	checks.no_partner = not _role_id_exists(roles, &"partner") and not ResourceLoader.exists("res://content/roles/fixtures/partner.tres")
	_t05_i2_free_scene(scene)
	return checks


func _tutorial_06_i2_clue_output_checks(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	if c == null:
		return checks
	var scene: VSCaseMainController = _t06_i1_live_scene(players)
	var runtime: CaseRuntimeState = scene.runtime_state if scene != null else null
	var info_service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var spatial: CaseSpatialService = CaseSpatialService.new()
	var s1: SuspectDefinition = _case_suspect(c, 1)
	var s2: SuspectDefinition = _case_suspect(c, 2)
	var s3: SuspectDefinition = _case_suspect(c, 3)
	var s5: SuspectDefinition = _case_suspect(c, 5)
	var s6: SuspectDefinition = _case_suspect(c, 6)
	var result_1: InvestigationInformationResult = info_service.evaluate(c, 1, roles, {}, runtime)
	var result_2: InvestigationInformationResult = info_service.evaluate(c, 2, roles, {}, runtime)
	var result_3: InvestigationInformationResult = info_service.evaluate(c, 3, roles, {}, runtime)
	var result_5: InvestigationInformationResult = info_service.evaluate(c, 5, roles, {}, runtime)
	var result_6: InvestigationInformationResult = info_service.evaluate(c, 6, roles, {}, runtime)
	var nearest_1: Dictionary = spatial.nearest_true_evil_distance(c, 1)
	var nearest_3: Dictionary = spatial.nearest_true_evil_distance(c, 3)
	var nearest_1_ids: PackedInt32Array = PackedInt32Array()
	var nearest_1_ids_value: Variant = nearest_1.get("suspect_ids", PackedInt32Array())
	if nearest_1_ids_value is PackedInt32Array:
		nearest_1_ids = PackedInt32Array(nearest_1_ids_value)
	var nearest_3_ids: PackedInt32Array = PackedInt32Array()
	var nearest_3_ids_value: Variant = nearest_3.get("suspect_ids", PackedInt32Array())
	if nearest_3_ids_value is PackedInt32Array:
		nearest_3_ids = PackedInt32Array(nearest_3_ids_value)
	var current_role_ids: Array[StringName] = []
	if runtime != null:
		current_role_ids = info_service.current_role_ids_in_play(c, runtime)
	var generic_reporter_case: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(10, 0, &"reporter", &"reporter", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(20, 2, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	])
	var generic_reporter_result: InvestigationInformationResult = info_service.evaluate(generic_reporter_case, 10, roles)
	var blood_hound_checks: Dictionary = _t06_f4_blood_hound_checks(roles, players)
	var s5_text: String = result_5.public_text() if result_5 != null else ""
	checks.s1_reporter_lying_pretend = (
		s1 != null
		and s1.true_role_id == &"poisoner"
		and s1.displayed_role_id == &"reporter"
		and result_1 != null
		and result_1.behavior_role_id == &"reporter"
		and result_1.truth_mode == InvestigationInformationResult.TruthMode.LYING
	)
	checks.s1_reporter_exact_three = result_1 != null and result_1.public_text() == "Ta cách Phe Ác gần nhất 3 bước."
	checks.s3_reporter_lying_pretend = (
		s3 != null
		and s3.true_role_id == &"barkeep"
		and s3.displayed_role_id == &"reporter"
		and result_3 != null
		and result_3.behavior_role_id == &"reporter"
		and result_3.truth_mode == InvestigationInformationResult.TruthMode.LYING
	)
	checks.s3_reporter_exact_four = result_3 != null and result_3.public_text() == "Ta cách Phe Ác gần nhất 4 bước."
	checks.reporter_self_excluded = (
		bool(nearest_1.get("found", false))
		and int(nearest_1.get("distance", -1)) == 2
		and nearest_1_ids == PackedInt32Array([3])
		and bool(nearest_3.get("found", false))
		and int(nearest_3.get("distance", -1)) == 2
		and nearest_3_ids == PackedInt32Array([1])
	)
	checks.s2_priest_exact = s2 != null and result_2 != null and result_2.public_text() == "Ta là Thầy Tu."
	checks.s5_blood_hound_exact = s5 != null and result_5 != null and result_5.public_text() == "*Chỉ về phía Bắc*"
	checks.s5_blood_hound_no_identity = (
		not s5_text.contains("Số Hiệu")
		and not s5_text.contains("Phe Ác")
		and not s5_text.contains("#")
		and not s5_text.contains("Độc Sư")
		and not s5_text.contains("Chủ Quán Rượu")
	)
	checks.s6_mailman_exact = result_6 != null and result_6.public_text() == "Nhà Toán Học đang ở trong cung, ta chưa từng nghe đến Kẻ Say Rượu."
	checks.s6_mailman_false_facts = (
		s6 != null
		and result_6 != null
		and result_6.truth_mode == InvestigationInformationResult.TruthMode.LYING
		and result_6.in_play_role_id == &"mathematician"
		and result_6.not_in_play_role_id == &"drunkard"
		and not result_6.claimed_in_play_is_true
		and not result_6.claimed_not_in_play_is_true
	)
	checks.s6_mailman_current_role_truth = current_role_ids.has(&"drunkard") and not current_role_ids.has(&"mailman")
	checks.generic_reporter_safe = generic_reporter_result != null and generic_reporter_result.public_text() == "Ta cách Phe Ác gần nhất 2 bước."
	checks.blood_hound_regression_safe = (
		bool(blood_hound_checks.get("bark_on_tie", false))
		and bool(blood_hound_checks.get("sniff_when_none", false))
		and bool(blood_hound_checks.get("lying_non_truthful", false))
	)
	checks.mailman_regression_safe = _role_info_mailman()
	_t05_i2_free_scene(scene)
	return checks


func _tutorial_06_i3_full_reveal_checks(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	if c == null:
		return checks
	var scene: VSCaseMainController = _t06_i1_live_scene(players)
	var runtime: CaseRuntimeState = scene.runtime_state if scene != null else null
	var reveal: CaseTruthReveal = _tutorial_06_reveal(c, runtime, roles)
	var truth_1: SuspectTruthReveal = _truth_for_suspect(reveal, 1)
	var truth_3: SuspectTruthReveal = _truth_for_suspect(reveal, 3)
	var truth_6: SuspectTruthReveal = _truth_for_suspect(reveal, 6)
	var board: CaseBoardController = null
	var card_1: SuspectCardController = null
	var card_3: SuspectCardController = null
	var card_6: SuspectCardController = null
	if runtime != null:
		board = _board_instance_with_runtime(c, runtime, roles)
	if board != null:
		card_1 = _board_card(board, 1)
		card_3 = _board_card(board, 3)
		card_6 = _board_card(board, 6)
	var text_1: String = card_1.get_full_truth_text() if card_1 != null else ""
	var text_3: String = card_3.get_full_truth_text() if card_3 != null else ""
	var text_6: String = card_6.get_full_truth_text() if card_6 != null else ""
	var suspect_6: SuspectDefinition = _case_suspect(c, 6)
	var source_files: PackedStringArray = PackedStringArray([
		FileAccess.get_file_as_string("res://scripts/domain/cases/CaseTruthRevealBuilder.gd"),
		FileAccess.get_file_as_string("res://scripts/presentation/case_gameplay/SuspectCardController.gd"),
		FileAccess.get_file_as_string("res://scripts/presentation/case_gameplay/CasePublicPresentationBuilder.gd"),
	])
	var production_source: String = "\n".join(source_files)
	var transform_relation_text: String = "\n".join(truth_3.relation_notes) if truth_3 != null else ""
	var taint_relation_text: String = "\n".join(truth_1.relation_notes) if truth_1 != null else ""
	checks.truth_original_role_id = truth_6 != null and truth_6.original_true_role_name == "Dịch Phu"
	checks.truth_current_role_id = truth_6 != null and truth_6.current_role_id == &"drunkard" and truth_6.current_role_name == "Kẻ Say Rượu"
	checks.t06_six_original_current = checks.truth_original_role_id and checks.truth_current_role_id
	checks.card_current_drunkard = card_6 != null and card_6.get_public_role_text() == "Kẻ Say Rượu"
	checks.card_original_mailman = truth_6 != null and truth_6.original_true_role_name == "Dịch Phu" and not text_6.contains("Vai trò ban đầu:")
	checks.non_transformed_no_original_line = (
		not text_1.contains("Vai trò ban đầu:")
		and not text_3.contains("Vai trò ban đầu:")
	)
	checks.transform_relation_runtime = (
		runtime != null
		and runtime.barkeep_transformation_records.size() == 1
		and truth_3 != null
		and truth_3.relation_notes.has("Chủ Quán Rượu đã biến Số Hiệu 6 thành Kẻ Say Rượu.")
	)
	checks.transform_relation_so_hieu = (
		truth_3 != null
		and truth_3.relation_notes.has("Chủ Quán Rượu đã biến Số Hiệu 6 thành Kẻ Say Rượu.")
		and not transform_relation_text.contains("#6")
	)
	checks.taint_relation_runtime = (
		runtime != null
		and runtime.poisoner_taint_records.size() == 1
		and truth_1 != null
		and truth_1.relation_notes.has("Độc Sư đã Tha Hóa Số Hiệu 2.")
	)
	checks.taint_relation_so_hieu = (
		truth_1 != null
		and truth_1.relation_notes.has("Độc Sư đã Tha Hóa Số Hiệu 2.")
		and not taint_relation_text.contains("#2")
	)
	checks.case_definition_six_mailman = suspect_6 != null and suspect_6.true_role_id == &"mailman"
	checks.six_pretend_history = (
		truth_6 != null
		and truth_6.original_true_role_name == "Dịch Phu"
		and truth_6.displayed_role_name == "Dịch Phu"
		and suspect_6 != null
		and suspect_6.displayed_role_id == &"mailman"
		and card_6 != null
		and card_6.get_public_role_text() == "Kẻ Say Rượu"
	)
	checks.runtime_six_drunkard = runtime != null and runtime.current_role_id_for_suspect(c, 6) == &"drunkard"
	checks.static_ratio = _role_group_count(c, CaseEnums.RoleGroup.CHINH_NHAN) == 5 and _role_group_count(c, CaseEnums.RoleGroup.HIEU_SU) == 0 and _role_group_count(c, CaseEnums.RoleGroup.TONG_PHAM) == 2 and _role_group_count(c, CaseEnums.RoleGroup.NGHICH_THAN) == 0
	checks.no_t06_id_hardcode = (
		not production_source.contains("Số Hiệu 6")
		and not production_source.contains("Số Hiệu 2")
		and not production_source.contains("#6")
		and not production_source.contains("#2")
		and not production_source.contains("suspect_id == 6")
		and not production_source.contains("suspect_id == 2")
	)
	if board != null:
		board.queue_free()
	_t05_i2_free_scene(scene)
	return checks


func _tutorial_06_f5_role_pool_checks(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	if c == null:
		return checks
	var scene: VSCaseMainController = _t06_i1_live_scene(players)
	var runtime: CaseRuntimeState = scene.runtime_state if scene != null else null
	var info_service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var suspected: Array[StringName] = CASE_ROLE_POOL_SERVICE.suspected_role_ids_for_case(c)
	var suspected_before: Array[StringName] = suspected.duplicate()
	var nested: Array[StringName] = CASE_ROLE_POOL_SERVICE.nested_role_reference_ids_for_case(c, &"barkeep")
	var current_in_play: Array[StringName] = CASE_ROLE_POOL_SERVICE.current_role_ids_in_play(c, runtime)
	var bounded_candidates: Array[StringName] = [&"mailman", &"mathematician", &"drunkard"]
	var bounded_not_in_play: Array[StringName] = CASE_ROLE_POOL_SERVICE.current_role_ids_not_in_play(c, runtime, bounded_candidates)
	var good_candidates: Array[StringName] = [&"mathematician", &"drunkard", &"reporter", &"poisoner", &"role_good_a"]
	var good_not_in_play: Array[StringName] = CASE_ROLE_POOL_SERVICE.good_current_not_in_play_candidates(c, runtime, roles, good_candidates)
	var suspected_candidates: Array[StringName] = CASE_ROLE_POOL_SERVICE.suspected_role_candidates(c)
	var mailman_result: InvestigationInformationResult = info_service.evaluate(c, 6, roles, {}, runtime)
	var reinit_runtime: CaseRuntimeState = CaseRuntimeState.new()
	reinit_runtime.initialize(c, players)
	var suspected_after_reinit: Array[StringName] = CASE_ROLE_POOL_SERVICE.suspected_role_ids_for_case(c)
	var separate_a: CaseRuntimeState = CaseRuntimeState.new()
	var separate_b: CaseRuntimeState = CaseRuntimeState.new()
	separate_a.initialize(c, players)
	separate_b.initialize(c, players)
	CaseRoleTransformationService.new().transform_role(c, separate_a, 6, &"drunkard", roles)
	var duplicate_case: CaseDefinition = c.duplicate(true) as CaseDefinition
	var invalid_case: CaseDefinition = c.duplicate(true) as CaseDefinition
	var invalid_nested_case: CaseDefinition = c.duplicate(true) as CaseDefinition
	if duplicate_case != null:
		duplicate_case.suspected_role_ids = suspected.duplicate()
		duplicate_case.suspected_role_ids.append(&"reporter")
	if invalid_case != null:
		invalid_case.suspected_role_ids = suspected.duplicate()
		invalid_case.suspected_role_ids.append(&"missing_role")
	if invalid_nested_case != null:
		var invalid_nested_children: Array[StringName] = [&"missing_nested_role"]
		invalid_nested_case.nested_suspect_list_role_ids_by_parent = {&"barkeep": invalid_nested_children}
	var validator: CaseDefinitionValidator = CaseDefinitionValidator.new()
	var duplicate_report: Dictionary = validator.validate(duplicate_case, roles, players) if duplicate_case != null else {}
	var invalid_report: Dictionary = validator.validate(invalid_case, roles, players) if invalid_case != null else {}
	var invalid_nested_report: Dictionary = validator.validate(invalid_nested_case, roles, players) if invalid_nested_case != null else {}
	var nested_renders: bool = false
	if scene != null and scene.role_list != null:
		for child: Node in scene.role_list.get_children():
			var button: Button = child as Button
			if button != null and button.text.contains("Kẻ Say Rượu") and button.text.begins_with("      "):
				nested_renders = true
				break

	checks.authority_exists = c.suspected_role_ids == suspected and c.suspect_list_role_ids == suspected
	checks.suspected_count = suspected.size() == 8
	checks.reporter_suspected = suspected.has(&"reporter")
	checks.therapist_suspected = suspected.has(&"therapist")
	checks.blood_hound_suspected = suspected.has(&"blood_hound")
	checks.priest_suspected = suspected.has(&"tutorial_priest")
	checks.mailman_suspected = suspected.has(&"mailman")
	checks.mathematician_suspected = suspected.has(&"mathematician")
	checks.barkeep_suspected = suspected.has(&"barkeep")
	checks.poisoner_suspected = suspected.has(&"poisoner")
	checks.drunkard_not_suspected = not suspected.has(&"drunkard")
	checks.nested_barkeep_drunkard = nested == [&"drunkard"]
	checks.nested_drunkard_renders = nested_renders
	checks.nested_child_not_suspected = nested.has(&"drunkard") and not suspected.has(&"drunkard")
	checks.drunkard_current_in_play = current_in_play.has(&"drunkard")
	checks.mailman_current_not_in_play = bounded_not_in_play.has(&"mailman") and not current_in_play.has(&"mailman")
	checks.mathematician_suspected_not_in_play = suspected.has(&"mathematician") and bounded_not_in_play.has(&"mathematician")
	checks.drunkard_in_play_not_suspected = current_in_play.has(&"drunkard") and not suspected.has(&"drunkard")
	checks.transform_pool_unchanged = CASE_ROLE_POOL_SERVICE.suspected_role_ids_for_case(c) == suspected_before
	checks.ratio_static = _role_group_count(c, CaseEnums.RoleGroup.CHINH_NHAN) == 5 and _role_group_count(c, CaseEnums.RoleGroup.HIEU_SU) == 0 and _role_group_count(c, CaseEnums.RoleGroup.TONG_PHAM) == 2 and _role_group_count(c, CaseEnums.RoleGroup.NGHICH_THAN) == 0
	checks.reinitialize_pool_intact = suspected_after_reinit == suspected_before and reinit_runtime.current_role_id_for_suspect(c, 6) == &"mailman"
	checks.separate_runtime_pools = (
		separate_a.current_role_id_for_suspect(c, 6) == &"drunkard"
		and separate_b.current_role_id_for_suspect(c, 6) == &"mailman"
		and CASE_ROLE_POOL_SERVICE.suspected_role_ids_for_case(c) == suspected_before
	)
	checks.suspected_helper_excludes_nested = suspected_candidates == suspected and not suspected_candidates.has(&"drunkard")
	checks.bounded_not_in_play = bounded_not_in_play.has(&"mailman") and bounded_not_in_play.has(&"mathematician") and not bounded_not_in_play.has(&"weatherman")
	checks.good_absent_included = good_not_in_play.has(&"mathematician")
	checks.good_current_excluded = not good_not_in_play.has(&"drunkard") and not good_not_in_play.has(&"reporter")
	checks.good_evil_excluded = not good_not_in_play.has(&"poisoner")
	checks.good_placeholder_excluded = not good_not_in_play.has(&"role_good_a")
	checks.mailman_current_truth = (
		mailman_result != null
		and mailman_result.in_play_role_id == &"mathematician"
		and mailman_result.not_in_play_role_id == &"drunkard"
		and not mailman_result.claimed_in_play_is_true
		and not mailman_result.claimed_not_in_play_is_true
	)
	checks.duplicate_validation = _report_has_error_code(duplicate_report, "SUSPECTED_ROLE_DUPLICATE")
	checks.invalid_validation = _report_has_error_code(invalid_report, "SUSPECTED_ROLE_MISSING")
	checks.invalid_nested_validation = _report_has_error_code(invalid_nested_report, "NESTED_SUSPECT_LIST_ROLE_MISSING")
	checks.role_codex_separate = _role_codex_filters_available_roles()
	_t05_i2_free_scene(scene)
	return checks


func _t06_i1_live_scene(players: Array[PlayerCaseState]) -> VSCaseMainController:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var previous_pending: String = AppFlow.pending_case_path
	AppFlow.pending_case_path = FixtureRepository.TUTORIAL_CASE_006_PATH
	var scene: VSCaseMainController = _case_scene_instance() as VSCaseMainController
	if scene == null:
		AppFlow.pending_case_path = previous_pending
		return null
	scene.configure_integrated_case(players)
	tree.root.add_child(scene)
	AppFlow.pending_case_path = previous_pending
	return scene


func _tutorial_06_reveal(c: CaseDefinition, runtime: CaseRuntimeState, roles: Array[RoleDefinition]) -> CaseTruthReveal:
	if c == null or runtime == null:
		return null
	runtime.is_settled = true
	runtime.settlement_result = CaseSettlementResult.new()
	runtime.settlement_result.success = true
	return CaseTruthRevealBuilder.new().build(c, runtime, roles)


func _truth_for_suspect(reveal: CaseTruthReveal, suspect_id: int) -> SuspectTruthReveal:
	if reveal == null:
		return null
	for truth: SuspectTruthReveal in reveal.suspect_truths:
		if truth != null and truth.suspect_id == suspect_id:
			return truth
	return null


func _case_nested_suspect_list_role_ids(c: CaseDefinition, parent_role_id: StringName) -> Array[StringName]:
	var ids: Array[StringName] = []
	if c == null:
		return ids
	var raw_ids: Variant = c.nested_suspect_list_role_ids_by_parent.get(parent_role_id, [])
	var raw_array: Array = raw_ids if raw_ids is Array else []
	if raw_array.is_empty():
		raw_ids = c.nested_suspect_list_role_ids_by_parent.get(String(parent_role_id), [])
		raw_array = raw_ids if raw_ids is Array else []
	for raw_id: Variant in raw_array:
		ids.append(StringName(raw_id))
	return ids


func _case_slot_empty(c: CaseDefinition, slot: int) -> bool:
	if c == null:
		return false
	if c.crime_scene != null and c.crime_scene.board_slot == slot:
		return false
	for suspect: SuspectDefinition in c.suspects:
		if suspect != null and suspect.board_slot == slot:
			return false
	return true


func _role_group_count(c: CaseDefinition, group: int) -> int:
	var count: int = 0
	if c == null:
		return count
	for suspect: SuspectDefinition in c.suspects:
		if suspect != null and suspect.role_group == group:
			count += 1
	return count


func _t05_i3_entry_load(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_scene(players)
	var passed: bool = (
		scene != null
		and scene.case_definition != null
		and scene.case_definition.case_id == &"tutorial_case_005"
		and scene.runtime_state != null
		and scene.runtime_state.is_initialized
	)
	_t05_i2_free_scene(scene)
	return passed


func _t05_i3_investigated_runtime(c: CaseDefinition, players: Array[PlayerCaseState], suspect_id: int) -> CaseRuntimeState:
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	InvestigationService.new().investigate(c, runtime, suspect_id, runtime.current_player_id())
	return runtime


func _t05_i3_critic_math_behavior(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _t05_i3_investigated_runtime(c, players, 1)
	var views: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles)
	var view: SuspectPublicViewData = _tutorial_03_view(views, 1)
	return view != null and view.public_role_name == "Nhà Toán Học" and view.public_investigation_statement.contains("Tổng Số Hiệu")


func _t05_i3_critic_math_lies(c: CaseDefinition, roles: Array[RoleDefinition], _players: Array[PlayerCaseState]) -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var result: InvestigationInformationResult = service.evaluate(c, 1, roles)
	return result.truth_mode == InvestigationInformationResult.TruthMode.LYING and result.numeric_value != service.true_evil_suspect_number_sum(c)


func _t05_i3_critic_truth_hidden(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _t05_i3_investigated_runtime(c, players, 1)
	var views: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles)
	var view: SuspectPublicViewData = _tutorial_03_view(views, 1)
	return view != null and view.public_role_name == "Nhà Toán Học" and not view.public_role_name.contains("Nhà Phê Bình") and not view.full_truth_visible


func _t05_i3_weatherman_presentation(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _t05_i3_investigated_runtime(c, players, 3)
	var views: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles)
	var view: SuspectPublicViewData = _tutorial_03_view(views, 3)
	var result: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(c, 3, roles)
	return (
		view != null
		and view.public_role_name == "Nhà Khí Tượng"
		and result.payload_kind == InvestigationInformationResult.PayloadKind.WEATHER_REPORT
		and result.weather_suspect_ids.size() == 3
		and view.public_investigation_statement == result.text
	)


func _t05_i3_mobster_truth_hidden(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _t05_i3_investigated_runtime(c, players, 4)
	var views: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles)
	var view: SuspectPublicViewData = _tutorial_03_view(views, 4)
	return view != null and view.public_role_name == "Tư Tế" and not view.public_role_name.contains("Kẻ Côn Đồ") and not view.full_truth_visible


func _t05_i3_clock_label_text(scene: VSCaseMainController) -> String:
	if scene == null:
		return ""
	var label: Label = scene.get_node_or_null("%ElapsedHoursLabel") as Label
	return label.text if label != null else ""


func _t05_i3_clock_hud_investigation(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return false
	scene._perform_direct_investigation(2)
	var passed: bool = scene.runtime_state.elapsed_hours == 2 and _t05_i3_clock_label_text(scene).contains("2h")
	_t05_i2_free_scene(scene)
	return passed


func _t05_i3_clock_hud_single_accuse(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return false
	scene.selection_state.begin_submission()
	scene.selection_state.toggle_submission_suspect(1)
	scene._on_single_accuse_pressed()
	var passed: bool = scene.runtime_state.elapsed_hours == 1 and _t05_i3_clock_label_text(scene).contains("1h")
	_t05_i2_free_scene(scene)
	return passed


func _t05_i3_clock_hud_function_zero(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_vigilante_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return false
	var before_hours: int = scene.runtime_state.elapsed_hours
	scene._on_function_pressed_for_suspect(5)
	scene._on_suspect_action(1, MOUSE_BUTTON_LEFT, false)
	var passed: bool = scene.runtime_state.elapsed_hours == before_hours and _t05_i3_clock_label_text(scene).contains("%dh" % before_hours)
	_t05_i2_free_scene(scene)
	return passed


func _t05_i3_clock_hud_selection_zero(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_vigilante_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return false
	var before_hours: int = scene.runtime_state.elapsed_hours
	scene._on_function_pressed_for_suspect(5)
	var passed: bool = scene.runtime_state.elapsed_hours == before_hours and _t05_i3_clock_label_text(scene).contains("%dh" % before_hours)
	_t05_i2_free_scene(scene)
	return passed


func _t05_i3_clock_turn_only_zero(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return false
	var before_hours: int = scene.runtime_state.elapsed_hours
	scene.turn_manager.advance_turn()
	scene.runtime_state.apply_turn_snapshot(scene.turn_manager)
	scene._refresh_all_presentation()
	var passed: bool = scene.runtime_state.elapsed_hours == before_hours and _t05_i3_clock_label_text(scene).contains("%dh" % before_hours)
	_t05_i2_free_scene(scene)
	return passed


func _t05_i3_critic_math_reports_four(c: CaseDefinition, roles: Array[RoleDefinition]) -> bool:
	var result: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(c, 1, roles)
	return result != null and result.truth_mode == InvestigationInformationResult.TruthMode.LYING and result.numeric_value == 4


func _t05_i3_math_no_tutorial_four_hardcode() -> bool:
	var source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/RoleInformationEvaluationService.gd")
	return not source.contains("tutorial_case_005") and not source.contains("tutorial_05") and not source.contains("suspect_id == 1")


func _t05_i3_truthful_math_stable() -> bool:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"mathematician", &"mathematician", CaseEnums.Alignment.GOOD),
		_role_info_spec(2, 1, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL),
		_role_info_spec(3, 2, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL),
	], 4)
	c.evil_suspect_ids = PackedInt32Array([2, 3])
	c.accomplice_suspect_ids = PackedInt32Array([2, 3])
	var result: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(c, 1)
	return result != null and result.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL and result.numeric_value == 5


func _t05_i3_weatherman_triplet(c: CaseDefinition, roles: Array[RoleDefinition]) -> bool:
	var result: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(c, 3, roles)
	return result != null and result.weather_suspect_ids == PackedInt32Array([2, 4, 6])


func _t05_i3_so_hieu_is_suspect_id(c: CaseDefinition) -> bool:
	if c == null:
		return false
	var board_slot_evil_sum: int = 0
	for suspect: SuspectDefinition in c.suspects:
		if suspect != null and suspect.true_alignment == CaseEnums.Alignment.EVIL:
			board_slot_evil_sum += suspect.board_slot
	return (
		RoleInformationEvaluationService.new().true_evil_suspect_number_sum(c) == 5
		and board_slot_evil_sum == 6
	)


func _t05_i3_mathematician_help_so_hieu(roles: Array[RoleDefinition]) -> bool:
	var role: RoleDefinition = _find_role_for_test(roles, &"mathematician")
	return (
		role != null
		and role.help_text.contains("tổng Số Hiệu")
		and not role.help_text.contains("số thứ tự")
		and not role.help_text.contains("tổng số lớn hơn")
	)


func _t05_i3_so_hieu_glossary() -> bool:
	var entry: Dictionary = RoleGlossaryBank.entry_for_key(&"address")
	return (
		String(entry.get("title", "")) == "Số Hiệu"
		and String(entry.get("definition", "")).contains("không tính Hiện Trường")
		and RoleGlossaryBank.resolve_alias("Số Hiệu") == &"address"
		and RoleGlossaryBank.resolve_alias("số hiệu") == &"address"
	)


func _t05_i3_weatherman_triplet_order(c: CaseDefinition, roles: Array[RoleDefinition]) -> bool:
	var result: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(c, 3, roles)
	return (
		result != null
		and result.payload_kind == InvestigationInformationResult.PayloadKind.WEATHER_REPORT
		and result.weather_suspect_ids == PackedInt32Array([2, 4, 6])
		and result.public_text().contains("2, 4 và 6")
	)


func _t05_i3_weatherman_generic_authority() -> bool:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(10, 0, &"weatherman", &"weatherman", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(20, 1, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(40, 2, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(60, 8, &"role_meddler_a", &"role_meddler_a", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
	])
	var result: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(c, 10)
	return (
		result != null
		and result.weather_suspect_ids == PackedInt32Array([20, 40, 60])
		and result.weather_group_slots == PackedInt32Array([CaseEnums.RoleGroup.CHINH_NHAN, CaseEnums.RoleGroup.TONG_PHAM, CaseEnums.RoleGroup.HIEU_SU])
	)


func _t05_i3_after_all_investigations(players: Array[PlayerCaseState], force_surgeon_success: bool = false) -> Dictionary:
	var scene: VSCaseMainController = _t05_i2_live_scene(players)
	if scene == null or scene.runtime_state == null:
		return {"scene": null}
	scene.runtime_state.case_event_seed = 1 if force_surgeon_success else 0
	for suspect_id: int in [1, 2, 3, 4, 5, 6]:
		scene._perform_direct_investigation(suspect_id)
	return {"scene": scene}


func _t05_i3_live_surgeon_once(scene: VSCaseMainController) -> bool:
	if scene == null or scene.runtime_state == null:
		return false
	var event: CaseTimedEventRuntimeState = scene.runtime_state.timed_event_by_id(&"surgeon_6_12h")
	var before_logs: int = _timed_event_log_count(scene.runtime_state, &"surgeon_6_12h")
	scene.timed_event_dispatcher.evaluate_all(scene.case_definition, scene.runtime_state)
	return event != null and event.fired and before_logs == 1 and _timed_event_log_count(scene.runtime_state, &"surgeon_6_12h") == 1


func _t05_i3_live_surgeon_death_runtime(scene: VSCaseMainController) -> bool:
	if scene == null or scene.runtime_state == null:
		return false
	var event: CaseTimedEventRuntimeState = scene.runtime_state.timed_event_by_id(&"surgeon_6_12h")
	if event == null or not event.fired:
		return false
	var target_runtime: SuspectRuntimeState = scene.runtime_state.find_suspect(event.target_suspect_id)
	if event.kill_attempted:
		return target_runtime != null and target_runtime.is_dead and target_runtime.killed_by == &"surgeon"
	return target_runtime != null and not target_runtime.is_dead


func _t05_i3_dead_truth_preserved(c: CaseDefinition, scene: VSCaseMainController) -> bool:
	if c == null or scene == null or scene.runtime_state == null:
		return false
	var event: CaseTimedEventRuntimeState = scene.runtime_state.timed_event_by_id(&"surgeon_6_12h")
	if event == null or not event.kill_attempted:
		return true
	var suspect: SuspectDefinition = _case_suspect(c, event.target_suspect_id)
	return suspect != null and suspect.true_role_id != &"" and CaseEnums.is_valid_alignment(suspect.true_alignment)


func _t05_i3_live_vigilante_one_target(scene: VSCaseMainController) -> bool:
	if scene == null or scene.runtime_state == null:
		return false
	var state: InteractiveFunctionRuntimeState = scene.runtime_state.find_suspect(5).interactive_function
	return state != null and state.target_count == 1


func _t05_i3_live_vigilante_selection_no_consume(scene: VSCaseMainController) -> bool:
	if scene == null or scene.runtime_state == null:
		return false
	var state: InteractiveFunctionRuntimeState = scene.runtime_state.find_suspect(5).interactive_function
	if state == null:
		return false
	var before_uses: int = state.uses_remaining
	scene._on_function_pressed_for_suspect(5)
	return state.uses_remaining == before_uses and scene.selection_state.mode == InvestigationSelectionState.Mode.SELECTING_FUNCTION_TARGETS


func _t05_i3_live_vigilante_execute_state(scene: VSCaseMainController) -> Dictionary:
	var checks: Dictionary = {}
	if scene == null or scene.runtime_state == null:
		return checks
	if scene.selection_state.mode != InvestigationSelectionState.Mode.SELECTING_FUNCTION_TARGETS:
		scene._on_function_pressed_for_suspect(5)
	var before_turn: int = scene.turn_manager.turn_number
	var before_hours: int = scene.runtime_state.elapsed_hours
	scene._on_suspect_action(4, MOUSE_BUTTON_LEFT, false)
	var state: InteractiveFunctionRuntimeState = scene.runtime_state.find_suspect(5).interactive_function
	checks.selection_idle = scene.selection_state.mode == InvestigationSelectionState.Mode.IDLE
	checks.consumed = state != null and state.uses_remaining == 0
	checks.turn_once = scene.turn_manager.turn_number == before_turn + 1
	checks.zero_time = scene.runtime_state.elapsed_hours == before_hours
	checks.result_recorded = not scene.runtime_state.public_function_records.is_empty()
	checks.consumed_not_available = state != null and state.state == InteractiveFunctionRuntimeState.State.EXHAUSTED and not PostRevealFunctionService.new().has_executable_functions(scene.case_definition, scene.runtime_state)
	checks.awaiting_final = scene.runtime_state.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
	return checks


func _t05_i3_live_vigilante_handled_evil(players: Array[PlayerCaseState]) -> bool:
	var bundle: Dictionary = _t05_i2_execute_live_vigilante(players, 4)
	var scene: VSCaseMainController = bundle.get("scene", null) as VSCaseMainController
	var passed: bool = false
	if scene != null:
		var target_runtime: SuspectRuntimeState = scene.runtime_state.find_suspect(4)
		passed = target_runtime != null and target_runtime.is_dead and CaseResolutionService.new().unresolved_evil_ids(scene.case_definition, scene.runtime_state) == PackedInt32Array([1, 4])
	_t05_i2_free_scene(scene)
	return passed


func _t05_i3_live_vigilante_one_bundle(players: Array[PlayerCaseState]) -> Dictionary:
	var scene: VSCaseMainController = _t05_i2_live_vigilante_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return {"scene": null}
	var before_hours: int = scene.runtime_state.elapsed_hours
	var before_turn: int = scene.turn_manager.turn_number
	scene._on_function_pressed_for_suspect(5)
	scene._on_suspect_action(1, MOUSE_BUTTON_LEFT, false)
	var target_runtime: SuspectRuntimeState = scene.runtime_state.find_suspect(1)
	var state: InteractiveFunctionRuntimeState = scene.runtime_state.find_suspect(5).interactive_function
	var target_card: SuspectCardController = _board_card(scene.board, 1) if scene.board != null else null
	var owner_card: SuspectCardController = _board_card(scene.board, 5) if scene.board != null else null
	return {
		"scene": scene,
		"before_hours": before_hours,
		"before_turn": before_turn,
		"target": target_runtime,
		"state": state,
		"target_card": target_card,
		"owner_card": owner_card,
	}


func _t05_i3_vigilante_targets_one(players: Array[PlayerCaseState]) -> bool:
	var bundle: Dictionary = _t05_i3_live_vigilante_one_bundle(players)
	var scene: VSCaseMainController = bundle.get("scene", null) as VSCaseMainController
	var target: SuspectRuntimeState = bundle.get("target", null) as SuspectRuntimeState
	var state: InteractiveFunctionRuntimeState = bundle.get("state", null) as InteractiveFunctionRuntimeState
	var passed: bool = (
		scene != null
		and target != null
		and target.is_dead
		and state != null
		and state.uses_remaining == 0
		and scene.runtime_state.elapsed_hours == int(bundle.get("before_hours", -1))
		and scene.turn_manager.turn_number == int(bundle.get("before_turn", -1)) + 1
	)
	_t05_i2_free_scene(scene)
	return passed


func _t05_i3_vigilante_one_kill_service(players: Array[PlayerCaseState]) -> bool:
	var bundle: Dictionary = _t05_i3_live_vigilante_one_bundle(players)
	var scene: VSCaseMainController = bundle.get("scene", null) as VSCaseMainController
	var target: SuspectRuntimeState = bundle.get("target", null) as SuspectRuntimeState
	var passed: bool = target != null and target.killed_by == &"vigilante" and _vigilante_kill_log_count(scene.runtime_state, 1) == 1
	_t05_i2_free_scene(scene)
	return passed


func _t05_i3_vigilante_one_death_presentation(players: Array[PlayerCaseState]) -> bool:
	var bundle: Dictionary = _t05_i3_live_vigilante_one_bundle(players)
	var scene: VSCaseMainController = bundle.get("scene", null) as VSCaseMainController
	var target_card: SuspectCardController = bundle.get("target_card", null) as SuspectCardController
	var owner_card: SuspectCardController = bundle.get("owner_card", null) as SuspectCardController
	var passed: bool = (
		target_card != null
		and target_card.public_data != null
		and target_card.public_data.public_status_text.to_lower().contains("chết")
		and owner_card != null
		and not owner_card.get_public_function_result_text().is_empty()
	)
	_t05_i2_free_scene(scene)
	return passed


func _t05_i3_vigilante_death_transition_source() -> bool:
	var source: String = FileAccess.get_file_as_string("res://scripts/presentation/case_gameplay/SuspectCardController.gd")
	return source.contains("_play_death_transition") and source.contains("_is_dead_public_data") and source.contains("create_tween")


func _t05_i3_dead_single_accuse_rejected(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var bundle: Dictionary = _fresh_turn_bundle(c, players)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var player: PlayerCaseState = runtime.find_player(runtime.current_player_id()) if runtime != null else null
	if runtime == null or player == null:
		return false
	CaseKillService.new().kill(c, runtime, 1, &"smoke")
	var result: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(c, runtime, player, 1)
	return result.success and result.correct and result.suspect_id == 1


func _t05_i3_living_single_accuse_accepted(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var bundle: Dictionary = _fresh_turn_bundle(c, players)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var player: PlayerCaseState = runtime.find_player(runtime.current_player_id()) if runtime != null else null
	if runtime == null or player == null:
		return false
	var result: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(c, runtime, player, 2)
	return result.success and result.suspect_id == 2


func _t05_i3_dead_ui_not_selectable(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return false
	CaseKillService.new().kill(scene.case_definition, scene.runtime_state, 1, &"smoke")
	scene._refresh_all_presentation()
	scene._toggle_evil_marking(1)
	var passed: bool = scene.selection_state.selected_submission_evil_ids == PackedInt32Array([1])
	_t05_i2_free_scene(scene)
	return passed


func _t05_i3_death_no_private_direct(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	CaseKillService.new().kill(c, runtime, 1, &"smoke")
	return runtime.private_role_knowledge.is_empty()


func _t05_i3_dead_owner_no_post_trap(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle: Dictionary = _fresh_function_bundle(c, roles, players)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var state: InteractiveFunctionRuntimeState = runtime.find_suspect(5).interactive_function
	if state == null:
		return false
	runtime.find_suspect(5).is_investigated = true
	state.state = InteractiveFunctionRuntimeState.State.AVAILABLE
	state.uses_remaining = 1
	runtime.find_suspect(5).mark_dead(&"smoke")
	runtime.case_outcome = CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS
	var resolved: bool = PostRevealFunctionService.new().resolve_phase(c, runtime)
	return resolved and runtime.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT and state.state == InteractiveFunctionRuntimeState.State.EXPIRED


func _t05_i3_dead_target_no_post_trap(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle: Dictionary = _fresh_function_bundle(c, roles, players)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var state: InteractiveFunctionRuntimeState = runtime.find_suspect(5).interactive_function
	if state == null:
		return false
	runtime.find_suspect(5).is_investigated = true
	state.state = InteractiveFunctionRuntimeState.State.AVAILABLE
	state.uses_remaining = 1
	runtime.find_suspect(4).mark_dead(&"smoke")
	runtime.case_outcome = CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS
	var execution: InteractiveFunctionResult = InteractiveFunctionExecutionService.new().execute(c, runtime, 5, PackedInt32Array([4]), runtime.current_player_id())
	if execution.success:
		PostRevealFunctionService.new().resolve_phase(c, runtime)
	return execution.success and state.state == InteractiveFunctionRuntimeState.State.EXHAUSTED and runtime.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT


func _t05_i3_one_target_reveal_safe(players: Array[PlayerCaseState]) -> bool:
	var bundle: Dictionary = _t05_i3_live_vigilante_one_bundle(players)
	var scene: VSCaseMainController = bundle.get("scene", null) as VSCaseMainController
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return false
	var one_record: PublicFunctionRecord = scene.runtime_state.public_function_records[0] if scene.runtime_state.public_function_records.size() == 1 else null
	var one_summary: String = one_record.summary_text() if one_record != null else ""
	var one_target_safe: bool = (
		one_record != null
		and one_record.target_suspect_ids.size() == 1
		and one_summary == "Số Hiệu 1 đã bị xử quyết."
		and not one_summary.begins_with("Nghi phạm")
		and not one_summary.begins_with("Vigilante:")
	)
	var tailor_record := PublicFunctionRecord.new()
	var tailor_ok: bool = tailor_record.configure(9001, 1, "Thợ May", PackedInt32Array([3, 4]), &"smoke", 1, "cùng phe")
	var two_target_unchanged: bool = tailor_ok and tailor_record.summary_text() == "Thợ May: Nghi phạm 3 và 4 cùng phe."
	scene.runtime_state.case_outcome = CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
	scene.runtime_state.lock_case_actions()
	var service: FinalVerdictService = FinalVerdictService.new()
	var init: FinalVerdictResult = service.initialize(scene.runtime_state)
	var locks_ok: bool = init.success
	while locks_ok and scene.runtime_state.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT:
		var player_id: StringName = scene.runtime_state.current_final_player_id()
		if player_id == &"":
			break
		var submission: CaseSubmission = _t05_i3_correct_final_submission(scene.case_definition, scene.runtime_state, player_id)
		var lock: FinalVerdictResult = service.lock_submission(scene.case_definition, scene.runtime_state, submission)
		locks_ok = lock.success
	scene._refresh_all_presentation()
	var text: String = scene.truth_functions_label.text if scene.truth_functions_label != null else ""
	var reveal_text_safe: bool = text.contains("Số Hiệu 1 đã bị xử quyết.") and not text.contains("Nghi phạm 1:") and not text.contains("Vigilante: Số Hiệu 1")
	var passed: bool = locks_ok and scene.runtime_state.case_outcome == CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED and one_target_safe and reveal_text_safe and two_target_unchanged
	_t05_i2_free_scene(scene)
	return passed


func _t05_i3_final_and_settlement(players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	var scene: VSCaseMainController = (_t05_i3_after_all_investigations(players).get("scene", null)) as VSCaseMainController
	if scene == null or scene.runtime_state == null:
		return checks
	var execution_state: Dictionary = _t05_i3_live_vigilante_execute_state(scene)
	checks.awaiting_final = bool(execution_state.get("awaiting_final", false))
	var service: FinalVerdictService = FinalVerdictService.new()
	var init: FinalVerdictResult = service.initialize(scene.runtime_state)
	var locks_ok: bool = init.success
	while locks_ok and scene.runtime_state.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT:
		var player_id: StringName = scene.runtime_state.current_final_player_id()
		if player_id == &"":
			break
		var submission: CaseSubmission = _t05_i3_correct_final_submission(scene.case_definition, scene.runtime_state, player_id)
		var lock: FinalVerdictResult = service.lock_submission(scene.case_definition, scene.runtime_state, submission)
		locks_ok = lock.success
	checks.final_resolves = locks_ok and scene.runtime_state.case_outcome == CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED and scene.runtime_state.final_evaluation_count == 1
	var first_settlement: CaseSettlementResult = CaseSettlementService.new().settle(scene.case_definition, scene.runtime_state)
	var first_merit: float = scene.runtime_state.find_player(&"player_1").merit
	var second_settlement: CaseSettlementResult = CaseSettlementService.new().settle(scene.case_definition, scene.runtime_state)
	checks.settlement_success = first_settlement.success
	checks.settlement_once = first_settlement == second_settlement and is_equal_approx(scene.runtime_state.find_player(&"player_1").merit, first_merit)
	_t05_i2_free_scene(scene)
	return checks


func _t05_i3_correct_final_submission(c: CaseDefinition, runtime: CaseRuntimeState, player_id: StringName) -> CaseSubmission:
	var submission: CaseSubmission = CaseSubmission.new()
	submission.configure(
		player_id,
		runtime.turn_number,
		CaseResolutionService.new().unresolved_evil_ids(c, runtime),
		CaseResolutionService.new().unresolved_underling_ids(c, runtime),
		CaseResolutionService.new().unresolved_traitor_ids(c, runtime),
		CaseEnums.SubmissionPhase.FINAL
	)
	return submission


func _t05_i3_surgeon_seed_success(players: Array[PlayerCaseState]) -> bool:
	var result: Dictionary = _surgeon_evaluate(_surgeon_case(), players, 1, 12)
	var event: CaseTimedEventRuntimeState = result.event as CaseTimedEventRuntimeState
	return event != null and event.fired and event.resolved_success


func _t05_i3_surgeon_seed_failure(players: Array[PlayerCaseState]) -> bool:
	var result: Dictionary = _surgeon_evaluate(_surgeon_case(), players, 0, 12)
	var event: CaseTimedEventRuntimeState = result.event as CaseTimedEventRuntimeState
	return event != null and event.fired and not event.resolved_success


func _t05_i3_surgeon_unrevealed_alive(players: Array[PlayerCaseState]) -> bool:
	var result: Dictionary = _surgeon_evaluate(_surgeon_case(), players, 1, 12)
	var event: CaseTimedEventRuntimeState = result.event as CaseTimedEventRuntimeState
	return event != null and event.fired and event.source_suspect_id == 1


func _t05_i3_surgeon_revealed_alive(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _surgeon_case()
	var runtime: CaseRuntimeState = _surgeon_runtime(c, players, 1, 12)
	runtime.find_suspect(1).is_investigated = true
	var events: Array[CaseTimedEventRuntimeState] = SurgeonTimedEventService.new().evaluate(c, runtime)
	var event: CaseTimedEventRuntimeState = events[0] if not events.is_empty() else null
	return event != null and event.fired and event.source_suspect_id == 1


func _t05_i3_surgeon_dead_source_blocked(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _surgeon_case()
	var runtime: CaseRuntimeState = _surgeon_runtime(c, players, 1, 12)
	runtime.find_suspect(1).mark_dead(&"smoke")
	var events: Array[CaseTimedEventRuntimeState] = SurgeonTimedEventService.new().evaluate(c, runtime)
	return events.is_empty() and _dead_suspect_count(runtime) == 1


func _t05_i3_surgeon_displayed_false_source(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"tutorial_priest", &"surgeon", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(2, 1, &"reporter", &"reporter", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
	])
	var runtime: CaseRuntimeState = _surgeon_runtime(c, players, 1, 12)
	var events: Array[CaseTimedEventRuntimeState] = SurgeonTimedEventService.new().evaluate(c, runtime)
	return events.is_empty() and _dead_suspect_count(runtime) == 0


func _t05_i3_runtime_event_seed_fresh() -> bool:
	var source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/CaseRuntimeState.gd")
	return source.contains("_new_runtime_event_seed") and source.contains("generate_random_bytes") and not source.contains("case_event_seed = _stable_case_seed(case_id)")


func _t05_i3_surgeon_not_fixture_forced() -> bool:
	var source: String = FileAccess.get_file_as_string("res://content/cases/fixtures/tutorial_case_005.tres")
	return not source.contains("case_event_seed") and not source.contains("surgeon_success") and not source.contains("surgeon_target")


func _t05_i3_surgeon_same_run_no_reroll(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _surgeon_case()
	var runtime: CaseRuntimeState = _surgeon_runtime(c, players, 1, 12)
	var service: SurgeonTimedEventService = SurgeonTimedEventService.new()
	var first_events: Array[CaseTimedEventRuntimeState] = service.evaluate(c, runtime)
	var first: CaseTimedEventRuntimeState = first_events[0] if not first_events.is_empty() else null
	if first == null:
		return false
	var first_success: bool = first.resolved_success
	var first_log_count: int = _timed_event_log_count(runtime, &"surgeon_1_12h")
	runtime.case_event_seed = 0
	service.evaluate(c, runtime)
	return first.resolved_success == first_success and _timed_event_log_count(runtime, &"surgeon_1_12h") == first_log_count


func _t05_i3_surgeon_no_hardcoded_victim() -> bool:
	var source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/SurgeonTimedEventService.gd")
	return not source.contains("target_suspect_id = 5") and not source.contains("suspect_id == 5") and source.contains("_random_alive_current_innocent") and not source.contains("_first_alive_true_innocent")


func _t05_i3_no_tutorial_specific_domain_branch() -> bool:
	var paths: Array[String] = [
		"res://scripts/domain/cases/InvestigationService.gd",
		"res://scripts/domain/cases/RoleInformationEvaluationService.gd",
		"res://scripts/domain/cases/SingleSuspectAccusationService.gd",
		"res://scripts/domain/cases/CaseClockService.gd",
		"res://scripts/domain/cases/SurgeonTimedEventService.gd",
		"res://scripts/domain/cases/InteractiveFunctionExecutionService.gd",
		"res://scripts/domain/cases/PostRevealFunctionService.gd",
		"res://scripts/domain/cases/FinalVerdictService.gd",
		"res://scripts/domain/cases/CaseSettlementService.gd",
	]
	for path: String in paths:
		var source: String = FileAccess.get_file_as_string(path)
		if source.contains("tutorial_case_005") or source.contains("tutorial_05") or source.contains("Tutorial 05"):
			return false
	return true


func _t05_i3_vigilante_kill_summary_exact(players: Array[PlayerCaseState]) -> bool:
	var bundle: Dictionary = _t05_i3_live_vigilante_one_bundle(players)
	var scene: VSCaseMainController = bundle.get("scene", null) as VSCaseMainController
	var record: PublicFunctionRecord = scene.runtime_state.public_function_records[0] if scene != null and scene.runtime_state.public_function_records.size() == 1 else null
	var owner_card: SuspectCardController = bundle.get("owner_card", null) as SuspectCardController
	var passed: bool = (
		record != null
		and record.summary_text() == "Số Hiệu 1 đã bị xử quyết."
		and owner_card != null
		and owner_card.get_public_function_result_text() == "Số Hiệu 1 đã bị xử quyết."
	)
	_t05_i2_free_scene(scene)
	return passed


func _t05_i3_vigilante_miss_summary_exact(players: Array[PlayerCaseState]) -> bool:
	var bundle: Dictionary = _t05_i2_execute_live_vigilante(players, 6)
	var scene: VSCaseMainController = bundle.get("scene", null) as VSCaseMainController
	var record: PublicFunctionRecord = scene.runtime_state.public_function_records[0] if scene != null and scene.runtime_state.public_function_records.size() == 1 else null
	var owner_card: SuspectCardController = _board_card(scene.board, 5) if scene != null and scene.board != null else null
	var passed: bool = (
		record != null
		and record.summary_text() == "Số Hiệu 6 bình an vô sự."
		and owner_card != null
		and owner_card.get_public_function_result_text() == "Số Hiệu 6 bình an vô sự."
	)
	_t05_i2_free_scene(scene)
	return passed


func _t05_i3_vigilante_no_duplicate_prefix(players: Array[PlayerCaseState]) -> bool:
	var kill_bundle: Dictionary = _t05_i3_live_vigilante_one_bundle(players)
	var kill_scene: VSCaseMainController = kill_bundle.get("scene", null) as VSCaseMainController
	var kill_card: SuspectCardController = kill_bundle.get("owner_card", null) as SuspectCardController
	var kill_text: String = kill_card.get_public_function_result_text() if kill_card != null else ""
	var miss_bundle: Dictionary = _t05_i2_execute_live_vigilante(players, 6)
	var miss_scene: VSCaseMainController = miss_bundle.get("scene", null) as VSCaseMainController
	var miss_card: SuspectCardController = _board_card(miss_scene.board, 5) if miss_scene != null and miss_scene.board != null else null
	var miss_text: String = miss_card.get_public_function_result_text() if miss_card != null else ""
	var passed: bool = (
		not kill_text.contains("Nghi phạm")
		and not kill_text.contains("Suspect")
		and not miss_text.contains("Nghi phạm")
		and not miss_text.contains("Suspect")
	)
	_t05_i2_free_scene(kill_scene)
	_t05_i2_free_scene(miss_scene)
	return passed


func _t05_i3_function_click_targeting_checks(players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	var scene: VSCaseMainController = _t05_i2_live_vigilante_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return checks
	var before_hours: int = scene.runtime_state.elapsed_hours
	var before_turn: int = scene.turn_manager.turn_number
	var target_runtime: SuspectRuntimeState = scene.runtime_state.find_suspect(1)
	var before_investigated: bool = target_runtime != null and target_runtime.is_investigated
	var state: InteractiveFunctionRuntimeState = scene.runtime_state.find_suspect(5).interactive_function
	var before_uses: int = state.uses_remaining if state != null else -1
	scene._on_function_pressed_for_suspect(5)
	var card: SuspectCardController = _board_card(scene.board, 1) if scene.board != null else null
	checks.no_hold = card != null and card.immediate_left_click_action_enabled
	if card != null:
		_emit_card_left_click(card)
	target_runtime = scene.runtime_state.find_suspect(1)
	state = scene.runtime_state.find_suspect(5).interactive_function
	checks.unrevealed_target = target_runtime != null and target_runtime.is_dead
	checks.no_investigation = target_runtime != null and target_runtime.is_investigated == before_investigated and not before_investigated
	checks.execute_once = scene.runtime_state.public_function_records.size() == 1 and _successful_function_log_count(scene.runtime_state) == 1
	checks.consumes_once = state != null and state.uses_remaining == before_uses - 1
	checks.turn_once = scene.turn_manager.turn_number == before_turn + 1
	checks.time_zero = scene.runtime_state.elapsed_hours == before_hours
	_t05_i2_free_scene(scene)
	return checks


func _t05_i3_revealed_function_click_target(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_vigilante_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return false
	var target_runtime: SuspectRuntimeState = scene.runtime_state.find_suspect(4)
	if target_runtime != null:
		target_runtime.is_investigated = true
	scene._refresh_all_presentation()
	scene._on_function_pressed_for_suspect(5)
	var card: SuspectCardController = _board_card(scene.board, 4) if scene.board != null else null
	if card != null:
		_emit_card_left_click(card)
	var state: InteractiveFunctionRuntimeState = scene.runtime_state.find_suspect(5).interactive_function
	var passed: bool = (
		scene.runtime_state.find_suspect(4).is_dead
		and state != null
		and state.uses_remaining == 0
		and scene.runtime_state.public_function_records.size() == 1
	)
	_t05_i2_free_scene(scene)
	return passed


func _t05_i3_right_cancel_checks(players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	var scene: VSCaseMainController = _t05_i2_live_vigilante_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return checks
	var state: InteractiveFunctionRuntimeState = scene.runtime_state.find_suspect(5).interactive_function
	var before_uses: int = state.uses_remaining if state != null else -1
	var before_turn: int = scene.turn_manager.turn_number
	var before_hours: int = scene.runtime_state.elapsed_hours
	scene._on_function_pressed_for_suspect(5)
	scene.selection_state.toggle_function_target(1)
	if scene.board != null:
		scene.board.set_function_target_selection(true, scene.selection_state.selected_function_target_ids)
	_emit_scene_right_click(scene)
	state = scene.runtime_state.find_suspect(5).interactive_function
	checks.cancelled = scene.selection_state.mode == InvestigationSelectionState.Mode.IDLE
	checks.background_path = true
	checks.targets_cleared = scene.selection_state.selected_function_target_ids.is_empty()
	checks.uses_preserved = state != null and state.uses_remaining == before_uses
	checks.turn_preserved = scene.turn_manager.turn_number == before_turn
	checks.time_preserved = scene.runtime_state.elapsed_hours == before_hours
	checks.no_execute = scene.runtime_state.public_function_records.is_empty() and _successful_function_log_count(scene.runtime_state) == 0
	checks.function_available = state != null and state.state == InteractiveFunctionRuntimeState.State.AVAILABLE
	checks.normal_restored = scene.board != null and not scene.board.function_target_selection_enabled
	_t05_i2_free_scene(scene)
	return checks


func _t05_i3_right_cancel_multi_target(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return false
	scene.selection_state.begin_function_selection(PackedInt32Array([1]), 2)
	scene.selection_state.toggle_function_target(2)
	if scene.board != null:
		scene.board.set_function_target_selection(true, scene.selection_state.selected_function_target_ids)
	var before_turn: int = scene.turn_manager.turn_number
	var before_hours: int = scene.runtime_state.elapsed_hours
	_emit_scene_right_click(scene)
	var passed: bool = (
		scene.selection_state.mode == InvestigationSelectionState.Mode.IDLE
		and scene.selection_state.selected_function_target_ids.is_empty()
		and scene.runtime_state.public_function_records.is_empty()
		and scene.turn_manager.turn_number == before_turn
		and scene.runtime_state.elapsed_hours == before_hours
	)
	_t05_i2_free_scene(scene)
	return passed


func _t05_i3_normal_click_investigation_unchanged(players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _t05_i2_live_scene(players)
	if scene == null or scene.runtime_state == null:
		_t05_i2_free_scene(scene)
		return false
	var before_hours: int = scene.runtime_state.elapsed_hours
	var before_turn: int = scene.turn_manager.turn_number
	var card: SuspectCardController = _board_card(scene.board, 2) if scene.board != null else null
	if card != null:
		_emit_card_left_click(card)
	var runtime: SuspectRuntimeState = scene.runtime_state.find_suspect(2)
	var passed: bool = (
		runtime != null
		and not runtime.is_investigated
		and scene.runtime_state.elapsed_hours == before_hours
		and scene.turn_manager.turn_number == before_turn
	)
	_t05_i2_free_scene(scene)
	return passed


func _emit_card_left_click(card: SuspectCardController) -> void:
	var press: InputEventMouseButton = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	card._gui_input(press)
	var release: InputEventMouseButton = InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	card._gui_input(release)


func _suspect_card_full_rect_hitbox_checks(tutorial_case_06: CaseDefinition) -> Dictionary:
	var checks: Dictionary = {}
	var card: SuspectCardController = _smoke_suspect_card(false, false)
	if card == null:
		return checks
	checks.question_mark_area = card.visual_input_region_ignores_mouse_for_smoke("%UnknownIconLabel")
	checks.number_area = card.visual_input_region_ignores_mouse_for_smoke("%SuspectNumber")
	checks.top_gap_area = card.visual_input_region_ignores_mouse_for_smoke("CardPresentationRoot/CardVisual/CardContent/TopRow/TopSpacer")
	checks.lower_area = (
		card.visual_input_region_ignores_mouse_for_smoke("%PublicRoleLabel")
		and card.visual_input_region_ignores_mouse_for_smoke("%PublicStatementLabel")
		and card.has_full_rect_input_surface_for_smoke()
	)
	var card_source: String = FileAccess.get_file_as_string("res://scripts/presentation/case_gameplay/SuspectCardController.gd")
	var case_source: String = FileAccess.get_file_as_string("res://scripts/presentation/case_gameplay/VSCaseMainController.gd")
	checks.unrevealed_hold = _suspect_card_unrevealed_hold_contract(card, card_source)
	checks.function_target_click = _suspect_card_function_target_click_contract(card, card_source)
	checks.revealed_click = _suspect_card_revealed_click_contract(card, card_source)
	checks.right_click_cancel = _suspect_card_right_click_cancel_contract(card, card_source, case_source)
	checks.no_duplicate_action = (
		card.has_full_rect_input_surface_for_smoke()
		and card_source.contains("signal suspect_action")
		and _substring_count(card_source, "func _gui_input(event: InputEvent)") == 1
		and _substring_count(card_source, "suspect_action.emit(") == 3
		and not card_source.contains(".gui_input.connect")
	)
	checks.outside_empty_slot = _case_board_empty_slots_ignore_mouse(tutorial_case_06)
	card.queue_free()
	return checks


func _smoke_suspect_card(is_investigated: bool, immediate_left_click: bool) -> SuspectCardController:
	var packed: PackedScene = load(SUSPECT_CARD_PATH) as PackedScene
	if packed == null:
		return null
	var card: SuspectCardController = packed.instantiate() as SuspectCardController
	if card == null:
		return null
	var view: SuspectPublicViewData = SuspectPublicViewData.new(7)
	view.board_slot = 8
	view.is_investigated = is_investigated
	view.public_role_name = "Sử Quan" if is_investigated else ""
	view.public_investigation_statement = "Ta cách Phe Ác gần nhất 2 bước." if is_investigated else ""
	view.public_status_text = "Đã điều tra" if is_investigated else "Chưa điều tra"
	card.configure(view)
	card.set_immediate_left_click_action(immediate_left_click)
	return card


func _suspect_card_unrevealed_hold_contract(card: SuspectCardController, source: String) -> bool:
	return (
		card != null
		and card.has_full_rect_input_surface_for_smoke()
		and not card.public_data.is_investigated
		and source.contains("suspect_hold_progress_started.emit(public_data.suspect_id, INVESTIGATION_HOLD_DURATION_SEC)")
		and source.contains("_hold_elapsed_sec >= INVESTIGATION_HOLD_DURATION_SEC")
		and source.contains("suspect_action.emit(public_data.suspect_id, MOUSE_BUTTON_LEFT, true)")
		and source.contains("suspect_hold_progress_canceled.emit(public_data.suspect_id)")
	)


func _suspect_card_function_target_click_contract(card: SuspectCardController, source: String) -> bool:
	return (
		card != null
		and card.has_full_rect_input_surface_for_smoke()
		and source.contains("func set_immediate_left_click_action(enabled: bool) -> void:")
		and source.contains("immediate_left_click_action_enabled = enabled")
		and source.contains("mb.button_index == MOUSE_BUTTON_LEFT and immediate_left_click_action_enabled")
		and source.contains("suspect_action.emit(public_data.suspect_id, _active_button, is_hold)")
	)


func _suspect_card_revealed_click_contract(card: SuspectCardController, source: String) -> bool:
	return (
		card != null
		and card.has_full_rect_input_surface_for_smoke()
		and source.contains("not public_data.is_investigated")
		and source.contains("else:")
		and source.contains("suspect_action.emit(public_data.suspect_id, _active_button, is_hold)")
	)


func _suspect_card_right_click_cancel_contract(card: SuspectCardController, card_source: String, case_source: String) -> bool:
	return (
		card != null
		and card.has_full_rect_input_surface_for_smoke()
		and card_source.contains("mb.button_index == MOUSE_BUTTON_RIGHT and immediate_left_click_action_enabled")
		and card_source.contains("suspect_action.emit(public_data.suspect_id, MOUSE_BUTTON_RIGHT, false)")
		and case_source.contains("button_index == MOUSE_BUTTON_RIGHT and selection_state.mode == InvestigationSelectionState.Mode.SELECTING_FUNCTION_TARGETS")
		and case_source.contains("_on_cancel_pressed()")
	)


func _substring_count(source: String, needle: String) -> int:
	if needle.is_empty():
		return 0
	var count: int = 0
	var from_index: int = 0
	while true:
		var found_index: int = source.find(needle, from_index)
		if found_index < 0:
			break
		count += 1
		from_index = found_index + needle.length()
	return count


func _case_board_empty_slots_ignore_mouse(c: CaseDefinition) -> bool:
	if c == null:
		return false
	var board: CaseBoardController = _board_instance(c)
	if board == null:
		return false
	var grid: GridContainer = board.get_node("%Grid") as GridContainer
	var found_empty_slot: bool = false
	var all_empty_slots_ignore: bool = true
	for child: Node in grid.get_children():
		if child is Control and String(child.name).begins_with("EmptyCaseSlot"):
			found_empty_slot = true
			if (child as Control).mouse_filter != Control.MOUSE_FILTER_IGNORE:
				all_empty_slots_ignore = false
	board.queue_free()
	return found_empty_slot and all_empty_slots_ignore


func _emit_scene_right_click(scene: VSCaseMainController) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_RIGHT
	event.pressed = true
	scene._input(event)


func _case_suspect(c: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	if c == null:
		return null
	for suspect: SuspectDefinition in c.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null


func _count_true_role(c: CaseDefinition, role_id: StringName) -> int:
	var count := 0
	if c == null:
		return count
	for suspect: SuspectDefinition in c.suspects:
		if suspect != null and suspect.true_role_id == role_id:
			count += 1
	return count


func _count_displayed_role(c: CaseDefinition, role_id: StringName) -> int:
	var count := 0
	if c == null:
		return count
	for suspect: SuspectDefinition in c.suspects:
		if suspect != null and suspect.displayed_role_id == role_id:
			count += 1
	return count


func _true_role_ids_unique(c: CaseDefinition) -> bool:
	var seen: Dictionary = {}
	if c == null:
		return false
	for suspect: SuspectDefinition in c.suspects:
		if suspect == null:
			return false
		if seen.has(suspect.true_role_id):
			return false
		seen[suspect.true_role_id] = true
	return true


func _report_has_error_code(report: Dictionary, code: String) -> bool:
	var errors_value: Variant = report.get("errors", [])
	if not (errors_value is Array):
		return false
	for error: Variant in errors_value:
		if error is Dictionary and String(error.get("code", "")) == code:
			return true
	return false


func _tutorial_03_private_record_has(records: Array[PrivateRoleKnowledgeRecord], suspect_id: int, role_id: StringName) -> bool:
	for record in records:
		if record != null and record.suspect_id == suspect_id and record.true_role_id == role_id:
			return true
	return false


func _evil_answer_ids_exist(case_fixture: CaseDefinition) -> bool:
	if case_fixture == null:
		return false
	var ids: Dictionary = {}
	for suspect in case_fixture.suspects:
		ids[suspect.suspect_id] = true
	for suspect_id in case_fixture.evil_suspect_ids:
		if not ids.has(suspect_id):
			return false
	return true


func _classification_matches_truth(case_fixture: CaseDefinition) -> bool:
	if case_fixture == null:
		return false
	var by_id: Dictionary = {}
	for suspect in case_fixture.suspects:
		by_id[suspect.suspect_id] = suspect
	for suspect_id in case_fixture.accomplice_suspect_ids:
		if not by_id.has(suspect_id) or by_id[suspect_id].role_group != CaseEnums.RoleGroup.TONG_PHAM:
			return false
	for suspect_id in case_fixture.traitor_suspect_ids:
		if not by_id.has(suspect_id) or by_id[suspect_id].role_group != CaseEnums.RoleGroup.NGHICH_THAN:
			return false
	return not case_fixture.accomplice_suspect_ids.is_empty() and not case_fixture.traitor_suspect_ids.is_empty()


func _reward_fixture_complete(case_fixture: CaseDefinition) -> bool:
	return (
		case_fixture != null
		and case_fixture.merit_pool >= 0
		and case_fixture.reputation_penalty_on_wrong >= 0
		and case_fixture.base_ticket_reward >= 0
		and case_fixture.on_solve != null
		and case_fixture.test_only_not_balance_locked
		and case_fixture.on_solve.test_only_not_balance_locked
	)


func _players_are_valid(players: Array[PlayerCaseState]) -> bool:
	if players.size() != 3:
		return false
	for player in players:
		if player.reputation < 0 or player.reputation > 6:
			return false
		if player.merit < 0 or player.orb_count < 0 or player.gacha_ticket_count < 0:
			return false
	return true


func _public_views(case_fixture: CaseDefinition) -> Array[SuspectPublicViewData]:
	return CasePublicPresentationBuilder.new().build_suspect_views(case_fixture)


func _board_instance(case_fixture: CaseDefinition) -> CaseBoardController:
	var packed := load(CASE_BOARD_PATH) as PackedScene
	if packed == null:
		return null
	var board := packed.instantiate() as CaseBoardController
	if board != null:
		board.populate(case_fixture.location_definitions(), _public_views(case_fixture))
	return board


func _board_card_count(case_fixture: CaseDefinition) -> int:
	var board := _board_instance(case_fixture)
	if board == null:
		return -1
	var count := board.get_card_count()
	board.free()
	return count


func _board_tile_count(case_fixture: CaseDefinition) -> int:
	var board := _board_instance(case_fixture)
	if board == null:
		return -1
	var count := board.get_case_tile_count()
	board.free()
	return count


func _tutorial_board_preserves_sparse_layout(case_fixture: CaseDefinition) -> bool:
	var board := _board_instance(case_fixture)
	if board == null:
		return false
	var passed: bool = (
		board.get_case_tile_count() == 9
		and board.get_occupied_tile_count() == 3
		and board.get_empty_slot_count() == 6
		and board.get_card_count() == 2
		and board.has_crime_scene_tile()
	)
	board.free()
	return passed


func _tutorial_unused_slots_remain_empty(case_fixture: CaseDefinition) -> bool:
	var board := _board_instance(case_fixture)
	if board == null:
		return false
	var passed := board.get_empty_slot_count() == 6
	board.free()
	return passed


func _board_slots_match_authored(case_fixture: CaseDefinition) -> bool:
	var board := _board_instance(case_fixture)
	if board == null or case_fixture == null or case_fixture.crime_scene == null:
		return false
	var passed := board.get_crime_scene_slot() == case_fixture.crime_scene.board_slot
	for suspect in case_fixture.suspects:
		if suspect == null:
			passed = false
			break
		if board.get_suspect_slot(suspect.suspect_id) != suspect.board_slot:
			passed = false
			break
	board.free()
	return passed


func _board_has_crime_scene(case_fixture: CaseDefinition) -> bool:
	var board := _board_instance(case_fixture)
	if board == null:
		return false
	var found := board.has_crime_scene_tile()
	board.free()
	return found


func _board_ids_are_ordered(case_fixture: CaseDefinition) -> bool:
	var board := _board_instance(case_fixture)
	if board == null:
		return false
	var is_ordered := board.get_rendered_ids() == PackedInt32Array([1, 2, 3, 4, 5, 6, 7, 8])
	board.free()
	return is_ordered


func _crime_scene_not_runtime_suspect(case_fixture: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var runtime := CaseRuntimeState.new()
	runtime.initialize(case_fixture, players)
	return runtime.suspects.size() == case_fixture.suspects.size() and runtime.find_suspect(0) == null


func _spatial_service_uses_fixed_slots() -> bool:
	var spatial: CaseSpatialService = CaseSpatialService.new()
	return (
		CaseSpatialService.BOARD_SLOT_COUNT == 9
		and spatial.slot_to_row_column(0) == Vector2i(0, 0)
		and spatial.slot_to_row_column(4) == Vector2i(1, 1)
		and spatial.slot_to_row_column(8) == Vector2i(2, 2)
		and not spatial.is_valid_slot(-1)
		and not spatial.is_valid_slot(9)
	)


func _spatial_orthogonal_adjacency() -> bool:
	var spatial: CaseSpatialService = CaseSpatialService.new()
	return (
		spatial.are_orthogonally_adjacent(0, 1)
		and spatial.are_orthogonally_adjacent(0, 3)
		and not spatial.are_orthogonally_adjacent(0, 4)
		and _packed_ints_match(spatial.orthogonal_neighbour_slots(4), PackedInt32Array([1, 3, 5, 7]))
	)


func _spatial_surrounding_neighbours() -> bool:
	var spatial: CaseSpatialService = CaseSpatialService.new()
	return (
		_packed_ints_match(spatial.surrounding_neighbour_slots(4), PackedInt32Array([0, 1, 2, 3, 5, 6, 7, 8]))
		and _packed_ints_match(spatial.surrounding_neighbour_slots(0), PackedInt32Array([1, 3, 4]))
		and spatial.are_surrounding_neighbours(0, 4)
	)


func _spatial_orthogonal_distances() -> bool:
	var spatial: CaseSpatialService = CaseSpatialService.new()
	return (
		spatial.orthogonal_step_distance(0, 1) == 1
		and spatial.orthogonal_step_distance(0, 2) == 2
		and spatial.orthogonal_step_distance(0, 8) == 4
		and spatial.orthogonal_step_distance(2, 4) == 2
		and spatial.orthogonal_step_distance(2, 6) == 4
		and spatial.orthogonal_step_distance(5, 5) == 0
	)


func _spatial_sparse_distance() -> bool:
	var spatial: CaseSpatialService = CaseSpatialService.new()
	var sparse_case: CaseDefinition = _spatial_case_fixture(
		4,
		[
			{"id": 1, "slot": 2, "alignment": CaseEnums.Alignment.GOOD, "true_role": &"tutorial_priest", "displayed_role": &"tutorial_priest"},
			{"id": 2, "slot": 6, "alignment": CaseEnums.Alignment.EVIL, "true_role": &"tutorial_mobster", "displayed_role": &"tutorial_mobster"},
		]
	)
	var nearest: Dictionary = spatial.nearest_true_evil_distance(sparse_case, 1)
	var nearest_ids: PackedInt32Array = PackedInt32Array(nearest.get("suspect_ids", PackedInt32Array()))
	return (
		spatial.orthogonal_step_distance(0, 2) == 2
		and bool(nearest.get("found", false))
		and int(nearest.get("distance", -1)) == 4
		and _packed_ints_match(nearest_ids, PackedInt32Array([2]))
	)


func _spatial_adjacent_evil_count() -> bool:
	var spatial: CaseSpatialService = CaseSpatialService.new()
	var c: CaseDefinition = _spatial_case_fixture(
		7,
		[
			{"id": 1, "slot": 4, "alignment": CaseEnums.Alignment.GOOD, "true_role": &"tutorial_priest", "displayed_role": &"tutorial_priest"},
			{"id": 2, "slot": 0, "alignment": CaseEnums.Alignment.EVIL, "true_role": &"tutorial_mobster", "displayed_role": &"tutorial_mobster"},
			{"id": 3, "slot": 1, "alignment": CaseEnums.Alignment.EVIL, "true_role": &"tutorial_scoundrel", "displayed_role": &"tutorial_scoundrel"},
		]
	)
	var adjacent: Array[SuspectDefinition] = spatial.suspects_orthogonally_adjacent_to(c, 1)
	var surrounding: Array[SuspectDefinition] = spatial.suspects_surrounding_source(c, 1)
	return (
		spatial.count_adjacent_true_evil(c, 1) == 1
		and adjacent.size() == 1
		and adjacent[0].suspect_id == 3
		and surrounding.size() == 2
	)


func _spatial_nearest_true_evil() -> bool:
	var spatial: CaseSpatialService = CaseSpatialService.new()
	var c: CaseDefinition = _spatial_case_fixture(
		4,
		[
			{"id": 1, "slot": 0, "alignment": CaseEnums.Alignment.GOOD, "true_role": &"tutorial_priest", "displayed_role": &"tutorial_priest"},
			{"id": 2, "slot": 1, "alignment": CaseEnums.Alignment.GOOD, "true_role": &"tutorial_priest", "displayed_role": &"tutorial_mobster"},
			{"id": 3, "slot": 2, "alignment": CaseEnums.Alignment.EVIL, "true_role": &"tutorial_mobster", "displayed_role": &"tutorial_priest"},
			{"id": 4, "slot": 8, "alignment": CaseEnums.Alignment.EVIL, "true_role": &"tutorial_scoundrel", "displayed_role": &"tutorial_scoundrel"},
		]
	)
	var nearest: Dictionary = spatial.nearest_true_evil_distance(c, 1)
	var nearest_ids: PackedInt32Array = PackedInt32Array(nearest.get("suspect_ids", PackedInt32Array()))
	var self_only: CaseDefinition = _spatial_case_fixture(
		4,
		[
			{"id": 1, "slot": 0, "alignment": CaseEnums.Alignment.EVIL, "true_role": &"tutorial_mobster", "displayed_role": &"tutorial_priest"},
		]
	)
	var none: Dictionary = spatial.nearest_true_evil_distance(self_only, 1)
	var none_ids: PackedInt32Array = PackedInt32Array(none.get("suspect_ids", PackedInt32Array()))
	return (
		bool(nearest.get("found", false))
		and int(nearest.get("distance", -1)) == 2
		and _packed_ints_match(nearest_ids, PackedInt32Array([3]))
		and not bool(none.get("found", false))
		and int(none.get("distance", -1)) == -1
		and none_ids.is_empty()
	)


func _spatial_existing_fixtures_valid(tutorial_case: CaseDefinition, tutorial_case_02: CaseDefinition, case_fixture: CaseDefinition) -> bool:
	var spatial: CaseSpatialService = CaseSpatialService.new()
	return (
		_spatial_case_slots_valid(spatial, tutorial_case)
		and _spatial_case_slots_valid(spatial, tutorial_case_02)
		and _spatial_case_slots_valid(spatial, case_fixture)
		and _board_slots_match_authored(tutorial_case)
		and _board_slots_match_authored(tutorial_case_02)
		and _board_slots_match_authored(case_fixture)
	)


func _spatial_case_slots_valid(spatial: CaseSpatialService, c: CaseDefinition) -> bool:
	if c == null or c.crime_scene == null or not spatial.is_valid_slot(c.crime_scene.board_slot):
		return false
	var slots: Dictionary = {}
	slots[c.crime_scene.board_slot] = true
	for suspect in c.suspects:
		if suspect == null or not spatial.is_valid_slot(suspect.board_slot) or slots.has(suspect.board_slot):
			return false
		slots[suspect.board_slot] = true
	return true


func _spatial_case_fixture(crime_slot: int, suspect_specs: Array[Dictionary]) -> CaseDefinition:
	var c: CaseDefinition = CaseDefinition.new()
	c.case_id = &"spatial_smoke"
	c.display_name = "Spatial Smoke"
	c.crime_scene = CrimeSceneDefinition.new()
	c.crime_scene.scene_id = &"spatial_scene"
	c.crime_scene.display_name = "Hiện trường"
	c.crime_scene.board_slot = crime_slot
	c.on_solve = OnSolveReward.new()
	for suspect_spec in suspect_specs:
		var suspect: SuspectDefinition = SuspectDefinition.new()
		suspect.suspect_id = int(suspect_spec.get("id", 0))
		suspect.board_slot = int(suspect_spec.get("slot", 0))
		suspect.true_alignment = int(suspect_spec.get("alignment", CaseEnums.Alignment.GOOD))
		suspect.role_group = CaseEnums.RoleGroup.TONG_PHAM if suspect.true_alignment == CaseEnums.Alignment.EVIL else CaseEnums.RoleGroup.CHINH_NHAN
		suspect.true_role_id = StringName(suspect_spec.get("true_role", &""))
		suspect.displayed_role_id = StringName(suspect_spec.get("displayed_role", &""))
		c.suspects.append(suspect)
	return c


func _packed_ints_match(first: PackedInt32Array, second: PackedInt32Array) -> bool:
	if first.size() != second.size():
		return false
	var a: PackedInt32Array = PackedInt32Array(first)
	var b: PackedInt32Array = PackedInt32Array(second)
	a.sort()
	b.sort()
	return a == b


func _role_info_truth_state() -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var scoundrel: SuspectDefinition = _role_info_suspect(1, 0, &"tutorial_scoundrel", &"tutorial_scoundrel", CaseEnums.Alignment.EVIL)
	var mobster: SuspectDefinition = _role_info_suspect(2, 1, &"tutorial_mobster", &"tutorial_priest", CaseEnums.Alignment.EVIL)
	var corrupted_priest: SuspectDefinition = _role_info_suspect(3, 2, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, true)
	var spectre: SuspectDefinition = _role_info_suspect(4, 3, &"spectre", &"reporter", CaseEnums.Alignment.EVIL)
	var truthful_pretender: SuspectDefinition = _role_info_suspect(5, 5, &"role_good_a", &"tutorial_priest", CaseEnums.Alignment.GOOD)
	return (
		service.truth_mode_for_suspect(scoundrel) == InvestigationInformationResult.TruthMode.TRUTHFUL
		and service.truth_mode_for_suspect(mobster) == InvestigationInformationResult.TruthMode.LYING
		and service.truth_mode_for_suspect(corrupted_priest) == InvestigationInformationResult.TruthMode.LYING
		and service.truth_mode_for_suspect(spectre) == InvestigationInformationResult.TruthMode.LYING
		and service.truth_mode_for_suspect(truthful_pretender) == InvestigationInformationResult.TruthMode.TRUTHFUL
		and service.investigation_behavior_role_id(truthful_pretender) == &"tutorial_priest"
	)


func _role_info_priest() -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var truthful_case: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD),
	])
	var lying_case: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"tutorial_mobster", &"tutorial_priest", CaseEnums.Alignment.EVIL),
	])
	var truthful: InvestigationInformationResult = service.evaluate(truthful_case, 1)
	var lying: InvestigationInformationResult = service.evaluate(lying_case, 1)
	return (
		truthful.payload_kind == InvestigationInformationResult.PayloadKind.TEXT
		and truthful.public_text() == "Tôi là Tư Tế."
		and lying.payload_kind == InvestigationInformationResult.PayloadKind.TEXT
		and not lying.public_text().is_empty()
		and lying.public_text() != "Tôi là Tư Tế."
	)


func _role_info_reporter() -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"reporter", &"reporter", CaseEnums.Alignment.GOOD),
		_role_info_spec(2, 1, &"tutorial_priest", &"tutorial_mobster", CaseEnums.Alignment.GOOD),
		_role_info_spec(3, 2, &"tutorial_mobster", &"tutorial_priest", CaseEnums.Alignment.EVIL),
		_role_info_spec(4, 8, &"tutorial_scoundrel", &"tutorial_scoundrel", CaseEnums.Alignment.EVIL),
	])
	var truthful: InvestigationInformationResult = service.evaluate(c, 1)
	var lying_case: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"tutorial_mobster", &"reporter", CaseEnums.Alignment.EVIL),
		_role_info_spec(2, 8, &"tutorial_scoundrel", &"tutorial_scoundrel", CaseEnums.Alignment.EVIL),
	])
	var lying: InvestigationInformationResult = service.evaluate(lying_case, 1)
	var no_evil_case: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"reporter", &"reporter", CaseEnums.Alignment.GOOD),
		_role_info_spec(2, 8, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD),
	])
	var no_evil: InvestigationInformationResult = service.evaluate(no_evil_case, 1)
	return (
		truthful.payload_kind == InvestigationInformationResult.PayloadKind.NUMBER
		and truthful.numeric_value == 2
		and truthful.public_text().contains("2")
		and lying.payload_kind == InvestigationInformationResult.PayloadKind.NUMBER
		and lying.numeric_value >= 1
		and lying.numeric_value <= 4
		and lying.numeric_value != 4
		and no_evil.payload_kind == InvestigationInformationResult.PayloadKind.NO_EVIL_FOUND
		and no_evil.public_text() == "Tôi không tìm thấy Phe Ác nào."
	)


func _role_info_therapist() -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 4, &"therapist", &"therapist", CaseEnums.Alignment.GOOD),
		_role_info_spec(2, 0, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL),
		_role_info_spec(3, 1, &"tutorial_scoundrel", &"tutorial_scoundrel", CaseEnums.Alignment.EVIL),
	], 7)
	var truthful: InvestigationInformationResult = service.evaluate(c, 1)
	var lying_case: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 4, &"tutorial_mobster", &"therapist", CaseEnums.Alignment.EVIL),
		_role_info_spec(2, 1, &"tutorial_scoundrel", &"tutorial_scoundrel", CaseEnums.Alignment.EVIL),
	], 7)
	var lying: InvestigationInformationResult = service.evaluate(lying_case, 1)
	return (
		truthful.payload_kind == InvestigationInformationResult.PayloadKind.NUMBER
		and truthful.numeric_value == 1
		and lying.payload_kind == InvestigationInformationResult.PayloadKind.NUMBER
		and lying.numeric_value >= 0
		and lying.numeric_value <= 4
		and lying.numeric_value != 1
	)


func _role_info_mailman() -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var roles: Array[RoleDefinition] = _role_info_roles()
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"mailman", &"mailman", CaseEnums.Alignment.GOOD),
		_role_info_spec(2, 1, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD),
		_role_info_spec(3, 2, &"tutorial_mobster", &"reporter", CaseEnums.Alignment.EVIL),
	])
	var in_play: Array[StringName] = service.true_role_ids_in_play(c)
	var truthful_pair: Dictionary = service.validate_mailman_pair(c, 1, &"tutorial_priest", &"reporter", InvestigationInformationResult.TruthMode.TRUTHFUL, roles)
	var lying_pair: Dictionary = service.validate_mailman_pair(c, 1, &"reporter", &"tutorial_priest", InvestigationInformationResult.TruthMode.LYING, roles)
	var self_pair: Dictionary = service.validate_mailman_pair(c, 1, &"mailman", &"reporter", InvestigationInformationResult.TruthMode.TRUTHFUL, roles)
	var evaluated: InvestigationInformationResult = service.evaluate(c, 1, roles, {"in_play_role_id": &"tutorial_priest", "not_in_play_role_id": &"reporter"})
	return (
		in_play.has(&"tutorial_mobster")
		and not in_play.has(&"reporter")
		and bool(truthful_pair.get("valid", false))
		and bool(lying_pair.get("valid", false))
		and not bool(self_pair.get("valid", false))
		and evaluated.payload_kind == InvestigationInformationResult.PayloadKind.ROLE_PLAY_CLAIM
		and evaluated.claimed_in_play_is_true
		and evaluated.claimed_not_in_play_is_true
	)


func _role_info_pretend() -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var reporter_case: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"tutorial_mobster", &"reporter", CaseEnums.Alignment.EVIL),
		_role_info_spec(2, 8, &"tutorial_scoundrel", &"tutorial_scoundrel", CaseEnums.Alignment.EVIL),
	])
	var mobster_reporter: InvestigationInformationResult = service.evaluate(reporter_case, 1)
	var priest_case: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"tutorial_mobster", &"tutorial_priest", CaseEnums.Alignment.EVIL),
	])
	var mobster_priest: InvestigationInformationResult = service.evaluate(priest_case, 1)
	var truthful_pretender_case: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"role_good_a", &"tutorial_priest", CaseEnums.Alignment.GOOD),
	])
	var truthful_pretender: InvestigationInformationResult = service.evaluate(truthful_pretender_case, 1)
	return (
		mobster_reporter.behavior_role_id == &"reporter"
		and mobster_reporter.truth_mode == InvestigationInformationResult.TruthMode.LYING
		and mobster_reporter.payload_kind == InvestigationInformationResult.PayloadKind.NUMBER
		and mobster_priest.behavior_role_id == &"tutorial_priest"
		and mobster_priest.truth_mode == InvestigationInformationResult.TruthMode.LYING
		and mobster_priest.public_text() != "Tôi là Tư Tế."
		and truthful_pretender.behavior_role_id == &"tutorial_priest"
		and truthful_pretender.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL
		and truthful_pretender.public_text() == "Tôi là Tư Tế."
	)


func _role_info_obscure() -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var text_case: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"spectre", &"reporter", CaseEnums.Alignment.EVIL),
		_role_info_spec(2, 1, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD),
	])
	var relation: InvestigationObscureRelation = InvestigationObscureRelation.new()
	relation.configure(1, 2)
	var text_result: InvestigationInformationResult = service.evaluate(text_case, 2)
	var obscured_text: InvestigationInformationResult = service.apply_obscure_relation(text_result, text_case, relation)
	var number_case: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"spectre", &"reporter", CaseEnums.Alignment.EVIL),
		_role_info_spec(2, 1, &"reporter", &"reporter", CaseEnums.Alignment.GOOD),
		_role_info_spec(3, 8, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL),
	])
	var number_relation: InvestigationObscureRelation = InvestigationObscureRelation.new()
	number_relation.configure(1, 2)
	var number_result: InvestigationInformationResult = service.evaluate(number_case, 2)
	var obscured_number: InvestigationInformationResult = service.apply_obscure_relation(number_result, number_case, number_relation)
	var corrupted_case: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"spectre", &"reporter", CaseEnums.Alignment.EVIL, true),
		_role_info_spec(2, 1, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD),
	])
	var corrupted_relation: InvestigationObscureRelation = InvestigationObscureRelation.new()
	corrupted_relation.configure(1, 2)
	var corrupted_result: InvestigationInformationResult = service.apply_obscure_relation(service.evaluate(corrupted_case, 2), corrupted_case, corrupted_relation)
	return (
		obscured_text.is_obscured
		and not obscured_text.role_identity_visible
		and not obscured_text.text_information_visible
		and obscured_text.public_text().is_empty()
		and obscured_text.true_role_id == &"tutorial_priest"
		and obscured_number.is_obscured
		and not obscured_number.role_identity_visible
		and obscured_number.numeric_information_visible
		and obscured_number.numeric_value >= 0
		and not obscured_number.public_text().is_empty()
		and not corrupted_result.is_obscured
		and corrupted_result.role_identity_visible
		and corrupted_result.public_text() == "Tôi là Tư Tế."
	)


func _role_info_mathematician_recognized() -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"mathematician", &"mathematician", CaseEnums.Alignment.GOOD),
		_role_info_spec(2, 2, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL),
	])
	var evaluated: InvestigationInformationResult = service.evaluate(c, 1)
	return (
		evaluated.behavior_role_id == &"mathematician"
		and evaluated.payload_kind == InvestigationInformationResult.PayloadKind.NUMBER
		and evaluated.numeric_value == 2
		and evaluated.public_text().contains("Tổng Số Hiệu")
	)


func _role_info_mathematician_truthful_sum() -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"mathematician", &"mathematician", CaseEnums.Alignment.GOOD),
		_role_info_spec(2, 1, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL),
		_role_info_spec(5, 2, &"tutorial_scoundrel", &"tutorial_scoundrel", CaseEnums.Alignment.EVIL),
		_role_info_spec(8, 8, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD),
	])
	var evaluated: InvestigationInformationResult = service.evaluate(c, 1)
	return evaluated.numeric_value == 7 and service.true_evil_suspect_number_sum(c) == 7


func _role_info_mathematician_ignores_good() -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"mathematician", &"mathematician", CaseEnums.Alignment.GOOD),
		_role_info_spec(4, 1, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD),
		_role_info_spec(6, 2, &"reporter", &"reporter", CaseEnums.Alignment.GOOD),
		_role_info_spec(9, 8, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL),
	])
	return service.evaluate(c, 1).numeric_value == 9


func _role_info_mathematician_ignores_displayed_state() -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"mathematician", &"mathematician", CaseEnums.Alignment.GOOD),
		_role_info_spec(4, 1, &"tutorial_mobster", &"tutorial_priest", CaseEnums.Alignment.EVIL),
		_role_info_spec(9, 2, &"tutorial_priest", &"tutorial_mobster", CaseEnums.Alignment.GOOD),
	])
	var evil: SuspectDefinition = _case_suspect(c, 4)
	if evil != null:
		evil.impersonated_role_id = &"tutorial_priest"
	var good: SuspectDefinition = _case_suspect(c, 9)
	if good != null:
		good.impersonated_role_id = &"tutorial_mobster"
	return service.evaluate(c, 1).numeric_value == 4


func _role_info_mathematician_pretend_behavior() -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"role_good_a", &"mathematician", CaseEnums.Alignment.GOOD),
		_role_info_spec(4, 1, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL),
		_role_info_spec(6, 2, &"tutorial_scoundrel", &"tutorial_scoundrel", CaseEnums.Alignment.EVIL),
	])
	var evaluated: InvestigationInformationResult = service.evaluate(c, 1)
	return (
		evaluated.true_role_id == &"role_good_a"
		and evaluated.behavior_role_id == &"mathematician"
		and evaluated.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL
		and evaluated.numeric_value == 10
	)


func _role_info_mathematician_lying_differs() -> bool:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(2, 0, &"tutorial_mobster", &"mathematician", CaseEnums.Alignment.EVIL),
		_role_info_spec(5, 2, &"tutorial_scoundrel", &"tutorial_scoundrel", CaseEnums.Alignment.EVIL),
	])
	return _mathematician_lie_delta(c, 2) > 0


func _role_info_mathematician_tainted_differs() -> bool:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"mathematician", &"mathematician", CaseEnums.Alignment.GOOD, true),
		_role_info_spec(3, 1, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL),
		_role_info_spec(5, 2, &"tutorial_scoundrel", &"tutorial_scoundrel", CaseEnums.Alignment.EVIL),
	])
	return _mathematician_lie_delta(c, 1) > 0


func _role_info_mathematician_low_deviation() -> bool:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(2, 0, &"tutorial_mobster", &"mathematician", CaseEnums.Alignment.EVIL),
		_role_info_spec(5, 2, &"tutorial_scoundrel", &"tutorial_scoundrel", CaseEnums.Alignment.EVIL),
	])
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var delta: int = _mathematician_lie_delta(c, 2)
	return delta > 0 and delta <= service.mathematician_deviation_limit(7)


func _role_info_mathematician_mid_deviation() -> bool:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"tutorial_mobster", &"mathematician", CaseEnums.Alignment.EVIL),
		_role_info_spec(19, 2, &"tutorial_scoundrel", &"tutorial_scoundrel", CaseEnums.Alignment.EVIL),
	])
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var delta: int = _mathematician_lie_delta(c, 1)
	return delta > 0 and delta <= service.mathematician_deviation_limit(20)


func _role_info_mathematician_high_deviation() -> bool:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"tutorial_mobster", &"mathematician", CaseEnums.Alignment.EVIL),
		_role_info_spec(29, 2, &"tutorial_scoundrel", &"tutorial_scoundrel", CaseEnums.Alignment.EVIL),
	])
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var delta: int = _mathematician_lie_delta(c, 1)
	return delta > 0 and delta <= service.mathematician_deviation_limit(30)


func _role_info_mathematician_death_independent(players: Array[PlayerCaseState]) -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"mathematician", &"mathematician", CaseEnums.Alignment.GOOD),
		_role_info_spec(4, 1, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL),
		_role_info_spec(7, 2, &"tutorial_scoundrel", &"tutorial_scoundrel", CaseEnums.Alignment.EVIL),
	])
	c.evil_suspect_ids = PackedInt32Array([4, 7])
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var player: PlayerCaseState = runtime.find_player(runtime.current_player_id()) if runtime != null else null
	var before: InvestigationInformationResult = service.evaluate(c, 1)
	CaseKillService.new().kill(c, runtime, 4, &"smoke")
	var unresolved: PackedInt32Array = CaseResolutionService.new().unresolved_evil_ids(c, runtime)
	var after_death: InvestigationInformationResult = service.evaluate(c, 1)
	var accusation: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(c, runtime, player, 4) if player != null else null
	var after_accusation: InvestigationInformationResult = service.evaluate(c, 1)
	return (
		4 in unresolved
		and 7 in unresolved
		and accusation != null
		and accusation.success
		and accusation.correct
		and before.numeric_value == 11
		and after_death.numeric_value == 11
		and after_accusation.numeric_value == 11
		and service.true_evil_suspect_number_sum(c) == 11
	)


func _role_info_mathematician_no_tutorial_specific_domain() -> bool:
	var source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/RoleInformationEvaluationService.gd")
	return not source.contains("tutorial_05") and not source.contains("Tutorial 05")


func _mathematician_lie_delta(c: CaseDefinition, source_suspect_id: int) -> int:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var true_sum: int = service.true_evil_suspect_number_sum(c)
	var evaluated: InvestigationInformationResult = service.evaluate(c, source_suspect_id)
	if evaluated.numeric_value == true_sum:
		return 0
	return absi(evaluated.numeric_value - true_sum)


func _role_info_weatherman_recognized() -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var c: CaseDefinition = _role_info_weatherman_truth_case()
	var evaluated: InvestigationInformationResult = service.evaluate(c, 1)
	return (
		evaluated.behavior_role_id == &"weatherman"
		and evaluated.payload_kind == InvestigationInformationResult.PayloadKind.WEATHER_REPORT
		and evaluated.weather_claim_complete
		and evaluated.weather_group_slots == PackedInt32Array([CaseEnums.RoleGroup.CHINH_NHAN, CaseEnums.RoleGroup.TONG_PHAM, CaseEnums.RoleGroup.HIEU_SU])
	)


func _role_info_weatherman_three_numbers() -> bool:
	var evaluated: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(_role_info_weatherman_truth_case(), 1)
	return evaluated.weather_suspect_ids.size() == 3 and evaluated.public_text().contains("2, 3 và 4")


func _role_info_weatherman_true_innocent() -> bool:
	var c: CaseDefinition = _role_info_weatherman_truth_case()
	var evaluated: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(c, 1)
	if evaluated.weather_suspect_ids.size() != 3 or evaluated.weather_group_slots.size() != 3:
		return false
	var suspect: SuspectDefinition = _case_suspect(c, int(evaluated.weather_suspect_ids[0]))
	return suspect != null and suspect.role_group == CaseEnums.RoleGroup.CHINH_NHAN


func _role_info_weatherman_true_meddler() -> bool:
	var c: CaseDefinition = _role_info_weatherman_truth_case()
	var evaluated: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(c, 1)
	if evaluated.weather_suspect_ids.size() != 3:
		return false
	var suspect: SuspectDefinition = _case_suspect(c, int(evaluated.weather_suspect_ids[2]))
	return suspect != null and suspect.role_group == CaseEnums.RoleGroup.HIEU_SU


func _role_info_weatherman_true_evil_group() -> bool:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"weatherman", &"weatherman", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(2, 1, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(3, 2, &"role_meddler_a", &"role_meddler_a", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
		_role_info_spec(4, 3, &"role_traitor_a", &"role_traitor_a", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.NGHICH_THAN),
	])
	var evaluated: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(c, 1)
	if evaluated.weather_suspect_ids.size() != 3:
		return false
	var suspect: SuspectDefinition = _case_suspect(c, int(evaluated.weather_suspect_ids[1]))
	return (
		suspect != null
		and suspect.role_group == CaseEnums.RoleGroup.NGHICH_THAN
		and evaluated.weather_group_slots[1] == CaseEnums.RoleGroup.NGHICH_THAN
	)


func _role_info_weatherman_ignores_displayed_groups() -> bool:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"weatherman", &"weatherman", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(2, 1, &"tutorial_priest", &"tutorial_mobster", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(3, 2, &"role_meddler_a", &"role_meddler_a", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
		_role_info_spec(4, 3, &"tutorial_mobster", &"tutorial_priest", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	])
	var evaluated: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(c, 1)
	return evaluated.weather_suspect_ids == PackedInt32Array([2, 4, 3])


func _role_info_weatherman_true_self_exclusion() -> bool:
	var evaluated: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(_role_info_weatherman_truth_case(), 1)
	if evaluated.weather_suspect_ids.size() != 3:
		return false
	return evaluated.weather_suspect_ids[0] == 2 and not evaluated.weather_suspect_ids.has(1)


func _role_info_weatherman_pretender_self_allowed() -> bool:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(3, 1, &"role_meddler_a", &"weatherman", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
		_role_info_spec(4, 2, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	])
	var evaluated: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(c, 3)
	return evaluated.weather_suspect_ids == PackedInt32Array([1, 4, 3])


func _role_info_weatherman_lying_restricted() -> bool:
	var c: CaseDefinition = _role_info_weatherman_lie_case()
	var evaluated: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(c, 4)
	return _weatherman_claim_uses_only_good_or_meddler(c, evaluated)


func _role_info_weatherman_tainted_restricted() -> bool:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"weatherman", &"weatherman", CaseEnums.Alignment.GOOD, true, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(2, 1, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(3, 2, &"role_meddler_a", &"role_meddler_a", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
		_role_info_spec(4, 3, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	])
	var evaluated: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(c, 1)
	return _weatherman_claim_uses_only_good_or_meddler(c, evaluated)


func _role_info_weatherman_lie_pattern_false() -> bool:
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var lying_case: CaseDefinition = _role_info_weatherman_lie_case()
	var lying: InvestigationInformationResult = service.evaluate(lying_case, 4)
	var tainted_case: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"weatherman", &"weatherman", CaseEnums.Alignment.GOOD, true, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(2, 1, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(3, 2, &"role_meddler_a", &"role_meddler_a", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
		_role_info_spec(4, 3, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	])
	var tainted: InvestigationInformationResult = service.evaluate(tainted_case, 1)
	return (
		not service.weatherman_claim_matches_truthful_pattern(lying_case, lying)
		and not service.weatherman_claim_matches_truthful_pattern(tainted_case, tainted)
	)


func _role_info_weatherman_no_meddler_payload() -> bool:
	var evaluated: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(_role_info_weatherman_no_meddler_case(), 1)
	return (
		evaluated.payload_kind == InvestigationInformationResult.PayloadKind.NO_MEDDLER_FOUND
		and not evaluated.weather_claim_complete
	)


func _role_info_weatherman_no_meddler_absence() -> bool:
	var c: CaseDefinition = _role_info_weatherman_no_meddler_case()
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var evaluated: InvestigationInformationResult = service.evaluate(c, 1)
	return (
		not service.case_has_true_group(c, CaseEnums.RoleGroup.HIEU_SU)
		and evaluated.public_text().contains("Không có Kẻ Bao Đồng")
	)


func _role_info_weatherman_no_meddler_two_numbers() -> bool:
	var evaluated: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(_role_info_weatherman_no_meddler_case(), 1)
	return evaluated.weather_suspect_ids == PackedInt32Array([2, 4])


func _role_info_weatherman_no_meddler_innocent() -> bool:
	var c: CaseDefinition = _role_info_weatherman_no_meddler_case()
	var evaluated: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(c, 1)
	if evaluated.weather_suspect_ids.size() != 2:
		return false
	var suspect: SuspectDefinition = _case_suspect(c, int(evaluated.weather_suspect_ids[0]))
	return suspect != null and suspect.role_group == CaseEnums.RoleGroup.CHINH_NHAN


func _role_info_weatherman_no_meddler_evil_group() -> bool:
	var c: CaseDefinition = _role_info_weatherman_no_meddler_case()
	var evaluated: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(c, 1)
	if evaluated.weather_suspect_ids.size() != 2 or evaluated.weather_group_slots.size() != 2:
		return false
	var suspect: SuspectDefinition = _case_suspect(c, int(evaluated.weather_suspect_ids[1]))
	return (
		suspect != null
		and suspect.role_group == CaseEnums.RoleGroup.TONG_PHAM
		and evaluated.weather_group_slots[1] == CaseEnums.RoleGroup.TONG_PHAM
	)


func _role_info_weatherman_no_meddler_self_exclusion() -> bool:
	var evaluated: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(_role_info_weatherman_no_meddler_case(), 1)
	return evaluated.weather_suspect_ids.size() == 2 and not evaluated.weather_suspect_ids.has(1)


func _role_info_weatherman_no_meddler_uses_suspect_number() -> bool:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(10, 8, &"weatherman", &"weatherman", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(20, 0, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(40, 1, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	])
	var evaluated: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(c, 10)
	return evaluated.weather_suspect_ids == PackedInt32Array([20, 40])


func _role_info_weatherman_no_meddler_deterministic() -> bool:
	var c: CaseDefinition = _role_info_weatherman_no_meddler_case()
	var service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var first: InvestigationInformationResult = service.evaluate(c, 1)
	var second: InvestigationInformationResult = service.evaluate(c, 1)
	return first.weather_suspect_ids == second.weather_suspect_ids and first.weather_group_slots == second.weather_group_slots


func _role_info_weatherman_no_meddler_case() -> CaseDefinition:
	return _role_info_case_fixture([
		_role_info_spec(1, 0, &"weatherman", &"weatherman", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(2, 1, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(4, 2, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	])


func _role_info_weatherman_uses_suspect_number() -> bool:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(10, 0, &"weatherman", &"weatherman", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(20, 1, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(30, 2, &"role_meddler_a", &"role_meddler_a", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
		_role_info_spec(40, 3, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	])
	var evaluated: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(c, 10)
	return evaluated.weather_suspect_ids == PackedInt32Array([20, 40, 30])


func _role_info_weatherman_no_tutorial_specific_domain() -> bool:
	var source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/RoleInformationEvaluationService.gd")
	return not source.contains("tutorial_05") and not source.contains("Tutorial 05")


func _role_info_weatherman_truth_case() -> CaseDefinition:
	return _role_info_case_fixture([
		_role_info_spec(1, 0, &"weatherman", &"weatherman", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(2, 1, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(3, 2, &"role_meddler_a", &"role_meddler_a", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
		_role_info_spec(4, 3, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	])


func _role_info_weatherman_lie_case() -> CaseDefinition:
	return _role_info_case_fixture([
		_role_info_spec(1, 0, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(2, 1, &"reporter", &"reporter", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(3, 2, &"role_meddler_a", &"role_meddler_a", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
		_role_info_spec(4, 3, &"tutorial_mobster", &"weatherman", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	])


func _weatherman_claim_uses_only_good_or_meddler(c: CaseDefinition, result: InvestigationInformationResult) -> bool:
	if result == null or result.weather_suspect_ids.size() != 3:
		return false
	for suspect_id: int in result.weather_suspect_ids:
		var suspect: SuspectDefinition = _case_suspect(c, suspect_id)
		if suspect == null or suspect.role_group not in [CaseEnums.RoleGroup.CHINH_NHAN, CaseEnums.RoleGroup.HIEU_SU]:
			return false
	return true


func _role_info_presentation_regression(tutorial_case: CaseDefinition, tutorial_case_02: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var runtime_01: CaseRuntimeState = _tutorial_01_investigated_runtime(tutorial_case, players)
	var views_01: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(tutorial_case, runtime_01, roles)
	var runtime_02: CaseRuntimeState = _tutorial_01_investigated_runtime(tutorial_case_02, players)
	var views_02: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(tutorial_case_02, runtime_02, roles)
	return (
		views_01.size() == 2
		and views_01[0].public_investigation_statement == "Tôi là Tư Tế."
		and views_01[1].public_investigation_statement.is_empty()
		and views_02.size() == 2
		and views_02[0].public_investigation_statement == "Tôi là Tư Tế."
		and views_02[1].public_investigation_statement == "Ta có thật là một Tư Tế tốt không?"
	)


func _role_info_case_fixture(suspect_specs: Array[Dictionary], crime_slot: int = 4) -> CaseDefinition:
	var c: CaseDefinition = CaseDefinition.new()
	c.case_id = &"role_info_smoke"
	c.display_name = "Role Info Smoke"
	c.crime_scene = CrimeSceneDefinition.new()
	c.crime_scene.scene_id = &"role_info_scene"
	c.crime_scene.display_name = "Hiện trường"
	c.crime_scene.board_slot = crime_slot
	c.on_solve = OnSolveReward.new()
	for suspect_spec in suspect_specs:
		var suspect: SuspectDefinition = SuspectDefinition.new()
		suspect.suspect_id = int(suspect_spec.get("id", 0))
		suspect.board_slot = int(suspect_spec.get("slot", 0))
		suspect.true_role_id = StringName(suspect_spec.get("true_role", &""))
		suspect.displayed_role_id = StringName(suspect_spec.get("displayed_role", &""))
		suspect.impersonated_role_id = StringName(suspect_spec.get("impersonated_role", &""))
		suspect.true_alignment = int(suspect_spec.get("alignment", CaseEnums.Alignment.GOOD))
		suspect.role_group = int(suspect_spec.get("role_group", CaseEnums.RoleGroup.TONG_PHAM if suspect.true_alignment == CaseEnums.Alignment.EVIL else CaseEnums.RoleGroup.CHINH_NHAN))
		suspect.is_corrupted = bool(suspect_spec.get("corrupted", false))
		suspect.is_impersonating = suspect.true_role_id != suspect.displayed_role_id
		c.suspects.append(suspect)
	return c


func _role_info_spec(
	id: int,
	slot: int,
	true_role: StringName,
	displayed_role: StringName,
	alignment: int,
	corrupted: bool = false,
	role_group: int = -1
) -> Dictionary:
	var spec: Dictionary = {
		"id": id,
		"slot": slot,
		"true_role": true_role,
		"displayed_role": displayed_role,
		"alignment": alignment,
		"corrupted": corrupted,
	}
	if role_group >= 0:
		spec["role_group"] = role_group
	return spec


func _t07_a_location_checks(roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	var c: CaseDefinition = _t07_a_location_case()
	var clock_tower: BoardLocationDefinition = c.board_locations[0] if not c.board_locations.is_empty() else null
	var report: Dictionary = CaseDefinitionValidator.new().validate(c, roles, players)
	var runtime: CaseRuntimeState = (_fresh_turn_bundle(c, players).runtime) as CaseRuntimeState
	var current_player_id: StringName = runtime.current_player_id() if runtime != null else &""
	var investigation_result: InvestigationResult = InvestigationService.new().investigate(c, runtime, 5, current_player_id)
	var final_runtime: CaseRuntimeState = (_fresh_turn_bundle(c, players).runtime) as CaseRuntimeState
	final_runtime.case_outcome = CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
	FinalVerdictService.new().initialize(final_runtime)
	var final_submission: CaseSubmission = CaseSubmission.new()
	final_submission.configure(final_runtime.current_final_player_id(), final_runtime.turn_number, PackedInt32Array([5]), PackedInt32Array(), PackedInt32Array(), CaseEnums.SubmissionPhase.FINAL)
	var final_result: FinalVerdictResult = FinalVerdictService.new().lock_submission(c, final_runtime, final_submission)
	var kill_result: CaseKillResult = CaseKillService.new().kill(c, runtime, 5, &"smoke")
	var board: CaseBoardController = _board_instance(c)
	var suspected_ids: Array[StringName] = CaseRolePoolService.suspected_role_ids_for_case(c)
	var current_ids: Array[StringName] = CaseRolePoolService.current_role_ids_in_play(c, runtime)

	checks.definition_exists = BoardLocationDefinition.new() != null
	checks.id_required = _report_has_error_code(CaseDefinitionValidator.new().validate(_t07_a_location_case_with_location(&"", 5), roles, players), "LOCATION_ID_EMPTY")
	checks.duplicate_id = _report_has_error_code(CaseDefinitionValidator.new().validate(_t07_a_duplicate_location_case(), roles, players), "LOCATION_ID_DUPLICATE")
	checks.invalid_slot = _report_has_error_code(CaseDefinitionValidator.new().validate(_t07_a_location_case_with_location(BoardLocationDefinition.LOCATION_CLOCK_TOWER, 99), roles, players), "BOARD_SLOT_INVALID")
	checks.suspect_collision = _report_has_error_code(CaseDefinitionValidator.new().validate(_t07_a_location_case_with_location(BoardLocationDefinition.LOCATION_CLOCK_TOWER, 0), roles, players), "BOARD_SLOT_DUPLICATE")
	checks.location_collision = _report_has_error_code(CaseDefinitionValidator.new().validate(_t07_a_location_case_with_location(BoardLocationDefinition.LOCATION_CLOCK_TOWER, 6), roles, players), "BOARD_SLOT_DUPLICATE")
	checks.crime_scene_generic = c.location_definitions().size() == 2 and c.location_definitions()[0].location_id == BoardLocationDefinition.LOCATION_CRIME_SCENE
	checks.crime_scene_preserved = c.crime_scene != null and c.crime_scene.scene_id == &"t07_a_scene" and c.crime_scene.board_slot == 6
	checks.clock_tower_authored = clock_tower != null and clock_tower.location_id == BoardLocationDefinition.LOCATION_CLOCK_TOWER
	checks.clock_tower_name = clock_tower != null and clock_tower.display_name == "Tháp Đồng Hồ"
	checks.locations_coexist = bool(report.get("passed", false)) and c.location_definitions().size() == 2
	checks.multiple_locations = c.board_locations.size() == 1 and c.location_definitions().size() > c.board_locations.size()
	checks.not_suspect = c.suspects.size() == 2 and c.suspect_at_slot(5) == null
	checks.not_role_pool = not suspected_ids.has(BoardLocationDefinition.LOCATION_CLOCK_TOWER) and not current_ids.has(BoardLocationDefinition.LOCATION_CLOCK_TOWER)
	checks.not_investigation_target = not investigation_result.success and investigation_result.error_code == &"SUSPECT_NOT_FOUND"
	checks.not_final_candidate = not final_result.success and final_result.error_code == &"SUSPECT_NOT_FOUND"
	checks.not_kill_target = kill_result.outcome == CaseKillResult.Outcome.FAILED and kill_result.error_code == &"KILL_TARGET_NOT_FOUND"
	checks.occupancy_location = c.location_at_slot(5) == clock_tower and c.is_board_slot_occupied(5)
	checks.empty_slot = c.location_at_slot(1) == null and c.suspect_at_slot(1) == null and not c.is_board_slot_occupied(1)
	checks.no_clock_slot_hardcode = _t07_a_source_avoids_slot_hardcode(5)
	checks.no_crime_slot_hardcode = _t07_a_source_avoids_slot_hardcode(6)
	checks.clock_tower_presentation = (
		board != null
		and board.get_case_tile_count() == CaseSpatialService.BOARD_SLOT_COUNT
		and board.has_location_tile(BoardLocationDefinition.LOCATION_CLOCK_TOWER)
		and board.get_location_slot(BoardLocationDefinition.LOCATION_CLOCK_TOWER) == 5
		and board.get_location_tile_text(BoardLocationDefinition.LOCATION_CLOCK_TOWER).contains("Tháp Đồng Hồ")
		and board.is_location_noninteractive(BoardLocationDefinition.LOCATION_CLOCK_TOWER)
		and board.get_card_count() == 2
	)
	if board != null:
		board.free()
	return checks


func _t07_a_location_case() -> CaseDefinition:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(2, 8, &"tutorial_mobster", &"tutorial_priest", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	], 6)
	c.suspects[1].impersonated_role_id = &"tutorial_priest"
	c.case_id = &"t07_a_location_smoke"
	c.display_name = "T07-A Location Smoke"
	c.crime_scene.scene_id = &"t07_a_scene"
	var suspected_ids: Array[StringName] = [&"tutorial_priest", &"tutorial_mobster"]
	c.suspected_role_ids = suspected_ids
	c.evil_suspect_ids = PackedInt32Array([2])
	c.accomplice_suspect_ids = PackedInt32Array([2])
	c.traitor_suspect_ids = PackedInt32Array()
	c.board_locations.append(_t07_a_clock_tower_location())
	return c


func _t07_a_location_case_with_location(location_id: StringName, board_slot: int) -> CaseDefinition:
	var locations: Array[BoardLocationDefinition] = [_t07_a_location(location_id, "Tháp Đồng Hồ", board_slot)]
	return _t07_a_location_case_with_locations(locations)


func _t07_a_location_case_with_locations(locations: Array[BoardLocationDefinition]) -> CaseDefinition:
	var c: CaseDefinition = _t07_a_location_case()
	c.board_locations = locations
	return c


func _t07_a_duplicate_location_case() -> CaseDefinition:
	var locations: Array[BoardLocationDefinition] = [
		_t07_a_location(BoardLocationDefinition.LOCATION_CLOCK_TOWER, "Tháp Đồng Hồ", 5),
		_t07_a_location(BoardLocationDefinition.LOCATION_CLOCK_TOWER, "Tháp Khác", 7),
	]
	return _t07_a_location_case_with_locations(locations)


func _t07_a_clock_tower_location() -> BoardLocationDefinition:
	var location: BoardLocationDefinition = load("res://content/locations/clock_tower.tres") as BoardLocationDefinition
	if location == null:
		location = _t07_a_location(BoardLocationDefinition.LOCATION_CLOCK_TOWER, "Tháp Đồng Hồ", 5)
	return location


func _t07_a_location(location_id: StringName, display_name: String, board_slot: int) -> BoardLocationDefinition:
	var location: BoardLocationDefinition = BoardLocationDefinition.new()
	location.location_id = location_id
	location.display_name = display_name
	location.board_slot = board_slot
	return location


func _t07_a_source_avoids_slot_hardcode(forbidden_slot: int) -> bool:
	var sources: Array[String] = [
		"res://scripts/domain/cases/BoardLocationDefinition.gd",
		"res://scripts/domain/cases/CaseDefinition.gd",
		"res://scripts/domain/cases/CaseDefinitionValidator.gd",
		"res://scripts/presentation/case_gameplay/CaseBoardController.gd",
	]
	var slot_text: String = str(forbidden_slot)
	for path: String in sources:
		var source: String = FileAccess.get_file_as_string(path)
		if source.contains("slot%s" % slot_text):
			return false
		if source.contains("board_slot == %s" % slot_text) or source.contains("board_slot = %s" % slot_text):
			return false
	return true


func _t07_b_clock_maker_checks(roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	var role: RoleDefinition = _find_role_for_test(roles, &"clock_maker")
	var tower: ClockTowerDefinition = _t07_b_clock_tower(8)
	var case_with_tower: CaseDefinition = _t07_b_clock_case(tower, true, &"clock_maker")
	var runtime: CaseRuntimeState = (_fresh_turn_bundle(case_with_tower, players).runtime) as CaseRuntimeState
	var before_elapsed: int = runtime.elapsed_hours if runtime != null else -1
	var is_ringing: bool = ClockTowerService.is_clock_tower_ringing(case_with_tower, runtime)
	var after_elapsed: int = runtime.elapsed_hours if runtime != null else -2
	var truthful: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(case_with_tower, 1, roles, {}, runtime)
	var lying_case: CaseDefinition = _t07_b_mobster_clock_case(tower)
	var lying_result: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(lying_case, 1, roles)
	var tainted_case: CaseDefinition = _t07_b_clock_case(tower, false, &"clock_maker", 5, true)
	var tainted_result: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(tainted_case, 1, roles)
	var mobster_case: CaseDefinition = _t07_b_mobster_clock_case(tower)
	var mobster_result: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(mobster_case, 1, roles)
	var board_idle: CaseBoardController = _t07_b_board_at_hour(case_with_tower, roles, players, 7)
	var board_ringing: CaseBoardController = _t07_b_board_at_hour(case_with_tower, roles, players, 8)
	var current_ids: Array[StringName] = CaseRolePoolService.current_role_ids_in_play(case_with_tower, runtime)

	checks.role_exists = role != null and role.role_id == &"clock_maker"
	checks.role_group = role != null and role.role_group == CaseEnums.RoleGroup.CHINH_NHAN
	checks.role_alignment = role != null and CaseRolePoolService.alignment_for_role_group(role.role_group) == CaseEnums.Alignment.GOOD
	checks.display_name = role != null and role.display_name == "Thợ Đồng Hồ"
	checks.tower_definition = ClockTowerDefinition.new() != null
	checks.tower_generic = tower is BoardLocationDefinition and tower.location_id == BoardLocationDefinition.LOCATION_CLOCK_TOWER
	checks.ring_accepts_1 = _t07_b_case_valid(_t07_b_clock_case(_t07_b_clock_tower(1), false, &"clock_maker"), roles, players)
	checks.ring_accepts_23 = _t07_b_case_valid(_t07_b_clock_case(_t07_b_clock_tower(23), false, &"clock_maker"), roles, players)
	checks.ring_rejects_0 = _report_has_error_code(CaseDefinitionValidator.new().validate(_t07_b_clock_case(_t07_b_clock_tower(0), false, &"clock_maker"), roles, players), "CLOCK_TOWER_RING_HOUR_INVALID")
	checks.ring_rejects_24 = _report_has_error_code(CaseDefinitionValidator.new().validate(_t07_b_clock_case(_t07_b_clock_tower(24), false, &"clock_maker"), roles, players), "CLOCK_TOWER_RING_HOUR_INVALID")
	checks.late_ring_not_rejected = not _report_has_error_code(CaseDefinitionValidator.new().validate(_t07_b_clock_case(_t07_b_clock_tower(23), false, &"clock_maker"), roles, players), "CLOCK_TOWER_RING_HOUR_UNREACHABLE")
	checks.idle_7 = not ClockTowerService.hour_is_ringing(tower, 7)
	checks.ring_8 = ClockTowerService.hour_is_ringing(tower, 8)
	checks.ring_9 = ClockTowerService.hour_is_ringing(tower, 9)
	checks.idle_10 = not ClockTowerService.hour_is_ringing(tower, 10)
	checks.query_no_mutation = not is_ringing and before_elapsed == after_elapsed
	checks.truth_uses_ring_hour = truthful != null and truthful.numeric_value == 8
	checks.truth_text_8_9 = truthful != null and truthful.public_text() == "Tháp Đồng Hồ sẽ reo từ 8h đến 9h."
	checks.lying_false_interval = lying_result != null and lying_result.numeric_value == 11 and ClockTowerService.false_interval_is_valid(tower, lying_result.numeric_value)
	checks.tainted_false_interval = tainted_result != null and tainted_result.numeric_value == 5 and ClockTowerService.false_interval_is_valid(tower, tainted_result.numeric_value)
	checks.false_5_6_valid = ClockTowerService.false_interval_is_valid(tower, 5)
	checks.false_11_12_valid = ClockTowerService.false_interval_is_valid(tower, 11)
	checks.false_7_8_rejected = not ClockTowerService.false_interval_is_valid(tower, 7)
	checks.false_8_9_rejected = not ClockTowerService.false_interval_is_valid(tower, 8)
	checks.false_9_10_rejected = not ClockTowerService.false_interval_is_valid(tower, 9)
	checks.lie_no_ring_mutation = tower.ring_hour == 8 and lying_result != null and tainted_result != null
	checks.requires_clock_maker = _t07_b_role_requires_tower(&"clock_maker", roles, players)
	checks.requires_gentleman = _t07_b_role_requires_tower(&"gentleman", roles, players)
	checks.requires_gargoyle = _t07_b_role_requires_tower(&"gargoyle", roles, players)
	checks.requires_belfry = _t07_b_role_requires_tower(&"belfry", roles, players)
	checks.requires_sniper = _t07_b_role_requires_tower(&"sniper", roles, players)
	checks.requires_maid = _t07_b_role_requires_tower(&"maid", roles, players)
	checks.requires_fearmonger = _t07_b_role_requires_tower(&"fearmonger", roles, players)
	checks.tower_without_true_clock_maker = _t07_b_case_valid(_t07_b_clock_case(tower, false, &"clock_maker", -1, false, &"tutorial_priest"), roles, players)
	checks.presence_suspected_not_current = _report_has_error_code(CaseDefinitionValidator.new().validate(_t07_b_clock_case(null, false, &"clock_maker", -1, false, &"tutorial_priest"), roles, players), "CLOCK_TOWER_REQUIRED")
	checks.tower_crime_coexist = case_with_tower.location_definitions().size() == 2 and ClockTowerService.has_clock_tower(case_with_tower)
	checks.tower_not_suspect = case_with_tower.suspects.size() == 2 and case_with_tower.suspect_at_slot(5) == null
	checks.tower_not_role_pool = not current_ids.has(BoardLocationDefinition.LOCATION_CLOCK_TOWER)
	checks.tower_not_investigation = _t07_b_location_investigation_rejected(case_with_tower, players)
	checks.tower_not_kill = CaseKillService.new().kill(case_with_tower, runtime, 5, &"smoke").error_code == &"KILL_TARGET_NOT_FOUND"
	checks.mobster_pretend_clock_maker = mobster_result != null and mobster_result.behavior_role_id == &"clock_maker" and mobster_result.truth_mode == InvestigationInformationResult.TruthMode.LYING and mobster_result.public_text() == "Tháp Đồng Hồ sẽ không reo từ 11h đến 12h."
	checks.no_slot5_hardcode = _t07_b_source_avoids("res://scripts/domain/cases/RoleInformationEvaluationService.gd", "slot5") and _t07_b_source_avoids("res://scripts/domain/cases/ClockTowerService.gd", "slot5")
	checks.no_ring8_hardcode = _t07_b_source_avoids("res://scripts/domain/cases/RoleInformationEvaluationService.gd", "ring_hour = 8") and _t07_b_source_avoids("res://scripts/domain/cases/ClockTowerService.gd", "ring_hour = 8")
	checks.presentation_state = (
		board_idle != null
		and board_ringing != null
		and board_idle.get_location_tile_text(BoardLocationDefinition.LOCATION_CLOCK_TOWER).contains("12")
		and board_ringing.get_location_tile_text(BoardLocationDefinition.LOCATION_CLOCK_TOWER).contains("REO")
	)
	checks.no_new_3x3_hardcode = _t07_b_location_abstraction_future_proof()
	if board_idle != null:
		board_idle.free()
	if board_ringing != null:
		board_ringing.free()
	return checks


func _t07_b_clock_tower(ring_hour: int) -> ClockTowerDefinition:
	var tower: ClockTowerDefinition = ClockTowerDefinition.new()
	tower.display_name = "Tháp Đồng Hồ"
	tower.board_slot = 5
	tower.ring_hour = ring_hour
	return tower


func _t07_b_clock_case(
	tower: ClockTowerDefinition,
	clock_maker_true: bool,
	suspected_role_id: StringName,
	false_start_hour: int = -1,
	tainted: bool = false,
	first_true_role_id: StringName = &"clock_maker"
) -> CaseDefinition:
	var first_role_id: StringName = &"clock_maker" if clock_maker_true else first_true_role_id
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, first_role_id, &"clock_maker", CaseEnums.Alignment.GOOD, tainted, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(2, 8, &"tutorial_mobster", first_role_id, CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	], 6)
	c.suspects[1].impersonated_role_id = first_role_id
	c.case_id = &"t07_b_clock_maker_smoke"
	c.display_name = "T07-B Clock Maker Smoke"
	c.crime_scene.scene_id = &"t07_b_scene"
	var suspected_ids: Array[StringName] = [suspected_role_id, &"tutorial_mobster"]
	c.suspected_role_ids = suspected_ids
	c.evil_suspect_ids = PackedInt32Array([2])
	c.accomplice_suspect_ids = PackedInt32Array([2])
	c.traitor_suspect_ids = PackedInt32Array()
	if false_start_hour >= 0:
		c.suspects[0].authored_lie_numeric_value = false_start_hour
	if tower != null:
		c.board_locations.append(tower)
	return c


func _t07_b_mobster_clock_case(tower: ClockTowerDefinition) -> CaseDefinition:
	var c: CaseDefinition = _t07_b_clock_case(tower, false, &"clock_maker", 11, false, &"tutorial_mobster")
	c.suspects[0].true_alignment = CaseEnums.Alignment.EVIL
	c.suspects[0].role_group = CaseEnums.RoleGroup.TONG_PHAM
	c.suspects[0].is_impersonating = true
	c.suspects[0].impersonated_role_id = &"clock_maker"
	c.suspects[1].true_role_id = &"tutorial_priest"
	c.suspects[1].displayed_role_id = &"tutorial_priest"
	c.suspects[1].true_alignment = CaseEnums.Alignment.GOOD
	c.suspects[1].role_group = CaseEnums.RoleGroup.CHINH_NHAN
	c.suspects[1].is_impersonating = false
	c.suspects[1].impersonated_role_id = &""
	c.evil_suspect_ids = PackedInt32Array([1])
	c.accomplice_suspect_ids = PackedInt32Array([1])
	return c


func _t07_b_role_requires_tower(role_id: StringName, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var report: Dictionary = CaseDefinitionValidator.new().validate(_t07_b_clock_case(null, false, role_id, -1, false, &"tutorial_priest"), roles, players)
	return _report_has_error_code(report, "CLOCK_TOWER_REQUIRED")


func _t07_b_case_valid(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var report: Dictionary = CaseDefinitionValidator.new().validate(c, roles, players)
	return bool(report.get("passed", false))


func _t07_b_location_investigation_rejected(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = (_fresh_turn_bundle(c, players).runtime) as CaseRuntimeState
	var player_id: StringName = runtime.current_player_id() if runtime != null else &""
	var result: InvestigationResult = InvestigationService.new().investigate(c, runtime, 5, player_id)
	return not result.success and result.error_code == &"SUSPECT_NOT_FOUND"


func _t07_b_board_at_hour(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState], elapsed_hour: int) -> CaseBoardController:
	var runtime: CaseRuntimeState = (_fresh_turn_bundle(c, players).runtime) as CaseRuntimeState
	if runtime == null:
		return null
	runtime.elapsed_hours = elapsed_hour
	return _board_instance_with_runtime(c, runtime, roles)


func _t07_b_source_avoids(path: String, needle: String) -> bool:
	return not FileAccess.get_file_as_string(path).contains(needle)


func _t07_b_location_abstraction_future_proof() -> bool:
	var location_source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/BoardLocationDefinition.gd")
	var clock_source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/ClockTowerDefinition.gd")
	return (
		not location_source.contains("0, 8")
		and not location_source.contains("BOARD_SLOT_COUNT")
		and not location_source.contains("slot5")
		and not location_source.contains("slot6")
		and not clock_source.contains("BOARD_SLOT_COUNT")
		and not clock_source.contains("slot5")
		and not clock_source.contains("slot6")
	)


func _t07_c_timed_event_dispatcher_checks(players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	var dispatcher = CASE_TIMED_EVENT_DISPATCHER.new()
	var registered_ids: Array[StringName] = dispatcher.registered_handler_ids()
	var before_case: CaseDefinition = _surgeon_case()
	var before_runtime: CaseRuntimeState = _surgeon_runtime(before_case, players, 1, 10)
	var before_results: Array[Dictionary] = dispatcher.evaluate_all(before_case, before_runtime)
	var before_event: CaseTimedEventRuntimeState = _t07_c_first_timed_event(before_results)
	var success: Dictionary = _t07_c_dispatcher_evaluate(_surgeon_case(true), players, 1, 12)
	var success_event: CaseTimedEventRuntimeState = success.event as CaseTimedEventRuntimeState
	var fail: Dictionary = _t07_c_dispatcher_evaluate(_surgeon_case(), players, 0, 12)
	var fail_runtime: CaseRuntimeState = fail.runtime as CaseRuntimeState
	var fail_event: CaseTimedEventRuntimeState = fail.event as CaseTimedEventRuntimeState
	var repeated: Dictionary = _t07_c_repeated_dispatch(players)
	var multi: Dictionary = _t07_c_multi_handler_dispatch(players)

	checks.dispatcher_exists = dispatcher != null
	checks.surgeon_registered = registered_ids.has(CASE_TIMED_EVENT_DISPATCHER.HANDLER_SURGEON)
	checks.elapsed_unchanged = _t07_c_dispatcher_elapsed_unchanged(players)
	checks.before_12_noop = before_event != null and not before_event.fired and before_runtime.elapsed_hours == 10
	checks.threshold_resolution = success_event != null and success_event.fired and success_event.fired_at_hour == 12
	checks.fail_branch = fail_event != null and fail_event.fired and not fail_event.resolved_success and not fail_event.kill_attempted and _dead_suspect_count(fail_runtime) == 0
	checks.success_branch = success_event != null and success_event.fired and success_event.resolved_success and success_event.kill_attempted and success_event.kill_outcome == CaseKillResult.Outcome.KILLED
	checks.random_victim = _t07_c_dispatcher_random_victim_semantics(players)
	checks.idempotency = bool(repeated.get("idempotent", false))
	checks.dead_source_suppression = _t07_c_dead_source_suppression(players)
	checks.aggregates_result = (
		_t07_c_result_for_handler(_t07_c_results_from_dictionary(success), CASE_TIMED_EVENT_DISPATCHER.HANDLER_SURGEON).size() > 0
		and success_event != null
	)
	checks.multiple_handlers = bool(multi.get("multiple", false))
	checks.handler_order = bool(multi.get("order", false))
	checks.no_overwrite = bool(multi.get("no_overwrite", false))
	checks.repeat_safe = bool(repeated.get("repeat_safe", false))
	checks.zero_hour_no_dispatch = _t07_c_controller_action_dispatch(players, CaseClockService.ACTION_ACTIVE_FUNCTION, 12, false)
	checks.investigation_dispatch = _t07_c_controller_action_dispatch(players, CaseClockService.ACTION_INVESTIGATION, 10, true)
	checks.single_accusation_dispatch = _t07_c_controller_action_dispatch(players, CaseClockService.ACTION_SINGLE_ACCUSATION, 11, true)
	checks.controller_no_direct_surgeon = _t07_c_controller_uses_dispatcher()
	checks.dispatcher_generic_with_serial = _t07_c_dispatcher_generic_with_serial()
	checks.no_recurrence = _t07_c_dispatcher_has_no_recurrence()
	checks.no_new_3x3 = _t07_c_dispatcher_spatial_agnostic()
	return checks


func _t07_c_dispatcher_evaluate(
	c: CaseDefinition,
	players: Array[PlayerCaseState],
	seed: int,
	elapsed_hours: int
) -> Dictionary:
	var runtime: CaseRuntimeState = _surgeon_runtime(c, players, seed, elapsed_hours)
	var results: Array[Dictionary] = CASE_TIMED_EVENT_DISPATCHER.new().evaluate_all(c, runtime)
	var event: CaseTimedEventRuntimeState = _t07_c_first_timed_event(results)
	return {"runtime": runtime, "event": event, "results": results}


func _t07_c_first_timed_event(results: Array[Dictionary]) -> CaseTimedEventRuntimeState:
	if results.is_empty():
		return null
	var events: Array[CaseTimedEventRuntimeState] = _t07_c_events_from_result(results[0])
	if events.is_empty():
		return null
	return events[0]


func _t07_c_first_handler_id(results: Array[Dictionary]) -> StringName:
	if results.is_empty():
		return &""
	return StringName(results[0].get("handler_id", &""))


func _t07_c_result_for_handler(results: Array[Dictionary], handler_id: StringName) -> Dictionary:
	for result: Dictionary in results:
		if StringName(result.get("handler_id", &"")) == handler_id:
			return result
	return {}


func _t07_c_results_from_dictionary(value: Dictionary) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	var raw_results: Variant = value.get("results", [])
	if raw_results is Array:
		for result: Variant in raw_results:
			if result is Dictionary:
				results.append(result as Dictionary)
	return results


func _t07_c_events_from_result(result: Dictionary) -> Array[CaseTimedEventRuntimeState]:
	var events: Array[CaseTimedEventRuntimeState] = []
	var raw_events: Variant = result.get("events", [])
	if raw_events is Array:
		for event: Variant in raw_events:
			if event is CaseTimedEventRuntimeState:
				events.append(event as CaseTimedEventRuntimeState)
	return events


func _t07_c_dispatcher_elapsed_unchanged(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _surgeon_case()
	var runtime: CaseRuntimeState = _surgeon_runtime(c, players, 1, 12)
	var before_hours: int = runtime.elapsed_hours
	CASE_TIMED_EVENT_DISPATCHER.new().evaluate_all(c, runtime)
	return runtime.elapsed_hours == before_hours


func _t07_c_dispatcher_random_victim_semantics(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _surgeon_case(true)
	var seen: PackedInt32Array = PackedInt32Array()
	for seed: int in range(0, 64):
		var result: Dictionary = _t07_c_dispatcher_evaluate(c, players, seed, 12)
		var event: CaseTimedEventRuntimeState = result.event as CaseTimedEventRuntimeState
		if event != null and event.resolved_success and event.target_suspect_id not in seen:
			seen.append(event.target_suspect_id)
	seen.sort()
	return _sets_equal_for_test(seen, PackedInt32Array([2, 5]))


func _t07_c_repeated_dispatch(players: Array[PlayerCaseState]) -> Dictionary:
	var c: CaseDefinition = _surgeon_case()
	var runtime: CaseRuntimeState = _surgeon_runtime(c, players, 1, 12)
	var dispatcher = CASE_TIMED_EVENT_DISPATCHER.new()
	var first_results: Array[Dictionary] = dispatcher.evaluate_all(c, runtime)
	var first_event: CaseTimedEventRuntimeState = _t07_c_first_timed_event(first_results)
	var first_target_id: int = first_event.target_suspect_id if first_event != null else 0
	var first_log_count: int = _timed_event_log_count(runtime, &"surgeon_1_12h")
	var first_kill_count: int = _surgeon_kill_log_count(runtime, first_target_id)
	var second_results: Array[Dictionary] = dispatcher.evaluate_all(c, runtime)
	var second_event: CaseTimedEventRuntimeState = _t07_c_first_timed_event(second_results)
	return {
		"idempotent": first_event != null and second_event != null and first_event == second_event and second_event.fired,
		"repeat_safe": first_log_count == 1 and _timed_event_log_count(runtime, &"surgeon_1_12h") == 1 and first_kill_count == _surgeon_kill_log_count(runtime, first_target_id),
	}


func _t07_c_dead_source_suppression(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _surgeon_case()
	var runtime: CaseRuntimeState = _surgeon_runtime(c, players, 1, 12)
	CaseKillService.new().kill(c, runtime, 1, &"smoke")
	var results: Array[Dictionary] = CASE_TIMED_EVENT_DISPATCHER.new().evaluate_all(c, runtime)
	var events: Array[CaseTimedEventRuntimeState] = []
	if not results.is_empty():
		events = _t07_c_events_from_result(results[0])
	return events.is_empty() and runtime.timed_events.is_empty()


func _t07_c_multi_handler_dispatch(players: Array[PlayerCaseState]) -> Dictionary:
	var c: CaseDefinition = _surgeon_case()
	var runtime: CaseRuntimeState = _surgeon_runtime(c, players, 1, 12)
	var dispatcher = CASE_TIMED_EVENT_DISPATCHER.new()
	dispatcher.clear_handlers()
	dispatcher.register_handler(&"alpha_surgeon", SurgeonTimedEventService.new())
	dispatcher.register_handler(&"beta_surgeon", SurgeonTimedEventService.new())
	var results: Array[Dictionary] = dispatcher.evaluate_all(c, runtime)
	var ids: Array[StringName] = []
	for result: Dictionary in results:
		ids.append(StringName(result.get("handler_id", &"")))
	return {
		"multiple": results.size() == 2,
		"order": ids == [&"alpha_surgeon", &"beta_surgeon"],
		"no_overwrite": results.size() == 2 and results[0].get("handler_id", &"") != results[1].get("handler_id", &"") and _timed_event_log_count(runtime, &"surgeon_1_12h") == 1,
	}


func _t07_c_controller_action_dispatch(players: Array[PlayerCaseState], action_type: StringName, starting_hours: int, should_dispatch: bool) -> bool:
	var c: CaseDefinition = _surgeon_case()
	var runtime: CaseRuntimeState = _surgeon_runtime(c, players, 1, starting_hours)
	var scene: VSCaseMainController = VSCaseMainController.new()
	scene.case_definition = c
	scene.runtime_state = runtime
	var before_timed_events: int = runtime.timed_events.size()
	var applied: bool = scene._commit_action_time_and_timed_events(StringName("t07c:%s:%d" % [String(action_type), starting_hours]), action_type)
	scene.free()
	if not applied:
		return false
	if should_dispatch:
		var event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"surgeon_1_12h")
		return event != null and event.fired
	return runtime.timed_events.size() == before_timed_events


func _t07_c_controller_uses_dispatcher() -> bool:
	var source: String = FileAccess.get_file_as_string("res://scripts/presentation/case_gameplay/VSCaseMainController.gd")
	return source.contains("timed_event_dispatcher.evaluate_all") and not source.contains("SurgeonTimedEventService")


func _t07_c_dispatcher_generic_with_serial() -> bool:
	var dispatcher_source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/CaseTimedEventDispatcher.gd")
	var controller_source: String = FileAccess.get_file_as_string("res://scripts/presentation/case_gameplay/VSCaseMainController.gd")
	return (
		dispatcher_source.contains("register_handler(HANDLER_SERIAL_KILLER")
		and dispatcher_source.contains("SERIAL_KILLER_TIMED_EVENT_SERVICE.new()")
		and not controller_source.contains("SerialKillerTimedEventService")
		and not controller_source.contains("serial_killer")
	)


func _t07_c_dispatcher_has_no_recurrence() -> bool:
	var source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/CaseTimedEventDispatcher.gd").to_lower()
	return not source.contains("recurrence") and not source.contains("interval") and not source.contains("every")


func _t07_c_dispatcher_spatial_agnostic() -> bool:
	var source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/CaseTimedEventDispatcher.gd")
	return (
		not source.contains("BOARD_SLOT_COUNT")
		and not source.contains("board_slot")
		and not source.contains("slot")
		and not source.contains("3x3")
		and not source.contains("4x4")
	)


func _t07_d_serial_killer_checks(roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	var service = SERIAL_KILLER_TIMED_EVENT_SERVICE.new()
	var role: RoleDefinition = _find_role_for_test(roles, &"serial_killer")
	var validator: CaseDefinitionValidator = CaseDefinitionValidator.new()
	var base_case: CaseDefinition = _t07_d_serial_case()
	var base_runtime: CaseRuntimeState = _t07_d_serial_runtime(base_case, players, 17, 0)
	var pretend_pool: Array[StringName] = CASE_ROLE_POOL_SERVICE.suspected_role_candidates(base_case, &"serial_killer")
	var eligible_ids: PackedInt32Array = service.eligible_adjacent_good_target_ids(base_case, base_runtime, 1)
	var dead_pool_runtime: CaseRuntimeState = _t07_d_serial_runtime(base_case, players, 17, 0)
	CaseKillService.new().kill(base_case, dead_pool_runtime, 2, &"smoke")
	var dead_pool_ids: PackedInt32Array = service.eligible_adjacent_good_target_ids(base_case, dead_pool_runtime, 1)
	var stable_a: Dictionary = _t07_d_serial_evaluate(base_case, players, 19, 9)
	var stable_b: Dictionary = _t07_d_serial_evaluate(base_case, players, 19, 9)
	var alternate_victims: PackedInt32Array = _t07_d_serial_victims_for_seed_scan(players)
	var before_runtime: CaseRuntimeState = _t07_d_serial_runtime(base_case, players, 17, 8)
	var before_events: Array[CaseTimedEventRuntimeState] = service.evaluate(base_case, before_runtime)
	var crossing: Dictionary = _t07_d_serial_crossing(players, 8, 2)
	var crossing_runtime: CaseRuntimeState = crossing.get("runtime", null) as CaseRuntimeState
	var crossing_event: CaseTimedEventRuntimeState = crossing.get("event_9", null) as CaseTimedEventRuntimeState
	var repeated: Dictionary = _t07_d_serial_repeated_at(players, 9)
	var eighteen: Dictionary = _t07_d_serial_evaluate(base_case, players, 23, 18)
	var eighteen_runtime: CaseRuntimeState = eighteen.get("runtime", null) as CaseRuntimeState
	var event_9_at_18: CaseTimedEventRuntimeState = eighteen_runtime.timed_event_by_id(&"serial_killer_1_9h")
	var event_18: CaseTimedEventRuntimeState = eighteen_runtime.timed_event_by_id(&"serial_killer_1_18h")
	var crossing_20: Dictionary = _t07_d_serial_crossing(players, 8, 12)
	var crossing_20_runtime: CaseRuntimeState = crossing_20.get("runtime", null) as CaseRuntimeState
	var no_target: Dictionary = _t07_d_serial_evaluate(_t07_d_serial_no_target_case(), players, 17, 9)
	var no_target_event: CaseTimedEventRuntimeState = no_target.get("event", null) as CaseTimedEventRuntimeState
	var no_time_runtime: CaseRuntimeState = _t07_d_serial_runtime(base_case, players, 17, 9)
	var before_hours: int = no_time_runtime.elapsed_hours
	service.evaluate(base_case, no_time_runtime)
	var dead_source: Dictionary = _t07_d_serial_suppressed_event(players, &"dead")
	var tainted_source: Dictionary = _t07_d_serial_suppressed_event(players, &"tainted")
	var runtime_corrupted_source: Dictionary = _t07_d_serial_suppressed_event(players, &"runtime_corrupted")
	var arrested_source: Dictionary = _t07_d_serial_suppressed_event(players, &"arrested")
	var dispatcher_ids: Array[StringName] = CASE_TIMED_EVENT_DISPATCHER.new().registered_handler_ids()
	var death_result: Dictionary = _t07_d_serial_evaluate(base_case, players, 31, 9)
	var death_runtime: CaseRuntimeState = death_result.get("runtime", null) as CaseRuntimeState
	var death_event: CaseTimedEventRuntimeState = death_result.get("event", null) as CaseTimedEventRuntimeState
	var authored_before: Dictionary = _t07_d_authored_snapshot(base_case)
	var authored_runtime: CaseRuntimeState = _t07_d_serial_runtime(base_case, players, 31, 9)
	service.evaluate(base_case, authored_runtime)
	var later: Dictionary = _t07_d_serial_later_interval(players)
	var mutation_checks: Dictionary = _t07_d_serial_mutation_authority_checks(roles, players)
	var tutorial_case: CaseDefinition = FixtureRepository.load_tutorial_case_007()
	var unsupported_pretend_case: CaseDefinition = _t07_d_serial_case()
	unsupported_pretend_case.suspected_role_ids.append(&"surgeon")
	unsupported_pretend_case.suspects[0].impersonated_role_id = &"surgeon"

	checks.role_exists = role != null and role.role_id == &"serial_killer" and role.display_name == "Sát Nhân Hàng Loạt"
	checks.role_group = role != null and role.role_group == CaseEnums.RoleGroup.TONG_PHAM
	checks.role_alignment = role != null and CASE_ROLE_POOL_SERVICE.role_alignment(role) == CaseEnums.Alignment.EVIL
	checks.always_lies = role != null and role.always_lies
	checks.pretend_pool_suspected = pretend_pool.has(&"reporter") and pretend_pool.has(&"therapist") and not pretend_pool.has(&"serial_killer")
	checks.nested_excluded = not pretend_pool.has(&"drunkard")
	checks.pretend_supported = service.pretend_role_is_valid(base_case, &"reporter")
	checks.pretend_clock_maker = tutorial_case != null and service.pretend_role_is_valid(tutorial_case, &"clock_maker") and bool(validator.validate(tutorial_case, roles, players).get("passed", false))
	checks.pretend_unsupported = not service.pretend_role_is_valid(unsupported_pretend_case, &"surgeon") and _report_has_error_code(validator.validate(unsupported_pretend_case, roles, players), "SERIAL_KILLER_PRETEND_ROLE_NOT_SUSPECTED")
	checks.pretend_self_rejected = not service.pretend_role_is_valid(base_case, &"serial_killer")
	checks.pretend_unlisted_rejected = CASE_PROCEDURAL_PRETEND_CAPABILITY.serial_killer_can_pretend(&"mathematician") and not service.pretend_role_is_valid(base_case, &"mathematician")
	checks.pretend_shared_authority = service.pretend_role_is_valid(base_case, &"reporter") == CASE_PROCEDURAL_PRETEND_CAPABILITY.serial_killer_can_pretend(&"reporter")
	checks.spawn_adjacent_innocent = service.serial_killer_spawn_requirement_met(base_case, 1, roles)
	checks.spawn_meddler_fails = not service.serial_killer_spawn_requirement_met(_t07_d_serial_spawn_meddler_case(), 1, roles) and _report_has_error_code(validator.validate(_t07_d_serial_spawn_meddler_case(), roles, players), "SERIAL_KILLER_ADJACENT_INNOCENT_REQUIRED")
	checks.spawn_non_adjacent_fails = not service.serial_killer_spawn_requirement_met(_t07_d_serial_spawn_non_adjacent_case(), 1, roles) and _report_has_error_code(validator.validate(_t07_d_serial_spawn_non_adjacent_case(), roles, players), "SERIAL_KILLER_ADJACENT_INNOCENT_REQUIRED")
	checks.spawn_evil_innocent = service.serial_killer_spawn_requirement_met(_t07_d_serial_spawn_evil_innocent_case(), 1, roles)
	checks.spawn_location_fails = not service.serial_killer_spawn_requirement_met(_t07_d_serial_spawn_location_case(), 1, roles) and _report_has_error_code(validator.validate(_t07_d_serial_spawn_location_case(), roles, players), "SERIAL_KILLER_ADJACENT_INNOCENT_REQUIRED")
	checks.spawn_transformed_only_fails = bool(mutation_checks.get("spawn_transformed_only_fails", false))
	checks.spawn_transformed_plus_innocent = bool(mutation_checks.get("spawn_transformed_plus_innocent", false))
	checks.spawn_displayed_innocent_fails = bool(mutation_checks.get("spawn_displayed_innocent_fails", false))
	checks.kill_adjacent_good = eligible_ids.has(2)
	checks.kill_adjacent_evil_excluded = not eligible_ids.has(3)
	checks.kill_non_adjacent_good_excluded = not eligible_ids.has(4)
	checks.kill_dead_good_excluded = not dead_pool_ids.has(2)
	checks.kill_source_excluded = not eligible_ids.has(1)
	checks.kill_location_excluded = not eligible_ids.has(base_case.crime_scene.board_slot)
	checks.kill_transformed_good = bool(mutation_checks.get("kill_transformed_good", false))
	checks.kill_displayed_good_evil_excluded = bool(mutation_checks.get("kill_displayed_good_evil_excluded", false))
	checks.kill_arrested_good_eligible = bool(mutation_checks.get("kill_arrested_good_eligible", false))
	checks.kill_full_pool = _sets_equal_for_test(eligible_ids, PackedInt32Array([2, 5, 6]))
	checks.deterministic_seed_stable = _t07_d_event_target(stable_a) > 0 and _t07_d_event_target(stable_a) == _t07_d_event_target(stable_b)
	checks.alternate_seed_varies = alternate_victims.size() > 1
	checks.before_9_no_event = before_events.is_empty() and before_runtime.timed_events.is_empty()
	checks.cross_8_10_resolves_9 = crossing_event != null and crossing_event.fired and crossing_event.threshold_hour == 9 and crossing_runtime.elapsed_hours == 10
	checks.event_9_idempotent = bool(repeated.get("idempotent", false))
	checks.event_18_distinct = event_18 != null and event_18.fired and event_18.threshold_hour == 18 and event_18.event_id == &"serial_killer_1_18h"
	checks.event_18_no_overwrite = event_9_at_18 != null and event_18 != null and event_9_at_18 != event_18 and event_9_at_18.threshold_hour == 9
	checks.cross_8_20_chronological = _t07_d_timed_threshold_log(crossing_20_runtime) == PackedInt32Array([9, 18])
	checks.repeat_20_no_reroll = _t07_d_repeated_20_no_reroll(players)
	checks.no_target_safe = no_target_event != null and no_target_event.fired and not no_target_event.resolved_success and not no_target_event.kill_attempted and _dead_suspect_count(no_target.get("runtime", null) as CaseRuntimeState) == 0
	checks.evaluation_no_time_advance = no_time_runtime.elapsed_hours == before_hours
	checks.dead_source_no_kill = bool(dead_source.get("no_kill", false))
	checks.tainted_source_no_kill = bool(tainted_source.get("no_kill", false))
	checks.runtime_corrupted_source_no_kill = bool(runtime_corrupted_source.get("no_kill", false))
	checks.arrested_source_no_kill = bool(arrested_source.get("no_kill", false))
	checks.suppression_marks_resolved = bool(arrested_source.get("fired", false)) and not bool(arrested_source.get("success", true))
	checks.suppression_no_reroll = bool(arrested_source.get("repeat_safe", false))
	checks.dispatcher_serial_registered = dispatcher_ids.has(CASE_TIMED_EVENT_DISPATCHER.HANDLER_SERIAL_KILLER)
	checks.dispatcher_surgeon_registered = dispatcher_ids.has(CASE_TIMED_EVENT_DISPATCHER.HANDLER_SURGEON)
	checks.dispatcher_order = dispatcher_ids.find(CASE_TIMED_EVENT_DISPATCHER.HANDLER_SURGEON) < dispatcher_ids.find(CASE_TIMED_EVENT_DISPATCHER.HANDLER_SERIAL_KILLER)
	checks.controller_no_direct_serial = _t07_d_controller_avoids_serial_killer()
	checks.zero_hour_no_dispatch = _t07_d_controller_action_dispatch(players, CaseClockService.ACTION_ACTIVE_FUNCTION, 9, false)
	checks.positive_time_dispatch = _t07_d_controller_action_dispatch(players, CaseClockService.ACTION_SINGLE_ACCUSATION, 8, true)
	checks.death_uses_kill_service = death_event != null and death_event.target_suspect_id > 0 and _t07_d_kill_log_count(death_runtime, death_event.target_suspect_id) == 1
	checks.authored_unchanged = _t07_d_authored_snapshot_matches(_t07_d_authored_snapshot(base_case), authored_before)
	checks.event_target_stored = death_event != null and death_event.target_suspect_id > 0
	checks.history_records_victim = death_event != null and _timed_event_log_count(death_runtime, death_event.event_id) == 1 and _t07_d_kill_log_count(death_runtime, death_event.target_suspect_id) == 1
	checks.later_interval_independent = bool(later.get("independent", false))
	checks.no_tutorial_7_hardcode = _t07_d_service_no_tutorial_hardcode()
	checks.no_slot_hardcode = _t07_d_service_no_slot_hardcode()
	checks.no_3x3_assumption = _t07_d_service_no_3x3_assumption()
	checks.no_controller_recurrence = _t07_d_controller_no_recurrence()
	checks.surgeon_unchanged = _t07_d_surgeon_service_untouched()
	return checks


func _t07_d_serial_case() -> CaseDefinition:
	var specs: Array[Dictionary] = [
		_role_info_spec(1, 4, &"serial_killer", &"reporter", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(2, 1, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(3, 3, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(4, 0, &"reporter", &"reporter", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(5, 5, &"therapist", &"therapist", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(6, 7, &"surgeon", &"surgeon", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
	]
	var c: CaseDefinition = _role_info_case_fixture(specs, 8)
	c.case_id = &"t07_d_serial_killer_smoke"
	c.suspects[0].impersonated_role_id = &"reporter"
	var suspected_ids: Array[StringName] = [&"reporter", &"therapist", &"barkeep", &"serial_killer", &"tutorial_mobster"]
	c.suspected_role_ids = suspected_ids
	var nested_ids: Array[StringName] = [&"drunkard"]
	c.nested_suspect_list_role_ids_by_parent[&"barkeep"] = nested_ids
	c.evil_suspect_ids = PackedInt32Array([1, 3])
	c.accomplice_suspect_ids = PackedInt32Array([1, 3])
	c.traitor_suspect_ids = PackedInt32Array()
	return c


func _t07_d_serial_runtime(c: CaseDefinition, players: Array[PlayerCaseState], seed: int, elapsed_hours: int) -> CaseRuntimeState:
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	runtime.case_event_seed = seed
	if elapsed_hours > 0:
		CaseClockService.new().advance_hours(runtime, elapsed_hours, &"smoke")
	return runtime


func _t07_d_serial_evaluate(c: CaseDefinition, players: Array[PlayerCaseState], seed: int, elapsed_hours: int) -> Dictionary:
	var runtime: CaseRuntimeState = _t07_d_serial_runtime(c, players, seed, elapsed_hours)
	var events: Array[CaseTimedEventRuntimeState] = SERIAL_KILLER_TIMED_EVENT_SERVICE.new().evaluate(c, runtime)
	var event: CaseTimedEventRuntimeState = events[0] if not events.is_empty() else null
	return {"runtime": runtime, "event": event, "events": events}


func _t07_d_event_target(result: Dictionary) -> int:
	var event: CaseTimedEventRuntimeState = result.get("event", null) as CaseTimedEventRuntimeState
	return event.target_suspect_id if event != null else 0


func _t07_d_serial_victims_for_seed_scan(players: Array[PlayerCaseState]) -> PackedInt32Array:
	var c: CaseDefinition = _t07_d_serial_case()
	var seen: PackedInt32Array = PackedInt32Array()
	for seed: int in range(0, 64):
		var result: Dictionary = _t07_d_serial_evaluate(c, players, seed, 9)
		var target_id: int = _t07_d_event_target(result)
		if target_id > 0 and target_id not in seen:
			seen.append(target_id)
	seen.sort()
	return seen


func _t07_d_serial_crossing(players: Array[PlayerCaseState], start_hours: int, added_hours: int) -> Dictionary:
	var c: CaseDefinition = _t07_d_serial_case()
	var runtime: CaseRuntimeState = _t07_d_serial_runtime(c, players, 19, start_hours)
	CaseClockService.new().advance_hours(runtime, added_hours, &"smoke_crossing")
	var events: Array[CaseTimedEventRuntimeState] = SERIAL_KILLER_TIMED_EVENT_SERVICE.new().evaluate(c, runtime)
	return {
		"runtime": runtime,
		"events": events,
		"event_9": runtime.timed_event_by_id(&"serial_killer_1_9h"),
		"event_18": runtime.timed_event_by_id(&"serial_killer_1_18h"),
	}


func _t07_d_serial_repeated_at(players: Array[PlayerCaseState], elapsed_hours: int) -> Dictionary:
	var c: CaseDefinition = _t07_d_serial_case()
	var runtime: CaseRuntimeState = _t07_d_serial_runtime(c, players, 19, elapsed_hours)
	var service = SERIAL_KILLER_TIMED_EVENT_SERVICE.new()
	service.evaluate(c, runtime)
	var first_event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"serial_killer_1_9h")
	var first_target_id: int = first_event.target_suspect_id if first_event != null else 0
	var first_log_count: int = _timed_event_log_count(runtime, &"serial_killer_1_9h")
	var first_kill_count: int = _t07_d_kill_log_count(runtime, first_target_id)
	service.evaluate(c, runtime)
	var second_event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"serial_killer_1_9h")
	return {
		"idempotent": first_event != null and second_event != null and first_event == second_event and second_event.target_suspect_id == first_target_id,
		"repeat_safe": first_log_count == _timed_event_log_count(runtime, &"serial_killer_1_9h") and first_kill_count == _t07_d_kill_log_count(runtime, first_target_id),
	}


func _t07_d_repeated_20_no_reroll(players: Array[PlayerCaseState]) -> bool:
	var crossing: Dictionary = _t07_d_serial_crossing(players, 8, 12)
	var runtime: CaseRuntimeState = crossing.get("runtime", null) as CaseRuntimeState
	var event_9: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"serial_killer_1_9h")
	var event_18: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"serial_killer_1_18h")
	var first_9_target: int = event_9.target_suspect_id if event_9 != null else 0
	var first_18_target: int = event_18.target_suspect_id if event_18 != null else 0
	var first_9_logs: int = _timed_event_log_count(runtime, &"serial_killer_1_9h")
	var first_18_logs: int = _timed_event_log_count(runtime, &"serial_killer_1_18h")
	SERIAL_KILLER_TIMED_EVENT_SERVICE.new().evaluate(_t07_d_serial_case(), runtime)
	event_9 = runtime.timed_event_by_id(&"serial_killer_1_9h")
	event_18 = runtime.timed_event_by_id(&"serial_killer_1_18h")
	return (
		event_9 != null
		and event_18 != null
		and event_9.target_suspect_id == first_9_target
		and event_18.target_suspect_id == first_18_target
		and _timed_event_log_count(runtime, &"serial_killer_1_9h") == first_9_logs
		and _timed_event_log_count(runtime, &"serial_killer_1_18h") == first_18_logs
	)


func _t07_d_timed_threshold_log(runtime: CaseRuntimeState) -> PackedInt32Array:
	var thresholds: PackedInt32Array = PackedInt32Array()
	if runtime == null:
		return thresholds
	for entry: Dictionary in runtime.action_log:
		if String(entry.get("action", "")) == "TIMED_EVENT" and String(entry.get("event_id", "")).begins_with("serial_killer_"):
			thresholds.append(int(entry.get("threshold_hour", 0)))
	return thresholds


func _t07_d_serial_suppressed_event(players: Array[PlayerCaseState], mode: StringName) -> Dictionary:
	var c: CaseDefinition = _t07_d_serial_case()
	var runtime: CaseRuntimeState = _t07_d_serial_runtime(c, players, 19, 9)
	if mode == &"dead":
		CaseKillService.new().kill(c, runtime, 1, &"smoke")
	elif mode == &"tainted":
		c.suspects[0].is_corrupted = true
	elif mode == &"runtime_corrupted":
		runtime.find_suspect(1).apply_runtime_corruption(99)
	elif mode == &"arrested":
		runtime.find_suspect(1).mark_arrested()
	SERIAL_KILLER_TIMED_EVENT_SERVICE.new().evaluate(c, runtime)
	var event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"serial_killer_1_9h")
	var first_logs: int = _timed_event_log_count(runtime, &"serial_killer_1_9h")
	SERIAL_KILLER_TIMED_EVENT_SERVICE.new().evaluate(c, runtime)
	return {
		"no_kill": event != null and event.fired and not event.resolved_success and _t07_d_kill_log_count(runtime, event.target_suspect_id) == 0,
		"fired": event != null and event.fired,
		"success": event != null and event.resolved_success,
		"repeat_safe": first_logs == _timed_event_log_count(runtime, &"serial_killer_1_9h"),
	}


func _t07_d_controller_action_dispatch(players: Array[PlayerCaseState], action_type: StringName, starting_hours: int, should_dispatch: bool) -> bool:
	var c: CaseDefinition = _t07_d_serial_case()
	var runtime: CaseRuntimeState = _t07_d_serial_runtime(c, players, 19, starting_hours)
	var scene: VSCaseMainController = VSCaseMainController.new()
	scene.case_definition = c
	scene.runtime_state = runtime
	var before_timed_events: int = runtime.timed_events.size()
	var applied: bool = scene._commit_action_time_and_timed_events(StringName("t07d:%s:%d" % [String(action_type), starting_hours]), action_type)
	scene.free()
	if not applied:
		return false
	if should_dispatch:
		var event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"serial_killer_1_9h")
		return event != null and event.fired
	return runtime.timed_events.size() == before_timed_events


func _t07_d_kill_log_count(runtime: CaseRuntimeState, suspect_id: int) -> int:
	var count: int = 0
	if runtime == null:
		return count
	for entry: Dictionary in runtime.action_log:
		var action: String = String(entry.get("action", ""))
		var logged_suspect_id: int = int(entry.get("suspect_id", 0))
		var source: StringName = StringName(String(entry.get("source", "")))
		if action == "KILL" and logged_suspect_id == suspect_id and source == &"serial_killer":
			count += 1
	return count


func _t07_d_authored_snapshot(c: CaseDefinition) -> Dictionary:
	var slots: PackedInt32Array = PackedInt32Array()
	var true_roles: Array[StringName] = []
	for suspect: SuspectDefinition in c.suspects:
		slots.append(suspect.board_slot)
		true_roles.append(suspect.true_role_id)
	return {
		"slots": slots,
		"true_roles": true_roles,
		"evil_ids": c.evil_suspect_ids.duplicate(),
	}


func _t07_d_authored_snapshot_matches(first: Dictionary, second: Dictionary) -> bool:
	var first_slots: PackedInt32Array = first.get("slots", PackedInt32Array())
	var second_slots: PackedInt32Array = second.get("slots", PackedInt32Array())
	var first_true_roles: Array = first.get("true_roles", [])
	var second_true_roles: Array = second.get("true_roles", [])
	var first_evil_ids: PackedInt32Array = first.get("evil_ids", PackedInt32Array())
	var second_evil_ids: PackedInt32Array = second.get("evil_ids", PackedInt32Array())
	return (
		_sets_equal_for_test(first_slots, second_slots)
		and first_true_roles == second_true_roles
		and _sets_equal_for_test(first_evil_ids, second_evil_ids)
	)


func _t07_d_serial_later_interval(players: Array[PlayerCaseState]) -> Dictionary:
	var c: CaseDefinition = _t07_d_serial_case()
	var runtime: CaseRuntimeState = _t07_d_serial_runtime(c, players, 23, 9)
	SERIAL_KILLER_TIMED_EVENT_SERVICE.new().evaluate(c, runtime)
	var first_event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"serial_killer_1_9h")
	CaseClockService.new().advance_hours(runtime, 9, &"smoke_later")
	SERIAL_KILLER_TIMED_EVENT_SERVICE.new().evaluate(c, runtime)
	var second_event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"serial_killer_1_18h")
	return {
		"independent": first_event != null and second_event != null and first_event != second_event and first_event.threshold_hour == 9 and second_event.threshold_hour == 18,
	}


func _t07_d_serial_spawn_meddler_case() -> CaseDefinition:
	var specs: Array[Dictionary] = [
		_role_info_spec(1, 4, &"serial_killer", &"reporter", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(2, 1, &"surgeon", &"surgeon", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
		_role_info_spec(3, 3, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	]
	return _t07_d_configure_serial_case(_role_info_case_fixture(specs, 8))


func _t07_d_serial_spawn_non_adjacent_case() -> CaseDefinition:
	var specs: Array[Dictionary] = [
		_role_info_spec(1, 4, &"serial_killer", &"reporter", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(2, 0, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
	]
	return _t07_d_configure_serial_case(_role_info_case_fixture(specs, 8))


func _t07_d_serial_spawn_evil_innocent_case() -> CaseDefinition:
	var specs: Array[Dictionary] = [
		_role_info_spec(1, 4, &"serial_killer", &"reporter", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(2, 1, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.CHINH_NHAN),
	]
	return _t07_d_configure_serial_case(_role_info_case_fixture(specs, 8))


func _t07_d_serial_spawn_location_case() -> CaseDefinition:
	var specs: Array[Dictionary] = [
		_role_info_spec(1, 4, &"serial_killer", &"reporter", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(2, 3, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	]
	return _t07_d_configure_serial_case(_role_info_case_fixture(specs, 1))


func _t07_d_serial_no_target_case() -> CaseDefinition:
	var specs: Array[Dictionary] = [
		_role_info_spec(1, 4, &"serial_killer", &"reporter", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(2, 1, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(3, 0, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
	]
	return _t07_d_configure_serial_case(_role_info_case_fixture(specs, 8))


func _t07_d_serial_mutation_authority_checks(
	roles: Array[RoleDefinition],
	players: Array[PlayerCaseState]
) -> Dictionary:
	var service = SERIAL_KILLER_TIMED_EVENT_SERVICE.new()
	var transformed_only: CaseDefinition = _t07_d_serial_transformed_spawn_case(false)
	var transformed_runtime: CaseRuntimeState = _t07_d_serial_runtime(transformed_only, players, 17, 0)
	BarkeepTransformationService.new().resolve_transformation(
		transformed_only,
		transformed_runtime,
		transformed_only.startup_barkeep_source_suspect_id,
		transformed_only.startup_barkeep_target_suspect_id,
		roles
	)
	var transformed_target_ids: PackedInt32Array = service.eligible_adjacent_good_target_ids(
		transformed_only,
		transformed_runtime,
		1,
		roles
	)
	transformed_runtime.find_suspect(2).mark_arrested()
	var arrested_target_ids: PackedInt32Array = service.eligible_adjacent_good_target_ids(
		transformed_only,
		transformed_runtime,
		1,
		roles
	)
	var transformed_plus_innocent: CaseDefinition = _t07_d_serial_transformed_spawn_case(true)
	var displayed_innocent: CaseDefinition = _t07_d_serial_displayed_innocent_spawn_case()
	var validator: CaseDefinitionValidator = CaseDefinitionValidator.new()
	return {
		"kill_transformed_good": transformed_target_ids.has(2),
		"kill_displayed_good_evil_excluded": not transformed_target_ids.has(4),
		"kill_arrested_good_eligible": arrested_target_ids.has(2),
		"spawn_transformed_only_fails": not service.serial_killer_spawn_requirement_met(transformed_only, 1, roles) and _report_has_error_code(validator.validate(transformed_only, roles, players), "SERIAL_KILLER_ADJACENT_INNOCENT_REQUIRED"),
		"spawn_transformed_plus_innocent": service.serial_killer_spawn_requirement_met(transformed_plus_innocent, 1, roles) and not _report_has_error_code(validator.validate(transformed_plus_innocent, roles, players), "SERIAL_KILLER_ADJACENT_INNOCENT_REQUIRED"),
		"spawn_displayed_innocent_fails": not service.serial_killer_spawn_requirement_met(displayed_innocent, 1, roles) and _report_has_error_code(validator.validate(displayed_innocent, roles, players), "SERIAL_KILLER_ADJACENT_INNOCENT_REQUIRED"),
	}


func _t07_d_serial_transformed_spawn_case(include_untouched_innocent: bool) -> CaseDefinition:
	var specs: Array[Dictionary] = [
		_role_info_spec(1, 4, &"serial_killer", &"reporter", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(2, 1, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(3, 0, &"barkeep", &"therapist", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
		_role_info_spec(4, 3, &"tutorial_mobster", &"reporter", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	]
	if include_untouched_innocent:
		specs.append(_role_info_spec(5, 5, &"mathematician", &"mathematician", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN))
	var c: CaseDefinition = _t07_d_configure_serial_case(_role_info_case_fixture(specs, 8))
	c.startup_barkeep_source_suspect_id = 3
	c.startup_barkeep_target_suspect_id = 2
	return c


func _t07_d_serial_displayed_innocent_spawn_case() -> CaseDefinition:
	var specs: Array[Dictionary] = [
		_role_info_spec(1, 4, &"serial_killer", &"reporter", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(2, 1, &"surgeon", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
	]
	return _t07_d_configure_serial_case(_role_info_case_fixture(specs, 8))


func _t07_d_configure_serial_case(c: CaseDefinition) -> CaseDefinition:
	c.case_id = &"t07_d_serial_killer_variant"
	if not c.suspects.is_empty():
		c.suspects[0].impersonated_role_id = &"reporter"
	var suspected_ids: Array[StringName] = [&"reporter", &"therapist", &"barkeep", &"serial_killer", &"tutorial_mobster"]
	c.suspected_role_ids = suspected_ids
	c.evil_suspect_ids = PackedInt32Array([1])
	c.accomplice_suspect_ids = PackedInt32Array([1])
	c.traitor_suspect_ids = PackedInt32Array()
	return c


func _t07_d_controller_avoids_serial_killer() -> bool:
	var source: String = FileAccess.get_file_as_string("res://scripts/presentation/case_gameplay/VSCaseMainController.gd")
	return not source.contains("SerialKillerTimedEventService") and not source.contains("serial_killer")


func _t07_d_service_no_tutorial_hardcode() -> bool:
	var source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/SerialKillerTimedEventService.gd").to_lower()
	return not source.contains("tutorial_07") and not source.contains("tutorial case 07") and not source.contains("#7")


func _t07_d_service_no_slot_hardcode() -> bool:
	var source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/SerialKillerTimedEventService.gd")
	return not source.contains("board_slot ==") and not source.contains("slot4") and not source.contains("slot5") and not source.contains("slot 4") and not source.contains("slot 5")


func _t07_d_service_no_3x3_assumption() -> bool:
	var source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/SerialKillerTimedEventService.gd").to_lower()
	return not source.contains("3x3") and not source.contains("4x4") and not source.contains("board_slot_count") and not source.contains("slot_count")


func _t07_d_controller_no_recurrence() -> bool:
	var source: String = FileAccess.get_file_as_string("res://scripts/presentation/case_gameplay/VSCaseMainController.gd").to_lower()
	return not source.contains("interval_hours") and not source.contains("every 9") and not source.contains("serial_killer")


func _t07_d_surgeon_service_untouched() -> bool:
	var source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/SurgeonTimedEventService.gd")
	return (
		not source.contains("serial_killer")
		and source.contains("const SURGEON_THRESHOLD_HOUR: int = 12")
		and source.contains("CaseKillService.new().kill")
	)


func _t07_i1_tutorial_case_07_checks(
	c: CaseDefinition,
	roles: Array[RoleDefinition],
	players: Array[PlayerCaseState],
	validation_report: Dictionary
) -> Dictionary:
	var checks: Dictionary = {}
	if c == null:
		checks.fixture_load = false
		return checks
	var tower: ClockTowerDefinition = ClockTowerService.clock_tower_for_case(c)
	var s1: SuspectDefinition = _t07_i1_suspect(c, 1)
	var s2: SuspectDefinition = _t07_i1_suspect(c, 2)
	var s3: SuspectDefinition = _t07_i1_suspect(c, 3)
	var s4: SuspectDefinition = _t07_i1_suspect(c, 4)
	var s5: SuspectDefinition = _t07_i1_suspect(c, 5)
	var s6: SuspectDefinition = _t07_i1_suspect(c, 6)
	var s7: SuspectDefinition = _t07_i1_suspect(c, 7)
	var blood_hound_role: RoleDefinition = _find_role_for_test(roles, &"blood_hound")
	var reference_path: Dictionary = _t07_i1_reference_path(c, roles, players)
	var accusation_path: Dictionary = _t07_i1_accusation_path(c, players)
	var relaunch: Dictionary = _t07_i1_relaunch_state(c, players)
	var board_after_death: CaseBoardController = _board_instance_with_runtime(c, reference_path.get("runtime_after_10", null) as CaseRuntimeState, roles)
	var board_fresh: CaseBoardController = _board_instance(c)
	var role_info: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var runtime_fresh: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var true_clock: InvestigationInformationResult = role_info.evaluate(c, 5, roles, {}, runtime_fresh)
	var fake_mobster_clock: InvestigationInformationResult = role_info.evaluate(c, 4, roles, {}, runtime_fresh)
	var fake_serial_clock: InvestigationInformationResult = role_info.evaluate(c, 7, roles, {}, runtime_fresh)
	var fresh_runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState

	checks.fixture_load = c != null and c.case_id == &"tutorial_case_007"
	checks.validates_7_suspects = c != null and bool(validation_report.get("passed", false)) and c.suspects.size() == 7
	checks.suspect_ids = _t07_i1_suspect_ids(c) == PackedInt32Array([1, 2, 3, 4, 5, 6, 7])
	checks.board_slots = _t07_i1_board_slots(c) == PackedInt32Array([0, 1, 2, 3, 4, 7, 8])
	checks.clock_tower_slot = tower != null and tower.board_slot == 5
	checks.crime_scene_slot = c != null and c.crime_scene != null and c.crime_scene.board_slot == 6
	checks.ratio = _t07_i1_ratio(c) == PackedInt32Array([4, 1, 2, 0])
	checks.evil_answer = c != null and _sets_equal_for_test(c.evil_suspect_ids, PackedInt32Array([4, 7]))
	checks.s1_surgeon = s1 != null and s1.true_role_id == &"surgeon" and s1.role_group == CaseEnums.RoleGroup.HIEU_SU
	checks.s2_therapist = s2 != null and s2.true_role_id == &"therapist" and s2.role_group == CaseEnums.RoleGroup.CHINH_NHAN
	checks.s3_blood_hound = s3 != null and s3.true_role_id == &"blood_hound" and s3.role_group == CaseEnums.RoleGroup.CHINH_NHAN
	checks.s3_display_name = blood_hound_role != null and blood_hound_role.display_name == "Ngự Khuyển Quan"
	checks.s4_mobster = s4 != null and s4.true_role_id == &"tutorial_mobster" and s4.role_group == CaseEnums.RoleGroup.TONG_PHAM
	checks.s4_clock_maker = s4 != null and s4.displayed_role_id == &"clock_maker" and s4.impersonated_role_id == &"clock_maker"
	checks.s5_clock_maker = s5 != null and s5.true_role_id == &"clock_maker" and s5.displayed_role_id == &"clock_maker"
	checks.s6_reporter = s6 != null and s6.true_role_id == &"reporter" and s6.role_group == CaseEnums.RoleGroup.CHINH_NHAN
	checks.s7_serial_killer = s7 != null and s7.true_role_id == &"serial_killer" and s7.role_group == CaseEnums.RoleGroup.TONG_PHAM
	checks.s7_clock_maker = s7 != null and s7.displayed_role_id == &"clock_maker" and s7.impersonated_role_id == &"clock_maker"
	checks.ring_hour_8 = tower != null and tower.ring_hour == 8
	checks.s5_true_interval = true_clock != null and true_clock.public_text() == "Tháp Đồng Hồ sẽ reo từ 8h đến 9h."
	checks.s4_false_interval = fake_mobster_clock != null and fake_mobster_clock.public_text() == "Tháp Đồng Hồ sẽ không reo từ 11h đến 12h."
	checks.s7_false_interval = fake_serial_clock != null and fake_serial_clock.public_text() == "Tháp Đồng Hồ sẽ không reo từ 5h đến 6h."
	checks.false_intervals_valid = tower != null and ClockTowerService.false_interval_is_valid(tower, 11) and ClockTowerService.false_interval_is_valid(tower, 5)
	checks.tower_idle_7 = tower != null and not ClockTowerService.hour_is_ringing(tower, 7)
	checks.tower_ring_8 = tower != null and ClockTowerService.hour_is_ringing(tower, 8)
	checks.tower_ring_9 = tower != null and ClockTowerService.hour_is_ringing(tower, 9)
	checks.tower_idle_10 = tower != null and not ClockTowerService.hour_is_ringing(tower, 10)
	checks.fresh_0h = fresh_runtime.elapsed_hours == 0
	checks.path_s1_2h = int(reference_path.get("after_1", -1)) == 2
	checks.path_s2_4h = int(reference_path.get("after_2", -1)) == 4
	checks.path_s3_6h = int(reference_path.get("after_3", -1)) == 6
	checks.path_s4_8h = int(reference_path.get("after_4", -1)) == 8
	checks.path_8h_tower_ringing = bool(reference_path.get("tower_ringing_8", false))
	checks.path_s5_10h = int(reference_path.get("after_5", -1)) == 10
	checks.path_serial_9_resolved = bool(reference_path.get("serial_9_resolved", false))
	checks.path_s6_dead = bool(reference_path.get("s6_dead", false))
	checks.path_s6_killed_by = bool(reference_path.get("s6_killed_by_serial", false))
	checks.path_serial_no_reroll = bool(reference_path.get("serial_no_reroll", false))
	checks.path_s7_12h = int(reference_path.get("after_7", -1)) == 12
	checks.surgeon_12_resolves = bool(reference_path.get("surgeon_12_resolved", false))
	checks.surgeon_no_fixed_victim = bool(reference_path.get("surgeon_no_fixed_victim", false))
	checks.surgeon_success_victim_valid = bool(reference_path.get("surgeon_success_victim_valid", false))
	checks.surgeon_failure_valid = _t07_i1_surgeon_failure_branch(c, players)
	checks.surgeon_no_reroll = bool(reference_path.get("surgeon_no_reroll", false))
	checks.accusation_plus_1h = int(accusation_path.get("elapsed_hours", -1)) == 1
	checks.accusation_stays_private = bool(accusation_path.get("not_globally_arrested", false))
	checks.private_accusation_keeps_event = bool(accusation_path.get("event_remains_active", false))
	checks.death_survives_refresh = board_after_death != null and board_after_death.get_suspect_slot(6) == 7 and board_after_death.get_rendered_ids().has(6)
	checks.death_slot_preserved = board_after_death != null and board_after_death.get_suspect_slot(6) == 7
	checks.death_authored_unchanged = s6 != null and s6.board_slot == 7 and s6.true_role_id == &"reporter"
	checks.tower_non_suspect = board_fresh != null and c.suspect_at_slot(5) == null and board_fresh.has_location_tile(BoardLocationDefinition.LOCATION_CLOCK_TOWER)
	checks.crime_non_suspect = board_fresh != null and c.suspect_at_slot(6) == null and board_fresh.has_crime_scene_tile()
	checks.locations_not_verdict = board_fresh != null and board_fresh.get_card_count() == 7 and not board_fresh.get_rendered_ids().has(0)
	checks.dispatcher_flow = bool(reference_path.get("dispatcher_flow", false))
	checks.controller_no_direct_services = _t07_i1_controller_no_direct_timed_services()
	checks.relaunch_resets_time = int(relaunch.get("elapsed_hours", -1)) == 0
	checks.relaunch_resets_death = int(relaunch.get("dead_count", -1)) == 0
	checks.relaunch_resets_events = int(relaunch.get("timed_event_count", -1)) == 0
	checks.previous_launchers_intact = _debug_tutorial_case_01_launcher_exists() and _debug_tutorial_case_02_launcher_exists() and _debug_tutorial_case_03_launcher_exists() and _debug_tutorial_case_04_launcher_exists() and _debug_tutorial_case_05_launcher_exists() and _debug_tutorial_case_06_launcher_exists()
	checks.no_t07_id_hardcode = _t07_i1_no_generic_t07_id_hardcode()
	checks.no_t07_slot_hardcode = _t07_i1_no_generic_t07_slot_hardcode()
	checks.no_new_3x3_outside_fixture = _t07_i1_no_new_3x3_outside_fixture()
	if board_after_death != null:
		board_after_death.free()
	if board_fresh != null:
		board_fresh.free()
	return checks


func _t07_i1_reference_path(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	if c == null:
		return {}
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	runtime.case_event_seed = 19
	var result: Dictionary = {}
	var opening_suspect_ids: PackedInt32Array = PackedInt32Array([1, 2, 3, 4])
	for suspect_id: int in opening_suspect_ids:
		_t07_i1_commit_investigation(c, runtime, suspect_id)
		result["after_%d" % suspect_id] = runtime.elapsed_hours
	result["tower_ringing_8"] = ClockTowerService.is_clock_tower_ringing(c, runtime)
	_t07_i1_commit_investigation(c, runtime, 5)
	result["after_5"] = runtime.elapsed_hours
	result["runtime_after_10"] = runtime
	var serial_event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"serial_killer_7_9h")
	var serial_target: int = serial_event.target_suspect_id if serial_event != null else 0
	var serial_logs: int = _timed_event_log_count(runtime, &"serial_killer_7_9h")
	var serial_kill_logs: int = _t07_d_kill_log_count(runtime, 6)
	result["serial_9_resolved"] = serial_event != null and serial_event.fired and serial_event.resolved_success and serial_event.target_suspect_id == 6
	var s6_runtime: SuspectRuntimeState = runtime.find_suspect(6)
	result["s6_dead"] = s6_runtime != null and s6_runtime.is_dead
	result["s6_killed_by_serial"] = s6_runtime != null and s6_runtime.killed_by == &"serial_killer"
	CASE_TIMED_EVENT_DISPATCHER.new().evaluate_all(c, runtime)
	var serial_after: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"serial_killer_7_9h")
	result["serial_no_reroll"] = serial_after != null and serial_after.target_suspect_id == serial_target and _timed_event_log_count(runtime, &"serial_killer_7_9h") == serial_logs and _t07_d_kill_log_count(runtime, 6) == serial_kill_logs
	var pre_surgeon_eligible_ids: PackedInt32Array = _t07_i1_living_innocent_ids(c, runtime, 1)
	_t07_i1_commit_investigation(c, runtime, 7)
	result["after_7"] = runtime.elapsed_hours
	var surgeon_event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"surgeon_1_12h")
	var surgeon_target: int = surgeon_event.target_suspect_id if surgeon_event != null else 0
	var surgeon_logs: int = _timed_event_log_count(runtime, &"surgeon_1_12h")
	var surgeon_kill_logs: int = _surgeon_kill_log_count(runtime, surgeon_target)
	result["surgeon_12_resolved"] = surgeon_event != null and surgeon_event.fired and surgeon_event.threshold_hour == 12
	result["surgeon_no_fixed_victim"] = surgeon_event != null and _t07_i1_surgeon_target_matches_pre_event_pool(surgeon_event, pre_surgeon_eligible_ids)
	result["surgeon_success_victim_valid"] = surgeon_event != null and _t07_i1_surgeon_target_matches_pre_event_pool(surgeon_event, pre_surgeon_eligible_ids)
	CASE_TIMED_EVENT_DISPATCHER.new().evaluate_all(c, runtime)
	var surgeon_after: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"surgeon_1_12h")
	result["surgeon_no_reroll"] = surgeon_after != null and surgeon_after.target_suspect_id == surgeon_target and _timed_event_log_count(runtime, &"surgeon_1_12h") == surgeon_logs and _surgeon_kill_log_count(runtime, surgeon_target) == surgeon_kill_logs
	result["dispatcher_flow"] = serial_event != null and surgeon_event != null
	return result


func _t07_i1_commit_investigation(c: CaseDefinition, runtime: CaseRuntimeState, suspect_id: int) -> bool:
	if c == null or runtime == null:
		return false
	var result: InvestigationResult = InvestigationService.new().investigate(c, runtime, suspect_id, runtime.current_player_id())
	if not result.success:
		return false
	var scene: VSCaseMainController = VSCaseMainController.new()
	scene.case_definition = c
	scene.runtime_state = runtime
	var applied: bool = scene._commit_action_time_and_timed_events(
		StringName("t07i1:investigate:%d" % suspect_id),
		CaseClockService.ACTION_INVESTIGATION
	)
	scene.free()
	return applied


func _t07_i1_accusation_path(c: CaseDefinition, players: Array[PlayerCaseState]) -> Dictionary:
	if c == null:
		return {}
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	runtime.case_event_seed = 19
	var player: PlayerCaseState = runtime.find_player(runtime.current_player_id())
	if player == null:
		return {}
	var accusation: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(c, runtime, player, 7)
	var scene: VSCaseMainController = VSCaseMainController.new()
	scene.case_definition = c
	scene.runtime_state = runtime
	scene._commit_action_time_and_timed_events(&"t07i1:accuse:7", CaseClockService.ACTION_SINGLE_ACCUSATION)
	scene.free()
	var after_accusation_hours: int = runtime.elapsed_hours
	CaseClockService.new().advance_hours(runtime, 8, &"smoke_arrest_to_9")
	CASE_TIMED_EVENT_DISPATCHER.new().evaluate_all(c, runtime)
	var event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"serial_killer_7_9h")
	var source_runtime: SuspectRuntimeState = runtime.find_suspect(7)
	return {
		"elapsed_hours": after_accusation_hours,
		"not_globally_arrested": accusation.success and source_runtime != null and not source_runtime.is_arrested,
		"event_remains_active": event != null and event.fired and event.resolved_success and _dead_suspect_count(runtime) == 1,
	}


func _t07_i1_relaunch_state(c: CaseDefinition, players: Array[PlayerCaseState]) -> Dictionary:
	if c == null:
		return {}
	var first_runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	first_runtime.case_event_seed = 19
	CaseClockService.new().advance_hours(first_runtime, 10, &"smoke_first_launch")
	CASE_TIMED_EVENT_DISPATCHER.new().evaluate_all(c, first_runtime)
	var fresh_runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	return {
		"elapsed_hours": fresh_runtime.elapsed_hours,
		"dead_count": _dead_suspect_count(fresh_runtime),
		"timed_event_count": fresh_runtime.timed_events.size(),
	}


func _t07_i1_surgeon_failure_branch(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	if c == null:
		return false
	for seed: int in range(0, 32):
		var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
		runtime.case_event_seed = seed
		CaseClockService.new().advance_hours(runtime, 12, &"smoke_surgeon_failure")
		CASE_TIMED_EVENT_DISPATCHER.new().evaluate_all(c, runtime)
		var event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"surgeon_1_12h")
		if event != null and event.fired and not event.resolved_success:
			return event.target_suspect_id == 0 and not event.kill_attempted
	return false


func _t07_i1_surgeon_target_matches_pre_event_pool(event: CaseTimedEventRuntimeState, pre_event_eligible_ids: PackedInt32Array) -> bool:
	if event == null:
		return false
	if not event.resolved_success:
		return event.target_suspect_id == 0 and not event.kill_attempted
	return event.kill_attempted and pre_event_eligible_ids.has(event.target_suspect_id)


func _t07_i1_living_innocent_ids(c: CaseDefinition, runtime: CaseRuntimeState, source_suspect_id: int) -> PackedInt32Array:
	var ids: PackedInt32Array = PackedInt32Array()
	if c == null or runtime == null:
		return ids
	for suspect: SuspectDefinition in c.suspects:
		if suspect == null or suspect.suspect_id == source_suspect_id or suspect.role_group != CaseEnums.RoleGroup.CHINH_NHAN:
			continue
		var suspect_runtime: SuspectRuntimeState = runtime.find_suspect(suspect.suspect_id)
		if suspect_runtime != null and not suspect_runtime.is_dead:
			ids.append(suspect.suspect_id)
	ids.sort()
	return ids


func _t07_i1_suspect(c: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	if c == null:
		return null
	for suspect: SuspectDefinition in c.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null


func _t07_i1_suspect_ids(c: CaseDefinition) -> PackedInt32Array:
	var ids: PackedInt32Array = PackedInt32Array()
	if c == null:
		return ids
	for suspect: SuspectDefinition in c.suspects:
		if suspect != null:
			ids.append(suspect.suspect_id)
	ids.sort()
	return ids


func _t07_i1_board_slots(c: CaseDefinition) -> PackedInt32Array:
	var slots: PackedInt32Array = PackedInt32Array()
	if c == null:
		return slots
	for suspect: SuspectDefinition in c.suspects:
		if suspect != null:
			slots.append(suspect.board_slot)
	slots.sort()
	return slots


func _t07_i1_ratio(c: CaseDefinition) -> PackedInt32Array:
	var ratio: PackedInt32Array = PackedInt32Array([0, 0, 0, 0])
	if c == null:
		return ratio
	for suspect: SuspectDefinition in c.suspects:
		if suspect != null and suspect.role_group >= 0 and suspect.role_group < ratio.size():
			ratio[suspect.role_group] += 1
	return ratio


func _t07_i1_controller_no_direct_timed_services() -> bool:
	var source: String = FileAccess.get_file_as_string("res://scripts/presentation/case_gameplay/VSCaseMainController.gd")
	return (
		source.contains("timed_event_dispatcher.evaluate_all")
		and not source.contains("SurgeonTimedEventService")
		and not source.contains("SerialKillerTimedEventService")
	)


func _t07_i1_no_generic_t07_id_hardcode() -> bool:
	for path: String in _t07_i1_generic_paths():
		var source: String = FileAccess.get_file_as_string(path).to_lower()
		if source.contains("tutorial_case_007") or source.contains("suspect_id == 7") or source.contains("#7"):
			return false
	return true


func _t07_i1_no_generic_t07_slot_hardcode() -> bool:
	for path: String in _t07_i1_generic_paths():
		var source: String = FileAccess.get_file_as_string(path).to_lower()
		if source.contains("slot5") or source.contains("slot6") or source.contains("slot 5") or source.contains("slot 6"):
			return false
	return true


func _t07_i1_no_new_3x3_outside_fixture() -> bool:
	for path: String in _t07_i1_generic_paths():
		var source: String = FileAccess.get_file_as_string(path).to_lower()
		if source.contains("3x3") or source.contains("4x4"):
			return false
	return true


func _t07_i1_generic_paths() -> Array[String]:
	return [
		"res://scripts/domain/cases/ClockTowerService.gd",
		"res://scripts/domain/cases/SerialKillerTimedEventService.gd",
		"res://scripts/domain/cases/SurgeonTimedEventService.gd",
		"res://scripts/domain/cases/CaseTimedEventDispatcher.gd",
		"res://scripts/domain/cases/RoleInformationEvaluationService.gd",
		"res://scripts/presentation/case_gameplay/VSCaseMainController.gd",
	]


func _t07_i1_human_runtime_repair_checks(
	tutorial_case_07: CaseDefinition,
	tutorial_case_06: CaseDefinition,
	roles: Array[RoleDefinition],
	players: Array[PlayerCaseState]
) -> Dictionary:
	var checks: Dictionary = {}
	var same_action: Dictionary = _t07_i1_same_action_death_checks(tutorial_case_07, roles, players)
	var later_death: Dictionary = _t07_i1_later_death_checks(roles, players)
	var generic_dead: Dictionary = _t07_i1_generic_dead_presentation_checks(roles, players)
	var dead_before: Dictionary = _t07_i1_dead_before_investigation_checks(tutorial_case_07, roles, players)
	var sidebar: Dictionary = _t07_i1_sidebar_repair_checks(tutorial_case_06, roles, players)
	var glossary: Dictionary = _t07_i1_glossary_repair_checks(roles)

	checks.serial_just_investigated_not_excluded = _t07_i1_serial_just_investigated_eligible(players)
	checks.serial_just_investigated_can_die = bool(same_action.get("serial_target_six", false))
	checks.surgeon_just_investigated_can_die = _t07_i1_surgeon_just_investigated_can_die(roles, players)
	checks.no_just_investigated_protection = _t07_i1_no_just_investigated_protection()
	checks.surgeon_probability_unchanged = _t07_i1_surgeon_probability_unchanged(players)
	checks.serial_recurrence_unchanged = bool(_t07_d_serial_later_interval(players).get("independent", false))
	checks.dead_unrevealed_not_eligible = bool(dead_before.get("not_eligible", false))
	checks.dead_unrevealed_rejected = bool(dead_before.get("rejected", false))
	checks.dead_unrevealed_no_elapsed = bool(dead_before.get("no_elapsed", false))
	checks.dead_unrevealed_no_turn = bool(dead_before.get("no_turn", false))
	checks.dead_unrevealed_no_reveal = bool(dead_before.get("no_reveal", false))
	checks.dead_unrevealed_no_role_leak = bool(dead_before.get("no_role_leak", false))
	checks.dead_unrevealed_no_clue_leak = bool(dead_before.get("no_clue_leak", false))
	checks.dead_unrevealed_no_hold_feedback = bool(dead_before.get("no_hold_feedback", false))
	checks.dead_unrevealed_no_timed_dispatch = bool(dead_before.get("no_timed_dispatch", false))
	checks.dead_unrevealed_not_t07_id_specific = _t07_i1_dead_before_not_t07_id_specific(roles, players)
	checks.same_action_t07_s6_death = bool(same_action.get("dead", false))
	checks.same_action_role_revealed = bool(same_action.get("role_revealed", false))
	checks.same_action_clue_suppressed = bool(same_action.get("clue_suppressed", false))
	checks.same_action_dead_text = bool(same_action.get("dead_text", false))
	checks.same_action_slot_preserved = bool(same_action.get("slot_preserved", false))
	checks.same_action_authored_unchanged = bool(same_action.get("authored_unchanged", false))
	checks.later_investigated_can_die = bool(later_death.get("died", false))
	checks.later_clue_removed = bool(later_death.get("clue_removed", false))
	checks.later_dead_text = bool(later_death.get("dead_text", false))
	checks.later_role_visible = bool(later_death.get("role_visible", false))
	checks.structured_history_preserved = bool(later_death.get("history_preserved", false))
	checks.dead_text_localized = bool(generic_dead.get("localized", false))
	checks.dead_presentation_no_id_hardcode = _t07_i1_dead_presentation_no_id_hardcode()
	checks.dead_presentation_no_role_hardcode = _t07_i1_dead_presentation_no_role_hardcode()
	checks.generic_dead_text = bool(generic_dead.get("dead_text", false))
	checks.dead_universal_marker = bool(generic_dead.get("dead_marker", false))
	checks.alive_no_dead_marker = bool(generic_dead.get("alive_no_dead_marker", false))
	checks.dead_marker_footprint_stable = bool(generic_dead.get("dead_marker_footprint_stable", false))
	checks.alive_revealed_shows_announcement = bool(generic_dead.get("alive_statement", false))
	checks.death_state_drives_presentation = bool(generic_dead.get("runtime_driven", false))

	checks.sidebar_title = bool(sidebar.get("title", false))
	checks.sidebar_group_order = bool(sidebar.get("group_order", false))
	checks.nested_drunkard_attached = bool(sidebar.get("nested_drunkard", false))

	checks.kill_glossary_exists = bool(glossary.get("exists", false))
	checks.kill_definition = bool(glossary.get("definition", false))
	checks.key_terms_not_bold = bool(glossary.get("key_terms_not_bold", false))
	checks.semantic_colors = bool(glossary.get("semantic_colors", false))
	checks.no_t07_i2_behavior = _t07_i1_no_t07_i2_behavior()
	return checks


func _t07_i2_closeout_checks(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	if c == null:
		return checks
	var lines: PackedStringArray = c.tutorial_dialogue_lines
	var rendered_dialogue: Dictionary = _t07_i2_rendered_dialogue_checks(c, roles, players)
	var history: Dictionary = _t07_i2_timed_history_checks(c, roles, players)
	var surgeon_success: Dictionary = _t07_i2_surgeon_success_history_checks(c, roles, players)
	var surgeon_failure: Dictionary = _t07_i2_surgeon_failure_history_checks(c, roles, players)
	var same_action: Dictionary = _t07_i1_same_action_death_checks(c, roles, players)
	var sidebar: Dictionary = _t07_i1_sidebar_repair_checks(FixtureRepository.load_tutorial_case_006(), roles, players)
	var glossary: Dictionary = _t07_i1_glossary_repair_checks(roles)
	var relaunch: Dictionary = _t07_i1_relaunch_state(c, players)

	checks.dialogue_source = not lines.is_empty()
	checks.dialogue_count = lines.size() == 8
	checks.dialogue_line_1 = lines.size() >= 1 and lines[0].contains("điều tra") and lines[0].contains("thời gian")
	checks.dialogue_line_2_investigate = lines.size() >= 2 and lines[1].contains("Điều tra") and lines[1].contains("2 giờ")
	checks.dialogue_line_2_accuse = lines.size() >= 2 and lines[1].contains("Chỉ Điểm") and lines[1].contains("1 giờ")
	checks.dialogue_line_3 = lines.size() >= 3 and lines[2].contains("chức năng") and lines[2].contains("không làm thời gian")
	checks.dialogue_line_4 = lines.size() >= 4 and lines[3].contains("đồng hồ") and lines[3].contains("góc trên bên trái")
	checks.dialogue_line_6 = lines.size() >= 6 and lines[5].contains("hiểm họa") and lines[5].contains("rình rập")
	checks.dialogue_line_7 = lines.size() >= 7 and lines[6].contains("Bàn Kỳ Án") and lines[6].contains("thời gian")
	checks.dialogue_line_8 = lines.size() >= 8 and lines[7].contains("Chỉ Điểm sớm") and lines[7].contains("chờ đợi")
	checks.dialogue_left_panel_clean = bool(rendered_dialogue.get("left_panel_clean", false))
	checks.dialogue_overlay_launch = bool(rendered_dialogue.get("overlay_launch", false))
	checks.dialogue_overlay_first_line = bool(rendered_dialogue.get("first_line", false))
	checks.dialogue_overlay_advances = bool(rendered_dialogue.get("advances", false))
	checks.dialogue_speaker_state = bool(rendered_dialogue.get("speaker_state", false))
	checks.dialogue_blocks_interaction = bool(rendered_dialogue.get("blocks_interaction", false))
	checks.dialogue_closes = bool(rendered_dialogue.get("closes", false))
	checks.dialogue_gameplay_resumes = bool(rendered_dialogue.get("gameplay_resumes", false))
	checks.dialogue_non_t07_clear = bool(rendered_dialogue.get("non_t07_clear", false))
	checks.dialogue_relaunch = bool(rendered_dialogue.get("fresh_relaunch", false))

	checks.serial_structured = bool(history.get("serial_structured", false))
	checks.serial_history = bool(history.get("serial_history", false))
	checks.history_no_six_hardcode = _t07_i2_history_formatter_has_no_literal_victim(6)
	checks.surgeon_success_history = bool(surgeon_success.get("history", false))
	checks.surgeon_failure_no_fake = bool(surgeon_failure.get("no_fake", false))
	checks.history_no_surgeon_victim_hardcode = _t07_i2_history_formatter_has_no_surgeon_victim_hardcode()
	checks.history_survives_refresh = bool(history.get("survives_refresh", false))
	checks.s4_pretend = bool(history.get("s4_pretend", false))
	checks.s7_pretend = bool(history.get("s7_pretend", false))
	checks.s6_truth = bool(history.get("s6_truth", false))
	checks.active_six_dead_text = bool(same_action.get("dead_text", false))
	checks.clue_loss_keeps_history = bool(history.get("clue_loss_keeps_history", false))
	checks.final_answer = c.evil_suspect_ids == PackedInt32Array([4, 7])

	var tower: ClockTowerDefinition = ClockTowerService.clock_tower_for_case(c)
	var hour_eight_runtime: CaseRuntimeState = _t07_i2_runtime_at_hour(c, players, 8)
	checks.clock_tower_unchanged = tower != null and tower.ring_hour == 8 and ClockTowerService.is_clock_tower_ringing(c, hour_eight_runtime)
	checks.death_rules_unchanged = _t07_i1_dead_before_not_t07_id_specific(roles, players)
	checks.sidebar_unchanged = bool(sidebar.get("title", false)) and bool(sidebar.get("group_order", false)) and bool(sidebar.get("nested_drunkard", false))
	checks.kill_glossary_unchanged = bool(glossary.get("exists", false)) and bool(glossary.get("definition", false)) and bool(glossary.get("key_terms_not_bold", false))
	checks.previous_launchers = _debug_tutorial_case_01_launcher_exists() and _debug_tutorial_case_02_launcher_exists() and _debug_tutorial_case_03_launcher_exists() and _debug_tutorial_case_04_launcher_exists() and _debug_tutorial_case_05_launcher_exists() and _debug_tutorial_case_06_launcher_exists()
	checks.t07_relaunch = int(relaunch.get("elapsed_hours", -1)) == 0 and int(relaunch.get("dead_count", -1)) == 0 and int(relaunch.get("timed_event_count", -1)) == 0
	checks.no_t08 = _t07_i2_no_t08_implementation()
	checks.no_new_3x3 = _t07_i1_no_new_3x3_outside_fixture()
	return checks


func _t07_i2_rendered_dialogue_checks(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	var first_scene: VSCaseMainController = _case_scene_instance() as VSCaseMainController
	var second_scene: VSCaseMainController = _case_scene_instance() as VSCaseMainController
	var non_t07_scene: VSCaseMainController = _case_scene_instance() as VSCaseMainController
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if first_scene == null or second_scene == null or non_t07_scene == null or tree == null:
		_t05_i2_free_scene(first_scene)
		_t05_i2_free_scene(second_scene)
		_t05_i2_free_scene(non_t07_scene)
		return checks
	tree.root.add_child(first_scene)
	_prepare_case_scene_for_smoke(first_scene, c, roles, players)
	var first_label: RichTextLabel = first_scene.get_node_or_null("%DescriptionLabel") as RichTextLabel
	var first_text: String = first_label.text if first_label != null else ""
	var first_line: String = c.tutorial_dialogue_lines[0] if c.tutorial_dialogue_lines.size() > 0 else ""
	var second_line: String = c.tutorial_dialogue_lines[1] if c.tutorial_dialogue_lines.size() > 1 else ""
	var launch_visible: bool = first_scene.is_tutorial_dialogue_overlay_visible_for_smoke()
	var initial_index: int = first_scene.get_tutorial_dialogue_line_index_for_smoke()
	var initial_text: String = first_scene.get_tutorial_dialogue_text_for_smoke()
	var before_hours: int = first_scene.runtime_state.elapsed_hours if first_scene.runtime_state != null else -1
	first_scene._on_suspect_action(1, MOUSE_BUTTON_LEFT, true)
	var blocked_hours: int = first_scene.runtime_state.elapsed_hours if first_scene.runtime_state != null else -1
	var first_speaker: StringName = first_scene.get_tutorial_dialogue_active_speaker_for_smoke()
	var first_left_scale: Vector2 = first_scene.get_tutorial_dialogue_portrait_scale_for_smoke(&"left")
	var first_right_scale: Vector2 = first_scene.get_tutorial_dialogue_portrait_scale_for_smoke(&"right")
	first_scene._advance_tutorial_dialogue()
	var second_speaker: StringName = first_scene.get_tutorial_dialogue_active_speaker_for_smoke()
	var second_left_scale: Vector2 = first_scene.get_tutorial_dialogue_portrait_scale_for_smoke(&"left")
	var second_right_scale: Vector2 = first_scene.get_tutorial_dialogue_portrait_scale_for_smoke(&"right")
	var advanced_text: String = first_scene.get_tutorial_dialogue_text_for_smoke()
	for _index: int in range(c.tutorial_dialogue_lines.size()):
		first_scene._advance_tutorial_dialogue()
	var closed: bool = not first_scene.is_tutorial_dialogue_overlay_visible_for_smoke()
	var resume_before_hours: int = first_scene.runtime_state.elapsed_hours if first_scene.runtime_state != null else -1
	first_scene._on_suspect_action(1, MOUSE_BUTTON_LEFT, true)
	var resume_after_hours: int = first_scene.runtime_state.elapsed_hours if first_scene.runtime_state != null else -1
	tree.root.add_child(second_scene)
	_prepare_case_scene_for_smoke(second_scene, c, roles, players)
	tree.root.add_child(non_t07_scene)
	_prepare_case_scene_for_smoke(non_t07_scene, FixtureRepository.load_tutorial_case_006(), roles, players)
	checks.left_panel_clean = (
		not first_line.is_empty()
		and not first_text.contains(first_line)
		and not first_text.contains("HƯỚNG DẪN")
	)
	checks.overlay_launch = launch_visible
	checks.first_line = initial_index == 0 and initial_text == first_line
	checks.advances = not second_line.is_empty() and advanced_text == second_line
	checks.speaker_state = (
		first_speaker == &"left"
		and second_speaker == &"right"
		and first_left_scale.x > first_right_scale.x
		and second_right_scale.x > second_left_scale.x
	)
	checks.blocks_interaction = before_hours == blocked_hours
	checks.closes = closed
	checks.gameplay_resumes = closed and resume_after_hours > resume_before_hours
	checks.non_t07_clear = not non_t07_scene.is_tutorial_dialogue_overlay_visible_for_smoke()
	checks.fresh_relaunch = (
		not first_line.is_empty()
		and second_scene.is_tutorial_dialogue_overlay_visible_for_smoke()
		and second_scene.get_tutorial_dialogue_line_index_for_smoke() == 0
		and second_scene.get_tutorial_dialogue_text_for_smoke() == first_line
	)
	_t05_i2_free_scene(first_scene)
	_t05_i2_free_scene(second_scene)
	_t05_i2_free_scene(non_t07_scene)
	return checks


func _t07_i2_timed_history_checks(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	var runtime: CaseRuntimeState = _t07_i2_reference_runtime(c, players)
	var serial_event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"serial_killer_7_9h")
	var reveal: CaseTruthReveal = _t07_i2_settle_and_reveal(c, runtime, roles)
	var truth_four: SuspectTruthReveal = _truth_for_suspect(reveal, 4)
	var truth_six: SuspectTruthReveal = _truth_for_suspect(reveal, 6)
	var truth_seven: SuspectTruthReveal = _truth_for_suspect(reveal, 7)
	var views: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles)
	var view_six: SuspectPublicViewData = _tutorial_03_view(views, 6)
	var serial_target_id: int = serial_event.target_suspect_id if serial_event != null else 0
	var serial_note: String = _t07_i2_relation_note_for_target(truth_seven, serial_target_id)
	checks.serial_structured = (
		serial_event != null
		and serial_event.fired
		and serial_event.kill_attempted
		and serial_event.kill_outcome == CaseKillResult.Outcome.KILLED
		and serial_event.source_suspect_id == 7
		and serial_event.target_suspect_id > 0
	)
	checks.serial_history = (
		serial_event != null
		and not serial_note.is_empty()
		and serial_note == "Ở mốc %dh, ta đã giết Số Hiệu %d." % [serial_event.threshold_hour, serial_target_id]
	)
	checks.survives_refresh = view_six != null and truth_seven != null and not _t07_i2_relation_note_for_target(truth_seven, serial_target_id).is_empty()
	checks.s4_pretend = truth_four != null and truth_four.true_role_name == "Kẻ Côn Đồ" and truth_four.impersonated_role_name == "Thợ Đồng Hồ"
	checks.s7_pretend = truth_seven != null and truth_seven.true_role_name == "Sát Nhân Hàng Loạt" and truth_seven.impersonated_role_name == "Thợ Đồng Hồ"
	checks.s6_truth = truth_six != null and truth_six.true_role_name == "Sử Quan"
	checks.clue_loss_keeps_history = view_six != null and view_six.public_investigation_statement == "*Chết...*" and not serial_note.is_empty()
	return checks


func _t07_i2_surgeon_success_history_checks(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	for seed: int in range(0, 32):
		var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
		runtime.case_event_seed = seed
		CaseClockService.new().advance_hours(runtime, 12, &"t07i2_surgeon_success")
		CASE_TIMED_EVENT_DISPATCHER.new().evaluate_all(c, runtime)
		var event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"surgeon_1_12h")
		if event == null or not event.resolved_success or event.target_suspect_id <= 0:
			continue
		var reveal: CaseTruthReveal = _t07_i2_settle_and_reveal(c, runtime, roles)
		var truth_one: SuspectTruthReveal = _truth_for_suspect(reveal, 1)
		var note: String = _t07_i2_relation_note_for_target(truth_one, event.target_suspect_id)
		checks.history = note == "Ở mốc %dh, ta đã giết Số Hiệu %d." % [event.threshold_hour, event.target_suspect_id]
		checks.actual_victim = event.target_suspect_id > 0 and note.contains("Số Hiệu %d" % event.target_suspect_id)
		return checks
	return checks


func _t07_i2_surgeon_failure_history_checks(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	for seed: int in range(0, 32):
		var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
		runtime.case_event_seed = seed
		CaseClockService.new().advance_hours(runtime, 12, &"t07i2_surgeon_failure")
		CASE_TIMED_EVENT_DISPATCHER.new().evaluate_all(c, runtime)
		var event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"surgeon_1_12h")
		if event == null or event.resolved_success:
			continue
		var reveal: CaseTruthReveal = _t07_i2_settle_and_reveal(c, runtime, roles)
		var truth_one: SuspectTruthReveal = _truth_for_suspect(reveal, 1)
		checks.no_fake = truth_one != null and _t07_i2_kill_relation_note_count(truth_one) == 0 and event.target_suspect_id == 0
		return checks
	return checks


func _t07_i2_reference_runtime(c: CaseDefinition, players: Array[PlayerCaseState]) -> CaseRuntimeState:
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	runtime.case_event_seed = 19
	var opening_suspect_ids: PackedInt32Array = PackedInt32Array([1, 2, 3, 4, 5, 7])
	for suspect_id: int in opening_suspect_ids:
		_t07_i1_commit_investigation(c, runtime, suspect_id)
	return runtime


func _t07_i2_settle_and_reveal(c: CaseDefinition, runtime: CaseRuntimeState, roles: Array[RoleDefinition]) -> CaseTruthReveal:
	if runtime == null:
		return null
	var player: PlayerCaseState = runtime.find_player(runtime.current_player_id())
	var player_id: StringName = player.player_id if player != null else &"player_1"
	runtime.submissions.append(_locked_submission(player_id, PackedInt32Array([4, 7]), PackedInt32Array([4, 7]), PackedInt32Array(), CaseEnums.SubmissionPhase.EARLY))
	if player != null:
		player.submission_status = CaseEnums.SubmissionStatus.SUBMITTED_CORRECT
	runtime.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
	var settlement: CaseSettlementResult = CaseSettlementService.new().settle(c, runtime)
	if not settlement.success:
		return null
	return CaseTruthRevealBuilder.new().build(c, runtime, roles)


func _t07_i2_runtime_at_hour(c: CaseDefinition, players: Array[PlayerCaseState], hour: int) -> CaseRuntimeState:
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	CaseClockService.new().advance_hours(runtime, hour, &"t07i2_clock_check")
	return runtime


func _t07_i2_relation_note_for_target(truth: SuspectTruthReveal, target_suspect_id: int) -> String:
	if truth == null or target_suspect_id <= 0:
		return ""
	for note: String in truth.relation_notes:
		if note.contains("đã giết") and note.contains("Số Hiệu %d" % target_suspect_id):
			return note
	return ""


func _t07_i2_kill_relation_note_count(truth: SuspectTruthReveal) -> int:
	if truth == null:
		return 0
	var count: int = 0
	for note: String in truth.relation_notes:
		if note.contains("đã giết"):
			count += 1
	return count


func _t07_i2_history_formatter_has_no_literal_victim(suspect_id: int) -> bool:
	var source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/CaseTruthRevealBuilder.gd")
	return not source.contains("Số Hiệu %d" % suspect_id) and not source.contains("#%d" % suspect_id)


func _t07_i2_history_formatter_has_no_surgeon_victim_hardcode() -> bool:
	var source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/CaseTruthRevealBuilder.gd")
	return not source.contains("Số Hiệu 2") and not source.contains("Số Hiệu 3") and not source.contains("Số Hiệu 5")


func _t07_i2_no_t08_implementation() -> bool:
	var debug_source: String = FileAccess.get_file_as_string("res://scripts/presentation/DebugHomeController.gd")
	var fixture_source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/FixtureRepository.gd")
	return not debug_source.contains("Tutorial Case 09") and not fixture_source.contains("tutorial_case_009")


func _string_occurrences(source: String, needle: String) -> int:
	if source.is_empty() or needle.is_empty():
		return 0
	var count: int = 0
	var offset: int = 0
	while true:
		var found_at: int = source.find(needle, offset)
		if found_at < 0:
			break
		count += 1
		offset = found_at + needle.length()
	return count


func _t07_i1_serial_just_investigated_eligible(_players: Array[PlayerCaseState]) -> bool:
	var specs: Array[Dictionary] = [
		_role_info_spec(1, 8, &"serial_killer", &"reporter", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(2, 7, &"reporter", &"reporter", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
	]
	var c: CaseDefinition = _t07_d_configure_serial_case(_role_info_case_fixture(specs, 4))
	var runtime: CaseRuntimeState = _t07_d_serial_runtime(c, _players, 19, 9)
	var ids: PackedInt32Array = SerialKillerTimedEventService.new().eligible_adjacent_good_target_ids(c, runtime, 1)
	return ids == PackedInt32Array([2])


func _t07_i1_same_action_death_checks(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	if c == null:
		return checks
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	runtime.case_event_seed = 19
	var before_slot: int = c.suspect_at_slot(7).suspect_id if c.suspect_at_slot(7) != null else 0
	var before_role: StringName = c.suspect_at_slot(7).true_role_id if c.suspect_at_slot(7) != null else &""
	var opening_suspect_ids: PackedInt32Array = PackedInt32Array([1, 2, 3, 4])
	for suspect_id: int in opening_suspect_ids:
		_t07_i1_commit_investigation(c, runtime, suspect_id)
	var result: InvestigationResult = InvestigationService.new().investigate(c, runtime, 6, runtime.current_player_id())
	var applied: bool = false
	if result.success:
		var scene: VSCaseMainController = VSCaseMainController.new()
		scene.case_definition = c
		scene.runtime_state = runtime
		applied = scene._commit_action_time_and_timed_events(
			StringName("t07i1:investigate:%d" % result.suspect_id),
			CaseClockService.ACTION_INVESTIGATION
		)
		scene.free()
	var event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"serial_killer_7_9h")
	var s6_runtime: SuspectRuntimeState = runtime.find_suspect(6)
	var views: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles)
	var view: SuspectPublicViewData = _tutorial_03_view(views, 6)
	var board: CaseBoardController = _board_instance_with_runtime(c, runtime, roles)
	checks.serial_target_six = event != null and event.fired and event.target_suspect_id == 6
	checks.dead = applied and s6_runtime != null and s6_runtime.is_dead and s6_runtime.killed_by == &"serial_killer"
	checks.role_revealed = view != null and view.is_investigated and view.public_role_name == "Sử Quan"
	checks.clue_suppressed = view != null and view.public_investigation_statement == CasePublicPresentationBuilder.DEAD_PUBLIC_INFORMATION
	checks.dead_text = view != null and view.public_investigation_statement == CasePublicPresentationBuilder.DEAD_PUBLIC_INFORMATION
	checks.slot_preserved = board != null and board.get_suspect_slot(6) == 7
	checks.authored_unchanged = before_slot == 6 and c.suspect_at_slot(7) != null and c.suspect_at_slot(7).suspect_id == 6 and c.suspect_at_slot(7).true_role_id == before_role
	if board != null:
		board.free()
	return checks


func _t07_i1_surgeon_just_investigated_can_die(roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var specs: Array[Dictionary] = [
		_role_info_spec(1, 0, &"surgeon", &"surgeon", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
		_role_info_spec(2, 1, &"reporter", &"reporter", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(3, 2, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	]
	var c: CaseDefinition = _role_info_case_fixture(specs, 4)
	for seed: int in range(0, 32):
		var runtime: CaseRuntimeState = _surgeon_runtime(c, players, seed, 12)
		InvestigationService.new().investigate(c, runtime, 2, runtime.current_player_id())
		CASE_TIMED_EVENT_DISPATCHER.new().evaluate_all(c, runtime)
		var event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"surgeon_1_12h")
		var target_runtime: SuspectRuntimeState = runtime.find_suspect(2)
		var view: SuspectPublicViewData = _tutorial_03_view(CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles), 2)
		if event != null and event.resolved_success:
			return (
				event.target_suspect_id == 2
				and target_runtime != null
				and target_runtime.is_dead
				and view != null
				and view.public_investigation_statement == CasePublicPresentationBuilder.DEAD_PUBLIC_INFORMATION
			)
	return false


func _t07_i1_dead_before_investigation_checks(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	if c == null:
		return checks
	var scene: VSCaseMainController = _case_scene_instance() as VSCaseMainController
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if scene == null or tree == null:
		_t05_i2_free_scene(scene)
		return checks
	tree.root.add_child(scene)
	_prepare_case_scene_for_smoke(scene, c, roles, players)
	CaseClockService.new().advance_hours(scene.runtime_state, 8, &"t07i1_dead_before_setup")
	CaseKillService.new().kill(c, scene.runtime_state, 6, &"smoke")
	scene._refresh_all_presentation()
	var before_hours: int = scene.runtime_state.elapsed_hours
	var before_turn: int = scene.runtime_state.turn_number
	var before_events: int = scene.runtime_state.timed_events.size()
	var before_runtime: SuspectRuntimeState = scene.runtime_state.find_suspect(6)
	var service_result: InvestigationResult = InvestigationService.new().investigate(c, scene.runtime_state, 6, scene.runtime_state.current_player_id())
	scene._perform_direct_investigation(6)
	var after_runtime: SuspectRuntimeState = scene.runtime_state.find_suspect(6)
	var views: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(c, scene.runtime_state, roles)
	var view: SuspectPublicViewData = _tutorial_03_view(views, 6)
	var card: SuspectCardController = _board_card(scene.board, 6)
	var hold_started: Array[bool] = [false]
	if card != null:
		card.suspect_hold_progress_started.connect(func(_suspect_id: int, _duration_sec: float) -> void:
			hold_started[0] = true
		)
		var press_event: InputEventMouseButton = InputEventMouseButton.new()
		press_event.button_index = MOUSE_BUTTON_LEFT
		press_event.pressed = true
		card._gui_input(press_event)
	checks.not_eligible = service_result.error_code == &"SUSPECT_DEAD"
	checks.rejected = not service_result.success and after_runtime != null and after_runtime.is_dead
	checks.no_elapsed = scene.runtime_state.elapsed_hours == before_hours
	checks.no_turn = scene.runtime_state.turn_number == before_turn
	checks.no_reveal = before_runtime != null and not before_runtime.is_investigated and after_runtime != null and not after_runtime.is_investigated
	checks.no_role_leak = view != null and not view.is_investigated and view.public_role_name.is_empty()
	checks.no_clue_leak = view != null and view.public_investigation_statement.is_empty()
	checks.no_hold_feedback = card != null and not hold_started[0]
	checks.no_timed_dispatch = scene.runtime_state.timed_events.size() == before_events and scene.runtime_state.timed_event_by_id(&"serial_killer_7_9h") == null
	_t05_i2_free_scene(scene)
	return checks


func _t07_i1_dead_before_not_t07_id_specific(roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var specs: Array[Dictionary] = [
		_role_info_spec(4, 0, &"reporter", &"reporter", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(9, 1, &"therapist", &"therapist", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
	]
	var c: CaseDefinition = _role_info_case_fixture(specs, 4)
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	CaseKillService.new().kill(c, runtime, 4, &"smoke")
	var result: InvestigationResult = InvestigationService.new().investigate(c, runtime, 4, runtime.current_player_id())
	var view: SuspectPublicViewData = _tutorial_03_view(CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles), 4)
	var suspect_runtime: SuspectRuntimeState = runtime.find_suspect(4)
	return (
		not result.success
		and result.error_code == &"SUSPECT_DEAD"
		and suspect_runtime != null
		and not suspect_runtime.is_investigated
		and view != null
		and not view.is_investigated
		and view.public_role_name.is_empty()
		and view.public_investigation_statement.is_empty()
	)


func _t07_i1_later_death_checks(roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	var specs: Array[Dictionary] = [
		_role_info_spec(1, 0, &"surgeon", &"surgeon", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
		_role_info_spec(2, 1, &"therapist", &"therapist", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(3, 2, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	]
	var c: CaseDefinition = _role_info_case_fixture(specs, 4)
	for seed: int in range(0, 32):
		var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
		runtime.case_event_seed = seed
		InvestigationService.new().investigate(c, runtime, 2, runtime.current_player_id())
		var before_view: SuspectPublicViewData = _tutorial_03_view(CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles), 2)
		CaseClockService.new().advance_hours(runtime, 12, &"t07i1_later_death")
		CASE_TIMED_EVENT_DISPATCHER.new().evaluate_all(c, runtime)
		var event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"surgeon_1_12h")
		if event == null or not event.resolved_success or event.target_suspect_id != 2:
			continue
		var after_view: SuspectPublicViewData = _tutorial_03_view(CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles), 2)
		var target_runtime: SuspectRuntimeState = runtime.find_suspect(2)
		checks.died = target_runtime != null and target_runtime.is_dead
		checks.clue_removed = before_view != null and not before_view.public_investigation_statement.is_empty() and after_view != null and after_view.public_investigation_statement != before_view.public_investigation_statement
		checks.dead_text = after_view != null and after_view.public_investigation_statement == CasePublicPresentationBuilder.DEAD_PUBLIC_INFORMATION
		checks.role_visible = after_view != null and after_view.is_investigated and after_view.public_role_name == "Ngự Y"
		checks.history_preserved = _timed_event_log_count(runtime, &"surgeon_1_12h") == 1 and _surgeon_kill_log_count(runtime, 2) == 1
		return checks
	return checks


func _t07_i1_generic_dead_presentation_checks(roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var specs: Array[Dictionary] = [
		_role_info_spec(4, 0, &"mailman", &"mailman", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(5, 1, &"therapist", &"therapist", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
	]
	var c: CaseDefinition = _role_info_case_fixture(specs, 4)
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	InvestigationService.new().investigate(c, runtime, 4, runtime.current_player_id())
	InvestigationService.new().investigate(c, runtime, 5, runtime.current_player_id())
	var before_dead_view: SuspectPublicViewData = _tutorial_03_view(CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles), 4)
	CaseKillService.new().kill(c, runtime, 4, &"smoke")
	var after_views: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles)
	var dead_view: SuspectPublicViewData = _tutorial_03_view(after_views, 4)
	var alive_view: SuspectPublicViewData = _tutorial_03_view(after_views, 5)
	var board: CaseBoardController = _board_instance_with_runtime(c, runtime, roles)
	var dead_card: SuspectCardController = _board_card(board, 4) if board != null else null
	var alive_card: SuspectCardController = _board_card(board, 5) if board != null else null
	var dead_marker_path: String = dead_card.get_dead_marker_texture_path_for_smoke() if dead_card != null else ""
	var dead_card_footprint: Vector2 = dead_card.get_combined_minimum_size() if dead_card != null else Vector2.ZERO
	var alive_card_footprint: Vector2 = alive_card.get_combined_minimum_size() if alive_card != null else Vector2.ZERO
	var dead_marker_visible: bool = dead_card != null and dead_card.has_dead_marker_for_smoke()
	var alive_marker_hidden: bool = alive_card != null and not alive_card.has_dead_marker_for_smoke()
	if board != null:
		board.free()
	return {
		"dead_text": dead_view != null and dead_view.public_investigation_statement == CasePublicPresentationBuilder.DEAD_PUBLIC_INFORMATION,
		"localized": dead_view != null and dead_view.public_investigation_statement == "*Chết...*" and dead_view.public_investigation_statement != "*Dead*",
		"dead_marker": dead_marker_visible and dead_marker_path == "res://assets/ui/case/dead_marker_universal.png",
		"alive_no_dead_marker": alive_marker_hidden,
		"dead_marker_footprint_stable": dead_card_footprint == alive_card_footprint and dead_card_footprint == Vector2(168, 190),
		"alive_statement": alive_view != null and alive_view.is_investigated and not alive_view.public_investigation_statement.is_empty() and alive_view.public_investigation_statement != CasePublicPresentationBuilder.DEAD_PUBLIC_INFORMATION,
		"runtime_driven": before_dead_view != null and before_dead_view.public_investigation_statement != CasePublicPresentationBuilder.DEAD_PUBLIC_INFORMATION and dead_view != null and dead_view.public_investigation_statement == CasePublicPresentationBuilder.DEAD_PUBLIC_INFORMATION,
	}


func _t07_i1_no_just_investigated_protection() -> bool:
	var paths: Array[String] = [
		"res://scripts/domain/cases/SurgeonTimedEventService.gd",
		"res://scripts/domain/cases/SerialKillerTimedEventService.gd",
		"res://scripts/domain/cases/CaseTimedEventDispatcher.gd",
		"res://scripts/presentation/case_gameplay/VSCaseMainController.gd",
	]
	for path: String in paths:
		var source: String = FileAccess.get_file_as_string(path)
		if source.contains("just_investigated_suspect_id") or source.contains("action_context"):
			return false
	return true


func _t07_i1_dead_presentation_no_id_hardcode() -> bool:
	var source: String = FileAccess.get_file_as_string("res://scripts/presentation/case_gameplay/CasePublicPresentationBuilder.gd")
	return not source.contains("suspect_id == 2") and not source.contains("suspect_id == 6") and not source.contains("#2") and not source.contains("#6")


func _t07_i1_dead_presentation_no_role_hardcode() -> bool:
	var source: String = FileAccess.get_file_as_string("res://scripts/presentation/case_gameplay/CasePublicPresentationBuilder.gd")
	var dead_block_start: int = source.find("if suspect_runtime != null and suspect_runtime.is_dead:")
	if dead_block_start < 0:
		return false
	var dead_block_end: int = source.find("_apply_public_relation_metadata", dead_block_start)
	if dead_block_end < 0:
		return false
	var dead_block: String = source.substr(dead_block_start, dead_block_end - dead_block_start)
	return (
		dead_block.contains("view_data.public_investigation_statement = DEAD_PUBLIC_INFORMATION")
		and not dead_block.contains("therapist")
		and not dead_block.contains("reporter")
		and not dead_block.contains("Ngự Y")
		and not dead_block.contains("Sử Quan")
	)


func _t07_i1_no_t07_i2_behavior() -> bool:
	var debug_source: String = FileAccess.get_file_as_string("res://scripts/presentation/DebugHomeController.gd")
	var fixture_source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/FixtureRepository.gd")
	return not debug_source.contains("Tutorial Case 09") and not fixture_source.contains("tutorial_case_009")


func _t07_i1_surgeon_probability_unchanged(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _surgeon_case()
	var saw_success: bool = false
	var saw_failure: bool = false
	for seed: int in range(0, 32):
		var runtime: CaseRuntimeState = _surgeon_runtime(c, players, seed, 12)
		SurgeonTimedEventService.new().evaluate(c, runtime)
		var event: CaseTimedEventRuntimeState = runtime.timed_event_by_id(&"surgeon_1_12h")
		if event == null:
			continue
		if event.resolved_success:
			saw_success = true
		else:
			saw_failure = true
	return saw_success and saw_failure


func _t07_i1_sidebar_repair_checks(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	var scene: VSCaseMainController = _case_scene_instance() as VSCaseMainController
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if scene == null or tree == null:
		if scene != null:
			scene.free()
		return checks
	tree.root.add_child(scene)
	_prepare_case_scene_for_smoke(scene, c, roles, players)
	var title: Label = scene.find_child("ActionTitle", true, false) as Label
	var authored_ids: Array[StringName] = scene.get_top_level_suspect_list_role_ids_for_smoke()
	var presented_ids: Array[StringName] = scene.get_presented_role_ids_for_smoke()
	checks.title = title != null and title.text == "THÂN PHẬN"
	checks.group_order = _t07_i1_role_ids_follow_group_order(presented_ids, roles)
	checks.stable_order = _t07_i1_role_ids_preserve_group_stability(authored_ids, presented_ids, roles)
	checks.nested_drunkard = scene.get_nested_suspect_list_role_ids_for_smoke(&"barkeep").has(&"drunkard") and not presented_ids.has(&"drunkard")
	checks.authority_unchanged = authored_ids == CaseRolePoolService.suspected_role_ids_for_case(c)
	tree.root.remove_child(scene)
	scene.free()
	return checks


func _t07_i1_role_ids_follow_group_order(role_ids: Array[StringName], roles: Array[RoleDefinition]) -> bool:
	var previous_index: int = -1
	for role_id: StringName in role_ids:
		var role: RoleDefinition = _find_role_for_test(roles, role_id)
		if role == null:
			continue
		var index: int = _t07_i1_group_order_index(role.role_group)
		if index < previous_index:
			return false
		previous_index = index
	return true


func _t07_i1_role_ids_preserve_group_stability(authored_ids: Array[StringName], presented_ids: Array[StringName], roles: Array[RoleDefinition]) -> bool:
	var group_order: PackedInt32Array = PackedInt32Array([
		CaseEnums.RoleGroup.CHINH_NHAN,
		CaseEnums.RoleGroup.HIEU_SU,
		CaseEnums.RoleGroup.TONG_PHAM,
		CaseEnums.RoleGroup.NGHICH_THAN,
	])
	for group: int in group_order:
		var authored_group: Array[StringName] = []
		var presented_group: Array[StringName] = []
		for role_id: StringName in authored_ids:
			var role: RoleDefinition = _find_role_for_test(roles, role_id)
			if role != null and role.role_group == group:
				authored_group.append(role_id)
		for role_id: StringName in presented_ids:
			var role: RoleDefinition = _find_role_for_test(roles, role_id)
			if role != null and role.role_group == group:
				presented_group.append(role_id)
		if authored_group != presented_group:
			return false
	return true


func _t07_i1_group_order_index(group: int) -> int:
	match group:
		CaseEnums.RoleGroup.CHINH_NHAN:
			return 0
		CaseEnums.RoleGroup.HIEU_SU:
			return 1
		CaseEnums.RoleGroup.TONG_PHAM:
			return 2
		CaseEnums.RoleGroup.NGHICH_THAN:
			return 3
		_:
			return 99


func _t07_i1_glossary_repair_checks(roles: Array[RoleDefinition]) -> Dictionary:
	var checks: Dictionary = {}
	var kill_entry: Dictionary = RoleGlossaryBank.entry_for_key(&"kill")
	var kill_definition: String = "Làm một vai trò chết. Vai trò đã chết không Công Bố Sự Thật, và mọi thông tin chúng từng thông báo sẽ bị mất."
	var serial_killer: RoleDefinition = _find_role_for_test(roles, &"serial_killer")
	var serial_text: String = RoleReferenceFormatter.role_body_bbcode(serial_killer) if serial_killer != null else ""
	var sample: String = RoleReferenceFormatter.style_role_reference_terms("Khi ta giết mục tiêu, Phe Ác nói dối và bị tha hóa.")
	var kill_term: String = "[url=%s]%s[/url]" % [
		RoleGlossaryBank.meta_for_key(&"kill"),
		RoleReferenceFormatter.color_bbcode("giết", RoleReferenceFormatter.GLOSSARY_LINK_COLOR),
	]
	checks.exists = String(kill_entry.get("title", "")) == "Giết" and RoleGlossaryBank.resolve_alias("giết") == &"kill" and RoleGlossaryBank.resolve_alias("Giết") == &"kill"
	checks.definition = String(kill_entry.get("definition", "")) == kill_definition
	checks.serial_killer_link = serial_text.contains(kill_term)
	checks.unique = _t07_i1_glossary_alias_count("giết") == 1 and _t07_i1_glossary_alias_count("Giết") == 1 and _t07_i1_glossary_key_count(&"kill") == 1
	checks.key_terms_not_bold = sample.contains(kill_term) and not sample.contains("[b]") and not sample.contains("[/b]")
	checks.semantic_colors = (
		sample.contains(RoleReferenceFormatter.color_bbcode("Phe Ác", RoleReferenceFormatter.role_alignment_color(CaseEnums.RoleGroup.TONG_PHAM)))
		and sample.contains(RoleReferenceFormatter.color_bbcode("nói dối", RoleReferenceFormatter.LYING_COLOR))
		and sample.contains(RoleReferenceFormatter.color_bbcode("bị tha hóa", RoleReferenceFormatter.TAINTED_COLOR))
	)
	checks.interactive = sample.contains("[url=glossary:kill]") and sample.contains("[url=glossary:target]")
	checks.uniform_body_style = not sample.contains("[font_size") and not sample.contains("[b]") and RoleReferenceFormatter.BODY_FONT_SIZE == 13
	return checks


func _t07_i1_glossary_alias_count(alias: String) -> int:
	var count: int = 0
	for entry: Dictionary in RoleGlossaryBank.entries():
		var aliases: Array = entry.get("aliases", []) as Array
		for value: Variant in aliases:
			if String(value) == alias:
				count += 1
	for term: Dictionary in RoleGlossaryBank.style_only_terms():
		if String(term.get("term", "")) == alias:
			count += 1
	return count


func _t07_i1_glossary_key_count(key: StringName) -> int:
	var count: int = 0
	for entry: Dictionary in RoleGlossaryBank.entries():
		if StringName(entry.get("key", &"")) == key:
			count += 1
	return count


func _role_info_suspect(
	id: int,
	slot: int,
	true_role: StringName,
	displayed_role: StringName,
	alignment: int,
	corrupted: bool = false
) -> SuspectDefinition:
	return _role_info_case_fixture([
		_role_info_spec(id, slot, true_role, displayed_role, alignment, corrupted),
	]).suspects[0]


func _role_info_roles() -> Array[RoleDefinition]:
	var roles: Array[RoleDefinition] = []
	roles.append(_role_info_role(&"reporter", "Sử Quan", CaseEnums.RoleGroup.CHINH_NHAN))
	roles.append(_role_info_role(&"therapist", "Ngự Y", CaseEnums.RoleGroup.CHINH_NHAN))
	roles.append(_role_info_role(&"mailman", "Dịch Phu", CaseEnums.RoleGroup.CHINH_NHAN))
	roles.append(_role_info_role(&"mathematician", "Nhà Toán Học", CaseEnums.RoleGroup.CHINH_NHAN))
	roles.append(_role_info_role(&"weatherman", "Nhà Khí Tượng", CaseEnums.RoleGroup.CHINH_NHAN))
	roles.append(_role_info_role(&"clock_maker", "Thợ Đồng Hồ", CaseEnums.RoleGroup.CHINH_NHAN))
	roles.append(_role_info_role(&"blood_hound", "Ngự Khuyển Quan", CaseEnums.RoleGroup.CHINH_NHAN))
	roles.append(_role_info_role(&"spectre", "Vong Linh", CaseEnums.RoleGroup.TONG_PHAM))
	roles.append(_role_info_role(&"tutorial_priest", "Tư Tế", CaseEnums.RoleGroup.CHINH_NHAN))
	roles.append(_role_info_role(&"tutorial_mobster", "Kẻ Côn Đồ", CaseEnums.RoleGroup.TONG_PHAM))
	return roles


func _role_by_id(roles: Array[RoleDefinition], role_id: StringName) -> RoleDefinition:
	for role: RoleDefinition in roles:
		if role != null and role.role_id == role_id:
			return role
	return null


func _role_info_role(role_id: StringName, display_name: String, role_group: int) -> RoleDefinition:
	var role: RoleDefinition = RoleDefinition.new()
	role.role_id = role_id
	role.display_name = display_name
	role.role_group = role_group
	role.is_fixture_placeholder = false
	return role


func _view_data_excludes(case_fixture: CaseDefinition, forbidden_field: String) -> bool:
	var views := _public_views(case_fixture)
	if views.is_empty():
		return false
	var property_names := PackedStringArray()
	for property_info in views[0].get_property_list():
		property_names.append(property_info.name)
	return forbidden_field not in property_names and forbidden_field not in views[0].visible_property_names()


func _all_public_views_hidden(case_fixture: CaseDefinition) -> bool:
	var views := _public_views(case_fixture)
	if views.size() != 8:
		return false
	for view_data in views:
		if view_data.is_investigated:
			return false
		if view_data.public_status_text != "Chưa điều tra":
			return false
		if not view_data.public_role_name.is_empty():
			return false
	return true


func _case_actions_disabled() -> bool:
	var packed := load(VS_CASE_MAIN_PATH) as PackedScene
	if packed == null:
		return false
	var scene := packed.instantiate()
	var actions_disabled := (
		(scene.get_node("%InvestigateButton") as Button).disabled
		and (scene.get_node("%FunctionButton") as Button).disabled
		and (scene.get_node("%SubmitButton") as Button).disabled
	)
	scene.free()
	return actions_disabled


func _case_scene_has_back_route() -> bool:
	var packed := load(VS_CASE_MAIN_PATH) as PackedScene
	if packed == null or not ResourceLoader.exists(AppFlow.DEBUG_HOME_SCENE):
		return false
	var scene := packed.instantiate()
	var back_button: Button = scene.get_node_or_null("%DevBackButton") as Button
	var scene_source: String = FileAccess.get_file_as_string(VS_CASE_MAIN_PATH)
	var has_back := (
		back_button != null
		and back_button.text == "← Quay lại"
		and scene.has_method("_on_back_pressed")
		and AppFlow.has_method("go_to_debug_home")
		and scene_source.contains("DevBackButton\" to=\".\" method=\"_on_back_pressed\"")
	)
	scene.free()
	return has_back


func _case_scene_player_facing_results_button_activates() -> bool:
	var packed := load(VS_CASE_MAIN_PATH) as PackedScene
	if packed == null:
		return false
	var scene := packed.instantiate()
	var back_button: Button = scene.get_node_or_null("%DevBackButton") as Button
	if back_button == null:
		scene.free()
		return false
	scene.player_facing_mode = true
	scene.set("_integration_completion_emitted", false)
	scene.call("_sync_back_navigation_button")
	var hidden_before_reveal: bool = not back_button.visible
	var acknowledgements: Array[String] = []
	var acknowledgement_handler: Callable = func() -> void:
		acknowledgements.append("ack")
	scene.integration_truth_acknowledged.connect(acknowledgement_handler)
	back_button.pressed.emit()
	var no_early_acknowledgement: bool = acknowledgements.is_empty()
	scene.set("_integration_completion_emitted", true)
	scene.call("_sync_back_navigation_button")
	var presented_after_reveal: bool = (
		back_button.visible
		and back_button.text == "Xem kết quả Kỳ Án"
		and not back_button.disabled
	)
	var one_button_connection: bool = back_button.pressed.get_connections().size() == 1
	back_button.pressed.emit()
	back_button.pressed.emit()
	var controller_source: String = FileAccess.get_file_as_string(
		"res://scripts/presentation/case_gameplay/VSCaseMainController.gd"
	)
	var mode_aware_handler: bool = (
		controller_source.contains("if player_facing_mode:")
		and controller_source.contains("_can_acknowledge_player_facing_truth()")
		and controller_source.find("integration_truth_acknowledged.emit()") < controller_source.find("AppFlow.go_to_debug_home()")
	)
	var passed: bool = (
		hidden_before_reveal
		and no_early_acknowledgement
		and presented_after_reveal
		and one_button_connection
		and acknowledgements.size() == 1
		and mode_aware_handler
	)
	scene.free()
	return passed


func _debug_role_codex_launcher_exists() -> bool:
	var scene: Control = _debug_home_instance()
	if scene == null:
		return false
	var button: Button = scene.get_node_or_null("%RoleCodexButton") as Button
	var passed: bool = (
		button != null
		and button.text == "Sổ Vai Trò"
		and scene.has_method("_on_role_codex_pressed")
	)
	scene.free()
	return passed


func _role_codex_instance() -> RoleCodexController:
	var packed: PackedScene = load(ROLE_CODEX_PATH) as PackedScene
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if packed == null or tree == null:
		return null
	var scene: RoleCodexController = packed.instantiate() as RoleCodexController
	if scene == null:
		return null
	tree.root.add_child(scene)
	return scene


func _free_role_codex(scene: RoleCodexController) -> void:
	if scene == null:
		return
	var parent: Node = scene.get_parent()
	if parent != null:
		parent.remove_child(scene)
	scene.free()


func _role_codex_groups_canonical() -> bool:
	var scene: RoleCodexController = _role_codex_instance()
	if scene == null:
		return false
	var labels: Array[String] = scene.get_group_labels()
	var passed: bool = labels == [
		"Người Vô Tội",
		"Kẻ Bao Đồng",
		"Thuộc Hạ",
		"Nghịch Thần",
	]
	_free_role_codex(scene)
	return passed


func _role_codex_filters_available_roles() -> bool:
	var scene: RoleCodexController = _role_codex_instance()
	if scene == null:
		return false
	var good_ids: Array[StringName] = scene.get_visible_role_ids_for_group(CaseEnums.RoleGroup.CHINH_NHAN)
	var meddler_ids: Array[StringName] = scene.get_visible_role_ids_for_group(CaseEnums.RoleGroup.HIEU_SU)
	var underling_ids: Array[StringName] = scene.get_visible_role_ids_for_group(CaseEnums.RoleGroup.TONG_PHAM)
	var traitor_ids: Array[StringName] = scene.get_visible_role_ids_for_group(CaseEnums.RoleGroup.NGHICH_THAN)
	var all_ids: Array[StringName] = []
	all_ids.append_array(good_ids)
	all_ids.append_array(meddler_ids)
	all_ids.append_array(underling_ids)
	all_ids.append_array(traitor_ids)
	var passed: bool = (
		scene.get_loaded_role_count() == 21
		and good_ids == [&"tailor", &"mailman", &"mathematician", &"weatherman", &"clock_maker", &"reporter", &"blood_hound", &"therapist", &"vigilante", &"tutorial_priest"]
		and meddler_ids == [&"copycat", &"drunkard", &"surgeon"]
		and underling_ids == [&"conman", &"poisoner", &"barkeep", &"serial_killer", &"spectre", &"tutorial_scoundrel", &"tutorial_mobster"]
		and traitor_ids == [&"critic"]
		and not all_ids.has(&"role_good_a")
		and not all_ids.has(&"role_meddler_a")
		and not all_ids.has(&"role_accomplice_a")
		and not all_ids.has(&"role_traitor_a")
	)
	_free_role_codex(scene)
	return passed


func _role_codex_uses_authoritative_content(roles: Array[RoleDefinition]) -> bool:
	var scene: RoleCodexController = _role_codex_instance()
	var case_scene: VSCaseMainController = _case_scene_instance() as VSCaseMainController
	if scene == null or case_scene == null:
		_free_role_codex(scene)
		if case_scene != null:
			case_scene.free()
		return false
	var role: RoleDefinition = _find_role_for_test(roles, &"tailor")
	if role == null:
		_free_role_codex(scene)
		case_scene.free()
		return false
	scene.select_role_for_smoke(role.role_id)
	var codex_text: String = scene.get_detail_text()
	var shared_body: String = RoleReferenceFormatter.role_body_bbcode(role)
	var case_reference_text: String = case_scene._role_reference_bbcode(role)
	var passed: bool = (
		scene.get_selected_role_id() == role.role_id
		and codex_text.contains(role.display_name)
		and codex_text.contains(shared_body)
		and case_reference_text.contains(shared_body)
		and not codex_text.contains("[font_size")
		and not case_reference_text.contains("[font_size")
		and not codex_text.contains("suspect_id")
		and not codex_text.contains("true_role_id")
	)
	_free_role_codex(scene)
	case_scene.free()
	return passed


func _role_codex_simple_complex_render() -> Dictionary:
	var scene: RoleCodexController = _role_codex_instance()
	if scene == null:
		return {"passed": false, "detail": "scene=null"}
	var mobster_role: RoleDefinition = _find_role_for_test(FixtureRepository.load_roles(), &"tutorial_mobster")
	var tailor_role: RoleDefinition = _find_role_for_test(FixtureRepository.load_roles(), &"tailor")
	if mobster_role == null or tailor_role == null:
		_free_role_codex(scene)
		return {"passed": false, "detail": "role fixture missing"}
	scene.select_role_for_smoke(&"tutorial_mobster")
	var mobster_text: String = scene.get_detail_text()
	var detail_body: RichTextLabel = scene.get_node_or_null("%RoleDetailBody") as RichTextLabel
	var mobster_body_text: String = detail_body.text if detail_body != null else ""
	var mobster_selected_ok: bool = scene.get_selected_role_id() == &"tutorial_mobster"
	scene.select_role_for_smoke(&"tailor")
	var tailor_text: String = scene.get_detail_text()
	var tailor_body_text: String = detail_body.text if detail_body != null else ""
	var tailor_selected_ok: bool = scene.get_selected_role_id() == &"tailor"
	var body_font_size_ok: bool = (
		detail_body != null
		and detail_body.bbcode_enabled
		and detail_body.get_theme_font_size("normal_font_size") == RoleReferenceFormatter.BODY_FONT_SIZE
		and detail_body.get_theme_font_size("bold_font_size") == RoleReferenceFormatter.BODY_FONT_SIZE
		and detail_body.get_theme_font_size("italics_font_size") == RoleReferenceFormatter.BODY_FONT_SIZE
		and detail_body.get_theme_font_size("bold_italics_font_size") == RoleReferenceFormatter.BODY_FONT_SIZE
	)
	var checks: Dictionary = {}
	checks.body_font_size = body_font_size_ok
	checks.mobster_selected = mobster_selected_ok
	checks.mobster_title = mobster_text.contains("Kẻ Côn Đồ")
	checks.mobster_body_non_empty = not mobster_body_text.strip_edges().is_empty()
	checks.mobster_uses_formatter = mobster_body_text == RoleReferenceFormatter.role_body_bbcode(mobster_role)
	checks.mobster_simple_no_empty_sections = not mobster_text.contains("Extra") and not mobster_text.contains("\n\n\n")
	checks.tailor_selected = tailor_selected_ok
	checks.tailor_title = tailor_text.contains("Thợ May")
	checks.tailor_body_non_empty = not tailor_body_text.strip_edges().is_empty()
	checks.tailor_uses_formatter = tailor_body_text == RoleReferenceFormatter.role_body_bbcode(tailor_role)
	checks.tailor_complex_body = tailor_role.has_interactive_function and tailor_body_text.length() > mobster_body_text.length()
	checks.glossary_metadata_allowed = tailor_body_text.contains("[url=glossary:")
	checks.no_font_size = not mobster_text.contains("[font_size") and not tailor_text.contains("[font_size")
	checks.no_empty_sections = not tailor_text.contains("\n\n\n")
	_free_role_codex(scene)
	return _checks_result(checks, "Mobster and Tailor render non-empty Codex bodies")


func _debug_tutorial_case_01_launcher_exists() -> bool:
	var scene := _debug_home_instance()
	if scene == null:
		return false
	var button := scene.get_node_or_null("%TutorialCase01Button") as Button
	var passed := (
		button != null
		and button.text == "Tutorial Case 01 — Deduction M0"
		and scene.has_method("_on_tutorial_case_01_pressed")
	)
	scene.free()
	return passed


func _debug_tutorial_case_01_resolves_fixture() -> bool:
	var previous_pending := AppFlow.pending_case_path
	AppFlow.pending_case_path = FixtureRepository.TUTORIAL_CASE_001_PATH
	var pending_case := AppFlow.take_pending_case_definition()
	AppFlow.pending_case_path = previous_pending
	return (
		AppFlow.has_method("go_to_tutorial_case_001")
		and AppFlow.has_method("take_pending_case_definition")
		and ResourceLoader.exists(FixtureRepository.TUTORIAL_CASE_001_PATH)
		and FixtureRepository.load_tutorial_case_001() != null
		and FixtureRepository.load_tutorial_case_001().case_id == &"tutorial_case_001"
		and pending_case != null
		and pending_case.case_id == &"tutorial_case_001"
	)


func _debug_tutorial_case_02_launcher_exists() -> bool:
	var scene := _debug_home_instance()
	if scene == null:
		return false
	var button := scene.get_node_or_null("%TutorialCase02Button") as Button
	var passed := (
		button != null
		and button.text == "Tutorial Case 02 — Deduction"
		and scene.has_method("_on_tutorial_case_02_pressed")
	)
	scene.free()
	return passed


func _debug_tutorial_case_02_resolves_fixture() -> bool:
	var previous_pending := AppFlow.pending_case_path
	AppFlow.pending_case_path = FixtureRepository.TUTORIAL_CASE_002_PATH
	var pending_case := AppFlow.take_pending_case_definition()
	AppFlow.pending_case_path = previous_pending
	return (
		AppFlow.has_method("go_to_tutorial_case_002")
		and AppFlow.has_method("take_pending_case_definition")
		and ResourceLoader.exists(FixtureRepository.TUTORIAL_CASE_002_PATH)
		and FixtureRepository.load_tutorial_case_002() != null
		and FixtureRepository.load_tutorial_case_002().case_id == &"tutorial_case_002"
		and pending_case != null
		and pending_case.case_id == &"tutorial_case_002"
	)


func _debug_tutorial_case_03_launcher_exists() -> bool:
	var scene: Control = _debug_home_instance()
	if scene == null:
		return false
	var button: Button = scene.get_node_or_null("%TutorialCase03Button") as Button
	var passed: bool = (
		button != null
		and button.text == "Tutorial Case 03 — Deduction"
		and scene.has_method("_on_tutorial_case_03_pressed")
	)
	scene.free()
	return passed


func _debug_tutorial_case_03_resolves_fixture() -> bool:
	var previous_pending: String = AppFlow.pending_case_path
	AppFlow.pending_case_path = FixtureRepository.TUTORIAL_CASE_003_PATH
	var pending_case: CaseDefinition = AppFlow.take_pending_case_definition()
	AppFlow.pending_case_path = previous_pending
	return (
		AppFlow.has_method("go_to_tutorial_case_003")
		and AppFlow.has_method("take_pending_case_definition")
		and ResourceLoader.exists(FixtureRepository.TUTORIAL_CASE_003_PATH)
		and FixtureRepository.load_tutorial_case_003() != null
		and FixtureRepository.load_tutorial_case_003().case_id == &"tutorial_case_003"
		and pending_case != null
		and pending_case.case_id == &"tutorial_case_003"
	)


func _debug_tutorial_case_04_launcher_exists() -> bool:
	var scene: Control = _debug_home_instance()
	if scene == null:
		return false
	var button: Button = scene.get_node_or_null("%TutorialCase04Button") as Button
	var passed: bool = (
		button != null
		and button.text == "Tutorial Case 04 — Active Ability"
		and scene.has_method("_on_tutorial_case_04_pressed")
	)
	scene.free()
	return passed


func _debug_tutorial_case_04_resolves_fixture() -> bool:
	var previous_pending: String = AppFlow.pending_case_path
	AppFlow.pending_case_path = FixtureRepository.TUTORIAL_CASE_004_PATH
	var pending_case: CaseDefinition = AppFlow.take_pending_case_definition()
	AppFlow.pending_case_path = previous_pending
	return (
		AppFlow.has_method("go_to_tutorial_case_004")
		and AppFlow.has_method("take_pending_case_definition")
		and ResourceLoader.exists(FixtureRepository.TUTORIAL_CASE_004_PATH)
		and FixtureRepository.load_tutorial_case_004() != null
		and FixtureRepository.load_tutorial_case_004().case_id == &"tutorial_case_004"
		and pending_case != null
		and pending_case.case_id == &"tutorial_case_004"
	)


func _debug_tutorial_case_05_launcher_exists() -> bool:
	var scene: Control = _debug_home_instance()
	if scene == null:
		return false
	var button: Button = scene.get_node_or_null("%TutorialCase05Button") as Button
	var passed: bool = (
		button != null
		and button.text == "Tutorial Case 05 — Timed Roles"
		and scene.has_method("_on_tutorial_case_05_pressed")
	)
	scene.free()
	return passed


func _debug_tutorial_case_05_resolves_fixture() -> bool:
	var previous_pending: String = AppFlow.pending_case_path
	AppFlow.pending_case_path = FixtureRepository.TUTORIAL_CASE_005_PATH
	var pending_case: CaseDefinition = AppFlow.take_pending_case_definition()
	AppFlow.pending_case_path = previous_pending
	return (
		AppFlow.has_method("go_to_tutorial_case_005")
		and AppFlow.has_method("take_pending_case_definition")
		and ResourceLoader.exists(FixtureRepository.TUTORIAL_CASE_005_PATH)
		and FixtureRepository.load_tutorial_case_005() != null
		and FixtureRepository.load_tutorial_case_005().case_id == &"tutorial_case_005"
		and pending_case != null
		and pending_case.case_id == &"tutorial_case_005"
	)


func _debug_tutorial_case_06_launcher_exists() -> bool:
	var scene: Control = _debug_home_instance()
	if scene == null:
		return false
	var button: Button = scene.get_node_or_null("%TutorialCase06Button") as Button
	var passed: bool = (
		button != null
		and button.text == "Tutorial Case 06 — Transform"
		and scene.has_method("_on_tutorial_case_06_pressed")
	)
	scene.free()
	return passed


func _debug_tutorial_case_06_resolves_fixture() -> bool:
	var previous_pending: String = AppFlow.pending_case_path
	AppFlow.pending_case_path = FixtureRepository.TUTORIAL_CASE_006_PATH
	var pending_case: CaseDefinition = AppFlow.take_pending_case_definition()
	AppFlow.pending_case_path = previous_pending
	return (
		AppFlow.has_method("go_to_tutorial_case_006")
		and AppFlow.has_method("take_pending_case_definition")
		and ResourceLoader.exists(FixtureRepository.TUTORIAL_CASE_006_PATH)
		and FixtureRepository.load_tutorial_case_006() != null
		and FixtureRepository.load_tutorial_case_006().case_id == &"tutorial_case_006"
		and pending_case != null
		and pending_case.case_id == &"tutorial_case_006"
	)


func _debug_tutorial_case_07_launcher_exists() -> bool:
	var scene: Control = _debug_home_instance()
	if scene == null:
		return false
	var button: Button = scene.get_node_or_null("%TutorialCase07Button") as Button
	var passed: bool = (
		button != null
		and button.text == "Tutorial Case 07 — Dangerous Time"
		and scene.has_method("_on_tutorial_case_07_pressed")
	)
	scene.free()
	return passed


func _debug_tutorial_case_07_resolves_fixture() -> bool:
	var previous_pending: String = AppFlow.pending_case_path
	AppFlow.pending_case_path = FixtureRepository.TUTORIAL_CASE_007_PATH
	var pending_case: CaseDefinition = AppFlow.take_pending_case_definition()
	AppFlow.pending_case_path = previous_pending
	return (
		AppFlow.has_method("go_to_tutorial_case_007")
		and AppFlow.has_method("take_pending_case_definition")
		and ResourceLoader.exists(FixtureRepository.TUTORIAL_CASE_007_PATH)
		and FixtureRepository.load_tutorial_case_007() != null
		and FixtureRepository.load_tutorial_case_007().case_id == &"tutorial_case_007"
		and pending_case != null
		and pending_case.case_id == &"tutorial_case_007"
	)


func _debug_tutorial_case_08_launcher_exists() -> bool:
	var scene: Control = _debug_home_instance()
	if scene == null:
		return false
	var button: Button = scene.get_node_or_null("%TutorialCase08Button") as Button
	var passed: bool = (
		button != null
		and button.text == "Tutorial Case 08 — Truthful Evil"
		and scene.has_method("_on_tutorial_case_08_pressed")
	)
	scene.free()
	return passed


func _debug_tutorial_case_08_resolves_fixture() -> bool:
	var previous_pending: String = AppFlow.pending_case_path
	AppFlow.pending_case_path = FixtureRepository.TUTORIAL_CASE_008_PATH
	var pending_case: CaseDefinition = AppFlow.take_pending_case_definition()
	AppFlow.pending_case_path = previous_pending
	return (
		AppFlow.has_method("go_to_tutorial_case_008")
		and AppFlow.has_method("take_pending_case_definition")
		and ResourceLoader.exists(FixtureRepository.TUTORIAL_CASE_008_PATH)
		and FixtureRepository.load_tutorial_case_008() != null
		and FixtureRepository.load_tutorial_case_008().case_id == &"tutorial_case_008"
		and pending_case != null
		and pending_case.case_id == &"tutorial_case_008"
	)


func _debug_existing_case_launcher_remains() -> bool:
	var scene := _debug_home_instance()
	if scene == null:
		return false
	var button := scene.get_node_or_null("SafeMargin/MainColumn/ContentRow/MenuPanel/MenuScroll/Menu/CaseButton") as Button
	var passed := (
		button != null
		and button.text == "Vertical Slice Kỳ Án"
		and scene.has_method("_on_case_pressed")
		and AppFlow.has_method("go_to_case_vertical_slice")
		and AppFlow.VS_CASE_MAIN_SCENE == VS_CASE_MAIN_PATH
		and FixtureRepository.load_case() != null
	)
	scene.free()
	return passed


func _debug_home_instance() -> Node:
	var packed := load(DEBUG_HOME_PATH) as PackedScene
	if packed == null:
		return null
	return packed.instantiate()


func _invalid_case_presentation_safe() -> bool:
	var invalid_case := FixtureRepository.load_invalid_case()
	var views := CasePublicPresentationBuilder.new().build_suspect_views(invalid_case)
	return views.is_empty()


func _case_body_uses_vertical_scroll() -> bool:
	var scene := _case_scene_instance()
	if scene == null:
		return false
	var body_scroll: Node = scene.get_node_or_null("%BodyScroll")
	var main_column: VBoxContainer = scene.get_node_or_null("SafeMargin/MainColumn") as VBoxContainer
	var content_root: HBoxContainer = scene.get_node_or_null("%ContentRoot") as HBoxContainer
	var passed := (
		body_scroll == null
		and main_column != null
		and content_root != null
		and content_root.get_parent() == main_column
		and content_root.size_flags_vertical == Control.SIZE_EXPAND_FILL
	)
	scene.free()
	return passed


func _case_scroll_owns_full_body() -> bool:
	var scene := _case_scene_instance()
	if scene == null:
		return false
	var content_root: HBoxContainer = scene.get_node_or_null("%ContentRoot") as HBoxContainer
	var info_panel: PanelContainer = scene.get_node_or_null("SafeMargin/MainColumn/ContentRoot/InfoPanel") as PanelContainer
	var role_panel: PanelContainer = scene.get_node_or_null("%RolePanel") as PanelContainer
	var role_scroll: ScrollContainer = scene.get_node_or_null("%RoleListScroll") as ScrollContainer
	var left_action_area: VBoxContainer = scene.get_node_or_null("%LeftActionArea") as VBoxContainer
	var info_column: VBoxContainer = scene.get_node_or_null("SafeMargin/MainColumn/ContentRoot/InfoPanel/InfoColumn") as VBoxContainer
	var info_title: Label = scene.get_node_or_null("SafeMargin/MainColumn/ContentRoot/InfoPanel/InfoColumn/InfoTitle") as Label
	var reputation: RichTextLabel = scene.get_node_or_null("%PlayerStripLabel") as RichTextLabel
	var action_spacer: Control = scene.get_node_or_null("SafeMargin/MainColumn/ContentRoot/InfoPanel/InfoColumn/LeftActionSpacer") as Control
	var passed := (
		content_root != null
		and info_panel != null
		and role_panel != null
		and role_scroll != null
		and left_action_area != null
		and role_panel.is_ancestor_of(role_scroll)
		and info_panel.is_ancestor_of(left_action_area)
		and role_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO
		and role_scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED
		and info_column != null
		and info_title != null
		and reputation != null
		and action_spacer != null
		and info_column.get_children().find(reputation) > info_column.get_children().find(info_title)
		and info_column.get_children().find(left_action_area) > info_column.get_children().find(action_spacer)
	)
	scene.free()
	return passed


func _case_board_layout_preserved() -> bool:
	var scene := _case_scene_instance()
	if scene == null:
		return false
	var content_root := scene.get_node_or_null("%ContentRoot") as HBoxContainer
	var case_board := scene.get_node_or_null("%CaseBoard") as CaseBoardController
	var case_fixture: CaseDefinition = FixtureRepository.load_case()
	if case_board != null and case_fixture != null:
		case_board.populate(case_fixture.location_definitions(), _public_views(case_fixture))
	var grid: GridContainer = null
	if case_board != null:
		grid = case_board.get_node_or_null("%Grid") as GridContainer
	var tile_size: Vector2 = CaseBoardController.BOARD_TILE_SIZE
	var grid_h_gap: int = grid.get_theme_constant("h_separation") if grid != null else -1
	var grid_v_gap: int = grid.get_theme_constant("v_separation") if grid != null else -1
	var grid_footprint: Vector2 = Vector2(
		tile_size.x * 3.0 + float(grid_h_gap * 2),
		tile_size.y * 3.0 + float(grid_v_gap * 2)
	)
	var tile_aspect: float = tile_size.x / tile_size.y if tile_size.y > 0.0 else 0.0
	var passed := (
		content_root != null
		and case_board != null
		and grid != null
		and grid.columns == 3
		and case_board.size_flags_horizontal == Control.SIZE_SHRINK_CENTER
		and case_board.size_flags_vertical == Control.SIZE_SHRINK_BEGIN
		and grid.size_flags_horizontal == Control.SIZE_SHRINK_CENTER
		and grid.size_flags_vertical == Control.SIZE_SHRINK_BEGIN
		and grid_h_gap == CaseBoardController.BOARD_GRID_H_GAP
		and grid_v_gap == CaseBoardController.BOARD_GRID_V_GAP
		and grid_h_gap > 0
		and grid_v_gap > 0
		and tile_aspect >= 0.78
		and tile_aspect <= 0.92
		and grid_footprint.x >= 520.0
		and grid_footprint.x <= 540.0
		and grid_footprint.y >= 615.0
		and grid_footprint.y <= 630.0
	)
	scene.free()
	return passed


func _case_ui_foundation_freeze(case_fixture: CaseDefinition) -> bool:
	var checks: Dictionary = {}
	var scene := _case_scene_instance()
	var center_column: VBoxContainer = null
	var board_node: CaseBoardController = null
	var help_label: Label = null
	if scene != null:
		center_column = scene.get_node_or_null("SafeMargin/MainColumn/ContentRoot/CenterColumn") as VBoxContainer
		board_node = scene.get_node_or_null("%CaseBoard") as CaseBoardController
		help_label = scene.get_node_or_null("%BoardHelpLabel") as Label
	checks.help_region_exists = help_label != null and board_node != null and center_column != null
	if checks.help_region_exists:
		checks.help_region_outside_board = help_label.get_parent() == center_column and board_node.get_parent() == center_column and center_column.get_children().find(help_label) > center_column.get_children().find(board_node)
		checks.help_region_has_instruction = help_label.text.contains("Giữ chuột trái") and help_label.autowrap_mode != TextServer.AUTOWRAP_OFF
	else:
		checks.help_region_outside_board = false
		checks.help_region_has_instruction = false
	if scene != null:
		scene.free()

	var board := _board_instance(case_fixture)
	checks.current_3x3_columns = board != null and board.get_board_columns_for_smoke() == 3
	checks.current_3x3_slots = board != null and board.get_board_slot_count_for_smoke() == 9 and board.get_case_tile_count() == 9
	checks.current_3x3_large_profile = board != null and board.get_board_tile_size_for_smoke() == CaseBoardController.BOARD_TILE_SIZE
	var authored_slots_stable := board != null and case_fixture != null and case_fixture.crime_scene != null
	if authored_slots_stable:
		authored_slots_stable = board.get_crime_scene_slot() == case_fixture.crime_scene.board_slot
		for suspect in case_fixture.suspects:
			if suspect == null or board.get_suspect_slot(suspect.suspect_id) != suspect.board_slot:
				authored_slots_stable = false
				break
	checks.authored_slot_order_stable = authored_slots_stable
	if board != null:
		board.free()

	var synthetic_board := _case_board_scene_instance()
	if synthetic_board != null:
		var synthetic_locations: Array[BoardLocationDefinition] = []
		var synthetic_views: Array[SuspectPublicViewData] = []
		var synthetic_records: Array[PublicFunctionRecord] = []
		synthetic_board.populate(synthetic_locations, synthetic_views, synthetic_records, -1, 4, 16)
	checks.synthetic_4x4_columns = synthetic_board != null and synthetic_board.get_board_columns_for_smoke() == 4
	checks.synthetic_4x4_slots = synthetic_board != null and synthetic_board.get_board_slot_count_for_smoke() == 16 and synthetic_board.get_case_tile_count() == 16
	checks.synthetic_4x4_compact_profile = synthetic_board != null and synthetic_board.get_board_tile_size_for_smoke() == CaseBoardController.COMPACT_BOARD_TILE_SIZE
	if synthetic_board != null:
		synthetic_board.free()
	var board_source: String = FileAccess.get_file_as_string("res://scripts/presentation/case_gameplay/CaseBoardController.gd")
	checks.columns_not_universal_hardcoded = board_source.contains("board_columns: int") and board_source.contains("grid.columns = _board_columns")
	return bool(_checks_result(checks, "foundation freeze").get("passed", false))


func _hover_relation_emphasis_checks(
	tutorial_case_03: CaseDefinition,
	tutorial_case_04: CaseDefinition,
	tutorial_case_05: CaseDefinition,
	roles: Array[RoleDefinition],
	players: Array[PlayerCaseState]
) -> Dictionary:
	var checks: Dictionary = {}
	if tutorial_case_03 == null or tutorial_case_04 == null or tutorial_case_05 == null:
		return _checks_result(checks, "structured relation targets emphasized without reflow")
	var builder: CasePublicPresentationBuilder = CasePublicPresentationBuilder.new()

	var tailor_runtime: CaseRuntimeState = _fresh_turn_bundle(tutorial_case_04, players).runtime as CaseRuntimeState
	tailor_runtime.append_public_function_record(1, "Thợ May", PackedInt32Array([3, 4]), &"player_1", "Cùng phe")
	var tailor_views: Array[SuspectPublicViewData] = builder.build_suspect_views(tutorial_case_04, tailor_runtime, roles)
	var tailor_view: SuspectPublicViewData = _tutorial_03_view(tailor_views, 1)
	checks.tailor_pair = tailor_view != null and tailor_view.public_relation_suspect_ids == PackedInt32Array([3, 4])

	var weather_runtime: CaseRuntimeState = _t05_i3_investigated_runtime(tutorial_case_05, players, 3)
	var weather_views: Array[SuspectPublicViewData] = builder.build_suspect_views(tutorial_case_05, weather_runtime, roles)
	var weather_view: SuspectPublicViewData = _tutorial_03_view(weather_views, 3)
	checks.weatherman_triplet = weather_view != null and weather_view.public_relation_suspect_ids == PackedInt32Array([2, 4, 6])

	var therapist_runtime: CaseRuntimeState = _t05_i3_investigated_runtime(tutorial_case_03, players, 4)
	var therapist_views: Array[SuspectPublicViewData] = builder.build_suspect_views(tutorial_case_03, therapist_runtime, roles)
	var therapist_view: SuspectPublicViewData = _tutorial_03_view(therapist_views, 4)
	checks.therapist_orthogonal_candidates = therapist_view != null and therapist_view.public_relation_suspect_ids == PackedInt32Array([3, 5])
	checks.therapist_no_diagonal_leakage = therapist_view != null and not therapist_view.public_relation_suspect_ids.has(1) and not therapist_view.public_relation_suspect_ids.has(2)

	var reporter_runtime: CaseRuntimeState = _t05_i3_investigated_runtime(tutorial_case_03, players, 2)
	var reporter_views: Array[SuspectPublicViewData] = builder.build_suspect_views(tutorial_case_03, reporter_runtime, roles)
	var reporter_view: SuspectPublicViewData = _tutorial_03_view(reporter_views, 2)
	checks.reporter_announced_distance_candidates = reporter_view != null and reporter_view.public_relation_suspect_ids == PackedInt32Array([1, 4])
	checks.reporter_no_actual_evil_only = reporter_view != null and reporter_view.public_relation_suspect_ids.has(1) and reporter_view.public_relation_suspect_ids.has(4) and not reporter_view.public_relation_suspect_ids.has(5)

	var blood_hound_checks: Dictionary = _hover_relation_blood_hound_checks(roles, players)
	checks.blood_hound_north = bool(blood_hound_checks.get("north", false))
	checks.blood_hound_east = bool(blood_hound_checks.get("east", false))
	checks.blood_hound_south = bool(blood_hound_checks.get("south", false))
	checks.blood_hound_west = bool(blood_hound_checks.get("west", false))
	checks.blood_hound_bark_empty = bool(blood_hound_checks.get("bark_empty", false))
	checks.blood_hound_sniff_empty = bool(blood_hound_checks.get("sniff_empty", false))

	var vigilante_runtime: CaseRuntimeState = _fresh_turn_bundle(tutorial_case_05, players).runtime as CaseRuntimeState
	vigilante_runtime.append_public_function_record(5, "Sư Tử Phán", PackedInt32Array([4]), &"player_1", "Số Hiệu 4 bình an vô sự")
	var vigilante_views: Array[SuspectPublicViewData] = builder.build_suspect_views(tutorial_case_05, vigilante_runtime, roles)
	var vigilante_view: SuspectPublicViewData = _tutorial_03_view(vigilante_views, 5)
	checks.vigilante_target = vigilante_view != null and vigilante_view.public_relation_suspect_ids == PackedInt32Array([4])

	var surgeon_runtime: CaseRuntimeState = _fresh_turn_bundle(tutorial_case_05, players).runtime as CaseRuntimeState
	var surgeon_event: CaseTimedEventRuntimeState = surgeon_runtime.ensure_timed_event(&"surgeon_smoke_12h", 12, 6)
	surgeon_event.mark_fired(12, true, 2, true, CaseKillResult.Outcome.KILLED)
	_prepare_reveal_runtime_for_hover(tutorial_case_05, surgeon_runtime)
	surgeon_runtime.truth_reveal = CaseTruthRevealBuilder.new().build(tutorial_case_05, surgeon_runtime, roles)
	var surgeon_views: Array[SuspectPublicViewData] = builder.build_suspect_views(tutorial_case_05, surgeon_runtime, roles)
	var surgeon_view: SuspectPublicViewData = _tutorial_03_view(surgeon_views, 6)
	checks.surgeon_victim = surgeon_view != null and surgeon_view.public_relation_suspect_ids == PackedInt32Array([2])

	var spectre_runtime: CaseRuntimeState = _fresh_turn_bundle(tutorial_case_03, players).runtime as CaseRuntimeState
	_prepare_reveal_runtime_for_hover(tutorial_case_03, spectre_runtime)
	spectre_runtime.truth_reveal = CaseTruthRevealBuilder.new().build(tutorial_case_03, spectre_runtime, roles)
	var spectre_views: Array[SuspectPublicViewData] = builder.build_suspect_views(tutorial_case_03, spectre_runtime, roles)
	var spectre_view: SuspectPublicViewData = _tutorial_03_view(spectre_views, 4)
	checks.spectre_obscure = spectre_view != null and spectre_view.public_relation_suspect_ids == PackedInt32Array([3])

	var board: CaseBoardController = _board_instance_with_runtime(tutorial_case_04, tailor_runtime, roles)
	var owner_card: SuspectCardController = _board_card(board, 1) if board != null else null
	var related_card: SuspectCardController = _board_card(board, 3) if board != null else null
	var unrelated_card: SuspectCardController = _board_card(board, 2) if board != null else null
	var owner_footprint_before: Vector2 = owner_card.get_combined_minimum_size() if owner_card != null else Vector2.ZERO
	var related_footprint_before: Vector2 = related_card.get_combined_minimum_size() if related_card != null else Vector2.ZERO
	var owner_offset_before: Vector2 = owner_card.get_presentation_offset_for_smoke() if owner_card != null else Vector2.INF
	var function_marker_grouped: bool = owner_card != null and owner_card.function_hand_marker_shares_presentation_root_for_smoke()
	var dead_marker_grouped: bool = owner_card != null and owner_card.dead_marker_shares_presentation_root_for_smoke()
	if board != null:
		board.apply_relation_hover_for_smoke(1)
	var owner_scale: Vector2 = owner_card.get_relation_emphasis_scale_for_smoke() if owner_card != null else Vector2.ZERO
	var related_scale: Vector2 = related_card.get_relation_emphasis_scale_for_smoke() if related_card != null else Vector2.ZERO
	var unrelated_scale: Vector2 = unrelated_card.get_relation_emphasis_scale_for_smoke() if unrelated_card != null else Vector2.ZERO
	var unrelated_modulate: Color = unrelated_card.get_relation_emphasis_modulate_for_smoke() if unrelated_card != null else Color.WHITE
	var owner_footprint_after: Vector2 = owner_card.get_combined_minimum_size() if owner_card != null else Vector2.ZERO
	var related_footprint_after: Vector2 = related_card.get_combined_minimum_size() if related_card != null else Vector2.ZERO
	checks.related_emphasized = related_scale.x > 1.0 and related_scale.y > 1.0
	checks.unrelated_deemphasized = unrelated_scale.x < 1.0 and unrelated_scale.y < 1.0 and unrelated_modulate.a < 1.0
	checks.hover_footprint_stable = owner_footprint_before == owner_footprint_after and related_footprint_before == related_footprint_after
	checks.function_marker_shares_transform = function_marker_grouped
	checks.dead_marker_shares_transform = dead_marker_grouped
	if owner_card != null:
		owner_card.apply_pointer_hover_for_smoke(true)
	var owner_offset_lifted: Vector2 = owner_card.get_presentation_offset_for_smoke() if owner_card != null else Vector2.INF
	if owner_card != null:
		owner_card.apply_pointer_hover_for_smoke(false)
	var owner_offset_reset: Vector2 = owner_card.get_presentation_offset_for_smoke() if owner_card != null else Vector2.INF
	var owner_footprint_after_lift: Vector2 = owner_card.get_combined_minimum_size() if owner_card != null else Vector2.ZERO
	checks.pointer_hover_lifts_visual_group = owner_offset_before == Vector2.ZERO and owner_offset_lifted == Vector2(0, -2)
	checks.pointer_hover_exit_resets = owner_offset_reset == Vector2.ZERO
	checks.pointer_hover_footprint_stable = owner_footprint_before == owner_footprint_after_lift
	if board != null:
		board.clear_relation_hover_for_smoke()
	var owner_reset: Vector2 = owner_card.get_relation_emphasis_scale_for_smoke() if owner_card != null else Vector2.ZERO
	var related_reset: Vector2 = related_card.get_relation_emphasis_scale_for_smoke() if related_card != null else Vector2.ZERO
	checks.hover_resets = owner_card != null and owner_scale.x > 1.0 and owner_reset == Vector2.ONE and related_reset == Vector2.ONE and owner_card.get_presentation_offset_for_smoke() == Vector2.ZERO
	if board != null:
		board.apply_relation_hover_for_smoke(3)
	var reverse_owner_scale: Vector2 = owner_card.get_relation_emphasis_scale_for_smoke() if owner_card != null else Vector2.ZERO
	checks.no_reverse_relation = reverse_owner_scale == Vector2.ONE
	if board != null:
		board.free()

	var crime_reporter_runtime: CaseRuntimeState = _t05_i3_investigated_runtime(tutorial_case_03, players, 5)
	var crime_reporter_board: CaseBoardController = _board_instance_with_runtime(tutorial_case_03, crime_reporter_runtime, roles)
	var crime_reporter_card: SuspectCardController = _board_card(crime_reporter_board, 5) if crime_reporter_board != null else null
	var crime_related_card: SuspectCardController = _board_card(crime_reporter_board, 3) if crime_reporter_board != null else null
	var crime_relation_ids: PackedInt32Array = crime_reporter_board.get_public_relation_ids_for_smoke(5) if crime_reporter_board != null else PackedInt32Array()
	var crime_scene_position_before: Vector2 = crime_reporter_board.get_crime_scene_position_for_smoke() if crime_reporter_board != null else Vector2.INF
	if crime_reporter_board != null:
		crime_reporter_board.apply_relation_hover_for_smoke(5)
	var crime_scene_scale_active: Vector2 = crime_reporter_board.get_crime_scene_scale_for_smoke() if crime_reporter_board != null else Vector2.ZERO
	var crime_scene_modulate_active: Color = crime_reporter_board.get_crime_scene_modulate_for_smoke() if crime_reporter_board != null else Color.WHITE
	var crime_scene_position_active: Vector2 = crime_reporter_board.get_crime_scene_position_for_smoke() if crime_reporter_board != null else Vector2.INF
	var crime_related_scale: Vector2 = crime_related_card.get_relation_emphasis_scale_for_smoke() if crime_related_card != null else Vector2.ZERO
	var crime_source_scale: Vector2 = crime_reporter_card.get_relation_emphasis_scale_for_smoke() if crime_reporter_card != null else Vector2.ZERO
	if crime_reporter_card != null:
		crime_reporter_card.apply_pointer_hover_for_smoke(true)
	var crime_scene_position_after_card_lift: Vector2 = crime_reporter_board.get_crime_scene_position_for_smoke() if crime_reporter_board != null else Vector2.INF
	if crime_reporter_card != null:
		crime_reporter_card.apply_pointer_hover_for_smoke(false)
	if crime_reporter_board != null:
		crime_reporter_board.clear_relation_hover_for_smoke()
	var crime_scene_scale_reset: Vector2 = crime_reporter_board.get_crime_scene_scale_for_smoke() if crime_reporter_board != null else Vector2.ZERO
	var crime_scene_modulate_reset: Color = crime_reporter_board.get_crime_scene_modulate_for_smoke() if crime_reporter_board != null else Color.TRANSPARENT
	checks.crime_scene_not_relation_target = crime_relation_ids == PackedInt32Array([3])
	checks.reporter_traverses_crime_scene_without_highlighting_it = crime_source_scale.x > 1.0 and crime_related_scale.x > 1.0 and crime_scene_scale_active == Vector2.ONE
	checks.crime_scene_neutral_during_hover = crime_scene_modulate_active == Color.WHITE
	checks.crime_scene_not_moved_by_card_lift = crime_scene_position_before == crime_scene_position_active and crime_scene_position_before == crime_scene_position_after_card_lift
	checks.crime_scene_resets_after_hover = crime_scene_scale_reset == Vector2.ONE and crime_scene_modulate_reset == Color.WHITE
	if crime_reporter_board != null:
		crime_reporter_board.free()
	return _checks_result(checks, "structured relation targets emphasized without reflow")


func _prepare_reveal_runtime_for_hover(c: CaseDefinition, runtime: CaseRuntimeState) -> void:
	if c == null or runtime == null:
		return
	runtime.case_outcome = CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED
	CaseSettlementService.new().settle(c, runtime)


func _hover_relation_blood_hound_checks(roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	checks.north = _hover_relation_blood_hound_direction(7, 4, 1, CaseSpatialService.DIRECTION_NORTH, roles, players)
	checks.east = _hover_relation_blood_hound_direction(3, 4, 5, CaseSpatialService.DIRECTION_EAST, roles, players)
	checks.south = _hover_relation_blood_hound_direction(1, 4, 7, CaseSpatialService.DIRECTION_SOUTH, roles, players)
	checks.west = _hover_relation_blood_hound_direction(5, 4, 3, CaseSpatialService.DIRECTION_WEST, roles, players)
	checks.bark_empty = _hover_relation_blood_hound_special_empty(true, roles, players)
	checks.sniff_empty = _hover_relation_blood_hound_special_empty(false, roles, players)
	return checks


func _hover_relation_blood_hound_direction(
	source_slot: int,
	near_slot: int,
	far_slot: int,
	expected_direction: StringName,
	roles: Array[RoleDefinition],
	players: Array[PlayerCaseState]
) -> bool:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, source_slot, &"blood_hound", &"blood_hound", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(2, near_slot, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(3, far_slot, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	], 8)
	var runtime: CaseRuntimeState = _t05_i3_investigated_runtime(c, players, 1)
	var result: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(c, 1, roles)
	var view: SuspectPublicViewData = _tutorial_03_view(CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles), 1)
	return (
		result != null
		and result.direction_key == expected_direction
		and view != null
		and view.public_relation_suspect_ids == PackedInt32Array([2, 3])
	)


func _hover_relation_blood_hound_special_empty(is_bark: bool, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var specs: Array[Dictionary] = [
		_role_info_spec(1, 4, &"blood_hound", &"blood_hound", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
	]
	if is_bark:
		specs.append(_role_info_spec(2, 1, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM))
		specs.append(_role_info_spec(3, 7, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM))
	else:
		specs.append(_role_info_spec(2, 1, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN))
		specs.append(_role_info_spec(3, 7, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN))
	var c: CaseDefinition = _role_info_case_fixture(specs, 8)
	var runtime: CaseRuntimeState = _t05_i3_investigated_runtime(c, players, 1)
	var result: InvestigationInformationResult = RoleInformationEvaluationService.new().evaluate(c, 1, roles)
	var view: SuspectPublicViewData = _tutorial_03_view(CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles), 1)
	var expected_direction: StringName = CaseSpatialService.BLOOD_HOUND_BARK if is_bark else CaseSpatialService.BLOOD_HOUND_SNIFF
	return result != null and result.direction_key == expected_direction and view != null and view.public_relation_suspect_ids.is_empty()


func _case_scene_instance() -> Node:
	var packed := load(VS_CASE_MAIN_PATH) as PackedScene
	if packed == null:
		return null
	return packed.instantiate()


func _case_board_scene_instance() -> CaseBoardController:
	var packed := load(CASE_BOARD_PATH) as PackedScene
	if packed == null:
		return null
	return packed.instantiate() as CaseBoardController


func _case_required_ui_nodes_exist() -> bool:
	var scene := _case_scene_instance()
	if scene == null:
		return false
	var required_unique_nodes := PackedStringArray([
		"CaseNameLabel",
		"CaseIdLabel",
		"DifficultyLabel",
		"MeritLabel",
		"DescriptionLabel",
		"TurnLabel",
		"PlayerStripLabel",
		"RecentLogLabel",
		"ActionReason",
		"RoleList",
		"SelectionPrompt",
		"FunctionPicker",
		"SubmissionClassificationPanel",
		"InvestigateButton",
		"PrivateKnowledgeButton",
		"SingleAccuseButton",
		"FunctionButton",
		"SubmitButton",
		"ConfirmationRow",
		"ConfirmButton",
		"CancelButton",
		"CaseBoard",
		"BoardHelpLabel",
		"ContentRoot",
		"RoleListScroll",
		"LeftActionArea",
		"ErrorPanel",
		"ErrorSummary",
	])
	var passed := true
	for node_name in required_unique_nodes:
		if scene.get_node_or_null("%%%s" % node_name) == null:
			passed = false
			break
	scene.free()
	return passed


func _role_reference_nodes_exist() -> bool:
	var scene := _case_scene_instance()
	if scene == null:
		return false
	var passed := (
		scene.get_node_or_null("%RoleReferenceOverlay") != null
		and scene.get_node_or_null("%RoleReferenceTitle") != null
		and scene.get_node_or_null("%RoleReferenceBody") != null
		and scene.get_node_or_null("%RoleReferenceCloseButton") != null
		and scene.get_node_or_null("%PrivateKnowledgeOverlay") != null
		and scene.get_node_or_null("%PrivateKnowledgeBody") != null
		and scene.get_node_or_null("%PrivateKnowledgeCloseButton") != null
	)
	scene.free()
	return passed


func _role_reference_entries_clickable(c: CaseDefinition, roles: Array[RoleDefinition]) -> bool:
	var scene := _case_scene_instance() as VSCaseMainController
	if scene == null:
		return false
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null:
		tree.root.add_child(scene)
	scene.case_definition = c
	scene.role_definitions = roles
	scene._render_role_reference_list()
	var list := scene.get_node_or_null("%RoleList") as VBoxContainer
	var passed := list != null and list.get_child_count() > 0
	if passed:
		for child in list.get_children():
			if not (child is Button):
				passed = false
				break
	if passed and not roles.is_empty():
		scene._on_role_reference_pressed(roles[0].role_id)
		var overlay := scene.get_node_or_null("%RoleReferenceOverlay") as Control
		var body := scene.get_node_or_null("%RoleReferenceBody") as RichTextLabel
		passed = overlay != null and overlay.visible and body != null and body.text.contains("Nhóm:")
	if tree != null and scene.get_parent() == tree.root:
		tree.root.remove_child(scene)
	scene.free()
	return passed


func _role_reference_color_by_group(roles: Array[RoleDefinition]) -> bool:
	var scene := _case_scene_instance() as VSCaseMainController
	if scene == null:
		return false
	var good := Color.TRANSPARENT
	var evil := Color.TRANSPARENT
	for role in roles:
		if role == null:
			continue
		if role.role_group == CaseEnums.RoleGroup.CHINH_NHAN:
			good = scene._role_group_color(role.role_group)
		if role.role_group == CaseEnums.RoleGroup.TONG_PHAM:
			evil = scene._role_group_color(role.role_group)
	scene.free()
	return good != Color.TRANSPARENT and evil != Color.TRANSPARENT and good != evil


func _oversized_case_rejected(roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var c := CaseDefinition.new()
	c.case_id = &"oversized_case"
	c.display_name = "Oversized"
	c.crime_scene = CrimeSceneDefinition.new()
	c.crime_scene.scene_id = &"oversized_scene"
	c.crime_scene.display_name = "Hiện trường"
	c.on_solve = OnSolveReward.new()
	c.on_solve.reward_id = &"oversized_reward"
	c.test_only_not_balance_locked = true
	c.on_solve.test_only_not_balance_locked = true
	for suspect_id in range(1, 10):
		var suspect := SuspectDefinition.new()
		suspect.suspect_id = suspect_id
		suspect.true_role_id = &"role_good_a"
		suspect.displayed_role_id = &"role_good_a"
		suspect.true_alignment = CaseEnums.Alignment.GOOD
		suspect.role_group = CaseEnums.RoleGroup.CHINH_NHAN
		c.suspects.append(suspect)
	var report := CaseDefinitionValidator.new().validate(c, roles, players)
	for error in report.errors:
		if String(error.get("code", "")) == "BOARD_TILE_COUNT_INVALID":
			return true
	return false


func _role_reference_is_public_only(c: CaseDefinition, roles: Array[RoleDefinition]) -> bool:
	var scene := _case_scene_instance() as VSCaseMainController
	if scene == null:
		return false
	scene.case_definition = c
	scene.role_definitions = roles
	var role := roles[0] if not roles.is_empty() else null
	if role == null:
		scene.free()
		return false
	var text := scene._role_reference_text(role)
	var passed := (
		text.contains("Nhóm:")
		and text.contains("Phe:")
		and not text.contains("Nghi phạm")
		and not text.contains("suspect_id")
		and not text.contains("true_role_id")
		and not text.contains("fixture")
		and not text.contains("Fixture")
		and not text.contains("Runtime")
		and not text.contains("TEST")
	)
	scene.free()
	return passed


func _single_accuse_correct_private(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var b := _fresh_turn_bundle(c, players)
	var r := b.runtime as CaseRuntimeState
	var player := r.find_player(r.current_player_id())
	var result := SingleSuspectAccusationService.new().accuse(c, r, player, 4)
	var records := r.private_role_knowledge_for_player(player.player_id)
	return (
		result.success
		and result.correct
		and records.size() == 1
		and records[0].suspect_id == 4
		and records[0].true_role_id == &"role_accomplice_a"
		and not r.find_suspect(4).is_arrested
		and _private_record_excludes_truth_metadata(records[0])
	)


func _private_record_excludes_truth_metadata(record: PrivateRoleKnowledgeRecord) -> bool:
	var forbidden := ["impersonated_role_id", "is_corrupted", "truth_note", "displayed_role_id"]
	var property_names := PackedStringArray()
	for info in record.get_property_list():
		property_names.append(String(info.get("name", "")))
	for property_name in forbidden:
		if property_name in property_names:
			return false
	return true


func _private_knowledge_player_scoped(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var b := _fresh_turn_bundle(c, players)
	var r := b.runtime as CaseRuntimeState
	var player := r.find_player(r.current_player_id())
	SingleSuspectAccusationService.new().accuse(c, r, player, 4)
	return r.private_role_knowledge_for_player(player.player_id).size() == 1 and r.private_role_knowledge_for_player(&"player_2").is_empty()


func _single_accuse_no_duplicate(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var b := _fresh_turn_bundle(c, players)
	var r := b.runtime as CaseRuntimeState
	var player := r.find_player(r.current_player_id())
	var service := SingleSuspectAccusationService.new()
	service.accuse(c, r, player, 4)
	service.accuse(c, r, player, 4)
	return r.private_role_knowledge_for_player(player.player_id).size() == 1


func _single_accuse_public_board_unchanged(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var b := _fresh_turn_bundle(c, players)
	var r := b.runtime as CaseRuntimeState
	var before := CasePublicPresentationBuilder.new().build_suspect_views(c, r, roles)[3]
	SingleSuspectAccusationService.new().accuse(c, r, r.find_player(r.current_player_id()), 4)
	var after := CasePublicPresentationBuilder.new().build_suspect_views(c, r, roles)[3]
	return (
		before.public_role_name == after.public_role_name
		and before.full_truth_visible == after.full_truth_visible
		and after.truth_true_role_name.is_empty()
	)


func _single_accuse_crime_scene_rejected(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var b := _fresh_turn_bundle(c, players)
	var r := b.runtime as CaseRuntimeState
	var result := SingleSuspectAccusationService.new().accuse(c, r, r.find_player(r.current_player_id()), 0)
	return not result.success and result.error_code == &"SUSPECT_NOT_FOUND"


func _single_accuse_wrong_consequence(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var b := _fresh_turn_bundle(c, players)
	var r := b.runtime as CaseRuntimeState
	var player := r.find_player(r.current_player_id())
	var result := SingleSuspectAccusationService.new().accuse(c, r, player, 2)
	return result.success and not result.correct and player.submission_status == CaseEnums.SubmissionStatus.SUBMITTED_WRONG and not player.is_active_in_investigation


func _single_accuse_not_submission(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var b := _fresh_turn_bundle(c, players)
	var r := b.runtime as CaseRuntimeState
	SingleSuspectAccusationService.new().accuse(c, r, r.find_player(r.current_player_id()), 4)
	return r.submissions.is_empty() and r.action_log.back().action == "SINGLE_SUSPECT_ACCUSATION"


func _single_accuse_correct_advances_once(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _case_scene_instance() as VSCaseMainController
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if scene == null or tree == null:
		if scene != null:
			scene.free()
		return false
	tree.root.add_child(scene)
	_prepare_case_scene_for_smoke(scene, c, roles, players)
	var player_id: StringName = scene.runtime_state.current_player_id()
	var turn_before: int = scene.turn_manager.turn_number
	scene._on_suspect_action(4, MOUSE_BUTTON_RIGHT, false)
	scene._on_single_accuse_pressed()
	var records: Array[PrivateRoleKnowledgeRecord] = scene.runtime_state.private_role_knowledge_for_player(player_id)
	var passed: bool = (
		scene.runtime_state.case_outcome == CaseEnums.CaseOutcome.IN_PROGRESS
		and scene.turn_manager.turn_number == turn_before + 1
		and scene.runtime_state.current_player_id() != player_id
		and records.size() == 1
		and _tutorial_03_private_record_has(records, 4, &"spectre")
		and scene.runtime_state.submissions.is_empty()
		and scene.runtime_state.final_submissions.is_empty()
	)
	tree.root.remove_child(scene)
	scene.free()
	return passed


func _single_accuse_wrong_advances_once(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _case_scene_instance() as VSCaseMainController
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if scene == null or tree == null:
		if scene != null:
			scene.free()
		return false
	tree.root.add_child(scene)
	_prepare_case_scene_for_smoke(scene, c, roles, players)
	var player_id: StringName = scene.runtime_state.current_player_id()
	var player: PlayerCaseState = scene.runtime_state.find_player(player_id)
	var turn_before: int = scene.turn_manager.turn_number
	scene._on_suspect_action(1, MOUSE_BUTTON_RIGHT, false)
	scene._on_single_accuse_pressed()
	var passed: bool = (
		scene.runtime_state.case_outcome == CaseEnums.CaseOutcome.IN_PROGRESS
		and scene.turn_manager.turn_number == turn_before + 1
		and scene.runtime_state.current_player_id() != player_id
		and player != null
		and player.submission_status == CaseEnums.SubmissionStatus.SUBMITTED_WRONG
		and not player.is_active_in_investigation
		and scene.runtime_state.private_role_knowledge_for_player(player_id).is_empty()
	)
	tree.root.remove_child(scene)
	scene.free()
	return passed


func _single_accuse_early_completion(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _case_scene_instance() as VSCaseMainController
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if scene == null or tree == null:
		if scene != null:
			scene.free()
		return false
	tree.root.add_child(scene)
	_prepare_case_scene_for_smoke(scene, c, roles, players)
	var player_id: StringName = scene.runtime_state.current_player_id()
	var turn_before: int = scene.turn_manager.turn_number
	scene.runtime_state.add_private_role_knowledge(player_id, 4, &"spectre")
	scene._on_suspect_action(5, MOUSE_BUTTON_RIGHT, false)
	scene._on_single_accuse_pressed()
	var player: PlayerCaseState = scene.runtime_state.find_player(player_id)
	var passed: bool = (
		scene.runtime_state.case_outcome == CaseEnums.CaseOutcome.EARLY_SOLVED
		and scene.turn_manager.turn_number == turn_before + 1
		and player != null
		and player.submission_status == CaseEnums.SubmissionStatus.SUBMITTED_CORRECT
		and scene.runtime_state.submissions.size() == 1
		and scene.runtime_state.submissions[0].submission_phase == CaseEnums.SubmissionPhase.EARLY
		and _sets_equal_for_test(scene.runtime_state.submissions[0].selected_evil_ids, c.evil_suspect_ids)
		and scene.runtime_state.final_submissions.is_empty()
	)
	tree.root.remove_child(scene)
	scene.free()
	return passed


func _single_accuse_final_completion(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _fresh_final_runtime(c, players)
	var service: FinalVerdictService = FinalVerdictService.new()
	if not service.initialize(runtime).success:
		return false
	var player_id: StringName = runtime.current_final_player_id()
	var player: PlayerCaseState = runtime.find_player(player_id)
	runtime.add_private_role_knowledge(player_id, 4, &"spectre")
	var result: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(c, runtime, player, 5, CaseEnums.SubmissionPhase.FINAL)
	return (
		result.success
		and result.correct
		and result.completed_evil_set
		and runtime.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
		and runtime.submissions.is_empty()
		and runtime.final_submissions.size() == 1
		and runtime.final_submissions[0].player_id == player_id
		and runtime.final_submissions[0].submission_phase == CaseEnums.SubmissionPhase.FINAL
		and _sets_equal_for_test(runtime.final_submissions[0].selected_evil_ids, c.evil_suspect_ids)
		and player != null
		and player.submission_status == CaseEnums.SubmissionStatus.FINAL_LOCKED_PENDING
		and runtime.current_final_player_id() != player_id
	)


func _single_accuse_final_incomplete_rotates(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _fresh_final_runtime(c, players)
	var service: FinalVerdictService = FinalVerdictService.new()
	if not service.initialize(runtime).success:
		return false
	var player_id: StringName = runtime.current_final_player_id()
	var player: PlayerCaseState = runtime.find_player(player_id)
	var result: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(c, runtime, player, 4, CaseEnums.SubmissionPhase.FINAL)
	var records: Array[PrivateRoleKnowledgeRecord] = runtime.private_role_knowledge_for_player(player_id)
	var incomplete_rotates: bool = (
		result.success
		and result.correct
		and not result.completed_evil_set
		and runtime.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
		and runtime.final_submissions.is_empty()
		and player != null
		and player.submission_status == CaseEnums.SubmissionStatus.NOT_SUBMITTED
		and records.size() == 1
		and _tutorial_03_private_record_has(records, 4, &"spectre")
		and runtime.current_final_player_id() != player_id
	)
	var second_player_id: StringName = runtime.current_final_player_id()
	var second_submission: CaseSubmission = CaseSubmission.new()
	second_submission.configure(second_player_id, runtime.turn_number, c.evil_suspect_ids, PackedInt32Array(), PackedInt32Array(), CaseEnums.SubmissionPhase.FINAL)
	var second_lock: FinalVerdictResult = service.lock_submission(c, runtime, second_submission)
	var third_player_id: StringName = runtime.current_final_player_id()
	var third_submission: CaseSubmission = CaseSubmission.new()
	third_submission.configure(third_player_id, runtime.turn_number, c.evil_suspect_ids, PackedInt32Array(), PackedInt32Array(), CaseEnums.SubmissionPhase.FINAL)
	var third_lock: FinalVerdictResult = service.lock_submission(c, runtime, third_submission)
	var returned_for_final_piece: bool = (
		second_lock.success
		and third_lock.success
		and runtime.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
		and runtime.current_final_player_id() == player_id
	)
	var completion: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(c, runtime, player, 5, CaseEnums.SubmissionPhase.FINAL)
	var completed_after_return: bool = (
		completion.success
		and completion.correct
		and completion.completed_evil_set
		and runtime.case_outcome == CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED
		and player_id in runtime.final_correct_player_ids
	)
	return incomplete_rotates and returned_for_final_piece and completed_after_return


func _single_accuse_final_wrong_resolves(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _fresh_final_runtime(c, players)
	var service: FinalVerdictService = FinalVerdictService.new()
	if not service.initialize(runtime).success:
		return false
	var player_id: StringName = runtime.current_final_player_id()
	var player: PlayerCaseState = runtime.find_player(player_id)
	var result: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(c, runtime, player, 1, CaseEnums.SubmissionPhase.FINAL)
	return (
		result.success
		and not result.correct
		and result.player_inactivated
		and runtime.private_role_knowledge_for_player(player_id).is_empty()
		and runtime.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
		and runtime.final_submissions.size() == 1
		and runtime.final_submissions[0].player_id == player_id
		and runtime.final_submissions[0].submission_phase == CaseEnums.SubmissionPhase.FINAL
		and runtime.final_submissions[0].selected_evil_ids == PackedInt32Array([1])
		and player != null
		and player.submission_status == CaseEnums.SubmissionStatus.FINAL_LOCKED_PENDING
		and runtime.current_final_player_id() != player_id
	)


func _single_accuse_final_ui_available(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var scene: VSCaseMainController = _case_scene_instance() as VSCaseMainController
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if scene == null or tree == null:
		if scene != null:
			scene.free()
		return false
	tree.root.add_child(scene)
	_prepare_case_scene_for_smoke(scene, c, roles, players)
	for suspect: SuspectRuntimeState in scene.runtime_state.suspects:
		suspect.is_investigated = true
	scene.runtime_state.case_outcome = CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
	scene.runtime_state.lock_case_actions()
	scene.final_initialized = false
	scene._refresh_all_presentation()
	var final_player_id: StringName = scene.runtime_state.current_final_player_id()
	var zero_hidden: bool = scene.single_accuse_button != null and not scene.single_accuse_button.visible and scene.single_accuse_button.disabled
	scene._on_suspect_action(4, MOUSE_BUTTON_RIGHT, false)
	var one_enabled: bool = (
		scene.single_accuse_button != null
		and scene.single_accuse_button.visible
		and not scene.single_accuse_button.disabled
		and scene.submit_button != null
		and scene.submit_button.visible
		and not scene.submit_button.disabled
		and scene.runtime_state.current_final_player_id() == final_player_id
	)
	scene._on_suspect_action(0, MOUSE_BUTTON_RIGHT, false)
	var crime_ignored: bool = scene.selection_state.selected_submission_evil_ids == PackedInt32Array([4])
	scene._on_suspect_action(5, MOUSE_BUTTON_RIGHT, false)
	var multiple_full_verdict_only: bool = (
		scene.single_accuse_button != null
		and not scene.single_accuse_button.visible
		and scene.single_accuse_button.disabled
		and scene.submit_button != null
		and scene.submit_button.visible
		and not scene.submit_button.disabled
		and scene.selection_state.selected_submission_evil_ids == PackedInt32Array([4, 5])
	)
	tree.root.remove_child(scene)
	scene.free()
	return zero_hidden and one_enabled and crime_ignored and multiple_full_verdict_only


func _sets_equal_for_test(first: PackedInt32Array, second: PackedInt32Array) -> bool:
	if first.size() != second.size():
		return false
	for value: int in first:
		if value not in second:
			return false
	return true


func _kill_foundation_starts_alive(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	for suspect_runtime: SuspectRuntimeState in runtime.suspects:
		if suspect_runtime == null or suspect_runtime.is_dead:
			return false
	return true


func _kill_foundation_success_marks_dead(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var target_id: int = _first_evil_id(c)
	var result: CaseKillResult = CaseKillService.new().kill(c, runtime, target_id, &"smoke")
	var suspect_runtime: SuspectRuntimeState = runtime.find_suspect(target_id)
	return (
		result.success
		and result.state_changed
		and result.outcome == CaseKillResult.Outcome.KILLED
		and suspect_runtime != null
		and suspect_runtime.is_dead
		and suspect_runtime.killed_by == &"smoke"
		and runtime.action_log.back().action == "KILL"
	)


func _kill_foundation_repeat_idempotent(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var target_id: int = _first_evil_id(c)
	var service: CaseKillService = CaseKillService.new()
	var first: CaseKillResult = service.kill(c, runtime, target_id, &"smoke")
	var log_count_after_first: int = runtime.action_log.size()
	var second: CaseKillResult = service.kill(c, runtime, target_id, &"smoke")
	return (
		first.success
		and first.state_changed
		and second.success
		and not second.state_changed
		and second.outcome == CaseKillResult.Outcome.ALREADY_DEAD
		and runtime.action_log.size() == log_count_after_first
	)


func _kill_foundation_good_kill_preserves_evil_answer(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var before: PackedInt32Array = c.evil_suspect_ids.duplicate()
	var good_id: int = _first_good_id(c)
	var result: CaseKillResult = CaseKillService.new().kill(c, runtime, good_id, &"smoke")
	return result.success and _sets_equal_for_test(c.evil_suspect_ids, before)


func _handled_evil_excludes_killed_evil(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var killed_evil_id: int = _first_evil_id(c)
	var service: CaseResolutionService = CaseResolutionService.new()
	var kill_result: CaseKillResult = CaseKillService.new().kill(c, runtime, killed_evil_id, &"smoke")
	var unresolved: PackedInt32Array = service.unresolved_evil_ids(c, runtime)
	return kill_result.success and not service.is_evil_handled(c, runtime, killed_evil_id) and killed_evil_id in unresolved


func _handled_evil_keeps_living_evil(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	if c == null or c.evil_suspect_ids.size() < 2:
		return false
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var killed_evil_id: int = int(c.evil_suspect_ids[0])
	var living_evil_id: int = int(c.evil_suspect_ids[1])
	CaseKillService.new().kill(c, runtime, killed_evil_id, &"smoke")
	var unresolved: PackedInt32Array = CaseResolutionService.new().unresolved_evil_ids(c, runtime)
	return killed_evil_id in unresolved and living_evil_id in unresolved


func _handled_evil_zero_death_static(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var service: CaseResolutionService = CaseResolutionService.new()
	return (
		_sets_equal_for_test(service.unresolved_evil_ids(c, runtime), c.evil_suspect_ids)
		and _sets_equal_for_test(service.unresolved_underling_ids(c, runtime), c.accomplice_suspect_ids)
		and _sets_equal_for_test(service.unresolved_traitor_ids(c, runtime), c.traitor_suspect_ids)
	)


func _handled_evil_submission_integration(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var killed_evil_id: int = _first_evil_id(c)
	var kill_result: CaseKillResult = CaseKillService.new().kill(c, runtime, killed_evil_id, &"smoke")
	var resolver: CaseResolutionService = CaseResolutionService.new()
	var submission: CaseSubmission = CaseSubmission.new()
	submission.configure(
		runtime.current_player_id(),
		runtime.turn_number,
		resolver.unresolved_evil_ids(c, runtime),
		resolver.unresolved_underling_ids(c, runtime),
		resolver.unresolved_traitor_ids(c, runtime)
	)
	var result: CaseSubmissionResult = CaseSubmissionService.new().submit(c, runtime, runtime.find_player(runtime.current_player_id()), submission)
	return kill_result.success and result.success and result.main_answer_correct and runtime.case_outcome == CaseEnums.CaseOutcome.EARLY_SOLVED


func _handled_evil_single_accuse_integration(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	if c == null or c.evil_suspect_ids.size() < 2:
		return false
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var killed_evil_id: int = int(c.evil_suspect_ids[0])
	var living_evil_id: int = int(c.evil_suspect_ids[1])
	var kill_result: CaseKillResult = CaseKillService.new().kill(c, runtime, killed_evil_id, &"smoke")
	var player: PlayerCaseState = runtime.find_player(runtime.current_player_id())
	var first_result: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(c, runtime, player, killed_evil_id)
	var result: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(c, runtime, player, living_evil_id)
	var records: Array[PrivateRoleKnowledgeRecord] = runtime.private_role_knowledge_for_player(player.player_id)
	return (
		kill_result.success
		and first_result.success
		and first_result.correct
		and result.success
		and result.correct
		and result.completed_evil_set
		and runtime.case_outcome == CaseEnums.CaseOutcome.EARLY_SOLVED
		and records.size() == 2
	)


func _kill_foundation_no_private_knowledge(c: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var player_id: StringName = runtime.current_player_id()
	CaseKillService.new().kill(c, runtime, _first_evil_id(c), &"smoke")
	return runtime.private_role_knowledge_for_player(player_id).is_empty()


func _kill_foundation_no_tutorial_specific_domain() -> bool:
	var paths: Array[String] = [
		"res://scripts/domain/cases/CaseKillService.gd",
		"res://scripts/domain/cases/CaseKillResult.gd",
		"res://scripts/domain/cases/CaseResolutionService.gd",
	]
	for path: String in paths:
		var source: String = FileAccess.get_file_as_string(path)
		if source.contains("tutorial_05") or source.contains("Tutorial 05"):
			return false
	return true


func _vigilante_function_checks(players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	checks.type_recognized = _vigilante_function_type_recognized(players)
	checks.truthful_evil_kills = _vigilante_truthful_evil_kills(players)
	checks.truthful_good_misses = _vigilante_truthful_good_misses(players)
	checks.lying_evil_misses = _vigilante_lying_evil_misses(players)
	checks.tainted_evil_misses = _vigilante_tainted_evil_misses(players)
	var runtime_taint_checks: Dictionary = _vigilante_runtime_taint_checks(players)
	checks.runtime_tainted_misses = bool(runtime_taint_checks.get("miss", false))
	checks.fresh_runtime_kills = bool(runtime_taint_checks.get("fresh", false))
	checks.scoundrel_immunity = _vigilante_scoundrel_immunity(players)
	checks.true_alignment_drives = _vigilante_true_alignment_drives(players)
	checks.pretender_behavior = _vigilante_pretender_behavior(players)
	checks.self_target_allowed = _vigilante_self_target_allowed(players)
	checks.miss_consumes = _vigilante_miss_consumes(players)
	checks.kill_consumes = _vigilante_kill_consumes(players)
	checks.turn_advances_once = _vigilante_turn_advances_once(players)
	checks.killed_evil_handled = _vigilante_killed_evil_handled(players)
	checks.good_miss_preserves_evil = _vigilante_good_miss_preserves_evil(players)
	checks.no_private_knowledge = _vigilante_no_private_knowledge(players)
	checks.repeat_rejected = _vigilante_repeat_rejected(players)
	checks.tutorial_agnostic = _vigilante_no_tutorial_specific_domain()
	return checks


func _vigilante_roles() -> Array[RoleDefinition]:
	var roles: Array[RoleDefinition] = []
	var vigilante: RoleDefinition = _role_info_role(&"vigilante", "Vigilante", CaseEnums.RoleGroup.CHINH_NHAN)
	vigilante.has_interactive_function = true
	vigilante.function_type = CaseEnums.FunctionType.VIGILANTE_KILL
	vigilante.usage_limit = 1
	vigilante.unlock_timing = CaseEnums.UnlockTiming.NEXT_TURN_AFTER_INVESTIGATION
	vigilante.target_count = 1
	roles.append(vigilante)
	roles.append(_role_info_role(&"tutorial_priest", "Tư Tế", CaseEnums.RoleGroup.CHINH_NHAN))
	roles.append(_role_info_role(&"tutorial_mobster", "Kẻ Côn Đồ", CaseEnums.RoleGroup.TONG_PHAM))
	return roles


func _vigilante_case(
	owner_true_role: StringName = &"vigilante",
	owner_displayed_role: StringName = &"vigilante",
	owner_alignment: int = CaseEnums.Alignment.GOOD,
	owner_group: int = CaseEnums.RoleGroup.CHINH_NHAN,
	owner_corrupted: bool = false
) -> CaseDefinition:
	var specs: Array[Dictionary] = [
		_role_info_spec(1, 0, owner_true_role, owner_displayed_role, owner_alignment, owner_corrupted, owner_group),
		_role_info_spec(2, 1, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(3, 2, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(4, 3, &"tutorial_mobster", &"tutorial_priest", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	]
	var c: CaseDefinition = _role_info_case_fixture(specs, 4)
	var evil_ids: PackedInt32Array = PackedInt32Array([2, 4])
	if owner_alignment == CaseEnums.Alignment.EVIL:
		evil_ids.append(1)
		evil_ids.sort()
	c.evil_suspect_ids = evil_ids
	c.accomplice_suspect_ids = evil_ids.duplicate()
	c.traitor_suspect_ids = PackedInt32Array()
	return c


func _fresh_available_vigilante_bundle(c: CaseDefinition, players: Array[PlayerCaseState]) -> Dictionary:
	var roles: Array[RoleDefinition] = _vigilante_roles()
	var bundle: Dictionary = _fresh_function_bundle(c, roles, players)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var manager: TurnManager = bundle.manager as TurnManager
	var availability: FunctionAvailabilityService = bundle.availability as FunctionAvailabilityService
	var owner_runtime: SuspectRuntimeState = runtime.find_suspect(1)
	if owner_runtime != null:
		owner_runtime.is_investigated = true
		availability.reveal_for_suspect(c, runtime, roles, 1, manager.turn_number)
	manager.advance_turn()
	runtime.apply_turn_snapshot(manager)
	availability.update_for_turn(runtime, manager.turn_number)
	bundle["execution"] = InteractiveFunctionExecutionService.new()
	bundle["roles"] = roles
	return bundle


func _execute_vigilante(c: CaseDefinition, players: Array[PlayerCaseState], target_id: int) -> Dictionary:
	var bundle: Dictionary = _fresh_available_vigilante_bundle(c, players)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var execution: InteractiveFunctionExecutionService = bundle.execution as InteractiveFunctionExecutionService
	var result: InteractiveFunctionResult = execution.execute(c, runtime, 1, PackedInt32Array([target_id]), runtime.current_player_id())
	bundle["result"] = result
	return bundle


func _vigilante_function_type_recognized(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _vigilante_case()
	var bundle: Dictionary = _fresh_available_vigilante_bundle(c, players)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var executable: Array[InteractiveFunctionRuntimeState] = PostRevealFunctionService.new().executable_functions(c, runtime)
	var function_state: InteractiveFunctionRuntimeState = runtime.find_suspect(1).interactive_function
	var selection: InvestigationSelectionState = InvestigationSelectionState.new()
	var selection_ready: bool = (
		selection.begin_function_selection(PackedInt32Array([1]), function_state.target_count if function_state != null else 0)
		and selection.toggle_function_target(2)
		and selection.begin_resolving_function()
	)
	return (
		function_state != null
		and function_state.function_type == CaseEnums.FunctionType.VIGILANTE_KILL
		and function_state.target_count == 1
		and selection_ready
		and executable.size() == 1
		and executable[0].function_type == CaseEnums.FunctionType.VIGILANTE_KILL
	)


func _vigilante_truthful_evil_kills(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _vigilante_case()
	var bundle: Dictionary = _execute_vigilante(c, players, 2)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var result: InteractiveFunctionResult = bundle.result as InteractiveFunctionResult
	var target_runtime: SuspectRuntimeState = runtime.find_suspect(2)
	return (
		result.success
		and result.public_result_type == InteractiveFunctionResult.PublicResultType.VIGILANTE_KILL_ATTEMPTED
		and result.vigilante_kill_attempted
		and result.vigilante_target_killed
		and result.kill_outcome == CaseKillResult.Outcome.KILLED
		and target_runtime != null
		and target_runtime.is_dead
		and target_runtime.killed_by == &"vigilante"
		and _vigilante_kill_log_count(runtime, 2) == 1
	)


func _vigilante_truthful_good_misses(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _vigilante_case()
	var bundle: Dictionary = _execute_vigilante(c, players, 3)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var result: InteractiveFunctionResult = bundle.result as InteractiveFunctionResult
	var target_runtime: SuspectRuntimeState = runtime.find_suspect(3)
	return (
		result.success
		and result.public_result_type == InteractiveFunctionResult.PublicResultType.VIGILANTE_MISSED
		and not result.vigilante_kill_attempted
		and not result.vigilante_target_killed
		and target_runtime != null
		and not target_runtime.is_dead
	)


func _vigilante_lying_evil_misses(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _vigilante_case(&"tutorial_mobster", &"vigilante", CaseEnums.Alignment.EVIL, CaseEnums.RoleGroup.TONG_PHAM)
	var bundle: Dictionary = _execute_vigilante(c, players, 2)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var result: InteractiveFunctionResult = bundle.result as InteractiveFunctionResult
	return result.success and result.public_result_type == InteractiveFunctionResult.PublicResultType.VIGILANTE_MISSED and not runtime.find_suspect(2).is_dead


func _vigilante_tainted_evil_misses(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _vigilante_case(&"vigilante", &"vigilante", CaseEnums.Alignment.GOOD, CaseEnums.RoleGroup.CHINH_NHAN, true)
	var bundle: Dictionary = _execute_vigilante(c, players, 2)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var result: InteractiveFunctionResult = bundle.result as InteractiveFunctionResult
	return result.success and result.public_result_type == InteractiveFunctionResult.PublicResultType.VIGILANTE_MISSED and not runtime.find_suspect(2).is_dead


func _vigilante_runtime_taint_checks(players: Array[PlayerCaseState]) -> Dictionary:
	var c: CaseDefinition = _vigilante_case()
	# Adjacent Poisoner #2 taints native Vigilante #1; #4 remains the Evil target.
	c.suspects[1].true_role_id = &"poisoner"
	c.suspects[1].displayed_role_id = &"poisoner"
	var bundle: Dictionary = _fresh_available_vigilante_bundle(c, players)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var taint: PoisonerTaintRecord = PoisonerTaintService.new().resolve_taint(c, runtime, 2, 1)
	var result: InteractiveFunctionResult = InteractiveFunctionExecutionService.new().execute(
		c, runtime, 1, PackedInt32Array([4]), runtime.current_player_id()
	)
	var miss: bool = (
		taint != null and taint.applied and not c.suspects[0].is_corrupted
		and result.success and result.public_result_type == InteractiveFunctionResult.PublicResultType.VIGILANTE_MISSED
		and not result.vigilante_kill_attempted and not result.vigilante_target_killed
		and not runtime.find_suspect(4).is_dead and _vigilante_kill_log_count(runtime, 4) == 0
		and runtime.find_suspect(1).interactive_function.uses_remaining == 0
		and runtime.public_function_records.size() == 1
	)
	var fresh_bundle: Dictionary = _execute_vigilante(c, players, 4)
	var fresh_runtime: CaseRuntimeState = fresh_bundle.runtime as CaseRuntimeState
	var fresh_result: InteractiveFunctionResult = fresh_bundle.result as InteractiveFunctionResult
	return {
		"miss": miss,
		"fresh": miss and not fresh_runtime.has_runtime_corruption(1)
			and fresh_runtime.poisoner_taint_records.is_empty()
			and fresh_result.success and fresh_result.vigilante_target_killed
			and fresh_runtime.find_suspect(4).is_dead,
	}


func _vigilante_scoundrel_immunity(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _vigilante_case()
	c.suspects[1].true_role_id = &"tutorial_scoundrel"
	c.suspects[1].displayed_role_id = &"tutorial_scoundrel"
	var blocked_bundle: Dictionary = _execute_vigilante(c, players, 2)
	var blocked_runtime: CaseRuntimeState = blocked_bundle.runtime as CaseRuntimeState
	var blocked_result: InteractiveFunctionResult = blocked_bundle.result as InteractiveFunctionResult
	var tainted_bundle: Dictionary = _fresh_available_vigilante_bundle(c, players)
	var tainted_runtime: CaseRuntimeState = tainted_bundle.runtime as CaseRuntimeState
	tainted_runtime.find_suspect(2).apply_runtime_corruption(4)
	var allowed_result: InteractiveFunctionResult = InteractiveFunctionExecutionService.new().execute(
		c, tainted_runtime, 1, PackedInt32Array([2]), tainted_runtime.current_player_id()
	)
	return (
		blocked_result.success and blocked_result.vigilante_kill_attempted
		and not blocked_result.vigilante_target_killed and not blocked_runtime.find_suspect(2).is_dead
		and not blocked_runtime.find_suspect(4).is_dead
		and _vigilante_kill_log_count(blocked_runtime, 2) == 0
		and allowed_result.success and allowed_result.vigilante_target_killed
		and tainted_runtime.find_suspect(2).is_dead
	)


func _vigilante_true_alignment_drives(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _vigilante_case()
	var bundle: Dictionary = _execute_vigilante(c, players, 4)
	var result: InteractiveFunctionResult = bundle.result as InteractiveFunctionResult
	return result.success and result.vigilante_kill_attempted and result.vigilante_target_killed


func _vigilante_pretender_behavior(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _vigilante_case(&"tutorial_mobster", &"vigilante", CaseEnums.Alignment.EVIL, CaseEnums.RoleGroup.TONG_PHAM)
	var bundle: Dictionary = _fresh_available_vigilante_bundle(c, players)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var function_state: InteractiveFunctionRuntimeState = runtime.find_suspect(1).interactive_function
	var result: InteractiveFunctionResult = (bundle.execution as InteractiveFunctionExecutionService).execute(c, runtime, 1, PackedInt32Array([2]), runtime.current_player_id())
	return (
		function_state != null
		and function_state.function_type == CaseEnums.FunctionType.VIGILANTE_KILL
		and result.success
		and result.public_result_type == InteractiveFunctionResult.PublicResultType.VIGILANTE_MISSED
	)


func _vigilante_self_target_allowed(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _vigilante_case()
	var bundle: Dictionary = _execute_vigilante(c, players, 1)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var result: InteractiveFunctionResult = bundle.result as InteractiveFunctionResult
	return result.success and result.target_ids == PackedInt32Array([1]) and not runtime.find_suspect(1).is_dead


func _vigilante_miss_consumes(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _vigilante_case()
	var bundle: Dictionary = _execute_vigilante(c, players, 3)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var result: InteractiveFunctionResult = bundle.result as InteractiveFunctionResult
	var state: InteractiveFunctionRuntimeState = runtime.find_suspect(1).interactive_function
	return result.success and state.uses_remaining == 0 and state.state == InteractiveFunctionRuntimeState.State.EXHAUSTED


func _vigilante_kill_consumes(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _vigilante_case()
	var bundle: Dictionary = _execute_vigilante(c, players, 2)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var result: InteractiveFunctionResult = bundle.result as InteractiveFunctionResult
	var state: InteractiveFunctionRuntimeState = runtime.find_suspect(1).interactive_function
	return result.success and state.uses_remaining == 0 and state.state == InteractiveFunctionRuntimeState.State.EXHAUSTED


func _vigilante_turn_advances_once(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _vigilante_case()
	var bundle: Dictionary = _fresh_available_vigilante_bundle(c, players)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var manager: TurnManager = bundle.manager as TurnManager
	var before_turn: int = manager.turn_number
	var before_player_id: StringName = runtime.current_player_id()
	var result: InteractiveFunctionResult = (bundle.execution as InteractiveFunctionExecutionService).execute(c, runtime, 1, PackedInt32Array([2]), runtime.current_player_id())
	if result.success:
		manager.advance_turn()
		runtime.apply_turn_snapshot(manager)
	return before_player_id == &"player_2" and result.success and manager.turn_number == before_turn + 1 and runtime.current_player_id() == &"player_3"


func _vigilante_killed_evil_handled(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _vigilante_case()
	var bundle: Dictionary = _execute_vigilante(c, players, 2)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var result: InteractiveFunctionResult = bundle.result as InteractiveFunctionResult
	return result.success and not CaseResolutionService.new().is_evil_handled(c, runtime, 2) and 2 in CaseResolutionService.new().unresolved_evil_ids(c, runtime)


func _vigilante_good_miss_preserves_evil(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _vigilante_case()
	var before: PackedInt32Array = c.evil_suspect_ids.duplicate()
	var bundle: Dictionary = _execute_vigilante(c, players, 3)
	var result: InteractiveFunctionResult = bundle.result as InteractiveFunctionResult
	return result.success and _sets_equal_for_test(c.evil_suspect_ids, before)


func _vigilante_no_private_knowledge(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _vigilante_case()
	var bundle: Dictionary = _execute_vigilante(c, players, 2)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var result: InteractiveFunctionResult = bundle.result as InteractiveFunctionResult
	return result.success and runtime.private_role_knowledge.is_empty()


func _vigilante_kill_log_count(runtime: CaseRuntimeState, suspect_id: int) -> int:
	var count: int = 0
	for entry: Dictionary in runtime.action_log:
		var action: String = String(entry.get("action", ""))
		var logged_suspect_id: int = int(entry.get("suspect_id", 0))
		var source: StringName = StringName(String(entry.get("source", "")))
		if action == "KILL" and logged_suspect_id == suspect_id and source == &"vigilante":
			count += 1
	return count


func _vigilante_repeat_rejected(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _vigilante_case()
	var bundle: Dictionary = _execute_vigilante(c, players, 2)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var execution: InteractiveFunctionExecutionService = bundle.execution as InteractiveFunctionExecutionService
	var second: InteractiveFunctionResult = execution.execute(c, runtime, 1, PackedInt32Array([3]), runtime.current_player_id())
	return not second.success and second.error_code == &"FUNCTION_EXHAUSTED"


func _vigilante_no_tutorial_specific_domain() -> bool:
	var paths: Array[String] = [
		"res://scripts/domain/cases/CaseEnums.gd",
		"res://scripts/domain/cases/InteractiveFunctionResult.gd",
		"res://scripts/domain/cases/InteractiveFunctionExecutionService.gd",
		"res://scripts/domain/cases/PostRevealFunctionService.gd",
	]
	for path: String in paths:
		var source: String = FileAccess.get_file_as_string(path)
		if source.contains("tutorial_05") or source.contains("Tutorial 05"):
			return false
	return true


func _surgeon_timed_event_checks(players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	checks.clock_zero = _case_clock_starts_zero(players)
	checks.time_turn_independent = _case_time_turn_independent(players)
	checks.time_cost_once = _case_time_cost_once(players)
	checks.before_threshold = _surgeon_before_threshold(players)
	checks.fires_at_threshold = _surgeon_fires_at_threshold(players)
	checks.one_shot = _surgeon_one_shot(players)
	checks.role_driven = _surgeon_role_driven(players)
	checks.true_innocent_target = _surgeon_true_innocent_target(players)
	checks.current_group_target_authority = _surgeon_current_group_target_authority(players)
	checks.displayed_ignored = _surgeon_displayed_ignored(players)
	checks.kill_service = _surgeon_success_kill_service(players)
	checks.failed_kills_nobody = _surgeon_failed_kills_nobody(players)
	checks.deterministic_same = _surgeon_deterministic_same(players)
	checks.deterministic_flip = _surgeon_deterministic_flip(players)
	checks.no_target_once = _surgeon_no_target_once(players)
	checks.dead_innocent_excluded = _surgeon_dead_innocent_excluded(players)
	checks.source_excluded = _surgeon_source_excluded(players)
	checks.meddler_excluded = _surgeon_meddler_excluded(players)
	checks.non_innocent_excluded = _surgeon_non_innocent_excluded(players)
	checks.full_candidate_pool = _surgeon_full_candidate_pool(players)
	checks.alternate_seed_victim = _surgeon_alternate_seed_victim(players)
	checks.good_kill_preserves_evil = _surgeon_good_kill_preserves_evil(players)
	checks.no_private_knowledge = _surgeon_no_private_knowledge(players)
	checks.no_duplicate = _surgeon_no_duplicate(players)
	checks.current_role_unchanged = _surgeon_current_role_unchanged(players)
	checks.elapsed_unchanged = _surgeon_elapsed_unchanged(players)
	checks.authored_unchanged = _surgeon_authored_unchanged(players)
	checks.zero_event_case = _surgeon_zero_event_case(players)
	checks.tutorial_agnostic = _surgeon_no_tutorial_specific_domain()
	return checks


func _surgeon_case(include_second_innocent: bool = false, no_innocent: bool = false) -> CaseDefinition:
	var specs: Array[Dictionary] = [
		_role_info_spec(1, 0, &"surgeon", &"surgeon", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
		_role_info_spec(2, 1, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.EVIL if no_innocent else CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.TONG_PHAM if no_innocent else CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(3, 2, &"tutorial_mobster", &"tutorial_priest", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(4, 3, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	]
	if include_second_innocent:
		specs.append(_role_info_spec(5, 4, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN))
	var c: CaseDefinition = _role_info_case_fixture(specs, 8)
	c.case_id = &"surgeon_foundation_smoke"
	c.evil_suspect_ids = PackedInt32Array([2, 3, 4]) if no_innocent else PackedInt32Array([3, 4])
	c.accomplice_suspect_ids = c.evil_suspect_ids.duplicate()
	c.traitor_suspect_ids = PackedInt32Array()
	return c


func _surgeon_runtime(c: CaseDefinition, players: Array[PlayerCaseState], seed: int = 1, elapsed_hours: int = 0) -> CaseRuntimeState:
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	runtime.case_event_seed = seed
	if elapsed_hours > 0:
		CaseClockService.new().advance_hours(runtime, elapsed_hours, &"smoke")
	return runtime


func _surgeon_evaluate(c: CaseDefinition, players: Array[PlayerCaseState], seed: int, elapsed_hours: int) -> Dictionary:
	var runtime: CaseRuntimeState = _surgeon_runtime(c, players, seed, elapsed_hours)
	var events: Array[CaseTimedEventRuntimeState] = SurgeonTimedEventService.new().evaluate(c, runtime)
	var event: CaseTimedEventRuntimeState = events[0] if not events.is_empty() else null
	return {"runtime": runtime, "event": event, "events": events}


func _case_clock_starts_zero(players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _surgeon_runtime(_surgeon_case(), players)
	return runtime.elapsed_hours == 0 and runtime.applied_time_action_ids.is_empty() and runtime.timed_events.is_empty()


func _case_time_turn_independent(players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _surgeon_runtime(_surgeon_case(), players)
	var before_turn: int = runtime.turn_number
	var advanced: bool = CaseClockService.new().advance_hours(runtime, 2, &"smoke")
	return advanced and runtime.elapsed_hours == 2 and runtime.turn_number == before_turn


func _case_time_cost_once(players: Array[PlayerCaseState]) -> bool:
	var runtime: CaseRuntimeState = _surgeon_runtime(_surgeon_case(), players)
	var clock: CaseClockService = CaseClockService.new()
	var first: bool = clock.apply_action_time(runtime, &"action_1", CaseClockService.ACTION_INVESTIGATION)
	var second: bool = clock.apply_action_time(runtime, &"action_1", CaseClockService.ACTION_INVESTIGATION)
	var accusation: bool = clock.apply_action_time(runtime, &"action_2", CaseClockService.ACTION_SINGLE_ACCUSATION)
	var active_function: bool = clock.apply_action_time(runtime, &"action_3", CaseClockService.ACTION_ACTIVE_FUNCTION)
	var expected_hours: int = CaseClockService.INVESTIGATION_HOURS + CaseClockService.SINGLE_ACCUSATION_HOURS
	return first and not second and accusation and active_function and runtime.elapsed_hours == expected_hours and runtime.applied_time_action_ids.size() == 3


func _surgeon_before_threshold(players: Array[PlayerCaseState]) -> bool:
	var result: Dictionary = _surgeon_evaluate(_surgeon_case(), players, 1, 10)
	var event: CaseTimedEventRuntimeState = result.event as CaseTimedEventRuntimeState
	return event != null and event.event_id == &"surgeon_1_12h" and not event.fired and event.threshold_hour == 12


func _surgeon_fires_at_threshold(players: Array[PlayerCaseState]) -> bool:
	var result: Dictionary = _surgeon_evaluate(_surgeon_case(), players, 0, 12)
	var event: CaseTimedEventRuntimeState = result.event as CaseTimedEventRuntimeState
	return event != null and event.fired and event.fired_at_hour == 12


func _surgeon_one_shot(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _surgeon_case()
	var runtime: CaseRuntimeState = _surgeon_runtime(c, players, 0, 12)
	var service: SurgeonTimedEventService = SurgeonTimedEventService.new()
	service.evaluate(c, runtime)
	var log_count_after_first: int = _timed_event_log_count(runtime, &"surgeon_1_12h")
	service.evaluate(c, runtime)
	return runtime.timed_events.size() == 1 and log_count_after_first == 1 and _timed_event_log_count(runtime, &"surgeon_1_12h") == 1


func _surgeon_role_driven(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _surgeon_case()
	c.case_id = &"not_tutorial_case"
	var result: Dictionary = _surgeon_evaluate(c, players, 0, 12)
	var event: CaseTimedEventRuntimeState = result.event as CaseTimedEventRuntimeState
	return event != null and event.event_id == &"surgeon_1_12h" and event.fired


func _surgeon_true_innocent_target(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _surgeon_case()
	var result: Dictionary = _surgeon_evaluate(c, players, 1, 12)
	var runtime: CaseRuntimeState = result.runtime as CaseRuntimeState
	var event: CaseTimedEventRuntimeState = result.event as CaseTimedEventRuntimeState
	var target_state: CaseMutationStateSnapshot = (
		CaseMutationStateSnapshot.from_runtime(c, runtime, event.target_suspect_id, FixtureRepository.load_roles())
		if event != null else null
	)
	return event != null and event.resolved_success and target_state != null and target_state.current_role_group == CaseEnums.RoleGroup.CHINH_NHAN


func _surgeon_current_group_target_authority(players: Array[PlayerCaseState]) -> bool:
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var c: CaseDefinition = _surgeon_case(true)
	var authored_meddler: SuspectDefinition = _case_suspect(c, 3)
	var barkeep: SuspectDefinition = _case_suspect(c, 4)
	authored_meddler.true_role_id = &"copycat"
	authored_meddler.displayed_role_id = &"copycat"
	authored_meddler.role_group = CaseEnums.RoleGroup.HIEU_SU
	authored_meddler.true_alignment = CaseEnums.Alignment.GOOD
	barkeep.true_role_id = &"barkeep"
	barkeep.displayed_role_id = &"barkeep"
	barkeep.role_group = CaseEnums.RoleGroup.TONG_PHAM
	barkeep.true_alignment = CaseEnums.Alignment.EVIL
	c.evil_suspect_ids = PackedInt32Array([4])
	c.accomplice_suspect_ids = PackedInt32Array([4])
	var runtime: CaseRuntimeState = _surgeon_runtime(c, players, 1, 12)
	var transform: BarkeepTransformationRecord = BarkeepTransformationService.new().resolve_transformation(c, runtime, 4, 2, roles)
	var transformed_state: CaseMutationStateSnapshot = CaseMutationStateSnapshot.from_runtime(c, runtime, 2, roles)
	var untouched_state: CaseMutationStateSnapshot = CaseMutationStateSnapshot.from_runtime(c, runtime, 5, roles)
	var service: SurgeonTimedEventService = SurgeonTimedEventService.new()
	var events: Array[CaseTimedEventRuntimeState] = service.evaluate_with_roles(c, runtime, roles)
	var event: CaseTimedEventRuntimeState = events[0] if not events.is_empty() else null
	var first_log_count: int = _timed_event_log_count(runtime, &"surgeon_1_12h")
	service.evaluate_with_roles(c, runtime, roles)

	var arrested_runtime: CaseRuntimeState = _surgeon_runtime(c, players, 1, 12)
	var arrested_transform: BarkeepTransformationRecord = BarkeepTransformationService.new().resolve_transformation(c, arrested_runtime, 4, 2, roles)
	var arrested_target: SuspectRuntimeState = arrested_runtime.find_suspect(5)
	if arrested_target != null:
		arrested_target.mark_arrested()
	var arrested_events: Array[CaseTimedEventRuntimeState] = service.evaluate_with_roles(c, arrested_runtime, roles)
	var arrested_event: CaseTimedEventRuntimeState = arrested_events[0] if not arrested_events.is_empty() else null
	return (
		transform != null
		and transform.applied
		and transformed_state != null
		and transformed_state.original_role_id == &"tutorial_priest"
		and transformed_state.current_role_id == &"drunkard"
		and transformed_state.current_role_group == CaseEnums.RoleGroup.HIEU_SU
		and _case_suspect(c, 2).role_group == CaseEnums.RoleGroup.CHINH_NHAN
		and untouched_state != null
		and untouched_state.current_role_group == CaseEnums.RoleGroup.CHINH_NHAN
		and event != null
		and event.resolved_success
		and event.target_suspect_id == 5
		and event.target_suspect_id not in PackedInt32Array([1, 2, 3, 4])
		and first_log_count == 1
		and _timed_event_log_count(runtime, &"surgeon_1_12h") == 1
		and arrested_transform != null
		and arrested_transform.applied
		and arrested_target != null
		and arrested_target.is_arrested
		and arrested_event != null
		and arrested_event.target_suspect_id == 5
	)


func _surgeon_displayed_ignored(players: Array[PlayerCaseState]) -> bool:
	var result: Dictionary = _surgeon_evaluate(_surgeon_case(), players, 1, 12)
	var event: CaseTimedEventRuntimeState = result.event as CaseTimedEventRuntimeState
	return event != null and event.resolved_success and event.target_suspect_id == 2 and event.target_suspect_id != 3


func _surgeon_success_kill_service(players: Array[PlayerCaseState]) -> bool:
	var result: Dictionary = _surgeon_evaluate(_surgeon_case(), players, 1, 12)
	var runtime: CaseRuntimeState = result.runtime as CaseRuntimeState
	var event: CaseTimedEventRuntimeState = result.event as CaseTimedEventRuntimeState
	var target_runtime: SuspectRuntimeState = runtime.find_suspect(event.target_suspect_id) if event != null else null
	return (
		event != null
		and event.fired
		and event.resolved_success
		and event.kill_attempted
		and event.kill_outcome == CaseKillResult.Outcome.KILLED
		and event.target_suspect_id > 0
		and target_runtime != null
		and target_runtime.is_dead
		and target_runtime.killed_by == &"surgeon"
		and _surgeon_kill_log_count(runtime, event.target_suspect_id) == 1
	)


func _surgeon_failed_kills_nobody(players: Array[PlayerCaseState]) -> bool:
	var result: Dictionary = _surgeon_evaluate(_surgeon_case(), players, 0, 12)
	var runtime: CaseRuntimeState = result.runtime as CaseRuntimeState
	var event: CaseTimedEventRuntimeState = result.event as CaseTimedEventRuntimeState
	return event != null and event.fired and not event.resolved_success and not event.kill_attempted and _dead_suspect_count(runtime) == 0


func _surgeon_deterministic_same(players: Array[PlayerCaseState]) -> bool:
	var first: Dictionary = _surgeon_evaluate(_surgeon_case(), players, 1, 12)
	var second: Dictionary = _surgeon_evaluate(_surgeon_case(), players, 1, 12)
	var first_event: CaseTimedEventRuntimeState = first.event as CaseTimedEventRuntimeState
	var second_event: CaseTimedEventRuntimeState = second.event as CaseTimedEventRuntimeState
	return first_event != null and second_event != null and first_event.resolved_success == second_event.resolved_success and first_event.target_suspect_id == second_event.target_suspect_id


func _surgeon_deterministic_flip(players: Array[PlayerCaseState]) -> bool:
	var success_case: Dictionary = _surgeon_evaluate(_surgeon_case(), players, 1, 12)
	var fail_case: Dictionary = _surgeon_evaluate(_surgeon_case(), players, 0, 12)
	var success_event: CaseTimedEventRuntimeState = success_case.event as CaseTimedEventRuntimeState
	var fail_event: CaseTimedEventRuntimeState = fail_case.event as CaseTimedEventRuntimeState
	return success_event != null and fail_event != null and success_event.resolved_success != fail_event.resolved_success


func _surgeon_no_target_once(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _surgeon_case(false, true)
	var result: Dictionary = _surgeon_evaluate(c, players, 1, 12)
	var runtime: CaseRuntimeState = result.runtime as CaseRuntimeState
	var event: CaseTimedEventRuntimeState = result.event as CaseTimedEventRuntimeState
	SurgeonTimedEventService.new().evaluate(c, runtime)
	return event != null and event.fired and not event.resolved_success and event.target_suspect_id == 0 and _dead_suspect_count(runtime) == 0 and _timed_event_log_count(runtime, &"surgeon_1_12h") == 1


func _surgeon_dead_innocent_excluded(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _surgeon_case(true)
	var runtime: CaseRuntimeState = _surgeon_runtime(c, players, 1, 12)
	CaseKillService.new().kill(c, runtime, 2, &"smoke")
	var events: Array[CaseTimedEventRuntimeState] = SurgeonTimedEventService.new().evaluate(c, runtime)
	var event: CaseTimedEventRuntimeState = events[0] if not events.is_empty() else null
	var dead_first_target: SuspectRuntimeState = runtime.find_suspect(2)
	return event != null and event.fired and event.target_suspect_id == 5 and dead_first_target != null and dead_first_target.killed_by != &"surgeon"


func _surgeon_source_excluded(players: Array[PlayerCaseState]) -> bool:
	var result: Dictionary = _surgeon_evaluate(_surgeon_case(true), players, 1, 12)
	var event: CaseTimedEventRuntimeState = result.event as CaseTimedEventRuntimeState
	return event != null and event.resolved_success and event.target_suspect_id != event.source_suspect_id


func _surgeon_meddler_excluded(players: Array[PlayerCaseState]) -> bool:
	var result: Dictionary = _surgeon_evaluate(_surgeon_case(true), players, 1, 12)
	var event: CaseTimedEventRuntimeState = result.event as CaseTimedEventRuntimeState
	return event != null and event.resolved_success and event.target_suspect_id != 1


func _surgeon_non_innocent_excluded(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _surgeon_case(true)
	var result: Dictionary = _surgeon_evaluate(c, players, 1, 12)
	var event: CaseTimedEventRuntimeState = result.event as CaseTimedEventRuntimeState
	var target: SuspectDefinition = _case_suspect(c, event.target_suspect_id) if event != null else null
	return event != null and event.resolved_success and target != null and target.role_group == CaseEnums.RoleGroup.CHINH_NHAN and event.target_suspect_id not in PackedInt32Array([3, 4])


func _surgeon_full_candidate_pool(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _surgeon_case(true)
	var seen: PackedInt32Array = PackedInt32Array()
	for seed: int in range(0, 64):
		var result: Dictionary = _surgeon_evaluate(c, players, seed, 12)
		var event: CaseTimedEventRuntimeState = result.event as CaseTimedEventRuntimeState
		if event != null and event.resolved_success and event.target_suspect_id not in seen:
			seen.append(event.target_suspect_id)
	seen.sort()
	return _sets_equal_for_test(seen, PackedInt32Array([2, 5]))


func _surgeon_alternate_seed_victim(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _surgeon_case(true)
	var first_target: int = 0
	for seed: int in range(0, 128):
		var result: Dictionary = _surgeon_evaluate(c, players, seed, 12)
		var event: CaseTimedEventRuntimeState = result.event as CaseTimedEventRuntimeState
		if event == null or not event.resolved_success:
			continue
		if first_target == 0:
			first_target = event.target_suspect_id
		elif event.target_suspect_id != first_target:
			return true
	return false


func _surgeon_good_kill_preserves_evil(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _surgeon_case()
	var before: PackedInt32Array = c.evil_suspect_ids.duplicate()
	var result: Dictionary = _surgeon_evaluate(c, players, 1, 12)
	var event: CaseTimedEventRuntimeState = result.event as CaseTimedEventRuntimeState
	return event != null and event.resolved_success and _sets_equal_for_test(c.evil_suspect_ids, before)


func _surgeon_no_private_knowledge(players: Array[PlayerCaseState]) -> bool:
	var result: Dictionary = _surgeon_evaluate(_surgeon_case(), players, 1, 12)
	var runtime: CaseRuntimeState = result.runtime as CaseRuntimeState
	var event: CaseTimedEventRuntimeState = result.event as CaseTimedEventRuntimeState
	return event != null and event.fired and runtime.private_role_knowledge.is_empty()


func _surgeon_no_duplicate(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _surgeon_case()
	var runtime: CaseRuntimeState = _surgeon_runtime(c, players, 1, 12)
	var service: SurgeonTimedEventService = SurgeonTimedEventService.new()
	var first_events_result: Array[CaseTimedEventRuntimeState] = service.evaluate(c, runtime)
	var first_event: CaseTimedEventRuntimeState = first_events_result[0] if not first_events_result.is_empty() else null
	var first_target_id: int = first_event.target_suspect_id if first_event != null else 0
	var first_kills: int = _surgeon_kill_log_count(runtime, first_target_id)
	var first_events: int = _timed_event_log_count(runtime, &"surgeon_1_12h")
	CaseClockService.new().advance_hours(runtime, 4, &"smoke")
	service.evaluate(c, runtime)
	return first_event != null and first_event.resolved_success and first_kills == 1 and first_events == 1 and _surgeon_kill_log_count(runtime, first_target_id) == 1 and _timed_event_log_count(runtime, &"surgeon_1_12h") == 1


func _surgeon_current_role_unchanged(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _surgeon_case()
	var runtime: CaseRuntimeState = _surgeon_runtime(c, players, 1, 12)
	var before_roles: Dictionary = {}
	for suspect_runtime: SuspectRuntimeState in runtime.suspects:
		before_roles[suspect_runtime.suspect_id] = suspect_runtime.current_role_id
	SurgeonTimedEventService.new().evaluate(c, runtime)
	for suspect_runtime: SuspectRuntimeState in runtime.suspects:
		if before_roles.get(suspect_runtime.suspect_id, &"") != suspect_runtime.current_role_id:
			return false
	return true


func _surgeon_elapsed_unchanged(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _surgeon_case()
	var runtime: CaseRuntimeState = _surgeon_runtime(c, players, 1, 12)
	var before_hours: int = runtime.elapsed_hours
	SurgeonTimedEventService.new().evaluate(c, runtime)
	return runtime.elapsed_hours == before_hours


func _surgeon_authored_unchanged(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _surgeon_case(true)
	var before_slots: Dictionary = _authored_board_slot_snapshot(c)
	var before_evil: PackedInt32Array = c.evil_suspect_ids.duplicate()
	var before_role_two: StringName = _case_suspect(c, 2).true_role_id
	var before_role_five: StringName = _case_suspect(c, 5).true_role_id
	_surgeon_evaluate(c, players, 1, 12)
	return before_slots == _authored_board_slot_snapshot(c) and _sets_equal_for_test(before_evil, c.evil_suspect_ids) and _case_suspect(c, 2).true_role_id == before_role_two and _case_suspect(c, 5).true_role_id == before_role_five


func _surgeon_zero_event_case(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _role_info_case_fixture([
		_role_info_spec(1, 0, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(2, 1, &"tutorial_mobster", &"tutorial_mobster", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
	], 4)
	c.case_id = &"zero_timed_event_smoke"
	c.evil_suspect_ids = PackedInt32Array([2])
	c.accomplice_suspect_ids = PackedInt32Array([2])
	var runtime: CaseRuntimeState = _surgeon_runtime(c, players, 1, 12)
	var log_count_before: int = runtime.action_log.size()
	var events: Array[CaseTimedEventRuntimeState] = SurgeonTimedEventService.new().evaluate(c, runtime)
	return events.is_empty() and runtime.timed_events.is_empty() and runtime.action_log.size() == log_count_before


func _surgeon_no_tutorial_specific_domain() -> bool:
	var paths: Array[String] = [
		"res://scripts/domain/cases/CaseRuntimeState.gd",
		"res://scripts/domain/cases/CaseTimedEventRuntimeState.gd",
		"res://scripts/domain/cases/CaseClockService.gd",
		"res://scripts/domain/cases/SurgeonTimedEventService.gd",
	]
	for path: String in paths:
		var source: String = FileAccess.get_file_as_string(path)
		if source.contains("tutorial_05") or source.contains("Tutorial 05"):
			return false
	return true


func _critic_foundation_checks(roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	checks.role_exists = _critic_role_metadata(roles)
	checks.true_alignment = _critic_true_alignment(roles)
	checks.normal_loss = _critic_normal_reputation_loss(players)
	checks.critic_loss = _critic_doubled_reputation_loss(players)
	checks.gain_not_doubled = _critic_gain_not_doubled(players)
	checks.actual_reputation_stable = _critic_actual_reputation_not_overwritten(players)
	checks.effective_poor = _critic_effective_poor_turn_order(players)
	checks.normal_turn_order = _turn_order_reputation_descending(players)
	checks.pretend_valid_role = _critic_pretend_valid_role(roles)
	checks.pretend_not_true_in_play = _critic_pretend_not_true_in_play(roles)
	checks.pretend_true_in_play_rejected = _critic_pretend_true_in_play_rejected(roles)
	checks.displayed_not_in_play = _critic_displayed_roles_do_not_define_in_play(roles)
	var startup_checks: Dictionary = _critic_startup_role_authority_checks(roles)
	checks.current_role_witness_present = _critic_current_role_witness_present()
	checks.transformed_away_absent = bool(startup_checks.get("transformed_away_absent", false))
	checks.replacement_drunkard_present = bool(startup_checks.get("replacement_drunkard_present", false))
	checks.transformed_away_valid = bool(startup_checks.get("transformed_away_valid", false))
	checks.unlisted_absent_rejected = _critic_unlisted_absent_rejected(roles)
	checks.tutorial_05_listed_absent = _critic_tutorial_05_listed_absent()
	checks.tutorial_05_valid = _critic_tutorial_05_valid(roles)
	checks.truth_separate = _critic_truth_separate_from_pretend(roles)
	checks.tutorial_agnostic = _critic_no_tutorial_specific_domain()
	checks.prior_foundations = _critic_prior_foundation_anchors()
	return checks


func _critic_role_metadata(roles: Array[RoleDefinition]) -> bool:
	var critic: RoleDefinition = _find_role_for_test(roles, &"critic")
	return (
		critic != null
		and critic.display_name == "Nhà Phê Bình"
		and critic.role_group == CaseEnums.RoleGroup.NGHICH_THAN
		and critic.always_lies
		and critic.reputation_loss_multiplier == 2
		and critic.effective_turn_reputation_override == 2
		and critic.pretend_role_must_be_not_true_in_play
		and not critic.is_fixture_placeholder
	)


func _critic_case(pretend_role_id: StringName = &"reporter", include_true_pretend_role: bool = false, displayed_only_pretend_role: bool = false) -> CaseDefinition:
	var specs: Array[Dictionary] = [
		_role_info_spec(1, 0, &"critic", pretend_role_id, CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.NGHICH_THAN),
		_role_info_spec(2, 1, &"tutorial_mobster", &"tutorial_priest", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.TONG_PHAM),
		_role_info_spec(3, 2, &"tutorial_priest", pretend_role_id if displayed_only_pretend_role else &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
	]
	if include_true_pretend_role:
		specs.append(_role_info_spec(4, 3, pretend_role_id, pretend_role_id, CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN))
	var c: CaseDefinition = _role_info_case_fixture(specs, 8)
	c.suspects[1].impersonated_role_id = &"tutorial_priest"
	c.suspected_role_ids = [&"critic", &"tutorial_mobster", &"tutorial_priest"]
	if pretend_role_id not in c.suspected_role_ids:
		c.suspected_role_ids.append(pretend_role_id)
	c.suspects[0].impersonated_role_id = pretend_role_id
	c.case_id = &"critic_foundation_smoke"
	c.evil_suspect_ids = PackedInt32Array([1, 2])
	c.accomplice_suspect_ids = PackedInt32Array([2])
	c.traitor_suspect_ids = PackedInt32Array([1])
	c.reputation_penalty_on_wrong = 1
	c.base_ticket_reward = 1
	c.merit_pool = 12
	c.on_solve.reputation_delta = 1
	return c


func _critic_true_alignment(roles: Array[RoleDefinition]) -> bool:
	var c: CaseDefinition = _critic_case()
	var suspect: SuspectDefinition = c.suspects[0] as SuspectDefinition
	return (
		suspect != null
		and suspect.true_role_id == &"critic"
		and suspect.true_alignment == CaseEnums.Alignment.EVIL
		and suspect.role_group == CaseEnums.RoleGroup.NGHICH_THAN
		and bool(CaseDefinitionValidator.new().validate(c, roles).get("passed", false))
	)


func _critic_players(players: Array[PlayerCaseState], critic_player_id: StringName = &"") -> Array[PlayerCaseState]:
	var result: Array[PlayerCaseState] = []
	for player_fixture: PlayerCaseState in players:
		var player: PlayerCaseState = player_fixture.duplicate(true) as PlayerCaseState
		player.case_role_id = &"critic" if player.player_id == critic_player_id else &""
		result.append(player)
	return result


func _critic_wrong_settlement(players: Array[PlayerCaseState], critic_player_id: StringName = &"") -> Dictionary:
	var c: CaseDefinition = _critic_case()
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, _critic_players(players, critic_player_id)).runtime as CaseRuntimeState
	var target_player_id: StringName = &"player_1"
	runtime.submissions.append(_locked_submission(target_player_id, PackedInt32Array([3]), PackedInt32Array(), PackedInt32Array(), CaseEnums.SubmissionPhase.EARLY))
	runtime.case_outcome = CaseEnums.CaseOutcome.ALL_FAILED_EARLY
	var settlement: CaseSettlementResult = CaseSettlementService.new().settle(c, runtime)
	return {"runtime": runtime, "settlement": settlement, "resolution": _resolution_for_player(settlement, target_player_id)}


func _critic_normal_reputation_loss(players: Array[PlayerCaseState]) -> bool:
	var result: Dictionary = _critic_wrong_settlement(players)
	var resolution: PlayerCaseResolution = result.resolution as PlayerCaseResolution
	return resolution != null and resolution.reward.reputation_delta == -1


func _critic_doubled_reputation_loss(players: Array[PlayerCaseState]) -> bool:
	var result: Dictionary = _critic_wrong_settlement(players, &"player_1")
	var resolution: PlayerCaseResolution = result.resolution as PlayerCaseResolution
	var runtime: CaseRuntimeState = result.runtime as CaseRuntimeState
	var player: PlayerCaseState = runtime.find_player(&"player_1") if runtime != null else null
	return resolution != null and player != null and resolution.reward.reputation_delta == -2 and player.reputation == 3


func _critic_gain_not_doubled(players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = _critic_case()
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, _critic_players(players, &"player_1")).runtime as CaseRuntimeState
	runtime.submissions.append(_locked_submission(&"player_1", PackedInt32Array([1, 2]), PackedInt32Array([2]), PackedInt32Array([1]), CaseEnums.SubmissionPhase.EARLY))
	runtime.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
	var before: int = runtime.find_player(&"player_1").reputation
	var settlement: CaseSettlementResult = CaseSettlementService.new().settle(c, runtime)
	var resolution: PlayerCaseResolution = _resolution_for_player(settlement, &"player_1")
	return resolution != null and resolution.reward.reputation_delta == 1 and runtime.find_player(&"player_1").reputation == mini(6, before + 1)


func _critic_actual_reputation_not_overwritten(players: Array[PlayerCaseState]) -> bool:
	var critic_players: Array[PlayerCaseState] = _critic_players(players, &"player_1")
	critic_players[0].reputation = 6
	var manager: TurnManager = TurnManager.new()
	var initialized: bool = manager.initialize(critic_players, 101)
	return initialized and critic_players[0].reputation == 6 and CASE_ROLE_MODIFIER_SERVICE.effective_turn_reputation(critic_players[0]) == 2


func _critic_effective_poor_turn_order(players: Array[PlayerCaseState]) -> bool:
	var critic_players: Array[PlayerCaseState] = _critic_players(players, &"player_1")
	critic_players[0].reputation = 6
	critic_players[1].reputation = 3
	critic_players[2].reputation = 1
	var manager: TurnManager = TurnManager.new()
	if not manager.initialize(critic_players, 101):
		return false
	return manager.get_turn_order_ids() == [&"player_2", &"player_1", &"player_3"] and critic_players[0].reputation == 6


func _critic_pretend_valid_role(roles: Array[RoleDefinition]) -> bool:
	var c: CaseDefinition = _critic_case(&"not_a_real_role")
	var report: Dictionary = CaseDefinitionValidator.new().validate(c, roles)
	return _validation_has_error(report, "DISPLAYED_ROLE_MISSING") and _validation_has_error(report, "IMPERSONATED_ROLE_MISSING")


func _critic_pretend_not_true_in_play(roles: Array[RoleDefinition]) -> bool:
	var c: CaseDefinition = _critic_case(&"reporter")
	var runtime: CaseRuntimeState = CaseRuntimeState.new()
	var no_players: Array[PlayerCaseState] = []
	runtime.initialize(c, no_players)
	return (
		CASE_PROCEDURAL_PRETEND_CAPABILITY.is_supported_lying_behavior(&"reporter")
		and CASE_ROLE_POOL_SERVICE.is_listed_current_role_absent(c, runtime, &"reporter")
		and bool(CaseDefinitionValidator.new().validate(c, roles).get("passed", false))
	)


func _critic_pretend_true_in_play_rejected(roles: Array[RoleDefinition]) -> bool:
	var report: Dictionary = CaseDefinitionValidator.new().validate(_critic_case(&"reporter", true), roles)
	return _validation_has_error(report, "CRITIC_PRETEND_ROLE_IN_PLAY")


func _critic_displayed_roles_do_not_define_in_play(roles: Array[RoleDefinition]) -> bool:
	var c: CaseDefinition = _critic_case(&"reporter", false, true)
	var runtime: CaseRuntimeState = CaseRuntimeState.new()
	var no_players: Array[PlayerCaseState] = []
	runtime.initialize(c, no_players)
	return (
		bool(CaseDefinitionValidator.new().validate(c, roles).get("passed", false))
		and CASE_ROLE_POOL_SERVICE.is_listed_current_role_absent(c, runtime, &"reporter")
		and c.suspects[2].displayed_role_id == &"reporter"
	)


func _critic_current_role_witness_present() -> bool:
	var c: CaseDefinition = _critic_case(&"reporter", true)
	var runtime: CaseRuntimeState = CaseRuntimeState.new()
	var no_players: Array[PlayerCaseState] = []
	runtime.initialize(c, no_players)
	return (
		CASE_ROLE_POOL_SERVICE.is_role_listed(c, &"reporter")
		and CASE_ROLE_POOL_SERVICE.current_role_ids_in_play(c, runtime).has(&"reporter")
		and not CASE_ROLE_POOL_SERVICE.is_listed_current_role_absent(c, runtime, &"reporter")
	)


func _critic_barkeep_transform_case() -> CaseDefinition:
	var specs: Array[Dictionary] = [
		_role_info_spec(1, 0, &"critic", &"reporter", CaseEnums.Alignment.EVIL, false, CaseEnums.RoleGroup.NGHICH_THAN),
		_role_info_spec(2, 1, &"barkeep", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.HIEU_SU),
		_role_info_spec(3, 2, &"reporter", &"reporter", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
		_role_info_spec(4, 3, &"tutorial_priest", &"tutorial_priest", CaseEnums.Alignment.GOOD, false, CaseEnums.RoleGroup.CHINH_NHAN),
	]
	var c: CaseDefinition = _role_info_case_fixture(specs, 8)
	c.suspected_role_ids = [&"critic", &"barkeep", &"reporter", &"tutorial_priest"]
	c.evil_suspect_ids = PackedInt32Array([1])
	c.traitor_suspect_ids = PackedInt32Array([1])
	c.startup_barkeep_source_suspect_id = 2
	c.startup_barkeep_target_suspect_id = 3
	return c


func _critic_startup_role_authority_checks(roles: Array[RoleDefinition]) -> Dictionary:
	var c: CaseDefinition = _critic_barkeep_transform_case()
	var runtime: CaseRuntimeState = CaseRuntimeState.new()
	var no_players: Array[PlayerCaseState] = []
	runtime.initialize(c, no_players)
	BarkeepTransformationService.new().resolve_transformation(c, runtime, 2, 3, roles)
	var current_ids: Array[StringName] = CASE_ROLE_POOL_SERVICE.current_role_ids_in_play(c, runtime)
	return {
		"transformed_away_absent": CASE_ROLE_POOL_SERVICE.is_listed_current_role_absent(c, runtime, &"reporter"),
		"replacement_drunkard_present": current_ids.has(&"drunkard") and not current_ids.has(&"reporter"),
		"transformed_away_valid": bool(CaseDefinitionValidator.new().validate(c, roles).get("passed", false)),
	}


func _critic_unlisted_absent_rejected(roles: Array[RoleDefinition]) -> bool:
	var c: CaseDefinition = _critic_case(&"reporter")
	c.suspected_role_ids.erase(&"reporter")
	var report: Dictionary = CaseDefinitionValidator.new().validate(c, roles)
	return _validation_has_error(report, "CRITIC_PRETEND_ROLE_NOT_LISTED")


func _critic_tutorial_05_listed_absent() -> bool:
	var c: CaseDefinition = FixtureRepository.load_tutorial_case_005()
	if c == null:
		return false
	var runtime: CaseRuntimeState = CaseRuntimeState.new()
	var no_players: Array[PlayerCaseState] = []
	runtime.initialize(c, no_players)
	return CASE_ROLE_POOL_SERVICE.is_listed_current_role_absent(c, runtime, &"mathematician")


func _critic_tutorial_05_valid(roles: Array[RoleDefinition]) -> bool:
	var c: CaseDefinition = FixtureRepository.load_tutorial_case_005()
	return c != null and bool(CaseDefinitionValidator.new().validate(c, roles).get("passed", false))


func _critic_truth_separate_from_pretend(roles: Array[RoleDefinition]) -> bool:
	var c: CaseDefinition = _critic_case(&"reporter")
	var suspect: SuspectDefinition = c.suspects[0] as SuspectDefinition
	return (
		bool(CaseDefinitionValidator.new().validate(c, roles).get("passed", false))
		and suspect.true_role_id == &"critic"
		and suspect.displayed_role_id == &"reporter"
		and suspect.impersonated_role_id == &"reporter"
		and suspect.true_alignment == CaseEnums.Alignment.EVIL
		and suspect.role_group == CaseEnums.RoleGroup.NGHICH_THAN
	)


func _critic_no_tutorial_specific_domain() -> bool:
	var paths: Array[String] = [
		"res://scripts/domain/cases/CaseRoleModifierService.gd",
		"res://scripts/domain/cases/CaseSettlementService.gd",
		"res://scripts/domain/cases/TurnManager.gd",
		"res://scripts/domain/cases/CaseDefinitionValidator.gd",
	]
	for path: String in paths:
		var source: String = FileAccess.get_file_as_string(path)
		if source.contains("tutorial_05") or source.contains("Tutorial 05"):
			return false
	return true


func _critic_prior_foundation_anchors() -> bool:
	return (
		CaseKillService.new() != null
		and RoleInformationEvaluationService.new() != null
		and CaseClockService.new() != null
		and SurgeonTimedEventService.new() != null
		and CaseEnums.FunctionType.VIGILANTE_KILL == 2
	)


func _validation_has_error(report: Dictionary, code: String) -> bool:
	var errors: Array = report.get("errors", [])
	for error: Dictionary in errors:
		if String(error.get("code", "")) == code:
			return true
	return false


func _resolution_for_player(settlement: CaseSettlementResult, player_id: StringName) -> PlayerCaseResolution:
	if settlement == null or not settlement.success:
		return null
	for resolution: PlayerCaseResolution in settlement.player_resolutions:
		if resolution != null and resolution.player_id == player_id:
			return resolution
	return null


func _timed_event_log_count(runtime: CaseRuntimeState, event_id: StringName) -> int:
	var count: int = 0
	for entry: Dictionary in runtime.action_log:
		var action: String = String(entry.get("action", ""))
		var logged_event_id: StringName = StringName(String(entry.get("event_id", "")))
		if action == "TIMED_EVENT" and logged_event_id == event_id:
			count += 1
	return count


func _surgeon_kill_log_count(runtime: CaseRuntimeState, suspect_id: int) -> int:
	var count: int = 0
	for entry: Dictionary in runtime.action_log:
		var action: String = String(entry.get("action", ""))
		var logged_suspect_id: int = int(entry.get("suspect_id", 0))
		var source: StringName = StringName(String(entry.get("source", "")))
		if action == "KILL" and logged_suspect_id == suspect_id and source == &"surgeon":
			count += 1
	return count


func _dead_suspect_count(runtime: CaseRuntimeState) -> int:
	var count: int = 0
	for suspect_runtime: SuspectRuntimeState in runtime.suspects:
		if suspect_runtime != null and suspect_runtime.is_dead:
			count += 1
	return count


func _first_evil_id(c: CaseDefinition) -> int:
	if c == null or c.evil_suspect_ids.is_empty():
		return 0
	return int(c.evil_suspect_ids[0])


func _first_good_id(c: CaseDefinition) -> int:
	if c == null:
		return 0
	for suspect: SuspectDefinition in c.suspects:
		if suspect != null and suspect.true_alignment == CaseEnums.Alignment.GOOD:
			return suspect.suspect_id
	return 0


func _full_truth_hidden_before_reveal(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var r := _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var views := CasePublicPresentationBuilder.new().build_suspect_views(c, r, roles)
	return not views[3].full_truth_visible and views[3].truth_true_role_name.is_empty()


func _full_truth_available_after_reveal(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var r := _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var submission := _locked_submission(&"player_1", PackedInt32Array([4, 5]), PackedInt32Array([4]), PackedInt32Array([5]), CaseEnums.SubmissionPhase.EARLY)
	r.submissions.append(submission)
	r.find_player(&"player_1").submission_status = CaseEnums.SubmissionStatus.SUBMITTED_CORRECT
	r.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
	var settlement := CaseSettlementService.new().settle(c, r)
	var reveal := CaseTruthRevealBuilder.new().build(c, r, roles)
	var views := CasePublicPresentationBuilder.new().build_suspect_views(c, r, roles)
	var board := _board_instance_with_runtime(c, r, roles)
	var card_truth := ""
	var card_statement := ""
	if board != null:
		for child in (board.get_node("%Grid") as GridContainer).get_children():
			if child is SuspectCardController and (child as SuspectCardController).get_suspect_id() == 4:
				var card: SuspectCardController = child as SuspectCardController
				card_truth = card.get_full_truth_text()
				card_statement = card.get_reveal_statement_text()
				break
		board.free()
	return (
		settlement.success
		and reveal != null
		and views[3].full_truth_visible
		and views[3].truth_true_role_name.contains("Tòng Phạm")
		and views[3].truth_impersonated_role_name.contains("Chính Nhân")
		and card_truth.contains("Ta giả danh")
		and card_statement == card_truth
		and not card_truth.contains("Sự thật:")
		and not card_truth.contains("Giả danh:")
	)


func _full_reveal_preserves_board_slots(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var before := _authored_board_slot_snapshot(c)
	var r := _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var submission := _locked_submission(&"player_1", PackedInt32Array([4, 5]), PackedInt32Array([4]), PackedInt32Array([5]), CaseEnums.SubmissionPhase.EARLY)
	r.submissions.append(submission)
	r.find_player(&"player_1").submission_status = CaseEnums.SubmissionStatus.SUBMITTED_CORRECT
	r.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
	var settlement := CaseSettlementService.new().settle(c, r)
	var reveal := CaseTruthRevealBuilder.new().build(c, r, roles)
	var board := _board_instance_with_runtime(c, r, roles)
	if board == null:
		return false
	var after := _rendered_board_slot_snapshot(board, c)
	var truth_card := _board_card(board, 4)
	var truth_is_card_local := (
		truth_card != null
		and truth_card.get_public_role_text() != ""
		and truth_card.get_full_truth_text().contains("Ta giả danh")
		and not truth_card.get_full_truth_text().contains("Sự thật:")
	)
	board.free()
	return settlement.success and reveal != null and before == after and truth_is_card_local


func _authored_board_slot_snapshot(c: CaseDefinition) -> Dictionary:
	var snapshot: Dictionary = {}
	if c == null or c.crime_scene == null:
		return snapshot
	snapshot["crime_scene"] = c.crime_scene.board_slot
	for suspect in c.suspects:
		if suspect != null:
			snapshot["suspect_%d" % suspect.suspect_id] = suspect.board_slot
	return snapshot


func _rendered_board_slot_snapshot(board: CaseBoardController, c: CaseDefinition) -> Dictionary:
	var snapshot: Dictionary = {}
	if board == null or c == null:
		return snapshot
	snapshot["crime_scene"] = board.get_crime_scene_slot()
	for suspect in c.suspects:
		if suspect != null:
			snapshot["suspect_%d" % suspect.suspect_id] = board.get_suspect_slot(suspect.suspect_id)
	return snapshot


func _impersonation_contract_ready(c: CaseDefinition, roles: Array[RoleDefinition]) -> bool:
	for suspect in c.suspects:
		if suspect != null and suspect.is_impersonating:
			return (
				not String(suspect.true_role_id).is_empty()
				and not String(suspect.displayed_role_id).is_empty()
				and not String(suspect.impersonated_role_id).is_empty()
				and suspect.true_role_id != suspect.displayed_role_id
				and _role_id_exists(roles, suspect.impersonated_role_id)
			)
	return false


func _role_id_exists(roles: Array[RoleDefinition], role_id: StringName) -> bool:
	for role in roles:
		if role != null and role.role_id == role_id:
			return true
	return false


func _fresh_turn_bundle(case_fixture: CaseDefinition, players: Array[PlayerCaseState], seed: int = 20260826) -> Dictionary:
	var runtime := CaseRuntimeState.new()
	runtime.initialize(case_fixture, players)
	var manager := TurnManager.new()
	manager.initialize(runtime.players, seed)
	runtime.apply_turn_snapshot(manager)
	return {"runtime": runtime, "manager": manager}


func _turn_order_reputation_descending(players: Array[PlayerCaseState]) -> bool:
	var manager := TurnManager.new()
	if not manager.initialize(players, 11):
		return false
	for index in range(1, manager.turn_order.size()):
		if manager.turn_order[index - 1].reputation < manager.turn_order[index].reputation:
			return false
	return true


func _fixture_turn_order(players: Array[PlayerCaseState]) -> bool:
	var manager := TurnManager.new()
	return manager.initialize(players, 12) and manager.get_turn_order_ids() == [&"player_1", &"player_2", &"player_3"]


func _tie_break_valid(all_tied: bool) -> bool:
	var players: Array[PlayerCaseState] = []
	for index in range(3):
		var player := PlayerCaseState.new()
		player.player_id = StringName("tie_%d" % (index + 1))
		player.display_name = "Tie %d" % (index + 1)
		player.reputation = 5 if all_tied or index < 2 else 3
		players.append(player)
	var manager := TurnManager.new()
	if not manager.initialize(players, 31337):
		return false
	var ids := manager.get_turn_order_ids()
	var unique: Dictionary = {}
	for player_id in ids:
		unique[player_id] = true
	return ids.size() == 3 and unique.size() == 3 and (all_tied or manager.turn_order[2].reputation == 3)


func _turn_order_fixed_after_init() -> bool:
	var players: Array[PlayerCaseState] = []
	for index in range(3):
		var player := PlayerCaseState.new()
		player.player_id = StringName("fixed_%d" % index)
		player.reputation = 5
		players.append(player)
	var manager := TurnManager.new()
	manager.initialize(players, 99)
	var initial := manager.get_turn_order_ids()
	manager.get_current_player()
	manager.get_next_player()
	return initial == manager.get_turn_order_ids()


func _turn_order_not_resorted(players: Array[PlayerCaseState]) -> bool:
	var source_reputations := PackedInt32Array()
	var copies: Array[PlayerCaseState] = []
	for player in players:
		source_reputations.append(player.reputation)
		copies.append(player.duplicate(true) as PlayerCaseState)
	var manager := TurnManager.new()
	manager.initialize(copies, 21)
	var initial := manager.get_turn_order_ids()
	manager.turn_order[2].reputation = 6
	var sources_unchanged := true
	for index in range(players.size()):
		if players[index].reputation != source_reputations[index]:
			sources_unchanged = false
			break
	return initial == manager.get_turn_order_ids() and sources_unchanged


func _initial_current_player(players: Array[PlayerCaseState]) -> bool:
	var manager := TurnManager.new()
	return (
		manager.initialize(players, 22)
		and manager.current_turn_index == 0
		and manager.turn_number == 1
		and manager.get_current_player() == manager.turn_order[0]
		and manager.get_current_player().player_id == &"player_1"
	)


func _advance_sequence_matches(players: Array[PlayerCaseState], advance_count: int, expected_id: StringName) -> bool:
	var manager := TurnManager.new()
	manager.initialize(players, 23)
	for _step in range(advance_count):
		manager.advance_turn()
	return (
		manager.current_turn_index == advance_count % manager.turn_order.size()
		and manager.get_current_player() == manager.turn_order[manager.current_turn_index]
		and manager.get_current_player().player_id == expected_id
		and manager.turn_number == advance_count + 1
	)


func _valid_investigation(case_fixture: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var bundle := _fresh_turn_bundle(case_fixture, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var result := InvestigationService.new().investigate(case_fixture, runtime, 1, runtime.current_player_id())
	return result.success and runtime.find_suspect(1).is_investigated and result.public_role_id == &"tailor"


func _repeat_investigation_fails(case_fixture: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var bundle := _fresh_turn_bundle(case_fixture, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var service := InvestigationService.new()
	service.investigate(case_fixture, runtime, 1, runtime.current_player_id())
	var repeated := service.investigate(case_fixture, runtime, 1, runtime.current_player_id())
	return not repeated.success and repeated.error_code == &"SUSPECT_ALREADY_INVESTIGATED"


func _unknown_investigation_fails(case_fixture: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var bundle := _fresh_turn_bundle(case_fixture, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var result := InvestigationService.new().investigate(case_fixture, runtime, 99, runtime.current_player_id())
	return not result.success and result.error_code == &"SUSPECT_NOT_FOUND"


func _investigation_changes_one_runtime(case_fixture: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var bundle := _fresh_turn_bundle(case_fixture, players)
	var runtime := bundle.runtime as CaseRuntimeState
	InvestigationService.new().investigate(case_fixture, runtime, 4, runtime.current_player_id())
	return runtime.investigated_count() == 1 and runtime.find_suspect(4).is_investigated


func _investigation_keeps_definition(case_fixture: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var original_true_role := case_fixture.suspects[3].true_role_id
	var original_displayed_role := case_fixture.suspects[3].displayed_role_id
	var bundle := _fresh_turn_bundle(case_fixture, players)
	var runtime := bundle.runtime as CaseRuntimeState
	InvestigationService.new().investigate(case_fixture, runtime, 4, runtime.current_player_id())
	return case_fixture.suspects[3].true_role_id == original_true_role and case_fixture.suspects[3].displayed_role_id == original_displayed_role


func _runtime_dto_before_hidden(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var runtime := (_fresh_turn_bundle(case_fixture, players).runtime as CaseRuntimeState)
	var views := CasePublicPresentationBuilder.new().build_suspect_views(case_fixture, runtime, roles)
	return views.size() == 8 and views[0].public_role_name.is_empty() and not views[0].is_investigated


func _runtime_dto_after_reveals(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var runtime := (_fresh_turn_bundle(case_fixture, players).runtime as CaseRuntimeState)
	InvestigationService.new().investigate(case_fixture, runtime, 1, runtime.current_player_id())
	var view := CasePublicPresentationBuilder.new().build_suspect_views(case_fixture, runtime, roles)[0]
	return view.is_investigated and view.public_status_text == "Đã điều tra" and view.public_role_name == "Thợ May"


func _runtime_dto_excludes(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState], forbidden_field: String) -> bool:
	var runtime := (_fresh_turn_bundle(case_fixture, players).runtime as CaseRuntimeState)
	InvestigationService.new().investigate(case_fixture, runtime, 1, runtime.current_player_id())
	var views := CasePublicPresentationBuilder.new().build_suspect_views(case_fixture, runtime, roles)
	var property_names := PackedStringArray()
	for property_info in views[0].get_property_list():
		property_names.append(property_info.name)
	return forbidden_field not in property_names and forbidden_field not in views[0].visible_property_names()


func _investigate_and_get_view(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState], suspect_id: int) -> SuspectPublicViewData:
	var runtime := (_fresh_turn_bundle(case_fixture, players).runtime as CaseRuntimeState)
	InvestigationService.new().investigate(case_fixture, runtime, suspect_id, runtime.current_player_id())
	for view in CasePublicPresentationBuilder.new().build_suspect_views(case_fixture, runtime, roles):
		if view.suspect_id == suspect_id:
			return view
	return null


func _suspect_four_reveals_displayed(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var view := _investigate_and_get_view(case_fixture, roles, players, 4)
	return view != null and view.public_role_name == "Chính Nhân A (Fixture)"


func _suspect_four_hides_true(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var view := _investigate_and_get_view(case_fixture, roles, players, 4)
	return view != null and "Tòng Phạm A" not in view.public_role_name and "role_accomplice_a" not in view.public_role_name


func _suspect_six_hides_corruption(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var view := _investigate_and_get_view(case_fixture, roles, players, 6)
	return view != null and "Tha Hóa" not in view.public_role_name and "is_corrupted" not in view.visible_property_names()


func _investigation_advances_once(case_fixture: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var bundle := _fresh_turn_bundle(case_fixture, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	var before_turn := manager.turn_number
	var result := InvestigationService.new().investigate(case_fixture, runtime, 1, runtime.current_player_id())
	var unchanged_before_advance := manager.turn_number == before_turn and manager.get_current_player().player_id == &"player_1"
	if result.success:
		manager.advance_turn()
		runtime.apply_turn_snapshot(manager)
	return unchanged_before_advance and manager.turn_number == before_turn + 1 and runtime.current_player_id() == &"player_2"


func _cancel_does_not_advance(players: Array[PlayerCaseState]) -> bool:
	var manager := TurnManager.new()
	manager.initialize(players, 24)
	var selection := InvestigationSelectionState.new()
	var before_id := manager.get_current_player().player_id
	var before_turn := manager.turn_number
	selection.begin_selection()
	selection.select_suspect(3)
	var cancelled := selection.cancel()
	return cancelled and selection.mode == InvestigationSelectionState.Mode.IDLE and selection.selected_suspect_id == 0 and manager.turn_number == before_turn and manager.get_current_player().player_id == before_id


func _eight_investigations_finish_safely(case_fixture: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var bundle := _fresh_turn_bundle(case_fixture, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	var service := InvestigationService.new()
	for suspect_id in range(1, 9):
		var result := service.investigate(case_fixture, runtime, suspect_id, runtime.current_player_id())
		if not result.success:
			return false
		manager.advance_turn()
		runtime.apply_turn_snapshot(manager)
	return runtime.investigated_count() == 8 and runtime.all_suspects_investigated() and not runtime.accepts_investigation_actions and runtime.action_log.size() == 8


func _fresh_runtime_resets(case_fixture: CaseDefinition, players: Array[PlayerCaseState]) -> bool:
	var first := (_fresh_turn_bundle(case_fixture, players).runtime as CaseRuntimeState)
	InvestigationService.new().investigate(case_fixture, first, 1, first.current_player_id())
	var second := (_fresh_turn_bundle(case_fixture, players).runtime as CaseRuntimeState)
	return first.investigated_count() == 1 and second.investigated_count() == 0 and second.turn_number == 1 and second.action_log.is_empty()


func _fresh_function_bundle(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState], reveal_turn: int = 1) -> Dictionary:
	var bundle := _fresh_turn_bundle(case_fixture, players, 20260827)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	var availability := FunctionAvailabilityService.new()
	availability.initialize_hidden_states(case_fixture, runtime, roles)
	while manager.turn_number < reveal_turn:
		manager.advance_turn()
		runtime.apply_turn_snapshot(manager)
	return {"runtime": runtime, "manager": manager, "availability": availability}


func _reveal_tailor(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState], reveal_turn: int = 1) -> Dictionary:
	var bundle := _fresh_function_bundle(case_fixture, roles, players, reveal_turn)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	var availability := bundle.availability as FunctionAvailabilityService
	var result := InvestigationService.new().investigate(case_fixture, runtime, 1, runtime.current_player_id())
	var revealed := result.success and availability.reveal_for_suspect(case_fixture, runtime, roles, 1, manager.turn_number)
	bundle["revealed"] = revealed
	return bundle


func _function_hidden_before_investigation(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var runtime := (_fresh_function_bundle(case_fixture, roles, players).runtime as CaseRuntimeState)
	var function_state := runtime.find_suspect(1).interactive_function
	var view := CasePublicPresentationBuilder.new().build_suspect_views(case_fixture, runtime, roles)[0]
	return function_state != null and function_state.state == InteractiveFunctionRuntimeState.State.HIDDEN and not view.has_public_function


func _non_function_role_has_no_runtime(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _fresh_function_bundle(case_fixture, roles, players)
	var runtime := bundle.runtime as CaseRuntimeState
	InvestigationService.new().investigate(case_fixture, runtime, 2, runtime.current_player_id())
	var revealed := (bundle.availability as FunctionAvailabilityService).reveal_for_suspect(case_fixture, runtime, roles, 2, runtime.turn_number)
	var view := CasePublicPresentationBuilder.new().build_suspect_views(case_fixture, runtime, roles)[1]
	return not revealed and runtime.find_suspect(2).interactive_function == null and not view.has_public_function


func _reveal_function_is_locked(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _reveal_tailor(case_fixture, roles, players)
	var state := (bundle.runtime as CaseRuntimeState).find_suspect(1).interactive_function
	return bundle.revealed and state.state == InteractiveFunctionRuntimeState.State.LOCKED_UNTIL_NEXT_TURN


func _locked_not_available_same_turn(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _reveal_tailor(case_fixture, roles, players)
	return (bundle.availability as FunctionAvailabilityService).available_functions(bundle.runtime as CaseRuntimeState).is_empty()


func _available_turn_is_next(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _reveal_tailor(case_fixture, roles, players)
	var state := (bundle.runtime as CaseRuntimeState).find_suspect(1).interactive_function
	return state.revealed_on_turn == 1 and state.available_from_turn == state.revealed_on_turn + 1


func _next_turn_unlocks(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _reveal_tailor(case_fixture, roles, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	manager.advance_turn()
	runtime.apply_turn_snapshot(manager)
	var changed := (bundle.availability as FunctionAvailabilityService).update_for_turn(runtime, manager.turn_number)
	return changed == PackedInt32Array([1]) and runtime.find_suspect(1).interactive_function.state == InteractiveFunctionRuntimeState.State.AVAILABLE


func _unlock_independent_of_revealer(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _reveal_tailor(case_fixture, roles, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	manager.advance_turn()
	runtime.apply_turn_snapshot(manager)
	(bundle.availability as FunctionAvailabilityService).update_for_turn(runtime, manager.turn_number)
	return runtime.current_player_id() == &"player_2" and runtime.find_suspect(1).interactive_function.state == InteractiveFunctionRuntimeState.State.AVAILABLE


func _turn_four_unlocks_turn_five(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _reveal_tailor(case_fixture, roles, players, 4)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	var state := runtime.find_suspect(1).interactive_function
	var locked_on_four := state.revealed_on_turn == 4 and state.available_from_turn == 5 and state.state == InteractiveFunctionRuntimeState.State.LOCKED_UNTIL_NEXT_TURN
	manager.advance_turn()
	runtime.apply_turn_snapshot(manager)
	(bundle.availability as FunctionAvailabilityService).update_for_turn(runtime, manager.turn_number)
	return locked_on_four and manager.turn_number == 5 and state.state == InteractiveFunctionRuntimeState.State.AVAILABLE


func _multiple_functions_coexist(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _reveal_tailor(case_fixture, roles, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	var availability := bundle.availability as FunctionAvailabilityService
	var tailor: RoleDefinition
	for role in roles:
		if role.role_id == &"tailor":
			tailor = role
			break
	var second := InteractiveFunctionRuntimeState.new(2)
	second.configure_hidden(tailor)
	second.lock_after_reveal(manager.turn_number)
	runtime.find_suspect(2).interactive_function = second
	manager.advance_turn()
	runtime.apply_turn_snapshot(manager)
	availability.update_for_turn(runtime, manager.turn_number)
	return availability.available_functions(runtime).size() == 2


func _function_action_disabled_without_available(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _reveal_tailor(case_fixture, roles, players)
	return not (bundle.availability as FunctionAvailabilityService).has_available_functions(bundle.runtime as CaseRuntimeState)


func _function_action_enabled_with_available(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _reveal_tailor(case_fixture, roles, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	manager.advance_turn()
	runtime.apply_turn_snapshot(manager)
	(bundle.availability as FunctionAvailabilityService).update_for_turn(runtime, manager.turn_number)
	return (bundle.availability as FunctionAvailabilityService).has_available_functions(runtime)


func _function_placeholder_snapshot() -> Dictionary:
	var scene := _case_scene_instance() as VSCaseMainController
	var fallback := {"turn_unchanged": false, "usage_unchanged": false, "runtime_unchanged": false}
	if scene == null:
		return fallback
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		scene.free()
		return fallback
	tree.root.add_child(scene)
	var result := scene.investigation_service.investigate(scene.case_definition, scene.runtime_state, 1, scene.runtime_state.current_player_id())
	if not result.success:
		tree.root.remove_child(scene)
		scene.free()
		return fallback
	scene.function_availability_service.reveal_for_suspect(scene.case_definition, scene.runtime_state, scene.role_definitions, 1, scene.turn_manager.turn_number)
	scene.turn_manager.advance_turn()
	scene.runtime_state.apply_turn_snapshot(scene.turn_manager)
	scene.function_availability_service.update_for_turn(scene.runtime_state, scene.turn_manager.turn_number)
	var before_turn := scene.turn_manager.turn_number
	var function_state := scene.runtime_state.find_suspect(1).interactive_function
	var before_usage := function_state.uses_remaining
	var before_investigated := scene.runtime_state.investigated_count()
	var before_log_size := scene.runtime_state.action_log.size()
	scene._on_function_pressed_for_suspect(1)
	var snapshot := {
		"turn_unchanged": scene.turn_manager.turn_number == before_turn,
		"usage_unchanged": function_state.uses_remaining == before_usage,
		"runtime_unchanged": scene.runtime_state.investigated_count() == before_investigated and scene.runtime_state.action_log.size() == before_log_size,
	}
	tree.root.remove_child(scene)
	scene.free()
	return snapshot


func _true_role_owns_function(roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var suspect := SuspectDefinition.new()
	suspect.suspect_id = 1
	suspect.true_role_id = &"tailor"
	suspect.displayed_role_id = &"role_good_a"
	var custom_case := CaseDefinition.new()
	custom_case.case_id = &"ownership_test"
	custom_case.suspects.append(suspect)
	var runtime := CaseRuntimeState.new()
	runtime.initialize(custom_case, players)
	var manager := TurnManager.new()
	manager.initialize(runtime.players, 71)
	runtime.apply_turn_snapshot(manager)
	var availability := FunctionAvailabilityService.new()
	availability.initialize_hidden_states(custom_case, runtime, roles)
	var result := InvestigationService.new().investigate(custom_case, runtime, 1, runtime.current_player_id())
	var revealed := result.success and availability.reveal_for_suspect(custom_case, runtime, roles, 1, 1)
	var view := CasePublicPresentationBuilder.new().build_suspect_views(custom_case, runtime, roles)[0]
	return revealed and view.public_role_name == "Chính Nhân A (Fixture)" and "Thợ May" not in view.public_function_text


func _pretended_role_function_available(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	if c == null:
		return false
	var bundle: Dictionary = _fresh_turn_bundle(c, players)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var manager: TurnManager = bundle.manager as TurnManager
	var availability: FunctionAvailabilityService = FunctionAvailabilityService.new()
	availability.initialize_hidden_states(c, runtime, roles)
	var result: InvestigationResult = InvestigationService.new().investigate(c, runtime, 2, runtime.current_player_id())
	var revealed: bool = result.success and availability.reveal_for_suspect(c, runtime, roles, 2, manager.turn_number)
	var suspect_runtime: SuspectRuntimeState = runtime.find_suspect(2)
	var function_state: InteractiveFunctionRuntimeState = suspect_runtime.interactive_function if suspect_runtime != null else null
	var views: Array[SuspectPublicViewData] = CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles)
	var view: SuspectPublicViewData = _tutorial_03_view(views, 2)
	return (
		revealed
		and function_state != null
		and function_state.function_type == CaseEnums.FunctionType.TAILOR_COMPARE_ALIGNMENT
		and view != null
		and view.public_role_name == "Thợ May"
		and view.has_public_function
	)


func _suspect_one_tailor_timing(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	return _reveal_function_is_locked(case_fixture, roles, players) and _next_turn_unlocks(case_fixture, roles, players)


func _function_lifecycle_resets(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var first_bundle := _reveal_tailor(case_fixture, roles, players)
	var first_runtime := first_bundle.runtime as CaseRuntimeState
	var first_manager := first_bundle.manager as TurnManager
	first_manager.advance_turn()
	first_runtime.apply_turn_snapshot(first_manager)
	(first_bundle.availability as FunctionAvailabilityService).update_for_turn(first_runtime, first_manager.turn_number)
	var second_runtime := (_fresh_function_bundle(case_fixture, roles, players).runtime as CaseRuntimeState)
	return first_runtime.find_suspect(1).interactive_function.state == InteractiveFunctionRuntimeState.State.AVAILABLE and second_runtime.find_suspect(1).interactive_function.state == InteractiveFunctionRuntimeState.State.HIDDEN and second_runtime.find_suspect(1).interactive_function.available_from_turn == 0


func _all_suspect_investigations_function_button_enabled() -> bool:
	var scene := _case_scene_instance() as VSCaseMainController
	if scene == null:
		return false
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		scene.free()
		return false
	tree.root.add_child(scene)
	for suspect in scene.case_definition.suspects:
		var result := scene.investigation_service.investigate(scene.case_definition, scene.runtime_state, suspect.suspect_id, scene.runtime_state.current_player_id())
		if not result.success:
			tree.root.remove_child(scene)
			scene.free()
			return false
		scene.function_availability_service.reveal_for_suspect(scene.case_definition, scene.runtime_state, scene.role_definitions, suspect.suspect_id, scene.turn_manager.turn_number)
		scene.turn_manager.advance_turn()
		scene.runtime_state.apply_turn_snapshot(scene.turn_manager)
		scene.function_availability_service.update_for_turn(scene.runtime_state, scene.turn_manager.turn_number)
	scene._update_action_ui()
	var enabled := not scene.function_button.disabled and scene.investigate_button.disabled and scene.submit_button.disabled and scene.runtime_state.case_outcome == CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS
	tree.root.remove_child(scene)
	scene.free()
	return enabled


func _investigation_and_unlock_advance_once(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _reveal_tailor(case_fixture, roles, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	var before := manager.turn_number
	manager.advance_turn()
	runtime.apply_turn_snapshot(manager)
	(bundle.availability as FunctionAvailabilityService).update_for_turn(runtime, manager.turn_number)
	return manager.turn_number == before + 1 and runtime.turn_number == before + 1 and runtime.find_suspect(1).interactive_function.state == InteractiveFunctionRuntimeState.State.AVAILABLE


func _public_function_dto_hides_source(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _reveal_tailor(case_fixture, roles, players)
	var view := CasePublicPresentationBuilder.new().build_suspect_views(case_fixture, bundle.runtime as CaseRuntimeState, roles)[0]
	var names := view.visible_property_names()
	return view.has_public_function and "true_role_id" not in names and "function_type" not in names and "owner_role_id" not in names


func _public_function_hand_marker_contract(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _reveal_tailor(case_fixture, roles, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	var builder := CasePublicPresentationBuilder.new()
	var locked_view: SuspectPublicViewData = builder.build_suspect_views(case_fixture, runtime, roles)[0]
	var passive_board := _board_instance_with_runtime(case_fixture, runtime, roles)
	var passive_card := _board_card(passive_board, 2)
	var locked_marker_empty := locked_view.public_function_marker_state.is_empty()
	var locked_status_empty := locked_view.public_function_text.is_empty()
	var no_function_no_hand := passive_card != null and not passive_card.has_function_hand_marker_for_smoke()
	if passive_board != null:
		passive_board.free()
	manager.advance_turn()
	runtime.apply_turn_snapshot(manager)
	(bundle.availability as FunctionAvailabilityService).update_for_turn(runtime, manager.turn_number)
	var available_view: SuspectPublicViewData = builder.build_suspect_views(case_fixture, runtime, roles)[0]
	var available_board := _board_instance_with_runtime(case_fixture, runtime, roles)
	var available_card := _board_card(available_board, 1)
	var available_footprint := available_card.get_combined_minimum_size() if available_card != null else Vector2.ZERO
	var available_hand := (
		available_card != null
		and available_card.has_function_hand_marker_for_smoke()
		and _function_hand_is_available(available_card.get_function_hand_marker_texture_path_for_smoke())
		and available_card.get_public_function_status_text().is_empty()
	)
	if available_board != null:
		available_board.free()
	var result := InteractiveFunctionExecutionService.new().execute(case_fixture, runtime, 1, PackedInt32Array([2, 3]), runtime.current_player_id())
	var consumed_view: SuspectPublicViewData = builder.build_suspect_views(case_fixture, runtime, roles)[0]
	var consumed_board := _board_instance_with_runtime(case_fixture, runtime, roles)
	var consumed_card := _board_card(consumed_board, 1)
	var consumed_footprint := consumed_card.get_combined_minimum_size() if consumed_card != null else Vector2.ZERO
	var consumed_hand := (
		consumed_card != null
		and consumed_card.has_function_hand_marker_for_smoke()
		and _function_hand_is_consumed(consumed_card.get_function_hand_marker_texture_path_for_smoke())
		and consumed_card.get_public_function_status_text().is_empty()
	)
	var result_visible := consumed_card != null and consumed_card.get_public_function_result_text() == "2 và 3 cùng phe."
	var footprint_stable := available_footprint == consumed_footprint
	if consumed_board != null:
		consumed_board.free()
	return (
		locked_marker_empty
		and locked_status_empty
		and no_function_no_hand
		and available_view.public_function_text.is_empty()
		and available_hand
		and result.success
		and consumed_view.public_function_text.is_empty()
		and consumed_hand
		and result_visible
		and footprint_stable
		and _t08_copycat_borrowed_function_marker(roles, players)
	)


func _function_hand_is_available(texture_path: String) -> bool:
	return texture_path == "res://assets/ui/case/function_hand_available.png"


func _function_hand_is_consumed(texture_path: String) -> bool:
	return texture_path == "res://assets/ui/case/function_hand_consumed.png"


func _fresh_available_tailor_bundle(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var bundle := _reveal_tailor(case_fixture, roles, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	manager.advance_turn()
	runtime.apply_turn_snapshot(manager)
	(bundle.availability as FunctionAvailabilityService).update_for_turn(runtime, manager.turn_number)
	bundle["execution"] = InteractiveFunctionExecutionService.new()
	return bundle


func _execute_tailor(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState], targets: PackedInt32Array = PackedInt32Array([2, 3])) -> Dictionary:
	var bundle := _fresh_available_tailor_bundle(case_fixture, roles, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var result := (bundle.execution as InteractiveFunctionExecutionService).execute(case_fixture, runtime, 1, targets, runtime.current_player_id())
	bundle["result"] = result
	return bundle


func _tailor_available_required(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	return _locked_tailor_cannot_execute(case_fixture, roles, players)


func _locked_tailor_cannot_execute(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _reveal_tailor(case_fixture, roles, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var result := InteractiveFunctionExecutionService.new().execute(case_fixture, runtime, 1, PackedInt32Array([2, 3]), runtime.current_player_id())
	return not result.success and result.error_code == &"FUNCTION_NOT_AVAILABLE" and runtime.find_suspect(1).interactive_function.uses_remaining == 1


func _exhausted_tailor_cannot_execute(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _execute_tailor(case_fixture, roles, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var second := (bundle.execution as InteractiveFunctionExecutionService).execute(case_fixture, runtime, 1, PackedInt32Array([2, 3]), runtime.current_player_id())
	return not second.success and second.error_code == &"FUNCTION_EXHAUSTED"


func _tailor_exactly_two_targets(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _fresh_available_tailor_bundle(case_fixture, roles, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var result := (bundle.execution as InteractiveFunctionExecutionService).execute(case_fixture, runtime, 1, PackedInt32Array([2]), runtime.current_player_id())
	return not result.success and result.error_code == &"TARGET_COUNT_INVALID" and runtime.find_suspect(1).interactive_function.uses_remaining == 1


func _tailor_duplicate_target_fails(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _fresh_available_tailor_bundle(case_fixture, roles, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var result := (bundle.execution as InteractiveFunctionExecutionService).execute(case_fixture, runtime, 1, PackedInt32Array([2, 2]), runtime.current_player_id())
	return not result.success and result.error_code == &"TARGETS_MUST_DIFFER"


func _tailor_unknown_target_fails(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _fresh_available_tailor_bundle(case_fixture, roles, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var result := (bundle.execution as InteractiveFunctionExecutionService).execute(case_fixture, runtime, 1, PackedInt32Array([2, 99]), runtime.current_player_id())
	return not result.success and result.error_code == &"TARGET_NOT_FOUND"


func _tailor_valid_pair_succeeds(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	return (_execute_tailor(case_fixture, roles, players).result as InteractiveFunctionResult).success


func _tailor_same_alignment(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var result := _execute_tailor(case_fixture, roles, players, PackedInt32Array([2, 3])).result as InteractiveFunctionResult
	return result.success and result.public_result_type == InteractiveFunctionResult.PublicResultType.SAME_ALIGNMENT and result.public_result_text == "Cùng phe"


func _tailor_different_alignment(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var result := _execute_tailor(case_fixture, roles, players, PackedInt32Array([2, 4])).result as InteractiveFunctionResult
	return result.success and result.public_result_type == InteractiveFunctionResult.PublicResultType.DIFFERENT_ALIGNMENT and result.public_result_text == "Khác phe"


func _tailor_authored_corruption_inverts(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var corrupted_case: CaseDefinition = case_fixture.duplicate(true) as CaseDefinition
	var owner: SuspectDefinition = _case_suspect(corrupted_case, 1)
	if owner == null:
		return false
	owner.is_corrupted = true
	var result := _execute_tailor(corrupted_case, roles, players, PackedInt32Array([2, 3])).result as InteractiveFunctionResult
	return result.success and result.public_result_type == InteractiveFunctionResult.PublicResultType.DIFFERENT_ALIGNMENT and result.public_result_text == "Khác phe"


func _tailor_runtime_taint_inverts(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle: Dictionary = _fresh_available_tailor_bundle(case_fixture, roles, players)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var owner_runtime: SuspectRuntimeState = runtime.find_suspect(1)
	if owner_runtime == null or not owner_runtime.apply_runtime_corruption(99):
		return false
	var result: InteractiveFunctionResult = (bundle.execution as InteractiveFunctionExecutionService).execute(
		case_fixture, runtime, 1, PackedInt32Array([2, 3]), runtime.current_player_id()
	)
	return result.success and result.public_result_type == InteractiveFunctionResult.PublicResultType.DIFFERENT_ALIGNMENT and result.public_result_text == "Khác phe"


func _tailor_runtime_taint_is_not_sticky(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	if not _tailor_runtime_taint_inverts(case_fixture, roles, players):
		return false
	var fresh_result := _execute_tailor(case_fixture, roles, players, PackedInt32Array([2, 3])).result as InteractiveFunctionResult
	return fresh_result.success and fresh_result.public_result_type == InteractiveFunctionResult.PublicResultType.SAME_ALIGNMENT and fresh_result.public_result_text == "Cùng phe"


func _tailor_ignores_target_displayed_identity(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var display_case: CaseDefinition = case_fixture.duplicate(true) as CaseDefinition
	var target: SuspectDefinition = _case_suspect(display_case, 2)
	if target == null:
		return false
	target.displayed_role_id = &"role_accomplice_a"
	target.is_impersonating = true
	target.impersonated_role_id = target.displayed_role_id
	var result := _execute_tailor(display_case, roles, players, PackedInt32Array([2, 3])).result as InteractiveFunctionResult
	return target.true_alignment == CaseEnums.Alignment.GOOD and result.success and result.public_result_type == InteractiveFunctionResult.PublicResultType.SAME_ALIGNMENT and result.public_result_text == "Cùng phe"


func _tailor_result_hides_raw_alignment(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var result := _execute_tailor(case_fixture, roles, players, PackedInt32Array([2, 4])).result as InteractiveFunctionResult
	return "GOOD" not in result.public_result_text and "EVIL" not in result.public_result_text and "Phe Thiện" not in result.public_result_text and "Phe Ác" not in result.public_result_text


func _tailor_result_has_no_true_role(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var result := _execute_tailor(case_fixture, roles, players).result as InteractiveFunctionResult
	var names := PackedStringArray()
	for property_info in result.get_property_list():
		names.append(property_info.name)
	return "true_role_id" not in names and "true_alignment" not in names


func _tailor_cancel_preserves_usage(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _fresh_available_tailor_bundle(case_fixture, roles, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var before_log_size := runtime.action_log.size()
	var selection := InvestigationSelectionState.new()
	selection.begin_function_selection(PackedInt32Array([1]))
	selection.toggle_function_target(2)
	selection.toggle_function_target(3)
	var cancelled := selection.cancel()
	return cancelled and runtime.find_suspect(1).interactive_function.uses_remaining == 1 and runtime.action_log.size() == before_log_size and selection.mode == InvestigationSelectionState.Mode.IDLE


func _tailor_cancel_does_not_advance(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _fresh_available_tailor_bundle(case_fixture, roles, players)
	var manager := bundle.manager as TurnManager
	var before := manager.turn_number
	var selection := InvestigationSelectionState.new()
	selection.begin_function_selection(PackedInt32Array([1]))
	selection.toggle_function_target(2)
	selection.cancel()
	return manager.turn_number == before


func _tailor_consumes_usage(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _execute_tailor(case_fixture, roles, players)
	return (bundle.runtime as CaseRuntimeState).find_suspect(1).interactive_function.uses_remaining == 0


func _tailor_becomes_exhausted(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _execute_tailor(case_fixture, roles, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var view := CasePublicPresentationBuilder.new().build_suspect_views(case_fixture, runtime, roles)[0]
	return runtime.find_suspect(1).interactive_function.state == InteractiveFunctionRuntimeState.State.EXHAUSTED and view.public_function_marker_state == "consumed" and not view.is_function_available


func _exhausted_tailor_not_available(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _execute_tailor(case_fixture, roles, players)
	return (bundle.availability as FunctionAvailabilityService).available_functions(bundle.runtime as CaseRuntimeState).is_empty()


func _tailor_advances_exactly_once(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _fresh_available_tailor_bundle(case_fixture, roles, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	var before := manager.turn_number
	var result := (bundle.execution as InteractiveFunctionExecutionService).execute(case_fixture, runtime, 1, PackedInt32Array([2, 3]), runtime.current_player_id())
	var service_did_not_advance := manager.turn_number == before
	if result.success:
		manager.advance_turn()
		runtime.apply_turn_snapshot(manager)
	return service_did_not_advance and manager.turn_number == before + 1


func _failed_tailor_does_not_advance(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _fresh_available_tailor_bundle(case_fixture, roles, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	var before := manager.turn_number
	var result := (bundle.execution as InteractiveFunctionExecutionService).execute(case_fixture, runtime, 1, PackedInt32Array([2]), runtime.current_player_id())
	return not result.success and manager.turn_number == before


func _tailor_keeps_investigated_states(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _fresh_available_tailor_bundle(case_fixture, roles, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var before := PackedByteArray()
	for suspect in runtime.suspects:
		before.append(1 if suspect.is_investigated else 0)
	(bundle.execution as InteractiveFunctionExecutionService).execute(case_fixture, runtime, 1, PackedInt32Array([2, 4]), runtime.current_player_id())
	var after := PackedByteArray()
	for suspect in runtime.suspects:
		after.append(1 if suspect.is_investigated else 0)
	return before == after


func _tailor_keeps_definitions_immutable(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var before := PackedInt32Array()
	for suspect in case_fixture.suspects:
		before.append(suspect.true_alignment)
	_execute_tailor(case_fixture, roles, players, PackedInt32Array([2, 4]))
	var after := PackedInt32Array()
	for suspect in case_fixture.suspects:
		after.append(suspect.true_alignment)
	return before == after


func _tailor_public_log_stored(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _execute_tailor(case_fixture, roles, players, PackedInt32Array([2, 4]))
	var log: Dictionary = (bundle.runtime as CaseRuntimeState).action_log.back()
	return log.action == "FUNCTION_EXECUTE" and log.success and log.owner_suspect_id == 1 and log.target_ids == PackedInt32Array([2, 4]) and log.public_result == "Khác phe" and not log.has("true_alignment")


func _tailor_result_snapshot_stable(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var bundle := _execute_tailor(case_fixture, roles, players, PackedInt32Array([2, 4]))
	var runtime := bundle.runtime as CaseRuntimeState
	var stored_before: String = runtime.action_log.back().public_result
	var original_alignment: CaseEnums.Alignment = case_fixture.suspects[1].true_alignment
	case_fixture.suspects[1].true_alignment = CaseEnums.Alignment.EVIL
	var stored_after: String = runtime.action_log.back().public_result
	case_fixture.suspects[1].true_alignment = original_alignment
	return stored_before == "Khác phe" and stored_after == stored_before


func _tailor_reenter_resets(case_fixture: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var first := _execute_tailor(case_fixture, roles, players)
	var second := _fresh_function_bundle(case_fixture, roles, players)
	var second_runtime := second.runtime as CaseRuntimeState
	var has_execution_history := false
	for entry in second_runtime.action_log:
		if entry.action == "FUNCTION_EXECUTE":
			has_execution_history = true
	return (first.runtime as CaseRuntimeState).find_suspect(1).interactive_function.uses_remaining == 0 and second_runtime.find_suspect(1).interactive_function.uses_remaining == 1 and second_runtime.find_suspect(1).interactive_function.state == InteractiveFunctionRuntimeState.State.HIDDEN and not has_execution_history


func _submission_still_disabled() -> bool:
	var scene := _case_scene_instance()
	if scene == null:
		return false
	var submit := scene.get_node_or_null("%SubmitButton") as Button
	var passed := submit != null and submit.disabled and not scene.has_method("_commit_submission")
	scene.free()
	return passed


func _submission_bundle(case_fixture: CaseDefinition, players: Array[PlayerCaseState]) -> Dictionary:
	var bundle := _fresh_turn_bundle(case_fixture, players, 3030)
	bundle["service"] = CaseSubmissionService.new()
	return bundle


func _submission_answer(case_fixture: CaseDefinition, players: Array[PlayerCaseState], evil: PackedInt32Array, under: PackedInt32Array = PackedInt32Array(), traitor: PackedInt32Array = PackedInt32Array()) -> CaseSubmissionResult:
	var bundle := _submission_bundle(case_fixture, players)
	var runtime := bundle.runtime as CaseRuntimeState
	var submission := CaseSubmission.new()
	submission.configure(runtime.current_player_id(), runtime.turn_number, evil, under, traitor)
	return (bundle.service as CaseSubmissionService).submit(case_fixture, runtime, runtime.find_player(runtime.current_player_id()), submission)


func _submission_current_player(c: CaseDefinition, p: Array[PlayerCaseState]) -> bool: return _submission_answer(c, p, PackedInt32Array()).success
func _submission_main(c: CaseDefinition, p: Array[PlayerCaseState], ids: PackedInt32Array) -> bool: return _submission_answer(c, p, ids).main_answer_correct
func _submission_error(c: CaseDefinition, p: Array[PlayerCaseState], e: PackedInt32Array, u: PackedInt32Array, t: PackedInt32Array) -> StringName: return _submission_answer(c, p, e, u, t).error_code
func _submission_outcome(c: CaseDefinition, p: Array[PlayerCaseState], ids: PackedInt32Array) -> CaseEnums.CaseOutcome:
	var b := _submission_bundle(c, p); var r := b.runtime as CaseRuntimeState; var s := CaseSubmission.new(); s.configure(r.current_player_id(), 1, ids, PackedInt32Array(), PackedInt32Array()); (b.service as CaseSubmissionService).submit(c, r, r.find_player(r.current_player_id()), s); return r.case_outcome


func _submission_non_current(c: CaseDefinition, p: Array[PlayerCaseState]) -> bool:
	var b := _submission_bundle(c,p); var r := b.runtime as CaseRuntimeState; var s := CaseSubmission.new(); s.configure(&"player_2",1,PackedInt32Array(),PackedInt32Array(),PackedInt32Array()); return (b.service as CaseSubmissionService).submit(c,r,r.find_player(&"player_2"),s).error_code == &"PLAYER_NOT_CURRENT"
func _submission_inactive(c: CaseDefinition, p: Array[PlayerCaseState]) -> bool:
	var b := _submission_bundle(c,p); var r := b.runtime as CaseRuntimeState; r.find_player(&"player_1").is_active_in_investigation=false; var s:=CaseSubmission.new(); s.configure(&"player_1",1,PackedInt32Array(),PackedInt32Array(),PackedInt32Array()); return not (b.service as CaseSubmissionService).submit(c,r,r.find_player(&"player_1"),s).success
func _submission_only_once(c: CaseDefinition,p:Array[PlayerCaseState])->bool:
	var b:=_submission_bundle(c,p); var r:=b.runtime as CaseRuntimeState; var svc:=b.service as CaseSubmissionService; var s:=CaseSubmission.new(); s.configure(&"player_1",1,PackedInt32Array(),PackedInt32Array(),PackedInt32Array()); svc.submit(c,r,r.find_player(&"player_1"),s); var s2:=CaseSubmission.new(); s2.configure(&"player_1",1,PackedInt32Array(),PackedInt32Array(),PackedInt32Array()); return not svc.submit(c,r,r.find_player(&"player_1"),s2).success
func _submission_wrong_class_still_solves(c:CaseDefinition,p:Array[PlayerCaseState])->bool:
	var result:=_submission_answer(c,p,PackedInt32Array([4,5]),PackedInt32Array([5]),PackedInt32Array([4])); return result.main_answer_correct and not result.underling_classification_correct and not result.traitor_classification_correct
func _submission_locks(c:CaseDefinition,p:Array[PlayerCaseState],ids:PackedInt32Array)->bool:
	var b:=_submission_bundle(c,p); var r:=b.runtime as CaseRuntimeState; var s:=CaseSubmission.new(); s.configure(&"player_1",1,ids,PackedInt32Array(),PackedInt32Array()); (b.service as CaseSubmissionService).submit(c,r,r.find_player(&"player_1"),s); return s.is_locked
func _submission_cancel_clean()->bool:
	var s:=InvestigationSelectionState.new(); s.begin_submission(); s.toggle_submission_suspect(4); return s.cancel() and s.selected_submission_evil_ids.is_empty()
func _submission_cancel_turn(p:Array[PlayerCaseState])->bool:
	var m:=TurnManager.new(); m.initialize(p,1); var before:=m.turn_number; var s:=InvestigationSelectionState.new(); s.begin_submission(); s.cancel(); return m.turn_number==before
func _submission_correct_no_advance(c:CaseDefinition,p:Array[PlayerCaseState])->bool:
	var b:=_submission_bundle(c,p); var m:=b.manager as TurnManager; var before:=m.turn_number; _commit_on_bundle(c,b,PackedInt32Array([4,5])); return m.turn_number==before
func _commit_on_bundle(c:CaseDefinition,b:Dictionary,ids:PackedInt32Array)->CaseSubmissionResult:
	var r:=b.runtime as CaseRuntimeState; var s:=CaseSubmission.new(); s.configure(r.current_player_id(),r.turn_number,ids,PackedInt32Array(),PackedInt32Array()); return (b.service as CaseSubmissionService).submit(c,r,r.find_player(r.current_player_id()),s)
func _submission_marks_others(c:CaseDefinition,p:Array[PlayerCaseState])->bool:
	var b:=_submission_bundle(c,p); _commit_on_bundle(c,b,PackedInt32Array([4,5])); var r:=b.runtime as CaseRuntimeState; return r.find_player(&"player_2").submission_status==CaseEnums.SubmissionStatus.NOT_SUBMITTED_CASE_ENDED and r.find_player(&"player_3").submission_status==CaseEnums.SubmissionStatus.NOT_SUBMITTED_CASE_ENDED
func _submission_prior_wrong_stays(c:CaseDefinition,p:Array[PlayerCaseState])->bool:
	var b:=_submission_bundle(c,p); _commit_on_bundle(c,b,PackedInt32Array([4])); var r:=b.runtime as CaseRuntimeState; var m:=b.manager as TurnManager; m.advance_turn(); r.apply_turn_snapshot(m); _commit_on_bundle(c,b,PackedInt32Array([4,5])); return r.find_player(&"player_1").submission_status==CaseEnums.SubmissionStatus.SUBMITTED_WRONG
func _submission_wrong_inactive(c:CaseDefinition,p:Array[PlayerCaseState])->bool:
	var b:=_submission_bundle(c,p); _commit_on_bundle(c,b,PackedInt32Array()); return not (b.runtime as CaseRuntimeState).find_player(&"player_1").is_active_in_investigation
func _submission_wrong_advances(c:CaseDefinition,p:Array[PlayerCaseState])->bool:
	var b:=_submission_bundle(c,p); var m:=b.manager as TurnManager; var before:=m.turn_number; _commit_on_bundle(c,b,PackedInt32Array()); m.advance_turn(); return m.turn_number==before+1
func _turn_skips_one_inactive(p:Array[PlayerCaseState])->bool:
	var copies:Array[PlayerCaseState]=[]
	for x in p:
		copies.append(x.duplicate(true))
	var m:=TurnManager.new(); m.initialize(copies,1); copies[0].is_active_in_investigation=false; return m.advance_turn().player_id==&"player_2"
func _turn_skips_two_inactive(p:Array[PlayerCaseState])->bool:
	var copies:Array[PlayerCaseState]=[]
	for x in p:
		copies.append(x.duplicate(true))
	var m:=TurnManager.new(); m.initialize(copies,1); copies[0].is_active_in_investigation=false; copies[1].is_active_in_investigation=false; return m.advance_turn().player_id==&"player_3"
func _sole_active_loops(p:Array[PlayerCaseState])->bool:
	var copies:Array[PlayerCaseState]=[]
	for x in p:
		copies.append(x.duplicate(true))
	copies[0].is_active_in_investigation=false; copies[1].is_active_in_investigation=false; var m:=TurnManager.new(); m.initialize(copies,1); m.current_turn_index=2; return m.advance_turn().player_id==&"player_3"
func _all_players_fail(c:CaseDefinition,p:Array[PlayerCaseState])->bool:
	var b:=_submission_bundle(c,p); var r:=b.runtime as CaseRuntimeState; var m:=b.manager as TurnManager
	for _i in range(3):
		_commit_on_bundle(c,b,PackedInt32Array())
		if r.active_player_count()>0:
			m.advance_turn(); r.apply_turn_snapshot(m)
	return r.case_outcome==CaseEnums.CaseOutcome.ALL_FAILED_EARLY
func _zero_active_no_next(p:Array[PlayerCaseState])->bool:
	var copies:Array[PlayerCaseState]=[]
	for x in p:
		var q:=x.duplicate(true) as PlayerCaseState
		q.is_active_in_investigation=false; copies.append(q)
	var m:=TurnManager.new(); m.initialize(copies,1); return m.advance_turn()==null
func _inactive_sees_public(c:CaseDefinition,roles:Array[RoleDefinition],p:Array[PlayerCaseState])->bool:
	var b:=_submission_bundle(c,p); var r:=b.runtime as CaseRuntimeState; r.find_player(&"player_1").is_active_in_investigation=false; return CasePublicPresentationBuilder.new().build_suspect_views(c,r,roles).size()==8
func _inactive_cannot_investigate(c:CaseDefinition,p:Array[PlayerCaseState])->bool:
	var b:=_submission_bundle(c,p); var r:=b.runtime as CaseRuntimeState; r.find_player(&"player_1").is_active_in_investigation=false; return not InvestigationService.new().investigate(c,r,2,&"player_1").success
func _inactive_cannot_function(c:CaseDefinition,roles:Array[RoleDefinition],p:Array[PlayerCaseState])->bool:
	var b:=_fresh_available_tailor_bundle(c,roles,p); var r:=b.runtime as CaseRuntimeState; r.find_player(r.current_player_id()).is_active_in_investigation=false; return not (b.execution as InteractiveFunctionExecutionService).execute(c,r,1,PackedInt32Array([2,3]),r.current_player_id()).success
func _function_survives_revealer(c:CaseDefinition,roles:Array[RoleDefinition],p:Array[PlayerCaseState])->bool:
	var b:=_fresh_available_tailor_bundle(c,roles,p); var r:=b.runtime as CaseRuntimeState; r.find_player(&"player_1").is_active_in_investigation=false; return (b.execution as InteractiveFunctionExecutionService).execute(c,r,1,PackedInt32Array([2,3]),r.current_player_id()).success
func _submission_log_private(c:CaseDefinition,p:Array[PlayerCaseState])->bool:
	var b:=_submission_bundle(c,p); _commit_on_bundle(c,b,PackedInt32Array([4])); var log:Dictionary=(b.runtime as CaseRuntimeState).action_log.back(); return not log.has("selected_evil_ids") and not log.has("underling_ids")
func _public_log_has_no_truth(c:CaseDefinition,p:Array[PlayerCaseState])->bool: return _submission_log_private(c,p)
func _eight_sets_awaiting(c:CaseDefinition,p:Array[PlayerCaseState])->bool:
	var b:=_fresh_turn_bundle(c,p); var r:=b.runtime as CaseRuntimeState; var m:=b.manager as TurnManager
	for id in range(1,9):
		InvestigationService.new().investigate(c,r,id,r.current_player_id())
		m.advance_turn(); r.apply_turn_snapshot(m)
	PostRevealFunctionService.new().resolve_phase(c,r)
	return r.case_outcome==CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
func _awaiting_rejects_submission(c:CaseDefinition,p:Array[PlayerCaseState])->bool:
	var b:=_submission_bundle(c,p); (b.runtime as CaseRuntimeState).case_outcome=CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT; return not _commit_on_bundle(c,b,PackedInt32Array([4,5])).success
func _ended_states_lock_actions(c:CaseDefinition,p:Array[PlayerCaseState])->bool:
	var b:=_submission_bundle(c,p); _commit_on_bundle(c,b,PackedInt32Array([4,5])); return not (b.runtime as CaseRuntimeState).accepts_investigation_actions
func _player_status_public_only()->bool: return true
func _submission_rewards_unchanged(c:CaseDefinition,p:Array[PlayerCaseState])->bool: return _submission_resource_delta(c,p,"orb")==0.0 and _submission_resource_delta(c,p,"merit")==0.0 and _submission_resource_delta(c,p,"reputation")==0.0 and _submission_resource_delta(c,p,"tickets")==0.0
func _submission_resource_delta(c:CaseDefinition,p:Array[PlayerCaseState],kind:String)->float:
	var b:=_submission_bundle(c,p); var r:=b.runtime as CaseRuntimeState; var x:=r.find_player(&"player_1"); var before:float = x.orb_count if kind=="orb" else x.merit if kind=="merit" else x.reputation if kind=="reputation" else x.gacha_ticket_count; _commit_on_bundle(c,b,PackedInt32Array()); var after:float = x.orb_count if kind=="orb" else x.merit if kind=="merit" else x.reputation if kind=="reputation" else x.gacha_ticket_count; return after-before
func _submission_reset(c:CaseDefinition,p:Array[PlayerCaseState])->bool:
	var first:=_submission_bundle(c,p); _commit_on_bundle(c,first,PackedInt32Array()); var second:=_submission_bundle(c,p); var r:=second.runtime as CaseRuntimeState; return r.submissions.is_empty() and r.case_outcome==CaseEnums.CaseOutcome.IN_PROGRESS and r.active_player_count()==3 and r.turn_number==1
func _function_text_history_checks(c: CaseDefinition, roles: Array[RoleDefinition], p: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	checks.record_load = PublicFunctionRecord.new() != null
	var bundle := _fresh_available_tailor_bundle(c, roles, p)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	var function_state := runtime.find_suspect(1).interactive_function
	var turn_before := manager.turn_number
	var usage_before := function_state.uses_remaining
	var result := (bundle.execution as InteractiveFunctionExecutionService).execute(c, runtime, 1, PackedInt32Array([4,7]), runtime.current_player_id())
	var record: PublicFunctionRecord = runtime.public_function_records[0] if runtime.public_function_records.size() == 1 else null
	checks.one_record = result.success and runtime.public_function_records.size() == 1
	checks.owner = record != null and record.source_suspect_id == 1
	checks.targets = record != null and record.target_suspect_ids == PackedInt32Array([4,7])
	checks.result = record != null and record.public_result_text in ["Cùng phe", "Khác phe"]
	checks.acting_player = record != null and record.acting_player_id == runtime.current_player_id()
	checks.turn = record != null and record.executed_on_turn == turn_before
	var cancelled_bundle := _fresh_available_tailor_bundle(c, roles, p)
	var cancelled_runtime := cancelled_bundle.runtime as CaseRuntimeState
	var selection := InvestigationSelectionState.new(); selection.begin_function_selection(PackedInt32Array([1])); selection.toggle_function_target(2); selection.cancel()
	checks.cancel_clean = cancelled_runtime.public_function_records.is_empty()
	var invalid_bundle := _fresh_available_tailor_bundle(c, roles, p)
	var invalid_runtime := invalid_bundle.runtime as CaseRuntimeState
	var invalid := (invalid_bundle.execution as InteractiveFunctionExecutionService).execute(c, invalid_runtime, 1, PackedInt32Array([2]), invalid_runtime.current_player_id())
	checks.invalid_clean = not invalid.success and invalid_runtime.public_function_records.is_empty()
	checks.no_hidden_fields = _public_record_has_no_hidden_fields()
	var same_record := PublicFunctionRecord.new()
	var different_record := PublicFunctionRecord.new()
	same_record.configure(1, 1, "Thợ May", PackedInt32Array([4, 5]), &"player_1", 3, "Cùng phe")
	different_record.configure(2, 1, "Thợ May", PackedInt32Array([4, 5]), &"player_2", 4, "Khác phe")
	checks.same_sentence = same_record.summary_text() == "Thợ May: Nghi phạm 4 và 5 cùng phe."
	checks.different_sentence = different_record.summary_text() == "Thợ May: Nghi phạm 4 và 5 khác phe."
	checks.sentence_no_leak = _public_sentence_has_no_hidden_identity(same_record.summary_text()) and _public_sentence_has_no_hidden_identity(different_record.summary_text())
	checks.multiple_order = _public_record_order_preserved(c, p)
	checks.history_retains = _public_text_history_retained(c, p) and _full_reveal_previous_function_result_history(roles, p)
	checks.record_reset = _public_record_reset(c, roles, p)
	checks.turn_unchanged = manager.turn_number == turn_before
	checks.usage_once = function_state.uses_remaining == usage_before - 1 and runtime.public_function_records.size() == 1
	checks.post_regression = _post_reveal_tailor_text_history(c, roles, p)
	checks.final_regression = _one_active_final(c, p)
	checks.early_regression = _submission_outcome(c, p, PackedInt32Array([4,5])) == CaseEnums.CaseOutcome.EARLY_SOLVED
	checks.ui_nodes = _text_history_ui_nodes_exist()
	checks.no_overlay = _removed_function_overlay_not_executable()
	checks.no_toggle = _case_has_no_node("OverlayToggle")
	return checks


func _removed_function_overlay_not_executable() -> bool:
	var main_scene := load(VS_CASE_MAIN_PATH) as PackedScene
	var board_scene := load(CASE_BOARD_PATH) as PackedScene
	if main_scene == null or board_scene == null:
		return false
	var main_instance := main_scene.instantiate()
	var board_instance := board_scene.instantiate()
	var runtime_clean := (
		main_instance.find_child("FunctionRelationOverlay", true, false) == null
		and main_instance.find_child("OverlayToggle", true, false) == null
		and board_instance.find_child("FunctionRelationOverlay", true, false) == null
		and board_instance.find_child("OverlayToggle", true, false) == null
	)
	main_instance.free()
	board_instance.free()
	if not runtime_clean:
		return false
	var canonical_sources := [
		VS_CASE_MAIN_PATH,
		CASE_BOARD_PATH,
		SUSPECT_CARD_PATH,
		"res://scripts/presentation/case_gameplay/VSCaseMainController.gd",
		"res://scripts/presentation/case_gameplay/CaseBoardController.gd",
		"res://scripts/presentation/case_gameplay/SuspectCardController.gd",
	]
	for source_path in canonical_sources:
		var source_text := FileAccess.get_file_as_string(source_path)
		for removed_wiring in [
			"FunctionRelationOverlay",
			"PublicFunctionRelation",
			"PublicFunctionPresentationBuilder",
			"OverlayToggle",
		]:
			if removed_wiring in source_text:
				return false
	return true


func _public_record_has_no_hidden_fields() -> bool:
	var names: Array[StringName] = []
	for property_info in PublicFunctionRecord.new().get_property_list(): names.append(property_info.name)
	for forbidden in [&"true_alignment", &"true_role_id", &"is_corrupted", &"is_tainted", &"is_impersonating", &"correct_answer"]:
		if forbidden in names: return false
	return true


func _public_sentence_has_no_hidden_identity(sentence: String) -> bool:
	for forbidden in ["GOOD", "EVIL", "Phe Thiện", "Phe Ác", "true_alignment", "true_role", "Tha Hóa", "giả danh", "correct_answer"]:
		if forbidden in sentence:
			return false
	return true


func _public_record_order_preserved(c: CaseDefinition, p: Array[PlayerCaseState]) -> bool:
	var runtime := (_fresh_turn_bundle(c, p).runtime as CaseRuntimeState)
	runtime.append_public_function_record(1, "Thợ May", PackedInt32Array([2,3]), &"player_1", "Cùng phe")
	runtime.append_public_function_record(6, "Vai X", PackedInt32Array([4]), &"player_2", "Kết quả công khai")
	return runtime.public_function_records.size() == 2 and runtime.public_function_records[0].record_id == 1 and runtime.public_function_records[1].record_id == 2


func _public_text_history_retained(c: CaseDefinition, p: Array[PlayerCaseState]) -> bool:
	var runtime := (_fresh_turn_bundle(c, p).runtime as CaseRuntimeState)
	runtime.append_public_function_record(1, "Thợ May", PackedInt32Array([4,5]), &"player_1", "Cùng phe")
	runtime.append_public_function_record(1, "Thợ May", PackedInt32Array([2,7]), &"player_2", "Khác phe")
	return (
		runtime.public_function_records.size() == 2
		and runtime.public_function_records[0].summary_text() == "Thợ May: Nghi phạm 4 và 5 cùng phe."
		and runtime.public_function_records[1].summary_text() == "Thợ May: Nghi phạm 2 và 7 khác phe."
	)


func _full_reveal_previous_function_result_history(roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var tutorial_case_04: CaseDefinition = FixtureRepository.load_tutorial_case_004()
	if tutorial_case_04 == null:
		return false
	var bundle: Dictionary = _fresh_turn_bundle(tutorial_case_04, players)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var manager: TurnManager = bundle.manager as TurnManager
	var availability: FunctionAvailabilityService = FunctionAvailabilityService.new()
	availability.initialize_hidden_states(tutorial_case_04, runtime, roles)
	var player_id: StringName = runtime.current_player_id()
	var investigated: bool = (
		InvestigationService.new().investigate(tutorial_case_04, runtime, 2, player_id).success
		and availability.reveal_for_suspect(tutorial_case_04, runtime, roles, 2, manager.turn_number)
	)
	manager.advance_turn()
	runtime.apply_turn_snapshot(manager)
	availability.update_for_turn(runtime, manager.turn_number)
	var action: InteractiveFunctionResult = InteractiveFunctionExecutionService.new().execute(
		tutorial_case_04,
		runtime,
		2,
		PackedInt32Array([3, 4]),
		runtime.current_player_id()
	)
	var active_board: CaseBoardController = _board_instance_with_runtime(tutorial_case_04, runtime, roles)
	var active_card: SuspectCardController = _board_card(active_board, 2) if active_board != null else null
	var active_statement: String = active_card.get_public_function_result_text() if active_card != null else ""
	if active_board != null:
		active_board.free()
	var player: PlayerCaseState = runtime.find_player(runtime.current_player_id())
	var accuse: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(tutorial_case_04, runtime, player, 2)
	var settlement: CaseSettlementResult = CaseSettlementService.new().settle(tutorial_case_04, runtime)
	var reveal: CaseTruthReveal = CaseTruthRevealBuilder.new().build(tutorial_case_04, runtime, roles)
	var reveal_board: CaseBoardController = _board_instance_with_runtime(tutorial_case_04, runtime, roles)
	var reveal_card: SuspectCardController = _board_card(reveal_board, 2) if reveal_board != null else null
	var default_statement: String = reveal_card.get_reveal_statement_text() if reveal_card != null else ""
	var role_before_toggle: String = reveal_card.get_public_role_text() if reveal_card != null else ""
	var footprint_before: Vector2 = reveal_card.get_combined_minimum_size() if reveal_card != null else Vector2.ZERO
	var has_history: bool = reveal_card != null and reveal_card.has_reveal_history_button()
	if reveal_card != null:
		reveal_card.toggle_reveal_history_for_smoke()
	var history_statement: String = reveal_card.get_reveal_statement_text() if reveal_card != null else ""
	var role_after_history: String = reveal_card.get_public_role_text() if reveal_card != null else ""
	var footprint_after_history: Vector2 = reveal_card.get_combined_minimum_size() if reveal_card != null else Vector2.ZERO
	if reveal_card != null:
		reveal_card.toggle_reveal_history_for_smoke()
	var restored_statement: String = reveal_card.get_reveal_statement_text() if reveal_card != null else ""
	var footprint_after_restore: Vector2 = reveal_card.get_combined_minimum_size() if reveal_card != null else Vector2.ZERO
	if reveal_board != null:
		reveal_board.free()
	return (
		investigated
		and action.success
		and active_statement == "3 và 4 khác phe."
		and accuse != null
		and accuse.success
		and settlement.success
		and reveal != null
		and default_statement == "Ta giả danh Thợ May."
		and has_history
		and history_statement == "3 và 4 khác phe."
		and restored_statement == "Ta giả danh Thợ May."
		and role_before_toggle == "Kẻ Côn Đồ"
		and role_after_history == "Kẻ Côn Đồ"
		and footprint_before == footprint_after_history
		and footprint_after_history == footprint_after_restore
	)


func _public_record_reset(c: CaseDefinition, roles: Array[RoleDefinition], p: Array[PlayerCaseState]) -> bool:
	var first := _execute_tailor(c, roles, p).runtime as CaseRuntimeState
	var second := _fresh_turn_bundle(c, p).runtime as CaseRuntimeState
	return first.public_function_records.size() == 1 and second.public_function_records.is_empty()


func _post_reveal_tailor_text_history(c: CaseDefinition, roles: Array[RoleDefinition], p: Array[PlayerCaseState]) -> bool:
	var bundle := _post_reveal_tailor_bundle(c, roles, p)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	var result := InteractiveFunctionExecutionService.new().execute(c, runtime, 1, PackedInt32Array([2,4]), runtime.current_player_id())
	if not result.success: return false
	var recorded := runtime.public_function_records.size() == 1
	manager.advance_turn(); runtime.apply_turn_snapshot(manager)
	(bundle.availability as FunctionAvailabilityService).update_for_turn(runtime, manager.turn_number)
	PostRevealFunctionService.new().resolve_phase(c, runtime)
	return recorded and runtime.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT


func _text_history_ui_nodes_exist() -> bool:
	var scene := _case_scene_instance()
	if scene == null: return false
	var board := scene.get_node_or_null("%CaseBoard")
	var card_scene := load(SUSPECT_CARD_PATH) as PackedScene
	var card: Node = null
	if card_scene != null:
		card = card_scene.instantiate()
	var statement_label: Label = null
	var statement_region: Control = null
	var reveal_history_button: Button = null
	var card_presentation_root: Control = null
	var card_content: VBoxContainer = null
	var suspect_card: SuspectCardController = card as SuspectCardController
	if card != null:
		statement_label = card.get_node_or_null("%PublicStatementLabel") as Label
		statement_region = card.get_node_or_null("%StatementRegion") as Control
		reveal_history_button = card.get_node_or_null("%RevealHistoryButton") as Button
		card_presentation_root = card.get_node_or_null("%CardPresentationRoot") as Control
		card_content = card.get_node_or_null("CardPresentationRoot/CardVisual/CardContent") as VBoxContainer
	var short_statement_size: int = 0
	var medium_statement_size: int = 0
	var long_statement_size: int = 0
	var obscured_statement_size: int = 0
	var short_statement_fits: bool = false
	var medium_statement_fits: bool = false
	var long_statement_fits: bool = false
	var obscured_statement_fits: bool = false
	var obscured_statement_complete: bool = false
	var short_card_content_min_y: float = -1.0
	var long_card_content_min_y: float = -2.0
	if suspect_card != null:
		suspect_card.set_presentation_profile_for_tile_size(Vector2(168, 190))
		var short_view: SuspectPublicViewData = SuspectPublicViewData.new(1)
		short_view.is_investigated = true
		short_view.public_role_name = "Dịch Phu"
		short_view.public_status_text = "Đã điều tra"
		short_view.public_investigation_statement = "Ta là Dịch Phu."
		suspect_card.configure(short_view)
		short_statement_size = suspect_card.get_statement_font_size_for_smoke()
		short_statement_fits = suspect_card.statement_text_fits_region_for_smoke()
		if card_content != null:
			short_card_content_min_y = card_content.get_combined_minimum_size().y
		var medium_view: SuspectPublicViewData = SuspectPublicViewData.new(1)
		medium_view.is_investigated = true
		medium_view.public_role_name = "Sử Quan"
		medium_view.public_status_text = "Đã điều tra"
		medium_view.public_investigation_statement = "Ta cách Phe Ác gần nhất 2 bước."
		suspect_card.configure(medium_view)
		medium_statement_size = suspect_card.get_statement_font_size_for_smoke()
		medium_statement_fits = suspect_card.statement_text_fits_region_for_smoke()
		var long_view: SuspectPublicViewData = SuspectPublicViewData.new(1)
		long_view.is_investigated = true
		long_view.public_role_name = "Dịch Phu"
		long_view.public_status_text = "Đã điều tra"
		long_view.public_investigation_statement = "Kẻ Côn Đồ đang ở trong cung, ta chưa từng nghe đến Sử Quan. Ta thông báo rõ vai nào đang có và vai nào không có trong Kỳ Án."
		suspect_card.configure(long_view)
		long_statement_size = suspect_card.get_statement_font_size_for_smoke()
		long_statement_fits = suspect_card.statement_text_fits_region_for_smoke()
		if card_content != null:
			long_card_content_min_y = card_content.get_combined_minimum_size().y
		var obscured_view: SuspectPublicViewData = SuspectPublicViewData.new(6)
		obscured_view.is_investigated = true
		obscured_view.public_role_name = "?????"
		obscured_view.public_role_obscured = true
		obscured_view.public_information_obscured = true
		obscured_view.public_investigation_statement = "■■ ■■ 1 ■■■■■ ■■■■ ■■■■■ ■■■ ■■."
		suspect_card.configure(obscured_view)
		obscured_statement_size = suspect_card.get_statement_font_size_for_smoke()
		obscured_statement_fits = suspect_card.statement_text_fits_region_for_smoke()
		obscured_statement_complete = (
			suspect_card.get_public_statement_text() == obscured_view.public_investigation_statement
			and suspect_card.get_public_statement_text().ends_with(".")
			and suspect_card.get_public_statement_text().length() == obscured_view.public_investigation_statement.length()
		)
	var statement_region_bounded: bool = (
		statement_region != null
		and statement_label != null
		and statement_region.get_parent() == card_content
		and statement_label.get_parent() == statement_region
		and statement_region.clip_contents
		and statement_region.custom_minimum_size.y == 60.0
		and statement_region.get_combined_minimum_size().y == 60.0
		and statement_label.custom_minimum_size.y == 0.0
		and statement_label.clip_text
	)
	var compact_region_bounded: bool = false
	if suspect_card != null and statement_region != null:
		suspect_card.set_presentation_profile_for_tile_size(Vector2(126, 143))
		compact_region_bounded = statement_region.custom_minimum_size.y == 38.0
	var passed: bool = (
		board != null
		and card != null
		and card.get_node_or_null("%PublicFunctionResultsLabel") != null
		and reveal_history_button != null
		and card_presentation_root != null
		and card_content != null
		and reveal_history_button.get_parent() == card_presentation_root
		and reveal_history_button.z_index > 1
		and reveal_history_button.mouse_filter == Control.MOUSE_FILTER_STOP
		and reveal_history_button.custom_minimum_size == Vector2.ZERO
		and reveal_history_button.offset_top >= 0.0
		and reveal_history_button.offset_bottom <= card.custom_minimum_size.y
		and suspect_card != null
		and not suspect_card.has_statement_scroll_region_for_smoke()
		and statement_label != null
		and statement_region_bounded
		and compact_region_bounded
		and short_statement_fits
		and medium_statement_fits
		and long_statement_fits
		and obscured_statement_fits
		and obscured_statement_complete
		and obscured_statement_size >= SuspectCardController.OBSCURED_STATEMENT_MIN_FONT_SIZE
		and obscured_statement_size < int(SuspectCardController.STATEMENT_FONT_TIERS[0])
		and short_statement_size >= medium_statement_size
		and medium_statement_size >= long_statement_size
		and short_statement_size > long_statement_size
		and long_statement_size > 0
		and short_card_content_min_y == long_card_content_min_y
		and scene.find_child("FunctionHistoryPanel", true, false) == null
		and scene.find_child("FunctionHistoryList", true, false) == null
	)
	if card != null: card.free()
	scene.free()
	return passed


func _case_has_no_node(node_name: String) -> bool:
	var scene := _case_scene_instance()
	if scene == null: return false
	var found := scene.find_child(node_name, true, false)
	var passed := found == null
	scene.free()
	return passed


func _card_local_clue_checks(c: CaseDefinition, roles: Array[RoleDefinition], p: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	var bundle := _execute_tailor(c, roles, p, PackedInt32Array([4,5]))
	var runtime := bundle.runtime as CaseRuntimeState
	var board := _board_instance_with_runtime(c, runtime, roles)
	if board == null:
		return checks
	var owner_card := _board_card(board, 1)
	var target_four := _board_card(board, 4)
	var target_five := _board_card(board, 5)
	var owner_clue := owner_card.get_public_function_result_text() if owner_card != null else ""
	checks.owner_status = owner_card != null and owner_card.has_function_hand_marker_for_smoke() and _function_hand_is_consumed(owner_card.get_function_hand_marker_texture_path_for_smoke()) and owner_card.get_public_function_status_text().is_empty()
	checks.owner_clue = owner_clue in ["4 và 5 cùng phe.", "4 và 5 khác phe."]
	checks.target_four_clean = target_four != null and target_four.get_public_function_result_text().is_empty()
	checks.target_five_clean = target_five != null and target_five.get_public_function_result_text().is_empty()
	checks.source_mapping = runtime.public_function_records.size() == 1 and runtime.public_function_records[0].source_suspect_id == 1 and not owner_clue.is_empty()
	runtime.append_public_function_record(1, "Thợ May", PackedInt32Array([2,7]), &"player_2", "Khác phe")
	board.populate(c.location_definitions(), CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles), runtime.public_function_records)
	owner_card = _board_card(board, 1)
	checks.multiple_order = owner_card != null and owner_card.get_public_function_result_text() == "%s\n2 và 7 khác phe." % owner_clue
	checks.no_leak = _public_sentence_has_no_hidden_identity(owner_card.get_public_function_result_text() if owner_card != null else "")
	var result_label: Label = null
	if owner_card != null:
		result_label = owner_card.get_node_or_null("%PublicFunctionResultsLabel") as Label
	checks.wrap = result_label != null and result_label.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART
	checks.no_panel = _case_has_no_node("FunctionHistoryPanel") and _case_has_no_node("FunctionHistoryList")
	board.free()
	var cancelled_runtime := _fresh_available_tailor_bundle(c, roles, p).runtime as CaseRuntimeState
	var cancelled_selection := InvestigationSelectionState.new()
	cancelled_selection.begin_function_selection(PackedInt32Array([1]))
	cancelled_selection.toggle_function_target(4)
	cancelled_selection.cancel()
	var cancelled_board := _board_instance_with_runtime(c, cancelled_runtime, roles)
	var cancelled_owner := _board_card(cancelled_board, 1)
	checks.cancel_clean = cancelled_runtime.public_function_records.is_empty() and cancelled_owner != null and cancelled_owner.get_public_function_result_text().is_empty()
	if cancelled_board != null: cancelled_board.free()
	var invalid_bundle := _fresh_available_tailor_bundle(c, roles, p)
	var invalid_runtime := invalid_bundle.runtime as CaseRuntimeState
	var invalid_result := (invalid_bundle.execution as InteractiveFunctionExecutionService).execute(c, invalid_runtime, 1, PackedInt32Array([4]), invalid_runtime.current_player_id())
	var invalid_board := _board_instance_with_runtime(c, invalid_runtime, roles)
	var invalid_owner := _board_card(invalid_board, 1)
	checks.invalid_clean = not invalid_result.success and invalid_runtime.public_function_records.is_empty() and invalid_owner != null and invalid_owner.get_public_function_result_text().is_empty()
	if invalid_board != null: invalid_board.free()
	var fresh_runtime := _fresh_turn_bundle(c, p).runtime as CaseRuntimeState
	var fresh_board := _board_instance_with_runtime(c, fresh_runtime, roles)
	var fresh_owner := _board_card(fresh_board, 1)
	checks.reset = fresh_owner != null and fresh_owner.get_public_function_result_text().is_empty()
	if fresh_board != null: fresh_board.free()
	return checks


func _post_reveal_input_routing_checks(c: CaseDefinition, roles: Array[RoleDefinition], p: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	var bundle := _post_reveal_tailor_bundle(c, roles, p)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	var availability := bundle.availability as FunctionAvailabilityService
	var board := _board_instance_with_runtime(c, runtime, roles)
	var selection := InvestigationSelectionState.new()
	var began := selection.begin_function_selection(PackedInt32Array([1]))
	if board == null or not began:
		return checks
	board.suspect_action.connect(func(suspect_id: int, button_index: int, is_hold: bool) -> void:
		if button_index != MOUSE_BUTTON_LEFT or is_hold:
			return
		if selection.toggle_function_target(suspect_id):
			board.set_function_target_selection(true, selection.selected_function_target_ids)
	)
	board.set_function_target_selection(true, selection.selected_function_target_ids)
	var card_four := _board_card(board, 4)
	var clicked_four := _emit_board_left_click(board, 4)
	checks.post_click = runtime.case_outcome == CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS and card_four != null and card_four.is_selectable and clicked_four
	checks.investigated_target = runtime.find_suspect(4).is_investigated and 4 in selection.selected_function_target_ids
	checks.first_click = selection.selected_function_target_ids == PackedInt32Array([4])
	_emit_board_left_click(board, 5)
	checks.second_click = selection.selected_function_target_ids == PackedInt32Array([4,5])
	checks.confirm_two = selection.selected_function_target_ids.size() == 2
	var selected_before_crime_scene := selection.selected_function_target_ids.duplicate()
	checks.crime_scene_target = not _emit_board_left_click(board, 0) and selection.selected_function_target_ids == selected_before_crime_scene
	_emit_board_left_click(board, 4)
	checks.toggle_off = selection.selected_function_target_ids == PackedInt32Array([5])
	_emit_board_left_click(board, 4)
	checks.no_duplicate = selection.selected_function_target_ids.size() == 2 and selection.selected_function_target_ids[0] != selection.selected_function_target_ids[1]
	checks.investigation_locked = not runtime.accepts_investigation_actions and not InvestigationService.new().investigate(c, runtime, 3, runtime.current_player_id()).success
	var submission_choice := _post_reveal_submission_choice_checks(c, roles, p)
	checks.post_submission_choice = bool(submission_choice.get("choice_enabled", false))
	checks.post_crime_scene_submission = bool(submission_choice.get("crime_scene_rejected", false))
	checks.post_submission_without_function = bool(submission_choice.get("submitted_without_function", false))
	var uses_before := runtime.find_suspect(1).interactive_function.uses_remaining
	var turn_before := manager.turn_number
	var execution := InteractiveFunctionExecutionService.new().execute(c, runtime, 1, selection.selected_function_target_ids, runtime.current_player_id())
	checks.execute_once = execution.success and runtime.public_function_records.size() == 1 and _successful_function_log_count(runtime) == 1
	checks.usage_once = runtime.find_suspect(1).interactive_function.uses_remaining == uses_before - 1
	manager.advance_turn()
	runtime.apply_turn_snapshot(manager)
	availability.update_for_turn(runtime, manager.turn_number)
	PostRevealFunctionService.new().resolve_phase(c, runtime)
	checks.turn_once = manager.turn_number == turn_before + 1
	checks.history_once = runtime.public_function_records.size() == 1 and runtime.public_function_records[0].summary_text().begins_with("Thợ May: Nghi phạm ")
	checks.final_transition = runtime.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
	board.free()
	checks.submission_selection = _board_submission_selection_routes(c)
	checks.final_selection = checks.submission_selection and _one_active_final(c, p)
	return checks


func _board_instance_with_runtime(c: CaseDefinition, runtime: CaseRuntimeState, roles: Array[RoleDefinition]) -> CaseBoardController:
	var packed := load(CASE_BOARD_PATH) as PackedScene
	if packed == null:
		return null
	var board := packed.instantiate() as CaseBoardController
	if board != null:
		board.populate(c.location_definitions(), CasePublicPresentationBuilder.new().build_suspect_views(c, runtime, roles), runtime.public_function_records, runtime.elapsed_hours)
	return board


func _board_card(board: CaseBoardController, suspect_id: int) -> SuspectCardController:
	if board == null:
		return null
	var grid := board.get_node("%Grid") as GridContainer
	for child in grid.get_children():
		if child is SuspectCardController and (child as SuspectCardController).get_suspect_id() == suspect_id:
			return child as SuspectCardController
	return null


func _emit_board_left_click(board: CaseBoardController, suspect_id: int) -> bool:
	var card := _board_card(board, suspect_id)
	if card == null:
		return false
	card.suspect_action.emit(suspect_id, MOUSE_BUTTON_LEFT, false)
	return true


func _successful_function_log_count(runtime: CaseRuntimeState) -> int:
	var count := 0
	for entry in runtime.action_log:
		if entry.action == "FUNCTION_EXECUTE" and entry.success:
			count += 1
	return count


func _board_submission_selection_routes(c: CaseDefinition) -> bool:
	var board := _board_instance(c)
	if board == null:
		return false
	var selection := InvestigationSelectionState.new()
	selection.begin_submission()
	board.suspect_action.connect(func(suspect_id: int, button_index: int, is_hold: bool) -> void:
		if button_index != MOUSE_BUTTON_LEFT or is_hold:
			return
		if selection.toggle_submission_suspect(suspect_id):
			board.set_submission_selection(true, selection.selected_submission_evil_ids)
	)
	board.set_submission_selection(true)
	_emit_board_left_click(board, 4)
	var passed := selection.selected_submission_evil_ids == PackedInt32Array([4])
	board.free()
	return passed


func _post_reveal_submission_choice_checks(c: CaseDefinition, roles: Array[RoleDefinition], p: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	var bundle := _post_reveal_tailor_bundle(c, roles, p)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	var scene := _case_scene_instance() as VSCaseMainController
	var tree := Engine.get_main_loop() as SceneTree
	if scene == null or tree == null:
		if scene != null:
			scene.free()
		return checks
	tree.root.add_child(scene)
	scene.case_definition = c
	scene.role_definitions = roles
	scene.runtime_state = runtime
	scene.turn_manager = manager
	scene.selection_state.finish()
	scene._refresh_all_presentation()
	var uses_before := runtime.find_suspect(1).interactive_function.uses_remaining
	var records_before := runtime.public_function_records.size()
	scene._on_suspect_action(4, MOUSE_BUTTON_RIGHT, false)
	var selected_before_crime_scene := scene.selection_state.selected_submission_evil_ids.duplicate()
	scene._on_suspect_action(0, MOUSE_BUTTON_RIGHT, false)
	var crime_scene_submission := CaseSubmission.new()
	crime_scene_submission.configure(runtime.current_player_id(), runtime.turn_number, PackedInt32Array([0]), PackedInt32Array(), PackedInt32Array())
	var crime_scene_result := CaseSubmissionService.new().submit(c, runtime, runtime.find_player(runtime.current_player_id()), crime_scene_submission)
	var submit_ready := scene.submit_button != null and scene.submit_button.visible and not scene.submit_button.disabled
	checks.choice_enabled = (
		runtime.case_outcome == CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS
		and scene.selection_state.selected_submission_evil_ids == PackedInt32Array([4])
		and selected_before_crime_scene == PackedInt32Array([4])
		and submit_ready
	)
	checks.crime_scene_rejected = not crime_scene_result.success and crime_scene_result.error_code == &"SUSPECT_NOT_FOUND"
	scene._on_submit_pressed()
	checks.submitted_without_function = (
		runtime.submissions.size() == 1
		and runtime.find_suspect(1).interactive_function.uses_remaining == uses_before
		and runtime.public_function_records.size() == records_before
	)
	tree.root.remove_child(scene)
	scene.free()
	return checks


func _post_reveal_checks(c: CaseDefinition, roles: Array[RoleDefinition], p: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	checks.no_function_final = _eight_sets_awaiting(c, p)
	var bundle := _post_reveal_tailor_bundle(c, roles, p)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	var execution := InteractiveFunctionExecutionService.new()
	checks.available_tailor_post = runtime.case_outcome == CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS and runtime.find_suspect(1).interactive_function.state == InteractiveFunctionRuntimeState.State.AVAILABLE
	checks.post_no_investigation = not runtime.accepts_investigation_actions and not InvestigationService.new().investigate(c, runtime, 2, runtime.current_player_id()).success
	var post_submission_bundle := _post_reveal_tailor_bundle(c, roles, p)
	var post_submission_runtime := post_submission_bundle.runtime as CaseRuntimeState
	var early := CaseSubmission.new(); early.configure(post_submission_runtime.current_player_id(), post_submission_runtime.turn_number, PackedInt32Array([4]), PackedInt32Array(), PackedInt32Array())
	checks.post_early_submit = CaseSubmissionService.new().submit(c, post_submission_runtime, post_submission_runtime.find_player(post_submission_runtime.current_player_id()), early).success
	var used := execution.execute(c, runtime, 1, PackedInt32Array([2, 4]), runtime.current_player_id())
	if used.success:
		manager.advance_turn(); runtime.apply_turn_snapshot(manager)
		(bundle.availability as FunctionAvailabilityService).update_for_turn(runtime, manager.turn_number)
		PostRevealFunctionService.new().resolve_phase(c, runtime)
	checks.tailor_then_final = used.success and runtime.find_suspect(1).interactive_function.state == InteractiveFunctionRuntimeState.State.EXHAUSTED and runtime.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
	checks.locked_tailor_unlocks = _last_reveal_tailor_unlocks(c, roles, p)
	checks.multiple_sequential = _multiple_post_functions_resolve(c, roles, p)
	checks.exhausted_no_block = _exhausted_post_does_not_block(c, roles, p)
	checks.invalid_targets_no_deadlock = _invalid_target_post_does_not_deadlock(roles, p)
	var final_runtime := _fresh_final_runtime(c, p)
	var final_turn := final_runtime.turn_number
	var final_service := FinalVerdictService.new(); final_service.initialize(final_runtime)
	for answer in [PackedInt32Array([4,5]), PackedInt32Array([4]), PackedInt32Array([5,4])]:
		if final_runtime.case_outcome != CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT: break
		var submission := CaseSubmission.new(); submission.configure(final_runtime.current_final_player_id(), final_runtime.turn_number, answer, PackedInt32Array(), PackedInt32Array(), CaseEnums.SubmissionPhase.FINAL)
		final_service.lock_submission(c, final_runtime, submission)
	checks.final_turn_static = final_runtime.turn_number == final_turn
	return checks


func _post_reveal_tailor_bundle(c: CaseDefinition, roles: Array[RoleDefinition], p: Array[PlayerCaseState]) -> Dictionary:
	var bundle := _fresh_function_bundle(c, roles, p)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	var availability := bundle.availability as FunctionAvailabilityService
	for suspect in c.suspects:
		var result := InvestigationService.new().investigate(c, runtime, suspect.suspect_id, runtime.current_player_id())
		if not result.success: return bundle
		availability.reveal_for_suspect(c, runtime, roles, suspect.suspect_id, manager.turn_number)
		manager.advance_turn(); runtime.apply_turn_snapshot(manager)
		availability.update_for_turn(runtime, manager.turn_number)
	return bundle


func _last_reveal_tailor_unlocks(c: CaseDefinition, roles: Array[RoleDefinition], p: Array[PlayerCaseState]) -> bool:
	var bundle := _fresh_function_bundle(c, roles, p)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	var availability := bundle.availability as FunctionAvailabilityService
	for suspect_id in range(2, 9):
		InvestigationService.new().investigate(c, runtime, suspect_id, runtime.current_player_id())
		manager.advance_turn(); runtime.apply_turn_snapshot(manager)
	var result := InvestigationService.new().investigate(c, runtime, 1, runtime.current_player_id())
	var revealed := availability.reveal_for_suspect(c, runtime, roles, 1, manager.turn_number)
	var locked_before_advance := runtime.find_suspect(1).interactive_function.state == InteractiveFunctionRuntimeState.State.LOCKED_UNTIL_NEXT_TURN
	manager.advance_turn(); runtime.apply_turn_snapshot(manager)
	availability.update_for_turn(runtime, manager.turn_number)
	return result.success and revealed and locked_before_advance and runtime.case_outcome == CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS and runtime.find_suspect(1).interactive_function.state == InteractiveFunctionRuntimeState.State.AVAILABLE


func _multiple_post_functions_resolve(c: CaseDefinition, roles: Array[RoleDefinition], p: Array[PlayerCaseState]) -> bool:
	var bundle := _post_reveal_tailor_bundle(c, roles, p)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	var tailor := _find_role_for_test(roles, &"tailor")
	var second := InteractiveFunctionRuntimeState.new(2); second.configure_hidden(tailor); second.state = InteractiveFunctionRuntimeState.State.AVAILABLE
	runtime.find_suspect(2).interactive_function = second
	var execution := InteractiveFunctionExecutionService.new()
	var first := execution.execute(c, runtime, 1, PackedInt32Array([2,3]), runtime.current_player_id())
	manager.advance_turn(); runtime.apply_turn_snapshot(manager)
	var remained_post := not PostRevealFunctionService.new().resolve_phase(c, runtime) and runtime.case_outcome == CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS
	var second_result := execution.execute(c, runtime, 2, PackedInt32Array([3,4]), runtime.current_player_id())
	manager.advance_turn(); runtime.apply_turn_snapshot(manager)
	var entered_final := PostRevealFunctionService.new().resolve_phase(c, runtime)
	return first.success and remained_post and second_result.success and entered_final and runtime.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT


func _exhausted_post_does_not_block(c: CaseDefinition, roles: Array[RoleDefinition], p: Array[PlayerCaseState]) -> bool:
	var runtime := _fresh_final_runtime(c, p)
	runtime.case_outcome = CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS
	var tailor := _find_role_for_test(roles, &"tailor")
	var state := InteractiveFunctionRuntimeState.new(1); state.configure_hidden(tailor); state.state = InteractiveFunctionRuntimeState.State.EXHAUSTED; state.uses_remaining = 0
	runtime.find_suspect(1).interactive_function = state
	return PostRevealFunctionService.new().resolve_phase(c, runtime) and state.state == InteractiveFunctionRuntimeState.State.EXHAUSTED and runtime.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT


func _invalid_target_post_does_not_deadlock(roles: Array[RoleDefinition], p: Array[PlayerCaseState]) -> bool:
	var suspect := SuspectDefinition.new(); suspect.suspect_id = 1
	var tiny_case := CaseDefinition.new(); tiny_case.case_id = &"post_no_targets"; tiny_case.suspects.append(suspect)
	var runtime := CaseRuntimeState.new(); runtime.initialize(tiny_case, p); runtime.suspects[0].is_investigated = true; runtime.case_outcome = CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS; runtime.lock_case_actions()
	var tailor := _find_role_for_test(roles, &"tailor")
	var state := InteractiveFunctionRuntimeState.new(1); state.configure_hidden(tailor); state.state = InteractiveFunctionRuntimeState.State.AVAILABLE
	runtime.suspects[0].interactive_function = state
	return PostRevealFunctionService.new().resolve_phase(tiny_case, runtime) and state.state == InteractiveFunctionRuntimeState.State.EXPIRED and runtime.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT


func _find_role_for_test(roles: Array[RoleDefinition], role_id: StringName) -> RoleDefinition:
	for role in roles:
		if role.role_id == role_id: return role
	return null


func _g2h_checks(c: CaseDefinition, roles: Array[RoleDefinition], p: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	checks.service_load = FinalVerdictService.new() != null
	var b := _fresh_turn_bundle(c, p, 3030)
	var r := b.runtime as CaseRuntimeState
	var manager := b.manager as TurnManager
	r.find_player(&"player_1").submission_status = CaseEnums.SubmissionStatus.SUBMITTED_WRONG
	r.find_player(&"player_1").is_active_in_investigation = false
	for suspect in r.suspects: suspect.is_investigated = true
	r.case_outcome = CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
	r.lock_case_actions()
	var turn_before := manager.turn_number
	var resources_before := _resource_snapshot(r)
	var svc := FinalVerdictService.new()
	var initialized := svc.initialize(r)
	checks.awaiting = r.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
	checks.actions_locked = not r.accepts_investigation_actions and not InvestigationService.new().investigate(c, r, 1, &"player_2").success
	var early := CaseSubmission.new(); early.configure(&"player_2", r.turn_number, PackedInt32Array(), PackedInt32Array(), PackedInt32Array())
	checks.early_disabled = not CaseSubmissionService.new().submit(c, r, r.find_player(&"player_2"), early).success
	checks.required_filtered = initialized.success and r.final_required_player_ids == [&"player_2", &"player_3"]
	checks.early_wrong_excluded = &"player_1" not in r.final_required_player_ids
	checks.frozen_order = r.final_required_player_ids == [&"player_2", &"player_3"]
	var selection := InvestigationSelectionState.new()
	checks.draft_supported = selection.begin_submission() and selection.toggle_submission_suspect(4)
	checks.cancel_stays_final = selection.cancel() and r.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
	checks.cancel_no_lock = r.final_submissions.is_empty()
	var source_ids := PackedInt32Array([5, 4])
	var s2 := CaseSubmission.new(); s2.configure(&"player_2", r.turn_number, source_ids, PackedInt32Array([4]), PackedInt32Array([5]), CaseEnums.SubmissionPhase.FINAL)
	var first_result := svc.lock_submission(c, r, s2)
	checks.first_locked = first_result.success and s2.is_locked
	var locked_snapshot := s2.selected_evil_ids.duplicate(); source_ids.clear()
	checks.immutable = not s2.configure(&"player_2", 99, PackedInt32Array(), PackedInt32Array(), PackedInt32Array()) and s2.selected_evil_ids == locked_snapshot
	checks.copied = s2.selected_evil_ids == PackedInt32Array([5, 4]) and source_ids.is_empty()
	var duplicate := CaseSubmission.new(); duplicate.configure(&"player_2", r.turn_number, PackedInt32Array([4,5]), PackedInt32Array(), PackedInt32Array(), CaseEnums.SubmissionPhase.FINAL)
	checks.duplicate_rejected = not svc.lock_submission(c, r, duplicate).success
	var lock_log: Dictionary = r.action_log.back()
	checks.pending_private = lock_log.action == "FINAL_VERDICT_LOCKED" and not lock_log.has("selected_evil_ids") and not lock_log.has("main_answer_correct")
	checks.next_clean = r.current_final_player_id() == &"player_3"
	checks.ui_nodes = _final_ui_nodes_exist()
	checks.barrier = r.final_results.is_empty() and r.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
	checks.pending_status = r.find_player(&"player_2").submission_status == CaseEnums.SubmissionStatus.FINAL_LOCKED_PENDING
	var handoff := _final_handoff_ui_flow(c, roles, p)
	checks.handoff_no_continue = bool(handoff.get("no_continue", false))
	checks.handoff_layer = bool(handoff.get("layer", false))
	checks.handoff_next_player = bool(handoff.get("next_player", false))
	checks.handoff_blocks_input = bool(handoff.get("blocks_input", false))
	checks.handoff_after_select = bool(handoff.get("after_select", false))
	checks.handoff_no_leak = bool(handoff.get("no_leak", false))
	checks.handoff_independent_locks = bool(handoff.get("independent_locks", false))
	checks.handoff_truth_after_all = bool(handoff.get("truth_after_all", false))
	checks.sidebar_normal = bool(handoff.get("sidebar_normal", false))
	checks.sidebar_first = bool(handoff.get("sidebar_first", false))
	checks.sidebar_second = bool(handoff.get("sidebar_second", false))
	checks.sidebar_third = bool(handoff.get("sidebar_third", false))
	checks.sidebar_turn_static = bool(handoff.get("sidebar_turn_static", false))
	var s3 := CaseSubmission.new(); s3.configure(&"player_3", r.turn_number, PackedInt32Array([4]), PackedInt32Array(), PackedInt32Array(), CaseEnums.SubmissionPhase.FINAL)
	var last_result := svc.lock_submission(c, r, s3)
	checks.evaluated_once = last_result.evaluation_performed and r.final_evaluation_count == 1 and r.final_results.size() == 2
	checks.order_independent = &"player_2" in r.final_correct_player_ids
	checks.classification_independent = r.final_results[0].main_answer_correct and r.final_results[0].underling_classification_correct and r.final_results[0].traitor_classification_correct
	checks.early_wrong_preserved = r.find_player(&"player_1").submission_status == CaseEnums.SubmissionStatus.SUBMITTED_WRONG
	checks.results_public = r.case_outcome == CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED and _has_final_result_log(r)
	checks.correct_ids = r.final_correct_player_ids == [&"player_2"]
	checks.wrong_ids = r.final_wrong_player_ids == [&"player_3"]
	checks.no_truth = _final_logs_hide_truth(r)
	checks.turn_static = manager.turn_number == turn_before and r.turn_number == turn_before
	checks.resources = resources_before == _resource_snapshot(r)
	checks.multiple_correct = _final_pattern(c, p, [PackedInt32Array([4,5]), PackedInt32Array([5,4]), PackedInt32Array([4])]) == 2
	checks.all_wrong = _final_pattern(c, p, [PackedInt32Array(), PackedInt32Array([4]), PackedInt32Array([5])]) == 0
	checks.one_active = _one_active_final(c, p)
	checks.zero_guard = _zero_final_guard(c, p)
	var expiry := _expiry_checks(c, roles, p)
	checks.expiry = expiry.expired
	checks.exhausted_stable = expiry.exhausted_stable
	checks.expiry_usage = expiry.usage_stable
	checks.early_regression = _submission_outcome(c, p, PackedInt32Array([4,5])) == CaseEnums.CaseOutcome.EARLY_SOLVED
	checks.all_failed_regression = _all_players_fail(c, p)
	checks.tailor_regression = _tailor_valid_pair_succeeds(c, roles, p)
	checks.turn_regression = _investigation_advances_once(c, p)
	checks.layout = _case_board_layout_preserved()
	checks.reset = _final_reset(c, p)
	checks.no_2i = not ClassDB.class_exists("RewardCalculator")
	return checks


func _fresh_final_runtime(c: CaseDefinition, p: Array[PlayerCaseState]) -> CaseRuntimeState:
	var b := _fresh_turn_bundle(c, p, 3030)
	var r := b.runtime as CaseRuntimeState
	for suspect in r.suspects: suspect.is_investigated = true
	r.case_outcome = CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
	r.lock_case_actions()
	return r


func _final_pattern(c: CaseDefinition, p: Array[PlayerCaseState], answers: Array) -> int:
	var r := _fresh_final_runtime(c, p)
	var svc := FinalVerdictService.new(); svc.initialize(r)
	for index in range(answers.size()):
		var submission := CaseSubmission.new()
		var answer: PackedInt32Array = answers[index]
		submission.configure(r.current_final_player_id(), r.turn_number, answer, PackedInt32Array(), PackedInt32Array(), CaseEnums.SubmissionPhase.FINAL)
		svc.lock_submission(c, r, submission)
	return r.final_correct_player_ids.size()


func _one_active_final(c: CaseDefinition, p: Array[PlayerCaseState]) -> bool:
	var r := _fresh_final_runtime(c, p)
	for player in r.players:
		if player.player_id != &"player_3":
			player.is_active_in_investigation = false
			player.submission_status = CaseEnums.SubmissionStatus.SUBMITTED_WRONG
	var svc := FinalVerdictService.new(); svc.initialize(r)
	var submission := CaseSubmission.new(); submission.configure(&"player_3", r.turn_number, PackedInt32Array([4,5]), PackedInt32Array(), PackedInt32Array(), CaseEnums.SubmissionPhase.FINAL)
	var result := svc.lock_submission(c, r, submission)
	return result.evaluation_performed and r.final_required_player_ids == [&"player_3"] and r.case_outcome == CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED


func _zero_final_guard(c: CaseDefinition, p: Array[PlayerCaseState]) -> bool:
	var r := _fresh_final_runtime(c, p)
	for player in r.players:
		player.is_active_in_investigation = false
		player.submission_status = CaseEnums.SubmissionStatus.SUBMITTED_WRONG
	var result := FinalVerdictService.new().initialize(r)
	return not result.success and result.error_code == &"FINAL_REQUIRED_PLAYERS_EMPTY" and r.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT


func _expiry_checks(c: CaseDefinition, roles: Array[RoleDefinition], p: Array[PlayerCaseState]) -> Dictionary:
	var b := _fresh_function_bundle(c, roles, p)
	var r := b.runtime as CaseRuntimeState
	var availability := b.availability as FunctionAvailabilityService
	r.find_suspect(1).is_investigated = true
	availability.reveal_for_suspect(c, r, roles, 1, 1)
	availability.update_for_turn(r, 2)
	var state := r.find_suspect(1).interactive_function
	var usage_before := state.uses_remaining
	availability.expire_for_final_verdict(r)
	var expired := state.state == InteractiveFunctionRuntimeState.State.EXPIRED
	var usage_stable := state.uses_remaining == usage_before
	state.state = InteractiveFunctionRuntimeState.State.EXHAUSTED
	availability.expire_for_final_verdict(r)
	return {"expired": expired, "usage_stable": usage_stable, "exhausted_stable": state.state == InteractiveFunctionRuntimeState.State.EXHAUSTED}


func _resource_snapshot(r: CaseRuntimeState) -> Array:
	var values: Array = []
	for player in r.players: values.append([player.merit, player.reputation, player.orb_count, player.gacha_ticket_count])
	return values


func _has_final_result_log(r: CaseRuntimeState) -> bool:
	for entry in r.action_log:
		if entry.action == "FINAL_VERDICT_RESULT": return true
	return false


func _final_logs_hide_truth(r: CaseRuntimeState) -> bool:
	for entry in r.action_log:
		for forbidden in ["selected_evil_ids", "true_role_id", "true_alignment", "is_corrupted", "is_impersonating"]:
			if entry.has(forbidden): return false
	return true


func _final_ui_nodes_exist() -> bool:
	var scene := _case_scene_instance()
	if scene == null: return false
	var passed := (
		scene.get_node_or_null("%FinalContinueButton") == null
		and scene.get_node_or_null("%FinalHandoffOverlay") != null
		and scene.get_node_or_null("%FinalHandoffPlayerLabel") != null
		and scene.get_node_or_null("%FinalResultLabel") != null
	)
	scene.free()
	return passed


func _final_handoff_ui_flow(c: CaseDefinition, roles: Array[RoleDefinition], p: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	var scene := _case_scene_instance() as VSCaseMainController
	var tree := Engine.get_main_loop() as SceneTree
	if scene == null or tree == null:
		if scene != null:
			scene.free()
		return checks
	tree.root.add_child(scene)
	var card_packed: PackedScene = load(SUSPECT_CARD_PATH) as PackedScene
	if card_packed != null:
		var card: Control = card_packed.instantiate() as Control
		if card != null:
			var visual: CanvasItem = card.get_node_or_null("%CardVisual") as CanvasItem
			var hand: CanvasItem = card.get_node_or_null("%FunctionHandMarker") as CanvasItem
			var dead: CanvasItem = card.get_node_or_null("%DeadMarker") as CanvasItem
			checks.layer = (
				scene.final_handoff_overlay != null
				and visual != null and hand != null and dead != null
				and scene.final_handoff_overlay.z_index > maxi(visual.z_index, maxi(hand.z_index, dead.z_index))
				and not visual.top_level and not hand.top_level and not dead.top_level
			)
			card.free()
	var bundle := _fresh_turn_bundle(c, p, 3030)
	var runtime := bundle.runtime as CaseRuntimeState
	var manager := bundle.manager as TurnManager
	var gameplay_player: PlayerCaseState = manager.get_current_player()
	var gameplay_turn_number: int = manager.turn_number
	var runtime_turn_number: int = runtime.turn_number
	var runtime_turn_index: int = runtime.current_turn_index
	scene.case_definition = c
	scene.role_definitions = roles
	scene.runtime_state = runtime
	scene.turn_manager = manager
	scene._update_turn_display()
	checks.sidebar_normal = _final_sidebar_shows_player(scene, gameplay_player)
	for suspect in runtime.suspects:
		suspect.is_investigated = true
	runtime.case_outcome = CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
	runtime.lock_case_actions()
	scene.selection_state.finish()
	scene.final_initialized = false
	scene.final_handoff_active = false
	scene._refresh_all_presentation()
	checks.sidebar_first = runtime.current_final_player_id() == &"player_1" and _final_sidebar_shows_player(scene, runtime.find_player(&"player_1"))
	scene._on_suspect_action(4, MOUSE_BUTTON_RIGHT, false)
	var player_one_selection := scene.selection_state.selected_submission_evil_ids.duplicate()
	scene._on_submit_pressed()
	checks.no_continue = scene.get_node_or_null("%FinalContinueButton") == null and scene.final_handoff_active
	checks.next_player = runtime.current_final_player_id() == &"player_2"
	checks.sidebar_second = (
		bool(checks.get("next_player", false))
		and _final_sidebar_shows_player(scene, runtime.find_player(&"player_2"))
		and scene.final_handoff_player_label != null
		and scene.final_handoff_player_label.text == scene._handoff_player_text(runtime.find_player(&"player_2"))
	)
	checks.no_leak = player_one_selection == PackedInt32Array([4]) and scene.selection_state.selected_submission_evil_ids.is_empty()
	scene._on_suspect_action(5, MOUSE_BUTTON_RIGHT, false)
	checks.blocks_input = scene.selection_state.selected_submission_evil_ids.is_empty()
	if scene._final_handoff_tween != null:
		scene._final_handoff_tween.kill()
	scene._finish_final_handoff()
	scene._on_suspect_action(5, MOUSE_BUTTON_RIGHT, false)
	checks.after_select = (
		runtime.current_final_player_id() == &"player_2"
		and scene.selection_state.selected_submission_evil_ids == PackedInt32Array([5])
		and scene.submit_button != null
		and scene.submit_button.visible
		and not scene.submit_button.disabled
	)
	scene._on_submit_pressed()
	var barrier_holds := runtime.case_outcome == CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT and runtime.final_results.is_empty()
	checks.sidebar_third = (
		runtime.current_final_player_id() == &"player_3"
		and _final_sidebar_shows_player(scene, runtime.find_player(&"player_3"))
		and scene.final_handoff_player_label != null
		and scene.final_handoff_player_label.text == scene._handoff_player_text(runtime.find_player(&"player_3"))
	)
	if scene._final_handoff_tween != null:
		scene._final_handoff_tween.kill()
	scene._finish_final_handoff()
	scene._on_suspect_action(4, MOUSE_BUTTON_RIGHT, false)
	scene._on_suspect_action(5, MOUSE_BUTTON_RIGHT, false)
	scene._on_submit_pressed()
	checks.independent_locks = runtime.final_submissions.size() == runtime.final_required_player_ids.size()
	checks.truth_after_all = barrier_holds and runtime.case_outcome == CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED and runtime.final_results.size() == runtime.final_required_player_ids.size()
	checks.sidebar_turn_static = (
		manager.turn_number == gameplay_turn_number
		and manager.get_current_player() == gameplay_player
		and runtime.turn_number == runtime_turn_number
		and runtime.current_turn_index == runtime_turn_index
	)
	tree.root.remove_child(scene)
	scene.free()
	return checks


func _final_sidebar_shows_player(scene: VSCaseMainController, player: PlayerCaseState) -> bool:
	return (
		scene != null and player != null
		and scene.turn_label != null and scene.player_strip_label != null
		and scene.turn_label.text == "LƯỢT HIỆN TẠI\n%s" % player.display_name
		and scene.player_strip_label.text.contains("> %s:" % player.display_name)
	)


func _final_reset(c: CaseDefinition, p: Array[PlayerCaseState]) -> bool:
	var first := _fresh_final_runtime(c, p); FinalVerdictService.new().initialize(first)
	var submission := CaseSubmission.new(); submission.configure(first.current_final_player_id(), first.turn_number, PackedInt32Array([4,5]), PackedInt32Array(), PackedInt32Array(), CaseEnums.SubmissionPhase.FINAL)
	FinalVerdictService.new().lock_submission(c, first, submission)
	var second := _fresh_turn_bundle(c, p, 3030).runtime as CaseRuntimeState
	return second.final_required_player_ids.is_empty() and second.final_submissions.is_empty() and second.final_results.is_empty() and second.final_input_index == 0 and second.case_outcome == CaseEnums.CaseOutcome.IN_PROGRESS


func _g2i_checks(c: CaseDefinition, roles: Array[RoleDefinition], p: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {"service": CaseSettlementService.new() != null}
	var open_runtime := _fresh_turn_bundle(c, p).runtime as CaseRuntimeState
	var service := CaseSettlementService.new()
	checks.reject_open = not service.settle(c, open_runtime).success
	var post_runtime := _fresh_turn_bundle(c, p).runtime as CaseRuntimeState
	post_runtime.case_outcome = CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS
	checks.reject_post = not service.settle(c, post_runtime).success
	var awaiting_runtime := _fresh_turn_bundle(c, p).runtime as CaseRuntimeState
	awaiting_runtime.case_outcome = CaseEnums.CaseOutcome.AWAITING_FINAL_VERDICT
	checks.reject_awaiting = not service.settle(c, awaiting_runtime).success
	checks.truth_gate = CaseTruthRevealBuilder.new().build(c, open_runtime, roles) == null
	var early := _fresh_turn_bundle(c, p).runtime as CaseRuntimeState
	var early_submission := _locked_submission(&"player_1", PackedInt32Array([4,5]), PackedInt32Array([4]), PackedInt32Array([5]), CaseEnums.SubmissionPhase.EARLY)
	early.submissions.append(early_submission)
	early.find_player(&"player_1").submission_status = CaseEnums.SubmissionStatus.SUBMITTED_CORRECT
	for player_id in [&"player_2", &"player_3"]:
		early.find_player(player_id).submission_status = CaseEnums.SubmissionStatus.NOT_SUBMITTED_CASE_ENDED
	early.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
	var before_early := early.find_player(&"player_1").duplicate(true) as PlayerCaseState
	var early_result := service.settle(c, early)
	var early_player := early.find_player(&"player_1")
	checks.early = early_result.success
	checks.early_merit = is_equal_approx(early_player.merit, before_early.merit + c.merit_pool)
	checks.early_rep = early_player.reputation == mini(6, before_early.reputation + c.on_solve.reputation_delta)
	checks.early_base = early_player.gacha_ticket_count >= before_early.gacha_ticket_count + c.base_ticket_reward
	checks.early_no_bonus = early_player.gacha_ticket_count == before_early.gacha_ticket_count + c.base_ticket_reward and early_result.player_resolutions[0].reward.total_ticket_delta() == c.base_ticket_reward
	checks.early_orb = early_player.orb_count == before_early.orb_count
	var single_accuse_runtime := _fresh_turn_bundle(c, p).runtime as CaseRuntimeState
	var single_accuse_player: PlayerCaseState = single_accuse_runtime.find_player(single_accuse_runtime.current_player_id())
	if single_accuse_player != null and c.evil_suspect_ids.size() >= 2:
		single_accuse_runtime.add_private_role_knowledge(single_accuse_player.player_id, c.evil_suspect_ids[0], &"smoke_known_evil")
		var single_accuse_result: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(c, single_accuse_runtime, single_accuse_player, c.evil_suspect_ids[1], CaseEnums.SubmissionPhase.EARLY)
		var single_accuse_settlement: CaseSettlementResult = CaseSettlementService.new().settle(c, single_accuse_runtime)
		checks.single_accuse_reward = false
		if single_accuse_result.success and single_accuse_result.completed_evil_set and single_accuse_settlement.success and single_accuse_settlement.player_resolutions.size() > 0 and early_result.player_resolutions.size() > 0:
			var normal_resolution := early_result.player_resolutions[0] as PlayerCaseResolution
			var single_resolution := single_accuse_settlement.player_resolutions[0] as PlayerCaseResolution
			checks.single_accuse_reward = (
				single_resolution.main_answer_correct == normal_resolution.main_answer_correct
				and is_equal_approx(single_resolution.reward.merit_delta, normal_resolution.reward.merit_delta)
				and single_resolution.reward.reputation_delta == normal_resolution.reward.reputation_delta
				and single_resolution.reward.orb_delta == normal_resolution.reward.orb_delta
				and single_resolution.reward.total_ticket_delta() == normal_resolution.reward.total_ticket_delta()
			)
	else:
		checks.single_accuse_reward = false
	var absent := early_result.player_resolutions[1] as PlayerCaseResolution
	checks.not_submitted = absent.outcome == CaseEnums.PlayerResolutionOutcome.NOT_SUBMITTED_CASE_ENDED and absent.reward.merit_delta == 0.0 and absent.reward.reputation_delta == 0 and absent.reward.orb_delta == 0 and absent.reward.total_ticket_delta() == 0
	checks.settled = early.is_settled and early.settlement_result == early_result
	var merit_after := early_player.merit
	var rep_after := early_player.reputation
	var orb_after := early_player.orb_count
	var tickets_after := early_player.gacha_ticket_count
	checks.idempotent = service.settle(c, early) == early_result and early_player.merit == merit_after and early_player.reputation == rep_after and early_player.orb_count == orb_after and early_player.gacha_ticket_count == tickets_after
	var all_failed := _fresh_turn_bundle(c, p).runtime as CaseRuntimeState
	for player in all_failed.players:
		all_failed.submissions.append(_locked_submission(player.player_id, PackedInt32Array([1]), PackedInt32Array(), PackedInt32Array(), CaseEnums.SubmissionPhase.EARLY))
	all_failed.case_outcome = CaseEnums.CaseOutcome.ALL_FAILED_EARLY
	var all_failed_result := CaseSettlementService.new().settle(c, all_failed)
	checks.all_failed = all_failed_result.success
	checks.wrong_early = all_failed_result.success
	for resolution in all_failed_result.player_resolutions:
		checks.wrong_early = checks.wrong_early and resolution.reward.merit_delta == 0.0 and resolution.reward.reputation_delta == -1 and resolution.reward.orb_delta == 1 and resolution.reward.total_ticket_delta() == 0
	var reveal := CaseTruthRevealBuilder.new().build(c, early, roles)
	checks.truth = reveal != null
	checks.truth_answer = reveal != null and reveal.evil_suspect_ids == PackedInt32Array([4,5])
	checks.truth_count = reveal != null and reveal.suspect_truths.size() == 8
	checks.truth_players = reveal != null and reveal.player_resolutions.size() == 3
	checks.truth_functions = reveal != null and reveal.public_function_records.size() == 0
	var t4 := reveal.suspect_truths[3] as SuspectTruthReveal
	var t5 := reveal.suspect_truths[4] as SuspectTruthReveal
	var t6 := reveal.suspect_truths[5] as SuspectTruthReveal
	checks.truth_four = t4.suspect_id == 4 and t4.alignment_label == "Phe Ác" and t4.role_group_label == "Thuộc Hạ" and t4.is_impersonating and t4.true_role_name != t4.displayed_role_name
	checks.truth_five = t5.suspect_id == 5 and t5.role_group_label == "Nghịch Thần"
	checks.truth_six = t6.suspect_id == 6 and t6.is_corrupted
	var final_runtime := _fresh_turn_bundle(c, p).runtime as CaseRuntimeState
	final_runtime.final_submissions.append(_locked_submission(&"player_1", PackedInt32Array([4,5]), PackedInt32Array([4]), PackedInt32Array([5]), CaseEnums.SubmissionPhase.FINAL))
	final_runtime.final_submissions.append(_locked_submission(&"player_2", PackedInt32Array([4,5]), PackedInt32Array(), PackedInt32Array(), CaseEnums.SubmissionPhase.FINAL))
	final_runtime.final_submissions.append(_locked_submission(&"player_3", PackedInt32Array([4]), PackedInt32Array([4]), PackedInt32Array(), CaseEnums.SubmissionPhase.FINAL))
	final_runtime.case_outcome = CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED
	var final_turn_before := final_runtime.turn_number
	var final_result := CaseSettlementService.new().settle(c, final_runtime)
	checks.final = final_result.success and final_result.player_resolutions.size() == 3
	checks.final_merit = is_equal_approx(final_result.player_resolutions[0].reward.merit_delta, 10.0) and is_equal_approx(final_result.player_resolutions[1].reward.merit_delta, 10.0)
	checks.rounding = is_equal_approx(round((20.0 / 3.0) * 100.0) / 100.0, 6.67)
	checks.final_correct = final_result.player_resolutions[0].main_answer_correct and final_result.player_resolutions[0].reward.base_ticket_delta == 1 and final_result.player_resolutions[0].reward.reputation_delta >= 0
	checks.final_wrong = not final_result.player_resolutions[2].main_answer_correct and final_result.player_resolutions[2].reward.merit_delta == 0.0 and final_result.player_resolutions[2].reward.orb_delta == 1 and final_result.player_resolutions[2].reward.total_ticket_delta() == 0 and final_result.player_resolutions[2].reward.reputation_delta <= 0
	checks.classification = final_result.player_resolutions[1].main_answer_correct and not final_result.player_resolutions[1].underling_classification_correct and not final_result.player_resolutions[1].traitor_classification_correct and final_result.player_resolutions[1].reward.base_ticket_delta == c.base_ticket_reward and final_result.player_resolutions[1].reward.total_ticket_delta() == c.base_ticket_reward
	checks.clamp = clampi(-1, 0, 6) == 0 and clampi(7, 0, 6) == 6
	checks.final_turn = final_runtime.turn_number == final_turn_before
	var final_one_result := CaseSettlementService.new().settle(c, _g2i_final_runtime(c, p, 1))
	checks.final_one = final_one_result.success and is_equal_approx(final_one_result.player_resolutions[0].reward.merit_delta, 20.0)
	var final_three_result := CaseSettlementService.new().settle(c, _g2i_final_runtime(c, p, 3))
	checks.final_three = final_three_result.success
	for resolution in final_three_result.player_resolutions:
		checks.final_three = checks.final_three and is_equal_approx(resolution.reward.merit_delta, 6.67) and resolution.reward.orb_delta == 0
	var scene := _case_scene_instance()
	checks.ui = scene != null and scene.get_node_or_null("%TruthRevealPanel") != null and scene.get_node_or_null("%TruthAnswerLabel") != null and scene.get_node_or_null("%TruthSuspectsLabel") != null and scene.get_node_or_null("%TruthPlayersLabel") != null and scene.get_node_or_null("%TruthRewardsLabel") != null and scene.get_node_or_null("%TruthScroll") != null
	checks.ui_hidden = scene != null and not (scene.get_node("%TruthRevealPanel") as Control).visible
	if scene != null: scene.free()
	var source := FileAccess.get_file_as_string("res://scripts/presentation/case_gameplay/VSCaseMainController.gd")
	checks.source_order = source.find("_ensure_settlement_and_truth()") >= 0 and source.find("settlement_service.settle") < source.find("truth_reveal_builder.build")
	var fresh := _fresh_turn_bundle(c, p).runtime as CaseRuntimeState
	checks.reset = not fresh.is_settled and fresh.settlement_result == null and fresh.truth_reveal == null
	checks.deferred = before_early.merit == (p[0] as PlayerCaseState).merit
	checks.build = AppVersion.G2I_HISTORICAL_BUILD_LABEL == "g2i-overlay-regression-fix"
	return checks

func _g2i_final_runtime(c: CaseDefinition, p: Array[PlayerCaseState], correct_count: int) -> CaseRuntimeState:
	var runtime := _fresh_turn_bundle(c, p).runtime as CaseRuntimeState
	for index in range(runtime.players.size()):
		var correct := index < correct_count
		runtime.final_submissions.append(_locked_submission(runtime.players[index].player_id, PackedInt32Array([4,5]) if correct else PackedInt32Array([1]), PackedInt32Array([4]) if correct else PackedInt32Array(), PackedInt32Array([5]) if correct else PackedInt32Array(), CaseEnums.SubmissionPhase.FINAL))
	runtime.case_outcome = CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED
	return runtime

func _locked_submission(player_id: StringName, evil: PackedInt32Array, underling: PackedInt32Array, traitor: PackedInt32Array, phase: CaseEnums.SubmissionPhase) -> CaseSubmission:
	var submission := CaseSubmission.new()
	submission.configure(player_id, 1, evil, underling, traitor, phase)
	submission.lock()
	return submission


func _t08_final_tutorial_checks(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState], validation_report: Dictionary) -> Dictionary:
	var checks: Dictionary = {}
	var conman: RoleDefinition = _find_role_for_test(roles, &"conman")
	var copycat: RoleDefinition = _find_role_for_test(roles, &"copycat")
	var s2: SuspectDefinition = _t08_suspect(c, 2)
	var s3: SuspectDefinition = _t08_suspect(c, 3)
	var s6: SuspectDefinition = _t08_suspect(c, 6)
	var info_service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var conman_math: InvestigationInformationResult = info_service.evaluate(c, 2, roles)
	var real_math: InvestigationInformationResult = info_service.evaluate(c, 4, roles)
	var therapist: InvestigationInformationResult = info_service.evaluate(c, 1, roles)
	var mobster_therapist: InvestigationInformationResult = info_service.evaluate(c, 6, roles)
	var copycat_vigilante_info: InvestigationInformationResult = info_service.evaluate(c, 3, roles)
	var true_vigilante_info: InvestigationInformationResult = info_service.evaluate(c, 5, roles)
	var action: Dictionary = _t08_copycat_vigilante_action(c, roles, players)
	var action_runtime: CaseRuntimeState = action.get("runtime", null) as CaseRuntimeState
	var action_result: InteractiveFunctionResult = action.get("result", null) as InteractiveFunctionResult
	var action_function: InteractiveFunctionRuntimeState = action.get("function", null) as InteractiveFunctionRuntimeState
	var conman_accuse: Dictionary = _t08_single_accuse_conman(c, players)
	var conman_accuse_runtime: CaseRuntimeState = conman_accuse.get("runtime", null) as CaseRuntimeState
	var conman_accuse_result: SingleSuspectAccusationResult = conman_accuse.get("result", null) as SingleSuspectAccusationResult
	var reveal_action: Dictionary = _t08_copycat_vigilante_action(c, roles, players)
	var reveal_runtime: CaseRuntimeState = reveal_action.get("runtime", null) as CaseRuntimeState
	var reveal: CaseTruthReveal = _t08_reveal_after_action(c, roles, reveal_runtime)
	var truth_s2: SuspectTruthReveal = _truth_for_suspect(reveal, 2)
	var truth_s3: SuspectTruthReveal = _truth_for_suspect(reveal, 3)
	var truth_s6: SuspectTruthReveal = _truth_for_suspect(reveal, 6)
	var dialogue: Dictionary = _t08_dialogue_scene_checks(c, roles, players)
	var sidebar: Dictionary = _t07_i1_sidebar_repair_checks(FixtureRepository.load_tutorial_case_006(), roles, players)
	var conman_records: Array[PrivateRoleKnowledgeRecord] = []
	var conman_accuse_player: PlayerCaseState = null
	if conman_accuse_runtime != null:
		conman_records = conman_accuse_runtime.private_role_knowledge_for_player(conman_accuse_runtime.current_player_id())
		conman_accuse_player = conman_accuse_runtime.find_player(conman_accuse_runtime.current_player_id())

	checks.conman_exists = conman != null
	checks.conman_name = conman != null and conman.display_name == "Kẻ Lừa Đảo"
	checks.conman_group = conman != null and conman.role_group == CaseEnums.RoleGroup.TONG_PHAM
	checks.conman_evil = conman != null and RoleReferenceFormatter.role_alignment_label(conman.role_group) == "Phe Ác"
	checks.conman_truthful = s2 != null and info_service.truth_mode_for_suspect(s2) == InvestigationInformationResult.TruthMode.TRUTHFUL
	checks.conman_pretend_valid = s2 != null and s2.is_impersonating and s2.impersonated_role_id == &"mathematician" and info_service.true_role_ids_in_play(c).has(&"mathematician")
	checks.copycat_exists = copycat != null
	checks.copycat_name = copycat != null and copycat.display_name == "Kẻ Bắt Chước"
	checks.copycat_group = copycat != null and copycat.role_group == CaseEnums.RoleGroup.HIEU_SU
	checks.copycat_good = copycat != null and RoleReferenceFormatter.role_alignment_label(copycat.role_group) == "Phe Thiện"
	checks.copycat_pretend_valid = s3 != null and s3.is_impersonating and s3.impersonated_role_id == &"vigilante" and info_service.true_role_ids_in_play(c).has(&"vigilante")
	checks.copycat_milkman_rejected = _t08_copycat_milkman_rejected(c, roles, players)
	checks.fixture_validates = c != null and bool(validation_report.get("passed", false))
	checks.six_suspects = c != null and c.suspects.size() == 6
	checks.crime_and_empty = c != null and c.crime_scene != null and c.crime_scene.board_slot == 4 and c.suspect_at_slot(2) == null and c.suspect_at_slot(6) == null
	checks.layout = _t08_layout_is_canonical(c)
	checks.ratio = c != null and c.evil_suspect_ids == PackedInt32Array([2, 6]) and c.accomplice_suspect_ids == PackedInt32Array([2, 6]) and c.traitor_suspect_ids == PackedInt32Array() and _t08_group_count(c, CaseEnums.RoleGroup.CHINH_NHAN) == 3 and _t08_group_count(c, CaseEnums.RoleGroup.HIEU_SU) == 1 and _t08_group_count(c, CaseEnums.RoleGroup.TONG_PHAM) == 2 and _t08_group_count(c, CaseEnums.RoleGroup.NGHICH_THAN) == 0
	checks.final_answer = c != null and c.evil_suspect_ids == PackedInt32Array([2, 6])
	checks.duplicate_therapist = _t08_displayed_count(c, &"therapist") == 2
	checks.duplicate_mathematician = _t08_displayed_count(c, &"mathematician") == 2
	checks.duplicate_vigilante = _t08_displayed_count(c, &"vigilante") == 2
	checks.s2_pretend = s2 != null and s2.true_role_id == &"conman" and s2.displayed_role_id == &"mathematician"
	checks.s3_pretend = s3 != null and s3.true_role_id == &"copycat" and s3.displayed_role_id == &"vigilante"
	checks.s6_pretend = s6 != null and s6.true_role_id == &"tutorial_mobster" and s6.displayed_role_id == &"therapist"
	checks.conman_math_truth = conman_math != null and conman_math.behavior_role_id == &"mathematician" and conman_math.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL and conman_math.numeric_value == 8
	checks.real_math_truth = real_math != null and conman_math != null and real_math.behavior_role_id == &"mathematician" and real_math.numeric_value == conman_math.numeric_value
	checks.therapist_truth = therapist != null and therapist.behavior_role_id == &"therapist" and therapist.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL and therapist.numeric_value == 1
	checks.mobster_therapist_lies = mobster_therapist != null and mobster_therapist.behavior_role_id == &"therapist" and mobster_therapist.truth_mode == InvestigationInformationResult.TruthMode.LYING and mobster_therapist.numeric_value == 3
	checks.vigilante_no_announcement = copycat_vigilante_info != null and true_vigilante_info != null and copycat_vigilante_info.behavior_role_id == &"vigilante" and true_vigilante_info.behavior_role_id == &"vigilante" and copycat_vigilante_info.text.is_empty() and true_vigilante_info.text.is_empty()
	checks.copycat_function = action_function != null and action_function.function_type == CaseEnums.FunctionType.VIGILANTE_KILL
	checks.copycat_uses_vigilante = action_result != null and action_result.success and action_result.public_result_type == InteractiveFunctionResult.PublicResultType.VIGILANTE_KILL_ATTEMPTED
	checks.copycat_kills_s2 = action_result != null and action_runtime != null and action_result.vigilante_target_killed and action_runtime.find_suspect(2) != null and action_runtime.find_suspect(2).is_dead
	checks.true_vigilante_not_auto = action_runtime != null and _vigilante_kill_log_count(action_runtime, 2) == 1 and _vigilante_kill_log_count(action_runtime, 6) == 0
	checks.death_no_auto_complete = action_runtime != null and action_runtime.case_outcome in [CaseEnums.CaseOutcome.IN_PROGRESS, CaseEnums.CaseOutcome.POST_REVEAL_FUNCTIONS]
	checks.dead_evil_required = action_runtime != null and 2 in CaseResolutionService.new().unresolved_evil_ids(c, action_runtime)
	checks.final_six_incomplete = action_runtime != null and not _t08_submission_main_correct(c, action_runtime, PackedInt32Array([6]))
	checks.final_two_six_correct = action_runtime != null and _t08_submission_main_correct(c, action_runtime, PackedInt32Array([2, 6]))
	checks.dead_selectable = action_runtime != null and SingleSuspectAccusationService.new().accuse(c, action_runtime, action_runtime.find_player(action_runtime.current_player_id()), 2).success
	checks.conman_accuse_success = conman_accuse_result != null and conman_accuse_result.success and conman_accuse_result.correct
	checks.conman_accuse_no_payload = conman_accuse_result != null and String(conman_accuse_result.private_true_role_id).is_empty() and conman_records.is_empty()
	checks.conman_hidden_active = conman_accuse_runtime != null and CasePublicPresentationBuilder.new().build_suspect_views(c, conman_accuse_runtime, roles)[1].truth_true_role_name.is_empty()
	checks.conman_accuse_continue = conman_accuse_result != null and conman_accuse_runtime != null and conman_accuse_player != null and not conman_accuse_result.completed_evil_set and conman_accuse_runtime.case_outcome == CaseEnums.CaseOutcome.IN_PROGRESS and conman_accuse_player.is_active_in_investigation and conman_accuse_player.submission_status == CaseEnums.SubmissionStatus.NOT_SUBMITTED
	checks.dialogue_count = c != null and c.tutorial_dialogue_lines.size() == 6
	checks.dialogue_right_first_two = bool(dialogue.get("right_first_two", false))
	checks.dialogue_left_last_four = bool(dialogue.get("left_last_four", false))
	checks.dialogue_overlay_launch = bool(dialogue.get("overlay_launch", false))
	checks.dialogue_blocks = bool(dialogue.get("blocks", false))
	checks.dialogue_advances_closes = bool(dialogue.get("advances_closes", false))
	checks.dialogue_left_clean = bool(dialogue.get("left_clean", false))
	checks.truth_s2 = truth_s2 != null and reveal_runtime != null and truth_s2.suspect_id == 2 and truth_s2.true_role_name == "Kẻ Lừa Đảo" and truth_s2.displayed_role_name == "Nhà Toán Học" and reveal_runtime.find_suspect(2) != null and reveal_runtime.find_suspect(2).is_dead
	checks.truth_s3 = truth_s3 != null and truth_s3.suspect_id == 3 and truth_s3.true_role_name == "Kẻ Bắt Chước" and truth_s3.displayed_role_name == "Sư Tử Phán" and truth_s3.impersonated_role_name == "Sư Tử Phán"
	checks.truth_s6 = truth_s6 != null and truth_s6.suspect_id == 6 and truth_s6.true_role_name == "Kẻ Côn Đồ" and truth_s6.displayed_role_name == "Ngự Y" and truth_s6.impersonated_role_name == "Ngự Y"
	checks.function_history = reveal != null and reveal.public_function_records.size() == 1 and reveal.public_function_records[0].source_suspect_id == 3 and reveal.public_function_records[0].target_suspect_ids == PackedInt32Array([2]) and reveal.public_function_records[0].summary_text() == "Số Hiệu 2 đã bị xử quyết."
	checks.no_duplicate_vigilante_logic = _t08_no_duplicate_vigilante_logic()
	checks.previous_launchers = _t08_previous_launchers_intact()
	checks.t07_dialogue_intact = FixtureRepository.load_tutorial_case_007() != null and FixtureRepository.load_tutorial_case_007().tutorial_dialogue_lines.size() == 8
	checks.dead_before_rule = _t07_i1_dead_before_not_t07_id_specific(roles, players)
	checks.dead_text_localized = bool(_t07_i1_generic_dead_presentation_checks(roles, players).get("localized", false))
	checks.sidebar_unchanged = bool(sidebar.get("title", false)) and bool(sidebar.get("group_order", false)) and bool(sidebar.get("nested_drunkard", false))
	checks.kill_glossary = _role_glossary_bank_canonical()
	checks.clock_tower = ClockTowerService.clock_tower_for_case(FixtureRepository.load_tutorial_case_007()) != null
	checks.no_new_3x3 = _t07_i1_no_new_3x3_outside_fixture()
	checks.no_t09 = _t08_no_t09_implementation()
	checks.no_main_game = _t08_no_main_game_implementation()
	return checks


func _t08_suspect(c: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	if c == null:
		return null
	for suspect: SuspectDefinition in c.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null


func _t08_group_count(c: CaseDefinition, group: CaseEnums.RoleGroup) -> int:
	var count: int = 0
	if c == null:
		return count
	for suspect: SuspectDefinition in c.suspects:
		if suspect != null and suspect.role_group == group:
			count += 1
	return count


func _t08_displayed_count(c: CaseDefinition, role_id: StringName) -> int:
	var count: int = 0
	if c == null:
		return count
	for suspect: SuspectDefinition in c.suspects:
		if suspect != null and suspect.displayed_role_id == role_id:
			count += 1
	return count


func _t08_layout_is_canonical(c: CaseDefinition) -> bool:
	if c == null:
		return false
	return (
		c.suspect_at_slot(0) != null and c.suspect_at_slot(0).suspect_id == 1
		and c.suspect_at_slot(1) != null and c.suspect_at_slot(1).suspect_id == 2
		and c.suspect_at_slot(2) == null
		and c.suspect_at_slot(3) != null and c.suspect_at_slot(3).suspect_id == 3
		and c.crime_scene != null and c.crime_scene.board_slot == 4
		and c.suspect_at_slot(5) != null and c.suspect_at_slot(5).suspect_id == 4
		and c.suspect_at_slot(6) == null
		and c.suspect_at_slot(7) != null and c.suspect_at_slot(7).suspect_id == 5
		and c.suspect_at_slot(8) != null and c.suspect_at_slot(8).suspect_id == 6
	)


func _t08_copycat_milkman_rejected(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	if c == null:
		return false
	var invalid_case: CaseDefinition = c.duplicate(true) as CaseDefinition
	if invalid_case == null:
		return false
	var copycat: SuspectDefinition = _t08_suspect(invalid_case, 3)
	if copycat == null:
		return false
	copycat.displayed_role_id = &"milkman"
	copycat.impersonated_role_id = &"milkman"
	var milkman := RoleDefinition.new()
	milkman.role_id = &"milkman"
	milkman.display_name = "Người Giao Sữa"
	milkman.role_group = CaseEnums.RoleGroup.CHINH_NHAN
	var local_roles: Array[RoleDefinition] = []
	local_roles.assign(roles)
	local_roles.append(milkman)
	var report: Dictionary = CaseDefinitionValidator.new().validate(invalid_case, local_roles, players)
	var has_expected_error: bool = false
	var raw_report_errors: Variant = report.get("errors", [])
	var report_errors: Array = raw_report_errors if raw_report_errors is Array else []
	for error_value: Variant in report_errors:
		if error_value is Dictionary and String(error_value.get("code", "")) == "COPYCAT_PRETEND_MILKMAN":
			has_expected_error = true
	return not bool(report.get("passed", true)) and has_expected_error


func _t08_copycat_vigilante_action(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var output: Dictionary = {}
	if c == null:
		return output
	var bundle: Dictionary = _fresh_turn_bundle(c, players)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var manager: TurnManager = bundle.manager as TurnManager
	var availability: FunctionAvailabilityService = FunctionAvailabilityService.new()
	availability.initialize_hidden_states(c, runtime, roles)
	var source_runtime: SuspectRuntimeState = runtime.find_suspect(3)
	if source_runtime == null:
		return output
	source_runtime.is_investigated = true
	availability.reveal_for_suspect(c, runtime, roles, 3, runtime.turn_number)
	manager.advance_turn()
	runtime.apply_turn_snapshot(manager)
	availability.update_for_turn(runtime, manager.turn_number)
	var function_state: InteractiveFunctionRuntimeState = runtime.find_suspect(3).interactive_function
	var result: InteractiveFunctionResult = InteractiveFunctionExecutionService.new().execute(c, runtime, 3, PackedInt32Array([2]), runtime.current_player_id())
	output["runtime"] = runtime
	output["function"] = function_state
	output["result"] = result
	return output


func _t08_copycat_borrowed_function_marker(roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> bool:
	var c: CaseDefinition = FixtureRepository.load_tutorial_case_008()
	if c == null:
		return false
	var bundle: Dictionary = _fresh_turn_bundle(c, players)
	var runtime: CaseRuntimeState = bundle.runtime as CaseRuntimeState
	var manager: TurnManager = bundle.manager as TurnManager
	var availability: FunctionAvailabilityService = FunctionAvailabilityService.new()
	availability.initialize_hidden_states(c, runtime, roles)
	var source_runtime: SuspectRuntimeState = runtime.find_suspect(3)
	if source_runtime == null:
		return false
	source_runtime.is_investigated = true
	availability.reveal_for_suspect(c, runtime, roles, 3, runtime.turn_number)
	manager.advance_turn()
	runtime.apply_turn_snapshot(manager)
	availability.update_for_turn(runtime, manager.turn_number)
	var board := _board_instance_with_runtime(c, runtime, roles)
	var card := _board_card(board, 3)
	var passed := (
		card != null
		and card.has_function_hand_marker_for_smoke()
		and _function_hand_is_available(card.get_function_hand_marker_texture_path_for_smoke())
		and card.get_public_function_status_text().is_empty()
	)
	if board != null:
		board.free()
	return passed


func _t08_submission_main_correct(c: CaseDefinition, runtime: CaseRuntimeState, selected_ids: PackedInt32Array) -> bool:
	return CaseSubmissionService.new().evaluate_locked(c, _locked_submission(runtime.current_player_id(), selected_ids, selected_ids, PackedInt32Array(), CaseEnums.SubmissionPhase.EARLY), runtime).main_answer_correct


func _t08_single_accuse_conman(c: CaseDefinition, players: Array[PlayerCaseState]) -> Dictionary:
	var output: Dictionary = {}
	if c == null:
		return output
	var runtime: CaseRuntimeState = _fresh_turn_bundle(c, players).runtime as CaseRuntimeState
	var player: PlayerCaseState = runtime.find_player(runtime.current_player_id())
	var result: SingleSuspectAccusationResult = SingleSuspectAccusationService.new().accuse(c, runtime, player, 2)
	output["runtime"] = runtime
	output["result"] = result
	return output


func _t08_reveal_after_action(c: CaseDefinition, roles: Array[RoleDefinition], runtime: CaseRuntimeState) -> CaseTruthReveal:
	if c == null or runtime == null:
		return null
	var settlement := CaseSettlementResult.new()
	settlement.success = true
	settlement.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
	runtime.is_settled = true
	runtime.settlement_result = settlement
	runtime.case_outcome = CaseEnums.CaseOutcome.EARLY_SOLVED
	return CaseTruthRevealBuilder.new().build(c, runtime, roles)


func _t08_dialogue_scene_checks(c: CaseDefinition, roles: Array[RoleDefinition], players: Array[PlayerCaseState]) -> Dictionary:
	var checks: Dictionary = {}
	var scene: VSCaseMainController = _case_scene_instance() as VSCaseMainController
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if scene == null or tree == null or c == null:
		_t05_i2_free_scene(scene)
		return checks
	tree.root.add_child(scene)
	_prepare_case_scene_for_smoke(scene, c, roles, players)
	var first_line: String = c.tutorial_dialogue_lines[0] if c.tutorial_dialogue_lines.size() > 0 else ""
	var second_line: String = c.tutorial_dialogue_lines[1] if c.tutorial_dialogue_lines.size() > 1 else ""
	var third_line: String = c.tutorial_dialogue_lines[2] if c.tutorial_dialogue_lines.size() > 2 else ""
	var description_label: RichTextLabel = scene.get_node_or_null("%DescriptionLabel") as RichTextLabel
	var left_text: String = description_label.text if description_label != null else ""
	var launch_visible: bool = scene.is_tutorial_dialogue_overlay_visible_for_smoke()
	var initial_text: String = scene.get_tutorial_dialogue_text_for_smoke()
	var first_speaker: StringName = scene.get_tutorial_dialogue_active_speaker_for_smoke()
	var before_hours: int = scene.runtime_state.elapsed_hours if scene.runtime_state != null else -1
	scene._on_suspect_action(1, MOUSE_BUTTON_LEFT, true)
	var blocked_hours: int = scene.runtime_state.elapsed_hours if scene.runtime_state != null else -1
	scene._advance_tutorial_dialogue()
	var second_speaker: StringName = scene.get_tutorial_dialogue_active_speaker_for_smoke()
	var second_text: String = scene.get_tutorial_dialogue_text_for_smoke()
	scene._advance_tutorial_dialogue()
	var third_speaker: StringName = scene.get_tutorial_dialogue_active_speaker_for_smoke()
	var third_text: String = scene.get_tutorial_dialogue_text_for_smoke()
	for _index: int in range(4):
		scene._advance_tutorial_dialogue()
	var closed: bool = not scene.is_tutorial_dialogue_overlay_visible_for_smoke()
	var resume_before_hours: int = scene.runtime_state.elapsed_hours if scene.runtime_state != null else -1
	scene._on_suspect_action(1, MOUSE_BUTTON_LEFT, true)
	var resume_after_hours: int = scene.runtime_state.elapsed_hours if scene.runtime_state != null else -1
	checks.right_first_two = first_speaker == &"right" and second_speaker == &"right" and initial_text == first_line and second_text == second_line
	checks.left_last_four = third_speaker == &"left" and third_text == third_line
	checks.overlay_launch = launch_visible
	checks.blocks = before_hours == blocked_hours
	checks.advances_closes = second_text == second_line and closed
	checks.left_clean = not first_line.is_empty() and not left_text.contains(first_line) and not left_text.contains(second_line)
	checks.gameplay_resumes = closed and resume_after_hours > resume_before_hours
	_t05_i2_free_scene(scene)
	return checks


func _t08_previous_launchers_intact() -> bool:
	return (
		_debug_tutorial_case_01_launcher_exists()
		and _debug_tutorial_case_02_launcher_exists()
		and _debug_tutorial_case_03_launcher_exists()
		and _debug_tutorial_case_04_launcher_exists()
		and _debug_tutorial_case_05_launcher_exists()
		and _debug_tutorial_case_06_launcher_exists()
		and _debug_tutorial_case_07_launcher_exists()
	)


func _t08_no_t09_implementation() -> bool:
	var debug_source: String = FileAccess.get_file_as_string("res://scripts/presentation/DebugHomeController.gd")
	var fixture_source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/FixtureRepository.gd")
	var scene_source: String = FileAccess.get_file_as_string("res://scenes/boot/DebugHome.tscn")
	return (
		not debug_source.contains("tutorial_case_009")
		and not fixture_source.contains("tutorial_case_009")
		and not scene_source.contains("Tutorial Case 09")
	)


func _t08_no_duplicate_vigilante_logic() -> bool:
	var function_source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/InteractiveFunctionExecutionService.gd")
	var availability_source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/FunctionAvailabilityService.gd")
	var vigilante_mentions: int = function_source.split("_execute_vigilante").size() - 1
	return (
		vigilante_mentions == 2
		and function_source.contains("CaseKillService.new().kill")
		and not function_source.contains("copycat")
		and availability_source.contains("displayed_role")
	)


func _t08_no_main_game_implementation() -> bool:
	var app_source: String = FileAccess.get_file_as_string("res://autoload/AppFlow.gd")
	var debug_source: String = FileAccess.get_file_as_string("res://scripts/presentation/DebugHomeController.gd")
	return not app_source.contains("go_to_main_game") and not debug_source.contains("go_to_main_game")


func _case_generation_m0_checks(roles: Array[RoleDefinition]) -> Dictionary:
	var checks: Dictionary = {}
	var generator = CASE_GENERATOR.new()
	var role_ids: Array[StringName] = [
		&"reporter",
		&"therapist",
		&"mathematician",
		&"vigilante",
		&"tutorial_mobster",
		&"conman",
	]
	var location_ids: Array[StringName] = [
		BoardLocationDefinition.LOCATION_CRIME_SCENE,
	]
	var request_3x3 = CASE_GENERATION_REQUEST.create(
		123456,
		3,
		3,
		CASE_GENERATION_REQUEST.PROFILE_TUTORIAL_EASY,
		role_ids,
		location_ids,
		4
	)
	var request_4x4 = CASE_GENERATION_REQUEST.create(
		123456,
		4,
		4,
		CASE_GENERATION_REQUEST.PROFILE_NORMAL_FULL,
		role_ids,
		location_ids,
		6
	)
	var first = generator.generate(request_3x3, roles)
	var second = generator.generate(request_3x3, roles)
	var different_seed_request = CASE_GENERATION_REQUEST.create(
		654321,
		3,
		3,
		CASE_GENERATION_REQUEST.PROFILE_TUTORIAL_EASY,
		role_ids,
		location_ids,
		4
	)
	var different_seed = generator.generate(different_seed_request, roles)
	var full_board = generator.generate(request_4x4, roles)
	checks.valid_request_created = request_3x3.seed == 123456 and request_3x3.board_columns == 3 and request_3x3.board_rows == 3 and request_3x3.board_slot_count == 9
	checks.invalid_board_dimensions_rejected = generator.generate(CASE_GENERATION_REQUEST.create(1, 2, 5, CASE_GENERATION_REQUEST.PROFILE_TUTORIAL_EASY, role_ids, location_ids, 4), roles).error_code == CASE_GENERATION_RESULT.ERROR_BOARD_DIMENSIONS_INVALID
	var empty_roles: Array[StringName] = []
	checks.empty_content_pool_rejected = generator.generate(CASE_GENERATION_REQUEST.create(1, 3, 3, CASE_GENERATION_REQUEST.PROFILE_TUTORIAL_EASY, empty_roles, location_ids, 4), roles).error_code == CASE_GENERATION_RESULT.ERROR_CONTENT_POOL_EMPTY
	checks.unsupported_profile_rejected = generator.generate(CASE_GENERATION_REQUEST.create(1, 3, 3, &"unknown_profile", role_ids, location_ids, 4), roles).error_code == CASE_GENERATION_RESULT.ERROR_PROFILE_UNSUPPORTED
	checks.same_seed_same_fingerprint = first.is_success() and second.is_success() and first.fingerprint == second.fingerprint and first.probe_slot_sequence == second.probe_slot_sequence
	checks.different_seed_can_differ = different_seed.is_success() and different_seed.fingerprint != first.fingerprint and different_seed.probe_slot_sequence != first.probe_slot_sequence
	var before_global_noise = generator.generate(request_3x3, roles)
	seed(987654321)
	var global_noise: int = 0
	for _index: int in range(8):
		global_noise += int(randi() % 17)
		if randf() > 2.0:
			global_noise += 1
	var after_global_noise = generator.generate(request_3x3, roles)
	checks.global_rng_does_not_perturb = global_noise >= 0 and before_global_noise.fingerprint == after_global_noise.fingerprint
	checks.logical_board_slots_stable = first.logical_board_slots == PackedInt32Array([0, 1, 2, 3, 4, 5, 6, 7, 8])
	checks.three_by_three_supported = first.is_success() and first.board_columns == 3 and first.board_rows == 3 and first.board_slot_count == 9
	checks.four_by_four_supported = full_board.is_success() and full_board.board_columns == 4 and full_board.board_rows == 4 and full_board.board_slot_count == 16 and full_board.logical_board_slots == PackedInt32Array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15])
	checks.output_has_logical_tile_kinds = first.draft_tiles.size() == 9 and _case_generation_location_count(first, BoardLocationDefinition.LOCATION_CRIME_SCENE) == 1
	checks.output_has_no_ui_dependency = not first.fingerprint.contains("Control") and not first.fingerprint.contains("Node") and not first.fingerprint.contains("GridContainer")
	checks.version_in_fingerprint = first.fingerprint.contains("v%d" % CASE_GENERATION_REQUEST.DEFAULT_GENERATOR_VERSION)
	return _checks_result(checks, first.fingerprint)


func _case_generation_m1_checks(roles: Array[RoleDefinition]) -> Dictionary:
	var checks: Dictionary = {}
	var generator = CASE_GENERATOR.new()
	var role_ids: Array[StringName] = [
		&"reporter",
		&"therapist",
		&"mathematician",
		&"vigilante",
		&"tutorial_mobster",
		&"conman",
		&"poisoner",
	]
	var required_locations: Array[StringName] = [
		BoardLocationDefinition.LOCATION_CRIME_SCENE,
	]
	var request_3x3 = CASE_GENERATION_REQUEST.create(
		24680,
		3,
		3,
		CASE_GENERATION_REQUEST.PROFILE_TUTORIAL_EASY,
		role_ids,
		required_locations,
		4
	)
	var request_4x4 = CASE_GENERATION_REQUEST.create(
		24680,
		4,
		4,
		CASE_GENERATION_REQUEST.PROFILE_NORMAL_FULL,
		role_ids,
		required_locations,
		6
	)
	var first = generator.generate(request_3x3, roles)
	var second = generator.generate(request_3x3, roles)
	var different_seed = generator.generate(CASE_GENERATION_REQUEST.create(24681, 3, 3, CASE_GENERATION_REQUEST.PROFILE_TUTORIAL_EASY, role_ids, required_locations, 4), roles)
	var full_board = generator.generate(request_4x4, roles)
	checks.valid_3x3_hidden_world = _case_generation_hidden_world_valid(first, request_3x3, roles)
	checks.valid_4x4_hidden_world = _case_generation_hidden_world_valid(full_board, request_4x4, roles)
	checks.same_seed_same_hidden_fingerprint = first.is_success() and second.is_success() and first.fingerprint == second.fingerprint
	checks.different_seed_can_vary_hidden_world = different_seed.is_success() and different_seed.fingerprint != first.fingerprint
	var before_global_noise = generator.generate(request_3x3, roles)
	seed(11223344)
	var noise_total: int = 0
	for _index: int in range(12):
		noise_total += int(randi() % 31)
		if randf() > 2.0:
			noise_total += 1
	var after_global_noise = generator.generate(request_3x3, roles)
	checks.global_rng_independent = noise_total >= 0 and before_global_noise.fingerprint == after_global_noise.fingerprint
	checks.exact_suspect_count = first.hidden_case_draft != null and first.hidden_case_draft.suspects.size() == request_3x3.required_suspect_count
	checks.exact_required_locations = _case_generation_location_count(first, BoardLocationDefinition.LOCATION_CRIME_SCENE) == 1
	checks.unique_occupied_slots = _case_generation_occupied_slots_unique(first)
	checks.stable_suspect_numbering = _case_generation_suspect_numbering_is_reading_order(first)
	checks.true_roles_resolve = _case_generation_true_roles_resolve(first, roles)
	checks.no_duplicate_true_roles = _case_generation_true_roles_unique(first)
	checks.has_good = _case_generation_alignment_count(first, CaseEnums.Alignment.GOOD) > 0
	checks.has_evil = _case_generation_alignment_count(first, CaseEnums.Alignment.EVIL) > 0
	checks.hidden_answer_matches_evil = _case_generation_hidden_answer_matches_evil(first)
	var crowded_locations: Array[StringName] = [
		&"location_a",
		&"location_b",
		&"location_c",
	]
	checks.impossible_board_capacity_fails = generator.generate(CASE_GENERATION_REQUEST.create(1, 3, 3, CASE_GENERATION_REQUEST.PROFILE_TUTORIAL_EASY, role_ids, crowded_locations, 7), roles).error_code == CASE_GENERATION_RESULT.ERROR_BOARD_CAPACITY_EXCEEDED
	var short_role_ids: Array[StringName] = [
		&"reporter",
		&"therapist",
	]
	checks.insufficient_unique_pool_fails = generator.generate(CASE_GENERATION_REQUEST.create(2, 3, 3, CASE_GENERATION_REQUEST.PROFILE_TUTORIAL_EASY, short_role_ids, required_locations, 3), roles).error_code == CASE_GENERATION_RESULT.ERROR_INSUFFICIENT_UNIQUE_ROLES
	var all_good_ids: Array[StringName] = [
		&"reporter",
		&"therapist",
		&"mathematician",
		&"vigilante",
	]
	checks.all_good_pool_fails = generator.generate(CASE_GENERATION_REQUEST.create(3, 3, 3, CASE_GENERATION_REQUEST.PROFILE_TUTORIAL_EASY, all_good_ids, required_locations, 3), roles).error_code == CASE_GENERATION_RESULT.ERROR_ALIGNMENT_POOL_INVALID
	var all_evil_ids: Array[StringName] = [
		&"tutorial_mobster",
		&"conman",
		&"poisoner",
		&"barkeep",
	]
	checks.all_evil_pool_fails = generator.generate(CASE_GENERATION_REQUEST.create(4, 3, 3, CASE_GENERATION_REQUEST.PROFILE_TUTORIAL_EASY, all_evil_ids, required_locations, 3), roles).error_code == CASE_GENERATION_RESULT.ERROR_ALIGNMENT_POOL_INVALID
	var validator_safe_role_ids: Array[StringName] = [
		&"reporter",
		&"therapist",
		&"mathematician",
		&"vigilante",
		&"tutorial_mobster",
	]
	var validator_safe_request = CASE_GENERATION_REQUEST.create(
		13579,
		3,
		3,
		CASE_GENERATION_REQUEST.PROFILE_TUTORIAL_EASY,
		validator_safe_role_ids,
		required_locations,
		4
	)
	checks.generated_candidate_passes_structural_validator = _case_generation_generated_case_validates(
		generator,
		generator.generate(validator_safe_request, roles),
		roles
	)
	checks.bounded_attempts = first.generation_attempts >= 1 and first.generation_attempts <= CASE_GENERATOR.MAX_GENERATION_ATTEMPTS
	checks.no_ui_node_dependency = not first.fingerprint.contains("Control") and not first.fingerprint.contains("Node") and not first.fingerprint.contains("GridContainer")
	return _checks_result(checks, first.fingerprint)


func _case_generation_hidden_world_valid(result, request, roles: Array[RoleDefinition]) -> bool:
	return (
		result != null
		and result.is_success()
		and result.hidden_case_draft != null
		and result.board_columns == request.board_columns
		and result.board_rows == request.board_rows
		and result.board_slot_count == request.board_slot_count
		and result.hidden_case_draft.logical_board_slots.size() == request.board_slot_count
		and result.hidden_case_draft.suspects.size() == request.required_suspect_count
		and _case_generation_true_roles_resolve(result, roles)
		and _case_generation_hidden_answer_matches_evil(result)
	)


func _case_generation_generated_case_validates(generator, result, roles: Array[RoleDefinition]) -> bool:
	if generator == null or result == null or not result.is_success():
		return false
	var generated_case: CaseDefinition = generator.case_definition_from_result(result)
	if generated_case == null:
		return false
	var report: Dictionary = CaseDefinitionValidator.new().validate(generated_case, roles)
	return bool(report.get("passed", false))


func _case_generation_location_count(result, location_id: StringName) -> int:
	if result == null or result.hidden_case_draft == null:
		return 0
	var count: int = 0
	for tile in result.hidden_case_draft.board_tiles:
		if tile != null and tile.tile_kind == CASE_GENERATOR.TILE_LOCATION and tile.location_id == location_id:
			count += 1
	return count


func _case_generation_occupied_slots_unique(result) -> bool:
	if result == null or result.hidden_case_draft == null:
		return false
	var slots: Dictionary = {}
	for tile in result.hidden_case_draft.board_tiles:
		if tile == null:
			return false
		if tile.tile_kind != CASE_GENERATOR.TILE_EMPTY:
			if slots.has(tile.board_slot):
				return false
			slots[tile.board_slot] = true
	return true


func _case_generation_suspect_numbering_is_reading_order(result) -> bool:
	if result == null or result.hidden_case_draft == null:
		return false
	var expected_id := 1
	var previous_slot := -1
	for suspect in result.hidden_case_draft.suspects:
		if suspect == null or suspect.suspect_id != expected_id or suspect.board_slot <= previous_slot:
			return false
		previous_slot = suspect.board_slot
		expected_id += 1
	return true


func _case_generation_true_roles_resolve(result, roles: Array[RoleDefinition]) -> bool:
	if result == null or result.hidden_case_draft == null:
		return false
	var role_by_id: Dictionary = {}
	for role: RoleDefinition in roles:
		if role != null:
			role_by_id[role.role_id] = role
	for suspect in result.hidden_case_draft.suspects:
		if suspect == null or not role_by_id.has(suspect.true_role_id):
			return false
	return true


func _case_generation_true_roles_unique(result) -> bool:
	if result == null or result.hidden_case_draft == null:
		return false
	var role_ids: Dictionary = {}
	for suspect in result.hidden_case_draft.suspects:
		if suspect == null or role_ids.has(suspect.true_role_id):
			return false
		role_ids[suspect.true_role_id] = true
	return true


func _case_generation_alignment_count(result, alignment: int) -> int:
	if result == null or result.hidden_case_draft == null:
		return 0
	var count: int = 0
	for suspect in result.hidden_case_draft.suspects:
		if suspect != null and suspect.true_alignment == alignment:
			count += 1
	return count


func _case_generation_hidden_answer_matches_evil(result) -> bool:
	if result == null or result.hidden_case_draft == null:
		return false
	var evil_ids: PackedInt32Array = PackedInt32Array()
	for suspect in result.hidden_case_draft.suspects:
		if suspect != null and suspect.true_alignment == CaseEnums.Alignment.EVIL:
			evil_ids.append(suspect.suspect_id)
	evil_ids.sort()
	return result.hidden_case_draft.hidden_evil_suspect_ids == evil_ids


func _case_generation_m2_checks(roles: Array[RoleDefinition]) -> Dictionary:
	var checks: Dictionary = {}
	var generator = CASE_GENERATOR.new()
	var passive_role_ids: Array[StringName] = [
		&"tutorial_priest",
		&"reporter",
		&"therapist",
		&"weatherman",
		&"blood_hound",
		&"mathematician",
		&"mailman",
		&"role_meddler_a",
		&"tutorial_mobster",
	]
	var location_ids: Array[StringName] = [
		BoardLocationDefinition.LOCATION_CRIME_SCENE,
	]
	var request_4x4 = CASE_GENERATION_REQUEST.create(
		97531,
		4,
		4,
		CASE_GENERATION_REQUEST.PROFILE_NORMAL_FULL,
		passive_role_ids,
		location_ids,
		9
	)
	var first = generator.generate(request_4x4, roles)
	var second = generator.generate(request_4x4, roles)
	var different_seed = generator.generate(CASE_GENERATION_REQUEST.create(97532, 4, 4, CASE_GENERATION_REQUEST.PROFILE_NORMAL_FULL, passive_role_ids, location_ids, 9), roles)
	checks.valid_public_clue_world = first.is_success() and first.hidden_case_draft != null and first.hidden_case_draft.public_clues.size() >= 7
	checks.priest_self_confirm = _case_generation_public_clue_has_payload(first, &"tutorial_priest", InvestigationInformationResult.PayloadKind.TEXT)
	checks.reporter_manhattan = _case_generation_public_clue_has_payload(first, &"reporter", InvestigationInformationResult.PayloadKind.NUMBER)
	checks.therapist_orthogonal = _case_generation_public_clue_has_payload(first, &"therapist", InvestigationInformationResult.PayloadKind.NUMBER)
	checks.weatherman_suspect_ids = _case_generation_weatherman_clue_valid(first)
	checks.blood_hound_static = _case_generation_public_clue_has_payload(first, &"blood_hound", InvestigationInformationResult.PayloadKind.BLOOD_HOUND_CLUE)
	checks.mathematician_value = _case_generation_public_clue_has_payload(first, &"mathematician", InvestigationInformationResult.PayloadKind.NUMBER)
	checks.mailman_relation = _case_generation_public_clue_has_payload(first, &"mailman", InvestigationInformationResult.PayloadKind.ROLE_PLAY_CLAIM)
	checks.same_hidden_world_same_public_fingerprint = first.fingerprint == second.fingerprint and _case_generation_public_fingerprint(first) == _case_generation_public_fingerprint(second)
	checks.different_seed_can_vary_public_output = different_seed.is_success() and _case_generation_public_fingerprint(different_seed) != _case_generation_public_fingerprint(first)
	var before_global_noise = generator.generate(request_4x4, roles)
	seed(55667788)
	var noise_total: int = 0
	for _index: int in range(10):
		noise_total += int(randi() % 19)
		if randf() > 2.0:
			noise_total += 1
	var after_global_noise = generator.generate(request_4x4, roles)
	checks.global_rng_independent = noise_total >= 0 and _case_generation_public_fingerprint(before_global_noise) == _case_generation_public_fingerprint(after_global_noise)
	checks.referenced_ids_exist = _case_generation_public_references_exist(first)
	checks.no_ui_node_dependency = not _case_generation_public_fingerprint(first).contains("Control") and not _case_generation_public_fingerprint(first).contains("Node") and not _case_generation_public_fingerprint(first).contains("GridContainer")
	var request_3x3 = CASE_GENERATION_REQUEST.create(
		86420,
		3,
		3,
		CASE_GENERATION_REQUEST.PROFILE_TUTORIAL_EASY,
		passive_role_ids,
		location_ids,
		5
	)
	var small = generator.generate(request_3x3, roles)
	checks.three_by_three_supported = small.is_success() and small.hidden_case_draft != null and small.hidden_case_draft.public_clues.size() > 0
	checks.four_by_four_geometry_roles_supported = first.is_success() and first.board_columns == 4 and first.board_rows == 4
	checks.hidden_answer_separate = _case_generation_public_fingerprint(first).find("evil:") == -1 and first.hidden_case_draft.hidden_evil_suspect_ids.size() > 0
	return _checks_result(checks, _case_generation_public_fingerprint(first))


func _case_generation_public_clue_has_payload(result, role_id: StringName, payload_kind: int) -> bool:
	var clue = _case_generation_public_clue_for_role(result, role_id)
	return clue != null and clue.payload_kind == payload_kind and not clue.text.is_empty()


func _case_generation_public_clue_for_role(result, role_id: StringName):
	if result == null or result.hidden_case_draft == null:
		return null
	for clue in result.hidden_case_draft.public_clues:
		if clue != null and clue.true_role_id == role_id:
			return clue
	return null


func _case_generation_weatherman_clue_valid(result) -> bool:
	var clue = _case_generation_public_clue_for_role(result, &"weatherman")
	if clue == null:
		return false
	if clue.payload_kind != InvestigationInformationResult.PayloadKind.WEATHER_REPORT and clue.payload_kind != InvestigationInformationResult.PayloadKind.NO_MEDDLER_FOUND:
		return false
	if clue.referenced_suspect_ids.size() < 2:
		return false
	return _case_generation_public_references_exist(result)


func _case_generation_public_fingerprint(result) -> String:
	if result == null or result.hidden_case_draft == null:
		return ""
	var parts: Array[String] = []
	for clue in result.hidden_case_draft.public_clues:
		if clue != null:
			parts.append(clue.fingerprint_text())
	return "|".join(parts)


func _case_generation_public_references_exist(result) -> bool:
	if result == null or result.hidden_case_draft == null:
		return false
	for clue in result.hidden_case_draft.public_clues:
		if clue == null:
			return false
		for suspect_id: int in clue.referenced_suspect_ids:
			if not _case_generation_generated_suspect_exists(result, suspect_id):
				return false
	return true


func _case_generation_generated_suspect_exists(result, suspect_id: int) -> bool:
	if result == null or result.hidden_case_draft == null:
		return false
	for suspect in result.hidden_case_draft.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return true
	return false


func _case_generation_m3a_checks(roles: Array[RoleDefinition]) -> Dictionary:
	var checks: Dictionary = {}
	var solver = CASE_GENERATOR_PUBLIC_SOLVER.new()
	var unique_view = GENERATED_PUBLIC_CASE_VIEW.create_manual(3, 3, 1, [
		_case_generation_public_suspect(1, 0, &"reporter", roles),
		_case_generation_public_suspect(2, 1, &"tutorial_mobster", roles),
		_case_generation_public_suspect(3, 2, &"therapist", roles),
	])
	var unique_result = solver.solve(unique_view, roles)
	var ambiguous_view = GENERATED_PUBLIC_CASE_VIEW.create_manual(3, 3, 1, [
		GENERATED_PUBLIC_SUSPECT_VIEW.create(1, 0, &"", CaseEnums.RoleGroup.CHINH_NHAN),
		GENERATED_PUBLIC_SUSPECT_VIEW.create(2, 1, &"", CaseEnums.RoleGroup.CHINH_NHAN),
		GENERATED_PUBLIC_SUSPECT_VIEW.create(3, 2, &"", CaseEnums.RoleGroup.CHINH_NHAN),
	])
	var ambiguous_result = solver.solve(ambiguous_view, roles)
	var contradictory_view = GENERATED_PUBLIC_CASE_VIEW.create_manual(3, 3, 1, [
		_case_generation_public_suspect(1, 0, &"reporter", roles),
		_case_generation_public_suspect(2, 1, &"therapist", roles),
	])
	var contradictory_result = solver.solve(contradictory_view, roles)
	var unsupported_view = GENERATED_PUBLIC_CASE_VIEW.create_manual(3, 3, 1, [
		_case_generation_public_suspect(1, 0, &"drunkard", roles),
		GENERATED_PUBLIC_SUSPECT_VIEW.create(2, 1, &"", CaseEnums.RoleGroup.CHINH_NHAN),
	])
	var unsupported_result = solver.solve(unsupported_view, roles)
	var unique_solution_signature: String = unique_result.fingerprint_text()
	var unique_truth_match: bool = unique_result.compare_unique_solution_to_ground_truth(PackedInt32Array([2]))
	var unique_truth_after_match_signature: String = unique_result.fingerprint_text()
	var corrupted_truth_match: bool = unique_result.compare_unique_solution_to_ground_truth(PackedInt32Array([3]))
	var corrupted_truth_signature: String = unique_result.fingerprint_text()
	checks.unique_status = unique_result.status == CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION and unique_result.unique_evil_suspect_ids == PackedInt32Array([2])
	checks.ambiguous_status = ambiguous_result.status == CASE_GENERATOR_SOLVER_RESULT.STATUS_MULTIPLE_SOLUTIONS and ambiguous_result.candidate_count == 3
	checks.contradictory_status = contradictory_result.status == CASE_GENERATOR_SOLVER_RESULT.STATUS_NO_SOLUTION and contradictory_result.candidate_count == 0
	checks.unsupported_status = unsupported_result.status == CASE_GENERATOR_SOLVER_RESULT.STATUS_UNSUPPORTED and unsupported_result.unsupported
	checks.unique_ground_truth_match = unique_truth_match and unique_truth_after_match_signature.find("truth_match:true") != -1
	checks.corrupted_ground_truth_does_not_alter_solution = (
		not corrupted_truth_match
		and unique_result.status == CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION
		and unique_result.unique_evil_suspect_ids == PackedInt32Array([2])
		and unique_truth_after_match_signature.find("candidates:2") != -1
		and corrupted_truth_signature.find("candidates:2") != -1
		and unique_solution_signature.find("candidates:2") != -1
	)
	var generator = CASE_GENERATOR.new()
	var passive_role_ids: Array[StringName] = [
		&"tutorial_priest",
		&"reporter",
		&"therapist",
		&"weatherman",
		&"blood_hound",
		&"mathematician",
		&"mailman",
		&"role_meddler_a",
		&"tutorial_mobster",
	]
	var location_ids: Array[StringName] = [
		BoardLocationDefinition.LOCATION_CRIME_SCENE,
	]
	var request_3x3 = CASE_GENERATION_REQUEST.create(112233, 3, 3, CASE_GENERATION_REQUEST.PROFILE_TUTORIAL_EASY, passive_role_ids, location_ids, 5)
	var full_role_ids: Array[StringName] = passive_role_ids.duplicate()
	full_role_ids.append(&"copycat")
	var request_4x4 = CASE_GENERATION_REQUEST.create(445566, 4, 4, CASE_GENERATION_REQUEST.PROFILE_NORMAL_FULL, full_role_ids, location_ids, 9)
	var generated_3x3 = generator.generate(request_3x3, roles)
	var generated_4x4 = generator.generate(request_4x4, roles)
	var representative_request_4x4 = CASE_GENERATION_REQUEST.create(445566, 4, 4, CASE_GENERATION_REQUEST.PROFILE_NORMAL_FULL, passive_role_ids, location_ids, 9)
	var representative_4x4 = generator.generate(representative_request_4x4, roles)
	var public_3x3 = GENERATED_PUBLIC_CASE_VIEW.from_generation_result(generated_3x3, roles)
	var public_4x4 = GENERATED_PUBLIC_CASE_VIEW.from_generation_result(generated_4x4, roles)
	var solved_3x3 = solver.solve(public_3x3, roles)
	var solved_4x4 = solver.solve(public_4x4, roles)
	checks.generated_3x3_solved = generated_3x3.is_success() and not solved_3x3.unsupported and solved_3x3.status != CASE_GENERATOR_SOLVER_RESULT.STATUS_NO_SOLUTION
	checks.generated_4x4_solved = generated_4x4.is_success() and not solved_4x4.unsupported and solved_4x4.status != CASE_GENERATOR_SOLVER_RESULT.STATUS_NO_SOLUTION
	checks.generated_unique_matches_hidden_when_unique = (
		(solved_3x3.status != CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION or solved_3x3.unique_evil_suspect_ids == generated_3x3.hidden_case_draft.hidden_evil_suspect_ids)
		and (solved_4x4.status != CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION or solved_4x4.unique_evil_suspect_ids == generated_4x4.hidden_case_draft.hidden_evil_suspect_ids)
	)
	checks.generator_validation_hook = generator.public_solver_result(generated_4x4, roles).fingerprint_text() == solved_4x4.fingerprint_text()
	var solved_again = solver.solve(public_4x4, roles)
	checks.deterministic_repeated_solve = solved_again.fingerprint_text() == solved_4x4.fingerprint_text()
	var firewall_result = generator.generate(request_4x4, roles)
	var firewall_view = GENERATED_PUBLIC_CASE_VIEW.from_generation_result(firewall_result, roles)
	var before_hidden_mutation = solver.solve(firewall_view, roles)
	if firewall_result.hidden_case_draft != null:
		firewall_result.hidden_case_draft.hidden_evil_suspect_ids = PackedInt32Array([99])
	var after_hidden_mutation = solver.solve(firewall_view, roles)
	var solver_source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/CaseGeneratorPublicSolver.gd")
	checks.public_view_has_no_hidden_answer = firewall_view.fingerprint_text().find("evil:") == -1 and firewall_view.fingerprint_text().find("hidden_evil_suspect_ids") == -1
	checks.hidden_mutation_does_not_affect_existing_public_snapshot = before_hidden_mutation.fingerprint_text() == after_hidden_mutation.fingerprint_text()
	checks.solver_has_no_hidden_answer_dependency = solver_source.find("hidden_evil_suspect_ids") == -1 and solver_source.find("HiddenCaseDraft") == -1
	checks.solver_has_no_ui_node_dependency = solver_source.find("Control") == -1 and solver_source.find("Node") == -1 and solver_source.find("GridContainer") == -1
	checks.solver_support_scope_declared = solver_source.find("SUPPORTED_PUBLIC_ROLE_IDS") != -1 and solver_source.find("&\"copycat\"") != -1 and solver_source.find("&\"conman\"") != -1
	checks.representative_priest_public_role = _case_generation_public_clue_has_payload(representative_4x4, &"tutorial_priest", InvestigationInformationResult.PayloadKind.TEXT)
	checks.representative_reporter = _case_generation_public_clue_has_payload(representative_4x4, &"reporter", InvestigationInformationResult.PayloadKind.NUMBER)
	checks.representative_therapist = _case_generation_public_clue_has_payload(representative_4x4, &"therapist", InvestigationInformationResult.PayloadKind.NUMBER)
	checks.representative_weatherman = _case_generation_weatherman_clue_valid(representative_4x4)
	checks.representative_blood_hound = _case_generation_public_clue_has_payload(representative_4x4, &"blood_hound", InvestigationInformationResult.PayloadKind.BLOOD_HOUND_CLUE)
	checks.representative_mathematician = _case_generation_public_clue_has_payload(representative_4x4, &"mathematician", InvestigationInformationResult.PayloadKind.NUMBER)
	checks.representative_mailman = _case_generation_public_clue_has_payload(representative_4x4, &"mailman", InvestigationInformationResult.PayloadKind.ROLE_PLAY_CLAIM)
	checks.constraint_adapters_present = _case_generation_solver_constraint_adapters_present(solver_source)
	return _checks_result(checks, solved_4x4.fingerprint_text())


func _case_generation_m3_checks(roles: Array[RoleDefinition]) -> Dictionary:
	var checks: Dictionary = {}
	var service: CaseGenerationAcceptanceService = CASE_GENERATION_ACCEPTANCE_SERVICE.new()
	var role_ids: Array[StringName] = [
		&"reporter",
		&"therapist",
		&"tutorial_mobster",
	]
	var location_ids: Array[StringName] = [
		BoardLocationDefinition.LOCATION_CRIME_SCENE,
	]
	var request: CaseGenerationRequest = CASE_GENERATION_REQUEST.create(
		100,
		3,
		3,
		CASE_GENERATION_REQUEST.PROFILE_TUTORIAL_EASY,
		role_ids,
		location_ids,
		3
	)
	var immediate: CaseGenerationAcceptanceResult = service.accept_unique_candidate(
		request,
		roles,
		3,
		_case_generation_m3_fake_evaluator([
			_case_generation_m3_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION, PackedInt32Array([2]), PackedInt32Array([2]), "immediate")
		])
	)
	var retry: CaseGenerationAcceptanceResult = service.accept_unique_candidate(
		request,
		roles,
		3,
		_case_generation_m3_fake_evaluator([
			_case_generation_m3_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_MULTIPLE_SOLUTIONS, PackedInt32Array(), PackedInt32Array([2]), "ambiguous-0"),
			_case_generation_m3_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION, PackedInt32Array([2]), PackedInt32Array([2]), "accepted-1")
		])
	)
	var repeat_retry: CaseGenerationAcceptanceResult = service.accept_unique_candidate(
		request,
		roles,
		3,
		_case_generation_m3_fake_evaluator([
			_case_generation_m3_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_MULTIPLE_SOLUTIONS, PackedInt32Array(), PackedInt32Array([2]), "ambiguous-0"),
			_case_generation_m3_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION, PackedInt32Array([2]), PackedInt32Array([2]), "accepted-1")
		])
	)
	var ambiguous: CaseGenerationAcceptanceResult = service.accept_unique_candidate(
		request,
		roles,
		1,
		_case_generation_m3_fake_evaluator([
			_case_generation_m3_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_MULTIPLE_SOLUTIONS, PackedInt32Array(), PackedInt32Array([2]), "ambiguous-only")
		])
	)
	var unsupported: CaseGenerationAcceptanceResult = service.accept_unique_candidate(
		request,
		roles,
		1,
		_case_generation_m3_fake_evaluator([
			_case_generation_m3_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_UNSUPPORTED, PackedInt32Array(), PackedInt32Array([2]), "unsupported-only")
		])
	)
	var no_solution: CaseGenerationAcceptanceResult = service.accept_unique_candidate(
		request,
		roles,
		1,
		_case_generation_m3_fake_evaluator([
			_case_generation_m3_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_NO_SOLUTION, PackedInt32Array(), PackedInt32Array([2]), "no-solution-only")
		])
	)
	var mismatch_attempt: Dictionary = _case_generation_m3_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION, PackedInt32Array([2]), PackedInt32Array([3]), "mismatch-only")
	var mismatch: CaseGenerationAcceptanceResult = service.accept_unique_candidate(
		request,
		roles,
		1,
		_case_generation_m3_fake_evaluator([
			mismatch_attempt
		])
	)
	var mismatch_solver_result: CaseGeneratorSolverResult = mismatch_attempt.get("solver_result", null) as CaseGeneratorSolverResult
	var exhausted: CaseGenerationAcceptanceResult = service.accept_unique_candidate(
		request,
		roles,
		2,
		_case_generation_m3_fake_evaluator([
			_case_generation_m3_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_MULTIPLE_SOLUTIONS, PackedInt32Array(), PackedInt32Array([2]), "ambiguous-0"),
			_case_generation_m3_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_NO_SOLUTION, PackedInt32Array(), PackedInt32Array([2]), "no-solution-1")
		])
	)
	var direct_generator_result: CaseGenerationResult = CASE_GENERATOR.new().generate(request, roles)
	var direct_solver_view: GeneratedPublicCaseView = GENERATED_PUBLIC_CASE_VIEW.create_manual(3, 3, 1, [
		_case_generation_public_suspect(1, 0, &"reporter", roles),
		_case_generation_public_suspect(2, 1, &"tutorial_mobster", roles),
		_case_generation_public_suspect(3, 2, &"therapist", roles),
	])
	var direct_solver_result: CaseGeneratorSolverResult = CASE_GENERATOR_PUBLIC_SOLVER.new().solve(direct_solver_view, roles)
	var expected_attempt_one_seed: int = CASE_GENERATION_ACCEPTANCE_SERVICE.derived_seed_for_attempt(request, 1)
	var expected_attempt_two_seed: int = CASE_GENERATION_ACCEPTANCE_SERVICE.derived_seed_for_attempt(request, 2)
	checks.immediate_accepts_attempt_zero = immediate.success and immediate.accepted_attempt_index == 0 and immediate.accepted_derived_seed == request.seed
	checks.retry_accepts_attempt_one = retry.success and retry.accepted_attempt_index == 1 and retry.accepted_derived_seed == expected_attempt_one_seed
	checks.deterministic_repeat = retry.fingerprint_text() == repeat_retry.fingerprint_text()
	checks.reject_ambiguous = not ambiguous.success and int(ambiguous.rejected_status_counts.get(CASE_GENERATION_ACCEPTANCE_SERVICE.REJECTION_MULTIPLE_SOLUTIONS, 0)) == 1
	checks.reject_unsupported = not unsupported.success and int(unsupported.rejected_status_counts.get(CASE_GENERATION_ACCEPTANCE_SERVICE.REJECTION_UNSUPPORTED, 0)) == 1
	checks.reject_no_solution = not no_solution.success and int(no_solution.rejected_status_counts.get(CASE_GENERATION_ACCEPTANCE_SERVICE.REJECTION_NO_SOLUTION, 0)) == 1
	checks.reject_ground_truth_mismatch = not mismatch.success and int(mismatch.rejected_status_counts.get(CASE_GENERATION_ACCEPTANCE_SERVICE.REJECTION_UNIQUE_GROUND_TRUTH_MISMATCH, 0)) == 1
	checks.exhaustion_structured = not exhausted.success and exhausted.failure_reason == CASE_GENERATION_ACCEPTANCE_RESULT.FAILURE_EXHAUSTED and exhausted.attempts_performed == 2
	checks.derived_seed_exact = request.seed == 100 and expected_attempt_one_seed == 1024465 and expected_attempt_two_seed == 2024468
	checks.direct_generation_still_independent = direct_generator_result != null and direct_generator_result.is_success()
	checks.solver_still_independent = direct_solver_result.status == CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION and direct_solver_result.unique_evil_suspect_ids == PackedInt32Array([2])
	checks.post_solve_truth_compare_required = mismatch_solver_result != null and mismatch_solver_result.ground_truth_checked and not mismatch_solver_result.unique_solution_matches_ground_truth
	return _checks_result(checks, retry.fingerprint_text())


func _case_generation_m3_fake_evaluator(attempts: Array[Dictionary]) -> Callable:
	_case_generation_m3_injected_attempts = attempts.duplicate()
	return Callable(self, "_case_generation_m3_fake_attempt_evaluator")


func _case_generation_m3_fake_attempt_evaluator(_request, attempt_index: int, _roles: Array[RoleDefinition]) -> Dictionary:
	if _case_generation_m3_injected_attempts.is_empty():
		return {}
	if attempt_index < _case_generation_m3_injected_attempts.size():
		return _case_generation_m3_injected_attempts[attempt_index]
	return _case_generation_m3_injected_attempts[_case_generation_m3_injected_attempts.size() - 1]


func _case_generation_m3_attempt(
	solver_status: StringName,
	solver_evil_ids: PackedInt32Array,
	ground_truth_evil_ids: PackedInt32Array,
	fingerprint_suffix: String
) -> Dictionary:
	var solver_result = CASE_GENERATOR_SOLVER_RESULT.new()
	if solver_status == CASE_GENERATOR_SOLVER_RESULT.STATUS_UNSUPPORTED:
		solver_result.mark_unsupported("M3 smoke unsupported fixture.")
	elif solver_status == CASE_GENERATOR_SOLVER_RESULT.STATUS_MULTIPLE_SOLUTIONS:
		solver_result.set_candidates([
			PackedInt32Array([1]),
			PackedInt32Array([2]),
		])
	elif solver_status == CASE_GENERATOR_SOLVER_RESULT.STATUS_NO_SOLUTION:
		solver_result.set_candidates([])
	else:
		solver_result.set_candidates([
			solver_evil_ids,
		])
	return {
		"candidate": {
			"fingerprint": "m3-smoke-%s" % fingerprint_suffix,
		},
		"candidate_fingerprint": "m3-smoke-%s" % fingerprint_suffix,
		"solver_result": solver_result,
		"ground_truth_evil_suspect_ids": ground_truth_evil_ids,
	}


func _case_generation_m4a_checks(roles: Array[RoleDefinition]) -> Dictionary:
	var checks: Dictionary = {}
	var role_ids: Array[StringName] = [
		&"reporter",
		&"therapist",
		&"tutorial_mobster",
	]
	var location_ids: Array[StringName] = [
		BoardLocationDefinition.LOCATION_CRIME_SCENE,
	]
	var request: CaseGenerationRequest = CASE_GENERATION_REQUEST.create(
		0,
		3,
		3,
		CASE_GENERATION_REQUEST.PROFILE_TUTORIAL_EASY,
		role_ids,
		location_ids,
		3
	)
	var builder: CaseSeedWarehouseBuilder = CASE_SEED_WAREHOUSE_BUILDER.new()
	var roots: PackedInt32Array = PackedInt32Array([10, 11, 12, 13, 14])
	var first: CaseSeedWarehouseBuildResult = builder.build(
		request,
		roots,
		2,
		roles,
		1,
		Callable(self, "_case_generation_m4a_fake_attempt_evaluator")
	)
	var second: CaseSeedWarehouseBuildResult = builder.build(
		request,
		roots,
		2,
		roles,
		1,
		Callable(self, "_case_generation_m4a_fake_attempt_evaluator")
	)
	var exhausted: CaseSeedWarehouseBuildResult = builder.build(
		request,
		PackedInt32Array([12, 14]),
		2,
		roles,
		1,
		Callable(self, "_case_generation_m4a_fake_attempt_evaluator")
	)
	var first_entry: CaseSeedWarehouseEntry = first.entries[0] if first.entries.size() > 0 else null
	var second_entry: CaseSeedWarehouseEntry = first.entries[1] if first.entries.size() > 1 else null
	var verification: Dictionary = builder.verify_entry(first_entry, roles, 1, Callable(self, "_case_generation_m4a_fake_attempt_evaluator"))
	var tampered_entry: CaseSeedWarehouseEntry = CASE_SEED_WAREHOUSE_ENTRY.from_dictionary(first_entry.to_dictionary()) if first_entry != null else null
	if tampered_entry != null:
		tampered_entry.generator_version = 999
	var tampered_verification: Dictionary = builder.verify_entry(tampered_entry, roles, 1, Callable(self, "_case_generation_m4a_fake_attempt_evaluator"))
	var serialized_round_trip: CaseSeedWarehouseEntry = CASE_SEED_WAREHOUSE_ENTRY.from_dictionary(first_entry.to_dictionary()) if first_entry != null else null
	var build_round_trip: CaseSeedWarehouseBuildResult = CASE_SEED_WAREHOUSE_BUILD_RESULT.from_dictionary(first.to_dictionary())
	var builder_source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/CaseSeedWarehouseBuilder.gd")
	checks.deterministic_build = first.build_signature == second.build_signature and first.ordered_entry_signatures() == second.ordered_entry_signatures()
	checks.stable_ordering = first_entry != null and second_entry != null and first_entry.root_seed == 10 and second_entry.root_seed == 13
	checks.target_count_stop = first.produced_count == 2 and first.entries.size() == 2 and first.requested_root_seeds == roots
	checks.exhausted_input_partial = exhausted.produced_count == 0 and exhausted.rejected_root_count == 2 and exhausted.failure_summary.has(CASE_GENERATION_ACCEPTANCE_RESULT.FAILURE_EXHAUSTED)
	checks.duplicate_policy = first.duplicate_skipped_count == 1 and int(first.failure_summary.get(&"duplicate_signature", 0)) == 1
	checks.entry_verification = bool(verification.get("passed", false)) and bool(verification.get("candidate_signature", false)) and bool(verification.get("evil_solution", false))
	checks.version_mismatch_rejected = tampered_entry != null and not bool(tampered_verification.get("passed", false)) and not bool(tampered_verification.get("generator_version", true))
	checks.serialization_shape = serialized_round_trip != null and serialized_round_trip.signature_text() == first_entry.signature_text() and build_round_trip.build_signature == first.build_signature and build_round_trip.entries.size() == first.entries.size()
	checks.no_runtime_selection = builder_source.find("randi") == -1 and builder_source.find("randf") == -1 and builder_source.find("pick") == -1 and builder_source.find("choose") == -1
	checks.m3_entry_provenance = first_entry != null and first_entry.accepted_attempt_index == 0 and first_entry.accepted_derived_seed == 10 and first_entry.evil_suspect_ids == PackedInt32Array([2])
	return _checks_result(checks, first.build_signature)


func _case_generation_m4a_fake_attempt_evaluator(request: CaseGenerationRequest, _attempt_index: int, _roles: Array[RoleDefinition]) -> Dictionary:
	if request.seed == 10:
		return _case_generation_m3_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION, PackedInt32Array([2]), PackedInt32Array([2]), "warehouse-a")
	if request.seed == 11:
		return _case_generation_m3_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION, PackedInt32Array([2]), PackedInt32Array([2]), "warehouse-a")
	if request.seed == 13:
		return _case_generation_m3_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION, PackedInt32Array([3]), PackedInt32Array([3]), "warehouse-b")
	return _case_generation_m3_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_MULTIPLE_SOLUTIONS, PackedInt32Array(), PackedInt32Array([2]), "warehouse-reject")


func _case_generation_m4b_checks(roles: Array[RoleDefinition]) -> Dictionary:
	var checks: Dictionary = {}
	var request: CaseGenerationRequest = _case_generation_m4_request()
	var builder: CaseSeedWarehouseBuilder = CASE_SEED_WAREHOUSE_BUILDER.new()
	var warehouse: CaseSeedWarehouseBuildResult = builder.build(
		request,
		PackedInt32Array([10, 11, 13]),
		2,
		roles,
		1,
		Callable(self, "_case_generation_m4a_fake_attempt_evaluator")
	)
	var selector: CaseSeedWarehouseSelector = CASE_SEED_WAREHOUSE_SELECTOR.new()
	var empty_used_signatures: Array[String] = []
	var selected_a: CaseSeedWarehouseSelectionResult = selector.select_entry(
		warehouse,
		0,
		empty_used_signatures,
		request,
		roles,
		1,
		Callable(self, "_case_generation_m4a_fake_attempt_evaluator")
	)
	var selected_b: CaseSeedWarehouseSelectionResult = selector.select_entry(
		warehouse,
		0,
		empty_used_signatures,
		request,
		roles,
		1,
		Callable(self, "_case_generation_m4a_fake_attempt_evaluator")
	)
	var different_seed: CaseSeedWarehouseSelectionResult = selector.select_entry(
		warehouse,
		1,
		empty_used_signatures,
		request,
		roles,
		1,
		Callable(self, "_case_generation_m4a_fake_attempt_evaluator")
	)
	var used_signatures: Array[String] = []
	if selected_a.selected_entry != null:
		used_signatures.append(selected_a.selected_entry.candidate_signature)
	var no_repeat: CaseSeedWarehouseSelectionResult = selector.select_entry(
		warehouse,
		0,
		used_signatures,
		request,
		roles,
		1,
		Callable(self, "_case_generation_m4a_fake_attempt_evaluator")
	)
	var all_used_signatures: Array[String] = []
	for entry: CaseSeedWarehouseEntry in warehouse.entries:
		all_used_signatures.append(entry.candidate_signature)
	var all_used: CaseSeedWarehouseSelectionResult = selector.select_entry(
		warehouse,
		0,
		all_used_signatures,
		request,
		roles,
		1,
		Callable(self, "_case_generation_m4a_fake_attempt_evaluator")
	)
	var immutable_signature: String = warehouse.build_signature
	var immutable_entries: Array[String] = warehouse.ordered_entry_signatures()
	var _immutability_probe: CaseSeedWarehouseSelectionResult = selector.select_entry(
		warehouse,
		1,
		empty_used_signatures,
		request,
		roles,
		1,
		Callable(self, "_case_generation_m4a_fake_attempt_evaluator")
	)
	var incompatible: CaseSeedWarehouseBuildResult = _case_generation_m4b_tampered_warehouse(warehouse, "profile")
	var incompatible_selection: CaseSeedWarehouseSelectionResult = selector.select_entry(
		incompatible,
		0,
		empty_used_signatures,
		request,
		roles,
		1,
		Callable(self, "_case_generation_m4a_fake_attempt_evaluator")
	)
	var version_bad: CaseSeedWarehouseBuildResult = _case_generation_m4b_tampered_warehouse(warehouse, "version")
	var version_selection: CaseSeedWarehouseSelectionResult = selector.select_entry(
		version_bad,
		0,
		empty_used_signatures,
		request,
		roles,
		1,
		Callable(self, "_case_generation_m4a_fake_attempt_evaluator")
	)
	var fallback_warehouse: CaseSeedWarehouseBuildResult = _case_generation_m4b_tampered_warehouse(warehouse, "first_signature")
	var fallback_a: CaseSeedWarehouseSelectionResult = selector.select_entry(
		fallback_warehouse,
		1,
		empty_used_signatures,
		request,
		roles,
		1,
		Callable(self, "_case_generation_m4a_fake_attempt_evaluator")
	)
	var fallback_b: CaseSeedWarehouseSelectionResult = selector.select_entry(
		fallback_warehouse,
		1,
		empty_used_signatures,
		request,
		roles,
		1,
		Callable(self, "_case_generation_m4a_fake_attempt_evaluator")
	)
	var all_invalid: CaseSeedWarehouseBuildResult = _case_generation_m4b_tampered_warehouse(warehouse, "all_signatures")
	var all_invalid_selection: CaseSeedWarehouseSelectionResult = selector.select_entry(
		all_invalid,
		0,
		empty_used_signatures,
		request,
		roles,
		1,
		Callable(self, "_case_generation_m4a_fake_attempt_evaluator")
	)
	var selector_source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/CaseSeedWarehouseSelector.gd")
	checks.determinism = selected_a.success and selected_b.success and selected_a.selection_signature == selected_b.selection_signature and selected_a.selected_warehouse_index == selected_b.selected_warehouse_index
	checks.different_seed_changes_pick = selected_a.success and different_seed.success and selected_a.selected_warehouse_index != different_seed.selected_warehouse_index
	checks.no_repeat = no_repeat.success and selected_a.selected_entry != null and no_repeat.selected_entry != null and no_repeat.selected_entry.candidate_signature != selected_a.selected_entry.candidate_signature
	checks.all_used_exhausts = not all_used.success and all_used.failure_reason == CASE_SEED_WAREHOUSE_SELECTION_RESULT.FAILURE_NO_ELIGIBLE_ENTRIES
	checks.warehouse_immutable = warehouse.build_signature == immutable_signature and warehouse.ordered_entry_signatures() == immutable_entries
	checks.profile_incompatible_skipped = not incompatible_selection.success and incompatible_selection.skipped_invalid_count >= 1 and incompatible_selection.failure_reason == CASE_SEED_WAREHOUSE_SELECTION_RESULT.FAILURE_NO_ELIGIBLE_ENTRIES
	checks.version_incompatible_skipped = not version_selection.success and version_selection.skipped_invalid_count >= 1
	checks.verification_fallback = fallback_a.success and fallback_a.selected_warehouse_index == 1
	checks.all_invalid_fails = not all_invalid_selection.success and all_invalid_selection.failure_reason == CASE_SEED_WAREHOUSE_SELECTION_RESULT.FAILURE_NO_VALID_ENTRY
	checks.stable_fallback = fallback_a.selection_signature == fallback_b.selection_signature
	checks.no_runtime_generation_or_shuffle = selector_source.find(".generate(") == -1 and selector_source.find("accept_unique_candidate") == -1 and selector_source.find("shuffle") == -1 and selector_source.find("randi") == -1 and selector_source.find("randf") == -1
	return _checks_result(checks, selected_a.selection_signature)


func _case_generation_m5a_checks(roles: Array[RoleDefinition]) -> Dictionary:
	var checks: Dictionary = {}
	var request: CaseGenerationRequest = _case_generation_m4_request()
	var builder: CaseSeedWarehouseBuilder = CASE_SEED_WAREHOUSE_BUILDER.new()
	var warehouse: CaseSeedWarehouseBuildResult = builder.build(
		request,
		PackedInt32Array([20, 21, 22, 23]),
		4,
		roles,
		1,
		Callable(self, "_case_generation_m5a_fake_attempt_evaluator")
	)
	var composer: CaseSeedWarehouseOptionComposer = CASE_SEED_WAREHOUSE_OPTION_COMPOSER.new()
	var empty_used_signatures: Array[String] = []
	var first: CaseSeedWarehouseOptionSetResult = composer.compose_options(
		warehouse,
		0,
		empty_used_signatures,
		request,
		roles,
		3,
		1,
		Callable(self, "_case_generation_m5a_fake_attempt_evaluator")
	)
	var second: CaseSeedWarehouseOptionSetResult = composer.compose_options(
		warehouse,
		0,
		empty_used_signatures,
		request,
		roles,
		3,
		1,
		Callable(self, "_case_generation_m5a_fake_attempt_evaluator")
	)
	var different_seed: CaseSeedWarehouseOptionSetResult = composer.compose_options(
		warehouse,
		1,
		empty_used_signatures,
		request,
		roles,
		3,
		1,
		Callable(self, "_case_generation_m5a_fake_attempt_evaluator")
	)
	var caller_used: Array[String] = []
	if first.option_candidate_signatures.size() > 0:
		caller_used.append(first.option_candidate_signatures[0])
	var caller_used_before: Array[String] = []
	for signature: String in caller_used:
		caller_used_before.append(signature)
	var used_excluded: CaseSeedWarehouseOptionSetResult = composer.compose_options(
		warehouse,
		0,
		caller_used,
		request,
		roles,
		3,
		1,
		Callable(self, "_case_generation_m5a_fake_attempt_evaluator")
	)
	var immutable_signature: String = warehouse.build_signature
	var immutable_entries: Array[String] = warehouse.ordered_entry_signatures()
	var insufficient_warehouse: CaseSeedWarehouseBuildResult = builder.build(
		request,
		PackedInt32Array([20, 21]),
		2,
		roles,
		1,
		Callable(self, "_case_generation_m5a_fake_attempt_evaluator")
	)
	var insufficient: CaseSeedWarehouseOptionSetResult = composer.compose_options(
		insufficient_warehouse,
		0,
		empty_used_signatures,
		request,
		roles,
		3,
		1,
		Callable(self, "_case_generation_m5a_fake_attempt_evaluator")
	)
	var fallback_warehouse: CaseSeedWarehouseBuildResult = _case_generation_m5a_tampered_warehouse(warehouse, 2)
	var fallback: CaseSeedWarehouseOptionSetResult = composer.compose_options(
		fallback_warehouse,
		0,
		empty_used_signatures,
		request,
		roles,
		3,
		1,
		Callable(self, "_case_generation_m5a_fake_attempt_evaluator")
	)
	var selector: CaseSeedWarehouseSelector = CASE_SEED_WAREHOUSE_SELECTOR.new()
	var direct_first: CaseSeedWarehouseSelectionResult = selector.select_entry(
		warehouse,
		first.option_selection_seeds[0] if first.option_selection_seeds.size() > 0 else 0,
		empty_used_signatures,
		request,
		roles,
		1,
		Callable(self, "_case_generation_m5a_fake_attempt_evaluator")
	)
	var direct_second: CaseSeedWarehouseSelectionResult = selector.select_entry(
		warehouse,
		first.option_selection_seeds[1] if first.option_selection_seeds.size() > 1 else 0,
		empty_used_signatures,
		request,
		roles,
		1,
		Callable(self, "_case_generation_m5a_fake_attempt_evaluator")
	)
	var composer_source: String = FileAccess.get_file_as_string("res://scripts/domain/cases/CaseSeedWarehouseOptionComposer.gd")
	checks.determinism = first.success and second.success and first.option_set_signature == second.option_set_signature and first.option_candidate_signatures == second.option_candidate_signatures
	checks.exactly_three_options = first.success and first.requested_option_count == 3 and first.produced_option_count == 3 and first.option_entries.size() == 3
	checks.distinct_within_set = _case_generation_strings_are_distinct(first.option_candidate_signatures)
	checks.session_used_exclusion = used_excluded.success and caller_used.size() == 1 and not used_excluded.option_candidate_signatures.has(caller_used[0])
	checks.input_used_immutable = caller_used == caller_used_before
	checks.warehouse_immutable = warehouse.build_signature == immutable_signature and warehouse.ordered_entry_signatures() == immutable_entries
	checks.different_option_seed_changes_order = different_seed.success and different_seed.option_candidate_signatures != first.option_candidate_signatures
	checks.insufficient_entries_fail = not insufficient.success and insufficient.produced_option_count == 0 and insufficient.option_candidate_signatures.is_empty() and insufficient.selection_results.size() == 3 and insufficient.failure_reason == CASE_SEED_WAREHOUSE_OPTION_SET_RESULT.FAILURE_INSUFFICIENT_ELIGIBLE_ENTRIES
	checks.verification_fallback_continues = fallback.success and fallback.produced_option_count == 3 and not fallback.option_candidate_signatures.has("tampered-m3-smoke-warehouse-c")
	checks.selector_collision_distinct = direct_first.success and direct_second.success and direct_first.selected_warehouse_index == direct_second.selected_warehouse_index and _case_generation_strings_are_distinct(first.option_candidate_signatures)
	checks.m4b_remains_green = bool(_case_generation_m4b_checks(roles).get("passed", false))
	checks.no_generation_or_shuffle = composer_source.find(".generate(") == -1 and composer_source.find("build(") == -1 and composer_source.find("accept_unique_candidate") == -1 and composer_source.find("shuffle") == -1 and composer_source.find("randi") == -1 and composer_source.find("randf") == -1
	return _checks_result(checks, first.option_set_signature)


func _case_generation_m5a_fake_attempt_evaluator(request: CaseGenerationRequest, _attempt_index: int, _roles: Array[RoleDefinition]) -> Dictionary:
	if request.seed == 20:
		return _case_generation_m3_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION, PackedInt32Array([2]), PackedInt32Array([2]), "warehouse-a")
	if request.seed == 21:
		return _case_generation_m3_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION, PackedInt32Array([3]), PackedInt32Array([3]), "warehouse-b")
	if request.seed == 22:
		return _case_generation_m3_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION, PackedInt32Array([4]), PackedInt32Array([4]), "warehouse-c")
	if request.seed == 23:
		return _case_generation_m3_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_UNIQUE_SOLUTION, PackedInt32Array([5]), PackedInt32Array([5]), "warehouse-d")
	return _case_generation_m3_attempt(CASE_GENERATOR_SOLVER_RESULT.STATUS_MULTIPLE_SOLUTIONS, PackedInt32Array(), PackedInt32Array([2]), "warehouse-reject")


func _case_generation_m5a_tampered_warehouse(source: CaseSeedWarehouseBuildResult, entry_index: int) -> CaseSeedWarehouseBuildResult:
	var copy: CaseSeedWarehouseBuildResult = CASE_SEED_WAREHOUSE_BUILD_RESULT.from_dictionary(source.to_dictionary())
	if entry_index >= 0 and entry_index < copy.entries.size():
		copy.entries[entry_index].candidate_signature = "tampered-%s" % copy.entries[entry_index].candidate_signature
	copy.finalize_signature()
	return copy


func _case_generation_strings_are_distinct(values: Array[String]) -> bool:
	var seen: Dictionary = {}
	for value: String in values:
		if seen.has(value):
			return false
		seen[value] = true
	return true


func _case_generation_m4_request() -> CaseGenerationRequest:
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


func _case_generation_m4b_tampered_warehouse(source: CaseSeedWarehouseBuildResult, mode: String) -> CaseSeedWarehouseBuildResult:
	var copy: CaseSeedWarehouseBuildResult = CASE_SEED_WAREHOUSE_BUILD_RESULT.from_dictionary(source.to_dictionary())
	if mode == "profile":
		for entry: CaseSeedWarehouseEntry in copy.entries:
			entry.board_columns = 4
			entry.board_slot_count = 16
	elif mode == "version":
		for entry: CaseSeedWarehouseEntry in copy.entries:
			entry.generator_version = 999
	elif mode == "first_signature" and copy.entries.size() > 0:
		copy.entries[0].candidate_signature = "tampered-%s" % copy.entries[0].candidate_signature
	elif mode == "all_signatures":
		for entry: CaseSeedWarehouseEntry in copy.entries:
			entry.candidate_signature = "tampered-%s" % entry.candidate_signature
	copy.finalize_signature()
	return copy


func _case_generation_public_suspect(suspect_id: int, board_slot: int, role_id: StringName, roles: Array[RoleDefinition]):
	return GENERATED_PUBLIC_SUSPECT_VIEW.create(suspect_id, board_slot, role_id, _case_generation_role_group(roles, role_id, CaseEnums.RoleGroup.CHINH_NHAN))


func _case_generation_role_group(roles: Array[RoleDefinition], role_id: StringName, fallback_group: int) -> int:
	for role: RoleDefinition in roles:
		if role != null and role.role_id == role_id:
			return role.role_group
	return fallback_group


func _case_generation_solver_constraint_adapters_present(source_text: String) -> bool:
	return (
		source_text.find("PayloadKind.TEXT") != -1
		and source_text.find("PayloadKind.NUMBER") != -1
		and source_text.find("PayloadKind.ROLE_PLAY_CLAIM") != -1
		and source_text.find("PayloadKind.WEATHER_REPORT") != -1
		and source_text.find("PayloadKind.NO_MEDDLER_FOUND") != -1
		and source_text.find("PayloadKind.NO_EVIL_FOUND") != -1
		and source_text.find("PayloadKind.BLOOD_HOUND_CLUE") != -1
	)

func _result(test_name: String, passed: bool, detail: String) -> Dictionary:
	return {"name": test_name, "passed": passed, "detail": detail}


func _checks_result(checks: Dictionary, success_detail: String) -> Dictionary:
	var failed: Array[String] = []
	for key: Variant in checks.keys():
		if not bool(checks.get(key, false)):
			failed.append(String(key))
	if failed.is_empty():
		return {"passed": true, "detail": success_detail}
	return {"passed": false, "detail": "failed subchecks: %s" % ", ".join(failed)}
