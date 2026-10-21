using System;
using System.Collections.Generic;

namespace Save;

[Serializable]
public class RegionSaveDatav0_5_19
{
	public Regions region;

	public List<CaseQuirks> quirks = new List<CaseQuirks>();

	public string data;

	public RegionSaveDatav0_5_19(Regions _region, List<CaseQuirks> _quirks, string _unique_data)
	{
		region = _region;
		quirks = _quirks;
		data = _unique_data;
	}
}
