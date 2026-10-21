using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;

namespace XNode;

[Serializable]
public class NodePort
{
	public enum IO
	{
		Input,
		Output
	}

	[Serializable]
	private class PortConnection
	{
		[SerializeField]
		public string fieldName;

		[SerializeField]
		public Node node;

		[NonSerialized]
		private NodePort port;

		[SerializeField]
		public List<Vector2> reroutePoints = new List<Vector2>();

		public NodePort Port
		{
			get
			{
				if (port == null)
				{
					return port = GetPort();
				}
				return port;
			}
		}

		public PortConnection(NodePort port)
		{
			this.port = port;
			node = port.node;
			fieldName = port.fieldName;
		}

		private NodePort GetPort()
		{
			if (node == null || string.IsNullOrEmpty(fieldName))
			{
				return null;
			}
			return node.GetPort(fieldName);
		}
	}

	private Type valueType;

	[SerializeField]
	private string _fieldName;

	[SerializeField]
	private Node _node;

	[SerializeField]
	private string _typeQualifiedName;

	[SerializeField]
	private List<PortConnection> connections = new List<PortConnection>();

	[SerializeField]
	private IO _direction;

	[SerializeField]
	private Node.ConnectionType _connectionType;

	[SerializeField]
	private Node.TypeConstraint _typeConstraint;

	[SerializeField]
	private bool _dynamic;

	public int ConnectionCount => connections.Count;

	public NodePort Connection
	{
		get
		{
			for (int i = 0; i < connections.Count; i++)
			{
				if (connections[i] != null)
				{
					return connections[i].Port;
				}
			}
			return null;
		}
	}

	public IO direction
	{
		get
		{
			return _direction;
		}
		internal set
		{
			_direction = value;
		}
	}

	public Node.ConnectionType connectionType
	{
		get
		{
			return _connectionType;
		}
		internal set
		{
			_connectionType = value;
		}
	}

	public Node.TypeConstraint typeConstraint
	{
		get
		{
			return _typeConstraint;
		}
		internal set
		{
			_typeConstraint = value;
		}
	}

	public bool IsConnected => connections.Count != 0;

	public bool IsInput => direction == IO.Input;

	public bool IsOutput => direction == IO.Output;

	public string fieldName => _fieldName;

	public Node node => _node;

	public bool IsDynamic => _dynamic;

	public bool IsStatic => !_dynamic;

	public Type ValueType
	{
		get
		{
			if (valueType == null && !string.IsNullOrEmpty(_typeQualifiedName))
			{
				valueType = Type.GetType(_typeQualifiedName, throwOnError: false);
			}
			return valueType;
		}
		set
		{
			if (!(valueType == value))
			{
				valueType = value;
				if (value != null)
				{
					_typeQualifiedName = NodeDataCache.GetTypeQualifiedName(value);
				}
			}
		}
	}

	public NodePort(FieldInfo fieldInfo)
	{
		_fieldName = fieldInfo.Name;
		ValueType = fieldInfo.FieldType;
		_dynamic = false;
		object[] customAttributes = fieldInfo.GetCustomAttributes(inherit: false);
		for (int i = 0; i < customAttributes.Length; i++)
		{
			if (customAttributes[i] is Node.InputAttribute)
			{
				_direction = IO.Input;
				_connectionType = (customAttributes[i] as Node.InputAttribute).connectionType;
				_typeConstraint = (customAttributes[i] as Node.InputAttribute).typeConstraint;
			}
			else if (customAttributes[i] is Node.OutputAttribute)
			{
				_direction = IO.Output;
				_connectionType = (customAttributes[i] as Node.OutputAttribute).connectionType;
				_typeConstraint = (customAttributes[i] as Node.OutputAttribute).typeConstraint;
			}
			if (customAttributes[i] is PortTypeOverrideAttribute)
			{
				ValueType = (customAttributes[i] as PortTypeOverrideAttribute).type;
			}
		}
	}

	public NodePort(NodePort nodePort, Node node)
	{
		_fieldName = nodePort._fieldName;
		ValueType = nodePort.valueType;
		_direction = nodePort.direction;
		_dynamic = nodePort._dynamic;
		_connectionType = nodePort._connectionType;
		_typeConstraint = nodePort._typeConstraint;
		_node = node;
	}

	public NodePort(string fieldName, Type type, IO direction, Node.ConnectionType connectionType, Node.TypeConstraint typeConstraint, Node node)
	{
		_fieldName = fieldName;
		ValueType = type;
		_direction = direction;
		_node = node;
		_dynamic = true;
		_connectionType = connectionType;
		_typeConstraint = typeConstraint;
	}

