using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class SerialKiller : ClockRoleData
{
	private const int kill_hour = 9;

	private int next_kill;

	private List<int> killed_targets = new List<int>();

	public override Roles role => Roles.SERIAL_KILLER;

	public override string english_name => "Serial Killer";

	public override string english_description => $"Every {9} hours, I {Keywords.KILL.toString()} an {Keywords.CARDINALLY_ADJACENT.toString()} {TextHelper.goodRole} if possible.\n{TextHelper.iLieAndPretendSuspected}.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I will always be " + Keywords.CARDINALLY_ADJACENT.toString() + " to at least 1 " + TextHelper.goodRole + "."));
			list.Add((DescriptionType.SPECIAL, "When I am " + TextHelper.arrested + ", " + Keywords.DEAD.toString() + " or " + TextHelper.tainted + ", I do not " + Keywords.KILL.toString() + "."));
			return list;
		}
	}

	public override string credits => "Runaway142";

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => killed_targets.Count > 0;

	public SerialKiller(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
		next_kill = 9;
	}

	public SerialKiller(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split('#');
			next_kill = int.Parse(array[0]);
			killed_targets = array[1].fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Problem loading role {role}! ({_save.unique_data}) Error: {arg}");
			next_kill = 9;
			killed_targets = new List<int>();
		}
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new PositionRoleGC(RoleClassifications.INNOCENT, GCPosition.ADJACENT, DisguiseConstraintType.ALWAYS_IGNORE));
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onTimePassedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _rep, int _new_time)
	{
		if (base.tainted || base.dead || base.arrested)
		{
			return _board;
		}
		if (_new_time >= next_kill)
		{
			next_kill += 9;
			List<RoleData> list = (from _r in _board.getAdjacentRolesFromGridPos(base.board_position, base.case_ref.board_size)
				where _r.getVisualAlignment() == Alignments.GOOD && !_r.getIsDead()
				select _r).ToList();
			if (list.Count == 0)
			{
				return _board;
			}
			RoleData randomElementFromList = list.getRandomElementFromList(random);
			base.case_ref.killAddress(randomElementFromList.getAddress(), ((RoleData)this).maybe());
			killed_targets.Add(randomElementFromList.getAddress());
		}
		return base.onTimePassedAction(_board, _rep, _new_time);
	}

	public override string getUniqueSaveData()
	{
		return next_kill + "#" + killed_targets.toStringCommaSeperated();
	}

	public override string getTruthString()
	{
		return ((killed_targets.Count > 0) ? (TextHelper.killedManyLocalised(killed_targets) + "\n") : "") + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return killed_targets.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}

	public override List<RevealLineSettings> getRevealLines(CaseSnapshot _snap)
	{
		if (killed_targets.Count != 0)
		{
			return getRevealLineToTargets(RevealLineColour.RED, _snap, killed_targets);
		}
		return new List<RevealLineSettings>();
	}
}
