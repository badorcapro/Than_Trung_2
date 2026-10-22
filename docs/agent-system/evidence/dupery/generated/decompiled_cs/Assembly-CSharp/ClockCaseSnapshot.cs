using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

public class ClockCaseSnapshot : CaseSnapshot
{
	public bool reputation_hidden;

	public ClockCaseActionPayload clock_payload => base.payload as ClockCaseActionPayload;

	public int visual_hours_passed { get; private set; }

	public ReputationStatus visual_reputation_status { get; private set; }

	public Maybe<string> reputation_comment { get; private set; } = new Maybe<string>();

	public override bool case_lost => clock_payload.reputation <= 0;

	public ClockCaseSnapshot(ClockCaseActionPayload _payload, bool _case_solved, Dictionary<RoleClassifications, int> _classification_ratio, HashSet<RoleData> _suspect_list, HashSet<RoleData> _true_suspect_list, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _visual_time_passed, ReputationStatus _visual_rep_status, CaseReputationManager _rep_manager)
		: base(_case_solved, _payload, _classification_ratio, _suspect_list, _true_suspect_list, _board)
	{
		visual_hours_passed = _visual_time_passed;
		visual_reputation_status = _visual_rep_status;
		reputation_comment = ((_rep_manager.reputation_comment.Length < 2) ? new Maybe<string>() : _rep_manager.reputation_comment.maybe());
		reputation_hidden = _rep_manager.hidden_reputation;
	}

	public void changeVisualHoursPassed(int _hours_passed)
	{
		visual_hours_passed = _hours_passed;
	}

	public override string debugPrint(List<CaseQuirks> _case_quirks)
	{
		return $"Hours Passed: {clock_payload.hour_passed} (v: {visual_hours_passed})\n" + $"Reputation: {clock_payload.reputation}\n" + "Reputation Comment: " + (reputation_comment.is_some ? reputation_comment.value : "*EMPTY*") + "\n" + base.debugPrint(_case_quirks);
	}

	public override string debugPrintExtra(List<CaseQuirks> _case_quirks)
	{
		return $"Hours Passed: {clock_payload.hour_passed} (v: {visual_hours_passed})\n" + $"Reputation: {clock_payload.reputation}\n" + "Reputation Comment: " + (reputation_comment.is_some ? reputation_comment.value : "*EMPTY*") + "\n" + base.debugPrintExtra(_case_quirks);
	}
}
