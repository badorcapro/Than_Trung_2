using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Quirks;
using UnityEngine;

namespace CaseCreation;

public class BoardPositioningFactory
{
	public class BoardPositioningResult
	{
		public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> board;

		public BoardPositioningResult(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
		{
			board = _board;
		}
	}

	protected Action<string> print_error;

	protected Func<Roles, RoleData> role_getter;

	protected List<Roles> in_play_list;

	protected List<LocationTypes> in_play_locations;

	protected List<CaseQuirkData> ordered_board_placement_quirks;

	protected List<Vector2Int> board_positions;

	protected List<Vector2Int> available_positions;

	protected List<BoardMarker<Roles>> positioned_roles;

	protected List<BoardMarker<LocationTypes>> positioned_locations;

	private Dictionary<Roles, List<IPositioningGenerationConstraint>> positional_constraints = new Dictionary<Roles, List<IPositioningGenerationConstraint>>();

	public Either<string, BoardPositioningResult> result = new Either<string, BoardPositioningResult>("NOT BUILT");

	public System.Random random { get; private set; }

	public Vector2Int board_size { get; protected set; }

	public List<BoardMarker<Roles>> roles_to_position { get; protected set; }

	public List<BoardMarker<LocationTypes>> locations_to_position { get; protected set; }

	public BoardPositioningFactory(Vector2Int _board_size, List<Roles> _in_play, List<LocationTypes> _locations, List<CaseQuirkData> _ordered_pos_quirks, System.Random _rng, Func<Roles, RoleData> _getter, Action<string> _error)
	{
		random = _rng;
		print_error = _error;
		role_getter = _getter;
		board_size = _board_size;
		in_play_list = _in_play;
		in_play_locations = _locations;
		ordered_board_placement_quirks = _ordered_pos_quirks;
		positioned_roles = new List<BoardMarker<Roles>>();
		positioned_locations = new List<BoardMarker<LocationTypes>>();
		roles_to_position = new List<BoardMarker<Roles>>();
		locations_to_position = new List<BoardMarker<LocationTypes>>();
		result = positionRoles();
	}

	private Either<string, BoardPositioningResult> positionRoles()
	{
		board_positions = new List<Vector2Int>();
		for (int i = 0; i < board_size.x; i++)
		{
			for (int j = 0; j < board_size.y; j++)
			{
				board_positions.Add(new Vector2Int(i, j));
			}
		}
		positional_constraints = in_play_list.Aggregate(new Dictionary<Roles, List<IPositioningGenerationConstraint>>(), (Dictionary<Roles, List<IPositioningGenerationConstraint>> _a, Roles _r) => _a.addTo(_r, role_getter(_r).generation_constraint.getConstraintOfInterface<IPositioningGenerationConstraint>()));
		foreach (CaseQuirkData ordered_board_placement_quirk in ordered_board_placement_quirks)
		{
			positional_constraints = ordered_board_placement_quirk.onBoardPlacement(positional_constraints, in_play_list, random);
		}
		foreach (Roles item in in_play_list)
		{
			List<IAddPositionalGenerationConstraint> constraintOfInterface = role_getter(item).generation_constraint.getConstraintOfInterface<IAddPositionalGenerationConstraint>();
			if (constraintOfInterface.Count > 0)
			{
				positional_constraints = constraintOfInterface.Aggregate(positional_constraints, (Dictionary<Roles, List<IPositioningGenerationConstraint>> _a, IAddPositionalGenerationConstraint _c) => _c.addConstraints(_a, in_play_list, random));
			}
		}
		List<Roles> roles_to_add = in_play_list.copy();
		roles_to_add.shuffle(random);
		roles_to_add.OrderByDescending((Roles _r) => positional_constraints[_r].Aggregate(GenerationConstraintPriority.NONE, (GenerationConstraintPriority _a, IPositioningGenerationConstraint _pc) => (GenerationConstraintPriority)Mathf.Max((int)_a, (int)_pc.position_priority)));
		available_positions = board_positions.copy();
		while (roles_to_add.Count > 0)
		{
			if (!tryPositionRole(roles_to_add[0], available_positions))
			{
				return new Either<string, BoardPositioningResult>($"Failed to position {roles_to_add[0]}!");
			}
			available_positions = board_positions.copy();
			positioned_roles.ForEach(delegate(BoardMarker<Roles> _m)
			{
				roles_to_add.Remove(_m.data);
				available_positions.Remove(_m.position);
			});
			positioned_locations.ForEach(delegate(BoardMarker<LocationTypes> _m)
			{
				available_positions.Remove(_m.position);
			});
		}
		available_positions.shuffle(random);
		foreach (LocationTypes location in in_play_locations)
		{
			if (!positioned_locations.Any((BoardMarker<LocationTypes> _l) => _l.data == location))
			{
				Vector2Int pos = available_positions[0];
				available_positions.RemoveAt(0);
				positioned_locations.Add(new BoardMarker<LocationTypes>(location, pos, _locked: false));
			}
		}
		Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> emptyBoard = CaseHelper.getEmptyBoard(board_size);
		positioned_roles = positioned_roles.OrderBy((BoardMarker<Roles> _p) => _p.position.x + _p.position.y * 1000).ToList();
		for (int k = 0; k < positioned_roles.Count; k++)
		{
			if (emptyBoard[positioned_roles[k].position].is_some)
			{
				return new Either<string, BoardPositioningResult>($"{positioned_roles[k].data} wants to be positioned at {positioned_roles[k].position} but space is not empty!");
			}
			emptyBoard[positioned_roles[k].position] = positioned_roles[k].data.createRole(k + 1, positioned_roles[k].position, random, new Maybe<RoleData>()).toEitherA<RoleData, LocationData>().maybe();
		}
		foreach (BoardMarker<LocationTypes> positioned_location in positioned_locations)
		{
			if (emptyBoard[positioned_location.position].is_some)
			{
				return new Either<string, BoardPositioningResult>($"{positioned_location.data} wants to be positioned at {positioned_location.position} but space is not empty!");
			}
			emptyBoard[positioned_location.position] = positioned_location.data.createLocation(positioned_location.position, random).toEitherB<RoleData, LocationData>().maybe();
		}
		return new Either<string, BoardPositioningResult>(new BoardPositioningResult(emptyBoard));
	}

