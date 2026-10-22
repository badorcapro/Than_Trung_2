using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace Save;

[Serializable]
public class _dep_RegionSaveData
{
	public Regions region;

	public List<CaseQuirks> quirks = new List<CaseQuirks>();

	public int progress_id;

	public RegionEventsType region_event;

	public string data;

	public _dep_RegionSaveData()
	{
		List<CaseQuirks> list = new List<CaseQuirks>();
		region = Regions.NONE;
		quirks = list;
		progress_id = -101;
		region_event = (RegionEventsType)(-1);
		data = "";
	}

	public _dep_RegionSaveData(Regions _region, List<CaseQuirks> _quirks, int _node_id, RegionEventsType _event_type, string _unique_data)
	{
		region = _region;
		quirks = _quirks;
		progress_id = _node_id;
		region_event = _event_type;
		data = _unique_data;
	}

	public Maybe<_dep_RegionState> load()
	{
		switch (region)
		{
		case Regions.DEMO:
		case Regions.TEST_1:
		case Regions.QUIRK_I:
		case Regions.QUIRK_II:
		case Regions.QUIRK_III:
		case Regions.OFFICE:
			return ((_dep_RegionState)new _dep_ClockRegionState(this)).maybe();
		case Regions.DOCKS:
			return ((_dep_RegionState)new _dep_DocksRegionState(this)).maybe();
		case Regions.CASINO:
			return ((_dep_RegionState)new _dep_CasinoRegionState(this)).maybe();
		case Regions.BACK_ALLEYS:
			return ((_dep_RegionState)new _dep_BackAlleysRegionState(this)).maybe();
		case Regions.NONE:
			return new Maybe<_dep_RegionState>();
		default:
			Debug.LogError($"No region state load function set up for region type {region}!");
			return new Maybe<_dep_RegionState>();
		}
	}
}
