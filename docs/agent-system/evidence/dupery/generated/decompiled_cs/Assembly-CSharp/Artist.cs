using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

public class Artist : RoleData
{
	private Roles said_role = (Roles)(-1);

	public override Roles role => Roles.ARTIST;

	public override string english_name => "Artist";

	public override string english_description => TextHelper.whenInvestigatedIAnnounce + " a " + Keywords.ROLE.toString() + " an " + TextHelper.evilRole + " is " + TextHelper.pretending + " to be.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "If there are no " + TextHelper.pretending + " " + TextHelper.evilRoles + ", I will " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_1 + "\"."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I " + Keywords.ANNOUNCE.toString() + " an " + TextHelper.inPlayInnocentRole + " no " + TextHelper.evilRole + " is " + TextHelper.pretending + " to be."));
			return list;
		}
	}

	public override bool has_hover_focus => said_role != (Roles)(-1);

	public override bool hasInfo => true;

	private string loc_blank_key => $"{role} [blank]";

	public Artist(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Artist(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			said_role = (Roles)int.Parse(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}! '{_save.unique_data}' | Error: {arg}");
			said_role = (Roles)(-1);
		}
	}

	protected override bool getEnglishNamePrefixOption()
	{
		return false;
	}

	protected override string fillExtraDescription(string _description, DescriptionType _type)
	{
		if (_type == DescriptionType.SPECIAL)
		{
			return _description.Replace(RoleData.loc_marker_1, getInfoBlank());
		}
		return _description;
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a && _occupent.maybe_a.value.getIsInvestigated() && !_occupent.maybe_a.value.getIsArrested() && _occupent.maybe_a.value.getVisualRole().role == said_role)
		{
			return !_occupent.maybe_a.value.getIsObscured();
		}
		return false;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		List<RoleData> pretending_evil_roles = (from _r in _snap.board.getRolesInPlay()
			where _r.Value.getIsDisguised() && _r.Value.getVisualAlignment() == Alignments.EVIL
			select _r.Value.getVisualRole()).ToList();
		if (base.has_bad_info)
		{
			List<RoleData> list = (from _r in _snap.board.getRolesInPlay()
				where _r.Value.role.getClassificationFromRoleType() == RoleClassifications.INNOCENT && !_r.Value.getIsDisguised() && !pretending_evil_roles.Exists((RoleData _pr) => _pr.role == _r.Value.role)
				select _r.Value).ToList();
			if (list.Count == 0)
			{
				return getInfoBlank();
			}
			RoleData randomElementFromList = list.getRandomElementFromList(random);
			said_role = randomElementFromList.role;
			return getInfo(randomElementFromList);
		}
		if (pretending_evil_roles.Count == 0)
		{
			return getInfoBlank();
		}
		RoleData randomElementFromList2 = pretending_evil_roles.getRandomElementFromList(random);
		said_role = randomElementFromList2.role;
		return getInfo(randomElementFromList2);
	}

	private string getInfo(RoleData _role)
	{
		return LocalisationHelper.checkOptionIfNotAsian(checkTranslationWithData(getInfoEnglish, _role.name), _role.getNamePrefixOption());
	}

	private string getInfoBlank()
	{
		return checkTranslation(loc_blank_key, getInfoBlankEnglish);
	}

	private string getInfoEnglish(string _data)
	{
		return "I have painted a{#/n} " + _data + ".";
	}

	private string getInfoBlankEnglish()
	{
		return "I have painted a blank canvas.";
	}

	public override string getUniqueSaveData()
	{
		int num = (int)said_role;
		return num.ToString();
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.INNOCENT;
	}
}
