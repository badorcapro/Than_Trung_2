using System.Collections.Generic;
using Leads;

namespace Quirks;

public class DarkWhispers : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.DARK_WHISPERS;

	protected override string english_name => "Dark Whispers";

	protected override string english_description => "The " + Roles.GOSSIP.toString() + " will choose a " + RoleClassifications.TRAITOR.toString() + " if possible.";

	public override bool is_marker_quirk => true;

	public override bool canAdd(List<Roles> _available_roles, List<CaseQuirks> _in_play_quirks, CaseType _case_type)
	{
		if (_available_roles.Contains(Roles.GOSSIP))
		{
			return base.canAdd(_available_roles, _in_play_quirks, _case_type);
		}
		return false;
	}

	public override bool isValidForClue(List<CaseQuirks> _quirks, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return canRoleAppearInPlay(Roles.GOSSIP, _unforced, _forced);
	}
}
