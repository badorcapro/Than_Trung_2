using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class DubiousChef : DocksRoleData
{
	private List<int> tainted_roles = new List<int>();

	public override Roles role => Roles.DUBIOUS_CHEF;

	public override string english_name => "Dubious Chef";

	public override string english_description => "Everytime you move the " + Keywords.BOAT.toString() + " onto an " + TextHelper.innocentRole + ", I " + Keywords.TAINT.toString() + " them if I am not " + TextHelper.revealed + ". If you move the " + Keywords.BOAT.toString() + " onto me, I " + Keywords.REVEAL.toString() + " myself. " + TextHelper.ipretendInPlayInnocent + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "When the " + Keywords.BOAT.toString() + " moves off of a " + Keywords.ROLE.toString() + ", I do not un-" + Keywords.TAINT.toString() + " them."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", I will not " + Keywords.TAINT.toString() + " any " + Keywords.ROLE.toString() + " but I will still " + Keywords.REVEAL.toString() + " myself."));
			return list;
		}
	}

	public override bool hasInfo => !disguise.is_some;

	public override bool has_truth_hover_focus => tainted_roles.Count > 0;

	public DubiousChef(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public DubiousChef(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			tainted_roles = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			tainted_roles = new List<int>();
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.TAINTS);
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getInnocentDisguise(DisguiseTarget.IN_PLAY);
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		return checkTranslation(englishInfo);
	}

	private string englishInfo()
	{
		return "Did you like my soup?";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		if (!disguise.is_some || base.arrested || base.dead)
		{
			return _board;
		}
		if (_new_pos == base.board_position)
		{
			setDisguise(new Maybe<RoleData>());
			resetInfo();
			return _board;
		}
		if (base.tainted)
		{
			return _board;
		}
		Maybe<RoleData> roleAtBoardPosition = _new_pos.getRoleAtBoardPosition(_board);
		if (roleAtBoardPosition.is_some && roleAtBoardPosition.value.getVisualClassification() == RoleClassifications.INNOCENT)
		{
			bool isLyingOrTainted = roleAtBoardPosition.value.getIsLyingOrTainted();
			roleAtBoardPosition.value.setTainted(_new: true);
			tainted_roles.addIfNotDuplicate(roleAtBoardPosition.value.getAddress());
			if (!isLyingOrTainted)
			{
				roleAtBoardPosition.value.resetInfo();
			}
		}
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	public override string getUniqueSaveData()
	{
		return tainted_roles.toStringCommaSeperated();
	}

	public override string getTruthString()
	{
		return ((tainted_roles.Count > 0) ? (TextHelper.taintedManyLocalised(tainted_roles) + "\n") : "") + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return tainted_roles.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}
}
