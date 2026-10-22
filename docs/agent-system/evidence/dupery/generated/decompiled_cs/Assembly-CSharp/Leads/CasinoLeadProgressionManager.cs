using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

namespace Leads;

public class CasinoLeadProgressionManager : LeadProgressionManager
{
	public override Regions region => Regions.CASINO;

	public CasinoLeadProgressionManager(RegionsSO _region_data, int _tier)
		: base(_region_data[Regions.CASINO], _tier)
	{
	}

	public override List<Lead> createRegionLeads(System.Random _rng, bool _force_new, int _wanted = 3)
	{
		List<Lead> list = new List<Lead>();
		List<RoleSetInfoStruct> list2 = new List<RoleSetInfoStruct>();
		for (int i = 0; i < _wanted; i++)
		{
			Lead lead = createLead(_rng, list2, (i != 0 || !_force_new) ? new Maybe<RoleSetInfoStruct>() : tryGetRandomNewSet(_rng));
			list2.Add(lead.prime_suspect_set);
			list.Add(lead);
		}
		return list;
	}

	private Lead createLead(System.Random _rng, List<RoleSetInfoStruct> _other_primes, Maybe<RoleSetInfoStruct> _forced_prime)
	{
		RoleSetInfoStruct prime_suspects;
		if (_forced_prime.is_some)
		{
			prime_suspects = _forced_prime.value;
		}
		else
		{
			prime_suspects = new RoleSetInfoStruct(region_data.getTierSets(tier).getRandomElementFromList(_rng));
			while (_other_primes.Any((RoleSetInfoStruct _p) => _p.set_roles.Count == prime_suspects.set_roles.Count && _p.set_roles.All((Roles _sr) => prime_suspects.set_roles.Contains(_sr))))
			{
				prime_suspects = new RoleSetInfoStruct(region_data.getTierSets(tier).getRandomElementFromList(_rng));
			}
		}
		List<Roles> available = region_data.createAvailableRoles(tier, _rng, prime_suspects.set_roles);
		MinMaxFloat leadDifficulty = LeadProgressionManager.getLeadDifficulty(LeadProgressionManager.getLeadDifficulty(tier), _rng);
		int num = LeadProgressionManager.getLeadLengthPossibleRange(tier).get(_rng);
		Vector2Int grid_size = LeadProgressionManager.getStartingBoardSize(tier);
		int num2 = CasinoLead.starting_chips;
		if (is_syndicate_lead)
		{
			num = Mathf.Max(num - 3, 5);
			grid_size = new Vector2Int(4, 4);
			leadDifficulty.min = Mathf.Max(leadDifficulty.min, 0.4f);
			leadDifficulty.max = Mathf.Max(leadDifficulty.max, 0.8f);
			num2 = CasinoLead.starting_syndicate_chips;
		}
		if (GameHandler.MetaData.difficulty == GameMetaData.Difficulty.EASY)
		{
			num2 += 50;
		}
		if (GameHandler.MetaData.difficulty == GameMetaData.Difficulty.CHALLENGE)
		{
			num2 -= (is_syndicate_lead ? 25 : 50);
		}
		return new CasinoLead(available, grid_size, leadDifficulty, num, prime_suspects, num2);
	}

	public override Case createQuickCase(System.Random _rng)
	{
		return createLead(_rng, new List<RoleSetInfoStruct>(), new Maybe<RoleSetInfoStruct>()).createRandomCase(_rng);
	}

