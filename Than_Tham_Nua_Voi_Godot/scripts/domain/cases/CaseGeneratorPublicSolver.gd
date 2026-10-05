class_name CaseGeneratorPublicSolver
extends RefCounted

const SOLVER_RESULT := preload("res://scripts/domain/cases/CaseGeneratorSolverResult.gd")
const PRETEND_CAPABILITY := preload("res://scripts/domain/cases/CaseProceduralPretendCapability.gd")
const MAX_SUSPECT_COUNT := 16
const MAX_PRETEND_SUSPECT_COUNT := 9
const SUPPORTED_PUBLIC_ROLE_IDS: Array[StringName] = [
	&"tutorial_priest",
	&"priest",
	&"reporter",
	&"therapist",
	&"weatherman",
	&"blood_hound",
	&"mathematician",
	&"mailman",
	&"role_meddler_a",
	&"tutorial_mobster",
	&"mobster",
	&"copycat",
	&"conman",
	&"spectre",
	&"tutorial_scoundrel",
	&"tailor", # Native, silent until the player executes its runtime function.
	&"vigilante", # Native; future player-selected kills are not acceptance evidence.
	&"clock_maker",
	&"surgeon", # Native, silent; the future 12h timed outcome is runtime-only.
	&"serial_killer", # Pretender; future 9h timed outcomes are runtime-only.
	&"critic", # Dedicated listed-but-current-absent lying disguise hypothesis.
]
const EARLY_EVIL_CLUE_ROLE_IDS: Array[StringName] = [
	&"tutorial_priest", &"priest", &"reporter", &"therapist", &"mathematician",
]

var _audit_initial_sets: Dictionary = {}
var _audit_clue_sets: Array[Dictionary] = []

# M6B search diagnostics; counters are scoped and reset for every solve() call.
var _diag_active: bool = false
var _diag_id: int = 0
var _diag_started_usec: int = 0
var _diag_evil_sets: int = 0
var _diag_target_candidates: int = 0
var _diag_transform_targets: int = 0
var _diag_fake_role_candidates: int = 0
var _diag_barkeep_source_assignments: int = 0
var _diag_role_assignments: int = 0
var _diag_pretend_assignments: int = 0
var _diag_structural_prunes: int = 0
var _diag_leaf_structural_rejects: int = 0
var _diag_fixed_clue_prunes: int = 0
var _diag_natural_target_prunes: int = 0
var _diag_worlds_before_replay: int = 0
var _diag_worlds_replayed: int = 0
var _diag_poisoner_hypotheses: int = 0
var _diag_transform_attempts: int = 0
var _diag_transform_applied: int = 0
var _diag_spectre_target_assignments: int = 0
var _diag_spectre_pretend_assignments: int = 0
var _diag_natural_target_set_prunes: int = 0
var _diag_remaining_role_set_prunes: int = 0
var _diag_evil_support_set_prunes: int = 0
var _diag_preflight_clue_evaluations: int = 0
var _diag_clue_evaluations: int = 0
var _diag_max_depth: int = 0
var _diag_max_role_options: int = 0
var _diag_max_poisoner_targets: int = 0
var _diag_suspects: int = 0
var _diag_evil_count: int = 0
var _diag_clues: int = 0


func solve(public_view, roles: Array[RoleDefinition] = []):
	var result: CaseGeneratorSolverResult = SOLVER_RESULT.new()
	_diag_begin(public_view)
	_audit_initial_sets.clear()
	_audit_clue_sets.clear()
	if public_view == null:
		result.mark_unsupported("Public case view is null.")
		return _finish_solve(result)
	if public_view.suspects.size() > MAX_SUSPECT_COUNT:
		result.mark_unsupported("Public case view exceeds the M2 exhaustive search bound.")
		return _finish_solve(result)
	if public_view.public_evil_count < 0 or public_view.public_evil_count > public_view.suspects.size():
		result.mark_unsupported("Public Evil count is outside the suspect range.")
		return _finish_solve(result)
	var unsupported_reason: String = _unsupported_reason(public_view)
	if not unsupported_reason.is_empty():
		result.mark_unsupported(unsupported_reason)
		return _finish_solve(result)
	for _clue in public_view.public_clues:
		_audit_clue_sets.append({})
	var suspect_ids: PackedInt32Array = public_view.suspect_ids()
	result.raw_evil_set_count = _raw_evil_set_count(suspect_ids.size(), public_view.public_evil_count)
	var candidates: Array = []
	if not _clock_location_is_valid(public_view):
		result.set_candidates(candidates)
		return _finish_solve(result)
	if _has_pretend_candidates(public_view):
		if public_view.suspects.size() > MAX_PRETEND_SUSPECT_COUNT:
			result.mark_unsupported("Pretend-world search exceeds the nine-suspect bound.")
			return _finish_solve(result)
		_collect_pretend_candidates(public_view, roles, suspect_ids, public_view.public_evil_count, 0, PackedInt32Array(), candidates)
	else:
		_collect_candidates(public_view, roles, suspect_ids, public_view.public_evil_count, 0, PackedInt32Array(), candidates)
	result.set_candidates(candidates)
	result.initial_candidate_count = _audit_initial_sets.size()
	result.pre_replay_evil_sets = _audit_evil_sets(_audit_initial_sets)
	for surviving_sets: Dictionary in _audit_clue_sets:
		result.remaining_candidate_counts.append(surviving_sets.size())
		result.replay_evil_sets_after_clues.append(_audit_evil_sets(surviving_sets))
	return _finish_solve(result)


func _finish_solve(result: CaseGeneratorSolverResult) -> CaseGeneratorSolverResult:
	result.performance_diagnostics = _diag_finish()
	return result


func _raw_evil_set_count(suspect_count: int, evil_count: int) -> int:
	if evil_count < 0 or evil_count > suspect_count:
		return 0
	var choose_count: int = mini(evil_count, suspect_count - evil_count)
	var combinations: int = 1
	for step: int in range(1, choose_count + 1):
		combinations = int(combinations * (suspect_count - choose_count + step) / step)
	return combinations


func _audit_evil_sets(by_signature: Dictionary) -> Array:
	var signatures: Array = by_signature.keys()
	signatures.sort()
	var sets: Array = []
	for signature: String in signatures:
		var ids: PackedInt32Array = by_signature[signature]
		sets.append(ids.duplicate())
	return sets


func _diag_begin(public_view) -> void:
	_diag_active = true
	_diag_id = Time.get_ticks_usec()
	_diag_started_usec = _diag_id
	_diag_evil_sets = 0
	_diag_target_candidates = 0
	_diag_transform_targets = 0
	_diag_fake_role_candidates = 0
	_diag_barkeep_source_assignments = 0
	_diag_role_assignments = 0
	_diag_pretend_assignments = 0
	_diag_structural_prunes = 0
	_diag_leaf_structural_rejects = 0
	_diag_fixed_clue_prunes = 0
	_diag_natural_target_prunes = 0
	_diag_worlds_before_replay = 0
	_diag_worlds_replayed = 0
	_diag_poisoner_hypotheses = 0
	_diag_transform_attempts = 0
	_diag_transform_applied = 0
	_diag_spectre_target_assignments = 0
	_diag_spectre_pretend_assignments = 0
	_diag_natural_target_set_prunes = 0
	_diag_remaining_role_set_prunes = 0
	_diag_evil_support_set_prunes = 0
	_diag_preflight_clue_evaluations = 0
	_diag_clue_evaluations = 0
	_diag_max_depth = 0
	_diag_max_role_options = 0
	_diag_max_poisoner_targets = 0
	_diag_suspects = public_view.suspects.size() if public_view != null else 0
	_diag_evil_count = public_view.public_evil_count if public_view != null else 0
	_diag_clues = public_view.public_clues.size() if public_view != null else 0
	print("M6B_SOLVER_DIAG id=%d stage=begin suspects=%d evil=%d clues=%d" % [
		_diag_id, _diag_suspects, _diag_evil_count, _diag_clues,
	])


