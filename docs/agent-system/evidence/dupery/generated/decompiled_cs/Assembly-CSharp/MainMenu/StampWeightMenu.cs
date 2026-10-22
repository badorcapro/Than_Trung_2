using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLocalisation;
using Leads;
using Localisation;
using UnityEngine;

namespace MainMenu;

public class StampWeightMenu : MenuBase, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private RectTransform timeline_parent;

	[SerializeField]
	private StampWeightTimelineElement last_element;

	[SerializeField]
	private StampWeightTimelineElement default_element;

	[SerializeField]
	private RectTransform add_element_trans;

	[Header("Prefab")]
	[SerializeField]
	private StampWeightTimelineElement element_prefab;

	public List<StampWeightTimelineElement> timeline { get; private set; } = new List<StampWeightTimelineElement>();

	private AssetKey localisation_asset => LocalisationHelper.misc_asset;

	public Dictionary<int, List<(LeadEventBuilderData, int)>> getProgressionData()
	{
		Dictionary<int, List<(LeadEventBuilderData, int)>> dictionary = new Dictionary<int, List<(LeadEventBuilderData, int)>>();
		dictionary[-1] = last_element.stamp_odds.Select((StampOddVisualiser _s) => (event_data: _s.event_data, event_odd: _s.event_odd)).ToList();
		dictionary[0] = default_element.stamp_odds.Select((StampOddVisualiser _s) => (event_data: _s.event_data, event_odd: _s.event_odd)).ToList();
		foreach (StampWeightTimelineElement item in timeline)
		{
			List<(LeadEventBuilderData, int)> value = item.stamp_odds.Select((StampOddVisualiser _s) => (event_data: _s.event_data, event_odd: _s.event_odd)).ToList();
			for (int i = item.range.min; i <= item.range.max; i++)
			{
				dictionary[i] = value;
			}
		}
		return dictionary;
	}

	protected override void onMenuOpening()
	{
		base.onMenuOpening();
		setUpAnew(new List<LeadEventType>());
	}

	public void setUpAnew(List<LeadEventType> _vetoed)
	{
		timeline.destroyAllSafe();
		last_element.setUpSpecial(localisation_asset.checkTranslation(englishLast(), englishLast, _check_keywords: false), _vetoed.copy().add(LeadEventType.PLUS_ONE_CASE));
		default_element.setUpSpecial(localisation_asset.checkTranslation(englishDefault(), englishDefault, _check_keywords: false), _vetoed.copy().add(LeadEventType.PLUS_ONE_CASE, LeadEventType.INCREASE_BOARD_SIZE));
		positionTimeline();
	}

	private void positionTimeline()
	{
		float num = 0f;
		for (int i = 0; i < timeline.Count; i++)
		{
			timeline[i].rect_trans.anchoredPosition = new Vector2(timeline[i].rect_trans.anchoredPosition.x, 0f - num);
			num += timeline[i].height + 15f;
		}
		add_element_trans.anchoredPosition = new Vector2(add_element_trans.anchoredPosition.x, 0f - num);
		num += add_element_trans.sizeDelta.y + 15f;
		last_element.rect_trans.anchoredPosition = new Vector2(last_element.rect_trans.anchoredPosition.x, 0f - num);
		default_element.rect_trans.anchoredPosition = new Vector2(default_element.rect_trans.anchoredPosition.x, 0f - num - last_element.rect_trans.sizeDelta.y - 15f);
	}

	private string englishLast()
	{
		return "Last";
	}

	private string englishDefault()
	{
		return "Default";
	}
}
