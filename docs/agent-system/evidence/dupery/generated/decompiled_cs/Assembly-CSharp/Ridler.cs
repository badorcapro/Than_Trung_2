using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Ridler : RoleData
{
	public override Roles role => Roles.RIDLER;

	public override string english_name => "Ridler";

	public override string english_description => "All " + TextHelper.underlingRoles + " become " + Alignments.GOOD.toString() + ". If any " + TextHelper.goodRoles + " are " + TextHelper.arrested + ", I destroy your " + Keywords.REPUTATION.toString() + ".\n" + TextHelper.iLieAndPretendNotInPlay + ".";

	public override bool hasInfo => false;

	public Ridler(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Ridler(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getTruthString()
	{
		return checkTranslation(base.loc_default_truth_key, getTruthEnglish) + "\n" + base.getTruthString();
	}

	private string getTruthEnglish()
	{
		return "I made all underlings good.";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted || base.dead || base.arrested)
		{
			return _board;
		}
		_board.getRolesInPlay().Values.Where((RoleData _r) => _r.getVisualClassification() == RoleClassifications.UNDERLING).ToList().ForEach(delegate(RoleData _r)
		{
			_r.setAlignment(Alignments.GOOD);
		});
		return _board;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (base.tainted || base.dead || base.arrested)
		{
			return _board;
		}
		if (_board.getRolesInPlay()[_arrested_address].getTrueAlignment() == Alignments.GOOD)
		{
			if (base.case_ref is ClockCase clockCase)
			{
				clockCase.setReputationExternally(0);
			}
			else if (base.case_ref is DocksCase docksCase)
			{
				docksCase.setReputationExternally(0);
			}
			else
			{
				Debug.LogError($"{role} could not set reputation! Not the right type of case!");
			}
		}
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
