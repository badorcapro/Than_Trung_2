using System.Collections.Generic;
using Leads;

namespace Quirks;

public class GoodIntuition : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.GOOD_INTUITION;

	protected override string english_name => "Good Intuition";

	protected override string english_description => "The " + Roles.PARTNER.toString() + " is more likely to " + Keywords.ANNOUNCE.toString() + " the " + Keywords.ADDRESS.toString() + " of an " + TextHelper.underlingRole + ".";

	public override bool is_marker_quirk => true;

	public override bool canAdd(List<Roles> _available_roles, List<CaseQuirks> _in_play_quirks, CaseType _case_type)
	{
		if (_available_roles.Contains(Roles.PARTNER))
		{
			return base.canAdd(_available_roles, _in_play_quirks, _case_type);
		}
		return false;
	}

	public override bool isValidForClue(List<CaseQuirks> _quirks, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return canRoleAppearInPlay(Roles.PARTNER, _unforced, _forced);
	}
}
