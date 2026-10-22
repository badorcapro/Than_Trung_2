using System.Collections.Generic;
using Audio;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using GameStats;
using Leads;
using Save;
using UnityEngine;
using UnityEngine.UI;

namespace Summary;

public class SummarySceneManager : MonoBehaviour
{
	[SerializeField]
	private RegionsSO regions_data;

	[Header("References")]
	[SerializeField]
	private UnlockNotification unlock_notification;

	[SerializeField]
	private ParalaxAnimationManager paralax_manager;

	[SerializeField]
	private RunStatsViewer run_stats;

	[SerializeField]
	private MenuBase menu;

	[SerializeField]
	private JiggleButton back_button;

	[SerializeField]
	private JiggleButton view_lead_button;

	[SerializeField]
	private MenuBase lead_menu;

	[SerializeField]
	private RectTransform lead_parent;

	[SerializeField]
	private List<Image> smoke_images;

	[SerializeField]
	private Material smoke_mat;

	[Header("Prefabs")]
	[SerializeField]
	private LeadFacade lead_prefab;

	public Maybe<LeadFacade> current_facade { get; private set; } = new Maybe<LeadFacade>();

	private void Start()
	{
		float num = paralax_manager.animateObjects("opening");
		RunStats runStats = (GameHandler.StatsData.previous_run.is_some ? GameHandler.StatsData.previous_run.value : new RunStats(GameHandler.StatsData.run_stats[GameHandler.StatsData.run_stats.Count - 1]));
		run_stats.setUpRunStats(runStats);
		run_stats.setUpControllerNavigation(back_button);
		(num / 2f).wait(delegate
		{
			run_stats.openMenu();
			0.5f.wait(menu.openMenu).start(this);
		}).start(this);
		num.wait(delegate
		{
			smoke_images.ForEach(delegate(Image _s)
			{
				_s.material = smoke_mat;
				_s.SetMaterialDirty();
			});
		}).start(this);
		if (GameHandler.instance.previous_run_tier_up && runStats.run_region != Regions.SYNDICATE)
		{
			unlock_notification.openWithNotification(runStats.run_region, SaveHandler.instance.meta_data.getTierOfRegion(runStats.run_region));
		}
		else if (GameHandler.instance.using_gamepad)
		{
			back_button.Select();
		}
		AudioHandler.Music.playMusic(Music.A_MT);
		if (GameHandler.instance.last_lead_info.is_some)
		{
			run_stats.setButtonCheck(view_lead_button.gameObject);
		}
	}

	public void onLeave()
	{
		GameHandler.instance.moveToScene("MainMenuScene", _save: true);
	}

	public void onViewLead()
	{
		if (!GameHandler.instance.last_lead_info.is_some)
		{
			return;
		}
		List<Lead> value = GameHandler.instance.last_lead_info.value;
		if (value.Count != 0)
		{
			Lead lead = value[run_stats.current_lead];
			if (current_facade.is_some)
			{
				Object.Destroy(current_facade.value.gameObject);
				current_facade = new Maybe<LeadFacade>();
			}
			current_facade = Object.Instantiate(lead_prefab, lead_parent).maybe();
			current_facade.value.setCurrentLead(lead, regions_data[lead.case_type.fromType()].region_name);
			run_stats.openNewMenu(lead_menu);
		}
	}

	public void onLeadClose()
	{
		lead_menu.closeMenu();
	}
}
