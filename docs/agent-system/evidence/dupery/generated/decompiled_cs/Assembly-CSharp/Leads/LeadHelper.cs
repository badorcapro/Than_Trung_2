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

public static class LeadHelper
{
	private static int getMaxClassForClue(RoleClassifications _class, ClueTypes _clue, Vector2Int _board_size)
	{
		int result = default(int);
		switch (_clue)
		{
		case ClueTypes.ROLE_NOT_IN_PLAY:
			switch (_class)
			{
			case RoleClassifications.INNOCENT:
				result = 5;
				break;
			case RoleClassifications.MEDDLER:
				result = 3;
				break;
			case RoleClassifications.UNDERLING:
				result = 3;
				break;
			case RoleClassifications.TRAITOR:
				result = 2;
				break;
			default:
				global::_003CPrivateImplementationDetails_003E.ThrowSwitchExpressionException(_class);
				break;
			}
			return result;
		case ClueTypes.ROLE_SUSPECTED:
			switch (_class)
			{
			case RoleClassifications.INNOCENT:
				result = _board_size.x * _board_size.y - 3;
				break;
			case RoleClassifications.MEDDLER:
				result = Mathf.Min(_board_size.x * _board_size.y / 4, 4);
				break;
			case RoleClassifications.UNDERLING:
				result = Mathf.Min(_board_size.x * _board_size.y / 4, 4);
				break;
			case RoleClassifications.TRAITOR:
				result = ((_board_size.x < 4 || _board_size.y < 4) ? 2 : 3);
				break;
			default:
				global::_003CPrivateImplementationDetails_003E.ThrowSwitchExpressionException(_class);
				break;
			}
			return result;
		default:
			switch (_class)
			{
			case RoleClassifications.INNOCENT:
				result = _board_size.x * _board_size.y / 3;
				break;
			case RoleClassifications.MEDDLER:
				result = ((_board_size.x < 4 || _board_size.y < 4) ? 1 : 2);
				break;
			case RoleClassifications.UNDERLING:
				result = ((_board_size.x < 4 || _board_size.y < 4) ? 1 : 2);
				break;
			case RoleClassifications.TRAITOR:
				result = 1;
				break;
			default:
				global::_003CPrivateImplementationDetails_003E.ThrowSwitchExpressionException(_class);
				break;
			}
			return result;
		}
	}

	private static bool canAddRoleClueOfClass(RoleClassifications _class, int _in_play, int _suspected, Vector2Int _board_size)
	{
		return _class switch
		{
			RoleClassifications.INNOCENT => true, 
			RoleClassifications.MEDDLER => _in_play < ((_board_size.x + _board_size.y < 8) ? 1 : 2) && _suspected < 3, 
			RoleClassifications.UNDERLING => _in_play < ((_board_size.x + _board_size.y < 8) ? 1 : 2) && _suspected < 3, 
			RoleClassifications.TRAITOR => _in_play < 1 && _suspected < 2, 
			_ => throw new ArgumentException($"No canAddRoleClueOfClass function set up for class {_class}!"), 
		};
	}

	private static List<RoleClassifications> filterPossibleClasses(List<RoleClassifications> _av_class, ClueTypes _type, List<Roles> _prime_suspects, List<Clue> _clues, Vector2Int _board_size)
	{
		if (_av_class.Count == 0)
		{
			_av_class.addAll();
		}
		Dictionary<RoleClassifications, int> forced = new Dictionary<RoleClassifications, int>();
		if (_type == ClueTypes.ROLE_SUSPECTED)
		{
			foreach (Roles _prime_suspect in _prime_suspects)
			{
				forced.increaseOrCreate(_prime_suspect.getClassificationFromRoleType(), 1);
			}
		}
		foreach (Clue _clue in _clues)
		{
			if (_clue is RoleClue roleClue && roleClue.clue_type == _type)
			{
				forced.increaseOrCreate(roleClue.role_in_focus.getClassificationFromRoleType(), 1);
			}
		}
		int num = forced.sumValues();
		if (num >= _type switch
		{
			ClueTypes.ROLE_SUSPECTED => Mathf.Min(12, _board_size.x * _board_size.y), 
			ClueTypes.ROLE_NOT_IN_PLAY => Mathf.Min(9, _board_size.x * _board_size.y / 2), 
			ClueTypes.ROLE_IN_PLAY => Mathf.Min(6, _board_size.x * _board_size.y / 3), 
			_ => 0, 
		})
		{
			return new List<RoleClassifications>();
		}
		return _av_class.Where((RoleClassifications _c) => forced.getOrDefault(_c, 0) < getMaxClassForClue(_c, _type, _board_size)).ToList();
	}

