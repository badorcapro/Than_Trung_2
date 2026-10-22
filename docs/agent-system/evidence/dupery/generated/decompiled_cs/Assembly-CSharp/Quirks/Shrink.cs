using System.Collections.Generic;
using Leads;
using UnityEngine;

namespace Quirks;

public class Shrink : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.SHRINK;

	protected override string english_name => "Shrink";

	protected override string english_description => "The " + Roles.THERAPIST.toString() + " now considers " + TextHelper.meddlers + " " + Alignments.EVIL.toString() + ".";

	public override string description_white => base.description.colourSpriteLink("adjacent", Color.white);

	public override bool is_marker_quirk => true;

	public override bool canAdd(List<Roles> _available_roles, List<CaseQuirks> _in_play_quirks, CaseType _case_type)
	{
		if (_available_roles.Contains(Roles.THERAPIST))
		{
			return base.canAdd(_available_roles, _in_play_quirks, _case_type);
		}
		return false;
	}

	public override bool isValidForClue(List<CaseQuirks> _quirks, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return canRoleAppearInPlay(Roles.THERAPIST, _unforced, _forced);
	}
}