	public bool externalPositionAnyRole(List<Roles> _roles, List<Vector2Int> _pos, List<BoardMarker<Roles>> _from, int _desired = 1)
	{
		_roles.shuffle(random);
		int num = 0;
		while (_roles.Count > 0 && num < _desired)
		{
			List<BoardMarker<LocationTypes>> list = locations_to_position.copy();
			List<BoardMarker<Roles>> list2 = roles_to_position.copy();
			if (externalPositionRole(_roles[0], _pos, _from, _lock: false))
			{
				num++;
			}
			else
			{
				locations_to_position = list;
				roles_to_position = list2;
			}
			_roles.RemoveAt(0);
		}
		return num == _desired;
	}

	public bool externalPositionRole(Roles _role, List<Vector2Int> _pos, List<BoardMarker<Roles>> _from, bool _lock)
	{
		if (_from.Any((BoardMarker<Roles> _m) => _m.data == _role) || roles_to_position.Any((BoardMarker<Roles> _m) => _m.data == _role) || positioned_roles.Any((BoardMarker<Roles> _m) => _m.data == _role))
		{
			return false;
		}
		List<Vector2Int> list = _pos.Where((Vector2Int _p) => available_positions.Contains(_p) && !_from.Any((BoardMarker<Roles> _f) => _f.position == _p) && !roles_to_position.Any((BoardMarker<Roles> _rp) => _rp.position == _p)).ToList();
		if (list.Count == 0)
		{
			return false;
		}
		return tryPositionRole(_role, list, _from, _lock, _is_source: false);
	}

	private bool tryPositionRole(Roles _role, List<Vector2Int> _pos, bool _lock = false)
	{
		return tryPositionRole(_role, _pos, new List<BoardMarker<Roles>>(), _lock, _is_source: true);
	}

