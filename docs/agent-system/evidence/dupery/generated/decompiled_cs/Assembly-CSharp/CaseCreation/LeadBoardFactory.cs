using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Generic;
using GRGLib.Maybe;
using Leads;
using Quirks;
using UnityEngine;

namespace CaseCreation;

public class LeadBoardFactory
{
	protected const int board_stability_error_threshold = 99;

	protected System.Random random;

	protected CaseType case_type;

	protected Vector2Int board_size;

	protected CaseRatioBuilderData ratio_builder;

	protected float difficulty_01;

	protected Case case_ref;

	protected List<Roles> lead_roles;

	protected List<Clue> clues;

	protected RoleSetInfoStruct prime_suspects;

	public List<CaseQuirkData> active_quirks;

	public Dictionary<Roles, RoleData> empty_roles = new Dictionary<Roles, RoleData>();

	protected SuspectListFactory.SuspectListFactoryResult suspect_list_result;

	protected InPlayListFactory.InPlayListFactoryResult in_play_list_result;

	protected BoardPositioningFactory.BoardPositioningResult positioning_result;

	public HashSet<RoleData> suspect_list;

	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> board = new Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>>();

	public LocationTypes starting_location
	{
		get
		{
			if (case_type != CaseType.DOCKS)
			{
				return LocationTypes.CRIME_SCENE;
			}
			return LocationTypes.DOCKS;
		}
	}

	public Dictionary<RoleClassifications, int> ratio { get; protected set; } = new Dictionary<RoleClassifications, int>();

	public Dictionary<RoleClassifications, int> visual_ratio { get; protected set; } = new Dictionary<RoleClassifications, int>();

	public LeadBoardFactory(float _diff01, List<Roles> _available_roles, List<Clue> _clues, RoleSetInfoStruct _prime_suspects, Case _case, CaseRatioBuilderData _ratio_builder, System.Random _rng)
	{
		random = _rng;
		case_type = _case.case_type;
		board_size = _case.board_size;
		ratio_builder = _ratio_builder;
		difficulty_01 = _diff01;
		case_ref = _case;
		lead_roles = _available_roles;
		clues = _clues;
		prime_suspects = _prime_suspects;
		active_quirks = clues.whereSelect((Clue _c) => _c is QuirkClue, (Clue _c) => (_c as QuirkClue).quirk_in_focus.createQuirk());
		if (lead_roles.Count == 0)
		{
			lead_roles = new List<Roles>().addAll((Roles _r) => !_r.isTest() && !_r.isScrapped() && _r.isRoleOfCaseType(case_type));
		}
		createCase();
	}

	public LeadBoardFactory(Lead _lead, Case _case, CaseRatioBuilderData _ratio_builder, System.Random _rng)
		: this(_lead.case_difficulty, _lead.lead_roles, _lead.clues, _lead.prime_suspect_set, _case, _ratio_builder, _rng)
	{
	}

	private void createCase()
	{
		int num = 0;
		bool flag = false;
		while (!flag && num < 99)
		{
			num++;
			if (!checkError(createRatio()) && attemptLooped(createSuspectList, 5) && attemptLooped(createInPlayList, 5) && attemptLooped(positionRoles, 10) && !checkError(finaliseBoard()))
			{
				flag = true;
			}
		}
		if (!flag)
		{
			displayError($"Failed to create board in {99} attempts!", _print_extra_data: true);
		}
	}

	private Maybe<string> createRatio()
	{
		try
		{
			(List<Roles>, List<Roles>) tuple = clues.Aggregate((new List<Roles>(), new List<Roles>()), delegate((List<Roles>, List<Roles>) _a, Clue _c)
			{
				if (!(_c is RoleClue roleClue))
				{
					return _a;
				}
				if (roleClue.clue_type == ClueTypes.ROLE_IN_PLAY)
				{
					return (_a.Item1.add(roleClue.role_in_focus), _a.Item2);
				}
				return (roleClue.clue_type == ClueTypes.ROLE_SUSPECTED) ? (_a.Item1, _a.Item2.add(roleClue.role_in_focus)) : _a;
			});
			CaseRatioBuilderData ratio_data = updateRatioBuilderFromForcedRoles(tuple.Item2.addRange(prime_suspects.set_roles), tuple.Item1);
			ratio = CaseHelper.generateRatio(difficulty_01, ratio_data, random);
			return (ratio.sumValues() + 1 <= board_size.x * board_size.y) ? new Maybe<string>() : "Summed ratio is bigger than available board spaces!".maybe();
		}
		catch (Exception arg)
		{
			return $"Ratio creation failed due to error: {arg}".maybe();
		}
	}

