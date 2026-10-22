using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Godfather : RoleData
{
	private List<int> killed_targets = new List<int>();

	public override Roles role => Roles.GODFATHER;

	public override string english_name => "Godfather";

	public override string english_description => TextHelper.whileIAmAliveAndNotArrested + ", everytime you " + Keywords.ARREST.toString() + " an " + TextHelper.evilRole + ", I " + Keywords.KILL.toString() + " a random " + TextHelper.goodRole + " if possible.\n" + TextHelper.iLieAndPretendNotInPlay + ".";

	public override string credits => "Wind";

	public override bool hasInfo => false;

	public Godfather(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Godfather(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			killed_targets = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			killed_targets = new List<int>();
		}
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getTruthString()
	{
		return ((killed_targets.Count == 0) ? "" : checkTranslationWithData(base.loc_default_truth_key, englishTruth, CaseHelper.getSimpleMultiAddress(killed_targets))) + base.getTruthString();
	}

	private string englishTruth(string _data)
	{
		return "I killed " + _data + ".";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (base.tainted || base.dead || base.arrested)
		{
			return _board;
		}
		Dictionary<int, RoleData> rolesInPlay = _board.getRolesInPlay();
		if (rolesInPlay[_arrested_address].getVisualAlignment() == Alignments.EVIL)
		{
			List<KeyValuePair<int, RoleData>> list = rolesInPlay.Where((KeyValuePair<int, RoleData> _r) => !_r.Value.getIsArrested() && !_r.Value.getIsDead() && _r.Value.getVisualAlignment() == Alignments.GOOD).ToList();
			if (list.Count == 0)
			{
				return _board;
			}
			int key = list.getRandomElementFromList(random).Key;
			base.case_ref.killAddress(key, ((RoleData)this).maybe());
			killed_targets.Add(key);
		}
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	public override string getUniqueSaveData()
	{
		return killed_targets.toStringCommaSeperated();
	}
}
