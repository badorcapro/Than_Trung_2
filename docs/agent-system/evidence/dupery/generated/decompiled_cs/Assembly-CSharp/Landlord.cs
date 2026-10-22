using System;
using System.Collections.Generic;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Landlord : RoleData
{
	private int target_address = -1;

	public override Roles role => Roles.LANDLORD;

	public override string english_name => "Landlord";

	public override string english_description => "I pick a " + TextHelper.surroundingNeighbour + ". While I am " + TextHelper.aliveAndNotArrested + ", you cannot " + Keywords.INVESTIGATE.toString() + " them.\n" + TextHelper.iLieAndPretendSuspected + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", I do not stop you from " + TextHelper.investigating + " any of my " + TextHelper.surroundingNeighbours));
			return list;
		}
	}

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => target_address != -1;

	public Landlord(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Landlord(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		target_address = int.Parse(_save.unique_data);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.INVESTIGATION_BLOCKER);
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getTruthString()
	{
		return ((target_address == -1) ? "" : (TextHelper.blockedOneLocalised(target_address) + "\n")) + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == target_address;
		}
		return false;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted)
		{
			return _board;
		}
		List<RoleData> surroundingRolesFromGridPos = _board.getSurroundingRolesFromGridPos(base.board_position, base.case_ref.board_size);
		if (surroundingRolesFromGridPos.Count == 0)
		{
			return _board;
		}
		RoleData randomElementFromList = surroundingRolesFromGridPos.getRandomElementFromList(random);
		target_address = randomElementFromList.getAddress();
		randomElementFromList.setCanBeInvestigated($"#R_{role}", _true: false, _uninvestigate: true);
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (_arrested_address != base.address)
		{
			return _board;
		}
		setTargetInvestigationPossible(_board);
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onKillAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _murdered_address, Maybe<RoleData> _killer)
	{
		if (_murdered_address != base.address)
		{
			return _board;
		}
		setTargetInvestigationPossible(_board);
		return base.onKillAction(_board, _payload, _murdered_address, _killer);
	}

	private void setTargetInvestigationPossible(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		if (target_address != -1)
		{
			_board.getRolesInPlay()[target_address].setCanBeInvestigated($"#R_{role}", _true: true);
		}
	}

	public override string getUniqueSaveData()
	{
		return target_address.ToString();
	}
}
