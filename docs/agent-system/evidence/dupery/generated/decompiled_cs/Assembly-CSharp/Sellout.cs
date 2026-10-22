using System;
using System.Collections.Generic;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Sellout : CasinoRoleData
{
	private static int reward = 20;

	private Maybe<int> made_evil = new Maybe<int>();

	private bool come_clean;

	public override Roles role => Roles.SELLOUT;

	public override string english_name => "Sellout";

	public override string english_description => "I make a " + TextHelper.meddlerRole + " " + Alignments.EVIL.toString() + ". If you " + Keywords.ARREST.toString() + " them while I am " + TextHelper.aliveAndNotArrested + ", I " + Keywords.REVEAL.toString() + " myself and give you " + RoleData.loc_marker_1 + " " + TextHelper.chips_with_link + ".\n" + TextHelper.iLieAndPretendSuspected + ". When I am " + TextHelper.arrested + ", I " + Keywords.ANNOUNCE.toString() + " the identity of the " + Keywords.ROLE.toString() + " I made " + Alignments.EVIL.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "If I find no " + TextHelper.meddlerRole + " to make " + Alignments.EVIL.toString() + ", I will " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_1 + "\" when I am " + TextHelper.arrested + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", I do not make any " + Keywords.ROLE.toString() + " " + Alignments.EVIL.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo
	{
		get
		{
			if (base.arrested || come_clean)
			{
				return !base.dead;
			}
			return false;
		}
	}

	public override bool has_hover_focus
	{
		get
		{
			if (come_clean && !base.dead && !base.obscured)
			{
				return made_evil.is_some;
			}
			return false;
		}
	}

	public override bool has_truth_hover_focus => made_evil.is_some;

	private string loc_solo_info_key => $"{role} [info_solo]";

	private string loc_clean_info_key => $"{role} [info_cln]";

	public Sellout(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Sellout(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			if (array[0] == "f")
			{
				made_evil = new Maybe<int>();
			}
			else
			{
				made_evil = int.Parse(array[0]).maybe();
			}
			come_clean = array[1] == "t";
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}!\nSave: {_save.unique_data}\nError: {arg}");
			made_evil = new Maybe<int>();
			come_clean = false;
		}
	}

	protected override string fillDescription(string _description, CaseSnapshot _snapshot)
	{
		return defaultFillDescription(_description);
	}

	protected override string defaultFillDescription(string _description)
	{
		return _description.Replace(RoleData.loc_marker_1, reward.ToString());
	}

	protected override string fillExtraDescription(string _description, DescriptionType _type)
	{
		if (_type == DescriptionType.SPECIAL)
		{
			return _description.Replace(RoleData.loc_marker_1, checkTranslation(loc_solo_info_key, englishSolo));
		}
		return _description;
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		List<AdvancedGenerationConstraint> list = new List<AdvancedGenerationConstraint>();
		list.Add(new ClassificationRatioGC(RoleClassifications.MEDDLER, 1, DisguiseConstraintType.ALWAYS_IGNORE));
		list.Add(new AvoidSuspectRoleGC(Roles.RECRUITER));
		return new RoleGenerationConstraints(list);
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (come_clean)
		{
			if (!made_evil.is_some)
			{
				Debug.LogError($"Cannot come clean when I did not make any role evil! - {role}");
				return "";
			}
			return checkTranslationWithData(loc_clean_info_key, englishComeClean, made_evil.value);
		}
		if (!made_evil.is_some)
		{
			return checkTranslation(loc_solo_info_key, englishSolo);
		}
		RoleData roleData = _snap.board.getRolesInPlay()[made_evil.value];
		return checkTranslationWithData(englishArrest, roleData.name_coloured);
	}

	private string englishComeClean(string _data)
	{
		return "#" + _data + " is with me.";
	}

	private string englishArrest(string _data)
	{
		return "You'll never find my " + _data + " friend!";
	}

	private string englishSolo()
	{
		return "No one was willing to join me...";
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == made_evil.value;
		}
		return false;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted || base.dead || base.arrested)
		{
			return _board;
		}
		List<RoleData> rolesInPlayOfClass = _board.getRolesInPlayOfClass(RoleClassifications.MEDDLER);
		if (rolesInPlayOfClass.Count == 0)
		{
			return _board;
		}
		RoleData randomElementFromList = rolesInPlayOfClass.getRandomElementFromList(random);
		randomElementFromList.setAlignment(Alignments.EVIL);
		made_evil = randomElementFromList.getAddress().maybe();
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (base.dead || base.tainted)
		{
			return _board;
		}
		if (_arrested_address == base.address && !come_clean)
		{
			override_reveal_role = new Maybe<Roles>();
			setDisguise(new Maybe<RoleData>());
			resetInfo();
			return _board;
		}
		if (base.arrested)
		{
			return _board;
		}
		if (made_evil.is_some && _arrested_address == made_evil.value)
		{
			come_clean = true;
			override_reveal_role = new Maybe<Roles>();
			setDisguise(new Maybe<RoleData>());
			base.casino_case.gainChips(reward);
		}
		return _board;
	}

	public override string getTruthString()
	{
		return (made_evil.is_some ? (TextHelper.madeEvilOneLocalised(made_evil.value) + "\n") : "") + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == made_evil.value;
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return (made_evil.is_some ? made_evil.value.ToString() : "f") + "," + (come_clean ? "t" : "f");
	}
}
