class_name RoleInformationEvaluationService
extends RefCounted

const CASE_ROLE_MODIFIER_SERVICE := preload("res://scripts/domain/cases/CaseRoleModifierService.gd")
const POISONER_TAINT_SERVICE := preload("res://scripts/domain/cases/PoisonerTaintService.gd")
const CASE_ROLE_POOL_SERVICE := preload("res://scripts/domain/cases/CaseRolePoolService.gd")

const PRIEST_ROLE_IDS: Array[StringName] = [&"tutorial_priest", &"priest"]
const REPORTER_ROLE_IDS: Array[StringName] = [&"reporter"]
const THERAPIST_ROLE_IDS: Array[StringName] = [&"therapist"]
const MAILMAN_ROLE_IDS: Array[StringName] = [&"mailman"]
const BLOOD_HOUND_ROLE_IDS: Array[StringName] = [&"blood_hound"]
const MATHEMATICIAN_ROLE_IDS: Array[StringName] = [&"mathematician"]
const WEATHERMAN_ROLE_IDS: Array[StringName] = [&"weatherman"]
const CLOCK_MAKER_ROLE_IDS: Array[StringName] = [&"clock_maker"]
const MOBSTER_ROLE_IDS: Array[StringName] = [&"tutorial_mobster", &"mobster"]
const SPECTRE_ROLE_IDS: Array[StringName] = [&"spectre"]
const POISONER_ROLE_IDS: Array[StringName] = [&"poisoner"]
const BARKEEP_ROLE_IDS: Array[StringName] = [&"barkeep"]
const DRUNKARD_ROLE_IDS: Array[StringName] = [&"drunkard"]
const SERIAL_KILLER_ROLE_IDS: Array[StringName] = [&"serial_killer"]
const BLOOD_HOUND_OUTCOMES: Array[StringName] = [
	CaseSpatialService.DIRECTION_NORTH,
	CaseSpatialService.DIRECTION_EAST,
	CaseSpatialService.DIRECTION_SOUTH,
	CaseSpatialService.DIRECTION_WEST,
	CaseSpatialService.BLOOD_HOUND_BARK,
	CaseSpatialService.BLOOD_HOUND_SNIFF,
]
const PRIEST_TRUTHFUL_TEXT: String = "Tôi là Tư Tế."
const PRIEST_LIE_TEXTS: Array[String] = [
	"Ta có thật là một Tư Tế tốt không?",
	"Tôi chỉ nhớ mình từng đứng trong thánh đường.",
]


func evaluate(
	case_definition: CaseDefinition,
	suspect_id: int,
	roles: Array[RoleDefinition] = [],
	mailman_pair: Dictionary = {},
	runtime_state: CaseRuntimeState = null
) -> InvestigationInformationResult:
	var suspect: SuspectDefinition = _find_suspect(case_definition, suspect_id)
	if suspect == null:
		return InvestigationInformationResult.new()
	var behavior_role_id: StringName = investigation_behavior_role_id(suspect)
	var truth_mode: int = truth_mode_for_suspect_effective(case_definition, runtime_state, suspect_id)
	return evaluate_behavior(case_definition, suspect, behavior_role_id, truth_mode, roles, mailman_pair, runtime_state)


func evaluate_behavior(
	case_definition: CaseDefinition,
	suspect: SuspectDefinition,
	behavior_role_id: StringName,
	truth_mode: int,
	roles: Array[RoleDefinition] = [],
	mailman_pair: Dictionary = {},
	runtime_state: CaseRuntimeState = null
) -> InvestigationInformationResult:
	var result: InvestigationInformationResult = _base_result(suspect, behavior_role_id, truth_mode)
	if _role_id_in(behavior_role_id, PRIEST_ROLE_IDS):
		_evaluate_priest(suspect, result)
	elif _role_id_in(behavior_role_id, REPORTER_ROLE_IDS):
		_evaluate_reporter(case_definition, suspect, result)
	elif _role_id_in(behavior_role_id, THERAPIST_ROLE_IDS):
		_evaluate_therapist(case_definition, suspect, result)
	elif _role_id_in(behavior_role_id, MAILMAN_ROLE_IDS):
		_evaluate_mailman(case_definition, suspect, result, roles, mailman_pair, runtime_state)
	elif _role_id_in(behavior_role_id, BLOOD_HOUND_ROLE_IDS):
		_evaluate_blood_hound(case_definition, result, runtime_state)
	elif _role_id_in(behavior_role_id, MATHEMATICIAN_ROLE_IDS):
		_evaluate_mathematician(case_definition, suspect, result)
	elif _role_id_in(behavior_role_id, WEATHERMAN_ROLE_IDS):
		_evaluate_weatherman(case_definition, suspect, result, roles, runtime_state)
	elif _role_id_in(behavior_role_id, CLOCK_MAKER_ROLE_IDS):
		_evaluate_clock_maker(case_definition, suspect, result)
	return result


func investigation_behavior_role_id(suspect: SuspectDefinition) -> StringName:
	if suspect == null:
		return &""
	if not String(suspect.displayed_role_id).is_empty():
		return suspect.displayed_role_id
	return suspect.true_role_id


