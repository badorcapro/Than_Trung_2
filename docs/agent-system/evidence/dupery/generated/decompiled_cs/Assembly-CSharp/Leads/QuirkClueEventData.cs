using System;
using UnityEngine;

namespace Leads;

[Serializable]
public struct QuirkClueEventData
{
	public enum QuirkTypeAllowed
	{
		ALL,
		ONLY_GOOD,
		ONLY_BAD
	}

	public QuirkTypeAllowed quirks_allowed;

	public bool random;

	public Func<CaseQuirks, bool> validation_func => quirks_allowed switch
	{
		QuirkTypeAllowed.ONLY_GOOD => (CaseQuirks _q) => _q.isGoodQuirk(), 
		QuirkTypeAllowed.ONLY_BAD => (CaseQuirks _q) => _q.isBadQuirk(), 
		QuirkTypeAllowed.ALL => (CaseQuirks _q) => true, 
		_ => (CaseQuirks _q) => true, 
	};

	public QuirkClueEventData(QuirkTypeAllowed _allowed, bool _random)
	{
		bool flag = _random;
		quirks_allowed = _allowed;
		random = flag;
	}

	public QuirkClueEventData(string _data)
	{
		try
		{
			string[] array = _data.Split(',');
			quirks_allowed = (QuirkTypeAllowed)int.Parse(array[0]);
			random = array[1] == "t";
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to create quirk clue event data with given data.\nData: {_data}\nError: {arg}");
			random = false;
			quirks_allowed = QuirkTypeAllowed.ALL;
		}
	}

	public string toData()
	{
		return string.Format("{0},{1}", (int)quirks_allowed, random ? "t" : "f");
	}
}
