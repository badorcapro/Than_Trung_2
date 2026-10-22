using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Thief : BackAlleyRoleData
{
	private Maybe<BackAlleysItem> stolen_item = new Maybe<BackAlleysItem>();

	private bool returned_item;

	public override Roles role => Roles.THIEF;

	public override string english_name => "Thief";

	public override string english_description => "When I am " + Keywords.IN_PLAY.toString() + ", I " + Keywords.STEAL.toString() + " an " + Keywords.ITEM.toString() + " from you at the start of the case. When I am " + TextHelper.arrested + ", I return the " + Keywords.ITEM.toString() + ".\n" + TextHelper.iLieAndPretendSuspected + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I only return the " + Keywords.ITEM.toString() + " when I am " + TextHelper.arrested + ". If I am " + TextHelper.killed + ", I do not return the " + Keywords.ITEM.toString() + " I " + TextHelper.stole + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", I do not " + Keywords.STEAL.toString() + " an " + Keywords.ITEM.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public Thief(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Thief(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			if (_save.unique_data == "no_item")
			{
				stolen_item = new Maybe<BackAlleysItem>();
				return;
			}
			returned_item = _save.unique_data[0] == 't';
			stolen_item = BackAlleysItem.load(_save.unique_data.Substring(1), delegate
			{
			}, random).maybe();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			stolen_item = new Maybe<BackAlleysItem>();
		}
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override string getUniqueSaveData()
	{
		if (!stolen_item.is_some)
		{
			return "no_item";
		}
		return (returned_item ? "t" : "f") + stolen_item.value.toSaveData();
	}

	public override string getTruthString()
	{
		if (!stolen_item.is_some)
		{
			return base.getTruthString();
		}
		return checkTranslationWithData(base.loc_default_truth_key, englishTruth, stolen_item.value.name) + "\n" + base.getTruthString();
	}

	private string englishTruth(string _data)
	{
		return "I stole your " + _data + ".";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted || base.dead || base.arrested)
		{
			return _board;
		}
		stolen_item = base.back_alley_case.pouch.stealItem(random);
		return _board;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (_arrested_address == base.address && stolen_item.is_some && !returned_item)
		{
			base.back_alley_case.pouch.gainItem(stolen_item.value);
			returned_item = true;
			return _board;
		}
		return base.onArrestAction(_board, _payload, _arrested_address);
	}
}
