using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class ChatterBox : ClockRoleData
{
	private static int extra_normal = 2;

	public override Roles role => Roles.CHATTER_BOX;

	public override string english_name => "Chatter Box";

	public override string english_description => $"When {TextHelper.investigated} an extra {extra_normal} hours pass. If at least 1 {TextHelper.evilRole} is in the same row as me, an additional extra hour passes.";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)>
	{
		(DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " no extra time passes when you " + Keywords.INVESTIGATE.toString() + " me."),
		(DescriptionType.SPECIAL, "When checking for " + TextHelper.evilRoles + " in my row, I do not check myself.")
	};

	public override bool hasInfo => false;

	public ChatterBox(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public ChatterBox(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.MEDDLER;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onInvestigationAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _investigated_address)
	{
		if (_investigated_address == base.address && !base.has_bad_info)
		{
			int hours_waited = extra_normal + ((_board.getRolesInRow(base.board_position, base.case_ref.board_size, (RoleData _r) => _r.getVisualAlignment() == Alignments.EVIL).Count > 0) ? 1 : 0);
			_board = base.clock_case.waitTime(hours_waited).board;
		}
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
