using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

public class Downplayer : RoleData
{
	private List<int> affected_addresses = new List<int>();

	public override Roles role => Roles.DOWNPLAYER;

	public override string english_name => "Downplayer";

	public override string english_description => "All " + TextHelper.traitorRoles + " " + Keywords.REVEAL.toString() + " as " + Keywords.IN_PLAY.toString() + " " + TextHelper.underlingRoles + " when " + TextHelper.arrested + ". " + TextHelper.iLieAndPretendSuspected + ".";

	public override string credits => "ExistingHuman";

	public override bool hasInfo => false;

	public Downplayer(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Downplayer(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			affected_addresses = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Save data could not be parsed! ({_save.unique_data}) | {role} | Error: {arg}");
			affected_addresses = new List<int>();
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new ClassificationRatioGC(RoleClassifications.TRAITOR, 1, DisguiseConstraintType.NEVER_IGNORE));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (base.arrested || base.dead || base.tainted || _arrested_address == base.address)
		{
			return _board;
		}
		Dictionary<int, RoleData> rolesInPlay = _board.getRolesInPlay();
		RoleData roleData = rolesInPlay[_arrested_address];
		if (roleData.getVisualClassification() != RoleClassifications.TRAITOR)
		{
			return _board;
		}
		Roles overrideRevealRole = rolesInPlay.Where((KeyValuePair<int, RoleData> _r) => _r.Value.role.getClassificationFromRoleType() == RoleClassifications.UNDERLING).ToList().getRandomElementFromList(random)
			.Value.role;
		roleData.setOverrideRevealRole(overrideRevealRole);
		affected_addresses.Add(roleData.getAddress());
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getUniqueSaveData()
	{
		return affected_addresses.toStringCommaSeperated();
	}

	public override string getTruthString()
	{
		if (affected_addresses.Count == 0)
		{
			return base.getTruthString();
		}
		return LocalisationHelper.checkOption(checkTranslationWithData(base.loc_default_truth_key, englishTruth, CaseHelper.getSimpleMultiAddress(affected_addresses)), affected_addresses.Count != 1);
	}

	private string englishTruth(string _data)
	{
		return "I made " + _data + " reveal as {#underlings/an underling}.";
	}
}
