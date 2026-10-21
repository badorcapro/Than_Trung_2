using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Submariner : DocksRoleData
{
	public override Roles role => Roles.SUBMARINE;

	public override string english_name => "Submariner";

	public override string english_description => "I " + Keywords.ANNOUNCE.toString() + " how many " + TextHelper.evilRoles + " are " + TextHelper.hidden + ". " + TextHelper.whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString() + " how many " + TextHelper.goodRoles + " are " + TextHelper.hidden + " instead.";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.SPECIAL, TextHelper.iUpdateWhenBoatMoves) };

	public override bool hasInfo => true;

	public Submariner(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Submariner(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new List<AdvancedGenerationConstraint>
		{
			new InPlayRequireRoleGC(RoleGenerationMarkers.HIDES),
			new LeadRequireGC(new List<RoleClassifications>
			{
				RoleClassifications.MEDDLER,
				RoleClassifications.UNDERLING
			}, RoleGenerationMarkers.HIDES, 2)
		});
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		int replace = _snap.board.getRolesInPlay().Count((KeyValuePair<int, RoleData> _r) => _r.Value.getIsHidden() && _r.Value.getVisualAlignment() == ((!base.has_bad_info) ? Alignments.EVIL : Alignments.GOOD));
		return checkTranslationWithPlural(englishInfo, replace);
	}

	private string englishInfo(string _data)
	{
		return _data + " anomal{#y/ies} spotted.";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		if (base.dead)
		{
			return _board;
		}
		resetInfo();
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoleDredgedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, RoleData _dredged, Maybe<RoleData> _dredger)
	{
		if (base.dead)
		{
			return _board;
		}
		resetInfo();
		return base.onRoleDredgedAction(_board, _payload, _dredged, _dredger);
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
