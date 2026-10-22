using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Doppelganger : RoleData, IHaveRoleAbility, IHaveAbility
{
	private int target_address = -1;

	private bool override_has_info;

	public override Roles role => Roles.DOPPELGANGER;

	public override string english_name => "Doppelganger";

	public override string english_description => Keywords.ABILITY.toStringCap() + ": Pick a " + Keywords.ROLE.toString() + " with an " + Keywords.ABILITY.toString() + ".\nIf the selected " + Keywords.ROLE.toString() + " is " + TextHelper.lyingOrTainted + ", I " + Keywords.ANNOUNCE.toString() + " \"Something does not make sense.\", otherwise I " + Keywords.PRETEND.toString() + " to be their " + Keywords.APPEARANCE.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I can only " + Keywords.TARGET.toString() + " " + TextHelper.investigated + " " + TextHelper.roles + " with my " + Keywords.ABILITY.toString() + ".\nI cannot " + Keywords.TARGET.toString() + " myself with my " + Keywords.ABILITY.toString() + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I always " + Keywords.ANNOUNCE.toString() + " \"Something does not make sense.\""));
			return list;
		}
	}

	public override bool hasInfo => override_has_info;

	bool IHaveAbility.abilityExhausted => ability_exhausted;

	int IHaveAbility.numberTargets => 1;

	bool IHaveRoleAbility.allowSelfTarget => false;

	public Doppelganger(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Doppelganger(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		override_has_info = base.info_string.is_some;
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.HAS_ABILITY, new List<AdvancedGenerationConstraint>
		{
			new AvoidSuspectRoleGC(Roles.ACCOUNTANT, Roles.SCRAMBLER),
			new InPlayRequireRoleGC(RoleGenerationMarkers.HAS_ABILITY, 1, DisguiseConstraintType.NEVER_IGNORE),
			new LeadRequireGC(new List<RoleClassifications>
			{
				RoleClassifications.INNOCENT,
				RoleClassifications.MEDDLER
			}, RoleGenerationMarkers.HAS_ABILITY, 2)
		});
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.INNOCENT;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address == base.address && !disguise.is_some)
		{
			target_address = _target_addresses[0];
			RoleData roleData = _board.getRolesInPlay()[target_address];
			if (base.has_bad_info || roleData.getIsLying() || roleData.getIsTainted())
			{
				override_has_info = true;
			}
			else
			{
				overrideWithNewDisguise(roleData.getVisualRole().role);
			}
		}
		return _board.registerRoleChange(base.board_position, this);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		return checkTranslation(getInfoEnglish);
	}

	private string getInfoEnglish()
	{
		return "Something does not make sense.";
	}

	bool IHaveRoleAbility.validateTarget(RoleData _roll_candidate)
	{
		if (_roll_candidate.getAddress() != base.address && _roll_candidate.getVisualRole().getHasAnyAbility())
		{
			if (!_roll_candidate.getIsInvestigated())
			{
				return _roll_candidate.getIsArrested();
			}
			return true;
		}
		return false;
	}

	string IHaveAbility.getAbilityPrompt()
	{
		return checkTranslation(base.loc_default_ability_prompt_key, getAbilityPromptEnglish);
	}

	private string getAbilityPromptEnglish()
	{
		return "Select one " + Keywords.ROLE.toString() + " with an " + Keywords.ABILITY.toString() + ".";
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
