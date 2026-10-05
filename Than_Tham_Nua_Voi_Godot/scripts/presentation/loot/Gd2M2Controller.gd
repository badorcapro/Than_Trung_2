extends Control

@onready var count_panel: PanelContainer = %CountPanel
@onready var player_count_option: OptionButton = %PlayerCountOption
@onready var selection_panel: PanelContainer = %SelectionPanel
@onready var current_player_label: Label = %CurrentPlayerLabel
@onready var character_grid: GridContainer = %CharacterGrid
@onready var character_details: RichTextLabel = %CharacterDetails
@onready var lock_button: Button = %LockButton
@onready var pass_device_panel: PanelContainer = %PassDevicePanel
@onready var pass_device_label: Label = %PassDeviceLabel
@onready var summary_panel: PanelContainer = %SummaryPanel
@onready var summary_text: RichTextLabel = %SummaryText
@onready var ready_panel: PanelContainer = %ReadyPanel
@onready var ready_summary: RichTextLabel = %ReadySummary
@onready var phase_label: Label = %PhaseLabel
@onready var validation_label: Label = %ValidationLabel

var characters: Array[CharacterDefinition] = []
var session: CharacterSelectionSession = CharacterSelectionSession.new()
var service: CharacterSelectionService = CharacterSelectionService.new()


func _ready() -> void:
	characters = Gd2FixtureRepository.load_selection_characters()
	for count: int in range(1, 5): player_count_option.add_item("%d player" % count, count)
	player_count_option.select(2)
	_build_character_buttons()
	_show_phase(CharacterSelectionSession.Phase.PLAYER_COUNT)
	_set_validation("Fixture: %d Characters — TEST_ONLY / PROTOTYPE / NOT_CANON_LOCKED" % characters.size(), true)


func _on_count_continue_pressed() -> void:
	var selected_count: int = player_count_option.get_selected_id()
	var report: LootValidationReport = service.configure_player_count(session, selected_count, true)
	_show_report(report)
	if report.is_valid:
		_show_phase(CharacterSelectionSession.Phase.SELECTING)
		_refresh_selection()


func _on_character_pressed(character_id: StringName) -> void:
	var report: LootValidationReport = service.select_character(session, character_id, characters)
	_show_report(report)
	if report.is_valid: _refresh_selection()


func _on_lock_pressed() -> void:
	var report: LootValidationReport = service.lock_current_selection(session, characters)
	_show_report(report)
	if not report.is_valid: return
	_show_phase(session.phase)
	if session.phase == CharacterSelectionSession.Phase.PASS_DEVICE:
		pass_device_label.text = "Đưa máy cho Player %d" % (session.current_seat_index + 1)
	elif session.phase == CharacterSelectionSession.Phase.SUMMARY:
		_refresh_summary()


func _on_pass_continue_pressed() -> void:
	var report: LootValidationReport = service.continue_after_pass_device(session)
	_show_report(report)
	if report.is_valid:
		_show_phase(CharacterSelectionSession.Phase.SELECTING)
		_refresh_selection()


func _on_edit_pressed() -> void:
	var seat_index: int = maxi(0, session.player_count - 1)
	var report: LootValidationReport = service.edit_seat(session, seat_index)
	_show_report(report)
	if report.is_valid:
		_show_phase(CharacterSelectionSession.Phase.SELECTING)
		_refresh_selection()


func _on_confirm_pressed() -> void:
	var report: LootValidationReport = service.finalize_selection(session, characters)
	_show_report(report)
	if not report.is_valid: return
	var serializer: Gd2StateSerializer = Gd2StateSerializer.new()
	var round_trip_passed: bool = serializer.players_round_trip_match(session.committed_players)
	_show_phase(CharacterSelectionSession.Phase.READY_FOR_LOOT_M3)
	ready_summary.text = "%s\n\nSnapshot: %d PlayerPhaseState\nRound-trip: %s\nCommit count: %d\n\nNo movement/reward/Equipment/Gacha runtime started." % [_summary_rows(), session.committed_players.size(), "PASS" if round_trip_passed else "FAIL", session.commit_count]
	_set_validation("Finalize + snapshot + round-trip: %s" % ("PASS" if round_trip_passed else "FAIL"), round_trip_passed)


