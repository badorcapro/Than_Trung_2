using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class ScamArtist : CasinoRoleData
{
	private static int additional_cost = 10;

	public override Roles role => Roles.SCAM_ARTIST;

	public override string english_name => "Scam Artist";

	public override string english_description => $"{TextHelper.iLieAndPretendInPlay} with an {Keywords.ABILITY.toString()}. Using my {Keywords.ABILITY.toString()} will cost an additional {additional_cost} {TextHelper.chips_with_link}.";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTaintedMyBehaviourRemains) };

	public override bool hasInfo => false;

	public ScamArtist(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public ScamArtist(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new InPlayRequireRoleGC(RoleClassifications.INNOCENT, RoleGenerationMarkers.HAS_ABILITY));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return new DisguiseCharacteristics(DisguiseTarget.CUSTOM_IN_PLAY, new List<RoleClassifications>
		{
			RoleClassifications.INNOCENT,
			RoleClassifications.MEDDLER
		}, (RoleData _r) => _r.generation_constraint.isOfMarker(RoleGenerationMarkers.HAS_ABILITY), new List<Roles>());
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address != base.address)
		{
			return _board;
		}
		base.casino_case.spendChips(additional_cost);
		return base.onAbilityUsedAction(_board, _payload, _ability_user_address, _target_addresses);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override bool isLiar()
	{
		return true;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
