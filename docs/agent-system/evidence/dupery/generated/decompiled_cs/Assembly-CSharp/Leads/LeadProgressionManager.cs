using System;
using System.Collections.Generic;
using System.Linq;
using AlternateModes;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Generic;
using GRGLib.Maybe;
using Nodes.Logic;
using Save;
using UnityEngine;

namespace Leads;

public abstract class LeadProgressionManager
{
	protected enum WeightsModification
	{
		REMOVE,
		NONE,
		MINUS_500
	}

	protected RegionDataSO region_data;

	protected int tier;

	protected bool is_syndicate_lead;

	public abstract Regions region { get; }

	public Maybe<List<CaseQuirks>> available_quirks { get; protected set; } = new Maybe<List<CaseQuirks>>();

	public Maybe<CustomLeadOverrideSetting> custom_settings { get; protected set; } = new Maybe<CustomLeadOverrideSetting>();

	public bool skip_event_scene
	{
		get
		{
			if (custom_settings.is_some)
			{
				return custom_settings.value.remove_stamps;
			}
			return false;
		}
	}

	public static LeadProgressionManager load(LeadProgressionManagerCustomSave _custom, RegionsSO _regions, Maybe<AlternateModeData> _mode)
	{
		return (_custom.region switch
		{
			Regions.OFFICE => new OfficeLeadProgressionManager(_regions, SaveHandler.instance.meta_data.getTierOfRegion(_custom.region)), 
			Regions.CASINO => new CasinoLeadProgressionManager(_regions, SaveHandler.instance.meta_data.getTierOfRegion(_custom.region)), 
			Regions.DOCKS => new DocksLeadProgressionManager(_regions, SaveHandler.instance.meta_data.getTierOfRegion(_custom.region)), 
			_ => throw new ArgumentException($"Could not load lead progression manager of region {_custom.region}!"), 
		}).loadData(_custom, _mode);
	}

	protected LeadProgressionManager(RegionDataSO _region_data, int _tier)
	{
		region_data = _region_data;
		tier = _tier;
	}

	public abstract List<Lead> createRegionLeads(System.Random _rng, bool _force_new, int _wanted = 3);

	protected Maybe<RoleSetInfoStruct> tryGetRandomNewSet(System.Random _rng)
	{
		List<RoleSetsGraph> setOfTier = region_data.getSetOfTier(tier);
		if (setOfTier.Count == 0)
		{
			Debug.LogError($"Cannot force new set as tier {tier} does not have any?");
			return new Maybe<RoleSetInfoStruct>();
		}
		return new RoleSetInfoStruct(setOfTier.getRandomElementFromList(_rng)).maybe();
	}

	public List<LeadEvent> getEventChoices(Lead _lead, System.Random _rng)
	{
		if (_lead.current_case == 0 && _lead.clues.Count > 0)
		{
			return new List<LeadEvent>
			{
				new AddStartingClues(_lead, _rng)
			};
		}
		List<LeadEvent> list = checkForCustomOverride(_lead.current_case, _lead, _rng);
		if (list.Count > 0)
		{
			return list;
		}
		list = tryGetWantedChoices(_lead, _rng);
		if (list.Count > 0)
		{
			return list;
		}
		return getBackupEventChoices(_lead, _rng);
	}

	protected abstract List<LeadEvent> tryGetWantedChoices(Lead _lead, System.Random _rng);

	protected abstract List<LeadEvent> getBackupEventChoices(Lead _lead, System.Random _rng);

	public abstract Case createQuickCase(System.Random _rng);

	public void setSyndicateLead()
	{
		is_syndicate_lead = true;
	}

	public string getRegionName()
	{
		return region_data.region_name;
	}

	protected List<LeadEvent> checkForCustomOverride(int _case_nb, Lead _lead, System.Random _rng)
	{
		if (!custom_settings.is_some)
		{
			return new List<LeadEvent>();
		}
		if (custom_settings.value.mode_data.is_some && custom_settings.value.mode_data.value is IChangeEvents changeEvents)
		{
			List<LeadEvent> customEvent = changeEvents.getCustomEvent(this, _case_nb, _lead, _rng);
			if (customEvent.Count > 0)
			{
				return customEvent;
			}
		}
		if (custom_settings.value.override_event.ContainsKey(_case_nb))
		{
			return getEventChoicesFromWeightedList(new List<(LeadEventBuilderData, int)> { (new LeadEventBuilderData(custom_settings.value.override_event[_case_nb]), 100) }, _lead, _rng, _check_vetoe: false);
		}
		return new List<LeadEvent>();
	}

