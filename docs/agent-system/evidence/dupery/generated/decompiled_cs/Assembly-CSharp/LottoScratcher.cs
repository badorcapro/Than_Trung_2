using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class LottoScratcher : CasinoRoleData, IHaveRoleAbility, IHaveAbility
{
	private enum B_InfoType
	{
		TRUSTWORTHY,
		PRETENDING,
		LYING,
		TAINTED
	}

	private const int ability_reward = 30;

	private List<int> targets = new List<int>();

	private bool all_evil;

	public override Roles role => Roles.LOTTO_SCRATCHER;

	public override string english_name => "Lotto Scratcher";

	public override string english_description => $"{Keywords.ABILITY.toStringCap()}: Pick 2 {Keywords.ALIVE.toString()} and {Keywords.UNARRESTED.toString()} {TextHelper.roles}. If they are both {Alignments.EVIL.toString()}, I give you {30} {TextHelper.chips_with_link}.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "If the " + TextHelper.roles + " picked are both " + Alignments.EVIL.toString() + ", I will " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_1 + "\". Otherwise I will " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_2 + "\"."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I will never give you " + TextHelper.chips_with_link + " and I will " + Keywords.ANNOUNCE.toString() + " the wrong statement."));
			return list;
		}
	}

	public override string credits => "Wind";

	public override bool hasInfo => ability_exhausted;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 2;

	public bool allowSelfTarget => true;

	private string loc_wrong_info_key => $"{role} [info_wrong]";

	public LottoScratcher(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public LottoScratcher(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override string fillExtraDescription(string _description, DescriptionType _type)
	{
		if (_type != DescriptionType.SPECIAL)
		{
			return _description;
		}
		return _description.Replace(RoleData.loc_marker_1, checkTranslation(infoSolvedEnglish)).Replace(RoleData.loc_marker_2, checkTranslation(loc_wrong_info_key, infoWrongEnglish));
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.HAS_ABILITY, new ClassificationRatioGC(RoleClassifications.UNDERLING, 2, DisguiseConstraintType.NEVER_IGNORE));
	}

	public bool validateTarget(RoleData _roll_candidate)
	{
		if (!_roll_candidate.getIsArrested())
		{
			return !_roll_candidate.getIsDead();
		}
		return false;
	}

	public string getAbilityPrompt()
	{
		return checkTranslation(base.loc_default_ability_prompt_key, getAbilityPromptEnglish);
	}

	private string getAbilityPromptEnglish()
	{
		return "Select two alive and unarrested roles.";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address != base.address)
		{
			return _board;
		}
		targets = _target_addresses;
		Dictionary<int, RoleData> board_roles = _board.getRolesInPlay();
		all_evil = !targets.Any((int _a) => board_roles[_a].getVisualAlignment() != Alignments.EVIL);
		if (all_evil && !base.has_bad_info)
		{
			base.casino_case.gainChips(30);
		}
		return _board;
	}

	protected override string generateCasinoInfoString(CasinoCaseSnapshot _snap)
	{
		if (base.has_bad_info ? (!all_evil) : all_evil)
		{
			return checkTranslation(infoSolvedEnglish);
		}
		return checkTranslation(loc_wrong_info_key, infoWrongEnglish);
	}

	private string infoSolvedEnglish()
	{
		return "You solved it!";
	}

	private string infoWrongEnglish()
	{
		return "Better luck next time!";
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
