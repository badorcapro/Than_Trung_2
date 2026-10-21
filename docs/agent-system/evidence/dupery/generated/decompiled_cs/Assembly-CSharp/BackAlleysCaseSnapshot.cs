using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

public class BackAlleysCaseSnapshot : CaseSnapshot
{
	public BackAlleysCaseActionPayload back_alleys_payload => base.payload as BackAlleysCaseActionPayload;

	public override bool case_lost => back_alleys_payload.current_health <= 0;

	public BackAlleysCaseSnapshot(BackAlleysCaseActionPayload _payload, bool _case_solved, Dictionary<RoleClassifications, int> _classification_ratio, HashSet<RoleData> _suspect_list, HashSet<RoleData> _true_suspect_list, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
		: base(_case_solved, _payload, _classification_ratio, _suspect_list, _true_suspect_list, _board)
	{
	}

	public override string debugPrint(List<CaseQuirks> _case_quirks)
	{
		return $"Health: {back_alleys_payload.current_health}/{back_alleys_payload.max_health}\n" + base.debugPrint(_case_quirks);
	}

	public override string debugPrintExtra(List<CaseQuirks> _case_quirks)
	{
		return $"Health: {back_alleys_payload.current_health}/{back_alleys_payload.max_health}\n" + base.debugPrintExtra(_case_quirks);
	}
}
