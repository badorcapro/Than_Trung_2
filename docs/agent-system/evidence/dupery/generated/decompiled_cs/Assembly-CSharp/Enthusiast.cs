using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Enthusiast : BackAlleyRoleData
{
	private int target = -1;

	public override Roles role => Roles.ENTHUSIAST;

	public override string english_name => "Enthusiast";

	public override string english_description => TextHelper.whenInvestigatedIAnnounce + " the " + Keywords.ADDRESS.toString() + " of an " + Alignments.EVIL.toString() + " " + TextHelper.adjacentNeighbour + ". If I have no " + Alignments.EVIL.toString() + " " + TextHelper.adjacentNeighbour + ", I " + Keywords.ANNOUNCE.toString() + " the " + Keywords.ADDRESS.toString() + " of a random " + TextHelper.adjacentNeighbour + " instead.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I can only be " + Keywords.SUSPECTED.toString() + " if you " + TextHelper.held + " both a " + BackAlleysItemColour.LAWFUL.toString() + " and " + TextHelper.mischeviousItem + " at the start of the case."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I " + Keywords.ANNOUNCE.toString() + " the " + Keywords.ADDRESS.toString() + " of a " + Alignments.GOOD.toString() + " " + TextHelper.adjacentNeighbour + ". If none exist, I " + Keywords.ANNOUNCE.toString() + " the " + Keywords.ADDRESS.toString() + " of a random " + TextHelper.adjacentNeighbour + "."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	public Enthusiast(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Enthusiast(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			target = int.Parse(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			target = -1;
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new List<AdvancedGenerationConstraint>
		{
			new PositionRoleGC(GCPosition.ADJACENT, DisguiseConstraintType.NEVER_IGNORE)
		});
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		return target == _occupent.maybe_a.value.getAddress();
	}

	protected override string generateBackAlleysInfoString(BackAlleysCaseSnapshot _snap)
	{
		List<RoleData> adjacentRolesFromGridPos = _snap.board.getAdjacentRolesFromGridPos(base.board_position, base.case_ref.board_size);
		List<RoleData> list = adjacentRolesFromGridPos.Where((RoleData _r) => _r.getVisualAlignment() == ((!base.has_bad_info) ? Alignments.EVIL : Alignments.GOOD)).ToList();
		if (list.Count > 0)
		{
			target = list.getRandomElementFromList(random).getAddress();
			return getInfo(target);
		}
		target = adjacentRolesFromGridPos.getRandomElementFromList(random).getAddress();
		return getInfo(target);
	}

	private string getInfo(int _data)
	{
		return checkTranslationWithData(englishInfo, _data);
	}

	private string englishInfo(string _data)
	{
		return "I don't trust #" + _data;
	}

	public override string getUniqueSaveData()
	{
		return target.ToString();
	}
}
