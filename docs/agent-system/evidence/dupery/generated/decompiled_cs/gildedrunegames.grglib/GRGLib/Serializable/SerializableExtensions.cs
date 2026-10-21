using System.Collections.Generic;
using UnityEngine;

namespace GRGLib.Serializable;

public static class SerializableExtensions
{
	public static STupple<T, T2> toSTupple<T, T2>(this (T, T2) _val)
	{
		return new STupple<T, T2>(_val.Item1, _val.Item2);
	}

	public static STupple<T, T2, T3> toSTupple<T, T2, T3>(this (T, T2, T3) _val)
	{
		return new STupple<T, T2, T3>(_val.Item1, _val.Item2, _val.Item3);
	}

	public static Dictionary<T, T2> unserialize<T, T2>(this SerializableDictionary<T, T2> _dict)
	{
		Dictionary<T, T2> dictionary = new Dictionary<T, T2>();
		foreach (KeyValuePair<T, T2> item in _dict)
		{
			dictionary[item.Key] = item.Value;
		}
		return dictionary;
	}

	public static SerializableDictionary<T, T2> makeSerializable<T, T2>(this Dictionary<T, T2> _dict)
	{
		SerializableDictionary<T, T2> serializableDictionary = new SerializableDictionary<T, T2>();
		foreach (KeyValuePair<T, T2> item in _dict)
		{
			serializableDictionary[item.Key] = item.Value;
		}
		return serializableDictionary;
	}

	public static Vector2Int toVector2Int(this STupple<int, int> _tupple)
	{
		return new Vector2Int(_tupple.Item1, _tupple.Item2);
	}

	public static SerializableVector2 serialize(this Vector2 _v2)
	{
		return new SerializableVector2(_v2);
	}

	public static SerializableVector3 toSVector3(this Vector3 _v3)
	{
		return new SerializableVector3(_v3);
	}

	public static SerializableVector2 toSVector2(this Vector3 _v3)
	{
		return new SerializableVector2(_v3);
	}

	public static Vector3 unserialize(this SerializableVector3 _val)
	{
		return new Vector3(_val.x, _val.y, _val.z);
	}
}
