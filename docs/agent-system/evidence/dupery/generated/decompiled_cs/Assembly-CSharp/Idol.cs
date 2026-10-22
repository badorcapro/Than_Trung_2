using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Idol : RoleData
{
	private List<int> tainted_addresses = new List<int>();

	public override Roles role => Roles.IDOL;

	public override string english_name => "Idol";

	public override string english_description => "I " + Keywords.TAINT.toString() + " all " + RoleClassifications.INNOCENT.toString() + " " + Keywords.CA_NEIGHBOURS.toString() + ".\n" + TextHelper.iLieAndPretendNotInPlay + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I will always be " + Keywords.CARDINALLY_ADJACENT.toString() + " to at least 1 " + TextHelper.innocentRole + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => tainted_addresses.Count > 0;

	public Idol(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Idol(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			tainted_addresses = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Could not load {role}!\nSave: {_save.unique_data}\nError: {arg}");
			tainted_addresses = new List<int>();
		}
	}

	protected override bool getEnglishNamePrefixOption()
	{
		return false;
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.TAINTS, new PositionRoleGC(RoleClassifications.INNOCENT, GCPosition.ADJACENT, DisguiseConstraintType.ALWAYS_IGNORE));
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
		return ((tainted_addresses.Count > 0) ? (TextHelper.taintedManyLocalised(tainted_addresses) + "\n") : "") + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return tainted_addresses.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}

	public override List<RevealLineSettings> getRevealLines(CaseSnapshot _snap)
	{
		if (tainted_addresses.Count != 0)
		{
			return getRevealLineToTargets(RevealLineColour.PURPLE, _snap, tainted_addresses);
		}
		return base.getRevealLines(_snap);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted)
		{
			return _board;
		}
		foreach (RoleData item in base.case_ref.hasMarkerQuirk(CaseQuirks.THAT_SMILE) ? _board.getSurroundingRolesFromGridPos(base.board_position, base.case_ref.board_size) : _board.getAdjacentRolesFromGridPos(base.board_position, base.case_ref.board_size))
		{
			if (item.getVisualClassification() == RoleClassifications.INNOCENT)
			{
				item.setTainted(_new: true);
				tainted_addresses.Add(item.getAddress());
			}
		}
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return tainted_addresses.toStringCommaSeperated();
	}
}
