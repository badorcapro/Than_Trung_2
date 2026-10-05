class_name Gd2ProductionCharacterRosterTestSuite
extends RefCounted

const CHARACTER_REPOSITORY := preload(
	"res://scripts/application/characters/ProductionCharacterRepository.gd"
)
const HOUSE_REPOSITORY := preload(
	"res://scripts/application/houses/ProductionHouseRepository.gd"
)
const ROSTER_VALIDATOR := preload(
	"res://scripts/domain/characters/ProductionCharacterRosterValidator.gd"
)
const SETUP_SESSION := preload(
	"res://scripts/application/player_facing/PlayerFacingSetupSession.gd"
)
const MOVEMENT_SERVICE := preload(
	"res://scripts/application/loot/LootMovementService.gd"
)
const REWARD_SERVICE := preload(
	"res://scripts/application/loot/LootRewardService.gd"
)
const PLAYER_STATE := preload(
	"res://scripts/domain/characters/PlayerPhaseState.gd"
)
const REWARD_ROLL_SOURCE := preload(
	"res://scripts/infrastructure/SequenceRewardRollSource.gd"
)
const PLAYER_SCENE := "res://scenes/player_facing/PlayerFacingStart.tscn"


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var characters: Array[CharacterDefinition] = CHARACTER_REPOSITORY.load_all()
	var map_definition: LootMapDefinition = Gd2FixtureRepository.load_production_map()
	rows.append(_row("GĐ2 production roster contains exactly five Characters", characters.size() == 5))
	rows.append(_row("GĐ2 production Character IDs are canonical", _ids(characters) == _expected_ids()))
	rows.append(_row("GĐ2 production Character names are canonical", _names(characters) == _expected_names()))
	rows.append(_row("GĐ2 production Character Houses are canonical", _house_ids(characters) == _expected_house_ids()))
	rows.append(_row("GĐ2 production roster represents each canonical House once", _one_per_house(characters)))
	rows.append(_row("GĐ2 production Character IDs are unique", _all_unique(_ids(characters))))
	rows.append(_row("GĐ2 production Characters are not TEST_ONLY", _all_production(characters)))
	rows.append(_row("GĐ2 production Characters use neutral 2/2/2 stats", _neutral_stats(characters)))
	rows.append(_row("GĐ2 production Character skills remain deferred", _skills_are_deferred(characters)))
	rows.append(_row("GĐ2 production roster follows House display order", _order_matches_houses(characters)))
	rows.append(_row("GĐ2 production roster passes scoped validation", ROSTER_VALIDATOR.new().validate(characters).is_valid))
	rows.append(_row("PF normal setup loads production Characters", _setup_uses_production(characters)))
	rows.append(_row("PF Character presentation uses authoritative names", _presentation_names_match()))
	rows.append(_row("PF Character presentation uses authoritative House names", _presentation_houses_match()))
	rows.append(_row("PF duplicate production Character selection is rejected", _duplicate_selection_rejected()))
	rows.append(_row("PF five-candidate Character list remains structurally valid", _five_candidate_layout_is_valid()))
	rows.append(_row("GĐ2 production Characters resolve canonical House spawns", _spawns_match(characters, map_definition)))
	rows.append(_row("GĐ2 production Speed reaches movement runtime", _movement_stats_match(characters, map_definition, true)))
	rows.append(_row("GĐ2 production Stamina reaches round runtime", _movement_stats_match(characters, map_definition, false)))
	rows.append(_row("GĐ2 production Bag reaches round Loot capacity", _bag_capacity_matches(characters, map_definition)))
	rows.append(_row("GĐ2 legacy TEST Character roster remains unchanged", _legacy_fixtures_unchanged()))
	return rows


func _row(name: String, passed: bool) -> Dictionary:
	return {
		"name": name,
		"passed": passed,
		"detail": "GĐ2 production Character roster invariant",
	}


func _expected_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	result.append(&"character_hoang_linh_lam")
	result.append(&"character_chu_tue_nguyet")
	result.append(&"character_kim_thanh_giai")
	result.append(&"character_huyen_ca_xuy")
	result.append(&"character_lam_phuong_xuan")
	return result


