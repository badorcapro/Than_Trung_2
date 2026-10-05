class_name FixtureRepository
extends RefCounted

const ROLE_PATHS := [
	"res://content/roles/fixtures/tailor.tres",
	"res://content/roles/fixtures/role_good_a.tres",
	"res://content/roles/fixtures/role_good_b.tres",
	"res://content/roles/fixtures/role_good_c.tres",
	"res://content/roles/fixtures/role_meddler_a.tres",
	"res://content/roles/fixtures/role_meddler_b.tres",
	"res://content/roles/fixtures/role_accomplice_a.tres",
	"res://content/roles/fixtures/role_traitor_a.tres",
	"res://content/roles/fixtures/critic.tres",
	"res://content/roles/fixtures/conman.tres",
	"res://content/roles/fixtures/copycat.tres",
	"res://content/roles/fixtures/poisoner.tres",
	"res://content/roles/fixtures/barkeep.tres",
	"res://content/roles/fixtures/drunkard.tres",
	"res://content/roles/fixtures/serial_killer.tres",
	"res://content/roles/fixtures/mailman.tres",
	"res://content/roles/fixtures/mathematician.tres",
	"res://content/roles/fixtures/weatherman.tres",
	"res://content/roles/fixtures/clock_maker.tres",
	"res://content/roles/fixtures/reporter.tres",
	"res://content/roles/fixtures/blood_hound.tres",
	"res://content/roles/fixtures/therapist.tres",
	"res://content/roles/fixtures/spectre.tres",
	"res://content/roles/fixtures/vigilante.tres",
	"res://content/roles/fixtures/surgeon.tres",
	"res://content/roles/fixtures/tutorial_priest.tres",
	"res://content/roles/fixtures/tutorial_scoundrel.tres",
	"res://content/roles/fixtures/tutorial_mobster.tres",
]

const CASE_PATH := "res://content/cases/fixtures/vs_case_001.tres"
const TUTORIAL_CASE_001_PATH := "res://content/cases/fixtures/tutorial_case_001.tres"
const TUTORIAL_CASE_002_PATH := "res://content/cases/fixtures/tutorial_case_002.tres"
const TUTORIAL_CASE_003_PATH := "res://content/cases/fixtures/tutorial_case_003.tres"
const TUTORIAL_CASE_004_PATH := "res://content/cases/fixtures/tutorial_case_004.tres"
const TUTORIAL_CASE_005_PATH := "res://content/cases/fixtures/tutorial_case_005.tres"
const TUTORIAL_CASE_006_PATH := "res://content/cases/fixtures/tutorial_case_006.tres"
const TUTORIAL_CASE_007_PATH := "res://content/cases/fixtures/tutorial_case_007.tres"
const TUTORIAL_CASE_008_PATH := "res://content/cases/fixtures/tutorial_case_008.tres"
const HV1_DISGUISE_CLUE_BEHAVIOR_PATH := "res://content/cases/fixtures/hv1_disguise_clue_behavior.tres"
const HV2_ACTIVE_DISGUISE_PATH := "res://content/cases/fixtures/hv2_active_disguise.tres"
const HV3_TIMED_COEXISTENCE_PATH := "res://content/cases/fixtures/hv3_timed_coexistence.tres"
const HV4_CRITIC_MAILMAN_PATH := "res://content/cases/fixtures/hv4_critic_mailman.tres"
const HV5_MUTATION_VISIBILITY_PATH := "res://content/cases/fixtures/hv5_mutation_visibility.tres"
const HV6_RESOLUTION_TIMED_SAFETY_PATH := "res://content/cases/fixtures/hv6_resolution_timed_safety.tres"
const INVALID_CASE_PATH := "res://tests/fixtures/cases/vs_case_invalid_empty_id.tres"
const PLAYER_PATHS := [
	"res://tests/fixtures/players/player_1.tres",
	"res://tests/fixtures/players/player_2.tres",
	"res://tests/fixtures/players/player_3.tres",
]


static func load_roles() -> Array[RoleDefinition]:
	var roles: Array[RoleDefinition] = []
	for path in ROLE_PATHS:
		var resource := load(path) as RoleDefinition
		if resource != null:
			roles.append(resource)
	return roles


