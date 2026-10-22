using System;
using GRGLib.Generic;

[Serializable]
public struct RegionDifficultyData
{
	public MinMaxFloat starting_difficulty;

	public MinMaxFloat ending_difficulty;

	public MinMaxFloat difficulty_increase => ending_difficulty - starting_difficulty;

	public MinMaxFloat getDifficulty(int _progress)
	{
		return starting_difficulty + difficulty_increase * ((float)_progress / 100f);
	}

	public float getCaseDifficulty(int _progress, Random _rng)
	{
		return getDifficulty(_progress).get(_rng);
	}
}
