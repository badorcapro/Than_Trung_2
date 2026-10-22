using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Numbers;
using GRGLib.Maybe;
using GRGLib.Serializable;
using UnityEngine;

namespace GRGLib.Extensions.Collections;

public static class CollectionsExtension
{
	public static List<T> copy<T>(this List<T> _list)
	{
		List<T> new_list = new List<T>();
		_list.ForEach(delegate(T _e)
		{
			new_list.Add(_e);
		});
		return new_list;
	}

	public static List<T> add<T>(this List<T> _l, T _e, int _nb = 1)
	{
		for (int i = 0; i < _nb; i++)
		{
			_l.Add(_e);
		}
		return _l;
	}

	public static List<T> add<T>(this List<T> _l, params T[] _es)
	{
		return _l.addRange(_es);
	}

	public static List<T> addIfNotDuplicate<T>(this List<T> _l, T _e)
	{
		if (_l.Contains(_e))
		{
			return _l;
		}
		return _l.add(_e);
	}

	public static List<T> addIfSome<T>(this List<T> _list, Maybe<T> _maybe)
	{
		if (_maybe.is_some)
		{
			_list.Add(_maybe.value);
		}
		return _list;
	}

	public static List<T> addRange<T>(this List<T> _l, IEnumerable<T> _e)
	{
		_l.AddRange(_e);
		return _l;
	}

	public static List<T> sort<T>(this List<T> _list, Comparison<T> _comparison)
	{
		_list.Sort(_comparison);
		return _list;
	}

	public static List<T> sort<T>(this List<T> _list)
	{
		_list.Sort();
		return _list;
	}

	public static (List<T>, List<T>) split<T>(this IEnumerable<T> _list, Func<T, bool> _splitter)
	{
		List<T> list = new List<T>();
		List<T> list2 = new List<T>();
		foreach (T item in _list)
		{
			if (_splitter(item))
			{
				list.Add(item);
			}
			else
			{
				list2.Add(item);
			}
		}
		return (list, list2);
	}

	public static Dictionary<T2, List<T>> split<T, T2>(this IEnumerable<T> _list, Func<T, T2> _splitter)
	{
		Dictionary<T2, List<T>> dictionary = new Dictionary<T2, List<T>>();
		foreach (T item in _list)
		{
			T2 key = _splitter(item);
			dictionary.addOrCreate(key, item);
		}
		return dictionary;
	}

	public static List<T> makeListFromItem<T>(this T _item)
	{
		return new List<T> { _item };
	}

	public static List<T> makeListFromItem<T>(this T _item, int _nb)
	{
		List<T> list = _item.makeListFromItem();
		for (int i = 1; i < _nb; i++)
		{
			list.Add(_item);
		}
		return list;
	}

	public static List<T> makeListFromItems<T>(this T _item_1, params T[] _items)
	{
		return _item_1.makeListFromItem().addRange(_items);
	}

	public static List<T> addAll<T>(this List<T> _l) where T : Enum
	{
		foreach (object value in Enum.GetValues(typeof(T)))
		{
			_l.Add((T)value);
		}
		return _l;
	}

	public static List<T> addAll<T>(this List<T> _l, Func<T, bool> _condition) where T : Enum
	{
		foreach (T value in Enum.GetValues(typeof(T)))
		{
			if (_condition(value))
			{
				_l.Add(value);
			}
		}
		return _l;
	}

	public static List<T> reverse<T>(this List<T> _l)
	{
		_l.Reverse();
		return _l;
	}

	public static List<T> toListSafe<T>(this IEnumerable<T> _enum)
	{
		if (_enum == null || _enum.Count() == 0)
		{
			return new List<T>();
		}
		return _enum.ToList();
	}

	public static T last<T>(this List<T> _list)
	{
		return _list[_list.Count - 1];
	}

	public static List<T> removeAt<T>(this List<T> _list, int _index)
	{
		_list.RemoveAt(_index);
		return _list;
	}

	public static List<T> removeLast<T>(this List<T> _list)
	{
		return _list.removeAt(_list.Count - 1);
	}

	public static bool anyAfterIndex<T>(this List<T> _list, int _index, Func<T, bool> _compare)
	{
		for (int i = _index + 1; i < _list.Count; i++)
		{
			if (_compare(_list[i]))
			{
				return true;
			}
		}
		return false;
	}

