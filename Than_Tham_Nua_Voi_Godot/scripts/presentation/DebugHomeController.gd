extends Control

@onready var build_label: Label = %BuildLabel
@onready var status_label: Label = %StatusLabel
@onready var notice_label: Label = %NoticeLabel
@onready var log_preview: RichTextLabel = %LogPreview
@onready var smoke_panel: PanelContainer = %SmokePanel
@onready var smoke_results: RichTextLabel = %SmokeResults
@onready var copy_failures_button: Button = %CopyFailuresButton

var _last_smoke_failure_text := ""


func _ready() -> void:
	build_label.text = "Build: %s" % AppVersion.summary()
	status_label.text = "Project initialized successfully"
	AppLogger.log_emitted.connect(_on_log_emitted)
	_refresh_log_preview()
	AppLogger.info("DebugHome loaded")


func _on_case_pressed() -> void:
	AppLogger.info("Opening Vertical Slice Kỳ Án")
	AppFlow.go_to_case_vertical_slice()


func _on_sample_case_4x4_pressed() -> void:
	AppLogger.info("Opening Sample 4×4 Case Board")
	AppFlow.go_to_sample_case_4x4_visual()


func _on_role_codex_pressed() -> void:
	AppLogger.info("Opening Sổ Vai Trò")
	AppFlow.go_to_role_codex()


func _on_tutorial_case_01_pressed() -> void:
	AppLogger.info("Opening Tutorial Case 01 — Deduction M0")
	AppFlow.go_to_tutorial_case_001()


func _on_tutorial_case_02_pressed() -> void:
	AppLogger.info("Opening Tutorial Case 02 — Deduction")
	AppFlow.go_to_tutorial_case_002()


func _on_tutorial_case_03_pressed() -> void:
	AppLogger.info("Opening Tutorial Case 03 — Deduction")
	AppFlow.go_to_tutorial_case_003()


func _on_tutorial_case_04_pressed() -> void:
	AppLogger.info("Opening Tutorial Case 04 — Active Ability")
	AppFlow.go_to_tutorial_case_004()


func _on_tutorial_case_05_pressed() -> void:
	AppLogger.info("Opening Tutorial Case 05 — Timed Roles")
	AppFlow.go_to_tutorial_case_005()


func _on_tutorial_case_06_pressed() -> void:
	AppLogger.info("Opening Tutorial Case 06 — Transform")
	AppFlow.go_to_tutorial_case_006()


func _on_tutorial_case_07_pressed() -> void:
	AppLogger.info("Opening Tutorial Case 07 — Dangerous Time")
	AppFlow.go_to_tutorial_case_007()


func _on_tutorial_case_08_pressed() -> void:
	AppLogger.info("Opening Tutorial Case 08 — Truthful Evil")
	AppFlow.go_to_tutorial_case_008()


func _on_hv1_disguise_clue_behavior_pressed() -> void:
	AppLogger.info("Opening HV1 — Disguise & Clue Behavior")
	AppFlow.go_to_hv1_disguise_clue_behavior()


func _on_hv2_active_disguise_pressed() -> void:
	AppLogger.info("Opening HV2 — Active Disguise")
	AppFlow.go_to_hv2_active_disguise()


func _on_hv3_timed_coexistence_pressed() -> void:
	AppLogger.info("Opening HV3 — Timed Coexistence")
	AppFlow.go_to_hv3_timed_coexistence()


func _on_hv4_critic_mailman_pressed() -> void:
	AppLogger.info("Opening HV4 — Critic & Mailman")
	AppFlow.go_to_hv4_critic_mailman()


func _on_hv5_mutation_visibility_pressed() -> void:
	AppLogger.info("Opening HV5 — Mutation & Visibility")
	AppFlow.go_to_hv5_mutation_visibility()


func _on_hv6_resolution_timed_safety_pressed() -> void:
	AppLogger.info("Opening HV6 — Resolution & Timed Safety")
	AppFlow.go_to_hv6_resolution_timed_safety()


func _on_player_menu_pressed() -> void:
	AppLogger.info("Returning to player-facing Main Menu")
	AppFlow.go_to_player_main_menu()


func _on_loot_pressed() -> void:
	AppLogger.info("Opening GĐ2-M1 Loot Foundation")
	AppFlow.go_to_loot_m1_foundation()


func _on_character_selection_pressed() -> void:
	AppLogger.info("Opening GĐ2-M2 Character Selection")
	AppFlow.go_to_gd2_m2_character_selection()


func _on_movement_pressed() -> void:
	AppLogger.info("Opening GĐ2-M3 Spawn + Movement debug fixture")
	AppFlow.go_to_gd2_m3_movement()


func _on_production_loot_map_pressed() -> void:
	AppLogger.info("Opening GĐ2-M0A Production Imperial Court Tabletop")
	AppFlow.go_to_production_loot_map_preview()


func _on_reward_item_pressed() -> void:
	AppLogger.info("Opening GĐ2-M4 Reward + Item debug fixture")
	AppFlow.go_to_gd2_m4_reward_item()


