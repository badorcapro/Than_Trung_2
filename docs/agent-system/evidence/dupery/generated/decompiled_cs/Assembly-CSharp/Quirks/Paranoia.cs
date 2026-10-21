using System.Collections.Generic;
using Leads;

namespace Quirks;

public class Paranoia : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.PARANOIA;

	protected override string english_name => "Paranoia";

	protected override string english_description => Keywords.TRUTHFUL.toStringCap() + " " + "Skeptics".asKeyword(Roles.SKEPTIC) + " will " + Keywords.ANNOUNCE.toString() + " nothing unless you have " + ReputationStatus.EXCEPTIONAL.toString() + " " + Keywords.REPUTATION.toString() + ".";

	public override bool is_marker_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.CLOCK;
	}

	public override bool canAdd(List<Roles> _available_roles, List<CaseQuirks> _in_play_quirks, CaseType _case_type)
	{
		if (_available_roles.Contains(Roles.SKEPTIC))
		{
			return base.canAdd(_available_roles, _in_play_quirks, _case_type);
		}
		return false;
	}

	public override bool isValidForClue(List<CaseQuirks> _quirks, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return canRoleAppearInPlay(Roles.SKEPTIC, _unforced, _forced);
	}
}
