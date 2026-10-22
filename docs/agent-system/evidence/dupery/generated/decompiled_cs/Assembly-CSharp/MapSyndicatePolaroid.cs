using System;
using Save;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class MapSyndicatePolaroid : MapPolaroid
{
	[SerializeField]
	private RegionsSO regions_data;

	[Header("Syndicate References")]
	[SerializeField]
	private TMP_Text tiers_remaining;

	[SerializeField]
	private Image syndicate_image;

	[SerializeField]
	private GameObject stats_section;

	[SerializeField]
	private TMP_Text win_text;

	[SerializeField]
	private TMP_Text played_text;

	[SerializeField]
	private TMP_Text streak_text;

	private Action<Regions> start;

	public void setUp(Action<Regions> _start_region)
	{
		start = _start_region;
		if (GameHandler.MetaData.regionUnlocked(Regions.SYNDICATE))
		{
			base.discovered = true;
			group.interactable = true;
			tiers_remaining.gameObject.SetActive(value: false);
			RegionProgressionSaveData regionProgressionSaveData = GameHandler.MetaData.getProgressionUnserialized()[Regions.SYNDICATE];
			stats_section.SetActive(value: true);
			win_text.text = regionProgressionSaveData.runs_succeeded.ToString();
			played_text.text = regionProgressionSaveData.runs_attempted.ToString();
			streak_text.text = regionProgressionSaveData.current_streak.ToString();
			title.text = regions_data[Regions.SYNDICATE].region_name.ToUpper();
			syndicate_image.color = Color.white;
		}
		else
		{
			title.text = "???";
			stats_section.SetActive(value: false);
			syndicate_image.color = new Color(0.5f, 0.5f, 0.5f, 0.1f);
			if (GameHandler.MetaData.regionUnlocked(Regions.DOCKS) && GameHandler.MetaData.getTierOfRegion(Regions.DOCKS) >= 2)
			{
				tiers_remaining.gameObject.SetActive(value: true);
				tiers_remaining.text = (GameMetaData.syndicate_unlock_tier - GameHandler.MetaData.getSummedTiers()).ToString();
			}
		}
	}

	public void onStartRegion()
	{
		if (base.discovered)
		{
			start(Regions.SYNDICATE);
		}
	}
}
