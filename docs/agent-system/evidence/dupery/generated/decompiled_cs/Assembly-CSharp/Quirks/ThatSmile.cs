using System.Collections.Generic;
using Leads;
using UnityEngine;

namespace Quirks;

public class ThatSmile : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.THAT_SMILE;

	protected override string english_name => "That Smile";

	protected override string english_description => "The " + Roles.IDOL.toString() + " now " + TextHelper.taints + " all " + RoleClassifications.INNOCENT.toString() + " " + TextHelper.surroundingNeighbours + ".";

	public override string description_white => base.description.colourSpriteLink("surrounding", Color.white);

	public override bool is_marker_quirk => true;

	public override bool canAdd(List<Roles> _available_roles, List<CaseQuirks> _in_play_quirks, CaseType _case_type)
	{
		if (_available_roles.Contains(Roles.IDOL))
		{
			return base.canAdd(_available_roles, _in_play_quirks, _case_type);
		}
		return false;
	}

	public override bool isValidForClue(List<CaseQuirks> _quirks, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return canRoleAppearInPlay(Roles.IDOL, _unforced, _forced);
	}
}
