extends RefCounted

const SESSION := preload("res://scripts/application/mvp/MvpIntegratedNextCaseSession.gd")
const WAREHOUSE_BUILDER := preload("res://scripts/domain/cases/CaseSeedWarehouseBuilder.gd")
const OPTION_COMPOSER := preload("res://scripts/domain/cases/CaseSeedWarehouseOptionComposer.gd")
const GENERATOR := preload("res://scripts/domain/cases/CaseGenerator.gd")


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roles: Array[RoleDefinition] = FixtureRepository.load_roles()
	var player_setup := PlayerFacingSetupSession.new()
	player_setup.begin_new_game()
	rows.append(_row("New player-facing Match owns a positive generation seed", player_setup.match_state != null and player_setup.match_state.case_generation_seed > 0))
	var session = SESSION.new()
	var match_state := MvpMatchState.new()
	match_state.case_generation_seed = 447711
	match_state.current_round_number = 1
	session.match_state = match_state
	var request: CaseGenerationRequest = session._default_next_case_generation_request()
	var roots: PackedInt32Array = session._default_next_case_warehouse_root_seeds()
	var option_seed: int = session._default_next_case_option_seed()
	var restored: MvpMatchState = MvpMatchState.from_dict(match_state.to_dict())
	rows.append(_row("Production Match generation seed survives round-trip", restored.case_generation_seed == 447711))
	var repeat_roots: PackedInt32Array = session._default_next_case_warehouse_root_seeds()
	var repeat_option_seed: int = session._default_next_case_option_seed()
	match_state.case_generation_seed = 447712
	var other_roots: PackedInt32Array = session._default_next_case_warehouse_root_seeds()
	var other_option_seed: int = session._default_next_case_option_seed()
	match_state.case_generation_seed = 447711
	match_state.current_round_number = 2
	var next_round_option_seed: int = session._default_next_case_option_seed()
	var same_match_roots: PackedInt32Array = session._default_next_case_warehouse_root_seeds()
	rows.append(_row("Production Match/Round seeds deterministically change options", roots == repeat_roots and option_seed == repeat_option_seed and roots != other_roots and option_seed != other_option_seed and next_round_option_seed != option_seed and same_match_roots == roots))
	match_state.current_round_number = 1
	var generator = GENERATOR.new()
	var warehouse: CaseSeedWarehouseBuildResult = WAREHOUSE_BUILDER.new().build_varied_suspect_counts(request, roots, roots.size(), roles, 5, 8, 24)
	var deterministic_candidate: bool = false
	if not warehouse.entries.is_empty():
		var first_request: CaseGenerationRequest = warehouse.entries[0].request()
		first_request.seed = warehouse.entries[0].accepted_derived_seed
		var direct_a: CaseGenerationResult = generator.generate(first_request, roles)
		var direct_b: CaseGenerationResult = generator.generate(first_request, roles)
		deterministic_candidate = direct_a.is_success() and direct_b.is_success() and direct_a.fingerprint == direct_b.fingerprint and direct_a.suspected_role_ids == direct_b.suspected_role_ids and direct_a.hidden_case_draft.hidden_evil_suspect_ids == direct_b.hidden_case_draft.hidden_evil_suspect_ids
	rows.append(_row("Production generator repeats explicit seed and Evil answer", deterministic_candidate))
	var signatures: Dictionary = {}
	var evil_sets: Dictionary = {}
	var first_eight_evil_sets: Dictionary = {}
	var role_compositions: Dictionary = {}
	var board_placements: Dictionary = {}
	var clue_combinations: Dictionary = {}
	var suspect_lists: Dictionary = {}
	var suspect_count_histogram: Dictionary = {"5": 0, "6": 0, "7": 0, "8": 0}
	var role_frequency: Dictionary = {}
	var first_evil_position_frequency: Dictionary = {}
	var lists_valid: bool = true
	var solver_valid: bool = true
	var signatures_stable: bool = true
	var evil_counts_valid: bool = true
	var solver_solve_count: int = 0
	var solver_total_ms: int = 0
	var solver_max_ms: int = 0
	var solver_max_root_seed: int = 0
	var solver_max_accepted_seed: int = 0
	var roles_by_id: Dictionary = {}
	for role: RoleDefinition in roles:
		if role != null:
			roles_by_id[role.role_id] = role
	var entry_index: int = 0
	for entry: CaseSeedWarehouseEntry in warehouse.entries:
		signatures[entry.candidate_signature] = true
		evil_sets[_join_ints(entry.evil_suspect_ids)] = true
		if entry_index < 8:
			first_eight_evil_sets[_join_ints(entry.evil_suspect_ids)] = true
		entry_index += 1
		var candidate_request: CaseGenerationRequest = entry.request()
		candidate_request.seed = entry.accepted_derived_seed
		var candidate: CaseGenerationResult = generator.generate(candidate_request, roles)
		if candidate == null or not candidate.is_success() or candidate.hidden_case_draft == null:
			lists_valid = false
			solver_valid = false
			signatures_stable = false
			evil_counts_valid = false
			continue
		var suspect_count: int = candidate.hidden_case_draft.suspects.size()
		var count_key: String = str(suspect_count)
		suspect_count_histogram[count_key] = int(suspect_count_histogram.get(count_key, 0)) + 1
		var listed: Array[StringName] = candidate.suspected_role_ids
		var listed_parts: PackedStringArray = PackedStringArray()
		var listed_set: Dictionary = {}
		var represented_for_list_budget: Dictionary = {}
		var critic_fake_role_id: StringName = &""
		for role_id: StringName in listed:
			listed_parts.append(String(role_id))
			listed_set[role_id] = true
			var listed_role: RoleDefinition = roles_by_id.get(role_id, null) as RoleDefinition
			lists_valid = lists_valid and request.allowed_role_ids.has(role_id) and listed_role != null and not listed_role.is_fixture_placeholder
		suspect_lists[",".join(listed_parts)] = true
		lists_valid = lists_valid and listed_set.size() == listed.size() and listed.size() < request.allowed_role_ids.size()
		var signature_matches: bool = candidate.fingerprint == entry.candidate_signature
		signatures_stable = signatures_stable and signature_matches
		var solved: CaseGeneratorSolverResult = generator.public_solver_result(candidate, roles) as CaseGeneratorSolverResult
		if solved != null and not solved.performance_diagnostics.is_empty():
			var solve_elapsed_ms: int = int(
				solved.performance_diagnostics.get("elapsed_ms", 0)
			)
			solver_solve_count += 1
			solver_total_ms += solve_elapsed_ms
			if solver_solve_count == 1 or solve_elapsed_ms > solver_max_ms:
				solver_max_ms = solve_elapsed_ms
				solver_max_root_seed = entry.root_seed
				solver_max_accepted_seed = entry.accepted_derived_seed
		var solver_matches_truth: bool = solved != null and solved.compare_unique_solution_to_ground_truth(candidate.hidden_case_draft.hidden_evil_suspect_ids)
		solver_valid = solver_valid and solver_matches_truth
		if not signature_matches or not solver_matches_truth:
			var solved_status: String = String(solved.status) if solved != null else "null"
			var solved_evil_ids: PackedInt32Array = solved.unique_evil_suspect_ids if solved != null else PackedInt32Array()
			print("VARIETY_REGRESSION_DIAG root_seed=%d accepted_seed=%d suspect_count=%d signature_matches=%s solver_matches_truth=%s solver_status=%s truth_evil=%s solver_evil=%s" % [
				entry.root_seed, entry.accepted_derived_seed, suspect_count, str(signature_matches), str(solver_matches_truth),
				solved_status, str(candidate.hidden_case_draft.hidden_evil_suspect_ids), str(solved_evil_ids),
			])
		var role_ids: Array[String] = []
		var placements: Array[String] = []
		var clue_ids: Array[String] = []
		var combined_evil_group_count: int = 0
		for suspect in candidate.hidden_case_draft.suspects:
			if suspect != null:
				role_ids.append(String(suspect.true_role_id))
				represented_for_list_budget[suspect.true_role_id] = true
				if suspect.true_role_id == &"critic":
					# Critic's displayed role stays current-absent and consumes a red-herring slot.
					critic_fake_role_id = suspect.displayed_role_id
				else:
					represented_for_list_budget[suspect.displayed_role_id] = true
				lists_valid = lists_valid and listed_set.has(suspect.true_role_id) and listed_set.has(suspect.displayed_role_id)
				role_frequency[String(suspect.true_role_id)] = int(role_frequency.get(String(suspect.true_role_id), 0)) + 1
				if suspect.role_group == CaseEnums.RoleGroup.TONG_PHAM or suspect.role_group == CaseEnums.RoleGroup.NGHICH_THAN:
					combined_evil_group_count += 1
				placements.append("%d:%d" % [suspect.suspect_id, suspect.board_slot])
				if not candidate.hidden_case_draft.hidden_evil_suspect_ids.is_empty() and suspect.suspect_id == candidate.hidden_case_draft.hidden_evil_suspect_ids[0]:
					var position_key: String = str(suspect.board_slot)
					first_evil_position_frequency[position_key] = int(first_evil_position_frequency.get(position_key, 0)) + 1
		var red_herring_count: int = 0
		evil_counts_valid = (
			evil_counts_valid
			and combined_evil_group_count == candidate.hidden_case_draft.hidden_evil_suspect_ids.size()
			and combined_evil_group_count <= GENERATOR.MAX_3X3_EVIL_COUNT
		)
		for role_id: StringName in listed:
			if not represented_for_list_budget.has(role_id):
				red_herring_count += 1
		var red_herring_budget: int = 2 if suspect_count <= 6 else 1
		lists_valid = lists_valid and red_herring_count == red_herring_budget
		if not String(critic_fake_role_id).is_empty():
			var critic_case: CaseDefinition = generator.case_definition_from_result(candidate)
			var critic_runtime: CaseRuntimeState = CaseRuntimeState.new()
			var no_players: Array[PlayerCaseState] = []
			critic_runtime.initialize(critic_case, no_players)
			if critic_case.startup_barkeep_source_suspect_id > 0:
				var transform: BarkeepTransformationRecord = BarkeepTransformationService.new().resolve_transformation(
					critic_case, critic_runtime,
					critic_case.startup_barkeep_source_suspect_id,
					critic_case.startup_barkeep_target_suspect_id,
					roles
				)
				lists_valid = lists_valid and transform != null and transform.applied
			lists_valid = (
				lists_valid
				and listed_set.has(critic_fake_role_id)
				and CaseRolePoolService.is_listed_current_role_absent(
					critic_case, critic_runtime, critic_fake_role_id
				)
			)
		for clue in candidate.hidden_case_draft.public_clues:
			if clue != null:
				clue_ids.append("%s:%d:%s" % [String(clue.behavior_role_id), clue.payload_kind, clue.text])
		role_ids.sort()
		role_compositions[",".join(role_ids)] = true
		board_placements[",".join(placements)] = true
		clue_combinations["|".join(clue_ids)] = true
	var tested_roots: int = warehouse.produced_count + warehouse.rejected_root_count + warehouse.duplicate_skipped_count
	var metrics_data: Dictionary = {
		"roots_tested": tested_roots,
		"accepted_cases": warehouse.entries.size(),
		"distinct_case_signatures": signatures.size(),
		"distinct_suspect_lists": suspect_lists.size(),
		"suspect_count_histogram": suspect_count_histogram,
		"distinct_board_layouts": board_placements.size(),
		"distinct_evil_sets": evil_sets.size(),
		"role_frequency": role_frequency,
		"first_evil_position_frequency": first_evil_position_frequency,
		"rejected_by_count_and_reason": warehouse.failure_summary,
		"signatures": signatures.size(),
		"evil_sets": evil_sets.size(),
		"first8_evil_sets": first_eight_evil_sets.size(),
		"roles": role_compositions.size(),
		"boards": board_placements.size(),
		"clues": clue_combinations.size(),
		"solver_solve_count": solver_solve_count,
		"solver_total_ms": solver_total_ms,
		"solver_average_ms": (
			float(solver_total_ms) / float(solver_solve_count)
			if solver_solve_count > 0 else 0.0
		),
		"solver_max_ms": solver_max_ms,
		"solver_max_root_seed": solver_max_root_seed,
		"solver_max_accepted_seed": solver_max_accepted_seed,
	}
	var metrics: String = JSON.stringify(metrics_data)
	rows.append(_row("Production warehouse has distinct verified signatures", warehouse.entries.size() >= 3 and signatures.size() == warehouse.entries.size(), metrics))
	rows.append(_row("Production warehouse Evil suspect number varies", tested_roots == roots.size() and evil_sets.size() > 1 and first_eight_evil_sets.size() > 1, metrics))
	rows.append(_row("Production warehouse changes roles, board and clues", role_compositions.size() > 1 and board_placements.size() > 1 and clue_combinations.size() > 1, metrics))
	var distinct_counts: int = 0
	for count_value: Variant in suspect_count_histogram.values():
		if int(count_value) > 0:
			distinct_counts += 1
	rows.append(_row("Production sweep reaches multiple suspect counts", tested_roots >= 64 and distinct_counts >= 2, metrics))
	rows.append(_row("Production Cases have distinct bounded Suspect Lists", suspect_lists.size() >= 2 and lists_valid, metrics))
	rows.append(_row("Production mixed-count candidates stay solver-unique and signature-stable", solver_valid and signatures_stable and not warehouse.entries.is_empty(), metrics))
	rows.append(_row("Production 3x3 Cases cap combined Underling and Traitor Evil at three", evil_counts_valid and not warehouse.entries.is_empty(), metrics))
	var used_signatures: Array[String] = []
	var selection_request: CaseGenerationRequest = CaseGenerationRequest.create(request.seed, request.board_columns, request.board_rows, request.generation_profile_id, request.allowed_role_ids, request.required_location_ids, 0, request.generator_version)
	var options: CaseSeedWarehouseOptionSetResult = OPTION_COMPOSER.new().compose_options(warehouse, option_seed, used_signatures, selection_request, roles, 3, 24)
	var option_signatures: Dictionary = {}
	for signature: String in options.option_candidate_signatures:
		option_signatures[signature] = true
	rows.append(_row("Production M5A still offers three distinct Cases", options.success and option_signatures.size() == 3, metrics))
	var summary_keys: Array[String] = [
		"accepted_cases", "distinct_case_signatures", "distinct_suspect_lists",
		"suspect_count_histogram", "distinct_board_layouts", "distinct_evil_sets",
		"role_frequency", "first_evil_position_frequency", "signatures", "evil_sets",
		"first8_evil_sets", "roles", "boards", "clues",
		"solver_solve_count", "solver_total_ms", "solver_average_ms",
		"solver_max_ms", "solver_max_root_seed", "solver_max_accepted_seed",
	]
	var summary_lines: PackedStringArray = PackedStringArray(["=== PRODUCTION VARIETY SUMMARY ==="])
	for key: String in summary_keys:
		summary_lines.append("%s: %s" % [key, JSON.stringify(metrics_data[key])])
	summary_lines.append("=== END PRODUCTION VARIETY SUMMARY ===")
	var summary_text: String = "\n".join(summary_lines)
	print(summary_text)
	var summary_file: FileAccess = FileAccess.open("user://production_variety_summary.txt", FileAccess.WRITE)
	if summary_file == null:
		push_warning("Could not write production variety summary to user://production_variety_summary.txt")
	else:
		summary_file.store_string(summary_text)
		summary_file.close()
	return rows


func _join_ints(values: PackedInt32Array) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for value: int in values:
		parts.append(str(value))
	return ",".join(parts)


func _row(name: String, passed: bool, detail: String = "Stored Match seed, deterministic production diversity") -> Dictionary:
	return {"name": name, "passed": passed, "detail": detail}
