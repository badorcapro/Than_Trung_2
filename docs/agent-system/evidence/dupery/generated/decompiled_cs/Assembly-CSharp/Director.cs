using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Director : RoleData
{
	private Roles said_role = (Roles)(-1);

	private Maybe<(int, Roles)> estimated_transformation = new Maybe<(int, Roles)>();

	public override Roles role => Roles.DIRECTOR;

	public override string english_name => "Director";

	public override string english_description => "I " + Keywords.TRANSFORM.toString() + " a " + Keywords.SURROUNDING.toString() + " " + TextHelper.innocentRole + " into a " + TextHelper.notInPlayMeddlerRole + ". " + TextHelper.whenInvestigatedIAnnounce + " the identity of a " + Keywords.SURROUNDING.toString() + " " + TextHelper.meddlerRole + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "Roles".asKeyword(Keywords.ROLE) + " that " + Keywords.PRETEND.toString() + " to be me do not " + Keywords.TRANSFORM.toString() + " any " + Keywords.ROLE.toString() + " even if " + Keywords.TRUTHFUL.toString() + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, "I " + Keywords.TRANSFORM.toString() + " a " + Keywords.ROLE.toString() + " even if I am " + TextHelper.tainted + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTaintIAnnounce + " a " + TextHelper.suspectedMeddlerRole + " that is not " + Keywords.SURROUNDING.toString() + " me."));
			return list;
		}
	}

	public override string credits => "Exiliado89";

	public override bool hasInfo => true;

	public override bool has_hover_focus => said_role != (Roles)(-1);

	public override bool has_truth_hover_focus => estimated_transformation.is_some;

	private string loc_no_info_key => $"{role} [info_no]";

	public Director(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Director(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			said_role = (Roles)int.Parse(array[0]);
			if (array[1] == "f")
			{
				estimated_transformation = new Maybe<(int, Roles)>();
			}
			else
			{
				estimated_transformation = (int.Parse(array[1]), (Roles)int.Parse(array[2])).maybe();
			}
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}!\nSave: {_save.unique_data}\nError: {arg}");
			said_role = (Roles)(-1);
			estimated_transformation = new Maybe<(int, Roles)>();
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		List<AdvancedGenerationConstraint> list = new List<AdvancedGenerationConstraint>();
		list.Add(new TransformToClassPositionedGC(role, RoleClassifications.INNOCENT, RoleClassifications.MEDDLER, GCPosition.SURROUNDING));
		list.Add(new AvoidSuspectRoleGC(Roles.BARKEEP));
		return new RoleGenerationConstraints(list);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (base.has_bad_info)
		{
			List<RoleData> surrounding_roles = _snap.board.getSurroundingRolesFromGridPos(base.board_position, base.case_ref.board_size);
			List<RoleData> list = _snap.true_suspect_list.Where((RoleData _s) => !surrounding_roles.Any((RoleData _rd) => _rd.role == _s.role) && _s.getTrueClassification() == RoleClassifications.MEDDLER).ToList();
			if (list.Count == 0)
			{
				Debug.LogError($"{role} is lying but there is no suspected meddler role that is not surrounding this role!");
				return checkTranslation(loc_no_info_key, englishNoInfo);
			}
			RoleData randomElementFromList = list.getRandomElementFromList(random);
			said_role = randomElementFromList.role;
			return checkTranslationWithData(englishInfo, randomElementFromList.name_coloured);
		}
		List<RoleData> list2 = (from _r in _snap.board.getSurroundingRolesFromGridPos(base.board_position, base.case_ref.board_size)
			where _r.getVisualClassification() == RoleClassifications.MEDDLER
			select _r).ToList();
		if (list2.Count == 0)
		{
			return checkTranslation(loc_no_info_key, englishNoInfo);
		}
		RoleData randomElementFromList2 = list2.getRandomElementFromList(random);
		said_role = randomElementFromList2.role;
		return checkTranslationWithData(englishInfo, randomElementFromList2.name_coloured);
	}

	private string englishInfo(string _d1)
	{
		return "I talked to the " + _d1 + ".";
	}

	private string englishNoInfo()
	{
		return "I've spoken with no one.";
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a && _occupent.maybe_a.value.getIsInvestigated() && !_occupent.maybe_a.value.getIsObscured())
		{
			return _occupent.maybe_a.value.getVisualAppearance() == said_role;
		}
		return false;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (!base.is_true_self)
		{
			return _board;
		}
		List<RoleData> list = (from _r in _board.getSurroundingRolesFromGridPos(base.board_position, base.case_ref.board_size)
			where _r.getTrueClassification() == RoleClassifications.MEDDLER
			select _r).ToList();
		if (list.Count == 0)
		{
			return _board;
		}
		RoleData randomElementFromList = list.getRandomElementFromList(random);
		estimated_transformation = (randomElementFromList.getAddress(), randomElementFromList.role).maybe();
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	public override string getTruthString()
	{
		if (!estimated_transformation.is_some)
		{
			return base.getTruthString();
		}
		return TextHelper.transformedLocalised(estimated_transformation.value.Item1, estimated_transformation.value.Item2) + "\n" + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == estimated_transformation.value.Item1;
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return string.Format("{0},{1}", (int)said_role, estimated_transformation.is_some ? $"{estimated_transformation.value.Item1},{(int)estimated_transformation.value.Item2}" : "f");
	}
}
