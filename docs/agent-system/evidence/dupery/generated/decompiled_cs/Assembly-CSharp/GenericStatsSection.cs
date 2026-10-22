using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.String;
using GRGLib.Maybe;
using GameStats;
using TMPro;
using UnityEngine;

public class GenericStatsSection : StatsRegionSection
{
	[SerializeField]
	private RegionsSO region_data;

	[Header("Text References")]
	[SerializeField]
	private TMP_Text cases_solved;

	[SerializeField]
	private TMP_Text cases_failed;

	[SerializeField]
	private TMP_Text roles_investigated;

	[SerializeField]
	private TMP_Text roles_arrested_evil;

	[SerializeField]
	private TMP_Text roles_arrested_good;

	[SerializeField]
	private TMP_Text roles_died_evil;

	[SerializeField]
	private TMP_Text roles_died_good;

	[SerializeField]
	private TMP_Text ability_used;

	[SerializeField]
	private TMP_Text favourite_ability;

	[SerializeField]
	private bool new_line_favourite = true;

	[Header("Misc Settings")]
	[SerializeField]
	private bool is_run_history;

	private string loc_cso_key => "StatsGeneric [CSO]";

	private string loc_cfo_key => "StatsGeneric [CFO]";

	private string loc_cs_key => "StatsGeneric [CS]";

	private string loc_cf_key => "StatsGeneric [CF]";

	private string loc_in_key => "StatsGeneric [IN]";

	private string loc_are_key => "StatsGeneric [ARE]";

	private string loc_arg_key => "StatsGeneric [ARG]";

	private string loc_die_key => "StatsGeneric [DIE]";

	private string loc_dig_key => "StatsGeneric [DIG]";

	private string loc_au_key => "StatsGeneric [AU]";

	private string loc_af_key => "StatsGeneric [AF]";

	protected override void setUpSection(RunStats _stats, CaseStats _region_stats, Maybe<CaseType> _region)
	{
		int num;
		int num2;
		int num3;
		if (!_region.is_some)
		{
			num = _stats.cases_solved_all;
			num2 = _stats.cases_flawless_all;
			num3 = _stats.cases_attempted_all;
		}
		else
		{
			num = _stats.getCasesSolved(_region.value);
			num2 = _stats.getCasesFlawless(_region.value);
			num3 = _stats.getCasesAttempted(_region.value);
		}
		if (is_run_history)
		{
			cases_solved.text = translate(loc_cso_key, caseSolvedEnglish, num);
			cases_failed.text = translate(loc_cfo_key, caseFlawlessEnglish, num2);
		}
		else
		{
			cases_solved.text = translate(loc_cs_key, caseSolvedWithFlawlessEnglish, num, num2);
			cases_failed.text = translate(loc_cf_key, caseFailEnglish, num3 - num);
		}
		roles_investigated.text = translate(loc_in_key, investigatedEnglish, _region_stats.investigated.Values.Aggregate(0, (int _a, int _r) => _a + _r));
		roles_arrested_evil.text = translate(loc_are_key, arrestedEvilEnglish, _region_stats.arrested_align.getOrDefault(Alignments.EVIL, 0));
		roles_arrested_good.text = translate(loc_arg_key, arrestedGoodEnglish, _region_stats.arrested_align.getOrDefault(Alignments.GOOD, 0));
		roles_died_evil.text = translate(loc_die_key, diedEvilEnglish, _region_stats.died_align.getOrDefault(Alignments.EVIL, 0));
		roles_died_good.text = translate(loc_dig_key, diedGoodEnglish, _region_stats.died_align.getOrDefault(Alignments.GOOD, 0));
		ability_used.text = translate(loc_au_key, abUsedEnglish, _region_stats.ability_used.Values.Aggregate(0, (int _a, int _r) => _a + _r));
		Maybe<(Roles, int)> max = _region_stats.ability_used.getMax();
		string text = (new_line_favourite ? "\n" : "");
		favourite_ability.text = (max.is_some ? translate(loc_af_key, abFavEnglish, text + max.value.Item1.createEmptyRole().name) : "");
	}

	private string caseSolvedWithFlawlessEnglish(string _data_1, string _data_2)
	{
		return "CASES SOLVED: " + _data_1 + (" (" + _data_2 + " flawless)").italics().sizeRelative(90);
	}

	private string caseSolvedEnglish(string _data)
	{
		return "CASES SOLVED: " + _data;
	}

	private string caseFlawlessEnglish(string _data)
	{
		return "CASES FLAWLESS: " + _data;
	}

	private string caseFailEnglish(string _data)
	{
		return "CASES FAILED: " + _data;
	}

	private string investigatedEnglish(string _data)
	{
		return "ROLES INVESTIGATED: " + _data;
	}

	private string arrestedEvilEnglish(string _data_1)
	{
		return "EVIL ARRESTED: " + _data_1;
	}

	private string arrestedGoodEnglish(string _data_1)
	{
		return "GOOD ARRESTED: " + _data_1;
	}

	private string diedEvilEnglish(string _data_1)
	{
		return "EVIL DEATHS: " + _data_1;
	}

	private string diedGoodEnglish(string _data_1)
	{
		return "GOOD DEATHS: " + _data_1;
	}

	private string abUsedEnglish(string _data)
	{
		return "ABILITIES USED: " + _data;
	}

	private string abFavEnglish(string _data)
	{
		return "FAVOURITE ABILITY: " + _data;
	}
}