	protected List<LeadEvent> getEventChoicesFromWeightedList(List<(LeadEventBuilderData, int)> _w_choice, Lead _lead, System.Random _rng, bool _check_vetoe = true, int _wanted = 3)
	{
		List<LeadEvent> list = new List<LeadEvent>();
		while (list.Count < _wanted && _w_choice.Count > 0)
		{
			Maybe<LeadEventBuilderData> chosen = _w_choice.weightedChoose(_rng);
			if (!chosen.is_some)
			{
				continue;
			}
			Maybe<LeadEvent> _result;
			WeightsModification weightsModification = tryCreateLeadEvent(chosen.value, _rng, _lead, list, out _result, _check_vetoe);
			switch (weightsModification)
			{
			case WeightsModification.REMOVE:
				_w_choice.RemoveAll(((LeadEventBuilderData, int) _we) => _we.Item1.isSame(chosen.value));
				break;
			case WeightsModification.MINUS_500:
			{
				(LeadEventBuilderData, int) item = _w_choice.Find(((LeadEventBuilderData, int) _wc) => _wc.Item1.isSame(chosen.value));
				_w_choice.Remove(item);
				_w_choice.Add((chosen.value, Mathf.Max(item.Item2 - 500, 1)));
				break;
			}
			default:
				Debug.LogError($"No behaviour set up for modification {weightsModification}!");
				break;
			case WeightsModification.NONE:
				break;
			}
			if (_result.is_some)
			{
				list.Add(_result.value);
			}
		}
		return list;
	}

