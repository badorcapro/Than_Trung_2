using System;
using System.Collections.Generic;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class BadMouth : RoleData
{
	private int target = -1;

	private bool changed_target;

	public override Roles role => Roles.BAD_MOUTH;

	public override string english_name => "Bad Mouth";

	public override string english_description => "One " + TextHelper.innocentRole + " registers as an " + Alignments.EVIL.toString() + " " + RoleClassifications.UNDERLING.toString() + " to every other " + Keywords.ROLE.toString() + ". " + TextHelper.whenInvestigatedIAnnounce + " their " + Keywords.ADDRESS.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I " + Keywords.ANNOUNCE.toString() + " the " + Keywords.ADDRESS.toString() + " of an " + TextHelper.innocentRole + " but do not change how they register to every other " + Keywords.ROLE.toString() + "."));
			return list;
		}
	}

	public override string credits => "Smile";

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	private string loc_info_late_key => $"{role} [late_info]";

	public BadMouth(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public BadMouth(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			target = int.Parse(array[0]);
			changed_target = array[1] == "t";
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed {role}! ({_save.unique_data}) | Error: {arg}");
			target = -1;
			changed_target = false;
		}
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (target != -1)
		{
			return checkTranslationWithData(getInfoEnglish, target);
		}
		return checkTranslation(loc_info_late_key, getInfoLateEnglish);
	}

	private string getInfoEnglish(string _data)
	{
		return "I have badmouthed #" + _data + ".";
	}

	private string getInfoLateEnglish()
	{
		return "I arrived late. I badmouthed no one.";
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == target;
		}
		return false;
	}

	public override string getTruthString()
	{
		if (target != -1 && changed_target)
		{
			return checkTranslationWithData(base.loc_default_truth_key, getTruthEnglish, target) + "\n" + base.getTruthString();
		}
		return base.getTruthString();
	}

	private string getTruthEnglish(string _data)
	{
		return "I made #" + _data + " register as an evil underling!";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		List<RoleData> rolesInPlayOfClass = _board.getRolesInPlayOfClass(default(RoleClassifications));
		if (rolesInPlayOfClass.Count == 0)
		{
			Debug.LogError($"No innocents in play! ({role} info)");
			target = -1;
			return _board;
		}
		RoleData randomElementFromList = rolesInPlayOfClass.getRandomElementFromList(random);
		target = randomElementFromList.getAddress();
		if (base.has_bad_info)
		{
			return _board;
		}
		randomElementFromList.setVisualAlignment(Alignments.EVIL);
		randomElementFromList.setVisualClassification(RoleClassifications.UNDERLING);
		changed_target = true;
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return string.Format("{0},{1}", target, changed_target ? "t" : "f");
	}
}
