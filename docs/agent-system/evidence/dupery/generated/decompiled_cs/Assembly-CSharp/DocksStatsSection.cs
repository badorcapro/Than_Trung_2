using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using GameStats;
using TMPro;
using UnityEngine;

public class DocksStatsSection : StatsRegionSection
{
	[Header("Text References")]
	[SerializeField]
	private TMP_Text fuel_spent;

	[SerializeField]
	private TMP_Text average_fuel_spent;

	[SerializeField]
	private TMP_Text evil_let_loose;

	[SerializeField]
	private TMP_Text sneakiest_evil;

	[Space]
	[SerializeField]
	private bool new_lines = true;

	private string loc_fs_key => "StatsDocks [FS]";

	private string loc_af_key => "StatsDocks [AF]";

	private string loc_eu_key => "StatsDocks [EU]";

	private string loc_se_key => "StatsDocks [SE]";

	protected override void setUpSection(RunStats _stats, CaseStats _region_stats, Maybe<CaseType> _region)
	{
		if (!(_region_stats is DocksCaseStats docksCaseStats))
		{
			Debug.LogError("Given region stats is not DocksCaseStats! This is not allowed!!");
			return;
		}
		float num = Mathf.Max(_stats.getCasesAttempted(CaseType.DOCKS), 1);
		fuel_spent.text = translate(loc_fs_key, fuelUsedEnglish, docksCaseStats.fuel_used);
		string text = (new_lines ? "\n" : "");
		average_fuel_spent.text = translate(loc_af_key, averageFuelUsedEnglish, text + ((float)docksCaseStats.fuel_used / num).ToString("0.0"));
		evil_let_loose.text = translate(loc_eu_key, evilNotCaught, docksCaseStats.evil_uncaptured.Aggregate(0, (int _a, KeyValuePair<Roles, int> _kvp) => _a += _kvp.Value));
		Maybe<(Roles, int)> max = docksCaseStats.evil_uncaptured.getMax();
		sneakiest_evil.text = (max.is_some ? translate(loc_se_key, sneakiestEvil, text + max.value.Item1.createEmptyRole().name, max.value.Item2.ToString()) : "");
	}

	private string fuelUsedEnglish(string _data)
	{
		return "FUEL USED: " + _data;
	}

	private string averageFuelUsedEnglish(string _data)
	{
		return "AVERAGE FUEL PER CASE: " + _data;
	}

	private string evilNotCaught(string _data)
	{
		return "ESCAPED EVIL ROLES: " + _data;
	}

	private string sneakiestEvil(string _data, string _data_2)
	{
		return "SNEAKIEST EVIL ROLE: " + _data + " (" + _data_2 + ")";
	}
}
