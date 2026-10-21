using System;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Nodes.Logic;
using UnityEngine;

public class RegionDataGraphNavigator
{
	public const int no_node_id = -101;

	private Maybe<RegionDataNodeBase> last_actioned = new Maybe<RegionDataNodeBase>();

	public System.Random random { get; private set; } = RandomExtensions.freshRandom();

	public RegionDataGraphNavigator(RegionDataNodeBase _start_node)
	{
		last_actioned = _start_node.maybe();
	}

	public RegionDataGraphNavigator(RegionDataGraph _graph, int _node_id)
	{
		try
		{
			if (_node_id != -101)
			{
				last_actioned = _graph.fetchNode<RegionDataNodeBase>(_node_id).maybe();
			}
			else
			{
				last_actioned = new Maybe<RegionDataNodeBase>();
			}
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading RegionDataGraphNavigator failed!! Save: {_node_id} || Error: {arg}");
			last_actioned = ((RegionDataNodeBase)_graph.fetchStartNode()).maybe();
		}
	}

	public void setLastActioned(RegionDataNodeBase _node)
	{
		last_actioned = _node.maybe();
	}

	public bool tryNext()
	{
		if (!last_actioned.is_some)
		{
			return false;
		}
		return last_actioned.value.nextAction(this);
	}

	public int getSaveNodeId()
	{
		if (!last_actioned.is_some)
		{
			return -101;
		}
		return last_actioned.value.UID;
	}

	public RegionDataNodeBase getLastActioned()
	{
		return last_actioned.value;
	}
}
