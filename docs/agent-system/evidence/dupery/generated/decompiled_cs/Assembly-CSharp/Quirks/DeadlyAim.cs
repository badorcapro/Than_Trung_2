using System.Collections.Generic;
using Leads;

namespace Quirks;

public class DeadlyAim : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.DEADLY_AIM;

	protected override string english_name => "Deadly Aim";

	protected override string english_description => "The " + Roles.HITMAN.toString() + " will only " + Keywords.KILL.toString() + " " + TextHelper.goodRoles + ".";

	public override bool is_marker_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.CLOCK;
	}

	public override bool canAdd(List<Roles> _available_roles, List<CaseQuirks> _in_play_quirks, CaseType _case_type)
	{
		if (_available_roles.Contains(Roles.HITMAN))
		{
			return base.canAdd(_available_roles, _in_play_quirks, _case_type);
		}
		return false;
	}

	public override bool isValidForClue(List<CaseQuirks> _quirks, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return canRoleAppearInPlay(Roles.HITMAN, _unforced, _forced);
	}
}
