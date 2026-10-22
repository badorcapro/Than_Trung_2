using System;
using System.Collections;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace Visual;

public class SpecialAbilityVisualManager : MonoBehaviour
{
	private WorldVisualManager world_visual_handler;

	private SuspectListVisualManager suspect_list_visual_handler;

	private BoardVisualManager board_manager;

	private List<AbilityData> selected_special_data = new List<AbilityData>();

	private SpecialAbilityType ability_type;

	public void setUpReferences(WorldVisualManager _region_visual, BoardVisualManager _board, SuspectListVisualManager _suspect_visuals)
	{
		world_visual_handler = _region_visual;
		board_manager = _board;
		suspect_list_visual_handler = _suspect_visuals;
	}

	public bool setUpForSelection(SpecialAbilityType _ability_type, IHaveSpecialAbility _ab_user)
	{
		ability_type = _ability_type;
		switch (_ability_type)
		{
		case SpecialAbilityType.NONE:
			return false;
		case SpecialAbilityType.SUSPECT:
			suspect_list_visual_handler.setUpForSelection(delegate(SuspectAbilityData _data)
			{
				if (_ab_user is IHaveSpecialSpecificAbility haveSpecialSpecificAbility)
				{
					if (haveSpecialSpecificAbility.validateSelectedSpecialData(_data))
					{
						selected_special_data.Add(_data);
					}
				}
				else
				{
					selected_special_data.Add(_data);
				}
			});
			return true;
		case SpecialAbilityType.EMPTY_SLOT:
			board_manager.overrideEmptySlotCallback(delegate
			{
			}, delegate
			{
			}, delegate(EmptySlot _e, Vector2Int _p)
			{
				EmptySlotAbilityData emptySlotAbilityData = new EmptySlotAbilityData(_p);
				if (_ab_user is IHaveSpecialSpecificAbility haveSpecialSpecificAbility3)
				{
					if (haveSpecialSpecificAbility3.validateSelectedSpecialData(emptySlotAbilityData))
					{
						selected_special_data.Add(emptySlotAbilityData);
					}
				}
				else
				{
					selected_special_data.Add(emptySlotAbilityData);
				}
			});
			return true;
		case SpecialAbilityType.LOCATION:
			board_manager.overrideLocationCallback(delegate(LocationAbilityData _data)
			{
				if (_ab_user is IHaveSpecialSpecificAbility haveSpecialSpecificAbility2)
				{
					if (haveSpecialSpecificAbility2.validateSelectedSpecialData(_data))
					{
						selected_special_data.Add(_data);
					}
				}
				else
				{
					selected_special_data.Add(_data);
				}
			});
			return true;
		case SpecialAbilityType.CARD_ABILITY:
			if (!(world_visual_handler is CasinoRegionWorldManager casinoRegionWorldManager))
			{
				Debug.LogError("Can only use card ability in casino region!");
				return false;
			}
			casinoRegionWorldManager.setUpCardsForSelection(delegate(CasinoCardAbilityData _data)
			{
				selected_special_data.Add(_data);
			});
			return true;
		default:
			Debug.LogError($"Failed to set up selection! Nothing set up for special ability type {_ability_type}");
			return false;
		}
	}

	private void resetSelection()
	{
		switch (ability_type)
		{
		case SpecialAbilityType.SUSPECT:
			suspect_list_visual_handler.resetNormalSelection();
			break;
		case SpecialAbilityType.EMPTY_SLOT:
			board_manager.resetEmptySlotCallbackOverride();
			break;
		case SpecialAbilityType.LOCATION:
			board_manager.resetLocationCallback();
			break;
		case SpecialAbilityType.CARD_ABILITY:
			if (world_visual_handler is CasinoRegionWorldManager casinoRegionWorldManager)
			{
				casinoRegionWorldManager.resetCardSelections();
			}
			break;
		}
	}

	public IEnumerator waitForSpecialAbilitySelection(IHaveSpecialAbility _special_ability, Action<List<AbilityData>> _callback)
	{
		selected_special_data = new List<AbilityData>();
		while (selected_special_data.Count < _special_ability.numberTargets)
		{
			yield return null;
		}
		resetSelection();
		_callback(selected_special_data);
	}

	public void cancelAbility(Maybe<IHaveAbility> _ability_user)
	{
		if (_ability_user.is_some && _ability_user.value is IHaveSpecialAbility)
		{
			resetSelection();
		}
	}
}
