using System.Collections.Generic;

namespace CaseCreation;

public interface IClassificationGenerationConstraint
{
	bool canSuspectWithRatio(Dictionary<RoleClassifications, int> _ratio, List<Roles> _forced_suspects, List<Roles> _forced_in_play, SuspectListFactory _factory);

	bool canBeInPlayWithRatio(Dictionary<RoleClassifications, int> _ratio, List<Roles> _forced_in_play, InPlayListFactory _factory);

	CaseRatioBuilderData updateBuilder(CaseRatioBuilderData _ratio_builder, bool _is_force_suspected, bool _is_force_in_play, List<Roles> _forced_suspects, List<Roles> _forced_in_play);
}
