using GRGLib.Extensions.String;
using GRGLib.Maybe;
using GameStats;
using TMPro;
using UnityEngine;

public class GlobalRecapStatsSection : StatsRegionSection
{
	[Header("Text References")]
	[SerializeField]
	private TMP_Text play_time;

	[SerializeField]
	private TMP_Text average_play_time;

	private string loc_pt_key => "StatsGlobal [PT]";

	private string loc_pta_key => "StatsGlobal [PTA]";

	protected override void setUpSection(RunStats _stats, CaseStats _region_stats, Maybe<CaseType> _region)
	{
		play_time.text = translate(loc_pt_key, playTimeEnglish, _stats.play_time.toTime());
		float time_in_seconds = ((_stats.cases_attempted_all == 0) ? 0f : (_stats.play_time / (float)_stats.cases_attempted_all));
		average_play_time.text = translate(loc_pta_key, playTimeAverageEnglish, "\n" + time_in_seconds.toTime());
	}

	private string playTimeEnglish(string _data)
	{
		return "PLAY TIME: " + _data;
	}

	private string playTimeAverageEnglish(string _data)
	{
		return "AVERAGE PLAY TIME PER CASE: " + _data;
	}
}
