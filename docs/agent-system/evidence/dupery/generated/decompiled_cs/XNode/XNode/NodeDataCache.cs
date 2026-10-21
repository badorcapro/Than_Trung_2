using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using UnityEngine;
using UnityEngine.Serialization;

namespace XNode;

public static class NodeDataCache
{
	[Serializable]
	private class PortDataCache : Dictionary<Type, Dictionary<string, NodePort>>
	{
	}

	private static PortDataCache portDataCache;

	private static Dictionary<Type, Dictionary<string, string>> formerlySerializedAsCache;

	private static Dictionary<Type, string> typeQualifiedNameCache;

	private static bool Initialized => portDataCache != null;

	public static string GetTypeQualifiedName(Type type)
	{
		if (typeQualifiedNameCache == null)
		{
			typeQualifiedNameCache = new Dictionary<Type, string>();
		}
		if (!typeQualifiedNameCache.TryGetValue(type, out var value))
		{
			value = type.AssemblyQualifiedName;
			typeQualifiedNameCache.Add(type, value);
		}
		return value;
	}

	public static void UpdatePorts(Node node, Dictionary<string, NodePort> ports)
	{
		if (!Initialized)
		{
			BuildCache();
		}
		Dictionary<string, List<NodePort>> dictionary = new Dictionary<string, List<NodePort>>();
		Type type = node.GetType();
		Dictionary<string, string> value = null;
		if (formerlySerializedAsCache != null)
		{
			formerlySerializedAsCache.TryGetValue(type, out value);
		}
		List<NodePort> list = new List<NodePort>();
		if (!portDataCache.TryGetValue(type, out var value2))
		{
			value2 = new Dictionary<string, NodePort>();
		}
		NodePort[] array = ports.Values.ToArray();
		foreach (NodePort nodePort in array)
		{
			if (value2.TryGetValue(nodePort.fieldName, out var value3))
			{
				if (nodePort.IsDynamic || nodePort.direction != value3.direction || nodePort.connectionType != value3.connectionType || nodePort.typeConstraint != value3.typeConstraint)
				{
					if (!nodePort.IsDynamic && nodePort.direction == value3.direction)
					{
						dictionary.Add(nodePort.fieldName, nodePort.GetConnections());
					}
					nodePort.ClearConnections();
					ports.Remove(nodePort.fieldName);
				}
				else
				{
					nodePort.ValueType = value3.ValueType;
				}
			}
			else if (nodePort.IsStatic)
			{
				string value4 = null;
				if (value != null && value.TryGetValue(nodePort.fieldName, out value4))
				{
					dictionary.Add(value4, nodePort.GetConnections());
				}
				nodePort.ClearConnections();
				ports.Remove(nodePort.fieldName);
			}
			else if (IsDynamicListPort(nodePort))
			{
				list.Add(nodePort);
			}
		}
		foreach (NodePort value6 in value2.Values)
		{
			if (ports.ContainsKey(value6.fieldName))
			{
				continue;
			}
			NodePort nodePort2 = new NodePort(value6, node);
			if (dictionary.TryGetValue(value6.fieldName, out var value5))
			{
				for (int j = 0; j < value5.Count; j++)
				{
					NodePort nodePort3 = value5[j];
					if (nodePort3 != null && nodePort2.CanConnectTo(nodePort3))
					{
						nodePort2.Connect(nodePort3);
					}
				}
			}
			ports.Add(value6.fieldName, nodePort2);
		}
		foreach (NodePort item in list)
		{
			string key = item.fieldName.Substring(0, item.fieldName.IndexOf(' '));
			NodePort nodePort4 = value2[key];
			item.ValueType = GetBackingValueType(nodePort4.ValueType);
			item.direction = nodePort4.direction;
			item.connectionType = nodePort4.connectionType;
			item.typeConstraint = nodePort4.typeConstraint;
		}
	}

	private static Type GetBackingValueType(Type portValType)
	{
		if (portValType.HasElementType)
		{
			return portValType.GetElementType();
		}
		if (portValType.IsGenericType && portValType.GetGenericTypeDefinition() == typeof(List<>))
		{
			return portValType.GetGenericArguments()[0];
		}
		return portValType;
	}

