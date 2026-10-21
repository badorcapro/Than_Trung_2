using System;
using System.Collections.Generic;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using GameStats;
using Leads;
using LevelEditor;
using Quirks;
using Save;
using UnityEngine;

public class CasinoCase : Case
{
	public static int base_investigation_cost = 2;

	public static int base_arrest_cost = 30;

	public List<CasinoCard> drawn = new List<CasinoCard>();

	private string wants_chips_hidden = "";

	private CasinoCaseStats region_stats = new CasinoCaseStats();

	public CasinoCard left_card { get; private set; }

	public CasinoCard right_card { get; private set; }

	public int chips { get; private set; }

	public bool chips_hidden => wants_chips_hidden != "";

	public float cost_multiplyer { get; private set; } = 1f;

	public int investigation_cost => Mathf.RoundToInt((float)base_investigation_cost * cost_multiplyer);

	public int arrest_cost => Mathf.RoundToInt((float)base_arrest_cost * cost_multiplyer);

	public override CaseType case_type => CaseType.CASINO;

	public CasinoCase(int _chips, float _chips_multi, CaseBuildData _case_data, List<Roles> _available_roles)
		: base(_case_data)
	{
		chips = _chips;
		cost_multiplyer = _chips_multi;
		drawNewCards();
		createBoardAndStart(_available_roles, _case_data.case_quirks);
	}

	public CasinoCase(Lead _lead, int _chips, float _chips_multi, float _diff, CaseRatioBuilderData _ratio_data)
		: base(_lead, _diff, _ratio_data)
	{
		chips = _chips;
		cost_multiplyer = _chips_multi;
		drawNewCards();
		createBoardAndStart(_lead, ratio_builder_data);
	}

	public CasinoCase(CaseSave _case, Maybe<Lead> _current_lead)
		: base(_case, _current_lead)
	{
		try
		{
			string[] array = _case.unique_data.Split(',');
			chips = int.Parse(array[0]);
			cost_multiplyer = float.Parse(array[1]);
			left_card = CasinoCard.parse(array[2]);
			right_card = CasinoCard.parse(array[3]);
			region_stats.chips_spent = int.Parse(array[4]);
			region_stats.chips_gained = int.Parse(array[5]);
			if (array.Length > 6)
			{
				wants_chips_hidden = array[6];
			}
		}
		catch (Exception arg)
		{
			Debug.LogError($"Something went wrong trying to parse save data ('{_case.unique_data}')! \nError: {arg}");
			chips = 50;
			cost_multiplyer = 1f;
			drawNewCards();
		}
		onCaseLoadEnd();
	}

	public CasinoCase(Vector2Int _size, int _chips, float _chips_multi, Maybe<(CasinoCard, CasinoCard)> _cards, List<Roles> _suspect_list, List<RoleData> _board_roles, List<LocationData> _board_locations, Maybe<int> _tutorial, List<CaseQuirks> _case_quirks = null)
		: base(_size, _suspect_list, _board_roles, _board_locations, _tutorial, _case_quirks)
	{
		chips = _chips;
		cost_multiplyer = _chips_multi;
		if (_cards.is_some)
		{
			left_card = _cards.value.Item1;
			right_card = _cards.value.Item2;
		}
		else
		{
			drawNewCards();
		}
		startFromPresetBoard();
	}

	public CasinoCase(Vector2Int _size, int _chips, List<Roles> _suspect_list, List<RoleData> _board_roles, List<LocationData> _board_locations, Maybe<int> _tutorial, List<CaseQuirks> _case_quirks = null)
		: this(_size, _chips, 1f, new Maybe<(CasinoCard, CasinoCard)>(), _suspect_list, _board_roles, _board_locations, _tutorial, _case_quirks)
	{
		chips = _chips;
		cost_multiplyer = 1f;
		drawNewCards();
		startFromPresetBoard();
	}

