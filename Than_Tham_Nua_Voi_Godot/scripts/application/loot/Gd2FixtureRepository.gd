class_name Gd2FixtureRepository
extends RefCounted

const CHARACTER_PATHS := ["res://content/characters/fixtures/character_a.tres", "res://content/characters/fixtures/character_b.tres", "res://content/characters/fixtures/character_c.tres"]
const CHARACTER_SELECTION_PATHS := ["res://content/characters/fixtures/character_a.tres", "res://content/characters/fixtures/character_b.tres", "res://content/characters/fixtures/character_c.tres", "res://content/characters/fixtures/character_d.tres"]
const MAP_PATH := "res://content/loot_maps/fixtures/loot_map_m1_test_only.tres"
const M3_MAP_PATH := "res://content/loot_maps/fixtures/loot_map_m3_test_only.tres"
const EQUIPMENT_PATHS := ["res://tests/fixtures/gd2/equipment_relic_test_only.tres", "res://tests/fixtures/gd2/equipment_stigmata_a_test_only.tres", "res://tests/fixtures/gd2/equipment_stigmata_b_test_only.tres", "res://tests/fixtures/gd2/equipment_stigmata_c_test_only.tres"]
const M4_REWARD_PATHS := ["res://tests/fixtures/gd2/m4_reward_silver.tres", "res://tests/fixtures/gd2/m4_reward_orb.tres", "res://tests/fixtures/gd2/m4_reward_ticket.tres", "res://tests/fixtures/gd2/m4_reward_exp.tres", "res://tests/fixtures/gd2/m4_reward_exchange.tres", "res://tests/fixtures/gd2/m4_reward_item.tres", "res://tests/fixtures/gd2/m4_reward_special_once.tres"]
const M4_ITEM_PATHS := ["res://tests/fixtures/gd2/m4_item_move_plus.tres", "res://tests/fixtures/gd2/m4_item_extra_action.tres", "res://tests/fixtures/gd2/m4_item_all_others_penalty.tres"]
const M5_EQUIPMENT_PATHS := ["res://tests/fixtures/gd2/m5_equipment_a_relic.tres","res://tests/fixtures/gd2/m5_equipment_a_stig_a.tres","res://tests/fixtures/gd2/m5_equipment_a_stig_b.tres","res://tests/fixtures/gd2/m5_equipment_a_stig_c.tres","res://tests/fixtures/gd2/m5_equipment_s_relic.tres","res://tests/fixtures/gd2/m5_equipment_s_other.tres","res://tests/fixtures/gd2/m5_equipment_s_stig_a.tres","res://tests/fixtures/gd2/m5_equipment_s_stig_b.tres","res://tests/fixtures/gd2/m5_equipment_s_stig_c.tres","res://tests/fixtures/gd2/m5_equipment_ss_relic.tres","res://tests/fixtures/gd2/m5_equipment_ss_stig_a.tres","res://tests/fixtures/gd2/m5_equipment_ss_stig_b.tres","res://tests/fixtures/gd2/m5_equipment_ss_stig_c.tres"]
const M5_PERFECT_PATHS := ["res://tests/fixtures/gd2/m5_perfect_ss_relic.tres","res://tests/fixtures/gd2/m5_perfect_ss_stigmata_choice.tres","res://tests/fixtures/gd2/m5_perfect_s_choice.tres","res://tests/fixtures/gd2/m5_perfect_exp.tres","res://tests/fixtures/gd2/m5_perfect_exchange.tres","res://tests/fixtures/gd2/m5_perfect_silver.tres","res://tests/fixtures/gd2/m5_perfect_ticket.tres"]
const M5_GACHA_CONFIG_PATH := "res://tests/fixtures/gd2/m5_gacha_config_test_only.tres"
const PRODUCTION_MAP_PATH := "res://content/loot_maps/production/imperial_court_tabletop_v1.tres"

static func load_characters() -> Array[CharacterDefinition]:
	var result: Array[CharacterDefinition] = []
	for path in CHARACTER_PATHS:
		var item: CharacterDefinition = load(path) as CharacterDefinition
		if item != null: result.append(item)
	return result

static func load_selection_characters() -> Array[CharacterDefinition]:
	var result: Array[CharacterDefinition] = []
	for path: String in CHARACTER_SELECTION_PATHS:
		var item: CharacterDefinition = load(path) as CharacterDefinition
		if item != null: result.append(item)
	return result

static func load_map() -> LootMapDefinition:
	return load(MAP_PATH) as LootMapDefinition

static func load_m3_map() -> LootMapDefinition:
	return load(M3_MAP_PATH) as LootMapDefinition

static func load_production_map() -> LootMapDefinition:
	return load(PRODUCTION_MAP_PATH) as LootMapDefinition

static func load_equipment() -> Array[EquipmentInstance]:
	var result: Array[EquipmentInstance] = []
	for path in EQUIPMENT_PATHS:
		var item: EquipmentInstance = load(path) as EquipmentInstance
		if item != null: result.append(item)
	return result

static func load_m4_rewards() -> Array[RewardDefinition]:
	var result: Array[RewardDefinition] = []
	for path: String in M4_REWARD_PATHS:
		var reward: RewardDefinition = load(path) as RewardDefinition
		if reward != null: result.append(reward)
	return result

static func load_m4_items() -> Array[ConsumableItemDefinition]:
	var result: Array[ConsumableItemDefinition] = []
	for path: String in M4_ITEM_PATHS:
		var item: ConsumableItemDefinition = load(path) as ConsumableItemDefinition
		if item != null: result.append(item)
	return result

static func load_m5_equipment_definitions() -> Array[EquipmentDefinition]:
	var result: Array[EquipmentDefinition] = []
	for path: String in M5_EQUIPMENT_PATHS:
		var definition: EquipmentDefinition = load(path) as EquipmentDefinition
		if definition != null: result.append(definition)
	return result

static func load_m5_perfect_entries() -> Array[PerfectPoolEntry]:
	var result: Array[PerfectPoolEntry] = []
	for path: String in M5_PERFECT_PATHS:
		var entry: PerfectPoolEntry = load(path) as PerfectPoolEntry
		if entry != null: result.append(entry)
	return result

static func load_m5_gacha_config() -> GachaConfig:
	return load(M5_GACHA_CONFIG_PATH) as GachaConfig

static func build_players() -> Array[PlayerPhaseState]:
	var players: Array[PlayerPhaseState] = []
	var characters: Array[CharacterDefinition] = load_characters()
	var equipment: Array[EquipmentInstance] = load_equipment()
	for index in range(characters.size()):
		var state := PlayerPhaseState.new()
		state.player_id = StringName("test_player_%d" % (index + 1)); state.seat_index = index; state.character_id = characters[index].character_id
		# TEST_ONLY legacy snapshot coverage; never movement authority.
		state.reputation = 5 - index; state.round_id = &"test_round_m1"; state.current_node_id = StringName("spawn_test_%d" % (index + 1)); state.remaining_moves = characters[index].base_stamina
		if index == 0:
			state.equipment_collection = equipment
			state.relic_instance_id = &"test_relic_001"; state.stigmata_a_instance_id = &"test_stigmata_a_001"; state.stigmata_b_instance_id = &"test_stigmata_b_001"; state.stigmata_c_instance_id = &"test_stigmata_c_001"
		players.append(state)
	return players
