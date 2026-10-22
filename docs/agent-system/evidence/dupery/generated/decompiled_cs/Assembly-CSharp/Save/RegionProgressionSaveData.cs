using System;
using GameStats;
using UnityEngine;

namespace Save;

[Serializable]
public class RegionProgressionSaveData
{
	public const int max_tier = 9;

	public int m_using_tier = -1;

	public int tier;

	public int xp;

	public bool force_new;

	public int runs_attempted;

	public int runs_succeeded;

	public int current_streak;

	public int using_tier
	{
		get
		{
			if (m_using_tier > 0)
			{
				return m_using_tier;
			}
			return tier;
		}
	}

	public RegionProgressionSaveData(int _tier, int _xp)
	{
		tier = _tier;
		xp = _xp;
		runs_attempted = 0;
		runs_succeeded = 0;
		current_streak = 0;
	}

	public void setUsingTier(int _tier)
	{
		if (_tier == tier)
		{
			m_using_tier = -1;
		}
		else
		{
			m_using_tier = Mathf.Clamp(_tier, 1, tier);
		}
	}

	public bool onRunEnd(RunStats _stats)
	{
		runs_attempted++;
		runs_succeeded += (_stats.run_won ? 1 : 0);
		current_streak = (_stats.run_won ? (current_streak + 1) : 0);
		return gainXp(_stats);
	}

	private bool gainXp(RunStats _stats)
	{
		if (tier >= 9 || !_stats.run_won || tier != using_tier)
		{
			return false;
		}
		xp += ((tier <= 5) ? 100 : 50);
		if (xp >= 100)
		{
			xp = 0;
			tier++;
			return true;
		}
		return false;
	}
}
