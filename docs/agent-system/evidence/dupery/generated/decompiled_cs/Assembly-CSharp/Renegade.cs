using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Renegade : RoleData
{
	public override Roles role => Roles.RENEGADE;

	public override string english_name => "Renegade";

	public override string english_description => TextHelper.ipretendSuspected + ". If any of my " + Keywords.CA_NEIGHBOURS.toString() + " are " + Alignments.EVIL.toString() + ", I " + Keywords.LIE.toString() + ".";

	public override string credits => "Sequest";

	public override bool hasInfo => false;

	public Renegade(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Renegade(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override bool getEnglishNamePrefixOption()
	{
		return false;
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override bool isLiar()
	{
		return false;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (_board.getAdjacentRolesFromGridPos(base.board_position, base.case_ref.board_size).Any((RoleData _r) => _r.getVisualAlignment() == Alignments.EVIL))
		{
			base.lying = true;
		}
		else
		{
			base.lying = false;
		}
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
