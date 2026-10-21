using System;
using System.Collections.Generic;
using GRGLib.Maybe;

namespace Save;

[Serializable]
public class CaseBuilDataSavev0_3_12
{
	public float difficulty_01;

	public CaseRatioBuilderData ratio_builder_data;

	public Maybe<CaseQuirks> quirk_added;

	public List<CaseQuirks> case_quirks;

	public Maybe<CaseSavev0_3_12> case_save;

	public Roles icon;

	public string case_description = "";

	public CaseRewardSavev0_3_12 case_reward;
}
