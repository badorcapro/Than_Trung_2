using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Leads;

namespace Save;

[Serializable]
public class RegionSaveData
{
	public Regions region;

	public List<CaseQuirks> case_quirks;

	public int region_progress;

	public Maybe<LeadSaveData> current_lead;

	public string unique_data;

	public RegionSaveData(RegionState _region)
	{
		region = _region.region;
		case_quirks = _region.case_quirks;
		region_progress = _region.region_progress;
		current_lead = _region.current_lead.fmap((Lead _l) => new LeadSaveData(_l));
		unique_data = _region.getUniqueData();
	}

	public RegionSaveData()
	{
		region = Regions.NONE;
		case_quirks = new List<CaseQuirks>();
		region_progress = -1;
		current_lead = new Maybe<LeadSaveData>();
		unique_data = "";
	}
}
