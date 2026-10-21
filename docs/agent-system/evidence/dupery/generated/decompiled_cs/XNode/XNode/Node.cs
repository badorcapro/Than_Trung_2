using System;
using System.Collections.Generic;
using UnityEngine;

namespace XNode;

[Serializable]
public abstract class Node : ScriptableObject
{
	public enum ShowBackingValue
	{
		Never,
		Unconnected,
		Always
	}

	public enum ConnectionType
	{
		Multiple,
		Override
	}

	public enum TypeConstraint
	{
		None,
		Inherited,
		Strict,
		InheritedInverse,
		InheritedAny
	}

	[AttributeUsage(AttributeTargets.Field)]
	public class InputOutputAttribute : NodePortAttribute
	{
		public InputOutputAttribute(ShowBackingValue backingValue = ShowBackingValue.Unconnected, ConnectionType connectionType = ConnectionType.Multiple, TypeConstraint typeConstraint = TypeConstraint.None, bool dynamicPortList = false)
		{
			base.backingValue = backingValue;
			base.connectionType = connectionType;
			base.dynamicPortList = dynamicPortList;
			base.typeConstraint = typeConstraint;
		}
	}

	public abstract class NodePortAttribute : Attribute
	{
		public ShowBackingValue backingValue;

		public ConnectionType connectionType;

		public bool dynamicPortList;

		public TypeConstraint typeConstraint;

		[Obsolete("Use dynamicPortList instead")]
		public bool instancePortList
		{
			get
			{
				return dynamicPortList;
			}
			set
			{
				dynamicPortList = value;
			}
		}
	}

	[AttributeUsage(AttributeTargets.Field)]
	public class InputAttribute : NodePortAttribute
	{
		public InputAttribute(ShowBackingValue backingValue = ShowBackingValue.Unconnected, ConnectionType connectionType = ConnectionType.Multiple, TypeConstraint typeConstraint = TypeConstraint.None, bool dynamicPortList = false)
		{
			base.backingValue = backingValue;
			base.connectionType = connectionType;
			base.dynamicPortList = dynamicPortList;
			base.typeConstraint = typeConstraint;
		}
	}

	[AttributeUsage(AttributeTargets.Field)]
	public class OutputAttribute : NodePortAttribute
	{
		public OutputAttribute(ShowBackingValue backingValue = ShowBackingValue.Never, ConnectionType connectionType = ConnectionType.Multiple, TypeConstraint typeConstraint = TypeConstraint.None, bool dynamicPortList = false)
		{
			base.backingValue = backingValue;
			base.connectionType = connectionType;
			base.dynamicPortList = dynamicPortList;
			base.typeConstraint = typeConstraint;
		}

		[Obsolete("Use constructor with TypeConstraint")]
		public OutputAttribute(ShowBackingValue backingValue, ConnectionType connectionType, bool dynamicPortList)
			: this(backingValue, connectionType, TypeConstraint.None, dynamicPortList)
		{
		}
	}

	[AttributeUsage(AttributeTargets.Class, AllowMultiple = false)]
	public class CreateNodeMenuAttribute : Attribute
	{
		public string menuName;

		public int order;

		public CreateNodeMenuAttribute(string menuName)
		{
			this.menuName = menuName;
			order = 0;
		}

		public CreateNodeMenuAttribute(string menuName, int order)
		{
			this.menuName = menuName;
			this.order = order;
		}
	}

	[AttributeUsage(AttributeTargets.Class, AllowMultiple = false)]
	public class DisallowMultipleNodesAttribute : Attribute
	{
		public int max;

		public DisallowMultipleNodesAttribute(int max = 1)
		{
			this.max = max;
		}
	}

	[AttributeUsage(AttributeTargets.Class, AllowMultiple = false)]
	public class NodeTintAttribute : Attribute
	{
		public Color color;

		public NodeTintAttribute(float r, float g, float b)
		{
			color = new Color(r, g, b);
		}

		public NodeTintAttribute(string hex)
		{
			ColorUtility.TryParseHtmlString(hex, out color);
		}

		public NodeTintAttribute(byte r, byte g, byte b)
		{
			color = new Color32(r, g, b, byte.MaxValue);
		}
	}

	[AttributeUsage(AttributeTargets.Class, AllowMultiple = false)]
	public class NodeWidthAttribute : Attribute
	{
		public int width;

		public NodeWidthAttribute(int width)
		{
			this.width = width;
		}
	}

