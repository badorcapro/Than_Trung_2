using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Pickpocket : CasinoRoleData
{
	private static int investigation_theft = 10;

	private int stolen_chips;

	private bool chips_returned;

	public override Roles role => Roles.PICKPOCKET;

	public override string english_name => "Pickpocket";

	public override string english_description => $"Whenever you {Keywords.INVESTIGATE.toString()} an {TextHelper.adjacentNeighbour}, I might steal {investigation_theft} {TextHelper.chips_with_link}. {TextHelper.iLieAndPretendSuspected}. " + "When I am " + TextHelper.arrested + ", you regain all the " + Keywords.CHIPS.toString() + " I stole.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I have a 50% chance to steal each time you " + Keywords.INVESTIGATE.toString() + " one of my " + TextHelper.adjacentNeighbours + "."));
			list.Add((DescriptionType.SPECIAL, "If I am " + TextHelper.killed + ", you do not regain any of the stolen " + Keywords.CHIPS.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	private string loc_return_truth_key => $"{role} [truth_return]";

	public Pickpocket(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Pickpocket(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			stolen_chips = int.Parse(array[0]);
			chips_returned = array[1] == "t";
		}
		catch (Exception arg)
		{
			Debug.LogError($"Error occured parsing save data of {role}!\n{arg}");
			stolen_chips = 0;
			chips_returned = false;
		}
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		return "";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onInvestigationAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _investigated_address)
	{
		if (base.tainted || base.dead || base.arrested)
		{
			return _board;
		}
		Dictionary<int, RoleData> rolesInPlay = _board.getRolesInPlay();
		if (!rolesInPlay.ContainsKey(_investigated_address))
		{
			return _board;
		}
		if (rolesInPlay[_investigated_address].getBoardPosition().isAdjacent(base.board_position) && (base.casino_case.hasMarkerQuirk(CaseQuirks.AGILE_FINGERS) || random.Next(0, 2) == 1))
		{
			int chips = base.casino_case.chips;
			base.casino_case.spendChips(investigation_theft);
			stolen_chips += chips - base.casino_case.chips;
		}
		return base.onInvestigationAction(_board, _payload, _investigated_address);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (_arrested_address != base.address || chips_returned || base.tainted)
		{
			return _board;
		}
		chips_returned = true;
		base.casino_case.gainChips(stolen_chips);
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	public override string getUniqueSaveData()
	{
		return string.Format("{0},{1}", stolen_chips, chips_returned ? "t" : "f");
	}

	public override string getTruthString()
	{
		return ((stolen_chips > 0) ? (checkTranslationWithData(base.loc_default_truth_key, stolenTruthEnglish, stolen_chips) + (chips_returned ? (" " + checkTranslation(loc_return_truth_key, returnedTruthEnglish)) : "") + "\n") : "") + base.getTruthString();
	}

	private string stolenTruthEnglish(string _data)
	{
		return "I stole " + _data + TextHelper.chips_sprite_link + "!";
	}

	private string returnedTruthEnglish()
	{
		return "I returned them when you arrested me.";
	}
}
