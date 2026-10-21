using System;
using System.Collections.Generic;
using GRGLib.Extensions.Random;
using UnityEngine;
using XNode;

namespace Nodes.Logic;

public class RegionStartNode : RegionDataNodeBase
{
	[Output(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public RegionDataNodeBase exit;

	[SerializeField]
	private List<RoleSetsGraph> starting_set_pool;

	public RoleSetsGraph getStartingSet(System.Random _rng)
	{
		return starting_set_pool.getRandomElementFromList(_rng);
	}

	public List<RoleSetsGraph> getAllStartingSets()
	{
		return starting_set_pool;
	}

	protected override void doAction(RegionDataGraphNavigator _navigator)
	{
		Debug.LogError("Start node has no action, this function shouldn't be called.");
		nextAction(_navigator);
	}
}