	public CasinoCase(LevelEditorManager _manager, Vector2Int _board_size)
		: base(_manager, _board_size)
	{
		chips = 50;
		cost_multiplyer = 1f;
		drawNewCards();
	}

	public CasinoCase(CasinoCase _editor_case)
		: base(_editor_case)
	{
		chips = _editor_case.chips;
		cost_multiplyer = 1f;
		left_card = _editor_case.left_card;
		right_card = _editor_case.right_card;
		startFromPresetBoard();
	}

	public CasinoCase(int _chips, float _chips_multi, float _difficulty_01, List<CaseQuirks> _case_quirks, List<Roles> _forced_roles, int _forced_address_size = -1, int _forced_innocents = -1, int _forced_meddlers = -1, int _forced_underlings = -1, int _forced_traitors = -1, bool _remove_extra_suspects = false)
		: base(new Vector2Int(4, 4), _difficulty_01, _forced_address_size, _forced_innocents, _forced_meddlers, _forced_underlings, _forced_traitors, _remove_extra_suspects)
	{
		chips = _chips;
		cost_multiplyer = _chips_multi;
		drawNewCards();
		createBoardAndStart(new List<Roles>(), _forced_roles, _case_quirks);
	}

	public override CaseActionPayload getPayload()
	{
		return new CasinoCaseActionPayload(chips, chips_hidden, cost_multiplyer, left_card, right_card);
	}

	protected override void onInvestigate(int _address, List<RoleData> _ordered_roles_for_event_calls)
	{
		base.onInvestigate(_address, _ordered_roles_for_event_calls);
		int num = investigation_cost;
		for (int i = 0; i < _ordered_roles_for_event_calls.Count; i++)
		{
			if (_ordered_roles_for_event_calls[i] is IAmCasinoRole amCasinoRole)
			{
				num = Mathf.Max(0, amCasinoRole.fetchInvistigationCost(_address, num, board, getPayload() as CasinoCaseActionPayload));
			}
			else if (_ordered_roles_for_event_calls[i].getIsDisguised() && _ordered_roles_for_event_calls[i].getDisguise().value is IAmCasinoRole amCasinoRole2)
			{
				num = Mathf.Max(0, amCasinoRole2.fetchInvistigationCost(_address, num, board, getPayload() as CasinoCaseActionPayload));
			}
		}
		spendChips(num, _ordered_roles_for_event_calls);
	}

	protected override void onArrest(RoleData _arrested_role, List<RoleData> _ordered_roles_for_event_calls)
	{
		int num = ((_arrested_role.getTrueAlignment() == Alignments.GOOD) ? arrest_cost : 0);
		for (int i = 0; i < _ordered_roles_for_event_calls.Count; i++)
		{
			if (_ordered_roles_for_event_calls[i] is IAmCasinoRole amCasinoRole)
			{
				num = Mathf.Max(0, amCasinoRole.fetchArrestCost(_arrested_role.getAddress(), num, board, getPayload() as CasinoCaseActionPayload));
			}
			else if (_ordered_roles_for_event_calls[i].getIsDisguised() && _ordered_roles_for_event_calls[i].getDisguise().value is IAmCasinoRole amCasinoRole2)
			{
				num = Mathf.Max(0, amCasinoRole2.fetchArrestCost(_arrested_role.getAddress(), num, board, getPayload() as CasinoCaseActionPayload));
			}
		}
		spendChips(num, _ordered_roles_for_event_calls);
	}

	public void updateChipsFromRegion(_dep_CasinoRegionState _casino_region)
	{
		chips = _casino_region.chips;
	}

	public void spendChipsSilent(int _to_remove)
	{
		chips = Mathf.Max(chips - _to_remove, 0);
		region_stats.chips_spent += _to_remove;
	}

	public void spendChips(int _to_remove)
	{
		spendChips(_to_remove, board.getOrderdRolesForEventCalls());
	}

