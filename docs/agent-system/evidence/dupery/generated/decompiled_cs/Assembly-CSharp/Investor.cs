using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Investor : CasinoRoleData
{
	private List<int> tainted_roles = new List<int>();

	public override Roles role => Roles.INVESTOR;

	public override string english_name => "Investor";

	public override string english_description => "I add a " + LocationTypes.SLOT_MACHINE.toString() + " on the " + Keywords.BOARD.toString() + ". I " + Keywords.TAINT.toString() + " a random number of " + TextHelper.innocentRoles + " " + Keywords.SURROUNDING.toString() + " the " + LocationTypes.SLOT_MACHINE.toString() + ". " + TextHelper.iLieAndPretendNotInPlay + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I can " + Keywords.TAINT.toString() + " any number of " + TextHelper.innocentRoles + " " + Keywords.SURROUNDING.toString() + " the " + LocationTypes.SLOT_MACHINE.toString() + ", including all and none of them."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => tainted_roles.Count > 0;

	private string loc_slot_info_key => $"{role} [slot_info]";

	public Investor(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Investor(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			tainted_roles = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! Error: {arg}");
			tainted_roles = new List<int>();
		}
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.TAINTS, new InPlayLocationGC(LocationTypes.SLOT_MACHINE, DisguiseConstraintType.NEVER_IGNORE));
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted || base.arrested || base.dead)
		{
			return _board;
		}
		Dictionary<LocationTypes, LocationData> locationsInPlay = _board.getLocationsInPlay();
		if (!locationsInPlay.ContainsKey(LocationTypes.SLOT_MACHINE))
		{
			Debug.LogError($"{role} with no {LocationTypes.SLOT_MACHINE}! This should not be possible!");
			return _board;
		}
		tainted_roles = new List<int>();
		List<RoleData> list = (from _r in _board.getSurroundingRolesFromGridPos(locationsInPlay[LocationTypes.SLOT_MACHINE].getBoardPosition(), base.case_ref.board_size)
			where _r.getVisualClassification() == RoleClassifications.INNOCENT
			select _r).ToList();
		int num = ((list.Count != 0) ? random.Next(0, list.Count + 1) : 0);
		if (num == 0)
		{
			return _board;
		}
		List<RoleData> randomElementsFromList = list.getRandomElementsFromList(random, num);
		randomElementsFromList.ForEach(delegate(RoleData _t)
		{
			_t.setTainted(_new: true);
		});
		tainted_roles = randomElementsFromList.Select((RoleData _r) => _r.getAddress()).ToList();
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	public string getNumberTainted()
	{
		return checkTranslationWithData(loc_slot_info_key, englishNumberTainted, tainted_roles.Count);
	}

	private string englishNumberTainted(string _data)
	{
		return "I had " + _data + " players.";
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getTruthString()
	{
		return ((tainted_roles.Count > 0) ? (TextHelper.taintedManyLocalised(tainted_roles) + "\n") : "") + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return tainted_roles.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return tainted_roles.toStringCommaSeperated();
	}
}
