using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Croupier : CasinoRoleData
{
	private static int discard_cost = 2;

	public override Roles role => Roles.CROUPIER;

	public override string english_name => "Croupier";

	public override string english_description => $"While I am {TextHelper.investigated}, {TextHelper.aliveAndNotArrested}, discarding a {Keywords.CARD.toString()} costs {discard_cost} {TextHelper.chips_with_link}. {TextHelper.iLieAndPretendSuspected}.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", discarding a " + Keywords.CARD.toString() + " will not cost you any " + TextHelper.chips_with_link));
			return list;
		}
	}

	public override string credits => "Arboreality";

	public override bool hasInfo => false;

	public Croupier(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Croupier(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new InPlayRequireRoleGC(checkRoleForConstraints, new RequirementEEB(() => LevelEditorHelper.cardAbilityRole), 1, DisguiseConstraintType.ALWAYS_IGNORE));
	}

	private bool checkRoleForConstraints(Roles _role)
	{
		if (_role.createEmptyRole() is IHaveSpecialAbility haveSpecialAbility)
		{
			return haveSpecialAbility.ability_type == SpecialAbilityType.CARD_ABILITY;
		}
		return false;
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCardDrawnAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCaseActionPayload _payload, List<CasinoCard> _discarded, List<CasinoCard> _new_cards)
	{
		if (!base.investigated || base.tainted || base.dead || base.arrested || _discarded.Count == 0)
		{
			return _board;
		}
		base.casino_case.spendChips(discard_cost * _discarded.Count);
		return base.onCardDrawnAction(_board, _payload, _discarded, _new_cards);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		return "";
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
