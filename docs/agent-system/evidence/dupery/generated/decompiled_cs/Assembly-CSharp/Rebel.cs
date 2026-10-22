using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Rebel : BackAlleyRoleData
{
	private bool had_mischevious;

	public override Roles role => Roles.REBEL;

	public override string english_name => "Rebel";

	public override string english_description => TextHelper.ipretendNotInPlayInnocent + ". If you " + TextHelper.held + " at least 1 " + TextHelper.mischeviousItem + " when the case started, I also " + Keywords.LIE.toString() + ".";

	public override bool hasInfo => false;

	public Rebel(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Rebel(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			had_mischevious = _save.unique_data == "t";
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			had_mischevious = false;
		}
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getInnocentDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	public override string getUniqueSaveData()
	{
		if (!had_mischevious)
		{
			return "f";
		}
		return "t";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onDisguiseSet(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (_payload is BackAlleysCaseActionPayload backAlleysCaseActionPayload)
		{
			had_mischevious = backAlleysCaseActionPayload.pouch.filled_slots.Any((BackAlleySlot _i) => _i.item.value.colour == BackAlleysItemColour.MISCHEVIOUS);
			if (had_mischevious)
			{
				setLying(_new: true);
			}
			return _board;
		}
		Debug.LogError("Smugler is a Back Alley region unique role! Yet payload was not of the BackAlley type!");
		return base.onDisguiseSet(_board, _payload, _suspects);
	}

	public override string getTruthString()
	{
		if (!had_mischevious)
		{
			return base.getTruthString();
		}
		return checkTranslation(base.loc_default_truth_key, englishTruth) + "\n" + base.getTruthString();
	}

	private string englishTruth()
	{
		return "You had a Mischevious Item so I lied.";
	}
}
