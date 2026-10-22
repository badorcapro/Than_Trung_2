using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Publisher : RoleData
{
	private int target = -1;

	private bool regained;

	public override Roles role => Roles.PUBLISHER;

	public override string english_name => "Publisher";

	public override string english_description => "I " + Keywords.ANNOUNCE.toString() + " the " + Keywords.ADDRESS.toString() + " of an " + TextHelper.uninvestigatedGoodRole + ". If they are still " + Keywords.UNINVESTIGATED.toString() + ", " + TextHelper.aliveAndNotArrested + " when you solve the case, regain 1 " + Keywords.REPUTATION.toString() + ". Starts " + TextHelper.investigated;

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I start " + TextHelper.investigated + " even when I am " + TextHelper.lying + " or " + TextHelper.tainted + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTaintIAnnounce + " the " + Keywords.ADDRESS.toString() + " of an " + TextHelper.uninvestigatedEvilRole + "."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public override bool has_hover_focus => target != -1;

	private string loc_no_info_key => $"{role} [noinfo]";

	public Publisher(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Publisher(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			target = int.Parse(array[0]);
			regained = array[1] == "t";
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}!\nData: {_save.unique_data}\nError: {arg}");
			target = -1;
			regained = false;
		}
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		List<KeyValuePair<int, RoleData>> list = _snap.address_occupents.Where((KeyValuePair<int, RoleData> _kvp) => !_kvp.Value.getIsInvestigated() && _kvp.Value.getVisualAlignment() == (Alignments)(base.has_bad_info ? 1 : 0)).ToList();
		if (list.Count == 0)
		{
			return checkTranslation(loc_no_info_key, englishNoInfo);
		}
		target = list.getRandomElementFromList(random).Key;
		return checkTranslationWithData(englishInfo, target);
	}

	private string englishNoInfo()
	{
		return "I have no client.";
	}

	private string englishInfo(string _data)
	{
		return "Please don't bother #" + _data + "!";
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == target;
		}
		return false;
	}

	public override string getTruthString()
	{
		if (!regained)
		{
			return base.getTruthString();
		}
		return checkTranslation(base.loc_default_truth_key, englishTruthRegained) + "\n" + base.getTruthString();
	}

	private string englishTruthRegained()
	{
		return "I gave you back 1 reputation for trusting me!";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		setInvestigatedOuter();
		return _board;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseOverAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, bool _won)
	{
		if (target == -1 || base.has_bad_info || !_won)
		{
			return base.onCaseOverAction(_board, _payload, _won);
		}
		RoleData roleData = _board.getRolesInPlay()[target];
		if (roleData.getIsInvestigated() || roleData.getIsArrested() || roleData.getIsDead())
		{
			return _board;
		}
		if (base.case_ref is ClockCase clockCase)
		{
			clockCase.addReputation(1);
		}
		else if (base.case_ref is DocksCase docksCase)
		{
			docksCase.addReputation(1);
		}
		else
		{
			Debug.LogError($"{role} failed to add reputation as case ref is not of expected type!");
		}
		regained = true;
		return base.onCaseOverAction(_board, _payload, _won);
	}

	public override string getUniqueSaveData()
	{
		return string.Format("{0},{1}", target, regained ? "t" : "f");
	}
}
