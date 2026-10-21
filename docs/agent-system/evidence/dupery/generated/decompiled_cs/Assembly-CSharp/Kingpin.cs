using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Kingpin : RoleData
{
	private int tainted_address = -1;

	private int evil_address = -1;

	public override Roles role => Roles.KINGPIN;

	public override string english_name => "Kingpin";

	public override string english_description => "One " + RoleClassifications.INNOCENT.toString() + " " + TextHelper.surroundingNeighbour + " becomes " + Alignments.EVIL.toString() + ".\nOne " + RoleClassifications.INNOCENT.toString() + " " + TextHelper.surroundingNeighbour + " becomes " + TextHelper.tainted + ".\n" + TextHelper.iLieAndPretendNotInPlay + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "The " + TextHelper.innocent + " I make " + Alignments.EVIL.toString() + " and the " + TextHelper.innocent + " I " + Keywords.TAINT.toString() + " can be same " + Keywords.ROLE.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public Kingpin(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Kingpin(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		string[] array = _save.unique_data.Split(',');
		tainted_address = int.Parse(array[0]);
		evil_address = int.Parse(array[1]);
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.TAINTS, new PositionRoleGC(RoleClassifications.INNOCENT, GCPosition.SURROUNDING, DisguiseConstraintType.ALWAYS_IGNORE));
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getTruthString()
	{
		if (tainted_address != -1 && evil_address != -1)
		{
			return checkTranslationWithReplace(base.loc_default_truth_key, () => getTruthEnglish(tainted_address.ToString(), evil_address.ToString()), tainted_address, evil_address) + "\n" + base.getTruthString();
		}
		return base.getTruthString();
	}

	private string getTruthEnglish(string _data, string _data_2)
	{
		return "I tainted #" + _data + " and made #" + _data_2 + " evil.";
	}

	public override List<RevealLineSettings> getRevealLines(CaseSnapshot _snap)
	{
		if (evil_address == tainted_address)
		{
			if (evil_address == -1)
			{
				return base.getRevealLines(_snap);
			}
			return getRevealLineToTarget(evil_address, RevealLineColour.BLACK, _snap);
		}
		List<RevealLineSettings> list = new List<RevealLineSettings>();
		if (evil_address != -1)
		{
			list.AddRange(getRevealLineToTarget(evil_address, RevealLineColour.RED, _snap));
		}
		if (tainted_address != -1)
		{
			list.AddRange(getRevealLineToTarget(tainted_address, RevealLineColour.PURPLE, _snap));
		}
		return list;
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
		List<RoleData> list = (from _e in _board.getSurroundingRolesFromGridPos(base.board_position, base.case_ref.board_size)
			where _e.getVisualClassification() == RoleClassifications.INNOCENT
			select _e).ToList();
		if (list.Count != 0)
		{
			RoleData randomElementFromList = list.getRandomElementFromList(random);
			randomElementFromList.setTainted(_new: true);
			tainted_address = randomElementFromList.getAddress();
			RoleData randomElementFromList2 = list.getRandomElementFromList(random);
			randomElementFromList2.setAlignment(Alignments.EVIL);
			evil_address = randomElementFromList2.getAddress();
		}
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return $"{tainted_address},{evil_address}";
	}
}
