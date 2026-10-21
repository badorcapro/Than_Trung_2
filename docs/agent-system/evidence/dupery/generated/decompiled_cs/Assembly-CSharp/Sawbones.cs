using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Sawbones : RoleData
{
	private int victim = -1;

	public override Roles role => Roles.SAWBONES;

	public override string english_name => "Sawbones";

	public override string english_description => TextHelper.whenInvestigated + ", if your " + Keywords.REPUTATION_STATUS.toString() + " is not " + ReputationStatus.NEUTRAL.toString() + ", I " + Keywords.KILL.toString() + " a random non-" + TextHelper.meddlerRole + ". " + TextHelper.ipretendNotInPlayInnocent + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + " I never " + Keywords.KILL.toString() + ".") };

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => victim > 0;

	public Sawbones(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Sawbones(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		victim = RoleHelper.tryLoadSingleValueFromUniqueData(role, _save);
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getInnocentDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onInvestigationAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _investigated_address)
	{
		if (_investigated_address != base.address || base.tainted || base.dead || base.arrested)
		{
			return _board;
		}
		List<RoleData> list = (from _r in _board.getRolesInPlayOfClass(RoleClassifications.INNOCENT, RoleClassifications.UNDERLING, RoleClassifications.TRAITOR)
			where !_r.getIsDead()
			select _r).ToList();
		if (list.Count == 0)
		{
			return _board;
		}
		if (base.case_ref is ClockCase clockCase)
		{
			if (clockCase.reputation_status != ReputationStatus.NEUTRAL)
			{
				victim = list.getRandomElementFromList(random).getAddress();
				base.case_ref.killAddress(victim, this);
			}
		}
		else if (base.case_ref is DocksCase docksCase)
		{
			if (docksCase.reputation_status != ReputationStatus.NEUTRAL)
			{
				victim = list.getRandomElementFromList(random).getAddress();
				base.case_ref.killAddress(victim, this);
			}
		}
		else
		{
			Debug.LogError($"{role} can no get reputation from case type {base.case_ref.case_type}! Pleas fix this");
		}
		return base.onInvestigationAction(_board, _payload, _investigated_address);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getTruthString()
	{
		if (victim == -1)
		{
			return base.getTruthString();
		}
		return TextHelper.killedOneLocalised(victim) + "\n" + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == victim;
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return victim.ToString();
	}
}
