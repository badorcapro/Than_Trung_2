using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Showstealer : RoleData
{
	public override Roles role => Roles.SHOWSTEALER;

	public override string english_name => "Showstealer";

	public override string english_description => $"I hide every other {TextHelper.meddlerRole} from the {Keywords.SUSPECT_LIST}. Other {TextHelper.roles} cannot {Keywords.PRETEND.toString()} to be me.";

	public override string credits => "Proger10ias";

	public override bool can_be_disguise => false;

	public override bool hasInfo => false;

	public Showstealer(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Showstealer(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new ClassificationRatioGC(RoleClassifications.MEDDLER, 2, DisguiseConstraintType.NEVER_IGNORE));
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		base.case_ref.removeFromVisualSuspectList((Roles _r) => _r != role && _r.getClassificationFromRoleType() == RoleClassifications.MEDDLER);
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.MEDDLER;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
