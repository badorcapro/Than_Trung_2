using System;
using System.Collections;
using System.Collections.Generic;
using Codex;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using GRGLib.Serializable;
using GRGLocalisation;
using GameStats;
using Localisation;
using TMPro;
using UnityEngine;

public class StatsMenu : MenuBase, IAmLocalised
{
	[SerializeField]
	private RegionsSO regions_data;

	[Header("Animation Settings")]
	[SerializeField]
	private BackgroundMenuAnimationManager animation_manager;

	[SerializeField]
	private CanvasGroup text_group;

	[Header("Optional References")]
	[SerializeField]
	private JiggleButton codex_button;

	[SerializeField]
	private CodexMenu codex;

	[SerializeField]
	private JiggleButton run_history;

	[Header("Sections")]
	[SerializeField]
	private SerializableDictionary<CaseType, StatsRegionSection> stats_sections;

	[SerializeField]
	private GlobalStatsSection global_section;

	[SerializeField]
	private GenericStatsSection generic_section;

	[SerializeField]
	private ProgressionStatsSection progression_section;

	[Header("Text References")]
	[SerializeField]
	private TMP_Text region_name;

	private CoroutineRunner text_fade_runner;

	private Dictionary<RectTransform, CoroutineRunner> section_movers = new Dictionary<RectTransform, CoroutineRunner>();

	private List<CaseType> region_list = new List<CaseType>();

	private int current_region;

	private RunStats current_run_stats;

	private string loc_global_key => "Stats Global";

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	protected override void Awake()
	{
		base.Awake();
		text_fade_runner = new CoroutineRunner(this);
		if (codex == null && codex_button != null)
		{
			codex_button.gameObject.SetActive(value: false);
		}
	}

	protected override void onMenuOpening()
	{
		base.onMenuOpening();
		try
		{
			current_run_stats = ((GameHandler.instance.current_scene == "MainMenuScene") ? GameHandler.StatsData.Combined : GameHandler.State.run_stats);
			if (run_history != null)
			{
				run_history.gameObject.SetActive(GameHandler.instance.current_scene == "MainMenuScene" && GameHandler.StatsData.run_stats.Count > 0);
			}
			region_list = new List<CaseType> { (CaseType)(-1) };
			foreach (LeadStats lead_stat in current_run_stats.lead_stats)
			{
				region_list.addIfNotDuplicate(lead_stat.case_type);
			}
			setUp(current_run_stats, new Maybe<CaseType>());
		}
		catch (Exception arg)
		{
			Debug.LogError($"FAILED TO OPEN STATS MENU!\nError: {arg}");
		}
	}

	public void setUp(RunStats _stats, Maybe<CaseType> _region)
	{
		if (!_region.is_some)
		{
			region_name.text = localisation_asset.checkTranslation(loc_global_key, globalEnglish);
			global_section.setUp(_stats, _stats.combined_stats, _region);
			generic_section.setUp(_stats, _stats.combined_stats, _region);
			progression_section.setUp(_stats, _stats.combined_stats, _region);
			setUpSections(global_section.rect_trans, generic_section.rect_trans);
			closeRegionSections(new Maybe<CaseType>());
		}
		else
		{
			region_name.text = regions_data[_region.value].region_name;
			CaseStats caseStats = _stats.getCaseStats(_region.value);
			global_section.setUp(_stats, caseStats, _region);
			stats_sections[_region.value].setUp(_stats, caseStats, _region);
			generic_section.setUp(_stats, caseStats, _region);
			progression_section.setUp(_stats, caseStats, _region);
			setUpSections(global_section.rect_trans, generic_section.rect_trans, stats_sections[_region.value].rect_trans);
			closeRegionSections(_region.value.maybe());
		}
	}

	private void closeRegionSections(Maybe<CaseType> _exeption)
	{
		foreach (KeyValuePair<CaseType, StatsRegionSection> stats_section in stats_sections)
		{
			if (!_exeption.is_some || stats_section.Key != _exeption.value)
			{
				stats_section.Value.closeMenu();
			}
		}
	}

	private void setUpSections(params RectTransform[] _ordered_top_sections)
	{
		float num = 0f;
		for (int i = 0; i < _ordered_top_sections.Length; i++)
		{
			section_movers.getOrCreate(_ordered_top_sections[i], () => new CoroutineRunner(this)).run(_ordered_top_sections[i].anchoredMove(new Vector3(_ordered_top_sections[i].anchoredPosition.x, num), 0.4f, CoroutineExtensions.easeInOutFunc));
			num -= 30f + _ordered_top_sections[i].sizeDelta.y;
		}
	}

	public void moveSection(bool _increase)
	{
		current_region = (region_list.Count + current_region + (_increase ? 1 : (-1))) % region_list.Count;
		setUp(current_run_stats, (region_list[current_region] == (CaseType)(-1)) ? new Maybe<CaseType>() : region_list[current_region].maybe());
	}

	protected override IEnumerator openingMenuAnimation()
	{
		menu_group.alpha = 1f;
		animation_manager.openingMenuAnimation();
		float half_length = animation_manager.getAnimationDuration(_in: true);
		yield return half_length.wait();
		text_fade_runner.run(text_group.fade(1f, half_length, CoroutineExtensions.easeInOutFunc));
		yield return half_length.wait();
	}

	protected override IEnumerator closingMenuAnimation()
	{
		float animationDuration = animation_manager.getAnimationDuration(_in: false);
		text_fade_runner.run(text_group.fade(0f, animationDuration / 3f, CoroutineExtensions.easeInOutFunc));
		animation_manager.closingMenuAnimation();
		yield return animationDuration.wait();
		menu_group.alpha = 0f;
	}

	public void openCodexMenu()
	{
		if (!(codex == null))
		{
			openNewMenu(codex);
			codex.openRoleMenuPage(_open_codex: false);
		}
	}

	private string globalEnglish()
	{
		return "Global";
	}
}
