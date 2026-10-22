using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace GRGLib.Serializable;

[Serializable]
public class SerializableDictionary
{
}
[Serializable]
public class SerializableDictionary<TKey, TValue> : SerializableDictionary, ISerializationCallbackReceiver, IDictionary<TKey, TValue>, ICollection<KeyValuePair<TKey, TValue>>, IEnumerable<KeyValuePair<TKey, TValue>>, IEnumerable
{
	[Serializable]
	public struct SerializableKeyValuePair
	{
		public TKey Key;

		public TValue Value;

		public SerializableKeyValuePair(TKey key, TValue value)
		{
			Key = key;
			Value = value;
		}
	}

	[SerializeField]
	private List<SerializableKeyValuePair> list = new List<SerializableKeyValuePair>();

	private Lazy<Dictionary<TKey, uint>> _keyPositions;

	private Dictionary<TKey, uint> KeyPositions => _keyPositions.Value;

	public TValue this[TKey key]
	{
		get
		{
			return list[(int)KeyPositions[key]].Value;
		}
		set
		{
			if (KeyPositions.TryGetValue(key, out var value2))
			{
				list[(int)value2] = new SerializableKeyValuePair(key, value);
				return;
			}
			KeyPositions[key] = (uint)list.Count;
			list.Add(new SerializableKeyValuePair(key, value));
		}
	}

	public ICollection<TKey> Keys => list.Select((SerializableKeyValuePair tuple) => tuple.Key).ToArray();

	public ICollection<TValue> Values => list.Select((SerializableKeyValuePair tuple) => tuple.Value).ToArray();

	public int Count => list.Count;

	public bool IsReadOnly => false;

	public SerializableDictionary()
	{
		_keyPositions = new Lazy<Dictionary<TKey, uint>>(MakeKeyPositions);
	}

	private Dictionary<TKey, uint> MakeKeyPositions()
	{
		int count = list.Count;
		Dictionary<TKey, uint> dictionary = new Dictionary<TKey, uint>(count);
		for (int i = 0; i < count; i++)
		{
			dictionary[list[i].Key] = (uint)i;
		}
		return dictionary;
	}

	public void OnBeforeSerialize()
	{
	}

	public void OnAfterDeserialize()
	{
		_keyPositions = new Lazy<Dictionary<TKey, uint>>(MakeKeyPositions);
	}

	public void Add(TKey key, TValue value)
	{
		if (KeyPositions.ContainsKey(key))
		{
			throw new ArgumentException("An element with the same key already exists in the dictionary.");
		}
		KeyPositions[key] = (uint)list.Count;
		list.Add(new SerializableKeyValuePair(key, value));
	}

	public bool ContainsKey(TKey key)
	{
		return KeyPositions.ContainsKey(key);
	}

	public bool Remove(TKey key)
	{
		if (KeyPositions.TryGetValue(key, out var value))
		{
			Dictionary<TKey, uint> keyPositions = KeyPositions;
			keyPositions.Remove(key);
			int count = keyPositions.Count;
			list.RemoveAt((int)value);
			for (uint num = value; num < count; num++)
			{
				keyPositions[list[(int)num].Key] = num;
			}
			return true;
		}
		return false;
	}

	public bool TryGetValue(TKey key, out TValue value)
	{
		if (KeyPositions.TryGetValue(key, out var value2))
		{
			value = list[(int)value2].Value;
			return true;
		}
		value = default(TValue);
		return false;
	}

	public void Add(KeyValuePair<TKey, TValue> kvp)
	{
		Add(kvp.Key, kvp.Value);
	}

	public void Clear()
	{
		list.Clear();
	}

	public bool Contains(KeyValuePair<TKey, TValue> kvp)
	{
		return KeyPositions.ContainsKey(kvp.Key);
	}

	public void CopyTo(KeyValuePair<TKey, TValue>[] array, int arrayIndex)
	{
		int count = list.Count;
		if (array.Length - arrayIndex < count)
		{
			throw new ArgumentException("arrayIndex");
		}
		int num = 0;
		while (num < count)
		{
			SerializableKeyValuePair serializableKeyValuePair = list[num];
			array[arrayIndex] = new KeyValuePair<TKey, TValue>(serializableKeyValuePair.Key, serializableKeyValuePair.Value);
			num++;
			arrayIndex++;
		}
	}

	public bool Remove(KeyValuePair<TKey, TValue> kvp)
	{
		return Remove(kvp.Key);
	}

	public IEnumerator<KeyValuePair<TKey, TValue>> GetEnumerator()
	{
		return list.Select(ToKeyValuePair).GetEnumerator();
		static KeyValuePair<TKey, TValue> ToKeyValuePair(SerializableKeyValuePair skvp)
		{
			return new KeyValuePair<TKey, TValue>(skvp.Key, skvp.Value);
		}
	}

	IEnumerator IEnumerable.GetEnumerator()
	{
		return GetEnumerator();
	}
}
