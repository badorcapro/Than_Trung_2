using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Introvert : RoleData
{
	public int introvert_num = -1;

	public override Roles role => Roles.INTROVERT;

	public override string english_name => "Introvert";

	public override string english_description => "I pick a " + Keywords.TARGET.toString() + ", I cannot be " + TextHelper.investigated + " until my " + Keywords.TARGET.toString() + " has been " + TextHelper.investigated + ".";

	public override bool hasInfo => false;

	public Introvert(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		introvert_num = int.Parse(_save.unique_data);
	}

	public Introvert(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public override string getTruthString()
	{
		return ((introvert_num == -1) ? "" : (checkTranslationWithData(base.loc_default_truth_key, getTruthEnglish, introvert_num) + "\n")) + base.getTruthString();
	}

	private string getTruthEnglish(string _data)
	{
		return "I couldn't be investigated until #" + _data + " was.";
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getUniqueSaveData()
	{
		return introvert_num.ToString();
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.MEDDLER;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		introvert_num = _board.getRolesInPlay().Keys.Where((int _e) => _e != base.address).ToList().getRandomElementFromList(random);
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	public override bool canBeInvestigated(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		if (base.canBeInvestigated(_board))
		{
			if (!_board.getRolesInPlay()[introvert_num].getIsInvestigated())
			{
				return base.has_bad_info;
			}
			return true;
		}
		return false;
	}
}
