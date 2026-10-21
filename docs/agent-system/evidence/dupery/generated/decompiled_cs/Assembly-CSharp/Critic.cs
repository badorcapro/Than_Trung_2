using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Critic : RoleData, IChangeReputation, IChangeReputationStatus
{
	public override Roles role => Roles.CRITIC;

	public override string english_name => "Critic";

	public override string english_description => "You lose twice as much " + Keywords.REPUTATION.toString() + " as normal.\nOthers treat your " + Keywords.REPUTATION_STATUS.toString() + " as " + ReputationStatus.POOR.toString() + ".\n" + TextHelper.iLieAndPretendNotInPlay + ".";

	public override bool hasInfo => false;

	public Critic(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Critic(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public int checkReputationChange(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _rep_change)
	{
		if (_rep_change >= 0 || base.tainted || (!base.case_ref.hasMarkerQuirk(CaseQuirks.HAUNTED) && (base.dead || base.arrested)))
		{
			return _rep_change;
		}
		return _rep_change * 2;
	}

	public ReputationStatus checkVisualReputation(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _reputation, ReputationStatus _current_visual)
	{
		if (!base.tainted && ((!base.arrested && !base.dead) || base.case_ref.hasMarkerQuirk(CaseQuirks.HAUNTED)))
		{
			return ReputationStatus.POOR;
		}
		return _current_visual;
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
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
		return RoleClassifications.TRAITOR;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