func _diag_finish() -> Dictionary:
	if not _diag_active:
		return {}
	var elapsed_ms: int = int((Time.get_ticks_usec() - _diag_started_usec) / 1000)
	var diagnostics: Dictionary = {
		"solve_id": _diag_id,
		"elapsed_ms": elapsed_ms,
		"evil_sets": _diag_evil_sets,
		"target_candidates": _diag_target_candidates,
		"fake_role_candidates": _diag_fake_role_candidates,
		"role_assignments": _diag_role_assignments,
		"pretend_assignments": _diag_pretend_assignments,
		"barkeep_targets": _diag_transform_targets,
		"barkeep_sources": _diag_barkeep_source_assignments,
		"barkeep_transform_attempts": _diag_transform_attempts,
		"barkeep_transform_applied": _diag_transform_applied,
		"spectre_targets": _diag_spectre_target_assignments,
		"spectre_pretends": _diag_spectre_pretend_assignments,
		"natural_target_set_prunes": _diag_natural_target_set_prunes,
		"remaining_role_set_prunes": _diag_remaining_role_set_prunes,
		"evil_support_set_prunes": _diag_evil_support_set_prunes,
		"poisoner_targets": _diag_poisoner_hypotheses,
		"worlds_before_replay": _diag_worlds_before_replay,
		"worlds_replayed": _diag_worlds_replayed,
		"preflight_clues": _diag_preflight_clue_evaluations,
		"clues_replayed": _diag_clue_evaluations,
		"structural_prunes": _diag_structural_prunes,
		"leaf_structural_rejects": _diag_leaf_structural_rejects,
		"early_clue_prunes": _diag_fixed_clue_prunes,
		"natural_target_prunes": _diag_natural_target_prunes,
	}
	_diag_emit(diagnostics)
	_diag_active = false
	return diagnostics


func _diag_emit(diagnostics: Dictionary) -> void:
	print("M6B_SOLVER_DIAG id=%d stage=end ms=%d evil_sets=%d target_candidates=%d fake_roles=%d roles=%d pretends=%d barkeep_targets=%d barkeep_sources=%d barkeep_attempts=%d barkeep_applied=%d spectre_targets=%d spectre_pretends=%d poisoner_targets=%d worlds_before_replay=%d worlds_replayed=%d preflight_clues=%d clues_replayed=%d structural_prunes=%d leaf_structural_rejects=%d early_clue_prunes=%d natural_target_prunes=%d natural_target_set_prunes=%d remaining_role_set_prunes=%d evil_support_set_prunes=%d max_depth=%d max_role_options=%d max_poisoner_targets=%d" % [
		_diag_id, int(diagnostics.get("elapsed_ms", 0)), _diag_evil_sets,
		_diag_target_candidates, _diag_fake_role_candidates, _diag_role_assignments,
		_diag_pretend_assignments, _diag_transform_targets,
		_diag_barkeep_source_assignments, _diag_transform_attempts, _diag_transform_applied,
		_diag_spectre_target_assignments, _diag_spectre_pretend_assignments,
		_diag_poisoner_hypotheses, _diag_worlds_before_replay, _diag_worlds_replayed,
		_diag_preflight_clue_evaluations, _diag_clue_evaluations, _diag_structural_prunes,
		_diag_leaf_structural_rejects, _diag_fixed_clue_prunes,
		_diag_natural_target_prunes, _diag_natural_target_set_prunes,
		_diag_remaining_role_set_prunes, _diag_evil_support_set_prunes,
		_diag_max_depth, _diag_max_role_options,
		_diag_max_poisoner_targets,
	])


func _has_pretend_candidates(public_view) -> bool:
	var possible_role_ids: Array[StringName] = _hypothesis_role_pool(public_view)
	if possible_role_ids.has(PRETEND_CAPABILITY.COPYCAT_ROLE_ID) or possible_role_ids.has(PRETEND_CAPABILITY.CONMAN_ROLE_ID) or possible_role_ids.has(PRETEND_CAPABILITY.POISONER_ROLE_ID) or possible_role_ids.has(PRETEND_CAPABILITY.BARKEEP_ROLE_ID) or possible_role_ids.has(PRETEND_CAPABILITY.SPECTRE_ROLE_ID) or possible_role_ids.has(PRETEND_CAPABILITY.SERIAL_KILLER_ROLE_ID) or possible_role_ids.has(PRETEND_CAPABILITY.CRITIC_ROLE_ID):
		return true
	for mobster_role_id: StringName in PRETEND_CAPABILITY.MOBSTER_ROLE_IDS:
		if possible_role_ids.has(mobster_role_id):
			return true
	return false


func _hypothesis_role_pool(public_view) -> Array[StringName]:
	var suspected_role_ids: Array[StringName] = public_view.suspected_role_ids
	if not suspected_role_ids.is_empty():
		return suspected_role_ids
	var allowed_role_ids: Array[StringName] = public_view.allowed_role_ids
	return allowed_role_ids


func _collect_pretend_candidates(
	public_view,
	roles: Array[RoleDefinition],
	suspect_ids: PackedInt32Array,
	remaining: int,
	start_index: int,
	current: PackedInt32Array,
	candidates: Array
) -> void:
	if remaining == 0:
		var evil_ids: PackedInt32Array = current.duplicate()
		if _evil_set_has_compatible_pretend_world(public_view, roles, evil_ids):
			candidates.append(evil_ids)
		return
	if remaining > suspect_ids.size() - start_index:
		return
	for index: int in range(start_index, suspect_ids.size()):
		current.append(suspect_ids[index])
		_collect_pretend_candidates(public_view, roles, suspect_ids, remaining - 1, index + 1, current, candidates)
		current.remove_at(current.size() - 1)


func _evil_set_has_compatible_pretend_world(
	public_view, roles: Array[RoleDefinition], evil_ids: PackedInt32Array
) -> bool:
	if _diag_active:
		_diag_evil_sets += 1
	var role_by_id: Dictionary = _roles_by_id(roles)
	# Resolve Evil sources first so a transform branch without Barkeep stops before Good-role permutations.
	var search_order: PackedInt32Array = PackedInt32Array()
	for suspect_index: int in range(public_view.suspects.size()):
		if evil_ids.has(public_view.suspects[suspect_index].suspect_id):
			search_order.append(suspect_index)
	for suspect_index: int in range(public_view.suspects.size()):
		if not evil_ids.has(public_view.suspects[suspect_index].suspect_id):
			search_order.append(suspect_index)
	if _assign_pretend_hypothesis(public_view, roles, role_by_id, evil_ids, search_order, 0, {}, {}, 0, &""):
		return true
	if not _hypothesis_role_pool(public_view).has(PRETEND_CAPABILITY.BARKEEP_ROLE_ID):
		return false
	if not _evil_set_can_host_barkeep(public_view, role_by_id, evil_ids):
		if _diag_active:
			_diag_structural_prunes += 1
		return false
	for public_suspect in public_view.suspects:
		if public_suspect != null and not evil_ids.has(public_suspect.suspect_id):
			if _diag_active:
				_diag_target_candidates += 1
			var fake_role: RoleDefinition = role_by_id.get(public_suspect.public_role_id, null) as RoleDefinition
			if fake_role == null or fake_role.is_fixture_placeholder or CaseRolePoolService.role_alignment(fake_role) != CaseEnums.Alignment.GOOD:
				if _diag_active:
					_diag_structural_prunes += 1
				continue
			if not PRETEND_CAPABILITY.is_supported_behavior(fake_role.role_id) or not _hypothesis_role_pool(public_view).has(fake_role.role_id):
				if _diag_active:
					_diag_structural_prunes += 1
				continue
			if _diag_active:
				_diag_fake_role_candidates += 1
				_diag_transform_targets += 1
			if _assign_pretend_hypothesis(public_view, roles, role_by_id, evil_ids, search_order, 0, {}, {}, public_suspect.suspect_id, fake_role.role_id):
				return true
	return false


