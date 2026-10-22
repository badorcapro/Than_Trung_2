using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Generic;
using Leads;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace MainMenu;

public class StampWeightTimelineElement : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private RectTransform stamp_odds_parent;

	[SerializeField]
	private TMP_InputField range_input;

	[SerializeField]
	private Button add_stamp_button;

	[Header("Prefabs")]
	[SerializeField]
	private StampOddVisualiser odd_visualiser_prefab;

	private List<LeadEventType> vetoed = new List<LeadEventType>();

	private Func<StampWeightTimelineElement, bool> try_remove_self;

	private CoroutineRunner add_shake_runner;

	public RectTransform rect_trans => base.transform as RectTransform;

	public float height => rect_trans.sizeDelta.y;

	public List<StampOddVisualiser> stamp_odds { get; private set; } = new List<StampOddVisualiser>();

	public MinMaxInt range { get; private set; }

	public bool is_special { get; private set; }

	public void setUp(List<LeadEventType> _vetoed)
	{
		vetoed = _vetoed;
		for (int i = 0; i < 3; i++)
		{
			createNewStampOdd(new List<LeadEventType>());
		}
		resetStampDropdowns();
	}

	public void setUpSpecial(string _special_text, List<LeadEventType> _vetoed)
	{
		is_special = true;
		range_input.SetTextWithoutNotify(_special_text);
		range_input.interactable = false;
		vetoed = _vetoed;
		for (int i = 0; i < 3; i++)
		{
			createNewStampOdd(new List<LeadEventType>());
		}
		resetStampDropdowns();
	}

	private StampOddVisualiser createNewStampOdd(List<LeadEventType> _events)
	{
		if (_events.Count == 0)
		{
			_events = getAllAvailableEvents();
		}
		StampOddVisualiser stampOddVisualiser = UnityEngine.Object.Instantiate(odd_visualiser_prefab, stamp_odds_parent);
		stampOddVisualiser.setUp(getAllAvailableEvents(), onStampChange, tryStampRemoval);
		stampOddVisualiser.rect_trans.anchoredPosition = new Vector2(stampOddVisualiser.rect_trans.anchoredPosition.x, -stamp_odds.Count * 160 - 36);
		stamp_odds.Add(stampOddVisualiser);
		rect_trans.sizeDelta = new Vector2(rect_trans.sizeDelta.x, stamp_odds.Count * 160);
		return stampOddVisualiser;
	}

	private List<LeadEventType> getAllAvailableEvents()
	{
		return CollectionsExtension.addAll(new List<LeadEventType>(), (LeadEventType _et) => !vetoed.Contains(_et) && !stamp_odds.Any((StampOddVisualiser _s) => _s.event_type == _et));
	}

	public void onRangeChange(string _input)
	{
		if (is_special)
		{
			return;
		}
		try
		{
			string[] array = _input.Split('-');
			if (array.Length == 1)
			{
				int num = int.Parse(array[0]);
				range = new MinMaxInt(num, num);
			}
			else
			{
				range = new MinMaxInt(int.Parse(array[0]), int.Parse(array[1]));
			}
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to parse range data {_input}.\nError: {arg}");
		}
	}

	public void onAddStamp()
	{
		List<LeadEventType> allAvailableEvents = getAllAvailableEvents();
		if (allAvailableEvents.Count == 0)
		{
			add_shake_runner.run(add_stamp_button.transform.shake(0.25f, 2.5f));
		}
		else
		{
			createNewStampOdd(allAvailableEvents);
		}
	}

	private void onStampChange(StampOddVisualiser _stamp)
	{
		resetStampDropdowns();
	}

	private bool tryStampRemoval(StampOddVisualiser _stamp)
	{
		if (!is_special)
		{
			if (stamp_odds.Count > 1)
			{
				onStampRemoval(_stamp);
				return true;
			}
			if (try_remove_self(this))
			{
				UnityEngine.Object.Destroy(base.gameObject);
				return true;
			}
			return false;
		}
		if (stamp_odds.Count > 3)
		{
			onStampRemoval(_stamp);
			return true;
		}
		return false;
	}

	private void onStampRemoval(StampOddVisualiser _stamp)
	{
		stamp_odds.Remove(_stamp);
		for (int i = 0; i < stamp_odds.Count; i++)
		{
			stamp_odds[i].rect_trans.anchoredPosition = new Vector2(stamp_odds[i].rect_trans.anchoredPosition.x, -i * 160 - 36);
		}
		rect_trans.sizeDelta = new Vector2(rect_trans.sizeDelta.x, stamp_odds.Count * 160);
		resetStampDropdowns();
	}

	private void resetStampDropdowns()
	{
		List<LeadEventType> av_ev = getAllAvailableEvents();
		stamp_odds.ForEach(delegate(StampOddVisualiser _s)
		{
			_s.resetDropdownOptions(av_ev);
		});
	}
}