	private bool tryPositionRole(Roles _role, List<Vector2Int> _pos, List<BoardMarker<Roles>> _from, bool _lock, bool _is_source)
	{
		List<IPositioningGenerationConstraint> list = positional_constraints[_role];
		List<Vector2Int> list2 = _pos.copy();
		foreach (IPositioningGenerationConstraint item in list)
		{
			list2 = item.filterAvailablePositions(_role, list2, _from, positioned_roles, positioned_locations, this);
			if (list2.Count == 0)
			{
				return false;
			}
		}
		list2.shuffle(random);
		bool flag = false;
		BoardMarker<Roles> self = new BoardMarker<Roles>(_role, new Vector2Int(-1, -1), _lock);
		for (int i = 0; i < list2.Count; i++)
		{
			if (flag)
			{
				break;
			}
			flag = true;
			self = new BoardMarker<Roles>(_role, list2[i], _lock);
			List<BoardMarker<Roles>> from = _from.copy().add(self);
			if (_is_source)
			{
				roles_to_position.Clear();
				locations_to_position.Clear();
			}
			for (int j = 0; j < list.Count && flag; j++)
			{
				flag = list[j].tryPositionOther(_role, self.position, from, positioned_roles, positioned_locations, in_play_list, this);
			}
		}
		if (!flag)
		{
			return false;
		}
		if (_is_source)
		{
			positioned_roles.AddRange(roles_to_position);
			if (positioned_roles.Any((BoardMarker<Roles> _m) => _m.position == self.position))
			{
				Debug.LogError($"WHY? {_role} | {roles_to_position.Any((BoardMarker<Roles> _m) => _m.position == self.position)}");
			}
			positioned_roles.Add(self);
			roles_to_position.Clear();
			positioned_locations.AddRange(locations_to_position);
			locations_to_position.Clear();
		}
		else
		{
			roles_to_position.Add(self);
			available_positions.Remove(self.position);
		}
		return true;
	}

	public bool externalPositionLocation(LocationTypes _location, List<Vector2Int> _pos, List<BoardMarker<Roles>> _from, bool _lock)
	{
		List<Vector2Int> list = _pos.Where((Vector2Int _p) => available_positions.Contains(_p) && !_from.Any((BoardMarker<Roles> _m) => _m.position == _p)).ToList();
		if (list.Count == 0)
		{
			return false;
		}
		Vector2Int randomElementFromList = list.getRandomElementFromList(random);
		locations_to_position.Add(new BoardMarker<LocationTypes>(_location, randomElementFromList, _lock));
		available_positions.Remove(randomElementFromList);
		return true;
	}

	public Maybe<BoardMarker<Roles>> getLatestRoleToPosition()
	{
		if (roles_to_position.Count != 0)
		{
			return roles_to_position.last().maybe();
		}
		return new Maybe<BoardMarker<Roles>>();
	}

	public Maybe<BoardMarker<Roles>> firstMatch(List<BoardMarker<Roles>> _from, Func<BoardMarker<Roles>, bool> _condition)
	{
		Maybe<BoardMarker<Roles>> maybe = positioned_roles.firstIfSome((BoardMarker<Roles> _m) => _condition(_m));
		if (maybe.is_some)
		{
			return maybe;
		}
		maybe = _from.firstIfSome((BoardMarker<Roles> _m) => _condition(_m));
		if (maybe.is_some)
		{
			return maybe;
		}
		return roles_to_position.firstIfSome((BoardMarker<Roles> _m) => _condition(_m));
	}

	public bool hasSomethingAtPosition(List<BoardMarker<Roles>> _from, Vector2Int _position)
	{
		if (!positioned_roles.Any((BoardMarker<Roles> _m) => _m.position == _position) && !_from.Any((BoardMarker<Roles> _m) => _m.position == _position) && !roles_to_position.Any((BoardMarker<Roles> _m) => _m.position == _position) && !positioned_locations.Any((BoardMarker<LocationTypes> _m) => _m.position == _position))
		{
			return locations_to_position.Any((BoardMarker<LocationTypes> _m) => _m.position == _position);
		}
		return true;
	}

	public RoleClassifications getVisualClass(Roles _role)
	{
		return role_getter(_role).getVisualClassification();
	}

	public static List<ValidationError> validateBoard(CaseType _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseSnapshot _snap, Vector2Int _board_size)
	{
		List<ValidationError> list = new List<ValidationError>();
		Dictionary<int, RoleData> rolesInPlay = _board.getRolesInPlay();
		Dictionary<LocationTypes, LocationData> locationsInPlay = _board.getLocationsInPlay();
		if (_case == CaseType.DOCKS)
		{
			if (!locationsInPlay.ContainsKey(LocationTypes.DOCKS))
			{
				list.Add(new RequirementEEB(LocationTypes.DOCKS).createValidationError());
			}
		}
		else if (!locationsInPlay.ContainsKey(LocationTypes.CRIME_SCENE))
		{
			list.Add(new RequirementEEB(LocationTypes.CRIME_SCENE).createValidationError());
		}
		foreach (KeyValuePair<int, RoleData> item in rolesInPlay)
		{
			foreach (IPositioningGenerationConstraint item2 in item.Value.generation_constraint.getConstraintOfInterface<IPositioningGenerationConstraint>())
			{
				Maybe<ValidationError> maybe = item2.checkPositioningError(_case, item.Value, _board, _snap, _board_size);
				list.addIfSome(maybe);
			}
		}
		return list;
	}
}