	public static MinMaxInt getExtremeProgression<T>(this List<T> _clues, int _middle) where T : Clue
	{
		return _clues.getExtremeProgression((T _c) => _c.progression, _middle);
	}

	public static MinMaxInt getExtremeProgression<T>(this List<T> _clues, Func<T, int> _prog_getter, int _middle) where T : Clue
	{
		return _clues.Aggregate(new MinMaxInt(_middle, _middle), delegate(MinMaxInt _a, T _c)
		{
			int num = _prog_getter(_c);
			if (num < _a.min)
			{
				return new MinMaxInt(_c.progression, _a.max);
			}
			return (num > _a.max) ? new MinMaxInt(_a.min, _c.progression) : _a;
		});
	}

	public static Maybe<RoleClue> createNonTraitorRoleClue(List<Roles> _prime_suspects, List<Roles> _available_roles, List<Clue> _clues, Vector2Int _board_size, List<LeadEvent> _events, System.Random _rng, bool _immutable = false)
	{
		return createRoleClue(_prime_suspects, _available_roles, _clues, _board_size, _events, new List<ClueTypes>(), new List<RoleClassifications>
		{
			RoleClassifications.INNOCENT,
			RoleClassifications.MEDDLER,
			RoleClassifications.UNDERLING
		}, (Roles _r) => true, _rng, _immutable);
	}

	public static Maybe<RoleClue> createRoleClue(Lead _lead, System.Random _rng, params RoleClassifications[] _av_class)
	{
		return createRoleClue(_lead, new List<LeadEvent>(), _rng, new List<ClueTypes>(), _av_class);
	}

	public static Maybe<RoleClue> createRoleClue(Lead _lead, List<LeadEvent> _events, System.Random _rng, List<ClueTypes> _types, params RoleClassifications[] _av_class)
	{
		List<RoleClassifications> list = new List<RoleClassifications>().addAll();
		if (_av_class.Length != 0)
		{
			list = list.Where((RoleClassifications _c) => _av_class.Contains(_c)).ToList();
		}
		return createRoleClue(_lead.prime_suspect_set.set_roles, _lead.lead_roles, _lead.clues, _lead.current_board_size, _events, _types, list, (Roles _r) => true, _rng);
	}

	public static Maybe<RoleClue> createRoleClue(Lead _lead, List<LeadEvent> _events, System.Random _rng, bool _allow_traitors, params ClueTypes[] _av_types)
	{
		return createRoleClue(_lead, _events, _rng, (Roles _r) => true, _allow_traitors, _av_types);
	}

	public static Maybe<RoleClue> createRoleClue(Lead _lead, List<LeadEvent> _events, System.Random _rng, Func<Roles, bool> _filter, bool _allow_traitors, params ClueTypes[] _av_types)
	{
		List<RoleClassifications> list = new List<RoleClassifications>().addAll();
		if (!_allow_traitors || _lead.case_difficulty < 0.7f)
		{
			list.Remove(RoleClassifications.TRAITOR);
		}
		return createRoleClue(_lead.prime_suspect_set.set_roles, _lead.lead_roles, _lead.clues, _lead.current_board_size, _events, _av_types.ToList(), list, _filter, _rng);
	}

	public static Maybe<RoleClue> createRoleClue(List<Roles> _prime_suspects, List<Roles> _available_roles, List<Clue> _clues, Vector2Int _board_size, List<LeadEvent> _events, ClueTypes _type, RoleClassifications _classification, System.Random _rng, bool _immutable = false)
	{
		return createRoleClue(_prime_suspects, _available_roles, _clues, _board_size, _events, _type.makeListFromItem(), _classification.makeListFromItem(), (Roles _r) => true, _rng, _immutable);
	}

