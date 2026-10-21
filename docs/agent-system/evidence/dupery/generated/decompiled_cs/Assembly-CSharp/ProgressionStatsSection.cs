using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Generic;
using GRGLib.Maybe;
using GameStats;
using TMPro;
using UnityEngine;

public class ProgressionStatsSection : StatsRegionSection
{
	[SerializeField]
	private RegionsSO regions_data;

	[Header("Text References")]
	[SerializeField]
	private TMP_Text discovery_progress;

	[SerializeField]
	private TMP_Text roles_discovered;

	[SerializeField]
	private TMP_Text location_discovered;

	[SerializeField]
	private TMP_Text quirks_discovered;

	private string loc_pr_key => "StatsProgression [PR]";

	private string loc_rd_key => "StatsProgression [RD]";

	private string loc_ld_key => "StatsProgression [LD]";

	private string loc_qd_key => "StatsProgression [QD]";

	protected override void setUpSection(RunStats _stats, CaseStats _region_stats, Maybe<CaseType> _region)
	{
		MinMaxInt minMaxInt;
		MinMaxInt minMaxInt2;
		MinMaxInt minMaxInt3;
		if (!_region.is_some)
		{
			minMaxInt = new MinMaxInt(GameHandler.StatsData.roles_discovered.Count, new List<Roles>().addAll().Count((Roles _r) => !_r.isScrapped() && !_r.isTest()));
			minMaxInt2 = new MinMaxInt(GameHandler.StatsData.location_discovered.Count, new List<LocationTypes>().addAll().Count((LocationTypes _l) => !_l.isScrapped()));
			minMaxInt3 = new MinMaxInt(GameHandler.StatsData.played_case_quirks.Count, new List<CaseQuirks>().addAll().Count((CaseQuirks _q) => !_q.isScrapped()));
		}
		else
		{
			RegionDataSO region = regions_data[_region.value];
			int tier = 9;
			List<Roles> region_roles = region.getAvailableRoles(tier);
			List<LocationTypes> region_locations = new List<LocationTypes>().addAll((LocationTypes _l) => !_l.isScrapped() && _l.createEmptyLocation().isOfRegion(region.region));
			List<CaseQuirks> region_quirks = region.getAvailableQuirks(tier);
			minMaxInt = new MinMaxInt(GameHandler.StatsData.roles_discovered.Count((Roles _r) => region_roles.Contains(_r)), region_roles.Count);
			minMaxInt2 = new MinMaxInt(GameHandler.StatsData.location_discovered.Count((LocationTypes _l) => region_locations.Contains(_l)), region_locations.Count);
			minMaxInt3 = new MinMaxInt(GameHandler.StatsData.played_case_quirks.Count((CaseQuirks _q) => region_quirks.Contains(_q)), region_quirks.Count);
		}
		float num = 100f * (float)(minMaxInt.min + minMaxInt2.min + minMaxInt3.min) / (float)(minMaxInt.max + minMaxInt2.max + minMaxInt3.max);
		discovery_progress.text = translate(loc_pr_key, progressEnglish, num.ToString("0.0"));
		roles_discovered.text = translate(loc_rd_key, rolesDiscoveredEnglish, minMaxInt.min, minMaxInt.max);
		location_discovered.text = translate(loc_ld_key, locationsDiscoveredEnglish, minMaxInt2.min, minMaxInt2.max);
		quirks_discovered.text = translate(loc_qd_key, quirksDiscoveredEnglish, minMaxInt3.min, minMaxInt3.max);
	}

	private string progressEnglish(string _data)
	{
		return "Progress: " + _data + "%";
	}

	private string rolesDiscoveredEnglish(string _data_1, string _data_2)
	{
		return "Roles Discovered: " + _data_1 + "/" + _data_2;
	}

	private string locationsDiscoveredEnglish(string _data_1, string _data_2)
	{
		return "Locations Discovered: " + _data_1 + "/" + _data_2;
	}

	private string quirksDiscoveredEnglish(string _data_1, string _data_2)
	{
		return "Case Quirks Discovered: " + _data_1 + "/" + _data_2;
	}
}
