using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Skeptic : RoleData
{
	private int target = -1;

	public override Roles role => Roles.SKEPTIC;

	public override string english_name => "Skeptic";

	public override string english_description => TextHelper.whenInvestigated + ", I " + Keywords.ANNOUNCE.toString() + " one " + Keywords.ADDRESS.toString() + " and its " + Keywords.ALIGNMENT.toString() + ".\nIf your " + Keywords.REPUTATION_STATUS.toString() + " is " + ReputationStatus.POOR.toString() + ", I lose faith in you.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I cannot " + Keywords.TARGET.toString() + " myself with my information."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", regardless of your " + Keywords.REPUTATION.toString() + ", I " + Keywords.ANNOUNCE.toString() + " one " + Keywords.ADDRESS.toString() + " and the opposite of its actual " + Keywords.ALIGNMENT.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public override bool has_hover_focus => target != -1;

	private string loc_no_info_key => $"{role} [no_info]";

	public Skeptic(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Skeptic(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		target = int.Parse(_save.unique_data);
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		return _occupent.maybe_a.value.getAddress() == target;
	}

	private bool shouldGossip(ReputationStatus _rep)
	{
		if (!base.case_ref.hasMarkerQuirk(CaseQuirks.PARANOIA))
		{
			if (_rep == ReputationStatus.POOR)
			{
				return base.has_bad_info;
			}
			return true;
		}
		if (_rep != ReputationStatus.EXCEPTIONAL)
		{
			return base.has_bad_info;
		}
		return true;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (_snap is ClockCaseSnapshot clockCaseSnapshot)
		{
			return generateInfo(clockCaseSnapshot, clockCaseSnapshot.visual_reputation_status);
		}
		if (_snap is DocksCaseSnapshot docksCaseSnapshot)
		{
			return generateInfo(docksCaseSnapshot, docksCaseSnapshot.visual_reputation_status);
		}
		Debug.LogError($"No generate info string function set up for snapshot of type {_snap.GetType()}!");
		return "";
	}

	protected string generateInfo(CaseSnapshot _snap, ReputationStatus _rep_status)
	{
		if (shouldGossip(_rep_status))
		{
			target = _snap.board.getRolesInPlay().Keys.Where((int _e) => _e != base.address && _e != -1).ToList().getRandomElementFromList(random);
			if (base.has_bad_info)
			{
				return getInfo(target, (_snap.board.getRolesInPlay()[target].getVisualAlignment() == Alignments.GOOD) ? Alignments.EVIL : Alignments.GOOD);
			}
			return getInfo(target, _snap.board.getRolesInPlay()[target].getVisualAlignment());
		}
		return getNoInfo();
	}

	private string getInfo(int _target, Alignments _alignment)
	{
		return checkTranslationWithReplace(() => getInfoEnglish(_target.ToString(), _alignment.toStringPlainCap()), () => _target.ToString(), () => _alignment.toStringPlainCap());
	}

	private string getInfoEnglish(string _data_1, string _data_2)
	{
		return "#" + _data_1 + " is " + _data_2;
	}

	private string getNoInfo()
	{
		return checkTranslation(loc_no_info_key, getNoInfoEnglish);
	}

	private string getNoInfoEnglish()
	{
		return "Sorry, you can't be trusted.";
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
		return target.ToString();
	}
}