static func load_case() -> CaseDefinition:
	return load(CASE_PATH) as CaseDefinition


static func load_tutorial_case_001() -> CaseDefinition:
	return load(TUTORIAL_CASE_001_PATH) as CaseDefinition


static func load_tutorial_case_002() -> CaseDefinition:
	return load(TUTORIAL_CASE_002_PATH) as CaseDefinition


static func load_tutorial_case_003() -> CaseDefinition:
	return load(TUTORIAL_CASE_003_PATH) as CaseDefinition


static func load_tutorial_case_004() -> CaseDefinition:
	return load(TUTORIAL_CASE_004_PATH) as CaseDefinition


static func load_tutorial_case_005() -> CaseDefinition:
	return load(TUTORIAL_CASE_005_PATH) as CaseDefinition


static func load_tutorial_case_006() -> CaseDefinition:
	return load(TUTORIAL_CASE_006_PATH) as CaseDefinition


static func load_tutorial_case_007() -> CaseDefinition:
	return load(TUTORIAL_CASE_007_PATH) as CaseDefinition


static func load_tutorial_case_008() -> CaseDefinition:
	return load(TUTORIAL_CASE_008_PATH) as CaseDefinition


static func load_hv1_disguise_clue_behavior() -> CaseDefinition:
	return load(HV1_DISGUISE_CLUE_BEHAVIOR_PATH) as CaseDefinition


static func load_hv2_active_disguise() -> CaseDefinition:
	return load(HV2_ACTIVE_DISGUISE_PATH) as CaseDefinition


static func load_hv3_timed_coexistence() -> CaseDefinition:
	return load(HV3_TIMED_COEXISTENCE_PATH) as CaseDefinition


static func load_hv4_critic_mailman() -> CaseDefinition:
	return load(HV4_CRITIC_MAILMAN_PATH) as CaseDefinition


static func load_hv5_mutation_visibility() -> CaseDefinition:
	return load(HV5_MUTATION_VISIBILITY_PATH) as CaseDefinition


static func load_hv6_resolution_timed_safety() -> CaseDefinition:
	return load(HV6_RESOLUTION_TIMED_SAFETY_PATH) as CaseDefinition


static func load_invalid_case() -> CaseDefinition:
	return load(INVALID_CASE_PATH) as CaseDefinition


