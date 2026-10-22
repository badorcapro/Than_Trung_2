using System;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;
using Visual;

namespace CaseSelection;

public class BackAlleyShopManager : MonoBehaviour, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private TMP_Text money_text;

	[SerializeField]
	private List<BackAlleyShopItemSlot> item_slots;

	[SerializeField]
	private ItemVisualHelper item_visualiser;

	[SerializeField]
	private BackAlleysPouchVisualManager pouch_manager;

	[SerializeField]
	private RectTransform drag_parent;

	private int current_moneys;

	private System.Random random;

	private CoroutineRunner credits_runner;

	private AssetKey localisation_asset => LocalisationHelper.misc_asset;

	private string loc_credits_key => "BAShopManager [credits]";

	public void setUpShop(_dep_BackAlleysRegionState _alley_state)
	{
		random = RandomExtensions.freshRandom();
		credits_runner = new CoroutineRunner(this);
		current_moneys = _alley_state.credits;
		money_text.text = localisation_asset.checkTranslationWithData(loc_credits_key, englishCredits, $"{_alley_state.credits}{TextHelper.credits_sprite_link}");
		List<BackAlleysItemType> potential_items = new List<BackAlleysItemType>().addAll();
		item_slots.ForEach(delegate(BackAlleyShopItemSlot _s)
		{
			BackAlleysItemType randomElementFromList = potential_items.getRandomElementFromList(random);
			_s.setItem(randomElementFromList, tryBuyItem, item_visualiser);
			potential_items.remove(randomElementFromList);
		});
		pouch_manager.setUpSelection(drag_parent, _alley_state);
	}

	private bool tryBuyItem(BackAlleysItemType _item, int _price)
	{
		throw new NotImplementedException("AAAA");
	}

	private void updateMoney(int _previous, int _current)
	{
		credits_runner.run(money_text.countdownReplace(localisation_asset.checkTranslation(loc_credits_key, () => englishCredits(LocalisationHelper.text_marker_1)), LocalisationHelper.text_marker_1, _previous, _current, 0.5f, (int _i) => _i + TextHelper.credits_sprite_link, CoroutineExtensions.easeInOutFunc));
	}

	private string englishCredits(string _data)
	{
		return "Credits: " + _data;
	}
}
