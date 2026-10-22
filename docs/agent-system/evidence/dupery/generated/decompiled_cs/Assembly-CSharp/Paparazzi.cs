using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Paparazzi : CasinoRoleData
{
	private bool trigerred;

	public override Roles role => Roles.PAPARAZZI;

	public override string english_name => "Paparazzi";

	public override string english_description => "If your first " + Keywords.ARREST.toString() + " is a " + TextHelper.goodRole + ", I bankrupt you. " + TextHelper.iLieAndPretendNotInPlay + ".";

	public override string credits => "gv";

	public override bool hasInfo => false;

	public Paparazzi(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			trigerred = _save.unique_data == "t";
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}!\nData: {_save.unique_data}\nError: {arg}");
			trigerred = false;
		}
	}

	public Paparazzi(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (trigerred || base.tainted || (!base.case_ref.hasMarkerQuirk(CaseQuirks.HAUNTED) && (base.dead || base.arrested)))
		{
			return _board;
		}
		trigerred = true;
		RoleData roleData = _board.getRolesInPlay()[_arrested_address];
		if (roleData.getVisualAlignment() == Alignments.EVIL)
		{
			return _board;
		}
		if (roleData.getTrueAlignment() == Alignments.EVIL)
		{
			return _board;
		}
		base.casino_case.spendChips(base.casino_case.chips);
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	public override string getUniqueSaveData()
	{
		if (!trigerred)
		{
			return "f";
		}
		return "t";
	}
}