func _evil_set_can_host_barkeep(public_view, role_by_id: Dictionary, evil_ids: PackedInt32Array) -> bool:
	for public_suspect in public_view.suspects:
		if not evil_ids.has(public_suspect.suspect_id):
			continue
		var displayed_role_id: StringName = _public_displayed_behavior_role_id(public_view, public_suspect)
		var displayed_role: RoleDefinition = role_by_id.get(displayed_role_id, null) as RoleDefinition
		if PRETEND_CAPABILITY.can_pretend_procedural(PRETEND_CAPABILITY.BARKEEP_ROLE_ID, displayed_role):
			return true
	return false


func _assign_pretend_hypothesis(
	public_view,
	roles: Array[RoleDefinition],
	role_by_id: Dictionary,
	evil_ids: PackedInt32Array,
	search_order: PackedInt32Array,
	index: int,
	assigned: Dictionary,
	used_roles: Dictionary,
	transform_target_id: int,
	transform_fake_role_id: StringName
) -> bool:
	if _diag_active:
		_diag_max_depth = maxi(_diag_max_depth, index)
	if transform_target_id > 0 and index >= evil_ids.size() and not used_roles.has(PRETEND_CAPABILITY.BARKEEP_ROLE_ID):
		if _diag_active:
			_diag_structural_prunes += 1
		return false
	var obscured_target_id: int = _public_obscured_target_id(public_view)
	if index == evil_ids.size():
		if (obscured_target_id > 0) != used_roles.has(PRETEND_CAPABILITY.SPECTRE_ROLE_ID):
			if _diag_active:
				_diag_structural_prunes += 1
			return false
		if not _required_natural_targets_can_still_fit(
			public_view, role_by_id, evil_ids, assigned, used_roles,
			transform_target_id, transform_fake_role_id
		):
			if _diag_active:
				_diag_natural_target_set_prunes += 1
				_diag_structural_prunes += 1
			return false
		if not _remaining_good_roles_can_still_fit(
			public_view, role_by_id, evil_ids, assigned, used_roles,
			transform_target_id, transform_fake_role_id
		):
			if _diag_active:
				_diag_remaining_role_set_prunes += 1
				_diag_structural_prunes += 1
			return false
	if index == evil_ids.size():
		if not _fixed_clues_can_match(public_view, roles, evil_ids, assigned, transform_target_id, used_roles.has(PRETEND_CAPABILITY.POISONER_ROLE_ID)):
			if _diag_active:
				_diag_fixed_clue_prunes += 1
			return false
	if index == public_view.suspects.size():
		var barkeep_id: int = 0
		for public_suspect in public_view.suspects:
			var true_role_id: StringName = StringName(assigned.get(public_suspect.suspect_id, &""))
			var assigned_displayed_role_id: StringName = _public_displayed_behavior_role_id(public_view, public_suspect)
			if true_role_id == PRETEND_CAPABILITY.BARKEEP_ROLE_ID:
				barkeep_id = public_suspect.suspect_id
			if not PRETEND_CAPABILITY.is_pretender(true_role_id):
				continue
			if true_role_id == PRETEND_CAPABILITY.POISONER_ROLE_ID or true_role_id == PRETEND_CAPABILITY.BARKEEP_ROLE_ID:
				if not _hypothesis_role_pool(public_view).has(assigned_displayed_role_id):
					if _diag_active:
						_diag_leaf_structural_rejects += 1
					return false
				continue
			if true_role_id == PRETEND_CAPABILITY.CRITIC_ROLE_ID:
				if not _critic_hypothesis_is_valid(
					public_view, assigned, public_suspect.suspect_id,
					assigned_displayed_role_id, transform_target_id
				):
					if _diag_active:
						_diag_leaf_structural_rejects += 1
					return false
				continue
			if PRETEND_CAPABILITY.behavior_requires_current_native_witness(
				assigned_displayed_role_id
			):
				if not _assigned_current_native_witness_is_satisfied(
					public_view, assigned, public_suspect.suspect_id,
					assigned_displayed_role_id, transform_target_id
				):
					if _diag_active:
						_diag_leaf_structural_rejects += 1
					return false
				continue
			var natural_target_found: bool = false
			for other in public_view.suspects:
				if _natural_witness_must_remain_current(true_role_id, assigned_displayed_role_id) and other.suspect_id == transform_target_id:
					continue
				if other.suspect_id != public_suspect.suspect_id and assigned.get(other.suspect_id, &"") == assigned_displayed_role_id:
					natural_target_found = true
					break
			if not natural_target_found:
				if _diag_active:
					_diag_leaf_structural_rejects += 1
				return false
		if (barkeep_id > 0) != (transform_target_id > 0):
			if _diag_active:
				_diag_structural_prunes += 1
				_diag_leaf_structural_rejects += 1
			return false
		if not _spectre_hypothesis_is_valid(public_view, role_by_id, assigned, transform_target_id):
			if _diag_active:
				_diag_structural_prunes += 1
				_diag_leaf_structural_rejects += 1
			return false
		if not _serial_killer_hypothesis_is_valid(public_view, role_by_id, assigned, transform_target_id):
			if _diag_active:
				_diag_structural_prunes += 1
				_diag_leaf_structural_rejects += 1
			return false
		return _candidate_matches_public_clues(public_view, roles, evil_ids, assigned, transform_target_id, barkeep_id)
	var public_suspect = public_view.suspects[search_order[index]]
	var displayed_role_id: StringName = _public_displayed_behavior_role_id(public_view, public_suspect)
	var displayed_role: RoleDefinition = role_by_id.get(displayed_role_id, null) as RoleDefinition
	if displayed_role == null:
		return false
	var possible_roles: Array[StringName] = [displayed_role_id]
	var pretender_role_ids: Array[StringName] = [
		PRETEND_CAPABILITY.COPYCAT_ROLE_ID,
		PRETEND_CAPABILITY.CONMAN_ROLE_ID,
		PRETEND_CAPABILITY.POISONER_ROLE_ID,
		PRETEND_CAPABILITY.BARKEEP_ROLE_ID,
		PRETEND_CAPABILITY.SPECTRE_ROLE_ID,
		PRETEND_CAPABILITY.SERIAL_KILLER_ROLE_ID,
		PRETEND_CAPABILITY.CRITIC_ROLE_ID,
		&"tutorial_mobster",
		&"mobster",
	]
	var possible_role_ids: Array[StringName] = _hypothesis_role_pool(public_view)
	for pretender_role_id: StringName in pretender_role_ids:
		if possible_role_ids.has(pretender_role_id) and PRETEND_CAPABILITY.can_pretend_procedural(pretender_role_id, displayed_role):
			possible_roles.append(pretender_role_id)
	if public_suspect.suspect_id == transform_target_id and CaseRolePoolService.role_alignment(displayed_role) == CaseEnums.Alignment.GOOD:
		for role_id: StringName in possible_role_ids:
			var original_role: RoleDefinition = role_by_id.get(role_id, null) as RoleDefinition
			if original_role != null and original_role.role_group == CaseEnums.RoleGroup.CHINH_NHAN and not possible_roles.has(role_id):
				possible_roles.append(role_id)
	if _diag_active:
		_diag_max_role_options = maxi(_diag_max_role_options, possible_roles.size())
	for true_role_id: StringName in possible_roles:
		if used_roles.has(true_role_id) or not possible_role_ids.has(true_role_id):
			continue
		if transform_target_id > 0 and public_suspect.suspect_id != transform_target_id and true_role_id == transform_fake_role_id:
			continue
		if transform_target_id == 0 and true_role_id == PRETEND_CAPABILITY.BARKEEP_ROLE_ID:
			continue
		if PRETEND_CAPABILITY.is_pretender(true_role_id) and true_role_id == displayed_role_id:
			continue
		if true_role_id == PRETEND_CAPABILITY.SPECTRE_ROLE_ID and obscured_target_id <= 0:
			continue
		var true_role: RoleDefinition = role_by_id.get(true_role_id, null) as RoleDefinition
		if true_role == null:
			continue
		if public_suspect.suspect_id == transform_target_id and true_role.role_group != CaseEnums.RoleGroup.CHINH_NHAN:
			continue
		var true_evil: bool = CaseRolePoolService.role_alignment(true_role) == CaseEnums.Alignment.EVIL
		if true_evil != evil_ids.has(public_suspect.suspect_id):
			continue
		if PRETEND_CAPABILITY.is_pretender(true_role_id):
			if true_role_id == PRETEND_CAPABILITY.POISONER_ROLE_ID or true_role_id == PRETEND_CAPABILITY.BARKEEP_ROLE_ID:
				if not possible_role_ids.has(displayed_role_id):
					if _diag_active:
						_diag_structural_prunes += 1
					continue
			elif true_role_id == PRETEND_CAPABILITY.CRITIC_ROLE_ID:
				var critic_displayed_role: RoleDefinition = role_by_id.get(displayed_role_id, null) as RoleDefinition
				if not possible_role_ids.has(displayed_role_id) or not PRETEND_CAPABILITY.can_pretend_procedural(PRETEND_CAPABILITY.CRITIC_ROLE_ID, critic_displayed_role):
					if _diag_active:
						_diag_structural_prunes += 1
					continue
			elif not possible_role_ids.has(displayed_role_id) or not _partial_natural_target_possible(
				public_view, role_by_id, evil_ids, assigned, public_suspect.suspect_id,
				displayed_role_id, transform_target_id, transform_fake_role_id
			):
				if _diag_active:
					_diag_natural_target_prunes += 1
				continue
		assigned[public_suspect.suspect_id] = true_role_id
		used_roles[true_role_id] = true
		# All supported natural witnesses are Good roles. If the witnesses already
		# required by this partial Evil assignment cannot fit the fixed Good side,
		# no later Evil pretender or mutation assignment can restore feasibility.
		if index + 1 < evil_ids.size() and not _required_natural_targets_can_still_fit(
			public_view, role_by_id, evil_ids, assigned, used_roles,
			transform_target_id, transform_fake_role_id
		):
			if _diag_active:
				_diag_evil_support_set_prunes += 1
				_diag_structural_prunes += 1
			assigned.erase(public_suspect.suspect_id)
			used_roles.erase(true_role_id)
			continue
		if _diag_active:
			_diag_role_assignments += 1
			if PRETEND_CAPABILITY.is_pretender(true_role_id):
				_diag_pretend_assignments += 1
			if transform_target_id > 0 and true_role_id == PRETEND_CAPABILITY.BARKEEP_ROLE_ID:
				_diag_barkeep_source_assignments += 1
			if true_role_id == PRETEND_CAPABILITY.SPECTRE_ROLE_ID:
				_diag_spectre_pretend_assignments += 1
				if obscured_target_id > 0:
					_diag_spectre_target_assignments += 1
		if _assign_pretend_hypothesis(public_view, roles, role_by_id, evil_ids, search_order, index + 1, assigned, used_roles, transform_target_id, transform_fake_role_id):
			return true
		assigned.erase(public_suspect.suspect_id)
		used_roles.erase(true_role_id)
	return false


