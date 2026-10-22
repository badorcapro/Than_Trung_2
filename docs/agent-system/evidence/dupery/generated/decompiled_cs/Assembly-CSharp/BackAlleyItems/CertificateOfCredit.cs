using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace BackAlleyItems;

public class CertificateOfCredit : BackAlleysItem, IHaveAbility
{
	private const int starting_usages = 1;

	public override BackAlleysItemType type => BackAlleysItemType.CERTIFICATE_OF_CREDIT;

	public override BackAlleysItemColour colour => BackAlleysItemColour.LAWFUL;

	public override BackAlleysItemCost cost => BackAlleysItemCost.PRICEY;

	protected override string english_name => "Certificate of Credit";

	protected override string english_description => $"Regain 2 {Keywords.HEALTH.toString()}. Has {1} use.";

	public override bool is_active => true;

	public bool abilityExhausted => base.uses_remaining <= 0;

	public int numberTargets => 0;

	public CertificateOfCredit(System.Random _rng, int _usages = -1)
		: base(_rng, (_usages == -1) ? 1 : _usages)
	{
	}

	public string getAbilityPrompt()
	{
		return "";
	}

	public override void useItemAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<AbilityData> _data, BackAlleysCase _case)
	{
		_case.addHealth(2);
		spendUse();
	}

	protected override string getUniqueSaveData()
	{
		return "";
	}
}
