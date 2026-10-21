using System;
using UnityEngine;

namespace Quirks;

public class MortalDread : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.MORTAL_DREAD;

	protected override string english_name => "Mortal Dread";

	protected override string english_description => "When a " + Keywords.ROLE.toString() + " " + TextHelper.dies + ", if your " + Keywords.REPUTATION_STATUS.toString() + " is not " + ReputationStatus.POOR.toString() + ", lose 1 " + Keywords.REPUTATION.toString() + ".";

	public override bool is_kill_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type switch
		{
			CaseType.CLOCK => true, 
			CaseType.DOCKS => true, 
			_ => false, 
		};
	}

	public override void onKill(Case _case, RoleData _killed_role, bool _was_alive, System.Random _rng)
	{
		if (!_killed_role.getIsDead() || !_was_alive)
		{
			return;
		}
		if (_case is ClockCase clockCase)
		{
			if (clockCase.reputation_status != 0)
			{
				clockCase.addReputation(-1);
			}
		}
		else if (_case is DocksCase docksCase)
		{
			if (docksCase.reputation_status != 0)
			{
				docksCase.addReputation(-1);
			}
		}
		else
		{
			Debug.LogError($"No onKill function set up for case type {_case.case_type}! {quirk_type}");
		}
	}
}