static func build_sample_case_4x4_visual() -> CaseDefinition:
	var sample: CaseDefinition = CaseDefinition.new()
	sample.case_id = &"sample_case_4x4_visual"
	sample.display_name = "Sample 4×4 — Layout Spike"
	sample.short_description = "Synthetic visual-only board used to inspect compact 4×4 case layout."
	sample.difficulty_label = "DEV VISUAL"
	sample.merit_pool = 0
	sample.reputation_penalty_on_wrong = 0
	sample.base_ticket_reward = 0
	sample.test_only_not_balance_locked = true
	sample.balance_note = "VISUAL_ONLY: 4×4 board/card readability spike, not a playable/generated case."
	sample.set_meta(&"board_columns", 4)
	sample.set_meta(&"board_slot_count", 16)
	sample.set_meta(&"visual_sample_case", true)

	var reward: OnSolveReward = OnSolveReward.new()
	reward.reward_id = &"sample_case_4x4_visual_reward"
	reward.reputation_delta = 0
	reward.test_only_not_balance_locked = true
	reward.note = "VISUAL_ONLY: no gameplay reward."
	sample.on_solve = reward

	var scene: CrimeSceneDefinition = CrimeSceneDefinition.new()
	scene.scene_id = &"sample_scene_4x4_visual"
	scene.display_name = "Hiện trường"
	scene.board_slot = 5
	scene.description = "Một hiện trường mẫu để kiểm tra bố cục 4×4."
	sample.crime_scene = scene

	var suspects: Array[SuspectDefinition] = [
		_sample_visual_suspect(1, 0, &"therapist", CaseEnums.RoleGroup.CHINH_NHAN, CaseEnums.Alignment.GOOD, "Ta có 1 người bệnh thuộc Phe Ác."),
		_sample_visual_suspect(2, 1, &"reporter", CaseEnums.RoleGroup.CHINH_NHAN, CaseEnums.Alignment.GOOD, "Ta cách Phe Ác gần nhất 3 bước."),
		_sample_visual_suspect(3, 2, &"mathematician", CaseEnums.RoleGroup.CHINH_NHAN, CaseEnums.Alignment.GOOD, "Tổng Số Hiệu của Phe Ác là 21."),
		_sample_visual_suspect(4, 3, &"weatherman", CaseEnums.RoleGroup.CHINH_NHAN, CaseEnums.Alignment.GOOD, "Ta thấy Số Hiệu 1, 11 và 8."),
		_sample_visual_suspect(5, 4, &"blood_hound", CaseEnums.RoleGroup.CHINH_NHAN, CaseEnums.Alignment.GOOD, "Hao Khuyển của ta chỉ nằm im."),
		_sample_visual_suspect(6, 6, &"mailman", CaseEnums.RoleGroup.CHINH_NHAN, CaseEnums.Alignment.GOOD, "Ngự Y đang ở trong cung, ta chưa từng nghe đến Thợ Đồng Hồ."),
		_sample_visual_suspect(7, 7, &"tailor", CaseEnums.RoleGroup.CHINH_NHAN, CaseEnums.Alignment.GOOD, "Ta có thể so hai nghi phạm."),
		_sample_visual_suspect(8, 8, &"surgeon", CaseEnums.RoleGroup.HIEU_SU, CaseEnums.Alignment.GOOD, "Ở mốc 12h, ta có thể ra tay."),
		_sample_visual_suspect(9, 9, &"vigilante", CaseEnums.RoleGroup.HIEU_SU, CaseEnums.Alignment.GOOD, "Công lý sẽ đến với một Số Hiệu."),
		_sample_visual_suspect(10, 11, &"tutorial_priest", CaseEnums.RoleGroup.CHINH_NHAN, CaseEnums.Alignment.GOOD, "Tôi là Tư Tế."),
		_sample_visual_suspect(11, 14, &"tutorial_scoundrel", CaseEnums.RoleGroup.TONG_PHAM, CaseEnums.Alignment.EVIL, "Ta nói dối và giả danh một vai trò đang có trong Kỳ Án."),
		_sample_visual_suspect(12, 15, &"tutorial_mobster", CaseEnums.RoleGroup.TONG_PHAM, CaseEnums.Alignment.EVIL, "Ta giả danh một vai trò đang bị nghi ngờ."),
	]
	sample.suspects = suspects
	var mailman: SuspectDefinition = sample.suspects[5]
	mailman.mailman_claimed_in_play_role_id = &"therapist"
	mailman.mailman_claimed_not_in_play_role_id = &"clock_maker"
	sample.evil_suspect_ids = PackedInt32Array([11, 12])
	sample.accomplice_suspect_ids = PackedInt32Array([11, 12])
	sample.traitor_suspect_ids = PackedInt32Array()
	var role_ids: Array[StringName] = [
		&"therapist",
		&"reporter",
		&"mathematician",
		&"weatherman",
		&"blood_hound",
		&"mailman",
		&"tailor",
		&"surgeon",
		&"vigilante",
		&"tutorial_priest",
		&"tutorial_scoundrel",
		&"tutorial_mobster",
	]
	sample.suspected_role_ids = role_ids
	sample.suspect_list_role_ids = role_ids.duplicate()
	return sample


static func _sample_visual_suspect(
	suspect_id: int,
	board_slot: int,
	role_id: StringName,
	role_group: int,
	alignment: int,
	statement: String
) -> SuspectDefinition:
	var suspect: SuspectDefinition = SuspectDefinition.new()
	suspect.suspect_id = suspect_id
	suspect.board_slot = board_slot
	suspect.true_role_id = role_id
	suspect.displayed_role_id = role_id
	suspect.true_alignment = alignment
	suspect.role_group = role_group
	suspect.public_investigation_statement = statement
	return suspect


static func load_players() -> Array[PlayerCaseState]:
	var players: Array[PlayerCaseState] = []
	for path in PLAYER_PATHS:
		var resource := load(path) as PlayerCaseState
		if resource != null:
			players.append(resource)
	return players