	protected override List<LeadEvent> tryGetWantedChoices(Lead _lead, System.Random _rng)
	{
		if (!(_lead is CasinoLead casinoLead))
		{
			Debug.LogError($"Cannot get wanted choices for casino lead when lead is not a casino lead! {_lead.case_type}!");
			return getBackupEventChoices(_lead, _rng);
		}
		if (_lead.current_case == LeadProgressionManager.getSizeIncreaseProgress(tier) && _lead.current_board_size.x == 3)
		{
			return getBoardSizeIncrease(_lead, _rng);
		}
		if (_lead.current_case > 5 && _lead.current_case == _lead.max_case - 2 && casinoLead.chips < getMaxChipsFromDiff(tier) - tier * 3 - 100)
		{
			return getEventCheckForChips(getRandomPositiveChoice(_rng, 56 + tier * 4), casinoLead, _rng);
		}
		if (_lead.current_case == _lead.max_case - 1)
		{
			if (is_syndicate_lead)
			{
				return getBoardSizeIncrease(_lead, _rng);
			}
			return getTraitorChoice(_lead, _rng);
		}
		bool flag = GameHandler.MetaData.difficulty == GameMetaData.Difficulty.CHALLENGE;
		switch (_lead.current_case)
		{
		case 1:
			if (flag && tier > 4)
			{
				return getEventChoicesFromWeightedList(getRandomNegativeChoice(_rng, tier * 5), _lead, _rng);
			}
			return getEventChoicesFromWeightedList(getRandomPositiveChoice(_rng, 20 + tier * 5), _lead, _rng);
		case 2:
			return getEventCheckForChips(getRandomPositiveChoice(_rng, 45 + tier * 5), casinoLead, _rng);
		case 3:
			return getEventChoicesFromWeightedList(getRandomNegativeChoice(_rng, 50), _lead, _rng);
		case 4:
		{
			List<LeadEvent> list = new List<LeadEvent>();
			list.Add(new CasinoChipsGainEvent(_lead, new MinMaxInt(61 - tier, 77 - tier * 2), _rng, _show_exact: true));
			list.Add(new AddSingleRandomRoleEvent(_lead, new List<LeadEvent>(), _rng, true, new List<ClueTypes> { ClueTypes.ROLE_IN_PLAY }, default(RoleClassifications)));
			list.Add(new AddSingleRandomQuirkEvent(_rng, _lead, new List<LeadEvent>(), region_data.getAvailableQuirks(tier), (CaseQuirks _q) => _q.isGoodQuirk(), _show_real: true));
			list.Add(new AddSingleRandomRoleWithAbilityEvent(_rng, _lead, new List<LeadEvent>(), _show_exact: false));
			list.Add(new AddSingleRandomRoleEvent(_lead, new List<LeadEvent>(), _rng, true, ClueTypes.ROLE_NOT_IN_PLAY.makeListFromItem(), RoleClassifications.UNDERLING));
			list.Add(new RemoveRandomClueEvent(_rng, _lead, new List<LeadEvent>(), _show_exact: true));
			return list.Where((LeadEvent _e) => _e.isValidForCurrentLead(_lead) && (!base.custom_settings.is_some || !base.custom_settings.value.vetoed.Contains(_e.event_type))).ToList().removeAllAfterIndex(3);
		}
		case 5:
			return getEventChoicesFromWeightedList(negativeRoleOrQuirkChoiceComplexWithExtraCase(), _lead, _rng);
		case 6:
			if (tier < 3 && !flag)
			{
				return getEventChoicesFromWeightedList(getRandomPositiveChoice(_rng, 20 + tier * 7), _lead, _rng);
			}
			return getEventChoicesFromWeightedList(getRandomMidChoice(_rng, 50), _lead, _rng);
		case 7:
			return getEventChoicesFromWeightedList((tier < 3 && !flag) ? getRandomMidChoice(_rng, 30) : negativeQuirkChoice(), _lead, _rng);
		case 8:
			return getEventChoicesFromWeightedList(neutralChaoticChoice(), _lead, _rng);
		default:
			if (_lead.current_case % 3 == 0)
			{
				return getEventChoicesFromWeightedList(getRandomNegativeChoice(_rng, 50), _lead, _rng);
			}
			if (_lead.current_case % 3 == 1)
			{
				return getEventChoicesFromWeightedList(neutralChaoticChoice(), _lead, _rng);
			}
			return getEventChoicesFromWeightedList(getRandomChoice(_rng, 50, 35), _lead, _rng);
		}
	}

	protected List<(LeadEventBuilderData, int)> getRandomChoice(System.Random _rng, int _negative_odds, int _mid_odds)
	{
		int num = _rng.Next(0, 100);
		if (num < _mid_odds)
		{
			return getRandomMidChoice(_rng, 50);
		}
		if (num < _negative_odds + _mid_odds)
		{
			return getRandomNegativeChoice(_rng, 50);
		}
		return getRandomPositiveChoice(_rng, 50);
	}