func truth_mode_for_suspect(suspect: SuspectDefinition) -> int:
	if suspect == null:
		return InvestigationInformationResult.TruthMode.TRUTHFUL
	if suspect.is_corrupted:
		return InvestigationInformationResult.TruthMode.LYING
	if CASE_ROLE_MODIFIER_SERVICE.is_critic_role_id(suspect.true_role_id):
		return InvestigationInformationResult.TruthMode.LYING
	if _role_id_in(suspect.true_role_id, MOBSTER_ROLE_IDS) or _role_id_in(suspect.true_role_id, SPECTRE_ROLE_IDS) or _role_id_in(suspect.true_role_id, POISONER_ROLE_IDS) or _role_id_in(suspect.true_role_id, BARKEEP_ROLE_IDS) or _role_id_in(suspect.true_role_id, DRUNKARD_ROLE_IDS) or _role_id_in(suspect.true_role_id, SERIAL_KILLER_ROLE_IDS):
		return InvestigationInformationResult.TruthMode.LYING
	return InvestigationInformationResult.TruthMode.TRUTHFUL


func truth_mode_for_suspect_effective(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, suspect_id: int) -> int:
	var suspect: SuspectDefinition = _find_suspect(case_definition, suspect_id)
	if suspect == null:
		return InvestigationInformationResult.TruthMode.TRUTHFUL
	if POISONER_TAINT_SERVICE.is_effectively_corrupted(case_definition, runtime_state, suspect_id):
		return InvestigationInformationResult.TruthMode.LYING
	if _role_id_in(current_role_id_for_suspect(case_definition, runtime_state, suspect_id), POISONER_ROLE_IDS):
		return InvestigationInformationResult.TruthMode.LYING
	if _role_id_in(current_role_id_for_suspect(case_definition, runtime_state, suspect_id), BARKEEP_ROLE_IDS):
		return InvestigationInformationResult.TruthMode.LYING
	if _role_id_in(current_role_id_for_suspect(case_definition, runtime_state, suspect_id), DRUNKARD_ROLE_IDS):
		return InvestigationInformationResult.TruthMode.LYING
	if _role_id_in(current_role_id_for_suspect(case_definition, runtime_state, suspect_id), SERIAL_KILLER_ROLE_IDS):
		return InvestigationInformationResult.TruthMode.LYING
	return truth_mode_for_suspect(suspect)


func true_role_ids_in_play(case_definition: CaseDefinition, exclude_suspect_id: int = 0) -> Array[StringName]:
	var role_ids: Array[StringName] = []
	if case_definition == null:
		return role_ids
	for suspect in case_definition.suspects:
		if suspect == null or suspect.suspect_id == exclude_suspect_id:
			continue
		if not role_ids.has(suspect.true_role_id):
			role_ids.append(suspect.true_role_id)
	role_ids.sort()
	return role_ids


func true_role_ids_not_in_play(case_definition: CaseDefinition, roles: Array[RoleDefinition], exclude_role_id: StringName = &"") -> Array[StringName]:
	var in_play: Array[StringName] = true_role_ids_in_play(case_definition)
	var not_in_play: Array[StringName] = []
	var candidates: Array[StringName] = _mailman_role_universe(case_definition, roles)
	for role in roles:
		if role == null or role.role_id == exclude_role_id or not candidates.has(role.role_id):
			continue
		if not in_play.has(role.role_id) and not not_in_play.has(role.role_id):
			not_in_play.append(role.role_id)
	not_in_play.sort()
	return not_in_play


func original_true_role_id_for_suspect(case_definition: CaseDefinition, suspect_id: int) -> StringName:
	var suspect: SuspectDefinition = _find_suspect(case_definition, suspect_id)
	return suspect.true_role_id if suspect != null else &""


func current_role_id_for_suspect(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, suspect_id: int) -> StringName:
	if runtime_state != null:
		return runtime_state.current_role_id_for_suspect(case_definition, suspect_id)
	return original_true_role_id_for_suspect(case_definition, suspect_id)


func current_role_ids_in_play(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, exclude_suspect_id: int = 0) -> Array[StringName]:
	return CASE_ROLE_POOL_SERVICE.current_role_ids_in_play(case_definition, runtime_state, exclude_suspect_id)


func current_role_ids_not_in_play(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	roles: Array[RoleDefinition],
	exclude_role_id: StringName = &""
) -> Array[StringName]:
	var candidate_role_ids: Array[StringName] = _mailman_role_universe(case_definition, roles, runtime_state)
	return current_role_ids_not_in_play_from_candidates(case_definition, runtime_state, candidate_role_ids, exclude_role_id)


func _mailman_role_universe(case_definition: CaseDefinition, roles: Array[RoleDefinition], runtime_state: CaseRuntimeState = null) -> Array[StringName]:
	var authored_ids: Array[StringName] = CASE_ROLE_POOL_SERVICE.suspected_role_ids_for_case(case_definition)
	if not authored_ids.is_empty():
		var in_play: Array[StringName] = CASE_ROLE_POOL_SERVICE.current_role_ids_in_play(case_definition, runtime_state)
		for role_id: StringName in authored_ids:
			if not in_play.has(role_id):
				return authored_ids
		for role: RoleDefinition in roles:
			if role != null and not role.is_fixture_placeholder and not authored_ids.has(role.role_id):
				authored_ids.append(role.role_id)
		return authored_ids
	var ids: Array[StringName] = []
	for role: RoleDefinition in roles:
		if role != null and not ids.has(role.role_id):
			ids.append(role.role_id)
	return ids


