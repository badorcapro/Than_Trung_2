using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Leads;
using UnityEngine;

namespace Quirks;

public class FaultyGauge : CaseQuirkData
{
	private const int max_offset = 2;

	public override CaseQuirks quirk_type => CaseQuirks.FAULTY_GAUGE;

	protected override string english_name => "Faulty Gauge";

	protected override string english_description => $"Your {Keywords.FUEL.toString()} gauge is offset by a value between -{2} and +{2}.";

	public override bool is_case_start_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.DOCKS;
	}

	public override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseStart(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		if (!(_case is DocksCase docksCase))
		{
			Debug.LogError($"{quirk_type} is a docks quirk but has been found in a {_case.case_type} case!");
			return _board;
		}
		docksCase.doBoatConstructorAction(delegate(DocksBoat _b)
		{
			_b.fuel_offset = (_rng.Next(1, 3) * ((_rng.Next(0, 2) == 1) ? 1 : (-1))).maybe();
		});
		return _board;
	}

	public override List<Roles> filterRoleForClues(List<Roles> _roles, ClueTypes _type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (_type == ClueTypes.ROLE_NOT_IN_PLAY)
		{
			return _roles;
		}
		_roles.Remove(Roles.VANDAL);
		return _roles;
	}

	public override bool isValidForClue(List<CaseQuirks> _quirks, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (_forced.getOrCreate(ClueTypes.ROLE_IN_PLAY, () => new List<Roles>()).Contains(Roles.VANDAL))
		{
			return false;
		}
		if (_forced.getOrCreate(ClueTypes.ROLE_SUSPECTED, () => new List<Roles>()).Contains(Roles.VANDAL))
		{
			return false;
		}
		return true;
	}
}
