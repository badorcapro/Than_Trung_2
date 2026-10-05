extends Control

@onready var fixture_counts_label: Label = %FixtureCountsLabel
@onready var validation_status_label: Label = %ValidationStatusLabel
@onready var validation_details: RichTextLabel = %ValidationDetails

var characters: Array[CharacterDefinition] = []
var map_definition: LootMapDefinition
var equipment: Array[EquipmentInstance] = []
var players: Array[PlayerPhaseState] = []

func _ready() -> void:
	_reload_fixture()

func _on_reload_pressed() -> void:
	_reload_fixture()

func _on_validate_pressed() -> void:
	var report := LootFixtureValidator.new().validate(characters, map_definition, players)
	validation_status_label.text = "Validation: PASS" if report.is_valid else "Validation: FAIL"
	validation_details.text = "\n".join(report.formatted_lines())
	AppLogger.info("GĐ2-M1 validation %s" % ("PASS" if report.is_valid else "FAIL"))

func _on_round_trip_pressed() -> void:
	var serializer := Gd2StateSerializer.new()
	var all_pass := not players.is_empty()
	for player in players: all_pass = all_pass and serializer.round_trip_matches(player)
	validation_status_label.text = "Round-trip: PASS" if all_pass else "Round-trip: FAIL"
	validation_details.text = "All PlayerPhaseState snapshots preserve semantic equality and contain no Node/scene reference." if all_pass else "Round-trip mismatch. Send the recent log."

func _on_back_pressed() -> void:
	AppFlow.go_to_debug_home()

func _reload_fixture() -> void:
	characters = Gd2FixtureRepository.load_characters()
	map_definition = Gd2FixtureRepository.load_map()
	equipment = Gd2FixtureRepository.load_equipment()
	players = Gd2FixtureRepository.build_players()
	var node_count := 0 if map_definition == null else map_definition.nodes.size()
	fixture_counts_label.text = "Players: %d    Characters: %d    Map nodes: %d    Equipment instances: %d" % [players.size(), characters.size(), node_count, equipment.size()]
	validation_status_label.text = "Fixture reloaded — TEST_ONLY / PROTOTYPE / NOT_CANON_LOCKED"
	validation_details.text = "Ready. Run validation or round-trip test."
	AppLogger.info("GĐ2-M1 fixture loaded")