func current_role_ids_not_in_play_from_candidates(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	candidate_role_ids: Array[StringName],
	exclude_role_id: StringName = &""
) -> Array[StringName]:
	return CASE_ROLE_POOL_SERVICE.current_role_ids_not_in_play(case_definition, runtime_state, candidate_role_ids, exclude_role_id)


func suspected_role_ids_for_case(case_definition: CaseDefinition) -> Array[StringName]:
	return CASE_ROLE_POOL_SERVICE.suspected_role_ids_for_case(case_definition)


func suspected_role_candidates(case_definition: CaseDefinition, exclude_role_id: StringName = &"") -> Array[StringName]:
	return CASE_ROLE_POOL_SERVICE.suspected_role_candidates(case_definition, exclude_role_id)


func good_current_not_in_play_candidates(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	roles: Array[RoleDefinition],
	candidate_role_ids: Array[StringName],
	exclude_role_id: StringName = &""
) -> Array[StringName]:
	return CASE_ROLE_POOL_SERVICE.good_current_not_in_play_candidates(case_definition, runtime_state, roles, candidate_role_ids, exclude_role_id)


func validate_mailman_pair(
	case_definition: CaseDefinition,
	source_suspect_id: int,
	in_play_role_id: StringName,
	not_in_play_role_id: StringName,
	truth_mode: int,
	roles: Array[RoleDefinition] = []
) -> Dictionary:
	var source: SuspectDefinition = _find_suspect(case_definition, source_suspect_id)
	var mailman_role_id: StringName = investigation_behavior_role_id(source)
	if source == null or in_play_role_id == mailman_role_id or not_in_play_role_id == mailman_role_id:
		return {"valid": false, "in_play_truth": false, "not_in_play_truth": false}
	var in_play_roles: Array[StringName] = true_role_ids_in_play(case_definition)
	var not_in_play_roles: Array[StringName] = true_role_ids_not_in_play(case_definition, roles, mailman_role_id)
	var in_play_truth: bool = in_play_roles.has(in_play_role_id)
	var not_in_play_truth: bool = not_in_play_roles.has(not_in_play_role_id)
	if truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL:
		return {"valid": in_play_truth and not_in_play_truth, "in_play_truth": in_play_truth, "not_in_play_truth": not_in_play_truth}
	return {"valid": (not in_play_truth) and (not not_in_play_truth), "in_play_truth": in_play_truth, "not_in_play_truth": not_in_play_truth}


func validate_mailman_pair_current(
	case_definition: CaseDefinition,
	runtime_state: CaseRuntimeState,
	source_suspect_id: int,
	in_play_role_id: StringName,
	not_in_play_role_id: StringName,
	truth_mode: int,
	roles: Array[RoleDefinition] = []
) -> Dictionary:
	var source: SuspectDefinition = _find_suspect(case_definition, source_suspect_id)
	var mailman_role_id: StringName = investigation_behavior_role_id(source)
	if source == null or in_play_role_id == mailman_role_id or not_in_play_role_id == mailman_role_id:
		return {"valid": false, "in_play_truth": false, "not_in_play_truth": false}
	var in_play_roles: Array[StringName] = current_role_ids_in_play(case_definition, runtime_state)
	var not_in_play_roles: Array[StringName] = current_role_ids_not_in_play(case_definition, runtime_state, roles, mailman_role_id)
	var in_play_truth: bool = in_play_roles.has(in_play_role_id)
	var not_in_play_truth: bool = not_in_play_roles.has(not_in_play_role_id)
	if truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL:
		return {"valid": in_play_truth and not_in_play_truth, "in_play_truth": in_play_truth, "not_in_play_truth": not_in_play_truth}
	return {"valid": (not in_play_truth) and (not not_in_play_truth), "in_play_truth": in_play_truth, "not_in_play_truth": not_in_play_truth}


func apply_obscure(result: InvestigationInformationResult, active: bool) -> InvestigationInformationResult:
	if result == null:
		return null
	var public_result: InvestigationInformationResult = result.duplicate_result()
	if not active:
		return public_result
	public_result.is_obscured = true
	public_result.role_identity_visible = false
	public_result.text_information_visible = false
	public_result.numeric_information_visible = true
	return public_result


func apply_obscure_relation(
	result: InvestigationInformationResult,
	case_definition: CaseDefinition,
	relation: InvestigationObscureRelation,
	runtime_state: CaseRuntimeState = null
) -> InvestigationInformationResult:
	if result == null or relation == null or result.suspect_id != relation.target_suspect_id:
		return result
	var obscurer: SuspectDefinition = _find_suspect(case_definition, relation.source_suspect_id)
	var target: SuspectDefinition = _find_suspect(case_definition, relation.target_suspect_id)
	var active: bool = (
		obscurer != null
		and target != null
		and _role_id_in(obscurer.true_role_id, SPECTRE_ROLE_IDS)
		and not POISONER_TAINT_SERVICE.is_effectively_corrupted(case_definition, runtime_state, obscurer.suspect_id)
		and target.role_group != CaseEnums.RoleGroup.HIEU_SU
		and not _role_id_in(current_role_id_for_suspect(case_definition, runtime_state, target.suspect_id), DRUNKARD_ROLE_IDS)
	)
	return apply_obscure(result, active)