	protected virtual WeightsModification tryCreateLeadEvent(LeadEventBuilderData _data, System.Random _rng, Lead _lead, List<LeadEvent> _events, out Maybe<LeadEvent> _result, bool _check_vetoe = true)
	{
		if (_check_vetoe && custom_settings.is_some && custom_settings.value.vetoed.Contains(_data.event_type))
		{
			_result = new Maybe<LeadEvent>();
			return WeightsModification.REMOVE;
		}
		switch (_data.event_type)
		{
		case LeadEventType.PLUS_ONE_CASE:
			_result = PlusOneCaseEvent.tryCreateEvent(_rng, _lead, _show_exact: true);
			return WeightsModification.REMOVE;
		case LeadEventType.INCREASE_BOARD_SIZE:
			_result = IncreaseBoardSizeEvent.tryCreateEvent(_rng, _lead, _show_exact: true);
			return WeightsModification.REMOVE;
		case LeadEventType.REPUTATION_GAIN:
			try
			{
				if (_data.data == "")
				{
					return tryCreateReputationGainEvent(_lead, _rng, _events, out _result, 4, 6, 1);
				}
				List<int> list = _data.data.fromStringCommaSeperate();
				return tryCreateReputationGainEvent(_lead, _rng, _events, out _result, list.ToArray());
			}
			catch (Exception arg)
			{
				Debug.LogError($"Failed to load reputation gain event data.\nData: {_data.data}\nError: {arg}");
				return tryCreateReputationGainEvent(_lead, _rng, _events, out _result, 4, 6, 1);
			}
		case LeadEventType.CHIPS_GAIN:
			return tryCreateChipsGainEvent(_lead, _rng, _events, out _result, _show: true, new ChipsGainEventData(_data.data).gains_array);
		case LeadEventType.ADD_ROLE_CLUE:
		{
			RoleClueEventData roleClueEventData = new RoleClueEventData(_data.data);
			return tryCreateRoleClue(_lead, _rng, _events, out _result, !roleClueEventData.random, roleClueEventData.types, roleClueEventData.classes);
		}
		case LeadEventType.ADD_QUIRK_CLUE:
		{
			QuirkClueEventData quirkClueEventData = new QuirkClueEventData(_data.data);
			return tryCreateQuirkClue(_lead, _rng, _events, out _result, !quirkClueEventData.random, quirkClueEventData.validation_func);
		}
		case LeadEventType.ADD_ABILITY_ROLE_CLUE:
			return tryCreateAbilityRoleClue(_lead, _rng, _events, out _result, _data.data == "t");
		case LeadEventType.REMOVE_RANDOM_CLUE:
			_result = ((LeadEvent)new RemoveRandomClueEvent(_rng, _lead, _events, _show_exact: true)).maybe();
			if (!_result.value.isValidForCurrentLead(_lead))
			{
				_result = new Maybe<LeadEvent>();
			}
			return WeightsModification.REMOVE;
		case LeadEventType.REMOVE_QUIRK_CLUE:
			_result = ((LeadEvent)new RemoveOneQuirkEvent(_rng, _lead, _events, _show_exact: true)).maybe();
			if (!_result.value.isValidForCurrentLead(_lead))
			{
				_result = new Maybe<LeadEvent>();
			}
			return WeightsModification.REMOVE;
		case LeadEventType.REPLACE_MULTI_ROLE_CLUES:
			_result = ((LeadEvent)new ReplaceMultipleRandomRolesEvent(_rng, _lead, _events, 3, _show_exact: true)).maybe();
			if (!_result.value.isValidForCurrentLead(_lead))
			{
				_result = new Maybe<LeadEvent>();
			}
			return WeightsModification.REMOVE;
		case LeadEventType.INVERT_RANDOM_ROLE_CLUE:
			_result = ((LeadEvent)new InvertRandomRoleStatusEvent(_rng, _lead, _events, _show_exact: true)).maybe();
			if (!_result.value.isValidForCurrentLead(_lead))
			{
				_result = new Maybe<LeadEvent>();
			}
			return WeightsModification.REMOVE;
		case LeadEventType.REPLACE_QUIRK_CLUE:
			_result = ((LeadEvent)new ReplaceOneQuirkEvent(_rng, _lead, _events, region_data.getAvailableQuirks(tier), (CaseQuirks _q) => true, _show_exact: true)).maybe();
			if (!_result.value.isValidForCurrentLead(_lead))
			{
				_result = new Maybe<LeadEvent>();
			}
			return WeightsModification.REMOVE;
		case LeadEventType.FILL_OUT_WITH_ROLE_CLUES:
			_result = ((LeadEvent)new FillOutWithRandomRolesEvent(_rng, _lead, _events)).maybe();
			if (!_result.value.isValidForCurrentLead(_lead))
			{
				_result = new Maybe<LeadEvent>();
			}
			return WeightsModification.REMOVE;
		case LeadEventType.PUBLIC_UNREST:
			_result = ((LeadEvent)new PublicUnresetEvent(_rng, _lead)).maybe();
			if (!_result.value.isValidForCurrentLead(_lead))
			{
				_result = new Maybe<LeadEvent>();
			}
			return WeightsModification.REMOVE;
		default:
			Debug.LogError($"No function set up to create lead event of type {_data.event_type}!");
			_result = new Maybe<LeadEvent>();
			return WeightsModification.REMOVE;
		}
	}

	protected WeightsModification tryCreateReputationGainEvent(Lead _lead, System.Random _rng, List<LeadEvent> _exist, out Maybe<LeadEvent> _created, params int[] _rep_gain_odds)
	{
		if (_exist.Any((LeadEvent _e) => _e is ReputationGainEvent))
		{
			return failEventCreation(out _created);
		}
		List<(int, int)> list = new List<(int, int)>();
		if (_lead is OfficeLead officeLead)
		{
			if (officeLead.reputation == 6)
			{
				return failEventCreation(out _created);
			}
			int num = Mathf.Min((_rep_gain_odds.Length == 0) ? 3 : _rep_gain_odds.Length, 6 - officeLead.reputation);
			for (int i = 0; i < num; i++)
			{
				list.Add((i + 1, (_rep_gain_odds.Length == 0) ? 1 : _rep_gain_odds[i]));
			}
		}
		else
		{
			if (!(_lead is DocksLead docksLead))
			{
				Debug.LogError("Trying to create reputation gain event while not in a reputation based region!");
				return failEventCreation(out _created);
			}
			if (docksLead.reputation == 6)
			{
				return failEventCreation(out _created);
			}
			int num2 = Mathf.Min((_rep_gain_odds.Length == 0) ? 3 : _rep_gain_odds.Length, 6 - docksLead.reputation);
			for (int j = 0; j < num2; j++)
			{
				list.Add((j + 1, (_rep_gain_odds.Length == 0) ? 1 : _rep_gain_odds[j]));
			}
		}
		_created = ReputationGainEvent.tryCreateEvent(_rng, _lead, list.weightedChoose(_rng).value, _show_exact: true);
		return WeightsModification.REMOVE;
	}

