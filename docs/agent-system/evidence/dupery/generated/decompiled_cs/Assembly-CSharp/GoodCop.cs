using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class GoodCop : RoleData, IHaveRoleAbility, IHaveAbility
{
	public int target = -1;

	public override Roles role => Roles.GOOD_COP;

	public override string english_name => "Good Cop";

	public override string english_description => Keywords.ABILITY.toStringCap() + ": Pick a " + Keywords.ROLE.toString() + ". I convert their " + Keywords.ALIGNMENT.toString() + " to my own. When I am " + Keywords.IN_PLAY.toString() + ", the " + Roles.BAD_COP.toString() + " is also " + Keywords.IN_PLAY.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I do not convert the " + Keywords.ALIGNMENT.toString() + " of the picked " + Keywords.ROLE.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => ability_exhausted;

	bool IHaveAbility.abilityExhausted => ability_exhausted;

	int IHaveAbility.numberTargets => 1;

	bool IHaveRoleAbility.allowSelfTarget => true;

	public GoodCop(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		target = int.Parse(_save.unique_data);
	}

	public GoodCop(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.HAS_ABILITY, new InPlayRequireRoleGC(Roles.BAD_COP, DisguiseConstraintType.ALWAYS_IGNORE));
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		return checkTranslationWithData(getInfoEnglish, target);
	}

	private string getInfoEnglish(string _data)
	{
		return "I befriended #" + _data + "!";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address == getAddress())
		{
			target = _target_addresses[0];
			if (base.has_bad_info)
			{
				return _board;
			}
			RoleData roleData = _board.getRolesInPlay()[_target_addresses[0]];
			roleData.setAlignment((!base.tainted) ? (true_self.is_some ? true_self.value.getVisualAlignment() : getVisualAlignment()) : (((!true_self.is_some) ? (getVisualAlignment() == Alignments.GOOD) : (true_self.value.getVisualAlignment() == Alignments.GOOD)) ? Alignments.EVIL : Alignments.GOOD));
			return _board.registerRoleChange(roleData.getBoardPosition(), roleData);
		}
		return base.onAbilityUsedAction(_board, _payload, _ability_user_address, _target_addresses);
	}

	public override string getUniqueSaveData()
	{
		return target.ToString();
	}

	bool IHaveRoleAbility.validateTarget(RoleData _roll_candidate)
	{
		return true;
	}

	string IHaveAbility.getAbilityPrompt()
	{
		return checkTranslation(base.loc_default_ability_prompt_key, getAbilityPromptEnglish);
	}

	private string getAbilityPromptEnglish()
	{
		return "Select 1 role to befriend.";
	}
}
