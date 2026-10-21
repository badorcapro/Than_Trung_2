using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Mailman : RoleData
{
	public override Roles role => Roles.MAILMAN;

	public override string english_name => "Mailman";

	public override string english_description => TextHelper.whenInvestigated + ", I " + Keywords.ANNOUNCE.toString() + " one " + TextHelper.inPlayRole + " and one " + TextHelper.notInPlayRole + ", specifying which is which.";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", both parts of my " + TextHelper.announcement + " will be false.") };

	public override bool hasInfo => true;

	private string loc_info_key => $"{role} [info]";

	public Mailman(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Mailman(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.CANT_BE_ONLY_NOT_IN_PLAY);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		List<RoleData> list = (from _e in _snap.board.getRolesInPlay()
			select _e.Value into _e
			where _e.role != Roles.MAILMAN
			select _e).ToList();
		List<RoleData> list2 = (from _e in _snap.board.getRolesNotInPlay(_snap.true_suspect_list)
			where _e.role != Roles.MAILMAN
			select _e).ToList();
		if (list.Count == 0 || list2.Count == 0)
		{
			Debug.LogError("Mailman cannot give info!");
			return "";
		}
		if (base.has_bad_info)
		{
			return infoString(list2.getRandomElementFromList(random), list.getRandomElementFromList(random));
		}
		RoleData randomElementFromList = list.getRandomElementFromList(random);
		RoleData randomElementFromList2 = list2.getRandomElementFromList(random);
		return infoString(randomElementFromList, randomElementFromList2);
	}

	private string infoString(RoleData _in, RoleData _out)
	{
		return checkTranslationWithReplace(loc_info_key, () => getInfoEnglish(_in.name, _out.name), () => _in.name, () => _out.name);
	}

	private string getInfoEnglish(string _data_1, string _data_2)
	{
		return "The " + _data_1 + " lives in town, I've never heard of the " + _data_2 + ".";
	}

	public RoleData createAndForceSetInfo(Roles _in, Roles _out)
	{
		base.info_string = infoString(_in.createEmptyRole(), _out.createEmptyRole()).maybe();
		return this;
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.INNOCENT;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