	public static List<(T, T2)> toListTupple<T, T2>(this Dictionary<T, T2> _dict)
	{
		List<(T, T2)> list = new List<(T, T2)>();
		foreach (KeyValuePair<T, T2> item in _dict)
		{
			list.Add((item.Key, item.Value));
		}
		return list;
	}

	public static List<(T1, T2)> toListTupple<T1, T2>(this SerializableDictionary<T1, T2> _sd)
	{
		return _sd.Aggregate(new List<(T1, T2)>(), (List<(T1, T2)> _a, KeyValuePair<T1, T2> _b) => _a.add((_b.Key, _b.Value)));
	}

	public static List<STupple<T1, T2>> toListSTupple<T1, T2>(this Dictionary<T1, T2> _sd)
	{
		return _sd.Aggregate(new List<STupple<T1, T2>>(), (List<STupple<T1, T2>> _a, KeyValuePair<T1, T2> _b) => _a.add(new STupple<T1, T2>(_b.Key, _b.Value)));
	}

	public static List<STupple<T1, T2>> toListSTupple<T1, T2>(this SerializableDictionary<T1, T2> _sd)
	{
		return _sd.Aggregate(new List<STupple<T1, T2>>(), (List<STupple<T1, T2>> _a, KeyValuePair<T1, T2> _b) => _a.add(new STupple<T1, T2>(_b.Key, _b.Value)));
	}

	public static List<T> remove<T>(this List<T> _list, T _element)
	{
		_list.Remove(_element);
		return _list;
	}

	public static List<T> removeNull<T>(this List<T> _list)
	{
		if (!typeof(T).isNullable())
		{
			return _list;
		}
		List<T> list = new List<T>();
		foreach (T item in _list)
		{
			if (item == null)
			{
				list.add(item);
			}
		}
		foreach (T item2 in list)
		{
			_list.remove(item2);
		}
		return _list;
	}

	public static List<T> removeAllAfterIndex<T>(this List<T> _list, int _index)
	{
		if (_index >= _list.Count)
		{
			return _list;
		}
		_list.RemoveRange(_index, _list.Count - _index);
		return _list;
	}

	public static List<T> removeRange<T>(this List<T> _list, params T[] _to_remove)
	{
		return _list.removeAll((T _e) => _to_remove.Contains(_e));
	}

	public static List<T> removeRange<T>(this List<T> _list, HashSet<T> _to_remove)
	{
		return _list.removeAll((T _e) => _to_remove.Contains(_e));
	}

	public static List<T> removeRange<T>(this List<T> _list, List<T> _to_remove)
	{
		return _list.removeAll((T _e) => _to_remove.Contains(_e));
	}

	public static List<T> removeAll<T>(this List<T> _list, Predicate<T> _match)
	{
		_list.RemoveAll(_match);
		return _list;
	}

	public static List<T> removeFirst<T>(this List<T> _l, Predicate<T> _predicate)
	{
		for (int i = 0; i < _l.Count; i++)
		{
			if (_predicate(_l[i]))
			{
				return _l.remove(_l[i]);
			}
		}
		return _l;
	}

	public static void destroyAll(this List<Transform> _list)
	{
		_list.destroyAll((Transform _e) => _e.gameObject);
	}

	public static void destroyAll(this List<GameObject> _list)
	{
		_list.destroyAll((GameObject _e) => _e);
	}

	public static void destroyAll<T>(this List<T> _list) where T : MonoBehaviour
	{
		_list.destroyAll((T _e) => _e.gameObject);
	}

	public static void destroyAll<T>(this List<T> _list, Func<T, GameObject> _gameobject_getter)
	{
		_list.ForEach(delegate(T _el)
		{
			UnityEngine.Object.Destroy(_gameobject_getter(_el));
		});
		_list.Clear();
	}

	public static void destroyAllSafe(this List<Transform> _list)
	{
		_list.destroyAll((Transform _e) => _e.gameObject);
	}

	public static void destroyAllSafe(this List<GameObject> _list)
	{
		_list.destroyAll((GameObject _e) => _e);
	}

	public static void destroyAllSafe<T>(this List<T> _list) where T : MonoBehaviour
	{
		_list.destroyAll((T _e) => _e.gameObject);
	}

