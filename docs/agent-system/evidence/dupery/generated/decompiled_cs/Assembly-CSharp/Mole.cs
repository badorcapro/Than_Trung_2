using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Mole : RoleData
{
	private List<int> killed = new List<int>();

	public override Roles role => Roles.MOLE;

	public override string english_name => "Mole";

	public override string english_description => "I am " + Keywords.SURROUNDING.toString() + " the " + LocationTypes.CRIME_SCENE.toString() + ". While I am " + Keywords.UNINVESTIGATED.toString() + ", " + TextHelper.aliveAndNotArrested + ", I might " + Keywords.KILL.toString() + " any " + TextHelper.goodRole + " you " + Keywords.INVESTIGATE.toString() + ". " + TextHelper.iLieAndPretendSuspected + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I have a 50% chance to " + Keywords.KILL.toString() + " each time you " + Keywords.INVESTIGATE.toString() + " a " + TextHelper.goodRole + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => killed.Count > 0;

	public Mole(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Mole(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			killed = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Could not load {role}!\nSave: {_save.unique_data}\nError: {arg}");
			killed = new List<int>();
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new PositionLocationGC(LocationTypes.CRIME_SCENE, GCPosition.SURROUNDING, DisguiseConstraintType.IGNORE_WHEN_LYING));
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

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onInvestigationAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _investigated_address)
	{
		if (base.tainted || base.dead || base.arrested || base.investigated)
		{
			return _board;
		}
		RoleData roleData = _board.getRolesInPlay()[_investigated_address];
		if (roleData.getVisualAlignment() != 0 || random.Next(0, 2) == 1)
		{
			return _board;
		}
		base.case_ref.killAddress(roleData.getAddress(), this);
		killed.Add(roleData.getAddress());
		return base.onInvestigationAction(_board, _payload, _investigated_address);
	}

	public override string getUniqueSaveData()
	{
		return killed.toStringCommaSeperated();
	}
}
