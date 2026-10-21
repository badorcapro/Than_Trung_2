using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;

namespace GRGLib.Maybe;

public static class MaybeExtensions
{
	public static Maybe<T> maybe<T>(this T _obj)
	{
		return new Maybe<T>(_obj);
	}

	public static Maybe<List<T>> add<T>(this Maybe<List<T>> list, T type)
	{
		if (!list.is_some)
		{
			list = type.makeListFromItem().maybe();
			return list;
		}
		list.value.Add(type);
		return list;
	}

	public static Maybe<List<T>> add<T>(this Maybe<List<T>> list, List<T> types)
	{
		if (!list.is_some)
		{
			list = new Maybe<List<T>>(new List<T>());
		}
		list.value.AddRange(types);
		return list;
	}

	public static Maybe<List<T>> add<T>(this Maybe<List<T>> list, HashSet<T> types)
	{
		if (!list.is_some)
		{
			list = new Maybe<List<T>>(new List<T>());
		}
		list.value.AddRange(types);
		return list;
	}

	public static T returnValueOrDefault<T>(this Maybe<T> _maybe, T _default)
	{
		if (!_maybe.is_some)
		{
			return _default;
		}
		return _maybe.value;
	}

	public static void doActionIfSome<T>(this Maybe<T> _maybe_val, Action<T> _action)
	{
		_maybe_val.doActionIfSome(_action, delegate
		{
		});
	}

	public static void doActionIfSome<T>(this Maybe<T> _maybe_val, Action<T> _action, Action _fail)
	{
		if (!_maybe_val.is_some)
		{
			_fail();
		}
		else
		{
			_action(_maybe_val.value);
		}
	}

	public static Maybe<T2> returnModifiedValueIfSome<T, T2>(this Maybe<T> _maybe, Func<T, T2> _conversion)
	{
		if (_maybe.is_some)
		{
			return _conversion(_maybe.value).maybe();
		}
		return new Maybe<T2>();
	}

	public static Maybe<T2> returnModifiedValueIfSome<T, T2>(this Maybe<T> _maybe, Func<T, Maybe<T2>> _conversion)
	{
		if (_maybe.is_some)
		{
			return _conversion(_maybe.value);
		}
		return new Maybe<T2>();
	}

	public static Maybe<T> maybeNull<T>(this T _value)
	{
		if (_value == null)
		{
			return new Maybe<T>();
		}
		return _value.maybe();
	}
}
