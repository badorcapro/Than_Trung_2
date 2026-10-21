using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Whale : DocksRoleData
{
	private int role_hidden = -1;

	public override Roles role => Roles.WHALE;

	public override string english_name => "Whale";

	public override string english_description => TextHelper.whenInvestigated + ", I " + Keywords.HIDE.toString() + " a random " + TextHelper.unhidden + " " + TextHelper.goodRole + " if possible. If I am " + TextHelper.lyingOrTainted + ", I " + Keywords.HIDE.toString() + " a random " + TextHelper.unhidden + " " + TextHelper.evilRole + " instead.";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.SPECIAL, "I cannot " + Keywords.HIDE.toString() + " myself.") };

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => role_hidden > 0;

	public Whale(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Whale(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		role_hidden = RoleHelper.tryLoadSingleValueFromUniqueData(role, _save);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.HIDES);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onInvestigationAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _investigated_address)
	{
		if (_investigated_address != base.address || base.dead || base.arrested)
		{
			return _board;
		}
		List<RoleData> list = (from _r in _board.getRolesInPlayOfAlignment(base.has_bad_info ? Alignments.EVIL : Alignments.GOOD)
			where !_r.getIsHidden() && _r.getAddress() != base.address
			select _r).ToList();
		if (list.Count == 0)
		{
			return _board;
		}
		RoleData randomElementFromList = list.getRandomElementFromList(random);
		role_hidden = randomElementFromList.getAddress();
		randomElementFromList.setHidden(_new: true);
		return base.onInvestigationAction(_board, _payload, _investigated_address);
	}

	public override string getTruthString()
	{
		return ((role_hidden > 0) ? (TextHelper.hidOneLocalised(role_hidden) + "\n") : "") + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == role_hidden;
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return role_hidden.ToString();
	}
}