func _partial_natural_target_possible(
	public_view, role_by_id: Dictionary, evil_ids: PackedInt32Array,
	assigned: Dictionary, source_id: int, required_role_id: StringName,
	transform_target_id: int, transform_fake_role_id: StringName
) -> bool:
	var required_role: RoleDefinition = role_by_id.get(required_role_id, null) as RoleDefinition
	if required_role == null:
		return false
	var source_true_role_id: StringName = StringName(assigned.get(source_id, &""))
	var current_witness_required: bool = _natural_witness_must_remain_current(
		source_true_role_id, required_role_id
	)
	for other in public_view.suspects:
		if other.suspect_id == source_id:
			continue
		if current_witness_required and other.suspect_id == transform_target_id:
			continue
		if assigned.has(other.suspect_id):
			if assigned[other.suspect_id] == required_role_id:
				return true
			continue
		if evil_ids.has(other.suspect_id):
			continue
		if other.suspect_id == transform_target_id:
			if required_role.role_group == CaseEnums.RoleGroup.CHINH_NHAN:
				return true
		elif _public_displayed_behavior_role_id(public_view, other) == required_role_id:
			if transform_target_id == 0 or required_role_id != transform_fake_role_id:
				return true
	return false


func _required_natural_targets_can_still_fit(
	public_view, role_by_id: Dictionary, evil_ids: PackedInt32Array,
	assigned: Dictionary, used_roles: Dictionary,
	transform_target_id: int, transform_fake_role_id: StringName
) -> bool:
	var required_roles: Array[StringName] = []
	var current_witness_required_by_role: Dictionary = {}
	for source_id: Variant in assigned:
		var true_role_id: StringName = StringName(assigned[source_id])
		if not PRETEND_CAPABILITY.is_pretender(true_role_id):
			continue
		if true_role_id == PRETEND_CAPABILITY.POISONER_ROLE_ID or true_role_id == PRETEND_CAPABILITY.BARKEEP_ROLE_ID or true_role_id == PRETEND_CAPABILITY.CRITIC_ROLE_ID:
			continue
		var source: Variant = _public_suspect_by_id(public_view, int(source_id))
		var required_role_id: StringName = _public_displayed_behavior_role_id(public_view, source)
		if String(required_role_id).is_empty():
			return false
		var already_satisfied: bool = false
		for other_id: Variant in assigned:
			if (
				int(other_id) != int(source_id)
				and StringName(assigned[other_id]) == required_role_id
				and not (
					_natural_witness_must_remain_current(true_role_id, required_role_id)
					and int(other_id) == transform_target_id
				)
			):
				already_satisfied = true
				break
		if not already_satisfied:
			if not required_roles.has(required_role_id):
				required_roles.append(required_role_id)
			if _natural_witness_must_remain_current(true_role_id, required_role_id):
				current_witness_required_by_role[required_role_id] = true
	if required_roles.is_empty():
		return true
	var candidates_by_role: Dictionary = {}
	for required_role_id: StringName in required_roles:
		if used_roles.has(required_role_id):
			return false
		var required_role: RoleDefinition = role_by_id.get(required_role_id, null) as RoleDefinition
		if required_role == null or CaseRolePoolService.role_alignment(required_role) != CaseEnums.Alignment.GOOD:
			return false
		var candidate_ids: PackedInt32Array = PackedInt32Array()
		for suspect in public_view.suspects:
			if suspect == null or evil_ids.has(suspect.suspect_id):
				continue
			if suspect.suspect_id == transform_target_id and current_witness_required_by_role.has(required_role_id):
				continue
			if suspect.suspect_id == transform_target_id:
				if required_role.role_group == CaseEnums.RoleGroup.CHINH_NHAN:
					candidate_ids.append(suspect.suspect_id)
			elif _public_displayed_behavior_role_id(public_view, suspect) == required_role_id:
				if transform_target_id == 0 or required_role_id != transform_fake_role_id:
					candidate_ids.append(suspect.suspect_id)
		if candidate_ids.is_empty():
			return false
		candidates_by_role[required_role_id] = candidate_ids
	return _natural_target_roles_have_distinct_hosts(required_roles, candidates_by_role, 0, {})


