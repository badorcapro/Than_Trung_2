using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Veteran : RoleData
{
	private List<int> roles_tried = new List<int>();

	public override Roles role => Roles.VETERAN;

	public override string english_name => "Veteran";

	public override string english_description => "If an " + Keywords.ROLE.toString() + " attempts to " + Keywords.KILL.toString() + " me, I " + Keywords.KILL.toString() + " them first. " + TextHelper.ipretendSuspectedInnocent;

	public override bool hasInfo => false;

	public Veteran(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Veteran(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		roles_tried = _save.unique_data.fromStringCommaSeperate();
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getInnocentDisguise(DisguiseTarget.SUSPECTED);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getTruthString()
	{
		if (roles_tried.Count != 0)
		{
			return checkTranslationWithData(base.loc_default_truth_key, englishTruth, CaseHelper.getSimpleMultiAddress(roles_tried)) + "\n" + base.getTruthString();
		}
		return base.getTruthString();
	}

	private string englishTruth(string _data)
	{
		return "I killed " + _data;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onKillAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _murdered_address, Maybe<RoleData> _killer)
	{
		if (base.has_bad_info || _murdered_address != base.address || !_killer.is_some || _killer.value.getVisualAlignment() != Alignments.EVIL)
		{
			return _board;
		}
		int num = _killer.value.getAddress();
		if (num == base.address)
		{
			return _board;
		}
		if (!base.is_true_self)
		{
			true_self.value.resurrect();
		}
		base.dead = false;
		base.case_ref.killAddress(_killer.value.getAddress(), ((RoleData)this).maybe());
		roles_tried.Add(num);
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return roles_tried.toStringCommaSeperated();
	}
}
