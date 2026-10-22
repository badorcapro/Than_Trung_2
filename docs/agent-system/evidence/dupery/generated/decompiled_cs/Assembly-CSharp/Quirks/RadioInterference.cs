using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using Leads;

namespace Quirks;

public class RadioInterference : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.RADIO_INTERFERENCE;

	protected override string english_name => "Radio Interference";

	protected override string english_description => "One category in the ratio is incorrectly reduced by 1. Another category is incorrectly increased by 1.";

	public override bool is_visual_ratio_quirk => true;

	public override bool canAdd(List<Roles> _available_roles, List<CaseQuirks> _in_play_quirks, CaseType _case_type)
	{
		if (!_in_play_quirks.Contains(CaseQuirks.BROKEN_RADIO))
		{
			return base.canAdd(_available_roles, _in_play_quirks, _case_type);
		}
		return false;
	}

	public override Dictionary<RoleClassifications, int> onVisualRatioCreation(Dictionary<RoleClassifications, int> _visual, Dictionary<RoleClassifications, int> _real, Random _rng)
	{
		List<KeyValuePair<RoleClassifications, int>> list = _visual.Where((KeyValuePair<RoleClassifications, int> _c) => _c.Value > 0).ToList();
		if (list.Count < 2)
		{
			return _visual;
		}
		List<KeyValuePair<RoleClassifications, int>> randomElementsFromList = list.getRandomElementsFromList(_rng, 2);
		_visual[randomElementsFromList[0].Key]++;
		_visual[randomElementsFromList[1].Key]--;
		return _visual;
	}

	public override bool isValidForClue(List<CaseQuirks> _quirks, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return !_quirks.Contains(CaseQuirks.BROKEN_RADIO);
	}
}
