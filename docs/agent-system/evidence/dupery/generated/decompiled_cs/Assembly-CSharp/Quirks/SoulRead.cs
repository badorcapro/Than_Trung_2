using System;
using UnityEngine;

namespace Quirks;

public class SoulRead : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.SOUL_READ;

	protected override string english_name => "Soul Read";

	protected override string english_description => "Everytime a " + Keywords.ROLE.toString() + " " + TextHelper.dies + ", discard a random " + Keywords.CARD.toString() + " and draw a new one of the " + TextHelper.suitAssociated + " with the " + Keywords.DEAD.toString() + " " + Keywords.ROLE.toString() + "'s " + Keywords.CLASSIFICATION.toString() + ".";

	public override bool is_kill_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.CASINO;
	}

	public override void onKill(Case _case, RoleData _killed_role, bool _was_alive, System.Random _rng)
	{
		if (!(_case is CasinoCase casinoCase))
		{
			Debug.LogError($"{quirk_type} is a casino quirk! Cannot be in {_case.case_type} case!");
		}
		else if (_was_alive && _killed_role.getIsDead())
		{
			bool flag = _rng.Next(0, 2) == 1;
			casinoCase.drawNewCards(_killed_role.getVisualClassification().toSuit(), flag, !flag);
		}
	}
}
