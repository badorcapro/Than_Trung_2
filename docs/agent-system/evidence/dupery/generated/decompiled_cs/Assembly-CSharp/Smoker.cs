using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Smoker : RoleData, ISpecialLoad
{
	private bool rep_hidden;

	public override Roles role => Roles.SMOKER;

	public override string english_name => "Smoker";

	public override string english_description => TextHelper.underlingRoles + " are not " + TextHelper.revealed + " when " + TextHelper.arrested + ". Your " + Keywords.REPUTATION.toString() + " is hidden. " + TextHelper.iLieAndPretendNotInPlay + ".";

	public override string credits => "Wingidon";

	public override bool hasInfo => false;

	private string loc_hidden_headline_key => $"{role} [hdhd]";

	public Smoker(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Smoker(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		rep_hidden = RoleHelper.tryLoadSingleBoolFromUniqueData(role, _save);
	}

	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseLoaded(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		if (rep_hidden)
		{
			hideReputation();
		}
		return _board;
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.arrested || base.dead || base.tainted)
		{
			return _board;
		}
		hideReputation();
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	private void hideReputation()
	{
		rep_hidden = true;
		if (base.case_ref is ClockCase clockCase)
		{
			clockCase.setHiddenReputation(checkTranslation(loc_hidden_headline_key, englishHiddenHeadline));
		}
		else if (base.case_ref is DocksCase docksCase)
		{
			docksCase.setHiddenReputation(checkTranslation(loc_hidden_headline_key, englishHiddenHeadline));
		}
		else
		{
			Debug.LogError($"Cannot set reputation hidden when in case of type {base.case_ref.case_type}!");
		}
	}

	private string englishHiddenHeadline()
	{
		return "DETECTIVE REPUTATION UNKNOWN!";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (_arrested_address == base.address && !base.case_ref.hasMarkerQuirk(CaseQuirks.HAUNTED))
		{
			undoSmoke();
			return _board;
		}
		if (base.tainted || ((base.arrested || base.dead) && !base.case_ref.hasMarkerQuirk(CaseQuirks.HAUNTED)))
		{
			return _board;
		}
		RoleData roleData = _board.getRolesInPlay()[_arrested_address];
		if (roleData.getVisualClassification() == RoleClassifications.UNDERLING)
		{
			roleData.setOverrideRevealRole(roleData.getVisualRole().role);
		}
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onKillAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _murdered_address, Maybe<RoleData> _killer)
	{
		if (_murdered_address != base.address || base.case_ref.hasMarkerQuirk(CaseQuirks.HAUNTED))
		{
			return _board;
		}
		undoSmoke();
		return base.onKillAction(_board, _payload, _murdered_address, _killer);
	}

	private void undoSmoke()
	{
		rep_hidden = false;
		if (base.case_ref is ClockCase clockCase)
		{
			clockCase.unhideReputation();
		}
		else if (base.case_ref is DocksCase docksCase)
		{
			docksCase.unhideReputation();
		}
		else
		{
			Debug.LogError($"Cannot set reputation hidden when in case of type {base.case_ref.case_type}!");
		}
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getUniqueSaveData()
	{
		if (!rep_hidden)
		{
			return "f";
		}
		return "t";
	}
}
