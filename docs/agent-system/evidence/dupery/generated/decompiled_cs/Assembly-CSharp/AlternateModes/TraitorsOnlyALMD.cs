using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Generic;
using Leads;
using Save;
using UnityEngine;

namespace AlternateModes;

public class TraitorsOnlyALMD : AlternateLeadModeData
{
	public override AlternateModeTypes mode_type => AlternateModeTypes.TRAITOR_ONLY;

	protected override string english_name => "Traitorous Syndicate";

	protected override string english_description => "A " + Keywords.LEAD.toString() + " where every " + Keywords.CASE.toString() + " has a " + RoleClassifications.TRAITOR.toString() + " " + Keywords.IN_PLAY.toString() + ".";

	public override LeadProgressionManager createLeadProgressionManager(Regions _region, RegionsSO _regions_data, RegionProgressionSaveData _progression, System.Random _rng)
	{
		return createBasicProgressionManager(_region, _regions_data, _progression);
	}

	public override Lead createLead(LeadProgressionManager _manager, RegionsSO _regions_data, RegionProgressionSaveData _progression, System.Random _rng)
	{
		RegionDataSO regionDataSO = _regions_data[_manager.region];
		List<Roles> available = regionDataSO.createAvailableRoles(_prime_suspects: (from _r in regionDataSO.getAvailableRoles(_progression.tier)
			where _r.getClassificationFromRoleType() == RoleClassifications.TRAITOR
			select _r).ToList(), _tier: _progression.tier, _rng: _rng);
		Lead lead = createBasicLead(_manager.region, available, new Vector2Int(4, 4), new MinMaxFloat(0.5f, 1f), 8, _regions_data.getEmptyPrimeSuspectSet());
		lead.setForcedEndTraitorCases(99);
		return lead;
	}
}
