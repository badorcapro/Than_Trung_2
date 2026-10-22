using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Turncoat : DocksRoleData
{
	private bool became_evil_from_boat;

	public override Roles role => Roles.TURNCOAT;

	public override string english_name => "Turncoat";

	public override string english_description => TextHelper.ipretendInPlayInnocent + ". When the " + Keywords.BOAT.toString() + " is moved onto me, I become " + Alignments.EVIL.toString() + ". If I am " + Alignments.EVIL.toString() + ", " + TextHelper.aliveAndNotArrested + " when you end the " + Keywords.CASE.toString() + ", you lose 1 " + Keywords.REPUTATION.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", I do not become " + Alignments.EVIL.toString() + ".") };

	public override bool hasInfo => false;

	public Turncoat(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Turncoat(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		became_evil_from_boat = RoleHelper.tryLoadSingleBoolFromUniqueData(role, _save);
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getInnocentDisguise(DisguiseTarget.IN_PLAY);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		if (_new_pos != base.board_position || base.tainted || base.dead || base.arrested || base.alignment == Alignments.EVIL)
		{
			return _board;
		}
		setAlignment(Alignments.EVIL);
		became_evil_from_boat = true;
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onPlayerEndAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload)
	{
		if (base.alignment != Alignments.EVIL || base.arrested || base.dead || base.tainted)
		{
			return _board;
		}
		base.docks_case.setReputationExternally(base.docks_case.reputation - 1);
		return base.onPlayerEndAction(_board, _payload);
	}

	public override string getTruthString()
	{
		return (became_evil_from_boat ? (checkTranslation(base.loc_default_truth_key, englishTruth) + "\n") : "") + base.getTruthString();
	}

	private string englishTruth()
	{
		return "I became " + Alignments.EVIL.toString() + " when the boat was moved onto me.";
	}

	public override string getUniqueSaveData()
	{
		if (!became_evil_from_boat)
		{
			return "f";
		}
		return "t";
	}
}
