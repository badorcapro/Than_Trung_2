using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Scoundrel : RoleData
{
	public override Roles role => Roles.SCOUNDREL;

	public override string english_name => "Scoundrel";

	public override string english_description => "I cannot " + TextHelper.die + " or be " + TextHelper.arrested + " unless I am the only " + Keywords.UNARRESTED.toString() + " and " + Keywords.ALIVE.toString() + " " + Alignments.EVIL.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "Attempting to " + Keywords.ARREST.toString() + " me still passes time."));
			list.Add((DescriptionType.SPECIAL, "I ignore all " + TextHelper.goodRoles + " that appear to be " + Alignments.EVIL.toString() + ". I can always be " + TextHelper.arrested + " or " + TextHelper.killed + " if I am the only true " + Keywords.UNARRESTED.toString() + " and " + Keywords.ALIVE.toString() + " " + Alignments.EVIL.toString() + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, "When I am " + TextHelper.tainted + " I can be " + TextHelper.arrested + " or " + TextHelper.killed + " even when I am not the last " + TextHelper.evilRole + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public Scoundrel(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Scoundrel(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new ClassificationRatioGC(RoleClassifications.UNDERLING, 2, DisguiseConstraintType.ALWAYS_IGNORE));
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.EVIL;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.UNDERLING;
	}

	private bool isLastEvilAlive(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		return _board.getRolesInPlay().Values.Where((RoleData _e) => !_e.getIsArrested() && !_e.getIsDead() && _e.getAddress() != base.address && _e.getTrueAlignment() == Alignments.EVIL && _e.getVisualAlignment() == Alignments.EVIL).Count() == 0;
	}

	public override bool canBeKilled(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		if (!base.tainted)
		{
			return isLastEvilAlive(_board);
		}
		return true;
	}

	public override bool canBeArrested(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		if (!base.tainted)
		{
			return isLastEvilAlive(_board);
		}
		return true;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}

	protected override bool isLiar()
	{
		return false;
	}
}
