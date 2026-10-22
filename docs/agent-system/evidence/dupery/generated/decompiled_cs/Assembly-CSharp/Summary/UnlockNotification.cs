using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.UI;
using GRGLocalisation;
using Localisation;
using Nodes.Logic;
using Save;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace Summary;

public class UnlockNotification : MenuBase, IAmLocalised
{
	[SerializeField]
	private RegionsSO regions_data;

	[SerializeField]
	private RoleVisualDataSO roles_data;

	[Header("References")]
	[SerializeField]
	private TMP_Text notification_text;

	[SerializeField]
	private TMP_Text extra_text;

	[SerializeField]
	private AnimatedLayoutGroup unlocked_roles_layout;

	[SerializeField]
	private Button on_close_select;

	[Header("Prefabs")]
	[SerializeField]
	private PrimeSuspectVisual unlocked_roles_prefab;

	private AssetKey localisation_asset => LocalisationHelper.misc_asset;

	private string loc_roles_unlocked_key => "Sum [rls_unlock]";

	private string loc_region_unlocked_key => "Sum [rg_unlock]";

	private string loc_region_the_key => "Sum [rg_the]";

	public void openWithNotification(Regions _region, int _tier)
	{
		if (_region == Regions.OFFICE && _tier == GameMetaData.casino_unlock_tier)
		{
			openWithUnlockedNotification(Regions.CASINO);
		}
		else if (_region == Regions.CASINO && _tier == GameMetaData.docks_unlock_tier)
		{
			openWithUnlockedNotification(Regions.DOCKS);
		}
		else if (GameHandler.MetaData.getTierOfRegion(Regions.DOCKS) > 1 && (GameHandler.MetaData.getSummedTiers() == GameMetaData.syndicate_unlock_tier || (_region == Regions.DOCKS && _tier == 2 && GameHandler.MetaData.getSummedTiers() >= GameMetaData.syndicate_unlock_tier)))
		{
			openWithUnlockedNotification(Regions.SYNDICATE);
		}
		else
		{
			openWithUnlockedRoles(_region, _tier);
		}
	}

	private void openWithUnlockedRoles(Regions _region, int _tier)
	{
		RegionDataSO regionDataSO = regions_data[_region];
		List<Roles> previous_available = regionDataSO.getAvailableRoles(_tier - 1);
		List<Roles> list = regionDataSO.getSetOfTier(_tier).Aggregate(new HashSet<Roles>(), (HashSet<Roles> _a, RoleSetsGraph _s) => _a.addRange(from _r in _s.getSetRoles()
			where !previous_available.Contains(_r)
			select _r)).ToList();
		for (int i = 0; i < list.Count && i < 5; i++)
		{
			Object.Instantiate(unlocked_roles_prefab, unlocked_roles_layout.transform).setUp(list[i], roles_data);
		}
		openMenu();
	}

	private string englishRolesUnlocked()
	{
		return "ROLES UNLOCKED!";
	}

	private void openWithUnlockedNotification(Regions _unlocked)
	{
		notification_text.text = localisation_asset.checkTranslation(loc_region_unlocked_key, englishRegionUnlocked, _check_keywords: false);
		extra_text.text = localisation_asset.checkTranslationWithData(loc_region_the_key, englishTheRegion, regions_data[_unlocked].region_name);
		openMenu();
	}

	private string englishRegionUnlocked()
	{
		return "REGION UNLOCKED!";
	}

	private string englishTheRegion(string _d1)
	{
		return "THE " + _d1.ToUpper() + "!";
	}

	protected override void onMenuClosed()
	{
		base.onMenuClosed();
		if (GameHandler.instance.using_gamepad)
		{
			on_close_select.Select();
		}
	}
}
