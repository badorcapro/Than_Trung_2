extends Control

const HOUSE_REPOSITORY := preload(
	"res://scripts/application/houses/ProductionHouseRepository.gd"
)
const MAP_VIEW := preload(
	"res://scripts/presentation/player_facing/PlayerFacingLootMapView.gd"
)
const REWARD_SNAPSHOT_SERVICE := preload(
	"res://scripts/application/loot/RewardSnapshotService.gd"
)
const PRODUCTION_REWARD_REPO := preload(
	"res://scripts/application/loot/ProductionRewardRepository.gd"
)

@onready var map_view: MAP_VIEW = %ProductionMapView
@onready var active_player_label: Label = %ActivePlayerLabel
@onready var state_label: Label = %StateLabel
@onready var camera_label: Label = %CameraLabel
@onready var move_button: Button = %MoveButton
@onready var branch_buttons: HBoxContainer = %BranchButtons
@onready var debug_overlay: Control = %DebugOverlay

var map_definition: LootMapDefinition
var session := LootMovementSession.new()
var movement_service := LootMovementService.new()
var roll_source: MovementRollSource = SequenceMovementRollSource.new([1, 2, 1, 2, 1])
var _preview_snapshots: Array = []
var _debug_visible := false
var _selected_preview_branch: StringName = &""
var _windowed_size := Vector2i.ZERO
var _windowed_position := Vector2i.ZERO
var _windowed_geometry_captured := false