func _base_result(
	suspect: SuspectDefinition,
	behavior_role_id: StringName,
	truth_mode: int
) -> InvestigationInformationResult:
	var result: InvestigationInformationResult = InvestigationInformationResult.new()
	if suspect != null:
		result.suspect_id = suspect.suspect_id
		result.true_role_id = suspect.true_role_id
		result.displayed_role_id = suspect.displayed_role_id
	result.behavior_role_id = behavior_role_id
	result.truth_mode = truth_mode
	return result


func _evaluate_priest(suspect: SuspectDefinition, result: InvestigationInformationResult) -> void:
	result.payload_kind = InvestigationInformationResult.PayloadKind.TEXT
	var authored_text: String = suspect.public_investigation_statement if suspect != null else ""
	if not authored_text.is_empty():
		result.text = authored_text
	elif result.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL:
		result.text = PRIEST_TRUTHFUL_TEXT
	else:
		result.text = String(PRIEST_LIE_TEXTS[0])


func _evaluate_reporter(case_definition: CaseDefinition, suspect: SuspectDefinition, result: InvestigationInformationResult) -> void:
	var spatial: CaseSpatialService = CaseSpatialService.new()
	var nearest: Dictionary = spatial.nearest_true_evil_distance(case_definition, result.suspect_id)
	var found: bool = bool(nearest.get("found", false))
	var truthful_distance: int = int(nearest.get("distance", -1))
	if result.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL:
		if found:
			result.payload_kind = InvestigationInformationResult.PayloadKind.NUMBER
			result.numeric_value = truthful_distance
			result.text = "Ta cách Phe Ác gần nhất %d bước." % truthful_distance
		else:
			result.payload_kind = InvestigationInformationResult.PayloadKind.NO_EVIL_FOUND
			result.text = "Tôi không tìm thấy Phe Ác nào."
		return
	result.payload_kind = InvestigationInformationResult.PayloadKind.NUMBER
	result.numeric_value = _authored_or_default_incorrect_int(suspect, 1, 4, truthful_distance)
	result.text = "Ta cách Phe Ác gần nhất %d bước." % result.numeric_value


func _evaluate_therapist(case_definition: CaseDefinition, suspect: SuspectDefinition, result: InvestigationInformationResult) -> void:
	var spatial: CaseSpatialService = CaseSpatialService.new()
	var truthful_count: int = spatial.count_adjacent_true_evil(case_definition, result.suspect_id)
	result.payload_kind = InvestigationInformationResult.PayloadKind.NUMBER
	result.numeric_value = truthful_count
	if result.truth_mode == InvestigationInformationResult.TruthMode.LYING:
		result.numeric_value = _authored_or_default_incorrect_int(suspect, 0, 4, truthful_count)
	result.text = "Ta có %d người bệnh thuộc Phe Ác." % result.numeric_value


func _evaluate_mailman(
	case_definition: CaseDefinition,
	suspect: SuspectDefinition,
	result: InvestigationInformationResult,
	roles: Array[RoleDefinition],
	mailman_pair: Dictionary,
	runtime_state: CaseRuntimeState = null
) -> void:
	var in_play_id: StringName = StringName(mailman_pair.get("in_play_role_id", &""))
	var not_in_play_id: StringName = StringName(mailman_pair.get("not_in_play_role_id", &""))
	if String(in_play_id).is_empty() and suspect != null:
		in_play_id = suspect.mailman_claimed_in_play_role_id
	if String(not_in_play_id).is_empty() and suspect != null:
		not_in_play_id = suspect.mailman_claimed_not_in_play_role_id
	if String(in_play_id).is_empty() or String(not_in_play_id).is_empty():
		var pair: Dictionary = _default_mailman_pair(case_definition, roles, result, runtime_state)
		in_play_id = StringName(pair.get("in_play_role_id", &""))
		not_in_play_id = StringName(pair.get("not_in_play_role_id", &""))
	var validation: Dictionary = (
		validate_mailman_pair_current(case_definition, runtime_state, result.suspect_id, in_play_id, not_in_play_id, result.truth_mode, roles)
		if runtime_state != null
		else validate_mailman_pair(case_definition, result.suspect_id, in_play_id, not_in_play_id, result.truth_mode, roles)
	)
	result.payload_kind = InvestigationInformationResult.PayloadKind.ROLE_PLAY_CLAIM
	result.in_play_role_id = in_play_id
	result.not_in_play_role_id = not_in_play_id
	result.claimed_in_play_is_true = bool(validation.get("in_play_truth", false))
	result.claimed_not_in_play_is_true = bool(validation.get("not_in_play_truth", false))
	result.text = "%s đang ở trong cung, ta chưa từng nghe đến %s." % [
		_role_display_name(roles, in_play_id),
		_role_display_name(roles, not_in_play_id),
	]


