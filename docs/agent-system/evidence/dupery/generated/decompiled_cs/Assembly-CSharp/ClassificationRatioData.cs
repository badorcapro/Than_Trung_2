using System;
using UnityEngine;

[Serializable]
public struct ClassificationRatioData
{
	public int min_wanted;

	public int forced;

	public int max_allowed;

	public string print()
	{
		if (forced != -1)
		{
			return $"Forced: {forced}";
		}
		return $"Min-Max: {min_wanted}-{max_allowed}";
	}

	public ClassificationRatioData(int _min, int _max)
	{
		min_wanted = _min;
		max_allowed = _max;
		forced = -1;
	}

	public ClassificationRatioData(int _forced, int _min, int _max)
	{
		forced = _forced;
		min_wanted = _min;
		max_allowed = _max;
	}

	public void setMin(int _min)
	{
		min_wanted = _min;
		max_allowed = Mathf.Max(_min, max_allowed);
	}
}
