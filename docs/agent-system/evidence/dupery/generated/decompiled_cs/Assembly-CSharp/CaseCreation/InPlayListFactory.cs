using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Leads;
using Quirks;

namespace CaseCreation;

public class InPlayListFactory
{
	public class InPlayListFactoryResult
	{
		public List<Roles> in_play_roles;

		public List<LocationTypes> in_play_locations;

		public InPlayListFactoryResult(List<Roles> _roles, List<LocationTypes> _locations)
		{
			in_play_roles = _roles;
			in_play_locations = _locations;
		}
	}

	private enum RoleAdditionResult
	{
		ERROR = -1,
		FAIL,
		SUCCESS
	}

	protected Action<string> print_error;

	protected Random random;

	protected Func<Roles, RoleData> role_getter;

	protected List<Roles> suspect_list;

	protected Dictionary<RoleClassifications, int> ratio;

	protected List<Roles> forced_in_play;

	protected float difficulty_01;

	protected List<LocationTypes> in_play_locations;

	protected int location_spaces_available;

	protected List<CaseQuirkData> active_quirks;

	protected List<ITransformationGenerationConstraint> wanted_transformations = new List<ITransformationGenerationConstraint>();

	public HashSet<Roles> vetoed = new HashSet<Roles>();

	public List<ChainMarker<Roles>> attempt_roles = new List<ChainMarker<Roles>>();

	public List<ChainMarker<LocationTypes>> attempt_locations = new List<ChainMarker<LocationTypes>>();

	protected Dictionary<RoleClassifications, int> remaining_ratio;

	public Either<string, InPlayListFactoryResult> result = new Either<string, InPlayListFactoryResult>("NOT BUILT");

	public InPlayListFactory(Dictionary<RoleClassifications, int> _ratio, SuspectListFactory.SuspectListFactoryResult _suspects_results, List<CaseQuirkData> _quirks, List<Clue> _clues, float _diff, int _board_space_count, Random _rng, Func<Roles, RoleData> _getter, Action<string> _error)
		: this(_suspects_results.suspect_list, _quirks, _ratio, _clues.Aggregate(new List<Roles>(), (List<Roles> _a, Clue _c) => (!(_c is RoleClue { clue_type: ClueTypes.ROLE_IN_PLAY } roleClue)) ? _a : _a.add(roleClue.role_in_focus)), _diff, _suspects_results.wanted_locations, _board_space_count, _rng, _getter, _error)
	{
	}

	public InPlayListFactory(List<Roles> _suspect_list, List<CaseQuirkData> _quirks, Dictionary<RoleClassifications, int> _ratio, List<Roles> _forced, float _diff, List<LocationTypes> _locations, int _board_space_count, Random _rng, Func<Roles, RoleData> _getter, Action<string> _error)
	{
		print_error = _error;
		random = _rng;
		role_getter = _getter;
		suspect_list = _suspect_list;
		ratio = _ratio;
		forced_in_play = _forced;
		difficulty_01 = _diff;
		in_play_locations = _locations;
		location_spaces_available = _board_space_count - ratio.sumValues();
		active_quirks = _quirks;
		result = createInPlayList();
	}