	public static void destroyAllSafe<T>(this List<T> _list, Func<T, GameObject> _gameobject_getter)
	{
		_list.ForEach(delegate(T _el)
		{
			if (_el != null)
			{
				UnityEngine.Object.Destroy(_gameobject_getter(_el));
			}
		});
		_list.Clear();
	}

	public static Maybe<T> firstIfSome<T>(this List<T> _l, Predicate<T> _predicate)
	{
		for (int i = 0; i < _l.Count; i++)
		{
			if (_predicate(_l[i]))
			{
				return _l[i].maybe();
			}
		}
		return new Maybe<T>();
	}

	public static HashSet<string> search(this List<string> _list, string _search, bool _exact_search = false, bool _lower_strings = true, bool _trim_search = true)
	{
		return _list.search(_search, (string _e) => _e, _exact_search, _lower_strings, _trim_search);
	}

	public static HashSet<T> search<T>(this List<T> _list, string _search, Func<T, string> _to_string, bool _exact_search = false, bool _lower_strings = true, bool _trim_search = true)
	{
		string text = (_trim_search ? _search.Trim() : _search);
		if (_lower_strings)
		{
			text = text.ToLower();
		}
		HashSet<T> hashSet = new HashSet<T>();
		foreach (T item in _list)
		{
			string text2 = _to_string(item);
			if (_lower_strings)
			{
				text2 = text2.ToLower();
			}
			if (_exact_search && text2 == text)
			{
				hashSet.Add(item);
			}
			else if (!_exact_search && text2.Contains(text))
			{
				hashSet.Add(item);
			}
		}
		return hashSet;
	}

	public static Maybe<string> searchFirst(this List<string> _list, string _search, bool _exact_search = false, bool _lower_strings = true, bool _trim_search = true)
	{
		return _list.searchFirst(_search, (string _e) => _e, _exact_search, _lower_strings, _trim_search);
	}

	public static Maybe<T> searchFirst<T>(this List<T> _list, string _search, Func<T, string> _to_string, bool _exact_search = false, bool _lower_strings = true, bool _trim_search = true)
	{
		string text = (_trim_search ? _search.Trim() : _search);
		if (_lower_strings)
		{
			text = text.ToLower();
		}
		foreach (T item in _list)
		{
			string text2 = _to_string(item);
			if (_lower_strings)
			{
				text2 = text2.ToLower();
			}
			if (_exact_search && text2 == text)
			{
				return item.maybe();
			}
			if (!_exact_search && text2.Contains(text))
			{
				return item.maybe();
			}
		}
		return new Maybe<T>();
	}

	public static Dictionary<T, T2> copy<T, T2>(this Dictionary<T, T2> _dict)
	{
		Dictionary<T, T2> dictionary = new Dictionary<T, T2>();
		foreach (KeyValuePair<T, T2> item in _dict)
		{
			dictionary[item.Key] = item.Value;
		}
		return dictionary;
	}

	public static SerializableDictionary<T, T2> copy<T, T2>(this SerializableDictionary<T, T2> _dict)
	{
		SerializableDictionary<T, T2> serializableDictionary = new SerializableDictionary<T, T2>();
		foreach (KeyValuePair<T, T2> item in _dict)
		{
			serializableDictionary[item.Key] = item.Value;
		}
		return serializableDictionary;
	}

	public static Dictionary<T, K> addTo<T, K>(this Dictionary<T, K> _dict, T _key, K _element)
	{
		_dict[_key] = _element;
		return _dict;
	}

	public static SerializableDictionary<T, K> addTo<T, K>(this SerializableDictionary<T, K> _dict, T _key, K _element)
	{
		_dict[_key] = _element;
		return _dict;
	}

	public static Dictionary<T, T2> toDictionary<T, T2>(this List<(T, T2)> _ti)
	{
		return _ti.Aggregate(new Dictionary<T, T2>(), (Dictionary<T, T2> _a, (T, T2) _b) => _a.addTo(_b.Item1, _b.Item2));
	}

	public static Dictionary<T, T2> toDictionary<T, T2>(this List<STupple<T, T2>> _ti)
	{
		return _ti.Aggregate(new Dictionary<T, T2>(), (Dictionary<T, T2> _a, STupple<T, T2> _b) => _a.addTo(_b.Item1, _b.Item2));
	}

