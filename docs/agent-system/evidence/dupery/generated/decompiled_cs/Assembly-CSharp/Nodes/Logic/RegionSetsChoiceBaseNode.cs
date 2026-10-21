using System;
using System.Collections.Generic;
using GRGLib.Extensions.Random;
using XNode;

namespace Nodes.Logic;

public abstract class RegionSetsChoiceBaseNode : RegionDataNodeBase, INodeRoleSets
{
	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public RegionDataNodeBase enter;

	[Output(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public RegionDataNodeBase exit;

	protected override void doAction(RegionDataGraphNavigator _navigator)
	{
	}

	protected abstract List<RoleSetsGraph> getPotentialGraphs(RegionDataGraphNavigator _navigator);

	protected abstract List<Roles> getAllowedRandomRoles(RegionDataGraphNavigator _navigator);

	public virtual (RoleSetsGraph, RoleSetsGraph, List<Roles>) getChoice(RegionDataGraphNavigator _navigator)
	{
		List<RoleSetsGraph> potentialGraphs = getPotentialGraphs(_navigator);
		if (potentialGraphs.Count < 2)
		{
			throw new ArgumentException($"Cannot set up event scene with choice as not enough role sets are allowed!!! Only {potentialGraphs.Count} choices available!");
		}
		List<RoleSetsGraph> randomElementsFromList = potentialGraphs.getRandomElementsFromList(_navigator.random, 2);
		return (randomElementsFromList[0], randomElementsFromList[1], getAllowedRandomRoles(_navigator));
	}

	public abstract bool canRoleAppear(Roles _role);
}
