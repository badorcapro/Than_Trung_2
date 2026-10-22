using GRGLib.Maybe;
using GameStats;
using TMPro;
using UnityEngine;

public class CasinoStatsSection : StatsRegionSection
{
	[Header("Text References")]
	[SerializeField]
	private TMP_Text chips_spent;

	[SerializeField]
	private TMP_Text average_chips_spent;

	[SerializeField]
	private TMP_Text chips_gained;

	private string loc_cs_key => "StatsCasino [CS]";

	private string loc_cg_key => "StatsCasino [CG]";

	private string loc_as_key => "StatsCasino [AS]";

	protected override void setUpSection(RunStats _stats, CaseStats _region_stats, Maybe<CaseType> _region)
	{
		if (!(_region_stats is CasinoCaseStats casinoCaseStats))
		{
			Debug.LogError("Given region stats is not CasinoCaseStats! This is not allowed!!");
			return;
		}
		float num = Mathf.Max(_stats.getCasesAttempted(CaseType.CASINO), 1);
		chips_spent.text = translate(loc_cs_key, chipsSpentEnglish, casinoCaseStats.chips_spent + TextHelper.chips_sprite_link);
		chips_gained.text = translate(loc_cg_key, chipsGainedEnglish, casinoCaseStats.chips_gained + TextHelper.chips_sprite_link);
		average_chips_spent.text = translate(loc_as_key, averageChipsSpentEnglish, "\n" + ((float)casinoCaseStats.chips_spent / num).ToString("0.0") + TextHelper.chips_sprite_link);
	}

	private string chipsSpentEnglish(string _data)
	{
		return "CHIPS SPENT: " + _data;
	}

	private string chipsGainedEnglish(string _data)
	{
		return "CHIPS GAINED: " + _data;
	}

	private string averageChipsSpentEnglish(string _data)
	{
		return "AVERAGE CHIPS SPENT PER CASE: " + _data;
	}
}
