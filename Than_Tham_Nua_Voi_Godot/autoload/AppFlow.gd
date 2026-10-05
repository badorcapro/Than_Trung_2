extends Node

const DEBUG_HOME_SCENE := "res://scenes/boot/DebugHome.tscn"
const ROLE_CODEX_SCENE := "res://scenes/boot/RoleCodex.tscn"
const PLAYER_FACING_START_SCENE := "res://scenes/player_facing/PlayerFacingStart.tscn"
const VS_CASE_MAIN_SCENE := "res://scenes/case_gameplay/VSCaseMain.tscn"
const VS_LOOT_M1_SCENE := "res://scenes/loot/VSLootMain.tscn"
const GD2_M2_SELECTION_SCENE := "res://scenes/loot/Gd2M2CharacterSelection.tscn"
const GD2_M3_MOVEMENT_SCENE := "res://scenes/loot/Gd2M3Movement.tscn"
const GD2_M4_REWARD_ITEM_SCENE := "res://scenes/loot/Gd2M4RewardItem.tscn"
const GD2_M5_EQUIPMENT_MANAGEMENT_SCENE := "res://scenes/loot/Gd2M5EquipmentManagement.tscn"
const GD2_M6_PROTOTYPE_B_SCENE := "res://scenes/loot/Gd2M6PrototypeBFullFlow.tscn"
const PRODUCTION_LOOT_MAP_PREVIEW_SCENE := "res://scenes/loot/ProductionLootMapPreview.tscn"
const GD3_M2_CASE_LOOT_BRIDGE_SCENE := "res://scenes/mvp/Gd3M2CaseLootBridge.tscn"
const GD3_M3_INTEGRATED_CASE_LOOT_SCENE := "res://scenes/mvp/Gd3M3IntegratedCaseLoot.tscn"
const GD3_M4_ROUND_COMPLETION_SCENE := "res://scenes/mvp/Gd3M4RoundCompletion.tscn"
const GD3_M5_NEXT_CASE_ORCHESTRATION_SCENE := "res://scenes/mvp/Gd3M5NextCaseOrchestration.tscn"
const GD3_M6_TWO_ROUND_COMPLETION_SCENE := "res://scenes/mvp/Gd3M6TwoRoundCompletion.tscn"

var pending_m3_players: Array[PlayerPhaseState] = []
var pending_case_path := ""
var pending_case_definition: CaseDefinition


func go_to_debug_home() -> Error:
	return _change_scene(DEBUG_HOME_SCENE, "DebugHome")


func go_to_role_codex() -> Error:
	return _change_scene(ROLE_CODEX_SCENE, "Sổ Vai Trò")


func go_to_player_main_menu() -> Error:
	return _change_scene(PLAYER_FACING_START_SCENE, "Player Main Menu")


func go_to_case_vertical_slice() -> Error:
	pending_case_path = ""
	pending_case_definition = null
	return _change_scene(VS_CASE_MAIN_SCENE, "Vertical Slice Kỳ Án")


func go_to_sample_case_4x4_visual() -> Error:
	pending_case_path = ""
	pending_case_definition = FixtureRepository.build_sample_case_4x4_visual()
	return _change_scene(VS_CASE_MAIN_SCENE, "Sample 4×4 Case Board")


func go_to_tutorial_case_001() -> Error:
	pending_case_path = FixtureRepository.TUTORIAL_CASE_001_PATH
	return _change_scene(VS_CASE_MAIN_SCENE, "Tutorial Case 01 — Deduction M0")


func go_to_tutorial_case_002() -> Error:
	pending_case_path = FixtureRepository.TUTORIAL_CASE_002_PATH
	return _change_scene(VS_CASE_MAIN_SCENE, "Tutorial Case 02 — Deduction")


func go_to_tutorial_case_003() -> Error:
	pending_case_path = FixtureRepository.TUTORIAL_CASE_003_PATH
	return _change_scene(VS_CASE_MAIN_SCENE, "Tutorial Case 03 — Deduction")


func go_to_tutorial_case_004() -> Error:
	pending_case_path = FixtureRepository.TUTORIAL_CASE_004_PATH
	return _change_scene(VS_CASE_MAIN_SCENE, "Tutorial Case 04 — Active Ability")


func go_to_tutorial_case_005() -> Error:
	pending_case_path = FixtureRepository.TUTORIAL_CASE_005_PATH
	return _change_scene(VS_CASE_MAIN_SCENE, "Tutorial Case 05 — Timed Roles")


func go_to_tutorial_case_006() -> Error:
	pending_case_path = FixtureRepository.TUTORIAL_CASE_006_PATH
	return _change_scene(VS_CASE_MAIN_SCENE, "Tutorial Case 06 — Transform")


func go_to_tutorial_case_007() -> Error:
	pending_case_path = FixtureRepository.TUTORIAL_CASE_007_PATH
	return _change_scene(VS_CASE_MAIN_SCENE, "Tutorial Case 07 — Dangerous Time")


func go_to_tutorial_case_008() -> Error:
	pending_case_path = FixtureRepository.TUTORIAL_CASE_008_PATH
	return _change_scene(VS_CASE_MAIN_SCENE, "Tutorial Case 08 — Truthful Evil")