	public Either<string, InPlayListFactoryResult> createInPlayList()
	{
		attempt_roles = new List<ChainMarker<Roles>>();
		attempt_locations = in_play_locations.Select((LocationTypes _l) => new ChainMarker<LocationTypes>(_l, _locked: true)).ToList();
		Dictionary<RoleClassifications, List<Roles>> suspects_by_class = suspect_list.Aggregate(new Dictionary<RoleClassifications, List<Roles>>
		{
			{
				RoleClassifications.INNOCENT,
				new List<Roles>()
			},
			{
				RoleClassifications.MEDDLER,
				new List<Roles>()
			},
			{
				RoleClassifications.UNDERLING,
				new List<Roles>()
			},
			{
				RoleClassifications.TRAITOR,
				new List<Roles>()
			}
		}, delegate(Dictionary<RoleClassifications, List<Roles>> _a, Roles _r)
		{
			if (!forced_in_play.Contains(_r))
			{
				_a[_r.getClassificationFromRoleType()].add(_r);
			}
			return _a;
		});
		ratio = active_quirks.Aggregate(ratio.copy(), (Dictionary<RoleClassifications, int> _a, CaseQuirkData _q) => (!_q.is_ratio_modification_quirk) ? _a : _q.onRatioModification(_a, ratio, suspect_list, random));
		remaining_ratio = ratio.copy();
		List<Roles> remaining_forced = forced_in_play.copy();
		while (remaining_ratio.Any((KeyValuePair<RoleClassifications, int> _r) => _r.Value > 0))
		{
			if (remaining_forced.Count > 0)
			{
				if (!tryAddForced(role_getter(remaining_forced[0]), suspect_list))
				{
					return new Either<string, InPlayListFactoryResult>($"Could not add forced role {remaining_forced[0]}!");
				}
				attempt_roles.ForEach(delegate(ChainMarker<Roles> _r)
				{
					remaining_forced.Remove(_r.data);
					suspects_by_class[_r.data.getClassificationFromRoleType()].Remove(_r.data);
				});
			}
			else
			{
				Maybe<string> maybe = fillInPlayList(suspects_by_class);
				if (maybe.is_some)
				{
					return new Either<string, InPlayListFactoryResult>(maybe.value);
				}
			}
			Dictionary<RoleClassifications, int> chosen_roles_ratio = attempt_roles.Aggregate(new Dictionary<RoleClassifications, int>(), (Dictionary<RoleClassifications, int> _a, ChainMarker<Roles> _r) => _a.increaseOrCreate(_r.data.getClassificationFromRoleType(), 1));
			remaining_ratio = ratio.select((RoleClassifications _k, int _v) => _v - chosen_roles_ratio.getOrDefault(_k, 0));
		}
		if (wanted_transformations.Count > 0 && !transformRoles())
		{
			return new Either<string, InPlayListFactoryResult>("Failed to satisfy transformation constraint!");
		}
		if (!finalChecks())
		{
			return new Either<string, InPlayListFactoryResult>("Final checks (for in play list) failed!");
		}
		return new Either<string, InPlayListFactoryResult>(new InPlayListFactoryResult(attempt_roles.Select((ChainMarker<Roles> _m) => _m.data).ToList(), attempt_locations.Select((ChainMarker<LocationTypes> _m) => _m.data).ToList()));
	}

	private Maybe<string> fillInPlayList(Dictionary<RoleClassifications, List<Roles>> _suspects_by_class)
	{
		List<ChainMarker<Roles>> list = attempt_roles.copy();
		List<ChainMarker<LocationTypes>> list2 = attempt_locations.copy();
		List<ITransformationGenerationConstraint> list3 = wanted_transformations.copy();
		HashSet<Roles> hashSet = vetoed.copy();
		RoleClassifications nextClassificationToAdd = getNextClassificationToAdd(remaining_ratio);
		switch (add1(nextClassificationToAdd, _suspects_by_class, remaining_ratio[nextClassificationToAdd]))
		{
		case RoleAdditionResult.SUCCESS:
			attempt_roles.ForEach(delegate(ChainMarker<Roles> _ar)
			{
				_suspects_by_class[_ar.data.getClassificationFromRoleType()].Remove(_ar.data);
			});
			break;
		case RoleAdditionResult.ERROR:
			return $"Failed to add a {nextClassificationToAdd} in play!".maybe();
		case RoleAdditionResult.FAIL:
			attempt_roles = list;
			attempt_locations = list2;
			wanted_transformations = list3;
			vetoed = hashSet;
			break;
		}
		return new Maybe<string>();
	}

	private RoleClassifications getNextClassificationToAdd(Dictionary<RoleClassifications, int> _remaining_ratio)
	{
		if (_remaining_ratio[RoleClassifications.TRAITOR] > 0)
		{
			return RoleClassifications.TRAITOR;
		}
		if (_remaining_ratio[RoleClassifications.UNDERLING] > 0)
		{
			return RoleClassifications.UNDERLING;
		}
		if (_remaining_ratio[RoleClassifications.MEDDLER] > 0)
		{
			return RoleClassifications.MEDDLER;
		}
		return RoleClassifications.INNOCENT;
	}