func _natural_witness_must_remain_current(
	pretender_role_id: StringName,
	displayed_role_id: StringName
) -> bool:
	return (
		PRETEND_CAPABILITY.MOBSTER_ROLE_IDS.has(pretender_role_id)
		or PRETEND_CAPABILITY.behavior_requires_current_native_witness(displayed_role_id)
	)


func _assigned_current_native_witness_is_satisfied(
	public_view,
	assigned: Dictionary,
	source_suspect_id: int,
	behavior_role_id: StringName,
	transform_target_id: int
) -> bool:
	var suspect_ids: PackedInt32Array = PackedInt32Array()
	var current_role_ids_by_suspect: Dictionary = {}
	for suspect in public_view.suspects:
		if suspect == null:
			continue
		suspect_ids.append(suspect.suspect_id)
		var current_role_id: StringName = StringName(assigned.get(suspect.suspect_id, &""))
		if suspect.suspect_id == transform_target_id:
			current_role_id = BarkeepTransformationService.DRUNKARD_ROLE_ID
		current_role_ids_by_suspect[suspect.suspect_id] = current_role_id
	return PRETEND_CAPABILITY.procedural_current_native_witness_is_satisfied(
		source_suspect_id,
		behavior_role_id,
		suspect_ids,
		current_role_ids_by_suspect
	)


func _natural_target_roles_have_distinct_hosts(
	required_roles: Array[StringName], candidates_by_role: Dictionary,
	role_index: int, used_suspect_ids: Dictionary
) -> bool:
	if role_index >= required_roles.size():
		return true
	var required_role_id: StringName = required_roles[role_index]
	var candidate_ids: PackedInt32Array = candidates_by_role.get(required_role_id, PackedInt32Array())
	for suspect_id: int in candidate_ids:
		if used_suspect_ids.has(suspect_id):
			continue
		used_suspect_ids[suspect_id] = true
		if _natural_target_roles_have_distinct_hosts(
			required_roles, candidates_by_role, role_index + 1, used_suspect_ids
		):
			return true
		used_suspect_ids.erase(suspect_id)
	return false


func _public_suspect_by_id(public_view, suspect_id: int):
	for suspect in public_view.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect
	return null


func _remaining_good_roles_can_still_fit(
	public_view, role_by_id: Dictionary, evil_ids: PackedInt32Array,
	assigned: Dictionary, used_roles: Dictionary,
	transform_target_id: int, transform_fake_role_id: StringName
) -> bool:
	var possible_role_ids: Array[StringName] = _hypothesis_role_pool(public_view)
	var remaining_suspect_ids: PackedInt32Array = PackedInt32Array()
	var roles_by_suspect: Dictionary = {}
	for suspect in public_view.suspects:
		if suspect == null or assigned.has(suspect.suspect_id) or evil_ids.has(suspect.suspect_id):
			continue
		var displayed_role_id: StringName = _public_displayed_behavior_role_id(public_view, suspect)
		var displayed_role: RoleDefinition = role_by_id.get(displayed_role_id, null) as RoleDefinition
		if displayed_role == null:
			return false
		var candidate_roles: Array[StringName] = [displayed_role_id]
		if possible_role_ids.has(PRETEND_CAPABILITY.COPYCAT_ROLE_ID) and PRETEND_CAPABILITY.can_pretend_procedural(
			PRETEND_CAPABILITY.COPYCAT_ROLE_ID, displayed_role
		):
			candidate_roles.append(PRETEND_CAPABILITY.COPYCAT_ROLE_ID)
		if suspect.suspect_id == transform_target_id:
			for role_id: StringName in possible_role_ids:
				var original_role: RoleDefinition = role_by_id.get(role_id, null) as RoleDefinition
				if original_role != null and original_role.role_group == CaseEnums.RoleGroup.CHINH_NHAN and not candidate_roles.has(role_id):
					candidate_roles.append(role_id)
		var legal_roles: Array[StringName] = []
		for role_id: StringName in candidate_roles:
			if used_roles.has(role_id) or not possible_role_ids.has(role_id):
				continue
			if suspect.suspect_id != transform_target_id and transform_target_id > 0 and role_id == transform_fake_role_id:
				continue
			if PRETEND_CAPABILITY.is_pretender(role_id) and role_id == displayed_role_id:
				continue
			var role: RoleDefinition = role_by_id.get(role_id, null) as RoleDefinition
			if role == null or CaseRolePoolService.role_alignment(role) != CaseEnums.Alignment.GOOD:
				continue
			if suspect.suspect_id == transform_target_id and role.role_group != CaseEnums.RoleGroup.CHINH_NHAN:
				continue
			legal_roles.append(role_id)
		if legal_roles.is_empty():
			return false
		remaining_suspect_ids.append(suspect.suspect_id)
		roles_by_suspect[suspect.suspect_id] = legal_roles
	return _remaining_suspects_have_distinct_roles(
		remaining_suspect_ids, roles_by_suspect, 0, {}
	)


func _remaining_suspects_have_distinct_roles(
	remaining_suspect_ids: PackedInt32Array, roles_by_suspect: Dictionary,
	suspect_index: int, matched_roles: Dictionary
) -> bool:
	if suspect_index >= remaining_suspect_ids.size():
		return true
	var suspect_id: int = remaining_suspect_ids[suspect_index]
	var candidate_roles: Array[StringName] = []
	var stored_roles: Variant = roles_by_suspect.get(suspect_id, [])
	if stored_roles is Array:
		for raw_role_id: Variant in stored_roles:
			candidate_roles.append(StringName(raw_role_id))
	for role_id: StringName in candidate_roles:
		if matched_roles.has(role_id):
			continue
		matched_roles[role_id] = true
		if _remaining_suspects_have_distinct_roles(
			remaining_suspect_ids, roles_by_suspect, suspect_index + 1, matched_roles
		):
			return true
		matched_roles.erase(role_id)
	return false


func _fixed_clues_can_match(
	public_view, roles: Array[RoleDefinition], evil_ids: PackedInt32Array,
	assigned: Dictionary, transform_target_id: int, has_poisoner: bool
) -> bool:
	# These Evil-source clues are fixed after Evil roles are assigned. Static
	# Good clues can differ only at the Poisoner or Drunkard target.
	var case_definition: CaseDefinition = _case_definition_from_public_candidate(
		public_view, roles, evil_ids, assigned, transform_target_id
	)
	var evaluator := RoleInformationEvaluationService.new()
	var mismatches: int = 0
	var allowed_mismatches: int = 1 if has_poisoner else 0
	for clue in public_view.public_clues:
		if clue == null:
			continue
		var source_is_evil: bool = evil_ids.has(clue.suspect_id)
		if source_is_evil:
			if not EARLY_EVIL_CLUE_ROLE_IDS.has(clue.behavior_role_id):
				continue
		else:
			if clue.suspect_id == transform_target_id:
				continue
			if not PRETEND_CAPABILITY.STATIC_BEHAVIOR_ROLE_IDS.has(clue.behavior_role_id):
				continue
			if clue.behavior_role_id == &"mailman" or clue.behavior_role_id == &"weatherman":
				continue
		if _diag_active:
			_diag_preflight_clue_evaluations += 1
		var result: InvestigationInformationResult = evaluator.evaluate(case_definition, clue.suspect_id, roles)
		if not _clue_matches_result(clue, result):
			if source_is_evil:
				return false
			mismatches += 1
			if mismatches > allowed_mismatches:
				return false
	return true


