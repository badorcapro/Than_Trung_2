class_name CaseSelectionModalController
extends Control

## Presentation Controller for 1-of-3 Case Selection and Level Progression Bar.
## Provides tactile visual cards, star displays, and choice dispatching for Canvas 1920x1080.

signal case_chosen(case_option: Dictionary)
signal level_clicked(level_id: int)
signal modal_closed()

@onready var progression_container: HBoxContainer = %ProgressionContainer
@onready var total_stars_label: Label = %TotalStarsLabel
@onready var cards_container: HBoxContainer = %CardsContainer
@onready var title_label: Label = %TitleLabel
@onready var subtitle_label: Label = %SubtitleLabel
@onready var close_button: Button = %CloseButton

var _selection_manager: CaseSelectionManager
var _progression_manager: LevelProgressionManager


func _ready() -> void:
	if close_button != null and not close_button.pressed.is_connected(_on_close_pressed):
		close_button.pressed.connect(_on_close_pressed)


func setup(
	selection_mgr: CaseSelectionManager,
	progression_mgr: LevelProgressionManager
) -> void:
	_selection_manager = selection_mgr
	_progression_manager = progression_mgr
	refresh_view()


func refresh_view() -> void:
	_render_progression_bar()
	_render_case_options()


func _render_progression_bar() -> void:
	if progression_container == null or _progression_manager == null:
		return

	for child in progression_container.get_children():
		child.queue_free()

	if total_stars_label != null:
		total_stars_label.text = "Tổng số sao: %d ⭐" % _progression_manager.get_total_stars()

	var all_levels := _progression_manager.get_all_levels()
	for lvl in all_levels:
		var lvl_id: int = int(lvl.get("level_id", 1))
		var is_unlocked: bool = bool(lvl.get("is_unlocked", false))
		var stars: int = int(lvl.get("star_rating", 0))

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(80, 52)
		btn.disabled = not is_unlocked

		var star_str := ""
		if not is_unlocked:
			star_str = "🔒"
		elif stars == 0:
			star_str = "☆☆☆"
		elif stars == 1:
			star_str = "★☆☆"
		elif stars == 2:
			star_str = "★★☆"
		else:
			star_str = "★★★"

		btn.text = "Hồi %d\n%s" % [lvl_id, star_str]
		btn.pressed.connect(func() -> void:
			_on_level_button_pressed(lvl_id)
		)
		progression_container.add_child(btn)


func _render_case_options() -> void:
	if cards_container == null or _selection_manager == null:
		return

	for child in cards_container.get_children():
		child.queue_free()

	var options := _selection_manager.get_current_options()
	for opt in options:
		var opt_idx: int = int(opt.get("option_index", 0))
		var title: String = String(opt.get("title", "Kỳ Án"))
		var region: String = String(opt.get("region_name", "Hoàng Cung"))
		var diff: String = String(opt.get("difficulty", "Vừa"))
		var suspects: int = int(opt.get("suspect_count", 5))
		var evil: int = int(opt.get("evil_count", 1))
		var reward: int = int(opt.get("reputation_reward", 100))
		var desc: String = String(opt.get("description", ""))

		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(360, 480)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 14)
		panel.add_child(vbox)

		var header_lbl := Label.new()
		header_lbl.text = "HỒ SƠ %d: %s" % [opt_idx + 1, diff.to_upper()]
		header_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		header_lbl.add_theme_font_size_override("font_size", 14)
		header_lbl.add_theme_color_override("font_color", _difficulty_color(diff))
		vbox.add_child(header_lbl)

		var title_lbl := Label.new()
		title_lbl.text = title
		title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title_lbl.add_theme_font_size_override("font_size", 18)
		vbox.add_child(title_lbl)

		var region_lbl := Label.new()
		region_lbl.text = "Địa Bàn: %s" % region
		region_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		region_lbl.add_theme_font_size_override("font_size", 13)
		vbox.add_child(region_lbl)

		var info_box := VBoxContainer.new()
		info_box.add_theme_constant_override("separation", 6)
		vbox.add_child(info_box)

		var suspect_lbl := Label.new()
		suspect_lbl.text = "• Số lượng đối tượng: %d nghi phạm (%d phản trặc)" % [suspects, evil]
		suspect_lbl.add_theme_font_size_override("font_size", 13)
		info_box.add_child(suspect_lbl)

		var reward_lbl := Label.new()
		reward_lbl.text = "• Thưởng công danh: +%d điểm" % reward
		reward_lbl.add_theme_font_size_override("font_color", Color(0.96, 0.82, 0.35, 1.0))
		reward_lbl.add_theme_font_size_override("font_size", 13)
		info_box.add_child(reward_lbl)

		var desc_lbl := Label.new()
		desc_lbl.text = desc
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
		desc_lbl.add_theme_font_size_override("font_size", 12)
		desc_lbl.add_theme_color_override("font_color", Color(0.75, 0.78, 0.82, 0.9))
		vbox.add_child(desc_lbl)

		var select_btn := Button.new()
		select_btn.custom_minimum_size = Vector2(0, 48)
		select_btn.text = "THỤ LÝ KỲ ÁN NÀY"
		select_btn.pressed.connect(func() -> void:
			_on_case_button_pressed(opt_idx)
		)
		vbox.add_child(select_btn)

		cards_container.add_child(panel)


func _on_case_button_pressed(option_index: int) -> void:
	if _selection_manager == null:
		return
	var chosen := _selection_manager.select_option(option_index)
	if not chosen.is_empty():
		case_chosen.emit(chosen)


func _on_level_button_pressed(level_id: int) -> void:
	level_clicked.emit(level_id)


func _on_close_pressed() -> void:
	modal_closed.emit()
	visible = false


func _difficulty_color(diff: String) -> Color:
	match diff:
		CaseSelectionManager.DIFFICULTY_EASY:
			return Color(0.2, 0.75, 0.45, 1.0)
		CaseSelectionManager.DIFFICULTY_HARD:
			return Color(0.92, 0.32, 0.28, 1.0)
		_:
			return Color(0.95, 0.72, 0.25, 1.0)