func _on_back_pressed() -> void:
	AppFlow.go_to_debug_home()


func _on_continue_m3_pressed() -> void:
	AppFlow.go_to_gd2_m3_movement(session.committed_players)


func _build_character_buttons() -> void:
	for child: Node in character_grid.get_children(): child.queue_free()
	for character: CharacterDefinition in characters:
		var button: Button = Button.new()
		button.name = "Character_%s" % String(character.character_id)
		button.custom_minimum_size = Vector2(300, 112)
		button.text = "%s\nOrigin: %s | Speed %d | Stamina %d | Bag %d\nPassive: %s [TEST_ONLY]\nActive: %s | Orb %d [TEST_ONLY]" % [character.display_name, character.origin_house_id, character.base_speed, character.base_stamina, character.base_bag_level, character.passive_skill_id, character.active_skill_id, character.active_orb_requirement]
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.pressed.connect(_on_character_pressed.bind(character.character_id))
		character_grid.add_child(button)


func _refresh_selection() -> void:
	current_player_label.text = "Player %d selecting — %d/%d" % [session.current_seat_index + 1, session.current_seat_index + 1, session.player_count]
	var selected_id: StringName = session.selected_character_ids[session.current_seat_index]
	var character: CharacterDefinition = _find_character(selected_id)
	lock_button.disabled = character == null
	character_details.text = "Chọn một Character. Duplicate hiện được phép bởi fixture policy TEST_ONLY; đây không phải luật canon." if character == null else _character_details(character)


func _refresh_summary() -> void:
	summary_text.text = _summary_rows()


func _summary_rows() -> String:
	var lines: Array[String] = ["Player | Character | Origin | Speed | Stamina | Bag | Active Orb"]
	for seat_index: int in range(session.player_count):
		var character: CharacterDefinition = _find_character(session.selected_character_ids[seat_index])
		if character == null: continue
		lines.append("Player %d | %s | %s | %d | %d | %d | %d" % [seat_index + 1, character.display_name, character.origin_house_id, character.base_speed, character.base_stamina, character.base_bag_level, character.active_orb_requirement])
	return "\n".join(lines)


func _character_details(character: CharacterDefinition) -> String:
	return "[b]%s[/b]\nOrigin: %s\nBase preview — Speed %d | Stamina %d | Bag Lv %d\nPassive: %s — TEST_ONLY placeholder\nActive: %s — Orb requirement %d — TEST_ONLY placeholder" % [character.display_name, character.origin_house_id, character.base_speed, character.base_stamina, character.base_bag_level, character.passive_skill_id, character.active_skill_id, character.active_orb_requirement]


func _find_character(character_id: StringName) -> CharacterDefinition:
	for character: CharacterDefinition in characters:
		if character.character_id == character_id: return character
	return null


func _show_phase(next_phase: int) -> void:
	count_panel.visible = next_phase == CharacterSelectionSession.Phase.PLAYER_COUNT
	selection_panel.visible = next_phase == CharacterSelectionSession.Phase.SELECTING
	pass_device_panel.visible = next_phase == CharacterSelectionSession.Phase.PASS_DEVICE
	summary_panel.visible = next_phase == CharacterSelectionSession.Phase.SUMMARY
	ready_panel.visible = next_phase == CharacterSelectionSession.Phase.READY_FOR_LOOT_M3
	var phase_name_value: Variant = CharacterSelectionSession.Phase.keys()[next_phase]
	phase_label.text = "Phase: %s" % String(phase_name_value)


func _show_report(report: LootValidationReport) -> void:
	_set_validation("\n".join(report.formatted_lines()), report.is_valid)


func _set_validation(message: String, passed: bool) -> void:
	validation_label.text = ("PASS — " if passed else "FAIL — ") + message
