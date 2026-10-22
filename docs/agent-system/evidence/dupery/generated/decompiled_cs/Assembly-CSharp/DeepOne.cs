using System;
using System.Collections.Generic;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class DeepOne : DocksRoleData
{
	private List<int> tainted_roles = new List<int>();

	private int hidden_role = -1;

	public override Roles role => Roles.DEEP_ONE;

	public override string english_name => "Deep One";

	public override string english_description => "I " + Keywords.HIDE.toString() + " a random " + TextHelper.innocentRole + " and " + Keywords.TAINT.toString() + " all " + TextHelper.hidden + " " + TextHelper.innocentRoles + " at the start of a " + Keywords.CASE.toString() + ". " + TextHelper.iLieAndPretendSuspected + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", I do not " + Keywords.HIDE.toString() + " or " + Keywords.TAINT.toString() + " any " + Keywords.ROLE.toString() + "."));
			return list;
		}
	}

	public override int execution_order => CaseHelper.LAST_MEDDLER - 1;

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus
	{
		get
		{
			if (tainted_roles.Count <= 0)
			{
				return hidden_role > 0;
			}
			return true;
		}
	}

	public DeepOne(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public DeepOne(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split('#');
			tainted_roles = array[0].fromStringCommaSeperate();
			hidden_role = int.Parse(array[1]);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}!\nSave: {_save.unique_data}\nError: {arg}");
			tainted_roles = new List<int>();
			hidden_role = -1;
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.HIDES, RoleGenerationMarkers.TAINTS);
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAfterDisguiseAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted || base.arrested || base.dead)
		{
			return _board;
		}
		List<RoleData> rolesInPlayOfClass = _board.getRolesInPlayOfClass(default(RoleClassifications));
		RoleData randomElementFromList = rolesInPlayOfClass.getRandomElementFromList(random);
		randomElementFromList.setHidden(_new: true);
		hidden_role = randomElementFromList.getAddress();
		foreach (RoleData item in rolesInPlayOfClass)
		{
			if (item.getIsHidden())
			{
				item.setTainted(_new: true);
				tainted_roles.Add(item.getAddress());
			}
		}
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	public override string getTruthString()
	{
		return ((hidden_role > 0) ? (TextHelper.hidOneLocalised(hidden_role) + " ") : "") + ((tainted_roles.Count > 0) ? (TextHelper.taintedManyLocalised(tainted_roles) + "\n") : "") + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			if (!tainted_roles.Contains(_occupent.maybe_a.value.getAddress()))
			{
				return _occupent.maybe_a.value.getAddress() == hidden_role;
			}
			return true;
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return $"{tainted_roles.toStringCommaSeperated()}#{hidden_role}";
	}
}