	public void VerifyConnections()
	{
		for (int num = connections.Count - 1; num >= 0; num--)
		{
			if (!(connections[num].node != null) || string.IsNullOrEmpty(connections[num].fieldName) || connections[num].node.GetPort(connections[num].fieldName) == null)
			{
				connections.RemoveAt(num);
			}
		}
	}

	public object GetOutputValue()
	{
		if (direction == IO.Input)
		{
			return null;
		}
		return node.GetValue(this);
	}

	public object GetInputValue()
	{
		return Connection?.GetOutputValue();
	}

	public object[] GetInputValues()
	{
		object[] array = new object[ConnectionCount];
		for (int i = 0; i < ConnectionCount; i++)
		{
			NodePort port = connections[i].Port;
			if (port == null)
			{
				connections.RemoveAt(i);
				i--;
			}
			else
			{
				array[i] = port.GetOutputValue();
			}
		}
		return array;
	}

	public T GetInputValue<T>()
	{
		object inputValue = GetInputValue();
		if (!(inputValue is T))
		{
			return default(T);
		}
		return (T)inputValue;
	}

	public T[] GetInputValues<T>()
	{
		object[] inputValues = GetInputValues();
		T[] array = new T[inputValues.Length];
		for (int i = 0; i < inputValues.Length; i++)
		{
			if (inputValues[i] is T)
			{
				array[i] = (T)inputValues[i];
			}
		}
		return array;
	}

	public bool TryGetInputValue<T>(out T value)
	{
		object inputValue = GetInputValue();
		if (inputValue is T)
		{
			value = (T)inputValue;
			return true;
		}
		value = default(T);
		return false;
	}

	public float GetInputSum(float fallback)
	{
		object[] inputValues = GetInputValues();
		if (inputValues.Length == 0)
		{
			return fallback;
		}
		float num = 0f;
		for (int i = 0; i < inputValues.Length; i++)
		{
			if (inputValues[i] is float)
			{
				num += (float)inputValues[i];
			}
		}
		return num;
	}

	public int GetInputSum(int fallback)
	{
		object[] inputValues = GetInputValues();
		if (inputValues.Length == 0)
		{
			return fallback;
		}
		int num = 0;
		for (int i = 0; i < inputValues.Length; i++)
		{
			if (inputValues[i] is int)
			{
				num += (int)inputValues[i];
			}
		}
		return num;
	}

	public void Connect(NodePort port)
	{
		if (connections == null)
		{
			connections = new List<PortConnection>();
		}
		if (port == null)
		{
			Debug.LogWarning("Cannot connect to null port");
			return;
		}
		if (port == this)
		{
			Debug.LogWarning("Cannot connect port to self.");
			return;
		}
		if (IsConnectedTo(port))
		{
			Debug.LogWarning("Port already connected. ");
			return;
		}
		if (direction == port.direction)
		{
			Debug.LogWarning("Cannot connect two " + ((direction == IO.Input) ? "input" : "output") + " connections");
			return;
		}
		if (port.connectionType == Node.ConnectionType.Override && port.ConnectionCount != 0)
		{
			port.ClearConnections();
		}
		if (connectionType == Node.ConnectionType.Override && ConnectionCount != 0)
		{
			ClearConnections();
		}
		connections.Add(new PortConnection(port));
		if (port.connections == null)
		{
			port.connections = new List<PortConnection>();
		}
		if (!port.IsConnectedTo(this))
		{
			port.connections.Add(new PortConnection(this));
		}
		node.OnCreateConnection(this, port);
		port.node.OnCreateConnection(this, port);
	}

	public List<NodePort> GetConnections()
	{
		List<NodePort> list = new List<NodePort>();
		for (int i = 0; i < connections.Count; i++)
		{
			NodePort connection = GetConnection(i);
			if (connection != null)
			{
				list.Add(connection);
			}
		}
		return list;
	}

	public NodePort GetConnection(int i)
	{
		if (connections[i].node == null || string.IsNullOrEmpty(connections[i].fieldName))
		{
			connections.RemoveAt(i);
			return null;
		}
		NodePort port = connections[i].node.GetPort(connections[i].fieldName);
		if (port == null)
		{
			connections.RemoveAt(i);
			return null;
		}
		return port;
	}

	public int GetConnectionIndex(NodePort port)
	{
		for (int i = 0; i < ConnectionCount; i++)
		{
			if (connections[i].Port == port)
			{
				return i;
			}
		}
		return -1;
	}

	public bool IsConnectedTo(NodePort port)
	{
		for (int i = 0; i < connections.Count; i++)
		{
			if (connections[i].Port == port)
			{
				return true;
			}
		}
		return false;
	}