	public static Maybe<RoleClue> createRoleClue(List<Roles> _prime_suspects, List<Roles> _available_roles, List<Clue> _clues, Vector2Int _board_size, List<LeadEvent> _events, List<ClueTypes> _av_types, List<RoleClassifications> _av_class, Func<Roles, bool> _filter, System.Random _rng, bool _immutable = false)
	{
		if (_av_types.Count == 0)
		{
			_av_types.add(ClueTypes.ROLE_SUSPECTED, ClueTypes.ROLE_IN_PLAY, ClueTypes.ROLE_NOT_IN_PLAY);
		}
		_av_types.shuffle(_rng);
		Dictionary<ClueTypes, List<Roles>> forced_roles = new Dictionary<ClueTypes, List<Roles>> { 
		{
			ClueTypes.ROLE_SUSPECTED,
			_prime_suspects.copy()
		} };
		List<Roles> unforced = _available_roles.copy().removeRange(_prime_suspects);
		foreach (Clue _clue in _clues)
		{
			if (_clue is RoleClue roleClue)
			{
				forced_roles.addOrCreate(roleClue.clue_type, roleClue.role_in_focus);
				unforced.remove(roleClue.role_in_focus);
			}
		}
		foreach (ClueTypes clue_type in _av_types)
		{
			List<RoleClassifications> possible_classes = filterPossibleClasses(_av_class, clue_type, _prime_suspects, _clues, _board_size);
			List<Roles> seed = _available_roles.Where((Roles _r) => _filter(_r) && possible_classes.Contains(_r.getClassificationFromRoleType()) && checkRoleAgainstEvents(_r, _events)).ToList();
			seed = _prime_suspects.Aggregate(seed, (List<Roles> _a, Roles _s) => _s.createEmptyRole().generation_constraint.filterRoleCluePossibilities(_a, clue_type, _s, ClueTypes.ROLE_SUSPECTED, unforced, forced_roles));
			seed = _clues.Aggregate(seed, (List<Roles> _a, Clue _c) => _c.filterRoleForClues(_a, clue_type, unforced, forced_roles));
			seed = seed.Where((Roles _r) => _r.createEmptyRole().generation_constraint.canBeAddedAsRoleClue(_r, clue_type, unforced, forced_roles)).ToList();
			if (seed.Count > 0)
			{
				return new RoleClue(_immutable, seed.getRandomElementFromList(_rng), clue_type).maybe();
			}
		}
		return new Maybe<RoleClue>();
	}

	private static bool checkRoleAgainstEvents(Roles _role, List<LeadEvent> _events)
	{
		return !_events.Any((LeadEvent _e) => _e is IRoleFilterEvent roleFilterEvent && !roleFilterEvent.canRoleAppear(_role));
	}

	public static Maybe<QuirkClue> createQuirkClue(Lead _lead, RegionDataSO _region_data, int _tier, List<LeadEvent> _events, Func<CaseQuirks, bool> _allowed, System.Random _rng, bool _immutable = false)
	{
		return createQuirkClue(_region_data.getAvailableQuirks(_tier), _lead, _events, _allowed, _rng, _immutable);
	}

	public static Maybe<QuirkClue> createQuirkClue(List<CaseQuirks> _available_quirks, Lead _lead, List<LeadEvent> _events, Func<CaseQuirks, bool> _allowed, System.Random _rng, bool _immutable = false)
	{
		return createQuirkClue(_available_quirks, _lead.lead_roles, _lead.prime_suspect_set.set_roles, _lead.clues, _events, _allowed, _rng, _immutable);
	}

