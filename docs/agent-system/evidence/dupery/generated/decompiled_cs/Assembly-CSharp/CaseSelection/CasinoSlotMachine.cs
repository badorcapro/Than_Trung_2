using System;
using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using GRGLib.UI;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;

namespace CaseSelection;

public class CasinoSlotMachine : MonoBehaviour, IAmLocalised
{
	[Header("Inner References")]
	[SerializeField]
	private List<CasinoSlotMachineSpinner> spinners;

	[SerializeField]
	private TMP_Text betting_chips;

	[SerializeField]
	private TMP_Text symbol_count_text;

	[SerializeField]
	private TMP_Text winning_text;

	[SerializeField]
	private List<Sprite> symbol_sprites;

	[SerializeField]
	private AdvancedButton increase_button;

	[SerializeField]
	private AdvancedButton decrease_button;

	private int chips_bet = 10;

	private int max_bet_possible;

	private int symbol_count = 3;

	private bool can_bet;

	private System.Random random = RandomExtensions.freshRandom();

	private Action<int> chips_used;

	private AssetKey localisation_asset => LocalisationHelper.misc_asset;

	private string loc_symbol_key => "SlotMachine [symbols]";

	private string loc_win_big_key => "SlotMachine [win_b]";

	private string loc_win_key => "SlotMachine [win]";

	private string loc_lose_key => "SlotMachine [lose]";

	public void setUp(_dep_CasinoRegionState _state, Action<int> _chips_used, bool _available)
	{
		max_bet_possible = _state.chips - 10 - Mathf.RoundToInt(5f);
		chips_bet = Mathf.Max(Mathf.Min(10, max_bet_possible), 0);
		can_bet = _available && _state.chips >= max_bet_possible;
		chips_used = _chips_used;
		updateBetTextAndSymbolCount();
	}

	public void increaseBet()
	{
		if (can_bet)
		{
			if (chips_bet <= 5)
			{
				chips_bet = 10;
			}
			else if (chips_bet <= 10)
			{
				chips_bet = 25;
			}
			else if (chips_bet < 100)
			{
				chips_bet += 25;
			}
			else
			{
				chips_bet += 50;
			}
			chips_bet = Mathf.Min(chips_bet, max_bet_possible);
			updateBetTextAndSymbolCount();
		}
	}

	public void decreaseBet()
	{
		if (can_bet)
		{
			if (chips_bet > 50)
			{
				chips_bet -= ((chips_bet % 50 == 0) ? 50 : (chips_bet % 50));
			}
			else if (chips_bet > 25)
			{
				chips_bet = 25;
			}
			else if (chips_bet > 10)
			{
				chips_bet = 10;
			}
			else if (chips_bet > 5)
			{
				chips_bet = 5;
			}
			updateBetTextAndSymbolCount();
		}
	}

	private void updateBetTextAndSymbolCount()
	{
		betting_chips.text = $"{chips_bet}{TextHelper.chips_sprite_link}";
		symbol_count = ((chips_bet <= 10) ? 3 : ((chips_bet <= 25) ? 4 : ((chips_bet <= 50) ? 5 : ((chips_bet <= 100) ? 6 : ((chips_bet <= 200) ? 7 : ((chips_bet <= 350) ? 8 : ((chips_bet <= 500) ? 9 : 10)))))));
		symbol_count_text.text = localisation_asset.checkTranslation(loc_symbol_key, englishSymbols) + $"\n{symbol_count}";
	}

	private string englishSymbols()
	{
		return "Symbols:";
	}

	public void spin()
	{
		if (!can_bet)
		{
			return;
		}
		can_bet = false;
		winning_text.text = "";
		List<Sprite> range = symbol_sprites.GetRange(0, symbol_count);
		HashSet<int> unique_results = new HashSet<int>();
		for (int i = 0; i < spinners.Count; i++)
		{
			if (i >= 2 && unique_results.Count == i && random.Next(0, 13) == 9)
			{
				unique_results.Add(spinners[i].spin(range, random, 3f - 0.5f * (float)i, unique_results.getRandomElement(random).maybe()));
			}
			else
			{
				unique_results.Add(spinners[i].spin(range, random, 3f - 0.5f * (float)i));
			}
		}
		int chips_won = chips_bet;
		3f.wait(delegate
		{
			if (unique_results.Count == 1)
			{
				winning_text.text = localisation_asset.checkTranslation(loc_win_big_key, englishWinBig);
				chips_won *= 3;
			}
			else if (unique_results.Count == 2)
			{
				winning_text.text = localisation_asset.checkTranslation(loc_win_key, englishWin);
				chips_won = chips_won;
			}
			else
			{
				winning_text.text = localisation_asset.checkTranslation(loc_lose_key, englishLost);
				chips_won *= -1;
			}
			chips_used(chips_won);
		}).start(this);
	}

	private string englishWinBig()
	{
		return "YOU WON BIG!";
	}

	private string englishWin()
	{
		return "YOU WON!";
	}

	private string englishLost()
	{
		return "YOU LOST!";
	}

	public void setUpSelectable(AdvancedButton _right_most_case)
	{
		increase_button.addLeftSelectable(_right_most_case);
		decrease_button.addLeftSelectable(_right_most_case);
		_right_most_case.addRightSelectables(decrease_button, increase_button);
	}
}
