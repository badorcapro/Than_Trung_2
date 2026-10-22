using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Barkeep : RoleData
{
	private int target_address = -1;

	private bool force_no_touch;

	public override Roles role => Roles.BARKEEP;

	public override string english_name => "Barkeep";

	public override string english_description => "I " + Keywords.TRANSFORM.toString() + " one " + TextHelper.innocentRole + " into the " + Roles.DRUNKARD.toString() + ".\n" + TextHelper.iLieAndPretendSuspected + ".";

	public override bool hasInfo => false;

	public override int execution_order => CaseHelper.FIRST_IN_ORDER;

	public override bool has_truth_hover_focus => target_address != -1;

	public Barkeep(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Barkeep(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		target_address = int.Parse(_save.unique_data);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new TransformToRoleGC(RoleClassifications.INNOCENT, Roles.DRUNKARD));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.EVIL;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.UNDERLING;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted || force_no_touch)
		{
			return _board;
		}
		RoleData roleData = _board.getRolesInPlay().Values.ToList().Find((RoleData _e) => _e.role == Roles.DRUNKARD);
		if (roleData == null)
		{
			Debug.LogError("COULD NOT FIND ANY DRUNK! Case generation should have failed!");
			target_address = -1;
			return _board;
		}
		target_address = roleData.getAddress();
		return _board;
	}

	public void forceNoTouch(int _pretend_target)
	{
		target_address = _pretend_target;
		force_no_touch = true;
	}

	public override string getUniqueSaveData()
	{
		return $"{target_address}";
	}

	public override string getTruthString()
	{
		return ((target_address == -1) ? "" : (TextHelper.transformedLocalised(target_address, Roles.DRUNKARD) + "\n")) + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == target_address;
		}
		return false;
	}

	public override List<RevealLineSettings> getRevealLines(CaseSnapshot _snap)
	{
		if (target_address != -1)
		{
			return getRevealLineToTarget(target_address, RevealLineColour.YELLOW, _snap);
		}
		return base.getRevealLines(_snap);
	}
}