	public static SerializableDictionary<T, T2> toSerializableDictionary<T, T2>(this List<(T, T2)> _ti)
	{
		return _ti.Aggregate(new SerializableDictionary<T, T2>(), (SerializableDictionary<T, T2> _a, (T, T2) _b) => _a.addTo(_b.Item1, _b.Item2));
	}

	public static SerializableDictionary<T, T2> toSerializableDictionary<T, T2>(this List<STupple<T, T2>> _ti)
	{
		return _ti.Aggregate(new SerializableDictionary<T, T2>(), (SerializableDictionary<T, T2> _a, STupple<T, T2> _b) => _a.addTo(_b.Item1, _b.Item2));
	}

	public static Dictionary<T, T2> makeDictionary<T, T2>(this T _key, T2 _value)
	{
		return new Dictionary<T, T2>().addTo(_key, _value);
	}

	public static Dictionary<T1, T2> toDictionary<T1, T2>(this IEnumerable<KeyValuePair<T1, T2>> _pairs)
	{
		Dictionary<T1, T2> to_return = new Dictionary<T1, T2>();
		_pairs.ToList().ForEach(delegate(KeyValuePair<T1, T2> _p)
		{
			to_return[_p.Key] = _p.Value;
		});
		return to_return;
	}

	public static SerializableDictionary<T1, T2> toSerializableDictionary<T1, T2>(this IEnumerable<KeyValuePair<T1, T2>> _pairs)
	{
		SerializableDictionary<T1, T2> to_return = new SerializableDictionary<T1, T2>();
		_pairs.ToList().ForEach(delegate(KeyValuePair<T1, T2> _p)
		{
			to_return[_p.Key] = _p.Value;
		});
		return to_return;
	}

	public static Dictionary<T1, T2> where<T1, T2>(this Dictionary<T1, T2> _dictionary, Func<T1, T2, bool> _predicate)
	{
		return _dictionary.Where((KeyValuePair<T1, T2> _p) => _predicate(_p.Key, _p.Value)).toDictionary();
	}

	public static Dictionary<T1, T3> select<T1, T2, T3>(this Dictionary<T1, T2> _dict, Func<T1, T2, T3> _conversion)
	{
		return _dict.Select((KeyValuePair<T1, T2> _p) => new KeyValuePair<T1, T3>(_p.Key, _conversion(_p.Key, _p.Value))).toDictionary();
	}

	public static Dictionary<T1, int> countToDictionary<T1>(this List<T1> _l)
	{
		return _l.Aggregate(new Dictionary<T1, int>(), delegate(Dictionary<T1, int> _a, T1 _b)
		{
			if (!_a.ContainsKey(_b))
			{
				_a[_b] = 0;
			}
			_a[_b]++;
			return _a;
		});
	}

	public static Dictionary<T1, T2> addRange<T1, T2>(this Dictionary<T1, T2> _first, Dictionary<T1, T2> _second)
	{
		_second.Keys.ToList().ForEach(delegate(T1 _k)
		{
			_first[_k] = _second[_k];
		});
		return _first;
	}

	public static Dictionary<T1, T2> maybeAddRange<T1, T2>(this Dictionary<T1, T2> _first, Maybe<Dictionary<T1, T2>> _second)
	{
		if (!_second.is_some)
		{
			return _first;
		}
		return _first.addRange(_second.value);
	}

	public static void destroyAll<T1>(this Dictionary<T1, Transform> _dict)
	{
		_dict.destroyAll((KeyValuePair<T1, Transform> _kvp) => _kvp.Value.gameObject);
	}

	public static void destroyAll<T1>(this Dictionary<T1, GameObject> _dict)
	{
		_dict.destroyAll((KeyValuePair<T1, GameObject> _kvp) => _kvp.Value);
	}

	public static void destroyAll<T1, T2>(this Dictionary<T1, T2> _dict) where T2 : MonoBehaviour
	{
		_dict.destroyAll((KeyValuePair<T1, T2> _kvp) => _kvp.Value.gameObject);
	}

	public static void destroyAll<T1, T2>(this Dictionary<T1, T2> _dict, Func<KeyValuePair<T1, T2>, GameObject> _game_object_getter)
	{
		foreach (KeyValuePair<T1, T2> item in _dict)
		{
			UnityEngine.Object.Destroy(_game_object_getter(item));
		}
		_dict.Clear();
	}

