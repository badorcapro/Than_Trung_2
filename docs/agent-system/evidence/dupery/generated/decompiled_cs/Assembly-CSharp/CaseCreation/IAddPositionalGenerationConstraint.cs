using System;
using System.Collections.Generic;

namespace CaseCreation;

public interface IAddPositionalGenerationConstraint
{
	Dictionary<Roles, List<IPositioningGenerationConstraint>> addConstraints(Dictionary<Roles, List<IPositioningGenerationConstraint>> _constraints, List<Roles> _in_play_roles, Random _rng);
}
