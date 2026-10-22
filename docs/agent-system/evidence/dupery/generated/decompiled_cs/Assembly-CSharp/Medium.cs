using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Medium : RoleData
{
	private int unobscured_target = -1;

	private Roles said = (Roles)(-1);

	public override Roles role => Roles.MEDIUM;

	public override string english_name => "Medium";

	public override string english_description => TextHelper.whenInvestigated + " I " + TextHelper.unobscure + " a random " + Keywords.ROLE.toString() + " and " + Keywords.ANNOUNCE.toString() + " their identity.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I do not " + TextHelper.unobscure + " any " + Keywords.ROLE.toString() + " and I " + Keywords.ANNOUNCE.toString() + " a random " + TextHelper.inPlayRole + "."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public override bool has_hover_focus => said > (Roles)0;

	private string loc_no_info_key => $"{role} [info_no]";

	public Medium(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Medium(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			unobscured_target = int.Parse(array[0]);
			said = (Roles)int.Parse(array[1]);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}!\nSave: {_save.unique_data}\nError: {arg}");
			unobscured_target = -1;
			said = (Roles)(-1);
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new List<AdvancedGenerationConstraint>
		{
			new InPlayRequireRoleGC(RoleGenerationMarkers.OBSCURES),
			new LeadRequireGC(new List<RoleClassifications>
			{
				RoleClassifications.MEDDLER,
				RoleClassifications.UNDERLING
			}, RoleGenerationMarkers.OBSCURES, 2)
		});
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onInvestigationAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _investigated_address)
	{
		if (base.has_bad_info || _investigated_address != base.address)
		{
			return _board;
		}
		List<RoleData> list = _board.getRolesInPlay().Values.Where((RoleData _r) => _r.getIsObscured()).ToList();
		if (list.Count == 0)
		{
			return _board;
		}
		RoleData randomElementFromList = list.getRandomElementFromList(random);
		randomElementFromList.setObscured(_new: false);
		randomElementFromList.clearTempObscured();
		unobscured_target = randomElementFromList.getAddress();
		return base.onInvestigationAction(_board, _payload, _investigated_address);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (base.has_bad_info)
		{
			RoleData randomElementFromList = _snap.board.getRolesInPlay().Values.Where((RoleData _r) => _r.getAddress() != unobscured_target).ToList().getRandomElementFromList(random);
			said = randomElementFromList.role;
			return checkTranslationWithData(englishInfo, randomElementFromList.name_coloured);
		}
		if (unobscured_target <= 0)
		{
			return checkTranslation(loc_no_info_key, englishNoInfo);
		}
		RoleData roleData = _snap.board.getRolesInPlay()[unobscured_target];
		said = roleData.role;
		return checkTranslationWithData(englishInfo, roleData.name_coloured);
	}

	private string englishInfo(string _data)
	{
		return "I've spoken to a " + _data + ".";
	}

	private string englishNoInfo()
	{
		return "I found no soul to speak to.";
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a && !_occupent.maybe_a.value.getIsObscured() && _occupent.maybe_a.value.getIsInvestigated() && !_occupent.maybe_a.value.getIsHidden())
		{
			return _occupent.maybe_a.value.getVisualAppearance() == said;
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return $"{unobscured_target},{(int)said}";
	}
}