func _evaluate_blood_hound(case_definition: CaseDefinition, result: InvestigationInformationResult, runtime_state: CaseRuntimeState = null) -> void:
	var truthful: Dictionary = CaseSpatialService.new().blood_hound_truthful_outcome(case_definition, result.suspect_id)
	var outcome: StringName = StringName(truthful.get("outcome", CaseSpatialService.BLOOD_HOUND_SNIFF))
	if result.truth_mode == InvestigationInformationResult.TruthMode.LYING:
		outcome = _blood_hound_lie_outcome(case_definition, runtime_state, result.suspect_id, outcome)
	_apply_blood_hound_outcome(result, outcome)


func _evaluate_mathematician(case_definition: CaseDefinition, suspect: SuspectDefinition, result: InvestigationInformationResult) -> void:
	var true_sum: int = true_evil_suspect_number_sum(case_definition)
	result.payload_kind = InvestigationInformationResult.PayloadKind.NUMBER
	result.numeric_value = true_sum
	if result.truth_mode == InvestigationInformationResult.TruthMode.LYING:
		result.numeric_value = _authored_or_default_incorrect_mathematician_sum(suspect, true_sum)
	result.text = "Tổng Số Hiệu của Phe Ác là %d." % result.numeric_value


func _evaluate_weatherman(case_definition: CaseDefinition, suspect: SuspectDefinition, result: InvestigationInformationResult, roles: Array[RoleDefinition], runtime_state: CaseRuntimeState) -> void:
	if _first_weather_group_suspect_id(case_definition, CaseEnums.RoleGroup.HIEU_SU, roles, runtime_state) == 0:
		_apply_weatherman_no_meddler_claim(case_definition, result, _no_meddler_weatherman_ids(case_definition, suspect, roles, runtime_state), roles, runtime_state)
		return
	if result.truth_mode == InvestigationInformationResult.TruthMode.LYING:
		_apply_weatherman_claim(case_definition, result, _lying_weatherman_ids(case_definition, roles, runtime_state), roles, runtime_state)
		return
	_apply_weatherman_claim(case_definition, result, _truthful_weatherman_ids(case_definition, suspect, roles, runtime_state), roles, runtime_state)


func _evaluate_clock_maker(case_definition: CaseDefinition, suspect: SuspectDefinition, result: InvestigationInformationResult) -> void:
	var tower: ClockTowerDefinition = ClockTowerService.clock_tower_for_case(case_definition)
	result.payload_kind = InvestigationInformationResult.PayloadKind.TEXT
	if tower == null:
		result.text = "Không có Tháp Đồng Hồ trong Kỳ Án."
		return
	if result.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL:
		result.numeric_value = tower.ring_hour
		result.text = "Tháp Đồng Hồ sẽ reo từ %s." % ClockTowerService.ring_interval_text(tower)
		return
	var false_start_hour: int = _authored_clock_maker_false_start_hour(suspect, tower)
	result.numeric_value = false_start_hour
	result.text = "Tháp Đồng Hồ sẽ không reo từ %dh đến %dh." % [false_start_hour, false_start_hour + 1]


func _authored_clock_maker_false_start_hour(suspect: SuspectDefinition, tower: ClockTowerDefinition) -> int:
	if suspect != null and ClockTowerService.false_interval_is_valid(tower, suspect.authored_lie_numeric_value):
		return suspect.authored_lie_numeric_value
	for hour: int in range(1, 24):
		if ClockTowerService.false_interval_is_valid(tower, hour):
			return hour
	return 1


func _apply_weatherman_claim(case_definition: CaseDefinition, result: InvestigationInformationResult, ids: PackedInt32Array, roles: Array[RoleDefinition], runtime_state: CaseRuntimeState) -> void:
	result.payload_kind = InvestigationInformationResult.PayloadKind.WEATHER_REPORT
	result.weather_suspect_ids = ids.duplicate()
	result.weather_group_slots = _weather_groups_for_ids(case_definition, ids, roles, runtime_state)
	result.weather_claim_complete = ids.size() == 3
	if result.weather_claim_complete:
		var announced_ids: PackedInt32Array = ids.duplicate()
		announced_ids.sort()
		result.text = "Ta thấy Số Hiệu %d, %d và %d." % [announced_ids[0], announced_ids[1], announced_ids[2]]
	else:
		result.text = "Ta không thấy đủ ba dấu hiệu thời tiết."


func _apply_weatherman_no_meddler_claim(case_definition: CaseDefinition, result: InvestigationInformationResult, ids: PackedInt32Array, roles: Array[RoleDefinition], runtime_state: CaseRuntimeState) -> void:
	result.payload_kind = InvestigationInformationResult.PayloadKind.NO_MEDDLER_FOUND
	result.weather_suspect_ids = ids.duplicate()
	result.weather_group_slots = _weather_groups_for_ids(case_definition, ids, roles, runtime_state)
	result.weather_claim_complete = false
	if ids.size() == 2:
		result.text = "Không có Kẻ Bao Đồng; Số Hiệu %d và %d." % [ids[0], ids[1]]
	else:
		result.text = "Không có Kẻ Bao Đồng trong Kỳ Án."


