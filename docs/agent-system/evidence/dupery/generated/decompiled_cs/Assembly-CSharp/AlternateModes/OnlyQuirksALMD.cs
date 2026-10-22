using System;
using System.Collections.Generic;
using Leads;
using Save;

namespace AlternateModes;

public class OnlyQuirksALMD : AlternateLeadModeData, IChangeEvents
{
	public override AlternateModeTypes mode_type => AlternateModeTypes.ONLY_QUIRKS;

	protected override string english_name => "Quirks Only";

	protected override string english_description => "A " + Keywords.LEAD.toString() + " where every " + Keywords.STAMP.toString() + " choice is always a choice between 3 random " + TextHelper.quirks + ".";

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
			list.Add(new ReplaceOneQuirkEvent(_rng, _lead, list, availableQuirks, (CaseQuirks _q) => true, _show_exact: true));
			list.Add(new ReplaceOneQuirkEvent(_rng, _lead, list, availableQuirks, (CaseQuirks _q) => true, _show_exact: true));
			list.Add(new ReplaceOneQuirkEvent(_rng, _lead, list, availableQuirks, (CaseQuirks _q) => true, _show_exact: true));
		}
		else
		{
			list.Add(new AddSingleRandomQuirkEvent(_rng, _lead, list, availableQuirks, (CaseQuirks _q) => true, _show_real: true));
			list.Add(new AddSingleRandomQuirkEvent(_rng, _lead, list, availableQuirks, (CaseQuirks _q) => true, _show_real: true));
			list.Add(new AddSingleRandomQuirkEvent(_rng, _lead, list, availableQuirks, (CaseQuirks _q) => true, _show_real: true));
		}
		list.RemoveAll((LeadEvent _e) => !_e.isValidForCurrentLead(_lead));
		if (list.Count < 2)
		{
			list.Add(new RemoveOneQuirkEvent(_rng, _lead, list, _show_exact: true));
			list.Add(new RemoveOneQuirkEvent(_rng, _lead, list, _show_exact: true));
			list.RemoveAll((LeadEvent _e) => !_e.isValidForCurrentLead(_lead));
		}
		return list;
	}
}
