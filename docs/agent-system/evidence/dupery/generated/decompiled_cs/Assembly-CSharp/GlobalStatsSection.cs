using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.String;
using GRGLib.Maybe;
using GameStats;
using Save;
using TMPro;
using UnityEngine;

public class GlobalStatsSection : StatsRegionSection
{
	[Header("Text References")]
	[SerializeField]
	private TMP_Text runs_played;

	[SerializeField]
	private TMP_Text runs_won;

	[SerializeField]
	private TMP_Text play_time;

	private string loc_rp_key => "StatsGlobal [RP]";

	private string loc_rw_key => "StatsGlobal [RW]";

	private string loc_pt_key => "StatsGlobal [PT]";

	protected override void setUpSection(RunStats _stats, CaseStats _region_stats, Maybe<CaseType> _region)
	{
		if (!_region.is_some)
		{
			runs_played.text = translate(loc_rp_key, runsPlayedEnglish, GameHandler.StatsData.run_stats.Count);
			runs_won.text = translate(loc_rw_key, runsWonEnglish, GameHandler.StatsData.run_stats.Where((StatsSaveData _r) => _r.run_won).toListSafe().Count);
			play_time.text = translate(loc_pt_key, playTimeEnglish, _stats.play_time.toTime());
			return;
		}
		List<LeadStatsSaveData> list = GameHandler.StatsData.run_stats.Aggregate(new List<LeadStatsSaveData>(), delegate(List<LeadStatsSaveData> _a, StatsSaveData _rs)
		{
			Maybe<LeadStatsSaveData> maybe = _rs.lead_stats.firstIfSome((LeadStatsSaveData _l) => _l.case_type == _region.value);
			if (!maybe.is_some)
			{
				return _a;
			}
			_a.Add(maybe.value);
			return _a;
		});
		runs_played.text = translate(loc_rp_key, runsPlayedEnglish, list.Count);
		runs_won.text = translate(loc_rw_key, runsWonEnglish, list.Count((LeadStatsSaveData _ls) => _ls.lead_completed));
		play_time.text = translate(loc_pt_key, playTimeEnglish, list.Aggregate(0f, (float _a, LeadStatsSaveData _ls) => _a + _ls.play_time).toTime());
	}

	private string runsPlayedEnglish(string _data)
	{
		return "Runs Played: " + _data;
	}

	private string runsWonEnglish(string _data)
	{
		return "Runs Won: " + _data;
	}

	private string playTimeEnglish(string _data)
	{
		return "Play Time: " + _data;
	}
}
