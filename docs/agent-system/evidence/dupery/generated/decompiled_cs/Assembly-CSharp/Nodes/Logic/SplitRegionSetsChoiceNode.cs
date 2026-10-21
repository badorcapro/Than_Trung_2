using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using UnityEngine;

namespace Nodes.Logic;

public class SplitRegionSetsChoiceNode : RegionSetsChoiceBaseNode
{
	[SerializeField]
	private List<RoleSetsGraph> choices_1;

	[SerializeField]
	private List<RoleSetsGraph> choices_2;

	protected override List<RoleSetsGraph> getPotentialGraphs(RegionDataGraphNavigator _navigator)
	{
		throw new NotImplementedException("This should never be called!!! (SplitRegionSetsChoiceNode.getPotentialGraphs)");
	}

	protected override List<Roles> getAllowedRandomRoles(RegionDataGraphNavigator _navigator)
	{
		return choices_1.Aggregate(new HashSet<Roles>(), (HashSet<Roles> _a, RoleSetsGraph _c) => _a.addRange(_c.getSetRoles())).addRange(choices_2.Aggregate(new HashSet<Roles>(), (HashSet<Roles> _a, RoleSetsGraph _c) => _a.addRange(_c.getSetRoles()))).ToList();
	}

	public override (RoleSetsGraph, RoleSetsGraph, List<Roles>) getChoice(RegionDataGraphNavigator _navigator)
	{
		throw new NotImplementedException("This function is deprecated!");
	}

	public override bool canRoleAppear(Roles _role)
	{
		if (!choices_1.Any((RoleSetsGraph _c) => _c.getSetRoles().Contains(_role)))
		{
			return choices_2.Any((RoleSetsGraph _c) => _c.getSetRoles().Contains(_role));
		}
		return true;
	}
}
