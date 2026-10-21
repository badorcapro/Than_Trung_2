using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Mechanic : DocksRoleData
{
	private const int fuel_cost_reduction = 1;

	public override Roles role => Roles.MECHANIC;

	public override string english_name => "Mechanic";

	public override string english_description => $"Moving the {Keywords.BOAT.toString()} onto me costs {1} less fuel. Starts {TextHelper.investigated}.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, TextHelper.iAmSelfConfirm));
			list.Add((DescriptionType.SPECIAL, "I start " + TextHelper.investigated + " even when I am " + TextHelper.lying + " or " + TextHelper.tainted + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", the cost of moving the " + Keywords.BOAT.toString() + " onto me is not reduced."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public Mechanic(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Mechanic(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(default(RoleGenerationMarkers));
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		setInvestigatedOuter();
		base.docks_case.doBoatConstructorAction(delegate(DocksBoat _b)
		{
			_b.fuel_cost_changes.Add(changeFuelCost);
		});
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	private int changeFuelCost(DocksBoat _boat, Vector2Int _position)
	{
		if (_position != base.board_position || base.has_bad_info || base.dead || base.arrested)
		{
			return 0;
		}
		return -1;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
