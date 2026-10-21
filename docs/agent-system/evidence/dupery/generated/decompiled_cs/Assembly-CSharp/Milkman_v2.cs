using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Milkman_v2 : ClockRoleData
{
	private int taint_target = -1;

	public override Roles role => Roles.MILKMAN;

	public override string english_name => "Milkman";

	public override string english_description => "I might be " + Alignments.EVIL.toString() + ". If I am, I also " + Keywords.TAINT.toString() + " an " + TextHelper.innocent + " " + TextHelper.adjacentNeighbour + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I have a 50% chance of being " + Alignments.EVIL.toString() + " and " + TextHelper.tainting + " a random " + TextHelper.innocent + " " + TextHelper.adjacentNeighbour + "."));
			list.Add((DescriptionType.SPECIAL, "I always have an " + TextHelper.innocent + " " + TextHelper.adjacentNeighbour + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I do not " + Keywords.TAINT.toString() + " any of my " + TextHelper.adjacentNeighbours + " and my " + Keywords.ALIGNMENT.toString() + " does not change."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public Milkman_v2(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Milkman_v2(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			taint_target = int.Parse(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			taint_target = -1;
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new PositionRoleGC(RoleClassifications.INNOCENT, GCPosition.ADJACENT, DisguiseConstraintType.IGNORE_WHEN_LYING));
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted || base.dead || random.Next(0, 2) == 1)
		{
			return _board;
		}
		List<RoleData> list = (from _r in _board.getAdjacentRolesFromGridPos(base.board_position, base.case_ref.board_size)
			where _r.getVisualClassification() == RoleClassifications.INNOCENT
			select _r).ToList();
		if (list.Count == 0)
		{
			return _board;
		}
		RoleData randomElementFromList = list.getRandomElementFromList(random);
		randomElementFromList.setTainted(_new: true);
		taint_target = randomElementFromList.getAddress();
		setAlignment(Alignments.EVIL);
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	public override string getTruthString()
	{
		if (taint_target == -1)
		{
			return base.getTruthString();
		}
		return checkTranslationWithData(base.loc_default_truth_key, englishEvilTruth, taint_target);
	}

	private string englishEvilTruth(string _data)
	{
		return "I became evil and tainted #" + _data + ".";
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.MEDDLER;
	}

	public override string getUniqueSaveData()
	{
		return $"{taint_target}";
	}
}