	protected WeightsModification tryCreateRoleClue(Lead _lead, System.Random _rng, List<LeadEvent> _exist, out Maybe<LeadEvent> _created, bool _show, ClueTypes[] _types, params RoleClassifications[] _available_class)
	{
		if (!_show && _exist.Any((LeadEvent _e) => _e is AddSingleRandomRoleEvent && !_e.show_exact))
		{
			_show = true;
		}
		_created = ((LeadEvent)new AddSingleRandomRoleEvent(_lead, _exist, _rng, _show, _types.ToList(), _available_class)).maybe();
		if (!_created.value.isValidForCurrentLead(_lead))
		{
			return failEventCreation(out _created);
		}
		return WeightsModification.MINUS_500;
	}

	protected WeightsModification tryCreateQuirkClue(Lead _lead, System.Random _rng, List<LeadEvent> _exist, out Maybe<LeadEvent> _created, bool _show, Func<CaseQuirks, bool> _filter, bool _allow_show_swap = true)
	{
		if (!_show && _exist.Any((LeadEvent _e) => _e is AddSingleRandomQuirkEvent && !_e.show_exact))
		{
			if (!_allow_show_swap)
			{
				return failEventCreation(out _created);
			}
			_show = true;
		}
		_created = ((LeadEvent)new AddSingleRandomQuirkEvent(_rng, _lead, _exist, getAvailableQuirks(), _filter, _show)).maybe();
		if (!_created.value.isValidForCurrentLead(_lead))
		{
			return failEventCreation(out _created);
		}
		return WeightsModification.MINUS_500;
	}

	public List<CaseQuirks> getAvailableQuirks()
	{
		if (!available_quirks.is_some)
		{
			return region_data.getAvailableQuirks(tier);
		}
		return available_quirks.value;
	}

	protected WeightsModification tryCreateAbilityRoleClue(Lead _lead, System.Random _rng, List<LeadEvent> _exist, out Maybe<LeadEvent> _created, bool _show)
	{
		_created = ((LeadEvent)new AddSingleRandomRoleWithAbilityEvent(_rng, _lead, _exist, _show)).maybe();
		if (!_created.value.isValidForCurrentLead(_lead))
		{
			return failEventCreation(out _created);
		}
		return WeightsModification.REMOVE;
	}

	protected WeightsModification tryCreateChipsGainEvent(Lead _lead, System.Random _rng, List<LeadEvent> _exist, out Maybe<LeadEvent> _created, bool _show, params (int, MinMaxInt)[] _current_to_range)
	{
		if (_exist.Any((LeadEvent _e) => _e is CasinoChipsGainEvent))
		{
			return failEventCreation(out _created);
		}
		if (_lead is CasinoLead casinoLead)
		{
			for (int i = 0; i < _current_to_range.Length; i++)
			{
				if (_current_to_range[i].Item1 > casinoLead.chips)
				{
					_created = CasinoChipsGainEvent.tryCreateEvent(_rng, _lead, _current_to_range[i].Item2, _show);
					return WeightsModification.REMOVE;
				}
			}
			return failEventCreation(out _created);
		}
		Debug.LogError("Trying to create chips gain event while not in the casino!");
		return failEventCreation(out _created);
	}

	private WeightsModification failEventCreation(out Maybe<LeadEvent> _creation)
	{
		_creation = new Maybe<LeadEvent>();
		return WeightsModification.REMOVE;
	}

	protected List<LeadEvent> getBoardSizeIncrease(Lead _lead, System.Random _rng)
	{
		return getEventChoicesFromWeightedList(new List<(LeadEventBuilderData, int)> { (new LeadEventBuilderData(LeadEventType.INCREASE_BOARD_SIZE), 100) }, _lead, _rng);
	}

