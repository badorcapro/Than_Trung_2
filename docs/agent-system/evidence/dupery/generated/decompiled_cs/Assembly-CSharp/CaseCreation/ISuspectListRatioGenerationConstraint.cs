using System.Collections.Generic;

namespace CaseCreation;

public interface ISuspectListRatioGenerationConstraint
{
	Dictionary<RoleClassifications, int> modifySuspectRatio(Dictionary<RoleClassifications, int> _current, Dictionary<RoleClassifications, int> _ratio, SuspectListFactory _factory);
}