func _truthful_weatherman_ids(case_definition: CaseDefinition, suspect: SuspectDefinition, roles: Array[RoleDefinition], runtime_state: CaseRuntimeState) -> PackedInt32Array:
	var ids: PackedInt32Array = PackedInt32Array()
	var exclude_self_from_innocent: bool = (
		suspect != null
		and _role_id_in(suspect.true_role_id, WEATHERMAN_ROLE_IDS)
		and suspect.role_group == CaseEnums.RoleGroup.CHINH_NHAN
	)
	var excluded_innocent_id: int = 0
	if exclude_self_from_innocent:
		excluded_innocent_id = suspect.suspect_id
	ids.append(_first_weather_group_suspect_id(case_definition, CaseEnums.RoleGroup.CHINH_NHAN, roles, runtime_state, excluded_innocent_id))
	ids.append(_first_weather_evil_suspect_id(case_definition, roles, runtime_state))
	ids.append(_first_weather_group_suspect_id(case_definition, CaseEnums.RoleGroup.HIEU_SU, roles, runtime_state))
	if ids.has(0):
		return PackedInt32Array()
	return ids


func _no_meddler_weatherman_ids(case_definition: CaseDefinition, suspect: SuspectDefinition, roles: Array[RoleDefinition], runtime_state: CaseRuntimeState) -> PackedInt32Array:
	var ids: PackedInt32Array = PackedInt32Array()
	var exclude_self_from_innocent: bool = (
		suspect != null
		and _role_id_in(suspect.true_role_id, WEATHERMAN_ROLE_IDS)
		and suspect.role_group == CaseEnums.RoleGroup.CHINH_NHAN
	)
	var excluded_innocent_id: int = 0
	if exclude_self_from_innocent:
		excluded_innocent_id = suspect.suspect_id
	ids.append(_first_weather_group_suspect_id(case_definition, CaseEnums.RoleGroup.CHINH_NHAN, roles, runtime_state, excluded_innocent_id))
	ids.append(_first_weather_evil_suspect_id(case_definition, roles, runtime_state))
	if ids.has(0):
		return PackedInt32Array()
	return ids


func _lying_weatherman_ids(case_definition: CaseDefinition, roles: Array[RoleDefinition], runtime_state: CaseRuntimeState) -> PackedInt32Array:
	var ids: PackedInt32Array = PackedInt32Array()
	var allowed_groups: PackedInt32Array = PackedInt32Array([
		CaseEnums.RoleGroup.CHINH_NHAN,
		CaseEnums.RoleGroup.HIEU_SU,
	])
	for suspect: SuspectDefinition in _suspects_by_number(case_definition):
		if suspect != null and _weather_group_for_suspect(suspect, roles, runtime_state) in allowed_groups:
			ids.append(suspect.suspect_id)
			if ids.size() == 3:
				return ids
	return PackedInt32Array()


func _weather_group_for_suspect(suspect: SuspectDefinition, roles: Array[RoleDefinition], runtime_state: CaseRuntimeState) -> int:
	if suspect == null:
		return -1
	if runtime_state != null:
		var runtime_suspect: SuspectRuntimeState = runtime_state.find_suspect(suspect.suspect_id)
		var current_role_id: StringName = suspect.true_role_id
		if runtime_suspect != null and not String(runtime_suspect.current_role_id).is_empty():
			current_role_id = runtime_suspect.current_role_id
		for role: RoleDefinition in roles:
			if role != null and role.role_id == current_role_id:
				return role.role_group
	return suspect.role_group


func _first_weather_group_suspect_id(case_definition: CaseDefinition, group: int, roles: Array[RoleDefinition], runtime_state: CaseRuntimeState, exclude_suspect_id: int = 0) -> int:
	for candidate: SuspectDefinition in _suspects_by_number(case_definition):
		if candidate != null and candidate.suspect_id != exclude_suspect_id and _weather_group_for_suspect(candidate, roles, runtime_state) == group:
			return candidate.suspect_id
	return 0


func _first_weather_evil_suspect_id(case_definition: CaseDefinition, roles: Array[RoleDefinition], runtime_state: CaseRuntimeState) -> int:
	var underling_id: int = _first_weather_group_suspect_id(case_definition, CaseEnums.RoleGroup.TONG_PHAM, roles, runtime_state)
	if underling_id != 0:
		return underling_id
	return _first_weather_group_suspect_id(case_definition, CaseEnums.RoleGroup.NGHICH_THAN, roles, runtime_state)


func _weather_groups_for_ids(case_definition: CaseDefinition, ids: PackedInt32Array, roles: Array[RoleDefinition], runtime_state: CaseRuntimeState) -> PackedInt32Array:
	var groups: PackedInt32Array = PackedInt32Array()
	for suspect_id: int in ids:
		groups.append(_weather_group_for_suspect(_find_suspect(case_definition, suspect_id), roles, runtime_state))
	return groups


func true_evil_suspect_number_sum(case_definition: CaseDefinition) -> int:
	var total: int = 0
	if case_definition == null:
		return total
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect != null and suspect.true_alignment == CaseEnums.Alignment.EVIL:
			total += suspect.suspect_id
	return total


