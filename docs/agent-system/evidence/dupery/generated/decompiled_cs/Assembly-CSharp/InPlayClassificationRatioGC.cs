using System.Collections.Generic;
using CaseCreation;
using GRGLib.Generic;

public class InPlayClassificationRatioGC : ClassificationRatioGC
{
	public InPlayClassificationRatioGC(RoleClassifications _class, int _min_needed, DisguiseConstraintType _disguise = DisguiseConstraintType.IGNORE_WHEN_LYING)
		: base(_class, _min_needed, _disguise)
	{
	}

	public InPlayClassificationRatioGC(RoleClassifications _class, MinMaxInt _needed, DisguiseConstraintType _disguise = DisguiseConstraintType.IGNORE_WHEN_LYING)
		: base(_class, _needed, _disguise)
	{
	}

	public override bool canSuspectWithRatio(Dictionary<RoleClassifications, int> _ratio, List<Roles> _forced_suspects, List<Roles> _forced_in_play, SuspectListFactory _factory)
	{
		return true;
	}

	public override CaseRatioBuilderData updateBuilder(CaseRatioBuilderData _ratio_builder, bool _guaranteed_suspected, bool _guaranteed_in_play, List<Roles> _forced_suspects, List<Roles> _forced_in_play)
	{
		if (!_guaranteed_in_play)
		{
			return _ratio_builder;
		}
		return base.updateBuilder(_ratio_builder, _guaranteed_suspected, _guaranteed_in_play, _forced_suspects, _forced_in_play);
	}
}
