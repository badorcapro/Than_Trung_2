using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Egotist : RoleData
{
	private int target = -1;

	public override Roles role => Roles.EGOTIST;

	public override string english_name => "Egotist";

	public override string english_description => "If the first " + Keywords.ROLE.toString() + " you " + Keywords.ARREST.toString() + " is " + Alignments.GOOD.toString() + ", they become " + Alignments.EVIL.toString() + " and " + Keywords.REVEAL.toString() + " as a " + TextHelper.suspectedUnderlingRole + ".\nI can't make myself " + Alignments.EVIL.toString() + ". " + TextHelper.ipretendNotInPlayInnocent + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", I do not affect the first " + Keywords.ARREST.toString() + ".") };

	public override string credits => "Sequest";

	public override bool hasInfo => false;

	public Egotist(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Egotist(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			target = int.Parse(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed {role}! ({_save.unique_data}) | Error: {arg}");
			target = -1;
		}
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getInnocentDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		return "";
	}

	public override string getTruthString()
	{
		if (target > -1)
		{
			return checkTranslationWithData(base.loc_default_truth_key, getTruthEnglish, target) + "\n" + base.getTruthString();
		}
		return base.getTruthString();
	}

	private string getTruthEnglish(string _data)
	{
		return "I made #" + _data + " evil as you arrested them!";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (base.dead || base.arrested || base.has_bad_info || target != -1)
		{
			return _board;
		}
		RoleData roleData = _board.getRolesInPlay()[_arrested_address];
		if (roleData.getVisualAlignment() == Alignments.GOOD)
		{
			roleData.setAlignment(Alignments.EVIL);
			roleData.setOverrideRevealRole((from _r in base.case_ref.getSuspectList()
				where _r.getClassificationFromRoleType() == RoleClassifications.UNDERLING
				select _r).ToList().getRandomElementFromList(random));
			target = _arrested_address;
		}
		else
		{
			target = -2;
		}
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	public override string getUniqueSaveData()
	{
		return target.ToString();
	}
}
