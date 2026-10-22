using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Generic;
using UnityEngine;

[Serializable]
public class CaseRatioBuilderData
{
	public MinMaxInt address_size = new MinMaxInt(6, 12);

	public ClassificationRatioData innocents = new ClassificationRatioData(1, 16);

	public ClassificationRatioData meddlers = new ClassificationRatioData(0, 4);

	public ClassificationRatioData underlings = new ClassificationRatioData(1, 4);

	public ClassificationRatioData traitors = new ClassificationRatioData(0, 1);

	public ClassificationRatioData this[RoleClassifications _class] => _class switch
	{
		RoleClassifications.INNOCENT => innocents, 
		RoleClassifications.MEDDLER => meddlers, 
		RoleClassifications.UNDERLING => underlings, 
		RoleClassifications.TRAITOR => traitors, 
		_ => throw new ArgumentException($"No ratio data available for role classification {_class}!"), 
	};

	public CaseRatioBuilderData(CaseRatioBuilderData _data)
		: this(_data.address_size, _data.innocents, _data.meddlers, _data.underlings, _data.traitors)
	{
	}

	public CaseRatioBuilderData(MinMaxInt _address_size, ClassificationRatioData _innocent, ClassificationRatioData _meddlers, ClassificationRatioData _underlings, ClassificationRatioData _traitors)
	{
		address_size = _address_size;
		innocents = _innocent;
		meddlers = _meddlers;
		underlings = _underlings;
		traitors = _traitors;
	}

	public CaseRatioBuilderData(int _forced_address_size, int _forced_innocent, int _forced_meddlers, int _forced_underlings, int _forced_traitors)
	{
		address_size = new MinMaxInt((_forced_address_size == -1) ? 6 : _forced_address_size, (_forced_address_size == -1) ? 12 : _forced_address_size);
		innocents = new ClassificationRatioData(_forced_innocent, 1, 16);
		meddlers = new ClassificationRatioData(_forced_meddlers, 0, 4);
		underlings = new ClassificationRatioData(_forced_underlings, 1, 4);
		traitors = new ClassificationRatioData(_forced_traitors, 0, 1);
	}

	public CaseRatioBuilderData(List<Roles> _available_roles, int _forced_roles = -1)
		: this(_available_roles, (_forced_roles == -1) ? new MinMaxInt(6, 12) : new MinMaxInt(_forced_roles, _forced_roles))
	{
	}

	public CaseRatioBuilderData(List<Roles> _available_roles, MinMaxInt _address_size)
	{
		address_size = _address_size;
		Dictionary<RoleClassifications, int> dict = new Dictionary<RoleClassifications, int>();
		foreach (Roles _available_role in _available_roles)
		{
			RoleClassifications classificationFromRoleType = _available_role.getClassificationFromRoleType();
			dict.increaseOrCreate(classificationFromRoleType, 1);
		}
		innocents = new ClassificationRatioData(1, dict.getOrDefault(RoleClassifications.INNOCENT, 1));
		meddlers = new ClassificationRatioData(0, Mathf.Min(dict.getOrDefault(RoleClassifications.MEDDLER, 0), 4));
		underlings = new ClassificationRatioData(1, Mathf.Min(dict.getOrDefault(RoleClassifications.UNDERLING, 1), 4));
		traitors = new ClassificationRatioData(0, Mathf.Min(dict.getOrDefault(RoleClassifications.TRAITOR, 0), 1));
	}

	public CaseRatioBuilderData setMin(RoleClassifications _class, int _min)
	{
		if (this[_class].min_wanted >= _min)
		{
			return this;
		}
		switch (_class)
		{
		case RoleClassifications.INNOCENT:
			innocents.min_wanted = _min;
			innocents.max_allowed = Mathf.Max(_min, innocents.max_allowed);
			break;
		case RoleClassifications.MEDDLER:
			meddlers.min_wanted = _min;
			meddlers.max_allowed = Mathf.Max(_min, meddlers.max_allowed);
			break;
		case RoleClassifications.UNDERLING:
			underlings.min_wanted = _min;
			underlings.max_allowed = Mathf.Max(_min, underlings.max_allowed);
			break;
		case RoleClassifications.TRAITOR:
			traitors.min_wanted = _min;
			traitors.max_allowed = Mathf.Max(_min, traitors.max_allowed);
			break;
		}
		return this;
	}

	public CaseRatioBuilderData setMax(RoleClassifications _class, int _max)
	{
		if (this[_class].max_allowed <= _max)
		{
			return this;
		}
		switch (_class)
		{
		case RoleClassifications.INNOCENT:
			innocents.max_allowed = _max;
			break;
		case RoleClassifications.MEDDLER:
			meddlers.max_allowed = _max;
			break;
		case RoleClassifications.UNDERLING:
			underlings.max_allowed = _max;
			break;
		case RoleClassifications.TRAITOR:
			traitors.max_allowed = _max;
			break;
		}
		return this;
	}

	public CaseRatioBuilderData setForced(RoleClassifications _class, int _forced)
	{
		return setMin(_class, _forced).setMax(_class, _forced);
	}

	public int getMinRatioFromClassifications()
	{
		return innocents.min_wanted + meddlers.min_wanted + traitors.min_wanted + underlings.min_wanted;
	}

	public bool canHaveClassification(RoleClassifications _class)
	{
		return this[_class].max_allowed > 0;
	}

	public void updateBuilderFromForcedRoles(List<Roles> _forced, List<Roles> _suspected)
	{
		Dictionary<RoleClassifications, int> dictionary = _forced.Select((Roles _r) => _r.getClassificationFromRoleType()).ToList().countToDictionary();
		address_size.min = Mathf.Max(address_size.min, _forced.Count);
		if (address_size.min > address_size.max)
		{
			address_size.max = address_size.min;
		}
		foreach (KeyValuePair<RoleClassifications, int> item in dictionary)
		{
			setMin(item.Key, item.Value);
		}
	}

	public CaseRatioBuilderData copy()
	{
		return new CaseRatioBuilderData(address_size, innocents, meddlers, underlings, traitors);
	}

	public string print()
	{
		return "Innocent: " + innocents.print() + "\nMeddlers: " + meddlers.print() + "\nUnderlings: " + underlings.print() + "\nTraitors: " + traitors.print();
	}
}