func case_has_true_group(case_definition: CaseDefinition, group: int) -> bool:
	return _first_true_group_suspect_id(case_definition, group) != 0


func weatherman_claim_matches_truthful_pattern(case_definition: CaseDefinition, result: InvestigationInformationResult) -> bool:
	if case_definition == null or result == null or result.weather_suspect_ids.size() != 3:
		return false
	var seen_ids: Dictionary = {}
	var innocent_count: int = 0
	var meddler_count: int = 0
	var evil_count: int = 0
	for suspect_id: int in result.weather_suspect_ids:
		if seen_ids.has(suspect_id):
			return false
		seen_ids[suspect_id] = true
		var suspect: SuspectDefinition = _find_suspect(case_definition, suspect_id)
		if suspect == null:
			return false
		match suspect.role_group:
			CaseEnums.RoleGroup.CHINH_NHAN:
				innocent_count += 1
			CaseEnums.RoleGroup.HIEU_SU:
				meddler_count += 1
			CaseEnums.RoleGroup.TONG_PHAM, CaseEnums.RoleGroup.NGHICH_THAN:
				evil_count += 1
			_:
				return false
	return innocent_count == 1 and meddler_count == 1 and evil_count == 1


func mathematician_deviation_limit(true_sum: int) -> int:
	if true_sum <= 11:
		return 4
	if true_sum >= 29:
		return 10
	return maxi(1, int(floor(float(true_sum) * 0.35)))


func _authored_or_default_incorrect_mathematician_sum(suspect: SuspectDefinition, true_sum: int) -> int:
	var deviation_limit: int = mathematician_deviation_limit(true_sum)
	if suspect != null:
		var authored_value: int = suspect.authored_lie_numeric_value
		var authored_delta: int = absi(authored_value - true_sum)
		if authored_value >= 0 and authored_value != true_sum and authored_delta <= deviation_limit:
			return authored_value
	return _incorrect_mathematician_sum(true_sum, deviation_limit)


func _incorrect_mathematician_sum(true_sum: int, deviation_limit: int) -> int:
	var lower: int = maxi(0, true_sum - 1)
	if lower != true_sum and absi(lower - true_sum) <= deviation_limit:
		return lower
	var higher: int = true_sum + 1
	if absi(higher - true_sum) <= deviation_limit:
		return higher
	return true_sum + deviation_limit


func _first_true_group_suspect_id(case_definition: CaseDefinition, group: int, exclude_suspect_id: int = 0) -> int:
	for suspect: SuspectDefinition in _suspects_by_number(case_definition):
		if suspect != null and suspect.suspect_id != exclude_suspect_id and suspect.role_group == group:
			return suspect.suspect_id
	return 0


func _first_true_evil_group_suspect_id(case_definition: CaseDefinition) -> int:
	var underling_id: int = _first_true_group_suspect_id(case_definition, CaseEnums.RoleGroup.TONG_PHAM)
	if underling_id != 0:
		return underling_id
	var traitor_id: int = _first_true_group_suspect_id(case_definition, CaseEnums.RoleGroup.NGHICH_THAN)
	if traitor_id != 0:
		return traitor_id
	for suspect: SuspectDefinition in _suspects_by_number(case_definition):
		if suspect != null and _is_evil_role_group(suspect.role_group):
			return suspect.suspect_id
	return 0


func _suspect_has_true_group(case_definition: CaseDefinition, suspect_id: int, group: int) -> bool:
	var suspect: SuspectDefinition = _find_suspect(case_definition, suspect_id)
	return suspect != null and suspect.role_group == group


func _suspect_has_true_evil_group(case_definition: CaseDefinition, suspect_id: int) -> bool:
	var suspect: SuspectDefinition = _find_suspect(case_definition, suspect_id)
	return suspect != null and _is_evil_role_group(suspect.role_group)


func _is_evil_role_group(group: int) -> bool:
	return group == CaseEnums.RoleGroup.TONG_PHAM or group == CaseEnums.RoleGroup.NGHICH_THAN


func _true_groups_for_ids(case_definition: CaseDefinition, ids: PackedInt32Array) -> PackedInt32Array:
	var groups: PackedInt32Array = PackedInt32Array()
	for suspect_id: int in ids:
		var suspect: SuspectDefinition = _find_suspect(case_definition, suspect_id)
		groups.append(int(suspect.role_group) if suspect != null else -1)
	return groups


func _suspects_by_number(case_definition: CaseDefinition) -> Array[SuspectDefinition]:
	var suspects: Array[SuspectDefinition] = []
	if case_definition == null:
		return suspects
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect != null:
			suspects.append(suspect)
	suspects.sort_custom(func(first: SuspectDefinition, second: SuspectDefinition) -> bool:
		return first.suspect_id < second.suspect_id
	)
	return suspects


