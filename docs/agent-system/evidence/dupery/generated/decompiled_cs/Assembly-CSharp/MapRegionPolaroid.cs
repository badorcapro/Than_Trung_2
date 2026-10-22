using System;
using GRGLib.Coroutines;
using GRGLib.UI;
using Save;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class MapRegionPolaroid : MapPolaroid
{
	[SerializeField]
	private RegionsSO regions_data;

	[SerializeField]
	private TMP_Text tier;

	[SerializeField]
	private GameObject tier_polaroid;

	[SerializeField]
	private GameObject stats_section;

	[SerializeField]
	private TMP_Text win_text;

	[SerializeField]
	private TMP_Text played_text;

	[SerializeField]
	private TMP_Text streak_text;

	[SerializeField]
	private ProgressBar tier_progress_bar;

	[SerializeField]
	private Image region_image;

	[Header("Optional")]
	[SerializeField]
	private GameObject tier_button;

	[SerializeField]
	private GameObject tier_blocker;

	[SerializeField]
	private CanvasGroup tier_slider_group;

	[SerializeField]
	private Slider tier_slider;

	[SerializeField]
	private TMP_Text tier_slider_number;

	[Header("Settings")]
	[SerializeField]
	private Regions region;

	private Action<Regions> start;

	private Action<Regions> check;

	private Action<Regions> quick_case;

	private Action<Regions> tutorial;

	private Func<Regions, int, (int, bool)> set_tier;

	private CoroutineRunner tier_slider_fade;

	public Regions polaroid_region => region;

	public void setUpPolaroid(RegionProgressionSaveData _progression, Action<Regions> _start_region, Action<Regions> _check_region, Action<Regions> _quick_case, Action<Regions> _tutorial, Func<Regions, int, (int, bool)> _set_tier)
	{
		tier_progress_bar.gameObject.SetActive(value: true);
		if (stats_section != null)
		{
			stats_section.SetActive(value: true);
		}
		title.text = regions_data[region].region_name.ToUpper();
		tier_progress_bar.setProgress(_progression.xp, 100f);
		tier.text = $"T{_progression.using_tier}" + ((_progression.using_tier != _progression.tier) ? "*" : "");
		tier_polaroid.SetActive(value: true);
		win_text.text = _progression.runs_succeeded.ToString();
		played_text.text = _progression.runs_attempted.ToString();
		streak_text.text = _progression.current_streak.ToString();
		start = _start_region;
		check = _check_region;
		quick_case = _quick_case;
		tutorial = _tutorial;
		set_tier = _set_tier;
		base.discovered = true;
		group.interactable = true;
		region_image.color = new Color(1f, 1f, 1f, 1f);
		if (_progression.tier == 1 && tier_button != null)
		{
			tier_button.gameObject.SetActive(value: false);
		}
		else if (tier_slider_group != null)
		{
			tier_slider_fade = new CoroutineRunner(this);
			tier_slider_number.text = _progression.using_tier.ToString();
			tier_slider.maxValue = _progression.tier;
			tier_slider.SetValueWithoutNotify(_progression.using_tier);
		}
	}

	public void setUpCustomPolaroid(Action<Regions> _start_region, Action<Regions> _check_region)
	{
		start = _start_region;
		check = _check_region;
		base.discovered = true;
		group.interactable = true;
	}

	public void setUpPolaroidUndiscovered()
	{
		title.text = "???";
		tier.text = "";
		tier_polaroid.SetActive(value: false);
		tier_progress_bar.gameObject.SetActive(value: false);
		if (stats_section != null)
		{
			stats_section.SetActive(value: false);
		}
		base.discovered = false;
		group.interactable = false;
		region_image.color = new Color(0.5f, 0.5f, 0.5f, 0.1f);
	}

	public void onStartRegion()
	{
		if (base.discovered)
		{
			start(region);
		}
	}

	public void onCheckRegion()
	{
		if (base.discovered)
		{
			check(region);
		}
	}

	public void onQuickCase()
	{
		if (base.discovered)
		{
			quick_case(region);
		}
	}

	public void onReplayTutorial()
	{
		if (base.discovered)
		{
			tutorial(region);
		}
	}

	public void onTierHover(bool _in)
	{
		if (base.discovered)
		{
			tier_blocker.SetActive(_in);
			if (_in)
			{
				tier_slider_group.interactable = true;
				tier_slider_group.blocksRaycasts = true;
				tier_slider_fade.run(tier_slider_group.fade(1f, 0.35f));
			}
			else
			{
				tier_slider_group.interactable = false;
				tier_slider_group.blocksRaycasts = false;
				tier_slider_fade.run(tier_slider_group.fade(0f, 0.15f));
			}
		}
	}

	public void onTierSelect(float _value)
	{
		onTierSelect(Mathf.RoundToInt(_value));
	}

	public void onTierSelect(int _value)
	{
		if (base.discovered)
		{
			(int, bool) tuple = set_tier(region, _value);
			tier.text = $"T{tuple.Item1}" + (tuple.Item2 ? "" : "*");
			tier_slider_number.text = tuple.Item1.ToString();
		}
	}

	protected override void onA()
	{
		onStartRegion();
	}

	protected override void onX()
	{
		onQuickCase();
	}

	protected override void onY()
	{
		onReplayTutorial();
	}

	protected override void onSelect()
	{
		onCheckRegion();
	}
}