	protected List<LeadEvent> getTraitorChoice(Lead _lead, System.Random _rng)
	{
		return getEventChoicesFromWeightedList(new List<(LeadEventBuilderData, int)>
		{
			(new LeadEventBuilderData(new RoleClueEventData(false, RoleClassifications.TRAITOR).setTypes(ClueTypes.ROLE_IN_PLAY)), 2000 - tier * 25),
			(new LeadEventBuilderData(new RoleClueEventData(false, RoleClassifications.TRAITOR).setTypes(default(ClueTypes))), 1800),
			(new LeadEventBuilderData(new RoleClueEventData(false, RoleClassifications.TRAITOR).setTypes(ClueTypes.ROLE_NOT_IN_PLAY)), 1300 + tier * 25),
			(new LeadEventBuilderData(LeadEventType.INVERT_RANDOM_ROLE_CLUE), 300),
			(new LeadEventBuilderData(LeadEventType.REPLACE_QUIRK_CLUE), 200),
			(new LeadEventBuilderData(LeadEventType.REPLACE_MULTI_ROLE_CLUES), 200),
			(new LeadEventBuilderData(LeadEventType.REMOVE_RANDOM_CLUE), 50)
		}, _lead, _rng);
	}

	protected List<(LeadEventBuilderData, int)> positiveRoleOrQuirkChoice()
	{
		List<(LeadEventBuilderData, int)> list = new List<(LeadEventBuilderData, int)>();
		list.Add((new LeadEventBuilderData(new RoleClueEventData(false, default(RoleClassifications)).setTypes(ClueTypes.ROLE_IN_PLAY, ClueTypes.ROLE_SUSPECTED)), 1400 - tier * 10));
		list.Add((new LeadEventBuilderData(new QuirkClueEventData(QuirkClueEventData.QuirkTypeAllowed.ONLY_GOOD, _random: false)), 1300 + tier * 15));
		list.Add((new LeadEventBuilderData(new RoleClueEventData(false, RoleClassifications.MEDDLER).setTypes(ClueTypes.ROLE_NOT_IN_PLAY)), 500 - tier * 10));
		return list;
	}

	protected List<(LeadEventBuilderData, int)> positiveRoleOrQuirkChoiceComplex()
	{
		List<(LeadEventBuilderData, int)> list = new List<(LeadEventBuilderData, int)>();
		list.Add((new LeadEventBuilderData(new QuirkClueEventData(QuirkClueEventData.QuirkTypeAllowed.ONLY_GOOD, _random: false)), 1300 + tier * 15));
		list.Add((new LeadEventBuilderData(new RoleClueEventData(false, default(RoleClassifications)).setTypes(default(ClueTypes))), 1200 - tier * 10));
		list.Add((new LeadEventBuilderData(new RoleClueEventData(false, RoleClassifications.MEDDLER, RoleClassifications.UNDERLING).setTypes(ClueTypes.ROLE_NOT_IN_PLAY)), 800 - tier * 10));
		list.Add((new LeadEventBuilderData(new QuirkClueEventData(QuirkClueEventData.QuirkTypeAllowed.ONLY_GOOD, _random: true)), 600 + tier * 15));
		list.Add((new LeadEventBuilderData(new RoleClueEventData(false, default(RoleClassifications)).setTypes(ClueTypes.ROLE_IN_PLAY)), 500 - tier * 10));
		return list;
	}

	protected List<(LeadEventBuilderData, int)> positiveRoleOrQuirkChoiceComplexWithAbility()
	{
		return positiveRoleOrQuirkChoiceComplex().add((new LeadEventBuilderData(LeadEventType.ADD_ABILITY_ROLE_CLUE), 900 - tier * 10));
	}

	protected List<(LeadEventBuilderData, int)> manipulationChoice()
	{
		return new List<(LeadEventBuilderData, int)>
		{
			(new LeadEventBuilderData(LeadEventType.INVERT_RANDOM_ROLE_CLUE), 1200),
			(new LeadEventBuilderData(LeadEventType.REPLACE_QUIRK_CLUE), 900),
			(new LeadEventBuilderData(LeadEventType.REPLACE_MULTI_ROLE_CLUES), 800),
			(new LeadEventBuilderData(LeadEventType.PLUS_ONE_CASE), 300 + tier * 15),
			(new LeadEventBuilderData(LeadEventType.REMOVE_RANDOM_CLUE), 100)
		};
	}

