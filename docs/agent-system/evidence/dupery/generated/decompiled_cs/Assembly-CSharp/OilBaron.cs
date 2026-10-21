using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class OilBaron : DocksRoleData
{
	private const int fuel_per_kill = 4;

	private int fuel_since_last_kill;

	private List<int> killed = new List<int>();

	public override Roles role => Roles.OIL_BARON;

	public override string english_name => "Oil Baron";

	public override string english_description => $"I {Keywords.KILL.toString()} a {Keywords.ROLE.toString()} for every {4} {Keywords.FUEL.toString()} used. {TextHelper.iLieAndPretendNotInPlay}.";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)>();

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => killed.Count > 0;

	public OilBaron(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public OilBaron(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split('#');
			fuel_since_last_kill = int.Parse(array[0]);
			killed = array[1].fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			fuel_since_last_kill = 0;
			killed = new List<int>();
		}
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onFuelUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, int _fuel_used)
	{
		if (base.tainted || (!base.case_ref.hasMarkerQuirk(CaseQuirks.HAUNTED) && (base.dead || base.arrested)))
		{
			return _board;
		}
		fuel_since_last_kill += _fuel_used;
		Debug.Log(fuel_since_last_kill);
		if (fuel_since_last_kill < 4)
		{
			return _board;
		}
		List<(RoleData, int)> list = (from _r in _board.getRolesInPlay().Values
			where !_r.getIsDead()
			select (_r: _r, getKillOddFromClassification(_r.role.getClassificationFromRoleType()))).ToList();
		if (list.Count == 0)
		{
			return _board;
		}
		list.weightedChooseMany(Mathf.Min(fuel_since_last_kill / 4, list.Count), random).value.ForEach(delegate(RoleData _t)
		{
			base.case_ref.killAddress(_t.getAddress(), this);
			killed.Add(_t.getAddress());
		});
		fuel_since_last_kill %= 4;
		return base.onFuelUsedAction(_board, _payload, _fuel_used);
	}

	private int getKillOddFromClassification(RoleClassifications _class)
	{
		return _class switch
		{
			RoleClassifications.INNOCENT => 30, 
			RoleClassifications.MEDDLER => 30, 
			RoleClassifications.UNDERLING => 10, 
			RoleClassifications.TRAITOR => 1, 
			_ => 0, 
		};
	}

	public override string getTruthString()
	{
		return ((killed.Count == 0) ? "" : (TextHelper.killedManyLocalised(killed) + "\n")) + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return killed.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return $"{fuel_since_last_kill}#{killed.toStringCommaSeperated()}";
	}
}
