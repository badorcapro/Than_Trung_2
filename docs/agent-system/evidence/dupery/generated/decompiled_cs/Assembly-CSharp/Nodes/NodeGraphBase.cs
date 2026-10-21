using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using XNode;

namespace Nodes;

public class NodeGraphBase : NodeGraph
{
	public List<T> fetchNodes<T>() where T : NodeBase
	{
		return (from _n in nodes
			where _n is T
			select _n as T).toListSafe();
	}

	public List<NodeBase> fetchNodes()
	{
		return nodes.Select((Node _n) => _n as NodeBase).toListSafe();
	}

	public T fetchNode<T>(int _uid) where T : NodeBase
	{
		return fetchNode(_uid) as T;
	}

	public NodeBase fetchNode(int _uid)
	{
		List<NodeBase> list = (from _n in fetchNodes()
			where _n.UID == _uid
			select _n).ToList();
		if (list.Count == 0)
		{
			throw new ArgumentException($"No matching node found with a UID of '{_uid}' in '{base.name}'");
		}
		if (list.Count > 1)
		{
			throw new ArgumentException($"More than one node with a UID of '{_uid}' found in '{base.name}'... this should not happen!");
		}
		return list[0];
	}

	public int getUniqueIndex()
	{
		int i = 0;
		if (nodes.Count != 0)
		{
			for (; nodes.Select((Node _e) => (_e as NodeBase).UID).Contains(i); i++)
			{
			}
		}
		return i;
	}
}
