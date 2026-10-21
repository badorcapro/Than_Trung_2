using System.Collections;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using GRGLib.Serializable;
using GRGLib.UI;
using GRGLocalisation;
using GameStats;
using Localisation;
using TMPro;
using UnityEngine;

public class RunStatsViewer : MenuBase, IAmLocalised
{
	[Header("Stats References")]
	[SerializeField]
	private RegionsSO regions_data;

	[SerializeField]
	private AnimatedLayoutGroup region_group;

	[SerializeField]
	private TMP_Text title_text;

	[SerializeField]
	private GenericStatsSection base_section;

	[SerializeField]
	private GlobalRecapStatsSection recap_section;

	[SerializeField]
	private SerializableDictionary<CaseType, StatsRegionSection> stats_sections;

	[SerializeField]
	private PieChart pie_chart;

	[Header("Animation Settings")]
	[SerializeField]
	private Vector2 target_position;

	[SerializeField]
	private Vector2 starting_position;

	[SerializeField]
	private float starting_scale;

	[Header("Prefabs")]
	[SerializeField]
	private RunStatsViewerRegionButton region_button_prefab;

	private MultiCoroutineRunner additional_menuing_runner;

	private RunStats run;

	private List<RunStatsViewerRegionButton> region_buttons = new List<RunStatsViewerRegionButton>();

	private Maybe<GameObject> lead_button = new Maybe<GameObject>();

	public int current_lead { get; private set; }

	private string loc_won_key => "RunViewer [won]";

	private string loc_lost_key => "RunViewer [lost]";

	private string loc_lead_nb_ley => "RunViewever [run_nb]";

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	protected override void Awake()
	{
		base.Awake();
		additional_menuing_runner = new MultiCoroutineRunner(this);
	}

	public void setUpRunStats(RunStats _stats)
	{
		run = _stats;
		Regions region = ((_stats.run_region != Regions.CUSTOM) ? _stats.run_region : ((_stats.lead_stats.Count > 0) ? _stats.lead_stats[0].case_type.fromType() : Regions.OFFICE));
		title_text.text = (run.run_won ? localisation_asset.checkTranslation(loc_won_key, wonEnglish) : ((regions_data[region].fired_end_text.Trim() != "") ? regions_data[region].fired_end_text : localisation_asset.checkTranslation(loc_lost_key, lostEnglish)));
		for (int i = 0; i < run.lead_stats.Count; i++)
		{
			RunStatsViewerRegionButton runStatsViewerRegionButton = Object.Instantiate(region_button_prefab, region_group.transform);
			runStatsViewerRegionButton.setUpCallback(i, toggleLead);
			runStatsViewerRegionButton.text.text = localisation_asset.checkTranslationWithData(loc_lead_nb_ley, englishRunNb, i + 1);
			region_buttons.Add(runStatsViewerRegionButton);
		}
		region_group.checkUpdate();
		for (int j = 0; j < region_buttons.Count; j++)
		{
			if (j > 0)
			{
				region_buttons[j].button.addLeftSelectable(region_buttons[j - 1].button);
			}
			if (j + 1 < region_buttons.Count)
			{
				region_buttons[j].button.addRightSelectable(region_buttons[j + 1].button);
			}
		}
		base.gameObject.SetActive(value: true);
		CoroutineLibrary.waitEndOfFrame().addCallback(delegate
		{
			if (run.lead_stats.Count == 1)
			{
				current_lead = 0;
				setUpText(current_lead.maybe());
				setUpPieCharts(current_lead.maybe());
			}
			else
			{
				setUpText(new Maybe<int>());
				setUpPieCharts(new Maybe<int>());
			}
		}).start(this);
	}

	public void setButtonCheck(GameObject _button)
	{
		lead_button = _button.maybe();
		lead_button.value.SetActive(run.lead_stats.Count == 1);
	}

	public void setUpControllerNavigation(AdvancedButton _p1)
	{
		for (int i = 0; i < region_buttons.Count; i++)
		{
			region_buttons[i].button.clearDownSelectable();
			region_buttons[i].button.addDownSelectables(_p1);
		}
		_p1.clearUpSelectable();
		if (region_buttons.Count > 1)
		{
			_p1.addUpSelectable(region_buttons[0].button);
		}
	}