func _default_mailman_pair(
	case_definition: CaseDefinition,
	roles: Array[RoleDefinition],
	result: InvestigationInformationResult,
	runtime_state: CaseRuntimeState = null
) -> Dictionary:
	var in_play_roles: Array[StringName] = (
		current_role_ids_in_play(case_definition, runtime_state, result.suspect_id)
		if runtime_state != null
		else true_role_ids_in_play(case_definition, result.suspect_id)
	)
	var not_in_play_roles: Array[StringName] = (
		current_role_ids_not_in_play(case_definition, runtime_state, roles, result.behavior_role_id)
		if runtime_state != null
		else true_role_ids_not_in_play(case_definition, roles, result.behavior_role_id)
	)
	if result.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL:
		return {
			"in_play_role_id": in_play_roles[0] if not in_play_roles.is_empty() else &"",
			"not_in_play_role_id": not_in_play_roles[0] if not not_in_play_roles.is_empty() else &"",
		}
	return {
		"in_play_role_id": not_in_play_roles[0] if not not_in_play_roles.is_empty() else &"",
		"not_in_play_role_id": in_play_roles[0] if not in_play_roles.is_empty() else &"",
	}


func _apply_blood_hound_outcome(result: InvestigationInformationResult, outcome: StringName) -> void:
	result.payload_kind = InvestigationInformationResult.PayloadKind.BLOOD_HOUND_CLUE
	result.direction_key = outcome
	match outcome:
		CaseSpatialService.DIRECTION_NORTH, CaseSpatialService.DIRECTION_EAST, CaseSpatialService.DIRECTION_SOUTH, CaseSpatialService.DIRECTION_WEST:
			result.text = "*Chỉ về phía %s*" % _direction_label(outcome)
		CaseSpatialService.BLOOD_HOUND_BARK:
			result.text = "*sủa*"
		CaseSpatialService.BLOOD_HOUND_SNIFF:
			result.text = "*nằm im*"
		_:
			result.direction_key = CaseSpatialService.BLOOD_HOUND_SNIFF
			result.text = "*nằm im*"


func _blood_hound_lie_outcome(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, suspect_id: int, truthful_outcome: StringName) -> StringName:
	var procedural_poisoner: bool = case_definition != null and case_definition.has_meta(&"procedural_poisoner_clues")
	var procedural_barkeep: bool = case_definition != null and case_definition.has_meta(&"procedural_barkeep_clues")
	var procedural_critic: bool = case_definition != null and case_definition.has_meta(&"procedural_critic_clues")
	var stable_procedural_clue: bool = procedural_poisoner or procedural_barkeep or procedural_critic
	var procedural_source: String = "critic"
	if procedural_poisoner:
		procedural_source = "poisoner"
	elif procedural_barkeep:
		procedural_source = "barkeep"
	var seed_text: String = (
		"%s:%d:%s" % [procedural_source, suspect_id, truthful_outcome]
		if stable_procedural_clue else "%s:%d:%s" % [case_definition.case_id if case_definition != null else &"", suspect_id, truthful_outcome]
	)
	var seed_value: int = 0 if stable_procedural_clue else (runtime_state.case_event_seed if runtime_state != null else seed_text.hash())
	var start_index: int = absi(seed_value + seed_text.hash()) % BLOOD_HOUND_OUTCOMES.size()
	for offset: int in range(BLOOD_HOUND_OUTCOMES.size()):
		var candidate: StringName = BLOOD_HOUND_OUTCOMES[(start_index + offset) % BLOOD_HOUND_OUTCOMES.size()]
		if candidate != truthful_outcome:
			return candidate
	return CaseSpatialService.BLOOD_HOUND_SNIFF


func _incorrect_int(min_value: int, max_value: int, correct_value: int) -> int:
	for value in range(min_value, max_value + 1):
		var candidate: int = int(value)
		if candidate != correct_value:
			return candidate
	return min_value


func _authored_or_default_incorrect_int(suspect: SuspectDefinition, min_value: int, max_value: int, correct_value: int) -> int:
	if suspect != null:
		var authored_value: int = suspect.authored_lie_numeric_value
		if authored_value >= min_value and authored_value <= max_value and authored_value != correct_value:
			return authored_value
	return _incorrect_int(min_value, max_value, correct_value)


func _role_id_in(role_id: StringName, role_ids: Array[StringName]) -> bool:
	for candidate: StringName in role_ids:
		if role_id == candidate:
			return true
	return false


func _find_suspect(case_definition: CaseDefinition, suspect_id: int) -> SuspectDefinition:
	if case_definition == null:
		return null
	for suspect in case_definition.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null


func _role_display_name(roles: Array[RoleDefinition], role_id: StringName) -> String:
	for role in roles:
		if role != null and role.role_id == role_id:
			return role.display_name
	return String(role_id)


func _direction_label(direction: StringName) -> String:
	match direction:
		CaseSpatialService.DIRECTION_NORTH:
			return "Bắc"
		CaseSpatialService.DIRECTION_EAST:
			return "Đông"
		CaseSpatialService.DIRECTION_SOUTH:
			return "Nam"
		CaseSpatialService.DIRECTION_WEST:
			return "Tây"
		_:
			return "không rõ"


func _suspect_id_list_text(suspect_ids: PackedInt32Array) -> String:
	var parts: Array[String] = []
	for suspect_id: int in suspect_ids:
		parts.append("Số Hiệu %d" % suspect_id)
	return ", ".join(parts)