	public void spendChips(int _to_remove, List<RoleData> _ordered_roles_for_event_calls, bool _silent = false)
	{
		chips = Mathf.Max(chips - _to_remove, 0);
		region_stats.chips_spent += _to_remove;
		SteamHelper.addToStats(AchiementStats.CHIPS_SPENT, _to_remove);
		if (!_silent)
		{
			onMoneySpent(-_to_remove, _ordered_roles_for_event_calls);
		}
	}

	public void gainChipsSilent(int _to_add)
	{
		chips += _to_add;
		region_stats.chips_gained += _to_add;
	}

	public void gainChips(int _to_add)
	{
		gainChips(_to_add, board.getOrderdRolesForEventCalls());
	}

	public void gainChips(int _to_add, List<RoleData> _ordered_roles_for_event_calls, bool _silent = false)
	{
		chips += _to_add;
		region_stats.chips_gained += _to_add;
		if (!_silent)
		{
			onMoneySpent(_to_add, _ordered_roles_for_event_calls);
		}
	}

	public void hideChips(string _hider_id)
	{
		wants_chips_hidden += _hider_id;
	}

	public void revealChips(string _hider_id)
	{
		wants_chips_hidden = wants_chips_hidden.Replace(_hider_id, "");
	}

	private void onMoneySpent(int _money_diff, List<RoleData> _ordered_roles_for_event_calls)
	{
		callRoleFunction(_ordered_roles_for_event_calls, (IAmCasinoRole _c, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _b) => _c.onMoneySpent(_b, getPayload() as CasinoCaseActionPayload, _money_diff));
		base.active_quirks.ForEach(delegate(CaseQuirkData _q)
		{
			_q.onChipsSpent(this, _money_diff, random);
		});
	}

	private List<CasinoCard> drawCards(bool _left_card = true, bool _right_card = true)
	{
		return drawCards(new Maybe<CasinoCardInfo.Suit>(), _left_card, _right_card);
	}

	private List<CasinoCard> drawCards(CasinoCardInfo.Suit _suit, bool _left_card = true, bool _right_card = true)
	{
		return drawCards(_suit.maybe(), _left_card, _right_card);
	}

	private List<CasinoCard> drawCards(Maybe<CasinoCardInfo.Suit> _draw_suit, bool _left_card = true, bool _right_card = true)
	{
		List<CasinoCard> list = new List<CasinoCard>();
		List<CasinoCard> list2 = new List<CasinoCard>();
		List<CasinoCard> list3 = CaseHelper.getCards(drawn, _draw_suit);
		if (_left_card)
		{
			list3 = checkCards(list3, _draw_suit);
			CasinoCard randomElementFromList = list3.getRandomElementFromList(random);
			if (_right_card)
			{
				list3.Remove(randomElementFromList);
			}
			drawn.Add(randomElementFromList);
			if (left_card != null)
			{
				list.Add(left_card);
			}
			left_card = randomElementFromList;
			list2.Add(randomElementFromList);
		}
		if (_right_card)
		{
			list3 = checkCards(list3, _draw_suit);
			CasinoCard randomElementFromList2 = list3.getRandomElementFromList(random);
			drawn.Add(randomElementFromList2);
			if (right_card != null)
			{
				list.Add(right_card);
			}
			right_card = randomElementFromList2;
			list2.Add(randomElementFromList2);
		}
		onCardDrawn(list, list2);
		return list2;
	}

	private List<CasinoCard> checkCards(List<CasinoCard> _cards, Maybe<CasinoCardInfo.Suit> _draw_suit)
	{
		if (_cards.Count == 0)
		{
			if (_draw_suit.is_some)
			{
				_cards = CaseHelper.getCards(drawn);
			}
			if (_cards.Count == 0)
			{
				drawn.Clear();
				drawn.Add(left_card);
				drawn.Add(right_card);
				_cards = CaseHelper.getCards(drawn, _draw_suit);
			}
		}
		return _cards;
	}