	public void setUpControllerNavigation(AdvancedButton _p1, AdvancedButton _p2, AdvancedButton _p3)
	{
		for (int i = 0; i < region_buttons.Count; i++)
		{
			region_buttons[i].button.clearDownSelectable();
			region_buttons[i].button.addDownSelectables(_p1, _p2, _p3);
		}
		_p1.clearUpSelectable();
		_p2.clearUpSelectable();
		_p3.clearUpSelectable();
		_p3.addUpSelectables(_p1, _p2);
		if (region_buttons.Count > 1)
		{
			_p1.addUpSelectable(region_buttons[0].button);
			_p2.addUpSelectable(region_buttons[0].button);
			_p3.addUpSelectable(region_buttons[0].button);
		}
	}

	protected override IEnumerator openingMenuAnimation()
	{
		additional_menuing_runner.run(base.transform.moveTransformAxis(target_position, new Vector2(1.05f, 1.45f), CoroutineExtensions.getCustomEaseOutBounceFunc(3, 0.2f), CoroutineExtensions.easeOutFunc), base.transform.scaleTransform(1f, 1.05f, CoroutineExtensions.getCustomEaseOutBounceFunc(3, 0.4f)));
		return menu_group.fadeRealTime(1f, 0.65f, CoroutineExtensions.easeInOutFunc);
	}

	protected override IEnumerator closingMenuAnimation()
	{
		additional_menuing_runner.run(base.transform.moveTransform(target_position + new Vector2(-80f, -50f), 0.65f, CoroutineExtensions.easeInOutFunc), base.transform.scaleTransform(0.8f, 0.65f, CoroutineExtensions.easeInOutFunc));
		return menu_group.fadeRealTime(0f, 0.45f, CoroutineExtensions.easeInOutFunc);
	}

	protected override void onMenuOpening()
	{
		base.onMenuOpening();
	}

	protected override void onMenuClosed()
	{
		base.onMenuClosed();
		base.transform.localPosition = starting_position;
		base.transform.localScale = new Vector3(starting_scale, starting_scale, 1f);
	}

	private bool toggleLead(int _lead)
	{
		if (current_lead == _lead)
		{
			current_lead = -1;
			setUpText(new Maybe<int>());
			setUpPieCharts(new Maybe<int>());
			if (lead_button.is_some)
			{
				lead_button.value.SetActive(value: false);
			}
			return false;
		}
		current_lead = _lead;
		setUpText(_lead.maybe());
		setUpPieCharts(_lead.maybe());
		if (lead_button.is_some)
		{
			lead_button.value.SetActive(value: true);
		}
		return true;
	}

	public void setUpText(Maybe<int> _lead)
	{
		Maybe<CaseType> case_type = new Maybe<CaseType>();
		CaseStats case_stats;
		if (_lead.is_some && _lead.value < run.lead_stats.Count)
		{
			current_lead = _lead.value;
			case_stats = run.lead_stats[current_lead].combined_case_stats;
			case_type = run.lead_stats[current_lead].case_type.maybe();
		}
		else
		{
			case_stats = run.combined_stats;
		}
		base_section.closeAndReopen(delegate
		{
			base_section.setUp(run, case_stats, case_type);
			if (case_type.is_some)
			{
				recap_section.forceCloseImmidiate();
			}
			else
			{
				recap_section.setUp(run, case_stats, case_type);
				recap_section.forceOpenImmidiate();
			}
			foreach (KeyValuePair<CaseType, StatsRegionSection> stats_section in stats_sections)
			{
				if (case_type.is_some && stats_section.Key == case_type.value)
				{
					stats_section.Value.setUp(run, case_stats, case_type);
					stats_section.Value.forceOpenImmidiate(_check_awake: false);
				}
				else
				{
					stats_section.Value.forceCloseImmidiate();
				}
			}
			foreach (RunStatsViewerRegionButton region_button in region_buttons)
			{
				region_button.toggle(_lead.is_some && region_button.lead_number == _lead.value);
			}
		});
	}

	public void setUpPieCharts(Maybe<int> _lead)
	{
		if (_lead.is_some)
		{
			pie_chart.setPossibleCharts(run.lead_stats[_lead.value].combined_case_stats);
		}
		else
		{
			pie_chart.setPossibleCharts(run.combined_stats);
		}
	}

	private string wonEnglish()
	{
		return "The Syndicate Defeated!";
	}

	private string lostEnglish()
	{
		return "Detective Fired!";
	}

	private string englishRunNb(string _d1)
	{
		return "Lead " + _d1;
	}
}
