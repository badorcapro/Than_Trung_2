using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Recruiter : RoleData
{
	public override Roles role => Roles.RECRUITER;

	public override string english_name => "Recruiter";

	public override string english_description => "I make all " + TextHelper.meddlerRoles + " " + Alignments.EVIL.toString() + ".\n" + TextHelper.iLieAndPretendNotInPlay + ".";

	public override string credits => "Smile";

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => true;

	public Recruiter(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Recruiter(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new InPlayClassificationRatioGC(RoleClassifications.MEDDLER, 1, DisguiseConstraintType.ALWAYS_IGNORE));
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getTruthString()
	{
		return checkTranslation(base.loc_default_truth_key, getTruthEnglish) + "\n" + base.getTruthString();
	}

	private string getTruthEnglish()
	{
		return "I made all meddlers evil.";
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getVisualClassification() == RoleClassifications.MEDDLER;
		}
		return false;
	}

	public override List<RevealLineSettings> getRevealLines(CaseSnapshot _snap)
	{
		List<KeyValuePair<int, RoleData>> list = _snap.address_occupents.Where((KeyValuePair<int, RoleData> _kvp) => _kvp.Value.getVisualClassification() == RoleClassifications.MEDDLER).ToList();
		if (list.Count == 0)
		{
			return base.getRevealLines(_snap);
		}
		return getRevealLineToTargets(RevealLineColour.RED, _snap, list.Select((KeyValuePair<int, RoleData> _m) => _m.Key).ToList());
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.EVIL;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.TRAITOR;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted)
		{
			return _board;
		}
		_board.getRolesInPlay().Values.Where((RoleData _r) => _r.getVisualClassification() == RoleClassifications.MEDDLER).ToList().ForEach(delegate(RoleData _r)
		{
			_r.setAlignment(Alignments.EVIL);
		});
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
