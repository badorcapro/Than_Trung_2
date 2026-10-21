using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Marksman : RoleData
{
	public override Roles role => Roles.MARKSMAN;

	public override string english_name => "Marksman";

	public override string english_description => "I " + Keywords.PRETEND.toString() + " to be the " + Roles.VIGILANTE.toString() + ". When using my " + Keywords.ABILITY.toString() + ", I always " + Keywords.KILL.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", I never " + Keywords.KILL.toString() + ".") };

	public override string credits => "DanielDavidGuy";

	public override bool hasInfo => false;

	public Marksman(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Marksman(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new SuspectRequireRoleGC(Roles.VIGILANTE));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return new DisguiseCharacteristics(Roles.VIGILANTE);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (disguise.is_some && disguise.value is Vigilante vigilante)
		{
			vigilante.always_kill = true;
		}
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
