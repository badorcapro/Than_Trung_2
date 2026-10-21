using System.Collections.Generic;
using System.Linq;
using AlternateModes;
using GRGLib.Extensions.Random;
using TMPro;
using UnityEngine;

namespace MainMenu;

public class AlternativeModesMenu : MenuBase
{
	[Header("Alt References")]
	[SerializeField]
	private RegionsSO regions_data;

	[SerializeField]
	private TMP_Dropdown modes_dropdown;

	[SerializeField]
	private TMP_Dropdown regions_dropdown;

	[SerializeField]
	private TMP_Text mode_description;

	[SerializeField]
	private TMP_Text extra_description;

	private List<AlternateModeData> modes_data;

	private List<Regions> available_regions;

	private int selected_mode;

	protected override void onMenuOpening()
	{
		base.onMenuOpening();
		modes_data = AlternateModeData.createAllUnlockedModes();
		modes_dropdown.ClearOptions();
		modes_dropdown.AddOptions(modes_data.Select((AlternateModeData _m) => _m.name).ToList());
		onModeSelection(0);
	}

	public void onModeSelection(int _mode)
	{
		selected_mode = Mathf.Min(_mode, modes_data.Count - 1);
		modes_dropdown.SetValueWithoutNotify(selected_mode);
		AlternateModeData alternateModeData = modes_data[selected_mode];
		regions_dropdown.ClearOptions();
		available_regions = alternateModeData.getAvailableRegions();
		regions_dropdown.AddOptions(available_regions.Select((Regions _r) => regions_data[_r].region_name).ToList());
		regions_dropdown.SetValueWithoutNotify(0);
		onRegionSelection(0);
	}

	public void onRegionSelection(int _region)
	{
		AlternateModeData alternateModeData = modes_data[selected_mode];
		mode_description.text = alternateModeData.description;
		if (!GameHandler.StatsData.alt_modes_stats.ContainsKey(alternateModeData.mode_type))
		{
			extra_description.text = "";
		}
		else
		{
			extra_description.text = alternateModeData.getExtraDescription(available_regions[_region], GameHandler.StatsData.alt_modes_stats[alternateModeData.mode_type]);
		}
	}

	public void onPlay()
	{
		AlternateModeData alternateModeData = modes_data[selected_mode];
		Regions regions = available_regions[regions_dropdown.value];
		alternateModeData.startMode(regions, regions_data, GameHandler.MetaData.getProgressionUnserialized()[regions], RandomExtensions.freshRandom());
	}
}