func _unsupported_reason(public_view) -> String:
	for role_id: StringName in _hypothesis_role_pool(public_view):
		if role_id == &"drunkard":
			return "M6B mutation hypotheses are not enabled for procedural solving: %s" % role_id
	var obscured_count: int = 0
	for public_suspect in public_view.suspects:
		if public_suspect == null:
			return "Public suspect entry is null."
		if public_suspect.role_identity_obscured:
			obscured_count += 1
			var behavior_role_id: StringName = _public_displayed_behavior_role_id(public_view, public_suspect)
			if String(behavior_role_id).is_empty() or not SUPPORTED_PUBLIC_ROLE_IDS.has(behavior_role_id):
				return "Obscured public role has no supported public clue behavior."
		if not String(public_suspect.public_role_id).is_empty() and not SUPPORTED_PUBLIC_ROLE_IDS.has(public_suspect.public_role_id):
			return "Unsupported public role for M2 solver: %s" % public_suspect.public_role_id
	if obscured_count > 1:
		return "Spectre public view contains more than one obscured suspect."
	for clue in public_view.public_clues:
		if clue == null:
			return "Public clue entry is null."
		if not SUPPORTED_PUBLIC_ROLE_IDS.has(clue.behavior_role_id):
			return "Unsupported public clue role for M2 solver: %s" % clue.behavior_role_id
		if not _payload_kind_supported(clue.payload_kind):
			return "Unsupported public clue payload kind for M2 solver: %d" % clue.payload_kind
	return ""


func _payload_kind_supported(payload_kind: int) -> bool:
	return (
		payload_kind == InvestigationInformationResult.PayloadKind.TEXT
		or payload_kind == InvestigationInformationResult.PayloadKind.NUMBER
		or payload_kind == InvestigationInformationResult.PayloadKind.ROLE_PLAY_CLAIM
		or payload_kind == InvestigationInformationResult.PayloadKind.WEATHER_REPORT
		or payload_kind == InvestigationInformationResult.PayloadKind.NO_MEDDLER_FOUND
		or payload_kind == InvestigationInformationResult.PayloadKind.NO_EVIL_FOUND
		or payload_kind == InvestigationInformationResult.PayloadKind.BLOOD_HOUND_CLUE
	)


func _collect_candidates(
	public_view,
	roles: Array[RoleDefinition],
	suspect_ids: PackedInt32Array,
	remaining: int,
	start_index: int,
	current: PackedInt32Array,
	candidates: Array
) -> void:
	if remaining == 0:
		if _diag_active:
			_diag_evil_sets += 1
		var candidate: PackedInt32Array = current.duplicate()
		candidate.sort()
		if not _candidate_matches_public_role_constraints(public_view, roles, candidate):
			return
		_record_audit_initial(candidate)
		if _candidate_matches_public_clues(public_view, roles, candidate):
			candidates.append(candidate)
		return
	var slots_left: int = suspect_ids.size() - start_index
	if remaining > slots_left:
		return
	for index: int in range(start_index, suspect_ids.size()):
		current.append(int(suspect_ids[index]))
		_collect_candidates(public_view, roles, suspect_ids, remaining - 1, index + 1, current, candidates)
		current.remove_at(current.size() - 1)


func _candidate_matches_public_role_constraints(public_view, roles: Array[RoleDefinition], evil_ids: PackedInt32Array) -> bool:
	var role_by_id: Dictionary = _roles_by_id(roles)
	for public_suspect in public_view.suspects:
		if public_suspect == null or String(public_suspect.public_role_id).is_empty():
			continue
		var public_group: int = _public_group(public_suspect, role_by_id)
		var public_alignment: int = CaseRolePoolService.alignment_for_role_group(public_group)
		var candidate_is_evil: bool = evil_ids.has(public_suspect.suspect_id)
		if public_alignment == CaseEnums.Alignment.EVIL and not candidate_is_evil:
			return false
		if public_alignment == CaseEnums.Alignment.GOOD and candidate_is_evil:
			return false
	return true


func _candidate_matches_public_clues(
	public_view, roles: Array[RoleDefinition], evil_ids: PackedInt32Array,
	true_roles: Dictionary = {}, transform_target_id: int = 0, barkeep_id: int = 0
) -> bool:
	if _diag_active:
		_diag_worlds_before_replay += 1
	var case_definition: CaseDefinition = _case_definition_from_public_candidate(public_view, roles, evil_ids, true_roles, transform_target_id)
	var poisoner_id: int = 0
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect.true_role_id == PRETEND_CAPABILITY.POISONER_ROLE_ID:
			poisoner_id = suspect.suspect_id
			break
	if poisoner_id > 0:
		var taint_service := PoisonerTaintService.new()
		var eligible_ids: PackedInt32Array = taint_service.eligible_taint_target_ids(case_definition, poisoner_id)
		if _diag_active:
			_diag_max_poisoner_targets = maxi(_diag_max_poisoner_targets, eligible_ids.size())
		for target_id: int in eligible_ids:
			if _diag_active:
				_diag_poisoner_hypotheses += 1
			var runtime_state := CaseRuntimeState.new()
			var no_players: Array[PlayerCaseState] = []
			runtime_state.initialize(case_definition, no_players)
			var taint: PoisonerTaintRecord = taint_service.resolve_taint(case_definition, runtime_state, poisoner_id, target_id)
			if taint == null or not taint.applied:
				continue
			if not _apply_barkeep_hypothesis(case_definition, runtime_state, roles, transform_target_id, barkeep_id):
				continue
			_record_audit_initial(evil_ids)
			if _clues_match_candidate_world(public_view, roles, evil_ids, case_definition, runtime_state):
				return true
		return false
	if barkeep_id > 0:
		var barkeep_runtime := CaseRuntimeState.new()
		var barkeep_no_players: Array[PlayerCaseState] = []
		barkeep_runtime.initialize(case_definition, barkeep_no_players)
		if not _apply_barkeep_hypothesis(case_definition, barkeep_runtime, roles, transform_target_id, barkeep_id):
			if _diag_active:
				_diag_structural_prunes += 1
				_diag_leaf_structural_rejects += 1
			return false
		_record_audit_initial(evil_ids)
		return _clues_match_candidate_world(public_view, roles, evil_ids, case_definition, barkeep_runtime)
	_record_audit_initial(evil_ids)
	return _clues_match_candidate_world(public_view, roles, evil_ids, case_definition, null)