func _ready() -> void:
	map_definition = Gd2FixtureRepository.load_production_map()
	var snapshot_service := REWARD_SNAPSHOT_SERVICE.new()
	_preview_snapshots = snapshot_service.build_weighted_reward_snapshot(
		&"preview_round",
		map_definition,
		PRODUCTION_REWARD_REPO.load_rewards(),
		PRODUCTION_REWARD_REPO.load_tables(),
		SequenceRewardRollSource.new([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
	)
	if map_view != null:
		map_view.node_clicked.connect(_on_map_node_clicked)
	_build_preview_session()
	_apply_debug_visibility(false)
	_refresh()


func _process(_delta: float) -> void:
	if map_view != null and _debug_visible:
		camera_label.text = "Camera: %.0f, %.0f  ·  Rìa màn hình để di chuyển  ·  SPACE để tìm người chơi" % [
			map_view.camera_center().x, map_view.camera_center().y
		]


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event: InputEventKey = event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return
	match preview_hotkey_action(key_event.keycode):
		&"TOGGLE_DEBUG":
			_apply_debug_visibility(not _debug_visible)
			get_viewport().set_input_as_handled()
		&"TOGGLE_FULLSCREEN":
			_toggle_true_fullscreen()
			get_viewport().set_input_as_handled()
		&"ROLL_MOVE":
			_on_move_pressed()
			get_viewport().set_input_as_handled()


static func preview_hotkey_action(keycode: int) -> StringName:
	if keycode == KEY_F9:
		return &"TOGGLE_DEBUG"
	if keycode == KEY_F11:
		return &"TOGGLE_FULLSCREEN"
	if keycode == KEY_Z:
		return &"ROLL_MOVE"
	return &""


static func fullscreen_mode_after_toggle(current_mode: int) -> int:
	if current_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		return DisplayServer.WINDOW_MODE_WINDOWED
	return DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN


static func fullscreen_window_id() -> int:
	return DisplayServer.MAIN_WINDOW_ID


func _toggle_true_fullscreen() -> void:
	var main_window_id: int = fullscreen_window_id()
	var current_mode: int = DisplayServer.window_get_mode(main_window_id)
	var target_mode: int = fullscreen_mode_after_toggle(current_mode)
	_log_fullscreen_window_diagnostic(main_window_id, current_mode, target_mode)
	if target_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
			_windowed_size = DisplayServer.window_get_size(main_window_id)
			_windowed_position = DisplayServer.window_get_position(main_window_id)
			_windowed_geometry_captured = _windowed_size.x > 0 and _windowed_size.y > 0
		DisplayServer.window_set_mode(target_mode, main_window_id)
		call_deferred("_refresh_after_window_mode_change", false)
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED, main_window_id)
	call_deferred("_refresh_after_window_mode_change", true)


func _refresh_after_window_mode_change(restore_windowed_geometry: bool) -> void:
	var main_window_id: int = fullscreen_window_id()
	if restore_windowed_geometry and _windowed_geometry_captured:
		DisplayServer.window_set_size(_windowed_size, main_window_id)
		DisplayServer.window_set_position(_windowed_position, main_window_id)
	if map_view != null:
		map_view.refresh_viewport_geometry()


func _log_fullscreen_window_diagnostic(
	main_window_id: int, current_mode: int, target_mode: int
) -> void:
	var local_window: Window = get_window()
	var root_window: Window = get_tree().root
	var local_window_id: int = (
		local_window.get_window_id() if local_window != null
		else DisplayServer.INVALID_WINDOW_ID
	)
	var root_window_id: int = root_window.get_window_id()
	var local_window_mode: int = (
		DisplayServer.window_get_mode(local_window_id)
		if local_window_id != DisplayServer.INVALID_WINDOW_ID
		else -1
	)
	var target_mode_before: int = DisplayServer.window_get_mode(main_window_id)
	var child_windows: Array[Node] = root_window.find_children("*", "Window", true, false)
	var diagnostic: String = (
		(
			"M0A_FULLSCREEN_DIAG scene=%s local=%s local_id=%d root=%s root_id=%d "
			+ "main_id=%d local_is_main=%s child_windows=%d local_mode=%d "
			+ "main_mode=%d target_mode_before=%d requested_mode=%d"
		)
		% [
			name,
			local_window.name if local_window != null else "<null>",
			local_window_id,
			root_window.name,
			root_window_id,
			main_window_id,
			str(local_window_id == main_window_id and root_window_id == main_window_id),
			child_windows.size(),
			local_window_mode,
			current_mode,
			target_mode_before,
			target_mode,
		]
	)
	print(diagnostic)


func _build_preview_session() -> void:
	session.round_id = &"production_map_preview"
	for house: HouseDefinition in HOUSE_REPOSITORY.load_all():
		var player := LootMovementPlayerState.new()
		player.player_id = StringName("preview_%s" % String(house.house_id))
		player.origin_house_id = house.house_id
		player.current_node_id = StringName(
			map_definition.origin_spawn_by_house.get(house.house_id, &"")
		)
		# Preview-only values exercise movement without defining production Characters.
		player.speed_snapshot = 2
		player.stamina_snapshot = 3
		player.remaining_moves = 3
		session.ordered_player_ids.append(player.player_id)
		session.player_states.append(player)
	session.started = true


func _on_move_pressed() -> void:
	if session.pending_branch != null and session.pending_branch.active:
		return
	var chosen: StringName = _selected_preview_branch
	_selected_preview_branch = &""
	var _action: MovementActionResult = movement_service.roll_move(
		session, map_definition, roll_source, [], chosen, true
	)
	_refresh()


func _on_branch_chosen(chosen_branch_id: StringName) -> void:
	_selected_preview_branch = &""
	var _action: MovementActionResult = movement_service.continue_branch_move(
		session, map_definition, chosen_branch_id, []
	)
	_refresh()


func _on_next_player_pressed() -> void:
	movement_service.advance_without_movement(session)
	_refresh()


func _on_focus_pressed() -> void:
	map_view.focus_active_player()


func _on_back_pressed() -> void:
	AppFlow.go_to_debug_home()


func _apply_debug_visibility(visible: bool) -> void:
	_debug_visible = visible
	debug_overlay.visible = visible
	map_view.set_debug_labels_visible(visible)


func _on_map_node_clicked(node_id: StringName) -> void:
	if session.pending_branch != null and session.pending_branch.active:
		if session.pending_branch.available_branch_ids.has(node_id):
			_on_branch_chosen(node_id)
			return
	else:
		var current: LootMovementPlayerState = session.current_player()
		if current != null:
			var branches: Array[LootNodeDefinition] = movement_service.get_available_branches(
				map_definition, current.current_node_id
			)
			if _has_branch_node(branches, node_id):
				_selected_preview_branch = node_id
				_refresh()
				return


func _refresh() -> void:
	map_view.configure(map_definition, session, _preview_snapshots)
	if branch_buttons != null:
		for child: Node in branch_buttons.get_children():
			child.queue_free()

	var current: LootMovementPlayerState = session.current_player()
	if current == null:
		active_player_label.text = "Đã hoàn tất lượt xem trước"
		state_label.text = ""
		move_button.disabled = true
		map_view.set_selectable_branches([])
		return
	var house: HouseDefinition = HOUSE_REPOSITORY.find(current.origin_house_id)
	var house_name: String = (
		house.display_name if house != null else String(current.origin_house_id)
	)

	if session.pending_branch != null and session.pending_branch.active:
		active_player_label.text = "⚠️ %s: Gặp ngã rẽ tại %s (còn %d bước)" % [
			house_name,
			map_view.label_for_node(session.pending_branch.fork_node_id),
			session.pending_branch.remaining_steps,
		]
		state_label.text = "Hãy bấm ô cờ trên bản đồ hoặc chọn nút bên dưới để tiếp tục di chuyển."
		move_button.disabled = true
		map_view.set_selectable_branches(session.pending_branch.available_branch_ids)
		for branch_id: StringName in session.pending_branch.available_branch_ids:
			var btn := Button.new()
			btn.text = map_view.label_for_node(branch_id)
			btn.pressed.connect(func(): _on_branch_chosen(branch_id))
			branch_buttons.add_child(btn)
		return

	active_player_label.text = "Lượt hiện tại: %s" % house_name
	state_label.text = "Nút: %s  ·  Speed xem trước: %d  ·  Stamina còn lại: %d  ·  [Z] Đổ xúc xắc" % [
		current.current_node_id, current.speed_snapshot, current.remaining_moves
	]
	move_button.disabled = session.completed

	var branches: Array[LootNodeDefinition] = movement_service.get_available_branches(
		map_definition, current.current_node_id
	)
	if branches.size() > 1:
		var branch_ids: Array[StringName] = []
		for b: LootNodeDefinition in branches:
			branch_ids.append(b.node_id)
		map_view.set_selectable_branches(branch_ids)
		if _selected_preview_branch.is_empty() or not _has_branch_node(branches, _selected_preview_branch):
			_selected_preview_branch = branches[0].node_id
		for b: LootNodeDefinition in branches:
			var btn := Button.new()
			var is_sel: bool = b.node_id == _selected_preview_branch
			btn.text = ("👉 " if is_sel else "") + map_view.label_for_node(b.node_id)
			btn.pressed.connect(func():
				_selected_preview_branch = b.node_id
				_refresh()
			)
			branch_buttons.add_child(btn)
	else:
		map_view.set_selectable_branches([])


func _has_branch_node(branches: Array[LootNodeDefinition], node_id: StringName) -> bool:
	for b: LootNodeDefinition in branches:
		if b.node_id == node_id:
			return true
	return false