	protected List<(LeadEventBuilderData, int)> neutralRoleAndManipChoice()
	{
		List<(LeadEventBuilderData, int)> list = new List<(LeadEventBuilderData, int)>();
		list.Add((new LeadEventBuilderData(new RoleClueEventData(false, RoleClassifications.UNDERLING)), 1200));
		list.Add((new LeadEventBuilderData(new RoleClueEventData(false, RoleClassifications.MEDDLER)), 1100));
		list.Add((new LeadEventBuilderData(new RoleClueEventData(false, default(RoleClassifications)).setTypes(ClueTypes.ROLE_NOT_IN_PLAY)), 600));
		list.Add((new LeadEventBuilderData(LeadEventType.REPLACE_MULTI_ROLE_CLUES), 600));
		list.Add((new LeadEventBuilderData(LeadEventType.INVERT_RANDOM_ROLE_CLUE), 300));
		list.Add((new LeadEventBuilderData(LeadEventType.PLUS_ONE_CASE), 300));
		list.Add((new LeadEventBuilderData(LeadEventType.FILL_OUT_WITH_ROLE_CLUES), 100));
		list.Add((new LeadEventBuilderData(LeadEventType.REMOVE_RANDOM_CLUE), 50));
		return list;
	}

	protected List<(LeadEventBuilderData, int)> neutralChaoticChoice()
	{
		List<(LeadEventBuilderData, int)> list = new List<(LeadEventBuilderData, int)>();
		list.Add((new LeadEventBuilderData(LeadEventType.INVERT_RANDOM_ROLE_CLUE), 1000));
		list.Add((new LeadEventBuilderData(LeadEventType.REPLACE_MULTI_ROLE_CLUES), 900));
		list.Add((new LeadEventBuilderData(new RoleClueEventData(false, RoleClassifications.UNDERLING)), 900));
		list.Add((new LeadEventBuilderData(new RoleClueEventData(false, RoleClassifications.MEDDLER)), 800));
		list.Add((new LeadEventBuilderData(new RoleClueEventData(false, default(RoleClassifications))), 700));
		list.Add((new LeadEventBuilderData(new QuirkClueEventData(QuirkClueEventData.QuirkTypeAllowed.ALL, _random: false)), 600));
		list.Add((new LeadEventBuilderData(LeadEventType.PLUS_ONE_CASE), 500));
		list.Add((new LeadEventBuilderData(LeadEventType.FILL_OUT_WITH_ROLE_CLUES), 300));
		list.Add((new LeadEventBuilderData(LeadEventType.REMOVE_RANDOM_CLUE), 100));
		return list;
	}

	protected List<(LeadEventBuilderData, int)> negativeQuirkChoice()
	{
		return new List<(LeadEventBuilderData, int)>
		{
			(new LeadEventBuilderData(new QuirkClueEventData(QuirkClueEventData.QuirkTypeAllowed.ONLY_BAD, _random: false)), 1300 - tier * 15),
			(new LeadEventBuilderData(new QuirkClueEventData(QuirkClueEventData.QuirkTypeAllowed.ALL, _random: true)), 300 + tier * 15)
		};
	}

	protected List<(LeadEventBuilderData, int)> negativeRoleOrQuirkChoice()
	{
		List<(LeadEventBuilderData, int)> list = new List<(LeadEventBuilderData, int)>();
		list.Add((new LeadEventBuilderData(new RoleClueEventData(false, RoleClassifications.UNDERLING).setTypes(ClueTypes.ROLE_IN_PLAY, ClueTypes.ROLE_SUSPECTED)), 1400 - tier * 15));
		list.Add((new LeadEventBuilderData(new QuirkClueEventData(QuirkClueEventData.QuirkTypeAllowed.ONLY_BAD, _random: false)), 1300 + tier * 25));
		list.Add((new LeadEventBuilderData(new RoleClueEventData(false, RoleClassifications.MEDDLER).setTypes(default(ClueTypes))), 500 - tier * 10));
		return list;
	}

