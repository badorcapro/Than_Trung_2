using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Jellyfish : DocksRoleData
{
	private const int max_hide = 3;

	private List<int> targets = new List<int>();

	public override Roles role => Roles.JELLYFISH;

	public override string english_name => "Jellyfish";

	public override string english_description => $"I {Keywords.HIDE.toString()} up to {3} {TextHelper.innocentRoles}. I might {Keywords.HIDE.toString()}. {TextHelper.iLieAndPretendNotInPlay}.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I have a 50% chance to " + Keywords.HIDE.toString() + ".\nI always " + Keywords.HIDE.toString() + " at least 1 " + TextHelper.innocentRole + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => targets.Count > 0;

	public Jellyfish(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Jellyfish(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			targets = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			targets = new List<int>();
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.HIDES);
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted || base.dead)
		{
			return _board;
		}
		List<RoleData> list = _board.getRolesInPlayOfClass(default(RoleClassifications));
		List<RoleData> list2 = list.Where((RoleData _r) => !_r.getIsHidden()).ToList();
		if (list2.Count > 0)
		{
			list = list2;
		}
		if (list.Count == 0)
		{
			Debug.LogError($"{role} found no innocent to hide!");
			return _board;
		}
		int quant = random.Next(1, Mathf.Min(3, list.Count + 1));
		list.getRandomElementsFromList(random, quant).ForEach(delegate(RoleData _r)
		{
			_r.setHidden(_new: true);
			targets.Add(_r.getAddress());
		});
		if (random.Next(0, 2) == 1)
		{
			base.hidden = true;
		}
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	public override string getTruthString()
	{
		return ((targets.Count == 0) ? "" : (TextHelper.hidManyLocalised(targets) + "\n")) + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return targets.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return targets.toStringCommaSeperated();
	}
}
