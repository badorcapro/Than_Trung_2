using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Smugler : BackAlleyRoleData
{
	private int tainted_target = -1;

	public override Roles role => Roles.SMUGLER;

	public override string english_name => "Smugler";

	public override string english_description => "I " + Keywords.TAINT.toString() + " the furthest " + TextHelper.innocentRole + " from me. " + TextHelper.iLieAndPretendSuspected + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I can only be " + Keywords.SUSPECTED.toString() + " if you " + TextHelper.held + " both a " + BackAlleysItemColour.ILLEGAL.toString() + " and " + BackAlleysItemColour.BLACKMARKET.toString() + " " + Keywords.ITEM.toString() + " when you started the case."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public Smugler(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Smugler(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			tainted_target = int.Parse(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			tainted_target = -1;
		}
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override string getUniqueSaveData()
	{
		return tainted_target.ToString();
	}

	public override string getTruthString()
	{
		if (tainted_target != -1)
		{
			return checkTranslationWithData(base.loc_default_truth_key, englishTruth, tainted_target) + "\n" + base.getTruthString();
		}
		return base.getTruthString();
	}

	private string englishTruth(string _data)
	{
		return "I tainted #" + _data + ".";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted || base.dead || base.arrested)
		{
			return _board;
		}
		RoleData randomElementFromList = _board.getRolesInPlayOfClass(default(RoleClassifications)).Aggregate((0, new List<RoleData>()), delegate((int, List<RoleData>) _a, RoleData _r)
		{
			int num = _r.getBoardPosition().cardinalDistance(base.board_position);
			if (num > _a.Item1)
			{
				return (num, new List<RoleData> { _r });
			}
			return (num == _a.Item1) ? (num, _a.Item2.add(_r)) : _a;
		}).Item2.getRandomElementFromList(random);
		randomElementFromList.setTainted(_new: true);
		tainted_target = randomElementFromList.getAddress();
		return _board;
	}
}
