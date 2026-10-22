using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

public class CasinoCaseSnapshot : CaseSnapshot
{
	public CasinoCaseActionPayload casino_payload => base.payload as CasinoCaseActionPayload;

	public override bool case_lost => casino_payload.chips <= 0;

	public CasinoCaseSnapshot(CasinoCaseActionPayload _payload, bool _case_solved, Dictionary<RoleClassifications, int> _classification_ratio, HashSet<RoleData> _suspect_list, HashSet<RoleData> _true_suspect_list, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
		: base(_case_solved, _payload, _classification_ratio, _suspect_list, _true_suspect_list, _board)
	{
	}

	public override string debugPrint(List<CaseQuirks> _case_quirks)
	{
		return $"Chips: {casino_payload.chips}\nCost Multi: x{casino_payload.cost_multi}\n{base.debugPrint(_case_quirks)}";
	}

	public override string debugPrintExtra(List<CaseQuirks> _case_quirks)
	{
		return $"Chips: {casino_payload.chips}\nCost Multi: x{casino_payload.cost_multi}\n{base.debugPrintExtra(_case_quirks)}";
	}
}
