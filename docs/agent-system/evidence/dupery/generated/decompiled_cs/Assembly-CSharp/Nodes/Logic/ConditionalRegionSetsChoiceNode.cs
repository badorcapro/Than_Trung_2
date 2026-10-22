using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Generic;
using GRGLib.Serializable;
using UnityEngine;

namespace Nodes.Logic;

public class ConditionalRegionSetsChoiceNode : RegionSetsChoiceBaseNode
{
	[SerializeField]
	protected RoleSetsType set_type;

	[SerializeField]
	private SerializableDictionary<RoleClassifications, MinMaxInt> wanted_class;

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
		return base.region_graph.canRoleAppearInDefaultSet(set_type, _role, (RoleSetsGraph _s) => ratioMatches(_s.getSetRoles().getListRatio()));
	}

	private bool ratioMatches(Dictionary<RoleClassifications, int> _ratio)
	{
		foreach (KeyValuePair<RoleClassifications, MinMaxInt> item in wanted_class)
		{
			if (!item.Value.inRange(_ratio.getOrDefault(item.Key, 0)))
			{
				return false;
			}
		}
		return true;
	}
}
