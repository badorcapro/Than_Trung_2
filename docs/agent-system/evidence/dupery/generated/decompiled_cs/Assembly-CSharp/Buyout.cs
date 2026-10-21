using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Buyout : CasinoRoleData
{
	private const int low_threshold = 40;

	private const int high_threshold = 100;

	private int said = -1;

	public override Roles role => Roles.BUYOUT;

	public override string english_name => "Buyout";

	public override string english_description => $"{TextHelper.whenInvestigated}, if you have less than {40} {Keywords.CHIPS.toString()}, I {Keywords.ANNOUNCE.toString()} the " + $"{Keywords.ADDRESS.toString()} of an {TextHelper.underlingOrTraitorRole}. If you have more than {100} {Keywords.CHIPS.toString()}, I {Keywords.ANNOUNCE.toString()} the " + Keywords.ADDRESS.toString() + " of an " + TextHelper.innocentRole + ". Otherwise, I " + Keywords.ANNOUNCE.toString() + " the " + Keywords.ADDRESS.toString() + " of a " + TextHelper.meddlerRole + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I " + Keywords.ANNOUNCE.toString() + " the " + Keywords.ADDRESS.toString() + " of a " + Keywords.ROLE.toString() + " that is of the incorrect " + Keywords.CLASSIFICATION.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public override bool has_hover_focus => said > 0;

	public Buyout(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Buyout(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		said = RoleHelper.tryLoadSingleValueFromUniqueData(role, _save);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new List<AdvancedGenerationConstraint>
		{
			new VisualClassificationRatioGC(RoleClassifications.MEDDLER, 1, DisguiseConstraintType.NEVER_IGNORE),
			new InPlayRequireRoleGC(RoleClassifications.MEDDLER)
		});
	}

	protected override string generateCasinoInfoString(CasinoCaseSnapshot _snap)
	{
		HashSet<RoleClassifications> class_wanted;
		if (_snap.casino_payload.chips < 40)
		{
			class_wanted = new HashSet<RoleClassifications>
			{
				RoleClassifications.UNDERLING,
				RoleClassifications.TRAITOR
			};
		}
		else if (_snap.casino_payload.chips <= 100)
		{
			class_wanted = new HashSet<RoleClassifications> { RoleClassifications.MEDDLER };
		}
		else
		{
			class_wanted = new HashSet<RoleClassifications> { RoleClassifications.INNOCENT };
		}
		List<int> list = (base.has_bad_info ? (from _ao in _snap.address_occupents
			where _ao.Key != base.address && !class_wanted.Contains(_ao.Value.getVisualClassification())
			select _ao.Key).ToList() : (from _ao in _snap.address_occupents
			where _ao.Key != base.address && class_wanted.Contains(_ao.Value.getVisualClassification())
			select _ao.Key).ToList());
		if (list.Count == 0)
		{
			if (base.has_bad_info && !class_wanted.Contains(getVisualClassification()))
			{
				list.Add(base.address);
			}
			else
			{
				if (base.has_bad_info || !class_wanted.Contains(getVisualClassification()))
				{
					Debug.LogError($"{role} No valid targets found!");
					return "";
				}
				list.Add(base.address);
			}
		}
		said = list.getRandomElementFromList(random);
		return checkTranslationWithData(englishInfo, said);
	}

	private string englishInfo(string _data)
	{
		return "You should check #" + _data + ".";
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == said;
		}
		return false;
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.INNOCENT;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