	private RoleAdditionResult add1(RoleClassifications _class, Dictionary<RoleClassifications, List<Roles>> _suspects_by_class, int _roles_needed)
	{
		List<Roles> orCreate = _suspects_by_class.getOrCreate(_class, () => new List<Roles>());
		if (orCreate.Count < _roles_needed)
		{
			return RoleAdditionResult.ERROR;
		}
		Roles randomElementFromList = orCreate.getRandomElementFromList(random);
		orCreate.Remove(randomElementFromList);
		if (tryAddRole(role_getter(randomElementFromList), suspect_list))
		{
			return RoleAdditionResult.SUCCESS;
		}
		return RoleAdditionResult.FAIL;
	}

	public bool externalTryAddAnyOfRoles(List<Roles> _roles, ChainMarker<Roles> _from, List<Roles> _suspect_list, bool _forced, int _desired = 1)
	{
		_roles.shuffle(random);
		int num = 0;
		while (_roles.Count > 0 && num < _desired)
		{
			List<ChainMarker<LocationTypes>> list = attempt_locations.copy();
			List<ChainMarker<Roles>> list2 = attempt_roles.copy();
			List<ChainMarker<Roles>> added = _from.added.copy();
			HashSet<Roles> hashSet = vetoed.copy();
			if (externalTryAddRole(_roles[0], _from, _suspect_list, _forced))
			{
				num++;
			}
			else
			{
				attempt_locations = list;
				attempt_roles = list2;
				_from.added = added;
				vetoed = hashSet;
			}
			_roles.RemoveAt(0);
		}
		return num == _desired;
	}

	public bool externalTryAddRole(Roles _role, ChainMarker<Roles> _from, List<Roles> _suspect_list, bool _forced)
	{
		if (_from.existsFrom(_role) || attempt_roles.Any((ChainMarker<Roles> _m) => _m.data == _role))
		{
			return true;
		}
		if (remaining_ratio[_role.getClassificationFromRoleType()] - _from.fromClassCount(_role.getClassificationFromRoleType()) <= 0)
		{
			return false;
		}
		return tryAddRole(role_getter(_role), _from.maybe(), _suspect_list, _forced);
	}

	private bool tryAddRole(RoleData _role, List<Roles> _suspect_list, bool _forced = false)
	{
		return tryAddRole(_role, new Maybe<ChainMarker<Roles>>(), _suspect_list, _forced);
	}

	private bool tryAddForced(RoleData _role, List<Roles> _suspect_list)
	{
		if (remaining_ratio[_role.role.getClassificationFromRoleType()] <= 0)
		{
			List<ChainMarker<Roles>> list = attempt_roles.Where((ChainMarker<Roles> _r) => _r.data.getClassificationFromRoleType() == _role.role.getClassificationFromRoleType() && !_r.locked).ToList();
			if (list.Count == 0)
			{
				return false;
			}
			list.shuffle(random);
			Maybe<ChainMarker<Roles>> maybe = list.firstIfSome((ChainMarker<Roles> _m) => !_m.from.is_some || role_getter(_m.from.value.data).generation_constraint.canReplaceInPlayRole(_role, _m, _m.from.value.maybe(), this));
			if (!maybe.is_some)
			{
				return false;
			}
			attempt_roles.Remove(maybe.value);
			attempt_roles.removeRange(maybe.value.getAllAdded(new List<ChainMarker<Roles>>()));
		}
		return tryAddRole(_role, new Maybe<ChainMarker<Roles>>(), _suspect_list, _forced: true);
	}

