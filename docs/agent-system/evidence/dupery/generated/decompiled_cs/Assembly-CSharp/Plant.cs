using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

public class Plant : ClockRoleData
{
	private static int undercover_time = 18;

	private Roles was_disguised_as = Roles.PLANT;

	private string disguise_name = "";

	public override Roles role => Roles.PLANT;

	public override int execution_order => CaseHelper.LAST_MEDDLER;

	public override string english_name => "Plant";

	public override string english_description => TextHelper.iLieAndPretend + " to be a " + Keywords.ROLE.toString() + " an " + TextHelper.underlingOrTraitorRole + " is " + TextHelper.pretending + " to be. " + $"After the {undercover_time}{undercover_time.getOrdinalSuffix()} hour, I stop {TextHelper.pretending}, {Keywords.REVEAL.toString()} my true identity and {Keywords.ANNOUNCE.toString()} the {Keywords.ROLE.toString()} I was {TextHelper.pretending} to be.";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + " I do not change my behaviour.") };

	public override bool hasInfo => true;

	public override bool can_be_disguise => false;

	private string loc_no_target_info_key => $"{role} [info_nt]";

	public Plant(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Plant(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		was_disguised_as = (Roles)int.Parse(_save.unique_data);
		disguise_name = ((was_disguised_as == Roles.PLANT) ? "" : was_disguised_as.toString());
	}

	protected override bool getEnglishNamePrefixOption()
	{
		return false;
	}

	protected override bool isLiar()
	{
		return true;
	}

	public override string getTruthString()
	{
		if (!(disguise_name == ""))
		{
			return getInfoString();
		}
		return base.getTruthString();
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onDisguiseSet(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		List<RoleData> list = (from _r in _board.getRolesInPlay().Values
			where _r.getVisualClassification().equalToAny(RoleClassifications.TRAITOR, RoleClassifications.UNDERLING)
			where _r.getIsDisguised()
			select _r).ToList();
		if (list.Count == 0)
		{
			disguise_name = "";
			return _board;
		}
		list.shuffle(random);
		RoleData roleData = list[0].getVisualRole().role.createRole(base.address, base.board_position, random, ((RoleData)this).maybe());
		roleData.setTainted(_new: true);
		setDisguise(roleData.maybe());
		disguise_name = roleData.name;
		was_disguised_as = roleData.role;
		return _board.registerRoleChange(base.board_position, this);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onTimePassedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _rep, int _new_time)
	{
		if (_new_time < undercover_time)
		{
			return _board;
		}
		if (!disguise.is_some)
		{
			return _board;
		}
		setDisguise(new Maybe<RoleData>());
		if (base.investigated && !base.dead)
		{
			base.case_ref.checkAddSuspect(role);
		}
		resetInfo();
		return _board.registerRoleChange(base.board_position, this);
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.MEDDLER;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		return getInfoString();
	}

	private string getInfoString()
	{
		if (!(disguise_name == ""))
		{
			return LocalisationHelper.checkOptionIfNotAsian(checkTranslationWithData(getInfoEnglish, disguise_name), was_disguised_as.createEmptyRole().getNamePrefixOption());
		}
		return checkTranslation(loc_no_target_info_key, getNoInfoEnglish);
	}

	private string getInfoEnglish(string _data)
	{
		return "I was pretending to be a{#/n} " + _data + "!";
	}

	private string getNoInfoEnglish()
	{
		return "I couldn't find any targets!";
	}

	public override string getUniqueSaveData()
	{
		int num = (int)was_disguised_as;
		return num.ToString();
	}
}
