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

public class DocksLeadProgressionManager : LeadProgressionManager
{
	public override Regions region => Regions.DOCKS;

	public DocksLeadProgressionManager(RegionsSO _region_data, int _tier)
		: base(_region_data[Regions.DOCKS], _tier)
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
		int num = getNeededArrestsPossibleRange(tier).get(_rng);
		Vector2Int grid_size = LeadProgressionManager.getStartingBoardSize(tier);
		if (is_syndicate_lead)
		{
			num = Mathf.Max(num - 6, 10);
			grid_size = new Vector2Int(4, 4);
			leadDifficulty.min = Mathf.Max(leadDifficulty.min, 0.4f);
			leadDifficulty.max = Mathf.Max(leadDifficulty.max, 0.8f);
		}
		return new DocksLead(available, grid_size, leadDifficulty, num, prime_suspects);
	}

	public override Case createQuickCase(System.Random _rng)
	{
		return createLead(_rng, new List<RoleSetInfoStruct>(), new Maybe<RoleSetInfoStruct>()).createRandomCase(_rng);
	}

	protected override List<LeadEvent> tryGetWantedChoices(Lead _lead, System.Random _rng)
	{
		if (!(_lead is DocksLead { current_board_size: var current_board_size } docksLead))
		{
			Debug.LogError($"DocksLeadProgressionManager cannot get wanted choices for a {_lead.case_type} lead! Can only do docks lead!");
			return getBackupEventChoices(_lead, _rng);
		}
		if (current_board_size.x == 3 && docksLead.evil_arrested > getSizeIncreaseArrestProgress(tier))
		{
			return getBoardSizeIncrease(_lead, _rng);
		}
		if (docksLead.evil_arrested >= docksLead.needed_arrested - 4 - getExtraTraitorArrests(tier) && !docksLead.clues.Any((Clue _c) => _c is RoleClue roleClue && roleClue.role_in_focus.getClassificationFromRoleType() == RoleClassifications.TRAITOR && roleClue.clue_type != ClueTypes.ROLE_NOT_IN_PLAY))
		{
			if (is_syndicate_lead && _lead.current_board_size.x < 5)
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
			return getEventChoicesFromWeightedList(getRandomPositiveChoice(_rng, tier * 5), _lead, _rng);
		case 2:
			return getEventChoicesFromWeightedList(getRandomPositiveChoice(_rng, 45 + tier * 6), _lead, _rng);
		case 3:
			return getEventChoicesFromWeightedList(getRandomNegativeChoice(_rng, 50), _lead, _rng);
		case 4:
		{
			List<LeadEvent> list = new List<LeadEvent>();
			list.Add(new ReputationGainEvent(_rng, _lead, _show_exact: true, Mathf.Min(Mathf.Max(1, DocksCase.max_reputation - docksLead.reputation), (tier > 4) ? 2 : 3)));
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
			return getPositiveChoice1();
		}
		return getPositiveChoice2();
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

	protected List<(LeadEventBuilderData, int)> getPositiveChoice1()
	{
		return positiveRoleOrQuirkChoice().add((new LeadEventBuilderData(LeadEventType.REPUTATION_GAIN, (tier > 5) ? "7,4" : "6,3,1"), 850 - tier * 10));
	}

	protected List<(LeadEventBuilderData, int)> getPositiveChoice2()
	{
		return positiveRoleOrQuirkChoiceComplex().add((new LeadEventBuilderData(LeadEventType.REPUTATION_GAIN, (tier > 5) ? "7,4" : "6,3,1"), 750 - tier * 10));
	}

	protected override List<LeadEvent> getBackupEventChoices(Lead _lead, System.Random _rng)
	{
		return getEventChoicesFromWeightedList(new List<(LeadEventBuilderData, int)>
		{
			(new LeadEventBuilderData(new RoleClueEventData(false, RoleClassifications.INNOCENT, RoleClassifications.MEDDLER, RoleClassifications.UNDERLING)), 1200),
			(new LeadEventBuilderData(new QuirkClueEventData(QuirkClueEventData.QuirkTypeAllowed.ALL, _random: false)), 800),
			(new LeadEventBuilderData(new QuirkClueEventData(QuirkClueEventData.QuirkTypeAllowed.ALL, _random: true)), 200),
			(new LeadEventBuilderData(LeadEventType.REPLACE_QUIRK_CLUE), 700),
			(new LeadEventBuilderData(LeadEventType.INVERT_RANDOM_ROLE_CLUE), 600),
			(new LeadEventBuilderData(LeadEventType.REPLACE_MULTI_ROLE_CLUES), 500),
			(new LeadEventBuilderData(LeadEventType.REPUTATION_GAIN, "8,6,1"), 500),
			(new LeadEventBuilderData(LeadEventType.REMOVE_RANDOM_CLUE), 400)
		}, _lead, _rng);
	}

	private static MinMaxInt getNeededArrestsPossibleRange(int _tier)
	{
		MinMaxInt baseNeededArrestsPossibleRange = getBaseNeededArrestsPossibleRange(_tier);
		if (GameHandler.MetaData.difficulty == GameMetaData.Difficulty.EASY)
		{
			baseNeededArrestsPossibleRange -= new MinMaxInt(1, 2);
		}
		if (GameHandler.MetaData.difficulty == GameMetaData.Difficulty.CHALLENGE)
		{
			baseNeededArrestsPossibleRange += new MinMaxInt(2, 1);
		}
		return baseNeededArrestsPossibleRange;
	}

	private static MinMaxInt getBaseNeededArrestsPossibleRange(int _tier)
	{
		return _tier switch
		{
			1 => new MinMaxInt(12, 15), 
			2 => new MinMaxInt(13, 15), 
			3 => new MinMaxInt(14, 16), 
			4 => new MinMaxInt(14, 17), 
			5 => new MinMaxInt(15, 18), 
			6 => new MinMaxInt(16, 19), 
			7 => new MinMaxInt(17, 20), 
			8 => new MinMaxInt(18, 20), 
			9 => new MinMaxInt(19, 21), 
			_ => getBaseNeededArrestsPossibleRange(1), 
		};
	}

	private static int getSizeIncreaseArrestProgress(int _tier)
	{
		return GameHandler.MetaData.difficulty switch
		{
			GameMetaData.Difficulty.EASY => Mathf.Max(8 - _tier, 3), 
			GameMetaData.Difficulty.CHALLENGE => 3, 
			_ => (_tier < 2) ? 5 : 3, 
		};
	}

	private static int getExtraTraitorArrests(int _tier)
	{
		if (GameHandler.MetaData.difficulty != GameMetaData.Difficulty.CHALLENGE)
		{
			return 0;
		}
		if (_tier >= 4)
		{
			if (_tier >= 7)
			{
				return _tier - 6;
			}
			return 1;
		}
		return 0;
	}
}
