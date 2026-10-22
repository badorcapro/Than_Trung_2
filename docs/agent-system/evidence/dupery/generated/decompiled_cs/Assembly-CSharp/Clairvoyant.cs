using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Clairvoyant : RoleData, IHaveSpecialAbility, IHaveAbility
{
	private List<int> unobscured = new List<int>();

	public override Roles role => Roles.CLAIRVOYANT;

	public override string english_name => "Clairvoyant";

	public override string english_description => "I cannot be " + TextHelper.obscured + ".\n" + Keywords.ABILITY.toStringCap() + ": Pick a " + Keywords.ROLE.toString() + " from the " + Keywords.SUSPECT_LIST.toString() + ". I " + TextHelper.unobscure + " every " + Keywords.ROLE.toString() + " whose " + Keywords.APPEARANCE.toString() + " matches the selected " + Keywords.ROLE.toString() + ". I " + Keywords.ANNOUNCE.toString() + " the " + TextHelper.addresses + " of the " + TextHelper.roles + " I " + TextHelper.unobscured + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I can be " + TextHelper.obscured + " and my " + Keywords.ABILITY.toString() + " does not work. My " + TextHelper.announcement + " will be correct."));
			return list;
		}
	}

	public SpecialAbilityType ability_type => SpecialAbilityType.SUSPECT;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	public override bool hasInfo => ability_exhausted;

	private string loc_no_info_key => $"{role} [info_no]";

	public Clairvoyant(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Clairvoyant(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		unobscured = RoleHelper.tryLoadListFromUniqueData(role, _save);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.HAS_ABILITY, new List<AdvancedGenerationConstraint>
		{
			new InPlayRequireRoleGC(RoleGenerationMarkers.OBSCURES, 1, DisguiseConstraintType.NEVER_IGNORE),
			new LeadRequireGC(new List<RoleClassifications>
			{
				RoleClassifications.MEDDLER,
				RoleClassifications.UNDERLING
			}, RoleGenerationMarkers.OBSCURES, 2)
		});
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.has_bad_info)
		{
			return _board;
		}
		setTempObscuredImmunity(this, _true: true);
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	public string getAbilityPrompt()
	{
		return TextHelper.ab_selectASuspectLocalised;
	}

	public void onSpecialAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _user_address, List<AbilityData> _data)
	{
		if (_user_address != base.address || base.has_bad_info)
		{
			return;
		}
		if (_data.Count != 0)
		{
			AbilityData abilityData = _data[0];
			SuspectAbilityData sus_data = abilityData as SuspectAbilityData;
			if (sus_data != null)
			{
				List<RoleData> list = _board.getRolesInPlay().Values.Where((RoleData _r) => _r.getIsObscured() && _r.getVisualAppearance() == sus_data.role).ToList();
				unobscured = new List<int>();
				list.ForEach(delegate(RoleData _r)
				{
					_r.setObscured(_new: false);
					_r.clearTempObscured();
					unobscured.Add(_r.getAddress());
				});
				return;
			}
		}
		Debug.LogError($"{role} special ability data list is empty or not of correct type!");
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (unobscured.Count == 0)
		{
			return checkTranslation(loc_no_info_key, englishNoInfo);
		}
		return checkTranslationWithData(englishInfo, CaseHelper.getSimpleMultiAddress(unobscured));
	}

	private string englishInfo(string _data)
	{
		return "I brightened " + _data + ".";
	}

	private string englishNoInfo()
	{
		return "I found no soul to shine my light on.";
	}

	public override string getUniqueSaveData()
	{
		return unobscured.toStringCommaSeperated();
	}
}
