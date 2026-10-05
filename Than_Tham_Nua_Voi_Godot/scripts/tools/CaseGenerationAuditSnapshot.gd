extends RefCounted

const MUTATION_STATE := preload("res://scripts/domain/cases/CaseMutationStateSnapshot.gd")

var root_seed: int = 0
var attempt_index: int = -1
var attempt_seed: int = -1
var generator_version: int = 0
var candidate_signature: String = ""
var suspect_count: int = 0
var board_tiles: Array[Dictionary] = []
var suspected_role_ids: Array[StringName] = []
var red_herring_role_ids: Array[StringName] = []
var hidden_suspects: Array[Dictionary] = []
var public_clues: Array[Dictionary] = []
var true_evil_ids: PackedInt32Array = PackedInt32Array()
var solver_raw_evil_set_count: int = 0
var solver_initial_count: int = 0
var solver_pre_replay_sets: Array = []
var solver_remaining_counts: PackedInt32Array = PackedInt32Array()
var solver_replay_sets_after_clues: Array = []
var solver_final_sets: Array = []
var solver_status: StringName = &""
var solver_unique_ids: PackedInt32Array = PackedInt32Array()
var ground_truth_matches: bool = false
var accepted: bool = false
var rejection_reason: StringName = &""
var rejected_attempts: Array[Dictionary] = []
var role_names: Dictionary = {}
var clock_tower_ring_hour: int = 0


func capture(entry: CaseSeedWarehouseEntry, acceptance: CaseGenerationAcceptanceResult, roles: Array[RoleDefinition]) -> bool:
	if entry == null or acceptance == null or not acceptance.success:
		return false
	var candidate: CaseGenerationResult = acceptance.accepted_candidate as CaseGenerationResult
	var solver: CaseGeneratorSolverResult = acceptance.accepted_solver_result as CaseGeneratorSolverResult
	var public_view: GeneratedPublicCaseView = acceptance.accepted_public_view as GeneratedPublicCaseView
	if candidate == null or candidate.hidden_case_draft == null or solver == null or public_view == null:
		return false
	if (
		entry.root_seed != acceptance.root_seed
		or entry.accepted_attempt_index != acceptance.accepted_attempt_index
		or entry.accepted_derived_seed != acceptance.accepted_derived_seed
		or entry.candidate_signature != candidate.fingerprint
		or entry.solver_signature != solver.fingerprint_text()
	):
		return false
	root_seed = acceptance.root_seed
	attempt_index = acceptance.accepted_attempt_index
	attempt_seed = acceptance.accepted_derived_seed
	generator_version = candidate.generator_version
	candidate_signature = candidate.fingerprint
	suspect_count = candidate.hidden_case_draft.suspects.size()
	clock_tower_ring_hour = candidate.hidden_case_draft.clock_tower_ring_hour
	for role_id: StringName in candidate.suspected_role_ids:
		suspected_role_ids.append(role_id)
	true_evil_ids = candidate.hidden_case_draft.hidden_evil_suspect_ids.duplicate()
	true_evil_ids.sort()
	solver_raw_evil_set_count = solver.raw_evil_set_count
	solver_initial_count = solver.initial_candidate_count
	solver_pre_replay_sets = _duplicate_evil_sets(solver.pre_replay_evil_sets)
	solver_remaining_counts = solver.remaining_candidate_counts.duplicate()
	for clue_sets: Array in solver.replay_evil_sets_after_clues:
		solver_replay_sets_after_clues.append(_duplicate_evil_sets(clue_sets))
	solver_status = solver.status
	solver_unique_ids = solver.unique_evil_suspect_ids.duplicate()
	ground_truth_matches = solver.ground_truth_checked and solver.unique_solution_matches_ground_truth
	accepted = acceptance.success
	rejection_reason = acceptance.failure_reason
	for rejected: Dictionary in acceptance.rejected_attempts:
		rejected_attempts.append(rejected.duplicate(true))
	for role: RoleDefinition in roles:
		if role != null:
			role_names[role.role_id] = role.display_name
	for tile in candidate.hidden_case_draft.board_tiles:
		board_tiles.append({
			"slot": tile.board_slot,
			"kind": tile.tile_kind,
			"suspect_id": tile.suspect_id,
			"location_id": tile.location_id,
		})
	var represented_roles: Dictionary = {}
	for suspect in candidate.hidden_case_draft.suspects:
		represented_roles[suspect.true_role_id] = true
		represented_roles[suspect.displayed_role_id] = true
		var obscure_target_suspect_id: int = 0
		var obscured_by_suspect_id: int = 0
		if suspect.suspect_id == candidate.hidden_case_draft.spectre_source_suspect_id:
			obscure_target_suspect_id = candidate.hidden_case_draft.spectre_obscure_target_suspect_id
		if suspect.suspect_id == candidate.hidden_case_draft.spectre_obscure_target_suspect_id:
			obscured_by_suspect_id = candidate.hidden_case_draft.spectre_source_suspect_id
		var behavior_role_id: StringName = suspect.displayed_role_id
		var truth_mode: int = -1
		for clue in candidate.hidden_case_draft.public_clues:
			if clue != null and clue.suspect_id == suspect.suspect_id:
				behavior_role_id = clue.behavior_role_id
				truth_mode = clue.truth_mode
				break
		hidden_suspects.append({
			"suspect_id": suspect.suspect_id,
			"board_slot": suspect.board_slot,
			"true_role_id": suspect.true_role_id,
			"current_role_id": suspect.true_role_id,
			"displayed_role_id": suspect.displayed_role_id,
			"impersonated_role_id": suspect.impersonated_role_id,
			"is_impersonating": suspect.is_impersonating,
			"obscure_target_suspect_id": obscure_target_suspect_id,
			"obscured_by_suspect_id": obscured_by_suspect_id,
			"behavior_role_id": behavior_role_id,
			"role_group": suspect.role_group,
			"true_alignment": suspect.true_alignment,
			"truth_mode": truth_mode,
		})
	for role_id: StringName in suspected_role_ids:
		if not represented_roles.has(role_id):
			red_herring_role_ids.append(role_id)
	for clue in public_view.public_clues:
		var references: PackedInt32Array = clue.referenced_suspect_ids.duplicate()
		if clue.payload_kind == InvestigationInformationResult.PayloadKind.WEATHER_REPORT:
			references.sort()
		public_clues.append({
			"suspect_id": clue.suspect_id,
			"displayed_role_id": clue.displayed_role_id,
			"behavior_role_id": clue.behavior_role_id,
			"payload_kind": clue.payload_kind,
			"text": clue.text,
			"numeric_value": clue.numeric_value,
			"referenced_suspect_ids": references,
			"weather_group_slots": clue.weather_group_slots.duplicate(),
			"in_play_role_id": clue.in_play_role_id,
			"not_in_play_role_id": clue.not_in_play_role_id,
			"direction_key": clue.direction_key,
		})
	for evil_set: PackedInt32Array in solver.candidate_evil_sets:
		solver_final_sets.append(evil_set.duplicate())
	return true


