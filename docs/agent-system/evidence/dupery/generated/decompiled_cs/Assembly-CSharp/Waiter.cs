using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

public class Waiter : CasinoRoleData, IHaveSpecialAbility, IHaveAbility
{
	private const int ability_cost = 2;

	private Maybe<CasinoCard> card_picked = new Maybe<CasinoCard>();

	private int said = -1;

	public override Roles role => Roles.WAITER;

	public override string english_name => "Waiter";

	public override string english_description => TextHelper.ability_with_cost_marker + ": Pick a " + Keywords.CARD.toString() + " and discard it. I " + Keywords.ANNOUNCE.toString() + " how many " + Keywords.STEPS.toString() + " I am from the closest " + Keywords.ROLE.toString() + " of the same " + Keywords.CLASSIFICATION.toString() + " as the " + TextHelper.associated + " " + TextHelper.suit + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "If I find no " + TextHelper.roles + " of the same " + Keywords.CLASSIFICATION.toString() + " as the picked " + Keywords.CARD.toString() + " " + TextHelper.associated + " " + TextHelper.suit + ", I " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_1 + "\""));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I will " + Keywords.ANNOUNCE.toString() + " a random number of " + Keywords.STEPS.toString() + " between 1 and 4 that is incorrect."));
			return list;
		}
	}

	public SpecialAbilityType ability_type => SpecialAbilityType.CARD_ABILITY;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	public override bool hasInfo
	{
		get
		{
			if (ability_exhausted)
			{
				return card_picked.is_some;
			}
			return false;
		}
	}

	public override bool has_hover_focus => said != -1;

	private string loc_empty_info_key => $"{role} [info_emp]";

	public Waiter(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Waiter(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			said = int.Parse(array[0]);
			if (array[1] == "f")
			{
				card_picked = new Maybe<CasinoCard>();
			}
			else
			{
				card_picked = CasinoCard.parse(array[1]).maybe();
			}
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}!\nSave: {_save.unique_data}\nError: {arg}");
			said = -1;
			card_picked = new Maybe<CasinoCard>();
		}
	}

	protected override string fillDescription(string _description, CaseSnapshot _snapshot)
	{
		return _description.Replace(RoleData.loc_marker_1, Mathf.FloorToInt(2f * (_snapshot as CasinoCaseSnapshot).casino_payload.cost_multi).ToString());
	}

	protected override string defaultFillDescription(string _description)
	{
		return _description.Replace(RoleData.loc_marker_1, 2.ToString());
	}

	protected override string fillExtraDescription(string _description, DescriptionType _type)
	{
		if (_type == DescriptionType.SPECIAL)
		{
			return _description.Replace(RoleData.loc_marker_1, checkTranslationWithData(loc_empty_info_key, englishEmptyInfo, "#"));
		}
		return base.fillExtraDescription(_description, _type);
	}

	public void onSpecialAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _user_address, List<AbilityData> _data)
	{
		if (_user_address == base.address)
		{
			base.casino_case.spendChips(2);
			if (_data.Count > 0 && _data[0] is CasinoCardAbilityData casinoCardAbilityData)
			{
				card_picked = casinoCardAbilityData.card_picked.maybe();
				base.casino_case.replaceCard(casinoCardAbilityData.card_picked);
			}
			else
			{
				Debug.LogError($"Did not know how to parse special ability data! List was either empty or of the wrong type! ({role})");
			}
		}
	}

	public string getAbilityPrompt()
	{
		return TextHelper.ab_selectACardLocalised;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (!card_picked.is_some)
		{
			Debug.LogError("Trying to get info string before card is picked!");
			return "";
		}
		RoleClassifications @class = card_picked.value.suit.toClass();
		List<RoleData> list = (from _r in _snap.board.getRolesInPlayOfClass(card_picked.value.suit.toClass())
			where _r.getAddress() != base.address
			select _r).ToList();
		if (list.Count == 0)
		{
			if (base.has_bad_info)
			{
				said = random.Next(1, 5);
				return getInfo(@class, said);
			}
			said = -1;
			return checkTranslationWithData(loc_empty_info_key, englishEmptyInfo, @class.toString());
		}
		int num = list.Aggregate(-1, (int _a, RoleData _r) => (_a != -1 && _r.getBoardPosition().cardinalDistance(base.board_position) >= _a) ? _a : _r.getBoardPosition().cardinalDistance(base.board_position));
		if (base.has_bad_info)
		{
			said = random.Next(1, 5);
			if (said == num)
			{
				said = said % 4 + 1;
			}
			return getInfo(@class, said);
		}
		said = num;
		return getInfo(@class, num);
	}

	private string getInfo(RoleClassifications _class, int _dist)
	{
		return LocalisationHelper.checkPlural(checkTranslationWithReplace(() => englishInfo(_class.toString(), _dist.ToString()), () => _class.toString(), () => _dist.ToString()), _dist);
	}

	private string englishInfo(string _d1, string _d2)
	{
		return "My closest " + _d1 + " customer is " + _d2 + " step{#/s} away.";
	}

	private string englishEmptyInfo(string _data)
	{
		return "I have no " + _data + " customers.";
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _position.cardinalDistance(base.board_position) == said;
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return string.Format("{0},{1}", said, card_picked.is_some ? CasinoCard.toData(card_picked.value) : "f");
	}
}
