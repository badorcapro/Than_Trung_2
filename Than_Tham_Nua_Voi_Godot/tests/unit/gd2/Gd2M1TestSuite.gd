class_name Gd2M1TestSuite
extends RefCounted

func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var characters: Array[CharacterDefinition] = Gd2FixtureRepository.load_characters()
	var map_definition: LootMapDefinition = Gd2FixtureRepository.load_map()
	var equipment: Array[EquipmentInstance] = Gd2FixtureRepository.load_equipment()
	var players: Array[PlayerPhaseState] = Gd2FixtureRepository.build_players()
	rows.append(_row("GĐ2-M1 scene shell loads", load("res://scenes/loot/VSLootMain.tscn") is PackedScene))
	rows.append(_row("GĐ2-M1 fixture characters load", characters.size() == 3))
	rows.append(_row("GĐ2-M1 fixture map loads", map_definition != null and map_definition.nodes.size() == 5))
	rows.append(_row("GĐ2-M1 fixture Equipment loads", equipment.size() == 4))
	rows.append(_row("GĐ2-M1 aggregate fixture valid", LootFixtureValidator.new().validate(characters, map_definition, players).is_valid))
	var character_validator := CharacterDefinitionValidator.new()
	var invalid_character := CharacterDefinition.new(); invalid_character.origin_house_id = &"test_house"; invalid_character.base_speed = 0
	rows.append(_row("Character empty ID fails", _has_error(character_validator.validate(invalid_character), &"CHARACTER_ID_EMPTY")))
	rows.append(_row("Character speed zero fails", _has_error(character_validator.validate(invalid_character), &"SPEED_BELOW_ONE")))
	invalid_character.character_id = &"invalid_character"; invalid_character.base_speed = 1; invalid_character.base_stamina = -1
	rows.append(_row("Character negative stamina fails", _has_error(character_validator.validate(invalid_character), &"STAMINA_NEGATIVE")))
	invalid_character.base_stamina = 0; invalid_character.base_bag_level = -1
	rows.append(_row("Character negative Bag fails", _has_error(character_validator.validate(invalid_character), &"BAG_LEVEL_NEGATIVE")))
	rows.append(_row("Valid Character fixture passes", character_validator.validate(characters[0]).is_valid))
	var equipment_validator := EquipmentValidator.new()
	var invalid_equipment := EquipmentInstance.new(); invalid_equipment.instance_id = &"invalid"; invalid_equipment.equipment_definition_id = &"test"; invalid_equipment.gold_star_level = -1
	rows.append(_row("Gold below range fails", _has_error(equipment_validator.validate(invalid_equipment), &"GOLD_STAR_OUT_OF_RANGE")))
	invalid_equipment.gold_star_level = 6; invalid_equipment.purple_star_level = 7
	rows.append(_row("Purple above range fails", _has_error(equipment_validator.validate(invalid_equipment), &"PURPLE_STAR_OUT_OF_RANGE")))
	invalid_equipment.gold_star_level = 1; invalid_equipment.purple_star_level = 2
	rows.append(_row("Purple greater than Gold fails", _has_error(equipment_validator.validate(invalid_equipment), &"PURPLE_EXCEEDS_GOLD")))
	invalid_equipment.purple_star_level = 0; invalid_equipment.equipment_type = EquipmentEnums.EquipmentType.RELIC; invalid_equipment.stigmata_slot = EquipmentEnums.StigmataSlot.A
	rows.append(_row("Relic with slot A fails", _has_error(equipment_validator.validate(invalid_equipment), &"RELIC_SLOT_INVALID")))
	invalid_equipment.equipment_type = EquipmentEnums.EquipmentType.STIGMATA; invalid_equipment.stigmata_slot = EquipmentEnums.StigmataSlot.NONE
	rows.append(_row("Stigmata NONE fails", _has_error(equipment_validator.validate(invalid_equipment), &"STIGMATA_SLOT_REQUIRED")))
	invalid_equipment.equipment_type = 99
	rows.append(_row("Invalid Equipment type fails", _has_error(equipment_validator.validate(invalid_equipment), &"EQUIPMENT_TYPE_INVALID")))
	invalid_equipment.equipment_type = EquipmentEnums.EquipmentType.RELIC; invalid_equipment.stigmata_slot = 99
	rows.append(_row("Invalid Stigmata slot enum fails", _has_error(equipment_validator.validate(invalid_equipment), &"STIGMATA_SLOT_INVALID")))
	invalid_equipment.stigmata_slot = EquipmentEnums.StigmataSlot.NONE; invalid_equipment.tier = 99
	rows.append(_row("Invalid Equipment tier fails", _has_error(equipment_validator.validate(invalid_equipment), &"EQUIPMENT_TIER_INVALID")))
	rows.append(_row("Valid Equipment fixture passes", equipment_validator.validate(equipment[0]).is_valid and equipment_validator.validate(equipment[1]).is_valid))
	var loadout_validator := LoadoutValidator.new(); var loadout := LoadoutState.new()
	loadout.relic_instance_id = equipment[0].instance_id; loadout.stigmata_a_instance_id = equipment[0].instance_id
	rows.append(_row("Duplicate instance across slots fails", _has_error(loadout_validator.validate(equipment, loadout), &"INSTANCE_EQUIPPED_MULTIPLE_SLOTS")))
	loadout = LoadoutState.new(); loadout.stigmata_a_instance_id = equipment[2].instance_id
	rows.append(_row("Wrong A/B/C slot fails", _has_error(loadout_validator.validate(equipment, loadout), &"STIGMATA_LOADOUT_SLOT_MISMATCH")))
	var second_relic := EquipmentInstance.new(); second_relic.instance_id = &"test_relic_002"; second_relic.equipment_definition_id = &"test_relic_definition_2"
	var collection_with_two_relics: Array[EquipmentInstance] = equipment.duplicate(); collection_with_two_relics.append(second_relic)
	loadout = LoadoutState.new(); loadout.relic_instance_id = equipment[0].instance_id; loadout.stigmata_a_instance_id = second_relic.instance_id
	rows.append(_row("More than one referenced Relic fails", _has_error(loadout_validator.validate(collection_with_two_relics, loadout), &"MULTIPLE_RELICS_EQUIPPED")))
	loadout = LoadoutState.new(); loadout.relic_instance_id = &"missing_instance"
	rows.append(_row("Missing loadout instance fails", _has_error(loadout_validator.validate(equipment, loadout), &"LOADOUT_INSTANCE_MISSING")))
	loadout = LoadoutState.new(); loadout.relic_instance_id = equipment[0].instance_id; loadout.stigmata_a_instance_id = equipment[1].instance_id; loadout.stigmata_b_instance_id = equipment[2].instance_id; loadout.stigmata_c_instance_id = equipment[3].instance_id
	rows.append(_row("Valid loadout passes", loadout_validator.validate(equipment, loadout).is_valid))
	var map_validator := LootMapValidator.new(); var duplicate_map := _duplicate_node_map()
	rows.append(_row("Duplicate Loot node fails", _has_error(map_validator.validate(duplicate_map), &"DUPLICATE_NODE_ID")))
	var dangling_map := _single_node_map(&"missing")
	rows.append(_row("Dangling Loot edge fails", _has_error(map_validator.validate(dangling_map), &"DANGLING_EDGE")))
	var houses: Array[StringName] = [&"missing_house"]
	rows.append(_row("Missing origin spawn fails", _has_error(map_validator.validate(map_definition, houses), &"ORIGIN_SPAWN_MISSING")))
	rows.append(_row("Valid Loot map passes", map_validator.validate(map_definition, [&"test_house_a", &"test_house_b", &"test_house_c"]).is_valid))
	var bad_player := PlayerPhaseState.new(); bad_player.player_id = &"bad"; bad_player.character_id = &"test_character_a"; bad_player.orb_count = -1
	rows.append(_row("Negative player resource fails", _has_error(PlayerPhaseStateValidator.new().validate(bad_player), &"RESOURCE_OR_STATE_NEGATIVE")))
	rows.append(_row("Valid PlayerPhaseState passes", PlayerPhaseStateValidator.new().validate(players[0]).is_valid))
	var serializer: Gd2StateSerializer = Gd2StateSerializer.new(); var payload: String = serializer.serialize_player(players[0])
	rows.append(_row("PlayerPhaseState persistent round-trip equal", serializer.round_trip_matches(players[0])))
	rows.append(_row("Serialized state excludes Node and scene refs", not serializer.contains_forbidden_runtime_value(JSON.parse_string(payload))))
	rows.append(_row("Temporary effect contract round-trips", _temporary_effect_round_trip()))
	rows.append(_row("Gacha Basic and Rate Up state separated", players[0].gacha_state.rate_up_state_by_banner is Dictionary and players[0].gacha_state.consecutive_without_a_plus == 0))
	return rows