func _expected_names() -> Array[String]:
	var result: Array[String] = []
	result.append("Hoàng Linh Lâm")
	result.append("Chu Tuệ Nguyệt")
	result.append("Kim Thanh Giai")
	result.append("Huyền Ca Xuý")
	result.append("Lam Phương Xuân")
	return result


func _expected_house_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	result.append(&"house_hoang")
	result.append(&"house_chu")
	result.append(&"house_kim")
	result.append(&"house_huyen")
	result.append(&"house_lam")
	return result


func _ids(characters: Array[CharacterDefinition]) -> Array[StringName]:
	var result: Array[StringName] = []
	for character: CharacterDefinition in characters:
		result.append(character.character_id)
	return result


func _names(characters: Array[CharacterDefinition]) -> Array[String]:
	var result: Array[String] = []
	for character: CharacterDefinition in characters:
		result.append(character.display_name)
	return result


func _house_ids(characters: Array[CharacterDefinition]) -> Array[StringName]:
	var result: Array[StringName] = []
	for character: CharacterDefinition in characters:
		result.append(character.origin_house_id)
	return result


func _all_unique(values: Array[StringName]) -> bool:
	var seen: Dictionary = {}
	for value: StringName in values:
		if value.is_empty() or seen.has(value):
			return false
		seen[value] = true
	return true


func _one_per_house(characters: Array[CharacterDefinition]) -> bool:
	return (
		_all_unique(_house_ids(characters))
		and _house_ids(characters) == _expected_house_ids()
	)


func _all_production(characters: Array[CharacterDefinition]) -> bool:
	for character: CharacterDefinition in characters:
		if character.test_only_not_canon_locked:
			return false
	return true


func _neutral_stats(characters: Array[CharacterDefinition]) -> bool:
	for character: CharacterDefinition in characters:
		if character.base_speed != 2 or character.base_stamina != 2 or character.base_bag_level != 2:
			return false
	return true


func _skills_are_deferred(characters: Array[CharacterDefinition]) -> bool:
	for character: CharacterDefinition in characters:
		if (
			not character.passive_skill_id.is_empty()
			or not character.active_skill_id.is_empty()
			or character.active_orb_requirement != 0
		):
			return false
	return true


func _order_matches_houses(characters: Array[CharacterDefinition]) -> bool:
	var houses: Array[HouseDefinition] = HOUSE_REPOSITORY.load_all()
	if characters.size() != houses.size():
		return false
	for index: int in range(characters.size()):
		if characters[index].origin_house_id != houses[index].house_id:
			return false
	return true


func _setup_uses_production(expected: Array[CharacterDefinition]) -> bool:
	var setup: SETUP_SESSION = SETUP_SESSION.new()
	return _ids(setup.characters) == _ids(expected)


func _presentation_names_match() -> bool:
	var setup: SETUP_SESSION = SETUP_SESSION.new()
	for index: int in range(setup.characters.size()):
		var view: Dictionary = setup.character_presentation(setup.characters[index])
		if String(view.get("name", "")) != _expected_names()[index]:
			return false
	return true


func _presentation_houses_match() -> bool:
	var setup: SETUP_SESSION = SETUP_SESSION.new()
	var houses: Array[HouseDefinition] = HOUSE_REPOSITORY.load_all()
	for index: int in range(setup.characters.size()):
		var view: Dictionary = setup.character_presentation(setup.characters[index])
		if String(view.get("house", "")) != houses[index].display_name:
			return false
	return true


func _duplicate_selection_rejected() -> bool:
	var setup: SETUP_SESSION = SETUP_SESSION.new()
	setup.begin_new_game()
	if not bool(setup.choose_player_count(3).get("success", false)):
		return false
	var character_id: StringName = setup.characters[0].character_id
	if not bool(setup.select_character(character_id).get("success", false)):
		return false
	setup.lock_current_character()
	setup.continue_after_pass_device()
	var duplicate: Dictionary = setup.select_character(character_id)
	return (
		not bool(duplicate.get("success", true))
		and String(duplicate.get("code", "")) == "DUPLICATE_CHARACTER_DISALLOWED"
	)


