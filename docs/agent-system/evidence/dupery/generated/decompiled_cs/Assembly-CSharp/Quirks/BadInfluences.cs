using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;

namespace Quirks;

public class BadInfluences : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.BAD_INFLUENCES;

	protected override string english_name => "Bad Influences";

	protected override string english_description => "If there are at least 2 " + TextHelper.meddlerRoles + " " + Keywords.IN_PLAY.toString() + ", 1 " + TextHelper.meddlerRole + " is " + TextHelper.transformed + " into a " + Keywords.NOT_IN_PLAY.toString() + " " + RoleClassifications.UNDERLING.toString() + ".";

	protected override string english_extra_description => "The " + TextHelper.meddlerRole + " will always be " + TextHelper.transformed + " into a " + Keywords.NOT_IN_PLAY.toString() + " " + RoleClassifications.UNDERLING.toString() + ". If none are found, then no " + RoleClassifications.MEDDLER.toString() + " will be " + TextHelper.transformed + ".";

	public override bool is_ratio_modification_quirk => true;

	public override bool is_suspects_ratio_quirk => true;

	public override Dictionary<RoleClassifications, int> onRatioModification(Dictionary<RoleClassifications, int> _modified, Dictionary<RoleClassifications, int> _ratio, List<Roles> _suspect_list, Random _rng)
	{
		if (_modified.getOrCreate(RoleClassifications.MEDDLER, 0) >= 2 && _suspect_list.getUnderlings().Count > _modified.getOrCreate(RoleClassifications.UNDERLING, 0))
		{
			_modified[RoleClassifications.MEDDLER]--;
			_modified[RoleClassifications.UNDERLING]++;
		}
		return _modified;
	}

	public override Dictionary<RoleClassifications, int> onSuspectRatio(Dictionary<RoleClassifications, int> _needed_extras, Dictionary<RoleClassifications, int> _ratio, Random _rng)
	{
		_needed_extras.increaseOrCreate(RoleClassifications.UNDERLING, 1);
		return _needed_extras;
	}
}