	private CaseRatioBuilderData updateRatioBuilderFromForcedRoles(List<Roles> _forced_suspected, List<Roles> _forced_in_play)
	{
		CaseRatioBuilderData caseRatioBuilderData = new CaseRatioBuilderData(ratio_builder);
		caseRatioBuilderData.updateBuilderFromForcedRoles(_forced_in_play, _forced_suspected);
		HashSet<LocationTypes> hashSet = new HashSet<LocationTypes> { starting_location };
		foreach (Roles item in _forced_suspected)
		{
			caseRatioBuilderData = checkForcedRoleConstraintForRatio(getEmptyRoleData(item).generation_constraint, caseRatioBuilderData, _is_forced_ip: false, _forced_suspected, _forced_in_play, hashSet);
		}
		foreach (Roles item2 in _forced_in_play)
		{
			caseRatioBuilderData = checkForcedRoleConstraintForRatio(getEmptyRoleData(item2).generation_constraint, caseRatioBuilderData, _is_forced_ip: true, _forced_suspected, _forced_in_play, hashSet);
		}
		caseRatioBuilderData.address_size = new MinMaxInt(caseRatioBuilderData.address_size.min, caseRatioBuilderData.address_size.max - Mathf.Max(hashSet.Count, 1));
		if (caseRatioBuilderData.address_size.min > caseRatioBuilderData.address_size.max)
		{
			Debug.LogError($"The max ({caseRatioBuilderData.address_size.max}) number of addresses is smaller than the min ({caseRatioBuilderData.address_size.min}) number. This is concerning!");
			caseRatioBuilderData.address_size.min = caseRatioBuilderData.address_size.max;
		}
		return caseRatioBuilderData;
	}

	private CaseRatioBuilderData checkForcedRoleConstraintForRatio(RoleGenerationConstraints _constraint, CaseRatioBuilderData _builder, bool _is_forced_ip, List<Roles> _forced_suspected, List<Roles> _forced_in_play, HashSet<LocationTypes> _forced_locations)
	{
		List<IClassificationGenerationConstraint> constraintOfInterface = _constraint.getConstraintOfInterface<IClassificationGenerationConstraint>();
		if (constraintOfInterface.Count > 0)
		{
			_builder = constraintOfInterface.Aggregate(_builder, (CaseRatioBuilderData _a, IClassificationGenerationConstraint _c) => _c.updateBuilder(_a, _is_force_suspected: true, _is_forced_ip, _forced_suspected, _forced_in_play));
		}
		_constraint.getConstraintOfInterface<IAddLocationGenerationConstraint>().ForEach(delegate(IAddLocationGenerationConstraint _c)
		{
			Maybe<LocationTypes> forcedLocation = _c.getForcedLocation(_is_force_suspected: true, _is_forced_ip);
			if (forcedLocation.is_some && forcedLocation.value != starting_location)
			{
				_forced_locations.Add(forcedLocation.value);
			}
		});
		return _builder;
	}

	private Maybe<string> createSuspectList()
	{
		try
		{
			Either<string, SuspectListFactory.SuspectListFactoryResult> result = new SuspectListFactory(difficulty_01, ratio, board_size.x * board_size.y, prime_suspects.set_roles, clues, lead_roles, starting_location, active_quirks, getEmptyRoleData, random, displayError).result;
			if (result.is_a)
			{
				return result.maybe_a;
			}
			suspect_list_result = result.maybe_b.value;
			suspect_list = suspect_list_result.suspect_list.Select((Roles _r) => getEmptyRoleData(_r)).toHashSet();
			return new Maybe<string>();
		}
		catch (Exception arg)
		{
			return $"Suspect List Creation Failed due to error:\n{arg}".maybe();
		}
	}

	private Maybe<string> createInPlayList()
	{
		try
		{
			Either<string, InPlayListFactory.InPlayListFactoryResult> result = new InPlayListFactory(ratio, suspect_list_result, active_quirks, clues, difficulty_01, board_size.x * board_size.y, random, getEmptyRoleData, displayError).result;
			if (result.is_a)
			{
				return result.maybe_a;
			}
			in_play_list_result = result.maybe_b.value;
			return new Maybe<string>();
		}
		catch (Exception arg)
		{
			return $"In play List creation failed due to error:\n{arg}".maybe();
		}
	}

