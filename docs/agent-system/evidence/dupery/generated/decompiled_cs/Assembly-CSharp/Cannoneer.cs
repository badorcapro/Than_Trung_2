using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Cannoneer : DocksRoleData
{
	private List<int> killed = new List<int>();

	public override Roles role => Roles.CANNONEER;

	public override string english_name => "Cannoneer";

	public override string english_description => "When the " + Keywords.BOAT.toString() + " moves into my column or row, I " + Keywords.KILL.toString() + " a random " + Keywords.ROLE.toString() + " in my column or row if possible. " + TextHelper.iLieAndPretendSuspected + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I cannot " + Keywords.KILL.toString() + " myself."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", " + TextHelper.deadOrArrested + ", I never " + Keywords.KILL.toString() + "."));
			return list;
		}
	}

	public override string credits => "Exiliado89";

	public override bool has_truth_hover_focus => killed.Count > 0;

	public override bool hasInfo => false;

	public Cannoneer(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Cannoneer(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		killed = RoleHelper.tryLoadListFromUniqueData(role, _save);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new PositionRoleGC(GCPosition.COLUMN_OR_ROW, DisguiseConstraintType.ALWAYS_IGNORE));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		if (base.tainted || base.dead || base.arrested)
		{
			return _board;
		}
		if (_new_pos.inSameColumnOrRow(base.board_position))
		{
			List<RoleData> list = (from _r in _board.getRolesInColumnOrRow(base.board_position, base.case_ref.board_size)
				where !_r.getIsDead()
				select _r).ToList();
			if (list.Count == 0)
			{
				return _board;
			}
			RoleData randomElementFromList = list.getRandomElementFromList(random);
			base.case_ref.killAddress(randomElementFromList.getAddress(), this);
			killed.Add(randomElementFromList.getAddress());
		}
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
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

	public override string getUniqueSaveData()
	{
		return killed.toStringCommaSeperated();
	}
}
