using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

public class Preacher : RoleData
{
	private Roles override_reveal_as = Roles.PREACHER;

	public override Roles role => Roles.PREACHER;

	public override Roles reveal_as => override_reveal_as;

	public override string english_name => "Preacher";

	public override string english_description => TextHelper.iLieAndPretendSuspected + ". When I am " + TextHelper.arrested + ", I " + Keywords.REVEAL.toString() + " as a " + Keywords.NOT_IN_PLAY.toString() + " " + RoleClassifications.TRAITOR.toString() + ". An extra " + RoleClassifications.TRAITOR.toString() + " is " + Keywords.SUSPECTED.toString() + ".";

	public override bool hasInfo => false;

	public Preacher(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Preacher(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		if (_save.unique_data != null && _save.unique_data != "")
		{
			override_reveal_as = (Roles)int.Parse(_save.unique_data);
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new SuspectRequireRoleGC(RoleClassifications.TRAITOR, 2, _true_class: true));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onDisguiseSet(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted)
		{
			return _board;
		}
		List<RoleData> list = (from _r in _board.getRolesNotInPlay(_suspects)
			where _r.role.getClassificationFromRoleType() == RoleClassifications.TRAITOR
			select _r).ToList();
		if (list.Count == 0)
		{
			Debug.LogError("Preacher cant reveal as not in play traitor as none exists!\nSuspect List: " + base.case_ref.getSuspectList().Aggregate("", (string _a, Roles _r) => _a += $"{_r} | "));
			return _board;
		}
		override_reveal_as = list.getRandomElementFromList(random).role;
		return _board;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.EVIL;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.UNDERLING;
	}

	public override string getUniqueSaveData()
	{
		int num = (int)override_reveal_as;
		return num.ToString();
	}

	public override string getTruthString()
	{
		if (override_reveal_as == Roles.PREACHER || !base.arrested)
		{
			return base.getTruthString();
		}
		RoleData roleData = override_reveal_as.createEmptyRole();
		return LocalisationHelper.checkOptionIfNotAsian(checkTranslationWithData(base.loc_default_truth_key, englishTruth, roleData.name), roleData.getNamePrefixOption()) + "\n" + base.getTruthString();
	}

	private string englishTruth(string _data)
	{
		return "I revealed as a{#/n} " + _data + ".";
	}
}
