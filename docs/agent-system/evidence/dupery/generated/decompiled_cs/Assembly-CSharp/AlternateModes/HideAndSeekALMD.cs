using System;
using System.Collections.Generic;
using GRGLib.Generic;
using Leads;
using Save;
using UnityEngine;

namespace AlternateModes;

public class HideAndSeekALMD : AlternateLeadModeData
{
	public override AlternateModeTypes mode_type => AlternateModeTypes.HIDE_AND_SEEK;

	protected override string english_name => "Hide And Seek";

	protected override string english_description => "A " + Keywords.LEAD.toString() + " where every " + Keywords.ROLE.toString() + " in every " + Keywords.CASE.toString() + " is " + TextHelper.hidden + " except for the " + Roles.CRABER.toString() + " who is always " + Keywords.IN_PLAY.toString() + ".";

	public override List<Regions> getAvailableRegions()
	{
		return new List<Regions> { Regions.DOCKS };
	}

	public override bool modeUnlocked()
	{
		return GameHandler.MetaData.getTierOfRegion(Regions.DOCKS) >= 3;
	}

	public override LeadProgressionManager createLeadProgressionManager(Regions _region, RegionsSO _regions_data, RegionProgressionSaveData _progression, System.Random _rng)
	{
		return createBasicProgressionManager(Regions.DOCKS, _regions_data, _progression);
	}

	public override Lead createLead(LeadProgressionManager _manager, RegionsSO _regions_data, RegionProgressionSaveData _progression, System.Random _rng)
	{
		Lead lead = createBasicLead(Regions.DOCKS, _regions_data, 3, new Vector2Int(3, 3), new MinMaxFloat(0.2f, 0.8f), 10, _rng);
		lead.updateClueList(new List<Clue>
		{
			new RoleClue(_immutable: false, Roles.CRABER, ClueTypes.ROLE_IN_PLAY),
			new QuirkClue(_immutable: true, CaseQuirks.HIDE_AND_SEEK)
		});
		return lead;
	}
}
