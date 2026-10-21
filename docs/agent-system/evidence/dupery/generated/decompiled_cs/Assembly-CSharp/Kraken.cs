using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Kraken : DocksRoleData
{
	private static int fuel_lost_on_move_away = 3;

	public override Roles role => Roles.KRAKEN;

	public override string english_name => "Kraken";

	public override string english_description => $"All {TextHelper.roles} that are not on or {TextHelper.adjacentToTheBoat} are {TextHelper.obscured}. If the {Keywords.BOAT.toString()} moves off of me while I am {TextHelper.aliveAndNotArrested}, lose {fuel_lost_on_move_away} {Keywords.FUEL.toString()}." + " " + TextHelper.iLieAndPretendNotInPlay + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, TextHelper.whenIAmArrestedOrKilled + ", I " + TextHelper.unobscure + " all " + TextHelper.roles + " I " + TextHelper.obscured + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public Kraken(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Kraken(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.OBSCURES);
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		return "";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		base.docks_case.doBoatConstructorAction(delegate(DocksBoat _b)
		{
			checkObscures(_board, _b.position);
		});
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		if (base.tainted || ((base.dead || base.arrested) && !base.case_ref.hasMarkerQuirk(CaseQuirks.HAUNTED)))
		{
			return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
		}
		checkObscures(_board, _new_pos);
		if (_old_pos == base.board_position)
		{
			base.docks_case.loseFuel(fuel_lost_on_move_away);
		}
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	private void checkObscures(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Vector2Int _boat_position)
	{
		foreach (KeyValuePair<int, RoleData> item in _board.getRolesInPlay())
		{
			if (item.Value.getBoardPosition().cardinalDistance(_boat_position) <= 1)
			{
				item.Value.setTempObscured(this, _true: false);
			}
			else if (!item.Value.isTempObscureBy(this))
			{
				item.Value.setTempObscured(this, _true: true);
			}
		}
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (_arrested_address == base.address && !base.case_ref.hasMarkerQuirk(CaseQuirks.HAUNTED))
		{
			foreach (KeyValuePair<int, RoleData> item in _board.getRolesInPlay())
			{
				item.Value.setTempObscured(this, _true: false);
			}
		}
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onKillAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _murdered_address, Maybe<RoleData> _killer)
	{
		if (_murdered_address == base.address && !base.case_ref.hasMarkerQuirk(CaseQuirks.HAUNTED))
		{
			foreach (KeyValuePair<int, RoleData> item in _board.getRolesInPlay())
			{
				item.Value.setTempObscured(this, _true: false);
			}
		}
		return base.onKillAction(_board, _payload, _murdered_address, _killer);
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
