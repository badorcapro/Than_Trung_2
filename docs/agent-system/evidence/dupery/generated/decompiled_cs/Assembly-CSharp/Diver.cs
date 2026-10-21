using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

public class Diver : DocksRoleData
{
	private int target = -1;

	private bool forced_target;

	private RoleClassifications claim_class = (RoleClassifications)(-1);

	private Roles claim_role = (Roles)(-1);

	public override Roles role => Roles.DIVER;

	public override string english_name => "Diver";

	public override string english_description => "I pick a " + Keywords.ROLE.toString() + ". If I am on the " + Keywords.BOAT.toString() + ", I " + Keywords.ANNOUNCE.toString() + " the " + Keywords.ADDRESS.toString() + " and identity of my picked " + Keywords.ROLE.toString() + ". Otherwise, I " + Keywords.ANNOUNCE.toString() + " the " + Keywords.CLASSIFICATION.toString() + " of my picked " + Keywords.ROLE.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, TextHelper.iUpdateWhenBoatMoves));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I pick a random " + Keywords.ADDRESS.toString() + " and a random " + TextHelper.suspectedRole + " that is not of the correct " + Keywords.CLASSIFICATION.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => true;

	private string loc_boat_info_key => $"{role} [info_boat]";

	public Diver(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Diver(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			target = int.Parse(array[0]);
			claim_class = (RoleClassifications)int.Parse(array[1]);
			claim_role = (Roles)int.Parse(array[2]);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) | Error: {arg}");
			target = -1;
			claim_class = (RoleClassifications)(-1);
			claim_role = (Roles)(-1);
		}
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (forced_target)
		{
			return _board;
		}
		int count = _board.getRolesInPlay().Count;
		target = random.Next(1, count + 1);
		if (target == base.address)
		{
			target += ((base.address != count) ? 1 : (-1));
		}
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		if (base.dead)
		{
			return _board;
		}
		if (_old_pos == base.board_position || _new_pos == base.board_position)
		{
			resetInfo();
		}
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		RoleData real_role = _snap.address_occupents[target];
		if (base.has_bad_info && claim_class == (RoleClassifications)(-1))
		{
			List<RoleClassifications> list = (from _kvp in _snap.board.getOnBoardRatio(_true_class: true)
				where _kvp.Value > 0 && _kvp.Key != real_role.getVisualClassification()
				select _kvp.Key).ToList();
			list.shuffle(random);
			bool flag = false;
			while (list.Count > 0 && !flag)
			{
				claim_class = list[0];
				List<RoleData> list2 = _snap.true_suspect_list.Where((RoleData _s) => _s.role.getClassificationFromRoleType() == claim_class && _s.role != role && _s.role != real_role.role).ToList();
				if (list2.Count > 0)
				{
					claim_role = list2.getRandomElementFromList(random).role;
					flag = true;
				}
				else
				{
					list.RemoveAt(0);
					Debug.LogError($"Diver could not find valid role of class {claim_class}!");
				}
			}
			if (!flag)
			{
				throw new ArgumentException("Diver could not find any valid lie!???");
			}
		}
		if (_snap.docks_payload.boat.position == base.board_position)
		{
			RoleData empty_claim = (base.has_bad_info ? claim_role.createEmptyRole() : real_role);
			return checkTranslationWithReplace(loc_boat_info_key, () => englishBoatInfo(target.ToString(), empty_claim.english_name), () => target.ToString(), () => empty_claim.name);
		}
		if (base.has_bad_info)
		{
			return LocalisationHelper.checkOption(checkTranslationWithData(englishInfo, claim_class.toStringPlain()), claim_class.getPrefixOption());
		}
		return LocalisationHelper.checkOption(checkTranslationWithData(englishInfo, real_role.getVisualClassification().toStringPlain()), real_role.getVisualClassification().getPrefixOption());
	}

	private string englishInfo(string _data)
	{
		return "I see a{#/n} " + _data + ".";
	}

	private string englishBoatInfo(string _data_1, string _data_2)
	{
		return "#" + _data_1 + " is the " + _data_2 + ".";
	}

	public void createAndForceSetInfo(int _address)
	{
		forced_target = true;
		target = _address;
	}

	public override string getUniqueSaveData()
	{
		return $"{target},{(int)claim_class},{(int)claim_role}";
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.INNOCENT;
	}
}
