using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Numbers;
using GRGLib.Maybe;
using GRGLib.UI;
using GameStats;
using Save;
using TMPro;
using UnityEngine;

public class RunHistoryManager : MenuBase
{
	[Header("Run History")]
	[SerializeField]
	private RectTransform run_parent;

	[SerializeField]
	private BackgroundMenuAnimationManager animation_manager;

	[SerializeField]
	private CanvasGroup stats_text_group;

	[SerializeField]
	private RunHistoryGraph graph;

	[Header("Run Selection References")]
	[SerializeField]
	private TMP_Text run_title;

	[SerializeField]
	private AdvancedButton left_button;

	[SerializeField]
	private AdvancedButton right_button;

	[SerializeField]
	private AdvancedButton back_button;

	[Header("Prefabs")]
	[SerializeField]
	private RunStatsViewer run_prefab;

	private Dictionary<StatsSaveData, RunStatsViewer> viewers = new Dictionary<StatsSaveData, RunStatsViewer>();

	private Maybe<RunStatsViewer> opened_viewer = new Maybe<RunStatsViewer>();

	private int viewing_run;

	private CoroutineRunner stats_text_runner;

	protected override void Awake()
	{
		base.Awake();
		stats_text_runner = new CoroutineRunner(this);
		graph.setUp();
	}

	protected override void onMenuOpening()
	{
		base.onMenuOpening();
		animation_manager.animateBackground("run_history");
		try
		{
			openRun(GameHandler.StatsData.run_stats.Last());
			viewing_run = GameHandler.StatsData.run_stats.Count - 1;
			run_title.text = $"{viewing_run + 1}/{viewing_run + 1}";
		}
		catch (Exception)
		{
			Debug.LogError("Opening run history failed!");
			run_title.text = "0/0";
		}
		if (GameHandler.StatsData.run_stats.Count <= 1)
		{
			left_button.interactable = false;
			right_button.interactable = false;
		}
		stats_text_runner.run(stats_text_group.fade(0f, 0.15f, CoroutineExtensions.easeInOutFunc));
		if (!graph.graph_created)
		{
			graph.createGraphFromData();
		}
	}

	protected override void onMenuOpen()
	{
		base.onMenuOpen();
		if (GameHandler.instance.using_gamepad)
		{
			back_button.Select();
		}
	}

	protected override void onMenuClosing()
	{
		animation_manager.openingMenuAnimation();
		base.onMenuClosing();
		viewers.destroyAll();
		viewers = new Dictionary<StatsSaveData, RunStatsViewer>();
		opened_viewer = new Maybe<RunStatsViewer>();
		stats_text_runner.run(0.15f.wait(delegate
		{
			stats_text_runner.run(stats_text_group.fade(1f, 0.35f, CoroutineExtensions.easeInOutFunc));
		}));
	}

	public void openRun(StatsSaveData _stats)
	{
		if (!viewers.ContainsKey(_stats))
		{
			RunStatsViewer runStatsViewer = UnityEngine.Object.Instantiate(run_prefab, run_parent);
			runStatsViewer.setUpRunStats(new RunStats(_stats));
			viewers[_stats] = runStatsViewer;
		}
		if (!opened_viewer.is_some || !(opened_viewer.value == viewers[_stats]))
		{
			if (opened_viewer.is_some)
			{
				opened_viewer.value.closeMenu();
			}
			viewers[_stats].openMenu();
			opened_viewer = viewers[_stats].maybe();
			viewers[_stats].setUpControllerNavigation(left_button, right_button, back_button);
		}
	}

	public void switchRun(bool _increase)
	{
		viewing_run += (_increase ? 1 : (-1));
		viewing_run = IntegerExtension.modNoNegative(viewing_run, GameHandler.StatsData.run_stats.Count);
		run_title.text = $"{viewing_run + 1}/{GameHandler.StatsData.run_stats.Count}";
		openRun(GameHandler.StatsData.run_stats[viewing_run]);
		graph.selectElement(viewing_run);
	}
}