func _on_m5_pressed() -> void:
	AppLogger.info("Opening GĐ2-M5 Equipment Management + Gacha debug fixture")
	AppFlow.go_to_gd2_m5_equipment_management()


func _on_m6_pressed() -> void:
	AppLogger.info("Opening GĐ2-M6 Prototype B Full Flow")
	AppFlow.go_to_gd2_m6_prototype_b()


func _on_gd3_m2_pressed() -> void:
	AppLogger.info("Opening GĐ3-M2 Case to Loot Bridge")
	AppFlow.go_to_gd3_m2_case_loot_bridge()


func _on_gd3_m3_pressed() -> void:
	AppLogger.info("Opening GĐ3-M3 Integrated Case to Loot")
	AppFlow.go_to_gd3_m3_integrated_case_loot()


func _on_gd3_m4_pressed() -> void:
	AppLogger.info("Opening GĐ3-M4 Integrated Round Completion")
	AppFlow.go_to_gd3_m4_round_completion()


func _on_gd3_m5_pressed() -> void:
	AppLogger.info("Opening GĐ3-M5 Multi-Round Next Case Integration")
	AppFlow.go_to_gd3_m5_next_case_orchestration()


func _on_gd3_m6_pressed() -> void:
	AppLogger.info("Opening GĐ3-M6 Bounded Two-Round Completion")
	AppFlow.go_to_gd3_m6_two_round_completion()


func _on_smoke_pressed() -> void:
	smoke_panel.visible = true
	_run_smoke_tests()


func _on_validate_fixture_pressed() -> void:
	var validator := CaseDefinitionValidator.new()
	var report := validator.validate(
		FixtureRepository.load_case(),
		FixtureRepository.load_roles(),
		FixtureRepository.load_players()
	)
	if report.passed:
		_show_notice("Case Fixture: PASS")
		AppLogger.info("Case Fixture validation PASS")
	else:
		var codes: Array[String] = []
		for validation_error in report.errors:
			codes.append(validation_error.code)
		_show_notice("Case Fixture: FAIL — %s" % ", ".join(codes))
		AppLogger.error("Case Fixture validation FAIL: %s" % ", ".join(codes))


func _on_rerun_pressed() -> void:
	_run_smoke_tests()


func _on_close_smoke_pressed() -> void:
	smoke_panel.visible = false


func _on_copy_failures_pressed() -> void:
	if _last_smoke_failure_text.is_empty():
		DisplayServer.clipboard_set("ALL SMOKE TESTS PASSED.")
		_show_notice("Smoke failures: none.")
		return
	DisplayServer.clipboard_set(_last_smoke_failure_text)
	_show_notice("Smoke FAIL list copied to Clipboard.")


func _on_exit_pressed() -> void:
	AppLogger.info("Exit requested")
	get_tree().quit()


func _show_notice(message: String) -> void:
	notice_label.text = message
	AppLogger.warning(message)


func _run_smoke_tests() -> void:
	var runner := SmokeTestRunner.new()
	var report := runner.run_all()
	
	smoke_results.text = report.formatted_text
	_last_smoke_failure_text = _build_copyable_failure_summary(report)
	if copy_failures_button != null:
		copy_failures_button.disabled = report.failed == 0
	
	if report.failed == 0:
		AppLogger.info("Smoke tests PASS (%d/%d)" % [report.passed, report.total])
	else:
		AppLogger.error("Smoke tests FAIL (%d failed)\n%s" % [report.failed, _last_smoke_failure_text])
		DisplayServer.clipboard_set(_last_smoke_failure_text)
		_show_notice("Smoke FAIL: %d tests. Copied failures to Clipboard!" % report.failed)
		
	_refresh_log_preview()


func _build_copyable_failure_summary(report: Variant) -> String:
	if not ("failed" in report) or report.failed == 0:
		return "ALL SMOKE TESTS PASSED."
		
	var lines: Array[String] = []
	lines.append("FAILED SMOKE TESTS (%d/%d)" % [report.failed, report.total if "total" in report else 0])
	lines.append("==================")
	if "failure_text" in report and not String(report.failure_text).is_empty():
		lines.append(String(report.failure_text))
		return "\n".join(lines)
	
	var raw_text: String = String(report.formatted_text) if "formatted_text" in report else ""
	var regex := RegEx.new()
	regex.compile("\\[color=.*?\\]|\\[/color\\]")
	var clean_text := regex.sub(raw_text, "", true)
	
	for line in clean_text.split("\n"):
		var trimmed := line.strip_edges()
		if trimmed.begins_with("FAIL") or trimmed.begins_with("[FAIL]"):
			lines.append(trimmed)
			
	return "\n".join(lines)


func _on_log_emitted(_level: String, _message: String, _line: String) -> void:
	_refresh_log_preview()


func _refresh_log_preview() -> void:
	log_preview.text = "\n".join(AppLogger.recent_lines())