	private Maybe<string> positionRoles()
	{
		try
		{
			Either<string, BoardPositioningFactory.BoardPositioningResult> result = new BoardPositioningFactory(board_size, in_play_list_result.in_play_roles, in_play_list_result.in_play_locations, orderedQuirks((CaseQuirkData _q) => _q.is_board_placement_quirk), random, getEmptyRoleData, displayError).result;
			if (result.is_a)
			{
				return result.maybe_a;
			}
			positioning_result = result.maybe_b.value;
			return new Maybe<string>();
		}
		catch (Exception arg)
		{
			return $"Positioning roles failed due to error:\n{arg}".maybe();
		}
	}

	private Maybe<string> finaliseBoard()
	{
		try
		{
			board = positioning_result.board;
			List<RoleData> orderdRolesForEventCalls = board.getOrderdRolesForEventCalls();
			orderdRolesForEventCalls.ForEach(delegate(RoleData _r)
			{
				_r.onRoundCreated(case_ref);
			});
			Func<Func<CaseQuirkData, bool>, List<CaseQuirkData>> func = case_ref.setQuirkDataAndOrder(active_quirks);
			visual_ratio = ratio.copy();
			func((CaseQuirkData _q) => _q.is_visual_ratio_quirk).ForEach(delegate(CaseQuirkData _q)
			{
				visual_ratio = _q.onVisualRatioCreation(visual_ratio, ratio, random);
			});
			func((CaseQuirkData _q) => _q.is_case_start_quirk).ForEach(delegate(CaseQuirkData _q)
			{
				board = _q.onCaseStart(case_ref, board, random);
			});
			List<RoleData> suspects = suspect_list.ToList();
			for (int i = 0; i < orderdRolesForEventCalls.Count; i++)
			{
				Maybe<Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>>> maybe = orderdRolesForEventCalls[i].onSetDisguise(board, case_ref.getPayload(), suspects);
				if (!maybe.is_some)
				{
					throw new ArgumentException($"Failed to generate disguise for {orderdRolesForEventCalls[i].role}!");
				}
				board = maybe.value;
			}
			return new Maybe<string>();
		}
		catch (Exception arg)
		{
			return $"Failed to finalised board due to error:\n{arg}".maybe();
		}
	}

	private RoleData getEmptyRoleData(Roles _role)
	{
		return empty_roles.getOrCreate(_role, () => _role.createEmptyRole());
	}

	private List<CaseQuirkData> orderedQuirks(Func<CaseQuirkData, bool> _filter)
	{
		return (from _q in active_quirks.Where(_filter)
			orderby _q.execution_order
			select _q).ToList();
	}

	protected bool checkError(Maybe<string> _result)
	{
		if (!_result.is_some)
		{
			return false;
		}
		displayError(_result.value);
		return true;
	}

	protected void displayError(string _error)
	{
		displayError(_error, _print_extra_data: true);
	}

	protected void displayError(string _error, bool _print_extra_data)
	{
		if (!_print_extra_data)
		{
			Debug.LogError(_error);
			return;
		}
		Debug.LogError(_error + $"\nGeneric: {board_size.x}x{board_size.y} {case_type} case (with difficulty {difficulty_01})\n" + "Lead Roles: " + lead_roles.Aggregate("", (string _a, Roles _r) => _a += $"{_r} | ") + "\nPrime Suspects: " + prime_suspects.set_roles.Aggregate("", (string _a, Roles _r) => _a += $"{_r} | ") + "\nClues: " + clues.Aggregate("", (string _a, Clue _c) => _a = _a + $"{_c.clue_type}_" + ((_c is RoleClue { role_in_focus: var role_in_focus }) ? role_in_focus.ToString() : (_c as QuirkClue).quirk_in_focus.ToString()) + " | ") + "\nRatio:\n" + ((ratio == null) ? "null" : ratio.Aggregate("", (string _a, KeyValuePair<RoleClassifications, int> _r) => _a += $"   {_r.Key}: {_r.Value}\n")) + "\nSuspect List: " + ((suspect_list_result == null) ? "null" : suspect_list_result.suspect_list.Aggregate("", (string _a, Roles _r) => _a += $"{_r} | ")) + "\nIn play List: " + ((in_play_list_result == null) ? "null" : in_play_list_result.in_play_roles.Aggregate("", (string _a, Roles _r) => _a += $"{_r} | ")));
	}

	protected bool attemptLooped(Func<Maybe<string>> _try_section, int _max_attemps)
	{
		Maybe<string> maybe = new Maybe<string>();
		for (int i = 0; i < _max_attemps; i++)
		{
			maybe = _try_section();
			if (!maybe.is_some)
			{
				return true;
			}
		}
		displayError("Section failed. Final Error: " + maybe.value);
		return false;
	}
}
