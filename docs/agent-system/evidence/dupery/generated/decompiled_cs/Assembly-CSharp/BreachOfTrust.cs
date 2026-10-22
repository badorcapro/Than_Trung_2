using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Leads;
using Quirks;

public class BreachOfTrust : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.BREACH_OF_TRUST;

	protected override string english_name => "Breach of Trust";

	protected override string english_description => Keywords.SELF_CONFIRM.toStringCap() + " " + TextHelper.roles + " cannot be " + Keywords.SUSPECTED.toString() + ".";

	public override bool is_suspect_removal_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type switch
		{
			CaseType.CLOCK => true, 
			CaseType.CASINO => true, 
			CaseType.BACK_ALLEYS => true, 
			_ => false, 
		};
	}

	public override Maybe<Roles> onSuspectRemoval(Roles _removal, bool _force, List<Roles> _from)
	{
		if (!_removal.createEmptyRole().generation_constraint.isOfMarker(RoleGenerationMarkers.SELF_CONFIRM))
		{
			return new Maybe<Roles>();
		}
		return new Maybe<Roles>(_removal);
	}

	public override bool isValidForClue(List<CaseQuirks> _quirks, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (!isRoleOfMarkerAlwaysSuspected(RoleGenerationMarkers.SELF_CONFIRM, _forced))
		{
			return !_quirks.Contains(CaseQuirks.UNHOLY_LAND);
		}
		return false;
	}

	public override List<Roles> filterRoleForClues(List<Roles> _roles, ClueTypes _type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return _roles.Where((Roles _r) => !_r.createEmptyRole().generation_constraint.isOfMarker(RoleGenerationMarkers.SELF_CONFIRM)).ToList();
	}
}
