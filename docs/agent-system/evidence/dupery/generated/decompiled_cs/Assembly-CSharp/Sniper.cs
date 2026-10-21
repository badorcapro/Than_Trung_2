using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Sniper : ClockRoleData
{
	private List<int> killed = new List<int>();

	public override Roles role => Roles.SNIPER;

	public override string english_name => "Sniper";

	public override string english_description => "When the " + LocationTypes.CLOCK_TOWER.toString() + " rings, I " + Keywords.KILL.toString() + " the furthest " + TextHelper.aliveAndNotArrested + " " + Keywords.ROLE.toString() + " from me. \nI am " + Keywords.CARDINALLY_ADJACENT.toString() + " to the " + LocationTypes.CLOCK_TOWER.toString() + ".\n" + TextHelper.iLieAndPretendSuspected + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I add a " + LocationTypes.CLOCK_TOWER.toString() + " to the " + Keywords.BOARD.toString() + " when I am " + Keywords.SUSPECTED.toString() + "."));
			list.Add((DescriptionType.SPECIAL, "I cannot " + Keywords.KILL.toString() + " myself."));
			list.Add((DescriptionType.SPECIAL, "When I am " + TextHelper.arrested + ", " + Keywords.DEAD.toString() + " or " + TextHelper.tainted + ", I do not " + Keywords.KILL.toString() + "."));
			return list;
		}
	}

	public override string credits => "Exiliado89, NotSoDogNinja";

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => killed.Count > 0;

	public Sniper(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Sniper(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			killed = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Problem loading role {role}! ({_save.unique_data}) Error: {arg}");
			killed = new List<int>();
		}
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new List<AdvancedGenerationConstraint>
		{
			new SuspectLocationGC(LocationTypes.CLOCK_TOWER),
			new PositionLocationGC(LocationTypes.CLOCK_TOWER, GCPosition.ADJACENT, DisguiseConstraintType.ALWAYS_IGNORE)
		});
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onLocationTriggeredAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects, LocationData _location)
	{
		if (_location.location_type != LocationTypes.CLOCK_TOWER || base.tainted || base.dead || base.arrested)
		{
			return _board;
		}
		List<RoleData> item = (from _r in _board.getRolesInPlay()
			where _r.Key != base.address && !_r.Value.getIsArrested() && !_r.Value.getIsDead()
			select _r).Aggregate((new List<RoleData>(), 0), delegate((List<RoleData>, int) _a, KeyValuePair<int, RoleData> _r)
		{
			int num = _r.Value.getBoardPosition().cardinalDistance(base.board_position);
			if (_a.Item1.Count > 0)
			{
				if (_a.Item2 > num)
				{
					return _a;
				}
				if (_a.Item2 == num)
				{
					return (_a.Item1.add(_r.Value), _a.Item2);
				}
			}
			return (_r.Value.makeListFromItem(), num);
		}).Item1;
		if (item.Count == 0)
		{
			killed.Add(-2);
			Debug.Log("Sniper found no valid target.");
			return base.onLocationTriggeredAction(_board, _payload, _suspects, _location);
		}
		RoleData randomElementFromList = item.getRandomElementFromList(random);
		killed.Add(randomElementFromList.getAddress());
		base.case_ref.killAddress(randomElementFromList.getAddress(), ((RoleData)this).maybe());
		return base.onLocationTriggeredAction(_board, _payload, _suspects, _location);
	}

	public override string getUniqueSaveData()
	{
		return killed.toStringCommaSeperated();
	}

	public override string getTruthString()
	{
		return ((killed.Count > 0) ? (TextHelper.killedManyLocalised(killed) + "\n") : "") + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return killed.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}
}
