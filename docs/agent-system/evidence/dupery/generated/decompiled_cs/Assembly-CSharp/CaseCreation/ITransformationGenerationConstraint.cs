using System;
using System.Collections.Generic;
using GRGLib.Maybe;

namespace CaseCreation;

public interface ITransformationGenerationConstraint : IFilterRoleCluesGenerationConstraint
{
	bool tryTransformation(List<ChainMarker<Roles>> _can_transform, List<ChainMarker<Roles>> _in_play_roles, Random _rng, InPlayListFactory _factory, out Maybe<(ChainMarker<Roles>, Roles)> _to_transform);

	Maybe<Roles> getRoleTransformed(Roles _self, CaseSnapshot _snap);

	Maybe<ValidationError> checkTransformationError(CaseType _type, Roles _self, List<Roles> _in_play, CaseSnapshot _snap);
}
