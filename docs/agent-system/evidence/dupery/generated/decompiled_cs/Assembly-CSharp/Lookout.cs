using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Lookout : DocksRoleData
{
	private int said = -1;

	public override Roles role => Roles.LOOKOUT;

	public override string english_name => "Lookout";

	public override string english_description => "I " + Keywords.ANNOUNCE.toString() + " how many " + Keywords.STEPS.toString() + " the " + RoleClassifications.TRAITOR.toString() + " is from the " + LocationTypes.DOCKS.toString() + ". I start " + TextHelper.investigated + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString() + " a random number of " + Keywords.STEPS.toString() + " between 1 and 4 that is incorrect."));
			return list;
		}
	}

	public override bool has_hover_focus => said > 0;

	public override bool hasInfo => true;

	private string loc_no_info_key => $"{role} [info_no]";

	public Lookout(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Lookout(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			said = int.Parse(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			said = -1;
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.CANT_BE_ONLY_NOT_IN_PLAY, new InPlayClassificationRatioGC(RoleClassifications.TRAITOR, 1, DisguiseConstraintType.ALWAYS_IGNORE));
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _position.cardinalDistance(_snap.board.getLocationsInPlay()[LocationTypes.DOCKS].getBoardPosition()) == said;
		}
		return false;
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		List<RoleData> rolesInPlayOfClass = _snap.board.getRolesInPlayOfClass(RoleClassifications.TRAITOR);
		if (rolesInPlayOfClass.Count == 0)
		{
			if (base.has_bad_info)
			{
				said = random.Next(1, 5);
				return checkTranslationWithPlural(englishInfo, said);
			}
			return checkTranslation(loc_no_info_key, englishNoInfo);
		}
		int num = rolesInPlayOfClass[0].getBoardPosition().cardinalDistance(_snap.board.getLocationsInPlay()[LocationTypes.DOCKS].getBoardPosition());
		if (base.has_bad_info)
		{
			said = random.Next(1, 5);
			if (said == num)
			{
				said--;
				if (said == 0)
				{
					said = 4;
				}
			}
		}
		else
		{
			said = num;
		}
		return checkTranslationWithPlural(englishInfo, said);
	}

	private string englishInfo(string _data)
	{
		return "The beast is " + _data + " step{#/s} away from the docks!";
	}

	private string englishNoInfo()
	{
		return "The beast is nowhere to be seen...";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		base.investigated = true;
		if (!base.obscured)
		{
			base.case_ref.checkAddSuspect(role);
		}
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	public override string getUniqueSaveData()
	{
		return said.ToString();
	}
}