	public bool CanConnectTo(NodePort port)
	{
		NodePort nodePort = null;
		NodePort nodePort2 = null;
		if (IsInput)
		{
			nodePort = this;
		}
		else
		{
			nodePort2 = this;
		}
		if (port.IsInput)
		{
			nodePort = port;
		}
		else
		{
			nodePort2 = port;
		}
		if (nodePort == null || nodePort2 == null)
		{
			return false;
		}
		if (nodePort.typeConstraint == Node.TypeConstraint.Inherited && !nodePort.ValueType.IsAssignableFrom(nodePort2.ValueType))
		{
			return false;
		}
		if (nodePort.typeConstraint == Node.TypeConstraint.Strict && nodePort.ValueType != nodePort2.ValueType)
		{
			return false;
		}
		if (nodePort.typeConstraint == Node.TypeConstraint.InheritedInverse && !nodePort2.ValueType.IsAssignableFrom(nodePort.ValueType))
		{
			return false;
		}
		if (nodePort.typeConstraint == Node.TypeConstraint.InheritedAny && !nodePort.ValueType.IsAssignableFrom(nodePort2.ValueType) && !nodePort2.ValueType.IsAssignableFrom(nodePort.ValueType))
		{
			return false;
		}
		if (nodePort2.typeConstraint == Node.TypeConstraint.Inherited && !nodePort.ValueType.IsAssignableFrom(nodePort2.ValueType))
		{
			return false;
		}
		if (nodePort2.typeConstraint == Node.TypeConstraint.Strict && nodePort.ValueType != nodePort2.ValueType)
		{
			return false;
		}
		if (nodePort2.typeConstraint == Node.TypeConstraint.InheritedInverse && !nodePort2.ValueType.IsAssignableFrom(nodePort.ValueType))
		{
			return false;
		}
		if (nodePort2.typeConstraint == Node.TypeConstraint.InheritedAny && !nodePort.ValueType.IsAssignableFrom(nodePort2.ValueType) && !nodePort2.ValueType.IsAssignableFrom(nodePort.ValueType))
		{
			return false;
		}
		return true;
	}

	public void Disconnect(NodePort port)
	{
		for (int num = connections.Count - 1; num >= 0; num--)
		{
			if (connections[num].Port == port)
			{
				connections.RemoveAt(num);
			}
		}
		if (port != null)
		{
			for (int i = 0; i < port.connections.Count; i++)
			{
				if (port.connections[i].Port == this)
				{
					port.connections.RemoveAt(i);
					port.node.OnRemoveConnection(port);
				}
			}
		}
		node.OnRemoveConnection(this);
	}

	public void Disconnect(int i)
	{
		NodePort port = connections[i].Port;
		port?.connections.RemoveAll((PortConnection it) => it.Port == this);
		connections.RemoveAt(i);
		node.OnRemoveConnection(this);
		port?.node.OnRemoveConnection(port);
	}

	public void ClearConnections()
	{
		while (connections.Count > 0)
		{
			Disconnect(connections[0].Port);
		}
	}

	public List<Vector2> GetReroutePoints(int index)
	{
		return connections[index].reroutePoints;
	}

	public void SwapConnections(NodePort targetPort)
	{
		int count = connections.Count;
		int count2 = targetPort.connections.Count;
		List<NodePort> list = new List<NodePort>();
		List<NodePort> list2 = new List<NodePort>();
		for (int i = 0; i < count; i++)
		{
			list.Add(connections[i].Port);
		}
		for (int j = 0; j < count2; j++)
		{
			list2.Add(targetPort.connections[j].Port);
		}
		ClearConnections();
		targetPort.ClearConnections();
		for (int k = 0; k < list.Count; k++)
		{
			targetPort.Connect(list[k]);
		}
		for (int l = 0; l < list2.Count; l++)
		{
			Connect(list2[l]);
		}
	}

	public void AddConnections(NodePort targetPort)
	{
		int connectionCount = targetPort.ConnectionCount;
		for (int i = 0; i < connectionCount; i++)
		{
			NodePort port = targetPort.connections[i].Port;
			Connect(port);
		}
	}

	public void MoveConnections(NodePort targetPort)
	{
		int count = connections.Count;
		for (int i = 0; i < count; i++)
		{
			NodePort port = targetPort.connections[i].Port;
			Connect(port);
		}
		ClearConnections();
	}

	public void Redirect(List<Node> oldNodes, List<Node> newNodes)
	{
		foreach (PortConnection connection in connections)
		{
			int num = oldNodes.IndexOf(connection.node);
			if (num >= 0)
			{
				connection.node = newNodes[num];
			}
		}
	}
}
