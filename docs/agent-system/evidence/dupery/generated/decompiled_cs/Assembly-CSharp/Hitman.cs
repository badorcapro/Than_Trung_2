using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Hitman : ClockRoleData
{
	private const int trigger_hours = 4;

	private int trigger_target = 4;

	private List<int> killed_targets = new List<int>();

	public override Roles role => Roles.HITMAN;

	public override string english_name => "Hitman";

	public override string english_description => $"Every {4} hours, if I am not {TextHelper.arrested} or {Keywords.DEAD.toString()}, I {Keywords.KILL.toString()} one {Keywords.UNINVESTIGATED.toString()} {Keywords.ROLE.toString()}." + "\n" + TextHelper.iLieAndPretendNotInPlay + ".";

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => killed_targets.Count > 0;

	public Hitman(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
		trigger_target = 4;
	}

	public Hitman(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split('#');
			trigger_target = int.Parse(array[0]);
			killed_targets = array[1].fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			trigger_target = 4;
			killed_targets = new List<int>();
		}
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onTimePassedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _rep, int _new_time)
	{
		if (base.tainted || ((base.dead || base.arrested) && !base.case_ref.hasMarkerQuirk(CaseQuirks.HAUNTED)))
		{
			return _board;
		}
		if (_new_time - trigger_target < 0)
		{
			return _board;
		}
		while (_new_time - trigger_target >= 0)
		{
			List<RoleData> list = _board.getRolesInPlay().Values.Where((RoleData _x) => !_x.getIsInvestigated() && !_x.getIsDead() && !_x.getIsArrested()).ToList();
			if (base.case_ref.hasMarkerQuirk(CaseQuirks.DEADLY_AIM))
			{
				list = list.Where((RoleData _e) => _e.getVisualAlignment() == Alignments.GOOD).ToList();
			}
			if (list.Count == 0)
			{
				return _board;
			}
			int num = -1;
			if (base.case_ref.hasMarkerQuirk(CaseQuirks.DEADLY_AIM))
			{
				num = list.getRandomElementFromList(random).getAddress();
				_board = base.case_ref.killAddress(num, ((RoleData)this).maybe()).board;
			}
			else
			{
				num = list.Select((RoleData _e) => (_e: _e, (_e.role.getClassificationFromRoleType() == RoleClassifications.INNOCENT || _e.role.getClassificationFromRoleType() == RoleClassifications.MEDDLER) ? 20 : ((_e.role.getClassificationFromRoleType() != RoleClassifications.UNDERLING) ? 1 : 5))).ToList().weightedChoose(random)
					.value.getAddress();
				_board = base.case_ref.killAddress(num, ((RoleData)this).maybe()).board;
			}
			killed_targets.Add(num);
			trigger_target += 4;
		}
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return trigger_target + "#" + killed_targets.toStringCommaSeperated();
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
