using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Jinx : RoleData
{
	private int target_address = -1;

	public override Roles role => Roles.JINX;

	public override string english_name => "Jinx";

	public override string english_description => TextHelper.whenInvestigated + ", I " + Keywords.OBSCURE.toString() + " the next " + Keywords.ROLE.toString() + " you " + Keywords.INVESTIGATE.toString() + ".\n" + TextHelper.ipretendInPlayInnocent + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I will not " + Keywords.OBSCURE.toString() + " any " + TextHelper.roles + " if I am " + Keywords.DEAD.toString() + " or " + TextHelper.arrested + "."));
			return list;
		}
	}

	public override string credits => "Smile";

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => target_address > 0;

	public Jinx(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Jinx(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			target_address = int.Parse(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading failed! {role}! Error: {arg}");
			target_address = -1;
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.OBSCURES);
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return new DisguiseCharacteristics(DisguiseTarget.IN_PLAY, new List<RoleClassifications> { RoleClassifications.INNOCENT }, new List<Roles>());
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getTruthString()
	{
		return ((target_address != -1) ? (TextHelper.obscuredOneLocalised(target_address) + "\n") : "") + base.getTruthString();
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
		return new List<RevealLineSettings>();
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onInvestigationAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _investigated_address)
	{
		if (!base.investigated || _investigated_address == base.address || target_address != -1 || base.dead || base.arrested || base.has_bad_info)
		{
			return _board;
		}
		target_address = _investigated_address;
		_board.getRolesInPlay()[target_address].setObscured(_new: true);
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return target_address.ToString();
	}
}