	[Serializable]
	private class NodePortDictionary : Dictionary<string, NodePort>, ISerializationCallbackReceiver
	{
		[SerializeField]
		private List<string> keys = new List<string>();

		[SerializeField]
		private List<NodePort> values = new List<NodePort>();

		public void OnBeforeSerialize()
		{
			keys.Clear();
			values.Clear();
			keys.Capacity = base.Count;
			values.Capacity = base.Count;
			using Enumerator enumerator = GetEnumerator();
			while (enumerator.MoveNext())
			{
				KeyValuePair<string, NodePort> current = enumerator.Current;
				keys.Add(current.Key);
				values.Add(current.Value);
			}
		}

		public void OnAfterDeserialize()
		{
			Clear();
			EnsureCapacity(keys.Count);
			if (keys.Count != values.Count)
			{
				throw new Exception("there are " + keys.Count + " keys and " + values.Count + " values after deserialization. Make sure that both key and value types are serializable.");
			}
			for (int i = 0; i < keys.Count; i++)
			{
				Add(keys[i], values[i]);
			}
		}
	}

	[SerializeField]
	public NodeGraph graph;

	[SerializeField]
	public Vector2 position;

	[SerializeField]
	private NodePortDictionary ports = new NodePortDictionary();

	public static NodeGraph graphHotfix;

	[Obsolete("Use DynamicPorts instead")]
	public IEnumerable<NodePort> InstancePorts => DynamicPorts;

	[Obsolete("Use DynamicOutputs instead")]
	public IEnumerable<NodePort> InstanceOutputs => DynamicOutputs;

	[Obsolete("Use DynamicInputs instead")]
	public IEnumerable<NodePort> InstanceInputs => DynamicInputs;

	public IEnumerable<NodePort> Ports
	{
		get
		{
			foreach (NodePort value in ports.Values)
			{
				yield return value;
			}
		}
	}

	public IEnumerable<NodePort> Outputs
	{
		get
		{
			foreach (NodePort port in Ports)
			{
				if (port.IsOutput)
				{
					yield return port;
				}
			}
		}
	}

	public IEnumerable<NodePort> Inputs
	{
		get
		{
			foreach (NodePort port in Ports)
			{
				if (port.IsInput)
				{
					yield return port;
				}
			}
		}
	}

	public IEnumerable<NodePort> DynamicPorts
	{
		get
		{
			foreach (NodePort port in Ports)
			{
				if (port.IsDynamic)
				{
					yield return port;
				}
			}
		}
	}

	public IEnumerable<NodePort> DynamicOutputs
	{
		get
		{
			foreach (NodePort port in Ports)
			{
				if (port.IsDynamic && port.IsOutput)
				{
					yield return port;
				}
			}
		}
	}

	public IEnumerable<NodePort> DynamicInputs
	{
		get
		{
			foreach (NodePort port in Ports)
			{
				if (port.IsDynamic && port.IsInput)
				{
					yield return port;
				}
			}
		}
	}

	[Obsolete("Use AddDynamicInput instead")]
	public NodePort AddInstanceInput(Type type, ConnectionType connectionType = ConnectionType.Multiple, TypeConstraint typeConstraint = TypeConstraint.None, string fieldName = null)
	{
		return AddDynamicInput(type, connectionType, typeConstraint, fieldName);
	}

	[Obsolete("Use AddDynamicOutput instead")]
	public NodePort AddInstanceOutput(Type type, ConnectionType connectionType = ConnectionType.Multiple, TypeConstraint typeConstraint = TypeConstraint.None, string fieldName = null)
	{
		return AddDynamicOutput(type, connectionType, typeConstraint, fieldName);
	}

	[Obsolete("Use AddDynamicPort instead")]
	private NodePort AddInstancePort(Type type, NodePort.IO direction, ConnectionType connectionType = ConnectionType.Multiple, TypeConstraint typeConstraint = TypeConstraint.None, string fieldName = null)
	{
		return AddDynamicPort(type, direction, connectionType, typeConstraint, fieldName);
	}

	[Obsolete("Use RemoveDynamicPort instead")]
	public void RemoveInstancePort(string fieldName)
	{
		RemoveDynamicPort(fieldName);
	}

	[Obsolete("Use RemoveDynamicPort instead")]
	public void RemoveInstancePort(NodePort port)
	{
		RemoveDynamicPort(port);
	}