	private static bool IsDynamicListPort(NodePort port)
	{
		string[] array = port.fieldName.Split(' ');
		if (array.Length != 2)
		{
			return false;
		}
		FieldInfo field = port.node.GetType().GetField(array[0]);
		if (field == null)
		{
			return false;
		}
		return field.GetCustomAttributes(inherit: true).Any(delegate(object x)
		{
			Node.InputAttribute inputAttribute = x as Node.InputAttribute;
			Node.OutputAttribute outputAttribute = x as Node.OutputAttribute;
			return (inputAttribute != null && inputAttribute.dynamicPortList) || (outputAttribute?.dynamicPortList ?? false);
		});
	}

	private static void BuildCache()
	{
		portDataCache = new PortDataCache();
		Type baseType = typeof(Node);
		List<Type> list = new List<Type>();
		Assembly[] assemblies = AppDomain.CurrentDomain.GetAssemblies();
		foreach (Assembly assembly in assemblies)
		{
			string text = assembly.GetName().Name;
			int num = text.IndexOf('.');
			if (num != -1)
			{
				text = text.Substring(0, num);
			}
			switch (text)
			{
			case "UnityEditor":
			case "UnityEngine":
			case "Unity":
			case "System":
			case "mscorlib":
			case "Microsoft":
				continue;
			}
			list.AddRange((from t in assembly.GetTypes()
				where !t.IsAbstract && baseType.IsAssignableFrom(t)
				select t).ToArray());
		}
		for (int j = 0; j < list.Count; j++)
		{
			CachePorts(list[j]);
		}
	}

	public static List<FieldInfo> GetNodeFields(Type nodeType)
	{
		List<FieldInfo> list = new List<FieldInfo>(nodeType.GetFields(BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic));
		Type type = nodeType;
		while ((type = type.BaseType) != typeof(Node))
		{
			FieldInfo[] fields = type.GetFields(BindingFlags.Instance | BindingFlags.NonPublic);
			foreach (FieldInfo parentField in fields)
			{
				if (list.TrueForAll((FieldInfo x) => x.Name != parentField.Name))
				{
					list.Add(parentField);
				}
			}
		}
		return list;
	}

	private static void CachePorts(Type nodeType)
	{
		List<FieldInfo> nodeFields = GetNodeFields(nodeType);
		for (int i = 0; i < nodeFields.Count; i++)
		{
			object[] customAttributes = nodeFields[i].GetCustomAttributes(inherit: true);
			Node.InputAttribute inputAttribute = customAttributes.FirstOrDefault((object x) => x is Node.InputAttribute) as Node.InputAttribute;
			Node.OutputAttribute outputAttribute = customAttributes.FirstOrDefault((object x) => x is Node.OutputAttribute) as Node.OutputAttribute;
			FormerlySerializedAsAttribute formerlySerializedAsAttribute = customAttributes.FirstOrDefault((object x) => x is FormerlySerializedAsAttribute) as FormerlySerializedAsAttribute;
			if (inputAttribute == null && outputAttribute == null)
			{
				continue;
			}
			if (inputAttribute != null && outputAttribute != null)
			{
				Debug.LogError("Field " + nodeFields[i].Name + " of type " + nodeType.FullName + " cannot be both input and output.");
			}
			else
			{
				if (!portDataCache.ContainsKey(nodeType))
				{
					portDataCache.Add(nodeType, new Dictionary<string, NodePort>());
				}
				NodePort nodePort = new NodePort(nodeFields[i]);
				portDataCache[nodeType].Add(nodePort.fieldName, nodePort);
			}
			if (formerlySerializedAsAttribute != null)
			{
				if (formerlySerializedAsCache == null)
				{
					formerlySerializedAsCache = new Dictionary<Type, Dictionary<string, string>>();
				}
				if (!formerlySerializedAsCache.ContainsKey(nodeType))
				{
					formerlySerializedAsCache.Add(nodeType, new Dictionary<string, string>());
				}
				if (formerlySerializedAsCache[nodeType].ContainsKey(formerlySerializedAsAttribute.oldName))
				{
					Debug.LogError("Another FormerlySerializedAs with value '" + formerlySerializedAsAttribute.oldName + "' already exist on this node.");
				}
				else
				{
					formerlySerializedAsCache[nodeType].Add(formerlySerializedAsAttribute.oldName, nodeFields[i].Name);
				}
			}
		}
	}
}
