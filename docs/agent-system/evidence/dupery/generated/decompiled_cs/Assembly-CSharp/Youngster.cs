using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Youngster : RoleData
{
	public override Roles role => Roles.YOUNGSTER;

	public override string english_name => "Youngster";

	public override string english_description => "When " + TextHelper.arrested + " reduce your " + Keywords.REPUTATION.toString() + " by twice as much as normal.";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " arresting me causes " + Keywords.REPUTATION.toString() + " to be lost like normal.") };

	public override bool hasInfo => false;

	public Youngster(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Youngster(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
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

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (base.has_bad_info)
		{
			return _board;
		}
		if (_arrested_address == base.address && base.alignment == Alignments.GOOD)
		{
			if (_payload is ClockCaseActionPayload clockCaseActionPayload && base.case_ref is ClockCase clockCase)
			{
				clockCase.setReputationExternally(clockCaseActionPayload.reputation - 2);
			}
			else if (_payload is DocksCaseActionPayload docksCaseActionPayload && base.case_ref is DocksCase docksCase)
			{
				docksCase.setReputationExternally(docksCaseActionPayload.reputation - 2);
			}
			else
			{
				Debug.LogError("Youngster found in a case with no valid payload/case type");
			}
		}
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