	public List<CasinoCard> drawNewCards(Maybe<CasinoCardInfo.Suit> _suit, bool _left_card = true, bool _right_card = true)
	{
		return drawCards(_suit, _left_card, _right_card);
	}

	public List<CasinoCard> drawNewCards(CasinoCardInfo.Suit _suit, bool _left_card = true, bool _right_card = true)
	{
		return drawCards(_suit, _left_card, _right_card);
	}

	public List<CasinoCard> drawNewCards(bool _left_card = true, bool _right_card = true)
	{
		return drawCards(_left_card, _right_card);
	}

	public Maybe<CasinoCard> replaceCard(CasinoCard _card, CasinoCardInfo.Suit _suit)
	{
		return replaceCard(_card, _suit.maybe());
	}

	public Maybe<CasinoCard> replaceCard(CasinoCard _card)
	{
		return replaceCard(_card, new Maybe<CasinoCardInfo.Suit>());
	}

	public Maybe<CasinoCard> replaceCard(CasinoCard _card, Maybe<CasinoCardInfo.Suit> _suit)
	{
		if (left_card == _card)
		{
			return drawNewCards(_suit, _left_card: true, _right_card: false).firstIfSome((CasinoCard _) => true);
		}
		if (right_card == _card)
		{
			return drawNewCards(_suit, _left_card: false).firstIfSome((CasinoCard _) => true);
		}
		Debug.LogError($"Could not replace card {_card} as it is not part of the 2 drawn cards!");
		return new Maybe<CasinoCard>();
	}

	private void onCardDrawn(List<CasinoCard> _discarded, List<CasinoCard> _new_cards)
	{
		onCardDrawn(_discarded, _new_cards, board.getOrderdRolesForEventCalls());
	}

	private void onCardDrawn(List<CasinoCard> _discarded, List<CasinoCard> _new_cards, List<RoleData> _ordered_roles_for_event_calls)
	{
		callRoleFunction(_ordered_roles_for_event_calls, (IAmCasinoRole _c, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _b) => _c.onCardDrawn(_b, getPayload() as CasinoCaseActionPayload, _discarded, _new_cards));
		base.active_quirks.ForEach(delegate(CaseQuirkData _q)
		{
			_q.onCardChange(board, this, _discarded, _new_cards, random);
		});
		if (SteamHelper.shouldCheckFor(Achiements.POCKET_ROCKETS) && left_card.value == 1 && right_card.value == 1)
		{
			SteamHelper.tryAchieve(Achiements.POCKET_ROCKETS);
		}
	}

	protected override CaseSnapshot generateCaseSnapshot(bool _silent = false)
	{
		if (!_silent)
		{
			return new CasinoCaseSnapshot(getPayload() as CasinoCaseActionPayload, base.case_solved, public_classification_ratio, visual_suspect_list, suspect_list, board);
		}
		return new CasinoCaseSnapshot(getPayload() as CasinoCaseActionPayload, base.case_solved, classification_ratio, suspect_list, suspect_list, board);
	}

	protected override void checkForAchievements(bool _won)
	{
		base.checkForAchievements(_won);
		if (_won && chips > 400)
		{
			SteamHelper.tryAchieve(Achiements.MONEY_MAKER);
		}
	}

	protected override CaseStats setRegionStats()
	{
		return region_stats;
	}

	protected override string getUniqueSaveData()
	{
		return $"{chips},{cost_multiplyer},{CasinoCard.toData(left_card)},{CasinoCard.toData(right_card)},{region_stats.chips_spent},{region_stats.chips_gained},{wants_chips_hidden}";
	}

	public void setChipsFromLevelEditor(LevelEditorManager _manager, int _chips)
	{
		if (!(_manager == null))
		{
			chips = _chips;
		}
	}

	public void setChipsFromCBCLead(CaseToCaseLead _cbc_lead, int _chips)
	{
		if (_cbc_lead != null)
		{
			chips = _chips;
		}
	}
}