	protected List<(LeadEventBuilderData, int)> negativeRoleOrQuirkChoiceComplex()
	{
		List<(LeadEventBuilderData, int)> list = new List<(LeadEventBuilderData, int)>();
		list.Add((new LeadEventBuilderData(new RoleClueEventData(false, RoleClassifications.UNDERLING).setTypes(ClueTypes.ROLE_IN_PLAY, ClueTypes.ROLE_SUSPECTED)), 1400 - tier * 10));
		list.Add((new LeadEventBuilderData(new QuirkClueEventData(QuirkClueEventData.QuirkTypeAllowed.ONLY_BAD, _random: false)), 1300 + tier * 15));
		list.Add((new LeadEventBuilderData(new RoleClueEventData(false, default(RoleClassifications)).setTypes(ClueTypes.ROLE_NOT_IN_PLAY)), 700 - tier * 10));
		list.Add((new LeadEventBuilderData(new RoleClueEventData(false, RoleClassifications.MEDDLER).setTypes(default(ClueTypes))), 600 - tier * 10));
		list.Add((new LeadEventBuilderData(new QuirkClueEventData(QuirkClueEventData.QuirkTypeAllowed.ALL, _random: true)), 400 + tier * 15));
		return list;
	}

	protected List<(LeadEventBuilderData, int)> negativeRoleOrQuirkChoiceComplexWithExtraCase()
	{
		return positiveRoleOrQuirkChoiceComplex().add((new LeadEventBuilderData(LeadEventType.PLUS_ONE_CASE), 900));
	}

	public void setAvailableQuirks(List<CaseQuirks> _quirks)
	{
		available_quirks = _quirks.maybe();
	}

	public void resetAvailableQuirks()
	{
		available_quirks = new Maybe<List<CaseQuirks>>();
	}

	public List<CaseQuirks> getAvailableQuirks(List<CaseQuirks> _default)
	{
		if (!available_quirks.is_some)
		{
			return _default;
		}
		return available_quirks.value;
	}

	private CustomLeadOverrideSetting getOrCreateOverrideSettings()
	{
		if (!custom_settings.is_some)
		{
			custom_settings = new CustomLeadOverrideSetting().maybe();
		}
		return custom_settings.value;
	}

	public void clearOverrideEvents()
	{
		custom_settings = new Maybe<CustomLeadOverrideSetting>();
	}

	public void addOverrideEvent(int _at, LeadEventType _event)
	{
		getOrCreateOverrideSettings().override_event[_at] = _event;
	}

	public void addEventVetoe(params LeadEventType[] _events)
	{
		getOrCreateOverrideSettings().vetoed.addRange(_events);
	}

	public void setNoStamps()
	{
		getOrCreateOverrideSettings().remove_stamps = true;
	}

	public void loadCustomSettings(string _save_data)
	{
		loadCustomSettings(_save_data, new Maybe<AlternateModeData>());
	}

	public void loadCustomSettings(string _save_data, Maybe<AlternateModeData> _data)
	{
		custom_settings = ((_save_data == "") ? new Maybe<CustomLeadOverrideSetting>() : new CustomLeadOverrideSetting(_save_data, _data).maybe());
	}

	public void setAltMode(AlternateModeData _data)
	{
		getOrCreateOverrideSettings().mode_data = _data.maybe();
	}

	public string getOverrideSaveData()
	{
		if (!custom_settings.is_some)
		{
			return "";
		}
		return custom_settings.value.toSaveData();
	}

	public LeadProgressionManager loadData(LeadProgressionManagerCustomSave _save, Maybe<AlternateModeData> _data)
	{
		loadCustomSettings(_save.custom_override, _data);
		available_quirks = (_save.available_quirks.is_some ? _save.available_quirks.value.copy().maybe() : new Maybe<List<CaseQuirks>>());
		return this;
	}

	protected static MinMaxInt getLeadLengthPossibleRange(int _tier)
	{
		return getLeadLengthPossibleRange(GameHandler.MetaData.difficulty, _tier);
	}

	protected static MinMaxInt getLeadLengthPossibleRange(GameMetaData.Difficulty _diff, int _tier)
	{
		MinMaxInt baseLeadLengthPossibleRange = getBaseLeadLengthPossibleRange(_tier);
		if (_diff == GameMetaData.Difficulty.EASY && _tier > 5)
		{
			baseLeadLengthPossibleRange -= new MinMaxInt(0, 1);
		}
		if (_diff == GameMetaData.Difficulty.CHALLENGE)
		{
			baseLeadLengthPossibleRange += new MinMaxInt(1, 1);
		}
		return baseLeadLengthPossibleRange;
	}

