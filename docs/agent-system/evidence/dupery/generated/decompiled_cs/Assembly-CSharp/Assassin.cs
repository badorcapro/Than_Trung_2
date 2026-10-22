using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Assassin : RoleData
{
	private List<int> killed = new List<int>();

	public override Roles role => Roles.ASSASSIN;

	public override string english_name => "Assassin";

	public override string english_description => "I " + Keywords.KILL.toString() + " every " + Keywords.ROLE.toString() + " you try to " + Keywords.ARREST.toString() + ". " + TextHelper.iLieAndPretendNotInPlay + ".";

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => killed.Count > 0;

	public Assassin(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			killed = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Problem loading role {role}! ({_save.unique_data}) Error: {arg}");
			killed = new List<int>();
		}
	}

	public Assassin(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	protected override bool getEnglishNamePrefixOption()
	{
		return false;
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return new DisguiseCharacteristics(DisguiseTarget.NOT_IN_PLAY, new List<RoleClassifications>
		{
			RoleClassifications.INNOCENT,
			RoleClassifications.MEDDLER
		}, new List<Roles>());
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		return "";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (base.tainted || ((base.dead || base.arrested) && !base.case_ref.hasMarkerQuirk(CaseQuirks.HAUNTED)))
		{
			return _board;
		}
		base.case_ref.killAddress(_arrested_address, this);
		killed.Add(_arrested_address);
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return killed.toStringCommaSeperated();
	}

	public override string getTruthString()
	{
		return ((killed.Count > 0) ? (TextHelper.killedManyLocalised(killed) + "\n") : "") + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return killed.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}
}