	public static Maybe<QuirkClue> createQuirkClue(List<CaseQuirks> _available_quirks, List<Roles> _lead_roles, List<Roles> _prime_suspects, List<Clue> _clues, List<LeadEvent> _events, Func<CaseQuirks, bool> _allowed, System.Random _rng, bool _immutable = false)
	{
		List<CaseQuirks> list = _available_quirks.Where((CaseQuirks _q) => _allowed(_q) && !_q.isSpecialQuirk() && !_clues.Any((Clue _c) => _c is QuirkClue quirkClue && quirkClue.quirk_in_focus == _q) && !_events.Any((LeadEvent _e) => _e is IQuirkFilterEvent quirkFilterEvent && !quirkFilterEvent.canQuirkAppear(_q))).ToList();
		if (list.Count == 0)
		{
			return new Maybe<QuirkClue>();
		}
		Dictionary<ClueTypes, List<Roles>> dictionary = new Dictionary<ClueTypes, List<Roles>> { 
		{
			ClueTypes.ROLE_SUSPECTED,
			_prime_suspects.copy()
		} };
		List<Roles> list2 = _lead_roles.copy().removeRange(_prime_suspects);
		List<CaseQuirks> list3 = new List<CaseQuirks>();
		foreach (Clue _clue in _clues)
		{
			if (_clue is RoleClue roleClue)
			{
				dictionary.addOrCreate(roleClue.clue_type, roleClue.role_in_focus);
				list2.remove(roleClue.role_in_focus);
			}
			else if (_clue is QuirkClue quirkClue2)
			{
				list3.Add(quirkClue2.quirk_in_focus);
			}
		}
		list.shuffle(_rng);
		for (int i = 0; i < list.Count; i++)
		{
			QuirkClue quirkClue3 = new QuirkClue(_immutable, list[0]);
			if (quirkClue3.isValidForClue(list3, list2, dictionary))
			{
				return quirkClue3.maybe();
			}
		}
		return new Maybe<QuirkClue>();
	}

	public static bool checkClueTypeCompatibility(this ClueTypes _type_1, ClueTypes _type_2)
	{
		switch (_type_1)
		{
		case ClueTypes.ROLE_SUSPECTED:
		case ClueTypes.ROLE_IN_PLAY:
			return _type_2 != ClueTypes.ROLE_NOT_IN_PLAY;
		case ClueTypes.ROLE_NOT_IN_PLAY:
			return _type_2 == ClueTypes.ROLE_NOT_IN_PLAY;
		default:
			Debug.LogError("No function set up to check if role can be added!");
			return true;
		}
	}

	public static LeadProgressionManager getLeadProgressionManager(this Regions _region, RegionsSO _regions_data)
	{
		return _region switch
		{
			Regions.OFFICE => new OfficeLeadProgressionManager(_regions_data, SaveHandler.instance.meta_data.getTierOfRegion(_region)), 
			Regions.CASINO => new CasinoLeadProgressionManager(_regions_data, SaveHandler.instance.meta_data.getTierOfRegion(_region)), 
			Regions.DOCKS => new DocksLeadProgressionManager(_regions_data, SaveHandler.instance.meta_data.getTierOfRegion(_region)), 
			_ => throw new ArgumentException($"No lead progression manager set up for region {GameHandler.State.current_region}!"), 
		};
	}

	public static LeadProgressionManager getSyndicateProgressionManager(GameState _state, RegionsSO _regions_data)
	{
		LeadProgressionManager leadProgressionManager;
		if (_state.lineup_clues.Count == 0)
		{
			leadProgressionManager = Regions.OFFICE.getLeadProgressionManager(_regions_data);
		}
		else if (_state.lineup_clues.Count == 1)
		{
			leadProgressionManager = Regions.CASINO.getLeadProgressionManager(_regions_data);
		}
		else
		{
			if (_state.lineup_clues.Count != 2)
			{
				throw new ArgumentException("Cannot get lead progression manager of syndicate when player already has 2 clues!");
			}
			leadProgressionManager = Regions.DOCKS.getLeadProgressionManager(_regions_data);
		}
		leadProgressionManager.setSyndicateLead();
		return leadProgressionManager;
	}

	public static StampType toStampType(this ClueTypes _clue)
	{
		return _clue switch
		{
			ClueTypes.ROLE_SUSPECTED => StampType.ROLE_SUSPECTED, 
			ClueTypes.ROLE_IN_PLAY => StampType.ROLE_IN_PLAY, 
			ClueTypes.ROLE_NOT_IN_PLAY => StampType.ROLE_NOT_IN_PLAY, 
			ClueTypes.QUIRK_IN_PLAY => StampType.QUIRK, 
			_ => throw new ArgumentException($"No stamp type set up for clue type {_clue} (in toStampType)"), 
		};
	}
}
