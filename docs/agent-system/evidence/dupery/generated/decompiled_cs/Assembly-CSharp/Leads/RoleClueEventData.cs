using System;
using System.Linq;
using UnityEngine;

namespace Leads;

[Serializable]
public class RoleClueEventData
{
	public RoleClassifications[] classes;

	public ClueTypes[] types = new ClueTypes[0];

	public bool random;

	public RoleClueEventData(bool _random, params RoleClassifications[] _available)
	{
		bool flag = _random;
		random = flag;
		classes = _available;
	}

	public RoleClueEventData(string _data)
	{
		try
		{
			string[] array = _data.Split('#');
			random = array[0] == "t";
			if (array[1] == "")
			{
				classes = new RoleClassifications[0];
			}
			else
			{
				classes = (from _i in array[1].fromStringCommaSeperate()
					select (RoleClassifications)_i).ToArray();
			}
			if (array.Length == 2 || array[2] == "")
			{
				types = new ClueTypes[0];
				return;
			}
			types = (from _i in array[2].fromStringCommaSeperate()
				select (ClueTypes)_i).ToArray();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to create role clue event data from string.\nData: {_data}\nError: {arg}");
			random = false;
			classes = new RoleClassifications[0];
		}
	}

	public RoleClueEventData setTypes(params ClueTypes[] _types)
	{
		types = _types;
		return this;
	}

	public string toData()
	{
		return (random ? "t" : "f") + "#" + classes.Select((RoleClassifications _c) => (int)_c).ToList().toStringCommaSeperated() + "#" + types.Select((ClueTypes _t) => (int)_t).ToList().toStringCommaSeperated();
	}
}
