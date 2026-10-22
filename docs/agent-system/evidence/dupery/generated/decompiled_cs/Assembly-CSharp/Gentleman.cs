using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Gentleman : ClockRoleData
{
	private HashSet<int> refreshed_ids;

	public override Roles role => Roles.GENTLEMAN;

	public override string english_name => "Gentleman";

	public override string english_description => "When the " + LocationTypes.CLOCK_TOWER.toString() + " rings, I restore the " + Keywords.ABILITY.toString() + " of one " + TextHelper.innocent + " " + TextHelper.adjacentNeighbour + " with a spent " + Keywords.ABILITY.toString() + " and " + Keywords.ANNOUNCE.toString() + " their " + Keywords.ADDRESS.toString() + " if possible.\nStarts " + TextHelper.investigated + ".\nI add a " + LocationTypes.CLOCK_TOWER.toString() + " on the " + Keywords.BOARD.toString() + " when I am " + Keywords.SUSPECTED.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I always have an " + TextHelper.innocent + " " + TextHelper.adjacentNeighbour + " with an " + Keywords.ABILITY.toString() + "."));
			list.Add((DescriptionType.SPECIAL, "I start " + TextHelper.investigated + " even when I am " + TextHelper.lying + " or " + TextHelper.tainted + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I do not restore anyone's " + Keywords.ABILITY.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => true;

	private string loc_no_hits_key => $"{role} [no_hits]";

	private string loc_hits_key => $"{role} [hit]";

	public Gentleman(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
		refreshed_ids = new HashSet<int>();
	}

	public Gentleman(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		refreshed_ids = JsonUtility.FromJson<HashSet<int>>(_save.unique_data);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new List<AdvancedGenerationConstraint>
		{
			new SuspectLocationGC(LocationTypes.CLOCK_TOWER),
			new PositionRoleGC(RoleClassifications.INNOCENT, RoleGenerationMarkers.HAS_ABILITY, GCPosition.ADJACENT, DisguiseConstraintType.IGNORE_WHEN_LYING)
		});
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a && _occupent.maybe_a.value.getBoardPosition().isAdjacent(_position))
		{
			return _occupent.maybe_a.value.getHasRoleAbility();
		}
		return false;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		setInvestigatedOuter();
		return _board;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onLocationTriggeredAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects, LocationData _location)
	{
		if (_location.location_type == LocationTypes.CLOCK_TOWER && base.investigated && !base.dead && !base.has_bad_info)
		{
			List<RoleData> list = (from _r in _board.getAdjacentRolesFromGridPos(base.board_position, base.case_ref.board_size)
				where _r.getVisualClassification() == RoleClassifications.INNOCENT && _r.getVisualRole().getHasAnyAbility() && _r.getVisualRole().getIsAbilityExhausted()
				select _r).ToList();
			if (list.Count > 0)
			{
				RoleData randomElementFromList = list.getRandomElementFromList(random);
				randomElementFromList.getVisualRole().restoreAbility();
				refreshed_ids.Add(randomElementFromList.getAddress());
				resetInfo();
			}
		}
		return base.onLocationTriggeredAction(_board, _payload, _suspects, _location);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (refreshed_ids.Count != 0)
		{
			return checkTranslationWithData(loc_hits_key, getInfoStringWithHits, CaseHelper.getSimpleMultiAddress(refreshed_ids.ToList()));
		}
		return checkTranslation(loc_no_hits_key, getInfoStringNoHits);
	}

	private string getInfoStringNoHits()
	{
		return "Apologies but my services are not needed at this hour.";
	}

	private string getInfoStringWithHits(string _data)
	{
		return "The folk in " + _data + " have made great use of my services.";
	}

	public override string getUniqueSaveData()
	{
		return JsonUtility.ToJson(refreshed_ids);
	}
}
