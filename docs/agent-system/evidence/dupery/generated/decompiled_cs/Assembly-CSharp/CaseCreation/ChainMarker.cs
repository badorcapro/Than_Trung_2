using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;

namespace CaseCreation;

public class ChainMarker<T> where T : Enum
{
	public T data;

	public bool locked;

	public Maybe<ChainMarker<Roles>> from = new Maybe<ChainMarker<Roles>>();

	public List<ChainMarker<Roles>> added = new List<ChainMarker<Roles>>();

	public ChainMarker(T _data, bool _locked = false)
	{
		data = _data;
		locked = _locked;
	}

	public ChainMarker(T _data, Maybe<ChainMarker<Roles>> _from, bool _locked = false)
	{
		data = _data;
		locked = _locked;
		from = _from;
	}

	public ChainMarker(T _data, ChainMarker<Roles> _from)
	{
		data = _data;
		from = _from.maybe();
	}

	public void addToChain(ChainMarker<Roles> _chain)
	{
		added.Add(_chain);
	}

	public bool existsFrom(Roles _data)
	{
		T val = data;
		if (!(val is Roles roles) || roles != _data)
		{
			if (from.is_some)
			{
				return from.value.existsFrom(_data);
			}
			return false;
		}
		return true;
	}

	public bool existsFrom(Func<Roles, bool> _condition)
	{
		T val = data;
		if (!(val is Roles arg) || !_condition(arg))
		{
			if (from.is_some)
			{
				return from.value.existsFrom(_condition);
			}
			return false;
		}
		return true;
	}

	private int addIfOfClass(RoleClassifications _class, int _current)
	{
		T val = data;
		return _current + ((val is Roles role && role.getClassificationFromRoleType() == _class) ? 1 : 0);
	}

	public int fromClassCount(RoleClassifications _class, int _current = 0)
	{
		if (!from.is_some)
		{
			return addIfOfClass(_class, _current);
		}
		return from.value.fromClassCount(_class, addIfOfClass(_class, _current));
	}

	public int addIfSatisfy(Func<Roles, bool> _condition, int _current)
	{
		T val = data;
		return _current + ((val is Roles arg && _condition(arg)) ? 1 : 0);
	}

	public int fromCount(Func<Roles, bool> _condition, int _current = 0)
	{
		if (!from.is_some)
		{
			return addIfSatisfy(_condition, _current);
		}
		return from.value.fromCount(_condition, addIfSatisfy(_condition, _current));
	}

	public List<ChainMarker<Roles>> getAllAdded(List<ChainMarker<Roles>> _start)
	{
		return added.Aggregate(_start.addRange(added), (List<ChainMarker<Roles>> _a, ChainMarker<Roles> _cm) => _a.addRange(_cm.getAllAdded(_a)));
	}
}
