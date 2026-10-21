using System;
using System.Collections.Generic;
using Leads;
using Save;

namespace AlternateModes;

public class RandomQuirksALMD : AlternateLeadModeData, IChangeEvents
{
	public override AlternateModeTypes mode_type => AlternateModeTypes.RANDOM_QUIRKS;

	protected override string english_name => "Random Quirks";

	protected override string english_description => "A " + Keywords.LEAD.toString() + " where you get a random " + Keywords.QUIRK.toString() + " " + Keywords.STAMP.toString() + " between each " + Keywords.CASE.toString() + ".";

	public override LeadProgressionManager createLeadProgressionManager(Regions _region, RegionsSO _regions_data, RegionProgressionSaveData _progression, Random _rng)
	{
		LeadProgressionManager leadProgressionManager = createBasicProgressionManager(_region, _regions_data, _progression);
		leadProgressionManager.setAltMode(this);
		return leadProgressionManager;
	}

	public override Lead createLead(LeadProgressionManager _manager, RegionsSO _regions_data, RegionProgressionSaveData _progression, Random _rng)
	{
		Lead lead = _manager.createRegionLeads(_rng, _force_new: false, 1)[0];
		lead.setLeadLength(7);
		return lead;
	}

	public List<LeadEvent> getCustomEvent(LeadProgressionManager _progression, int _case_nb, Lead _lead, Random _rng)
	{
		List<LeadEvent> list = new List<LeadEvent>();
		List<CaseQuirks> availableQuirks = _progression.getAvailableQuirks();
		if (_lead.current_board_size.x < 4 && _case_nb > 2)
		{
			list.Add(new IncreaseBoardSizeEvent(_rng, _lead, _show_exact: true));
			return list;
		}
		if (_lead.clues.Count >= 10)
		{
			for (int i = 0; i < 9; i++)
			{
				if (list.Count != 0)
				{
					break;
				}
				list.Add(new ReplaceOneQuirkEvent(_rng, _lead, list, availableQuirks, (CaseQuirks _q) => true, _show_exact: false));
				list.RemoveAll((LeadEvent _e) => !_e.isValidForCurrentLead(_lead));
			}
			return list;
		}
		for (int j = 0; j < 9; j++)
		{
			if (list.Count != 0)
			{
				break;
			}
			list.Add(new AddSingleRandomQuirkEvent(_rng, _lead, list, availableQuirks, (CaseQuirks _q) => true, _show_real: false));
			list.RemoveAll((LeadEvent _e) => !_e.isValidForCurrentLead(_lead));
		}
		return list;
	}
}
