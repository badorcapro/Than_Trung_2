using UnityEngine;

namespace Quirks;

public class ViolentPiracy : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.VIOLENT_PIRACY;

	protected override string english_name => "Violent Piracy";

	protected override string english_description => "The " + Roles.PIRATE.toString() + " will now always " + Keywords.KILL.toString() + " when you move the " + Keywords.BOAT.toString() + " onto one of their " + TextHelper.adjacentNeighbours + ".";

	public override string description_white => base.description.colourSpriteLink("adjacent", new Color(1f, 1f, 1f, 1f));

	public override bool is_marker_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.DOCKS;
	}
}
