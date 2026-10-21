using System;
using System.Collections.Generic;

namespace Quirks;

public class BrokenRadio : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.BROKEN_RADIO;

	protected override string english_name => "Broken Radio";

	protected override string english_description => "All categories in the ratio incorrectly read as 0.";

	public override bool is_visual_ratio_quirk => true;

	public override Dictionary<RoleClassifications, int> onVisualRatioCreation(Dictionary<RoleClassifications, int> _visual, Dictionary<RoleClassifications, int> _real, Random _rng)
	{
		return new Dictionary<RoleClassifications, int>
		{
			{
				RoleClassifications.INNOCENT,
				0
			},
			{
				RoleClassifications.MEDDLER,
				0
			},
			{
				RoleClassifications.UNDERLING,
				0
			},
			{
				RoleClassifications.TRAITOR,
				0
			}
		};
	}
}
