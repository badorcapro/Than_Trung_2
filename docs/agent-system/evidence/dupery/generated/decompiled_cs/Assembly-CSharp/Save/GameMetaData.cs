using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Serializable;
using GameStats;
using UnityEngine;

namespace Save;

[Serializable]
public class GameMetaData
{
	public enum Difficulty
	{
		EASY = -1,
		DEFAULT,
		CHALLENGE
	}

	public string file_name = "";

	public bool intro_cutscene_played;

	public SerializableDictionary<Regions, RegionProgressionSaveData> region_progression;

	public bool custom_mode_unlocked;

	public Difficulty difficulty;

	public static int custom_mode_unlock_tier => 3;

	public static int casino_unlock_tier => 3;

	public static int docks_unlock_tier => 3;

	public static int syndicate_unlock_tier => 12;

	public GameMetaData()
		: this(new Dictionary<Regions, RegionProgressionSaveData> { 
		{
			Regions.OFFICE,
			new RegionProgressionSaveData(1, 0)
		} })
	{
	}

	public GameMetaData(Dictionary<Regions, RegionProgressionSaveData> _prog)
	{
		region_progression = _prog.makeSerializable();
	}

	public Dictionary<Regions, RegionProgressionSaveData> getProgressionUnserialized()
	{
		return region_progression.unserialize();
	}

	public bool regionUnlocked(Regions _region)
	{
		if (region_progression.ContainsKey(_region))
		{
			return region_progression[_region].tier > 0;
		}
		return false;
	}

	public int getSummedTiers()
	{
		return getProgressionUnserialized().Aggregate(0, (int _a, KeyValuePair<Regions, RegionProgressionSaveData> _p) => _a + _p.Value.tier);
	}

	public int getTierOfRegion(Regions _region)
	{
		if (!region_progression.ContainsKey(_region))
		{
			return 0;
		}
		return region_progression[_region].using_tier;
	}

	public void setTierOfRegion(Regions _region, int _tier)
	{
		if (region_progression.ContainsKey(_region))
		{
			region_progression[_region].setUsingTier(_tier);
		}
	}

	public bool isRegionUsingCustomTier(Regions _region)
	{
		if (!region_progression.ContainsKey(_region))
		{
			return false;
		}
		return region_progression[_region].using_tier == region_progression[_region].tier;
	}

	public bool regionWantsNewSets(Regions _region)
	{
		if (!region_progression.ContainsKey(_region))
		{
			return false;
		}
		return region_progression[_region].force_new;
	}

	public void resetRegionWantsNewSet(Regions _region)
	{
		if (region_progression.ContainsKey(_region))
		{
			region_progression[_region].force_new = false;
		}
	}

	public bool onRunEnd(RunStats _stats)
	{
		if (_stats.run_region == Regions.CUSTOM)
		{
			return false;
		}
		if (!region_progression.ContainsKey(_stats.run_region))
		{
			Debug.LogError($"Finished run in {_stats.run_region} that is not unlocked!");
			return false;
		}
		if (_stats.run_won)
		{
			if (_stats.run_region == Regions.SYNDICATE)
			{
				SteamHelper.tryAchieve(Achiements.BEAT_SYNDICATE);
				if (difficulty == Difficulty.CHALLENGE && getSummedTiers() >= 28)
				{
					SteamHelper.tryAchieve(Achiements.CHALLENGE_ACCEPTED);
				}
			}
			if (region_progression[_stats.run_region].using_tier >= 9)
			{
				SteamHelper.tryAchieveCompletion(_stats.run_region);
			}
		}
		bool flag = region_progression[_stats.run_region].onRunEnd(_stats);
		region_progression[_stats.run_region].force_new = flag;
		checkUnlocks();
		return flag;
	}

	private void checkUnlocks()
	{
		Dictionary<Regions, RegionProgressionSaveData> progressionUnserialized = getProgressionUnserialized();
		if (!custom_mode_unlocked)
		{
			custom_mode_unlocked = progressionUnserialized.ContainsKey(Regions.OFFICE) && progressionUnserialized[Regions.OFFICE].tier >= custom_mode_unlock_tier;
		}
		if (!progressionUnserialized.ContainsKey(Regions.CASINO) && progressionUnserialized.ContainsKey(Regions.OFFICE) && progressionUnserialized[Regions.OFFICE].tier >= casino_unlock_tier)
		{
			region_progression[Regions.CASINO] = new RegionProgressionSaveData(1, 0);
			SteamHelper.tryAchieve(Achiements.UNLOCK_CASINO);
		}
		if (!progressionUnserialized.ContainsKey(Regions.DOCKS) && progressionUnserialized.ContainsKey(Regions.CASINO) && progressionUnserialized[Regions.CASINO].tier >= docks_unlock_tier)
		{
			region_progression[Regions.DOCKS] = new RegionProgressionSaveData(1, 0);
			SteamHelper.tryAchieve(Achiements.UNLOCK_DOCKS);
		}
		if (!progressionUnserialized.ContainsKey(Regions.SYNDICATE) && progressionUnserialized.ContainsKey(Regions.DOCKS) && progressionUnserialized[Regions.DOCKS].tier >= 2 && getTotalTier(progressionUnserialized) >= syndicate_unlock_tier)
		{
			region_progression[Regions.SYNDICATE] = new RegionProgressionSaveData(1, 0);
			SteamHelper.tryAchieve(Achiements.UNLOCK_SYNDICATE);
		}
	}

	private int getTotalTier(Dictionary<Regions, RegionProgressionSaveData> _prog)
	{
		return (_prog.ContainsKey(Regions.OFFICE) ? _prog[Regions.OFFICE].tier : 0) + (_prog.ContainsKey(Regions.CASINO) ? _prog[Regions.CASINO].tier : 0) + (_prog.ContainsKey(Regions.DOCKS) ? _prog[Regions.DOCKS].tier : 0);
	}

	public void setDifficulty(Difficulty _diff)
	{
		difficulty = _diff;
	}
}