	public static void destroyAllSafe<T1>(this Dictionary<T1, GameObject> _dict)
	{
		_dict.destroyAllSafe((KeyValuePair<T1, GameObject> _kvp) => _kvp.Value);
	}

	public static void destroyAllSafe<T1, T2>(this Dictionary<T1, T2> _dict, Func<KeyValuePair<T1, T2>, GameObject> _game_object_getter)
	{
		foreach (KeyValuePair<T1, T2> item in _dict)
		{
			if (_game_object_getter(item) != null)
			{
				UnityEngine.Object.Destroy(_game_object_getter(item));
			}
		}
		_dict.Clear();
	}

	public static Maybe<T2> tryGet<T, T2>(this Dictionary<T, T2> _dict, T _key)
	{
		if (!_dict.ContainsKey(_key))
		{
			return new Maybe<T2>();
		}
		return _dict[_key].maybe();
	}

	public static Maybe<T2> tryGet<T, T2>(this SerializableDictionary<T, T2> _dict, T _key)
	{
		if (!_dict.ContainsKey(_key))
		{
			return new Maybe<T2>();
		}
		return _dict[_key].maybe();
	}

	public static T2 getOrCreate<T, T2>(this Dictionary<T, T2> _dict, T _key, T2 _default)
	{
		return _dict.getOrCreate(_key, () => _default);
	}

	public static T2 getOrCreate<T, T2>(this Dictionary<T, T2> _dict, T _key, Func<T2> _construtor)
	{
		if (!_dict.ContainsKey(_key))
		{
			_dict[_key] = _construtor();
		}
		return _dict[_key];
	}

	public static T2 getOrCreate<T, T2>(this SerializableDictionary<T, T2> _dict, T _key, T2 _default)
	{
		return _dict.getOrCreate(_key, () => _default);
	}

	public static T2 getOrCreate<T, T2>(this SerializableDictionary<T, T2> _dict, T _key, Func<T2> _construtor)
	{
		if (!_dict.ContainsKey(_key))
		{
			_dict[_key] = _construtor();
		}
		return _dict[_key];
	}

	public static T2 getOrDefault<T, T2>(this Dictionary<T, T2> _dict, Func<KeyValuePair<T, T2>, bool> _predicate, T2 _default)
	{
		return _dict.getOrDefault(_predicate, () => _default);
	}

	public static T2 getOrDefault<T, T2>(this Dictionary<T, T2> _dict, Func<KeyValuePair<T, T2>, bool> _predicate, Func<T2> _construtor)
	{
		foreach (KeyValuePair<T, T2> item in _dict)
		{
			if (_predicate(item))
			{
				return item.Value;
			}
		}
		return _construtor();
	}

	public static T2 getOrDefault<T, T2>(this SerializableDictionary<T, T2> _dict, Func<KeyValuePair<T, T2>, bool> _predicate, T2 _default)
	{
		return _dict.getOrDefault(_predicate, () => _default);
	}

	public static T2 getOrDefault<T, T2>(this SerializableDictionary<T, T2> _dict, Func<KeyValuePair<T, T2>, bool> _predicate, Func<T2> _construtor)
	{
		foreach (KeyValuePair<T, T2> item in _dict)
		{
			if (_predicate(item))
			{
				return item.Value;
			}
		}
		return _construtor();
	}

	public static T2 getOrDefault<T, T2>(this Dictionary<T, T2> _dict, T _key, T2 _default)
	{
		if (!_dict.ContainsKey(_key))
		{
			return _default;
		}
		return _dict[_key];
	}

	public static T2 getOrDefault<T, T2>(this SerializableDictionary<T, T2> _dict, T _key, T2 _default)
	{
		if (!_dict.ContainsKey(_key))
		{
			return _default;
		}
		return _dict[_key];
	}

	public static void addOrCreate<T, T2>(this Dictionary<T, List<T2>> _dict, T _key, T2 _value)
	{
		if (!_dict.ContainsKey(_key))
		{
			_dict[_key] = new List<T2>();
		}
		_dict[_key].Add(_value);
	}

	public static void addOrCreate<T, T2>(this SortedDictionary<T, List<T2>> _dict, T _key, T2 _value)
	{
		if (!_dict.ContainsKey(_key))
		{
			_dict[_key] = new List<T2>();
		}
		_dict[_key].Add(_value);
	}

