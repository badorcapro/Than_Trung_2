using System;
using System.Collections.Generic;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Mortician : CasinoRoleData
{
	private Maybe<int> killed_target = new Maybe<int>();

	public override Roles role => Roles.MORTICIAN;

	public override string english_name => "Mortician";

	public override string english_description => "When a " + Keywords.CARD.toString() + " is discarded, I might " + Keywords.KILL.toString() + " an " + TextHelper.innocentRole + ". I " + Keywords.ANNOUNCE.toString() + " the " + Keywords.ROLE.toString() + " I " + TextHelper.killed + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I have a 50% chance to " + Keywords.KILL.toString() + " each time a " + Keywords.CARD.toString() + " is discarded. I can only " + Keywords.KILL.toString() + " once."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I never " + Keywords.KILL.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => killed_target.is_some;

	public Mortician(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Mortician(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		if (_save.unique_data == "f")
		{
			killed_target = new Maybe<int>();
		}
		else
		{
			killed_target = RoleHelper.tryLoadSingleValueFromUniqueData(role, _save).maybe();
		}
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

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCardDrawnAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCaseActionPayload _payload, List<CasinoCard> _discarded, List<CasinoCard> _new_cards)
	{
		if (_discarded.Count == 0 || base.dead || base.arrested || base.has_bad_info || killed_target.is_some)
		{
			return _board;
		}
		if (random.Next(0, Mathf.RoundToInt(Mathf.Pow(2f, _discarded.Count))) == 1)
		{
			return _board;
		}
		List<int> list = _board.getRolesInPlayOfClass(default(RoleClassifications)).whereSelect((RoleData _r) => !_r.getIsDead(), (RoleData _r) => _r.getAddress());
		if (list.Count == 0)
		{
			return _board;
		}
		killed_target = list.getRandomElementFromList(random).maybe();
		base.casino_case.killAddress(killed_target.value, this);
		return _board;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (!killed_target.is_some)
		{
			Debug.LogError($"Trying to get info before target has been killed! {role}");
			return "";
		}
		RoleData roleData = _snap.address_occupents[killed_target.value];
		return checkTranslationWithData(englishInfo, roleData.name_coloured);
	}

	private string englishInfo(string _d1)
	{
		return "I took the " + _d1 + " out.";
	}

	public override string getUniqueSaveData()
	{
		if (!killed_target.is_some)
		{
			return "f";
		}
		return killed_target.value.ToString();
	}
}
