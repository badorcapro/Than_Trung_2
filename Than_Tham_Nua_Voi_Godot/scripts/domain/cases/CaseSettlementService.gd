class_name CaseSettlementService
extends RefCounted

const CaseRoleModifierServiceScript := preload("res://scripts/domain/cases/CaseRoleModifierService.gd")

var _submission_service := CaseSubmissionService.new()

func settle(case_definition: CaseDefinition, runtime: CaseRuntimeState) -> CaseSettlementResult:
	if case_definition == null or runtime == null or not runtime.is_initialized:
		return CaseSettlementResult.failed(&"SETTLEMENT_CONTEXT_INVALID", "Dữ liệu quyết toán không hợp lệ.")
	if runtime.is_settled:
		return runtime.settlement_result
	if runtime.case_outcome not in [CaseEnums.CaseOutcome.EARLY_SOLVED, CaseEnums.CaseOutcome.ALL_FAILED_EARLY, CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED]:
		return CaseSettlementResult.failed(&"CASE_NOT_COMPLETE", "Chỉ quyết toán sau khi Kỳ Án kết thúc.")
	var evaluations: Dictionary = {}
	for submission in runtime.submissions + runtime.final_submissions:
		var evaluated: CaseSubmissionResult = _submission_service.evaluate_locked(case_definition, submission, runtime)
		if evaluated.success:
			evaluations[submission.player_id] = {"result": evaluated, "phase": submission.submission_phase}
	var correct_count := 0
	for player_id in evaluations:
		if evaluations[player_id].result.main_answer_correct:
			correct_count += 1
	var merit_share := 0.0
	if runtime.case_outcome == CaseEnums.CaseOutcome.EARLY_SOLVED:
		merit_share = float(case_definition.merit_pool)
	elif runtime.case_outcome == CaseEnums.CaseOutcome.FINAL_VERDICT_RESOLVED and correct_count > 0:
		merit_share = _round_two(float(case_definition.merit_pool) / float(correct_count))
	var settlement := CaseSettlementResult.new()
	settlement.success = true
	settlement.case_outcome = runtime.case_outcome
	for player in runtime.players:
		var resolution := _build_resolution(case_definition, runtime, player, evaluations.get(player.player_id), merit_share)
		settlement.player_resolutions.append(resolution)
		if resolution.main_answer_correct:
			settlement.correct_solver_ids.append(player.player_id)
	for resolution in settlement.player_resolutions:
		_apply_resolution(runtime.find_player(resolution.player_id), resolution.reward)
	runtime.settlement_result = settlement
	runtime.is_settled = true
	return settlement

func _build_resolution(c: CaseDefinition, runtime: CaseRuntimeState, player: PlayerCaseState, entry: Variant, merit_share: float) -> PlayerCaseResolution:
	var resolution := PlayerCaseResolution.new()
	resolution.player_id = player.player_id
	resolution.display_name = player.display_name
	var delta := resolution.reward
	delta.merit_before = player.merit
	delta.reputation_before = player.reputation
	delta.orb_before = player.orb_count
	delta.tickets_before = player.gacha_ticket_count
	if entry == null:
		resolution.outcome = CaseEnums.PlayerResolutionOutcome.NOT_SUBMITTED_CASE_ENDED
	else:
		var evaluated: CaseSubmissionResult = entry.result
		resolution.submission_phase = entry.phase
		resolution.main_answer_correct = evaluated.main_answer_correct
		resolution.underling_classification_correct = evaluated.underling_classification_correct
		resolution.traitor_classification_correct = evaluated.traitor_classification_correct
		if evaluated.main_answer_correct:
			resolution.outcome = CaseEnums.PlayerResolutionOutcome.CORRECT_EARLY if entry.phase == CaseEnums.SubmissionPhase.EARLY else CaseEnums.PlayerResolutionOutcome.CORRECT_FINAL
			delta.merit_delta = merit_share
			delta.reputation_delta = c.on_solve.reputation_delta if c.on_solve != null else 0
			delta.base_ticket_delta = c.base_ticket_reward
		else:
			resolution.outcome = CaseEnums.PlayerResolutionOutcome.WRONG_EARLY if entry.phase == CaseEnums.SubmissionPhase.EARLY else CaseEnums.PlayerResolutionOutcome.WRONG_FINAL
			delta.reputation_delta = -c.reputation_penalty_on_wrong
			delta.orb_delta = 1
	delta.reputation_delta = CaseRoleModifierServiceScript.adjusted_reputation_delta(player, delta.reputation_delta)
	delta.merit_after = delta.merit_before + delta.merit_delta
	delta.reputation_after = clampi(delta.reputation_before + delta.reputation_delta, 0, 6)
	delta.reputation_delta = delta.reputation_after - delta.reputation_before
	delta.orb_after = delta.orb_before + delta.orb_delta
	delta.tickets_after = delta.tickets_before + delta.total_ticket_delta()
	return resolution

func _apply_resolution(player: PlayerCaseState, delta: PlayerCaseRewardDelta) -> void:
	player.merit = delta.merit_after
	player.reputation = delta.reputation_after
	player.orb_count = delta.orb_after
	player.gacha_ticket_count = delta.tickets_after

func _round_two(value: float) -> float:
	return round(value * 100.0) / 100.0