func _five_candidate_layout_is_valid() -> bool:
	var packed: PackedScene = load(PLAYER_SCENE) as PackedScene
	var root: Node = packed.instantiate() if packed != null else null
	if root == null:
		return false
	var grid: GridContainer = root.find_child("CharacterGrid", true, false) as GridContainer
	var scroll: ScrollContainer = root.find_child("CharacterScroll", true, false) as ScrollContainer
	var valid: bool = grid != null and grid.columns == 2 and scroll != null
	root.free()
	return valid and CHARACTER_REPOSITORY.load_all().size() == 5


func _player_for(character: CharacterDefinition) -> PlayerPhaseState:
	var player: PLAYER_STATE = PLAYER_STATE.new()
	player.player_id = StringName("player_%s" % character.character_id)
	player.seat_index = 0
	player.character_id = character.character_id
	return player


func _movement_for(
	character: CharacterDefinition, map_definition: LootMapDefinition
) -> LootMovementSession:
	var players: Array[PlayerPhaseState] = []
	players.append(_player_for(character))
	return MOVEMENT_SERVICE.new().build_session_from_selection(
		players, CHARACTER_REPOSITORY.load_all(), map_definition, &"production_roster_test"
	)


func _spawns_match(
	characters: Array[CharacterDefinition], map_definition: LootMapDefinition
) -> bool:
	for character: CharacterDefinition in characters:
		var movement: LootMovementSession = _movement_for(character, map_definition)
		if movement == null or movement.player_states.size() != 1:
			return false
		var expected_spawn: StringName = StringName(
			map_definition.origin_spawn_by_house.get(character.origin_house_id, &"")
		)
		if (
			expected_spawn.is_empty()
			or movement.player_states[0].origin_house_id != character.origin_house_id
			or movement.player_states[0].current_node_id != expected_spawn
		):
			return false
	return true


func _movement_stats_match(
	characters: Array[CharacterDefinition],
	map_definition: LootMapDefinition,
	check_speed: bool
) -> bool:
	for character: CharacterDefinition in characters:
		var movement: LootMovementSession = _movement_for(character, map_definition)
		if movement == null or movement.player_states.size() != 1:
			return false
		var state: LootMovementPlayerState = movement.player_states[0]
		if check_speed and state.speed_snapshot != 2:
			return false
		if not check_speed and (state.stamina_snapshot != 2 or state.remaining_moves != 2):
			return false
	return true


func _bag_capacity_matches(
	characters: Array[CharacterDefinition], map_definition: LootMapDefinition
) -> bool:
	for character: CharacterDefinition in characters:
		var players: Array[PlayerPhaseState] = []
		var player: PlayerPhaseState = _player_for(character)
		players.append(player)
		var rolls: Array[int] = []
		rolls.append(0)
		var session: LootRewardSession = REWARD_SERVICE.new().build_session(
			players,
			characters,
			map_definition,
			Gd2FixtureRepository.load_m4_rewards(),
			REWARD_ROLL_SOURCE.new(rolls),
			&"production_roster_test"
		)
		if session == null:
			return false
		var round_loot: RoundLootInventoryState = session.find_round_loot_state(
			player.player_id
		)
		if (
			int(session.bag_capacity_by_player.get(String(player.player_id), -1)) != 2
			or round_loot == null
			or round_loot.capacity != 2
		):
			return false
	return true


func _legacy_fixtures_unchanged() -> bool:
	var fixtures: Array[CharacterDefinition] = Gd2FixtureRepository.load_selection_characters()
	var expected: Array[StringName] = []
	expected.append(&"test_character_a")
	expected.append(&"test_character_b")
	expected.append(&"test_character_c")
	expected.append(&"test_character_d")
	if _ids(fixtures) != expected:
		return false
	for character: CharacterDefinition in fixtures:
		if not character.test_only_not_canon_locked:
			return false
	return true