	public static Dictionary<T1, int> increaseOrCreate<T1>(this Dictionary<T1, int> _dict, T1 _key, int _to_add)
	{
		if (_dict.ContainsKey(_key))
		{
			_dict[_key] += _to_add;
		}
		else
		{
			_dict[_key] = _to_add;
		}
		return _dict;
	}

	public static Dictionary<T1, int> increaseOrCreateRange<T1>(this Dictionary<T1, int> _first, Dictionary<T1, int> _second)
	{
		_second.Keys.ToList().ForEach(delegate(T1 _k)
		{
			if (_first.ContainsKey(_k))
			{
				_first[_k] += _second[_k];
			}
			else
			{
				_first[_k] = _second[_k];
			}
		});
		return _first;
	}

	public static Dictionary<T1, float> increaseOrCreate<T1>(this Dictionary<T1, float> _dict, T1 _key, float _to_add)
	{
		if (_dict.ContainsKey(_key))
		{
			_dict[_key] += _to_add;
		}
		else
		{
			_dict[_key] = _to_add;
		}
		return _dict;
	}

	public static Dictionary<T1, float> increaseOrCreateRange<T1>(this Dictionary<T1, float> _first, Dictionary<T1, float> _second)
	{
		_second.Keys.ToList().ForEach(delegate(T1 _k)
		{
			if (_first.ContainsKey(_k))
			{
				_first[_k] += _second[_k];
			}
			else
			{
				_first[_k] = _second[_k];
			}
		});
		return _first;
	}

	public static Maybe<(T, int)> getMin<T>(this Dictionary<T, int> _dict)
	{
		return _dict.getMost((int _v, int _h) => _v < _h);
	}

	public static Maybe<T> getMinKey<T>(this Dictionary<T, int> _dict)
	{
		return _dict.getMostKey((int _v, int _h) => _v < _h);
	}

	public static int getMinValue<T>(this Dictionary<T, int> _dict)
	{
		return _dict.getMostValue((int _v, int _h) => _v < _h);
	}

	public static Maybe<(T, int)> getMax<T>(this Dictionary<T, int> _dict)
	{
		return _dict.getMost((int _v, int _h) => _v > _h);
	}

	public static Maybe<T> getMaxKey<T>(this Dictionary<T, int> _dict)
	{
		return _dict.getMostKey((int _v, int _h) => _v > _h);
	}

	public static int getMaxValue<T>(this Dictionary<T, int> _dict)
	{
		return _dict.getMostValue((int _v, int _h) => _v > _h);
	}

	public static Maybe<(T, float)> getMin<T>(this Dictionary<T, float> _dict)
	{
		return _dict.getMost((float _v, float _h) => _v < _h);
	}

	public static Maybe<T> getMinKey<T>(this Dictionary<T, float> _dict)
	{
		return _dict.getMostKey((float _v, float _h) => _v < _h);
	}

	public static float getMinValue<T>(this Dictionary<T, float> _dict)
	{
		return _dict.getMostValue((float _v, float _h) => _v < _h);
	}

	public static Maybe<(T, float)> getMax<T>(this Dictionary<T, float> _dict)
	{
		return _dict.getMost((float _v, float _h) => _v > _h);
	}

	public static Maybe<T> getMaxKey<T>(this Dictionary<T, float> _dict)
	{
		return _dict.getMostKey((float _v, float _h) => _v > _h);
	}

	public static float getMaxValue<T>(this Dictionary<T, float> _dict)
	{
		return _dict.getMostValue((float _v, float _h) => _v > _h);
	}

	public static Maybe<T> getMostKey<T>(this Dictionary<T, int> _dict, Func<int, int, bool> _is_most)
	{
		return _dict.getMost(_is_most).returnModifiedValueIfSome(((T, int) _a) => _a.Item1);
	}

	public static int getMostValue<T>(this Dictionary<T, int> _dict, Func<int, int, bool> _is_most)
	{
		return _dict.getMost(_is_most).returnModifiedValueIfSome(((T, int) _a) => _a.Item2).returnValueOrDefault(0);
	}