	protected static MinMaxInt getBaseLeadLengthPossibleRange(int _tier)
	{
		return _tier switch
		{
			1 => new MinMaxInt(6, 7), 
			2 => new MinMaxInt(6, 7), 
			3 => new MinMaxInt(6, 8), 
			4 => new MinMaxInt(6, 8), 
			5 => new MinMaxInt(6, 8), 
			6 => new MinMaxInt(6, 9), 
			7 => new MinMaxInt(7, 9), 
			8 => new MinMaxInt(7, 9), 
			9 => new MinMaxInt(8, 10), 
			_ => getBaseLeadLengthPossibleRange(1), 
		};
	}

	protected static Vector2Int getStartingBoardSize(int _tier)
	{
		return getStartingBoardSize(GameHandler.MetaData.difficulty, _tier);
	}

	protected static Vector2Int getStartingBoardSize(GameMetaData.Difficulty _diff, int _tier)
	{
		return _diff switch
		{
			GameMetaData.Difficulty.EASY => (_tier < 7) ? new Vector2Int(3, 3) : new Vector2Int(4, 4), 
			GameMetaData.Difficulty.DEFAULT => (_tier < 5) ? new Vector2Int(3, 3) : new Vector2Int(4, 4), 
			GameMetaData.Difficulty.CHALLENGE => (_tier < 3) ? new Vector2Int(3, 3) : new Vector2Int(4, 4), 
			_ => getStartingBoardSize(GameMetaData.Difficulty.DEFAULT, _tier), 
		};
	}

	protected static int getSizeIncreaseProgress(int _tier)
	{
		return getSizeIncreaseProgress(GameHandler.MetaData.difficulty, _tier);
	}

	protected static int getSizeIncreaseProgress(GameMetaData.Difficulty _diff, int _tier)
	{
		return _diff switch
		{
			GameMetaData.Difficulty.EASY => (_tier < 5) ? 3 : 2, 
			GameMetaData.Difficulty.DEFAULT => (_tier < 3) ? 3 : 2, 
			GameMetaData.Difficulty.CHALLENGE => (_tier < 2) ? 3 : 2, 
			_ => getSizeIncreaseProgress(GameMetaData.Difficulty.DEFAULT, _tier), 
		};
	}

	protected static MinMaxFloat getLeadDifficulty(int _tier)
	{
		return getLeadDifficulty(GameHandler.MetaData.difficulty, _tier);
	}

	protected static MinMaxFloat getLeadDifficulty(GameMetaData.Difficulty _diff, int _tier)
	{
		return _diff switch
		{
			GameMetaData.Difficulty.EASY => getBaseLeadDifficulty(_tier) - new MinMaxFloat(0.17f, 0.17f), 
			GameMetaData.Difficulty.DEFAULT => getBaseLeadDifficulty(_tier), 
			GameMetaData.Difficulty.CHALLENGE => getBaseLeadDifficulty(_tier) + new MinMaxFloat(0.15f, 0.15f), 
			_ => getLeadDifficulty(GameMetaData.Difficulty.DEFAULT, _tier), 
		};
	}

	protected static MinMaxFloat getBaseLeadDifficulty(int _tier)
	{
		return _tier switch
		{
			1 => new MinMaxFloat(0.2f, 0.7f), 
			2 => new MinMaxFloat(0.22f, 0.72f), 
			3 => new MinMaxFloat(0.24f, 0.74f), 
			4 => new MinMaxFloat(0.26f, 0.76f), 
			5 => new MinMaxFloat(0.28f, 0.78f), 
			6 => new MinMaxFloat(0.3f, 0.8f), 
			7 => new MinMaxFloat(0.31f, 0.81f), 
			8 => new MinMaxFloat(0.32f, 0.83f), 
			9 => new MinMaxFloat(0.33f, 0.85f), 
			_ => getLeadDifficulty(1), 
		};
	}

	protected static MinMaxFloat getLeadDifficulty(MinMaxFloat _base, System.Random _rng, float _max_offset = 0.06f)
	{
		float num = _rng.nextFloat(0f - _max_offset, _max_offset);
		MinMaxFloat result = _base + new MinMaxFloat(num, num);
		if (result.min < 0f)
		{
			result = new MinMaxFloat(0f, result.max);
		}
		if (result.max > 1f)
		{
			result = new MinMaxFloat(result.min, 1f);
		}
		else if (result.max < 0.7f)
		{
			result = new MinMaxFloat(result.min, 0.7f);
		}
		return result;
	}
}
