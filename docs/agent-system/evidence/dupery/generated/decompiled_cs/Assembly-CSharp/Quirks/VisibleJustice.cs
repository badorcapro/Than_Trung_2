using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class VisibleJustice : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.VISIBLE_JUSTICE;

	protected override string english_name => "Visible Justice";

	protected override string english_description => "If your " + Keywords.REPUTATION_STATUS.toString() + " is " + ReputationStatus.POOR.toString() + ", " + TextHelper.arresting + " a " + RoleClassifications.TRAITOR.toString() + " increases your " + Keywords.REPUTATION.toString() + " by 1.";

	public override bool is_arrest_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type switch
		{
			CaseType.CLOCK => true, 
			CaseType.DOCKS => true, 
			_ => false, 
		};
	}

	public override void onArrest(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, RoleData _arrested_role, System.Random _rng)
	{
		if (_arrested_role.getTrueClassification() != RoleClassifications.TRAITOR)
		{
			return;
		}
		if (_case is ClockCase clockCase)
		{
			if (clockCase.reputation_status == ReputationStatus.POOR)
			{
				clockCase.addReputation(1);
			}
		}
		else if (_case is DocksCase docksCase)
		{
			if (docksCase.reputation_status == ReputationStatus.POOR)
			{
				docksCase.addReputation(1);
			}
		}
		else
		{
			Debug.LogError($"onArrest is not set up for case type {_case.case_type}! {quirk_type}");
		}
	}
}
