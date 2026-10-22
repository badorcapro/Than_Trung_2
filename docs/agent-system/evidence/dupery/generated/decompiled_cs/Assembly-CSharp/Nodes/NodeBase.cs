using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using UnityEngine;
using XNode;

namespace Nodes;

public abstract class NodeBase : Node
{
	[HideInInspector]
	public int UID = -1;

	public NodeBase setup(int _uid)
	{
		UID = _uid;
		return this;
	}

	public override object GetValue(NodePort port)
	{
		return this;
	}

	public List<T> getListInputValues<T>(string _port_name) where T : NodeBase
	{
		return getListValues(_port_name, (string _n) => getInputValues<T>(_n));
	}

	public List<T> getListOutputValues<T>(string _port_name) where T : NodeBase
	{
		return getListValues(_port_name, (string _n) => getOutputValues<T>(_n));
	}

	private List<T> getListValues<T>(string _port_name, Func<string, List<T>> _get_value) where T : NodeBase
	{
		List<T> list = new List<T>();
		string text = _port_name + " {N}";
		bool flag = false;
		int num = 0;
		while (!flag)
		{
			string text2 = text.Replace("{N}", num.ToString());
			flag = !HasPort(text2);
			if (!flag)
			{
				List<T> list2 = _get_value(text2);
				if (list2.Count != 0)
				{
					list.add(list2[0]);
				}
			}
			num++;
		}
		return list;
	}

	public List<T> getInputValues<T>(string _port_name) where T : NodeBase
	{
		return (from _a in (GetInputPort(_port_name) ?? throw new ArgumentException("Input Port with name " + _port_name + " not found!")).GetInputValues<T>()
			where _a != null
			select _a).ToList();
	}

	public Maybe<T> tryGetInputValue<T>(string _port_name) where T : NodeBase
	{
		List<T> inputValues = getInputValues<T>(_port_name);
		if (inputValues.Count > 0)
		{
			return inputValues[0].maybe();
		}
		return new Maybe<T>();
	}

	public List<T> getOutputValues<T>(string _port_name) where T : NodeBase
	{
		List<NodePort> connections = (GetOutputPort(_port_name) ?? throw new ArgumentException("Output Port with name " + _port_name + " not found!")).GetConnections();
		if (connections.Count == 0)
		{
			return new List<T>();
		}
		List<Node> list = connections.Select((NodePort _e) => _e.node).ToList();
		List<T> t_list = new List<T>();
		list.ForEach(delegate(Node _a)
		{
			t_list.add(_a as T);
		});
		return t_list.Where((T _t) => _t != null).ToList();
	}

	public Maybe<T> tryGetOutputValue<T>(string _port_name) where T : NodeBase
	{
		List<T> outputValues = getOutputValues<T>(_port_name);
		if (outputValues.Count > 0)
		{
			return outputValues[0].maybe();
		}
		return new Maybe<T>();
	}
}
