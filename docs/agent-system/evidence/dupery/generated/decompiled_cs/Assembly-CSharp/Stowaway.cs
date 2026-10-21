using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Stowaway : DocksRoleData
{
	private Maybe<RoleData> previous_disguise = new Maybe<RoleData>();

	public override Roles role => Roles.STOWAWAY;

	public override string english_name => "Stowaway";

	public override string english_description => TextHelper.ipretendNotInPlayInnocent + ". When the " + Keywords.BOAT.toString() + " is not on the " + LocationTypes.DOCKS.toString() + ", I " + Keywords.REVEAL.toString() + " myself.";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.SPECIAL, TextHelper.iUpdateWhenBoatMoves) };

	public override bool hasInfo => false;

	public Stowaway(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Stowaway(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			if (_save.unique_data == "f")
			{
				previous_disguise = new Maybe<RoleData>();
				return;
			}
			previous_disguise = _from_save(JsonUtility.FromJson<RoleDataSave>(_save.unique_data)).maybe();
			if (previous_disguise.value == null)
			{
				Debug.LogError("WTF?");
			}
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			previous_disguise = new Maybe<RoleData>();
		}
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getInnocentDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		base.docks_case.doBoatConstructorAction(delegate(DocksBoat _b)
		{
			if (!(_b.position == _board.getLocationsInPlay()[LocationTypes.DOCKS].getBoardPosition()) && disguise.is_some)
			{
				previous_disguise = disguise.value.maybe();
				setDisguise(new Maybe<RoleData>());
			}
		});
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		if (_new_pos != _board.getLocationsInPlay()[LocationTypes.DOCKS].getBoardPosition())
		{
			if (disguise.is_some)
			{
				previous_disguise = disguise.value.maybe();
				setDisguise(new Maybe<RoleData>());
			}
		}
		else if (!disguise.is_some)
		{
			if (!previous_disguise.is_some)
			{
				Debug.LogError("Lazy officer bug! No previous disguise to go back to!");
			}
			setDisguise(previous_disguise);
		}
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	public override string getUniqueSaveData()
	{
		if (!previous_disguise.is_some)
		{
			return "f";
		}
		return JsonUtility.ToJson(previous_disguise.value.toDataSave());
	}
}
