using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

public class DocksCaseSnapshot : CaseSnapshot
{
	private bool force_lost;

	public DocksCaseActionPayload docks_payload => base.payload as DocksCaseActionPayload;

	public Maybe<string> reputation_comment { get; private set; } = new Maybe<string>();

	public bool reputation_hidden { get; private set; }

	public ReputationStatus visual_reputation_status { get; private set; }

	public override bool case_lost
	{
		get
		{
			if (!force_lost)
			{
				return docks_payload.reputation <= 0;
			}
			return true;
		}
	}

	public DocksCaseSnapshot(DocksCaseActionPayload _payload, bool _case_solved, Dictionary<RoleClassifications, int> _classification_ratio, HashSet<RoleData> _suspect_list, HashSet<RoleData> _true_suspect_list, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, ReputationStatus _visual_rep_status, CaseReputationManager _rep_manager, bool _force_lost)
		: base(_case_solved && !_force_lost, _payload, _classification_ratio, _suspect_list, _true_suspect_list, _board)
	{
		reputation_comment = ((_rep_manager.reputation_comment.Length < 2) ? new Maybe<string>() : _rep_manager.reputation_comment.maybe());
		reputation_hidden = _rep_manager.hidden_reputation;
		force_lost = _force_lost;
		visual_reputation_status = _visual_rep_status;
	}

	public override string debugPrint(List<CaseQuirks> _case_quirks)
	{
		return $"Boat: {docks_payload.boat.position} (fuel: {docks_payload.boat.fuel})\n" + $"Reputation: {docks_payload.reputation}\n" + "Reputation Comment: " + (reputation_comment.is_some ? reputation_comment.value : "*EMPTY*") + "\n" + base.debugPrint(_case_quirks);
	}

	public override string debugPrintExtra(List<CaseQuirks> _case_quirks)
	{
		return $"Boat: {docks_payload.boat.position} (fuel: {docks_payload.boat.fuel})\n" + $"Reputation: {docks_payload.reputation}\n" + "Reputation Comment: " + (reputation_comment.is_some ? reputation_comment.value : "*EMPTY*") + "\n" + base.debugPrintExtra(_case_quirks);
	}
}
