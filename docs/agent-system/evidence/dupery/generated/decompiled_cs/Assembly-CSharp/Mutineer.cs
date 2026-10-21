using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Quirks;
using Save;
using UnityEngine;

public class Mutineer : DocksRoleData
{
	public override Roles role => Roles.MUTINEER;

	public override string english_name => "Mutineer";

	public override string english_description => TextHelper.whenInvestigated + ", I move the " + Keywords.BOAT.toString() + " away from me if possible. I cannot be " + TextHelper.arrested + " unless I am the only " + Keywords.UNARRESTED.toString() + " and " + Keywords.ALIVE.toString() + " " + Alignments.EVIL.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, Keywords.FUEL.toStringCap() + " is used as usual when I move the " + Keywords.BOAT.toString() + "."));
			list.Add((DescriptionType.SPECIAL, "I ignore all " + TextHelper.goodRoles + " that appear to be " + Alignments.EVIL.toString() + ". I can always be " + TextHelper.arrested + " if I am the only true " + Keywords.UNARRESTED.toString() + " and " + Keywords.ALIVE.toString() + " " + Alignments.EVIL.toString() + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", I do not move the " + Keywords.BOAT.toString() + " and I can be " + TextHelper.arrested + " even when I am not the last " + TextHelper.evilRole + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public Mutineer(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Mutineer(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		List<AdvancedGenerationConstraint> list = new List<AdvancedGenerationConstraint>();
		list.Add(new AvoidSuspectRoleGC(Roles.SCOUNDREL));
		list.Add(new ClassificationRatioGC(RoleClassifications.UNDERLING, 2, DisguiseConstraintType.ALWAYS_IGNORE));
		return new RoleGenerationConstraints(list);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onInvestigationAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _investigated_address)
	{
		if (base.arrested || base.dead || base.tainted || base.docks_case.hasMarkerQuirk(CaseQuirks.SILENT_MUTINY))
		{
			return _board;
		}
		if (_investigated_address == base.address)
		{
			int distance = base.board_position.cardinalDistance(base.docks_case.boat.position);
			List<Vector2Int> list = (from _p in base.docks_case.boat.position.getCardinalNeighboursFromPositionWithinGrid(base.case_ref.board_size)
				where _p.cardinalDistance(base.board_position) >= distance
				select _p).ToList();
			if (list.Count == 0)
			{
				return _board;
			}
			base.docks_case.moveBoatExternally(list.getRandomElementFromList(random));
		}
		return base.onInvestigationAction(_board, _payload, _investigated_address);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		if (!base.docks_case.hasMarkerQuirk(CaseQuirks.SILENT_MUTINY) || _new_pos != base.board_position || base.tainted || base.dead)
		{
			return _board;
		}
		Maybe<CaseQuirkData> maybe = base.docks_case.active_quirks.firstIfSome((CaseQuirkData _q) => _q is SilentMutiny);
		if (!maybe.is_some)
		{
			Debug.LogError("Has silent mutiny quirk but could not find it in the active quirks list!");
			return _board;
		}
		if (maybe.value.quirk_completed)
		{
			return _board;
		}
		base.docks_case.moveBoatExternally(base.board_position.getAdjacentPositionsOnBoard(base.docks_case.board_size).getRandomElementFromList(random));
		setDisguise(new Maybe<RoleData>());
		(maybe.value as SilentMutiny).setCompleted();
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	private bool isLastEvilAlive(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		return _board.getRolesInPlay().Values.Where((RoleData _e) => !_e.getIsArrested() && !_e.getIsDead() && _e.getAddress() != base.address && _e.getTrueAlignment() == Alignments.EVIL && _e.getVisualAlignment() == Alignments.EVIL).Count() == 0;
	}

	public override bool canBeArrested(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		if (!base.tainted)
		{
			return isLastEvilAlive(_board);
		}
		return true;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}

	protected override bool isLiar()
	{
		return false;
	}
}