func _apply_barkeep_hypothesis(
	case_definition: CaseDefinition, runtime_state: CaseRuntimeState,
	roles: Array[RoleDefinition], transform_target_id: int, barkeep_id: int
) -> bool:
	if barkeep_id == 0:
		return transform_target_id == 0
	if _diag_active:
		_diag_transform_attempts += 1
	var service := BarkeepTransformationService.new()
	var record: BarkeepTransformationRecord = service.resolve_transformation(
		case_definition, runtime_state, barkeep_id, transform_target_id, roles
	)
	if record == null or not record.applied:
		return false
	if _diag_active:
		_diag_transform_applied += 1
	var fake_role_id: StringName = &""
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect.suspect_id == transform_target_id:
			fake_role_id = suspect.displayed_role_id
			break
	if not PRETEND_CAPABILITY.is_supported_behavior(fake_role_id):
		return false
	return service.drunkard_pretend_role_is_valid(
		case_definition, runtime_state, roles,
		CaseRolePoolService.suspected_role_candidates(case_definition), fake_role_id
	)


func _clock_location_is_valid(public_view) -> bool:
	var required: bool = _hypothesis_role_pool(public_view).has(&"clock_maker")
	for suspect in public_view.suspects:
		if _public_displayed_behavior_role_id(public_view, suspect) == &"clock_maker":
			required = true
	if public_view.clock_tower_slot < 0:
		return not required
	if public_view.clock_tower_slot >= public_view.board_slot_count:
		return false
	for suspect in public_view.suspects:
		if suspect.board_slot == public_view.clock_tower_slot:
			return false
	return true


func _clues_match_candidate_world(
	public_view, roles: Array[RoleDefinition], evil_ids: PackedInt32Array,
	case_definition: CaseDefinition, runtime_state: CaseRuntimeState
) -> bool:
	var has_clock_clue: bool = false
	for clue in public_view.public_clues:
		if clue.behavior_role_id == &"clock_maker":
			has_clock_clue = true
	if not has_clock_clue:
		return _clues_match_scheduled_world(public_view, roles, evil_ids, case_definition, runtime_state)
	var tower: ClockTowerDefinition = ClockTowerService.clock_tower_for_case(case_definition)
	if tower == null:
		return false
	# Existential public-world schedule, never the generated hidden ring hour.
	# One shared schedule must satisfy every clue in this candidate world.
	var evaluator := RoleInformationEvaluationService.new()
	for hour: int in range(1, 24):
		tower.ring_hour = hour
		var clock_matches: bool = true
		for clue in public_view.public_clues:
			if clue.behavior_role_id != &"clock_maker":
				continue
			if _diag_active:
				_diag_clue_evaluations += 1
			var information: InvestigationInformationResult = evaluator.evaluate(case_definition, clue.suspect_id, roles, {}, runtime_state)
			if not _clue_matches_result(clue, information):
				clock_matches = false
				break
		if clock_matches:
			# Other supported clues do not depend on the ring schedule.
			return _clues_match_scheduled_world(public_view, roles, evil_ids, case_definition, runtime_state)
	return false


func _clues_match_scheduled_world(
	public_view, roles: Array[RoleDefinition], evil_ids: PackedInt32Array,
	case_definition: CaseDefinition, runtime_state: CaseRuntimeState
) -> bool:
	if _diag_active:
		_diag_worlds_replayed += 1
	var evaluator := RoleInformationEvaluationService.new()
	for clue_index: int in range(public_view.public_clues.size()):
		var clue = public_view.public_clues[clue_index]
		if clue == null:
			return false
		var mailman_pair: Dictionary = {}
		if clue.payload_kind == InvestigationInformationResult.PayloadKind.ROLE_PLAY_CLAIM:
			mailman_pair = {
				"in_play_role_id": clue.in_play_role_id,
				"not_in_play_role_id": clue.not_in_play_role_id,
			}
		if _diag_active:
			_diag_clue_evaluations += 1
		var recomputed: InvestigationInformationResult = evaluator.evaluate(case_definition, clue.suspect_id, roles, mailman_pair, runtime_state)
		if not _clue_matches_result(clue, recomputed):
			return false
		var surviving_sets: Dictionary = _audit_clue_sets[clue_index]
		var set_key: String = _audit_set_key(evil_ids)
		if not surviving_sets.has(set_key):
			surviving_sets[set_key] = evil_ids.duplicate()
	return true


func _record_audit_initial(evil_ids: PackedInt32Array) -> void:
	var set_key: String = _audit_set_key(evil_ids)
	if not _audit_initial_sets.has(set_key):
		_audit_initial_sets[set_key] = evil_ids.duplicate()


func _audit_set_key(evil_ids: PackedInt32Array) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for suspect_id: int in evil_ids:
		parts.append(str(suspect_id))
	return ",".join(parts)


func _case_definition_from_public_candidate(
	public_view, roles: Array[RoleDefinition], evil_ids: PackedInt32Array,
	true_roles: Dictionary = {}, transform_target_id: int = 0
) -> CaseDefinition:
	var case_definition := CaseDefinition.new()
	case_definition.case_id = &"public_solver_candidate"
	case_definition.data_version = 1
	if true_roles.values().has(PRETEND_CAPABILITY.POISONER_ROLE_ID):
		case_definition.set_meta(&"procedural_poisoner_clues", true)
	if true_roles.values().has(PRETEND_CAPABILITY.BARKEEP_ROLE_ID):
		case_definition.set_meta(&"procedural_barkeep_clues", true)
	if true_roles.values().has(PRETEND_CAPABILITY.CRITIC_ROLE_ID):
		case_definition.set_meta(&"procedural_critic_clues", true)
	case_definition.set_meta(&"board_columns", public_view.board_columns)
	case_definition.set_meta(&"board_rows", public_view.board_rows)
	case_definition.set_meta(&"board_slot_count", public_view.board_slot_count)
	if public_view.clock_tower_slot >= 0:
		var tower := ClockTowerDefinition.new()
		tower.board_slot = public_view.clock_tower_slot
		case_definition.board_locations.append(tower)
	var public_suspected_role_ids: Array[StringName] = public_view.suspected_role_ids
	var allowed_role_ids: Array[StringName] = public_view.allowed_role_ids
	if not public_suspected_role_ids.is_empty():
		case_definition.suspected_role_ids = public_suspected_role_ids.duplicate()
	elif not allowed_role_ids.is_empty():
		case_definition.suspected_role_ids = allowed_role_ids.duplicate()
	else:
		case_definition.suspected_role_ids = _role_ids_from_roles(roles)
	var role_by_id: Dictionary = _roles_by_id(roles)
	for public_suspect in public_view.suspects:
		if public_suspect == null:
			continue
		var suspect := SuspectDefinition.new()
		suspect.suspect_id = public_suspect.suspect_id
		suspect.board_slot = public_suspect.board_slot
		var displayed_role_id: StringName = _public_displayed_behavior_role_id(public_view, public_suspect)
		suspect.displayed_role_id = displayed_role_id
		suspect.true_role_id = StringName(true_roles.get(public_suspect.suspect_id, displayed_role_id))
		var true_role: RoleDefinition = role_by_id.get(suspect.true_role_id, null) as RoleDefinition
		suspect.role_group = true_role.role_group if true_role != null else _public_group(public_suspect, role_by_id)
		if suspect.true_role_id != suspect.displayed_role_id and suspect.suspect_id != transform_target_id:
			suspect.is_impersonating = true
			suspect.impersonated_role_id = suspect.displayed_role_id
		if String(suspect.true_role_id).is_empty():
			suspect.true_role_id = &"generated_public_unknown"
			suspect.displayed_role_id = &"generated_public_unknown"
			suspect.role_group = CaseEnums.RoleGroup.TONG_PHAM if evil_ids.has(suspect.suspect_id) else CaseEnums.RoleGroup.CHINH_NHAN
		suspect.true_alignment = CaseEnums.Alignment.EVIL if evil_ids.has(suspect.suspect_id) else CaseEnums.Alignment.GOOD
		case_definition.suspects.append(suspect)
	var obscured_target_id: int = _public_obscured_target_id(public_view)
	if obscured_target_id > 0:
		for suspect: SuspectDefinition in case_definition.suspects:
			if suspect.true_role_id == PRETEND_CAPABILITY.SPECTRE_ROLE_ID:
				suspect.obscure_target_suspect_id = obscured_target_id
				break
	return case_definition


