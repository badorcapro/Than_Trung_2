using System;
using System.Collections.Generic;
using GRGLib.Generic;
using Leads;
using Save;
using UnityEngine;

namespace AlternateModes;

public class SpectresDreamALMD : AlternateLeadModeData
{
	public override AlternateModeTypes mode_type => AlternateModeTypes.SPECTRES_DREAM;

	protected override string english_name => "Spectre's Dream";

	protected override string english_description => "A " + Keywords.LEAD.toString() + " where every " + Keywords.ROLE.toString() + " in every " + Keywords.CASE.toString() + " starts " + TextHelper.obscured + ".";

	public override LeadProgressionManager createLeadProgressionManager(Regions _region, RegionsSO _regions_data, RegionProgressionSaveData _progression, System.Random _rng)
	{
		return createBasicProgressionManager(_region, _regions_data, _progression);
	}

	public override Lead createLead(LeadProgressionManager _manager, RegionsSO _regions_data, RegionProgressionSaveData _progression, System.Random _rng)
	{
		Lead lead = createBasicLead(_manager.region, _regions_data, _progression.tier, new Vector2Int(3, 3), new MinMaxFloat(0.2f, 0.8f), 7, _rng);
		lead.updateClueList(new List<Clue>
		{
			new QuirkClue(_immutable: true, CaseQuirks.SPECTRES_DREAM)
		});
		return lead;
	}
}
