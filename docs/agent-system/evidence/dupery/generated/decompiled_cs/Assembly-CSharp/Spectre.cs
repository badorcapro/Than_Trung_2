using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Spectre : RoleData
{
	private int target_address = -1;

	private bool forced;

	public override Roles role => Roles.SPECTRE;

	public override string english_name => "Spectre";

	public override string english_description => "I " + Keywords.OBSCURE.toString() + " one non-" + TextHelper.meddlerRole + " hiding its name, appearance, and information. Numbers are not " + TextHelper.obscured + ". \n" + TextHelper.iLieAndPretendSuspected + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I can " + Keywords.OBSCURE.toString() + " myself."));
			list.Add((DescriptionType.LYING_OR_TAINTED, "When I am " + TextHelper.tainted + " I do not " + Keywords.OBSCURE.toString() + " my " + Keywords.TARGET.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => target_address > 0;

	public Spectre(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Spectre(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		target_address = int.Parse(_save.unique_data);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.OBSCURES);
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getTruthString()
	{
		return ((target_address == -1) ? "" : (TextHelper.obscuredOneLocalised(target_address) + "\n")) + base.getTruthString();
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
			return getRevealLineToTarget(target_address, RevealLineColour.BLACK, _snap);
		}
		return base.getRevealLines(_snap);
	}

	public void forceTargetAddress(int _target)
	{
		target_address = _target;
		forced = true;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted)
		{
			return _board;
		}
		if (forced)
		{
			_board.getRolesInPlay()[target_address].setObscured(_new: true);
			return _board;
		}
		RoleData randomElementFromList = _board.getRolesInPlay().Values.Where((RoleData _e) => _e.role.getClassificationFromRoleType() != RoleClassifications.MEDDLER).ToList().getRandomElementFromList(random);
		randomElementFromList.getVisualRole().setObscured(_new: true);
		target_address = randomElementFromList.getAddress();
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return $"{target_address}";
	}
}
