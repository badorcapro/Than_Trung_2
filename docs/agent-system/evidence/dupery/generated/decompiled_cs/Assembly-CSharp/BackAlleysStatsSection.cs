using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using GameStats;
using TMPro;
using UnityEngine;

public class BackAlleysStatsSection : StatsRegionSection
{
	[Header("Text References")]
	[SerializeField]
	private TMP_Text items_used;

	[SerializeField]
	private TMP_Text average_items_used;

	[SerializeField]
	private TMP_Text favourite_item;

	private string loc_iu_key => "StatsBackAlleys [IU]";

	private string loc_au_key => "StatsBackAlleys [AU]";

	private string loc_fi_key => "StatsBackAlleys [FI]";

	protected override void setUpSection(RunStats _stats, CaseStats _region_stats, Maybe<CaseType> _region)
	{
		if (!(_region_stats is BackAlleyCaseStats backAlleyCaseStats))
		{
			Debug.LogError("Given region stats is not BackAlleyCaseStats! This is not allowed!!");
			return;
		}
		float num = Mathf.Max(_stats.getCasesAttempted(CaseType.BACK_ALLEYS), 1);
		int num2 = backAlleyCaseStats.items_used.Aggregate(0, (int _a, KeyValuePair<BackAlleysItemType, int> _kvp) => _a += _kvp.Value);
		items_used.text = translate(loc_iu_key, itemUsedEnglish, num2);
		average_items_used.text = translate(loc_au_key, avItemUsedEnglish, "\n" + ((float)num2 / num).ToString("0.0"));
		Maybe<(BackAlleysItemType, int)> max = backAlleyCaseStats.items_used.getMax();
		favourite_item.text = (max.is_some ? translate(loc_fi_key, favouriteItemEnglish, "\n" + max.value.Item1.createItem(RandomExtensions.freshRandom()).name, max.value.Item2.ToString()) : "");
	}

	private string itemUsedEnglish(string _data)
	{
		return "Item used: " + _data;
	}

	private string avItemUsedEnglish(string _data)
	{
		return "AVERAGE ITEMS USED PER CASE: " + _data;
	}

	private string favouriteItemEnglish(string _data, string _data_2)
	{
		return "FAVOURITE ITEM: " + _data + " (" + _data_2 + ")";
	}
}
