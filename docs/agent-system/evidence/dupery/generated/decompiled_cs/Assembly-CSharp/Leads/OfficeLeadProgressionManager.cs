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

public class OfficeLeadProgressionManager : LeadProgressionManager
{
	public override Regions region => Regions.OFFICE;

	public OfficeLeadProgressionManager(RegionsSO _regions_data, int _tier)
		: base(_regions_data[Regions.OFFICE], _tier)
	{
	}

	public override List<Lead> createRegionLeads(System.Random _rng, bool _force_new, int _wanted = 3)
	{
		List<Lead> list = new List<Lead>();
		List<RoleSetInfoStruct> list2 = new List<RoleSetInfoStruct>();
		for (int i = 0; i < _wanted; i++)
		{
			Lead lead = createLead(_rng, list2, (i != 1 || !_force_new) ? new Maybe<RoleSetInfoStruct>() : tryGetRandomNewSet(_rng));
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
		if (is_syndicate_lead)
		{
			num = Mathf.Max(num - 3, 5);
			grid_size = new Vector2Int(4, 4);
			leadDifficulty.min = Mathf.Max(leadDifficulty.min, 0.4f);
			leadDifficulty.max = Mathf.Max(leadDifficulty.max, 0.8f);
		}
		return new OfficeLead(available, grid_size, leadDifficulty, num, prime_suspects);
	}

	public override Case createQuickCase(System.Random _rng)
	{
		return createLead(_rng, new List<RoleSetInfoStruct>(), new Maybe<RoleSetInfoStruct>()).createRandomCase(_rng);
	}

	protected override List<LeadEvent> tryGetWantedChoices(Lead _lead, System.Random _rng)
	{
		if (!(_lead is OfficeLead officeLead))
		{
			Debug.LogError($"OfficeLeadProgressionManager cannot get wanted choices for a {_lead.case_type} lead! Can only do office lead!");
			return getBackupEventChoices(_lead, _rng);
		}
		if (_lead.current_case == LeadProgressionManager.getSizeIncreaseProgress(tier) && _lead.current_board_size.x == 3)
		{
			return getBoardSizeIncrease(_lead, _rng);
		}
		if (_lead.current_case == getPublicUnrestProgress(tier, _lead.max_case) && !_lead.clues.Any((Clue _c) => _c is QuirkClue quirkClue && quirkClue.quirk_in_focus == CaseQuirks.PUBLIC_UNREST))
		{
			return getEventChoicesFromWeightedList(new List<(LeadEventBuilderData, int)> { (new LeadEventBuilderData(LeadEventType.PUBLIC_UNREST), 100) }, _lead, _rng);
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
		if (_lead.current_case > 5 && _lead.current_case == _lead.max_case - 2)
		{
			return getEventChoicesFromWeightedList(getRandomPositiveChoice(_rng, tier * 10, flag), _lead, _rng);
		}
		switch (_lead.current_case)
		{
		case 1:
			if (flag && tier > 4)
			{
				return getEventChoicesFromWeightedList(getRandomNegativeChoice(_rng, tier * 5), _lead, _rng);
			}
			return getEventChoicesFromWeightedList(getRandomPositiveChoice(_rng, tier * 5, flag), _lead, _rng);
		case 2:
			return getEventChoicesFromWeightedList(getRandomPositiveChoice(_rng, 45 + tier * 6, flag), _lead, _rng);
		case 3:
			return getEventChoicesFromWeightedList(getRandomNegativeChoice(_rng, 50), _lead, _rng);
		case 4:
		{
			List<LeadEvent> list = new List<LeadEvent>();
			list.Add(new ReputationGainEvent(_rng, _lead, _show_exact: true, Mathf.Min(Mathf.Max(1, ClockCase.max_reputation - officeLead.reputation), (tier > 4) ? 2 : 3)));
			list.Add(new AddSingleRandomRoleEvent(_lead, new List<LeadEvent>(), _rng, true, ClueTypes.ROLE_IN_PLAY.makeListFromItem(), default(RoleClassifications)));
			list.Add(new AddSingleRandomQuirkEvent(_rng, _lead, new List<LeadEvent>(), region_data.getAvailableQuirks(tier), (CaseQuirks _q) => _q.isGoodQuirk(), _show_real: true));
			list.Add(new AddSingleRandomRoleEvent(_lead, new List<LeadEvent>(), _rng, true, ClueTypes.ROLE_NOT_IN_PLAY.makeListFromItem(), RoleClassifications.UNDERLING));
			list.Add(new AddSingleRandomRoleWithAbilityEvent(_rng, _lead, new List<LeadEvent>(), _show_exact: false));
			list.Add(new RemoveRandomClueEvent(_rng, _lead, new List<LeadEvent>(), _show_exact: true));
			return list.Where((LeadEvent _e) => _e.isValidForCurrentLead(_lead)).ToList().removeAllAfterIndex(3);
		}
		case 5:
			return getEventChoicesFromWeightedList(negativeRoleOrQuirkChoiceComplexWithExtraCase(), _lead, _rng);
		case 6:
			if (tier < 3 && !flag)
			{
				return getEventChoicesFromWeightedList(getRandomPositiveChoice(_rng, 20 + tier * 7, flag), _lead, _rng);
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
			return getEventChoicesFromWeightedList(getRandomChoice(_rng, 50, 35, flag), _lead, _rng);
		}
	}

	protected List<(LeadEventBuilderData, int)> getRandomChoice(System.Random _rng, int _negative_odds, int _mid_odds, bool _is_challenge)
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
		return getRandomPositiveChoice(_rng, 50, _is_challenge);
	}

	protected List<(LeadEventBuilderData, int)> getRandomPositiveChoice(System.Random _rng, int _odds, bool _challenge)
	{
		if (_rng.Next(0, 100) >= _odds)
		{
			return getPositiveChoice1(_challenge);
		}
		return getPositiveChoice2(_challenge);
	}

	protected List<(LeadEventBuilderData, int)> getRandomMidChoice(System.Random _rng, int _odds)
	{
		if (_rng.Next(0, 100) >= _odds)
		{
			return manipulationChoice();
		}
		return neutralRoleAndManipChoice();
	}

	protected List<(LeadEventBuilderData, int)> getRandomNegativeChoice(System.Random _rng, int _odds)
	{
		if (_rng.Next(0, 100) >= _odds)
		{
			return negativeRoleOrQuirkChoice();
		}
		return negativeQuirkChoice();
	}

	protected List<(LeadEventBuilderData, int)> getPositiveChoice1(bool _challenge)
	{
		return positiveRoleOrQuirkChoice().add((new LeadEventBuilderData(LeadEventType.REPUTATION_GAIN, (tier > 5 || _challenge) ? "7,4" : "6,3,1"), 1100 - tier * 5 + getRepGainOddsDiffFromDifficulty()));
	}

	protected List<(LeadEventBuilderData, int)> getPositiveChoice2(bool _challenge)
	{
		return positiveRoleOrQuirkChoiceComplex().add((new LeadEventBuilderData(LeadEventType.REPUTATION_GAIN, (tier > 5 || _challenge) ? "7,4" : "6,3,1"), 1200 - tier * 5 + getRepGainOddsDiffFromDifficulty()));
	}

	private int getRepGainOddsDiffFromDifficulty()
	{
		return GameHandler.MetaData.difficulty switch
		{
			GameMetaData.Difficulty.EASY => 150, 
			GameMetaData.Difficulty.DEFAULT => 0, 
			GameMetaData.Difficulty.CHALLENGE => -100, 
			_ => 0, 
		};
	}

	protected override List<LeadEvent> getBackupEventChoices(Lead _lead, System.Random _rng)
	{
		return getEventChoicesFromWeightedList(new List<(LeadEventBuilderData, int)>
		{
			(new LeadEventBuilderData(new RoleClueEventData(false, RoleClassifications.INNOCENT, RoleClassifications.MEDDLER, RoleClassifications.UNDERLING)), 1200 - tier * 8),
			(new LeadEventBuilderData(new QuirkClueEventData(QuirkClueEventData.QuirkTypeAllowed.ALL, _random: false)), 800 + tier * 10),
			(new LeadEventBuilderData(new QuirkClueEventData(QuirkClueEventData.QuirkTypeAllowed.ALL, _random: true)), 200 + tier * 10),
			(new LeadEventBuilderData(LeadEventType.REPUTATION_GAIN, (tier > 5) ? "7,3" : "6,4"), 750 - tier * 6),
			(new LeadEventBuilderData(LeadEventType.REPLACE_QUIRK_CLUE), 700),
			(new LeadEventBuilderData(LeadEventType.INVERT_RANDOM_ROLE_CLUE), 600),
			(new LeadEventBuilderData(LeadEventType.REPLACE_MULTI_ROLE_CLUES), 500),
			(new LeadEventBuilderData(LeadEventType.REMOVE_RANDOM_CLUE), 400)
		}, _lead, _rng);
	}

	private static int getPublicUnrestProgress(int _tier, int _max_cases)
	{
		if (GameHandler.MetaData.difficulty == GameMetaData.Difficulty.EASY)
		{
			return -1;
		}
		if (GameHandler.MetaData.difficulty == GameMetaData.Difficulty.CHALLENGE)
		{
			return getChallengePublicUnrestProgress(_tier, _max_cases);
		}
		return getDefaultPublicUnrestProgress(_tier, _max_cases);
	}

	private static int getDefaultPublicUnrestProgress(int _tier, int _max_cases)
	{
		return _tier switch
		{
			7 => _max_cases - 3, 
			8 => _max_cases - 3, 
			9 => _max_cases - 4, 
			_ => -1, 
		};
	}

	private static int getChallengePublicUnrestProgress(int _tier, int _max_cases)
	{
		return _tier switch
		{
			5 => _max_cases - 3, 
			6 => _max_cases - 3, 
			7 => _max_cases - 4, 
			8 => _max_cases - 5, 
			9 => _max_cases - 6, 
			_ => -1, 
		};
	}
}
