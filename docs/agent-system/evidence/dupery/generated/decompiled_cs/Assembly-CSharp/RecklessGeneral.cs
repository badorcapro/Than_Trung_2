using System;
using System.Collections.Generic;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class RecklessGeneral : DocksRoleData
{
	public override Roles role => Roles.RECKLESS_GENERAL;

	public override string english_name => "Reckless General";

	public override string english_description => "While I am " + TextHelper.investigated + ", " + Keywords.ALIVE.toString() + " and " + Keywords.UNARRESTED.toString() + ", everytime you " + Keywords.INVESTIGATE.toString() + " or " + Keywords.ARREST.toString() + " a " + Keywords.ROLE.toString() + ", I might move the " + Keywords.BOAT.toString() + " in a random direction.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I have a 50% chance of moving the " + Keywords.BOAT.toString() + ". This movement consumes your " + Keywords.FUEL.toString() + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I never move the " + Keywords.BOAT.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public RecklessGeneral(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public RecklessGeneral(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onInvestigationAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _investigated_address)
	{
		if (_investigated_address == base.address)
		{
			return _board;
		}
		checkMoveBoat();
		return base.onInvestigationAction(_board, _payload, _investigated_address);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (_arrested_address == base.address)
		{
			return _board;
		}
		checkMoveBoat();
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	private void checkMoveBoat()
	{
		if (!base.has_bad_info && !base.arrested && !base.dead && base.investigated && random.Next(0, 2) != 1)
		{
			List<Vector2Int> cardinalNeighboursFromPositionWithinGrid = base.docks_case.boat.position.getCardinalNeighboursFromPositionWithinGrid(base.case_ref.board_size);
			base.docks_case.moveBoatExternally(cardinalNeighboursFromPositionWithinGrid.getRandomElementFromList(random));
		}
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