func display_lines(
	case_definition: CaseDefinition = null,
	runtime_state: CaseRuntimeState = null,
	roles: Array[RoleDefinition] = []
) -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("[GENERATION]")
	lines.append("Seed: %d | Attempt: %d (seed %d) | v%d" % [root_seed, attempt_index, attempt_seed, generator_version])
	lines.append("Suspects: %d" % suspect_count)
	lines.append("Suspect List: %s" % _role_list(suspected_role_ids))
	if not red_herring_role_ids.is_empty():
		lines.append("Red herrings: %s" % _role_list(red_herring_role_ids))
	var board_parts: PackedStringArray = PackedStringArray()
	for tile: Dictionary in board_tiles:
		board_parts.append("%d:%s" % [int(tile["slot"]), _tile_suffix(tile)])
	lines.append("Board: %s" % ", ".join(board_parts))
	lines.append("")
	lines.append("[HIDDEN TRUTH]")
	if clock_tower_ring_hour > 0:
		lines.append("Clock Tower: %dh / %dh" % [clock_tower_ring_hour, clock_tower_ring_hour + 1])
	for suspect: Dictionary in hidden_suspects:
		var mutation: CaseMutationStateSnapshot = null
		if case_definition != null and runtime_state != null:
			mutation = MUTATION_STATE.from_runtime(case_definition, runtime_state, int(suspect["suspect_id"]), roles)
		if mutation != null and (mutation.original_role_id != mutation.current_role_id or mutation.is_tainted or mutation.is_obscured):
			lines.append(mutation.audit_line(role_names))
		else:
			lines.append(_hidden_suspect_line(suspect))
		if int(suspect.get("obscure_target_suspect_id", 0)) > 0:
			lines.append("  -> che #%d" % int(suspect["obscure_target_suspect_id"]))
		if int(suspect.get("obscured_by_suspect_id", 0)) > 0:
			lines.append("  -> obscured by #%d" % int(suspect["obscured_by_suspect_id"]))
		if runtime_state != null:
			var transform: BarkeepTransformationRecord = runtime_state.barkeep_record_for_source(int(suspect["suspect_id"]))
			if transform != null and transform.applied:
				lines.append("  Transform target: #%d" % transform.target_suspect_id)
	lines.append("Evil set: %s" % _ids_text(true_evil_ids))
	lines.append("")
	lines.append("[PUBLIC CLUES]")
	for clue: Dictionary in public_clues:
		lines.append("#%d %s: %s" % [int(clue["suspect_id"]), _role_text(clue["displayed_role_id"]), String(clue["text"])])
	lines.append("")
	lines.append("[SOLVER]")
	lines.append("Raw Evil sets: %d (exact combinations)" % solver_raw_evil_set_count)
	lines.append("Observed after early pruning: %d" % solver_pre_replay_sets.size())
	lines.append("  (public structure + safe early fixed-clue filters)")
	lines.append("  (observed optimized checkpoints, not reconstructed clue-prefix totals)")
	_append_evil_sets(lines, solver_pre_replay_sets)
	for index: int in range(solver_replay_sets_after_clues.size()):
		var clue_sets: Array = solver_replay_sets_after_clues[index]
		lines.append("Observed after replay clue #%d: %d" % [index + 1, clue_sets.size()])
		_append_evil_sets(lines, clue_sets)
	lines.append("Observed final: %d" % solver_final_sets.size())
	_append_evil_sets(lines, solver_final_sets)
	lines.append("Result: %s -> %s" % [_solver_status_text(), _set_list_text(solver_final_sets)])
	lines.append("")
	lines.append("[ACCEPTANCE]")
	lines.append("Truth: %s | Solver: %s" % [_ids_text(true_evil_ids), _ids_text(solver_unique_ids)])
	lines.append("Match: %s | Accepted: %s" % [_yes_no(ground_truth_matches), _yes_no(accepted)])
	if not String(rejection_reason).is_empty():
		lines.append("Reason: %s" % String(rejection_reason))
	for rejected: Dictionary in rejected_attempts:
		lines.append("Rejected #%d (seed %d): %s / %s" % [int(rejected["attempt_index"]), int(rejected["attempt_seed"]), String(rejected["reason"]), String(rejected["solver_status"])])
	return lines