	protected List<(LeadEventBuilderData, int)> getRandomPositiveChoice(System.Random _rng, int _odds)
	{
		if (_rng.Next(0, 100) >= _odds)
		{
			return positiveRoleOrQuirkChoice();
		}
		return positiveRoleOrQuirkChoiceComplexWithAbility();
	}

	protected List<(LeadEventBuilderData, int)> getRandomNegativeChoice(System.Random _rng, int _odds)
	{
		if (_rng.Next(0, 100) >= _odds)
		{
			return negativeRoleOrQuirkChoice();
		}
		return negativeQuirkChoice();
	}

	protected List<(LeadEventBuilderData, int)> getRandomMidChoice(System.Random _rng, int _odds)
	{
		if (_rng.Next(0, 100) >= _odds)
		{
			return manipulationChoice();
		}
		return neutralRoleAndManipChoice();
	}

	protected List<LeadEvent> getEventCheckForChips(List<(LeadEventBuilderData, int)> _choice, CasinoLead _lead, System.Random _rng)
	{
		if (_lead.chips > getMaxChipsFromDiff(tier))
		{
			return getEventChoicesFromWeightedList(_choice, _lead, _rng);
		}
		List<LeadEvent> eventChoicesFromWeightedList = getEventChoicesFromWeightedList(_choice, _lead, _rng, _check_vetoe: true, 2);
		eventChoicesFromWeightedList.Add(new CasinoChipsGainEvent(_lead, getMinMaxChipsGainFromDiff(_lead), _rng, _show_exact: true));
		return eventChoicesFromWeightedList;
	}

	private int getMaxChipsFromDiff(int _tier)
	{
		int num = 275 - _tier * 2;
		if (GameHandler.MetaData.difficulty == GameMetaData.Difficulty.EASY)
		{
			num += 75;
		}
		else if (GameHandler.MetaData.difficulty == GameMetaData.Difficulty.CHALLENGE)
		{
			num -= 25;
		}
		return num;
	}

	private MinMaxInt getMinMaxChipsGainFromDiff(CasinoLead _lead)
	{
		return GameHandler.MetaData.difficulty switch
		{
			GameMetaData.Difficulty.EASY => new MinMaxInt(Mathf.Clamp(300 - tier - _lead.chips, 40, 76 - tier), Mathf.Clamp(351 - tier * 2 - _lead.chips, 50, 91 - tier)), 
			GameMetaData.Difficulty.CHALLENGE => new MinMaxInt(Mathf.Clamp(200 - tier - _lead.chips, 25, 51 - tier), Mathf.Clamp(251 - tier * 2 - _lead.chips, 30, 66 - tier)), 
			_ => new MinMaxInt(Mathf.Clamp(250 - tier - _lead.chips, 35, 65 - tier), Mathf.Clamp(301 - tier * 2 - _lead.chips, 45, 80 - tier)), 
		};
	}

	protected override List<LeadEvent> getBackupEventChoices(Lead _lead, System.Random _rng)
	{
		return getEventChoicesFromWeightedList(new List<(LeadEventBuilderData, int)>
		{
			(new LeadEventBuilderData(new RoleClueEventData(false, RoleClassifications.INNOCENT, RoleClassifications.MEDDLER, RoleClassifications.UNDERLING)), 1200 - tier * 10),
			(new LeadEventBuilderData(new QuirkClueEventData(QuirkClueEventData.QuirkTypeAllowed.ALL, _random: false)), 800 + tier * 10),
			(new LeadEventBuilderData(new QuirkClueEventData(QuirkClueEventData.QuirkTypeAllowed.ALL, _random: true)), 200 + tier * 10),
			(new LeadEventBuilderData(LeadEventType.REPLACE_QUIRK_CLUE), 700),
			(new LeadEventBuilderData(LeadEventType.INVERT_RANDOM_ROLE_CLUE), 600),
			(new LeadEventBuilderData(LeadEventType.REPLACE_MULTI_ROLE_CLUES), 500),
			(new LeadEventBuilderData(LeadEventType.REMOVE_RANDOM_CLUE), 400)
		}, _lead, _rng);
	}
}
