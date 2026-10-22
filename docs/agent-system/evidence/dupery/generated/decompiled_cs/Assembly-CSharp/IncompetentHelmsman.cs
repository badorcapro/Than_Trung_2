using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class IncompetentHelmsman : DocksRoleData
{
	public const int cost_increase = 1;

	public override Roles role => Roles.INCOMPETENT_HELMSMAN;

	public override string english_name => "Incompetent Helmsman";

	public override string english_description => $"While I am {Keywords.ALIVE.toString()} and {Keywords.UNARRESTED.toString()}, moving the {Keywords.BOAT.toString()} costs {1} additional {Keywords.FUEL.toString()}.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, $"Any movement done by the {Keywords.BOAT.toString()}, regardless of how many {Keywords.STEPS.toString()} were travelled, will cost {1} addtional {Keywords.FUEL.toString()}."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I do not increase the " + Keywords.FUEL.toString() + " cost of moving the " + Keywords.BOAT.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public IncompetentHelmsman(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public IncompetentHelmsman(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		base.docks_case.doBoatConstructorAction(delegate(DocksBoat _b)
		{
			_b.fuel_cost_changes.Add((DocksBoat _b, Vector2Int _p) => (!base.has_bad_info && !base.arrested && !base.dead) ? 1 : 0);
		});
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		base.docks_case.doBoatConstructorAction(delegate(DocksBoat _b)
		{
			_b.fuel_cost_changes.Add((DocksBoat _b, Vector2Int _p) => (!base.has_bad_info && !base.arrested && !base.dead) ? 1 : 0);
		});
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