func _spectre_hypothesis_is_valid(
	public_view, role_by_id: Dictionary, assigned: Dictionary, transform_target_id: int
) -> bool:
	var obscured_target_id: int = _public_obscured_target_id(public_view)
	var spectre_source_id: int = 0
	for suspect_id: Variant in assigned:
		if StringName(assigned[suspect_id]) == PRETEND_CAPABILITY.SPECTRE_ROLE_ID:
			spectre_source_id = int(suspect_id)
			break
	if obscured_target_id <= 0:
		return spectre_source_id == 0
	if spectre_source_id <= 0 or obscured_target_id == transform_target_id:
		return false
	var target_role_id: StringName = StringName(assigned.get(obscured_target_id, &""))
	var target_role: RoleDefinition = role_by_id.get(target_role_id, null) as RoleDefinition
	return target_role != null and target_role.role_group != CaseEnums.RoleGroup.HIEU_SU


func _critic_hypothesis_is_valid(
	public_view,
	assigned: Dictionary,
	critic_source_id: int,
	displayed_role_id: StringName,
	transform_target_id: int
) -> bool:
	if (
		String(displayed_role_id).is_empty()
		or displayed_role_id == PRETEND_CAPABILITY.CRITIC_ROLE_ID
		or not _hypothesis_role_pool(public_view).has(displayed_role_id)
		or not PRETEND_CAPABILITY.critic_can_pretend(displayed_role_id)
	):
		return false
	for suspect_id: Variant in assigned:
		if int(suspect_id) == critic_source_id or int(suspect_id) == transform_target_id:
			continue
		if StringName(assigned[suspect_id]) == displayed_role_id:
			return false
	return true


func _serial_killer_hypothesis_is_valid(
	public_view, role_by_id: Dictionary, assigned: Dictionary, transform_target_id: int
) -> bool:
	var source_id: int = 0
	var source_slot: int = -1
	for public_suspect in public_view.suspects:
		if public_suspect != null and StringName(assigned.get(public_suspect.suspect_id, &"")) == PRETEND_CAPABILITY.SERIAL_KILLER_ROLE_ID:
			source_id = public_suspect.suspect_id
			source_slot = public_suspect.board_slot
			break
	if source_id == 0:
		return true
	for public_suspect in public_view.suspects:
		if public_suspect == null or public_suspect.suspect_id == source_id:
			continue
		if not _board_slots_are_orthogonally_adjacent(source_slot, public_suspect.board_slot, public_view.board_columns):
			continue
		if public_suspect.suspect_id == transform_target_id:
			continue
		var current_role_id: StringName = StringName(assigned.get(public_suspect.suspect_id, &""))
		var current_role: RoleDefinition = role_by_id.get(current_role_id, null) as RoleDefinition
		if current_role != null and current_role.role_group == CaseEnums.RoleGroup.CHINH_NHAN:
			return true
	return false


func _board_slots_are_orthogonally_adjacent(first_slot: int, second_slot: int, columns: int) -> bool:
	if first_slot < 0 or second_slot < 0 or columns <= 0:
		return false
	var delta: int = absi(first_slot - second_slot)
	return delta == columns or (delta == 1 and absi(first_slot % columns - second_slot % columns) == 1)


func _public_obscured_target_id(public_view) -> int:
	var target_id: int = 0
	for public_suspect in public_view.suspects:
		if public_suspect == null or not public_suspect.role_identity_obscured:
			continue
		if target_id > 0:
			return -1
		target_id = public_suspect.suspect_id
	return target_id


func _public_displayed_behavior_role_id(public_view, public_suspect) -> StringName:
	if public_suspect == null:
		return &""
	if not String(public_suspect.public_role_id).is_empty():
		return public_suspect.public_role_id
	for clue in public_view.public_clues:
		if clue != null and clue.suspect_id == public_suspect.suspect_id:
			return clue.behavior_role_id
	return &""


func _clue_matches_result(clue, result: InvestigationInformationResult) -> bool:
	if result == null:
		return false
	if clue.payload_kind != result.payload_kind:
		return false
	if clue.behavior_role_id != result.behavior_role_id:
		return false
	if clue.behavior_role_id == &"clock_maker":
		return (
			clue.clock_start_hour >= 1 and clue.clock_start_hour <= 23
			and clue.clock_end_hour == clue.clock_start_hour + 1
			and clue.numeric_value == clue.clock_start_hour
			and clue.clock_start_hour == result.numeric_value
			and clue.clock_claims_ringing == (result.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL)
		)
	match clue.payload_kind:
		InvestigationInformationResult.PayloadKind.TEXT:
			return clue.text == result.text
		InvestigationInformationResult.PayloadKind.NUMBER:
			return clue.numeric_value == result.numeric_value
		InvestigationInformationResult.PayloadKind.ROLE_PLAY_CLAIM:
			return (
				clue.in_play_role_id == result.in_play_role_id
				and clue.not_in_play_role_id == result.not_in_play_role_id
				and result.claimed_in_play_is_true == (result.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL)
				and result.claimed_not_in_play_is_true == (result.truth_mode == InvestigationInformationResult.TruthMode.TRUTHFUL)
			)
		InvestigationInformationResult.PayloadKind.WEATHER_REPORT:
			return _weather_ids_match(clue.referenced_suspect_ids, result.weather_suspect_ids)
		InvestigationInformationResult.PayloadKind.NO_MEDDLER_FOUND:
			return clue.referenced_suspect_ids == result.weather_suspect_ids and clue.weather_group_slots == result.weather_group_slots
		InvestigationInformationResult.PayloadKind.NO_EVIL_FOUND:
			return true
		InvestigationInformationResult.PayloadKind.BLOOD_HOUND_CLUE:
			return clue.direction_key == result.direction_key
		_:
			return false


func _weather_ids_match(announced_ids: PackedInt32Array, evaluated_ids: PackedInt32Array) -> bool:
	if announced_ids.size() != 3 or evaluated_ids.size() != 3:
		return false
	var announced_sorted: PackedInt32Array = announced_ids.duplicate()
	announced_sorted.sort()
	if announced_sorted[0] == announced_sorted[1] or announced_sorted[1] == announced_sorted[2]:
		return false
	var evaluated_sorted: PackedInt32Array = evaluated_ids.duplicate()
	evaluated_sorted.sort()
	return announced_sorted == evaluated_sorted


func _roles_by_id(roles: Array[RoleDefinition]) -> Dictionary:
	var by_id: Dictionary = {}
	for role: RoleDefinition in roles:
		if role != null and not String(role.role_id).is_empty():
			by_id[role.role_id] = role
	return by_id


func _public_group(public_suspect, role_by_id: Dictionary) -> int:
	var role: RoleDefinition = role_by_id.get(public_suspect.public_role_id, null) as RoleDefinition
	return role.role_group if role != null else public_suspect.public_role_group


func _role_ids_from_roles(roles: Array[RoleDefinition]) -> Array[StringName]:
	var ids: Array[StringName] = []
	for role: RoleDefinition in roles:
		if role != null and not ids.has(role.role_id):
			ids.append(role.role_id)
	ids.sort()
	return ids