	private bool tryAddRole(RoleData _role, Maybe<ChainMarker<Roles>> _from, List<Roles> _suspect_list, bool _forced)
	{
		RoleGenerationConstraints generationConstraints = _role.getGenerationConstraints();
		if (generationConstraints.isOfMarker(RoleGenerationMarkers.SELF_CONFIRM) && attempt_roles.Any((ChainMarker<Roles> _m) => role_getter(_m.data).generation_constraint.isOfMarker(RoleGenerationMarkers.SELF_CONFIRM)))
		{
			return false;
		}
		foreach (IClassificationGenerationConstraint item in generationConstraints.getConstraintOfInterface<IClassificationGenerationConstraint>())
		{
			if (!item.canBeInPlayWithRatio(ratio, forced_in_play, this))
			{
				return false;
			}
		}
		ChainMarker<Roles> chainMarker = new ChainMarker<Roles>(_role.role, _from, _forced);
		foreach (IInPlayListGenerationConstraint item2 in generationConstraints.getConstraintOfInterface<IInPlayListGenerationConstraint>())
		{
			if (!item2.tryAddRoleInPlay(chainMarker, _forced, _from, attempt_roles, _suspect_list, this))
			{
				return false;
			}
		}
		attempt_roles.Add(chainMarker);
		wanted_transformations.AddRange(generationConstraints.getConstraintOfInterface<ITransformationGenerationConstraint>());
		if (_from.is_some)
		{
			_from.value.addToChain(chainMarker);
		}
		return true;
	}

	public bool externalAddLocation(LocationTypes _location, ChainMarker<Roles> _from)
	{
		if (attempt_locations.Any((ChainMarker<LocationTypes> _m) => _m.data == _location))
		{
			return true;
		}
		if (location_spaces_available <= attempt_locations.Count)
		{
			return false;
		}
		attempt_locations.Add(new ChainMarker<LocationTypes>(_location, _from));
		return true;
	}

	public bool externalAddVetoe(List<Roles> _roles)
	{
		vetoed.addRange(_roles);
		return true;
	}

	private bool transformRoles()
	{
		List<ChainMarker<Roles>> can_transform = attempt_roles.Where((ChainMarker<Roles> _m) => !_m.locked).ToList();
		foreach (ITransformationGenerationConstraint wanted_transformation in wanted_transformations)
		{
			if (wanted_transformation.tryTransformation(can_transform, attempt_roles, random, this, out var _to_transform))
			{
				if (_to_transform.is_some)
				{
					attempt_roles.Remove(_to_transform.value.Item1);
					attempt_roles.Add(new ChainMarker<Roles>(_to_transform.value.Item2, _locked: true));
				}
				continue;
			}
			return false;
		}
		return true;
	}

	private bool finalChecks()
	{
		if (attempt_roles.Count != ratio.sumValues())
		{
			print_error("In play role count is different to summed ratio!");
			return false;
		}
		if (attempt_roles.Any((ChainMarker<Roles> _r) => attempt_roles.Any((ChainMarker<Roles> _r2) => _r != _r2 && _r.data == _r2.data)))
		{
			print_error("In play role list found duplicate!\n" + attempt_roles.Aggregate("", (string _a, ChainMarker<Roles> _m) => _a += $"{_m.data} | "));
			return false;
		}
		List<Roles> not_in_play = suspect_list.copy();
		attempt_roles.ForEach(delegate(ChainMarker<Roles> _m)
		{
			not_in_play.Remove(_m.data);
		});
		if (not_in_play.Count >= 2)
		{
			return true;
		}
		if (not_in_play.Count == 0)
		{
			return false;
		}
		return !role_getter(not_in_play[0]).generation_constraint.isOfMarker(RoleGenerationMarkers.CANT_BE_ONLY_NOT_IN_PLAY);
	}

	public RoleData getEmptyRole(Roles _role)
	{
		return role_getter(_role);
	}

	public List<Roles> getSuspectList()
	{
		return suspect_list;
	}

	public static List<ValidationError> validateInPlayList(CaseType _type, CaseSnapshot _snap, List<Roles> _in_play_list)
	{
		List<ValidationError> list = new List<ValidationError>();
		foreach (Roles item in _in_play_list)
		{
			RoleData roleData = item.createEmptyRole();
			foreach (IInPlayListGenerationConstraint item2 in roleData.generation_constraint.getConstraintOfInterface<IInPlayListGenerationConstraint>())
			{
				Maybe<ValidationError> maybe = item2.checkInPlayListForError(_type, item, _in_play_list, _snap);
				list.addIfSome(maybe);
			}
			foreach (ITransformationGenerationConstraint item3 in roleData.generation_constraint.getConstraintOfInterface<ITransformationGenerationConstraint>())
			{
				Maybe<ValidationError> maybe2 = item3.checkTransformationError(_type, item, _in_play_list, _snap);
				list.addIfSome(maybe2);
			}
		}
		return list;
	}
}
