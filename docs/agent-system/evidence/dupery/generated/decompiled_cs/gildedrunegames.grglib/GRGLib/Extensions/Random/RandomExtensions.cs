using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using UnityEngine;

namespace GRGLib.Extensions.Random;

public static class RandomExtensions
{
	public static System.Random freshRandom()
	{
		return new System.Random(Guid.NewGuid().GetHashCode());
	}

	public static float nextFloat(this System.Random _rnd, float _min, float _max_inclusive)
	{
		return (float)(_rnd.NextDouble() * (double)(_max_inclusive - _min) + (double)_min);
	}

	public static Vector2 nextVector2(this System.Random _rng, Vector2 _min, Vector2 _max)
	{
		return new Vector2(_rng.nextFloat(_min.x, _max.x), _rng.nextFloat(_min.y, _max.y));
	}

	public static Vector2 nextVector2Linear(this System.Random _rng, Vector2 _min, Vector2 _max)
	{
		return _min + (_max - _min) * _rng.nextFloat(0f, 1f);
	}

	public static Vector3 nextVector3(this System.Random _rng, Vector3 _min, Vector3 _max)
	{
		return new Vector3(_rng.nextFloat(_min.x, _max.x), _rng.nextFloat(_min.y, _max.y), _rng.nextFloat(_min.z, _max.z));
	}

	public static Vector3 nextVector3Linear(this System.Random _rng, Vector3 _min, Vector3 _max)
	{
		return _min + (_max - _min) * _rng.nextFloat(0f, 1f);
	}

	public static int randomBetween(this Vector2Int _min_max, System.Random _rnd)
	{
		return _rnd.Next(_min_max.x, _min_max.y);
	}

	public static Vector2Int randomBetween(this System.Random _rng, Vector2Int _start, Vector2Int _end, bool _linear = false)
	{
		if (_linear)
		{
			int num = _rng.Next(1001);
			Vector2 vector = _start - _end;
			Vector2 vector2 = _start + vector * ((float)num / 1000f);
			return new Vector2Int((int)vector2.x, (int)vector2.y);
		}
		return new Vector2Int(_rng.Next(_start.x, _end.x), _rng.Next(_start.y, _end.y));
	}

	public static Vector3 getRandomPositionBetween(this Vector3 a, Vector3 b, System.Random _rnd)
	{
		return new Vector3((float)_rnd.NextDouble() * (b.x - a.x) + a.x, (float)_rnd.NextDouble() * (b.y - a.y) + a.y, 0f);
	}

	public static Maybe<T> choose<T>(this List<T> _list, System.Random _rand)
	{
		if (_list.Count <= 0)
		{
			return new Maybe<T>();
		}
		return new Maybe<T>(_list[_rand.Next(0, _list.Count)]);
	}

	public static Maybe<T> weightedChoose<T>(this List<(T, int)> _list, System.Random _rand)
	{
		int num = _list.Select(((T, int) p) => p.Item2).Aggregate(0, (int l, int r) => (r < 0) ? l : (l + r));
		if (num <= 0)
		{
			return new Maybe<T>();
		}
		return _list.Aggregate((new Maybe<T>(), _rand.Next(0, num)), ((Maybe<T>, int) acc, (T, int) p) => (acc.Item2 >= 0) ? (new Maybe<T>(p.Item1), acc.Item2 - p.Item2) : acc, ((Maybe<T>, int) x) => x).Item1;
	}

	public static Maybe<List<T>> weightedChooseMany<T>(this List<(T, int)> _list, int _number, System.Random _rand, bool _remove_on_take = true)
	{
		List<(T, int)> list = _list.copy();
		int num = list.Select(((T, int) p) => p.Item2).Aggregate((int l, int r) => (r < 0) ? l : (l + r));
		if (num <= 0)
		{
			return new Maybe<List<T>>();
		}
		List<T> list2 = new List<T>();
		for (int i = 0; i < _number; i++)
		{
			num = list.Select(((T, int) p) => p.Item2).Aggregate((int l, int r) => (r < 0) ? l : (l + r));
			int num2 = _rand.Next(num);
			int j;
			for (j = 0; j < list.Count && num2 >= list[j].Item2; j++)
			{
				num2 -= list[j].Item2;
			}
			list2.add(list[j].Item1);
			if (_remove_on_take)
			{
				list.RemoveAt(j);
			}
		}
		return list2.maybe();
	}

	public static T getRandomElementFromList<T>(this List<T> _list, System.Random _rnd)
	{
		return _list[_rnd.Next(_list.Count)];
	}

	public static List<T> getRandomElementsFromList<T>(this List<T> _list, System.Random _rnd, int _quant)
	{
		List<T> list = _list.copy();
		List<T> list2 = new List<T>();
		for (int i = 0; i < _quant; i++)
		{
			if (list.Count == 0)
			{
				break;
			}
			T item = list[_rnd.Next(0, list.Count)];
			list2.Add(item);
			list.Remove(item);
		}
		return list2;
	}

	public static List<T> getRandomElementsFromList<T>(this List<T> _list, System.Random _rnd)
	{
		return _list.getRandomElementsFromList(_rnd, _rnd.Next(1, _list.Count + 1));
	}

	public static T getRandomElement<T>(this HashSet<T> _hashset, System.Random _rnd)
	{
		return _hashset.ElementAt(_rnd.Next(_hashset.Count));
	}

	public static List<T> getRandomElements<T>(this HashSet<T> _hashset, System.Random _rnd, int _nb)
	{
		return _hashset.ToList().getRandomElementsFromList(_rnd, _nb);
	}

	public static List<T> addRandomUnique<T>(this List<T> _current, List<T> _extra_rand, System.Random _rnd, int _nb_to_add = 1)
	{
		if (_nb_to_add > _extra_rand.Count)
		{
			throw new ArgumentException($"Cannot add {_nb_to_add} elements from the list extra_rand as it is of size {_extra_rand.Count}! (in GenericHelper.addRandomUnique())");
		}
		_current.AddRange(_extra_rand.getRandomElementsFromList(_rnd, _nb_to_add));
		return _current;
	}

	public static T getRandomValueOfEnum<T>(this System.Random _rnd) where T : Enum
	{
		List<T> list = new List<T>().addAll();
		return list[_rnd.Next(list.Count)];
	}

	public static T getRandomEnumValueBetween<T>(this System.Random _rng, T _min, T _max_inclusive) where T : Enum
	{
		return (T)(object)_rng.Next((int)(object)_min, (int)(object)_max_inclusive + 1);
	}

	public static void shuffle<T>(this IList<T> list, System.Random _rng)
	{
		int num = list.Count;
		while (num > 1)
		{
			num--;
			int index = _rng.Next(num + 1);
			T value = list[index];
			list[index] = list[num];
			list[num] = value;
		}
	}

	public static Queue<T> shuffle<T>(this Queue<T> _queue, System.Random _rng)
	{
		List<T> list = _queue.ToList();
		list.shuffle(_rng);
		Queue<T> out_q = new Queue<T>();
		list.ForEach(delegate(T _e)
		{
			out_q.Enqueue(_e);
		});
		return out_q;
	}
}
