using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;

namespace AlternateModes;

[Serializable]
public class AlternateModeStatsData
{
	public List<Regions> completed = new List<Regions>();

	public string data = "";

	public AlternateModeStatsData(Regions _completed)
	{
		completed.addIfNotDuplicate(_completed);
	}

	public AlternateModeStatsData(Regions _completed, Func<string, string> _check_override)
	{
		completed.addIfNotDuplicate(_completed);
		data = _check_override(data);
	}
}
