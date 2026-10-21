using GRGLib.Maybe;
using GameStats;
using TMPro;
using UnityEngine;

public class OfficeStatsSection : StatsRegionSection
{
	[Header("Text References")]
	[SerializeField]
	private TMP_Text time_passed;

	[SerializeField]
	private TMP_Text average_time_per_case;

	private string loc_tp_key => "StatsOffice [TP]";

	private string loc_av_key => "StatsOffice [AV]";

	protected override void setUpSection(RunStats _stats, CaseStats _region_stats, Maybe<CaseType> _region)
	{
		if (!(_region_stats is OfficeCaseStats officeCaseStats))
		{
			Debug.LogError("Given region stats is not OfficeCaseStats! This is not allowed!!");
			return;
		}
		float num = Mathf.Max(_stats.getCasesAttempted(CaseType.CLOCK), 1);
		time_passed.text = translate(loc_tp_key, timePassedEnglish, officeCaseStats.time_passed);
		average_time_per_case.text = translate(loc_av_key, avTimePassedEnglish, "\n" + ((float)officeCaseStats.time_passed / num).ToString("0.00"));
	}

	private string timePassedEnglish(string _data)
	{
		return "TIME PASSED: " + _data + " hours.";
	}

	private string avTimePassedEnglish(string _data)
	{
		return "AVERAGE TIME PER CASE: " + _data + " hours.";
	}
}
