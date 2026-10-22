using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using UnityEngine;

namespace Nodes.Logic;

public class SimpleRegionSetsChoiceNode : RegionSetsChoiceBaseNode
{
	[SerializeField]
	private List<RoleSetsGraph> possible_choices;

	protected override List<RoleSetsGraph> getPotentialGraphs(RegionDataGraphNavigator _navigator)
	{
		throw new NotImplementedException("Region nodes are deprecated!");
	}

	protected override List<Roles> getAllowedRandomRoles(RegionDataGraphNavigator _navigator)
	{
		return possible_choices.Aggregate(new HashSet<Roles>(), (HashSet<Roles> _a, RoleSetsGraph _c) => _a.addRange(_c.getSetRoles())).ToList();
	}

	public override bool canRoleAppear(Roles _role)
	{
		return possible_choices.Any((RoleSetsGraph _c) => _c.getSetRoles().Contains(_role));
	}
}