	public static Maybe<T> getMostKey<T>(this Dictionary<T, float> _dict, Func<float, float, bool> _is_most)
	{
		return _dict.getMost(_is_most).returnModifiedValueIfSome(((T, float) _a) => _a.Item1);
	}

	public static float getMostValue<T>(this Dictionary<T, float> _dict, Func<float, float, bool> _is_most)
	{
		return _dict.getMost(_is_most).returnModifiedValueIfSome(((T, float) _a) => _a.Item2).returnValueOrDefault(0f);
	}

	public static Maybe<(T, T2)> getMost<T, T2>(this Dictionary<T, T2> _dict, Func<T2, T2, bool> _is_most)
	{
		Maybe<(T, T2)> maybe = new Maybe<(T, T2)>();
		foreach (KeyValuePair<T, T2> item in _dict)
		{
			if (!maybe.is_some || _is_most(item.Value, maybe.value.Item2))
			{
				maybe = new Maybe<(T, T2)>((item.Key, item.Value));
			}
		}
		return maybe;
	}

	public static bool isDictEqual<T, T2>(this Dictionary<T, T2> _dict1, Dictionary<T, T2> _dict2) where T2 : IComparable<T2>
	{
		if (_dict1.Count == _dict2.Count)
		{
			foreach (KeyValuePair<T, T2> item in _dict1)
			{
				if (_dict2.TryGetValue(item.Key, out var value))
				{
					if (value.CompareTo(item.Value) != 0)
					{
						return false;
					}
					continue;
				}
				return false;
			}
			return true;
		}
		return false;
	}

	public static bool checkElementInDictionary<T>(this Dictionary<T, int> _dict, T _key, int _to_compare, NumberComparaison _direction, bool _key_not_present_value = false)
	{
		if (!_dict.ContainsKey(_key))
		{
			return _key_not_present_value;
		}
		return _dict[_key].compareInt(_direction, _to_compare);
	}

	public static bool checkElementInDictionary<T>(this SerializableDictionary<T, int> _dict, T _key, int _to_compare, NumberComparaison _direction, bool _key_not_present_value = false)
	{
		if (!_dict.ContainsKey(_key))
		{
			return _key_not_present_value;
		}
		return _direction switch
		{
			NumberComparaison.BELOW => _dict[_key] < _to_compare, 
			NumberComparaison.ABOVE => _dict[_key] > _to_compare, 
			NumberComparaison.EXACT => _dict[_key] == _to_compare, 
			NumberComparaison.EXACT_AND_BELOW => _dict[_key] <= _to_compare, 
			NumberComparaison.EXACT_AND_ABOVE => _dict[_key] >= _to_compare, 
			_ => throw new ArgumentException($"Number comparaison '{_direction}' case not set up! In GenericHelper.checkElementInDictionary()"), 
		};
	}

	public static bool containsAny<T, T2>(this Dictionary<T, T2> _dict, List<T> _keys)
	{
		return _dict.containsAny(_keys.ToArray());
	}

	public static bool containsAny<T, T2>(this Dictionary<T, T2> _dict, params T[] _keys)
	{
		foreach (T key in _keys)
		{
			if (_dict.ContainsKey(key))
			{
				return true;
			}
		}
		return false;
	}

	public static bool containsAny<T, T2>(this SerializableDictionary<T, T2> _dict, List<T> _keys)
	{
		return _dict.containsAny(_keys.ToArray());
	}

	public static bool containsAny<T, T2>(this SerializableDictionary<T, T2> _dict, params T[] _keys)
	{
		foreach (T key in _keys)
		{
			if (_dict.ContainsKey(key))
			{
				return true;
			}
		}
		return false;
	}

	public static HashSet<T> searchKey<T, T2>(this Dictionary<T, T2> _dict, string _search, Func<KeyValuePair<T, T2>, string> _to_string, bool _exact_search = false, bool _lower_strings = true, bool _trim_search = true)
	{
		string text = (_trim_search ? _search.Trim() : _search);
		if (_lower_strings)
		{
			text = text.ToLower();
		}
		HashSet<T> hashSet = new HashSet<T>();
		foreach (KeyValuePair<T, T2> item in _dict)
		{
			string text2 = _to_string(item);
			if (_lower_strings)
			{
				text2 = text2.ToLower();
			}
			if (_exact_search && text2 == text)
			{
				hashSet.Add(item.Key);
			}
			else if (!_exact_search && text2.Contains(text))
			{
				hashSet.Add(item.Key);
			}
		}
		return hashSet;
	}