	[Obsolete("Use ClearDynamicPorts instead")]
	public void ClearInstancePorts()
	{
		ClearDynamicPorts();
	}

	protected void OnEnable()
	{
		if (graphHotfix != null)
		{
			graph = graphHotfix;
		}
		graphHotfix = null;
		UpdatePorts();
		Init();
	}

	public void UpdatePorts()
	{
		NodeDataCache.UpdatePorts(this, ports);
	}

	protected virtual void Init()
	{
	}

	public void VerifyConnections()
	{
		foreach (NodePort port in Ports)
		{
			port.VerifyConnections();
		}
	}

	public NodePort AddDynamicInput(Type type, ConnectionType connectionType = ConnectionType.Multiple, TypeConstraint typeConstraint = TypeConstraint.None, string fieldName = null)
	{
		return AddDynamicPort(type, NodePort.IO.Input, connectionType, typeConstraint, fieldName);
	}

	public NodePort AddDynamicOutput(Type type, ConnectionType connectionType = ConnectionType.Multiple, TypeConstraint typeConstraint = TypeConstraint.None, string fieldName = null)
	{
		return AddDynamicPort(type, NodePort.IO.Output, connectionType, typeConstraint, fieldName);
	}

	private NodePort AddDynamicPort(Type type, NodePort.IO direction, ConnectionType connectionType = ConnectionType.Multiple, TypeConstraint typeConstraint = TypeConstraint.None, string fieldName = null)
	{
		if (fieldName == null)
		{
			fieldName = "dynamicInput_0";
			int num = 0;
			while (HasPort(fieldName))
			{
				int num2 = ++num;
				fieldName = "dynamicInput_" + num2;
			}
		}
		else if (HasPort(fieldName))
		{
			Debug.LogWarning("Port '" + fieldName + "' already exists in " + base.name, this);
			return ports[fieldName];
		}
		NodePort nodePort = new NodePort(fieldName, type, direction, connectionType, typeConstraint, this);
		ports.Add(fieldName, nodePort);
		return nodePort;
	}

	public void RemoveDynamicPort(string fieldName)
	{
		if (GetPort(fieldName) == null)
		{
			throw new ArgumentException("port " + fieldName + " doesn't exist");
		}
		RemoveDynamicPort(GetPort(fieldName));
	}

	public void RemoveDynamicPort(NodePort port)
	{
		if (port == null)
		{
			throw new ArgumentNullException("port");
		}
		if (port.IsStatic)
		{
			throw new ArgumentException("cannot remove static port");
		}
		port.ClearConnections();
		ports.Remove(port.fieldName);
	}

	[ContextMenu("Clear Dynamic Ports")]
	public void ClearDynamicPorts()
	{
		foreach (NodePort item in new List<NodePort>(DynamicPorts))
		{
			RemoveDynamicPort(item);
		}
	}

	public NodePort GetOutputPort(string fieldName)
	{
		NodePort port = GetPort(fieldName);
		if (port == null || port.direction != NodePort.IO.Output)
		{
			return null;
		}
		return port;
	}

	public NodePort GetInputPort(string fieldName)
	{
		NodePort port = GetPort(fieldName);
		if (port == null || port.direction != 0)
		{
			return null;
		}
		return port;
	}

	public NodePort GetPort(string fieldName)
	{
		if (ports.TryGetValue(fieldName, out var value))
		{
			return value;
		}
		return null;
	}

	public bool HasPort(string fieldName)
	{
		return ports.ContainsKey(fieldName);
	}

	public T GetInputValue<T>(string fieldName, T fallback = default(T))
	{
		NodePort port = GetPort(fieldName);
		if (port != null && port.IsConnected)
		{
			return port.GetInputValue<T>();
		}
		return fallback;
	}

	public T[] GetInputValues<T>(string fieldName, params T[] fallback)
	{
		NodePort port = GetPort(fieldName);
		if (port != null && port.IsConnected)
		{
			return port.GetInputValues<T>();
		}
		return fallback;
	}

	public virtual object GetValue(NodePort port)
	{
		Debug.LogWarning("No GetValue(NodePort port) override defined for " + GetType());
		return null;
	}

	public virtual void OnCreateConnection(NodePort from, NodePort to)
	{
	}

	public virtual void OnRemoveConnection(NodePort port)
	{
	}

	public void ClearConnections()
	{
		foreach (NodePort port in Ports)
		{
			port.ClearConnections();
		}
	}
}
