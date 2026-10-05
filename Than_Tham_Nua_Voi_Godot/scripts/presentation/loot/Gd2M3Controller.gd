extends Control

@onready var phase_label: Label = %PhaseLabel
@onready var current_player_label: Label = %CurrentPlayerLabel
@onready var player_overview: RichTextLabel = %PlayerOverview
@onready var map_overview: RichTextLabel = %MapOverview
@onready var result_label: RichTextLabel = %ResultLabel
@onready var move_button: Button = %MoveButton
@onready var validation_label: Label = %ValidationLabel

var characters: Array[CharacterDefinition] = []
var map_definition: LootMapDefinition
var session: LootMovementSession
var service := LootMovementService.new()
var roll_source: MovementRollSource = SeededMovementRollSource.new()


func _ready() -> void:
	characters = Gd2FixtureRepository.load_selection_characters()
	map_definition = Gd2FixtureRepository.load_m3_map()
	var players: Array[PlayerPhaseState] = AppFlow.take_pending_m3_players()
	if players.is_empty():
		players = _build_debug_selection_snapshot(3)
	var houses: Array[StringName] = []
	for player: PlayerPhaseState in players:
		var character: CharacterDefinition = _find_character(player.character_id)
		if character != null and not houses.has(character.origin_house_id):
			houses.append(character.origin_house_id)
	var report: LootValidationReport = LootMovementMapValidator.new().validate(map_definition, houses)
	validation_label.text = "Validation: %s" % ("PASS" if report.is_valid else "FAIL — %s" % " | ".join(report.formatted_lines()))
	if report.is_valid:
		session = service.build_session_from_selection(players, characters, map_definition)
	_refresh()


func _on_move_pressed() -> void:
	var result: MovementActionResult = service.roll_move(session, map_definition, roll_source)
	if result != null:
		var path: Array[String] = []
		for node_id: StringName in result.traversed_node_ids:
			path.append(String(node_id))
		result_label.text = "Turn %d — %s\nRoll: %d\nPath: %s\nEnd: %s\nRemaining: %d%s" % [result.turn_number, result.player_id, result.roll_distance, " → ".join(path) if not path.is_empty() else "(empty)", result.end_node_id, result.remaining_moves_after, "\nEnd-of-path: action consumed" if result.truncated_by_end_of_path else ""]
	_refresh()


func _on_back_pressed() -> void:
	AppFlow.go_to_debug_home()


func _refresh() -> void:
	if session == null:
		phase_label.text = "Phase: BUILD_FAILED"
		move_button.disabled = true
		return
	var phase_name: Variant = LootMovementSession.Phase.keys()[session.phase]
	phase_label.text = "Phase: %s" % String(phase_name)
	var current: LootMovementPlayerState = session.current_player()
	current_player_label.text = "Movement complete" if session.completed else "%s's turn" % String(current.player_id)
	move_button.disabled = session.completed
	var player_lines: Array[String] = ["[b]Player | Character | Origin | Node | Speed | Moves[/b]"]
	for player: LootMovementPlayerState in session.player_states:
		player_lines.append("%s | %s | %s | %s | %d | %d" % [player.player_id, player.character_id, player.origin_house_id, player.current_node_id, player.speed_snapshot, player.remaining_moves])
	player_overview.text = "\n".join(player_lines)
	var occupancy: Dictionary = {}
	for player: LootMovementPlayerState in session.player_states:
		if not occupancy.has(player.current_node_id):
			occupancy[player.current_node_id] = []
		var occupants: Array = occupancy[player.current_node_id] as Array
		occupants.append(String(player.player_id))
		occupancy[player.current_node_id] = occupants
	var map_lines: Array[String] = ["[b]Debug occupancy (same-node allowed)[/b]"]
	for node: LootNodeDefinition in map_definition.nodes:
		var occupants_value: Variant = occupancy.get(node.node_id, [])
		var occupant_names: Array[String] = []
		if occupants_value is Array:
			occupant_names.assign(occupants_value)
		var neighbors: Array[String] = []
		for neighbor_id: StringName in node.outgoing_neighbor_ids:
			neighbors.append(String(neighbor_id))
		map_lines.append("%s → %s   [%s]" % [node.node_id, ", ".join(neighbors), ", ".join(occupant_names)])
	map_overview.text = "\n".join(map_lines)


func _build_debug_selection_snapshot(count: int) -> Array[PlayerPhaseState]:
	var players: Array[PlayerPhaseState] = []
	for index: int in range(count):
		var player := PlayerPhaseState.new()
		player.player_id = StringName("debug_player_%d" % (index + 1))
		player.seat_index = index
		player.character_id = characters[index].character_id
		player.phase_id = &"READY_FOR_LOOT_M3"
		players.append(player)
	return players


func _find_character(character_id: StringName) -> CharacterDefinition:
	for character: CharacterDefinition in characters:
		if character.character_id == character_id:
			return character
	return null