	public static HashSet<T2> search<T, T2>(this Dictionary<T, T2> _dict, string _search, Func<KeyValuePair<T, T2>, string> _to_string, bool _exact_search = false, bool _lower_strings = true, bool _trim_search = true)
	{
		string text = (_trim_search ? _search.Trim() : _search);
		if (_lower_strings)
		{
			text = text.ToLower();
		}
		HashSet<T2> hashSet = new HashSet<T2>();
		foreach (KeyValuePair<T, T2> item in _dict)
		{
			string text2 = _to_string(item);
			if (_lower_strings)
			{
				text2 = text2.ToLower();
			}
			if (_exact_search && text2 == text)
			{
				hashSet.Add(item.Value);
			}
			else if (!_exact_search && text2.Contains(text))
			{
				hashSet.Add(item.Value);
			}
		}
		return hashSet;
	}

	public static int sumValues<T>(this Dictionary<T, int> _dict)
	{
		return _dict.sumValues(0, (int _a, int _b) => _a + _b);
	}

	public static float sumValues<T>(this Dictionary<T, float> _dict)
	{
		return _dict.sumValues(0f, (float _a, float _b) => _a + _b);
	}

	public static double sumValues<T>(this Dictionary<T, double> _dict)
	{
		return _dict.sumValues(0.0, (double _a, double _b) => _a + _b);
	}

	public static T2 sumValues<T, T2>(this Dictionary<T, T2> _dict, T2 _zero_value, Func<T2, T2, T2> _add)
	{
		T2 val = _zero_value;
		foreach (T2 value in _dict.Values)
		{
			val = _add(val, value);
		}
		return val;
	}

	public static int sumKeys<T>(this Dictionary<int, T> _dict)
	{
		return _dict.sumKeys(0, (int _a, int _b) => _a + _b);
	}

	public static float sumKeys<T>(this Dictionary<float, T> _dict)
	{
		return _dict.sumKeys(0f, (float _a, float _b) => _a + _b);
	}

	public static double sumKeys<T>(this Dictionary<double, T> _dict)
	{
		return _dict.sumKeys(0.0, (double _a, double _b) => _a + _b);
	}

	public static T sumKeys<T, T2>(this Dictionary<T, T2> _dict, T _zero_value, Func<T, T, T> _add)
	{
		T val = _zero_value;
		foreach (T key in _dict.Keys)
		{
			val = _add(val, key);
		}
		return val;
	}

	public static bool ContainsIndex(this Array array, int index, int dimension)
	{
		if (index < 0)
		{
			return false;
		}
		return index < array.GetLength(dimension);
	}

	public static void forEach<T>(this T[] _array, Action<T> _action)
	{
		foreach (T obj in _array)
		{
			_action(obj);
		}
	}

	public static void forEach<T>(this HashSet<T> _hashset, Action<T> _action)
	{
		foreach (T item in _hashset)
		{
			_action(item);
		}
	}

	public static HashSet<T> copy<T>(this HashSet<T> _set)
	{
		return _set.toHashSet();
	}

	public static HashSet<T> toHashSet<T>(this IEnumerable<T> _l)
	{
		return new HashSet<T>().addRange(_l);
	}

	public static HashSet<T> add<T>(this HashSet<T> _set, T _value)
	{
		_set.Add(_value);
		return _set;
	}

	public static HashSet<T> addRange<T>(this HashSet<T> _set, IEnumerable<T> _range)
	{
		foreach (T item in _range)
		{
			_set.Add(item);
		}
		return _set;
	}

	public static bool exists<T>(this HashSet<T> _hashSet, Func<T, bool> _comparison)
	{
		foreach (T item in _hashSet)
		{
			if (_comparison(item))
			{
				return true;
			}
		}
		return false;
	}

	public static Queue<T> enqueue<T>(this Queue<T> _queue, T _element)
	{
		_queue.Enqueue(_element);
		return _queue;
	}

	public static Queue<T> toQueue<T>(this IEnumerable<T> _enumerable)
	{
		Queue<T> queue = new Queue<T>();
		foreach (T item in _enumerable)
		{
			queue.enqueue(item);
		}
		return queue;
	}
}