func go_to_hv1_disguise_clue_behavior() -> Error:
	pending_case_path = FixtureRepository.HV1_DISGUISE_CLUE_BEHAVIOR_PATH
	return _change_scene(VS_CASE_MAIN_SCENE, "HV1 — Disguise & Clue Behavior")


func go_to_hv2_active_disguise() -> Error:
	pending_case_path = FixtureRepository.HV2_ACTIVE_DISGUISE_PATH
	return _change_scene(VS_CASE_MAIN_SCENE, "HV2 — Active Disguise")


func go_to_hv3_timed_coexistence() -> Error:
	pending_case_path = FixtureRepository.HV3_TIMED_COEXISTENCE_PATH
	return _change_scene(VS_CASE_MAIN_SCENE, "HV3 — Timed Coexistence")


func go_to_hv4_critic_mailman() -> Error:
	pending_case_path = FixtureRepository.HV4_CRITIC_MAILMAN_PATH
	return _change_scene(VS_CASE_MAIN_SCENE, "HV4 — Critic & Mailman")


func go_to_hv5_mutation_visibility() -> Error:
	pending_case_path = FixtureRepository.HV5_MUTATION_VISIBILITY_PATH
	return _change_scene(VS_CASE_MAIN_SCENE, "HV5 — Mutation & Visibility")


func go_to_hv6_resolution_timed_safety() -> Error:
	pending_case_path = FixtureRepository.HV6_RESOLUTION_TIMED_SAFETY_PATH
	return _change_scene(VS_CASE_MAIN_SCENE, "HV6 — Resolution & Timed Safety")


func take_pending_case_definition() -> CaseDefinition:
	if pending_case_definition != null:
		var definition: CaseDefinition = pending_case_definition
		pending_case_definition = null
		pending_case_path = ""
		return definition
	if pending_case_path.is_empty():
		return null
	var path := pending_case_path
	pending_case_path = ""
	return load(path) as CaseDefinition


func go_to_loot_m1_foundation() -> Error:
	return _change_scene(VS_LOOT_M1_SCENE, "GĐ2-M1 Loot Foundation")

func go_to_gd2_m2_character_selection() -> Error:
	return _change_scene(GD2_M2_SELECTION_SCENE, "GĐ2-M2 Character Selection")

func go_to_gd2_m3_movement(players: Array[PlayerPhaseState] = []) -> Error:
	pending_m3_players.clear()
	for player: PlayerPhaseState in players:
		pending_m3_players.append(PlayerPhaseState.from_dict(player.to_dict()))
	return _change_scene(GD2_M3_MOVEMENT_SCENE, "GĐ2-M3 Spawn + Movement")

func go_to_production_loot_map_preview() -> Error:
	return _change_scene(
		PRODUCTION_LOOT_MAP_PREVIEW_SCENE,
		"GĐ2-M0A Production Imperial Court Tabletop"
	)

func take_pending_m3_players() -> Array[PlayerPhaseState]:
	var result: Array[PlayerPhaseState] = pending_m3_players
	pending_m3_players = []
	return result

func go_to_gd2_m4_reward_item() -> Error:
	return _change_scene(GD2_M4_REWARD_ITEM_SCENE, "GĐ2-M4 Reward + Item + Temporary Effect")

func go_to_gd2_m5_equipment_management() -> Error:
	return _change_scene(GD2_M5_EQUIPMENT_MANAGEMENT_SCENE, "GĐ2-M5 Equipment Management + Gacha")

func go_to_gd2_m6_prototype_b() -> Error:
	return _change_scene(GD2_M6_PROTOTYPE_B_SCENE, "GĐ2-M6 Prototype B Full Flow")

func go_to_gd3_m2_case_loot_bridge() -> Error:
	return _change_scene(GD3_M2_CASE_LOOT_BRIDGE_SCENE, "GĐ3-M2 Case to Loot Bridge")

func go_to_gd3_m3_integrated_case_loot() -> Error:
	return _change_scene(
		GD3_M3_INTEGRATED_CASE_LOOT_SCENE, "GĐ3-M3 Integrated Case to Loot"
	)

func go_to_gd3_m4_round_completion() -> Error:
	return _change_scene(
		GD3_M4_ROUND_COMPLETION_SCENE, "GĐ3-M4 Integrated Round Completion"
	)

func go_to_gd3_m5_next_case_orchestration() -> Error:
	return _change_scene(
		GD3_M5_NEXT_CASE_ORCHESTRATION_SCENE, "GĐ3-M5 Multi-Round Next Case Integration"
	)

func go_to_gd3_m6_two_round_completion() -> Error:
	return _change_scene(
		GD3_M6_TWO_ROUND_COMPLETION_SCENE, "GĐ3-M6 Bounded Two-Round Completion"
	)


func _change_scene(scene_path: String, scene_label: String) -> Error:
	AppLogger.info("Scene transition requested: %s" % scene_label)
	var result := get_tree().change_scene_to_file(scene_path)
	if result != OK:
		AppLogger.error("Failed to load %s (error %d)" % [scene_label, result])
	return result
