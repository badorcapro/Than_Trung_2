using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Bomber : RoleData
{
	public override Roles role => Roles.BOMBER;

	public override string english_name => "Bomber";

	public override string english_description => "Adds 2 " + LocationTypes.BOMB_THREAT.toString() + " to the " + Keywords.BOARD.toString() + ". One of these is a " + LocationTypes.BOMB.toString() + ". When I am " + TextHelper.arrested + ", unless I am the last " + Alignments.EVIL.toString() + ", the " + LocationTypes.BOMB.toString() + " detonates " + TextHelper.killing + " any " + Keywords.CARDINALLY_ADJACENT.toString() + " " + TextHelper.roles + ". I am never next to the " + LocationTypes.BOMB.toString() + ".\n" + TextHelper.iLieAndPretendNotInPlay + ".";

	public override bool hasInfo => false;

	public Bomber(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public Bomber(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return new DisguiseCharacteristics(DisguiseTarget.NOT_IN_PLAY, new List<RoleClassifications>
		{
			RoleClassifications.INNOCENT,
			RoleClassifications.MEDDLER
		}, new List<Roles>());
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.EVIL;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.TRAITOR;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		Queue<Vector2Int> queue = _board.getEmptySpaces().toQueue();
		if (queue.Count == 0)
		{
			Debug.LogError("No space for the bomb on the board!");
			return _board;
		}
		queue = queue.shuffle(random);
		Vector2Int vector2Int = queue.Dequeue();
		_board[vector2Int] = LocationTypes.BOMB.createLocation(vector2Int, random).toEitherB<RoleData, LocationData>().maybe();
		if (queue.Count != 0)
		{
			Vector2Int vector2Int2 = queue.Dequeue();
			_board[vector2Int2] = LocationTypes.BOMB_THREAT.createLocation(vector2Int2, random).toEitherB<RoleData, LocationData>().maybe();
		}
		else
		{
			Debug.LogError("There is no space on the board for the bomb threat!");
		}
		if (vector2Int.cardinalDistance(base.board_position) > 1)
		{
			return _board;
		}
		while (queue.Count > 0)
		{
			Vector2Int vector2Int3 = queue.Dequeue();
			if (vector2Int3.cardinalDistance(vector2Int) > 1)
			{
				Vector2Int key = base.board_position;
				_board[key] = new Maybe<Either<RoleData, LocationData>>();
				base.board_position = vector2Int3;
				_board = _board.registerRoleChange(vector2Int3, this);
				return _board.recalculateAddresses();
			}
		}
		List<RoleData> list = _board.getRolesInPlay().Values.toListSafe();
		list.shuffle(random);
		foreach (RoleData item in list)
		{
			Vector2Int boardPosition = item.getBoardPosition();
			if (boardPosition.cardinalDistance(vector2Int) > 1)
			{
				Vector2Int vector2Int4 = base.board_position;
				item.setBoardPosition(vector2Int4);
				_board = _board.registerRoleChange(vector2Int4, item);
				base.board_position = boardPosition;
				_board = _board.registerRoleChange(boardPosition, this);
				return _board.recalculateAddresses();
			}
		}
		Debug.LogError("Bomber beside bomb but can't move???");
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (_arrested_address != base.address)
		{
			return _board;
		}
		if (base.tainted || _board.getAllNotArrestedOrDeadEvil().Count <= 0)
		{
			return _board;
		}
		Dictionary<LocationTypes, LocationData> locationsInPlay = _board.getLocationsInPlay();
		if (!locationsInPlay.ContainsKey(LocationTypes.BOMB))
		{
			return _board;
		}
		foreach (RoleData adjacentRolesFromGridPo in _board.getAdjacentRolesFromGridPos(locationsInPlay[LocationTypes.BOMB].getBoardPosition(), base.case_ref.board_size))
		{
			_board = base.case_ref.killAddress(adjacentRolesFromGridPo.getAddress(), new Maybe<RoleData>()).board;
		}
		(locationsInPlay[LocationTypes.BOMB] as Bomb).explode();
		Debug.Log("BOOOOOMMMMM....?");
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
