using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

public class Journalist : RoleData
{
	public override Roles role => Roles.JOURNALIST;

	public override string english_name => "Journalist";

	public override string english_description => TextHelper.whenInvestigatedIAnnounce + " your " + Keywords.REPUTATION_STATUS.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)>
	{
		(DescriptionType.SPECIAL, TextHelper.iAmSelfConfirm),
		(DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTaintIAnnounce + " a random " + Keywords.REPUTATION_STATUS.toString() + " that is incorrect.")
	};

	public override string credits => "gv";

	public override bool hasInfo => true;

	public Journalist(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Journalist(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(default(RoleGenerationMarkers));
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		ReputationStatus visual_reputation_status;
		if (_snap is ClockCaseSnapshot clockCaseSnapshot)
		{
			visual_reputation_status = clockCaseSnapshot.visual_reputation_status;
		}
		else
		{
			if (!(_snap is DocksCaseSnapshot docksCaseSnapshot))
			{
				throw new ArgumentException($"{role} could not get reputation status from snapshot in region!");
			}
			visual_reputation_status = docksCaseSnapshot.visual_reputation_status;
		}
		ReputationStatus reputationStatus = ((!base.has_bad_info) ? visual_reputation_status : new List<ReputationStatus>().addAll().remove(visual_reputation_status).getRandomElementFromList(random));
		return LocalisationHelper.checkOptionIfNotAsian(checkTranslationWithData(englishInfo, reputationStatus.toString()), reputationStatus.getPrefixOption());
	}

	private string englishInfo(string _data)
	{
		return "People think you are a{#/n} " + _data + " detective.";
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
