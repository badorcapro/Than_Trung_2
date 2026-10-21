using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Milkman : ClockRoleData
{
	private int hour_trigger = 24;

	private bool triggered;

	public override Roles role => Roles.MILKMAN;

	public override string english_name => "Milkman";

	public override string english_description => $"After the {hour_trigger}th hour I become {Alignments.EVIL.toString()}.";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I do not change my " + Keywords.ALIGNMENT.toString() + " after the 24th hour.") };

	public override bool hasInfo => false;

	public Milkman(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Milkman(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getTruthString()
	{
		if (!triggered)
		{
			return base.getTruthString();
		}
		return checkTranslation(base.loc_default_truth_key, getTruthEnglish);
	}

	private string getTruthEnglish()
	{
		return "I became evil when midnight struck!";
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.MEDDLER;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onTimePassedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _rep, int _new_time)
	{
		if (_new_time >= hour_trigger && !base.has_bad_info && !triggered && !base.arrested && !base.dead && base.alignment != Alignments.EVIL)
		{
			triggered = true;
			base.alignment = Alignments.EVIL;
			if (!base.is_true_self)
			{
				true_self.value.setAlignment(Alignments.EVIL);
			}
		}
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
