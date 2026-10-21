using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using UnityEngine;

namespace Nodes.Logic;

public class StandardRegionSetsChoiceNode : RegionSetsChoiceBaseNode
{
	[SerializeField]
	protected RoleSetsType set_type;

	protected override List<RoleSetsGraph> getPotentialGraphs(RegionDataGraphNavigator _navigator)
	{
		throw new NotImplementedException("Region nodes are no longer supported!");
	}

	protected override List<Roles> getAllowedRandomRoles(RegionDataGraphNavigator _navigator)
	{
		return base.region_graph.getDefaultSets(set_type).Aggregate(new HashSet<Roles>(), (HashSet<Roles> _a, RoleSetsGraph _c) => _a.addRange(_c.getSetRoles())).ToList();
	}

	public override bool canRoleAppear(Roles _role)
	{
		return base.region_graph.canRoleAppearInDefaultSet(set_type, _role);
	}
}
