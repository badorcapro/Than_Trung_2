using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

public class Researcher : RoleData, IHaveRoleAbility, IHaveAbility
{
	private int target = -1;

	private RoleClassifications researching_class = (RoleClassifications)(-1);

	public override Roles role => Roles.RESEARCHER;

	public override string english_name => "Researcher";

	public override string english_description => TextHelper.whenInvestigatedIAnnounce + " a random " + Keywords.CLASSIFICATION.toString() + ".\n" + Keywords.ABILITY.toStringCap() + ": Pick a " + Keywords.ROLE.toString() + ". I " + Keywords.ANNOUNCE.toString() + " if they are of that " + Keywords.CLASSIFICATION.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I can " + Keywords.TARGET.toString() + " myself with my " + Keywords.ABILITY.toString() + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTaintIAnnounceOppositeOfTrue));
			return list;
		}
	}

	public override string credits => "Runaway142";

	public override bool has_hover_focus
	{
		get
		{
			if (ability_exhausted)
			{
				return target != -1;
			}
			return false;
		}
	}

	public override bool hasInfo => true;

	bool IHaveAbility.abilityExhausted => ability_exhausted;

	int IHaveAbility.numberTargets => 1;

	bool IHaveRoleAbility.allowSelfTarget => true;

	private string loc_match_info_key => $"{role} [info_mtch]";

	private string loc_no_match_info_key => $"{role} [info_nm]";

	public Researcher(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Researcher(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			target = int.Parse(array[0]);
			researching_class = (RoleClassifications)int.Parse(array[1]);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! Error: {arg}");
			target = -1;
			researching_class = (RoleClassifications)(-1);
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.HAS_ABILITY);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address == base.address)
		{
			target = _target_addresses[0];
			resetInfo();
		}
		return _board;
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		return _occupent.maybe_a.value.getAddress() == target;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (target == -1)
		{
			researching_class = _snap.board.getOnBoardRatio(_true_class: true).where((RoleClassifications _c, int _n) => _n > 0).ToList()
				.getRandomElementFromList(random)
				.Key;
			return checkTranslationWithData(englishInfo, researching_class.toString());
		}
		if (researching_class == (RoleClassifications)(-1))
		{
			Debug.LogError("Researching class not set up but generating ability info!");
		}
		bool flag = _snap.address_occupents[target].getVisualClassification() == researching_class;
		if (base.has_bad_info)
		{
			flag = !flag;
		}
		if (flag)
		{
			return LocalisationHelper.checkOption(checkTranslationWithReplace(loc_match_info_key, () => englishInfoMatch(target.ToString(), researching_class.toString()), () => target.ToString(), () => researching_class.toString()), researching_class.getPrefixOption());
		}
		return LocalisationHelper.checkOption(checkTranslationWithReplace(loc_no_match_info_key, () => englishInfoNoMatch(target.ToString(), researching_class.toString()), () => target.ToString(), () => researching_class.toString()), researching_class.getPrefixOption());
	}

	private string englishInfo(string _data)
	{
		return "I study the towns " + _data + ".";
	}

	private string englishInfoMatch(string _d1, string _d2)
	{
		return "#" + _d1 + " is a{#/n} " + _d2 + ".";
	}

	private string englishInfoNoMatch(string _d1, string _d2)
	{
		return "#" + _d1 + " is not a{#/n} " + _d2 + ".";
	}

	bool IHaveRoleAbility.validateTarget(RoleData _roll_candidate)
	{
		return true;
	}

	string IHaveAbility.getAbilityPrompt()
	{
		return TextHelper.ab_selectRolesLocalised(1);
	}

	public override string getUniqueSaveData()
	{
		return $"{target},{(int)researching_class}";
	}
}
