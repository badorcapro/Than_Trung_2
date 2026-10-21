using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Trickster : CasinoRoleData, IChangeAbilityTargets
{
	public override Roles role => Roles.TRICKSTER;

	public override string english_name => "Trickster";

	public override string english_description => "Whenever you pick a " + Keywords.CARD.toString() + " for an " + Keywords.ABILITY.toString() + ", I make you pick the other one. " + TextHelper.ipretendNotInPlayInnocent + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", " + TextHelper.deadOrArrested + ", I do not change your " + TextHelper.cards + " selection."));
			return list;
		}
	}

	public override string credits => "5kBird";

	public override bool hasInfo => false;

	public Trickster(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Trickster(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new InPlayRequireRoleGC((Roles _r) => _r.createEmptyRole() is IHaveSpecialAbility haveSpecialAbility && haveSpecialAbility.ability_type == SpecialAbilityType.CARD_ABILITY, new RequirementEEB(() => LevelEditorHelper.cardAbilityRole), 1, DisguiseConstraintType.ALWAYS_IGNORE));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getInnocentDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public List<int> changeAbilityTargets(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<int> _targets, int _abil_user_address)
	{
		return _targets;
	}

	public List<AbilityData> changeAbilityData(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<AbilityData> _data, int _abil_user_address)
	{
		if (base.tainted || base.dead || base.arrested)
		{
			return _data;
		}
		if (!(_case is CasinoCase casinoCase))
		{
			Debug.LogError($"{role} | Cannot change ability data when not in casino!");
			return _data;
		}
		foreach (AbilityData _datum in _data)
		{
			if (_datum is CasinoCardAbilityData casinoCardAbilityData)
			{
				if (casinoCase.left_card.info == casinoCardAbilityData.card_picked.info)
				{
					casinoCardAbilityData.card_picked = casinoCase.right_card;
				}
				else
				{
					casinoCardAbilityData.card_picked = casinoCase.left_card;
				}
			}
		}
		return _data;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