func _row(name: String, passed: bool) -> Dictionary:
	return {"name":name, "passed":passed, "detail":"GĐ2-M1 foundation invariant"}

func _has_error(report: LootValidationReport, code: StringName) -> bool:
	for issue in report.errors:
		if issue.code == code: return true
	return false

func _duplicate_node_map() -> LootMapDefinition:
	var result := LootMapDefinition.new(); result.map_id = &"test_duplicate"
	var a := LootNodeDefinition.new(); a.node_id = &"same"
	var b := LootNodeDefinition.new(); b.node_id = &"same"
	result.nodes.append(a); result.nodes.append(b)
	return result

func _single_node_map(neighbor: StringName) -> LootMapDefinition:
	var result := LootMapDefinition.new(); result.map_id = &"test_dangling"
	var node := LootNodeDefinition.new(); node.node_id = &"start"; node.outgoing_neighbor_ids.append(neighbor)
	result.nodes.append(node)
	return result

func _temporary_effect_round_trip() -> bool:
	var effect := TemporaryEffectState.new(); effect.effect_id = &"test_effect"; effect.target_player_ids.append(&"test_player_1"); effect.duration = TemporaryEffectState.Duration.THIS_ROUND
	var restored: TemporaryEffectState = TemporaryEffectState.from_dict(effect.to_dict())
	return restored.effect_id == effect.effect_id and restored.target_player_ids == effect.target_player_ids and restored.duration == effect.duration
