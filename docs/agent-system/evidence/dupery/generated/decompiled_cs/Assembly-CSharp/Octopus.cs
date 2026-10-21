using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Octopus : DocksRoleData
{
	private List<int> remaining = new List<int>();

	public override Roles role => Roles.OCTOPUS;

	public override string english_name => "Octopus";

	public override string english_description => "If I am " + Keywords.ALIVE.toString() + " and you have not " + TextHelper.arrested + " all " + TextHelper.evilRoles + " when you end the " + Keywords.CASE.toString() + ", I escape and ruin your " + Keywords.REPUTATION.toString() + ". " + TextHelper.iLieAndPretendNotInPlay + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I only check for true " + TextHelper.evilRoles + ", meaning I ignore all " + TextHelper.roles + " that appear as " + Alignments.EVIL.toString() + " that are not."));
			return list;
		}
	}

	public override string credits => "5kBird";

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => remaining.Count > 0;

	public Octopus(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Octopus(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		remaining = RoleHelper.tryLoadListFromUniqueData(role, _save);
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
		if (base.tainted || !base.is_true_self)
		{
			return _board;
		}
		base.docks_case.doBoatConstructorAction(delegate(DocksBoat _b)
		{
			_b.max_fuel += 2;
			_b.fuel += 2;
		});
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onPlayerEndAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload)
	{
		if (!base.arrested || base.dead || base.tainted)
		{
			return _board;
		}
		List<RoleData> allNotArrestedOrDeadEvil = _board.getAllNotArrestedOrDeadEvil();
		if (allNotArrestedOrDeadEvil.Count > 0)
		{
			base.arrested = false;
			remaining = allNotArrestedOrDeadEvil.Select((RoleData _r) => _r.getAddress()).ToList();
		}
		return base.onPlayerEndAction(_board, _payload);
	}

	public override string getTruthString()
	{
		return ((remaining.Count > 0) ? checkTranslationWithData(base.loc_default_truth_key, englishTruth, CaseHelper.getSimpleMultiAddress(remaining)) : "") + base.getTruthString();
	}

	private string englishTruth(string _data)
	{
		return "I escaped with the help of " + _data + "!";
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return remaining.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return remaining.toStringCommaSeperated();
	}
}