func _hidden_suspect_line(suspect: Dictionary) -> String:
	var true_role: StringName = suspect["true_role_id"]
	var displayed_role: StringName = suspect["displayed_role_id"]
	var behavior_role: StringName = suspect["behavior_role_id"]
	var line: String = "#%d %s" % [int(suspect["suspect_id"]), _role_text(true_role)]
	if bool(suspect["is_impersonating"]):
		line += " -> giả %s" % _role_text(displayed_role)
	elif displayed_role != true_role:
		line += " -> hiện %s" % _role_text(displayed_role)
	if behavior_role != true_role or behavior_role != displayed_role:
		line += " (hành vi: %s)" % _role_text(behavior_role)
	return "%s | %s / %s | %s" % [
		line, _group_text(int(suspect["role_group"])),
		_alignment_text(int(suspect["true_alignment"])), _truth_text(int(suspect["truth_mode"])),
	]


func _tile_suffix(tile: Dictionary) -> String:
	if String(tile["kind"]) == "suspect":
		return "#%d" % int(tile["suspect_id"])
	if String(tile["kind"]) == "location":
		if tile["location_id"] == BoardLocationDefinition.LOCATION_CRIME_SCENE:
			return "Hiện trường"
		return String(tile["location_id"])
	return "trống"


func _role_text(role_id: StringName) -> String:
	if String(role_id).is_empty():
		return "none"
	return String(role_names.get(role_id, String(role_id)))


func _group_text(group: int) -> String:
	match group:
		CaseEnums.RoleGroup.CHINH_NHAN:
			return "Người Vô Tội"
		CaseEnums.RoleGroup.HIEU_SU:
			return "Kẻ Bao Đồng"
		CaseEnums.RoleGroup.TONG_PHAM:
			return "Thuộc Hạ"
		CaseEnums.RoleGroup.NGHICH_THAN:
			return "Nghịch Thần"
		_:
			return "unknown"


func _alignment_text(alignment: int) -> String:
	return "Evil" if alignment == CaseEnums.Alignment.EVIL else "Good"


func _solver_status_text() -> String:
	match solver_status:
		CaseGeneratorSolverResult.STATUS_UNIQUE_SOLUTION:
			return "UNIQUE"
		CaseGeneratorSolverResult.STATUS_MULTIPLE_SOLUTIONS:
			return "MULTIPLE"
		CaseGeneratorSolverResult.STATUS_NO_SOLUTION:
			return "NO SOLUTION"
		CaseGeneratorSolverResult.STATUS_UNSUPPORTED:
			return "UNSUPPORTED"
		_:
			return String(solver_status).to_upper()


func _truth_text(mode: int) -> String:
	if mode == InvestigationInformationResult.TruthMode.TRUTHFUL:
		return "truthful"
	if mode == InvestigationInformationResult.TruthMode.LYING:
		return "lying"
	return "no public clue"


func _role_list(ids: Array[StringName]) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for role_id: StringName in ids:
		parts.append(_role_text(role_id))
	return ", ".join(parts) if not parts.is_empty() else "none"


func _yes_no(value: bool) -> String:
	return "YES" if value else "NO"


func _ids_text(ids: PackedInt32Array) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for suspect_id: int in ids:
		parts.append("#%d" % suspect_id)
	return "{" + ", ".join(parts) + "}"


func _set_list_text(sets: Array) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for ids: PackedInt32Array in sets:
		parts.append(_ids_text(ids))
	return "; ".join(parts) if not parts.is_empty() else "none"


func _append_evil_sets(lines: PackedStringArray, sets: Array) -> void:
	if sets.is_empty():
		lines.append("  none")
		return
	for ids: PackedInt32Array in sets:
		lines.append("  %s" % _ids_text(ids))


func _duplicate_evil_sets(sets: Array) -> Array:
	var copies: Array = []
	for ids: PackedInt32Array in sets:
		copies.append(ids.duplicate())
	return copies
